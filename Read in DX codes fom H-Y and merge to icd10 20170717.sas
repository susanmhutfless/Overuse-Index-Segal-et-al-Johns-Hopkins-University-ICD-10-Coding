*Segal overuse project;
*Read in ICD-9 codes provided by Hsien-Yen, crosswalk to ICD-10 codes;

*susie; libname segal "V:\Segal overuse"; run;
*lena; 

data dx; set segal.icd_indicator_susan; run;*n rows=2378;*all codes are dx in this file;
proc contents data=dx; run; *icd char 5;
proc print data=dx (obs=10); run;


*crosswalk source: https://www.nber.org/data/icd9-icd-10-cm-and-pcs-crosswalk-general-equivalence-mapping.html;
data cross (keep = icd icd10cm); 
set segal.icd9toicd10cmgem; 
icd=icd9cm;
run;
proc contents data=cross; run; *icd char 5;
proc print data=cross (obs=10); run;

proc sort data=dx; by icd;
proc sort data=cross; by icd;
run;*confirmed formats of icd variable are the same;

data dx9_10;
retain icd icd10cm;
merge dx (in=a) cross (in=b);
by icd;
if a;
run;*n rows=4553;
proc print data=dx9_10 (obs=500); run;

*add in dx9&dx10 labels;
*source: https://www.cms.gov/Medicare/Coding/ICD9ProviderDiagnosticCodes/codes.html;
*https://www.nber.org/data/icd-10-cm-mappings.html;
*icd9;
proc import datafile='V:\Segal overuse\CMS32_DESC_LONG_SHORT_DX.xlsx' dbms=xlsx out=dx9_desc; run;
proc contents data=dx9_desc; run;
proc print data=dx9_desc (obs=10); run;
data dx9_desc2 (drop=diagnosis_code long_description short_description d); set dx9_desc;
icd=diagnosis_code;
icd9_description=long_description;
run;
proc print data=dx9_desc2; run;

*add icd9 labels;
proc sort data=dx9_10; by icd;
proc sort data=dx9_desc2; by icd;
run;

data dx9_10v2;
merge
dx9_10 (in=a) dx9_desc2 (in=b);
by icd;
if a;
run;*4553;
proc print data=dx9_10v2 (obs=10); run;
proc contents data=dx9_10v2; run;

*icd10;
proc import datafile='V:\Segal overuse\icd_10_cm_mappings2018.csv' dbms=csv out=dx10_desc; run;
proc contents data=dx10_desc; run;
data dx10_desc2 (drop= dgns_cd description hcc: fyear); length icd10cm $7.; set dx10_desc;
icd10cm= dgns_cd;
icd10_description=description;
run;
proc print data=dx10_desc2 (obs=10); run;

proc sort data=dx9_10v2; by icd10cm;
proc sort data=dx10_desc2; by icd10cm;
run;

data dx9_10v3 (drop = icd);
retain icd9cm icd10cm icd9_description icd10_description;
merge
dx9_10v2 (in=a) dx10_desc2 (in=b);
by icd10cm;
if a;
icd9cm=icd;
run;*4553;
proc print data=dx9_10v3; where icd9_description=' ';run;*17 missing ICD-9-cm description (=this is problematic--figure out why);
proc print data=dx9_10v3; where icd10_description=' ';run;*3491;*those missing are thsoe that don't link to a HCC (either not common ICD-9-CM or outside of scope for HCC groupings--could be examined/reconsidered);
proc print data=dx9_10v3; where icd9_description=' ' and icd10_description=' ';run;*17--same 17 as above;
proc print data=dx9_10v3; where icd9cm ne ' ' and icd10cm=' ';run;*17--same 17 as above;
proc print data=dx9_10v3 (obs=10); where icd10cm ne ' ';* and icd9cm=' ';run;*0--all icd10 correspond to icd9 (as they should);
PROC EXPORT DATA= dx9_10v3
OUTFILE= "V:\Segal overuse\Overuse Pop ICD9 to 10 crosswalked July 2019.csv"
DBMS=csv REPLACE;
RUN;

*patient file;

File name: patient
Description: patient-level information
Unit: one record per patient
Variables and Definitions:
bene_id: unique patient ID
sex: 'F' or 'M'
date_death: date of death (in SAS format)
death: a binary indicator of death in the observation period
date_birth: date of birth (in SAS format)
Age: a continuous variable
Age_group: a categorical variable 
Region: a categorical variable showing where the individual lives
Researchers can decide what to use, such as HRR 
Race: a categorical variable 
Morbidity: a categorical variable showing the morbidity of an individual 
