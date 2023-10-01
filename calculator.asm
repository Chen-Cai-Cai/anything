DATAS SEGMENT
    MENU0 DB "Input experssion to calculate: ",'$'
    MENU1 DB "*****Invalid Number!*****",0DH,0AH,'$'
    MENU2 DB "*****Invalid Operator!*****",0DH,0AH,'$'
    MENU3 DB "*****Invalid Input!*****",0DH,0AH,'$'
    MINUS DB "-",'$'
    MFLAG DB 0
    NUMBER1 DD 0
    NUMBER2 DD 0
    NUMBER3 DD 0
    OP1 DB 0
    OP2 DB 0
    OP1_LEVEL DB 0
    OP2_LEVEL DB 0
    DEC_BASE DD 10
DATAS ENDS

STACKS SEGMENT
    DB 100 DUP(0)
STACKS ENDS

CODES SEGMENT
.386
START:
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
    MOV AX,DATAS
    MOV DS,AX
    MOV ES,AX
    MOV AX,STACKS
    MOV SS,AX
    XOR SI,SI
    XOR CX,CX
MAIN_LOOP:
    CALL PRINT_ENTER
    CALL PRINT_TIPS
    XOR CX,CX
    XOR SI,SI
    XOR AX,AX
    MOV BYTE PTR MFLAG,AL
CAL_LOOP:
    CALL READ_NUMBER_AND_OP
    MOV NUMBER1[SI],EBX
    ADD SI,4
    INC CX
    CMP AL,'='
    JE GET_ANS
    CMP AL,'+'
    JE GET_ADD
    CMP AL,'-'
    JE GET_SUB
    CMP AL,'*'
    JE GET_MUL
    CMP AL,'/'
    JE GET_DIV
    CALL PRINT_ENTER
    JMP MAIN_LOOP
GET_ANS:
    CMP CX,1
    JE CAL_ONE_NUMBER
    CMP CX,2
    JE CAL_TWO_NUMBER
    CMP CX,3
    JE CAL_THREE_NUMBER
;-------------------------------
GET_ADD:
    CMP CX,1
    JE GET_ADD_ONE
    CMP CX,2
    JE GET_ADD_TWO
GET_ADD_END:
    JMP CAL_LOOP
GET_ADD_ONE:
    PUSH AX
    MOV AL,'+'
    MOV OP1,AL
    MOV AL,1
    MOV OP1_LEVEL,AL
    POP AX
    JMP GET_ADD_END
GET_ADD_TWO:
    PUSH AX
    MOV AL,'+'
    MOV OP2,AL
    MOV AL,1
    MOV OP2_LEVEL,AL
    POP AX
    JMP GET_ADD_END
;-------------------------------
GET_SUB:
    CMP CX,1
    JE GET_SUB_ONE
    CMP CX,2
    JE GET_SUB_TWO
GET_SUB_END:
    JMP CAL_LOOP
GET_SUB_ONE:
    PUSH AX
    MOV AL,'-'
    MOV OP1,AL
    MOV AL,1
    MOV OP1_LEVEL,AL
    POP AX
    JMP GET_SUB_END
GET_SUB_TWO:
    PUSH AX
    MOV AL,'-'
    MOV OP2,AL
    MOV AL,1
    MOV OP2_LEVEL,AL
    POP AX
    JMP GET_SUB_END
;-------------------------------
GET_MUL:
    CMP CX,1
    JE GET_MUL_ONE
    CMP CX,2
    JE GET_MUL_TWO
GET_MUL_END:
    JMP CAL_LOOP
GET_MUL_ONE:
    PUSH AX
    MOV AL,'*'
    MOV OP1,AL
    MOV AL,2
    MOV OP1_LEVEL,AL
    POP AX
    JMP GET_MUL_END
GET_MUL_TWO:
    PUSH AX
    MOV AL,'*'
    MOV OP2,AL
    MOV AL,2
    MOV OP2_LEVEL,AL
    POP AX
    JMP GET_MUL_END
;-------------------------------
GET_DIV:
    CMP CX,1
    JE GET_DIV_ONE
    CMP CX,2
    JE GET_DIV_TWO
GET_DIV_END:
    JMP CAL_LOOP
GET_DIV_ONE:
    PUSH AX
    MOV AL,'/'
    MOV OP1,AL
    MOV AL,2
    MOV OP1_LEVEL,AL
    POP AX
    JMP GET_DIV_END
GET_DIV_TWO:
    PUSH AX
    MOV AL,'/'
    MOV OP2,AL
    MOV AL,2
    MOV OP2_LEVEL,AL
    POP AX
    JMP GET_DIV_END
;-------------------------------
CAL_END:
    XOR SI,SI
    XOR CX,CX
    JMP MAIN_LOOP
PROGRAM_EXIT:
    MOV AX,4C00H
    INT 21h
CAL_ONE_NUMBER:
    CALL GET_ANS_ONE
    JMP CAL_END
CAL_TWO_NUMBER:
    XOR SI,SI
    CALL GET_ANS_TWO
    JMP CAL_END
