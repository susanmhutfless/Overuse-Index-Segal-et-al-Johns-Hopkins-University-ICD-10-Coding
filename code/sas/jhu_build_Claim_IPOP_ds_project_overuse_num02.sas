/********************************************************************
* Job Name: jhu_build_Claim_IPOP_ds_project_overuse_num02.sas
* Job Desc: Input for Inpatient Claims 
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************/

/*** Indicator description ***/
/* Description and codes from .xlsx file  "ICD-10 conversions_12_06-19" */

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

/*inclusion criteria*/
%global includ_hcpcs;
%global includ_pr10;

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
%global flag_popped																;
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
%let  ds_all_ip          =  &lwork..num02_ip_2010_14_all						; 
%let  ds_all_op          =  &lwork..num02_ot_2010_14_all						; 
%let  ds_all_car         =  &lwork..num02_car_2010_14_all						;


/*** end of indicator specific variables ***/


/*** start of section - global vars ***/
%global lwork ltemp shlib                    	;   /** libname prefix **/
%global pat_id clm_id                       	;
%global pat_id                               	;

/*** libname prefix alias assignments ***/
%let  lwork              = work              	;
%let  ltemp              = temp              	;
%let  shlib              = shu172sl          	;

%let  pat_id             = bene_id      		;
%let  clm_id             = clm_id            	;


%global diag_pfx diag_cd_min diag_cd_max 		;
%global plc_of_srvc_cd                   		;
%global ds_all_prefix                    		;
%let  ds_all_prefix      = 						; 

%let  diag_pfx           = icd_dgns_cd_         ;
%let  diag_cd_min        = 1                 	;
%let  diag_cd_max        = 25                 	;

%let  proc_pfx           = icd_prcdr_          	;
%let  proc_cd_min        = 1                 	;
%let  proc_cd_max        = 25                 	;

%let  plc_of_srvc_cd     = clm_fac_type_cd    	;

%global age										;
%global clm_beg_dt clm_end_dt clm_dob clm_pymt_dt	;
%global clm_drg 								;
%let  age                = age_at_proc          ;
%let  clm_beg_dt         = clm_from_dt   		;
%let  clm_end_dt         = clm_thru_dt   		;
%let  clm_pymt_dt        = clm_pymt_dt     		;
%let  clm_drg            = clm_drg_cd    		;
%let  clm_dob            = dob_dt       		;

/*** end of section   - global vars ***/

/*** start of section - OUTPUT DS NAMES ***/

/*** end of section   - OUTPUT DS NAMES ***/

%let vpath     = /sas/vrdc/users/shu172/files   ;
%let proj_path = /jhu_projects/overuse          ;
%let code_path = /code/                         ;
%let vrdc_code = &vpath./jhu_vrdc_code          ;


/*** start of section - local vars remote work ***/
%include "&vrdc_code./remote_dev_work_local.sas";
/*** end of section   - local vars remote work ***/

/*** make sure to run macros in ***/
%include "&vrdc_code./macro_tool_box.sas"		;


%global vars_to_keep_ip_op						;
%global vars_to_keep_ip   						;

%global vars_to_drop_op   						;
%global vars_to_drop_op   						;

%let vars_to_keep_ip_op = 	pop:
							bene_id 
							gndr_cd 
							bene_race_cd
							bene_cnty_cd
							bene_state_cd 
							bene_mlg_cntct_zip_cd  
							prvdr_num 
							prvdr_state_cd 
							at_physn_npi 
							op_physn_npi 
							org_npi_num 
							ot_physn_npi 
							rndrng_physn_npi
                          ;

%let vars_to_keep_ip    = 	bene_id clm_id clm_admsn_dt dob_dt NCH_BENE_DSCHRG_DT ptnt_dschrg_stus_cd
							nch_clm_type_cd CLM_IP_ADMSN_TYPE_CD clm_fac_type_cd clm_src_ip_admsn_cd 
							admtg_dgns_cd clm_drg_cd icd_dgns_cd1-icd_dgns_cd25  
							gndr_cd bene_race_cd bene_cnty_cd bene_state_cd bene_mlg_cntct_zip_cd  
							prvdr_num prvdr_state_cd OP_PHYSN_SPCLTY_CD
							at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi;                         
%let vars_to_keep_op	=	;
%let vars_to_drop_ip    = 	;
%let vars_to_drop_op    =  	;

%global view_lib;
libname sviews "/sas/vrdc/users/shu172/sviewsl";
%let    view_lib = sviews;

libname view_out "/sas/vrdc/users/shu172/sviewsl/view_out";
%global def_proj_src_ds_prefix;
%let    def_proj_src_ds_prefix = max;


/*** this section is related to IP - inpatient claims ***/
/*   get inpatient procedure codes                         */

*%macro create_dsk(view_lib       = ,
                  src_lib_prefix = ,
                  year           = ,
                  prefix         = ,
                  ctype          = );
*start of code;

%macro claims_rev(source=, rev_cohort=, include_cohort=);
/* identify hcpcs  */
proc sql;
create table include_cohort1a (compress=yes) as
select bene_id, clm_id, hcpcs_cd
from 
	&rev_cohort
where 
	hcpcs_cd in (&includ_hcpcs);
quit;
proc sql;
	create table include_cohort1b (compress=yes) as
select a.hcpcs_cd, b.*
from 
	include_cohort1a a, 
	&source b
where 
	a.bene_id=b.bene_id and a.clm_id=b.clm_id;
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
select include_cohort1b.hcpcs_cd, include_cohort2.*
from 
	include_cohort1b 
left join 
	include_cohort2 	(keep = &vars_to_keep_ip )
on (
	include_cohort1b.bene_id = include_cohort2.bene_id and include_cohort1b.clm_id = include_cohort2.clm_id
	)
