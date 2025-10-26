// heap_safe_minstack.c — _Min_Stack_Size を常に確保して安全残量を計算
#include <stdint.h>
#include <stddef.h>

extern void* sbrk(int incr);

/* リンカシンボル */
extern char _end;      // ヒープ開始（.data/.bss 終端）
extern char _estack;   // （HEAP_ENDが無ければ代用する上端）
extern const size_t _Min_Stack_Size;  // ★常に残す最低スタック分

/* もしヒープを別RAM帯に置いていて .ld に上端を作っているなら推奨 */
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

#ifndef HEAP_SAFETY_MARGIN
#define HEAP_SAFETY_MARGIN 0u   // 必要なら 512〜2048B 程度
#endif

static inline uintptr_t get_sp_any(void){
    uintptr_t psp = (uintptr_t)__get_PSP();
    return psp ? psp : (uintptr_t)__get_MSP();
}
static inline int in_range(uintptr_t a, uintptr_t lo, uintptr_t hi){
    return (a >= lo) && (a < hi);
}
static inline uintptr_t heap_hi(void){
    /* HEAP_END を定義しているならそれを返すのがベスト */
    // return (uintptr_t)&HEAP_END;
    return (uintptr_t)&_estack;
}

static size_t g_min_safe = (size_t)-1;

/* 現在の “運用上の安全” 残量（_Min_Stack_Size を常に確保） */
size_t heap_safe_free_now_bytes(void){
    uintptr_t brk = (uintptr_t)sbrk(0);
    uintptr_t lo  = (uintptr_t)&_end;
    uintptr_t hi  = heap_hi();

    /* まず、上端から _Min_Stack_Size を引いて「必ず確保する帯」を除外 */
    uintptr_t hi_reserved = hi;
    if ((size_t)(hi - (uintptr_t)0) > _Min_Stack_Size) {
        hi_reserved = hi - _Min_Stack_Size;
    }

    /* 既定境界は「上端−最低スタック」 */
    uintptr_t boundary = hi_reserved;

    /* SP が “同じRAM帯” にいて、brkより上で、かつ hi_reserved より下なら SP を採用 */
    uintptr_t sp = get_sp_any();
    if (in_range(sp, lo, hi) && sp > brk && sp < boundary) {
        boundary = sp;
    }

    size_t cur = (boundary > brk) ? (size_t)(boundary - brk) : 0;

    /* 追加の安全マージンがあれば控除 */
    if (cur > HEAP_SAFETY_MARGIN) cur -= HEAP_SAFETY_MARGIN;
    else                          cur  = 0;

    if (g_min_safe == (size_t)-1 || cur < g_min_safe) g_min_safe = cur;
    return cur;
}

/* これまでの最小 “安全” 残量（最悪時の余裕） */
size_t heap_safe_free_min_bytes(void){
    if (g_min_safe == (size_t)-1) (void)heap_safe_free_now_bytes();
    return g_min_safe;
}

void heap_safe_free_min_reset(void){ g_min_safe = (size_t)-1; }
