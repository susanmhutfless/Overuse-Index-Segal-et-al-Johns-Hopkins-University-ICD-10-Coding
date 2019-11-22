/********************************************************************
* Job Name: source_code_for_output_prep_using_table1_logic.sas
* Job Desc: Job to prepare and create tables and figures
* Copyright: Johns Hopkins University - HutflessLab 2019
********************************************************************
* Longer Desc:
*
* Job Dependency Notes: This job runs after
*                       this code will likely NOT be used it
*                       will be used in sections that are useful
*                       put into job
*                       crohns_cohort_prep_logic_for_output.sas
*                       The output from that is needed for this job.
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


/* TABLES AND FIGURES FOR CD PROJECT */

/* create formats */
proc format;
value $race_eth
'0' = "MISSING"
'1' = "WHITE, NOT OF HISPANIC ORIGIN"
'2' = "BLACK, NOT OF HISPANIC ORIGIN"
'3' = "AMERICAN INDIAN OR ALASKAN NATIVE"
'4' = "ASIAN OR PACIFIC ISLANDER"
'5' = "HISPANIC"
'6' = "NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER"
'7' = "HISPANIC OR LATINO AND ONE OR MORE RACES"
'8' = "MORE THAN ONE RACE (HISPANIC OR LATINO NOT INDICATED)"
'9' = "UNKNOWN"
;
run;

proc format;
value $elig
'00' = "NOT ELIGIBLE"
'11' = "AGED, CASH"
'12' = "BLIND/DISABLED, CASH"
'14' = "CHILD (NOT CHILD OF UNEMPLOYED ADULT, NOT FOSTER CARE CHILD), ELIGIBLE UNDER SECTION 1931 OF THE ACT"
'15' = "ADULT (NOT BASED ON UNEMPLOYMENT STATUS), ELIGIBLE UNDER SECTION 1931 OF THE ACT"
'16' = "CHILD OF UNEMPLOYED ADULT, ELIGIBLE UNDER SECTION 1931 OF THE ACT"
'17' = "UNEMPLOYED ADULT, ELIGIBLE UNDER SECTION 1931 OF THE ACT"
'21' = "AGED, Medically Needy"
'22' = "BLIND/DISABLED, Medically Needy"
'24' = "CHILD, Medically Needy (FORMERLY AFDC CHILD, Medically Needy)"
'25' = "ADULT, Medically Needy (FORMERLY AFDC ADULT, Medically Needy)"
'31' = "AGED, POVERTY"
'32' = "BLIND/DISABLED, POVERTY"
'34' = "CHILD, POVERTY (INCLUDES MEDICAID EXPANSION CHIP CHILDREN)"
'35' = "ADULT, POVERTY"
'3A' = "INDIVIDUAL COVERED UNDER THE BREAST AND CERVICAL CANCER PREVENTION ACT OF 2000, POVERTY"
'41' = "OTHER AGED"
'42' = "OTHER BLIND/DISABLED"
'44' = "OTHER CHILD"
'45' = "OTHER ADULT"
'48' = "FOSTER CARE CHILD"
'51' = "AGED, SECTION 1115 DEMONSTRATION EXPANSION"
'52' = "DISABLED, SECTION 1115 DEMONSTRATION EXPANSION"
'54' = "CHILD, SECTION 1115 DEMONSTRATION EXPANSION"
'55' = "ADULT, SECTION 1115 DEMONSTRATION EXPANSION"
'99' = " UNKNOWN ELIGIBILITY";
run;

/* new on 7/31 */

/* can copy below into the tables/figures file instead of here */

data &lwork..cd_2010_14;
set
&shlib..cd_2010_14;
    * cd count criteria;
    * if cd_count < 2 then delete;
    * cd proportion of claims criteria;
    * if cd_prop < 0.5 then delete;
    * last IBD encounter is CD;
    * if cd_last ne 1 then delete;
    * followup criteria;
    if elig_days_10_14 = 0 then delete;

    if elig_end_flag = 0 then delete; *these people had days eligible but never had a relevant month eligible;
run;

/* make table 1 demographics--take into account number of codes and fup */
/* 1 cd count */

proc freq data=&shlib..cd_2010_14 order=freq;
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
  state
  ;
run;

proc means data=&shlib..cd_2010_14 n median min max;
  where cd_count = 1;
  var
  cd_first_age
  cd_prop
  cd_count
  uc_count
  ibd_count
  cd_first_age
  cd_fup
  fup:
  ;
run;

/* at least 2 cd counts */
proc freq data=&shlib..cd_2010_14 order=freq;
  where cd_count >= 2;
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
  state
  ;
run;


proc means data=&shlib..cd_2010_14 n median min max;
  where cd_count >= 2;
  var
  cd_first_age
  cd_prop
  cd_count
  uc_count
  ibd_count
  cd_first_age
  cd_fup
  fup:
  ;
run;

/* at least 1 year without ibd codes and fup_b4_cd is more than 0 */
proc freq data= &lwork..cd_2010_14 order=freq;
  where cd_count >= 2 and fup_b4_cd >= 1 and fup_after_cd >= 0;
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
  state
  ;

run;


proc means data= &lwork..cd_2010_14 n median min max;
  where cd_count >= 2 and fup_b4_cd >= 1 and fup_after_cd >=  0;
  var
  cd_first_age
  cd_prop
  cd_count
  uc_count
  ibd_count
  cd_first_age
  cd_fup
  fup:
  ;
