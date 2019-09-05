libname ccw 'D:\Overuse'; 

data ccw.kitty_bene_summary; set ccw.kitty_bene_summary;
length women_75 women_80 men_75 men_all women_all all_85 3 zip_code $ 5; women_75=0; women_80=0; men_75=0; men_all=0; women_all=0; all_85=0;
if BENE_SEX_IDENT_CD="2" and BENE_AGE_AT_END_REF_YR>=75 then women_75=1;
if BENE_SEX_IDENT_CD="2" and BENE_AGE_AT_END_REF_YR>=80 then women_80=1;
if BENE_SEX_IDENT_CD="1" and BENE_AGE_AT_END_REF_YR>=75 then men_75=1;
if BENE_SEX_IDENT_CD="2" then women_all=1;
if BENE_SEX_IDENT_CD="1" then men_all=1;
if BENE_AGE_AT_END_REF_YR>=85 then all_85=1;
zip_code=substr(BENE_ZIP_CD, 1, 5);
run;
proc freq; table  women_75 women_80 men_75 men_all women_all all_85; run;
/* proc freq; table BENE_ZIP_CD; run; proc freq; table zip_code; run;
proc freq data=ccw.kitty_bene_summary; table BENE_VALID_DEATH_DT_SW; where BENE_VALID_DEATH_DT_SW="V"; run; */

data ccw.beneficiary_death; set ccw.beneficiary_death;
length women_75 women_80 men_75 men_all women_all all_85 3 zip_code $ 5; women_75=0; women_80=0; men_75=0; men_all=0; women_all=0; all_85=0;
if BENE_SEX_IDENT_CD="2" and BENE_AGE_AT_END_REF_YR>=75 then women_75=1;
if BENE_SEX_IDENT_CD="2" and BENE_AGE_AT_END_REF_YR>=80 then women_80=1;
if BENE_SEX_IDENT_CD="1" and BENE_AGE_AT_END_REF_YR>=75 then men_75=1;
if BENE_SEX_IDENT_CD="2" then women_all=1;
if BENE_SEX_IDENT_CD="1" then men_all=1;
if BENE_AGE_AT_END_REF_YR>=85 then all_85=1;
zip_code=substr(BENE_ZIP_CD, 1, 5);
run;
proc freq; table  women_75 women_80 men_75 men_all women_all all_85; run;
/* proc freq; table BENE_ZIP_CD; run; proc freq; table zip_code; run; */

data ccw.kitty_beneficiary_summary_file; set ccw.kitty_bene_summary ccw.beneficiary_death; run;
proc sort nodupkey; by bene_id; run;

proc freq; table BENE_SEX_IDENT_CD BENE_RACE_CD BENE_MDCR_STATUS_CD region BENE_VALID_DEATH_DT_SW / missing; run;
proc means; var BENE_AGE_AT_END_REF_YR; run;



/***  Pop 01   ***/
 /* Denominator - Individuals with a code for emergency visit* with any of the ICD-9 diagnoses OR individuals with a hospitalization with DRGs as listed, or primary or secondary diagnosis code during hospitalization for any of the ICD-9 diagnoses*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where er_visit=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
Data er_visit; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; keep type clm_id bene_id; run;
Data a_er_pos; set ccw.kitty_op_claims_er ccw.kitty_bcarrier_claims_er ccw.kitty_op_claims_er_death ccw.kitty_bcarrier_claims_er_death; where ER_pos=1; keep type clm_id bene_id; run; 
Data er_visit; set er_visit a_er_pos; run;
proc sort nodupkey; by type clm_id bene_id; run;
 
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where acs=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data a; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
proc sort nodupkey; by type clm_id bene_id; run;

Data b; merge a (in=a) er_visit (in=b); by type clm_id bene_id; if a=1 and b=1; keep type clm_id bene_id date_service; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where acs_drg=1; run;
%Mend type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data a; set a_icd_MedPAR a_icd_MedPAR_death; keep type clm_id bene_id date_service; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where acs_angina_ip_12=1; run;
%Mend type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data c; set a_icd_MedPAR a_icd_MedPAR_death; keep type clm_id bene_id date_service; run;

Data ccw.pop_01_de; set a b c; run;
proc sort nodupkey; by bene_id date_service; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_01_de; merge ccw.pop_01_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 
proc means Data=ccw.pop_01_de; var n_de; run;

Data a; set ccw.pop_01_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_01_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_01_de_zip; by HRR; run;
proc summary Data=ccw.pop_01_de_zip; by HRR;
output out=ccw.pop_01_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_01_de_hrr; set ccw.pop_01_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - Individuals with CPT codes as listed or HCPCS codes as listed for echocardiography */
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where stress_echocardiography=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data ccw.pop_01_nu; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort nodupkey; by bene_id date_service; run;
Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data b; set ccw.pop_01_de; keep bene_id; run; 
proc sort nodupkey; by bene_id; run;
Data ccw.pop_01_nu; merge ccw.pop_01_nu (in=a) b (in=b) a; by bene_id; if a=1 and b=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_01_nu_zip; merge ccw.pop_01_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_01_nu_zip; by HRR; run;
proc summary Data=ccw.pop_01_nu_zip; by HRR;
output out=ccw.pop_01_nu_hrr sum(stress_echocardiography)=n_nu; run;

Data ccw.pop_01_nu_hrr; set ccw.pop_01_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_01_hrr; merge ccw.pop_01_nu_hrr ccw.pop_01_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means data=ccw.pop_01_hrr; var n_nu n_de rate; where hrr ne ""; run;




/***  Pop 02   ***/
 /* Denominator – Individuals with a code for emergency visit with any of the ICD-9 diagnoses OR individuals with a hospitalization with DRGs as listed, or primary or secondary diagnosis code during hospitalization for any of the ICD-9 diagnoses*, AND a code for cardiac rehabilitation following that index hospitalization (within 2 months)*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where er_visit=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
Data er_visit; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; keep type clm_id bene_id; run;
Data a_er_pos; set ccw.kitty_op_claims_er ccw.kitty_bcarrier_claims_er ccw.kitty_op_claims_er_death ccw.kitty_bcarrier_claims_er_death; where ER_pos=1; keep type clm_id bene_id; run; 
Data er_visit; set er_visit a_er_pos; run;
proc sort nodupkey; by type clm_id bene_id; run;
 
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where acs=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data a; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
proc sort nodupkey; by type clm_id bene_id; run;

Data b; merge a (in=a) er_visit (in=b); by type clm_id bene_id; if a=1 and b=1; keep bene_id date_service; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where acs_drg=1; run;
%Mend type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data a; set a_icd_MedPAR a_icd_MedPAR_death; keep bene_id date_service; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where acs_angina_ip_12=1; run;
%Mend type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data c; set a_icd_MedPAR a_icd_MedPAR_death; keep bene_id date_service; run;
Data c; set a b c; run;
proc sort; by bene_id; run;

%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where cardiac_rehab=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
Data d; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; rename date_service=date_service_cardiac; run;
proc sort; by bene_id; run;

***  many-to-many merge  ***;
proc sql; create table e as  select *  from c c, d d  where c.bene_id=d.bene_id; quit;

Data e; set e; where date_service_cardiac<=date_service+61 and date_service_cardiac>=date_service; run; 
proc sort nodupkey; by bene_id date_service date_service_cardiac; run;
Data f; set e; by bene_id date_service date_service_cardiac; if first.date_service=1; run;

Data ccw.pop_02_de; set f; run;
Data ccw.pop_02_de; set ccw.pop_02_de; keep date_service bene_id clm_id type date_service_cardiac; run;
proc sort nodupkey; by bene_id date_service date_service_cardiac; run;

proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_02_de; merge ccw.pop_02_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_02_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_02_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_02_de_zip; by HRR; run;
proc summary Data=ccw.pop_02_de_zip; by HRR;
output out=ccw.pop_02_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_02_de_hrr; set ccw.pop_02_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - Stress echocardiogram DURING OR AFTER the ACS service date and BEFORE the first code for cardiac rehabilitation*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where stress_echocardiography=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data c; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;

Data d; set ccw.pop_02_de; rename date_service=date_service_acs; run;
Data d; set d; keep bene_id date_service_cardiac date_service_acs; run;
  ***  many-to-many merge  ***;
  ***  identify eligible unique type+clm_id+bene_id+date_service observations  ***;
  ***  eligible means date requirements are satisfied  ***;
proc sql; create table e as  select *  from c c, d d  where c.bene_id=d.bene_id; quit;

Data ccw.pop_02_nu; set e; where date_service<date_service_cardiac and date_service>=date_service_acs; run;
proc sort nodupkey; by bene_id date_service; run;

Data b; set ccw.kitty_beneficiary_summary_file;	keep zip_code bene_id; run;
proc sort nodupkey; by bene_id; run;

Data a; merge ccw.pop_02_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_02_nu_zip; merge a (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_02_nu_zip; by HRR; run;
proc summary Data=ccw.pop_02_nu_zip; by HRR; output out=ccw.pop_02_nu_hrr sum(stress_echocardiography)=n_nu; run;

Data ccw.pop_02_nu_hrr; set ccw.pop_02_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_02_hrr; merge ccw.pop_02_nu_hrr ccw.pop_02_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; where hrr ne ""; run;



/***  Pop 03   ***/
 /* Denominator - Individuals with a code for revascularization procedures AND a code for cardiac rehabilitation following revascularization procedure*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where revascularization_proc=1; run;
Data a_proc_&type; set a_proc_&type; rename revascularization_proc=revascularization; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where revascularization=1; run;
%Mend type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
%Macro type;
Data a_&type; set ccw.kitty_&type; where revascularization=1; run;
%Mend type; %let type=icdproc_outpatient; %type; %let type=proc_MedPAR; %type; %let type=icdproc_outpatient_death; %type; %let type=proc_MedPAR_death; %type;
Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death a_icd_MedPAR a_icd_MedPAR_death a_icdproc_outpatient a_proc_MedPAR a_icdproc_outpatient_death a_proc_MedPAR_death;
keep revascularization bene_id date_service; run;

%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where cardiac_rehab=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
Data b; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; keep cardiac_rehab bene_id date_service; run;
Data b; set b; rename date_service=date_service_cardiac; run; 

***  many-to-many merge  ***;
proc sql; create table c as  select *  from a a, b b  where a.bene_id=b.bene_id; quit;

Data c; set c; where date_service<date_service_cardiac; run; 
proc sort nodupkey; by bene_id date_service date_service_cardiac; run;
Data ccw.pop_03_de; set c; by bene_id date_service date_service_cardiac; if first.date_service=1; run;
proc sort nodupkey; by bene_id date_service date_service_cardiac; run;

proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_03_de; merge ccw.pop_03_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 
proc means; var n_de; run;

Data a; set ccw.pop_03_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_03_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_03_de_zip; by HRR; run;
proc summary Data=ccw.pop_03_de_zip; by HRR;
output out=ccw.pop_03_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_03_de_hrr; set ccw.pop_03_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

  /* Numerator - Stress echocardiogram DURING OR AFTER the revascularization service date and BEFORE the first  code for cardiac rehabilitation*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where stress_echocardiography=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data c; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run; 
proc contents; run;
Data c; set c; keep type clm_id bene_id stress_echocardiography date_service; run;

Data d; set ccw.pop_03_de; rename date_service=date_service_revascularization; run;
Data d; set d; keep bene_id date_service_cardiac date_service_revascularization; run;


  ***  many-to-many merge  ***;
  ***  identify eligible unique type+clm_id+bene_id+date_service observations  ***;
  ***  eligible means date requirements are satisfied  ***;
proc sql; create table e as  select *  from c c, d d  where c.bene_id=d.bene_id; quit;
Data ccw.pop_03_nu; set e; where date_service<date_service_cardiac and date_service>=date_service_revascularization; run;
proc sort nodupkey; by bene_id date_service; run;

Data b; set ccw.kitty_beneficiary_summary_file;	keep zip_code bene_id; run;
proc sort nodupkey; by bene_id; run;

Data a; merge ccw.pop_03_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_03_nu_zip; merge a (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_03_nu_zip; by HRR; run;
proc summary Data=ccw.pop_03_nu_zip; by HRR; output out=ccw.pop_03_nu_hrr sum(stress_echocardiography)=n_nu; run;

Data ccw.pop_03_nu_hrr; set ccw.pop_03_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_03_hrr; merge ccw.pop_03_nu_hrr ccw.pop_03_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; where hrr ne ""; run;




/*** Pop 05   No One has Cardiac CT   
Denominator - Individuals with cardiac CT AND NO CAD diagnosis AND no ACS angina diagnosis AND no revascularization in the following 12 months
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where cardiac_ct=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; keep cardiac_ct bene_id date_service; run;
proc sort; by bene_id date_service; run; Data b; set a; by bene_id date_service; if first.bene_id=1; rename date_service=date_service_cardiac; run; 

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where cad=1 or acs_angina=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data c; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; keep cad acs_angina bene_id date_service; run;
proc freq; table cad acs_angina; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where cad=1 or acs_angina=1 or revascularization=1; run;
%Mend type; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data d; set a_icd_MedPAR a_icd_MedPAR_death; keep cad acs_angina revascularization bene_id date_service; run;
proc freq; table cad acs_angina revascularization; run;

%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where revascularization_proc=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
Data e; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; keep revascularization_proc bene_id date_service; run;
proc freq; table revascularization_proc; run;

%Macro type;
Data a_&type; set ccw.kitty_&type; where revascularization=1; run;
%Mend type; %let type=icdproc_outpatient; %type; %let type=proc_MedPAR; %type; %let type=icdproc_outpatient_death; %type; %let type=proc_MedPAR_death; %type;
Data f; set a_icdproc_outpatient a_proc_MedPAR a_icdproc_outpatient_death a_proc_MedPAR_death; keep revascularization bene_id date_service; run;
proc freq; table revascularization; run;

Data g; set c d e f; run;
proc sort; by bene_id date_service; run; 
Data h; set g; by bene_id date_service; if last.bene_id=1; run; 

Data i; merge h (in=a) b (in=b); by bene_id; if b=1; run;
Data ccw.pop_05_de; set h; if date_service ne . and date_service>=date_service_cardiac then delete; run;
***/



