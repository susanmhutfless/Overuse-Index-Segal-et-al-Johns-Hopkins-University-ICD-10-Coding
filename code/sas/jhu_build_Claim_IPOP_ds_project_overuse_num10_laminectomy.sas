/********************************************************************
* Job Name: jhu_build_Claim_IPOP_ds_project_overuse_laminectomy.sas
* Job Desc: Input for Inpatient & Outpatient (Including Carrier) Claims 
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************/

/* Indicator 10 */

/*** start of indicator specific variables ***/

/*global variables for inclusion and exclusion*/
%global includ_hcpcs 
		includ_pr10_code4  includ_pr10_substr4
		includ_pr10_code7  includ_pr10_substr7
		includ_dx10  includ_dx10_n 
		EXCLUD_dx10  exclud_dx10_n
		EXCLUD_dx10_code3	exclud_dx10_substr3
		EXCLUD_dx10_code4	exclud_dx10_substr4;

/*inclusion criteria*/
		*people without DIAGNOSES of lower extremtiy neuropathy or weakness;

%let includ_hcpcs =
					'22558'	'22612' '22630'
					'22633' 				;		*use for popped visit;

%let includ_pr10_code7 =
					'0SG0070' '0SG0071' '0SG007J'
					'0SG00A0' '0SG00AJ' 
					'0SG00J0' '0SG00J1' '0SG00JJ'
					'0SG00K0' '0SG00K1' 			; 		*use for popped visit;
%let includ_pr10_substr7 = 7;		*this number should match number that needs to be substringed;
%let includ_dx10   = '0';							
%let includ_dx10_n = 7;		
%let includ_drg = '0';

/** Exclusion criteria **/
%let exclud_hcpcs= '0'; 					

%let EXclud_pr10 =	'0'				; 
%let EXclud_pr10_n = 7;	

%let EXCLUD_dx10_code3   = 'S34' 'C00' 'C01'
					'C02' 'C03' 'C04' 'C05' 'C06'
					'C07' 'C08' 'C09' 'C10' 'C11'
					'C12' 'C13' 'C14' 'C15' 'C16' 
					'C17' 'C18' 'C19' 'C20' 'C21' 
					'C22' 'C23' 'C24' 'C25' 'C26'
					'C27' 'C28' 'C29' 'C30' 'C31'
					'C32' 'C33' 'C34' 'C35' 'C36'
					'C37' 'C38' 'C39' 'C40' 'C41'
					'C42' 'C43' 'C45' 'C46' 'C47' 
					'C48' 'C49' 'C50' 'C51' 'C52' 
					'C53' 'C54' 'C55' 'C56' 'C57' 
					'C58' 'C59' 'C60' 'C61' 'C62' 
					'C63' 'C64' 'C65' 'C66' 'C67' 
					'C68' 'C69' 'C70' 'C71' 'C72' 
					'C73' 'C74' 'C75' 'C76' 'C77'
					'C78' 'C79' 'C80' 'C81' 'C82' 
					'C83' 'C84' 'C85' 'C86' 'C87'
					'C88' 'C89' 'C90' 'C91' 'C92' 
					'C93' 'C94' 'C95' 'C96' ; 						* use for popped visit;
%let exclud_dx10_substr3 = 3; 
%let EXCLUD_dx10_code4   = 'M543' 'M544' 'M462' 'M463' 'M464' 'M465' ; 			* use for popped visit;
%let exclud_dx10_substr4 = 4; 

