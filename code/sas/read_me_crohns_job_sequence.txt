/********************************************************************
* Job Name: read_me_crohns_job_sequence.txt
* Job Desc: describe the jobs and sequence required to run jobs
* Copyright: Johns Hopkins University - HutflessLab 2019
********************************************************************
Seq   Job Name
  0   read_me_crohns_job_sequence.txt
  1   jhu_build_denom_ds_project_various.sas
  2   jhu_build_Claim_IP_ds_project_crohns.sas
  2   jhu_build_Claim_OP_ds_project_crohns.sas
  3   crohns_cohort_prep_logic_for_output.sas
      source_code_for_output_prep_using_table1_logic.sas


Seq   Job Name (followed by description)
  0   read_me_crohns_job_sequence.txt
      - this job/file - with relevant facts
  
  1   jhu_build_denom_ds_project_various.sas
      - takes the denom for "many" patients and preps data
        we can use for 'projects' - today its crohns
        however eventually this job will be located into
        a JHU repo - dedicated to "broad data prep"
        - this job should typically RUN before others
          mentioned below
        - this job can take time to run
        - this job should not be run over and over
        - updates to this job today 2019/11/21 should/could be 
          specific to crohns - later this may shift
        - output from this is used by:
          crohns_cohort_prep_logic_for_output.sas
  
  2   jhu_build_Claim_IP_ds_project_crohns.sas
      - Takes Inpatient (IP) claims for YYYY and preps them
        with crohns logic and intention for use in downstream jobs
        - this job should typically RUN before 
          crohns_cohort_prep_logic_for_output.sas
        - output from this is used by:
          crohns_cohort_prep_logic_for_output.sas
        - this job uses VIEWS - be aware that views require
          diligent administration of folders, naming, intent
  
  2   jhu_build_Claim_OP_ds_project_crohns.sas
      - Takes Outpatient (OP) claims for STATE / YYYY and preps them
        with crohns logic and intention for use in downstream jobs
        - this job should typically RUN before 
          crohns_cohort_prep_logic_for_output.sas
        - output from this is used by:
          crohns_cohort_prep_logic_for_output.sas
        - this job uses VIEWS - be aware that views require
          diligent administration of folders, naming, intent
  
  
  3   crohns_cohort_prep_logic_for_output.sas
      - Takes the output of jobs:
        jhu_build_denom_ds_project_various.sas
        jhu_build_Claim_IP_ds_project_crohns.sas
        jhu_build_Claim_OP_ds_project_crohns.sas
        this code then makes final table/data preparation with
        crohns logic to produce facts needed for publication
  
  
      source_code_for_output_prep_using_table1_logic.sas
      - This code is meant to hold logic and code which
        for crohns maybe used in parts, sections to refine
        output.  The parts copied from here will go into
        crohns_cohort_prep_logic_for_output.sas
