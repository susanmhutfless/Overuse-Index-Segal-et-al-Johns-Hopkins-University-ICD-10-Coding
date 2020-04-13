/********************************************************************
* Job Name: jhu_build_Claim_IPOP_ds_project_overuse_num18_summed.sas
* Job Desc: Input for Inpatient & Outpatient (Including Carrier) Claims 
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************/

/*** Indicator description ***/
/* Description and codes from .xlsx file  "ICD-10 conversions_3_30_2020" */

***************Major modifications made per 27mar2020 phone call to 
include at risk population only and sum counts**************************************
We need to identify the at-risk population, calculate their agecat/comorbid/female and sum 
by hospital qtr year
then evaluate N of the eligible that popped;

/* Indicator 18 */

/*** start of indicator specific variables ***/

/*global variables for inclusion and exclusion*/
%global includ_hcpcs includ_pr10 
		includ_dx10  includ_dx10_n 
		EXCLUD_dx10  exclud_dx10_n;

/*inclusion criteria*/
%let includ_hcpcs =
					'29881' '27332' '27333' '27403'
					'29868' '29880' '29881' '29882'
					'29883'			;



%let includ_pr10 =
					'0SBC4ZZ' '0SBD4ZZ'			;

%let includ_dx10   = 'M17';
%let includ_dx10_n = 3;		*this number should match number that needs to be substringed;
%let includ_drg = ;

/** Exclusion criteria **/
%let exclud_hcpcs= '27447';

%let EXclud_pr10 =	'0SRC' '0SRD'				;
%let EXclud_pr10_n = 4;	

%let EXCLUD_dx10   = 'V' 'W'; 
%let exclud_dx10_n = 1; 

/** Label pop specific variables  **/
%global popN;
%let	popN							= 18;
%let 	flag_popped             		= popped18 								;
%let 	flag_popped_label				= 'indicator 18 popped'					;	
%let	flag_popped_dt					= popped18_dt							;
%let 	flag_popped_dt_label			= 'indicator 18 date patient popped (IP=clm_admsn_dt OP=clm_from_dt)'	;
%let 	pop_age							= pop_18_age							;				
%let	pop_age_label					= 'age eligible for pop 18'				;
%let	pop_los							= pop_18_los							;
%let	pop_los_label					= 'length of stay when patient popped'	;
%let	pop_year						= pop_18_year							;
%let	pop_nch_clm_type_cd				= pop_18_nch_clm_type_cd				;
%let  	pop_CLM_IP_ADMSN_TYPE_CD		= pop_18_CLM_IP_ADMSN_TYPE_CD			;
%let	pop_clm_fac_type_cd				= pop_18_clm_fac_type_cd				;
%let	pop_clm_src_ip_admsn_cd			= pop_18_clm_src_ip_admsn_cd			;
%let	pop_ptnt_dschrg_stus_cd  		= pop_18_ptnt_dschrg_stus_cd			;
%let	pop_admtg_dgns_cd				= pop_18_admtg_dgns_cd					;
%let	pop_icd_dgns_cd1				= pop_18_icd_dgns_cd1					;
%let	pop_icd_prcdr_cd1				= pop_18_icd_prcdr_cd1					;
%let	pop_clm_drg_cd					= pop_18_clm_drg_cd						;
%let	pop_hcpcs_cd					= pop_18_hcpcs_cd						;
%let	pop_OP_PHYSN_SPCLTY_CD			= pop_18_OP_PHYSN_SPCLTY_CD				;
%let	pop_nch_clm_type_cd				= pop_18_nch_clm_type_cd				;
%let	pop_nch_clm_type_cd_label		= 'claim/facility type for pop 18' 		;
%let	pop_CLM_IP_ADMSN_TYPE_CD_label	= 'inpatient admission type code for pop 18'	;
%let  	pop_clm_fac_type_cd_label		= 'inpatient clm_fac_type_cd for pop 18';
%let	pop_clm_src_ip_admsn_cd_label	= 'clm_src_ip_admsn_cd for pop 18'		;
%let	pop_ptnt_dschrg_stus_cd_label	= 'discharge status code for pop 18'	;	
/*** end of indicator specific variables ***/


/*** start of section - study specific libraries and variables ***/
/*** libname prefix alias assignments ***/
%global lwork ltemp permlib;
%let  lwork              = work              	;
%let  ltemp              = temp              	;
%let  permlib              = shu172sl          	;  /** permanent library location**/

%global bene_id 	clm_id 		hcpcs_cd 	clm_drg_cd
		diag_pfx 	diag_cd_min diag_cd_max
		proc_pfx 	proc_cd_min proc_cd_max        
		clm_beg_dt_in	clm_end_dt_in
		clm_beg_dt		clm_end_dt	clm_dob
		gndr_cd									;

%let  bene_id            = bene_id      		;
%let  clm_id             = clm_id            	;
%let  gndr_cd            = gndr_cd              ;
%let  hcpcs_cd           = hcpcs_cd             ;
%let  clm_drg_cd         = clm_drg_cd    		;

%let  diag_pfx           = icd_dgns_cd          ;
%let  diag_cd_min        = 1                 	;
%let  diag_cd_max        = 25                 	;

%let  proc_pfx           = icd_prcdr_cd         ;
%let  proc_cd_min        = 1                 	;
%let  proc_cd_max        = 25                 	;

%let  clm_beg_dt_in      = clm_admsn_dt   		;*_in stands for inpatient;
%let  clm_end_dt_in      = NCH_BENE_DSCHRG_DT   ;
%let  clm_from_dt         = clm_from_dt   		;
%let  clm_thru_dt         = clm_thru_dt   		;
%let  clm_dob            = dob_dt       		;
%let  nch_clm_type_cd    = nch_clm_type_cd      ;
%let  CLM_IP_ADMSN_TYPE_CD = CLM_IP_ADMSN_TYPE_CD ;
%let  clm_fac_type_cd    = clm_fac_type_cd      ;
%let  clm_src_ip_admsn_cd = clm_src_ip_admsn_cd ;
%let  ptnt_dschrg_stus_cd = ptnt_dschrg_stus_cd ;
%let  admtg_dgns_cd      = admtg_dgns_cd        ;
%let  icd_dgns_cd1       = icd_dgns_cd1         ;
%let  icd_prcdr_cd1       = icd_prcdr_cd1       ;
%let  OP_PHYSN_SPCLTY_CD = OP_PHYSN_SPCLTY_CD   ;
/*revenue center for inpatient/outpatient identifies ED*/
%global rev_cntr;
%let rev_cntr = rev_cntr;
%let ED_rev_cntr = 	'0450' '0451' '0452' '0453' '0454' '0455' '0456'
					'0457' '0458' '0459' '0981'  					;

/*** end of section   - study specific variables ***/

/** locations where code stored on machine for project **/
%let vpath     = /sas/vrdc/users/shu172/files   ;
%let proj_path = /jhu_projects/overuse          ;
%let code_path = /code/                         ;
%let vrdc_code = &vpath./jhu_vrdc_code          ;
%include "&vrdc_code./macro_tool_box.sas";
%include "&vrdc_code./medicare_formats.sas";
*%include "&vrdc_code./jhu_build_Health_Systems.sas";


