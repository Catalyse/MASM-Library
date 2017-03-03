TITLE final.asm
;//**********************************************************
;//Program Description: final.asm
;//Author: Taylor May
;//Creation Date: 20151206
;//**********************************************************

INCLUDE Irvine32.inc

line textequ <call CRLF>;
write textequ <call writeL>;
clear textequ <call Clrscr>;

.data	;//thine data segment

.code   ;//thine code segment
;//---------------PROTO Section----------------------
Menu PROTO;//Nothing passed to main
WriteL PROTO;//Nothing passed to writel
UserInput PROTO, gArr3:DWORD, uChar:BYTE;
GameWait PROTO, mulVal:DWORD;//Nothing is passed.
DrawGame PROTO, gArr1:DWORD;//pass game array to draw
UserPlay PROTO;//Nothing is passed
CompPlay PROTO;//Nothing is passed
CompMove PROTO, gArr2:DWORD, cChar:BYTE;
WinValidation PROTO, gArr4:DWORD;
WinDraw PROTO, winRow:BYTE, winSym:BYTE;
CheckMoveType PROTO, move:BYTE;
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
;//This method accepts the users input, checks if the input is valid, and if so puts it into the game array.
;//This method accepts the game array, and the symbol for the user.
;//This method modifies the game array with a move once complete.
UserInput proc, gArr3:DWORD, uChar:BYTE;
.data;
    statement1 BYTE "Please enter your move:",0;
    invalid1 BYTE "Invalid Entry.",0;
    invalid2 BYTE "Spot Already Filled!",0;
.code;
L1:
    mov ESI, gArr3;
    mov EDX, OFFSET statement1;
    write;
    call ReadInt;
    cmp EAX,1;
    JL L2;//Too low
    cmp EAX,9;
    JG L2;//Too high

    sub EAX, 1;//Put it in range for index.

    add ESI, EAX;
    mov BL, [ESI];
    cmp BL, 5;
    JNE P1;//Is filled, repick
    mov AL, uChar;
    mov [ESI], AL;
    JMP E1;
L2:;//Invalid Choice -- Wait for a second after invalid statement then redraw the screen
    mov EDX, OFFSET invalid1;
    write;
    INVOKE GameWait, 1000;
    INVOKE DrawGame, gArr3;
    JMP L1;
P1:;//Already filled -- Wait for a second after invalid statement then redraw the screen
    mov EDX, OFFSET invalid2;
    write;
    INVOKE GameWait, 1000;
    INVOKE DrawGame, gArr3;
    JMP L1;
E1:

ret;
UserInput endp;
;//==================================================
;//==================================================
;//Takes value in the form of a DWORD int, checks if its an x, o, or unset and returns a char in EAX.
CheckMoveType proc, move:BYTE;
    cmp move, 0;
    JE X1;
    cmp move, 1;
    JE O1;
    JMP D1;
X1:;//Set EAX to X
    mov EAX, 'X';
    JMP E1;
O1:
    mov EAX, 'O';
    JMP E1;
D1:
    mov EAX, '-';
E1:
ret;
CheckMoveType endp;
;//==================================================
;//==================================================
UserPlay proc;
.data;
    startStat1 BYTE "Welcome to the User Versus Computer mode, a player will be chosen randomly to start...",0;
    userStart BYTE "The user has been chosen randomly to start!",0;
    compStart BYTE "The computer has been chosen randomly to start!",0;
    userWin BYTE "You win!",0;
    compWin BYTE "The computer wins!",0;
    compMov BYTE "The computer has moved!",0;
    gameArr1 BYTE 9 DUP(5);
    userChar BYTE 0;
    cpuChar BYTE 0;
    moveCount1 BYTE 0;
.code;
    mov EDX, OFFSET startStat1;
    write;

    mov EAX, 10;
    call RandomRange;
    cmp EAX, 5;//Player is 1-5, CPU is 6-10
    JG P2;
P1:;//Player 1 Start(user)
    ;//Since the player has the first move in the game loop we dont need to do anything
    mov EDX, OFFSET userStart;
    write;
    INVOKE GameWait, 3000;
    mov userChar, 0;
    mov cpuChar, 1;
    INVOKE DrawGame, ADDR gameArr1;
    JMP S1;
