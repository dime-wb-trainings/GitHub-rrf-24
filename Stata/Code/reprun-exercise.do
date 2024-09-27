/*******************************************************************************
RRF 2024
Code for Advanced Applications in Stata: Tools for Reproducible Research
*******************************************************************************/

* Update folder path to the raw dataset and add a folder that for outputs that 
* so that it can be tracked via Github 
if "`c(username)'" == "wb558768" {
	global onedrive "C:/Users/wb558768/WBG/Maria Ruth Jones - Materials/DataWork/Data/Raw"
	global outputs 	"C:/Users/wb558768/Documents/GitHub/Trainings/Outputs"
}

*-------------------------------------------------------------------------------	
* Load data
*------------------------------------------------------------------------------- 

use "${onedrive}/TZA_CCT_baseline.dta", clear

*-------------------------------------------------------------------------------	
* Clean data
*------------------------------------------------------------------------------- 

* Drop duplicates
sort hhid
by hhid: gen dup = cond(_N==1,0,_n)
drop if dup==2

* Check for correct data type
ds, has(type string)	

* Submissionday should be date 
gen submissiondate = date(submissionday, "YMD hms")
format submissiondate %td

* duration should be numeric 
destring duration, replace

* ar_farm_unit should be categorical 
encode ar_farm_unit, gen(ar_unit)

* clean crop_other: add info to crop variable
replace crop_other = proper(crop_other)

replace crop = 40 if regex(crop_other, "Coconut") == 1
replace crop = 41 if regex(crop_other, "Sesame") == 1

* adding value labels for new crops
label define df_CROP 40 "Coconut" 41 "Sesame", add
		
* Turn numeric variables with negative values into missings
foreach numVar in treat_cost* trust_* assoc health {
	qui recode `numVar' (-88 =.d)
}

* Explore variables for outliers
sum food_cons nonfood_cons ar_farm, det

* dropping, ordering, labeling before saving
drop 	ar_farm_unit submissionday crop_other dup
		
order 	ar_unit, after(ar_farm)

lab var submissiondate "Date of interview"

*-------------------------------------------------------------------------------	
* Construct data
*------------------------------------------------------------------------------- 

* Area in acre
// Equal to area farm if unit is acres, 
// otherwise multiplied by value of hectare in acres

global acre_conv 2.47

di $acre_conv

generate 	area_acre = ar_farm 				if ar_unit == 1 , after(ar_farm)
replace 	area_acre = ar_farm * $acre_conv 	if ar_unit == 2

lab var		area_acre "Area farmed in acres"

* Consumption in usd
global usd 0.00037

foreach cons_var in food_cons nonfood_cons {
	
	* Save labels 
	local `cons_var'_lab: variable label `cons_var'
	
	* generate vars
	gen `cons_var'_usd = `cons_var' * $usd , after(`cons_var')
	
	* apply labels to new variables
	lab var `cons_var'_usd "``cons_var'_lab' (USD)"
	
}

* Winsorize variables with outliers 

foreach win_var in area_acre food_cons_usd nonfood_cons_usd {
	
	local `win_var'_lab: variable label `win_var'
	
	winsor 	`win_var', p(0.05) high gen(`win_var'_w)
	order 	`win_var'_w, after(`win_var')
	lab var `win_var'_w "``win_var'_lab' (Winsorized 0.05)"
	
}

* Assigning groups to half of the households 
isid hhid, sort
gen random = runiform()
egen ordering = rank(random) 

* Assign observations to control & treatment group based on their ranks 
gen group = .  
replace group = 1 if ordering <= _N/2
replace group = 0 if ordering > _N/2 

lab def grp 1 "Treatment" 0 "Control"
lab val group grp
lab var group "Group Assignment"

*-------------------------------------------------------------------------------	
* Analyze data
*------------------------------------------------------------------------------- 


* defining globals with variables used for summary
global sumvars 		hh_size n_child_5 n_elder  ///
					livestock_now area_acre_w drought_flood crop_damage

* Summary table - overall and by districts
eststo all: 	estpost sum $sumvars
eststo male: 	estpost sum $sumvars if female_head == 0
eststo female: 	estpost sum $sumvars if female_head == 1

* Also export in tex for latex
esttab 	all male female ///
		using "${outputs}/summary.tex", replace ///
		label ///
		main(mean %6.2f) aux(sd) ///
		refcat(hh_size "\textbf{HH characteristics}" drought_flood "\textbf{Shocks:}" , nolabel) ///
		mtitle("Full Sample" " Male-headed HH" "Female-headed HH") ///
		nonotes addn(Mean with standard deviations in parentheses.)
		
* Model 1: Regress of food consumption value on treatment
regress food_cons_usd_w group
eststo model1		// store regression results

estadd local clustering "No"

* Model 2: Add controls 
regress food_cons_usd_w group crop_damage drought_flood
eststo model2

estadd local clustering "No"

* Model 3: Add clustering by village
regress food_cons_usd_w group crop_damage drought_flood, vce(cluster vid)
eststo model3

estadd local clustering "Yes"

* Export results
esttab 	model1 model2 model3 ///
		using "$outputs/regressions.tex" , ///
		label ///
		b(%9.3f) se(%9.3f) ///
		nomtitles ///
		mgroup("Annual food consumption(USD)", pattern(1 0 0 ) span) ///
		scalars("clustering Clustering") ///
		replace		

* Bar graph by treatment for all districts 
gr bar 	trust_mem, ///
		over(group) ///
		asy ///
		legend(rows(1) order(0 "Assignment:" 1 "Control" 2 "Treatment") pos(6)) ///
		subtitle(,pos(6) bcolor(none)) ///
		blabel(total, format(%9.2f)) ///
		ytitle("Trust in members of the community (%)") name(g1, replace)
		
gr export "$outputs/fig1.png", replace				
		
*** End of file!