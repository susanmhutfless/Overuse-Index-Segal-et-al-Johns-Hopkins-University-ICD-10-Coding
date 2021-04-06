/********************************************************************
* Job Name: pop_crosstabs.sas
* Job Desc: Characteristics of eligible, outcome, combined and 
		aggregate tables (includes creation of aggregate table)
* Copyright: Johns Hopkins University - Hutfless & Segal Labs 2021
********************************************************************/

/**This section makes summaries for POPPED & eligible populations **/
*look at popped;
%macro poppedlook(in=);
proc freq data=&in order=freq noprint; 
table  	&flag_popped /nocum out=&flag_popped; run;
proc print data=&flag_popped noobs; where count>=11; run;

*title 'Linked to AHRQ compendium hospital';
proc freq data=&in order=freq noprint; 
where pop_compendium_hospital_id ne ' ';
table  	&flag_popped /nocum out=&flag_popped; run;
proc print data=&flag_popped noobs; where count>=11; run;

proc freq data=&in order=freq noprint; 
table  	setting_pop /nocum out=setting_pop; run;
proc print data=setting_pop noobs; where count>=11; run;

proc freq data=&in order=freq noprint; 
table  	setting_pop_: /nocum out=setting_pop_; run;
proc print data=setting_pop_ noobs; where count>=11; run;

proc freq data=&in order=freq noprint; 
table  	&pop_year /nocum out=&pop_year (drop = count); run;
proc print data=&pop_year noobs; run;

proc freq data=&in order=freq noprint; 
table  	&pop_hcpcs_cd /nocum out=&pop_hcpcs_cd (drop = count); run;
proc print data=&pop_hcpcs_cd noobs; where percent>1; run;

proc freq data=&in order=freq noprint; 
table  	&pop_icd_prcdr_cd1 /nocum out=&pop_icd_prcdr_cd1 (drop = count); run;
proc print data=&pop_icd_prcdr_cd1 noobs; where percent>1; run;

proc freq data=&in order=freq noprint; 
table  	rev_cntr /nocum out=rev_cntr (drop = count); run;
proc print data=rev_cntr noobs; where percent>1; run;

proc freq data=&in order=freq noprint; 
table  	rev_cntr1 /nocum out=rev_cntr1 (drop = count); run;
proc print data=rev_cntr1 noobs; where percent>1; run;

proc freq data=&in order=freq noprint; 
table  	pop_ed /nocum out=pop_ed (drop = count); run;
proc print data=pop_ed noobs; where percent>1; run;

proc freq data=&in order=freq noprint; 
table  	&pop_clm_drg_cd /nocum out=&pop_clm_drg_cd (drop = count); run;
proc print data=&pop_clm_drg_cd noobs; run; *inpatient only;

proc freq data=&in order=freq noprint; 
table  	&pop_admtg_dgns_cd /nocum out=&pop_admtg_dgns_cd (drop = count); run;
proc print data=&pop_admtg_dgns_cd noobs; where percent>1; run;*inpatient only;

proc freq data=&in order=freq noprint; 
table  	&pop_icd_dgns_cd1 /nocum out=&pop_icd_dgns_cd1 (drop = count); run;
proc print data=&pop_icd_dgns_cd1 noobs; where percent>1; run;

proc freq data=&in order=freq noprint; 
table  	&pop_OP_PHYSN_SPCLTY_CD /nocum out=&pop_OP_PHYSN_SPCLTY_CD (drop = count); run;
proc print data=&pop_OP_PHYSN_SPCLTY_CD noobs; run;

proc freq data=&in order=freq noprint; 
table  	&pop_nch_clm_type_cd /nocum out=&pop_nch_clm_type_cd (drop = count); run;
proc print data=&pop_nch_clm_type_cd noobs; run;

proc freq data=&in order=freq noprint; 
table  	&ptnt_dschrg_stus_cd /nocum out=&ptnt_dschrg_stus_cd (drop = count); run;
proc print data=&ptnt_dschrg_stus_cd noobs; run;

proc freq data=&in order=freq noprint; 
table  	&CLM_IP_ADMSN_TYPE_CD /nocum out=&CLM_IP_ADMSN_TYPE_CD (drop = count); run;
proc print data=&CLM_IP_ADMSN_TYPE_CD noobs; run;

