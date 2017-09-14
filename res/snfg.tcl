# Load the 3D-SNFG script

################################################################################
# 3D-SNFG.tcl (version 1)
# Written by David F. Thieker and Jodi A. Hadden 
# See http://glycam.org/3d-snfg for full documentation.
# 
# Please cite:
# 3D Implementation of the Symbol Nomenclature for Graphical Representation of Glycans
# D.F. Thieker, J.A. Hadden, K. Schulten, and R.J. Woods
# Glycobiology, 2016
#
# Usage in .vmdrc or TkConsole:
# $ source ./3D-SNFG.tcl
# Print information on commands:
# $ snfg-help
#
# Default keyboard shortcuts:
# g: Enable 3D-SNFG drawing of full size shapes
# b: Enable 3D-SNFG drawing of full size shapes and label the reducing terminus
# i: Enable 3D-SNFG drawing of icon size shapes
# d: Disable 3D-SNFG drawing 
################################################################################

# SNFG variables
namespace eval SNFG {

	set size 4.0 ; # Let full size be default, reducing terminal off
	set cylinder_radius 0.5
	set cylinder_redfac 0
	set sphere_redfac 0

	variable carbmol "empty"
	variable ROH_att "empty"
        
	set sphere_size [expr $size*0.5]
        set cube_size [expr $size*0.806]
        set diamond_size [expr $size*1.3]
        set cone_size $size
        set rectangle_size $size
        set star_size $size
        set hexagon_size [expr $size*1.15]
        set pentagon_size $size

	set residues {}
	set p6list {}
	set geom_center_list {}
	set geom_center_att_list {}
	set shapelist {}
        set sizelist {}
        set color1list {}
        set color2list {}
	set shiftbool {}

	### Filled sphere ###################################################################################################### 
	# Glc
	set Glc_common [list GLC MAL BGC]
	set Glc_charmm [list AGLC BGLC]
	set Glc_glycam [list 0GA 0GB 1GA 1GB 2GA 2GB 3GA 3GB 4GA 4GB 6GA 6GB ZGA ZGB YGA YGB XGA XGB WGA WGB VGA VGB UGA UGB TGA TGB SGA SGB RGA RGB QGA QGB PGA PGB 0gA 0gB 1gA 1gB 2gA 2gB 3gA 3gB 4gA 4gB 6gA 6gB ZgA ZgB YgA YgB XgA XgB WgA WgB VgA VgB UgA UgB TgA TgB SgA SgB RgA RgB QgA QgB PgA PgB] 
	# Man
	set Man_common [list MAN BMA] 
	set Man_charmm [list AMAN BMAN]
	set Man_glycam [list 0MA 0MB 1MA 1MB 2MA 2MB 3MA 3MB 4MA 4MB 6MA 6MB ZMA ZMB YMA YMB XMA XMB WMA WMB VMA VMB UMA UMB TMA TMB SMA SMB RMA RMB QMA QMB PMA PMB 0mA 0mB 1mA 1mB 2mA 2mB 3mA 3mB 4mA 4mB 6mA 6mB ZmA ZmB YmA YmB XmA XmB WmA WmB VmA VmB UmA UmB TmA TmB SmA SmB RmA RmB QmA QmB PmA PmB]
	# Gal
	set Gal_common [list GAL GLA]
	set Gal_charmm [list AGAL BGAL]
	set Gal_glycam [list 0LA 0LB 1LA 1LB 2LA 2LB 3LA 3LB 4LA 4LB 6LA 6LB ZLA ZLB YLA YLB XLA XLB WLA WLB VLA VLB ULA ULB TLA TLB SLA SLB RLA RLB QLA QLB PLA PLB 0lA 0lB 1lA 1lB 2lA 2lB 3lA 3lB 4lA 4lB 6lA 6lB ZlA ZlB YlA YlB XlA XlB WlA WlB VlA VlB UlA UlB TlA TlB SlA SlB RlA RlB QlA QlB PlA PlB] 
	# Gul
	set Gul_common [list GUL GUP GL0]
	set Gul_charmm [list AGUL BGUL]
	set Gul_glycam [list 0KA 0KB 1KA 1KB 2KA 2KB 3KA 3KB 4KA 4KB 6KA 6KB ZKA ZKB YKA YKB XKA XKB WKA WKB VKA VKB UKA UKB TKA TKB SKA SKB RKA RKB QKA QKB PKA PKB 0kA 0kB 1kA 1kB 2kA 2kB 3kA 3kB 4kA 4kB 6kA 6kB ZkA ZkB YkA YkB XkA XkB WkA WkB VkA VkB UkA UkB TkA TkB SkA SkB RkA RkB QkA QkB PkA PkB] 
	# Alt
	set Alt_common [list ALT]
	set Alt_charmm [list AALT BALT]
	set Alt_glycam [list 0EA 0EB 1EA 1EB 2EA 2EB 3EA 3EB 4EA 4EB 6EA 6EB ZEA ZEB YEA YEB XEA XEB WEA WEB VEA VEB UEA UEB TEA TEB SEA SEB REA REB QEA QEB PEA PEB 0eA 0eB 1eA 1eB 2eA 2eB 3eA 3eB 4eA 4eB 6eA 6eB ZeA ZeB YeA YeB XeA XeB WeA WeB VeA VeB UeA UeB TeA TeB SeA SeB ReA ReB QeA QeB PeA PeB] 
	# All
	set All_common [list ALL WOO]
	set All_charmm [list AALL BALL]
	set All_glycam [list 0NA 0NB 1NA 1NB 2NA 2NB 3NA 3NB 4NA 4NB 6NA 6NB ZNA ZNB YNA YNB XNA XNB WNA WNB VNA VNB UNA UNB TNA TNB SNA SNB RNA RNB QNA QNB PNA PNB 0nA 0nB 1nA 1nB 2nA 2nB 3nA 3nB 4nA 4nB 6nA 6nB ZnA ZnB YnA YnB XnA XnB WnA WnB VnA VnB UnA UnB TnA TnB SnA SnB RnA RnB QnA QnB PnA PnB]
	# Tal
	set Tal_common [list TAL]
	set Tal_charmm [list ATAL BTAL]
	set Tal_glycam [list 0TA 0TB 1TA 1TB 2TA 2TB 3TA 3TB 4TA 4TB 6TA 6TB ZTA ZTB YTA YTB XTA XTB WTA WTB VTA VTB UTA UTB TTA TTB STA STB RTA RTB QTA QTB PTA PTB 0tA 0tB 1tA 1tB 2tA 2tB 3tA 3tB 4tA 4tB 6tA 6tB ZtA ZtB YtA YtB XtA XtB WtA WtB VtA VtB UtA UtB TtA TtB StA StB RtA RtB QtA QtB PtA PtB] 
	# Ido
	set Ido_common [list IDO]
	set Ido_charmm [list AIDO BIDO]
	set Ido_glycam [list ] 
	### Filled cube ######################################################################################################
	# GlcNAc
	set GlcNAc_common [list NAG 4YS SGN BGLN NDG]
	set GlcNAc_charmm [list AGLCNA BGLCNA BGLCN0]
	set GlcNAc_glycam [list 0YA 0YB 1YA 1YB 3YA 3YB 4YA 4YB 6YA 6YB WYA WYB VYA VYB UYA UYB QYA QYB 0yA 0yB 1yA 1yB 3yA 3yB 4yA 4yB 6yA 6yB WyA WyB VyA VyB UyA UyB QyA QyB XYY UYY VYY]
	# ManNAc
	set ManNAc_common [list ]
	set ManNAc_charmm [list ]
	set ManNAc_glycam [list 0WA 0WB 1WA 1WB 3WA 3WB 4WA 4WB 6WA 6WB WWA WWB VWA VWB UWA UWB QWA QWB 0wA 0wB 1wA 1wB 3wA 3wB 4wA 4wB 6wA 6wB WwA WwB VwA VwB UwA UwB QwA QwB]
	# GalNAc
	set GalNAc_common [list NGA]
	set GalNAc_charmm [list AGALNA BGALNA]
	set GalNAc_glycam [list 0VA 0VB 1VA 1VB 3VA 3VB 4VA 4VB 6VA 6VB WVA WVB VVA VVB UVA UVB QVA QVB 0vA 0vB 1vA 1vB 3vA 3vB 4vA 4vB 6vA 6vB WvA WvB VvA VvB UvA UvB QvA QvB]
	# GulNAc
	set GulNAc_common [list ]
	set GulNAc_charmm [list ]
	set GulNAc_glycam [list ]
	# AltNAc
	set AltNAc_common [list ]
	set AltNAc_charmm [list ]
	set AltNAc_glycam [list ]
	# AllNAc
	set AllNAc_common [list ]
	set AllNAc_charmm [list ]
	set AllNAc_glycam [list ]
	# TalNAc
	set TalNAc_common [list ]
	set TalNAc_charmm [list ]
	set TalNAc_glycam [list ] 
	# IdoNAc
	set IdoNAc_common [list ]
	set IdoNAc_charmm [list ]
	set IdoNAc_glycam [list ] 
	### Crossed cube ######################################################################################################
	# GlcN
	set GlcN_common [list GCS]
	set GlcN_charmm [list ]
	set GlcN_glycam [list 0YN 0Yn 0YNP 0YnP 0YS 0Ys 3YS 3Ys 4YS 4Ys 6YS 6Ys QYS QYs UYS UYs VYS VYs WYS WYs 0yS 0ys 3yS 3ys 4yS 4ys] ; # Those ending in S are sulfated glucosamine, white\blue cube
	# ManN
	set ManN_common [list ]
	set ManN_charmm [list ]
	set ManN_glycam [list ]
	# GalN
	set GalN_common [list ]
	set GalN_charmm [list ]
	set GalN_glycam [list ]
	# GulN
	set GulN_common [list ]
	set GulN_charmm [list ]
	set GulN_glycam [list ]
	# AltN
	set AltN_common [list ]
	set AltN_charmm [list ]
	set AltN_glycam [list ]
	# AllN
	set AllN_common [list ]
	set AllN_charmm [list ]
	set AllN_glycam [list ]
	# TalN
	set TalN_common [list ]
	set TalN_charmm [list ]
	set TalN_glycam [list ] 
	# IdoN
	set IdoN_common [list ]
	set IdoN_charmm [list ]
	set IdoN_glycam [list ] 
	# Divided diamond ######################################################################################################
	# GlcA
	set GlcA_common [list GCU]
	set GlcA_charmm [list AGLCA BGLCA BGLCA0]
	set GlcA_glycam [list 0ZA 0ZB 1ZA 1ZB 2ZA 2ZB 3ZA 3ZB 4ZA 4ZB ZZA ZZB YZA YZB WZA WZB TZA TZB 0zA 0zB 1zA 1zB 2zA 2zB 3zA 3zB 4zA 4zB ZzA ZzB YzA YzB WzA WzB TzA TzB 0ZBP] ; # 0ZBP is protonated beta-D
	# ManA 
	set ManA_common [list MAV BEM]
	set ManA_charmm [list ]
	set ManA_glycam [list ] 
	# GalA
	set GalA_common [list ADA]
	set GalA_charmm [list ]
	set GalA_glycam [list 0OA 0OB 1OA 1OB 2OA 2OB 3OA 3OB 4OA 4OB ZOA ZOB YOA YOB WOA WOB TOA TOB 0oA 0oB 1oA 1oB 2oA 2oB 3oA 3oB 4oA 4oB ZoA ZoB YoA YoB WoA WoB ToA ToB] 
	# GulA
	set GulA_common [list LGU]
	set GulA_charmm [list ]
	set GulA_glycam [list ] 
	# AltA
	set AltA_common [list ]
	set AltA_charmm [list ]
	set AltA_glycam [list ] 
	# AllA
	set AllA_common [list ]
	set AllA_charmm [list ]
	set AllA_glycam [list ] 
	# TalA
	set TalA_common [list ]
	set TalA_charmm [list ]
	set TalA_glycam [list ] 
	# IdoA
	set IdoA_common [list IDS]
	set IdoA_charmm [list AIDOA BIDOA]
	set IdoA_glycam [list 0UA 0UB 1UA 1UB 2UA 2UB 3UA 3UB 4UA 4UB ZUA ZUB YUA YUB WUA WUB TUA TUB 0uA 0uB 1uA 1uB 2uA 2uB 3uA 3uB 4uA 4uB ZuA ZuB YuA YuB WuA WuB TuA TuB YuAP] ; # YuAP is protonated alpha-L 
	### Filled cone ######################################################################################################
	# Qui
	set Qui_common [list QUI]
	set Qui_charmm [list ]
	set Qui_glycam [list 0QA 0QB 1QA 1QB 2QA 2QB 3QA 3QB 4QA 4QB ZQA ZQB YQA YQB WQA WQB TQA TQB 0qA 0qB 1qA 1qB 2qA 2qB 3qA 3qB 4qA 4qB ZqA ZqB YqA YqB WqA WqB TqA TqB]
	# Rha
	set Rha_common [list RAM]
	set Rha_charmm [list ARHM BRHM]
	set Rha_glycam [list 0HA 0HB 1HA 1HB 2HA 2HB 3HA 3HB 4HA 4HB ZHA ZHB YHA YHB WHA WHB THA THB 0hA 0hB 1hA 1hB 2hA 2hB 3hA 3hB 4hA 4hB ZhA ZhB YhA YhB WhA WhB ThA ThB] 
	# x6dAlt
	set x6dAlt_common [list ]
	set x6dAlt_charmm [list ]
	set x6dAlt_glycam [list ] 
	# x6dTal
	set x6dTal_common [list ]
	set x6dTal_charmm [list ]
	set x6dTal_glycam [list ]
	# Fuc
	set Fuc_common [list FUC FUL]
	set Fuc_charmm [list AFUC BFUC]
	set Fuc_glycam [list 0FA 0FB 1FA 1FB 2FA 2FB 3FA 3FB 4FA 4FB ZFA ZFB YFA YFB WFA WFB TFA TFB 0fA 0fB 1fA 1fB 2fA 2fB 3fA 3fB 4fA 4fB ZfA ZfB YfA YfB WfA WfB TfA TfB] 
	### Divided cone ######################################################################################################
	# QuiNAc
	set QuiNAc_common [list ]
	set QuiNAc_charmm [list ]
	set QuiNAc_glycam [list ] 
	# RhaNAc
	set RhaNAc_common [list ]
	set RhaNAc_charmm [list ]
	set RhaNAc_glycam [list ]
	# FucNAc
	set FucNAc_common [list ]
	set FucNAc_charmm [list ]
	set FucNAc_glycam [list ] 
	### Flat rectangle ######################################################################################################
	# Oli
	set Oli_common [list OLI]
	set Oli_charmm [list ]
	set Oli_glycam [list ] 
	# Tyv
	set Tyv_common [list TYV]
	set Tyv_charmm [list ]
	set Tyv_glycam [list 0TV 0Tv 1TV 1Tv 2TV 2Tv 4TV 4Tv YTV YTv 0tV 0tv 1tV 1tv 2tV 2tv 4tV 4tv YtV Ytv] 
	# Abe
	set Abe_common [list ABE]
	set Abe_charmm [list ]
	set Abe_glycam [list 0AE 2AE 4AE YGa 0AF 2AF 4AF YAF]
	# Par
	set Par_common [list PAR]
	set Par_charmm [list ]
	set Par_glycam [list ]
	# Dig
	set Dig_common [list DIG]
	set Dig_charmm [list ]
	set Dig_glycam [list ] 
	# Col
	set Col_common [list COL]
	set Col_charmm [list ]
	set Col_glycam [list ] 
	### Filled star ######################################################################################################
	# Ara
	set Ara_common [list ARA AHR]
	set Ara_charmm [list AARB BARB]
	set Ara_glycam [list 0AA 0AB 1AA 1AB 2AA 2AB 3AA 3AB 4AA 4AB ZAA ZAB YAA YAB WAA WAB TAA TAB 0AD 0AU 1AD 1AU 2AD 2AU 3AD 3AU 5AD 5AU ZAD ZAU 0aA 0aB 1aA 1aB 2aA 2aB 3aA 3aB 4aA 4aB ZaA ZaB YaA YaB WaA WaB TaA TaB 0aD 0aU 1aD 1aU 2aD 2aU 3aD 3aU 5aD 5aU ZaD ZaU]
	# Lyx
	set Lyx_common [list LYX]
	set Lyx_charmm [list ALYF BLYF]
	set Lyx_glycam [list 0DA 0DB 1DA 1DB 2DA 2DB 3DA 3DB 4DA 4DB ZDA ZDB YDA YDB WDA WDB TDA TDB 0DD 0DU 1DD 1DU 2DD 2DU 3DD 3DU 5DD 5DU ZDD ZDU 0dA 0dB 1dA 1dB 2dA 2dB 3dA 3dB 4dA 4dB ZdA ZdB YdA YdB WdA WdB TdA TdB 0dD 0dU 1dD 1dU 2dD 2dU 3dD 3dU 5dD 5dU ZdD ZdU] 
	# Xyl
	set Xyl_common [list XYL XYS LXC XYP]
	set Xyl_charmm [list AXYL BXYL AXYF BXYF]
	set Xyl_glycam [list 0XA 0XB 1XA 1XB 2XA 2XB 3XA 3XB 4XA 4XB ZXA ZXB YXA YXB WXA WXB TXA TXB 0XD 0XU 1XD 1XU 2XD 2XU 3XD 3XU 5XD 5XU ZXD ZXU 0xA 0xB 1xA 1xB 2xA 2xB 3xA 3xB 4xA 4xB ZxA ZxB YxA YxB WxA WxB TxA TxB 0xD 0xU 1xD 1xU 2xD 2xU 3xD 3xU 5xD 5xU ZxD ZxU] 
	# Rib
	set Rib_common [list RIB]
	set Rib_charmm [list ARIB BRIB]
	set Rib_glycam [list 0RA 0RB 1RA 1RB 2RA 2RB 3RA 3RB 4RA 4RB ZRA ZRB YRA YRB WRA WRB TRA TRB 0RD 0RU 1RD 1RU 2RD 2RU 3RD 3RU 5RD 5RU ZRD ZRU 0rA 0rB 1rA 1rB 2rA 2rB 3rA 3rB 4rA 4rB ZrA ZrB YrA YrB WrA WrB TrA TrB 0rD 0rU 1rD 1rU 2rD 2rU 3rD 3rU 5rD 5rU ZrD ZrU]
	### Filled diamond ######################################################################################################
	# Kdn
	set Kdn_common [list KDN]
	set Kdn_charmm [list ]
	set Kdn_glycam [list ]
	# Neu5Ac
	set Neu5Ac_common [list SIA] ; # Careful, SIA could refer to Ido in the future 
	set Neu5Ac_charmm [list ANE5AC BNE5AC]
	set Neu5Ac_glycam [list 0SA 0SB 4SA 4SB 7SA 7SB 8SA 8SB 9SA 9SB ASA ASB BSA BSB CSA CSB DSA DSB ESA ESB FSA FSB GSA GSB HSA HSB ISA ISB JSA JSB KSA KSB 0sA 0sB 4sA 4sB 7sA 7sB 8sA 8sB 9sA 9sB AsA AsB BsA BsB CsA CsB DsA DsB EsA EsB FsA FsB GsA GsB HsA HsB IsA IsB JsA JsB KsA KsB]
	# Neu5Gc
	set Neu5Gc_common [list ]
	set Neu5Gc_charmm [list ]
	set Neu5Gc_glycam [list 0GL 4GL 7GL 8GL 9GL CGL DGL EGL FGL GGL HGL IGL JGL KGL 0gL 4gL 7gL 8gL 9gL AgL BgL CgL DgL EgL FgL GgL HgL IgL JgL KgL]
	# Neu
	set Neu_common [list NEU]
	set Neu_charmm [list ]
	set Neu_glycam [list ] 
	### Flat hexagon ######################################################################################################
	# Bac
	set Bac_common [list BAC]
	set Bac_charmm [list ]
	set Bac_glycam [list 0BC 3BC 0bC 3bC]
	# LDManHep
	set LDManHep_common [list GMH]
	set LDManHep_charmm [list ]
	set LDManHep_glycam [list ]
	# Kdo
	set Kdo_common [list KDO]
	set Kdo_charmm [list ]
	set Kdo_glycam [list ]
	# Dha
	set Dha_common [list DHA]
	set Dha_charmm [list ]
	set Dha_glycam [list ] 
	# DDManHep
	set DDManHep_common [list ]
	set DDManHep_charmm [list ]
	set DDManHep_glycam [list ] 
	# MurNAc
	set MurNAc_common [list ]
	set MurNAc_charmm [list ]
	set MurNAc_glycam [list ]
	# MurNGc
	set MurNGc_common [list ]
	set MurNGc_charmm [list ]
	set MurNGc_glycam [list ] 
	# Mur
	set Mur_common [list MUR]
	set Mur_charmm [list ]
	set Mur_glycam [list ] 
	### Flat pentagon ######################################################################################################
	# Api
	set Api_common [list API]
	set Api_charmm [list ]
	set Api_glycam [list ] 
	# Fruc
	set Fruc_common [list FRU]
	set Fruc_charmm [list AFRU BFRU]
	set Fruc_glycam [list 0CA 0CB 1CA 1CB 2CA 2CB 3CA 3CB 4CA 4CB 5CA 5CB WCA WCB 0CD 0CU 1CD 1CU 2CD 2CU 3CD 3CU 4CD 4CU 6CD 6CU WCD WCU VCD VCU UCD UCU QCD QCU 0cA 0cB 1cA 1cB 2cA 2cB 3cA 3cB 4cA 4cB 5cA 5cB WcA WcB 0cD 0cU 1cD 1cU 2cD 2cU 3cD 3cU 4cD 4cU 6cD 6cU WcD WcU VcD VcU UcD UcU QcD QcU] 
	# Tag
	set Tag_common [list TAG]
	set Tag_charmm [list ]
	set Tag_glycam [list 0JA 0JB 1JA 1JB 2JA 2JB 3JA 3JB 4JA 4JB 5JA 5JB WJA WJB 0JD 0JU 1JD 1JU 2JD 2JU 3JD 3JU 4JD 4JU 6JD 6JU WJD WJU VJD VJU UJD UJU QJD QJU 0jA 0jB 1jA 1jB 2jA 2jB 3jA 3jB 4jA 4jB 5jA 5jB WjA WjB 0jD 0jU 1jD 1jU 2jD 2jU 3jD 3jU 4jD 4jU 6jD 6jU WjD WjU VjD VjU UjD UjU QjD QjU] 
	# Sor
	set Sor_common [list SOR]
	set Sor_charmm [list ]
	set Sor_glycam [list 0BA 0BB 1BA 1BB 2BA 2BB 3BA 3BB 4BA 4BB 5BA 5BB WBA WBB 0BD 0BU 1BD 1BU 2BD 2BU 3BD 3BU 4BD 4BU 6BD 6BU WBD WBU VBD VBU UBD UBU QBD QBU 0bA 0bB 1bA 1bB 2bA 2bB 3bA 3bB 4bA 4bB 5bA 5bB WbA WbB 0bD 0bU 1bD 1bU 2bD 2bU 3bD 3bU 4bD 4bU 6bD 6bU WbD WbU VbD VbU UbD UbU QbD QbU]
	# Psi
	set Psi_common [list PSI]
	set Psi_charmm [list ]
	set Psi_glycam [list 0PA 0PB 1PA 1PB 2PA 2PB 3PA 3PB 4PA 4PB 5PA 5PB WPA WPB 0PD 0PU 1PD 1PU 2PD 2PU 3PD 3PU 4PD 4PU 6PD 6PU WPD WPU VPD VPU UPD UPU QPD QPU 0pA 0pB 1pA 1pB 2pA 2pB 3pA 3pB 4pA 4pB 5pA 5pB WpA WpB 0pD 0pU 1pD 1pU 2pD 2pU 3pD 3pU 4pD 4pU 6pD 6pU WpD WpU VpD VpU UpD UpU QpD QpU] 

