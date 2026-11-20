*************************************
*Replication code for Ewens Xiao and Xu 2023
*************************************
****************
* Figure 7
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


* Counterfactual Simulations
collapse K* p_* totyr_p_*, by(year)

foreach x in p totyr_p {
replace `x'_noreg=`x'_actual if year<2000
}

twoway ///
(line K_actual year, lpattern(solid) lcolor(black) lwidth(medthick) ) || ///
(line K_nojobs year, lpattern(dash) lcolor(black)  lwidth(medthick)  ) || ///
(line K_nosox year, lpattern(shortdash_dot) lcolor(black) lwidth(medthick) ) || ///
(line K_noreg year, lpattern(shortdash) lcolor(black) lwidth(medthick) ), ///
graphregion(color(white)) xlabel(1990(5)2020, nogrid) xtitle("") aspectrati(0.55) ///
legend(label(1 "Actual Regulations") label(2 "No JOBS Act") label(3 "No SOX 404") label(4 "Zero Regulation") col(2) position(6))
graph export $output/Figure7a.png, replace

twoway ///
(line p_actual year, lpattern(solid) lcolor(black) lwidth(medthick) ) || ///
(line p_nojobs year, lpattern(dash) lcolor(black)  lwidth(medthick)  ) || ///
(line p_nosox year, lpattern(shortdash_dot) lcolor(black) lwidth(medthick) ) || ///
(line p_noreg year, lpattern(shortdash) lcolor(black) lwidth(medthick) ), ///
graphregion(color(white)) xlabel(1990(5)2020, nogrid) xtitle("") aspectrati(0.55) ///
legend(label(1 "Actual Regulations") label(2 "No JOBS Act") label(3 "No SOX 404") label(4 "Zero Regulation") col(2) position(6))
graph export $output/Figure7b.png, replace

twoway ///
(line totyr_p_actual year, lpattern(solid) lcolor(black) lwidth(medthick) ) || ///
(line totyr_p_nojobs year, lpattern(dash) lcolor(black)  lwidth(medthick)  ) || ///
(line totyr_p_nosox year, lpattern(shortdash_dot) lcolor(black) lwidth(medthick) ) || ///
(line totyr_p_noreg year, lpattern(shortdash) lcolor(black) lwidth(medthick) ), ///
graphregion(color(white)) xlabel(1990(5)2020, nogrid) xtitle("") aspectrati(0.55) ///
legend(label(1 "Actual Regulations") label(2 "No JOBS Act") label(3 "No SOX 404") label(4 "Zero Regulation") col(2) position(6))
graph export $output/Figure7c.png, replace