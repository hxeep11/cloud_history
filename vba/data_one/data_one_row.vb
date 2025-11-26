Sub data_one_row()
Dim i  As Long
Dim a As Range

'끝 열의 숫자 값 갖고오기
'항상 이 구문을 사용할 때는 activesheet를 붙여서 객체가 존재하게끔 해주고,
'끝에 row나 column에 s가 붙지 않는 것을 인식해야 함
lastRow = ActiveSheet.Cells.Find("*", SearchOrder:=xlByRows, SearchDirection:=xlPrevious).row
'Cells.Select ' 공백 지우기
'Selection.SpecialCells(xlCellTypeBlanks).Select
'Selection.Delete Shift:=xlUp

For i = 1 To lastRow
    Range(Range("b1"), Range("b300000").End(xlUp)).Select

'B열의 값이 0이면, 종료
    If IsEmpty(Selection) = True Then
        Exit Sub
    End If

    Application.CutCopyMode = False
    Selection.Cut

    Cells(1, 1).End(xlDown).Offset(1).Select
    ActiveSheet.Paste

    Range("b1").EntireColumn.Select '헤더 부분을 제외하기 위한 마지막 라인 복사 제외
    Selection.Delete Shift:=xlToLeft
    i = i + 1
Next i
End Sub