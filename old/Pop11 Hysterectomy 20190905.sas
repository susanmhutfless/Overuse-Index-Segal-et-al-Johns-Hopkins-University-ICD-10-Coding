*Pop 11: Hysterectomy;
*Eligible: all women--even those that did not have a hysterectomy but may have had a hysterectomy before Medicare eligible;
*Popped: had hysterectomy without female genital organ malignancy (vulva, vagina, uterus, ovary, unspecified--all but placenta--if had hysterectomy for placenta malignancy then not considered a "pop");
%let pop11_hcpcs='58150', '58152', '58180', '58200', '58210', '58260', '58262', '58263', '58267', '58270', '58275', '58280', '58285', '58290',
				'58291', '58292', '59293', '59294', '58541', '58542', '58543', '58544', '58548', '58550', '58552', '58553', '58554', '58570',
				'58571', '58572', '58573'; *Hysterectomy;
*did not include ICD codes for hysterectomy-they did not match the DRG list;

*for exclusion;
		*DID NOT INCLUDE PLACENTA or "uncertain behavior"--note that DRG lists included placenta, in situ and uncertain behavior ICD dx codes;
%let pop11_icd_EX_dx9_3='179', '180', '182','183', '184';*"malignancy" exlcusion icd-9;
%let pop11_icd_EX_dx9='1953','1986','19882';
%let pop11_icd_EX_dx10_3='C51','C52','C53','C54','C55','C56','C57'; *"malignancy" exclusion icd-10 based on cross-walk and check of DRG hysterectomy codes for malignancy;
%let pop11_icd_EX_dx10_4='C763','C796';
%let pop11_icd_EX_dx10='C7982';
*did not include DRG exclusion--checked diagnosis codes included in malignancy DRG lists and incorporated those that matched original ICD list;


*First: Identify HCPCS codes for hysterectomy from inpatient, outpatient, carrier;
*numerator for inpatient, outpatient, carrier;
%macro inp_rev(source=, include_cohort=);
proc sql;
create table &include_cohort (compress=yes) as
select *
from 
&source
where 
hcpcs_cd in (&pop11_hcpcs);
quit;
proc sort data=&include_cohort NODUPKEY; by bene_id clm_thru_dt; run;
Data &include_cohort (keep=bene_id popped_11_dt popped_11); length popped_11 3; set &include_cohort;   
popped_11=1; popped_11_dt=clm_thru_dt; 
run; 
%mend;
%inp_rev(source=rif2010.inpatient_revenue_01, include_cohort=pop11_INnum_2010_1);
%inp_rev(source=rif2010.inpatient_revenue_02, include_cohort=pop11_INnum_2010_2);
%inp_rev(source=rif2010.inpatient_revenue_03, include_cohort=pop11_INnum_2010_3);
%inp_rev(source=rif2010.inpatient_revenue_04, include_cohort=pop11_INnum_2010_4);
%inp_rev(source=rif2010.inpatient_revenue_05, include_cohort=pop11_INnum_2010_5);
%inp_rev(source=rif2010.inpatient_revenue_06, include_cohort=pop11_INnum_2010_6);
%inp_rev(source=rif2010.inpatient_revenue_07, include_cohort=pop11_INnum_2010_7);
%inp_rev(source=rif2010.inpatient_revenue_08, include_cohort=pop11_INnum_2010_8);
%inp_rev(source=rif2010.inpatient_revenue_09, include_cohort=pop11_INnum_2010_9);
%inp_rev(source=rif2010.inpatient_revenue_10, include_cohort=pop11_INnum_2010_10);
%inp_rev(source=rif2010.inpatient_revenue_11, include_cohort=pop11_INnum_2010_11);
%inp_rev(source=rif2010.inpatient_revenue_12, include_cohort=pop11_INnum_2010_12);
%inp_rev(source=rif2010.outpatient_revenue_01, include_cohort=pop11_OUTnum_2010_1);
%inp_rev(source=rif2010.outpatient_revenue_02, include_cohort=pop11_OUTnum_2010_2);
%inp_rev(source=rif2010.outpatient_revenue_03, include_cohort=pop11_OUTnum_2010_3);
%inp_rev(source=rif2010.outpatient_revenue_04, include_cohort=pop11_OUTnum_2010_4);
%inp_rev(source=rif2010.outpatient_revenue_05, include_cohort=pop11_OUTnum_2010_5);
%inp_rev(source=rif2010.outpatient_revenue_06, include_cohort=pop11_OUTnum_2010_6);
%inp_rev(source=rif2010.outpatient_revenue_07, include_cohort=pop11_OUTnum_2010_7);
%inp_rev(source=rif2010.outpatient_revenue_08, include_cohort=pop11_OUTnum_2010_8);
%inp_rev(source=rif2010.outpatient_revenue_09, include_cohort=pop11_OUTnum_2010_9);
%inp_rev(source=rif2010.outpatient_revenue_10, include_cohort=pop11_OUTnum_2010_10);
%inp_rev(source=rif2010.outpatient_revenue_11, include_cohort=pop11_OUTnum_2010_11);
%inp_rev(source=rif2010.outpatient_revenue_12, include_cohort=pop11_OUTnum_2010_12);
%inp_rev(source=rif2010.bcarrier_line_01, include_cohort=pop11_CARnum_2010_1);
%inp_rev(source=rif2010.bcarrier_line_02, include_cohort=pop11_CARnum_2010_2);
%inp_rev(source=rif2010.bcarrier_line_03, include_cohort=pop11_CARnum_2010_3);
%inp_rev(source=rif2010.bcarrier_line_04, include_cohort=pop11_CARnum_2010_4);
%inp_rev(source=rif2010.bcarrier_line_05, include_cohort=pop11_CARnum_2010_5);
%inp_rev(source=rif2010.bcarrier_line_06, include_cohort=pop11_CARnum_2010_6);
%inp_rev(source=rif2010.bcarrier_line_07, include_cohort=pop11_CARnum_2010_7);
%inp_rev(source=rif2010.bcarrier_line_08, include_cohort=pop11_CARnum_2010_8);
%inp_rev(source=rif2010.bcarrier_line_09, include_cohort=pop11_CARnum_2010_9);
%inp_rev(source=rif2010.bcarrier_line_10, include_cohort=pop11_CARnum_2010_10);
%inp_rev(source=rif2010.bcarrier_line_11, include_cohort=pop11_CARnum_2010_11);
%inp_rev(source=rif2010.bcarrier_line_12, include_cohort=pop11_CARnum_2010_12);

