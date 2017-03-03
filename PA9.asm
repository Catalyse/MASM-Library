TITLE PA9.asm
;//**********************************************************
;//Program Description: PA8.asm
;//Author: Taylor May
;//Creation Date: 20151129
;//**********************************************************

INCLUDE Irvine32.inc

move textequ <mov> ;//I like dis. Dis mine now.
clear textequ <call CRLF>;
write textequ <call writeL>;
clearS textequ <call clearScreen>;

.data	;//thine data segment

.code   ;//thine code segment
;//---------------PROTO Section----------------------
Menu PROTO;//Nothing passed to main
WriteL PROTO;//Nothing passed to writel
str_cat_setup PROTO;
str_n_cat_setup PROTO;
str_str_setup PROTO;
userInput PROTO, strStore:DWORD;
len_comp PROTO, strL1:DWORD, strL2:DWORD;
str_cat PROTO, str11:DWORD, str12:DWORD, str11L:DWORD, str12L:DWORD;
str_n_cat PROTO, str21:DWORD, str22:DWORD, str21L:DWORD, str22L:DWORD;
str_str PROTO, str31:DWORD, str32:DWORD, str31L:DWORD, str32L:DWORD;
;//--------------------END---------------------------
;//==================================================
;//All Functions below will make use of the Str_length procedure which returns the length in EAX.
;//==================================================
;//Writes the string in EDX, adds a newline;
writeL proc;//called using write
    call WriteString;
    call CRLF;
ret;
writeL endp;
;//==================================================
;//==================================================
;//This function takes user input and fills an array provided
;//Receives an array to fill.
;//Stores values in said array as return val
userInput proc, strStore:DWORD;
.data;
    prompt1 BYTE "Please enter a string of less than 25 in length but greater than 0: ",0;
.code;
L1:
    mov EDX, strStore;
    mov ECX, 25;
    call ReadString;
    cmp EAX, 0;
    JE L1;
    ;//EAX contains the string length
ret;
userInput endp;
;//==================================================
;//==================================================
;//This function sets up the variables and takes user input for str_cat
;//No received or returned vals
str_cat_setup proc;
.data;
    promptCat11 BYTE "Please enter a target string, and a source string, the source is added to the target.",0;
    promptCat12 BYTE "Target String: ",0;
    promptCat13 BYTE "Source String: ",0;
    promptCat14 BYTE "String combination too large, cannot process.",0;
    promptCat15 BYTE "Combined String: ",0;
    defaultStr1 BYTE 25;
    string11 BYTE 25 DUP(?);
    string12 BYTE 25 DUP(?);
    str1Len1 DWORD 0;
    str2Len1 DWORD 0;
.code;
    mov EDX, OFFSET promptCat11;
    write;
    mov EDX, OFFSET promptCat12;
    write;
    INVOKE userInput, ADDR string11;
    mov EDX, OFFSET promptCat13;
    write;
    INVOKE userInput, ADDR string12;

    ;//Check string lengths
    INVOKE Str_length, ADDR string11;
    mov str1Len1, EAX;
    INVOKE Str_length, ADDR string12;
    mov str2Len1, EAX;

    INVOKE len_comp, str1Len1, str2Len1;
    cmp EAX, 0;
    JE E1;

    mov EAX, str1Len1;
    INVOKE str_cat,ADDR string11,ADDR string12, str1Len1, str2Len1;

    mov EDX, OFFSET promptCat15;
    write;
    mov EDX, OFFSET string11;
    write;
    JMP E2;//Jump over error
    JMP E2;//Skip error prompt
E1:;//Skip because string cannot be appended.
    mov EDX, OFFSET promptCat14;
    write;
E2:;
ret;
str_cat_setup endp;
;//==================================================
;//==================================================
;//This function sets up the variables and takes user input for str_n_cat
;//No received or returned vals
str_n_cat_setup proc;
.data;
    promptCat21 BYTE "Please enter a target string, and a source string, the source is added to the target.",0;
    promptCat22 BYTE "Target String: ",0;
    promptCat23 BYTE "Source String: ",0;
    promptCat24 BYTE "Please enter an n number of characters to add from the source string to the target.",0;
    promptCat25 BYTE "String combination too large, cannot process.",0;
    promptCat26 BYTE "Combined String: ",0;
    defaultStr2 BYTE 25;
    string21 BYTE 25 DUP(?);
    string22 BYTE 25 DUP(?);
    str1Len2 DWORD 0;
    str2Len2 DWORD 0;
    nVal DWORD 0;
