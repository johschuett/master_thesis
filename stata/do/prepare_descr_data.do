** DO NOT EXECUTE THIS DO-FILE ON ITS OWN, DO MAIN.DO !! **

use ${v38}ppathl, clear
keep if inrange(netto, 10, 19)


* generate female dummy
recode sex (2 = 1) (1 = 0) (nonmissing = .), gen(female)

label variable female "Female"

label define female 0 "[0] Male", modify
label define female 1 "[1] Female", modify

label values female female

drop if mi(female)


* eastern origin
recode loc1989 (1 = 1) (2 = 0) (nonmissing = .), gen(east_origin)

label variable east_origin "East German Origin"

label define east_origin 0 "[0] Does not have an East German Origin", modify
label define east_origin 1 "[1] Has an East German Origin", modify

label values east_origin east_origin

drop if mi(east_origin)


* drop people born outside of germany
drop if germborn == 2


* stem profession
merge 1:1 pid syear using ${v38}pl, keep(1 3) keepusing(p_isco88) nogen

recode p_isco88 (1236 2111/2213 3111/3212 = 1) (min/0 = .) (nonmissing = 0), gen(stem)

label variable stem "STEM Profession"

label define stem 0 "[0] Does not have a STEM Profession", modify
label define stem 1 "[1] Has a STEM Profession", modify

label values stem stem


* info about employment status
merge 1:1 pid syear using ${v38}pgen, keep(1 3) keepusing(pgemplst) nogen


* only individuals who are either full- or part-time employed should be marked
* as success in stem variable
replace stem = 0 if !inrange(pgemplst, 1, 2)
replace stem = . if pgemplst < 0 & stem == 1

* drop individuals who still lack information on whether they work in stem or not
drop if mi(stem)


* generate age
gen age = syear - gebjahr

label variable age "Age"


* partner
recode partner (1/4 = 1) (0 5 = 0), gen(partner_bin)
label variable partner_bin "Spouse/Life Partner"

label define partner_bin 0 "[0] Does not have a Spouse/Life Partner", modify
label define partner_bin 1 "[1] Has a Spouse/Life Partner", modify

label values partner_bin partner_bin


* household size
merge m:1 hid syear using ${v38}hbrutto, keep(3) keepusing(hhgr) nogen
label variable hhgr "Household Size"


* monthly household net income
merge m:1 hid syear using ${v38}hl, keep(1 3) keepusing(hlc0005_h) nogen
rename hlc0005_h hhincome
label variable hhincome "Monthly Household Income (Net)"


* residence west germany
merge m:1 hid syear using ${v38}regionl, keep(3) keepusing(bula) nogen

recode bula (1/10 = 1) (11/16 = 0) (nonmissing = .), gen(west)

label variable west "Residence in West Germany"

label define west 0 "[0] Does not reside in West Germany", modify
label define west 1 "[1] Resides in West Germany", modify

label values west west

drop if mi(west)


* save dataset
compress
save ${data}female_stem, replace
