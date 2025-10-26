// heap_free_min.c — 現在の残量 と 過去最小の残量
#include <stdint.h>
#include <stddef.h>

extern void* sbrk(int incr);
extern char _estack;  // リンカスクリプトで定義されていること

// これまで観測した最小の残量（未初期化状態は "未観測" を表す）
static size_t g_min_free = (size_t)-1;

/** 現在のヒープ残量（理論値：_estack まで） */
size_t c_heap_free_now_bytes(void) {
    uintptr_t brk = (uintptr_t)sbrk(0);
    uintptr_t lim = (uintptr_t)&_estack;
    size_t cur = (lim > brk) ? (size_t)(lim - brk) : 0;

    // 最小値更新
    if (g_min_free == (size_t)-1 || cur < g_min_free) {
        g_min_free = cur;
    }
    return cur;
}

/** これまでで最小だったヒープ残量（最小free） */
size_t c_heap_free_min_bytes(void) {
    if (g_min_free == (size_t)-1) {
        (void)c_heap_free_now_bytes(); // 初回呼び出しで初期化
    }
    return g_min_free;
}

/** 任意：最小値をリセット（モード切り替え・テスト前など） */
void c_heap_free_min_reset(void) {
    g_min_free = (size_t)-1;
}
