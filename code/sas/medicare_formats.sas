/******************************************************************
* PROGRAM NAME :  medicare_formats.sas
* DESCRIPTION :   common formats for use with Medicare data on VRDC
* AUTHOR:         shutfle1@jhmi.edu
* LinkedIn:       
* GIT Repo Source: 
*******************************************************************
*  these formats may not apply to other data sources.
	caveat emptor if trying to use with medicaid or other sources
*******************************************************************/




*create formats for dgns, drg, hcpcs for easier data checks;
proc sort data=METADX.CCW_RFRNC_dgns_CD NODUPKEY OUT=dgns; BY dgns_CD dgns_DESC; RUN; *799;
proc sort data=dgns ; by dgns_cd descending dgns_efctv_dt; run;
proc sort data=dgns NODUPKEY out=dgns2 dupout=dgns_dup; by dgns_cd; run;
proc print data=dgns_dup; run;
data fmtdgns (rename=(dgns_CD=start));
set dgns2 (keep = dgns_cd dgns_desc);
fmtname='$dgns';
label = dgns_cd ||": " || dgns_desc;
run;
proc format cntlin=fmtdgns; run;

proc sort data=METADX.CCW_RFRNC_DRG_CD NODUPKEY OUT=DRG; WHERE DRG_EFCTV_DT>='01JAN2013'D; BY DRG_CD DRG_DESC; RUN; *799;
proc sort data=drg ; by drg_cd descending drg_efctv_dt; run;
proc sort data=drg NODUPKEY out=drg2 dupout=drg_dup; by drg_cd; run;
proc print data=drg_dup; run;
data fmtDRG (rename=(DRG_CD=start));
set DRG2 (keep = drg_cd drg_desc);
fmtname='$DRG';
label = drg_cd ||": " || drg_desc;
run;
proc format cntlin=fmtDRG; run;

proc sort data=METADX.CCW_RFRNC_hcpcs_CD NODUPKEY OUT=hcpcs; BY hcpcs_CD hcpcs_shrt_desc; RUN; *799;
proc sort data=hcpcs ; by hcpcs_cd descending hcpcs_actn_efctv_dt; run;
proc sort data=hcpcs NODUPKEY out=hcpcs2 dupout=hcpcs_dup; by hcpcs_cd; run;
proc print data=hcpcs_dup; run;
data fmthcpcs (rename=(hcpcs_CD=start));
set hcpcs2 (keep = hcpcs_cd hcpcs_shrt_desc);
fmtname='$hcpcs';
label = hcpcs_cd ||": " || hcpcs_shrt_desc;
run;
proc format cntlin=fmthcpcs; run;

