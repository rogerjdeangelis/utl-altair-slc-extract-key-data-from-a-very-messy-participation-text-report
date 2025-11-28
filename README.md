# utl-altair-slc-extract-key-data-from-a-very-messy-participation-text-report
Altair slc extract key data from a very messy participation text report
    %let pgm=utl-altair-slc-extract-key-data-from-a-very-messy-participation-text-report;

    %stop_submission;

    Altair slc extract key data from a very messy participation text report

    Once you parse the text the computations are simple.

    Too long to post here, see github

    github
    https://github.com/rogerjdeangelis/utl-altair-slc-extract-key-data-from-a-very-messy-participation-text-report

    community.altair.com
    https://community.altair.com/discussion/32928
    https://community.altair.com/discussion/32928/monarch-exercise-31-ice-black-knight-msp-s-21k-participation-consolidation-of-remittance-analysis#latest


    CONTENTS

       1  PARSE INPUT (CREATE TABLE PARSE)
       2  How many accounts had Service Fees?
       3  How many accounts have a Participation % that is not 90%?
       4  How many loans have a Due Date that is > Paid Date


    /*************************************************************************************************************************************/
    /* INPUT                        | PROCESS                                                   | OUTPUT                                 */
    /*                              |                                                           |                                        */
    /* 1 PARSE TEXT FILE            |                                                           |                                        */
    /*                              |                                                           |                                        */
    /* d:\txt\RemittanceReport.txt  | data parse;                                               |Table work.parse                        */
    /*                              |                                                           |                                        */
    /*                              |  retain partic;                                           |   PARTIC ISO_PAID    ISO_DUE       FEE */
    /*                              |                                                           |                                        */
    /*                              |  infile "d:\txt\RemittanceReport.txt";                    | 1    90 2023-09-11  2023-09-01      0  */
    /*                              |                                                           | 2    90 2023-09-11  2023-10-01      0  */
    /*                              |  input;                                                   | 3    90 2023-09-05  2023-10-01      0  */
    /*                              |  lyn=_infile_;                                            | 4    90 2023-09-05  2023-11-01      0  */
    /*                              |                                                           | 5    90 2023-09-29  2023-11-01      0  */
    /*                              |  if index(lyn,'PARTICIPATION') then do;                   | ...                                    */
    /*                              |     partic=input(substr(lyn,82,7),6.);                    | ...                                    */
    /*                              |  end;                                                     | 5797 10 2023-09-05  2023-09-01      0  */
    /*                              |                                                           | 5798 10 2023-09-05  2023-10-01      0  */
    /*                              |  if not missing (input(substr(lyn,2,11),?? 10.)) then do; | 5799 10 2023-09-01  2023-09-01      0  */
    /*                              |    paid_datec = scan(lyn,4,' ');                          | 5800 24 2023-09-15  2023-09-01 349.13  */
    /*                              |    due_datec  = scan(lyn,5,' ');                          | 5801 30 2023-09-01  2023-09-01 329.31  */
    /*                              |    feec       = scan(lyn,10,' ');                         |                                        */
    /*                              |    iso_paid   = put(input(paid_datec,mmddyy8.),e8601da.); |                                        */
    /*                              |    iso_due    = put(input(due_datec ,mmddyy8.),e8601da.); |                                        */
    /*                              |    fee        = input(                                    |                                        */
    /*                              |                   ifc(index(feec,'-')                     |                                        */
    /*                              |                    ,cats('-',compress(feec,'-'))          |                                        */
    /*                              |                    ,feec)                                 |                                        */
    /*                              |                  ,6.);                                    |                                        */
    /*                              |    output;                                                |                                        */
    /*                              |  end;                                                     |                                        */
    /*                              |                                                           |                                        */
    /*                              |  drop lyn paid_datec due_datec feec;                      |                                        */
    /*                              |                                                           |                                        */
    /*                              | run;quit;                                                 |                                        */
    /*                              |                                                           |                                        */
    /*------------------------------|-----------------------------------------------------------|----------------------------------------*/
    /*                                                                                          |                                        */
    /* 2  HOW MANY ACCOUNTS HAD SERVICE FEES?                                                   i                                        */
    /*                              |                                                           |                                        */
    /*                              | proc format;                                              |                          Cumulative    */
    /*                              |                                                           | FEE    Frequency Percent  Frequency    */
    /*                              |   value num2mis                                           | -----------------------------------    */
    /*                              |    . = 'MIS'                                              | NEG          10    0.17         10     */
    /*                              |    0 = 'ZRO'                                              | ZRO        5534   95.40       5544     */
    /*                              |    0<-high = "POS"                                        | POS         257    4.43       5801     */
    /*                              |    low-<0 = 'NEG'                                         |                                        */
    /*                              |    other='POP'                                            |                                        */
    /*                              |    ;                                                      |                                        */
    /*                              | run;quit;                                                 |                                        */
    /*                              |                                                           |                                        */
    /*                              | proc freq data=parse;                                     |                                        */
    /*                              |  format fee num2mis.;                                     |                                        */
    /*                              |  tables fee;                                              |                                        */
    /*                              | run;quit;                                                 |                                        */
    /*                              |                                                           |                                        */
    /*------------------------------|-----------------------------------------------------------|----------------------------------------*/
    /*                                                                                          |                                        */
    /* 3  HOW MANY ACCOUNTS HAVE A PARTICIPATION % THAT IS NOT 90%?                             |                                        */
    /*                              |                                                           |                                        */
    /*                              | proc sql;                                                 |             NOT_90_                    */
    /*                              |   select                                                  | NOT_90  PARTCIPATION                   */
    /*                              |     'NOT 90' as NOT_90                                    | --------------------                   */
    /*                              |     ,count(*) as NOT_90_PARTCIPATION                      | NOT 90          4641                   */
    /*                              |   from                                                    |                                        */
    /*                              |     parse                                                 |                                        */
    /*                              |   where                                                   |                                        */
    /*                              |     partic ne 90                                          |                                        */
    /*                              | ;quit;                                                    |                                        */
    /*                              |                                                           |                                        */
    /*------------------------------|-----------------------------------------------------------|----------------------------------------*/
    /*                                                                                          |                                        */
    /* 4  HOW MANY LOANS HAVE A DUE DATE THAT IS > PAID DATE                                    |                                        */
    /*                              |                                                           |                                        */
    /*                              | proc sql;                                                 | ISO_DUE_GT_          NOT_90_           */
    /*                              |   select                                                  | ISO_PAID             PERCENT           */
    /*                              |     'ISO_DUE > ISO_PAID' as ISO_DUE_GT_ISO_PAID           | ----------------------------           */
    /*                              |     ,count(*) as NOT_90_PERCENT                           | ISO_DUE > ISO_PAID      2317           */
    /*                              |   from                                                    |                                        */
    /*                              |     parse                                                 |                                        */
    /*                              |   where                                                   |                                        */
    /*                              |     iso_due > iso_paid                                    |                                        */
    /*                              | ;quit;                                                    |                                        */
    /*************************************************************************************************************************************/


    /*                   _                               _
    (_)_ __  _ __  _   _| |_   ___  __ _ _ __ ___  _ __ | | ___
    | | `_ \| `_ \| | | | __| / __|/ _` | `_ ` _ \| `_ \| |/ _ \
    | | | | | |_) | |_| | |_  \__ \ (_| | | | | | | |_) | |  __/
    |_|_| |_| .__/ \__,_|\__| |___/\__,_|_| |_| |_| .__/|_|\___|
            |_|                                   |_|

    COPY DOWNLOAD TO d:\txt\RemittanceReport.txt
    */

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

                          XXXXXXXX  CONSOLIDATION CODE B-0078           PARTICIPATION  90.00 %           INTEREST RATE   .00000
                                    INVESTOR/CATEGORY  283-105                                           SERVICE-FEE     .00000
    ------------------------------------------------------------------------------------------------------------------------------------
         INV      CONSOL           DATE     DUE            LOAN        PARTICIPANT   PRINCIPAL  INTEREST SERVICE     NET        NET
       LOAN NO     CODE  INV CAT   PAID     DATE         BALANCE         BALANCE       PAID       PAID     FEE    INTEREST   REMITTED
                                                                                    PMTDEF AMT & TYPE                    PMTDEF REMIT
    ------------------------------------------------------------------------------------------------------------------------------------
     2222222224   B-0078 283-105 09-05-23 10-01-23      66,722.60       60,050.34      708.98     278.48     .00     278.48      987.46
     2222222224   B-0078 283-105 09-05-23 11-01-23      66,719.78       60,047.80        2.54        .00     .00        .00        2.54
     2222222224   B-0078 283-105 09-29-23 11-01-23      65,928.40       59,335.56      712.24     275.22     .00     275.22      987.46
     2222222224   B-0078 283-105 09-29-23 12-01-23      65,925.58       59,333.02        2.54        .00     .00        .00        2.54
               CATEGORY TOTAL       4 ITEMS                                          1,426.30                .00               1,980.00
                                                                                                  553.70             553.70
                     .00  PR                       .00  EA                         .00  FE                       .00  CA
                                    .00  IN                        .00  PI                        .00  PP                       .00  R

    /*                               _            _
    / |  _ __   __ _ _ __ ___  ___  | |_ ___  ___| |_
    | | | `_ \ / _` | `__/ __|/ _ \ | __/ _ \/ __| __|
    | | | |_) | (_| | |  \__ \  __/ | ||  __/\__ \ |_
    |_| | .__/ \__,_|_|  |___/\___|  \__\___||___/\__|
        |_|
    */

    /*--- NOTE A ADDED A PERSISTENT WORK LIBRARY ---*/
    libname workx "d:/wpswrkx";

    data workx.parse;

     retain partic;

     infile "d:\txt\RemittanceReport.txt";

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

    run;quit;


    proc print data=parse width=min;
    run;


    OUTPUT
    ------

    Table work.parse

       PARTIC ISO_PAID    ISO_DUE       FEE

     1    90 2023-09-11  2023-09-01      0
     2    90 2023-09-11  2023-10-01      0
     3    90 2023-09-05  2023-10-01      0
     4    90 2023-09-05  2023-11-01      0
     5    90 2023-09-29  2023-11-01      0
     ...
     ...
     5797 10 2023-09-05  2023-09-01      0
     5798 10 2023-09-05  2023-10-01      0
     5799 10 2023-09-01  2023-09-01      0
     5800 24 2023-09-15  2023-09-01 349.13
     5801 30 2023-09-01  2023-09-01 329.31

    /*
    | | ___   __ _
    | |/ _ \ / _` |
    | | (_) | (_| |
    |_|\___/ \__, |
             |___/
    */

    1                                          Altair SLC       10:33 Friday, November 28, 2025

    NOTE: Copyright 2002-2025 World Programming, an Altair Company
    NOTE: Altair SLC 2026 (05.26.01.00.000758)
          Licensed to Roger DeAngelis
    NOTE: This session is executing on the X64_WIN11PRO platform and is running in 64 bit mode

    NOTE: AUTOEXEC processing beginning; file is C:\wpsoto\autoexec.sas
    NOTE: AUTOEXEC source line
    1       +  ï»¿;;;;
               ^
    ERROR: Expected a statement keyword : found "?"
    NOTE: Library workx assigned as follows:
          Engine:        SAS7BDAT
          Physical Name: d:\wpswrkx


    NOTE: 1 record was written to file PRINT

    NOTE: The data step took :
          real time : 0.024
          cpu time  : 0.000


    NOTE: AUTOEXEC processing completed

    1          data parse;
    2
    3          retain partic;
    4
    5          infile "d:\txt\RemittanceReport.txt";
    6
    7          input;
    8          lyn=_infile_;
    9
    10         if index(lyn,'PARTICIPATION') then do;
    11            partic=input(substr(lyn,82,7),6.);
    12         end;
    13
    14         if not missing (input(substr(lyn,2,11),?? 10.)) then do;
    15           paid_datec = scan(lyn,4,' ');
    16           due_datec  = scan(lyn,5,' ');
    17           feec       = scan(lyn,10,' ');
    18           iso_paid   = put(input(paid_datec,mmddyy8.),e8601da.);
    19           iso_due    = put(input(due_datec ,mmddyy8.),e8601da.);
    20           fee        = input(
    21                          ifc(index(feec,'-')
    22                           ,cats('-',compress(feec,'-'))
    23                           ,feec)
    24                         ,6.);
    25           output;
    26         end;
    27
    28         drop lyn paid_datec due_datec feec;
    29
    30        run;

    NOTE: The infile 'd:\txt\RemittanceReport.txt' is:
          Filename='d:\txt\RemittanceReport.txt',
          Owner Name=T7610\Roger,
          File size (bytes)=1742938,
          Create Time=16:51:16 Nov 27 2025,
          Last Accessed=10:32:26 Nov 28 2025,
          Last Modified=16:51:16 Nov 27 2025,
          Lrecl=32767, Recfm=V

    2                                                                                                                         Altair SLC


    NOTE: 13007 records were read from file 'd:\txt\RemittanceReport.txt'
          The minimum record length was 132
          The maximum record length was 132
    NOTE: Data set "WORK.parse" has 5801 observation(s) and 4 variable(s)
    NOTE: The data step took :
          real time : 0.139
          cpu time  : 0.125


    30      !     quit;
    31
    32
    33        proc print data=parse width=min;
    34        run;
    NOTE: 5801 observations were read from "WORK.parse"
    NOTE: Procedure print step took :
          real time : 0.114
          cpu time  : 0.093


    ERROR: Error printed on page 1

    NOTE: Submitted statements took :
          real time : 0.384
          cpu time  : 0.281
    /*___                        _             __
    |___ \   ___  ___ _ ____   _(_) ___ ___   / _| ___  ___  ___
      __) | / __|/ _ \ `__\ \ / / |/ __/ _ \ | |_ / _ \/ _ \/ __|
     / __/  \__ \  __/ |   \ V /| | (_|  __/ |  _|  __/  __/\__ \
    |_____| |___/\___|_|    \_/ |_|\___\___| |_|  \___|\___||___/

    */

    proc format;

      value num2mis
       . = 'MIS'
       0 = 'ZRO'
       0<-high = "POS"
       low-<0 = 'NEG'
       other='POP'
       ;
    run;quit;

    proc freq data=workx.parse;
     format fee num2mis.;
     tables fee;
    run;quit;


    OUTPUT
    ------

    Altair SLC

    The FREQ Procedure

                                   Cumulative    Cumulative
    FEE    Frequency    Percent     Frequency       Percent
    -------------------------------------------------------
    NEG           10       0.17            10          0.17
    ZRO         5534      95.40          5544         95.57
    POS          257       4.43          5801        100.00

    /*____                    _   _      _             _   _              __    ___   ___
    |___ /   _ __   __ _ _ __| |_(_) ___(_)_ __   __ _| |_(_) ___  _ __   \ \  / _ \ / _ \
      |_ \  | `_ \ / _` | `__| __| |/ __| | `_ \ / _` | __| |/ _ \| `_ \   \ \| (_) | | | |
     ___) | | |_) | (_| | |  | |_| | (__| | |_) | (_| | |_| | (_) | | | |  / / \__, | |_| |
    |____/  | .__/ \__,_|_|   \__|_|\___|_| .__/ \__,_|\__|_|\___/|_| |_| /_/    /_/ \___/
            |_|                           |_|
    */

    proc sql;
      select
        'NOT 90' as NOT_90
        ,count(*) as NOT_90_PARTCIPATION
      from
        workx.parse
      where
        partic ne 90
    ;quit;

    OUTPUT
    ------

    Altair SLC

      NOT_90  NOT_90_PARTCIPATION
      ---------------------------
      NOT 90                 4641

    /*
    | | ___   __ _
    | |/ _ \ / _` |
    | | (_) | (_| |
    |_|\___/ \__, |
             |___/
    */

    1                                          Altair SLC       10:48 Friday, November 28, 2025

    NOTE: Copyright 2002-2025 World Programming, an Altair Company
    NOTE: Altair SLC 2026 (05.26.01.00.000758)
          Licensed to Roger DeAngelis
    NOTE: This session is executing on the X64_WIN11PRO platform and is running in 64 bit mode

    NOTE: AUTOEXEC processing beginning; file is C:\wpsoto\autoexec.sas
    NOTE: AUTOEXEC source line
    1       +  ï»¿;;;;
               ^
    ERROR: Expected a statement keyword : found "?"
    NOTE: Library workx assigned as follows:
          Engine:        SAS7BDAT
          Physical Name: d:\wpswrkx


    NOTE: 1 record was written to file PRINT

    NOTE: The data step took :
          real time : 0.021
          cpu time  : 0.000


    NOTE: AUTOEXEC processing completed

    1          proc sql;
    2           select
    3             'NOT 90' as NOT_90
    4             ,count(*) as NOT_90_PARTCIPATION
    5           from
    6             workx.parse
    7           where
    8             partic ne 90
    9         ;quit;
    NOTE: Procedure sql step took :
          real time : 0.021
          cpu time  : 0.000


    10
    ERROR: Error printed on page 1

    NOTE: Submitted statements took :
          real time : 0.185
          cpu time  : 0.062


    /*  _         _             __                _     _
    | || |     __| |_   _  ___  \ \   _ __   __ _(_) __| |
    | || |_   / _` | | | |/ _ \  \ \ | `_ \ / _` | |/ _` |
    |__   _| | (_| | |_| |  __/  / / | |_) | (_| | | (_| |
       |_|    \__,_|\__,_|\___| /_/  | .__/ \__,_|_|\__,_|
                                     |_|
    */

    proc sql;
      select
        'ISO_DUE > ISO_PAID' as iso_due_gt_iso_paid
        ,count(*) as not_90_percent
      from
        workx.parse
      where
        iso_due > iso_paid
    ;quit;

    OUTPUT
    ------

    Altair SLC

      ISO_DUE_GT_ISO_PAID  NOT_90_PERCENT
      -----------------------------------
      ISO_DUE > ISO_PAID             2317

    /*
    | | ___   __ _
    | |/ _ \ / _` |
    | | (_) | (_| |
    |_|\___/ \__, |
             |___/
    */

    1                                          Altair SLC       10:51 Friday, November 28, 2025

    NOTE: Copyright 2002-2025 World Programming, an Altair Company
    NOTE: Altair SLC 2026 (05.26.01.00.000758)
          Licensed to Roger DeAngelis
    NOTE: This session is executing on the X64_WIN11PRO platform and is running in 64 bit mode

    NOTE: AUTOEXEC processing beginning; file is C:\wpsoto\autoexec.sas
    NOTE: AUTOEXEC source line
    1       +  ï»¿;;;;
               ^
    ERROR: Expected a statement keyword : found "?"
    NOTE: Library workx assigned as follows:
          Engine:        SAS7BDAT
          Physical Name: d:\wpswrkx


    NOTE: 1 record was written to file PRINT

    NOTE: The data step took :
          real time : 0.030
          cpu time  : 0.000


    NOTE: AUTOEXEC processing completed

    1
    2         proc sql;
    3           select
    4             'ISO_DUE > ISO_PAID' as iso_due_gt_iso_paid
    5             ,count(*) as not_90_percent
    6           from
    7             workx.parse
    8           where
    9             iso_due > iso_paid
    10        ;quit;
    NOTE: Procedure sql step took :
          real time : 0.017
          cpu time  : 0.015


    11
    12
    ERROR: Error printed on page 1

    NOTE: Submitted statements took :

    /*              _
      ___ _ __   __| |
     / _ \ `_ \ / _` |
    |  __/ | | | (_| |
     \___|_| |_|\__,_|

    */
