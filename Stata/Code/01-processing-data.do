* RRF 2024 - Processing Data Template	
*-------------------------------------------------------------------------------	
* Loading data
*------------------------------------------------------------------------------- 	
	
	* Load TZA_CCT_baseline.dta
	use "${data}/???", clear
	
*-------------------------------------------------------------------------------	
* Checking for unique ID and fixing duplicates
*------------------------------------------------------------------------------- 		

	* Identify duplicates 
	ieduplicates	??? ///
					using "${outputs}/duplicates.xlsx", ///
					uniquevars(???) ///
					keepvars(???) ///
					nodaily
					
	
*-------------------------------------------------------------------------------	
* Define locals to store variables for each level
*------------------------------------------------------------------------------- 							
	
	* IDs
	local ids 		???	
	
	* Unit: household
	local hh_vars 	???
	
	* Unit: Household-memebr
	local hh_mem	???
	
	
	* define locals with suffix and for reshape
	foreach mem in `hh_mem' {
		
		local mem_vars 		???
		local reshape_mem	???
	}
		
	
*-------------------------------------------------------------------------------	
* Tidy Data: HH
*-------------------------------------------------------------------------------	

	preserve 
		
		* Keep HH vars
		keep `ids' `hh_vars'
		
		* Check if data type is string
				
		
		* Fix data types 
		* numeric should be numeric
		* dates should be in the date format
		* Categorical should have value labels 
		
				
		
		* Turn numeric variables with negative values into missings
		ds, has(type ???)
		global ??? ???

		foreach numVar of global numVars {
			
			???
		}	
		
		* Explore variables for outliers
		sum ???
		
		* dropping, ordering, labeling before saving
		drop 	???
				
		order 	???
		
		lab var ???
		
		isid ???
		
		* Save data		
		iesave 	"${data}/Intermediate/???", ///
				idvars(???)  version(???) replace ///
				report(path("${outputs}/???.csv") replace)  
		
	restore
	
*-------------------------------------------------------------------------------	
* Tidy Data: HH-member 
*-------------------------------------------------------------------------------*

	preserve 

		keep ???

		* tidy: reshape tp hh-mem level 
		reshape ???
		
		* clean variable names 
		rename ???
		
		* drop missings 
		drop if mi(???)
		
		* Cleaning using iecodebook
		// recode the non-responses to extended missing
		// add variable/value labels
		// create a template first, then edit the template and change the syntax to 
		// iecodebook apply
		iecodebook template 	using ///
								"${outputs}/hh_mem_codebook.xlsx"
								
		isid ???					
		
		* Save data: Use iesave to save the clean data and create a report 
		iesave 	???  
				
	restore			
	
*-------------------------------------------------------------------------------	
* Tidy Data: Secondary data
*------------------------------------------------------------------------------- 	
	
	* Import secondary data 
	???
	
	* reshape  
	reshape ???
	
	* rename for clarity
	rename ???
	
	* Fix data types
	encode ???
	
	* Label all vars 
	lab var district "District"
	???
	???
	???
	
	* Save
	keeporder ???
	
	save "${data}/Intermediate/???.dta", replace

	
****************************************************************************end!
	
