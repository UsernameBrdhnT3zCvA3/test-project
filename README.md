# シート比較VBAスクリプト

このVBAスクリプトは、Excel の2つのシート間でデータを比較し、差分があった場合に3つ目のシートに結果を出力します。

## 機能

- **Sheet1** のB列～N列（H列、I列は除外）と **Sheet2** のB列～L列を比較
- 差分がある行を **Sheet3** に横並びで出力
- Sheet1の内容は Sheet3 のB列～、Sheet2の内容は Sheet3 のO列～に配置

## 使用方法

1. Excel ファイルに以下のシートを用意してください：
   - **Sheet1**: 比較元データ（B列～N列、ただしH列・I列は除外）
   - **Sheet2**: 比較先データ（B列～L列）
   - **Sheet3**: 結果出力先（自動でクリアされます）

2. VBAエディタを開き（Alt + F11）、新しいモジュールを作成

3. `sheet_comparison.vba` の内容をコピー＆ペーストします

4. マクロを実行：
   - VBAエディタで `CompareSheets` サブルーチンを選択してF5キー
   - または Excel のリボンから「開発」→「マクロ」→「CompareSheets」を実行

## 出力結果

### Sheet3の構成
- **A列**: 行番号
- **B列～L列**: Sheet1のデータ（B,C,D,E,F,G,J,K,L,M,N列の順）
- **M列**: セパレータ（"---"）
- **N列**: 差分マーク（"◄►"）
- **O列～Y列**: Sheet2のデータ（B,C,D,E,F,G,H,I,J,K,L列の順）

### 比較対象の列
- **Sheet1**: B, C, D, E, F, G, J, K, L, M, N列（H列・I列は除外）
- **Sheet2**: B, C, D, E, F, G, H, I, J, K, L列

## 注意事項

- 1行目はヘッダー行として扱われ、比較対象外です
- 空白セルも含めて厳密に比較されます
- Sheet3は実行時に自動でクリアされます
- 差分がない場合は「差分なし」のメッセージが表示されます

## カスタマイズ

必要に応じて以下の部分を修正できます：

```vba
' シート名の変更
Set ws1 = ThisWorkbook.Sheets("Sheet1")  ' ← シート名を変更
Set ws2 = ThisWorkbook.Sheets("Sheet2")  ' ← シート名を変更
Set ws3 = ThisWorkbook.Sheets("Sheet3")  ' ← シート名を変更

' 比較開始行の変更
For row1 = 2 To maxRow  ' ← 2を変更すると開始行を変更可能

' 比較列の変更
sheet1Cols = Array(2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 14)  ' ← 列番号配列
sheet2Cols = Array(2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)    ' ← 列番号配列
```