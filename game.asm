.MODEL SMALL
.STACK 400h

.DATA

    ; ------------ CONFIGURACAO ------------

    SCREEN_W EQU 620
    SCREEN_H EQU 600

    VIDEO_MODE EQU 0103h
    
    ; -------------- CORES ----------------

    COR_VERDE_CLARO EQU 0Ah

    ; ---------------- TITULO -----------
    
    LINHAS_RESTANTES_TEXTO_TITULO DB 5
    TEXTO_TITULO LABEL BYTE

    DB 'm    m                             mmmmm           m                  ""#   ',0
    DB '##  ##  mmm    mmm   m mm          #   "#  mmm   mm#mm   m mm   mmm     #   ',0
    DB '# ## # #" "#  #" "#  #"  #         #mmm#" "   #    #     #"  " #" "#    #   ',0
    DB '# "" # #   #  #   #  #   #         #      m"""#    #     #     #   #    #   ',0
    DB '#    # "#m#"  "#m#"  #   #         #      "mm"#    "mm   #     "#m#"    "mm ',0

.CODE

    MAIN PROC

        MOV AX, SEG TEXTO_TITULO
        MOV DS, AX

        ; Configura modo grafico VESA 800x600
        MOV AX, 4F02h
        MOV BX, VIDEO_MODE
        INT 10h

        ; Verifica se o modo foi configurado
        CMP AX, 004Fh
        JNE ERRO_VIDEO

        CALL DESENHA_TITULO

        ; Aguarda uma tecla
        MOV AH, 00h
        INT 16h

        ; Volta para modo texto
        MOV AX, 0003h
        INT 10h

        MOV AX, 4C00h
        INT 21h

    ERRO_VIDEO:

        MOV AX, 0003h
        INT 10h

        MOV AX, 4C01h
        INT 21h

    MAIN ENDP


    ; ------------------------------
    ; ESCREVE_TEXTO
    ;
    ; DS:SI = endereco do texto
    ; DH    = linha
    ; BL    = cor
    ; ------------------------------

    ESCREVE_TEXTO PROC NEAR

        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI

        XOR CX, CX
        MOV DI, SI

        
        CALCULA_TAMANHO: ; Calcula o tamanho do texto
            CMP BYTE PTR [DI], 0
            JE PREPARA_IMPRESSAO

            INC DI
            INC CX

            JMP CALCULA_TAMANHO


        PREPARA_IMPRESSAO:
        
            MOV AX, SCREEN_W / 8 ; Centraliza o texto principal
            SUB AX, CX
            SHR AX, 1

            ; Inicio da area logica: 90 pixels
            ADD AX, 11

            ; Coluna inicial
            MOV DL, AL

            ; Posiciona cursor
            MOV AH, 02h
            XOR BH, BH
            INT 10h
        
        IMPRIME_CARACTERE: ; Imprime caracteres
            LODSB

            CMP AL, 0
            JE FINALIZA_IMPRESSAO

            MOV AH, 0Eh
            XOR BH, BH
            MOV BL, COR_VERDE_CLARO
            INT 10h

            JMP IMPRIME_CARACTERE


            FINALIZA_IMPRESSAO:

            POP DI
            POP SI
            POP DX
            POP CX
            POP BX
            POP AX

            RET

    ESCREVE_TEXTO ENDP
    

    ; ------------------------------
    ; DESENHA_TITULO
    ; ------------------------------

    DESENHA_TITULO PROC NEAR

        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI

        MOV SI, OFFSET TEXTO_TITULO
        
        MOV DH, 2 ; Margin TOP
        MOV BL, COR_VERDE_CLARO ; Cor verde claro

        DT_LOOP:
        
            CALL ESCREVE_TEXTO ; Avanca para proxima string
        DT_NEXT:

            CMP BYTE PTR [SI], 0
            JE DT_ADVANCE

            INC SI
            JMP DT_NEXT

        DT_ADVANCE:

            INC SI
            INC DH

            DEC LINHAS_RESTANTES_TEXTO_TITULO
            JNZ DT_LOOP

            POP SI
            POP DX
            POP CX
            POP BX
            POP AX

            RET

    DESENHA_TITULO ENDP

END MAIN
