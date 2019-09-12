*Pop 11: Hysterectomy;
*Eligible: all women with a hysterectomy;
*Popped: had hysterectomy without female genital organ malignancy (vulva, vagina, uterus, ovary, unspecified--all but placenta--if had hysterectomy for placenta malignancy then not considered a "pop");
%let pop11_hcpcs='58150', '58152', '58180', '58260', '58262', '58263', '58267', '58270', '58275', '58280', '58285', '58290',
				'58291', '58292', '59293', '59294', '58200', '58210', '58541', '58542', '58543', '58544', '58548', 
				'58550', '58552', '58553', '58554', '58570','58571', '58572', '58573'; *Hysterectomy (radical: 58548, 58285, 58210);
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

*create formats for dgns, drg, hcpcs for easier data checks;
proc sort data=METADX.CCW_RFRNC_dgns_CD NODUPKEY OUT=dgns; BY dgns_CD dgns_DESC; RUN; *799;
proc sort data=dgns ; by dgns_cd descending dgns_efctv_dt; run;
proc sort data=dgns NODUPKEY out=dgns2 dupout=dgns_dup; by dgns_cd; run;
proc print data=dgns_dup; run;
data fmtdgns (rename=(dgns_CD=start));
set dgns2 (keep = dgns_cd dgns_desc);
fmtname='$dgns';
label = dgns_cd ||": " || dgns_desc;
run;
proc format cntlin=fmtdgns; run;

proc sort data=METADX.CCW_RFRNC_DRG_CD NODUPKEY OUT=DRG; WHERE DRG_EFCTV_DT>='01JAN2013'D; BY DRG_CD DRG_DESC; RUN; *799;
proc sort data=drg ; by drg_cd descending drg_efctv_dt; run;
proc sort data=drg NODUPKEY out=drg2 dupout=drg_dup; by drg_cd; run;
proc print data=drg_dup; run;
data fmtDRG (rename=(DRG_CD=start));
set DRG2 (keep = drg_cd drg_desc);
fmtname='$DRG';
label = drg_cd ||": " || drg_desc;
run;
proc format cntlin=fmtDRG; run;

proc sort data=METADX.CCW_RFRNC_hcpcs_CD NODUPKEY OUT=hcpcs; BY hcpcs_CD hcpcs_shrt_desc; RUN; *799;
proc sort data=hcpcs ; by hcpcs_cd descending hcpcs_actn_efctv_dt; run;
proc sort data=hcpcs NODUPKEY out=hcpcs2 dupout=hcpcs_dup; by hcpcs_cd; run;
proc print data=hcpcs_dup; run;
data fmthcpcs (rename=(hcpcs_CD=start));
set hcpcs2 (keep = hcpcs_cd hcpcs_shrt_desc);
fmtname='$hcpcs';
label = hcpcs_cd ||": " || hcpcs_shrt_desc;
run;
proc format cntlin=fmthcpcs; run;



*First: Identify HCPCS codes for hysterectomy from inpatient, outpatient, carrier;
*denominator for inpatient, outpatient, carrier;
%macro claims_rev(source=, rev_cohort=, include_cohort=);
proc sql;
create table include_cohort1 (compress=yes) as
select *
from 
&rev_cohort
where 
hcpcs_cd in (&pop11_hcpcs);
quit;
proc sql;
create table include_cohort2 (compress=yes) as
select *
from 
include_cohort1 a, 
&source b
where 
(a.bene_id=b.bene_id and a.clm_id=b.clm_id) or b.clm_drg_cd in(&pop11_drg);		*check that code still works on outpatient/carrier;
quit;
Data &include_cohort (keep=pop:
		bene_id gndr_cd bene_race_cd bene_cnty_cd bene_state_cd bene_mlg_cntct_zip_cd  
		prvdr_num prvdr_state_cd at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi rfr_physn_npi prf_physn_npi); 
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
%claims_rev(source=rif2010.inpatient_claims_01, rev_cohort=rif2010.inpatient_revenue_01, include_cohort=pop_11_indenom_2010_1);
%claims_rev(source=rif2010.inpatient_claims_02, rev_cohort=rif2010.inpatient_revenue_02, include_cohort=pop_11_indenom_2010_2);
%claims_rev(source=rif2010.inpatient_claims_03, rev_cohort=rif2010.inpatient_revenue_03, include_cohort=pop_11_indenom_2010_3);
%claims_rev(source=rif2010.inpatient_claims_04, rev_cohort=rif2010.inpatient_revenue_04, include_cohort=pop_11_indenom_2010_4);
%claims_rev(source=rif2010.inpatient_claims_05, rev_cohort=rif2010.inpatient_revenue_05, include_cohort=pop_11_indenom_2010_5);
%claims_rev(source=rif2010.inpatient_claims_06, rev_cohort=rif2010.inpatient_revenue_06, include_cohort=pop_11_indenom_2010_6);
%claims_rev(source=rif2010.inpatient_claims_07, rev_cohort=rif2010.inpatient_revenue_07, include_cohort=pop_11_indenom_2010_7);
%claims_rev(source=rif2010.inpatient_claims_08, rev_cohort=rif2010.inpatient_revenue_08, include_cohort=pop_11_indenom_2010_8);
%claims_rev(source=rif2010.inpatient_claims_09, rev_cohort=rif2010.inpatient_revenue_09, include_cohort=pop_11_indenom_2010_9);
%claims_rev(source=rif2010.inpatient_claims_10, rev_cohort=rif2010.inpatient_revenue_10, include_cohort=pop_11_indenom_2010_10);
%claims_rev(source=rif2010.inpatient_claims_11, rev_cohort=rif2010.inpatient_revenue_11, include_cohort=pop_11_indenom_2010_11);
%claims_rev(source=rif2010.inpatient_claims_12, rev_cohort=rif2010.inpatient_revenue_12, include_cohort=pop_11_indenom_2010_12);
%claims_rev(source=rif2011.inpatient_claims_01, rev_cohort=rif2011.inpatient_revenue_01, include_cohort=pop_11_indenom_2011_1);
%claims_rev(source=rif2011.inpatient_claims_02, rev_cohort=rif2011.inpatient_revenue_02, include_cohort=pop_11_indenom_2011_2);
%claims_rev(source=rif2011.inpatient_claims_03, rev_cohort=rif2011.inpatient_revenue_03, include_cohort=pop_11_indenom_2011_3);
%claims_rev(source=rif2011.inpatient_claims_04, rev_cohort=rif2011.inpatient_revenue_04, include_cohort=pop_11_indenom_2011_4);
%claims_rev(source=rif2011.inpatient_claims_05, rev_cohort=rif2011.inpatient_revenue_05, include_cohort=pop_11_indenom_2011_5);
%claims_rev(source=rif2011.inpatient_claims_06, rev_cohort=rif2011.inpatient_revenue_06, include_cohort=pop_11_indenom_2011_6);
%claims_rev(source=rif2011.inpatient_claims_07, rev_cohort=rif2011.inpatient_revenue_07, include_cohort=pop_11_indenom_2011_7);
%claims_rev(source=rif2011.inpatient_claims_08, rev_cohort=rif2011.inpatient_revenue_08, include_cohort=pop_11_indenom_2011_8);
%claims_rev(source=rif2011.inpatient_claims_09, rev_cohort=rif2011.inpatient_revenue_09, include_cohort=pop_11_indenom_2011_9);
%claims_rev(source=rif2011.inpatient_claims_10, rev_cohort=rif2011.inpatient_revenue_10, include_cohort=pop_11_indenom_2011_10);
%claims_rev(source=rif2011.inpatient_claims_11, rev_cohort=rif2011.inpatient_revenue_11, include_cohort=pop_11_indenom_2011_11);
%claims_rev(source=rif2011.inpatient_claims_12, rev_cohort=rif2011.inpatient_revenue_12, include_cohort=pop_11_indenom_2011_12);
%claims_rev(source=rif2012.inpatient_claims_01, rev_cohort=rif2012.inpatient_revenue_01, include_cohort=pop_11_indenom_2012_1);
%claims_rev(source=rif2012.inpatient_claims_02, rev_cohort=rif2012.inpatient_revenue_02, include_cohort=pop_11_indenom_2012_2);
%claims_rev(source=rif2012.inpatient_claims_03, rev_cohort=rif2012.inpatient_revenue_03, include_cohort=pop_11_indenom_2012_3);
%claims_rev(source=rif2012.inpatient_claims_04, rev_cohort=rif2012.inpatient_revenue_04, include_cohort=pop_11_indenom_2012_4);
%claims_rev(source=rif2012.inpatient_claims_05, rev_cohort=rif2012.inpatient_revenue_05, include_cohort=pop_11_indenom_2012_5);
%claims_rev(source=rif2012.inpatient_claims_06, rev_cohort=rif2012.inpatient_revenue_06, include_cohort=pop_11_indenom_2012_6);
%claims_rev(source=rif2012.inpatient_claims_07, rev_cohort=rif2012.inpatient_revenue_07, include_cohort=pop_11_indenom_2012_7);
%claims_rev(source=rif2012.inpatient_claims_08, rev_cohort=rif2012.inpatient_revenue_08, include_cohort=pop_11_indenom_2012_8);
%claims_rev(source=rif2012.inpatient_claims_09, rev_cohort=rif2012.inpatient_revenue_09, include_cohort=pop_11_indenom_2012_9);
%claims_rev(source=rif2012.inpatient_claims_10, rev_cohort=rif2012.inpatient_revenue_10, include_cohort=pop_11_indenom_2012_10);
%claims_rev(source=rif2012.inpatient_claims_11, rev_cohort=rif2012.inpatient_revenue_11, include_cohort=pop_11_indenom_2012_11);
%claims_rev(source=rif2012.inpatient_claims_12, rev_cohort=rif2012.inpatient_revenue_12, include_cohort=pop_11_indenom_2012_12);
%claims_rev(source=rif2013.inpatient_claims_01, rev_cohort=rif2013.inpatient_revenue_01, include_cohort=pop_11_indenom_2013_1);
%claims_rev(source=rif2013.inpatient_claims_02, rev_cohort=rif2013.inpatient_revenue_02, include_cohort=pop_11_indenom_2013_2);
%claims_rev(source=rif2013.inpatient_claims_03, rev_cohort=rif2013.inpatient_revenue_03, include_cohort=pop_11_indenom_2013_3);
%claims_rev(source=rif2013.inpatient_claims_04, rev_cohort=rif2013.inpatient_revenue_04, include_cohort=pop_11_indenom_2013_4);
%claims_rev(source=rif2013.inpatient_claims_05, rev_cohort=rif2013.inpatient_revenue_05, include_cohort=pop_11_indenom_2013_5);
%claims_rev(source=rif2013.inpatient_claims_06, rev_cohort=rif2013.inpatient_revenue_06, include_cohort=pop_11_indenom_2013_6);
%claims_rev(source=rif2013.inpatient_claims_07, rev_cohort=rif2013.inpatient_revenue_07, include_cohort=pop_11_indenom_2013_7);
%claims_rev(source=rif2013.inpatient_claims_08, rev_cohort=rif2013.inpatient_revenue_08, include_cohort=pop_11_indenom_2013_8);
%claims_rev(source=rif2013.inpatient_claims_09, rev_cohort=rif2013.inpatient_revenue_09, include_cohort=pop_11_indenom_2013_9);
%claims_rev(source=rif2013.inpatient_claims_10, rev_cohort=rif2013.inpatient_revenue_10, include_cohort=pop_11_indenom_2013_10);
%claims_rev(source=rif2013.inpatient_claims_11, rev_cohort=rif2013.inpatient_revenue_11, include_cohort=pop_11_indenom_2013_11);
%claims_rev(source=rif2013.inpatient_claims_12, rev_cohort=rif2013.inpatient_revenue_12, include_cohort=pop_11_indenom_2013_12);
%claims_rev(source=rif2014.inpatient_claims_01, rev_cohort=rif2014.inpatient_revenue_01, include_cohort=pop_11_indenom_2014_1);
%claims_rev(source=rif2014.inpatient_claims_02, rev_cohort=rif2014.inpatient_revenue_02, include_cohort=pop_11_indenom_2014_2);
%claims_rev(source=rif2014.inpatient_claims_03, rev_cohort=rif2014.inpatient_revenue_03, include_cohort=pop_11_indenom_2014_3);
%claims_rev(source=rif2014.inpatient_claims_04, rev_cohort=rif2014.inpatient_revenue_04, include_cohort=pop_11_indenom_2014_4);
%claims_rev(source=rif2014.inpatient_claims_05, rev_cohort=rif2014.inpatient_revenue_05, include_cohort=pop_11_indenom_2014_5);
%claims_rev(source=rif2014.inpatient_claims_06, rev_cohort=rif2014.inpatient_revenue_06, include_cohort=pop_11_indenom_2014_6);
%claims_rev(source=rif2014.inpatient_claims_07, rev_cohort=rif2014.inpatient_revenue_07, include_cohort=pop_11_indenom_2014_7);
%claims_rev(source=rif2014.inpatient_claims_08, rev_cohort=rif2014.inpatient_revenue_08, include_cohort=pop_11_indenom_2014_8);
%claims_rev(source=rif2014.inpatient_claims_09, rev_cohort=rif2014.inpatient_revenue_09, include_cohort=pop_11_indenom_2014_9);
%claims_rev(source=rif2014.inpatient_claims_10, rev_cohort=rif2014.inpatient_revenue_10, include_cohort=pop_11_indenom_2014_10);
%claims_rev(source=rif2014.inpatient_claims_11, rev_cohort=rif2014.inpatient_revenue_11, include_cohort=pop_11_indenom_2014_11);
%claims_rev(source=rif2014.inpatient_claims_12, rev_cohort=rif2014.inpatient_revenue_12, include_cohort=pop_11_indenom_2014_12);
%claims_rev(source=rif2015.inpatient_claims_01, rev_cohort=rif2015.inpatient_revenue_01, include_cohort=pop_11_indenom_2015_1);
%claims_rev(source=rif2015.inpatient_claims_02, rev_cohort=rif2015.inpatient_revenue_02, include_cohort=pop_11_indenom_2015_2);
%claims_rev(source=rif2015.inpatient_claims_03, rev_cohort=rif2015.inpatient_revenue_03, include_cohort=pop_11_indenom_2015_3);
%claims_rev(source=rif2015.inpatient_claims_04, rev_cohort=rif2015.inpatient_revenue_04, include_cohort=pop_11_indenom_2015_4);
%claims_rev(source=rif2015.inpatient_claims_05, rev_cohort=rif2015.inpatient_revenue_05, include_cohort=pop_11_indenom_2015_5);
%claims_rev(source=rif2015.inpatient_claims_06, rev_cohort=rif2015.inpatient_revenue_06, include_cohort=pop_11_indenom_2015_6);
%claims_rev(source=rif2015.inpatient_claims_07, rev_cohort=rif2015.inpatient_revenue_07, include_cohort=pop_11_indenom_2015_7);
%claims_rev(source=rif2015.inpatient_claims_08, rev_cohort=rif2015.inpatient_revenue_08, include_cohort=pop_11_indenom_2015_8);
%claims_rev(source=rif2015.inpatient_claims_09, rev_cohort=rif2015.inpatient_revenue_09, include_cohort=pop_11_indenom_2015_9);
%claims_rev(source=rif2015.inpatient_claims_10, rev_cohort=rif2015.inpatient_revenue_10, include_cohort=pop_11_indenom_2015_10);
%claims_rev(source=rif2015.inpatient_claims_11, rev_cohort=rif2015.inpatient_revenue_11, include_cohort=pop_11_indenom_2015_11);
%claims_rev(source=rif2015.inpatient_claims_12, rev_cohort=rif2015.inpatient_revenue_12, include_cohort=pop_11_indenom_2015_12);
%claims_rev(source=rif2016.inpatient_claims_01, rev_cohort=rif2016.inpatient_revenue_01, include_cohort=pop_11_indenom_2016_1);
%claims_rev(source=rif2016.inpatient_claims_02, rev_cohort=rif2016.inpatient_revenue_02, include_cohort=pop_11_indenom_2016_2);
%claims_rev(source=rif2016.inpatient_claims_03, rev_cohort=rif2016.inpatient_revenue_03, include_cohort=pop_11_indenom_2016_3);
%claims_rev(source=rif2016.inpatient_claims_04, rev_cohort=rif2016.inpatient_revenue_04, include_cohort=pop_11_indenom_2016_4);
%claims_rev(source=rif2016.inpatient_claims_05, rev_cohort=rif2016.inpatient_revenue_05, include_cohort=pop_11_indenom_2016_5);
%claims_rev(source=rif2016.inpatient_claims_06, rev_cohort=rif2016.inpatient_revenue_06, include_cohort=pop_11_indenom_2016_6);
%claims_rev(source=rif2016.inpatient_claims_07, rev_cohort=rif2016.inpatient_revenue_07, include_cohort=pop_11_indenom_2016_7);
%claims_rev(source=rif2016.inpatient_claims_08, rev_cohort=rif2016.inpatient_revenue_08, include_cohort=pop_11_indenom_2016_8);
%claims_rev(source=rif2016.inpatient_claims_09, rev_cohort=rif2016.inpatient_revenue_09, include_cohort=pop_11_indenom_2016_9);
%claims_rev(source=rif2016.inpatient_claims_10, rev_cohort=rif2016.inpatient_revenue_10, include_cohort=pop_11_indenom_2016_10);
%claims_rev(source=rif2016.inpatient_claims_11, rev_cohort=rif2016.inpatient_revenue_11, include_cohort=pop_11_indenom_2016_11);
%claims_rev(source=rif2016.inpatient_claims_12, rev_cohort=rif2016.inpatient_revenue_12, include_cohort=pop_11_indenom_2016_12);
%claims_rev(source=rif2017.inpatient_claims_01, rev_cohort=rif2017.inpatient_revenue_01, include_cohort=pop_11_indenom_2017_1);
%claims_rev(source=rif2017.inpatient_claims_02, rev_cohort=rif2017.inpatient_revenue_02, include_cohort=pop_11_indenom_2017_2);
%claims_rev(source=rif2017.inpatient_claims_03, rev_cohort=rif2017.inpatient_revenue_03, include_cohort=pop_11_indenom_2017_3);
%claims_rev(source=rif2017.inpatient_claims_04, rev_cohort=rif2017.inpatient_revenue_04, include_cohort=pop_11_indenom_2017_4);
%claims_rev(source=rif2017.inpatient_claims_05, rev_cohort=rif2017.inpatient_revenue_05, include_cohort=pop_11_indenom_2017_5);
%claims_rev(source=rif2017.inpatient_claims_06, rev_cohort=rif2017.inpatient_revenue_06, include_cohort=pop_11_indenom_2017_6);
%claims_rev(source=rif2017.inpatient_claims_07, rev_cohort=rif2017.inpatient_revenue_07, include_cohort=pop_11_indenom_2017_7);
%claims_rev(source=rif2017.inpatient_claims_08, rev_cohort=rif2017.inpatient_revenue_08, include_cohort=pop_11_indenom_2017_8);
%claims_rev(source=rif2017.inpatient_claims_09, rev_cohort=rif2017.inpatient_revenue_09, include_cohort=pop_11_indenom_2017_9);
%claims_rev(source=rif2017.inpatient_claims_10, rev_cohort=rif2017.inpatient_revenue_10, include_cohort=pop_11_indenom_2017_10);
%claims_rev(source=rif2017.inpatient_claims_11, rev_cohort=rif2017.inpatient_revenue_11, include_cohort=pop_11_indenom_2017_11);
%claims_rev(source=rif2017.inpatient_claims_12, rev_cohort=rif2017.inpatient_revenue_12, include_cohort=pop_11_indenom_2017_12);
%claims_rev(source=rifq2018.inpatient_claims_01, rev_cohort=rifq2018.inpatient_revenue_01, include_cohort=pop_11_indenom_2018_1);
%claims_rev(source=rifq2018.inpatient_claims_02, rev_cohort=rifq2018.inpatient_revenue_02, include_cohort=pop_11_indenom_2018_2);
%claims_rev(source=rifq2018.inpatient_claims_03, rev_cohort=rifq2018.inpatient_revenue_03, include_cohort=pop_11_indenom_2018_3);
%claims_rev(source=rifq2018.inpatient_claims_04, rev_cohort=rifq2018.inpatient_revenue_04, include_cohort=pop_11_indenom_2018_4);
%claims_rev(source=rifq2018.inpatient_claims_05, rev_cohort=rifq2018.inpatient_revenue_05, include_cohort=pop_11_indenom_2018_5);
%claims_rev(source=rifq2018.inpatient_claims_06, rev_cohort=rifq2018.inpatient_revenue_06, include_cohort=pop_11_indenom_2018_6);
%claims_rev(source=rifq2018.inpatient_claims_07, rev_cohort=rifq2018.inpatient_revenue_07, include_cohort=pop_11_indenom_2018_7);
%claims_rev(source=rifq2018.inpatient_claims_08, rev_cohort=rifq2018.inpatient_revenue_08, include_cohort=pop_11_indenom_2018_8);
%claims_rev(source=rifq2018.inpatient_claims_09, rev_cohort=rifq2018.inpatient_revenue_09, include_cohort=pop_11_indenom_2018_9);
%claims_rev(source=rifq2018.inpatient_claims_10, rev_cohort=rifq2018.inpatient_revenue_10, include_cohort=pop_11_indenom_2018_10);
%claims_rev(source=rifq2018.inpatient_claims_11, rev_cohort=rifq2018.inpatient_revenue_11, include_cohort=pop_11_indenom_2018_11);
%claims_rev(source=rifq2018.inpatient_claims_12, rev_cohort=rifq2018.inpatient_revenue_12, include_cohort=pop_11_indenom_2018_12);

