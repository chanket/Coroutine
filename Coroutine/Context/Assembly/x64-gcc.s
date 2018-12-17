.globl UpdateContext
.globl ResumeContext

#struct ContextStructBase
#{
#	void * Stack;
#	void * StackBase;
#	size_t StackSize;
#	size_t Resumed;
#	size_t RBX, RSP, RBP, R12, R13, R14, R15;
#};

#size_t UpdateContext(void * context)
#RDI	: context
UpdateContext:
.cfi_startproc
	#Stack size to RAX
	MOVQ 8(%RDI), %RAX
	SUBQ %RSP, %RAX

	#Check validation
	CMPQ 16(%RDI), %RAX
	JG UpdateContext_Fail
	MOVQ $0, %RDX
	CMPQ (%RDI), %RDX
	JE UpdateContext_Fail

	#Set Resumed
	MOVQ %RDX, 24(%RDI)
	
	#Save RBX
	MOVQ %RBX, 32(%RDI)

	#Save RSP
	MOVQ %RSP, 40(%RDI)

	#Save RBP
	MOVQ %RBP, 48(%RDI)

	#Save R12
	MOVQ %R12, 56(%RDI)

	#Save R13
	MOVQ %R13, 64(%RDI)

	#Save R14
	MOVQ %R14, 72(%RDI)

	#Save R15
	MOVQ %R15, 80(%RDI)

	#Transfer stack
	MOVQ %RDI, %R8			#Context to R8
	MOVQ %RAX, %RCX			#Stack size to RCX
	MOVQ (%R8), %RDI		#Destination to RDI
	MOVQ %RSP, %RSI			#Source to RSI
	CALL TransferStack
	
UpdateContext_Success:
	MOVQ $0, %RAX
	RET
UpdateContext_Fail:
	RET
.cfi_endproc


#size_t ResumeContext(void * context)
#RDI	: context
ResumeContext:
.cfi_startproc

	#Set Resumed
	MOVQ 24(%RDI), %RDX
	INCQ %RDX
	MOVQ %RDX, 24(%RDI)

	#Resume RBX
	MOVQ 32(%RDI), %RBX

	#Resume RSP
	MOVQ 40(%RDI), %RSP

	#Resume RBP
	MOVQ 48(%RDI), %RBP

	#Resume R12
	MOVQ 56(%RDI), %R12

	#Resume R13
	MOVQ 64(%RDI), %R13

	#Resume R14
	MOVQ 72(%RDI), %R14

	#Resume R15
	MOVQ 80(%RDI), %R15

	#Transfer stack
	MOVQ %RDI, %R8			#Context to R8
	MOVQ 8(%R8), %RCX		#Stack base to RCX
	SUBQ %RSP, %RCX			#Stack size to RCX
	MOVQ %RSP, %RDI			#Destination to RDI
	MOVQ (%R8), %RSI		#Source to RSI
	CALL TransferStack
	
ResumeContext_Success:
	MOVQ $0, %RAX
	RET
.cfi_endproc


#Copy memory from RSI to RDI, of remaining size RCX, using RDX
#The function will correctly return no matter how the stack changes in copying
#Only RAX, RCX, RDX will be changed
TransferStack:
.cfi_startproc
	POPQ %RAX
TransferStack_Loop_8:
	CMPQ $8, %RCX
	JL TransferStack_Loop_1
	#Copy 8 bytes each time
	MOVQ -8(%RSI, %RCX), %RDX
	MOVQ %RDX, -8(%RDI, %RCX)
	SUBQ $8, %RCX
	JMP TransferStack_Loop_8
TransferStack_Loop_1:
	CMPQ $1, %RCX
	JL TransferStack_Success
	#Copy 1 byte each time
	MOVB -1(%RSI, %RCX), %DL
	MOVB %DL, -1(%RDI, %RCX)
	SUBQ $1, %RCX
	JMP TransferStack_Loop_1
TransferStack_Success:
	PUSHQ %RAX
	RET
.cfi_endproc
