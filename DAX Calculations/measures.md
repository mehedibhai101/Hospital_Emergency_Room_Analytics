# 📊 Measures: Hospital Emergency Room Analytics

This documentation provides the complete catalog of all DAX measures used in the Emergency Room Analytics project, organized by functional category.

---

## 🏥 Core KPIs & Patient Volume

* **Total Patients**: Total count of unique patient visits.

    * **Formula**: `COUNT(data[Patient Id])`
    * **Format**: `#,0`

* **Referred Patients**: Count of patients referred by a specific department.
  
  * **Formula**: `CALCULATE([Total Patients], data[Department]<>"None" && data[Department]<>"")`
  * **Format**: `#,0`

* **Non-Referred**: Patients who arrived without a specific internal referral.

  * **Formula**: `[Total Patients]-[Referred Patients]`
  * **Format**: `#,0`

* **Avg Waittime (minutes)**: Average time a patient waited.

  * **Formula**: `AVERAGE(data[Wait Time])`
  * **Format**: `0.00 min`

* **Avg Satisfaction Score**: Average patient feedback score (1-10).

  * **Formula**: `AVERAGE(data[Satisfaction Score])`
  * **Format**: `0.00`

---

## 👥 Demographics

* **Male Axis**: Count of male patients (Positive Axis).

  * **Formula**: `1 * CALCULATE([Total Patients], data[Gender]="♂")`
  * **Format**: `#,0`

* **Female Axis**: Count of female patients (Negative Axis).

  * **Formula**: `-1 * CALCULATE([Total Patients], data[Gender]="♀")`
  * **Format**: `#,0`

* **M%**: Formatted label for Male percentage.

  * **Formula**:
  
  ```dax
  "Male ("&ROUND(DIVIDE(CALCULATE([Total Patients], data[Gender]="♂"), [Total Patients]), 3)*100&"%)"
  ```
  
  * **Format**: `General`

* **F%**: Formatted label for Female percentage.

  * **Formula**:
  
  ```dax
  "("&ROUND(DIVIDE(CALCULATE([Total Patients], data[Gender]="♀"), [Total Patients]), 3)*100&"%) Female "
  ```
  
  * **Format**: `General`

---

## 📈 Time Intelligence: Month-over-Month (MoM)

* **MoM(P)**: Month-over-Month growth for Total Patients.

  * **Formula**: `DIVIDE([Total Patients], CALCULATE([Total Patients], PREVIOUSMONTH('calendar'[Date])), 1)-1`
  * **Format**: `0.00%;-0.00%;0.00%`

* **MoM(R)**: Month-over-Month growth for Referred Patients.

  * **Formula**: `DIVIDE([Referred Patients], CALCULATE([Referred Patients], PREVIOUSMONTH('calendar'[Date])), 1)-1`
  * **Format**: `0.00%;-0.00%;0.00%`

* **MoM(W)**: Month-over-Month growth for Wait Time.

  * **Formula**: `DIVIDE([Avg Waittime (days)], CALCULATE([Avg Waittime (days)], PREVIOUSMONTH('calendar'[Date])), 1)-1`
  * **Format**: `0.00%;-0.00%;0.00%`

* **MoM(S)**: Month-over-Month growth for Satisfaction Score.

  * **Formula**: `DIVIDE([Avg Satisfaction Score], CALCULATE([Avg Satisfaction Score], PREVIOUSMONTH('calendar'[Date])), 1)-1`
  * **Format**: `0.00%;-0.00%;0.00%`

---

## 🔁 Time Intelligence: Period-over-Period (PoP)

* **NumDays**: Helper measure to calculate the duration of the currently selected date range.

  * **Formula**:
  
  ```dax
  VAR StartDate = MIN('calendar'[Date]) 
  VAR EndDate = MAX('calendar'[Date]) 
  VAR NumDays = DATEDIFF(StartDate, EndDate, DAY) +1 
  RETURN NumDays
  ```
  
  * **Format**: `0`

