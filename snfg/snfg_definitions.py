#!/usr/bin/env python
# encoding: utf-8

ATOM_NAMES = set('C1 C2 C3 C4 C5 O5 O6'.split())

COLORS = dict(
    white=(0.00, 0.00, 0.00, 0.00),
    blue=(1.00, 0.50, 0.00, 0.00),
    green=(1.00, 0.00, 1.00, 0.00),
    yellow=(0.00, 0.15, 1.00, 0.00),
    cyan=(0.41, 0.05, 0.03, 0.00),
    pink=(0.00, 0.47, 0.24, 0.00),
    purple=(0.38, 0.88, 0.00, 0.00),
    tan=(0.32, 0.48, 0.76, 0.13),
    orange=(0.00, 0.50, 1.00, 0.00),
    red=(0.00, 1.00, 1.00, 0.00),
)

SCALES = dict(
    sphere=0.5,
    cube=0.806,
    diamond=1.3,
    cone=1.0,
    rectangle=1.0,
    star=1.0,
    hexagon=1.15,
    pentagon=1.0,
)

RESIDUES = {
    'Glc': dict(
        color='blue',
        shape='sphere',
        name='Glucose'
    ),
    'Man': dict(
        color='green',
        shape='sphere',
        name='Mannose'
    ),
    'Gal': dict(
        color='yellow',
        shape='sphere',
        name='Galactose'
    ),
    'Gul': dict(
        color='orange',
        shape='sphere',
        name='Gulose'
    ),
    'Alt': dict(
        color='pink',
        shape='sphere',
        name='Altrose'
    ),
    'All': dict(
        color='purple',
        shape='sphere',
        name='Allose'
    ),
    'Tal': dict(
        color='cyan',
        shape='sphere',
        name='Talose'
    ),
    'Ido': dict(
        color='brown',
        shape='sphere',
        name='Idose'
    ),
    # Filled cube
    'GlcNAc': dict(
        color='blue',
        shape='cube',
        name='N acetyl glucosamine'
    ),
    'ManNAc': dict(
        color='green',
        shape='cube',
        name='N acetyl mannosamine'
    ),
    'GalNAc': dict(
        color='yellow',
        shape='cube',
        name='N acetyl galactosamine'
    ),
    'GulNAc': dict(
        color='orange',
        shape='cube',
        name='N acetyl gulosamine'
    ),
    'AltNAc': dict(
        color='pink',
        shape='cube',
        name='N acetyl altrosamine'
    ),
    'AllNAc': dict(
        color='purple',
        shape='cube',
        name='N acetyl allosamine'
    ),
    'TalNAc': dict(
        color='cyan',
        shape='cube',
        name='N acetyl talosamine'
    ),
    'IdoNAc': dict(
        color='brown',
        shape='cube',
        name='N acetyl idosamine'
    ),
    # Crossed cube
    'GlcN': dict(
        color='white blue',
        shape='cube',
        name='Glucosamine'
    ),
    'ManN': dict(
        color='white green',
        shape='cube',
        name='Mannosamine'
    ),
    'GalN': dict(
        color='white yellow',
        shape='cube',
        name='Galactosamine'
    ),
    'GulN': dict(
        color='white orange',
        shape='cube',
        name='Gulosamine'
    ),
    'AltN': dict(
        color='white pink',
        shape='cube',
        name='Altrosamine'
    ),
    'AllN': dict(
        color='white purple',
        shape='cube',
        name='Allosamine'
    ),
    'TalN': dict(
        color='white cyan',
        shape='cube',
        name='Talosamine'
    ),
    'IdoN': dict(
        color='white brown',
        shape='cube',
        name='Idosamine'
    ),
    # Divided diamond
    'GlcA': dict(
        color='blue white',
        shape='diamond',
        name='Glucuronic acid'
    ),
    'ManA': dict(
        color='green white',
        shape='diamond',
        name='Mannuronic acid'
    ),
    'GalA': dict(
        color='yellow white',
        shape='diamond',
        name='Galacturonic acid'
    ),
    'GulA': dict(
        color='orange white',
        shape='diamond',
        name='Guluronic acid'
    ),
    'AltA': dict(
        color='white pink',
        shape='diamond',
        name='Altruronic acid'
    ),
    'AllA': dict(
        color='purple white',
        shape='diamond',
        name='Alluronic acid'
    ),
    'TalA': dict(
        color='cyanwhite',
        shape='diamond',
        name='Taluronic acid'
    ),
    'IdoA': dict(
        color='white brown',
        shape='diamond',
        name='Iduronic acid'
    ),
    # Filled cone
    'Qui': dict(
        color='blue',
        shape='cone',
        name='Quinovose'
    ),
    'Qui': dict(
        color='blue',
        shape='cone',
        name='Quinovose'
    ),
    'Rha': dict(
        color='green',
        shape='cone',
        name='Rhamnose'
    ),
    'x6dAlt': dict(
        color='pink',
        shape='cone',
        name='6 Deoxy altrose'
    ),
    'x6dTal': dict(
        color='cyan',
        shape='cone',
        name='6 Deoxy talose'
    ),
    'Fuc': dict(
        color='red',
        shape='cone',
        name='Fucose'
    ),
    # Divided cone
    'QuiNAc': dict(
        color='white blue',
        shape='cone',
        name='N Acetyl quinovosamine'
    ),
    'RhaNAc': dict(
        color='white green',
        shape='cone',
        name='N Acetyl rhamnosamine'
    ),
    'FucNAc': dict(
        color='white red',
        shape='cone',
        name='N Acetyl fucosamine'
    ),
    # Flat rectangle
    'Oli': dict(
        color='blue',
        shape='rectangle',
        name='Olivose'
    ),
    'Tyv': dict(
        color='green',
        shape='rectangle',
        name='Tyvelose'
    ),
    'Abe': dict(
        color='orange',
        shape='rectangle',
        name='Abequose'
    ),
    'Par': dict(
        color='pink',
        shape='rectangle',
        name='Paratose'
    ),
    'Dig': dict(
        color='purple',
        shape='rectangle',
        name='Digitoxose'
    ),
    'Col': dict(
        color='cyan',
        shape='rectangle',
        name='Colitose'
    ),
    # Filled star
    'Ara': dict(
        color='green',
        shape='star',
        name='Arabinose'
    ),
    'Lyx': dict(
        color='yellow',
        shape='star',
        name='Lyxose'
    ),
    'Xyl': dict(
        color='orange',
        shape='star',
        name='Xylose'
    ),
    'Rib': dict(
        color='pink',
        shape='star',
        name='Ribose'
    ),
    # Filled diamond
    'Kdn': dict(
        color='green',
        shape='diamond',
        name='Ketodeoxynononic acid'
    ),
    'Neu5Ac': dict(
        color='purple',
        shape='diamond',
        name='N Acetylneuraminic acid'
    ),
    'Neu5Gc': dict(
        color='cyan',
        shape='diamond',
        name='N Glycolylneuraminic acid'
    ),
    'Neu': dict(
        color='brown',
        shape='diamond',
        name='Neuraminic acid'
    ),
    # Flat hexagon
    'Bac': dict(
        color='blue',
        shape='hexagon',
        name='Bacillosamine'
    ),
    'LDManHep': dict(
        color='green',
        shape='hexagon',
        name='L glycero D manno Heptose'
    ),
    'Kdo': dict(
        color='yellow',
        shape='hexagon',
        name='Ketodeoxyoctonic acid'
    ),
    'Dha': dict(
        color='orange',
        shape='hexagon',
        name='3 Deoxy lyxo heptulosaric acid'
    ),
    'DDManHep': dict(
        color='pink',
        shape='hexagon',
        name='D glycero D manno Heptose'
    ),
    'MurNAc': dict(
        color='purple',
        shape='hexagon',
        name='N Acetylmuramic acid'
    ),
    'MurNGc': dict(
        color='cyan',
        shape='hexagon',
        name='N Glycolylmuramic acid'
    ),
    'Mur': dict(
        color='brown',
        shape='hexagon',
        name='Muramic acid'
    ),
    # Pentagon
    'Api': dict(
        color='blue',
        shape='pentagon',
        name='Apiose'
    ),
    'Fruc': dict(
        color='green',
        shape='pentagon',
        name='Fructose'
    ),
    'Tag': dict(
        color='yellow',
        shape='pentagon',
        name='Tagatose'
    ),
    'Sor': dict(
        color='orange',
        shape='pentagon',
        name='Sorbose'
    ),
    'Psi': dict(
        color='pink',
        shape='pentagon',
        name='Psicose'
    ),
    # Unknown
    'UNK': dict(
        color='white',
        shape='hexagon',
        name='Unknown'
    )
}

