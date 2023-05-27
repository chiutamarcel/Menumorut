    DOSSEG
    .MODEL SMALL
    .STACK 32
    .DATA
encoded     DB  80 DUP(0)
temp        DB  '0x', 160 DUP(0)
fileHandler DW  ?
filename    DB  'in/in.txt', 0          ; Trebuie sa existe acest fisier 'in/in.txt'!
outfile     DB  'out/out.txt', 0        ; Trebuie sa existe acest director 'out'!
message     DB  80 DUP(0)
msglen      DW  ?
padding     DW  0
iterations  DW  0 
x           DW  ?
x0          DW  ?
nume        DB  "Chiuta$"
prenume     DB  "Mihai$"
a           DW  ?
b           DW  ?
TABEL       DB  "Bqmgp86CPe9DfNz7R1wjHIMZKGcYXiFtSU2ovJOhW4ly5EkrqsnAxubTV03a=L/d"
padCount    DB  ?
    .CODE
START:
    MOV     AX, @DATA
    MOV     DS, AX

    CALL    FILE_INPUT                  ; NU MODIFICATI!

    ; calculate b
    MOV     SI, OFFSET nume
    CALL    SUM_NAME
    MOV     [b], AX

    ; calculate a
    MOV     SI, OFFSET prenume
    CALL    SUM_NAME
    MOV     [a], AX
    
    CALL    SEED                        ; TODO - Trebuie implementata

    CALL    ENCRYPT                     ; TODO - Trebuie implementata
    
    CALL    ENCODE                      ; TODO - Trebuie implementata
    
                                        ; Mai jos se regaseste partea de
                                        ; afisare pe baza valorilor care se
                                        ; afla in variabilele x0, a, b, respectiv
                                        ; in sirurile message si encoded.
                                        ; NU MODIFICATI!
    MOV     AH, 3CH                     ; BIOS Int - Open file
    MOV     CX, 0
    MOV     AL, 1                       ; AL - Access mode ( Write - 1 )
    MOV     DX, OFFSET outfile          ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    CALL    WRITE                       ; NU MODIFICATI!

    MOV     AH, 4CH                     ; Bios Int - Terminate with return code
    MOV     AL, 0                       ; AL - Return code
    INT     21H
FILE_INPUT:
    MOV     AH, 3DH                     ; BIOS Int - Open file
    MOV     AL, 0                       ; AL - Access mode ( Read - 0 )
    MOV     DX, OFFSET fileName         ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    MOV     AH, 3FH                     ; BIOD Int - Read from file or device
    MOV     BX, [fileHandler]           ; BX - File handler
    MOV     CX, 80                      ; CX - Number of bytes to read
    MOV     DX, OFFSET message          ; DX - Data buffer
    INT     21H
    MOV     [msglen], AX                ; Return: AX - number of read bytes

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H

    RET
SEED:
    MOV     AH, 2CH                     ; BIOS Int - Get System Time
    INT     21H

    ; uncomment for testing
    ; MOV     CH, 17H
    ; MOV     CL, 3BH
    ; MOV     DH, 3BH
    ; MOV     DL, 63H

    CALL    CALC_X0                     ; TODO1 [DONE]: Completati subrutina SEED
    MOV     SI, OFFSET x0               ; astfel incat la final sa fie salvat
    MOV     DI, OFFSET x                ; in variabila 'x' si 'x0' continutul 
    MOV     AX, [x0]                    ; termenului initial
    MOV     [x], AX

    RET
ENCRYPT:
    MOV     CX, [msglen]
    MOV     SI, OFFSET message
; TODO3 [DONE]: Completati subrutina ENCRYPT
; astfel incat in cadrul buclei sa fie
; XOR-at elementul curent din sirul de
; intrare cu termenul corespunzator din
; sirul generat, iar mai apoi sa fie generat
; si termenul urmator

    XOR_CHR_LOOP:
        MOV AL, [SI]
        MOV BX, x
        XOR AL, BL
        MOV AH, 0
        MOV [SI], AL
        CALL RAND
        INC SI
    LOOP XOR_CHR_LOOP

    MOV [x], DX     ; put x_(n-1) back into it's place


    RET
