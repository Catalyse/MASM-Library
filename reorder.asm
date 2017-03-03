TITLE reorder.asm;//Change to the name of your of your program.
;//**********************************************************
;//Program Description: PA2
;//Author: Taylor May
;//Creation Date: 9/10/2015
;//**********************************************************

INCLUDE Irvine32.inc

move textequ <mov> ;//I like this

.data							;//the data segment
arrayD DWORD 1,2,3					;//The array

.code							;//start code segment
main PROC						     ;//start the main procedure
mov eax, [arrayD];//Move first value to EAX
xchg eax, arrayD+4;//Switch eax and the second value
xchg eax, arrayD+8;//Switch each and the third value
mov arrayD, eax;//Store eax back in the first value

call dumpregs


    exit
main ENDP							;//end of main procedure
END main							;//end of source code and hilarious comments