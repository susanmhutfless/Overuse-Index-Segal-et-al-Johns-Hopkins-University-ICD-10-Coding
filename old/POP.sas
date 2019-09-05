libname ccw 'D:\Overuse'; 

proc freq Data=ccw.kitty_proc_carrier; table HCPCS_CD; run; 
proc freq Data=ccw.kitty_icdproc_outpatient; table proc; run; 
proc contents Data=ccw.kitty_icd_MedPAR; run;
proc contents Data=ccw.kitty_proc_carrier; run;


***   ICD Code   ***;
%Macro type;
Data ccw.kitty_icd_&type; set ccw.kitty_icd_&type;
length acs acs_angina cad low_back_pain prostate_ca DCIS traumatic_brain_injury OSA multiple_sclerosis foot_ulcer lung_cancer lung_cancer_out syncope_heat syncope_carotid_sinus CHF sinusitis AF_flutter heart_neoplasm herniated_disc mononeuritis malignancy chronic_ulcer heart_disease colon_screen pop_40 pop_41 pop_43 breast_cancer allergy acute_sinusitis chronic_sinusitis diabetes colon_screenICD back_pain pop49 trauma intraspinal_abcess pop51 pop52 curettage tardive_dyskinesia prostate_cancer cervical_cancer 3 icd4 $ 4 icd3 $ 3 icd_5 $ 1; 
acs=0; acs_angina=0; cad=0; low_back_pain=0; prostate_ca=0; DCIS=0; traumatic_brain_injury=0; OSA=0; multiple_sclerosis=0; foot_ulcer=0; lung_cancer=0; lung_cancer_out=0; syncope_heat=0; syncope_carotid_sinus=0; CHF=0; sinusitis=0; AF_flutter=0; heart_neoplasm=0; herniated_disc=0; mononeuritis=0; malignancy=0; chronic_ulcer=0; heart_disease=0; colon_screen=0; pop_40=0; pop_41=0; pop_43=0; breast_cancer=0; allergy=0; acute_sinusitis=0; chronic_sinusitis=0; diabetes=0; colon_screenICD=0; back_pain=0; pop49=0; trauma=0; intraspinal_abcess=0; pop51=0; pop52=0; curettage=0; tardive_dyskinesia=0; prostate_cancer=0; cervical_cancer=0;

if icd in ("33385 ") then tardive_dyskinesia=1; /* Tardive Dyskinesia */
if icd in ("4111  " "41181 " "41189 ") then acs=1; /*pop 1 & 2*/
if icd in ("410   " "4100  " "4101  " "4102  " "4103  " "4104  " "4105  " "4106  " "4107  " "4108  " "4109  " "4111  " "41181 " "41189 " "4130  " "4131  " "4139  " "78650 " "78651 " "78659 ") then acs_angina=1; /*pop 5*/
if icd in ("412   " "414   " "4142 " "4143 " "4144 " "4148 " "4149 ") then cad=1; /*pop 5*/
if icd in ("7242  ") then low_back_pain=1; /*pop 37*/
if icd in ("185   " "2334  ") then prostate_ca=1; /*pop 36*/
if icd in ("2330  ") then DCIS=1; /*pop 35*/
if icd in ("854   " "95901 ") then traumatic_brain_injury=1; /*pop 34*/
if icd in ("340   ") then multiple_sclerosis=1; /*pop 30*/
if icd in ("70706 " "70707 " "70713 " "70714 " "70715") then foot_ulcer=1; /*pop 29*/
if icd in ("1970  " "2357  " "2391  ") then lung_cancer=1; /*pop 28*/
if icd in ("1623  ") then lung_cancer_out=1; /*pop 28*/
if icd in ("7802  " "9921  ") then syncope_heat=1; /*pop 27*/
if icd in ("33701 ") then syncope_carotid_sinus=1; /*pop 27*/
if icd in ("428   " "4280  " "4281  " "4289  ") then CHF=1; /*pop 26*/
if icd in ("2334  ") and position='1' then prostate_cancer=1; /*Prostate cancer*/

if icd in ("6909  ") then curettage=1; /*cervical cancer*/

