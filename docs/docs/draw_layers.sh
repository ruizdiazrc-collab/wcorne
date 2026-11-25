#!/usr/bin/env bash
# Regenera docs/keymap.yaml y las imágenes de docs/layers/ desde config/corne.keymap.
# Requiere: pip install keymap-drawer
set -e
cd "$(dirname "$0")/.."
keymap -c docs/keymap_drawer.config.yaml parse -c 12 -z config/corne.keymap -o docs/keymap.yaml
python3 - <<'P'
import yaml,re
p='docs/keymap.yaml'; d=yaml.safe_load(open(p))
d['layout']={'ortho_layout':{'split':True,'rows':3,'columns':6,'thumbs':3}}
for name,L in d['layers'].items():
    flat=[k for row in L for k in row]
    for i,k in enumerate(flat):
        if isinstance(k,str):
            m=re.fullmatch(r'KP (\d)',k)
            if m: flat[i]={'t':m[1],'s':'KP'}
        elif isinstance(k,dict) and k.get('type')=='held':
            flat[i]={'t':{38:'Num',40:'Sym'}.get(i,k.get('t','')),'type':'held'}
    d['layers'][name]=[flat[r*12:(r+1)*12] for r in range(3)]+[flat[36:]]
yaml.safe_dump(d,open(p,'w'),allow_unicode=True,sort_keys=False)
P
for L in Base Num Numpad Sym; do keymap -c docs/keymap_drawer.config.yaml draw docs/keymap.yaml -s $L > docs/layers/$(echo $L | tr A-Z a-z).svg; done
keymap -c docs/keymap_drawer.config.yaml draw docs/keymap.yaml > docs/layers/all.svg