/*%inp_rev(source=rif2011.inpatient_revenue_01, include_cohort=pop11_INnum_2011_1);
%inp_rev(source=rif2011.inpatient_revenue_02, include_cohort=pop11_INnum_2011_2);
%inp_rev(source=rif2011.inpatient_revenue_03, include_cohort=pop11_INnum_2011_3);
%inp_rev(source=rif2011.inpatient_revenue_04, include_cohort=pop11_INnum_2011_4);
%inp_rev(source=rif2011.inpatient_revenue_05, include_cohort=pop11_INnum_2011_5);
%inp_rev(source=rif2011.inpatient_revenue_06, include_cohort=pop11_INnum_2011_6);
%inp_rev(source=rif2011.inpatient_revenue_07, include_cohort=pop11_INnum_2011_7);
%inp_rev(source=rif2011.inpatient_revenue_08, include_cohort=pop11_INnum_2011_8);
%inp_rev(source=rif2011.inpatient_revenue_09, include_cohort=pop11_INnum_2011_9);
%inp_rev(source=rif2011.inpatient_revenue_10, include_cohort=pop11_INnum_2011_10);
%inp_rev(source=rif2011.inpatient_revenue_11, include_cohort=pop11_INnum_2011_11);
%inp_rev(source=rif2011.inpatient_revenue_12, include_cohort=pop11_INnum_2011_12);
%inp_rev(source=rif2011.outpatient_revenue_01, include_cohort=pop11_OUTnum_2011_1);
%inp_rev(source=rif2011.outpatient_revenue_02, include_cohort=pop11_OUTnum_2011_2);
%inp_rev(source=rif2011.outpatient_revenue_03, include_cohort=pop11_OUTnum_2011_3);
%inp_rev(source=rif2011.outpatient_revenue_04, include_cohort=pop11_OUTnum_2011_4);
%inp_rev(source=rif2011.outpatient_revenue_05, include_cohort=pop11_OUTnum_2011_5);
%inp_rev(source=rif2011.outpatient_revenue_06, include_cohort=pop11_OUTnum_2011_6);
%inp_rev(source=rif2011.outpatient_revenue_07, include_cohort=pop11_OUTnum_2011_7);
%inp_rev(source=rif2011.outpatient_revenue_08, include_cohort=pop11_OUTnum_2011_8);
%inp_rev(source=rif2011.outpatient_revenue_09, include_cohort=pop11_OUTnum_2011_9);
%inp_rev(source=rif2011.outpatient_revenue_10, include_cohort=pop11_OUTnum_2011_10);
%inp_rev(source=rif2011.outpatient_revenue_11, include_cohort=pop11_OUTnum_2011_11);
%inp_rev(source=rif2011.outpatient_revenue_12, include_cohort=pop11_OUTnum_2011_12);
%inp_rev(source=rif2011.bcarrier_line_01, include_cohort=pop11_CARnum_2011_1);
%inp_rev(source=rif2011.bcarrier_line_02, include_cohort=pop11_CARnum_2011_2);
%inp_rev(source=rif2011.bcarrier_line_03, include_cohort=pop11_CARnum_2011_3);
%inp_rev(source=rif2011.bcarrier_line_04, include_cohort=pop11_CARnum_2011_4);
%inp_rev(source=rif2011.bcarrier_line_05, include_cohort=pop11_CARnum_2011_5);
%inp_rev(source=rif2011.bcarrier_line_06, include_cohort=pop11_CARnum_2011_6);
%inp_rev(source=rif2011.bcarrier_line_07, include_cohort=pop11_CARnum_2011_7);
%inp_rev(source=rif2011.bcarrier_line_08, include_cohort=pop11_CARnum_2011_8);
%inp_rev(source=rif2011.bcarrier_line_09, include_cohort=pop11_CARnum_2011_9);
%inp_rev(source=rif2011.bcarrier_line_10, include_cohort=pop11_CARnum_2011_10);
%inp_rev(source=rif2011.bcarrier_line_11, include_cohort=pop11_CARnum_2011_11);
%inp_rev(source=rif2011.bcarrier_line_12, include_cohort=pop11_CARnum_2011_12);

%inp_rev(source=rif2012.inpatient_revenue_01, include_cohort=pop11_INnum_2012_1);
%inp_rev(source=rif2012.inpatient_revenue_02, include_cohort=pop11_INnum_2012_2);
%inp_rev(source=rif2012.inpatient_revenue_03, include_cohort=pop11_INnum_2012_3);
%inp_rev(source=rif2012.inpatient_revenue_04, include_cohort=pop11_INnum_2012_4);
%inp_rev(source=rif2012.inpatient_revenue_05, include_cohort=pop11_INnum_2012_5);
%inp_rev(source=rif2012.inpatient_revenue_06, include_cohort=pop11_INnum_2012_6);
%inp_rev(source=rif2012.inpatient_revenue_07, include_cohort=pop11_INnum_2012_7);
%inp_rev(source=rif2012.inpatient_revenue_08, include_cohort=pop11_INnum_2012_8);
%inp_rev(source=rif2012.inpatient_revenue_09, include_cohort=pop11_INnum_2012_9);
%inp_rev(source=rif2012.inpatient_revenue_10, include_cohort=pop11_INnum_2012_10);
%inp_rev(source=rif2012.inpatient_revenue_11, include_cohort=pop11_INnum_2012_11);
%inp_rev(source=rif2012.inpatient_revenue_12, include_cohort=pop11_INnum_2012_12);
%inp_rev(source=rif2012.outpatient_revenue_01, include_cohort=pop11_OUTnum_2012_1);
%inp_rev(source=rif2012.outpatient_revenue_02, include_cohort=pop11_OUTnum_2012_2);
%inp_rev(source=rif2012.outpatient_revenue_03, include_cohort=pop11_OUTnum_2012_3);
%inp_rev(source=rif2012.outpatient_revenue_04, include_cohort=pop11_OUTnum_2012_4);
%inp_rev(source=rif2012.outpatient_revenue_05, include_cohort=pop11_OUTnum_2012_5);
%inp_rev(source=rif2012.outpatient_revenue_06, include_cohort=pop11_OUTnum_2012_6);
%inp_rev(source=rif2012.outpatient_revenue_07, include_cohort=pop11_OUTnum_2012_7);
%inp_rev(source=rif2012.outpatient_revenue_08, include_cohort=pop11_OUTnum_2012_8);
%inp_rev(source=rif2012.outpatient_revenue_09, include_cohort=pop11_OUTnum_2012_9);
%inp_rev(source=rif2012.outpatient_revenue_10, include_cohort=pop11_OUTnum_2012_10);
%inp_rev(source=rif2012.outpatient_revenue_11, include_cohort=pop11_OUTnum_2012_11);
%inp_rev(source=rif2012.outpatient_revenue_12, include_cohort=pop11_OUTnum_2012_12);
%inp_rev(source=rif2012.bcarrier_line_01, include_cohort=pop11_CARnum_2012_1);
%inp_rev(source=rif2012.bcarrier_line_02, include_cohort=pop11_CARnum_2012_2);
%inp_rev(source=rif2012.bcarrier_line_03, include_cohort=pop11_CARnum_2012_3);
%inp_rev(source=rif2012.bcarrier_line_04, include_cohort=pop11_CARnum_2012_4);
%inp_rev(source=rif2012.bcarrier_line_05, include_cohort=pop11_CARnum_2012_5);
%inp_rev(source=rif2012.bcarrier_line_06, include_cohort=pop11_CARnum_2012_6);
%inp_rev(source=rif2012.bcarrier_line_07, include_cohort=pop11_CARnum_2012_7);
%inp_rev(source=rif2012.bcarrier_line_08, include_cohort=pop11_CARnum_2012_8);
%inp_rev(source=rif2012.bcarrier_line_09, include_cohort=pop11_CARnum_2012_9);
%inp_rev(source=rif2012.bcarrier_line_10, include_cohort=pop11_CARnum_2012_10);
%inp_rev(source=rif2012.bcarrier_line_11, include_cohort=pop11_CARnum_2012_11);
%inp_rev(source=rif2012.bcarrier_line_12, include_cohort=pop11_CARnum_2012_12);

%inp_rev(source=rif2013.inpatient_revenue_01, include_cohort=pop11_INnum_2013_1);
%inp_rev(source=rif2013.inpatient_revenue_02, include_cohort=pop11_INnum_2013_2);
%inp_rev(source=rif2013.inpatient_revenue_03, include_cohort=pop11_INnum_2013_3);
%inp_rev(source=rif2013.inpatient_revenue_04, include_cohort=pop11_INnum_2013_4);
%inp_rev(source=rif2013.inpatient_revenue_05, include_cohort=pop11_INnum_2013_5);
%inp_rev(source=rif2013.inpatient_revenue_06, include_cohort=pop11_INnum_2013_6);
%inp_rev(source=rif2013.inpatient_revenue_07, include_cohort=pop11_INnum_2013_7);
%inp_rev(source=rif2013.inpatient_revenue_08, include_cohort=pop11_INnum_2013_8);
%inp_rev(source=rif2013.inpatient_revenue_09, include_cohort=pop11_INnum_2013_9);
%inp_rev(source=rif2013.inpatient_revenue_10, include_cohort=pop11_INnum_2013_10);
%inp_rev(source=rif2013.inpatient_revenue_11, include_cohort=pop11_INnum_2013_11);
%inp_rev(source=rif2013.inpatient_revenue_12, include_cohort=pop11_INnum_2013_12);
%inp_rev(source=rif2013.outpatient_revenue_01, include_cohort=pop11_OUTnum_2013_1);
%inp_rev(source=rif2013.outpatient_revenue_02, include_cohort=pop11_OUTnum_2013_2);
%inp_rev(source=rif2013.outpatient_revenue_03, include_cohort=pop11_OUTnum_2013_3);
%inp_rev(source=rif2013.outpatient_revenue_04, include_cohort=pop11_OUTnum_2013_4);
%inp_rev(source=rif2013.outpatient_revenue_05, include_cohort=pop11_OUTnum_2013_5);
%inp_rev(source=rif2013.outpatient_revenue_06, include_cohort=pop11_OUTnum_2013_6);
%inp_rev(source=rif2013.outpatient_revenue_07, include_cohort=pop11_OUTnum_2013_7);
%inp_rev(source=rif2013.outpatient_revenue_08, include_cohort=pop11_OUTnum_2013_8);
%inp_rev(source=rif2013.outpatient_revenue_09, include_cohort=pop11_OUTnum_2013_9);
%inp_rev(source=rif2013.outpatient_revenue_10, include_cohort=pop11_OUTnum_2013_10);
%inp_rev(source=rif2013.outpatient_revenue_11, include_cohort=pop11_OUTnum_2013_11);
%inp_rev(source=rif2013.outpatient_revenue_12, include_cohort=pop11_OUTnum_2013_12);
%inp_rev(source=rif2013.bcarrier_line_01, include_cohort=pop11_CARnum_2013_1);
%inp_rev(source=rif2013.bcarrier_line_02, include_cohort=pop11_CARnum_2013_2);
%inp_rev(source=rif2013.bcarrier_line_03, include_cohort=pop11_CARnum_2013_3);
%inp_rev(source=rif2013.bcarrier_line_04, include_cohort=pop11_CARnum_2013_4);
%inp_rev(source=rif2013.bcarrier_line_05, include_cohort=pop11_CARnum_2013_5);
%inp_rev(source=rif2013.bcarrier_line_06, include_cohort=pop11_CARnum_2013_6);
%inp_rev(source=rif2013.bcarrier_line_07, include_cohort=pop11_CARnum_2013_7);
%inp_rev(source=rif2013.bcarrier_line_08, include_cohort=pop11_CARnum_2013_8);
%inp_rev(source=rif2013.bcarrier_line_09, include_cohort=pop11_CARnum_2013_9);
%inp_rev(source=rif2013.bcarrier_line_10, include_cohort=pop11_CARnum_2013_10);
%inp_rev(source=rif2013.bcarrier_line_11, include_cohort=pop11_CARnum_2013_11);
%inp_rev(source=rif2013.bcarrier_line_12, include_cohort=pop11_CARnum_2013_12);

%inp_rev(source=rif2014.inpatient_revenue_01, include_cohort=pop11_INnum_2014_1);
%inp_rev(source=rif2014.inpatient_revenue_02, include_cohort=pop11_INnum_2014_2);
%inp_rev(source=rif2014.inpatient_revenue_03, include_cohort=pop11_INnum_2014_3);
%inp_rev(source=rif2014.inpatient_revenue_04, include_cohort=pop11_INnum_2014_4);
%inp_rev(source=rif2014.inpatient_revenue_05, include_cohort=pop11_INnum_2014_5);
%inp_rev(source=rif2014.inpatient_revenue_06, include_cohort=pop11_INnum_2014_6);
%inp_rev(source=rif2014.inpatient_revenue_07, include_cohort=pop11_INnum_2014_7);
%inp_rev(source=rif2014.inpatient_revenue_08, include_cohort=pop11_INnum_2014_8);
%inp_rev(source=rif2014.inpatient_revenue_09, include_cohort=pop11_INnum_2014_9);
%inp_rev(source=rif2014.inpatient_revenue_10, include_cohort=pop11_INnum_2014_10);
%inp_rev(source=rif2014.inpatient_revenue_11, include_cohort=pop11_INnum_2014_11);
%inp_rev(source=rif2014.inpatient_revenue_12, include_cohort=pop11_INnum_2014_12);
%inp_rev(source=rif2014.outpatient_revenue_01, include_cohort=pop11_OUTnum_2014_1);
%inp_rev(source=rif2014.outpatient_revenue_02, include_cohort=pop11_OUTnum_2014_2);
%inp_rev(source=rif2014.outpatient_revenue_03, include_cohort=pop11_OUTnum_2014_3);
%inp_rev(source=rif2014.outpatient_revenue_04, include_cohort=pop11_OUTnum_2014_4);
%inp_rev(source=rif2014.outpatient_revenue_05, include_cohort=pop11_OUTnum_2014_5);
%inp_rev(source=rif2014.outpatient_revenue_06, include_cohort=pop11_OUTnum_2014_6);
%inp_rev(source=rif2014.outpatient_revenue_07, include_cohort=pop11_OUTnum_2014_7);
%inp_rev(source=rif2014.outpatient_revenue_08, include_cohort=pop11_OUTnum_2014_8);
%inp_rev(source=rif2014.outpatient_revenue_09, include_cohort=pop11_OUTnum_2014_9);
%inp_rev(source=rif2014.outpatient_revenue_10, include_cohort=pop11_OUTnum_2014_10);
%inp_rev(source=rif2014.outpatient_revenue_11, include_cohort=pop11_OUTnum_2014_11);
%inp_rev(source=rif2014.outpatient_revenue_12, include_cohort=pop11_OUTnum_2014_12);
%inp_rev(source=rif2014.bcarrier_line_01, include_cohort=pop11_CARnum_2014_1);
%inp_rev(source=rif2014.bcarrier_line_02, include_cohort=pop11_CARnum_2014_2);
%inp_rev(source=rif2014.bcarrier_line_03, include_cohort=pop11_CARnum_2014_3);
%inp_rev(source=rif2014.bcarrier_line_04, include_cohort=pop11_CARnum_2014_4);
%inp_rev(source=rif2014.bcarrier_line_05, include_cohort=pop11_CARnum_2014_5);
%inp_rev(source=rif2014.bcarrier_line_06, include_cohort=pop11_CARnum_2014_6);
%inp_rev(source=rif2014.bcarrier_line_07, include_cohort=pop11_CARnum_2014_7);
%inp_rev(source=rif2014.bcarrier_line_08, include_cohort=pop11_CARnum_2014_8);
%inp_rev(source=rif2014.bcarrier_line_09, include_cohort=pop11_CARnum_2014_9);
%inp_rev(source=rif2014.bcarrier_line_10, include_cohort=pop11_CARnum_2014_10);
%inp_rev(source=rif2014.bcarrier_line_11, include_cohort=pop11_CARnum_2014_11);
%inp_rev(source=rif2014.bcarrier_line_12, include_cohort=pop11_CARnum_2014_12);

%inp_rev(source=rif2015.inpatient_revenue_01, include_cohort=pop11_INnum_2015_1);
%inp_rev(source=rif2015.inpatient_revenue_02, include_cohort=pop11_INnum_2015_2);
%inp_rev(source=rif2015.inpatient_revenue_03, include_cohort=pop11_INnum_2015_3);
%inp_rev(source=rif2015.inpatient_revenue_04, include_cohort=pop11_INnum_2015_4);
%inp_rev(source=rif2015.inpatient_revenue_05, include_cohort=pop11_INnum_2015_5);
%inp_rev(source=rif2015.inpatient_revenue_06, include_cohort=pop11_INnum_2015_6);
%inp_rev(source=rif2015.inpatient_revenue_07, include_cohort=pop11_INnum_2015_7);
%inp_rev(source=rif2015.inpatient_revenue_08, include_cohort=pop11_INnum_2015_8);
%inp_rev(source=rif2015.inpatient_revenue_09, include_cohort=pop11_INnum_2015_9);
%inp_rev(source=rif2015.inpatient_revenue_10, include_cohort=pop11_INnum_2015_10);
%inp_rev(source=rif2015.inpatient_revenue_11, include_cohort=pop11_INnum_2015_11);
%inp_rev(source=rif2015.inpatient_revenue_12, include_cohort=pop11_INnum_2015_12);
%inp_rev(source=rif2015.outpatient_revenue_01, include_cohort=pop11_OUTnum_2015_1);
%inp_rev(source=rif2015.outpatient_revenue_02, include_cohort=pop11_OUTnum_2015_2);
%inp_rev(source=rif2015.outpatient_revenue_03, include_cohort=pop11_OUTnum_2015_3);
%inp_rev(source=rif2015.outpatient_revenue_04, include_cohort=pop11_OUTnum_2015_4);
%inp_rev(source=rif2015.outpatient_revenue_05, include_cohort=pop11_OUTnum_2015_5);
%inp_rev(source=rif2015.outpatient_revenue_06, include_cohort=pop11_OUTnum_2015_6);
%inp_rev(source=rif2015.outpatient_revenue_07, include_cohort=pop11_OUTnum_2015_7);
%inp_rev(source=rif2015.outpatient_revenue_08, include_cohort=pop11_OUTnum_2015_8);
%inp_rev(source=rif2015.outpatient_revenue_09, include_cohort=pop11_OUTnum_2015_9);
%inp_rev(source=rif2015.outpatient_revenue_10, include_cohort=pop11_OUTnum_2015_10);
%inp_rev(source=rif2015.outpatient_revenue_11, include_cohort=pop11_OUTnum_2015_11);
%inp_rev(source=rif2015.outpatient_revenue_12, include_cohort=pop11_OUTnum_2015_12);
%inp_rev(source=rif2015.bcarrier_line_01, include_cohort=pop11_CARnum_2015_1);
%inp_rev(source=rif2015.bcarrier_line_02, include_cohort=pop11_CARnum_2015_2);
%inp_rev(source=rif2015.bcarrier_line_03, include_cohort=pop11_CARnum_2015_3);
%inp_rev(source=rif2015.bcarrier_line_04, include_cohort=pop11_CARnum_2015_4);
%inp_rev(source=rif2015.bcarrier_line_05, include_cohort=pop11_CARnum_2015_5);
%inp_rev(source=rif2015.bcarrier_line_06, include_cohort=pop11_CARnum_2015_6);
%inp_rev(source=rif2015.bcarrier_line_07, include_cohort=pop11_CARnum_2015_7);
%inp_rev(source=rif2015.bcarrier_line_08, include_cohort=pop11_CARnum_2015_8);
%inp_rev(source=rif2015.bcarrier_line_09, include_cohort=pop11_CARnum_2015_9);
%inp_rev(source=rif2015.bcarrier_line_10, include_cohort=pop11_CARnum_2015_10);
%inp_rev(source=rif2015.bcarrier_line_11, include_cohort=pop11_CARnum_2015_11);
%inp_rev(source=rif2015.bcarrier_line_12, include_cohort=pop11_CARnum_2015_12);

%inp_rev(source=rif2016.inpatient_revenue_01, include_cohort=pop11_INnum_2016_1);
%inp_rev(source=rif2016.inpatient_revenue_02, include_cohort=pop11_INnum_2016_2);
%inp_rev(source=rif2016.inpatient_revenue_03, include_cohort=pop11_INnum_2016_3);
%inp_rev(source=rif2016.inpatient_revenue_04, include_cohort=pop11_INnum_2016_4);
%inp_rev(source=rif2016.inpatient_revenue_05, include_cohort=pop11_INnum_2016_5);
%inp_rev(source=rif2016.inpatient_revenue_06, include_cohort=pop11_INnum_2016_6);
%inp_rev(source=rif2016.inpatient_revenue_07, include_cohort=pop11_INnum_2016_7);
%inp_rev(source=rif2016.inpatient_revenue_08, include_cohort=pop11_INnum_2016_8);
%inp_rev(source=rif2016.inpatient_revenue_09, include_cohort=pop11_INnum_2016_9);
%inp_rev(source=rif2016.inpatient_revenue_10, include_cohort=pop11_INnum_2016_10);
%inp_rev(source=rif2016.inpatient_revenue_11, include_cohort=pop11_INnum_2016_11);
%inp_rev(source=rif2016.inpatient_revenue_12, include_cohort=pop11_INnum_2016_12);
%inp_rev(source=rif2016.outpatient_revenue_01, include_cohort=pop11_OUTnum_2016_1);
%inp_rev(source=rif2016.outpatient_revenue_02, include_cohort=pop11_OUTnum_2016_2);
%inp_rev(source=rif2016.outpatient_revenue_03, include_cohort=pop11_OUTnum_2016_3);
%inp_rev(source=rif2016.outpatient_revenue_04, include_cohort=pop11_OUTnum_2016_4);
%inp_rev(source=rif2016.outpatient_revenue_05, include_cohort=pop11_OUTnum_2016_5);
%inp_rev(source=rif2016.outpatient_revenue_06, include_cohort=pop11_OUTnum_2016_6);
%inp_rev(source=rif2016.outpatient_revenue_07, include_cohort=pop11_OUTnum_2016_7);
%inp_rev(source=rif2016.outpatient_revenue_08, include_cohort=pop11_OUTnum_2016_8);
%inp_rev(source=rif2016.outpatient_revenue_09, include_cohort=pop11_OUTnum_2016_9);
%inp_rev(source=rif2016.outpatient_revenue_10, include_cohort=pop11_OUTnum_2016_10);
%inp_rev(source=rif2016.outpatient_revenue_11, include_cohort=pop11_OUTnum_2016_11);
%inp_rev(source=rif2016.outpatient_revenue_12, include_cohort=pop11_OUTnum_2016_12);
%inp_rev(source=rif2016.bcarrier_line_01, include_cohort=pop11_CARnum_2016_1);
%inp_rev(source=rif2016.bcarrier_line_02, include_cohort=pop11_CARnum_2016_2);
%inp_rev(source=rif2016.bcarrier_line_03, include_cohort=pop11_CARnum_2016_3);
%inp_rev(source=rif2016.bcarrier_line_04, include_cohort=pop11_CARnum_2016_4);
%inp_rev(source=rif2016.bcarrier_line_05, include_cohort=pop11_CARnum_2016_5);
%inp_rev(source=rif2016.bcarrier_line_06, include_cohort=pop11_CARnum_2016_6);
%inp_rev(source=rif2016.bcarrier_line_07, include_cohort=pop11_CARnum_2016_7);
%inp_rev(source=rif2016.bcarrier_line_08, include_cohort=pop11_CARnum_2016_8);
%inp_rev(source=rif2016.bcarrier_line_09, include_cohort=pop11_CARnum_2016_9);
%inp_rev(source=rif2016.bcarrier_line_10, include_cohort=pop11_CARnum_2016_10);
%inp_rev(source=rif2016.bcarrier_line_11, include_cohort=pop11_CARnum_2016_11);
%inp_rev(source=rif2016.bcarrier_line_12, include_cohort=pop11_CARnum_2016_12);

%inp_rev(source=rif2017.inpatient_revenue_01, include_cohort=pop11_INnum_2017_1);
%inp_rev(source=rif2017.inpatient_revenue_02, include_cohort=pop11_INnum_2017_2);
%inp_rev(source=rif2017.inpatient_revenue_03, include_cohort=pop11_INnum_2017_3);
%inp_rev(source=rif2017.inpatient_revenue_04, include_cohort=pop11_INnum_2017_4);
%inp_rev(source=rif2017.inpatient_revenue_05, include_cohort=pop11_INnum_2017_5);
%inp_rev(source=rif2017.inpatient_revenue_06, include_cohort=pop11_INnum_2017_6);
%inp_rev(source=rif2017.inpatient_revenue_07, include_cohort=pop11_INnum_2017_7);
%inp_rev(source=rif2017.inpatient_revenue_08, include_cohort=pop11_INnum_2017_8);
%inp_rev(source=rif2017.inpatient_revenue_09, include_cohort=pop11_INnum_2017_9);
%inp_rev(source=rif2017.inpatient_revenue_10, include_cohort=pop11_INnum_2017_10);
%inp_rev(source=rif2017.inpatient_revenue_11, include_cohort=pop11_INnum_2017_11);
%inp_rev(source=rif2017.inpatient_revenue_12, include_cohort=pop11_INnum_2017_12);
%inp_rev(source=rif2017.outpatient_revenue_01, include_cohort=pop11_OUTnum_2017_1);
%inp_rev(source=rif2017.outpatient_revenue_02, include_cohort=pop11_OUTnum_2017_2);
%inp_rev(source=rif2017.outpatient_revenue_03, include_cohort=pop11_OUTnum_2017_3);
%inp_rev(source=rif2017.outpatient_revenue_04, include_cohort=pop11_OUTnum_2017_4);
%inp_rev(source=rif2017.outpatient_revenue_05, include_cohort=pop11_OUTnum_2017_5);
%inp_rev(source=rif2017.outpatient_revenue_06, include_cohort=pop11_OUTnum_2017_6);
%inp_rev(source=rif2017.outpatient_revenue_07, include_cohort=pop11_OUTnum_2017_7);
%inp_rev(source=rif2017.outpatient_revenue_08, include_cohort=pop11_OUTnum_2017_8);
%inp_rev(source=rif2017.outpatient_revenue_09, include_cohort=pop11_OUTnum_2017_9);
%inp_rev(source=rif2017.outpatient_revenue_10, include_cohort=pop11_OUTnum_2017_10);
%inp_rev(source=rif2017.outpatient_revenue_11, include_cohort=pop11_OUTnum_2017_11);
%inp_rev(source=rif2017.outpatient_revenue_12, include_cohort=pop11_OUTnum_2017_12);
%inp_rev(source=rif2017.bcarrier_line_01, include_cohort=pop11_CARnum_2017_1);
%inp_rev(source=rif2017.bcarrier_line_02, include_cohort=pop11_CARnum_2017_2);
%inp_rev(source=rif2017.bcarrier_line_03, include_cohort=pop11_CARnum_2017_3);
%inp_rev(source=rif2017.bcarrier_line_04, include_cohort=pop11_CARnum_2017_4);
%inp_rev(source=rif2017.bcarrier_line_05, include_cohort=pop11_CARnum_2017_5);
%inp_rev(source=rif2017.bcarrier_line_06, include_cohort=pop11_CARnum_2017_6);
%inp_rev(source=rif2017.bcarrier_line_07, include_cohort=pop11_CARnum_2017_7);
%inp_rev(source=rif2017.bcarrier_line_08, include_cohort=pop11_CARnum_2017_8);
%inp_rev(source=rif2017.bcarrier_line_09, include_cohort=pop11_CARnum_2017_9);
%inp_rev(source=rif2017.bcarrier_line_10, include_cohort=pop11_CARnum_2017_10);
%inp_rev(source=rif2017.bcarrier_line_11, include_cohort=pop11_CARnum_2017_11);
%inp_rev(source=rif2017.bcarrier_line_12, include_cohort=pop11_CARnum_2017_12);

%inp_rev(source=rifq2018.inpatient_revenue_01, include_cohort=pop11_INnum_2018_1);
%inp_rev(source=rifq2018.inpatient_revenue_02, include_cohort=pop11_INnum_2018_2);
%inp_rev(source=rifq2018.inpatient_revenue_03, include_cohort=pop11_INnum_2018_3);
%inp_rev(source=rifq2018.inpatient_revenue_04, include_cohort=pop11_INnum_2018_4);
%inp_rev(source=rifq2018.inpatient_revenue_05, include_cohort=pop11_INnum_2018_5);
%inp_rev(source=rifq2018.inpatient_revenue_06, include_cohort=pop11_INnum_2018_6);
%inp_rev(source=rifq2018.inpatient_revenue_07, include_cohort=pop11_INnum_2018_7);
%inp_rev(source=rifq2018.inpatient_revenue_08, include_cohort=pop11_INnum_2018_8);
%inp_rev(source=rifq2018.inpatient_revenue_09, include_cohort=pop11_INnum_2018_9);
%inp_rev(source=rifq2018.inpatient_revenue_10, include_cohort=pop11_INnum_2018_10);
%inp_rev(source=rifq2018.inpatient_revenue_11, include_cohort=pop11_INnum_2018_11);
%inp_rev(source=rifq2018.inpatient_revenue_12, include_cohort=pop11_INnum_2018_12);
%inp_rev(source=rifq2018.outpatient_revenue_01, include_cohort=pop11_OUTnum_2018_1);
%inp_rev(source=rifq2018.outpatient_revenue_02, include_cohort=pop11_OUTnum_2018_2);
%inp_rev(source=rifq2018.outpatient_revenue_03, include_cohort=pop11_OUTnum_2018_3);
%inp_rev(source=rifq2018.outpatient_revenue_04, include_cohort=pop11_OUTnum_2018_4);
%inp_rev(source=rifq2018.outpatient_revenue_05, include_cohort=pop11_OUTnum_2018_5);
%inp_rev(source=rifq2018.outpatient_revenue_06, include_cohort=pop11_OUTnum_2018_6);
%inp_rev(source=rifq2018.outpatient_revenue_07, include_cohort=pop11_OUTnum_2018_7);
%inp_rev(source=rifq2018.outpatient_revenue_08, include_cohort=pop11_OUTnum_2018_8);
%inp_rev(source=rifq2018.outpatient_revenue_09, include_cohort=pop11_OUTnum_2018_9);
%inp_rev(source=rifq2018.outpatient_revenue_10, include_cohort=pop11_OUTnum_2018_10);
%inp_rev(source=rifq2018.outpatient_revenue_11, include_cohort=pop11_OUTnum_2018_11);
%inp_rev(source=rifq2018.outpatient_revenue_12, include_cohort=pop11_OUTnum_2018_12);
%inp_rev(source=rifq2018.bcarrier_line_01, include_cohort=pop11_CARnum_2018_1);
%inp_rev(source=rifq2018.bcarrier_line_02, include_cohort=pop11_CARnum_2018_2);
%inp_rev(source=rifq2018.bcarrier_line_03, include_cohort=pop11_CARnum_2018_3);
%inp_rev(source=rifq2018.bcarrier_line_04, include_cohort=pop11_CARnum_2018_4);
%inp_rev(source=rifq2018.bcarrier_line_05, include_cohort=pop11_CARnum_2018_5);
%inp_rev(source=rifq2018.bcarrier_line_06, include_cohort=pop11_CARnum_2018_6);
%inp_rev(source=rifq2018.bcarrier_line_07, include_cohort=pop11_CARnum_2018_7);
%inp_rev(source=rifq2018.bcarrier_line_08, include_cohort=pop11_CARnum_2018_8);
%inp_rev(source=rifq2018.bcarrier_line_09, include_cohort=pop11_CARnum_2018_9);
%inp_rev(source=rifq2018.bcarrier_line_10, include_cohort=pop11_CARnum_2018_10);
%inp_rev(source=rifq2018.bcarrier_line_11, include_cohort=pop11_CARnum_2018_11);
%inp_rev(source=rifq2018.bcarrier_line_12, include_cohort=pop11_CARnum_2018_12);
*/
data pop_11_num;
set pop11_INnum_2010_1 pop11_INnum_2010_2 pop11_INnum_2010_3 pop11_INnum_2010_4 pop11_INnum_2010_5 pop11_INnum_2010_6 pop11_INnum_2010_7
pop11_INnum_2010_8 pop11_INnum_2010_9 pop11_INnum_2010_10 pop11_INnum_2010_11 pop11_INnum_2010_12
pop11_OUTnum_2010_1 pop11_OUTnum_2010_2 pop11_OUTnum_2010_3 pop11_OUTnum_2010_4 pop11_OUTnum_2010_5 pop11_OUTnum_2010_6 pop11_OUTnum_2010_7
pop11_OUTnum_2010_8 pop11_OUTnum_2010_9 pop11_OUTnum_2010_10 pop11_OUTnum_2010_11 pop11_OUTnum_2010_12
pop11_CARnum_2010_1 pop11_CARnum_2010_2 pop11_CARnum_2010_3 pop11_CARnum_2010_4 pop11_CARnum_2010_5 pop11_CARnum_2010_6 pop11_CARnum_2010_7
pop11_CARnum_2010_8 pop11_CARnum_2010_9 pop11_CARnum_2010_10 pop11_CARnum_2010_11 pop11_CARnum_2010_12
/*
pop11_INnum_2011_1 pop11_INnum_2011_2 pop11_INnum_2011_3 pop11_INnum_2011_4 pop11_INnum_2011_5 pop11_INnum_2011_6 pop11_INnum_2011_7
pop11_INnum_2011_8 pop11_INnum_2011_9 pop11_INnum_2011_10 pop11_INnum_2011_11 pop11_INnum_2011_12
pop11_OUTnum_2011_1 pop11_OUTnum_2011_2 pop11_OUTnum_2011_3 pop11_OUTnum_2011_4 pop11_OUTnum_2011_5 pop11_OUTnum_2011_6 pop11_OUTnum_2011_7
pop11_OUTnum_2011_8 pop11_OUTnum_2011_9 pop11_OUTnum_2011_10 pop11_OUTnum_2011_11 pop11_OUTnum_2011_12
pop11_CARnum_2011_1 pop11_CARnum_2011_2 pop11_CARnum_2011_3 pop11_CARnum_2011_4 pop11_CARnum_2011_5 pop11_CARnum_2011_6 pop11_CARnum_2011_7
pop11_CARnum_2011_8 pop11_CARnum_2011_9 pop11_CARnum_2011_10 pop11_CARnum_2011_11 pop11_CARnum_2011_12

pop11_INnum_2012_1 pop11_INnum_2012_2 pop11_INnum_2012_3 pop11_INnum_2012_4 pop11_INnum_2012_5 pop11_INnum_2012_6 pop11_INnum_2012_7
pop11_INnum_2012_8 pop11_INnum_2012_9 pop11_INnum_2012_10 pop11_INnum_2012_11 pop11_INnum_2012_12
pop11_OUTnum_2012_1 pop11_OUTnum_2012_2 pop11_OUTnum_2012_3 pop11_OUTnum_2012_4 pop11_OUTnum_2012_5 pop11_OUTnum_2012_6 pop11_OUTnum_2012_7
pop11_OUTnum_2012_8 pop11_OUTnum_2012_9 pop11_OUTnum_2012_10 pop11_OUTnum_2012_11 pop11_OUTnum_2012_12
pop11_CARnum_2012_1 pop11_CARnum_2012_2 pop11_CARnum_2012_3 pop11_CARnum_2012_4 pop11_CARnum_2012_5 pop11_CARnum_2012_6 pop11_CARnum_2012_7
pop11_CARnum_2012_8 pop11_CARnum_2012_9 pop11_CARnum_2012_10 pop11_CARnum_2012_11 pop11_CARnum_2012_12

pop11_INnum_2013_1 pop11_INnum_2013_2 pop11_INnum_2013_3 pop11_INnum_2013_4 pop11_INnum_2013_5 pop11_INnum_2013_6 pop11_INnum_2013_7
pop11_INnum_2013_8 pop11_INnum_2013_9 pop11_INnum_2013_10 pop11_INnum_2013_11 pop11_INnum_2013_12
pop11_OUTnum_2013_1 pop11_OUTnum_2013_2 pop11_OUTnum_2013_3 pop11_OUTnum_2013_4 pop11_OUTnum_2013_5 pop11_OUTnum_2013_6 pop11_OUTnum_2013_7
pop11_OUTnum_2013_8 pop11_OUTnum_2013_9 pop11_OUTnum_2013_10 pop11_OUTnum_2013_11 pop11_OUTnum_2013_12
pop11_CARnum_2013_1 pop11_CARnum_2013_2 pop11_CARnum_2013_3 pop11_CARnum_2013_4 pop11_CARnum_2013_5 pop11_CARnum_2013_6 pop11_CARnum_2013_7
pop11_CARnum_2013_8 pop11_CARnum_2013_9 pop11_CARnum_2013_10 pop11_CARnum_2013_11 pop11_CARnum_2013_12

pop11_INnum_2014_1 pop11_INnum_2014_2 pop11_INnum_2014_3 pop11_INnum_2014_4 pop11_INnum_2014_5 pop11_INnum_2014_6 pop11_INnum_2014_7
pop11_INnum_2014_8 pop11_INnum_2014_9 pop11_INnum_2014_10 pop11_INnum_2014_11 pop11_INnum_2014_12
pop11_OUTnum_2014_1 pop11_OUTnum_2014_2 pop11_OUTnum_2014_3 pop11_OUTnum_2014_4 pop11_OUTnum_2014_5 pop11_OUTnum_2014_6 pop11_OUTnum_2014_7
pop11_OUTnum_2014_8 pop11_OUTnum_2014_9 pop11_OUTnum_2014_10 pop11_OUTnum_2014_11 pop11_OUTnum_2014_12
pop11_CARnum_2014_1 pop11_CARnum_2014_2 pop11_CARnum_2014_3 pop11_CARnum_2014_4 pop11_CARnum_2014_5 pop11_CARnum_2014_6 pop11_CARnum_2014_7
pop11_CARnum_2014_8 pop11_CARnum_2014_9 pop11_CARnum_2014_10 pop11_CARnum_2014_11 pop11_CARnum_2014_12

pop11_INnum_2015_1 pop11_INnum_2015_2 pop11_INnum_2015_3 pop11_INnum_2015_4 pop11_INnum_2015_5 pop11_INnum_2015_6 pop11_INnum_2015_7
pop11_INnum_2015_8 pop11_INnum_2015_9 pop11_INnum_2015_10 pop11_INnum_2015_11 pop11_INnum_2015_12
pop11_OUTnum_2015_1 pop11_OUTnum_2015_2 pop11_OUTnum_2015_3 pop11_OUTnum_2015_4 pop11_OUTnum_2015_5 pop11_OUTnum_2015_6 pop11_OUTnum_2015_7
pop11_OUTnum_2015_8 pop11_OUTnum_2015_9 pop11_OUTnum_2015_10 pop11_OUTnum_2015_11 pop11_OUTnum_2015_12
pop11_CARnum_2015_1 pop11_CARnum_2015_2 pop11_CARnum_2015_3 pop11_CARnum_2015_4 pop11_CARnum_2015_5 pop11_CARnum_2015_6 pop11_CARnum_2015_7
pop11_CARnum_2015_8 pop11_CARnum_2015_9 pop11_CARnum_2015_10 pop11_CARnum_2015_11 pop11_CARnum_2015_12

pop11_INnum_2016_1 pop11_INnum_2016_2 pop11_INnum_2016_3 pop11_INnum_2016_4 pop11_INnum_2016_5 pop11_INnum_2016_6 pop11_INnum_2016_7
pop11_INnum_2016_8 pop11_INnum_2016_9 pop11_INnum_2016_10 pop11_INnum_2016_11 pop11_INnum_2016_12
pop11_OUTnum_2016_1 pop11_OUTnum_2016_2 pop11_OUTnum_2016_3 pop11_OUTnum_2016_4 pop11_OUTnum_2016_5 pop11_OUTnum_2016_6 pop11_OUTnum_2016_7
pop11_OUTnum_2016_8 pop11_OUTnum_2016_9 pop11_OUTnum_2016_10 pop11_OUTnum_2016_11 pop11_OUTnum_2016_12
pop11_CARnum_2016_1 pop11_CARnum_2016_2 pop11_CARnum_2016_3 pop11_CARnum_2016_4 pop11_CARnum_2016_5 pop11_CARnum_2016_6 pop11_CARnum_2016_7
pop11_CARnum_2016_8 pop11_CARnum_2016_9 pop11_CARnum_2016_10 pop11_CARnum_2016_11 pop11_CARnum_2016_12

pop11_INnum_2017_1 pop11_INnum_2017_2 pop11_INnum_2017_3 pop11_INnum_2017_4 pop11_INnum_2017_5 pop11_INnum_2017_6 pop11_INnum_2017_7
pop11_INnum_2017_8 pop11_INnum_2017_9 pop11_INnum_2017_10 pop11_INnum_2017_11 pop11_INnum_2017_12
pop11_OUTnum_2017_1 pop11_OUTnum_2017_2 pop11_OUTnum_2017_3 pop11_OUTnum_2017_4 pop11_OUTnum_2017_5 pop11_OUTnum_2017_6 pop11_OUTnum_2017_7
pop11_OUTnum_2017_8 pop11_OUTnum_2017_9 pop11_OUTnum_2017_10 pop11_OUTnum_2017_11 pop11_OUTnum_2017_12
pop11_CARnum_2017_1 pop11_CARnum_2017_2 pop11_CARnum_2017_3 pop11_CARnum_2017_4 pop11_CARnum_2017_5 pop11_CARnum_2017_6 pop11_CARnum_2017_7
pop11_CARnum_2017_8 pop11_CARnum_2017_9 pop11_CARnum_2017_10 pop11_CARnum_2017_11 pop11_CARnum_2017_12

pop11_INnum_2018_1 pop11_INnum_2018_2 pop11_INnum_2018_3 pop11_INnum_2018_4 pop11_INnum_2018_5 pop11_INnum_2018_6 pop11_INnum_2018_7
pop11_INnum_2018_8 pop11_INnum_2018_9 pop11_INnum_2018_10 pop11_INnum_2018_11 pop11_INnum_2018_12
pop11_OUTnum_2018_1 pop11_OUTnum_2018_2 pop11_OUTnum_2018_3 pop11_OUTnum_2018_4 pop11_OUTnum_2018_5 pop11_OUTnum_2018_6 pop11_OUTnum_2018_7
pop11_OUTnum_2018_8 pop11_OUTnum_2018_9 pop11_OUTnum_2018_10 pop11_OUTnum_2018_11 pop11_OUTnum_2018_12
pop11_CARnum_2018_1 pop11_CARnum_2018_2 pop11_CARnum_2018_3 pop11_CARnum_2018_4 pop11_CARnum_2018_5 pop11_CARnum_2018_6 pop11_CARnum_2018_7
pop11_CARnum_2018_8 pop11_CARnum_2018_9 pop11_CARnum_2018_10 pop11_CARnum_2018_11 pop11_CARnum_2018_12*/
;
run;
proc sort data=pop_11_num NODUPKEY;by bene_id popped_11_dt;run;*62,100 for 2010;

