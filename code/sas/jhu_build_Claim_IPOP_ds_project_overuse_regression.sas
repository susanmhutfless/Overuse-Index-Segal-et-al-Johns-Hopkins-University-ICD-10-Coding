/********************************************************************
* Job Name: jhu_build_Claim_IPOP_ds_project_overuse_regression.sas
* Job Desc: Input for Inpatient & Outpatient (Including Carrier) Claims 
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************/

/*** bring hosp level tables together and run regression model***/

data pop_data_input;
	* Read in data, keeping track of the popN ;
	set &permlib..pop_: 	;
run;


/*=============================================================*/
/* 		REGRESSION MODEL		 	       */
/*=============================================================*/

ods trace on;   
proc glimmix data = pop_data_input ;
	/* Store parameter estimates */
        ods output ParameterEstimates=params;
	* I believe all fixed effects/categorical variables should go in the class statement ;
	* You can set your reference group with a (REF = 'XX') statement following each variable ;
	class health_sys_id2016 pop_year pop_qtr pop_num pop_compendium_hospital_id;
	* My understanding is that random effects should be included in the class statement but NOT model statement ;
	model popped/n= elig_age_mean female_percent cc_sum_mean health_sys_id2016 pop_year pop_qtr pop_num
	/ solution;
	* Random effects go below ;
	random intercept /subject=pop_compendium_hospital_id solution;

run;
ods trace off;     

