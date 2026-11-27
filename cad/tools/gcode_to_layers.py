import sys,re,json,gzip,base64
TYPES=['External perimeter','Perimeter','Overhang perimeter','Internal infill','Solid infill','Top solid infill','Bridge infill','Gap fill','Skirt/Brim','Other']
def tidx(t):
    return TYPES.index(t) if t in TYPES else 9
src,dst=sys.argv[1:3]
x=y=z=e=0.0; rel_e=False; typ=9; layers={}; cur=None
def flush():
    global cur
    if cur and len(cur[1])>=4: layers.setdefault(round(z,2),[]).append(cur)
    cur=None
for line in open(src):
    if line.startswith(';TYPE:'):
        flush(); typ=tidx(line[6:].strip()); continue
    if line.startswith('M83'): rel_e=True
    if line.startswith('M82'): rel_e=False
    if not (line.startswith('G1 ') or line.startswith('G0 ')): 
        if line.startswith('G92'):
            m=re.search(r'E([-\d.]+)',line)
            if m: e=float(m.group(1))
        continue
    p=dict((k,float(v)) for k,v in re.findall(r'([XYZE])([-\d.]+)',line.split(';')[0]))
    nx,ny,nz=p.get('X',x),p.get('Y',y),p.get('Z',z)
    ext=False
    if 'E' in p:
        de=p['E'] if rel_e else p['E']-e
        e = e+p['E'] if rel_e else p['E']
        ext = de>0 and ('X' in p or 'Y' in p)
    if nz!=z: flush(); z=nz
    if ext:
        if cur is None or cur[0]!=typ: flush(); cur=[typ,[round(x*10),round(y*10)]]
        cur[1]+= [round(nx*10),round(ny*10)]
    else:
        flush()
    x,y=nx,ny
flush()
def dl(pts):
    o=pts[:2]
    for i in range(2,len(pts)): o.append(pts[i]-pts[i-2])
    return o
L=[[k,[[t,dl(q)] for t,q in v]] for k,v in sorted(layers.items())]
data=json.dumps({'unit':0.1,'delta':1,'types':TYPES,'layers':L},separators=(',',':')).encode()
open(dst,'w').write(base64.b64encode(gzip.compress(data,9)).decode())
print(src.split('/')[-1], len(L),'layers', len(data)//1024,'KB json', len(open(dst).read())//1024,'KB b64gz')
