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
							pop_num  bene_death_dt VALID_DEATH_DT_SW bene_birth_dt 
							bene_race_cd sex_ident_cd
							/*elig_compendium_hospital_id--because no requirement to die in hospital, cant assign to compendium for eligibility*/ 
							county_cd state_code zip_cd
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
%macro claims_rev(date=, source=, rev_cohort=, include_cohort=, ccn=);
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
*do not sort here--allow them to pop more than once-need to merge to outpatient to count 2 ed visits;


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
*do not sort here--allow them to pop more than once-need to merge to inpatient to count 2 ed visits;

data pop_&popN._in_out_popped1
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

*sort nodupkey by bene popped date before count so dn't accidentally double count;
proc sort data=pop_&popN._in_out_popped1 NODUPKEY out=pop_&popN._in_out_popped2; by &bene_id &flag_popped_dt; run;

*only keep those with at least 2 ed vists (=popped 2 times) as popped;
data pop_&popN._in_out_popped;
	set pop_&popN._in_out_popped2;
	by &bene_id;
	if first.&bene_id then do; ed_count = 0; ed_date_first=&flag_popped_dt; end; 
	ed_count + 1;
	if last.&bene_id then do; ed_date_last=&flag_popped_dt; end;
	if last.&bene_id then output;
	if ed_count<2 then delete;
	run;

/* get rid of duplicate rows so that each bene contributes 1x per hospital/year/qtr --there should be no dupes here*/
proc sort data=pop_&popN._in_out_popped NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id elig_dt; run;									 
proc sort data=pop_&popN._in_out_popped NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id ; run; 

*person can contribute only once even if seen in inpatient and outpatient in same hosp/year/qtr;
proc sort data=pop_&popN._in_out_popped NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id elig_dt; run;
proc sort data=pop_&popN._in_out_popped NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id; run;

*End: Identify who popped;

*start linkage to MBSF for comorbidities;

*bring in chronic conditions;
%macro line(abcd=, include_cohort=);
proc sql;
create table &include_cohort (compress=yes) as
select  
a.bene_id, a.elig_dt, b.*
from 
&permlib..pop_&popN._in_out a,
&abcd b
where a.bene_id = b.bene_id and a.pop_year = b.BENE_ENROLLMT_REF_YR;
quit;
%mend;
%line(abcd=mbsf.mbsf_cc_2018, include_cohort=cc_2018); 
%line(abcd=mbsf.mbsf_cc_2017, include_cohort=cc_2017); 
%line(abcd=mbsf.mbsf_cc_2016, include_cohort=cc_2016);  
%line(abcd=mbsf.mbsf_otcc_2018, include_cohort=otcc_2018); 
%line(abcd=mbsf.mbsf_otcc_2017, include_cohort=otcc_2017); 
%line(abcd=mbsf.mbsf_otcc_2016, include_cohort=otcc_2016); 


proc sort data=cc_2016; by bene_id elig_dt;
proc sort data=cc_2017; by bene_id elig_dt;
proc sort data=cc_2018; by bene_id elig_dt;

