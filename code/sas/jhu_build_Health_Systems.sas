/********************************************************************
* Job Name: jhu_build_Health_Systems.sas
* Job Desc: Create linkage variables for health systems 
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************/

/**Sources for compendium files:
https://www.ahrq.gov/chsp/data-resources/compendium.html
https://www.ahrq.gov/chsp/data-resources/compendium-2016.html includes hospital & group practice
https://www.ahrq.gov/chsp/data-resources/compendium-2018.html includes hospitals only
**/

%global lwork ltemp permlib;
%let  lwork              = work              	;
%let  ltemp              = temp              	;
%let  permlib            = shu172sl          	;  /** permanent library location**/

%global bene_id clm_from_dt	ccn_hosp;
%let bene_id 	 	= bene_id;
%let clm_from_dt 	= clm_from_dt;
%let ccn_hosp		= prvdr_num;

data ahrq_ccn2016 (KEEP = compendium_hospital_id year ccn2016 hospital_name2016 health_sys_name2016 health_sys_id2016); 
set &permlib..ahrqcomp2016;
ccn2016=put(ccn, $6.);
hospital_name2016=hospital_name;
health_sys_name2016=health_sys_name;
health_sys_id2016=health_sys_id;
if ccn2016=' ' then delete;
year=2016;
run;
proc contents data=ahrq_CCN2016; RUN;

data ahrq_ccn2018 (KEEP = compendium_hospital_id year ccn2018 hospital_name2018 health_sys_name2018 health_sys_id2018); 
set &permlib..ahrqcomp2018;
ccn2018=put(ccn, $6.);
hospital_name2018=hospital_name;
health_sys_name2018=health_sys_name;
health_sys_id2018=health_sys_id;
if ccn2018=' ' then delete;
year=2018;
run;
proc contents data=ahrq_CCN2018; RUN;

*merge all AHRQ compendium hospital years that are linked by compendium hospital id together;

proc sort data=ahrq_ccn2016; by compendium_hospital_id year;
proc sort data=ahrq_ccn2018; by compendium_hospital_id year;
run;

data ahrq_ccn;
merge ahrq_ccn2016 ahrq_ccn2018; 
by compendium_hospital_id;
*only keep those with non-missing health system id;
if health_sys_id2016 =' ' and health_sys_id2018 = ' ' then delete;
run;

*save permanent file;
data &permlib..ahrq_ccn; set ahrq_ccn;
run;

*identify AHRQ group practices (2016 only) for linkage to carrier by TIN/tax_num;
*health system id is the identifier that links group practices and hospitals;
data ahrq_group2016 
(KEEP = year health_sys_id2016 health_sys_name2016 group_practice_name2016 pecos_pac_ids); 
set &permlib..ahrqgroup2016;
health_sys_name2016=health_sys_name;
group_practice_name2016=tin_name;
health_sys_id2016=health_sys_id;
if health_sys_id2016=' ' then delete;
year=2016;
run;
proc contents data=ahrq_group2016; RUN;
*should be able to link pecos_pac_ids to tax_num in carrier file since the health system
	is based on the TIN.  However I don't get any that link
there are also cells with more than 1 value in them--the group practice file
	is not analysis ready--we woudl need to go through line by line and fix AHRQ's file
	in order to use---see Johns Hopkins University--all 3 tins are in 1 cell;
		*I also can't find the ids assigned to HOpkins anywhere....;
*https://www.resdac.org/cms-data/variables/line-provider-tax-number;

*identify count of unique patients in CCN hospitals for each quarter to use as denominator;
*you need to use 2 macros
	--one to identy patients (create_year_month), 
		another to loop through years (scan_year_month);
%macro create_year_month(
				  source         = ,
                  year           = ,
                  month          = ,
				  ccn			 = ,
				  rif   		 =  );

proc sql;
	create table &source._bene_&year._&month._1 (compress=yes) as
select a.&bene_id, a.&ccn_hosp, a.&clm_from_dt, b.*
from 
	&rif.&year..&source._&month a,
	ahrq_ccn b
where 
	a.&ccn_hosp = b.&ccn
