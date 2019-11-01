*identify the most common denied claims by hcpcs for Segal Overuse;
*this is outpatient only--probably largest setting for overuse of interest in our study;

%macro denied (out=, in_revenue=, in_claims=);
data &out; 
set &in_revenue (keep=REV_CNTR_1ST_ANSI_CD REV_CNTR_2nd_ANSI_CD REV_CNTR_3rd_ANSI_CD REV_CNTR_4th_ANSI_CD CLM_MDCR_NON_PMT_RSN_CD hcpcs_cd denied);
ansi1=REV_CNTR_1ST_ANSI_CD; ansi2=REV_CNTR_2nd_ANSI_CD; ansi3=REV_CNTR_3rd_ANSI_CD; ansi4=REV_CNTR_4th_ANSI_CD;
array ansi(4) ansi1-ansi4;
do i=1 to 4;
	if substr(ansi(i),3,2) in('19','20','21','25','31','33','34','39','55','56','62','A1','A8') then denied=1;
	if substr(ansi(i),3,3) in('129','135','138','B14','B18','B23') then denied=1;
end;
if CLM_MDCR_NON_PMT_RSN_CD ne ' ' then denied=1;* Medicare did not pay for;;
if denied ne 1 then delete;
run;
%mend;
%denied (out=outpatient_denied_18_4, in_revenue=rifq2018.outpatient_revenue_04);
%denied (out=outpatient_denied_18_5, in_revenue=rifq2018.outpatient_revenue_05);
%denied (out=outpatient_denied_18_6, in_revenue=rifq2018.outpatient_revenue_06);
%denied (out=outpatient_denied_18_7, in_revenue=rifq2018.outpatient_revenue_07);
%denied (out=outpatient_denied_18_8, in_revenue=rifq2018.outpatient_revenue_08);
%denied (out=outpatient_denied_18_9, in_revenue=rifq2018.outpatient_revenue_09);
%denied (out=outpatient_denied_18_10, in_revenue=rifq2018.outpatient_revenue_10);
%denied (out=outpatient_denied_18_11, in_revenue=rifq2018.outpatient_revenue_11);
%denied (out=outpatient_denied_18_12, in_revenue=rifq2018.outpatient_revenue_12);

data denied;
set 
outpatient_denied_18_4 outpatient_denied_18_5 outpatient_denied_18_6 outpatient_denied_18_7
outpatient_denied_18_8 outpatient_denied_18_9 outpatient_denied_18_10 outpatient_denied_18_11 outpatient_denied_18_12;
run;

*format hcpcs with labels;
proc sort data=METADX.CCW_RFRNC_hcpcs_CD NODUPKEY OUT=hcpcs; BY hcpcs_CD hcpcs_shrt_desc; RUN; 
proc sort data=hcpcs ; by hcpcs_cd descending hcpcs_actn_efctv_dt; run;
proc sort data=hcpcs NODUPKEY out=hcpcs2 dupout=hcpcs_dup; by hcpcs_cd; run;
proc print data=hcpcs_dup; run;
data fmthcpcs (rename=(hcpcs_CD=start));
set hcpcs2 (keep = hcpcs_cd hcpcs_shrt_desc);
fmtname='$hcpcs';
label = hcpcs_cd ||": " || hcpcs_shrt_desc;
run;
proc format cntlin=fmthcpcs; run;

proc freq data=denied order=freq; table hcpcs_cd; format hcpcs_cd $hcpcs.; run;
