Sub reveal-sheet()
'/// (숨겨진) 모든 이름을 보이게 함
Dim n As Name
For Each n In ThisWorkbook.Names
    n.Visible = True
Next n
End Sub