%macro claims_rev(source=, rev_cohort=, include_cohort=);
proc sql;
create table include_cohort1 (compress=yes) as
select *
from 
&rev_cohort
where 
hcpcs_cd in (&pop11_hcpcs);
quit;
proc sql;
create table include_cohort2 (compress=yes) as
select *
from 
include_cohort1 a,
&source b
where 
(a.bene_id=b.bene_id and a.clm_id=b.clm_id);* or b.clm_drg_cd in(&pop11_drg);		*clm_drg not on outpatient/carrier;
quit;
Data &include_cohort (keep=pop:
		bene_id gndr_cd bene_race_cd bene_cnty_cd bene_state_cd bene_mlg_cntct_zip_cd  
		prvdr_num prvdr_state_cd at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi rfr_physn_npi prf_physn_npi); 
set include_cohort2;   
pop_11_elig_dt=clm_thru_dt;  			label pop_11_elig_dt='date eligible for pop 11';
pop_11_elig=1; 							label pop_11_elig='eligible for pop 11';
pop_11_age=(clm_thru_dt-dob_dt)/365.25; label pop_11_age='age eligible for pop 11';
pop_11_age=round(pop_11_age);
pop_11_year=year(clm_thru_dt);
pop_11_nch_clm_type_cd=nch_clm_type_cd; label pop_11_nch_clm_type_cd='claim/facility type for pop 11 eligibility'; 
pop_11_los=clm_thru_dt-clm_from_dt;	label pop_11_los='length of stay for pop 11 eligibility';
run; 
%mend;
%claims_rev(source=rif2010.outpatient_claims_01, rev_cohort=rif2010.outpatient_revenue_01, include_cohort=pop_11_outdenom_2010_1);
%claims_rev(source=rif2010.outpatient_claims_02, rev_cohort=rif2010.outpatient_revenue_02, include_cohort=pop_11_outdenom_2010_2);
%claims_rev(source=rif2010.outpatient_claims_03, rev_cohort=rif2010.outpatient_revenue_03, include_cohort=pop_11_outdenom_2010_3);
%claims_rev(source=rif2010.outpatient_claims_04, rev_cohort=rif2010.outpatient_revenue_04, include_cohort=pop_11_outdenom_2010_4);
%claims_rev(source=rif2010.outpatient_claims_05, rev_cohort=rif2010.outpatient_revenue_05, include_cohort=pop_11_outdenom_2010_5);
%claims_rev(source=rif2010.outpatient_claims_06, rev_cohort=rif2010.outpatient_revenue_06, include_cohort=pop_11_outdenom_2010_6);
%claims_rev(source=rif2010.outpatient_claims_07, rev_cohort=rif2010.outpatient_revenue_07, include_cohort=pop_11_outdenom_2010_7);
%claims_rev(source=rif2010.outpatient_claims_08, rev_cohort=rif2010.outpatient_revenue_08, include_cohort=pop_11_outdenom_2010_8);
%claims_rev(source=rif2010.outpatient_claims_09, rev_cohort=rif2010.outpatient_revenue_09, include_cohort=pop_11_outdenom_2010_9);
%claims_rev(source=rif2010.outpatient_claims_10, rev_cohort=rif2010.outpatient_revenue_10, include_cohort=pop_11_outdenom_2010_10);
%claims_rev(source=rif2010.outpatient_claims_11, rev_cohort=rif2010.outpatient_revenue_11, include_cohort=pop_11_outdenom_2010_11);
%claims_rev(source=rif2010.outpatient_claims_12, rev_cohort=rif2010.outpatient_revenue_12, include_cohort=pop_11_outdenom_2010_12);
%claims_rev(source=rif2010.bcarrier_claims_01, rev_cohort=rif2010.bcarrier_line_01, include_cohort=pop_11_cardenom_2010_1);
%claims_rev(source=rif2010.bcarrier_claims_02, rev_cohort=rif2010.bcarrier_line_02, include_cohort=pop_11_cardenom_2010_2);
%claims_rev(source=rif2010.bcarrier_claims_03, rev_cohort=rif2010.bcarrier_line_03, include_cohort=pop_11_cardenom_2010_3);
%claims_rev(source=rif2010.bcarrier_claims_04, rev_cohort=rif2010.bcarrier_line_04, include_cohort=pop_11_cardenom_2010_4);
%claims_rev(source=rif2010.bcarrier_claims_05, rev_cohort=rif2010.bcarrier_line_05, include_cohort=pop_11_cardenom_2010_5);
%claims_rev(source=rif2010.bcarrier_claims_06, rev_cohort=rif2010.bcarrier_line_06, include_cohort=pop_11_cardenom_2010_6);
%claims_rev(source=rif2010.bcarrier_claims_07, rev_cohort=rif2010.bcarrier_line_07, include_cohort=pop_11_cardenom_2010_7);
%claims_rev(source=rif2010.bcarrier_claims_08, rev_cohort=rif2010.bcarrier_line_08, include_cohort=pop_11_cardenom_2010_8);
%claims_rev(source=rif2010.bcarrier_claims_09, rev_cohort=rif2010.bcarrier_line_09, include_cohort=pop_11_cardenom_2010_9);
%claims_rev(source=rif2010.bcarrier_claims_10, rev_cohort=rif2010.bcarrier_line_10, include_cohort=pop_11_cardenom_2010_10);
%claims_rev(source=rif2010.bcarrier_claims_11, rev_cohort=rif2010.bcarrier_line_11, include_cohort=pop_11_cardenom_2010_11);
%claims_rev(source=rif2010.bcarrier_claims_12, rev_cohort=rif2010.bcarrier_line_12, include_cohort=pop_11_cardenom_2010_12);

%claims_rev(source=rif2011.outpatient_claims_01, rev_cohort=rif2011.outpatient_revenue_01, include_cohort=pop_11_outdenom_2011_1);
%claims_rev(source=rif2011.outpatient_claims_02, rev_cohort=rif2011.outpatient_revenue_02, include_cohort=pop_11_outdenom_2011_2);
%claims_rev(source=rif2011.outpatient_claims_03, rev_cohort=rif2011.outpatient_revenue_03, include_cohort=pop_11_outdenom_2011_3);
%claims_rev(source=rif2011.outpatient_claims_04, rev_cohort=rif2011.outpatient_revenue_04, include_cohort=pop_11_outdenom_2011_4);
%claims_rev(source=rif2011.outpatient_claims_05, rev_cohort=rif2011.outpatient_revenue_05, include_cohort=pop_11_outdenom_2011_5);
%claims_rev(source=rif2011.outpatient_claims_06, rev_cohort=rif2011.outpatient_revenue_06, include_cohort=pop_11_outdenom_2011_6);
%claims_rev(source=rif2011.outpatient_claims_07, rev_cohort=rif2011.outpatient_revenue_07, include_cohort=pop_11_outdenom_2011_7);
%claims_rev(source=rif2011.outpatient_claims_08, rev_cohort=rif2011.outpatient_revenue_08, include_cohort=pop_11_outdenom_2011_8);
%claims_rev(source=rif2011.outpatient_claims_09, rev_cohort=rif2011.outpatient_revenue_09, include_cohort=pop_11_outdenom_2011_9);
%claims_rev(source=rif2011.outpatient_claims_10, rev_cohort=rif2011.outpatient_revenue_10, include_cohort=pop_11_outdenom_2011_10);
%claims_rev(source=rif2011.outpatient_claims_11, rev_cohort=rif2011.outpatient_revenue_11, include_cohort=pop_11_outdenom_2011_11);
%claims_rev(source=rif2011.outpatient_claims_12, rev_cohort=rif2011.outpatient_revenue_12, include_cohort=pop_11_outdenom_2011_12);
%claims_rev(source=rif2011.bcarrier_claims_01, rev_cohort=rif2011.bcarrier_line_01, include_cohort=pop_11_cardenom_2011_1);
%claims_rev(source=rif2011.bcarrier_claims_02, rev_cohort=rif2011.bcarrier_line_02, include_cohort=pop_11_cardenom_2011_2);
%claims_rev(source=rif2011.bcarrier_claims_03, rev_cohort=rif2011.bcarrier_line_03, include_cohort=pop_11_cardenom_2011_3);
%claims_rev(source=rif2011.bcarrier_claims_04, rev_cohort=rif2011.bcarrier_line_04, include_cohort=pop_11_cardenom_2011_4);
%claims_rev(source=rif2011.bcarrier_claims_05, rev_cohort=rif2011.bcarrier_line_05, include_cohort=pop_11_cardenom_2011_5);
%claims_rev(source=rif2011.bcarrier_claims_06, rev_cohort=rif2011.bcarrier_line_06, include_cohort=pop_11_cardenom_2011_6);
%claims_rev(source=rif2011.bcarrier_claims_07, rev_cohort=rif2011.bcarrier_line_07, include_cohort=pop_11_cardenom_2011_7);
%claims_rev(source=rif2011.bcarrier_claims_08, rev_cohort=rif2011.bcarrier_line_08, include_cohort=pop_11_cardenom_2011_8);
%claims_rev(source=rif2011.bcarrier_claims_09, rev_cohort=rif2011.bcarrier_line_09, include_cohort=pop_11_cardenom_2011_9);
%claims_rev(source=rif2011.bcarrier_claims_10, rev_cohort=rif2011.bcarrier_line_10, include_cohort=pop_11_cardenom_2011_10);
%claims_rev(source=rif2011.bcarrier_claims_11, rev_cohort=rif2011.bcarrier_line_11, include_cohort=pop_11_cardenom_2011_11);
%claims_rev(source=rif2011.bcarrier_claims_12, rev_cohort=rif2011.bcarrier_line_12, include_cohort=pop_11_cardenom_2011_12);

