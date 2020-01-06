/********************************************************************
* Job Name: jhu_build_Claim_IPOP_ds_project_overuse_num02.sas
* Job Desc: Input for Inpatient & Outpatient (Including Carrier) Claims 
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************/

/*** Indicator description ***/
/* Description and codes from .xlsx file  "ICD-10 conversions_12_17-19" */

/* Indicator 02 */

/*Description from Excel file
(New) Number 		2	
Indicator 		Don�t perform unproven diagnostic tests, such as immunoglobulin G (IgG) testing or an indiscriminate battery of immunoglobulin E (IgE) tests, in the evaluation of allergy.
Indicator
			Motivator: IgG testing has no relevance to allergy; IgE testing should be very selective

			Indictor: IgG testing where the primary diagnosis is allergy or broad IgE testing where the primary diagnosis is allergy

			[this can be reported among all patients with IgG and IgE testing]

Timing		Inclusionary diagnosis code is associated with the procedure code (same claim)
			or same admission (with primary diagnosis)	

System		Allergy	

Actor		Allergists, primary care

*/


/*** start of indicator specific variables ***/

/*inclusion criteria (options: CPT/HCPCS, ICD procedure, ICD diagnosis, DRG)*/
%let includ_hcpcs =		'82784'	'82787'	;

*%let includ_pr10 =	; 

%let includ_dx10_3 =	'Z88' 'J30' 	;
%let includ_dx10_4 =	'Z910'			;
*%let includ_drg = ;

/** Exclusion criteria **/
%let exclud_dx10_1 =	'C'														;
%let exclud_dx10_3 =	'D80'	'D81'	'D82'	'D83'	'D84'	'D85'
						'D86'	'D87'	'D88'	'D89'							;

/** Label pop specific variables  instructions **/
%let 	flag_popped             		= popped02 								;
%let 	flag_popped_label				= 'indicator 02 popped'					;	
%let	flag_popped_dt					= popped02_dt							;
%let 	flag_popped_dt_label			= 'indicator 02 date patient popped (IP=clm_admsn_dt OP=clm_from_dt)'	;
%let 	pop_age							= pop_02_age							;				
%let	pop_age_label					= 'age eligible for pop 02'				;
%let	pop_los							= pop_02_los							;
%let	pop_los_label					= 'length of stay when patient popped'	;
%let	pop_year						= pop_02_year							;
%let	pop_nch_clm_type_cd				= pop_02_nch_clm_type_cd				;
%let  	pop_CLM_IP_ADMSN_TYPE_CD		= pop_02_CLM_IP_ADMSN_TYPE_CD			;
%let	pop_clm_fac_type_cd				= pop_02_clm_fac_type_cd				;
%let	pop_clm_src_ip_admsn_cd			= pop_02_clm_src_ip_admsn_cd			;
%let	pop_ptnt_dschrg_stus_cd  		= pop_02_ptnt_dschrg_stus_cd			;
%let	pop_admtg_dgns_cd				= pop_02_admtg_dgns_cd					;
%let	pop_icd_dgns_cd1				= pop_02_icd_dgns_cd1					;
%let	pop_clm_drg_cd					= pop_02_clm_drg_cd						;
%let	pop_hcpcs_cd					= pop_02_hcpcs_cd						;
%let	pop_OP_PHYSN_SPCLTY_CD			= pop_02_OP_PHYSN_SPCLTY_CD				;
%let	pop_nch_clm_type_cd				= pop_02_nch_clm_type_cd				;
%let	pop_nch_clm_type_cd_label		= 'claim/facility type for pop 02' 		;
%let	pop_CLM_IP_ADMSN_TYPE_CD_label	= 'inpatient admission type code for pop 02'	;
%let  	pop_clm_fac_type_cd_label		= 'inpatient clm_fac_type_cd for pop 02';
%let	pop_clm_src_ip_admsn_cd_label	= 'clm_src_ip_admsn_cd for pop 02'		;
%let	pop_ptnt_dschrg_stus_cd_label	= 'discharge status code for pop 02'	;	


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

%let  proc_pfx           = icd_prcdr          	;
%let  proc_cd_min        = 1                 	;
%let  proc_cd_max        = 25                 	;

%let  clm_beg_dt_in      = clm_admsn_dt   		;
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
%let  OP_PHYSN_SPCLTY_CD = OP_PHYSN_SPCLTY_CD   ;

/*** end of section   - study specific variables ***/

/** locations where code stored on machine for project **/
%let vpath     = /sas/vrdc/users/shu172/files   ;
%let proj_path = /jhu_projects/overuse          ;
%let code_path = /code/                         ;
%let vrdc_code = &vpath./jhu_vrdc_code          ;
%include "&vrdc_code./macro_tool_box.sas";
%include "&vrdc_code./medicare_formats.sas";

/** vars to keep or delete from the different data sources **/

