*Pop 1 denom: ACS in inpatient (icd or drg) OR ACS in outpatient ED (icd only);
*Pop 1 num: electrocardiogram based on hcpcs in inpatient, outpatient or carrier;

*all codes needed for pop 1;
%let pop1_hcpcs='93350', '93351', 'C8928', 'C8930'; *Stress Echocardiography performed;
%let pop1_hcpcs_ed='99281', '99282', '99283', '99284', '99285';*hcpcs indicating emergency room visit;
%let pop1_rev_ed='0450','0451','0452','0456','0459','0981';*revenue center indicating emergency room visit https://www.resdac.org/cms-data/variables/revenue-center-code-ffs;
%let pop1_icd_dx9='4111', '41181', '41189';
%let pop1_icd_dx9_3='410';
%let pop1_icd_dx10='I200','I240','I248';*crosswalk of icd-9 to 10 with descriptions at bottom of program;
%let pop1_icd_dx10_3='I21';
%let pop1_drg='281', '282', '283', '284', '285', '286', '287';


*all variables needed for pop 1;
*if your facility uses a different variable from the one on the left, enter in your variable on the right;
	*e.g., if you use pt_id instead of bene_id change to %let bene_id=pt_id;
/*
%let bene_id=bene_id; *patient level indicator;
%let clm_id=clm_id; *claim level indicator;
%let clm_admsn_dt=clm_admsn_dt; *inpatient date of admission;
%let clm_thru_dt=clm_thru_dt; *common end date for inpatient, outpatient, carrier files;
%let gndr_cd=gndr_cd; *male/sex/ indicator;
%let bene_race_cd=bene_race_cd; *race/ethnicity code for patient;
%let bene_cnty_cd=bene_cnty_cd; *patient county code;
%let bene_state_cd=bene_state_cd;*patient state code;
%let bene_mlg_cntct_zip_cd =bene_mlg_cntct_zip_cd; *patient zip code;
%let prvdr_num=prvdr_num; *hospital id; 
%let prvdr_state_cd=prvdr_state_cd; *hospital state;
%let clm_fac_type_cd=clm_fac_type_cd; *type of facility;**1=hospital, 8=special facility or ASC surgery data dictionary https://www.resdac.org/cms-data/variables/claim-facility-type-code-ffs;
%let clm_ip_admsn_type_cd=clm_ip_admsn_type_cd; *type of inpatient admission;
%let at_physn_npi=at_physn_npi; *attending physician npi;
%let op_physn_npi=op_physn_npi; *operating physician npi;
%let org_npi_num=org_npi_num; *organization npi number;
%let ot_physn_npi=ot_physn_npi; *other physician npi number;
%let rndrng_physn_npi=rndrng_physn_npi; *rendering physician npi;
%let clm_drg_cd=clm_drg_cd; *drg code;
%let icd_dgns_cd1=icd_dgns_cd1; *first icd dx code;
%let icd_dgns_cd25=icd_dgns_cd25; *last icd dx code;
%let dob_dt=dob_dt; *patient date of birth;
%let clm_from_dt=clm_from_dt; *outpatient date of service--changed into clm_admsn_dt in the program for merging to inpatient;
*/
*denominator for inpatient;
%macro inp_claims(source=, include_cohort=);
data &include_cohort
(keep =  pop_01_elig pop_01_age pop_01_year pop_01_setting
		bene_id clm_id clm_admsn_dt clm_thru_dt gndr_cd bene_race_cd bene_cnty_cd bene_state_cd bene_mlg_cntct_zip_cd  
		prvdr_num prvdr_state_cd clm_fac_type_cd clm_ip_admsn_type_cd 
		at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi);
length pop_01_elig 3;
set &source;
where clm_fac_type_cd in('1');*1=hospital https://www.resdac.org/cms-data/variables/claim-facility-type-code-ffs;
*DRG code qualifying;
if clm_drg_cd in(&pop1_drg) then pop1=1;
*DX code qualifying;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
do j=1 to 25;
	if substr(dx(j),1,3) in(&pop1_icd_dx9_3) then do; pop1=1; end;
	if dx(j) in(&pop1_icd_dx9) then do; pop1=1; end;
end;
if pop1 ne 1 then delete;
pop_01_elig=1;
pop_01_age=(clm_admsn_dt-dob_dt)/365.25;
pop_01_age=round(pop_01_age);
pop_01_year=year(clm_admsn_dt);
pop_01_setting='inp';
run;
proc sort data=&include_cohort NODUPKEY;by bene_id clm_admsn_dt;run;
%mend;
%inp_claims(source=rif2010.inpatient_claims_01, include_cohort=pop_01_INdenom_2010_1);
%inp_claims(source=rif2010.inpatient_claims_02, include_cohort=pop_01_INdenom_2010_2);
%inp_claims(source=rif2010.inpatient_claims_03, include_cohort=pop_01_INdenom_2010_3);
%inp_claims(source=rif2010.inpatient_claims_04, include_cohort=pop_01_INdenom_2010_4);
%inp_claims(source=rif2010.inpatient_claims_05, include_cohort=pop_01_INdenom_2010_5);
%inp_claims(source=rif2010.inpatient_claims_06, include_cohort=pop_01_INdenom_2010_6);
%inp_claims(source=rif2010.inpatient_claims_07, include_cohort=pop_01_INdenom_2010_7);
%inp_claims(source=rif2010.inpatient_claims_08, include_cohort=pop_01_INdenom_2010_8);
%inp_claims(source=rif2010.inpatient_claims_09, include_cohort=pop_01_INdenom_2010_9);
%inp_claims(source=rif2010.inpatient_claims_10, include_cohort=pop_01_INdenom_2010_10);
%inp_claims(source=rif2010.inpatient_claims_11, include_cohort=pop_01_INdenom_2010_11);
%inp_claims(source=rif2010.inpatient_claims_12, include_cohort=pop_01_INdenom_2010_12);
%inp_claims(source=rif2011.inpatient_claims_01, include_cohort=pop_01_INdenom_2011_1);
%inp_claims(source=rif2011.inpatient_claims_02, include_cohort=pop_01_INdenom_2011_2);
%inp_claims(source=rif2011.inpatient_claims_03, include_cohort=pop_01_INdenom_2011_3);
%inp_claims(source=rif2011.inpatient_claims_04, include_cohort=pop_01_INdenom_2011_4);
%inp_claims(source=rif2011.inpatient_claims_05, include_cohort=pop_01_INdenom_2011_5);
%inp_claims(source=rif2011.inpatient_claims_06, include_cohort=pop_01_INdenom_2011_6);
%inp_claims(source=rif2011.inpatient_claims_07, include_cohort=pop_01_INdenom_2011_7);
%inp_claims(source=rif2011.inpatient_claims_08, include_cohort=pop_01_INdenom_2011_8);
%inp_claims(source=rif2011.inpatient_claims_09, include_cohort=pop_01_INdenom_2011_9);
%inp_claims(source=rif2011.inpatient_claims_10, include_cohort=pop_01_INdenom_2011_10);
%inp_claims(source=rif2011.inpatient_claims_11, include_cohort=pop_01_INdenom_2011_11);
%inp_claims(source=rif2011.inpatient_claims_12, include_cohort=pop_01_INdenom_2011_12);

%inp_claims(source=rif2012.inpatient_claims_01, include_cohort=pop_01_INdenom_2012_1);
%inp_claims(source=rif2012.inpatient_claims_02, include_cohort=pop_01_INdenom_2012_2);
%inp_claims(source=rif2012.inpatient_claims_03, include_cohort=pop_01_INdenom_2012_3);
%inp_claims(source=rif2012.inpatient_claims_04, include_cohort=pop_01_INdenom_2012_4);
%inp_claims(source=rif2012.inpatient_claims_05, include_cohort=pop_01_INdenom_2012_5);
%inp_claims(source=rif2012.inpatient_claims_06, include_cohort=pop_01_INdenom_2012_6);
%inp_claims(source=rif2012.inpatient_claims_07, include_cohort=pop_01_INdenom_2012_7);
%inp_claims(source=rif2012.inpatient_claims_08, include_cohort=pop_01_INdenom_2012_8);
%inp_claims(source=rif2012.inpatient_claims_09, include_cohort=pop_01_INdenom_2012_9);
%inp_claims(source=rif2012.inpatient_claims_10, include_cohort=pop_01_INdenom_2012_10);
%inp_claims(source=rif2012.inpatient_claims_11, include_cohort=pop_01_INdenom_2012_11);
%inp_claims(source=rif2012.inpatient_claims_12, include_cohort=pop_01_INdenom_2012_12);

%inp_claims(source=rif2013.inpatient_claims_01, include_cohort=pop_01_INdenom_2013_1);
%inp_claims(source=rif2013.inpatient_claims_02, include_cohort=pop_01_INdenom_2013_2);
%inp_claims(source=rif2013.inpatient_claims_03, include_cohort=pop_01_INdenom_2013_3);
%inp_claims(source=rif2013.inpatient_claims_04, include_cohort=pop_01_INdenom_2013_4);
%inp_claims(source=rif2013.inpatient_claims_05, include_cohort=pop_01_INdenom_2013_5);
%inp_claims(source=rif2013.inpatient_claims_06, include_cohort=pop_01_INdenom_2013_6);
%inp_claims(source=rif2013.inpatient_claims_07, include_cohort=pop_01_INdenom_2013_7);
%inp_claims(source=rif2013.inpatient_claims_08, include_cohort=pop_01_INdenom_2013_8);
%inp_claims(source=rif2013.inpatient_claims_09, include_cohort=pop_01_INdenom_2013_9);
%inp_claims(source=rif2013.inpatient_claims_10, include_cohort=pop_01_INdenom_2013_10);
%inp_claims(source=rif2013.inpatient_claims_11, include_cohort=pop_01_INdenom_2013_11);
%inp_claims(source=rif2013.inpatient_claims_12, include_cohort=pop_01_INdenom_2013_12);

%inp_claims(source=rif2014.inpatient_claims_01, include_cohort=pop_01_INdenom_2014_1);
%inp_claims(source=rif2014.inpatient_claims_02, include_cohort=pop_01_INdenom_2014_2);
%inp_claims(source=rif2014.inpatient_claims_03, include_cohort=pop_01_INdenom_2014_3);
%inp_claims(source=rif2014.inpatient_claims_04, include_cohort=pop_01_INdenom_2014_4);
%inp_claims(source=rif2014.inpatient_claims_05, include_cohort=pop_01_INdenom_2014_5);
%inp_claims(source=rif2014.inpatient_claims_06, include_cohort=pop_01_INdenom_2014_6);
%inp_claims(source=rif2014.inpatient_claims_07, include_cohort=pop_01_INdenom_2014_7);
%inp_claims(source=rif2014.inpatient_claims_08, include_cohort=pop_01_INdenom_2014_8);
%inp_claims(source=rif2014.inpatient_claims_09, include_cohort=pop_01_INdenom_2014_9);
%inp_claims(source=rif2014.inpatient_claims_10, include_cohort=pop_01_INdenom_2014_10);
%inp_claims(source=rif2014.inpatient_claims_11, include_cohort=pop_01_INdenom_2014_11);
%inp_claims(source=rif2014.inpatient_claims_12, include_cohort=pop_01_INdenom_2014_12);

%inp_claims(source=rif2015.inpatient_claims_01, include_cohort=pop_01_INdenom_2015_1);
%inp_claims(source=rif2015.inpatient_claims_02, include_cohort=pop_01_INdenom_2015_2);
%inp_claims(source=rif2015.inpatient_claims_03, include_cohort=pop_01_INdenom_2015_3);
%inp_claims(source=rif2015.inpatient_claims_04, include_cohort=pop_01_INdenom_2015_4);
%inp_claims(source=rif2015.inpatient_claims_05, include_cohort=pop_01_INdenom_2015_5);
%inp_claims(source=rif2015.inpatient_claims_06, include_cohort=pop_01_INdenom_2015_6);
%inp_claims(source=rif2015.inpatient_claims_07, include_cohort=pop_01_INdenom_2015_7);
%inp_claims(source=rif2015.inpatient_claims_08, include_cohort=pop_01_INdenom_2015_8);
%inp_claims(source=rif2015.inpatient_claims_09, include_cohort=pop_01_INdenom_2015_9);
%inp_claims(source=rif2015.inpatient_claims_10, include_cohort=pop_01_INdenom_2015_10);
%inp_claims(source=rif2015.inpatient_claims_11, include_cohort=pop_01_INdenom_2015_11);
%inp_claims(source=rif2015.inpatient_claims_12, include_cohort=pop_01_INdenom_2015_12);

%inp_claims(source=rif2016.inpatient_claims_01, include_cohort=pop_01_INdenom_2016_1);
%inp_claims(source=rif2016.inpatient_claims_02, include_cohort=pop_01_INdenom_2016_2);
%inp_claims(source=rif2016.inpatient_claims_03, include_cohort=pop_01_INdenom_2016_3);
%inp_claims(source=rif2016.inpatient_claims_04, include_cohort=pop_01_INdenom_2016_4);
%inp_claims(source=rif2016.inpatient_claims_05, include_cohort=pop_01_INdenom_2016_5);
%inp_claims(source=rif2016.inpatient_claims_06, include_cohort=pop_01_INdenom_2016_6);
%inp_claims(source=rif2016.inpatient_claims_07, include_cohort=pop_01_INdenom_2016_7);
%inp_claims(source=rif2016.inpatient_claims_08, include_cohort=pop_01_INdenom_2016_8);
%inp_claims(source=rif2016.inpatient_claims_09, include_cohort=pop_01_INdenom_2016_9);
%inp_claims(source=rif2016.inpatient_claims_10, include_cohort=pop_01_INdenom_2016_10);
%inp_claims(source=rif2016.inpatient_claims_11, include_cohort=pop_01_INdenom_2016_11);
%inp_claims(source=rif2016.inpatient_claims_12, include_cohort=pop_01_INdenom_2016_12);

%inp_claims(source=rif2017.inpatient_claims_01, include_cohort=pop_01_INdenom_2017_1);
%inp_claims(source=rif2017.inpatient_claims_02, include_cohort=pop_01_INdenom_2017_2);
%inp_claims(source=rif2017.inpatient_claims_03, include_cohort=pop_01_INdenom_2017_3);
%inp_claims(source=rif2017.inpatient_claims_04, include_cohort=pop_01_INdenom_2017_4);
%inp_claims(source=rif2017.inpatient_claims_05, include_cohort=pop_01_INdenom_2017_5);
%inp_claims(source=rif2017.inpatient_claims_06, include_cohort=pop_01_INdenom_2017_6);
%inp_claims(source=rif2017.inpatient_claims_07, include_cohort=pop_01_INdenom_2017_7);
%inp_claims(source=rif2017.inpatient_claims_08, include_cohort=pop_01_INdenom_2017_8);
%inp_claims(source=rif2017.inpatient_claims_09, include_cohort=pop_01_INdenom_2017_9);
%inp_claims(source=rif2017.inpatient_claims_10, include_cohort=pop_01_INdenom_2017_10);
%inp_claims(source=rif2017.inpatient_claims_11, include_cohort=pop_01_INdenom_2017_11);
%inp_claims(source=rif2017.inpatient_claims_12, include_cohort=pop_01_INdenom_2017_12);

