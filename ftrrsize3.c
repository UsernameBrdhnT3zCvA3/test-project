#include <stdint.h>
#include <stddef.h>

extern void* sbrk(int incr);
extern char HEAP_END;      // ★リンカで定義した“ヒープ帯の上限”
extern char _end;          // ヒープ開始（必要なら）

#if defined(__GNUC__)
  #include "cmsis_gcc.h"
#endif

#ifndef HEAP_SAFETY_MARGIN
#define HEAP_SAFETY_MARGIN 1024u
#endif

static inline uintptr_t get_sp_any(void){
    uintptr_t psp = (uintptr_t)__get_PSP();
    return psp ? psp : (uintptr_t)__get_MSP();
}

// ユーティリティ: アドレスが同一RAM帯かチェック（単純な範囲判定）
static inline int in_range(uintptr_t a, uintptr_t lo, uintptr_t hi){
    return (a >= lo) && (a < hi);
}

size_t c_heap_safe_free_now_bytes(void){
    uintptr_t brk = (uintptr_t)sbrk(0);
    uintptr_t heap_lo = (uintptr_t)&_end;
    uintptr_t heap_hi = (uintptr_t)&HEAP_END;    // 同じRAM帯の上限

    // デフォ境界は“そのRAM帯の上限”
    uintptr_t boundary = heap_hi;

    // SPが“同じ帯にあり、かつ brk より上”なら SP を採用
    uintptr_t sp = get_sp_any();
    if (in_range(sp, heap_lo, heap_hi) && sp > brk) {
        boundary = sp;
    }

    size_t cur = (boundary > brk) ? (size_t)(boundary - brk) : 0;
    if (cur > HEAP_SAFETY_MARGIN) cur -= HEAP_SAFETY_MARGIN; else cur = 0;
    return cur;
}
