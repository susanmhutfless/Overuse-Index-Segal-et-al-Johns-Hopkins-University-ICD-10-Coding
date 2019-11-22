/********************************************************************
* Job Name: macro_prepare_table_publication_structure.sas
* Job Desc: Input for Inpat Claims for Step1 Job
* Copyright: Johns Hopkins University - HutflessLab 2019
********************************************************************/

/*******************************************************************
 * Source: Downloaded by shutfle1@jhmi.edu
 * Download Date: 20191120
 * Documentation:
 *      PDF documentation and original SAS code available from website
        mentioned in "download source"
        - SH modified this slightly for a project (with respect to output options)
        - if macro doesn't work re-download the original from website above
 * Download Source:
 *    https://www.hsph.harvard.edu/donna-spiegelman/software/table1-for-windows/
*******************************************************************/

/*******************************************************************
* Credits in Original Source Code
* The numargs macro was developed by
* Carrie Wager,Programmer,Channing Laboratory 1990
* Modified AMcD 1993, e hertzmark 1994 and L Chen 1996
*******************************************************************/

%macro numargs(arg, delimit);
   %if %quote(&arg)= %then %do;
        0
   %end;
   %else %do;
     %let n=1;
     %do %until (%qscan(%quote(&arg), %eval(&n), %str( ))=%str());
        %let n=%eval(&n+1);
        %end;
        %eval(&n-1)
   %end;
   %mend numargs;

/*************  get footnotes from table 1 call***************/
%macro makefn();

%global fnlst fncnt;
%let fncnt = 0;

***scan variable list to fncnt # in list;
%do %while(%qscan(&fn, &fncnt+1,%str(@)) ne %str());
    %let fncnt = %eval(&fncnt+1);
%end;

%do i = 1 %to &fncnt;

 %global fn&i fnvar&i;
 %let var&i = %Scan(&fn,&i,"@");
 %let fn&i    =;
 %let fnvar&i =;

 data null;
  fnstr = "&&var&i";

  fn    = prxchange("s/^\S+//", 1, fnstr);
  fnvar = prxchange("s/ \S+//", -1, fnstr);

  call symput("fn&i", fn);
  call symput("fnvar&i", fnvar);
 run;
%end;

%let fnlst=;

%do z = 1 %to &fncnt;
 %let fnlst = &fnlst &&fnvar&z;
%end;

%mend;



%macro t1rtf(
             data     =,
             exposure =,
             varlist  =,
             noadj    =,
             cat      =,
             mdn      =,
             rtftitle =,
             landscape=,
             fn       =,
             uselbl   =,
             file     =,
             dec      =,
             dec_rnd  =
             );

/**************** end footnotes **************/

data table1dat;
        set &data;

proc contents data = table1dat out = dsetcont noprint;

data dsetcont;
 set dsetcont;
 if missing(label) then label = name;
 lbltmp1 = prxchange('s/(BYTE\(\d{1,3}\))/%sysfunc($1)/I', -1, label);
 label = resolve(lbltmp1);
 drop lbltmp1;
run;

%let expfmt=;
%let explbl=;

/* get labels and format name for levels of exposure variable */
proc sql noprint;
 select upcase(format) into :expfmt from dsetcont where upcase(name) = "%upcase(&exposure)";
 select label into :explbl from dsetcont where upcase(name) = "%upcase(&exposure)";
quit;

proc format;
 value  levelfmt
 0="&label0"
 1="&label1"
 2="&label2"
 3="&label3"
 4="&label4"
 5="&label5"
 6="&label6"
 7="&label7"
 8="&label8"
 9="&label9"
 10="&label10"
 11="&label11"
 12="&label12"
 13="&label13"
 14="&label14"
 15="&label15";

/* if missing format or request uselbl option, then use levelfmt option or defaults for
exposure level lables */
%if &expfmt eq %str() or %upcase("&uselbl")="T" %then %do; %let expfmt = LEVELFMT; %end;


/* get formats using format name for exposure variable, to be used as labels */
proc format library = &fmtlib..&fmtcat cntlout=frmts;

data frmts;
set frmts;
if upcase(fmtname) = "%upcase(&expfmt)";
if type = "N" then do;
   startN = int(start); /* start * 1.0;*/
   endN = int(end); /*end * 1.0;*/

 fmttmp1 = prxchange('s/(BYTE\(\d{1,3}\))/%sysfunc($1)/I', -1, label);
 label = resolve(fmttmp1);
 drop fmttmp1;
end;
run;

/* remove existing formats from exposure  */
data table1dat;
 set table1dat;
 format &exposure;
run;

%let cntvar = 0;

/*scan variable list to cntvar # in list - note: could change to numargs for consitiency left for now */
%do %while(%qscan(&varlist, &cntvar+1,%str( )) ne %str());
    %let cntvar = %eval(&cntvar+1);
%end;

/* for footnote superscripts */
%let super = a b c d e f g h i j k l m n o p q r s t u v w x y z;


/*** M. Pazaris NOTE moved out of "v" loop ***/
%let count=0;
%let countobs=0;
%let expval =;
%let minexp=;
%let maxexp=;

proc sql noprint;
 select count(unique(&exposure)) into :count
 from table1dat
 where &exposure >= 0;
 select min(&exposure) into :minexp
 from table1dat
 where &exposure >= 0;
 select max(&exposure) into :maxexp
 from table1dat
 where &exposure >= 0;
 select unique(&exposure) into :expval separated by ' '
 from table1dat
 where &exposure >= 0;
 select count(*) into :countobs
 from table1dat
 where &exposure >= 0;
quit;

%let count = %sysfunc(compress(&count));
%let minexp = %sysfunc(compress(&minexp));
%let maxexp = %sysfunc(compress(&maxexp));

   %if "%upcase(&multn)" = "T" %then %do i = &minexp %to &maxexp;
     %let exp_n&i =;
   proc sql;
    select %bquote(count(unique(&id))) into :exp_n&i
    from table1dat where &exposure=&i;
   quit;
  %end;


/*** end M. Pazaris NOTE moved out of "v" loop ***/


data tab;
set tab;
%if &count > 1 %then %do; _nall_ = sum(of n&minexp-n&maxexp);
%end;
%if &count = 1 %then %do; _nall_ = n&minexp;
%end;
run;

%do v = 1 %to &cntvar;

%let var = %Scan(&varlist,&v," ");
%let varpol = %Scan(&varlist,%eval(&v+1)," ");

%let catv=;
%let mdnv=;
%let nadj=;
%let fn=;
%let mis=;


     /****  Calculate missing percent  *******/
      %if "%upcase(&miscol)" = "T" %then %do;
           proc sql noprint;
            select (1-(_nall_/&countobs))*100 into :mis
            from tab having upcase(varname) = "%upcase(&var)";
           quit;

        /*** Missing for polytomous categorical variabels ****/
        %if "&polycat" ne "" %then %do p = 1 %to &polyord;
                    %if %upcase(&var) = %upcase(_tmp&p) %then %do;
                       proc sql noprint;
                        select (1-(_nall_/&countobs))*100 into :mis
                        from tab having upcase(varname) = "%upcase(&varpol)";
                      quit;

                    %end;
        %end;
    %end;

