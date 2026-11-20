*************************************
*Replication code for Ewens Xiao and Xu 2023
*************************************
****************
* Table 5
****************

* Panel A
**********
/*
First, 
run Matlab code Table5a.m, which outputs heterogeneity_local_res.xlsx into $output
run Matlab code Table5b.m, which outputs heterogeneity_local_time.xlsx into $output
*/

import excel "$output/heterogeneity_local_time.xlsx", sheet("Sheet1") clear
save $output/temp, replace
import excel "$output/heterogeneity_local_res.xlsx", sheet("Sheet1") clear
append using $output/temp

rename (A-F) (k_25 k_75 k_700 k2pv_25 k2pv_75 k2pv_700)
drop if _n==13 | _n==14
g sample=""
order sample
replace sample="Low Tobin's Q" if _n==1
replace sample="High Tobin's Q" if _n==2
replace sample="Low tangibility" if _n==3
replace sample="High tangibility" if _n==4
replace sample="Low HP competition" if _n==5
replace sample="High HP competition" if _n==6
replace sample="Non-manufac." if _n==7
replace sample="Manufac." if _n==8
replace sample="Non-fin. or utility" if _n==9
replace sample="Fin & utility" if _n==10
replace sample="Low ROA" if _n==11
replace sample="High ROA" if _n==12
replace sample="Low cash ratio" if _n==13
replace sample="High cash ratio" if _n==14
replace sample="Low turnover" if _n==15
replace sample="High turnover" if _n==16
replace sample="Early sample period" if _n==17
replace sample="Late sample period" if _n==18

*add results from Table 3 as first row
insobs 1, before(1)
replace sample="Baseline" if _n==1
replace k_25=0.022 if _n==1
replace k_75=0.132 if _n==1
replace k_700=0.873 if _n==1
replace k2pv_25=1.205 if _n==1
replace k2pv_75=1.841 if _n==1
replace k2pv_700=1.164 if _n==1

preserve
	foreach x of varlist k_* k2pv_* {
		replace `x'=round(`x', 0.001)
	}
	format k_* k2pv_* %5.3f
	export excel using "$output/Table5a.xlsx", firstrow(variables) keepcellfmt replace
restore
save "$output/Table5a", replace



* Panel B
**********

* Kappa
global covariates tq ppe hp_tsimm sic_manufac sic_finutil roa cashratio turnover

foreach samp in 25 75 700 {
use $input/res_`samp'mil, clear
qui {
	rename _all, lower
	drop res_lnfloat
	matrix A=(0)
	foreach x in $covariates {

	qui: sum res_`x', det
	qui: g byte abovemed_`x'=res_`x'>=r(p50) if res_`x'!=.

	tabstat res_`x', by(abovemed_`x') stat(mean) col(stat) save

	matrix list r(Stat1)
	matrix list r(Stat2)

	matrix A=A\r(Stat1)\r(Stat2)
	}
}
matrix list A
clear
svmat A, names(covmean)
rename covmean1 covmean_`samp'
drop if _n==1
g id=_n
save $output/T5b_covmean_`samp', replace
}

