*Pops with Diagnosis as Denominator: 

*using sinusitis as example;
*Eligible: all individuals with diagnosis of sinusitis;
%let pop='pop20';
%let icd_dx9_3='461', '473';*461 is acute, 473 is chronic;
%let icd_dx10_3='J01', 'J32'; *j01 is acute, j32 is chronic;
%let hcpcs='31575', '31476', '31577', '31578', '31579'; *pop 20: fiberoptic laryngoscopy;
				*'31231', '31233', '31235', 						*pop 21: diagnostic_endoscopy;
				*'70486', '70487', '70488' 						*pop 47: sinus ct; *Any occurrence of sinus CT (CPT 70486, 70487, 70488) in the 92 days preceding the diagnosis of acute sinusitis; 
;
*look for ICD procedures, DRG and Betos codes in addition to HCPCS;


*did not include DRG exclusion--checked diagnosis codes included in malignancy DRG lists and incorporated those that matched original ICD list;

*create formats for dgns, drg, hcpcs for easier data checks;
proc sort data=METADX.CCW_RFRNC_dgns_CD NODUPKEY OUT=dgns; BY dgns_CD dgns_DESC; RUN; 
proc sort data=dgns ; by dgns_cd descending dgns_efctv_dt; run;
proc sort data=dgns NODUPKEY out=dgns2 dupout=dgns_dup; by dgns_cd; run;
proc print data=dgns_dup; run;
data fmtdgns (rename=(dgns_CD=start));
set dgns2 (keep = dgns_cd dgns_desc);
fmtname='$dgns';
label = dgns_cd ||": " || dgns_desc;
run;
proc format cntlin=fmtdgns; run;

proc sort data=METADX.CCW_RFRNC_DRG_CD NODUPKEY OUT=DRG; WHERE DRG_EFCTV_DT>='01JAN2013'D; BY DRG_CD DRG_DESC; RUN; 
proc sort data=drg ; by drg_cd descending drg_efctv_dt; run;
proc sort data=drg NODUPKEY out=drg2 dupout=drg_dup; by drg_cd; run;
proc print data=drg_dup; run;
data fmtDRG (rename=(DRG_CD=start));
set DRG2 (keep = drg_cd drg_desc);
fmtname='$DRG';
label = drg_cd ||": " || drg_desc;
run;
proc format cntlin=fmtDRG; run;

proc sort data=METADX.CCW_RFRNC_hcpcs_CD NODUPKEY OUT=hcpcs; BY hcpcs_CD hcpcs_shrt_desc; RUN; 
proc sort data=hcpcs ; by hcpcs_cd descending hcpcs_actn_efctv_dt; run;
proc sort data=hcpcs NODUPKEY out=hcpcs2 dupout=hcpcs_dup; by hcpcs_cd; run;
proc print data=hcpcs_dup; run;
data fmthcpcs (rename=(hcpcs_CD=start));
set hcpcs2 (keep = hcpcs_cd hcpcs_shrt_desc);
fmtname='$hcpcs';
label = hcpcs_cd ||": " || hcpcs_shrt_desc;
run;
proc format cntlin=fmthcpcs; run;

*denominator based on ICD diagnosis code;
%macro inp_claims(source=, include_cohort=);
data include_cohort1; set &source;
*DX code qualifying;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
do j=1 to 25;
	if substr(dx(j),1,3) in(&icd_dx9_3) then do; qual_dgns=1; end;
	if substr(dx(j),1,3) in(&icd_dx10_3) then do; qual_dgns=1; end;
end;
if qual_dgns ne 1 then delete; 
run;
proc sort data=include_cohort1 NODUPKEY; by bene_id clm_thru_dt; run;*sorted by person and date of qualifying diagnosis;
Data &include_cohort (keep=pop:
		bene_id gndr_cd bene_race_cd bene_cnty_cd bene_state_cd bene_mlg_cntct_zip_cd  
		prvdr_num prvdr_state_cd org_npi_num at_physn: op_physn:  ot_physn: rndrng_physn: rfr_physn: prf_physn:); 
set include_cohort1;   
pop_elig=1; 							label pop_elig='eligible for pop';
pop_elig_dt=clm_thru_dt;  				label pop_elig_dt='date eligible for pop';*note this is end date NOT admission date or clm_from_dt;
pop_los=clm_thru_dt-clm_from_dt;		label pop_los='length of stay for pop eligibility';
pop_age=(clm_thru_dt-dob_dt)/365.25; 	label pop_age='age eligible for pop';
pop_age=round(pop_age);
pop_year=year(clm_thru_dt);
pop_nch_clm_type_cd=nch_clm_type_cd; 	label pop_nch_clm_type_cd='claim type for pop eligibility';
pop_clm_fac_type_cd=clm_fac_type_cd;	label pop_clm_fac_type_cd='facility type for pop eligibility';
if admtg_dgns_cd ne ' ' then do; pop_admtg_dgns_cd=put(admtg_dgns_cd,$dgns.); end;
if icd_dgns_cd1 ne ' ' then do; pop_icd_dgns_cd1=put(icd_dgns_cd1,$dgns.); end;
if clm_drg_cd ne ' ' then do;pop_clm_drg_cd=put(clm_drg_cd,$drg.);end;
if hcpcs_cd ne ' ' then do; pop_hcpcs_cd=put(hcpcs_cd,$hcpcs.);end;
if icd_prcdr_cd1 ne ' ' then do; pop_icd_prcdr_cd1=icd_prcdr_cd1; end;
if clm_ip_admsn_type_cd ne ' ' then do; pop_clm_ip_admsn_type_cd=clm_ip_admsn_type_cd; end;
run;
%mend;
%inp_claims(source=rif2010.inpatient_claims_01, include_cohort=pop_INdenom_2010_1);
%inp_claims(source=rif2010.inpatient_claims_02, include_cohort=pop_INdenom_2010_2);
%inp_claims(source=rif2010.inpatient_claims_03, include_cohort=pop_INdenom_2010_3);
%inp_claims(source=rif2010.inpatient_claims_04, include_cohort=pop_INdenom_2010_4);
%inp_claims(source=rif2010.inpatient_claims_05, include_cohort=pop_INdenom_2010_5);
%inp_claims(source=rif2010.inpatient_claims_06, include_cohort=pop_INdenom_2010_6);
%inp_claims(source=rif2010.inpatient_claims_07, include_cohort=pop_INdenom_2010_7);
%inp_claims(source=rif2010.inpatient_claims_08, include_cohort=pop_INdenom_2010_8);
%inp_claims(source=rif2010.inpatient_claims_09, include_cohort=pop_INdenom_2010_9);
%inp_claims(source=rif2010.inpatient_claims_10, include_cohort=pop_INdenom_2010_10);
%inp_claims(source=rif2010.inpatient_claims_11, include_cohort=pop_INdenom_2010_11);
%inp_claims(source=rif2010.inpatient_claims_12, include_cohort=pop_INdenom_2010_12);
%inp_claims(source=rif2010.outpatient_claims_01, include_cohort=pop_OUTdenom_2010_1);
%inp_claims(source=rif2010.outpatient_claims_02, include_cohort=pop_OUTdenom_2010_2);
%inp_claims(source=rif2010.outpatient_claims_03, include_cohort=pop_OUTdenom_2010_3);
%inp_claims(source=rif2010.outpatient_claims_04, include_cohort=pop_OUTdenom_2010_4);
%inp_claims(source=rif2010.outpatient_claims_05, include_cohort=pop_OUTdenom_2010_5);
%inp_claims(source=rif2010.outpatient_claims_06, include_cohort=pop_OUTdenom_2010_6);
%inp_claims(source=rif2010.outpatient_claims_07, include_cohort=pop_OUTdenom_2010_7);
%inp_claims(source=rif2010.outpatient_claims_08, include_cohort=pop_OUTdenom_2010_8);
%inp_claims(source=rif2010.outpatient_claims_09, include_cohort=pop_OUTdenom_2010_9);
%inp_claims(source=rif2010.outpatient_claims_10, include_cohort=pop_OUTdenom_2010_10);
%inp_claims(source=rif2010.outpatient_claims_11, include_cohort=pop_OUTdenom_2010_11);
%inp_claims(source=rif2010.outpatient_claims_12, include_cohort=pop_OUTdenom_2010_12);
%inp_claims(source=rif2010.bcarrier_claims_01, include_cohort=pop_CARdenom_2010_1);
%inp_claims(source=rif2010.bcarrier_claims_02, include_cohort=pop_CARdenom_2010_2);
%inp_claims(source=rif2010.bcarrier_claims_03, include_cohort=pop_CARdenom_2010_3);
%inp_claims(source=rif2010.bcarrier_claims_04, include_cohort=pop_CARdenom_2010_4);
%inp_claims(source=rif2010.bcarrier_claims_05, include_cohort=pop_CARdenom_2010_5);
%inp_claims(source=rif2010.bcarrier_claims_06, include_cohort=pop_CARdenom_2010_6);
%inp_claims(source=rif2010.bcarrier_claims_07, include_cohort=pop_CARdenom_2010_7);
%inp_claims(source=rif2010.bcarrier_claims_08, include_cohort=pop_CARdenom_2010_8);
%inp_claims(source=rif2010.bcarrier_claims_09, include_cohort=pop_CARdenom_2010_9);
%inp_claims(source=rif2010.bcarrier_claims_10, include_cohort=pop_CARdenom_2010_10);
%inp_claims(source=rif2010.bcarrier_claims_11, include_cohort=pop_CARdenom_2010_11);
%inp_claims(source=rif2010.bcarrier_claims_12, include_cohort=pop_CARdenom_2010_12);

%inp_claims(source=rif2011.inpatient_claims_01, include_cohort=pop_INdenom_2011_1);
%inp_claims(source=rif2011.inpatient_claims_02, include_cohort=pop_INdenom_2011_2);
%inp_claims(source=rif2011.inpatient_claims_03, include_cohort=pop_INdenom_2011_3);
%inp_claims(source=rif2011.inpatient_claims_04, include_cohort=pop_INdenom_2011_4);
%inp_claims(source=rif2011.inpatient_claims_05, include_cohort=pop_INdenom_2011_5);
%inp_claims(source=rif2011.inpatient_claims_06, include_cohort=pop_INdenom_2011_6);
%inp_claims(source=rif2011.inpatient_claims_07, include_cohort=pop_INdenom_2011_7);
%inp_claims(source=rif2011.inpatient_claims_08, include_cohort=pop_INdenom_2011_8);
%inp_claims(source=rif2011.inpatient_claims_09, include_cohort=pop_INdenom_2011_9);
%inp_claims(source=rif2011.inpatient_claims_10, include_cohort=pop_INdenom_2011_10);
%inp_claims(source=rif2011.inpatient_claims_11, include_cohort=pop_INdenom_2011_11);
%inp_claims(source=rif2011.inpatient_claims_12, include_cohort=pop_INdenom_2011_12);
%inp_claims(source=rif2011.outpatient_claims_01, include_cohort=pop_OUTdenom_2011_1);
%inp_claims(source=rif2011.outpatient_claims_02, include_cohort=pop_OUTdenom_2011_2);
%inp_claims(source=rif2011.outpatient_claims_03, include_cohort=pop_OUTdenom_2011_3);
%inp_claims(source=rif2011.outpatient_claims_04, include_cohort=pop_OUTdenom_2011_4);
%inp_claims(source=rif2011.outpatient_claims_05, include_cohort=pop_OUTdenom_2011_5);
%inp_claims(source=rif2011.outpatient_claims_06, include_cohort=pop_OUTdenom_2011_6);
%inp_claims(source=rif2011.outpatient_claims_07, include_cohort=pop_OUTdenom_2011_7);
%inp_claims(source=rif2011.outpatient_claims_08, include_cohort=pop_OUTdenom_2011_8);
%inp_claims(source=rif2011.outpatient_claims_09, include_cohort=pop_OUTdenom_2011_9);
%inp_claims(source=rif2011.outpatient_claims_10, include_cohort=pop_OUTdenom_2011_10);
%inp_claims(source=rif2011.outpatient_claims_11, include_cohort=pop_OUTdenom_2011_11);
%inp_claims(source=rif2011.outpatient_claims_12, include_cohort=pop_OUTdenom_2011_12);
%inp_claims(source=rif2011.bcarrier_claims_01, include_cohort=pop_CARdenom_2011_1);
%inp_claims(source=rif2011.bcarrier_claims_02, include_cohort=pop_CARdenom_2011_2);
%inp_claims(source=rif2011.bcarrier_claims_03, include_cohort=pop_CARdenom_2011_3);
%inp_claims(source=rif2011.bcarrier_claims_04, include_cohort=pop_CARdenom_2011_4);
%inp_claims(source=rif2011.bcarrier_claims_05, include_cohort=pop_CARdenom_2011_5);
%inp_claims(source=rif2011.bcarrier_claims_06, include_cohort=pop_CARdenom_2011_6);
%inp_claims(source=rif2011.bcarrier_claims_07, include_cohort=pop_CARdenom_2011_7);
%inp_claims(source=rif2011.bcarrier_claims_08, include_cohort=pop_CARdenom_2011_8);
%inp_claims(source=rif2011.bcarrier_claims_09, include_cohort=pop_CARdenom_2011_9);
%inp_claims(source=rif2011.bcarrier_claims_10, include_cohort=pop_CARdenom_2011_10);
%inp_claims(source=rif2011.bcarrier_claims_11, include_cohort=pop_CARdenom_2011_11);
%inp_claims(source=rif2011.bcarrier_claims_12, include_cohort=pop_CARdenom_2011_12);