* **PoP(P)**: Dynamic Period growth for Patients (compares current N days vs previous N days).

  * **Formula**:
  
  ```dax
  VAR StartDate = MIN('calendar'[Date])
  VAR EndDate = MAX('calendar'[Date])
  VAR NumDays = DATEDIFF(StartDate, EndDate, DAY) +1
  VAR PrevStart = StartDate - NumDays
  VAR PrevEnd = EndDate - NumDays
  VAR CurrrentPeriod = [Total Patients]
  VAR PrevPeriod = 
      CALCULATE( [Total Patients],
          FILTER( ALL('calendar'),
              'calendar'[Date]>=PrevStart && 'calendar'[Date]<=PrevEnd
          )
      )
  VAR Growth = DIVIDE(CurrrentPeriod - PrevPeriod, PrevPeriod, "--") 
  RETURN IF( PrevStart < DATE(2023, 1, 4), "--", Growth)
  ```
  
  * **Format**: `0.00%;-0.00%;0.00%`

* **PoP(R)**: Dynamic Period growth for Referred Patients.

  * **Formula**:
  
  ```dax
  VAR StartDate = MIN('calendar'[Date])
  VAR EndDate = MAX('calendar'[Date])
  VAR NumDays = DATEDIFF(StartDate, EndDate, DAY) +1
  VAR PrevStart = StartDate - NumDays
  VAR PrevEnd = EndDate - NumDays
  VAR CurrrentPeriod = [Referred Patients]
  VAR PrevPeriod = 
      CALCULATE( [Referred Patients],
          FILTER( ALL('calendar'),
              'calendar'[Date]>=PrevStart && 'calendar'[Date]<=PrevEnd
          )
      )
  VAR Growth = DIVIDE(CurrrentPeriod - PrevPeriod, PrevPeriod, "--") 
  RETURN IF( PrevStart < DATE(2023, 1, 4), "--", Growth)
  ```
  
  * **Format**: `0.00%;-0.00%;0.00%`

* **PoP(W)**: Dynamic Period growth for Wait Time.

  * **Formula**:
  
  ```dax
  VAR StartDate = MIN('calendar'[Date])
  VAR EndDate = MAX('calendar'[Date])
  VAR NumDays = DATEDIFF(StartDate, EndDate, DAY) +1
  VAR PrevStart = StartDate - NumDays
  VAR PrevEnd = EndDate - NumDays
  VAR CurrrentPeriod = [Avg Waittime (days)]
  VAR PrevPeriod = 
      CALCULATE([Avg Waittime (days)],
          FILTER( ALL('calendar'),
              'calendar'[Date]>=PrevStart && 'calendar'[Date]<=PrevEnd
          )
      )
  VAR Growth = DIVIDE(CurrrentPeriod - PrevPeriod, PrevPeriod, "--") 
  RETURN IF( PrevStart < DATE(2023, 1, 4), "--", Growth)
  ```
  
  * **Format**: `0.00%;-0.00%;0.00%`

* **PoP(S)**: Dynamic Period growth for Satisfaction Score.
  
  * **Formula**:
  
  ```dax
  VAR StartDate = MIN('calendar'[Date])
  VAR EndDate = MAX('calendar'[Date])
  VAR NumDays = DATEDIFF(StartDate, EndDate, DAY) +1
  VAR PrevStart = StartDate - NumDays
  VAR PrevEnd = EndDate - NumDays
  VAR CurrrentPeriod = [Avg Satisfaction Score]
  VAR PrevPeriod = 
      CALCULATE( [Avg Satisfaction Score],
          FILTER( ALL('calendar'),
              'calendar'[Date]>=PrevStart && 'calendar'[Date]<=PrevEnd
          )
      )
  VAR Growth = DIVIDE(CurrrentPeriod - PrevPeriod, PrevPeriod, "--") 
  RETURN IF( PrevStart < DATE(2023, 1, 4), "--", Growth)
  ```
  
  * **Format**: `0.00%;-0.00%;0.00%`

---

