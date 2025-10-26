// heap_minheap.c — 「総量は _Min_Heap_Size だけ」の前提で残りを計算
#include <stddef.h>
#include <stdint.h>

extern void* sbrk(int incr);

/* リンカシンボル */
extern char _end;                 // ヒープ開始 (.bss/.data 終端)
extern const size_t _Min_Heap_Size;  // 総ヒープ容量（リンク時に決め打ち）

// 内部: 現在の使用量（クランプ付き）
static size_t heap_used_bytes_raw(void){
    uintptr_t brk   = (uintptr_t)sbrk(0);
    uintptr_t start = (uintptr_t)&_end;
    if (brk <= start) return 0;
    size_t used = (size_t)(brk - start);
    if (used > _Min_Heap_Size) used = _Min_Heap_Size;   // 念のためクランプ
    return used;
}

// 公開: 現在の残り
size_t heap_free_now_bytes(void){
    size_t used = heap_used_bytes_raw();
    return (_Min_Heap_Size > used) ? (_Min_Heap_Size - used) : 0;
}

// 公開: これまでの最小残り（ピーク時の残り）
static size_t g_min_free = (size_t)-1;
size_t heap_free_min_bytes(void){
    size_t now = heap_free_now_bytes();
    if (g_min_free == (size_t)-1 || now < g_min_free) g_min_free = now;
    return g_min_free;
}

// 任意: リセット
void heap_free_min_reset(void){ g_min_free = (size_t)-1; }
