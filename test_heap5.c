// heap_safe_final.c — _Min_Stack_Sizeを常に除外、SPも考慮、__HeapLimitにも整合
#include <stdint.h>
#include <stddef.h>

extern void* sbrk(int incr);

/* リンカシンボル */
extern char _end;                // ヒープ開始（.bss/.data終端）
extern char _estack;             // RAM上端（同一バンク）
extern const size_t _Min_Stack_Size;  // 常に確保する最低スタック分
/* _sbrkが__HeapLimitを上限に使っている場合用（sysmem.cで定義） */
extern char __HeapLimit;         // 無ければリンク時に0扱い

#if defined(__GNUC__)
  #include "cmsis_gcc.h"
#elif defined(__ARMCC_VERSION)
  #include "cmsis_armclang.h"
#elif defined(__ICCARM__)
  #include "cmsis_iccarm.h"
#else
  #error "Add CMSIS header for __get_MSP/__get_PSP"
#endif

#ifndef HEAP_SAFETY_MARGIN
#define HEAP_SAFETY_MARGIN 0u    // 割込みなどの余裕。必要なら512〜2048B
#endif

/* --- 内部 util --- */
static inline uintptr_t get_sp_any(void){
    uintptr_t psp = (uintptr_t)__get_PSP();
    return psp ? psp : (uintptr_t)__get_MSP();
}
static inline int in_range(uintptr_t a, uintptr_t lo, uintptr_t hi){
    return (a >= lo) && (a < hi);
}
static inline uintptr_t heap_hi(void){
    return (uintptr_t)&_estack;   // 必要ならHEAP_ENDに差し替え
}

/* --- 状態保存 --- */
static size_t g_min_safe = (size_t)-1;

/* 現在の“運用上の安全残量”（SPと_Min_Stack_Size考慮） */
size_t heap_safe_free_now_bytes(void)
{
    uintptr_t brk = (uintptr_t)sbrk(0);
    uintptr_t lo  = (uintptr_t)&_end;
    uintptr_t hi  = heap_hi();

    // 1️⃣ __HeapLimit が有効ならそれを上限に採用
    uintptr_t limit = (uintptr_t)&__HeapLimit;
    if (limit < lo || limit > hi) {
        // 無効なら _estack - _Min_Stack_Size を上限に
        limit = (hi >= (uintptr_t)_Min_Stack_Size)
              ? (hi - (uintptr_t)_Min_Stack_Size)
              : lo;
    }

    // 2️⃣ SP が同じRAM帯にいて brk より上なら、それも境界候補に
    uintptr_t sp = get_sp_any();
    if (in_range(sp, lo, hi) && sp > brk && sp < limit) {
        limit = sp;
    }

    // 3️⃣ 残量計算（負防止＆マージン引き）
    size_t cur = (limit > brk) ? (size_t)(limit - brk) : 0;
    if (cur > HEAP_SAFETY_MARGIN) cur -= HEAP_SAFETY_MARGIN;
    else                          cur = 0;

    // 4️⃣ 最小値トラッキング
    if (g_min_safe == (size_t)-1 || cur < g_min_safe)
        g_min_safe = cur;

    return cur;
}

/* これまでの最小“安全”残量（ピーク時最悪値） */
size_t heap_safe_free_min_bytes(void)
{
    if (g_min_safe == (size_t)-1)
        (void)heap_safe_free_now_bytes();
    return g_min_safe;
}

/* 最小値リセット */
void heap_safe_free_min_reset(void)
{
    g_min_safe = (size_t)-1;
}