run;

/* at least 1 year before without ibd codes and 1 year followup after */
proc freq data= &lwork..cd_2010_14 order=freq;
  where cd_count >= 2 and fup_b4_cd >= 1 and fup_after_cd >= 1;
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
  state
  ;
run;


proc means data= &lwork..cd_2010_14 n median min max;
  where cd_count >= 2 and fup_b4_cd >= 1 and fup_after_cd >= 1;
  var
  cd_first_age
  cd_prop
  cd_count
  uc_count
  ibd_count
  cd_first_age
  cd_fup
  fup:
  ;
run;


/* END DEMOGRAPHICS SUMMARIES */

/* make a table by state----note wrong dataset and variables--need updates */

ods output crosstabfreqs= &lwork..asd_state_rx (where=(_type_ in('10','11')));

proc sort data=&shlib..asd_infusions_rx_2010_14;
by state_cd;
run;

proc freq data=&shlib..asd_infusions_rx_2010_14 order=freq;
table
state_cd  * (
b12
chela
dmps
oxy
gluta
mela
b12_rx
chela_rx
dmps_rx
oxy_rx
gluta_rx
mela_rx
b12_fin_rx
chela_fin_rx
dmps_fin_rx
oxy_fin_rx
gluta_fin_rx
mela_fin_rx
b12_unfin_rx
chela_unfin_rx
dmps_unfin_rx
oxy_unfin_rx
gluta_unfin_rx
mela_unfin_rx
b12_inf
chela_inf
dmps_inf
oxy_inf
gluta_inf
/*mela_inf*/
b12_inhal_rx
chela_inhal_rx
dmps_inhal_rx
oxy_inhal_rx
gluta_inhal_rx
mela_inhal_rx
b12_inj_rx
chela_inj_rx
dmps_inj_rx
oxy_inj_rx
gluta_inj_rx
mela_inj_rx
b12_powder_rx
chela_powder_rx
dmps_powder_rx
oxy_powder_rx
gluta_powder_rx
mela_powder_rx
b12_sol_rx
chela_sol_rx
dmps_sol_rx
oxy_sol_rx
gluta_sol_rx
mela_sol_rx
b12_crystal_rx
chela_crystal_rx
dmps_crystal_rx
oxy_crystal_rx
gluta_crystal_rx
mela_crystal_rx
);
run;


ODS OUTPUT CLOSE;
/* EXPORT THIS REQUEST OF SUMMARY OF ALL RX: request demographic of national and state data */

data &lwork..asd_freqs_rx (drop = missing colpercent percent _table_ _type_);
set
&lwork..asd_all_rx
&lwork..asd_state_rx
;
if frequency < 11 then delete;
run;

/* gather yearly counts from max_ps files of ALL beneficiaries to set up for rates */
/* we need to figure out how to apply the same exclusion criteria to the "general" population as
   we do to the CD populations, including the different iterations above */


proc sort data=&mps2010 nodupkey out= &lwork..count2010;
by &pat_idb &pat_idm;
run;
proc sort data=&mps2011 nodupkey out= &lwork..count2011;
by &pat_idb &pat_idm;
run;
proc sort data=&mps2012 nodupkey out= &lwork..count2012;
by &pat_idb &pat_idm;
run;
proc sort data=&mps2013 nodupkey out= &lwork..count2013;
by &pat_idb &pat_idm;
run;
proc sort data=&mps2014 nodupkey out= &lwork..count2014;
by &pat_idb &pat_idm;
run;

proc means data= &lwork..count2010 n; var max_yr_dt; run;
proc means data= &lwork..count2011 n; var max_yr_dt; run;
proc means data= &lwork..count2012 n; var max_yr_dt; run;
proc means data= &lwork..count2013 n; var max_yr_dt; run;
proc means data= &lwork..count2014 n; var max_yr_dt; run;


/* gather yearly geographic counts from cd cohort */

proc sql;
  create table  &lwork..cd_state_2010_14 as
  select state,
    sum(case when cd_first_year=2010 then 1 else 0 end) as cd_count2010,
    sum(case when cd_first_year=2011 then 1 else 0 end) as cd_count2011,
    sum(case when cd_first_year=2012 then 1 else 0 end) as cd_count2012,
    sum(case when cd_first_year=2013 then 1 else 0 end) as cd_count2013,
    sum(case when cd_first_year=2014 then 1 else 0 end) as cd_count2014
  from &shlib..cd_2010_14
  group by state;
quit;
run;

%macro cd_geo_cnty(year=);

  proc sql;
    create table  &lwork..cd_cnty&year as
    select el_rsdnc_cnty_cd_ltst&year as el_rsdnc_cnty_cd_ltst,
      sum(case when cd_first_year=&year then 1 else 0 end) as COUNT&year
    from &shlib..cd_2010_14
    group by el_rsdnc_cnty_cd_ltst;
  quit;
  run;

%mend;

%cd_geo_cnty(year=2010);
%cd_geo_cnty(year=2011);
%cd_geo_cnty(year=2012);
%cd_geo_cnty(year=2013);
%cd_geo_cnty(year=2014);


