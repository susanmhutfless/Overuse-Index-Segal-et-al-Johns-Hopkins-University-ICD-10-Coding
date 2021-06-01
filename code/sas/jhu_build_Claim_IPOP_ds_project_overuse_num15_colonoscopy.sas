/********************************************************************
* Job Name: jhu_build_Claim_IPOP_ds_project_overuse_num15_colonoscopy.sas
* Job Desc: Input for Inpatient & Outpatient (Including Carrier) Claims 
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************/

/*** start of indicator specific variables ***/

/*global variables for inclusion and exclusion*/
%global includ_hcpcs 
		includ_pr10  includ_pr10_n
		includ_dx10  includ_dx10_n 
		EXCLUD_dx10  exclud_dx10_n;

/*inclusion criteria*/
		*people over 80;

%let includ_hcpcs =
					'45378'	'45379'	'45380'	'45381'
					'45382'	'45383'	'45384'	'45385'	
					'45386'	'45387'	'45388'	'45389'
					'45390'	'45391'	'45392'	'45393'
					'45394'	'45395'	'45396'	'45397'
					'45398'	'G0105'	'G0121'	'45330'
					'45331'	'45332'	'45333'	'45334'
					'45335'	'45336'	'45337'	'45338'	
					'45339'	'45340'	'45341'	'45342'
					'45343'	'45344'	'45345'	'45346'	
					'45347'	'45348'	'45349'	'45350'
					'88305'	'G0104'		;		*use for popped visit;



%let includ_pr10 =
					'0'			; 
%let includ_pr10_n = 7;		*this number should match number that needs to be substringed;

%let includ_dx10   = 'Z1211';						*use for popped visit; 
%let includ_dx10_n = 5;		*this number should match number that needs to be substringed;
%let includ_drg = '0';

/** Exclusion criteria **/
%let exclud_hcpcs= '0'; 					

%let EXclud_pr10 =	'0'				; 
%let EXclud_pr10_n = 7;	

%let EXCLUD_dx10   = '0'; 						
%let exclud_dx10_n = 7; 

/** Label pop specific variables  **/
%global popN;
%let	popN							= 15;
%let	poptext							= "colonoscopy"; 
%let 	flag_popped             		= popped15 								;
%let 	flag_popped_label				= 'indicator 15 popped'					;	
%let	flag_popped_dt					= popped15_dt							;
%let 	flag_popped_dt_label			= 'indicator 15 date patient popped (IP=clm_admsn_dt OP=clm_from_dt)'	;
%let 	pop_age							= pop_15_age							;				
%let	pop_age_label					= 'age popped for pop 15'				;
%let	pop_los							= pop_15_los							;
%let	pop_los_label					= 'length of stay when patient popped'	;
%let	pop_year						= pop_15_year							;
%let	pop_nch_clm_type_cd				= pop_15_nch_clm_type_cd				;
%let  	pop_CLM_IP_ADMSN_TYPE_CD		= pop_15_CLM_IP_ADMSN_TYPE_CD			;
%let	pop_clm_fac_type_cd				= pop_15_clm_fac_type_cd				;
%let	pop_clm_src_ip_admsn_cd			= pop_15_clm_src_ip_admsn_cd			;
%let	pop_ptnt_dschrg_stus_cd  		= pop_15_ptnt_dschrg_stus_cd			;
%let	pop_admtg_dgns_cd				= pop_15_admtg_dgns_cd					;
%let	pop_icd_dgns_cd1				= pop_15_icd_dgns_cd1					;
%let	pop_icd_prcdr_cd1				= pop_15_icd_prcdr_cd1					;
%let	pop_clm_drg_cd					= pop_15_clm_drg_cd						;
%let	pop_hcpcs_cd					= pop_15_hcpcs_cd						;
%let	pop_OP_PHYSN_SPCLTY_CD			= pop_15_OP_PHYSN_SPCLTY_CD				;
%let	pop_nch_clm_type_cd				= pop_15_nch_clm_type_cd				;
%let	pop_nch_clm_type_cd_label		= 'claim/facility type for pop 15' 		;
%let	pop_CLM_IP_ADMSN_TYPE_CD_label	= 'inpatient admission type code for pop 15'	;
%let  	pop_clm_fac_type_cd_label		= 'inpatient clm_fac_type_cd for pop 15';
%let	pop_clm_src_ip_admsn_cd_label	= 'clm_src_ip_admsn_cd for pop 15'		;
%let	pop_ptnt_dschrg_stus_cd_label	= 'discharge status code for pop 15'	;	
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
/*revenue center for inpatient/outpatient identifies ED*/
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
*First identify all who are eligible;

/*** this macro is for inpatient and outpatient claims--must have DX code of interest***/
%macro claims_rev(date=,	source=,  rev_cohort=, include_cohort=, ccn=);
*identify dx codes of interest;
proc sql;
	create table include_cohort1 (compress=yes) as