*start identification of eligibility;
*First identify all who are eligible;
/*** this macro is for inpatient and outpatient claims--must have DX code of interest***/
%macro claims_rev(date=,	source=,  rev_cohort=, include_cohort=, ccn=);
*identify dx codes of interest;
proc sql;
	create table include_cohort1 (compress=yes) as
select * 
from 
&source
where 
	    substr(icd_dgns_cd1,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd2,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd3,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd4,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd5,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd6,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd7,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd8,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd9,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd10,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd11,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd12,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd13,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd14,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd15,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd16,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd17,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd18,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd19,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd20,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd21,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd22,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd23,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd24,1,&includ_dx10_n) in(&includ_dx10) or
		substr(icd_dgns_cd25,1,&includ_dx10_n) in(&includ_dx10)		;
quit;
*link to ahrq ccn so in hospital within a health system;
proc sql;
	create table include_cohort2 (compress=yes) as
select *
from 
	&permlib..ahrq_ccn a,
	include_cohort1 b	
where 
	b.prvdr_num = a.&ccn
;
quit;
*link to revenue center and hcpcs;
proc sql;
create table include_cohort3 (compress=yes) as
select a.*, b.&rev_cntr, b.&hcpcs_cd
from 
	include_cohort2 a,
	&rev_cohort b
where 
	a.&bene_id = b.&bene_id 
	and 
	a.&clm_id = b.&clm_id;
quit;
*transpose the revenue/hcpcs to 1 row per bene/clm;
proc sort data=include_cohort3 nodupkey out=hcpcs_transposed; by &bene_id &clm_id &hcpcs_cd; run;
proc transpose data=hcpcs_transposed out=hcpcs_transposed (drop = _name_ _label_) prefix=hcpcs_cd;
    by &bene_id &clm_id ;
    var &hcpcs_cd;
run;

proc sort data=include_cohort3 nodupkey out=rev_transposed; by &bene_id &clm_id &rev_cntr; run;
proc transpose data=rev_transposed out=rev_transposed (drop = _name_ _label_) prefix=rev_cntr;
    by &bene_id &clm_id ;
    var &rev_cntr;
run;
*make inclusion/exclusion criteria and set variables for eligible population;
data &include_cohort ; 
merge 	include_cohort2 
		hcpcs_transposed
		rev_transposed; 
by &bene_id &clm_id ;
array rev{*} rev_cntr:;
do r=1 to dim(rev);
	if rev(r) in(&ED_rev_cntr) then elig_ed=1;	
end;
label elig_ed='eligible visit: revenue center indicated emergency department'; 
array hcpcs{*} hcpcs_cd:;
do h=1 to dim(hcpcs);
	if hcpcs(h) in(&exclud_hcpcs) then DELETE=1;	
end;
label elig_ed='eligible visit: revenue center indicated emergency department'; 
array pr(&proc_cd_max) &proc_pfx.&proc_cd_min - &proc_pfx.&proc_cd_max;
do i=1 to &proc_cd_max;
	if substr(pr(i),1,&exclud_pr10_n) in(&EXclud_pr10) then DELETE=1;	
end;
array dx(&diag_cd_max) &diag_pfx.&diag_cd_min - &diag_pfx.&diag_cd_max;
do j=1 to &diag_cd_max;
	if substr(dx(j),1,&includ_dx10_n) in(&includ_dx10) then KEEP=1;	
end;
if KEEP ne 1 then DELETE;
if DELETE = 1 then delete;
elig_dt=&date;
elig_age=(&date-&clm_dob)/365.25; label elig_age='age at eligibility';
if &clm_end_dt_in ne . then do;
	elig_los=&clm_end_dt_in-&date;	label elig_los ='length of stay at eligbility';
end;
if elig_los =. then do;
	elig_los=&clm_thru_dt-&date;	label elig_los ='length of stay at eligbility';
end;
elig=1;
pop_num=&popN;
run; 
*delete the temp datasets;
proc datasets lib=work nolist;
 delete include: ;
quit;
run;
%mend;
/*** this section is related to IP - inpatient claims--for eligible cohort***/
*%claims_rev(date=&clm_beg_dt_in, source=rif2015.INpatient_claims_07,  
	rev_cohort=rif2015.inpatient_revenue_07, include_cohort=pop_&popN._INinclude_2015_7, ccn=ccn2016);
*%claims_rev(date=&clm_beg_dt_in, source=rif2015.INpatient_claims_08,  
	rev_cohort=rif2015.INpatient_revenue_08, include_cohort=pop_&popN._INinclude_2015_8, ccn=ccn2016);
*%claims_rev(date=&clm_beg_dt_in, source=rif2015.INpatient_claims_09,  
	rev_cohort=rif2015.INpatient_revenue_09, include_cohort=pop_&popN._INinclude_2015_9, ccn=ccn2016);
