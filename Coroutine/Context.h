#pragma once
#define CONTEXT_ERROR_UNSUPPORTED_ARCH "UNSUPPORTED ARCHITECTURE"
#define CONTEXT_ERROR_UNSUPPORTED_PLAT "UNSUPPORTED PLATFORM"
#define CONTEXT_ERROR_UNSUPPORTED_COMP "UNSUPPORTED COMPILER"
#include "Context/ContextStruct.h"
#include "Context/GetStackBase.h"

#ifdef _MSC_VER
#ifdef _M_IX86
extern "C" size_t _cdecl UpdateContext(Context context);
extern "C" size_t _cdecl ResumeContext(Context context);
#elif _M_X64
extern "C" size_t UpdateContext(Context context);
extern "C" size_t ResumeContext(Context context);
#else
static_assert(false, CONTEXT_ERROR_UNSUPPORTED_ARCH);
#endif

#elif __GNUG__
#ifdef __i386__
extern "C" size_t UpdateContext(Context context) __attribute__((cdecl));
extern "C" size_t ResumeContext(Context context) __attribute__((cdecl));
#elif __x86_64__
extern "C" size_t UpdateContext(Context context) __attribute__((sysv_abi));
extern "C" size_t ResumeContext(Context context) __attribute__((sysv_abi));
#else
static_assert(false, CONTEXT_ERROR_UNSUPPORTED_ARCH);
#endif

#else
static_assert(false, CONTEXT_ERROR_UNSUPPORTED_COMP);
#endif

void DestroyContext(Context context, void(*freeFunc)(void *) = free) {
	if (context == nullptr) return;

	if (context->Stack != nullptr) freeFunc(context->Stack);
	freeFunc(context);
}

Context SaveContext(void * (*mallocFunc)(size_t) = malloc, void(*freeFunc)(void *) = free, size_t (*sizeFunc)() = nullptr) {
	Context context = (Context)malloc(sizeof(ContextStruct));

	if (context == nullptr) {
		return nullptr;
	}
	else {
		context->Stack = nullptr;
		context->StackBase = GetStackBase();
		context->StackSize = sizeFunc ? sizeFunc() : UpdateContext(context);

		context->Stack = malloc(context->StackSize);
		if (context->Stack == nullptr) {
			DestroyContext(context, freeFunc);
			return nullptr;
		}
		else {
			if (UpdateContext(context)) {
				DestroyContext(context, freeFunc);
				return nullptr;
			}
			else {
				return context;
			}
		}
	}
}