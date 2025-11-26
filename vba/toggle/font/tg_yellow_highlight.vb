Sub tg-yellow-highlight()

    If Selection.Interior.Color = vbYellow Then
        Selection.Interior.Color = xlNone

        Selection.WrapText = False

    Else
        Selection.Interior.Color = vbYellow

        Selection.WrapText = True

    End If

End Sub