/* Load in the provided dataset */
/* Please change file path to where you have the dataset. */
DATA wic_raw; 
  set '/home/u58377353/itfps466_updated_2023511.sas7bdat'; 
RUN; 

/* Encode Diet Score as a categorical variable.
Category 1 = "Poor"
Category 2 = "Needs Improvement"
Category 3 = "Good"
*/
data wic_categorical;
	set wic_raw;
	IF HEI2015_TOTAL_SCORE <= 50 THEN diet_score = "1";
	ELSE IF HEI2015_TOTAL_SCORE > 50 and HEI2015_TOTAL_SCORE <= 80 THEN diet_score = "2";
	ELSE diet_score = "3";
RUN;

/* Remove rows with missing values from the dataset. */
data wic_pruned;
    set wic_categorical;
    if cmiss(of _all_) then delete;
run;

/*   Data Exploration   */

/* Display diet score frequencies from the un-pruned data. */
proc freq data = wic_categorical;
tables diet_score;

/* Display diet score frequencies from pruned data (no missing values). */
proc freq data = wic_pruned;
tables diet_score;

/* Display how frequently each variable is missing. */
proc means data=wic_categorical
    NMISS;
run;

/*   Research questions    */

/* Reasearch question 1 */
proc logistic data=wic_pruned;
	class RSL_FoodSecurity24m (param=ref ref='3')
  		SL_EthnicityCG (param=ref ref='2')
  		SL_MomMaritalStatus (param=ref ref='2')
  		SL_Poverty2013s (param=ref ref='3');
	model diet_score = RSL_FoodSecurity24m
  		SL_EthnicityCG
  		SL_MomMaritalStatus
  		SL_Poverty2013s;
  	oddsratio RSL_FoodSecurity24m;
  	effectplot interaction(x=RSL_FoodSecurity24m sliceby=diet_score) / polybar;
run;

/* Reasearch question 2 */
proc logistic data=wic_pruned;
	class cumulativeFS (param=ref ref='3')
  		SL_EthnicityCG (param=ref ref='2')
  		SL_MomMaritalStatus (param=ref ref='2')
  		SL_Poverty2013s (param=ref ref='3');
	model diet_score = cumulativeFS  
    	SL_EthnicityCG
    	SL_MomMaritalStatus
    	SL_Poverty2013s;
    oddsratio cumulativeFS;
  	effectplot interaction(x=cumulativeFS sliceby=diet_score) / polybar;
run;

/* Research Question 3 */
/* (Treating restrictive and pressuring as numerical variables) */
proc logistic data=wic_pruned;
	class RSL_FoodSecurity24m (param=ref ref='3')
  		SL_EthnicityCG (param=ref ref='2')
  		SL_MomMaritalStatus (param=ref ref='2')
  		SL_Poverty2013s (param=ref ref='3');
	model diet_score = RSL_FoodSecurity24m
		RSL_FoodSecurity24m * RSL_ChildWICPartStat24m
		RSL_FoodSecurity24m * pressuring24m
		RSL_FoodSecurity24m * restrictive24m
  		SL_EthnicityCG
  		SL_MomMaritalStatus
  		SL_Poverty2013s;
  	oddsratio RSL_FoodSecurity24m;
  	effectplot interaction(x=RSL_FoodSecurity24m sliceby=diet_score) / polybar;
run;