.CODE

;struct ContextStructBase
;{
;	void * Stack;
;	void * StackBase;
;	size_t StackSize;
;	size_t Resumed;
;	size_t RBX, RSP, RBP, RDI, RSI, R12, R13, R14, R15;
;};

;size_t UpdateContext(void * context);
;RCX      : context
UpdateContext PROC

	;Stack size to RAX
	MOV RAX, [RCX + 8]
	SUB RAX, RSP

	;Check validation
	CMP RAX, [RCX + 16]
	JG UpdateContext_Fail
	MOV RDX, 0
	CMP RDX, [RCX]
	JE UpdateContext_Fail

	;Set Resumed
	MOV [RCX + 24], RDX

	;Save RBX
	MOV [RCX + 32], RBX

	;Save RSP
	MOV [RCX + 40], RSP

	;Save RBP
	MOV [RCX + 48], RBP
	
	;Save RDI
	MOV [RCX + 56], RDI

	;Save RSI
	MOV [RCX + 64], RSI

	;Save R12
	MOV [RCX + 72], R12

	;Save R13
	MOV [RCX + 80], R13

	;Save R14
	MOV [RCX + 88], R14

	;Save R15
	MOV [RCX + 96], R15

	;Transfer stack
	MOV R8, RCX				;Context to R8
	MOV RCX, RAX			;Stack size to RCX
	MOV RDI, [R8]			;Destination to RDI
	MOV RSI, RSP			;Source to RSI
	CALL TransferStack
	MOV RDI, [R8 + 56]		;Resume RDI
	MOV RSI, [R8 + 64]		;Resume RSI

	;Return
UpdateContext_Success:
	MOV RAX, 0
	RET
UpdateContext_Fail:
	RET

UpdateContext ENDP


;size_t ResumeContext(void * context);
;RCX      : context
ResumeContext PROC
	;Set Resumed
	MOV RDX, [RCX + 24]
	INC RDX
	MOV [RCX + 24], RDX

	;Resume RBX
	MOV RBX, [RCX + 32]

	;Resume RSP
	MOV RSP, [RCX + 40]

	;Resume RBP
	MOV RBP, [RCX + 48]

	;Resume R12
	MOV R12, [RCX + 72]

	;Resume R13
	MOV R13, [RCX + 80]

	;Resume R14
	MOV R14, [RCX + 88]

	;Resume R15
	MOV R15, [RCX + 96]
	
	;Transfer stack
	MOV R8, RCX				;Context to R8
	MOV RCX, [R8 + 8]		;Stack base to RCX
	SUB RCX, RSP			;Stack size to RCX
	MOV RDI, RSP			;Destination to RDI
	MOV RSI, [R8]			;Source to RSI
	CALL TransferStack
	MOV RDI, [R8 + 56]		;Resume RDI
	MOV RSI, [R8 + 64]		;Resume RSI

	;Return
ResumeContext_Success:
	MOV RAX, 0
	RET
ResumeContext ENDP


;Copy memory from RSI to RDI, of remaining size RCX, using RDX
;The function will correctly return no matter how the stack changes in copying
;Only RAX, RCX, RDX will be changed
TransferStack PROC
	POP RAX
TransferStack_Loop_8:
	CMP RCX, 8
	JL TransferStack_Loop_1
	;Copy 8 bytes each time
	MOV RDX, [RSI + RCX - 8]
	MOV [RDI + RCX - 8], RDX
	SUB RCX, 8
	JMP TransferStack_Loop_8
TransferStack_Loop_1:
	CMP RCX, 1
	JL TransferStack_Success
	;Copy 1 byte each time
	MOV DL, byte ptr [RSI + RCX - 1]
	MOV byte ptr [RDI + RCX - 1], DL
	SUB RCX, 1
	JMP TransferStack_Loop_1
TransferStack_Success:
	PUSH RAX
	RET
TransferStack ENDP

END