if icd in ("1641  " "2127  ") then heart_neoplasm=1; /*pop 7*/
if icd in ("7221  " "7222  " "7223  " "7225  " "7226  " "7227  " "72270 " "72272 " "72273 " "7228  " "72280 " "72282 " "72283 " "7229  " "72290 " "72292 " "72293 ") then herniated_disc=1; /*pop 10*/
if icd in ("3550  " "3557  " "3558  " "3559  " "7243  " "7244  " "7292  ") then mononeuritis=1; /*pop 10*/
if icd in ("179   ") then malignancy=1; /*pop 11*/
if icd in ("4540  " "4542  " "45931 " "45933 " "707   " "7070  " "7071  " "7078  " "7079  ") then chronic_ulcer=1; /*pop 18*/
if icd in ("39891 " "40201 " "40211 " "40201 " "4280  " "4281  ") then heart_disease=1; /*pop 38*/
if icd in ("V7651 ") then colon_screen=1; /*pop 39*/
if icd in ("1580  " "1890  " "20100 " "2230  " "40390 " "5849  " "4859  " "59970 " "7944  " "59080 " "5909  " "591   " "5932  " "59654 " "5990  ") then pop_40=1; /*pop 40*/
if icd in ("7859  " "7842  " "36234 " "4359  " "43310 " "34290 " "7802  " "7813  " "4370  ") then pop_41=1; /*pop 41*/
if icd in ("1740  " "1741  " "1742  " "1743  " "1744  " "1745  " "1746  " "1747  " "1748  " "1749  ") then breast_cancer=1; /*pop 45*/
if icd in ("4770  " "4771  " "4772  " "4778  " "4779  " "4930  " "49302 " "4939  " "49390 " "49392 " "7080  " "9953  ") then allergy=1; /*pop 46*/
if icd in ("4610  " "4611  " "4612  " "4613  " "4618  " "4619  ") then acute_sinusitis=1; /*pop 47*/
if icd in ("4730  " "4731  " "4732  " "4733  " "4738  " "4739  ") then chronic_sinusitis=1; /*pop 47*/
if icd in ("V7651 ") then colon_screenICD=1; /*pop 48*/
if icd in ("7213  " "72190 " "72210 " "72252 " "7226  " "72293 " "72402 " "7242  " "7243  " "7245  " "7246  " "72470 " "72471 " "72479 " "7385  " "7393  " "7394  " "8460  " "8461  " "8462  " "8463  " "8468  " "8469  " "8472  ") then back_pain=1; /*pop 49*/
if icd in ("34460 " "34461 " "7292  " "2793  ") then pop49=1; /*pop 49*/
if icd in ("92611 " "92612 ") then trauma=1; /*pop 49*/
if icd in ("3249  " "3241  ") then intraspinal_abcess=1; /*pop 49*/
if icd in ("5939  " "1200  " "59970 " "59971 " "59972 " "2512  " "2510  " "2508  " "2703  " "2559  " "1550  " "1551  " "1552  " "1570  " "1571  " "1572  " "1573  " "1574  " "1578  " "1579  " "1890  " "2115  " "2116  " "2117  " "2230  ") then pop51=1; /*pop 51*/
if icd in ("92611 " "92612 " "37601" "3240  ") then pop52=1; /*pop 52*/


icd4=substr(icd, 1, 4);	icd3=substr(icd, 1, 3); icd_5=substr(icd, 5, 5);
if icd4 in ("8540" "8541") then traumatic_brain_injury=1; /*pop 34*/
if icd4 in ("3272") then OSA=1; /*pop 33*/
if icd4 in ("4140") then cad=1; /*pop 5*/
if icd3 in ("410") then acs=1; /*pop 1 & 2*/
if icd3 in ("850" "851" "852" "853") then traumatic_brain_injury=1; /*pop 34*/ 
if icd3 in ("162") and icd_5="" then lung_cancer=1; /*pop 28*/ 
if icd3 in ("4282" "4283" "4284") then CHF=1; /*pop 26*/
if icd4 in ("4273") then AF_flutter=1; /*pop 26*/
if icd3 in ("461" "473") and icd_5="" then sinusitis=1; /*pop 19 20 21*/ 
if icd3 in ("180") then cervical_cancer=1; /*Cervical Cancer*/
if icd3 in ("180") and position='1' then cervical_cancer=1; /*Cervical Cancer*/
if icd3 in ("185") and position='1' then prostate_cancer=1; /*Prostate Cancer*/

if icd3 in ("180" "182" "183" "184") and icd_5="" then malignancy=1; /*pop 11*/
if icd4 in ("7070" "7071") then chronic_ulcer=1; /*pop 18*/
if icd4 in ("4282" "4283" "4284") then heart_disease=1; /*pop 38*/
if icd3 in ("466" "480" "481" "482" "483" "484" "485" "486" "487" "488" "490" "491" "492" "493" "494" "495" "496" "500" "501" "502" "503" "504" "505" "506" "507" "508" "510" "511" "512" "513" "514" "515" "516" "517" "518" "519") then pop_43=1; /*pop 43*/
if icd3 in ("250") then diabetes=1; /*pop 48*/
if icd3 in ("140" "141" "142" "143" "144" "145" "146" "147" "148" "149" "150" "151" "152" "153" "154" "155" "156" "157" "158" "159" "160" "161" "162" "163" "164" "165" "166" "167" "168" "169" "170" "171" "172" "173" "174" "175" "176" "177" "178" "179" "180" "181" "182" "183" "184" "185" "186" "187" "188" "189" "190" "191" "192" "193" "194" "195" "196" "197" "198" "199" "200" "201" "202" "203" "204" "205" "206" "207" "208" "230" "231" "232" "233" "234" "235" "236" "237" "238" "239" "042" "043" "044") then pop49=1; /*pop 49*/
if icd4 in ("3040" "3041" "3042" "3044" "3054" "3055" "3056" "3057") then pop49=1; /*pop 49*/
if icd3 in ("800" "801" "802" "803" "804" "805" "806" "807" "808" "809" "810" "811" "812" "813" "814" "815" "816" "817" "818" "819" "820" "821" "822" "823" "824" "825" "826" "827" "828" "829" "830" "831" "832" "833" "834" "835" "836" "837" "838" "839" "850" "851" "852" "853" "854" "860" "861" "862" "863" "864" "865" "866" "867" "868" "869" "905" "906" "907" "908" "909" "929" "952" "958" "959") then trauma=1; /*pop 49*/
if icd3 in ("194" "277" "237") then pop51=1; /*pop 51*/
if icd3 in ("140" "141" "142" "143" "144" "145" "146" "147" "148" "149" "150" "151" "152" "153" "154" "155" "156" "157" "158" "159" "160" "161" "162" "163" "164" "165" "166" "167" "168" "169" "170" "171" "172" "173" "174" "175" "176" "177" "178" "179" "180" "181" "182" "183" "184" "185" "186" "187" "188" "189" "190" "191" "192" "193" "194" "195" "196" "197" "198" "199" "200" "201" "202" "203" "204" "205" "206" "207" "208" "209" "210" "211" "212" "213" "214" "215" "216" "217" "218" "219" "220" "221" "222" "223" "224" "225" "226" "227" "228" "229" "230" "231" "232" "233" "234" "235" "236" "237" "238" "239" "800" "801" "802" "803" "804" "805" "806" "807" "808" "809" "810" "811" "812" "813" "814" "815" "816" "817" "818" "819" "820" "821" "822" "823" "824" "825" "826" "827" "828" "829" "830" "831" "832" "833" "834" "835" "836" "837" "838" "839""850" "851" "852" "853" "854" "860" "861" "862" "863" "864" "865" "866" "867" "868" "869" "905" "906" "907" "908" "909" "929" "952" "958" "959") then pop52=1; /*pop 52*/