;
quit;
data &source._bene_&year._&month; set &source._bene_&year._&month._1;
month=month(&clm_from_dt);
year=year(&clm_from_dt);
qtr=qtr(&clm_from_dt);
patient=1;
if compendium_hospital_id =' ' then delete;
if health_sys_id2016 	  =' ' then delete;
run;
/*each person (bene_id) can contribute only once per period per hospital*/
/*another option is to only allow them to contribute once per health system: health_sys_id2016*/
proc sort data=&source._bene_&year._&month nodupkey; by compendium_hospital_id year qtr &bene_id ; run;
%mend;
		/*** macro that loops through years and months of interest  ***/
		%macro scan_year_month(y_list     =,
		                      m_list     =);
		     %let year_idx=1;
		     %let year_to_do= %scan(&y_list        ,  &year_idx);
		     %do %while (&year_to_do   ne);

		         %let mo_idx=1;
		         %let mo_to_do=%scan( &m_list  , &mo_idx);
		             %do %while ( &mo_to_do   ne);

%create_year_month(source         = inpatient_claims,
           year           = &year_to_do,
           month          = &mo_to_do,
		   ccn			  = ccn2016	,
		   rif			  =	rif			); *using ccn2016 for all years;

                 %let mo_idx   = %eval( &mo_idx + 1);
                 %let mo_to_do = %scan( &m_list , &mo_idx );
             %end;
         %let year_idx   = %eval( &year_idx + 1 );
         %let year_to_do = %scan( &y_list, &year_idx );
     %end;
%mend;
%scan_year_month(y_list= 2013 2014 2015 2016 2017 2018  , m_list=  01 02 03 04 05 06 07 08 09 10 11 12);

/*2019 does not have all months and need to use rifq*/
%macro scan_year_month(y_list     =,
                      m_list     =);
     %let year_idx=1;
     %let year_to_do= %scan(&y_list        ,  &year_idx);
     %do %while (&year_to_do   ne);

         %let mo_idx=1;
         %let mo_to_do=%scan( &m_list  , &mo_idx);
             %do %while ( &mo_to_do   ne);

%create_year_month(source         = inpatient_claims,
           year           = &year_to_do,
           month          = &mo_to_do,
		   ccn			  = ccn2016	,
		   rif			  =	rifq			); *using ccn2016 for all years;

                 %let mo_idx   = %eval( &mo_idx + 1);
                 %let mo_to_do = %scan( &m_list , &mo_idx );
             %end;
         %let year_idx   = %eval( &year_idx + 1 );
         %let year_to_do = %scan( &y_list, &year_idx );
     %end;
%mend;
%scan_year_month(y_list= 2019 , m_list=  01 02 03 04 05 06 07 08 09 			);

data inpatient_claims_temp; set inpatient_claims_bene: ;run;
data &permlib..ccn_inpatient_claims_DELETE; set inpatient_claims_temp; run;

*do summary after group all months together in 1 file;
proc summary data=&permlib..ccn_inpatient_claims_DELETE;
class compendium_hospital_id year qtr;
var patient;
output out=inpatient_count_2013_19 (drop = _type_ _freq_) sum=/autoname; run;

data &permlib..ccn_inp_count_2013_19; set inpatient_count_2013_19;
if compendium_hospital_id = ' ' then delete;
if qtr=. then delete;
if year=. then delete;
if year<2013 then delete;
if year>2019 then delete;
run;

*delete working files so space to run outpatient;
proc datasets lib=work nolist kill; quit; run;

/*now do for outpatient, hospital-based claims*/
*2013-2018;
%macro scan_year_month(y_list     =,
		                      m_list     =);
		     %let year_idx=1;
		     %let year_to_do= %scan(&y_list        ,  &year_idx);
		     %do %while (&year_to_do   ne);

		         %let mo_idx=1;
		         %let mo_to_do=%scan( &m_list  , &mo_idx);
		             %do %while ( &mo_to_do   ne);

%create_year_month(source         = outpatient_claims,
           year           = &year_to_do,
           month          = &mo_to_do,
		   ccn			  = ccn2016	,
		   rif			  =	rif			); *using ccn2016 for all years;

                 %let mo_idx   = %eval( &mo_idx + 1);
                 %let mo_to_do = %scan( &m_list , &mo_idx );
             %end;
         %let year_idx   = %eval( &year_idx + 1 );
         %let year_to_do = %scan( &y_list, &year_idx );
     %end;
