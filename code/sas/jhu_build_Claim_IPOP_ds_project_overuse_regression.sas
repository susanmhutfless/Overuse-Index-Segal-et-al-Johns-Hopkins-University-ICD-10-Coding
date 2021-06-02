/********************************************************************
* Job Name: jhu_build_Claim_IPOP_ds_project_overuse_regression.sas
* Job Desc: Input for Inpatient & Outpatient (Including Carrier) Claims 
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************/

/*** bring hosp level tables together and run regression model***/

data &permlib..pop_01_18;
	set &permlib..pop_01 - &permlib..pop_18 	;
run;


/*=============================================================*/
/* 		REGRESSION MODEL		 	       */
/*=============================================================*/

title "Pop &popN Aggregate summary For Analysis";
proc freq data=&permlib..pop_&popN; 
table  	pop_num pop_text  pop_year pop_qtr ; run;
proc means data=&permlib..pop_&popN n mean median min max; 
var elig_age_mean elig_age_median cc_sum_median female_percent popped n; run;


proc glimmix data = &permlib..pop_&popN ;
        ods output ParameterEstimates=params;
	class health_sys_id2016 pop_year pop_qtr pop_num pop_compendium_hospital_id;
	model popped/n= elig_age_mean female_percent cc_sum_mean health_sys_id2016 pop_year pop_qtr pop_num
	/ solution;
	random intercept /subject=pop_compendium_hospital_id solution;
run;    