run;
proc means; var acs acs_angina cad low_back_pain prostate_ca DCIS traumatic_brain_injury OSA multiple_sclerosis foot_ulcer lung_cancer lung_cancer_out syncope_heat syncope_carotid_sinus CHF sinusitis AF_flutter heart_neoplasm herniated_disc mononeuritis malignancy chronic_ulcer heart_disease colon_screen pop_40 pop_41 pop_43 breast_cancer allergy acute_sinusitis chronic_sinusitis diabetes colon_screenICD back_pain pop49 trauma intraspinal_abcess pop51 pop52 curettage tardive_dyskinesia prostate_cancer cervical_cancer; run;
%Mend type; %let type=carrier; %type; %let type=outpatient; %type; %let type=carrier_death; %type; %let type=outpatient_death; %type;


***   CPT/HCPCS Procedure Code   ***;
%Macro type;
Data ccw.kitty_proc_&type; set ccw.kitty_proc_&type;
length stress_echocardiography cardiac_rehab revascularization_proc cardiac_ct er_visit traction prostate_scan prostate_risk MRI_chest MRI_breast MRI_brain soft_palate_implants h_pylori_test hyperbaric_oxygen EEG digoxin MRI_knee knee_surgery prostatectomy PSA PAP_test allergy_testing fiberoptic_laryngoscopy diagnostic_endoscopy echocardiogram myocardial_perfusion laminectomy hysterectomy ptca cabg hip_arthroplasty knee_arthroplasty pt_visit wound_culture biopsy colon_screen aaa_screen carotid_ultrasound carotid_image radiology tumor_marker anesthesia allergy_test46 sinus_ct dialysis cancer_screen lumbar_mri therapies evaluations lumbar_surgerythorax_ct thorax_contrast abdomen_ct abdomen_contrast brain_ct sinus_ct dilation colpscopy prostate_biopsy 3 HCPCS_CD_num 5;
stress_echocardiography=0; cardiac_rehab=0; revascularization_proc=0; cardiac_ct=0; er_visit=0; traction=0; prostate_scan=0; prostate_risk=0; MRI_chest=0; MRI_breast=0; MRI_brain=0; soft_palate_implants=0; h_pylori_test=0; hyperbaric_oxygen=0; EEG=0; digoxin=0; MRI_knee=0; knee_surgery=0; prostatectomy=0; PSA=0; PAP_test=0; allergy_testing=0; fiberoptic_laryngoscopy=0; diagnostic_endoscopy=0; echocardiogram=0; myocardial_perfusion=0; laminectomy=0; hysterectomy=0; ptca=0; cabg=0; hip_arthroplasty=0; knee_arthroplasty=0; pt_visit=0; wound_culture=0; biopsy=0; colon_screen=0; aaa_screen=0; carotid_ultrasound=0; carotid_image=0; radiology=0; tumor_marker=0; anesthesia=0; allergy_test46=0; sinus_ct=0; dialysis=0; cancer_screen=0; lumbar_mri=0; therapies=0; evaluations=0; lumbar_surgery=0; thorax_ct=0; thorax_contrast=0; abdomen_ct=0; abdomen_contrast=0; brain_ct=0; sinus_ct=0; dilation=0; colpscopy=0; prostate_biopsy=0;

