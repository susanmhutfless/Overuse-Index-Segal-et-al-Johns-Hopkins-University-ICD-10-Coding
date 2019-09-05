%let pop11_hcpcs='58150', '58152', '58180', '58200', '58210', '58260', '58262', '58263', '58267', '58270', '58275', '58280', '58285', '58290',
				'58291', '58292', '59293', '59294', '58541', '58542', '58543', '58544', '58548', '58550', '58552', '58553', '58554', '58570',
				'58571', '58572', '58573'; *Hysterectomy;
				*note: did not include 52810--used 58210 instead--assumed 52810 is a typo by previous analysts (21aug2019);*Both H-Y and Alli analyses included the 52810 mistake;
*%let pop11_hcpcs_ed='99281', '99282', '99283', '99284', '99285';*hcpcs indicating emergency room visit;
*%let pop11_rev_ed='0450','0451','0452','0456','0459','0981';*revenue center indicating emergency room visit https://www.resdac.org/cms-data/variables/revenue-center-code-ffs;
%let pop11_icd_pr9='6831', '6839',  '6841', '6849', '6851', '6859', '6861','6869', '6871', '6879','689';*icd=9 for hysterecromy;
%let pop11_icd_pr10='0UT90ZZ','0UT94ZZ','0UT97ZZ','0UT98ZZ','0UT9FZZ','0UTC0ZZ','0UTC4ZZ','0UTC7ZZ','0UTC8ZZ',
				   '0UT40ZZ','0UT44ZZ','0UT47ZZ','0UT48ZZ';*icd-10 for hysterectomy based on cross-walk of the icd-9 codes;

*for exclusion;
%let pop11_icd_EX_dx9_3='179', '180', '182','183', '184';*"malignancy" exlcusion icd-9;
%let pop11_icd_EX_dx10='C510', 'C511', 'C512', 'C519', 'C52', 'C530', 'C531', 'C538', 'C539', 'C540', 'C541', 'C542', 'C543', 'C548', 'C549', 
					  'C55', 'C569', 'C5700', 'C5710', 'C5720', 'C573', 'C574', 'C574', 'C577', 'C578', 'C579'; *"malignancy" exclusion icd-10 based on cross-walk;
%let pop11_EX_drg='734', '735', '736', '737', '738', '739', '740', '741', '754', '755', '756';*having a code for any hysterectomy--unclear why this is exclued--in effect excludes anyone with hysterectomy in a hospital setting;


/*Code from the “instructions” start--MarketScan codes matches exactly--no cross-check made to identify the 52810 error--assume code was not checked by new analyst;
if HCPCS in ("58150" "58152" "58180" "58200" "52810" "58260" "58262" "58263" "58267" "58270" "58275" "58280" "58285" "58290" "58291" "58292" "59293" "59294" "58541" "58542" "58543" "58544" "58548" "58550" "58552" "58553" "58554" "58570" "58571" "58572" "58573") then hysterectomy=1; *pop 11;
if icd3 in ("179" "180" "182" "183" "184") then malignancy=1; *pop 11;
if proc in ("683" "6831" "6839" "684" "6841" "6849" "685" "6851" "6859" "686" "6861" "6869" "687" "6871" "6879" "689") then hysterectomy=1; *pop 11;
if drg in ("734" "735" "736" "737" "738" "739" "740" "741" "754" "755" "756") then malignancy=1; *pop 11;
*marketscan code referencing pop11;
if PROC in ("58150" "58152" "58180" "58200" "52810" "58260" "58262" "58263" "58267" "58270" "58275" "58280" "58285" "58290" "58291" "58292" "59293" "59294" "58541" "58542" "58543" "58544" "58548" "58550" "58552" "58553" "58554" "58570" "58571" "58572" "58573") then hysterectomy=1; *pop 11;
*if proc in ("683" "6831" "6839" "684" "6841" "6849" "685" "6851" "6859" "686" "6861" "6869" "687" "6871" "6879" "689") then hysterectomy=1; *pop 11;
*if icd3 in ("179" "180" "182" "183" "184") then malignancy=1; *pop 11;
*if drg in (734 735 736 737 738 739 740 741 754 755 756) then malignancy=1; *pop 11;

*CODE FROM "INSTRUCTIONS" FROM H-Y AND ALLI START;
***  Pop 11;
* Denominator - all women minus those with a malignancy diagnosis (ICD9 and DRG);
Data icd_malignancy; set icd; where malignancy=1; keep bene_id; run;
Data drg_malignancy; set drg; where malignancy=1; keep bene_id; run;
Data malignancy; set icd_malignancy drg_malignancy; run;
proc sort nodupkey; by bene_id; run;

Data female; set patient; where sex="F"; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

Data pop_11_de; merge female (in=d) malignancy (in=e); by bene_id; if d=1 and e=0; length pop_11_de 3; pop_11_de=1; 
keep bene_id pop_11_de; run; 
proc sort nodupkey; by bene_id; run;

  * Numerator - anyone with hysterectomy (not specified for malignancy);
Data proc_hysterectomy; set proc; where hysterectomy=1; keep bene_id; run;
Data icd_proc_hysterectomy; set icd_proc; where hysterectomy=1; keep bene_id; run;
Data pop_11_nu; set proc_hysterectomy icd_proc_hysterectomy; length pop_11_nu 3; pop_11_nu=1; keep bene_id pop_11_nu; run; 
proc sort nodupkey; by bene_id; run;

* POP 11 merge;
Data pop_11; merge pop_11_de (in=a) pop_11_nu; by bene_id; if a=1; run;
Data pop_11; set pop_11; pop_num="11"; if pop_11_nu=. then pop_11_nu=0; if pop_11_de=. then pop_11_de=0; run;
*Code from the “instructions” stop;*/



*NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO NO;
*Below is the incorrect calculation made by H-Y and Alli perpetuated--only change is the HCPCS fix---
do NOT use results of code below for publication;

*First: Identify HCPCS codes for hysterectomy from inpatient, outpatient, carrier;
*Then identify all women who never had malignant disease;

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
where sex_ident_cd='2' and BENE_HI_CVRAGE_TOT_MONS=12 and BENE_SMI_CVRAGE_TOT_MONS=12;*female and enrolled in parts A and B all 12 months of 2010;
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

*if in cc_cohort and in numerator and didn't have endometrial cancer then include;
proc sort data=cc_2010; by bene_id;
proc sort data=pop_11_num NODUPKEY; by bene_id;*denominator is person level not date so keep only 1 hysterectomy for the year-sorted above so we are keeping 1st hysterectomy only;
		*53,140 when de-dupe to 1 hyst per person;
data pop_01_cc; 
merge cc_2010(in=a) pop_11_num  (in=b);
if a;
by bene_id;
if CANCER_ENDOMETRIAL=3 and cancer_endometrial_ever<=popped_11_dt then delete;*if endometrial cancer after hyesterectomy then keep;
if popped_11=. then popped_11=0;
run;*16,643,098;
proc freq data=pop_01_cc; table popped_11; run;


/*crosswalk for icd procedure downloaded from https://www.nber.org/data/icd9-icd-10-cm-and-pcs-crosswalk-general-equivalence-mapping.html;
libname segal "V:\Segal overuse"; run;
data cross_pcs; set segal.icd9toicd10pcsgem;run;
proc sort data=cross_pcs; by icd10cm;
proc print data=cross_pcs noobs; 
where icd9cm in('6831', '6839',  '6841', '6849', '6851', '6859', '6861','6869', '6871', '6879')
or substr(icd9cm,1,3) in('683', '684', '685', '686', '687', '689');
var icd10cm;
run;
*crosswalk for icd diagnosis
data cross (keep = icd icd10cm); 
data cross_dx; set segal.icd9toicd10cmgem; run;
proc sort data=cross_dx; by icd10cm;
proc print data=cross_dx noobs;
where substr(icd9cm,1,3) in('179', '180', '182','183', '184');
var icd10cm;
run;*/

*denominator for inpatient;
%macro inp_claims(source=, include_cohort=);
data &include_cohort
(keep =  pop_02_elig pop_02_age pop_02_year pop_02_setting
		bene_id clm_id clm_admsn_dt clm_thru_dt gndr_cd bene_race_cd bene_cnty_cd bene_state_cd bene_mlg_cntct_zip_cd  
		prvdr_num prvdr_state_cd clm_fac_type_cd clm_ip_admsn_type_cd 
		at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi);
length pop_02_elig 3;
set &source;
where clm_fac_type_cd in('1');*1=hospital https://www.resdac.org/cms-data/variables/claim-facility-type-code-ffs;
*DRG code EXCLUSION;
if clm_drg_cd in(&pop2_EX_drg) then pop2=0;
*DX code EXCLUSION;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
do j=1 to 25;
	if substr(dx(j),1,3) in(&pop2_icd_EX_dx9_3) then do; pop2=0; end;
