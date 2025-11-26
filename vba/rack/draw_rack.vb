Sub clear()
Set ws = ThisWorkbook.Sheets("Sheet1")
    ' 드로잉 영역을 초기화합니다.
    Range("F1:BW500").Select
    Selection.ColumnWidth = 1.9
    Selection.Cut

    ws.Range("F1:BW41").Clear
    ws.Range("F:BW").ColumnWidth = 1.9


Columns("A:E").Select
Selection.Delete Shift:=xlToLeft
Columns("A:A").Select
Selection.Insert Shift:=xlToRight
Selection.Insert Shift:=xlToRight
Selection.Insert Shift:=xlToRight
Selection.Insert Shift:=xlToRight
Selection.Insert Shift:=xlToRight
End Sub
' ----------------------------------------------------
Sub base()

' 엑셀 시트명을 지정하세요.
' 현재 시트가 "Sheet1"이 아니라면 아래 "Sheet1"을 수정하세요.
Dim ws As Worksheet
Set ws = ThisWorkbook.Sheets("Sheet1")

' --- 첫 번째 랙 그룹 정보 입력 (D4~E19) ---
Dim startRange1 As Range
Dim numGroups1 As Integer
Set startRange1 = ws.Range("F4:G19")
numGroups1 = 17 ' 추가 배치할 그룹 수

' --- 두 번째 랙 그룹 정보 입력 (H28~I41) ---
Dim startRange2 As Range
Dim numGroups2 As Integer
Set startRange2 = ws.Range("J28:K41")
numGroups2 = 16 ' 추가 배치할 그룹 수

' 그룹 간 간격 (컬럼 수)
Dim offsetCols As Integer
offsetCols = 2

' 그리기 함수 호출
Call group(startRange1, numGroups1, offsetCols)
Call group(startRange2, numGroups2, offsetCols)

End Sub