if HCPCS_CD in ("93350" "93351" "C8928" "C8930") then stress_echocardiography=1; /*pop 1*/
if HCPCS_CD in ("93797" "93798" "G0422" "G0423" "S9472") then cardiac_rehab=1; /*pop 2*/
if HCPCS_CD in ("33533" "33534" "33535" "33536" "33510" "33511" "33512" "33513" "33514" "33516" "33517" "33518" "33519" "33521" "33522" "33523" "33572" "92980" "92982" "92995" "4110F" "S2205" "S2206" "S2207" "S2208" "S2209") then revascularization_proc=1; /*pop 3*/
if HCPCS_CD in ("75571" "75572" "75574") then cardiac_ct=1; /*pop 5*/
if HCPCS_CD in ("97012" "97140" "E0830") then traction=1; /*pop 37*/
if HCPCS_CD in ("78811" "78812" "78813" "78814" "78815" "78816" "72192" "72193" "72194" "3269F" "77074" "77075") then prostate_scan=1; /*pop 36*/
if HCPCS_CD in ("3272F" "3273F") then prostate_risk=1; /*pop 36*/
if HCPCS_CD in ("78811" "78812" "78813" "78814" "78815" "78816") then pet_scan=1; /*pop 36*/
if HCPCS_CD in ("77058" "77059") then MRI_breast=1; /*pop 35*/
if HCPCS_CD in ("71550" "71551" "71552" "71555") then MRI_chest=1; /*pop 28 & 35*/
if HCPCS_CD in ("70551" "70552" "70553") then MRI_brain=1; /*pop 34*/
if HCPCS_CD in ("C9727") then soft_palate_implants=1; /*pop 33*/
if HCPCS_CD in ("86677") then h_pylori_test=1; /*pop 32*/
if HCPCS_CD in ("C1300" "99183" "A4575") then hyperbaric_oxygen=1; /*pop 29 & 30*/
if HCPCS_CD in ("3650F" "95812" "95813" "95816" "95819" "95822" "95827") then EEG=1; /*pop 27*/
if HCPCS_CD in ("80162") then digoxin=1; /*pop 26*/
if HCPCS_CD in ("73721" "73722" "73723") then MRI_knee=1; /*pop 25*/
if HCPCS_CD in ("27447") then knee_surgery=1; /*pop 25*/
if HCPCS_CD in ("99281" "99282" "99283" "99284" "99285") then er_visit=1; /* pop 24 */
if HCPCS_CD in ("84152" "84153" "84154" "G0103") then PSA=1; /*pop 23*/
if HCPCS_CD in ("3015F" "88141" "88142" "88143" "88147" "88148" "88150" "88152" "88153" "88154" "Q0091") then PAP_test=1; /*pop 22*/
if HCPCS_CD in ("31231" "31233" "31235") then diagnostic_endoscopy=1; /*pop 21*/
if HCPCS_CD in ("31575" "31476" "31577" "31578" "31579") then fiberoptic_laryngoscopy=1; /*pop 20*/
if HCPCS_CD in ("95004" "95010" "95015" "95024" "95027" "95028" "95044" "95065" "95199") then allergy_testing=1; /*pop 19*/

if HCPCS_CD in ("58120") then dilation=1; /*cervical cancer*/
if HCPCS_CD in ("57420" "57421" "57452" "57454" "57455" "57456" "57460" "57461") then colpscopy=1; /*cervical cancer*/
if HCPCS_CD in ("55700" "55705" "55706") then prostate_biopsy=1; /*prostate cancer*/

if HCPCS_CD in ("93306" "93307" "93308" "C8923" "C8924" "C8929") then echocardiogram=1; /*pop 7*/
if HCPCS_CD in ("78451" "78452" "78453" "78454" "78460" "78461" "78464" "78465" "78491" "78492") then myocardial_perfusion=1; /*pop 8, pop 9*/
if HCPCS_CD in ("22533" "22534" "22558" "22630" "0275T" "63005" "63012" "63017" "63030" "63035" "63042" "63047" "63200" "63267" "63272" "63173" "63185" "63190" "63191") then laminectomy=1; /*pop 10*/
if HCPCS_CD in ("58150" "58152" "58180" "58200" "52810" "58260" "58262" "58263" "58267" "58270" "58275" "58280" "58285" "58290" "58291" "58292" "59293" "59294" "58541" "58542" "58543" "58544" "58548" "58550" "58552" "58553" "58554" "58570" "58571" "58572" "58573") then hysterectomy=1; /*pop 11*/
if HCPCS_CD in ("92982" "92995") then ptca=1; /*pop 12*/
if HCPCS_CD in ("33510" "33511" "33512" "33513" "33514" "33515" "33516" "33517" "33518" "33519" "33520" "33521" "33522" "33523" "33524" "33525" "33526" "33527" "33528" "33529" "33530" "33533" "33534" "33535" "33536" "33537" "33538" "33539" "33540" "33541" "33542" "33543" "33544" "33545" "33546" "33547" "33548" "S2205" "S2206" "S2207" "S2208" "S2209") then cabg=1; /*pop 13*/
if HCPCS_CD in ("27130" "27134" "27137" "27138") then hip_arthroplasty=1; /*pop 14*/
if HCPCS_CD in ("27446" "27448" "27487") then knee_arthroplasty=1; /*pop 15*/
if HCPCS_CD in ("52601" "55801" "55810" "55812" "55815" "55821" "55831" "55840" "55845" "55866") then prostatectomy=1; /*pop 16*/
if HCPCS_CD in ("4260F" "4261F") then wound_culture=1; /*pop 18*/
if HCPCS_CD in ("97001" "97002" "99201" "99202" "99203" "99204" "99205" "99212" "99213" "99214" "99215" "99241" "99242" "99243" "99244" "99245") then pt_visit=1; /*pop 18*/
if HCPCS_CD in ("93505") then biopsy=1; /*pop 38*/
if HCPCS_CD in ("G0105" "G0120" "G0121" "G0104" "G0106" "G0122" "G0328 ") then colon_screen=1; /*pop 39*/
if HCPCS_CD in ("G0389") then aaa_screen=1; /*pop 40*/
if HCPCS_CD in ("93880") then carotid_ultrasound=1; /*pop 41*/
if HCPCS_CD in ("3100F") then carotid_image=1; /*pop 41*/
if HCPCS_CD in ("71010" "71020") then radiology=1; /*pop 43*/
if HCPCS_CD in ("82378" "86300") then tumor_marker=1; /*pop 45*/
if HCPCS_CD in ("82701" "82784" "82785" "82787" "86005") then allergy_test46=1; /*pop 46*/
if HCPCS_CD in ("70486" "70487" "70488") then sinus_ct=1; /*pop 47*/
if HCPCS_CD in ("4052F" "4053F" "4054F") then dialysis=1; /*pop 48*/
if HCPCS_CD in ("G0105" "G0120" "G0121" "45379" "45380" "45381" "45382" "45383" "45384" "45385" "84152" "84153" "84154" "G0103" "3015F" "88141" "88142" "88143" "88147" "88148" "88150" "88152" "88153" "88154" "Q0091" "77057" "G0202") then cancer_screen=1; /*pop 48*/
if HCPCS_CD in ("72148" "72149" "72158") then lumbar_mri=1; /*pop 49*/
if HCPCS_CD in ("97110" "97112" "97113" "97124" "97140" "98940" "98941" "98942" "98943") then therapies=1; /*pop 49*/
if HCPCS_CD in ("99201" "99202" "99203" "99204" "99205" "99211" "99212" "99213" "99214" "99215" "99241" "99242" "99243" "99244" "99245" "99341" "99342" "99343" "99344" "99345" "99347" "99348" "99349" "99350" "99354" "99355" "99356" "99357" "99385" "99386" "99387" "99395" "99396" "99397" "99401" "99402" "99403" "99404" "99455" "99456" "99499") then evaluations=1; /*pop 49*/
if HCPCS_CD in ("22899") then lumbar_surgery=1; /*pop 49*/
if HCPCS_CD in ("71250" "71260" "71270") then thorax_ct=1; /*pop 50*/
if HCPCS_CD in ("71270") then thorax_contrast=1; /*pop 50*/
if HCPCS_CD in ("74150" "74160" "74170") then abdomen_ct=1; /*pop 51*/
if HCPCS_CD in ("74170") then abdomen_contrast=1; /*pop 51*/
if HCPCS_CD in ("70450" "70460" "70470") then brain_ct=1; /*pop 52*/
if HCPCS_CD in ("70486" "70487" "70488") then sinus_ct=1; /*pop 52*/


