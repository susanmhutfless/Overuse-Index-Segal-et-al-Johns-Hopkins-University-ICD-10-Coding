/********************************************************************
* Job Name: chronic_conditions.sas
* Job Desc: Identify chronic conditions
* Copyright: Johns Hopkins University - HutflessLab 2021
********************************************************************/


*bring in chronic conditions;
%macro line(abcd=, include_cohort=);
proc sql;
create table &include_cohort (compress=yes) as
select  
a.bene_id, a.elig_dt, b.*
from 
&permlib..pop_&popN._1line_nocc a,
&abcd b
where a.bene_id = b.bene_id and a.pop_year = b.BENE_ENROLLMT_REF_YR;
quit;
%mend;
%line(abcd=mbsf.mbsf_cc_2018, include_cohort=cc_2018); 
%line(abcd=mbsf.mbsf_cc_2017, include_cohort=cc_2017); 
%line(abcd=mbsf.mbsf_cc_2016, include_cohort=cc_2016);  
%line(abcd=mbsf.mbsf_otcc_2018, include_cohort=otcc_2018); 
%line(abcd=mbsf.mbsf_otcc_2017, include_cohort=otcc_2017); 
%line(abcd=mbsf.mbsf_otcc_2016, include_cohort=otcc_2016); 


proc sort data=cc_2016; by bene_id elig_dt;
proc sort data=cc_2017; by bene_id elig_dt;
proc sort data=cc_2018; by bene_id elig_dt;

