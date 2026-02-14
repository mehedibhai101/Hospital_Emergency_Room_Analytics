# 🏗️ Calculated Columns: Hospital Emergency Room Analytics

This documentation details the structural data enhancements for the Emergency Room (ER) analysis model, focusing on temporal and demographic segmentation to drive operational insights.

* **Age Group (data)**:
Categorizes patients into 10-year deciles. This is essential for identifying which demographic segments are most frequently utilizing ER services (e.g., pediatric vs. geriatric volume).

  ```dax
  SWITCH( TRUE(),
      data[Age] <= 9,  "01-09",
      data[Age] <= 19, "10-19",
      data[Age] <= 29, "20-29",
      data[Age] <= 39, "30-39",
      data[Age] <= 49, "40-49",
      data[Age] <= 59, "50-59",
      data[Age] <= 69, "60-69",
      data[Age] <= 79, "70-79",
      ""
  )
  ```

* **Hour Group (data)**:
Segments the 24-hour cycle into 3-hour blocks. This allows hospital administration to visualize peak arrival windows and adjust staffing levels accordingly.

  ```dax
  SWITCH( TRUE(),
      data[Time] >= TIME(0,0,0)   && data[Time] < TIME(3,0,0), "00-03",
      data[Time] >= TIME(3,0,0)  && data[Time] < TIME(6,0,0), "03-06",
      data[Time] >= TIME(6,0,0)  && data[Time] < TIME(9,0,0), "06-09",
      data[Time] >= TIME(9,0,0)  && data[Time] < TIME(12,0,0), "09-12",
      data[Time] >= TIME(12,0,0) && data[Time] < TIME(15,0,0), "12-15",
      data[Time] >= TIME(15,0,0) && data[Time] < TIME(18,0,0), "15-18",
      data[Time] >= TIME(18,0,0) && data[Time] < TIME(21,0,0), "18-21",
      data[Time] >= TIME(21,0,0) && data[Time] < TIME(23,59,59), "21-00", 
      "" 
  )
  ```

---

**🧠 Explanation of Complex Logics**

**Temporal Load Balancing**: The `Hour Group` logic is the foundation for the ER's "Heatmap" visuals. By grouping timestamps into 3-hour intervals, we transform messy, continuous data into discrete categories. This reveals "Rush Hour" patterns—for instance, if the 18-21 (6 PM - 9 PM) bucket consistently shows a 40% higher volume, the hospital can shift part-time nursing staff to overlap specifically during those hours.

**Demographic Deciles**: The `Age Group` column uses a `SWITCH(TRUE())` pattern, which is more performant than nested `IF` statements in Power BI. The use of leading zeros (e.g., "01-09") is a strategic formatting choice; it ensures that the categories sort alphabetically/numerically correct on axis labels without requiring a separate "Sort By" column.

**Operational Efficiency**: These columns, when combined with the `Avg Waittime` measures created previously, allow for "Wait Time by Hour" analysis. This identifies whether long wait times are a result of total patient volume or a specific lack of resources during overnight "Hour Groups" (00-06).
