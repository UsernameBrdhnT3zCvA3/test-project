// mpu_config.c 等に
static void MPU_Config_For_DMA(void)
{
    HAL_MPU_Disable();

    MPU_Region_InitTypeDef m = {0};
    m.Enable           = MPU_REGION_ENABLE;
    m.Number           = MPU_REGION_NUMBER4;      // 空いてる番号を使用
    m.BaseAddress      = 0x30000000;              // D2 SRAM 先頭（例）
    m.Size             = MPU_REGION_SIZE_32KB;    // 必要サイズに合わせる（2のべき乗）
    m.SubRegionDisable = 0x00;
    m.TypeExtField     = MPU_TEX_LEVEL0;          // Normal memory
    m.AccessPermission = MPU_REGION_FULL_ACCESS;
    m.DisableExec      = MPU_INSTRUCTION_ACCESS_DISABLE;
    m.IsShareable      = MPU_ACCESS_NOT_SHAREABLE;
    m.IsCacheable      = MPU_ACCESS_NOT_CACHEABLE; // ★Non-Cacheable
    m.IsBufferable     = MPU_ACCESS_NOT_BUFFERABLE;

    HAL_MPU_ConfigRegion(&m);

    HAL_MPU_Enable(MPU_PRIVILEGED_DEFAULT);
}
