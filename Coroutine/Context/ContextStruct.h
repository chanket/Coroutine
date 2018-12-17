#pragma once

struct ContextStructBase
{
	void * Stack;
	void * StackBase;
	size_t StackSize;
	size_t Resumed;
};

#ifdef _MSC_VER
#ifdef _M_IX86
struct ContextStruct : ContextStructBase
{
	size_t EBX, ESP, EBP, EDI, ESI;
};

#elif _M_X64
struct ContextStruct : ContextStructBase
{
	size_t RBX, RSP, RBP, RDI, RSI, R12, R13, R14, R15;
};
#else
static_assert(false, CONTEXT_ERROR_UNSUPPORTED_ARCH);
#endif

#elif __GNUG__
#ifdef __i386__
struct ContextStruct : ContextStructBase
{
	size_t EBX, ESP, EBP, EDI, ESI;
};
#elif __x86_64__
struct ContextStruct : ContextStructBase
{
	size_t RBX, RSP, RBP, R12, R13, R14, R15;
};
#else
static_assert(false, CONTEXT_ERROR_UNSUPPORTED_ARCH);
#endif

#else
static_assert(false, CONTEXT_ERROR_UNSUPPORTED_COMP);
#endif

typedef ContextStruct * Context;