proc sort data=otcc_2016; by bene_id elig_dt;
proc sort data=otcc_2017; by bene_id elig_dt;
proc sort data=otcc_2018; by bene_id elig_dt;
proc sort data=&permlib..pop_&popN._in_out; by bene_id elig_dt;
run;
data cc (keep=bene: elig_dt enrl_src ami ami_ever alzh_ever alzh_demen_ever atrial_fib_ever
cataract_ever chronickidney_ever copd_ever chf_ever diabetes_ever glaucoma_ever  hip_fracture_ever 
ischemicheart_ever depression_ever osteoporosis_ever ra_oa_ever stroke_tia_ever cancer_breast_ever
cancer_colorectal_ever cancer_prostate_ever cancer_lung_ever cancer_endometrial_ever anemia_ever asthma_ever
hyperl_ever hyperp_ever hypert_ever hypoth_ever 
acp_MEDICARE_EVER anxi_MEDICARE_EVER autism_MEDICARE_EVER bipl_MEDICARE_EVER brainj_MEDICARE_EVER cerpal_MEDICARE_EVER
cysfib_MEDICARE_EVER depsn_MEDICARE_EVER epilep_MEDICARE_EVER fibro_MEDICARE_EVER hearim_MEDICARE_EVER
hepviral_MEDICARE_EVER hivaids_MEDICARE_EVER intdis_MEDICARE_EVER leadis_MEDICARE_EVER leuklymph_MEDICARE_EVER
liver_MEDICARE_EVER migraine_MEDICARE_EVER mobimp_MEDICARE_EVER mulscl_MEDICARE_EVER musdys_MEDICARE_EVER
obesity_MEDICARE_EVER othdel_MEDICARE_EVER psds_MEDICARE_EVER ptra_MEDICARE_EVER pvd_MEDICARE_EVER schi_MEDICARE_EVER
schiot_MEDICARE_EVER spibif_MEDICARE_EVER spiinj_MEDICARE_EVER toba_MEDICARE_EVER ulcers_MEDICARE_EVER
visual_MEDICARE_EVER cc_sum cc_other_sum cc_DHHS_sum);
;
merge otcc: cc:	;
by bene_id elig_dt;
*make chronic conitions indicators;
if ami_ever ne . and ami_ever<=elig_dt then cc_ami=1; else cc_ami=0;
if alzh_ever ne . and alzh_ever <=elig_dt then cc_alzh=1; else cc_alzh=0;
if alzh_demen_ever ne . and alzh_demen_ever <=elig_dt then cc_alzh_demen=1; else cc_alzh_demen=0;
if atrial_fib_ever ne . and atrial_fib_ever<=elig_dt then cc_atrial_fib=1; else cc_atrial_fib=0;
if cataract_ever ne . and cataract_ever <=elig_dt then cc_cataract=1; else cc_cataract=0;
if chronickidney_ever ne . and chronickidney_ever<=elig_dt then cc_chronickidney=1; else cc_chronickidney=0;
if copd_ever ne . and copd_ever <=elig_dt then cc_copd=1; else cc_copd=0;
if chf_ever ne . and chf_ever <=elig_dt then cc_chf=1; else cc_chf=0;
if diabetes_ever ne . and diabetes_ever <=elig_dt then cc_diabetes=1; else cc_diabetes=0;
if glaucoma_ever ne . and glaucoma_ever  <=elig_dt then cc_glaucoma=1; else cc_glaucoma=0;
if hip_fracture_ever ne . and hip_fracture_ever <=elig_dt then cc_hip_fracture=1; else cc_hip_fracture=0;
if ischemicheart_ever ne . and ischemicheart_ever<=elig_dt then cc_ischemicheart=1; else cc_ischemicheart=0;
if depression_ever ne . and depression_ever <=elig_dt then cc_depression=1; else cc_depression=0;
if osteoporosis_ever ne . and osteoporosis_ever <=elig_dt then cc_osteoporosis=1; else cc_osteoporosis=0;
if ra_oa_ever ne . and ra_oa_ever <=elig_dt then cc_ra_oa=1; else cc_ra_oa=0;
if stroke_tia_ever  ne . and stroke_tia_ever <=elig_dt then cc_stroke_tia=1; else cc_stroke_tia=0;
if cancer_breast_ever ne . and cancer_breast_ever<=elig_dt then cc_cancer_breast=1; else cc_cancer_breast=0;
if cancer_colorectal_ever ne . and cancer_colorectal_ever<=elig_dt then cc_cancer_colorectal=1; else cc_cancer_colorectal=0;
if cancer_prostate_ever ne . and cancer_prostate_ever <=elig_dt then cc_cancer_prostate=1; else cc_cancer_prostate=0;
if cancer_lung_ever ne . and cancer_lung_ever <=elig_dt then cc_cancer_lung=1; else cc_cancer_lung=0;
if cancer_endometrial_ever ne . and cancer_endometrial_ever<=elig_dt then cc_cancer_endometrial=1; else cc_cancer_endometrial=0;
if anemia_ever ne . and anemia_ever <=elig_dt then cc_anemia=1; else cc_anemia=0;
if asthma_ever ne . and asthma_ever<=elig_dt then cc_asthma=1; else cc_asthma=0;
if hyperl_ever ne . and hyperl_ever <=elig_dt then cc_hyperl=1; else cc_hyperl=0;
if hyperp_ever ne . and hyperp_ever <=elig_dt then cc_hyperp=1; else cc_hyperp=0;
if hypert_ever ne . and hypert_ever <=elig_dt then cc_hypert=1; else cc_hypert=0;
if hypoth_ever ne . and hypoth_ever<=elig_dt then cc_hypoth=1; else cc_hypoth=0;
cc_sum=sum(cc_ami, cc_alzh, cc_alzh_demen, cc_atrial_fib, cc_chronickidney, cc_copd, cc_chf, cc_diabetes, cc_glaucoma, cc_hip_fracture,
cc_ischemicheart, cc_depression, cc_osteoporosis, cc_ra_oa, cc_stroke_tia, cc_cancer_breast, cc_cancer_colorectal, cc_cancer_prostate,
cc_cancer_lung, cc_cancer_endometrial, cc_anemia, cc_asthma, cc_hyperl, cc_hyperp, cc_hypert, cc_hypoth);
if ACP_MEDICARE_EVER ne . and ACP_MEDICARE_EVER<=elig_dt then cc_acp=1; else cc_acp=0;
if ANXI_MEDICARE_EVER ne . and ANXI_MEDICARE_EVER<=elig_dt then cc_anxi=1; else cc_anxi=0;
if AUTISM_MEDICARE_EVER ne . and AUTISM_MEDICARE_EVER<= elig_dt then cc_autism=1; else cc_autism=0;
if BIPL_MEDICARE_EVER ne . and BIPL_MEDICARE_EVER<=elig_dt then cc_bipl=1; else cc_bipl=0;
if BRAINJ_MEDICARE_EVER ne . and BRAINJ_MEDICARE_EVER<=elig_dt then cc_brainj=1; else cc_brainj=0;
if CERPAL_MEDICARE_EVER ne . and CERPAL_MEDICARE_EVER<=elig_dt then cc_cerpal=1; else cc_cerpal=0;
if CYSFIB_MEDICARE_EVER ne . and CYSFIB_MEDICARE_EVER<=elig_dt then cc_cysfib=1; else cc_cysfib=0;
if DEPSN_MEDICARE_EVER ne . and DEPSN_MEDICARE_EVER<=elig_dt then cc_depsn=1; else cc_depsn =0;
if EPILEP_MEDICARE_EVER ne . and EPILEP_MEDICARE_EVER<=elig_dt then cc_epilep=1; else cc_epilep=0;
if FIBRO_MEDICARE_EVER ne . and FIBRO_MEDICARE_EVER<=elig_dt then cc_fibro=1; else cc_fibro=0;
if HEARIM_MEDICARE_EVER ne . and HEARIM_MEDICARE_EVER<=elig_dt then cc_hearim=1; else cc_hearim=0;
if HEPVIRAL_MEDICARE_EVER ne . and HEPVIRAL_MEDICARE_EVER<=elig_dt then cc_hepviral=1; else cc_hepviral=0;
if HIVAIDS_MEDICARE_EVER ne . and HIVAIDS_MEDICARE_EVER<=elig_dt then cc_hivaids=1; else cc_hivaids=0;
if INTDIS_MEDICARE_EVER ne . and INTDIS_MEDICARE_EVER<=elig_dt then cc_intdis=1; else cc_intdis=0;
if LEADIS_MEDICARE_EVER ne . and LEADIS_MEDICARE_EVER<=elig_dt then cc_leadis=1; else cc_leadis=0; 
if LEUKLYMPH_MEDICARE_EVER ne . and LEUKLYMPH_MEDICARE_EVER<=elig_dt then cc_leuklymph=1; else cc_leuklymph=0;
if LIVER_MEDICARE_EVER ne . and LIVER_MEDICARE_EVER<=elig_dt then cc_liver=1; else cc_liver=0; 
if MIGRAINE_MEDICARE_EVER ne . and MIGRAINE_MEDICARE_EVER<=elig_dt then cc_migraine=1; else cc_migraine=0; 
if MOBIMP_MEDICARE_EVER ne . and MOBIMP_MEDICARE_EVER<=elig_dt then cc_mobimp=1; else cc_mobimp=0; 
if MULSCL_MEDICARE_EVER ne . and MULSCL_MEDICARE_EVER<=elig_dt then cc_mulscl=1; else cc_mulscl=0; 
if MUSDYS_MEDICARE_EVER ne . and MUSDYS_MEDICARE_EVER<=elig_dt then cc_musdys=1; else cc_musdys=0;
if OBESITY_MEDICARE_EVER ne . and OBESITY_MEDICARE_EVER<=elig_dt then cc_obesity=1; else cc_obesity=0;
if OTHDEL_MEDICARE_EVER ne . and OTHDEL_MEDICARE_EVER<=elig_dt then cc_othdel=1; else cc_othdel=0;
if PSDS_MEDICARE_EVER ne . and PSDS_MEDICARE_EVER<=elig_dt then cc_psds=1; else cc_psds=0;
if PTRA_MEDICARE_EVER ne . and PTRA_MEDICARE_EVER<=elig_dt then cc_ptra=1; else cc_ptra=0;
if PVD_MEDICARE_EVER ne . and PVD_MEDICARE_EVER<=elig_dt then cc_pvd=1; else cc_pvd=0;
if SCHI_MEDICARE_EVER ne . and SCHI_MEDICARE_EVER<=elig_dt then cc_schi=1; else cc_schi=0;
if SCHIOT_MEDICARE_EVER ne . and SCHIOT_MEDICARE_EVER<=elig_dt then cc_schiot=1; else cc_schiot=0;
if SPIBIF_MEDICARE_EVER ne . and SPIBIF_MEDICARE_EVER<=elig_dt then cc_spibif=1; else cc_spibif=0;
if SPIINJ_MEDICARE_EVER ne . and SPIINJ_MEDICARE_EVER<=elig_dt then cc_spiinj=1; else cc_spiinj=0;
if TOBA_MEDICARE_EVER ne . and TOBA_MEDICARE_EVER<=elig_dt then cc_toba=1; else cc_toba=0;
if ULCERS_MEDICARE_EVER ne . and ULCERS_MEDICARE_EVER<=elig_dt then cc_ulcers=1; else cc_ulcers=0;
if VISUAL_MEDICARE_EVER ne . and VISUAL_MEDICARE_EVER<=elig_dt then cc_visual=1; else cc_visual=0;
cc_other_sum=sum(cc_acp, cc_anxi, cc_autism, cc_bipl, cc_brainj, cc_cerpal, cc_cysfib, cc_depsn, cc_epilep, 
cc_fibro, cc_hearim, cc_hepviral, cc_hivaids, cc_intdis, cc_leadis, cc_leuklymph, cc_liver, cc_migraine, 
cc_mobimp, cc_mulscl, cc_musdys, cc_obesity, cc_othdel, cc_psds, cc_ptra, cc_pvd, cc_schi, cc_schiot, 
cc_spibif, cc_spiinj, cc_toba, cc_ulcers, cc_visual); 
*DHHS has own chronic conditions list which is a subset of these CC
https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Chronic-Conditions/Downloads/Methods_Overview.pdf ;
cc_DHHS_sum=sum(cc_alzh_demen, cc_atrial_fib, cc_chronickidney, cc_copd, cc_chf, cc_diabetes, cc_ischemicheart, cc_depression,
cc_osteoporosis, cc_ra_oa, cc_stroke_tia, cc_cancer_breast, cc_cancer_colorectal, cc_cancer_prostate, cc_cancer_lung, cc_asthma,
cc_hyperl, cc_hypert,cc_autism, cc_hepviral, cc_hivaids, cc_schi);
run;