%inp_claims(source=rifq2018.inpatient_claims_01, include_cohort=pop_01_INdenom_2018_1);
%inp_claims(source=rifq2018.inpatient_claims_02, include_cohort=pop_01_INdenom_2018_2);
%inp_claims(source=rifq2018.inpatient_claims_03, include_cohort=pop_01_INdenom_2018_3);
%inp_claims(source=rifq2018.inpatient_claims_04, include_cohort=pop_01_INdenom_2018_4);
%inp_claims(source=rifq2018.inpatient_claims_05, include_cohort=pop_01_INdenom_2018_5);
%inp_claims(source=rifq2018.inpatient_claims_06, include_cohort=pop_01_INdenom_2018_6);
%inp_claims(source=rifq2018.inpatient_claims_07, include_cohort=pop_01_INdenom_2018_7);
%inp_claims(source=rifq2018.inpatient_claims_08, include_cohort=pop_01_INdenom_2018_8);
%inp_claims(source=rifq2018.inpatient_claims_09, include_cohort=pop_01_INdenom_2018_9);
%inp_claims(source=rifq2018.inpatient_claims_10, include_cohort=pop_01_INdenom_2018_10);
%inp_claims(source=rifq2018.inpatient_claims_11, include_cohort=pop_01_INdenom_2018_11);
%inp_claims(source=rifq2018.inpatient_claims_12, include_cohort=pop_01_INdenom_2018_12);

*denominator for outpatient ED---icd-9 (note running all of 2015 with icd9 and then icd10);
%macro out_claims(source=, include_cohort=, rev_cohort=);
data &include_cohort
(keep =  pop_01_elig pop_01_age pop_01_year pop_01_setting
		bene_id clm_id clm_admsn_dt clm_thru_dt gndr_cd bene_race_cd bene_cnty_cd bene_state_cd bene_mlg_cntct_zip_cd  
		prvdr_num prvdr_state_cd clm_fac_type_cd /*clm_ip_admsn_type_cd*/ 
		at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi);
length pop_01_elig 3;
set &source;
where clm_fac_type_cd in('1','8');*1=hospital, 8=special facility or ASC surgery data dictionary https://www.resdac.org/cms-data/variables/claim-facility-type-code-ffs;
*no DRG code in outpatient;
*DX code qualifying;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
do j=1 to 25;
	if substr(dx(j),1,3) in(&pop1_icd_dx9_3) then do; pop1=1; end;
	if dx(j) in(&pop1_icd_dx9) then do; pop1=1; end;
end;
if pop1 ne 1 then delete;
pop_01_elig=1;
clm_admsn_dt=clm_from_dt;*reassigning date of claim start to clm_admsn_dt to match the inpatient file;
pop_01_age=(clm_admsn_dt-dob_dt)/365.25;
pop_01_age=round(pop_01_age);
pop_01_year=year(clm_admsn_dt);
pop_01_setting='out';
run;
proc sort data=&include_cohort NODUPKEY;by bene_id clm_id;run;
data merged;
merge &include_cohort (in=a) &rev_cohort (in=b keep=bene_id clm_id rev_cntr hcpcs_cd);
by bene_id clm_id;
if a and b;
run;
*keep ED only--use revenue center or HCPCS codes;
data &include_cohort (drop=rev_cntr hcpcs_cd); set merged;
where rev_cntr in(&pop1_rev_ed) or hcpcs_cd in (&pop1_hcpcs_ed);
run;
proc sort data=&include_cohort NODUPKEY;by bene_id clm_admsn_dt;run;
%mend;
%out_claims(source=rif2010.outpatient_claims_01, rev_cohort=rif2010.outpatient_revenue_01, include_cohort=pop_01_OUTdenom_2010_1);
%out_claims(source=rif2010.outpatient_claims_02, rev_cohort=rif2010.outpatient_revenue_02, include_cohort=pop_01_OUTdenom_2010_2);
%out_claims(source=rif2010.outpatient_claims_03, rev_cohort=rif2010.outpatient_revenue_03, include_cohort=pop_01_OUTdenom_2010_3);
%out_claims(source=rif2010.outpatient_claims_04, rev_cohort=rif2010.outpatient_revenue_04, include_cohort=pop_01_OUTdenom_2010_4);
%out_claims(source=rif2010.outpatient_claims_05, rev_cohort=rif2010.outpatient_revenue_05, include_cohort=pop_01_OUTdenom_2010_5);
%out_claims(source=rif2010.outpatient_claims_06, rev_cohort=rif2010.outpatient_revenue_06, include_cohort=pop_01_OUTdenom_2010_6);
%out_claims(source=rif2010.outpatient_claims_07, rev_cohort=rif2010.outpatient_revenue_07, include_cohort=pop_01_OUTdenom_2010_7);
%out_claims(source=rif2010.outpatient_claims_08, rev_cohort=rif2010.outpatient_revenue_08, include_cohort=pop_01_OUTdenom_2010_8);
%out_claims(source=rif2010.outpatient_claims_09, rev_cohort=rif2010.outpatient_revenue_09, include_cohort=pop_01_OUTdenom_2010_9);
%out_claims(source=rif2010.outpatient_claims_10, rev_cohort=rif2010.outpatient_revenue_10, include_cohort=pop_01_OUTdenom_2010_10);
%out_claims(source=rif2010.outpatient_claims_11, rev_cohort=rif2010.outpatient_revenue_11, include_cohort=pop_01_OUTdenom_2010_11);
%out_claims(source=rif2010.outpatient_claims_12, rev_cohort=rif2010.outpatient_revenue_12, include_cohort=pop_01_OUTdenom_2010_12);

%out_claims(source=rif2011.outpatient_claims_01, rev_cohort=rif2011.outpatient_revenue_01, include_cohort=pop_01_OUTdenom_2011_1);
%out_claims(source=rif2011.outpatient_claims_02, rev_cohort=rif2011.outpatient_revenue_02, include_cohort=pop_01_OUTdenom_2011_2);
%out_claims(source=rif2011.outpatient_claims_03, rev_cohort=rif2011.outpatient_revenue_03, include_cohort=pop_01_OUTdenom_2011_3);
%out_claims(source=rif2011.outpatient_claims_04, rev_cohort=rif2011.outpatient_revenue_04, include_cohort=pop_01_OUTdenom_2011_4);
%out_claims(source=rif2011.outpatient_claims_05, rev_cohort=rif2011.outpatient_revenue_05, include_cohort=pop_01_OUTdenom_2011_5);
%out_claims(source=rif2011.outpatient_claims_06, rev_cohort=rif2011.outpatient_revenue_06, include_cohort=pop_01_OUTdenom_2011_6);
%out_claims(source=rif2011.outpatient_claims_07, rev_cohort=rif2011.outpatient_revenue_07, include_cohort=pop_01_OUTdenom_2011_7);
%out_claims(source=rif2011.outpatient_claims_08, rev_cohort=rif2011.outpatient_revenue_08, include_cohort=pop_01_OUTdenom_2011_8);
%out_claims(source=rif2011.outpatient_claims_09, rev_cohort=rif2011.outpatient_revenue_09, include_cohort=pop_01_OUTdenom_2011_9);
%out_claims(source=rif2011.outpatient_claims_10, rev_cohort=rif2011.outpatient_revenue_10, include_cohort=pop_01_OUTdenom_2011_10);
%out_claims(source=rif2011.outpatient_claims_11, rev_cohort=rif2011.outpatient_revenue_11, include_cohort=pop_01_OUTdenom_2011_11);
%out_claims(source=rif2011.outpatient_claims_12, rev_cohort=rif2011.outpatient_revenue_12, include_cohort=pop_01_OUTdenom_2011_12);

%out_claims(source=rif2012.outpatient_claims_01, rev_cohort=rif2012.outpatient_revenue_01, include_cohort=pop_01_OUTdenom_2012_1);
%out_claims(source=rif2012.outpatient_claims_02, rev_cohort=rif2012.outpatient_revenue_02, include_cohort=pop_01_OUTdenom_2012_2);
%out_claims(source=rif2012.outpatient_claims_03, rev_cohort=rif2012.outpatient_revenue_03, include_cohort=pop_01_OUTdenom_2012_3);
%out_claims(source=rif2012.outpatient_claims_04, rev_cohort=rif2012.outpatient_revenue_04, include_cohort=pop_01_OUTdenom_2012_4);
%out_claims(source=rif2012.outpatient_claims_05, rev_cohort=rif2012.outpatient_revenue_05, include_cohort=pop_01_OUTdenom_2012_5);
%out_claims(source=rif2012.outpatient_claims_06, rev_cohort=rif2012.outpatient_revenue_06, include_cohort=pop_01_OUTdenom_2012_6);
%out_claims(source=rif2012.outpatient_claims_07, rev_cohort=rif2012.outpatient_revenue_07, include_cohort=pop_01_OUTdenom_2012_7);
%out_claims(source=rif2012.outpatient_claims_08, rev_cohort=rif2012.outpatient_revenue_08, include_cohort=pop_01_OUTdenom_2012_8);
%out_claims(source=rif2012.outpatient_claims_09, rev_cohort=rif2012.outpatient_revenue_09, include_cohort=pop_01_OUTdenom_2012_9);
%out_claims(source=rif2012.outpatient_claims_10, rev_cohort=rif2012.outpatient_revenue_10, include_cohort=pop_01_OUTdenom_2012_10);
%out_claims(source=rif2012.outpatient_claims_11, rev_cohort=rif2012.outpatient_revenue_11, include_cohort=pop_01_OUTdenom_2012_11);
%out_claims(source=rif2012.outpatient_claims_12, rev_cohort=rif2012.outpatient_revenue_12, include_cohort=pop_01_OUTdenom_2012_12);

%out_claims(source=rif2013.outpatient_claims_01, rev_cohort=rif2013.outpatient_revenue_01, include_cohort=pop_01_OUTdenom_2013_1);
%out_claims(source=rif2013.outpatient_claims_02, rev_cohort=rif2013.outpatient_revenue_02, include_cohort=pop_01_OUTdenom_2013_2);
%out_claims(source=rif2013.outpatient_claims_03, rev_cohort=rif2013.outpatient_revenue_03, include_cohort=pop_01_OUTdenom_2013_3);
%out_claims(source=rif2013.outpatient_claims_04, rev_cohort=rif2013.outpatient_revenue_04, include_cohort=pop_01_OUTdenom_2013_4);
%out_claims(source=rif2013.outpatient_claims_05, rev_cohort=rif2013.outpatient_revenue_05, include_cohort=pop_01_OUTdenom_2013_5);
%out_claims(source=rif2013.outpatient_claims_06, rev_cohort=rif2013.outpatient_revenue_06, include_cohort=pop_01_OUTdenom_2013_6);
%out_claims(source=rif2013.outpatient_claims_07, rev_cohort=rif2013.outpatient_revenue_07, include_cohort=pop_01_OUTdenom_2013_7);
%out_claims(source=rif2013.outpatient_claims_08, rev_cohort=rif2013.outpatient_revenue_08, include_cohort=pop_01_OUTdenom_2013_8);
%out_claims(source=rif2013.outpatient_claims_09, rev_cohort=rif2013.outpatient_revenue_09, include_cohort=pop_01_OUTdenom_2013_9);
%out_claims(source=rif2013.outpatient_claims_10, rev_cohort=rif2013.outpatient_revenue_10, include_cohort=pop_01_OUTdenom_2013_10);
%out_claims(source=rif2013.outpatient_claims_11, rev_cohort=rif2013.outpatient_revenue_11, include_cohort=pop_01_OUTdenom_2013_11);
%out_claims(source=rif2013.outpatient_claims_12, rev_cohort=rif2013.outpatient_revenue_12, include_cohort=pop_01_OUTdenom_2013_12);

%out_claims(source=rif2014.outpatient_claims_01, rev_cohort=rif2014.outpatient_revenue_01, include_cohort=pop_01_OUTdenom_2014_1);
%out_claims(source=rif2014.outpatient_claims_02, rev_cohort=rif2014.outpatient_revenue_02, include_cohort=pop_01_OUTdenom_2014_2);
%out_claims(source=rif2014.outpatient_claims_03, rev_cohort=rif2014.outpatient_revenue_03, include_cohort=pop_01_OUTdenom_2014_3);
%out_claims(source=rif2014.outpatient_claims_04, rev_cohort=rif2014.outpatient_revenue_04, include_cohort=pop_01_OUTdenom_2014_4);
%out_claims(source=rif2014.outpatient_claims_05, rev_cohort=rif2014.outpatient_revenue_05, include_cohort=pop_01_OUTdenom_2014_5);
%out_claims(source=rif2014.outpatient_claims_06, rev_cohort=rif2014.outpatient_revenue_06, include_cohort=pop_01_OUTdenom_2014_6);
%out_claims(source=rif2014.outpatient_claims_07, rev_cohort=rif2014.outpatient_revenue_07, include_cohort=pop_01_OUTdenom_2014_7);
%out_claims(source=rif2014.outpatient_claims_08, rev_cohort=rif2014.outpatient_revenue_08, include_cohort=pop_01_OUTdenom_2014_8);
%out_claims(source=rif2014.outpatient_claims_09, rev_cohort=rif2014.outpatient_revenue_09, include_cohort=pop_01_OUTdenom_2014_9);
%out_claims(source=rif2014.outpatient_claims_10, rev_cohort=rif2014.outpatient_revenue_10, include_cohort=pop_01_OUTdenom_2014_10);
%out_claims(source=rif2014.outpatient_claims_11, rev_cohort=rif2014.outpatient_revenue_11, include_cohort=pop_01_OUTdenom_2014_11);
%out_claims(source=rif2014.outpatient_claims_12, rev_cohort=rif2014.outpatient_revenue_12, include_cohort=pop_01_OUTdenom_2014_12);

%out_claims(source=rif2015.outpatient_claims_01, rev_cohort=rif2015.outpatient_revenue_01, include_cohort=pop_01_OUTdenom_2015a_1);
%out_claims(source=rif2015.outpatient_claims_02, rev_cohort=rif2015.outpatient_revenue_02, include_cohort=pop_01_OUTdenom_2015a_2);
%out_claims(source=rif2015.outpatient_claims_03, rev_cohort=rif2015.outpatient_revenue_03, include_cohort=pop_01_OUTdenom_2015a_3);
%out_claims(source=rif2015.outpatient_claims_04, rev_cohort=rif2015.outpatient_revenue_04, include_cohort=pop_01_OUTdenom_2015a_4);
%out_claims(source=rif2015.outpatient_claims_05, rev_cohort=rif2015.outpatient_revenue_05, include_cohort=pop_01_OUTdenom_2015a_5);
%out_claims(source=rif2015.outpatient_claims_06, rev_cohort=rif2015.outpatient_revenue_06, include_cohort=pop_01_OUTdenom_2015a_6);
%out_claims(source=rif2015.outpatient_claims_07, rev_cohort=rif2015.outpatient_revenue_07, include_cohort=pop_01_OUTdenom_2015a_7);
%out_claims(source=rif2015.outpatient_claims_08, rev_cohort=rif2015.outpatient_revenue_08, include_cohort=pop_01_OUTdenom_2015a_8);
%out_claims(source=rif2015.outpatient_claims_09, rev_cohort=rif2015.outpatient_revenue_09, include_cohort=pop_01_OUTdenom_2015a_9);
%out_claims(source=rif2015.outpatient_claims_10, rev_cohort=rif2015.outpatient_revenue_10, include_cohort=pop_01_OUTdenom_2015a_10);
%out_claims(source=rif2015.outpatient_claims_11, rev_cohort=rif2015.outpatient_revenue_11, include_cohort=pop_01_OUTdenom_2015a_11);
%out_claims(source=rif2015.outpatient_claims_12, rev_cohort=rif2015.outpatient_revenue_12, include_cohort=pop_01_OUTdenom_2015a_12);