	# Glycam residues not included because they are terminals, substitutions, glycoprotein residues, or general uronates: (keep this list for checking purposes)
	# ROH OME TBT NLN OLS OLT ZOLS ZOLT SO3 MEX ACX CA2 045 245 
}

# Enable SNFG
proc snfg-enable { rep } { 

	draw delete all
	snfg-disable

	set topsel [atomselect top "index 0"]
	set topmol [$topsel molid]
	set ::SNFG::carbmol $topmol
	$topsel delete

	set usage ""

	if {$rep == "icon"} {
		set ::SNFG::size 1.5
		set ::SNFG::cylinder_radius 0
		set ::SNFG::cylinder_redfac 0
		set ::SNFG::sphere_redfac 0
	} elseif {$rep == "full"} {
		set ::SNFG::size 4.0
		set ::SNFG::cylinder_radius 0.5
                set ::SNFG::cylinder_redfac 0
                set ::SNFG::sphere_redfac 0
	} elseif {$rep == "fullred"} {
		set ::SNFG::size 4.0
		set ::SNFG::cylinder_radius 0.5
		set ::SNFG::cylinder_redfac 0.4
		set ::SNFG::sphere_redfac 0.25
	} else {
		set usage "\nUsage: snfg-enable icon/full/fullred\nSee output of snfg-help for more information."
	}

        set ::SNFG::sphere_size [expr $::SNFG::size*0.5]
        set ::SNFG::cube_size [expr $::SNFG::size*0.806]
        set ::SNFG::diamond_size [expr $SNFG::size*1.3]
        set ::SNFG::cone_size $::SNFG::size
        set ::SNFG::rectangle_size $::SNFG::size
        set ::SNFG::star_size $::SNFG::size
        set ::SNFG::hexagon_size [expr $::SNFG::size*1.15]
        set ::SNFG::pentagon_size $::SNFG::size

        set ::SNFG::residues {}
	set ::SNFG::p6list {}
	set ::SNFG::geom_center_list {}
	set ::SNFG::geom_center_att_list {}
	set ::SNFG::shapelist {}
	set ::SNFG::sizelist {}
	set ::SNFG::color1list {}
	set ::SNFG::color2list {}
	set ::SNFG::shiftbool {}

	puts "Glycan residues detected:\n"
	snfg-detect

	puts "$usage"

        global vmd_frame
        trace variable vmd_frame($::SNFG::carbmol) w snfg-drawcounter
	snfg-update $vmd_frame($::SNFG::carbmol)
	snfg-draw
}

# Disable SNFG
proc snfg-disable {} {

	draw delete all

	global vmd_frame
	trace vdelete vmd_frame($::SNFG::carbmol) w snfg-drawcounter
}

# Call SNFG scripts to draw shapes
proc snfg-drawcounter { name element op } {

	draw delete all

        set ::SNFG::p6list {}
        set ::SNFG::geom_center_list {}
        set ::SNFG::geom_center_att_list {}

	global vmd_frame
	snfg-update $vmd_frame($::SNFG::carbmol)
	snfg-draw
}

# Sphere
proc linked_carb.oriented.sphere {p6 size geom_center geom_center_att color1 color2} {
	draw color $color1
	draw sphere $geom_center radius $size resolution 36
}

