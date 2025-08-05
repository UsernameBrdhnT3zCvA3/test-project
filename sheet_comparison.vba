Sub CompareSheets()
    Dim ws1 As Worksheet, ws2 As Worksheet, ws3 As Worksheet
    Dim lastRow1 As Long, lastRow2 As Long, maxRow As Long
    Dim row1 As Long, row2 As Long, outputRow As Long
    Dim col As Long
    Dim isDifferent As Boolean
    Dim sheet1Data As String, sheet2Data As String
    
    ' シートの設定
    Set ws1 = ThisWorkbook.Sheets("Sheet1")
    Set ws2 = ThisWorkbook.Sheets("Sheet2")
    Set ws3 = ThisWorkbook.Sheets("Sheet3")
    
    ' Sheet3をクリア
    ws3.Cells.Clear
    
    ' シート名を上部に表示
    ws3.Range("A1").Value = "Row"
    ws3.Range("B1").Value = "Sheet1"
    ws3.Range("N1").Value = "Sheet2"
    
    ' Sheet1とSheet2からヘッダーを取得して設定
    Dim sheet1Cols As Variant
    Dim sheet2Cols As Variant
    
    sheet1Cols = Array(2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 14) ' B,C,D,E,F,G,J,K,L,M,N
    sheet2Cols = Array(2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)   ' B,C,D,E,F,G,H,I,J,K,L
    
    ' Sheet1のヘッダーを設定（3行目）
    Dim outputCol As Long
    outputCol = 2 ' B列から開始
    For col = 0 To UBound(sheet1Cols)
        ws3.Cells(3, outputCol).Value = ws1.Cells(1, sheet1Cols(col)).Value
        outputCol = outputCol + 1
    Next col
    
    ' Sheet2のヘッダーを設定（3行目、N列から開始）
    outputCol = 14 ' N列から開始
    For col = 0 To UBound(sheet2Cols)
        ws3.Cells(3, outputCol).Value = ws2.Cells(1, sheet2Cols(col)).Value
        outputCol = outputCol + 1
    Next col
    
    ' 最終行を取得
    lastRow1 = ws1.Cells(ws1.Rows.Count, "B").End(xlUp).Row
    lastRow2 = ws2.Cells(ws2.Rows.Count, "B").End(xlUp).Row
    maxRow = Application.WorksheetFunction.Max(lastRow1, lastRow2)
    
    outputRow = 5 ' 5行目から出力開始
    
    ' 各行を比較
    For row1 = 2 To maxRow ' 2行目から開始（1行目はヘッダーと仮定）
        isDifferent = False
        
        ' Sheet1の各列（B-G, J-N）とSheet2の各列（B-L）を比較
        ' Sheet1: B,C,D,E,F,G,J,K,L,M,N (H,I除外)
        ' Sheet2: B,C,D,E,F,G,H,I,J,K,L
        
        ' 対応する列同士を比較
        For col = 0 To UBound(sheet1Cols)
            If row1 <= lastRow1 Then
                sheet1Data = CStr(ws1.Cells(row1, sheet1Cols(col)).Value)
            Else
                sheet1Data = ""
            End If
            
            If row1 <= lastRow2 Then
                sheet2Data = CStr(ws2.Cells(row1, sheet2Cols(col)).Value)
            Else
                sheet2Data = ""
            End If
            
            If sheet1Data <> sheet2Data Then
                isDifferent = True
                Exit For
            End If
        Next col
        
        ' 差分がある場合、Sheet3に出力
        If isDifferent Then
            ws3.Cells(outputRow, 1).Value = row1 ' 行番号
            
            ' Sheet1のデータを出力（B列～）
            outputCol = 2 ' B列から開始
            
            For col = 0 To UBound(sheet1Cols)
                If row1 <= lastRow1 Then
                    ws3.Cells(outputRow, outputCol).Value = ws1.Cells(row1, sheet1Cols(col)).Value
                End If
                outputCol = outputCol + 1
            Next col
            
            ' Sheet2のデータを出力（N列～）
            outputCol = 14 ' N列から開始
            
            For col = 0 To UBound(sheet2Cols)
                If row1 <= lastRow2 Then
                    ws3.Cells(outputRow, outputCol).Value = ws2.Cells(row1, sheet2Cols(col)).Value
                End If
                outputCol = outputCol + 1
            Next col
            
            outputRow = outputRow + 1
        End If
    Next row1
    
    ' 結果の表示
    If outputRow = 5 Then
        MsgBox "差分は見つかりませんでした。", vbInformation
        ws3.Range("A5").Value = "差分なし"
    Else
        MsgBox (outputRow - 5) & "件の差分が見つかりました。Sheet3に出力しました。", vbInformation
        
        ' Sheet3の書式設定
        ' シート名の行（1行目）
        With ws3.Range("A1:Y1")
            .Font.Bold = True
            .Interior.Color = RGB(180, 180, 180)
        End With
        
        ' ヘッダー行（3行目）
        With ws3.Range("A3:Y3")
            .Font.Bold = True
            .Interior.Color = RGB(220, 220, 220)
        End With
        
        ' 罫線を追加
        With ws3.Range("A1:Y" & (outputRow - 1))
            .Borders.LineStyle = xlContinuous
            .Borders.Weight = xlThin
        End With
        
        ' 列幅の自動調整
        ws3.Columns("A:Y").AutoFit
    End If
    
End Sub