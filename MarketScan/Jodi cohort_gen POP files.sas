libname raw "/dcl01/alexande/data/MARKETSCAN/MarketscanOL";
libname jodi "/dcl01/alexande/data/personal/hchang24/jodi/overuse";
libname jodi1 "/dcl01/leased/jsegal/hchang24";


**  Generate Files for JHOI  **;
**  Patient file  **;
%Macro tx;
Data jodi.cohort_patient_&tx._01_06; set jodi.denominator_&tx; where age_&tx._18up=1 and enrol_&tx._01_06=1; length sex $1.;
rename age_&tx=age; if sex_&tx="1" then sex="M"; if sex_&tx="2" then sex="F"; rename egeoloc_&tx=egeoloc; rename msa_&tx=msa;
rename enrolid=bene_id; keep enrolid age_&tx sex egeoloc_&tx msa_&tx; run;
proc sort nodupkey; by bene_id; run;
Data jodi.cohort_patient_&tx._07_12; set jodi.denominator_&tx; where age_&tx._18up=1 and enrol_&tx._07_12=1; length sex $1.;
rename age_&tx=age; if sex_&tx="1" then sex="M"; if sex_&tx="2" then sex="F"; rename egeoloc_&tx=egeoloc; rename msa_&tx=msa;
rename enrolid=bene_id; keep enrolid age_&tx sex egeoloc_&tx msa_&tx; run;
proc sort nodupkey; by bene_id; run;
%Mend tx;
%let tx=103;%tx; %let tx=112;%tx; %let tx=121;%tx; %let tx=131;%tx; %let tx=141;%tx; %let tx=151;%tx; 


**  Claims file  **;
%Macro tx;
Data a; set jodi.cohort_ip_&tx; length place_of_service $2.; place_of_service="IP"; clm_id=caseid; keep enrolid clm_id date_from date_end place_of_service; run;
Data b; set jodi.cohort_op_&tx; where proc1 not in ("99281" "99282" "99283" "99284" "99285");
length place_of_service $2.; place_of_service="OP"; clm_id=seqnum; keep enrolid clm_id date_from date_end place_of_service; run;
Data c; set jodi.cohort_op_&tx; where proc1 in ("99281" "99282" "99283" "99284" "99285");
length place_of_service $2.; place_of_service="ER"; clm_id=seqnum; keep enrolid clm_id date_from date_end place_of_service; run;
Data jodi.cohort_claims_&tx; set a b c; rename enrolid=bene_id; run;
%Mend tx;
%let tx=103_01_06;%tx; %let tx=112_01_06;%tx; %let tx=121_01_06;%tx; %let tx=131_01_06;%tx; %let tx=141_01_06;%tx; %let tx=151_01_06;%tx; 
%let tx=103_07_12;%tx; %let tx=112_07_12;%tx; %let tx=121_07_12;%tx; %let tx=131_07_12;%tx; %let tx=141_07_12;%tx; %let tx=151_07_12;%tx; 


** Proc file  **;
%Macro tx;
Data a1; set jodi.cohort_ip_&tx; where pproc ne ""; length place_of_service $2. proc_num 5; place_of_service="IP"; clm_id=caseid; 
proc=pproc; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;
Data a2; set jodi.cohort_ip_&tx; where proc1 ne ""; length place_of_service $2. proc_num 5; place_of_service="IP"; 
clm_id=caseid; proc=proc1; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;
Data a3; set jodi.cohort_ip_&tx; where proc2 ne ""; length place_of_service $2. proc_num 5; place_of_service="IP"; 
clm_id=caseid; proc=proc2; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;
Data a4; set jodi.cohort_ip_&tx; where proc3 ne ""; length place_of_service $2. proc_num 5; place_of_service="IP"; 
clm_id=caseid; proc=proc3; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;
Data a5; set jodi.cohort_ip_&tx; where proc4 ne ""; length place_of_service $2. proc_num 5; place_of_service="IP";
clm_id=caseid; proc=proc4; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;
Data a6; set jodi.cohort_ip_&tx; where proc5 ne ""; length place_of_service $2. proc_num 5; place_of_service="IP"; 
clm_id=caseid; proc=proc5; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;
Data a7; set jodi.cohort_ip_&tx; where proc6 ne ""; length place_of_service $2. proc_num 5; place_of_service="IP"; 
clm_id=caseid; proc=proc6; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;
Data a8; set jodi.cohort_ip_&tx; where proc7 ne ""; length place_of_service $2. proc_num 5; place_of_service="IP"; 
clm_id=caseid; proc=proc7; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;
Data a9; set jodi.cohort_ip_&tx; where proc8 ne ""; length place_of_service $2. proc_num 5; place_of_service="IP"; 
clm_id=caseid; proc=proc8; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;
Data a10; set jodi.cohort_ip_&tx; where proc9 ne ""; length place_of_service $2. proc_num 5; place_of_service="IP"; 
clm_id=caseid; proc=proc9; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;
Data a11; set jodi.cohort_ip_&tx; where proc10 ne ""; length place_of_service $2. proc_num 5; place_of_service="IP"; 
clm_id=caseid; proc=proc10; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;
Data a12; set jodi.cohort_ip_&tx; where proc11 ne ""; length place_of_service $2. proc_num 5; place_of_service="IP"; 
clm_id=caseid; proc=proc11; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;
Data a13; set jodi.cohort_ip_&tx; where proc12 ne ""; length place_of_service $2. proc_num 5; place_of_service="IP"; 
clm_id=caseid; proc=proc12; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;
Data a14; set jodi.cohort_ip_&tx; where proc13 ne ""; length place_of_service $2. proc_num 5; place_of_service="IP"; 
clm_id=caseid; proc=proc13; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;
Data a15; set jodi.cohort_ip_&tx; where proc14 ne ""; length place_of_service $2. proc_num 5; place_of_service="IP"; 
clm_id=caseid; proc=proc14; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;
Data a16; set jodi.cohort_ip_&tx; where proc15 ne ""; length place_of_service $2. proc_num 5; place_of_service="IP"; 
clm_id=caseid; proc=proc15; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;

Data b1; set jodi.cohort_ips_&tx; where pproc ne ""; length place_of_service $2. proc_num 5; place_of_service="IP"; 
clm_id=caseid; proc=pproc; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;
Data b2; set jodi.cohort_ips_&tx; where proc1 ne ""; length place_of_service $2. proc_num 5; place_of_service="IP"; 
clm_id=caseid; proc=proc1; proc_num=proc*1; keep enrolid clm_id date_from place_of_service proc proc_num; run;

Data c1; set jodi.cohort_op_&tx; where proc1 not in ("99281" "99282" "99283" "99284" "99285"); 
length place_of_service $2. proc_num 5; place_of_service="OP"; clm_id=seqnum; proc=proc1; proc_num=proc*1; 
keep enrolid clm_id date_from place_of_service proc proc_num; run;

Data d1; set jodi.cohort_op_&tx; where proc1 in ("99281" "99282" "99283" "99284" "99285"); 
length place_of_service $2. proc_num 5; place_of_service="ER"; clm_id=seqnum; proc=proc1; proc_num=proc*1; 
keep enrolid clm_id date_from place_of_service proc proc_num; run;

Data jodi.cohort_proc_&tx; set a1-a16 b1-b2 c1 d1; rename enrolid=bene_id; run;
proc sort nodup; by bene_id clm_id; run;
%Mend tx;
%let tx=103_01_06;%tx; %let tx=112_01_06;%tx; %let tx=121_01_06;%tx; %let tx=131_01_06;%tx; %let tx=141_01_06;%tx; %let tx=151_01_06;%tx; 
%let tx=103_07_12;%tx; %let tx=112_07_12;%tx; %let tx=121_07_12;%tx; %let tx=131_07_12;%tx; %let tx=141_07_12;%tx; %let tx=151_07_12;%tx; 