;
quit;
Data &include_cohort (keep= &vars_to_keep_ip_op); 
set include_cohort3;   
&flag_popped_dt=clm_admsn_dt; 
	format &flag_popped_dt date9.; 						label &flag_popped_dt			=	&flag_popped_dt_label;
&flag_popped=1; 										label &flag_popped				=	&flag_popped_label;
&pop_age=(clm_admsn_dt-dob_dt)/365.25; 					label &pop_age					=	&pop_age_label;
&pop_age=round(&pop_age);
&pop_los=NCH_BENE_DSCHRG_DT-clm_admsn_dt;				label &pop_los					=	&pop_los_label;
&pop_year=year(clm_admsn_dt);
&pop_nch_clm_type_cd=put(nch_clm_type_cd, clm_type_cd.); 
														label &pop_nch_clm_type_cd		=	&pop_nch_clm_type_cd_label;
&pop_CLM_IP_ADMSN_TYPE_CD = put(CLM_IP_ADMSN_TYPE_CD,$IP_ADMSN_TYPE_CD.);
&pop_clm_fac_type_cd = clm_fac_type_cd; 				label &pop_clm_fac_type_cd     	= 	&pop_clm_fac_type_cd_label;
&pop_clm_src_ip_admsn_cd = clm_src_ip_admsn_cd; 		label &pop_clm_src_ip_admsn_cd 	= 	&pop_clm_src_ip_admsn_cd_label;
&pop_ptnt_dschrg_stus_cd = ptnt_dschrg_stus_cd; 		label &pop_ptnt_dschrg_stus_cd 	= 	&pop_ptnt_dschrg_stus_cd;
&pop_admtg_dgns_cd=put(admtg_dgns_cd,$dgns.);
&pop_icd_dgns_cd1=put(icd_dgns_cd1,$dgns.);
&pop_clm_drg_cd=put(clm_drg_cd,$drg.);
&pop_hcpcs_cd=put(hcpcs_cd,$hcpcs.);
&pop_OP_PHYSN_SPCLTY_CD=OP_PHYSN_SPCLTY_CD;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
do j=1 to 25;
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
run;
/* get rid of duplicate rows--keep first occurence so sort by date first */
proc sort data=pop_02_IN; by bene_id &flag_popped_dt; run;
proc sort data=pop_02_IN nodupkey; by bene_id; run;

*look at inpatient info;
proc freq data=pop_02_IN order=freq; 
table  	&flag_popped &pop_year gndr_cd bene_state_cd prvdr_state_cd 
		&pop_OP_PHYSN_SPCLTY_CD &pop_ptnt_dschrg_stus_cd
		&pop_nch_clm_type_cd &pop_CLM_IP_ADMSN_TYPE_CD &pop_clm_fac_type_cd &pop_clm_src_ip_admsn_cd
		&pop_admtg_dgns_cd &pop_icd_dgns_cd1 &pop_clm_drg_cd &pop_hcpcs_cd; 
format bene_state_cd prvdr_state_cd $state. &pop_OP_PHYSN_SPCLTY_CD $speccd. &pop_clm_src_ip_admsn_cd $src1adm.
		&pop_ptnt_dschrg_stus_cd $stuscd.;
run;

proc means data=pop_02_IN n mean median min max; var &flag_popped_dt &pop_age &pop_los; run;


/*** this section is related to OP - outpatient claims ***/

*%macro create_dsk(view_lib       = ,
                  src_lib_prefix = ,
                  year           = ,
                  prefix         = ,
                  ctype          = );
*start of outpatient code;

%macro claims_rev(source=, rev_cohort=, include_cohort=);
proc sql;
create table include_cohort1 (compress=yes) as
select bene_id, clm_id, hcpcs_cd
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
	(a.bene_id=b.bene_id and a.clm_id=b.clm_id) 
;		
quit;
Data &include_cohort (keep = &vars_to_keep_ip_op); 
set include_cohort2;   
&flag_popped_dt=clm_from_dt; 
	format &flag_popped_dt date9.; 			label &flag_popped_dt	=	&flag_popped_dt_label;
&flag_popped=1; 							label &flag_popped		=	&flag_popped_label;
&pop_age=(clm_from_dt-dob_dt)/365.25; 		label &pop_age			=	&pop_age_label;
&pop_age=round(&pop_age);
&pop_los=clm_thru_dt-clm_from_dt;			label &pop_los			=	&pop_los_label;
&pop_year=year(clm_from_dt);
&pop_nch_clm_type_cd=put(nch_clm_type_cd, clm_type_cd.); label &pop_nch_clm_type_cd	=	&pop_nch_clm_type_cd_label;

&pop_icd_dgns_cd1=put(icd_dgns_cd1,$dgns.);
&pop_hcpcs_cd=put(hcpcs_cd,$hcpcs.);
&pop_OP_PHYSN_SPCLTY_CD=OP_PHYSN_SPCLTY_CD; format &pop_OP_PHYSN_SPCLTY_CD speccd.;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
do j=1 to 25;
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
run;
*get rid of duplicate rows;
proc sort data=pop_02_OUT nodupkey; by bene_id &flag_popped_dt; run;

*look at OUTpatient info;
proc freq data=pop_02_OUT order=freq; 
table  &flag_popped &pop_year &pop_OP_PHYSN_SPCLTY_CD &pop_nch_clm_type_cd 
		 &pop_hcpcs_cd &pop_icd_dgns_cd1 ; 
format &pop_OP_PHYSN_SPCLTY_CD $speccd. &pop_icd_dgns_cd1 $dgns. &pop_hcpcs_cd $hcpcs.;
run;

proc means data=pop_02_OUT n mean median min max; var &flag_popped_dt pop_02_age pop_02_los; run;