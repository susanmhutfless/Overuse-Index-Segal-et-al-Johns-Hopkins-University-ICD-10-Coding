/********************************************************************
* Job Name: jhu_build_Claim_IPOP_ds_project_overuse_regression.sas
* Job Desc: Input for Inpatient & Outpatient (Including Carrier) Claims 
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************/

/*** bring hosp level tables together and run regression model***/
%global lwork ltemp permlib;
%let  lwork              = work              	;
%let  ltemp              = temp              	;
%let  permlib              = shu172sl          	;

data &permlib..pop_01_18;
	set &permlib..pop_01 - &permlib..pop_18 	;
	
run;


/*=============================================================*/
/* 		REGRESSION MODEL		 	       */
/*=============================================================*/

title "Pop 01 - Pop 18 Aggregate Summary For Analysis";
proc freq data=&permlib..pop_01_18; 
table  	pop_num pop_text  pop_year pop_qtr yr_qtr pop_num;* health_sys_id2016 pop_compendium_hospital_id; run;
proc means data=&permlib..pop_01_18 n mean median min max; 
var elig_age_mean elig_age_median cc_sum_mean cc_sum_median female_percent popped n; run;
proc means nmiss data=&permlib..pop_01_18; run;

title "Pop 01 - Pop 18 without standardized coefficients";
ods trace on;
proc glimmix data = &permlib..pop_01_18 method=quad;        
class health_sys_id2016 yr_qtr(ref=first) pop_num pop_compendium_hospital_id;
model popped= elig_age_mean female_percent cc_sum_mean health_sys_id2016 yr_qtr pop_num
	/ s dist=negbin offset=log_elig_pop;
	random intercept /subject=pop_compendium_hospital_id ;
ods output ParameterEstimates=params;
run;    
ods trace off;
data &permlib..pop_01_18_params; set params; run;