%claims_rev(source=rif2012.outpatient_claims_01, rev_cohort=rif2012.outpatient_revenue_01, include_cohort=pop_11_outdenom_2012_1);
%claims_rev(source=rif2012.outpatient_claims_02, rev_cohort=rif2012.outpatient_revenue_02, include_cohort=pop_11_outdenom_2012_2);
%claims_rev(source=rif2012.outpatient_claims_03, rev_cohort=rif2012.outpatient_revenue_03, include_cohort=pop_11_outdenom_2012_3);
%claims_rev(source=rif2012.outpatient_claims_04, rev_cohort=rif2012.outpatient_revenue_04, include_cohort=pop_11_outdenom_2012_4);
%claims_rev(source=rif2012.outpatient_claims_05, rev_cohort=rif2012.outpatient_revenue_05, include_cohort=pop_11_outdenom_2012_5);
%claims_rev(source=rif2012.outpatient_claims_06, rev_cohort=rif2012.outpatient_revenue_06, include_cohort=pop_11_outdenom_2012_6);
%claims_rev(source=rif2012.outpatient_claims_07, rev_cohort=rif2012.outpatient_revenue_07, include_cohort=pop_11_outdenom_2012_7);
%claims_rev(source=rif2012.outpatient_claims_08, rev_cohort=rif2012.outpatient_revenue_08, include_cohort=pop_11_outdenom_2012_8);
%claims_rev(source=rif2012.outpatient_claims_09, rev_cohort=rif2012.outpatient_revenue_09, include_cohort=pop_11_outdenom_2012_9);
%claims_rev(source=rif2012.outpatient_claims_10, rev_cohort=rif2012.outpatient_revenue_10, include_cohort=pop_11_outdenom_2012_10);
%claims_rev(source=rif2012.outpatient_claims_11, rev_cohort=rif2012.outpatient_revenue_11, include_cohort=pop_11_outdenom_2012_11);
%claims_rev(source=rif2012.outpatient_claims_12, rev_cohort=rif2012.outpatient_revenue_12, include_cohort=pop_11_outdenom_2012_12);
%claims_rev(source=rif2012.bcarrier_claims_01, rev_cohort=rif2012.bcarrier_line_01, include_cohort=pop_11_cardenom_2012_1);
%claims_rev(source=rif2012.bcarrier_claims_02, rev_cohort=rif2012.bcarrier_line_02, include_cohort=pop_11_cardenom_2012_2);
%claims_rev(source=rif2012.bcarrier_claims_03, rev_cohort=rif2012.bcarrier_line_03, include_cohort=pop_11_cardenom_2012_3);
%claims_rev(source=rif2012.bcarrier_claims_04, rev_cohort=rif2012.bcarrier_line_04, include_cohort=pop_11_cardenom_2012_4);
%claims_rev(source=rif2012.bcarrier_claims_05, rev_cohort=rif2012.bcarrier_line_05, include_cohort=pop_11_cardenom_2012_5);
%claims_rev(source=rif2012.bcarrier_claims_06, rev_cohort=rif2012.bcarrier_line_06, include_cohort=pop_11_cardenom_2012_6);
%claims_rev(source=rif2012.bcarrier_claims_07, rev_cohort=rif2012.bcarrier_line_07, include_cohort=pop_11_cardenom_2012_7);
%claims_rev(source=rif2012.bcarrier_claims_08, rev_cohort=rif2012.bcarrier_line_08, include_cohort=pop_11_cardenom_2012_8);
%claims_rev(source=rif2012.bcarrier_claims_09, rev_cohort=rif2012.bcarrier_line_09, include_cohort=pop_11_cardenom_2012_9);
%claims_rev(source=rif2012.bcarrier_claims_10, rev_cohort=rif2012.bcarrier_line_10, include_cohort=pop_11_cardenom_2012_10);
%claims_rev(source=rif2012.bcarrier_claims_11, rev_cohort=rif2012.bcarrier_line_11, include_cohort=pop_11_cardenom_2012_11);
%claims_rev(source=rif2012.bcarrier_claims_12, rev_cohort=rif2012.bcarrier_line_12, include_cohort=pop_11_cardenom_2012_12);

%claims_rev(source=rif2013.outpatient_claims_01, rev_cohort=rif2013.outpatient_revenue_01, include_cohort=pop_11_outdenom_2013_1);
%claims_rev(source=rif2013.outpatient_claims_02, rev_cohort=rif2013.outpatient_revenue_02, include_cohort=pop_11_outdenom_2013_2);
%claims_rev(source=rif2013.outpatient_claims_03, rev_cohort=rif2013.outpatient_revenue_03, include_cohort=pop_11_outdenom_2013_3);
%claims_rev(source=rif2013.outpatient_claims_04, rev_cohort=rif2013.outpatient_revenue_04, include_cohort=pop_11_outdenom_2013_4);
%claims_rev(source=rif2013.outpatient_claims_05, rev_cohort=rif2013.outpatient_revenue_05, include_cohort=pop_11_outdenom_2013_5);
%claims_rev(source=rif2013.outpatient_claims_06, rev_cohort=rif2013.outpatient_revenue_06, include_cohort=pop_11_outdenom_2013_6);
%claims_rev(source=rif2013.outpatient_claims_07, rev_cohort=rif2013.outpatient_revenue_07, include_cohort=pop_11_outdenom_2013_7);
%claims_rev(source=rif2013.outpatient_claims_08, rev_cohort=rif2013.outpatient_revenue_08, include_cohort=pop_11_outdenom_2013_8);
%claims_rev(source=rif2013.outpatient_claims_09, rev_cohort=rif2013.outpatient_revenue_09, include_cohort=pop_11_outdenom_2013_9);
%claims_rev(source=rif2013.outpatient_claims_10, rev_cohort=rif2013.outpatient_revenue_10, include_cohort=pop_11_outdenom_2013_10);
%claims_rev(source=rif2013.outpatient_claims_11, rev_cohort=rif2013.outpatient_revenue_11, include_cohort=pop_11_outdenom_2013_11);
%claims_rev(source=rif2013.outpatient_claims_12, rev_cohort=rif2013.outpatient_revenue_12, include_cohort=pop_11_outdenom_2013_12);

%claims_rev(source=rif2013.bcarrier_claims_01, rev_cohort=rif2013.bcarrier_line_01, include_cohort=pop_11_cardenom_2013_1);
%claims_rev(source=rif2013.bcarrier_claims_02, rev_cohort=rif2013.bcarrier_line_02, include_cohort=pop_11_cardenom_2013_2);
%claims_rev(source=rif2013.bcarrier_claims_03, rev_cohort=rif2013.bcarrier_line_03, include_cohort=pop_11_cardenom_2013_3);
%claims_rev(source=rif2013.bcarrier_claims_04, rev_cohort=rif2013.bcarrier_line_04, include_cohort=pop_11_cardenom_2013_4);
%claims_rev(source=rif2013.bcarrier_claims_05, rev_cohort=rif2013.bcarrier_line_05, include_cohort=pop_11_cardenom_2013_5);
%claims_rev(source=rif2013.bcarrier_claims_06, rev_cohort=rif2013.bcarrier_line_06, include_cohort=pop_11_cardenom_2013_6);
%claims_rev(source=rif2013.bcarrier_claims_07, rev_cohort=rif2013.bcarrier_line_07, include_cohort=pop_11_cardenom_2013_7);
%claims_rev(source=rif2013.bcarrier_claims_08, rev_cohort=rif2013.bcarrier_line_08, include_cohort=pop_11_cardenom_2013_8);
%claims_rev(source=rif2013.bcarrier_claims_09, rev_cohort=rif2013.bcarrier_line_09, include_cohort=pop_11_cardenom_2013_9);
%claims_rev(source=rif2013.bcarrier_claims_10, rev_cohort=rif2013.bcarrier_line_10, include_cohort=pop_11_cardenom_2013_10);
%claims_rev(source=rif2013.bcarrier_claims_11, rev_cohort=rif2013.bcarrier_line_11, include_cohort=pop_11_cardenom_2013_11);
%claims_rev(source=rif2013.bcarrier_claims_12, rev_cohort=rif2013.bcarrier_line_12, include_cohort=pop_11_cardenom_2013_12);

%claims_rev(source=rif2014.outpatient_claims_01, rev_cohort=rif2014.outpatient_revenue_01, include_cohort=pop_11_outdenom_2014_1);
%claims_rev(source=rif2014.outpatient_claims_02, rev_cohort=rif2014.outpatient_revenue_02, include_cohort=pop_11_outdenom_2014_2);
%claims_rev(source=rif2014.outpatient_claims_03, rev_cohort=rif2014.outpatient_revenue_03, include_cohort=pop_11_outdenom_2014_3);
%claims_rev(source=rif2014.outpatient_claims_04, rev_cohort=rif2014.outpatient_revenue_04, include_cohort=pop_11_outdenom_2014_4);
%claims_rev(source=rif2014.outpatient_claims_05, rev_cohort=rif2014.outpatient_revenue_05, include_cohort=pop_11_outdenom_2014_5);
%claims_rev(source=rif2014.outpatient_claims_06, rev_cohort=rif2014.outpatient_revenue_06, include_cohort=pop_11_outdenom_2014_6);
%claims_rev(source=rif2014.outpatient_claims_07, rev_cohort=rif2014.outpatient_revenue_07, include_cohort=pop_11_outdenom_2014_7);
%claims_rev(source=rif2014.outpatient_claims_08, rev_cohort=rif2014.outpatient_revenue_08, include_cohort=pop_11_outdenom_2014_8);
%claims_rev(source=rif2014.outpatient_claims_09, rev_cohort=rif2014.outpatient_revenue_09, include_cohort=pop_11_outdenom_2014_9);
%claims_rev(source=rif2014.outpatient_claims_10, rev_cohort=rif2014.outpatient_revenue_10, include_cohort=pop_11_outdenom_2014_10);
%claims_rev(source=rif2014.outpatient_claims_11, rev_cohort=rif2014.outpatient_revenue_11, include_cohort=pop_11_outdenom_2014_11);
%claims_rev(source=rif2014.outpatient_claims_12, rev_cohort=rif2014.outpatient_revenue_12, include_cohort=pop_11_outdenom_2014_12);

%claims_rev(source=rif2014.bcarrier_claims_01, rev_cohort=rif2014.bcarrier_line_01, include_cohort=pop_11_cardenom_2014_1);
%claims_rev(source=rif2014.bcarrier_claims_02, rev_cohort=rif2014.bcarrier_line_02, include_cohort=pop_11_cardenom_2014_2);
%claims_rev(source=rif2014.bcarrier_claims_03, rev_cohort=rif2014.bcarrier_line_03, include_cohort=pop_11_cardenom_2014_3);
%claims_rev(source=rif2014.bcarrier_claims_04, rev_cohort=rif2014.bcarrier_line_04, include_cohort=pop_11_cardenom_2014_4);
%claims_rev(source=rif2014.bcarrier_claims_05, rev_cohort=rif2014.bcarrier_line_05, include_cohort=pop_11_cardenom_2014_5);
%claims_rev(source=rif2014.bcarrier_claims_06, rev_cohort=rif2014.bcarrier_line_06, include_cohort=pop_11_cardenom_2014_6);
%claims_rev(source=rif2014.bcarrier_claims_07, rev_cohort=rif2014.bcarrier_line_07, include_cohort=pop_11_cardenom_2014_7);
%claims_rev(source=rif2014.bcarrier_claims_08, rev_cohort=rif2014.bcarrier_line_08, include_cohort=pop_11_cardenom_2014_8);
%claims_rev(source=rif2014.bcarrier_claims_09, rev_cohort=rif2014.bcarrier_line_09, include_cohort=pop_11_cardenom_2014_9);
%claims_rev(source=rif2014.bcarrier_claims_10, rev_cohort=rif2014.bcarrier_line_10, include_cohort=pop_11_cardenom_2014_10);
%claims_rev(source=rif2014.bcarrier_claims_11, rev_cohort=rif2014.bcarrier_line_11, include_cohort=pop_11_cardenom_2014_11);
%claims_rev(source=rif2014.bcarrier_claims_12, rev_cohort=rif2014.bcarrier_line_12, include_cohort=pop_11_cardenom_2014_12);

%claims_rev(source=rif2015.outpatient_claims_01, rev_cohort=rif2015.outpatient_revenue_01, include_cohort=pop_11_outdenom_2015_1);
%claims_rev(source=rif2015.outpatient_claims_02, rev_cohort=rif2015.outpatient_revenue_02, include_cohort=pop_11_outdenom_2015_2);
%claims_rev(source=rif2015.outpatient_claims_03, rev_cohort=rif2015.outpatient_revenue_03, include_cohort=pop_11_outdenom_2015_3);
%claims_rev(source=rif2015.outpatient_claims_04, rev_cohort=rif2015.outpatient_revenue_04, include_cohort=pop_11_outdenom_2015_4);
%claims_rev(source=rif2015.outpatient_claims_05, rev_cohort=rif2015.outpatient_revenue_05, include_cohort=pop_11_outdenom_2015_5);
%claims_rev(source=rif2015.outpatient_claims_06, rev_cohort=rif2015.outpatient_revenue_06, include_cohort=pop_11_outdenom_2015_6);
%claims_rev(source=rif2015.outpatient_claims_07, rev_cohort=rif2015.outpatient_revenue_07, include_cohort=pop_11_outdenom_2015_7);
%claims_rev(source=rif2015.outpatient_claims_08, rev_cohort=rif2015.outpatient_revenue_08, include_cohort=pop_11_outdenom_2015_8);
%claims_rev(source=rif2015.outpatient_claims_09, rev_cohort=rif2015.outpatient_revenue_09, include_cohort=pop_11_outdenom_2015_9);
%claims_rev(source=rif2015.outpatient_claims_10, rev_cohort=rif2015.outpatient_revenue_10, include_cohort=pop_11_outdenom_2015_10);
%claims_rev(source=rif2015.outpatient_claims_11, rev_cohort=rif2015.outpatient_revenue_11, include_cohort=pop_11_outdenom_2015_11);
%claims_rev(source=rif2015.outpatient_claims_12, rev_cohort=rif2015.outpatient_revenue_12, include_cohort=pop_11_outdenom_2015_12);

%claims_rev(source=rif2015.bcarrier_claims_01, rev_cohort=rif2015.bcarrier_line_01, include_cohort=pop_11_cardenom_2015_1);
%claims_rev(source=rif2015.bcarrier_claims_02, rev_cohort=rif2015.bcarrier_line_02, include_cohort=pop_11_cardenom_2015_2);
%claims_rev(source=rif2015.bcarrier_claims_03, rev_cohort=rif2015.bcarrier_line_03, include_cohort=pop_11_cardenom_2015_3);
%claims_rev(source=rif2015.bcarrier_claims_04, rev_cohort=rif2015.bcarrier_line_04, include_cohort=pop_11_cardenom_2015_4);
%claims_rev(source=rif2015.bcarrier_claims_05, rev_cohort=rif2015.bcarrier_line_05, include_cohort=pop_11_cardenom_2015_5);
%claims_rev(source=rif2015.bcarrier_claims_06, rev_cohort=rif2015.bcarrier_line_06, include_cohort=pop_11_cardenom_2015_6);
%claims_rev(source=rif2015.bcarrier_claims_07, rev_cohort=rif2015.bcarrier_line_07, include_cohort=pop_11_cardenom_2015_7);
%claims_rev(source=rif2015.bcarrier_claims_08, rev_cohort=rif2015.bcarrier_line_08, include_cohort=pop_11_cardenom_2015_8);
%claims_rev(source=rif2015.bcarrier_claims_09, rev_cohort=rif2015.bcarrier_line_09, include_cohort=pop_11_cardenom_2015_9);
%claims_rev(source=rif2015.bcarrier_claims_10, rev_cohort=rif2015.bcarrier_line_10, include_cohort=pop_11_cardenom_2015_10);
%claims_rev(source=rif2015.bcarrier_claims_11, rev_cohort=rif2015.bcarrier_line_11, include_cohort=pop_11_cardenom_2015_11);
%claims_rev(source=rif2015.bcarrier_claims_12, rev_cohort=rif2015.bcarrier_line_12, include_cohort=pop_11_cardenom_2015_12);

