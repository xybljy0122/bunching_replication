*************************************
*Replication code for Ewens Xiao and Xu 2023
*************************************
***********
* Table 2
***********

use $input/Table2, clear

foreach x in 25 75 700 {
g treat_below_`x'mil = treat_`x'mil*below_`x'mil
}

label var lev_bk "Book leverage"
label var investratio1 "Investment1"
label var investratio2 "Investment2"
label var investratio3 "Investment3"
label var publicown "Non-aff. own."
label var treat_below_25mil "Below $25m x Bunching years"
label var treat_below_75mil "Below $75m x Bunching years"
label var treat_below_700mil "Below $700m x Bunching years"

global margins lev_bk investratio1 investratio2 investratio3 publicown


eststo clear
foreach x of varlist $margins {

qui ivreghdfe `x'  treat_below_25mil treat_25mil below_25mil (L_`x'=L2_`x')  if samp_25mil & abs(publicfloat_mil-25)<=5, absorb(sic3 fyear) cluster(sic3 fyear) partial(treat_25mil below_25mil)
qui sum `x' if e(sample)
qui estadd local ymean=round(r(mean), 0.001)
qui estadd local FE "Yes"
eststo
}
esttab using "$output/Table2.csv", mtitles("Book leverage" "Investment1" "Investment2" "Investment3" "Non-aff. own.") title(Panel A) stats(FE N ymean, label("Year FE and SIC3 FE" "N" "Mean of dep. var.") fmt(0 %9.0f %9.3f)) star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) label nonotes nogap br mtitle keep(treat_below_*) replace


eststo clear
foreach x of varlist $margins {
qui ivreghdfe `x'  treat_below_75mil treat_75mil below_75mil  (L_`x'=L2_`x') if samp_75mil & abs(publicfloat_mil-75)<=15, absorb(sic3 fyear) cluster(sic3 fyear) partial(treat_75mil below_75mil)
qui sum `x' if e(sample) 
qui estadd local ymean=round(r(mean), 0.001)
qui estadd local FE "Yes"
eststo
}
esttab using "$output/Table2.csv", mtitles("Book leverage" "Investment1" "Investment2" "Investment3" "Non-aff. own.") title(Panel B) stats(FE N ymean, label("Year FE and SIC3 FE" "N" "Mean of dep. var.") fmt(0 %9.0f %9.3f)) star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) label nonotes nogap br mtitle keep(treat_below_*) append


eststo clear
foreach x of varlist $margins {
qui ivreghdfe `x'  treat_below_700mil treat_700mil below_700mil  (L_`x'=L2_`x')  if samp_700mil & abs(publicfloat_mil-700)<=100, absorb(sic3 fyear) cluster(sic3 fyear) partial(treat_700mil below_700mil)
qui sum `x' if e(sample)
qui estadd local ymean=round(r(mean), 0.001)
qui estadd local FE "Yes"
eststo
}
esttab using "$output/Table2.csv", mtitles("Book leverage" "Investment1" "Investment2" "Investment3" "Non-aff. own.") title(Panel C) stats(FE N ymean, label("Year FE and SIC3 FE" "N" "Mean of dep. var.") fmt(0 %9.0f %9.3f)) star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) label nonotes nogap br mtitle keep(treat_below_*) append