data &lwork..cd_cnty_2010_14;
  merge
   &lwork..cd_cnty2010
   &lwork..cd_cnty2011
   &lwork..cd_cnty2012
   &lwork..cd_cnty2013
   &lwork..cd_cnty2014
  ;
  by el_rsdnc_cnty_cd_ltst;
run;

/* gather yearly geographic sex counts from cd cohort */
proc sql;
  create table  &lwork..cd_state_sex_2010_14 as
  select state,
    sum(case when cd_first_year=2010 and sex='F' then 1 else 0 end) as cd_fem2010,
    sum(case when cd_first_year=2011 and sex='F' then 1 else 0 end) as cd_fem2011,
    sum(case when cd_first_year=2012 and sex='F' then 1 else 0 end) as cd_fem2012,
    sum(case when cd_first_year=2013 and sex='F' then 1 else 0 end) as cd_fem2013,
    sum(case when cd_first_year=2014 and sex='F' then 1 else 0 end) as cd_fem2014
  from &shlib..cd_2010_14
  group by state;
quit;
run;

%macro cd_geo_cnty_sex(year=);

  proc sql;
    create table  &lwork..cd_cnty&year as
    select el_rsdnc_cnty_cd_ltst&year as el_rsdnc_cnty_cd_ltst,
      sum(case when cd_first_year=&year and sex='F' then 1 else 0 end) as COUNT&year
    from &shlib..cd_2010_14
    group by el_rsdnc_cnty_cd_ltst;
  quit;
  run;

%mend;

%cd_geo_cnty_sex(year=2010);
%cd_geo_cnty_sex(year=2011);
%cd_geo_cnty_sex(year=2012);
%cd_geo_cnty_sex(year=2013);
%cd_geo_cnty_sex(year=2014);

data &lwork..cd_cnty_sex_2010_14;
  merge
   &lwork..cd_cnty2010
   &lwork..cd_cnty2011
   &lwork..cd_cnty2012
   &lwork..cd_cnty2013
   &lwork..cd_cnty2014;
  by el_rsdnc_cnty_cd_ltst;
run;


/* gather yearly geographic information from max_ps files */


%macro year_state(year=, file=);

  proc sql;
    create table  &lwork..state_&year as
    select state_cd,
      count(*) as COUNT&year
    from &file
    group by state_cd;
  quit;


%mend;

%year_state(year=2010, file=&mps2010);
%year_state(year=2011, file=&mps2011);
%year_state(year=2012, file=&mps2012);
%year_state(year=2013, file=&mps2013);
%year_state(year=2014, file=&mps2014);


data &shlib..max_state_2010_14;
  merge
   &lwork..state_2010
   &lwork..state_2011
   &lwork..state_2012
   &lwork..state_2013
   &lwork..state_2014
  ;
  by state_cd;
run;

%macro year_cnty(year=, file=);

  proc sql;
    create table  &lwork..cnty_&year as
    select el_rsdnc_cnty_cd_ltst,
      count(*) as COUNT&year
    from &file
    group by el_rsdnc_cnty_cd_ltst;
  quit;
  run;

%mend;

%year_cnty(year=2010, file=&mps2010);
%year_cnty(year=2011, file=&mps2011);
%year_cnty(year=2012, file=&mps2012);
%year_cnty(year=2013, file=&mps2013);
%year_cnty(year=2014, file=&mps2014);

data &shlib..max_cnty_2010_14;
  merge
   &lwork..cnty_2010
   &lwork..cnty_2011
   &lwork..cnty_2012
   &lwork..cnty_2013
   &lwork..cnty_2014
  ;
  by el_rsdnc_cnty_cd_ltst;
run;

/* gather yearly geographic sex information from max_ps files */
%macro year_state_sex(year=, file=);

  proc sql;
    create table  &lwork..sex_&year as
    select state_cd,        /* <= added, as we are grouping by */
      sum(case when el_sex_cd='F' then 1 else 0 end) as FEM&year
    from &file
    group by state_cd;   /*  <--- this part here is important! */
  quit;
  run;

%mend;

%year_state_sex(year=2010, file=&mps2010);
%year_state_sex(year=2011, file=&mps2011);
%year_state_sex(year=2012, file=&mps2012);
%year_state_sex(year=2013, file=&mps2013);
%year_state_sex(year=2014, file=&mps2014);


data &shlib..max_state_sex_2010_14;
  merge
   &lwork..sex_2010
   &lwork..sex_2011
   &lwork..sex_2012
   &lwork..sex_2013
   &lwork..sex_2014
  ;
  by state_cd;
run;

%macro year_cnty_sex(year=, file=);

  proc sql;
    create table  &lwork..cnty_sex_&year as
    select el_rsdnc_cnty_cd_ltst,        /* <= added, as we are grouping by */
      sum(case when el_sex_cd='F' then 1 else 0 end) as FEM&year
    from &file
    group by el_rsdnc_cnty_cd_ltst;   /*  <--- this part here is important! */
  quit;
  run;

%mend;

%year_cnty_sex(year=2010, file=&mps2010);
%year_cnty_sex(year=2011, file=&mps2011);
%year_cnty_sex(year=2012, file=&mps2012);
%year_cnty_sex(year=2013, file=&mps2013);
%year_cnty_sex(year=2014, file=&mps2014);

