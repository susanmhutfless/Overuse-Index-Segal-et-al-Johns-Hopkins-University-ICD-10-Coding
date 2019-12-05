/********************************************************************
* Job Name: jhu_build_Claim_IP_ds_project_overuse.sas
* Job Desc: Input for Inpatient Claims 
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************/

/*** Indicator description ***/
/*this example was created for hysterectomy**
From sheet/manuscript, located at .....add later for final......
Useful as build (how to concat from excel to tak exact codes): =CONCATENATE("'",D1,"'")

(New) Number 		11	
Indicator 			Hysterectomy for benign disease	
Indicator
			Motivator: there are too many hysterectomies performed for benign disease
			that could be managed more conservatively

			Indicator: Hysterectomy performed for an indication other than a cancer diagnosis
			of a pelvic organ (ovary, uterus, peritoneum, cervix, bladder).

			[this can be reported among all patients with hysterectomy]

Timing		Inclusionary diagnosis code is associated with the procedure code (same claim)
			or same admission (with primary diagnosis)	

System		Gyne	

Actor		Gynecologist, occasionally general surgeon
*/

/*** start of indicator specific variables ***/

/*inclusion criteria*/
%global includ_hcpcs;
%global includ_pr10;

%let includ_hcpcs =
					'58150'	'58152'	'58180'	'58200'
					'58210'	'58260'	'58262'	'58263'	
					'58267'	'58270'	'58275'	'58280'
					'58285'	'58290'	'58291'	'58292'
					'59293'	'59294'	'58541'	'58542'
					'58543'	'58544'	'58548'	'58550'
					'58552'	'58553'	'58554'	'58570'
					'58571'	'58572'	'58573'				;

%let includ_pr10 =
					'0UT94ZL'	'0UT90ZL'	'0UT94ZZ'
					'0UT90ZZ'	'0UT9FZL'	'0UT9FZZ'
					'0UT97ZL'	'0UT98ZL'	'0UT97ZZ'
					'0UT98ZZ'	'0UT44ZZ'	'0UT94ZZ'
					'0UT40ZZ'	'0UT90ZZ'	'0UT44ZZ'
					'0UT9FZZ'	'0UT47ZZ'	'0UT48ZZ'
					'0UT97ZZ'	'0UT98ZZ'	'0UT90ZZ'
					'0UT94ZZ'	'0UT90ZL'	'0UT90ZZ'
					'0UT94ZL'	'0UT94ZZ'	'0UT97ZL'
					'0UT97ZZ'	'0UT98ZL'	'0UT98ZZ'
					'0UT9FZL'	'0UT9FZZ'				;

%let includ_drg = ;

/** Exclusion criteria **/
%let EXCLUD_dx10_1='C'; 

/** label pop specific variables **/
%global flag_popped																;
%let 	flag_popped             		= popped11 								;
%let 	flag_popped_label				= 'indicator 11 popped'					;	
%let	flag_popped_dt					= popped11_dt							;
%let 	flag_popped_dt_label			= 'indicator 11 date patient popped'	;
%let 	pop_age							= pop_11_age							;				
%let	pop_age_label					= 'age at pop 11'						;
%let	pop_los							= pop_11_los							;
%let	pop_los_label					= 'length of stay when patient popped'	;
%let	pop_year						= pop_11_year							;
%let	pop_nch_clm_type_cd				= pop_11_nch_clm_type_cd				;
%let  	pop_CLM_IP_ADMSN_TYPE_CD		= pop_11_CLM_IP_ADMSN_TYPE_CD			;
%let	pop_clm_fac_type_cd				= pop_11_clm_fac_type_cd				;
%let	pop_clm_src_ip_admsn_cd			= pop_11_clm_src_ip_admsn_cd					;
%let	pop_ptnt_dschrg_stus_cd  		= pop_11_ptnt_dschrg_stus_cd			;
%let	pop_admtg_dgns_cd				= pop_11_admtg_dgns_cd					;
%let	pop_icd_dgns_cd1				= pop_11_icd_dgns_cd1					;
%let	pop_clm_drg_cd					= pop_11_clm_drg_cd						;
%let	pop_hcpcs_cd					= pop_11_hcpcs_cd						;
%let	pop_OP_PHYSN_SPCLTY_CD			= pop_11_OP_PHYSN_SPCLTY_CD				;

