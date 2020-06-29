/********************************************************************
* Job Name: jhu_build_Claim_IPOP_ds_project_overuse_num01.sas
* Job Desc: Input for Inpatient & Outpatient (Including Carrier) Claims 
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************/

/*** Indicator description ***/
/* Description and codes from .xlsx file  "ICD-10 conversions_12_17-19" */
/* There are no changes from "ICD-10 conversions_12_17-19" and "ICD-10 conversions_5_28_20"*/

*Edits: Added output for aggregated results on 28jun2020 by shutfle1@jhmi.edu;

/* Indicator 01 */


/*Description from Excel file
More than one emergency department visit in last 30 days of life	

"Motivator: clinicians should know which patients are  at end of life and use resources wisely

Indicator:  More than one ED visit in last 30 days of life

"	Two or more revenue codes for an ED encounter in last 30 days of life 	

ED	All	

Perhaps failure of primary care

*/


/*** start of indicator specific variables ***/

/*inclusion criteria: All patients who died based on death date in or outside of hospital (MBSF file)*/

/*popped: had 2+ ED visits in 30 days prior to death--CMS uses rev center to identify ED visits*/
/*revenue center for inpatient/outpatient identifies ED*/
%global rev_cntr;
%let rev_cntr = rev_cntr;
%let ED_rev_cntr = '0450' '0451' '0452' '0453' '0454' '0455' '0456'
				'0457' '0458' '0459' '0981'  					;
*ed list from https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5905698/;

*there are no diagnosis or procedure inclusion or exclusion criteria for this pop--it is special;

/** Label pop specific variables  **/
%global popN;
%let	popN							= 01;
%let 	flag_popped             		= popped01 								;
%let 	flag_popped_label				= 'indicator 01 popped'					;	
%let	flag_popped_dt					= popped01_dt							;
%let 	flag_popped_dt_label			= 'indicator 01 date patient popped (IP=clm_admsn_dt OP=clm_from_dt)'	;
%let 	pop_age							= pop_01_age							;				
%let	pop_age_label					= 'age popped for pop 01'				;
%let	pop_los							= pop_01_los							;
%let	pop_los_label					= 'length of stay when patient popped'	;
%let	pop_year						= pop_01_year							;
%let	pop_nch_clm_type_cd				= pop_01_nch_clm_type_cd				;
%let  	pop_CLM_IP_ADMSN_TYPE_CD		= pop_01_CLM_IP_ADMSN_TYPE_CD			;
%let	pop_clm_fac_type_cd				= pop_01_clm_fac_type_cd				;
%let	pop_clm_src_ip_admsn_cd			= pop_01_clm_src_ip_admsn_cd			;
%let	pop_ptnt_dschrg_stus_cd  		= pop_01_ptnt_dschrg_stus_cd			;
%let	pop_admtg_dgns_cd				= pop_01_admtg_dgns_cd					;
%let	pop_icd_dgns_cd1				= pop_01_icd_dgns_cd1					;
%let	pop_icd_prcdr_cd1				= pop_01_icd_prcdr_cd1					;
%let	pop_clm_drg_cd					= pop_01_clm_drg_cd						;
%let	pop_hcpcs_cd					= pop_01_hcpcs_cd						;
%let	pop_OP_PHYSN_SPCLTY_CD			= pop_01_OP_PHYSN_SPCLTY_CD				;
%let	pop_nch_clm_type_cd				= pop_01_nch_clm_type_cd				;
%let	pop_nch_clm_type_cd_label		= 'claim/facility type for pop 01' 		;
%let	pop_CLM_IP_ADMSN_TYPE_CD_label	= 'inpatient admission type code for pop 01'	;
%let  	pop_clm_fac_type_cd_label		= 'inpatient clm_fac_type_cd for pop 01';
%let	pop_clm_src_ip_admsn_cd_label	= 'clm_src_ip_admsn_cd for pop 01'		;
%let	pop_ptnt_dschrg_stus_cd_label	= 'discharge status code for pop 01'	;	
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

%let  diag_pfx           = icd_dgns_cd         ;
%let  diag_cd_min        = 1                 	;
%let  diag_cd_max        = 25                 	;

