TITLE fibonacci.asm;//Change to the name of your of your program.
;//**********************************************************
;//Program Description: fibonacci
;//Author: Taylor May
;//Creation Date: 9/10/2015
;//**********************************************************

INCLUDE Irvine32.inc

move textequ <mov> ;//I like this

.data							;//the data segment
arrayF BYTE 0,1,5 DUP(0);			;//The array

.code							;//start code segment
main PROC						     ;//start the main procedure
    mov esi, OFFSET arrayF;
    mov al,[esi];
    inc esi;//+1
    add al,[esi];
    inc esi;//+2
    mov [esi], al;//Move element 3 into the array
    add al,[esi]-1;//Since arrayF+2 is already in AL, just add 1 again to get the 4th element
    inc esi;//+3
    mov [esi], al;
    add al,[esi]-1;
    inc esi;//+4
    mov [esi], al;
    add al,[esi]-1;
    inc esi;//+5
    mov [esi], al;
    add al,[esi]-1;
    inc esi;//+6
    mov [esi], al;

    mov ebx, DWORD PTR [arrayF+3]

    call dumpregs


    exit
main ENDP							;//end of main procedure
END main							;//end of source code and hilarious comments