RESIDUE_CODES = {
    ### Filled sphere ###
    'Glc': dict(common=set('GLC MAL BGC'.split()),
                charmm=set('AGLC BGLC'.split()),
                glycam=set('0GA 0GB 1GA 1GB 2GA 2GB 3GA 3GB 4GA 4GB 6GA 6GB ZGA ZGB YGA YGB XGA XGB WGA WGB VGA VGB UGA UGB TGA TGB SGA SGB RGA RGB QGA QGB PGA PGB 0gA 0gB 1gA 1gB 2gA 2gB 3gA 3gB 4gA 4gB 6gA 6gB ZgA ZgB YgA YgB XgA XgB WgA WgB VgA VgB UgA UgB TgA TgB SgA SgB RgA RgB QgA QgB PgA PgB'.split()), ),
    'Man': dict(common=set('MAN BMA'.split()),
                charmm=set('AMAN BMAN'.split()),
                glycam=set('0MA 0MB 1MA 1MB 2MA 2MB 3MA 3MB 4MA 4MB 6MA 6MB ZMA ZMB YMA YMB XMA XMB WMA WMB VMA VMB UMA UMB TMA TMB SMA SMB RMA RMB QMA QMB PMA PMB 0mA 0mB 1mA 1mB 2mA 2mB 3mA 3mB 4mA 4mB 6mA 6mB ZmA ZmB YmA YmB XmA XmB WmA WmB VmA VmB UmA UmB TmA TmB SmA SmB RmA RmB QmA QmB PmA PmB'.split()), ),
    'Gal': dict(common=set('GAL GLA'.split()),
                charmm=set('AGAL BGAL'.split()),
                glycam=set('0LA 0LB 1LA 1LB 2LA 2LB 3LA 3LB 4LA 4LB 6LA 6LB ZLA ZLB YLA YLB XLA XLB WLA WLB VLA VLB ULA ULB TLA TLB SLA SLB RLA RLB QLA QLB PLA PLB 0lA 0lB 1lA 1lB 2lA 2lB 3lA 3lB 4lA 4lB 6lA 6lB ZlA ZlB YlA YlB XlA XlB WlA WlB VlA VlB UlA UlB TlA TlB SlA SlB RlA RlB QlA QlB PlA PlB'.split()), ),
    'Gul': dict(common=set('GUL GUP GL0'.split()),
                charmm=set('AGUL BGUL'.split()),
                glycam=set('0KA 0KB 1KA 1KB 2KA 2KB 3KA 3KB 4KA 4KB 6KA 6KB ZKA ZKB YKA YKB XKA XKB WKA WKB VKA VKB UKA UKB TKA TKB SKA SKB RKA RKB QKA QKB PKA PKB 0kA 0kB 1kA 1kB 2kA 2kB 3kA 3kB 4kA 4kB 6kA 6kB ZkA ZkB YkA YkB XkA XkB WkA WkB VkA VkB UkA UkB TkA TkB SkA SkB RkA RkB QkA QkB PkA PkB'.split()), ),
    'Alt': dict(common=set(['ALT']),
                charmm=set('AALT BALT'.split()),
                glycam=set('0EA 0EB 1EA 1EB 2EA 2EB 3EA 3EB 4EA 4EB 6EA 6EB ZEA ZEB YEA YEB XEA XEB WEA WEB VEA VEB UEA UEB TEA TEB SEA SEB REA REB QEA QEB PEA PEB 0eA 0eB 1eA 1eB 2eA 2eB 3eA 3eB 4eA 4eB 6eA 6eB ZeA ZeB YeA YeB XeA XeB WeA WeB VeA VeB UeA UeB TeA TeB SeA SeB ReA ReB QeA QeB PeA PeB'.split()), ),
    'All': dict(common=set('ALL WOO'.split()),
                charmm=set('AALL BALL'.split()),
                glycam=set('0NA 0NB 1NA 1NB 2NA 2NB 3NA 3NB 4NA 4NB 6NA 6NB ZNA ZNB YNA YNB XNA XNB WNA WNB VNA VNB UNA UNB TNA TNB SNA SNB RNA RNB QNA QNB PNA PNB 0nA 0nB 1nA 1nB 2nA 2nB 3nA 3nB 4nA 4nB 6nA 6nB ZnA ZnB YnA YnB XnA XnB WnA WnB VnA VnB UnA UnB TnA TnB SnA SnB RnA RnB QnA QnB PnA PnB'.split()), ),
    'Tal': dict(common=set(['TAL']),
                charmm=set('ATAL BTAL'.split()),
                glycam=set('0TA 0TB 1TA 1TB 2TA 2TB 3TA 3TB 4TA 4TB 6TA 6TB ZTA ZTB YTA YTB XTA XTB WTA WTB VTA VTB UTA UTB TTA TTB STA STB RTA RTB QTA QTB PTA PTB 0tA 0tB 1tA 1tB 2tA 2tB 3tA 3tB 4tA 4tB 6tA 6tB ZtA ZtB YtA YtB XtA XtB WtA WtB VtA VtB UtA UtB TtA TtB StA StB RtA RtB QtA QtB PtA PtB'.split()), ),
    'Ido': dict(common=set(['IDO']),
                charmm=set('AIDO BIDO'.split()),
                glycam=set(), ),
    ### Filled cube ###
    'GlcNAc': dict(common=set('NAG 4YS SGN BGLN NDG'.split()),
                   charmm=set('AGLCNA BGLCNA BGLCN0'.split()),
                   glycam=set('0YA 0YB 1YA 1YB 3YA 3YB 4YA 4YB 6YA 6YB WYA WYB VYA VYB UYA UYB QYA QYB 0yA 0yB 1yA 1yB 3yA 3yB 4yA 4yB 6yA 6yB WyA WyB VyA VyB UyA UyB QyA QyB XYY UYY VYY'.split()), ),
    'ManNAc': dict(common=set(),
                   charmm=set(),
                   glycam=set('0WA 0WB 1WA 1WB 3WA 3WB 4WA 4WB 6WA 6WB WWA WWB VWA VWB UWA UWB QWA QWB 0wA 0wB 1wA 1wB 3wA 3wB 4wA 4wB 6wA 6wB WwA WwB VwA VwB UwA UwB QwA QwB'.split()), ),
    'GalNAc': dict(common=set(['NGA']),
                   charmm=set('AGALNA BGALNA'.split()),
                   glycam=set('0VA 0VB 1VA 1VB 3VA 3VB 4VA 4VB 6VA 6VB WVA WVB VVA VVB UVA UVB QVA QVB 0vA 0vB 1vA 1vB 3vA 3vB 4vA 4vB 6vA 6vB WvA WvB VvA VvB UvA UvB QvA QvB'.split()), ),
    'GulNAc': dict(common=set(),
                   charmm=set(),
                   glycam=set(), ),
    'AltNAc': dict(common=set(),
                   charmm=set(),
                   glycam=set(), ),
    'AllNAc': dict(common=set(),
                   charmm=set(),
                   glycam=set(), ),
    'TalNAc': dict(common=set(),
                   charmm=set(),
                   glycam=set(), ),
    'IdoNAc': dict(common=set(),
                   charmm=set(),
                   glycam=set(), ),
    ### Crossed cube ###
    'GlcN': dict(common=set(['GCS']),
                 charmm=set(),
                 glycam=set('0YN 0Yn 0YNP 0YnP 0YS 0Ys 3YS 3Ys 4YS 4Ys 6YS 6Ys QYS QYs UYS UYs VYS VYs WYS WYs 0yS 0ys 3yS 3ys 4yS 4ys'.split())),  # Those ending in S are sulfated glucosamine, white\blue cube),
    'ManN': dict(common=set(),
                 charmm=set(),
                 glycam=set(), ),
    'GalN': dict(common=set(),
                 charmm=set(),
                 glycam=set(), ),
    'GulN': dict(common=set(),
                 charmm=set(),
                 glycam=set(), ),
    'AltN': dict(common=set(),
                 charmm=set(),
                 glycam=set(), ),
    'AllN': dict(common=set(),
                 charmm=set(),
                 glycam=set(), ),
    'TalN': dict(common=set(),
                 charmm=set(),
                 glycam=set(), ),
    'IdoN': dict(common=set(),
                 charmm=set(),
                 glycam=set(), ),
    # Divided diamond ###
    'GlcA': dict(common=set(['GCU']),
                 charmm=set('AGLCA BGLCA BGLCA0'.split()),
                 glycam=set('0ZA 0ZB 1ZA 1ZB 2ZA 2ZB 3ZA 3ZB 4ZA 4ZB ZZA ZZB YZA YZB WZA WZB TZA TZB 0zA 0zB 1zA 1zB 2zA 2zB 3zA 3zB 4zA 4zB ZzA ZzB YzA YzB WzA WzB TzA TzB 0ZBP'.split())),  # 0ZBP is protonated beta-D),
    'ManA': dict(common=set('MAV BEM'.split()),
                 charmm=set(),
                 glycam=set(), ),
    'GalA': dict(common=set(['ADA']),
                 charmm=set(),
                 glycam=set('0OA 0OB 1OA 1OB 2OA 2OB 3OA 3OB 4OA 4OB ZOA ZOB YOA YOB WOA WOB TOA TOB 0oA 0oB 1oA 1oB 2oA 2oB 3oA 3oB 4oA 4oB ZoA ZoB YoA YoB WoA WoB ToA ToB'.split()), ),
    'GulA': dict(common=set(['LGU']),
                 charmm=set(),
                 glycam=set(), ),
    'AltA': dict(common=set(),
                 charmm=set(),
                 glycam=set(), ),
    'AllA': dict(common=set(),
                 charmm=set(),
                 glycam=set(), ),
    'TalA': dict(common=set(),
                 charmm=set(),
                 glycam=set(), ),
    'IdoA': dict(common=set(['IDS']),
                 charmm=set('AIDOA BIDOA'.split()),
                 glycam=set('0UA 0UB 1UA 1UB 2UA 2UB 3UA 3UB 4UA 4UB ZUA ZUB YUA YUB WUA WUB TUA TUB 0uA 0uB 1uA 1uB 2uA 2uB 3uA 3uB 4uA 4uB ZuA ZuB YuA YuB WuA WuB TuA TuB YuAP'.split())),  # YuAP is protonated alpha-L
    ### Filled cone ###
    'Qui': dict(common=set(['QUI']),
                charmm=set(),
                glycam=set('0QA 0QB 1QA 1QB 2QA 2QB 3QA 3QB 4QA 4QB ZQA ZQB YQA YQB WQA WQB TQA TQB 0qA 0qB 1qA 1qB 2qA 2qB 3qA 3qB 4qA 4qB ZqA ZqB YqA YqB WqA WqB TqA TqB'.split()), ),
    'Rha': dict(common=set(['RAM']),
                charmm=set('ARHM BRHM'.split()),
                glycam=set('0HA 0HB 1HA 1HB 2HA 2HB 3HA 3HB 4HA 4HB ZHA ZHB YHA YHB WHA WHB THA THB 0hA 0hB 1hA 1hB 2hA 2hB 3hA 3hB 4hA 4hB ZhA ZhB YhA YhB WhA WhB ThA ThB'.split()), ),
    'x6dAlt': dict(common=set(),
                   charmm=set(),
                   glycam=set(), ),
    'x6dTal': dict(common=set(),
                   charmm=set(),
                   glycam=set(), ),
    'Fuc': dict(common=set('FUC FUL'.split()),
                charmm=set('AFUC BFUC'.split()),
                glycam=set('0FA 0FB 1FA 1FB 2FA 2FB 3FA 3FB 4FA 4FB ZFA ZFB YFA YFB WFA WFB TFA TFB 0fA 0fB 1fA 1fB 2fA 2fB 3fA 3fB 4fA 4fB ZfA ZfB YfA YfB WfA WfB TfA TfB'.split()), ),
    ### Divided cone ###
    'QuiNAc': dict(common=set(),
                   charmm=set(),
                   glycam=set(), ),
    'RhaNAc': dict(common=set(),
                   charmm=set(),
                   glycam=set(), ),
    'FucNAc': dict(common=set(),
                   charmm=set(),
                   glycam=set(), ),
    ### Flat rectangle ###
    'Oli': dict(common=set(['OLI']),
                charmm=set(),
                glycam=set(), ),
    'Tyv': dict(common=set(['TYV']),
                charmm=set(),
                glycam=set('0TV 0Tv 1TV 1Tv 2TV 2Tv 4TV 4Tv YTV YTv 0tV 0tv 1tV 1tv 2tV 2tv 4tV 4tv YtV Ytv'.split()), ),
    'Abe': dict(common=set(['ABE']),
                charmm=set(),
                glycam=set('0AE 2AE 4AE YGa 0AF 2AF 4AF YAF'.split()), ),
    'Par': dict(common=set(['PAR']),
                charmm=set(),
                glycam=set(), ),
    'Dig': dict(common=set(['DIG']),
                charmm=set(),
                glycam=set(), ),
    'Col': dict(common=set(['COL']),
                charmm=set(),
                glycam=set(), ),
    ### Filled star ###
    'Ara': dict(common=set('ARA AHR'.split()),
                charmm=set('AARB BARB'.split()),
                glycam=set('0AA 0AB 1AA 1AB 2AA 2AB 3AA 3AB 4AA 4AB ZAA ZAB YAA YAB WAA WAB TAA TAB 0AD 0AU 1AD 1AU 2AD 2AU 3AD 3AU 5AD 5AU ZAD ZAU 0aA 0aB 1aA 1aB 2aA 2aB 3aA 3aB 4aA 4aB ZaA ZaB YaA YaB WaA WaB TaA TaB 0aD 0aU 1aD 1aU 2aD 2aU 3aD 3aU 5aD 5aU ZaD ZaU'.split()), ),
    'Lyx': dict(common=set(['LYX']),
                charmm=set('ALYF BLYF'.split()),
                glycam=set('0DA 0DB 1DA 1DB 2DA 2DB 3DA 3DB 4DA 4DB ZDA ZDB YDA YDB WDA WDB TDA TDB 0DD 0DU 1DD 1DU 2DD 2DU 3DD 3DU 5DD 5DU ZDD ZDU 0dA 0dB 1dA 1dB 2dA 2dB 3dA 3dB 4dA 4dB ZdA ZdB YdA YdB WdA WdB TdA TdB 0dD 0dU 1dD 1dU 2dD 2dU 3dD 3dU 5dD 5dU ZdD ZdU'.split()), ),
    'Xyl': dict(common=set('XYL XYS LXC XYP'.split()),
                charmm=set('AXYL BXYL AXYF BXYF'.split()),
                glycam=set('0XA 0XB 1XA 1XB 2XA 2XB 3XA 3XB 4XA 4XB ZXA ZXB YXA YXB WXA WXB TXA TXB 0XD 0XU 1XD 1XU 2XD 2XU 3XD 3XU 5XD 5XU ZXD ZXU 0xA 0xB 1xA 1xB 2xA 2xB 3xA 3xB 4xA 4xB ZxA ZxB YxA YxB WxA WxB TxA TxB 0xD 0xU 1xD 1xU 2xD 2xU 3xD 3xU 5xD 5xU ZxD ZxU'.split()), ),
    'Rib': dict(common=set(['RIB']),
                charmm=set('ARIB BRIB'.split()),
                glycam=set('0RA 0RB 1RA 1RB 2RA 2RB 3RA 3RB 4RA 4RB ZRA ZRB YRA YRB WRA WRB TRA TRB 0RD 0RU 1RD 1RU 2RD 2RU 3RD 3RU 5RD 5RU ZRD ZRU 0rA 0rB 1rA 1rB 2rA 2rB 3rA 3rB 4rA 4rB ZrA ZrB YrA YrB WrA WrB TrA TrB 0rD 0rU 1rD 1rU 2rD 2rU 3rD 3rU 5rD 5rU ZrD ZrU'.split()), ),
    ### Filled diamond ###
    'Kdn': dict(common=set(['KDN']),
                charmm=set(),
                glycam=set(), ),
    # Neu5Ac
    'Neu5Ac': dict(common=set(['SIA']),  # Careful, SIA could refer to Ido in the future
                   charmm=set('ANE5AC BNE5AC'.split()),
                   glycam=set('0SA 0SB 4SA 4SB 7SA 7SB 8SA 8SB 9SA 9SB ASA ASB BSA BSB CSA CSB DSA DSB ESA ESB FSA FSB GSA GSB HSA HSB ISA ISB JSA JSB KSA KSB 0sA 0sB 4sA 4sB 7sA 7sB 8sA 8sB 9sA 9sB AsA AsB BsA BsB CsA CsB DsA DsB EsA EsB FsA FsB GsA GsB HsA HsB IsA IsB JsA JsB KsA KsB'.split()), ),
    # Neu5Gc
    'Neu5Gc': dict(common=set(),
                   charmm=set(),
                   glycam=set('0GL 4GL 7GL 8GL 9GL CGL DGL EGL FGL GGL HGL IGL JGL KGL 0gL 4gL 7gL 8gL 9gL AgL BgL CgL DgL EgL FgL GgL HgL IgL JgL KgL'.split()), ),
    'Neu': dict(common=set(['NEU']),
                charmm=set(),
                glycam=set(), ),
    ### Flat hexagon ###
    'Bac': dict(common=set(['BAC']),
                charmm=set(),
                glycam=set('0BC 3BC 0bC 3bC'.split()), ),
    'LDManHep': dict(common=set(['GMH']),
                     charmm=set(),
                     glycam=set(), ),
    'Kdo': dict(common=set(['KDO']),
                charmm=set(),
                glycam=set(), ),
    'Dha': dict(common=set(['DHA']),
                charmm=set(),
                glycam=set(), ),
    'DDManHep': dict(common=set(),
                     charmm=set(),
                     glycam=set(), ),
    'MurNAc': dict(common=set(),
                   charmm=set(),
                   glycam=set(), ),
    'MurNGc': dict(common=set(),
                   charmm=set(),
                   glycam=set(), ),
    'Mur': dict(common=set(['MUR']),
                charmm=set(),
                glycam=set(), ),
    ### Flat pentagon ###
    'Api': dict(common=set(['API']),
                charmm=set(),
                glycam=set(), ),
    'Fruc': dict(common=set(['FRU']),
                 charmm=set('AFRU BFRU'.split()),
                 glycam=set('0CA 0CB 1CA 1CB 2CA 2CB 3CA 3CB 4CA 4CB 5CA 5CB WCA WCB 0CD 0CU 1CD 1CU 2CD 2CU 3CD 3CU 4CD 4CU 6CD 6CU WCD WCU VCD VCU UCD UCU QCD QCU 0cA 0cB 1cA 1cB 2cA 2cB 3cA 3cB 4cA 4cB 5cA 5cB WcA WcB 0cD 0cU 1cD 1cU 2cD 2cU 3cD 3cU 4cD 4cU 6cD 6cU WcD WcU VcD VcU UcD UcU QcD QcU'.split()), ),
    'Tag': dict(common=set(['TAG']),
                charmm=set(),
                glycam=set('0JA 0JB 1JA 1JB 2JA 2JB 3JA 3JB 4JA 4JB 5JA 5JB WJA WJB 0JD 0JU 1JD 1JU 2JD 2JU 3JD 3JU 4JD 4JU 6JD 6JU WJD WJU VJD VJU UJD UJU QJD QJU 0jA 0jB 1jA 1jB 2jA 2jB 3jA 3jB 4jA 4jB 5jA 5jB WjA WjB 0jD 0jU 1jD 1jU 2jD 2jU 3jD 3jU 4jD 4jU 6jD 6jU WjD WjU VjD VjU UjD UjU QjD QjU'.split()), ),
    'Sor': dict(common=set(['SOR']),
                charmm=set(),
                glycam=set('0BA 0BB 1BA 1BB 2BA 2BB 3BA 3BB 4BA 4BB 5BA 5BB WBA WBB 0BD 0BU 1BD 1BU 2BD 2BU 3BD 3BU 4BD 4BU 6BD 6BU WBD WBU VBD VBU UBD UBU QBD QBU 0bA 0bB 1bA 1bB 2bA 2bB 3bA 3bB 4bA 4bB 5bA 5bB WbA WbB 0bD 0bU 1bD 1bU 2bD 2bU 3bD 3bU 4bD 4bU 6bD 6bU WbD WbU VbD VbU UbD UbU QbD QbU'.split()), ),
    'Psi': dict(common=set(['PSI']),
                charmm=set(),
                glycam=set('0PA 0PB 1PA 1PB 2PA 2PB 3PA 3PB 4PA 4PB 5PA 5PB WPA WPB 0PD 0PU 1PD 1PU 2PD 2PU 3PD 3PU 4PD 4PU 6PD 6PU WPD WPU VPD VPU UPD UPU QPD QPU 0pA 0pB 1pA 1pB 2pA 2pB 3pA 3pB 4pA 4pB 5pA 5pB WpA WpB 0pD 0pU 1pD 1pU 2pD 2pU 3pD 3pU 4pD 4pU 6pD 6pU WpD WpU VpD VpU UpD UpU QpD QpU'.split()), ),

    # Glycam residues not included because they are terminals, substitutions, glycoprotein residues, or general uronates: (keep this list for checking purposes)
    # ROH OME TBT NLN OLS OLT ZOLS ZOLT SO3 MEX ACX CA2 045 245

}

REVERSE_RESIDUE_CODES = {}
for name, data in RESIDUE_CODES.items():
    for _, codes in data.items():
        for code in codes:
            REVERSE_RESIDUE_CODES[code] = name