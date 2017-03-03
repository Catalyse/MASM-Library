TITLE PA5.asm
;//**********************************************************
;//Program Description: PA5.asm
;//Author: Taylor May
;//Creation Date: 20151016 (Yes the day it was due)
;//**********************************************************

INCLUDE Irvine32.inc

move textequ <mov> ;//I like dis. Dis mine now.
clear textequ <call CRLF>;
write textequ <call writeL>;
error textequ <call ErrorMsg>;
colors textequ <call RandomColor>;

.data	;//thine data segment (And yes there is a lot)
menu1 BYTE "Welcome to the string encryption program.", 0;
menu2 BYTE "Please choose from the options below: ", 0;
menuChoice1 BYTE "1) Run. ", 0;//I can follow instructions but dont 1 and 2 do the same thing?
menuChoice2 BYTE "2) Quit. ", 0;
menuChoice3 BYTE "1) Enter string to encrypt. ", 0;
menuChoice31 BYTE "Enter string to encrypt: ", 0;
menuChoice4 BYTE "2) Use default string to encrypt.", 0;
prompt1 BYTE "Would you like to encrypt? Yes = 1, No = 2."
defaultEncrypt BYTE "Encryption using a rotation key.", 0;
arrSize DWORD ?;
strStorage BYTE 140 DUP(0),0;
strEncrypted BYTE 140 DUP(0),0;
menuError BYTE "Whoops! You can't read very well, please pick a valid choice.", 0;
key BYTE -2,-1,2,3,1,-3,4,1,5,2;
keyLength BYTE 0Ah;
errPrompt BYTE "WHOOPS! You're not very good at reading! Try again!", 0;
exitMsg BYTE "The program has terminated.", 0;

.code   ;//thine code segment
;//==================================================
;//==================================================
;//==================================================
;//UserInt procedure grabs a string from the user to encrypt.
;//Dumps int into EAX then returns.
UsrInput proc;
    mov EDX, OFFSET menuChoice31;
    write;
    	mov EDX, OFFSET strStorage;
	mov ECX, SIZEOF strStorage;
	call ReadString;
	mov arrSize, EAX;

	mov EDX, OFFSET strStorage;
	call WriteString;
	call CRLF;
ret;
UsrInput endp;
;//==================================================
;//==================================================
;//EDX contains the offset to the string we need to encrypt, all other regs fair game.
Encrypt proc;
    mov ecx, arrSize;//Move the size of the string to ECX to set the loop counter.
    mov ESI, OFFSET strStorage;
    mov EAX, OFFSET key;//Store key array for use.
    mov EBX, 0;//Set counters to 0
L1:
    push ECX;

    mov CL, [EAX];//Store one byte of key.

    cmp CL, 0;//Rotate Right.
    JGE R1;

    ROL BYTE PTR [ESI], CL;//rotate right.

    cmp EBX, 10;
    JE RK1;
    JMP RR1;//Continue Loop

R1:
    ROR BYTE PTR [ESI], CL;

RR1:;//Jump back to look
    inc ESI;
    inc EAX;

    pop ECX;
    loop L1;
    JMP E1;
RK1:;//Reset key to 0;
    mov EAX, OFFSET key;
    JMP R1;
E1:    
ret;
Encrypt endp;
;//==================================================
;//==================================================
Decrypt proc;
    mov ecx, arrSize;//Move the size of the string to ECX to set the loop counter.
    mov ESI, OFFSET strStorage;
    mov EAX, OFFSET key;//Store key array for use.
    mov EBX, 0;//Set counters to 0
L1:
    push ECX;

    mov CL, [EAX];//Store one byte of key.
    neg CL;

    cmp CL, 0;//Rotate Right.
    JGE R1;

    ROR BYTE PTR [ESI], CL;//rotate right.

    cmp EBX, 10;
    JE RK1;
    JMP RR1;//Continue Loop

R1:
    ROL BYTE PTR [ESI], CL;

RR1:;//Jump back to look
    inc ESI;
    inc EAX;

    pop ECX;
    loop L1;
    JMP E1;
RK1:;//Reset key to 0;
    mov EAX, OFFSET key;
    JMP R1;
E1:

ret;
Decrypt endp;
;//==================================================
;//==================================================
;//Generic Error Message to save me some typing
ErrorMsg proc;//Called using error;
    push EDX;
    mov EDX, OFFSET errPrompt;
    write;
    clear;
    pop EDX;
ret;
ErrorMsg endp;
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
;//I Ran out of time on this one, and needed to just put 1 or 2 for it, mark me down but Im just glad I got this done!
SubMenu1 proc;
ST1:
    mov EDX, OFFSET prompt1;
    write;
    call ReadInt;
    cmp EAX,1;
    JE OP1;
    cmp EAX,2;
    JE OP2;
    JNE OP3;
OP1:
    call Decrypt;
    mov EDX, OFFSET strStorage;
    write;
    JMP OP2;
OP3:
    mov EDX, OFFSET menuError;
    write;
OP2:
ret;
SubMenu1 endp;
;//==================================================
;//==================================================
SubMenu proc;
ST1:
    mov EDX, OFFSET menuChoice3;
    write;
    mov EDX, OFFSET menuChoice4;
    write;
    call ReadInt;
    cmp EAX,1;
    JE OP1;
    cmp EAX,2;
    JE OP2;
    JNE OP3;
OP1:
    call UsrInput;
    call Encrypt;
    mov EDX, OFFSET strStorage;
    write;
    call SubMenu1;

    JMP OP4;
OP2:
    mov EDX, OFFSET defaultEncrypt;
    write;
    mov ESI, OFFSET defaultEncrypt;
    call Encrypt;
    call SubMenu1;
    JMP OP4;
OP3:
    mov EDX, OFFSET menuError;
    write;
OP4:
ret;
SubMenu endp;
;//==================================================
;//This is the main menu.
Menu proc;
ST1:
    mov EAX, 0Ah;
    call SetTextColor;
    mov EDX, OFFSET menu1;
    write;
    mov EDX, OFFSET menu2;
    write;
    mov EDX, OFFSET menuChoice1;
    write;
    mov EDX, OFFSET menuChoice2;
    write;
    call ReadInt;
    cmp EAX,1;
    JE OP1;
    cmp EAX,2;
    JE OP3;
    JNE OP2;

OP1:
    call SubMenu;
    JMP ST1;
OP2:
    mov EDX, OFFSET menuError;
    write;
    JMP ST1;
OP3:
ret;
Menu endp;
;//==================================================
;//==================================================
main PROC						     ;//start the main procedure
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