*bring in denominator of all women based on MBSF file--ideally would count months until death and not require entire year;
data pop_11_denom;
set mbsf.mbsf_abcd_2010;
where sex_ident_cd='2' and BENE_HI_CVRAGE_TOT_MONS=12 and BENE_SMI_CVRAGE_TOT_MONS=12
and BENE_HMO_CVRAGE_TOT_MONS=0;*female and enrolled in parts A and B all 12 months and MA for 0 months of 2010;
run;*23,236,037;

*bring in chronic conditions---associated with denominator first then match to the num-denom file;
%macro line(abcd=, include_cohort=);
proc sql;
create table &include_cohort (compress=yes) as
select  
a.bene_id, b.*
from 
pop_11_denom a,
&abcd b
where a.bene_id=b.bene_id and b.CANCER_ENDOMETRIAL in(2,3);*had sufficient ffs coverage for endometrial cancer indicator;
quit;
%mend;
%line(abcd=mbsf.mbsf_cc_2010, include_cohort=cc_2010); *16,652,315 were female and had sufficient info to make endometrial cancer determination;


*start;
*identify those with female genital cancer from dx codes for exclusion;
*exclusion for inpatient;
%macro inp_claims(source=, include_cohort=);
data &include_cohort
(keep =  bene_id clm_id pop_11_exclude pop_11_exclude_dt);
set &source;
*DX code qualifying;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
do j=1 to 25;
	if substr(dx(j),1,3) in(&pop11_icd_EX_dx9_3) then do; pop11=1; end;
	if dx(j) in(&pop11_icd_EX_dx9) then do; pop11=1; end;