%let vars_to_keep_ip    = 	pop: 
							&bene_id &clm_id &gndr_cd 
							&clm_beg_dt_in &clm_end_dt_in &clm_dob  &ptnt_dschrg_stus_cd
							&nch_clm_type_cd &CLM_IP_ADMSN_TYPE_CD &clm_fac_type_cd &clm_src_ip_admsn_cd 
							&admtg_dgns_cd &clm_drg_cd  &hcpcs_cd
							&diag_pfx.&diag_cd_min   
							prvdr_num prvdr_state_cd OP_PHYSN_SPCLTY_CD
							at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi
							/*RFR_PHYSN_NPI*/
							bene_race_cd	bene_cnty_cd
							bene_state_cd 	bene_mlg_cntct_zip_cd								;                         
%let vars_to_keep_op	=	pop: 
							&bene_id &clm_id &gndr_cd 
							&clm_from_dt &clm_thru_dt &clm_dob  &ptnt_dschrg_stus_cd
							&nch_clm_type_cd &clm_fac_type_cd  
							&hcpcs_cd  
							&diag_pfx.&diag_cd_min   
							prvdr_num prvdr_state_cd OP_PHYSN_SPCLTY_CD /*RFR_PHYSN_NPI*/
							at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi
							bene_race_cd	bene_cnty_cd
							bene_state_cd 	bene_mlg_cntct_zip_cd								;
%let vars_to_keep_car	=	pop: 
							&bene_id &clm_id &gndr_cd 
							&clm_from_dt &clm_thru_dt &clm_dob  
							&nch_clm_type_cd   
							&hcpcs_cd  
							&diag_pfx.&diag_cd_min   
							/*RFR_PHYSN_NPI*/ CPO_PRVDR_NUM CPO_ORG_NPI_NUM
							CARR_CLM_BLG_NPI_NUM   ACO_ID_NUM
							PRF_PHYSN_NPI ORG_NPI_NUM 
							CARR_LINE_PRVDR_TYPE_CD TAX_NUM  
							prvdr_state_cd PRVDR_SPCLTY PRTCPTNG_IND_CD
							LINE_CMS_TYPE_SRVC_CD LINE_PLACE_OF_SRVC_CD
							BETOS_CD 
							bene_race_cd	bene_cnty_cd
							bene_state_cd 	bene_mlg_cntct_zip_cd;
%let vars_to_drop_ip    = 	;
%let vars_to_drop_op    =  	;
%let vars_to_drop_car    =  ;

/*** this section is related to IP - inpatient claims ***/
%macro claims_rev(source=, rev_cohort=, include_cohort=);
/* identify hcpcs  */
proc sql;
create table include_cohort1a (compress=yes) as
select &bene_id, &clm_id, &hcpcs_cd
from 
	&rev_cohort
where 
	&hcpcs_cd in (&includ_hcpcs);
quit;
proc sql;
	create table include_cohort1b (compress=yes) as
select a.&hcpcs_cd, b.*
from 
	include_cohort1a a, 
	&source b
where 
	a.&bene_id=b.&bene_id and a.&clm_id=b.&clm_id;
quit;
/* identify icd  */
proc sql;
	create table include_cohort2 (compress=yes) as
select *
from 
	&source 
;
quit;
proc sql;
	create table include_cohort3 (compress=yes) as
select include_cohort1b.&hcpcs_cd, include_cohort2.*
from 
	include_cohort1b 
left join 
	include_cohort2 	
on (
	include_cohort1b.&bene_id = include_cohort2.&bene_id 
	and 
	include_cohort1b.&clm_id = include_cohort2.&clm_id
	)
;
quit;
Data &include_cohort (keep=  &vars_to_keep_ip); 
set include_cohort3;   
&flag_popped_dt=&clm_beg_dt_in; 
	format &flag_popped_dt date9.; 						label &flag_popped_dt			=	&flag_popped_dt_label;
&flag_popped=1; 										label &flag_popped				=	&flag_popped_label;
&pop_age=(&clm_beg_dt_in-&clm_dob)/365.25; 				label &pop_age					=	&pop_age_label;
&pop_age=round(&pop_age);
&pop_los=&clm_end_dt_in-&clm_beg_dt_in;					label &pop_los					=	&pop_los_label;
&pop_year=year(&clm_beg_dt_in);
&pop_nch_clm_type_cd=put(&nch_clm_type_cd, clm_type_cd.); 
														label &pop_nch_clm_type_cd		=	&pop_nch_clm_type_cd_label;
&pop_CLM_IP_ADMSN_TYPE_CD = put(&CLM_IP_ADMSN_TYPE_CD,$IP_ADMSN_TYPE_CD.);
&pop_clm_fac_type_cd = &clm_fac_type_cd; 				label &pop_clm_fac_type_cd     	= 	&pop_clm_fac_type_cd_label;
&pop_clm_src_ip_admsn_cd = &clm_src_ip_admsn_cd; 		label &pop_clm_src_ip_admsn_cd 	= 	&pop_clm_src_ip_admsn_cd_label;
&pop_ptnt_dschrg_stus_cd = &ptnt_dschrg_stus_cd; 		label &pop_ptnt_dschrg_stus_cd 	= 	&pop_ptnt_dschrg_stus_cd;
&pop_admtg_dgns_cd=put(&admtg_dgns_cd,$dgns.);
&pop_icd_dgns_cd1=put(&icd_dgns_cd1,$dgns.);
&pop_clm_drg_cd=put(&clm_drg_cd,$drg.);
&pop_hcpcs_cd=put(&hcpcs_cd,$hcpcs.);
&pop_OP_PHYSN_SPCLTY_CD=&OP_PHYSN_SPCLTY_CD;
array dx(25) &diag_pfx.&diag_cd_min - &diag_pfx.&diag_cd_max;
do j=1 to &diag_cd_max;
	if substr(dx(j),1,3) in(&includ_dx10_3) or substr(dx(j),1,4) in(&includ_dx10_4) then ALLERGY=1;
	if substr(dx(j),1,3) in(&exclud_dx10_3) or substr(dx(j),1,1) in(&exclud_dx10_1) then DELETE=1;
