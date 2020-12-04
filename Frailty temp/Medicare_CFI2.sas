/********************************************************************
* Job Name: Medicare_CFI.sas
* Job Desc: Calculate CFI by county and zip code on Medicare 20% sample 
* Input data: Medicare MBSF, inpatient, outpatient, and carrier base and revenue files
* Output data: CFI_county_15
*              CFI_zip_15
********************************************************************/

%global bene_id 	clm_id  	clm_from_dt 	clm_thru_dt  			
		bene_dob 	bene_sex 	bene_race 		COUNTY_CD ZIP_CD
		ENROLLMT_YR	startmonth	endmonth
		buyin 		hmo 		
		diag_pfx 	diag_cd_max
		proc_pfx 	proc_cd_max   
		hcpcs_cd
		vars_to_keep_mbsf  		
		vars_to_keep_car 		vars_to_keep_car_rev 
		vars_to_keep_ip 		vars_to_keep_ip_rev 
		vars_to_keep_op 		vars_to_keep_op_rev
		permlib;

%let  bene_id            = bene_id      		;
%let  clm_id             = clm_id            	;
%let  buyin              = MDCR_ENTLMT_BUYIN_IND_01 MDCR_ENTLMT_BUYIN_IND_02 MDCR_ENTLMT_BUYIN_IND_03 MDCR_ENTLMT_BUYIN_IND_04 MDCR_ENTLMT_BUYIN_IND_05 MDCR_ENTLMT_BUYIN_IND_06 MDCR_ENTLMT_BUYIN_IND_07 MDCR_ENTLMT_BUYIN_IND_08 MDCR_ENTLMT_BUYIN_IND_09 MDCR_ENTLMT_BUYIN_IND_10 MDCR_ENTLMT_BUYIN_IND_11 MDCR_ENTLMT_BUYIN_IND_12;
%let  hmo                = hmo_ind_01 hmo_ind_02 hmo_ind_03 hmo_ind_04 hmo_ind_05 hmo_ind_06 hmo_ind_07 hmo_ind_08 hmo_ind_09 hmo_ind_10 hmo_ind_11 hmo_ind_12;
%let  ENROLLMT_YR        = BENE_ENROLLMT_REF_YR ;
%let  clm_from_dt        = clm_from_dt   		;
%let  clm_thru_dt        = clm_thru_dt   		;
%let  bene_dob           = BENE_BIRTH_DT        ;
%let  bene_sex           = SEX_IDENT_CD         ;
%let  bene_race          = BENE_RACE_CD         ;
%let  diag_pfx           = ICD_DGNS_CD          ;
%let  diag_cd_max        = 25                 	;
%let  proc_pfx           = ICD_PRCDR_CD         ;
%let  proc_cd_max        = 25                 	;
%let  hcpcs_cd           = hcpcs_cd          	;
%let  COUNTY_CD          = COUNTY_CD          	;
%let  ZIP_CD             = ZIP_CD            	;
%let  startmonth         = 4            	 	;
%let  endmonth           = 9            	 	;


/** locations where data sets stored - please edit accordingly **/
*%let mbsfpath     = ; /** locations where MBSF data stored **/
*%let inpath       = ; /** locations where inpatient base and revenue data stored **/
*%let oppath       = ; /** locations where outpatient base and revenue data stored **/
*%let carpath      = ; /** locations where carrier base and line data stored **/
*%let outpath      = ; /** locations where output data will be stored **/
%let  permlib            = shu172sl          	;  /** permanent library location**/


/** locations where Charlson comorbidity macros stored - please edit accordingly **/
/*%let vrdc_code = /sas/config_m5/compute/Lev2/sasCCW;*/
/*%include "&vrdc_code.remove.ruleout.dxcodes.macro.sas";*/
/*%include "&vrdc_code.charlson.comorbidity.macro.sas";*/


/** vars to keep or delete from the different data sources **/
%let vars_to_keep_mbsf    = 	&bene_id &ENROLLMT_YR &buyin &hmo &ZIP_CD &COUNTY_CD &bene_dob. &bene_sex. &bene_race.;
%let vars_to_keep_car     = 	&bene_id &clm_id &clm_from_dt &clm_thru_dt &diag_pfx: &proc_pfx:;
%let vars_to_keep_car_rev = 	&bene_id &clm_id &clm_thru_dt &hcpcs_cd;
%let vars_to_keep_ip      = 	&bene_id &clm_id &clm_from_dt &clm_thru_dt &diag_pfx: &proc_pfx:;
%let vars_to_keep_ip_rev  = 	&bene_id &clm_id &clm_thru_dt &hcpcs_cd;
%let vars_to_keep_op      = 	&bene_id &clm_id &clm_from_dt &clm_thru_dt &diag_pfx: &proc_pfx:;
%let vars_to_keep_op_rev  = 	&bene_id &clm_id &clm_thru_dt &hcpcs_cd;

