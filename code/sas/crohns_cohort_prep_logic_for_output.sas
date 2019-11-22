/********************************************************************
* Job Name: crohns_cohort_prep_logic_for_output.sas
* Job Desc: Job to identify Crohns Medicaid Patients
* Copyright: Johns Hopkins University - HutflessLab 2019
********************************************************************
* Longer Desc:
* Create Crohns Disease Cohort with demographic information
* for the first cd diagnosis only
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
%let outds_cd_2010_2014 = &shlib..cd_2010_14 ;
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


/*** start section - cohort prep and merge of IP OP ***/
/*** start section - cohort prep and merge of IP OP ***/
/*** start section - cohort prep and merge of IP OP ***/


/* merge inpatient and outpatient diagnoses together--then count cd claims **/
data &lwork..cd2;
set
 &ds_all_op
 &ds_all_ip
;
if &pat_idm =' ' and &pat_idb =. then delete;

age_round=round(age);
/* 41k missing age--age at cd dx is the most
   important--delete after have age cd dx variable */

if &clm_beg_dt =. then &clm_beg_dt = &clm_end_dt;
if &clm_end_dt =. then &clm_end_dt = &clm_beg_dt;

/** manually identified those with srvc begn date<2010 and fixing **/
if &clm_beg_dt ='01apr2000'd then &clm_beg_dt ='01apr2010'd;
if &clm_beg_dt ='24oct2002'd then &clm_beg_dt ='24oct2012'd;

if '01jan2009'd <= &clm_beg_dt < '01jan2010'd then &clm_beg_dt = '01jan2010'd;

/* 31 have observations where service begin date and end date is in 2015 */

if &clm_beg_dt >= '01jan2015'd then delete;

/* seems to be more errors in beginning date than end
   date--note that the outpatient errors were fixed
   in the outpatient code above */
if &clm_beg_dt > &clm_end_dt then &clm_beg_dt = &clm_end_dt;

run;

proc print data=&lwork..cd2 (obs=20);
where &clm_beg_dt > &clm_end_dt and &clm_pymt_dt < &clm_end_dt;
var &pat_id &clm_beg_dt &clm_end_dt &clm_pymt_dt;
run;


/* count unique days with cd and  uc (=ulcerative colitis) */
proc sort data=&lwork..cd2 nodupkey;
by &pat_id &clm_beg_dt &flag_cd &flag_uc;
run;

proc sort data=&lwork..cd2;
by &pat_id &clm_beg_dt &flag_cd;
run;

data &lwork..cd (keep = &pat_id cd_count);
set &lwork..cd2;
by &pat_id &clm_beg_dt &flag_cd;
where &flag_cd=1;

/* keeps crohn's disease dx only--doesn't count uc dx */
if first.&pat_id then cd_count=0; cd_count+1;
if last.&pat_id then output;
run;


proc freq data=&lwork..cd ;
table cd_count;
run;

proc sort data=&lwork..cd2;
by &pat_id &clm_beg_dt &flag_uc;
run;

data &lwork..uc (keep = &pat_id uc_count);
set &lwork..cd2;
by &pat_id &clm_beg_dt &flag_uc;
where &flag_uc=1;
if first.&pat_id then uc_count=0; uc_count+1;
if last.&pat_id then output;
run;

proc freq data = &lwork..uc;
table uc_count;
run;

data &lwork..cduc (keep=&pat_id cd_count uc_count cd_prop ibd_count);
merge
&lwork..uc
&lwork..cd
;
by &pat_id;
if cd_count=. then cd_count=0;
if uc_count=. then uc_count=0;
ibd_count=cd_count+uc_count;
cd_prop = cd_count / ibd_count;
run;

proc means data=&lwork..cduc n mean median p25 p75 min max;
var
cd_prop
cd_count
uc_count
ibd_count
;
run;

/* create indicator if their last encounter in IBD dataset was for CD */
proc sort data=&lwork..cduc;
by &pat_id;
run;