data &shlib..max_cnty_sex_2010_14;
  merge
   &lwork..cnty_sex_2010
   &lwork..cnty_sex_2011
   &lwork..cnty_sex_2012
   &lwork..cnty_sex_2013
   &lwork..cnty_sex_2014
  ;
  by el_rsdnc_cnty_cd_ltst;
run;


/* merge cd and total counts, calculate rates
   - need to do this for different definitions of cd/general pouplation */

data &shlib..cd_map_state;
  merge
   &lwork..cd_state_2010_14
   &shlib..max_state_2010_14      (rename=(state_cd=state))
   &lwork..cd_state_sex_2010_14
   &shlib..max_state_sex_2010_14  (rename=(state_cd=state));
  by state;
  fips=stfips(state);
  rate_count2010 =(cd_count2010 / count2010)*100;
  rate_count2011 =(cd_count2011 / count2011)*100;
  rate_count2012 =(cd_count2012 / count2012)*100;
  rate_count2013 =(cd_count2013 / count2013)*100;
  rate_count2014 =(cd_count2014 / count2014)*100;
  rate_fem2010   =(cd_fem2010   / fem2010  )*100;
  rate_fem2011   =(cd_fem2011   / fem2011  )*100;
  rate_fem2012   =(cd_fem2012   / fem2012  )*100;
  rate_fem2013   =(cd_fem2013   / fem2013  )*100;
  rate_fem2014   =(cd_fem2014   / fem2014  )*100;
run;

data &shlib..cd_map_cnty;
  merge
   &lwork..cd_cnty_2010_14
   &shlib..max_state_2010_14      (rename=(state_cd=state))
   &lwork..cd_state_sex_2010_14
   &shlib..max_state_sex_2010_14  (rename=(state_cd=state));
  by state;
  *fips=stfips(state); *need to add ssa->fips conversion;
  rate_count2010 =(cd_count2010 / count2010)*100;
  rate_count2011 =(cd_count2011 / count2011)*100;
  rate_count2012 =(cd_count2012 / count2012)*100;
  rate_count2013 =(cd_count2013 / count2013)*100;
  rate_count2014 =(cd_count2014 / count2014)*100;
  rate_fem2010   =(cd_fem2010   / fem2010  )*100;
  rate_fem2011   =(cd_fem2011   / fem2011  )*100;
  rate_fem2012   =(cd_fem2012   / fem2012  )*100;
  rate_fem2013   =(cd_fem2013   / fem2013  )*100;
  rate_fem2014   =(cd_fem2014   / fem2014  )*100;
run;


/* map cd counts by state */
proc sort data= &shlib..cd_2010_14;
by state;
run;

%macro reshape_n(year=);
        data &lwork..cd_states_&year;
            set
            &shlib..cd_2010_14;
            where cd_first_year = &year;
            fips = stfips(state);
        run;

        proc freq data= &lwork..cd_states_&year noprint;
            table state;
        run;

        proc means data= &lwork..cd_states_&year sum noprint;
            class fips;
            var cd_count;
            output out= &lwork..cd_sum_&year;
        run;

        proc sql noprint;
            create table  &lwork..cd_map_&year as
            select fips as state, cd_count from cd_sum_&year where _type_=1 and _stat_='N';
        quit;
%mend;


%macro statemap_n(year=, title=);
        title &title;
        pattern1 v=ms c=cxd6eaff;
        pattern2 v=ms c=cxa0c6ef;
        pattern3 v=ms c=cx6ba3df;
        pattern4 v=ms c=cx357fcf;
        pattern5 v=ms c=cx005cbf;

        proc gmap data= &lwork..cd_map_&year map=mapsgfk.us;
                id state;
                choro cd_count / levels=5; label pct='Count';
        run;
%mend;

%reshape_n(year=2010);
%reshape_n(year=2011);
%reshape_n(year=2012);
%reshape_n(year=2013);
%reshape_n(year=2014);

%statemap_n(year=2010, title='Count of New Medicaid CD 2010, N=57,162');
%statemap_n(year=2011, title='Count of New Medicaid CD 2011, N=36,594');
%statemap_n(year=2012, title='Count of New Medicaid CD 2012, N=34,267');
%statemap_n(year=2013, title='Count of New Medicaid CD 2013, N=23,092');
%statemap_n(year=2014, title='Count of New Medicaid CD 2014, N=14,343');


/* map cd rates by state */
%macro statemap(year=, title=);
        title &title;
        proc sql noprint;
                create table  &lwork..map as
                select fips as state, &var
                from &shlib..cd_map;
        quit;

        pattern1 v=ms c=cxd6eaff;
        pattern2 v=ms c=cxa0c6ef;
        pattern3 v=ms c=cx6ba3df;
        pattern4 v=ms c=cx357fcf;
        pattern5 v=ms c=cx005cbf;

        proc gmap data= &lwork..map map=mapsgfk.us;
                id state;
                choro &var / levels=5; label &var=&label;
        run;
%mend;

%statemap(var=rate_count2010, label='Rate (%)', title='Rate of New Medicaid CD 2010');
%statemap(var=rate_count2011, label='Rate (%)', title='Rate of New Medicaid CD 2011');
%statemap(var=rate_count2012, label='Rate (%)', title='Rate of New Medicaid CD 2012');
%statemap(var=rate_count2013, label='Rate (%)', title='Rate of New Medicaid CD 2013');
%statemap(var=rate_count2014, label='Rate (%)', title='Rate of New Medicaid CD 2014');