*libname mbsflib "&mbsfpath.";
*libname inlib "&inpath.";
*libname oplib "&oppath.";
*libname carlib "&carpath.";
*libname outlib "&outpath.";

proc format;
	value $fmt_ 
		"39891", "4280" , "4281" , "42820", "42821", "42822", "42823", "42830", "42831", "42832", "42833", "42840", "42841", "42842", "42843", "4289" = "CHF"
		"2900" , "29010", "29011", "29012", "29013", "29020", "29021", "2903" , "29040", "29041", "29042", "29043", "2908" , "2909" , "2930" , "2931" , "2940" , 
			     "2941" , "29410", "29411", "29420", "29421", "2948" , "2949" , "3100" , "3102" , "3108" , "31081", "31089", "3109" , "3310" , "3311" , "33111", "33119", 
			     "3312" , "33182", "797" = "Cognitive impairment"
		"34660", "34661", "34662", "34663", "430"  , "431"  , "4320" , "4321" , "4329" , "43301", "43311", "43321", "43331", "43381", "43391", "4340" , "43400",  
			     "43401", "4341" , "43410", "43411", "4349" , "43490", "43491", "436"  , "438"  , "4380" , "43810", "43811", "43812", "43813", "43814", "43819", "43820",  
			     "43821", "43822", "43830", "43831", "43832", "43840", "43841", "43842", "43850", "43851", "43852", "43853", "4386" , "4387" , "43881", "43882",  
			     "43883", "43884", "43885", "43889", "4389" = "Stroke"
		"7140" , "7141" , "7142" , "71430", "71431", "71432", "71433", "7144" , "71481", "71489", "7149" , "71500", "71504", "71509", "71510", "71511", "71512",  
			     "71513", "71514", "71515", "71516", "71517", "71518", "71520", "71521", "71522", "71523", "71524", "71525", "71526", "71527", "71528", "71530",  
			     "71531", "71532", "71533", "71534", "71535", "71536", "71537", "71538", "71580", "71589", "71590", "71591", "71592", "71593", "71594", "71595",  
			     "71596", "71597", "71598", "7200" , "V134" = "Arthritis"
		"29383", "29600", "29601", "29602", "29603", "29604", "29605", "29606", "29610", "29611", "29612", "29613", "29614", "29615", "29616", "29620", "29621",  
			     "29622", "29623", "29624", "29625", "29626", "29630", "29631", "29632", "29633", "29634", "29635", "29636", "29640", "29641", "29642", "29643",  
			     "29644", "29645", "29646", "29650", "29651", "29652", "29653", "29654", "29655", "29656", "29660", "29661", "29662", "29663", "29664", "29665",  
			     "29666", "2967" , "29680", "29681", "29682", "29689", "29690", "29699", "3004" , "3090" , "3091" , "30922", "30923", "30924", "30928", "30929",  
			     "3093" , "3094" , "30982", "30983", "30989", "3099" , "311" = "Depression"
		"29381", "29382", "29500", "29501", "29502", "29503", "29504", "29505", "29510", "29511", "29512", "29513", "29514", "29515", "29520", "29521", "29522",  
			     "29523", "29524", "29525", "29530", "29531", "29532", "29533", "29534", "29535", "29540", "29541", "29542", "29543", "29544", "29545", "29550",  
			     "29551", "29552", "29553", "29554", "29555", "29560", "29561", "29562", "29563", "29564", "29565", "29570", "29571", "29572", "29573", "29574",  
			     "29575", "29580", "29581", "29582", "29583", "29584", "29585", "29590", "29591", "29592", "29593", "29594", "29595", "2970" , "2971" , "2972" ,  
			     "2973" , "2978" , "2979" , "2980" , "2981" , "2982" , "2983" , "2984" , "2988" , "2989" = "Paranoid"
		"V463" = "Impaired mobility"
		"E8800", "E8801", "E8809", "E8810", "E8811", "E882" , "E8830", "E8831", "E8832", "E8839", "E8840", "E8841", "E8842", "E8843", "E8844", "E8845", "E8846",  
			     "E8849", "E885" , "E8850", "E8851", "E8852", "E8853", "E8854", "E8859", "E8860", "E8869", "E888" , "E8880", "E8881", "E8888", "E8889", "E9681",  
			     "E9870", "E9871", "E9872", "E9879" = "Falls"
		"1100" , "1101" , "1102" , "1103" , "1104" , "1105" , "1106" , "1108" , "1109" , "1110" , "1111" , "1112" , "1113" , "1118" , "1119" , "1120" ,  
			     "1121" , "1122" , "1123" , "1125" , "11282", "11284", "11285", "11289", "1129" , "1141" , "1143" , "1149" , "11500", "11509", "11510", "11519",  
			     "11590", "11599", "1160" , "1161" , "1162" , "1170" , "1171" , "1172" , "1173" , "1174" , "1175" , "1176" , "1177" , "1178" , "1179" , "118" = "Mycoses"
		"3320" = "Parkinson`s disease"
		"00322", "0203" , "0204" , "0205" , "0212" , "0221" , "0310" , "0391" , "0521" , "0551" , "0730" , "0830" , "1124" , "1140" , "1144" , "1145" ,  
			     "11505", "11515", "11595", "1304" , "1363" , "4800" , "4801" , "4802" , "4803" , "4808" , "4809" , "481"  , "4820" , "4821" , "4822" ,  
			     "4823" , "48230", "48231", "48232", "48239", "4824" , "48240", "48241", "48242", "48249", "4828" , "48281", "48282", "48283", "48284", "48289",  
			     "4829" , "483"  , "4830" , "4831" , "4838" , "4841" , "4843" , "4845" , "4846" , "4847" , "4848" , "485"  , "486"  , "5130" , "5171" = "Pneumonia"
		"0201" , "0210" , "0220" , "0311" , "03285", "035"  , "0390" , "6800" , "6801" , "6802" , "6803" , "6804" , "6805" , "6806" , "6807" , "6808" ,  
			     "6809" , "68100", "68101", "68102", "68110", "68111", "6819" , "6820" , "6821" , "6822" , "6823" , "6824" , "6825" , "6826" , "6827" ,  
			     "6828" , "6829" , "684"  , "6850" , "6851" , "6860" , "68600", "68601", "68609", "6861" , "6868" , "6869" = "Skin and subcutaneous tissue infections"
		"7070" , "70700", "70701", "70702", "70703", "70704", "70705", "70706", "70707", "70709", "7071", "70710", "70711", "70712", "70713", "70714", "70715",  
			     "70719", "70720", "70721", "70722", "70723", "70724", "70725", "7078" , "7079" = "Chronic ulcer of skin"
		"2740" , "27400", "27401", "27402", "27403", "27410", "27411", "27419", "27481", "27482", "27489", "2749", "71210", "71211", "71212", "71213", "71214",  
			     "71215", "71216", "71217", "71218", "71219", "71220", "71221", "71222", "71223", "71224", "71225", "71226", "71227", "71228", "71229", "71230",  
			     "71231", "71232", "71233", "71234", "71235", "71236", "71237", "71238", "71239", "71280", "71281", "71282", "71283", "71284", "71285", "71286",  
			     "71287", "71288", "71289", "71290", "71291", "71292", "71293", "71294", "71295", "71296", "71297", "71298", "71299" = "Gout and other crystal arthropathies"
		"03284", "59000", "59001", "59010", "59011", "5902" , "5903" , "59080", "59081", "5909" , "5950" , "5951" , "5952" , "5953" , "5954" , "59581", "59582",  
			     "59589", "5959" , "5970" , "59780", "59781", "59789", "59800", "59801", "5990" = "Urinary tract infections"
		"7130" , "7131" , "7132" , "7133" , "7134" , "7135" , "7136" , "7137" , "7138" , "71600", "71601", "71602", "71603", "71604", "71605", "71606", "71607",  
			     "71608", "71609", "71620", "71621", "71622", "71623", "71624", "71625", "71626", "71627", "71628", "71629", "71630", "71631", "71632", "71633",  
			     "71634", "71635", "71636", "71637", "71638", "71639", "71640", "71641", "71642", "71643", "71644", "71645", "71646", "71647", "71648", "71649",  
			     "71650", "71651", "71652", "71653", "71654", "71655", "71656", "71657", "71658", "71659", "71660", "71661", "71662", "71663", "71664", "71665",  
			     "71666", "71667", "71668", "71680", "71681", "71682", "71683", "71684", "71685", "71686", "71687", "71688", "71689", "71690", "71691", "71692",  
			     "71693", "71694", "71695", "71696", "71697", "71698", "71699", "71810", "71811", "71812", "71813", "71814", "71815", "71817", "71818", "71819",  
			     "71820", "71821", "71822", "71823", "71824", "71825", "71826", "71827", "71828", "71829", "71850", "71851", "71852", "71853", "71854", "71855",  
			     "71856", "71857", "71858", "71859", "71860", "71865", "71870", "71871", "71872", "71873", "71874", "71875", "71876", "71877", "71878", "71879",  
			     "71880", "71881", "71882", "71883", "71884", "71885", "71886", "71887", "71888", "71889", "71890", "71891", "71892", "71893", "71894", "71895",  
			     "71897", "71898", "71899", "71900", "71901", "71902", "71903", "71904", "71905", "71906", "71907", "71908", "71909", "71910", "71911", "71912",  
			     "71913", "71914", "71915", "71916", "71917", "71918", "71919", "71920", "71921", "71922", "71923", "71924", "71925", "71926", "71927", "71928",  
			     "71929", "71930", "71931", "71932", "71933", "71934", "71935", "71936", "71937", "71938", "71939", "71940", "71941", "71942", "71943", "71944",  
			     "71945", "71946", "71947", "71948", "71949", "71950", "71951", "71952", "71953", "71954", "71955", "71956", "71957", "71958", "71959", "71960",  
			     "71961", "71962", "71963", "71964", "71965", "71966", "71967", "71968", "71969", "7197 ", "71970", "71975", "71976", "71977", "71978", "71979",  
			     "71980", "71981", "71982", "71983", "71984", "71985", "71986", "71987", "71988", "71989", "71990", "71991", "71992", "71993", "71994", "71995",  
			     "71996", "71997", "71998", "71999", "7201" , "7202" , "72081", "72089", "7209" , "7210" , "7211" , "7212" , "7213" , "72141", "72142", "7215" ,  
			     "7216" , "7217" , "7218" , "72190", "72191", "7220" , "72210", "72211", "7222",  "72230", "72231", "72232", "72239", "7224" , "72251", "72252",  
			     "7226" , "72270", "72271", "72272", "72273", "72280", "72281", "72282", "72283", "72290", "72291", "72292", "72293", "7230" , "7231" , "7232" ,  
			     "7233" , "7234" , "7235" , "7236" , "7237" , "7238" , "7239" , "72400", "72401", "72402", "72403", "72409", "7241" , "7242" , "7243" , "7244" ,  
			     "7245" , "7246" , "72470", "72471", "72479", "7248" , "7249" , "73300", "73301", "73302", "73309", "7331" , "73310", "73311", "73312", "73313",  
			     "73314", "73315", "73316", "73319", "73393", "73394", "73395", "73396", "73397", "73398", "V1351", "7310" , "7311" , "7312" , "7313" , "7318" ,  
			     "7320" , "7321" , "7322" , "7323" , "7324" , "7325" , "7326" , "7327" , "7328" , "7329" , "73320", "73321", "73322", "73329", "7333" , "73340",  
			     "73341", "73342", "73343", "73344", "73345", "73349", "7335" , "7336" , "7337" , "73381", "73382", "73390", "73391", "73392", "73399", "73730",  
			     "73731", "73732", "7390" , "7391" , "7392" , "7393" , "7394" , "7395" , "7396" , "7397" , "7398" , "7399" , "V424" , "V486" , "V487" , "V494" ,  
			     "V8821", "V8822", "V8829" = "Musculoskeletal problem";
	value NA .="NA";
