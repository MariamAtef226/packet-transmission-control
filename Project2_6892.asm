;Mariam Atef Hassan - 6892 - project #2
;Option 2:
;number of packets per transmission is based on total number of transmitted packets

org 100h


.MODEL SMALL 
.STACK 100H 
.DATA 

reader db 'Enter size of file (Number of packets to be transferred):',13,10,'$'
newline db 13,10,'$'
res db 'Number of transmissions done to transmit this file =   ','$'
        
num dw 0   ;where input number will be stored
ten dw 10
two dw 2
oldax1 dw 0
oldax2 dw 0



.CODE

MAIN PROC
    
        MOV AX,@DATA 
        MOV DS,AX    ;initializing data segment register
        MOV AH,09H   ;DOS fn code to write string to output
	    LEA DX,reader ;printing the string "reader"
	    INT 21H 
        
        
        CALL READ
    
    ;bx will store number of transmission operations
    ;ax will store number of transmitted packets so far
        
        MOV AH,09H     ;DOS fn code to write string to output
	    LEA DX,newline ;printing a new line
	    INT 21H         
        MOV AH,09H
	    LEA DX,res    ;printing the string "res"
	    INT 21H
	     
        MOV BX, 1
        MOV AX, 1
    
 
    check_done:
    
        CMP AX,num  ;have we moved all packets?
        JL  start_of_loop  ;if not, go and move the remaining
        MOV AX,BX   ;if yes, store number of movement operations in AX
        JMP next    ;go and print it                            
                      
    start_of_loop:
        
        CMP AX,40H   ;64 decimal ... case 1
        JGE case2
        MOV oldax1,AX
        MUL two
        ADD AX, oldax1  ;doubling the number
        INC BX ;a transmission is done. So, increase the counter
        JMP check_done
    
    case2:  
  
        CMP AX, 80H  ;once we reach 128 decimal ">=128"
        JGE case3    ;go to case 3 "start over"
        MOV oldax2, AX
        INC AX
        ADD AX, oldax2
        INC BX   ;a transmission is done. So, increase the counter
        JMP check_done
    
    case3: 
  
        SUB num,AX
        MOV AX, 1 ;start over
        INC BX    ;transmit 1 packet
        JMP check_done
	
	next:       

        CALL PRINT
        ret

MAIN ENDP
        
        
        
        
         
READ PROC         
    
        MOV num, 0  ;initialize memory location num by 0..it'll store received digits so far

    reading_digits:

        MOV AH,01H
        INT 21H
    
        CMP AL, 0DH ;CHECK IF ENTER KEY WAS PRESSED WHICH MEANS END OF INPUT
        JE done
    
        CMP AL, 30H ;if ascii code of entered key is <30H or >39H, then it's not numeric. Then it's invalid
        JL invalid
    
        CMP AL,39H
        JG invalid
    
        SUB AL, 30H ;convert from ascii to integer
        MOV AH,00
        MOV BX,AX
        MOV AX,num
        MUL ten
        ADD AX,BX
        MOV num,AX
    
    invalid:           
    
        JMP reading_digits

    done:
    
        ret

ENDP

        
        
        
        

PRINT PROC          
     
    ;initialize count
        MOV CX,0
        MOV DX,0
    label1:
        ; if ax is zero
        CMP AX,0
        JE print1     
         
        ;initialize bx to 10
        ;MOV BX,10       
         
        ; extract the last digit and push it to the stack
        DIV ten                
        PUSH DX             
         
        INC CX             
         
        ;set dx to 0
        XOR DX,DX
        
        JMP label1
    
    print1:
        ;check if count is greater than zero
        CMP CX,0
        JE exit
         
        ;pop the top of stack, add 30H to it to represent ASCII
        POP DX
        ADD DX,30H
         
        MOV AH,02h
        INT 21h
        DEC CX
        JMP print1
    exit:
    
        ret 
        
PRINT ENDP
        
        
END MAIN