*************************************
*Replication code for Ewens Xiao and Xu 2023
*************************************
****************
* Table 4
****************
eststo clear

use $input/sample_25m, clear
collapse (median) at ebitda ni if treat==1 & (publicfloat_mil>=27  & publicfloat_mil<=33)
g threshold="$25m"
g regulation="Scaled disclosure"
g k=0.022
foreach x in at ebitda ni {
g k2`x'=0.022/`x'
}
save $output/T4_25, replace

use $input/sample_75m, clear
collapse (median) at ebitda ni if treat==1 & (publicfloat_mil>=95 & publicfloat_mil<=105)
g threshold="$75m"
g regulation="SOX 404 + filign delay"
g k=0.132
foreach x in at ebitda ni {
g k2`x'=k/`x'
}
save $output/T4_75, replace

use $input/sample_700m, clear
collapse (median) at ebitda ni if treat==1 & (publicfloat_mil>=840 & publicfloat_mil<=1000)
g threshold="$700m"
g regulation="EGC benefits"
g k=0.873
foreach x in at ebitda ni {
g k2`x'=k/`x'
}
save $output/T4_700, replace

clear
append using $output/T4_25
append using $output/T4_75
append using $output/T4_700

order threshold k 
label var threshold "Threshold"
label var k "Regulatory costs (k)"
label var regulation "Identified regulations"
label var at "Total assets"
label var ebitda "EBITDA"
label var ni "Net income"
label var k2at "k/Total assets"
label var k2ebitda "k/EBITDA"
label var k2ni "k/Net income"

foreach x of varlist at ebitda ni {
	replace `x'=round(`x', 0.01)
	format `x' %6.2f
}

foreach x of varlist k2at k2ebitda k2ni {
	replace `x'=100*round(`x', 0.0001)
	tostring `x', replace force
	replace `x'=`x'+"%"
}

capture erase $output/T4_25.dta
capture erase $output/T4_75.dta
capture erase $output/T4_700.dta

export excel using "$output/Table4.xlsx", firstrow(variables) keepcellfmt replace
/*Transpose the Excel table for the final format*/