end;
*PR code INCLUSION;
array pr(25) icd_prcdr_cd1 - icd_prcdr_cd25;
do k=1 to 25;
	if pr(k) in(&pop2_icd_pr9) then do; pop2=1; end;
end;
if pop2 ne 1 then delete;
pop_02_elig=1;
pop_02_age=(clm_admsn_dt-dob_dt)/365.25;
pop_02_age=round(pop_02_age);
pop_02_year=year(clm_admsn_dt);
pop_02_setting='inp';
run;
proc sort data=&include_cohort NODUPKEY;by bene_id clm_admsn_dt;run;
%mend;
%inp_claims(source=rif2010.inpatient_claims_01, include_cohort=pop_02_INdenom_2010_1);
%inp_claims(source=rif2010.inpatient_claims_02, include_cohort=pop_02_INdenom_2010_2);
%inp_claims(source=rif2010.inpatient_claims_03, include_cohort=pop_02_INdenom_2010_3);
%inp_claims(source=rif2010.inpatient_claims_04, include_cohort=pop_02_INdenom_2010_4);
%inp_claims(source=rif2010.inpatient_claims_05, include_cohort=pop_02_INdenom_2010_5);
%inp_claims(source=rif2010.inpatient_claims_06, include_cohort=pop_02_INdenom_2010_6);
%inp_claims(source=rif2010.inpatient_claims_07, include_cohort=pop_02_INdenom_2010_7);
%inp_claims(source=rif2010.inpatient_claims_08, include_cohort=pop_02_INdenom_2010_8);
%inp_claims(source=rif2010.inpatient_claims_09, include_cohort=pop_02_INdenom_2010_9);
%inp_claims(source=rif2010.inpatient_claims_10, include_cohort=pop_02_INdenom_2010_10);
%inp_claims(source=rif2010.inpatient_claims_11, include_cohort=pop_02_INdenom_2010_11);
%inp_claims(source=rif2010.inpatient_claims_12, include_cohort=pop_02_INdenom_2010_12);
%inp_claims(source=rif2011.inpatient_claims_01, include_cohort=pop_02_INdenom_2011_1);
%inp_claims(source=rif2011.inpatient_claims_02, include_cohort=pop_02_INdenom_2011_2);
%inp_claims(source=rif2011.inpatient_claims_03, include_cohort=pop_02_INdenom_2011_3);
%inp_claims(source=rif2011.inpatient_claims_04, include_cohort=pop_02_INdenom_2011_4);
%inp_claims(source=rif2011.inpatient_claims_05, include_cohort=pop_02_INdenom_2011_5);
%inp_claims(source=rif2011.inpatient_claims_06, include_cohort=pop_02_INdenom_2011_6);
%inp_claims(source=rif2011.inpatient_claims_07, include_cohort=pop_02_INdenom_2011_7);
%inp_claims(source=rif2011.inpatient_claims_08, include_cohort=pop_02_INdenom_2011_8);
%inp_claims(source=rif2011.inpatient_claims_09, include_cohort=pop_02_INdenom_2011_9);
%inp_claims(source=rif2011.inpatient_claims_10, include_cohort=pop_02_INdenom_2011_10);
%inp_claims(source=rif2011.inpatient_claims_11, include_cohort=pop_02_INdenom_2011_11);
%inp_claims(source=rif2011.inpatient_claims_12, include_cohort=pop_02_INdenom_2011_12);

%inp_claims(source=rif2012.inpatient_claims_01, include_cohort=pop_02_INdenom_2012_1);
%inp_claims(source=rif2012.inpatient_claims_02, include_cohort=pop_02_INdenom_2012_2);
%inp_claims(source=rif2012.inpatient_claims_03, include_cohort=pop_02_INdenom_2012_3);
%inp_claims(source=rif2012.inpatient_claims_04, include_cohort=pop_02_INdenom_2012_4);
%inp_claims(source=rif2012.inpatient_claims_05, include_cohort=pop_02_INdenom_2012_5);
%inp_claims(source=rif2012.inpatient_claims_06, include_cohort=pop_02_INdenom_2012_6);
%inp_claims(source=rif2012.inpatient_claims_07, include_cohort=pop_02_INdenom_2012_7);
%inp_claims(source=rif2012.inpatient_claims_08, include_cohort=pop_02_INdenom_2012_8);
%inp_claims(source=rif2012.inpatient_claims_09, include_cohort=pop_02_INdenom_2012_9);
%inp_claims(source=rif2012.inpatient_claims_10, include_cohort=pop_02_INdenom_2012_10);
%inp_claims(source=rif2012.inpatient_claims_11, include_cohort=pop_02_INdenom_2012_11);
%inp_claims(source=rif2012.inpatient_claims_12, include_cohort=pop_02_INdenom_2012_12);