%do c = 1 %to &cntvar;

        %if %upcase(&var) eq %upcase(%Scan(&cat, &c," "))  %then %let catv = %Scan(&cat, &c," ");
        %if %upcase(&var) eq %upcase(%Scan(&noadj, &c," ")) %then %let nadj = %Scan(&noadj, &c," ");
        %if %upcase(&var) eq %upcase(%Scan(&fnlst, &c," ")) %then %let fn = &fn %Scan(&super, &c," ");
        %if %upcase(&var) eq %upcase(%Scan(&mdn, &c," ")) %then %let mdnv = %Scan(&mdn, &c," ");


%end;



%let vn=0;
%let numpoly = %numargs(&poly);


*** iterate through each exposure value in list;
%do i = &minexp %to &maxexp; /*1 %to &count;*/
%let vn=%eval(&vn+1);
%let mrow&i=;
%let srow&i=;
%let arow&i=;
%let brow&i=;
%let crow&i=;
%let nrow&i=;
%let n&i=;
%let val = %Scan(&expval, &vn," ");
%let var_lbl=;
%let lbl&i=;
%let lengthfmt =;

proc sql noprint;

%if %upcase(&var) ne %upcase(&catv) and %upcase(&var) ne %upcase(&nadj)
%then %do;
 select mn&i into :mrow&i from tab where upcase(varname)="%upcase(&var)";
 select std&i into :srow&i from tab where upcase(varname)="%upcase(&var)";
 select mdn&i into :arow&i from tab where upcase(varname)="%upcase(&var)";
 select min&i into :brow&i from tab where upcase(varname)="%upcase(&var)";
 select max&i into :crow&i from tab where upcase(varname)="%upcase(&var)";
 select label into :var_lbl from dsetcont where upcase(name) = %upcase("&var");
%end;

%if %upcase(&var) ne %upcase(&catv) and %upcase(&var) eq %upcase(&nadj)  %then %do;
 select mean(&var) into :mrow&i from table1dat where &exposure=&i;
 select std(&var) into :srow&i from table1dat where &exposure=&i;
 select label into :var_lbl from dsetcont where upcase(name) = %upcase("&var");
%end;

%if %upcase(&var) eq %upcase(&catv) and %upcase(&var) ne %upcase(&nadj) %then %do;
 select n&i into :nrow&i from tab where upcase(varname)="%upcase(&var)";
 select mn&i*100 into :mrow&i from tab where upcase(varname)="%upcase(&var)";
 select label /*cats(label,', %')*/ into :var_lbl from dsetcont where upcase(name) = "%upcase(&var)";
%end;

%if %upcase(&var) eq %upcase(&catv) and %upcase(&var) eq %upcase(&nadj) %then %do;
 select n(&var) into :nrow&i from table1dat where &exposure=&i;
 select mean(&var)*100 into :mrow&i from table1dat where &exposure=&i;
 select label /*cats(label,', %')*/ into :var_lbl from dsetcont where upcase(name) = "%upcase(&var)";
%end;

select %bquote(count(*)) FORMAT=40.0 into :n&i from table1dat where &exposure = &i;

select %bquote(label) into :lbl&i from frmts where upcase(fmtname) = "%upcase(&expfmt)" and startN <= &val <=endN;

quit;

%end;

%if &count > 5 or %eval(&count+&dec > 5) %then %do;
%let landscape = T;
%end;

%let nadjfn=;
%if "%upcase(&fn_noadj)" ne "" %then %do i = 1 %to %numargs(&fn_noadj);
  %if "%upcase(&var)" eq "%upcase(%scan(&fn_noadj, &i, %str( )))" %then %do;
  %let nadjfn = %str(^{super *});
 %end;
%end;

%*put var = nadj &var = &&nadj;


data allrows&v;
%do j = &minexp %to &maxexp; /* 1 %to &count;*/

 length value $ 256;



 %if "%upcase(&var)" ne "%upcase(&catv)" %then %do;
 value = cats("&var_lbl", "&nadjfn", "^{super &fn}");
 %end;

 %if "%upcase(&var)" eq "%upcase(&catv)" %then %do;
     %if "%upcase(&pctn)" eq "N" %then %do;
         value = cats("&var_lbl", "&nadjfn", "^{super &fn}",', n');
         %end;
     %if "%upcase(&pctn)" eq "PCTN" %then %do;
         value = cats("&var_lbl", "&nadjfn", "^{super &fn}",', %(n)');
         %end;
     %if "%upcase(&pctn)" eq "PCT" %then %do;
         value = cats("&var_lbl", "&nadjfn", "^{super &fn}",', %');
         %end;
 %end;


 tmp_n1 = symget("mrow&j");
 tmp_n2 = symget("srow&j");
 tmp_n3 = symget("arow&j");
 tmp_n4 = symget("brow&j");
 tmp_n5 = symget("crow&j");
 tmp_n6 = symget("nrow&j");

if &dec < 1 then do;

  if abs(tmp_n1) >= 1000 then do;
        tmp_n1b = round(tmp_n1);
        tmp_n2b = round(tmp_n2);
        tmp_n3b = round(tmp_n3);
        tmp_n4b = round(tmp_n4);
        tmp_n5b = round(tmp_n5);
        tmp_n1bcat = tmp_n1b;
        tmp_c1= put(tmp_n1b, 30.0 -C);
        tmp_c2= put(tmp_n2b, 30.0 -C);
        tmp_c3= put(tmp_n3b, 30.0 -C);
        tmp_c4= put(tmp_n4b, 30.0 -C);
        tmp_c5= put(tmp_n5b, 30.0 -C);
  end;
  else if abs(tmp_n1) >= 100 then do;
        tmp_n1b = round(tmp_n1,.1);
        tmp_n2b = round(tmp_n2,.1);
        tmp_n3b = round(tmp_n3,.1);
        tmp_n4b = round(tmp_n4,.1);
        tmp_n5b = round(tmp_n5,.1);
        tmp_n1bcat = round(tmp_n1);
        tmp_c1= put(tmp_n1b, 30.1 -C);
        tmp_c2= put(tmp_n2b, 30.1 -C);
        tmp_c3= put(tmp_n3b, 30.1 -C);
        tmp_c4= put(tmp_n4b, 30.1 -C);
        tmp_c5= put(tmp_n5b, 30.1 -C);
  end;
  else if abs(tmp_n1) >= 10 then do;
        tmp_n1b = round(tmp_n1,.01);
        tmp_n2b = round(tmp_n2,.01);
        tmp_n3b = round(tmp_n3,.01);
        tmp_n4b = round(tmp_n4,.01);
        tmp_n5b = round(tmp_n5,.01);
        tmp_n1bcat = round(tmp_n1);
        tmp_c1= put(tmp_n1b, 30.2 -C);
        tmp_c2= put(tmp_n2b, 30.2 -C);
        tmp_c3= put(tmp_n3b, 30.2 -C);
        tmp_c4= put(tmp_n4b, 30.2 -C);
        tmp_c5= put(tmp_n5b, 30.2 -C);
  end;
  else if abs(tmp_n1) >= 1 then do;
        tmp_n1b = round(tmp_n1,.001);
        tmp_n2b = round(tmp_n2,.001);
        tmp_n3b = round(tmp_n3,.001);
        tmp_n4b = round(tmp_n4,.001);
        tmp_n5b = round(tmp_n5,.001);
        tmp_n1bcat = round(tmp_n1);
        tmp_c1= put(tmp_n1b, 30.3 -C);
        tmp_c2= put(tmp_n2b, 30.3 -C);
        tmp_c3= put(tmp_n3b, 30.3 -C);
        tmp_c4= put(tmp_n4b, 30.3 -C);
        tmp_c5= put(tmp_n5b, 30.3 -C);
  end;
  else if abs(tmp_n1) >= 0 then do;
        tmp_n1b = round(tmp_n1,.0001);
        tmp_n2b = round(tmp_n2,.0001);
        tmp_n3b = round(tmp_n3,.0001);
        tmp_n4b = round(tmp_n4,.0001);
        tmp_n5b = round(tmp_n5,.0001);
        tmp_n1bcat = round(tmp_n1);
        tmp_c1= put(tmp_n1b, 30.4 -C);
        tmp_c2= put(tmp_n2b, 30.4 -C);
        tmp_c3= put(tmp_n3b, 30.4 -C);
        tmp_c4= put(tmp_n4b, 30.4 -C);
        tmp_c5= put(tmp_n5b, 30.4 -C);
  end;
 end;