%claims_rev(source=rif2016.outpatient_claims_01, rev_cohort=rif2016.outpatient_revenue_01, include_cohort=pop_11_outdenom_2016_1);
%claims_rev(source=rif2016.outpatient_claims_02, rev_cohort=rif2016.outpatient_revenue_02, include_cohort=pop_11_outdenom_2016_2);
%claims_rev(source=rif2016.outpatient_claims_03, rev_cohort=rif2016.outpatient_revenue_03, include_cohort=pop_11_outdenom_2016_3);
%claims_rev(source=rif2016.outpatient_claims_04, rev_cohort=rif2016.outpatient_revenue_04, include_cohort=pop_11_outdenom_2016_4);
%claims_rev(source=rif2016.outpatient_claims_05, rev_cohort=rif2016.outpatient_revenue_05, include_cohort=pop_11_outdenom_2016_5);
%claims_rev(source=rif2016.outpatient_claims_06, rev_cohort=rif2016.outpatient_revenue_06, include_cohort=pop_11_outdenom_2016_6);
%claims_rev(source=rif2016.outpatient_claims_07, rev_cohort=rif2016.outpatient_revenue_07, include_cohort=pop_11_outdenom_2016_7);
%claims_rev(source=rif2016.outpatient_claims_08, rev_cohort=rif2016.outpatient_revenue_08, include_cohort=pop_11_outdenom_2016_8);
%claims_rev(source=rif2016.outpatient_claims_09, rev_cohort=rif2016.outpatient_revenue_09, include_cohort=pop_11_outdenom_2016_9);
%claims_rev(source=rif2016.outpatient_claims_10, rev_cohort=rif2016.outpatient_revenue_10, include_cohort=pop_11_outdenom_2016_10);
%claims_rev(source=rif2016.outpatient_claims_11, rev_cohort=rif2016.outpatient_revenue_11, include_cohort=pop_11_outdenom_2016_11);
%claims_rev(source=rif2016.outpatient_claims_12, rev_cohort=rif2016.outpatient_revenue_12, include_cohort=pop_11_outdenom_2016_12);

%claims_rev(source=rif2016.bcarrier_claims_01, rev_cohort=rif2016.bcarrier_line_01, include_cohort=pop_11_cardenom_2016_1);
%claims_rev(source=rif2016.bcarrier_claims_02, rev_cohort=rif2016.bcarrier_line_02, include_cohort=pop_11_cardenom_2016_2);
%claims_rev(source=rif2016.bcarrier_claims_03, rev_cohort=rif2016.bcarrier_line_03, include_cohort=pop_11_cardenom_2016_3);
%claims_rev(source=rif2016.bcarrier_claims_04, rev_cohort=rif2016.bcarrier_line_04, include_cohort=pop_11_cardenom_2016_4);
%claims_rev(source=rif2016.bcarrier_claims_05, rev_cohort=rif2016.bcarrier_line_05, include_cohort=pop_11_cardenom_2016_5);
%claims_rev(source=rif2016.bcarrier_claims_06, rev_cohort=rif2016.bcarrier_line_06, include_cohort=pop_11_cardenom_2016_6);
%claims_rev(source=rif2016.bcarrier_claims_07, rev_cohort=rif2016.bcarrier_line_07, include_cohort=pop_11_cardenom_2016_7);
%claims_rev(source=rif2016.bcarrier_claims_08, rev_cohort=rif2016.bcarrier_line_08, include_cohort=pop_11_cardenom_2016_8);
%claims_rev(source=rif2016.bcarrier_claims_09, rev_cohort=rif2016.bcarrier_line_09, include_cohort=pop_11_cardenom_2016_9);
%claims_rev(source=rif2016.bcarrier_claims_10, rev_cohort=rif2016.bcarrier_line_10, include_cohort=pop_11_cardenom_2016_10);
%claims_rev(source=rif2016.bcarrier_claims_11, rev_cohort=rif2016.bcarrier_line_11, include_cohort=pop_11_cardenom_2016_11);
%claims_rev(source=rif2016.bcarrier_claims_12, rev_cohort=rif2016.bcarrier_line_12, include_cohort=pop_11_cardenom_2016_12);

%claims_rev(source=rif2017.outpatient_claims_01, rev_cohort=rif2017.outpatient_revenue_01, include_cohort=pop_11_outdenom_2017_1);
%claims_rev(source=rif2017.outpatient_claims_02, rev_cohort=rif2017.outpatient_revenue_02, include_cohort=pop_11_outdenom_2017_2);
%claims_rev(source=rif2017.outpatient_claims_03, rev_cohort=rif2017.outpatient_revenue_03, include_cohort=pop_11_outdenom_2017_3);
%claims_rev(source=rif2017.outpatient_claims_04, rev_cohort=rif2017.outpatient_revenue_04, include_cohort=pop_11_outdenom_2017_4);
%claims_rev(source=rif2017.outpatient_claims_05, rev_cohort=rif2017.outpatient_revenue_05, include_cohort=pop_11_outdenom_2017_5);
%claims_rev(source=rif2017.outpatient_claims_06, rev_cohort=rif2017.outpatient_revenue_06, include_cohort=pop_11_outdenom_2017_6);
%claims_rev(source=rif2017.outpatient_claims_07, rev_cohort=rif2017.outpatient_revenue_07, include_cohort=pop_11_outdenom_2017_7);
%claims_rev(source=rif2017.outpatient_claims_08, rev_cohort=rif2017.outpatient_revenue_08, include_cohort=pop_11_outdenom_2017_8);
%claims_rev(source=rif2017.outpatient_claims_09, rev_cohort=rif2017.outpatient_revenue_09, include_cohort=pop_11_outdenom_2017_9);
%claims_rev(source=rif2017.outpatient_claims_10, rev_cohort=rif2017.outpatient_revenue_10, include_cohort=pop_11_outdenom_2017_10);
%claims_rev(source=rif2017.outpatient_claims_11, rev_cohort=rif2017.outpatient_revenue_11, include_cohort=pop_11_outdenom_2017_11);
%claims_rev(source=rif2017.outpatient_claims_12, rev_cohort=rif2017.outpatient_revenue_12, include_cohort=pop_11_outdenom_2017_12);

%claims_rev(source=rif2017.bcarrier_claims_01, rev_cohort=rif2017.bcarrier_line_01, include_cohort=pop_11_cardenom_2017_1);
%claims_rev(source=rif2017.bcarrier_claims_02, rev_cohort=rif2017.bcarrier_line_02, include_cohort=pop_11_cardenom_2017_2);
%claims_rev(source=rif2017.bcarrier_claims_03, rev_cohort=rif2017.bcarrier_line_03, include_cohort=pop_11_cardenom_2017_3);
%claims_rev(source=rif2017.bcarrier_claims_04, rev_cohort=rif2017.bcarrier_line_04, include_cohort=pop_11_cardenom_2017_4);
%claims_rev(source=rif2017.bcarrier_claims_05, rev_cohort=rif2017.bcarrier_line_05, include_cohort=pop_11_cardenom_2017_5);
%claims_rev(source=rif2017.bcarrier_claims_06, rev_cohort=rif2017.bcarrier_line_06, include_cohort=pop_11_cardenom_2017_6);
%claims_rev(source=rif2017.bcarrier_claims_07, rev_cohort=rif2017.bcarrier_line_07, include_cohort=pop_11_cardenom_2017_7);
%claims_rev(source=rif2017.bcarrier_claims_08, rev_cohort=rif2017.bcarrier_line_08, include_cohort=pop_11_cardenom_2017_8);
%claims_rev(source=rif2017.bcarrier_claims_09, rev_cohort=rif2017.bcarrier_line_09, include_cohort=pop_11_cardenom_2017_9);
%claims_rev(source=rif2017.bcarrier_claims_10, rev_cohort=rif2017.bcarrier_line_10, include_cohort=pop_11_cardenom_2017_10);
%claims_rev(source=rif2017.bcarrier_claims_11, rev_cohort=rif2017.bcarrier_line_11, include_cohort=pop_11_cardenom_2017_11);
%claims_rev(source=rif2017.bcarrier_claims_12, rev_cohort=rif2017.bcarrier_line_12, include_cohort=pop_11_cardenom_2017_12);

%claims_rev(source=rifq2018.outpatient_claims_01, rev_cohort=rifq2018.outpatient_revenue_01, include_cohort=pop_11_outdenom_2018_1);
%claims_rev(source=rifq2018.outpatient_claims_02, rev_cohort=rifq2018.outpatient_revenue_02, include_cohort=pop_11_outdenom_2018_2);
%claims_rev(source=rifq2018.outpatient_claims_03, rev_cohort=rifq2018.outpatient_revenue_03, include_cohort=pop_11_outdenom_2018_3);
%claims_rev(source=rifq2018.outpatient_claims_04, rev_cohort=rifq2018.outpatient_revenue_04, include_cohort=pop_11_outdenom_2018_4);
%claims_rev(source=rifq2018.outpatient_claims_05, rev_cohort=rifq2018.outpatient_revenue_05, include_cohort=pop_11_outdenom_2018_5);
%claims_rev(source=rifq2018.outpatient_claims_06, rev_cohort=rifq2018.outpatient_revenue_06, include_cohort=pop_11_outdenom_2018_6);
%claims_rev(source=rifq2018.outpatient_claims_07, rev_cohort=rifq2018.outpatient_revenue_07, include_cohort=pop_11_outdenom_2018_7);
%claims_rev(source=rifq2018.outpatient_claims_08, rev_cohort=rifq2018.outpatient_revenue_08, include_cohort=pop_11_outdenom_2018_8);
%claims_rev(source=rifq2018.outpatient_claims_09, rev_cohort=rifq2018.outpatient_revenue_09, include_cohort=pop_11_outdenom_2018_9);
%claims_rev(source=rifq2018.outpatient_claims_10, rev_cohort=rifq2018.outpatient_revenue_10, include_cohort=pop_11_outdenom_2018_10);
%claims_rev(source=rifq2018.outpatient_claims_11, rev_cohort=rifq2018.outpatient_revenue_11, include_cohort=pop_11_outdenom_2018_11);
%claims_rev(source=rifq2018.outpatient_claims_12, rev_cohort=rifq2018.outpatient_revenue_12, include_cohort=pop_11_outdenom_2018_12);

%claims_rev(source=rifq2018.bcarrier_claims_01, rev_cohort=rifq2018.bcarrier_line_01, include_cohort=pop_11_cardenom_2018_1);
%claims_rev(source=rifq2018.bcarrier_claims_02, rev_cohort=rifq2018.bcarrier_line_02, include_cohort=pop_11_cardenom_2018_2);
%claims_rev(source=rifq2018.bcarrier_claims_03, rev_cohort=rifq2018.bcarrier_line_03, include_cohort=pop_11_cardenom_2018_3);
%claims_rev(source=rifq2018.bcarrier_claims_04, rev_cohort=rifq2018.bcarrier_line_04, include_cohort=pop_11_cardenom_2018_4);
%claims_rev(source=rifq2018.bcarrier_claims_05, rev_cohort=rifq2018.bcarrier_line_05, include_cohort=pop_11_cardenom_2018_5);
%claims_rev(source=rifq2018.bcarrier_claims_06, rev_cohort=rifq2018.bcarrier_line_06, include_cohort=pop_11_cardenom_2018_6);
%claims_rev(source=rifq2018.bcarrier_claims_07, rev_cohort=rifq2018.bcarrier_line_07, include_cohort=pop_11_cardenom_2018_7);
%claims_rev(source=rifq2018.bcarrier_claims_08, rev_cohort=rifq2018.bcarrier_line_08, include_cohort=pop_11_cardenom_2018_8);
%claims_rev(source=rifq2018.bcarrier_claims_09, rev_cohort=rifq2018.bcarrier_line_09, include_cohort=pop_11_cardenom_2018_9);
%claims_rev(source=rifq2018.bcarrier_claims_10, rev_cohort=rifq2018.bcarrier_line_10, include_cohort=pop_11_cardenom_2018_10);
%claims_rev(source=rifq2018.bcarrier_claims_11, rev_cohort=rifq2018.bcarrier_line_11, include_cohort=pop_11_cardenom_2018_11);
%claims_rev(source=rifq2018.bcarrier_claims_12, rev_cohort=rifq2018.bcarrier_line_12, include_cohort=pop_11_cardenom_2018_12);

data pop_11_denom;
set pop_11_INdenom_2010_1 pop_11_INdenom_2010_2 pop_11_INdenom_2010_3 pop_11_INdenom_2010_4 pop_11_INdenom_2010_5 pop_11_INdenom_2010_6 pop_11_INdenom_2010_7
pop_11_INdenom_2010_8 pop_11_INdenom_2010_9 pop_11_INdenom_2010_10 pop_11_INdenom_2010_11 pop_11_INdenom_2010_12
pop_11_outdenom_2010_1 pop_11_outdenom_2010_2 pop_11_outdenom_2010_3 pop_11_outdenom_2010_4 pop_11_outdenom_2010_5 pop_11_outdenom_2010_6 pop_11_outdenom_2010_7
pop_11_outdenom_2010_8 pop_11_outdenom_2010_9 pop_11_outdenom_2010_10 pop_11_outdenom_2010_11 pop_11_outdenom_2010_12
pop_11_cardenom_2010_1 pop_11_cardenom_2010_2 pop_11_cardenom_2010_3 pop_11_cardenom_2010_4 pop_11_cardenom_2010_5 pop_11_cardenom_2010_6 pop_11_cardenom_2010_7
pop_11_cardenom_2010_8 pop_11_cardenom_2010_9 pop_11_cardenom_2010_10 pop_11_cardenom_2010_11 pop_11_cardenom_2010_12

pop_11_INdenom_2011_1 pop_11_INdenom_2011_2 pop_11_INdenom_2011_3 pop_11_INdenom_2011_4 pop_11_INdenom_2011_5 pop_11_INdenom_2011_6 pop_11_INdenom_2011_7
pop_11_INdenom_2011_8 pop_11_INdenom_2011_9 pop_11_INdenom_2011_10 pop_11_INdenom_2011_11 pop_11_INdenom_2011_12
pop_11_outdenom_2011_1 pop_11_outdenom_2011_2 pop_11_outdenom_2011_3 pop_11_outdenom_2011_4 pop_11_outdenom_2011_5 pop_11_outdenom_2011_6 pop_11_outdenom_2011_7
pop_11_outdenom_2011_8 pop_11_outdenom_2011_9 pop_11_outdenom_2011_10 pop_11_outdenom_2011_11 pop_11_outdenom_2011_12
pop_11_cardenom_2011_1 pop_11_cardenom_2011_2 pop_11_cardenom_2011_3 pop_11_cardenom_2011_4 pop_11_cardenom_2011_5 pop_11_cardenom_2011_6 pop_11_cardenom_2011_7
pop_11_cardenom_2011_8 pop_11_cardenom_2011_9 pop_11_cardenom_2011_10 pop_11_cardenom_2011_11 pop_11_cardenom_2011_12

pop_11_INdenom_2012_1 pop_11_INdenom_2012_2 pop_11_INdenom_2012_3 pop_11_INdenom_2012_4 pop_11_INdenom_2012_5 pop_11_INdenom_2012_6 pop_11_INdenom_2012_7
pop_11_INdenom_2012_8 pop_11_INdenom_2012_9 pop_11_INdenom_2012_10 pop_11_INdenom_2012_11 pop_11_INdenom_2012_12
pop_11_outdenom_2012_1 pop_11_outdenom_2012_2 pop_11_outdenom_2012_3 pop_11_outdenom_2012_4 pop_11_outdenom_2012_5 pop_11_outdenom_2012_6 pop_11_outdenom_2012_7
pop_11_outdenom_2012_8 pop_11_outdenom_2012_9 pop_11_outdenom_2012_10 pop_11_outdenom_2012_11 pop_11_outdenom_2012_12
pop_11_cardenom_2012_1 pop_11_cardenom_2012_2 pop_11_cardenom_2012_3 pop_11_cardenom_2012_4 pop_11_cardenom_2012_5 pop_11_cardenom_2012_6 pop_11_cardenom_2012_7
pop_11_cardenom_2012_8 pop_11_cardenom_2012_9 pop_11_cardenom_2012_10 pop_11_cardenom_2012_11 pop_11_cardenom_2012_12

