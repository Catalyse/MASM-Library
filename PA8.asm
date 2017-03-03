TITLE PA8.asm
;//**********************************************************
;//Program Description: PA8.asm
;//Author: Taylor May
;//Creation Date: 20151120
;//**********************************************************

INCLUDE Irvine32.inc

move textequ <mov> ;//I like dis. Dis mine now.
clear textequ <call CRLF>;
write textequ <call writeL>;

.data	;//thine data segment (And yes there is a lot)

.code   ;//thine code segment
;//---------------PROTO Section----------------------
Menu PROTO;//Nothing passed to main
WriteL PROTO;//Nothing passed to writel
UserInput PROTO;//Nothing is passed
SortArray PROTO, arrOff:DWORD, arrLen:DWORD;
CopyArr PROTO, arr1:DWORD, arr2:DWORD, arrL:DWORD;
DisplayArr PROTO, uArr:DWORD, sArr:DWORD, lArr:DWORD;//unsortedArr, sortedArr, lengthArr.
;//--------------------END---------------------------
;//==================================================
;//==================================================
;//Writes the string in EDX, adds a newline;
writeL proc;//called using write
    call WriteString;
    call CRLF;
ret;
writeL endp;
;//==================================================
;//==================================================
UserInput proc;
.data;
    statement1 BYTE "Please enter the values of your array ended by a 0:",0;
    stat2 BYTE "Invalid Entry.",0;
    count DWORD 0;
    aArray WORD 100 DUP(?);
    bArray WORD 100 DUP(?);//Sorted Array
.code;
    mov EDX, OFFSET statement1;
    write;
    mov ESI, OFFSET bArray;
L1:
    call ReadInt;
    cmp EAX,0;
    JE L2;//user terminated.
    JL L3;
    cmp EAX, 750;
    JG L3;
    mov ESI, EAX;
    add ESI, 2;
    add count, 1;
    cmp count, 100;
    JGE L2;//Array limit hit.
    JMP L1;//Loop.
L2:
    invoke CopyArr,ADDR aArray, ADDR bArray, count;//arrOff is already the address

    invoke SortArray, ADDR bArray, count;

    invoke DisplayArr, ADDR aArray, ADDR bArray, count;

    JMP E1;
L3:
    mov EDX, OFFSET stat2;
    write;
    JMP L1;
E1:
ret;
UserInput endp;
;//==================================================
;//==================================================
RandomFill proc;
.data;
    statement11 BYTE "Filling your array...",0;
    arrSize DWORD 100;
    cArray WORD 110 DUP(0);
    dArray WORD 110 DUP(0);//Sorted Array
.code;
    mov EDX, OFFSET statement1;
    write;
    mov ESI, OFFSET cArray;
    mov ECX, 100;
L1:
    mov EAX, 749;
    call RandomRange;
    add EAX, 1;
    mov [ESI], EAX;
    add ESI, 2;
    loop L1;
    
    invoke CopyArr,ADDR cArray, ADDR dArray, 100;//arrOff is already the address

    invoke SortArray, ADDR dArray, 100;

    invoke DisplayArr, ADDR cArray, ADDR dArray, 100;
ret;
RandomFill endp;
;//==================================================
;//==================================================
SortArray proc, arrOff:DWORD, arrLen:DWORD;
.data
    boolVal BYTE 0;
.code

L1:;//If we sorted we must sort again
    mov EAX, 0;
    mov ECX, arrLen;//Set loop count
    sub ECX, 1;
    mov ESI, arrOff;
    mov boolVal, 0;//Reset the bool
L2:
    mov AL, [ESI];
    add ESI, 1;//Set to next addr
    cmp AL, [ESI];
    JG SWAP;//If first val is greater than second value we need to swap them

SR:;//Swap return
    loop L2;
    JMP R1;
SWAP:
    mov AL, [ESI];//Second Value
    xchg [ESI-1], AL;
    mov [ESI], AL;
    mov boolVal, 1;//Swap made, must rerun
    JMP SR;

