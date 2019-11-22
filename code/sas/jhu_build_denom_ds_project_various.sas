/********************************************************************
* Job Name: jhu_build_denom_ds_project_various.sas
* Job Desc: Job to identify Medicaid Patients to Use as Denominator
* Copyright: Johns Hopkins University - HutflessLab 2019
********************************************************************
* Longer Desc:
* Create Medicaid Denominator File with demographic information
* to use when calculating rates
********************************************************************/


/*** start of section - global vars ***/
%global lwork ltemp shlib                    ;   /** libname prefix **/
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
%let  pat_id             = bene_id           ;
%let  clm_id             = clm_id            ;

%let    by_var_pat_id    = /*&pat_idm*/ &pat_idb;

%global diag_pfx diag_cd_min diag_cd_max ;
%global plc_of_srvc_cd                   ;
%global ds_all_prefix                    ;
%let  ds_all_prefix      = ;
*%let  ds_all_ip          = /* &lwork..cd_ip_2010_14_all; **/ shu172sl.cd_ip_2010_14_all;
*%let  ds_all_op          = /* &lwork..cd_ot_2010_14_all; **/ shu172sl.cd_ot_2010_14_all;

%let  diag_pfx           = diag_cd_          ;
%let  diag_cd_min        = 1                 ;
%let  diag_cd_max        = 9                 ;
%let  plc_of_srvc_cd     = plc_of_srvc_cd    ;

/*%global main_diag_criteria;
%global cd_diag_criteria;
%global uc_diag_criteria;
%let  main_diag_criteria = '555' '556' 'K50' 'K51'    ;
%let  cd_diag_criteria   = '555' 'K50'                ;
%let  uc_diag_criteria   = '556' 'K51'                ;

%global flag_cd flag_uc;
%let flag_cd             = cd ;
%let flag_uc             = uc ;
*/
%global age;
%global clm_beg_dt clm_end_dt clm_dob clm_pymt_dt;
%global clm_drg ;
%let  age                = age           ;
%let  clm_beg_dt         = srvc_bgn_dt   ;
%let  clm_end_dt         = srvc_end_dt   ;
%let  clm_pymt_dt        = pymt_dt       ;
%let  clm_drg            = clm_drg_cd    ;
%let  clm_dob            = el_dob        ;


    /*** assign let vars to source libs - data ***/
    /*** later this will move to a different   ***/
    /*** dot sas job name and be included      ***/
    %global mps2010 ;
    %global mps2011 ;
    %global mps2012 ;
    %global mps2013 ;
    %global mps2014 ;

    %let mps2010 = max2010.maxdata_ps_2010;
    %let mps2011 = max2011.maxdata_ps_2011;
    %let mps2012 = max2012.maxdata_ps_2012;
    %let mps2013 = max2013.maxdata_ps_2013;
    %let mps2014 = max2014.maxdata_ps_2014;


/*** end of section   - global vars ***/

/*** start of section - OUTPUT DS NAMES ***/
%let outds_cd_2010_2014 = &shlib..ALL_DENOM_2010_14 ;
/*** end of section   - OUTPUT DS NAMES ***/

/*** start of section - local vars remote work ***/
%include "&vrdc_code./remote_dev_work_local.sas";
/*** end of section   - local vars remote work ***/

/*** make sure to run macros in ***/
%include "&vrdc_code./macro_tool_box.sas";
/** these will initiate needed macros for audits **/


*need to link to medicaid enrollment file (shu172.maxdata_ps_2014)
to assess eligibility for medicaid;
*https://www.resdac.org/cms-data/files/max-ps;
*https://support.sas.com/resources/papers/proceedings/proceedings/sugi29/260-29.pdf;
*https://www.lexjansen.com/wuss/2012/103.pdf;
*goal: make 1 file that has 1 record per msis _bene_ id wih the first start and stop date
(for entire period 2010-2014);

/*** START section - PS for Elig ***/
/*** START section - PS for Elig ***/
/*** START section - PS for Elig ***/



%macro year(in=, out=, month=, county=, zip=, ss=, fup=, RENAME=);
data &out
                 (keep=
                       &pat_idm
                       &pat_idb
                       &month
                       el_days_el_cnt:
                       &county
                       &zip
                       &ss
                       &fup
                        el_dob
                        el_race_ethncy_cd
                        el_sex_cd
                        el_dod);
SET
&in   (RENAME=&RENAME)            ;
        &month      =el_elgblty_mo_cnt;
        &county     =el_rsdnc_cnty_cd_ltst;
        &zip        =el_rsdnc_zip_cd_ltst;
        &ss         =el_ss_elgblty_cd_ltst;
        &fup        =el_max_elgblty_cd_ltst;
