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
    
    
    ;   --- Item Menu Strings ---
    
    M_ITEMS  DB 13, 10, 13, 10, '--- AVAILABLE ITEMS ---', 13, 10, '$'
    I_1      DB '1. Bread   - Rs. 50', 13, 10, '$'
    I_2      DB '2. Milk    - Rs. 80', 13, 10, '$'
    I_3      DB '3. Eggs    - Rs. 10', 13, 10, '$'
    I_4      DB '4. Butter  - RS. 90', 13, 10, '$'
    I_5      DB '5. Juice   - RS. 60', 13, 10, '$'
    I_PROMPT DB 'Which item would you like to buy? (1-5): $'
                                                             
                                                             
                                                             
 
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
        PRINT_STR PROMPT; Prints the prompt asking for input
        
        ; 3. Take user input from the keyboard
        MOV AH, 01h     ; DOS Finction 01h: Read  single character
        INT 21h         ; Typed key is saved in the AL Register
        
        ; --- NEW ROUTING LOGIC ---
        ; We use CMP (Compare) and JE (jump if Equal)
        
        CMP AL, '1'     ; Did the user press key '1'?
        JE SHOW_ITEMS   ; If Equal, Them jump to the SHOW_ITEMS Label
        
        CMP AL, '2'     ; Did the user press key '2'?
        JE SHOW_TOTAL   ; If Equal, Then jump to the SHOW_TOTAL Label
        
        CMP AL, '3'     ; Did the user press key '3'?
        JE INVOICE      ; If Equal, Then jump to the INVOICE Label
        
        CMP AL, '4'     ; Did the user press '4'?
        JE EXIT_PROG    ; If Equal, Then jump to the EXIT_PROG Label
        
        
        ; If someone Press invalid key, then jump back to the start JMP MAIN
        
        
        ; ======================================
        ;       SECTION LABELS FOR OPTIONS
        ; ======================================
                                                
        SHOW_ITEMS:
                ; 1. Print all the items using our Macro
                PRINT_STR M_ITEMS
                PRINT_STR I_1
                PRINT_STR I_2
                PRINT_STR I_3
                PRINT_STR I_4
                PRINT_STR I_5
                PRINT_STR I_PROMPT
                
                ; 2. Take user input for which item they want
                MOV AH, 01h    ; Read character function
                INT 21h        ; AL now holds the item they chose (1-5)
                 
                 
                  
                ; (Later, we will add the math logic right here to save the price!)
                
                
                
                ; 3. Jump back to the main dashboard
                JMP MAIN       ; Go back to the main menu when done
                 
                 
                 
        SHOW_TOTAL:
                ; (We will write the totl calculation display here later)
                JMP MAIN       ; Go back to the main menu when done
                 
                 
                 
        INVOICE:
                ; (We will write the invoice generation here later)
                JMP MAIN       ; Go back to main menu when done
                 
                 
                 
        EXIT_PROG:
                ; 4. Exit the Prograk Gracefully
                MOV AH, 4Ch    ; DOS Function 4Ch: Terminate program
                INT 21h        ; Trigger DOS interrupt to exit                                                              
                                                  
                                                  
     MAIN ENDP                 ; End of the main procedure
     END MAIN                  ; Tells the assembler this is the very end of the file