** ICD file  **;
%Macro tx;
Data a1; set jodi.cohort_ip_&tx; where pdx ne ""; length place_of_service $2. position 3; position=1; 
place_of_service="IP"; clm_id=caseid; icd=pdx; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data a2; set jodi.cohort_ip_&tx; where dx1 ne ""; length place_of_service $2. position 3; position=2; 
place_of_service="IP"; clm_id=caseid; icd=dx1; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data a3; set jodi.cohort_ip_&tx; where dx2 ne ""; length place_of_service $2. position 3; position=3; 
place_of_service="IP"; clm_id=caseid; icd=dx2; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data a4; set jodi.cohort_ip_&tx; where dx3 ne ""; length place_of_service $2. position 3; position=4; 
place_of_service="IP"; clm_id=caseid; icd=dx3; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data a5; set jodi.cohort_ip_&tx; where dx4 ne ""; length place_of_service $2. position 3; position=5; 
place_of_service="IP"; clm_id=caseid; icd=dx4; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data a6; set jodi.cohort_ip_&tx; where dx5 ne ""; length place_of_service $2. position 3; position=6; 
place_of_service="IP"; clm_id=caseid; icd=dx5; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data a7; set jodi.cohort_ip_&tx; where dx6 ne ""; length place_of_service $2. position 3; position=7; 
place_of_service="IP"; clm_id=caseid; icd=dx6; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data a8; set jodi.cohort_ip_&tx; where dx7 ne ""; length place_of_service $2. position 3; position=8; 
place_of_service="IP"; clm_id=caseid; icd=dx7; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data a9; set jodi.cohort_ip_&tx; where dx8 ne ""; length place_of_service $2. position 3; position=9; 
place_of_service="IP"; clm_id=caseid; icd=dx8; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data a10; set jodi.cohort_ip_&tx; where dx9 ne ""; length place_of_service $2. position 3; position=10; 
place_of_service="IP"; clm_id=caseid; icd=dx9; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data a11; set jodi.cohort_ip_&tx; where dx10 ne ""; length place_of_service $2. position 3; position=11; 
place_of_service="IP"; clm_id=caseid; icd=dx10; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data a12; set jodi.cohort_ip_&tx; where dx11 ne ""; length place_of_service $2. position 3; position=12; 
place_of_service="IP"; clm_id=caseid; icd=dx11; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data a13; set jodi.cohort_ip_&tx; where dx12 ne ""; length place_of_service $2. position 3; position=13; 
place_of_service="IP"; clm_id=caseid; icd=dx12; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data a14; set jodi.cohort_ip_&tx; where dx13 ne ""; length place_of_service $2. position 3; position=14; 
place_of_service="IP"; clm_id=caseid; icd=dx13; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data a15; set jodi.cohort_ip_&tx; where dx14 ne ""; length place_of_service $2. position 3; position=15; 
place_of_service="IP"; clm_id=caseid; icd=dx14; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data a16; set jodi.cohort_ip_&tx; where dx15 ne ""; length place_of_service $2. position 3; position=16; 
place_of_service="IP"; clm_id=caseid; icd=dx15; keep enrolid clm_id date_from date_end place_of_service position icd; run;

Data b1; set jodi.cohort_ips_&tx; where pdx ne ""; length place_of_service $2. position 3; position=1; 
place_of_service="IP"; clm_id=caseid; icd=pdx; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data b2; set jodi.cohort_ips_&tx; where dx1 ne ""; length place_of_service $2. position 3; position=2; 
place_of_service="IP"; clm_id=caseid; icd=dx1; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data b3; set jodi.cohort_ips_&tx; where dx2 ne ""; length place_of_service $2. position 3; position=3; 
place_of_service="IP"; clm_id=caseid; icd=dx2; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data b4; set jodi.cohort_ips_&tx; where dx3 ne ""; length place_of_service $2. position 3; position=4; 
place_of_service="IP"; clm_id=caseid; icd=dx3; keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data b5; set jodi.cohort_ips_&tx; where dx4 ne ""; length place_of_service $2. position 3; position=5; 
place_of_service="IP"; clm_id=caseid; icd=dx4; keep enrolid clm_id date_from date_end place_of_service position icd; run;

Data c1; set jodi.cohort_op_&tx; where proc1 not in ("99281" "99282" "99283" "99284" "99285"); 
length place_of_service $2. position 3; position=1; place_of_service="OP"; clm_id=seqnum; icd=dx1; 
keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data c2; set jodi.cohort_op_&tx; where proc1 not in ("99281" "99282" "99283" "99284" "99285"); 
length place_of_service $2. position 3; position=2; place_of_service="OP"; clm_id=seqnum; icd=dx2; 
keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data c3; set jodi.cohort_op_&tx; where proc1 not in ("99281" "99282" "99283" "99284" "99285"); 
length place_of_service $2. position 3; position=3; place_of_service="OP"; clm_id=seqnum; icd=dx3; 
keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data c4; set jodi.cohort_op_&tx; where proc1 not in ("99281" "99282" "99283" "99284" "99285"); 
length place_of_service $2. position 3; position=4; place_of_service="OP"; clm_id=seqnum; icd=dx4; 
keep enrolid clm_id date_from date_end place_of_service position icd; run;

Data d1; set jodi.cohort_op_&tx; where proc1 in ("99281" "99282" "99283" "99284" "99285"); 
length place_of_service $2. position 3; position=1; place_of_service="ER"; clm_id=seqnum; icd=dx1; 
keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data d2; set jodi.cohort_op_&tx; where proc1 in ("99281" "99282" "99283" "99284" "99285"); 
length place_of_service $2. position 3; position=2; place_of_service="ER"; clm_id=seqnum; icd=dx2; 
keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data d3; set jodi.cohort_op_&tx; where proc1 in ("99281" "99282" "99283" "99284" "99285"); 
length place_of_service $2. position 3; position=3; place_of_service="ER"; clm_id=seqnum; icd=dx3; 
keep enrolid clm_id date_from date_end place_of_service position icd; run;
Data d4; set jodi.cohort_op_&tx; where proc1 in ("99281" "99282" "99283" "99284" "99285"); 
length place_of_service $2. position 3; position=4; place_of_service="ER"; clm_id=seqnum; icd=dx4; 
keep enrolid clm_id date_from date_end place_of_service position icd; run;

Data jodi1.cohort_icd_&tx; set a1-a16 b1-b5 c1-c4 d1-d4; rename enrolid=bene_id; run;
proc sort nodup; by bene_id clm_id; run;
%Mend tx;
%let tx=103_01_06;%tx; 
%let tx=112_01_06;%tx; %let tx=121_01_06;%tx; %let tx=131_01_06;%tx; %let tx=141_01_06;%tx; %let tx=151_01_06;%tx; 
%let tx=103_07_12;%tx; %let tx=112_07_12;%tx; %let tx=121_07_12;%tx; %let tx=131_07_12;%tx; %let tx=141_07_12;%tx; %let tx=151_07_12;%tx; 


** DRG file  **;
%Macro tx;
Data a1; set jodi.cohort_ip_&tx; if drg ne .; clm_id=caseid; keep enrolid clm_id date_from drg; run;
Data b1; set jodi.cohort_ips_&tx; if drg ne .; clm_id=caseid; keep enrolid clm_id date_from drg; run;

Data jodi1.cohort_drg_&tx; set a1 b1; rename enrolid=bene_id; run;
proc sort nodup; by bene_id clm_id; run;
%Mend tx;
%let tx=103_01_06;%tx; %let tx=112_01_06;%tx; %let tx=121_01_06;%tx; %let tx=131_01_06;%tx; %let tx=141_01_06;%tx; %let tx=151_01_06;%tx; 
%let tx=103_07_12;%tx; %let tx=112_07_12;%tx; %let tx=121_07_12;%tx; %let tx=131_07_12;%tx; %let tx=141_07_12;%tx; %let tx=151_07_12;%tx; 


**  POP Marker  **;
** Procedure Code  **;
%Macro tx;
Data jodi1.cohort_proc_&tx; set jodi1.cohort_proc_&tx;
if PROC in ("99281" "99282" "99283" "99284" "99285") then er_visit=1; /* pop 1 */
if PROC in ("93350" "93351" "C8928" "C8930") then stress_echocardiography=1; /*pop 1*/
if PROC in ("22533" "22534" "22558" "22630" "0275T" "63005" "63012" "63017" "63030" "63035" "63042" "63047" "63200" "63267" "63272" "63173" "63185" "63190" "63191") then laminectomy=1; /*pop 10*/
if PROC in ("58150" "58152" "58180" "58200" "52810" "58260" "58262" "58263" "58267" "58270" "58275" "58280" "58285" "58290" "58291" "58292" "59293" "59294" "58541" "58542" "58543" "58544" "58548" "58550" "58552" "58553" "58554" "58570" "58571" "58572" "58573") then hysterectomy=1; /*pop 11*/
if PROC in ("31575" "31476" "31577" "31578" "31579") then fiberoptic_laryngoscopy=1; /*pop 20*/
if PROC in ("31231" "31233" "31235") then diagnostic_endoscopy=1; /*pop 21*/
if PROC in ("99281" "99282" "99283" "99284" "99285") then er_visit=1; /* pop 24/26 */
if PROC in ("80162") then digoxin=1; /*pop 26*/
if PROC in ("3650F" "95812" "95813" "95816" "95819" "95822" "95827") then EEG=1; /*pop 27*/
if PROC in ("86677") then h_pylori_test=1; /*pop 32*/
if PROC in ("70551" "70552" "70553") then MRI_brain=1; /*pop 34*/
if PROC in ("78811" "78812" "78813" "78814" "78815" "78816" "72192" "72193" "72194" "3269F" "77074" "77075") then prostate_scan=1; /*pop 36*/
if PROC in ("78811" "78812" "78813" "78814" "78815" "78816") then pet_scan=1; /*pop 36*/
if PROC in ("3272F" "3273F") then prostate_risk=1; /*pop 36*/
if PROC in ("97012" "97140" "E0830") then traction=1; /*pop 37*/
if PROC in ("93880") then carotid_ultrasound=1; /*pop 41*/
if PROC in ("3100F") then carotid_image=1; /*pop 41*/
if PROC in ("71010" "71020") then radiology=1; /*pop 43*/
if length(PROC)=5 and PROC_num>= 100 AND PROC_num<= 2101 then anesthesia=1; /*pop 43*/
if PROC in ("82378" "86300") then tumor_marker=1; /*pop 45*/
if PROC in ("82701" "82784" "82785" "82787" "86005") then allergy_test46=1; /*pop 46*/
if PROC in ("70486" "70487" "70488") then sinus_ct=1; /*pop 47*/
if PROC in ("72148" "72149" "72158") then lumbar_mri=1; /*pop 49*/
if PROC in ("97110" "97112" "97113" "97124" "97140" "98940" "98941" "98942" "98943") then therapies=1; /*pop 49*/
if PROC in ("99201" "99202" "99203" "99204" "99205" "99211" "99212" "99213" "99214" "99215" "99241" "99242" "99243" 
  "99244" "99245" "99341" "99342" "99343" "99344" "99345" "99347" "99348" "99349" "99350" "99354" "99355" "99356" "99357" 
  "99385" "99386" "99387" "99395" "99396" "99397" "99401" "99402" "99403" "99404" "99455" "99456" "99499") then evaluations=1; /*pop 49*/
