TITLE Problem4.asm

INCLUDE Irvine32.inc     ;//Includes the Irvine32 library of functions

move textequ <mov>

.data
prompt1 BYTE "Array Generation Complete...", 0;
fillArr BYTE ?;

.code
;//=======================================
randNum proc;
	mov EAX, 50;//Set the max value of 50
	call RandomRange;//Do random stuff
	add EAX, 50;//Add 50 to put in 50-100 range
	ret;
randNum endp;
;//=======================================
;//=======================================
AlphaGrade proc;
	mov ESI, 0;
	mov EAX, 0;
	mov ECX, 20;
L1:
	push ECX;
	mov AH, [fillArr + ESI];

	cmp AH, 60;
	JL F1;
	cmp AH, 70;
	JL D1;
	cmp AH, 80;
	JL C1;
	cmp AH, 90;
	JL B1;
	JGE A1;

F1:
	mov AL, 'F';
	mov EBX, RED + (YELLOW * 16);
	JMP CMP1;
D1:
	mov AL, 'D';
	mov EBX, BLACK + (YELLOW * 16);
	JMP CMP1;
C1:
	mov AL, 'C';
	mov EBX, YELLOW + (BLACK * 16);
	JMP CMP1;
B1:
	mov AL, 'B';
	mov EBX, GREEN + (BLACK * 16);
	JMP CMP1;
A1:
	mov AL, 'A';
	mov EBX, GREEN + (BLACK * 16);
	JMP CMP1;
CMP1:
	call PrintGrade;
	add ESI, 1;
	pop ECX;
	loop L1;
ret;
AlphaGrade endp;
;//=======================================
;//=======================================
PrintGrade proc;
	mov EDX, 0;
	push EAX;
	mov AL, AH;
	mov AH, 0;
	call WriteInt;
	pop EAX;
	mov CH, 21;
	sub CH, CL;
	mov DH, CH;
	mov DL, 8;
	call Gotoxy;

	push EAX;//Set the color
	mov EAX, EBX;
	call SetTextColor;
	pop EAX;
	
	mov AH, 0;
	call WriteChar;
	mov DL, 0;
	add DH, 1;
	call Gotoxy;

	push EAX;//Return Color to normal
	mov EAX, LightGray + (BLACK * 16);
	call SetTextColor;
	pop EAX;
ret;
PrintGrade endp;
;//=======================================
;//=======================================
genArray proc;
	push ECX;
	mov ESI, 0;
	mov ECX, 20;
L1:
	push ECX;
	call randNum;
	mov [fillArr + ESI], AL;
	add ESI, 1;
	pop ECX;
	loop L1;

	pop ECX;
	mov EDX, OFFSET prompt1;
	call WriteString;
	call CRLF;
ret;
genArray endp;
;//=======================================

main proc;//All you must do is change the set values for ESI and ECX, EG: change to testArray1(book array)
	call Randomize;
	call genArray;
	call AlphaGrade;

	call WaitMsg;
exit
main endp

end main