*denominator for outpatient ED---icd-10;
%macro out_claims(source=, include_cohort=, rev_cohort=);
data &include_cohort
(keep =  pop_01_elig pop_01_age pop_01_year pop_01_setting
		bene_id clm_id clm_admsn_dt clm_thru_dt gndr_cd bene_race_cd bene_cnty_cd bene_state_cd bene_mlg_cntct_zip_cd  
		prvdr_num prvdr_state_cd clm_fac_type_cd /*clm_ip_admsn_type_cd*/ 
		at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi);
length pop_01_elig 3;
set &source;
where clm_fac_type_cd in('1','8');*1=hospital, 8=special facility or ASC surgery data dictionary https://www.resdac.org/cms-data/variables/claim-facility-type-code-ffs;
*no DRG code in outpatient;
*DX code qualifying;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
do j=1 to 25;
	if substr(dx(j),1,3) in(&pop1_icd_dx10_3) then do; pop1=1; end;
	if dx(j) in(&pop1_icd_dx10) then do; pop1=1; end;
end;
if pop1 ne 1 then delete;
pop_01_elig=1;
clm_admsn_dt=clm_from_dt;
pop_01_age=(clm_admsn_dt-dob_dt)/365.25;
pop_01_age=round(pop_01_age);
pop_01_year=year(clm_admsn_dt);
pop_01_setting='out';
run;
proc sort data=&include_cohort NODUPKEY;by bene_id clm_id;run;
data merged;
merge &include_cohort (in=a) &rev_cohort (in=b keep=bene_id clm_id rev_cntr hcpcs_cd);
by bene_id clm_id;
if a and b;
run;
*keep ED only--use revenue center or HCPCS codes;
data &include_cohort (drop=rev_cntr hcpcs_cd); set merged;
where rev_cntr in(&pop1_rev_ed) or hcpcs_cd in (&pop1_hcpcs_ed);
run;
proc sort data=&include_cohort NODUPKEY;by bene_id clm_admsn_dt;run;
%mend;
%out_claims(source=rif2015.outpatient_claims_01, rev_cohort=rif2015.outpatient_revenue_01, include_cohort=pop_01_OUTdenom_2015b_1);
%out_claims(source=rif2015.outpatient_claims_02, rev_cohort=rif2015.outpatient_revenue_02, include_cohort=pop_01_OUTdenom_2015b_2);
%out_claims(source=rif2015.outpatient_claims_03, rev_cohort=rif2015.outpatient_revenue_03, include_cohort=pop_01_OUTdenom_2015b_3);
%out_claims(source=rif2015.outpatient_claims_04, rev_cohort=rif2015.outpatient_revenue_04, include_cohort=pop_01_OUTdenom_2015b_4);
%out_claims(source=rif2015.outpatient_claims_05, rev_cohort=rif2015.outpatient_revenue_05, include_cohort=pop_01_OUTdenom_2015b_5);
%out_claims(source=rif2015.outpatient_claims_06, rev_cohort=rif2015.outpatient_revenue_06, include_cohort=pop_01_OUTdenom_2015b_6);
%out_claims(source=rif2015.outpatient_claims_07, rev_cohort=rif2015.outpatient_revenue_07, include_cohort=pop_01_OUTdenom_2015b_7);
%out_claims(source=rif2015.outpatient_claims_08, rev_cohort=rif2015.outpatient_revenue_08, include_cohort=pop_01_OUTdenom_2015b_8);
%out_claims(source=rif2015.outpatient_claims_09, rev_cohort=rif2015.outpatient_revenue_09, include_cohort=pop_01_OUTdenom_2015b_9);
%out_claims(source=rif2015.outpatient_claims_10, rev_cohort=rif2015.outpatient_revenue_10, include_cohort=pop_01_OUTdenom_2015b_10);
%out_claims(source=rif2015.outpatient_claims_11, rev_cohort=rif2015.outpatient_revenue_11, include_cohort=pop_01_OUTdenom_2015b_11);
%out_claims(source=rif2015.outpatient_claims_12, rev_cohort=rif2015.outpatient_revenue_12, include_cohort=pop_01_OUTdenom_2015b_12);

%out_claims(source=rif2016.outpatient_claims_01, rev_cohort=rif2016.outpatient_revenue_01, include_cohort=pop_01_OUTdenom_2016_1);
%out_claims(source=rif2016.outpatient_claims_02, rev_cohort=rif2016.outpatient_revenue_02, include_cohort=pop_01_OUTdenom_2016_2);
%out_claims(source=rif2016.outpatient_claims_03, rev_cohort=rif2016.outpatient_revenue_03, include_cohort=pop_01_OUTdenom_2016_3);
%out_claims(source=rif2016.outpatient_claims_04, rev_cohort=rif2016.outpatient_revenue_04, include_cohort=pop_01_OUTdenom_2016_4);
%out_claims(source=rif2016.outpatient_claims_05, rev_cohort=rif2016.outpatient_revenue_05, include_cohort=pop_01_OUTdenom_2016_5);
%out_claims(source=rif2016.outpatient_claims_06, rev_cohort=rif2016.outpatient_revenue_06, include_cohort=pop_01_OUTdenom_2016_6);
%out_claims(source=rif2016.outpatient_claims_07, rev_cohort=rif2016.outpatient_revenue_07, include_cohort=pop_01_OUTdenom_2016_7);
%out_claims(source=rif2016.outpatient_claims_08, rev_cohort=rif2016.outpatient_revenue_08, include_cohort=pop_01_OUTdenom_2016_8);
%out_claims(source=rif2016.outpatient_claims_09, rev_cohort=rif2016.outpatient_revenue_09, include_cohort=pop_01_OUTdenom_2016_9);
%out_claims(source=rif2016.outpatient_claims_10, rev_cohort=rif2016.outpatient_revenue_10, include_cohort=pop_01_OUTdenom_2016_10);
%out_claims(source=rif2016.outpatient_claims_11, rev_cohort=rif2016.outpatient_revenue_11, include_cohort=pop_01_OUTdenom_2016_11);
%out_claims(source=rif2016.outpatient_claims_12, rev_cohort=rif2016.outpatient_revenue_12, include_cohort=pop_01_OUTdenom_2016_12);

%out_claims(source=rif2017.outpatient_claims_01, rev_cohort=rif2017.outpatient_revenue_01, include_cohort=pop_01_OUTdenom_2017_1);
%out_claims(source=rif2017.outpatient_claims_02, rev_cohort=rif2017.outpatient_revenue_02, include_cohort=pop_01_OUTdenom_2017_2);
%out_claims(source=rif2017.outpatient_claims_03, rev_cohort=rif2017.outpatient_revenue_03, include_cohort=pop_01_OUTdenom_2017_3);
%out_claims(source=rif2017.outpatient_claims_04, rev_cohort=rif2017.outpatient_revenue_04, include_cohort=pop_01_OUTdenom_2017_4);
%out_claims(source=rif2017.outpatient_claims_05, rev_cohort=rif2017.outpatient_revenue_05, include_cohort=pop_01_OUTdenom_2017_5);
%out_claims(source=rif2017.outpatient_claims_06, rev_cohort=rif2017.outpatient_revenue_06, include_cohort=pop_01_OUTdenom_2017_6);
%out_claims(source=rif2017.outpatient_claims_07, rev_cohort=rif2017.outpatient_revenue_07, include_cohort=pop_01_OUTdenom_2017_7);
%out_claims(source=rif2017.outpatient_claims_08, rev_cohort=rif2017.outpatient_revenue_08, include_cohort=pop_01_OUTdenom_2017_8);
%out_claims(source=rif2017.outpatient_claims_09, rev_cohort=rif2017.outpatient_revenue_09, include_cohort=pop_01_OUTdenom_2017_9);
%out_claims(source=rif2017.outpatient_claims_10, rev_cohort=rif2017.outpatient_revenue_10, include_cohort=pop_01_OUTdenom_2017_10);
%out_claims(source=rif2017.outpatient_claims_11, rev_cohort=rif2017.outpatient_revenue_11, include_cohort=pop_01_OUTdenom_2017_11);
%out_claims(source=rif2017.outpatient_claims_12, rev_cohort=rif2017.outpatient_revenue_12, include_cohort=pop_01_OUTdenom_2017_12);

%out_claims(source=rifq2018.outpatient_claims_01, rev_cohort=rifq2018.outpatient_revenue_01, include_cohort=pop_01_OUTdenom_2018_1);
%out_claims(source=rifq2018.outpatient_claims_02, rev_cohort=rifq2018.outpatient_revenue_02, include_cohort=pop_01_OUTdenom_2018_2);
%out_claims(source=rifq2018.outpatient_claims_03, rev_cohort=rifq2018.outpatient_revenue_03, include_cohort=pop_01_OUTdenom_2018_3);
%out_claims(source=rifq2018.outpatient_claims_04, rev_cohort=rifq2018.outpatient_revenue_04, include_cohort=pop_01_OUTdenom_2018_4);
%out_claims(source=rifq2018.outpatient_claims_05, rev_cohort=rifq2018.outpatient_revenue_05, include_cohort=pop_01_OUTdenom_2018_5);
%out_claims(source=rifq2018.outpatient_claims_06, rev_cohort=rifq2018.outpatient_revenue_06, include_cohort=pop_01_OUTdenom_2018_6);
%out_claims(source=rifq2018.outpatient_claims_07, rev_cohort=rifq2018.outpatient_revenue_07, include_cohort=pop_01_OUTdenom_2018_7);
%out_claims(source=rifq2018.outpatient_claims_08, rev_cohort=rifq2018.outpatient_revenue_08, include_cohort=pop_01_OUTdenom_2018_8);
%out_claims(source=rifq2018.outpatient_claims_09, rev_cohort=rifq2018.outpatient_revenue_09, include_cohort=pop_01_OUTdenom_2018_9);
%out_claims(source=rifq2018.outpatient_claims_10, rev_cohort=rifq2018.outpatient_revenue_10, include_cohort=pop_01_OUTdenom_2018_10);
%out_claims(source=rifq2018.outpatient_claims_11, rev_cohort=rifq2018.outpatient_revenue_11, include_cohort=pop_01_OUTdenom_2018_11);
%out_claims(source=rifq2018.outpatient_claims_12, rev_cohort=rifq2018.outpatient_revenue_12, include_cohort=pop_01_OUTdenom_2018_12);

*create single denominator file;
data pop_01_denom;
set pop_01_INdenom_2010_1 pop_01_INdenom_2010_2 pop_01_INdenom_2010_3 pop_01_INdenom_2010_4 pop_01_INdenom_2010_5 pop_01_INdenom_2010_6 pop_01_INdenom_2010_7
pop_01_INdenom_2010_8 pop_01_INdenom_2010_9 pop_01_INdenom_2010_10 pop_01_INdenom_2010_11 pop_01_INdenom_2010_12
pop_01_OUTdenom_2010_1 pop_01_OUTdenom_2010_2 pop_01_OUTdenom_2010_3 pop_01_OUTdenom_2010_4 pop_01_OUTdenom_2010_5 pop_01_OUTdenom_2010_6 pop_01_OUTdenom_2010_7
pop_01_OUTdenom_2010_8 pop_01_OUTdenom_2010_9 pop_01_OUTdenom_2010_10 pop_01_OUTdenom_2010_11 pop_01_OUTdenom_2010_12

pop_01_INdenom_2011_1 pop_01_INdenom_2011_2 pop_01_INdenom_2011_3 pop_01_INdenom_2011_4 pop_01_INdenom_2011_5 pop_01_INdenom_2011_6 pop_01_INdenom_2011_7
pop_01_INdenom_2011_8 pop_01_INdenom_2011_9 pop_01_INdenom_2011_10 pop_01_INdenom_2011_11 pop_01_INdenom_2011_12
pop_01_OUTdenom_2011_1 pop_01_OUTdenom_2011_2 pop_01_OUTdenom_2011_3 pop_01_OUTdenom_2011_4 pop_01_OUTdenom_2011_5 pop_01_OUTdenom_2011_6 pop_01_OUTdenom_2011_7
pop_01_OUTdenom_2011_8 pop_01_OUTdenom_2011_9 pop_01_OUTdenom_2011_10 pop_01_OUTdenom_2011_11 pop_01_OUTdenom_2011_12

pop_01_INdenom_2012_1 pop_01_INdenom_2012_2 pop_01_INdenom_2012_3 pop_01_INdenom_2012_4 pop_01_INdenom_2012_5 pop_01_INdenom_2012_6 pop_01_INdenom_2012_7
pop_01_INdenom_2012_8 pop_01_INdenom_2012_9 pop_01_INdenom_2012_10 pop_01_INdenom_2012_11 pop_01_INdenom_2012_12
pop_01_OUTdenom_2012_1 pop_01_OUTdenom_2012_2 pop_01_OUTdenom_2012_3 pop_01_OUTdenom_2012_4 pop_01_OUTdenom_2012_5 pop_01_OUTdenom_2012_6 pop_01_OUTdenom_2012_7
pop_01_OUTdenom_2012_8 pop_01_OUTdenom_2012_9 pop_01_OUTdenom_2012_10 pop_01_OUTdenom_2012_11 pop_01_OUTdenom_2012_12

pop_01_INdenom_2013_1 pop_01_INdenom_2013_2 pop_01_INdenom_2013_3 pop_01_INdenom_2013_4 pop_01_INdenom_2013_5 pop_01_INdenom_2013_6 pop_01_INdenom_2013_7
pop_01_INdenom_2013_8 pop_01_INdenom_2013_9 pop_01_INdenom_2013_10 pop_01_INdenom_2013_11 pop_01_INdenom_2013_12
pop_01_OUTdenom_2013_1 pop_01_OUTdenom_2013_2 pop_01_OUTdenom_2013_3 pop_01_OUTdenom_2013_4 pop_01_OUTdenom_2013_5 pop_01_OUTdenom_2013_6 pop_01_OUTdenom_2013_7
pop_01_OUTdenom_2013_8 pop_01_OUTdenom_2013_9 pop_01_OUTdenom_2013_10 pop_01_OUTdenom_2013_11 pop_01_OUTdenom_2013_12