end;
IF ALLERGY ne 1 then delete;
IF DELETE  =  1 then delete;
*if clm_drg_cd notin(&includ_drg) then delete;
run; 
%mend;
%claims_rev(source=rif2016.inpatient_claims_01, rev_cohort=rif2016.inpatient_revenue_01, include_cohort=pop_02_IN_2016_1);
%claims_rev(source=rif2016.inpatient_claims_02, rev_cohort=rif2016.inpatient_revenue_02, include_cohort=pop_02_IN_2016_2);
%claims_rev(source=rif2016.inpatient_claims_03, rev_cohort=rif2016.inpatient_revenue_03, include_cohort=pop_02_IN_2016_3);
%claims_rev(source=rif2016.inpatient_claims_04, rev_cohort=rif2016.inpatient_revenue_04, include_cohort=pop_02_IN_2016_4);
%claims_rev(source=rif2016.inpatient_claims_05, rev_cohort=rif2016.inpatient_revenue_05, include_cohort=pop_02_IN_2016_5);
%claims_rev(source=rif2016.inpatient_claims_06, rev_cohort=rif2016.inpatient_revenue_06, include_cohort=pop_02_IN_2016_6);
%claims_rev(source=rif2016.inpatient_claims_07, rev_cohort=rif2016.inpatient_revenue_07, include_cohort=pop_02_IN_2016_7);
%claims_rev(source=rif2016.inpatient_claims_08, rev_cohort=rif2016.inpatient_revenue_08, include_cohort=pop_02_IN_2016_8);
%claims_rev(source=rif2016.inpatient_claims_09, rev_cohort=rif2016.inpatient_revenue_09, include_cohort=pop_02_IN_2016_9);
%claims_rev(source=rif2016.inpatient_claims_10, rev_cohort=rif2016.inpatient_revenue_10, include_cohort=pop_02_IN_2016_10);
%claims_rev(source=rif2016.inpatient_claims_11, rev_cohort=rif2016.inpatient_revenue_11, include_cohort=pop_02_IN_2016_11);
%claims_rev(source=rif2016.inpatient_claims_12, rev_cohort=rif2016.inpatient_revenue_12, include_cohort=pop_02_IN_2016_12);
%claims_rev(source=rif2017.inpatient_claims_01, rev_cohort=rif2017.inpatient_revenue_01, include_cohort=pop_02_IN_2017_1);
%claims_rev(source=rif2017.inpatient_claims_02, rev_cohort=rif2017.inpatient_revenue_02, include_cohort=pop_02_IN_2017_2);
%claims_rev(source=rif2017.inpatient_claims_03, rev_cohort=rif2017.inpatient_revenue_03, include_cohort=pop_02_IN_2017_3);
%claims_rev(source=rif2017.inpatient_claims_04, rev_cohort=rif2017.inpatient_revenue_04, include_cohort=pop_02_IN_2017_4);
%claims_rev(source=rif2017.inpatient_claims_05, rev_cohort=rif2017.inpatient_revenue_05, include_cohort=pop_02_IN_2017_5);
%claims_rev(source=rif2017.inpatient_claims_06, rev_cohort=rif2017.inpatient_revenue_06, include_cohort=pop_02_IN_2017_6);
%claims_rev(source=rif2017.inpatient_claims_07, rev_cohort=rif2017.inpatient_revenue_07, include_cohort=pop_02_IN_2017_7);
%claims_rev(source=rif2017.inpatient_claims_08, rev_cohort=rif2017.inpatient_revenue_08, include_cohort=pop_02_IN_2017_8);
%claims_rev(source=rif2017.inpatient_claims_09, rev_cohort=rif2017.inpatient_revenue_09, include_cohort=pop_02_IN_2017_9);
%claims_rev(source=rif2017.inpatient_claims_10, rev_cohort=rif2017.inpatient_revenue_10, include_cohort=pop_02_IN_2017_10);
%claims_rev(source=rif2017.inpatient_claims_11, rev_cohort=rif2017.inpatient_revenue_11, include_cohort=pop_02_IN_2017_11);
%claims_rev(source=rif2017.inpatient_claims_12, rev_cohort=rif2017.inpatient_revenue_12, include_cohort=pop_02_IN_2017_12);
%claims_rev(source=rifq2018.inpatient_claims_01, rev_cohort=rifq2018.inpatient_revenue_01, include_cohort=pop_02_IN_2018_1);
%claims_rev(source=rifq2018.inpatient_claims_02, rev_cohort=rifq2018.inpatient_revenue_02, include_cohort=pop_02_IN_2018_2);
%claims_rev(source=rifq2018.inpatient_claims_03, rev_cohort=rifq2018.inpatient_revenue_03, include_cohort=pop_02_IN_2018_3);
%claims_rev(source=rifq2018.inpatient_claims_04, rev_cohort=rifq2018.inpatient_revenue_04, include_cohort=pop_02_IN_2018_4);
%claims_rev(source=rifq2018.inpatient_claims_05, rev_cohort=rifq2018.inpatient_revenue_05, include_cohort=pop_02_IN_2018_5);
%claims_rev(source=rifq2018.inpatient_claims_06, rev_cohort=rifq2018.inpatient_revenue_06, include_cohort=pop_02_IN_2018_6);
%claims_rev(source=rifq2018.inpatient_claims_07, rev_cohort=rifq2018.inpatient_revenue_07, include_cohort=pop_02_IN_2018_7);
%claims_rev(source=rifq2018.inpatient_claims_08, rev_cohort=rifq2018.inpatient_revenue_08, include_cohort=pop_02_IN_2018_8);
%claims_rev(source=rifq2018.inpatient_claims_09, rev_cohort=rifq2018.inpatient_revenue_09, include_cohort=pop_02_IN_2018_9);
%claims_rev(source=rifq2018.inpatient_claims_10, rev_cohort=rifq2018.inpatient_revenue_10, include_cohort=pop_02_IN_2018_10);
%claims_rev(source=rifq2018.inpatient_claims_11, rev_cohort=rifq2018.inpatient_revenue_11, include_cohort=pop_02_IN_2018_11);
%claims_rev(source=rifq2018.inpatient_claims_12, rev_cohort=rifq2018.inpatient_revenue_12, include_cohort=pop_02_IN_2018_12);

