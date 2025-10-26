// safe_heap.c — “運用上の安全”なヒープ残量の現在値と最小値
#include <stdint.h>
#include <stddef.h>

// 必要な外部シンボル
extern void* sbrk(int incr);
extern char _estack;                   // .ld で定義されていること

// 必要なら余裕（割込み/入れ子）ぶんを差し引く
#ifndef HEAP_SAFETY_MARGIN
#define HEAP_SAFETY_MARGIN 1024u       // 例: 1KB（環境に合わせて調整）
#endif

// CMSIS から SP を取る（PSP優先）
#if defined(__GNUC__)
  #include "cmsis_gcc.h"
#elif defined(__ARMCC_VERSION)
  #include "cmsis_armclang.h"
#elif defined(__ICCARM__)
  #include "cmsis_iccarm.h"
#else
  #error "add CMSIS header for __get_MSP/__get_PSP"
#endif

static inline uintptr_t get_sp_any(void){
    uintptr_t psp = (uintptr_t)__get_PSP();
    return psp ? psp : (uintptr_t)__get_MSP();
}

// ---- 公開API ----
static size_t g_min_safe = (size_t)-1;  // これまでの最小“安全残量”

/** 現在の“安全な”ヒープ残量（バイト） */
size_t c_heap_safe_free_now_bytes(void){
    uintptr_t brk = (uintptr_t)sbrk(0);
    uintptr_t est = (uintptr_t)&_estack;
    uintptr_t sp  = get_sp_any();
    uintptr_t bound = (sp && sp < est) ? sp : est;       // 上限 = min(SP, _estack)

    size_t cur = (bound > brk) ? (size_t)(bound - brk) : 0;
    if (cur > HEAP_SAFETY_MARGIN) cur -= HEAP_SAFETY_MARGIN; else cur = 0;

    if (g_min_safe == (size_t)-1 || cur < g_min_safe) g_min_safe = cur; // 最小更新
    return cur;
}

/** これまでの最小“安全残量”（一番危なかった時の余裕） */
size_t c_heap_safe_free_min_bytes(void){
    if (g_min_safe == (size_t)-1) (void)c_heap_safe_free_now_bytes(); // 初回補正
    return g_min_safe;
}

/** 任意：最小値リセット（モード切替/試験区切りで） */
void c_heap_safe_free_min_reset(void){ g_min_safe = (size_t)-1; }
