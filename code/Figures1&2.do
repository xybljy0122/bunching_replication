*************************************
*Replication code for Ewens Xiao and Xu 2023
*************************************
****************
* Figures 1 & 2
****************

*25m threshold
**************
use $input/sample_25m, clear

*Figures 1a & 1b
distplot publicfloat_mil ///
if publicfloat_mil>=23 & publicfloat_mil<=28, over(treat) xline(25, lpattern(dash)) ///
lpattern(dash) graphregion(color(white)) plotregion(color(white)) legend(symxsize(*0.5) symysize(*0.5) col(2) position(6))
graph export $output/Figure1a.png, as(png) replace

twoway hist publicfloat_mil ///
if publicfloat_mil>=20 & publicfloat_mil<=30 ///
, by(treat, note("") graphregion(color(white)) plotregion(color(white))) xline(25, lcolor(red)) width(1) frac gap(40) subtitle(,bcolor(white))
graph export $output/Figure1b.png, as(png) replace


*Figures 2a & 2b
distplot publicfloat_mil ///
if publicfloat_mil>=13 & publicfloat_mil<=18, over(treat) xline(15, lpattern(dash)) ///
lpattern(dash) graphregion(color(white)) plotregion(color(white)) legend(symxsize(*0.5) symysize(*0.5) col(2) position(6))
graph export $output/Figure2a.png, as(png) replace

graph twoway hist publicfloat_mil ///
if publicfloat_mil>=12 & publicfloat_mil<=18 ///
, by(treat, note("") graphregion(color(white)) plotregion(color(white))) xline(15, lcolor(red)) width(0.5) frac gap(40) subtitle(,bcolor(white))
graph export $output/Figure2b.png, as(png) replace



*75m threshold
**************
use $input/sample_75m, clear

*Figures 1c & 1d
distplot publicfloat_mil ///
if publicfloat_mil>=65 & publicfloat_mil<=90, over(treat) xline(75, lpattern(dash)) ///
lpattern(dash) graphregion(color(white)) plotregion(color(white)) legend(symxsize(*0.5) symysize(*0.5) col(2) position(6))
graph export $output/Figure1c.png, as(png) replace

graph twoway hist publicfloat_mil ///
if publicfloat_mil>=40 & publicfloat_mil<=120 ///
, by(treat, note("") graphregion(color(white)) plotregion(color(white))) xline(75, lcolor(red)) width(5) frac gap(40) subtitle(,bcolor(white))
graph export $output/Figure1d.png, as(png) replace


*Figures 2c & 2d
distplot publicfloat_mil ///
if publicfloat_mil>=55 & publicfloat_mil<=70, over(treat) xline(60, lpattern(dash)) ///
lpattern(dash) graphregion(color(white)) plotregion(color(white)) legend(symxsize(*0.5) symysize(*0.5) col(2) position(6))
graph export $output/Figure2c.png, as(png) replace

graph twoway hist publicfloat_mil ///
if publicfloat_mil>=55 & publicfloat_mil<=65 ///
, by(treat, note("") graphregion(color(white)) plotregion(color(white))) xline(60, lcolor(red)) width(1) frac gap(40) subtitle(,bcolor(white))
graph export $output/Figure2d.png, as(png) replace



*700m threshold
**************
use $input/sample_700m, clear

*Figures 1e & 1f
distplot publicfloat_mil ///
if publicfloat_mil>=600 & publicfloat_mil<=900, over(treat) xline(700, lpattern(dash)) ///
lpattern(dash) graphregion(color(white)) plotregion(color(white)) legend(symxsize(*0.5) symysize(*0.5) col(2) position(6))
graph export $output/Figure1d.png, as(png) replace

graph twoway hist publicfloat_mil if ///
publicfloat_mil>=400 & publicfloat_mil<=1200, ///
by(treat, note("") graphregion(color(white)) plotregion(color(white))) xline(700, lcolor(red)) width(50) frac gap(40) subtitle(,bcolor(white))
graph export $output/Figure1e.png, as(png) replace


*Figures 2e & 2f
distplot publicfloat_mil ///
if publicfloat_mil>=400 & publicfloat_mil<=600, over(treat) xline(500, lpattern(dash)) ///
lpattern(dash) graphregion(color(white)) plotregion(color(white)) legend(symxsize(*0.5) symysize(*0.5) col(2) position(6))
graph export $output/Figure2d.png, as(png) replace

graph twoway hist publicfloat_mil if ///
publicfloat_mil>=400 & publicfloat_mil<=600, ///
by(treat, note("") graphregion(color(white)) plotregion(color(white))) xline(500, lcolor(red)) width(25) frac gap(40) subtitle(,bcolor(white))
graph export $output/Figure2e.png, as(png) replace