if &dec >= 1 then do;
        tmp_n1b = round(tmp_n1, &dec_rnd);
        tmp_n1bcat = tmp_n1b;
        tmp_n2b = round(tmp_n2, &dec_rnd);
        tmp_n3b = round(tmp_n3, &dec_rnd);
        tmp_n4b = round(tmp_n4, &dec_rnd);
        tmp_n5b = round(tmp_n5, &dec_rnd);
        tmp_c1= put(tmp_n1b, 30.&dec -C);
        tmp_c2= put(tmp_n2b, 30.&dec -C);
        tmp_c3= put(tmp_n3b, 30.&dec -C);
        tmp_c4= put(tmp_n4b, 30.&dec -C);
        tmp_c5= put(tmp_n5b, 30.&dec -C);
end;

        tmp_n1bcat2=put(tmp_n1bcat, 30.&dec -C);
        tmp_n6cat =round(tmp_n6*tmp_n1/100);

if %upcase("&catv") ne %upcase("&var")  then do;
         if "%upcase(&sep)" eq "PM" then do;
         var&j = compbl(tmp_c1) || BYTE(177) || compbl(tmp_c2);
         end;
         if "%upcase(&sep)" eq "PAR" then do;
         var&j =TRIM(LEFT(tmp_c1))||" ("||TRIM(LEFT(tmp_c2))||")";
         end;
end;

if %upcase("&catv") eq %upcase("&var")  then do;
    if "%upcase(&pctn)" eq "N" then do;
        var&j=tmp_n6cat;
        end;
    if "%upcase(&pctn)" eq "PCTN" then do;
        /*var&j = compress(tmp_n1bcat2 || "(" || tmp_n6cat || ")");*/
        var&j =TRIM(LEFT(tmp_n1bcat2))||" ("||TRIM(LEFT(tmp_n6cat))||")";
        end;
    if "%upcase(&pctn)" eq "PCT" then do;
        var&j = put(tmp_n1bcat, 30.&dec -C);
        end;
end;

if  %upcase("&mdnv") eq %upcase("&var") then do;
    var&j = trim(left(tmp_c3))||" ("||trim(left(tmp_c4))||"," ||trim(left(tmp_c5))||")";
end;


/********  Format missing values for polytomous variables ******/
%if "&polycat" ne "" %then %do p1 = 1 %to %numargs(&allpoly);
 %if %upcase(%scan(&allpoly,&p1,%str( ))) = %upcase(&var) %then %do;
   value = '-    ' || value;
   %let mis=9999;
  %end;
%end;
%if "&polycat" ne "" %then %do p2 = 1 %to &polyord;
 %if %upcase(&var) = %upcase(_tmp&p2) %then %do;
 var&j = '00'x;
 %end;
%end;
%if "&poly" ne "" %then %do p3 =1 %to %numargs(&polylist);
 %if %upcase(%scan(&polylist,&p3,%str( ))) = %upcase(&var) %then %do;
  %let mis=9999;
 %end;
%end;
/********  End format missing values for polytomous varuiables ******/

if tmp_c1 = . and tmp_c3 = . then var&j = '00'x;

%if "%upcase(&multn)" ne "T" %then %do;
  %if "%upcase(&noexp)" ne "T" %then %do;
  label var&j = %sysfunc(cats("%unquote(&&lbl&j)", ' (n=', "%unquote(&&n&j)", ')' ));
  %end;
  %if "%upcase(&noexp)" eq "T" %then %do;
  label var&j = %sysfunc(cats(' (n=', "%unquote(&&n&j)", ')' ));
  %end;
%end;
%if "%upcase(&multn)" eq "T" %then %do;
  %if "%upcase(&noexp)" ne "T" %then %do;
  label var&j = %sysfunc(cats("%unquote(&&lbl&j)", ' (n\/N = ', "%unquote(&&exp_n&j)",' \/ ', "%unquote(&&n&j)", ')' ));
  %end;
  %if "%upcase(&noexp)" eq "T" %then %do;
  label var&j = %sysfunc(cats(' (n\/N = ', "%unquote(&&exp_n&j)",' \/ ', "%unquote(&&n&j)", ')' ));
%end;
%end;


 /**  set poly root = '' **/
 %if "&poly" ne "" %then %do p=1 %to &numpoly;
  %if "%upcase(%scan(&poly,&p," "))" = "%upcase(&var)" %then %do; var&j = ''; %end;
 %end;

%end;  /** end J loop **/

%if "%upcase(&miscol)" = "T" %then %do;
 if &mis ne 9999 then mis = put(&mis,4.1);
 else if "&mis" eq "9999" then mis = '00'x;
 label mis = 'Missing, %';
 /*format mis 4.1;*/
%end;

%*put varz = "&var";


drop tmp_n1
     tmp_n2
     tmp_c1
     tmp_c2
     tmp_n1b
     tmp_n2b
     tmp_n3
     tmp_n4
     tmp_n5
     tmp_c3
     tmp_c4
     tmp_c5
     tmp_n3b
     tmp_n4b
     tmp_n5b;

run;

proc append base = allrows data = allrows&v;
run;

%end;  /* end V loop */

data allrows;
set allrows;
label value = '00'x;
run;

title;

  *libname tmplt './';
  *ods path work.templat(update) sashelp.tmplmst(read);


proc template;
 define style Styles.Custom;
 parent = Styles.RTF;

replace Table from Output /
 frame = hsides  /* outside borders: void, box, above/below, vsides/hsides, lhs/rhs */
 rules = groups  /* internal borders: none, all, cols, rows, groups */
 cellpadding = 3pt /* the space between table cell contents and the cell border */
 cellspacing = 0pt /* the space between table cells, allows background to show */
 borderwidth = .75pt /* the width of the borders and rules */;

replace color_list /
 'link' = blue             /* links */
 'bgH'= white
 'fg' = black              /* text color */
 'bg' = white;             /* page background color */;