%inp_claims(source=rif2013.inpatient_claims_01, include_cohort=pop_02_INdenom_2013_1);
%inp_claims(source=rif2013.inpatient_claims_02, include_cohort=pop_02_INdenom_2013_2);
%inp_claims(source=rif2013.inpatient_claims_03, include_cohort=pop_02_INdenom_2013_3);
%inp_claims(source=rif2013.inpatient_claims_04, include_cohort=pop_02_INdenom_2013_4);
%inp_claims(source=rif2013.inpatient_claims_05, include_cohort=pop_02_INdenom_2013_5);
%inp_claims(source=rif2013.inpatient_claims_06, include_cohort=pop_02_INdenom_2013_6);
%inp_claims(source=rif2013.inpatient_claims_07, include_cohort=pop_02_INdenom_2013_7);
%inp_claims(source=rif2013.inpatient_claims_08, include_cohort=pop_02_INdenom_2013_8);
%inp_claims(source=rif2013.inpatient_claims_09, include_cohort=pop_02_INdenom_2013_9);
%inp_claims(source=rif2013.inpatient_claims_10, include_cohort=pop_02_INdenom_2013_10);
%inp_claims(source=rif2013.inpatient_claims_11, include_cohort=pop_02_INdenom_2013_11);
%inp_claims(source=rif2013.inpatient_claims_12, include_cohort=pop_02_INdenom_2013_12);

%inp_claims(source=rif2014.inpatient_claims_01, include_cohort=pop_02_INdenom_2014_1);
%inp_claims(source=rif2014.inpatient_claims_02, include_cohort=pop_02_INdenom_2014_2);
%inp_claims(source=rif2014.inpatient_claims_03, include_cohort=pop_02_INdenom_2014_3);
%inp_claims(source=rif2014.inpatient_claims_04, include_cohort=pop_02_INdenom_2014_4);
%inp_claims(source=rif2014.inpatient_claims_05, include_cohort=pop_02_INdenom_2014_5);
%inp_claims(source=rif2014.inpatient_claims_06, include_cohort=pop_02_INdenom_2014_6);
%inp_claims(source=rif2014.inpatient_claims_07, include_cohort=pop_02_INdenom_2014_7);
%inp_claims(source=rif2014.inpatient_claims_08, include_cohort=pop_02_INdenom_2014_8);
%inp_claims(source=rif2014.inpatient_claims_09, include_cohort=pop_02_INdenom_2014_9);
%inp_claims(source=rif2014.inpatient_claims_10, include_cohort=pop_02_INdenom_2014_10);
%inp_claims(source=rif2014.inpatient_claims_11, include_cohort=pop_02_INdenom_2014_11);
%inp_claims(source=rif2014.inpatient_claims_12, include_cohort=pop_02_INdenom_2014_12);

%inp_claims(source=rif2015.inpatient_claims_01, include_cohort=pop_02_INdenom_2015_1);
%inp_claims(source=rif2015.inpatient_claims_02, include_cohort=pop_02_INdenom_2015_2);
%inp_claims(source=rif2015.inpatient_claims_03, include_cohort=pop_02_INdenom_2015_3);
%inp_claims(source=rif2015.inpatient_claims_04, include_cohort=pop_02_INdenom_2015_4);
%inp_claims(source=rif2015.inpatient_claims_05, include_cohort=pop_02_INdenom_2015_5);
%inp_claims(source=rif2015.inpatient_claims_06, include_cohort=pop_02_INdenom_2015_6);
%inp_claims(source=rif2015.inpatient_claims_07, include_cohort=pop_02_INdenom_2015_7);
%inp_claims(source=rif2015.inpatient_claims_08, include_cohort=pop_02_INdenom_2015_8);
%inp_claims(source=rif2015.inpatient_claims_09, include_cohort=pop_02_INdenom_2015_9);
%inp_claims(source=rif2015.inpatient_claims_10, include_cohort=pop_02_INdenom_2015_10);
%inp_claims(source=rif2015.inpatient_claims_11, include_cohort=pop_02_INdenom_2015_11);
%inp_claims(source=rif2015.inpatient_claims_12, include_cohort=pop_02_INdenom_2015_12);

