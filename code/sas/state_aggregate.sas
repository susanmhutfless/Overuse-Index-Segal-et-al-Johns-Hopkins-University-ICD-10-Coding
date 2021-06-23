/********************************************************************
* Job Name: state_aggregate.sas
* Job Desc: Aggregation at state level instead of health system;
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************/


*create state instead of health system aggregate;

*make categories of age and cc for analysis at aggregate;
data pop_&popN._in_out_anal; set &permlib..pop_&popN._1line_cc;
if elig_age   =.   then delete; 
if elig_age   <0   then delete;
if elig_age   >105 then delete;
if cc_sum=. then delete;
if elig_gndr_cd notin('1','2') then delete;
    /** turn continuous age into category **/
    if 0  <= elig_age <= 5   then elig_age_cat = 05   ;
    if 5  <  elig_age <= 10  then elig_age_cat = 0510  ;
    if 10 <  elig_age <= 20  then elig_age_cat = 1020 ;
    if 20 <  elig_age <= 30  then elig_age_cat = 2030 ;
    if 30 <  elig_age <= 40  then elig_age_cat = 3040 ;
    if 40 <  elig_age <= 50  then elig_age_cat = 4050 ;
    if 50 <  elig_age <= 60  then elig_age_cat = 5060 ;
    if 60 <  elig_age <= 70  then elig_age_cat = 6070 ;
    if 70 <  elig_age <= 80  then elig_age_cat = 7080 ;
    if 80 <  elig_age <= 105 then elig_age_cat = 80105;
if cc_sum=0 	then cc_sum_cat	='0';
if cc_sum=1 	then cc_sum_cat	='1';
if cc_sum=2 	then cc_sum_cat	='2';
if 3<=cc_sum<=5 then cc_sum_cat	='3-5';
if 6<=cc_sum<=10 then cc_sum_cat='6-10';
if 11<=cc_sum<=15 then cc_sum_cat='11-15';
if 16<=cc_sum 	then cc_sum_cat	='16+';
run;


*get % for aggregate (1 record per hospital) analysis;
proc sort data=pop_&popN._in_out_anal; by elig_prvdr_state_cd pop_year pop_qtr; 
proc summary data= pop_&popN._in_out_anal;
by elig_prvdr_state_cd pop_year pop_qtr;
var elig_age cc_sum;
output out=sum2 mean= median=/autoname;
run;
data pop_&popN._means (drop = _type_ _freq_); 
set sum2;
n=_freq_; label n='number eligible for pop';
run;

proc sort data=pop_&popN._in_out_anal; by elig_prvdr_state_cd pop_year pop_qtr;
proc freq data=pop_&popN._in_out_anal noprint; by elig_prvdr_state_cd pop_year pop_qtr;
where popped=1;
table  	popped /nocum out=popped; run;
data pop_&popN._popped (keep = elig_prvdr_state_cd pop_year pop_qtr popped); set popped (drop = popped);
popped=count;
run;


proc sort data=pop_&popN._in_out_anal; by elig_prvdr_state_cd pop_year pop_qtr;
proc freq data=pop_&popN._in_out_anal noprint; by elig_prvdr_state_cd pop_year pop_qtr;
table  	elig_gndr_cd /nocum out=elig_gndr_cd; run;
data pop_&popN._elig_gndr_cd (keep = elig_prvdr_state_cd pop_year pop_qtr female_percent); 
set elig_gndr_cd;
where elig_gndr_cd='2';
female_percent=percent;
run;

data &permlib..pop_&popN._st;
merge pop_&popN._means pop_&popN._popped pop_&popN._elig_gndr_cd;
by elig_prvdr_state_cd pop_year pop_qtr;
if n=. then n=0;
if popped=. then popped=0; 
pop_num=&popN;
pop_text=&poptext;
run;

title "Pop &popN Aggregate summary For Analysis PROVIDER STATE";
proc freq data=&permlib..pop_&popN._st; 
table  	pop_num pop_text  pop_year pop_qtr elig_prvdr_state_cd; run;
proc means data=&permlib..pop_&popN._st n mean median min max; 
var elig_age_mean elig_age_median cc_sum_median female_percent popped n; run;

proc glimmix data = &permlib..pop_&popN._st method=quad;        
class elig_prvdr_state_cd yr_qtr(ref=first) pop_num pop_compendium_hospital_id;
model popped= elig_age_mean female_percent cc_sum_mean elig_prvdr_state_cd yr_qtr pop_num
	/ s dist=negbin offset=log_elig_pop;
	random intercept /subject=pop_compendium_hospital_id ;
ods output ParameterEstimates=params;
run;    