/** Label pop specific variables  **/
%global popN;
%let	popN							= 10;
%let	poptext							= "laminectomy";
%let 	flag_popped             		= popped10 								;
%let 	flag_popped_label				= 'indicator 10 popped'					;	
%let	flag_popped_dt					= popped10_dt							;
%let 	flag_popped_dt_label			= 'indicator 10 date patient popped (IP=clm_admsn_dt OP=clm_from_dt)'	;
%let 	pop_age							= pop_10_age							;				
%let	pop_age_label					= 'age popped for pop 10'				;
%let	pop_los							= pop_10_los							;
%let	pop_los_label					= 'length of stay when patient popped'	;
%let	pop_year						= pop_10_year							;
%let	pop_nch_clm_type_cd				= pop_10_nch_clm_type_cd				;
%let  	pop_CLM_IP_ADMSN_TYPE_CD		= pop_10_CLM_IP_ADMSN_TYPE_CD			;
%let	pop_clm_fac_type_cd				= pop_10_clm_fac_type_cd				;
%let	pop_clm_src_ip_admsn_cd			= pop_10_clm_src_ip_admsn_cd			;
%let	pop_ptnt_dschrg_stus_cd  		= pop_10_ptnt_dschrg_stus_cd			;
%let	pop_admtg_dgns_cd				= pop_10_admtg_dgns_cd					;
%let	pop_icd_dgns_cd1				= pop_10_icd_dgns_cd1					;
%let	pop_icd_prcdr_cd1				= pop_10_icd_prcdr_cd1					;
%let	pop_clm_drg_cd					= pop_10_clm_drg_cd						;
%let	pop_hcpcs_cd					= pop_10_hcpcs_cd						;
%let	pop_OP_PHYSN_SPCLTY_CD			= pop_10_OP_PHYSN_SPCLTY_CD				;
%let	pop_nch_clm_type_cd				= pop_10_nch_clm_type_cd				;
%let	pop_nch_clm_type_cd_label		= 'claim/facility type for pop 10' 		;
%let	pop_CLM_IP_ADMSN_TYPE_CD_label	= 'inpatient admission type code for pop 10'	;
%let  	pop_clm_fac_type_cd_label		= 'inpatient clm_fac_type_cd for pop 10';
%let	pop_clm_src_ip_admsn_cd_label	= 'clm_src_ip_admsn_cd for pop 10'		;
%let	pop_ptnt_dschrg_stus_cd_label	= 'discharge status code for pop 10'	;	
/*** end of indicator specific variables ***/


/*** start of section - study specific libraries and variables ***/
/*** libname prefix alias assignments ***/
%global lwork ltemp permlib;
%let  lwork              = work              	;
%let  ltemp              = temp              	;
%let  permlib              = shu172sl          	;  /** permanent library location**/

%global bene_id 	clm_id 		hcpcs_cd 	clm_drg_cd
		diag_pfx 	diag_cd_min diag_cd_max
		proc_pfx 	proc_cd_min proc_cd_max        
		clm_beg_dt_in	clm_end_dt_in
		clm_beg_dt		clm_end_dt	clm_dob
		gndr_cd									;

%let  bene_id            = bene_id      		;
%let  clm_id             = clm_id            	;
%let  gndr_cd            = gndr_cd              ;
%let  hcpcs_cd           = hcpcs_cd             ;
%let  clm_drg_cd         = clm_drg_cd    		;

%let  diag_pfx           = icd_dgns_cd          ;
%let  diag_cd_min        = 1                 	;
%let  diag_cd_max        = 25                 	;

%let  proc_pfx           = icd_prcdr_cd         ;
%let  proc_cd_min        = 1                 	;
%let  proc_cd_max        = 25                 	;

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
%let  admtg_dgns_cd      = admtg_dgns_cd        ;
%let  icd_dgns_cd1       = icd_dgns_cd1         ;
%let  icd_prcdr_cd1       = icd_prcdr_cd1       ;
%let  OP_PHYSN_SPCLTY_CD = OP_PHYSN_SPCLTY_CD   ;
/*revenue center for inpatient/outpatient identifies ED*/ *exclude ED for this 
%global rev_cntr;
%let rev_cntr = rev_cntr;
%let ED_rev_cntr = 	'0450' '0451' '0452' '0453' '0454' '0455' '0456'
					'0457' '0458' '0459' '0981'  					;

/*** end of section   - study specific variables ***/

/** locations where code stored on machine for project **/
%let vpath     = /sas/vrdc/users/shu172/files   ;
%let proj_path = /jhu_projects/overuse          ;
%let code_path = /code/                         ;
%let vrdc_code = &vpath./jhu_vrdc_code          ;
%include "&vrdc_code./macro_tool_box.sas";
%include "&vrdc_code./medicare_formats.sas";
*%include "&vrdc_code./jhu_build_Health_Systems.sas";


