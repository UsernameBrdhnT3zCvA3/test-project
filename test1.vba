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


Public Sub 整形_ログを列分割()
    Dim ws As Worksheet: Set ws = ActiveSheet
    Dim FIRST_LOG_COL As Long: FIRST_LOG_COL = 3           ' C列=3
    Dim SPLIT_MARK As String: SPLIT_MARK = "ST:13 EV:11"   ' 区切り語

    Dim f As Range, baseRow As Long
    ' C列で最初に使われている行（=先頭行）を取得
    Set f = ws.Columns(FIRST_LOG_COL).Find(What:="*", After:=ws.Cells(ws.Rows.Count, FIRST_LOG_COL), _
                                           LookIn:=xlFormulas, LookAt:=xlPart, SearchOrder:=xlByRows, _
                                           SearchDirection:=xlNext, MatchCase:=False)
    If f Is Nothing Then Exit Sub
    baseRow = f.Row

    Dim curCol As Long: curCol = FIRST_LOG_COL
    Dim guard As Long

    Application.ScreenUpdating = False
    Application.EnableEvents = False

    Do
        guard = guard + 1: If guard > 200 Then Exit Do ' 念のため無限ループ防止

        ' 現在列の最終行
        Dim lastRow As Long
        Set f = ws.Columns(curCol).Find(What:="*", LookIn:=xlFormulas, LookAt:=xlPart, _
                                        SearchOrder:=xlByRows, SearchDirection:=xlPrevious, MatchCase:=False)
        If f Is Nothing Then Exit Do
        lastRow = f.Row
        If lastRow < baseRow Then Exit Do

        ' 区切りの最初の出現位置（部分一致）
        Dim r As Long, hitRow As Long: hitRow = 0
        For r = baseRow To lastRow
            If InStr(1, CStr(ws.Cells(r, curCol).Value), SPLIT_MARK, vbTextCompare) > 0 Then
                hitRow = r: Exit For
            End If
        Next r

        If hitRow = 0 Then Exit Do          ' 区切りなし
        If hitRow >= lastRow Then Exit Do   ' 区切りが末尾＝移動対象なし

        ' 区切り“以下”を次列へ。貼り付け開始行は baseRow に揃える
        Dim destCol As Long: destCol = curCol + 1
        ws.Range(ws.Cells(baseRow, destCol), ws.Cells(ws.Rows.Count, destCol)).Clear
        ws.Range(ws.Cells(hitRow + 1, curCol), ws.Cells(lastRow, curCol)) _
            .Cut Destination:=ws.Cells(baseRow, destCol)

        curCol = destCol ' 次の列へ
    Loop

    Application.CutCopyMode = False
    Application.EnableEvents = True
    Application.ScreenUpdating = True
End Sub

'――― 一括実行（リセット→色付け）―――
Public Sub 色付けをリセットして適用()
    Dim ws As Worksheet: Set ws = ActiveSheet
    
    Const RULES_COL As Long = 1   ' A列：キーワード＆そのセルの塗り色
    Const DATA_COL_START As Long = 3  ' C列から右を対象
    
    Dim lastCol As Long, baseRow As Long, lastRow As Long
    Dim f As Range, c As Long, r As Long
    
    ' 最終列
    Set f = ws.Cells.Find(What:="*", After:=ws.Cells(1, 1), LookIn:=xlFormulas, _
                          LookAt:=xlPart, SearchOrder:=xlByColumns, SearchDirection:=xlPrevious, MatchCase:=False)
    If f Is Nothing Then Exit Sub
    lastCol = f.Column
    If lastCol < DATA_COL_START Then Exit Sub
    
    ' C列以降の「最初に値がある行」（最小）
    baseRow = 0
    For c = DATA_COL_START To lastCol
        Set f = ws.Columns(c).Find(What:="*", After:=ws.Cells(ws.Rows.Count, c), _
                                   LookIn:=xlFormulas, LookAt:=xlPart, SearchOrder:=xlByRows, _
                                   SearchDirection:=xlNext, MatchCase:=False)
        If Not f Is Nothing Then
            If baseRow = 0 Or f.Row < baseRow Then baseRow = f.Row
        End If
    Next c
    If baseRow = 0 Then Exit Sub
    
    ' C列以降の「最後の使用行」（最大）
    lastRow = 0
    For c = DATA_COL_START To lastCol
        Set f = ws.Columns(c).Find(What:="*", LookIn:=xlFormulas, LookAt:=xlPart, _
                                   SearchOrder:=xlByRows, SearchDirection:=xlPrevious, MatchCase:=False)
        If Not f Is Nothing Then If f.Row > lastRow Then lastRow = f.Row
    Next c
    If lastRow < baseRow Then Exit Sub
    
    ' ルール読み取り（A列：上にあるほど優先／無色は無効）
    Dim rules As Collection: Set rules = New Collection
    Dim ruleLast As Long, kw As String, clr As Long
    Set f = ws.Columns(RULES_COL).Find(What:="*", LookIn:=xlFormulas, LookAt:=xlPart, _
                                       SearchOrder:=xlByRows, SearchDirection:=xlPrevious, MatchCase:=False)
    If f Is Nothing Then
        MsgBox "A列にルールがありません。", vbExclamation: Exit Sub
    End If
    ruleLast = f.Row
    For r = 1 To ruleLast
        kw = Trim$(CStr(ws.Cells(r, RULES_COL).Value))
        clr = ws.Cells(r, RULES_COL).Interior.Color
        If Len(kw) > 0 And clr <> 0 Then
            Dim it(1) As Variant
            it(0) = kw: it(1) = clr
            rules.Add it
        End If
    Next r
    If rules.Count = 0 Then
        MsgBox "有効なルール（キーワード＋塗り色）がありません。", vbExclamation
        Exit Sub
    End If
    
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    
    ' ① リセット（C列以降の色をクリア）
    ws.Range(ws.Cells(baseRow, DATA_COL_START), ws.Cells(lastRow, lastCol)).Interior.ColorIndex = xlNone
    
    ' ② 色付け（部分一致・上にあるルール優先）
    Dim cell As Range, i As Long, txt As String
    For Each cell In ws.Range(ws.Cells(baseRow, DATA_COL_START), ws.Cells(lastRow, lastCol)).Cells
        txt = CStr(cell.Value2)
        If Len(txt) > 0 Then
            For i = 1 To rules.Count
                If InStr(1, txt, rules(i)(0), vbTextCompare) > 0 Then
                    cell.Interior.Color = CLng(rules(i)(1))
                    Exit For
                End If
            Next i
        End If
    Next cell
    
    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True
End Sub
