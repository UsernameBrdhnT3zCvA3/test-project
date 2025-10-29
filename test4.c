// Core/Src/new_overrides.cpp
#include <new>        // std::bad_alloc, std::nothrow_t
#include <cstddef>    // size_t

extern "C" {
#include "FreeRTOS.h" // pvPortMalloc / vPortFree の宣言をCリンケージで取り込む
}

// 例外が無効でもビルドが通るようにガード
void* operator new(std::size_t n) noexcept(false) {
    if (void* p = pvPortMalloc(n)) return p;
#if __cpp_exceptions
    throw std::bad_alloc();
#else
    return nullptr;   // 例外無効時はnullptrを返す（呼び出し側でチェック）
#endif
}

void  operator delete(void* p) noexcept {
    if (p) vPortFree(p);
}

void* operator new[](std::size_t n) noexcept(false) {
    if (void* p = pvPortMalloc(n)) return p;
#if __cpp_exceptions
    throw std::bad_alloc();
#else
    return nullptr;
#endif
}

void  operator delete[](void* p) noexcept {
    if (p) vPortFree(p);
}

// nothrow 版（任意だが入れておくと安全）
void* operator new(std::size_t n, const std::nothrow_t&) noexcept { return pvPortMalloc(n); }
void* operator new[](std::size_t n, const std::nothrow_t&) noexcept { return pvPortMalloc(n); }




111
// somewhere (e.g. Core/Src/new_overrides.cpp)
#include <new>
extern "C" void *pvPortMalloc(size_t);
extern "C" void  vPortFree(void*);

void* operator new(std::size_t n) {
    if (void* p = pvPortMalloc(n)) return p;
    throw std::bad_alloc();
}
void  operator delete(void* p) noexcept { if (p) vPortFree(p); }

void* operator new[](std::size_t n) {
    if (void* p = pvPortMalloc(n)) return p;
    throw std::bad_alloc();
}
void  operator delete[](void* p) noexcept { if (p) vPortFree(p); }

// 例: nothrow版も（任意）
void* operator new(std::size_t n, const std::nothrow_t&) noexcept { return pvPortMalloc(n); }
void* operator new[](std::size_t n, const std::nothrow_t&) noexcept { return pvPortMalloc(n); }


222
// Core/Src/malloc_wrap.c
#include <string.h>
void *pvPortMalloc(size_t);
void  vPortFree(void*);
/* FreeRTOS 2024 以降なら pvPortRealloc あり。なければ自前で実装 */
void *pvPortRealloc(void*, size_t);

void *__wrap_malloc(size_t n)              { return pvPortMalloc(n); }
void  __wrap_free(void* p)                 { if(p) vPortFree(p); }
void *__wrap_calloc(size_t n, size_t sz)   { size_t s=n*sz; void* p=pvPortMalloc(s); if(p) memset(p,0,s); return p; }
void *__wrap_realloc(void* p, size_t n)    {
#if defined(pvPortRealloc)
    return pvPortRealloc(p, n);
#else
    if (!p) return pvPortMalloc(n);
    void* q = pvPortMalloc(n);
    if (q) { /* 元サイズ不明なら最小限に */ memcpy(q, p, n); vPortFree(p); }
    return q;
#endif
}

333
-Wl,--wrap=malloc -Wl,--wrap=free -Wl,--wrap=calloc -Wl,--wrap=realloc