# Cube
proc linked_carb.oriented.cube {p6 size geom_center geom_center_att color1 color2} {
    # The objective is to orient the shapes so that they face the neighboring residue, connected at C1. 
	# This is accomplished by calculating the equation for the line that connects the geometric centers of the
	# target residue (where the shape will be placed) and the neighboring residue (which is attached at the C1 atom). 
	# If we consider the geometric center of the target residue to be point A, the center of the neighboring 
	# residue to be point B, and the origin to be point O, then vector_AB=vector_OB - vector_OA. 
    # Knowing vector AB allows us to put new points along the line; however, we want the shapes to be of a 
	# defined size. In order to adjust the size properly, the distance between geometric centers is determined, 
	# scaled to match the desired size, and then added/subtracted from the geometric center of the target sugar.

        set vec_AB [vecsub $geom_center_att $geom_center]
                
	# Resize the shape. $size refers to the total size, $half_length refers to the distance required create 
	# points on either side of the geometric center.
        set half_length [expr $size/2]

	# Vec_AB is currently too large, we want it to be adjusted so that the distance is equal to the offset 
	# that will be used to place the ponits around the geometric center. The equation asks the question, 
	# what factor should be multiplied times the distance in order to prodce $half-length?
        set adjustment [expr $half_length/[vecdist $geom_center $geom_center_att]]
                
	# Adjust vector_AB by the amount determined in both the forward and reverse directions
        set adj_vec_AB_1 [vecscale $adjustment $vec_AB]
        set adj_vec_AB_2 [vecscale -$adjustment $vec_AB]

	# Add two points along the line connecting the residues in the forward and reverse direction
        set x1 [vecadd $adj_vec_AB_1 $geom_center]
        set x2 [vecadd $adj_vec_AB_2 $geom_center]

	# perp_1 represents a point perpendicular to the previously created two
	set perp_1 [vecnorm [veccross [vecsub $x1 $x2] [vecsub $x2 $p6]]]
        set perp1 [vecscale $perp_1 $half_length]
        set perp2 [vecscale $perp_1 -$half_length]
	        
	# Each 'o' represents a point on the box (o stands for original points, which are based on the two that 
	# lie along the line connecting the two residues)
        set o1 [vecadd $perp1 $x1]
        set o2 [vecadd $perp1 $x2]
        set o3 [vecadd $perp2 $x1]
        set o4 [vecadd $perp2 $x2]

	# This creates 8 points (the corners of the box) based upon the coordinates of o1-o4
        set perp_for [vecscale [vecnorm [veccross [vecsub $o1 $o2] [vecsub $o3 $o1]]] $half_length]
        set perp_back [vecscale [vecnorm [veccross [vecsub $o1 $o2] [vecsub $o3 $o1]]] -$half_length]
        set s1 [vecadd $perp_for $o1]
        set s2 [vecadd $perp_for $o2]
        set s3 [vecadd $perp_for $o3]
        set s4 [vecadd $perp_for $o4]
        set s5 [vecadd $perp_back $o1]
        set s6 [vecadd $perp_back $o2]
        set s7 [vecadd $perp_back $o3]
        set s8 [vecadd $perp_back $o4]

        # Draw the Cube - some cubes require two colors, so the triangles are intentionally divided so that one 
	# side shows both colors
        # Color 1 (blue, yellow, or green)
        draw color $color1
        draw triangle $s2 $s3 $s4
        draw triangle $s1 $s2 $s6
        draw triangle $s4 $s7 $s8
        draw triangle $s5 $s6 $s8
        draw triangle $s2 $s4 $s8
        draw triangle $s1 $s5 $s7
        # Color 2 (white)
        draw color $color2
        draw triangle $s1 $s3 $s2
        draw triangle $s3 $s7 $s4
        draw triangle $s1 $s6 $s5
        draw triangle $s5 $s8 $s7
        draw triangle $s2 $s8 $s6
        draw triangle $s1 $s7 $s3

        # Draw a border around the edges of the cube - this is important for white shapes that blend into white 
	# backgrounds, and should be an option for the user
#       draw color gray
#       draw cylinder $s2 $s4 radius 0.01
#       draw cylinder $s4 $s8 radius 0.01
#       draw cylinder $s8 $s6 radius 0.01
#       draw cylinder $s6 $s2 radius 0.01
#       draw cylinder $s1 $s3 radius 0.01
#       draw cylinder $s3 $s7 radius 0.01
#       draw cylinder $s7 $s5 radius 0.01
#       draw cylinder $s5 $s1 radius 0.01
#       draw cylinder $s3 $s4 radius 0.01
#       draw cylinder $s8 $s7 radius 0.01
#       draw cylinder $s6 $s5 radius 0.01
#       draw cylinder $s1 $s2 radius 0.01

}

# Diamond
proc linked_carb.oriented.diamond {p6 size geom_center geom_center_att color1 color2} {
        # The objective is to orient the shapes so that they face the neighboring residue, connected at C1. 
        # This is accomplished by calculating the equation for the line that connects the geometric centers of the
        # target residue (where the shape will be placed) and the neighboring residue (which is attached at the C1 atom). 
        # If we consider the geometric center of the target residue to be point A, the center of the neighboring 
        # residue to be point B, and the origin to be point O, then vector_AB=vector_OB - vector_OA. 
        # Knowing vector AB allows us to put new points along the line; however, we want the shapes to be of a 
        # defined size. In order to adjust the size properly, the distance between geometric centers is determined, 
        # scaled to match the desired size, and then added/subtracted from the geometric center of the target sugar.

        set vec_AB [vecsub $geom_center_att $geom_center]
                
        # Resize the shape. $size refers to the total size, $shape_size refers to the distance required create 
	# points on either side of the geometric center.
        set shape_size [expr $size*0.5]
                
	# Vec_AB is currently too large, we want it to be adjusted so that the distance is equal to the offset 
	# that will be used to place the ponits around the geometric center. The equation asks the question, 	
	# what factor should be multiplied times the distance in order to prodce $half-length?
        set adjustment [expr $shape_size/[vecdist $geom_center $geom_center_att]]
                
	# Adjust vector_AB by the amount determined in both the forward and reverse directions
        set adj_vec_AB_1 [vecscale $adjustment $vec_AB]
        set adj_vec_AB_2 [vecscale -$adjustment $vec_AB]
                
	# Add two points along the line connecting the residues in the forward and reverse direction
        set x1 [vecadd $adj_vec_AB_1 $geom_center]
        set x2 [vecadd $adj_vec_AB_2 $geom_center]

	# perp_1 represents a point perpendicular to the previously created two
        set perp_1 [vecnorm [veccross [vecsub $x1 $x2] [vecsub $x2 $p6]]]
        set perp1 [vecscale $perp_1 $shape_size]
        set perp2 [vecscale $perp_1 -$shape_size]

	# The number of sides to the diamond is up for debate. It was suggested to use six sides since the 
	# diamond could look like a cube that has been rotated; however, four seems to work since the cylinder 
	# goes directly through one corner. Maybe it could be an option for the user?
	# Each 'o' represents a corner of a square that is centered on $geom_center
        set o1 [vecadd $perp1 $x1]
        set o2 [vecadd $perp1 $x2]
        set o3 [vecadd $perp2 $x1]
        set o4 [vecadd $perp2 $x2]

    # Determine coordinates for outer points of the diamond
	# Top point of star is $shape_size above geometric center
	# Vector distance between center and top point of star
        set d1 [vecsub $x2 $geom_center]
                
	# Rotate by 72 degrees to identify other points of the star - note that t5 is the same as n1
        set t1 [vectrans [trans angle $o1 $geom_center $o2 90] $d1]
        set t2 [vectrans [trans angle $o1 $geom_center $o2 180] $d1]
        set t3 [vectrans [trans angle $o1 $geom_center $o2 270] $d1]
        set t4 [vectrans [trans angle $o1 $geom_center $o2 360] $d1]
        set outer_1 [vecadd $t1 $geom_center]
        set outer_2 [vecadd $t2 $geom_center]
        set outer_3 [vecadd $t3 $geom_center]
        set outer_4 [vecadd $t4 $geom_center]

	# The following function creates the top and bottom of the diamond by creating two points at the geometric 
	# center that are perpendicular to the plane of the square (and parallel with the plane of the ring).
        set perp_for [vecscale $shape_size [vecnorm [veccross [vecsub $o1 $o2] [vecsub $o3 $o1]]]]
        set perp_back [vecscale -$shape_size [vecnorm [veccross [vecsub $o1 $o2] [vecsub $o3 $o1]]]]
        set top [vecadd $perp_for $geom_center]
        set bottom [vecadd $perp_back $geom_center]

        # Draw the diamond
        # Front
        draw color $color1
        draw triangle $outer_1 $bottom $outer_2
        draw triangle $outer_1 $outer_4 $bottom
        draw triangle $outer_3 $top $outer_2
        draw triangle $outer_3 $outer_4 $top
        # Back
        draw color $color2
        draw triangle $outer_1 $outer_2 $top
        draw triangle $outer_1 $top $outer_4
        draw triangle $outer_3 $outer_2 $bottom
        draw triangle $outer_3 $bottom $outer_4
}

# Cone
proc linked_carb.oriented.cone {p6 size geom_center geom_center_att color1 color2} {
        # The objective is to orient the shapes so that they face the neighboring residue, connected at C1. 
        # This is accomplished by calculating the equation for the line that connects the geometric centers of the
        # target residue (where the shape will be placed) and the neighboring residue (which is attached at the C1 atom). 
        # If we consider the geometric center of the target residue to be point A, the center of the neighboring 
        # residue to be point B, and the origin to be point O, then vector_AB=vector_OB - vector_OA. 
        # Knowing vector AB allows us to put new points along the line; however, we want the shapes to be of a 
        # defined size. In order to adjust the size properly, the distance between geometric centers is determined, 
        # scaled to match the desired size, and then added/subtracted from the geometric center of the target sugar.
        
	set vec_AB [vecsub $geom_center_att $geom_center]
                
	# Resize the shape. $size refers to the total size, $half_length refers to the distance required create 
	# points on either side of the geometric center.
        set half_length [expr $size/2]
                
	# Vec_AB is currently too large, we want it to be adjusted so that the distance is equal to the offset 
	# that will be used to place the points around the geometric center. The equation asks the question, 
	# what factor should be multiplied times the distance in order to prodce $half-length?
	# Two adjustments are added to shift the geom_center of the shape.
        set adjustment1 [expr ($half_length*0.66)/[vecdist $geom_center $geom_center_att]]
        set adjustment2 [expr ($half_length*1.33)/[vecdist $geom_center $geom_center_att]]
                
	# Adjust vector_AB by the amount determined in both the forward and reverse directions
        set adj_vec_AB_1 [vecscale $adjustment1 $vec_AB]
        set adj_vec_AB_2 [vecscale -$adjustment2 $vec_AB]
                
	# Add two points along the line connecting the residues in the forward and reverse direction
        set x1 [vecadd $adj_vec_AB_1 $geom_center]
        set x2 [vecadd $adj_vec_AB_2 $geom_center]

	# perp_1 represents a point perpendicular to the previously created two
	set perp_1 [vecnorm [veccross [vecsub $x1 $x2] [vecsub $x2 $p6]]]
        set perp1 [vecscale $perp_1 1]
        set perp2 [vecscale $perp_1 -0.5]
        set o1 [vecadd $perp1 $x1]
        set o2 [vecadd $perp2 $x1]
        set perp_3 [vecnorm [veccross [vecsub $o1 $x2] [vecsub $x2 $geom_center_att]]]
        set perp3 [vecscale $perp_3 $half_length]
        set o3 [vecadd $perp3 $x1]

        # Determine coordinates for outer points of the rectangle
	# Top point of rectangle is $half_length above geometric center
	# Vector distance between center and top point of rectangle
        set d1 [vecsub $o3 $x1]
                
	# Rotate by 90 degrees to identify other points of the rectangle - note that t5 is the same as x1
        set t1 [vectrans [trans angle $o1 $o3 $x1 45] $d1]
        set t2 [vectrans [trans angle $o1 $o3 $x1 90] $d1]
        set t3 [vectrans [trans angle $o1 $o3 $x1 135] $d1]
        set t4 [vectrans [trans angle $o1 $o3 $x1 180] $d1]
        set t5 [vectrans [trans angle $o1 $o3 $x1 225] $d1]
        set t6 [vectrans [trans angle $o1 $o3 $x1 270] $d1]
        set t7 [vectrans [trans angle $o1 $o3 $x1 315] $d1]
        set t8 [vectrans [trans angle $o1 $o3 $x1 360] $d1]
        set outer_1 [vecadd $t1 $x1]
        set outer_2 [vecadd $t2 $x1]
        set outer_3 [vecadd $t3 $x1]
        set outer_4 [vecadd $t4 $x1]
        set outer_5 [vecadd $t5 $x1]
        set outer_6 [vecadd $t6 $x1]
        set outer_7 [vecadd $t7 $x1]
        set outer_8 [vecadd $t8 $x1]

	# Draw the cone 
        # Base
	draw color $color1
        draw triangle $outer_1 $outer_2 $x1
        draw triangle $outer_1 $x1 $outer_8
        draw triangle $outer_3 $x1 $outer_2
        draw triangle $outer_3 $outer_4 $x1
	draw color $color2
        draw triangle $outer_5 $x1 $outer_4
        draw triangle $outer_5 $outer_6 $x1
        draw triangle $outer_7 $x1 $outer_6
        draw triangle $outer_7 $outer_8 $x1
	# Top
	draw color $color1
        draw triangle $outer_1 $x2 $outer_2
        draw triangle $outer_1 $outer_8 $x2
        draw triangle $outer_5 $outer_4 $x2
        draw triangle $outer_5 $x2 $outer_6
	draw color $color2
        draw triangle $outer_3 $outer_2 $x2
        draw triangle $outer_3 $x2 $outer_4
        draw triangle $outer_7 $outer_6 $x2
        draw triangle $outer_7 $x2 $outer_8
}

