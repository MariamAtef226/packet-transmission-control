;Mariam Atef Hassan - 6892 - project #2
;Option 3:
;comparisons is based on number of packets per transmission not on total number of transmitted packets

org 100h


.MODEL SMALL 
.STACK 100H 
.DATA 

reader db 'Enter size of file (Number of packets to be transferred):',13,10,'$'
newline db 13,10,'$'
res db 'Number of transmissions done to transmit this file =   ','$'
        
num dw 0
ten dw 10
two dw 2
trans dw 0
success dw 0



.CODE

MAIN PROC
    
        MOV AX,@DATA 
        MOV DS,AX 
        MOV AH,09H
	    LEA DX,reader  
	    INT 21H 
        
        
        CALL READ
   
        
        MOV AH,09H
	    LEA DX,newline  
	    INT 21H 
        MOV AH,09H
	    LEA DX,res  
	    INT 21H
	               
	;bx will store number of transmission operations
    ;ax will store number of transmitted packets so far           
	               
        MOV BX, 1
        MOV AX, 1
        MOV success,AX
    
 
    check_done:
    
        MOV trans, AX
        MOV AX, success
        CMP AX,num  ;have we moved all packets?
        JL  start_of_loop  ;if not, go and move the remaining
        MOV AX,BX   ;if yes, store number of movement operations in AX
        JMP next    ;go and print it                            
                      
    start_of_loop:
        
        MOV AX,trans
        CMP AX,40H   ;64 decimal ... case 1
        JGE case2
        MUL two
        ADD success, AX  
        INC BX ;a transmission is done. So, increase the counter
        JMP check_done
    
    case2:  
  
        MOV AX,trans
        CMP AX, 80H  ;once we reach 128 decimal ">=128"
        JGE case3    ;go to case 3 "start over"
        INC AX
        ADD success, AX 
        INC BX   ;a transmission is done. So, increase the counter
        JMP check_done
    
    case3: 
        MOV AX, done
        SUB num,AX
        MOV AX, 1 ;start over
        MOV trans,AX 
        MOV done,AX
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