select * 
from 
&source
where 
		(	((&date-&clm_dob)/365.25) >=80	
		 )	;
quit;
*link to ahrq ccn so in hospital within a health system;
proc sql;
	create table include_cohort2 (compress=yes) as
select *
from 
	&permlib..ahrq_ccn a,
	include_cohort1 b	
where 
	b.prvdr_num = a.&ccn
;
quit;
*link to revenue center and hcpcs;
proc sql;
create table include_cohort3 (compress=yes) as
select a.*, b.&rev_cntr, b.&hcpcs_cd
from 
	include_cohort2 a,
	&rev_cohort b
where 
	a.&bene_id = b.&bene_id 
	and 
	a.&clm_id = b.&clm_id;
quit;
*transpose the revenue/hcpcs to 1 row per bene/clm;
proc sort data=include_cohort3 nodupkey out=hcpcs_transposed; by &bene_id &clm_id &hcpcs_cd; run;
proc transpose data=hcpcs_transposed out=hcpcs_transposed (drop = _name_ _label_) prefix=hcpcs_cd;
    by &bene_id &clm_id ;
    var &hcpcs_cd;
run;

proc sort data=include_cohort3 nodupkey out=rev_transposed; by &bene_id &clm_id &rev_cntr; run;
proc transpose data=rev_transposed out=rev_transposed (drop = _name_ _label_) prefix=rev_cntr;
    by &bene_id &clm_id ;
    var &rev_cntr;
run;
*make inclusion/exclusion criteria and set variables for eligible population;
data &include_cohort ; 
merge 	include_cohort2 
		hcpcs_transposed
		rev_transposed; 
by &bene_id &clm_id ;
array rev{*} rev_cntr:;
do r=1 to dim(rev);
	if rev(r) in(&ED_rev_cntr) then elig_ed=1;	
end;
label elig_ed='eligible visit: revenue center indicated emergency department'; 
elig_dt=&date;
elig_age=(&date-&clm_dob)/365.25; label elig_age='age at eligibility';
if &clm_end_dt_in ne . then do;
	elig_los=&clm_end_dt_in-&date;	label elig_los ='length of stay at eligbility';
end;
if elig_los =. then do;
	elig_los=&clm_thru_dt-&date;	label elig_los ='length of stay at eligbility';
end;
elig=1;
pop_num=&popN;
run; 
*delete the temp datasets;
proc datasets lib=work nolist;
 delete include: ;
quit;
run;
%mend;
%include "&vrdc_code./elig_op.sas";

data pop_&popN._OUTinclude (keep= &bene_id &clm_id elig_dt elig: setting_elig:
							pop_num elig_compendium_hospital_id   &gndr_cd &clm_dob bene_race_cd
							&clm_from_dt &clm_thru_dt   &ptnt_dschrg_stus_cd
							&nch_clm_type_cd &clm_fac_type_cd  
							hcpcs_cd1
							&diag_pfx.&diag_cd_min   &proc_pfx.&proc_cd_min
							prvdr_num prvdr_state_cd OP_PHYSN_SPCLTY_CD rev_cntr1
							at_physn_npi op_physn_npi org_npi_num ot_physn_npi rndrng_physn_npi
							/*RFR_PHYSN_NPI*/
							bene_cnty_cd bene_state_cd 	bene_mlg_cntct_zip_cd
						);
set pop_&popN._OUTinclude: 	;
setting_elig='OP';
setting_elig_op=1;
elig_compendium_hospital_id=compendium_hospital_id;
elig_year=year(elig_dt);
elig_qtr=qtr(elig_dt);
elig_prvdr_num=prvdr_num;
elig_OP_PHYSN_SPCLTY_CD=OP_PHYSN_SPCLTY_CD;
elig_prvdr_state_cd=prvdr_state_cd;
elig_at_physn_npi=at_physn_npi;
elig_op_physn_npi =op_physn_npi ;
elig_org_npi_num=org_npi_num;
elig_ot_physn_npi=ot_physn_npi;
elig_rndrng_physn_npi=rndrng_physn_npi;
elig_gndr_cd=&gndr_cd;
elig_bene_race_cd=bene_race_cd;
elig_bene_cnty_cd=bene_cnty_cd;
elig_bene_state_cd=bene_state_cd; 	
elig_bene_mlg_cntct_zip_cd=bene_mlg_cntct_zip_cd;
format bene_state_cd prvdr_state_cd $state. OP_PHYSN_SPCLTY_CD $speccd. rev_cntr1 $rev_cntr.
		 &nch_clm_type_cd $clm_typ. 
		&ptnt_dschrg_stus_cd $stuscd. &gndr_cd gender. bene_race_cd race. 
		&icd_dgns_cd1  $dgns. &icd_prcdr_cd1 $prcdr. hcpcs_cd1 $hcpcs. ;