proc sort data=otcc_2016; by bene_id elig_dt;
proc sort data=otcc_2017; by bene_id elig_dt;
proc sort data=otcc_2018; by bene_id elig_dt;
proc sort data=&permlib..pop_&popN._1line_nocc; by bene_id elig_dt;
run;
data cc (keep=bene: elig_dt enrl_src ami ami_ever alzh_ever alzh_demen_ever atrial_fib_ever
cataract_ever chronickidney_ever copd_ever chf_ever diabetes_ever glaucoma_ever  hip_fracture_ever 
ischemicheart_ever depression_ever osteoporosis_ever ra_oa_ever stroke_tia_ever cancer_breast_ever
cancer_colorectal_ever cancer_prostate_ever cancer_lung_ever cancer_endometrial_ever anemia_ever asthma_ever
hyperl_ever hyperp_ever hypert_ever hypoth_ever 
acp_MEDICARE_EVER anxi_MEDICARE_EVER autism_MEDICARE_EVER bipl_MEDICARE_EVER brainj_MEDICARE_EVER cerpal_MEDICARE_EVER
cysfib_MEDICARE_EVER depsn_MEDICARE_EVER epilep_MEDICARE_EVER fibro_MEDICARE_EVER hearim_MEDICARE_EVER
hepviral_MEDICARE_EVER hivaids_MEDICARE_EVER intdis_MEDICARE_EVER leadis_MEDICARE_EVER leuklymph_MEDICARE_EVER
liver_MEDICARE_EVER migraine_MEDICARE_EVER mobimp_MEDICARE_EVER mulscl_MEDICARE_EVER musdys_MEDICARE_EVER
obesity_MEDICARE_EVER othdel_MEDICARE_EVER psds_MEDICARE_EVER ptra_MEDICARE_EVER pvd_MEDICARE_EVER schi_MEDICARE_EVER
schiot_MEDICARE_EVER spibif_MEDICARE_EVER spiinj_MEDICARE_EVER toba_MEDICARE_EVER ulcers_MEDICARE_EVER
visual_MEDICARE_EVER cc_sum cc_other_sum cc_DHHS_sum);
;
merge otcc: cc:	;
by bene_id elig_dt;
*make chronic conitions indicators;
if ami_ever ne . and ami_ever<=elig_dt then cc_ami=1; else cc_ami=0;
if alzh_ever ne . and alzh_ever <=elig_dt then cc_alzh=1; else cc_alzh=0;
if alzh_demen_ever ne . and alzh_demen_ever <=elig_dt then cc_alzh_demen=1; else cc_alzh_demen=0;
if atrial_fib_ever ne . and atrial_fib_ever<=elig_dt then cc_atrial_fib=1; else cc_atrial_fib=0;
if cataract_ever ne . and cataract_ever <=elig_dt then cc_cataract=1; else cc_cataract=0;
if chronickidney_ever ne . and chronickidney_ever<=elig_dt then cc_chronickidney=1; else cc_chronickidney=0;
if copd_ever ne . and copd_ever <=elig_dt then cc_copd=1; else cc_copd=0;
if chf_ever ne . and chf_ever <=elig_dt then cc_chf=1; else cc_chf=0;
if diabetes_ever ne . and diabetes_ever <=elig_dt then cc_diabetes=1; else cc_diabetes=0;
if glaucoma_ever ne . and glaucoma_ever  <=elig_dt then cc_glaucoma=1; else cc_glaucoma=0;
if hip_fracture_ever ne . and hip_fracture_ever <=elig_dt then cc_hip_fracture=1; else cc_hip_fracture=0;
if ischemicheart_ever ne . and ischemicheart_ever<=elig_dt then cc_ischemicheart=1; else cc_ischemicheart=0;
if depression_ever ne . and depression_ever <=elig_dt then cc_depression=1; else cc_depression=0;
if osteoporosis_ever ne . and osteoporosis_ever <=elig_dt then cc_osteoporosis=1; else cc_osteoporosis=0;
if ra_oa_ever ne . and ra_oa_ever <=elig_dt then cc_ra_oa=1; else cc_ra_oa=0;
if stroke_tia_ever  ne . and stroke_tia_ever <=elig_dt then cc_stroke_tia=1; else cc_stroke_tia=0;
if cancer_breast_ever ne . and cancer_breast_ever<=elig_dt then cc_cancer_breast=1; else cc_cancer_breast=0;
if cancer_colorectal_ever ne . and cancer_colorectal_ever<=elig_dt then cc_cancer_colorectal=1; else cc_cancer_colorectal=0;
if cancer_prostate_ever ne . and cancer_prostate_ever <=elig_dt then cc_cancer_prostate=1; else cc_cancer_prostate=0;
if cancer_lung_ever ne . and cancer_lung_ever <=elig_dt then cc_cancer_lung=1; else cc_cancer_lung=0;
if cancer_endometrial_ever ne . and cancer_endometrial_ever<=elig_dt then cc_cancer_endometrial=1; else cc_cancer_endometrial=0;
if anemia_ever ne . and anemia_ever <=elig_dt then cc_anemia=1; else cc_anemia=0;
if asthma_ever ne . and asthma_ever<=elig_dt then cc_asthma=1; else cc_asthma=0;
if hyperl_ever ne . and hyperl_ever <=elig_dt then cc_hyperl=1; else cc_hyperl=0;
if hyperp_ever ne . and hyperp_ever <=elig_dt then cc_hyperp=1; else cc_hyperp=0;
if hypert_ever ne . and hypert_ever <=elig_dt then cc_hypert=1; else cc_hypert=0;
if hypoth_ever ne . and hypoth_ever<=elig_dt then cc_hypoth=1; else cc_hypoth=0;
cc_sum=sum(cc_ami, cc_alzh, cc_alzh_demen, cc_atrial_fib, cc_chronickidney, cc_copd, cc_chf, cc_diabetes, cc_glaucoma, cc_hip_fracture,
cc_ischemicheart, cc_depression, cc_osteoporosis, cc_ra_oa, cc_stroke_tia, cc_cancer_breast, cc_cancer_colorectal, cc_cancer_prostate,
cc_cancer_lung, cc_cancer_endometrial, cc_anemia, cc_asthma, cc_hyperl, cc_hyperp, cc_hypert, cc_hypoth);
if ACP_MEDICARE_EVER ne . and ACP_MEDICARE_EVER<=elig_dt then cc_acp=1; else cc_acp=0;
if ANXI_MEDICARE_EVER ne . and ANXI_MEDICARE_EVER<=elig_dt then cc_anxi=1; else cc_anxi=0;
if AUTISM_MEDICARE_EVER ne . and AUTISM_MEDICARE_EVER<= elig_dt then cc_autism=1; else cc_autism=0;
if BIPL_MEDICARE_EVER ne . and BIPL_MEDICARE_EVER<=elig_dt then cc_bipl=1; else cc_bipl=0;
if BRAINJ_MEDICARE_EVER ne . and BRAINJ_MEDICARE_EVER<=elig_dt then cc_brainj=1; else cc_brainj=0;
if CERPAL_MEDICARE_EVER ne . and CERPAL_MEDICARE_EVER<=elig_dt then cc_cerpal=1; else cc_cerpal=0;
if CYSFIB_MEDICARE_EVER ne . and CYSFIB_MEDICARE_EVER<=elig_dt then cc_cysfib=1; else cc_cysfib=0;
if DEPSN_MEDICARE_EVER ne . and DEPSN_MEDICARE_EVER<=elig_dt then cc_depsn=1; else cc_depsn =0;
if EPILEP_MEDICARE_EVER ne . and EPILEP_MEDICARE_EVER<=elig_dt then cc_epilep=1; else cc_epilep=0;
if FIBRO_MEDICARE_EVER ne . and FIBRO_MEDICARE_EVER<=elig_dt then cc_fibro=1; else cc_fibro=0;
if HEARIM_MEDICARE_EVER ne . and HEARIM_MEDICARE_EVER<=elig_dt then cc_hearim=1; else cc_hearim=0;
if HEPVIRAL_MEDICARE_EVER ne . and HEPVIRAL_MEDICARE_EVER<=elig_dt then cc_hepviral=1; else cc_hepviral=0;
if HIVAIDS_MEDICARE_EVER ne . and HIVAIDS_MEDICARE_EVER<=elig_dt then cc_hivaids=1; else cc_hivaids=0;
if INTDIS_MEDICARE_EVER ne . and INTDIS_MEDICARE_EVER<=elig_dt then cc_intdis=1; else cc_intdis=0;
if LEADIS_MEDICARE_EVER ne . and LEADIS_MEDICARE_EVER<=elig_dt then cc_leadis=1; else cc_leadis=0; 
if LEUKLYMPH_MEDICARE_EVER ne . and LEUKLYMPH_MEDICARE_EVER<=elig_dt then cc_leuklymph=1; else cc_leuklymph=0;
if LIVER_MEDICARE_EVER ne . and LIVER_MEDICARE_EVER<=elig_dt then cc_liver=1; else cc_liver=0; 
if MIGRAINE_MEDICARE_EVER ne . and MIGRAINE_MEDICARE_EVER<=elig_dt then cc_migraine=1; else cc_migraine=0; 
if MOBIMP_MEDICARE_EVER ne . and MOBIMP_MEDICARE_EVER<=elig_dt then cc_mobimp=1; else cc_mobimp=0; 
if MULSCL_MEDICARE_EVER ne . and MULSCL_MEDICARE_EVER<=elig_dt then cc_mulscl=1; else cc_mulscl=0; 
if MUSDYS_MEDICARE_EVER ne . and MUSDYS_MEDICARE_EVER<=elig_dt then cc_musdys=1; else cc_musdys=0;
if OBESITY_MEDICARE_EVER ne . and OBESITY_MEDICARE_EVER<=elig_dt then cc_obesity=1; else cc_obesity=0;
if OTHDEL_MEDICARE_EVER ne . and OTHDEL_MEDICARE_EVER<=elig_dt then cc_othdel=1; else cc_othdel=0;
if PSDS_MEDICARE_EVER ne . and PSDS_MEDICARE_EVER<=elig_dt then cc_psds=1; else cc_psds=0;
if PTRA_MEDICARE_EVER ne . and PTRA_MEDICARE_EVER<=elig_dt then cc_ptra=1; else cc_ptra=0;
if PVD_MEDICARE_EVER ne . and PVD_MEDICARE_EVER<=elig_dt then cc_pvd=1; else cc_pvd=0;
if SCHI_MEDICARE_EVER ne . and SCHI_MEDICARE_EVER<=elig_dt then cc_schi=1; else cc_schi=0;
if SCHIOT_MEDICARE_EVER ne . and SCHIOT_MEDICARE_EVER<=elig_dt then cc_schiot=1; else cc_schiot=0;
if SPIBIF_MEDICARE_EVER ne . and SPIBIF_MEDICARE_EVER<=elig_dt then cc_spibif=1; else cc_spibif=0;
if SPIINJ_MEDICARE_EVER ne . and SPIINJ_MEDICARE_EVER<=elig_dt then cc_spiinj=1; else cc_spiinj=0;
if TOBA_MEDICARE_EVER ne . and TOBA_MEDICARE_EVER<=elig_dt then cc_toba=1; else cc_toba=0;
if ULCERS_MEDICARE_EVER ne . and ULCERS_MEDICARE_EVER<=elig_dt then cc_ulcers=1; else cc_ulcers=0;
if VISUAL_MEDICARE_EVER ne . and VISUAL_MEDICARE_EVER<=elig_dt then cc_visual=1; else cc_visual=0;
cc_other_sum=sum(cc_acp, cc_anxi, cc_autism, cc_bipl, cc_brainj, cc_cerpal, cc_cysfib, cc_depsn, cc_epilep, 
cc_fibro, cc_hearim, cc_hepviral, cc_hivaids, cc_intdis, cc_leadis, cc_leuklymph, cc_liver, cc_migraine, 
cc_mobimp, cc_mulscl, cc_musdys, cc_obesity, cc_othdel, cc_psds, cc_ptra, cc_pvd, cc_schi, cc_schiot, 
cc_spibif, cc_spiinj, cc_toba, cc_ulcers, cc_visual); 
*DHHS has own chronic conditions list which is a subset of these CC
https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Chronic-Conditions/Downloads/Methods_Overview.pdf ;
cc_DHHS_sum=sum(cc_alzh_demen, cc_atrial_fib, cc_chronickidney, cc_copd, cc_chf, cc_diabetes, cc_ischemicheart, cc_depression,
cc_osteoporosis, cc_ra_oa, cc_stroke_tia, cc_cancer_breast, cc_cancer_colorectal, cc_cancer_prostate, cc_cancer_lung, cc_asthma,
cc_hyperl, cc_hypert,cc_autism, cc_hepviral, cc_hivaids, cc_schi);
run;

data &permlib..pop_&popN._1line_cc;
merge 
cc (in=a) &permlib..pop_&popN._1line_nocc (in=b);
by bene_id elig_dt;
if a and b;
run; 

