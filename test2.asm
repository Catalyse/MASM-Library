TITLE TEST2.asm
;//**********************************************************
;//Program Description: TEST2.asm
;//Author: Taylor May
;//Creation Date: 20151108
;//**********************************************************

INCLUDE Irvine32.inc

move textequ <mov> ;//I like dis. Dis mine now.
clear textequ <call CRLF>;
write textequ <call writeL>;
numSep textequ <call sieveSep>;

.data	;//thine data segment (But this shit all global so I cant use it.)

.code   ;//thine code segment
;//==================================================
main PROC;//start the main procedure
;//**********************************************************
;//Description: 
;//Receives: 
;//Returns: 
;//**********************************************************
.data
    exitMsg BYTE "The program has terminated.",0;
.code
    call Randomize					;//A must at the beginning of any program that does random crap.
    mov EAX, 0Ah					;//Matrix text is index 10.
    call SetTextColor				;//Matrix text.
    ;//Begin Program.
    call Menu;
    clear;
    mov EDX, OFFSET exitMsg;
    write;
    clear;
    call WaitMsg;
    exit
main ENDP	;//end of main procedure
;//==================================================
;//==================================================

;//Menus section ****************************************************************************************

;//==================================================
;//This is the main menu.
Menu proc;
;//**********************************************************
;//Description: This is the main menu/GUI for the program
;//Receives: Nothing
;//Returns: Nothing
;//**********************************************************
.data
menuChoice1 BYTE "1) Run the Sieve of Eratosthenes.",0;
menuChoice2 BYTE "2) Calculate the Divisors and Prime Divisors of a Number.",0;
menuChoice3 BYTE "3) Quit.",0;
menuError BYTE "Please try reading the menu better and try again!",0;
;//End.data//
.code
S1:
    mov EDX, OFFSET menuChoice1;
    write;
    mov EDX, OFFSET menuChoice2;
    write;
    mov EDX, OFFSET menuChoice3;
    write;
    call ReadInt;
    cmp EAX,1;
    JE OP1;//Sieve
    cmp EAX,2;
    JE OP2;//Calculate primes
    cmp EAX,3;
    JE OP4;//Quit
    JNE OP3;//Error

OP1:;//Sieve -- This area will make all the calls.
    call Sieve;
    JMP S1;//Redeclare the menu.
OP2:;//Calculate primes
    call userInput;
    JMP S1;
OP3:;//Menu Error Text and menu reset
    mov EDX, OFFSET menuError;
    write;
    clear;
    JMP S1;
OP4:;//Exit
ret;
Menu endp;
;//==================================================

;//Divisors section ************************************************************************************

;//==================================================
userInput proc;
;//**********************************************************
;//Description: Taked the users input for the divisor section and passes the data to the appropriate method
;//Receives: Nothing
;//Returns: Nothing
;//**********************************************************
.data
    menu1 BYTE "Please enter the number you want to find the divisors for between 2 and 100: ",0;
    menuError1 BYTE "Error: Out of Range, try again!",0;
.code
S1:;
    mov EDX, OFFSET menu1;
    write;

    call ReadInt;
    cmp EAX,2;
    JL OP2;//Out of range
    cmp EAX,100;
    JG OP2;//Out of range
    JMP OP1;

OP1:;//Number falls into range.
    call DivisorCalc;
    JMP E1;
OP2:;//Menu Error Text and menu reset
    mov EDX, OFFSET menuError1;
    write;
    JMP S1;
E1:;//End
ret;
userInput endp;
;//==================================================
;//==================================================
DivisorCalc proc;
;//**********************************************************
;//Description: This procedure calculates divisors
;//Receives: An int in EAX.
;//Returns: Primes array in EBX
;//**********************************************************
;//                      10        20        30        40        50        60
.data;//       0123456789012345678901234567890123456789012345678901234567890
tableTop BYTE " n   Divisors                 Prime Divisors",0;
targetNum DWORD 0;
arrSize BYTE 0;
divisorArr BYTE 50 DUP(0);
.code
;//End.data//
    mov EDX, OFFSET tableTop;
    write;
    mov targetNum, EAX
    mov ECX, targetNum
    sub ECX, 1;//Make sure we stop at 2.