if PROC in ("22899") then lumbar_surgery=1; /*pop 49*/
if length(PROC)=5 and PROC_num>= 22010 AND PROC_num<= 22865 then lumbar_surgery=1; /*pop 49*/
if PROC in ("71250" "71260" "71270") then thorax_ct=1; /*pop 50*/
if PROC in ("71270") then thorax_contrast=1; /*pop 50*/
if PROC in ("74150" "74160" "74170") then abdomen_ct=1; /*pop 51*/
if PROC in ("74170") then abdomen_contrast=1; /*pop 51*/
if proc in ("8051" "8106" "8107" "8108" "8467" "8465") then spinal_fusion=1; /*pop 10*/
if proc in ("683" "6831" "6839" "684" "6841" "6849" "685" "6851" "6859" "686" "6861" "6869" "687" "6871" "6879" "689") then hysterectomy=1; /*pop 11*/
if proc in ("8914") then EEG=1; /*pop 27*/

array ab(30) er_visit--spinal_fusion; do i=1 to 30;
if ab(i)=. then ab(i)=0; end; drop i;

length er_visit--spinal_fusion 3;
run;
proc means; var er_visit--spinal_fusion; run;
%Mend tx;
%let tx=103_01_06;%tx; %let tx=112_01_06;%tx; %let tx=121_01_06;%tx; %let tx=131_01_06;%tx; %let tx=141_01_06;%tx; %let tx=151_01_06;%tx; 
%let tx=103_07_12;%tx; %let tx=112_07_12;%tx; %let tx=121_07_12;%tx; %let tx=131_07_12;%tx; %let tx=141_07_12;%tx; %let tx=151_07_12;%tx; 


** ICD  **;
%Macro tx;
Data jodi1.cohort_icd_&tx; set jodi1.cohort_icd_&tx;
icd4=substr(icd, 1, 4);	icd3=substr(icd, 1, 3); icd_5=substr(icd, 5, 1);
if icd in ("4111" "41181" "41189") then acs=1; /*pop 1*/
if icd3 in ("410") then acs=1; /*pop 1*/
if position in ("1" "2") and icd in ("4111  " "41181 " "41189 ") then acs_ip_12=1; /*pop 1*/
if position in ("1" "2") and icd3 in ("410") then acs_ip_12=1; /*pop 1*/
if icd in ("7221" "7222" "7223" "7225" "7226" "7227" "7228" "7229" "72270" "72272" "72273" "72280" "72282" "72283" "72290" "72292" "72293") then herniated_disc=1; /*pop 10*/
if icd in ("3550" "3557" "3558" "3559" "7243" "7244" "7292") then mononeuritis=1; /*pop 10*/
if icd3 in ("179" "180" "182" "183" "184") then malignancy=1; /*pop 11*/
if icd3 in ("461" "473") and icd_5="" then sinusitis=1; /*pop 19 20 21*/ 
if icd in ("4280" "4281" "4289") then CHF=1; /*pop 26*/
if icd4 in ("4282" "4283" "4284") then CHF=1; /*pop 26*/
if icd4 in ("4273") then AF_flutter=1; /*pop 26*/
if icd in ("7802" "9921") then syncope_heat=1; /*pop 27*/
if icd in ("33701") then syncope_carotid_sinus=1; /*pop 27*/
if icd in ("95901") then traumatic_brain_injury=1; /*pop 34*/
if icd4 in ("8540" "8541") then traumatic_brain_injury=1; /*pop 34*/
if icd3 in ("850" "851" "852" "853") then traumatic_brain_injury=1; /*pop 34*/ 
if icd3 in ("185") or icd in ("2334") then prostate_ca=1; /*pop 36*/
if icd in ("7213" "72190" "72210" "72252" "7226" "72293" "72402" "7242" "7243" "7245" "7246" "72470" "72471" "72479" "7385"
  "7393" "7394" "8460" "8461" "8462" "8463" "8468" "8469" "8472") then low_back_pain=1; /*pop 37 & pop 49*/
if icd in ("7859" "7842" "36234" "4359" "43310" "34290" "7802" "7813" "4370") then pop_41=1; /*pop 41*/
if icd3 in ("466" "480" "481" "482" "483" "484" "485" "486" "487" "488" "490" "491" "492" "493" "494" "495" "496" "500" "501" "502" "503" "504" "505" "506" "507" "508" "510" "511" "512" "513" "514" "515" "516" "517" "518" "519") then pop_43=1; /*pop 43*/
if icd in ("1740" "1741" "1742" "1743" "1744" "1745" "1746" "1748" "1749") then breast_cancer=1; /*pop 45*/
if icd in ("4770" "4771" "4772" "4778" "4779" "49302" "49390" "49392" "7080" "9953") then allergy=1; /*pop 46*/
if icd in ("4610" "4611" "4612" "4613" "4618" "4619") then acute_sinusitis=1; /*pop 47*/
if icd in ("4730" "4731" "4732" "4733" "4738" "4739") then chronic_sinusitis=1; /*pop 47*/
if icd in ("34460" "34461" "7292" "2793") then pop49=1; /*pop 49*/
if icd in ("92611" "92612") then trauma=1; /*pop 49*/
if icd in ("3249" "3241") then intraspinal_abcess=1; /*pop 49*/
if icd3 in ("140" "141" "142" "143" "144" "145" "146" "147" "148" "149" "150" "151" "152" "153" "154" "155" "156" "157" 
"158" "159" "160" "161" "162" "163" "164" "165" "166" "167" "168" "169" "170" "171" "172" "173" "174" "175" "176" "177" 
"178" "179" "180" "181" "182" "183" "184" "185" "186" "187" "188" "189" "190" "191" "192" "193" "194" "195" "196" "197" 
"198" "199" "200" "201" "202" "203" "204" "205" "206" "207" "208" "230" "231" "232" "233" "234" "235" "236" "237" "238" 
"239" "042" "043" "044") then pop49=1; /*pop 49*/
if icd3 in ("800" "801" "802" "803" "804" "805" "806" "807" "808" "809" "810" "811" "812" "813" "814" "815" "816" "817" 
  "818" "819" "820" "821" "822" "823" "824" "825" "826" "827" "828" "829" "830" "831" "832" "833" "834" "835" "836" "837" 
  "838" "839" "850" "851" "852" "853" "854" "860" "861" "862" "863" "864" "865" "866" "867" "868" "869" "905" "906" "907" 
  "908" "909" "929" "952" "958" "959") then trauma=1; /*pop 49*/
if icd4 in ("3040" "3041" "3042" "3044" "3054" "3055" "3056" "3057") then pop49=1; /*pop 49*/
if icd in ("5939" "1200" "59970" "59971" "59972" "2512" "2510" "2508" "2703" "2559" "1550" "1551" "1552" "1570" "1571" "1572" 
  "1573" "1574" "1578" "1579" "1890" "2115" "2116" "2117" "2230") then pop51=1; /*pop 51*/
if icd3 in ("194" "277" "237") then pop51=1; /*pop 51*/
if icd3 in ("180") then cervical_cancer=1; /*Cervical Cancer*/
if icd3 in ("180") and position='1' then cervical_cancer=1; /*Cervical Cancer*/
if icd3 in ("185") and position='1' then prostate_cancer=1; /*Prostate Cancer*/

array ab(25) acs--prostate_cancer; do i=1 to 25;
if ab(i)=. then ab(i)=0; end; drop i;