%inp_claims(source=rif2012.inpatient_claims_01, include_cohort=pop_INdenom_2012_1);
%inp_claims(source=rif2012.inpatient_claims_02, include_cohort=pop_INdenom_2012_2);
%inp_claims(source=rif2012.inpatient_claims_03, include_cohort=pop_INdenom_2012_3);
%inp_claims(source=rif2012.inpatient_claims_04, include_cohort=pop_INdenom_2012_4);
%inp_claims(source=rif2012.inpatient_claims_05, include_cohort=pop_INdenom_2012_5);
%inp_claims(source=rif2012.inpatient_claims_06, include_cohort=pop_INdenom_2012_6);
%inp_claims(source=rif2012.inpatient_claims_07, include_cohort=pop_INdenom_2012_7);
%inp_claims(source=rif2012.inpatient_claims_08, include_cohort=pop_INdenom_2012_8);
%inp_claims(source=rif2012.inpatient_claims_09, include_cohort=pop_INdenom_2012_9);
%inp_claims(source=rif2012.inpatient_claims_10, include_cohort=pop_INdenom_2012_10);
%inp_claims(source=rif2012.inpatient_claims_11, include_cohort=pop_INdenom_2012_11);
%inp_claims(source=rif2012.inpatient_claims_12, include_cohort=pop_INdenom_2012_12);
%inp_claims(source=rif2012.outpatient_claims_01, include_cohort=pop_OUTdenom_2012_1);
%inp_claims(source=rif2012.outpatient_claims_02, include_cohort=pop_OUTdenom_2012_2);
%inp_claims(source=rif2012.outpatient_claims_03, include_cohort=pop_OUTdenom_2012_3);
%inp_claims(source=rif2012.outpatient_claims_04, include_cohort=pop_OUTdenom_2012_4);
%inp_claims(source=rif2012.outpatient_claims_05, include_cohort=pop_OUTdenom_2012_5);
%inp_claims(source=rif2012.outpatient_claims_06, include_cohort=pop_OUTdenom_2012_6);
%inp_claims(source=rif2012.outpatient_claims_07, include_cohort=pop_OUTdenom_2012_7);
%inp_claims(source=rif2012.outpatient_claims_08, include_cohort=pop_OUTdenom_2012_8);
%inp_claims(source=rif2012.outpatient_claims_09, include_cohort=pop_OUTdenom_2012_9);
%inp_claims(source=rif2012.outpatient_claims_10, include_cohort=pop_OUTdenom_2012_10);
%inp_claims(source=rif2012.outpatient_claims_11, include_cohort=pop_OUTdenom_2012_11);
%inp_claims(source=rif2012.outpatient_claims_12, include_cohort=pop_OUTdenom_2012_12);
%inp_claims(source=rif2012.bcarrier_claims_01, include_cohort=pop_CARdenom_2012_1);
%inp_claims(source=rif2012.bcarrier_claims_02, include_cohort=pop_CARdenom_2012_2);
%inp_claims(source=rif2012.bcarrier_claims_03, include_cohort=pop_CARdenom_2012_3);
%inp_claims(source=rif2012.bcarrier_claims_04, include_cohort=pop_CARdenom_2012_4);
%inp_claims(source=rif2012.bcarrier_claims_05, include_cohort=pop_CARdenom_2012_5);
%inp_claims(source=rif2012.bcarrier_claims_06, include_cohort=pop_CARdenom_2012_6);
%inp_claims(source=rif2012.bcarrier_claims_07, include_cohort=pop_CARdenom_2012_7);
%inp_claims(source=rif2012.bcarrier_claims_08, include_cohort=pop_CARdenom_2012_8);
%inp_claims(source=rif2012.bcarrier_claims_09, include_cohort=pop_CARdenom_2012_9);
%inp_claims(source=rif2012.bcarrier_claims_10, include_cohort=pop_CARdenom_2012_10);
%inp_claims(source=rif2012.bcarrier_claims_11, include_cohort=pop_CARdenom_2012_11);
%inp_claims(source=rif2012.bcarrier_claims_12, include_cohort=pop_CARdenom_2012_12);

%inp_claims(source=rif2013.inpatient_claims_01, include_cohort=pop_INdenom_2013_1);
%inp_claims(source=rif2013.inpatient_claims_02, include_cohort=pop_INdenom_2013_2);
%inp_claims(source=rif2013.inpatient_claims_03, include_cohort=pop_INdenom_2013_3);
%inp_claims(source=rif2013.inpatient_claims_04, include_cohort=pop_INdenom_2013_4);
%inp_claims(source=rif2013.inpatient_claims_05, include_cohort=pop_INdenom_2013_5);
%inp_claims(source=rif2013.inpatient_claims_06, include_cohort=pop_INdenom_2013_6);
%inp_claims(source=rif2013.inpatient_claims_07, include_cohort=pop_INdenom_2013_7);
%inp_claims(source=rif2013.inpatient_claims_08, include_cohort=pop_INdenom_2013_8);
%inp_claims(source=rif2013.inpatient_claims_09, include_cohort=pop_INdenom_2013_9);
%inp_claims(source=rif2013.inpatient_claims_10, include_cohort=pop_INdenom_2013_10);
%inp_claims(source=rif2013.inpatient_claims_11, include_cohort=pop_INdenom_2013_11);
%inp_claims(source=rif2013.inpatient_claims_12, include_cohort=pop_INdenom_2013_12);
%inp_claims(source=rif2013.outpatient_claims_01, include_cohort=pop_OUTdenom_2013_1);
%inp_claims(source=rif2013.outpatient_claims_02, include_cohort=pop_OUTdenom_2013_2);
%inp_claims(source=rif2013.outpatient_claims_03, include_cohort=pop_OUTdenom_2013_3);
%inp_claims(source=rif2013.outpatient_claims_04, include_cohort=pop_OUTdenom_2013_4);
%inp_claims(source=rif2013.outpatient_claims_05, include_cohort=pop_OUTdenom_2013_5);
%inp_claims(source=rif2013.outpatient_claims_06, include_cohort=pop_OUTdenom_2013_6);
%inp_claims(source=rif2013.outpatient_claims_07, include_cohort=pop_OUTdenom_2013_7);
%inp_claims(source=rif2013.outpatient_claims_08, include_cohort=pop_OUTdenom_2013_8);
%inp_claims(source=rif2013.outpatient_claims_09, include_cohort=pop_OUTdenom_2013_9);
%inp_claims(source=rif2013.outpatient_claims_10, include_cohort=pop_OUTdenom_2013_10);
%inp_claims(source=rif2013.outpatient_claims_11, include_cohort=pop_OUTdenom_2013_11);
%inp_claims(source=rif2013.outpatient_claims_12, include_cohort=pop_OUTdenom_2013_12);
%inp_claims(source=rif2013.bcarrier_claims_01, include_cohort=pop_CARdenom_2013_1);
%inp_claims(source=rif2013.bcarrier_claims_02, include_cohort=pop_CARdenom_2013_2);
%inp_claims(source=rif2013.bcarrier_claims_03, include_cohort=pop_CARdenom_2013_3);
%inp_claims(source=rif2013.bcarrier_claims_04, include_cohort=pop_CARdenom_2013_4);
%inp_claims(source=rif2013.bcarrier_claims_05, include_cohort=pop_CARdenom_2013_5);
%inp_claims(source=rif2013.bcarrier_claims_06, include_cohort=pop_CARdenom_2013_6);
%inp_claims(source=rif2013.bcarrier_claims_07, include_cohort=pop_CARdenom_2013_7);
%inp_claims(source=rif2013.bcarrier_claims_08, include_cohort=pop_CARdenom_2013_8);
%inp_claims(source=rif2013.bcarrier_claims_09, include_cohort=pop_CARdenom_2013_9);
%inp_claims(source=rif2013.bcarrier_claims_10, include_cohort=pop_CARdenom_2013_10);
%inp_claims(source=rif2013.bcarrier_claims_11, include_cohort=pop_CARdenom_2013_11);
%inp_claims(source=rif2013.bcarrier_claims_12, include_cohort=pop_CARdenom_2013_12);

%inp_claims(source=rif2014.inpatient_claims_01, include_cohort=pop_INdenom_2014_1);
%inp_claims(source=rif2014.inpatient_claims_02, include_cohort=pop_INdenom_2014_2);
%inp_claims(source=rif2014.inpatient_claims_03, include_cohort=pop_INdenom_2014_3);
%inp_claims(source=rif2014.inpatient_claims_04, include_cohort=pop_INdenom_2014_4);
%inp_claims(source=rif2014.inpatient_claims_05, include_cohort=pop_INdenom_2014_5);
%inp_claims(source=rif2014.inpatient_claims_06, include_cohort=pop_INdenom_2014_6);
%inp_claims(source=rif2014.inpatient_claims_07, include_cohort=pop_INdenom_2014_7);
%inp_claims(source=rif2014.inpatient_claims_08, include_cohort=pop_INdenom_2014_8);
%inp_claims(source=rif2014.inpatient_claims_09, include_cohort=pop_INdenom_2014_9);
%inp_claims(source=rif2014.inpatient_claims_10, include_cohort=pop_INdenom_2014_10);
%inp_claims(source=rif2014.inpatient_claims_11, include_cohort=pop_INdenom_2014_11);
%inp_claims(source=rif2014.inpatient_claims_12, include_cohort=pop_INdenom_2014_12);
%inp_claims(source=rif2014.outpatient_claims_01, include_cohort=pop_OUTdenom_2014_1);
%inp_claims(source=rif2014.outpatient_claims_02, include_cohort=pop_OUTdenom_2014_2);
%inp_claims(source=rif2014.outpatient_claims_03, include_cohort=pop_OUTdenom_2014_3);
%inp_claims(source=rif2014.outpatient_claims_04, include_cohort=pop_OUTdenom_2014_4);
%inp_claims(source=rif2014.outpatient_claims_05, include_cohort=pop_OUTdenom_2014_5);
%inp_claims(source=rif2014.outpatient_claims_06, include_cohort=pop_OUTdenom_2014_6);
%inp_claims(source=rif2014.outpatient_claims_07, include_cohort=pop_OUTdenom_2014_7);
%inp_claims(source=rif2014.outpatient_claims_08, include_cohort=pop_OUTdenom_2014_8);
%inp_claims(source=rif2014.outpatient_claims_09, include_cohort=pop_OUTdenom_2014_9);
%inp_claims(source=rif2014.outpatient_claims_10, include_cohort=pop_OUTdenom_2014_10);
%inp_claims(source=rif2014.outpatient_claims_11, include_cohort=pop_OUTdenom_2014_11);
%inp_claims(source=rif2014.outpatient_claims_12, include_cohort=pop_OUTdenom_2014_12);
%inp_claims(source=rif2014.bcarrier_claims_01, include_cohort=pop_CARdenom_2014_1);
%inp_claims(source=rif2014.bcarrier_claims_02, include_cohort=pop_CARdenom_2014_2);
%inp_claims(source=rif2014.bcarrier_claims_03, include_cohort=pop_CARdenom_2014_3);
%inp_claims(source=rif2014.bcarrier_claims_04, include_cohort=pop_CARdenom_2014_4);
%inp_claims(source=rif2014.bcarrier_claims_05, include_cohort=pop_CARdenom_2014_5);
%inp_claims(source=rif2014.bcarrier_claims_06, include_cohort=pop_CARdenom_2014_6);
%inp_claims(source=rif2014.bcarrier_claims_07, include_cohort=pop_CARdenom_2014_7);
%inp_claims(source=rif2014.bcarrier_claims_08, include_cohort=pop_CARdenom_2014_8);
%inp_claims(source=rif2014.bcarrier_claims_09, include_cohort=pop_CARdenom_2014_9);
%inp_claims(source=rif2014.bcarrier_claims_10, include_cohort=pop_CARdenom_2014_10);
%inp_claims(source=rif2014.bcarrier_claims_11, include_cohort=pop_CARdenom_2014_11);
%inp_claims(source=rif2014.bcarrier_claims_12, include_cohort=pop_CARdenom_2014_12);

%inp_claims(source=rif2015.inpatient_claims_01, include_cohort=pop_INdenom_2015_1);
%inp_claims(source=rif2015.inpatient_claims_02, include_cohort=pop_INdenom_2015_2);
%inp_claims(source=rif2015.inpatient_claims_03, include_cohort=pop_INdenom_2015_3);
%inp_claims(source=rif2015.inpatient_claims_04, include_cohort=pop_INdenom_2015_4);
%inp_claims(source=rif2015.inpatient_claims_05, include_cohort=pop_INdenom_2015_5);
%inp_claims(source=rif2015.inpatient_claims_06, include_cohort=pop_INdenom_2015_6);
%inp_claims(source=rif2015.inpatient_claims_07, include_cohort=pop_INdenom_2015_7);
%inp_claims(source=rif2015.inpatient_claims_08, include_cohort=pop_INdenom_2015_8);
%inp_claims(source=rif2015.inpatient_claims_09, include_cohort=pop_INdenom_2015_9);
%inp_claims(source=rif2015.inpatient_claims_10, include_cohort=pop_INdenom_2015_10);
%inp_claims(source=rif2015.inpatient_claims_11, include_cohort=pop_INdenom_2015_11);
%inp_claims(source=rif2015.inpatient_claims_12, include_cohort=pop_INdenom_2015_12);
%inp_claims(source=rif2015.outpatient_claims_01, include_cohort=pop_OUTdenom_2015_1);
%inp_claims(source=rif2015.outpatient_claims_02, include_cohort=pop_OUTdenom_2015_2);
%inp_claims(source=rif2015.outpatient_claims_03, include_cohort=pop_OUTdenom_2015_3);
%inp_claims(source=rif2015.outpatient_claims_04, include_cohort=pop_OUTdenom_2015_4);
%inp_claims(source=rif2015.outpatient_claims_05, include_cohort=pop_OUTdenom_2015_5);
%inp_claims(source=rif2015.outpatient_claims_06, include_cohort=pop_OUTdenom_2015_6);
%inp_claims(source=rif2015.outpatient_claims_07, include_cohort=pop_OUTdenom_2015_7);
%inp_claims(source=rif2015.outpatient_claims_08, include_cohort=pop_OUTdenom_2015_8);
%inp_claims(source=rif2015.outpatient_claims_09, include_cohort=pop_OUTdenom_2015_9);
%inp_claims(source=rif2015.outpatient_claims_10, include_cohort=pop_OUTdenom_2015_10);
%inp_claims(source=rif2015.outpatient_claims_11, include_cohort=pop_OUTdenom_2015_11);
%inp_claims(source=rif2015.outpatient_claims_12, include_cohort=pop_OUTdenom_2015_12);
%inp_claims(source=rif2015.bcarrier_claims_01, include_cohort=pop_CARdenom_2015_1);
%inp_claims(source=rif2015.bcarrier_claims_02, include_cohort=pop_CARdenom_2015_2);
%inp_claims(source=rif2015.bcarrier_claims_03, include_cohort=pop_CARdenom_2015_3);
%inp_claims(source=rif2015.bcarrier_claims_04, include_cohort=pop_CARdenom_2015_4);
%inp_claims(source=rif2015.bcarrier_claims_05, include_cohort=pop_CARdenom_2015_5);
%inp_claims(source=rif2015.bcarrier_claims_06, include_cohort=pop_CARdenom_2015_6);
%inp_claims(source=rif2015.bcarrier_claims_07, include_cohort=pop_CARdenom_2015_7);
%inp_claims(source=rif2015.bcarrier_claims_08, include_cohort=pop_CARdenom_2015_8);
%inp_claims(source=rif2015.bcarrier_claims_09, include_cohort=pop_CARdenom_2015_9);
%inp_claims(source=rif2015.bcarrier_claims_10, include_cohort=pop_CARdenom_2015_10);
%inp_claims(source=rif2015.bcarrier_claims_11, include_cohort=pop_CARdenom_2015_11);
%inp_claims(source=rif2015.bcarrier_claims_12, include_cohort=pop_CARdenom_2015_12);