R1:;//Return tag
    cmp boolVal, 1;
    JE L1;
ret;
SortArray endp;
;//==================================================
;//==================================================
CopyArr proc, arr1:DWORD, arr2:DWORD, arrL:DWORD;//Arr1 and Arr2 are ADDR

    mov ECX, arrL;//set loop
    mov ESI, arr1;//Copy from.
    mov EDX, arr2;//Copy to.
L1:
    mov EAX, [ESI];
    mov [EDX], EAX;
    inc EDX;
    inc ESI;
    loop L1;

ret;
CopyArr endp;
;//==================================================
;//==================================================
DisplayArr proc, uArr:DWORD, sArr:DWORD, lArr:DWORD;
.data;
    uArrT BYTE "Unsorted Array:                   ",0;
    sArrT BYTE "Sorted Array:                     ",0;
.code;
    mov EDX, 0;//Reset EDX
    call Gotoxy
    mov EDX, OFFSET uArrT;
    write;

    mov DH, 1;//start on next row to not overwrite text
    call Gotoxy;

    mov ECX, lArr;
    mov ESI, uArr;
L1:
    mov EAX, 0;
    mov AX, [ESI]
    call WriteDec;
    add DL, 10;
    cmp DL, 75;
    JL R1;
    mov DL, 0;//DL is too high out of index potential.
    add DH, 1;
R1:;//jump over DL reset
    add ESI, 1;//next element
    call Gotoxy;
    loop L1;

    add DH, 1;//Move to next row.
    mov DL, 0;//Start from beginning.
    call Gotoxy;
    push EDX;//Save cursor location.
    mov EDX, OFFSET sArrT;
    write
    pop EDX;
    add DH, 1;
    call Gotoxy;//Start the display
    mov ECX, lArr;
    mov ESI, sArr;
L2:
    mov EAX, 0;
    mov AX, [ESI]
    call WriteDec;
    add DL, 10;
    cmp DL, 75;
    JL R2;
    mov DL, 0;//DL is too high out of index potential.
    add DH, 1;
R2:;//jump over DL reset
    add ESI, 1;//Next element
    call Gotoxy;
    loop L2;

ret;
DisplayArr endp;
;//==================================================
;//==================================================
;//This is the main menu.
Menu proc;
.data
    menu1 BYTE "Welcome to the BubbleSort Program!", 0;
    menu2 BYTE "Option 1: Enter an Array to be sorted.", 0;
    menu3 BYTE "Option 2: Use a randomly filled array.", 0;
    menu4 BYTE "Option 3: Exit.",0;
    menuError BYTE "Error: invalid option.",0;
.code
ST1:
    mov EAX, 0Ah;
    call SetTextColor;
    mov EDX, OFFSET menu1;
    write;
    mov EDX, OFFSET menu2;
    write;
    mov EDX, OFFSET menu3;
    write;
    mov EDX, OFFSET menu4;
    write;
    call ReadInt;
    cmp EAX,1;
    JE OP1;
    cmp EAX,2;
    JE OP2;
    cmp EAX,3;
    JE OP3;
    JNE OP4;

OP1:;//User generated array;
    invoke UserInput;
    JMP ST1;
OP2:;//Randomly Generated Array
    invoke RandomFill;
    JMP ST1;
OP4:
    mov EDX, OFFSET menuError;
    write;
    JMP ST1;
OP3:
ret;
Menu endp;
;//==================================================
;//==================================================
main PROC						     ;//start the main procedure
.data;
    exitMsg BYTE "The program has terminated.",0;
.code;
    call Randomize					;//A must at the beginning of any program that does random crap.
    mov EAX, 0;					 //Clear All Registers
    mov EBX, 0;
    mov ECX, 0;
    mov EDX, 0;
    call Menu;
    clear;
    mov EDX, OFFSET exitMsg;
    write;
    clear;
    call WaitMsg;
    exit
main ENDP							;//end of main procedure
END main							;//end of source code and hilarious comments(yes you know you laughed)