run;


*** Medicare part A, B and C coverage ***;
%macro mbsf(mbsource=, ipsource=, start=, end=, ip_pop_out=);
/** Beneficiaries with Part A+B coverage but not Part C from Apr 2015 - Sept 2015 **/
data include_cohort;
	set &mbsource.(keep=&vars_to_keep_mbsf.);
	array buyin{*} &buyin.;
	array hmo{*} &hmo.;
	do i = &startmonth. to &endmonth.;
		if buyin{i} not in ("C", "3") or hmo{i} not in ("0", "4") then exclude = 1;
	end;
	if exclude^=1;

	age=(&end.-&bene_dob.)/365.25;
	if age<65 then delete; *added 04dec2020;

	if &bene_sex.=1 then male=1; else if &bene_sex.=2 then male=0;

	if &bene_race.="1" then white=1; else if &bene_race. in ("2", "3", "4", "5", "6") then white=0;

	drop i exclude &ENROLLMT_YR. &buyin. &hmo. &bene_dob. &bene_sex. &bene_race.; 
run;

/** Beneficiaries with inpatient admissions from Apr 2015 - Sept 2015 **/
data ip; set &ipsource.; run;
proc sort data=ip out=ip2(keep=&bene_id.) nodupkey; by &bene_id.; run;

