#MAKE_EXE#      ; FORCING THE EMU8086 TO COMPILE AS AN EXE FILE

.MODEL SMALL    ; Defines the memory model
.STACK 100h     ; Reserves 256 bytes for the stack

.DATA           ; Start of the Data Segment
    
    
                  ; --- Header Strings ---
    
    HDR     DB '===========================', 13, 10
            DB '    SMART RETAIL SYSTEM    ', 13, 10
            DB '===========================', 13, 10, '$'
            
        
        
    ;   --- Main Menu String ---
    
    OPT1    DB '1. Item Menu (Select Items)', 13, 10, '$'
    OPT2    DB '2. Calculate Bill (Current Total: Rs. $'
    OPT3    DB ')', 13, 10, '3. Generate Invoice', 13, 10, '$'
    OPT4    DB '4. Exit', 13, 10, 13, 10, '$'
    PROMPT  DB 'Enter your Choice (1-4): $'
    
    
    ;   --- Variables & Data Storage ---
    
    PRICES DW 50, 80, 10, 90, 60    ; Array of 5 item prices
    TOTAL  DW 0                     ; TO store Grand Total  
    
                                                             
                                                             
                                                             
 
 .CODE          ; Marking the beginning of the executable instructions
 
 
    ;   --- Macro To Print The String ---   
    
    PRINT_STR MACRO STRING
        MOV AH, 09h     ; DOS function 09h: prints the string
        LEA DX, STRING  ; Load effective address of the string into the DX Register
        INT 21h         ; Trigger DOS interrupt to execute the print
    ENDM
    
    MAIN PROC           ; Start of your main procedure
        
        ; 1. Initialize the Data Segment
        MOV AX, @DATA
        MOV DS, AX
        
        ; 2. Print the Header and Menu Options
        PRINT_STR HDR
        PRINT_STR OPT1
        
        PRINT_STR OPT2  ; Prints up to "Rs. "
        ; (Later, we will insert code right here to print the actual TOTAL number)
        
        PRINT_STR OPT3  ; Prints the closing ")" and Option 3
        PRINT_STR OPT4  ; Prints Option 4
        Print_STR PROMPT; Prints the prompt asking for input
        
        ; 3. Take user input from the keyboard
        MOV AH, 01h     ; DOS Function 01h: Read a single character from keyboard
        INT 21h         ; Trigger DOS interrupt. (The typed key is saved in the AL Register)
        
        ; 4. Exit the Program Gracefully
        MOV AH, 4Ch     ; DOS Function 4Ch: Terminate program
        INT 21h         ; Trigger DOS interrupt to exit
        
        
     MAIN ENDP          ; End of the main procedure
     END MAIN           ; Tells the assembler this is the very end of the file