data pop_02_IN;
set pop_02_IN_2016_1 pop_02_IN_2016_2 pop_02_IN_2016_3 pop_02_IN_2016_4 pop_02_IN_2016_5 pop_02_IN_2016_6
	pop_02_IN_2016_7 pop_02_IN_2016_8 pop_02_IN_2016_9 pop_02_IN_2016_10 pop_02_IN_2016_11 pop_02_IN_2016_12
	pop_02_IN_2017_1 pop_02_IN_2017_2 pop_02_IN_2017_3 pop_02_IN_2017_4 pop_02_IN_2017_5 pop_02_IN_2017_6
	pop_02_IN_2017_7 pop_02_IN_2017_8 pop_02_IN_2017_9 pop_02_IN_2017_10 pop_02_IN_2017_11 pop_02_IN_2017_12
	pop_02_IN_2018_1 pop_02_IN_2018_2 pop_02_IN_2018_3 pop_02_IN_2018_4 pop_02_IN_2018_5 pop_02_IN_2018_6
	pop_02_IN_2018_7 pop_02_IN_2018_8 pop_02_IN_2018_9 pop_02_IN_2018_10 pop_02_IN_2018_11 pop_02_IN_2018_12
;
if &pop_year<2016 then delete;
if &pop_year>2018 then delete;
format bene_state_cd prvdr_state_cd $state. &pop_OP_PHYSN_SPCLTY_CD $speccd. &pop_clm_src_ip_admsn_cd $src1adm.
		&pop_ptnt_dschrg_stus_cd $stuscd.;
run;
/* get rid of duplicate rows--keep first occurence so sort by date first */
proc sort data=pop_02_IN; by &bene_id &flag_popped_dt; run;
proc sort data=pop_02_IN nodupkey; by &bene_id; run;

/*** this section is related to OP - outpatient claims ***/
%macro claims_rev(source=, rev_cohort=, include_cohort=);
proc sql;
create table include_cohort1 (compress=yes) as
select &bene_id, &clm_id, &hcpcs_cd
from 
&rev_cohort
where 
hcpcs_cd in (&includ_hcpcs);
quit;
proc sql;
create table include_cohort2 (compress=yes) as
select *
from 
include_cohort1 a, 
&source b
where 
	(a.&bene_id=b.&bene_id and a.&clm_id=b.&clm_id) 
;		
quit;
Data &include_cohort (keep = &vars_to_keep_op); 
set include_cohort2;   
&flag_popped_dt=&clm_from_dt; 
	format &flag_popped_dt date9.; 			label &flag_popped_dt	=	&flag_popped_dt_label;
&flag_popped=1; 							label &flag_popped		=	&flag_popped_label;
&pop_age=(&clm_from_dt-&clm_dob)/365.25; 	label &pop_age			=	&pop_age_label;
&pop_age=round(&pop_age);
&pop_los=&clm_thru_dt-&clm_from_dt;			label &pop_los			=	&pop_los_label;
&pop_year=year(&clm_from_dt);
&pop_nch_clm_type_cd=put(&nch_clm_type_cd, clm_type_cd.); label &pop_nch_clm_type_cd	=	&pop_nch_clm_type_cd_label;
&pop_icd_dgns_cd1=put(&icd_dgns_cd1,$dgns.);
&pop_hcpcs_cd=put(&hcpcs_cd,$hcpcs.);
&pop_OP_PHYSN_SPCLTY_CD=&OP_PHYSN_SPCLTY_CD; format &pop_OP_PHYSN_SPCLTY_CD speccd.;
array dx(25) &diag_pfx.&diag_cd_min - &diag_pfx.&diag_cd_max;
do j=1 to &diag_cd_max;
	if substr(dx(j),1,3) in(&includ_dx10_3) or substr(dx(j),1,4) in(&includ_dx10_4) then ALLERGY=1;
	if substr(dx(j),1,3) in(&exclud_dx10_3) or substr(dx(j),1,1) in(&exclud_dx10_1) then DELETE=1;
