#include "core_cm7.h"

static void EnableFaults(void)
{
    SCB->SHCSR |= (SCB_SHCSR_MEMFAULTENA_Msk |
                   SCB_SHCSR_BUSFAULTENA_Msk |
                   SCB_SHCSR_USGFAULTENA_Msk);
    SCB->CCR   |= (SCB_CCR_DIV_0_TRP_Msk | SCB_CCR_UNALIGN_TRP_Msk);
}

int main(void)
{
  HAL_Init();
  /* USER CODE BEGIN Init */
  EnableFaults();   // ← ここで一度呼ぶ（早いほど良い）
  /* USER CODE END Init */
  SystemClock_Config();
  ...
}