pop_01_INdenom_2014_1 pop_01_INdenom_2014_2 pop_01_INdenom_2014_3 pop_01_INdenom_2014_4 pop_01_INdenom_2014_5 pop_01_INdenom_2014_6 pop_01_INdenom_2014_7
pop_01_INdenom_2014_8 pop_01_INdenom_2014_9 pop_01_INdenom_2014_10 pop_01_INdenom_2014_11 pop_01_INdenom_2014_12
pop_01_OUTdenom_2014_1 pop_01_OUTdenom_2014_2 pop_01_OUTdenom_2014_3 pop_01_OUTdenom_2014_4 pop_01_OUTdenom_2014_5 pop_01_OUTdenom_2014_6 pop_01_OUTdenom_2014_7
pop_01_OUTdenom_2014_8 pop_01_OUTdenom_2014_9 pop_01_OUTdenom_2014_10 pop_01_OUTdenom_2014_11 pop_01_OUTdenom_2014_12

pop_01_INdenom_2015_1 pop_01_INdenom_2015_2 pop_01_INdenom_2015_3 pop_01_INdenom_2015_4 pop_01_INdenom_2015_5 pop_01_INdenom_2015_6 pop_01_INdenom_2015_7
pop_01_INdenom_2015_8 pop_01_INdenom_2015_9 pop_01_INdenom_2015_10 pop_01_INdenom_2015_11 pop_01_INdenom_2015_12
pop_01_OUTdenom_2015a_1 pop_01_OUTdenom_2015a_2 pop_01_OUTdenom_2015a_3 pop_01_OUTdenom_2015a_4 pop_01_OUTdenom_2015a_5 pop_01_OUTdenom_2015a_6 pop_01_OUTdenom_2015a_7
pop_01_OUTdenom_2015a_8 pop_01_OUTdenom_2015a_9 pop_01_OUTdenom_2015a_10 pop_01_OUTdenom_2015a_11 pop_01_OUTdenom_2015a_12
pop_01_OUTdenom_2015b_1 pop_01_OUTdenom_2015b_2 pop_01_OUTdenom_2015b_3 pop_01_OUTdenom_2015b_4 pop_01_OUTdenom_2015b_5 pop_01_OUTdenom_2015b_6 pop_01_OUTdenom_2015b_7
pop_01_OUTdenom_2015b_8 pop_01_OUTdenom_2015b_9 pop_01_OUTdenom_2015b_10 pop_01_OUTdenom_2015b_11 pop_01_OUTdenom_2015b_12

pop_01_INdenom_2016_1 pop_01_INdenom_2016_2 pop_01_INdenom_2016_3 pop_01_INdenom_2016_4 pop_01_INdenom_2016_5 pop_01_INdenom_2016_6 pop_01_INdenom_2016_7
pop_01_INdenom_2016_8 pop_01_INdenom_2016_9 pop_01_INdenom_2016_10 pop_01_INdenom_2016_11 pop_01_INdenom_2016_12
pop_01_OUTdenom_2016_1 pop_01_OUTdenom_2016_2 pop_01_OUTdenom_2016_3 pop_01_OUTdenom_2016_4 pop_01_OUTdenom_2016_5 pop_01_OUTdenom_2016_6 pop_01_OUTdenom_2016_7
pop_01_OUTdenom_2016_8 pop_01_OUTdenom_2016_9 pop_01_OUTdenom_2016_10 pop_01_OUTdenom_2016_11 pop_01_OUTdenom_2016_12

pop_01_INdenom_2017_1 pop_01_INdenom_2017_2 pop_01_INdenom_2017_3 pop_01_INdenom_2017_4 pop_01_INdenom_2017_5 pop_01_INdenom_2017_6 pop_01_INdenom_2017_7
pop_01_INdenom_2017_8 pop_01_INdenom_2017_9 pop_01_INdenom_2017_10 pop_01_INdenom_2017_11 pop_01_INdenom_2017_12
pop_01_OUTdenom_2017_1 pop_01_OUTdenom_2017_2 pop_01_OUTdenom_2017_3 pop_01_OUTdenom_2017_4 pop_01_OUTdenom_2017_5 pop_01_OUTdenom_2017_6 pop_01_OUTdenom_2017_7
pop_01_OUTdenom_2017_8 pop_01_OUTdenom_2017_9 pop_01_OUTdenom_2017_10 pop_01_OUTdenom_2017_11 pop_01_OUTdenom_2017_12

pop_01_INdenom_2018_1 pop_01_INdenom_2018_2 pop_01_INdenom_2018_3 pop_01_INdenom_2018_4 pop_01_INdenom_2018_5 pop_01_INdenom_2018_6 pop_01_INdenom_2018_7
pop_01_INdenom_2018_8 pop_01_INdenom_2018_9 pop_01_INdenom_2018_10 pop_01_INdenom_2018_11 pop_01_INdenom_2018_12
pop_01_OUTdenom_2018_1 pop_01_OUTdenom_2018_2 pop_01_OUTdenom_2018_3 pop_01_OUTdenom_2018_4 pop_01_OUTdenom_2018_5 pop_01_OUTdenom_2018_6 pop_01_OUTdenom_2018_7
pop_01_OUTdenom_2018_8 pop_01_OUTdenom_2018_9 pop_01_OUTdenom_2018_10 pop_01_OUTdenom_2018_11 pop_01_OUTdenom_2018_12
;
run;
proc sort data=pop_01_denom NODUPKEY;by bene_id clm_admsn_dt;run;*allow person to contribute for each hospitalization;

*numerator for inpatient, outpatient, carrier;
%macro inp_rev(source=, include_cohort=);
proc sql;
create table &include_cohort (compress=yes) as
select a.*
from 
pop_01_denom a,
&source b
where 
a.bene_id=b.bene_id
/*AND
a.clm_admsn_dt<=b.clm_thru_dt<=a.clm_thru_dt	/H-Y--this is the line that I assume is making the difference*/
AND
b.hcpcs_cd in (&pop1_hcpcs);
quit;
proc sort data=&include_cohort NODUPKEY; by bene_id clm_admsn_dt; run;
*keep date of admission for procedure NOT the numerator info--only thing from numerator is indicator that they popped which gets
put on the denom file;
Data &include_cohort (keep=bene_id clm_admsn_dt popped_01); set &include_cohort;  length popped_01 3; popped_01=1; run; 
%mend;
%inp_rev(source=rif2010.inpatient_revenue_01, include_cohort=pop1_INnum_2010_1);
%inp_rev(source=rif2010.inpatient_revenue_02, include_cohort=pop1_INnum_2010_2);
%inp_rev(source=rif2010.inpatient_revenue_03, include_cohort=pop1_INnum_2010_3);
%inp_rev(source=rif2010.inpatient_revenue_04, include_cohort=pop1_INnum_2010_4);
%inp_rev(source=rif2010.inpatient_revenue_05, include_cohort=pop1_INnum_2010_5);
%inp_rev(source=rif2010.inpatient_revenue_06, include_cohort=pop1_INnum_2010_6);
%inp_rev(source=rif2010.inpatient_revenue_07, include_cohort=pop1_INnum_2010_7);
%inp_rev(source=rif2010.inpatient_revenue_08, include_cohort=pop1_INnum_2010_8);
%inp_rev(source=rif2010.inpatient_revenue_09, include_cohort=pop1_INnum_2010_9);
%inp_rev(source=rif2010.inpatient_revenue_10, include_cohort=pop1_INnum_2010_10);
%inp_rev(source=rif2010.inpatient_revenue_11, include_cohort=pop1_INnum_2010_11);
%inp_rev(source=rif2010.inpatient_revenue_12, include_cohort=pop1_INnum_2010_12);
%inp_rev(source=rif2010.outpatient_revenue_01, include_cohort=pop1_OUTnum_2010_1);
%inp_rev(source=rif2010.outpatient_revenue_02, include_cohort=pop1_OUTnum_2010_2);
%inp_rev(source=rif2010.outpatient_revenue_03, include_cohort=pop1_OUTnum_2010_3);
%inp_rev(source=rif2010.outpatient_revenue_04, include_cohort=pop1_OUTnum_2010_4);
%inp_rev(source=rif2010.outpatient_revenue_05, include_cohort=pop1_OUTnum_2010_5);
%inp_rev(source=rif2010.outpatient_revenue_06, include_cohort=pop1_OUTnum_2010_6);
%inp_rev(source=rif2010.outpatient_revenue_07, include_cohort=pop1_OUTnum_2010_7);
%inp_rev(source=rif2010.outpatient_revenue_08, include_cohort=pop1_OUTnum_2010_8);
%inp_rev(source=rif2010.outpatient_revenue_09, include_cohort=pop1_OUTnum_2010_9);
%inp_rev(source=rif2010.outpatient_revenue_10, include_cohort=pop1_OUTnum_2010_10);
%inp_rev(source=rif2010.outpatient_revenue_11, include_cohort=pop1_OUTnum_2010_11);
%inp_rev(source=rif2010.outpatient_revenue_12, include_cohort=pop1_OUTnum_2010_12);
%inp_rev(source=rif2010.bcarrier_line_01, include_cohort=pop1_CARnum_2010_1);
%inp_rev(source=rif2010.bcarrier_line_02, include_cohort=pop1_CARnum_2010_2);
%inp_rev(source=rif2010.bcarrier_line_03, include_cohort=pop1_CARnum_2010_3);
%inp_rev(source=rif2010.bcarrier_line_04, include_cohort=pop1_CARnum_2010_4);
%inp_rev(source=rif2010.bcarrier_line_05, include_cohort=pop1_CARnum_2010_5);
%inp_rev(source=rif2010.bcarrier_line_06, include_cohort=pop1_CARnum_2010_6);
%inp_rev(source=rif2010.bcarrier_line_07, include_cohort=pop1_CARnum_2010_7);
%inp_rev(source=rif2010.bcarrier_line_08, include_cohort=pop1_CARnum_2010_8);
%inp_rev(source=rif2010.bcarrier_line_09, include_cohort=pop1_CARnum_2010_9);
%inp_rev(source=rif2010.bcarrier_line_10, include_cohort=pop1_CARnum_2010_10);
%inp_rev(source=rif2010.bcarrier_line_11, include_cohort=pop1_CARnum_2010_11);
%inp_rev(source=rif2010.bcarrier_line_12, include_cohort=pop1_CARnum_2010_12);

%inp_rev(source=rif2011.inpatient_revenue_01, include_cohort=pop1_INnum_2011_1);
%inp_rev(source=rif2011.inpatient_revenue_02, include_cohort=pop1_INnum_2011_2);
%inp_rev(source=rif2011.inpatient_revenue_03, include_cohort=pop1_INnum_2011_3);
%inp_rev(source=rif2011.inpatient_revenue_04, include_cohort=pop1_INnum_2011_4);
%inp_rev(source=rif2011.inpatient_revenue_05, include_cohort=pop1_INnum_2011_5);
%inp_rev(source=rif2011.inpatient_revenue_06, include_cohort=pop1_INnum_2011_6);
%inp_rev(source=rif2011.inpatient_revenue_07, include_cohort=pop1_INnum_2011_7);
%inp_rev(source=rif2011.inpatient_revenue_08, include_cohort=pop1_INnum_2011_8);
%inp_rev(source=rif2011.inpatient_revenue_09, include_cohort=pop1_INnum_2011_9);
%inp_rev(source=rif2011.inpatient_revenue_10, include_cohort=pop1_INnum_2011_10);
%inp_rev(source=rif2011.inpatient_revenue_11, include_cohort=pop1_INnum_2011_11);
%inp_rev(source=rif2011.inpatient_revenue_12, include_cohort=pop1_INnum_2011_12);
%inp_rev(source=rif2011.outpatient_revenue_01, include_cohort=pop1_OUTnum_2011_1);
%inp_rev(source=rif2011.outpatient_revenue_02, include_cohort=pop1_OUTnum_2011_2);
%inp_rev(source=rif2011.outpatient_revenue_03, include_cohort=pop1_OUTnum_2011_3);
%inp_rev(source=rif2011.outpatient_revenue_04, include_cohort=pop1_OUTnum_2011_4);
%inp_rev(source=rif2011.outpatient_revenue_05, include_cohort=pop1_OUTnum_2011_5);
%inp_rev(source=rif2011.outpatient_revenue_06, include_cohort=pop1_OUTnum_2011_6);
%inp_rev(source=rif2011.outpatient_revenue_07, include_cohort=pop1_OUTnum_2011_7);
%inp_rev(source=rif2011.outpatient_revenue_08, include_cohort=pop1_OUTnum_2011_8);
%inp_rev(source=rif2011.outpatient_revenue_09, include_cohort=pop1_OUTnum_2011_9);
%inp_rev(source=rif2011.outpatient_revenue_10, include_cohort=pop1_OUTnum_2011_10);
%inp_rev(source=rif2011.outpatient_revenue_11, include_cohort=pop1_OUTnum_2011_11);
%inp_rev(source=rif2011.outpatient_revenue_12, include_cohort=pop1_OUTnum_2011_12);
%inp_rev(source=rif2011.bcarrier_line_01, include_cohort=pop1_CARnum_2011_1);
%inp_rev(source=rif2011.bcarrier_line_02, include_cohort=pop1_CARnum_2011_2);
%inp_rev(source=rif2011.bcarrier_line_03, include_cohort=pop1_CARnum_2011_3);
%inp_rev(source=rif2011.bcarrier_line_04, include_cohort=pop1_CARnum_2011_4);
%inp_rev(source=rif2011.bcarrier_line_05, include_cohort=pop1_CARnum_2011_5);
%inp_rev(source=rif2011.bcarrier_line_06, include_cohort=pop1_CARnum_2011_6);
%inp_rev(source=rif2011.bcarrier_line_07, include_cohort=pop1_CARnum_2011_7);
%inp_rev(source=rif2011.bcarrier_line_08, include_cohort=pop1_CARnum_2011_8);
%inp_rev(source=rif2011.bcarrier_line_09, include_cohort=pop1_CARnum_2011_9);
%inp_rev(source=rif2011.bcarrier_line_10, include_cohort=pop1_CARnum_2011_10);
%inp_rev(source=rif2011.bcarrier_line_11, include_cohort=pop1_CARnum_2011_11);
%inp_rev(source=rif2011.bcarrier_line_12, include_cohort=pop1_CARnum_2011_12);