P2:;//Player 2 Start
    mov EDX, OFFSET compStart;
    write;
    INVOKE GameWait, 3000;
    mov userChar, 1;
    mov cpuChar, 0;
    INVOKE CompMove, ADDR gameArr1, cpuChar;
    INVOKE DrawGame, ADDR gameArr1;
    INVOKE GameWait, 1000;
    add moveCount1, 1;

    ;//================================Main Loop====================================
S1:;//Start Game
    INVOKE UserInput, ADDR gameArr1, userChar;
    add moveCount1, 1;
    INVOKE DrawGame, ADDR gameArr1;
    INVOKE WinValidation, ADDR gameArr1;
    cmp EAX, 5;
    JNE W1;
    cmp moveCount1, 9;//Game move limit hit, no winner
    JGE CG1;
    INVOKE GameWait, 1000;//This is so the GUI doesnt instantly redraw after the user plays
    INVOKE CompMove, ADDR gameArr1, cpuChar;
    add moveCount1, 1;
    INVOKE DrawGame, ADDR gameArr1;
    mov EDX, OFFSET compMov;
    write;
    INVOKE WinValidation, ADDR gameArr1;
    cmp EAX, 5;
    JNE W1;
    cmp moveCount1, 9;
    JGE CG1;
    JMP S1;
    ;//==================================END=======================================
    
W1:;//Win handler
    cmp AL, userChar;//If the value is equal to the players char then the player wins.
    JNE CW1;
PW1:;//Player wins
    mov EDX, OFFSET userWin;
    write;
    INVOKE WinDraw, BL, userChar;
    JMP E1;
CW1:;//Cpu win
    mov EDX, OFFSET compWin;
    write;
    INVOKE WinDraw, BL, cpuChar;
    JMP E1;
CG1:;//No winner
    mov EDX, OFFSET noWin2;
    write;
E1:
    call WaitMsg;
    mov ECX, 9;//loop
    mov ESI, OFFSET gameArr1;
    mov AL, 5;
    RL1:;//Array Reset loop
    mov [ESI], AL;
    add ESI, 1;
    loop RL1;
    mov moveCount1, 0;
    clear;
ret;
UserPlay endp;
;//==================================================
;//==================================================
CompPlay proc;
.data;
    startStat2 BYTE "Welcome to the User Versus Computer mode, a player will be chosen randomly to start...",0;
    cpu1Start BYTE "User Computer One has been chosen randomly to start!",0;
    cpu2Start BYTE "User Computer Two has been chosen randomly to start!",0;
    cpu1Move BYTE "Computer 1 Moved.",0;
    cpu2Move BYTE "Computer 2 Moved.",0;
    cpu1Win BYTE "Computer 1 Wins!",0;
    cpu2Win BYTE "Computer 2 Wins!",0;
    noWin2 BYTE "No winner this game!",0;
    gameArr2 BYTE 9 DUP(5);
    cpuChar1 BYTE 0;
    cpuChar2 BYTE 0;
    moveCount2 BYTE 0;
.code;
    mov EDX, OFFSET startStat2;
    write;

    mov EAX, 9;
    call RandomRange;
    cmp EAX, 4;//Player is 0-4, CPU is 5-9
    JG P2;
P1:;//Player 1 Start(cpu1)
    ;//Since the player has the first move in the game loop we dont need to do anything
    mov EDX, OFFSET cpu1Start;
    write;
    INVOKE GameWait, 3000;
    mov cpuChar1, 0;
    mov cpuChar2, 1;
    JMP C1;
P2:;//Player 2 Start(cpu2)
    mov EDX, OFFSET cpu2Start;
    write;
    INVOKE GameWait, 3000;
    mov cpuChar1, 1;
    mov cpuChar2, 0;
    JMP C2;
    ;//=======================Main Loop========================
S1:;//Start Game
    JMP C1;
    SR1:;//Return after move
    INVOKE WinValidation, ADDR gameArr2;
    cmp EAX, 5;
    JNE W1;
    INVOKE GameWait,2000;//Wait after move
S2: JMP C2;
    SR2:;//Return after move
    INVOKE WinValidation, ADDR gameArr2;
    cmp EAX, 5;
    JNE W1;
    INVOKE GameWait,2000;//Wait after move
    cmp moveCount2, 9;
    JGE CG1;
    JMP S1;
    ;//========================END=============================
C1:
    INVOKE CompMove, ADDR gameArr2, cpuChar1;
    INVOKE DrawGame, ADDR gameArr2;
    mov EDX, OFFSET cpu1Move;
    write;
    add moveCount2, 1;
    JMP SR1;
