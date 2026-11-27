import trimesh, numpy as np, json, sys, math
from shapely.geometry import Polygon, Point, box
from shapely.affinity import rotate, translate
from shapely.ops import unary_union
D='cad/stl/'   # run from the repo root
OUT='cad/print-runs/'
GAP=2.5; M=2.0  # lock pins need brim room  # gap between parts, bed margin
BED=box(M,M,220-M,220-M)
meshes={}; hulls={}
def load(n):
    if n not in meshes:
        m=trimesh.load(D+n+'.stl'); m.apply_translation(-m.bounds[0]*[1,1,1]); m.apply_translation([-m.extents[0]/2,-m.extents[1]/2,0])
        meshes[n]=m
        from scipy.spatial import ConvexHull
        v=m.vertices[:,:2]; h=ConvexHull(v); hulls[n]=Polygon(v[h.vertices])
    return meshes[n]
def fp(n,x,y,r):
    load(n); return translate(rotate(hulls[n],r,origin=(0,0)),x,y)
class Plate:
    def __init__(s,name): s.name=name; s.items=[]; s.polys=[]
    def ok(s,p):
        if not BED.contains(p): return False
        return all(p.distance(q)>=GAP for q in s.polys)
    def add(s,n,x,y,r,force=False):
        p=fp(n,x,y,r)
        if not force and not s.ok(p): return False
        if force: assert s.ok(p),(s.name,n,x,y,r, BED.contains(p))
        s.items.append((n,float(x),float(y),float(r))); s.polys.append(p); return True
    def fill(s,n,count,rots=(0,90),step=2.0):
        placed=0
        for y in np.arange(M,220,step):
            for x in np.arange(M,220,step):
                for r in rots:
                    if placed<count and s.add(n,x,y,r): placed+=1; break
        assert placed==count,(s.name,n,placed,count)
    def coins(s,n,count):
        load(n); best=None
        pitch=24+GAP+0.3
        for ox in np.arange(0,pitch,2):
            for oy in np.arange(0,pitch*0.866*2,2):
                pts=[]
                for j in range(-2,12):
                    for i in range(-2,12):
                        x=ox+i*pitch+(j%2)*pitch/2; y=oy+j*pitch*0.866
                        p=fp(n,x,y,0)
                        if s.ok(p): pts.append((x,y))
                if best is None or len(pts)>len(best): best=pts
        # keep the count closest to the middle of the free area
        assert len(best)>=count,(s.name,len(best))
        cx=np.mean([p[0] for p in best]); cy=np.mean([p[1] for p in best])
        best.sort(key=lambda p:(p[1],p[0]))
        for x,y in best[:count]: s.add(n,x,y,0,force=True)
        return len(best)
plates=[]
P=Plate('run0'); P.add('sensor_test',100,110,0,True); P.add('coin',140,110,0,True); plates.append(P)
P=Plate('run1'); P.add('core_half',110,87.8,0,True)
P.add('foot_socket',57,196,90,True); P.add('foot_socket',163,196,90,True); plates.append(P)
P=Plate('run2'); P.add('core_half',110,87.8,0,True)
P.add('gate',110,186.0,0,True); P.add('gate',110,207.8,0,True); plates.append(P)
for nm,up in (('run3','upright_left'),('run4','upright_right')):
    P=Plate(nm); P.add(up,110,110,45,True); n=P.coins('coin',21); print(nm,'coin spots',n); plates.append(P)
P=Plate('run5'); P.add('tray',110,M+30+0.5,0,True)
done=False
for th in np.arange(10,40,0.5):
    for cy in np.arange(100,200,1):
        if P.add('entry_bar',110,cy,th): done=True; break
    if done: break
print('bar angle',th,cy)
for n,c in (('servo_strap',2),('board_clip',5),('axle_pin',2),('lock_pin',3)):
    P.fill(n,c,rots=(0,90,45,135))
plates.append(P)
json.dump([{'name':p.name,'items':p.items} for p in plates],open(OUT+'plates.json','w'),indent=0)
for p in plates: print(p.name,[(i[0],round(i[1]),round(i[2]),i[3]) for i in p.items if i[0]!='coin'], sum(1 for i in p.items if i[0]=='coin'),'coins')