%inp_rev(source=rif2012.inpatient_revenue_01, include_cohort=pop1_INnum_2012_1);
%inp_rev(source=rif2012.inpatient_revenue_02, include_cohort=pop1_INnum_2012_2);
%inp_rev(source=rif2012.inpatient_revenue_03, include_cohort=pop1_INnum_2012_3);
%inp_rev(source=rif2012.inpatient_revenue_04, include_cohort=pop1_INnum_2012_4);
%inp_rev(source=rif2012.inpatient_revenue_05, include_cohort=pop1_INnum_2012_5);
%inp_rev(source=rif2012.inpatient_revenue_06, include_cohort=pop1_INnum_2012_6);
%inp_rev(source=rif2012.inpatient_revenue_07, include_cohort=pop1_INnum_2012_7);
%inp_rev(source=rif2012.inpatient_revenue_08, include_cohort=pop1_INnum_2012_8);
%inp_rev(source=rif2012.inpatient_revenue_09, include_cohort=pop1_INnum_2012_9);
%inp_rev(source=rif2012.inpatient_revenue_10, include_cohort=pop1_INnum_2012_10);
%inp_rev(source=rif2012.inpatient_revenue_11, include_cohort=pop1_INnum_2012_11);
%inp_rev(source=rif2012.inpatient_revenue_12, include_cohort=pop1_INnum_2012_12);
%inp_rev(source=rif2012.outpatient_revenue_01, include_cohort=pop1_OUTnum_2012_1);
%inp_rev(source=rif2012.outpatient_revenue_02, include_cohort=pop1_OUTnum_2012_2);
%inp_rev(source=rif2012.outpatient_revenue_03, include_cohort=pop1_OUTnum_2012_3);
%inp_rev(source=rif2012.outpatient_revenue_04, include_cohort=pop1_OUTnum_2012_4);
%inp_rev(source=rif2012.outpatient_revenue_05, include_cohort=pop1_OUTnum_2012_5);
%inp_rev(source=rif2012.outpatient_revenue_06, include_cohort=pop1_OUTnum_2012_6);
%inp_rev(source=rif2012.outpatient_revenue_07, include_cohort=pop1_OUTnum_2012_7);
%inp_rev(source=rif2012.outpatient_revenue_08, include_cohort=pop1_OUTnum_2012_8);
%inp_rev(source=rif2012.outpatient_revenue_09, include_cohort=pop1_OUTnum_2012_9);
%inp_rev(source=rif2012.outpatient_revenue_10, include_cohort=pop1_OUTnum_2012_10);
%inp_rev(source=rif2012.outpatient_revenue_11, include_cohort=pop1_OUTnum_2012_11);
%inp_rev(source=rif2012.outpatient_revenue_12, include_cohort=pop1_OUTnum_2012_12);
%inp_rev(source=rif2012.bcarrier_line_01, include_cohort=pop1_CARnum_2012_1);
%inp_rev(source=rif2012.bcarrier_line_02, include_cohort=pop1_CARnum_2012_2);
%inp_rev(source=rif2012.bcarrier_line_03, include_cohort=pop1_CARnum_2012_3);
%inp_rev(source=rif2012.bcarrier_line_04, include_cohort=pop1_CARnum_2012_4);
%inp_rev(source=rif2012.bcarrier_line_05, include_cohort=pop1_CARnum_2012_5);
%inp_rev(source=rif2012.bcarrier_line_06, include_cohort=pop1_CARnum_2012_6);
%inp_rev(source=rif2012.bcarrier_line_07, include_cohort=pop1_CARnum_2012_7);
%inp_rev(source=rif2012.bcarrier_line_08, include_cohort=pop1_CARnum_2012_8);
%inp_rev(source=rif2012.bcarrier_line_09, include_cohort=pop1_CARnum_2012_9);
%inp_rev(source=rif2012.bcarrier_line_10, include_cohort=pop1_CARnum_2012_10);
%inp_rev(source=rif2012.bcarrier_line_11, include_cohort=pop1_CARnum_2012_11);
%inp_rev(source=rif2012.bcarrier_line_12, include_cohort=pop1_CARnum_2012_12);

%inp_rev(source=rif2013.inpatient_revenue_01, include_cohort=pop1_INnum_2013_1);
%inp_rev(source=rif2013.inpatient_revenue_02, include_cohort=pop1_INnum_2013_2);
%inp_rev(source=rif2013.inpatient_revenue_03, include_cohort=pop1_INnum_2013_3);
%inp_rev(source=rif2013.inpatient_revenue_04, include_cohort=pop1_INnum_2013_4);
%inp_rev(source=rif2013.inpatient_revenue_05, include_cohort=pop1_INnum_2013_5);
%inp_rev(source=rif2013.inpatient_revenue_06, include_cohort=pop1_INnum_2013_6);
%inp_rev(source=rif2013.inpatient_revenue_07, include_cohort=pop1_INnum_2013_7);
%inp_rev(source=rif2013.inpatient_revenue_08, include_cohort=pop1_INnum_2013_8);
%inp_rev(source=rif2013.inpatient_revenue_09, include_cohort=pop1_INnum_2013_9);
%inp_rev(source=rif2013.inpatient_revenue_10, include_cohort=pop1_INnum_2013_10);
%inp_rev(source=rif2013.inpatient_revenue_11, include_cohort=pop1_INnum_2013_11);
%inp_rev(source=rif2013.inpatient_revenue_12, include_cohort=pop1_INnum_2013_12);
%inp_rev(source=rif2013.outpatient_revenue_01, include_cohort=pop1_OUTnum_2013_1);
%inp_rev(source=rif2013.outpatient_revenue_02, include_cohort=pop1_OUTnum_2013_2);
%inp_rev(source=rif2013.outpatient_revenue_03, include_cohort=pop1_OUTnum_2013_3);
%inp_rev(source=rif2013.outpatient_revenue_04, include_cohort=pop1_OUTnum_2013_4);
%inp_rev(source=rif2013.outpatient_revenue_05, include_cohort=pop1_OUTnum_2013_5);
%inp_rev(source=rif2013.outpatient_revenue_06, include_cohort=pop1_OUTnum_2013_6);
%inp_rev(source=rif2013.outpatient_revenue_07, include_cohort=pop1_OUTnum_2013_7);
%inp_rev(source=rif2013.outpatient_revenue_08, include_cohort=pop1_OUTnum_2013_8);
%inp_rev(source=rif2013.outpatient_revenue_09, include_cohort=pop1_OUTnum_2013_9);
%inp_rev(source=rif2013.outpatient_revenue_10, include_cohort=pop1_OUTnum_2013_10);
%inp_rev(source=rif2013.outpatient_revenue_11, include_cohort=pop1_OUTnum_2013_11);
%inp_rev(source=rif2013.outpatient_revenue_12, include_cohort=pop1_OUTnum_2013_12);
%inp_rev(source=rif2013.bcarrier_line_01, include_cohort=pop1_CARnum_2013_1);
%inp_rev(source=rif2013.bcarrier_line_02, include_cohort=pop1_CARnum_2013_2);
%inp_rev(source=rif2013.bcarrier_line_03, include_cohort=pop1_CARnum_2013_3);
%inp_rev(source=rif2013.bcarrier_line_04, include_cohort=pop1_CARnum_2013_4);
%inp_rev(source=rif2013.bcarrier_line_05, include_cohort=pop1_CARnum_2013_5);
%inp_rev(source=rif2013.bcarrier_line_06, include_cohort=pop1_CARnum_2013_6);
%inp_rev(source=rif2013.bcarrier_line_07, include_cohort=pop1_CARnum_2013_7);
%inp_rev(source=rif2013.bcarrier_line_08, include_cohort=pop1_CARnum_2013_8);
%inp_rev(source=rif2013.bcarrier_line_09, include_cohort=pop1_CARnum_2013_9);
%inp_rev(source=rif2013.bcarrier_line_10, include_cohort=pop1_CARnum_2013_10);
%inp_rev(source=rif2013.bcarrier_line_11, include_cohort=pop1_CARnum_2013_11);
%inp_rev(source=rif2013.bcarrier_line_12, include_cohort=pop1_CARnum_2013_12);

%inp_rev(source=rif2014.inpatient_revenue_01, include_cohort=pop1_INnum_2014_1);
%inp_rev(source=rif2014.inpatient_revenue_02, include_cohort=pop1_INnum_2014_2);
%inp_rev(source=rif2014.inpatient_revenue_03, include_cohort=pop1_INnum_2014_3);
%inp_rev(source=rif2014.inpatient_revenue_04, include_cohort=pop1_INnum_2014_4);
%inp_rev(source=rif2014.inpatient_revenue_05, include_cohort=pop1_INnum_2014_5);
%inp_rev(source=rif2014.inpatient_revenue_06, include_cohort=pop1_INnum_2014_6);
%inp_rev(source=rif2014.inpatient_revenue_07, include_cohort=pop1_INnum_2014_7);
%inp_rev(source=rif2014.inpatient_revenue_08, include_cohort=pop1_INnum_2014_8);
%inp_rev(source=rif2014.inpatient_revenue_09, include_cohort=pop1_INnum_2014_9);
%inp_rev(source=rif2014.inpatient_revenue_10, include_cohort=pop1_INnum_2014_10);
%inp_rev(source=rif2014.inpatient_revenue_11, include_cohort=pop1_INnum_2014_11);
%inp_rev(source=rif2014.inpatient_revenue_12, include_cohort=pop1_INnum_2014_12);
%inp_rev(source=rif2014.outpatient_revenue_01, include_cohort=pop1_OUTnum_2014_1);
%inp_rev(source=rif2014.outpatient_revenue_02, include_cohort=pop1_OUTnum_2014_2);
%inp_rev(source=rif2014.outpatient_revenue_03, include_cohort=pop1_OUTnum_2014_3);
%inp_rev(source=rif2014.outpatient_revenue_04, include_cohort=pop1_OUTnum_2014_4);
%inp_rev(source=rif2014.outpatient_revenue_05, include_cohort=pop1_OUTnum_2014_5);
%inp_rev(source=rif2014.outpatient_revenue_06, include_cohort=pop1_OUTnum_2014_6);
%inp_rev(source=rif2014.outpatient_revenue_07, include_cohort=pop1_OUTnum_2014_7);
%inp_rev(source=rif2014.outpatient_revenue_08, include_cohort=pop1_OUTnum_2014_8);
%inp_rev(source=rif2014.outpatient_revenue_09, include_cohort=pop1_OUTnum_2014_9);
%inp_rev(source=rif2014.outpatient_revenue_10, include_cohort=pop1_OUTnum_2014_10);
%inp_rev(source=rif2014.outpatient_revenue_11, include_cohort=pop1_OUTnum_2014_11);
%inp_rev(source=rif2014.outpatient_revenue_12, include_cohort=pop1_OUTnum_2014_12);
%inp_rev(source=rif2014.bcarrier_line_01, include_cohort=pop1_CARnum_2014_1);
%inp_rev(source=rif2014.bcarrier_line_02, include_cohort=pop1_CARnum_2014_2);
%inp_rev(source=rif2014.bcarrier_line_03, include_cohort=pop1_CARnum_2014_3);
%inp_rev(source=rif2014.bcarrier_line_04, include_cohort=pop1_CARnum_2014_4);
%inp_rev(source=rif2014.bcarrier_line_05, include_cohort=pop1_CARnum_2014_5);
%inp_rev(source=rif2014.bcarrier_line_06, include_cohort=pop1_CARnum_2014_6);
%inp_rev(source=rif2014.bcarrier_line_07, include_cohort=pop1_CARnum_2014_7);
%inp_rev(source=rif2014.bcarrier_line_08, include_cohort=pop1_CARnum_2014_8);
%inp_rev(source=rif2014.bcarrier_line_09, include_cohort=pop1_CARnum_2014_9);
%inp_rev(source=rif2014.bcarrier_line_10, include_cohort=pop1_CARnum_2014_10);
%inp_rev(source=rif2014.bcarrier_line_11, include_cohort=pop1_CARnum_2014_11);
%inp_rev(source=rif2014.bcarrier_line_12, include_cohort=pop1_CARnum_2014_12);

%inp_rev(source=rif2015.inpatient_revenue_01, include_cohort=pop1_INnum_2015_1);
%inp_rev(source=rif2015.inpatient_revenue_02, include_cohort=pop1_INnum_2015_2);
%inp_rev(source=rif2015.inpatient_revenue_03, include_cohort=pop1_INnum_2015_3);
%inp_rev(source=rif2015.inpatient_revenue_04, include_cohort=pop1_INnum_2015_4);
%inp_rev(source=rif2015.inpatient_revenue_05, include_cohort=pop1_INnum_2015_5);
%inp_rev(source=rif2015.inpatient_revenue_06, include_cohort=pop1_INnum_2015_6);
%inp_rev(source=rif2015.inpatient_revenue_07, include_cohort=pop1_INnum_2015_7);
%inp_rev(source=rif2015.inpatient_revenue_08, include_cohort=pop1_INnum_2015_8);
%inp_rev(source=rif2015.inpatient_revenue_09, include_cohort=pop1_INnum_2015_9);
%inp_rev(source=rif2015.inpatient_revenue_10, include_cohort=pop1_INnum_2015_10);
%inp_rev(source=rif2015.inpatient_revenue_11, include_cohort=pop1_INnum_2015_11);
%inp_rev(source=rif2015.inpatient_revenue_12, include_cohort=pop1_INnum_2015_12);
%inp_rev(source=rif2015.outpatient_revenue_01, include_cohort=pop1_OUTnum_2015_1);
%inp_rev(source=rif2015.outpatient_revenue_02, include_cohort=pop1_OUTnum_2015_2);
%inp_rev(source=rif2015.outpatient_revenue_03, include_cohort=pop1_OUTnum_2015_3);
%inp_rev(source=rif2015.outpatient_revenue_04, include_cohort=pop1_OUTnum_2015_4);
%inp_rev(source=rif2015.outpatient_revenue_05, include_cohort=pop1_OUTnum_2015_5);
%inp_rev(source=rif2015.outpatient_revenue_06, include_cohort=pop1_OUTnum_2015_6);
%inp_rev(source=rif2015.outpatient_revenue_07, include_cohort=pop1_OUTnum_2015_7);
%inp_rev(source=rif2015.outpatient_revenue_08, include_cohort=pop1_OUTnum_2015_8);
%inp_rev(source=rif2015.outpatient_revenue_09, include_cohort=pop1_OUTnum_2015_9);
%inp_rev(source=rif2015.outpatient_revenue_10, include_cohort=pop1_OUTnum_2015_10);
%inp_rev(source=rif2015.outpatient_revenue_11, include_cohort=pop1_OUTnum_2015_11);
%inp_rev(source=rif2015.outpatient_revenue_12, include_cohort=pop1_OUTnum_2015_12);
%inp_rev(source=rif2015.bcarrier_line_01, include_cohort=pop1_CARnum_2015_1);
%inp_rev(source=rif2015.bcarrier_line_02, include_cohort=pop1_CARnum_2015_2);
%inp_rev(source=rif2015.bcarrier_line_03, include_cohort=pop1_CARnum_2015_3);
%inp_rev(source=rif2015.bcarrier_line_04, include_cohort=pop1_CARnum_2015_4);
%inp_rev(source=rif2015.bcarrier_line_05, include_cohort=pop1_CARnum_2015_5);
%inp_rev(source=rif2015.bcarrier_line_06, include_cohort=pop1_CARnum_2015_6);
%inp_rev(source=rif2015.bcarrier_line_07, include_cohort=pop1_CARnum_2015_7);
%inp_rev(source=rif2015.bcarrier_line_08, include_cohort=pop1_CARnum_2015_8);
%inp_rev(source=rif2015.bcarrier_line_09, include_cohort=pop1_CARnum_2015_9);
%inp_rev(source=rif2015.bcarrier_line_10, include_cohort=pop1_CARnum_2015_10);
%inp_rev(source=rif2015.bcarrier_line_11, include_cohort=pop1_CARnum_2015_11);
%inp_rev(source=rif2015.bcarrier_line_12, include_cohort=pop1_CARnum_2015_12);