' ----------------------------------------------------
Sub draw()

    ' ----------------------------------------------------
    ' ▼▼▼ 아래 변수들을 수정하여 사용하세요 ▼▼▼
    ' ----------------------------------------------------

    ' 1. 데이터가 입력된 시트명과 시작 셀을 지정합니다.
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Sheet1")
    Dim dataStartCell As Range
    Set dataStartCell = ws.Range("A1")

    ' 2. 그룹별 랙의 기준 좌표를 설정합니다.
    '    (D열의 데이터를 읽지만, 그리는 위치는 E열부터 시작합니다.)
    Dim baseCellA As Range
    Set baseCellA = ws.Range("F19") ' A그룹 라인 01의 시작점

    Dim baseCellB As Range
    Set baseCellB = ws.Range("J28") ' B그룹 라인 02의 시작점

    ' ----------------------------------------------------
    ' ▲▲▲ 위 변수들을 수정하여 사용하세요 ▲▲▲
    ' ----------------------------------------------------

    Dim lastRow As Long
    Dim currentRow As Long
    Dim group As String
    Dim lineNumber As Integer
    Dim rackPosition As Integer
    Dim colorCase As String
    Dim status As String
    Dim targetRow As Long
    Dim targetCol As Long
    Dim targetColor As Long

    ' A열의 마지막 데이터가 있는 행을 찾습니다.
    On Error Resume Next
    lastRow = ws.Cells(ws.Rows.Count, dataStartCell.Column).End(xlUp).Row
    If lastRow < dataStartCell.Row Then
        MsgBox "데이터가 없습니다. A열에 데이터를 입력해주세요.", vbExclamation, "작업 중단"
        Exit Sub
    End If
    On Error GoTo 0

    If Not IsEmpty(ws.Cells(dataStartCell.Row, dataStartCell.Column)) Then
        If Not IsNumeric(ws.Cells(dataStartCell.Row, dataStartCell.Column).Value) Then
            currentRow = dataStartCell.Row + 1
        Else
            currentRow = dataStartCell.Row
        End If
    Else
        MsgBox "데이터가 없습니다. A열에 데이터를 입력해주세요.", vbExclamation, "작업 중단"
        Exit Sub
    End If

    ' 데이터가 있는 모든 행을 순회합니다.
    Do While Not IsEmpty(ws.Cells(currentRow, dataStartCell.Column))
        group = UCase(Trim(ws.Cells(currentRow, dataStartCell.Column).Value))

        If group = "" Or Not IsNumeric(ws.Cells(currentRow, dataStartCell.Column + 1).Value) Or _
           Not IsNumeric(ws.Cells(currentRow, dataStartCell.Column + 2).Value) Then GoTo NextRow

        lineNumber = CInt(Trim(ws.Cells(currentRow, dataStartCell.Column + 1).Value))
        rackPosition = CInt(Trim(ws.Cells(currentRow, dataStartCell.Column + 2).Value))
        colorCase = Trim(ws.Cells(currentRow, dataStartCell.Column + 3).Value) ' D열의 값을 읽어옴
        status = UCase(Trim(ws.Cells(currentRow, dataStartCell.Column + 4).Value)) ' E열의 값을 읽어옴 (O, X 등)

        ' E열 값이 "X"인 경우 예외 처리
        If status = "X" Then
            targetColor = RGB(255, 0, 0) ' 빨간색으로 지정

            If group = "A" Then
                targetCol = baseCellA.Column + (lineNumber - 1) * 4
                targetRow = baseCellA.Row - rackPosition

                With ws.Cells(targetRow, targetCol).Resize(1, 2)
                    .Interior.Color = targetColor
                    .Borders.LineStyle = xlContinuous
                    .Cells(1, 2).Value = rackPosition Mod 10 ' 랙 번호만 입력
                    ws.Cells(targetRow, targetCol + 2).Value = "X" ' 옆 셀에 "X" 입력
                End With

            ElseIf group = "B" Then
                targetCol = baseCellB.Column + (lineNumber - 2) * 4
                If rackPosition < 0 Then
                    targetRow = baseCellB.Row + (rackPosition * -1)
                Else
                    targetRow = baseCellB.Row + rackPosition
                End If

                With ws.Cells(targetRow, targetCol).Resize(1, 2)
                    .Interior.Color = targetColor
                    .Borders.LineStyle = xlContinuous
                    .Cells(1, 2).Value = rackPosition Mod 10 ' 랙 번호만 입력
                    ws.Cells(targetRow, targetCol + 2).Value = "X" ' 옆 셀에 "X" 입력
                End With
            End If
            GoTo NextRow
        End If

        ' E열 값이 "X"가 아닌 경우 기존 D열 값에 따라 색상 선택
        Select Case UCase(colorCase)
            Case "우리은행"
                targetColor = RGB(51, 153, 255)
            Case "우리FIS"
                targetColor = RGB(0, 255, 255)
            Case "우리카드"
                targetColor = RGB(51, 204, 0)
            Case "지주"
                targetColor = RGB(102, 102, 0)
            Case "공통"
                targetColor = RGB(255, 255, 0)
            Case "우리펀드"
                targetColor = RGB(204, 102, 204)
            Case "클라우드"
                targetColor = RGB(255, 217, 102)
            Case "우리투자증권"
                targetColor = RGB(204, 0, 153)
            Case "우리종합금융"
                targetColor = RGB(204, 0, 153)
            Case Else
                targetColor = RGB(204, 204, 204)
        End Select

        ' A그룹의 위치를 계산하고 색칠합니다.
        If group = "A" Then
            targetCol = baseCellA.Column + (lineNumber - 1) * 4
            If rackPosition < 0 Then
                targetRow = baseCellA.Row - (rackPosition)
            Else
                targetRow = baseCellA.Row - rackPosition
            End If

            With ws.Cells(targetRow, targetCol).Resize(1, 2)
                .Interior.Color = targetColor
                .Borders.LineStyle = xlContinuous
                .Cells(1, 2).Value = rackPosition Mod 10
            End With

        ' B그룹의 위치를 계산하고 색칠합니다.
        ElseIf group = "B" Then
            targetCol = baseCellB.Column + (lineNumber - 2) * 4
            If rackPosition < 0 Then
                targetRow = baseCellB.Row + (rackPosition * -1)
            Else
                targetRow = baseCellB.Row + rackPosition
            End If

            With ws.Cells(targetRow, targetCol).Resize(1, 2)
                .Interior.Color = targetColor
                .Borders.LineStyle = xlContinuous
                .Cells(1, 2).Value = rackPosition Mod 10
            End With
        End If

