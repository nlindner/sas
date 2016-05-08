/* From RPardee sample */ 
	options
	  linesize  = 150
	  msglevel  = i
	  formchar  = '|-++++++++++=|-/|<>*'
	  dsoptions = note2err
	  nocenter
	  noovp
	  nosqlremerge
	;
	options orientation = landscape ;

	data    bobbity ;
	run;


	data s.gnu ;
	  set b.old
	  ;

	* message ;
	* foobar; * foobar;
	x1 = a * b ;
	x2 = 8*n ;
	x = 1.2**2-1;
	x = 1.2**(2-1);
	z = "&date."d;

	/* foobar */

	x = a    *
	    b ;
	run ;

	%let out_folder = /C/Documents and Settings/pardre1/Application Data/Sublime Text 2/Packages/SAS/ ;
	%let out_folder = C:\Documents and Settings/pardre1/Application Data/Sublime Text 2/Packages/SAS/test.sas ;

	ods html path = "&out_folder" (URL=NONE)
	         body   = "test.html"
	         (title = "test output")
	          ;
	proc sql outobs = 20 nowarn feedback noprint;
	  create table blah as
	  select *
	  from some.other_table
	  ;
	quit;

	data bob;
	  set sashelp.class;
	  if height = 4 then do;
	    weight = 40;
	  end ;
	  if weight = 400 then do;
	    category = 'fatty';
	  end;
	  else do;
	    something;
	  end;
	run;

	data gnu;
	  set old;
	run;





data work.blah;
	set work.blah;
	put _all_;
run;

%macro test(lib=,tableName=);

	%let lib = %upcase(&lib);
	%let tableName = %upcase(&tableName);

	%if %sysfunc(exist(&lib..&tableName))
	%then %do;
		proc sql;
			SELECT count(*) as N_Item
			INTO   : N_Item
			FROM   dictionary.columns
			WHERE
				libname = %upcase("&lib")
				AND memname = %upcase("&tableName");

			%let N_Item = %left(&N_Item);

			SELECT ColumnName
			INTO   :ColName1 - :ColName&N_Item
			FROM   dictionary.columns
			WHERE
				libname = "&lib"
				AND memname = "&tableName";
		quit;


		%do i = 1 %to &N_Item %by 1;
			%let currItem = Blahblah&&ColName.&i;
			%put &i: &currItem;
			/* do something */
		%end;

	%end;

	%else %do;
		%put %str(E)RROR: &lib..&tableName table does not exist;
	%end;

%mend test;

%test(lib=WORK,tableName=Testme);


proc sql feedback stimer;
  connect to olebdb as DBRef
    ( user id= psw=);
  SELECT * 
  FROM   connection to DBRef (
  		SELECT a, b, count(*) as total
   	FROM cmq.dim_dlr
   	WHERE blah = x
   	GROUP BY blah
  );
quit;

%TestMe(var=1);

