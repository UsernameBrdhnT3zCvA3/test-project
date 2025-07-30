Sub ExportToCTable()
    ' 変数の宣言
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim i As Long
    Dim fileNum As Integer
    Dim filePath As String
    Dim colA As String, colB As String, colC As String
    Dim tableName As String
    Dim dataType As String
    
    ' アクティブワークシートを取得
    Set ws = ActiveSheet
    
    ' データの最終行を取得（A列を基準）
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    ' データが存在しない場合の処理
    If lastRow < 2 Then
        MsgBox "データが見つかりません。A列、B列、C列にデータを入力してください。", vbExclamation
        Exit Sub
    End If
    
    ' 出力ファイルのパスを設定（ワークブックと同じフォルダ）
    filePath = ThisWorkbook.Path & "\table_data.c"
    
    ' テーブル名とデータ型の設定
    tableName = "data_table"
    dataType = "const char*"  ' 文字列型として設定（必要に応じて変更可能）
    
    ' ファイル番号を取得
    fileNum = FreeFile
    
    ' ファイルを開く
    Open filePath For Output As #fileNum
    
    ' ヘッダーコメントの出力
    Print #fileNum, "/* Generated C Table from Excel Data */"
    Print #fileNum, "/* Columns: A, B, C */"
    Print #fileNum, ""
    
    ' インクルード文（必要に応じて）
    Print #fileNum, "#include <stdio.h>"
    Print #fileNum, ""
    
    ' テーブル構造体の定義
    Print #fileNum, "typedef struct {"
    Print #fileNum, "    " & dataType & " col_a;"
    Print #fileNum, "    " & dataType & " col_b;"
    Print #fileNum, "    " & dataType & " col_c;"
    Print #fileNum, "} TableRow;"
    Print #fileNum, ""
    
    ' テーブルデータの開始
    Print #fileNum, "TableRow " & tableName & "[] = {"
    
    ' データ行の処理（2行目から開始、1行目はヘッダーと仮定）
    For i = 2 To lastRow
        ' 各列の値を取得
        colA = Trim(CStr(ws.Cells(i, 1).Value))
        colB = Trim(CStr(ws.Cells(i, 2).Value))
        colC = Trim(CStr(ws.Cells(i, 3).Value))
        
        ' 空の値を処理
        If colA = "" Then colA = "NULL"
        If colB = "" Then colB = "NULL"
        If colC = "" Then colC = "NULL"
        
        ' 文字列の場合はダブルクォートで囲む
        If colA <> "NULL" Then colA = """" & colA & """"
        If colB <> "NULL" Then colB = """" & colB & """"
        If colC <> "NULL" Then colC = """" & colC & """"
        
        ' テーブル行の出力
        If i = lastRow Then
            ' 最後の行にはカンマを付けない
            Print #fileNum, "    {" & colA & ", " & colB & ", " & colC & "}"
        Else
            Print #fileNum, "    {" & colA & ", " & colB & ", " & colC & "},"
        End If
    Next i
    
    ' テーブルの終了
    Print #fileNum, "};"
    Print #fileNum, ""
    
    ' テーブルサイズの定義
    Print #fileNum, "#define TABLE_SIZE (sizeof(" & tableName & ") / sizeof(" & tableName & "[0]))"
    Print #fileNum, ""
    
    ' サンプル関数の追加
    Print #fileNum, "/* Sample function to print table data */"
    Print #fileNum, "void print_table() {"
    Print #fileNum, "    int i;"
    Print #fileNum, "    printf(""Table Data (%d rows):\n"", TABLE_SIZE);"
    Print #fileNum, "    printf(""%-20s %-20s %-20s\n"", ""Column A"", ""Column B"", ""Column C"");"
    Print #fileNum, "    printf(""----------------------------------------"")"
    Print #fileNum, "           ""----------------------------------------\n"");"
    Print #fileNum, "    for (i = 0; i < TABLE_SIZE; i++) {"
    Print #fileNum, "        printf(""%-20s %-20s %-20s\n"","
    Print #fileNum, "               " & tableName & "[i].col_a ? " & tableName & "[i].col_a : ""(null)"","
    Print #fileNum, "               " & tableName & "[i].col_b ? " & tableName & "[i].col_b : ""(null)"","
    Print #fileNum, "               " & tableName & "[i].col_c ? " & tableName & "[i].col_c : ""(null)"");"
    Print #fileNum, "    }"
    Print #fileNum, "}"
    
    ' ファイルを閉じる
    Close #fileNum
    
    ' 完了メッセージ
    MsgBox "C言語テーブルファイルの生成が完了しました。" & vbCrLf & _
           "ファイル: " & filePath & vbCrLf & _
           "行数: " & (lastRow - 1) & " 行", vbInformation
    
End Sub

' 数値データ用のバージョン
Sub ExportToCTableNumeric()
    ' 変数の宣言
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim i As Long
    Dim fileNum As Integer
    Dim filePath As String
    Dim colA As String, colB As String, colC As String
    Dim tableName As String
    
    ' アクティブワークシートを取得
    Set ws = ActiveSheet
    
    ' データの最終行を取得
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    ' データが存在しない場合の処理
    If lastRow < 2 Then
        MsgBox "データが見つかりません。", vbExclamation
        Exit Sub
    End If
    
    ' 出力ファイルのパス
    filePath = ThisWorkbook.Path & "\numeric_table.c"
    tableName = "numeric_table"
    
    ' ファイル番号を取得
    fileNum = FreeFile
    
    ' ファイルを開く
    Open filePath For Output As #fileNum
    
    ' ヘッダー
    Print #fileNum, "/* Generated Numeric C Table from Excel Data */"
    Print #fileNum, "#include <stdio.h>"
    Print #fileNum, ""
    
    ' 数値テーブル構造体
    Print #fileNum, "typedef struct {"
    Print #fileNum, "    double col_a;"
    Print #fileNum, "    double col_b;"
    Print #fileNum, "    double col_c;"
    Print #fileNum, "} NumericRow;"
    Print #fileNum, ""
    
    ' テーブルデータ
    Print #fileNum, "NumericRow " & tableName & "[] = {"
    
    For i = 2 To lastRow
        ' 数値として取得
        colA = CStr(ws.Cells(i, 1).Value)
        colB = CStr(ws.Cells(i, 2).Value)
        colC = CStr(ws.Cells(i, 3).Value)
        
        ' 空の場合は0
        If Not IsNumeric(ws.Cells(i, 1).Value) Then colA = "0.0"
        If Not IsNumeric(ws.Cells(i, 2).Value) Then colB = "0.0"
        If Not IsNumeric(ws.Cells(i, 3).Value) Then colC = "0.0"
        
        ' 出力
        If i = lastRow Then
            Print #fileNum, "    {" & colA & ", " & colB & ", " & colC & "}"
        Else
            Print #fileNum, "    {" & colA & ", " & colB & ", " & colC & "},"
        End If
    Next i
    
    Print #fileNum, "};"
    Print #fileNum, ""
    Print #fileNum, "#define NUMERIC_TABLE_SIZE (sizeof(" & tableName & ") / sizeof(" & tableName & "[0]))"
    
    Close #fileNum
    
    MsgBox "数値テーブルファイルの生成が完了しました: " & filePath, vbInformation
    
End Sub