use $output/T5b_covmean_25, clear
foreach samp in 75 700 {
merge 1:1 id using $output/T5b_covmean_`samp', nogen
}
order id
g sample=""
order sample
replace sample="Low Tobin's Q" if _n==1
replace sample="High Tobin's Q" if _n==2
replace sample="Low tangibility" if _n==3
replace sample="High tangibility" if _n==4
replace sample="Low HP competition" if _n==5
replace sample="High HP competition" if _n==6
replace sample="Non-manufac." if _n==7
replace sample="Manufac." if _n==8
replace sample="Non-fin. or utility" if _n==9
replace sample="Fin & utility" if _n==10
replace sample="Low ROA" if _n==11
replace sample="High ROA" if _n==12
replace sample="Low cash ratio" if _n==13
replace sample="High cash ratio" if _n==14
replace sample="Low turnover" if _n==15
replace sample="High turnover" if _n==16

capture erase $output/T5b_covmean_25.dta
capture erase $output/T5b_covmean_75.dta
capture erase $output/T5b_covmean_700.dta

merge 1:1 sample using $output/Table5a, nogen keep(3)
sort id
drop id k2pv*
foreach x in 25 75 700 {
	g kappa_`x'=ln(k_`x'/k_`x'[_n-1])/(covmean_`x'-covmean_`x'[_n-1]) if mod(_n, 2)==0
}
keep if kappa_25!=.
keep sample kappa_*
insobs 1, before(1)
g covariate=subinstr(sample, "High ", "", .)
drop sample
order covariate
replace covariate="Tangibility" if covariate=="tangibility"
replace covariate="Cash ratio" if covariate=="cash ratio"
replace covariate="Turnover" if covariate=="turnover"
replace covariate="Ln(public float)" if covariate==""
/*cost-float elasticity estimates from Table A.5*/
replace kappa_25=0.412 if kappa_25==.
replace kappa_75=0.456 if kappa_75==.
replace kappa_700=0.423 if kappa_700==.
save $output/Table5b_kappa, replace


* Covariate value for marginal firms
use $input/sample_25m if treat==1 & publicfloat_mil>=27  & publicfloat_mil<=33, clear
collapse (median) tq ppe hp_tsimm (mean) sic_manufac sic_finutil  (median) roa cashratio turnover
g threshold=25
g lnfloat=ln(26.869*1000000)
save $output/T5b_25, replace

use $input/sample_75m if treat==1 & publicfloat_mil>=95 & publicfloat_mil<=105, clear
collapse (median) tq ppe hp_tsimm (mean) sic_manufac sic_finutil  (median) roa cashratio turnover
g threshold=75
g lnfloat=ln(94.524*1000000)
save $output/T5b_75, replace

use $input/sample_700m if treat==1 & (publicfloat_mil>=840 & publicfloat_mil<=1000), clear
collapse (median) tq ppe hp_tsimm (mean) sic_manufac sic_finutil (median) roa cashratio turnover
g threshold=700
g lnfloat=ln(833.416*1000000)
save $output/T5b_700, replace

clear
append using $output/T5b_25
append using $output/T5b_75
append using $output/T5b_700
order threshold lnfloat 
xpose, clear
drop if _n==1
rename (v1 v2 v3) (x_25 x_75 x_700)
g id=_n
save $output/Table5b_x, replace

capture erase $output/T5b_25.dta
capture erase $output/T5b_75.dta
capture erase $output/T5b_700.dta


use $output/Table5b_kappa, clear
g id=_n
merge 1:1 id using $output/Table5b_x, nogen
drop id

foreach x of varlist kappa_* x_* {
	replace `x'=round(`x', 0.001)
}
format kappa_* x_* %5.3f
save $output/Table5b, replace