%inp_claims(source=rif2016.inpatient_claims_01, include_cohort=pop_INdenom_2016_1);
%inp_claims(source=rif2016.inpatient_claims_02, include_cohort=pop_INdenom_2016_2);
%inp_claims(source=rif2016.inpatient_claims_03, include_cohort=pop_INdenom_2016_3);
%inp_claims(source=rif2016.inpatient_claims_04, include_cohort=pop_INdenom_2016_4);
%inp_claims(source=rif2016.inpatient_claims_05, include_cohort=pop_INdenom_2016_5);
%inp_claims(source=rif2016.inpatient_claims_06, include_cohort=pop_INdenom_2016_6);
%inp_claims(source=rif2016.inpatient_claims_07, include_cohort=pop_INdenom_2016_7);
%inp_claims(source=rif2016.inpatient_claims_08, include_cohort=pop_INdenom_2016_8);
%inp_claims(source=rif2016.inpatient_claims_09, include_cohort=pop_INdenom_2016_9);
%inp_claims(source=rif2016.inpatient_claims_10, include_cohort=pop_INdenom_2016_10);
%inp_claims(source=rif2016.inpatient_claims_11, include_cohort=pop_INdenom_2016_11);
%inp_claims(source=rif2016.inpatient_claims_12, include_cohort=pop_INdenom_2016_12);
%inp_claims(source=rif2016.outpatient_claims_01, include_cohort=pop_OUTdenom_2016_1);
%inp_claims(source=rif2016.outpatient_claims_02, include_cohort=pop_OUTdenom_2016_2);
%inp_claims(source=rif2016.outpatient_claims_03, include_cohort=pop_OUTdenom_2016_3);
%inp_claims(source=rif2016.outpatient_claims_04, include_cohort=pop_OUTdenom_2016_4);
%inp_claims(source=rif2016.outpatient_claims_05, include_cohort=pop_OUTdenom_2016_5);
%inp_claims(source=rif2016.outpatient_claims_06, include_cohort=pop_OUTdenom_2016_6);
%inp_claims(source=rif2016.outpatient_claims_07, include_cohort=pop_OUTdenom_2016_7);
%inp_claims(source=rif2016.outpatient_claims_08, include_cohort=pop_OUTdenom_2016_8);
%inp_claims(source=rif2016.outpatient_claims_09, include_cohort=pop_OUTdenom_2016_9);
%inp_claims(source=rif2016.outpatient_claims_10, include_cohort=pop_OUTdenom_2016_10);
%inp_claims(source=rif2016.outpatient_claims_11, include_cohort=pop_OUTdenom_2016_11);
%inp_claims(source=rif2016.outpatient_claims_12, include_cohort=pop_OUTdenom_2016_12);
%inp_claims(source=rif2016.bcarrier_claims_01, include_cohort=pop_CARdenom_2016_1);
%inp_claims(source=rif2016.bcarrier_claims_02, include_cohort=pop_CARdenom_2016_2);
%inp_claims(source=rif2016.bcarrier_claims_03, include_cohort=pop_CARdenom_2016_3);
%inp_claims(source=rif2016.bcarrier_claims_04, include_cohort=pop_CARdenom_2016_4);
%inp_claims(source=rif2016.bcarrier_claims_05, include_cohort=pop_CARdenom_2016_5);
%inp_claims(source=rif2016.bcarrier_claims_06, include_cohort=pop_CARdenom_2016_6);
%inp_claims(source=rif2016.bcarrier_claims_07, include_cohort=pop_CARdenom_2016_7);
%inp_claims(source=rif2016.bcarrier_claims_08, include_cohort=pop_CARdenom_2016_8);
%inp_claims(source=rif2016.bcarrier_claims_09, include_cohort=pop_CARdenom_2016_9);
%inp_claims(source=rif2016.bcarrier_claims_10, include_cohort=pop_CARdenom_2016_10);
%inp_claims(source=rif2016.bcarrier_claims_11, include_cohort=pop_CARdenom_2016_11);
%inp_claims(source=rif2016.bcarrier_claims_12, include_cohort=pop_CARdenom_2016_12);

%inp_claims(source=rif2017.inpatient_claims_01, include_cohort=pop_INdenom_2017_1);
%inp_claims(source=rif2017.inpatient_claims_02, include_cohort=pop_INdenom_2017_2);
%inp_claims(source=rif2017.inpatient_claims_03, include_cohort=pop_INdenom_2017_3);
%inp_claims(source=rif2017.inpatient_claims_04, include_cohort=pop_INdenom_2017_4);
%inp_claims(source=rif2017.inpatient_claims_05, include_cohort=pop_INdenom_2017_5);
%inp_claims(source=rif2017.inpatient_claims_06, include_cohort=pop_INdenom_2017_6);
%inp_claims(source=rif2017.inpatient_claims_07, include_cohort=pop_INdenom_2017_7);
%inp_claims(source=rif2017.inpatient_claims_08, include_cohort=pop_INdenom_2017_8);
%inp_claims(source=rif2017.inpatient_claims_09, include_cohort=pop_INdenom_2017_9);
%inp_claims(source=rif2017.inpatient_claims_10, include_cohort=pop_INdenom_2017_10);
%inp_claims(source=rif2017.inpatient_claims_11, include_cohort=pop_INdenom_2017_11);
%inp_claims(source=rif2017.inpatient_claims_12, include_cohort=pop_INdenom_2017_12);
%inp_claims(source=rif2017.outpatient_claims_01, include_cohort=pop_OUTdenom_2017_1);
%inp_claims(source=rif2017.outpatient_claims_02, include_cohort=pop_OUTdenom_2017_2);
%inp_claims(source=rif2017.outpatient_claims_03, include_cohort=pop_OUTdenom_2017_3);
%inp_claims(source=rif2017.outpatient_claims_04, include_cohort=pop_OUTdenom_2017_4);
%inp_claims(source=rif2017.outpatient_claims_05, include_cohort=pop_OUTdenom_2017_5);
%inp_claims(source=rif2017.outpatient_claims_06, include_cohort=pop_OUTdenom_2017_6);
%inp_claims(source=rif2017.outpatient_claims_07, include_cohort=pop_OUTdenom_2017_7);
%inp_claims(source=rif2017.outpatient_claims_08, include_cohort=pop_OUTdenom_2017_8);
%inp_claims(source=rif2017.outpatient_claims_09, include_cohort=pop_OUTdenom_2017_9);
%inp_claims(source=rif2017.outpatient_claims_10, include_cohort=pop_OUTdenom_2017_10);
%inp_claims(source=rif2017.outpatient_claims_11, include_cohort=pop_OUTdenom_2017_11);
%inp_claims(source=rif2017.outpatient_claims_12, include_cohort=pop_OUTdenom_2017_12);
%inp_claims(source=rif2017.bcarrier_claims_01, include_cohort=pop_CARdenom_2017_1);
%inp_claims(source=rif2017.bcarrier_claims_02, include_cohort=pop_CARdenom_2017_2);
%inp_claims(source=rif2017.bcarrier_claims_03, include_cohort=pop_CARdenom_2017_3);
%inp_claims(source=rif2017.bcarrier_claims_04, include_cohort=pop_CARdenom_2017_4);
%inp_claims(source=rif2017.bcarrier_claims_05, include_cohort=pop_CARdenom_2017_5);
%inp_claims(source=rif2017.bcarrier_claims_06, include_cohort=pop_CARdenom_2017_6);
%inp_claims(source=rif2017.bcarrier_claims_07, include_cohort=pop_CARdenom_2017_7);
%inp_claims(source=rif2017.bcarrier_claims_08, include_cohort=pop_CARdenom_2017_8);
%inp_claims(source=rif2017.bcarrier_claims_09, include_cohort=pop_CARdenom_2017_9);
%inp_claims(source=rif2017.bcarrier_claims_10, include_cohort=pop_CARdenom_2017_10);
%inp_claims(source=rif2017.bcarrier_claims_11, include_cohort=pop_CARdenom_2017_11);
%inp_claims(source=rif2017.bcarrier_claims_12, include_cohort=pop_CARdenom_2017_12);

%inp_claims(source=rifq2018.inpatient_claims_01, include_cohort=pop_INdenom_2018_1);
%inp_claims(source=rifq2018.inpatient_claims_02, include_cohort=pop_INdenom_2018_2);
%inp_claims(source=rifq2018.inpatient_claims_03, include_cohort=pop_INdenom_2018_3);
%inp_claims(source=rifq2018.inpatient_claims_04, include_cohort=pop_INdenom_2018_4);
%inp_claims(source=rifq2018.inpatient_claims_05, include_cohort=pop_INdenom_2018_5);
%inp_claims(source=rifq2018.inpatient_claims_06, include_cohort=pop_INdenom_2018_6);
%inp_claims(source=rifq2018.inpatient_claims_07, include_cohort=pop_INdenom_2018_7);
%inp_claims(source=rifq2018.inpatient_claims_08, include_cohort=pop_INdenom_2018_8);
%inp_claims(source=rifq2018.inpatient_claims_09, include_cohort=pop_INdenom_2018_9);
%inp_claims(source=rifq2018.inpatient_claims_10, include_cohort=pop_INdenom_2018_10);
%inp_claims(source=rifq2018.inpatient_claims_11, include_cohort=pop_INdenom_2018_11);
%inp_claims(source=rifq2018.inpatient_claims_12, include_cohort=pop_INdenom_2018_12);
%inp_claims(source=rifq2018.outpatient_claims_01, include_cohort=pop_OUTdenom_2018_1);
%inp_claims(source=rifq2018.outpatient_claims_02, include_cohort=pop_OUTdenom_2018_2);
%inp_claims(source=rifq2018.outpatient_claims_03, include_cohort=pop_OUTdenom_2018_3);
%inp_claims(source=rifq2018.outpatient_claims_04, include_cohort=pop_OUTdenom_2018_4);
%inp_claims(source=rifq2018.outpatient_claims_05, include_cohort=pop_OUTdenom_2018_5);
%inp_claims(source=rifq2018.outpatient_claims_06, include_cohort=pop_OUTdenom_2018_6);
%inp_claims(source=rifq2018.outpatient_claims_07, include_cohort=pop_OUTdenom_2018_7);
%inp_claims(source=rifq2018.outpatient_claims_08, include_cohort=pop_OUTdenom_2018_8);
%inp_claims(source=rifq2018.outpatient_claims_09, include_cohort=pop_OUTdenom_2018_9);
%inp_claims(source=rifq2018.outpatient_claims_10, include_cohort=pop_OUTdenom_2018_10);
%inp_claims(source=rifq2018.outpatient_claims_11, include_cohort=pop_OUTdenom_2018_11);
%inp_claims(source=rifq2018.outpatient_claims_12, include_cohort=pop_OUTdenom_2018_12);
%inp_claims(source=rifq2018.bcarrier_claims_01, include_cohort=pop_CARdenom_2018_1);
%inp_claims(source=rifq2018.bcarrier_claims_02, include_cohort=pop_CARdenom_2018_2);
%inp_claims(source=rifq2018.bcarrier_claims_03, include_cohort=pop_CARdenom_2018_3);
%inp_claims(source=rifq2018.bcarrier_claims_04, include_cohort=pop_CARdenom_2018_4);
%inp_claims(source=rifq2018.bcarrier_claims_05, include_cohort=pop_CARdenom_2018_5);
%inp_claims(source=rifq2018.bcarrier_claims_06, include_cohort=pop_CARdenom_2018_6);
%inp_claims(source=rifq2018.bcarrier_claims_07, include_cohort=pop_CARdenom_2018_7);
%inp_claims(source=rifq2018.bcarrier_claims_08, include_cohort=pop_CARdenom_2018_8);
%inp_claims(source=rifq2018.bcarrier_claims_09, include_cohort=pop_CARdenom_2018_9);
%inp_claims(source=rifq2018.bcarrier_claims_10, include_cohort=pop_CARdenom_2018_10);
%inp_claims(source=rifq2018.bcarrier_claims_11, include_cohort=pop_CARdenom_2018_11);
%inp_claims(source=rifq2018.bcarrier_claims_12, include_cohort=pop_CARdenom_2018_12);
*did not go to line item files for line icd exclusion;

data pop_denom;
set pop_INdenom_2010_1 pop_INdenom_2010_2 pop_INdenom_2010_3 pop_INdenom_2010_4 pop_INdenom_2010_5 pop_INdenom_2010_6 pop_INdenom_2010_7
pop_INdenom_2010_8 pop_INdenom_2010_9 pop_INdenom_2010_10 pop_INdenom_2010_11 pop_INdenom_2010_12
pop_outdenom_2010_1 pop_outdenom_2010_2 pop_outdenom_2010_3 pop_outdenom_2010_4 pop_outdenom_2010_5 pop_outdenom_2010_6 pop_outdenom_2010_7
pop_outdenom_2010_8 pop_outdenom_2010_9 pop_outdenom_2010_10 pop_outdenom_2010_11 pop_outdenom_2010_12
pop_cardenom_2010_1 pop_cardenom_2010_2 pop_cardenom_2010_3 pop_cardenom_2010_4 pop_cardenom_2010_5 pop_cardenom_2010_6 pop_cardenom_2010_7
pop_cardenom_2010_8 pop_cardenom_2010_9 pop_cardenom_2010_10 pop_cardenom_2010_11 pop_cardenom_2010_12

pop_INdenom_2011_1 pop_INdenom_2011_2 pop_INdenom_2011_3 pop_INdenom_2011_4 pop_INdenom_2011_5 pop_INdenom_2011_6 pop_INdenom_2011_7
pop_INdenom_2011_8 pop_INdenom_2011_9 pop_INdenom_2011_10 pop_INdenom_2011_11 pop_INdenom_2011_12
pop_outdenom_2011_1 pop_outdenom_2011_2 pop_outdenom_2011_3 pop_outdenom_2011_4 pop_outdenom_2011_5 pop_outdenom_2011_6 pop_outdenom_2011_7
pop_outdenom_2011_8 pop_outdenom_2011_9 pop_outdenom_2011_10 pop_outdenom_2011_11 pop_outdenom_2011_12
pop_cardenom_2011_1 pop_cardenom_2011_2 pop_cardenom_2011_3 pop_cardenom_2011_4 pop_cardenom_2011_5 pop_cardenom_2011_6 pop_cardenom_2011_7
pop_cardenom_2011_8 pop_cardenom_2011_9 pop_cardenom_2011_10 pop_cardenom_2011_11 pop_cardenom_2011_12

pop_INdenom_2012_1 pop_INdenom_2012_2 pop_INdenom_2012_3 pop_INdenom_2012_4 pop_INdenom_2012_5 pop_INdenom_2012_6 pop_INdenom_2012_7
pop_INdenom_2012_8 pop_INdenom_2012_9 pop_INdenom_2012_10 pop_INdenom_2012_11 pop_INdenom_2012_12
pop_outdenom_2012_1 pop_outdenom_2012_2 pop_outdenom_2012_3 pop_outdenom_2012_4 pop_outdenom_2012_5 pop_outdenom_2012_6 pop_outdenom_2012_7
pop_outdenom_2012_8 pop_outdenom_2012_9 pop_outdenom_2012_10 pop_outdenom_2012_11 pop_outdenom_2012_12
pop_cardenom_2012_1 pop_cardenom_2012_2 pop_cardenom_2012_3 pop_cardenom_2012_4 pop_cardenom_2012_5 pop_cardenom_2012_6 pop_cardenom_2012_7
pop_cardenom_2012_8 pop_cardenom_2012_9 pop_cardenom_2012_10 pop_cardenom_2012_11 pop_cardenom_2012_12

pop_INdenom_2013_1 pop_INdenom_2013_2 pop_INdenom_2013_3 pop_INdenom_2013_4 pop_INdenom_2013_5 pop_INdenom_2013_6 pop_INdenom_2013_7
pop_INdenom_2013_8 pop_INdenom_2013_9 pop_INdenom_2013_10 pop_INdenom_2013_11 pop_INdenom_2013_12
pop_outdenom_2013_1 pop_outdenom_2013_2 pop_outdenom_2013_3 pop_outdenom_2013_4 pop_outdenom_2013_5 pop_outdenom_2013_6 pop_outdenom_2013_7
pop_outdenom_2013_8 pop_outdenom_2013_9 pop_outdenom_2013_10 pop_outdenom_2013_11 pop_outdenom_2013_12
pop_cardenom_2013_1 pop_cardenom_2013_2 pop_cardenom_2013_3 pop_cardenom_2013_4 pop_cardenom_2013_5 pop_cardenom_2013_6 pop_cardenom_2013_7
pop_cardenom_2013_8 pop_cardenom_2013_9 pop_cardenom_2013_10 pop_cardenom_2013_11 pop_cardenom_2013_12