end;
IF ALLERGY ne 1 then delete;
IF DELETE  =  1 then delete;
run; 
%mend;
%claims_rev(source=rif2016.OUTpatient_claims_01, rev_cohort=rif2016.OUTpatient_revenue_01, include_cohort=pop_02_OUT_2016_1);
%claims_rev(source=rif2016.OUTpatient_claims_01, rev_cohort=rif2016.OUTpatient_revenue_01, include_cohort=pop_02_OUT_2016_1);
%claims_rev(source=rif2016.OUTpatient_claims_02, rev_cohort=rif2016.OUTpatient_revenue_02, include_cohort=pop_02_OUT_2016_2);
%claims_rev(source=rif2016.OUTpatient_claims_03, rev_cohort=rif2016.OUTpatient_revenue_03, include_cohort=pop_02_OUT_2016_3);
%claims_rev(source=rif2016.OUTpatient_claims_04, rev_cohort=rif2016.OUTpatient_revenue_04, include_cohort=pop_02_OUT_2016_4);
%claims_rev(source=rif2016.OUTpatient_claims_05, rev_cohort=rif2016.OUTpatient_revenue_05, include_cohort=pop_02_OUT_2016_5);
%claims_rev(source=rif2016.OUTpatient_claims_06, rev_cohort=rif2016.OUTpatient_revenue_06, include_cohort=pop_02_OUT_2016_6);
%claims_rev(source=rif2016.OUTpatient_claims_07, rev_cohort=rif2016.OUTpatient_revenue_07, include_cohort=pop_02_OUT_2016_7);
%claims_rev(source=rif2016.OUTpatient_claims_08, rev_cohort=rif2016.OUTpatient_revenue_08, include_cohort=pop_02_OUT_2016_8);
%claims_rev(source=rif2016.OUTpatient_claims_09, rev_cohort=rif2016.OUTpatient_revenue_09, include_cohort=pop_02_OUT_2016_9);
%claims_rev(source=rif2016.OUTpatient_claims_10, rev_cohort=rif2016.OUTpatient_revenue_10, include_cohort=pop_02_OUT_2016_10);
%claims_rev(source=rif2016.OUTpatient_claims_11, rev_cohort=rif2016.OUTpatient_revenue_11, include_cohort=pop_02_OUT_2016_11);
%claims_rev(source=rif2016.OUTpatient_claims_12, rev_cohort=rif2016.OUTpatient_revenue_12, include_cohort=pop_02_OUT_2016_12);
%claims_rev(source=rif2017.OUTpatient_claims_01, rev_cohort=rif2017.OUTpatient_revenue_01, include_cohort=pop_02_OUT_2017_1);
%claims_rev(source=rif2017.OUTpatient_claims_02, rev_cohort=rif2017.OUTpatient_revenue_02, include_cohort=pop_02_OUT_2017_2);
%claims_rev(source=rif2017.OUTpatient_claims_03, rev_cohort=rif2017.OUTpatient_revenue_03, include_cohort=pop_02_OUT_2017_3);
%claims_rev(source=rif2017.OUTpatient_claims_04, rev_cohort=rif2017.OUTpatient_revenue_04, include_cohort=pop_02_OUT_2017_4);
%claims_rev(source=rif2017.OUTpatient_claims_05, rev_cohort=rif2017.OUTpatient_revenue_05, include_cohort=pop_02_OUT_2017_5);
%claims_rev(source=rif2017.OUTpatient_claims_06, rev_cohort=rif2017.OUTpatient_revenue_06, include_cohort=pop_02_OUT_2017_6);
%claims_rev(source=rif2017.OUTpatient_claims_07, rev_cohort=rif2017.OUTpatient_revenue_07, include_cohort=pop_02_OUT_2017_7);
%claims_rev(source=rif2017.OUTpatient_claims_08, rev_cohort=rif2017.OUTpatient_revenue_08, include_cohort=pop_02_OUT_2017_8);
%claims_rev(source=rif2017.OUTpatient_claims_09, rev_cohort=rif2017.OUTpatient_revenue_09, include_cohort=pop_02_OUT_2017_9);
%claims_rev(source=rif2017.OUTpatient_claims_10, rev_cohort=rif2017.OUTpatient_revenue_10, include_cohort=pop_02_OUT_2017_10);
%claims_rev(source=rif2017.OUTpatient_claims_11, rev_cohort=rif2017.OUTpatient_revenue_11, include_cohort=pop_02_OUT_2017_11);
%claims_rev(source=rif2017.OUTpatient_claims_12, rev_cohort=rif2017.OUTpatient_revenue_12, include_cohort=pop_02_OUT_2017_12);
%claims_rev(source=rifq2018.OUTpatient_claims_01, rev_cohort=rifq2018.OUTpatient_revenue_01, include_cohort=pop_02_OUT_2018_1);
%claims_rev(source=rifq2018.OUTpatient_claims_02, rev_cohort=rifq2018.OUTpatient_revenue_02, include_cohort=pop_02_OUT_2018_2);
%claims_rev(source=rifq2018.OUTpatient_claims_03, rev_cohort=rifq2018.OUTpatient_revenue_03, include_cohort=pop_02_OUT_2018_3);
%claims_rev(source=rifq2018.OUTpatient_claims_04, rev_cohort=rifq2018.OUTpatient_revenue_04, include_cohort=pop_02_OUT_2018_4);
%claims_rev(source=rifq2018.OUTpatient_claims_05, rev_cohort=rifq2018.OUTpatient_revenue_05, include_cohort=pop_02_OUT_2018_5);
%claims_rev(source=rifq2018.OUTpatient_claims_06, rev_cohort=rifq2018.OUTpatient_revenue_06, include_cohort=pop_02_OUT_2018_6);
%claims_rev(source=rifq2018.OUTpatient_claims_07, rev_cohort=rifq2018.OUTpatient_revenue_07, include_cohort=pop_02_OUT_2018_7);
%claims_rev(source=rifq2018.OUTpatient_claims_08, rev_cohort=rifq2018.OUTpatient_revenue_08, include_cohort=pop_02_OUT_2018_8);
%claims_rev(source=rifq2018.OUTpatient_claims_09, rev_cohort=rifq2018.OUTpatient_revenue_09, include_cohort=pop_02_OUT_2018_9);
%claims_rev(source=rifq2018.OUTpatient_claims_10, rev_cohort=rifq2018.OUTpatient_revenue_10, include_cohort=pop_02_OUT_2018_10);
%claims_rev(source=rifq2018.OUTpatient_claims_11, rev_cohort=rifq2018.OUTpatient_revenue_11, include_cohort=pop_02_OUT_2018_11);
%claims_rev(source=rifq2018.OUTpatient_claims_12, rev_cohort=rifq2018.OUTpatient_revenue_12, include_cohort=pop_02_OUT_2018_12);