%macro ETLSnippet(RptType=EXAMPLE2, SrcTable=work.Metric_Trans, dbmsAlias=MsSqlDB, inList=, exList=, TestMode=1, haltRun=1, UseCurrProcSql=1, ParamRC=);


	/* For ETL, only do insert/update because this operates on the data source's 
		subset of table columns. Calling macro/process calls a separate macro to
		delete inactive records
	*/
	%if &UseCurrProcSql = 0 
	%then %do;
		proc sql;
			%connectToDBMS(&dbmsAlias);
	%end;
	reset feedback exec noerrorstop noprint;

	/* 1.	Set macro-wide parameters: Status and column lists for input SrcTable
	======================================================================================== */

	/* Column lists must be space delimited */
	%local locRC currMacroName dbmsTable upmExList;

	%let locRC = -10;
	%let currMacroName = %sysfunc(compbl(&RptType ETL Process));
	%let dbmsTable = %sysfunc(strip(Report_&RptType.));

	%let upmExList =;

	%let RptType = %upcase(&RptType);

	%if &TestMode
	%then %do;
		%put %str(N)OTE: Started &currMacroName;
	%end;

	%else %if &RptType = OVERALL
	%then %do;
		%let upmExList = Report_Date &exList;
	%end;
	%else %if &RptType = EXAMPLE2
	%then %do;
		%let upmExList = Group_Var_A Group_Var_B &exList;
	%end;

	%else %do;
		%let locRC = 1;
		%put %str(W)ARNING: Report Type not recognized in &currMacroName. Halting;
		%goto EOM;
	%end;

	%if not %ObjectExists(&SrcTable,DATA) 
	%then %do;
		%let locRC = 2;
		%put %str(W)ARNING: Source table &SrcTable not found. Halting;
		%goto EOM;
	%end;


	/* 2.	Create temporary SQL Server table and populate with the input SrcTable
	======================================================================================== */
	execute (

		SELECT 
			 CAST(NULL AS CHAR(4)) AS Load_Type
			,CAST(NULL AS INT) AS RptId
			,%ListSqlColumns(columns=%bquote(&upmExList), delimiter=%str(, ))
			/* ... In reality, use utility macros here and elsewhere to dynamically 
				generate the Metric name list*/
			,Metric1
			,Metric2
			,Metric3
			,MetricN
		INTO ##&dbmsTable
		FROM dbo.&dbmsTable src
		WHERE 0 = 1

	) by &dbmsAlias;

	%if &sqlrc >= 8 
	%then %do;
		%let locRC = &sqlrc;
		%put %str(W)ARNING: %sysfunc(compbl(&currMacroName &locRC sqlRc at 2.Loading));
		%goto EOM;
	%end;

	INSERT INTO TEMPDB."##&dbmsTable"N (
		 %ListSqlColumns(columns=%bquote(&upmExList), delimiter=%str(, ))
		,Metric1
		,Metric2
		,Metric3
		,MetricN
	)
	SELECT
		 %ListSqlColumns(columns=%bquote(&upmExList), delimiter=%str(, ))
		,Metric1
		,Metric2
		,Metric3
		,MetricN
	FROM
		&SrcTable;

	%if &sqlrc >= 8 
	%then %do;
		%let locRC = &sqlrc;
		%let line = %sysfunc(compbl(&currMacroName &locRC sqlRc at 2.Inserts));
		%goto EOM;
	%end;



	/* 3.	Classify load type for SrcTable rows (Insert, Update)
	======================================================================================== */
	EXECUTE (
		UPDATE a
		SET
			 a.RptId = b.RptId
			,a.Load_Type = 
				CASE 
					WHEN b.RptId IS NULL THEN 'I'
					ELSE 'U'
				END
		FROM
			##&dbmsTable a
			LEFT OUTER JOIN dbo.&dbmsTable b 
			%if &RptType = OVERALL
			%then %do;
				ON  a.Report_Date	= b.Report_Date
			%end;
			%else %if &RptType = EXAMPLE2 
			%then %do;
				ON  a.Group_Var_A 	= b.Group_Var_A
				AND a.Group_Var_B 	= b.Group_Var_B 
			%end;

	) BY &dbmsAlias;

	%if &sqlrc >= 8 
	%then %do;
		%let locRC = &sqlrc;
		%put %str(W)ARNING: %sysfunc(compbl(&currMacroName &locRC sqlRc at 3.Classify));
		%goto EOM;
	%end;


	/* 4.	Do load process for SrcTable metric columns
			*	Null out all existing values for metrics (&ColListLoad) in report table
			*	Insert any new rows to report table
			*	Update all rows that match in SrcTable and report table
	======================================================================================== */
	EXECUTE (
		UPDATE dbo.&dbmsTable 
			SET
				 Metric1 = NULL
				,Metric2 = NULL
				,Metric3 = NULL
				,MetricN = NULL

		INSERT INTO dbo.&dbmsTable (
			 %ListSqlColumns(columns=%bquote(&upmExList), delimiter=%str(, ))
			,Metric1
			,Metric2
			,Metric3
			,MetricN
			,CreatedDate
			,UpdatedDate
		)
		SELECT
			 %ListSqlColumns(columns=%bquote(&upmExList), delimiter=%str(, ))
			,Metric1
			,Metric2
			,Metric3
			,MetricN
			,GETDATE() AS CreatedDate
			,GETDATE() AS UpdatedDate
		FROM
			##&dbmsTable a
		WHERE 
			a.Load_Type = 'I'

		UPDATE src
			SET
				 src.Metric1 = upd.Metric1
				,src.Metric2 = upd.Metric2
				,src.Metric3 = upd.Metric3
				,src.MetricN = upd.MetricN
				,src.UpdatedDate = getdate()
		FROM
			dbo.&dbmsTable src
			INNER JOIN ##&dbmsTable upd
				ON  upd.RptId = src.RptId
		WHERE 
			upd.Load_Type IN ('U')

	) BY &dbmsAlias;

	%if &sqlrc >= 8 
	%then %do;
		%let locRC = &sqlrc;
		%put %str(W)ARNING: %sysfunc(compbl(&currMacroName &locRC sqlRc 4.ETL));
		%goto EOM;
	%end;

	%else %do;
		%let locRC = 0;
	%end;


	/* 5.	Do end steps for this macro
	======================================================================================== */

	%EOM:

	reset exec noerrorstop print; 
	%put * Reached EOM for &currMacroName with &locRC RC;

	%if %bquote(&ParamRC) ^= %str() 
	%then %do;
		%let &ParamRC = &locRC; 

		%if &TestMode
		%then %do;
			%put %str(N)OTE: %sysfunc(compbl(&currMacroName set &ParamRC to &locRC));
		%end;
	%end;

	%if &TestMode
	%then %do;
		%put %str(I)NFO: %sysfunc(compbl(%bquote(Ended &currMacroName with 
			&locRC RC at %sysfunc(datetime(), mdyampm19.) )));
	%end;

	%if &UseCurrProcSql = 0 
	%then %do;
		quit;
	%end;

%mend;