* import bootstrapped estimates and compute std errors
forv x=1/3 {
	if `x'==1 {
	local y=25
	}
	if `x'==2 {
	local y=75 
	}
	if `x'==3 {
	local y=700
	}

	import excel "$input/bootstrap_`x'.csv", sheet("Sheet1") clear
	g replication=_n
	rename (A-R) k#, addnumber
	rename (S-AJ) v#, addnumber
	rename AK k`y'_marginal
	g k`y'tq=(ln(k1/k2))/(v1-v2)
	g k`y'ppe=(ln(k3/k4))/(v3-v4)
	g k`y'hp_tsimm=(ln(k5/k6))/(v5-v6)
	g k`y'sic_manufac=(ln(k7/k8))/(v7-v8)
	g k`y'sic_finutil=(ln(k9/k10))/(v9-v10)
	g k`y'roa=(ln(k11/k12))/(v11-v12)
	g k`y'lnfloat=(ln(k13/k14))/(v13-v14)
	g k`y'cashratio=(ln(k15/k16))/(v15-v16)
	g k`y'turnover=(ln(k17/k18))/(v17-v18)
	drop k1-v18
	save $input/bootstrap_`x', replace
}

use $input/bootstrap_1, clear
merge 1:1 replication using $input/bootstrap_2, nogen
merge 1:1 replication using $input/bootstrap_3, nogen
mdesc
replace k25lnfloat=0.412 
replace k75lnfloat=0.456 
replace k700lnfloat=0.423
compress
isid replication, s
save $input/extrapolate_parameters_res_ln_boot500_v3, replace
capture erase $input/bootstrap_1.dta
capture erase $input/bootstrap_2.dta
capture erase $input/bootstrap_3.dta


use $output/Table5b_x.dta, clear
drop id
drop if _n==1
g id=1
g char=_n
g varname=""
replace varname="tq" if char==1
replace varname="ppe" if char==2
replace varname="hp_tsimm" if char==3
replace varname="sic_manufac" if char==4
replace varname="sic_finutil" if char==5
replace varname="roa" if char==6
replace varname="cashratio" if char==7
replace varname="turnover" if char==8
drop char
rename x_* v*
reshape wide v25 v75 v700, i(id) j(varname) string
drop id
cross using $input/extrapolate_parameters_res_ln_boot500_v3
order replication
isid replication, s
egen nmiss_25=rmiss2(k25*)
egen nmiss_75=rmiss2(k75*)
egen nmiss_700=rmiss2(k700*)
preserve
	collapse (sd) k25tq k25ppe k25hp_tsimm k25sic_manufac k25sic_finutil k25roa k25cashratio k25turnover if nmiss_25==0
	g id=1
	reshape long k25, i(id) j(var) string
	drop id
	save $output/boot_sd_25, replace
restore
preserve
	collapse (sd) k75tq k75ppe k75hp_tsimm k75sic_manufac k75sic_finutil k75roa k75cashratio k75turnover if nmiss_75==0
	g id=1
	reshape long k75, i(id) j(var) string
	drop id
	save $output/boot_sd_75, replace
restore
preserve
	collapse (sd) k700tq k700ppe k700hp_tsimm k700sic_manufac k700sic_finutil k700roa k700cashratio k700turnover if nmiss_700==0
	g id=1
	reshape long k700, i(id) j(var) string
	drop id
	save $output/boot_sd_700, replace
restore

use $output/boot_sd_25, clear
merge 1:1 var using $output/boot_sd_75, nogen
merge 1:1 var using $output/boot_sd_700, nogen
rename k* kappa_sd_*
replace var="Cash ratio" if var=="cashratio"
replace var="Tobin's Q" if var=="tq"
replace var="Tangibility" if var=="ppe"
replace var="HP competition" if var=="hp_tsimm"
replace var="Manufac." if var=="sic_manufac"
replace var="Fin & utility" if var=="sic_finutil"
replace var="ROA" if var=="roa"
replace var="Turnover" if var=="turnover"
insobs 1, before(1)
replace var="Ln(public float)" if var==""
/*sd err of cost-float elasticities from Table A.5*/
replace kappa_sd_25=0.027 if kappa_sd_25==.
replace kappa_sd_75=0.028 if kappa_sd_75==.
replace kappa_sd_700=0.019 if kappa_sd_700==.
foreach x of varlist kappa_sd_* {
	replace `x'=round(`x', 0.001)
}
format kappa_sd_* %5.3f
rename var covariate
save $output/boot_sd, replace


use $output/Table5b, clear
g id=_n
merge 1:1 covariate using $output/boot_sd, nogen
sort id
drop id
forv x=1(2)17 {
insobs 1, after(`x')
}
foreach x in 25 75 700 {
	replace kappa_`x'=kappa_sd_`x'[_n-1] if kappa_`x'==.
	drop kappa_sd_`x'
}
export excel using "$output/Table5b.xlsx", firstrow(variables) keepcellfmt replace



capture erase $output/temp.dta
capture erase $output/Table5b_kappa.dta
capture erase $output/Table5b_x.dta
capture erase $output/Table5b.dta
capture erase $output/Table5a.dta
capture erase $output/boot_sd_25.dta
capture erase $output/boot_sd_75.dta
capture erase $output/boot_sd_700.dta
capture erase $output/boot_sd.dta


