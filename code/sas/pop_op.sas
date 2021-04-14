
/********************************************************************
* Job Name: pop_op.sas
* Job Desc: Eligible outpatient
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************/


/*** this section is related to OP Popped- OUTpatient claims ***/
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_01, rev_cohort=rif2016.OUTpatient_revenue_01, include_cohort=pop_&popN._out_2016_1, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_02, rev_cohort=rif2016.OUTpatient_revenue_02, include_cohort=pop_&popN._out_2016_2, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_03, rev_cohort=rif2016.OUTpatient_revenue_03, include_cohort=pop_&popN._out_2016_3, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_04, rev_cohort=rif2016.OUTpatient_revenue_04, include_cohort=pop_&popN._out_2016_4, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_05, rev_cohort=rif2016.OUTpatient_revenue_05, include_cohort=pop_&popN._out_2016_5, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_06, rev_cohort=rif2016.OUTpatient_revenue_06, include_cohort=pop_&popN._out_2016_6, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_07, rev_cohort=rif2016.OUTpatient_revenue_07, include_cohort=pop_&popN._out_2016_7, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_08, rev_cohort=rif2016.OUTpatient_revenue_08, include_cohort=pop_&popN._out_2016_8, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_09, rev_cohort=rif2016.OUTpatient_revenue_09, include_cohort=pop_&popN._out_2016_9, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_10, rev_cohort=rif2016.OUTpatient_revenue_10, include_cohort=pop_&popN._out_2016_10, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_11, rev_cohort=rif2016.OUTpatient_revenue_11, include_cohort=pop_&popN._out_2016_11, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2016.OUTpatient_claims_12, rev_cohort=rif2016.OUTpatient_revenue_12, include_cohort=pop_&popN._out_2016_12, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_01, rev_cohort=rif2017.OUTpatient_revenue_01, include_cohort=pop_&popN._out_2017_1, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_02, rev_cohort=rif2017.OUTpatient_revenue_02, include_cohort=pop_&popN._out_2017_2, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_03, rev_cohort=rif2017.OUTpatient_revenue_03, include_cohort=pop_&popN._out_2017_3, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_04, rev_cohort=rif2017.OUTpatient_revenue_04, include_cohort=pop_&popN._out_2017_4, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_05, rev_cohort=rif2017.OUTpatient_revenue_05, include_cohort=pop_&popN._out_2017_5, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_06, rev_cohort=rif2017.OUTpatient_revenue_06, include_cohort=pop_&popN._out_2017_6, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_07, rev_cohort=rif2017.OUTpatient_revenue_07, include_cohort=pop_&popN._out_2017_7, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_08, rev_cohort=rif2017.OUTpatient_revenue_08, include_cohort=pop_&popN._out_2017_8, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_09, rev_cohort=rif2017.OUTpatient_revenue_09, include_cohort=pop_&popN._out_2017_9, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_10, rev_cohort=rif2017.OUTpatient_revenue_10, include_cohort=pop_&popN._out_2017_10, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_11, rev_cohort=rif2017.OUTpatient_revenue_11, include_cohort=pop_&popN._out_2017_11, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rif2017.OUTpatient_claims_12, rev_cohort=rif2017.OUTpatient_revenue_12, include_cohort=pop_&popN._out_2017_12, ccn=ccn2016);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_01, rev_cohort=rifq2018.OUTpatient_revenue_01, include_cohort=pop_&popN._out_2018_1, ccn=ccn2018);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_02, rev_cohort=rifq2018.OUTpatient_revenue_02, include_cohort=pop_&popN._out_2018_2, ccn=ccn2018);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_03, rev_cohort=rifq2018.OUTpatient_revenue_03, include_cohort=pop_&popN._out_2018_3, ccn=ccn2018);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_04, rev_cohort=rifq2018.OUTpatient_revenue_04, include_cohort=pop_&popN._out_2018_4, ccn=ccn2018);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_05, rev_cohort=rifq2018.OUTpatient_revenue_05, include_cohort=pop_&popN._out_2018_5, ccn=ccn2018);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_06, rev_cohort=rifq2018.OUTpatient_revenue_06, include_cohort=pop_&popN._out_2018_6, ccn=ccn2018);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_07, rev_cohort=rifq2018.OUTpatient_revenue_07, include_cohort=pop_&popN._out_2018_7, ccn=ccn2018);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_08, rev_cohort=rifq2018.OUTpatient_revenue_08, include_cohort=pop_&popN._out_2018_8, ccn=ccn2018);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_09, rev_cohort=rifq2018.OUTpatient_revenue_09, include_cohort=pop_&popN._out_2018_9, ccn=ccn2018);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_10, rev_cohort=rifq2018.OUTpatient_revenue_10, include_cohort=pop_&popN._out_2018_10, ccn=ccn2018);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_11, rev_cohort=rifq2018.OUTpatient_revenue_11, include_cohort=pop_&popN._out_2018_11, ccn=ccn2018);
%claims_rev(date=&clm_from_dt, source=rifq2018.OUTpatient_claims_12, rev_cohort=rifq2018.OUTpatient_revenue_12, include_cohort=pop_&popN._out_2018_12, ccn=ccn2018);