%statemap(var=rate_fem2010, label='Rate (%)', title='Rate of New Female Medicaid CD 2010');
%statemap(var=rate_fem2011, label='Rate (%)', title='Rate of New Female Medicaid CD 2011');
%statemap(var=rate_fem2012, label='Rate (%)', title='Rate of New Female Medicaid CD 2012');
%statemap(var=rate_fem2013, label='Rate (%)', title='Rate of New Female Medicaid CD 2013');
%statemap(var=rate_fem2014, label='Rate (%)', title='Rate of New Female Medicaid CD 2014');



/* below may not be needed from a different project */
/* count unique patients per year (per state)       */
proc sql;
   create table  &lwork..new as
     select count(distinct(&pat_idb)) as unique2010,
            from &mps2010;
quit;


/* make map of count of CD cases per state needs denominator file */
/* reshape so 1 record per state                                  */

proc sort data=&shlib..cd_2010_14;
by state;
run;

proc means data=&shlib..cd_2010_14 sum;
  class state;
  var cd_count;
  output out= &lwork..cd_sum;
run;

proc sql noprint;
    create table  &lwork..cd_state as
    select input(state,2.0) as state, cd
    from  &lwork..cd_sum
    where cd_first_year=2010;
quit;


/* map state percentages to us50 map */
title 'Count of New Medicaid CD 2010, N=455,587';
pattern1 v=ms c=cxd6eaff;
pattern2 v=ms c=cxa0c6ef;
pattern3 v=ms c=cx6ba3df;
pattern4 v=ms c=cx357fcf;
pattern5 v=ms c=cx005cbf;

proc gmap data= &lwork..cd_state map=mapsgfk.us;
    id state;
    choro cd_count / levels=5; label asd='Count';
run;

/* make map for percent of ASD patients who used drug in each state */
/* reshape so 1 record per state/county */
%macro reshape(type=);

        proc sort data= &shlib..asd_infusions_rx_2010_14;
        by fipsstate fcounty;
        run;

        proc summary data= &shlib..asd_infusions_rx_2010_14;
        class fipsstate;
        var &type;
        output out= &lwork..cd_state_&type sum=;
        run;

        proc summary data= &shlib..asd_infusions_rx_2010_14;
        class fipsstate fcounty;
        var &type;
        output out= &lwork..cd_county_&type sum=;
        run;

        data &lwork..state_&type (where=(_TYPE_=1));
            set &lwork..cd_state_&type;
            pct=(&type/_FREQ_)*100;
        run;

        data &lwork..county_&type (where=(_TYPE_=3));
            set &lwork..cd_county_&type;
            pct=(&type/_FREQ_)*100;
        run;

        proc sql noprint;
        create table  &lwork..pct_state_&type as
        select input(fipsstate,2.0) as state, pct
        from state_&type where _FREQ_>10;
        *where fipsstate ne '02' and fipsstate ne '15';

        create table  &lwork..pct_county_&type as
        select input(fipsstate,2.0) as state, input(fcounty,3.0) as county, pct
        from  &lwork..county_&type where _FREQ_>10;
        *where fipsstate ne '02' and fipsstate ne '15';
%mend;


/* map state percentages to us50 map */

%macro usstatemap(type=, title=);
        title &title;
        /* data &lwork..us48; set maps.states; if state ne 2 and state ne 15 and state ne 72; run; */
        /* proc gproject data= &lwork..us48 out=us48proj; id state; run; */
        pattern1 v=ms c=cxd6eaff;
        pattern2 v=ms c=cxa0c6ef;
        pattern3 v=ms c=cx6ba3df;
        pattern4 v=ms c=cx357fcf;
        pattern5 v=ms c=cx005cbf;
        proc gmap data= &lwork..pct_state_&type map=mapsgfk.us;
                id state;
                choro pct / levels=5; label pct='Percent';
        run;
%mend;

/* map county percentages to us48 map */
%macro uscountymap(type=, title=);
        title &title;
        data &lwork..us48;
        set maps.counties;
        if state ne 2 and state ne 15 and state ne 72;
        run;

        proc gproject data=&lwork..us48 out=&lwork..us48proj;
        id state;
        run;

        pattern1 v=ms c=cxd6eaff;
        pattern2 v=ms c=cxa0c6ef;
        pattern3 v=ms c=cx6ba3df;
        pattern4 v=ms c=cx357fcf;
        pattern5 v=ms c=cx005cbf;

        proc gmap data=&lwork..pct_county_&type map= &lwork..us48proj all;
            id state county;
            choro pct / levels=5; label pct='Percent';
        run;
%mend;

