/********************************************************************
* Job Name: read_me_overuse_job_sequence.txt
* Job Desc: describe the jobs and sequence required to run jobs
* Copyright: Johns Hopkins University - SegalLab & HutflessLab 2019
********************************************************************
Order which jobs should be run.  If same number is listed twice that
means that order does not matter for those 2+ jobs
Seq   Job Name
  0   read_me_overuse_job_sequence.txt
  1   jhu_build_Claim_IP_ds_project_overuse.sas
  1   jhu_build_Claim_OP_ds_project_overuse.sas
  1   jhu_build_Claim_CAR_ds_project_overuse.sas
*Pending---will either have 1 file that sets up all measures or 
	1 measure per file OR both
  2   overuse_cohort_prep_logic_for_output.sas
      source_code_for_output_prep_using_table1_logic.sas


Seq   Job Name (followed by description)
  0   read_me_overuse_job_sequence.txt
      - this job/file - with relevant facts
  
  0   jhu_build_denom_ds_project_various.sas
      - Denominator file from another repo is called in.
	The format of this file is....
	List final repo (Hutfless is editing that repo naming now)
  
  1   jhu_build_Claim_IP_ds_project_overuse.sas
      - Takes Inpatient (IP) claims for YYYY and preps them
        with overuse logic and intention for use in downstream jobs
        - this job should typically RUN before 
          overuse_cohort_prep_logic_for_output.sas
        - output from this is used by:
          overuse_cohort_prep_logic_for_output.sas
        - this job uses VIEWS - be aware that views require
          diligent administration of folders, naming, intent
  
  1   jhu_build_Claim_OP_ds_project_overuse.sas
      - Takes Outpatient (OP) claims for STATE / YYYY and preps them
        with overuse logic and intention for use in downstream jobs
        - this job should typically RUN before 
          overuse_cohort_prep_logic_for_output.sas
        - output from this is used by:
          overuse_cohort_prep_logic_for_output.sas
        - this job uses VIEWS - be aware that views require
          diligent administration of folders, naming, intent  

  1   jhu_build_Claim_CAR_ds_project_overuse.sas
      - Takes Carrier (CAR) claims for STATE / YYYY and preps them
        with overuse logic and intention for use in downstream jobs
        - this job should typically RUN before 
          overuse_cohort_prep_logic_for_output.sas
        - output from this is used by:
          overuse_cohort_prep_logic_for_output.sas
        - this job uses VIEWS - be aware that views require
          diligent administration of folders, naming, intent


****very draft below---need to decide on final workflow****  
  
  2   overuse_cohort_prep_logic_for_output.sas
      - Takes the output of jobs:
        jhu_build_denom_ds_project_various.sas
        jhu_build_Claim_IP_ds_project_overuse.sas
        jhu_build_Claim_OP_ds_project_overuse.sas
	jhu_build_Claim_CAR_ds_project_overuse.sas
        this code then makes final table/data preparation with
        overuse logic to produce facts needed for publication
  
  
      source_code_for_output_prep_using_table1_logic.sas
      - This code is meant to hold logic and code which
        for overuse maybe used in parts, sections to refine
        output.  The parts copied from here will go into
        overuse_cohort_prep_logic_for_output.sas
