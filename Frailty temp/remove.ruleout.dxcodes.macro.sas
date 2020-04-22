   /****************************************************************
    UPDATED on July 22, 2010 to remove code (below) that made a selection
    on HCPCS.  Now all the claims are looked at for conditions.
    
    if (&FILETYPE='M') or
      ('00100' <= &HCPCS <= '01999' or '10021' <= &HCPCS <= '69979' or
       '77261' <= &HCPCS <= '79999' or
       '90918' <= &HCPCS <= '91299' or '92950' <= &HCPCS <= '99199');
    
    *****************************************************************
 
    This SAS macro first removes records that are considered to have
    unreliable diagnosis coding.  These are selected by HCPCS.  
    Generally, they are bills that were not encoded by clinicians.
    Since CMS requires the bill to have a diagnosis code in order to
    be paid, someone (frequently the receptionist, etc) fills in an
    existing code for the patient that may not accurately reflect the
    reason for the procedure.

    Then, the macro reviews all claims and blanks out diagnoses that 
    are not considered valid.  The macro searches the claims as follows:
       KEEPS: all diagnosis codes on MEDPAR claims.
       KEEPS: all diagnosis codes on the Outpatient or Physician/Supplier
        claims that are also found on MEDPAR claims.
       KEEPS: all diagnosis codes on the Outpatient or Physician/supplier 
        claims that appear more than once over a time span exceeding 30 
        days. (Billing cycles may cause multiple bills to be submitted 
        for the same procedure within that time frame.)
    PLEASE NOTE: The NCI application of this algorithm includes specific
    ICD-9 codes.  Other researchers may wish to search within a group of
    related codes.  In those cases, this macro would have to be modified 
    or new code would have to be written.

    All other variables remain the same.  The dataset must contain 
    lists of diagnosis codes.  There are other specific variables 
    needed to complete this task.

    In order to use this program:
      1. Include this file in your SAS program  
          %include '/directory path/remove.ruleout.dxcodes.macro.sas';
      2. Create a clean file of claim records to send to the macro.
          You may include claim information from any file, including
          MEDPAR, Outpatient SAF and Physicial/Supplier (NCH).

      3. After setting up your data file, call the macro RULEOUT:
          RULEOUT(SetIn, PatId, Clmdte, Start, Finish, dx01-dx10, 10, HCPCS, Filetype);
          would send the data set 'SetIn', to the macro.  This file 
          includes the person identifier 'PatId', the date of claim 
          from the claim record 'Clmdte', the date the comorbidity
          window opens 'Start', and the date it closes 'Finish'.
          There are 10 diagnosis codes in the array variables 'dx01-dx10'.
          Diagnosis codes are in ICD-9 format.  HCPCS are the procedure
          codes from the SAF and NCH files. Only CPT-4 codes are used in
          this program.  The file source of each claim record is found
          in the variable 'Filetype' (M=Medpar, O=Outpatient, N=NCH).
    
    This returns the data set CLMRECS which contains claim records within
    the specified window.  Only acceptable ICD-9 diagnosis codes are included.
    The variables are the same as those in the file sent to the macro.
    The data set is sorted by the person identifier.
   **********************************************************************/


   /* Main macro RULEOUT */