pop_INdenom_2014_1 pop_INdenom_2014_2 pop_INdenom_2014_3 pop_INdenom_2014_4 pop_INdenom_2014_5 pop_INdenom_2014_6 pop_INdenom_2014_7
pop_INdenom_2014_8 pop_INdenom_2014_9 pop_INdenom_2014_10 pop_INdenom_2014_11 pop_INdenom_2014_12
pop_outdenom_2014_1 pop_outdenom_2014_2 pop_outdenom_2014_3 pop_outdenom_2014_4 pop_outdenom_2014_5 pop_outdenom_2014_6 pop_outdenom_2014_7
pop_outdenom_2014_8 pop_outdenom_2014_9 pop_outdenom_2014_10 pop_outdenom_2014_11 pop_outdenom_2014_12
pop_cardenom_2014_1 pop_cardenom_2014_2 pop_cardenom_2014_3 pop_cardenom_2014_4 pop_cardenom_2014_5 pop_cardenom_2014_6 pop_cardenom_2014_7
pop_cardenom_2014_8 pop_cardenom_2014_9 pop_cardenom_2014_10 pop_cardenom_2014_11 pop_cardenom_2014_12

pop_INdenom_2015_1 pop_INdenom_2015_2 pop_INdenom_2015_3 pop_INdenom_2015_4 pop_INdenom_2015_5 pop_INdenom_2015_6 pop_INdenom_2015_7
pop_INdenom_2015_8 pop_INdenom_2015_9 pop_INdenom_2015_10 pop_INdenom_2015_11 pop_INdenom_2015_12
pop_outdenom_2015_1 pop_outdenom_2015_2 pop_outdenom_2015_3 pop_outdenom_2015_4 pop_outdenom_2015_5 pop_outdenom_2015_6 pop_outdenom_2015_7
pop_outdenom_2015_8 pop_outdenom_2015_9 pop_outdenom_2015_10 pop_outdenom_2015_11 pop_outdenom_2015_12
pop_cardenom_2015_1 pop_cardenom_2015_2 pop_cardenom_2015_3 pop_cardenom_2015_4 pop_cardenom_2015_5 pop_cardenom_2015_6 pop_cardenom_2015_7
pop_cardenom_2015_8 pop_cardenom_2015_9 pop_cardenom_2015_10 pop_cardenom_2015_11 pop_cardenom_2015_12

pop_INdenom_2016_1 pop_INdenom_2016_2 pop_INdenom_2016_3 pop_INdenom_2016_4 pop_INdenom_2016_5 pop_INdenom_2016_6 pop_INdenom_2016_7
pop_INdenom_2016_8 pop_INdenom_2016_9 pop_INdenom_2016_10 pop_INdenom_2016_11 pop_INdenom_2016_12
pop_outdenom_2016_1 pop_outdenom_2016_2 pop_outdenom_2016_3 pop_outdenom_2016_4 pop_outdenom_2016_5 pop_outdenom_2016_6 pop_outdenom_2016_7
pop_outdenom_2016_8 pop_outdenom_2016_9 pop_outdenom_2016_10 pop_outdenom_2016_11 pop_outdenom_2016_12
pop_cardenom_2016_1 pop_cardenom_2016_2 pop_cardenom_2016_3 pop_cardenom_2016_4 pop_cardenom_2016_5 pop_cardenom_2016_6 pop_cardenom_2016_7
pop_cardenom_2016_8 pop_cardenom_2016_9 pop_cardenom_2016_10 pop_cardenom_2016_11 pop_cardenom_2016_12

pop_INdenom_2017_1 pop_INdenom_2017_2 pop_INdenom_2017_3 pop_INdenom_2017_4 pop_INdenom_2017_5 pop_INdenom_2017_6 pop_INdenom_2017_7
pop_INdenom_2017_8 pop_INdenom_2017_9 pop_INdenom_2017_10 pop_INdenom_2017_11 pop_INdenom_2017_12
pop_outdenom_2017_1 pop_outdenom_2017_2 pop_outdenom_2017_3 pop_outdenom_2017_4 pop_outdenom_2017_5 pop_outdenom_2017_6 pop_outdenom_2017_7
pop_outdenom_2017_8 pop_outdenom_2017_9 pop_outdenom_2017_10 pop_outdenom_2017_11 pop_outdenom_2017_12
pop_cardenom_2017_1 pop_cardenom_2017_2 pop_cardenom_2017_3 pop_cardenom_2017_4 pop_cardenom_2017_5 pop_cardenom_2017_6 pop_cardenom_2017_7
pop_cardenom_2017_8 pop_cardenom_2017_9 pop_cardenom_2017_10 pop_cardenom_2017_11 pop_cardenom_2017_12

pop_INdenom_2018_1 pop_INdenom_2018_2 pop_INdenom_2018_3 pop_INdenom_2018_4 pop_INdenom_2018_5 pop_INdenom_2018_6 pop_INdenom_2018_7
pop_INdenom_2018_8 pop_INdenom_2018_9 pop_INdenom_2018_10 pop_INdenom_2018_11 pop_INdenom_2018_12
pop_outdenom_2018_1 pop_outdenom_2018_2 pop_outdenom_2018_3 pop_outdenom_2018_4 pop_outdenom_2018_5 pop_outdenom_2018_6 pop_outdenom_2018_7
pop_outdenom_2018_8 pop_outdenom_2018_9 pop_outdenom_2018_10 pop_outdenom_2018_11 pop_outdenom_2018_12
pop_cardenom_2018_1 pop_cardenom_2018_2 pop_cardenom_2018_3 pop_cardenom_2018_4 pop_cardenom_2018_5 pop_cardenom_2018_6 pop_cardenom_2018_7
pop_cardenom_2018_8 pop_cardenom_2018_9 pop_cardenom_2018_10 pop_cardenom_2018_11 pop_cardenom_2018_12
;
run;*52,725,065;
proc sort data=pop_denom NODUPKEY;by bene_id pop_elig_dt;run;*48,371,873;
proc freq data=pop_denom; table pop_nch_clm_type_cd; run;*most are  physician claims;


*Numerator: had procedure on same day as sinusitis;
%macro claims_rev(source=, rev_cohort=, include_cohort=);
proc sql;
create table include_cohort1 (compress=yes) as
select a.*, b.pop_elig_dt
from 
&rev_cohort a,
pop_denom b
where 
a.bene_id=b.bene_id and a.hcpcs_cd in (&hcpcs) and a.clm_thru_dt=b.pop_elig_dt;*consider making range of days if expand beyond hcpcs...;
quit;
proc sql;
create table include_cohort2 (compress=yes) as
select *
from 
include_cohort1 a, 
&source b
where 
a.bene_id=b.bene_id and a.clm_id=b.clm_id;		
quit;
Data &include_cohort (keep=bene_id pop_elig_dt popped_dt popped_hcpcs_cd); 
set include_cohort2;   
popped_dt=clm_thru_dt;  			label popped_dt='date popped';
popped_hcpcs_cd=put(hcpcs_cd,$hcpcs.); label popped_hcpcs_cd='hcpcs code associated with procedure';
run; 
%mend;
%claims_rev(source=rif2010.inpatient_claims_01, rev_cohort=rif2010.inpatient_revenue_01, include_cohort=pop_innum_2010_1);
%claims_rev(source=rif2010.inpatient_claims_02, rev_cohort=rif2010.inpatient_revenue_02, include_cohort=pop_innum_2010_2);
%claims_rev(source=rif2010.inpatient_claims_03, rev_cohort=rif2010.inpatient_revenue_03, include_cohort=pop_innum_2010_3);
%claims_rev(source=rif2010.inpatient_claims_04, rev_cohort=rif2010.inpatient_revenue_04, include_cohort=pop_innum_2010_4);
%claims_rev(source=rif2010.inpatient_claims_05, rev_cohort=rif2010.inpatient_revenue_05, include_cohort=pop_innum_2010_5);
%claims_rev(source=rif2010.inpatient_claims_06, rev_cohort=rif2010.inpatient_revenue_06, include_cohort=pop_innum_2010_6);
%claims_rev(source=rif2010.inpatient_claims_07, rev_cohort=rif2010.inpatient_revenue_07, include_cohort=pop_innum_2010_7);
%claims_rev(source=rif2010.inpatient_claims_08, rev_cohort=rif2010.inpatient_revenue_08, include_cohort=pop_innum_2010_8);
%claims_rev(source=rif2010.inpatient_claims_09, rev_cohort=rif2010.inpatient_revenue_09, include_cohort=pop_innum_2010_9);
%claims_rev(source=rif2010.inpatient_claims_10, rev_cohort=rif2010.inpatient_revenue_10, include_cohort=pop_innum_2010_10);
%claims_rev(source=rif2010.inpatient_claims_11, rev_cohort=rif2010.inpatient_revenue_11, include_cohort=pop_innum_2010_11);
%claims_rev(source=rif2010.inpatient_claims_12, rev_cohort=rif2010.inpatient_revenue_12, include_cohort=pop_innum_2010_12);
%claims_rev(source=rif2011.inpatient_claims_01, rev_cohort=rif2011.inpatient_revenue_01, include_cohort=pop_innum_2011_1);
%claims_rev(source=rif2011.inpatient_claims_02, rev_cohort=rif2011.inpatient_revenue_02, include_cohort=pop_innum_2011_2);
%claims_rev(source=rif2011.inpatient_claims_03, rev_cohort=rif2011.inpatient_revenue_03, include_cohort=pop_innum_2011_3);
%claims_rev(source=rif2011.inpatient_claims_04, rev_cohort=rif2011.inpatient_revenue_04, include_cohort=pop_innum_2011_4);
%claims_rev(source=rif2011.inpatient_claims_05, rev_cohort=rif2011.inpatient_revenue_05, include_cohort=pop_innum_2011_5);
%claims_rev(source=rif2011.inpatient_claims_06, rev_cohort=rif2011.inpatient_revenue_06, include_cohort=pop_innum_2011_6);
%claims_rev(source=rif2011.inpatient_claims_07, rev_cohort=rif2011.inpatient_revenue_07, include_cohort=pop_innum_2011_7);
%claims_rev(source=rif2011.inpatient_claims_08, rev_cohort=rif2011.inpatient_revenue_08, include_cohort=pop_innum_2011_8);
%claims_rev(source=rif2011.inpatient_claims_09, rev_cohort=rif2011.inpatient_revenue_09, include_cohort=pop_innum_2011_9);
%claims_rev(source=rif2011.inpatient_claims_10, rev_cohort=rif2011.inpatient_revenue_10, include_cohort=pop_innum_2011_10);
%claims_rev(source=rif2011.inpatient_claims_11, rev_cohort=rif2011.inpatient_revenue_11, include_cohort=pop_innum_2011_11);
%claims_rev(source=rif2011.inpatient_claims_12, rev_cohort=rif2011.inpatient_revenue_12, include_cohort=pop_innum_2011_12);
%claims_rev(source=rif2012.inpatient_claims_01, rev_cohort=rif2012.inpatient_revenue_01, include_cohort=pop_innum_2012_1);
%claims_rev(source=rif2012.inpatient_claims_02, rev_cohort=rif2012.inpatient_revenue_02, include_cohort=pop_innum_2012_2);
%claims_rev(source=rif2012.inpatient_claims_03, rev_cohort=rif2012.inpatient_revenue_03, include_cohort=pop_innum_2012_3);
%claims_rev(source=rif2012.inpatient_claims_04, rev_cohort=rif2012.inpatient_revenue_04, include_cohort=pop_innum_2012_4);
%claims_rev(source=rif2012.inpatient_claims_05, rev_cohort=rif2012.inpatient_revenue_05, include_cohort=pop_innum_2012_5);
%claims_rev(source=rif2012.inpatient_claims_06, rev_cohort=rif2012.inpatient_revenue_06, include_cohort=pop_innum_2012_6);
%claims_rev(source=rif2012.inpatient_claims_07, rev_cohort=rif2012.inpatient_revenue_07, include_cohort=pop_innum_2012_7);
%claims_rev(source=rif2012.inpatient_claims_08, rev_cohort=rif2012.inpatient_revenue_08, include_cohort=pop_innum_2012_8);
%claims_rev(source=rif2012.inpatient_claims_09, rev_cohort=rif2012.inpatient_revenue_09, include_cohort=pop_innum_2012_9);
%claims_rev(source=rif2012.inpatient_claims_10, rev_cohort=rif2012.inpatient_revenue_10, include_cohort=pop_innum_2012_10);
%claims_rev(source=rif2012.inpatient_claims_11, rev_cohort=rif2012.inpatient_revenue_11, include_cohort=pop_innum_2012_11);
%claims_rev(source=rif2012.inpatient_claims_12, rev_cohort=rif2012.inpatient_revenue_12, include_cohort=pop_innum_2012_12);
%claims_rev(source=rif2013.inpatient_claims_01, rev_cohort=rif2013.inpatient_revenue_01, include_cohort=pop_innum_2013_1);
%claims_rev(source=rif2013.inpatient_claims_02, rev_cohort=rif2013.inpatient_revenue_02, include_cohort=pop_innum_2013_2);
%claims_rev(source=rif2013.inpatient_claims_03, rev_cohort=rif2013.inpatient_revenue_03, include_cohort=pop_innum_2013_3);
%claims_rev(source=rif2013.inpatient_claims_04, rev_cohort=rif2013.inpatient_revenue_04, include_cohort=pop_innum_2013_4);
%claims_rev(source=rif2013.inpatient_claims_05, rev_cohort=rif2013.inpatient_revenue_05, include_cohort=pop_innum_2013_5);
%claims_rev(source=rif2013.inpatient_claims_06, rev_cohort=rif2013.inpatient_revenue_06, include_cohort=pop_innum_2013_6);
%claims_rev(source=rif2013.inpatient_claims_07, rev_cohort=rif2013.inpatient_revenue_07, include_cohort=pop_innum_2013_7);
%claims_rev(source=rif2013.inpatient_claims_08, rev_cohort=rif2013.inpatient_revenue_08, include_cohort=pop_innum_2013_8);
%claims_rev(source=rif2013.inpatient_claims_09, rev_cohort=rif2013.inpatient_revenue_09, include_cohort=pop_innum_2013_9);
%claims_rev(source=rif2013.inpatient_claims_10, rev_cohort=rif2013.inpatient_revenue_10, include_cohort=pop_innum_2013_10);
%claims_rev(source=rif2013.inpatient_claims_11, rev_cohort=rif2013.inpatient_revenue_11, include_cohort=pop_innum_2013_11);
%claims_rev(source=rif2013.inpatient_claims_12, rev_cohort=rif2013.inpatient_revenue_12, include_cohort=pop_innum_2013_12);
%claims_rev(source=rif2014.inpatient_claims_01, rev_cohort=rif2014.inpatient_revenue_01, include_cohort=pop_innum_2014_1);
%claims_rev(source=rif2014.inpatient_claims_02, rev_cohort=rif2014.inpatient_revenue_02, include_cohort=pop_innum_2014_2);
%claims_rev(source=rif2014.inpatient_claims_03, rev_cohort=rif2014.inpatient_revenue_03, include_cohort=pop_innum_2014_3);
%claims_rev(source=rif2014.inpatient_claims_04, rev_cohort=rif2014.inpatient_revenue_04, include_cohort=pop_innum_2014_4);
%claims_rev(source=rif2014.inpatient_claims_05, rev_cohort=rif2014.inpatient_revenue_05, include_cohort=pop_innum_2014_5);
%claims_rev(source=rif2014.inpatient_claims_06, rev_cohort=rif2014.inpatient_revenue_06, include_cohort=pop_innum_2014_6);
%claims_rev(source=rif2014.inpatient_claims_07, rev_cohort=rif2014.inpatient_revenue_07, include_cohort=pop_innum_2014_7);
%claims_rev(source=rif2014.inpatient_claims_08, rev_cohort=rif2014.inpatient_revenue_08, include_cohort=pop_innum_2014_8);
%claims_rev(source=rif2014.inpatient_claims_09, rev_cohort=rif2014.inpatient_revenue_09, include_cohort=pop_innum_2014_9);
%claims_rev(source=rif2014.inpatient_claims_10, rev_cohort=rif2014.inpatient_revenue_10, include_cohort=pop_innum_2014_10);
%claims_rev(source=rif2014.inpatient_claims_11, rev_cohort=rif2014.inpatient_revenue_11, include_cohort=pop_innum_2014_11);
%claims_rev(source=rif2014.inpatient_claims_12, rev_cohort=rif2014.inpatient_revenue_12, include_cohort=pop_innum_2014_12);
%claims_rev(source=rif2015.inpatient_claims_01, rev_cohort=rif2015.inpatient_revenue_01, include_cohort=pop_innum_2015_1);
%claims_rev(source=rif2015.inpatient_claims_02, rev_cohort=rif2015.inpatient_revenue_02, include_cohort=pop_innum_2015_2);
%claims_rev(source=rif2015.inpatient_claims_03, rev_cohort=rif2015.inpatient_revenue_03, include_cohort=pop_innum_2015_3);
%claims_rev(source=rif2015.inpatient_claims_04, rev_cohort=rif2015.inpatient_revenue_04, include_cohort=pop_innum_2015_4);
%claims_rev(source=rif2015.inpatient_claims_05, rev_cohort=rif2015.inpatient_revenue_05, include_cohort=pop_innum_2015_5);
%claims_rev(source=rif2015.inpatient_claims_06, rev_cohort=rif2015.inpatient_revenue_06, include_cohort=pop_innum_2015_6);
%claims_rev(source=rif2015.inpatient_claims_07, rev_cohort=rif2015.inpatient_revenue_07, include_cohort=pop_innum_2015_7);
%claims_rev(source=rif2015.inpatient_claims_08, rev_cohort=rif2015.inpatient_revenue_08, include_cohort=pop_innum_2015_8);
%claims_rev(source=rif2015.inpatient_claims_09, rev_cohort=rif2015.inpatient_revenue_09, include_cohort=pop_innum_2015_9);
%claims_rev(source=rif2015.inpatient_claims_10, rev_cohort=rif2015.inpatient_revenue_10, include_cohort=pop_innum_2015_10);
%claims_rev(source=rif2015.inpatient_claims_11, rev_cohort=rif2015.inpatient_revenue_11, include_cohort=pop_innum_2015_11);
%claims_rev(source=rif2015.inpatient_claims_12, rev_cohort=rif2015.inpatient_revenue_12, include_cohort=pop_innum_2015_12);
%claims_rev(source=rif2016.inpatient_claims_01, rev_cohort=rif2016.inpatient_revenue_01, include_cohort=pop_innum_2016_1);
%claims_rev(source=rif2016.inpatient_claims_02, rev_cohort=rif2016.inpatient_revenue_02, include_cohort=pop_innum_2016_2);
%claims_rev(source=rif2016.inpatient_claims_03, rev_cohort=rif2016.inpatient_revenue_03, include_cohort=pop_innum_2016_3);
%claims_rev(source=rif2016.inpatient_claims_04, rev_cohort=rif2016.inpatient_revenue_04, include_cohort=pop_innum_2016_4);
%claims_rev(source=rif2016.inpatient_claims_05, rev_cohort=rif2016.inpatient_revenue_05, include_cohort=pop_innum_2016_5);
%claims_rev(source=rif2016.inpatient_claims_06, rev_cohort=rif2016.inpatient_revenue_06, include_cohort=pop_innum_2016_6);
%claims_rev(source=rif2016.inpatient_claims_07, rev_cohort=rif2016.inpatient_revenue_07, include_cohort=pop_innum_2016_7);
%claims_rev(source=rif2016.inpatient_claims_08, rev_cohort=rif2016.inpatient_revenue_08, include_cohort=pop_innum_2016_8);
%claims_rev(source=rif2016.inpatient_claims_09, rev_cohort=rif2016.inpatient_revenue_09, include_cohort=pop_innum_2016_9);
%claims_rev(source=rif2016.inpatient_claims_10, rev_cohort=rif2016.inpatient_revenue_10, include_cohort=pop_innum_2016_10);
%claims_rev(source=rif2016.inpatient_claims_11, rev_cohort=rif2016.inpatient_revenue_11, include_cohort=pop_innum_2016_11);
%claims_rev(source=rif2016.inpatient_claims_12, rev_cohort=rif2016.inpatient_revenue_12, include_cohort=pop_innum_2016_12);
%claims_rev(source=rif2017.inpatient_claims_01, rev_cohort=rif2017.inpatient_revenue_01, include_cohort=pop_innum_2017_1);
%claims_rev(source=rif2017.inpatient_claims_02, rev_cohort=rif2017.inpatient_revenue_02, include_cohort=pop_innum_2017_2);
%claims_rev(source=rif2017.inpatient_claims_03, rev_cohort=rif2017.inpatient_revenue_03, include_cohort=pop_innum_2017_3);
%claims_rev(source=rif2017.inpatient_claims_04, rev_cohort=rif2017.inpatient_revenue_04, include_cohort=pop_innum_2017_4);
%claims_rev(source=rif2017.inpatient_claims_05, rev_cohort=rif2017.inpatient_revenue_05, include_cohort=pop_innum_2017_5);
%claims_rev(source=rif2017.inpatient_claims_06, rev_cohort=rif2017.inpatient_revenue_06, include_cohort=pop_innum_2017_6);
%claims_rev(source=rif2017.inpatient_claims_07, rev_cohort=rif2017.inpatient_revenue_07, include_cohort=pop_innum_2017_7);
%claims_rev(source=rif2017.inpatient_claims_08, rev_cohort=rif2017.inpatient_revenue_08, include_cohort=pop_innum_2017_8);
%claims_rev(source=rif2017.inpatient_claims_09, rev_cohort=rif2017.inpatient_revenue_09, include_cohort=pop_innum_2017_9);
%claims_rev(source=rif2017.inpatient_claims_10, rev_cohort=rif2017.inpatient_revenue_10, include_cohort=pop_innum_2017_10);
%claims_rev(source=rif2017.inpatient_claims_11, rev_cohort=rif2017.inpatient_revenue_11, include_cohort=pop_innum_2017_11);
%claims_rev(source=rif2017.inpatient_claims_12, rev_cohort=rif2017.inpatient_revenue_12, include_cohort=pop_innum_2017_12);
%claims_rev(source=rifq2018.inpatient_claims_01, rev_cohort=rifq2018.inpatient_revenue_01, include_cohort=pop_innum_2018_1);
%claims_rev(source=rifq2018.inpatient_claims_02, rev_cohort=rifq2018.inpatient_revenue_02, include_cohort=pop_innum_2018_2);
%claims_rev(source=rifq2018.inpatient_claims_03, rev_cohort=rifq2018.inpatient_revenue_03, include_cohort=pop_innum_2018_3);
%claims_rev(source=rifq2018.inpatient_claims_04, rev_cohort=rifq2018.inpatient_revenue_04, include_cohort=pop_innum_2018_4);
%claims_rev(source=rifq2018.inpatient_claims_05, rev_cohort=rifq2018.inpatient_revenue_05, include_cohort=pop_innum_2018_5);
%claims_rev(source=rifq2018.inpatient_claims_06, rev_cohort=rifq2018.inpatient_revenue_06, include_cohort=pop_innum_2018_6);
%claims_rev(source=rifq2018.inpatient_claims_07, rev_cohort=rifq2018.inpatient_revenue_07, include_cohort=pop_innum_2018_7);
%claims_rev(source=rifq2018.inpatient_claims_08, rev_cohort=rifq2018.inpatient_revenue_08, include_cohort=pop_innum_2018_8);
%claims_rev(source=rifq2018.inpatient_claims_09, rev_cohort=rifq2018.inpatient_revenue_09, include_cohort=pop_innum_2018_9);
%claims_rev(source=rifq2018.inpatient_claims_10, rev_cohort=rifq2018.inpatient_revenue_10, include_cohort=pop_innum_2018_10);
%claims_rev(source=rifq2018.inpatient_claims_11, rev_cohort=rifq2018.inpatient_revenue_11, include_cohort=pop_innum_2018_11);
%claims_rev(source=rifq2018.inpatient_claims_12, rev_cohort=rifq2018.inpatient_revenue_12, include_cohort=pop_innum_2018_12);