length acs--prostate_cancer 3;
run;
proc means; var acs--prostate_cancer; run;
%Mend tx;
%let tx=103_01_06;%tx; 
%let tx=112_01_06;%tx; %let tx=121_01_06;%tx; %let tx=131_01_06;%tx; %let tx=141_01_06;%tx; %let tx=151_01_06;%tx; 
%let tx=103_07_12;%tx; %let tx=112_07_12;%tx; %let tx=121_07_12;%tx; %let tx=131_07_12;%tx; %let tx=141_07_12;%tx; %let tx=151_07_12;%tx; 


** DRG  **;
%Macro tx;
Data jodi1.cohort_drg_&tx; set jodi1.cohort_drg_&tx;
length acs acs_drg spinal_fusion malignancy 3;
acs=0; acs_drg=0; spinal_fusion=0; malignancy=0;
if drg in (281 282 283 284 285 286 287) then do; acs=1; acs_drg=1; end; /*pop 1*/
if drg in (459 460) then spinal_fusion=1; /*pop 10*/
if drg in (734 735 736 737 738 739 740 741 754 755 756) then malignancy=1; /*pop 11*/
run;
proc means; var acs acs_drg spinal_fusion malignancy; run;
%Mend tx;
%let tx=103_01_06;%tx; %let tx=112_01_06;%tx; %let tx=121_01_06;%tx; %let tx=131_01_06;%tx; %let tx=141_01_06;%tx; %let tx=151_01_06;%tx; 
%let tx=103_07_12;%tx; %let tx=112_07_12;%tx; %let tx=121_07_12;%tx; %let tx=131_07_12;%tx; %let tx=141_07_12;%tx; %let tx=151_07_12;%tx; 



**  POP  **;
%Macro tx;
/***  Pop 01   ***/
/* Denominator - Individuals with a code for emergency visit* with any of the ICD-9 diagnoses OR individuals with a hospitalization 
with DRGs as listed, or primary or secondary diagnosis code during hospitalization for any of the ICD-9 diagnoses*/

** ACS in ER  *;
** ER Visit  **;
Data clm_er; set jodi1.cohort_claims_&tx; where place_of_service="ER"; keep clm_id bene_id; run;
Data proc_er; set jodi1.cohort_proc_&tx; where er_visit=1; keep clm_id bene_id; run; 
Data er_visit; set clm_er proc_er; run; proc sort nodupkey; by clm_id bene_id; run;

** ACS  **; 
Data icd_acs; set jodi1.cohort_icd_&tx; where acs=1; keep clm_id bene_id acs; run;
proc sort nodupkey; by clm_id bene_id acs; run;

Data icd_er_acs; merge icd_acs (in=a) er_visit (in=b); by clm_id bene_id; if a=1 and b=1; keep clm_id bene_id acs; run;

** ACS in DRG **;
Data drg_acs; set jodi1.cohort_drg_&tx; where acs=1; keep clm_id bene_id acs; run;
proc sort nodupkey; by clm_id bene_id acs; run;

** ACS in IP in 1st/2nd position *;
** IP Visit  **;
Data ip_visit; set jodi1.cohort_claims_&tx; where place_of_service="IP"; keep clm_id bene_id; run; proc sort nodupkey; by clm_id bene_id; run;

** ACS in 1st/2nd position **; 
Data icd_acs_12; set jodi1.cohort_icd_&tx; where acs=1 and position in (1 2); keep clm_id bene_id acs; run;
proc sort nodupkey; by clm_id bene_id acs; run;

Data icd_ip_acs; merge icd_acs_12 (in=a) ip_visit (in=b); by clm_id bene_id; if a=1 and b=1; keep clm_id bene_id acs; run;

** All ACS Combined: per beneficiary per date of service**;
Data pop_01_de; set icd_er_acs drg_acs icd_ip_acs; length pop_01_de 3; pop_01_de=1; run; 
proc sort nodupkey; by bene_id; run;

/* Numerator - Individuals with CPT codes as listed or HCPCS codes as listed for echocardiography */
Data pop_01_nu; set jodi1.cohort_proc_&tx; where stress_echocardiography=1; length pop_01_nu 3; pop_01_nu=1; keep bene_id pop_01_nu; run; 
proc sort nodupkey; by bene_id; run;

/* POP 01 merge */
Data pop_01; merge pop_01_de (in=a) pop_01_nu; by bene_id; if a=1; run;
Data jodi1.pop_01_&tx; set pop_01; length pop_num $2.; pop_num="01"; if pop_01_nu=. then pop_01_nu=0; if pop_01_de=. then pop_01_de=0; run;
proc freq; table pop_01_nu pop_01_de; run;


/***  Pop 10   ***/
/* Denominator - Everyone MINUS those with a clear indication (radicular symptoms--symptoms clearly of herniated disc-radicular pain)*/
* Herniated Disc *;
Data icd_herniated_disc; set jodi1.cohort_icd_&tx; where herniated_disc=1; keep clm_id bene_id herniated_disc; run;
proc sort nodupkey; by clm_id bene_id; run;

* Mononeuritis: Exclude mononueritis if occur 2 times with 30 days *;
Data icd_mononeuritis; set jodi1.cohort_icd_&tx; where mononeuritis=1; keep clm_id bene_id mononeuritis date_from; run;
proc sort nodupkey; by bene_id date_from; run;

Data icd_mononeuritis; set icd_mononeuritis; by bene_id date_from; 
date_from_pre=lag(date_from); if first.bene_id then delete; if date_from-date_from_pre>30 then delete;
run; 

Data exclusion; set icd_herniated_disc icd_mononeuritis; keep bene_id; run; 
proc sort nodupkey; by bene_id; run;

Data pop_10_de; set jodi1.cohort_patient_&tx; length pop_10_de 3; pop_10_de=1; keep bene_id pop_10_de; run;
proc sort; by bene_id; run;
Data pop_10_de; merge pop_10_de (in=d) exclusion (in=e); by bene_id; if d=1 and e=0; run; 
proc sort nodupkey; by bene_id; run;

/* Numerator - Laminectomy or spinal fusion */
Data proc_laminectomy_spinal_fusion; set jodi1.cohort_proc_&tx; where laminectomy=1 or spinal_fusion=1; keep bene_id; run;
Data drg_spinal_fusion; set jodi1.cohort_drg_&tx; where spinal_fusion=1; keep bene_id; run;

Data pop_10_nu; set proc_laminectomy_spinal_fusion drg_spinal_fusion; length pop_10_nu 3; pop_10_nu=1; keep bene_id pop_10_nu; run;
proc sort nodupkey; by bene_id; run;

/* POP 10 merge */
Data pop_10; merge pop_10_de (in=a) pop_10_nu; by bene_id; if a=1; run;
Data jodi1.pop_10_&tx; set pop_10; length pop_num $2.; pop_num="10"; if pop_10_nu=. then pop_10_nu=0; if pop_10_de=. then pop_10_de=0; run;
proc freq; table pop_10_nu pop_10_de; run;


/***  Pop 11   ***/
 /* Denominator - all women minus those with a malignancy diagnosis (ICD9 and DRG)*/
Data icd_malignancy; set jodi1.cohort_icd_&tx; where malignancy=1; keep bene_id; run;
Data drg_malignancy; set jodi1.cohort_drg_&tx; where malignancy=1; keep bene_id; run;
Data malignancy; set icd_malignancy drg_malignancy; run;
proc sort nodupkey; by bene_id; run;

Data female; set jodi1.cohort_patient_&tx; where sex="F"; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

Data pop_11_de; merge female (in=d) malignancy (in=e); by bene_id; if d=1 and e=0; 
length pop_11_de 3; pop_11_de=1; keep bene_id pop_11_de; run; 
proc sort nodupkey; by bene_id; run;

  /* Numerator - anyone with hysterectomy (not specified for malignancy) */
Data pop_11_nu; set jodi1.cohort_proc_&tx; where hysterectomy=1;
length pop_11_nu 3; pop_11_nu=1; keep bene_id pop_11_nu; run; 
proc sort nodupkey; by bene_id; run;

/* POP 11 merge */
Data pop_11; merge pop_11_de (in=a) pop_11_nu; by bene_id; if a=1; run;
Data jodi1.pop_11_&tx; set pop_11; length pop_num $2.; pop_num="11"; 
if pop_11_nu=. then pop_11_nu=0; if pop_11_de=. then pop_11_de=0; run;
proc freq; table pop_11_nu pop_11_de; run;


/***  Pop 20   ***/
/* Denominator - Individual with a diagnosis of sinusitis (acute or chronic) –inpatient or outpatient*/
Data pop_20_de; set jodi1.cohort_icd_&tx; where sinusitis=1; length pop_20_de 3; pop_20_de=1; keep bene_id pop_20_de; run; 
proc sort nodupkey; by bene_id; run;

  /* Numerator - Laryngoscopy WITH ICD-9 code indicating sinusitis on the same claim ID*/
data proc_fiberoptic_laryngoscopy; set jodi1.cohort_proc_&tx; where fiberoptic_laryngoscopy=1; keep clm_id bene_id; run;
proc sort nodupkey; by bene_id clm_id; run;