data &permlib..pop_&popN._in_out;
merge 
cc (in=a) &permlib..pop_&popN._in_out (in=b);
by bene_id elig_dt;
if a and b;
run; 

*Start summary checks;
/**Look at freq, means, contents of final 1 record per person dataset **/
*title 'Popped Inpatient or Outpatient (No Carrier) For Analysis';
title 'Popped Inpatient or Outpatient (No Carrier) For Analysis';
proc freq data=&permlib..pop_&popN._in_out; 
table  	popped &flag_popped &pop_year pop_year pop_qtr setting_pop setting_elig ed_count; run;
proc means data=&permlib..pop_&popN._in_out n mean median min max; 
var elig_age elig_los &pop_age &pop_los pop_age cc_sum ed_count; run;
proc contents data=&permlib..pop_&popN._in_out; run;

*Start summary checks;
/**This section makes summaries for inpatient, outpatient POPPED & eligible **/
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
						   


title 'Inpatient Popped';
%poppedlook(in=pop_&popN._IN);
*delete the temp datasets;
proc datasets lib=work nolist;
 delete setting: elig_ed elig_year elig_qtr pop_num icd: clm:
 		pop_icd: 
		year qtr &gndr_cd  bene_race_cd 
		pop_ed pop_year
		&pop_hcpcs_cd &pop_clm_drg_cd &pop_rev_cntr
		&pop_admtg_dgns_cd &pop_OP_PHYSN_SPCLTY_CD pop_nch_clm_type_cd
		&ptnt_dschrg_stus_cd ;