*start identification of eligibility;
*Pop10: restrict to same pop as 7 lower back pain;
*start identification of eligibility;
*First identify all who are eligible;
data &permlib..pop_&popN._elig;	
set &permlib..pop_07_elig;
run;
*end identification of eligibility;


*Start: Identify who popped;
%macro claims_rev(date=, source=, rev_cohort=, include_cohort=, ccn=);
* identify hcpcs ;
proc sql;
create table include_cohort1a (compress=yes) as
select &bene_id, &clm_id, &rev_cntr,
	&hcpcs_cd, case when &hcpcs_cd in (&includ_hcpcs) then 1 else 0 end as &flag_popped
from 
	&rev_cohort
where 
	&hcpcs_cd in (&includ_hcpcs);
quit;
* pull claim info for those with HCPCS (need to do this to get dx codes)*;
proc sql;
	create table include_cohort1b (compress=yes) as
select a.&rev_cntr, a.&hcpcs_cd, a.&flag_popped, b.*
from 
	include_cohort1a a, 
	&source b
where 
	(a.&bene_id=b.&bene_id and a.&clm_id=b.&clm_id);
quit;
*link to ccn;
proc sql;
	create table include_cohort1c (compress=yes) as
select *
from 
	&permlib..ahrq_ccn a,
	include_cohort1b b	
where 
	b.prvdr_num = a.&ccn
;
quit;
*pull icd procedure criteria from claims*;
proc sql;
	create table include_cohort1d (compress=yes) as
select *
from 
	&source
where
		substr(icd_prcdr_cd1,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd2,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd3,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd4,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd5,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd6,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd7,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd8,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd9,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd10,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd11,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd12,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd13,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd14,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd15,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd16,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd17,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd18,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd19,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd20,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd21,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd22,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd23,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd24,1,&includ_pr10_substr7) in(&includ_pr10_code7) or
		substr(icd_prcdr_cd25,1,&includ_pr10_substr7) in(&includ_pr10_code7) ;
quit;
*link icd prcdr identified to revenue center*;
proc sql;
	create table include_cohort1e (compress=yes) as
select a.&rev_cntr, b.*
from 
	&rev_cohort 		a,
	include_cohort1d 	b 
where 
	(a.&bene_id=b.&bene_id and a.&clm_id=b.&clm_id);
quit;
*transpose the revenue to 1 row per bene/clm;
proc sort data=include_cohort1e nodupkey out=rev_transposed; by &bene_id &clm_id &rev_cntr; run;
proc transpose data=rev_transposed out=rev_transposed (drop = _name_ _label_) prefix=rev_cntr;
    by &bene_id &clm_id ;
    var &rev_cntr;
run;
*bring transposed rev center in with claim;
data include_cohort1e2 ; 
merge 	include_cohort1d  
		rev_transposed; *have separate criteria for hcpcs above so no need to grab hcpcs here;
by &bene_id &clm_id ;
run;

* link to CCN ;
proc sql;
	create table include_cohort1f (compress=yes) as
select *
from 
	&permlib..ahrq_ccn a,
	include_cohort1e2 b	
where 
	b.prvdr_num = a.&ccn
;
quit;
*merge HCPCS and PRCDR identified pops together;
Data include_cohort1g; 
set include_cohort1c include_cohort1f; 
array rev{*} rev_cntr:;
do r=1 to dim(rev);
	if rev(r) in(&ED_rev_cntr) then pop_ed=1;	
end; 
label pop_ed='popped: revenue center indicated emergency department';
&flag_popped_dt=&date; 
	format &flag_popped_dt date9.; 						label &flag_popped_dt			=	&flag_popped_dt_label;
				 										label &flag_popped				=	&flag_popped_label;
