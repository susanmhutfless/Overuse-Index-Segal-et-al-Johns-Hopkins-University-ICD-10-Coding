/********************************************************************
* Job Name: read_me_overuse_job_sequence.txt
* Job Desc: describe the jobs and sequence required to run jobs
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************
Order of which jobs should be run.  If same number is listed twice that
means that order does not matter for those 2+ jobs

Seq   Job Name
  0   read_me_overuse_job_sequence.txt
  0   chronic conditions.sas
  0   elig_inp
  0   elig_op
  0   pop_inp
  0   pop_op
  0   pop_crosstabs
  1   jhu_build_Claim_IPOP_ds_project_overuse_num01 -
      jhu_build_Claim_IPOP_ds_project_overuse_num18

Seq   Job Name (followed by description)
  0   read_me_overuse_job_sequence.txt
      - this job/file - with relevant facts
  
  0   chronic conditions
	Code to apply medicare chronic conditions

  0   elig_inp
	Code to read in inpatient claims/lines from Medicare monthly

  0   elig_op
	Code to read in outpatient claims/lines from Medicare monthly
	
  0   pop_inp
	Code to read in inpatient claims/lines from Medicare monthly

  0   pop_op
	Code to read in outpatient claims/lines from Medicare monthly

  0   pop_crosstabs
	Frequency tables of eligible, popped, eligible combined with popped
		and hosp level characteristics; 
		creation of analysis table by pop;
		regression by pop
  1   jhu_build_Claim_IPOP_ds_project_overuse_num01 -
      jhu_build_Claim_IPOP_ds_project_overuse_num18
	1 program per pop measure