proc freq data=&in order=freq noprint; 
table  	&clm_src_ip_admsn_cd /nocum out=&clm_src_ip_admsn_cd (drop = count); run;
proc print data=&clm_src_ip_admsn_cd noobs; run;

proc freq data=&in order=freq noprint; 
table  	&gndr_cd /nocum out=&gndr_cd (drop = count); run;
proc print data=&gndr_cd noobs; run;

proc freq data=&in order=freq noprint; 
table  	bene_race_cd /nocum out=bene_race_cd (drop = count); run;
proc print data=bene_race_cd noobs; run;

proc means data=&in mean median min max; var  &pop_age &pop_los; run;
%mend;

%macro eliglook(in=);
proc freq data=&in order=freq noprint; 
table  	pop_num /nocum out=pop_num; run;
proc print data=pop_num noobs; where count>=11; run;

proc freq data=&in order=freq noprint; 
table  	setting_elig /nocum out=setting_elig; run;
proc print data=setting_elig noobs; where count>=11; run;

proc freq data=&in order=freq noprint; 
table  	setting_elig_: /nocum out=setting_elig_; run;
proc print data=setting_elig_ noobs; where count>=11; run;

proc freq data=&in order=freq noprint; 
table  	elig_year /nocum out=elig_year (drop = count); run;
proc print data=elig_year noobs; run;

proc freq data=&in order=freq noprint; 
table  	elig_qtr /nocum out=elig_qtr (drop = count); run;
proc print data=elig_qtr noobs; run;

proc freq data=&in order=freq noprint; 
table  	hcpcs_cd1 /nocum out=hcpcs_cd1 (drop = count); run;
proc print data=hcpcs_cd1 noobs; where percent>1; run;

proc freq data=&in order=freq noprint; 
table  	icd_prcdr_cd1 /nocum out=icd_prcdr_cd1 (drop = count); run;
proc print data=icd_prcdr_cd1 noobs; where percent>1; run;

proc freq data=&in order=freq noprint; 
table  	rev_cntr1 /nocum out=rev_cntr1 (drop = count); run;
proc print data=rev_cntr1 noobs; where percent>1; run;

proc freq data=&in order=freq noprint; 
table  	elig_ed /nocum out=elig_ed (drop = count); run;
proc print data=elig_ed noobs; where percent>1; run;

proc freq data=&in order=freq noprint; 
table  	&clm_drg_cd /nocum out=&clm_drg_cd (drop = count); run;
proc print data=&clm_drg_cd noobs; where percent>1; run; *inpatient only;

proc freq data=&in order=freq noprint; 
table  	icd_dgns_cd1 /nocum out=icd_dgns_cd1 (drop = count); run;
proc print data=icd_dgns_cd1 noobs; where percent>1; run;

proc freq data=&in order=freq noprint; 
table  	&admtg_dgns_cd /nocum out=&admtg_dgns_cd (drop = count); run;
proc print data=&admtg_dgns_cd noobs; where percent>1; run;

proc freq data=&in order=freq noprint; 
table  	OP_PHYSN_SPCLTY_CD /nocum out=OP_PHYSN_SPCLTY_CD (drop = count); run;
proc print data=OP_PHYSN_SPCLTY_CD noobs; run;

proc freq data=&in order=freq noprint; 
table  	nch_clm_type_cd /nocum out=nch_clm_type_cd (drop = count); run;
proc print data=nch_clm_type_cd noobs; run;

proc freq data=&in order=freq noprint; 
table  	&ptnt_dschrg_stus_cd /nocum out=&ptnt_dschrg_stus_cd (drop = count); run;
proc print data=&ptnt_dschrg_stus_cd noobs; run;

proc freq data=&in order=freq noprint; 
table  	&CLM_IP_ADMSN_TYPE_CD /nocum out=&CLM_IP_ADMSN_TYPE_CD (drop = count); run;
proc print data=&CLM_IP_ADMSN_TYPE_CD noobs; run;

proc freq data=&in order=freq noprint; 
table  	&clm_src_ip_admsn_cd /nocum out=&clm_src_ip_admsn_cd (drop = count); run;
proc print data=&clm_src_ip_admsn_cd noobs; run;

proc freq data=&in order=freq noprint; 
table  	&gndr_cd /nocum out=&gndr_cd (drop = count); run;
proc print data=&gndr_cd noobs; run;

