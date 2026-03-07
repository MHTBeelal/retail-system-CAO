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
    I_RESET  DB 'R. Reset Basket'    , 13, 10, '$'
    I_BACK   DB 'B. Back to Main Menu',13, 10, '$'
    I_PROMPT DB 'Which item would you like to buy? (1-5), B to go back, R to Reset: $'
    QTY_PROMPT DB 13, 10, 'Enter Quantity (1-9): $'
    
    
    ; --- Basket Tracking ---
    COUNTS   DB 0, 0, 0, 0, 0   ; 5 bytes to store quantity of each item
    B_OPEN   DB '[ ', '$'       ; Opening bracket
    B_CLOSE  DB ' ] ', '$'      ; Closing bracket
                                                             
    
    ; --- Billing Variables ---
    TAX      DW 0
    DISC     DW 0
    FINAL    DW 0
    
    
    ; --- Invoice Labels ---
    L_SUB    DB 13, 10, 'Sub-Total: Rs. ', '$'
    L_TAX    DB 13, 10, 'TAX: Rs. ',       '$'
    L_DISC   DB 13, 10, 'Discount: Rs. ',  '$'
    L_FINAL  DB 13, 10, '--------------------------', 13, 10
             DB 'FINAL BILL: Rs. ', '$'
    MSG_CONT DB 13, 10, 'Press any key to return to menu...', '$'
    
    
    ; --- Short Invoice Item Names (for Invoice table only) ---
    N_1      DB 'Bread     ', '$'
    N_2      DB 'Milk      ', '$'
    N_3      DB 'Eggs      ', '$'
    N_4      DB 'Butter    ', '$'
    N_5      DB 'Juice     ', '$'
    NEWLINE  DB 13, 10, '$'
    
    
    ; --- Invoice Table Headers ---
    INV_HDR  DB 13, 10, '--- FINAL INVOICE ---', 13, 10
             DB 'ITEM       QTY  PRICE  TOTAL', 13, 10
             DB '---------------------------', 13, 10, '$'
    SPACE    DB '   ', '$' ; USSING FOR FORMATTING COLUMNS
    INV_FOOT DB 13, 10, '--------------------------', 13, 10
             DB 'SUB-TOTAL ', '$'
    INV_FITM DB ' items     Rs. ', '$'
    FROM_INV DB 0
    G_PROMPT DB 13, 10, 'Press "G" to Generate Invoice', 13, 10
             DB 'Press any other key to return to menu: $'
    THANK_MSG DB 13, 10, 13, 10
              DB '===========================', 13, 10
              DB '    THANK YOU FOR YOUR     ', 13, 10
              DB '         PURCHASE!         ', 13, 10
              DB '===========================', 13, 10
              DB '  We hope to see you soon! ', 13, 10, 13, 10
              DB 'Press any key to continue...$'
    
                                                             
                                                             
 
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
        
        START_MENU:     ; Add this label so we can jump back here
            CALL CLEAR_SCREEN
        
        ; 2. Print the Header and Menu Options
        PRINT_STR HDR
        PRINT_STR OPT1
        
        PRINT_STR OPT2  ; Prints up to "Rs. "
        MOV AX, TOTAL
        CALL PRINT_NUM
        
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
        
        
        JMP START_MENU  ; Safty check if wrong input pressed
                        (; If someone Press invalid key, then jump back to the start JMP MAIN)
        
          
          
        ; ======================================
        ;       SECTION LABELS FOR OPTIONS
        ; ======================================
          
                                                
        SHOW_ITEMS:
                CALL CLEAR_SCREEN
                PRINT_STR M_ITEMS

                ; --- 1. Display items with their current basket counts ---
                MOV SI, 0               ; Index for Item 1
                LEA BX, I_1             ; Address of Item 1 string
                CALL PRINT_ITEM_LINE
    
                MOV SI, 1               ; Index for Item 2
                LEA BX, I_2
                CALL PRINT_ITEM_LINE
    
                MOV SI, 2               ; Index for Item 3
                LEA BX, I_3
                CALL PRINT_ITEM_LINE
    
                MOV SI, 3               ; Index for Item 4
                LEA BX, I_4
                CALL PRINT_ITEM_LINE
    
                MOV SI, 4               ; Index for Item 5
                LEA BX, I_5
                CALL PRINT_ITEM_LINE
                
                
                
                ; --- 2. Display Sub-Menu Options ---
                PRINT_STR I_BACK
                PRINT_STR I_RESET
                PRINT_STR I_PROMPT
                                  
                                  
                                  
              ; --- 3. Handle User Input ---
                MOV AH, 01h
                INT 21h
                
                ; Check for 'B' or 'b' (BACK)
                CMP AL, 'B'
                JE START_MENU
                CMP AL, 'b'
                JE START_MENU
                
                ; Check for 'R' OR 'r' (RESET)
                CMP AL, 'R'
                JE INTERNAL_RESET
                CMP AL, 'r'
                JE INTERNAL_RESET
                
                ; Check if input is between '1' and '5'
                CMP AL, '1'             ; If less than '1', invalid, *REFRESH*
                JB SHOW_ITEMS           
                CMP AL, '5'             ; If greater than '5', invalid, *REFRESH*
                JA SHOW_ITEMS          
                
                
                
                ; --- 4. Process Purchase (If 1-5 was pressed) ---
                SUB AL, '1'             ; Convert '1'-'5' to 0-4
                MOV AH, 0
                MOV SI, AX              ; SI now holds the item index (0-4)

                ; Save the index for later use (Quantity update)
                PUSH SI                 

                ; --- Get Quantity ---
                ; (For this example, we'll assume a single digit 1-9)
                PRINT_STR QTY_PROMPT    ; (Make sure you added this to .DATA!)
                MOV AH, 01h
                INT 21h
                SUB AL, '0'             ; AL = actual quantity
                MOV CL, AL              ; Store quantity in CL
    
                ; --- Update the Basket Count ---
                POP SI                  ; Get our item index back
                ADD COUNTS[SI], CL      ; Add the new quantity to the basket

                ; --- Update the Grand Total ---
                ; Total = Total + (Price[SI] * Quantity)
                PUSH SI
                ADD SI, SI              ; Double SI for Word array (DW)
                MOV AX, PRICES[SI]      ; Get Price
                MOV AH, 0               ; Clear AH just in case
                MUL CX                  ; AX = Price * Quantity
                ADD TOTAL, AX           ; Add result to Grand Total
                POP SI

                JMP SHOW_ITEMS                ; Refresh the list to show updated count!
                 
                
                ; --- Reset Logic inside the Item Menu ---
                INTERNAL_RESET:
                    MOV TOTAL, 0
                    MOV SI, 0
                RESET_LOOP_INT:
                    MOV COUNTS[SI], 0    
                    INC SI
                    CMP SI, 5
                    JL RESET_LOOP_INT
                    JMP SHOW_ITEMS              ; Refresh screen to show all [0]
                   
                 
        SHOW_TOTAL:
                CALL CLEAR_SCREEN
                
        SHOW_TOTAL_DIRECT:        
                PRINT_STR HDR
                 
                 
                ; --- ZERO BASKET CASE ---
                ; IF TOTAL IS 0, SKIP ALL CALCULATIONS!
                MOV AX, TOTAL
                CMP AX, 0
                JNE CALC_TAX         ; Not zero? Proceed normally
                MOV TAX,  0          ; Zero everything out
                MOV DISC, 0
                MOV FINAL, 0
                JMP DISPLAY_BILL     ; Jump straight to display
                
                
                ; --- 1. Calculate Tax ---
                ; CONDITION: 0-50 -> RS. 4, 51- 200 -> RS. 15, > 200 -> RS. 30
                CALC_TAX:
                MOV AX, TOTAL
                CMP AX, 50
                JBE TAX_LOW         ; TOTAL <= 50
                CMP AX, 200
                JBE TAX_MED          ; TOTAL <= 200
                MOV TAX, 30          ; TOTAL > 200
                JMP CALC_DISC
                
                TAX_LOW:
                    MOV TAX, 4
                    JMP CALC_DISC
                TAX_MED:
                    MOV TAX, 15
                
                
                ; --- 2. Calculate Discount ---
                ; CONDITION: >= 450 -> 30%, >= 200 -> 15%, ELSE 0%
                CALC_DISC:
                    MOV AX, TOTAL
                    CMP AX, 450
                    JAE DISC_30      ; TOTAL >= 450
                    CMP AX, 200      
                    JAE DISC_15      ; TOTAL >= 200
                    MOV DISC, 0      ; NO DISCOUNT!
                    JMP APPLY_BILL
                    
                
                DISC_30:
                    ; (TOTAL * 30) / 100
                    MOV BX, 30
                    MUL BX           ; AX = TOTAL * 30
                    MOV BX, 100     
                    DIV BX           ; AX = RESULT
                    MOV DISC, AX
                    JMP APPLY_BILL
                    
                DISC_15:
                    ; (TOTAL * 15) / 100
                    MOV BX, 15
                    MUL BX          ; AX = TOTAL * 15
                    MOV BX, 100
                    DIV BX           ; AX = RESULT
                    MOV DISC, AX
                
                
                ; --- 3. Final Calculation ---
                ; FINAL = (TOTAL - DISCOUNT) + TAX
                APPLY_BILL:
                MOV AX, TOTAL
                SUB AX, DISC
                ADD AX, TAX
                MOV FINAL, AX
                
                
                DISPLAY_BILL:
                ; --- 4. Display the Summary ---
                PRINT_STR L_SUB
                MOV AX, TOTAL
                CALL PRINT_NUM
                
                PRINT_STR L_TAX
                MOV AX, TAX
                CALL PRINT_NUM
                
                PRINT_STR L_DISC
                MOV AX, DISC
                CALL PRINT_NUM
                
                PRINT_STR L_FINAL
                MOV AX, FINAL
                CALL PRINT_NUM
                
                PRINT_STR MSG_CONT
                MOV AH, 01h
                INT 21h
                
                CMP FROM_INV, 1      ; Did we come from Invoice + G press?
                JNE START_MENU       ; No ? just go back to menu normally
                
                ; --- YES: Reset everything for new customer ---
                MOV FROM_INV, 0      ; Clear the flag
                MOV TOTAL, 0         ; Reset grand total
                MOV SI, 0
                RESET_NEW_CUST:
                    MOV COUNTS[SI], 0
                    INC SI
                    CMP SI, 5
                    JL RESET_NEW_CUST
                
                ; --- Show Thank You screen ---
                CALL CLEAR_SCREEN
                PRINT_STR THANK_MSG
                MOV AH, 01h
                INT 21h
                JMP START_MENU
                 
                 
                 
        INVOICE:
                CALL CLEAR_SCREEN
                PRINT_STR HDR
                PRINT_STR INV_HDR
                
                
                MOV SI, 0            ; Start at first time index
                
            PRINT_INVOICE_LOOP:
                MOV AL, COUNTS[SI]   ; Check if user bought this item
                CMP AL, 0
                JE NEXT_INV_ITEM     ; If quantity is 0 then skip printing this line
                
                
                ; --- Print Item Name ---
                ; Since names are separate variables, we use a small jump table
                PUSH SI
                CMP SI, 0
                JE P_I1
                CMP SI, 1
                JE P_I2
                CMP SI, 2
                JE P_I3
                CMP SI, 3
                JE P_I4
                JMP P_I5
                
                
                P_I1: PRINT_STR N_1
                      JMP AFTER_NAME
                P_I2: PRINT_STR N_2
                      JMP AFTER_NAME
                P_I3: PRINT_STR N_3
                      JMP AFTER_NAME
                P_I4: PRINT_STR N_4
                      JMP AFTER_NAME
                P_I5: PRINT_STR N_5

                AFTER_NAME:
                    POP SI
                    
                    
                ; --- Print Quantity ---
                PRINT_STR SPACE
                MOV AL, COUNTS[SI]
                MOV AH, 0
                CALL PRINT_NUM
                
                ; --- Print Price ---
                PRINT_STR SPACE
                PUSH SI
                ADD SI, SI          ; Word array adjustment
                MOV AX, PRICES[SI]
                CALL PRINT_NUM
                
                ; --- Calculate and Print Item Total ---
                PRINT_STR SPACE
                ; AX already has Price, AL of original COUNTS has quantity
                POP SI
                PUSH SI
                PUSH SI
                ADD SI, SI          ; Double SI for Word Array
                MOV AX, PRICES[SI]  ; Reload price cleanly into AX
                POP SI
                
                MOV AH, 0           ; Ensure high bytes are clean
                MOV BL, COUNTS[SI]  ; BL = quantity for this item
                MOV BH, 0
                MOV AH, 0
                MUL BX              ; AX = Price * Quantity
                CALL PRINT_NUM
                PRINT_STR NEWLINE   
                POP SI
                
                NEXT_INV_ITEM:
                    INC SI
                    CMP SI, 5
                    JL PRINT_INVOICE_LOOP
                    
                    
                    ; --- Show the Tax, Discount, and Grand Total ---
                ; We jump to the calculation logic already in SHOW_TOTAL
                ; but without clearing the screen first.
                ; --- Print Subtotal Row ---
                    PRINT_STR INV_FOOT      ; Print divider + "Sub-Total  "

                    ; Sum all quantities for total item count
                    MOV SI, 0
                    MOV BX, 0               ; BX = accumulator for total qty
                SUMQTY_LOOP:
                    MOV AL, COUNTS[SI]
                    MOV AH, 0
                    ADD BX, AX
                    INC SI
                    CMP SI, 5
                    JL SUMQTY_LOOP

                    MOV AX, BX
                    CALL PRINT_NUM          ; Print total item count

                    PRINT_STR INV_FITM      ; Print " items     Rs. "

                    MOV AX, TOTAL
                    CALL PRINT_NUM          ; Print sub-total amount

                    PRINT_STR NEWLINE
                    
                    
                    ; --- Ask user to confirm invoice generation ---
                    PRINT_STR G_PROMPT
                    MOV AH, 01h
                    INT 21h
                    CMP AL, 'G'
                    JE DO_FINALIZE
                    CMP AL, 'g'
                    JE DO_FINALIZE
                    JMP START_MENU      ; Any other key = go back
                    
                 DO_FINALIZE:
                     MOV FROM_INV, 1     ; Set flag so SHOW_TOTAL knows to reset
                     PRINT_STR NEWLINE   ; Fix: push "G" echo off the header line
                     JMP SHOW_TOTAL_DIRECT
                 
                 
                 
        EXIT_PROG:
                ; 4. Exit the Prograk Gracefully
                MOV AH, 4Ch    ; DOS Function 4Ch: Terminate program
                INT 21h        ; Trigger DOS interrupt to exit                                                              
                                                  
                                                  
     MAIN ENDP                 ; End of the main procedure
    
            
            ; ============================================
            ; PROCEDURE: PRINT_NUM
            ; Converts AX value to Decimal text on screen
            ; ============================================
            PRINT_NUM PROC
                PUSH AX
                PUSH BX
                PUSH CX
                PUSH DX
                
                
                MOV CX, 0       ; Counter for digits
                MOV BX, 10      ; We will divide by 10
                
                
            DIGIT_LOOP:
                MOV DX, 0       ; Clear remainder
                DIV BX          ; AX / 10. Remainder in DX
                PUSH DX         ; Save digit on stack
                INC CX          ; Increment count
                CMP AX, 0       ; Is quotient 0?
                JNE DIGIT_LOOP
                
             
            
            PRINT_LOOP:
                POP DX          ; Get digit back
                ADD DL, '0'     ; Convert to ASCII
                MOV AH, 02h     ; Print character
                INT 21h
                LOOP PRINT_LOOP
                
                POP DX
                POP CX
                POP BX
                POP AX
                
                
                RET
             PRINT_NUM ENDP   
            
            
            
            ; ============================================
            ; PROCEDURE: CLEAR_SCREEN
            ; This clears the terminal and resets the cursor
            ; ============================================
            CLEAR_SCREEN PROC
            ; 1. Scroll the entire screen up to clear it
            MOV AH, 06h     ; BIOS function: SCROLL UP
            MOV AL, 00h     ; AL = 0 means "CLEAR THE WHOLE WINDOW"
            MOV BH, 07h     ; Text attrubute (07h = White text on Black background)
            MOV CH, 00h     ; Upper left row (0)
            MOV CL, 00h     ; Upper left column (0)
            MOV DH, 24      ; Lower right row (24)
            MOV DL, 79      ; Lower right column (79)
            INT 10h         ; Call BIOS Video Interrupt
            
            
            ; 2. Reset Cursor to the Top-Left corner (0,0)
            MOV AH, 02h    ; BIOS function: Set Cursor Position
            MOV BH, 00h    ; Page number 0
            MOV DH, 00h    ; Row 0
            MOV DL, 00h    ; Column 0
            INT 10h        ; Call BIOS Video Interrupt   
            
            
            RET            ; Return to where the procedure was called      
     CLEAR_SCREEN ENDP
                     
                     
            
            ; ============================================
            ; PROCEDURE: PRINT_ITEM_LINE
            ; Inputs: BX = Address of Item Name String, SI = Index (0-4)
            ; ============================================
            PRINT_ITEM_LINE PROC
            PRINT_STR B_OPEN        ; Print "[ "
    
            ; 1. Get the count from the COUNTS array
            MOV AL, COUNTS[SI]      ; Load count for this item
            ADD AL, '0'             ; Convert number to ASCII
    
            ; 2. Print the single digit count
            MOV DL, AL
            MOV AH, 02h             ; DOS function to print a single character
            INT 21h
    
            PRINT_STR B_CLOSE       ; Print " ] "
    
            ; 3. Print the Item Name (passed via BX)
            MOV DX, BX
            MOV AH, 09h
            INT 21h
    
            RET
    PRINT_ITEM_LINE ENDP
           
            
            
     END MAIN                  ; Tells the assembler this is the very end of the file