CAL_THREE_NUMBER:
    CALL GET_ANS_THREE
    JMP CAL_END

GET_ANS_ONE PROC NEAR
    MOV DWORD PTR EAX,NUMBER1
    CALL VALUE_TO_DEC
    RET
GET_ANS_ONE ENDP

GET_ANS_TWO PROC NEAR
    CMP OP1,'+'
    JE GET_ANS_TWO_ADD
    CMP OP1,'-'
    JE GET_ANS_TWO_SUB
    CMP OP1,'*'
    JE GET_ANS_TWO_MUL
    CMP OP1,'/'
    JE GET_ANS_TWO_DIV
;-------------------------------
GET_ANS_TWO_ADD:
    MOV DWORD PTR EAX,NUMBER1[SI]
    ADD DWORD PTR EAX,NUMBER1[SI+4]
    CALL VALUE_TO_DEC
    RET
;-------------------------------
GET_ANS_TWO_SUB:
    MOV DWORD PTR EAX,NUMBER1[SI]
    CMP DWORD PTR EAX,NUMBER1[SI+4]
    JL GET_ANS_TWO_SUB_EXCHANGE
    SUB DWORD PTR EAX,NUMBER1[SI+4]
    CALL VALUE_TO_DEC
    RET
GET_ANS_TWO_SUB_EXCHANGE:
    XCHG DWORD PTR EAX,NUMBER1[SI+4]
    SUB DWORD PTR EAX,NUMBER1[SI]
    PUSH EAX
    LEA DX,MINUS
    MOV AH,09H
    INT 21H
    POP EAX
    CALL VALUE_TO_DEC
    RET
;-------------------------------
GET_ANS_TWO_MUL:
    MOV DWORD PTR EAX,NUMBER1[SI]
    MUL DWORD PTR NUMBER1[SI+4]
    CALL VALUE_TO_DEC
    RET
;-------------------------------
GET_ANS_TWO_DIV:
    MOV DWORD PTR EAX,NUMBER1[SI]
    DIV DWORD PTR NUMBER1[SI+4]
    CALL VALUE_TO_DEC
    RET
GET_ANS_TWO ENDP

GET_ANS_THREE PROC NEAR
GET_ANS_THREE_1:
    MOV BYTE PTR AL,OP1_LEVEL
    CMP AL,OP2_LEVEL
    JL PRIORITY_NUM2_NUM3
    JMP E_G_MU2_MU3
PRIORITY_NUM2_NUM3:
    MOV SI,4
    CALL GET_ANS_TWO_2
    MOV DWORD PTR NUMBER2,EAX
    XOR SI,SI
    CALL GET_ANS_TWO
    RET
E_G_MU2_MU3:
    XOR SI,SI
    CALL GET_ANS_TWO_3
    MOV DWORD PTR NUMBER1,EAX
    MOV DWORD PTR EAX,NUMBER3
    MOV DWORD PTR NUMBER2,EAX
    MOV BYTE PTR AL,OP2
    MOV BYTE PTR OP1,AL
    XOR SI,SI
    CALL GET_ANS_TWO_4
    MOV BYTE PTR DL,MFLAG
    CALL PRINT_MINUS_PROC
    CALL VALUE_TO_DEC
    RET
GET_ANS_THREE ENDP

PRINT_MINUS_PROC PROC NEAR
    PUSH AX
    PUSH DX
    LEA DX,MINUS
    MOV AH,09H
    INT 21H
    POP DX
    POP AX
    RET
PRINT_MINUS_PROC ENDP

GET_ANS_TWO_2 PROC NEAR
    CMP OP2,'*'
    JE GET_ANS_TWO_MUL_2
    CMP OP2,'/'
    JE GET_ANS_TWO_DIV_2
;-------------------------------
GET_ANS_TWO_MUL_2:
    MOV DWORD PTR EAX,NUMBER1[SI]
    MUL DWORD PTR NUMBER1[SI+4]
    RET
;-------------------------------
GET_ANS_TWO_DIV_2:
    MOV DWORD PTR EAX,NUMBER1[SI]
    DIV DWORD PTR NUMBER1[SI+4]
    RET
GET_ANS_TWO_2 ENDP

GET_ANS_TWO_3 PROC NEAR
    CMP OP1,'*'
    JE GET_ANS_TWO_MUL_3
    CMP OP1,'/'
    JE GET_ANS_TWO_DIV_3
    CMP OP1,'+'
    JE GET_ANS_TWO_ADD_3
    CMP OP1,'-'
    JE GET_ANS_TWO_SUB_3
;-------------------------------
GET_ANS_TWO_MUL_3:
    MOV DWORD PTR EAX,NUMBER1[SI]
    MUL DWORD PTR NUMBER1[SI+4]
    RET
;-------------------------------
GET_ANS_TWO_DIV_3:
    MOV DWORD PTR EAX,NUMBER1[SI]
    DIV DWORD PTR NUMBER1[SI+4]
    RET
