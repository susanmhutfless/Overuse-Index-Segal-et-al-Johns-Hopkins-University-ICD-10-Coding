libname raw "/dcl01/alexande/data/MARKETSCAN/MarketscanOL";
libname jodi "/dcl01/alexande/data/personal/hchang24/jodi/overuse";
libname jodi1 "/dcl01/leased/jsegal/hchang24";

**NEED TO CHANGE _103_07_12 TO THE DESIRED WINDOW - AO**

**  POP Panel Data  **;
%Macro type; 
data pop_&type; set jodi1.pop_&type._103_07_12; length pop 3; pop=pop_&type._nu; keep bene_id pop pop_num; run; 
%Mend type; 
%let type=01; %type; %let type=10; %type; %let type=11; %type; %let type=20; %type; %let type=21; %type; 
%let type=26; %type; %let type=27; %type; %let type=32; %type; %let type=34; %type; %let type=36; %type; 
%let type=37; %type; %let type=41; %type; %let type=43; %type; %let type=45; %type; %let type=46; %type; 
%let type=47; %type; %let type=49; %type; %let type=50; %type; %let type=51; %type; 

data jodi1.pop_all_103_07_12; set pop_01 pop_10 pop_11 pop_20 pop_21 pop_26 pop_27 pop_32 pop_34 
pop_36 pop_37 pop_41 pop_43 pop_45 pop_46 pop_47 pop_49 pop_50 pop_51; run;
proc sort; by bene_id; run;

data a; set jodi1.cohort_patient_103_07_12; keep bene_id--sex; run;
proc sort; by bene_id; run;

Data jodi1.pop_all_103_07_12; merge a jodi1.pop_all_103_07_12 (in=a); by bene_id; if a=1; run;
proc contents Data=jodi1.pop_all_103_07_12 position; run;
proc freq Data=jodi1.pop_all_103_07_12; table age sex msa; run;

Data jodi1.pop_all_103_07_12; set jodi1.pop_all_103_07_12; length age_group $5.;
if 18<=age<=34 then age_group="18-34"; if 35<=age<=44 then age_group="35-44";
if 45<=age<=54 then age_group="45-54"; if 55<=age then age_group="55+";
run;
proc freq; table age_group; run;


**NEED TO CHANGE "jhoi" OUTPUT NAME TO SOMETHING MORE SPECIFIC - AO**

proc surveyreg Data=jodi1.pop_all_103_07_12;
class pop_num msa sex age_group;
model pop = msa sex age_group pop_num/ noint solution;
ods output ParameterEstimates=jodi1.jhoi;
run;



**  POP at Patient Level  **;
proc contents data=jodi1.cohort_patient_103_07_12 position; run;
data jodi1.cohort_patient_103_07_12; merge jodi1.cohort_patient_103_07_12 jodi1.pop_01_103_07_12 jodi1.pop_10_103_07_12 
jodi1.pop_11_103_07_12 jodi1.pop_20_103_07_12 jodi1.pop_21_103_07_12 jodi1.pop_26_103_07_12 jodi1.pop_27_103_07_12 
jodi1.pop_32_103_07_12 jodi1.pop_34_103_07_12 jodi1.pop_36_103_07_12 jodi1.pop_37_103_07_12 jodi1.pop_41_103_07_12 
jodi1.pop_43_103_07_12 jodi1.pop_45_103_07_12 jodi1.pop_46_103_07_12 jodi1.pop_47_103_07_12 jodi1.pop_49_103_07_12 
jodi1.pop_50_103_07_12 jodi1.pop_51_103_07_12; by bene_id;
run;
proc contents position; run;
 
data jodi1.cohort_patient_103_07_12; set jodi1.cohort_patient_103_07_12; drop acs pop_num clm_id; run;
data jodi1.cohort_patient_103_07_12; set jodi1.cohort_patient_103_07_12; 
array ab(38) pop_01_de--pop_51_nu; do i=1 to 38; if ab(i)=. then ab(i)=0; end;
run;
proc means; var pop_01_de--pop_51_nu; run;


**  MSA Level  **;
proc sort data=jodi1.cohort_patient_103_07_12; by msa; run;
proc summary data=jodi1.cohort_patient_103_07_12; var pop_01_de--pop_51_nu; by msa; 
output out=jodi1.cohort_msa_103_07_12 sum(
pop_01_de pop_01_nu pop_10_de pop_10_nu pop_11_de pop_11_nu pop_20_de pop_20_nu pop_21_de pop_21_nu
pop_26_de pop_26_nu pop_27_de pop_27_nu pop_32_de pop_32_nu pop_34_de pop_34_nu pop_36_de pop_36_nu
pop_37_de pop_37_nu pop_41_de pop_41_nu pop_43_de pop_43_nu pop_45_de pop_45_nu pop_46_de pop_46_nu
pop_47_de pop_47_nu pop_49_de pop_49_nu pop_50_de pop_50_nu pop_51_de pop_51_nu) =
pop_01_de pop_01_nu pop_10_de pop_10_nu pop_11_de pop_11_nu pop_20_de pop_20_nu pop_21_de pop_21_nu
pop_26_de pop_26_nu pop_27_de pop_27_nu pop_32_de pop_32_nu pop_34_de pop_34_nu pop_36_de pop_36_nu
pop_37_de pop_37_nu pop_41_de pop_41_nu pop_43_de pop_43_nu pop_45_de pop_45_nu pop_46_de pop_46_nu
pop_47_de pop_47_nu pop_49_de pop_49_nu pop_50_de pop_50_nu pop_51_de pop_51_nu; run;

proc contents position; run;
Data jodi1.cohort_msa_103_07_12; set jodi1.cohort_msa_103_07_12; drop _freq_ _type_; run;
proc freq; table pop_01_de--pop_51_nu; run;

