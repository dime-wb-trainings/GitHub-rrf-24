* RRF 2024 - Analyzing Data Template	
*-------------------------------------------------------------------------------	
* Load data
*------------------------------------------------------------------------------- 
	
	*load analysis data 

*-------------------------------------------------------------------------------	
* Summary stats
*------------------------------------------------------------------------------- 

	* defining globals with variables used for summary
	global sumvars 		???
	
	* Summary table - overall and by districts
	eststo all: 	estpost sum ???
	???
	???
	???
	
	
	* Exporting table in csv
	esttab 	??? ///
			using "???", replace ///
			label ///
			????
	
	* Also export in tex for latex
	???
			
*-------------------------------------------------------------------------------	
* Balance tables
*------------------------------------------------------------------------------- 	
	
	* Balance (if they purchased cows or not)
	iebaltab 	???, ///
				grpvar(???) ///
				rowvarlabels	///
				format(???)	///
				savecsv(???) ///
				savetex(???) ///
				nonote addnote(???) replace 			

				
*-------------------------------------------------------------------------------	
* Regressions
*------------------------------------------------------------------------------- 				
				
	* Model 1: Regress of food consumption value on treatment
	regress
	eststo ???		// store regression results
	
	estadd ???
	
	* Model 2: Add controls 
	
	* Model 3: Add clustering by village
	
	* Export results in tex
	esttab 	??? ///
			using "$outputs/???.tex" , ///
			label ///
			b(???) se(???) ///
			nomtitles ///
			mgroup("???", pattern(1 0 0 ) span) ///
			scalars("???") ///
			replace
			
*-------------------------------------------------------------------------------			
* Graphs 
*-------------------------------------------------------------------------------	

	* Bar graph by treatment for all districts 
	gr bar ???
	
	gr export "$outputs/fig1.png", replace		
			
	* Distribution of non food consumption by female headed hhs with means

	twoway	(kdensity ???, color(???)) ///
			(kdensity ???, color(???)) ///
			, ///
			xline(???, lcolor(???) 	lpattern(???)) ///
			xline(???, lcolor(???) 	lpattern(???)) ///
			leg(order(0 "Household Head:" 1 "???" 2 "???" ) row(???) pos(???)) ///
			xtitle("???") ///
			ytitle("???") ///
			title("???") ///
			note("???")
			
	gr export "$outputs/fig2.png", replace				
			
*-------------------------------------------------------------------------------			
* Graphs: Secondary data
*-------------------------------------------------------------------------------			
			
	use "${data}/Final/???.dta", clear
	
	* createa  variable to highlight the districts in sample
	
	* Separate indicators by sample
	
	* Graph bar for number of schools by districts
	gr hbar 	??? ???, ///
				nofill ///
				over(???, sort(???)) ///
				legend(order(0 "???:" 1 "???" 2 "???") row(1)  pos(6)) ///
				ytitle("???") ///
				name(g1, replace)
				
	* Graph bar for number of medical facilities by districts				
	gr hbar 	???
				
	grc1leg2 	???, ///
				row(???) legend(???) ///
				ycommon xcommon ///
				title("???", size(???))
			
	
	gr export "$outputs/fig3.png", replace			

****************************************************************************end!
	