*%claims_rev(date=&clm_beg_dt_in, source=rif2015.INpatient_claims_10,  
	rev_cohort=rif2015.INpatient_revenue_10, include_cohort=pop_&popN._INinclude_2015_10, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2015.INpatient_claims_11,  
	rev_cohort=rif2015.INpatient_revenue_11, include_cohort=pop_&popN._INinclude_2015_11, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2015.INpatient_claims_12,  
	rev_cohort=rif2015.INpatient_revenue_12, include_cohort=pop_&popN._INinclude_2015_12, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_01,  
	rev_cohort=rif2016.INpatient_revenue_01, include_cohort=pop_&popN._INinclude_2016_1, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_02,  
	rev_cohort=rif2016.INpatient_revenue_02, include_cohort=pop_&popN._INinclude_2016_2, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_03,  
	rev_cohort=rif2016.INpatient_revenue_03, include_cohort=pop_&popN._INinclude_2016_3, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_04,  
	rev_cohort=rif2016.INpatient_revenue_04, include_cohort=pop_&popN._INinclude_2016_4, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_05,  
	rev_cohort=rif2016.INpatient_revenue_05, include_cohort=pop_&popN._INinclude_2016_5, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_06,  
	rev_cohort=rif2016.INpatient_revenue_06, include_cohort=pop_&popN._INinclude_2016_6, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_07,  
	rev_cohort=rif2016.INpatient_revenue_07, include_cohort=pop_&popN._INinclude_2016_7, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_08,  
	rev_cohort=rif2016.INpatient_revenue_08, include_cohort=pop_&popN._INinclude_2016_8, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_09,  
	rev_cohort=rif2016.INpatient_revenue_09, include_cohort=pop_&popN._INinclude_2016_9, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_10,  
	rev_cohort=rif2016.INpatient_revenue_10, include_cohort=pop_&popN._INinclude_2016_10, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_11,  
	rev_cohort=rif2016.INpatient_revenue_11, include_cohort=pop_&popN._INinclude_2016_11, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_12,  
	rev_cohort=rif2016.INpatient_revenue_12, include_cohort=pop_&popN._INinclude_2016_12, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_01,  
	rev_cohort=rif2017.INpatient_revenue_01, include_cohort=pop_&popN._INinclude_2017_1, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_02,  
	rev_cohort=rif2017.INpatient_revenue_02, include_cohort=pop_&popN._INinclude_2017_2, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_03,  
	rev_cohort=rif2017.INpatient_revenue_03, include_cohort=pop_&popN._INinclude_2017_3, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_04,  
	rev_cohort=rif2017.INpatient_revenue_04, include_cohort=pop_&popN._INinclude_2017_4, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_05,  
	rev_cohort=rif2017.INpatient_revenue_05, include_cohort=pop_&popN._INinclude_2017_5, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_06,  
	rev_cohort=rif2017.INpatient_revenue_06, include_cohort=pop_&popN._INinclude_2017_6, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_07,  
	rev_cohort=rif2017.INpatient_revenue_07, include_cohort=pop_&popN._INinclude_2017_7, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_08,  
	rev_cohort=rif2017.INpatient_revenue_08, include_cohort=pop_&popN._INinclude_2017_8, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_09,  
	rev_cohort=rif2017.INpatient_revenue_09, include_cohort=pop_&popN._INinclude_2017_9, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_10,  
	rev_cohort=rif2017.INpatient_revenue_10, include_cohort=pop_&popN._INinclude_2017_10, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_11,  
	rev_cohort=rif2017.INpatient_revenue_11, include_cohort=pop_&popN._INinclude_2017_11, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_12,  
	rev_cohort=rif2017.INpatient_revenue_12, include_cohort=pop_&popN._INinclude_2017_12, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_01,  
	rev_cohort=rifq2018.INpatient_revenue_01, include_cohort=pop_&popN._INinclude_2018_1, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_02,  
	rev_cohort=rifq2018.INpatient_revenue_02, include_cohort=pop_&popN._INinclude_2018_2, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_03,  
	rev_cohort=rifq2018.INpatient_revenue_03, include_cohort=pop_&popN._INinclude_2018_3, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_04,  
	rev_cohort=rifq2018.INpatient_revenue_04, include_cohort=pop_&popN._INinclude_2018_4, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_05,  
	rev_cohort=rifq2018.INpatient_revenue_05, include_cohort=pop_&popN._INinclude_2018_5, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_06,  
	rev_cohort=rifq2018.INpatient_revenue_06, include_cohort=pop_&popN._INinclude_2018_6, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_07,  
	rev_cohort=rifq2018.INpatient_revenue_07, include_cohort=pop_&popN._INinclude_2018_7, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_08,  
	rev_cohort=rifq2018.INpatient_revenue_08, include_cohort=pop_&popN._INinclude_2018_8, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_09,  
	rev_cohort=rifq2018.INpatient_revenue_09, include_cohort=pop_&popN._INinclude_2018_9, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_10,  
	rev_cohort=rifq2018.INpatient_revenue_10, include_cohort=pop_&popN._INinclude_2018_10, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_11,  
	rev_cohort=rifq2018.INpatient_revenue_11, include_cohort=pop_&popN._INinclude_2018_11, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_12,  
	rev_cohort=rifq2018.INpatient_revenue_12, include_cohort=pop_&popN._INinclude_2018_12, ccn=ccn2016);

data pop_&popN._INinclude (keep= &bene_id &clm_id elig_dt elig: setting_elig:
							pop_num elig_compendium_hospital_id  &gndr_cd &clm_dob bene_race_cd
							&clm_beg_dt_in &clm_end_dt_in  &ptnt_dschrg_stus_cd
							&nch_clm_type_cd &CLM_IP_ADMSN_TYPE_CD &clm_fac_type_cd &clm_src_ip_admsn_cd 
							&admtg_dgns_cd &clm_drg_cd  hcpcs_cd1
							&diag_pfx.&diag_cd_min   &proc_pfx.&proc_cd_min
							prvdr_num prvdr_state_cd OP_PHYSN_SPCLTY_CD rev_cntr1
							at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi
							/*RFR_PHYSN_NPI*/
							bene_cnty_cd bene_state_cd 	bene_mlg_cntct_zip_cd
						);
set pop_&popN._INinclude: 	;
setting_elig='IP';
setting_elig_ip=1;
elig_compendium_hospital_id=compendium_hospital_id;
elig_year=year(elig_dt);
elig_qtr=qtr(elig_dt);
elig_prvdr_num=prvdr_num;
elig_OP_PHYSN_SPCLTY_CD=OP_PHYSN_SPCLTY_CD;
elig_prvdr_state_cd=prvdr_state_cd;
elig_at_physn_npi=at_physn_npi;
elig_op_physn_npi =op_physn_npi ;
elig_org_npi_num=org_npi_num;
elig_ot_physn_npi=ot_physn_npi;
elig_rndrng_physn_npi=rndrng_physn_npi;
elig_gndr_cd=&gndr_cd;
elig_bene_race_cd=bene_race_cd;
elig_bene_cnty_cd=bene_cnty_cd;
elig_bene_state_cd=bene_state_cd; 	
elig_bene_mlg_cntct_zip_cd=bene_mlg_cntct_zip_cd;
format bene_state_cd prvdr_state_cd $state. OP_PHYSN_SPCLTY_CD $speccd. rev_cntr1 $rev_cntr.
		&clm_src_ip_admsn_cd $src1adm. &nch_clm_type_cd $clm_typ. &CLM_IP_ADMSN_TYPE_CD $typeadm.
		&ptnt_dschrg_stus_cd $stuscd. &gndr_cd gender. bene_race_cd race. &clm_drg_cd drg.
		&icd_dgns_cd1 &admtg_dgns_cd $dgns. &icd_prcdr_cd1 $prcdr. hcpcs_cd1 $hcpcs. ;
run;
/* get rid of duplicate rows so that each bene contributes 1x per hospital/year/qtr */
proc sort data=pop_&popN._INinclude NODUPKEY; by elig_compendium_hospital_id elig_year elig_qtr &bene_id elig_dt; run;
proc sort data=pop_&popN._INinclude NODUPKEY; by elig_compendium_hospital_id elig_year elig_qtr &bene_id ; run;

/*** this section is related to OP - outpatient claims--for eligibility***/
*%claims_rev(date=&clm_from_dt, source=rif2015.OUTpatient_claims_07,  
	rev_cohort=rif2015.inpatient_revenue_07, include_cohort=pop_&popN._OUTinclude_2015_7, ccn=ccn2016);
*%claims_rev(date=&clm_from_dt, source=rif2015.OUTpatient_claims_08,  
	rev_cohort=rif2015.outpatient_revenue_08, include_cohort=pop_&popN._OUTinclude_2015_8, ccn=ccn2016);
*%claims_rev(date=&clm_from_dt, source=rif2015.OUTpatient_claims_09,  
	rev_cohort=rif2015.outpatient_revenue_09, include_cohort=pop_&popN._OUTinclude_2015_9, ccn=ccn2016);
