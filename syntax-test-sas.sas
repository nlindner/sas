%macro Calc_Membership_Standard(Filt_HealthplanId = 1);

   proc sql feedback exitcode;
   /*       ^support.function.sqloptions.sas */
      %connectToDBMS(ClaimDB);
   /*  ^support.function.macrocall.sas */

      CREATE TABLE work.TEMP_ClaimDB_&TableSuffix. AS
   /*                                ^variable.parameter.macro.sas */
      SELECT 
          HealthPlan_Id
         ,IPAdmit_Qty
         ,Claim_Qty
         ,N_Member
         ,CASE 
            WHEN Claim_Qty > 0 THEN ROUND(IPAdmit_Qty/Claim_Qty,.0000000001)
            ELSE . 
          END AS IPAdmit_Pct
      FROM CONNECTION TO ClaimDB (
   /*      ^support.function.fromconnection.sas */
   /*                    ^keyword.emphasis.connection.sas */
         SELECT
             fMEM.HealthPlan_Id
            ,fMEM.Incurred_Month
            ,SUM(fCLM.IPAdmit_Qty) AS IPAdmit_Qty
            ,SUM(fCLM.Claim_Qty) AS Claim_Qty
            ,COUNT(DISTINCT CASE 
               WHEN &Is_Nonengaged THEN CAST(NULL AS INT)
               ELSE fMem.Member_Id
             END) as N_Member

         FROM 
            &evalTable fCLM
            INNER JOIN dbo.Member_Months fMEM
               ON  fMEM.Member_Id = fCLM.Member_Id 
               AND fMem.Incurred_Month = 
                  CONVERT(DATE, DATEADD(day, 1-day(fClm.Claim_Paid_Date), fClm.Claim_Paid_Date))
         WHERE 
            fMEM.Healthplan_id = &Filt_HealthplanId
         GROUP BY 
             fMEM.HealthPlan_Id
            ,fMEM.Incurred_Month
      );
      reset exec noerrorstop errorstop;
   /* ^support.function.sqloptions.sas */
   quit;

   %put %sysfunc(COMPBL(* retrieving &type column names for table &Table ...));

%mend;

/* WISHLIST: separate keywords like column and table from 
   ones that can be called within a %sysfunc(),  within a macro, or within a datastep */
   %put %sysfunc(COMPBL(* retrieving &type column names for table &Table ...));

data work.blah;
   set work.blah;
   format rownum 8.;
   rownum = _n_;
run;


/*
   WISHLIST: This is invalid outside of macro. Would like to separate out
   different KINDS of keywords for the syntax highlighting.*/
   %if (1=0) 
   %then %do;
      %let nml = blah;
      %put * nml=&nml;
   %end;


DATA Temp(DROP=User_Agent User_ID Session_Created_BY Session_Last_Update_Date 
      Session_Creation_Date Task_Creation_Date Session_Status);
   INFORMAT Task_Creation_Date Session_Date Session_Creation_Date 
      Session_Last_Update_Date DATETIME20.;
/*                             ^constant.numeric.dateformat.I.sas */      
   FORMAT Task_Creation_Date Session_Date Session_Creation_Date Session_Last_Update_Date DATETIME20.;
/* ^keyword.datastep.sas */
  INFILE raw(sessionTasks.txt)   DELIMITER='09'x LRECL=2000 FIRSTOBS  =  2;
  INPUT  Session_ID Task_Number Task_ID :$20. Task_URL :$128. User_Agent :$16.
   Study_URL :$48. Task_Status   $ Task_Sequence    $ Task_Creation_Date:ANYDTDTM21. 
   User_ID Study_Name :$64. Session_Date :ANYDTDTM21. Session_Status:$4. 
   Session_Creation_Date : ANYDTDTM21. Session_Created_By :$24. 
   Session_Last_Update_Date :ANYDTDTM21.;
RUN;  

ods html close;
ods html path=WebOut FILE="Prep.SessTask.01.Raw.TaskID.htm";
proc contents 
   data=temp;
run;

