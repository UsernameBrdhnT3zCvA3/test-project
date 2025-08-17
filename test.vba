Option Explicit

' A列のキーワード（セルの文字列）とそのセルの背景色を参照し、
' C列以降のログセルにキーワードが含まれる場合、その色で塗りつぶす単一のSubです。
' 実行名（日本語）: 色付け実行

Sub 色付け実行()
    Dim ws As Worksheet
    Set ws = ActiveSheet
    
    Dim lastA As Long, i As Long
    Dim keys() As String, colors() As Long, keyCount As Long
    Dim r As Long, c As Long, lastRow As Long, lastCol As Long
    Dim rngAll As Range
    Dim cellText As String
    
    ' A列の最終行を取得してキーワードと色を収集
    lastA = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    keyCount = 0
    For i = 1 To lastA
        If Trim(CStr(ws.Cells(i, "A").Value)) <> "" Then
            keyCount = keyCount + 1
            ReDim Preserve keys(1 To keyCount)
            ReDim Preserve colors(1 To keyCount)
            keys(keyCount) = CStr(ws.Cells(i, "A").Value)
            colors(keyCount) = ws.Cells(i, "A").Interior.Color
        End If
    Next i
    
    If keyCount = 0 Then
        MsgBox "A列にキーワードが見つかりません。", vbExclamation
        Exit Sub
    End If
    
    ' シート上の最終使用行・列を取得（C列以降が対象）
    On Error Resume Next
    lastRow = ws.Cells.Find(What:="*", After:=ws.Cells(1, 1), LookIn:=xlFormulas, _
                LookAt:=xlPart, SearchOrder:=xlByRows, SearchDirection:=xlPrevious).Row
    lastCol = ws.Cells.Find(What:="*", After:=ws.Cells(1, 1), LookIn:=xlFormulas, _
                LookAt:=xlPart, SearchOrder:=xlByColumns, SearchDirection:=xlPrevious).Column
    On Error GoTo 0
    
    If lastRow = 0 Or lastCol < 3 Then
        MsgBox "C列以降に処理対象のデータがありません。", vbInformation
        Exit Sub
    End If
    
    ' 対象範囲の既存の塗りつぶしをクリア（必要なければこの行をコメントアウト）
    Set rngAll = ws.Range(ws.Cells(1, 3), ws.Cells(lastRow, lastCol))
    rngAll.Interior.Pattern = xlNone
    
    ' 各セルを走査し、A列のキーワードが含まれていれば対応する色で塗る
    For r = 1 To lastRow
        For c = 3 To lastCol
            cellText = CStr(ws.Cells(r, c).Value)
            If Len(Trim(cellText)) > 0 Then
                For i = 1 To keyCount
                    If InStr(1, cellText, keys(i), vbTextCompare) > 0 Then
                        ws.Cells(r, c).Interior.Color = colors(i)
                        Exit For ' 最初にマッチしたキーワードの色を使う
                    End If
                Next i
            End If
        Next c
    Next r

    ' 完了メッセージは表示しない（要求に合わせて省略）
End Sub