# Rectangle 
proc linked_carb.oriented.rectangle {p6 size geom_center geom_center_att color1 color2} { 
        # The objective is to orient the shapes so that they face the neighboring residue, connected at C1. 
        # This is accomplished by calculating the equation for the line that connects the geometric centers of the
        # target residue (where the shape will be placed) and the neighboring residue (which is attached at the C1 atom). 
        # If we consider the geometric center of the target residue to be point A, the center of the neighboring 
        # residue to be point B, and the origin to be point O, then vector_AB=vector_OB - vector_OA. 
        # Knowing vector AB allows us to put new points along the line; however, we want the shapes to be of a 
        # defined size. In order to adjust the size properly, the distance between geometric centers is determined, 
        # scaled to match the desired size, and then added/subtracted from the geometric center of the target sugar.

	# The longest side of the rectangle is perpendicular to the plane of the ring, 
	# so it shouldn't clash with connecting residues.
        set vec_AB [vecsub $geom_center_att $geom_center]

	# Resize the shape. $size refers to the total size, $half_length refers to the 
	# distance required create points on either side of the geometric center.
	set shape_size [expr $size*1]
        set half_length [expr $shape_size/(1.2)]
        set thickness [expr $shape_size/(1.8)]
                
	# Vec_AB is currently too large, we want it to be adjusted so that the distance is equal to the offset 
	# that will be used to place the ponits around the geometric center. The equation asks the question, 
	# what factor should be multiplied times the distance in order to prodce $half-length?
        set adjustment [expr $half_length/[vecdist $geom_center $geom_center_att]]
                
	# Adjust vector_AB by the amount determined in both the forward and reverse directions
        set adj_vec_AB_1 [vecscale $adjustment $vec_AB]
        set adj_vec_AB_2 [vecscale -$adjustment $vec_AB]
                
	# Add two points along the line connecting the residues in the forward and reverse direction
        set x1 [vecadd $adj_vec_AB_1 $geom_center]
        set x2 [vecadd $adj_vec_AB_2 $geom_center]

	# perp_1 represents a point perpendicular to the previously created two
	set perp_1 [vecnorm [veccross [vecsub $x1 $x2] [vecsub $x2 $p6]]]
        set perp1 [vecscale $perp_1 $half_length]
        set perp2 [vecscale $perp_1 -$half_length]
	        
	# Each 'o' represents a corner of a square that is centered on $geom_center
        set o1 [vecadd $perp1 $x1]
        set o2 [vecadd $perp1 $x2]
        set o3 [vecadd $perp2 $x1]
        set o4 [vecadd $perp2 $x2]

	# Determine coordinates for outer points of the rectangle
	# Top point of rectangle is $half_length above geometric center
	# Vector distance between center and top point of rectangle
	set d1 [vecsub $x2 $geom_center]
		
	# Rotate by 90 degrees to identify other points of the rectangle - note that t5 is the same as n1
	set t1 [vectrans [trans angle $o1 $geom_center $o2 45] $d1]
	set t2 [vectrans [trans angle $o1 $geom_center $o2 90] $d1]
	set t3 [vectrans [trans angle $o1 $geom_center $o2 225] $d1]
	set t4 [vectrans [trans angle $o1 $geom_center $o2 270] $d1]
	set outer_1 [vecadd $t1 $geom_center]
	set outer_2 [vecadd $t2 $geom_center]
	set outer_3 [vecadd $t3 $geom_center]
	set outer_4 [vecadd $t4 $geom_center]

	# The following function makes the rectangle 3D by creating two points at the geometric center 
	# that are perpendicular to the plane of the square (and parallel with the plane of the ring).
        set perp_for [vecscale $thickness [vecnorm [veccross [vecsub $o1 $o2] [vecsub $o3 $o1]]]]
        set perp_back [vecscale -$thickness [vecnorm [veccross [vecsub $o1 $o2] [vecsub $o3 $o1]]]]
        set center_1 [vecadd $perp_for $geom_center]
        set center_2 [vecadd $perp_back $geom_center]
        set front_1 [vecadd $perp_for $outer_1]
        set front_2 [vecadd $perp_for $outer_2]
        set front_3 [vecadd $perp_for $outer_3]
        set front_4 [vecadd $perp_for $outer_4]
        set back_1 [vecadd $perp_back $outer_1]
        set back_2 [vecadd $perp_back $outer_2]
        set back_3 [vecadd $perp_back $outer_3]
        set back_4 [vecadd $perp_back $outer_4]

	# Draw the rectangle
	draw color $color1
	# Front
        draw triangle $front_1 $front_2 $center_1
        draw triangle $front_1 $center_1 $front_4
        draw triangle $front_3 $center_1 $front_2
        draw triangle $front_3 $front_4 $center_1
	# Back
        draw triangle $back_1 $center_2 $back_2
        draw triangle $back_1 $back_4 $center_2
        draw triangle $back_3 $back_2 $center_2
        draw triangle $back_3 $center_2 $back_4
	# Connect
        draw triangle $back_1 $back_2 $front_1
        draw triangle $back_2 $front_2 $front_1
        draw triangle $back_2 $back_3 $front_2
        draw triangle $back_3 $front_3 $front_2
        draw triangle $back_3 $back_4 $front_3
        draw triangle $back_4 $front_4 $front_3
        draw triangle $back_4 $back_1 $front_4
        draw triangle $back_1 $front_1 $front_4
}

# Star
proc linked_carb.oriented.star {p6 size geom_center geom_center_att color1 color2} { 
        # The objective is to orient the shapes so that they face the neighboring residue, connected at C1. 
        # This is accomplished by calculating the equation for the line that connects the geometric centers of the
        # target residue (where the shape will be placed) and the neighboring residue (which is attached at the C1 atom). 
        # If we consider the geometric center of the target residue to be point A, the center of the neighboring 
        # residue to be point B, and the origin to be point O, then vector_AB=vector_OB - vector_OA. 
        # Knowing vector AB allows us to put new points along the line; however, we want the shapes to be of a 
        # defined size. In order to adjust the size properly, the distance between geometric centers is determined, 
        # scaled to match the desired size, and then added/subtracted from the geometric center of the target sugar.

        set vec_AB [vecsub $geom_center_att $geom_center]
                
	# Resize the shape. $size refers to the total size, $half_length refers to the distance required create 
	# points on either side of the geometric center.
	set shape_size [expr $size*1.5]
        set half_length [expr $shape_size/2]
        set thickness [expr $shape_size/4]
                
	# Vec_AB is currently too large, we want it to be adjusted so that the distance is equal to the offset 
	# that will be used to place the ponits around the geometric center. The equation asks the question, 
	# what factor should be multiplied times the distance in order to prodce $half-length?
        set adjustment [expr $half_length/[vecdist $geom_center $geom_center_att]]
               
	# Adjust vector_AB by the amount determined in both the forward and reverse directions
        set adj_vec_AB_1 [vecscale $adjustment $vec_AB]
        set adj_vec_AB_2 [vecscale -$adjustment $vec_AB]
                
	# Add two points along the line connecting the residues in the forward and reverse direction
        set x1 [vecadd $adj_vec_AB_1 $geom_center]
        set x2 [vecadd $adj_vec_AB_2 $geom_center]

	# perp_1 represents a point perpendicular to the previously created two
	set perp_1 [vecnorm [veccross [vecsub $x1 $x2] [vecsub $x2 $p6]]]
        set perp1 [vecscale $perp_1 $half_length]
        set perp2 [vecscale $perp_1 -$half_length]
	        
	# Each 'o' represents a corner of a square that is centered on $geom_center
        set o1 [vecadd $perp1 $x1]
        set o2 [vecadd $perp1 $x2]
        set o3 [vecadd $perp2 $x1]
        set o4 [vecadd $perp2 $x2]

	# Determine coordinates for outer points of the star
	# Top point of star is $half_length above geometric center
	# Vector distance between center and top point of star
	set d1 [vecsub $x2 $geom_center]
		
	# Rotate by 72 degrees to identify other points of the star 
	set t1 [vectrans [trans angle $o1 $geom_center $o2 72] $d1]
	set t2 [vectrans [trans angle $o1 $geom_center $o2 144] $d1]
	set t3 [vectrans [trans angle $o1 $geom_center $o2 216] $d1]
	set t4 [vectrans [trans angle $o1 $geom_center $o2 288] $d1]
	set t5 [vectrans [trans angle $o1 $geom_center $o2 360] $d1]
	set outer_1 [vecadd $t1 $geom_center]
	set outer_2 [vecadd $t2 $geom_center]
	set outer_3 [vecadd $t3 $geom_center]
	set outer_4 [vecadd $t4 $geom_center]
	set outer_5 [vecadd $t5 $geom_center]

	# Determine coordinates for inner points of the star
	# Bottom point of star is $half_length below geometric center
	# Vector distance between center and top point of star
	set d2 [vecscale [vecsub $x1 $geom_center] 0.5]
		
	# Rotate by 72 degrees to identify other points of the star - note that b5 is the same as n2
	set b1 [vectrans [trans angle $o1 $geom_center $o2 72] $d2]
	set b2 [vectrans [trans angle $o1 $geom_center $o2 144] $d2]
	set b3 [vectrans [trans angle $o1 $geom_center $o2 216] $d2]
	set b4 [vectrans [trans angle $o1 $geom_center $o2 288] $d2]
	set b5 [vectrans [trans angle $o1 $geom_center $o2 360] $d2]
	set inner_1 [vecadd $b1 $geom_center]
	set inner_2 [vecadd $b2 $geom_center]
	set inner_3 [vecadd $b3 $geom_center]
	set inner_4 [vecadd $b4 $geom_center]
	set inner_5 [vecadd $b5 $geom_center]
	
	# The following function makes the star 3D by creating two points at the geometric center 
	# that are perpendicular to the plane of the star
        set perp_for [vecscale $thickness [vecnorm [veccross [vecsub $o1 $o2] [vecsub $o3 $o1]]]]
        set perp_back [vecscale -$thickness [vecnorm [veccross [vecsub $o1 $o2] [vecsub $o3 $o1]]]]
        set center_1 [vecadd $perp_for $geom_center]
        set center_2 [vecadd $perp_back $geom_center]

	# Draw the star
	draw color $color1
	draw triangle $outer_1 $center_1 $inner_3
	draw triangle $outer_1 $inner_3 $center_2
	draw triangle $outer_1 $inner_4 $center_1
	draw triangle $outer_1 $center_2 $inner_4
	draw triangle $outer_2 $center_1 $inner_4
	draw triangle $outer_2 $inner_4 $center_2
	draw triangle $outer_2 $inner_5 $center_1
	draw triangle $outer_2 $center_2 $inner_5
	draw triangle $outer_3 $center_1 $inner_5
	draw triangle $outer_3 $inner_5 $center_2
	draw triangle $outer_3 $inner_1 $center_1
	draw triangle $outer_3 $center_2 $inner_1
	draw triangle $outer_4 $center_1 $inner_1
	draw triangle $outer_4 $inner_1 $center_2
	draw triangle $outer_4 $inner_2 $center_1
	draw triangle $outer_4 $center_2 $inner_2
	draw triangle $outer_5 $center_1 $inner_2
	draw triangle $outer_5 $inner_2 $center_2
	draw triangle $outer_5 $inner_3 $center_1
	draw triangle $outer_5 $center_2 $inner_3
}

