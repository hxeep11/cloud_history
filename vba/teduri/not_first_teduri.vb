Sub not_first_teduri()

    Dim ws As Worksheet
    Dim lastRow As Long
    Dim lastCol As Long
    Dim firstRow As Long
    Dim firstCol As Long
    Dim i As Long
    Dim rng As Range
    
    Set ws = Worksheets("Sheet1")
    
    ' 시트에 데이터가 있는 마지막 행/열
    lastRow = ws.Cells.Find("*", SearchOrder:=xlByRows, SearchDirection:=xlPrevious).Row
    lastCol = ws.Cells.Find("*", SearchOrder:=xlByColumns, SearchDirection:=xlPrevious).Column
    
    ' 시트에 데이터가 있는 첫 행/열  ← ★추가된 부분
    firstRow = ws.Cells.Find("*", SearchOrder:=xlByRows, SearchDirection:=xlNext).Row
    firstCol = ws.Cells.Find("*", SearchOrder:=xlByColumns, SearchDirection:=xlNext).Column
    
    ' 시트 새로고침 off
    Application.ScreenUpdating = False
     
    ' 세로 방향(열 단위)로 테두리 적용
    For i = firstCol To lastCol
        Set rng = ws.Range(ws.Cells(firstRow, i), ws.Cells(lastRow, i))
        With rng.Borders
            .LineStyle = xlContinuous
            .Weight = xlThin
            .ColorIndex = xlAutomatic
        End With
        
        ' 맨 왼쪽/오른쪽 굵은 테두리
        If i = firstCol Then
            rng.Borders(xlEdgeLeft).Weight = xlMedium
            rng.Borders(xlEdgeLeft).ColorIndex = 1
        ElseIf i = lastCol Then
            rng.Borders(xlEdgeRight).Weight = xlMedium
            rng.Borders(xlEdgeRight).ColorIndex = 1
        End If
    Next i
    
    ' 전체 범위의 위/아래 굵은 테두리
    Set rng = ws.Range(ws.Cells(firstRow, firstCol), ws.Cells(lastRow, lastCol))
    rng.Borders(xlEdgeTop).Weight = xlMedium
    rng.Borders(xlEdgeTop).ColorIndex = 1
    rng.Borders(xlEdgeBottom).Weight = xlMedium
    rng.Borders(xlEdgeBottom).ColorIndex = 1
    
    Application.ScreenUpdating = True

End Sub