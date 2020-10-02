   /**********************************************************************
    Changes have been made to the remove.ruleout.dxcodes.macro.txt on 
    July 22, 2010 to remove code (below) that made a selection
    on HCPCS.  Now all the claims are looked at for conditions.
    
    if (&FILETYPE='M') or
      ('00100' <= &HCPCS <= '01999' or '10021' <= &HCPCS <= '69979' or
       '77261' <= &HCPCS <= '79999' or
       '90918' <= &HCPCS <= '91299' or '92950' <= &HCPCS <= '99199');
    
    Please make sure you use the current remove.ruleout.dxcodes.macro.txt
    before running this macro.
    
    *****************************************************************
    This SAS macro uses a dataset of claim records to calculate a 
    comorbidity index for a patient with respect to cancer.  This code
    reflects the Deyo adaptation of the Charlson comorbidity index, with
    several procedure codes that reflect the Romano adaptation.
    (NOTE: since cancer is the disease of interest, it is not included
    in the comorbidity index given below.)  The dataset must contain 
    lists of diagnosis and surgery codes.  There are other specific 
    variables needed to complete this task.
  
    In order to use this program:
      1. Include this file in your SAS program  
      	  %include '/directory path/charlson.comorbidity.macro.sas';
      2. Create a clean file of claim records to send to the macro.
    	  If you wish to remove diagnoses for procedures done for 
    	  'rule out' purposes, you must do so externally to this macro.
	  (SEE remove.ruleout.dxcodes.macro.sas from SEER-Medicare web site)
    	  You may include claim information from any file, including
    	  MEDPAR, Outpatient SAF and Physicial/Supplier (NCH).  All claim
	  records of interest should be included into the same file.
    	  You must sort the claim records by your person identifier.
      3. After setting up your data file, call the macro COMORB:
          COMORB(ClmData, RegCase, Ind_Pri, LOS, dx01-dx10, 10, surg01-surg10, 10, HCPCS, Source)
    	  would send the data set 'ClmData', sorted by the person 
    	  identifier 'RegCase' to the macro.  The variable 'Ind_Pri'
    	  must be set on each record as either index (I) or Prior event (P)
    	  with respect to the cancer of interest.  The number of
    	  days for a hospital stay is found in the variable 'LOS'.
    	  There are 10 diagnosis codes in the array variables 'dx01-dx10'.
    	  Similarly, there are 10 surgery codes in the array variables 
    	  'surg01-surg10'.  Diagnosis and surgery codes are in ICD-9 format.
          HCPCS are the procedure codes from the SAF and NCH files. Only CPT-4
	  codes are used in this program.  The file source of each claim 
	  record is found in the variable 'Source' (M=Medpar, O=Outpatient,
	  N=NCH).
    
    This returns the data set COMORB which contains 1 record for each person
    that had at least one claim record.  The variables included in this data set are
    the person identifier (in the example, RegCase), Charlson scores for 
    prior conditions, index conditions and prior+index conditions, and the
    condition indicator flags for prior and for index time frames. 
    
    NCI usually uses PCHRLSON calculated using claims from
    	(Date of Diagnosis - 12 months) through (Date of DX - 1 month)
   **********************************************************************/
 
   /* internal macro to set indicators */
%MACRO FLAGSET(VAR,FLAG,NFLAGS,POSISHN);
   &FLAG = &POSISHN;
   &NFLAGS = &NFLAGS + 1;
   &VAR = 1;
%MEND;
 
   /* Main macro COMORB */
