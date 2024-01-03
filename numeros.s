.global main
main:
    LDR R0,=filename        
    MOV R1, #0
    MOV R2, #0
    MOV R7, #5
    SVC 0

    LDR R1, =bufferascii
    MOV R2, #6
    MOV R7, #3
    SVC 0

    MOV R7, #6
    SVC 0

    LDR R4, =bufferascii
    MOV R5, #0
    MOV R6, #10

loop:
    LDRB R0, [R4], #1
    CMP R0, #0
    BEQ end
    CMP R0, #10 
    BEQ enter
    SUB R0, R0, #48 
    MUL R1, R5, R6
    ADD R5, R0, R1
    B loop

enter:
    LDR R0, =pattern
    MOV R1, R5
    BL printf

    MOV R5, #0 
    B loop
end:
    MOV R0, #0
    MOV R7, #1
    SVC 0

.data
filename: .asciz "test01.txt" 
pattern: .asciz "num: %d\n" 
bufferascii: .asciz