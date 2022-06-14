ods noproctitle;
ods graphics / imagemap=on;

/*******************SUMMARY STATISTICS********************/

PROC SUMMARY data=CAP.DATA chartype mean std min max n nmiss vardef=df;
	var radius_mean texture_mean perimeter_mean area_mean smoothness_mean 
		compactness_mean concavity_mean concave_points_mean symmetry_mean 
		fractal_dimension_mean radius_se texture_se perimeter_se area_se 
		smoothness_se compactness_se concavity_se concave_points_se symmetry_se 
		fractal_dimension_se radius_worst texture_worst perimeter_worst area_worst 
		smoothness_worst compactness_worst concavity_worst concave_points_worst 
		symmetry_worst fractal_dimension_worst;
		OUTPUT OUT = CAP.SS;
RUN;

PROC TRANSPOSE DATA=CAP.SS DELIMITER=_STAT_ OUT=CAP.SS1;
RUN;

TITLE color=darkgreen height=20pt 'Summary Statistics';
PROC PRINT DATA=CAP.SS1 noobs LABEL style(header obsheader)=[fontsize=14pt color= black backgroundcolor=MOLG borderbottomstyle=double borderbottomcolor=black] 
	style(data)=[fontsize=3 fontweight=bold color=black];
	WHERE _NAME_ NOT LIKE '_FREQ_';
	VAR _LABEL_ / style(data)=[fontsize=3 fontweight=bold backgroundcolor=PALG color=black]; 
	VAR COL4; 
	VAR COL5; 
	VAR COL2; 
	VAR COL3;
	LABEL _LABEL_ = "Variable"
	COL4 = 'Mean'
	COL5 = 'Standard Error'
	COL2 = 'Min Value'
	COL3 = 'Max Value';
RUN;
TITLE;

PROC DELETE DATA=CAP.SS;
RUN;

PROC DELETE DATA=CAP.SS1;
RUN;

/*****************DIAGNOSIS FREQUENCY***********************/

PROC FORMAT;
	value $diagnosis
	'M'='Malignant'
	'B'='Benign';
RUN;

TITLE color=darkgreen height=3 'Diagnosis Breakdown';
PROC SGPIE DATA=CAP.data;
	FORMAT diagnosis $diagnosis.;
	styleattrs datacolors=(darkblue darkred);
	pie diagnosis / dataskin=gloss datalabeldisplay=ALL datalabelattrs=(weight=bold size=24pt style=italic);
RUN;
TITLE;

/*****************PARTITION DATA TEST and TRAINING************/

PROC SURVEYSELECT DATA=CAP.DATA rate=0.7
	OUT= CAP.DATA_SELECT outall method=srs;
RUN;

DATA CAP.DATA_TRAIN CAP.DATA_TEST;
	SET CAP.data_select;
	IF SELECTED =1 THEN OUTPUT CAP.DATA_TRAIN;
	ELSE OUTPUT CAP.DATA_TEST;
RUN;

PROC DELETE DATA=CAP.DATA_SELECT;
RUN;

/****************BINARY LOGISTIC REGRESSION*******************/

PROC LOGISTIC DATA=CAP.DATA plots
    (maxpoints=none)=(phat roc);
	model diagnosis(event='M')=radius_mean texture_mean perimeter_mean area_mean 
		smoothness_mean compactness_mean concavity_mean concave_points_mean 
		symmetry_mean fractal_dimension_mean radius_se texture_se perimeter_se 
		area_se smoothness_se compactness_se concavity_se concave_points_se 
		symmetry_se fractal_dimension_se radius_worst texture_worst perimeter_worst 
		area_worst smoothness_worst compactness_worst concavity_worst 
		concave_points_worst symmetry_worst fractal_dimension_worst / link=probit 
		selection=stepwise slentry=0.05 slstay=0.05 hierarchy=single technique=fisher;
RUN;

/*********************DECISION TREE***************************/

PROC HPSPLIT DATA=CAP.DATA;
	class diagnosis;
	model diagnosis(event='M')=radius_mean texture_mean perimeter_mean area_mean 
		smoothness_mean compactness_mean concavity_mean concave_points_mean 
		symmetry_mean fractal_dimension_mean radius_se texture_se perimeter_se 
		area_se smoothness_se compactness_se concavity_se concave_points_se 
		symmetry_se fractal_dimension_se radius_worst texture_worst perimeter_worst 
		area_worst smoothness_worst compactness_worst concavity_worst 
		concave_points_worst symmetry_worst fractal_dimension_worst;
RUN;