*%claims_rev(date=&clm_from_dt, source=rif2015.OUTpatient_claims_10,  
	rev_cohort=rif2015.outpatient_revenue_10, include_cohort=pop_&popN._OUTinclude_2015_10, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2015.OUTpatient_claims_11,  
	rev_cohort=rif2015.outpatient_revenue_11, include_cohort=pop_&popN._OUTinclude_2015_11, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2015.OUTpatient_claims_12,  
	rev_cohort=rif2015.outpatient_revenue_12, include_cohort=pop_&popN._OUTinclude_2015_12, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_01,  
	rev_cohort=rif2016.outpatient_revenue_01, include_cohort=pop_&popN._OUTinclude_2016_1, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_02,  
	rev_cohort=rif2016.outpatient_revenue_02, include_cohort=pop_&popN._OUTinclude_2016_2, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_03,  
	rev_cohort=rif2016.outpatient_revenue_03, include_cohort=pop_&popN._OUTinclude_2016_3, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_04,  
	rev_cohort=rif2016.outpatient_revenue_04, include_cohort=pop_&popN._OUTinclude_2016_4, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_05,  
	rev_cohort=rif2016.outpatient_revenue_05, include_cohort=pop_&popN._OUTinclude_2016_5, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_06,  
	rev_cohort=rif2016.outpatient_revenue_06, include_cohort=pop_&popN._OUTinclude_2016_6, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_07,  
	rev_cohort=rif2016.outpatient_revenue_07, include_cohort=pop_&popN._OUTinclude_2016_7, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_08,  
	rev_cohort=rif2016.outpatient_revenue_08, include_cohort=pop_&popN._OUTinclude_2016_8, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_09,  
	rev_cohort=rif2016.outpatient_revenue_09, include_cohort=pop_&popN._OUTinclude_2016_9, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_10,  
	rev_cohort=rif2016.outpatient_revenue_10, include_cohort=pop_&popN._OUTinclude_2016_10, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_11,  
	rev_cohort=rif2016.outpatient_revenue_11, include_cohort=pop_&popN._OUTinclude_2016_11, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_12,  
	rev_cohort=rif2016.outpatient_revenue_12, include_cohort=pop_&popN._OUTinclude_2016_12, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_01,  
	rev_cohort=rif2017.outpatient_revenue_01, include_cohort=pop_&popN._OUTinclude_2017_1, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_02,  
	rev_cohort=rif2017.outpatient_revenue_02, include_cohort=pop_&popN._OUTinclude_2017_2, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_03,  
	rev_cohort=rif2017.outpatient_revenue_03, include_cohort=pop_&popN._OUTinclude_2017_3, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_04,  
	rev_cohort=rif2017.outpatient_revenue_04, include_cohort=pop_&popN._OUTinclude_2017_4, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_05,  
	rev_cohort=rif2017.outpatient_revenue_05, include_cohort=pop_&popN._OUTinclude_2017_5, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_06,  
	rev_cohort=rif2017.outpatient_revenue_06, include_cohort=pop_&popN._OUTinclude_2017_6, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_07,  
	rev_cohort=rif2017.outpatient_revenue_07, include_cohort=pop_&popN._OUTinclude_2017_7, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_08,  
	rev_cohort=rif2017.outpatient_revenue_08, include_cohort=pop_&popN._OUTinclude_2017_8, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_09,  
	rev_cohort=rif2017.outpatient_revenue_09, include_cohort=pop_&popN._OUTinclude_2017_9, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_10,  
	rev_cohort=rif2017.outpatient_revenue_10, include_cohort=pop_&popN._OUTinclude_2017_10, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_11,  
	rev_cohort=rif2017.outpatient_revenue_11, include_cohort=pop_&popN._OUTinclude_2017_11, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_12,  
	rev_cohort=rif2017.outpatient_revenue_12, include_cohort=pop_&popN._OUTinclude_2017_12, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_01,  
	rev_cohort=rifq2018.outpatient_revenue_01, include_cohort=pop_&popN._OUTinclude_2018_1, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_02,  
	rev_cohort=rifq2018.outpatient_revenue_02, include_cohort=pop_&popN._OUTinclude_2018_2, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_03,  
	rev_cohort=rifq2018.outpatient_revenue_03, include_cohort=pop_&popN._OUTinclude_2018_3, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_04,  
	rev_cohort=rifq2018.outpatient_revenue_04, include_cohort=pop_&popN._OUTinclude_2018_4, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_05,  
	rev_cohort=rifq2018.outpatient_revenue_05, include_cohort=pop_&popN._OUTinclude_2018_5, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_06,  
	rev_cohort=rifq2018.outpatient_revenue_06, include_cohort=pop_&popN._OUTinclude_2018_6, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_07,  
	rev_cohort=rifq2018.outpatient_revenue_07, include_cohort=pop_&popN._OUTinclude_2018_7, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_08,  
	rev_cohort=rifq2018.outpatient_revenue_08, include_cohort=pop_&popN._OUTinclude_2018_8, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_09,  
	rev_cohort=rifq2018.outpatient_revenue_09, include_cohort=pop_&popN._OUTinclude_2018_9, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_10,  
	rev_cohort=rifq2018.outpatient_revenue_10, include_cohort=pop_&popN._OUTinclude_2018_10, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_11,  
	rev_cohort=rifq2018.outpatient_revenue_11, include_cohort=pop_&popN._OUTinclude_2018_11, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_12,  
	rev_cohort=rifq2018.outpatient_revenue_12, include_cohort=pop_&popN._OUTinclude_2018_12, ccn=ccn2016);

data pop_&popN._OUTinclude (keep= &bene_id &clm_id elig_dt elig: setting_elig:
							pop_num elig_compendium_hospital_id   &gndr_cd &clm_dob bene_race_cd
							&clm_from_dt &clm_thru_dt   &ptnt_dschrg_stus_cd
							&nch_clm_type_cd &clm_fac_type_cd  
							&hcpcs_cd
							&diag_pfx.&diag_cd_min   &proc_pfx.&proc_cd_min
							prvdr_num prvdr_state_cd OP_PHYSN_SPCLTY_CD rev_cntr
							at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi
							/*RFR_PHYSN_NPI*/
							bene_cnty_cd bene_state_cd 	bene_mlg_cntct_zip_cd
						);
set pop_&popN._OUTinclude: 	;
setting_elig='OP';
setting_elig_op=1;
elig_compendium_hospital_id=compendium_hospital_id;
elig_year=year(elig_dt);
elig_qtr=qtr(elig_dt);
elig_prvdr_num=prvdr_num;
elig_OP_PHYSN_SPCLTY_CD=OP_PHYSN_SPCLTY_CD;
elig_prvdr_state_cd=prvdr_state_cd;
elig_at_physn_npi=at_physn_npi;
elig_op_physn_npi =op_physn_npi ;
elig_org_npi_num=org_npi_num;
elig_ot_physn_npi=ot_physn_npi;
elig_rndrng_physn_npi=rndrng_physn_npi;
elig_gndr_cd=&gndr_cd;
elig_bene_race_cd=bene_race_cd;
elig_bene_cnty_cd=bene_cnty_cd;
elig_bene_state_cd=bene_state_cd; 	
elig_bene_mlg_cntct_zip_cd=bene_mlg_cntct_zip_cd;
format bene_state_cd prvdr_state_cd $state. OP_PHYSN_SPCLTY_CD $speccd. rev_cntr1 $rev_cntr.
		&clm_src_ip_admsn_cd $src1adm. &nch_clm_type_cd $clm_typ. &CLM_IP_ADMSN_TYPE_CD $typeadm.
		&ptnt_dschrg_stus_cd $stuscd. &gndr_cd gender. bene_race_cd race. &clm_drg_cd drg.
		&icd_dgns_cd1 &admtg_dgns_cd $dgns. &icd_prcdr_cd1 $prcdr. hcpcs_cd1 $hcpcs. ;
