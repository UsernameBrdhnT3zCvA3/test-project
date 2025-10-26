// memmon.c — STM32/newlib用 ヒープ & MSPスタック監視
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <errno.h>

// リンカスクリプトで定義されているシンボル
extern char _end;     // .bss/.data の終端 = ヒープ開始
extern char _estack;  // スタック上端（リセット時SP）
extern char _sstack;  // スタック下端（リンカで ORIGIN(RAM) 等で公開しておく）

// newlib API
extern void* sbrk(int incr);

// ===== ヒープ監視 =====
static size_t g_heap_peak = 0;

// 現在のヒープ使用量
size_t c_heap_used_bytes(void) {
    char* brk = (char*)sbrk(0);
    size_t used = (size_t)(brk - &_end);
    if (used > g_heap_peak) g_heap_peak = used;
    return used;
}

// ヒープのピーク使用量
size_t c_heap_peak_bytes(void) { return g_heap_peak; }

// スタック衝突までの残りヒープ
static inline unsigned long get_sp_any(void) {
    unsigned long sp;
    __asm volatile("mrs %0, psp" : "=r"(sp));
    if (!sp) __asm volatile("mrs %0, msp" : "=r"(sp));
    return sp;
}
size_t c_heap_free_to_stack_bytes(void) {
    char* brk = (char*)sbrk(0);
    unsigned long sp = get_sp_any();
    unsigned long limit = (unsigned long)&_estack;
    unsigned long boundary = (sp < limit ? sp : limit);
    return (size_t)(boundary - (unsigned long)brk);
}

// ===== MSPスタック監視 =====
#ifndef STACK_PATTERN
#define STACK_PATTERN 0xAA
#endif
static int g_stack_filled = 0;

// 起動時に呼んでパターン埋め（最大使用量測定用）
void stack_fill_pattern(void) {
    for (volatile unsigned char* p = (unsigned char*)&_sstack;
         p < (unsigned char*)&_estack; ++p) {
        *p = (unsigned char)STACK_PATTERN;
    }
    g_stack_filled = 1;
}

// 現在のスタック使用量
static inline unsigned long get_msp(void) {
    unsigned long msp;
    __asm volatile("mrs %0, msp" : "=r"(msp));
    return msp;
}
size_t stack_total_bytes(void) {
    return (size_t)((unsigned long)&_estack - (unsigned long)&_sstack);
}
size_t stack_used_now_bytes(void) {
    return (size_t)((unsigned long)&_estack - get_msp());
}
// 過去最大使用量
size_t stack_used_max_bytes(void) {
    if (!g_stack_filled) return 0;
    volatile unsigned char* p = (unsigned char*)&_sstack;
    volatile unsigned char* top = (unsigned char*)&_estack;
    while (p < top && *p == (unsigned char)STACK_PATTERN) { ++p; }
    return (size_t)((unsigned long)top - (unsigned long)p);
}
// 現在の残量
size_t stack_free_now_bytes(void) {
    return stack_total_bytes() - stack_used_now_bytes();
}
// 最小残量（最大使用時にまだ残っていた量）
size_t stack_free_min_bytes(void) {
    return stack_total_bytes() - stack_used_max_bytes();
}

// ===== ログ出力 =====
void memmon_log(void) {
    printf("CHeap used=%luB peak=%luB free=%luB | "
           "MSP now=%luB max=%luB free=%luB\r\n",
        (unsigned long)c_heap_used_bytes(),
        (unsigned long)c_heap_peak_bytes(),
        (unsigned long)c_heap_free_to_stack_bytes(),
        (unsigned long)stack_used_now_bytes(),
        (unsigned long)stack_used_max_bytes(),
        (unsigned long)stack_free_now_bytes());
}