HCPCS_CD_num=HCPCS_CD*1;
if HCPCS_CD_num  >= 100 AND HCPCS_CD_num  <= 2101 then anesthesia=1; /*pop 43*/
if HCPCS_CD_num  >= 22010 AND HCPCS_CD_num  <= 22865 then lumbar_surgery=1; /*pop 49*/

run;
proc means; var stress_echocardiography cardiac_rehab revascularization_proc cardiac_ct er_visit traction  prostate_scan prostate_risk MRI_chest MRI_breast MRI_brain soft_palate_implants h_pylori_test hyperbaric_oxygen EEG digoxin MRI_knee knee_surgery PSA PAP_test allergy_testing fiberoptic_laryngoscopy diagnostic_endoscopy echocardiogram myocardial_perfusion laminectomy hysterectomy ptca cabg hip_arthroplasty knee_arthroplasty prostatectomy pt_visit wound_culture biopsy colon_screen aaa_screen carotid_ultrasound carotid_image radiology tumor_marker anesthesia allergy_test46 sinus_ct dialysis cancer_screen lumbar_mri therapies evaluations lumbar_surgery thorax_ct thorax_contrast abdomen_ct abdomen_contrast brain_ct sinus_ct dilation colpscopy prostate_biopsy; run;
%Mend type; %let type=carrier; %type; %let type=op_rc; %type; %let type=carrier_death; %type; %let type=op_rc_death; %type;



***   ICD Procedure Code   ***;
%Macro type;
Data ccw.kitty_&type; set ccw.kitty_&type;
length hyperbaric_oxygen revascularization knee_surgery echocardioography spinal_fusion hysterectomy hip_arthroplasty knee_arthroplasty prostatectomy 3 proc3 $ 3;
hyperbaric_oxygen=0; revascularization=0; knee_surgery=0;echocardioography=0; spinal_fusion=0; hysterectomy=0; hip_arthroplasty=0; knee_arthroplasty=0; prostatectomy=0;
if proc in ("360  " "3600 " "3601 " "3602 " "3603 " "3604 " "3605 " "3606 " "3607 " "3608 " "3609 " "0066 " "361  " "3610 " "3611 " "3612 " "3613 " "3614 " "3615 " "3616 " "3617 " "3618 " "3619 " "3699 ") then revascularization=1; /*pop 3, pop 9*/
if proc in ("8154 ") then knee_surgery=1; /*pop 25*/
if proc in ("9395 ") then hyperbaric_oxygen=1; /*pop 30*/