F1:
    push ECX
    mov arrSize, 0;
    mov EAX, 0;//Clear EAX
    ;//Done with text bit

    ;//Begin setup for sieve double loop
    mov ESI, 0;//Use this as an index to store primes in the array.
    mov EDX, 0;
    mov EBX, targetNum;//We will use BL to keep the count and start at 2 for loop 1
    mov ECX, targetNum;//Loop count(for the val of the num we are checking)

    mov BH, 2;//set BH to start at 2;
    L2:;//BL is the dividend.//BH is the divisor 
	   movzx AX, BL;
	   cmp AL, BH;
	   JE EL2;//This means that dividend = divisor and that we are done.
	   div BH;
	   cmp AH, 0;//Is a divisor
	   JE P1;//Is a divisor
	   R1:
	   add BH, 1;//Add one to BH and loop.
	   loop L2;
    EL2:;//End loop2
    mov [divisorArr + ESI], BL;
    add arrSize, 1;
    jmp E1;
M1:
    JMP F1;//This is annoying, apparently I was trying to jump too far so I had to make a middle ground. >.>;
P1:;//Is divisor
    mov [divisorArr + ESI], BH;
    add ESI, 1;
    add arrSize, 1;
    jmp R1;//Jump back into the loop
E1:;//End jump
    movzx ECX, arrSize;
    mov EDX, OFFSET divisorArr;
    call DivisorPrimeCalc;
    mov EAX, targetNum;
    call WriteInt;
    call DivWrite;
    sub targetNum, 1;
    pop ECX;
    loop M1;
    ;//EBX holds the divisor Array, and EAX holds the primes array.
ret;
DivisorCalc endp;
;//==================================================
;//==================================================
DivisorPrimeCalc proc;
;//**********************************************************
;//Description: This procedure calculates the primes up to N
;//Receives: An array of N's to test from EDX, and the array size in ECX.
;//Returns: Primes array in EAX, divArray size in CL, primeArray size in CH
;//**********************************************************
.data
primeArr1 BYTE 50 DUP(0);
arrSize1 BYTE 0;
primeSize BYTE 0;
indexVal BYTE 0;
.code
;//End.data//
    ;//Begin setup for prime double loop
    mov primeSize, 0;
    mov indexVal, 0;
    ;//Reseting index for multiple runs ^^^^^^^^^^^^^
    mov arrSize1, CL;
    mov ESI, 0;//Use this as an index to store primes in the array.
    mov EBX, 0;
L1:
    push ECX;//Store loop count for the end
    movzx ECX, indexVal;
    mov BL, [EDX + ECX];//We will use BL to keep the count and start at 2 for loop 1
    movzx ECX, BL;//Set the loop to test the current num (from 2 to N with N=Current num)
    mov BH, 2;//Reset BH to start at 2;
    L2:;//BL is the dividend.//BH is the divisor 
	   movzx AX, BL;
	   cmp AL, BH;
	   JE P1;//This means that dividend = divisor and the number is prime.
	   div BH;
	   cmp AH, 0;//If the remainder is zero then it was divided and is not prime
	   JE EL2;//Not prime
	   add BH, 1;//Add one to BH and loop.
	   loop L2;
    EL2:;//End loop2
    pop ECX;//Reset ECX and continue the prime loop
    add indexVal, 1;
    loop L1;
    jmp E1;
P1:;//If prime
    mov [primeArr1 + ESI], BL;
    add ESI, 1;
    add primeSize, 1;
    jmp EL2;//Jump over the rest of loop 2.
E1:;//End jump
    mov EBX, OFFSET primeArr1;
    mov ECX, 0;
    mov CL, arrSize1;
    mov CH, primeSize;
ret;
DivisorPrimeCalc endp;
;//==================================================
;//==================================================
DivWrite proc;
;//**********************************************************
;//Description: Writes out the divisor numbers
;//Receives: primeArr in EBX, divArr in EDX, divSize in CL, primeSize in CH
;//Returns: nothing
;//**********************************************************
.data
    divSize BYTE 0;
    divSpacer BYTE "   ",0;
    primeSpacer BYTE "     Prime: ",0;
    primeSize1 BYTE 0;
.code
    mov divSize, CL;
    mov primeSize1, CH;
    mov EAX, 0;

    push EDX;
    mov EDX, OFFSET divSpacer;//Spacer for the numbers
    call WriteString;
    pop EDX;
    
    mov ESI, 0;
    movzx ECX, divSize;
