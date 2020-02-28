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

*global statement is important so that var can be used inside macro;
%global bene_id 	clm_from_dt 	ccn_hosp	;
%let  bene_id            = bene_id      		;
%let  clm_from_dt        = clm_from_dt   		;
%let  ccn_hosp			 = prvdr_num			;

*start of code to read in, combine AHRQ compendium years;
data ahrq_ccn2016 (KEEP = compendium_hospital_id year ccn2016 hospital_name2016 health_sys_name2016); 
set &permlib..ahrqcomp2016;
ccn2016=put(ccn, $6.);
hospital_name2016=hospital_name;
health_sys_name2016=health_sys_name;
if ccn2016=' ' then delete;
year=2016;
run;
proc contents data=ahrq_CCN2016; RUN;

data ahrq_ccn2018 (KEEP = compendium_hospital_id year ccn2018 hospital_name2018 health_sys_name2018); 
set &permlib..ahrqcomp2018;
ccn2018=put(ccn, $6.);
hospital_name2018=hospital_name;
health_sys_name2018=health_sys_name;
if ccn2018=' ' then delete;
year=2018;
run;
proc contents data=ahrq_CCN2018; RUN;

*merge all AHRQ compendium hospital years that are linked by ccn together;
proc sort data=ahrq_ccn2016; by compendium_hospital_id year;
proc sort data=ahrq_ccn2018; by compendium_hospital_id year;
run;

data ahrq_ccn;
merge ahrq_ccn2016 ahrq_ccn2018; 
by compendium_hospital_id year;
run;

*create dataset of all individuals seen in a health system to use as the denominator;
	*use ccn2016 for all years;
*this section uses 2 macros-1 to identify who we want, another to spin through
	the months and years of interest;
%macro create_year_month(
				  source         = ,
                  year           = ,
                  month          = ,
				  ccn			 = ,
				  rif   		 =  );


proc sql;
	create table &source._bene_&year._&month._1 (compress=yes) as	/*change bene to file name that you want*/
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
if compendium_hospital_id=' ' then delete;
run;
proc sort data=&source._bene_&year._&month nodupkey; by compendium_hospital_id year qtr &bene_id ; run;

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
           year           = &year_to_do	,
           month          = &mo_to_do	,
		   ccn			  = ccn2016		,
		   rif			  =	rif			); *using ccn2016 for all years;

                 %let mo_idx   = %eval( &mo_idx + 1);
                 %let mo_to_do = %scan( &m_list , &mo_idx );
             %end;
         %let year_idx   = %eval( &year_idx + 1 );
         %let year_to_do = %scan( &y_list, &year_idx );
     %end;
%mend;
%scan_year_month(y_list= 2013 2014 2015 2016 2017 2018  , m_list=  01 02 03 04 05 06 07 08 09 10 11 12);

/*2019 does not have all months and need to use rifq for permanent file location*/
%macro scan_year_month(y_list     =,
                      m_list     =);
     %let year_idx=1;
     %let year_to_do= %scan(&y_list        ,  &year_idx);
     %do %while (&year_to_do   ne);

         %let mo_idx=1;
         %let mo_to_do=%scan( &m_list  , &mo_idx);
             %do %while ( &mo_to_do   ne);

%create_year_month(source = inpatient_claims	,
           year           = &year_to_do			,
           month          = &mo_to_do			,
		   ccn			  = ccn2016				,
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

*do summary after group all months together in 1 file;
proc summary data=inpatient_claims_temp;
class compendium_hospital_id year qtr;
var patient;
output out=inpatient_count_2013_19 (drop = _type_ _freq_) sum=/autoname; run;

data &permlib.ccn_inp_count_2013_19; set inpatient_count_2013_19;
if compendium_hospital_id = ' ' then delete;
if qtr=. then delete;
if year=. then delete;
if year<2013 then delete;
if year>2019 then delete;
run;