%let	pop_nch_clm_type_cd_label		= 'claim/facility type for pop 11' 		;
%let	pop_CLM_IP_ADMSN_TYPE_CD_label	= 'inpatient admission type code for pop 11'	;
%let  	pop_clm_fac_type_cd_label		= 'inpatient clm_fac_type_cd for pop 11';
%let	pop_clm_src_ip_admsn_cd_label	= 'clm_src_ip_admsn_cd for pop 11'		;
%let	pop_ptnt_dschrg_stus_cd_label	= 'discharge status code for pop 11'	;	


/*** end of indicator specific variables ***/

/*** start of section - global vars ***/
%global lwork ltemp shlib                    ;   /** libname prefix **/
%global pat_id clm_id                       ;
%global pat_id                               ;

/*** libname prefix alias assignments ***/
%let  lwork              = work              ;
%let  ltemp              = temp              ;
%let  shlib              = shu172sl          ;

%let  pat_id             = bene_id      ;
%let  clm_id             = clm_id            ;


%global diag_pfx diag_cd_min diag_cd_max ;
%global plc_of_srvc_cd                   ;
%global ds_all_prefix                    ;
%let  ds_all_prefix      = ;
%let  ds_all_ip          =  &lwork..num11_ip_2010_14_all; 
%let  ds_all_op          =  &lwork..num11_ot_2010_14_all; 
%let  ds_all_car         =  &lwork..num11_car_2010_14_all; 

%let  diag_pfx           = icd_dgns_cd_          ;
%let  diag_cd_min        = 1                 ;
%let  diag_cd_max        = 25                 ;

%let  proc_pfx           = icd_prcdr_          ;
%let  proc_cd_min        = 1                 ;
%let  proc_cd_max        = 25                 ;

%let  plc_of_srvc_cd     = clm_fac_type_cd    ;

%global age;
%global clm_beg_dt clm_end_dt clm_dob clm_pymt_dt;
%global clm_drg ;
%let  age                = age_at_proc           ;
%let  clm_beg_dt         = clm_from_dt   ;
%let  clm_end_dt         = clm_thru_dt   ;
%let  clm_pymt_dt        = clm_pymt_dt     ;
%let  clm_drg            = clm_drg_cd    ;
%let  clm_dob            = dob_dt       ;

/*** end of section   - global vars ***/

/*** start of section - OUTPUT DS NAMES ***/

/*** end of section   - OUTPUT DS NAMES ***/

%let vpath     = /sas/vrdc/users/shu172/files     ;
%let proj_path = /jhu_projects/overuse          ;
%let code_path = /code/                           ;
%let vrdc_code = &vpath./jhu_vrdc_code            ;


/*** start of section - local vars remote work ***/
%include "&vrdc_code./remote_dev_work_local.sas";
/*** end of section   - local vars remote work ***/

/*** make sure to run macros in ***/
%include "&vrdc_code./macro_tool_box.sas";


%global vars_to_keep_ip_op;
%global vars_to_keep_ip   ;

%global vars_to_drop_op   ;
%global vars_to_drop_op   ;

%let vars_to_keep_ip_op = el_:
                          eth:
                          msng_elg:
                          race_:
                          prcdr:
                          state:
                          diag:
                          prvdr:
                          msis_id:
                          bene_id:
                          pymt_dt
                          srvc_:
                          yr_num
                          ;

%let vars_to_keep_ip    = admsn_dt
                          patient_status_cd
                          chrg_amt
                          prncpl_prcdr_dt
                          ;

%let vars_to_drop_ip    = el_mdcr_ann: el_mdcr_xov: prcdr_cd_sys: ;

%let vars_to_drop_op    = el_mdcr_ann: el_mdcr_xov:               ;

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
		icd_prcdr_cd25 in(&includ_pr10) 
