'개량버전 221215 - 오류 존재함 데이터가 너무 길면 오류 뿜뿜, 끝까지 가는지 확인 못함
Sub copytoppt()
Dim tabname As String
Dim pptapp As PowerPoint.Application
Dim pptpres As PowerPoint.presentation
Dim pptslide As PowerPoint.slide
Dim pptslidecount As Integer
Dim i, lngC As Long
Dim rng As Range

Application.DisplayAlerts = False

'lngR = Range("a1", Range("A300000").End(xlUp)).Rows.Count
lngC = Range("a1", Range("XFD1").End(xlToLeft)).Columns.Count

'시트 새로고침 off
Application.ScreenUpdating = False
On Error Resume Next
Set pptapp = GetObject(, "powerpoint.application")
On Error GoTo 0

'열려있는 파워포인트 파일이 없으면 실행하고 프리젠테이션 생성
If pptapp Is Nothing Then
Set pptapp = New PowerPoint.Application
Set pptpres = pptapp.presentations.Add
End If
'프리젠터이션 선택
Set pptpres = pptapp.activepresentation

'슬라이드 페이지 수를 세고 뒤에 하나 더 추가
pptslidecount = pptpres.slides.Count
Set pptslide = pptpres.slides.Add(pptslidecount + 1, pplayoutblank)

For i = 1 To lngC
Cells(1, i).Select
Range(ActiveCell, ActiveCell.End(xlDown)).Select

Selection.Copy

If i Mod 100 = 0 Then
pptslidecount = pptpres.slides.Count
Set pptslide = pptpres.slides.Add(pptslidecount + 1, pplayoutblank)
End If

pptslide.Shapes.PasteSpecial pppasteenhancedmetafile

Next i

Application.ScreenUpdating = True
pptapp.Visible = True

'clear the clipboard
Application.CutCopyMode = False
Set pptslide = Nothing
Set pptpres = Nothing
Set pptapp = Nothing

End Sub