.code;
    mov EDX, OFFSET promptCat21;
    write;
    mov EDX, OFFSET promptCat22;
    write;
    INVOKE userInput, ADDR string21;
    mov EDX, OFFSET promptCat23;
    write;
    INVOKE userInput, ADDR string22;
    mov EDX, OFFSET promptCat24;
    write;
    call ReadInt;
    mov nVal, EAX;//Store the N value into memory

    ;//Check string lengths
    INVOKE Str_length, ADDR string21;
    mov str1Len2, EAX;
    INVOKE Str_length, ADDR string22;
    mov str2Len2, EAX;

    INVOKE len_comp, str1Len2, nVal;//Since we are only putting in N chars we can just test N versus the extra string
    cmp EAX, 0;
    JE E1;

    mov EAX, str1Len2;
    INVOKE str_n_cat,ADDR string21,ADDR string22, str1Len2, nVal;

    mov EDX, OFFSET promptCat26;
    write;
    mov EDX, OFFSET string21;
    write;
    JMP E2;//Jump over error
E1:
    mov EDX, OFFSET promptCat25;
    write;
E2:
ret;
str_n_cat_setup endp;
;//==================================================
;//==================================================
;//This function sets up the variables and takes user input for str_str
;//No received or returned vals
str_str_setup proc;
.data;
    promptCat31 BYTE "Please enter a target string, and a substring to find in the target.",0;
    promptCat32 BYTE "Target String: ",0;
    promptCat33 BYTE "Source SubString: ",0;
    promptCat34 BYTE "Substring too long!",0;
    defaultStr3 BYTE 25;
    string31 BYTE 25 DUP(?);
    string32 BYTE 25 DUP(?);
    str1Len3 DWORD 0;
    str2Len3 DWORD 0;
.code;
    mov EDX, OFFSET promptCat31;
    write;
    mov EDX, OFFSET promptCat32;
    write;
    INVOKE userInput, ADDR string31;
    mov EDX, OFFSET promptCat33;
    write;
    INVOKE userInput, ADDR string32;

    ;//Check string lengths
    INVOKE Str_length, ADDR string31;
    mov str1Len3, EAX;
    INVOKE Str_length, ADDR string32;
    mov str2Len3, EAX;

    mov EAX, str1Len3;
    cmp EAX, str2Len3;
    JL E1;//Substring too large

    INVOKE str_str,ADDR string31,ADDR string32, str1Len3, str2Len3;
    JMP E2;
E1:
    mov EDX, OFFSET promptCat34;
    write;
E2:
ret;
str_str_setup endp;
;//==================================================
;//==================================================
;//This function appends to strings together
;//Receives both string and both string lengths
;//Returns the combined string in str11 address
str_cat proc, str11:DWORD, str12:DWORD,str11L:DWORD, str12L:DWORD;
    mov ESI, str11;
    add ESI, str11L;
    mov EDX, str12;

    mov ECX, str12L;
L1:
    mov AL, [EDX];
    mov [ESI], AL;
    add ESI, 1;
    add EDX, 1;
    loop L1;

ret;
str_cat endp;
;//==================================================
;//==================================================
;//This function combines two strings, taking only N chars of the source string to append to the target
;//Receives both string and both string lengths
;//Returns the combined string in str11 address
str_n_cat proc, str21:DWORD, str22:DWORD,str21L:DWORD, str22L:DWORD;
    mov ESI, str21;
    add ESI, str21L;
    mov EDX, str22;

    mov ECX, str22L;
L1:
    mov AL, [EDX];
    mov [ESI], AL;
    add ESI, 1;
    add EDX, 1;
    loop L1;

ret;
str_n_cat endp;
;//==================================================
;//==================================================
;//This function find a substring within a string with internal recursion.
;//Receives both string and both string lengths
://Returns the substring found location in EAX, and the zero flag set, or the zero flag cleared and nothing in eax
str_str proc, str31:DWORD, str32:DWORD, str31L:DWORD, str32L:DWORD;
.data;
    strCount3 DWORD 0;
    subCount3 DWORD 0;
    promptCat35 BYTE "Substring found!",0;
    promptCat36 BYTE "Substring not found!",0;