## 🎨 Conditional Formatting (KPI Cards)

  * **MoM Color(P)**: `SWITCH( TRUE(), ISSTRING([MoM(P)]), "Black", [MoM(P)]>0, "Green", [MoM(P)]<0, "#D90227", "Black")`
  * **MoM Color(R)**: `SWITCH( TRUE(), ISSTRING([MoM(R)]), "Black", [MoM(R)]>0, "Green", [MoM(R)]<0, "#D90227", "Black")`
  * **MoM Color(W)**: `SWITCH( TRUE(), ISSTRING([MoM(W)]), "Black", [MoM(W)]<0, "Green", [MoM(W)]>0, "#D90227", "Black")` *(Note: Decrease in Wait Time is Green)*
  * **MoM Color(S)**: `SWITCH( TRUE(), ISSTRING([MoM(S)]), "Black", [MoM(S)]>0, "Green", [MoM(S)]<0, "#D90227", "Black")`
  
  * **PoP Color(P)**: `SWITCH( TRUE(), ISSTRING([PoP(P)]), "Black", [PoP(P)]>0, "Green", [PoP(P)]<0, "#D90227", "Black")`
  * **PoP Color(R)**: `SWITCH( TRUE(), ISSTRING([PoP(R)]), "Black", [PoP(R)]>0, "Green", [PoP(R)]<0, "#D90227", "Black")`
  * **PoP Color(W)**: `SWITCH( TRUE(), ISSTRING([PoP(W)]), "Black", [PoP(W)]<0, "Green", [PoP(W)]>0, "#D90227", "Black")` *(Note: Decrease in Wait Time is Green)*
  * **PoP Color(S)**: `SWITCH( TRUE(), ISSTRING([PoP(S)]), "Black", [PoP(S)]>0, "Green", [PoP(S)]<0, "#D90227", "Black")`

---

## 📉 Sparklines Helpers (Min/Max Indicators)

These measures return a value *only* if it matches the Min or Max of the current context, used to place markers on line charts.

* **Daily Sparklines (M)**:

  * **Max(MP)**: `SWITCH( TRUE(), [Total Patients]= MAXX( ALL('calendar'[Day]), [Total Patients]), [Total Patients], "" )`
  * **Max(MR)**: `SWITCH( TRUE(), [Referred Patients]= MAXX( ALL('calendar'[Day]), [Referred Patients]), [Referred Patients], "" )`
  * **Max(MW)**: `SWITCH( TRUE(), [Avg Waittime (days)]= MAXX( ALL('calendar'[Day]), [Avg Waittime (days)]), [Avg Waittime (days)], "" )`
  * **Max(MS)**: `SWITCH( TRUE(), [Avg Satisfaction Score]= MAXX( ALL('calendar'[Day]), [Avg Satisfaction Score]), [Avg Satisfaction Score], "" )`
  * **Min(MP)**: `SWITCH( TRUE(), [Total Patients]= MINX( ALL('calendar'[Day]), [Total Patients]), [Total Patients], "" )`
  * **Min(MR)**: `SWITCH( TRUE(), [Referred Patients]= MINX( ALL('calendar'[Day]), [Referred Patients]), [Referred Patients], "" )`
  * **Min(MS)**: `SWITCH( TRUE(), [Avg Satisfaction Score]= MINX( ALL('calendar'[Day]), [Avg Satisfaction Score]), [Avg Satisfaction Score], "" )`
  * **Min(MW)**: `SWITCH( TRUE(), [Avg Waittime (days)]= MINX( ALL('calendar'[Day]), [Avg Waittime (days)]), [Avg Waittime (days)], "" )`

