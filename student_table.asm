DATAS SEGMENT
	IN_NAME DB "Input name: ",'$'
    STR_NAME DB "   Name: ",'$'
    STR_ID DB "Student ID: ",'$'
    ER_TIP DB "Valid Command!",0DH,0AH,'$'
	IN_CHINESE DB "Input Chinese score: ",'$'
    IN_MATH DB "Input Math score: ",'$'
    IN_ENGLISH DB "Input English score: ",'$'
	STU_TABLE DB 10 DUP("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
    STU_TABLE_SORTED DB 10 DUP("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
    STU_TABLE_SINGLE_SCORE DB 10 DUP("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
    TMP DB "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    MENU0 DB "--------------------MENU--------------------",0DH,0AH
    MENU1 DB "|1. Display StudentTable.                  |",0DH,0AH
    MENU2 DB "|2. Display All Students' Sorted Score.    |",0DH,0AH
    MENU3 DB "|3. Display average score of every course. |",0DH,0AH
    MENU4 DB "|4. Display Chinese score.                 |",0DH,0AH
    MENU5 DB "|5. Display Math score.                    |",0DH,0AH
    MENU6 DB "|6. Display English score.                 |",0DH,0AH
    MENU7 DB "|7. Display menu.                          |",0DH,0AH
    MENU8 DB "|8. Exit.                                  |",0DH,0AH
    MENU9 DB "--------------------------------------------",0DH,0AH,'$'
    TIPS DB "Please select option: ",'$'
    CHINESE DB "Average Score:",0DH,0AH,"Chinese: ",'$'
    MATH DB "Math: ",'$'
    ENGLISH DB "English: ",'$'
    OUTLINE_RANK DB "Rank   ID   Name     Chinese     Math     English     Total",0DH,0AH,'$'
    OUTLINE DB "ID   Name     Chinese     Math     English     Total",0DH,0AH,'$'
    SINGLE_OL DB "ID   Score    Rank",0DH,0AH,'$'
    ID DB 0
    DEC_BASE DW 10
    DEBUG DB " | ",'$'
    BLANK_FLAG DB 0
    C_S DB "Chinese",0DH,0AH,'$'
    M_S DB "Math",0DH,0AH,'$'
    E_S DB "English",0DH,0AH,'$'
DATAS ENDS

STACKS SEGMENT
	DB 100 DUP(0)
STACKS ENDS

CODES SEGMENT
	ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
	MOV AX,DATAS
	MOV DS,AX
	MOV ES,AX
	MOV AX,STACKS
	MOV SS,AX
    CALL INPUT_INFORMATION
    CALL PRINT_MENU
    CALL GET_TOTAL
READ_CMD:
    LEA DX,TIPS
    MOV AH,09H
    INT 21H
    MOV AH,01H
    INT 21H
    CALL PRINT_ENTER
    CMP AL,'1'
    JL ERROR_CMD
    CMP AL,'8'
    JG ERROR_CMD
    CMP AL,'1'
    JE CMD_1
    CMP AL,'2'
    JE CMD_2
    CMP AL,'3'
    JE CMD_3
    CMP AL,'4'
    JE CMD_4
    CMP AL,'5'
    JE CMD_5
    CMP AL,'6'
    JE CMD_6
    CMP AL,'7'
    JE CMD_7
    MOV AX,4C00H
    INT 21H
CMD_1:
    XOR BX,BX
    XOR SI,SI
    CALL PRINT_STU_TABLE
    CALL PRINT_ENTER
    JMP READ_CMD
CMD_2:
    CALL PRINT_STU_TABLE_SORTED
    CALL PRINT_ENTER
    JMP READ_CMD
CMD_3:
    CALL PRINT_AVERAGE_SCORE
    CALL PRINT_ENTER
    JMP READ_CMD
CMD_4:
    MOV AH,09H
    LEA DX,C_S
    INT 21H
    LEA DX,SINGLE_OL
    INT 21H
    MOV SI,23
    CALL PRINT_SINGLE_OBJECT_RANK
    CALL PRINT_ENTER
    JMP READ_CMD
CMD_5:
    MOV AH,09H
    LEA DX,M_S
    INT 21H
    LEA DX,SINGLE_OL
    INT 21H
    MOV SI,27
    CALL PRINT_SINGLE_OBJECT_RANK
    CALL PRINT_ENTER
    JMP READ_CMD
CMD_6:
    MOV AH,09H
    LEA DX,E_S
    INT 21H
    LEA DX,SINGLE_OL
    INT 21H
    MOV SI,31
    CALL PRINT_SINGLE_OBJECT_RANK
    CALL PRINT_ENTER
    JMP READ_CMD
CMD_7:
    LEA DX,MENU0
    MOV AH,09H
    INT 21H
    JMP READ_CMD
ERROR_CMD:
    LEA DX,ER_TIP
    MOV AH,09H
    INT 21H
    JMP READ_CMD
;SI选定具体课程,CHINESE = 23,MATH = 27,ENGLISH = 31
PRINT_SINGLE_OBJECT_RANK PROC NEAR
    PUSH BX
    PUSH CX
    PUSH SI
    MOV CX,10
    XOR BX,BX
STR_SCORE_2_NUM_LOOP:
    CALL STR2NUM
    MOV WORD PTR STU_TABLE_SINGLE_SCORE[BX+35],DX
    MOV AX,WORD PTR STU_TABLE_SINGLE_SCORE[BX+35]
    ADD BX,43
    LOOP STR_SCORE_2_NUM_LOOP
    MOV BX,430
    MOV SI,35
    CALL EXCHANGE_SORT
    MOV CX,10
    XOR SI,SI
    XOR BX,BX
GIVE_RANK:
    INC SI
    MOV WORD PTR STU_TABLE_SINGLE_SCORE[BX+38],SI
    ADD BX,43
    LOOP GIVE_RANK
    MOV BX,430
    MOV SI,0
    CALL EXCHANGE_SORT
    CALL PRNIT_STU_TABLE_SINGLE_SCORE
    POP SI
    POP CX
    POP BX
    RET
PRINT_SINGLE_OBJECT_RANK ENDP

PRNIT_STU_TABLE_SINGLE_SCORE PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    MOV CX,10
    XOR BX,BX
PRNIT_STU_TABLE_SINGLE_SCORE_LOOP:
    XOR AX,AX
    MOV AL,STU_TABLE_SINGLE_SCORE[BX]
    CALL DECIMAL_PRINT
    CMP AL,10
    JE BLANK_DEC
    PUSH CX
    MOV CX,5
CX_DEC_RET:
    CALL PRINT_BLANK
    POP CX
    MOV AX,WORD PTR STU_TABLE_SINGLE_SCORE[BX+35]
    CALL DECIMAL_PRINT
    PUSH CX
    MOV CX,7
    CALL PRINT_BLANK
    POP CX
    MOV AX,WORD PTR STU_TABLE_SINGLE_SCORE[BX+38]
    CALL DECIMAL_PRINT
    ADD BX,43
    CALL PRINT_ENTER
    LOOP PRNIT_STU_TABLE_SINGLE_SCORE_LOOP
    POP SI
    POP CX
    POP BX
    POP AX
    RET
BLANK_DEC:
    PUSH CX
    MOV CX,4
    JMP CX_DEC_RET
PRNIT_STU_TABLE_SINGLE_SCORE ENDP

PRINT_STU_TABLE_SORTED PROC NEAR
    PUSH BX
    PUSH SI
    XOR BX,BX
    MOV SI,41
    CALL EXCHANGE_SORT
    MOV BX,430
    CALL PRINT_STU_TABLE
    POP SI
    POP BX
    RET
PRINT_STU_TABLE_SORTED ENDP

;交换排序
;排序对象 STU_TABLE[BX][SI]
EXCHANGE_SORT PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    MOV CX,9
    MOV DX,9
SORT_MAIN:
    PUSH CX
    MOV CX,DX
EXCHANGE_MAIN:
    CMP SI,0
    JE DESC_SORT
    MOV AX,WORD PTR STU_TABLE_SORTED[BX][SI]
    CMP AX,WORD PTR STU_TABLE_SORTED[BX+43][SI]
    JL EXCHANGE
AFTER_CMP:
    ADD BX,43
    LOOP EXCHANGE_MAIN
    CMP BX,430
    JG UBX
    XOR BX,BX
UBX_RET:
    DEC	DX
    POP CX
    LOOP SORT_MAIN
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
EXCHANGE:
    CALL SWAP
    JMP AFTER_CMP
UBX:
    MOV BX,430
    JMP UBX_RET
DESC_SORT:
    XOR AX,AX
    MOV AL,BYTE PTR STU_TABLE_SORTED[BX][SI]
    CMP AL,BYTE PTR STU_TABLE_SORTED[BX+43][SI]
    JG EXCHANGE
    JMP AFTER_CMP
EXCHANGE_SORT ENDP

;SWAP(STU_TABLE_SORTED[BX][SI],STU_TABLE_SORTED[BX+43][SI])
SWAP PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    MOV CX,43
    XOR SI,SI
;TMP = FIR
MOV_FIR_TO_TMP:
    MOV AL,STU_TABLE_SORTED[BX][SI]
    MOV TMP[SI],AL
    INC SI
    LOOP MOV_FIR_TO_TMP
    MOV CX,43
    XOR SI,SI
;FIR = SEC
MOV_SEC_TO_FIR:
    MOV AL,STU_TABLE_SORTED[BX+43][SI]
    MOV STU_TABLE_SORTED[BX][SI],AL
    INC SI
    LOOP MOV_SEC_TO_FIR
    MOV CX,43
    XOR SI,SI
;SEC = TMP
MOV_TMP_TO_SEC:
    MOV AL,TMP[SI]
    MOV STU_TABLE_SORTED[BX+43][SI],AL
    INC SI
    LOOP MOV_TMP_TO_SEC
    POP SI
    POP CX
    POP BX
    POP AX
    RET
SWAP ENDP

PRINT_AVERAGE_SCORE PROC NEAR
    PUSH AX
    PUSH DX
    PUSH SI
    ;语文平均成绩
    LEA DX,CHINESE
    MOV AH,09H
    INT 21H
    MOV SI,23
    CALL GET_AVERAGE
    MOV DH,AH
    XOR AH,AH
    CALL DECIMAL_PRINT
    CALL PRINT_FLOAT
    CALL PRINT_ENTER
    ;数学平均成绩
    LEA DX,MATH
    MOV AH,09H
    INT 21H
    MOV SI,27
    CALL GET_AVERAGE
    MOV DH,AH
    XOR AH,AH
    CALL DECIMAL_PRINT
    CALL PRINT_FLOAT
    CALL PRINT_ENTER
    ;英语平均成绩
    LEA DX,ENGLISH
    MOV AH,09H
    INT 21H
    MOV SI,31
    CALL GET_AVERAGE
    MOV DH,AH
    XOR AH,AH
    CALL DECIMAL_PRINT
    CALL PRINT_FLOAT
    CALL PRINT_ENTER
    POP SI
    POP DX
    POP AX
    RET
PRINT_AVERAGE_SCORE ENDP

PRINT_FLOAT PROC NEAR
    PUSH AX
    PUSH DX
    MOV DL,'.'
    MOV AH,02H
    INT 21H
    MOV DL,DH
    ADD DL,30H
    MOV AH,02H
    INT 21H
    POP DX
    POP AX
    RET
PRINT_FLOAT ENDP

;RET AX = 平均成绩
;INPUT = SI
GET_AVERAGE PROC NEAR
    PUSH BX
    PUSH SI
    PUSH CX
    XOR AX,AX
    XOR BX,BX
    MOV CX,10
GET_AVERAGE_BEG:
    CALL STR2NUM
    ADD AX,DX
    ADD BX,43
    LOOP GET_AVERAGE_BEG
    MOV BL,10
    DIV BYTE PTR BL
    POP CX
    POP SI
    POP BX
    RET
GET_AVERAGE ENDP

;求总分
GET_TOTAL PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    MOV CX,10
    XOR BX,BX
    XOR SI,SI
GET_TOTAL_LOOP:
    MOV SI,23
    CALL STR2NUM
    MOV AX,DX
    MOV SI,27
    CALL STR2NUM
    ADD AX,DX
    MOV SI,31
    CALL STR2NUM
    ADD AX,DX
    MOV WORD PTR STU_TABLE[BX+41],AX
    MOV WORD PTR STU_TABLE_SORTED[BX+41],AX
    MOV WORD PTR STU_TABLE_SINGLE_SCORE[BX+41],AX
    ADD BX,43
    LOOP GET_TOTAL_LOOP
    POP SI
    POP CX
    POP BX
    POP AX
    RET
GET_TOTAL ENDP

;BX,SI为输入
;DX为输出
STR2NUM PROC NEAR
    PUSH AX
    PUSH CX
    PUSH SI
    XOR AX,AX
    XOR DX,DX
    XOR CX,CX
STR2NUM_BEG:
    MOV BYTE PTR AL,STU_TABLE[BX][SI]
    CMP AL,'$'
    JE STR2NUM_END
    SUB AL,30H
    XCHG AX,CX
    MUL WORD PTR DEC_BASE
    XCHG AX,CX
    ADD CX,AX
    INC SI
    JMP STR2NUM_BEG
STR2NUM_END:
    PUSH CX
    POP DX
    POP SI
    POP CX
    POP AX
    RET
STR2NUM ENDP

;显示菜单
PRINT_MENU PROC NEAR
    PUSH AX
    PUSH DX
    LEA DX,MENU0
    MOV AH,09H
    INT 21H
    POP DX
    POP AX
    RET
PRINT_MENU ENDP

PRINT_STU_TABLE PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    XOR DI,DI
    CMP BX,430
    JNE PST_BX
    JE PRINT_RANK_OUTLINE
PST_BX_RET:
    LEA DX,OUTLINE
    MOV AH,09H
    INT 21H
    JMP RBX_END
PRINT_RANK_OUTLINE:
    LEA DX,OUTLINE_RANK
    MOV AH,09H
    INT 21H
RBX_END:
    MOV CX,10
PRINT_STU_TABLE_LOOP:
    CMP BX,430
    JGE PRINT_RANK
PRINT_RANK_END:
    PUSH DI
    XOR SI,SI
    ;打印ID
    XOR AX,AX
    MOV AL,STU_TABLE[BX][SI]
    XOR AH,AH
    MOV DI,AX
    CALL DECIMAL_PRINT
    PUSH CX
    MOV CX,5
    CALL PRINT_BLANK
    POP CX
    ;打印名字
    LEA DX,STU_TABLE[BX][SI+2]
    MOV AH,09H
    INT 21H
    PUSH CX
    MOV CX,9
    CALL PRINT_BLANK
    POP CX
    ;打印语文成绩
    LEA DX,STU_TABLE[BX][SI+23]
    INT 21H
    PUSH CX
    MOV CX,9
    CALL PRINT_BLANK
    POP CX
    ;打印数学成绩
    LEA DX,STU_TABLE[BX][SI+27]
    INT 21H
    PUSH CX
    MOV CX,8
    CALL PRINT_BLANK
    POP CX
    ;打印英语成绩
    LEA DX,STU_TABLE[BX][SI+31]
    INT 21H
    PUSH CX
    MOV CX,9
    CALL PRINT_BLANK
    POP CX
    ;打印total
    MOV AX,WORD PTR STU_TABLE[BX][SI+41]
    CALL DECIMAL_PRINT
    CALL PRINT_ENTER
    ADD BX,43
    POP DI
    LOOP PRINT_STU_TABLE_LOOP
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PST_BX:
    XOR BX,BX
    JMP PST_BX_RET
PRINT_RANK:
    INC DI
    MOV AX,DI
    CALL DECIMAL_PRINT
    PUSH CX
    MOV CX,6
    CALL PRINT_BLANK
    POP CX
    JMP PRINT_RANK_END
PRINT_STU_TABLE ENDP

;CX = 空格个数
PRINT_BLANK PROC NEAR
    PUSH AX
    PUSH CX
    PUSH DX
    CMP DI,10
    JE REVISE_CX
PRINT_BLANK_LOOP:
    MOV DL,' '
    MOV AH,02H
    INT 21H
    LOOP PRINT_BLANK_LOOP
    POP DX
    POP CX
    POP AX
    RET
REVISE_CX:
    DEC CX
    XOR DI,DI
    JMP PRINT_BLANK_LOOP
PRINT_BLANK ENDP

INPUT_INFORMATION PROC NEAR
    PUSH BX
    XOR BX,BX
    CALL INPUT_NAME
    CALL INPUT_SCORE
INPUT_END:
    POP BX
    RET
INPUT_INFORMATION ENDP

;void
INPUT_NAME PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    MOV CX,10
NEXT_NAME:
    ADD BYTE PTR ID,1
    XOR SI,SI
    MOV AH,ID
    MOV STU_TABLE[BX][SI],AH
    MOV STU_TABLE_SORTED[BX][SI],AH
    MOV STU_TABLE_SINGLE_SCORE[BX][SI],AH
    ADD SI,2
    LEA DX,IN_NAME
    MOV AH,9
    INT 21H
KEEP_IN:
    MOV AH,1
    INT 21H
    CMP AL,0DH
    JE INPUT_ENTER
    MOV STU_TABLE[BX][SI],AL
    MOV STU_TABLE_SORTED[BX][SI],AL
    MOV STU_TABLE_SINGLE_SCORE[BX][SI],AL
    INC SI
    JNE KEEP_IN
INPUT_ENTER:
    ADD BX,43
    LOOP NEXT_NAME
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
INPUT_NAME ENDP

INPUT_SCORE PROC NEAR
    PUSH AX
    PUSH CX
    PUSH BX
    PUSH DX
    PUSH SI
    MOV CX,10
    XOR BX,BX
LOOP_FOR_INPUT_SCORE:
    ;打印学号
    XOR SI,SI
    LEA DX,STR_ID
    MOV AH,09H
    INT 21H
    XOR AX,AX
    MOV AL,STU_TABLE[BX][SI]
    CALL DECIMAL_PRINT
    ;打印名字
    LEA DX,STR_NAME
    MOV AH,09H
    INT 21H
    ADD SI,2
    LEA DX,STU_TABLE[BX][SI]
    MOV AH,09H
    INT 21H
    CALL PRINT_ENTER
    ;开始输入成绩
    LEA DX,IN_CHINESE
    MOV AH,09H
    INT 21H
    MOV SI,23
    CALL INPUT_SINGLE_SCORE
    MOV SI,27
    LEA DX,IN_MATH
    INT 21H
    CALL INPUT_SINGLE_SCORE
    MOV SI,31
    LEA DX,IN_ENGLISH
    INT 21H
    CALL INPUT_SINGLE_SCORE
    ADD BX,43
    LOOP LOOP_FOR_INPUT_SCORE
    POP SI
    POP DX
    POP BX
    POP CX
    POP AX
    RET
INPUT_SCORE ENDP

;BX = 行，SI = 位置
INPUT_SINGLE_SCORE PROC NEAR
    PUSH AX
    PUSH BX
    PUSH SI
INPUT_SINGLE_SCORE_START:
    MOV AH,01H
    INT 21H
    CMP AL,0DH
    JE INPUT_SINGLE_SCORE_END
    MOV STU_TABLE[BX][SI],AL
    MOV STU_TABLE_SORTED[BX][SI],AL
    MOV STU_TABLE_SINGLE_SCORE[BX][SI],AL
    INC SI
    JMP INPUT_SINGLE_SCORE_START
INPUT_SINGLE_SCORE_END:
    POP SI
    POP BX
    POP AX
    RET
INPUT_SINGLE_SCORE ENDP
;换行
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

;agrs AX = 以十进制打印的目标内容
;void
DECIMAL_PRINT PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    OR AX,AX
    JZ ZERO
    MOV BX,-1
    PUSH BX
    MOV BX,10
LOOP_RE: 
    XOR DX,DX
    DIV BX
    MOV CX,AX
    OR CX,DX
    JZ PRINT_EXIT
    PUSH DX
    JMP LOOP_RE
ZERO:   
    MOV DL,30H
    MOV AH,02H
    INT 21H
PRINT_EXIT:
    POP DX
    CMP DX,-1
    JE EXIT_PRINT_DEC
    ADD DX,30H
    MOV AH,02H
    INT 21H
    JMP PRINT_EXIT
EXIT_PRINT_DEC:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DECIMAL_PRINT ENDP

CODES ENDS
END START