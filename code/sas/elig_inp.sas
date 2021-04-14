/********************************************************************
* Job Name: elig_inp.sas
* Job Desc: Inpatient eligible
* Copyright: Johns Hopkins University - Hutfless & Segal Labs 2021
********************************************************************/

/*** this section is related to IP - inpatient claims--for eligible cohort***/
%claims_rev(date=&clm_beg_dt_in, source=rif2015.INpatient_claims_07,  
	rev_cohort=rif2015.inpatient_revenue_07, include_cohort=pop_&popN._INinclude_2015_7, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2015.INpatient_claims_08,  
	rev_cohort=rif2015.INpatient_revenue_08, include_cohort=pop_&popN._INinclude_2015_8, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2015.INpatient_claims_09,  
	rev_cohort=rif2015.INpatient_revenue_09, include_cohort=pop_&popN._INinclude_2015_9, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2015.INpatient_claims_10,  
	rev_cohort=rif2015.INpatient_revenue_10, include_cohort=pop_&popN._INinclude_2015_10, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2015.INpatient_claims_11,  
	rev_cohort=rif2015.INpatient_revenue_11, include_cohort=pop_&popN._INinclude_2015_11, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2015.INpatient_claims_12,  
	rev_cohort=rif2015.INpatient_revenue_12, include_cohort=pop_&popN._INinclude_2015_12, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_01,  
	rev_cohort=rif2016.INpatient_revenue_01, include_cohort=pop_&popN._INinclude_2016_1, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_02,  
	rev_cohort=rif2016.INpatient_revenue_02, include_cohort=pop_&popN._INinclude_2016_2, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_03,  
	rev_cohort=rif2016.INpatient_revenue_03, include_cohort=pop_&popN._INinclude_2016_3, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_04,  
	rev_cohort=rif2016.INpatient_revenue_04, include_cohort=pop_&popN._INinclude_2016_4, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_05,  
	rev_cohort=rif2016.INpatient_revenue_05, include_cohort=pop_&popN._INinclude_2016_5, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_06,  
	rev_cohort=rif2016.INpatient_revenue_06, include_cohort=pop_&popN._INinclude_2016_6, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_07,  
	rev_cohort=rif2016.INpatient_revenue_07, include_cohort=pop_&popN._INinclude_2016_7, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_08,  
	rev_cohort=rif2016.INpatient_revenue_08, include_cohort=pop_&popN._INinclude_2016_8, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_09,  
	rev_cohort=rif2016.INpatient_revenue_09, include_cohort=pop_&popN._INinclude_2016_9, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_10,  
	rev_cohort=rif2016.INpatient_revenue_10, include_cohort=pop_&popN._INinclude_2016_10, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_11,  
	rev_cohort=rif2016.INpatient_revenue_11, include_cohort=pop_&popN._INinclude_2016_11, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2016.INpatient_claims_12,  
	rev_cohort=rif2016.INpatient_revenue_12, include_cohort=pop_&popN._INinclude_2016_12, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_01,  
	rev_cohort=rif2017.INpatient_revenue_01, include_cohort=pop_&popN._INinclude_2017_1, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_02,  
	rev_cohort=rif2017.INpatient_revenue_02, include_cohort=pop_&popN._INinclude_2017_2, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_03,  
	rev_cohort=rif2017.INpatient_revenue_03, include_cohort=pop_&popN._INinclude_2017_3, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_04,  
	rev_cohort=rif2017.INpatient_revenue_04, include_cohort=pop_&popN._INinclude_2017_4, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_05,  
	rev_cohort=rif2017.INpatient_revenue_05, include_cohort=pop_&popN._INinclude_2017_5, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_06,  
	rev_cohort=rif2017.INpatient_revenue_06, include_cohort=pop_&popN._INinclude_2017_6, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_07,  
	rev_cohort=rif2017.INpatient_revenue_07, include_cohort=pop_&popN._INinclude_2017_7, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_08,  
	rev_cohort=rif2017.INpatient_revenue_08, include_cohort=pop_&popN._INinclude_2017_8, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_09,  
	rev_cohort=rif2017.INpatient_revenue_09, include_cohort=pop_&popN._INinclude_2017_9, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_10,  
	rev_cohort=rif2017.INpatient_revenue_10, include_cohort=pop_&popN._INinclude_2017_10, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_11,  
	rev_cohort=rif2017.INpatient_revenue_11, include_cohort=pop_&popN._INinclude_2017_11, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rif2017.INpatient_claims_12,  
	rev_cohort=rif2017.INpatient_revenue_12, include_cohort=pop_&popN._INinclude_2017_12, ccn=ccn2016);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_01,  
	rev_cohort=rifq2018.INpatient_revenue_01, include_cohort=pop_&popN._INinclude_2018_1, ccn=ccn2018);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_02,  
	rev_cohort=rifq2018.INpatient_revenue_02, include_cohort=pop_&popN._INinclude_2018_2, ccn=ccn2018);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_03,  
	rev_cohort=rifq2018.INpatient_revenue_03, include_cohort=pop_&popN._INinclude_2018_3, ccn=ccn2018);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_04,  
	rev_cohort=rifq2018.INpatient_revenue_04, include_cohort=pop_&popN._INinclude_2018_4, ccn=ccn2018);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_05,  
	rev_cohort=rifq2018.INpatient_revenue_05, include_cohort=pop_&popN._INinclude_2018_5, ccn=ccn2018);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_06,  
	rev_cohort=rifq2018.INpatient_revenue_06, include_cohort=pop_&popN._INinclude_2018_6, ccn=ccn2018);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_07,  
	rev_cohort=rifq2018.INpatient_revenue_07, include_cohort=pop_&popN._INinclude_2018_7, ccn=ccn2018);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_08,  
	rev_cohort=rifq2018.INpatient_revenue_08, include_cohort=pop_&popN._INinclude_2018_8, ccn=ccn2018);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_09,  
	rev_cohort=rifq2018.INpatient_revenue_09, include_cohort=pop_&popN._INinclude_2018_9, ccn=ccn2018);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_10,  
	rev_cohort=rifq2018.INpatient_revenue_10, include_cohort=pop_&popN._INinclude_2018_10, ccn=ccn2018);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_11,  
	rev_cohort=rifq2018.INpatient_revenue_11, include_cohort=pop_&popN._INinclude_2018_11, ccn=ccn2018);
%claims_rev(date=&clm_beg_dt_in, source=rifq2018.INpatient_claims_12,  
	rev_cohort=rifq2018.INpatient_revenue_12, include_cohort=pop_&popN._INinclude_2018_12, ccn=ccn2018);