%inp_claims(source=rif2016.inpatient_claims_01, include_cohort=pop_02_INdenom_2016_1);
%inp_claims(source=rif2016.inpatient_claims_02, include_cohort=pop_02_INdenom_2016_2);
%inp_claims(source=rif2016.inpatient_claims_03, include_cohort=pop_02_INdenom_2016_3);
%inp_claims(source=rif2016.inpatient_claims_04, include_cohort=pop_02_INdenom_2016_4);
%inp_claims(source=rif2016.inpatient_claims_05, include_cohort=pop_02_INdenom_2016_5);
%inp_claims(source=rif2016.inpatient_claims_06, include_cohort=pop_02_INdenom_2016_6);
%inp_claims(source=rif2016.inpatient_claims_07, include_cohort=pop_02_INdenom_2016_7);
%inp_claims(source=rif2016.inpatient_claims_08, include_cohort=pop_02_INdenom_2016_8);
%inp_claims(source=rif2016.inpatient_claims_09, include_cohort=pop_02_INdenom_2016_9);
%inp_claims(source=rif2016.inpatient_claims_10, include_cohort=pop_02_INdenom_2016_10);
%inp_claims(source=rif2016.inpatient_claims_11, include_cohort=pop_02_INdenom_2016_11);
%inp_claims(source=rif2016.inpatient_claims_12, include_cohort=pop_02_INdenom_2016_12);

%inp_claims(source=rif2017.inpatient_claims_01, include_cohort=pop_02_INdenom_2017_1);
%inp_claims(source=rif2017.inpatient_claims_02, include_cohort=pop_02_INdenom_2017_2);
%inp_claims(source=rif2017.inpatient_claims_03, include_cohort=pop_02_INdenom_2017_3);
%inp_claims(source=rif2017.inpatient_claims_04, include_cohort=pop_02_INdenom_2017_4);
%inp_claims(source=rif2017.inpatient_claims_05, include_cohort=pop_02_INdenom_2017_5);
%inp_claims(source=rif2017.inpatient_claims_06, include_cohort=pop_02_INdenom_2017_6);
%inp_claims(source=rif2017.inpatient_claims_07, include_cohort=pop_02_INdenom_2017_7);
%inp_claims(source=rif2017.inpatient_claims_08, include_cohort=pop_02_INdenom_2017_8);
%inp_claims(source=rif2017.inpatient_claims_09, include_cohort=pop_02_INdenom_2017_9);
%inp_claims(source=rif2017.inpatient_claims_10, include_cohort=pop_02_INdenom_2017_10);
%inp_claims(source=rif2017.inpatient_claims_11, include_cohort=pop_02_INdenom_2017_11);
%inp_claims(source=rif2017.inpatient_claims_12, include_cohort=pop_02_INdenom_2017_12);

%inp_claims(source=rifq2018.inpatient_claims_01, include_cohort=pop_02_INdenom_2018_1);
%inp_claims(source=rifq2018.inpatient_claims_02, include_cohort=pop_02_INdenom_2018_2);
%inp_claims(source=rifq2018.inpatient_claims_03, include_cohort=pop_02_INdenom_2018_3);
%inp_claims(source=rifq2018.inpatient_claims_04, include_cohort=pop_02_INdenom_2018_4);
%inp_claims(source=rifq2018.inpatient_claims_05, include_cohort=pop_02_INdenom_2018_5);
%inp_claims(source=rifq2018.inpatient_claims_06, include_cohort=pop_02_INdenom_2018_6);
%inp_claims(source=rifq2018.inpatient_claims_07, include_cohort=pop_02_INdenom_2018_7);
%inp_claims(source=rifq2018.inpatient_claims_08, include_cohort=pop_02_INdenom_2018_8);
%inp_claims(source=rifq2018.inpatient_claims_09, include_cohort=pop_02_INdenom_2018_9);
%inp_claims(source=rifq2018.inpatient_claims_10, include_cohort=pop_02_INdenom_2018_10);
%inp_claims(source=rifq2018.inpatient_claims_11, include_cohort=pop_02_INdenom_2018_11);
%inp_claims(source=rifq2018.inpatient_claims_12, include_cohort=pop_02_INdenom_2018_12);





