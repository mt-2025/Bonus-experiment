


clear

import excel "Experimental data", firstrow 


label define r_level 1 "Risklevel_1" 2 "Risklevel_2" 3 "Risklevel_3"

gen TI_Asset = real(substr(Task_I,-1,1))
gen TI_level=1 
replace TI_level=2 if TI_Asset>=4 & TI_Asset<=6
replace TI_level=3 if TI_Asset>=7 
label val TI_level r_level

gen TN_Asset = real(substr(Task_N,-1,1))
gen TN_level=1 
replace TN_level=2 if TN_Asset>=4 & TN_Asset<=6
replace TN_level=3 if TN_Asset>=7 
label val TN_level r_level

gen TR1_Asset = real(substr(Task_R1,-1,1))
gen TR1_level=1 
replace TR1_level=2 if TR1_Asset>=4 & TR1_Asset<=6
replace TR1_level=3 if TR1_Asset>=7 
label val TR1_level r_level

gen TR2_Asset = real(substr(Task_R2,-1,1))
gen TR2_level=1 
replace TR2_level=2 if TR2_Asset>=4 & TR2_Asset<=6
replace TR2_level=3 if TR2_Asset>=7  
label val TR2_level r_level

gen Bonusgroup =1 if BonusGroup == "Proportional"
replace Bonusgroup = 2 if BonusGroup == "Bonus Cap"
replace Bonusgroup = 3 if BonusGroup == "Malus"
label define bonus 1 "Proportional" 2 "Bonus cap" 3 "Malus"
label val Bonusgroup bonus
gen bonuscap=0
replace bonuscap=1 if Bonusgroup==2
gen malus=0
replace malus=1 if Bonusgroup==3
label var bonuscap "Bonus Cap"
label var malus "Malus"

destring Age, replace
label var Age "Age"
gen Male=1 if Sex == "Male"
replace Male=0 if Sex =="Female"
label define Male_Female 0 "Female" 1 "Male"
label val Male Male_Female

label define will_willnot 1 "Interested" 0 "Not interested" 
gen interest_finance=0 
replace interest_finance=1 if Interest_in_fin=="Probably will"
replace interest_finance=1 if Interest_in_fin=="Definitely will"
label var interest_finance "InterestInFinance"
label val interest_finance will_willnot


save data1.dta, replace

* Inherent risk choices (Table 5)
eststo clear
eststo: mlogit TI_level i.Bonusgroup Age Male interest_finance, cformat(%9.3f)
esttab using results.rtf, replace label wide noomitted se pr2 star(* 0.10 ** 0.05 *** 0.01)


* For proportional group, compare Task I, Task N (Table 6)
use data1.dta,clear
keep if Bonusgroup ==1
gen Bonus=0
gen TI_or_TN_level = TI_level
label val TI_or_TN_level r_level

keep PartID TI_or_TN_level Age Male interest_finance Bonus 
save prop1.dta, replace

use data1.dta,clear
keep if Bonusgroup ==1
gen Bonus=1
gen TI_or_TN_level = TN_level
label val TI_or_TN_level r_level

keep PartID TI_or_TN_level Age Male interest_finance Bonus 
append using prop1.dta
save prop1.dta, replace

eststo clear
eststo: mlogit TI_or_TN_level Bonus Male interest_finance, cformat(%9.3f)
esttab using results.rtf, append label wide noomitted se pr2 star(* 0.10 ** 0.05 *** 0.01)

* Task N (for all Bonusgroup) (Table 7)
use data1.dta,clear

eststo clear
eststo: mlogit TN_level i.Bonusgroup TI_level Male interest_finance, cformat(%9.3f)
esttab using results.rtf, append label wide noomitted se pr2 star(* 0.10 ** 0.05 *** 0.01)

* compare Task R1 and Task R2 (for all Bonusgroup) (Table 9)
eststo clear
eststo: mlogit TR1_level i.Bonusgroup TI_level Male interest_finance, cformat(%9.3f)
est store est1

eststo: mlogit TR2_level i.Bonusgroup TI_level Male interest_finance, cformat(%9.3f)
est store est2

esttab est1 est2 using results.rtf, append label wide noomitted se pr2 star(* 0.10 ** 0.05 *** 0.01)

* For all groups, compare Task R1 vs Task N and Task R2 vs Task N (Table 8)
use data1.dta,clear
gen Relative=0
gen TN_or_TR1_level = TN_level
gen TN_or_TR2_level = TN_level
keep PartID Age Male interest_finance Relative TN_or_TR1_level TN_or_TR2_level TI_level bonuscap malus
save rela1.dta, replace

use data1.dta,clear
gen Relative=1
gen TN_or_TR1_level = TR1_level
gen TN_or_TR2_level = TR2_level
keep PartID Age Male interest_finance Relative TN_or_TR1_level TN_or_TR2_level TI_level bonuscap malus
append using rela1.dta

label val TN_or_TR1_level r_level

label val TN_or_TR2_level r_level

save rela1.dta, replace

eststo clear
eststo: mlogit TN_or_TR1_level Relative TI_level bonuscap malus Male interest_finance, cformat(%9.3f)
est store est1

eststo: mlogit TN_or_TR2_level Relative TI_level bonuscap malus Male interest_finance, cformat(%9.3f)
est store est2

esttab est1 est2 using results.rtf, append label wide noomitted se pr2 star(* 0.10 ** 0.05 *** 0.01)