C2:
    INVOKE CompMove, ADDR gameArr2, cpuChar2;
    INVOKE DrawGame, ADDR gameArr2;
    mov EDX, OFFSET cpu2Move;
    write;
    add moveCount2, 1;
    JMP SR2;

W1:;//Win handler
    cmp AL, cpuChar1;//If the value is equal to the players char then the player wins.
    JNE CW1;
PW1:;//comp 1 wins
    mov EDX, OFFSET cpu1Win;
    write;
    INVOKE WinDraw, BL, cpuChar1;
    JMP E1;
CW1:;//Cpu 2 win
    mov EDX, OFFSET cpu2Win;
    write;
    INVOKE WinDraw, BL, cpuChar2;
    JMP E1;
CG1:;//No winner
    mov EDX, OFFSET noWin2;
    write;
E1:
    call WaitMsg;
    mov ECX, 9;//loop
    mov ESI, OFFSET gameArr2;
    mov AL, 5;
    RL1:;//Array Reset loop
    mov [ESI], AL;
    add ESI, 1;
    loop RL1;
    mov moveCount2, 0;
    clear;
ret;
CompPlay endp;
;//==================================================
;//==================================================
CompMove proc, gArr2:DWORD, cChar:BYTE;
L1:;//Restart if val is already chosen.
    mov ESI, gArr2;
    mov EBX, 0;
    mov EAX, 8;
    add EAX, 1;//Dont want 0;
    call RandomRange;

    add ESI, EAX;//Add the index
    mov EAX, 0;
    mov AL, [ESI];
    cmp EAX, 5;
    JNE L1;//Is filled, repick
    mov AL, cChar;
    mov [ESI], AL;
ret;
CompMove endp;
;//==================================================
;//==================================================
;//This method will accept the game array and check each potential row for a victory.
;//Each element in the game array starts at 5, with X's being a 0 in the array, and O's being a 1 in the array
;//This means that if the value of the array exceeds 3, no one has one.
;//If the row value is 0, X's win, if the row value is 3 O's win.
;//Any other value does not add up to a win
;//Returns the winner in EAX and calls the winhighlight.
;This legend shows all 8 ways to win that will be checked.
;		  Columns				   Rows				 Diagonals
;		 C1  C2  C3							   D1		 D2
;     ==== 1 | 2 | 3 ====  ||  =R1= 1 | 1 | 1 ====  ||  ==== 1 | - | 2 ====
;     ==== 1 | 2 | 3 ====  ||  =R2= 2 | 2 | 2 ====  ||  ==== - | * | - ====
;     ==== 1 | 2 | 3 ====  ||  =R3= 3 | 3 | 3 ====  ||  ==== 2 | - | 1 ====
;											   D2		 D1
WinValidation proc, gArr4:DWORD;
.data;
    xWin BYTE 0;
    oWin BYTE 3;
.code;
    mov EAX, 0;
C1:
    mov ESI, gArr4;
    mov AL, [ESI];//first index 1
    add ESI, 3;
    add AL, [ESI];//second index 4
    add ESI, 3;
    add AL, [ESI];//third index 7
    cmp AL, 0;//X wins
    JNE C11;
    mov EAX, 0;//Mov the winning char to eax and return
    mov EBX, 1;//Winning row to return
    JMP E1;
    C11:
    cmp AL, 3;//O wins
    JNE C2;
    mov EAX, 1;
    mov EBX, 1;//Winning row to return
    JMP E1;
C2:
    mov ESI, gArr4;
    add ESI, 1;
    mov AL, [ESI];//first index 2
    add ESI, 3;
    mov BL, [ESI]
    add AL, BL;//second index 5
    add ESI, 3;
    mov BL, [ESI]
    add AL, BL;;//third index 8
    cmp AL, 0;//X wins
    JNE C21;
    mov EAX, 0;//Mov the winning char to eax and return
    mov EBX, 2;//Winning row to return
    JMP E1;
    C21:
    cmp AL, 3;//O wins
    JNE C3;
    mov EAX, 1;
    mov EBX, 2;//Winning row to return
    JMP E1;
