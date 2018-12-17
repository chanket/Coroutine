.MODEL flat
.CODE

;struct ContextStructBase
;{
;	void * Stack;
;	void * StackBase;
;	size_t StackSize;
;	size_t Resumed;
;	size_t EBX, ESP, EBP, EDI, ESI;
;};

;size_t UpdateContext(void * context);
;[ESP + 4]: context
_UpdateContext PROC

	;Context to ECX
	MOV ECX, [ESP + 4]

	;Stack size to EAX
	MOV EAX, [ECX + 4]
	SUB EAX, ESP

	;Check validation
	CMP EAX, [ECX + 8]
	JG UpdateContext_Fail
	MOV EDX, 0
	CMP EDX, [ECX]
	JE UpdateContext_Fail

	;Set Resumed
	MOV [ECX + 12], EDX

	;Save EBX
	MOV [ECX + 16], EBX

	;Save ESP
	MOV [ECX + 20], ESP

	;Save EBP
	MOV [ECX + 24], EBP
	
	;Save EDI
	MOV [ECX + 28], EDI

	;Save ESI
	MOV [ECX + 32], ESI

	;Transfer stack
	MOV EBX, ECX			;Context to EBX
	MOV ECX, EAX			;Stack size to ECX
	MOV EDI, [EBX]			;Destination to EDI
	MOV ESI, ESP			;Source to ESI
	CALL TransferStack
	MOV EDI, [EBX + 28]		;Resume EDI
	MOV ESI, [EBX + 32]		;Resume ESI
	MOV EBX, [EBX + 16]		;Resume EBX

	;Return
UpdateContext_Success:
	MOV EAX, 0
	RET
UpdateContext_Fail:
	RET

_UpdateContext ENDP


;size_t _ResumeContext(void * context);
;[ESP + 4]: context
_ResumeContext PROC
	;Context to ECX
	MOV ECX, [ESP + 4]

	;Set Resumed
	MOV EDX, [ECX + 12]
	INC EDX
	MOV [ECX + 12], EDX

	;Resume ESP
	MOV ESP, [ECX + 20]

	;Resume EBP
	MOV EBP, [ECX + 24]
	
	;Transfer stack
	MOV EBX, ECX			;Context to EBX
	MOV ECX, [EBX + 4]		;Stack base to ECX
	SUB ECX, ESP			;Stack size to ECX
	MOV EDI, ESP			;Destination to RDI
	MOV ESI, [EBX]			;Source to RSI
	CALL TransferStack
	MOV EDI, [EBX + 28]		;Resume EDI
	MOV ESI, [EBX + 32]		;Resume ESI
	MOV EBX, [EBX + 16]		;Resume EBX

	;Return
ResumeContext_Success:
	MOV EAX, 0
	RET
_ResumeContext ENDP


;Copy memory from ESI to EDI, of remaining size ECX, using EDX
;The function will correctly return no matter how the stack changes in copying
;Only EAX, ECX, EDX will be changed
TransferStack PROC
	POP EAX
TransferStack_Loop_4:
	CMP ECX, 4
	JL TransferStack_Loop_1
	;Copy 4 bytes each time
	MOV EDX, [ESI + ECX - 4]
	MOV [EDI + ECX - 4], EDX
	SUB ECX, 4
	JMP TransferStack_Loop_4
TransferStack_Loop_1:
	CMP ECX, 1
	JL TransferStack_Success
	;Copy 1 byte each time
	MOV DL, byte ptr [ESI + ECX - 1]
	MOV byte ptr [EDI + ECX - 1], DL
	SUB ECX, 1
	JMP TransferStack_Loop_1
TransferStack_Success:
	PUSH EAX
	RET
TransferStack ENDP

END