proc sort data=&lwork..cd2;
by &pat_id &clm_end_dt;
run;

data &lwork..cd_last
             (keep = &pat_id
                     cd_last_dt
                     cd_last
                     cd_count
                     uc_count
                     cd_prop
                     ibd_count);
merge
&lwork..cduc  (in=a)
&lwork..cd2   (in=b  keep=&pat_id &clm_end_dt &flag_cd);
if a and b;
by &pat_id;
if last.&pat_id;
if &flag_cd=1 then do;
    cd_last=1;
    cd_last_dt = &clm_end_dt;
    end;
if &flag_cd ne 1 then do;
    cd_last=0;
    end;
    label cd_last    ='indicator if last IBD visit was for CD (=1) or UC (=0)';
    label cd_last_dt ='Date of last CD encounter';

    /* require that they have at least 1 encounter
       for CD (=drop those with UC codes only */
if cd_count=0 then delete;
run;



/* create demog info from first visit           */

proc sort data=&lwork..cd2;
by &pat_id &clm_beg_dt;
run;


data &lwork..cd_first
              (keep = &pat_id
                      &pat_idb
                      &pat_idm
                      msis:
                      cd_:
                      state
                      sex
                      race:
                      ethnicity_code
                      el_ss_elgblty_cd:
                      elgblty_cd
                      uc_count
                      cd_count
                      ibd_count
                      cd_prop);
  merge
       &lwork..cd2
           (in=a keep=&pat_id
                      &pat_idb
                      &pat_idm
                      age:
                      yr_num
                      &clm_beg_dt
                      &plc_of_srvc_cd
                      el:
                      msis:
                      race:
                      ethnicity_code
                      state_cd)
       &lwork..cd_last (in=b);
  by &pat_id;
  if a and b;
  if first.&pat_id
    then do;
      cd_first_dt   = &clm_beg_dt;
      cd_first_age  = round(age);  *almost 2k missing;
      cd_first_year = yr_num;
      elgblty_cd    = el_max_elgblty_cd_ltst;
          *https://www.resdac.org/sites/resdac.umn.edu/files/MAX%20Uniform%20Eligibility%20Code%20-%20Most%20Recent%20Table_1.txt;
          *meaning of blind, disabled, cash: https://www.logisticare.com/blog/medicaid-and-the-aged-blind-and-disabled-abd-innovations-help-meet-the-evolving-requirements-of-high-need-low-income-americans;
    end;
  retain cd_first_dt    ;
  retain cd_first_age   ;
  retain cd_first_year  ;
  retain elgblty_cd     ;
  format cd_first_dt   date9.;
  if last.&pat_id
    then do;
      cd_fup=(cd_last_dt - cd_first_dt)/365.25;
    end;
  cd_first_place = &plc_of_srvc_cd;
  *https://www.resdac.org/sites/resdac.umn.edu/files/Place%20of%20Service%20Code%20Table.txt;
  *inpatient=21;
  state = state_cd;
  sex   = el_sex_cd;
  label cd_fup        ='time between last date with a CD code and first date with a CD code in years, no accounting for gaps in coverage';
  label cd_first_dt   ='first date of CD diagnosis in medicaid data, not the incident date';
  label cd_first_age  ='age at first encounter for CD';
  label cd_first_year ='calendar year of first encounter for CD';
  label elgblty_cd    ='eligibility code for Medicaid for first CD encounter from EL_MAX_ELGBLTY_CD_LTST';
  if last.&pat_id then output;
run;
/* only requirement is that they have at least 1 CD code */


data &lwork..cd_cohort;
set &lwork..cd_first;
*delete those missing age and sex;
  if cd_first_age =. then delete;
  if sex notin ('M','F') then delete;
  if cd_first_age <  18 then cd_first_age_lt18 =1;
     else cd_first_age_lt18 =0;  label cd_first_age_lt18 ='Age first CD less than 18 years old';
  if cd_first_age >= 65 then cd_first_age_gt65 =1;
     else cd_first_age_gt65 =0;  label cd_first_age_gt65 ='Age first CD greater than or equal to 65 years old';
