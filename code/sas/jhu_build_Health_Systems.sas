/********************************************************************
* Job Name: jhu_build_Health_Systems.sas
* Job Desc: Create linkage variables for health systems 
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************/

data ahrq_ccn2016 (KEEP = compendium_hospital_id year ccn2016 hospital_name2016 health_sys_name2016); 
set shu172sl.ahrqcomp2016;
ccn2016=put(ccn, $6.);
hospital_name2016=hospital_name;
health_sys_name2016=health_sys_name;
if ccn2016=' ' then delete;
year=2016;
run;
proc contents data=ahrq_CCN2016; RUN;

data ahrq_ccn2018 (KEEP = compendium_hospital_id year ccn2018 hospital_name2018 health_sys_name2018); 
set shu172sl.ahrqcomp2018;
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

