*Pop 1 denom: ACS in inpatient (icd or drg) OR ACS in outpatient? ED (icd only);
*Pop 1 num: electrocardiogram;
%let pop1_hcpcs='93350', '93351', 'C8928', 'C8930'; 
%let pop1_icd_dx='4111', '41181', '41189';
%let pop1_icd_dx3='410';
%let pop1_drg='281', '282', '283', '284', '285', '286', '287';

*denominator for inpatient;
%macro inp_claims(source=, include_cohort=);
data &include_cohort
(keep = bene_id clm_id pop_01_de clm_admsn_dt clm_thru_dt bene_race_cd bene_cnty_cd bene_state_cd bene_mlg_cntct_zip_cd gndr_cd pop_01_age);
length pop_01_de 3;
set &source;
*DRG code qualifying;
if clm_drg_cd in(&pop1_drg) then pop1=1;
*DX code qualifying;
array dx(25) icd_dgns_cd1 - icd_dgns_cd25;
do j=1 to 25;
	if substr(dx(j),1,3) in(&pop1_icd_dx3) then do; pop1_temp=1; poa_num=j; end;
	if dx(j) in(&pop1_icd_dx) then do; pop1_temp=1; poa_num=j; end;
end;
*EXCLUDE from denom if present on admission;
array poa(25) CLM_POA_IND_SW1-CLM_POA_IND_SW25;
	do k = 1 to 25;
		if poa_num ne . and poa_num=k then do;
			poa_ind=poa(k); 
		end;
end;
if pop1_temp=1 and poa_ind ne 'Y' then pop1=1;
if pop1 ne 1 then delete;
pop_01_de=1;
pop_01_age=(clm_admsn_dt-dob_dt)/365.25;
pop_01_age=round(pop_01_age);
run;
proc sort data=&include_cohort NODUPKEY;by bene_id clm_admsn_dt;run;
%mend;
%inp_claims(source=rif2010.inpatient_claims_01, include_cohort=pop1_denom_2010_1);
%inp_claims(source=rif2010.inpatient_claims_02, include_cohort=pop1_denom_2010_2);
%inp_claims(source=rif2010.inpatient_claims_03, include_cohort=pop1_denom_2010_3);
%inp_claims(source=rif2010.inpatient_claims_04, include_cohort=pop1_denom_2010_4);
%inp_claims(source=rif2010.inpatient_claims_05, include_cohort=pop1_denom_2010_5);
%inp_claims(source=rif2010.inpatient_claims_06, include_cohort=pop1_denom_2010_6);
%inp_claims(source=rif2010.inpatient_claims_07, include_cohort=pop1_denom_2010_7);
%inp_claims(source=rif2010.inpatient_claims_08, include_cohort=pop1_denom_2010_8);
%inp_claims(source=rif2010.inpatient_claims_09, include_cohort=pop1_denom_2010_9);
%inp_claims(source=rif2010.inpatient_claims_10, include_cohort=pop1_denom_2010_10);
%inp_claims(source=rif2010.inpatient_claims_11, include_cohort=pop1_denom_2010_11);
%inp_claims(source=rif2010.inpatient_claims_12, include_cohort=pop1_denom_2010_12);
proc print data=pop1_denom_2010_1 (obs=10); run;
data pop1_denom_2010;
set pop1_denom_2010_1 pop1_denom_2010_2 pop1_denom_2010_3 pop1_denom_2010_4 pop1_denom_2010_5 pop1_denom_2010_6 pop1_denom_2010_7
pop1_denom_2010_8 pop1_denom_2010_9 pop1_denom_2010_10 pop1_denom_2010_11 pop1_denom_2010_12;
run;
proc sort data=pop1_denom_2010 NODUPKEY;by bene_id clm_admsn_dt;run;

*numerator;
%macro inp_rev(source=, include_cohort=);
proc sql;
create table &include_cohort (compress=yes) as
select a.*
from 
pop1_denom_2010 a,
&source b
where 
a.bene_id=b.bene_id
AND
a.clm_admsn_dt<=b.clm_thru_dt<=a.clm_thru_dt
AND
b.hcpcs_cd in (&pop1_hcpcs);
quit;
proc sort data=&include_cohort NODUPKEY; by bene_id clm_admsn_dt; run;
Data &include_cohort (keep=bene_id clm_admsn_dt pop_01_nu); set &include_cohort;  length pop_01_nu 3; pop_01_nu=1; run; 
%mend;
%inp_rev(source=rif2010.inpatient_revenue_01, include_cohort=pop1_num_2010_1);
%inp_rev(source=rif2010.inpatient_revenue_02, include_cohort=pop1_num_2010_2);
%inp_rev(source=rif2010.inpatient_revenue_03, include_cohort=pop1_num_2010_3);
%inp_rev(source=rif2010.inpatient_revenue_04, include_cohort=pop1_num_2010_4);
%inp_rev(source=rif2010.inpatient_revenue_05, include_cohort=pop1_num_2010_5);
%inp_rev(source=rif2010.inpatient_revenue_06, include_cohort=pop1_num_2010_6);
%inp_rev(source=rif2010.inpatient_revenue_07, include_cohort=pop1_num_2010_7);
%inp_rev(source=rif2010.inpatient_revenue_08, include_cohort=pop1_num_2010_8);
%inp_rev(source=rif2010.inpatient_revenue_09, include_cohort=pop1_num_2010_9);
%inp_rev(source=rif2010.inpatient_revenue_10, include_cohort=pop1_num_2010_10);
%inp_rev(source=rif2010.inpatient_revenue_11, include_cohort=pop1_num_2010_11);
%inp_rev(source=rif2010.inpatient_revenue_12, include_cohort=pop1_num_2010_12);
proc print data=pop1_num_2010_1 (obs=20); run;
data pop1_num_2010;
set pop1_num_2010_1 pop1_num_2010_2 pop1_num_2010_3 pop1_num_2010_4 pop1_num_2010_5 pop1_num_2010_6 pop1_num_2010_7
pop1_num_2010_8 pop1_num_2010_9 pop1_num_2010_10 pop1_num_2010_11 pop1_num_2010_12;
run;
proc sort data=pop1_num_2010 NODUPKEY;by bene_id clm_admsn_dt;run;

data pop_01;
merge pop1_denom_2010 pop1_num_2010;
by bene_id clm_admsn_dt;
if pop_01_nu=. then pop_01_nu=0;
run;
proc print data=pop_01 (obs=20); run;
Proc freq data=pop_01; table bene_state_cd*pop_01_nu; run;
proc surveyreg Data=pop_01;
class pop_01_nu bene_state_cd /*morbidity  pop_01_age*/ gndr_cd bene_race_cd;
model pop_01_de = bene_state_cd /*morbidity*/ gndr_cd pop_01_age bene_race_cd pop_01_nu/ noint solution;
ods output ParameterEstimates=jhoi;
run;

*bring in outpatient file taking into account ED visits only--this appears to be where all the action is;
rev_cntr in('0450','0451','0452','0456','0459','0981') or hcpcs_cd in ('99281', '99282', '99283', '99284', '99285');
*ask why only 2 codes, ask about POA indicator;
