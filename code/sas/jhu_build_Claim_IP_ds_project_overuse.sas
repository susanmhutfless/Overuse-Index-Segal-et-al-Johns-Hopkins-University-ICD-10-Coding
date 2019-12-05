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


/*Exclusion criteria**/
%let EXCLUD_dx10_3='C53','C54','C55','C56'; 

/**flag for overuse (=popped)*/
%global flag_popped;
%let flag_popped             = popped11 ;

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
%let  clm_dob            = clm_dob        ;

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
libname sviews "/sas/vrdc/users/SHU172SL/sviews1";
%let    view_lib = sviews;

libname view_out "/sas/vrdc/users/SHU172SL/sviews1/view_out";
%global def_proj_src_ds_prefix;
%let    def_proj_src_ds_prefix = max;


/*** this section is related to IP - inpatient claims ***/
/*   get inpatient procedure codes                         */

%macro create_dsk(view_lib       = ,
                  src_lib_prefix = ,
                  year           = ,
                  prefix         = ,
                  ctype          = );
*start;
*First: Identify HCPCS codes for hysterectomy from inpatient, outpatient, carrier;
*denominator for inpatient, outpatient, carrier;
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
b.CLM_IP_ADMSN_TYPE_CD = '3'
AND
b.OP_PHYSN_SPCLTY_CD in('02', '16')
AND
(
	(a.bene_id=b.bene_id and a.clm_id=b.clm_id) 
	or (
		b.icd_prcdr_1 in(&includ_pr10) or
		b.icd_prcdr_2 in(&includ_pr10) or
		b.icd_prcdr_3 in(&includ_pr10) or
		b.icd_prcdr_4 in(&includ_pr10) or
		b.icd_prcdr_5 in(&includ_pr10) or
		b.icd_prcdr_6 in(&includ_pr10) or
		b.icd_prcdr_7 in(&includ_pr10) or
		b.icd_prcdr_8 in(&includ_pr10) or
		b.icd_prcdr_9 in(&includ_pr10) or
		b.icd_prcdr_10 in(&includ_pr10) or
		b.icd_prcdr_11 in(&includ_pr10) or
		b.icd_prcdr_12 in(&includ_pr10) or
		b.icd_prcdr_13 in(&includ_pr10) or
		b.icd_prcdr_14 in(&includ_pr10) or
		b.icd_prcdr_15 in(&includ_pr10) or
		b.icd_prcdr_16 in(&includ_pr10) or
		b.icd_prcdr_17 in(&includ_pr10) or
		b.icd_prcdr_18 in(&includ_pr10) or
		b.icd_prcdr_19 in(&includ_pr10) or
		b.icd_prcdr_20 in(&includ_pr10) or
		b.icd_prcdr_21 in(&includ_pr10) or
		b.icd_prcdr_22 in(&includ_pr10) or
		b.icd_prcdr_23 in(&includ_pr10) or
		b.icd_prcdr_24 in(&includ_pr10) or
		b.icd_prcdr_25 in(&includ_pr10) or
)
;		*check that code still works on outpatient/carrier;
quit;
Data &include_cohort (keep=pop:
		bene_id gndr_cd bene_race_cd bene_cnty_cd bene_state_cd bene_mlg_cntct_zip_cd  
		prvdr_num prvdr_state_cd 
		at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi rfr_physn_npi prf_physn_npi); 
set include_cohort2;   
pop_11_elig_dt=clm_thru_dt;  			label pop_11_elig_dt='date eligible for pop 11';
pop_11_elig=1; 							label pop_11_elig='eligible for pop 11';
pop_11_age=(clm_thru_dt-dob_dt)/365.25; label pop_11_age='age eligible for pop 11';
pop_11_age=round(pop_11_age);
pop_11_year=year(clm_thru_dt);
pop_11_nch_clm_type_cd=nch_clm_type_cd; label pop_11_nch_clm_type_cd='claim/facility type for pop 11 eligibility';
pop_11_los=clm_thru_dt-clm_from_dt;	label pop_11_los='length of stay for pop 11 eligibility';
pop_11_admtg_dgns_cd=put(admtg_dgns_cd,$dgns.);
pop_11_icd_dgns_cd1=put(icd_dgns_cd1,$dgns.);
pop_11_clm_drg_cd=put(clm_drg_cd,$drg.);
pop_11_hcpcs_cd=put(hcpcs_cd,$hcpcs.);
run; 
%mend;
%claims_rev(source=rif2016.inpatient_claims_01, rev_cohort=rif2016.inpatient_revenue_01, include_cohort=pop_11_indenom_2016_1);
*stop;


     data        &view_lib..&prefix.data_&ctype._&year.    /
          view = &view_lib..&prefix.data_&ctype._&year.    ;
          set &src_lib_prefix.&year..&prefix.data_&ctype._&year  (keep= &vars_to_keep_ip_op
                                                                        &vars_to_keep_ip   );
          where substr(&diag_pfx.1,1,3) in ( &main_diag_criteria ) or
                substr(&diag_pfx.2,1,3) in ( &main_diag_criteria ) or
                substr(&diag_pfx.3,1,3) in ( &main_diag_criteria ) or
                substr(&diag_pfx.4,1,3) in ( &main_diag_criteria ) or
                substr(&diag_pfx.5,1,3) in ( &main_diag_criteria ) or
                substr(&diag_pfx.6,1,3) in ( &main_diag_criteria ) or
                substr(&diag_pfx.7,1,3) in ( &main_diag_criteria ) or
                substr(&diag_pfx.8,1,3) in ( &main_diag_criteria ) or
                substr(&diag_pfx.9,1,3) in ( &main_diag_criteria );
                &flag_cd=0;
                &flag_uc=0;
          drop &vars_to_drop_ip ;
     run;
%mend;

     %create_dsk(view_lib       = &view_lib ,
                 src_lib_prefix = &def_proj_src_ds_prefix  ,
                 year           = 2010              ,
                 prefix         = &def_proj_src_ds_prefix  ,
                 ctype          = ip         );

     %create_dsk(view_lib       = &view_lib ,
                 src_lib_prefix = &def_proj_src_ds_prefix  ,
                 year           = 2011              ,
                 prefix         = &def_proj_src_ds_prefix  ,
                 ctype          = ip         );

     %create_dsk(view_lib       = &view_lib ,
                 src_lib_prefix = &def_proj_src_ds_prefix  ,
                 year           = 2012              ,
                 prefix         = &def_proj_src_ds_prefix  ,
                 ctype          = ip         );

     %create_dsk(view_lib       = &view_lib ,
                 src_lib_prefix = &def_proj_src_ds_prefix  ,
                 year           = 2013              ,
                 prefix         = &def_proj_src_ds_prefix  ,
                 ctype          = ip         );

     %create_dsk(view_lib       = &view_lib ,
                 src_lib_prefix = &def_proj_src_ds_prefix  ,
                 year           = 2014              ,
                 prefix         = &def_proj_src_ds_prefix  ,
                 ctype          = ip         );






%macro cdyear(serveryear=, cdyear=);

data &lwork..cd_2;
set
&serveryear ;
age=(&clm_beg_dt - el_dob)/365.25;
if substr(&diag_pfx.1,1,3) in ( &cd_diag_criteria ) or
   substr(&diag_pfx.2,1,3) in ( &cd_diag_criteria ) or
   substr(&diag_pfx.3,1,3) in ( &cd_diag_criteria ) or
   substr(&diag_pfx.4,1,3) in ( &cd_diag_criteria ) or
   substr(&diag_pfx.5,1,3) in ( &cd_diag_criteria ) or
   substr(&diag_pfx.6,1,3) in ( &cd_diag_criteria ) or
   substr(&diag_pfx.7,1,3) in ( &cd_diag_criteria ) or
   substr(&diag_pfx.8,1,3) in ( &cd_diag_criteria ) or
   substr(&diag_pfx.9,1,3) in ( &cd_diag_criteria )
   then do;
   &flag_cd=1;
   end;

if substr(&diag_pfx.1,1,3) in ( &uc_diag_criteria ) or
   substr(&diag_pfx.2,1,3) in ( &uc_diag_criteria ) or
   substr(&diag_pfx.3,1,3) in ( &uc_diag_criteria ) or
   substr(&diag_pfx.4,1,3) in ( &uc_diag_criteria ) or
   substr(&diag_pfx.5,1,3) in ( &uc_diag_criteria ) or
   substr(&diag_pfx.6,1,3) in ( &uc_diag_criteria ) or
   substr(&diag_pfx.7,1,3) in ( &uc_diag_criteria ) or
   substr(&diag_pfx.8,1,3) in ( &uc_diag_criteria ) or
   substr(&diag_pfx.9,1,3) in ( &uc_diag_criteria )
   then do;
   &flag_uc=1;
   end;
run;

proc sort data= &lwork..cd_2 nodupkey
           out= &cdyear;
by &pat_idm &pat_idb &clm_beg_dt &flag_cd &flag_uc;
run;

/* getting dataset of unique cd encounters
   --need to go back to OT file if want
   specific encounters as people have more
   than 1 row per date of service **/

%mend;

%cdyear(serveryear=sviews.maxdata_ip_2010, cdyear= &lwork..cd_ip_2010);
%cdyear(serveryear=sviews.maxdata_ip_2011, cdyear= &lwork..cd_ip_2011);
%cdyear(serveryear=sviews.maxdata_ip_2012, cdyear= &lwork..cd_ip_2012);
%cdyear(serveryear=sviews.maxdata_ip_2013, cdyear= &lwork..cd_ip_2013);
%cdyear(serveryear=sviews.maxdata_ip_2014, cdyear= &lwork..cd_ip_2014);


data  &ds_all_ip;
merge
 &lwork..cd_ip_2010
 &lwork..cd_ip_2011
 &lwork..cd_ip_2012
 &lwork..cd_ip_2013
 &lwork..cd_ip_2014
;
by &pat_idm &pat_idb &clm_beg_dt &flag_cd &flag_uc;

/* make a unique identifier that is a combo of msis & bene ids */
&pat_id = catx(' || ', &pat_idm, &pat_idb); label &pat_id='identifier for msis (state) &  bene (ccw) ids';
&plc_of_srvc_cd = 21;  /* 21=inpatient hospital */

run;

proc freq data= &ds_all_ip;
table &plc_of_srvc_cd;
run;