proc sort data=include_cohort; by &bene_id.; run;

data &ip_pop_out.; merge include_cohort(in=a) ip2(in=b); by &bene_id.; if a; if a and b then with_ip_6mopre=1; else if a and not b then with_ip_6mopre=0; run;
%mend;


/*** Diagnosis codes, procedure codes and HCPCS ***/
%macro claims(carbase=, carrev=, inbase=, inrev=, opbase=, oprev=, source=, claims_pop_out=, HCPCS_pop_out=);
/*** ICD-9 diagnosis and procedure codes ***/
data Bcarrier_base;
	set &carbase.;
	keep &bene_id. &clm_id. &clm_from_dt. &clm_thru_dt. &diag_pfx.:;
run;

data Inpatient_base;
	set &inbase.;
	keep &bene_id. &clm_id. &clm_from_dt. &clm_thru_dt. &diag_pfx.: &proc_pfx.:;
run;

data Outpatient_base;
	set &opbase.;
	keep &bene_id. &clm_id. &clm_from_dt. &clm_thru_dt. &diag_pfx.: &proc_pfx.:;
run;

data allclaims;
	set Bcarrier_base(in=a) Outpatient_base(in=b) Inpatient_base(in=c);
	if a then file="N"; 
		else if b then file="O";
		else if c then file="M";
run;

proc sort data=allclaims out=allclaimsnodup nodupkey; by &bene_id. file &clm_id. &clm_from_dt.; run;