end;
if pop11 ne 1 then delete;
pop_11_exclude=1;
pop_11_exclude_dt=clm_admsn_dt;
run;
proc sort data=&include_cohort NODUPKEY;by bene_id pop_11_exclude_dt;run;
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

*exclusion for outpatient and carrier;
%macro out_claims(source=, include_cohort=);
data &include_cohort
(keep =  bene_id clm_id pop_11_exclude pop_11_exclude_dt);
set &source;
*no location restriction;
*DX code qualifying;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
do j=1 to 25;
	if substr(dx(j),1,3) in(&pop11_icd_EX_dx9_3) then do; pop11=1; end;
	if dx(j) in(&pop11_icd_EX_dx9) then do; pop11=1; end;
end;
if pop11 ne 1 then delete;
pop_11_exclude=1;
pop_11_exclude_dt=clm_from_dt;*note difference in date between inpatient and outpatient;
run;
proc sort data=&include_cohort NODUPKEY;by bene_id pop_11_exclude_dt;run;
%mend;
%out_claims(source=rif2010.outpatient_claims_01, include_cohort=pop_11_OUTexclude_2010_1);
%out_claims(source=rif2010.outpatient_claims_02, include_cohort=pop_11_OUTexclude_2010_2);
%out_claims(source=rif2010.outpatient_claims_03, include_cohort=pop_11_OUTexclude_2010_3);
%out_claims(source=rif2010.outpatient_claims_04, include_cohort=pop_11_OUTexclude_2010_4);
%out_claims(source=rif2010.outpatient_claims_05, include_cohort=pop_11_OUTexclude_2010_5);
%out_claims(source=rif2010.outpatient_claims_06, include_cohort=pop_11_OUTexclude_2010_6);
%out_claims(source=rif2010.outpatient_claims_07, include_cohort=pop_11_OUTexclude_2010_7);
%out_claims(source=rif2010.outpatient_claims_08, include_cohort=pop_11_OUTexclude_2010_8);
%out_claims(source=rif2010.outpatient_claims_09, include_cohort=pop_11_OUTexclude_2010_9);
%out_claims(source=rif2010.outpatient_claims_10, include_cohort=pop_11_OUTexclude_2010_10);
%out_claims(source=rif2010.outpatient_claims_11, include_cohort=pop_11_OUTexclude_2010_11);
%out_claims(source=rif2010.outpatient_claims_12, include_cohort=pop_11_OUTexclude_2010_12);