run;
run;
/* get rid of duplicate rows so that each bene contributes 1x per hospital/year/qtr */
proc sort data=pop_&popN._OUTinclude NODUPKEY; by elig_compendium_hospital_id elig_year elig_qtr &bene_id elig_dt; run;
proc sort data=pop_&popN._OUTinclude NODUPKEY; by elig_compendium_hospital_id elig_year elig_qtr &bene_id ; run; 

data &permlib..pop_&popN._elig;
set 	pop_&popN._OUTinclude 
		pop_&popN._INinclude ;
run;
*person can contribute only once even if seen in inpatient and outpatient in same hosp/year/qtr;
proc sort data=&permlib..pop_&popN._elig NODUPKEY; by elig_compendium_hospital_id elig_year elig_qtr &bene_id ;run;

*end identification of eligibility;

*Start: Identify who popped;
/*** this section is related to IP - inpatient claims ***/
%macro claims_rev(date=, source=, rev_cohort=, include_cohort=, ccn=);
/* identify hcpcs  */
proc sql;
create table include_cohort1a (compress=yes) as
select &bene_id, &clm_id, &rev_cntr,
	&hcpcs_cd, case when &hcpcs_cd in (&includ_hcpcs) then 1 else 0 end as &flag_popped
from 
	&rev_cohort
where 
	&hcpcs_cd in (&includ_hcpcs);
quit;
/* pull claim info for those with HCPCS (need to do this to get dx codes)*/
proc sql;
	create table include_cohort1b (compress=yes) as
select a.&rev_cntr, a.&hcpcs_cd, a.&flag_popped, b.*
from 
	include_cohort1a a, 
	&source b
where 
	(a.&bene_id=b.&bene_id and a.&clm_id=b.&clm_id);
quit;/*link to ccn*/
proc sql;
	create table include_cohort1c (compress=yes) as
select *
from 
	&permlib..ahrq_ccn a,
	include_cohort1b b	
where 
	b.prvdr_num = a.&ccn
;
quit;
/*pull icd procedure criteria from claims*/
proc sql;
	create table include_cohort1d (compress=yes) as
select *
from 
	&source
where
		icd_prcdr_cd1 in(&includ_pr10) or
		icd_prcdr_cd2 in(&includ_pr10) or
		icd_prcdr_cd3 in(&includ_pr10) or
		icd_prcdr_cd4 in(&includ_pr10) or
		icd_prcdr_cd5 in(&includ_pr10) or
		icd_prcdr_cd6 in(&includ_pr10) or
		icd_prcdr_cd7 in(&includ_pr10) or
		icd_prcdr_cd8 in(&includ_pr10) or
		icd_prcdr_cd9 in(&includ_pr10) or
		icd_prcdr_cd10 in(&includ_pr10) or
		icd_prcdr_cd11 in(&includ_pr10) or
		icd_prcdr_cd12 in(&includ_pr10) or
		icd_prcdr_cd13 in(&includ_pr10) or
		icd_prcdr_cd14 in(&includ_pr10) or
		icd_prcdr_cd15 in(&includ_pr10) or
		icd_prcdr_cd16 in(&includ_pr10) or
		icd_prcdr_cd17 in(&includ_pr10) or
		icd_prcdr_cd18 in(&includ_pr10) or
		icd_prcdr_cd19 in(&includ_pr10) or
		icd_prcdr_cd20 in(&includ_pr10) or
		icd_prcdr_cd21 in(&includ_pr10) or
		icd_prcdr_cd22 in(&includ_pr10) or
		icd_prcdr_cd23 in(&includ_pr10) or
		icd_prcdr_cd24 in(&includ_pr10) or
		icd_prcdr_cd25 in(&includ_pr10)		;
quit;
/*link icd prcdr identified to revenue center*/
proc sql;
	create table include_cohort1e (compress=yes) as
select a.&rev_cntr, b.*
from 
	&rev_cohort 		a,
	include_cohort1d 	b 
where 
	(a.&bene_id=b.&bene_id and a.&clm_id=b.&clm_id);
quit;
/* link to CCN */
proc sql;
	create table include_cohort1f (compress=yes) as
select *
from 
	&permlib..ahrq_ccn a,
	include_cohort1e b	
where 
	b.prvdr_num = a.&ccn
;
quit;
*merge HCPCS and PRCDR identified pops together;
Data include_cohort1g; 
set include_cohort1c include_cohort1f;  
if &rev_cntr in(&ED_rev_cntr) then pop_ed=1; label pop_ed='popped: revenue center indicated emergency department';
&flag_popped_dt=&date; 
	format &flag_popped_dt date9.; 						label &flag_popped_dt			=	&flag_popped_dt_label;
				 										label &flag_popped				=	&flag_popped_label;
array pr(&proc_cd_max) &proc_pfx.&proc_cd_min - &proc_pfx.&proc_cd_max;
	do i=1 to &proc_cd_max;
		if pr(i) in(&includ_pr10) then &flag_popped=1;
end; 
array dx(25) &diag_pfx.&diag_cd_min - &diag_pfx.&diag_cd_max;
	do j=1 to &diag_cd_max;
		if substr(dx(j),1,&exclud_dx10_n) in(&EXCLUD_dx10) then DELETE=1;			
end;
IF DELETE  =  1 then delete; 
*if clm_drg_cd notin(&includ_drg) then delete;
if &flag_popped ne 1 then delete;
run; 
*link to eligibility--require the timing of inclusion dx and procedure match-up;
proc sql;
	create table &include_cohort (compress=yes) as
select a.elig_dt, b.*
from 
	&permlib..pop_&popN._elig a,
	include_cohort1g		  b	
where 
		a.&bene_id=b.&bene_id 
		and (	(a.elig_dt-60) <= b.&flag_popped_dt <=a.elig_dt); *had the eligible dx within 60 days of pop date; 