/***  Pop 07   ***/
 /* Denominator - Neoplasm of heart*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where heart_neoplasm=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data ccw.pop_07_de_claim; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
Data ccw.pop_07_de; set ccw.pop_07_de_claim; run; 
proc sort nodupkey; by bene_id date_service; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_07_de; merge ccw.pop_07_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_07_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_07_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_07_de_zip; by HRR; run;
proc summary Data=ccw.pop_07_de_zip; by HRR;
output out=ccw.pop_07_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_07_de_hrr; set ccw.pop_07_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - Myocardial perfusion study concurrent with code for neoplasm (within 2 weeks) AND ABSENCE of code for echocardiogram in the 3 months preceding myocardial perfusion study*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where myocardial_perfusion=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data c; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; rename date_service=date_service_myo; run;
proc sort; by bene_id; run;

%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where echocardiogram=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data d; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; rename date_service=date_service_echo; run;

Data e; set ccw.pop_07_de; rename date_service=date_service_neo; run;
Data e; set e; keep bene_id date_service_neo; run;
proc sort; by bene_id; run;

***  many-to-many merge  ***;
proc sql; create table f as  select *  from c c, e e  where c.bene_id=e.bene_id; quit;

Data g; set f; where -14 <= date_service_myo-date_service_neo <= 14; run;
proc sort nodupkey; by bene_id date_service_myo; run;

proc sql; create table h as select * from g g left join d d on g.bene_id=d.bene_id; quit;

Data ccw.pop_07_nu; set h; where date_service_myo-date_service_echo>=92 or date_service_myo-date_service_echo<0 or date_service_echo=.; run;
proc sort nodupkey; by bene_id date_service_myo; run;

Data i; set ccw.kitty_beneficiary_summary_file;	keep zip_code bene_id; run;
proc sort nodupkey; by bene_id; run;

Data a; merge ccw.pop_07_nu (in=a) i (in=i); by bene_id; if a=1 and i=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_07_nu_zip; merge a (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_07_nu_zip; by HRR; run;
proc summary Data=ccw.pop_07_nu_zip; by HRR; output out=ccw.pop_07_nu_hrr sum(myocardial_perfusion)=n_nu; run;

Data ccw.pop_07_nu_hrr; set ccw.pop_07_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_07_hrr; merge ccw.pop_07_nu_hrr ccw.pop_07_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;



/***  Pop 08   ***/
 /* Denominator - individuals with a code for er visit with any of the ICD9 dx OR individuals with a hospitalizations with DRGs as listed, or primary, or secondary dx during hospitalization for any of the ICD9 dxs AND a code for cardiac rehab following that index hospitalization */
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where er_visit=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
Data er_visit; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; keep type clm_id bene_id; run;
Data a_er_pos; set ccw.kitty_op_claims_er ccw.kitty_bcarrier_claims_er ccw.kitty_op_claims_er_death ccw.kitty_bcarrier_claims_er_death; where ER_pos=1; keep type clm_id bene_id; run; 
Data er_visit; set er_visit a_er_pos; run;
proc sort nodupkey; by type clm_id bene_id; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where acs=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data a; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
proc sort; by type clm_id bene_id; run;

Data b; merge a (in=a) er_visit (in=b); by type clm_id bene_id; if a=1 and b=1; keep bene_id date_service; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where acs_drg=1; run;
%Mend type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data a; set a_icd_MedPAR a_icd_MedPAR_death; keep bene_id date_service; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where acs_ip_12=1; run;
%Mend type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data c; set a_icd_MedPAR a_icd_MedPAR_death; keep bene_id date_service; run;
Data c; set a b c; run;
proc sort; by bene_id; run;

%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where cardiac_rehab=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
Data d; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; rename date_service=date_service_cardiac; run;
proc sort; by bene_id; run;

***  many-to-many merge  ***;
proc sql; create table e as  select *  from c c, d d  where c.bene_id=d.bene_id; quit;

Data e; set e; where date_service_cardiac<=date_service+61 and date_service_cardiac>=date_service; run; 
proc sort nodupkey; by bene_id date_service date_service_cardiac; run;
Data f; set e; by bene_id date_service date_service_cardiac; if first.date_service=1; run;

Data e; set e; where date_service_cardiac<=date_service+61 and date_service_cardiac>=date_service; run; 

Data ccw.pop_08_de; set e; run; proc contents; run;
Data ccw.pop_08_de; set ccw.pop_08_de; keep date_service bene_id clm_id type date_service_cardiac; run;
proc sort nodupkey; by bene_id date_service date_service_cardiac; run;

proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_08_de; merge ccw.pop_08_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_08_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_08_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_08_de_zip; by HRR; run;
proc summary Data=ccw.pop_08_de_zip; by HRR;
output out=ccw.pop_08_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_08_de_hrr; set ccw.pop_08_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - Myocardial perfusion study DURING or AFTER the index hospitalization and BEFORE the first code for cardiac rehabilitation*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where myocardial_perfusion=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data c; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;

Data d; set ccw.pop_08_de; rename date_service=date_service_acs; run;
Data d; set d; keep bene_id date_service_cardiac date_service_acs; run;

  ***  many-to-many merge  ***;
  ***  identify eligible unique type+clm_id+bene_id+date_service observations  ***;
  ***  eligible means date requirements are satisfied  ***;
proc sql; create table e as  select *  from c c, d d  where c.bene_id=d.bene_id; quit;
Data ccw.pop_08_nu; set e; where date_service<date_service_cardiac and date_service>=date_service_acs; run;
proc sort nodupkey; by bene_id date_service; run;

Data b; set ccw.kitty_beneficiary_summary_file;	keep zip_code bene_id; run;
proc sort nodupkey; by bene_id; run;