run;
/* some duplicates (less than 100 per year)
   --no easy way to tell which is the correct row, sorting nodupkey **/

proc sort data=&out nodupkey;
by &pat_idb;
run;

%mend;


%year(in=&mps2010, out=&lwork..ALL_elig2010, month=el_elgblty_mo_cnt2010, county=el_rsdnc_cnty_cd_ltst2010,
                zip=el_rsdnc_zip_cd_ltst2010, ss=el_ss_elgblty_cd_ltst2010, fup=el_max_elgblty_cd_ltst2010,
                RENAME=el_days_el_cnt_1-el_days_el_cnt_12=el_days_el_cnt_1-el_days_el_cnt_12);
%year(in=&mps2011, out=&lwork..ALL_elig2011, month=el_elgblty_mo_cnt2011, county=el_rsdnc_cnty_cd_ltst2011,
                zip=el_rsdnc_zip_cd_ltst2011, ss=el_ss_elgblty_cd_ltst2011, fup=el_max_elgblty_cd_ltst2011,
                RENAME=el_days_el_cnt_1-el_days_el_cnt_12=el_days_el_cnt_13-el_days_el_cnt_24);
%year(in=&mps2012, out=&lwork..ALL_elig2012, month=el_elgblty_mo_cnt2012, county=el_rsdnc_cnty_cd_ltst2012,
                zip=el_rsdnc_zip_cd_ltst2012, ss=el_ss_elgblty_cd_ltst2012, fup=el_max_elgblty_cd_ltst2012,
                RENAME=el_days_el_cnt_1-el_days_el_cnt_12=el_days_el_cnt_25-el_days_el_cnt_36);
%year(in=&mps2013, out=&lwork..ALL_elig2013, month=el_elgblty_mo_cnt2013, county=el_rsdnc_cnty_cd_ltst2013,
                zip=el_rsdnc_zip_cd_ltst2013, ss=el_ss_elgblty_cd_ltst2013, fup=el_max_elgblty_cd_ltst2013,
                RENAME=el_days_el_cnt_1-el_days_el_cnt_12=el_days_el_cnt_37-el_days_el_cnt_48);
%year(in=&mps2014, out=&lwork..ALL_elig2014, month=el_elgblty_mo_cnt2014, county=el_rsdnc_cnty_cd_ltst2014,
                zip=el_rsdnc_zip_cd_ltst2014, ss=el_ss_elgblty_cd_ltst2014, fup=el_max_elgblty_cd_ltst2014,
                RENAME=el_days_el_cnt_1-el_days_el_cnt_12=el_days_el_cnt_49-el_days_el_cnt_60);




data &lwork..ALL_elig_2010_14;
  merge
  &lwork..ALL_elig2010
  &lwork..ALL_elig2011
  &lwork..ALL_elig2012
  &lwork..ALL_elig2013
  &lwork..ALL_elig2014;
  by &pat_idb;
run;

/*** END section - PS for Elig ***/
/*** END section - PS for Elig ***/
/*** END section - PS for Elig ***/