replace fonts /
 'TitleFont' = ("Times Roman",12pt)  /* Titles from TITLE statements */
 'TitleFont2' = ("Times Roman",12pt,Bold Italic) /* Procedure titles ("The _____ Procedure")*/
 'StrongFont' = ("Times Roman",10pt,Bold)
 'EmphasisFont' = ("Times Roman",10pt,Italic)
 'headingEmphasisFont' = ("Times Roman",11pt,Bold Italic)
 'headingFont' = ("Times Roman",12pt)       /* Table column and row headings */
 'docFont' = ("Times Roman",12pt)                /* Data in table cells */
 'footFont' = ("Times Roman",12pt)               /* Footnotes from FOOTNOTE statements */
 'FixedEmphasisFont' = ("Courier",9pt,Italic)
 'FixedStrongFont' = ("Courier",9pt,Bold)
 'FixedHeadingFont' = ("Courier",9pt,Bold)
 'BatchFixedFont' = ("Courier",6.7pt)
 'FixedFont' = ("Courier",9pt);

end;
run;


goptions reset=all;
options papersize=A4 %if %upcase(&landscape) = T %then %do; orientation=landscape %end;
%if %upcase(&landscape) ^= T %then %do; orientation=portrait %end;;

ods listing close;
ods rtf file=&file style=Custom;
ods escapechar='^';


proc report data = allrows nowd style(header)={just=LEFT} /*style(report)={outputwidth=6.5 in}*/;

column ("{\b Table 1 \b0 %str(&rtftitle)}" value ("%str(&explbl)" %do z = &minexp %to &maxexp /*1 %to &count*/; var&z
%end;
%if "%upcase(&miscol)" = "T" %then %do;
mis
%end;));
define value / display ' ' /*style(column)={cellwidth=2in}*/;
%do z = &minexp %to &maxexp; /*1 %to &count;*/
/*define var&z /  noprint*/;
define var&z / display;
%end;
run;
quit;


%if "%upcase(&sep)" = "PM" %then %do;
  %if "%upcase(&ageadj)" ne "F" %then %do;
    ODS rtf text =
    "^S={Font=('Times Roman',12pt)}Values are means %sysfunc(BYTE(177)) SD or percentages and are standardized to the age distribution of the study population.";
  %end;

  %if "%upcase(&ageadj)" eq "F" %then %do;
    ODS rtf text =
    "^S={Font=('Times Roman',12pt)}Values are means %sysfunc(BYTE(177)) SD or percentages.";
  %end;
%end;


%if "%upcase(&sep)" = "PAR" %then %do;
  %if "%upcase(&ageadj)" ne "F" %then %do;
  ODS rtf text =
  "^S={Font=('Times Roman',12pt)}Values are means(SD) or medians(Q25, Q75) for continuous variables; percentages or ns or both for categorical variables, and are standardized to the age distribution of the study population.";
%end;

  %if "%upcase(&ageadj)" eq "F" %then %do;
  ODS rtf text =
  "^S={Font=('Times Roman',12pt)}Values are medians (Minimum, Maximum) for continuous variables; percentages or Ns or both for categorical variables.";
  %end;
%end;


%if "&poly" ne "" or "&polycat" ne "" %then %do;
  ODS rtf text =
  "^S={Font=('Times Roman',12pt)} Values of polytomous variables may not sum to 100% due to rounding";
  %end;


%do z = 1 %to &fncnt;
ODS rtf text = "^{super %Scan(&super, &z," ")} &&fn&z";
%end;

%if "%upcase(&ageadj)" eq "T" and "%upcase(&fn_noadj)" ne "" %then %do;
ODS rtf text =
"^S={Font=('Times Roman',12pt)} ^{super *} Value is not age adjusted";
%end;



quit;

ods rtf close;
goptions reset=all;
ods listing;
quit;

proc datasets nolist;
  delete allrows;
  run;
  quit;

%mend;


/******************************************************************************/
/******************************************************************************/
/************************* Poly Means Macro ***********************************/
/******************************************************************************/
/******************************************************************************/

%macro polymeans(polyvars=, data=);

%local polyvars fmtname vlbl fmtvals fmtlbls minfmt maxfmt adjpoly;


%let pcount = 0;

***scan variable list to pcount # in list;
%do %while(%qscan(&polyvars, &pcount+1,%str( )) ne %str());
    %let pcount = %eval(&pcount+1);
%end;

%local polyorig;
%let polyorig = &polyvars;

%global polylist;
%let polylist = &polylist;

proc contents data = &data out = dsetcont noprint;

%do pol = 1 %to &pcount;

%let adjpoly=F;

%let polyvar = %Scan(&polyvars,&pol," ");

%if "&noadj" ne "" %then %do a = 1 %to %numargs(&noadj);
%if "%upcase(%scan(&noadj, &a, %str( )))" eq "%upcase(&polyvar)" %then %do;
  %let adjpoly = T;
 %end;
%end;


%let fmtname=;
%let vlbl=;
proc sql noprint;
select format into :fmtname from dsetcont where upcase(name) = "%upcase(&polyvar)";
select label into :vlbl from dsetcont where %upcase(name) = "%upcase(&polyvar)";
quit;

proc format cntlout=frmts;


%let fmtvals=;
%let fmtlbls=;
%let minfmt=;
%let maxfmt=;

proc sql noprint;
select start into :fmtvals from frmts where upcase(fmtname) = "%upcase(&fmtname)";
select label into :fmtlbls separated by "^^^" from frmts where upcase(fmtname) = "%upcase(&fmtname)";
select min(start) into :minfmt from frmts where upcase(fmtname) = "%upcase(&fmtname)";
select max(start) into :maxfmt from frmts where upcase(fmtname) = "%upcase(&fmtname)";
quit;

%let minfmt = %sysfunc(compbl(&minfmt));
%let maxfmt = %sysfunc(compbl(&maxfmt));

%let fmtlbls&pol=&fmtlbls;

%let plst =;

%if &pol=1 %then %do;
   %let polorig_S = %sysfunc(compbl(&minfmt));
   %let polorig_E = %sysfunc(compbl(&maxfmt));
%end;
%if &pol>1 %then %do;
   %let polorig_S = %sysfunc(compbl(&polorig_S &minfmt));
   %let polorig_E = %sysfunc(compbl(&polorig_E &maxfmt));
%end;


%do j = &minfmt %to &maxfmt;
    %let mgt0 = 0;
    %let polylist = &polylist _tmp&pol._&j;

   proc sql noprint;
     select mean(&polyvar) into :mgt0 from &data having &polyvar = &j;
   quit;

    %if &mgt0 > 0 %then %do; %let plst = &plst _tmp&pol._&j; %end;
%end;

%if &pol=1 %then %do;
  %let polyarray = %sysfunc(compbl(%str(array &polyvar._a {*} _tmp&pol._&minfmt - _tmp&pol._&maxfmt;)));
  %let parrayname = %sysfunc(compbl(&polyvar._a{j}));
  %let parraynum = %sysfunc(compbl(%eval(&maxfmt - &minfmt + 1)));