%let  proc_pfx           = icd_prcdr_cd         ;
%let  proc_cd_min        = 1                 	;
%let  proc_cd_max        = 25                 	;

%let  clm_beg_dt_in      = clm_admsn_dt   		;	*_in stands for inpatient;
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
%let  icd_prcdr_cd1		 = icd_prcdr_cd1		;
%let  OP_PHYSN_SPCLTY_CD = OP_PHYSN_SPCLTY_CD   ;

/*** end of section   - study specific variables ***/

/** locations where code stored on machine for project **/
%let vpath     = /sas/vrdc/users/shu172/files   ;
%let proj_path = /jhu_projects/overuse          ;
%let code_path = /code/                         ;
%let vrdc_code = &vpath./jhu_vrdc_code          ;
%include "&vrdc_code./macro_tool_box.sas";
%include "&vrdc_code./medicare_formats.sas";
*%include "&vrdc_code./jhu_build_Health_Systems.sas";



/*first identify everyone who died*/
%macro line(abcd=, include_cohort=);
proc sql;
create table &include_cohort (compress=yes) as
select  
	bene_id, bene_death_dt, VALID_DEATH_DT_SW, 
	bene_birth_dt, bene_race_cd, sex_ident_cd,
	county_cd, state_code, zip_cd
from 
&abcd 
where bene_death_dt ne .;
quit;
proc sort data=&include_cohort; by bene_id;
%mend;
%line(abcd=mbsf.mbsf_abcd_2016, include_cohort=vital_2016); 
%line(abcd=mbsf.mbsf_abcd_2017, include_cohort=vital_2017); 
%line(abcd=mbsf.mbsf_abcd_2018, include_cohort=vital_2018); 

data pop_&popN._include (keep= &bene_id elig_dt elig: setting_elig:
							pop_num  &gndr_cd &clm_dob bene_race_cd
							/*elig_compendium_hospital_id--because no requirement to die in hospital, cant assign to compendium for eligibility*/ 
							county_cd, state_code, zip_cd
						); *note that county, state, zip are different format from claims based pops;
set vital:	; 
by &bene_id	;
elig_dt=bene_death_dt;
elig_age=(bene_death_dt-bene_birth_dt)/365.25; label elig_age='age at eligibility: this is age at death for pop01';
elig=1;
pop_num=&popN;
setting_elig='VS'; *VS is for vital statistics;
setting_elig_vs=1; label setting_elig_vs='eligiblity based on death according to vital statistics, indicator 1 only';
*elig_compendium_hospital_id=compendium_hospital_id;
elig_year=year(elig_dt);
elig_qtr=qtr(elig_dt);
/*elig_prvdr_num=prvdr_num;
elig_OP_PHYSN_SPCLTY_CD=OP_PHYSN_SPCLTY_CD;
elig_prvdr_state_cd=prvdr_state_cd;
elig_at_physn_npi=at_physn_npi;
elig_op_physn_npi =op_physn_npi ;
elig_org_npi_num=org_npi_num;
elig_ot_physn_npi=ot_physn_npi;
elig_rndrng_physn_npi=rndrng_physn_npi;*/
elig_gndr_cd=sex_ident_cd;
elig_bene_race_cd=bene_race_cd;
elig_bene_cnty_cd=county_cd;
elig_bene_state_cd=state_code; 	
elig_bene_mlg_cntct_zip_cd=zip_cd;
run;
/* get rid of duplicate rows so that each bene contributes 1x per hospital/year/qtr */
proc sort data=pop_&popN._include NODUPKEY; by /*elig_compendium_hospital_id*/ elig_year elig_qtr &bene_id elig_dt; run;
proc sort data=pop_&popN._include NODUPKEY; by /*elig_compendium_hospital_id*/ elig_year elig_qtr &bene_id ; run;

data &permlib..pop_&popN._elig;
set 	pop_&popN._include  ;
run;
*person can contribute only once even if seen in inpatient and outpatient in same hosp/year/qtr (not really needed for indicator 1 since you can only die once);
proc sort data=&permlib..pop_&popN._elig NODUPKEY; by /*elig_compendium_hospital_id*/ elig_year elig_qtr &bene_id ;run;