.code;
    mov EAX, 0;
    mov EBX, 0;
    mov ESI, str31;
    mov EDX, str32;
    mov strCount3, 0;

    mov ECX, str31L;//Loop through target string
L1:
    mov AL, [ESI]
    mov BL, [EDX];
    cmp EAX, EBX;//We only want to compare the first value of the substring, then jump to the checker loop
    JE C1;
    add strCount3, 1;
    mov ESI, str31;//Iterate in a way that lets me keep track of where im at in the string
    add ESI, strCount3;
    loop L1;
    ;//If it completes the loop, sub not found
    OR AL, 1;//Clear zero flag
    mov EDX, OFFSET promptCat36;
    write;
    JMP E1;

C1:;//Checker loop
    mov EBX, str32L;
    cmp subCount3, EBX;
    JE M1;//substring count exceeded string found
    mov EBX, 0;
    mov EAX, 0;
    mov AL, [ESI]
    mov BL, [EDX];
    cmp EAX, EBX;
    JNE R1;//Doesnt match move back to main loop.
    add ESI, 1;
    add EDX, 1;
    add subCount3, 1;
    JMP C1;//Repeat till we find mismatch or end of string and match

R1:;//Reset to main loop.
    mov ESI, str31;
    add strCount3,1;
    sub ECX, 1;
    add ESI, strCount3;
    mov subCount3, 0;
    mov EDX, str32;
    JMP L1;

M1:;//Match found
    mov ESI, str31;
    add ESI, strCount3;
    mov EAX, ESI;//Move first occurance of substring to EAX
    TEST AL, 0;//Set zero flag.
    mov EDX, OFFSET promptCat35;
    write;
E1:;//end
ret;
str_str endp;
;//==================================================
;//==================================================
;//This function compares the sizes of two strings and determines when combined whether they would exceed the max string length
;//Takes two string sizes
;//Returns 1 or 0 in EAX
len_comp proc, strL1:DWORD, strL2:DWORD;
.data;
    total BYTE 0;
.code;
    mov EAX, strL1;
    mov EBX, strL2;
    add EAX, EBX;
    cmp EAX, 25;
    JLE G1;

    mov EAX, 0;//Strings cannot be combined.
    JMP E1;
G1:
    mov EAX, 1;//Strings can be combined
E1:
ret;
len_comp endp;
;//==================================================
;//==================================================
;//This function clears the screen by resetting the cursor position and writing whitespace over the entire screen, then resets the cursor to 0
clearScreen proc;
    mov EDX, 0;
    mov EAX, ' ';
    call Gotoxy;

    mov ECX, 25;
L1:
    push ECX;
    mov ECX, 79;
    L2:
	   call WriteChar;
	   loop L2;
    pop ECX;
    loop L1;
    mov EDX, 0;
    call Gotoxy;
ret;
clearScreen endp;
;//==================================================
;//==================================================
;//This is the main menu.
Menu proc;
.data
    menu1 BYTE "Welcome to the String Program!", 0;
    menu2 BYTE "Option 1: Add a string to a target string.", 0;
    menu3 BYTE "Option 2: Add N characters of a string to a target string.", 0;
    menu4 BYTE "Option 3: Find a substring in a target string.",0;
    menu5 BYTE "Option 4: Exit.",0;
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
    mov EDX, OFFSET menu5;
    write;
    call ReadInt;
    cmp EAX,1;
    JE OP1;
    cmp EAX,2;
    JE OP2;
    cmp EAX,3;
    JE OP3;
    cmp EAX,4;
    JE OP4;
    JNE OP5;

OP1:;//Add a string to a target string
    invoke str_cat_setup;
    call WaitMsg;
    clearS;
    JMP ST1;
OP2:;//Add N characters of a string to a target string.
    invoke str_n_cat_setup;
    call WaitMsg;
    clearS;
    JMP ST1;
OP3:;//Find a substring in a target string.
    invoke str_str_setup;
    call WaitMsg;
    clearS;
    JMP ST1;
OP5:
    mov EDX, OFFSET menuError;
    write;
    call WaitMsg;
    clearS;
    JMP ST1;
OP4:
    clearS;
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
    mov EDX, OFFSET exitMsg;
    write;
    clear;
    call WaitMsg;
    exit
main ENDP							;//end of main procedure
END main							;//end of source code and hilarious comments(yes you know you laughed)