#include <stdio.h>
#include <stdarg.h>

/* ==========================
   設定
   ========================== */
#define DEBUG       1   // デバッグ出力 全体ON/OFF
#define UART_DEBUG  1   // UART出力だけON/OFF

/* UART出力関数（既存実装に置き換える） */
void UART(const char *s, int len) {
    // ★ここは実機のUART送信関数に置き換え★
    // 今は確認用にstderrへ出力
    fwrite(s, 1, len, stderr);
}

/* ==========================
   デバッグ用出力関数
   ========================== */
static inline void my_print(const char *fmt, ...) {
#if DEBUG
    char buf[256];                // 出力バッファ
    va_list args;
    va_start(args, fmt);
    int len = vsnprintf(buf, sizeof(buf), fmt, args);
    va_end(args);

    if (len < 0) return;
    if (len >= (int)sizeof(buf)) {
        len = (int)sizeof(buf) - 1;
    }

    // コンソールへ出力
    printf("%s", buf);

    // UARTへ出力
#if UART_DEBUG
    UART(buf, len);
#endif

#else
    (void)fmt; // DEBUG=0のとき未使用警告回避
#endif
}

/* ==========================
   マクロ定義
   ========================== */
#define PRINT(...) my_print(__VA_ARGS__)

/* ==========================
   使用例
   ========================== */
int main(void) {
    PRINT("test=%d\n", 10);
    PRINT("value=%d, str=%s\n", 123, "hello");
    return 0;
}