data &claims_pop_out.;
	merge allclaimsnodup &source.(in=a keep=&bene_id.);
	by &bene_id.;
	if a;
run;


/*** HCPCS codes ***/
data Bcarrier_line;
	set &carrev.;
	keep &bene_id. &clm_id. &clm_thru_dt. &hcpcs_cd.;
run;

data Inpatient_revenue;
	set &inrev.;
	keep &bene_id. &clm_id. &clm_thru_dt. &hcpcs_cd.;
run;

data Outpatient_revenue;
	set &oprev.;
	keep &bene_id. &clm_id. &clm_thru_dt. &hcpcs_cd.;
run;

data rev;
	set Bcarrier_line(in=a) Inpatient_revenue(in=b) Outpatient_revenue(in=c);
run;

proc sort data=rev; by &bene_id. &clm_id.; run;
proc sort data=allclaims; by &bene_id. &clm_id.; run;

data rev2; 
	merge rev(in=a) allclaims(in=b keep=&bene_id. &clm_id. &clm_from_dt.);
	by &bene_id. &clm_id.;
run;

proc sort data=rev2 out=revnodup nodupkey; by &bene_id. &clm_id. &hcpcs_cd.; run;

data &HCPCS_pop_out.;
	merge revnodup &source.(in=a keep=&bene_id.);
	by &bene_id.;
	if a;
run;

%mend;


/** Beneficiaries Charlson comorbidity index **/
%macro charl(source=, claims_source=, hcpcs_source=, charl_pop_out=, begin=, end=);

/** Select the HCPCS codes used in calculation of Charlson comorbidity index **/
data include_hcpcs;
	set &hcpcs_source.;
	where &hcpcs_cd. in ('35011', '35013',  '35045', '35081', '35082', 
	    '35091', '35092', '35102', '35103', '35111', '35112', '35121', 
	    '35122', '35131', '35132', '35141', '35142', '35151', '35152', 
	    '35153', '35311', '35321', '35331', '35341', '35351', '35506', 
	    '35507', '35511', '35516', '35518', '35521', '35526', '35531', 
	    '35533', '35536', '35541', '35546', '35548', '35549', '35551',
	    '35556', '35558', '35560', '35563', '35565', '35566', '35571',
	    '35582', '35583', '35585', '35587', '35601', '35606', '35612',
	    '35616', '35621', '35623', '35626', '35631', '35636', '35641',
	    '35646', '35650', '35651', '35654', '35656', '35661', '35663',
	    '35665', '35666', '35671', '35694', '35695', '35301', '35001', 
		'35002', '35005', '35501', '35508', '35509', '35515', '35642', 
 	    '35645', '35691', '35693', '37140', '37145', '37160', '37180', 
        '37181', '75885', '75887', '43204', '43205') OR
        '35355' <= hcpcs_cd <= '35381';
run;
proc sort data=include_hcpcs out=include_hcpcs2 nodupkey; by &bene_id. &clm_id.; run;

%RULEOUT(&claims_source., &bene_id., &clm_from_dt., &begin., &end., &diag_pfx.1-&diag_pfx.&diag_cd_max., &diag_cd_max., , file);

proc sort data=Clmrecs; by &bene_id. &clm_id.; run;

data Clmrecs2;
	merge Clmrecs(in=a) include_hcpcs2(in=b keep=&bene_id. &clm_id. &hcpcs_cd.);
	by &bene_id. &clm_id.;
	if a; 
	Ind_Pri="P";
	if file="M" then LOS=&clm_thru_dt.-&clm_from_dt.+1;
run;

proc sort data=Clmrecs2; by &bene_id.; run;

%COMORB(Clmrecs2, &bene_id., Ind_Pri, LOS, &diag_pfx.1-&diag_pfx.&diag_cd_max., &diag_cd_max., &proc_pfx.1-&proc_pfx.&proc_cd_max., &proc_cd_max., &hcpcs_cd., file)

proc sort data=COMORB; by &bene_id.; run;


data &charl_pop_out.;
	merge &source. COMORB(in=b keep=&bene_id. PCHRLSON);
	by &bene_id.;
	if PCHRLSON>0 then chrlson_b=1;
		else if PCHRLSON=0 or not b then chrlson_b=0;
	drop PCHRLSON;
run;

%mend;


/*** Calculate claims-based frailty index (CFI) ***/
%macro ccs(claims_source=, hcpcs_source=, charl_source=, CFI_person_out=, CFI_zip_out=, CFI_county_out=, start=, end=);
data ccs_claims;
	set &claims_source.;
	if &start.<=&clm_from_dt.<=&end.;
run;

