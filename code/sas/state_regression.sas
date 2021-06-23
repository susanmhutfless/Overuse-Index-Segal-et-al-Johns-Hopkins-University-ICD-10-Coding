/********************************************************************
* Job Name: state_regression.sas
* Job Desc: Aggregation and Regression at state level instead of health system;
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************/

/*** bring hosp level tables together and run regression model***/
%global lwork ltemp permlib;
%let  lwork              = work              	;
%let  ltemp              = temp              	;
%let  permlib              = shu172sl          	;

*run aggregate at state level;
%let	popN							= 01;
%let 	poptext							= "preopchest"							;
%include "&vrdc_code./state_aggregate.sas";
%let	popN							= 02;
%let	poptext							= "foot imaging";
%include "&vrdc_code./state_aggregate.sas";
%let	popN							= 03;
%let	poptext							= "brain imaging"; 
%include "&vrdc_code./state_aggregate.sas";
%let	popN							= 04;
%let	poptext							= "sinus CT"; 
%include "&vrdc_code./state_aggregate.sas";
%let	popN							= 05;
%let 	poptext							= "abd_w_wo_contrast";	
%include "&vrdc_code./state_aggregate.sas";
%let	popN							= 06;
%let 	poptext							= "imaging low risk prostate"			;
%include "&vrdc_code./state_aggregate.sas";
%let	popN							= 07;
%let	poptext							= "MRI_lowbackpain";
%include "&vrdc_code./state_aggregate.sas";
%let	popN							= 08;
%let	poptext							= "traction"; 
%include "&vrdc_code./state_aggregate.sas";
%let	popN							= 09;
%let 	poptext							= "hyst";
%include "&vrdc_code./state_aggregate.sas";
%let	popN							= 10;
%let	poptext							= "laminectomy";
%include "&vrdc_code./state_aggregate.sas";
%let	popN							= 11;
%let	poptext							= "meniscectomy";
%include "&vrdc_code./state_aggregate.sas";
%let	popN							= 12;
%let	poptext							= "nasal endoscopy"; 
%include "&vrdc_code./state_aggregate.sas";
%let	popN							= 13;
%let	poptext							= "PAP";
%include "&vrdc_code./state_aggregate.sas";
%let	popN							= 14;
%let	poptext							= "mammo";
%include "&vrdc_code./state_aggregate.sas";
%let	popN							= 15;
%let	poptext							= "colonoscopy"; 
%include "&vrdc_code./state_aggregate.sas";
%let	popN							= 16;
%let	poptext							= "carotid screening";
%include "&vrdc_code./state_aggregate.sas";
%let	popN							= 17;
%let	poptext							= "digoxin test"; 
%include "&vrdc_code./state_aggregate.sas";
%let	popN							= 18;
%let	poptext							= "EEG in syncope";
%include "&vrdc_code./state_aggregate.sas";


data &permlib..pop_01_18_st;
	set 
&permlib..pop_01_st
&permlib..pop_02_st
&permlib..pop_03_st
&permlib..pop_04_st
&permlib..pop_05_st

&permlib..pop_07_st
&permlib..pop_08_st
&permlib..pop_09_st
&permlib..pop_10_st
&permlib..pop_11_st
&permlib..pop_12_st
&permlib..pop_13_st
&permlib..pop_14_st
&permlib..pop_15_st
&permlib..pop_16_st
&permlib..pop_17_st
&permlib..pop_18_st 	;
*remove children's, psychiatric and rehab hospitals;
if find(hospital_name2016,'childr','i') then delete;
if find(hospital_name2016,'pedia','i') then delete;
if find(hospital_name2016,'behav','i') then delete;
if find(hospital_name2016,'rehab','i') then delete;
if find(hospital_name2016,'psych','i') then delete;
if find(hospital_name2016,'state hospital','i') then delete;
*do for 2018 name of hosp for completeness;
if find(hospital_name2018,'childr','i') then delete;
if find(hospital_name2018,'pedia','i') then delete;
if find(hospital_name2018,'behav','i') then delete;
if find(hospital_name2018,'rehab','i') then delete;
if find(hospital_name2018,'psych','i') then delete;
if find(hospital_name2018,'state hospital','i') then delete;
run;

data temp; set &permlib..pop_01_18_st;
if 1<=n<=10 then do; n=.; log_elig_pop=.;end;
if 1<=popped<=10 then popped=.;
run;

*of the low n, how many pop?;
title "How many pop when n<=10?";
PROC means data=&permlib..pop_01_18_st n min mean median p25 p75 max;
where n<=10;
var popped;
run;

title "How many pop when n>=11?";
PROC means data=&permlib..pop_01_18_st n min mean median p25 p75 max;
where n>=11;
var popped;
run;

title "How many pop when n>=20?";
PROC means data=&permlib..pop_01_18_st n min mean median p25 p75 max;
where n>=20;
var popped;
run;


/*=============================================================*/
/* 		REGRESSION MODEL		 	       */
/*=============================================================*/

title "Pop 01 - Pop 18 Aggregate Summary For Analysis PROVIDER STATE AGGREGATE";
proc freq data=&permlib..pop_01_18_st; 
table  	pop_num pop_text  pop_year pop_qtr yr_qtr pop_num;* health_sys_id pop_compendium_hospital_id; run;
proc means data=&permlib..pop_01_18_st n mean median min max; 
var elig_age_mean elig_age_median cc_sum_mean cc_sum_median female_percent popped n; run;
proc means nmiss data=&permlib..pop_01_18_st; run;

title "Pop 01 - Pop 18 without standardized coefficients";
ods trace on;
proc glimmix data = &permlib..pop_01_18_st method=quad;        
class elig_prvdr_state_cd yr_qtr(ref=first) pop_num pop_compendium_hospital_id;
model popped= elig_age_mean female_percent cc_sum_mean elig_prvdr_state_cd yr_qtr pop_num
	/ s dist=negbin offset=log_elig_pop;
	random intercept /subject=pop_compendium_hospital_id ;
ods output ParameterEstimates=params;
run;    
ods trace off;
data &permlib..pop_01_18_st_params; set params; run;