run;

/* have at least 1 CD code, info on age at first CD and sex is either male or female */
/* this is the N of the cohort without fup restrictions */


proc means nmiss data=&lwork..cd_cohort;
run;

/* place of service code is missing for some from the OT file */

proc freq data=&lwork..cd_cohort order=freq;
* where cd_count > 1;
  where cd_count = 1;
table
sex
cd_first_year
cd_first_age_lt18
cd_first_age_gt65
race:
ethnicity_code
cd_first_place
elgblty_cd
cd_count
state ;
run;

proc means data=&lwork..cd_cohort n mean median p25 p75 min max;
* where cd_count > 1;
  where cd_count = 1;
var
cd_first_age
cd_prop
cd_count
uc_count
ibd_count
cd_first_age
cd_fup;
run;

*need to link to medicaid enrollment file (shu172.maxdata_ps_2014) to assess eligibility for medicaid;
*https://www.resdac.org/cms-data/files/max-ps;
*https://support.sas.com/resources/papers/proceedings/proceedings/sugi29/260-29.pdf;
*https://www.lexjansen.com/wuss/2012/103.pdf;
*goal: make 1 file that has 1 record per msis _bene_ id wih the first start and stop date (for entire period 2010-2014);

proc sort data=&lwork..cd_cohort;
by &pat_idb &pat_idm ;
run;

/*** END section - cohort prep and merge of IP OP ***/
/*** END section - cohort prep and merge of IP OP ***/
/*** END section - cohort prep and merge of IP OP ***/



/*** START section - PS merge w Cohort for Elig ***/
/*** START section - PS merge w Cohort for Elig ***/
/*** START section - PS merge w Cohort for Elig ***/

data &lwork..cd_elig2010
                 (keep=&pat_id
                       &pat_idm
                       &pat_idb
                       el_elgblty_mo_cnt2010
                       el_days_el_cnt:
                       el_rsdnc_cnty_cd_ltst2010
                       el_rsdnc_zip_cd_ltst2010
                       el_ss_elgblty_cd_ltst2010
                       el_max_elgblty_cd_ltst2010);
  merge
  &lwork..cd_cohort      (in=a)
  &mps2010               (in=b);
  by &pat_idb &pat_idm;
  if a and b;
  el_rsdnc_cnty_cd_ltst2010  =el_rsdnc_cnty_cd_ltst;
  el_rsdnc_zip_cd_ltst2010   =el_rsdnc_zip_cd_ltst;
  el_ss_elgblty_cd_ltst2010  =el_ss_elgblty_cd_ltst;
  el_max_elgblty_cd_ltst2010 =el_max_elgblty_cd_ltst;
  el_elgblty_mo_cnt2010      =el_elgblty_mo_cnt;
run;

data &lwork..cd_elig2011
                 (keep=&pat_id
                       &pat_idm
                       &pat_idb
                       el_elgblty_mo_cnt2011
                       el_days_el_cnt:
                       el_rsdnc_cnty_cd_ltst2011
                       el_rsdnc_zip_cd_ltst2011
                       el_ss_elgblty_cd_ltst2011
                       el_max_elgblty_cd_ltst2011);
  merge
  &lwork..cd_cohort (in=a)
  &mps2011          (in=b rename= el_days_el_cnt_1 - el_days_el_cnt_12=el_days_el_cnt_13-el_days_el_cnt_24);
  by &pat_idb &pat_idm;
  if a and b;
  el_rsdnc_cnty_cd_ltst2011  =el_rsdnc_cnty_cd_ltst;
  el_rsdnc_zip_cd_ltst2011   =el_rsdnc_zip_cd_ltst;
  el_ss_elgblty_cd_ltst2011  =el_ss_elgblty_cd_ltst;
  el_max_elgblty_cd_ltst2011 =el_max_elgblty_cd_ltst;
  el_elgblty_mo_cnt2011      =el_elgblty_mo_cnt;