%MACRO COMORB(SETIN,PATID,IDXPRI,DAYS,DXVARSTR,NDXVAR,SXVARSTR,NSXVAR,HCPCS,FILETYPE);
   /**********************************************************************
    SETIN:    Dataset name: a dataset that contains the following:
    PATID:    Variable name: Unique ID for each patient.  &SETIN must be
              sorted by &PATID.  There may be more than 1 record per patient.
    IDXPRI:   Variable name: indicates for each record if the Dx and Surg 
    	      codes are Index 'I' or Prior 'P' to the event of interest.
    	      If the variable does not equal I or P, the record will not be
    	      used.  This variable should be set by the calling program.
    DAYS:     Variable name: contains the length of stay for hospital visits.
    DXVARSTR: Variable names: the diagnosis codes in ICD-9, ie 'DX01-DX10'
    NDXVAR:   Number: the actual number of diagnosis codes in DXVARSTR
    SXVARSTR: Variable names: the surgery codes in ICD-9, ie 'SURG01-SURG10'
    NSXVAR:   Number: the actual number of surgery codes in SXVARSTR
    HCPCS:    Variable name: the SAF and NCH file procedure codes in CPT-4.
    FILETYPE: Variable name: the source of the claim record.  Only important
    	      value is 'M' for MEDPAR (inpatient hospital records).  If this
    	      is 'M', the check for Acute MI will include &DAYS > 2.
   **********************************************************************/
 
 DATA COMORB;
   RETAIN CVPRIO01-CVPRIO18
          CVINDX01-CVINDX18; 
   LENGTH DEFAULT=3;
   SET &SETIN;
   BY &PATID;
    
   /* Flag arrays, diagnosis and surgery code arrays */
   ARRAY CLPRIO (18) CVPRIO01-CVPRIO18;
   ARRAY CLINDX (18) CVINDX01-CVINDX18;
   ARRAY COVAR  (18) ACUTEMI OLDMI CHF VASCUL1 VASCUL2 CVD
                     PULMON1 DEMENTIA PARALYS DIABET1 DIABET3 RENAL1
                     LIVER1 LIVER2 ULCER1 ULCER2 RHEUM AIDS;
   ARRAY FLAGS (*) FLAG01-FLAG18;
   ARRAY DX (&NDXVAR) $ &DXVARSTR;
   ARRAY SX (&NSXVAR) $ &SXVARSTR;
 			     
   /* Initialization */
   IF FIRST.&PATID THEN DO;
     DO M=1 TO 18;
       CLPRIO(M)=0;
       CLINDX(M)=0;
       END;
     END;

   DO M=1 TO 18;
     COVAR(M)=0;
     FLAGS(M)=0;
     END;
    
   NFLAGS=0;
    
   /* Diagnosis code loop */  
   DO K=1 TO &NDXVAR;
     dx_4 = substr(dx(k),1,4);
     dx_3 = substr(dx(k),1,3);

     /********** MYOCARDIAL INFARCTION WEIGHT = 1 ****************/
     IF ACUTEMI=0 THEN DO;		
       IF dx_3 = '410' then do;  	                  /* 410 thru 4109 */
          IF ((&FILETYPE='M') & (&DAYS > 2)) | NOT (&FILETYPE='M') THEN DO; 
            %FLAGSET(ACUTEMI,FLAGS(NFLAGS+1),NFLAGS,1);
            END;
          END;
       END;
 
     IF OLDMI=0 THEN DO;
       IF DX(K) = '412  ' then do;
          %FLAGSET(OLDMI,FLAGS(NFLAGS+1),NFLAGS,2);
          END;
       END;
 
     /********** CHF ***** WEIGHT = 1 ****************************/
     IF CHF=0 THEN DO;
       IF dx_3 = '428' then do;		                  /* 428 thru 4289 */ 
          %FLAGSET(CHF,FLAGS(NFLAGS+1),NFLAGS,3);
          END;
       END;
 
     /*********** PERIPHERAL VASCULAR DISEASE ******* WEIGHT = 1**/
     IF VASCUL1=0 THEN DO;		                  /* 441 thru 4419 */  
       IF dx_3 = '441' | dx_4 in ('4439', '7854', 'V434', 'v434') then do;
          %FLAGSET(VASCUL1,FLAGS(NFLAGS+1),NFLAGS,4);
          END;
       END;
 
     /********* CEREBROVASCULAR DISEASE ******* WEIGHT = 1 *******/
     IF CVD=0 THEN DO;					  /* 430 thru 4379 */
       IF '430' <= dx_3 <= '437' | DX(K)= '438  ' then do; 
          %FLAGSET(CVD,FLAGS(NFLAGS+1),NFLAGS,6);
          END;
       END;
 
     /*********** COPD *********************** WEIGHT = 1 ********/
     IF PULMON1=0 THEN DO;
       IF '490' <= dx_3 <= '496' | '500' <= dx_3 <= '505' | 
          dx_4 = '5064' THEN DO;
          %FLAGSET(PULMON1,FLAGS(NFLAGS+1),NFLAGS,7);
          END;
       END;
  
     /********  DEMENTIA ****** WEIGHT = 1 ***********************/
     IF DEMENTIA=0 THEN DO;
       IF dx_3 = '290' then do;		                  /* 290 thru 2909 */ 
          %FLAGSET(DEMENTIA,FLAGS(NFLAGS+1),NFLAGS,8);
          END;
       END;
 
     /********* PARALYSIS **************** WEIGHT = 2 ************/
     IF PARALYS=0 THEN DO;			  
       IF dx_3 = '342' | dx_4 = '3441' then do;	          /* 342 thru 3429 */ 
          %FLAGSET(PARALYS,FLAGS(NFLAGS+1),NFLAGS,9);
          END;
       END;
 
     /******** DIABETES ************* WEIGHT = 1 *****************/
     IF DIABET1=0 THEN DO;
       IF DX(K)= '250  ' | dx_4 = '2507' | '2500' <= dx_4 <= '2503' then do;
          %FLAGSET(DIABET1,FLAGS(NFLAGS+1),NFLAGS,10);
          END;
       END;
 
     /********* DIABETES WITH SEQUELAE ****** WEIGHT = 2 *********/
     IF DIABET3=0 THEN DO;
       IF ('2504' <= dx_4 <= '2506') | ('2508' <= dx_4 <= '2509') THEN DO;
          %FLAGSET(DIABET3,FLAGS(NFLAGS+1),NFLAGS,11);
          END;
       END;
 
     /********* CHRONIC RENAL FAILURE ******* WEIGHT = 2 *********/
     IF RENAL1=0 THEN DO;	     /* 582 - 5829; 583 - 5839, 588 - 5889 */
       IF dx_3 in ('582', '583', '585', '586', '588') then do;
          %FLAGSET(RENAL1,FLAGS(NFLAGS+1),NFLAGS,12);
          END;
       END;
 
     /************** VARIOUS CIRRHODITES ******** WEIGHT = 1 *****/
     IF LIVER1=0 THEN DO;	        /* includes 5714x ICD-9-CM codes */
       IF dx_4 in ('5712', '5714', '5715', '5716') then do;
          %FLAGSET(LIVER1,FLAGS(NFLAGS+1),NFLAGS,13);
          END;
       END;
 
     /************** MODERATE-SEVERE LIVER DISEASE *** WEIGHT = 3*/
     IF LIVER2=0 THEN DO;
       IF ('5722' <= dx_4 <= '5728') | ('4560' <= dx_4 <= '4561') |
          DX(K) in ('4562 ', '45620',  '45621') THEN DO;
          %FLAGSET(LIVER2,FLAGS(NFLAGS+1),NFLAGS,14);
          END;
       END;
 
     /*************** ULCERS ********** WEIGHT = 1 ***************/
     IF ULCER1=0 THEN DO;
       IF '5310' <= dx_4 <= '5313' | '5320' <= dx_4 <= '5323' |
          '5330' <= dx_4 <= '5333' | '5340' <= dx_4 <= '5343' |
          dx_4 in ('531 ', '5319', '532 ', '5329', '533 ', '5339', 
	           '534 ', '5349') THEN DO;
          %FLAGSET(ULCER1,FLAGS(NFLAGS+1),NFLAGS,15);
          END;
       END;
     IF ULCER2=0 THEN DO;
       IF '5314' <= dx_4 <= '5317' | '5324' <= dx_4 <= '5327' | 
          '5334' <= dx_4 <= '5337' | '5344' <= dx_4 <= '5347' THEN DO;
          %FLAGSET(ULCER2,FLAGS(NFLAGS+1),NFLAGS,16);
          END;
       END;
 
     /*************** RHEUM  ********** WEIGHT = 1 ***************/
     IF RHEUM=0  THEN DO;
       IF DX(K) in ('71481', '725  ', '7100 ', '7101 ', '7104 ') |
          '7140' <= dx_4 <= '7142' THEN DO;
          %FLAGSET(RHEUM,FLAGS(NFLAGS+1),NFLAGS,17);
          END;
       END;
 
     /*************** AIDS   ********** WEIGHT = 6 ***************/
     IF AIDS=0   THEN DO;
       IF '042' <= dx_3 <= '044' then do;          /* 042 thru 0449 */
          %FLAGSET(AIDS,FLAGS(NFLAGS+1),NFLAGS,18);
          END;
       END;
 
   END; /* end of Diagnosis code loop */

   /* Surgery code loop */ 
   DO J=1 TO &NSXVAR;
     /*********** PERIPHERAL VASCULAR DISEASE ******* WEIGHT = 1**/
     IF VASCUL2=0 THEN DO;
       IF SX(J) = '3813' | SX(J) = '3814' | SX(J) = '3816' |
          SX(J) = '3818' | SX(J) = '3843' | SX(J) = '3844' |
          SX(J) = '3846' | SX(J) = '3848' | SX(J) = '3833' |
          SX(J) = '3834' | SX(J) = '3836' | SX(J) = '3838' |
          '3922' <=SX(J)<= '3929' & SX(J) ^= '3927' THEN DO;
          %FLAGSET(VASCUL2,FLAGS(NFLAGS+1),NFLAGS,5);
          END;
       END;
 
     /********* CEREBROVASCULAR DISEASE ******* WEIGHT = 1 *******/
     IF CVD=0 THEN DO;
       IF SX(J) = '3812' | SX(J) = '3842' THEN DO;
          %FLAGSET(CVD,FLAGS(NFLAGS+1),NFLAGS,6);
	  END;
       END;
 
     /************** MODERATE-SEVERE LIVER DISEASE *** WEIGHT = 3*/
     IF LIVER2=0 THEN DO;
       IF SX(J) = '391 ' | SX(J) = '4291' THEN DO;
          %FLAGSET(LIVER2,FLAGS(NFLAGS+1),NFLAGS,14);
	  END;
       END;
       
   END; /* end of Surgery code loop */
 
   /* HCPCS procedure code */ 
   /*********** PERIPHERAL VASCULAR DISEASE ******* WEIGHT = 1**/
   IF VASCUL2=0 THEN DO;
     IF &HCPCS IN ('35011', '35013',  '35045', '35081', '35082', 
	'35091', '35092', '35102', '35103', '35111', '35112', '35121', 
	'35122', '35131', '35132', '35141', '35142', '35151', '35152', 
	'35153', '35311', '35321', '35331', '35341', '35351', '35506', 
	'35507', '35511', '35516', '35518', '35521', '35526', '35531', 
	'35533', '35536', '35541', '35546', '35548', '35549', '35551',
	'35556', '35558', '35560', '35563', '35565', '35566', '35571',
	'35582', '35583', '35585', '35587', '35601', '35606', '35612',
	'35616', '35621', '35623', '35626', '35631', '35636', '35641',
	'35646', '35650', '35651', '35654', '35656', '35661', '35663',
	'35665', '35666', '35671', '35694', '35695') OR
        '35355' <= &HCPCS <= '35381' 
       	THEN DO;
        %FLAGSET(VASCUL2,FLAGS(NFLAGS+1),NFLAGS,5);
        END;
     END;

   /********* CEREBROVASCULAR DISEASE ******* WEIGHT = 1 *******/
   IF CVD=0 THEN DO;
     IF &HCPCS IN ('35301', '35001', '35002', '35005', '35501', '35508',
 	'35509', '35515', '35642', '35645', '35691', '35693') THEN DO;
        %FLAGSET(CVD,FLAGS(NFLAGS+1),NFLAGS,6);
        END;
     END;

   /************** MODERATE-SEVERE LIVER DISEASE *** WEIGHT = 3*/
   IF LIVER2=0 THEN DO;
     IF &HCPCS IN ('37140', '37145', '37160', '37180', '37181', '75885', 
        '75887', '43204', '43205') THEN DO;
        %FLAGSET(LIVER2,FLAGS(NFLAGS+1),NFLAGS,14);
        END;
     END;

   /* end HCPCS procedure code */ 


   /* Use general indicators to turn on Prior and Index indicators */
   IF NFLAGS > 0 THEN DO;
     DO M=1 TO NFLAGS;
       I=FLAGS(M);
       IF COVAR(I) THEN DO;
         IF &IDXPRI = 'P'   THEN  CLPRIO(I)=1;
         ELSE IF &IDXPRI = 'I'   THEN  CLINDX(I)=1;
         END;
       END;
     END;

   IF LAST.&PATID THEN DO;
     /* CALCULATE THE COEFFICIENT FOR PRIOR CONDITIONS ONLY */
     PCHRLSON = (CVPRIO01 | CVPRIO02) +
                (CVPRIO03) +
                (CVPRIO04 | CVPRIO05) +
                (CVPRIO06) +
                (CVPRIO07) +
                (CVPRIO08) +
                ((CVPRIO10) & ^(CVPRIO11)) +
                ((CVPRIO13) & ^(CVPRIO14)) +
                (CVPRIO15 | CVPRIO16) +
                (CVPRIO17) +
                ((CVPRIO09) * 2) +
                ((CVPRIO12) * 2) +
                ((CVPRIO11) * 2) +
                ((CVPRIO14) * 3) +
                ((CVPRIO18) * 6);
 
     /* CALCULATE THE COEFFICIENT FOR PRIOR AND INDEX COND */
     CHRLSON = (CVPRIO01 | CVPRIO02 | CVINDX02) +
               (CVPRIO03) +
               (CVPRIO04 | CVINDX04 | CVPRIO05 | CVINDX05) +
               (CVPRIO06) +
               (CVPRIO07 | CVINDX07) +
               (CVPRIO08 | CVINDX08) +
               ((CVPRIO10 | CVINDX10) & ^(CVPRIO11 | CVINDX11)) +
               ((CVPRIO13 | CVINDX13) & ^(CVPRIO14 | CVINDX14)) +
               (CVPRIO15) +
               ((CVPRIO09) * 2) +
               ((CVPRIO12 | CVINDX12) * 2) +
               ((CVPRIO11 | CVINDX11) * 2) +
               ((CVPRIO14 | CVINDX14) * 3); 
 
     /* CALCULATE THE COEFFICIENT FOR INDEX CONDITIONS ONLY */
     XCHRLSON = (CVINDX02) +
                (CVINDX04 | CVINDX05) +
                (CVINDX07) +
                (CVINDX08) +
                ((CVINDX10) &^ (CVINDX11)) +
                ((CVINDX13) &^ (CVINDX14)) +
                ((CVINDX12) * 2) +
                ((CVINDX11) * 2) +
                ((CVINDX14) * 3); 

     OUTPUT;
     END;
   
   KEEP &PATID PCHRLSON CHRLSON XCHRLSON CVPRIO01-CVPRIO18 CVINDX01-CVINDX18;
   Label PCHRLSON = 'Prior Charlson comorbidity score'
         CHRLSON  = 'Prior+Index Charlson comorbidity score'
         XCHRLSON = 'Index Charlson comorbidity score'
         
         CVPRIO01 = 'Prior: MYOCARDIAL INFARCTION (1)'            
         CVPRIO02 = 'Prior: OLD MYOCARDIAL INFARCTION (1)'        
         CVPRIO03 = 'Prior: CHF (1)'                              
         CVPRIO04 = 'Prior: PERIPHERAL VASCULAR DISEASE (DX, 1)'  
         CVPRIO05 = 'Prior: PERIPHERAL VASCULAR DISEASE (SURG, 1)'
         CVPRIO06 = 'Prior: CEREBROVASCULAR DISEASE (1)'          
         CVPRIO07 = 'Prior: COPD (1)'                             
         CVPRIO08 = 'Prior: DEMENTIA (1)'                         
         CVPRIO09 = 'Prior: PARALYSIS (2)'                        
         CVPRIO10 = 'Prior: DIABETES (1)'                         
         CVPRIO11 = 'Prior: DIABETES WITH SEQUELAE (2)'           
         CVPRIO12 = 'Prior: CHRONIC RENAL FAILURE (2)'            
         CVPRIO13 = 'Prior: VARIOUS CIRRHODITES (1)'              
         CVPRIO14 = 'Prior: MODERATE-SEVERE LIVER DISEASE (3)'    
         CVPRIO15 = 'Prior: ULCERS1 (1)'                          
         CVPRIO16 = 'Prior: ULCERS2 (1)'                          
         CVPRIO17 = 'Prior: RHEUM (1)'                            
         CVPRIO18 = 'Prior: AIDS (6)'                             
         
         CVINDX01 = 'Index: MYOCARDIAL INFARCTION (1)'            
         CVINDX02 = 'Index: OLD MYOCARDIAL INFARCTION (1)'        
         CVINDX03 = 'Index: CHF (1)'                              
         CVINDX04 = 'Index: PERIPHERAL VASCULAR DISEASE (DX, 1)'  
         CVINDX05 = 'Index: PERIPHERAL VASCULAR DISEASE (SURG, 1)'
         CVINDX06 = 'Index: CEREBROVASCULAR DISEASE (1)'          
         CVINDX07 = 'Index: COPD (1)'                             
         CVINDX08 = 'Index: DEMENTIA (1)'                         
         CVINDX09 = 'Index: PARALYSIS (2)'                                 
         CVINDX10 = 'Index: DIABETES (1)'                         
         CVINDX11 = 'Index: DIABETES WITH SEQUELAE (2)'           
         CVINDX12 = 'Index: CHRONIC RENAL FAILURE (2)'            
         CVINDX13 = 'Index: VARIOUS CIRRHODITES (1)'              
         CVINDX14 = 'Index: MODERATE-SEVERE LIVER DISEASE (3)'    
         CVINDX15 = 'Index: ULCERS1 (1)'                          
         CVINDX16 = 'Index: ULCERS2 (1)'                          
         CVINDX17 = 'Index: RHEUM (1)'                            
         CVINDX18 = 'Index: AIDS (6)'                             
         ;

run; 
%MEND;
