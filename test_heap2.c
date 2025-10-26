// heap_safe.c — SP考慮の安全残量（現在/最小）
#include <stdint.h>
#include <stddef.h>

extern void* sbrk(int incr);

/* アドレス系リンカシンボル */
extern char _end;      // ヒープ開始（.data/.bss 終端）
extern char _estack;   // 同一RAM帯の上端（HEAP_ENDが無ければ代用）
/* 任意：ヒープを置いたRAM帯の終端を .ld で用意しているなら推奨 */
// extern char HEAP_END;

#if defined(__GNUC__)
  #include "cmsis_gcc.h"
#elif defined(__ARMCC_VERSION)
  #include "cmsis_armclang.h"
#elif defined(__ICCARM__)
  #include "cmsis_iccarm.h"
#else
  #error "Add CMSIS header for __get_MSP/__get_PSP"
#endif

/* --- 設定 --- */
// 固定の安全マージン（必要に応じて 0〜2KB 程度）
#ifndef HEAP_SAFETY_MARGIN
#define HEAP_SAFETY_MARGIN 0u
#endif

/* --- 内部ユーティリティ --- */
static inline uintptr_t get_sp_any(void){
    uintptr_t psp = (uintptr_t)__get_PSP();
    return psp ? psp : (uintptr_t)__get_MSP();
}
static inline int in_range(uintptr_t a, uintptr_t lo, uintptr_t hi){
    return (a >= lo) && (a < hi);
}
static inline uintptr_t heap_hi(void){
    /* HEAP_END を定義しているならそれを返す */
    // return (uintptr_t)&HEAP_END;
    /* なければ _estack を上端として使う（同一バンク前提） */
    return (uintptr_t)&_estack;
}

/* --- 本体API --- */
static size_t g_min_safe = (size_t)-1;

/* 現在の“運用上の安全”なヒープ残量（バイト） */
size_t heap_safe_free_now_bytes(void){
    uintptr_t brk = (uintptr_t)sbrk(0);
    uintptr_t lo  = (uintptr_t)&_end;
    uintptr_t hi  = heap_hi();

    /* 既定境界はヒープ帯の上端 */
    uintptr_t boundary = hi;

    /* SP が同じRAM帯にいて、かつ brk より上なら SP を境界に採用 */
    uintptr_t sp = get_sp_any();
    if (in_range(sp, lo, hi) && sp > brk) boundary = sp;

    size_t cur = (boundary > brk) ? (size_t)(boundary - brk) : 0;
    if (cur > HEAP_SAFETY_MARGIN) cur -= HEAP_SAFETY_MARGIN;
    else                          cur  = 0;

    if (g_min_safe == (size_t)-1 || cur < g_min_safe) g_min_safe = cur;
    return cur;
}

/* これまでの最小“安全”残量（最悪時のマージン） */
size_t heap_safe_free_min_bytes(void){
    if (g_min_safe == (size_t)-1) (void)heap_safe_free_now_bytes();
    return g_min_safe;
}

/* 任意：最小値リセット */
void heap_safe_free_min_reset(void){ g_min_safe = (size_t)-1; }