proc freq data=&in order=freq noprint; 
table  	bene_race_cd /nocum out=bene_race_cd (drop = count); run;
proc print data=bene_race_cd noobs; run;

proc means data=&in mean median min max; var  elig_age elig_los; run;
%mend;


title "Characteristics of Popped for Pop &popN Prior to Merge with Eligibile Population";
%poppedlook(in=&permlib..pop_&popN._popped);
proc datasets lib=work nolist;
 delete setting: elig_ed elig_year elig_qtr pop_num icd: clm:
 		pop_icd: 
		year qtr &gndr_cd  bene_race_cd 
		pop_ed pop_year
		&pop_hcpcs_cd &pop_clm_drg_cd 
		&pop_admtg_dgns_cd &pop_OP_PHYSN_SPCLTY_CD pop_nch_clm_type_cd
		&ptnt_dschrg_stus_cd ;
quit;
run;
title "Characteristics of Eligible for Pop &popN Prior to Merge with Popped Population";
%eliglook(in=&permlib..pop_&popN._elig);
proc datasets lib=work nolist;
 delete setting: elig_ed elig_year elig_qtr pop_num icd: clm:
		year qtr &gndr_cd  bene_race_cd 
		hcpcs_cd1 &clm_drg_cd rev_cntr1
		&admtg_dgns_cd &OP_PHYSN_SPCLTY_CD nch_clm_type_cd
		&ptnt_dschrg_stus_cd ;
quit;
run;

title "Pop &popN 1 line per person per hospital per quarter summary For Analysis (popped and eligibe merged)";
proc freq data=&permlib..pop_&popN._1line_cc; 
table  	popped &flag_popped &pop_year pop_year pop_qtr setting_pop setting_elig; run;
proc means data=&permlib..pop_&popN._1line_cc n mean median min max; 
var elig_age elig_los &pop_age &pop_los pop_age cc_sum; run;
/*proc contents data=&permlib..pop_&popN._1line_cc; run;*/


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
proc sort data=pop_&popN._in_out_anal; by pop_compendium_hospital_id pop_year pop_qtr; 
proc summary data= pop_&popN._in_out_anal;
by pop_compendium_hospital_id pop_year pop_qtr;
var elig_age cc_sum;
output out=sum2 mean= median=/autoname;
run;
data pop_&popN._means (drop = _type_ _freq_); 
set sum2;
n=_freq_; label n='number eligible for pop';
run;

proc sort data=pop_&popN._in_out_anal; by pop_compendium_hospital_id pop_year pop_qtr;
proc freq data=pop_&popN._in_out_anal noprint; by pop_compendium_hospital_id pop_year pop_qtr;
where popped=1;
table  	popped /nocum out=popped; run;
data pop_&popN._popped (keep = pop_compendium_hospital_id pop_year pop_qtr popped); set popped (drop = popped);
popped=count;
run;


proc sort data=pop_&popN._in_out_anal; by pop_compendium_hospital_id pop_year pop_qtr;
proc freq data=pop_&popN._in_out_anal noprint; by pop_compendium_hospital_id pop_year pop_qtr;
table  	elig_gndr_cd /nocum out=elig_gndr_cd; run;
data pop_&popN._elig_gndr_cd (keep = pop_compendium_hospital_id pop_year pop_qtr female_percent); 
set elig_gndr_cd;
where elig_gndr_cd='2';
female_percent=percent;
run;

data pop_&popN._in_out_anal2;
merge pop_&popN._means pop_&popN._popped pop_&popN._elig_gndr_cd;
by pop_compendium_hospital_id pop_year pop_qtr;
if n=. then n=0;
if popped=. then popped=0; 
pop_num=&popN;
pop_text=&poptext;
run;


*merge hospital aggregated data to health system;
proc sql;
create table &permlib..pop_&popN (compress=yes) as		
select  
*
from 
pop_&popN._in_out_anal2 a,
&permlib..ahrq_ccn b
where a.pop_compendium_hospital_id = b.compendium_hospital_id 
and b.health_sys_id2016 ne ' ';
quit;


title "Pop &popN Aggregate summary For Analysis";
proc freq data=&permlib..pop_&popN; 
table  	pop_num pop_text  pop_year pop_qtr ; run;
proc means data=&permlib..pop_&popN n mean median min max; 
var elig_age_mean elig_age_median cc_sum_median female_percent popped n; run;
