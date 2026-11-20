*************************************
*Replication code for Ewens Xiao and Xu 2023
*************************************
****************
* Table 8
****************
/*Note: coefficients and standard errors for marginal effects are multipled by 100 in the final table to represent the percentage effect. */ 


*Logit regression of going private
use $input/goingprivate_reg_sample, clear

global controls lev_bk ln_at ppe investratio1 sales_gr mb ret_ann lnnumest tot_io

eststo clear

logit F1_GPT_dummy ln_K_total ln_publicfloat_mil $controls i.sic1_yr_fe i.state_fe, iterate(200) cluster(cik)
estadd local FE1 "Yes"
estadd local FE2 "Yes"
eststo

margins, dydx(*) atmeans post
estadd local FE1 "Yes"
estadd local FE2 "Yes"
eststo

esttab using "$output/Table8.tex",  ///
replace b(5) se(5) star(* 0.10 ** 0.05 *** 0.01  )   ///
ar2  br  label mtitle noconstant  nonotes  stats(FE1 FE2 N , ///
label("Industry-year FE" "State FE" "Observations" ) ///
fmt(0 %9.0fc )) width(/hsize)  drop(*.sic1_yr_fe *.state_fe _cons )

