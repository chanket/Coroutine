# Coroutine
This project tries to make a cross-platform C\C++ coroutine implementation. 
It can save a thread's context at any time, and resume it any time later.

### Platforms
#### Windows x86, with `MSVC` compiler
The context contains: stack data, from ESP to stack base; registers EBX, ESP, EBP, EDI, ESI.
#### Windows x64, with `MSVC` compiler
The context contains: stack data, from RSP to stack base; registers RBX, RSP, RBP, RDI, RSI, R12, R13, R14, R15.
#### Ubuntu x64 18.04, with `g++` compiler
The context contains: stack data, from RSP to stack base; registers RBX, RSP, RBP, R12, R13, R14, R15.
