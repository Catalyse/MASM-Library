TITLE PA2.asm;//Change to the name of your of your program.
;//**********************************************************
;//Program Description: PA2
;//Author: Taylor May
;//Creation Date: 9/10/2015
;//**********************************************************

INCLUDE Irvine32.inc

move textequ <mov> ;//I like this
SECONDS_IN_DAY equ (60*60*24); //Part 3//
PART1EVAL equ (3*4*5*6); //Part 1//

.data							;//the data segment
valA		  BYTE	3h,4h,5h,6h		;//Yes I used hex, but its the same at these numbers
valAnswer	  BYTE	0h;

.code							;//start code segment
main PROC						     ;//start the main procedure
;//Part 1							 // When you said one statement I could only assume this is what you meant HOWEVER, 
								;// if you wanted literally one line I would have had to do it above the data declaration like I did in part 3
								;//Yes I know I dont need a semi colon at the end but it makes me feel better about myself. (And visual studio does the spacing right) //
    mov eax,0;
    mov ebx,0;
    mov al, valA;
    mov bl, [valA+1];//I used an array just for funzies. :D
    mul bl;
    mov bl, [valA+2];//Yeah thats right I said funzies.
    mul bl;
    mov bl, [valA+3];//Its okay if you're jelly that you didnt think of it first.
    mul bl;//This causes overflow, with the answer being 168, but what is moved to valAnswer after storage in AL is just 68 //
    mov valAnswer, al;
    call DumpRegs;

    ;//In the event that I was only supposed to use EQU up top and not use the mul directive:

    mov ax, PART1EVAL; //I couldnt store directly into al because of a size mismatch (168 is larger than 8 bits!)
    call DumpRegs;
;//End Part 1 //

;//Part 2 //
    CLC;//Clear carry bit   EFL A46 or 0000 0000 0000 0000 0000 1010 0100 0110 //
    mov eax,0;
    mov ax,0ffffh;
    inc ax;//Overflow//	   EFL 256 or 0000 0000 0000 0000 0000 0010 0101 0110 overflow bit thrown (0) (bit 11), Adjust bit thrown (bit 4) //
    call DumpRegs;
    mov ax,0;
    dec ax;//Underflow//	   EFL 296 or 0000 0000 0000 0000 0000 0010 1001 0110 zero flow thrown (bit 6), sign flag thrown (bit 7) //
    call DumpRegs;
;//End part two, that was easy!

;//Part 3 //
    mov ebx,0;
    mov ebx,SECONDS_IN_DAY;
    call DumpRegs;
					   ;//Results in EBX containing 00015180h OR 86400 in decimal.
;//End Part 3//

    exit
main ENDP							;//end of main procedure
END main							;//end of source code and hilarious comments