;		
quit;
proc sql;
	create table include_cohort3 (compress=yes) as
select include_cohort1b.hcpcs_cd, include_cohort2.*
from 
	include_cohort1b 
right outer join 
	include_cohort2 
					(keep = bene_id clm_id clm_admsn_dt dob_dt NCH_BENE_DSCHRG_DT ptnt_dschrg_stus_cd
							nch_clm_type_cd CLM_IP_ADMSN_TYPE_CD clm_fac_type_cd clm_src_ip_admsn_cd 
							admtg_dgns_cd clm_drg_cd icd_dgns_cd1-icd_dgns_cd25  
							gndr_cd bene_race_cd bene_cnty_cd bene_state_cd bene_mlg_cntct_zip_cd  
							prvdr_num prvdr_state_cd OP_PHYSN_SPCLTY_CD
							at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi )
on (
	include_cohort1b.bene_id = include_cohort2.bene_id and include_cohort1b.clm_id = include_cohort2.clm_id
	)
;
quit;
Data &include_cohort (keep= pop:
		bene_id gndr_cd bene_race_cd bene_cnty_cd bene_state_cd bene_mlg_cntct_zip_cd  
		prvdr_num prvdr_state_cd 
		at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi); 
set include_cohort3;   
&flag_popped_dt=clm_admsn_dt; format &flag_popped_dt date9.; 			label &flag_popped_dt=&flag_popped_dt_label;
&flag_popped=1; 							label &flag_popped=&flag_popped_label;
&pop_age=(clm_admsn_dt-dob_dt)/365.25; label &pop_age=&pop_age_label;
&pop_age=round(&pop_age);
&pop_los=NCH_BENE_DSCHRG_DT-clm_admsn_dt;	label &pop_los=&pop_los_label;
&pop_year=year(clm_admsn_dt);
&pop_nch_clm_type_cd=put(nch_clm_type_cd, clm_type_cd.); label &pop_nch_clm_type_cd=&pop_nch_clm_type_cd_label;
&pop_CLM_IP_ADMSN_TYPE_CD = put(CLM_IP_ADMSN_TYPE_CD,$IP_ADMSN_TYPE_CD.);
&pop_clm_fac_type_cd = clm_fac_type_cd; 		label &pop_clm_fac_type_cd = &pop_clm_fac_type_cd_label;
&pop_clm_src_ip_admsn_cd = clm_src_ip_admsn_cd; label &pop_clm_src_ip_admsn_cd = &pop_clm_src_ip_admsn_cd_label;
&pop_ptnt_dschrg_stus_cd = ptnt_dschrg_stus_cd; label &pop_ptnt_dschrg_stus_cd = &pop_ptnt_dschrg_stus_cd;
&pop_admtg_dgns_cd=put(admtg_dgns_cd,$dgns.);
&pop_icd_dgns_cd1=put(icd_dgns_cd1,$dgns.);
&pop_clm_drg_cd=put(clm_drg_cd,$drg.);
&pop_hcpcs_cd=put(hcpcs_cd,$hcpcs.);
&pop_OP_PHYSN_SPCLTY_CD=OP_PHYSN_SPCLTY_CD;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
do j=1 to 25;
	if substr(dx(j),1,3) in(&EXCLUD_dx10_3) then delete;