*outpatient and carrier;
%claims_rev(source=rif2010.outpatient_claims_01, rev_cohort=rif2010.outpatient_revenue_01, include_cohort=pop_outnum_2010_1);
%claims_rev(source=rif2010.outpatient_claims_02, rev_cohort=rif2010.outpatient_revenue_02, include_cohort=pop_outnum_2010_2);
%claims_rev(source=rif2010.outpatient_claims_03, rev_cohort=rif2010.outpatient_revenue_03, include_cohort=pop_outnum_2010_3);
%claims_rev(source=rif2010.outpatient_claims_04, rev_cohort=rif2010.outpatient_revenue_04, include_cohort=pop_outnum_2010_4);
%claims_rev(source=rif2010.outpatient_claims_05, rev_cohort=rif2010.outpatient_revenue_05, include_cohort=pop_outnum_2010_5);
%claims_rev(source=rif2010.outpatient_claims_06, rev_cohort=rif2010.outpatient_revenue_06, include_cohort=pop_outnum_2010_6);
%claims_rev(source=rif2010.outpatient_claims_07, rev_cohort=rif2010.outpatient_revenue_07, include_cohort=pop_outnum_2010_7);
%claims_rev(source=rif2010.outpatient_claims_08, rev_cohort=rif2010.outpatient_revenue_08, include_cohort=pop_outnum_2010_8);
%claims_rev(source=rif2010.outpatient_claims_09, rev_cohort=rif2010.outpatient_revenue_09, include_cohort=pop_outnum_2010_9);
%claims_rev(source=rif2010.outpatient_claims_10, rev_cohort=rif2010.outpatient_revenue_10, include_cohort=pop_outnum_2010_10);
%claims_rev(source=rif2010.outpatient_claims_11, rev_cohort=rif2010.outpatient_revenue_11, include_cohort=pop_outnum_2010_11);
%claims_rev(source=rif2010.outpatient_claims_12, rev_cohort=rif2010.outpatient_revenue_12, include_cohort=pop_outnum_2010_12);
%claims_rev(source=rif2010.bcarrier_claims_01, rev_cohort=rif2010.bcarrier_line_01, include_cohort=pop_carnum_2010_1);
%claims_rev(source=rif2010.bcarrier_claims_02, rev_cohort=rif2010.bcarrier_line_02, include_cohort=pop_carnum_2010_2);
%claims_rev(source=rif2010.bcarrier_claims_03, rev_cohort=rif2010.bcarrier_line_03, include_cohort=pop_carnum_2010_3);
%claims_rev(source=rif2010.bcarrier_claims_04, rev_cohort=rif2010.bcarrier_line_04, include_cohort=pop_carnum_2010_4);
%claims_rev(source=rif2010.bcarrier_claims_05, rev_cohort=rif2010.bcarrier_line_05, include_cohort=pop_carnum_2010_5);
%claims_rev(source=rif2010.bcarrier_claims_06, rev_cohort=rif2010.bcarrier_line_06, include_cohort=pop_carnum_2010_6);
%claims_rev(source=rif2010.bcarrier_claims_07, rev_cohort=rif2010.bcarrier_line_07, include_cohort=pop_carnum_2010_7);
%claims_rev(source=rif2010.bcarrier_claims_08, rev_cohort=rif2010.bcarrier_line_08, include_cohort=pop_carnum_2010_8);
%claims_rev(source=rif2010.bcarrier_claims_09, rev_cohort=rif2010.bcarrier_line_09, include_cohort=pop_carnum_2010_9);
%claims_rev(source=rif2010.bcarrier_claims_10, rev_cohort=rif2010.bcarrier_line_10, include_cohort=pop_carnum_2010_10);
%claims_rev(source=rif2010.bcarrier_claims_11, rev_cohort=rif2010.bcarrier_line_11, include_cohort=pop_carnum_2010_11);
%claims_rev(source=rif2010.bcarrier_claims_12, rev_cohort=rif2010.bcarrier_line_12, include_cohort=pop_carnum_2010_12);

%claims_rev(source=rif2011.outpatient_claims_01, rev_cohort=rif2011.outpatient_revenue_01, include_cohort=pop_outnum_2011_1);
%claims_rev(source=rif2011.outpatient_claims_02, rev_cohort=rif2011.outpatient_revenue_02, include_cohort=pop_outnum_2011_2);
%claims_rev(source=rif2011.outpatient_claims_03, rev_cohort=rif2011.outpatient_revenue_03, include_cohort=pop_outnum_2011_3);
%claims_rev(source=rif2011.outpatient_claims_04, rev_cohort=rif2011.outpatient_revenue_04, include_cohort=pop_outnum_2011_4);
%claims_rev(source=rif2011.outpatient_claims_05, rev_cohort=rif2011.outpatient_revenue_05, include_cohort=pop_outnum_2011_5);
%claims_rev(source=rif2011.outpatient_claims_06, rev_cohort=rif2011.outpatient_revenue_06, include_cohort=pop_outnum_2011_6);
%claims_rev(source=rif2011.outpatient_claims_07, rev_cohort=rif2011.outpatient_revenue_07, include_cohort=pop_outnum_2011_7);
%claims_rev(source=rif2011.outpatient_claims_08, rev_cohort=rif2011.outpatient_revenue_08, include_cohort=pop_outnum_2011_8);
%claims_rev(source=rif2011.outpatient_claims_09, rev_cohort=rif2011.outpatient_revenue_09, include_cohort=pop_outnum_2011_9);
%claims_rev(source=rif2011.outpatient_claims_10, rev_cohort=rif2011.outpatient_revenue_10, include_cohort=pop_outnum_2011_10);
%claims_rev(source=rif2011.outpatient_claims_11, rev_cohort=rif2011.outpatient_revenue_11, include_cohort=pop_outnum_2011_11);
%claims_rev(source=rif2011.outpatient_claims_12, rev_cohort=rif2011.outpatient_revenue_12, include_cohort=pop_outnum_2011_12);
%claims_rev(source=rif2011.bcarrier_claims_01, rev_cohort=rif2011.bcarrier_line_01, include_cohort=pop_carnum_2011_1);
%claims_rev(source=rif2011.bcarrier_claims_02, rev_cohort=rif2011.bcarrier_line_02, include_cohort=pop_carnum_2011_2);
%claims_rev(source=rif2011.bcarrier_claims_03, rev_cohort=rif2011.bcarrier_line_03, include_cohort=pop_carnum_2011_3);
%claims_rev(source=rif2011.bcarrier_claims_04, rev_cohort=rif2011.bcarrier_line_04, include_cohort=pop_carnum_2011_4);
%claims_rev(source=rif2011.bcarrier_claims_05, rev_cohort=rif2011.bcarrier_line_05, include_cohort=pop_carnum_2011_5);
%claims_rev(source=rif2011.bcarrier_claims_06, rev_cohort=rif2011.bcarrier_line_06, include_cohort=pop_carnum_2011_6);
%claims_rev(source=rif2011.bcarrier_claims_07, rev_cohort=rif2011.bcarrier_line_07, include_cohort=pop_carnum_2011_7);
%claims_rev(source=rif2011.bcarrier_claims_08, rev_cohort=rif2011.bcarrier_line_08, include_cohort=pop_carnum_2011_8);
%claims_rev(source=rif2011.bcarrier_claims_09, rev_cohort=rif2011.bcarrier_line_09, include_cohort=pop_carnum_2011_9);
%claims_rev(source=rif2011.bcarrier_claims_10, rev_cohort=rif2011.bcarrier_line_10, include_cohort=pop_carnum_2011_10);
%claims_rev(source=rif2011.bcarrier_claims_11, rev_cohort=rif2011.bcarrier_line_11, include_cohort=pop_carnum_2011_11);
%claims_rev(source=rif2011.bcarrier_claims_12, rev_cohort=rif2011.bcarrier_line_12, include_cohort=pop_carnum_2011_12);

