Sub teduri()
Dim lastRow
Dim lastCol
Dim lastAdd
Dim i As Long
Dim rng As Range

lastRow = Worksheets("Sheet1").Cells.Find("*", SearchOrder:=xlByRows, SearchDirection:=xlPrevious).Row
lastCol = Worksheets("Sheet1").Cells.Find("*", SearchOrder:=xlByColumns, SearchDirection:=xlPrevious).Column
lastAdd = ActiveSheet.Cells(lastRow, lastCol).Address 'address값으로 변환하게 되면 cells(1,1)이 (A,1)인 것처럼 변환됨

'시트 새로고침 off
Application.ScreenUpdating = False

For i = 1 To lastCol
    Set rng = Range(Cells(1, i), Cells(lastRow, i))
    rng.Borders.LineStyle = xlContinuous
    rng.Borders.Weight = xlThin
    rng.Borders.ColorIndex = xlAutomatic
    If i = 1 Then
        rng.Borders(xlEdgeLeft).Weight = xlMedium
        rng.Borders(xlEdgeLeft).ColorIndex = 1
    ElseIf i = lastCol Then
        rng.Borders(xlEdgeRight).Weight = xlMedium
        rng.Borders(xlEdgeRight).ColorIndex = 1
    End If
Next i

Set rng = Range(Cells(1, 1), Cells(lastRow, lastCol))
rng.Borders(xlEdgeTop).Weight = xlMedium
rng.Borders(xlEdgeTop).ColorIndex = 1
rng.Borders(xlEdgeBottom).Weight = xlMedium
rng.Borders(xlEdgeBottom).ColorIndex = 1

'테두리 적용 완료
Application.ScreenUpdating = True
End Sub