*end identification of eligibility;

*Start: identify who popped;
/*** identify encounters in the 30 days prior to death ***/
%macro claims_rev(source=, rev_cohort=, include_cohort=, ccn=);
/* identify hcpcs  */
proc sql;
create table include_cohort1a (compress=yes) as
select a.&bene_id, a.&clm_id, a.&hcpcs_cd, a.&clm_thru_dt, a.&rev_cntr, 
		case when a.&rev_cntr in (&ED_rev_cntr) then 1 else 0 end as &flag_popped
from 
	&rev_cohort a
 ;
quit;
/* pull claim info for those with ED encounter (need to do this to get dx codes)*/
proc sql;
	create table include_cohort1b (compress=yes) as
select *
from 
	include_cohort1a a, 
	&source b
where 
	(a.&bene_id=b.&bene_id and a.&clm_id=b.&clm_id);
quit;
/*link to ccn*/
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
/*set info about pop, brining in any DX code inclusions & exclusions on same day as qualifying procedure*/
Data include_cohort1g; 
set include_cohort1c;
&flag_popped_dt=&date; 
	format &flag_popped_dt date9.; 						label &flag_popped_dt			=	&flag_popped_dt_label;
				 										label &flag_popped				=	&flag_popped_label;
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
	a.bene_id = b.bene_id 
	and 
	( (b.bene_death_dt-30)<= a.elig_dt <=b.bene_death_dt )	
; 
quit;
%mend;

/*** this section is related to IP - inpatient claims ***/
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
							&admtg_dgns_cd &clm_drg_cd  rev_cntr1
							prvdr_num prvdr_state_cd OP_PHYSN_SPCLTY_CD 
							at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi
							RFR_PHYSN_NPI
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
format bene_state_cd prvdr_state_cd $state. &pop_OP_PHYSN_SPCLTY_CD $speccd. rev_cntr1 $rev_cntr.
		&pop_clm_src_ip_admsn_cd $src1adm. &pop_nch_clm_type_cd $clm_typ.
		&pop_CLM_IP_ADMSN_TYPE_CD $typeadm.
		&pop_ptnt_dschrg_stus_cd $stuscd.
		&pop_icd_dgns_cd1 &pop_admtg_dgns_cd $dgns. &pop_icd_prcdr_cd1 $prcdr. &pop_hcpcs_cd $hcpcs. 
		&gndr_cd gender. bene_race_cd race. &pop_clm_drg_cd drg. ;
run;
* get rid of duplicate rows so that each bene contributes 1x per hospital/year/qtr ;
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
format &pop_OP_PHYSN_SPCLTY_CD $speccd. rev_cntr $rev_cntr.
		 &pop_nch_clm_type_cd $clm_typ. 
		&ptnt_dschrg_stus_cd $stuscd. &gndr_cd gender. bene_race_cd race. 
		&pop_icd_dgns_cd1  $dgns. &pop_icd_prcdr_cd1 $prcdr. &pop_hcpcs_cd $hcpcs. ;
run;
/* get rid of duplicate rows so that each bene contributes 1x per hospital/year/qtr */
proc sort data=pop_&popN._OUT NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id elig_dt; run;
									 
proc sort data=pop_&popN._OUT NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id ; run; 