data pop_02_OUT;
set pop_02_OUT_2016_1 pop_02_OUT_2016_2 pop_02_OUT_2016_3 pop_02_OUT_2016_4 pop_02_OUT_2016_5 pop_02_OUT_2016_6
	pop_02_OUT_2016_7 pop_02_OUT_2016_8 pop_02_OUT_2016_9 pop_02_OUT_2016_10 pop_02_OUT_2016_11 pop_02_OUT_2016_12
	pop_02_OUT_2017_1 pop_02_OUT_2017_2 pop_02_OUT_2017_3 pop_02_OUT_2017_4 pop_02_OUT_2017_5 pop_02_OUT_2017_6
	pop_02_OUT_2017_7 pop_02_OUT_2017_8 pop_02_OUT_2017_9 pop_02_OUT_2017_10 pop_02_OUT_2017_11 pop_02_OUT_2017_12
	pop_02_OUT_2018_1 pop_02_OUT_2018_2 pop_02_OUT_2018_3 pop_02_OUT_2018_4 pop_02_OUT_2018_5 pop_02_OUT_2018_6
	pop_02_OUT_2018_7 pop_02_OUT_2018_8 pop_02_OUT_2018_9 pop_02_OUT_2018_10 pop_02_OUT_2018_11 pop_02_OUT_2018_12
;
if pop_02_year<2016 then delete;
if pop_02_year>2018 then delete;
format &pop_OP_PHYSN_SPCLTY_CD $speccd. &pop_icd_dgns_cd1 $dgns. &pop_hcpcs_cd $hcpcs.;
run;
*get rid of duplicate rows by DATE only---don't sort by bene_id yet
	so we can see all of the possible DX, CPT, PR codes possibly associated
	with the measure during data checks;
proc sort data=pop_02_OUT nodupkey; by bene_id &flag_popped_dt; run;

/**Do same for Carrier file that we did for Outpatient**/
%macro claims_rev(source=, rev_cohort=, include_cohort=);
proc sql;
create table include_cohort1 (compress=yes) as
select *
from 
&rev_cohort
where 
hcpcs_cd in (&includ_hcpcs);
quit;
proc sql;
create table include_cohort2 (compress=yes) as
select *
from 
include_cohort1 a, 
&source b
where 
	(a.&bene_id=b.&bene_id and a.&clm_id=b.&clm_id) 
;		
quit;
Data &include_cohort (keep = &vars_to_keep_car); 
set include_cohort2;   
&flag_popped_dt=&clm_from_dt; 
	format &flag_popped_dt date9.; 			label &flag_popped_dt	=	&flag_popped_dt_label;