array pr(&proc_cd_max) &proc_pfx.&proc_cd_min - &proc_pfx.&proc_cd_max;
do i=1 to &proc_cd_max;
	if substr(pr(i),1,&exclud_pr10_n) in(&EXclud_pr10) then DELETE=1;	
	if substr(pr(i),1,&includ_pr10_substr7) in(&includ_pr10_code7) then &flag_popped=1;
	if substr(pr(i),1,&includ_pr10_substr4) in(&includ_pr10_code4) then &flag_popped=1;
end;
array dx(&diag_cd_max) &diag_pfx.&diag_cd_min - &diag_pfx.&diag_cd_max;
do j=1 to &diag_cd_max;
	if substr(dx(j),1,&exclud_dx10_substr3) in(&EXCLUD_dx10_code3) then DELETE=1;
	if substr(dx(j),1,&exclud_dx10_substr4) in(&EXCLUD_dx10_code4) then DELETE=1;	
end;
if hcpcs_cd in(&exclud_hcpcs) then DELETE=1;
if DELETE = 1 then delete;
if &flag_popped ne 1 then delete;
run; 
*link to eligibility--require the timing of inclusion dx and procedure match-up;
proc sql;
	create table &include_cohort (compress=yes) as
select a.elig_dt, b.*
from 
	&permlib..pop_&popN._elig a,
	include_cohort1g		  b	
where 
		a.&bene_id=b.&bene_id 
		and 
		a.elig_dt-90 <= b.&flag_popped_dt <=a.elig_dt	
;  
quit;
%mend;
%include "&vrdc_code./pop_op.sas";

data pop_&popN._out (keep=  pop: &flag_popped_dt elig: setting: 
							&bene_id &clm_id 
							&clm_from_dt &clm_thru_dt &clm_dob  &ptnt_dschrg_stus_cd
							&nch_clm_type_cd &clm_fac_type_cd    
							prvdr_num prvdr_state_cd OP_PHYSN_SPCLTY_CD rev_cntr
							at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi
							/*RFR_PHYSN_NPI*/
							&gndr_cd bene_race_cd	bene_cnty_cd
							bene_state_cd 	bene_mlg_cntct_zip_cd	 );
set pop_&popN._out_:;
&flag_popped_dt=&clm_from_dt; 
	format &flag_popped_dt date9.; 			label &flag_popped_dt	=	&flag_popped_dt_label;
				 							label &flag_popped		=	&flag_popped_label;
&pop_age=(&clm_from_dt-&clm_dob)/365.25; 	label &pop_age			=	&pop_age_label;
&pop_age=round(&pop_age);
&pop_los=&clm_thru_dt-&clm_from_dt;			label &pop_los			=	&pop_los_label;
&pop_nch_clm_type_cd=put(&nch_clm_type_cd, clm_type_cd.); label &pop_nch_clm_type_cd	=	&pop_nch_clm_type_cd_label;
&pop_icd_dgns_cd1=put(&icd_dgns_cd1,$dgns.);
&pop_icd_prcdr_cd1=put(&icd_prcdr_cd1,$prcdr.);
&pop_hcpcs_cd=put(&hcpcs_cd,$hcpcs.);
&pop_OP_PHYSN_SPCLTY_CD=&OP_PHYSN_SPCLTY_CD; format &pop_OP_PHYSN_SPCLTY_CD speccd.;
pop_compendium_hospital_id=compendium_hospital_id;
setting_pop='OP';
setting_pop_op=1;
&pop_year=year(&flag_popped_dt);
pop_year=year(&flag_popped_dt);
pop_qtr=qtr(&flag_popped_dt);
if elig_dt = . then delete;
if &pop_year<2016 then delete;
if &pop_year>2018 then delete;
format &pop_OP_PHYSN_SPCLTY_CD $speccd. rev_cntr $rev_cntr.
		 &pop_nch_clm_type_cd $clm_typ. 
		&ptnt_dschrg_stus_cd $stuscd. &gndr_cd gender. bene_race_cd race. 
		&pop_icd_dgns_cd1  $dgns. &pop_icd_prcdr_cd1 $prcdr. &pop_hcpcs_cd $hcpcs. ;