pop_11_INdenom_2013_1 pop_11_INdenom_2013_2 pop_11_INdenom_2013_3 pop_11_INdenom_2013_4 pop_11_INdenom_2013_5 pop_11_INdenom_2013_6 pop_11_INdenom_2013_7
pop_11_INdenom_2013_8 pop_11_INdenom_2013_9 pop_11_INdenom_2013_10 pop_11_INdenom_2013_11 pop_11_INdenom_2013_12
pop_11_outdenom_2013_1 pop_11_outdenom_2013_2 pop_11_outdenom_2013_3 pop_11_outdenom_2013_4 pop_11_outdenom_2013_5 pop_11_outdenom_2013_6 pop_11_outdenom_2013_7
pop_11_outdenom_2013_8 pop_11_outdenom_2013_9 pop_11_outdenom_2013_10 pop_11_outdenom_2013_11 pop_11_outdenom_2013_12
pop_11_cardenom_2013_1 pop_11_cardenom_2013_2 pop_11_cardenom_2013_3 pop_11_cardenom_2013_4 pop_11_cardenom_2013_5 pop_11_cardenom_2013_6 pop_11_cardenom_2013_7
pop_11_cardenom_2013_8 pop_11_cardenom_2013_9 pop_11_cardenom_2013_10 pop_11_cardenom_2013_11 pop_11_cardenom_2013_12

pop_11_INdenom_2014_1 pop_11_INdenom_2014_2 pop_11_INdenom_2014_3 pop_11_INdenom_2014_4 pop_11_INdenom_2014_5 pop_11_INdenom_2014_6 pop_11_INdenom_2014_7
pop_11_INdenom_2014_8 pop_11_INdenom_2014_9 pop_11_INdenom_2014_10 pop_11_INdenom_2014_11 pop_11_INdenom_2014_12
pop_11_outdenom_2014_1 pop_11_outdenom_2014_2 pop_11_outdenom_2014_3 pop_11_outdenom_2014_4 pop_11_outdenom_2014_5 pop_11_outdenom_2014_6 pop_11_outdenom_2014_7
pop_11_outdenom_2014_8 pop_11_outdenom_2014_9 pop_11_outdenom_2014_10 pop_11_outdenom_2014_11 pop_11_outdenom_2014_12
pop_11_cardenom_2014_1 pop_11_cardenom_2014_2 pop_11_cardenom_2014_3 pop_11_cardenom_2014_4 pop_11_cardenom_2014_5 pop_11_cardenom_2014_6 pop_11_cardenom_2014_7
pop_11_cardenom_2014_8 pop_11_cardenom_2014_9 pop_11_cardenom_2014_10 pop_11_cardenom_2014_11 pop_11_cardenom_2014_12

pop_11_INdenom_2015_1 pop_11_INdenom_2015_2 pop_11_INdenom_2015_3 pop_11_INdenom_2015_4 pop_11_INdenom_2015_5 pop_11_INdenom_2015_6 pop_11_INdenom_2015_7
pop_11_INdenom_2015_8 pop_11_INdenom_2015_9 pop_11_INdenom_2015_10 pop_11_INdenom_2015_11 pop_11_INdenom_2015_12
pop_11_outdenom_2015_1 pop_11_outdenom_2015_2 pop_11_outdenom_2015_3 pop_11_outdenom_2015_4 pop_11_outdenom_2015_5 pop_11_outdenom_2015_6 pop_11_outdenom_2015_7
pop_11_outdenom_2015_8 pop_11_outdenom_2015_9 pop_11_outdenom_2015_10 pop_11_outdenom_2015_11 pop_11_outdenom_2015_12
pop_11_cardenom_2015_1 pop_11_cardenom_2015_2 pop_11_cardenom_2015_3 pop_11_cardenom_2015_4 pop_11_cardenom_2015_5 pop_11_cardenom_2015_6 pop_11_cardenom_2015_7
pop_11_cardenom_2015_8 pop_11_cardenom_2015_9 pop_11_cardenom_2015_10 pop_11_cardenom_2015_11 pop_11_cardenom_2015_12

pop_11_INdenom_2016_1 pop_11_INdenom_2016_2 pop_11_INdenom_2016_3 pop_11_INdenom_2016_4 pop_11_INdenom_2016_5 pop_11_INdenom_2016_6 pop_11_INdenom_2016_7
pop_11_INdenom_2016_8 pop_11_INdenom_2016_9 pop_11_INdenom_2016_10 pop_11_INdenom_2016_11 pop_11_INdenom_2016_12
pop_11_outdenom_2016_1 pop_11_outdenom_2016_2 pop_11_outdenom_2016_3 pop_11_outdenom_2016_4 pop_11_outdenom_2016_5 pop_11_outdenom_2016_6 pop_11_outdenom_2016_7
pop_11_outdenom_2016_8 pop_11_outdenom_2016_9 pop_11_outdenom_2016_10 pop_11_outdenom_2016_11 pop_11_outdenom_2016_12
pop_11_cardenom_2016_1 pop_11_cardenom_2016_2 pop_11_cardenom_2016_3 pop_11_cardenom_2016_4 pop_11_cardenom_2016_5 pop_11_cardenom_2016_6 pop_11_cardenom_2016_7
pop_11_cardenom_2016_8 pop_11_cardenom_2016_9 pop_11_cardenom_2016_10 pop_11_cardenom_2016_11 pop_11_cardenom_2016_12

pop_11_INdenom_2017_1 pop_11_INdenom_2017_2 pop_11_INdenom_2017_3 pop_11_INdenom_2017_4 pop_11_INdenom_2017_5 pop_11_INdenom_2017_6 pop_11_INdenom_2017_7
pop_11_INdenom_2017_8 pop_11_INdenom_2017_9 pop_11_INdenom_2017_10 pop_11_INdenom_2017_11 pop_11_INdenom_2017_12
pop_11_outdenom_2017_1 pop_11_outdenom_2017_2 pop_11_outdenom_2017_3 pop_11_outdenom_2017_4 pop_11_outdenom_2017_5 pop_11_outdenom_2017_6 pop_11_outdenom_2017_7
pop_11_outdenom_2017_8 pop_11_outdenom_2017_9 pop_11_outdenom_2017_10 pop_11_outdenom_2017_11 pop_11_outdenom_2017_12
pop_11_cardenom_2017_1 pop_11_cardenom_2017_2 pop_11_cardenom_2017_3 pop_11_cardenom_2017_4 pop_11_cardenom_2017_5 pop_11_cardenom_2017_6 pop_11_cardenom_2017_7
pop_11_cardenom_2017_8 pop_11_cardenom_2017_9 pop_11_cardenom_2017_10 pop_11_cardenom_2017_11 pop_11_cardenom_2017_12

pop_11_INdenom_2018_1 pop_11_INdenom_2018_2 pop_11_INdenom_2018_3 pop_11_INdenom_2018_4 pop_11_INdenom_2018_5 pop_11_INdenom_2018_6 pop_11_INdenom_2018_7
pop_11_INdenom_2018_8 pop_11_INdenom_2018_9 pop_11_INdenom_2018_10 pop_11_INdenom_2018_11 pop_11_INdenom_2018_12
pop_11_outdenom_2018_1 pop_11_outdenom_2018_2 pop_11_outdenom_2018_3 pop_11_outdenom_2018_4 pop_11_outdenom_2018_5 pop_11_outdenom_2018_6 pop_11_outdenom_2018_7
pop_11_outdenom_2018_8 pop_11_outdenom_2018_9 pop_11_outdenom_2018_10 pop_11_outdenom_2018_11 pop_11_outdenom_2018_12
pop_11_cardenom_2018_1 pop_11_cardenom_2018_2 pop_11_cardenom_2018_3 pop_11_cardenom_2018_4 pop_11_cardenom_2018_5 pop_11_cardenom_2018_6 pop_11_cardenom_2018_7
pop_11_cardenom_2018_8 pop_11_cardenom_2018_9 pop_11_cardenom_2018_10 pop_11_cardenom_2018_11 pop_11_cardenom_2018_12
;
*only keep inpatient and outpatient claims;
if pop_11_nch_clm_type_cd notin(40,50,61) then delete;
run;*232,450;
proc sort data=pop_11_denom NODUPKEY;by bene_id pop_11_elig_dt;run;*230,116;
proc freq data=pop_11_denom; table pop_11_nch_clm_type_cd; run;*need to use ICD procedure codes to identify inpatient, all are outpatient;

*bring in chronic conditions---associated with denominator first then match to the num-denom file;
%macro line(abcd=, include_cohort=);
proc sql;
create table &include_cohort (compress=yes) as
select  
a.bene_id, b.*
from 
pop_11_denom a,
&abcd b
where a.bene_id=b.bene_id ;
quit;
%mend;
%line(abcd=mbsf.mbsf_cc_2010, include_cohort=cc_2010); 
%line(abcd=mbsf.mbsf_cc_2011, include_cohort=cc_2011); 
%line(abcd=mbsf.mbsf_cc_2012, include_cohort=cc_2012); 
%line(abcd=mbsf.mbsf_cc_2013, include_cohort=cc_2013); 
%line(abcd=mbsf.mbsf_cc_2014, include_cohort=cc_2014); 
%line(abcd=mbsf.mbsf_cc_2015, include_cohort=cc_2015); 
%line(abcd=mbsf.mbsf_cc_2016, include_cohort=cc_2016); 
%line(abcd=mbsf.mbsf_cc_2017, include_cohort=cc_2017); 
%line(abcd=mbsf.mbsf_cc_2018, include_cohort=cc_2018); 

data cc (keep=bene_id ami ami_ever alzh_ever alzh_demen_ever atrial_fib_ever
cataract_ever chronickidney_ever copd_ever chf_ever diabetes_ever glaucoma_ever  hip_fracture_ever 
ischemicheart_ever depression_ever osteoporosis_ever ra_oa_ever stroke_tia_ever cancer_breast_ever
cancer_colorectal_ever cancer_prostate_ever cancer_lung_ever cancer_endometrial cancer_endometrial_ever anemia_ever asthma_ever
hyperl_ever hyperp_ever hypert_ever hypoth_ever );
merge 
cc_2010 cc_2011 cc_2012 cc_2013 cc_2014 cc_2015 cc_2016 cc_2017;* cc_2018;
by bene_id;
run; 
proc sort data=cc nodupkey; by bene_id; run;*228,233;
proc print data=cc (obs=20); run; *this has chronic condition outcomes EVER (not tied to the proc date);
proc freq data=cc; table CANCER_ENDOMETRIAL; run;

*numerator for inpatient, outpatient, carrier;
*identify those who had malignancy before hysterectomy or up to 30 days after (cancer at time of  hysterectomy)--will be EXCLUDED from the numerator;
%macro inp_claims(source=, include_cohort=);
proc sql;
create table &include_cohort (compress=yes) as
select a.pop_11_elig_dt, b.*
from 
pop_11_denom a,
&source b
where 
a.bene_id=b.bene_id
AND
b.clm_thru_dt<=(a.pop_11_elig_dt+30);*keep all encounters before or 30 days after eligiblity date to allow for cancer dx after hyst;
quit;
data &include_cohort; set &include_cohort;
*DX code qualifying;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
do j=1 to 25;
	if substr(dx(j),1,3) in(&pop11_icd_EX_dx9_3) then do; malig11=1; end;
	if substr(dx(j),1,3) in(&pop11_icd_EX_dx9_4) then do; malig11=1; end;
	if dx(j) in(&pop11_icd_EX_dx9) then do; malig11=1; end;
	if substr(dx(j),1,3) in(&pop11_icd_EX_dx10_3) then do; malig11=1; end;
	if substr(dx(j),1,3) in(&pop11_icd_EX_dx10_4) then do; malig11=1; end;
	if dx(j) in(&pop11_icd_EX_dx10) then do; malig11=1; end;
end;
if malig11=1 then popped_11=0; 
pop_11_malig_dt=clm_thru_dt;	label pop_11_malig_dt='date of female gential organ malignancy';
if popped_11 ne 0 then delete;
run;
proc sort data=&include_cohort NODUPKEY; by bene_id pop_11_malig_dt; run;*sorted by person and date of malignancy;
Data &include_cohort (keep=bene_id pop_11_elig_dt pop_11_malig_dt popped_11); set &include_cohort; run; 
%mend;
%inp_claims(source=rif2010.inpatient_claims_01, include_cohort=pop_11_INexclude_2010_1);
%inp_claims(source=rif2010.inpatient_claims_02, include_cohort=pop_11_INexclude_2010_2);
%inp_claims(source=rif2010.inpatient_claims_03, include_cohort=pop_11_INexclude_2010_3);
%inp_claims(source=rif2010.inpatient_claims_04, include_cohort=pop_11_INexclude_2010_4);
%inp_claims(source=rif2010.inpatient_claims_05, include_cohort=pop_11_INexclude_2010_5);
%inp_claims(source=rif2010.inpatient_claims_06, include_cohort=pop_11_INexclude_2010_6);
%inp_claims(source=rif2010.inpatient_claims_07, include_cohort=pop_11_INexclude_2010_7);
%inp_claims(source=rif2010.inpatient_claims_08, include_cohort=pop_11_INexclude_2010_8);
%inp_claims(source=rif2010.inpatient_claims_09, include_cohort=pop_11_INexclude_2010_9);
%inp_claims(source=rif2010.inpatient_claims_10, include_cohort=pop_11_INexclude_2010_10);
%inp_claims(source=rif2010.inpatient_claims_11, include_cohort=pop_11_INexclude_2010_11);
%inp_claims(source=rif2010.inpatient_claims_12, include_cohort=pop_11_INexclude_2010_12);
%inp_claims(source=rif2010.outpatient_claims_01, include_cohort=pop_11_OUTexclude_2010_1);
%inp_claims(source=rif2010.outpatient_claims_02, include_cohort=pop_11_OUTexclude_2010_2);
%inp_claims(source=rif2010.outpatient_claims_03, include_cohort=pop_11_OUTexclude_2010_3);
%inp_claims(source=rif2010.outpatient_claims_04, include_cohort=pop_11_OUTexclude_2010_4);
%inp_claims(source=rif2010.outpatient_claims_05, include_cohort=pop_11_OUTexclude_2010_5);
%inp_claims(source=rif2010.outpatient_claims_06, include_cohort=pop_11_OUTexclude_2010_6);
%inp_claims(source=rif2010.outpatient_claims_07, include_cohort=pop_11_OUTexclude_2010_7);
%inp_claims(source=rif2010.outpatient_claims_08, include_cohort=pop_11_OUTexclude_2010_8);
%inp_claims(source=rif2010.outpatient_claims_09, include_cohort=pop_11_OUTexclude_2010_9);
%inp_claims(source=rif2010.outpatient_claims_10, include_cohort=pop_11_OUTexclude_2010_10);
%inp_claims(source=rif2010.outpatient_claims_11, include_cohort=pop_11_OUTexclude_2010_11);
%inp_claims(source=rif2010.outpatient_claims_12, include_cohort=pop_11_OUTexclude_2010_12);
%inp_claims(source=rif2010.bcarrier_claims_01, include_cohort=pop_11_CARexclude_2010_1);
%inp_claims(source=rif2010.bcarrier_claims_02, include_cohort=pop_11_CARexclude_2010_2);
%inp_claims(source=rif2010.bcarrier_claims_03, include_cohort=pop_11_CARexclude_2010_3);
%inp_claims(source=rif2010.bcarrier_claims_04, include_cohort=pop_11_CARexclude_2010_4);
%inp_claims(source=rif2010.bcarrier_claims_05, include_cohort=pop_11_CARexclude_2010_5);
%inp_claims(source=rif2010.bcarrier_claims_06, include_cohort=pop_11_CARexclude_2010_6);
%inp_claims(source=rif2010.bcarrier_claims_07, include_cohort=pop_11_CARexclude_2010_7);
%inp_claims(source=rif2010.bcarrier_claims_08, include_cohort=pop_11_CARexclude_2010_8);
%inp_claims(source=rif2010.bcarrier_claims_09, include_cohort=pop_11_CARexclude_2010_9);
%inp_claims(source=rif2010.bcarrier_claims_10, include_cohort=pop_11_CARexclude_2010_10);
%inp_claims(source=rif2010.bcarrier_claims_11, include_cohort=pop_11_CARexclude_2010_11);
%inp_claims(source=rif2010.bcarrier_claims_12, include_cohort=pop_11_CARexclude_2010_12);