/*** Indicators for the chronic conditions included in CFI ***/
data ccs_claims2;
	set ccs_claims;
	array dx{*} &diag_pfx.:;
	do i=1 to dim(dx);
		if put(dx{i}, $fmt_.)="CHF" then CHF=1;
			else if put(dx{i}, $fmt_.)="Cognitive impairment" then Cognitive_impairment=1;
			else if put(dx{i}, $fmt_.)="Stroke" then Stroke=1;
			else if put(dx{i}, $fmt_.)="Arthritis" then Arthritis=1;
			else if put(dx{i}, $fmt_.)="Depression" then Depression=1;
			else if put(dx{i}, $fmt_.)="Paranoid" then Paranoid=1;
			else if put(dx{i}, $fmt_.)="Impaired mobility" then Impaired_mobility_icd=1;
			else if put(dx{i}, $fmt_.)="Falls" then Falls=1;
			else if put(dx{i}, $fmt_.)="Mycoses" then Mycoses=1;
			else if put(dx{i}, $fmt_.)="Parkinson`s disease" then Parkinson=1;
			else if put(dx{i}, $fmt_.)="Pneumonia" then Pneumonia=1;
			else if put(dx{i}, $fmt_.)="Skin and subcutaneous tissue infections" then Skin_infections=1;
			else if put(dx{i}, $fmt_.)="Chronic ulcer of skin" then Ulcer=1;
			else if put(dx{i}, $fmt_.)="Gout and other crystal arthropathies" then Gout=1;
			else if put(dx{i}, $fmt_.)="Urinary tract infections" then UTI=1;
			else if put(dx{i}, $fmt_.)="Musculoskeletal problem" then Musculo_prob=1;
	end;
	keep &bene_id. CHF Cognitive_impairment Stroke Arthritis Depression Paranoid Impaired_mobility_icd Falls Mycoses Parkinson Pneumonia Skin_infections Ulcer Gout UTI Musculo_prob;
run;

/*** Aggregate by patient ID to create binary variables at participant level ***/
proc sort data=ccs_claims2; by &bene_id.; run;

proc summary data=ccs_claims2; 
	var CHF Cognitive_impairment Stroke Arthritis Depression Paranoid Impaired_mobility_icd Falls Mycoses Parkinson Pneumonia Skin_infections Ulcer Gout UTI Musculo_prob; 
	by &bene_id.; 
	output out=icd_pt_condition(drop=_freq_ _type_)
		max(CHF Cognitive_impairment Stroke Arthritis Depression Paranoid Impaired_mobility_icd Falls Mycoses Parkinson Pneumonia Skin_infections Ulcer Gout UTI Musculo_prob) = 
			CHF Cognitive_impairment Stroke Arthritis Depression Paranoid Impaired_mobility_icd Falls Mycoses Parkinson Pneumonia Skin_infections Ulcer Gout UTI Musculo_prob; 
run;

/*** Define impaired mobility using HCPCS codes ***/
data hcpcs_Impaired_mobility;
	set &hcpcs_source.;
	if &start.<=&clm_from_dt.<=&end.;
	length hcpcs_1 $1. hcpcs_2_5 4 impaired_mobility_hcpcs 3; 
	impaired_mobility_hcpcs=0; 
	hcpcs_1=substr(&hcpcs_cd.,1,1); 
	if compress(substr(&hcpcs_cd.,2,4), "0123456789")="" then hcpcs_2_5=substr(&hcpcs_cd.,2,4)*1;
	if hcpcs_1="E" and (1050<=hcpcs_2_5<=1093 or 1100<=hcpcs_2_5<=1110 or 1130<=hcpcs_2_5<=1161 or 1170<=hcpcs_2_5<=1200 or 
		1220<=hcpcs_2_5<=1239 or 1240<=hcpcs_2_5<=1270 or 1280<=hcpcs_2_5<=1298) then impaired_mobility_hcpcs=1;
	keep &bene_id. &clm_id. &clm_from_dt. &clm_thru_dt. &hcpcs_cd. hcpcs_1 hcpcs_2_5 Impaired_mobility_hcpcs;
run;

/*** Aggregate by patient ID to create binary variables at participant level ***/
proc sort data=hcpcs_Impaired_mobility; by &bene_id.; run;

proc summary data=hcpcs_Impaired_mobility; 
	var Impaired_mobility_hcpcs; 
	by &bene_id.; 
	output out=hcpcs_pt_condition(drop=_freq_ _type_) max(Impaired_mobility_hcpcs) = Impaired_mobility_hcpcs; 
run;

/***  Merge two condition datasets at the participant level ***/
proc sort data=icd_pt_condition; by &bene_id.; run;
proc sort data=hcpcs_pt_condition; by &bene_id.; run;

Data pt_condition; 
	merge icd_pt_condition hcpcs_pt_condition; 
	by &bene_id.; 
run; 

Data pt_condition2; 
	set pt_condition; 
	length impaired_mobility 3; 
	impaired_mobility=0;
	array ccs(*) CHF -- Musculo_prob; 
	do i=1 to dim(ccs); 
		if ccs(i)=. then ccs(i)=0; 
	end; 
	if impaired_mobility_hcpcs=. then impaired_mobility_hcpcs=0;
	impaired_mobility=max(of Impaired_mobility_icd impaired_mobility_hcpcs);
	drop i; 
run;