%MACRO RULEOUT(SETIN,PATID,CLMDTE,START,FINISH,DXVARSTR,NDXVAR,HCPCS,FILETYPE);
   /**********************************************************************
    SETIN:    Dataset name: a dataset that contains the following:
    PATID:    Variable name: Unique ID for each patient.  &SETIN must be
              sorted by &PATID.  There may be more than 1 record per patient.
    CLMDTE:   Variable name: Date of the claim found on the claim file.
              Should be a SAS date format.
    START:    Variable name: Date the comorbidity window opens, ie DX-12
              Should be a SAS date format.
    FINISH:   Variable name: Date the comorbidity window closes, ie DX-1
              Should be a SAS date format.
    DXVARSTR: Variable names: the diagnosis codes, ie 'DX01-DX10'
    NDXVAR:   Number: the actual number of diagnosis codes in DXVARSTR
    HCPCS:    Variable name: the SAF and NCH file procedure codes in CPT-4.
    FILETYPE: Variable name: the source of the claim record.  Only important
              value is 'M' for MEDPAR (inpatient hospital records).  If this
              is 'M', all ICD-9 diagnosis codes are accepted.
   **********************************************************************/

  /* select claim records in appropriate window.  Keep 30 days extra on both sides */
  /* to allow for complete checks for the Outpatient and Physician/Supplier files.   */
  Data CLMRECS;
    set &SETIN;
    IF &START-30 <= &CLMDTE <= &FINISH+30;

  proc sort data=CLMRECS;
    by &PATID &CLMDTE;

  /* Separate data into variable of interest and variables unaffected by this macro */
  data test(keep=&PATID &CLMDTE icd9dx cnt j &filetype) CLMRECS(drop=j cnt &CLMDTE icd9dx &DXVARSTR);
    set CLMRECS;
    by &PATID &CLMDTE;
    ARRAY DXCODE (&NDXVAR) $ &DXVARSTR;
    retain cnt 0;
    cnt=cnt+1;
    cnta=cnt;
    clm_dtea=&CLMDTE;
    output CLMRECS;
    do j=1 to &NDXVAR;
      icd9dx=dxcode(j);
      if not (icd9dx='     ') then output test;
      end;

  proc sort data=test;
    by &PATID icd9dx &FILETYPE &CLMDTE;

  /* Initial pass at Dx codes: in test, retain all code in MEDPAR and those that appear */
  /* multiple times in a time span exceeding 30 days.  In hold, retain all codes that   */
  /* appear multiple time, but exact time span unclear when record processed.  In icds, */
  /* retain all patient/icd combinations that are discovered to be non-ruleout.         */
  data test(keep=&PATID clm_dtea icd9dx cnta ja) icds(keep=&PATID icd9dx iflag mflag)
       hold(keep=&PATID clm_dtea icd9dx cnta ja);
    set test;
    by &PATID icd9dx &FILETYPE &CLMDTE;
    retain clm_dtea clm_dtef clm_dtel cnta ja mflag iflag;
    if first.icd9dx then do;                /* initialize flags */
      mflag=0;
      iflag=0;
      clm_dtef=mdy(12,31,2100);
      clm_dtel=mdy(1,1,1900);
      end;  
    if &FILETYPE='M' then do;               /* KEEP, in medpar */
      clm_dtea=&CLMDTE;
      if &CLMDTE < clm_dtef then clm_dtef=&CLMDTE;
      if &CLMDTE > clm_dtel then clm_dtel=&CLMDTE;
      cnta=cnt;
      ja=j;
      output test;
      mflag=1;
      output icds;
      end;
    else if mflag=1 | iflag=1 then do;      /* KEEP, m=in medpar, i=outside 30 days */
      clm_dtea=&CLMDTE;
      if &CLMDTE < clm_dtef then clm_dtef=&CLMDTE;
      if &CLMDTE > clm_dtel then clm_dtel=&CLMDTE;
      cnta=cnt;
      ja=j;
      output test;
      end;
    else if first.icd9dx & last.icd9dx then delete;                          /* DROP, only appears once */

    else if first.icd9dx then do;           /* initialize retain variables */
      clm_dtea=&CLMDTE;
      if &CLMDTE < clm_dtef then clm_dtef=&CLMDTE;
      if &CLMDTE > clm_dtel then clm_dtel=&CLMDTE;
      cnta=cnt;
      ja=j;
      clm_dtef=&CLMDTE;
      end;
    else if last.icd9dx then do;
      if ((&CLMDTE-clm_dtea) > 30) | ((&CLMDTE-clm_dtef) > 30) | ((clm_dtel- &CLMDTE) > 30) then do; /* KEEP, outside 30 days */
        output test;                        /* KEEP previous information */
        clm_dtea=&CLMDTE;
        cnta=cnt;
        ja=j;
        output test;                        /* KEEP current information */
        iflag=1;
        output icds;
        end;
      /* else                                  DROP, only appears within 30 days */
      end;
    else do;
      if ((&CLMDTE-clm_dtea) > 30) | ((&CLMDTE-clm_dtef) > 30) | ((clm_dtel- &CLMDTE) > 30) then do; /* KEEP, outside 30 days */
        output test;                        /* KEEP previous information */ 
        clm_dtea=&CLMDTE;
        if &CLMDTE < clm_dtef then clm_dtef=&CLMDTE;
        if &CLMDTE > clm_dtel then clm_dtel=&CLMDTE;
        cnta=cnt;
        ja=j;
        output test;                        /* KEEP current information */ 
        iflag=1;
        output icds;
        end;
      else do;                              /* HOLD - may appear outside 30 days later */
        output hold;                        /* HOLD previous information */
        clm_dtea=&CLMDTE;                   /* upate retain variables */
        if &CLMDTE < clm_dtef then clm_dtef=&CLMDTE;
        if &CLMDTE > clm_dtel then clm_dtel=&CLMDTE;
        cnta=cnt;
        ja=j;
        end;
      end;
   
  proc sort data=icds nodups;
    by &PATID icd9dx;

  proc sort data=hold;
    by &PATID icd9dx;

  /* find all patient/icd9dx combinations that were held for recheck and were found to be valid */
  data test2(drop=iflag mflag);
    merge hold(in=h) icds(in=i);
    by &PATID icd9dx;
    if h;
    if iflag > 0 or mflag > 0 then output test2;

  data test;
    set test test2;

  proc datasets;
    delete hold icds test2;
  run;

  proc sort data=test;
    by &PATID cnta ja;

  /* reformat information from 1 icd code per record to standard format of &SETIN */
  data test(keep=&PATID cnta clm_dtea &DXVARSTR);
    set test;
    by &PATID cnta ja;
    ARRAY DXCODE (&NDXVAR) $ &DXVARSTR;
    retain &DXVARSTR '     ';
    dxcode(ja)=icd9dx;
    if last.cnta then do;
      output;
      do i=1 to &NDXVAR; 
        dxcode(i)='     ';
        end;
      end;

  proc sort data=test;
    by &PATID cnta clm_dtea;

  proc sort data=CLMRECS;
    by &PATID cnta clm_dtea;

  /* replace valid icd information into claim records.  All other information should be the same. */
  data CLMRECS(drop=cnta);
    merge test(in=t) CLMRECS(in=e);
    by &PATID cnta clm_dtea;
    if e;
    IF &START <= clm_dtea <= &FINISH; 
    rename clm_dtea=&CLMDTE;

  proc datasets;
    delete test;
  run;

  proc sort data=CLMRECS;
    by &PATID;
  run;

%MEND;