C3:
    mov ESI, gArr4;
    add ESI, 2;
    mov AL, [ESI];//first index 3
    add ESI, 3;
    mov BL, [ESI]
    add AL, BL;//second index 6
    add ESI, 3;
    mov BL, [ESI]
    add AL, BL;;//third index 9
    cmp AL, 0;//X wins
    JNE C31;
    mov EAX, 0;//Mov the winning char to eax and return
    mov EBX, 3;//Winning row to return
    JMP E1;
    C31:
    cmp AL, 3;//O wins
    JNE R1;
    mov EAX, 1;
    mov EBX, 3;//Winning row to return
    JMP E1;
R1:
    mov ESI, gArr4;
    mov AL, [ESI];//first index 1
    add ESI, 1;
    mov BL, [ESI]
    add AL, BL;//second index 2
    add ESI, 1;
    mov BL, [ESI]
    add AL, BL;//third index 3
    cmp AL, 0;//X wins
    JNE R11;
    mov EAX, 0;//Mov the winning char to eax and return
    mov EBX, 4;//Winning row to return
    JMP E1;
    R11:
    cmp AL, 3;//O wins
    JNE R2;
    mov EAX, 1;
    mov EBX, 4;//Winning row to return
    JMP E1;
R2:
    mov ESI, gArr4;
    add ESI, 3;
    mov AL, [ESI];//first index 4
    add ESI, 1;
    mov BL, [ESI]
    add AL, BL;//second index 5
    add ESI, 1;
    mov BL, [ESI]
    add AL, BL;//third index 6
    cmp AL, 0;//X wins
    JNE R21;
    mov EAX, 0;//Mov the winning char to eax and return
    mov EBX, 5;//Winning row to return
    JMP E1;
    R21:
    cmp EAX, 3;//O wins
    JNE R3;
    mov EAX, 1;
    mov EBX, 5;//Winning row to return
    JMP E1;
R3:
    mov ESI, gArr4;
    add ESI, 6
    mov AL, [ESI];//first index 7
    add ESI, 1;
    mov BL, [ESI]
    add AL, BL;//second index 8
    add ESI, 1;
    mov BL, [ESI]
    add AL, BL;//third index 9
    cmp AL, 0;//X wins
    JNE R31;
    mov EAX, 0;//Mov the winning char to eax and return
    mov EBX, 6;//Winning row to return
    JMP E1;
    R31:
    cmp AL, 3;//O wins
    JNE D1;
    mov EAX, 1;
    mov EBX, 6;//Winning row to return
    JMP E1;
D1:
    mov ESI, gArr4;
    mov AL, [ESI];//first index 1
    add ESI, 4;
    mov BL, [ESI]
    add AL, BL;//second index 5
    add ESI, 4;
    mov BL, [ESI]
    add AL, BL;//third index 9
    cmp AL, 0;//X wins
    JNE D11;
    mov EAX, 0;//Mov the winning char to eax and return
    mov EBX, 7;//Winning row to return
    JMP E1;
    D11:
    cmp AL, 3;//O wins
    JNE D2;
    mov EAX, 1;
    mov EBX, 7;//Winning row to return
    JMP E1;
D2:
    mov ESI, gArr4;
    add ESI, 2;
    mov AL, [ESI];//first index 3
    add ESI, 2;
    mov BL, [ESI]
    add AL, BL;//second index 5
    add ESI, 2;
    mov BL, [ESI]
    add AL, BL;//third index 7
    cmp AL, 0;//X wins
    JNE D21;
    mov EAX, 0;//Mov the winning char to eax and return
    mov EBX, 8;
    JMP E1;
    D21:
    cmp AL, 3;//O wins
    JNE NW;
    mov EAX, 1;
    mov EBX, 8;
    JMP E1;
NW:;//No win
    mov EAX, 5;//No winning sym
    mov EBX, 0;//No winning row
E1:
ret;
WinValidation endp;
;//==================================================
;//Takes no input, delays program by 1 second.
GameWait proc, mulVal:DWORD;
    mov EAX, mulVal;
    call Delay;
ret;
GameWait endp;
;//==================================================
;//==================================================
DrawGame proc, gArr1:DWORD;
.data;//     0    -   -10 -      20       -30 -   -  40
;//Cursorpos-01234567890123456789012345678901234567890123
    a1 BYTE "Current Game Board   ||      Move Legend",0;
    a2 BYTE "==== - | - | - ====  ||  ==== 1 | 2 | 3 ====",0;
    a3 BYTE "==== - | - | - ====  ||  ==== 4 | 5 | 6 ====",0;
    a4 BYTE "==== - | - | - ====  ||  ==== 7 | 8 | 9 ====",0;
    a5 BYTE "===================  ||  ===================",0;
    aS BYTE "====   |   |   ====  ||  ====   |   |   ====",0;
    ;//Array vals 1   2   3   4   5   6   7   8   9 
    ;//DH(row)	   2   2   2   4   4   4   6   6   6
    ;//DL(column) 5   9   13  5   9   13  5   9   13