&flag_popped=1; 							label &flag_popped		=	&flag_popped_label;
&pop_age=(&clm_from_dt-&clm_dob)/365.25; 	label &pop_age			=	&pop_age_label;
&pop_age=round(&pop_age);
&pop_los=&clm_thru_dt-&clm_from_dt;			label &pop_los			=	&pop_los_label;
&pop_year=year(&clm_from_dt);
&pop_nch_clm_type_cd=put(&nch_clm_type_cd, clm_type_cd.); label &pop_nch_clm_type_cd	=	&pop_nch_clm_type_cd_label;
&pop_icd_dgns_cd1=put(&icd_dgns_cd1,$dgns.);
&pop_hcpcs_cd=put(&hcpcs_cd,$hcpcs.);
array dx(25) &diag_pfx.&diag_cd_min - &diag_pfx.&diag_cd_max;
do j=1 to &diag_cd_max;
	if substr(dx(j),1,3) in(&includ_dx10_3) or substr(dx(j),1,4) in(&includ_dx10_4) then ALLERGY=1;
	if substr(dx(j),1,3) in(&exclud_dx10_3) or substr(dx(j),1,1) in(&exclud_dx10_1) then DELETE=1;
end;
IF ALLERGY ne 1 then delete;
IF DELETE  =  1 then delete;
run; 
%mend;
%claims_rev(source=rif2016.bcarrier_claims_01, rev_cohort=rif2016.bcarrier_line_01, include_cohort=pop_02_CAR_2016_1);
%claims_rev(source=rif2016.bcarrier_claims_01, rev_cohort=rif2016.bcarrier_line_01, include_cohort=pop_02_CAR_2016_1);
%claims_rev(source=rif2016.bcarrier_claims_02, rev_cohort=rif2016.bcarrier_line_02, include_cohort=pop_02_CAR_2016_2);
%claims_rev(source=rif2016.bcarrier_claims_03, rev_cohort=rif2016.bcarrier_line_03, include_cohort=pop_02_CAR_2016_3);
%claims_rev(source=rif2016.bcarrier_claims_04, rev_cohort=rif2016.bcarrier_line_04, include_cohort=pop_02_CAR_2016_4);
%claims_rev(source=rif2016.bcarrier_claims_05, rev_cohort=rif2016.bcarrier_line_05, include_cohort=pop_02_CAR_2016_5);
%claims_rev(source=rif2016.bcarrier_claims_06, rev_cohort=rif2016.bcarrier_line_06, include_cohort=pop_02_CAR_2016_6);
%claims_rev(source=rif2016.bcarrier_claims_07, rev_cohort=rif2016.bcarrier_line_07, include_cohort=pop_02_CAR_2016_7);
%claims_rev(source=rif2016.bcarrier_claims_08, rev_cohort=rif2016.bcarrier_line_08, include_cohort=pop_02_CAR_2016_8);
%claims_rev(source=rif2016.bcarrier_claims_09, rev_cohort=rif2016.bcarrier_line_09, include_cohort=pop_02_CAR_2016_9);
%claims_rev(source=rif2016.bcarrier_claims_10, rev_cohort=rif2016.bcarrier_line_10, include_cohort=pop_02_CAR_2016_10);
%claims_rev(source=rif2016.bcarrier_claims_11, rev_cohort=rif2016.bcarrier_line_11, include_cohort=pop_02_CAR_2016_11);
%claims_rev(source=rif2016.bcarrier_claims_12, rev_cohort=rif2016.bcarrier_line_12, include_cohort=pop_02_CAR_2016_12);
%claims_rev(source=rif2017.bcarrier_claims_01, rev_cohort=rif2017.bcarrier_line_01, include_cohort=pop_02_CAR_2017_1);
%claims_rev(source=rif2017.bcarrier_claims_02, rev_cohort=rif2017.bcarrier_line_02, include_cohort=pop_02_CAR_2017_2);
%claims_rev(source=rif2017.bcarrier_claims_03, rev_cohort=rif2017.bcarrier_line_03, include_cohort=pop_02_CAR_2017_3);
%claims_rev(source=rif2017.bcarrier_claims_04, rev_cohort=rif2017.bcarrier_line_04, include_cohort=pop_02_CAR_2017_4);
%claims_rev(source=rif2017.bcarrier_claims_05, rev_cohort=rif2017.bcarrier_line_05, include_cohort=pop_02_CAR_2017_5);
%claims_rev(source=rif2017.bcarrier_claims_06, rev_cohort=rif2017.bcarrier_line_06, include_cohort=pop_02_CAR_2017_6);
%claims_rev(source=rif2017.bcarrier_claims_07, rev_cohort=rif2017.bcarrier_line_07, include_cohort=pop_02_CAR_2017_7);
%claims_rev(source=rif2017.bcarrier_claims_08, rev_cohort=rif2017.bcarrier_line_08, include_cohort=pop_02_CAR_2017_8);
%claims_rev(source=rif2017.bcarrier_claims_09, rev_cohort=rif2017.bcarrier_line_09, include_cohort=pop_02_CAR_2017_9);
%claims_rev(source=rif2017.bcarrier_claims_10, rev_cohort=rif2017.bcarrier_line_10, include_cohort=pop_02_CAR_2017_10);
%claims_rev(source=rif2017.bcarrier_claims_11, rev_cohort=rif2017.bcarrier_line_11, include_cohort=pop_02_CAR_2017_11);
%claims_rev(source=rif2017.bcarrier_claims_12, rev_cohort=rif2017.bcarrier_line_12, include_cohort=pop_02_CAR_2017_12);
%claims_rev(source=rifq2018.bcarrier_claims_01, rev_cohort=rifq2018.bcarrier_line_01, include_cohort=pop_02_CAR_2018_1);
%claims_rev(source=rifq2018.bcarrier_claims_02, rev_cohort=rifq2018.bcarrier_line_02, include_cohort=pop_02_CAR_2018_2);
%claims_rev(source=rifq2018.bcarrier_claims_03, rev_cohort=rifq2018.bcarrier_line_03, include_cohort=pop_02_CAR_2018_3);
%claims_rev(source=rifq2018.bcarrier_claims_04, rev_cohort=rifq2018.bcarrier_line_04, include_cohort=pop_02_CAR_2018_4);
%claims_rev(source=rifq2018.bcarrier_claims_05, rev_cohort=rifq2018.bcarrier_line_05, include_cohort=pop_02_CAR_2018_5);
%claims_rev(source=rifq2018.bcarrier_claims_06, rev_cohort=rifq2018.bcarrier_line_06, include_cohort=pop_02_CAR_2018_6);
%claims_rev(source=rifq2018.bcarrier_claims_07, rev_cohort=rifq2018.bcarrier_line_07, include_cohort=pop_02_CAR_2018_7);
%claims_rev(source=rifq2018.bcarrier_claims_08, rev_cohort=rifq2018.bcarrier_line_08, include_cohort=pop_02_CAR_2018_8);
%claims_rev(source=rifq2018.bcarrier_claims_09, rev_cohort=rifq2018.bcarrier_line_09, include_cohort=pop_02_CAR_2018_9);
%claims_rev(source=rifq2018.bcarrier_claims_10, rev_cohort=rifq2018.bcarrier_line_10, include_cohort=pop_02_CAR_2018_10);
%claims_rev(source=rifq2018.bcarrier_claims_11, rev_cohort=rifq2018.bcarrier_line_11, include_cohort=pop_02_CAR_2018_11);
%claims_rev(source=rifq2018.bcarrier_claims_12, rev_cohort=rifq2018.bcarrier_line_12, include_cohort=pop_02_CAR_2018_12);

