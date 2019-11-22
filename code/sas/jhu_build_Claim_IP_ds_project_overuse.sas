/********************************************************************
* Job Name: jhu_build_Claim_IP_ds_project_overuse.sas
* Job Desc: Input for Inpat Claims 
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************/


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
%let  ds_all_ip          =  &lwork..ip_2010_14_all; 
%let  ds_all_op          =  &lwork..ot_2010_14_all; 
%let  ds_all_car         =  &lwork..car_2010_14_all; 

%let  diag_pfx           = diag_cd_          ;
%let  diag_cd_min        = 1                 ;
%let  diag_cd_max        = 25                 ;
%let  plc_of_srvc_cd     = plc_of_srvc_cd    ;

*start;
*Minor difference between thislist and ACOG and CMS measures: ACOG does not include 58200, CMS includes 58956;
%let pop11_drg='734','735','736','737','738','739','740','741';
*did not include ICD codes for hysterectomy-they did not match the DRG list;
*ICD9 codes from CMS https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=2&cad=rja&uact=8&ved=2ahUKEwiSgurrmMTkAhWsneAKHVTxBT0QFjABegQIBBAC&url=https%3A%2F%2Fcmit.cms.gov%2FCMIT_public%2FReportMeasure%3FmeasureRevisionId%3D1823&usg=AOvVaw3r6nZNGU9EO8ndkjN4kxL-:
68.6,
68.61, 68.69, 68.7, 68.71, 68.79, 68.3, 68.31, 68.39, 68.4, 68.41, 68.49, 68.5,
68.51, 68.59, 68.6, 68.61, 68.69, 68.9;

*Popped--malignancy without record of malignancy;
		*DID NOT INCLUDE PLACENTA or "uncertain behavior"--note that DRG lists included placenta, in situ and uncertain behavior ICD dx codes;
%let pop11_icd_EX_dx9_3='179', '180', '182','183', '184';*"malignancy" exlcusion icd-9;
%let pop11_icd_EX_dx9_4='V164','V104';
%let pop11_icd_EX_dx9='1953','1986','19882';
%let pop11_icd_EX_dx10_3='C51','C52','C53','C54','C55','C56','C57'; *"malignancy" exclusion icd-10 based on cross-walk and check of DRG hysterectomy codes for malignancy;
%let pop11_icd_EX_dx10_4='C763','C796','Z804','Z854';*include family history: z80.4 & personal history z85.4;
%let pop11_icd_EX_dx10='C7982';
*did not include DRG exclusion--checked diagnosis codes included in malignancy DRG lists and incorporated those that matched original ICD list;
*stop;
%global main_diag_criteria;
%global cd_diag_criteria;
%global uc_diag_criteria;
%let  main_diag_criteria = '555' '556' 'K50' 'K51'    ;
%let  cd_diag_criteria   = '555' 'K50'                ;
%let  uc_diag_criteria   = '556' 'K51'                ;

%global flag_cd flag_uc;
%let flag_cd             = cd ;
%let flag_uc             = uc ;

%global age;
%global clm_beg_dt clm_end_dt clm_dob clm_pymt_dt;
%global clm_drg ;
%let  age                = age           ;
%let  clm_beg_dt         = srvc_bgn_dt   ;
%let  clm_end_dt         = srvc_end_dt   ;
%let  clm_pymt_dt        = pymt_dt       ;
%let  clm_drg            = clm_drg_cd    ;
%let  clm_dob            = el_dob        ;

/*** end of section   - global vars ***/

/*** start of section - OUTPUT DS NAMES ***/

/*** end of section   - OUTPUT DS NAMES ***/

%let vpath     = /sas/vrdc/users/shu172/files     ;
%let proj_path = /jhu_projects/cd_cohort          ;
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
libname sviews "/sas/vrdc/users/shu172/sviews1";
%let    view_lib = sviews;

libname view_out "/sas/vrdc/users/shu172/sviews1/view_out";
%global def_proj_src_ds_prefix;
%let    def_proj_src_ds_prefix = max;


/*** this section is related to IP - inpatient claims ***/
/*   get inpatient cd diagnoses                         */

%macro create_dsk(view_lib       = ,
                  src_lib_prefix = ,
                  year           = ,
                  prefix         = ,
                  ctype          = );

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