Data icd_sinusitis; set jodi1.cohort_icd_&tx; where sinusitis=1; keep clm_id bene_id; run;
proc sort nodupkey; by bene_id clm_id; run;

Data pop_20_nu; merge proc_fiberoptic_laryngoscopy (in=a) icd_sinusitis (in=b); by bene_id clm_id; if a=1 and b=1; run;
Data pop_20_nu;	set pop_20_nu; length pop_20_nu 3; pop_20_nu=1; keep bene_id pop_20_nu; run;
proc sort nodupkey; by bene_id; run;

/* POP 20 merge */
Data pop_20; merge pop_20_de (in=a) pop_20_nu; by bene_id; if a=1; run;
Data jodi1.pop_20_&tx; set pop_20; length pop_num $2.; pop_num="20"; 
if pop_20_nu=. then pop_20_nu=0; if pop_20_de=. then pop_20_de=0; run;
proc freq; table pop_20_nu pop_20_de; run;


/***  Pop 21   ***/
 /* Denominator - Individual with a diagnosis of sinusitis (acute or chronic) –inpatient or outpatient*/
Data pop_21_de; set jodi1.cohort_icd_&tx; where sinusitis=1; length pop_21_de 3; pop_21_de=1; keep bene_id pop_21_de; run; 
proc sort nodupkey; by bene_id; run;


  /* Numerator - Nasal endoscopy WITH ICD-9 code indicating sinusitis on the same claim ID*/
Data diagnostic_endoscopy; set jodi1.cohort_proc_&tx; where diagnostic_endoscopy=1; keep clm_id bene_id; run;
proc sort nodupkey; by clm_id bene_id; run;

Data sinusitis; set jodi1.cohort_icd_&tx; where sinusitis=1; keep clm_id bene_id; run;
proc sort nodupkey; by clm_id bene_id; run;

Data pop_21_nu; merge diagnostic_endoscopy (in=a) sinusitis (in=b); by clm_id bene_id; if a=1 and b=1; 
length pop_21_nu 3; pop_21_nu=1; keep bene_id pop_21_nu; run;
proc sort nodupkey; by bene_id; run;

/* POP 21 merge */
Data pop_21; merge pop_21_de (in=a) pop_21_nu; by bene_id; if a=1; run;
Data jodi1.pop_21_&tx; set pop_21; length pop_num $2.; pop_num="21"; 
if pop_21_nu=. then pop_21_nu=0; if pop_21_de=. then pop_21_de=0; run;
proc freq; table pop_21_nu pop_21_de; run;


/***  Pop 26   ***/
 /* Denominator - All patients with CHF (will include atrial fibrillation patients as well)*/
Data pop_26_de; set jodi1.cohort_icd_&tx; where CHF=1 or AF_flutter=1; length pop_26_de 3; pop_26_de=1; keep pop_26_de bene_id; run; 
proc sort nodupkey; by bene_id; run;

  /* Numerator - Any measure of digoxin with no hospitalizations or ER visits during that year.*/
Data digoxin; set jodi1.cohort_proc_&tx; where digoxin=1; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

  /* Hospitalization & ER */
Data ip_er_clm; set jodi1.cohort_claims_&tx; where place_of_service in ('IP' 'ER'); keep bene_id; run;
Data er_proc; set jodi1.cohort_proc_&tx; where er_visit=1 OR place_of_service in ('ER'); keep bene_id; run;
Data ip_er; set ip_er_clm er_proc; run; 
proc sort nodupkey; by bene_id; run;

Data pop_26_nu; merge digoxin (in=a) ip_er (in=b); by bene_id; if a=1 and b=0; length pop_26_nu 3; pop_26_nu=1; keep pop_26_nu bene_id; run;
proc sort nodupkey; by bene_id; run;

/* POP 26 merge */
Data pop_26; merge pop_26_de (in=a) pop_26_nu; by bene_id; if a=1; run;
Data jodi1.pop_26_&tx; set pop_26; length pop_num $2.; pop_num="26"; if pop_26_nu=. then pop_26_nu=0; if pop_26_de=. then pop_26_de=0; run;
proc freq; table pop_26_nu pop_26_de; run;


/***  Pop 27   ***/
 /* Denominator - Individuals with an outpatient visit with diagnosis of syncope or hospitalization for syncope*/
Data pop_27_de; set jodi1.cohort_icd_&tx; where syncope_heat=1 or syncope_carotid_sinus=1; length pop_27_de 3; pop_27_de=1; keep pop_27_de bene_id; run;
proc sort nodupkey; by bene_id; run;

  /* Numerator - EEG on the same claim as diagnosis of syncope or at any time during the hospitalization with a code for syncope*/
  /* EGG not in ICD Procedure Outpatient */
Data egg; set jodi1.cohort_proc_&tx; where eeg=1 and place_of_service in ('IP' 'OP'); date_egg=date_from; keep bene_id clm_id date_egg; run;
proc sort nodupkey; by bene_id clm_id date_egg; run;

Data a1; set jodi1.cohort_icd_&tx; where syncope_heat=1 or syncope_carotid_sinus=1; keep clm_id bene_id; run;
proc sort nodupkey; by bene_id clm_id; run;
Data b1; set egg; keep clm_id bene_id; run;
proc sort nodupkey; by bene_id clm_id; run;

Data c1; merge a1 (in=a) b1 (in=b); by bene_id clm_id; if a=1 and b=1; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

Data a2; set jodi1.cohort_icd_&tx; where (syncope_heat=1 or syncope_carotid_sinus=1) and place_of_service='IP'; 
syncope_start=date_from; syncope_end=date_end; keep bene_id syncope_start syncope_end; run;
proc sort nodupkey; by bene_id syncope_start syncope_end; run;
Data b2; set egg; keep bene_id date_egg; run;
proc sort nodupkey; by bene_id date_egg; run;

proc sql; create table c2 as  select *  from a2 a, b2 b  where a.bene_id=b.bene_id; quit;
Data c2; set c2; where date_egg>=syncope_start and date_egg<=syncope_end; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

Data pop_27_nu; set c1 c2; length pop_27_nu 3; pop_27_nu=1; run;
proc sort nodupkey; by bene_id; run;

/* POP 27 merge */
Data pop_27; merge pop_27_de (in=a) pop_27_nu; by bene_id; if a=1; run;
Data jodi1.pop_27_&tx; set pop_27; length pop_num $2.; pop_num="27"; if pop_27_nu=. then pop_27_nu=0; if pop_27_de=. then pop_27_de=0; run;
proc freq; table pop_27_nu pop_27_de; run;


/***   Pop 32   ***/
 /* Denominator - Whole population */
Data pop_32_de; set jodi1.cohort_patient_&tx; length pop_32_de 3; pop_32_de=1; keep pop_32_de bene_id; run;
proc sort nodupkey; by bene_id; run;

  /* Numerator - Any code indicating testing for H. pylori*/
Data pop_32_nu; set jodi1.cohort_proc_&tx; where h_pylori_test=1; length pop_32_nu 3; pop_32_nu=1; keep pop_32_nu bene_id; run;
proc sort nodupkey; by bene_id; run;

/* POP 32 merge */
Data pop_32; merge pop_32_de (in=a) pop_32_nu; by bene_id; if a=1; run;
Data jodi1.pop_32_&tx; set pop_32; length pop_num $2.; pop_num="32"; if pop_32_nu=. then pop_32_nu=0; if pop_32_de=. then pop_32_de=0; run;
proc freq; table pop_32_nu pop_32_de; run;


/***  Pop 34   ***/
 /* Denominator - Patients with traumatic brain injury*/
Data pop_34_de; set jodi1.cohort_icd_&tx; where traumatic_brain_injury=1; 
length pop_34_de 3; pop_34_de=1; keep pop_34_de bene_id; run;
proc sort nodupkey; by bene_id; run;

 /* Numerator - MRI on the same claim as diagnosis if outpatient or during hospitalization if inpatient*/
Data mri; set jodi1.cohort_proc_&tx; where MRI_brain=1; date_mri=date_from; run;

Data a1; set icd; where traumatic_brain_injury=1; keep clm_id bene_id; run;
proc sort nodupkey; by bene_id clm_id; run;
Data b1; set mri; keep clm_id bene_id; run;
proc sort nodupkey; by bene_id clm_id; run;

Data c1; merge a1 (in=a) b1 (in=b); by bene_id clm_id; if a=1 and b=1; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

Data a2; set jodi1.cohort_icd_&tx; where traumatic_brain_injury=1 and place_of_service='IP'; 
brain_start=date_from; brain_end=date_end; keep bene_id brain_start brain_end; run;
proc sort nodupkey; by bene_id brain_start brain_end; run;
Data b2; set mri; keep bene_id date_mri; run;
proc sort nodupkey; by bene_id date_mri; run;

proc sql; create table c2 as  select *  from a2 a, b2 b where a.bene_id=b.bene_id; quit;
Data c2; set c2; where date_mri>=brain_start and date_mri<=brain_end; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

