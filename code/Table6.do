*************************************
*Replication code for Ewens Xiao and Xu 2023
*************************************
****************
* Table 6
****************
/*Note: coefficients and standard errors for marginal effects are multipled by 100 in the final table to represent the percentage effect. */ 

use $input/ipo_counterfactual_v3, clear

sum ipo_dummy ln_K_total ln_publicfloat_mil ln_totalRaised age
mdesc ipo_dummy ln_K_total ln_publicfloat_mil ln_totalRaised age

eststo clear
logit ipo_dummy ln_K_total ln_publicfloat_mil ln_totalRaised age ///
i.ind_year_fe i.state_fe, cluster(newID)
estadd local FE1 "Yes"
estadd local FE2 "Yes"
eststo

margins, dydx(*) atmeans post
estadd local FE1 "Yes"
estadd local FE2 "Yes"
eststo

esttab using "$output/Table6.tex",  ///
replace b(6) se(6) star(* 0.10 ** 0.05 *** 0.01  )   ///
ar2  br  label mtitle noconstant  nonotes  stats(FE1 FE2 N , ///
label("Industry-year FE"  "State FE" "Observations" ) ///
fmt(0 %9.0fc )) width(/hsize)  drop(*.ind_year_fe *.state_fe _cons )

