// heap_free_consistent.c — _sbrk の上限ロジックに揃えて残量を出す
#include <stdint.h>
#include <stddef.h>

extern void* sbrk(int incr);

/* アドレス系シンボル */
extern char _end;      // ヒープ開始
extern char _estack;   // ヒープを置いた帯の上端代用（HEAP_ENDがあればそちら推奨）
/* optional: ヒープ帯の真の上端を .ld に定義しているなら使う */
// extern char HEAP_END;

/* 数値系シンボル */
extern const size_t _Min_Stack_Size;   // 常に確保したい最小スタック

/* 一部の sysmem.c は __HeapLimit を参照して止める */
extern char __HeapLimit;   // 無い環境もあるので後で存在チェック

#if defined(__GNUC__)
  #include "cmsis_gcc.h"
#elif defined(__ARMCC_VERSION)
  #include "cmsis_armclang.h"
#elif defined(__ICCARM__)
  #include "cmsis_iccarm.h"
#endif

static inline uintptr_t get_sp_any(void){
    uintptr_t psp = (uintptr_t)__get_PSP();
    return psp ? psp : (uintptr_t)__get_MSP();
}
static inline int in_range(uintptr_t a, uintptr_t lo, uintptr_t hi){
    return (a >= lo) && (a < hi);
}
static inline uintptr_t heap_hi_default(void){
    // HEAP_END を用意してるならそれを返すのがベスト
    // return (uintptr_t)&HEAP_END;
    return (uintptr_t)&_estack;
}

size_t heap_free_now_consistent(void){
    uintptr_t brk = (uintptr_t)sbrk(0);
    uintptr_t lo  = (uintptr_t)&_end;
    uintptr_t hi  = heap_hi_default();

    // 1) __HeapLimit（存在すれば最有力の上限）
    uintptr_t limit = (uintptr_t)&__HeapLimit;
    // __HeapLimit が未定義の環境だと &__HeapLimit は 0 になり得るので無視
    if (limit < lo || limit > hi) {
        // 2) 上端から _Min_Stack_Size を引いた“予約除外”上限
        limit = (hi >= (uintptr_t)_Min_Stack_Size) ? (hi - (uintptr_t)_Min_Stack_Size) : lo;
    }

    // 3) SP が“同じ帯にあって brk より上”なら、その値も上限候補に
    uintptr_t sp = get_sp_any();
    if (in_range(sp, lo, hi) && sp > brk && sp < limit) {
        limit = sp;
    }

    // 残量（負にならないようクランプ）
    return (limit > brk) ? (size_t)(limit - brk) : 0;
}