Data pop_34_nu; set c1 c2; length pop_34_nu 3; pop_34_nu=1; run;
proc sort nodupkey; by bene_id; run;

/* POP 34 merge */
Data pop_34; merge pop_34_de (in=a) pop_34_nu; by bene_id; if a=1; run;
Data jodi1.pop_34_&tx; set pop_34; length pop_num $2.; pop_num="34"; if pop_34_nu=. then pop_34_nu=0; if pop_34_de=. then pop_34_de=0; run;
proc freq; table pop_34_nu pop_34_de; run;


/***  Pop 36   ***/
/* Denominator - Men with low risk for prostate CA*/
Data prostate; set jodi1.cohort_icd_&tx; where prostate_ca=1; keep bene_id; run;
proc sort nodupkey; by bene_id; run;
Data risk; set jodi1.cohort_proc_&tx; where prostate_risk=1;; keep bene_id; run;
proc sort nodupkey; by bene_id; run;
Data pop_36_de; merge prostate (in=a) risk (in=b); by bene_id; if a=1 and b=0; length pop_36_de 3; pop_36_de=1; run;
proc sort nodupkey; by bene_id; run;

  /* Numerator – PET, CT or radionuclide bone scan AFTER diagnosis */
Data scan; set jodi1.cohort_proc_&tx; where prostate_scan=1; date_scan=date_from; keep bene_id date_scan; run;
proc sort nodupkey; by bene_id date_scan; run;
Data prostate; set jodi1.cohort_icd_&tx; where prostate_ca=1; date_cancer=date_from; keep bene_id date_cancer; run;
proc sort nodupkey; by bene_id date_cancer; run;

proc sql; create table pop_36_nu as  select *  from scan a, prostate b where a.bene_id=b.bene_id; quit;
Data pop_36_nu; set pop_36_nu; where date_scan>=date_cancer; length pop_36_nu 3; pop_36_nu=1; keep bene_id pop_36_nu; run;
proc sort nodupkey; by bene_id; run;

/* POP 36 merge */
Data pop_36; merge pop_36_de (in=a) pop_36_nu; by bene_id; if a=1; run;
Data jodi1.pop_36_&tx; set pop_36; length pop_num $2.; pop_num="36"; if pop_36_nu=. then pop_36_nu=0; if pop_36_de=. then pop_36_de=0; run;
proc freq; table pop_36_nu pop_36_de; run;


/***  Pop 37   ***/
 /* Denominator - Low back pain diagnosis*/
Data pop_37_de; set jodi1.cohort_icd_&tx; where low_back_pain=1; length pop_37_de 3; pop_37_de=1; keep bene_id pop_37_de; run;
proc sort nodupkey; by bene_id; run;

  /* Numerator - Traction with diagnosis of low back pain*/
Data pop_37_nu; set jodi1.cohort_proc_&tx; where traction=1; length pop_37_nu 3; pop_37_nu=1; keep bene_id pop_37_nu; run;
proc sort nodupkey; by bene_id; run;

/* POP 37 merge */
Data pop_37; merge pop_37_de (in=a) pop_37_nu; by bene_id; if a=1; run;
Data jodi1.pop_37_&tx; set pop_37; length pop_num $2.; pop_num="37"; if pop_37_nu=. then pop_37_nu=0; if pop_37_de=. then pop_37_de=0; run;
proc freq; table pop_37_nu pop_37_de; run;


/***  Pop 41   ***/
 /* Denominator - all minus those with a specific diagnosis*/
Data a; set jodi1.cohort_icd_&tx; where pop_41=1; keep bene_id; run;
proc sort nodupkey; by bene_id; run;
Data b; set jodi1.cohort_patient_&tx; length pop_41_de 3; pop_41_de=1; keep bene_id pop_41_de; run;
proc sort nodupkey; by bene_id; run;
Data pop_41_de; merge a (in=a) b (in=b); by bene_id; if a=0 and b=1; run; 
proc sort nodupkey; by bene_id; run;

 /* Numerator - Screening for asymptomatic artery stenosis (CPT 93880 or 3100F, ONLY IN outpatient setting (not ER))*/
Data pop_41_nu; set jodi1.cohort_proc_&tx; where carotid_ultrasound=1 or carotid_image=1; run;
Data pop_41_nu; set pop_41_nu; if er_visit=1 or place_of_service='ER' then delete; length pop_41_nu 3; pop_41_nu=1; keep bene_id pop_41_nu; run;
proc sort nodupkey; by bene_id; run;
 
/* POP 41 merge */
Data pop_41; merge pop_41_de (in=a) pop_41_nu; by bene_id; if a=1; run;
Data jodi1.pop_41_&tx; set pop_41; length pop_num $2.; pop_num="41"; if pop_41_nu=. then pop_41_nu=0; if pop_41_de=. then pop_41_de=0; run;
proc freq; table pop_41_nu pop_41_de; run;


/***  Pop 43   ***/
  /* Denominator - All with anesthesia code excluding certain diagnoses*/
Data a; set jodi1.cohort_icd_&tx; where pop_43=1; keep bene_id; run;
proc sort nodupkey; by bene_id; run;
Data b; set jodi1.cohort_proc_&tx; where anesthesia=1; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

Data pop_43_de; merge a (in=a) b (in=b); by bene_id; if a=0 and b=1; length pop_43_de 3; pop_43_de=1; run; 
proc sort nodupkey; by bene_id pop_43_de; run;

  /* Numerator - Chest radiography 30 days before anesthesia*/
Data radiology; set jodi1.cohort_proc_&tx; where radiology=1; date_radiology=date_from; keep bene_id date_radiology; run;
proc sort nodupkey; by bene_id date_radiology; run;

Data b; set jodi1.cohort_proc_&tx; where anesthesia=1; date_anes=date_from; keep bene_id date_anes; run;
proc sort nodupkey; by bene_id date_anes; run;

proc sql; create table c as  select *  from radiology a, b b  where a.bene_id=b.bene_id; quit;

Data pop_43_nu; set c; where date_anes-date_radiology>=0 and date_anes-date_radiology<=30; run;
Data pop_43_nu; set pop_43_nu; length pop_43_nu 3; pop_43_nu=1; keep bene_id pop_43_nu; run; 
proc sort nodupkey; by bene_id; run;

/* POP 43 merge */
Data pop_43; merge pop_43_de (in=a) pop_43_nu; by bene_id; if a=1; run;
Data jodi1.pop_43_&tx; set pop_43; length pop_num $2.; pop_num="43"; if pop_43_nu=. then pop_43_nu=0; if pop_43_de=. then pop_43_de=0; run;
proc freq; table pop_43_nu pop_43_de; run;


/***  Pop 45   ***/
  /* Denominator - Women with breast cancer diagnosis*/
Data cancer; set jodi1.cohort_icd_&tx; where breast_cancer=1; keep bene_id; run;
proc sort nodupkey; by bene_id; run;
Data female; set jodi1.cohort_patient_&tx; where sex='F'; length pop_45_de 3; pop_45_de=1; keep bene_id pop_45_de; run; 
proc sort nodupkey; by bene_id pop_45_de; run;
Data pop_45_de; merge cancer (in=a) female (in=b); by bene_id; if a=1 and b=1; run; 
proc sort nodupkey; by bene_id pop_45_de; run;

  /* Numerator - Tumor marker studies*/
Data pop_45_nu; set jodi1.cohort_proc_&tx; where tumor_marker=1; length pop_45_nu 3; pop_45_nu=1; keep bene_id pop_45_nu; run; 
proc sort nodupkey; by bene_id; run;

/* POP 45 merge */
Data pop_45; merge pop_45_de (in=a) pop_45_nu; by bene_id; if a=1; run;
Data jodi1.pop_45_&tx; set pop_45; length pop_num $2.; pop_num="45"; if pop_45_nu=. then pop_45_nu=0; if pop_45_de=. then pop_45_de=0; run;
proc freq; table pop_45_nu pop_45_de; run;


/***  Pop 46   ***/
  /* Denominator – Individuals with allergy diagnosis (477.0, 477.1, 477.2, 477.8, 477.9, 493.0, 493.02, 493.9, 493.90, 493.92, 708.0, 995.3)*/
Data pop_46_de; set jodi1.cohort_icd_&tx; where allergy=1; length pop_46_de 3; pop_46_de=1; keep bene_id pop_46_de; run; 
proc sort nodupkey; by bene_id pop_46_de; run;

  /* Numerator - Use of CPT 82701, 82784, 82785, 82787, 86005 on the same claim as a code for diagnoses in the denominator column */
Data a; set jodi1.cohort_proc_&tx; where allergy_test46=1; keep clm_id bene_id; run;
proc sort nodupkey; by bene_id clm_id; run;
Data b; set jodi1.cohort_icd_&tx; where allergy=1; keep bene_id clm_id; run; 
proc sort nodupkey; by bene_id clm_id; run;