%inp_rev(source=rif2016.inpatient_revenue_01, include_cohort=pop1_INnum_2016_1);
%inp_rev(source=rif2016.inpatient_revenue_02, include_cohort=pop1_INnum_2016_2);
%inp_rev(source=rif2016.inpatient_revenue_03, include_cohort=pop1_INnum_2016_3);
%inp_rev(source=rif2016.inpatient_revenue_04, include_cohort=pop1_INnum_2016_4);
%inp_rev(source=rif2016.inpatient_revenue_05, include_cohort=pop1_INnum_2016_5);
%inp_rev(source=rif2016.inpatient_revenue_06, include_cohort=pop1_INnum_2016_6);
%inp_rev(source=rif2016.inpatient_revenue_07, include_cohort=pop1_INnum_2016_7);
%inp_rev(source=rif2016.inpatient_revenue_08, include_cohort=pop1_INnum_2016_8);
%inp_rev(source=rif2016.inpatient_revenue_09, include_cohort=pop1_INnum_2016_9);
%inp_rev(source=rif2016.inpatient_revenue_10, include_cohort=pop1_INnum_2016_10);
%inp_rev(source=rif2016.inpatient_revenue_11, include_cohort=pop1_INnum_2016_11);
%inp_rev(source=rif2016.inpatient_revenue_12, include_cohort=pop1_INnum_2016_12);
%inp_rev(source=rif2016.outpatient_revenue_01, include_cohort=pop1_OUTnum_2016_1);
%inp_rev(source=rif2016.outpatient_revenue_02, include_cohort=pop1_OUTnum_2016_2);
%inp_rev(source=rif2016.outpatient_revenue_03, include_cohort=pop1_OUTnum_2016_3);
%inp_rev(source=rif2016.outpatient_revenue_04, include_cohort=pop1_OUTnum_2016_4);
%inp_rev(source=rif2016.outpatient_revenue_05, include_cohort=pop1_OUTnum_2016_5);
%inp_rev(source=rif2016.outpatient_revenue_06, include_cohort=pop1_OUTnum_2016_6);
%inp_rev(source=rif2016.outpatient_revenue_07, include_cohort=pop1_OUTnum_2016_7);
%inp_rev(source=rif2016.outpatient_revenue_08, include_cohort=pop1_OUTnum_2016_8);
%inp_rev(source=rif2016.outpatient_revenue_09, include_cohort=pop1_OUTnum_2016_9);
%inp_rev(source=rif2016.outpatient_revenue_10, include_cohort=pop1_OUTnum_2016_10);
%inp_rev(source=rif2016.outpatient_revenue_11, include_cohort=pop1_OUTnum_2016_11);
%inp_rev(source=rif2016.outpatient_revenue_12, include_cohort=pop1_OUTnum_2016_12);
%inp_rev(source=rif2016.bcarrier_line_01, include_cohort=pop1_CARnum_2016_1);
%inp_rev(source=rif2016.bcarrier_line_02, include_cohort=pop1_CARnum_2016_2);
%inp_rev(source=rif2016.bcarrier_line_03, include_cohort=pop1_CARnum_2016_3);
%inp_rev(source=rif2016.bcarrier_line_04, include_cohort=pop1_CARnum_2016_4);
%inp_rev(source=rif2016.bcarrier_line_05, include_cohort=pop1_CARnum_2016_5);
%inp_rev(source=rif2016.bcarrier_line_06, include_cohort=pop1_CARnum_2016_6);
%inp_rev(source=rif2016.bcarrier_line_07, include_cohort=pop1_CARnum_2016_7);
%inp_rev(source=rif2016.bcarrier_line_08, include_cohort=pop1_CARnum_2016_8);
%inp_rev(source=rif2016.bcarrier_line_09, include_cohort=pop1_CARnum_2016_9);
%inp_rev(source=rif2016.bcarrier_line_10, include_cohort=pop1_CARnum_2016_10);
%inp_rev(source=rif2016.bcarrier_line_11, include_cohort=pop1_CARnum_2016_11);
%inp_rev(source=rif2016.bcarrier_line_12, include_cohort=pop1_CARnum_2016_12);

%inp_rev(source=rif2017.inpatient_revenue_01, include_cohort=pop1_INnum_2017_1);
%inp_rev(source=rif2017.inpatient_revenue_02, include_cohort=pop1_INnum_2017_2);
%inp_rev(source=rif2017.inpatient_revenue_03, include_cohort=pop1_INnum_2017_3);
%inp_rev(source=rif2017.inpatient_revenue_04, include_cohort=pop1_INnum_2017_4);
%inp_rev(source=rif2017.inpatient_revenue_05, include_cohort=pop1_INnum_2017_5);
%inp_rev(source=rif2017.inpatient_revenue_06, include_cohort=pop1_INnum_2017_6);
%inp_rev(source=rif2017.inpatient_revenue_07, include_cohort=pop1_INnum_2017_7);
%inp_rev(source=rif2017.inpatient_revenue_08, include_cohort=pop1_INnum_2017_8);
%inp_rev(source=rif2017.inpatient_revenue_09, include_cohort=pop1_INnum_2017_9);
%inp_rev(source=rif2017.inpatient_revenue_10, include_cohort=pop1_INnum_2017_10);
%inp_rev(source=rif2017.inpatient_revenue_11, include_cohort=pop1_INnum_2017_11);
%inp_rev(source=rif2017.inpatient_revenue_12, include_cohort=pop1_INnum_2017_12);
%inp_rev(source=rif2017.outpatient_revenue_01, include_cohort=pop1_OUTnum_2017_1);
%inp_rev(source=rif2017.outpatient_revenue_02, include_cohort=pop1_OUTnum_2017_2);
%inp_rev(source=rif2017.outpatient_revenue_03, include_cohort=pop1_OUTnum_2017_3);
%inp_rev(source=rif2017.outpatient_revenue_04, include_cohort=pop1_OUTnum_2017_4);
%inp_rev(source=rif2017.outpatient_revenue_05, include_cohort=pop1_OUTnum_2017_5);
%inp_rev(source=rif2017.outpatient_revenue_06, include_cohort=pop1_OUTnum_2017_6);
%inp_rev(source=rif2017.outpatient_revenue_07, include_cohort=pop1_OUTnum_2017_7);
%inp_rev(source=rif2017.outpatient_revenue_08, include_cohort=pop1_OUTnum_2017_8);
%inp_rev(source=rif2017.outpatient_revenue_09, include_cohort=pop1_OUTnum_2017_9);
%inp_rev(source=rif2017.outpatient_revenue_10, include_cohort=pop1_OUTnum_2017_10);
%inp_rev(source=rif2017.outpatient_revenue_11, include_cohort=pop1_OUTnum_2017_11);
%inp_rev(source=rif2017.outpatient_revenue_12, include_cohort=pop1_OUTnum_2017_12);
%inp_rev(source=rif2017.bcarrier_line_01, include_cohort=pop1_CARnum_2017_1);
%inp_rev(source=rif2017.bcarrier_line_02, include_cohort=pop1_CARnum_2017_2);
%inp_rev(source=rif2017.bcarrier_line_03, include_cohort=pop1_CARnum_2017_3);
%inp_rev(source=rif2017.bcarrier_line_04, include_cohort=pop1_CARnum_2017_4);
%inp_rev(source=rif2017.bcarrier_line_05, include_cohort=pop1_CARnum_2017_5);
%inp_rev(source=rif2017.bcarrier_line_06, include_cohort=pop1_CARnum_2017_6);
%inp_rev(source=rif2017.bcarrier_line_07, include_cohort=pop1_CARnum_2017_7);
%inp_rev(source=rif2017.bcarrier_line_08, include_cohort=pop1_CARnum_2017_8);
%inp_rev(source=rif2017.bcarrier_line_09, include_cohort=pop1_CARnum_2017_9);
%inp_rev(source=rif2017.bcarrier_line_10, include_cohort=pop1_CARnum_2017_10);
%inp_rev(source=rif2017.bcarrier_line_11, include_cohort=pop1_CARnum_2017_11);
%inp_rev(source=rif2017.bcarrier_line_12, include_cohort=pop1_CARnum_2017_12);

%inp_rev(source=rifq2018.inpatient_revenue_01, include_cohort=pop1_INnum_2018_1);
%inp_rev(source=rifq2018.inpatient_revenue_02, include_cohort=pop1_INnum_2018_2);
%inp_rev(source=rifq2018.inpatient_revenue_03, include_cohort=pop1_INnum_2018_3);
%inp_rev(source=rifq2018.inpatient_revenue_04, include_cohort=pop1_INnum_2018_4);
%inp_rev(source=rifq2018.inpatient_revenue_05, include_cohort=pop1_INnum_2018_5);
%inp_rev(source=rifq2018.inpatient_revenue_06, include_cohort=pop1_INnum_2018_6);
%inp_rev(source=rifq2018.inpatient_revenue_07, include_cohort=pop1_INnum_2018_7);
%inp_rev(source=rifq2018.inpatient_revenue_08, include_cohort=pop1_INnum_2018_8);
%inp_rev(source=rifq2018.inpatient_revenue_09, include_cohort=pop1_INnum_2018_9);
%inp_rev(source=rifq2018.inpatient_revenue_10, include_cohort=pop1_INnum_2018_10);
%inp_rev(source=rifq2018.inpatient_revenue_11, include_cohort=pop1_INnum_2018_11);
%inp_rev(source=rifq2018.inpatient_revenue_12, include_cohort=pop1_INnum_2018_12);
%inp_rev(source=rifq2018.outpatient_revenue_01, include_cohort=pop1_OUTnum_2018_1);
%inp_rev(source=rifq2018.outpatient_revenue_02, include_cohort=pop1_OUTnum_2018_2);
%inp_rev(source=rifq2018.outpatient_revenue_03, include_cohort=pop1_OUTnum_2018_3);
%inp_rev(source=rifq2018.outpatient_revenue_04, include_cohort=pop1_OUTnum_2018_4);
%inp_rev(source=rifq2018.outpatient_revenue_05, include_cohort=pop1_OUTnum_2018_5);
%inp_rev(source=rifq2018.outpatient_revenue_06, include_cohort=pop1_OUTnum_2018_6);
%inp_rev(source=rifq2018.outpatient_revenue_07, include_cohort=pop1_OUTnum_2018_7);
%inp_rev(source=rifq2018.outpatient_revenue_08, include_cohort=pop1_OUTnum_2018_8);
%inp_rev(source=rifq2018.outpatient_revenue_09, include_cohort=pop1_OUTnum_2018_9);
%inp_rev(source=rifq2018.outpatient_revenue_10, include_cohort=pop1_OUTnum_2018_10);
%inp_rev(source=rifq2018.outpatient_revenue_11, include_cohort=pop1_OUTnum_2018_11);
%inp_rev(source=rifq2018.outpatient_revenue_12, include_cohort=pop1_OUTnum_2018_12);
%inp_rev(source=rifq2018.bcarrier_line_01, include_cohort=pop1_CARnum_2018_1);
%inp_rev(source=rifq2018.bcarrier_line_02, include_cohort=pop1_CARnum_2018_2);
%inp_rev(source=rifq2018.bcarrier_line_03, include_cohort=pop1_CARnum_2018_3);
%inp_rev(source=rifq2018.bcarrier_line_04, include_cohort=pop1_CARnum_2018_4);
%inp_rev(source=rifq2018.bcarrier_line_05, include_cohort=pop1_CARnum_2018_5);
%inp_rev(source=rifq2018.bcarrier_line_06, include_cohort=pop1_CARnum_2018_6);
%inp_rev(source=rifq2018.bcarrier_line_07, include_cohort=pop1_CARnum_2018_7);
%inp_rev(source=rifq2018.bcarrier_line_08, include_cohort=pop1_CARnum_2018_8);
%inp_rev(source=rifq2018.bcarrier_line_09, include_cohort=pop1_CARnum_2018_9);
%inp_rev(source=rifq2018.bcarrier_line_10, include_cohort=pop1_CARnum_2018_10);
%inp_rev(source=rifq2018.bcarrier_line_11, include_cohort=pop1_CARnum_2018_11);
%inp_rev(source=rifq2018.bcarrier_line_12, include_cohort=pop1_CARnum_2018_12);

data pop_01_num;
set pop1_INnum_2010_1 pop1_INnum_2010_2 pop1_INnum_2010_3 pop1_INnum_2010_4 pop1_INnum_2010_5 pop1_INnum_2010_6 pop1_INnum_2010_7
pop1_INnum_2010_8 pop1_INnum_2010_9 pop1_INnum_2010_10 pop1_INnum_2010_11 pop1_INnum_2010_12
pop1_OUTnum_2010_1 pop1_OUTnum_2010_2 pop1_OUTnum_2010_3 pop1_OUTnum_2010_4 pop1_OUTnum_2010_5 pop1_OUTnum_2010_6 pop1_OUTnum_2010_7
pop1_OUTnum_2010_8 pop1_OUTnum_2010_9 pop1_OUTnum_2010_10 pop1_OUTnum_2010_11 pop1_OUTnum_2010_12
pop1_CARnum_2010_1 pop1_CARnum_2010_2 pop1_CARnum_2010_3 pop1_CARnum_2010_4 pop1_CARnum_2010_5 pop1_CARnum_2010_6 pop1_CARnum_2010_7
pop1_CARnum_2010_8 pop1_CARnum_2010_9 pop1_CARnum_2010_10 pop1_CARnum_2010_11 pop1_CARnum_2010_12

pop1_INnum_2011_1 pop1_INnum_2011_2 pop1_INnum_2011_3 pop1_INnum_2011_4 pop1_INnum_2011_5 pop1_INnum_2011_6 pop1_INnum_2011_7
pop1_INnum_2011_8 pop1_INnum_2011_9 pop1_INnum_2011_10 pop1_INnum_2011_11 pop1_INnum_2011_12
pop1_OUTnum_2011_1 pop1_OUTnum_2011_2 pop1_OUTnum_2011_3 pop1_OUTnum_2011_4 pop1_OUTnum_2011_5 pop1_OUTnum_2011_6 pop1_OUTnum_2011_7
pop1_OUTnum_2011_8 pop1_OUTnum_2011_9 pop1_OUTnum_2011_10 pop1_OUTnum_2011_11 pop1_OUTnum_2011_12
pop1_CARnum_2011_1 pop1_CARnum_2011_2 pop1_CARnum_2011_3 pop1_CARnum_2011_4 pop1_CARnum_2011_5 pop1_CARnum_2011_6 pop1_CARnum_2011_7
pop1_CARnum_2011_8 pop1_CARnum_2011_9 pop1_CARnum_2011_10 pop1_CARnum_2011_11 pop1_CARnum_2011_12

