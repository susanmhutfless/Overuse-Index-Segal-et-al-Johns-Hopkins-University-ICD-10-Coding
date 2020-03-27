/********************************************************************
* Job Name: jhu_build_Claim_IPOP_ds_project_overuse_merge_model.sas
* Job Desc: Merge all Pop datasets with denom dataset and comorbidities
	for analysis
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************/
/*** start of section - study specific libraries and variables ***/
/*** libname prefix alias assignments ***/
%global lwork ltemp permlib;
%let  lwork              = work              	;
%let  ltemp              = temp              	;
%let  permlib              = shu172sl          	;  /** permanent library location**/

%global bene_id 		clm_id 		
		clm_beg_dt_in	clm_end_dt_in
		clm_beg_dt		clm_end_dt	clm_dob
		gndr_cd									;

%let  bene_id            = bene_id      		;
%let  clm_id             = clm_id            	;
%let  gndr_cd            = gndr_cd              ;

%let  clm_beg_dt_in      = clm_admsn_dt   		;*_in stands for inpatient;
%let  clm_end_dt_in      = NCH_BENE_DSCHRG_DT   ;
%let  clm_from_dt         = clm_from_dt   		;
%let  clm_thru_dt         = clm_thru_dt   		;
%let  clm_dob            = dob_dt       		;
%let  nch_clm_type_cd    = nch_clm_type_cd      ;
%let  CLM_IP_ADMSN_TYPE_CD = CLM_IP_ADMSN_TYPE_CD ;
%let  clm_fac_type_cd    = clm_fac_type_cd      ;
%let  clm_src_ip_admsn_cd = clm_src_ip_admsn_cd ;
%let  ptnt_dschrg_stus_cd = ptnt_dschrg_stus_cd ;

%let  OP_PHYSN_SPCLTY_CD = OP_PHYSN_SPCLTY_CD   ;
/*** end of section   - study specific variables ***/

/** locations where code stored on machine for project **/
%let vpath     = /sas/vrdc/users/shu172/files   ;
%let proj_path = /jhu_projects/overuse          ;
%let code_path = /code/                         ;
%let vrdc_code = &vpath./jhu_vrdc_code          ;
%include "&vrdc_code./macro_tool_box.sas";
%include "&vrdc_code./medicare_formats.sas";
*%include "&vrdc_code./jhu_build_Health_Systems.sas";

*make a count file for unique inpatient or outpatient visits for all health system encounters;
Proc sort data=&permlib..ccn_outpatient_claims_DELETE; by compendium_hospital_id year qtr &bene_id;
Proc sort data=&permlib..ccn_inpatient_claims_DELETE; by compendium_hospital_id year qtr &bene_id;
run;

data inp_outp_temp;
merge &permlib..ccn_outpatient_claims_DELETE &permlib..ccn_inpatient_claims_DELETE;
by compendium_hospital_id year qtr &bene_id;
run;