run;


data &lwork..cd_elig2012
                 (keep=&pat_id
                       &pat_idm
                       &pat_idb
                       el_elgblty_mo_cnt2012
                       el_days_el_cnt:
                       el_rsdnc_cnty_cd_ltst2012
                       el_rsdnc_zip_cd_ltst2012
                       el_ss_elgblty_cd_ltst2012
                       el_max_elgblty_cd_ltst2012);
  merge
  &lwork..cd_cohort (in=a)
  &mps2012          (in=b rename=el_days_el_cnt_1-el_days_el_cnt_12=el_days_el_cnt_25-el_days_el_cnt_36);
  by &pat_idb &pat_idm;
  if a and b;
  el_rsdnc_cnty_cd_ltst2012  =el_rsdnc_cnty_cd_ltst;
  el_rsdnc_zip_cd_ltst2012   =el_rsdnc_zip_cd_ltst;
  el_ss_elgblty_cd_ltst2012  =el_ss_elgblty_cd_ltst;
  el_max_elgblty_cd_ltst2012 =el_max_elgblty_cd_ltst;
  el_elgblty_mo_cnt2012      =el_elgblty_mo_cnt;
run;


data &lwork..cd_elig2013
                 (keep=&pat_id
                       &pat_idm
                       &pat_idb
                       el_elgblty_mo_cnt2013
                       el_days_el_cnt:
                       el_rsdnc_cnty_cd_ltst2013
                       el_rsdnc_zip_cd_ltst2013
                       el_ss_elgblty_cd_ltst2013
                       el_max_elgblty_cd_ltst2013);
  merge
  &lwork..cd_cohort (in=a)
  &mps2013          (in=b rename=el_days_el_cnt_1-el_days_el_cnt_12=el_days_el_cnt_37-el_days_el_cnt_48);
  by &pat_idb &pat_idm;
  if a and b;
  el_rsdnc_cnty_cd_ltst2013  =el_rsdnc_cnty_cd_ltst;
  el_rsdnc_zip_cd_ltst2013   =el_rsdnc_zip_cd_ltst;
  el_ss_elgblty_cd_ltst2013  =el_ss_elgblty_cd_ltst;
  el_max_elgblty_cd_ltst2013 =el_max_elgblty_cd_ltst;
  el_elgblty_mo_cnt2013      =el_elgblty_mo_cnt;
run;


data &lwork..cd_elig2014
                 (keep=&pat_id
                       &pat_idm
                       &pat_idb
                       el_elgblty_mo_cnt2014
                       el_days_el_cnt:
                       el_rsdnc_cnty_cd_ltst2014
                       el_rsdnc_zip_cd_ltst2014
                       el_ss_elgblty_cd_ltst2014
                       el_max_elgblty_cd_ltst2014);
  merge
  &lwork..cd_cohort (in=a)
  &mps2014          (in=b rename=el_days_el_cnt_1-el_days_el_cnt_12=el_days_el_cnt_49-el_days_el_cnt_60);
  by &pat_idb &pat_idm;
  if a and b;
  el_rsdnc_cnty_cd_ltst2014  =el_rsdnc_cnty_cd_ltst;
  el_rsdnc_zip_cd_ltst2014   =el_rsdnc_zip_cd_ltst;
  el_ss_elgblty_cd_ltst2014  =el_ss_elgblty_cd_ltst;
  el_max_elgblty_cd_ltst2014 =el_max_elgblty_cd_ltst;
  el_elgblty_mo_cnt2014      =el_elgblty_mo_cnt;
run;

/* some duplicates (less than 100 per year)
   --no easy way to tell which is the correct row, sorting nodupkey **/

