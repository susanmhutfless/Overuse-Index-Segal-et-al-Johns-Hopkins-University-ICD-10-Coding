***ICD 10 merge*******;

libname icd10des "C:\Users\shutfle1\Box Sync\Improving Wisely\ICD code description file\ICD10CM_description";
proc contents data=icd10des.icd_10_description;run;

libname egdcolon "S:\CMS\Improving Wisely VRDC access\Programs\Coupled EGD Colonosopy";
data colon_icd10_dx_freq_1 (keep=icd_10_cm count);
set egdcolon.colon_icd10_dx_freq_1;
icd_10_cm=colon_dx_cd;
if count=999999 then count=.;
run;

data egd_icd10_dx_freq_1 (keep=icd_10_cm count);
set egdcolon.egd_icd10_dx_freq_1;
icd_10_cm=egd_dx_cd;
if count=999999 then count=.;
run;

proc sort data=icd10des.icd_10_description;by icd_10_cm;run;
proc sort data=colon_icd10_dx_freq_1; by icd_10_cm;run;
proc sort data=egd_icd10_dx_freq_1; by icd_10_cm;run;

data egd_icd10;
merge egd_icd10_dx_freq_1 (in=a) icd10des.icd_10_description (in=b);
by icd_10_cm;
if a;
run;

proc export data=egd_icd10 dbms=xlsx 
outfile="S:\CMS\Improving Wisely VRDC access\Programs\Coupled EGD Colonosopy\egd_dx_icd10" replace;
run;

data colon_icd10;
merge colon_icd10_dx_freq_1 (in=a) icd10des.icd_10_description (in=b);
by icd_10_cm;
if a;
run;

proc export data=colon_icd10 dbms=xlsx 
outfile="S:\CMS\Improving Wisely VRDC access\Programs\Coupled EGD Colonosopy\colon_dx_icd10" replace;
run;


****ICD 9 merge****;
proc import datafile= "C:\Users\shutfle1\Box Sync\Improving Wisely\ICD code description file\ICD9CM_description\CMS32_DESC_LONG_SHORT_DX.xlsx"
			out=icd9_diagnosis replace;
			getnames=yes;
run;

data  colon_icd9_dx_freq_1;
set egdcolon.colon_icd9_dx_freq_1;
DIAGNOSIS_CODE=colon_dx_cd;
if count=999999 then count=.;
run;

data  egd_icd9_dx_freq_1;
set egdcolon.egd_icd9_dx_freq_1;
DIAGNOSIS_CODE=egd_dx_cd;
if count=999999 then count=.;
run;

proc sort data=icd9_diagnosis;by diagnosis_code;run;
proc sort data=colon_icd9_dx_freq_1; by diagnosis_code;run;
proc sort data=egd_icd9_dx_freq_1; by diagnosis_code;run;

data egd_icd9 (drop=f4 egd_dx_cd);
merge egd_icd9_dx_freq_1 (in=a) icd9_diagnosis;
by diagnosis_code;
if a;
run;

proc export data=egd_icd9 dbms=xlsx 
outfile="S:\CMS\Improving Wisely VRDC access\Programs\Coupled EGD Colonosopy\egd_dx_icd9" replace;
run;

data colon_icd9 (drop=f4 colon_dx_cd);
merge colon_icd9_dx_freq_1 (in=a) icd9_diagnosis;
by diagnosis_code;
if a;
run;

proc export data=colon_icd9 dbms=xlsx 
outfile="S:\CMS\Improving Wisely VRDC access\Programs\Coupled EGD Colonosopy\colon_dx_icd9" replace;
run;