;-------------------------------
GET_ANS_TWO_ADD_3:
    MOV DWORD PTR EAX,NUMBER1[SI]
    ADD DWORD PTR EAX,NUMBER1[SI+4]
    RET
;-------------------------------
GET_ANS_TWO_SUB_3:
    MOV DWORD PTR EAX,NUMBER1[SI]
    CMP DWORD PTR EAX,NUMBER1[SI+4]
    JL GET_ANS_TWO_SUB_EXCHANGE_3
    PUSH EAX
    MOV AL,1
    MOV BYTE PTR MFLAG,AL
    POP EAX
    SUB DWORD PTR EAX,NUMBER1[SI+4]
    RET
GET_ANS_TWO_SUB_EXCHANGE_3:
    XCHG DWORD PTR EAX,NUMBER1[SI+4]
    SUB DWORD PTR EAX,NUMBER1[SI]
    PUSH EAX
    MOV AL,0
    MOV BYTE PTR MFLAG,AL
    POP EAX
    RET
GET_ANS_TWO_3 ENDP

GET_ANS_TWO_4 PROC NEAR
    CMP OP1,'+'
    JE GET_ANS_TWO_ADD_4
    CMP OP1,'-'
    JE GET_ANS_TWO_SUB_4
;-------------------------------
GET_ANS_TWO_ADD_4:
    MOV BYTE PTR DL,MFLAG
    CMP DL,1
    JE GET_ANS_TWO_SUB_3
    MOV DWORD PTR EAX,NUMBER1[SI]
    ADD DWORD PTR EAX,NUMBER1[SI+4]
    RET
;-------------------------------
GET_ANS_TWO_SUB_4:
    MOV BYTE PTR DL,MFLAG
    CMP DL,1
    JE GET_ANS_TWO_ADD_3
    MOV DWORD PTR EAX,NUMBER1[SI]
    CMP DWORD PTR EAX,NUMBER1[SI+4]
    JL GET_ANS_TWO_SUB_EXCHANGE_4
    SUB DWORD PTR EAX,NUMBER1[SI+4]
    RET
GET_ANS_TWO_SUB_EXCHANGE_4:
    XCHG DWORD PTR EAX,NUMBER1[SI+4]
    SUB DWORD PTR EAX,NUMBER1[SI]
    PUSH EAX
    MOV AL,1
    MOV BYTE PTR MFLAG,AL
    POP EAX
    RET
GET_ANS_TWO_4 ENDP

;EBX = 输入的操作数,AL = 操作符 
READ_NUMBER_AND_OP PROC NEAR
    PUSH CX
    MOV CX,8
    XOR EBX,EBX
RNAO_LOOP:
    XOR EAX,EAX
    MOV AH,01H
    INT 21H
    CMP AL,1BH ;AL == 'ESC'  
    JE PROGRAM_EXIT
    CMP AL,'='
    JE EQUAL_RET
    CMP AL,'0'
    JL READ_NUMBER_END
    CMP AL,'9'
    JG READ_NUMBER_END
    SUB AL,30H
    XOR AH,AH
    XCHG EAX,EBX
    MUL DEC_BASE
    XCHG EAX,EBX
    ADD EBX,EAX
    LOOP RNAO_LOOP
READ_NUMBER_END:
    POP CX
    CMP AL,'*'
    JL MAIN_LOOP
    CMP AL,'/'
    JG MAIN_LOOP
    CMP AL,'.'
    JE MAIN_LOOP
    CMP AL,','
    JE MAIN_LOOP
    RET
EQUAL_RET:
    POP CX
    RET
READ_NUMBER_AND_OP ENDP

INPUT_ERROR PROC NEAR
    PUSH DX
    PUSH AX
    LEA DX,MENU3
    MOV AH,09H
    INT 21H
    POP AX
    POP DX
    RET
INPUT_ERROR ENDP
;void
PRINT_TIPS PROC NEAR
    PUSH AX
    PUSH DX
    LEA DX,MENU0
    MOV AH,09H
    INT 21H
    POP DX
    POP AX
    RET
PRINT_TIPS ENDP

;EAX = 要以十进制输出的数
VALUE_TO_DEC PROC NEAR
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH ESI
    MOV ECX,10
    MOV EBX,10
VALUE_TO_DEC_DIV:
    XOR EDX,EDX
    DIV EBX
    OR DL,30H
    PUSH EDX
    LOOP VALUE_TO_DEC_DIV
    MOV ECX,10
VALUE_TO_DEC_PRINT:
    POP EDX
    MOV AH,2
    INT 21H
    LOOP VALUE_TO_DEC_PRINT
    POP ESI
    POP EDX
    POP ECX
    POP EBX
    POP EAX
    RET
VALUE_TO_DEC ENDP

PRINT_ENTER PROC NEAR
    PUSH AX
    PUSH DX
    MOV DL,0AH
    MOV AH,02H
    INT 21H
    POP DX
    POP AX
    RET
PRINT_ENTER ENDP

READ_AND_PROCESS PROC NEAR
READ_AND_PROCESS ENDP
CODES ENDS
END START