%reshape(type=b12);
%usstatemap(type=b12, title="Percent of pediatric ASD Medicaid beneficiaries who used B12 (rx or CPT) January 2010 - December 2014");
%uscountymap(type=b12, title="Percent of pediatric ASD Medicaid beneficiaries who used B12 (rx or CPT) January 2010 - December 2014");
%reshape(type=b12_rx);
%usstatemap(type=b12_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled B12 rx (finished or unfinished) January 2010 - December 2014");
%uscountymap(type=b12_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled B12 rx (finished or unfinished) January 2010 - December 2014");
%reshape(type=b12_fin_rx);
%usstatemap(type=b12_fin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled B12 rx (finished only) January 2010 - December 2014");
%uscountymap(type=b12_fin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled B12 rx (finished only) January 2010 - December 2014");
%reshape(type=b12_unfin_rx);
%usstatemap(type=b12_unfin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled B12 rx (unfinished only) January 2010 - December 2014");
%uscountymap(type=b12_unfin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled B12 rx (unfinished only) January 2010 - December 2014");
%reshape(type=b12_inf);
%usstatemap(type=b12_inf, title="Percent of pediatric ASD Medicaid beneficiaries who received B12 in clinic (based on CPT code) January 2010 - December 2014");
%uscountymap(type=b12_inf, title="Percent of pediatric ASD Medicaid beneficiaries who received B12 in clinic (based on CPT code) January 2010 - December 2014");
%reshape(type=b12_inhal_rx);
%usstatemap(type=b12_inhal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled B12 rx (inhalation only) January 2010 - December 2014");
%uscountymap(type=b12_inhal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled B12 rx (inhalation only) January 2010 - December 2014");
%reshape(type=b12_inj_rx);
%usstatemap(type=b12_inj_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled B12 rx (injection only)  January 2010 - December 2014");
%uscountymap(type=b12_inj_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled B12 rx (injection only)  January 2010 - December 2014");
%reshape(type=b12_powder_rx);
%usstatemap(type=b12_powder_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled B12 rx (powder only) January 2010 - December 2014");
%uscountymap(type=b12_powder_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled B12 rx (powder only) January 2010 - December 2014");
%reshape(type=b12_sol_rx);
%usstatemap(type=b12_sol_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled B12 rx (solution only) January 2010 - December 2014");
%uscountymap(type=b12_sol_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled B12 rx (solution only) January 2010 - December 2014");
%reshape(type=b12_crystal_rx);
%usstatemap(type=b12_crystal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled B12 rx (crystal only) January 2010 - December 2014");
%uscountymap(type=b12_crystal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled B12 rx (crystal only) January 2010 - December 2014");

%reshape(type=chela);
%usstatemap(type=chela, title="Percent of pediatric ASD Medicaid beneficiaries who received chelation (rx or CPT) January 2010 - December 2014");
%uscountymap(type=chela, title="Percent of pediatric ASD Medicaid beneficiaries who received chelation (rx or CPT) January 2010 - December 2014");
%reshape(type=chela_rx);
%usstatemap(type=chela_rx, title="Percent of pediatric ASD Medicaid beneficiaries who received chelation rx (finished or unfinished) January 2010 - December 2014");
%uscountymap(type=chela_rx, title="Percent of pediatric ASD Medicaid beneficiaries who received chelation rx (finished or unfinished) January 2010 - December 2014");
%reshape(type=chela_fin_rx);
%usstatemap(type=chela_fin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who received chelation rx (finished only) January 2010 - December 2014");
%uscountymap(type=chela_fin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who received chelation rx (finished only) January 2010 - December 2014");
%reshape(type=chela_unfin_rx);
%usstatemap(type=chela_unfin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who received chelation rx (unfinished only) January 2010 - December 2014");
%uscountymap(type=chela_unfin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who received chelation rx (unfinished only) January 2010 - December 2014");
%reshape(type=chela_inf);
%usstatemap(type=chela_inf, title="Percent of pediatric ASD Medicaid beneficiaries who received chelation in clinic (based on CPT code) January 2010 - December 2014");
%uscountymap(type=chela_inf, title="Percent of pediatric ASD Medicaid beneficiaries who received chelation in clinic (based on CPT code) January 2010 - December 2014");
%reshape(type=b12_inhal_rx);
%usstatemap(type=chela_inhal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled chela rx (inhalation only) January 2010 - December 2014");
%uscountymap(type=chela_inhal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled chelation rx (inhalation only) January 2010 - December 2014");
%reshape(type=chela_inj_rx);
%usstatemap(type=chela_inj_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled chelation rx (injection only)  January 2010 - December 2014");
%uscountymap(type=chela_inj_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled chelation rx (injection only)  January 2010 - December 2014");
%reshape(type=chela_powder_rx);
%usstatemap(type=chela_powder_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled chelation rx (powder only) January 2010 - December 2014");
%uscountymap(type=chela_powder_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled chelation rx (powder only) January 2010 - December 2014");
%reshape(type=chela_sol_rx);
%usstatemap(type=chela_sol_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled chelation rx (solution only) January 2010 - December 2014");
%uscountymap(type=chela_sol_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled chelation rx (solution only) January 2010 - December 2014");
%reshape(type=chela_crystal_rx);
%usstatemap(type=chela_crystal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled chelation rx (crystal only) January 2010 - December 2014");
%uscountymap(type=chela_crystal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled chelation rx (crystal only) January 2010 - December 2014");

%reshape(type=DMPS);
%usstatemap(type=DMPS, title="Percent of pediatric ASD Medicaid beneficiaries who received DMPS (rx or CPT) January 2010 - December 2014");
%uscountymap(type=DMPS, title="Percent of pediatric ASD Medicaid beneficiaries who received DMPS (rx or CPT) January 2010 - December 2014");
%reshape(type=DMPS_rx);
%usstatemap(type=DMPS_rx, title="Percent of pediatric ASD Medicaid beneficiaries who received DMPS rx (finished or unfinished) January 2010 - December 2014");
%uscountymap(type=DMPS_rx, title="Percent of pediatric ASD Medicaid beneficiaries who received DMPS rx (finished or unfinished) January 2010 - December 2014");
%reshape(type=DMPS_fin_rx);
%usstatemap(type=DMPS_fin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who received DMPS rx (finished only) January 2010 - December 2014");
%uscountymap(type=DMPS_fin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who received DMPS rx (finished only) January 2010 - December 2014");
%reshape(type=DMPS_unfin_rx);
%usstatemap(type=DMPS_unfin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who received DMPS rx (unfinished only) January 2010 - December 2014");
%uscountymap(type=DMPS_unfin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who received DMPS rx (unfinished only) January 2010 - December 2014");
%reshape(type=DMPS_inf);
%usstatemap(type=DMPS_inf, title="Percent of pediatric ASD Medicaid beneficiaries who received DMPS in clinic (based on CPT code) January 2010 - December 2014");
%uscountymap(type=DMPS_inf, title="Percent of pediatric ASD Medicaid beneficiaries who received DMPS in clinic (based on CPT code) January 2010 - December 2014");
%reshape(type=DMPS_inhal_rx);
%usstatemap(type=DMPS_inhal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled DMPS rx (inhalation only) January 2010 - December 2014");
%uscountymap(type=DMPS_inhal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled DMPS rx (inhalation only) January 2010 - December 2014");
%reshape(type=DMPS_inj_rx);
%usstatemap(type=DMPS_inj_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled DMPS rx (injection only)  January 2010 - December 2014");
%uscountymap(type=DMPS_inj_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled DMPS rx (injection only)  January 2010 - December 2014");
%reshape(type=DMPS_powder_rx);
%usstatemap(type=DMPS_powder_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled DMPS rx (powder only) January 2010 - December 2014");
%uscountymap(type=DMPS_powder_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled DMPS rx (powder only) January 2010 - December 2014");
%reshape(type=DMPS_sol_rx);
%usstatemap(type=DMPS_sol_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled DMPS rx (solution only) January 2010 - December 2014");
%uscountymap(type=DMPS_sol_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled DMPS rx (solution only) January 2010 - December 2014");
%reshape(type=DMPS_crystal_rx);
%usstatemap(type=DMPS_crystal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled DMPS rx (crystal only) January 2010 - December 2014");
%uscountymap(type=DMPS_crystal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled DMPS rx (crystal only) January 2010 - December 2014");

%reshape(type=oxy);
%usstatemap(type=oxy, title="Percent of pediatric ASD Medicaid beneficiaries who used oxy (rx or CPT) January 2010 - December 2014");
%uscountymap(type=oxy, title="Percent of pediatric ASD Medicaid beneficiaries who used oxy (rx or CPT) January 2010 - December 2014");
%reshape(type=oxy_rx);
%usstatemap(type=oxy_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled oxy rx (finished or unfinished) January 2010 - December 2014");
%uscountymap(type=oxy_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled oxy rx (finished or unfinished) January 2010 - December 2014");
%reshape(type=oxy_fin_rx);
%usstatemap(type=oxy_fin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled oxy rx (finished only) January 2010 - December 2014");
%uscountymap(type=oxy_fin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled oxy rx (finished only) January 2010 - December 2014");
%reshape(type=oxy_unfin_rx);
%usstatemap(type=oxy_unfin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled oxy rx (unfinished only) January 2010 - December 2014");
%uscountymap(type=oxy_unfin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled oxy rx (unfinished only) January 2010 - December 2014");
%reshape(type=oxy_inf);
%usstatemap(type=oxy_inf, title="Percent of pediatric ASD Medicaid beneficiaries who received oxy in clinic (based on CPT code) January 2010 - December 2014");
%uscountymap(type=oxy_inf, title="Percent of pediatric ASD Medicaid beneficiaries who received oxy in clinic (based on CPT code) January 2010 - December 2014");
%reshape(type=oxy_inhal_rx);
%usstatemap(type=oxy_inhal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled oxytocin rx (inhalation only) January 2010 - December 2014");
%uscountymap(type=oxy_inhal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled oxytocin rx (inhalation only) January 2010 - December 2014");
%reshape(type=oxy_inj_rx);
%usstatemap(type=oxy_inj_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled oxytocin rx (injection only)  January 2010 - December 2014");
%uscountymap(type=oxy_inj_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled oxytocin rx (injection only)  January 2010 - December 2014");
%reshape(type=oxy_powder_rx);
%usstatemap(type=oxy_powder_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled oxytocin rx (powder only) January 2010 - December 2014");
%uscountymap(type=oxy_powder_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled oxytocin rx (powder only) January 2010 - December 2014");
%reshape(type=oxy_sol_rx);
%usstatemap(type=oxy_sol_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled oxytocin rx (solution only) January 2010 - December 2014");
%uscountymap(type=oxy_sol_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled oxytocin rx (solution only) January 2010 - December 2014");
%reshape(type=oxy_crystal_rx);
%usstatemap(type=oxy_crystal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled oxytocin rx (crystal only) January 2010 - December 2014");
%uscountymap(type=oxy_crystal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled oxytocin rx (crystal only) January 2010 - December 2014");


%reshape(type=gluta);
%usstatemap(type=gluta, title="Percent of pediatric ASD Medicaid beneficiaries who used gluta (rx or CPT) January 2010 - December 2014");
%uscountymap(type=gluta, title="Percent of pediatric ASD Medicaid beneficiaries who used gluta (rx or CPT) January 2010 - December 2014");
%reshape(type=gluta_rx);
%usstatemap(type=gluta_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled gluta rx (finished or unfinished) January 2010 - December 2014");
%uscountymap(type=gluta_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled gluta rx (finished or unfinished) January 2010 - December 2014");
%reshape(type=gluta_fin_rx);
%usstatemap(type=gluta_fin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled gluta rx (finished only) January 2010 - December 2014");
%uscountymap(type=gluta_fin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled gluta rx (finished only) January 2010 - December 2014");
%reshape(type=gluta_unfin_rx);
%usstatemap(type=gluta_unfin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled gluta rx (unfinished only) January 2010 - December 2014");
%uscountymap(type=gluta_unfin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled gluta rx (unfinished only) January 2010 - December 2014");
%reshape(type=gluta_inf);
%usstatemap(type=gluta_inf, title="Percent of pediatric ASD Medicaid beneficiaries who received gluta in clinic (based on CPT code) January 2010 - December 2014");
%uscountymap(type=gluta_inf, title="Percent of pediatric ASD Medicaid beneficiaries who received gluta in clinic (based on CPT code) January 2010 - December 2014");
%reshape(type=gluta_inhal_rx);
%usstatemap(type=gluta_inhal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled glutathione rx (inhalation only) January 2010 - December 2014");
%uscountymap(type=gluta_inhal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled glutathione rx (inhalation only) January 2010 - December 2014");
%reshape(type=gluta_inj_rx);
%usstatemap(type=gluta_inj_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled glutathione rx (injection only)  January 2010 - December 2014");
%uscountymap(type=gluta_inj_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled glutathione rx (injection only)  January 2010 - December 2014");
%reshape(type=gluta_powder_rx);
%usstatemap(type=gluta_powder_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled glutathione rx (powder only) January 2010 - December 2014");
%uscountymap(type=gluta_powder_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled glutathione rx (powder only) January 2010 - December 2014");
%reshape(type=gluta_sol_rx);
%usstatemap(type=gluta_sol_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled glutathione rx (solution only) January 2010 - December 2014");
%uscountymap(type=gluta_sol_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled glutathione rx (solution only) January 2010 - December 2014");
%reshape(type=gluta_crystal_rx);
%usstatemap(type=gluta_crystal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled glutathione rx (crystal only) January 2010 - December 2014");
%uscountymap(type=gluta_crystal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled glutathione rx (crystal only) January 2010 - December 2014");

%reshape(type=mela);
%usstatemap(type=mela, title="Percent of pediatric ASD Medicaid beneficiaries who used mela (rx or CPT) January 2010 - December 2014");
%uscountymap(type=mela, title="Percent of pediatric ASD Medicaid beneficiaries who used mela (rx or CPT) January 2010 - December 2014");
%reshape(type=mela_rx);
%usstatemap(type=mela_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled mela rx (finished or unfinished) January 2010 - December 2014");
%uscountymap(type=mela_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled mela rx (finished or unfinished) January 2010 - December 2014");
%reshape(type=mela_fin_rx);
%usstatemap(type=mela_fin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled mela rx (finished only) January 2010 - December 2014");
%uscountymap(type=mela_fin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled mela rx (finished only) January 2010 - December 2014");
%reshape(type=mela_unfin_rx);
%usstatemap(type=mela_unfin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled mela rx (unfinished only) January 2010 - December 2014");
%uscountymap(type=mela_unfin_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled mela rx (unfinished only) January 2010 - December 2014");
%reshape(type=mela_inf);
%usstatemap(type=mela_inf, title="Percent of pediatric ASD Medicaid beneficiaries who received mela in clinic (based on CPT code) January 2010 - December 2014");
%uscountymap(type=mela_inf, title="Percent of pediatric ASD Medicaid beneficiaries who received mela in clinic (based on CPT code) January 2010 - December 2014");
%reshape(type=mela_inhal_rx);
%usstatemap(type=mela_inhal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled melatonin rx (inhalation only) January 2010 - December 2014");
%uscountymap(type=mela_inhal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled melatonin rx (inhalation only) January 2010 - December 2014");
%reshape(type=mela_inj_rx);
%usstatemap(type=mela_inj_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled melatonin rx (injection only)  January 2010 - December 2014");
%uscountymap(type=mela_inj_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled melatonin rx (injection only)  January 2010 - December 2014");
%reshape(type=mela_powder_rx);
%usstatemap(type=mela_powder_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled melatonin rx (powder only) January 2010 - December 2014");
%uscountymap(type=mela_powder_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled melatonin rx (powder only) January 2010 - December 2014");
%reshape(type=mela_sol_rx);
%usstatemap(type=mela_sol_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled melatonin rx (solution only) January 2010 - December 2014");
%uscountymap(type=mela_sol_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled melatonin rx (solution only) January 2010 - December 2014");
%reshape(type=mela_crystal_rx);
%usstatemap(type=mela_crystal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled melatonin rx (crystal only) January 2010 - December 2014");
%uscountymap(type=mela_crystal_rx, title="Percent of pediatric ASD Medicaid beneficiaries who filled melatonin rx (crystal only) January 2010 - December 2014");
