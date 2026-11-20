*************************************
*Replication code for Ewens Xiao and Xu 2023
*************************************
****************
* Figure 5
****************
/*
copy heatmap.ado and heatmap.sthlp to your PERSONAL or PLUS folder

Install R package "heatmapEco" in R (see details in the help file to heatmap, as well as here: https://github.com/ttfcui/heatmapEco)
*/
global linkdir "C:\Program Files\R\R-4.2.2\bin"  //For Windows
*global linkdir "/Library/Frameworks/R.framework/Versions/4.2-arm64/Resources" //For Mac



use $input/Figure5, clear
g float_interval=.
forv x=1/20 {
replace float_interval=`x'*5 if publicfloat_mil>`x'*5-2.5 & publicfloat_mil<=`x'*5+2.5
}
forv x=3/20 {
replace float_interval=`x'*50 if publicfloat_mil>`x'*50-25 & publicfloat_mil<=`x'*50+25
}
forv x=3/20 {
replace float_interval=`x'*500 if publicfloat_mil>`x'*500-250 & publicfloat_mil<=`x'*500+250
}
mdesc publicfloat_mil
count if publicfloat_mil>12500
count if publicfloat_mil<=2.5
tab float_interval, mis
drop if float_interval==.
keep if publicfloat_year>=1994 & publicfloat_year<=2018 
collapse (count) N=publicfloat_mil (median) regcost_* publicfloat_mil r_capm, by(float_interval publicfloat_year)
rename publicfloat_year year
sum N, det
rename (regcost_25-regcost_700) (k_sd k_sox k_egc)

*code annual costs for age>5
tsset float_interval year
g k_old=.
replace k_old=k_egc-k_sox-k_sd if year>=1994 & year<=2002 & float_interval<25
replace k_old=k_egc-k_sox if year>=1994 & year<=2002 & float_interval>=25
replace k_old=k_egc-k_sox-k_sd if year>=2003 & year<=2007 & float_interval<25
replace k_old=k_egc-k_sox if year>=2003 & year<=2007 & float_interval>=25 & float_interval<75
replace k_old=k_egc if year>=2003 & year<=2007 & float_interval>=75
replace k_old=k_egc-k_sox-k_sd if year>=2008 & year<=2018 & float_interval<25
replace k_old=k_egc-k_sox-k_sd if year>=2008 & year<=2018 & float_interval>=25 & float_interval<75
replace k_old=k_egc if year>=2008 & year<=2018 & float_interval>=75
rename k_old totalcosts_old
sum totalcosts_old, det
replace totalcosts_old=0 if totalcosts_old<0
g pvtotalcosts_2float_old=(totalcosts_old/r_capm)/publicfloat
winsor2 pvtotalcosts_2float_old, cut(0.5 99.5) replace

*code annual costs for age<=5
foreach x in totalcosts pvtotalcosts_2float {
g `x'_young=`x'_old
replace `x'_young=0 if year>=2012 & year<=2018 & float_interval<700
}
rename float_interval publicfloat
g publicfloat_str=string(publicfloat)

*plot heatmaps
heatmap pvtotalcosts_2float_young publicfloat_str year if publicfloat<=1000, ///
xtitle("Year") ytitle("Public float in mil") ztitle("PV(regulatory costs)/float") ///
tperiod(year) save($output/Figure5a.pdf)

heatmap pvtotalcosts_2float_old publicfloat_str year if publicfloat<=1000, ///
xtitle("Year") ytitle("Public float in mil") ztitle("PV(regulatory costs)/float") ///
tperiod(year) save($output/Figure5b.pdf)