if proc in ("8872 ") then echocardioography=1; /*pop 7*/
if proc in ("8051 " "8106 " "8107 " "8108 " "8467 " "8465 ") then spinal_fusion=1; /*pop 10*/
if proc in ("683  " "6831 " "6839 " "684  " "6841 " "6849 " "685  " "6851 " "6859 " "686  " "6861 " "6869 " "687  " "6871 " "6879 " "689  ") then hysterectomy=1; /*pop 11*/
if proc in ("361  " "362  " "363  " "369  ") then cabg=1; /*pop 13*/
if proc in ("8151 ") then hip_arthroplasty=1; /*pop 14*/
if proc in ("8154 ") then knee_arthroplasty=1; /*pop 15*/
if proc in ("602  " "6021 " "6029 " "603  " "604  " "605  " "606  " "6061 " "6062 " "6069 ") then prostatectomy=1; /*pop 16*/
if proc in ("3725 ") then biopsy=1; /*pop 38*/

proc3=substr(proc, 1, 3);
if proc3 in ("361  " "363  " "369  ") then cabg=1; /*pop 13*/

run;
proc means; var hyperbaric_oxygen revascularization knee_surgery echocardioography spinal_fusion hysterectomy hip_arthroplasty knee_arthroplasty prostatectomy; run;
%Mend type; %let type=icdproc_outpatient; %type; %let type=proc_MedPAR; %type; %let type=icdproc_outpatient_death; %type; %let type=proc_MedPAR_death; %type;


***   Hospitalization   ***;
%Macro type;
Data ccw.kitty_icd_&type; set ccw.kitty_icd_&type;
length acs acs_angina acs_angina_ip_12 acs_ip_12 acs_drg revascularization cad low_back_pain prostate_ca DCIS traumatic_brain_injury OSA multiple_sclerosis foot_ulcer lung_cancer lung_cancer_out syncope_heat syncope_carotid_sinus CHF sinusitis AF_flutter heart_neoplasm herniated_disc mononeuritis malignancy chronic_ulcer spinal_fusion ptca cabg heart_disease colon_screen pop_40 pop_41 pop_43 breast_cancer allergy acute_sinusitis chronic_sinusitis diabetes colon_screenICD back_pain pop49 trauma intraspinal_abcess pop51 pop52 3 icd4 $ 4 icd3 $ 3 icd_5 $ 1; 
acs=0; acs_angina=0; acs_angina_ip_12=0; acs_ip_12=0; acs_drg=0; revascularization=0; cad=0; low_back_pain=0; prostate_ca=0; DCIS=0; traumatic_brain_injury=0; OSA=0; multiple_sclerosis=0; foot_ulcer=0; lung_cancer=0; lung_cancer_out=0; syncope_heat=0; syncope_carotid_sinus=0; CHF=0; sinusitis=0; AF_flutter=0; heart_neoplasm=0; herniated_disc=0; mononeuritis=0; chronic_ulcer=0; heart_disease=0; colon_screen=0; pop_40=0; pop_41=0; pop_43=0; breast_cancer=0;	allergy=0; acute_sinusitis=0; chronic_sinusitis=0; diabetes=0; colon_screenICD=0;back_pain=0; pop49=0; trauma=0; intraspinal_abcess=0; pop51=0; pop52=0;
spinal_fusion=0; malignancy=0; ptca=0; cabg=0;

if position in ("1" "2") and icd in ("410   " "4100  " "4101  " "4102  " "4103  " "4104  " "4105  " "4106  " "4107  " "4108  " "4109  " "4111  " "41181 " "41189 " "4130  " "4131  " "4139  " "78650 " "78651 " "78659 ") then acs_angina_ip_12=1; /*pop 2*/
if position in ("1" "2") and icd in ("4111  " "41181 " "41189 ") then acs_ip_12=1; /*pop 8*/

if icd in ("4111  " "41181 " "41189 ") then acs=1; /*pop 1 & 2*/
if icd in ("410   " "4100  " "4101  " "4102  " "4103  " "4104  " "4105  " "4106  " "4107  " "4108  " "4109  " "4111  " "41181 " "41189 " "4130  " "4131  " "4139  " "78650 " "78651 " "78659 ") then acs_angina=1; /*pop 5*/
if icd in ("412   " "414   " "4142 " "4143 " "4144 " "4148 " "4149 ") then cad=1; /*pop 5*/
if icd in ("7242  ") then low_back_pain=1; /*pop 37*/
if icd in ("185   " "2334  ") then prostate_ca=1; /*pop 36*/
if icd in ("2330  ") then DCIS=1; /*pop 35*/
if icd in ("854   " "95901 ") then traumatic_brain_injury=1; /*pop 34*/
if icd in ("340   ") then multiple_sclerosis=1; /*pop 30*/
if icd in ("70706 " "70707 " "70713 " "70714 " "70715") then foot_ulcer=1; /*pop 29*/
if icd in ("1970  " "2357  " "2391  ") then lung_cancer=1; /*pop 28*/
if icd in ("1623  ") then lung_cancer_out=1; /*pop 28*/
if icd in ("7802  " "9921  ") then syncope_heat=1; /*pop 27*/
if icd in ("33701 ") then syncope_carotid_sinus=1; /*pop 27*/
if icd in ("428   " "4280  " "4281  " "4289  ") then CHF=1; /*pop 26*/

