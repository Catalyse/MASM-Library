TITLE quiz6.asm

INCLUDE Irvine32.inc     ;//Includes the Irvine32 library of functions

move textequ <mov>

.data
prompt1 BYTE "Enter a large decimal number: ", 0;
prompt2 BYTE "Enter how many spaces from the right the decimal point should be: ", 0;
decPoint BYTE ?;
arrSize DWORD ?;
strStorage BYTE 100 DUP(0);

.code
;//=======================================
UserInput proc;
	mov EDX, OFFSET prompt1;//Read out first instruction
	call WriteString;
	mov EDX, OFFSET strStorage;
	mov ECX, SIZEOF strStorage;
	call ReadString;
	mov arrSize, EAX;

	mov EDX, OFFSET strStorage;
	call WriteString;
	call CRLF;

	mov EDX, OFFSET prompt2;//Read out second instruction
	call WriteString;
	
	call ReadInt;
	mov decPoint, AL;
	call WriteInt;
	call CRLF;
ret;
UserInput endp;
;//=======================================
;//EBX contains the strStorage start location
;//EDX contains the dec location number
;//ECX contains array length;
Display proc;
	CMP ECX, EDX;
	JGE L1;
	JMP G1;
;//Use if dec location is smaller than or the same as the number size.
L1:
	mov AL, CL;//How many numbers we must write before the decimal
	sub AL, DL;
	mov AH, CL;//Remaining numbers to write post decimal.
	sub AH, AL;
	movzx ECX, AL;
	push EAX;
	mov ESI, 0;//Use as counter
LL1:;//Loop for Low
	mov al, [EBX + ESI];
	call WriteChar;
	add ESI, 1;
	loop LL1;
	;//Add DEC
	mov AL, '.';
	call WriteChar;
	
	pop EAX;
	movzx ECX, AH;

LH1:;
	mov al, [EBX + ESI];
	call WriteChar;
	add ESI, 1;
	loop LH1;
	JMP E1;
	
;//Use if dec location is greater than number size.
G1:
	mov AL, DL;//How many numbers we must write before the decimal
	sub AL, CL;
	push ECX;
	movzx ECX, AL;
	mov ESI, 0;//Use as counter

	;//Add DEC
	mov AL, '.';
	call WriteChar;

GL1:
	mov al, "0";
	call WriteChar;
	loop GL1;

	pop ECX;
GH1:;//Loop for Low
	mov al, [EBX + ESI];
	call WriteChar;
	add ESI, 1;
	loop GH1;

E1:
ret;
Display endp;
;//=======================================
;//=======================================
;//=======================================

main proc;
	call UserInput;

	;//Setup for Display
	movzx EDX, decPoint;
	mov EBX, OFFSET strStorage;
	mov ECX, arrSize;

	call Display;

	call CRLF;
	call WaitMsg;

exit
main endp

end main