%end;
%if &pol>1 %then %do;
  %let polyarray = &polyarray %sysfunc(compbl(%str(array &polyvar._a {*} _tmp&pol._&minfmt - _tmp&pol._&maxfmt;)));
  %let parrayname = %sysfunc(compbl(&parrayname &polyvar._a{j}));
  %let parraynum = %sysfunc(compbl(&parraynum %eval(&maxfmt - &minfmt + 1)));
%end;

%if &pol=1 %then %do; %let v1=%numargs(&varlist); %let tmpvarlist=; %let startvar=1; %end;
%if &pol > 1 %then %do; %let v1=%numargs(&varlist); %end;

%let stopvar=0;
%do vlst = &startvar %to &v1;

  %if &stopvar=0 and "%upcase(%scan(&varlist, &vlst, %str( )))" ne "%upcase(&polyvar)" %then %do;
  %let tmpvarlist = &tmpvarlist %scan(&varlist, &vlst, %str( ));
  %end;


  %if &stopvar=0 and "%upcase(%scan(&varlist, &vlst, %str( )))" eq "%upcase(&polyvar)" %then %do;
  %let tmpvarlist = &tmpvarlist %scan(&varlist, &vlst, %str( )) &plst;
  %let cat = &cat &plst;


  %if "%upcase(&adjpoly)" = "T" %then %do;
     %let noadj = &noadj &plst;
  %end;

  %if &pol < &pcount %then %do;  %let stopvar=1; %let startvar=%eval(&vlst+1); %end;

    %end;

  %end;
%end;

/*%put pazaris polyorig=&polyorig  polyarray = &polyarray parrayname = &parrayname parraynum =&parraynum;
varlist=&varlist cat=&cat plst=&plst polorig_S=&polorig_S polorig_E=&polorig_E */

%let varlist = &tmpvarlist;


data &data;
set &data;
  array origvar {*} &polyorig;
  &polyarray;

    %do i = 1 %to %numargs(&polyorig);
      numto = (scan("&parraynum",&i," "));
       do j = 1 to numto;
         if ^missing(origvar{&i}) then %scan("&parrayname", &i, " ") = 0;
         if origvar{&i}=j then %scan("&parrayname", &i, " ") = 1;
       end;

       %do k = 1 %to %scan("&parraynum",&i," ");
         label _tmp&i._&k = "-    %scan(&&fmtlbls&i, &k, %str(^^^))";
       %end;

    %end;
run;

%mend;

/********************************************************************************/
/************************* end poly means macro *********************************/
/********************************************************************************/
/************************* start poly cat macro *********************************/
/********************************************************************************/

%macro polycatset();

%global allpoly polyord;

%let polyord=0;
%let polycnt=0;
%let allpoly=;

%let polycatcnt=0;
***scan variable list to polycat # in list;
%do %while(%qscan(&polycat, &polycatcnt+1,%str(@)) ne %str());
    %let polycatcnt = %eval(&polycatcnt+1);
%end;

%let polystr=;


%do i = 1 %to &polycatcnt;
%let indexcat =;
%let adjrem =;
%let polystr=%Scan(&polycat,&i,"@");
%let polylbl&i=%Scan(&polystr,1,"$");
%let polycv=%Scan(&polystr,2,"$");


%let allpoly = &allpoly &polycv;

%let polyord = %scan(&polystr,1,%str( ));
%if &i eq 1 %then %do; %let polyord2 = &polyord; %end;
%if &i ne 1 %then %do; %let polyord2 = %eval(&polyord + &polycnt); %end;


%let polylbl&i =
%sysfunc(compbl(%substr(&&polylbl&i,%eval(%length(&polyord)+1),%eval(%length(&&polylbl&i)-%length(&polyord)))));
%let polycnt = %eval(%numargs(&polycv) + &polycnt);

%let varcnt = %numargs(&varlist);

%do z = 1 %to %numargs(&polycv);
%let tmpv = %Scan(&polycv,&z,%str( ));

    %macro skip;
    data &data;
    set &data;
     /*label &tmpv = "-    ";*/
     run;
    %mend;

%end;

   /* Create list of no-adjustment variables for not adjusted footnote */
   %let indexcat = %index(%upcase(&fn_noadj), %upcase(&polycv));
   %if &indexcat > 0 %then %let adjrem = %substr(&fn_noadj, &indexcat, %length(&polycv));
   %if &indexcat = 1 and (%eval(&indexcat+%length(&polycv)-1) = %length(&fn_noadj)) %then %let fn_noadj = _tmp&i;