%claims_rev(source=rif2012.outpatient_claims_01, rev_cohort=rif2012.outpatient_revenue_01, include_cohort=pop_outnum_2012_1);
%claims_rev(source=rif2012.outpatient_claims_02, rev_cohort=rif2012.outpatient_revenue_02, include_cohort=pop_outnum_2012_2);
%claims_rev(source=rif2012.outpatient_claims_03, rev_cohort=rif2012.outpatient_revenue_03, include_cohort=pop_outnum_2012_3);
%claims_rev(source=rif2012.outpatient_claims_04, rev_cohort=rif2012.outpatient_revenue_04, include_cohort=pop_outnum_2012_4);
%claims_rev(source=rif2012.outpatient_claims_05, rev_cohort=rif2012.outpatient_revenue_05, include_cohort=pop_outnum_2012_5);
%claims_rev(source=rif2012.outpatient_claims_06, rev_cohort=rif2012.outpatient_revenue_06, include_cohort=pop_outnum_2012_6);
%claims_rev(source=rif2012.outpatient_claims_07, rev_cohort=rif2012.outpatient_revenue_07, include_cohort=pop_outnum_2012_7);
%claims_rev(source=rif2012.outpatient_claims_08, rev_cohort=rif2012.outpatient_revenue_08, include_cohort=pop_outnum_2012_8);
%claims_rev(source=rif2012.outpatient_claims_09, rev_cohort=rif2012.outpatient_revenue_09, include_cohort=pop_outnum_2012_9);
%claims_rev(source=rif2012.outpatient_claims_10, rev_cohort=rif2012.outpatient_revenue_10, include_cohort=pop_outnum_2012_10);
%claims_rev(source=rif2012.outpatient_claims_11, rev_cohort=rif2012.outpatient_revenue_11, include_cohort=pop_outnum_2012_11);
%claims_rev(source=rif2012.outpatient_claims_12, rev_cohort=rif2012.outpatient_revenue_12, include_cohort=pop_outnum_2012_12);
%claims_rev(source=rif2012.bcarrier_claims_01, rev_cohort=rif2012.bcarrier_line_01, include_cohort=pop_carnum_2012_1);
%claims_rev(source=rif2012.bcarrier_claims_02, rev_cohort=rif2012.bcarrier_line_02, include_cohort=pop_carnum_2012_2);
%claims_rev(source=rif2012.bcarrier_claims_03, rev_cohort=rif2012.bcarrier_line_03, include_cohort=pop_carnum_2012_3);
%claims_rev(source=rif2012.bcarrier_claims_04, rev_cohort=rif2012.bcarrier_line_04, include_cohort=pop_carnum_2012_4);
%claims_rev(source=rif2012.bcarrier_claims_05, rev_cohort=rif2012.bcarrier_line_05, include_cohort=pop_carnum_2012_5);
%claims_rev(source=rif2012.bcarrier_claims_06, rev_cohort=rif2012.bcarrier_line_06, include_cohort=pop_carnum_2012_6);
%claims_rev(source=rif2012.bcarrier_claims_07, rev_cohort=rif2012.bcarrier_line_07, include_cohort=pop_carnum_2012_7);
%claims_rev(source=rif2012.bcarrier_claims_08, rev_cohort=rif2012.bcarrier_line_08, include_cohort=pop_carnum_2012_8);
%claims_rev(source=rif2012.bcarrier_claims_09, rev_cohort=rif2012.bcarrier_line_09, include_cohort=pop_carnum_2012_9);
%claims_rev(source=rif2012.bcarrier_claims_10, rev_cohort=rif2012.bcarrier_line_10, include_cohort=pop_carnum_2012_10);
%claims_rev(source=rif2012.bcarrier_claims_11, rev_cohort=rif2012.bcarrier_line_11, include_cohort=pop_carnum_2012_11);
%claims_rev(source=rif2012.bcarrier_claims_12, rev_cohort=rif2012.bcarrier_line_12, include_cohort=pop_carnum_2012_12);

%claims_rev(source=rif2013.outpatient_claims_01, rev_cohort=rif2013.outpatient_revenue_01, include_cohort=pop_outnum_2013_1);
%claims_rev(source=rif2013.outpatient_claims_02, rev_cohort=rif2013.outpatient_revenue_02, include_cohort=pop_outnum_2013_2);
%claims_rev(source=rif2013.outpatient_claims_03, rev_cohort=rif2013.outpatient_revenue_03, include_cohort=pop_outnum_2013_3);
%claims_rev(source=rif2013.outpatient_claims_04, rev_cohort=rif2013.outpatient_revenue_04, include_cohort=pop_outnum_2013_4);
%claims_rev(source=rif2013.outpatient_claims_05, rev_cohort=rif2013.outpatient_revenue_05, include_cohort=pop_outnum_2013_5);
%claims_rev(source=rif2013.outpatient_claims_06, rev_cohort=rif2013.outpatient_revenue_06, include_cohort=pop_outnum_2013_6);
%claims_rev(source=rif2013.outpatient_claims_07, rev_cohort=rif2013.outpatient_revenue_07, include_cohort=pop_outnum_2013_7);
%claims_rev(source=rif2013.outpatient_claims_08, rev_cohort=rif2013.outpatient_revenue_08, include_cohort=pop_outnum_2013_8);
%claims_rev(source=rif2013.outpatient_claims_09, rev_cohort=rif2013.outpatient_revenue_09, include_cohort=pop_outnum_2013_9);
%claims_rev(source=rif2013.outpatient_claims_10, rev_cohort=rif2013.outpatient_revenue_10, include_cohort=pop_outnum_2013_10);
%claims_rev(source=rif2013.outpatient_claims_11, rev_cohort=rif2013.outpatient_revenue_11, include_cohort=pop_outnum_2013_11);
%claims_rev(source=rif2013.outpatient_claims_12, rev_cohort=rif2013.outpatient_revenue_12, include_cohort=pop_outnum_2013_12);

%claims_rev(source=rif2013.bcarrier_claims_01, rev_cohort=rif2013.bcarrier_line_01, include_cohort=pop_carnum_2013_1);
%claims_rev(source=rif2013.bcarrier_claims_02, rev_cohort=rif2013.bcarrier_line_02, include_cohort=pop_carnum_2013_2);
%claims_rev(source=rif2013.bcarrier_claims_03, rev_cohort=rif2013.bcarrier_line_03, include_cohort=pop_carnum_2013_3);
%claims_rev(source=rif2013.bcarrier_claims_04, rev_cohort=rif2013.bcarrier_line_04, include_cohort=pop_carnum_2013_4);
%claims_rev(source=rif2013.bcarrier_claims_05, rev_cohort=rif2013.bcarrier_line_05, include_cohort=pop_carnum_2013_5);
%claims_rev(source=rif2013.bcarrier_claims_06, rev_cohort=rif2013.bcarrier_line_06, include_cohort=pop_carnum_2013_6);
%claims_rev(source=rif2013.bcarrier_claims_07, rev_cohort=rif2013.bcarrier_line_07, include_cohort=pop_carnum_2013_7);
%claims_rev(source=rif2013.bcarrier_claims_08, rev_cohort=rif2013.bcarrier_line_08, include_cohort=pop_carnum_2013_8);
%claims_rev(source=rif2013.bcarrier_claims_09, rev_cohort=rif2013.bcarrier_line_09, include_cohort=pop_carnum_2013_9);
%claims_rev(source=rif2013.bcarrier_claims_10, rev_cohort=rif2013.bcarrier_line_10, include_cohort=pop_carnum_2013_10);
%claims_rev(source=rif2013.bcarrier_claims_11, rev_cohort=rif2013.bcarrier_line_11, include_cohort=pop_carnum_2013_11);
%claims_rev(source=rif2013.bcarrier_claims_12, rev_cohort=rif2013.bcarrier_line_12, include_cohort=pop_carnum_2013_12);

%claims_rev(source=rif2014.outpatient_claims_01, rev_cohort=rif2014.outpatient_revenue_01, include_cohort=pop_outnum_2014_1);
%claims_rev(source=rif2014.outpatient_claims_02, rev_cohort=rif2014.outpatient_revenue_02, include_cohort=pop_outnum_2014_2);
%claims_rev(source=rif2014.outpatient_claims_03, rev_cohort=rif2014.outpatient_revenue_03, include_cohort=pop_outnum_2014_3);
%claims_rev(source=rif2014.outpatient_claims_04, rev_cohort=rif2014.outpatient_revenue_04, include_cohort=pop_outnum_2014_4);
%claims_rev(source=rif2014.outpatient_claims_05, rev_cohort=rif2014.outpatient_revenue_05, include_cohort=pop_outnum_2014_5);
%claims_rev(source=rif2014.outpatient_claims_06, rev_cohort=rif2014.outpatient_revenue_06, include_cohort=pop_outnum_2014_6);
%claims_rev(source=rif2014.outpatient_claims_07, rev_cohort=rif2014.outpatient_revenue_07, include_cohort=pop_outnum_2014_7);
%claims_rev(source=rif2014.outpatient_claims_08, rev_cohort=rif2014.outpatient_revenue_08, include_cohort=pop_outnum_2014_8);
%claims_rev(source=rif2014.outpatient_claims_09, rev_cohort=rif2014.outpatient_revenue_09, include_cohort=pop_outnum_2014_9);
%claims_rev(source=rif2014.outpatient_claims_10, rev_cohort=rif2014.outpatient_revenue_10, include_cohort=pop_outnum_2014_10);
%claims_rev(source=rif2014.outpatient_claims_11, rev_cohort=rif2014.outpatient_revenue_11, include_cohort=pop_outnum_2014_11);
%claims_rev(source=rif2014.outpatient_claims_12, rev_cohort=rif2014.outpatient_revenue_12, include_cohort=pop_outnum_2014_12);

%claims_rev(source=rif2014.bcarrier_claims_01, rev_cohort=rif2014.bcarrier_line_01, include_cohort=pop_carnum_2014_1);
%claims_rev(source=rif2014.bcarrier_claims_02, rev_cohort=rif2014.bcarrier_line_02, include_cohort=pop_carnum_2014_2);
%claims_rev(source=rif2014.bcarrier_claims_03, rev_cohort=rif2014.bcarrier_line_03, include_cohort=pop_carnum_2014_3);
%claims_rev(source=rif2014.bcarrier_claims_04, rev_cohort=rif2014.bcarrier_line_04, include_cohort=pop_carnum_2014_4);
%claims_rev(source=rif2014.bcarrier_claims_05, rev_cohort=rif2014.bcarrier_line_05, include_cohort=pop_carnum_2014_5);
%claims_rev(source=rif2014.bcarrier_claims_06, rev_cohort=rif2014.bcarrier_line_06, include_cohort=pop_carnum_2014_6);
%claims_rev(source=rif2014.bcarrier_claims_07, rev_cohort=rif2014.bcarrier_line_07, include_cohort=pop_carnum_2014_7);
%claims_rev(source=rif2014.bcarrier_claims_08, rev_cohort=rif2014.bcarrier_line_08, include_cohort=pop_carnum_2014_8);
%claims_rev(source=rif2014.bcarrier_claims_09, rev_cohort=rif2014.bcarrier_line_09, include_cohort=pop_carnum_2014_9);
%claims_rev(source=rif2014.bcarrier_claims_10, rev_cohort=rif2014.bcarrier_line_10, include_cohort=pop_carnum_2014_10);
%claims_rev(source=rif2014.bcarrier_claims_11, rev_cohort=rif2014.bcarrier_line_11, include_cohort=pop_carnum_2014_11);
%claims_rev(source=rif2014.bcarrier_claims_12, rev_cohort=rif2014.bcarrier_line_12, include_cohort=pop_carnum_2014_12);

%claims_rev(source=rif2015.outpatient_claims_01, rev_cohort=rif2015.outpatient_revenue_01, include_cohort=pop_outnum_2015_1);
%claims_rev(source=rif2015.outpatient_claims_02, rev_cohort=rif2015.outpatient_revenue_02, include_cohort=pop_outnum_2015_2);
%claims_rev(source=rif2015.outpatient_claims_03, rev_cohort=rif2015.outpatient_revenue_03, include_cohort=pop_outnum_2015_3);
%claims_rev(source=rif2015.outpatient_claims_04, rev_cohort=rif2015.outpatient_revenue_04, include_cohort=pop_outnum_2015_4);
%claims_rev(source=rif2015.outpatient_claims_05, rev_cohort=rif2015.outpatient_revenue_05, include_cohort=pop_outnum_2015_5);
%claims_rev(source=rif2015.outpatient_claims_06, rev_cohort=rif2015.outpatient_revenue_06, include_cohort=pop_outnum_2015_6);
%claims_rev(source=rif2015.outpatient_claims_07, rev_cohort=rif2015.outpatient_revenue_07, include_cohort=pop_outnum_2015_7);
%claims_rev(source=rif2015.outpatient_claims_08, rev_cohort=rif2015.outpatient_revenue_08, include_cohort=pop_outnum_2015_8);
%claims_rev(source=rif2015.outpatient_claims_09, rev_cohort=rif2015.outpatient_revenue_09, include_cohort=pop_outnum_2015_9);
%claims_rev(source=rif2015.outpatient_claims_10, rev_cohort=rif2015.outpatient_revenue_10, include_cohort=pop_outnum_2015_10);
%claims_rev(source=rif2015.outpatient_claims_11, rev_cohort=rif2015.outpatient_revenue_11, include_cohort=pop_outnum_2015_11);
%claims_rev(source=rif2015.outpatient_claims_12, rev_cohort=rif2015.outpatient_revenue_12, include_cohort=pop_outnum_2015_12);