quit;
run;
																	   

title 'Eligible because have date of death in MBSF--because no compendium hospital id without encounter--only those who popped can be assigned to a hospital';
%eliglook(in=pop_&popN._include);
		/*bene_state_cd prvdr_state_cd 
		&pop_OP_PHYSN_SPCLTY_CD &pop_clm_fac_type_cd &pop_ptnt_dschrg_stus_cd
		&pop_nch_clm_type_cd &pop_CLM_IP_ADMSN_TYPE_CD &pop_clm_src_ip_admsn_cd*/
proc datasets lib=work nolist;
 delete setting: elig_ed elig_year elig_qtr pop_num icd: clm:
		year qtr &gndr_cd  bene_race_cd 
		hcpcs_cd1 &clm_drg_cd rev_cntr1
		&admtg_dgns_cd &OP_PHYSN_SPCLTY_CD nch_clm_type_cd
		&ptnt_dschrg_stus_cd ;
quit;
run;
title 'Outpatient Popped';
%poppedlook(in=pop_&popN._OUT);
proc datasets lib=work nolist;
 delete setting: elig_ed elig_year elig_qtr pop_num icd: clm:
 		pop_icd: 
		year qtr &gndr_cd  bene_race_cd 
		pop_ed pop_year
		&pop_hcpcs_cd &pop_clm_drg_cd &pop_rev_cntr
		&pop_admtg_dgns_cd &pop_OP_PHYSN_SPCLTY_CD pop_nch_clm_type_cd
		&ptnt_dschrg_stus_cd ;