proc sort data=&lwork..cd_elig2010 nodupkey;
by &pat_id;
run;
proc sort data=&lwork..cd_elig2011 nodupkey;
by &pat_id;
run;
proc sort data=&lwork..cd_elig2012 nodupkey;
by &pat_id;
run;
proc sort data=&lwork..cd_elig2013 nodupkey;
by &pat_id;
run;
proc sort data=&lwork..cd_elig2014 nodupkey;
by &pat_id;
run;

data &lwork..cd_elig_2010_14;
  merge
  &lwork..cd_elig2010
  &lwork..cd_elig2011
  &lwork..cd_elig2012
  &lwork..cd_elig2013
  &lwork..cd_elig2014;
  by &pat_id;
run;

/*** END section - PS merge w Cohort for Elig ***/
/*** END section - PS merge w Cohort for Elig ***/
/*** END section - PS merge w Cohort for Elig ***/





data &lwork..first (drop=n i elig_month_flag done:);
  set
  &lwork..cd_elig_2010_14
  ;
  array MONTHS (60) el_days_el_cnt_1 - el_days_el_cnt_60;
  do n=1 to 60;
    if MONTHS(n) ge 15 then do;
      elig_month_flag = n;
          label elig_month_flag ='month between jan 2010 and dec 2014 with first eligibility in Medicaid (first month with >=15 days eligible)';
      leave;
    end;
  end;
  if 1  <= elig_month_flag <= 12  then do; max_yr_dt=2010; end;
  if 13 <= elig_month_flag <= 24  then do; max_yr_dt=2011; end;
  if 25 <= elig_month_flag <= 36  then do; max_yr_dt=2012; end;
  if 37 <= elig_month_flag <= 48  then do; max_yr_dt=2013; end;
  if 49 <= elig_month_flag <= 60  then do; max_yr_dt=2014; end;

  if elig_month_flag in(1,13,25,37,49)  then do;  elig_start_dt = mdy(1, 1, max_yr_dt);  end;
  if elig_month_flag in(2,14,26,38,50)  then do;  elig_start_dt = mdy(2, 1, max_yr_dt);  end;
  if elig_month_flag in(3,15,27,39,51)  then do;  elig_start_dt = mdy(3, 1, max_yr_dt);  end;
  if elig_month_flag in(4,16,28,40,52)  then do;  elig_start_dt = mdy(4, 1, max_yr_dt);  end;
  if elig_month_flag in(5,17,29,41,53)  then do;  elig_start_dt = mdy(5, 1, max_yr_dt);  end;
  if elig_month_flag in(6,18,30,42,54)  then do;  elig_start_dt = mdy(6, 1, max_yr_dt);  end;
  if elig_month_flag in(7,19,31,43,55)  then do;  elig_start_dt = mdy(7, 1, max_yr_dt);  end;
  if elig_month_flag in(8,20,32,44,56)  then do;  elig_start_dt = mdy(8, 1, max_yr_dt);  end;
  if elig_month_flag in(9,21,33,45,57)  then do;  elig_start_dt = mdy(9, 1, max_yr_dt);  end;
  if elig_month_flag in(10,22,34,46,58) then do;  elig_start_dt = mdy(10, 1, max_yr_dt); end;
  if elig_month_flag in(11,23,35,47,59) then do;  elig_start_dt = mdy(11, 1, max_yr_dt); end;
  if elig_month_flag in(12,24,36,48,60) then do;  elig_start_dt = mdy(12, 1, max_yr_dt); end;

  format elig_start_dt date9.;
  label elig_start_dt ='first date of Medicaid coverage 2010-2014 (>=15 days in month), date imputed in 1st for all';
  elig_days_10_14 =sum(of el_days_el_cnt_1-el_days_el_cnt_60); label elig_days_10_14='Sum of days eligible Jan2010-Dec2014 regardless of CD status';
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
  if 1  <= elig_end_flag <= 12  then do; max_yr_dt=2010; end;
  if 13 <= elig_end_flag <= 24  then do; max_yr_dt=2011; end;
  if 25 <= elig_end_flag <= 36  then do; max_yr_dt=2012; end;
  if 37 <= elig_end_flag <= 48  then do; max_yr_dt=2013; end;
  if 49 <= elig_end_flag <= 60  then do; max_yr_dt=2014; end;
  if elig_end_flag in(1,13,25,37,49)  then do;  elig_end_dt = mdy(1,31, max_yr_dt);  end;
  if elig_end_flag in(2,14,26,38,50)  then do;  elig_end_dt = mdy(2,28, max_yr_dt);  end;
  if elig_end_flag in(3,15,27,39,51)  then do;  elig_end_dt = mdy(3,31, max_yr_dt);  end;
  if elig_end_flag in(4,16,28,40,52)  then do;  elig_end_dt = mdy(4,30, max_yr_dt);  end;
  if elig_end_flag in(5,17,29,41,53)  then do;  elig_end_dt = mdy(5,31, max_yr_dt);  end;
  if elig_end_flag in(6,18,30,42,54)  then do;  elig_end_dt = mdy(6,30, max_yr_dt);  end;
  if elig_end_flag in(7,19,31,43,55)  then do;  elig_end_dt = mdy(7,31, max_yr_dt);  end;
  if elig_end_flag in(8,20,32,44,56)  then do;  elig_end_dt = mdy(8,31, max_yr_dt);  end;
  if elig_end_flag in(9,21,33,45,57)  then do;  elig_end_dt = mdy(9,30, max_yr_dt);  end;
  if elig_end_flag in(10,22,34,46,58) then do;  elig_end_dt = mdy(10,31, max_yr_dt); end;
  if elig_end_flag in(11,23,35,47,59) then do;  elig_end_dt = mdy(11,30, max_yr_dt); end;
  if elig_end_flag in(12,24,36,48,60) then do;  elig_end_dt = mdy(12,31, max_yr_dt); end;
  format elig_end_dt  date9.;
  label elig_end_dt ='last date of Medicaid coverage 2010-2014 (>=15 days in month)';
  if elig_start_dt ne . and elig_end_dt=. and elig_days_10_14 ne . then do;
    elig_end_flag = 60; elig_end_dt = mdy(12, 31, 2014); end;
      /* need to fill in the last available date as the end date */
  if elig_end_dt < elig_start_dt then elig_end_dt = elig_start_dt;

  /* drop those who never have a single month that meets the
     15 day eligibility criteria  (some of them have
     days > 15 but it's spread out over multiple months */