pop1_INnum_2012_1 pop1_INnum_2012_2 pop1_INnum_2012_3 pop1_INnum_2012_4 pop1_INnum_2012_5 pop1_INnum_2012_6 pop1_INnum_2012_7
pop1_INnum_2012_8 pop1_INnum_2012_9 pop1_INnum_2012_10 pop1_INnum_2012_11 pop1_INnum_2012_12
pop1_OUTnum_2012_1 pop1_OUTnum_2012_2 pop1_OUTnum_2012_3 pop1_OUTnum_2012_4 pop1_OUTnum_2012_5 pop1_OUTnum_2012_6 pop1_OUTnum_2012_7
pop1_OUTnum_2012_8 pop1_OUTnum_2012_9 pop1_OUTnum_2012_10 pop1_OUTnum_2012_11 pop1_OUTnum_2012_12
pop1_CARnum_2012_1 pop1_CARnum_2012_2 pop1_CARnum_2012_3 pop1_CARnum_2012_4 pop1_CARnum_2012_5 pop1_CARnum_2012_6 pop1_CARnum_2012_7
pop1_CARnum_2012_8 pop1_CARnum_2012_9 pop1_CARnum_2012_10 pop1_CARnum_2012_11 pop1_CARnum_2012_12

pop1_INnum_2013_1 pop1_INnum_2013_2 pop1_INnum_2013_3 pop1_INnum_2013_4 pop1_INnum_2013_5 pop1_INnum_2013_6 pop1_INnum_2013_7
pop1_INnum_2013_8 pop1_INnum_2013_9 pop1_INnum_2013_10 pop1_INnum_2013_11 pop1_INnum_2013_12
pop1_OUTnum_2013_1 pop1_OUTnum_2013_2 pop1_OUTnum_2013_3 pop1_OUTnum_2013_4 pop1_OUTnum_2013_5 pop1_OUTnum_2013_6 pop1_OUTnum_2013_7
pop1_OUTnum_2013_8 pop1_OUTnum_2013_9 pop1_OUTnum_2013_10 pop1_OUTnum_2013_11 pop1_OUTnum_2013_12
pop1_CARnum_2013_1 pop1_CARnum_2013_2 pop1_CARnum_2013_3 pop1_CARnum_2013_4 pop1_CARnum_2013_5 pop1_CARnum_2013_6 pop1_CARnum_2013_7
pop1_CARnum_2013_8 pop1_CARnum_2013_9 pop1_CARnum_2013_10 pop1_CARnum_2013_11 pop1_CARnum_2013_12

pop1_INnum_2014_1 pop1_INnum_2014_2 pop1_INnum_2014_3 pop1_INnum_2014_4 pop1_INnum_2014_5 pop1_INnum_2014_6 pop1_INnum_2014_7
pop1_INnum_2014_8 pop1_INnum_2014_9 pop1_INnum_2014_10 pop1_INnum_2014_11 pop1_INnum_2014_12
pop1_OUTnum_2014_1 pop1_OUTnum_2014_2 pop1_OUTnum_2014_3 pop1_OUTnum_2014_4 pop1_OUTnum_2014_5 pop1_OUTnum_2014_6 pop1_OUTnum_2014_7
pop1_OUTnum_2014_8 pop1_OUTnum_2014_9 pop1_OUTnum_2014_10 pop1_OUTnum_2014_11 pop1_OUTnum_2014_12
pop1_CARnum_2014_1 pop1_CARnum_2014_2 pop1_CARnum_2014_3 pop1_CARnum_2014_4 pop1_CARnum_2014_5 pop1_CARnum_2014_6 pop1_CARnum_2014_7
pop1_CARnum_2014_8 pop1_CARnum_2014_9 pop1_CARnum_2014_10 pop1_CARnum_2014_11 pop1_CARnum_2014_12

pop1_INnum_2015_1 pop1_INnum_2015_2 pop1_INnum_2015_3 pop1_INnum_2015_4 pop1_INnum_2015_5 pop1_INnum_2015_6 pop1_INnum_2015_7
pop1_INnum_2015_8 pop1_INnum_2015_9 pop1_INnum_2015_10 pop1_INnum_2015_11 pop1_INnum_2015_12
pop1_OUTnum_2015_1 pop1_OUTnum_2015_2 pop1_OUTnum_2015_3 pop1_OUTnum_2015_4 pop1_OUTnum_2015_5 pop1_OUTnum_2015_6 pop1_OUTnum_2015_7
pop1_OUTnum_2015_8 pop1_OUTnum_2015_9 pop1_OUTnum_2015_10 pop1_OUTnum_2015_11 pop1_OUTnum_2015_12
pop1_CARnum_2015_1 pop1_CARnum_2015_2 pop1_CARnum_2015_3 pop1_CARnum_2015_4 pop1_CARnum_2015_5 pop1_CARnum_2015_6 pop1_CARnum_2015_7
pop1_CARnum_2015_8 pop1_CARnum_2015_9 pop1_CARnum_2015_10 pop1_CARnum_2015_11 pop1_CARnum_2015_12

pop1_INnum_2016_1 pop1_INnum_2016_2 pop1_INnum_2016_3 pop1_INnum_2016_4 pop1_INnum_2016_5 pop1_INnum_2016_6 pop1_INnum_2016_7
pop1_INnum_2016_8 pop1_INnum_2016_9 pop1_INnum_2016_10 pop1_INnum_2016_11 pop1_INnum_2016_12
pop1_OUTnum_2016_1 pop1_OUTnum_2016_2 pop1_OUTnum_2016_3 pop1_OUTnum_2016_4 pop1_OUTnum_2016_5 pop1_OUTnum_2016_6 pop1_OUTnum_2016_7
pop1_OUTnum_2016_8 pop1_OUTnum_2016_9 pop1_OUTnum_2016_10 pop1_OUTnum_2016_11 pop1_OUTnum_2016_12
pop1_CARnum_2016_1 pop1_CARnum_2016_2 pop1_CARnum_2016_3 pop1_CARnum_2016_4 pop1_CARnum_2016_5 pop1_CARnum_2016_6 pop1_CARnum_2016_7
pop1_CARnum_2016_8 pop1_CARnum_2016_9 pop1_CARnum_2016_10 pop1_CARnum_2016_11 pop1_CARnum_2016_12

pop1_INnum_2017_1 pop1_INnum_2017_2 pop1_INnum_2017_3 pop1_INnum_2017_4 pop1_INnum_2017_5 pop1_INnum_2017_6 pop1_INnum_2017_7
pop1_INnum_2017_8 pop1_INnum_2017_9 pop1_INnum_2017_10 pop1_INnum_2017_11 pop1_INnum_2017_12
pop1_OUTnum_2017_1 pop1_OUTnum_2017_2 pop1_OUTnum_2017_3 pop1_OUTnum_2017_4 pop1_OUTnum_2017_5 pop1_OUTnum_2017_6 pop1_OUTnum_2017_7
pop1_OUTnum_2017_8 pop1_OUTnum_2017_9 pop1_OUTnum_2017_10 pop1_OUTnum_2017_11 pop1_OUTnum_2017_12
pop1_CARnum_2017_1 pop1_CARnum_2017_2 pop1_CARnum_2017_3 pop1_CARnum_2017_4 pop1_CARnum_2017_5 pop1_CARnum_2017_6 pop1_CARnum_2017_7
pop1_CARnum_2017_8 pop1_CARnum_2017_9 pop1_CARnum_2017_10 pop1_CARnum_2017_11 pop1_CARnum_2017_12

pop1_INnum_2018_1 pop1_INnum_2018_2 pop1_INnum_2018_3 pop1_INnum_2018_4 pop1_INnum_2018_5 pop1_INnum_2018_6 pop1_INnum_2018_7
pop1_INnum_2018_8 pop1_INnum_2018_9 pop1_INnum_2018_10 pop1_INnum_2018_11 pop1_INnum_2018_12
pop1_OUTnum_2018_1 pop1_OUTnum_2018_2 pop1_OUTnum_2018_3 pop1_OUTnum_2018_4 pop1_OUTnum_2018_5 pop1_OUTnum_2018_6 pop1_OUTnum_2018_7
pop1_OUTnum_2018_8 pop1_OUTnum_2018_9 pop1_OUTnum_2018_10 pop1_OUTnum_2018_11 pop1_OUTnum_2018_12
pop1_CARnum_2018_1 pop1_CARnum_2018_2 pop1_CARnum_2018_3 pop1_CARnum_2018_4 pop1_CARnum_2018_5 pop1_CARnum_2018_6 pop1_CARnum_2018_7
pop1_CARnum_2018_8 pop1_CARnum_2018_9 pop1_CARnum_2018_10 pop1_CARnum_2018_11 pop1_CARnum_2018_12
;
run;
proc sort data=pop_01_num NODUPKEY;by bene_id clm_admsn_dt;run;

*merge denominator and numerator files;
data pop_01; retain popped_01 pop_01_elig bene_id clm_admsn_dt clm_thru_dt clm_id;
merge pop_01_denom pop_01_num;
by bene_id clm_admsn_dt;
if popped_01=. then popped_01=0;
if pop_01_year<2010 then delete;
label pop_01_age='age on admission date';
label pop_01_elig='indicator of eligiblity (denominator)';
label pop_01_setting='inpatient or outpatient indicator';
label popped_01='eligible and experienced overuse pop';
run;
proc print data=pop_01 (obs=20); run;
proc contents data=pop_01; run;
Proc freq data=pop_01; table pop_01_year*popped_01 pop_01_setting*popped_01; run;


*start;
*bring in chronic conditions---associated with denominator first then match to the num-denom file;
%macro line(abcd=, include_cohort=);
proc sql;
create table &include_cohort (compress=yes) as
select  
a.bene_id, b.*
from 
pop_01_denom a,
&abcd b
where a.bene_id=b.bene_id;
quit;
%mend;
%line(abcd=mbsf.mbsf_cc_2018, include_cohort=cc_2018); *not available as of 8/21/2019;
%line(abcd=mbsf.mbsf_cc_2017, include_cohort=cc_2017); *3,182,460;
%line(abcd=mbsf.mbsf_cc_2016, include_cohort=cc_2016); 
%line(abcd=mbsf.mbsf_cc_2015, include_cohort=cc_2015); 
%line(abcd=mbsf.mbsf_cc_2014, include_cohort=cc_2014); 
%line(abcd=mbsf.mbsf_cc_2013, include_cohort=cc_2013); 
%line(abcd=mbsf.mbsf_cc_2012, include_cohort=cc_2012); 
%line(abcd=mbsf.mbsf_cc_2011, include_cohort=cc_2011); 
%line(abcd=mbsf.mbsf_cc_2010, include_cohort=cc_2010); *5,013,424;

data cc (keep=bene_id ami ami_ever alzh_ever alzh_demen_ever atrial_fib_ever
cataract_ever chronickidney_ever copd_ever chf_ever diabetes_ever glaucoma_ever  hip_fracture_ever 
ischemicheart_ever depression_ever osteoporosis_ever ra_oa_ever stroke_tia_ever cancer_breast_ever
cancer_colorectal_ever cancer_prostate_ever cancer_lung_ever cancer_endometrial_ever anemia_ever asthma_ever
hyperl_ever hyperp_ever hypert_ever hypoth_ever );
merge 
cc_2010 cc_2011 cc_2012 cc_2013 cc_2014 cc_2015 cc_2016 cc_2017;* cc_2018;
by bene_id;
run; 
proc sort data=cc nodupkey; by bene_id; run;*4,032,128;
proc print data=cc (obs=20); run; *this has chronic condition outcomes EVER (not tied to the proc date);
proc freq data=cc; table ami; run;

*make chronic conitions indicators;
proc sort data=pop_01; by bene_id; run;
data pop_01_cc; 
merge cc (in=a) pop_01 (in=b);
if a and b;
by bene_id;
if ami_ever ne . and ami_ever<CLM_ADMSN_DT then cc_ami=1; else cc_ami=0;
if alzh_ever ne . and alzh_ever <CLM_ADMSN_DT then cc_alzh=1; else cc_alzh=0;
if alzh_demen_ever ne . and alzh_demen_ever <CLM_ADMSN_DT then cc_alzh_demen=1; else cc_alzh_demen=0;
if atrial_fib_ever ne . and atrial_fib_ever<CLM_ADMSN_DT then cc_atrial_fib=1; else cc_atrial_fib=0;
if cataract_ever ne . and cataract_ever <CLM_ADMSN_DT then cc_cataract=1; else cc_cataract=0;
if chronickidney_ever ne . and chronickidney_ever<CLM_ADMSN_DT then cc_chronickidney=1; else cc_chronickidney=0;
if copd_ever ne . and copd_ever <CLM_ADMSN_DT then cc_copd=1; else cc_copd=0;
if chf_ever ne . and chf_ever <CLM_ADMSN_DT then cc_chf=1; else cc_chf=0;
if diabetes_ever ne . and diabetes_ever <CLM_ADMSN_DT then cc_diabetes=1; else cc_diabetes=0;
if glaucoma_ever ne . and glaucoma_ever  <CLM_ADMSN_DT then cc_glaucoma=1; else cc_glaucoma=0;
if hip_fracture_ever ne . and hip_fracture_ever <CLM_ADMSN_DT then cc_hip_fracture=1; else cc_hip_fracture=0;
if ischemicheart_ever ne . and ischemicheart_ever<CLM_ADMSN_DT then cc_ischemicheart=1; else cc_ischemicheart=0;
if depression_ever ne . and depression_ever <CLM_ADMSN_DT then cc_depression=1; else cc_depression=0;
if osteoporosis_ever ne . and osteoporosis_ever <CLM_ADMSN_DT then cc_osteoporosis=1; else cc_osteoporosis=0;
if ra_oa_ever ne . and ra_oa_ever <CLM_ADMSN_DT then cc_ra_oa=1; else cc_ra_oa=0;
if stroke_tia_ever  ne . and stroke_tia_ever <CLM_ADMSN_DT then cc_stroke_tia=1; else cc_stroke_tia=0;
if cancer_breast_ever ne . and cancer_breast_ever<CLM_ADMSN_DT then cc_cancer_breast=1; else cc_cancer_breast=0;
if cancer_colorectal_ever ne . and cancer_colorectal_ever<CLM_ADMSN_DT then cc_cancer_colorectal=1; else cc_cancer_colorectal=0;
if cancer_prostate_ever ne . and cancer_prostate_ever <CLM_ADMSN_DT then cc_cancer_prostate=1; else cc_cancer_prostate=0;
if cancer_lung_ever ne . and cancer_lung_ever <CLM_ADMSN_DT then cc_cancer_lung=1; else cc_cancer_lung=0;
if cancer_endometrial_ever ne . and cancer_endometrial_ever<CLM_ADMSN_DT then cc_cancer_endometrial=1; else cc_cancer_endometrial=0;
if anemia_ever ne . and anemia_ever <CLM_ADMSN_DT then cc_anemia=1; else cc_anemia=0;
if asthma_ever ne . and asthma_ever<CLM_ADMSN_DT then cc_asthma=1; else cc_asthma=0;
if hyperl_ever ne . and hyperl_ever <CLM_ADMSN_DT then cc_hyperl=1; else cc_hyperl=0;
if hyperp_ever ne . and hyperp_ever <CLM_ADMSN_DT then cc_hyperp=1; else cc_hyperp=0;
if hypert_ever ne . and hypert_ever <CLM_ADMSN_DT then cc_hypert=1; else cc_hypert=0;
if hypoth_ever ne . and hypoth_ever<CLM_ADMSN_DT then cc_hypoth=1; else cc_hypoth=0;
cc_sum=sum(cc_ami, cc_alzh, cc_alzh_demen, cc_atrial_fib, cc_chronickidney, cc_copd, cc_chf, cc_diabetes, cc_glaucoma, cc_hip_fracture,
cc_ischemicheart, cc_depression, cc_osteoporosis, cc_ra_oa, cc_stroke_tia, cc_cancer_breast, cc_cancer_colorectal, cc_cancer_prostate,
cc_cancer_lung, cc_cancer_endometrial, cc_anemia, cc_asthma, cc_hyperl, cc_hyperp, cc_hypert, cc_hypoth);
if cc_sum=0     then cc_cat='0  ';
if 1<=cc_sum<=5 then cc_cat='1-5';
if 6<=cc_sum<=9 then cc_cat='6-9';
if cc_sum>=10   then cc_cat='10+';
if     pop_01_age<65 then age_cat='LT 65';
if 65<=pop_01_age<70 then age_cat='65-69';
if 70<=pop_01_age<75 then age_cat='70-74';
if 75<=pop_01_age<79 then age_cat='75-79';
if 79<=pop_01_age<84 then age_cat='80-84';
if pop_01_age>=84     then age_cat='85-95';
run;*5,630,196--only include those with CC info;