* **Monthly Sparklines (P)**:

  * **Max(PP)**: `SWITCH( TRUE(), [Total Patients]= CALCULATE( MAXX( VALUES('calendar'[Mon-Year]), [Total Patients] ), ALLSELECTED('Calendar') ), [Total Patients], "" )`
  * **Max(PR)**: `SWITCH( TRUE(), [Referred Patients]= CALCULATE( MAXX( VALUES('calendar'[Mon-Year]), [Referred Patients] ), ALLSELECTED('Calendar') ), [Referred Patients], "" )`
  * **Max(PW)**: `SWITCH( TRUE(), [Avg Waittime (days)]= CALCULATE( MAXX( VALUES('calendar'[Mon-Year]), [Avg Waittime (days)] ), ALLSELECTED('Calendar') ), [Avg Waittime (days)], "" )`
  * **Max(PS)**: `SWITCH( TRUE(), [Avg Satisfaction Score]= CALCULATE( MAXX( VALUES('calendar'[Mon-Year]), [Avg Satisfaction Score] ), ALLSELECTED('Calendar') ), [Avg Satisfaction Score], "" )`
  * **Min(PP)**: `SWITCH( TRUE(), [Total Patients]= CALCULATE( MINX( VALUES('calendar'[Mon-Year]), [Total Patients] ), ALLSELECTED('Calendar') ), [Total Patients], "" )`
  * **Min(PR)**: `SWITCH( TRUE(), [Referred Patients]= CALCULATE( MINX( VALUES('calendar'[Mon-Year]), [Referred Patients] ), ALLSELECTED('Calendar') ), [Referred Patients], "" )`
  * **Min(PS)**: `SWITCH( TRUE(), [Avg Satisfaction Score]= CALCULATE( MINX( VALUES('calendar'[Mon-Year]), [Avg Satisfaction Score] ), ALLSELECTED('Calendar') ), [Avg Satisfaction Score], "" )`
  * **Min(PW)**: `SWITCH( TRUE(), [Avg Waittime (days)]= CALCULATE( MINX( VALUES('calendar'[Mon-Year]), [Avg Waittime (days)] ), ALLSELECTED('Calendar') ), [Avg Waittime (days)], "" )`

---

## 🎛️ UX & Filtering

* **Active Filters**: Displays a summary string of all currently applied filters for the report header.

  * **Formula**:
  
  ```dax
  VAR Gender= "𝐆𝐞𝐧𝐝𝐞𝐫: " & CONCATENATEX(VALUES(data[Gender]),data[Gender],", ") 
  VAR Age= "𝐀𝐠𝐞: " & CONCATENATEX(VALUES(data[Age Group]),data[Age Group],", ") 
  VAR Race= "𝐑𝐚𝐜𝐞: " & CONCATENATEX(VALUES(data[Race]),data[Race],", ") 
  VAR Waittime= "𝐖𝐚𝐢𝐭𝐭𝐢𝐦𝐞: " & MIN(data[Wait Time])&"-"&MAX(data[Wait Time])&" min" 
  VAR Target= "𝐓𝐚𝐫𝐠𝐞𝐭: " & CONCATENATEX(VALUES(data[Target Status]),data[Target Status],", ") 
  VAR Admission= "𝐀𝐝𝐦𝐢𝐬𝐬𝐢𝐨𝐧: " & CONCATENATEX(VALUES(data[Admission]),data[Admission],", ") 
  VAR _Date="𝐃𝐚𝐭𝐞: " & DATEDIFF(MIN('calendar'[Date]), MAX('calendar'[Date]), DAY) +1 
  VAR _Time= "𝐓𝐢𝐦𝐞: " & CONCATENATEX(VALUES(data[Hour Group]),data[Hour Group],", ") 
  VAR Department= "𝐃𝐞𝐩𝐚𝐫𝐭𝐦𝐞𝐧𝐭: " & CONCATENATEX(VALUES(data[Department]),data[Department],", ") 
  VAR Score= "𝐒𝐚𝐭𝐢𝐬𝐟𝐚𝐜𝐭𝐢𝐨𝐧 𝐒𝐜𝐨𝐫𝐞: " & CONCATENATEX(VALUES(data[Satisfaction Score]),data[Satisfaction Score],", ") 
  
  VAR GenderFIlter= ISFILTERED(data[Gender]) 
  VAR AgeFilter= ISFILTERED(data[Age Group]) 
  VAR RaceFilter= ISFILTERED(data[Race]) 
  VAR WaittimeFilter= ISFILTERED(data[Wait Time]) 
  VAR TargetFilter= ISFILTERED(data[Target Status]) 
  VAR AdmissionFIlter= ISFILTERED(data[Admission]) 
  VAR DateFilter= ISFILTERED('calendar'[Date]) 
  VAR TimeFilter= ISFILTERED(data[Hour Group]) 
  VAR DepartmentFilter= ISFILTERED(data[Department]) 
  VAR ScoreFilter= ISFILTERED(data[Satisfaction Score]) 
  
  VAR Maxfilter= 20 
  VAR Countfilter= 
      IF(GenderFIlter, COUNTROWS(VALUES(data[Gender])))+ 
      IF(AgeFilter, COUNTROWS(VALUES(data[Age Group])))+
      IF(RaceFilter, COUNTROWS(VALUES(data[Race])))+ 
      IF(WaittimeFilter,1)+
      IF(TargetFilter, COUNTROWS(VALUES(data[Target Status])))+ 
      IF(AdmissionFIlter, COUNTROWS(VALUES(data[Admission])))+ 
      IF(DateFilter, 1)+
      IF(TimeFilter, COUNTROWS(VALUES(data[Hour Group])))+ 
      IF(DepartmentFilter, COUNTROWS(VALUES(data[Department])))+
      IF(ScoreFilter, COUNTROWS(VALUES(data[Satisfaction Score]))) 
  
  VAR Filters= 
      IF( GenderFIlter || AgeFilter || RaceFilter || WaittimeFilter || TargetFilter || AdmissionFIlter || DateFilter || TimeFilter || DepartmentFilter || ScoreFilter, 
          IF(GenderFIlter, Gender & "; ") & 
          IF(AgeFilter,Age & "; ") & 
          IF(RaceFilter, Race & "; ") & 
          IF(WaittimeFilter, Waittime & "; ") & 
          IF(TargetFilter, Target & "; ") & 
          IF(AdmissionFilter, Admission & "; ") & 
          IF(DateFilter, _Date & "; ") & 
          IF(TimeFilter, _Time & "; ") & 
          IF(DepartmentFilter, Department & "; ") & 
          IF(ScoreFilter, Score & "; "), 
          "No filter applied"
      ) 
  
  VAR FilterMaxDisplay= IF(Countfilter<=Maxfilter, Filters, "Multiple Selection (" & Countfilter & "active filters)") 
  
  Return "𝐀𝐜𝐭𝐢𝐯𝐞 𝐅𝐢𝐥𝐭𝐞𝐫(s): " & FilterMaxDisplay
  ```
  
  * **Format**: `General`

