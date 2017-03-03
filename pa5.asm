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
menu1 BYTE "Welcome to the colorful random number thingy!", 0;
menu2 BYTE "Please choose from the options below: ", 0;
menuChoice1 BYTE "1) Print Randomly Generated Arrays.", 0;//I can follow instructions but dont 1 and 2 do the same thing?
menuChoice2 BYTE "2) Run Again. ", 0;
menuChoice3 BYTE "3) Quit. ", 0;
menuError BYTE "Whoops! You can't read very well, please pick a valid choice.", 0;
prompt1 BYTE "You will now choose three numbers each with their own restrictions, N, J, and K.", 0;
prompt11 BYTE "To maintain my sanity and make sure this program doesnt kill this computer,     please limit your choices to 1-50! ", 0;
prompt12 BYTE "Enter a value for N: ", 0;
prompt2 BYTE "J and K are a range of numbers please make J smaller than K or we get to restart:", 0;
prompt21 BYTE "To maintain my sanity and make sure this program doesnt kill this computer,     please limit your choices to 1-2,147,483,647!", 0;
prompt22 BYTE "Enter a value for --J--(Smaller Value): ", 0;
prompt23 BYTE "Enter a value for ---K---(Larger Value): ", 0;
errPrompt BYTE "WHOOPS! You're not very good at reading! Try again!", 0;
prompt4 BYTE "TIME TO GENERATE SOME RANDOM S**T :D", 0;
exitMsg BYTE "The program has terminated.", 0;
storageArr DWORD ?;//Declared last so I dont overwrite stuff

.code   ;//thine code segment
;//==================================================
;//This runs the procs in the right series initially.
MainHandler proc;
    call UsrInput;//EBX = J, EAX = K, CL = N;
    call ArrayFill;
    call ReadArr;
ret;
MainHandler endp;
;//==================================================
;//==================================================
;//UserInt procedure grabs an int from the user.
;//Dumps int into EAX then returns.
UsrInput proc;
;//Prompt1:
    JMP P12;
P11:
    error;
P12:
    mov EDX, OFFSET prompt1;
    write;
    mov EDX, OFFSET prompt11;
    write;
    mov EDX, OFFSET prompt12;
    call WriteString;//I dont use my proc here because I dont want a new line.
    ;//Begin Read//
    call ReadInt;//In my testing I discovered that MASM does have some error checking, and sets EAX to 0 if you try to enter something other than an int.
    clear;
    call WriteInt;
    clear;
    cmp AL, 1;
    JL P11;
    cmp AL, 50;
    JG P11;
    mov CL, AL;//Store N in CL;
    JMP P22;
;//Prompt 2:
P21:
    error;
P22:
    mov EDX, OFFSET prompt2;
    write;
    mov EDX, OFFSET prompt21;
    write;
    mov EDX, OFFSET prompt22;
    call WriteString;
    ;//Begin Read//
    call ReadInt;//In my testing I discovered that MASM does have some error checking, and sets EAX to 0 if you try to enter something too large.
    clear;
    call WriteInt;
    clear;
    cmp EAX, 0;
    JE P21;
    mov EBX, EAX;//Store J in EBX;
    JMP P32;
;//Prompt 3:
P31:
    error;
P32:
    mov EDX, OFFSET prompt23;
    call WriteString;
    ;//Begin Read//
    call ReadInt;//In my testing I discovered that MASM does have some error checking, and sets EAX to 0 if you try to enter something other than an int.
    clear;
    call WriteInt;
    clear;
    CMP EAX, 0;
    JE P31;
    cmp EAX, EBX;
    JLE P21;
ret;
UsrInput endp;
;//==================================================
;//==================================================
;//Takes EAX = K, EBX = J, CL = N;
ArrayFill proc;
    push ECX;//This is for later.
    mov ESI, 0;
L1:
    push ECX;
    push EAX;//Store Max Val

    sub EAX, EBX;//Lower the cap
    call RandomRange;
    add EAX, EBX;//Add to account for the minimum
    mov [storageArr + ESI], EAX;//Store in arr
    add ESI, 4;
    pop EAX;//Reset max value
    pop ECX;
    loop L1;
    pop ECX;
ret;
ArrayFill endp;
;//==================================================
;//==================================================
;//Reads out the array, ECX must be set;
ReadArr proc;
    push ECX;//Always need this
    mov EDX, OFFSET prompt4;
    write;
    mov EBX, 0;
L1:
    push ECX;

    colors;
    mov EAX, [storageArr + EBX];
    call WriteInt;
    add EBX, 4;
    clear;

    pop ECX;
    loop L1;
    pop ECX;
ret;
ReadArr endp;
;//==================================================
;//==================================================
;//Generic Error Message to save me some typing
ErrorMsg proc;
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
writeL proc;
    call WriteString;
    call CRLF;
ret;
writeL endp;
;//==================================================
;//==================================================
;//This procedure handles the random text coloration
RandomColor proc
	push eax;
	mov eax, 9;
	call RandomRange;
	cmp EAX, 3;
	JL W1;
	JE B1;
	JA G1;
W1:
	mov EAX,7;
	JMP D1;
B1:
	mov EAX,1;
	JMP D1;
G1:
	mov EAX,2;
D1:
	call SetTextColor;
	pop eax;
	ret;
RandomColor endp
;//==================================================
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
    mov EDX, OFFSET menuChoice3;
    write;
    call ReadInt;
    cmp EAX,1;
    JE OP1;
    cmp EAX,2;
    JE OP2;
    cmp EAX,3;
    JE OP4;
    JNE OP3;

OP1:
    call MainHandler;
    JMP ST1;
OP2:
    call ReadArr;
    JMP ST1;
OP3:
    mov EDX, OFFSET menuError;
    write;
    JMP ST1;
OP4:
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
    mov ESI, OFFSET storageArr;		;//Prep blank array
    call Menu;
    clear;
    mov EDX, OFFSET exitMsg;
    write;
    clear;
    call WaitMsg;
    exit
main ENDP							;//end of main procedure
END main							;//end of source code and hilarious comments(yes you know you laughed)