quit;
%mend;
%claims_rev(date=&clm_beg_dt_in, source=rif2016.inpatient_claims_01, rev_cohort=rif2016.inpatient_revenue_01, include_cohort=pop_&popN._IN_2016_1, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.inpatient_claims_02, rev_cohort=rif2016.inpatient_revenue_02, include_cohort=pop_&popN._IN_2016_2, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.inpatient_claims_03, rev_cohort=rif2016.inpatient_revenue_03, include_cohort=pop_&popN._IN_2016_3, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.inpatient_claims_04, rev_cohort=rif2016.inpatient_revenue_04, include_cohort=pop_&popN._IN_2016_4, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.inpatient_claims_05, rev_cohort=rif2016.inpatient_revenue_05, include_cohort=pop_&popN._IN_2016_5, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.inpatient_claims_06, rev_cohort=rif2016.inpatient_revenue_06, include_cohort=pop_&popN._IN_2016_6, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.inpatient_claims_07, rev_cohort=rif2016.inpatient_revenue_07, include_cohort=pop_&popN._IN_2016_7, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.inpatient_claims_08, rev_cohort=rif2016.inpatient_revenue_08, include_cohort=pop_&popN._IN_2016_8, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.inpatient_claims_09, rev_cohort=rif2016.inpatient_revenue_09, include_cohort=pop_&popN._IN_2016_9, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.inpatient_claims_10, rev_cohort=rif2016.inpatient_revenue_10, include_cohort=pop_&popN._IN_2016_10, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.inpatient_claims_11, rev_cohort=rif2016.inpatient_revenue_11, include_cohort=pop_&popN._IN_2016_11, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.inpatient_claims_12, rev_cohort=rif2016.inpatient_revenue_12, include_cohort=pop_&popN._IN_2016_12, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.inpatient_claims_01, rev_cohort=rif2017.inpatient_revenue_01, include_cohort=pop_&popN._IN_2017_1, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.inpatient_claims_02, rev_cohort=rif2017.inpatient_revenue_02, include_cohort=pop_&popN._IN_2017_2, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.inpatient_claims_03, rev_cohort=rif2017.inpatient_revenue_03, include_cohort=pop_&popN._IN_2017_3, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.inpatient_claims_04, rev_cohort=rif2017.inpatient_revenue_04, include_cohort=pop_&popN._IN_2017_4, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.inpatient_claims_05, rev_cohort=rif2017.inpatient_revenue_05, include_cohort=pop_&popN._IN_2017_5, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.inpatient_claims_06, rev_cohort=rif2017.inpatient_revenue_06, include_cohort=pop_&popN._IN_2017_6, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.inpatient_claims_07, rev_cohort=rif2017.inpatient_revenue_07, include_cohort=pop_&popN._IN_2017_7, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.inpatient_claims_08, rev_cohort=rif2017.inpatient_revenue_08, include_cohort=pop_&popN._IN_2017_8, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.inpatient_claims_09, rev_cohort=rif2017.inpatient_revenue_09, include_cohort=pop_&popN._IN_2017_9, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.inpatient_claims_10, rev_cohort=rif2017.inpatient_revenue_10, include_cohort=pop_&popN._IN_2017_10, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.inpatient_claims_11, rev_cohort=rif2017.inpatient_revenue_11, include_cohort=pop_&popN._IN_2017_11, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.inpatient_claims_12, rev_cohort=rif2017.inpatient_revenue_12, include_cohort=pop_&popN._IN_2017_12, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.inpatient_claims_01, rev_cohort=rifq2018.inpatient_revenue_01, include_cohort=pop_&popN._IN_2018_1, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.inpatient_claims_02, rev_cohort=rifq2018.inpatient_revenue_02, include_cohort=pop_&popN._IN_2018_2, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.inpatient_claims_03, rev_cohort=rifq2018.inpatient_revenue_03, include_cohort=pop_&popN._IN_2018_3, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.inpatient_claims_04, rev_cohort=rifq2018.inpatient_revenue_04, include_cohort=pop_&popN._IN_2018_4, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.inpatient_claims_05, rev_cohort=rifq2018.inpatient_revenue_05, include_cohort=pop_&popN._IN_2018_5, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.inpatient_claims_06, rev_cohort=rifq2018.inpatient_revenue_06, include_cohort=pop_&popN._IN_2018_6, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.inpatient_claims_07, rev_cohort=rifq2018.inpatient_revenue_07, include_cohort=pop_&popN._IN_2018_7, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.inpatient_claims_08, rev_cohort=rifq2018.inpatient_revenue_08, include_cohort=pop_&popN._IN_2018_8, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.inpatient_claims_09, rev_cohort=rifq2018.inpatient_revenue_09, include_cohort=pop_&popN._IN_2018_9, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.inpatient_claims_10, rev_cohort=rifq2018.inpatient_revenue_10, include_cohort=pop_&popN._IN_2018_10, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.inpatient_claims_11, rev_cohort=rifq2018.inpatient_revenue_11, include_cohort=pop_&popN._IN_2018_11, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.inpatient_claims_12, rev_cohort=rifq2018.inpatient_revenue_12, include_cohort=pop_&popN._IN_2018_12, ccn=ccn2016);

data pop_&popN._IN (keep=  pop: &flag_popped_dt elig: setting: 
							&bene_id &clm_id 
							&clm_beg_dt_in &clm_end_dt_in &clm_dob  &ptnt_dschrg_stus_cd
							&nch_clm_type_cd &CLM_IP_ADMSN_TYPE_CD &clm_fac_type_cd &clm_src_ip_admsn_cd 
							&admtg_dgns_cd &clm_drg_cd  
							prvdr_num prvdr_state_cd OP_PHYSN_SPCLTY_CD rev_cntr
							at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi
							/*RFR_PHYSN_NPI*/
							&gndr_cd bene_race_cd	bene_cnty_cd
							bene_state_cd 	bene_mlg_cntct_zip_cd );
set pop_&popN._IN_:;
&pop_age=(&clm_beg_dt_in-&clm_dob)/365.25; 				label &pop_age					=	&pop_age_label;
&pop_age=round(&pop_age);
&pop_los=&clm_end_dt_in-&clm_beg_dt_in;					label &pop_los					=	&pop_los_label;
&pop_nch_clm_type_cd=put(&nch_clm_type_cd, clm_type_cd.); 
														label &pop_nch_clm_type_cd		=	&pop_nch_clm_type_cd_label;
&pop_CLM_IP_ADMSN_TYPE_CD = put(&CLM_IP_ADMSN_TYPE_CD,$IP_ADMSN_TYPE_CD.);
&pop_clm_fac_type_cd = &clm_fac_type_cd; 				label &pop_clm_fac_type_cd     	= 	&pop_clm_fac_type_cd_label;
&pop_clm_src_ip_admsn_cd = &clm_src_ip_admsn_cd; 		label &pop_clm_src_ip_admsn_cd 	= 	&pop_clm_src_ip_admsn_cd_label;
&pop_ptnt_dschrg_stus_cd = &ptnt_dschrg_stus_cd; 		label &pop_ptnt_dschrg_stus_cd 	= 	&pop_ptnt_dschrg_stus_cd;
&pop_admtg_dgns_cd=put(&admtg_dgns_cd,$dgns.);
&pop_icd_dgns_cd1=put(&icd_dgns_cd1,$dgns.);
&pop_icd_prcdr_cd1=put(&icd_prcdr_cd1,$prcdr.);
&pop_clm_drg_cd=put(&clm_drg_cd,$drg.);
&pop_hcpcs_cd=put(&hcpcs_cd,$hcpcs.);
&pop_OP_PHYSN_SPCLTY_CD=&OP_PHYSN_SPCLTY_CD;
pop_compendium_hospital_id=compendium_hospital_id;
setting_pop='IP'; label setting_pop='setting where patient popped';
setting_pop_ip=1;
&pop_year=year(&flag_popped_dt);
pop_year=year(&flag_popped_dt);
pop_qtr=qtr(&flag_popped_dt);
if elig_dt = . then delete;
if &pop_year<2016 then delete;
if &pop_year>2018 then delete;
format bene_state_cd prvdr_state_cd $state. &pop_OP_PHYSN_SPCLTY_CD $speccd. &rev_cntr $rev_cntr.
		&pop_clm_src_ip_admsn_cd $src1adm.
		&pop_ptnt_dschrg_stus_cd $stuscd.
		&pop_icd_dgns_cd1 $dgns. &pop_icd_prcdr_cd1 $prcdr. &pop_hcpcs_cd $hcpcs. ;