proc sort data=pt_condition2; by &bene_id.; run;

Data all; 
	merge &charl_source. pt_condition2; 
	by &bene_id.; 
run;


/*** CFI ***/
Data &CFI_person_out.; 
	set all;
	p_frailty=exp(-9.00+1.24*impaired_mobility+0.50*CHF+0.54*depression+0.43*arthritis-0.49*white+0.33*cognitive_impairment+0.31*chrlson_b+
		0.28*stroke+0.50*Parkinson+0.24*paranoid+0.23*Ulcer-0.19*male+0.09*age+0.09*with_ip_6mopre+0.14*Mycoses+0.21*Pneumonia+0.18*Skin_infections+
		0.08*Gout+0.05*UTI+0.08*falls+0.05*musculo_prob)/
		(1+exp(-9.00+1.24*impaired_mobility+0.50*CHF+0.54*depression+0.43*arthritis-0.49*white+0.33*cognitive_impairment+0.31*chrlson_b+
		0.28*stroke+0.50*Parkinson+0.24*paranoid+0.23*Ulcer-0.19*male+0.09*age+0.09*with_ip_6mopre+0.14*Mycoses+0.21*Pneumonia+0.18*Skin_infections+
		0.08*Gout+0.05*UTI+0.08*falls+0.05*musculo_prob));

	if p_frailty>=0.2 then cfrail=1; else if .<p_frailty<0.2 then cfrail=0;
run;

/********************************* By county *********************************/
/*** Minimum, maximum and deciles of CFI by county ***/
proc means data=&CFI_person_out. min p10 p20 p30 p40 p50 p60 p70 p80 p90 max;
	var p_frailty;
	class COUNTY_CD;
	output out=county_decile min=county_CFI_min p10=county_CFI_p10 p20=county_CFI_p20 p30=county_CFI_p30 p40=county_CFI_p40 p50=county_CFI_p50
		p60=county_CFI_p60 p70=county_CFI_p70 p80=county_CFI_p80 p90=county_CFI_p90 max=county_CFI_max;
run;

/*** Percent of participants with CFI > 0.2 by country ***/
proc means data=&CFI_person_out. mean;
	var cfrail;
	class COUNTY_CD;
	output out=county_pct mean=county_CFI_percent_frail;
run;

proc sort data=&CFI_person_out.; by COUNTY_CD; run;
proc sort data=county_decile; by COUNTY_CD; run;
proc sort data=county_pct; by COUNTY_CD; run;

/*** Cell counts per county ***/
data county_n(keep=COUNTY_CD total_n frail_n nonfrail_n);
	set &CFI_person_out.;
	by COUNTY_CD;
	if first.COUNTY_CD then do; total_n=0; frail_n=0; nonfrail_n=0; end;
	total_n+1;
	if cfrail=0 then nonfrail_n+1;
		else if cfrail=1 then frail_n+1;
	if last.COUNTY_CD;
run;

data county;
	merge county_decile(drop=_type_ _freq_ where=(COUNTY_CD^="")) county_pct(drop=_type_ _freq_ where=(COUNTY_CD^="")) county_n;
	by COUNTY_CD;

	county_CFI_percent_frail=county_CFI_percent_frail*100;

	if 0<total_n<11 or 0<frail_n<11 or 0<nonfrail_n<11 then do;  
		county_CFI_min=.;
		county_CFI_p10=.;
		county_CFI_p20=.;
		county_CFI_p30=.;
		county_CFI_p40=.;
		county_CFI_p50=.;
		county_CFI_p60=.;
		county_CFI_p70=.;
		county_CFI_p80=.;
		county_CFI_p90=.;
		county_CFI_max=.;
		county_CFI_percent_frail=.;
	end;
	format county_CFI_min county_CFI_max county_CFI_p10 county_CFI_p20 county_CFI_p30 county_CFI_p40 county_CFI_p50 county_CFI_p60 county_CFI_p70 county_CFI_p80 county_CFI_p90 county_CFI_percent_frail NA.;
run;


/********************************* By zip code *********************************/
/*** Minimum, maximum and deciles of CFI by zip code ***/
proc means data=&CFI_person_out. min p10 p20 p30 p40 p50 p60 p70 p80 p90 max;
	var p_frailty;
	class ZIP_CD;
	output out=ZIP_decile min=ZIP_CFI_min p10=ZIP_CFI_p10 p20=ZIP_CFI_p20 p30=ZIP_CFI_p30 p40=ZIP_CFI_p40 p50=ZIP_CFI_p50
		p60=ZIP_CFI_p60 p70=ZIP_CFI_p70 p80=ZIP_CFI_p80 p90=ZIP_CFI_p90 max=ZIP_CFI_max;
run;

/*** Percent of participants with CFI > 0.2 by zip code ***/
proc means data=&CFI_person_out. mean;
	var cfrail;
	class ZIP_CD;
	output out=ZIP_pct mean=ZIP_CFI_percent_frail;
run;