---

**🧠 Explanation of Complex Logics**

* **Dynamic Period-over-Period (PoP)**: Unlike standard `SAMEPERIODLASTYEAR` functions which require full years of data, the `PoP` measures in this model use a "Sliding Window" logic. The formula calculates `NumDays` (the duration of the user's current selection) and subtracts that exact number from the start/end dates to define the `PrevStart` and `PrevEnd`. This allows the user to compare "Last 7 Days vs. Previous 7 Days" or "Last 3 Months vs. Previous 3 Months" seamlessly. It also includes a `DATE(2023, 1, 4)` guardrail to prevent the calculation from running into periods where no data exists.

* **Sparkline Min/Max Markers**: Measures like `Max(MP)` or `Min(MW)` are designed to clean up line charts. Instead of showing data labels for every single data point (which looks cluttered), these measures use `SWITCH` to check if the current data point matches the global Max or Min for the selected period. If it does, it returns the value; if not, it returns blank (`""`). When added to a chart as a secondary series, this creates isolated "dots" only on the peak and valley of the trend line.

* **Context-Aware KPI Coloring**: The `MoM Color` measures include specific business logic for the Emergency Room. While an increase in Patients (`>0`) is generally coded Green, an increase in Wait Time (`>0`) is coded Red (`#D90227`). This ensures that the dashboard traffic lights reflect operational health (Efficiency) rather than just mathematical growth.

* **Smart Header Construction**: The `Active Filters` measure is a massive concatenation string that inspects every slicer on the page (`ISFILTERED`). It builds a natural language summary sentence (e.g., "Active Filters: Gender: Male; Age: 18-24;"). It also includes a `Countfilter` check; if the user selects too many options (>20), it collapses the text into "Multiple Selection" to prevent the header from breaking the visual layout.