run;
/* get rid of duplicate rows so that each bene contributes 1x per hospital/year/qtr */
proc sort data=pop_&popN._IN NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id elig_dt; run;
proc sort data=pop_&popN._IN NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id ; run; 

/*** this section is related to OP Popped- OUTpatient claims ***/
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_01, rev_cohort=rif2016.OUTpatient_revenue_01, include_cohort=pop_&popN._out_2016_1, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_02, rev_cohort=rif2016.OUTpatient_revenue_02, include_cohort=pop_&popN._out_2016_2, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_03, rev_cohort=rif2016.OUTpatient_revenue_03, include_cohort=pop_&popN._out_2016_3, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_04, rev_cohort=rif2016.OUTpatient_revenue_04, include_cohort=pop_&popN._out_2016_4, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_05, rev_cohort=rif2016.OUTpatient_revenue_05, include_cohort=pop_&popN._out_2016_5, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_06, rev_cohort=rif2016.OUTpatient_revenue_06, include_cohort=pop_&popN._out_2016_6, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_07, rev_cohort=rif2016.OUTpatient_revenue_07, include_cohort=pop_&popN._out_2016_7, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_08, rev_cohort=rif2016.OUTpatient_revenue_08, include_cohort=pop_&popN._out_2016_8, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_09, rev_cohort=rif2016.OUTpatient_revenue_09, include_cohort=pop_&popN._out_2016_9, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_10, rev_cohort=rif2016.OUTpatient_revenue_10, include_cohort=pop_&popN._out_2016_10, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_11, rev_cohort=rif2016.OUTpatient_revenue_11, include_cohort=pop_&popN._out_2016_11, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_12, rev_cohort=rif2016.OUTpatient_revenue_12, include_cohort=pop_&popN._out_2016_12, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_01, rev_cohort=rif2017.OUTpatient_revenue_01, include_cohort=pop_&popN._out_2017_1, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_02, rev_cohort=rif2017.OUTpatient_revenue_02, include_cohort=pop_&popN._out_2017_2, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_03, rev_cohort=rif2017.OUTpatient_revenue_03, include_cohort=pop_&popN._out_2017_3, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_04, rev_cohort=rif2017.OUTpatient_revenue_04, include_cohort=pop_&popN._out_2017_4, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_05, rev_cohort=rif2017.OUTpatient_revenue_05, include_cohort=pop_&popN._out_2017_5, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_06, rev_cohort=rif2017.OUTpatient_revenue_06, include_cohort=pop_&popN._out_2017_6, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_07, rev_cohort=rif2017.OUTpatient_revenue_07, include_cohort=pop_&popN._out_2017_7, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_08, rev_cohort=rif2017.OUTpatient_revenue_08, include_cohort=pop_&popN._out_2017_8, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_09, rev_cohort=rif2017.OUTpatient_revenue_09, include_cohort=pop_&popN._out_2017_9, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_10, rev_cohort=rif2017.OUTpatient_revenue_10, include_cohort=pop_&popN._out_2017_10, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_11, rev_cohort=rif2017.OUTpatient_revenue_11, include_cohort=pop_&popN._out_2017_11, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_12, rev_cohort=rif2017.OUTpatient_revenue_12, include_cohort=pop_&popN._out_2017_12, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_01, rev_cohort=rifq2018.OUTpatient_revenue_01, include_cohort=pop_&popN._out_2018_1, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_02, rev_cohort=rifq2018.OUTpatient_revenue_02, include_cohort=pop_&popN._out_2018_2, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_03, rev_cohort=rifq2018.OUTpatient_revenue_03, include_cohort=pop_&popN._out_2018_3, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_04, rev_cohort=rifq2018.OUTpatient_revenue_04, include_cohort=pop_&popN._out_2018_4, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_05, rev_cohort=rifq2018.OUTpatient_revenue_05, include_cohort=pop_&popN._out_2018_5, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_06, rev_cohort=rifq2018.OUTpatient_revenue_06, include_cohort=pop_&popN._out_2018_6, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_07, rev_cohort=rifq2018.OUTpatient_revenue_07, include_cohort=pop_&popN._out_2018_7, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_08, rev_cohort=rifq2018.OUTpatient_revenue_08, include_cohort=pop_&popN._out_2018_8, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_09, rev_cohort=rifq2018.OUTpatient_revenue_09, include_cohort=pop_&popN._out_2018_9, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_10, rev_cohort=rifq2018.OUTpatient_revenue_10, include_cohort=pop_&popN._out_2018_10, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_11, rev_cohort=rifq2018.OUTpatient_revenue_11, include_cohort=pop_&popN._out_2018_11, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_12, rev_cohort=rifq2018.OUTpatient_revenue_12, include_cohort=pop_&popN._out_2018_12, ccn=ccn2016);

data pop_&popN._out (keep=  pop: &flag_popped_dt elig: setting: 
							&bene_id &clm_id 
							&clm_from_dt &clm_thru_dt &clm_dob  &ptnt_dschrg_stus_cd
							&nch_clm_type_cd &clm_fac_type_cd    
							prvdr_num prvdr_state_cd OP_PHYSN_SPCLTY_CD rev_cntr
							at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi
							/*RFR_PHYSN_NPI*/
							&gndr_cd bene_race_cd	bene_cnty_cd
							bene_state_cd 	bene_mlg_cntct_zip_cd	 );
set pop_&popN._out_:;
&flag_popped_dt=&clm_from_dt; 
	format &flag_popped_dt date9.; 			label &flag_popped_dt	=	&flag_popped_dt_label;
				 							label &flag_popped		=	&flag_popped_label;
