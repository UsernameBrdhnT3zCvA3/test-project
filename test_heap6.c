// heap_safe_no_heaplimit.c — __HeapLimit不要版
#include <stdint.h>
#include <stddef.h>

extern void* sbrk(int incr);

/* アドレス系（リンカ） */
extern char _end;      // ヒープ開始 (.data/.bss 終端)
extern char _estack;   // 同RAM帯の上端（HEAP_ENDが無ければ代用）
// もし .ld にヒープ帯の終端を用意しているならこちらを使う：
// extern char HEAP_END;

/* 数値系（リンカ：= 値; の絶対シンボル） */
extern const size_t _Min_Stack_Size;  // 常に残す最低スタック

#if defined(__GNUC__)
  #include "cmsis_gcc.h"
#elif defined(__ARMCC_VERSION)
  #include "cmsis_armclang.h"
#elif defined(__ICCARM__)
  #include "cmsis_iccarm.h"
#endif

#ifndef HEAP_SAFETY_MARGIN
#define HEAP_SAFETY_MARGIN 0u        // 必要なら 512〜2048B 程度
#endif

/* ---- 内部ユーティリティ ---- */
static inline uintptr_t get_sp_any(void){
    uintptr_t psp = (uintptr_t)__get_PSP();
    return psp ? psp : (uintptr_t)__get_MSP();
}
static inline int in_range(uintptr_t a, uintptr_t lo, uintptr_t hi){
    return (a >= lo) && (a < hi);
}
static inline uintptr_t heap_hi(void){
    // HEAP_END を定義していればそれを返すのが最も正確
    // return (uintptr_t)&HEAP_END;
    return (uintptr_t)&_estack;  // フォールバック
}

/* ---- 本体API ---- */
static size_t g_min_safe = (size_t)-1;

/* 現在の“運用上の安全”ヒープ残量（_Min_Stack_Sizeを常に除外） */
size_t heap_safe_free_now_bytes(void){
    uintptr_t brk = (uintptr_t)sbrk(0);
    uintptr_t lo  = (uintptr_t)&_end;
    uintptr_t hi  = heap_hi();

    // 「上端 − _Min_Stack_Size」をまず上限にする（最低スタックは常に死守）
    uintptr_t limit = (hi >= (uintptr_t)_Min_Stack_Size)
                    ? (hi - (uintptr_t)_Min_Stack_Size) : lo;

    // SPが同じRAM帯にいて、brkより上、かつ limit より下ならSPを境界に採用
    uintptr_t sp = get_sp_any();
    if (in_range(sp, lo, hi) && sp > brk && sp < limit) {
        limit = sp;
    }

    // 残量（必要なら追加マージン控除）
    size_t cur = (limit > brk) ? (size_t)(limit - brk) : 0;
    if (cur > HEAP_SAFETY_MARGIN) cur -= HEAP_SAFETY_MARGIN; else cur = 0;

    // 最小値更新
    if (g_min_safe == (size_t)-1 || cur < g_min_safe) g_min_safe = cur;
    return cur;
}

/* これまでの最小“安全”残量（最悪時の余裕） */
size_t heap_safe_free_min_bytes(void){
    if (g_min_safe == (size_t)-1) (void)heap_safe_free_now_bytes();
    return g_min_safe;
}

/* 任意：最小値リセット */
void heap_safe_free_min_reset(void){ g_min_safe = (size_t)-1; }
