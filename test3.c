#include "FreeRTOS.h"
#include "task.h"

/* ================================
 * FreeRTOS 保護フック実装
 * ================================ */

void vApplicationStackOverflowHook(TaskHandle_t xTask, const char *pcTaskName)
{
    (void)xTask; (void)pcTaskName;

    /* 簡易ログ（必要ならUARTやITMに出してもOK） */
    // printf("StackOverflow! task=%s\r\n", pcTaskName);

    __BKPT(0);                    /* デバッガで即停止 */
    taskDISABLE_INTERRUPTS();
    for(;;);                      /* ここで止める */
}

void vApplicationMallocFailedHook(void)
{
    /* malloc 失敗時（pvPortMallocがNULLを返したら） */
    // printf("Malloc failed!\r\n");

    __BKPT(0);
    taskDISABLE_INTERRUPTS();
    for(;;);
}