data pop_02_car;
set pop_02_car_2016_1 pop_02_car_2016_2 pop_02_car_2016_3 pop_02_car_2016_4 pop_02_car_2016_5 pop_02_car_2016_6
	pop_02_car_2016_7 pop_02_car_2016_8 pop_02_car_2016_9 pop_02_car_2016_10 pop_02_car_2016_11 pop_02_car_2016_12
	pop_02_car_2017_1 pop_02_car_2017_2 pop_02_car_2017_3 pop_02_car_2017_4 pop_02_car_2017_5 pop_02_car_2017_6
	pop_02_car_2017_7 pop_02_car_2017_8 pop_02_car_2017_9 pop_02_car_2017_10 pop_02_car_2017_11 pop_02_car_2017_12
	pop_02_car_2018_1 pop_02_car_2018_2 pop_02_car_2018_3 pop_02_car_2018_4 pop_02_car_2018_5 pop_02_car_2018_6
	pop_02_car_2018_7 pop_02_car_2018_8 pop_02_car_2018_9 pop_02_car_2018_10 pop_02_car_2018_11 pop_02_car_2018_12
;
if pop_02_year<2016 then delete;
if pop_02_year>2018 then delete;
format &pop_OP_PHYSN_SPCLTY_CD $speccd. &pop_icd_dgns_cd1 $dgns. &pop_hcpcs_cd $hcpcs.;
run;
*get rid of duplicate rows--keep duplicate bene_ids for same reason as OP;
proc sort data=pop_02_car nodupkey; by bene_id &flag_popped_dt; run;

/**This section makes summaries for inpatient, outpatient carrier POPPED **/
*look at inpatient info;
%macro poppedlook(in=);
proc freq data=&in order=freq noprint; 
table  	&flag_popped /nocum out=&flag_popped (drop = count); run;
proc print data=&flag_popped noobs; run;

proc freq data=&in order=freq noprint; 
table  	&pop_year /nocum out=&pop_year (drop = count); run;
proc print data=&pop_year noobs; run;

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
title 'Inpatient Popped';
%poppedlook(in=pop_02_IN);
		/*bene_state_cd prvdr_state_cd 
		&pop_OP_PHYSN_SPCLTY_CD &pop_clm_fac_type_cd &pop_ptnt_dschrg_stus_cd
		&pop_nch_clm_type_cd &pop_CLM_IP_ADMSN_TYPE_CD &pop_clm_src_ip_admsn_cd*/  
title 'Outpatient Popped';
%poppedlook(in=pop_02_OUT);
title 'Carrier Popped';
%poppedlook(in=pop_02_car);

*compile all Inpatient and Outpatient Popped into 1 dataset
		DO NOT INCLUDE CARRIER
		Keep ONLY the first observation per person;
data pop_02_in_out;
set pop_02_IN pop_02_OUT;
run;
proc sort data=pop_02_in_out nodupkey; by bene_id &flag_popped_dt; run;
proc sort data=pop_02_in_out nodupkey; by bene_id; run;