%inp_claims(source=rif2011.inpatient_claims_01, include_cohort=pop_11_INexclude_2011_1);
%inp_claims(source=rif2011.inpatient_claims_02, include_cohort=pop_11_INexclude_2011_2);
%inp_claims(source=rif2011.inpatient_claims_03, include_cohort=pop_11_INexclude_2011_3);
%inp_claims(source=rif2011.inpatient_claims_04, include_cohort=pop_11_INexclude_2011_4);
%inp_claims(source=rif2011.inpatient_claims_05, include_cohort=pop_11_INexclude_2011_5);
%inp_claims(source=rif2011.inpatient_claims_06, include_cohort=pop_11_INexclude_2011_6);
%inp_claims(source=rif2011.inpatient_claims_07, include_cohort=pop_11_INexclude_2011_7);
%inp_claims(source=rif2011.inpatient_claims_08, include_cohort=pop_11_INexclude_2011_8);
%inp_claims(source=rif2011.inpatient_claims_09, include_cohort=pop_11_INexclude_2011_9);
%inp_claims(source=rif2011.inpatient_claims_10, include_cohort=pop_11_INexclude_2011_10);
%inp_claims(source=rif2011.inpatient_claims_11, include_cohort=pop_11_INexclude_2011_11);
%inp_claims(source=rif2011.inpatient_claims_12, include_cohort=pop_11_INexclude_2011_12);
%inp_claims(source=rif2011.outpatient_claims_01, include_cohort=pop_11_OUTexclude_2011_1);
%inp_claims(source=rif2011.outpatient_claims_02, include_cohort=pop_11_OUTexclude_2011_2);
%inp_claims(source=rif2011.outpatient_claims_03, include_cohort=pop_11_OUTexclude_2011_3);
%inp_claims(source=rif2011.outpatient_claims_04, include_cohort=pop_11_OUTexclude_2011_4);
%inp_claims(source=rif2011.outpatient_claims_05, include_cohort=pop_11_OUTexclude_2011_5);
%inp_claims(source=rif2011.outpatient_claims_06, include_cohort=pop_11_OUTexclude_2011_6);
%inp_claims(source=rif2011.outpatient_claims_07, include_cohort=pop_11_OUTexclude_2011_7);
%inp_claims(source=rif2011.outpatient_claims_08, include_cohort=pop_11_OUTexclude_2011_8);
%inp_claims(source=rif2011.outpatient_claims_09, include_cohort=pop_11_OUTexclude_2011_9);
%inp_claims(source=rif2011.outpatient_claims_10, include_cohort=pop_11_OUTexclude_2011_10);
%inp_claims(source=rif2011.outpatient_claims_11, include_cohort=pop_11_OUTexclude_2011_11);
%inp_claims(source=rif2011.outpatient_claims_12, include_cohort=pop_11_OUTexclude_2011_12);
%inp_claims(source=rif2011.bcarrier_claims_01, include_cohort=pop_11_CARexclude_2011_1);
%inp_claims(source=rif2011.bcarrier_claims_02, include_cohort=pop_11_CARexclude_2011_2);
%inp_claims(source=rif2011.bcarrier_claims_03, include_cohort=pop_11_CARexclude_2011_3);
%inp_claims(source=rif2011.bcarrier_claims_04, include_cohort=pop_11_CARexclude_2011_4);
%inp_claims(source=rif2011.bcarrier_claims_05, include_cohort=pop_11_CARexclude_2011_5);
%inp_claims(source=rif2011.bcarrier_claims_06, include_cohort=pop_11_CARexclude_2011_6);
%inp_claims(source=rif2011.bcarrier_claims_07, include_cohort=pop_11_CARexclude_2011_7);
%inp_claims(source=rif2011.bcarrier_claims_08, include_cohort=pop_11_CARexclude_2011_8);
%inp_claims(source=rif2011.bcarrier_claims_09, include_cohort=pop_11_CARexclude_2011_9);
%inp_claims(source=rif2011.bcarrier_claims_10, include_cohort=pop_11_CARexclude_2011_10);
%inp_claims(source=rif2011.bcarrier_claims_11, include_cohort=pop_11_CARexclude_2011_11);
%inp_claims(source=rif2011.bcarrier_claims_12, include_cohort=pop_11_CARexclude_2011_12);

%inp_claims(source=rif2012.inpatient_claims_01, include_cohort=pop_11_INexclude_2012_1);
%inp_claims(source=rif2012.inpatient_claims_02, include_cohort=pop_11_INexclude_2012_2);
%inp_claims(source=rif2012.inpatient_claims_03, include_cohort=pop_11_INexclude_2012_3);
%inp_claims(source=rif2012.inpatient_claims_04, include_cohort=pop_11_INexclude_2012_4);
%inp_claims(source=rif2012.inpatient_claims_05, include_cohort=pop_11_INexclude_2012_5);
%inp_claims(source=rif2012.inpatient_claims_06, include_cohort=pop_11_INexclude_2012_6);
%inp_claims(source=rif2012.inpatient_claims_07, include_cohort=pop_11_INexclude_2012_7);
%inp_claims(source=rif2012.inpatient_claims_08, include_cohort=pop_11_INexclude_2012_8);
%inp_claims(source=rif2012.inpatient_claims_09, include_cohort=pop_11_INexclude_2012_9);
%inp_claims(source=rif2012.inpatient_claims_10, include_cohort=pop_11_INexclude_2012_10);
%inp_claims(source=rif2012.inpatient_claims_11, include_cohort=pop_11_INexclude_2012_11);
%inp_claims(source=rif2012.inpatient_claims_12, include_cohort=pop_11_INexclude_2012_12);
%inp_claims(source=rif2012.outpatient_claims_01, include_cohort=pop_11_OUTexclude_2012_1);
%inp_claims(source=rif2012.outpatient_claims_02, include_cohort=pop_11_OUTexclude_2012_2);
%inp_claims(source=rif2012.outpatient_claims_03, include_cohort=pop_11_OUTexclude_2012_3);
%inp_claims(source=rif2012.outpatient_claims_04, include_cohort=pop_11_OUTexclude_2012_4);
%inp_claims(source=rif2012.outpatient_claims_05, include_cohort=pop_11_OUTexclude_2012_5);
%inp_claims(source=rif2012.outpatient_claims_06, include_cohort=pop_11_OUTexclude_2012_6);
%inp_claims(source=rif2012.outpatient_claims_07, include_cohort=pop_11_OUTexclude_2012_7);
%inp_claims(source=rif2012.outpatient_claims_08, include_cohort=pop_11_OUTexclude_2012_8);
%inp_claims(source=rif2012.outpatient_claims_09, include_cohort=pop_11_OUTexclude_2012_9);
%inp_claims(source=rif2012.outpatient_claims_10, include_cohort=pop_11_OUTexclude_2012_10);
%inp_claims(source=rif2012.outpatient_claims_11, include_cohort=pop_11_OUTexclude_2012_11);
%inp_claims(source=rif2012.outpatient_claims_12, include_cohort=pop_11_OUTexclude_2012_12);
%inp_claims(source=rif2012.bcarrier_claims_01, include_cohort=pop_11_CARexclude_2012_1);
%inp_claims(source=rif2012.bcarrier_claims_02, include_cohort=pop_11_CARexclude_2012_2);
%inp_claims(source=rif2012.bcarrier_claims_03, include_cohort=pop_11_CARexclude_2012_3);
%inp_claims(source=rif2012.bcarrier_claims_04, include_cohort=pop_11_CARexclude_2012_4);
%inp_claims(source=rif2012.bcarrier_claims_05, include_cohort=pop_11_CARexclude_2012_5);
%inp_claims(source=rif2012.bcarrier_claims_06, include_cohort=pop_11_CARexclude_2012_6);
%inp_claims(source=rif2012.bcarrier_claims_07, include_cohort=pop_11_CARexclude_2012_7);
%inp_claims(source=rif2012.bcarrier_claims_08, include_cohort=pop_11_CARexclude_2012_8);
%inp_claims(source=rif2012.bcarrier_claims_09, include_cohort=pop_11_CARexclude_2012_9);
%inp_claims(source=rif2012.bcarrier_claims_10, include_cohort=pop_11_CARexclude_2012_10);
%inp_claims(source=rif2012.bcarrier_claims_11, include_cohort=pop_11_CARexclude_2012_11);
%inp_claims(source=rif2012.bcarrier_claims_12, include_cohort=pop_11_CARexclude_2012_12);

%inp_claims(source=rif2013.inpatient_claims_01, include_cohort=pop_11_INexclude_2013_1);
%inp_claims(source=rif2013.inpatient_claims_02, include_cohort=pop_11_INexclude_2013_2);
%inp_claims(source=rif2013.inpatient_claims_03, include_cohort=pop_11_INexclude_2013_3);
%inp_claims(source=rif2013.inpatient_claims_04, include_cohort=pop_11_INexclude_2013_4);
%inp_claims(source=rif2013.inpatient_claims_05, include_cohort=pop_11_INexclude_2013_5);
%inp_claims(source=rif2013.inpatient_claims_06, include_cohort=pop_11_INexclude_2013_6);
%inp_claims(source=rif2013.inpatient_claims_07, include_cohort=pop_11_INexclude_2013_7);
%inp_claims(source=rif2013.inpatient_claims_08, include_cohort=pop_11_INexclude_2013_8);
%inp_claims(source=rif2013.inpatient_claims_09, include_cohort=pop_11_INexclude_2013_9);
%inp_claims(source=rif2013.inpatient_claims_10, include_cohort=pop_11_INexclude_2013_10);
%inp_claims(source=rif2013.inpatient_claims_11, include_cohort=pop_11_INexclude_2013_11);
%inp_claims(source=rif2013.inpatient_claims_12, include_cohort=pop_11_INexclude_2013_12);
%inp_claims(source=rif2013.outpatient_claims_01, include_cohort=pop_11_OUTexclude_2013_1);
%inp_claims(source=rif2013.outpatient_claims_02, include_cohort=pop_11_OUTexclude_2013_2);
%inp_claims(source=rif2013.outpatient_claims_03, include_cohort=pop_11_OUTexclude_2013_3);
%inp_claims(source=rif2013.outpatient_claims_04, include_cohort=pop_11_OUTexclude_2013_4);
%inp_claims(source=rif2013.outpatient_claims_05, include_cohort=pop_11_OUTexclude_2013_5);
%inp_claims(source=rif2013.outpatient_claims_06, include_cohort=pop_11_OUTexclude_2013_6);
%inp_claims(source=rif2013.outpatient_claims_07, include_cohort=pop_11_OUTexclude_2013_7);
%inp_claims(source=rif2013.outpatient_claims_08, include_cohort=pop_11_OUTexclude_2013_8);
%inp_claims(source=rif2013.outpatient_claims_09, include_cohort=pop_11_OUTexclude_2013_9);
%inp_claims(source=rif2013.outpatient_claims_10, include_cohort=pop_11_OUTexclude_2013_10);
%inp_claims(source=rif2013.outpatient_claims_11, include_cohort=pop_11_OUTexclude_2013_11);
%inp_claims(source=rif2013.outpatient_claims_12, include_cohort=pop_11_OUTexclude_2013_12);
%inp_claims(source=rif2013.bcarrier_claims_01, include_cohort=pop_11_CARexclude_2013_1);
%inp_claims(source=rif2013.bcarrier_claims_02, include_cohort=pop_11_CARexclude_2013_2);
%inp_claims(source=rif2013.bcarrier_claims_03, include_cohort=pop_11_CARexclude_2013_3);
%inp_claims(source=rif2013.bcarrier_claims_04, include_cohort=pop_11_CARexclude_2013_4);
%inp_claims(source=rif2013.bcarrier_claims_05, include_cohort=pop_11_CARexclude_2013_5);
%inp_claims(source=rif2013.bcarrier_claims_06, include_cohort=pop_11_CARexclude_2013_6);
%inp_claims(source=rif2013.bcarrier_claims_07, include_cohort=pop_11_CARexclude_2013_7);
%inp_claims(source=rif2013.bcarrier_claims_08, include_cohort=pop_11_CARexclude_2013_8);
%inp_claims(source=rif2013.bcarrier_claims_09, include_cohort=pop_11_CARexclude_2013_9);
%inp_claims(source=rif2013.bcarrier_claims_10, include_cohort=pop_11_CARexclude_2013_10);
%inp_claims(source=rif2013.bcarrier_claims_11, include_cohort=pop_11_CARexclude_2013_11);
%inp_claims(source=rif2013.bcarrier_claims_12, include_cohort=pop_11_CARexclude_2013_12);

%inp_claims(source=rif2014.inpatient_claims_01, include_cohort=pop_11_INexclude_2014_1);
%inp_claims(source=rif2014.inpatient_claims_02, include_cohort=pop_11_INexclude_2014_2);
%inp_claims(source=rif2014.inpatient_claims_03, include_cohort=pop_11_INexclude_2014_3);
%inp_claims(source=rif2014.inpatient_claims_04, include_cohort=pop_11_INexclude_2014_4);
%inp_claims(source=rif2014.inpatient_claims_05, include_cohort=pop_11_INexclude_2014_5);
%inp_claims(source=rif2014.inpatient_claims_06, include_cohort=pop_11_INexclude_2014_6);
%inp_claims(source=rif2014.inpatient_claims_07, include_cohort=pop_11_INexclude_2014_7);
%inp_claims(source=rif2014.inpatient_claims_08, include_cohort=pop_11_INexclude_2014_8);
%inp_claims(source=rif2014.inpatient_claims_09, include_cohort=pop_11_INexclude_2014_9);
%inp_claims(source=rif2014.inpatient_claims_10, include_cohort=pop_11_INexclude_2014_10);
%inp_claims(source=rif2014.inpatient_claims_11, include_cohort=pop_11_INexclude_2014_11);
%inp_claims(source=rif2014.inpatient_claims_12, include_cohort=pop_11_INexclude_2014_12);
%inp_claims(source=rif2014.outpatient_claims_01, include_cohort=pop_11_OUTexclude_2014_1);
%inp_claims(source=rif2014.outpatient_claims_02, include_cohort=pop_11_OUTexclude_2014_2);
%inp_claims(source=rif2014.outpatient_claims_03, include_cohort=pop_11_OUTexclude_2014_3);
%inp_claims(source=rif2014.outpatient_claims_04, include_cohort=pop_11_OUTexclude_2014_4);
%inp_claims(source=rif2014.outpatient_claims_05, include_cohort=pop_11_OUTexclude_2014_5);
%inp_claims(source=rif2014.outpatient_claims_06, include_cohort=pop_11_OUTexclude_2014_6);
%inp_claims(source=rif2014.outpatient_claims_07, include_cohort=pop_11_OUTexclude_2014_7);
%inp_claims(source=rif2014.outpatient_claims_08, include_cohort=pop_11_OUTexclude_2014_8);
%inp_claims(source=rif2014.outpatient_claims_09, include_cohort=pop_11_OUTexclude_2014_9);
%inp_claims(source=rif2014.outpatient_claims_10, include_cohort=pop_11_OUTexclude_2014_10);
%inp_claims(source=rif2014.outpatient_claims_11, include_cohort=pop_11_OUTexclude_2014_11);
%inp_claims(source=rif2014.outpatient_claims_12, include_cohort=pop_11_OUTexclude_2014_12);
%inp_claims(source=rif2014.bcarrier_claims_01, include_cohort=pop_11_CARexclude_2014_1);
%inp_claims(source=rif2014.bcarrier_claims_02, include_cohort=pop_11_CARexclude_2014_2);
%inp_claims(source=rif2014.bcarrier_claims_03, include_cohort=pop_11_CARexclude_2014_3);
%inp_claims(source=rif2014.bcarrier_claims_04, include_cohort=pop_11_CARexclude_2014_4);
%inp_claims(source=rif2014.bcarrier_claims_05, include_cohort=pop_11_CARexclude_2014_5);
%inp_claims(source=rif2014.bcarrier_claims_06, include_cohort=pop_11_CARexclude_2014_6);
%inp_claims(source=rif2014.bcarrier_claims_07, include_cohort=pop_11_CARexclude_2014_7);
%inp_claims(source=rif2014.bcarrier_claims_08, include_cohort=pop_11_CARexclude_2014_8);
%inp_claims(source=rif2014.bcarrier_claims_09, include_cohort=pop_11_CARexclude_2014_9);
%inp_claims(source=rif2014.bcarrier_claims_10, include_cohort=pop_11_CARexclude_2014_10);
%inp_claims(source=rif2014.bcarrier_claims_11, include_cohort=pop_11_CARexclude_2014_11);
%inp_claims(source=rif2014.bcarrier_claims_12, include_cohort=pop_11_CARexclude_2014_12);

