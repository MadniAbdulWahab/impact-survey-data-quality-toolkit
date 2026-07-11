Attribute VB_Name = "modQCExport"
' RefreshAndExportQC - refresh every query and pivot, then export a QC summary.
'
' Synthetic data only. Import this module with
' Alt+F11 > File > Import File, then save the workbook as .xlsm and run
' RefreshAndExportQC (Alt+F8). The macro:
'   1. refreshes all Power Query connections and waits for them to finish;
'   2. refreshes every pivot cache;
'   3. counts the seven QC flags on the Entry_Demo sheet;
'   4. writes a QC_Export sheet and a timestamped CSV under excel\exports\.
'
' The macro makes no network calls and does not alter the raw data.
Option Explicit

Private Const FLAG_FIRST_ROW As Long = 3
Private Const FLAG_FIRST_COL As Long = 28   ' column AB (qc_missing_required)
Private Const FLAG_LAST_COL As Long = 34    ' column AH (qc_skip_logic)

Public Sub RefreshAndExportQC()
    Dim ws As Worksheet
    Dim pc As PivotCache

    On Error GoTo Failed

    ' 1. Refresh all queries and connections, then wait for async ones.
    ThisWorkbook.RefreshAll
    Application.CalculateUntilAsyncQueriesDone

    ' 2. Refresh every pivot cache explicitly.
    For Each pc In ThisWorkbook.PivotCaches
        pc.Refresh
    Next pc

    ' 3. Build the QC summary from the Entry_Demo flag columns.
    Dim demo As Worksheet
    Set demo = ThisWorkbook.Worksheets("Entry_Demo")

    Dim lastRow As Long
    lastRow = demo.Cells(demo.Rows.Count, 1).End(xlUp).Row
    If lastRow < FLAG_FIRST_ROW Then lastRow = FLAG_FIRST_ROW

    Dim col As Long
    Dim ruleName As String
    Dim flaggedRows As Long
    Dim summary As Worksheet

    Set summary = EnsureSheet("QC_Export")
    summary.Cells.Clear
    summary.Range("A1").Value = "Synthetic QC export - generated " & Format(Now, "yyyy-mm-dd hh:nn:ss")
    summary.Range("A2").Value = "QC rule"
    summary.Range("B2").Value = "Flagged rows"

    Dim outRow As Long
    outRow = 3
    For col = FLAG_FIRST_COL To FLAG_LAST_COL
        ruleName = CStr(demo.Cells(2, col).Value)
        Dim rng As Range
        Set rng = demo.Range(demo.Cells(FLAG_FIRST_ROW, col), demo.Cells(lastRow, col))
        Dim ruleCount As Long
        ruleCount = Application.WorksheetFunction.CountIf(rng, True)
        summary.Cells(outRow, 1).Value = ruleName
        summary.Cells(outRow, 2).Value = ruleCount
        outRow = outRow + 1
    Next col

    ' Total records carrying at least one flag (qc_any_issue is column AJ = 36).
    Dim anyRange As Range
    Set anyRange = demo.Range(demo.Cells(FLAG_FIRST_ROW, 36), demo.Cells(lastRow, 36))
    flaggedRows = Application.WorksheetFunction.CountIf(anyRange, True)
    summary.Cells(outRow, 1).Value = "records_with_any_flag"
    summary.Cells(outRow, 2).Value = flaggedRows

    summary.Columns("A:B").AutoFit

    ' 4. Export the summary to a timestamped CSV under excel\exports\.
    Dim exportDir As String
    exportDir = ThisWorkbook.Path & Application.PathSeparator & "exports"
    If Len(Dir(exportDir, vbDirectory)) = 0 Then MkDir exportDir

    Dim exportPath As String
    exportPath = exportDir & Application.PathSeparator & _
        "qc_report_" & Format(Now, "yyyymmdd_hhnnss") & ".csv"

    WriteSummaryCsv summary, outRow, exportPath

    MsgBox "QC export complete." & vbCrLf & _
           "Records with any flag: " & flaggedRows & vbCrLf & _
           "Saved: " & exportPath, vbInformation
    Exit Sub

Failed:
    MsgBox "RefreshAndExportQC stopped: " & Err.Description, vbExclamation
End Sub

Private Function EnsureSheet(sheetName As String) As Worksheet
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets(sheetName)
    On Error GoTo 0
    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
        ws.Name = sheetName
    End If
    Set EnsureSheet = ws
End Function

Private Sub WriteSummaryCsv(summary As Worksheet, lastRow As Long, filePath As String)
    Dim fileNum As Integer
    Dim r As Long
    fileNum = FreeFile
    Open filePath For Output As #fileNum
    Print #fileNum, "qc_rule,flagged_rows"
    For r = 3 To lastRow
        Print #fileNum, CStr(summary.Cells(r, 1).Value) & "," & CStr(summary.Cells(r, 2).Value)
    Next r
    Close #fileNum
End Sub