.code;
    clear;//Make sure screen is clear before writing
    mov EDX, OFFSET a1;
    write;
    mov EDX, OFFSET aS;
    write;
    mov EDX, OFFSET a2;
    write;
    mov EDX, OFFSET aS;
    write;
    mov EDX, OFFSET a3;
    write;
    mov EDX, OFFSET aS;
    write;
    mov EDX, OFFSET a4;
    write;
    mov EDX, OFFSET aS;
    write;
    mov EDX, OFFSET a5;
    write;
    ;//Now overwrite the - marks.
    mov EAX, 0;
    mov EDX, 0;
    mov ESI, gArr1;

S1:;//Spot 1
    mov AL, [ESI];
    invoke CheckMoveType, AL;
    mov DH, 2;
    mov DL, 5;
    call Gotoxy;
    call WriteChar;
    add ESI, 1;
S2:;//Spot 2
    mov AL, [ESI];
    invoke CheckMoveType, AL;
    mov DH, 2;
    mov DL, 9;
    call Gotoxy;
    call WriteChar;
    add ESI, 1;
S3:;//Spot 3
    mov AL, [ESI];
    invoke CheckMoveType, AL;
    mov DH, 2;
    mov DL, 13;
    call Gotoxy;
    call WriteChar;
    add ESI, 1;
S4:;//Spot 4
    mov AL, [ESI];
    invoke CheckMoveType, AL;
    mov DH, 4;
    mov DL, 5;
    call Gotoxy;
    call WriteChar;
    add ESI, 1;
S5:;//Spot 5
    mov AL, [ESI];
    invoke CheckMoveType, AL;
    mov DH, 4;
    mov DL, 9;
    call Gotoxy;
    call WriteChar;
    add ESI, 1;
S6:;//Spot 6
    mov AL, [ESI];
    invoke CheckMoveType, AL;
    mov DH, 4;
    mov DL, 13;
    call Gotoxy;
    call WriteChar;
    add ESI, 1;
S7:;//Spot 7
    mov AL, [ESI];
    invoke CheckMoveType, AL;
    mov DH, 6;
    mov DL, 5;
    call Gotoxy;
    call WriteChar;
    add ESI, 1;
S8:;//Spot 8
    mov AL, [ESI];
    invoke CheckMoveType, AL;
    mov DH, 6;
    mov DL, 9;
    call Gotoxy;
    call WriteChar;
    add ESI, 1;
S9:;//Spot 9
    mov AL, [ESI];
    invoke CheckMoveType, AL;
    mov DH, 6;
    mov DL, 13;
    call Gotoxy;
    call WriteChar;
E1:
    mov DH, 9;
    mov DL, 0;
    call Gotoxy;
ret;
DrawGame endp;
;//==================================================
;//==================================================
;This method is called from within the drawgame proc, and does not need to redraw the game again, but change the win area.
;This legend shows all 8 ways to win that will be checked.
;		  Columns				   Rows				 Diagonals
;		 C1  C2  C3							   D1		 D2
;     ==== 1 | 2 | 3 ====  ||  =R1= 1 | 1 | 1 ====  ||  ==== 1 | - | 2 ====
;     ==== 1 | 2 | 3 ====  ||  =R2= 2 | 2 | 2 ====  ||  ==== - | * | - ====
;     ==== 1 | 2 | 3 ====  ||  =R3= 3 | 3 | 3 ====  ||  ==== 2 | - | 1 ====
;											   D2		 D1
;//Win table for winRow: C1=1, C2=2, C3=3, R1=4, R2=5, R3=6, D1=7, D2=8
WinDraw proc, winRow:BYTE, winSym:BYTE;
    mov EAX, black + (white * 16);
    call SetTextColor;

    cmp winSym, 0;
    JNE O1;//Else X wins
    mov EAX, 'X';
    JMP S1;
O1:;//If O's win
    mov EAX, 'O';