%out_claims(source=rif2010.bcarrier_claims_01, include_cohort=pop_11_CARexclude_2010_1);
%out_claims(source=rif2010.bcarrier_claims_02, include_cohort=pop_11_CARexclude_2010_2);
%out_claims(source=rif2010.bcarrier_claims_03, include_cohort=pop_11_CARexclude_2010_3);
%out_claims(source=rif2010.bcarrier_claims_04, include_cohort=pop_11_CARexclude_2010_4);
%out_claims(source=rif2010.bcarrier_claims_05, include_cohort=pop_11_CARexclude_2010_5);
%out_claims(source=rif2010.bcarrier_claims_06, include_cohort=pop_11_CARexclude_2010_6);
%out_claims(source=rif2010.bcarrier_claims_07, include_cohort=pop_11_CARexclude_2010_7);
%out_claims(source=rif2010.bcarrier_claims_08, include_cohort=pop_11_CARexclude_2010_8);
%out_claims(source=rif2010.bcarrier_claims_09, include_cohort=pop_11_CARexclude_2010_9);
%out_claims(source=rif2010.bcarrier_claims_10, include_cohort=pop_11_CARexclude_2010_10);
%out_claims(source=rif2010.bcarrier_claims_11, include_cohort=pop_11_CARexclude_2010_11);
%out_claims(source=rif2010.bcarrier_claims_12, include_cohort=pop_11_CARexclude_2010_12);
*did not go to line item files for line icd exclusion;