%inp_claims(source=rif2015.inpatient_claims_01, include_cohort=pop_11_INexclude_2015_1);
%inp_claims(source=rif2015.inpatient_claims_02, include_cohort=pop_11_INexclude_2015_2);
%inp_claims(source=rif2015.inpatient_claims_03, include_cohort=pop_11_INexclude_2015_3);
%inp_claims(source=rif2015.inpatient_claims_04, include_cohort=pop_11_INexclude_2015_4);
%inp_claims(source=rif2015.inpatient_claims_05, include_cohort=pop_11_INexclude_2015_5);
%inp_claims(source=rif2015.inpatient_claims_06, include_cohort=pop_11_INexclude_2015_6);
%inp_claims(source=rif2015.inpatient_claims_07, include_cohort=pop_11_INexclude_2015_7);
%inp_claims(source=rif2015.inpatient_claims_08, include_cohort=pop_11_INexclude_2015_8);
%inp_claims(source=rif2015.inpatient_claims_09, include_cohort=pop_11_INexclude_2015_9);
%inp_claims(source=rif2015.inpatient_claims_10, include_cohort=pop_11_INexclude_2015_10);
%inp_claims(source=rif2015.inpatient_claims_11, include_cohort=pop_11_INexclude_2015_11);
%inp_claims(source=rif2015.inpatient_claims_12, include_cohort=pop_11_INexclude_2015_12);
%inp_claims(source=rif2015.outpatient_claims_01, include_cohort=pop_11_OUTexclude_2015_1);
%inp_claims(source=rif2015.outpatient_claims_02, include_cohort=pop_11_OUTexclude_2015_2);
%inp_claims(source=rif2015.outpatient_claims_03, include_cohort=pop_11_OUTexclude_2015_3);
%inp_claims(source=rif2015.outpatient_claims_04, include_cohort=pop_11_OUTexclude_2015_4);
%inp_claims(source=rif2015.outpatient_claims_05, include_cohort=pop_11_OUTexclude_2015_5);
%inp_claims(source=rif2015.outpatient_claims_06, include_cohort=pop_11_OUTexclude_2015_6);
%inp_claims(source=rif2015.outpatient_claims_07, include_cohort=pop_11_OUTexclude_2015_7);
%inp_claims(source=rif2015.outpatient_claims_08, include_cohort=pop_11_OUTexclude_2015_8);
%inp_claims(source=rif2015.outpatient_claims_09, include_cohort=pop_11_OUTexclude_2015_9);
%inp_claims(source=rif2015.outpatient_claims_10, include_cohort=pop_11_OUTexclude_2015_10);
%inp_claims(source=rif2015.outpatient_claims_11, include_cohort=pop_11_OUTexclude_2015_11);
%inp_claims(source=rif2015.outpatient_claims_12, include_cohort=pop_11_OUTexclude_2015_12);
%inp_claims(source=rif2015.bcarrier_claims_01, include_cohort=pop_11_CARexclude_2015_1);
%inp_claims(source=rif2015.bcarrier_claims_02, include_cohort=pop_11_CARexclude_2015_2);
%inp_claims(source=rif2015.bcarrier_claims_03, include_cohort=pop_11_CARexclude_2015_3);
%inp_claims(source=rif2015.bcarrier_claims_04, include_cohort=pop_11_CARexclude_2015_4);
%inp_claims(source=rif2015.bcarrier_claims_05, include_cohort=pop_11_CARexclude_2015_5);
%inp_claims(source=rif2015.bcarrier_claims_06, include_cohort=pop_11_CARexclude_2015_6);
%inp_claims(source=rif2015.bcarrier_claims_07, include_cohort=pop_11_CARexclude_2015_7);
%inp_claims(source=rif2015.bcarrier_claims_08, include_cohort=pop_11_CARexclude_2015_8);
%inp_claims(source=rif2015.bcarrier_claims_09, include_cohort=pop_11_CARexclude_2015_9);
%inp_claims(source=rif2015.bcarrier_claims_10, include_cohort=pop_11_CARexclude_2015_10);
%inp_claims(source=rif2015.bcarrier_claims_11, include_cohort=pop_11_CARexclude_2015_11);
%inp_claims(source=rif2015.bcarrier_claims_12, include_cohort=pop_11_CARexclude_2015_12);

%inp_claims(source=rif2016.inpatient_claims_01, include_cohort=pop_11_INexclude_2016_1);
%inp_claims(source=rif2016.inpatient_claims_02, include_cohort=pop_11_INexclude_2016_2);
%inp_claims(source=rif2016.inpatient_claims_03, include_cohort=pop_11_INexclude_2016_3);
%inp_claims(source=rif2016.inpatient_claims_04, include_cohort=pop_11_INexclude_2016_4);
%inp_claims(source=rif2016.inpatient_claims_05, include_cohort=pop_11_INexclude_2016_5);
%inp_claims(source=rif2016.inpatient_claims_06, include_cohort=pop_11_INexclude_2016_6);
%inp_claims(source=rif2016.inpatient_claims_07, include_cohort=pop_11_INexclude_2016_7);
%inp_claims(source=rif2016.inpatient_claims_08, include_cohort=pop_11_INexclude_2016_8);
%inp_claims(source=rif2016.inpatient_claims_09, include_cohort=pop_11_INexclude_2016_9);
%inp_claims(source=rif2016.inpatient_claims_10, include_cohort=pop_11_INexclude_2016_10);
%inp_claims(source=rif2016.inpatient_claims_11, include_cohort=pop_11_INexclude_2016_11);
%inp_claims(source=rif2016.inpatient_claims_12, include_cohort=pop_11_INexclude_2016_12);
%inp_claims(source=rif2016.outpatient_claims_01, include_cohort=pop_11_OUTexclude_2016_1);
%inp_claims(source=rif2016.outpatient_claims_02, include_cohort=pop_11_OUTexclude_2016_2);
%inp_claims(source=rif2016.outpatient_claims_03, include_cohort=pop_11_OUTexclude_2016_3);
%inp_claims(source=rif2016.outpatient_claims_04, include_cohort=pop_11_OUTexclude_2016_4);
%inp_claims(source=rif2016.outpatient_claims_05, include_cohort=pop_11_OUTexclude_2016_5);
%inp_claims(source=rif2016.outpatient_claims_06, include_cohort=pop_11_OUTexclude_2016_6);
%inp_claims(source=rif2016.outpatient_claims_07, include_cohort=pop_11_OUTexclude_2016_7);
%inp_claims(source=rif2016.outpatient_claims_08, include_cohort=pop_11_OUTexclude_2016_8);
%inp_claims(source=rif2016.outpatient_claims_09, include_cohort=pop_11_OUTexclude_2016_9);
%inp_claims(source=rif2016.outpatient_claims_10, include_cohort=pop_11_OUTexclude_2016_10);
%inp_claims(source=rif2016.outpatient_claims_11, include_cohort=pop_11_OUTexclude_2016_11);
%inp_claims(source=rif2016.outpatient_claims_12, include_cohort=pop_11_OUTexclude_2016_12);
%inp_claims(source=rif2016.bcarrier_claims_01, include_cohort=pop_11_CARexclude_2016_1);
%inp_claims(source=rif2016.bcarrier_claims_02, include_cohort=pop_11_CARexclude_2016_2);
%inp_claims(source=rif2016.bcarrier_claims_03, include_cohort=pop_11_CARexclude_2016_3);
%inp_claims(source=rif2016.bcarrier_claims_04, include_cohort=pop_11_CARexclude_2016_4);
%inp_claims(source=rif2016.bcarrier_claims_05, include_cohort=pop_11_CARexclude_2016_5);
%inp_claims(source=rif2016.bcarrier_claims_06, include_cohort=pop_11_CARexclude_2016_6);
%inp_claims(source=rif2016.bcarrier_claims_07, include_cohort=pop_11_CARexclude_2016_7);
%inp_claims(source=rif2016.bcarrier_claims_08, include_cohort=pop_11_CARexclude_2016_8);
%inp_claims(source=rif2016.bcarrier_claims_09, include_cohort=pop_11_CARexclude_2016_9);
%inp_claims(source=rif2016.bcarrier_claims_10, include_cohort=pop_11_CARexclude_2016_10);
%inp_claims(source=rif2016.bcarrier_claims_11, include_cohort=pop_11_CARexclude_2016_11);
%inp_claims(source=rif2016.bcarrier_claims_12, include_cohort=pop_11_CARexclude_2016_12);

%inp_claims(source=rif2017.inpatient_claims_01, include_cohort=pop_11_INexclude_2017_1);
%inp_claims(source=rif2017.inpatient_claims_02, include_cohort=pop_11_INexclude_2017_2);
%inp_claims(source=rif2017.inpatient_claims_03, include_cohort=pop_11_INexclude_2017_3);
%inp_claims(source=rif2017.inpatient_claims_04, include_cohort=pop_11_INexclude_2017_4);
%inp_claims(source=rif2017.inpatient_claims_05, include_cohort=pop_11_INexclude_2017_5);
%inp_claims(source=rif2017.inpatient_claims_06, include_cohort=pop_11_INexclude_2017_6);
%inp_claims(source=rif2017.inpatient_claims_07, include_cohort=pop_11_INexclude_2017_7);
%inp_claims(source=rif2017.inpatient_claims_08, include_cohort=pop_11_INexclude_2017_8);
%inp_claims(source=rif2017.inpatient_claims_09, include_cohort=pop_11_INexclude_2017_9);
%inp_claims(source=rif2017.inpatient_claims_10, include_cohort=pop_11_INexclude_2017_10);
%inp_claims(source=rif2017.inpatient_claims_11, include_cohort=pop_11_INexclude_2017_11);
%inp_claims(source=rif2017.inpatient_claims_12, include_cohort=pop_11_INexclude_2017_12);
%inp_claims(source=rif2017.outpatient_claims_01, include_cohort=pop_11_OUTexclude_2017_1);
%inp_claims(source=rif2017.outpatient_claims_02, include_cohort=pop_11_OUTexclude_2017_2);
%inp_claims(source=rif2017.outpatient_claims_03, include_cohort=pop_11_OUTexclude_2017_3);
%inp_claims(source=rif2017.outpatient_claims_04, include_cohort=pop_11_OUTexclude_2017_4);
%inp_claims(source=rif2017.outpatient_claims_05, include_cohort=pop_11_OUTexclude_2017_5);
%inp_claims(source=rif2017.outpatient_claims_06, include_cohort=pop_11_OUTexclude_2017_6);
%inp_claims(source=rif2017.outpatient_claims_07, include_cohort=pop_11_OUTexclude_2017_7);
%inp_claims(source=rif2017.outpatient_claims_08, include_cohort=pop_11_OUTexclude_2017_8);
%inp_claims(source=rif2017.outpatient_claims_09, include_cohort=pop_11_OUTexclude_2017_9);
%inp_claims(source=rif2017.outpatient_claims_10, include_cohort=pop_11_OUTexclude_2017_10);
%inp_claims(source=rif2017.outpatient_claims_11, include_cohort=pop_11_OUTexclude_2017_11);
%inp_claims(source=rif2017.outpatient_claims_12, include_cohort=pop_11_OUTexclude_2017_12);
%inp_claims(source=rif2017.bcarrier_claims_01, include_cohort=pop_11_CARexclude_2017_1);
%inp_claims(source=rif2017.bcarrier_claims_02, include_cohort=pop_11_CARexclude_2017_2);
%inp_claims(source=rif2017.bcarrier_claims_03, include_cohort=pop_11_CARexclude_2017_3);
%inp_claims(source=rif2017.bcarrier_claims_04, include_cohort=pop_11_CARexclude_2017_4);
%inp_claims(source=rif2017.bcarrier_claims_05, include_cohort=pop_11_CARexclude_2017_5);
%inp_claims(source=rif2017.bcarrier_claims_06, include_cohort=pop_11_CARexclude_2017_6);
%inp_claims(source=rif2017.bcarrier_claims_07, include_cohort=pop_11_CARexclude_2017_7);
%inp_claims(source=rif2017.bcarrier_claims_08, include_cohort=pop_11_CARexclude_2017_8);
%inp_claims(source=rif2017.bcarrier_claims_09, include_cohort=pop_11_CARexclude_2017_9);
%inp_claims(source=rif2017.bcarrier_claims_10, include_cohort=pop_11_CARexclude_2017_10);
%inp_claims(source=rif2017.bcarrier_claims_11, include_cohort=pop_11_CARexclude_2017_11);
%inp_claims(source=rif2017.bcarrier_claims_12, include_cohort=pop_11_CARexclude_2017_12);