end;
*if clm_drg_cd notin(&includ_drg) then delete;
run; 
%mend;
%claims_rev(source=rif2016.inpatient_claims_01, rev_cohort=rif2016.inpatient_revenue_01, include_cohort=pop_11_IN_2016_1);
%claims_rev(source=rif2016.inpatient_claims_02, rev_cohort=rif2016.inpatient_revenue_02, include_cohort=pop_11_IN_2016_2);
%claims_rev(source=rif2016.inpatient_claims_03, rev_cohort=rif2016.inpatient_revenue_03, include_cohort=pop_11_IN_2016_3);
%claims_rev(source=rif2016.inpatient_claims_04, rev_cohort=rif2016.inpatient_revenue_04, include_cohort=pop_11_IN_2016_4);
%claims_rev(source=rif2016.inpatient_claims_05, rev_cohort=rif2016.inpatient_revenue_05, include_cohort=pop_11_IN_2016_5);
%claims_rev(source=rif2016.inpatient_claims_06, rev_cohort=rif2016.inpatient_revenue_06, include_cohort=pop_11_IN_2016_6);
%claims_rev(source=rif2016.inpatient_claims_07, rev_cohort=rif2016.inpatient_revenue_07, include_cohort=pop_11_IN_2016_7);
%claims_rev(source=rif2016.inpatient_claims_08, rev_cohort=rif2016.inpatient_revenue_08, include_cohort=pop_11_IN_2016_8);
%claims_rev(source=rif2016.inpatient_claims_09, rev_cohort=rif2016.inpatient_revenue_09, include_cohort=pop_11_IN_2016_9);
%claims_rev(source=rif2016.inpatient_claims_10, rev_cohort=rif2016.inpatient_revenue_10, include_cohort=pop_11_IN_2016_10);
%claims_rev(source=rif2016.inpatient_claims_11, rev_cohort=rif2016.inpatient_revenue_11, include_cohort=pop_11_IN_2016_11);
%claims_rev(source=rif2016.inpatient_claims_12, rev_cohort=rif2016.inpatient_revenue_12, include_cohort=pop_11_IN_2016_12);
%claims_rev(source=rif2017.inpatient_claims_01, rev_cohort=rif2017.inpatient_revenue_01, include_cohort=pop_11_IN_2017_1);
%claims_rev(source=rif2017.inpatient_claims_02, rev_cohort=rif2017.inpatient_revenue_02, include_cohort=pop_11_IN_2017_2);
%claims_rev(source=rif2017.inpatient_claims_03, rev_cohort=rif2017.inpatient_revenue_03, include_cohort=pop_11_IN_2017_3);
%claims_rev(source=rif2017.inpatient_claims_04, rev_cohort=rif2017.inpatient_revenue_04, include_cohort=pop_11_IN_2017_4);
%claims_rev(source=rif2017.inpatient_claims_05, rev_cohort=rif2017.inpatient_revenue_05, include_cohort=pop_11_IN_2017_5);
%claims_rev(source=rif2017.inpatient_claims_06, rev_cohort=rif2017.inpatient_revenue_06, include_cohort=pop_11_IN_2017_6);
%claims_rev(source=rif2017.inpatient_claims_07, rev_cohort=rif2017.inpatient_revenue_07, include_cohort=pop_11_IN_2017_7);
%claims_rev(source=rif2017.inpatient_claims_08, rev_cohort=rif2017.inpatient_revenue_08, include_cohort=pop_11_IN_2017_8);
%claims_rev(source=rif2017.inpatient_claims_09, rev_cohort=rif2017.inpatient_revenue_09, include_cohort=pop_11_IN_2017_9);
%claims_rev(source=rif2017.inpatient_claims_10, rev_cohort=rif2017.inpatient_revenue_10, include_cohort=pop_11_IN_2017_10);
%claims_rev(source=rif2017.inpatient_claims_11, rev_cohort=rif2017.inpatient_revenue_11, include_cohort=pop_11_IN_2017_11);
%claims_rev(source=rif2017.inpatient_claims_12, rev_cohort=rif2017.inpatient_revenue_12, include_cohort=pop_11_IN_2017_12);
%claims_rev(source=rifq2018.inpatient_claims_01, rev_cohort=rifq2018.inpatient_revenue_01, include_cohort=pop_11_IN_2018_1);
%claims_rev(source=rifq2018.inpatient_claims_02, rev_cohort=rifq2018.inpatient_revenue_02, include_cohort=pop_11_IN_2018_2);
%claims_rev(source=rifq2018.inpatient_claims_03, rev_cohort=rifq2018.inpatient_revenue_03, include_cohort=pop_11_IN_2018_3);
%claims_rev(source=rifq2018.inpatient_claims_04, rev_cohort=rifq2018.inpatient_revenue_04, include_cohort=pop_11_IN_2018_4);
%claims_rev(source=rifq2018.inpatient_claims_05, rev_cohort=rifq2018.inpatient_revenue_05, include_cohort=pop_11_IN_2018_5);
%claims_rev(source=rifq2018.inpatient_claims_06, rev_cohort=rifq2018.inpatient_revenue_06, include_cohort=pop_11_IN_2018_6);
%claims_rev(source=rifq2018.inpatient_claims_07, rev_cohort=rifq2018.inpatient_revenue_07, include_cohort=pop_11_IN_2018_7);
%claims_rev(source=rifq2018.inpatient_claims_08, rev_cohort=rifq2018.inpatient_revenue_08, include_cohort=pop_11_IN_2018_8);
%claims_rev(source=rifq2018.inpatient_claims_09, rev_cohort=rifq2018.inpatient_revenue_09, include_cohort=pop_11_IN_2018_9);
%claims_rev(source=rifq2018.inpatient_claims_10, rev_cohort=rifq2018.inpatient_revenue_10, include_cohort=pop_11_IN_2018_10);
%claims_rev(source=rifq2018.inpatient_claims_11, rev_cohort=rifq2018.inpatient_revenue_11, include_cohort=pop_11_IN_2018_11);
%claims_rev(source=rifq2018.inpatient_claims_12, rev_cohort=rifq2018.inpatient_revenue_12, include_cohort=pop_11_IN_2018_12);