%let sourceRoot = C:\Users\Nicole\Documents\SAS;
%let macroRoot = &sourceRoot\MacroLib;
/*               ^variable.parameter.macro.sas */
%let appName = SampleCode;
%let appLevel = prod;
%include "&macroRoot\utility\utility__*.sas"  /lrecl=4096;
%include "&sourceRoot\&appName\&appLevel\main_batch.sas"  /lrecl=4096;


%LET Filter_ClaimDt_Bgn_SAS = %SYSFUNC(intnx(WEEK
   ,%SYSFUNC(INTNX(MONTH,%eval(%SYSFUNC(today()) - 1),-60,S))
   ,0,BEGINNING));

%LET Filter_ClaimDt_Bgn_SQL = %SYSFUNC(putn(&Filter_ClaimDt_Bgn_SAS,YYMMDDD10.));
%put Filter_ClaimDt_Bgn_SQL=&Filter_CntctDt_Bgn_SQL;

proc freq data = Temp; 
   tables Task_URL;
/* ^support.function.sas, support.class.sas */
run;

data Temp; 
   set Temp;
   
   * IF prior row is same as current row, mark as a Repeat;
   if Session_ID = LAG(Session_ID) 
      AND Task_URL = LAG(Task_URL)
      then Repeat=1; 
   else Repeat=0;
   output; *NLM test datastep keyword highlighting;
RUN;

ods html close;


proc means n data=work.Temp;
   var Session_ID;
   class Task_ID Task_Number;
   format Task_ID $16.;
/* ^support.function.sas, support.class.sas */
run;
proc transpose 
   data=Temp(WHERE=(Task_Number=2)) NAME=NAME OUT=GaveConsent(DROP=NAME);
   by Session_ID; 
   var Task_ID; 
   ID Task_Number;
run;

proc corr 
   data=Clean.Cr 
   OUTP=IniFactor;
   VAR Q01-Q11;
run; 

/* WISHLIST: More PROC-specific keyword highlighting? */
PROC FACTOR DATA=work.IniFactor (TYPE=CORR)
   ROTATE=PROMAX
   METHOD=PRINCIPAL
   PRIORS=SMC
   MINEIGEN=1
   CONV= 0.001
   MAXITER=200
   MSA
   SIMPLE
   SCREE
   REORDER
   HEYWOOD;
RUN;

%macro blah ;
   /* USAGE QUIRK/BUG: note that this will have macro highlighting
      but "%macro blah;" (i.e., no space) would not */
   %let something=nothing;
%mend;


%macro getQuoteList(string, inDlm=%str( ), outDlm=%str(, ), quoteType=DOUBLE,quotingChar=%str()); 

   %local i locString nItem thisDlm;
   %let nItem = %getItemCountInString(&string, inDlm=&inDlm);
/*              ^support.function.macrocall.sas */

   %if &nItem > 0 
   %then %do;

      %if %upcase(&quoteType) = SINGLE
      %then %do;
         %let quotingChar = %str(%');
         /*                      ^constant.character.escape.sas */
      %end;
      %else if %upcase(&quoteType) = DOUBLE
      %then %do;
         %let quotingChar = %str(%");
         /*                      ^constant.character.escape.sas */
      %end;

      %do i = 1 %to &nItem;
         %if &i = 1
         %then %do;
            %let thisDlm =;
            %let locString =;
         %end;
         %else %do;
            %let thisDlm=%bquote(&outDlm);
         %end;
          %let locString=&locString&thisDlm&quotingChar%nrbquote(%scan(&string, &i, &inDlm))&quotingChar;
      %end;

      /* Unquote override SAS tendency to confuse itself with all of the masking 
         functions (nrbquote etc); */
      %let locString = %unquote(&locString);

      &locString
   %end;

   %* Dummy/non-functional block to show nested ampersand resolution;
   %do i = 1 %to &nItem;
      %let columnTypeList = &&columnName&i &&targetDataType&i;
/*                          ^variable.parameter.macro.nested.sas */
   %end;

%mend;
