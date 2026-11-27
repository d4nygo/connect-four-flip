import trimesh, numpy as np, json, zipfile, sys
D='cad/stl/'   # run from the repo root
OUT='cad/print-runs/'
SOLID={'coin','gate','board_clip','servo_strap','axle_pin','lock_pin'}
plates=json.load(open(OUT+'plates.json'))
base={}
def load(n):
    if n not in base:
        m=trimesh.load(D+n+'.stl'); m.apply_translation(-m.bounds[0]); m.apply_translation([-m.extents[0]/2,-m.extents[1]/2,0]); base[n]=m
    return base[n].copy()
for p in plates:
    objs=[]
    for k,(n,x,y,r) in enumerate(p['items']):
        m=load(n); m.apply_transform(trimesh.transformations.rotation_matrix(np.radians(r),[0,0,1])); m.apply_translation([x,y,0]); objs.append((n,m))
    model=['<?xml version="1.0" encoding="UTF-8"?>\n<model unit="millimeter" xml:lang="en-US" xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02">\n<resources>']
    cfg=['<?xml version="1.0" encoding="UTF-8"?>\n<config>']
    for i,(n,m) in enumerate(objs,1):
        model.append('<object id="%d" type="model"><mesh><vertices>'%i)
        model.append(''.join('<vertex x="%.4f" y="%.4f" z="%.4f"/>'%tuple(v) for v in m.vertices))
        model.append('</vertices><triangles>')
        model.append(''.join('<triangle v1="%d" v2="%d" v3="%d"/>'%tuple(f) for f in m.faces))
        model.append('</triangles></mesh></object>')
        c='<object id="%d" instances_count="1"><metadata type="object" key="name" value="%s_%d"/>'%(i,n,i)
        if n in SOLID: c+='<metadata type="object" key="fill_density" value="100%"/><metadata type="object" key="fill_pattern" value="rectilinear"/>'
        if n=='lock_pin': c+='<metadata type="object" key="brim_width" value="3"/>'
        c+='<volume firstid="0" lastid="%d"><metadata type="volume" key="name" value="%s"/></volume></object>'%(len(m.faces)-1,n)
        cfg.append(c)
    model.append('</resources>\n<build>'+''.join('<item objectid="%d"/>'%i for i in range(1,len(objs)+1))+'</build>\n</model>')
    cfg.append('</config>')
    with zipfile.ZipFile(OUT+p['name']+'.3mf','w',zipfile.ZIP_DEFLATED) as z:
        z.writestr('[Content_Types].xml','<?xml version="1.0" encoding="UTF-8"?>\n<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/></Types>')
        z.writestr('_rels/.rels','<?xml version="1.0" encoding="UTF-8"?>\n<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Target="/3D/3dmodel.model" Id="rel0" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')
        z.writestr('3D/3dmodel.model','\n'.join(model))
        z.writestr('Metadata/Slic3r_PE_model.config','\n'.join(cfg))
    print(p['name'],len(objs),'objects')