%mend;
%scan_year_month(y_list= 2013 2014 2015 2016 2017 2018  , m_list=  01 02 03 04 05 06 07 08 09 10 11 12);

/*2019 does not have all months and need to use rifq*/
%macro scan_year_month(y_list     =,
                      m_list     =);
     %let year_idx=1;
     %let year_to_do= %scan(&y_list        ,  &year_idx);
     %do %while (&year_to_do   ne);

         %let mo_idx=1;
         %let mo_to_do=%scan( &m_list  , &mo_idx);
             %do %while ( &mo_to_do   ne);

%create_year_month(source         = outpatient_claims,
           year           = &year_to_do,
           month          = &mo_to_do,
		   ccn			  = ccn2016	,
		   rif			  =	rifq			); *using ccn2016 for all years;

                 %let mo_idx   = %eval( &mo_idx + 1);
                 %let mo_to_do = %scan( &m_list , &mo_idx );
             %end;
         %let year_idx   = %eval( &year_idx + 1 );
         %let year_to_do = %scan( &y_list, &year_idx );
     %end;
%mend;
%scan_year_month(y_list= 2019 , m_list=  01 02 03 04 05 06 07 08 09 			);

data outpatient_claims_temp; set outpatient_claims_bene: ;run;
data &permlib..ccn_outpatient_claims_DELETE; set outpatient_claims_temp; run;

*make room in working memory;
proc datasets lib=work nolist kill; quit; run;

*do summary after group all months together in 1 file;
proc summary data=&permlib..ccn_outpatient_claims_DELETE;
class compendium_hospital_id year qtr;
var patient;
output out=outpatient_count_2013_19 (drop = _type_ _freq_) sum=/autoname; run;

data &permlib..ccn_outp_count_2013_19; set outpatient_count_2013_19;
if compendium_hospital_id = ' ' then delete;
if qtr=. then delete;
if year=. then delete;
if year<2013 then delete;
if year>2019 then delete;
run;

*make a count file for unique inpatient or outpatient visits;
Proc sort data=&permlib..ccn_outpatient_claims_DELETE; by compendium_hospital_id year qtr &bene_id;
Proc sort data=&permlib..ccn_inpatient_claims_DELETE; by compendium_hospital_id year qtr &bene_id;
run;

data inp_outp_temp;
merge &permlib..ccn_outpatient_claims_DELETE &permlib..ccn_inpatient_claims_DELETE;
by compendium_hospital_id year qtr &bene_id;
run;

proc summary data=inp_outp_temp;
class compendium_hospital_id year qtr;
var patient;
output out=inp_outp_count_2013_19 (drop = _type_ _freq_) sum=/autoname; run;

data &permlib..ccn_inp_outp_count_2013_19; set inp_outp_count_2013_19;
if compendium_hospital_id = ' ' then delete;
if qtr=. then delete;
if year=. then delete;
if year<2013 then delete;
if year>2019 then delete;
run;

*add in descriptors;
*--this is set up to use the compendium hospital id for 2016 only;
proc sort data=&permlib..ccn_inp_outp_count_2013_19; by compendium_hospital_id;
proc sort data=&permlib..ahrq_ccn; by compendium_hospital_id;

data &permlib..ccn_inp_outp_count_2013_19;
merge &permlib..ccn_inp_outp_count_2013_19 &permlib..ahrq_ccn; 
by compendium_hospital_id;
if health_sys_id2016 = ' ' then delete;
if ccn2016=. then delete;
if patient_sum<11 then patient_sum=.;
run;


/*--this is set up to use the compendium hospital id for 2016 and 2018--NOT 2016 only;
proc sort data=&permlib..ccn_inp_outp_count_2013_19; by compendium_hospital_id year;
proc sort data=ahrq_ccn; by compendium_hospital_id year;

data &permlib..ccn_inp_outp_count_2013_19;
merge &permlib..ccn_inp_outp_count_2013_19 ahrq_ccn; 
by compendium_hospital_id year;
run;*/

proc datasets lib=work nolist kill; quit; run;
