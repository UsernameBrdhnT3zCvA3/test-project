// heap_watch.c（追加ファイル） — 既存の _sbrk はそのまま
#include <stddef.h>
extern void* sbrk(int incr);
extern char _end;     // ヒープ開始（.data/.bss 終端）
extern char _estack;  // スタック上端（リンカ）

static size_t g_peak = 0;

size_t c_heap_used_bytes(void) {
    char* brk = (char*)sbrk(0);
    size_t used = (size_t)(brk - &_end);
    if (used > g_peak) g_peak = used;
    return used;
}
size_t c_heap_peak_bytes(void) { return g_peak; }

static inline unsigned long get_sp(void){
    unsigned long sp;
    __asm volatile("mrs %0, psp" : "=r"(sp));
    if(!sp) __asm volatile("mrs %0, msp" : "=r"(sp));
    return sp;
}
size_t c_heap_free_to_stack_bytes(void) {
    char* brk = (char*)sbrk(0);
    unsigned long sp = get_sp();
    unsigned long limit = (unsigned long)&_estack;
    unsigned long boundary = (sp < limit ? sp : limit);
    return (size_t)(boundary - (unsigned long)brk);
}
