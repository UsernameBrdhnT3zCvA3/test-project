Sub FormatTextWrapping()
    Dim ws As Worksheet
    Set ws = ActiveSheet
    
    Dim formatRule As String
    formatRule = "ST:13 EV:11"
    
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, 3).End(xlUp).Row
    If lastRow < 1 Then Exit Sub
    
    ' C列からJ列まで順番に処理
    Dim currentCol As Long
    For currentCol = 3 To 10
        Dim currentLastRow As Long
        currentLastRow = ws.Cells(ws.Rows.Count, currentCol).End(xlUp).Row
        
        Dim i As Long
        For i = 1 To currentLastRow
            If ws.Cells(i, currentCol).Value <> "" Then
                Dim logText As String
                logText = CStr(ws.Cells(i, currentCol).Value)
                
                ' ST:13 EV:11が見つかったら移動処理
                If InStr(1, logText, formatRule, vbTextCompare) > 0 Then
                    Dim targetCol As Long
                    targetCol = currentCol + 1
                    
                    ' 下にデータがあるかチェック
                    Dim hasDataBelow As Boolean
                    hasDataBelow = False
                    
                    If i + 1 <= currentLastRow Then
                        Dim checkRow As Long
                        For checkRow = i + 1 To currentLastRow
                            If ws.Cells(checkRow, currentCol).Value <> "" Then
                                hasDataBelow = True
                                Exit For
                            End If
                        Next checkRow
                    End If
                    
                    If hasDataBelow Then
                        ' 一括移動処理
                        Dim sourceRange As Range
                        Set sourceRange = ws.Range(ws.Cells(i + 1, currentCol), ws.Cells(currentLastRow, currentCol))
                        
                        Dim destRange As Range
                        Set destRange = ws.Cells(3, targetCol)
                        
                        sourceRange.Copy destRange
                        sourceRange.ClearContents
                    Else
                        Exit Sub
                    End If
                    
                    Exit For
                End If
            End If
        Next i
    Next currentCol
End Sub

Sub ApplyColorFormatting()
    Dim ws As Worksheet
    Set ws = ActiveSheet
    
    ' A列のルールを配列に格納
    Dim lastRuleRow As Long
    lastRuleRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    
    Dim colorRules(1 To 100) As String
    Dim colorValues(1 To 100) As Long
    Dim ruleCount As Long
    ruleCount = 0
    
    Dim k As Long
    For k = 1 To lastRuleRow
        If Trim(ws.Cells(k, 1).Value) <> "" Then
            ruleCount = ruleCount + 1
            If ruleCount <= 100 Then
                colorRules(ruleCount) = Trim(ws.Cells(k, 1).Value)
                colorValues(ruleCount) = ws.Cells(k, 1).Interior.Color
            End If
        End If
    Next k
    
    ' ログ範囲を処理
    Dim lastRow As Long
    Dim lastCol As Long
    lastRow = ws.Cells(ws.Rows.Count, 3).End(xlUp).Row
    lastCol = 10
    
    If lastRow < 1 Then Exit Sub
    
    ' まず対象範囲の色をすべてクリア
    Dim clearRange As Range
    Set clearRange = ws.Range(ws.Cells(1, 3), ws.Cells(lastRow, lastCol))
    clearRange.Interior.ColorIndex = xlNone
    
    Dim i As Long, j As Long
    For i = 1 To lastRow
        For j = 3 To lastCol
            If ws.Cells(i, j).Value <> "" Then
                Dim logText As String
                logText = CStr(ws.Cells(i, j).Value)
                
                ' ルールをチェックして色付け
                If ruleCount > 0 Then
                    Dim r As Long
                    For r = 1 To ruleCount
                        If colorRules(r) <> "" And InStr(1, logText, colorRules(r), vbTextCompare) > 0 Then
                            ws.Cells(i, j).Interior.Color = colorValues(r)
                            Exit For
                        End If
                    Next r
                End If
            End If
        Next j
    Next i
End Sub