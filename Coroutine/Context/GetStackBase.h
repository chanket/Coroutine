#pragma once

void * GetStackBase();

#ifdef _WIN32
#include <Windows.h>
void * GetStackBase() {
	NT_TIB * tib = (NT_TIB*)NtCurrentTeb();
	return tib->StackBase;
}
#else
#include <unistd.h>
#include <pthread.h>
void * GetStackBase() {
	pthread_attr_t threadAttr;
	void * stackBase;
	size_t stackSize;

	if (pthread_getattr_np(pthread_self(), &threadAttr)) std::terminate();
	if (pthread_attr_getstack(&threadAttr, &stackBase, &stackSize)) std::terminate();

	return (unsigned char *)stackBase + stackSize;
}
#endif