data pop_&popN._in_out_popped
	(keep = bene_id elig: pop: setting: 
			&gndr_cd bene_race_cd	bene_cnty_cd bene_state_cd 	bene_mlg_cntct_zip_cd
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

*susie: start here:
*need to count number of times popped--each person must pop twice (=2 ed visits) to be considered a pop;


*person can contribute only once even if seen in inpatient and outpatient in same hosp/year/qtr;
proc sort data=pop_&popN._in_out_popped NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id elig_dt; run;
proc sort data=pop_&popN._in_out_popped NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id; run;

*End: Identify who popped;

*Start link eligible and popped;
proc sort data=pop_&popN._in_out_popped		NODUPKEY; by  &bene_id elig_dt;run;
proc sort data=&permlib..pop_&popN._elig	NODUPKEY; by  &bene_id elig_dt;run;

*choose POP hospital, year quarter if patient poppped, otherwise choose ELIG;
data &permlib..pop_&popN._in_out 
	(	drop=elig_compendium_hospital_id elig_year elig_qtr 
		keep= bene_id elig: pop: setting:);
merge pop_&popN._in_out_popped &permlib..pop_&popN._elig;
by &bene_id elig_dt;
if elig_compendium_hospital_id=' ' and pop_compendium_hospital_id=' ' then delete;
if pop_compendium_hospital_id=' ' then pop_compendium_hospital_id=elig_compendium_hospital_id;
label pop_compendium_hospital_id='Hospital where patient popped, if patient did not pop, the hospital where patient
	was first eligible during the quarter';
if elig_year=. and pop_year=. then delete;
if pop_year=. then pop_year=elig_year;
label pop_year='Year patient popped/was eligible';
if elig_qtr=. and pop_qtr=. then delete;
if pop_qtr=. then pop_qtr=elig_qtr;
label pop_qtr='Quarter patient popped/was eligible';
if elig_age=. and pop_age=. then delete;
if pop_age=. then pop_age=elig_age;
label pop_age='Age patient popped/was eligible';
if elig_gndr_cd=' ' and pop_gndr_cd=' ' then delete;
if pop_gndr_cd=' ' then pop_gndr_cd=elig_gndr_cd;
label pop_gndr_cd='Gender patient popped/was eligible';
format elig_dt date9.;
if pop_year<2016 then delete;
if pop_year>2018 then delete;
*delete those who were in eligibility outside range that did not pop;
if &flag_popped ne 1 and elig_year<2016 then delete;
if &flag_popped ne 1 and elig_year>2018 then delete;
if &flag_popped=. then &flag_popped=0;
popped=&flag_popped;
run;
/*allow to pop only once per qtr*/
proc sort data=&permlib..pop_&popN._in_out NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id;run;

/*title 'Popped Inpatient or Outpatient (No Carrier) For Analysis';
proc freq data=&permlib..pop_&popN._in_out; 
table  	popped &flag_popped &pop_year pop_year pop_qtr setting_pop setting_elig; run;
proc contents data=&permlib..pop_&popN._in_out; run;*/
*End link eligible and popped;




/**This section makes summaries for inpatient, outpatient carrier POPPED **/
*look at inpatient info;
%macro poppedlook(in=);
title 'Inpatient Popped AT LEAST 1 ED VISIT';
proc freq data=&in order=freq noprint; 
table  	&flag_popped /nocum out=&flag_popped; run;
proc print data=&flag_popped noobs; where count>=11; run;

title 'Inpatient Popped AND linked to AHRQ compendium health system';
proc freq data=&in order=freq noprint; 
where compendium_hospital_id ne ' ';
table  	&flag_popped /nocum out=&flag_popped; run;
proc print data=&flag_popped noobs; where count>=11; run;

title 'Inpatient Popped';
proc freq data=&in order=freq noprint; 
table  	&pop_year /nocum out=&pop_year (drop = count); run;
proc print data=&pop_year noobs; run;

proc freq data=&in order=freq noprint; 
table  	&pop_icd_prcdr_cd1 /nocum out=&pop_icd_prcdr_cd1 (drop = count); run;
proc print data=&pop_icd_prcdr_cd1 noobs; where percent>1; run;

proc freq data=&in order=freq noprint; 
table  	&pop_hcpcs_cd /nocum out=&pop_hcpcs_cd (drop = count); run;
proc print data=&pop_hcpcs_cd noobs; where percent>1; run;

proc freq data=&in order=freq noprint; 
table  	&pop_clm_drg_cd /nocum out=&pop_clm_drg_cd (drop = count); run;
proc print data=&pop_clm_drg_cd noobs; run;

proc freq data=&in order=freq noprint; 
table  	&pop_admtg_dgns_cd /nocum out=&pop_admtg_dgns_cd (drop = count); run;
proc print data=&pop_admtg_dgns_cd noobs; where percent>1; run;

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
%poppedlook(in=pop_01_IN);
		/*bene_state_cd prvdr_state_cd 
		&pop_OP_PHYSN_SPCLTY_CD &pop_clm_fac_type_cd &pop_ptnt_dschrg_stus_cd
		&pop_nch_clm_type_cd &pop_CLM_IP_ADMSN_TYPE_CD &pop_clm_src_ip_admsn_cd*/  
title 'Outpatient Popped AT LEAST 1 ED VISIT';
%macro poppedlook(in=);
proc freq data=&in order=freq noprint; 
table  	&flag_popped /nocum out=&flag_popped; run;
proc print data=&flag_popped noobs; where count>=11; run;

title 'Outpatient Popped AND linked to AHRQ compendium health system';
proc freq data=&in order=freq noprint; 
where compendium_hospital_id ne ' ';
table  	&flag_popped /nocum out=&flag_popped; run;
proc print data=&flag_popped noobs; where count>=11; run;

title 'Outpatient Popped';
proc freq data=&in order=freq noprint; 
table  	&pop_year /nocum out=&pop_year (drop = count); run;
proc print data=&pop_year noobs; run;

proc freq data=&in order=freq noprint; 
table  	&pop_hcpcs_cd /nocum out=&pop_hcpcs_cd (drop = count); run;
proc print data=&pop_hcpcs_cd noobs; where percent>1; run;

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
%poppedlook(in=pop_01_OUT);

*compile Outpatient Popped into 1 dataset
		DO NOT INCLUDE CARRIER
		Keep ONLY the first observation per person afer REQUIRING 2 ED VISITS (=2 INSTANCES OF POP);
data pop_01_in_out 
	(keep = bene_id &flag_popped &pop_age &flag_popped_dt &pop_year &gndr_cd
			prvdr_num prvdr_state_cd OP_PHYSN_SPCLTY_CD /*RFR_PHYSN_NPI*/
			at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi
			bene_race_cd	bene_cnty_cd bene_state_cd 	bene_mlg_cntct_zip_cd
			bene_death_dt);
set pop_01_IN pop_01_OUT;
run;
proc sort data=pop_01_in_out nodupkey; by bene_id &flag_popped_dt; run;

proc sort data=pop_01_in_out nodupkey out=pop_01_in_out1; by &bene_id &flag_popped_dt; run;
proc transpose data=pop_01_in_out1 out=pop_01_in_out_transpose (drop = _name_ _label_) prefix=flag_popped;
    by &bene_id bene_death_dt ;
    var &flag_popped_dt;
run;
data pop_01_in_out_transpose2 (keep = bene_id bene_death_dt ed_count_num); set pop_01_in_out_transpose;
where flag_popped2 ne .;
array count(24) flag_popped1-flag_popped24;
do i=1 to 24;
	if count(i) ne . then do; ed_count_num=i;end;
end;
label ed_count_num='number of times went to ED in 30 days before death';
run;
*merge in with the pop_01 if a and b and have those that popped...;

proc sort data=pop_01_in_out; by bene_id bene_death_dt;
proc sort data=pop_01_in_out_transpose2; by bene_id bene_death_dt;
run;

data pop_01_in_out_ed; 
merge pop_01_in_out (in=a) pop_01_in_out_transpose2 (in=b);
by bene_id bene_death_dt;
if a and b;
run;
proc sort data=pop_01_in_out_ed; by bene_id &flag_popped_dt; run;
proc sort data=pop_01_in_out_ed; by bene_id; run;

title 'Popped after Counting ED admits in 30 days before death';
proc means data=pop_01_in_out_ed n min mean median max; var ed_count_num; run;


title 'Popped Outpatient (No Inpatient, No Carrier) For Analysis, Require 2 ED admits in 30 days before death';
proc freq data=pop_01_in_out_ed; 
table  	&pop_year; run;
proc contents data=pop_01_in_out_ed; run;

*save permanent dataset;
data &permlib..pop_01_in_out; set pop_01_in_out_ed; run;


