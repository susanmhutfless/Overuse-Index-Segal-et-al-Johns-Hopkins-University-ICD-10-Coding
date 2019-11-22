/********************************************************************
* Job Name: jhu_build_Claim_OP_ds_project_crohns.sas
* Job Desc: Input for Outpat Claims for Step1 Job
* Copyright: Johns Hopkins University - HutflessLab 2019
********************************************************************/


/*** start of section - global vars ***/
%global lwork ltemp shlib                    ;
%global pat_idb clm_id                       ;
%global pat_idm                              ;
%global pat_id                               ;
%global by_var_pat_id                        ;

/*** libname prefix alias assignments ***/
%let  lwork              = work              ;
%let  ltemp              = temp              ;
%let  shlib              = shu172sl          ;

%let  pat_idb            = bene_id           ;
%let  pat_idm            = msis_id           ;
%let  pat_id             = msis_bene_id      ;
%let  clm_id             = clm_id            ;

%let    by_var_pat_id    = &pat_idm &pat_idb;

%global diag_pfx diag_cd_min diag_cd_max ;
%global plc_of_srvc_cd                   ;
%global ds_all_prefix                    ;
%let  ds_all_prefix      = ;
%let  ds_all_ip          = /* &lwork..cd_ip_2010_14_all; **/ shu172sl.cd_ip_2010_14_all;
%let  ds_all_op          = /* &lwork..cd_ot_2010_14_all; **/ shu172sl.cd_ot_2010_14_all;

%let  diag_pfx           = diag_cd_          ;
%let  diag_cd_min        = 1                 ;
%let  diag_cd_max        = 9                 ;
%let  plc_of_srvc_cd     = plc_of_srvc_cd    ;

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



/*** this section is related to OP - outpatient claims ***/

/*** end result view creation by state, year ***/
%macro create_dsk(view_lib       = ,
                  src_lib_prefix = ,
                  year           = ,
                  prefix         = ,
                  state          = ,
                  ctype          = );

     data        &view_lib..&prefix.data_&ctype.&state._&year.    /
          view = &view_lib..&prefix.data_&ctype.&state._&year.    ;
          set &src_lib_prefix.&year..&prefix.data&state._&ctype._&year  (keep= &vars_to_keep_ip_op ) ;
         where substr(&diag_pfx.1,1,3) in : ( &main_diag_criteria )
            or substr(&diag_pfx.2,1,3) in : ( &main_diag_criteria );
         &age=( &clm_beg_dt - &clm_dob )/365.25;
         if substr(&diag_pfx.1,1,3) in(&cd_diag_criteria) or substr(&diag_pfx.2,1,3) in(&cd_diag_criteria) then do;
             &flag_cd=1;
         end;
         if substr(&diag_pfx.1,1,3) in(&uc_diag_criteria) or substr(&diag_pfx.2,1,3) in(&uc_diag_criteria) then do;
             &flag_uc=1;
         end;
         drop &vars_to_drop_op ;
     run;

%mend;


/*** macro that calls views - runs by year and state loops ***/
%macro make_views_dsk(y_list     =,
                      m_list     =,
                      ctype      = );
     %let year_idx=1;
     %let year_to_do= %scan(&y_list        ,  &year_idx);
     %do %while (&year_to_do   ne);

         %let st_idx=1;
         %let st_to_do=%scan( &m_list  , &st_idx);
             %do %while ( &st_to_do   ne);

                     %create_dsk(view_lib      = &view_lib                ,
                                 src_lib_prefix= &def_proj_src_ds_prefix  ,
                                 year          = &year_to_do              ,
                                 prefix        = &def_proj_src_ds_prefix  ,
                                 state         = &st_to_do                ,
                                 ctype         = &ctype         );

                 %let st_idx   = %eval( &st_idx + 1);
                 %let st_to_do = %scan( &m_list , &st_idx );
             %end;
         %let year_idx   = %eval( &year_idx + 1 );
         %let year_to_do = %scan( &y_list, &year_idx );
     %end;
%mend;


/*** overall driver macro that allows us to configure which year and state to spin thru ***/
/*** this macro also does a clean up first by removing and deleting pre existing views  ***/
/*** its important to NEVER mix up project views in view folders to ensure safety       ***/
/*** its also important to never mix real sas data with sas views in this type of method***/

%macro build_views(file_name_prefix = ,
                   file_type_code   = ,
                   out_ds_combo     = );
     proc datasets lib= &view_lib noprint ;
         delete  &file_name_prefix.&file_type_code._:   (memtype = view);
         delete  &out_ds_combo.&file_type_code          (memtype = view);
     quit;
     run;

      /*** here we custom configure which year, state we want to spin thru   ***/
      /*** note for each state the _ prefix - this is due to how macro       ***/
      /*** interprets the state of oregon 'o r' as actual syntax and falters ***/
      /*** the underscore prefix quickly solves that but i'll find a better  ***/
      /*** solution later ***/
      %make_views_dsk(y_list= 2010      2012 2013 2014 , m_list= _id                  , ctype= ot );
      %make_views_dsk(y_list= 2010 2011 2012 2013      , m_list= _ar _az _ct _hi _in
                                                                 _ma _ny _oh _ok _or
                                                                 _wa                  , ctype= ot );
      %make_views_dsk(y_list= 2010 2011 2012 2013 2014 , m_list= _ca _ga _ia _la _mi
                                                                 _mn _mo _ms _nj _pa
                                                                 _sd _tn _ut _vt _wv
                                                                 _wy                  , ctype= ot );
      %make_views_dsk(y_list= 2010 2011 2012           , m_list= _ak _al _co _dc _de
                                                                 _fl _il     _ky _md
                                                                     _mt _nc _nd _ne
                                                                 _nh _nm _nv _ri _sc
                                                                 _tx _va _wi          , ctype= ot );
      %make_views_dsk(y_list=      2011 2012           , m_list= _ks _me
                                                                                      , ctype= ot );


     /*** here we combine all the individual "views" into a single bigger "view" ***/
     data        &view_lib..&out_ds_combo.&file_type_code   /
          view = &view_lib..&out_ds_combo.&file_type_code   ;
          merge viewout.maxdata_ot: ;
     run;

%mend;

%build_views(file_name_prefix = maxdata_  , file_type_code= ch , out_ds_combo= maxds_ot_   );


/*** here we take the final single view and actually initiate - pull the data from the views ***/
/*** into a single real sas dataset that we can then work with ***/

data &ds_all_op;
    set sviews.maxds_ot_ch
        ;

/* 2 have negative fup dates--both hospitalizated
   and say discharge date before admit date--change
   discharge date to admit date **/

if &clm_end_dt < &clm_beg_dt then do;
   &clm_end_dt = &clm_beg_dt;
end;

/* make a unique identifier that is a combo of msis & bene ids **/
&pat_id = catx(' || ', &pat_idm, &pat_idb); label &pat_id='identifier for msis (state) &  bene (ccw) ids';

run;