if elig_month_flag =. then delete;

run;

/* 174,415 without excluding thos with no
   eligible months based on flag, ~173,972 after exclusion */

/* do data checks here before/after figure out end/flag:  */
/* check what is going on with 0 months eligible          */
/* check if those with tot_mdcd_clm_cnt >= 1 but
   tot_mdcd_ffs_clm_cnt=0 show up in the ot/rx files      */

proc sort data=&lwork..first;
by &pat_id;
run;

proc sort data=&lwork..cd_cohort;
by &pat_id;
run;

/* calculate fup---use the medicaid eligibility */
/* calculate time before first CD code and time
   from first CD code to end of elgibility      */
/* can calculate first and last CD dates too as
   a secondary item to examine                  */

data &lwork..cd_enc_2010_14
                        (drop=el_days:)
                    /*  (keep = &pat_id
                                &pat_idm
                                &pat_idb
                                state_cd
                                el_sex_cd
                                el_race:
                                race:
                                ethnicity_code
                                el:
                                cd:
                                elgblty_cd_cd
                                fup:
                                elig_days_10_14) */
               ;
  merge
  &lwork..first     (in=a)
  &lwork..cd_cohort (in=b)
  ;
  by &pat_id;
  if b; /* keeping those with no followup for sensitivity analyses */

  fup_b4_CD    =(cd_first_dt - elig_start_dt)/365.25; label fup_b4_cd    ='time between first Medicaid eligibility and CD diagnosis';
  fup_after_CD =(elig_end_dt - cd_first_dt  )/365.25; label fup_after_cd ='time between last medicaid eligibility (90d gap) and CD diagnosis';
  /* 444 missing all eligibility info */
  if elig_start_dt=. and elig_end_dt=. then do;
      fup_b4_cd=0; fup_after_cd=0;
  end;
  /* none have elig_start_dt ne . and elig_end_dt =. */
  if cd_first_year = 2010 then do;
        el_rsdnc_cnty_cd_ltst_cd  = el_rsdnc_cnty_cd_ltst2010;
        el_rsdnc_zip_cd_ltst_cd   = el_rsdnc_zip_cd_ltst2010;
        el_ss_elgblty_cd_ltst_cd  = el_ss_elgblty_cd_ltst2010;
        el_max_elgblty_cd_ltst_cd = el_max_elgblty_cd_ltst2010;
  end;
  if cd_first_year = 2011 then do;
        el_rsdnc_cnty_cd_ltst_cd  = el_rsdnc_cnty_cd_ltst2011;
        el_rsdnc_zip_cd_ltst_cd   = el_rsdnc_zip_cd_ltst2011;
        el_ss_elgblty_cd_ltst_cd  = el_ss_elgblty_cd_ltst2011;
        el_max_elgblty_cd_ltst_cd = el_max_elgblty_cd_ltst2011;
  end;
  if cd_first_year = 2012 then do;
        el_rsdnc_cnty_cd_ltst_cd  = el_rsdnc_cnty_cd_ltst2012;
        el_rsdnc_zip_cd_ltst_cd   = el_rsdnc_zip_cd_ltst2012;
        el_ss_elgblty_cd_ltst_cd  = el_ss_elgblty_cd_ltst2012;
        el_max_elgblty_cd_ltst_cd = el_max_elgblty_cd_ltst2012;
  end;
  if cd_first_year = 2013 then do;
        el_rsdnc_cnty_cd_ltst_cd  = el_rsdnc_cnty_cd_ltst2013;
        el_rsdnc_zip_cd_ltst_cd   = el_rsdnc_zip_cd_ltst2013;
        el_ss_elgblty_cd_ltst_cd  = el_ss_elgblty_cd_ltst2013;
        el_max_elgblty_cd_ltst_cd = el_max_elgblty_cd_ltst2013;
  end;
  if cd_first_year = 2014 then do;
        el_rsdnc_cnty_cd_ltst_cd  = el_rsdnc_cnty_cd_ltst2014;
        el_rsdnc_zip_cd_ltst_cd   = el_rsdnc_zip_cd_ltst2014;
        el_ss_elgblty_cd_ltst_cd  = el_ss_elgblty_cd_ltst2014;
        el_max_elgblty_cd_ltst_cd = el_max_elgblty_cd_ltst2014;
  end;
  label el_max_elgblty_cd_ltst_cd='eligibility code for CD using the MAX eligibility indicator';
  label el_ss_elgblty_cd_ltst_cd ='eligibility code for CD using the state specific eligibility indicator';
  label el_rsdnc_cnty_cd_ltst_cd ='county during year of CD diagnosis';
  label el_rsdnc_zip_cd_ltst_cd  ='ZIP during year of CD diagnosis';
run;

/* 179,540---some have  no fup info (if exclude those with no fup after CD get 159,968 */

data  &outds_cd_2010_2014 ;
set &lwork..cd_enc_2010_14;
run;

/* no age restrictions, no number CD encounters restrictions, no fup restrictions */
/* 159,968 if require a fup restriction after CD (do a and b above in enc OR where fup_after_cd>0) */

proc means nmiss data= &outds_cd_2010_2014 ;
run;
/* the data that is missing from numeric variables seems reasonable */
/* This should result in a cohort of individuals with at least
   1 diagnosis code for Crohn's disease & have age and sex */