# Hexagon
proc linked_carb.oriented.hexagon {p6 size geom_center geom_center_att color1 color2} { 
        # The objective is to orient the shapes so that they face the neighboring residue, connected at C1. 
        # This is accomplished by calculating the equation for the line that connects the geometric centers of the
        # target residue (where the shape will be placed) and the neighboring residue (which is attached at the C1 atom). 
        # If we consider the geometric center of the target residue to be point A, the center of the neighboring 
        # residue to be point B, and the origin to be point O, then vector_AB=vector_OB - vector_OA. 
        # Knowing vector AB allows us to put new points along the line; however, we want the shapes to be of a 
        # defined size. In order to adjust the size properly, the distance between geometric centers is determined, 
        # scaled to match the desired size, and then added/subtracted from the geometric center of the target sugar.

        set vec_AB [vecsub $geom_center_att $geom_center]
                
	# Resize the shape. $size refers to the total size, $half_length refers to the distance required create 
	# points on either side of the geometric center.
	set shape_size [expr $size*1]
        set half_length [expr $shape_size/2]
        set thickness [expr $shape_size/4]
                
	# Vec_AB is currently too large, we want it to be adjusted so that the distance is equal to the offset 
	# that will be used to place the ponits around the geometric center. The equation asks the question, 
	# what factor should be multiplied times the distance in order to prodce $half-length?
        set adjustment [expr $half_length/[vecdist $geom_center $geom_center_att]]
                
	# Adjust vector_AB by the amount determined in both the forward and reverse directions
        set adj_vec_AB_1 [vecscale $adjustment $vec_AB]
        set adj_vec_AB_2 [vecscale -$adjustment $vec_AB]

	# Add two points along the line connecting the residues in the forward and reverse direction
        set x1 [vecadd $adj_vec_AB_1 $geom_center]
        set x2 [vecadd $adj_vec_AB_2 $geom_center]

	# perp_1 represents a point perpendicular to the previously created two
	set perp_1 [vecnorm [veccross [vecsub $x1 $x2] [vecsub $x2 $p6]]]
        set perp1 [vecscale $perp_1 $half_length]
        set perp2 [vecscale $perp_1 -$half_length]
	        
	# Each 'o' represents a corner of a square that is centered on $geom_center
        set o1 [vecadd $perp1 $x1]
        set o2 [vecadd $perp1 $x2]
        set o3 [vecadd $perp2 $x1]
        set o4 [vecadd $perp2 $x2]

	# Determine coordinates for outer points of the hexagon
	# Top point of hexagon is $half_length above geometric center
	# Vector distance between center and top point of pentagon
	set d1 [vecsub $x2 $geom_center]
		
	# Rotate by 60 degrees to identify other points of the hexagon - note that t5 is the same as n1
	set t1 [vectrans [trans angle $o1 $geom_center $o2 0] $d1]
	set t2 [vectrans [trans angle $o1 $geom_center $o2 45] $d1]
	set t3 [vectrans [trans angle $o1 $geom_center $o2 135] $d1]
	set t4 [vectrans [trans angle $o1 $geom_center $o2 180] $d1]
	set t5 [vectrans [trans angle $o1 $geom_center $o2 225] $d1]
	set t6 [vectrans [trans angle $o1 $geom_center $o2 315] $d1]
	set outer_1 [vecadd $t1 $geom_center]
	set outer_2 [vecadd $t2 $geom_center]
	set outer_3 [vecadd $t3 $geom_center]
	set outer_4 [vecadd $t4 $geom_center]
	set outer_5 [vecadd $t5 $geom_center]
	set outer_6 [vecadd $t6 $geom_center]

	# The following function makes the hexagon 3D by creating two points at the geometric center that are perpendicular to the plane of the hexagon
        set perp_for [vecscale $thickness [vecnorm [veccross [vecsub $o1 $o2] [vecsub $o3 $o1]]]]
        set perp_back [vecscale -$thickness [vecnorm [veccross [vecsub $o1 $o2] [vecsub $o3 $o1]]]]
        set center_1 [vecadd $perp_for $geom_center]
        set center_2 [vecadd $perp_back $geom_center]
        set front_1 [vecadd $perp_for $outer_1]
        set front_2 [vecadd $perp_for $outer_2]
        set front_3 [vecadd $perp_for $outer_3]
        set front_4 [vecadd $perp_for $outer_4]
        set front_5 [vecadd $perp_for $outer_5]
        set front_6 [vecadd $perp_for $outer_6]
        set back_1 [vecadd $perp_back $outer_1]
        set back_2 [vecadd $perp_back $outer_2]
        set back_3 [vecadd $perp_back $outer_3]
        set back_4 [vecadd $perp_back $outer_4]
        set back_5 [vecadd $perp_back $outer_5]
        set back_6 [vecadd $perp_back $outer_6]

	# Draw the hexagon
	draw color $color1
	# Front-side
        draw triangle $front_1 $front_2 $center_1
        draw triangle $front_1 $center_1 $front_6
        draw triangle $front_3 $center_1 $front_2
        draw triangle $front_3 $front_4 $center_1
        draw triangle $front_5 $center_1 $front_4
        draw triangle $front_5 $front_6 $center_1
	# Back-side
        draw triangle $back_1 $center_2 $back_2
        draw triangle $back_1 $back_6 $center_2
        draw triangle $back_3 $back_2 $center_2
        draw triangle $back_3 $center_2 $back_4
        draw triangle $back_5 $back_4 $center_2
        draw triangle $back_5 $center_2 $back_6
	# Connect
        draw triangle $back_1 $back_2 $front_1
        draw triangle $back_2 $front_2 $front_1
        draw triangle $back_2 $back_3 $front_2
        draw triangle $back_3 $front_3 $front_2
        draw triangle $back_3 $back_4 $front_3
        draw triangle $back_4 $front_4 $front_3
        draw triangle $back_4 $back_5 $front_4
        draw triangle $back_5 $front_5 $front_4
        draw triangle $back_5 $back_6 $front_5
        draw triangle $back_6 $front_6 $front_5
        draw triangle $back_6 $back_1 $front_6
        draw triangle $back_1 $front_1 $front_6
}

# Pentagon
proc linked_carb.oriented.pentagon {p6 size geom_center geom_center_att color1 color2} { 
        # The objective is to orient the shapes so that they face the neighboring residue, connected at C1. 
        # This is accomplished by calculating the equation for the line that connects the geometric centers of the
        # target residue (where the shape will be placed) and the neighboring residue (which is attached at the C1 atom). 
        # If we consider the geometric center of the target residue to be point A, the center of the neighboring 
        # residue to be point B, and the origin to be point O, then vector_AB=vector_OB - vector_OA. 
        # Knowing vector AB allows us to put new points along the line; however, we want the shapes to be of a 
        # defined size. In order to adjust the size properly, the distance between geometric centers is determined, 
        # scaled to match the desired size, and then added/subtracted from the geometric center of the target sugar.

        set vec_AB [vecsub $geom_center_att $geom_center]
                
	# Resize the shape. $size refers to the total size, $half_length refers to the distance required create 
	# points on either side of the geometric center.
	set shape_size [expr $size*1]
        set half_length [expr $shape_size/2]
        set thickness [expr $shape_size/4]
                
	# Vec_AB is currently too large, we want it to be adjusted so that the distance is equal to the offset 
	# that will be used to place the ponits around the geometric center. The equation asks the question, 
	# what factor should be multiplied times the distance in order to prodce $half-length?
        set adjustment [expr $half_length/[vecdist $geom_center $geom_center_att]]
                
	# Adjust vector_AB by the amount determined in both the forward and reverse directions
        set adj_vec_AB_1 [vecscale $adjustment $vec_AB]
        set adj_vec_AB_2 [vecscale -$adjustment $vec_AB]
                
	# Add two points along the line connecting the residues in the forward and reverse direction
        set x1 [vecadd $adj_vec_AB_1 $geom_center]
        set x2 [vecadd $adj_vec_AB_2 $geom_center]

	# perp_1 represents a point perpendicular to the previously created two
	set perp_1 [vecnorm [veccross [vecsub $x1 $x2] [vecsub $x2 $p6]]]
        set perp1 [vecscale $perp_1 $half_length]
        set perp2 [vecscale $perp_1 -$half_length]
	        
	# Each 'o' represents a corner of a square that is centered on $geom_center
        set o1 [vecadd $perp1 $x1]
        set o2 [vecadd $perp1 $x2]
        set o3 [vecadd $perp2 $x1]
        set o4 [vecadd $perp2 $x2]

	# Determine coordinates for outer points of the pentagon
	# Top point of pentagon is $half_length above geometric center
	# Vector distance between center and top point of pentagon
	set d1 [vecsub $x2 $geom_center]
		
	# Rotate by 72 degrees to identify other points of the pentagon - note that t5 is the same as n1
	set t1 [vectrans [trans angle $o1 $geom_center $o2 72] $d1]
	set t2 [vectrans [trans angle $o1 $geom_center $o2 144] $d1]
	set t3 [vectrans [trans angle $o1 $geom_center $o2 216] $d1]
	set t4 [vectrans [trans angle $o1 $geom_center $o2 288] $d1]
	set t5 [vectrans [trans angle $o1 $geom_center $o2 360] $d1]
	set outer_1 [vecadd $t1 $geom_center]
	set outer_2 [vecadd $t2 $geom_center]
	set outer_3 [vecadd $t3 $geom_center]
	set outer_4 [vecadd $t4 $geom_center]
	set outer_5 [vecadd $t5 $geom_center]

	# The following function makes the pentagon 3D by creating two points at the geometric center 
	# that are perpendicular to the plane of the pentagon
        set perp_for [vecscale $thickness [vecnorm [veccross [vecsub $o1 $o2] [vecsub $o3 $o1]]]]
        set perp_back [vecscale -$thickness [vecnorm [veccross [vecsub $o1 $o2] [vecsub $o3 $o1]]]]
        set center_1 [vecadd $perp_for $geom_center]
        set center_2 [vecadd $perp_back $geom_center]
        set front_1 [vecadd $perp_for $outer_1]
        set front_2 [vecadd $perp_for $outer_2]
        set front_3 [vecadd $perp_for $outer_3]
        set front_4 [vecadd $perp_for $outer_4]
        set front_5 [vecadd $perp_for $outer_5]
        set back_1 [vecadd $perp_back $outer_1]
        set back_2 [vecadd $perp_back $outer_2]
        set back_3 [vecadd $perp_back $outer_3]
        set back_4 [vecadd $perp_back $outer_4]
        set back_5 [vecadd $perp_back $outer_5]

	# Draw the pentagon
	draw color $color1
	# Front
        draw triangle $front_1 $front_2 $center_1
        draw triangle $front_1 $center_1 $front_5
        draw triangle $front_3 $center_1 $front_2
        draw triangle $front_3 $front_4 $center_1
        draw triangle $front_5 $center_1 $front_4
	# Back
        draw triangle $back_1 $center_2 $back_2
        draw triangle $back_1 $back_5 $center_2
        draw triangle $back_3 $back_2 $center_2
        draw triangle $back_3 $center_2 $back_4
        draw triangle $back_5 $back_4 $center_2
	# Connect
        draw triangle $back_1 $back_2 $front_1
        draw triangle $back_2 $front_2 $front_1
        draw triangle $back_2 $back_3 $front_2
        draw triangle $back_3 $front_3 $front_2
        draw triangle $back_3 $back_4 $front_3
        draw triangle $back_4 $front_4 $front_3
        draw triangle $back_4 $back_5 $front_4
        draw triangle $back_5 $front_5 $front_4
        draw triangle $back_5 $back_1 $front_5
        draw triangle $back_1 $front_1 $front_5
}

### Determine coordinate positions for placing shapes (and cylinders)
proc snfg-update { frm } {

	set i 0
	# For each carbohydrate residue
	foreach residue $::SNFG::residues {
	
		set startnum [lindex $::SNFG::shiftbool $i]

		# Get the coordinates for atoms in the 6-membered ring (p stands for point)
		set c1 [atomselect $::SNFG::carbmol "residue $residue and name C[expr $startnum+1]" frame $frm]
	 	set o5 [atomselect $::SNFG::carbmol "residue $residue and name O[expr $startnum+5]" frame $frm]

		lassign [$c1 get {x y z}] p1
		lassign [$o5 get {x y z}] p6
		$c1 delete
		$o5 delete

		# Calculate the geometric center of the ring
		set ring_atoms [atomselect $::SNFG::carbmol "residue $residue and name C[expr $startnum+1] C[expr $startnum+2] C[expr $startnum+3] C[expr $startnum+4] C[expr $startnum+5] O[expr $startnum+5]" frame $frm]
		set geom_center [measure center $ring_atoms]
		$ring_atoms delete

		# Get the geometric center of the ring attached to this ring, and draw cylinders connecting rings.
		# In some cases, there is no attached residue. The following line assigns the coordinates 
		# of the C1 atom (or C2 for sialic acids) to be the geometric center of the attached residue
		# so that the shapes can be aligned properly without crashing when no residue is attached. 
		set geom_center_att $p1	

		# Connections (cylinders) depend on linkage type
                set O_att [atomselect $::SNFG::carbmol "(oxygen within 1.6 of residue $residue and name C[expr $startnum+1]) and not (residue $residue and name O[expr $startnum+5])" frame $frm]
		set N_att [atomselect $::SNFG::carbmol "(nitrogen within 1.6 of residue $residue and name C[expr $startnum+1])" frame $frm]

		# If the residue has an attached oxygen
                if {[$O_att get residue]  >= 0 } {

                        lassign [$O_att get residue] O_att_r ; # Residue of attached oxygen
                        lassign [$O_att get name] O_att_n ; # Atom name of attached oxygen

			# Check if the oxygen is then attached to a carbon
                        set C_att [atomselect $::SNFG::carbmol "(carbon within 1.6 of residue $O_att_r and name $O_att_n) and not residue $residue" frame $frm]

			# If the oxygen is attached to a carbon
                        if {[$C_att get residue] >= 0 } {

				# Then the attached residue is a carbohydrate or this is an O-linked glycan
				# Check for ring atoms of the attached carbohydrate residue
                                lassign [$C_att get residue] C_att_r ; # Residue of attached carbon
				set carbatoms "maxringsize 6 from (hetero and name C1 C2 C3 C4 C5 O5 O6)"
                                set ring_atoms_att [atomselect $::SNFG::carbmol "($carbatoms) and residue $C_att_r" frame $frm]

				# If the attached residue contains ring atoms
                                if {[$ring_atoms_att get residue] >= 0 } {

					# Then the attached residue is a carbohydrate
					# Set position of attachment as geometric center of ring atoms of attached carbohydrate residue
                                        set geom_center_att [measure center $ring_atoms_att]

                                        draw color gray
                                        draw cylinder $geom_center $geom_center_att radius $::SNFG::cylinder_radius

				# Otherwise this is an O-linked glycan or GLYCAM OME or TBT
                                } else {

					# Check for alpha carbon of attached protein residue
                                        set att_CA [atomselect $::SNFG::carbmol "residue $C_att_r and name CA" frame $frm]

					# If it has CA
                                        if {[$att_CA get residue] >= 0 } {

						# Then it is attached to a protein via CA and is an O-linked glycan
                                                lassign [$att_CA get {x y z}] att_CAp

						draw color gray
                                                draw sphere $att_CAp radius $::SNFG::cylinder_radius resolution 36
                                                draw cylinder $geom_center $att_CAp radius $::SNFG::cylinder_radius

						# Position of attachment is linked CA, but this is necessary to align the shapes later
                                                lassign [$att_CA get {x y z}] geom_center_att

					# But if it has no CA
                                        } else {

						# Then GLYCAM OME or TBT 
						lassign [$O_att get {x y z}] geom_center_att

						draw color gray
						draw sphere $geom_center_att radius [expr $::SNFG::sphere_size*$::SNFG::sphere_redfac] resolution 36
						draw cylinder $geom_center $geom_center_att radius [expr $::SNFG::cylinder_radius*$::SNFG::cylinder_redfac]
					}
					$att_CA delete
                                }
				$ring_atoms_att delete

			# If the oxygen is not attached to a carbon
                        } else {

				# Then it is a terminal oxygen and marks the reducing end
				lassign [$O_att get {x y z}] geom_center_att

				draw color gray 
				draw sphere $geom_center_att radius [expr $::SNFG::sphere_size*$::SNFG::sphere_redfac] resolution 36
				draw cylinder $geom_center $geom_center_att radius [expr $::SNFG::cylinder_radius*$::SNFG::cylinder_redfac]
			}
                        $C_att delete

		# If the residue has an attached nitrogen
                } elseif {[$N_att get residue] >= 0 } {

			# Then we assume this is an N-linked glycan
			# Set position of attachment as the linked CA
                        lassign [$N_att get residue] N_att_r
                        set att_CA [atomselect $::SNFG::carbmol "residue $N_att_r and name CA" frame $frm]
                        lassign [$att_CA get {x y z}] att_CAp

			draw color gray
                        draw sphere $att_CAp radius $::SNFG::cylinder_radius resolution 36
                        draw cylinder $geom_center $att_CAp radius $::SNFG::cylinder_radius

			# Position of attachment is linked CA, but this is necessary to align the shapes later
                        lassign [$att_CA get {x y z}] geom_center_att
                        $att_CA delete

		# If there is no oxygen or nitrogen attached
                } else {

			# Generate a point to denote terminal
			set vec [vecsub $p1 $geom_center]
			set vecadj [vecscale 1.43 [vecscale $vec [expr 1/[veclength $vec]]]] ; # GLYCAM Cg-Oh bond distance = 1.43 Angstroms
			set geom_center_att [vecadd $p1 $vecadj]
			
			draw color gray
			draw sphere $geom_center_att radius [expr $::SNFG::sphere_size*$::SNFG::sphere_redfac] resolution 36
			draw cylinder $geom_center $geom_center_att radius [expr $::SNFG::cylinder_radius*$::SNFG::cylinder_redfac]
		}
		$O_att delete
		$N_att delete

                lappend ::SNFG::p6list $p6
                lappend ::SNFG::geom_center_list $geom_center
                lappend ::SNFG::geom_center_att_list $geom_center_att

                incr i
	}
}