if icd in ("1641  " "2127  ") then heart_neoplasm=1; /*pop 7*/
if icd in ("7221  " "7222  " "7223  " "7225  " "7226  " "7227  " "72270 " "72272 " "72273 " "7228  " "72280 " "72282 " "72283 " "7229  " "72290 " "72292 " "72293 ") then herniated_disc=1; /*pop 10*/
if icd in ("3550  " "3557  " "3558  " "3559  " "7243  " "7244  " "7292  ") then mononeuritis=1; /*pop 10*/
if icd in ("179   ") then malignancy=1; /*pop 11*/
if icd in ("4540  " "4542  " "45931 " "45933 " "707   " "7070  " "7071  " "7078  " "7079  ") then chronic_ulcer=1; /*pop 18*/
if icd in ("39891 " "40201 " "40211 " "40201 " "4280  " "4281  ") then heart_disease=1; /*pop 38*/
if icd in ("V7651 ") then colon_screen=1; /*pop 39*/
if icd in ("1580  " "1890  " "20100 " "2230  " "40390 " "5849  " "4859  " "59970 " "7944  " "59080 " "5909  " "591   " "5932  " "59654 " "5990  ") then pop_40=1; /*pop 40*/
if icd in ("7859  " "7842  " "36234 " "4359  " "43310 " "34290 " "7802  " "7813  " "4370  ") then pop_41=1; /*pop 41*/
if icd in ("1740  " "1741  " "1742  " "1743  " "1744  " "1745  " "1746  " "1747  " "1748  " "1749  ") then breast_cancer=1; /*pop 45*/
if icd in ("4770  " "4771  " "4772  " "4778  " "4779  " "4930  " "49302 " "4939  " "49390 " "49392 " "7080  " "9953  ") then allergy=1; /*pop 46*/
if icd in ("4610  " "4611  " "4612  " "4613  " "4618  " "4619  ") then acute_sinusitis=1; /*pop 47*/
if icd in ("4730  " "4731  " "4732  " "4733  " "4738  " "4739  ") then chronic_sinusitis=1; /*pop 47*/
if icd in ("V7651 ") then colon_screenICD=1; /*pop 48*/
if icd in ("7213  " "72190 " "72210 " "72252 " "7226  " "72293 " "72402 " "7242  " "7243  " "7245  " "7246  " "72470 " "72471 " "72479 " "7385  " "7393  " "7394  " "8460  " "8461  " "8462  " "8463  " "8468  " "8469  " "8472  ") then back_pain=1; /*pop 49*/
if icd in ("34460 " "34461 " "7292  " "2793  ") then pop49=1; /*pop 49*/
if icd in ("92611 " "92612 ") then trauma=1; /*pop 49*/
if icd in ("3249  " "3241  ") then intraspinal_abcess=1; /*pop 49*/
if icd in ("5939  " "1200  " "59970 " "59971 " "59972 " "2512  " "2510  " "2508  " "2703  " "2559  " "1550  " "1551  " "1552  " "1570  " "1571  " "1572  " "1573  " "1574  " "1578  " "1579  " "1890  " "2115  " "2116  " "2117  " "2230  ") then pop51=1; /*pop 51*/
if icd in ("92611 " "92612 " "37601" "3240  ") then pop52=1; /*pop 52*/


icd4=substr(icd, 1, 4);	icd3=substr(icd, 1, 3); icd_5=substr(icd, 5, 5);
if icd4 in ("8540" "8541") then traumatic_brain_injury=1; /*pop 34*/
if icd4 in ("3272") then OSA=1; /*pop 33*/
if icd4 in ("4140") then cad=1; /*pop 5*/
if icd3 in ("410") then acs=1; /*pop 1 & 2*/
if position in ("1" "2") and icd3 in ("410") then acs_ip_12=1; /*pop 8*/
if icd3 in ("850" "851" "852" "853") then traumatic_brain_injury=1; /*pop 34*/ 
if icd3 in ("162") and icd_5="" then lung_cancer=1; /*pop 28*/ 
if icd3 in ("4282" "4283" "4284") then CHF=1; /*pop 26*/
if icd4 in ("4273") then AF_flutter=1; /*pop 26*/
if icd3 in ("461" "473") and icd_5="" then sinusitis=1; /*pop 19 20 21*/ 