%let index1 = %eval(&indexcat+%length(&polycv);
%let index2 = %length(&fn_noadj);
%*put index 1 is &index1 and index2 is &index2;

   %if &indexcat = 1 and (%eval(&indexcat+%length(&polycv)-1) < %length(&fn_noadj)) %then %let fn_noadj =
_tmp&i %substr(&fn_noadj, %eval(&indexcat+%length(&polycv)-1));


   %if &indexcat > 1 %then %let fn_noadj = _tmp&i %substr(&fn_noadj, 1, %eval(&indexcat-1)) %substr(&fn_noadj, %eval(&indexcat+%length(&polycv)-1));


   %if %length(&fn_noadj) > 0 %then %let fn_noadj = %sysfunc(compbl(&fn_noadj));


%let varlist2 =;
%do z2 = 1 %to &varcnt;
 %if &z2 ne &polyord2 %then %do;
  %let varlist2 = &varlist2 %scan(&varlist,&z2, %str( ));
 %end;
%if &z2 eq &polyord2 %then %do;
  %let varlist2 = &varlist2 _tmp&i &polycv %scan(&varlist, &z2, %str( ));
 %end;
%end;
%if &polyord2 > &varcnt %then %do;
  %let varlist2 = &varlist2 _tmp&i &polycv;
%end;

%put polyord2 = &polyord2 varcnt = &varcnt varlist = &varlist varlist2 = &varlist2;

%let varlist = &varlist2;

%let cat = &cat &polycv;

%end;


/** M. Pazaris rearanged to avoide multiple datastep sets **/
data &data;
set &data;
 %do i2 = 1 %to &polycatcnt;
   _tmp&i2=.;
   label _tmp&i2="&&polylbl&i2";
%end;
run;


%mend;


/********************************************************************************/
/************************* end poly cat macro ***********************************/
/********************************************************************************/


/*This program was designed to compute direct standardization of
  rates, means, or proportions.  Specifically, Table 1 of many papers
  is a breakdown of cohort characteristics by exposure categories. In
  most instances, it is necessary to age-standardize the means or
  proportions of other potential confounders before displaying them
  by exposure category.


 changes from eric's program:
  requires exposure to be nonmissing
  allows more than 1 vbl in covar list

  computes std dev on weighted original data.  this estimates
  the std the group would have if it had had the same age distribution
  as the standard.
  also computes std error of the standardized mean.  this assumes that
  the weights relating to the means are constants, and that we do not
  take the between-age-group variance into account.
  */


%macro table1(data     =,
              ageadj   =T,
              exposure =,
              noexp    =F,
              agegroup =,
              varlist  =,
              header   =,
              missing  =.,
              covar    =,
              printvar =mean std se ,
              extstand =,
              explab   =,
              label0   =level 0,
              label1   =level 1,
              label2   =level 2,
              label3   =level 3,
              label4   =level 4,
              label5   =level 5,
              label6   =level 6,
              label7   =level 7,
              label8   =level 8,
              label9   =level 9,
              label10  =level 10,
              label11  =level 11,
              label12  =level 12,
              label13  =level 13,
              label14  =level 14,
              label15  =level 15,
              notes    =nonotes,

              /*** rtf options ***/
              nortf    =F,
              noadj    =,
              cat      =,
              rtftitle =,
              landscape=F,
              fn       =,
              uselbl   =F,
              file     =,
              miscol   =F,
              poly     =,
              mdn      =,
              polycat  =,
              fmtlib   =work,
              fmtcat   =formats,
              multn    =F,
              id       =id,
              sep      = par,
              pctn     =pct,
              dec      =0);


  options &notes;



/**** resort poly needs to match order of varlist ****/

%if &varlist ne  and &poly ne %then %do;

%let varlist = %sysfunc(compbl(&varlist));
%let poly = %sysfunc(compbl(&poly));

%let newpoly =;
%let vpv=;
%let vpp=;

%do i = 1 %to %numargs(&varlist);
       %let vpv=%scan(&varlist, &i, %str( ));
     %do j = 1 %to %numargs(&poly);
        %let vpp=%scan(&poly, &j, %str( ));
           %if "%upcase(&vpv)" = "%upcase(&vpp)" %then %do;
                 %let newpoly = &newpoly &vpv;
           %end;
     %end;
   %end;

%let poly = &newpoly;
%end;


/**** end resort poly needs to match order of varlist ****/

/* table1 can't be age-adjusted if noexp=T*/
%if %str(%upcase(&noexp)) eq %str(T) %then %let ageadj=F;


/******** TEST FOR MISSING VARIABLES IN VARLIST *********************/
proc contents data = &data out = _tmp_vcol_ noprint;
run;

%let missingvar =;

%do i = 1 %to %numargs(&varlist);
  %let var2chk = %scan(&varlist, &i, %str( ));
  %let varnumchk =;

      proc sql noprint;
         select varnum into:varnumchk from _tmp_vcol_
         having /*upcase(memname)=upcase("&data") and*/ upcase(name) = upcase("&var2chk");
      quit;

    %if "&varnumchk" eq "" %then %do; %let missingvar = &missingvar &var2chk; %end;

%*put pazaris test varnumchk = &varnumchk;

%end;
/******** END TEST FOR MISSING VARIABLES IN VARLIST *****************/




/******** TEST FOR DUPLICATE VARIABLES IN VARLIST *********************/
%let dupvalue =;
%do k1 = 1 %to %eval(%numargs(&varlist)-1);
  %let firstvar = %scan(&varlist, &k1, %str( ));
     %do k2 = %eval(&k1+1) %to %numargs(&varlist);
          %let secondvar = %scan(&varlist, &k2, %str( ));
              %if %upcase(&firstvar) = %upcase(&secondvar) %then %do;
                  %let dupvalue = &dupvalue &firstvar;
               %end;
     %end;
%end;

/******** END TEST FOR DUPLICATE VARIABLES IN VARLIST *****************/




proc format library= &fmtlib..&fmtcat;
value _tbl1_fmt_creat_val_ 1='yes' 2='no';

proc format library = &fmtlib..&fmtcat cntlout=frmtschg;


data frmtschg;
length label $ 100;
set frmtschg;
run;

data frmtschg;
length label $ 100;
set frmtschg;
 label   = prxchange("s/,/BYTE(130)/", -1, label);
run;


proc format library = &fmtlib..&fmtcat cntlin=frmtschg;
run;

%let errcall = 0;
%if %str(&data) = %str() %then %do;
%put ERROR: You did not provide a data-set name.;
%goto exit;
%end;

%if %str(%upcase(&noexp)) ne %str(T) and %str(&exposure) = %str() %then %do;
%put ERROR: You did not provide an exposure variable.;
%put ERROR: If you do not want an exposure, please set noexp=T.;
%goto exit;
%end;

%if %str(%upcase(&noexp)) ne %str(T) and %numargs(&exposure) > 1 %then %do;
%put ERROR: You can only have one exposure variable.;
%goto exit;
%end;

%if %str(&agegroup) = %str() and ((%str(%upcase(&ageadj)) ne %str(F)) and (%str(%upcase(&noexp)) ne %str(T)))  %then %do;
%put ERROR: You did not provide a varaiable for age-adjustment.;
%goto exit;
%end;

%if %str(&file) = %str() and %str(%upcase(&nortf)) ne %str(T) %then %do;
%put ERROR: You did not provide a file name for the MS Word table.;
%goto exit;
%end;

%if %str(&varlist) = %str() %then %do;
%put ERROR: You did not provide a list of variables.;
%goto exit;
%end;

%if %numargs(&varlist) = 1 %then %do;
%put ERROR: You need to provide more than one variable in varlist.;
%goto exit;
%end;

%if "&missingvar" ne ""  %then %do;
%put ERROR: You have included nonexistent variable(s) &missingvar in the table1 call.;
%goto exit;
%end;

%if "&dupvalue" ne ""  %then %do;
%put ERROR: You have included duplicate variable(s) &dupvalue in the table1 call.;
%goto exit;
%end;

/******* test for 0,1  coding for categorical variables *************/
%do c = 1 %to %numargs(&cat);
%let cvariable = %scan(&cat, &c, %str( ));
%let minc=;
%let maxc=;
 proc sql noprint;
    select min(&cvariable) into:minc from &data;
    select max(&cvariable) into:maxc from &data;
 quit;

%if &minc ne 0 or &maxc ne 1 %then %do;
  %put ERROR: categorical variables must be coded 0 1.;
  %put ERROR: variable &cvariable is coded as &minc &maxc.;
 %goto exit;
 %end;
%end;
/******* end test for 0,1  coding for categorical variables ********/

/******* test for noadj for age adjusted distributions *************/
%let noadjmdn =;
%do k1 = 1 %to %numargs(&mdn);
  %let mdnvar = %scan(&mdn, &k1, %str( ));
     %do k2 = 1 %to %numargs(&noadj);
          %let noadjvar = %scan(&noadj, &k2, %str( ));
              %if %upcase(&mdnvar) = %upcase(&noadjvar) %then %do;
                  %let noadjmdn = &noadjmdn &noadjvar;
               %end;
     %end;
%end;

%if "&noadjmdn" ne ""  %then %do;
%put ERROR: Remove &noadjmdn from mdn= Do a separate table1 macro call for &noadjmdn without age adjustment.;
%goto exit;
%end;
/******* end: test for noadj for age adjusted distributions *************/

%let dec_rnd = %sysevalf(1 * 10**-&dec);

/*****************************************************/
data tbl1adj;
set &data;
%if "%upcase(&ageadj)" = "F" %then %do; t1agegrp=1; %end; /* if table is not to be age
adjusted, set age adjustment variable to 1 */

%if "%upcase(&noexp)" = "T" %then %do; t1defaultexp=1; label t1defaultexp='00'x; %end; /* create dummy default exposure if no exposure
requested */
run;

%if "%upcase(&ageadj)" = "F" %then %do; %let agegroup=t1agegrp; %end;
%let data = tbl1adj;
/*****************************************************/

%if %str(&varlist) ne %str() %then %let varlist=%sysfunc(compbl(&varlist));
%if %str(&covar)   ne %str() %then %let covar  =%sysfunc(compbl(&covar));
%if %str(&noadj)   ne %str() %then %let noadj  =%sysfunc(compbl(&noadj));
%if %str(&cat)     ne %str() %then %let cat    =%sysfunc(compbl(&cat));
%if %str(&poly)    ne %str() %then %let poly   =%sysfunc(compbl(&poly));
%if %str(&polycat) ne %str() %then %let polycat=%sysfunc(compbl(&polycat));
%if %str(&mdn)     ne %str() %then %let mdn    =%sysfunc(compbl(&mdn));




%macro changelist(list=, listm=, datarename=);
%let list2 =;
%do i = 1 %to %numargs(&list);
   %if "%upcase(%scan(&list, &i, %str( )))" = "CASE" %then %do;
      %let list2 = &list2 _case;
      %let tmplbl =;

        %if "%upcase(&datarename)" = "T" %then %do;
            data &data;
            set &data;
         call symput('tmplbl', vlabel(%scan(&list, &i, %str( ))));
        run;

           data &data;
           set &data;
           _case = case;
         label _case = " &tmplbl";
           run;
        %end;
    %end;
     %if "%upcase(%scan(&list, &i, %str( )))" ne "CASE" %then %do;
        %let list2 = &list2 %scan(&list, &i, %str( ));
      %end;
  %end;
%let &listm = &list2;

%mend changelist;



%changelist(list=&agegroup, listm=agegroup, datarename=T);
%changelist(list=&exposure, listm=exposure, datarename=T);
%changelist(list=&varlist , listm=varlist , datarename=T);
%changelist(list=&cat     , listm=cat     , datarename=F);
%changelist(list=&poly    , listm=poly    , datarename=F);
%changelist(list=&polycat , listm=polycat , datarename=T);
%changelist(list=&mdn     , listm=mdn     , datarename=F);

/******* check to make sure poly variable is in varlist *****/

%if "&poly" ne "" %then %do pv = 1 %to %numargs(&poly);
%let polyvarerr=0;
 %let plyvar = %scan(&poly, &pv, %str( ));
  %do pv2 = 1 %to %numargs(&varlist);
    %if %upcase(&plyvar) = %upcase(%scan(&varlist, &pv2, %str( ))) %then %let polyvarerr=1;
  %end;

  %if &polyvarerr=0 %then %do;
     %put ERROR: all poly variables must be in varlist in order to determine table1 variable order.;
     %put ERROR: poly variable &plyvar was not found in varlist.;
     *%goto exit;
   %end;
%end;

%if &errcall = 1 %then %goto exit;

/**********************  Check poly formats *********************/

        proc contents data = &data out = dset4miss noprint;

        proc format library = &fmtlib..&fmtcat cntlout=fm4miss;
         data fm4miss;
          set fm4miss;
            startN = int(start); /* start * 1.0;*/
            endN = int(end); /*end * 1.0;*/
          run;


%if "&poly" ne "" %then %do p = 1 %to %numargs(&poly);
%let ptstvar = %scan(&poly, &p, %str( ));
%let minptv =;
%let maxptv =;
proc sql noprint;
select min(&ptstvar) into :minptv from &data where ^missing(&ptstvar);
select max(&ptstvar) into :maxptv from &data where ^missing(&ptstvar);
quit;

%*put mpazaris pts test ptstvar = &ptstvar minptv = &minptv maxptv = &maxptv;

   %*if &minptv ^= 1 %then %do;
    %*put ERROR poly variables lowest value must be 1;
    %*put the lowest value for &ptstvar is &minptv;
   %*let errcall = 1;
   %*end;

                  %let fmt4miss=;
                  proc sql noprint;
                   select upcase(format) into :fmt4miss from dset4miss where upcase(name) = "%upcase(&ptstvar)";
                  quit;

             /*%if &minptv = 1 %then*/ %do mm = 1 %to &maxptv;
                  %let missfmt = ;
                    proc sql noprint;
                     select fmtname into :missfmt from fm4miss where upcase(fmtname) = "%upcase(&fmt4miss)" and startN = &mm;
                    quit;

                  %if "&missfmt" = "" %then %do;
                   %put ERROR: poly variables must be formated consecutively starting at 1.;
                   %put ERROR: there is no format for level &mm for variable &ptstvar.;
                    *%goto exit;
                   %end;
                %end;


%end;

%if &errcall = 1 %then %goto exit;

/*  end check poly formats */

%let fn_noadj = &noadj;

%if %length(&rtftitle) > 0 %then %let rtftitle = %sysfunc(compbl(&rtftitle));
%if %length(&fn) > 0 %then %let fn = %sysfunc(compbl(&fn));


%makefn();


/********************* create polytomous variables *****************/

/* create  polytomous variables automatically when supplied with a ordinal variable */
%if "&poly" ne "" %then %do; %polymeans(polyvars=&poly, data=&data); %end;

/* use list of pre-defined polytomous variables */
%if "&polycat" ne "" %then %do; %polycatset(); %end;


/********************* end create polytomous variables *****************/





%if "%upcase(&noexp)" = "T" %then %do; %let exposure=t1defaultexp; %let ageadj=F; %end;



   options &notes;

%local nvar i _minexp_ _maxexp_ _nlev_ ;
%let nvar=%numargs(&varlist);


/* this is the analysis data set.  no COVAR missing, no exposure missing  */
data _tmp_;
   set &data;
   where &exposure ne &missing;
   %if "&covar" ne "" %then %do;
      if nmiss(of &covar) eq 0;
      %end;
   run;


/* this gets the levels of exposure, assuming they go by 1 from minexp to maxexp */
proc means noprint data=_tmp_;
var &exposure;
   output  out=_minmax_  min=minexp  max=maxexp;
   run;

data _minmax_;
set _minmax_;
   call symput('_minexp_', trim(left(minexp)));
   call symput('_maxexp_', trim(left(maxexp)));
   nlev=1+maxexp-minexp;
   call symput('_nlev_',trim(left(nlev)));
   run;

/* if not using an external standard age distribution */
/* then mainfreq is the age distribution of the whole study population */
%if %length(&extstand) eq 0 %then %do;
proc freq data=_tmp_;
   tables &agegroup/noprint out=mainfreq;
   run;


data mainfreq;
set mainfreq;
pctov=percent;
   keep pctov &agegroup;
   run;
/* remember that pctov is a percent, not a fraction */
%end;

/* using an external standard age distribution.
data set must have variables &agegroup and pctov (as a percent) */
%if %length(&extstand) ne 0 %then %do;
   data mainfreq;
   set &extstand;
   keep pctov &agegroup;
   run;
%end;

proc sort data=_tmp_;
by &exposure;
run;

/* this is to get the actual fractions of each exposure level in each age group */
proc freq data=_tmp_;
tables &agegroup / out=_tmp1_ noprint;
by &exposure;
run;

data _tmp1_;
set _tmp1_;
pctexp=percent;
keep pctexp &agegroup &exposure;
run;

proc sort data=_tmp1_;
by &agegroup;
run;

proc sort data=_tmp_;
by &agegroup &exposure;
run;

proc sort data=mainfreq;
by &agegroup;
run;


data _tmp1_;
merge
mainfreq
_tmp1_
;
by &agegroup;
   if pctexp gt 0 then wgt=pctov/pctexp;
   else do;
      put "WARNING from macro:  No observations in agegroup &agegroup , exposure level &exposure .";
      file print;
      put "WARNING from macro:  No observations in agegroup &agegroup , exposure level &exposure .";
      end;
run;


proc sort data=_tmp1_;
by &agegroup &exposure;
run;

data _tmp_;
merge
_tmp1_
_tmp_
;
by &agegroup &exposure;
run;

/* this gets standardized means and standard deviation assuming the
group had the age distribution of the standard population */
proc sort data=_tmp_;
by &exposure &agegroup;
run;

proc means noprint data=_tmp_ n mean std median min max;
  var &varlist;  weight wgt;  by &exposure;
   output  out=_stdm_
      %if &nvar eq 1 %then %do;
         mean=mean  std=std  n=n  median=median min=min max=max;
         %end;
   %else %do;
      mean=mean1-mean&nvar  std=std1-std&nvar   n=n1-n&nvar
      median=median1-median&nvar min=min1-min&nvar max=max1-max&nvar  ;
      %end;
   run;


/* now get std errors */
proc means noprint data=_tmp_;
var &varlist;
output  out=descrips
  %if &nvar eq 1 %then %do;  std=std;  %end;
  %else %do;  std=std1-std&nvar;  %end;
by &exposure &agegroup;
run;

proc sort data=descrips;
by &agegroup;
run;

data descrips;
merge
descrips
mainfreq
;
by &agegroup;
  wtse=pctov*pctov/10000;
%if &nvar eq 1 %then %do;  s1=std1*std1*wtse;  %end;
%else %do;
  array stds{*} std1-std&nvar;
  array summands{*}  s1-s&nvar;
  do i=1 to dim(stds);  summands{i}=wtse*stds{i}*stds{i};  end;
%end;
run;

proc sort;
by &exposure;
run;


proc means noprint data=descrips;
  %if &nvar eq 1 %then %do;  var s1;
    output  out=stderrsq  sum=v1;
  %end;
  %else %do;  var s1 - s&nvar ;
    output  out=stderrsq  sum=v1 - v&nvar ;
  %end;
by &exposure;
run;

data stderrsq;
set
stderrsq
;
%if &nvar eq 1 %then %do;  if v1 gt 0 then se1=sqrt(v1);  %end;
%else %do;
  array vs{*} v1-v&nvar;
  array ses{*} se1-se&nvar;
  %do i=1 %to &nvar;  if vs{&i} gt 0 then ses{&i}=sqrt(vs{&i});  %end;
%end;
keep &exposure
  %if &nvar eq 1 %then %do;  se1 ;  %end;
  %else %do;  se1 - se&nvar ;  %end;
run;

 /* doing rounding and putting out one obs per variable */
data _stdm_;
merge
_stdm_
stderrsq
;
by &exposure;
length varname $32 /*$20*/;
%if &nvar eq 1 %then %do;
  varname=trim("&varlist");

%end;
%else %do;
   array ns{*}  n1-n&nvar;
   array mns{*}  mean1-mean&nvar;
   array stds{*}  std1-std&nvar;
   array ses{*}  se1-se&nvar;
   array mdns{*}  median1-median&nvar;
   array mins{*}  min1-min&nvar;
   array maxs{*}  max1-max&nvar;

  %do i=1 %to &nvar;

varname=trim(left("%scan(&varlist, &i, %str( ))"));
   ord=.;
   ord=trim(left(&i));
   n=trim(left(ns{&i}));
   mean=trim(left(mns{&i}));
   std=trim(left(stds{&i}));
   se=trim(left(ses{&i}));
   median=trim(left(mdns{&i}));
   min=trim(left(mins{&i}));
   max=trim(left(maxs{&i}));
   output;
  %end;
%end;
keep &exposure varname n mean std se median min max ord ;
   run;


proc sort data=_stdm_;
by ord varname &exposure;


data _stdm_;
set _stdm_;
   minexp=.;
   maxexp=.;
   minexp=&_minexp_;
   maxexp=&_maxexp_;
   array ns{&_minexp_ : &_maxexp_} n&_minexp_ - n&_maxexp_;
   array mns{&_minexp_ : &_maxexp_}  mn&_minexp_ - mn&_maxexp_;
   array stds{&_minexp_ : &_maxexp_}  std&_minexp_ - std&_maxexp_;
   array ses{&_minexp_ : &_maxexp_}  se&_minexp_ - se&_maxexp_;
   array mdns{&_minexp_ : &_maxexp_}  mdn&_minexp_ - mdn&_maxexp_;
   array mins{&_minexp_ : &_maxexp_}  min&_minexp_ - min&_maxexp_;
   array maxs{&_minexp_ : &_maxexp_}  max&_minexp_ - max&_maxexp_;

   %do i=&_minexp_ %to &_maxexp_;  i=&i;
      if &exposure eq i then do;
         ns{i}=n;
         mns{i}=mean;
         stds{i}=std;
         ses{i}=se ;
         mdns{i}=median;
         mins{i}=min;
         maxs{i}=max;
      end;
    %end;
   %do i=&_minexp_ %to &_maxexp_;
      label n&i="&&label&i  n"
            mn&i="&&label&i  mean"
            std&i="&&label&i  standard dev"
            se&i="&&label&i  standard error"
            mdn&i="&&label&i  median"
            min&i="&&label&i min"
            max&i="&&label&i max"
             ;
    %end;
run;

proc means noprint data=_stdm_;
var %do i=&_minexp_ %to &_maxexp_;  n&i mn&i std&i se&i mdn&i min&i max&i %end;
;
output  out=tab  mean=;
by ord varname;
run;



%if %str(%upcase(&nortf)) eq %str(T) %then %do;
   options notes;
title5 "Table 1:  &header";
%if "&explab" ne "" %then %do;
   title6 "&explab";
%end;
proc print label data=tab noobs;  var varname
%do i=&_minexp_ %to &_maxexp_;
     n&i mn&i std&i se&i mdn&i min&i max&i
%end;
;


   run;

   options &notes;
   title5 " ";

%end;

   options notes;

%if "%upcase(&nortf)" = "T" %then %goto exit;
%t1rtf(data      = &data,
       exposure  = &exposure,
       varlist   = &varlist,
       noadj     = &noadj,
       cat       = &cat,
       mdn       = &mdn,
       rtftitle  = &rtftitle,
       landscape = &landscape,
       fn        = &fn,
       uselbl    = &uselbl,
       file      = &file,
       dec       = &dec,
       dec_rnd   = &dec_rnd);

goptions reset=all;

proc datasets nolist;
  delete
  descrips
  Null
  table1dat
  dsetcont
  frmts
  allrows:
  tbl1adj
  _tmp_tbl1_dat_
  _tmp_
  _minmax_
  mainfreq
  _tmp1_
  descrips
  stderrsq
  _stdm_
  tab
  ;

run;


%goto exit;
%exit:

%mend;