# Draw each residue shape according to its SNFG assignment
proc snfg-draw {} {
	set i 0
	while {$i < [llength $::SNFG::residues]} {
		linked_carb.oriented.[lindex $::SNFG::shapelist $i] [lindex $::SNFG::p6list $i] [lindex $::SNFG::sizelist $i] [lindex $::SNFG::geom_center_list $i] [lindex $::SNFG::geom_center_att_list $i] [lindex $::SNFG::color1list $i] [lindex $::SNFG::color2list $i]
		incr i
	}
}

# Change colors to official SNFG standard
proc snfg-colors {} {

	set white	[list white  0.00 0.00 0.00 0.00] ; # White 0/0/0/0
	set blue	[list blue   1.00 0.50 0.00 0.00] ; # Blue 100/50/0/0
	set green	[list green  1.00 0.00 1.00 0.00] ; # Green 100/0/100/0
	set yellow	[list yellow 0.00 0.15 1.00 0.00] ; # Yellow 0/15/100/0
	set cyan	[list cyan   0.41 0.05 0.03 0.00] ; # Light blue 41/5/3/0
	set pink	[list pink   0.00 0.47 0.24 0.00] ; # Pink 0/47/24/0
	set purple	[list purple 0.38 0.88 0.00 0.00] ; # Purple 38/88/0/0
	set tan		[list tan    0.32 0.48 0.76 0.13] ; # Brown 32/48/76/13
	set orange	[list orange 0.00 0.50 1.00 0.00] ; # Orange 0/50/100/0
	set red		[list red    0.00 1.00 1.00 0.00] ; # Red 0/100/100/0

	set colorlist   [list $white $blue $green $yellow $cyan $pink $purple $tan $orange $red]

	foreach color $colorlist {

		set name [lindex $color 0]

		set c [lindex $color 1]
		set m [lindex $color 2]
		set y [lindex $color 3]
		set k [lindex $color 4]

		set R [expr (1.-$c)*(1.-$k)]
		set G [expr (1.-$m)*(1.-$k)]
		set B [expr (1.-$y)*(1.-$k)]

		color change rgb $name $R $G $B 
		draw material AOShiny
	}
}

# Reset colors to VMD defaults
proc snfg-resetcolors {} {
	foreach color [colorinfo colors] {
		color change rgb $color
	}
}

