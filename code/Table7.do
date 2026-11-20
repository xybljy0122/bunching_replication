*************************************
*Replication code for Ewens Xiao and Xu 2023
*************************************
****************
* Table 7
****************
use $input/ipo_counterfactual_v3, clear

logit ipo_dummy ln_K_total ln_publicfloat_mil ln_totalRaised age  ///
i.ind_year_fe i.state_fe, cluster(newID)
capture drop p_actual
predict p_actual
keep if e(sample)

g K_actual = K_total

g K_nojobs=K_total
replace K_nojobs= K_er + K_404 + K_sd if ///
year>=2012 & year<=2018 & publicfloat_mil>=75 & publicfloat_mil<700 
replace K_nojobs= K_er if ///
year>=2012 & year<=2018 & publicfloat_mil>=0 & publicfloat_mil<75 
replace ln_K_total = log(K_nojobs)
predict p_nojobs

g K_nosox=K_total
replace K_nosox= K_er + K_sd if ///
(year>=2003 & year<=2018 & publicfloat_mil>=700 & publicfloat_mil<.) | ///
(year>=2003 & year<=2011 & publicfloat_mil>=75 & publicfloat_mil<700) 
replace K_nosox= 1/1000000  if ///
(year>=2012 & year<=2018 & publicfloat_mil>=75 & publicfloat_mil<700) 
replace ln_K_total = log(K_nosox)
predict p_nosox

g K_zerosd=.
replace K_zerosd= 1/1000000  if ///
(year>=2012 & year<=2018 & publicfloat_mil>=0 & publicfloat_mil<700)
replace K_zerosd= K_er + K_404  if ///
(year>=2003 & year<=2018 & publicfloat_mil>=700 & publicfloat_mil<.) | ///
(year>=2003 & year<=2011 & publicfloat_mil>=75 & publicfloat_mil<700) 
replace K_zerosd= K_er if ///
(year>=1992 & year<=2007 & publicfloat_mil>=0 & publicfloat_mil<25) | ///
(year>=2008 & year<=2011 & publicfloat_mil>=0 & publicfloat_mil<75)
replace K_zerosd= K_er if ///
(year>=1992 & year<=2002 & publicfloat_mil>=25 & publicfloat_mil<.) | ///
(year>=2003 & year<=2007 & publicfloat_mil>=25 & publicfloat_mil<75)
replace ln_K_total = log(K_zerosd)
predict p_zerosd

g K_noreg=1/1000000
replace ln_K_total = log(K_noreg) 
predict p_noreg

g K_maxreg=.
*replace K_maxreg = K_er + K_sd
replace K_maxreg = K_er + K_sd if ///
year>=1992 & year<=2002
replace K_maxreg = K_er + K_404 + K_sd if ///
year>=2003 & year<=2018
replace ln_K_total = log(K_maxreg) 
predict p_maxreg

g K_minreg=.
replace K_minreg = K_er  if ///
year>=1992 & year<=2011
replace K_minreg = 1/1000000 if ///
year>=2012 & year<=2018 
replace ln_K_total = log(K_minreg) 
predict p_minreg


foreach x in actual nojobs nosox zerosd noreg minreg maxreg {
g v_`x'=p_`x'*publicfloat_mil
}

g post2000=year>=2000
replace K_noreg=K_actual if post2000==0


drop K_sd K_404 K_egc K_total

foreach var of varlist K_* {
g ratio_`var'=`var'/publicfloat_mil*100
}


foreach var of varlist p_* v_* {
egen totall_`var'=sum(`var'), by(post2000)
egen totyr_`var'=sum(`var'), by(year)
}


foreach var of varlist p_* {
replace `var'=`var'*100
}

foreach var of varlist totall_v_* totyr_v_* {
replace `var'=`var'/1000
}



*Tabulate Counterfactual Simulation of Regulatory Costs and IPOs
collapse K* p_* v_* ratio_* totall_* totyr_*, by(post2000)
reshape long K_ p_ v_ totyr_p_ totall_p_ totall_v_ ratio_K_, i(post2000) j(scenario) string

label var K_ "Regulatory costs (\textdollar m)"
label var ratio_ "Regulatory costs / Public float (\%)"
label var p_ "IPO probability (\%)"
label var totyr_p_ "Yearly no. of IPOs"
label var totall_p_ "Total no. of IPOs"
label var totall_v_ "Total IPO public float (\textdollar b)"
label var v_ "Average IPO public float (\textdollar m)"


*Pre2000
estpost su K_ ratio_ p_ totyr_p_ totall_p_ totall_v_  if scenario== "actual" & post2000==0, d
est store actual_pre

*Post2000
foreach type in actual nosox nojobs noreg {
eststo clear
estpost su K_ ratio_ p_ totyr_p_ totall_p_ totall_v_  if scenario== "`type'" & post2000==1, d
est store `type'
}

esttab actual_pre actual nosox nojobs noreg using "$output/Table7.tex", replace ///
mtitles("{Actual regulation}" "{Actual regulation}" "{No SOX}" "{No JOBS Act}" "{Zero regulation}" ) ///
collabels(none)  width(\hsize) ///
cells("mean(fmt(3))") label nonumber noobs booktabs

/*
Inserting the following Tex code after column titles to adjust table foramt:
& (1)   & (2)   & (3)  & (4)  & (5)  \\
\midrule
& Pre-2000 & \multicolumn{4}{c}{{Post-2000}} \\
\cmidrule(lr){2-2} \cmidrule(lr){3-6} 
*/