%inp_claims(source=rifq2018.inpatient_claims_01, include_cohort=pop_11_INexclude_2018_1);
%inp_claims(source=rifq2018.inpatient_claims_02, include_cohort=pop_11_INexclude_2018_2);
%inp_claims(source=rifq2018.inpatient_claims_03, include_cohort=pop_11_INexclude_2018_3);
%inp_claims(source=rifq2018.inpatient_claims_04, include_cohort=pop_11_INexclude_2018_4);
%inp_claims(source=rifq2018.inpatient_claims_05, include_cohort=pop_11_INexclude_2018_5);
%inp_claims(source=rifq2018.inpatient_claims_06, include_cohort=pop_11_INexclude_2018_6);
%inp_claims(source=rifq2018.inpatient_claims_07, include_cohort=pop_11_INexclude_2018_7);
%inp_claims(source=rifq2018.inpatient_claims_08, include_cohort=pop_11_INexclude_2018_8);
%inp_claims(source=rifq2018.inpatient_claims_09, include_cohort=pop_11_INexclude_2018_9);
%inp_claims(source=rifq2018.inpatient_claims_10, include_cohort=pop_11_INexclude_2018_10);
%inp_claims(source=rifq2018.inpatient_claims_11, include_cohort=pop_11_INexclude_2018_11);
%inp_claims(source=rifq2018.inpatient_claims_12, include_cohort=pop_11_INexclude_2018_12);
%inp_claims(source=rifq2018.outpatient_claims_01, include_cohort=pop_11_OUTexclude_2018_1);
%inp_claims(source=rifq2018.outpatient_claims_02, include_cohort=pop_11_OUTexclude_2018_2);
%inp_claims(source=rifq2018.outpatient_claims_03, include_cohort=pop_11_OUTexclude_2018_3);
%inp_claims(source=rifq2018.outpatient_claims_04, include_cohort=pop_11_OUTexclude_2018_4);
%inp_claims(source=rifq2018.outpatient_claims_05, include_cohort=pop_11_OUTexclude_2018_5);
%inp_claims(source=rifq2018.outpatient_claims_06, include_cohort=pop_11_OUTexclude_2018_6);
%inp_claims(source=rifq2018.outpatient_claims_07, include_cohort=pop_11_OUTexclude_2018_7);
%inp_claims(source=rifq2018.outpatient_claims_08, include_cohort=pop_11_OUTexclude_2018_8);
%inp_claims(source=rifq2018.outpatient_claims_09, include_cohort=pop_11_OUTexclude_2018_9);
%inp_claims(source=rifq2018.outpatient_claims_10, include_cohort=pop_11_OUTexclude_2018_10);
%inp_claims(source=rifq2018.outpatient_claims_11, include_cohort=pop_11_OUTexclude_2018_11);
%inp_claims(source=rifq2018.outpatient_claims_12, include_cohort=pop_11_OUTexclude_2018_12);
%inp_claims(source=rifq2018.bcarrier_claims_01, include_cohort=pop_11_CARexclude_2018_1);
%inp_claims(source=rifq2018.bcarrier_claims_02, include_cohort=pop_11_CARexclude_2018_2);
%inp_claims(source=rifq2018.bcarrier_claims_03, include_cohort=pop_11_CARexclude_2018_3);
%inp_claims(source=rifq2018.bcarrier_claims_04, include_cohort=pop_11_CARexclude_2018_4);
%inp_claims(source=rifq2018.bcarrier_claims_05, include_cohort=pop_11_CARexclude_2018_5);
%inp_claims(source=rifq2018.bcarrier_claims_06, include_cohort=pop_11_CARexclude_2018_6);
%inp_claims(source=rifq2018.bcarrier_claims_07, include_cohort=pop_11_CARexclude_2018_7);
%inp_claims(source=rifq2018.bcarrier_claims_08, include_cohort=pop_11_CARexclude_2018_8);
%inp_claims(source=rifq2018.bcarrier_claims_09, include_cohort=pop_11_CARexclude_2018_9);
%inp_claims(source=rifq2018.bcarrier_claims_10, include_cohort=pop_11_CARexclude_2018_10);
%inp_claims(source=rifq2018.bcarrier_claims_11, include_cohort=pop_11_CARexclude_2018_11);
%inp_claims(source=rifq2018.bcarrier_claims_12, include_cohort=pop_11_CARexclude_2018_12);
*did not go to line item files for line icd exclusion;

data pop_11_exclude;
set pop_11_INexclude_2010_1 pop_11_INexclude_2010_2 pop_11_INexclude_2010_3 pop_11_INexclude_2010_4 pop_11_INexclude_2010_5 pop_11_INexclude_2010_6 pop_11_INexclude_2010_7
pop_11_INexclude_2010_8 pop_11_INexclude_2010_9 pop_11_INexclude_2010_10 pop_11_INexclude_2010_11 pop_11_INexclude_2010_12
pop_11_outexclude_2010_1 pop_11_outexclude_2010_2 pop_11_outexclude_2010_3 pop_11_outexclude_2010_4 pop_11_outexclude_2010_5 pop_11_outexclude_2010_6 pop_11_outexclude_2010_7
pop_11_outexclude_2010_8 pop_11_outexclude_2010_9 pop_11_outexclude_2010_10 pop_11_outexclude_2010_11 pop_11_outexclude_2010_12
pop_11_carexclude_2010_1 pop_11_carexclude_2010_2 pop_11_carexclude_2010_3 pop_11_carexclude_2010_4 pop_11_carexclude_2010_5 pop_11_carexclude_2010_6 pop_11_carexclude_2010_7
pop_11_carexclude_2010_8 pop_11_carexclude_2010_9 pop_11_carexclude_2010_10 pop_11_carexclude_2010_11 pop_11_carexclude_2010_12

pop_11_INexclude_2011_1 pop_11_INexclude_2011_2 pop_11_INexclude_2011_3 pop_11_INexclude_2011_4 pop_11_INexclude_2011_5 pop_11_INexclude_2011_6 pop_11_INexclude_2011_7
pop_11_INexclude_2011_8 pop_11_INexclude_2011_9 pop_11_INexclude_2011_10 pop_11_INexclude_2011_11 pop_11_INexclude_2011_12
pop_11_outexclude_2011_1 pop_11_outexclude_2011_2 pop_11_outexclude_2011_3 pop_11_outexclude_2011_4 pop_11_outexclude_2011_5 pop_11_outexclude_2011_6 pop_11_outexclude_2011_7
pop_11_outexclude_2011_8 pop_11_outexclude_2011_9 pop_11_outexclude_2011_10 pop_11_outexclude_2011_11 pop_11_outexclude_2011_12
pop_11_carexclude_2011_1 pop_11_carexclude_2011_2 pop_11_carexclude_2011_3 pop_11_carexclude_2011_4 pop_11_carexclude_2011_5 pop_11_carexclude_2011_6 pop_11_carexclude_2011_7
pop_11_carexclude_2011_8 pop_11_carexclude_2011_9 pop_11_carexclude_2011_10 pop_11_carexclude_2011_11 pop_11_carexclude_2011_12

pop_11_INexclude_2012_1 pop_11_INexclude_2012_2 pop_11_INexclude_2012_3 pop_11_INexclude_2012_4 pop_11_INexclude_2012_5 pop_11_INexclude_2012_6 pop_11_INexclude_2012_7
pop_11_INexclude_2012_8 pop_11_INexclude_2012_9 pop_11_INexclude_2012_10 pop_11_INexclude_2012_11 pop_11_INexclude_2012_12
pop_11_outexclude_2012_1 pop_11_outexclude_2012_2 pop_11_outexclude_2012_3 pop_11_outexclude_2012_4 pop_11_outexclude_2012_5 pop_11_outexclude_2012_6 pop_11_outexclude_2012_7
pop_11_outexclude_2012_8 pop_11_outexclude_2012_9 pop_11_outexclude_2012_10 pop_11_outexclude_2012_11 pop_11_outexclude_2012_12
pop_11_carexclude_2012_1 pop_11_carexclude_2012_2 pop_11_carexclude_2012_3 pop_11_carexclude_2012_4 pop_11_carexclude_2012_5 pop_11_carexclude_2012_6 pop_11_carexclude_2012_7
pop_11_carexclude_2012_8 pop_11_carexclude_2012_9 pop_11_carexclude_2012_10 pop_11_carexclude_2012_11 pop_11_carexclude_2012_12

pop_11_INexclude_2013_1 pop_11_INexclude_2013_2 pop_11_INexclude_2013_3 pop_11_INexclude_2013_4 pop_11_INexclude_2013_5 pop_11_INexclude_2013_6 pop_11_INexclude_2013_7
pop_11_INexclude_2013_8 pop_11_INexclude_2013_9 pop_11_INexclude_2013_10 pop_11_INexclude_2013_11 pop_11_INexclude_2013_12
pop_11_outexclude_2013_1 pop_11_outexclude_2013_2 pop_11_outexclude_2013_3 pop_11_outexclude_2013_4 pop_11_outexclude_2013_5 pop_11_outexclude_2013_6 pop_11_outexclude_2013_7
pop_11_outexclude_2013_8 pop_11_outexclude_2013_9 pop_11_outexclude_2013_10 pop_11_outexclude_2013_11 pop_11_outexclude_2013_12
pop_11_carexclude_2013_1 pop_11_carexclude_2013_2 pop_11_carexclude_2013_3 pop_11_carexclude_2013_4 pop_11_carexclude_2013_5 pop_11_carexclude_2013_6 pop_11_carexclude_2013_7
pop_11_carexclude_2013_8 pop_11_carexclude_2013_9 pop_11_carexclude_2013_10 pop_11_carexclude_2013_11 pop_11_carexclude_2013_12

pop_11_INexclude_2014_1 pop_11_INexclude_2014_2 pop_11_INexclude_2014_3 pop_11_INexclude_2014_4 pop_11_INexclude_2014_5 pop_11_INexclude_2014_6 pop_11_INexclude_2014_7
pop_11_INexclude_2014_8 pop_11_INexclude_2014_9 pop_11_INexclude_2014_10 pop_11_INexclude_2014_11 pop_11_INexclude_2014_12
pop_11_outexclude_2014_1 pop_11_outexclude_2014_2 pop_11_outexclude_2014_3 pop_11_outexclude_2014_4 pop_11_outexclude_2014_5 pop_11_outexclude_2014_6 pop_11_outexclude_2014_7
pop_11_outexclude_2014_8 pop_11_outexclude_2014_9 pop_11_outexclude_2014_10 pop_11_outexclude_2014_11 pop_11_outexclude_2014_12
pop_11_carexclude_2014_1 pop_11_carexclude_2014_2 pop_11_carexclude_2014_3 pop_11_carexclude_2014_4 pop_11_carexclude_2014_5 pop_11_carexclude_2014_6 pop_11_carexclude_2014_7
pop_11_carexclude_2014_8 pop_11_carexclude_2014_9 pop_11_carexclude_2014_10 pop_11_carexclude_2014_11 pop_11_carexclude_2014_12

pop_11_INexclude_2015_1 pop_11_INexclude_2015_2 pop_11_INexclude_2015_3 pop_11_INexclude_2015_4 pop_11_INexclude_2015_5 pop_11_INexclude_2015_6 pop_11_INexclude_2015_7
pop_11_INexclude_2015_8 pop_11_INexclude_2015_9 pop_11_INexclude_2015_10 pop_11_INexclude_2015_11 pop_11_INexclude_2015_12
pop_11_outexclude_2015_1 pop_11_outexclude_2015_2 pop_11_outexclude_2015_3 pop_11_outexclude_2015_4 pop_11_outexclude_2015_5 pop_11_outexclude_2015_6 pop_11_outexclude_2015_7
pop_11_outexclude_2015_8 pop_11_outexclude_2015_9 pop_11_outexclude_2015_10 pop_11_outexclude_2015_11 pop_11_outexclude_2015_12
pop_11_carexclude_2015_1 pop_11_carexclude_2015_2 pop_11_carexclude_2015_3 pop_11_carexclude_2015_4 pop_11_carexclude_2015_5 pop_11_carexclude_2015_6 pop_11_carexclude_2015_7
pop_11_carexclude_2015_8 pop_11_carexclude_2015_9 pop_11_carexclude_2015_10 pop_11_carexclude_2015_11 pop_11_carexclude_2015_12

pop_11_INexclude_2016_1 pop_11_INexclude_2016_2 pop_11_INexclude_2016_3 pop_11_INexclude_2016_4 pop_11_INexclude_2016_5 pop_11_INexclude_2016_6 pop_11_INexclude_2016_7
pop_11_INexclude_2016_8 pop_11_INexclude_2016_9 pop_11_INexclude_2016_10 pop_11_INexclude_2016_11 pop_11_INexclude_2016_12
pop_11_outexclude_2016_1 pop_11_outexclude_2016_2 pop_11_outexclude_2016_3 pop_11_outexclude_2016_4 pop_11_outexclude_2016_5 pop_11_outexclude_2016_6 pop_11_outexclude_2016_7
pop_11_outexclude_2016_8 pop_11_outexclude_2016_9 pop_11_outexclude_2016_10 pop_11_outexclude_2016_11 pop_11_outexclude_2016_12
pop_11_carexclude_2016_1 pop_11_carexclude_2016_2 pop_11_carexclude_2016_3 pop_11_carexclude_2016_4 pop_11_carexclude_2016_5 pop_11_carexclude_2016_6 pop_11_carexclude_2016_7
pop_11_carexclude_2016_8 pop_11_carexclude_2016_9 pop_11_carexclude_2016_10 pop_11_carexclude_2016_11 pop_11_carexclude_2016_12

pop_11_INexclude_2017_1 pop_11_INexclude_2017_2 pop_11_INexclude_2017_3 pop_11_INexclude_2017_4 pop_11_INexclude_2017_5 pop_11_INexclude_2017_6 pop_11_INexclude_2017_7
pop_11_INexclude_2017_8 pop_11_INexclude_2017_9 pop_11_INexclude_2017_10 pop_11_INexclude_2017_11 pop_11_INexclude_2017_12
pop_11_outexclude_2017_1 pop_11_outexclude_2017_2 pop_11_outexclude_2017_3 pop_11_outexclude_2017_4 pop_11_outexclude_2017_5 pop_11_outexclude_2017_6 pop_11_outexclude_2017_7
pop_11_outexclude_2017_8 pop_11_outexclude_2017_9 pop_11_outexclude_2017_10 pop_11_outexclude_2017_11 pop_11_outexclude_2017_12
pop_11_carexclude_2017_1 pop_11_carexclude_2017_2 pop_11_carexclude_2017_3 pop_11_carexclude_2017_4 pop_11_carexclude_2017_5 pop_11_carexclude_2017_6 pop_11_carexclude_2017_7
pop_11_carexclude_2017_8 pop_11_carexclude_2017_9 pop_11_carexclude_2017_10 pop_11_carexclude_2017_11 pop_11_carexclude_2017_12

pop_11_INexclude_2018_1 pop_11_INexclude_2018_2 pop_11_INexclude_2018_3 pop_11_INexclude_2018_4 pop_11_INexclude_2018_5 pop_11_INexclude_2018_6 pop_11_INexclude_2018_7
pop_11_INexclude_2018_8 pop_11_INexclude_2018_9 pop_11_INexclude_2018_10 pop_11_INexclude_2018_11 pop_11_INexclude_2018_12
pop_11_outexclude_2018_1 pop_11_outexclude_2018_2 pop_11_outexclude_2018_3 pop_11_outexclude_2018_4 pop_11_outexclude_2018_5 pop_11_outexclude_2018_6 pop_11_outexclude_2018_7
pop_11_outexclude_2018_8 pop_11_outexclude_2018_9 pop_11_outexclude_2018_10 pop_11_outexclude_2018_11 pop_11_outexclude_2018_12
pop_11_carexclude_2018_1 pop_11_carexclude_2018_2 pop_11_carexclude_2018_3 pop_11_carexclude_2018_4 pop_11_carexclude_2018_5 pop_11_carexclude_2018_6 pop_11_carexclude_2018_7
pop_11_carexclude_2018_8 pop_11_carexclude_2018_9 pop_11_carexclude_2018_10 pop_11_carexclude_2018_11 pop_11_carexclude_2018_12
;
run;
proc sort data=pop_11_exclude NODUPKEY;by bene_id pop_11_malig_dt;run;*358,411;

*if in cc_cohort and in numerator and didn't have endometrial cancer or genital cancer based on icd dx codes before hysterectomy date then include;
proc sort data=cc; by bene_id;*228,233;
proc sort data=pop_11_exclude NODUPKEY; by bene_id; *60,018 only keep first cancer dx for exclusion;
proc sort data=pop_11_denom NODUPKEY; by bene_id;*denominator is person level not date so keep only 1 hysterectomy for the year-sorted above so we are keeping 1st hysterectomy only;
		*229,847 when de-dupe to 1 hyst per person;
data shu172sl.pop_11_cc; 
merge cc(in=a) pop_11_exclude pop_11_denom;
if a;
by bene_id;
if /*CANCER_ENDOMETRIAL in(2,3) and*/ cancer_endometrial_ever ne . and cancer_endometrial_ever<=(pop_11_elig_dt+30) then popped_11=0;*if endometrial cancer after hyesterectomy then keep;
if popped_11=. then popped_11=1;*assume all those without malignancy had benign indication;
run;*228,233 (some not in cc file so dropped);
proc sort data=shu172sl.pop_11_cc; by pop_11_nch_clm_type_cd; run;
proc freq data=shu172sl.pop_11_cc; *by pop_11_nch_clm_type_cd; table pop_11_year*popped_11 / nocol nopercent; run;




