TITLE PA4.asm
;//**********************************************************
;//Program Description: PA4.asm
;//Author: Taylor May
;//Creation Date: 20151009
;//**********************************************************

INCLUDE Irvine32.inc

move textequ <mov> ;//I like dis. Dis mine now.

.data							;//thine data segment
prompt1 BYTE "To maintain my sanity and make sure this program doesnt kill this computer,     please limit your choices to 1-50! ", 0;
prompt2 BYTE "Enter a value: ", 0;
prompt3 BYTE "WHOOPS! You're not very good at reading! Please enter a valid number between 1 and 50: ", 0;
prompt4 BYTE "TIME TO GENERATE SOME RANDOM S**T :D", 0;
stringlength BYTE 30;
stringArr BYTE ?;

.code							;//thine code segment
;//==================================================
;//UserInt procedure grabs an int from the user.
;//Dumps int into EAX then returns.
UserInt proc;
    	mov EDX, OFFSET prompt1;
call settextc;
	call WriteString;
	call CRLF;
	mov EDX, OFFSET prompt2;
call settextc;
     call WriteString;
	;//Begin Read//
     call ReadInt;//In my testing I discovered that MASM does have some error checking, and sets EAX to 0 if you try to enter something other than an int.
	cmp EAX, 1;
	jl RT;//Check if less than 1: send to retry
	cmp EAX, 50;
	jle DN;//Check if less than or equal to 50: send to done
RT:
	mov EDX, OFFSET prompt3;
call settextc;
     call WriteString;
	call ReadInt;
	cmp EAX, 1;
	jl RT;//Check if less than 1: send to retry
	cmp EAX, 50;
	ja RT;//Check if greater than 50: send to retry
DN:
	ret;
UserInt endp;
;//==================================================
;//==================================================
RandStr proc;
    mov EDX, OFFSET prompt4;
call settextc;
    call WriteString;
    call CRLF;
    mov ECX, EAX;//Value set from UserInt;
    mov EBX, 0;
L1:
    push ECX;
    movzx ECX, stringlength;
    L2:
	   call RandChar;
	   mov [stringArr + EBX], AL;
	   inc EBX;
    loop L2;
    mov EDX, OFFSET stringArr;
call settextc;
    call WriteString;
    call CRLF;
    mov EBX, 0;
    pop ECX;
loop L1;
ret;
RandStr endp;
;//==================================================
;//==================================================
RandChar proc;
    mov EAX, 19h;
    call RandomRange;
    add EAX, 65;
    ret;
RandChar endp;
;//==================================================
;//==================================================
;//This procedure handles the random text coloration
settextc proc
	push eax;
	mov eax, 14;
	call RandomRange;
	add eax, 1;//Add one to avoid black and get to index 15.
	call SetTextColor;
	pop eax;
	ret;
settextc endp
;//==================================================
main PROC						     ;//start the main procedure
    call Randomize;
    call UserInt;
    call RandStr;

    call dumpregs

    call WaitMsg;
    exit
main ENDP							;//end of main procedure
END main							;//end of source code and hilarious comments