data pop_11_IN;
set pop_11_IN_2016_1 pop_11_IN_2016_2 pop_11_IN_2016_3 pop_11_IN_2016_4 pop_11_IN_2016_5 pop_11_IN_2016_6
	pop_11_IN_2016_7 pop_11_IN_2016_8 pop_11_IN_2016_9 pop_11_IN_2016_10 pop_11_IN_2016_11 pop_11_IN_2016_12
	pop_11_IN_2017_1 pop_11_IN_2017_2 pop_11_IN_2017_3 pop_11_IN_2017_4 pop_11_IN_2017_5 pop_11_IN_2017_6
	pop_11_IN_2017_7 pop_11_IN_2017_8 pop_11_IN_2017_9 pop_11_IN_2017_10 pop_11_IN_2017_11 pop_11_IN_2017_12
	pop_11_IN_2018_1 pop_11_IN_2018_2 pop_11_IN_2018_3 pop_11_IN_2018_4 pop_11_IN_2018_5 pop_11_IN_2018_6
	pop_11_IN_2018_7 pop_11_IN_2018_8 pop_11_IN_2018_9 pop_11_IN_2018_10 pop_11_IN_2018_11 pop_11_IN_2018_12
;
if &pop_year<2016 then delete;
if &pop_year>2018 then delete;
run;
/* get rid of duplicate rows--keep first occurence so sort by date first */
proc sort data=pop_11_IN; by bene_id &flag_popped_dt; run;
proc sort data=pop_11_IN nodupkey; by bene_id; run;

*look at inpatient info;
proc freq data=pop_11_IN order=freq; 
table  	&flag_popped &pop_year gndr_cd bene_state_cd prvdr_state_cd 
		&pop_OP_PHYSN_SPCLTY_CD &pop_ptnt_dschrg_stus_cd
		&pop_nch_clm_type_cd &pop_CLM_IP_ADMSN_TYPE_CD &pop_clm_fac_type_cd &pop_clm_src_ip_admsn_cd
		&pop_admtg_dgns_cd &pop_icd_dgns_cd1 &pop_clm_drg_cd &pop_hcpcs_cd; 
format bene_state_cd prvdr_state_cd $state. &pop_OP_PHYSN_SPCLTY_CD $speccd. &pop_clm_src_ip_admsn_cd $src1adm.
		&pop_ptnt_dschrg_stus_cd $stuscd.;
run;

proc means data=pop_11_IN n mean median min max; var &flag_popped_dt &pop_age &pop_los; run;