%claims_rev(source=rif2015.bcarrier_claims_01, rev_cohort=rif2015.bcarrier_line_01, include_cohort=pop_carnum_2015_1);
%claims_rev(source=rif2015.bcarrier_claims_02, rev_cohort=rif2015.bcarrier_line_02, include_cohort=pop_carnum_2015_2);
%claims_rev(source=rif2015.bcarrier_claims_03, rev_cohort=rif2015.bcarrier_line_03, include_cohort=pop_carnum_2015_3);
%claims_rev(source=rif2015.bcarrier_claims_04, rev_cohort=rif2015.bcarrier_line_04, include_cohort=pop_carnum_2015_4);
%claims_rev(source=rif2015.bcarrier_claims_05, rev_cohort=rif2015.bcarrier_line_05, include_cohort=pop_carnum_2015_5);
%claims_rev(source=rif2015.bcarrier_claims_06, rev_cohort=rif2015.bcarrier_line_06, include_cohort=pop_carnum_2015_6);
%claims_rev(source=rif2015.bcarrier_claims_07, rev_cohort=rif2015.bcarrier_line_07, include_cohort=pop_carnum_2015_7);
%claims_rev(source=rif2015.bcarrier_claims_08, rev_cohort=rif2015.bcarrier_line_08, include_cohort=pop_carnum_2015_8);
%claims_rev(source=rif2015.bcarrier_claims_09, rev_cohort=rif2015.bcarrier_line_09, include_cohort=pop_carnum_2015_9);
%claims_rev(source=rif2015.bcarrier_claims_10, rev_cohort=rif2015.bcarrier_line_10, include_cohort=pop_carnum_2015_10);
%claims_rev(source=rif2015.bcarrier_claims_11, rev_cohort=rif2015.bcarrier_line_11, include_cohort=pop_carnum_2015_11);
%claims_rev(source=rif2015.bcarrier_claims_12, rev_cohort=rif2015.bcarrier_line_12, include_cohort=pop_carnum_2015_12);

%claims_rev(source=rif2016.outpatient_claims_01, rev_cohort=rif2016.outpatient_revenue_01, include_cohort=pop_outnum_2016_1);
%claims_rev(source=rif2016.outpatient_claims_02, rev_cohort=rif2016.outpatient_revenue_02, include_cohort=pop_outnum_2016_2);
%claims_rev(source=rif2016.outpatient_claims_03, rev_cohort=rif2016.outpatient_revenue_03, include_cohort=pop_outnum_2016_3);
%claims_rev(source=rif2016.outpatient_claims_04, rev_cohort=rif2016.outpatient_revenue_04, include_cohort=pop_outnum_2016_4);
%claims_rev(source=rif2016.outpatient_claims_05, rev_cohort=rif2016.outpatient_revenue_05, include_cohort=pop_outnum_2016_5);
%claims_rev(source=rif2016.outpatient_claims_06, rev_cohort=rif2016.outpatient_revenue_06, include_cohort=pop_outnum_2016_6);
%claims_rev(source=rif2016.outpatient_claims_07, rev_cohort=rif2016.outpatient_revenue_07, include_cohort=pop_outnum_2016_7);
%claims_rev(source=rif2016.outpatient_claims_08, rev_cohort=rif2016.outpatient_revenue_08, include_cohort=pop_outnum_2016_8);
%claims_rev(source=rif2016.outpatient_claims_09, rev_cohort=rif2016.outpatient_revenue_09, include_cohort=pop_outnum_2016_9);
%claims_rev(source=rif2016.outpatient_claims_10, rev_cohort=rif2016.outpatient_revenue_10, include_cohort=pop_outnum_2016_10);
%claims_rev(source=rif2016.outpatient_claims_11, rev_cohort=rif2016.outpatient_revenue_11, include_cohort=pop_outnum_2016_11);
%claims_rev(source=rif2016.outpatient_claims_12, rev_cohort=rif2016.outpatient_revenue_12, include_cohort=pop_outnum_2016_12);

%claims_rev(source=rif2016.bcarrier_claims_01, rev_cohort=rif2016.bcarrier_line_01, include_cohort=pop_carnum_2016_1);
%claims_rev(source=rif2016.bcarrier_claims_02, rev_cohort=rif2016.bcarrier_line_02, include_cohort=pop_carnum_2016_2);
%claims_rev(source=rif2016.bcarrier_claims_03, rev_cohort=rif2016.bcarrier_line_03, include_cohort=pop_carnum_2016_3);
%claims_rev(source=rif2016.bcarrier_claims_04, rev_cohort=rif2016.bcarrier_line_04, include_cohort=pop_carnum_2016_4);
%claims_rev(source=rif2016.bcarrier_claims_05, rev_cohort=rif2016.bcarrier_line_05, include_cohort=pop_carnum_2016_5);
%claims_rev(source=rif2016.bcarrier_claims_06, rev_cohort=rif2016.bcarrier_line_06, include_cohort=pop_carnum_2016_6);
%claims_rev(source=rif2016.bcarrier_claims_07, rev_cohort=rif2016.bcarrier_line_07, include_cohort=pop_carnum_2016_7);
%claims_rev(source=rif2016.bcarrier_claims_08, rev_cohort=rif2016.bcarrier_line_08, include_cohort=pop_carnum_2016_8);
%claims_rev(source=rif2016.bcarrier_claims_09, rev_cohort=rif2016.bcarrier_line_09, include_cohort=pop_carnum_2016_9);
%claims_rev(source=rif2016.bcarrier_claims_10, rev_cohort=rif2016.bcarrier_line_10, include_cohort=pop_carnum_2016_10);
%claims_rev(source=rif2016.bcarrier_claims_11, rev_cohort=rif2016.bcarrier_line_11, include_cohort=pop_carnum_2016_11);
%claims_rev(source=rif2016.bcarrier_claims_12, rev_cohort=rif2016.bcarrier_line_12, include_cohort=pop_carnum_2016_12);

%claims_rev(source=rif2017.outpatient_claims_01, rev_cohort=rif2017.outpatient_revenue_01, include_cohort=pop_outnum_2017_1);
%claims_rev(source=rif2017.outpatient_claims_02, rev_cohort=rif2017.outpatient_revenue_02, include_cohort=pop_outnum_2017_2);
%claims_rev(source=rif2017.outpatient_claims_03, rev_cohort=rif2017.outpatient_revenue_03, include_cohort=pop_outnum_2017_3);
%claims_rev(source=rif2017.outpatient_claims_04, rev_cohort=rif2017.outpatient_revenue_04, include_cohort=pop_outnum_2017_4);
%claims_rev(source=rif2017.outpatient_claims_05, rev_cohort=rif2017.outpatient_revenue_05, include_cohort=pop_outnum_2017_5);
%claims_rev(source=rif2017.outpatient_claims_06, rev_cohort=rif2017.outpatient_revenue_06, include_cohort=pop_outnum_2017_6);
%claims_rev(source=rif2017.outpatient_claims_07, rev_cohort=rif2017.outpatient_revenue_07, include_cohort=pop_outnum_2017_7);
%claims_rev(source=rif2017.outpatient_claims_08, rev_cohort=rif2017.outpatient_revenue_08, include_cohort=pop_outnum_2017_8);
%claims_rev(source=rif2017.outpatient_claims_09, rev_cohort=rif2017.outpatient_revenue_09, include_cohort=pop_outnum_2017_9);
%claims_rev(source=rif2017.outpatient_claims_10, rev_cohort=rif2017.outpatient_revenue_10, include_cohort=pop_outnum_2017_10);
%claims_rev(source=rif2017.outpatient_claims_11, rev_cohort=rif2017.outpatient_revenue_11, include_cohort=pop_outnum_2017_11);
%claims_rev(source=rif2017.outpatient_claims_12, rev_cohort=rif2017.outpatient_revenue_12, include_cohort=pop_outnum_2017_12);

%claims_rev(source=rif2017.bcarrier_claims_01, rev_cohort=rif2017.bcarrier_line_01, include_cohort=pop_carnum_2017_1);
%claims_rev(source=rif2017.bcarrier_claims_02, rev_cohort=rif2017.bcarrier_line_02, include_cohort=pop_carnum_2017_2);
%claims_rev(source=rif2017.bcarrier_claims_03, rev_cohort=rif2017.bcarrier_line_03, include_cohort=pop_carnum_2017_3);
%claims_rev(source=rif2017.bcarrier_claims_04, rev_cohort=rif2017.bcarrier_line_04, include_cohort=pop_carnum_2017_4);
%claims_rev(source=rif2017.bcarrier_claims_05, rev_cohort=rif2017.bcarrier_line_05, include_cohort=pop_carnum_2017_5);
%claims_rev(source=rif2017.bcarrier_claims_06, rev_cohort=rif2017.bcarrier_line_06, include_cohort=pop_carnum_2017_6);
%claims_rev(source=rif2017.bcarrier_claims_07, rev_cohort=rif2017.bcarrier_line_07, include_cohort=pop_carnum_2017_7);
%claims_rev(source=rif2017.bcarrier_claims_08, rev_cohort=rif2017.bcarrier_line_08, include_cohort=pop_carnum_2017_8);
%claims_rev(source=rif2017.bcarrier_claims_09, rev_cohort=rif2017.bcarrier_line_09, include_cohort=pop_carnum_2017_9);
%claims_rev(source=rif2017.bcarrier_claims_10, rev_cohort=rif2017.bcarrier_line_10, include_cohort=pop_carnum_2017_10);
%claims_rev(source=rif2017.bcarrier_claims_11, rev_cohort=rif2017.bcarrier_line_11, include_cohort=pop_carnum_2017_11);
%claims_rev(source=rif2017.bcarrier_claims_12, rev_cohort=rif2017.bcarrier_line_12, include_cohort=pop_carnum_2017_12);

%claims_rev(source=rifq2018.outpatient_claims_01, rev_cohort=rifq2018.outpatient_revenue_01, include_cohort=pop_outnum_2018_1);
%claims_rev(source=rifq2018.outpatient_claims_02, rev_cohort=rifq2018.outpatient_revenue_02, include_cohort=pop_outnum_2018_2);
%claims_rev(source=rifq2018.outpatient_claims_03, rev_cohort=rifq2018.outpatient_revenue_03, include_cohort=pop_outnum_2018_3);
%claims_rev(source=rifq2018.outpatient_claims_04, rev_cohort=rifq2018.outpatient_revenue_04, include_cohort=pop_outnum_2018_4);
%claims_rev(source=rifq2018.outpatient_claims_05, rev_cohort=rifq2018.outpatient_revenue_05, include_cohort=pop_outnum_2018_5);
%claims_rev(source=rifq2018.outpatient_claims_06, rev_cohort=rifq2018.outpatient_revenue_06, include_cohort=pop_outnum_2018_6);
%claims_rev(source=rifq2018.outpatient_claims_07, rev_cohort=rifq2018.outpatient_revenue_07, include_cohort=pop_outnum_2018_7);
%claims_rev(source=rifq2018.outpatient_claims_08, rev_cohort=rifq2018.outpatient_revenue_08, include_cohort=pop_outnum_2018_8);
%claims_rev(source=rifq2018.outpatient_claims_09, rev_cohort=rifq2018.outpatient_revenue_09, include_cohort=pop_outnum_2018_9);
%claims_rev(source=rifq2018.outpatient_claims_10, rev_cohort=rifq2018.outpatient_revenue_10, include_cohort=pop_outnum_2018_10);
%claims_rev(source=rifq2018.outpatient_claims_11, rev_cohort=rifq2018.outpatient_revenue_11, include_cohort=pop_outnum_2018_11);
%claims_rev(source=rifq2018.outpatient_claims_12, rev_cohort=rifq2018.outpatient_revenue_12, include_cohort=pop_outnum_2018_12);

%claims_rev(source=rifq2018.bcarrier_claims_01, rev_cohort=rifq2018.bcarrier_line_01, include_cohort=pop_carnum_2018_1);
%claims_rev(source=rifq2018.bcarrier_claims_02, rev_cohort=rifq2018.bcarrier_line_02, include_cohort=pop_carnum_2018_2);
%claims_rev(source=rifq2018.bcarrier_claims_03, rev_cohort=rifq2018.bcarrier_line_03, include_cohort=pop_carnum_2018_3);
%claims_rev(source=rifq2018.bcarrier_claims_04, rev_cohort=rifq2018.bcarrier_line_04, include_cohort=pop_carnum_2018_4);
%claims_rev(source=rifq2018.bcarrier_claims_05, rev_cohort=rifq2018.bcarrier_line_05, include_cohort=pop_carnum_2018_5);
%claims_rev(source=rifq2018.bcarrier_claims_06, rev_cohort=rifq2018.bcarrier_line_06, include_cohort=pop_carnum_2018_6);
%claims_rev(source=rifq2018.bcarrier_claims_07, rev_cohort=rifq2018.bcarrier_line_07, include_cohort=pop_carnum_2018_7);
%claims_rev(source=rifq2018.bcarrier_claims_08, rev_cohort=rifq2018.bcarrier_line_08, include_cohort=pop_carnum_2018_8);
%claims_rev(source=rifq2018.bcarrier_claims_09, rev_cohort=rifq2018.bcarrier_line_09, include_cohort=pop_carnum_2018_9);
%claims_rev(source=rifq2018.bcarrier_claims_10, rev_cohort=rifq2018.bcarrier_line_10, include_cohort=pop_carnum_2018_10);
%claims_rev(source=rifq2018.bcarrier_claims_11, rev_cohort=rifq2018.bcarrier_line_11, include_cohort=pop_carnum_2018_11);
%claims_rev(source=rifq2018.bcarrier_claims_12, rev_cohort=rifq2018.bcarrier_line_12, include_cohort=pop_carnum_2018_12);

data pop_num;
set pop_INnum_2010_1 pop_INnum_2010_2 pop_INnum_2010_3 pop_INnum_2010_4 pop_INnum_2010_5 pop_INnum_2010_6 pop_INnum_2010_7
pop_INnum_2010_8 pop_INnum_2010_9 pop_INnum_2010_10 pop_INnum_2010_11 pop_INnum_2010_12
pop_outnum_2010_1 pop_outnum_2010_2 pop_outnum_2010_3 pop_outnum_2010_4 pop_outnum_2010_5 pop_outnum_2010_6 pop_outnum_2010_7
pop_outnum_2010_8 pop_outnum_2010_9 pop_outnum_2010_10 pop_outnum_2010_11 pop_outnum_2010_12
pop_carnum_2010_1 pop_carnum_2010_2 pop_carnum_2010_3 pop_carnum_2010_4 pop_carnum_2010_5 pop_carnum_2010_6 pop_carnum_2010_7
pop_carnum_2010_8 pop_carnum_2010_9 pop_carnum_2010_10 pop_carnum_2010_11 pop_carnum_2010_12

pop_INnum_2011_1 pop_INnum_2011_2 pop_INnum_2011_3 pop_INnum_2011_4 pop_INnum_2011_5 pop_INnum_2011_6 pop_INnum_2011_7
pop_INnum_2011_8 pop_INnum_2011_9 pop_INnum_2011_10 pop_INnum_2011_11 pop_INnum_2011_12
pop_outnum_2011_1 pop_outnum_2011_2 pop_outnum_2011_3 pop_outnum_2011_4 pop_outnum_2011_5 pop_outnum_2011_6 pop_outnum_2011_7
pop_outnum_2011_8 pop_outnum_2011_9 pop_outnum_2011_10 pop_outnum_2011_11 pop_outnum_2011_12
pop_carnum_2011_1 pop_carnum_2011_2 pop_carnum_2011_3 pop_carnum_2011_4 pop_carnum_2011_5 pop_carnum_2011_6 pop_carnum_2011_7
pop_carnum_2011_8 pop_carnum_2011_9 pop_carnum_2011_10 pop_carnum_2011_11 pop_carnum_2011_12