S1:;//Start win row check
    mov EDX, 0;
    cmp winRow, 1;
    JE C1;
    cmp winRow, 2;
    JE C2;
    cmp winRow, 3;
    JE C3;
    cmp winRow, 4;
    JE R1;
    cmp winRow, 5;
    JE R2;
    cmp winRow, 6;
    JE R3;
    cmp winRow, 7;
    JE D1;
    cmp winRow, 8;
    JE D2;
    JNE E1;//This should never happen

C1:;//Column 5, row 2, 4, 6
    mov DH, 2;//Row
    mov DL, 5;//Column
    call Gotoxy;
    call WriteChar;
    mov DH, 4;
    mov DL, 5;
    call Gotoxy;
    call WriteChar;
    mov DH, 6;
    mov DL, 5;
    call Gotoxy;
    call WriteChar;
    JMP E1;
C2:;//Column 7, row 2, 4, 6
    mov DH, 2;//Row
    mov DL, 9;//Column
    call Gotoxy;
    call WriteChar;
    mov DH, 4;
    mov DL, 9;
    call Gotoxy;
    call WriteChar;
    mov DH, 6;
    mov DL, 9;
    call Gotoxy;
    call WriteChar;
    JMP E1;
C3:;//Column 9, row 2, 4, 6
    mov DH, 2;//Row
    mov DL, 13;//Column
    call Gotoxy;
    call WriteChar;
    mov DH, 4;
    mov DL, 13;
    call Gotoxy;
    call WriteChar;
    mov DH, 6;
    mov DL, 13;
    call Gotoxy;
    call WriteChar;
    JMP E1;
R1:;//Column 5, 7, 9, row 2.
    mov DH, 2;//Row
    mov DL, 5;//Column
    call Gotoxy;
    call WriteChar;
    mov DH, 2;
    mov DL, 9;
    call Gotoxy;
    call WriteChar;
    mov DH, 2;
    mov DL, 13;
    call Gotoxy;
    call WriteChar;
    JMP E1;
R2:;//Column 5, 7, 9, row 4.
    mov DH, 4;//Row
    mov DL, 5;//Column
    call Gotoxy;
    call WriteChar;
    mov DH, 4;
    mov DL, 9;
    call Gotoxy;
    call WriteChar;
    mov DH, 4;
    mov DL, 13;
    call Gotoxy;
    call WriteChar;
    JMP E1;
R3:;//Column 5, 7, 9, row 6.
    mov DH, 6;//Row
    mov DL, 5;//Column
    call Gotoxy;
    call WriteChar;
    mov DH, 6;
    mov DL, 9;
    call Gotoxy;
    call WriteChar;
    mov DH, 6;
    mov DL, 13;
    call Gotoxy;
    call WriteChar;
    JMP E1;
D1:;//(5,2)(7,4)(9,6)
    mov DH, 2;//Row
    mov DL, 5;//Column
    call Gotoxy;
    call WriteChar;
    mov DH, 4;
    mov DL, 9;
    call Gotoxy;
    call WriteChar;
    mov DH, 6;
    mov DL, 13;
    call Gotoxy;
    call WriteChar;
    JMP E1;
D2:;//(9,2)(7,4)(5,6)
    mov DH, 2;//Row
    mov DL, 13;//Column
    call Gotoxy;
    call WriteChar;
    mov DH, 4;
    mov DL, 9;
    call Gotoxy;
    call WriteChar;
    mov DH, 6;
    mov DL, 5;
    call Gotoxy;
    call WriteChar;
    JMP E1;
E1:
    mov EAX, 0Ah;
    call SetTextColor;//Reset to the right color 11
    mov DL, 0;
    mov DH, 11;
    call Gotoxy;
ret;
WinDraw endp;
;//==================================================
;//==================================================
;//This is the main menu.
Menu proc;
.data
    menu1 BYTE "Welcome to the Tic-Tac-Toe Game!", 0;
    menu2 BYTE "Option 1: Play against the computer.", 0;
    menu3 BYTE "Option 2: Watch computers play eachother.", 0;
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

OP1:;//User V AI
    invoke UserPlay;
    JMP ST1;
OP2:;//AI Ran Game
    invoke CompPlay;
    JMP ST1;
OP4:
    mov EDX, OFFSET menuError;
    write;
    invoke GameWait, 2000;
    clear;
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
    line;
    mov EDX, OFFSET exitMsg;
    write;
    line;
    call WaitMsg;
    exit
main ENDP							;//end of main procedure
END main							;//end of source code and hilarious comments(yes you know you laughed)