data &lwork..first (drop=n i elig_month_flag done:);
  set
  &lwork..ALL_elig_2010_14
  ;
  array MONTHS (60) el_days_el_cnt_1 - el_days_el_cnt_60;
  do n=1 to 60;
    if MONTHS(n) ge 15 then do;
      elig_month_flag = n;
          label elig_month_flag ='month between jan 2010 and dec 2014 with first eligibility in Medicaid (first month with >=15 days eligible)';
      leave;
    end;
  end;
  if 1  <= elig_month_flag <= 12  then do; start_yr=2010; end;
  if 13 <= elig_month_flag <= 24  then do; start_yr=2011; end;
  if 25 <= elig_month_flag <= 36  then do; start_yr=2012; end;
  if 37 <= elig_month_flag <= 48  then do; start_yr=2013; end;
  if 49 <= elig_month_flag <= 60  then do; start_yr=2014; end;

  if elig_month_flag in(1,13,25,37,49)  then do;  elig_start_dt = mdy(1, 1, start_yr);  end;
  if elig_month_flag in(2,14,26,38,50)  then do;  elig_start_dt = mdy(2, 1, start_yr);  end;
  if elig_month_flag in(3,15,27,39,51)  then do;  elig_start_dt = mdy(3, 1, start_yr);  end;
  if elig_month_flag in(4,16,28,40,52)  then do;  elig_start_dt = mdy(4, 1, start_yr);  end;
  if elig_month_flag in(5,17,29,41,53)  then do;  elig_start_dt = mdy(5, 1, start_yr);  end;
  if elig_month_flag in(6,18,30,42,54)  then do;  elig_start_dt = mdy(6, 1, start_yr);  end;
  if elig_month_flag in(7,19,31,43,55)  then do;  elig_start_dt = mdy(7, 1, start_yr);  end;
  if elig_month_flag in(8,20,32,44,56)  then do;  elig_start_dt = mdy(8, 1, start_yr);  end;
  if elig_month_flag in(9,21,33,45,57)  then do;  elig_start_dt = mdy(9, 1, start_yr);  end;
  if elig_month_flag in(10,22,34,46,58) then do;  elig_start_dt = mdy(10, 1, start_yr); end;
  if elig_month_flag in(11,23,35,47,59) then do;  elig_start_dt = mdy(11, 1, start_yr); end;
  if elig_month_flag in(12,24,36,48,60) then do;  elig_start_dt = mdy(12, 1, start_yr); end;

  format elig_start_dt date9.;
  label elig_start_dt ='first date of Medicaid coverage 2010-2014 (>=15 days in month), date imputed in 1st for all';
  elig_days_10_14 =sum(of el_days_el_cnt_1-el_days_el_cnt_60); label elig_days_10_14='Sum of days eligible Jan2010-Dec2014';
  do i=1 to 60; /* until (done) */
    if i > elig_month_flag and MONTHS(i) < 15 then do;
      if MONTHS(i) < 15 then done1 = 1; else done1 = 0;
          if i >= 2 and MONTHS(i-1) < 15 then done2 =1; else done2 =0;
          if i >= 3 and MONTHS(i-2) < 15 then done3 =1; else done3 =0;
          if done1 =1 and done2 =1 and done3 =1 then elig_end_flag = i-3;
          if done1 + done2 + done3 = 3 then leave;
          label elig_end_flag ='month between jan 2010 and dec 2014 with last eligibility in Medicaid (last month with >=15 days eligible (3 month gap)';
    end;
  end;
  if 1  <= elig_end_flag <= 12  then do; end_yr_dt=2010; end;
  if 13 <= elig_end_flag <= 24  then do; end_yr_dt=2011; end;
  if 25 <= elig_end_flag <= 36  then do; end_yr_dt=2012; end;
  if 37 <= elig_end_flag <= 48  then do; end_yr_dt=2013; end;
  if 49 <= elig_end_flag <= 60  then do; end_yr_dt=2014; end;
  if elig_end_flag in(1,13,25,37,49)  then do;  elig_end_dt = mdy(1,31, end_yr_dt);  end;
  if elig_end_flag in(2,14,26,38,50)  then do;  elig_end_dt = mdy(2,28, end_yr_dt);  end;
  if elig_end_flag in(3,15,27,39,51)  then do;  elig_end_dt = mdy(3,31, end_yr_dt);  end;
  if elig_end_flag in(4,16,28,40,52)  then do;  elig_end_dt = mdy(4,30, end_yr_dt);  end;
  if elig_end_flag in(5,17,29,41,53)  then do;  elig_end_dt = mdy(5,31, end_yr_dt);  end;
  if elig_end_flag in(6,18,30,42,54)  then do;  elig_end_dt = mdy(6,30, end_yr_dt);  end;
  if elig_end_flag in(7,19,31,43,55)  then do;  elig_end_dt = mdy(7,31, end_yr_dt);  end;
  if elig_end_flag in(8,20,32,44,56)  then do;  elig_end_dt = mdy(8,31, end_yr_dt);  end;
  if elig_end_flag in(9,21,33,45,57)  then do;  elig_end_dt = mdy(9,30, end_yr_dt);  end;
  if elig_end_flag in(10,22,34,46,58) then do;  elig_end_dt = mdy(10,31, end_yr_dt); end;
  if elig_end_flag in(11,23,35,47,59) then do;  elig_end_dt = mdy(11,30, end_yr_dt); end;
  if elig_end_flag in(12,24,36,48,60) then do;  elig_end_dt = mdy(12,31, end_yr_dt); end;
  format elig_end_dt  date9.;
  label elig_end_dt ='last date of Medicaid coverage 2010-2014 (>=15 days in month)';
  if elig_start_dt ne . and elig_end_dt=. and elig_days_10_14 ne . then do;
    elig_end_flag = 60;
    elig_end_dt = mdy(12, 31, 2014);
  end;

  /* need to fill in the last available date as the end date */
  if elig_end_dt < elig_start_dt then elig_end_dt = elig_start_dt;
  /* drop those who never have a single month that meets the
     15 day eligibility criteria  (some of them have
     days > 15 but it's spread out over multiple months */
if elig_month_flag =. then delete;
run;


*may want to count total number of encounters for this population
to see how they differ from condition of interest cohort;


/* do data checks here before/after figure out end/flag:  */
/* check what is going on with 0 months eligible          */
/* check if those with tot_mdcd_clm_cnt >= 1 but
   tot_mdcd_ffs_clm_cnt=0 show up in the ot/rx files      */