proc sort data=&CFI_person_out.; by ZIP_CD; run;
proc sort data=ZIP_decile; by ZIP_CD; run;
proc sort data=ZIP_pct; by ZIP_CD; run;

/*** Cell counts per zip code ***/
data ZIP_n(keep=ZIP_CD total_n frail_n nonfrail_n);
	set &CFI_person_out.;
	by ZIP_CD;
	if first.ZIP_CD then do; total_n=0; frail_n=0; nonfrail_n=0; end;
	total_n+1;
	if cfrail=0 then nonfrail_n+1;
		else if cfrail=1 then frail_n+1;
	if last.ZIP_CD;
run;

data ZIP;
	merge ZIP_decile(drop=_type_ _freq_ where=(ZIP_CD^="")) ZIP_pct(drop=_type_ _freq_ where=(ZIP_CD^="")) ZIP_n;
	by ZIP_CD;

	ZIP_CFI_percent_frail=ZIP_CFI_percent_frail*100;

	if 0<total_n<11 or 0<frail_n<11 or 0<nonfrail_n<11 then do;  
		ZIP_CFI_min=.;
		ZIP_CFI_p10=.;
		ZIP_CFI_p20=.;
		ZIP_CFI_p30=.;
		ZIP_CFI_p40=.;
		ZIP_CFI_p50=.;
		ZIP_CFI_p60=.;
		ZIP_CFI_p70=.;
		ZIP_CFI_p80=.;
		ZIP_CFI_p90=.;
		ZIP_CFI_max=.;
		ZIP_CFI_percent_frail=.;
	end;
	format county_CFI_min county_CFI_max county_CFI_p10 county_CFI_p20 county_CFI_p30 county_CFI_p40 county_CFI_p50 county_CFI_p60 county_CFI_p70 county_CFI_p80 county_CFI_p90 ZIP_CFI_percent_frail NA.;
run;

data &permlib..&CFI_county_out.; set county; run;
data &permlib..&CFI_zip_out.; set ZIP; run;

%mend;


%mbsf(mbsource=MBSF.MBSF_ABCD_2015, ipsource=RIF2015.inpatient_claims_04 RIF2015.inpatient_claims_05 RIF2015.inpatient_claims_06 RIF2015.inpatient_claims_07 RIF2015.inpatient_claims_08 RIF2015.inpatient_claims_09, start='01apr2015'd, end='30sep2015'd, ip_pop_out=ip_15); *** Edit mbsource and ipsource accordingly ***;

%claims(carbase=RIF2015.bcarrier_claims_04 RIF2015.bcarrier_claims_05 RIF2015.bcarrier_claims_06 RIF2015.bcarrier_claims_07 RIF2015.bcarrier_claims_08 RIF2015.bcarrier_claims_09, 
carrev=RIF2015.bcarrier_line_04 RIF2015.bcarrier_line_05 RIF2015.bcarrier_line_06 RIF2015.bcarrier_line_07 RIF2015.bcarrier_line_08 RIF2015.bcarrier_line_09, 
inbase=RIF2015.inpatient_claims_04 RIF2015.inpatient_claims_05 RIF2015.inpatient_claims_06 RIF2015.inpatient_claims_07 RIF2015.inpatient_claims_08 RIF2015.inpatient_claims_09, 
inrev=RIF2015.inpatient_revenue_04 RIF2015.inpatient_revenue_05 RIF2015.inpatient_revenue_06 RIF2015.inpatient_revenue_07 RIF2015.inpatient_revenue_08 RIF2015.inpatient_revenue_09, 
opbase=RIF2015.outpatient_claims_04 RIF2015.outpatient_claims_05 RIF2015.outpatient_claims_06 RIF2015.outpatient_claims_07 RIF2015.outpatient_claims_08 RIF2015.outpatient_claims_09, 
oprev=RIF2015.outpatient_revenue_04 RIF2015.outpatient_revenue_05 RIF2015.outpatient_revenue_06 RIF2015.outpatient_revenue_07 RIF2015.outpatient_revenue_08 RIF2015.outpatient_revenue_09, 
source=ip_15, claims_pop_out=claims_15, HCPCS_pop_out=HCPCS_15);

%charl(source=ip_15, claims_source=claims_15, hcpcs_source=HCPCS_15, charl_pop_out=charl_15, begin='1apr2015'd, end='30sep2015'd);

%ccs(claims_source=claims_15, hcpcs_source=hcpcs_15, charl_source=charl_15, CFI_person_out=CFI_person_15, CFI_zip_out=CFI_zip_15, CFI_county_out=CFI_county_15, start='1apr2015'd, end='30sep2015'd);


proc print data=county_n noobs; var COUNTY_CD total_n frail_n nonfrail_n; where 0<total_n<11 or 0<frail_n<11 or 0<frail_n<11; run;
proc print data=ZIP_n noobs; var ZIP_CD total_n frail_n nonfrail_n; where 0<total_n<11 or 0<frail_n<11 or 0<frail_n<11; run;