pop_INnum_2012_1 pop_INnum_2012_2 pop_INnum_2012_3 pop_INnum_2012_4 pop_INnum_2012_5 pop_INnum_2012_6 pop_INnum_2012_7
pop_INnum_2012_8 pop_INnum_2012_9 pop_INnum_2012_10 pop_INnum_2012_11 pop_INnum_2012_12
pop_outnum_2012_1 pop_outnum_2012_2 pop_outnum_2012_3 pop_outnum_2012_4 pop_outnum_2012_5 pop_outnum_2012_6 pop_outnum_2012_7
pop_outnum_2012_8 pop_outnum_2012_9 pop_outnum_2012_10 pop_outnum_2012_11 pop_outnum_2012_12
pop_carnum_2012_1 pop_carnum_2012_2 pop_carnum_2012_3 pop_carnum_2012_4 pop_carnum_2012_5 pop_carnum_2012_6 pop_carnum_2012_7
pop_carnum_2012_8 pop_carnum_2012_9 pop_carnum_2012_10 pop_carnum_2012_11 pop_carnum_2012_12

pop_INnum_2013_1 pop_INnum_2013_2 pop_INnum_2013_3 pop_INnum_2013_4 pop_INnum_2013_5 pop_INnum_2013_6 pop_INnum_2013_7
pop_INnum_2013_8 pop_INnum_2013_9 pop_INnum_2013_10 pop_INnum_2013_11 pop_INnum_2013_12
pop_outnum_2013_1 pop_outnum_2013_2 pop_outnum_2013_3 pop_outnum_2013_4 pop_outnum_2013_5 pop_outnum_2013_6 pop_outnum_2013_7
pop_outnum_2013_8 pop_outnum_2013_9 pop_outnum_2013_10 pop_outnum_2013_11 pop_outnum_2013_12
pop_carnum_2013_1 pop_carnum_2013_2 pop_carnum_2013_3 pop_carnum_2013_4 pop_carnum_2013_5 pop_carnum_2013_6 pop_carnum_2013_7
pop_carnum_2013_8 pop_carnum_2013_9 pop_carnum_2013_10 pop_carnum_2013_11 pop_carnum_2013_12

pop_INnum_2014_1 pop_INnum_2014_2 pop_INnum_2014_3 pop_INnum_2014_4 pop_INnum_2014_5 pop_INnum_2014_6 pop_INnum_2014_7
pop_INnum_2014_8 pop_INnum_2014_9 pop_INnum_2014_10 pop_INnum_2014_11 pop_INnum_2014_12
pop_outnum_2014_1 pop_outnum_2014_2 pop_outnum_2014_3 pop_outnum_2014_4 pop_outnum_2014_5 pop_outnum_2014_6 pop_outnum_2014_7
pop_outnum_2014_8 pop_outnum_2014_9 pop_outnum_2014_10 pop_outnum_2014_11 pop_outnum_2014_12
pop_carnum_2014_1 pop_carnum_2014_2 pop_carnum_2014_3 pop_carnum_2014_4 pop_carnum_2014_5 pop_carnum_2014_6 pop_carnum_2014_7
pop_carnum_2014_8 pop_carnum_2014_9 pop_carnum_2014_10 pop_carnum_2014_11 pop_carnum_2014_12

pop_INnum_2015_1 pop_INnum_2015_2 pop_INnum_2015_3 pop_INnum_2015_4 pop_INnum_2015_5 pop_INnum_2015_6 pop_INnum_2015_7
pop_INnum_2015_8 pop_INnum_2015_9 pop_INnum_2015_10 pop_INnum_2015_11 pop_INnum_2015_12
pop_outnum_2015_1 pop_outnum_2015_2 pop_outnum_2015_3 pop_outnum_2015_4 pop_outnum_2015_5 pop_outnum_2015_6 pop_outnum_2015_7
pop_outnum_2015_8 pop_outnum_2015_9 pop_outnum_2015_10 pop_outnum_2015_11 pop_outnum_2015_12
pop_carnum_2015_1 pop_carnum_2015_2 pop_carnum_2015_3 pop_carnum_2015_4 pop_carnum_2015_5 pop_carnum_2015_6 pop_carnum_2015_7
pop_carnum_2015_8 pop_carnum_2015_9 pop_carnum_2015_10 pop_carnum_2015_11 pop_carnum_2015_12

pop_INnum_2016_1 pop_INnum_2016_2 pop_INnum_2016_3 pop_INnum_2016_4 pop_INnum_2016_5 pop_INnum_2016_6 pop_INnum_2016_7
pop_INnum_2016_8 pop_INnum_2016_9 pop_INnum_2016_10 pop_INnum_2016_11 pop_INnum_2016_12
pop_outnum_2016_1 pop_outnum_2016_2 pop_outnum_2016_3 pop_outnum_2016_4 pop_outnum_2016_5 pop_outnum_2016_6 pop_outnum_2016_7
pop_outnum_2016_8 pop_outnum_2016_9 pop_outnum_2016_10 pop_outnum_2016_11 pop_outnum_2016_12
pop_carnum_2016_1 pop_carnum_2016_2 pop_carnum_2016_3 pop_carnum_2016_4 pop_carnum_2016_5 pop_carnum_2016_6 pop_carnum_2016_7
pop_carnum_2016_8 pop_carnum_2016_9 pop_carnum_2016_10 pop_carnum_2016_11 pop_carnum_2016_12

pop_INnum_2017_1 pop_INnum_2017_2 pop_INnum_2017_3 pop_INnum_2017_4 pop_INnum_2017_5 pop_INnum_2017_6 pop_INnum_2017_7
pop_INnum_2017_8 pop_INnum_2017_9 pop_INnum_2017_10 pop_INnum_2017_11 pop_INnum_2017_12
pop_outnum_2017_1 pop_outnum_2017_2 pop_outnum_2017_3 pop_outnum_2017_4 pop_outnum_2017_5 pop_outnum_2017_6 pop_outnum_2017_7
pop_outnum_2017_8 pop_outnum_2017_9 pop_outnum_2017_10 pop_outnum_2017_11 pop_outnum_2017_12
pop_carnum_2017_1 pop_carnum_2017_2 pop_carnum_2017_3 pop_carnum_2017_4 pop_carnum_2017_5 pop_carnum_2017_6 pop_carnum_2017_7
pop_carnum_2017_8 pop_carnum_2017_9 pop_carnum_2017_10 pop_carnum_2017_11 pop_carnum_2017_12

pop_INnum_2018_1 pop_INnum_2018_2 pop_INnum_2018_3 pop_INnum_2018_4 pop_INnum_2018_5 pop_INnum_2018_6 pop_INnum_2018_7
pop_INnum_2018_8 pop_INnum_2018_9 pop_INnum_2018_10 pop_INnum_2018_11 pop_INnum_2018_12
pop_outnum_2018_1 pop_outnum_2018_2 pop_outnum_2018_3 pop_outnum_2018_4 pop_outnum_2018_5 pop_outnum_2018_6 pop_outnum_2018_7
pop_outnum_2018_8 pop_outnum_2018_9 pop_outnum_2018_10 pop_outnum_2018_11 pop_outnum_2018_12
pop_carnum_2018_1 pop_carnum_2018_2 pop_carnum_2018_3 pop_carnum_2018_4 pop_carnum_2018_5 pop_carnum_2018_6 pop_carnum_2018_7
pop_carnum_2018_8 pop_carnum_2018_9 pop_carnum_2018_10 pop_carnum_2018_11 pop_carnum_2018_12
;
*only keep procedures that occur after qualifying diagnosis;
if popped_dt<pop_elig_dt then delete;
run;*447,583;
proc sort data=pop_num NODUPKEY;by bene_id pop_elig_dt;run;*411,252;

*bring in chronic conditions---associated with denominator first then match to the num-denom file;
%macro line(abcd=, include_cohort=);
proc sql;
create table &include_cohort (compress=yes) as
select  
a.bene_id, b.*
from 
pop_denom a,
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
run; *48,212,026;
proc sort data=cc nodupkey; by bene_id; run;*;
proc print data=cc (obs=20); run; *this has chronic condition outcomes EVER (not tied to the proc date);
proc freq data=cc; table CANCER_ENDOMETRIAL; run;

*start here;

*bring in enrollment info....other qualifying characteristics;
*bring in denominator of all women based on MBSF file--ideally would count months until death and not require entire year;
data pop_11_denom;
set mbsf.mbsf_abcd_2010;
where /*sex_ident_cd='2' and*/ BENE_HI_CVRAGE_TOT_MONS=12 and BENE_SMI_CVRAGE_TOT_MONS=12;*female and enrolled in parts A and B all 12 months of 2010;
run;*;



*if in cc_cohort and in denominator then include;
proc sort data=cc; by bene_id;*;
proc sort data=pop_num; by bene_id popped_dt;*447,583 sort so keep first popped date--all procedures before elig date have been deleted;
proc sort data=pop_num NODUPKEY; by bene_id; *303,547;
proc sort data=pop_denom; by bene_id pop_elig_dt; *48,371,873 sort so keep first eligibility date;
proc sort data=pop_denom NODUPKEY; by bene_id;*15,618,210 denominator is person level not date so keep only 1 per person;
		*when de-dupe to 1 sinusitis per person;
data shu172sl.pop_cc; 
merge cc(in=a) pop_denom (in=b) pop_num;
if a and b;
by bene_id;
if popped_20=. then popped_20=0;
format pop_nch_clm_type_cd $clm_typ.;
if ami_ever ne . and ami_ever<=pop_elig_dt then cc_ami=1; else cc_ami=0;
if alzh_ever ne . and alzh_ever <=pop_elig_dt then cc_alzh=1; else cc_alzh=0;
if alzh_demen_ever ne . and alzh_demen_ever <=pop_elig_dt then cc_alzh_demen=1; else cc_alzh_demen=0;
if atrial_fib_ever ne . and atrial_fib_ever<=pop_elig_dt then cc_atrial_fib=1; else cc_atrial_fib=0;
if cataract_ever ne . and cataract_ever <=pop_elig_dt then cc_cataract=1; else cc_cataract=0;
if chronickidney_ever ne . and chronickidney_ever<=pop_elig_dt then cc_chronickidney=1; else cc_chronickidney=0;
if copd_ever ne . and copd_ever <=pop_elig_dt then cc_copd=1; else cc_copd=0;
if chf_ever ne . and chf_ever <=pop_elig_dt then cc_chf=1; else cc_chf=0;
if diabetes_ever ne . and diabetes_ever <=pop_elig_dt then cc_diabetes=1; else cc_diabetes=0;
if glaucoma_ever ne . and glaucoma_ever  <=pop_elig_dt then cc_glaucoma=1; else cc_glaucoma=0;
if hip_fracture_ever ne . and hip_fracture_ever <=pop_elig_dt then cc_hip_fracture=1; else cc_hip_fracture=0;
if ischemicheart_ever ne . and ischemicheart_ever<=pop_elig_dt then cc_ischemicheart=1; else cc_ischemicheart=0;
if depression_ever ne . and depression_ever <=pop_elig_dt then cc_depression=1; else cc_depression=0;
if osteoporosis_ever ne . and osteoporosis_ever <=pop_elig_dt then cc_osteoporosis=1; else cc_osteoporosis=0;
if ra_oa_ever ne . and ra_oa_ever <=pop_elig_dt then cc_ra_oa=1; else cc_ra_oa=0;
if stroke_tia_ever  ne . and stroke_tia_ever <=pop_elig_dt then cc_stroke_tia=1; else cc_stroke_tia=0;
if cancer_breast_ever ne . and cancer_breast_ever<=pop_elig_dt then cc_cancer_breast=1; else cc_cancer_breast=0;
if cancer_colorectal_ever ne . and cancer_colorectal_ever<=pop_elig_dt then cc_cancer_colorectal=1; else cc_cancer_colorectal=0;
if cancer_prostate_ever ne . and cancer_prostate_ever <=pop_elig_dt then cc_cancer_prostate=1; else cc_cancer_prostate=0;
if cancer_lung_ever ne . and cancer_lung_ever <=pop_elig_dt then cc_cancer_lung=1; else cc_cancer_lung=0;
if cancer_endometrial_ever ne . and cancer_endometrial_ever<=pop_elig_dt then cc_cancer_endometrial=1; else cc_cancer_endometrial=0;
if anemia_ever ne . and anemia_ever <=pop_elig_dt then cc_anemia=1; else cc_anemia=0;
if asthma_ever ne . and asthma_ever<=pop_elig_dt then cc_asthma=1; else cc_asthma=0;
if hyperl_ever ne . and hyperl_ever <=pop_elig_dt then cc_hyperl=1; else cc_hyperl=0;
if hyperp_ever ne . and hyperp_ever <=pop_elig_dt then cc_hyperp=1; else cc_hyperp=0;
if hypert_ever ne . and hypert_ever <=pop_elig_dt then cc_hypert=1; else cc_hypert=0;
if hypoth_ever ne . and hypoth_ever<=pop_elig_dt then cc_hypoth=1; else cc_hypoth=0;
cc_sum=sum(cc_ami, cc_alzh, cc_alzh_demen, cc_atrial_fib, cc_chronickidney, cc_copd, cc_chf, cc_diabetes, cc_glaucoma, cc_hip_fracture,
cc_ischemicheart, cc_depression, cc_osteoporosis, cc_ra_oa, cc_stroke_tia, cc_cancer_breast, cc_cancer_colorectal, cc_cancer_prostate,
cc_cancer_lung, cc_cancer_endometrial, cc_anemia, cc_asthma, cc_hyperl, cc_hyperp, cc_hypert, cc_hypoth);
if cc_sum=0     then cc_cat='0  ';
if 1<=cc_sum<=5 then cc_cat='1-5';
if 6<=cc_sum<=9 then cc_cat='6-9';
if cc_sum>=10   then cc_cat='10+';
if     pop_age<65 then age_cat='LT 65';
if 65<=pop_age<70 then age_cat='65-69';
if 70<=pop_age<75 then age_cat='70-74';
if 75<=pop_age<79 then age_cat='75-79';
if 79<=pop_age<84 then age_cat='80-84';
if pop_age>=84     then age_cat='85-95';
run;* (some not in cc file );
proc sort data=shu172sl.pop_cc; by pop_nch_clm_type_cd; run;
proc freq data=shu172sl.pop_cc order=freq; *by pop_nch_clm_type_cd; 
table gndr_cd pop_year*popped_11 pop_nch_clm_type_cd 
pop_admtg_dgns_cd pop_icd_dgns_cd1 pop_clm_drg_cd pop_hcpcs_cd
/ nocol nopercent; run;


*need to relabel everything to pop20 here---use prefix sql?;

PROC logistic DATA=shu172sl.pop_cc; 
class pop_year(ref=first) gndr_cd(ref='2')  bene_race_cd(ref=first) cc_cat(ref='6-9') age_cat(ref=first)/param=ref;
model popped_11 (event='1')= pop_year gndr_cd bene_race_cd age_cat cc_cat;*pop_age ed_admit;
      output out=pop_model p=pred_popped_11;
	  ods output parameterestimates=parameterestimates;
run;




