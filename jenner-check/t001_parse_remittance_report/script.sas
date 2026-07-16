/* Adapted from utl-altair-slc-extract-key-data-from-a-very-messy-participation-text-report.sas
   Original reads a fixed-width "Participant Consolidation of Remittance Report" text file via
   INFILE "d:\txt\RemittanceReport.txt" (a Windows path not available off-repo). Here the same
   report layout is supplied inline via DATALINES (a slice of the messy report text that ships
   in the repo's own README/source, plus two extra rows to exercise the not-90%-participation
   and negative-fee branches) so the parse logic runs unmodified. */

data parse;

 retain partic;

 infile datalines missover;

 input;
 lyn=_infile_;

 if index(lyn,'PARTICIPATION') then do;
    partic=input(substr(lyn,82,7),6.);
 end;

 if not missing (input(substr(lyn,2,11),?? 10.)) then do;
   paid_datec = scan(lyn,4,' ');
   due_datec  = scan(lyn,5,' ');
   feec       = scan(lyn,10,' ');
   iso_paid   = put(input(paid_datec,mmddyy8.),e8601da.);
   iso_due    = put(input(due_datec ,mmddyy8.),e8601da.);
   fee        = input(
                  ifc(index(feec,'-')
                   ,cats('-',compress(feec,'-'))
                   ,feec)
                 ,6.);
   output;
 end;

 drop lyn paid_datec due_datec feec;

datalines;
S8888-21K                                  X X X X X X X  X X X X  X X X X X X X X                                          09/29/23
XXXXXXXXX                                 PARTICIPANT CONSOLIDATION OF REMITTANCE REPORT                                    PAGE   1
XXXXXXXXXXXXXXXXXXXXXX
                                CONSOLIDATION CODE B-0028           PARTICIPATION  90.00 %           INTEREST RATE   .00000
XXXXXXXXXXX           XXXXXXXX  INVESTOR/CATEGORY  792-001                                           SERVICE-FEE     .00000
------------------------------------------------------------------------------------------------------------------------------------
     INV      CONSOL           DATE     DUE            LOAN        PARTICIPANT   PRINCIPAL  INTEREST SERVICE     NET        NET
   LOAN NO     CODE  INV CAT   PAID     DATE         BALANCE         BALANCE       PAID       PAID     FEE    INTEREST   REMITTED
                                                                                PMTDEF AMT & TYPE                    PMTDEF REMIT
------------------------------------------------------------------------------------------------------------------------------------
 2222222222   B-0028 792-001 09-11-23 09-01-23     438,376.26      394,538.63      910.37   1,853.67     .00   1,853.67    2,764.04
 2222222222   B-0028 792-001 09-11-23 10-01-23     438,303.64      394,473.28       65.36        .00     .00        .00       65.36
           CATEGORY TOTAL       2 ITEMS                                            975.73                .00               2,829.40
                                                                                            1,853.67           1,853.67
                 .00  PR                       .00  EA                         .00  FE                       .00  CA
                                .00  IN                        .00  PI                        .00  PP                       .00  R
S8888-21K                                  X X X X X X X  X X X X  X X X X X X X X                                          09/29/23
XXXXXXXXX                                 PARTICIPANT CONSOLIDATION OF REMITTANCE REPORT                                    PAGE   2
XXXXXXXXXXXXXXXXXXXXXX
                                CONSOLIDATION CODE B-0028           PARTICIPATION  90.00 %           INTEREST RATE   .00000
XXXXXXXXXXX           XXXXXXXX  INVESTOR/CATEGORY  792-001                                           SERVICE-FEE     .00000
------------------------------------------------------------------------------------------------------------------------------------
     INV      CONSOL           DATE     DUE            LOAN        PARTICIPANT   PRINCIPAL  INTEREST SERVICE     NET        NET
   LOAN NO     CODE  INV CAT   PAID     DATE         BALANCE         BALANCE       PAID       PAID     FEE    INTEREST   REMITTED
                                                                                PMTDEF AMT & TYPE                    PMTDEF REMIT
------------------------------------------------------------------------------------------------------------------------------------
           INVESTOR TOTAL       2 ITEMS                                            975.73                .00               2,829.40
                                                                                            1,853.67           1,853.67
                 .00  PR                       .00  EA                         .00  FE                       .00  CA
                                .00  IN                        .00  PI                        .00  PP                       .00  R
CONSOLIDATION CODE  TOTAL       2 ITEMS                                            975.73                .00               2,829.40
                                                                                            1,853.67           1,853.67
                 .00  PR                       .00  EA                         .00  FE                       .00  CA
                                .00  IN                        .00  PI                        .00  PP                       .00  R
S8888-21K                                  X X X X X X X  X X X X  X X X X X X X X                                          09/29/23
XXXXXXXXXXXXXXXXXXXXXXXX                  PARTICIPANT CONSOLIDATION OF REMITTANCE REPORT                                    PAGE   3

                      XXXXXXXX  CONSOLIDATION CODE B-0099           PARTICIPATION  75.00 %           INTEREST RATE   .00000
                                INVESTOR/CATEGORY  283-199                                           SERVICE-FEE     .00000
------------------------------------------------------------------------------------------------------------------------------------
     INV      CONSOL           DATE     DUE            LOAN        PARTICIPANT   PRINCIPAL  INTEREST SERVICE     NET        NET
   LOAN NO     CODE  INV CAT   PAID     DATE         BALANCE         BALANCE       PAID       PAID     FEE    INTEREST   REMITTED
                                                                                PMTDEF AMT & TYPE                    PMTDEF REMIT
------------------------------------------------------------------------------------------------------------------------------------
 2222222226   B-0099 283-199 09-15-23 09-01-23      55,100.00       50,000.00      500.00     278.48   349.13   278.48      474.90
 2222222227   B-0099 283-199 09-20-23 08-01-23      44,200.00       40,000.00      300.00     150.00   -25.10   150.00      324.90
           CATEGORY TOTAL       2 ITEMS                                            800.00                .00               799.80
                                                                                            428.48           428.48
                 .00  PR                       .00  EA                         .00  FE                       .00  CA
                                .00  IN                        .00  PI                        .00  PP                       .00  R
;
run;

proc print data=parse width=min;
run;

proc format;
  value num2mis
   . = 'MIS'
   0 = 'ZRO'
   0<-high = "POS"
   low-<0 = 'NEG'
   other='POP'
   ;
run;quit;

proc freq data=parse;
 format fee num2mis.;
 tables fee;
run;quit;

proc sql;
  select
    'NOT 90' as NOT_90
    ,count(*) as NOT_90_PARTCIPATION
  from
    parse
  where
    partic ne 90
;quit;

proc sql;
  select
    'ISO_DUE > ISO_PAID' as iso_due_gt_iso_paid
    ,count(*) as not_90_percent
  from
    parse
  where
    iso_due > iso_paid
;quit;