# Assign appropriate shape/color based on residue name
proc snfg-detect {} {

        # Collect a list of residues that contain carbohydrate ring atoms
	set carbatoms "maxringsize 6 from (hetero and name C1 C2 C3 C4 C5 O5 O6)"
	set rings [atomselect $::SNFG::carbmol "maxringsize 6 from ($carbatoms)" frame 0]
	# Filter out rings that aren't actually carbohydrates (can happen with linear carbohydrates with coordinating ions)
	set templist [lsort -unique [$rings get residue]]
	foreach res $templist {
	        set checkres [atomselect $::SNFG::carbmol "($carbatoms) and residue $res"]
	        if {[$checkres num] >= 5} {
	                lappend ::SNFG::residues $res
	        }
	        $checkres delete
	}

	# Check for GLYCAM reducing-terminal ROH to assign appropriate resname color 
	set topall [atomselect $::SNFG::carbmol "all"]
	set toplist [lsort -unique [$topall get resname]]
	if {[lsearch $toplist "ROH"] >= 0 } {
		set ROH_C [atomselect $::SNFG::carbmol "carbon within 1.6 of resname ROH" frame 0]
		set ::SNFG::ROH_att [$ROH_C get resname]
		$ROH_C delete
	}
	$topall delete

	# Assign list items for each detected carbohydrate ring residue
	set i 0
	foreach residue $::SNFG::residues {

		set ringatoms [atomselect $::SNFG::carbmol "maxringsize 6 from residue $residue" frame 0]
		set res [lsort -unique [$ringatoms get resname]]

		# Determine whether the ring atom numbering starts at C1 or C2 (important for drawing connections)
		if {[lsearch [$ringatoms get name] C1] >= 0} {
			lappend ::SNFG::shiftbool 0
		} elseif {[lsearch [$ringatoms get name] C2] >= 0} {
			lappend ::SNFG::shiftbool 1
		}

		# Assign shape/size/color properties based on recognized residue names
		### Filled sphere 
		# Glucose (blue sphere)
		if {[lsearch $::SNFG::Glc_common $res] >= 0 || [lsearch $::SNFG::Glc_charmm $res] >= 0 || [lsearch $::SNFG::Glc_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist sphere
                        lappend ::SNFG::sizelist $::SNFG::sphere_size
                        lappend ::SNFG::color1list blue
                        lappend ::SNFG::color2list blue
                        puts "$res: Glucose (blue sphere)"
		# Mannose (green sphere)
		} elseif {[lsearch $::SNFG::Man_common $res] >= 0 || [lsearch $::SNFG::Man_charmm $res] >= 0 || [lsearch $::SNFG::Man_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist sphere
                        lappend ::SNFG::sizelist $::SNFG::sphere_size
                        lappend ::SNFG::color1list green
                        lappend ::SNFG::color2list green
                        puts "$res: Mannose (green sphere)"
		# Galactose (yellow sphere)
		} elseif {[lsearch $::SNFG::Gal_common $res] >= 0 || [lsearch $::SNFG::Gal_charmm $res] >= 0 || [lsearch $::SNFG::Gal_glycam $res] >= 0} {
			lappend ::SNFG::shapelist sphere
			lappend ::SNFG::sizelist $::SNFG::sphere_size
			lappend ::SNFG::color1list yellow
			lappend ::SNFG::color2list yellow
			puts "$res: Galactose (yellow sphere)"
		# Gulose (orange sphere)
		} elseif {[lsearch $::SNFG::Gul_common $res] >= 0 || [lsearch $::SNFG::Gul_charmm $res] >= 0 || [lsearch $::SNFG::Gul_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist sphere
                        lappend ::SNFG::sizelist $::SNFG::sphere_size
                        lappend ::SNFG::color1list orange 
                        lappend ::SNFG::color2list orange
                        puts "$res: Galactose (orange sphere)"
		# Altrose (pink sphere)
                } elseif {[lsearch $::SNFG::Alt_common $res] >= 0 || [lsearch $::SNFG::Alt_charmm $res] >= 0 || [lsearch $::SNFG::Alt_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist sphere
                        lappend ::SNFG::sizelist $::SNFG::sphere_size
                        lappend ::SNFG::color1list pink 
                        lappend ::SNFG::color2list pink
			puts "$res: Altrose (pink sphere)"
                # Allose (purple sphere)
                } elseif {[lsearch $::SNFG::All_common $res] >= 0 || [lsearch $::SNFG::All_charmm $res] >= 0 || [lsearch $::SNFG::All_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist sphere
                        lappend ::SNFG::sizelist $::SNFG::sphere_size
                        lappend ::SNFG::color1list purple 
                        lappend ::SNFG::color2list purple
			puts "$res: Allose (purple sphere)"
                # Talose (light blue sphere)
                } elseif {[lsearch $::SNFG::Tal_common $res] >= 0 || [lsearch $::SNFG::Tal_charmm $res] >= 0 || [lsearch $::SNFG::Tal_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist sphere
                        lappend ::SNFG::sizelist $::SNFG::sphere_size
                        lappend ::SNFG::color1list cyan 
                        lappend ::SNFG::color2list cyan
                        puts "$res: Talose (light blue sphere)" 
                # Idose (brown sphere)
                } elseif {[lsearch $::SNFG::Ido_common $res] >= 0 || [lsearch $::SNFG::Ido_charmm $res] >= 0 || [lsearch $::SNFG::Ido_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist sphere
                        lappend ::SNFG::sizelist $::SNFG::sphere_size
                        lappend ::SNFG::color1list tan 
                        lappend ::SNFG::color2list tan 
                        puts "$res: Idose (brown sphere)" 
		### Filled cube 
		# N-acetyl-glucosamine (blue cube)
                } elseif {[lsearch $::SNFG::GlcNAc_common $res] >= 0 || [lsearch $::SNFG::GlcNAc_charmm $res] >= 0 || [lsearch $::SNFG::GlcNAc_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cube 
                        lappend ::SNFG::sizelist $::SNFG::cube_size
                        lappend ::SNFG::color1list blue 
                        lappend ::SNFG::color2list blue
                        puts "$res: N-acetyl-glucosamine (blue cube)"
		# N-acetyl-mannosamine (green cube)
                } elseif {[lsearch $::SNFG::ManNAc_common $res] >= 0 || [lsearch $::SNFG::ManNAc_charmm $res] >= 0 || [lsearch $::SNFG::ManNAc_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cube
                        lappend ::SNFG::sizelist $::SNFG::cube_size
                        lappend ::SNFG::color1list green 
                        lappend ::SNFG::color2list green
			puts "$res: N-acetyl-mannosamine (green cube)"
		# N-acetyl-galactosamine (yellow cube)
                } elseif {[lsearch $::SNFG::GalNAc_common $res] >= 0 || [lsearch $::SNFG::GalNAc_charmm $res] >= 0 || [lsearch $::SNFG::GalNAc_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cube
                        lappend ::SNFG::sizelist $::SNFG::cube_size
                        lappend ::SNFG::color1list yellow 
                        lappend ::SNFG::color2list yellow
			puts "$res: N-acetyl-galactosamine (yellow cube)"
                # N-acetyl-gulosamine (orange cube)
                } elseif {[lsearch $::SNFG::GulNAc_common $res] >= 0 || [lsearch $::SNFG::GulNAc_charmm $res] >= 0 || [lsearch $::SNFG::GulNAc_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cube
                        lappend ::SNFG::sizelist $::SNFG::cube_size
                        lappend ::SNFG::color1list orange 
                        lappend ::SNFG::color2list orange
                        puts "$res: N-acetyl-gulosamine (orange cube)"
		# N-acetyl-altrosamine (pink cube)
                } elseif {[lsearch $::SNFG::AltNAc_common $res] >= 0 || [lsearch $::SNFG::AltNAc_charmm $res] >= 0 || [lsearch $::SNFG::AltNAc_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cube
                        lappend ::SNFG::sizelist $::SNFG::cube_size
                        lappend ::SNFG::color1list pink 
                        lappend ::SNFG::color2list pink 
			puts "$res: N-acetyl-altrosamine (pink cube)" 
                # N-acetyl-allosamine (purple cube)
                } elseif {[lsearch $::SNFG::AllNAc_common $res] >= 0 || [lsearch $::SNFG::AllNAc_charmm $res] >= 0 || [lsearch $::SNFG::AllNAc_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cube
                        lappend ::SNFG::sizelist $::SNFG::cube_size
                        lappend ::SNFG::color1list purple 
                        lappend ::SNFG::color2list purple
			puts "$res: N-acetyl-allosamine (purple cube)"
                # N-acetyl-talosamine (light blue cube)
                } elseif {[lsearch $::SNFG::TalNAc_common $res] >= 0 || [lsearch $::SNFG::TalNAc_charmm $res] >= 0 || [lsearch $::SNFG::TalNAc_glycam $res] >= 0} {                        
			lappend ::SNFG::shapelist cube                        
			lappend ::SNFG::sizelist $::SNFG::cube_size
                        lappend ::SNFG::color1list cyan 
                        lappend ::SNFG::color2list cyan
                        puts "$res: N-acetyl-talosamine (light blue cube)"
                # N-acetyl-idosamine (brown cube)
                } elseif {[lsearch $::SNFG::IdoNAc_common $res] >= 0 || [lsearch $::SNFG::IdoNAc_charmm $res] >= 0 || [lsearch $::SNFG::IdoNAc_glycam $res] >= 0} {                        
                        lappend ::SNFG::shapelist cube
                        lappend ::SNFG::sizelist $::SNFG::cube_size
                        lappend ::SNFG::color1list tan 
                        lappend ::SNFG::color2list tan
                        puts "$res: N-acetyl-idosamine (brown cube)"
		### Crossed cube
		# Glucosamine (white\blue cube)
                } elseif {[lsearch $::SNFG::GlcN_common $res] >= 0 || [lsearch $::SNFG::GlcN_charmm $res] >= 0 || [lsearch $::SNFG::GlcN_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cube
                        lappend ::SNFG::sizelist $::SNFG::cube_size
                        lappend ::SNFG::color1list white 
                        lappend ::SNFG::color2list blue
                        puts "$res: Glucosamine (white\\blue cube)" 
		# Mannosamine (white\green cube)
                } elseif {[lsearch $::SNFG::ManN_common $res] >= 0 || [lsearch $::SNFG::ManN_charmm $res] >= 0 || [lsearch $::SNFG::ManN_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cube
                        lappend ::SNFG::sizelist $::SNFG::cube_size
                        lappend ::SNFG::color1list white
                        lappend ::SNFG::color2list green 
                        puts "$res: Mannosamine (white\\green cube)"
		# Galactosamine (white\yellow cube)
                } elseif {[lsearch $::SNFG::GalN_common $res] >= 0 || [lsearch $::SNFG::GalN_charmm $res] >= 0 || [lsearch $::SNFG::GalN_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cube
                        lappend ::SNFG::sizelist $::SNFG::cube_size
                        lappend ::SNFG::color1list white
                        lappend ::SNFG::color2list yellow 
                        puts "$res: Galactosamine (white\\yellow cube)" 
		# Gulosamine (white\orange cube)
                } elseif {[lsearch $::SNFG::GulN_common $res] >= 0 || [lsearch $::SNFG::GulN_charmm $res] >= 0 || [lsearch $::SNFG::GulN_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cube
                        lappend ::SNFG::sizelist $::SNFG::cube_size
                        lappend ::SNFG::color1list white
                        lappend ::SNFG::color2list orange 
			puts "$res: Gulosamine (white\\orange cube)"
		# Altrosamine (white\pink cube)
                } elseif {[lsearch $::SNFG::AltN_common $res] >= 0 || [lsearch $::SNFG::AltN_charmm $res] >= 0 || [lsearch $::SNFG::AltN_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cube
                        lappend ::SNFG::sizelist $::SNFG::cube_size
                        lappend ::SNFG::color1list white
                        lappend ::SNFG::color2list pink 
                        puts "$res: Altrosamine (white\\pink cube)" 
		# Allosamine (white\purple cube)
                } elseif {[lsearch $::SNFG::AllN_common $res] >= 0 || [lsearch $::SNFG::AllN_charmm $res] >= 0 || [lsearch $::SNFG::AllN_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cube
                        lappend ::SNFG::sizelist $::SNFG::cube_size
                        lappend ::SNFG::color1list white
                        lappend ::SNFG::color2list purple
			puts "$res: Allosamine (white\\purple cube)"
		# Talosamine (white\light blue cube)
                } elseif {[lsearch $::SNFG::TalN_common $res] >= 0 || [lsearch $::SNFG::TalN_charmm $res] >= 0 || [lsearch $::SNFG::TalN_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cube
                        lappend ::SNFG::sizelist $::SNFG::cube_size
                        lappend ::SNFG::color1list white
                        lappend ::SNFG::color2list cyan 
			puts "$res: Talosamine (white\\light blue cube)"
		# Idosamine (white\brown cube)
                } elseif {[lsearch $::SNFG::IdoN_common $res] >= 0 || [lsearch $::SNFG::IdoN_charmm $res] >= 0 || [lsearch $::SNFG::IdoN_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cube
                        lappend ::SNFG::sizelist $::SNFG::cube_size
                        lappend ::SNFG::color1list white
                        lappend ::SNFG::color2list tan 
                        puts "$res: Idosamine (white\\brown cube)"
		### Divided diamond
		# Glucuronic acid (blue-white diamond)
                } elseif {[lsearch $::SNFG::GlcA_common $res] >= 0 || [lsearch $::SNFG::GlcA_charmm $res] >= 0 || [lsearch $::SNFG::GlcA_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist diamond 
                        lappend ::SNFG::sizelist $::SNFG::diamond_size
                        lappend ::SNFG::color1list blue 
                        lappend ::SNFG::color2list white
                        puts "$res: Glucuronic acid (blue-white diamond)" 
		# Mannuronic acid (green-white diamond)
                } elseif {[lsearch $::SNFG::ManA_common $res] >= 0 || [lsearch $::SNFG::ManA_charmm $res] >= 0 || [lsearch $::SNFG::ManA_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist diamond
                        lappend ::SNFG::sizelist $::SNFG::diamond_size
                        lappend ::SNFG::color1list green 
                        lappend ::SNFG::color2list white
                        puts "$res: Mannuronic acid (green-white diamond)"
		# Galacturonic acid (yellow-white diamond)
                } elseif {[lsearch $::SNFG::GalA_common $res] >= 0 || [lsearch $::SNFG::GalA_charmm $res] >= 0 || [lsearch $::SNFG::GalA_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist diamond
                        lappend ::SNFG::sizelist $::SNFG::diamond_size
                        lappend ::SNFG::color1list yellow 
                        lappend ::SNFG::color2list white
                        puts "$res: Galacturonic acid (yellow-white diamond)"
		# Guluronic acid (orange-white diamond)
                } elseif {[lsearch $::SNFG::GulA_common $res] >= 0 || [lsearch $::SNFG::GulA_charmm $res] >= 0 || [lsearch $::SNFG::GulA_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist diamond
                        lappend ::SNFG::sizelist $::SNFG::diamond_size
                        lappend ::SNFG::color1list orange 
                        lappend ::SNFG::color2list white
			puts "$res: Guluronic acid (orange-white diamond)"
		# Altruronic acid (white-pink diamond) 
                } elseif {[lsearch $::SNFG::AltA_common $res] >= 0 || [lsearch $::SNFG::AltA_charmm $res] >= 0 || [lsearch $::SNFG::AltA_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist diamond
                        lappend ::SNFG::sizelist $::SNFG::diamond_size
                        lappend ::SNFG::color1list white 
                        lappend ::SNFG::color2list pink 
                        puts "$res: Altruronic acid (white-pink diamond)" 
		# Alluronic acid (purple-white diamond)
                } elseif {[lsearch $::SNFG::AllA_common $res] >= 0 || [lsearch $::SNFG::AllA_charmm $res] >= 0 || [lsearch $::SNFG::AllA_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist diamond
                        lappend ::SNFG::sizelist $::SNFG::diamond_size
                        lappend ::SNFG::color1list purple 
                        lappend ::SNFG::color2list white
                        puts "$res: Alluronic acid (purple-white diamond)"
		# Taluronic acid (light blue-white diamond)
                } elseif {[lsearch $::SNFG::TalA_common $res] >= 0 || [lsearch $::SNFG::TalA_charmm $res] >= 0 || [lsearch $::SNFG::TalA_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist diamond
                        lappend ::SNFG::sizelist $::SNFG::diamond_size
                        lappend ::SNFG::color1list cyan
                        lappend ::SNFG::color2list white
                        puts "$res: Taluronic acid (light blue-white diamond)" 
		# Iduronic acid (white-brown diamond)
                } elseif {[lsearch $::SNFG::IdoA_common $res] >= 0 || [lsearch $::SNFG::IdoA_charmm $res] >= 0 || [lsearch $::SNFG::IdoA_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist diamond
                        lappend ::SNFG::sizelist $::SNFG::diamond_size
                        lappend ::SNFG::color1list white 
                        lappend ::SNFG::color2list tan
                        puts "$res: Iduronic acid (white-brown diamond)"
		### Filled cone
		# Quinovose (blue cone)
                } elseif {[lsearch $::SNFG::Qui_common $res] >= 0 || [lsearch $::SNFG::Qui_charmm $res] >= 0 || [lsearch $::SNFG::Qui_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cone
                        lappend ::SNFG::sizelist $::SNFG::cone_size
                        lappend ::SNFG::color1list blue
                        lappend ::SNFG::color2list blue
                        puts "$res: Quinovose (blue cone)" 
                # Quinovose (blue cone)
                } elseif {[lsearch $::SNFG::Qui_common $res] >= 0 || [lsearch $::SNFG::Qui_charmm $res] >= 0 || [lsearch $::SNFG::Qui_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cone
                        lappend ::SNFG::sizelist $::SNFG::cone_size
                        lappend ::SNFG::color1list blue
                        lappend ::SNFG::color2list blue
                        puts "$res: Quinovose (blue cone)"
		# Rhamnose (green cone)
                } elseif {[lsearch $::SNFG::Rha_common $res] >= 0 || [lsearch $::SNFG::Rha_charmm $res] >= 0 || [lsearch $::SNFG::Rha_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cone
                        lappend ::SNFG::sizelist $::SNFG::cone_size
                        lappend ::SNFG::color1list green
                        lappend ::SNFG::color2list green
                        puts "$res: Rhamnose (green cone)"
		# 6-Deoxy-altrose (pink cone)
                } elseif {[lsearch $::SNFG::x6dAlt_common $res] >= 0 || [lsearch $::SNFG::x6dAlt_charmm $res] >= 0 || [lsearch $::SNFG::x6dAlt_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cone
                        lappend ::SNFG::sizelist $::SNFG::cone_size
                        lappend ::SNFG::color1list pink
                        lappend ::SNFG::color2list pink 
                        puts "$res: 6-Deoxy-altrose (pink cone)"
		# 6-Deoxy-talose (light blue cone)
                } elseif {[lsearch $::SNFG::x6dTal_common $res] >= 0 || [lsearch $::SNFG::x6dTal_charmm $res] >= 0 || [lsearch $::SNFG::x6dTal_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cone
                        lappend ::SNFG::sizelist $::SNFG::cone_size
                        lappend ::SNFG::color1list cyan
                        lappend ::SNFG::color2list cyan
                        puts "$res: 6-Deoxy-talose (light blue cone)" 
		# Fucose (red cone)
                } elseif {[lsearch $::SNFG::Fuc_common $res] >= 0 || [lsearch $::SNFG::Fuc_charmm $res] >= 0 || [lsearch $::SNFG::Fuc_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cone
                        lappend ::SNFG::sizelist $::SNFG::cone_size
                        lappend ::SNFG::color1list red
                        lappend ::SNFG::color2list red
                        puts "$res: Fucose (red cone)" 
		### Divided cone
		# N-Acetyl-quinovosamine (white|blue cone)
                } elseif {[lsearch $::SNFG::QuiNAc_common $res] >= 0 || [lsearch $::SNFG::QuiNAc_charmm $res] >= 0 || [lsearch $::SNFG::QuiNAc_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cone
                        lappend ::SNFG::sizelist $::SNFG::cone_size
                        lappend ::SNFG::color1list white
                        lappend ::SNFG::color2list blue
                        puts "$res: N-Acetyl-quinovosamine (white|blue cone)"
		# N-Acetyl-rhamnosamine (white|green cone)
                } elseif {[lsearch $::SNFG::RhaNAc_common $res] >= 0 || [lsearch $::SNFG::RhaNAc_charmm $res] >= 0 || [lsearch $::SNFG::RhaNAc_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cone
                        lappend ::SNFG::sizelist $::SNFG::cone_size
                        lappend ::SNFG::color1list white
                        lappend ::SNFG::color2list green
                        puts "$res: N-Acetyl-rhamnosamine (white|green cone)" 
		# N-Acetyl-fucosamine (white|red cone)
                } elseif {[lsearch $::SNFG::FucNAc_common $res] >= 0 || [lsearch $::SNFG::FucNAc_charmm $res] >= 0 || [lsearch $::SNFG::FucNAc_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist cone
                        lappend ::SNFG::sizelist $::SNFG::cone_size
                        lappend ::SNFG::color1list white
                        lappend ::SNFG::color2list red
                        puts "$res: N-Acetyl-fucosamine (white|red cone)" 
		### Flat rectangle
		# Olivose (blue rectangle)
                } elseif {[lsearch $::SNFG::Oli_common $res] >= 0 || [lsearch $::SNFG::Oli_charmm $res] >= 0 || [lsearch $::SNFG::Oli_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist rectangle
                        lappend ::SNFG::sizelist $::SNFG::rectangle_size
                        lappend ::SNFG::color1list blue
                        lappend ::SNFG::color2list blue
                        puts "$res: Olivose (blue rectangle)"
		# Tyvelose (green rectangle)
                } elseif {[lsearch $::SNFG::Tyv_common $res] >= 0 || [lsearch $::SNFG::Tyv_charmm $res] >= 0 || [lsearch $::SNFG::Tyv_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist rectangle
                        lappend ::SNFG::sizelist $::SNFG::rectangle_size
                        lappend ::SNFG::color1list green
                        lappend ::SNFG::color2list green
                        puts "$res: Tyvelose (green rectangle)"
		# Abequose (orange rectangle)
                } elseif {[lsearch $::SNFG::Abe_common $res] >= 0 || [lsearch $::SNFG::Abe_charmm $res] >= 0 || [lsearch $::SNFG::Abe_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist rectangle
                        lappend ::SNFG::sizelist $::SNFG::rectangle_size
                        lappend ::SNFG::color1list orange
                        lappend ::SNFG::color2list orange
                        puts "$res: Abequose (orange rectangle)"
		# Paratose (pink rectangle)
                } elseif {[lsearch $::SNFG::Par_common $res] >= 0 || [lsearch $::SNFG::Par_charmm $res] >= 0 || [lsearch $::SNFG::Par_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist rectangle
                        lappend ::SNFG::sizelist $::SNFG::rectangle_size
                        lappend ::SNFG::color1list pink
                        lappend ::SNFG::color2list pink
                        puts "$res: Paratose (pink rectangle)"
		# Digitoxose (purple rectangle)
                } elseif {[lsearch $::SNFG::Dig_common $res] >= 0 || [lsearch $::SNFG::Dig_charmm $res] >= 0 || [lsearch $::SNFG::Dig_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist rectangle
                        lappend ::SNFG::sizelist $::SNFG::rectangle_size
                        lappend ::SNFG::color1list purple
                        lappend ::SNFG::color2list purple
                        puts "$res: Digitoxose (purple rectangle)" 
		# Colitose (light blue rectangle)
                } elseif {[lsearch $::SNFG::Col_common $res] >= 0 || [lsearch $::SNFG::Col_charmm $res] >= 0 || [lsearch $::SNFG::Col_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist rectangle
                        lappend ::SNFG::sizelist $::SNFG::rectangle_size
                        lappend ::SNFG::color1list cyan
                        lappend ::SNFG::color2list cyan
                        puts "$res: Colitose (light blue rectangle)" 
		### Filled star
		# Arabinose (green star)
                } elseif {[lsearch $::SNFG::Ara_common $res] >= 0 || [lsearch $::SNFG::Ara_charmm $res] >= 0 || [lsearch $::SNFG::Ara_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist star
                        lappend ::SNFG::sizelist $::SNFG::star_size
                        lappend ::SNFG::color1list green
                        lappend ::SNFG::color2list green
                        puts "$res: Arabinose (green star)" 
		# Lyxose (yellow star)
                } elseif {[lsearch $::SNFG::Lyx_common $res] >= 0 || [lsearch $::SNFG::Lyx_charmm $res] >= 0 || [lsearch $::SNFG::Lyx_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist star
                        lappend ::SNFG::sizelist $::SNFG::star_size
                        lappend ::SNFG::color1list yellow
                        lappend ::SNFG::color2list yellow
                        puts "$res: Lyxose (yellow star)"
		# Xylose (orange star)
                } elseif {[lsearch $::SNFG::Xyl_common $res] >= 0 || [lsearch $::SNFG::Xyl_charmm $res] >= 0 || [lsearch $::SNFG::Xyl_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist star
                        lappend ::SNFG::sizelist $::SNFG::star_size
                        lappend ::SNFG::color1list orange
                        lappend ::SNFG::color2list orange
                        puts "$res: Xylose (orange star)" 
		# Ribose (pink star)
                } elseif {[lsearch $::SNFG::Rib_common $res] >= 0 || [lsearch $::SNFG::Rib_charmm $res] >= 0 || [lsearch $::SNFG::Rib_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist star
                        lappend ::SNFG::sizelist $::SNFG::star_size
                        lappend ::SNFG::color1list pink
                        lappend ::SNFG::color2list pink
                        puts "$res: Ribose (pink star)"
		### Filled diamond
		# Ketodeoxynononic acid (green diamond)
                } elseif {[lsearch $::SNFG::Kdn_common $res] >= 0 || [lsearch $::SNFG::Kdn_charmm $res] >= 0 || [lsearch $::SNFG::Kdn_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist diamond
                        lappend ::SNFG::sizelist $::SNFG::diamond_size
                        lappend ::SNFG::color1list green
                        lappend ::SNFG::color2list green
                        puts "$res: Ketodeoxynononic acid (green diamond)" 
		# N-Acetylneuraminic acid (purple diamond)
                } elseif {[lsearch $::SNFG::Neu5Ac_common $res] >= 0 || [lsearch $::SNFG::Neu5Ac_charmm $res] >= 0 || [lsearch $::SNFG::Neu5Ac_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist diamond
                        lappend ::SNFG::sizelist $::SNFG::diamond_size
                        lappend ::SNFG::color1list purple
                        lappend ::SNFG::color2list purple
                        puts "$res: N-Acetylneuraminic acid (purple diamond)"
		# N-Glycolylneuraminic acid (light blue diamond)
                } elseif {[lsearch $::SNFG::Neu5Gc_common $res] >= 0 || [lsearch $::SNFG::Neu5Gc_charmm $res] >= 0 || [lsearch $::SNFG::Neu5Gc_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist diamond
                        lappend ::SNFG::sizelist $::SNFG::diamond_size
                        lappend ::SNFG::color1list cyan
                        lappend ::SNFG::color2list cyan
                        puts "$res: N-Glycolylneuraminic acid (light blue diamond)" 
		# Neuraminic acid (brown diamond)
                } elseif {[lsearch $::SNFG::Neu_common $res] >= 0 || [lsearch $::SNFG::Neu_charmm $res] >= 0 || [lsearch $::SNFG::Neu_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist diamond
                        lappend ::SNFG::sizelist $::SNFG::diamond_size
                        lappend ::SNFG::color1list tan
                        lappend ::SNFG::color2list tan
                        puts "$res: Neuraminic acid (brown diamond)"
		### Flat hexagon
		# Bacillosamine (blue hexagon)
                } elseif {[lsearch $::SNFG::Bac_common $res] >= 0 || [lsearch $::SNFG::Bac_charmm $res] >= 0 || [lsearch $::SNFG::Bac_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist hexagon
                        lappend ::SNFG::sizelist $::SNFG::hexagon_size
                        lappend ::SNFG::color1list blue
                        lappend ::SNFG::color2list blue
                        puts "$res: Bacillosamine (blue hexagon)"
		# L-glycero-D-manno-Heptose (green hexagon)
                } elseif {[lsearch $::SNFG::LDManHep_common $res] >= 0 || [lsearch $::SNFG::LDManHep_charmm $res] >= 0 || [lsearch $::SNFG::LDManHep_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist hexagon
                        lappend ::SNFG::sizelist $::SNFG::hexagon_size
                        lappend ::SNFG::color1list green
                        lappend ::SNFG::color2list green
                        puts "$res: L-glycero-D-manno-Heptose (green hexagon)"
		# Ketodeoxyoctonic acid (yellow hexagon)
                } elseif {[lsearch $::SNFG::Kdo_common $res] >= 0 || [lsearch $::SNFG::Kdo_charmm $res] >= 0 || [lsearch $::SNFG::Kdo_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist hexagon
                        lappend ::SNFG::sizelist $::SNFG::hexagon_size
                        lappend ::SNFG::color1list yellow
                        lappend ::SNFG::color2list yellow
                        puts "$res: Ketodeoxyoctonic acid (yellow hexagon)"
		# 3-Deoxy-lyxo-heptulosaric acid (orange hexagon)
                } elseif {[lsearch $::SNFG::Dha_common $res] >= 0 || [lsearch $::SNFG::Dha_charmm $res] >= 0 || [lsearch $::SNFG::Dha_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist hexagon
                        lappend ::SNFG::sizelist $::SNFG::hexagon_size
                        lappend ::SNFG::color1list orange
                        lappend ::SNFG::color2list orange
                        puts "$res: 3-Deoxy-lyxo-heptulosaric acid (orange hexagon)" 
		# D-glycero-D-manno-Heptose (pink hexagon)
                } elseif {[lsearch $::SNFG::DDManHep_common $res] >= 0 || [lsearch $::SNFG::DDManHep_charmm $res] >= 0 || [lsearch $::SNFG::DDManHep_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist hexagon
                        lappend ::SNFG::sizelist $::SNFG::hexagon_size
                        lappend ::SNFG::color1list pink
                        lappend ::SNFG::color2list pink
 			puts "$res: D-glycero-D-manno-Heptose (pink hexagon)"
		# N-Acetylmuramic acid (purple hexagon)
                } elseif {[lsearch $::SNFG::MurNAc_common $res] >= 0 || [lsearch $::SNFG::MurNAc_charmm $res] >= 0 || [lsearch $::SNFG::MurNAc_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist hexagon
                        lappend ::SNFG::sizelist $::SNFG::hexagon_size
                        lappend ::SNFG::color1list purple
                        lappend ::SNFG::color2list purple
                        puts "$res: N-Acetylmuramic acid (purple hexagon)"
		# N-Glycolylmuramic acid (light blue hexagon)
                } elseif {[lsearch $::SNFG::MurNGc_common $res] >= 0 || [lsearch $::SNFG::MurNGc_charmm $res] >= 0 || [lsearch $::SNFG::MurNGc_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist hexagon
                        lappend ::SNFG::sizelist $::SNFG::hexagon_size
                        lappend ::SNFG::color1list cyan
                        lappend ::SNFG::color2list cyan
                        puts "$res: N-Glycolylmuramic acid (light blue hexagon)"
		# Muramic acid (brown hexagon)
                } elseif {[lsearch $::SNFG::Mur_common $res] >= 0 || [lsearch $::SNFG::Mur_charmm $res] >= 0 || [lsearch $::SNFG::Mur_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist hexagon
                        lappend ::SNFG::sizelist $::SNFG::hexagon_size
                        lappend ::SNFG::color1list tan
                        lappend ::SNFG::color2list tan
                        puts "$res: Muramic acid (brown hexagon)"
		### Pentagon
		# Apiose (blue pentagon)
                } elseif {[lsearch $::SNFG::Api_common $res] >= 0 || [lsearch $::SNFG::Api_charmm $res] >= 0 || [lsearch $::SNFG::Api_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist pentagon
                        lappend ::SNFG::sizelist $::SNFG::pentagon_size
                        lappend ::SNFG::color1list blue
                        lappend ::SNFG::color2list blue
                        puts "$res: Apiose (blue pentagon)"
		# Fructose (green pentagon)
                } elseif {[lsearch $::SNFG::Fruc_common $res] >= 0 || [lsearch $::SNFG::Fruc_charmm $res] >= 0 || [lsearch $::SNFG::Fruc_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist pentagon
                        lappend ::SNFG::sizelist $::SNFG::pentagon_size
                        lappend ::SNFG::color1list green
                        lappend ::SNFG::color2list green
                        puts "$res: Fructose (green pentagon)"
		# Tagatose (yellow pentagon)
                } elseif {[lsearch $::SNFG::Tag_common $res] >= 0 || [lsearch $::SNFG::Tag_charmm $res] >= 0 || [lsearch $::SNFG::Tag_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist pentagon
                        lappend ::SNFG::sizelist $::SNFG::pentagon_size
                        lappend ::SNFG::color1list yellow
                        lappend ::SNFG::color2list yellow
                        puts "$res: Tagatose (yellow pentagon)"
		# Sorbose (orange pentagon)
                } elseif {[lsearch $::SNFG::Sor_common $res] >= 0 || [lsearch $::SNFG::Sor_charmm $res] >= 0 || [lsearch $::SNFG::Sor_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist pentagon
                        lappend ::SNFG::sizelist $::SNFG::pentagon_size
                        lappend ::SNFG::color1list orange
                        lappend ::SNFG::color2list orange
                        puts "$res: Sorbose (orange pentagon)" 
		# Psicose (pink pentagon)
                } elseif {[lsearch $::SNFG::Psi_common $res] >= 0 || [lsearch $::SNFG::Psi_charmm $res] >= 0 || [lsearch $::SNFG::Psi_glycam $res] >= 0} {
                        lappend ::SNFG::shapelist pentagon
                        lappend ::SNFG::sizelist $::SNFG::pentagon_size
                        lappend ::SNFG::color1list pink
                        lappend ::SNFG::color2list pink
                        puts "$res: Psicose (pink pentagon)" 
	        } else {
	                lappend ::SNFG::shapelist hexagon 
	                lappend ::SNFG::sizelist $::SNFG::hexagon_size
	                lappend ::SNFG::color1list white 
	                lappend ::SNFG::color2list white 
			puts "$res: Unknown/unsupported" 
		}
		$ringatoms delete

		# Set resname colors to non-white for supported residues, white for unknown
		set color1 [lindex $::SNFG::color1list $i]
		set color2 [lindex $::SNFG::color2list $i]

		if {$color1 != "white"} {
			set rescolor $color1
		} else {
			set rescolor $color2 
		}
		color Resname "$res" $rescolor

		# Deal with coloring of GLYCAM reducing-terminal and glycoprotein residues
		if {$res == $::SNFG::ROH_att} { ; # Hydroxyl
			color Resname "ROH" $rescolor ; # Same color as attached residue
		}
		if {[lsearch $toplist "OME"] >= 0 } { ; # O-methyl
			color Resname "OME" white 
		}
		if {[lsearch $toplist "TBT"] >= 0 } { ; # Tert-butyl
			color Resname "TBT" white 
		}
		if {[lsearch $toplist "NLN"] >= 0 } { ; # ASN for N-linked glycoprotein
			color Resname "NLN" tan ; # Default color setting of ASN
		}
		if {[lsearch $toplist "OLS"] >= 0 } { ; # SER for O-linked glycoprotein
			color Resname "OLS" yellow ; # Default color setting of THR
		}
		if {[lsearch $toplist "OLT"] >= 0 } { ; # THR for O-linked glycoprotein
			color Resname "OLT" mauve ; # Default color setting of THR
		}
		if {[lsearch $toplist "ZOLS"] >= 0 } { ; # Zwitterion SER for N-linked glycoprotein
			color Resname "ZOLS" yellow ; # Default color setting of SER
		}
		if {[lsearch $toplist "ZOLT"] >= 0 } { ; # Zwitterion THR for N-linked glycoprotein
			color Resname "ZOLT" mauve ; # Default color setting of THR
		}

		incr i
	}
}

# Proc to print help message
proc snfg-help {} {
	puts "\n3D-SNFG capability imported!"
	puts "See http://glycam.org/3d-snfg for full documentation."
	puts "===============\n"
	puts "Useful command-line procedures:"
	puts "\nsnfg-enable icon/full/fullred"
	puts "  Enable 3D-SNFG drawing for top molecule, choosing icon or full size shapes."
	puts "  Full size shapes have an additional option to denote the reducing terminal."
	puts "  Also outputs a list of glycan residues detected for top molecule."
	puts "  Default keyboard shortcut for icon size: i"
	puts "  Default keyboard shortcut for full size: g"
	puts "  Default keyboard shortcut for full size with reducing terminus: b"
	puts "\nsnfg-disable"
	puts "  Turn off 3D-SNFG drawing for top molecule."
	puts "  Default keyboard shortcut: d"
	puts "\nsnfg-colors"
	puts "  Apply official 3D-SNFG colors."
	puts "\nsnfg-resetcolors"
	puts "  Reset colors to VMD defaults. Colors are also reset by snfg-disable."
	puts "\nsnfg-help"
	puts "  Print this message again for a list of command-line procedures."
	puts "===============\n"
}
snfg-help

# SNFG keyboard shortcuts 
# user add key g {snfg-enable full ; snfg-colors}
# user add key b {snfg-enable fullred ; snfg-colors}
# user add key i {snfg-enable icon ; snfg-colors}
# user add key d {snfg-disable}

