/* Indicator 02 */

/*Description from Excel file
(New) Number 		11	
Indicator 			Hysterectomy for benign disease	
Indicator
			Motivator: there are too many hysterectomies performed for benign disease
			that could be managed more conservatively

			Indicator: Hysterectomy performed for an indication other than a cancer diagnosis
			of a pelvic organ (ovary, uterus, peritoneum, cervix, bladder).

			[this can be reported among all patients with hysterectomy]

Timing		Inclusionary diagnosis code is associated with the procedure code (same claim)
			or same admission (with primary diagnosis)	

System		Gyne	

Actor		Gynecologist, occasionally general surgeon
*/

/* Eliana this might be Useful: how to concat from excel to tak exact codes: =CONCATENATE("'",D1,"'")


/*** start of indicator specific variables ***/

/*inclusion criteria*/
%global includ_hcpcs;
%global includ_pr10;

%let includ_hcpcs =
					'58150'	'58152'	'58180'	'58200'
					'58210'	'58260'	'58262'	'58263'	
					'58267'	'58270'	'58275'	'58280'
					'58285'	'58290'	'58291'	'58292'
					'59293'	'59294'	'58541'	'58542'
					'58543'	'58544'	'58548'	'58550'
					'58552'	'58553'	'58554'	'58570'
					'58571'	'58572'	'58573'				;

%let includ_pr10 =
					'0UT94ZL'	'0UT90ZL'	'0UT94ZZ'
					'0UT90ZZ'	'0UT9FZL'	'0UT9FZZ'
					'0UT97ZL'	'0UT98ZL'	'0UT97ZZ'
					'0UT98ZZ'	'0UT44ZZ'	'0UT94ZZ'
					'0UT40ZZ'	'0UT90ZZ'	'0UT44ZZ'
					'0UT9FZZ'	'0UT47ZZ'	'0UT48ZZ'
					'0UT97ZZ'	'0UT98ZZ'	'0UT90ZZ'
					'0UT94ZZ'	'0UT90ZL'	'0UT90ZZ'
					'0UT94ZL'	'0UT94ZZ'	'0UT97ZL'
					'0UT97ZZ'	'0UT98ZL'	'0UT98ZZ'
					'0UT9FZL'	'0UT9FZZ'				;

%let includ_drg = ;

/** Exclusion criteria **/
%let EXCLUD_dx10_1='C'; 

/** label pop specific variables  instructions: ctrl-H 11 for this pop # **/
%global flag_popped																;
%let 	flag_popped             		= popped11 								;
%let 	flag_popped_label				= 'indicator 11 popped'					;	
%let	flag_popped_dt					= popped11_dt							;
%let 	flag_popped_dt_label			= 'indicator 11 date patient popped'	;
%let 	pop_age							= pop_11_age							;				
%let	pop_age_label					= 'age eligible for pop 11'				;
%let	pop_los							= pop_11_los							;
%let	pop_los_label					= 'length of stay when patient popped'	;
%let	pop_year						= pop_11_year							;
%let	pop_nch_clm_type_cd				= pop_11_nch_clm_type_cd				;
%let  	pop_CLM_IP_ADMSN_TYPE_CD		= pop_11_CLM_IP_ADMSN_TYPE_CD			;
%let	pop_clm_fac_type_cd				= pop_11_clm_fac_type_cd				;
%let	pop_clm_src_ip_admsn_cd			= pop_11_clm_src_ip_admsn_cd					;
%let	pop_ptnt_dschrg_stus_cd  		= pop_11_ptnt_dschrg_stus_cd			;
%let	pop_admtg_dgns_cd				= pop_11_admtg_dgns_cd					;
%let	pop_icd_dgns_cd1				= pop_11_icd_dgns_cd1					;
%let	pop_clm_drg_cd					= pop_11_clm_drg_cd						;
%let	pop_hcpcs_cd					= pop_11_hcpcs_cd						;
%let	pop_OP_PHYSN_SPCLTY_CD			= pop_11_OP_PHYSN_SPCLTY_CD				;

%let	pop_nch_clm_type_cd_label		= 'claim/facility type for pop 11' 		;
%let	pop_CLM_IP_ADMSN_TYPE_CD_label	= 'inpatient admission type code for pop 11'	;
%let  	pop_clm_fac_type_cd_label		= 'inpatient clm_fac_type_cd for pop 11';
%let	pop_clm_src_ip_admsn_cd_label	= 'clm_src_ip_admsn_cd for pop 11'		;
%let	pop_ptnt_dschrg_stus_cd_label	= 'discharge status code for pop 11'	;	


/*** end of indicator specific variables ***/