let
    // Source connection to the local CSV file
    Source = Folder.Files("your_folder_path"),
    File_Content = Source{[#"Folder Path"="your_folder_path\",Name="emergency_visits.csv"]}[Content],
    
    // Import the CSV with standard 1252 encoding
    Imported_CSV = Csv.Document(File_Content, [Delimiter=",", Columns=14, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    Promote_Headers = Table.PromoteHeaders(Imported_CSV, [PromoteAllScalars=true]),

    // Assigned types and handled the Date/Time split immediately for cleaner lineage.
    Set_Initial_Types = Table.TransformColumnTypes(Promote_Headers,{
        {"Patient Id", type text}, {"Patient Admission Date", type datetime}, {"Patient First Inital", type text}, 
        {"Patient Last Name", type text}, {"Patient Gender", type text}, {"Patient Age", Int64.Type}, 
        {"Patient Race", type text}, {"Admitted vs Not Admitted", type text}, {"Department Referral", type text}, 
        {"Patient Admin Flag", type logical}, {"Target Status", type text}, {"Patient Satisfaction Score", Int64.Type}, 
        {"Patient Waittime", Int64.Type}, {"Patients CM", Int64.Type}
    }),

    // Split DateTime into Date and Time components for "Time of Day" trend analysis.
    Add_Date = Table.AddColumn(Set_Initial_Types, "Date", each DateTime.Date([Patient Admission Date]), type date),
    Add_Time = Table.TransformColumns(Add_Date,{{"Patient Admission Date", DateTime.Time, type time}}),
    Rename_Time = Table.RenameColumns(Add_Time,{{"Patient Admission Date", "Time"}}),

    // Concatenated Patient Name (Initial + Last Name).
    Merge_Names = Table.CombineColumns(Rename_Time,{"Patient First Inital", "Patient Last Name"},Combiner.CombineTextByDelimiter(". ", QuoteStyle.None),"Name"),

    // Consolidated Gender & Race standardization using bulk replacement logic.
    Clean_Demographics = Table.TransformColumns(Merge_Names, {
        {"Patient Gender", each if _ = "M" or _ = "Male" then "♂" else if _ = "F" or _ = "Female" then "♀" else _, type text},
        {"Patient Race", each if _ = "Two or More Races" then "1+ Races" else if _ = "Declined to Identify" then "#N/A" else _, type text}
    }),

    // Cleaned Target Status and removed non-analytical administration flags.
    Standardize_Status = Table.ReplaceValue(Clean_Demographics,"Target Missed","Missed",Replacer.ReplaceText,{"Target Status"}),
    Remove_Flags = Table.RemoveColumns(Standardize_Status,{"Patient Admin Flag", "Patients CM"}),

    // Professionalized headers for ER Dashboard visuals.
    Final_Renaming = Table.RenameColumns(Remove_Flags,{
        {"Admitted vs Not Admitted", "Admission Status"}, {"Department Referral", "Department"}, 
        {"Patient Satisfaction Score", "Satisfaction Score"}, {"Patient Waittime", "Wait Time (Min)"}, 
        {"Patient Race", "Race"}, {"Patient Age", "Age"}, {"Patient Gender", "Gender"}
    }),

    // Reordered for logical data flow: Patient Identity -> Clinical Timing -> Performance.
    Reorder_Cols = Table.ReorderColumns(Final_Renaming,{"Patient Id", "Name", "Age", "Gender", "Race", "Wait Time (Min)", "Admission Status", "Date", "Time", "Department", "Target Status", "Satisfaction Score"}),

    // Created a unified Search index column for global filtering in the UI.
    Add_Search_Index = Table.AddColumn(Reorder_Cols, "Search", each Text.Combine({[Patient Id], [Name], Text.From([Age]), [Gender], [Race], [Department], [Admission Status]}, " | "), type text)
in
    Add_Search_Index
