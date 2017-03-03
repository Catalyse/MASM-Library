TITLE Problem4.asm

INCLUDE Irvine32.inc     ;//Includes the Irvine32 library of functions

move textequ <mov>

.data
testArray1 BYTE 0h, 2h, 5h, 9h, 0Ah;
testArray2 BYTE 5h, 9h, 1Ah, 22h, 25h, 31h;

.code
;//=======================================
;//This method will scan an array whos start location must be stored in ESI and the Array length
;//stored in ECX prior to calling the method.
;//Will print each gap, then the sum.
checkArray proc
	dec ECX;//So we dont go out of index
	mov EBX, 0;//Use EBX for sum
	mov EAX, 0;
L1:
	push ECX

	mov AH, [ESI];
	mov AL, [ESI + 1];
	sub AL, AH;
	mov AH, 0;//Clear the subtractor
	call WriteInt;
	call CRLF;
	add EBX, EAX;
	add ESI, 1;

	pop ECX
	loop L1;

	mov EAX, EBX;
	call WriteInt;
	call CRLF;

	ret;
checkArray endp;
;//=======================================

main proc;//All you must do is change the set values for ESI and ECX, EG: change to testArray1(book array)
	mov ESI, OFFSET testArray2;
	mov ECX, LENGTHOF testArray2;
	call checkArray;
	call WaitMsg;
exit
main endp

end main