*model;
PROC logistic DATA=pop_01_cc; 
class pop_01_year(ref=first) gndr_cd(ref='2')  bene_race_cd(ref=first) cc_cat(ref='6-9') age_cat(ref=first)/param=ref;
model popped_01 (event='1')= pop_01_year gndr_cd bene_race_cd age_cat cc_cat;*pop_01_age ed_admit;
      output out=pop_01_model p=pred_popped_01;
	  ods output parameterestimates=parameterestimates;
run;
proc print data=pop_01_model (obs=20); var bene_id popped_01 pred_popped_01; run;
proc print data=parameterestimates; run;

*mean without hospital denominator;
proc means data=pop_01; var popped_01; run;
proc means data=pop_01_cc; var popped_01; run;
proc freq data=pop_01_cc; table popped_01; run;

*proc contents, histogram by prvdr_num, overall freq of popped*pop_elig;
proc print data=pop_01_cc; where prvdr_num=' '; run; *make sure none missing hospital id;
proc sort data=pop_01_cc; by prvdr_num;
proc summary data=pop_01_cc;
by prvdr_num;
var popped_01;
output out=popped_01_sum_per_hosp (rename=(_freq_=popped_01_elig)) 
	   sum= /autoname; 
run; 
data popped_01_sum_per_hosp (drop=_type_); set popped_01_sum_per_hosp; 
where _type_=0;
popped_01_percent=(popped_01_sum/popped_01_elig)*100;
label popped_01_percent='percent of eligible that experienced pop';
label popped_01_elig='eligible for pop';
run;
proc means data=popped_01_sum_per_hosp; var popped_01_percent popped_01_sum popped_01_elig; run;
ods graphics on;
title 'Pop 1 Percent by Hospital (prvdr_num)';
proc univariate data=popped_01_sum_per_hosp noprint;
   histogram popped_01_percent / midpoints    = 0 to 100 by 1;*  odstitle = title;
run;
*print provider number and percent popped for outliers;
proc sort data=popped_01_sum_per_hosp; by popped_01_percent; run;
proc print data=popped_01_sum_per_hosp; where popped_01_percent>=1 and popped_01_elig>=11;
var prvdr_num popped_01_percent popped_01_elig;
run;

*merge to state of prvdr_num for mapping--don't have county number of prvdr on file (only bene);
proc sort data=popped_01_sum_per_hosp; by prvdr_num;
proc sort data=pop_01_cc nodupkey out=pop_01_prvdr_state (keep= prvdr_num prvdr_state_cd); by prvdr_num; run;

data popped_01_MAP_per_hosp;
merge popped_01_sum_per_hosp (in=a) pop_01_prvdr_state (in=b);
by prvdr_num;
run;

*merge in fips county code info for mapping;
*add conversion from ssa to fips codes;
*libname ssa_fips 'S:\CMS\IBD Helmsley\ssa_fips\';
data ssa_fips14 (drop=cbsa cbsaname county state ssastate ssacounty); 
set _uplds.ssa_fips_state_county2014;*fips2017 also available in uploads;
*assign SSA to same variable names as CMS data;
prvdr_state_cd=ssastate;
bene_state_cd=ssastate;	
bene_cnty_cd=substrn(ssacounty,3,3);*length bene_cnty_cd $3;
run;
proc sort data=ssa_fips14; by prvdr_state_cd;* bene_cnty_cd; run;
proc sort data=popped_01_MAP_per_hosp; by prvdr_state_cd;* bene_cnty_cd; run;
data popped_01_MAP_per_hosp2;
	merge popped_01_MAP_per_hosp(in=a) ssa_fips14 (in=b);
	by prvdr_state_cd;* bene_cnty_cd;
	if a and b;
if prvdr_state_cd=' ' then delete;
if fipsstate=' ' then delete;
if prvdr_num=' ' then delete; 
if popped_01_percent=. then delete;
run;

*reshape so 1 record per state;
	proc sort data=popped_01_MAP_per_hosp2; by fipsstate; run;
	proc means data=popped_01_MAP_per_hosp2;
	  class fipsstate;
	  var popped_01_percent;
	  output out=popped_01_percent_sum;
	run;
	proc sql noprint;
	create table popped_01_percent_state as
	select input(fipsstate,2.0) as state, popped_01_percent AS  popped_01_percent_STATE from popped_01_percent_sum where _type_=1 and _stat_='MEAN';
quit;
*map state percentages to us50 map;
	pattern1 v=ms c=cxd6eaff; pattern2 v=ms c=cxa0c6ef; pattern3 v=ms c=cx6ba3df; pattern4 v=ms c=cx357fcf; pattern5 v=ms c=cx005cbf;
	proc gmap data=popped_01_percent_state map=mapsgfk.us;
		id state;
		choro popped_01_percent_STATE  / levels=5; label popped_01_percent_STATE='Percent with Pop 1';
	run;

*stop;


/*model from H-Y word file;
proc surveyreg Data=pop_01;
class popped_01 bene_state_cd morbidity  pop_01_age gndr_cd bene_race_cd;
model pop = bene_state_cd morbidity gndr_cd pop_01_age bene_race_cd pop_num noint solution;
ods output ParameterEstimates=jhoi;
run;

*List of included ICD-9 and ICD-10 codes and their descriptions;
icd9cm	icd10cm	icd9_description				icd10_description								icd10_description
4111	I200	Intermediate coronary syndrome	Unstable angina
4111	I200	Intermediate coronary syndrome	Unstable angina
41000	I2109	Acute myocardial infarction of anterolateral wall, episode of care unspecified	ST elevation (STEMI) myocardial infarction involving other cor
41000	I2109	Acute myocardial infarction of anterolateral wall, episode of care unspecified	ST elevation (STEMI) myocardial infarction involving other cor
41001	I2109	Acute myocardial infarction of anterolateral wall, initial episode of care	ST elevation (STEMI) myocardial infarction involving other cor
41001	I2109	Acute myocardial infarction of anterolateral wall, initial episode of care	ST elevation (STEMI) myocardial infarction involving other cor
41002	I2109	Acute myocardial infarction of anterolateral wall, subsequent episode of care	ST elevation (STEMI) myocardial infarction involving other cor
41002	I2109	Acute myocardial infarction of anterolateral wall, subsequent episode of care	ST elevation (STEMI) myocardial infarction involving other cor
41010	I2109	Acute myocardial infarction of other anterior wall, episode of care unspecified	ST elevation (STEMI) myocardial infarction involving other cor
41010	I2109	Acute myocardial infarction of other anterior wall, episode of care unspecified	ST elevation (STEMI) myocardial infarction involving other cor
41011	I2109	Acute myocardial infarction of other anterior wall, initial episode of care	ST elevation (STEMI) myocardial infarction involving other cor
41011	I2109	Acute myocardial infarction of other anterior wall, initial episode of care	ST elevation (STEMI) myocardial infarction involving other cor
41012	I2109	Acute myocardial infarction of other anterior wall, subsequent episode of care	ST elevation (STEMI) myocardial infarction involving other cor
41012	I2109	Acute myocardial infarction of other anterior wall, subsequent episode of care	ST elevation (STEMI) myocardial infarction involving other cor
41030	I2111	Acute myocardial infarction of inferoposterior wall, episode of care unspecified	ST elevation (STEMI) myocardial infarction involving right cor
41030	I2111	Acute myocardial infarction of inferoposterior wall, episode of care unspecified	ST elevation (STEMI) myocardial infarction involving right cor
41031	I2111	Acute myocardial infarction of inferoposterior wall, initial episode of care	ST elevation (STEMI) myocardial infarction involving right cor
41031	I2111	Acute myocardial infarction of inferoposterior wall, initial episode of care	ST elevation (STEMI) myocardial infarction involving right cor
41032	I2111	Acute myocardial infarction of inferoposterior wall, subsequent episode of care	ST elevation (STEMI) myocardial infarction involving right cor
41032	I2111	Acute myocardial infarction of inferoposterior wall, subsequent episode of care	ST elevation (STEMI) myocardial infarction involving right cor
41020	I2119	Acute myocardial infarction of inferolateral wall, episode of care unspecified	ST elevation (STEMI) myocardial infarction involving other cor
41020	I2119	Acute myocardial infarction of inferolateral wall, episode of care unspecified	ST elevation (STEMI) myocardial infarction involving other cor
41021	I2119	Acute myocardial infarction of inferolateral wall, initial episode of care	ST elevation (STEMI) myocardial infarction involving other cor
41021	I2119	Acute myocardial infarction of inferolateral wall, initial episode of care	ST elevation (STEMI) myocardial infarction involving other cor
41022	I2119	Acute myocardial infarction of inferolateral wall, subsequent episode of care	ST elevation (STEMI) myocardial infarction involving other cor
41022	I2119	Acute myocardial infarction of inferolateral wall, subsequent episode of care	ST elevation (STEMI) myocardial infarction involving other cor
41040	I2119	Acute myocardial infarction of other inferior wall, episode of care unspecified	ST elevation (STEMI) myocardial infarction involving other cor
41040	I2119	Acute myocardial infarction of other inferior wall, episode of care unspecified	ST elevation (STEMI) myocardial infarction involving other cor
41041	I2119	Acute myocardial infarction of other inferior wall, initial episode of care	ST elevation (STEMI) myocardial infarction involving other cor
41041	I2119	Acute myocardial infarction of other inferior wall, initial episode of care	ST elevation (STEMI) myocardial infarction involving other cor
41042	I2119	Acute myocardial infarction of other inferior wall, subsequent episode of care	ST elevation (STEMI) myocardial infarction involving other cor
41042	I2119	Acute myocardial infarction of other inferior wall, subsequent episode of care	ST elevation (STEMI) myocardial infarction involving other cor
41050	I2129	Acute myocardial infarction of other lateral wall, episode of care unspecified	ST elevation (STEMI) myocardial infarction involving other sit
41050	I2129	Acute myocardial infarction of other lateral wall, episode of care unspecified	ST elevation (STEMI) myocardial infarction involving other sit
41051	I2129	Acute myocardial infarction of other lateral wall, initial episode of care	ST elevation (STEMI) myocardial infarction involving other sit
41051	I2129	Acute myocardial infarction of other lateral wall, initial episode of care	ST elevation (STEMI) myocardial infarction involving other sit
41052	I2129	Acute myocardial infarction of other lateral wall, subsequent episode of care	ST elevation (STEMI) myocardial infarction involving other sit
41052	I2129	Acute myocardial infarction of other lateral wall, subsequent episode of care	ST elevation (STEMI) myocardial infarction involving other sit
41060	I2129	True posterior wall infarction, episode of care unspecified	ST elevation (STEMI) myocardial infarction involving other sit
41060	I2129	True posterior wall infarction, episode of care unspecified	ST elevation (STEMI) myocardial infarction involving other sit
41061	I2129	True posterior wall infarction, initial episode of care	ST elevation (STEMI) myocardial infarction involving other sit
41061	I2129	True posterior wall infarction, initial episode of care	ST elevation (STEMI) myocardial infarction involving other sit
41062	I2129	True posterior wall infarction, subsequent episode of care	ST elevation (STEMI) myocardial infarction involving other sit
41062	I2129	True posterior wall infarction, subsequent episode of care	ST elevation (STEMI) myocardial infarction involving other sit
41080	I2129	Acute myocardial infarction of other specified sites, episode of care unspecified	ST elevation (STEMI) myocardial infarction involving other sit
41080	I2129	Acute myocardial infarction of other specified sites, episode of care unspecified	ST elevation (STEMI) myocardial infarction involving other sit
41081	I2129	Acute myocardial infarction of other specified sites, initial episode of care	ST elevation (STEMI) myocardial infarction involving other sit
41081	I2129	Acute myocardial infarction of other specified sites, initial episode of care	ST elevation (STEMI) myocardial infarction involving other sit
41082	I2129	Acute myocardial infarction of other specified sites, subsequent episode of care	ST elevation (STEMI) myocardial infarction involving other sit
41082	I2129	Acute myocardial infarction of other specified sites, subsequent episode of care	ST elevation (STEMI) myocardial infarction involving other sit
41090	I213	Acute myocardial infarction of unspecified site, episode of care unspecified	ST elevation (STEMI) myocardial infarction of unspecified site
41090	I213	Acute myocardial infarction of unspecified site, episode of care unspecified	ST elevation (STEMI) myocardial infarction of unspecified site
41091	I213	Acute myocardial infarction of unspecified site, initial episode of care	ST elevation (STEMI) myocardial infarction of unspecified site
41091	I213	Acute myocardial infarction of unspecified site, initial episode of care	ST elevation (STEMI) myocardial infarction of unspecified site
41092	I213	Acute myocardial infarction of unspecified site, subsequent episode of care	ST elevation (STEMI) myocardial infarction of unspecified site
41092	I213	Acute myocardial infarction of unspecified site, subsequent episode of care	ST elevation (STEMI) myocardial infarction of unspecified site
41070	I214	Subendocardial infarction, episode of care unspecified	Non-ST elevation (NSTEMI) myocardial infarction
41070	I214	Subendocardial infarction, episode of care unspecified	Non-ST elevation (NSTEMI) myocardial infarction
41071	I214	Subendocardial infarction, initial episode of care	Non-ST elevation (NSTEMI) myocardial infarction
41071	I214	Subendocardial infarction, initial episode of care	Non-ST elevation (NSTEMI) myocardial infarction
41072	I214	Subendocardial infarction, subsequent episode of care	Non-ST elevation (NSTEMI) myocardial infarction
41072	I214	Subendocardial infarction, subsequent episode of care	Non-ST elevation (NSTEMI) myocardial infarction
41181	I240	Acute coronary occlusion without myocardial infarction	Acute coronary thrombosis not resulting in myocardial infarcti
41181	I240	Acute coronary occlusion without myocardial infarction	Acute coronary thrombosis not resulting in myocardial infarcti
41189	I248	Other acute and subacute forms of ischemic heart disease, other	Other forms of acute ischemic heart disease
41189	I248	Other acute and subacute forms of ischemic heart disease, other	Other forms of acute ischemic heart disease
;