Data pop_46_nu; merge a (in=a) b (in=b); by bene_id clm_id; if a=1 and b=1; length pop_46_nu 3; pop_46_nu=1; keep bene_id pop_46_nu; run; 
proc sort nodupkey; by bene_id; run;

/* POP 46 merge */
Data pop_46; merge pop_46_de (in=a) pop_46_nu; by bene_id; if a=1; run;
Data jodi1.pop_46_&tx; set pop_46; length pop_num $2.; pop_num="46"; if pop_46_nu=. then pop_46_nu=0; if pop_46_de=. then pop_46_de=0; run;
proc freq; table pop_46_nu pop_46_de; run;


/***  Pop 47   ***/
  /* Denominator – 461.0, 461.1, 461.2, 461.3, 461.8, 461.9 AND NO code in the preceding 3 months for any of these AND NO code in the preceding 3 months for 473.0, 473.1, 473.2, 473.3, 473.8, 473.9*/
Data acute_sinusitis; set jodi1.cohort_icd_&tx; where acute_sinusitis=1; rename date_from=date_service; keep bene_id date_from; run;
proc sort nodupkey; by bene_id date_service; run;

Data sinusitis; set jodi1.cohort_icd_&tx; where chronic_sinusitis=1 OR acute_sinusitis=1; keep bene_id date_from; run;
proc sort nodupkey; by bene_id date_from;  run;

***  Left join merge  ***;
proc sql; create table c as  select *  from acute_sinusitis a left join sinusitis b on a.bene_id=b.bene_id; quit;
Data d; set c; where date_from < date_service <= date_from+92; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

Data pop_47_de; merge acute_sinusitis (in=a) d (in=b); by bene_id; if a=1 and b=0; run;

Data pop_47_de; set pop_47_de; length pop_47_de 3; pop_47_de=1; keep bene_id pop_47_de; run; 
proc sort nodupkey; by bene_id pop_47_de; run;

  /* Numerator - Any occurrence of sinus CT (CPT 70486, 70487, 70488) in the 3 months preceding the diagnosis of acute sinusitis */
Data acute_sinusitis; set jodi1.cohort_icd_&tx; where acute_sinusitis=1; keep bene_id date_from; run;
proc sort nodupkey; by bene_id date_from; run;

Data sinus_ct; set jodi1.cohort_proc_&tx; where sinus_ct=1; rename date_from=date_sinus_ct; keep bene_id date_from; run;
proc sort nodupkey; by bene_id date_sinus_ct; run;

***  many-to-many merge  ***;
proc sql; create table c as  select *  from acute_sinusitis a, sinus_ct b where a.bene_id=b.bene_id; quit;

Data c; set c; where date_sinus_ct < date_from <= date_sinus_ct+92; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

Data pop_47_nu; set c; length pop_47_nu 3; pop_47_nu=1; keep bene_id pop_47_nu; run; 
proc sort nodupkey; by bene_id; run;

/* POP 47 merge */
Data pop_47; merge pop_47_de (in=a) pop_47_nu; by bene_id; if a=1; run;
Data jodi1.pop_47_&tx; set pop_47; length pop_num $2.; pop_num="47"; if pop_47_nu=. then pop_47_nu=0; if pop_47_de=. then pop_47_de=0; run;
proc freq; table pop_47_nu pop_47_de; run;


/***  Pop 49   ***/
  /* Denominator – MRI of the lumbar spine studies with a diagnosis of low back pain on the imaging claim.
CPT=72148, or 72149, or 72158  AND  ICD-9: 721.3, 721.90, 722.10, 722.52, 722.6, 722.93, 724.02, 724.2 ,  
724.3, 724.5, 724.6, 724.70, 724.71, 724.79,  738.5, 739.3, 739.4, 846.0, 846.1, 846.2, 846.3, 846.8, 846.9 , 847.2 "
Excluded from the denominator - CPT codes: 22010-22865 and 22899 in  90 days preceding MRI; ICD-9 codes: 140-208, 
230-234, 235-239,  304.0X, 304.1X, 304.2X, 304.4X, 305.4X, 305.5X, 305.6X, 305.7X, 344.60, 344.61, 729.2, 042-044, 
279.3 in preceding 365 days;  800-839, 850-854, 860-869, 905-909, 926.11, 926.12, 929, 952, 958-959 in preceding 
45 days; 324.9, 324.1 on same claim ID as MRI of the lumbar spine*/

Data a; set jodi1.cohort_proc_&tx; where lumbar_mri=1; rename date_from=date_mri; keep bene_id clm_id date_from; run;
proc sort nodupkey; by bene_id clm_id date_mri; run;
Data b; set jodi1.cohort_icd_&tx; where low_back_pain=1; keep bene_id clm_id; run;
proc sort nodupkey; by bene_id clm_id; run;

Data c; merge a (in=a) b (in=b); by bene_id clm_id; if a=1 and b=1; run;
proc sort nodupkey; by bene_id date_mri clm_id; run;

*Exclusions / Date;
Data lumbar_surgery; set jodi1.cohort_proc_&tx; where lumbar_surgery=1; rename date_from=date_lumbar_surgery; keep bene_id date_from; run;
proc sort nodupkey; by bene_id date_lumbar_surgery; run;

Data pop49; set jodi1.cohort_icd_&tx; where pop49=1; rename date_from=date_pop49; keep bene_id date_from; run;
proc sort nodupkey; by bene_id date_pop49;  run;

Data trauma; set jodi1.cohort_icd_&tx; where trauma=1; rename date_from=date_trauma; keep bene_id date_from; run;
proc sort nodupkey; by bene_id date_trauma;  run;

data dates; set lumbar_surgery pop49 trauma; run;

***  Left join merge  ***;
proc sql; create table d as  select *  from c c left join dates d  on c.bene_id=d.bene_id; quit;
Data e; set d; where date_lumbar_surgery<=date_mri<=date_lumbar_surgery+90 OR date_pop49<=date_mri<=date_pop49+365 OR date_trauma<=date_mri<=date_trauma+45; run;
proc sort nodupkey; by bene_id; run;

Data f; merge c (in=a) e (in=b); by bene_id; if a=1 and b=0; run;

*Exclusions / same claims;
Data intraspinal_abcess; set jodi1.cohort_icd_&tx; where intraspinal_abcess=1; keep bene_id clm_id; run;
proc sort nodupkey; by bene_id clm_id; run;

proc sort data=c nodupkey; by bene_id clm_id; run;
Data g; merge c (in=c) intraspinal_abcess (in=f); by bene_id clm_id; if c=1 and f=1; run;
proc sort nodupkey; by bene_id; run;

Data h; merge f (in=f) g (in=g); by bene_id date_mri; if f=1 and g=0; run;
Data pop_49_de; set h; length pop_49_de 3; pop_49_de=1; keep bene_id pop_49_de; run; 
proc sort nodupkey; by bene_id pop_49_de; run;

  /* Numerator – MRI of the lumbar spine studies with a diagnosis of low back pain (from the denominator) without the patient having 
claims-based evidence of prior antecedent conservative therapy.
CPT=72148, or 72149, or 72158 with no codes for 97110, 97112, 97113, 97124, 97140, 98940, 98941,98942,98943 in the 60 days preceding 
the MRI of the lumbar spine AND no codes for 99201-99205,99211 -99215,99241-99245, 99341-99345,99347-99350,99354-99357,99385-99387,99395-99397 , 
99401-99404,99455-99456,99499 between 28 and 60 days preceding the MRI of the lumbar spine*/
Data therapies; set jodi1.cohort_proc_&tx; where therapies=1; rename date_from=date_therapies; keep bene_id date_from; run;
proc sort nodupkey; by bene_id date_therapies;  run;

Data evaluations; set jodi1.cohort_proc_&tx; where evaluations=1; rename date_from=date_evaluations; keep bene_id date_from; run;
proc sort nodupkey; by bene_id date_evaluations;  run;

data therapies_evals; set therapies evaluations; run;
proc sort; by bene_id; run;

***  Left join merge  ***;
proc sql; create table d as  select *  from c c left join therapies_evals a on c.bene_id=a.bene_id; quit;
Data d; set d; where date_therapies<=date_mri<=date_therapies+60 OR date_evaluations+28<=date_mri<=date_evaluations+60; run;
proc sort nodupkey; by bene_id; run;

data e; set pop_49_de; keep bene_id; run;
proc sort nodupkey; by bene_id; run;
Data pop_49_nu; merge d (in=d) e (in=c); by bene_id; if c=1 and d=0; 
length pop_49_nu 3; pop_49_nu=1; keep bene_id pop_49_nu; run;
proc sort nodupkey; by bene_id; run;

/* POP 49 merge */
Data pop_49; merge pop_49_de (in=a) pop_49_nu; by bene_id; if a=1; run;
Data jodi1.pop_49_&tx; set pop_49; length pop_num $2.; pop_num="49"; if pop_49_nu=. then pop_49_nu=0; if pop_49_de=. then pop_49_de=0; run;
proc freq; table pop_49_nu pop_49_de; run;