RAND:
; TODO2 [DONE]: Completati subrutina RAND, astfel incat
; in cadrul acesteia va fi calculat termenul
; de rang n pe baza coeficientilor a, b si a 
; termenului de rang inferior (n-1) si salvat
; in cadrul variabilei 'x'
    PUSH    SI

    MOV     AX, [x]                         ; read x_(n-1)
    MOV     DX, [x]                         ; save a copy of x_(n-1)

    MOV     SI, OFFSET a                    ; a * x
    MOV     BX, [SI]                        ; 
    MUL     BL                              ;
                                            
    MOV     SI, offset b                    ; + b
    MOV     BX, [SI]                        ; 
    ADD     AX, BX                          ;

    MOV     BL, 255                         ; mod 255
    DIV     BL                              ;
    MOV     AL, AH                          ;
    MOV     AH, 0                           ;

    MOV     [x], AX                         ; save x_n

    POP     SI

    RET
ENCODE:
; TODO4 [DONE]: Completati subrutina ENCODE, astfel incat
; in cadrul acesteia va fi realizata codificarea
; sirului criptat pe baza alfabetului COD64 mentionat
; in enuntul problemei si rezultatul va fi stocat
; in cadrul variabilei encoded

    ; padCount = ( 3 - msglen % 3 ) % 3
    ; AH = msglen % 3
    MOV     AX, msglen
    MOV     BL, 3
    DIV     BL
    ; BL = msglen % 3, AL = 3 - msglen % 3
    MOV     BL, AH
    MOV     AL, 3
    SUB     AL, BL
    ; AH = ( 3 - msglen % 3 ) % 3
    MOV     AH, 0
    MOV     BL, 3
    DIV     BL
    ; padCount = AH
    MOV     padCount, AH

    MOV     SI, OFFSET iterations
    MOV     DI, OFFSET msglen
    
    ; AL = msglen DIV 3
    MOV     AX, msglen
    ;ADD     AX, BX
    MOV     BL, 3
    DIV     BL

    ; if ( msglen MOD 3 != 0 ) iterations = msglen DIV 3 + 1 else iterations = msglen DIV 3
    MOV     [SI], AL

    CMP     AH, 0
    JZ     DONT_ADD
    ADD     [SI], 1
    DONT_ADD:
    ;

    MOV     CX, iterations

    MOV     SI, OFFSET message
    MOV     DI, OFFSET encoded

    ENCODE_LOOP:
    ; T0
    MOV     AL, 11111100B   ; mask
    
    MOV     AH, 0
    AND     AL, [SI]
    SHR     AL, 2

    CALL    WRITE_FROM_TABEL
    INC     DI
    ;

    ; T1
    MOV     AL, 00000011B   ; mask1
    MOV     AH, 11110000B   ; mask2

    AND     AL, [SI]
    SHL     AL, 4

    AND     AH, [SI+1]
    SHR     AH, 4

    OR      AL, AH

    CALL    WRITE_FROM_TABEL
    INC     DI
    ;

    ; T2
    MOV     AL, 00001111B   ; mask1
    MOV     AH, 11000000B   ; mask2

    AND     AL, [SI+1]
    SHL     AL, 2

    AND     AH, [SI+2]
    SHR     AH, 6

    OR      AL, AH

    CALL    WRITE_FROM_TABEL
    INC     DI
    ;

    ; T3
    MOV     AL, 00111111B   ; mask
    
    AND     AL, [SI+2]

    CALL    WRITE_FROM_TABEL
    INC     DI
    ;

    ADD     SI, 3
    LOOP ENCODE_LOOP

    ; replace  "false Bs" with +
    MOV     SI, OFFSET encoded
    ; AX = iterations * 4
    MOV     AX, iterations
    MOV     BL, 4
    MUL     BL
    ; CX = padCount
    MOV     CL, padCount
    MOV     CH, 0

    CMP     CX, 0
    JZ      SKIP_PADDING

    ADD     SI, AX
    SUB     SI, CX
    
    REPLACE_FALSE_B:
        MOV [SI], '+'
        INC SI
    LOOP REPLACE_FALSE_B

    SKIP_PADDING:

    RET
