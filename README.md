# シート比較VBAスクリプト

このVBAスクリプトは、Excel の2つのシート間でデータを比較し、差分があった場合に3つ目のシートに結果を出力します。

## 機能

- **Sheet1** のB列～N列（H列、I列は除外）と **Sheet2** のB列～L列を比較
- 差分がある行を **Sheet3** に横並びで出力
- Sheet1の内容は Sheet3 のB列～、Sheet2の内容は Sheet3 のO列～に配置

## 使用方法

### 方法1: 固定シート名版（CompareSheets）

1. Excel ファイルに以下のシートを用意してください：
   - **比較元シート**: B列～N列（ただしH列・I列は除外）
   - **比較先シート**: B列～L列
   - **結果出力シート**: 自動でクリアされます

2. VBAエディタを開き（Alt + F11）、新しいモジュールを作成

3. `sheet_comparison.vba` の内容をコピー＆ペーストします

4. **シート名を変更する場合**：
   ```vba
   Const SHEET1_NAME As String = "データ1"     ' ← 比較元シート名
   Const SHEET2_NAME As String = "データ2"     ' ← 比較先シート名
   Const SHEET3_NAME As String = "比較結果"    ' ← 結果出力シート名
   ```

5. マクロを実行：
   - VBAエディタで `CompareSheets` サブルーチンを選択してF5キー
   - または Excel のリボンから「開発」→「マクロ」→「CompareSheets」を実行

### 方法2: 動的シート名版（CompareSheets_WithInput）

1. `sheet_comparison_with_input.vba` の内容をコピー＆ペーストします

2. マクロを実行すると、以下のダイアログが順番に表示されます：
   - 「比較元シート名を入力してください」
   - 「比較先シート名を入力してください」
   - 「結果出力シート名を入力してください」

3. 各シート名を入力して実行

## 出力結果

### Sheet3の構成
- **1行目**: シート名表示（A列:行番号、B列:Sheet1、N列:Sheet2）
- **3行目**: ヘッダー（Sheet1とSheet2の1行目から自動取得）
- **5行目以降**: 差分データ
  - **A列**: 行番号
  - **B列～M列**: Sheet1のデータ（B,C,D,E,F,G,J,K,L,M,N列の順）
  - **N列～Y列**: Sheet2のデータ（B,C,D,E,F,G,H,I,J,K,L列の順）

### 比較対象の列
- **Sheet1**: B, C, D, E, F, G, J, K, L, M, N列（H列・I列は除外）
- **Sheet2**: B, C, D, E, F, G, H, I, J, K, L列

## 注意事項

- 1行目はヘッダー行として扱われ、比較対象外です
- 空白セルも含めて厳密に比較されます
- Sheet3は実行時に自動でクリアされます
- 差分がない場合は「差分なし」のメッセージが表示されます

## カスタマイズ

### シート名の変更
```vba
' 固定シート名版の場合
Const SHEET1_NAME As String = "データ1"     ' ← 比較元シート名
Const SHEET2_NAME As String = "データ2"     ' ← 比較先シート名
Const SHEET3_NAME As String = "比較結果"    ' ← 結果出力シート名
```

### その他の設定変更
```vba
' 比較開始行の変更
For row1 = 2 To maxRow  ' ← 2を変更すると開始行を変更可能

' 出力開始行の変更
outputRow = 5  ' ← 5を変更すると出力開始行を変更可能

' 比較列の変更
sheet1Cols = Array(2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 14)  ' ← 列番号配列
sheet2Cols = Array(2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)    ' ← 列番号配列
```