Public Sub 整形_先頭揃え1本()
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
