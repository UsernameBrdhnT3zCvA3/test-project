/* heap_useNewlib.c : FreeRTOS のメモリアロケータを newlib に委譲 */
#include <stdlib.h>
#include "FreeRTOS.h"

/* 必要ならタスク毎の reent 構造体が有効か確認（推奨） */
#if (configUSE_NEWLIB_REENTRANT != 1)
#warning "configUSE_NEWLIB_REENTRANT=1 を推奨（タスク毎に _reent を持たせてスレッドセーフ化）"
#endif

void *pvPortMalloc(size_t xSize)
{
    void *pv = malloc(xSize);
#if (configUSE_MALLOC_FAILED_HOOK == 1)
    if (pv == NULL) { vApplicationMallocFailedHook(); }
#endif
    return pv;
}

void vPortFree(void *pv)
{
    if (pv != NULL) { free(pv); }
}

/* 互換用：heap_1/2/4/5 にあるけど、ここでは実質ダミーでOK */
void vPortInitialiseBlocks(void) { /* nothing */ }

/* 空実装でもビルドは通る。必要なら _sbrk から概算して返すよう拡張してもよい */
size_t xPortGetFreeHeapSize(void)               { return 0; }
size_t xPortGetMinimumEverFreeHeapSize(void)    { return 0; }