NextRow:
        currentRow = currentRow + 1
    Loop

    MsgBox "랙 배치도 그리기가 완료되었습니다.", vbInformation, "완료"
End Sub
' ----------------------------------------------------
Sub color()

Dim ws As Worksheet
Dim startCell As Range
Dim legendRow As Long

' 작업을 수행할 시트와 시작 셀을 지정합니다.
Set ws = ThisWorkbook.Sheets("Sheet1")
Set startCell = ws.Range("BX4") ' BX열 4행부터 시작

' 기존 색상표를 초기화합니다.
ws.Range("BV4:BX" & ws.Rows.Count).ClearContents
ws.Range("BV4:BX" & ws.Rows.Count).Interior.Color = xlNone

' 색상표 제목을 입력합니다.
startCell.Value = "색상 구분"
With startCell.Font
.Bold = True
.Size = 12
End With

legendRow = startCell.Row + 1

' Case별로 색상과 이름을 입력합니다.
' "우리은행"
ws.Cells(legendRow, startCell.Column).Interior.Color = RGB(173, 216, 230)
ws.Cells(legendRow, startCell.Column + 1).Value = "우리은행"

' "우리FIS"
legendRow = legendRow + 1
ws.Cells(legendRow, startCell.Column).Interior.Color = RGB(255, 182, 193)
ws.Cells(legendRow, startCell.Column + 1).Value = "우리FIS"

' "우리카드"
legendRow = legendRow + 1
ws.Cells(legendRow, startCell.Column).Interior.Color = RGB(144, 238, 144)
ws.Cells(legendRow, startCell.Column + 1).Value = "우리카드"

' "지주"
legendRow = legendRow + 1
ws.Cells(legendRow, startCell.Column).Interior.Color = RGB(255, 255, 153)
ws.Cells(legendRow, startCell.Column + 1).Value = "지주"

' "공통"
legendRow = legendRow + 1
ws.Cells(legendRow, startCell.Column).Interior.Color = RGB(229, 117, 241)
ws.Cells(legendRow, startCell.Column + 1).Value = "공통"

' "클라우드"
legendRow = legendRow + 1
ws.Cells(legendRow, startCell.Column).Interior.Color = RGB(134, 12, 12)
ws.Cells(legendRow, startCell.Column + 1).Value = "클라우드"

' "우리펀드", "우리투자증권"
legendRow = legendRow + 1
ws.Cells(legendRow, startCell.Column).Interior.Color = RGB(81, 175, 85)
ws.Cells(legendRow, startCell.Column + 1).Value = "우리펀드 / 우리투자증권"

' 그 외 (기본 회색)
legendRow = legendRow + 1
ws.Cells(legendRow, startCell.Column).Interior.Color = RGB(230, 230, 230)
ws.Cells(legendRow, startCell.Column + 1).Value = "그 외"

MsgBox "색상 구분이 완료되었습니다.", vbInformation, "완료"

End Sub
' ----------------------------------------------------
Sub group(ByVal startRange As Range, ByVal numGroups As Integer, ByVal offsetCols As Integer)

Dim i As Integer
Dim currentRange As Range
Dim totalColOffset As Integer

' 시작 그룹을 먼저 그립니다.
With startRange
.Borders.LineStyle = xlContinuous
.Borders.Weight = xlMedium
.Interior.Color = RGB(204, 255, 204) ' 연한 회색으로 채우기
End With

' 추가 그룹들을 그립니다.
For i = 1 To numGroups
' 다음 그룹의 시작 위치를 계산합니다.
' (시작 그룹의 컬럼 수 + 간격) * (그룹 인덱스)
totalColOffset = (startRange.Columns.Count + offsetCols) * i

' 새로운 범위를 지정합니다.
Set currentRange = startRange.Offset(0, totalColOffset)

' 새로운 그룹에 테두리와 색을 적용합니다.
With currentRange
.Borders.LineStyle = xlContinuous
.Borders.Weight = xlMedium
.Interior.Color = RGB(204, 255, 204) ' 연한 회색으로 채우기
End With
Next i

End Sub