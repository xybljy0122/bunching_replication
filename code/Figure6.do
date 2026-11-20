*************************************
*Replication code for Ewens Xiao and Xu 2023
*************************************
****************
* Figure 6
****************

use $input/Figure6, clear
g K_share_ebitda=100* K_total_sum/ebitda
label var K_total_sum "Aggregate regulatory costs"
label var K_share_ebitda "Share of aggregate EBITDA (%)"


keep if year>=1995

twoway (line K_total_sum year, lpattern(dash) lcolor(navy)) || (line K_share_ebitda year, yaxis(2)), aspectratio(0.6) ytitle("Aggregate regulatory costs in mil $") ytitle("Share of aggregate EBITDA (%)", axis(2)) ylabel(1000(1000)6000, angle(vertical) grid) ylabel(0.1(0.05)0.35, angle(vertical) grid axis(2)) xtitle("") xlabel(1995(3)2019, nogrid) graphregion(color(white)) plotregion(color(white)) legend(col(2) position(6)) xline(2002) xline(2012) text(6000 2002.5 "SOX", place(e)) text(6000 2012.5 "JOBS Act", place(e))
graph export $output/Figure6.png, replace