run;
/* get rid of duplicate rows so that each bene contributes 1x per hospital/year/qtr */
proc sort data=pop_&popN._OUT NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id elig_dt; run;
proc sort data=pop_&popN._OUT NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id ; run; 

data &permlib..pop_&popN._popped
	(keep = bene_id elig: pop: setting: 
			);
set pop_&popN._OUT;
pop_year=year(&flag_popped_dt);
pop_qtr=qtr(&flag_popped_dt);
pop_prvdr_num=prvdr_num;
pop_OP_PHYSN_SPCLTY_CD=OP_PHYSN_SPCLTY_CD;
pop_prvdr_state_cd=prvdr_state_cd;
pop_at_physn_npi=at_physn_npi;
pop_op_physn_npi =op_physn_npi ;
pop_org_npi_num=org_npi_num;
pop_ot_physn_npi=ot_physn_npi;
pop_rndrng_physn_npi=rndrng_physn_npi;
pop_gndr_cd=&gndr_cd;
pop_bene_race_cd=bene_race_cd;
pop_bene_cnty_cd=bene_cnty_cd;
pop_bene_state_cd=bene_state_cd; 	
pop_bene_mlg_cntct_zip_cd=bene_mlg_cntct_zip_cd;
run;
*person can contribute only once even if seen in inpatient and outpatient in same hosp/year/qtr;
proc sort data=&permlib..pop_&popN._popped NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id elig_dt; run;
proc sort data=&permlib..pop_&popN._popped NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id; run;

*End: Identify who popped;

*Start link eligible and popped;
proc sort data=&permlib..pop_&popN._popped	NODUPKEY; by  &bene_id elig_dt;run;
proc sort data=&permlib..pop_&popN._elig	NODUPKEY; by  &bene_id elig_dt;run;

*choose POP hospital, year quarter if patient poppped, otherwise choose ELIG;
data &permlib..pop_&popN._1line_nocc 
	(	drop=elig_compendium_hospital_id elig_year elig_qtr 
		keep= bene_id elig: pop: setting:);
merge &permlib..pop_&popN._popped &permlib..pop_&popN._elig;
by &bene_id elig_dt;
if elig_compendium_hospital_id=' ' and pop_compendium_hospital_id=' ' then delete;
if pop_compendium_hospital_id=' ' then pop_compendium_hospital_id=elig_compendium_hospital_id;
label pop_compendium_hospital_id='Hospital where patient popped, if patient did not pop, the hospital where patient
	was first eligible during the quarter';
if elig_year=. and pop_year=. then delete;
if pop_year=. then pop_year=elig_year;
label pop_year='Year patient popped/was eligible';
if elig_qtr=. and pop_qtr=. then delete;
if pop_qtr=. then pop_qtr=elig_qtr;
label pop_qtr='Quarter patient popped/was eligible';
if elig_age=. and pop_age=. then delete;
if pop_age=. then pop_age=elig_age;
label pop_age='Age patient popped/was eligible';
if elig_gndr_cd=' ' and pop_gndr_cd=' ' then delete;
if pop_gndr_cd=' ' then pop_gndr_cd=elig_gndr_cd;
label pop_gndr_cd='Gender patient popped/was eligible';
format elig_dt date9.;
if pop_year<2016 then delete;
if pop_year>2018 then delete;
*delete those who were in eligibility outside range that did not pop;
if &flag_popped ne 1 and elig_year<2016 then delete;
if &flag_popped ne 1 and elig_year>2018 then delete;
if &flag_popped=. then &flag_popped=0;
popped=&flag_popped;
run;
/*allow to pop only once per qtr*/
proc sort data=&permlib..pop_&popN._1line_nocc NODUPKEY; by pop_compendium_hospital_id pop_year pop_qtr &bene_id;run;

*linkage to MBSF for comorbidities;
%include "&vrdc_code./chronic_conditions.sas";

*Start summary checks;
/**Look at freq, means, contents of final 1 record per person per quarter dataset
the eligible population, the popped population prior to final and the aggregate table
then run the requested model for the single pop**/
										
*summary checks of elig & popped & creation of aggregate table for modeling;
%include "&vrdc_code./pop_crosstabs.sas";
	