WRITE_HEX:
    MOV     DI, OFFSET temp + 2
    XOR     DX, DX
DUMP:
    MOV     DL, [SI]
    PUSH    CX
    MOV     CL, 4

    ROR     DX, CL
    
    CMP     DL, 0ah
    JB      print_digit1

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     next_digit

print_digit1:  
    OR      DL, 30h
    MOV     byte ptr [DI] ,DL
next_digit:
    INC     DI
    MOV     CL, 12
    SHR     DX, CL
    CMP     DL, 0ah
    JB      print_digit2

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     AGAIN

print_digit2:    
    OR      DL, 30h
    MOV     byte ptr [DI], DL
AGAIN:
    INC     DI
    INC     SI
    POP     CX
    LOOP    dump
    
    MOV     byte ptr [DI], 10
    RET
WRITE:
    MOV     SI, OFFSET x0
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21h

    MOV     SI, OFFSET a
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET b
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET x
    MOV     CX, 1
    CALL    WRITE_HEX    
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET message
    MOV     CX, [msglen]
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, [msglen]
    ADD     CX, [msglen]
    ADD     CX, 3
    INT     21h

    MOV     AX, [iterations]
    MOV     BX, 4
    MUL     BX
    MOV     CX, AX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET encoded
    INT     21H

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H
    RET
CALC_X0:
    MOV     SI, OFFSET x0
    MOV     [SI], 00H

    ; CH * 3600
    
    MOV     AL, CH
    MOV     BL, 30 ; 3600 % 255 = 30 pt calcul mai usor
    
    MUL     BL

    ADD     [SI], AX

    ; + CL * 60

    MOV     AL, CL
    MOV     BL, 60
    
    MUL     BL

    ADD     [SI], AX

    ; + DH

    ADD     [SI], DH

    ; mod 255

    MOV     AX, [SI]
    MOV     BL, 255
    DIV     BL

    ; * 100

    MOV     AL, 0
    MOV     AL, AH
    MOV     BL, 100
    MUL     BL

    ; mod 255

    MOV     BL, 255
    DIV     BL
    MOV     AL, 0
    MOV     AL, AH
    MOV     AH, 0

    ; + DL

    MOV     BL, DL
    MOV     BH, 0
    ADD     AX, BX
    MOV     [SI], AX

    ; mod 255

    MOV     AX, [SI]
    MOV     BL, 255
    DIV     BL
    MOV     AL, 0
    MOV     AL, AH
    MOV     AH, 0
    MOV     [SI], AX

    RET
; SI - index in message, DI - index in encoded, AL - mask
WRITE_FROM_TABEL:
    PUSH    SI
    MOV     SI, OFFSET TABEL
    MOV     AH, 0
    ADD     SI, AX
    MOV     AL, [SI]
    MOV     [DI], AL
    POP     SI
    RET

; in: SI - nume/prenume; out: AX - a/b ( result )
SUM_NAME:
    PUSH SI
    PUSH BX

    MOV AX, 0

    LOOP_SUM_NAME:
    
    ; STOP IF nume[i] == $
    CMP BYTE PTR [SI], '$'
    JZ  END_LOOP_SUM_NAME

    ; ADD nume[i] to result
    MOV BH, 0
    MOV BL, BYTE PTR [SI]
    ADD AX, BX

    ; DIV 255
    MOV BL, 255
    DIV BL
    MOV AL, 0
    MOV AL, AH
    MOV AH, 0

    INC SI
    JMP LOOP_SUM_NAME
    END_LOOP_SUM_NAME:

    POP BX
    POP SI
    RET
END START