/***  Pop 50   ***/
  /* Denominator –  The number of thorax CT studies with and without contrast (“combined studies”). CPT 71250, 71260, 71270*/
Data pop_50_de; set jodi1.cohort_proc_&tx; where thorax_ct=1; length pop_50_de 3; pop_50_de=1; keep bene_id pop_50_de; run; 
proc sort nodupkey; by bene_id pop_50_de; run;

  /* Numerator – The number of thorax CT studies performed (with contrast, without contrast or both with and without contrast). CPT 71270*/
Data pop_50_nu; set jodi1.cohort_proc_&tx; where thorax_contrast=1; length pop_50_nu 3; pop_50_nu=1; keep bene_id pop_50_nu; run; 
proc sort nodupkey; by bene_id pop_50_nu; run;

/* POP 50 merge */
Data pop_50; merge pop_50_de (in=a) pop_50_nu; by bene_id; if a=1; run;
Data jodi1.pop_50_&tx; set pop_50; length pop_num $2.; pop_num="50"; if pop_50_nu=. then pop_50_nu=0; if pop_50_de=. then pop_50_de=0; run;
proc freq; table pop_50_nu pop_50_de; run;


/***  Pop 51  ***/
  /* Denominator – The number of Abdomen CT studies performed (with contrast, without contrast or both with and without contrast). CPT 74150, 74160, 74170, Excluding some diagnoses if on the same claim ID*/
Data abdomen_ct; set jodi1.cohort_proc_&tx; where abdomen_ct=1; keep bene_id clm_id; run;
proc sort nodupkey; by bene_id clm_id; run;

Data pop51; set jodi1.cohort_icd_&tx; where pop51=1; keep bene_id clm_id; run;
proc sort nodupkey; by bene_id clm_id; run;

Data c; merge abdomen_ct (in=a) pop51 (in=b); by bene_id clm_id; if a=1 and b=1; run;
proc sort nodupkey; by bene_id; run;

Data d; set abdomen_ct; keep bene_id; run;
proc sort nodupkey; by bene_id; run;

Data pop_51_de; merge d (in=d) c (in=c); by bene_id; if d=1 and c=0; length pop_51_de 3; pop_51_de=1; keep bene_id pop_51_de; run; 
proc sort nodupkey; by bene_id pop_51_de; run;

  /* Numerator – The number of Abdomen CT studies with and without contrast (“combined studies”).
CPT 74170*/
Data pop_51_nu; set jodi1.cohort_proc_&tx; where abdomen_contrast=1; length pop_51_nu 3; pop_51_nu=1; keep bene_id pop_51_nu; run; 
proc sort nodupkey; by bene_id pop_51_nu; run;

/* POP 51 merge */
Data pop_51; merge pop_51_de (in=a) pop_51_nu; by bene_id; if a=1; run;
Data jodi1.pop_51_&tx; set pop_51; length pop_num $2.; pop_num="51"; if pop_51_nu=. then pop_51_nu=0; if pop_51_de=. then pop_51_de=0; run;
proc freq; table pop_51_nu pop_51_de; run;

%Mend tx;
%let tx=103_01_06;%tx; 


**  POP Panel Data  **;
%Macro type; 
data pop_&type; set jodi1.pop_&type._103_01_06; length pop 3; pop=pop_&type._nu; keep bene_id pop pop_num; run; 
%Mend type; 
%let type=01; %type; %let type=10; %type; %let type=11; %type; %let type=20; %type; %let type=21; %type; 
%let type=26; %type; %let type=27; %type; %let type=32; %type; %let type=34; %type; %let type=36; %type; 
%let type=37; %type; %let type=41; %type; %let type=43; %type; %let type=45; %type; %let type=46; %type; 
%let type=47; %type; %let type=49; %type; %let type=50; %type; %let type=51; %type; 

data jodi1.pop_all_103_01_06; set pop_01 pop_10 pop_11 pop_20 pop_21 pop_26 pop_27 pop_32 pop_34 
pop_36 pop_37 pop_41 pop_43 pop_45 pop_46 pop_47 pop_49 pop_50 pop_51; run;
proc sort; by bene_id; run;

data a; set jodi1.cohort_patient_103_01_06; keep bene_id--sex; run;
proc sort; by bene_id; run;

Data jodi1.pop_all_103_01_06; merge a jodi1.pop_all_103_01_06 (in=a); by bene_id; if a=1; run;
proc contents Data=jodi1.pop_all_103_01_06 position; run;
proc freq Data=jodi1.pop_all_103_01_06; table age sex msa; run;

Data jodi1.pop_all_103_01_06; set jodi1.pop_all_103_01_06; length age_group $5.;
if 18<=age<=34 then age_group="18-34"; if 35<=age<=44 then age_group="35-44";
if 45<=age<=54 then age_group="45-54"; if 55<=age then age_group="55+";
run;
proc freq; table age_group; run;

proc surveyreg Data=jodi1.pop_all_103_01_06;
class pop_num msa sex age_group;
model pop = msa sex age_group pop_num/ noint solution;
ods output ParameterEstimates=jodi1.jhoi;
run;




**  POP at Patient Level  **;
proc contents data=jodi1.cohort_patient_103_01_06 position; run;
data jodi1.cohort_patient_103_01_06; merge jodi1.cohort_patient_103_01_06 jodi1.pop_01_103_01_06 jodi1.pop_10_103_01_06 
jodi1.pop_11_103_01_06 jodi1.pop_20_103_01_06 jodi1.pop_21_103_01_06 jodi1.pop_26_103_01_06 jodi1.pop_27_103_01_06 
jodi1.pop_32_103_01_06 jodi1.pop_34_103_01_06 jodi1.pop_36_103_01_06 jodi1.pop_37_103_01_06 jodi1.pop_41_103_01_06 
jodi1.pop_43_103_01_06 jodi1.pop_45_103_01_06 jodi1.pop_46_103_01_06 jodi1.pop_47_103_01_06 jodi1.pop_49_103_01_06 
jodi1.pop_50_103_01_06 jodi1.pop_51_103_01_06; by bene_id;
run;
proc contents position; run;
 
data jodi1.cohort_patient_103_01_06; set jodi1.cohort_patient_103_01_06; drop acs pop_num clm_id; run;
data jodi1.cohort_patient_103_01_06; set jodi1.cohort_patient_103_01_06; 
array ab(38) pop_01_de--pop_51_nu; do i=1 to 38; if ab(i)=. then ab(i)=0; end;
run;
proc means; var pop_01_de--pop_51_nu; run;


**  MSA Level  **;
proc sort data=jodi1.cohort_patient_103_01_06; by msa; run;
proc summary data=jodi1.cohort_patient_103_01_06; var pop_01_de--pop_51_nu; by msa; 
output out=jodi1.cohort_msa_103_01_06 sum(
pop_01_de pop_01_nu pop_10_de pop_10_nu pop_11_de pop_11_nu pop_20_de pop_20_nu pop_21_de pop_21_nu
pop_26_de pop_26_nu pop_27_de pop_27_nu pop_32_de pop_32_nu pop_34_de pop_34_nu pop_36_de pop_36_nu
pop_37_de pop_37_nu pop_41_de pop_41_nu pop_43_de pop_43_nu pop_45_de pop_45_nu pop_46_de pop_46_nu
pop_47_de pop_47_nu pop_49_de pop_49_nu pop_50_de pop_50_nu pop_51_de pop_51_nu) =
pop_01_de pop_01_nu pop_10_de pop_10_nu pop_11_de pop_11_nu pop_20_de pop_20_nu pop_21_de pop_21_nu
pop_26_de pop_26_nu pop_27_de pop_27_nu pop_32_de pop_32_nu pop_34_de pop_34_nu pop_36_de pop_36_nu
pop_37_de pop_37_nu pop_41_de pop_41_nu pop_43_de pop_43_nu pop_45_de pop_45_nu pop_46_de pop_46_nu
pop_47_de pop_47_nu pop_49_de pop_49_nu pop_50_de pop_50_nu pop_51_de pop_51_nu; run;

proc contents position; run;
Data jodi1.cohort_msa_103_01_06; set jodi1.cohort_msa_103_01_06; drop _freq_ _type_; run;
proc freq; table pop_01_de--pop_51_nu; run;




**  IP Death  **;
%Macro tx;
%Mend tx;
%let tx=103_01_06;%tx; 
%let tx=112_01_06;%tx; %let tx=121_01_06;%tx; %let tx=131_01_06;%tx; %let tx=141_01_06;%tx; %let tx=151_01_06;%tx; 
%let tx=103_07_12;%tx; %let tx=112_07_12;%tx; %let tx=121_07_12;%tx; %let tx=131_07_12;%tx; %let tx=141_07_12;%tx; %let tx=151_07_12;%tx; 


%Macro tx;

%Mend tx;
%let tx=103;%tx; %let tx=112;%tx; %let tx=121;%tx; %let tx=131;%tx; %let tx=141;%tx; %let tx=151;%tx; 