/*output permanent file---this cohort can be used for all conditions, not just Crohn's*/

data  &outds_cd_2010_2014 (keep = bene_id msis_id elig: fup_medicaid end_yr_dt);
set
&lwork..first
;
fup_medicaid=elig_end_dt-elig_start_dt;
        label fup_medicaid='Total Medicaid Follow-up, Months with at Least 15 days of eligibility & allow 90 day gaps in coverage';
run;

proc means nmiss data= &outds_cd_2010_2014 ;
run;

*exclusions that may want to apply to cohort here or in study specific exclusions;
*if el_dob=. then delete;
*if el_sex_cd notin('M','F') then delete;


/*example code for linking to get disease specific follow-up from ALL MEDICAID follow-up
        this code should be included in the disease-specific file*/

%macro next_section_turned_off();
proc sort data=&outds_cd_2010_2014;
by msis_bene_Id;
run;

proc sort data=shu172sl.asd_cohort_2010_14;
by msis_bene_Id;
run;

*calculate fup---use the medicaid eligibility info instead of first and last asd dates;
*calculate time before first asd code and time from first asd code to end of elgibility;

data      asd_elig (drop= el_days: n max_yr_dt i done: );
  merge
  first (in=a)
  shu172sl.asd_cohort_2010_14 (in=b)
  ;
  by msis_bene_Id;
  if a and b;
  fup_b4_asd=(dt_asd-elig_start_dt)/365.25; label fup_b4_asd='years between first Medicaid eligibility and asd diagnosis';
  format dt_asd elig_start_dt date9.;
  fup_after_asd=(elig_end_dt-dt_asd)/365.25; label fup_after_asd='years between asd diagnosis and last medicaid eligibility (90d gap)';

if yr_first_asd=2010 then do;
        el_rsdnc_cnty_cd_ltst_asd  = el_rsdnc_cnty_cd_ltst2010 ;
        el_rsdnc_zip_cd_ltst_asd   = el_rsdnc_zip_cd_ltst2010  ;
        el_ss_elgblty_cd_ltst_asd  = el_ss_elgblty_cd_ltst2010 ;
        el_max_elgblty_cd_ltst_asd = el_max_elgblty_cd_ltst2010;
end;
if yr_first_asd=2011 then do;
        el_rsdnc_cnty_cd_ltst_asd  = el_rsdnc_cnty_cd_ltst2011 ;
        el_rsdnc_zip_cd_ltst_asd   = el_rsdnc_zip_cd_ltst2011  ;
        el_ss_elgblty_cd_ltst_asd  = el_ss_elgblty_cd_ltst2011 ;
        el_max_elgblty_cd_ltst_asd = el_max_elgblty_cd_ltst2011;
end;
if yr_first_asd=2012 then do;
        el_rsdnc_cnty_cd_ltst_asd  = el_rsdnc_cnty_cd_ltst2012 ;
        el_rsdnc_zip_cd_ltst_asd   = el_rsdnc_zip_cd_ltst2012  ;
        el_ss_elgblty_cd_ltst_asd  = el_ss_elgblty_cd_ltst2012 ;
        el_max_elgblty_cd_ltst_asd = el_max_elgblty_cd_ltst2012;
end;
if yr_first_asd=2013 then do;
        el_rsdnc_cnty_cd_ltst_asd  = el_rsdnc_cnty_cd_ltst2013 ;
        el_rsdnc_zip_cd_ltst_asd   = el_rsdnc_zip_cd_ltst2013  ;
        el_ss_elgblty_cd_ltst_asd  = el_ss_elgblty_cd_ltst2013 ;
        el_max_elgblty_cd_ltst_asd = el_max_elgblty_cd_ltst2013;
end;
if yr_first_asd=2014 then do;
        el_rsdnc_cnty_cd_ltst_asd  = el_rsdnc_cnty_cd_ltst2014 ;
        el_rsdnc_zip_cd_ltst_asd   = el_rsdnc_zip_cd_ltst2014  ;
        el_ss_elgblty_cd_ltst_asd  = el_ss_elgblty_cd_ltst2014 ;
        el_max_elgblty_cd_ltst_asd = el_max_elgblty_cd_ltst2014;
end;
label el_max_elgblty_cd_ltst_asd ='eligibility code for asd using the MAX eligibility indicator';
label el_ss_elgblty_cd_ltst_asd  ='eligibility code for asd using the state specific eligibility indicator';
label el_rsdnc_cnty_cd_ltst_asd  ='county during year of ASD diagnosis';
label el_rsdnc_zip_cd_ltst_asd   ='ZIP during year of ASD diagnosis';
run;

%mend; ** related to: next_section_turned_off();