run;
run;
/* get rid of duplicate rows so that each bene contributes 1x per hospital/year/qtr */
proc sort data=pop_&popN._OUTinclude NODUPKEY; by elig_compendium_hospital_id elig_year elig_qtr &bene_id elig_dt; run;
proc sort data=pop_&popN._OUTinclude NODUPKEY; by elig_compendium_hospital_id elig_year elig_qtr &bene_id ; run; 

data &permlib..pop_&popN._elig;
set 	pop_&popN._OUTinclude  ;		
run;
*person can contribute only once even if seen in inpatient and outpatient in same hosp/year/qtr;
proc sort data=&permlib..pop_&popN._elig NODUPKEY; by elig_compendium_hospital_id elig_year elig_qtr &bene_id ;run;

*end identification of eligibility;

*Start: Identify who popped;
%macro claims_rev(date=, source=, rev_cohort=, include_cohort=, ccn=);
* identify hcpcs ;
proc sql;
create table include_cohort1a (compress=yes) as
select a.&bene_id, a.&clm_id, a.&rev_cntr,
	a.&hcpcs_cd, case when a.&hcpcs_cd in (&includ_hcpcs) then 1 else 0 end as &flag_popped
from 
	&rev_cohort a,
	&permlib..pop_&popN._elig b
where 
	a.&hcpcs_cd in (&includ_hcpcs)
	and
	a.&bene_id = b.&bene_id;
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
*pull icd diagnosis criteria from claims*;
proc sql;
	create table include_cohort1d (compress=yes) as
select a.*
from 
	&source a,
	&permlib..pop_&popN._elig b
where
a.&bene_id=b.&bene_id
and 
	(	a.icd_dgns_cd1 in(&includ_dx10) or
		a.icd_dgns_cd2 in(&includ_dx10) or
		a.icd_dgns_cd3 in(&includ_dx10) or
		a.icd_dgns_cd4 in(&includ_dx10) or
		a.icd_dgns_cd5 in(&includ_dx10) or
		a.icd_dgns_cd6 in(&includ_dx10) or
		a.icd_dgns_cd7 in(&includ_dx10) or
		a.icd_dgns_cd8 in(&includ_dx10) or
		a.icd_dgns_cd9 in(&includ_dx10) or
		a.icd_dgns_cd10 in(&includ_dx10) or
		a.icd_dgns_cd11 in(&includ_dx10) or
		a.icd_dgns_cd12 in(&includ_dx10) or
		a.icd_dgns_cd13 in(&includ_dx10) or
		a.icd_dgns_cd14 in(&includ_dx10) or
		a.icd_dgns_cd15 in(&includ_dx10) or
		a.icd_dgns_cd16 in(&includ_dx10) or
		a.icd_dgns_cd17 in(&includ_dx10) or
		a.icd_dgns_cd18 in(&includ_dx10) or
		a.icd_dgns_cd19 in(&includ_dx10) or
		a.icd_dgns_cd20 in(&includ_dx10) or
		a.icd_dgns_cd21 in(&includ_dx10) or
		a.icd_dgns_cd22 in(&includ_dx10) or
		a.icd_dgns_cd23 in(&includ_dx10) or
		a.icd_dgns_cd24 in(&includ_dx10) or
		a.icd_dgns_cd25 in(&includ_dx10)		);
quit;
/*link icd dx identified to revenue center*;
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
*/
* link to CCN ;
proc sql;
	create table include_cohort1f (compress=yes) as
select *
from 
	&permlib..ahrq_ccn a,
	include_cohort1d b	
where 
	b.prvdr_num = a.&ccn
;
quit;
*merge HCPCS and PRCDR identified pops together;
Data include_cohort1g; 
set include_cohort1c include_cohort1f; 
/*array rev{*} rev_cntr:;
do r=1 to dim(rev);
	if rev(r) in(&ED_rev_cntr) then pop_ed=1;	
end; 
label pop_ed='popped: revenue center indicated emergency department';*/
&flag_popped_dt=&date; 
	format &flag_popped_dt date9.; 						label &flag_popped_dt			=	&flag_popped_dt_label;
				 										label &flag_popped				=	&flag_popped_label;
array dx(&diag_cd_max) &diag_pfx.&diag_cd_min - &diag_pfx.&diag_cd_max;
do j=1 to &diag_cd_max;
	if substr(dx(j),1,&includ_dx10_n) in(&includ_dx10) then &flag_popped=1;
	if substr(dx(j),1,&exclud_dx10_n) in(&exclud_dx10) then DELETE=1;	
end;
if DELETE = 1 then delete;
*if clm_drg_cd notin(&includ_drg) then delete;
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
		a.elig_dt=b.&flag_popped_dt								
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
	(keep = bene_id elig: pop: setting: 			);
set  pop_&popN._OUT;
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
proc sort data=&permlib..pop_&popN._popped		NODUPKEY; by  &bene_id elig_dt;run;
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