&pop_age=(&clm_from_dt-&clm_dob)/365.25; 	label &pop_age			=	&pop_age_label;
&pop_age=round(&pop_age);
&pop_los=&clm_thru_dt-&clm_from_dt;			label &pop_los			=	&pop_los_label;
&pop_nch_clm_type_cd=put(&nch_clm_type_cd, clm_type_cd.); label &pop_nch_clm_type_cd	=	&pop_nch_clm_type_cd_label;
&pop_icd_dgns_cd1=put(&icd_dgns_cd1,$dgns.);
&pop_icd_prcdr_cd1=put(&icd_prcdr_cd1,$prcdr.);
&pop_hcpcs_cd=put(&hcpcs_cd,$hcpcs.);
&pop_OP_PHYSN_SPCLTY_CD=&OP_PHYSN_SPCLTY_CD; format &pop_OP_PHYSN_SPCLTY_CD speccd.;
pop_compendium_hospital_id=compendium_hospital_id;
setting_pop='OP';
setting_pop_op=1;
&pop_year=year(&flag_popped_dt);
pop_year=year(&flag_popped_dt);
pop_qtr=qtr(&flag_popped_dt);
if elig_dt = . then delete;
if &pop_year<2016 then delete;
if &pop_year>2018 then delete;
format &pop_OP_PHYSN_SPCLTY_CD $speccd. &rev_cntr $rev_cntr.
&pop_icd_dgns_cd1 $dgns. &pop_icd_prcdr_cd1 $prcdr. &pop_hcpcs_cd $hcpcs.;
run;
/* get rid of duplicate rows so that each bene contributes 1x per hospital/year/qtr */
proc sort data=pop_&popN._OUT NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id elig_dt; run;
proc sort data=pop_&popN._OUT NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id ; run; 

data pop_&popN._in_out_popped
	(keep = bene_id elig: pop: setting: 
			/*&gndr_cd bene_race_cd	bene_cnty_cd bene_state_cd 	bene_mlg_cntct_zip_cd*/
			);
set pop_&popN._IN pop_&popN._OUT;
pop_year=year(&flag_popped_dt);
pop_qtr=qtr(&flag_popped_dt);
pop_prvdr_num=prvdr_num;
pop_OP_PHYSN_SPCLTY_CD=OP_PHYSN_SPCLTY_CD;
pop_prvdr_state_cd=prvdr_state_cd;
pop_at_physn_npi=at_physn_npi;
pop_op_physn_npi =op_physn_npi ;
pop_org_npi_num=org_npi_num;
pop_ot_physn_npi=ot_physn_npi;
pop_rndrng_physn_npi=rndrng_physn_npi;
pop_gndr_cd=&gndr_cd;
pop_bene_race_cd=bene_race_cd;
pop_bene_cnty_cd=bene_cnty_cd;
pop_bene_state_cd=bene_state_cd; 	
pop_bene_mlg_cntct_zip_cd=bene_mlg_cntct_zip_cd;
run;
*person can contribute only once even if seen in inpatient and outpatient in same hosp/year/qtr;
proc sort data=pop_&popN._in_out_popped NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id; run;

*End: Identify who popped;

*Start link eligible and popped;
proc sort data=pop_&popN._in_out_popped		NODUPKEY; by  &bene_id elig_dt;run;
proc sort data=&permlib..pop_&popN._elig	NODUPKEY; by  &bene_id elig_dt;run;

data &permlib..pop_&popN._in_out (drop=compendium_hospital_id);
merge pop_&popN._in_out_popped &permlib..pop_&popN._elig;
by &bene_id elig_dt;
if elig_compendium_hospital_id=' ' and pop_compendium_hospital_id=' ' then delete;
if pop_compendium_hospital_id=' ' then pop_compendium_hospital_id=elig_compendium_hospital_id;
label pop_compendium_hospital_id='Hospital where patient popped, if patient did not pop, the hospital where patient
	was first eligible during the quarter';
run;
/*allow to pop only once per qtr*/
proc sort data=&permlib..pop_&popN._in_out NODUPKEY; by pop_compendium_hospital_id year qtr &bene_id;run;

title 'Popped Inpatient or Outpatient (No Carrier) For Analysis';
proc freq data=&permlib..pop_&popN._in_out; 
table  	&pop_year pop_year setting_pop setting_elig; run;
proc contents data=&permlib..pop_&popN._in_out; run;
*End link eligible and popped;

*Start summary checks;
/**This section makes summaries for inpatient, outpatient POPPED & eligible **/
*look at popped;
%macro poppedlook(in=);
proc freq data=&in order=freq noprint; 
table  	&flag_popped /nocum out=&flag_popped; run;
proc print data=&flag_popped noobs; where count>=11; run;

title 'Linked to AHRQ compendium hospital';
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
table  	&rev_cntr /nocum out=&rev_cntr (drop = count); run;
proc print data=&rev_cntr noobs; where percent>1; format &rev_cntr $rev_cntr.;run;

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
table  	&gndr_cd /nocum out=&gndr_cd (drop = count); run;
proc print data=&gndr_cd noobs; run;

proc means data=&in mean median min max; var  &pop_age &pop_los; run;
%mend;


*start;
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

*stop;

title 'Inpatient Popped';
%poppedlook(in=pop_&popN._IN);
*delete the temp datasets;
proc datasets lib=work nolist;
 delete setting: elig: pop: icd: clm:
		year qtr &gndr_cd  bene_race_cd 
		&hcpcs_cd &clm_drg_cd &rev_cntr
		&admtg_dgns_cd &OP_PHYSN_SPCLTY_CD nch_clm_type_cd
		&ptnt_dschrg_stus_cd ;
quit;
run;

title 'Eligible from inpatient encounter';
%eliglook(in=pop_&popN._INinclude);
		/*bene_state_cd prvdr_state_cd 
		&pop_OP_PHYSN_SPCLTY_CD &pop_clm_fac_type_cd &pop_ptnt_dschrg_stus_cd
		&pop_nch_clm_type_cd &pop_CLM_IP_ADMSN_TYPE_CD &pop_clm_src_ip_admsn_cd*/ 
proc datasets lib=work nolist;
 delete setting: elig: pop: icd: clm:
		year qtr &gndr_cd  bene_race_cd 
		hcpcs_cd1 &clm_drg_cd rev_cntr1
		&admtg_dgns_cd &OP_PHYSN_SPCLTY_CD nch_clm_type_cd
		&ptnt_dschrg_stus_cd ;
quit;
run;
title 'Outpatient Popped';
%poppedlook(in=pop_&popN._OUT);
proc datasets lib=work nolist;
 delete setting: elig: pop: icd: clm:
		year qtr &gndr_cd  bene_race_cd 
		&hcpcs_cd &clm_drg_cd &rev_cntr
		&admtg_dgns_cd &OP_PHYSN_SPCLTY_CD nch_clm_type_cd
		&ptnt_dschrg_stus_cd ;
quit;
run;
title 'Elgible from outpatient encounter';
%eliglook(in=pop_&popN._OUTinclude);
proc datasets lib=work nolist;
 delete setting: elig: pop: icd: clm:
		year qtr &gndr_cd  bene_race_cd 
		&hcpcs_cd &clm_drg_cd &rev_cntr
		&admtg_dgns_cd &OP_PHYSN_SPCLTY_CD nch_clm_type_cd
		&ptnt_dschrg_stus_cd ;
quit;
run;

*End summary checks;


*need to link ot mbsf to get comorbidity;

*need to average comorbidity, age sex by hospital;

*Start sum for analysis;
do proc summary of eigible then proc summary of popped
merge num and denom

*need to relink ot compendium to make sure using the correct health system.....popped, if not popped then eligible;
*poisson regression;


