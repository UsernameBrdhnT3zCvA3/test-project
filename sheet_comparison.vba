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
    
    ' ヘッダーを設定
    ws3.Range("A1").Value = "Row"
    ws3.Range("B1").Value = "Sheet1_B"
    ws3.Range("C1").Value = "Sheet1_C"
    ws3.Range("D1").Value = "Sheet1_D"
    ws3.Range("E1").Value = "Sheet1_E"
    ws3.Range("F1").Value = "Sheet1_F"
    ws3.Range("G1").Value = "Sheet1_G"
    ws3.Range("H1").Value = "Sheet1_J"  ' H列は除外なのでJ列
    ws3.Range("I1").Value = "Sheet1_K"  ' I列は除外なのでK列
    ws3.Range("J1").Value = "Sheet1_L"
    ws3.Range("K1").Value = "Sheet1_M"
    ws3.Range("L1").Value = "Sheet1_N"
    
    ws3.Range("M1").Value = "---"
    ws3.Range("N1").Value = "Difference"
    
    ws3.Range("O1").Value = "Sheet2_B"
    ws3.Range("P1").Value = "Sheet2_C"
    ws3.Range("Q1").Value = "Sheet2_D"
    ws3.Range("R1").Value = "Sheet2_E"
    ws3.Range("S1").Value = "Sheet2_F"
    ws3.Range("T1").Value = "Sheet2_G"
    ws3.Range("U1").Value = "Sheet2_H"
    ws3.Range("V1").Value = "Sheet2_I"
    ws3.Range("W1").Value = "Sheet2_J"
    ws3.Range("X1").Value = "Sheet2_K"
    ws3.Range("Y1").Value = "Sheet2_L"
    
    ' 最終行を取得
    lastRow1 = ws1.Cells(ws1.Rows.Count, "B").End(xlUp).Row
    lastRow2 = ws2.Cells(ws2.Rows.Count, "B").End(xlUp).Row
    maxRow = Application.WorksheetFunction.Max(lastRow1, lastRow2)
    
    outputRow = 2 ' ヘッダーの次の行から開始
    
    ' 各行を比較
    For row1 = 2 To maxRow ' 2行目から開始（1行目はヘッダーと仮定）
        isDifferent = False
        
        ' Sheet1の各列（B-G, J-N）とSheet2の各列（B-L）を比較
        ' Sheet1: B,C,D,E,F,G,J,K,L,M,N (H,I除外)
        ' Sheet2: B,C,D,E,F,G,H,I,J,K,L
        
        Dim sheet1Cols As Variant
        Dim sheet2Cols As Variant
        
        sheet1Cols = Array(2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 14) ' B,C,D,E,F,G,J,K,L,M,N
        sheet2Cols = Array(2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)   ' B,C,D,E,F,G,H,I,J,K,L
        
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
            Dim outputCol As Long
            outputCol = 2 ' B列から開始
            
            For col = 0 To UBound(sheet1Cols)
                If row1 <= lastRow1 Then
                    ws3.Cells(outputRow, outputCol).Value = ws1.Cells(row1, sheet1Cols(col)).Value
                End If
                outputCol = outputCol + 1
            Next col
            
            ws3.Cells(outputRow, 14).Value = "◄►" ' 差分マーク
            
            ' Sheet2のデータを出力（O列～）
            outputCol = 15 ' O列から開始
            
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
    If outputRow = 2 Then
        MsgBox "差分は見つかりませんでした。", vbInformation
        ws3.Range("A2").Value = "差分なし"
    Else
        MsgBox (outputRow - 2) & "件の差分が見つかりました。Sheet3に出力しました。", vbInformation
        
        ' Sheet3の書式設定
        With ws3.Range("A1:Y1")
            .Font.Bold = True
            .Interior.Color = RGB(200, 200, 200)
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