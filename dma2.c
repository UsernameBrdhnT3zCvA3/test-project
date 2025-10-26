// 例：0x30000000（D2 SRAM, 32KB）をNC化する
void MPU_Config_DMA_NC(void)
{
    // 1) 変更対象範囲のClean(+Invalidate)
    //    ※以前Cacheableで使っていた可能性があるため必須
    SCB_CleanDCache_by_Addr((uint32_t*)0x30000000, 32*1024);
    SCB_InvalidateDCache_by_Addr((uint32_t*)0x30000000, 32*1024);

    HAL_MPU_Disable();

    MPU_Region_InitTypeDef m = {0};
    m.Enable           = MPU_REGION_ENABLE;
    m.Number           = MPU_REGION_NUMBER7;          // ★高番号を推奨
    m.BaseAddress      = 0x30000000;
    m.Size             = MPU_REGION_SIZE_32KB;        // 2のべき乗 & 境界整列
    m.SubRegionDisable = 0x00;
    m.TypeExtField     = MPU_TEX_LEVEL0;              // Normal memory
    m.AccessPermission = MPU_REGION_FULL_ACCESS;
    m.DisableExec      = MPU_INSTRUCTION_ACCESS_ENABLE; // ★まずは実行許可
    m.IsShareable      = MPU_ACCESS_SHAREABLE;          // ★DMA向けはONが無難
    m.IsCacheable      = MPU_ACCESS_NOT_CACHEABLE;      // ★NC
    m.IsBufferable     = MPU_ACCESS_NOT_BUFFERABLE;

    HAL_MPU_ConfigRegion(&m);
    HAL_MPU_Enable(MPU_PRIVILEGED_DEFAULT);

    __DSB(); __ISB(); // 念のため
}