quit;
run;
/*title 'Elgible from outpatient encounter';
%eliglook(in=pop_&popN._OUTinclude);
proc datasets lib=work nolist;
 delete setting: elig_ed elig_year elig_qtr pop_num icd: clm:
		year qtr &gndr_cd  bene_race_cd 
		hcpcs_cd1 &clm_drg_cd rev_cntr1
		&admtg_dgns_cd &OP_PHYSN_SPCLTY_CD nch_clm_type_cd
		&ptnt_dschrg_stus_cd ;
quit;
run;*/
*End summary checks;

*create models;
*make categories of age and cc for analysis;
data pop_&popN._in_out_anal; set &permlib..pop_&popN._in_out;
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
if 1<=n<=10 then n=.;
if popped=. then popped=0;
if 1<=popped<=10 then popped=.;
run;

*merge hospital aggregated data to health system--request export of this dataset;
proc sql;
create table pop_&popN._in_out_anal3 (compress=yes) as
select  
*
from 
pop_&popN._in_out_anal2 a,
&permlib..ahrq_ccn b
where a.pop_compendium_hospital_id = b.compendium_hospital_id 
and b.health_sys_id2016 ne ' ';
quit;

*2 things required when program finishes running:
(1) Export pop_&popN._in_out_anal3--this is the analytic dataset
(2) Re-run the summary checks and request export of the PDF to review
		-these are the summaries of inpatient/outpatient prior to n<11 exclusions made for analytic dataset;


*because there is no hospital at time of death, there is no denominator---there are only people who pop;