Data a; merge ccw.pop_08_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_08_nu_zip; merge a (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_08_nu_zip; by HRR; run;
proc summary Data=ccw.pop_08_nu_zip; by HRR; output out=ccw.pop_08_nu_hrr sum(myocardial_perfusion)=n_nu; run;

Data ccw.pop_08_nu_hrr; set ccw.pop_08_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_08_hrr; merge ccw.pop_08_nu_hrr ccw.pop_08_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;



/***  Pop 09   ***/
 /* Denominator - Individuals with a code for revascularization procs AND a code for cardiac rehabiliation following that index hospitalization for revascularization*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where revascularization_proc=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where revascularization=1; run;
%Mend type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
%Macro type;
Data a_&type; set ccw.kitty_&type; where revascularization=1; run;
%Mend type; %let type=icdproc_outpatient; %type; %let type=proc_MedPAR; %type; %let type=icdproc_outpatient_death; %type; %let type=proc_MedPAR_death; %type;
Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death a_icd_MedPAR a_icd_MedPAR_death a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death a_proc_MedPAR a_proc_MedPAR_death;
rename revascularization_proc=revascularization; keep revascularization bene_id date_service; run;

%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where cardiac_rehab=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
Data b; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; keep cardiac_ct bene_id date_service; run;
Data b; set b;; rename date_service=date_service_cardiac; run; 

***  many-to-many merge  ***;
proc sql; create table c as  select *  from a a, b b  where a.bene_id=b.bene_id; quit;

Data c; set c; where date_service<date_service_cardiac; run; 
proc sort nodupkey; by bene_id date_service date_service_cardiac; run;
Data ccw.pop_03_de; set c; by bene_id date_service date_service_cardiac; if first.date_service=1; run;
proc sort nodupkey; by bene_id date_service date_service_cardiac; run;

proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_09_de; merge ccw.pop_09_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_09_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_09_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_09_de_zip; by HRR; run;
proc summary Data=ccw.pop_09_de_zip; by HRR;
output out=ccw.pop_09_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_09_de_hrr; set ccw.pop_09_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

  /* Numerator - Myocardial perfusion study DURING or AFTER the index hospitalization and BEFORE the first code for cardiac rehabilitation*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where myocardial_perfusion=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data c; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;


  /* Calculate # of myocardial_perfusion for each eligible unique type+clm_id+bene_id+date_service observations  */

  ***  many-to-many merge  ***;
  ***  identify eligible unique type+clm_id+bene_id+date_service observations  ***;
  ***  eligible means date requirements are satisfied  ***;
Data d; set ccw.pop_09_de; rename date_service=date_service_rev; run;
Data d; set d; keep bene_id date_service_cardiac date_service_rev; run;
proc sort; by bene_id date_service_rev date_service_cardiac; run;
Data d; set d; by bene_id date_service_rev date_service_cardiac; if first. date_service_rev=1; run;

proc sql; create table e as  select *  from c c, d d  where c.bene_id=d.bene_id; quit;
Data e; set e; where date_service<date_service_cardiac and date_service>=date_service_rev; run;
proc contents; run;
Data ccw.pop_09_nu; set e; keep type clm_id bene_id date_service myocardial_perfusion; run; 
proc sort nodupkey; by bene_id date_service; run;


Data b; set ccw.kitty_beneficiary_summary_file;	keep zip_code bene_id; run;
proc sort nodupkey; by bene_id; run;

Data a; merge ccw.pop_09_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_09_nu_zip; merge a (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_09_nu_zip; by HRR; run;
proc summary Data=ccw.pop_09_nu_zip; by HRR; output out=ccw.pop_09_nu_hrr sum(myocardial_perfusion)=n_nu; run;

Data ccw.pop_09_nu_hrr; set ccw.pop_09_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_09_hrr; merge ccw.pop_09_nu_hrr ccw.pop_09_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;



/***  Pop 10   ***/
 /* Denominator - Everyone MINUS those with a clear indication (radicular symptoms--symptoms clearly of herniated disc-radicular pain)*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where herniated_disc=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data a; set a_icd_carrier a_icd_outpatient a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR a_icd_MedPAR_death; run;
*Exclude all herniated disc;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where mononeuritis=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data b; set a_icd_carrier a_icd_outpatient a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR a_icd_MedPAR_death; run;
*Exclude mononueritis if occur 2 times with 30 days;

Data b; set b; rename date_service=date_service_mononeuritis; keep type clm_id bene_id mononeuritis date_service; run;
proc sort data=b; by bene_id date_service_mononeuritis; run;
Data c; set b; by bene_id date_service_mononeuritis; 
	lag_date_service = lag(date_service_mononeuritis); 
	label lag_date_service = "Previous visit date";

	if first.bene_id then diff = 100;
	if not first.bene_id then diff = date_service_mononeuritis - lag_date_service;
	
	if diff > 30 then delete; run; 

Data d; set a c; run;
proc sort nodupkey; by bene_id; run;

Data e; set ccw.kitty_beneficiary_summary_file; length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort; by bene_id; run;
Data ccw.pop_10_de; merge d (in=d) e (in=e); by bene_id; if e=1 and d=0; length n_de 3; n_de=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_10_de_zip; merge ccw.pop_10_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_10_de_zip; by HRR; run;
proc summary Data=ccw.pop_10_de_zip; by HRR;
output out=ccw.pop_10_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_10_de_hrr; set ccw.pop_10_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

 /* Numerator - Laminectomy or spinal fusion */
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where laminectomy=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where spinal_fusion=1; run;
%Mend type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

%Macro type;
Data a_&type; set ccw.kitty_&type; where spinal_fusion=1; run;
%Mend type; %let type=icdproc_outpatient; %type; %let type=proc_MedPAR; %type; %let type=icdproc_outpatient_death; %type; %let type=proc_MedPAR_death; %type;

Data ccw.pop_10_nu; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death a_icd_MedPAR a_icd_MedPAR_death a_icdproc_outpatient a_proc_MedPAR a_icdproc_outpatient_death a_proc_MedPAR_death;
length n_nu 3; n_nu=1; run;
proc sort nodupkey; by bene_id date_service; run;

Data b; set ccw.pop_10_de;	keep zip_code bene_id; run;
proc sort nodupkey; by bene_id; run;

Data ccw.pop_10_nu; merge ccw.pop_10_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_10_nu_zip; merge ccw.pop_10_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_10_nu_zip; by HRR; run;
proc summary Data=ccw.pop_10_nu_zip; by HRR;
output out=ccw.pop_10_nu_hrr sum(n_nu)=n_nu; run;

Data ccw.pop_10_nu_hrr; set ccw.pop_10_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_10_hrr; merge ccw.pop_10_nu_hrr ccw.pop_10_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;



/***  Pop 11   ***/
 /* Denominator - all women minus those with a malignancy diagnosis (ICD9 and DRG)*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where malignancy=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data a; set a_icd_carrier a_icd_outpatient a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR a_icd_MedPAR_death; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where malignancy=1; run;
%Mend type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data b; set a_icd_MedPAR a_icd_MedPAR_death; run;

Data c; set a b; run;
proc sort data=c nodupkey; by bene_id; run;

Data d; set ccw.kitty_beneficiary_summary_file; where women_all=1; length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort; by bene_id; run;
Data ccw.pop_11_de; merge c (in=c) d (in=d); by bene_id; if c=0 and d=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_11_de_zip; merge ccw.pop_11_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_11_de_zip; by HRR; run;
proc summary Data=ccw.pop_11_de_zip; by HRR;
output out=ccw.pop_11_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_11_de_hrr; set ccw.pop_11_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - anyone with hysterectomy (not specified for malignancy) */
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where hysterectomy=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

%Macro type;
Data a_&type; set ccw.kitty_&type; where hysterectomy=1; run;
%Mend type; %let type=icdproc_outpatient; %type; %let type=proc_MedPAR; %type; %let type=icdproc_outpatient_death; %type; %let type=proc_MedPAR_death; %type;

Data ccw.pop_11_nu; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death a_icdproc_outpatient a_proc_MedPAR a_icdproc_outpatient_death a_proc_MedPAR_death; run;
proc sort nodupkey; by bene_id date_service; run;

Data b; set ccw.pop_11_de; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

Data ccw.pop_11_nu; merge ccw.pop_11_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by bene_id; run;

Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data c; merge ccw.pop_11_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_11_nu_zip; merge c (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_11_nu_zip; by HRR; run;
proc summary Data=ccw.pop_11_nu_zip; by HRR;
output out=ccw.pop_11_nu_hrr sum(hysterectomy)=n_nu; run;

Data ccw.pop_11_nu_hrr; set ccw.pop_11_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_11_hrr; merge ccw.pop_11_nu_hrr ccw.pop_11_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;



/***  Pop 12   ***/
 /* Denominator - whole population */
Data ccw.pop_12_de; set ccw.kitty_beneficiary_summary_file;	length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_12_de_zip; merge ccw.pop_12_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_12_de_zip; by HRR; run;
proc summary Data=ccw.pop_12_de_zip; by HRR;
output out=ccw.pop_12_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_12_de_hrr; set ccw.pop_12_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

  /* Numerator - anyone with PTCA */
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where ptca=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where ptca=1; run;
%Mend type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

Data ccw.pop_12_nu; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death a_icd_MedPAR a_icd_MedPAR_death; run;
proc sort nodupkey; by bene_id date_service; run;

Data b; set ccw.kitty_beneficiary_summary_file;	keep zip_code bene_id; run;
proc sort nodupkey; by bene_id; run;

Data a; merge ccw.pop_12_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_12_nu_zip; merge a (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_12_nu_zip; by HRR; run;
proc summary Data=ccw.pop_12_nu_zip; by HRR; output out=ccw.pop_12_nu_hrr sum(ptca)=n_nu; run;

Data ccw.pop_12_nu_hrr; set ccw.pop_12_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_12_hrr; merge ccw.pop_12_nu_hrr ccw.pop_12_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;



/***  Pop 13   ***/
 /* Denominator - whole population */
Data ccw.pop_13_de; set ccw.kitty_beneficiary_summary_file;	length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_13_de_zip; merge ccw.pop_13_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_13_de_zip; by HRR; run;
proc summary Data=ccw.pop_13_de_zip; by HRR;
output out=ccw.pop_13_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_13_de_hrr; set ccw.pop_13_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

  /* Numerator - anyone with CABG */
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where cabg=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where cabg=1; run;
%Mend type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

%Macro type;
Data a_&type; set ccw.kitty_&type; where cabg=1; run;
%Mend type; %let type=icdproc_outpatient; %type; %let type=proc_MedPAR; %type; %let type=icdproc_outpatient_death; %type; %let type=proc_MedPAR_death; %type;

Data ccw.pop_13_nu; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death a_icd_MedPAR a_icd_MedPAR_death a_icdproc_outpatient a_proc_MedPAR a_icdproc_outpatient_death a_proc_MedPAR_death; run;
proc sort nodupkey; by bene_id date_service; run;

Data b; set ccw.kitty_beneficiary_summary_file;	keep zip_code bene_id; run;
proc sort nodupkey; by bene_id; run;

Data a; merge ccw.pop_13_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_13_nu_zip; merge a (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_13_nu_zip; by HRR; run;
proc summary Data=ccw.pop_13_nu_zip; by HRR;
output out=ccw.pop_13_nu_hrr sum(cabg)=n_nu; run;

Data ccw.pop_13_nu_hrr; set ccw.pop_13_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_13_hrr; merge ccw.pop_13_nu_hrr ccw.pop_13_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;



/***  Pop 14   ***/
 /* Denominator - whole population */
Data ccw.pop_14_de; set ccw.kitty_beneficiary_summary_file; length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_14_de_zip; merge ccw.pop_14_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_14_de_zip; by HRR; run;
proc summary Data=ccw.pop_14_de_zip; by HRR;
output out=ccw.pop_14_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_14_de_hrr; set ccw.pop_14_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

  /* Numerator - anyone with hip arthroplasty */
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where hip_arthroplasty=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

%Macro type;
Data a_&type; set ccw.kitty_&type; where hip_arthroplasty=1; run;
%Mend type; %let type=icdproc_outpatient; %type; %let type=proc_MedPAR; %type; %let type=icdproc_outpatient_death; %type; %let type=proc_MedPAR_death; %type;

Data ccw.pop_14_nu; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death a_icdproc_outpatient a_proc_MedPAR a_icdproc_outpatient_death a_proc_MedPAR_death; run;
proc sort nodupkey; by bene_id date_service; run;

Data b; set ccw.kitty_beneficiary_summary_file;	keep zip_code bene_id; run;
proc sort nodupkey; by bene_id; run;

Data a; merge ccw.pop_14_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_14_nu_zip; merge a (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_14_nu_zip; by HRR; run;
proc summary Data=ccw.pop_14_nu_zip; by HRR;
output out=ccw.pop_14_nu_hrr sum(hip_arthroplasty)=n_nu; run;

Data ccw.pop_14_nu_hrr; set ccw.pop_14_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_14_hrr; merge ccw.pop_14_nu_hrr ccw.pop_14_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; where hrr ne ""; run;



/***  Pop 15   ***/
 /* Denominator - whole population */
Data ccw.pop_15_de; set ccw.kitty_beneficiary_summary_file;	length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_15_de_zip; merge ccw.pop_15_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_15_de_zip; by HRR; run;
proc summary Data=ccw.pop_15_de_zip; by HRR;
output out=ccw.pop_15_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_15_de_hrr; set ccw.pop_15_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

  /* Numerator - anyone with knee arthroplasty */
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where knee_arthroplasty=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

%Macro type;
Data a_&type; set ccw.kitty_&type; where knee_arthroplasty=1; run;
%Mend type; %let type=icdproc_outpatient; %type; %let type=proc_MedPAR; %type; %let type=icdproc_outpatient_death; %type; %let type=proc_MedPAR_death; %type;

Data ccw.pop_15_nu; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death a_icdproc_outpatient a_proc_MedPAR a_icdproc_outpatient_death a_proc_MedPAR_death; run;
proc sort nodupkey; by bene_id date_service; run;

Data b; set ccw.kitty_beneficiary_summary_file;	keep zip_code bene_id; run;
proc sort nodupkey; by bene_id; run;

Data a; merge ccw.pop_15_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_15_nu_zip; merge a (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_15_nu_zip; by HRR; run;
proc summary Data=ccw.pop_15_nu_zip; by HRR;
output out=ccw.pop_15_nu_hrr sum(knee_arthroplasty)=n_nu; run;

Data ccw.pop_15_nu_hrr; set ccw.pop_15_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_15_hrr; merge ccw.pop_15_nu_hrr ccw.pop_15_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;



/***  Pop 16   ***/
 /* Denominator - whole male population */
Data ccw.pop_16_de; set ccw.kitty_beneficiary_summary_file; where men_all=1; length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_16_de_zip; merge ccw.pop_16_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_16_de_zip; by HRR; run;
proc summary Data=ccw.pop_16_de_zip; by HRR;
output out=ccw.pop_16_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_16_de_hrr; set ccw.pop_16_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - anyone with prostatectomy */
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where prostatectomy=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

%Macro type;
Data a_&type; set ccw.kitty_&type; where prostatectomy=1; run;
%Mend type; %let type=icdproc_outpatient; %type; %let type=proc_MedPAR; %type; %let type=icdproc_outpatient_death; %type; %let type=proc_MedPAR_death; %type;

Data ccw.pop_16_nu; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death a_icdproc_outpatient a_proc_MedPAR a_icdproc_outpatient_death a_proc_MedPAR_death; run;
proc sort nodupkey; by bene_id date_service; run;

Data b; set ccw.pop_16_de; keep bene_id; run;
proc sort nodupkey; by bene_id; run;
proc sort Data=ccw.pop_16_nu; by bene_id; run;

Data ccw.pop_16_nu; merge ccw.pop_16_nu (in=a) b (in=b); if a=1 and b=1; by bene_id; run;

Data b; set ccw.kitty_beneficiary_summary_file; where men_all=1; keep zip_code bene_id; run;
proc sort nodupkey; by bene_id; run;

Data a; merge ccw.pop_16_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_16_nu_zip; merge a (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_16_nu_zip; by HRR; run;
proc summary Data=ccw.pop_16_nu_zip; by HRR;
output out=ccw.pop_16_nu_hrr sum(prostatectomy)=n_nu; run;

Data ccw.pop_16_nu_hrr; set ccw.pop_16_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_16_hrr; merge ccw.pop_16_nu_hrr ccw.pop_16_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;



/***  Pop 18   ***  0 had numerator
* Denominator - patient visits with chronic ulcer visit *
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where pt_visit=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
Data pt_visit; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; keep type clm_id bene_id date_service; run;
proc sort nodupkey; by type clm_id bene_id; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where chronic_ulcer=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data a; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
proc sort; by type clm_id bene_id; run;

Data ccw.pop_18_de; merge a (in=a) pt_visit (in=b); by type clm_id bene_id; if a=1 and b=1; run;
proc sort nodupkey; by bene_id date_service; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_18_de; merge ccw.pop_18_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_18_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_18_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_18_de_zip; by HRR; run;
proc summary Data=ccw.pop_18_de_zip; by HRR;
output out=ccw.pop_18_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_18_de_hrr; set ccw.pop_18_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

* Numerator - patient with wound culture *
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where wound_culture=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort; by type clm_id bene_id; run;
Data b; set ccw.pop_18_de; keep type clm_id bene_id; run;
proc sort nodupkey; by type clm_id bene_id; run;

Data ccw.pop_18_nu; merge a (in=a) b (in=b); by type clm_id bene_id; if a=1 and b=1; run;
proc sort nodupkey; by bene_id date_service; run;
Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_18_nu; merge ccw.pop_18_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_18_nu_zip; merge ccw.pop_18_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_18_nu_zip; by HRR; run;
proc summary Data=ccw.pop_18_nu_zip; by HRR;
output out=ccw.pop_18_nu_hrr sum(wound_culture)=n_nu; run;

Data ccw.pop_18_nu_hrr; set ccw.pop_18_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_18_hrr; merge ccw.pop_18_nu_hrr ccw.pop_18_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;	/






/***  Pop 19   ***/
 /* Denominator - Individuals with a diagnosis of sinusitis (acute or chronic) –inpatient or outpatient*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where sinusitis=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data ccw.pop_19_de_claim; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
Data ccw.pop_19_de; set ccw.pop_19_de_claim; run; 
proc sort nodupkey; by bene_id date_service; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_19_de; merge ccw.pop_19_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_19_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_19_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_19_de_zip; by HRR; run;
proc summary Data=ccw.pop_19_de_zip; by HRR;
output out=ccw.pop_19_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_19_de_hrr; set ccw.pop_19_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - Allergy testing WITH an ICD-9 code indicating sinusitis on the same claim ID */
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where allergy_testing=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort; by type clm_id bene_id; run;
Data b; set ccw.pop_19_de_claim; keep type clm_id bene_id; run;
proc sort nodupkey; by type clm_id bene_id; run;

Data ccw.pop_19_nu; merge a (in=a) b (in=b); by type clm_id bene_id; if a=1 and b=1; run;
proc sort nodupkey; by bene_id date_service; run;
Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_19_nu; merge ccw.pop_19_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_19_nu_zip; merge ccw.pop_19_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_19_nu_zip; by HRR; run;
proc summary Data=ccw.pop_19_nu_zip; by HRR;
output out=ccw.pop_19_nu_hrr sum(allergy_testing)=n_nu; run;

Data ccw.pop_19_nu_hrr; set ccw.pop_19_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_19_hrr; merge ccw.pop_19_nu_hrr ccw.pop_19_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means data=ccw.pop_19_hrr; var n_nu n_de rate; run;



/***  Pop 20   ***/
 /* Denominator - Individual with a diagnosis of sinusitis (acute or chronic) –inpatient or outpatient*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where sinusitis=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

Data ccw.pop_20_de_claim; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
Data ccw.pop_20_de; set ccw.pop_20_de_claim; run; 
proc sort nodupkey; by bene_id date_service; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_20_de; merge ccw.pop_20_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_20_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_20_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_20_de_zip; by HRR; run;
proc summary Data=ccw.pop_20_de_zip; by HRR;
output out=ccw.pop_20_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_20_de_hrr; set ccw.pop_20_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - Laryngoscopy WITH ICD-9 code indicating sinusitis on the same claim ID*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where fiberoptic_laryngoscopy=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort; by type clm_id bene_id; run;
Data b; set ccw.pop_20_de_claim; keep type clm_id bene_id; run;
proc sort nodupkey; by type clm_id bene_id; run;

Data ccw.pop_20_nu; merge a (in=a) b (in=b); by type clm_id bene_id; if a=1 and b=1; run;
proc sort nodupkey; by bene_id date_service; run;
Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_20_nu; merge ccw.pop_20_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_20_nu_zip; merge ccw.pop_20_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_20_nu_zip; by HRR; run;
proc summary Data=ccw.pop_20_nu_zip; by HRR;
output out=ccw.pop_20_nu_hrr sum(fiberoptic_laryngoscopy)=n_nu; run;

Data ccw.pop_20_nu_hrr; set ccw.pop_20_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_20_hrr; merge ccw.pop_20_nu_hrr ccw.pop_20_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means data=ccw.pop_20_hrr; var n_nu n_de rate; run;



/***  Pop 21   ***/
 /* Denominator - Individual with a diagnosis of sinusitis (acute or chronic) –inpatient or outpatient*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where sinusitis=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

Data ccw.pop_21_de_claim; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
Data ccw.pop_21_de; set ccw.pop_20_de_claim; run; 
proc sort nodupkey; by bene_id date_service; run;

proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_21_de; merge ccw.pop_21_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_21_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_21_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_21_de_zip; by HRR; run;
proc summary Data=ccw.pop_21_de_zip; by HRR;
output out=ccw.pop_21_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_21_de_hrr; set ccw.pop_21_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - Nasal endoscopy WITH ICD-9 code indicating sinusitis on the same claim ID*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where diagnostic_endoscopy=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort; by type clm_id bene_id; run;
Data b; set ccw.pop_21_de_claim; keep type clm_id bene_id; run;
proc sort nodupkey; by type clm_id bene_id; run;

Data ccw.pop_21_nu; merge a (in=a) b (in=b); by type clm_id bene_id; if a=1 and b=1; run;
proc sort nodupkey; by bene_id date_service; run;
Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_21_nu; merge ccw.pop_21_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_21_nu_zip; merge ccw.pop_21_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_21_nu_zip; by HRR; run;
proc summary Data=ccw.pop_21_nu_zip; by HRR;
output out=ccw.pop_21_nu_hrr sum(diagnostic_endoscopy)=n_nu; run;

Data ccw.pop_21_nu_hrr; set ccw.pop_21_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_21_hrr; merge ccw.pop_21_nu_hrr ccw.pop_21_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means data=ccw.pop_21_hrr; var n_nu n_de rate; run;



/***  Pop 22   ***/
  /* Numerator - Cervical screen (necessarily will include vaginal screens too)*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where PAP_test=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data ccw.pop_22_nu; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;

proc sort nodupkey; by bene_id date_service; run;
Data b; set ccw.kitty_beneficiary_summary_file;	where women_all=1; keep zip_code bene_id; run;
proc sort nodupkey; by bene_id; run;

Data ccw.pop_22_nu; merge ccw.pop_22_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_22_nu_zip; merge ccw.pop_22_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_22_nu_zip; by HRR; run;
proc summary Data=ccw.pop_22_nu_zip; by HRR;
output out=ccw.pop_22_nu_hrr sum(PAP_test)=n_nu; run;

Data ccw.pop_22_nu_hrr; set ccw.pop_22_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

 /* Denominator – Women 65 years and older */
Data ccw.pop_22_de; set ccw.kitty_beneficiary_summary_file;	where women_all=1; length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_22_de_zip; merge ccw.pop_22_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_22_de_zip; by HRR; run;
proc summary Data=ccw.pop_22_de_zip; by HRR;
output out=ccw.pop_22_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_22_de_hrr; set ccw.pop_22_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

Data ccw.pop_22_hrr; merge ccw.pop_22_nu_hrr ccw.pop_22_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; where hrr ne ""; run;



/***  Pop 23   ***/
  /* Numerator - Evidence of a PSA test*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where PSA=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data ccw.pop_23_nu; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;

proc sort nodupkey; by bene_id date_service; run;
Data b; set ccw.kitty_beneficiary_summary_file;	where men_75=1; keep zip_code bene_id; run;
proc sort nodupkey; by bene_id; run;

Data ccw.pop_23_nu; merge ccw.pop_23_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_23_nu_zip; merge ccw.pop_23_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_23_nu_zip; by HRR; run;
proc summary Data=ccw.pop_23_nu_zip; by HRR;
output out=ccw.pop_23_nu_hrr sum(PSA)=n_nu; run;

Data ccw.pop_23_nu_hrr; set ccw.pop_23_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

 /* Denominator */
Data ccw.pop_23_de; set ccw.kitty_beneficiary_summary_file;	where men_75=1; length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_23_de_zip; merge ccw.pop_23_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_23_de_zip; by HRR; run;
proc summary Data=ccw.pop_23_de_zip; by HRR;
output out=ccw.pop_23_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_23_de_hrr; set ccw.pop_23_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

Data ccw.pop_23_hrr; merge ccw.pop_23_nu_hrr ccw.pop_23_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; where hrr ne ""; run;



/***  Pop 24   ***/
 /* Denominator - Individuals with death during our observation period */
Data ccw.pop_24_de; set ccw.beneficiary_death; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_24_de; keep zip_code bene_id n_de BENE_DEATH_DT; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_24_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_24_de_zip; by HRR; run;
proc summary Data=ccw.pop_24_de_zip; by HRR;
output out=ccw.pop_24_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_24_de_hrr; set ccw.pop_24_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

  /* Numerator - More than 2 visits with location code or CPT code indicating ED use within 30 days before death*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where er_visit=1 OR er_pos=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
Data b; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
Data a_er_pos; set ccw.kitty_op_claims_er ccw.kitty_bcarrier_claims_er ccw.kitty_op_claims_er_death ccw.kitty_bcarrier_claims_er_death; where ER_pos=1; run; 
Data b; set b a_er_pos; run;
proc sort nodupkey; by bene_id date_service; run;

Data a; set ccw.pop_24_de; keep bene_id BENE_DEATH_DT; run;
proc sort nodupkey; by bene_id; run;

Data c; merge a (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
Data c; set c; where date_service>=BENE_DEATH_DT-30; length n_nu 3; n_nu=1; run;
/** proc sort; by bene_id; run;
Data d; set c; by bene_id;  n+1; if first.bene_id=1 then n=1;run; proc freq; table n; run;
proc sort; by bene_id; run; Data e; set d; by bene_id n; if last.bene_id=1; run; proc freq; table n; run;  **/
proc summary Data=c; by bene_id; output out=d sum(n_nu)=n; run;
proc freq data=d; table n; run;

Data ccw.pop_24_nu; set d; where n>=2; run;
proc sort Data=ccw.pop_24_nu; by bene_id; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;

Data a; merge ccw.pop_24_nu (in=a) ccw.kitty_beneficiary_summary_file (in=b); by bene_id; if a=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_24_nu_zip; merge a (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; length n_nu 3; n_nu=1; run; 

proc sort Data=ccw.pop_24_nu_zip; by HRR; run;
proc summary Data=ccw.pop_24_nu_zip; by HRR;
output out=ccw.pop_24_nu_hrr sum(n_nu)=n_nu; run;

Data ccw.pop_24_nu_hrr; set ccw.pop_24_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_24_hrr; merge ccw.pop_24_nu_hrr ccw.pop_24_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; where hrr ne ""; run;



/***  Pop 25   ***/
 /* Denominator - Individuals with knee replacement surgery*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where knee_surgery=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
%Macro type;
Data a_&type; set ccw.kitty_&type; where knee_surgery=1; run;
%Mend type; %let type=icdproc_outpatient; %type; %let type=proc_MedPAR; %type; %let type=icdproc_outpatient_death; %type; %let type=proc_MedPAR_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death a_icdproc_outpatient a_proc_MedPAR a_icdproc_outpatient_death a_proc_MedPAR_death; run;
proc sort nodupkey; by bene_id date_service; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_25_de; merge a (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_25_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_25_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_25_de_zip; by HRR; run;
proc summary Data=ccw.pop_25_de_zip; by HRR;
output out=ccw.pop_25_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_25_de_hrr; set ccw.pop_25_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - Individuals with MRI of knee within 3 month of surgery*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where MRI_knee=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort nodupkey; by bene_id date_service;  run;

Data b; set ccw.pop_25_de; keep bene_id date_service; run;
Data b; set b; rename date_service=date_service_de; run;
proc sort; by bene_id; run;

***  many-to-many merge  ***;
proc sql; create table c as  select *  from a a, b b  where a.bene_id=b.bene_id; quit;
proc contents; run;

Data ccw.pop_25_nu; set c; where date_service_de-date_service >=0 and date_service_de-date_service <=92; run;
proc sort nodupkey; by bene_id date_service;  run;
Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_25_nu; merge ccw.pop_25_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_25_nu_zip; merge ccw.pop_25_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_25_nu_zip; by HRR; run;
proc summary Data=ccw.pop_25_nu_zip; by HRR;
output out=ccw.pop_25_nu_hrr sum(MRI_knee)=n_nu; run;

Data ccw.pop_25_nu_hrr; set ccw.pop_25_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_25_hrr; merge ccw.pop_25_nu_hrr ccw.pop_25_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;



/***  Pop 26   ***/
 /* Denominator - All patients with CHF (will include atrial fibrillation patients as well)*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where CHF=1 or AF_flutter=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

Data ccw.pop_26_de; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
proc sort nodupkey; by bene_id; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_26_de; merge ccw.pop_26_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_26_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_26_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_26_de_zip; by HRR; run;
proc summary Data=ccw.pop_26_de_zip; by HRR;
output out=ccw.pop_26_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_26_de_hrr; set ccw.pop_26_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means Data=ccw.pop_26_de_hrr; var n_de; run;


  /* Numerator - Any measure of digoxin with no hospitalizations or ER visits during that year.*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where digoxin=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort; by bene_id; run;

  /* Hospitalization & ER */
Data hospitalization; set ccw.kitty_medpar_death ccw.kitty_medpar; run;
Data hospitalization; set hospitalization; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where er_visit=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
Data er_visit; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; keep type clm_id bene_id; run;
Data a_er_pos; set ccw.kitty_op_claims_er ccw.kitty_bcarrier_claims_er ccw.kitty_op_claims_er_death ccw.kitty_bcarrier_claims_er_death; where ER_pos=1; keep type clm_id bene_id; run; 
Data er_visit; set er_visit a_er_pos; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

Data b; set ccw.pop_26_de; keep bene_id; run; 
proc sort nodup; by bene_id; run;

Data ccw.pop_26_nu; merge a (in=a) hospitalization (in=b) er_visit (in=c) b (in=d); by bene_id; if a=1 and b=0 and c=0 and d=1; run;
proc sort nodupkey; by bene_id; run;

Data b; set ccw.pop_26_nu; keep digoxin bene_id; run;
proc sort; by bene_id; run;
Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_26_nu; merge b (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_26_nu_zip; merge ccw.pop_26_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_26_nu_zip; by HRR; run;
proc summary Data=ccw.pop_26_nu_zip; by HRR;
output out=ccw.pop_26_nu_hrr sum(digoxin)=n_nu; run;

Data ccw.pop_26_nu_hrr; set ccw.pop_26_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_26_hrr; merge ccw.pop_26_nu_hrr ccw.pop_26_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means data=ccw.pop_26_hrr; var n_nu n_de rate; run;




/***  Pop 27   ***/
 /* Denominator - Individuals with an outpatient visit with diagnosis of syncope or hospitalization for syncope*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where syncope_heat=1 or syncope_carotid_sinus=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

Data ccw.pop_27_de_claim; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
Data ccw.pop_27_de; set ccw.pop_27_de_claim; run;
proc sort nodupkey; by bene_id date_service; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_27_de; merge ccw.pop_27_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_27_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_27_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_27_de_zip; by HRR; run;
proc summary Data=ccw.pop_27_de_zip; by HRR;
output out=ccw.pop_27_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_27_de_hrr; set ccw.pop_27_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - EEG on the same claim as diagnosis of syncope or at any time during the hospitalization with a code for syncope*/
  /* EGG not in ICD Procedure Outpatient */
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where eeg=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
%Macro type;
Data a_&type; set ccw.kitty_&type; where eeg=1; run;
%Mend type; %let type=proc_MedPAR; %type; %let type=proc_MedPAR_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death a_proc_MedPAR a_proc_MedPAR_death; run;
proc sort; by type clm_id bene_id; run;
Data b; set ccw.pop_27_de_claim; keep type clm_id bene_id; run;
proc sort nodupkey; by type clm_id bene_id; run;

Data ccw.pop_27_nu; merge a (in=a) b (in=b); by type clm_id bene_id; if a=1 and b=1; run;
proc sort nodupkey; by bene_id date_service; run;
Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_27_nu; merge ccw.pop_27_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_27_nu_zip; merge ccw.pop_27_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_27_nu_zip; by HRR; run;
proc summary Data=ccw.pop_27_nu_zip; by HRR;
output out=ccw.pop_27_nu_hrr sum(eeg)=n_nu; run;

Data ccw.pop_27_nu_hrr; set ccw.pop_27_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_27_hrr; merge ccw.pop_27_nu_hrr ccw.pop_27_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means data=ccw.pop_27_hrr; var n_nu n_de rate; run;




/***  Pop 28   ***/
 /* Denominator - Patients with lung cancer diagnosis*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where lung_cancer=1 or lung_cancer_out=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

Data a_all; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
Data a_in; set a_all; where lung_cancer=1; run;
proc sort nodupkey; by bene_id; run;
Data a_out; set a_all; where lung_cancer_out=1; run;
proc sort nodupkey; by bene_id; run;

Data ccw.pop_28_de; merge a_in a_out; by bene_id; length n_de 3; n_de=1; 
if lung_cancer=. then lung_cancer=0; if lung_cancer_out=. then lung_cancer_out=0;
run;
proc sort nodupkey; by bene_id; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_28_de; merge ccw.pop_28_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; run; 

Data b; set ccw.pop_28_de;	where lung_cancer=1 and lung_cancer_out=0; keep zip_code bene_id n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_28_de_zip; merge b ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_28_de_zip; by HRR; run;
proc summary Data=ccw.pop_28_de_zip; by HRR;
output out=ccw.pop_28_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_28_de_hrr; set ccw.pop_28_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


 /* Numerator - Evidence of MRI of chest*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where MRI_chest=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data ccw.pop_28_nu; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;

proc sort nodupkey; by bene_id date_service; run;
Data b; set ccw.pop_28_de;	where lung_cancer=1 and lung_cancer_out=0; keep zip_code bene_id n_de; run;
proc sort nodupkey; by bene_id; run;

Data ccw.pop_28_nu; merge ccw.pop_28_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_28_nu_zip; merge  ccw.pop_28_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_28_nu_zip; by HRR; run;
proc summary Data=ccw.pop_28_nu_zip; by HRR;
output out=ccw.pop_28_nu_hrr sum(MRI_chest)=n_nu; run;

Data ccw.pop_28_nu_hrr; set ccw.pop_28_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_28_hrr; merge ccw.pop_28_nu_hrr ccw.pop_28_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;



/***  Pop 29   ***/
 /* Denominator - Patient with any diagnosis code of foot ulcer*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where foot_ulcer=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

Data ccw.pop_29_de; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
proc sort nodupkey; by bene_id date_service; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_29_de; merge ccw.pop_29_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_29_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_29_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_29_de_zip; by HRR; run;
proc summary Data=ccw.pop_29_de_zip; by HRR;
output out=ccw.pop_29_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_29_de_hrr; set ccw.pop_29_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - Receipt of hyperbaric oxygen with associated diagnosis code of foot ulcer*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where hyperbaric_oxygen=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
%Macro type;
Data a_&type; set ccw.kitty_&type; where hyperbaric_oxygen=1; run;
%Mend type; %let type=icdproc_outpatient; %type; %let type=proc_MedPAR; %type; %let type=icdproc_outpatient_death; %type; %let type=proc_MedPAR_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death a_icdproc_outpatient a_proc_MedPAR a_icdproc_outpatient_death a_proc_MedPAR_death; run;
proc sort nodupkey; by type clm_id bene_id date_service; run;
Data b; set ccw.pop_29_de; keep type clm_id bene_id; run;
proc sort nodupkey; by type clm_id bene_id; run;

Data ccw.pop_29_nu; merge a (in=a) b (in=b); by type clm_id bene_id; if a=1 and b=1; run;
proc sort nodupkey; by bene_id date_service; run;
Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_29_nu; merge ccw.pop_29_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_29_nu_zip; merge ccw.pop_29_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_29_nu_zip; by HRR; run;
proc summary Data=ccw.pop_29_nu_zip; by HRR;
output out=ccw.pop_29_nu_hrr sum(hyperbaric_oxygen)=n_nu; run;

Data ccw.pop_29_nu_hrr; set ccw.pop_29_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_29_hrr; merge ccw.pop_29_nu_hrr ccw.pop_29_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means data=ccw.pop_29_hrr; var n_nu n_de rate; run;




/***  Pop 30  No on has numerator
** Denominator - Patient with any diagnosis code of multiple sclerosis  **
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where multiple_sclerosis=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

Data ccw.pop_30_de; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
proc sort nodupkey; by bene_id; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_30_de; merge ccw.pop_30_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_30_de; keep bene_id zip_code n_de; run;
proc sort nodup; by bene_id; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_30_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_30_de_zip; by HRR; run;
proc summary Data=ccw.pop_30_de_zip; by HRR;
output out=ccw.pop_30_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_30_de_hrr; set ccw.pop_30_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


* Numerator - Receipt of hyperbaric oxygen with associated diagnosis code of multiple sclerosis *
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where hyperbaric_oxygen=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
%Macro type;
Data a_&type; set ccw.kitty_&type; where hyperbaric_oxygen=1; run;
%Mend type; %let type=icdproc_outpatient; %type; %let type=proc_MedPAR; %type; %let type=icdproc_outpatient_death; %type; %let type=proc_MedPAR_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death a_icdproc_outpatient a_proc_MedPAR a_icdproc_outpatient_death a_proc_MedPAR_death; run;
proc sort nodupkey; by type clm_id bene_id date_service; run;
Data b; set ccw.pop_30_de; keep type clm_id bene_id; run;
proc sort nodupkey; by type clm_id bene_id; run;

Data ccw.pop_30_nu; merge a (in=a) b (in=b); by type clm_id bene_id; if a=1 and b=1; run;
proc sort; by bene_id; run;
Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_30_nu; merge ccw.pop_30_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_30_nu_zip; merge ccw.pop_30_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_30_nu_zip; by HRR; run;
proc summary Data=ccw.pop_30_nu_zip; by HRR;
output out=ccw.pop_30_nu_hrr sum(hyperbaric_oxygen)=n_nu; run;

Data ccw.pop_30_nu_hrr; set ccw.pop_30_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_30_hrr; merge ccw.pop_30_nu_hrr ccw.pop_30_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means data=ccw.pop_30_hrr; var n_nu n_de rate; run;  ***/



/***   Pop 32   ***/
  /* Numerator - Any code indicating testing for H. pylori*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where h_pylori_test=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data ccw.pop_32_nu; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;

proc sort nodupkey; by bene_id date_service; run;
Data b; set ccw.kitty_beneficiary_summary_file;	keep zip_code bene_id; run;
proc sort nodupkey; by bene_id; run;

Data a; merge ccw.pop_32_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_32_nu_zip; merge a (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_32_nu_zip; by HRR; run;
proc summary Data=ccw.pop_32_nu_zip; by HRR;
output out=ccw.pop_32_nu_hrr sum(h_pylori_test)=n_nu; run;

Data ccw.pop_32_nu_hrr; set ccw.pop_32_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

 /* Denominator - Whole population */
Data ccw.pop_32_de; set ccw.kitty_beneficiary_summary_file;	length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_32_de_zip; merge ccw.pop_32_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_32_de_zip; by HRR; run;
proc summary Data=ccw.pop_32_de_zip; by HRR;
output out=ccw.pop_32_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_32_de_hrr; set ccw.pop_32_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

Data ccw.pop_32_hrr; merge ccw.pop_32_nu_hrr ccw.pop_32_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; where HRR ne ""; run;




/***  Pop 33   ***
***  None has soft_palate_implants  ***
* Denominator - Individuals with OSA*
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where OSA=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

Data ccw.pop_33_de; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
proc sort; by bene_id; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_33_de; merge ccw.pop_33_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; run; 

* Numerator - Evidence of a soft tissue implant anytime during the year with the OSA diagnosis *
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where soft_palate_implants=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data ccw.pop_33_nu; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;

Data a; set ccw.pop_33_nu; keep bene_id soft_palate_implants; run; 
proc sort nodupkey; by bene_id; run;
Data b; set ccw.pop_33_de;	run;
proc sort nodupkey; by bene_id; run;

Data ccw.pop_33; merge a b (in=b); by bene_id; if b=1; if soft_palate_implants=. then soft_palate_implants=0; run; 
proc freq; table soft_palate_implants; run; 
Data ccw.pop_33; set ccw.pop_33; length n_de 3; n_de=1; run; proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;

Data ccw.pop_33_zip; merge ccw.pop_33 ccw.zip_crosswalk_2008; by zip_code; 
if soft_palate_implants=. then soft_palate_implants=0; if n_de=. then n_de=0; run;
proc means; var soft_palate_implants n_de; run;

proc sort Data=ccw.pop_33_zip; by HRR; run;
proc summary Data=ccw.pop_33_zip;
by HRR;
output out=ccw.pop_33_hrr sum(soft_palate_implants n_de)=n_nu n_de;
run;

Data ccw.pop_33_hrr; set ccw.pop_33_hrr; drop _freq_ _type_; rate=n_nu/n_de*1000; run;
proc means; var n_nu n_de percent; run; /



/***  Pop 34   ***/
 /* Denominator - Patients with traumatic brain injury*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where traumatic_brain_injury=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

Data ccw.pop_34_de_claim; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
Data ccw.pop_34_de; set ccw.pop_34_de_claim; run;
proc sort nodupkey; by bene_id date_service; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_34_de; merge ccw.pop_34_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_34_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_34_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_34_de_zip; by HRR; run;
proc summary Data=ccw.pop_34_de_zip; by HRR;
output out=ccw.pop_34_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_34_de_hrr; set ccw.pop_34_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - MRI on the same claim as diagnosis if outpatient or during hospitalization if inpatient*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where MRI_brain=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort nodupkey; by type clm_id bene_id date_service; run;
Data b; set ccw.pop_34_de_claim; keep type clm_id bene_id; run;
proc sort nodupkey; by type clm_id bene_id; run;

Data ccw.pop_34_nu; merge a (in=a) b (in=b); by type clm_id bene_id; if a=1 and b=1; run;
proc sort nodupkey; by bene_id date_service; run;
Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_34_nu; merge ccw.pop_34_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_34_nu_zip; merge ccw.pop_34_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_34_nu_zip; by HRR; run;
proc summary Data=ccw.pop_34_nu_zip; by HRR;
output out=ccw.pop_34_nu_hrr sum(MRI_brain)=n_nu; run;

Data ccw.pop_34_nu_hrr; set ccw.pop_34_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_34_hrr; merge ccw.pop_34_nu_hrr ccw.pop_34_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means data=ccw.pop_34_hrr; var n_nu n_de rate; where HRR ne ""; run;




/***  Pop 35   ***/
 /* Denominator - Individuals with DCIS */
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where DCIS=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

Data ccw.pop_35_de; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; length n_de 3; n_de=1; run;
/** proc contents; run; proc means; var date_service; run; **/
proc sort nodupkey; by bene_id date_service; run;

Data ccw.pop_35_de_earliest; set ccw.pop_35_de; by bene_id date_service; if first.bene_id=1; run; 
proc sort nodupkey; by bene_id; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_35_de_earliest; merge ccw.pop_35_de_earliest (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_35_de_zip; merge ccw.pop_35_de_earliest ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_35_de_zip; by HRR; run;
proc summary Data=ccw.pop_35_de_zip; by HRR;
output out=ccw.pop_35_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_35_de_hrr; set ccw.pop_35_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - MRI of chest or breast AFTER the first diagnosis of DCIS*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where MRI_breast=1 or MRI_chest=1; length mri 3; mri=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort; by bene_id; run;
Data b; set ccw.pop_35_de_earliest; keep bene_id date_service; run;
Data b; set b; rename date_service=date_service_de; run;
proc sort nodupkey; by bene_id; run;

Data ccw.pop_35_nu; merge a (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
Data ccw.pop_35_nu; set ccw.pop_35_nu; where date_service>=date_service_de; run;
proc sort nodupkey; by bene_id date_service; run;
Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_35_nu; merge ccw.pop_35_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_35_nu_zip; merge ccw.pop_35_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_35_nu_zip; by HRR; run;
proc summary Data=ccw.pop_35_nu_zip; by HRR;
output out=ccw.pop_35_nu_hrr sum(mri)=n_nu; run;

Data ccw.pop_35_nu_hrr; set ccw.pop_35_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_35_hrr; merge ccw.pop_35_nu_hrr ccw.pop_35_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; where HRR ne ""; run;




/***  Pop 36   ***/
/* Denominator - Men with low risk for prostate CA*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where prostate_ca=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data a; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
/** proc contents; run; proc means; var date_service; run; **/
proc sort; by bene_id date_service; run;

%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where prostate_risk=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data b; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

Data ccw.pop_36_de; merge a (in=a) b (in=b); by bene_id; if a=1 and b=0; length n_de 3; n_de=1; run;
proc sort nodupkey; by bene_id date_service; run;

Data ccw.pop_36_de_earlist; set ccw.pop_36_de; by bene_id date_service; if first.bene_id=1; run; 
proc sort nodupkey; by bene_id; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_36_de_earlist; merge ccw.pop_36_de_earlist (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_36_de_zip; merge ccw.pop_36_de_earlist ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_36_de_zip; by HRR; run;
proc summary Data=ccw.pop_36_de_zip; by HRR;
output out=ccw.pop_36_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_36_de_hrr; set ccw.pop_36_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator – PET, CT or radionuclide bone scan AFTER diagnosis */
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where prostate_scan=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort; by bene_id; run;
Data b; set ccw.pop_36_de; keep bene_id date_service; run;
Data b; set b; rename date_service=date_service_de; run;
proc sort nodupkey; by bene_id; run;

Data ccw.pop_36_nu; merge a (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
Data ccw.pop_36_nu; set ccw.pop_36_nu; where date_service>=date_service_de; run;
proc sort nodupkey; by bene_id date_service; run;

Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_36_nu; merge ccw.pop_36_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_36_nu_zip; merge ccw.pop_36_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_36_nu_zip; by HRR; run;
proc summary Data=ccw.pop_36_nu_zip; by HRR;
output out=ccw.pop_36_nu_hrr sum(pet_scan)=n_nu; run;

Data ccw.pop_36_nu_hrr; set ccw.pop_36_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_36_hrr; merge ccw.pop_36_nu_hrr ccw.pop_36_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; where HRR ne ""; run;




/***  Pop 37   ***/
 /* Denominator - Low back pain diagnosis*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where back_pain=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

Data ccw.pop_37_de; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
proc sort nodupkey; by bene_id date_service; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_37_de; merge ccw.pop_37_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_37_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_37_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_37_de_zip; by HRR; run;
proc summary Data=ccw.pop_37_de_zip; by HRR;
output out=ccw.pop_37_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_37_de_hrr; set ccw.pop_37_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - Traction with diagnosis of low back pain*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where traction=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort; by type clm_id bene_id date_service; run;
Data b; set ccw.pop_37_de; keep type clm_id bene_id; run;
proc sort nodupkey; by type clm_id bene_id; run;

Data ccw.pop_37_nu; merge a (in=a) b (in=b); by type clm_id bene_id; if a=1 and b=1; run;
proc sort nodupkey; by bene_id date_service; run;
Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_37_nu; merge ccw.pop_37_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_37_nu_zip; merge ccw.pop_37_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_37_nu_zip; by HRR; run;
proc summary Data=ccw.pop_37_nu_zip; by HRR;
output out=ccw.pop_37_nu_hrr sum(traction)=n_nu; run;

Data ccw.pop_37_nu_hrr; set ccw.pop_37_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_37_hrr; merge ccw.pop_37_nu_hrr ccw.pop_37_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means data=ccw.pop_37_hrr; var n_nu n_de rate; run;




/***  Pop 38   No denominator has numerator   
* Denominator - patients with heart failure *
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where heart_disease=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

Data ccw.pop_38_de; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
proc sort nodup; by bene_id date_service; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_38_de; merge ccw.pop_37_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_38_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_38_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_38_de_zip; by HRR; run;
proc summary Data=ccw.pop_38_de_zip; by HRR;
output out=ccw.pop_38_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_38_de_hrr; set ccw.pop_38_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

* Numerator - Endomyocardial biopsy *
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where biopsy=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
%Macro type;
Data a_&type; set ccw.kitty_&type; where biopsy=1; run;
%Mend type; %let type=icdproc_outpatient; %type; %let type=proc_MedPAR; %type; %let type=icdproc_outpatient_death; %type; %let type=proc_MedPAR_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death a_icdproc_outpatient a_proc_MedPAR a_icdproc_outpatient_death a_proc_MedPAR_death; run;
proc sort; by type clm_id bene_id; run;
Data b; set ccw.pop_38_de; keep type clm_id bene_id; run;
proc sort nodupkey; by type clm_id bene_id; run;

Data ccw.pop_38_nu; merge a (in=a) b (in=b); by type clm_id bene_id; if a=1 and b=1; run;
proc sort nodupkey; by bene_id date_service; run;
Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_38_nu; merge ccw.pop_38_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_38_nu_zip; merge ccw.pop_38_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_38_nu_zip; by HRR; run;
proc summary Data=ccw.pop_38_nu_zip; by HRR;
output out=ccw.pop_38_nu_hrr sum(biopsy)=n_nu; run;

Data ccw.pop_38_nu_hrr; set ccw.pop_38_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_38_hrr; merge ccw.pop_38_nu_hrr ccw.pop_38_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means data=ccw.pop_38_hrr; var n_nu n_de rate; where HRR ne ""; run; */


/***  Pop 39   ***/
 /* Denominator - Population age 85 and over*/
Data ccw.pop_39_de; set ccw.kitty_beneficiary_summary_file;	where all_85=1; length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_39_de_zip; merge ccw.pop_39_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_39_de_zip; by HRR; run;
proc summary Data=ccw.pop_39_de_zip; by HRR;
output out=ccw.pop_39_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_39_de_hrr; set ccw.pop_39_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

  /* Numerator - Screening for colorectal cancer (ICD and CPT code)*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where colon_screen=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where colon_screen=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data ccw.pop_39_nu; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort nodupkey; by bene_id date_service; run;

Data b; set ccw.pop_39_de; keep bene_id; run;
proc sort nodupkey; by bene_id; run;
proc sort Data=ccw.pop_39_nu; by bene_id; run;

Data ccw.pop_39_nu; merge ccw.pop_39_nu (in=a) b (in=b); if a=1 and b=1; by bene_id; run;

Data b; set ccw.kitty_beneficiary_summary_file;	where all_85=1; keep zip_code bene_id; run;
proc sort nodupkey; by bene_id; run;

Data a; merge ccw.pop_39_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_39_nu_zip; merge a (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_39_nu_zip; by HRR; run;
proc summary Data=ccw.pop_39_nu_zip; by HRR;
output out=ccw.pop_39_nu_hrr sum(colon_screen)=n_nu; run;

Data ccw.pop_39_nu_hrr; set ccw.pop_39_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_39_hrr; merge ccw.pop_39_nu_hrr ccw.pop_39_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; where HRR ne ""; run;



/***  Pop 40   ***/
 /* Denominator - all women minus those with a specific diagnosis*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where pop_40=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data a; set a_icd_carrier a_icd_outpatient a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR a_icd_MedPAR_death; run;
proc sort nodupkey; by bene_id; run;

Data b; set ccw.kitty_beneficiary_summary_file; where women_all=1; length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort; by bene_id; run;
Data ccw.pop_40_de; merge a (in=a) b (in=b); by bene_id; if a=0 and b=1; length n_de 3; n_de=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_40_de_zip; merge ccw.pop_40_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_40_de_zip; by HRR; run;
proc summary Data=ccw.pop_40_de_zip; by HRR;
output out=ccw.pop_40_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_40_de_hrr; set ccw.pop_40_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - Screen for abdominal aortic anuerysm */
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where aaa_screen=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort data=a; by bene_id; run;

Data b; set ccw.pop_40_de; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

Data ccw.pop_40_nu; merge a (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort nodupkey; by bene_id date_service; run;

Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_40_nu; merge ccw.pop_40_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_40_nu_zip; merge ccw.pop_40_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_40_nu_zip; by HRR; run;
proc summary Data=ccw.pop_40_nu_zip; by HRR;
output out=ccw.pop_40_nu_hrr sum(aaa_screen)=n_nu; run;

Data ccw.pop_40_nu_hrr; set ccw.pop_40_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_40_hrr; merge ccw.pop_40_nu_hrr ccw.pop_40_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;



/***  Pop 41   ***/
 /* Denominator - all minus those with a specific diagnosis*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where pop_41=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data a; set a_icd_carrier a_icd_outpatient a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR a_icd_MedPAR_death; run;
proc sort nodupkey; by bene_id; run;

Data b; set ccw.kitty_beneficiary_summary_file; length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort; by bene_id; run;
Data ccw.pop_41_de; merge a (in=a) b (in=b); by bene_id; if a=0 and b=1; length n_de 3; n_de=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_41_de_zip; merge ccw.pop_41_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_41_de_zip; by HRR; run;
proc summary Data=ccw.pop_41_de_zip; by HRR;
output out=ccw.pop_41_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_41_de_hrr; set ccw.pop_41_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

  /* Numerator - Screening for asymptomatic artery stenosis (CPT 93880 or 3100F, ONLY IN outpatient setting (not ER))*/

%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where (carotid_ultrasound=1 or carotid_image=1) AND er_pos=0; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
 
Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; n_nu=1; run;
proc sort data=a; by type clm_id bene_id; run;

%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where er_visit=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
Data er_visit; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; keep type clm_id bene_id; run;
proc sort nodupkey; by type clm_id bene_id; run;


Data b; merge a (in=a) er_visit (in=b); by type clm_id bene_id; if a=1 and b=0; run;
proc sort; by bene_id; run;

Data c; set ccw.pop_41_de; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

Data ccw.pop_41_nu; merge b (in=b) c (in=c); by bene_id; if b=1 and c=1; run;
proc sort nodupkey; by bene_id date_service; run;

Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_41_nu; merge ccw.pop_41_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_41_nu_zip; merge ccw.pop_41_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_41_nu_zip; by HRR; run;
proc summary Data=ccw.pop_41_nu_zip; by HRR;
output out=ccw.pop_41_nu_hrr sum(n_nu)=n_nu; run;

Data ccw.pop_41_nu_hrr; set ccw.pop_41_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_41_hrr; merge ccw.pop_41_nu_hrr ccw.pop_41_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;


/***  Pop 42 - NOT CODED  ***/


/***  Pop 43   ***/
  /* Denominator - All with anesthesia code excluding certain diagnoses*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where pop_43=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data a; set a_icd_carrier a_icd_outpatient a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR a_icd_MedPAR_death; run;
proc sort nodupkey; by bene_id; run;
*Exclude these patients;

%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where anesthesia=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
Data b; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort data=b; by bene_id; run;

Data c; merge a (in=a) b (in=b); by bene_id; if a=0 and b=1; length n_de 3; n_de=1; run; 
proc sort nodupkey; by bene_id date_service; run;

Data d; set ccw.kitty_beneficiary_summary_file; length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort data=d; by bene_id; run;
Data ccw.pop_43_de; merge c (in=c) d (in=d); by bene_id; if c=1; length n_de 3; n_de=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_43_de_zip; merge ccw.pop_43_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_43_de_zip; by HRR; run;
proc summary Data=ccw.pop_43_de_zip; by HRR;
output out=ccw.pop_43_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_43_de_hrr; set ccw.pop_43_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - Chest radiography 30 days before anesthesia*/

%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where radiology=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort; by bene_id; run;

Data b; set ccw.pop_43_de; keep bene_id date_service; run;
Data b; set b; rename date_service=date_service_de; run;
proc sort; by bene_id; run;

***  many-to-many merge  ***;
proc sql; create table c as  select *  from a a, b b  where a.bene_id=b.bene_id; quit;
proc contents; run;

Data ccw.pop_43_nu; set c; where date_service_de-date_service>=0 and date_service_de-date_service<=30; run;
proc sort nodupkey; by bene_id date_service; run;
Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_43_nu; merge ccw.pop_43_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_43_nu_zip; merge ccw.pop_43_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_43_nu_zip; by HRR; run;
proc summary Data=ccw.pop_43_nu_zip; by HRR;
output out=ccw.pop_43_nu_hrr sum(radiology)=n_nu; run;

Data ccw.pop_43_nu_hrr; set ccw.pop_43_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_43_hrr; merge ccw.pop_43_nu_hrr ccw.pop_43_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;



/***  Pop 44 - NOT CODED  ***/



/***  Pop 45   ***/
  /* Denominator - Women with breast cancer diagnosis*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where breast_cancer=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data a; set a_icd_carrier a_icd_outpatient a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR a_icd_MedPAR_death; run;

proc sort data=a nodupkey; by bene_id; run;

Data b; set ccw.kitty_beneficiary_summary_file; where women_all=1; length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort; by bene_id; run;
Data ccw.pop_45_de; merge a (in=a) b (in=b); by bene_id; if a=1 and b=1; length n_de 3; n_de=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_45_de_zip; merge ccw.pop_45_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_45_de_zip; by HRR; run;
proc summary Data=ccw.pop_45_de_zip; by HRR;
output out=ccw.pop_45_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_45_de_hrr; set ccw.pop_45_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

  /* Numerator - Tumor marker studies*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where tumor_marker=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort Data=a; by bene_id; run;

Data b; set ccw.pop_45_de; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

Data ccw.pop_45_nu; merge a (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort nodupkey; by bene_id date_service; run;

Data b; set ccw.kitty_beneficiary_summary_file; keep zip_code bene_id; run;
proc sort nodupkey; by bene_id; run;

Data a; merge ccw.pop_45_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_45_nu_zip; merge a (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_45_nu_zip; by HRR; run;
proc summary Data=ccw.pop_45_nu_zip; by HRR;
output out=ccw.pop_45_nu_hrr sum(tumor_marker)=n_nu; run;

Data ccw.pop_45_nu_hrr; set ccw.pop_45_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_45_hrr; merge ccw.pop_45_nu_hrr ccw.pop_45_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;



/***  Pop 46   ***/
  /* Denominator – Individuals with allergy diagnosis (477.0, 477.1, 477.2, 477.8, 477.9, 493.0, 493.02, 493.9, 493.90, 493.92, 708.0, 995.3)*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where allergy=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data ccw.pop_46_de_claim; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
Data ccw.pop_46_de; set ccw.pop_46_de_claim; run;
proc sort nodupkey; by bene_id date_service; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_46_de; merge ccw.pop_46_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_46_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_46_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_46_de_zip; by HRR; run;
proc summary Data=ccw.pop_46_de_zip; by HRR;
output out=ccw.pop_46_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_46_de_hrr; set ccw.pop_46_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - Use of CPT 82701, 82784, 82785, 82787, 86005 on the same claim as a code for diagnoses in the denominator column */
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where allergy_test46=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort; by type clm_id bene_id; run;
Data b; set ccw.pop_46_de_claim; keep type clm_id bene_id; run;
proc sort nodupkey; by type clm_id bene_id; run;

Data ccw.pop_46_nu; merge a (in=a) b (in=b); by type clm_id bene_id; if a=1 and b=1; run;
proc sort nodupkey; by bene_id date_service; run;
Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_46_nu; merge ccw.pop_46_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_46_nu_zip; merge ccw.pop_46_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_46_nu_zip; by HRR; run;
proc summary Data=ccw.pop_46_nu_zip; by HRR;
output out=ccw.pop_46_nu_hrr sum(allergy_test46)=n_nu; run;

Data ccw.pop_46_nu_hrr; set ccw.pop_46_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_46_hrr; merge ccw.pop_46_nu_hrr ccw.pop_46_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means data=ccw.pop_46_hrr; var n_nu n_de rate; run;



/***  Pop 47   ***/
  /* Denominator – 461.0, 461.1, 461.2, 461.3, 461.8, 461.9 AND NO code in the preceding 3 months for any of these AND NO code in the preceding 3 months for 473.0, 473.1, 473.2, 473.3, 473.8, 473.9*/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where acute_sinusitis=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data a; set a_icd_carrier a_icd_outpatient a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR a_icd_MedPAR_death; run;
proc sort nodupkey; by bene_id date_service;  run;
Data a; set a; rename date_service=date_service_de; run;
proc sort; by bene_id; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where chronic_sinusitis=1 OR acute_sinusitis=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data b; set a_icd_carrier a_icd_outpatient a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR a_icd_MedPAR_death; run;
proc sort nodupkey; by bene_id date_service;  run;

***  Left join merge  ***;
proc sql; create table c as  select *  from a a left join b b  on a.bene_id=b.bene_id; quit;
Data d; set c; where 0 < date_service_de-date_service and date_service_de-date_service <= 92; run;
proc sort nodupkey; by bene_id date_service_de; run;
Data e; set d; keep bene_id date_service_de; run;

Data f; merge a (in=a) e (in=b); by bene_id date_service_de; if a=1 and b=0; length n_de 3; n_de=1; run;
proc sort nodupkey; by bene_id date_service_de; run;

Data g; set ccw.kitty_beneficiary_summary_file; keep zip_code bene_id; run;
proc sort; by bene_id; run;
Data ccw.pop_47_de; merge f (in=d) g (in=e); by bene_id; if d=1; length n_de 3; n_de=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_47_de_zip; merge ccw.pop_47_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_47_de_zip; by HRR; run;
proc summary Data=ccw.pop_47_de_zip; by HRR;
output out=ccw.pop_47_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_47_de_hrr; set ccw.pop_47_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator - Any occurrence of sinus CT (CPT 70486, 70487, 70488) in the 3 months preceding the diagnosis of acute sinusitis */
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where sinus_ct=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort nodupkey; by bene_id date_service;  run;

Data b; set ccw.pop_47_de; keep bene_id date_service_de; run;
proc sort; by bene_id; run;

***  many-to-many merge  ***;
proc sql; create table c as  select *  from a a, b b  where a.bene_id=b.bene_id; quit;

Data ccw.pop_47_nu; set c; where date_service_de-date_service >=0 and date_service_de-date_service <=92; run;
proc sort nodupkey; by bene_id date_service;  run;
Data d; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_47_nu; merge ccw.pop_47_nu (in=a) d; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_47_nu_zip; merge ccw.pop_47_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_47_nu_zip; by HRR; run;
proc summary Data=ccw.pop_47_nu_zip; by HRR;
output out=ccw.pop_47_nu_hrr sum(sinus_ct)=n_nu; run;

Data ccw.pop_47_nu_hrr; set ccw.pop_47_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_47_hrr; merge ccw.pop_47_nu_hrr ccw.pop_47_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;



/***  Pop 48   ***/
  /* Denominator – 4052F, 4053F, 4054F AND diabetes (250.xx)*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where dialysis=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort nodupkey; by bene_id; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where diabetes=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data b; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
proc sort nodupkey; by bene_id; run;

Data ccw.pop_48_de; merge a (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort nodupkey; by bene_id; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_48_de; merge ccw.pop_48_de (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_48_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_48_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_48_de_zip; by HRR; run;
proc summary Data=ccw.pop_48_de_zip; by HRR;
output out=ccw.pop_48_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_48_de_hrr; set ccw.pop_48_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

  /* Numerator – Cancer screenings (colon:  G0105, G0120, G0121, 45379-45385, V76.51; prostate:  84152, 84153, 84154, G0103; Cervical:  3015F, 88141, 88142, 88143, 88147, 88148, 88150, 88152, 88153, 88154, HCPCS: Q0091; Mammo: 77057, G0202) */
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where cancer_screen=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where colon_screenICD=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data ccw.pop_48_nu; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; length n_nu 3; n_nu=1; run;
proc sort nodupkey; by bene_id date_service; run;
Data b; set ccw.pop_48_de;	keep zip_code bene_id; run;
proc sort nodupkey; by bene_id; run;

Data ccw.pop_48_nu; merge ccw.pop_48_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_48_nu_zip; merge ccw.pop_48_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_48_nu_zip; by HRR; run;
proc summary Data=ccw.pop_48_nu_zip; by HRR;
output out=ccw.pop_48_nu_hrr sum(n_nu)=n_nu; run;

Data ccw.pop_48_nu_hrr; set ccw.pop_48_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_48_hrr; merge ccw.pop_48_nu_hrr ccw.pop_48_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;




/***  Pop 49   ***/
  /* Denominator – MRI of the lumbar spine studies with a diagnosis of low back pain on the imaging claim.
CPT=72148, or 72149, or 72158  AND  ICD-9: 721.3, 721.90, 722.10, 722.52, 722.6, 722.93, 724.02, 724.2 ,  724.3, 724.5, 724.6, 724.70, 724.71, 724.79,  738.5, 739.3, 739.4, 846.0, 846.1, 846.2, 846.3, 846.8, 846.9 , 847.2 "
Excluded from the denominator - CPT codes: 22010-22865 and 22899 in  90 days preceding MRI; ICD-9 codes: 140-208, 230-234, 235-239,  304.0X, 304.1X, 304.2X, 304.4X, 305.4X, 305.5X, 305.6X, 305.7X, 344.60, 344.61, 729.2, 042-044, 279.3 in preceding 365 days;  800-839, 850-854, 860-869, 905-909, 926.11, 926.12, 929, 952, 958-959 in preceding 45 days; 324.9, 324.1 on same claim ID as MRI of the lumbar spine*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where lumbar_mri=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort; by type clm_id bene_id; run;
Data a; set a; rename date_service=date_mri; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where back_pain=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

Data b; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
proc sort; by type clm_id bene_id; run;

Data c; merge a (in=a) b (in=b); by type clm_id bene_id; if a=1 and b=1; run;
proc sort nodupkey; by type bene_id clm_id; run;

*Exclusions;
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where lumbar_surgery=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data surgery90days; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort nodupkey; by bene_id date_service;  run;
Data surgery90days; set surgery90days; rename date_service=date_surgery;run;
proc sort; by bene_id; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where pop49=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

Data pop49_year; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
proc sort nodupkey; by bene_id date_service;  run;
Data pop49_year; set pop49_year; rename date_service=date_pop49;run;
proc sort; by bene_id; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where trauma=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

Data trauma45days; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
proc sort nodupkey; by bene_id date_service;  run;
Data trauma45days; set trauma45days; rename date_service=date_trauma;run;
proc sort; by bene_id; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where intraspinal_abcess=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

Data abcess_clm; set a_icd_carrier a_icd_outpatient a_icd_MedPAR a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR_death; run;
proc sort nodupkey; by type clm_id bene_id; run;

data dates; set surgery90days pop49_year trauma45days; run;

***  Left join merge  ***;
proc sql; create table d as  select *  from c c left join dates d  on c.bene_id=d.bene_id; quit;
Data e; set d; where (date_mri-date_surgery>=0 and date_mri-date_surgery<=90) OR (date_mri-date_pop49>=0 and date_mri-date_pop49<=365) OR (date_mri-date_trauma>=0 AND date_mri-date_trauma<=45); run;
proc sort nodupkey; by bene_id date_mri; run;

proc sort data=c nodupkey; by type clm_id bene_id; run;
Data f; merge c (in=c) abcess_clm (in=f); by type clm_id bene_id; if c=1 and f=0; run;
proc sort nodupkey; by bene_id date_mri; run;

Data f; merge f (in=f) e (in=e); by bene_id date_mri; if f=1 and e=0; run;

Data g; set ccw.kitty_beneficiary_summary_file; length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort; by bene_id; run;
proc sort data=f; by bene_id; run;
Data ccw.pop_49_de; merge f (in=f) g (in=g); by bene_id; if f=1; length n_de 3; n_de=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_49_de_zip; merge ccw.pop_49_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_49_de_zip; by HRR; run;
proc summary Data=ccw.pop_49_de_zip; by HRR;
output out=ccw.pop_49_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_49_de_hrr; set ccw.pop_49_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;


  /* Numerator – MRI of the lumbar spine studies with a diagnosis of low back pain (from the denominator) without the patient having claims-based evidence of prior antecedent conservative therapy.
CPT=72148, or 72149, or 72158 with no codes for 97110, 97112, 97113, 97124, 97140, 98940, 98941,98942,98943 in the 60 days preceding the MRI of the lumbar spine AND no codes for 99201-99205,99211 -99215,99241-99245, 99341-99345,99347-99350,99354-99357,99385-99387,99395-99397 , 99401-99404,99455-99456,99499 between 28 and 60 days preceding the MRI of the lumbar spine*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where therapies=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data therapies; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort nodupkey; by bene_id date_service;  run;
Data therapies; set therapies; rename date_service=date_therapies;run;
proc sort; by bene_id; run;

%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where evaluations=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data evals; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort nodupkey; by bene_id date_service;  run;
Data evals; set evals; rename date_service=date_evals;run;
proc sort; by bene_id; run;
data a; set therapies evals; run;
data b; set ccw.pop_49_de; run;

***  Left join merge  ***;
proc sql; create table c as  select *  from b b left join a a on b.bene_id=a.bene_id; quit;
Data d; set c; where (date_mri-date_therapies>=0 and date_mri-date_therapies <=60) OR (date_mri-date_evals>=28 and date_mri-date_evals<=60); run;
proc sort nodupkey; by bene_id date_mri; run;

proc sort data=b nodupkey; by bene_id date_mri; run;
proc sort data=c nodupkey; by bene_id date_mri; run;
Data ccw.pop_49_nu; merge d (in=d) c (in=c); by bene_id date_mri; if c=1 and d=0; length n_de 3; n_nu=1; run;
proc sort nodupkey; by bene_id date_mri; run;

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_49_nu_zip; merge ccw.pop_49_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_49_nu_zip; by HRR; run;
proc summary Data=ccw.pop_49_nu_zip; by HRR;
output out=ccw.pop_49_nu_hrr sum(lumbar_mri)=n_nu; run;

Data ccw.pop_49_nu_hrr; set ccw.pop_49_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_49_hrr; merge ccw.pop_49_nu_hrr ccw.pop_49_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means Data=ccw.pop_49_hrr; var n_nu n_de rate; run;




/***  Pop 50   ***/
  /* Denominator –  The number of thorax CT studies with and without contrast (“combined studies”). CPT 71250, 71260, 71270*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where thorax_ct=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort nodupkey; by bene_id date_service; run;
proc sort data=ccw.kitty_beneficiary_summary_file; by bene_id; run;
Data ccw.pop_50_de; merge a (in=a) ccw.kitty_beneficiary_summary_file; by bene_id; if a=1; length n_de 3; n_de=1; run; 

Data a; set ccw.pop_50_de; keep bene_id zip_code n_de; run;
proc sort; by zip_code; run;

proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_50_de_zip; merge a ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_50_de_zip; by HRR; run;
proc summary Data=ccw.pop_50_de_zip; by HRR;
output out=ccw.pop_50_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_50_de_hrr; set ccw.pop_50_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

  /* Numerator – The number of thorax CT studies performed (with contrast, without contrast or both with and without contrast). CPT 71270*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where thorax_contrast=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data ccw.pop_50_nu; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort nodupkey; by bene_id date_service; run;
Data b; set ccw.pop_50_de;  keep zip_code bene_id n_de; run;
proc sort nodupkey; by bene_id; run;

Data ccw.pop_50_nu; merge ccw.pop_50_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_50_nu_zip; merge ccw.pop_50_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_50_nu_zip; by HRR; run;
proc summary Data=ccw.pop_50_nu_zip; by HRR;
output out=ccw.pop_50_nu_hrr sum(thorax_contrast)=n_nu; run;

Data ccw.pop_50_nu_hrr; set ccw.pop_50_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_50_hrr; merge ccw.pop_50_nu_hrr ccw.pop_50_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;



/***  Pop 51  ***/
  /* Denominator – The number of Abdomen CT studies performed (with contrast, without contrast or both with and without contrast). CPT 74150, 74160, 74170, Excluding some diagnoses if on the same claim ID*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where abdomen_ct=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort nodupkey; by type clm_id bene_id; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where pop51=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data b; set a_icd_carrier a_icd_outpatient a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR a_icd_MedPAR_death; run;
proc sort; by type clm_id bene_id; run;

Data c; merge a (in=a) b (in=b); by type clm_id bene_id; if a=1 and b=0; run;
proc sort nodupkey; by bene_id date_service; run;

Data d; set ccw.kitty_beneficiary_summary_file; length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort data=d; by bene_id; run;
Data ccw.pop_51_de; merge c (in=c) d (in=d); by bene_id; if c=1; length n_de 3; n_de=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_51_de_zip; merge ccw.pop_51_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_51_de_zip; by HRR; run;
proc summary Data=ccw.pop_51_de_zip; by HRR;
output out=ccw.pop_51_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_51_de_hrr; set ccw.pop_51_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

  /* Numerator – The number of Abdomen CT studies with and without contrast (“combined studies”).
CPT 74170*/
%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where abdomen_contrast=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data ccw.pop_51_nu; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;

Data b; set ccw.pop_51_de; keep bene_id; run;
proc sort nodupkey; by bene_id; run;
proc sort Data=ccw.pop_51_nu; by bene_id; run;

Data ccw.pop_51_nu; merge ccw.pop_51_nu (in=a) b (in=b); if a=1 and b=1; by bene_id; run;
proc sort nodupkey; by bene_id date_service; run;

Data b; set ccw.pop_51_de;  keep zip_code bene_id n_de; run;
proc sort nodupkey; by bene_id; run;

Data a; merge ccw.pop_51_nu (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_51_nu_zip; merge a (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_51_nu_zip; by HRR; run;
proc summary Data=ccw.pop_51_nu_zip; by HRR;
output out=ccw.pop_51_nu_hrr sum(abdomen_contrast)=n_nu; run;

Data ccw.pop_51_nu_hrr; set ccw.pop_51_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_51_hrr; merge ccw.pop_51_nu_hrr ccw.pop_51_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;





/***  Pop 52   ***/
  /* Denominator – Brain CT studies. CPT 70450, 70460, 70470
Denominator Time Window: Any day within a one-year window of claims data.
Exclude from the denominator if on the same claim as CPT 70450,70460,70470 - ICD-9  140-239, 800-839, 850-854, 860-869, 905-909, 926.11, 926.12, 929, 952, 958-959, 376.01, 324.0 */

%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where brain_ct=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort nodupkey; by type clm_id bene_id; run;

%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where pop52=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data b; set a_icd_carrier a_icd_outpatient a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR a_icd_MedPAR_death; run;
proc sort; by type clm_id bene_id; run;

Data c; merge a (in=a) b (in=b); by type clm_id bene_id; if a=1 and b=0; run;
proc sort nodupkey; by bene_id date_service; run;

Data d; set ccw.kitty_beneficiary_summary_file; length n_de 3; n_de=1; keep zip_code bene_id n_de; run;
proc sort data=d; by bene_id; run;
Data ccw.pop_52_de; merge c (in=c) d (in=d); by bene_id; if c=1; length n_de 3; n_de=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_52_de_zip; merge ccw.pop_52_de ccw.zip_crosswalk_2008; by zip_code; if n_de=. then n_de=0; run;
proc means; var n_de; run;

proc sort Data=ccw.pop_52_de_zip; by HRR; run;
proc summary Data=ccw.pop_52_de_zip; by HRR;
output out=ccw.pop_52_de_hrr sum(n_de)=n_de; run;

Data ccw.pop_52_de_hrr; set ccw.pop_52_de_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_de; run;

  /* Numerator – Of studies identified in the denominator, studies with a simultaneous Sinus CT study (i.e., on the same date, at the same facility as the Brain CT). CPT 70450, 70460, 70470 AND THE SAME DAY CPT 70486, 70487, 70488
Numerator Time Window: Same date as the imaging procedure counted in the denominator.*/

%Macro type;
Data a_proc_&type; set ccw.kitty_proc_&type; where sinus_ct=1; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;

Data a; set a_proc_carrier a_proc_op_rc a_proc_carrier_death a_proc_op_rc_death; run;
proc sort; by bene_id; run;
 Data b; set ccw.pop_52_de; rename date_service= date_service_de; run;
proc sort; by bene_id date_service_de; run;

Data ccw.pop_52_nu; merge a (in=a) b (in=b); by bene_id; if a=1 and b=1; run;
Data ccw.pop_52_nu; set ccw.pop_52_nu; where date_service=date_service_de; run;

proc sort nodupkey; by bene_id date_service; run;
Data a; set ccw.kitty_beneficiary_summary_file; keep bene_id zip_code; run;
proc sort; by bene_id; run;
Data ccw.pop_52_nu; merge ccw.pop_52_nu (in=a) a; by bene_id; if a=1; run; 

proc sort; by zip_code; run;
proc sort data=ccw.zip_crosswalk_2008; by zip_code; run;
Data ccw.pop_52_nu_zip; merge ccw.pop_52_nu (in=a) ccw.zip_crosswalk_2008; by zip_code; if a=1; run; 

proc sort Data=ccw.pop_52_nu_zip; by HRR; run;
proc summary Data=ccw.pop_52_nu_zip; by HRR;
output out=ccw.pop_52_nu_hrr sum(sinus_ct)=n_nu; run;

Data ccw.pop_52_nu_hrr; set ccw.pop_52_nu_hrr; drop _freq_ _type_; run;
proc sort; by hrr; run; proc means; var n_nu; run;

Data ccw.pop_52_hrr; merge ccw.pop_52_nu_hrr ccw.pop_52_de_hrr; by HRR; 
if n_nu=. then n_nu=0; if n_de=. then n_de=0; rate=1000*n_nu/n_de; run;
proc means; var n_nu n_de rate; run;



/***  Tardive Dyskinesia   ***/
%Macro type;
Data a_icd_&type; set ccw.kitty_icd_&type; where tardive_dyskinesia=1; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;
Data ccw.jodi_tardive_dyskinesia; set a_icd_carrier a_icd_outpatient a_icd_carrier_death a_icd_outpatient_death a_icd_MedPAR a_icd_MedPAR_death; run;
proc sort nodupkey; by bene_id date_service;  run;