data pops;
merge
&permlib..pop_01_in_out
&permlib..pop_02_in_out
&permlib..pop_03_in_out;*
&permlib..pop_04_in_out
&permlib..pop_05_in_out
&permlib..pop_06_in_out
&permlib..pop_07_in_out
&permlib..pop_08_in_out
&permlib..pop_09_in_out
&permlib..pop_10_in_out
&permlib..pop_11_in_out
&permlib..pop_12_in_out
&permlib..pop_13_in_out`
&permlib..pop_14_in_out
&permlib..pop_15_in_out
&permlib..pop_16_in_out
&permlib..pop_17_in_out
&permlib..pop_18_in_out
&permlib..pop_19_in_out
&permlib..pop_20_in_out
&permlib..pop_21_in_out
&permlib..pop_22_in_out
;
by &bene_id;
pop=sum(popped01--popped03);
run;

/**  Pop is sum of times popped per HS code:--did same above with sum
*POP Panel Data  **;
%Macro type; 
data pop_&type; set jodi1.pop_&type._103_01_06; length pop 3; pop=pop_&type._nu; keep bene_id pop pop_num; run; 
%Mend type; 
%let type=01; %type; %let type=10; %type; %let type=11; %type; %let type=20; %type; %let type=21; %type; 
*/

proc sort data=inp_outp_temp; by &bene_id; run;
data pops_denom1;
merge inp_outp_temp (in=a) pops;
by &bene_id; *should this be bene/comp/year/qtr and all setup files same? probably;
if a;
run;

*link to beneficiary file to get enrollment info;
*https://www.resdac.org/resconnect/articles/117;
%macro line(abcd=, include_cohort=);
proc sql;
create table &include_cohort (compress=yes) as
select  
a.bene_id, b.bene_death_dt, b.VALID_DEATH_DT_SW, b.COVSTART, b.ENTLMT_RSN_ORIG, b.ENTLMT_RSN_CURR, b.BENE_PTA_TRMNTN_CD, b.BENE_PTB_TRMNTN_CD
from 
pops_denom1 a,
&abcd b
where a.bene_id=b.bene_id;
quit;
%mend;
*%line(abcd=rifq2018.mbsf_abcd_2019, include_cohort=pops_vital_2019); 
%line(abcd=mbsf.mbsf_abcd_2018, include_cohort=pops_vital_2018); 
%line(abcd=mbsf.mbsf_abcd_2017, include_cohort=pops_vital_2017); 
%line(abcd=mbsf.mbsf_abcd_2016, include_cohort=pops_vital_2016); 
/*%line(abcd=mbsf.mbsf_abcd_2015, include_cohort=pops_vital_2015); 
%line(abcd=mbsf.mbsf_abcd_2014, include_cohort=pops_vital_2014); 
%line(abcd=mbsf.mbsf_abcd_2013, include_cohort=pops_vital_2013); 
%line(abcd=mbsf.mbsf_abcd_2012, include_cohort=pops_vital_2012); 
%line(abcd=mbsf.mbsf_abcd_2011, include_cohort=pops_vital_2011); 
%line(abcd=mbsf.mbsf_abcd_2010, include_cohort=pops_vital_2010); 

proc sort data=pops_vital_2010; by bene_id;
proc sort data=pops_vital_2011; by bene_id;
proc sort data=pops_vital_2012; by bene_id;
proc sort data=pops_vital_2013; by bene_id;
proc sort data=pops_vital_2014; by bene_id;
proc sort data=pops_vital_2015; by bene_id;*/
proc sort data=pops_vital_2016; by bene_id;
proc sort data=pops_vital_2017; by bene_id;
proc sort data=pops_vital_2018; by bene_id;
/*proc sort data=pops_vital_2019; by bene_id;*/
proc sort data=pops_denom1; by bene_id;
run;
data pops_denom2;
merge /*pops_vital_2010 pops_vital_2011 pops_vital_2012 pops_vital_2013 pops_vital_2014 pops_vital_2015*/
	pops_vital_2016 pops_vital_2017 pops_vital_2018
	pops_denom1;
by &bene_id;*also set up for bene qtr year?;
run; 

*bring in chronic conditions;
%macro line(abcd=, include_cohort=);
proc sql;
create table &include_cohort (compress=yes) as
select  
a.bene_id, b.*
from 
pops_denom1 a,
&abcd b
where a.bene_id=b.bene_id;
quit;
%mend;
%line(abcd=mbsf.mbsf_cc_2018, include_cohort=pops_cc_2018); 
%line(abcd=mbsf.mbsf_cc_2017, include_cohort=pops_cc_2017); 
%line(abcd=mbsf.mbsf_cc_2016, include_cohort=pops_cc_2016); 
/*%line(abcd=mbsf.mbsf_cc_2015, include_cohort=pops_cc_2015); 
%line(abcd=mbsf.mbsf_cc_2014, include_cohort=pops_cc_2014); 
%line(abcd=mbsf.mbsf_cc_2013, include_cohort=pops_cc_2013); 
%line(abcd=mbsf.mbsf_cc_2012, include_cohort=pops_cc_2012); 
%line(abcd=mbsf.mbsf_cc_2011, include_cohort=pops_cc_2011); 
%line(abcd=mbsf.mbsf_cc_2010, include_cohort=pops_cc_2010);*/ 
%line(abcd=mbsf.mbsf_otcc_2018, include_cohort=pops_otcc_2018); 
%line(abcd=mbsf.mbsf_otcc_2017, include_cohort=pops_otcc_2017); 
%line(abcd=mbsf.mbsf_otcc_2016, include_cohort=pops_otcc_2016); 
/*%line(abcd=mbsf.mbsf_otcc_2015, include_cohort=pops_otcc_2015);
%line(abcd=mbsf.mbsf_otcc_2014, include_cohort=pops_otcc_2014); 
%line(abcd=mbsf.mbsf_otcc_2013, include_cohort=pops_otcc_2013); 
%line(abcd=mbsf.mbsf_otcc_2012, include_cohort=pops_otcc_2012); 
%line(abcd=mbsf.mbsf_otcc_2011, include_cohort=pops_otcc_2011); 
%line(abcd=mbsf.mbsf_otcc_2010, include_cohort=pops_otcc_2010); */
/*proc sort data=pops_cc_2010; by bene_id;
proc sort data=pops_cc_2011; by bene_id;
proc sort data=pops_cc_2012; by bene_id;
proc sort data=pops_cc_2013; by bene_id;
proc sort data=pops_cc_2014; by bene_id;
proc sort data=pops_cc_2015; by bene_id;*/
proc sort data=pops_cc_2016; by bene_id;
proc sort data=pops_cc_2017; by bene_id;
proc sort data=pops_cc_2018; by bene_id;
/*proc sort data=pops_otcc_2010; by bene_id;
proc sort data=pops_otcc_2011; by bene_id;
proc sort data=pops_otcc_2012; by bene_id;
proc sort data=pops_otcc_2013; by bene_id;
proc sort data=pops_otcc_2014; by bene_id;
proc sort data=pops_otcc_2015; by bene_id;*/
proc sort data=pops_otcc_2016; by bene_id;
proc sort data=pops_otcc_2017; by bene_id;
proc sort data=pops_otcc_2018; by bene_id;
proc sort data=pops_denom2; by bene_id;
run;
data pops_denom3 
(keep=bene: compendium_hospital_id year qtr pop:
ENTLMT: covstart
/*enrl_src*/ ami ami_ever alzh_ever alzh_demen_ever atrial_fib_ever
cataract_ever chronickidney_ever copd_ever chf_ever diabetes_ever glaucoma_ever  hip_fracture_ever 
ischemicheart_ever depression_ever osteoporosis_ever ra_oa_ever stroke_tia_ever cancer_breast_ever
cancer_colorectal_ever cancer_prostate_ever cancer_lung_ever cancer_endometrial_ever anemia_ever asthma_ever
hyperl_ever hyperp_ever hypert_ever hypoth_ever valid_death_dt_sw covstart entlmt: 
acp_MEDICARE_EVER anxi_MEDICARE_EVER autism_MEDICARE_EVER bipl_MEDICARE_EVER brainj_MEDICARE_EVER cerpal_MEDICARE_EVER
cysfib_MEDICARE_EVER depsn_MEDICARE_EVER epilep_MEDICARE_EVER fibro_MEDICARE_EVER hearim_MEDICARE_EVER
hepviral_MEDICARE_EVER hivaids_MEDICARE_EVER intdis_MEDICARE_EVER leadis_MEDICARE_EVER leuklymph_MEDICARE_EVER
liver_MEDICARE_EVER migraine_MEDICARE_EVER mobimp_MEDICARE_EVER mulscl_MEDICARE_EVER musdys_MEDICARE_EVER
obesity_MEDICARE_EVER othdel_MEDICARE_EVER psds_MEDICARE_EVER ptra_MEDICARE_EVER pvd_MEDICARE_EVER schi_MEDICARE_EVER
schiot_MEDICARE_EVER spibif_MEDICARE_EVER spiinj_MEDICARE_EVER toba_MEDICARE_EVER ulcers_MEDICARE_EVER visual_MEDICARE_EVER);
merge 
/*pops_otcc_2010 pops_otcc_2011 pops_otcc_2012 pops_otcc_2013 pops_otcc_2014 pops_otcc_2015*/
pops_otcc_2016 pops_otcc_2017 pops_otcc_2018
/*pops_cc_2010 pops_cc_2011 pops_cc_2012 pops_cc_2013 pops_cc_2014 pops_cc_2015*/ 
pops_cc_2016 pops_cc_2017 pops_cc_2018
pops_denom2;
by bene_id;
run; 
proc print data=pops_denom3 (obs=20); run; *this has death and chronic condition outcomes EVER (not tied to the proc date;
proc freq data=pops_cc_2016; table ami; run;*check freq;

*copy model run previously--does not account for time that i can tell and does not account for repeated measures
	if sorted 1 row per person/msa/year/qtr unless Taylor series identifies replicates/covariance not specified in model?;
proc surveyreg Data=pops_denom3;
class pop_num health_sys_id2016 gndr_cd age_group;
model pop = health_sys_id2016 gndr_cd age_group pop_num/ noint solution;
ods output ParameterEstimates=jhoi;
run;

*do we want to sum the comorbidities so single variable?--cc only or include otcc;
*exclude those with no b coverage from study?;
*age when???;
