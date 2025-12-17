Sub tg_gray_highlight()

If selection.Interior.Color = vbWhite Then
Selection.Interior.Color = RGB(220,220,220)

Selection.WrapText = True

With Selection
	.HorizontalAlignment = xlCenter
	.VerticalAlignment= xlCenter
End With

Else
Selection.Interior.Color = vbWhite
Selection.Font.Color = RGB(0,0,0)

Selection.WrapText = False

With Selection
	.HorizontalAlignment = xlCenter
	.VerticalAlignment = xlCenter
End With

End If