L2:;//Divisors
    mov AL, [EDX + ESI];
    call WriteInt;
    numSep;
    add ESI, 1;
    loop L2;

    push EDX;
    mov EDX, OFFSET primeSpacer;
    call WriteString;
    pop EDX;

    movzx ECX, primeSize1;//Set the loop count for the # of primes.
    mov ESI, 0;//Use as index to loop through the prime arr.
L1:;//Primes
    mov AL, [EBX + ESI];
    call WriteInt;
    numSep;
    add ESI, 1;
    loop L1;
    clear;
ret;
DivWrite endp;
;//==================================================
;//==================================================

;//Sieve of Eratosthenes Section: **********************************************************************

;//==================================================
Sieve proc;
;//**********************************************************
;//Description: This procedure manages the sieve function of the program.
;//Receives: Nothing
;//Returns: Nothing
;//**********************************************************
    call SieveCalc;//Generate Prime numbers
    call SieveWrite;//Write out primes.
    clear;
    clear;
ret;
Sieve endp;
;//==================================================
SieveCalc proc;
;//**********************************************************
;//Description: This procedure calculates the primes up to 100, based on the algorithm provided.
;//Receives: Nothing
;//Returns: Primes array in EBX
;//**********************************************************
.data
sieveStatement BYTE "Running the Sieve of Eratosthenes...",0;
sieveEndStatement BYTE "The primes less than 100 are: ",0;
primeArr BYTE 20 DUP(0);
.code
;//End.data//
    mov EDX, OFFSET sieveStatement;
    write;
    mov EDX, OFFSET sieveEndStatement;
    call WriteString;//Didnt use my func here because I dont want a new line.
    ;//Done with text bit

    ;//Begin setup for sieve double loop
    mov ESI, 0;//Use this as an index to store primes in the array.
    mov EDX, 0;
    mov BL, 2;//We will use BL to keep the count and start at 2 for loop 1
    mov BH, 0;//We will use Bh to keep count for loop 2;
    mov ECX, 98;//Number of times we want to run the look since we are checking from 2-100 inclusive.(98 nums)
L1:
    push ECX;//Store loop count for the end
    movzx ECX, BL;//Set the loop to test the current num (from 2 to N with N=Current num)
    mov BH, 2;//Reset BH to start at 2;
    L2:;//BL is the dividend.//BH is the divisor 
	   movzx AX, BL;
	   cmp AL, BH;
	   JE P1;//This means that dividend = divisor and the number is prime.
	   div BH;
	   cmp AH, 0;//If the remainder is zero then it was divided and is not prime
	   JE EL2;//Not prime
	   add BH, 1;//Add one to BH and loop.
	   loop L2;
    EL2:;//End loop2
    add BL, 1;//Test next num
    pop ECX;//Reset ECX and continue the prime loop
    loop L1;
    jmp E1;
P1:;//If prime
    mov [primeArr + ESI], BL;
    add ESI, 1;
    jmp EL2;//Jump over the rest of loop 2.
E1:;//End jump
    mov EBX, OFFSET primeArr;
ret;
SieveCalc endp;
;//==================================================
;//==================================================
SieveWrite proc;
;//**********************************************************
;//Description: Writes out the values for the sieve
;//Receives: The sieve array in EBX.
;//Returns: nothing
;//**********************************************************
    mov EAX, 0;
    mov ECX, ESI;//Set the loop count for the # of primes.
    mov ESI, 0;//Use as index to loop through the prime arr.
L1:
    mov AL, [EBX + ESI];
    call WriteInt;
    numSep;
    add ESI, 1;
    loop L1;
ret;
SieveWrite endp;
;//==================================================
;//==================================================
;//This is just a compound way to write a number separator for the sieve.
sieveSep proc;
;//**********************************************************
;//Description: Adds a comma
;//Receives: nothing
;//Returns: nothing
;//**********************************************************
    push EAX;
    mov EAX, ',';
    call WriteChar;
    pop EAX;
ret;
sieveSep endp;
;//==================================================
writeL proc;//called using write
;//**********************************************************
;//Description: Writes the string in EDX, adds a newline;
;//Receives: EDX
;//Returns: Nothing
;//**********************************************************
    call WriteString;
    call CRLF;
ret;
writeL endp;
;//==================================================
;//==================================================
END main