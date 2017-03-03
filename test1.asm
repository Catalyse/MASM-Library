TITLE test1.asm
;// Chapter 3 example Modified for CSCI-2525.

INCLUDE Irvine32.inc     ;//Includes the Irvine32 library of functions

move textequ <mov>

.data

.code
main proc

	mov eax, 135214;
	mov ebx, 451273;
	mov ecx, 855705;
	mov edx, 35624;

	sub eax, ebx;

	add ecx, edx;

	add eax, ecx;

	call DUMPREGS;
	
exit
main endp
end main