data pop_11_exclude;
set pop11_INexclude_2010_1 pop11_INexclude_2010_2 pop11_INexclude_2010_3 pop11_INexclude_2010_4 pop11_INexclude_2010_5 pop11_INexclude_2010_6 pop11_INexclude_2010_7
pop11_INexclude_2010_8 pop11_INexclude_2010_9 pop11_INexclude_2010_10 pop11_INexclude_2010_11 pop11_INexclude_2010_12
pop11_OUTexclude_2010_1 pop11_OUTexclude_2010_2 pop11_OUTexclude_2010_3 pop11_OUTexclude_2010_4 pop11_OUTexclude_2010_5 pop11_OUTexclude_2010_6 pop11_OUTexclude_2010_7
pop11_OUTexclude_2010_8 pop11_OUTexclude_2010_9 pop11_OUTexclude_2010_10 pop11_OUTexclude_2010_11 pop11_OUTexclude_2010_12
pop11_CARexclude_2010_1 pop11_CARexclude_2010_2 pop11_CARexclude_2010_3 pop11_CARexclude_2010_4 pop11_CARexclude_2010_5 pop11_CARexclude_2010_6 pop11_CARexclude_2010_7
pop11_CARexclude_2010_8 pop11_CARexclude_2010_9 pop11_CARexclude_2010_10 pop11_CARexclude_2010_11 pop11_CARexclude_2010_12;
run;
proc sort data=pop_11_exclude NODUPKEY;by bene_id pop_11_exclude_dt;run;* for 2010;

*if in cc_cohort and in numerator and didn't have endometrial cancer or genital cancer based on icd dx codes before hysterectomy date then include;
proc sort data=cc_2010; by bene_id;
proc sort data=pop_11_exclude NODUPKEY; by bene_id; *only keep first cancer dx for exclusion;
proc sort data=pop_11_num NODUPKEY; by bene_id;*denominator is person level not date so keep only 1 hysterectomy for the year-sorted above so we are keeping 1st hysterectomy only;
		* when de-dupe to 1 hyst per person;
data pop_01_cc; 
merge cc_2010(in=a) pop_11_exclude pop_11_num;
if a;
by bene_id;
if CANCER_ENDOMETRIAL=3 and cancer_endometrial_ever<=popped_11_dt then delete;*if endometrial cancer after hyesterectomy then keep;
if pop_11_exclude_dt<=popped_11_dt then delete;*if female genital cancer after hysterectomy then keep;
if popped_11=. then popped_11=0;
run;*;
proc freq data=pop_01_cc; table popped_11; run;


*all women are eligible regardless of encounter type--it is not possible to attribute women to a health system using this denominator;