if icd3 in ("180" "182" "183" "184") and icd_5="" then malignancy=1; /*pop 11*/
if icd4 in ("7070" "7071") then chronic_ulcer=1; /*pop 18*/
if icd4 in ("4282" "4283" "4284") then heart_disease=1; /*pop 38*/
if icd3 in ("466" "480" "481" "482" "483" "484" "485" "486" "487" "488" "490" "491" "492" "493" "494" "495" "496" "500" "501" "502" "503" "504" "505" "506" "507" "508" "510" "511" "512" "513" "514" "515" "516" "517" "518" "519") then pop_43=1; /*pop 43*/
if icd3 in ("250") then diabetes=1; /*pop 48*/
if icd3 in ("140" "141" "142" "143" "144" "145" "146" "147" "148" "149" "150" "151" "152" "153" "154" "155" "156" "157" "158" "159" "160" "161" "162" "163" "164" "165" "166" "167" "168" "169" "170" "171" "172" "173" "174" "175" "176" "177" "178" "179" "180" "181" "182" "183" "184" "185" "186" "187" "188" "189" "190" "191" "192" "193" "194" "195" "196" "197" "198" "199" "200" "201" "202" "203" "204" "205" "206" "207" "208" "230" "231" "232" "233" "234" "235" "236" "237" "238" "239" "042" "043" "044") then pop49=1; /*pop 49*/
if icd4 in ("3040" "3041" "3042" "3044" "3054" "3055" "3056" "3057") then pop49=1; /*pop 49*/
if icd3 in ("800" "801" "802" "803" "804" "805" "806" "807" "808" "809" "810" "811" "812" "813" "814" "815" "816" "817" "818" "819" "820" "821" "822" "823" "824" "825" "826" "827" "828" "829" "830" "831" "832" "833" "834" "835" "836" "837" "838" "839" "850" "851" "852" "853" "854" "860" "861" "862" "863" "864" "865" "866" "867" "868" "869" "905" "906" "907" "908" "909" "929" "952" "958" "959") then trauma=1; /*pop 49*/
if icd3 in ("194" "277" "237") then pop51=1; /*pop 51*/
if icd3 in ("140" "141" "142" "143" "144" "145" "146" "147" "148" "149" "150" "151" "152" "153" "154" "155" "156" "157" "158" "159" "160" "161" "162" "163" "164" "165" "166" "167" "168" "169" "170" "171" "172" "173" "174" "175" "176" "177" "178" "179" "180" "181" "182" "183" "184" "185" "186" "187" "188" "189" "190" "191" "192" "193" "194" "195" "196" "197" "198" "199" "200" "201" "202" "203" "204" "205" "206" "207" "208" "209" "210" "211" "212" "213" "214" "215" "216" "217" "218" "219" "220" "221" "222" "223" "224" "225" "226" "227" "228" "229" "230" "231" "232" "233" "234" "235" "236" "237" "238" "239" "800" "801" "802" "803" "804" "805" "806" "807" "808" "809" "810" "811" "812" "813" "814" "815" "816" "817" "818" "819" "820" "821" "822" "823" "824" "825" "826" "827" "828" "829" "830" "831" "832" "833" "834" "835" "836" "837" "838" "839""850" "851" "852" "853" "854" "860" "861" "862" "863" "864" "865" "866" "867" "868" "869" "905" "906" "907" "908" "909" "929" "952" "958" "959") then pop52=1; /*pop 52*/

if drg_cd in ("281" "282" "283" "284" "285" "286" "287") then do; acs=1; acs_drg=1; acs_angina=1; acs_angina_ip_12=1; end; /*pop 2*/
if drg_cd in ("231" "232" "233" "234" "235" "236" "246" "247" "248" "249" "250" "251") then revascularization=1; /*pop 3*/

if drg_cd in ("459" "460") then spinal_fusion=1; /*pop 10*/
if drg_cd in ("734" "735" "736" "737" "738" "739" "740" "741" "754" "755" "756") then malignancy=1; /*pop 11*/
if drg_cd in ("246" "247" "248" "249" "250" "251") then ptca=1; /*pop 12*/
if drg_cd in ("231" "232" "233" "234" "235" "236") then cabg=1; /*pop 13*/

run;
proc means; var acs acs_angina acs_angina_ip_12 acs_ip_12 acs_drg revascularization cad low_back_pain prostate_ca DCIS traumatic_brain_injury OSA multiple_sclerosis foot_ulcer lung_cancer lung_cancer_out syncope_heat syncope_carotid_sinus CHF sinusitis AF_flutter heart_neoplasm herniated_disc mononeuritis malignancy chronic_ulcer spinal_fusion ptca cabg heart_disease colon_screen pop_40 pop_41 pop_43 breast_cancer allergy acute_sinusitis chronic_sinusitis diabetes colon_screenICD back_pain pop49 trauma intraspinal_abcess pop51 pop52 spinal_fusion malignancy ptca cabg; run;
%Mend type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;

%Macro type;
Data ccw.kitty_proc_&type; set ccw.kitty_proc_&type;
length EEG 3; EEG=0;
if proc in ("8914 ") then EEG=1; /*pop 27*/
run;
proc means; var eeg; run;
%Mend type; %let type=MedPAR; %type; %let type=MedPAR_death; %type;




**  For Jodi Frailty ICD Procedure Code   ***;
%Macro type;
Data a_&type; set ccw.kitty_&type; length frailty 3; frailty=0; if proc in ("3501 " "3511 " "3521 " "3522 ") then frailty=1;
keep bene_id frailty proc; run;
proc means; var frailty; run;
%Mend type; %let type=icdproc_outpatient; %type; %let type=proc_MedPAR; %type; %let type=icdproc_outpatient_death; %type; %let type=proc_MedPAR_death; %type;

Data a; set a_icdproc_outpatient a_proc_MedPAR a_icdproc_outpatient_death a_proc_MedPAR_death; where frailty=1; run;
proc freq; table proc; run;
proc sort nodupkey; by bene_id frailty; run;

%Macro type;
Data a_&type; set ccw.kitty_&type; length ICD_proc_3501 3; ICD_proc_3501=0; if proc="3501 " then ICD_proc_3501=1;
keep bene_id ICD_proc_3501; run;
proc means; var ICD_proc_3501; run;
%Mend type; %let type=icdproc_outpatient; %type; %let type=proc_MedPAR; %type; %let type=icdproc_outpatient_death; %type; %let type=proc_MedPAR_death; %type;

Data a; set a_icdproc_outpatient a_proc_MedPAR a_icdproc_outpatient_death a_proc_MedPAR_death; where ICD_proc_3501=1; run;
proc sort nodupkey; by bene_id ICD_proc_3501; run;
