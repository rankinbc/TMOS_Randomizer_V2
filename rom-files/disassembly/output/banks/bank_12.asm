; ============================================================================
; The Magic of Scheherazade - Bank 12 Disassembly
; ============================================================================
; File Offset: 0x18000 - 0x19FFF
; CPU Address: $8000 - $9FFF
; Size: 8192 bytes (8 KB)
; ============================================================================
;
; NOTE: This is a raw disassembly. Data regions interpreted as code will
; appear as garbage instructions. Further analysis needed to identify
; code vs data boundaries.
;
; ============================================================================

; da65 V2.19 - Git 034f73a
; Created:    2026-01-24 04:39:28
; Input file: C:/claude-workspace/TMOS_AI/rom-files/disassembly/output/banks/bank_12.bin
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
L003E           := $003E
L061C           := $061C
L0D88           := $0D88
PPU_CTRL        := $2000
PPU_MASK        := $2001
PPU_STATUS      := $2002
OAM_ADDR        := $2003
OAM_DATA        := $2004
PPU_SCROLL      := $2005
PPU_ADDR        := $2006
PPU_DATA        := $2007
L2010           := $2010
L2712           := $2712
L3D7E           := $3D7E
OAM_DMA         := $4014
APU_STATUS      := $4015
JOY1            := $4016
JOY2_FRAME      := $4017
L666C           := $666C
LA1F0           := $A1F0
LA239           := $A239
LA347           := $A347
LA3A5           := $A3A5
LA625           := $A625
LB4DD           := $B4DD
LB4F1           := $B4F1
LB541           := $B541
LB5E1           := $B5E1
LC498           := $C498
LDE93           := $DE93
LE019           := $E019
LE01B           := $E01B
LE01D           := $E01D
LE02F           := $E02F
LE031           := $E031
LE035           := $E035
LE03F           := $E03F
LE076           := $E076
LE078           := $E078
LE07A           := $E07A
LE07E           := $E07E
LE080           := $E080
LE082           := $E082
LE086           := $E086
LE08C           := $E08C
LE090           := $E090
LE092           := $E092
LE094           := $E094
LE096           := $E096
LE098           := $E098
LE09A           := $E09A
LE09C           := $E09C
LE09E           := $E09E
LE0A0           := $E0A0
LE0A4           := $E0A4
LE0AF           := $E0AF
LE0B1           := $E0B1
LE0B7           := $E0B7
LE0BD           := $E0BD
LE0BF           := $E0BF
LE0C3           := $E0C3
LE0C5           := $E0C5
LE0C7           := $E0C7
LE0CB           := $E0CB
LE0CD           := $E0CD
LE0D1           := $E0D1
LE0D3           := $E0D3
LE0D5           := $E0D5
LE0DC           := $E0DC
LE17B           := $E17B
LE2C6           := $E2C6
LE328           := $E328
LE33C           := $E33C
LE389           := $E389
LE5AA           := $E5AA
LE5B2           := $E5B2
LE88D           := $E88D
LE891           := $E891
LE898           := $E898
LE89D           := $E89D
LE8A8           := $E8A8
LE8B1           := $E8B1
LE8C8           := $E8C8
LE8EF           := $E8EF
LE95B           := $E95B
LE97D           := $E97D
LE992           := $E992
LE9EB           := $E9EB
LEA7E           := $EA7E
LEA88           := $EA88
LEAB5           := $EAB5
LEAB9           := $EAB9
LEABD           := $EABD
LEACA           := $EACA
LEBFF           := $EBFF
LEC21           := $EC21
LEC71           := $EC71
LEC75           := $EC75
LEC7E           := $EC7E
LEEB3           := $EEB3
LF067           := $F067
LF07B           := $F07B
LF082           := $F082
LF085           := $F085
LF09B           := $F09B
LF0A8           := $F0A8
LF0B2           := $F0B2
LF0B5           := $F0B5
LF0B8           := $F0B8
LF0BE           := $F0BE
LF0FF           := $F0FF
LF11C           := $F11C
LF154           := $F154
LF185           := $F185
LF1C0           := $F1C0
LF2B4           := $F2B4
LF510           := $F510
LF6BA           := $F6BA
LF70B           := $F70B
LF73D           := $F73D
LF747           := $F747
LF765           := $F765
LF785           := $F785
LF79E           := $F79E
LF951           := $F951
LFA29           := $FA29
LFA31           := $FA31
; ----------------------------------------------------------------------------
        eor     ($80,x)                         ; 8000
        brk                                     ; 8002
        brk                                     ; 8003
        sei                                     ; 8004
        txa                                     ; 8005
        cpx     $8A                             ; 8006
        .byte   $F4                             ; 8008
        txa                                     ; 8009
        lda     $8B,x                           ; 800A
        ror     $8C,x                           ; 800C
        .byte   $8B                             ; 800E
        .byte   $97                             ; 800F
        ldy     $97                             ; 8010
        .byte   $0B                             ; 8012
        sta     ($40),y                         ; 8013
        sta     ($E5),y                         ; 8015
        sty     $85,x                           ; 8017
        .byte   $90                             ; 8019
L801A:  .byte   $FF                             ; 801A
        stx     L917D                           ; 801B
        .byte   $33                             ; 801E
        .byte   $92                             ; 801F
        jmp     LC498                           ; 8020

; ----------------------------------------------------------------------------
        lda     ($F0,x)                         ; 8023
        lda     ($39,x)                         ; 8025
        ldx     #$7B                            ; 8027
        ldx     #$75                            ; 8029
        ldx     $A896                           ; 802B
        inc     $AD,x                           ; 802E
        sta     ($95),y                         ; 8030
        brk                                     ; 8032
        brk                                     ; 8033
        brk                                     ; 8034
        brk                                     ; 8035
        brk                                     ; 8036
        brk                                     ; 8037
        ror     $1A97,x                         ; 8038
        ldx     $AE47                           ; 803B
        .byte   $7F                             ; 803E
        ldy     $A560,x                         ; 803F
        ora     $7D20,y                         ; 8042
        sbc     #$68                            ; 8045
        .byte   $80                             ; 8047
        ldx     $80,y                           ; 8048
        rol     a                               ; 804A
        sta     ($8A,x)                         ; 804B
        sta     ($FD,x)                         ; 804D
        sta     ($52,x)                         ; 804F
        .byte   $82                             ; 8051
        .byte   $BF                             ; 8052
        .byte   $82                             ; 8053
        .byte   $F4                             ; 8054
        .byte   $82                             ; 8055
        sec                                     ; 8056
        .byte   $83                             ; 8057
        lsr     L9484,x                         ; 8058
        sty     $DE                             ; 805B
        sta     $00                             ; 805D
        brk                                     ; 805F
        brk                                     ; 8060
        brk                                     ; 8061
        brk                                     ; 8062
        brk                                     ; 8063
        brk                                     ; 8064
        brk                                     ; 8065
        cpx     $86                             ; 8066
L8068:  lda     $0601                           ; 8068
        beq     L809F                           ; 806B
        jsr     L92E2                           ; 806D
        lda     $11                             ; 8070
        cmp     #$06                            ; 8072
        beq     L809E                           ; 8074
L8076:  jsr     LE33C                           ; 8076
        lda     $11                             ; 8079
        cmp     #$06                            ; 807B
        beq     L809E                           ; 807D
        jsr     L90C5                           ; 807F
        jsr     LE0B1                           ; 8082
        jsr     LE094                           ; 8085
        jsr     LEACA                           ; 8088
        lda     $B1                             ; 808B
        and     #$04                            ; 808D
        beq     L809E                           ; 808F
        lda     $2E                             ; 8091
        bne     L809E                           ; 8093
        lda     #$0C                            ; 8095
        sta     $2E                             ; 8097
        lda     #$56                            ; 8099
        jmp     LE992                           ; 809B

; ----------------------------------------------------------------------------
L809E:  rts                                     ; 809E

; ----------------------------------------------------------------------------
L809F:  lda     #$00                            ; 809F
        sta     $AC                             ; 80A1
        lda     #$FF                            ; 80A3
        jsr     LE992                           ; 80A5
        jsr     LE89D                           ; 80A8
        jsr     LE389                           ; 80AB
        beq     L809E                           ; 80AE
        jsr     LF09B                           ; 80B0
        jmp     L8068                           ; 80B3

; ----------------------------------------------------------------------------
        lda     $1A                             ; 80B6
        jsr     LE97D                           ; 80B8
        cmp     ($80,x)                         ; 80BB
        cmp     $80,x                           ; 80BD
        .byte   $FE                             ; 80BF
        .byte   $80                             ; 80C0
L80C1:  jsr     $8A3E                           ; 80C1
        jsr     L87BE                           ; 80C4
L80C7:  jsr     LE09C                           ; 80C7
        jsr     LE8EF                           ; 80CA
        jsr     LEACA                           ; 80CD
        lda     #$01                            ; 80D0
        sta     $1A                             ; 80D2
        rts                                     ; 80D4

; ----------------------------------------------------------------------------
L80D5:  jsr     L880F                           ; 80D5
        beq     L80EB                           ; 80D8
        lda     $93                             ; 80DA
        bne     L80EC                           ; 80DC
        lda     #$08                            ; 80DE
        sta     $21                             ; 80E0
        sta     $2F                             ; 80E2
L80E4:  inc     $1A                             ; 80E4
        lda     #$01                            ; 80E6
        jsr     LE992                           ; 80E8
L80EB:  rts                                     ; 80EB

; ----------------------------------------------------------------------------
L80EC:  lda     $030B                           ; 80EC
        beq     L80EB                           ; 80EF
        jsr     L8A47                           ; 80F1
        bcc     L80EB                           ; 80F4
        ldy     #$00                            ; 80F6
        jsr     L8763                           ; 80F8
        jmp     L80D5                           ; 80FB

; ----------------------------------------------------------------------------
L80FE:  jsr     L880F                           ; 80FE
        beq     L8129                           ; 8101
        lda     #$FF                            ; 8103
        sta     $21                             ; 8105
        lda     $2F                             ; 8107
        bne     L8129                           ; 8109
L810B:  jsr     LE89D                           ; 810B
L810E:  lda     $AB                             ; 810E
        sta     $94                             ; 8110
        inc     $AB                             ; 8112
        jsr     LE2C6                           ; 8114
        jsr     LE8B1                           ; 8117
        lda     $19                             ; 811A
        cmp     #$0B                            ; 811C
        bne     L8125                           ; 811E
        lda     $AB                             ; 8120
        sta     $94                             ; 8122
        rts                                     ; 8124

; ----------------------------------------------------------------------------
L8125:  lda     $94                             ; 8125
        sta     $AB                             ; 8127
L8129:  rts                                     ; 8129

; ----------------------------------------------------------------------------
        lda     $1A                             ; 812A
        jsr     LE97D                           ; 812C
        cmp     ($80,x)                         ; 812F
        and     $81,x                           ; 8131
        sei                                     ; 8133
        .byte   $81                             ; 8134
L8135:  jsr     L880F                           ; 8135
        beq     L8129                           ; 8138
        lda     $030A                           ; 813A
        bne     L8147                           ; 813D
        lda     #$10                            ; 813F
        sta     $21                             ; 8141
        sta     $2F                             ; 8143
        bne     L80E4                           ; 8145
L8147:  lda     $2B                             ; 8147
        bne     L8129                           ; 8149
        lda     #$3C                            ; 814B
        sta     $2B                             ; 814D
        ldy     #$18                            ; 814F
        lda     $0305                           ; 8151
        bne     L815C                           ; 8154
        jsr     L8787                           ; 8156
        jmp     L8170                           ; 8159

; ----------------------------------------------------------------------------
L815C:  jsr     L8878                           ; 815C
        lda     L87BD                           ; 815F
        jsr     LE992                           ; 8162
        lda     L8742,y                         ; 8165
        jsr     L877C                           ; 8168
        lda     #$1E                            ; 816B
        jsr     L887B                           ; 816D
L8170:  lda     #$1E                            ; 8170
        jsr     LE0CD                           ; 8172
        jmp     L8135                           ; 8175

; ----------------------------------------------------------------------------
        jsr     L880F                           ; 8178
        beq     L8129                           ; 817B
        sta     $21                             ; 817D
        lda     $2F                             ; 817F
        bne     L8129                           ; 8181
        sta     $21                             ; 8183
        inc     $AB                             ; 8185
        jmp     L810E                           ; 8187

; ----------------------------------------------------------------------------
        lda     $1A                             ; 818A
        jsr     LE97D                           ; 818C
        sta     $81,x                           ; 818F
        .byte   $9B                             ; 8191
        sta     ($FE,x)                         ; 8192
        .byte   $80                             ; 8194
        jsr     LE0B1                           ; 8195
        jmp     L80C1                           ; 8198

; ----------------------------------------------------------------------------
L819B:  jsr     L880F                           ; 819B
        beq     L81FC                           ; 819E
        lda     $93                             ; 81A0
        bne     L81EA                           ; 81A2
        lda     #$01                            ; 81A4
        jsr     LE992                           ; 81A6
        lda     $03CC                           ; 81A9
        beq     L81B3                           ; 81AC
        lda     $033B                           ; 81AE
        bne     L81DA                           ; 81B1
L81B3:  lda     #$24                            ; 81B3
        jsr     L887B                           ; 81B5
        jsr     L889B                           ; 81B8
        jsr     LF11C                           ; 81BB
        lda     #$36                            ; 81BE
        sta     $0600,y                         ; 81C0
        lda     #$80                            ; 81C3
        sta     $0601,y                         ; 81C5
        lda     #$FF                            ; 81C8
        sta     $0604,y                         ; 81CA
        tya                                     ; 81CD
        tax                                     ; 81CE
        jsr     LE0BD                           ; 81CF
        lda     #$25                            ; 81D2
        jsr     L887B                           ; 81D4
        jmp     L819B                           ; 81D7

; ----------------------------------------------------------------------------
L81DA:  lda     #$06                            ; 81DA
        jsr     L8829                           ; 81DC
        lda     #$08                            ; 81DF
        sta     $21                             ; 81E1
        sta     $2F                             ; 81E3
        inc     $1A                             ; 81E5
        jmp     L80FE                           ; 81E7

; ----------------------------------------------------------------------------
L81EA:  lda     $030B                           ; 81EA
        beq     L81FC                           ; 81ED
        jsr     L8A47                           ; 81EF
        bcc     L81FC                           ; 81F2
        ldy     #$04                            ; 81F4
        jsr     L8763                           ; 81F6
        jmp     L819B                           ; 81F9

; ----------------------------------------------------------------------------
L81FC:  rts                                     ; 81FC

; ----------------------------------------------------------------------------
        lda     $1A                             ; 81FD
        jsr     LE97D                           ; 81FF
        sta     $81,x                           ; 8202
        php                                     ; 8204
        .byte   $82                             ; 8205
        sei                                     ; 8206
        .byte   $81                             ; 8207
L8208:  jsr     L880F                           ; 8208
        beq     L81FC                           ; 820B
        lda     $030A                           ; 820D
        bne     L821B                           ; 8210
        lda     #$10                            ; 8212
        sta     $21                             ; 8214
        sta     $2F                             ; 8216
        jmp     L80E4                           ; 8218

; ----------------------------------------------------------------------------
L821B:  cmp     #$78                            ; 821B
        beq     L81FC                           ; 821D
        lda     $33                             ; 821F
        cmp     #$0C                            ; 8221
        bcc     L8229                           ; 8223
        cmp     #$0F                            ; 8225
        bcc     L8231                           ; 8227
L8229:  lda     $2B                             ; 8229
        bne     L81FC                           ; 822B
        lda     #$28                            ; 822D
        sta     $2B                             ; 822F
L8231:  lda     #$27                            ; 8231
        jsr     L887B                           ; 8233
        lda     $E0                             ; 8236
        and     #$0F                            ; 8238
L823A:  sec                                     ; 823A
        sbc     #$06                            ; 823B
        bcs     L823A                           ; 823D
        adc     #$06                            ; 823F
        ora     #$88                            ; 8241
        sta     $030B                           ; 8243
        lda     #$03                            ; 8246
        sta     $25                             ; 8248
        lda     #$28                            ; 824A
        jsr     L887B                           ; 824C
        jmp     L8208                           ; 824F

; ----------------------------------------------------------------------------
        lda     $1A                             ; 8252
        jsr     LE97D                           ; 8254
        .byte   $5B                             ; 8257
        .byte   $82                             ; 8258
        .byte   $7B                             ; 8259
        .byte   $82                             ; 825A
        jsr     L80C1                           ; 825B
        lda     $03C6                           ; 825E
        beq     L8268                           ; 8261
        lda     $0338                           ; 8263
        bne     L8270                           ; 8266
L8268:  lda     #$2B                            ; 8268
        jsr     L887B                           ; 826A
        jmp     L80C7                           ; 826D

; ----------------------------------------------------------------------------
L8270:  lda     #$2C                            ; 8270
        jsr     L887B                           ; 8272
        jsr     LF185                           ; 8275
        jmp     L80C7                           ; 8278

; ----------------------------------------------------------------------------
L827B:  jsr     L880F                           ; 827B
        beq     L82AC                           ; 827E
        lda     $93                             ; 8280
        bne     L82AD                           ; 8282
        lda     #$01                            ; 8284
        jsr     LE992                           ; 8286
        lda     #$04                            ; 8289
        sta     $2F                             ; 828B
L828D:  lda     $7F                             ; 828D
        and     #$07                            ; 828F
        bne     L8296                           ; 8291
        jsr     LF085                           ; 8293
L8296:  jsr     LF0B2                           ; 8296
        lda     $2F                             ; 8299
        bne     L828D                           ; 829B
        lda     #$40                            ; 829D
        sta     $BC                             ; 829F
        inc     $19                             ; 82A1
        lda     #$00                            ; 82A3
        sta     $1A                             ; 82A5
        lda     #$80                            ; 82A7
        sta     $030B                           ; 82A9
L82AC:  rts                                     ; 82AC

; ----------------------------------------------------------------------------
L82AD:  lda     $030B                           ; 82AD
        beq     L82AC                           ; 82B0
        lda     #$00                            ; 82B2
        sta     $030B                           ; 82B4
        ldy     #$08                            ; 82B7
        jsr     L8763                           ; 82B9
        jmp     L827B                           ; 82BC

; ----------------------------------------------------------------------------
        lda     $1A                             ; 82BF
        jsr     LE97D                           ; 82C1
        cpy     $80                             ; 82C4
        dex                                     ; 82C6
        .byte   $82                             ; 82C7
        sei                                     ; 82C8
        .byte   $81                             ; 82C9
L82CA:  jsr     L880F                           ; 82CA
        beq     L82AC                           ; 82CD
        lda     $030A                           ; 82CF
        bne     L82E1                           ; 82D2
        lda     #$10                            ; 82D4
        sta     $21                             ; 82D6
        sta     $2F                             ; 82D8
        lda     #$40                            ; 82DA
        sta     $030B                           ; 82DC
        bne     L82F1                           ; 82DF
L82E1:  lda     $2B                             ; 82E1
        bne     L82AC                           ; 82E3
        lda     #$28                            ; 82E5
        sta     $2B                             ; 82E7
        ldy     #$1C                            ; 82E9
        jsr     L8787                           ; 82EB
        jmp     L82CA                           ; 82EE

; ----------------------------------------------------------------------------
L82F1:  jmp     L80E4                           ; 82F1

; ----------------------------------------------------------------------------
        lda     $1A                             ; 82F4
        jsr     LE97D                           ; 82F6
        sbc     $1182,x                         ; 82F9
        .byte   $83                             ; 82FC
        jsr     L80C1                           ; 82FD
        lda     $033C                           ; 8300
        beq     L8309                           ; 8303
        lda     #$46                            ; 8305
        bne     L830B                           ; 8307
L8309:  lda     #$35                            ; 8309
L830B:  jsr     L887B                           ; 830B
        jmp     L80C7                           ; 830E

; ----------------------------------------------------------------------------
        jsr     L880F                           ; 8311
        beq     L8337                           ; 8314
        lda     $2B                             ; 8316
        bne     L8337                           ; 8318
        lda     #$05                            ; 831A
        sta     $2B                             ; 831C
        lda     $81                             ; 831E
        beq     L8337                           ; 8320
        lda     #$05                            ; 8322
        sta     $00                             ; 8324
        jsr     LE0CD                           ; 8326
        lda     $81                             ; 8329
        ora     $0306                           ; 832B
        bne     L8337                           ; 832E
        lda     #$03                            ; 8330
        sta     $00                             ; 8332
        jsr     LE0D5                           ; 8334
L8337:  rts                                     ; 8337

; ----------------------------------------------------------------------------
        lda     $1A                             ; 8338
        jsr     LE97D                           ; 833A
        eor     $83                             ; 833D
        ora     ($83),y                         ; 833F
        sbc     $7883,x                         ; 8341
        sta     ($A9,x)                         ; 8344
        dey                                     ; 8346
        jsr     L8A55                           ; 8347
        lda     #$01                            ; 834A
        sta     $15                             ; 834C
        lda     #$70                            ; 834E
        sta     $14                             ; 8350
        lda     #$33                            ; 8352
        jsr     LE096                           ; 8354
        jsr     LE95B                           ; 8357
        jsr     LF09B                           ; 835A
        lda     $033C                           ; 835D
        beq     L836A                           ; 8360
        lda     $03CE                           ; 8362
        beq     L836A                           ; 8365
        jmp     L836F                           ; 8367

; ----------------------------------------------------------------------------
L836A:  lda     #$35                            ; 836A
        jmp     L8443                           ; 836C

; ----------------------------------------------------------------------------
L836F:  lda     #$60                            ; 836F
        sta     $37                             ; 8371
        lda     #$9C                            ; 8373
        sta     $0200                           ; 8375
        lda     #$07                            ; 8378
        asl     $033C                           ; 837A
        lsr     $033C                           ; 837D
        jsr     L8829                           ; 8380
        lda     #$88                            ; 8383
        jsr     L8A55                           ; 8385
        lda     $033C                           ; 8388
        ora     #$80                            ; 838B
        sta     $033C                           ; 838D
        jsr     L889B                           ; 8390
        jsr     L87BE                           ; 8393
        jsr     LE09C                           ; 8396
        jsr     LE8EF                           ; 8399
        jsr     LEACA                           ; 839C
        ldx     #$38                            ; 839F
        clc                                     ; 83A1
        lda     $0701,x                         ; 83A2
        adc     #$32                            ; 83A5
        bcc     L83AB                           ; 83A7
        lda     #$FF                            ; 83A9
L83AB:  sta     $0701,x                         ; 83AB
        lda     #$02                            ; 83AE
        sta     $1A                             ; 83B0
        rts                                     ; 83B2

; ----------------------------------------------------------------------------
L83B3:  ldx     #$38                            ; 83B3
L83B5:  lda     $0600,x                         ; 83B5
        cmp     #$38                            ; 83B8
        bne     L83F3                           ; 83BA
        lda     $0601,x                         ; 83BC
        and     #$0F                            ; 83BF
        cmp     #$03                            ; 83C1
        bne     L83F3                           ; 83C3
        lda     #$00                            ; 83C5
        sta     $0601,x                         ; 83C7
        lda     #$00                            ; 83CA
        sta     $14                             ; 83CC
        lda     #$00                            ; 83CE
        sta     $15                             ; 83D0
        lda     #$E0                            ; 83D2
        sta     $37                             ; 83D4
        lda     #$BF                            ; 83D6
        sta     $0200                           ; 83D8
        asl     $033C                           ; 83DB
        lsr     $033C                           ; 83DE
        jsr     LE5AA                           ; 83E1
        lda     #$81                            ; 83E4
        jsr     LE9EB                           ; 83E6
        lda     #$02                            ; 83E9
        sta     $18                             ; 83EB
        jsr     LE95B                           ; 83ED
        jsr     LF09B                           ; 83F0
L83F3:  txa                                     ; 83F3
        clc                                     ; 83F4
        adc     #$08                            ; 83F5
        tax                                     ; 83F7
        bne     L83B5                           ; 83F8
        jmp     L80C7                           ; 83FA

; ----------------------------------------------------------------------------
L83FD:  jsr     L880F                           ; 83FD
        beq     L8458                           ; 8400
        lda     $030A                           ; 8402
        bne     L8414                           ; 8405
        lda     #$10                            ; 8407
        sta     $21                             ; 8409
        sta     $2F                             ; 840B
        lda     #$80                            ; 840D
        sta     $030B                           ; 840F
        bne     L8459                           ; 8412
L8414:  lda     $2B                             ; 8414
        bne     L8424                           ; 8416
        lda     #$1E                            ; 8418
        sta     $2B                             ; 841A
        ldy     #$0C                            ; 841C
        jsr     L8763                           ; 841E
        jmp     L83FD                           ; 8421

; ----------------------------------------------------------------------------
L8424:  lda     $2C                             ; 8424
        bne     L8449                           ; 8426
        jsr     LF154                           ; 8428
        lda     #$39                            ; 842B
        jsr     L887B                           ; 842D
        jsr     L8A0A                           ; 8430
        lda     $03CF                           ; 8433
        sec                                     ; 8436
        sbc     #$0A                            ; 8437
        bcc     L8441                           ; 8439
        sta     $03CF                           ; 843B
        jmp     L836F                           ; 843E

; ----------------------------------------------------------------------------
L8441:  lda     #$3B                            ; 8441
L8443:  jsr     L887B                           ; 8443
        jmp     L83B3                           ; 8446

; ----------------------------------------------------------------------------
L8449:  lda     $33                             ; 8449
        cmp     #$0C                            ; 844B
        bcc     L8458                           ; 844D
        cmp     #$0F                            ; 844F
        bcs     L8458                           ; 8451
        lda     #$3C                            ; 8453
        jsr     L887B                           ; 8455
L8458:  rts                                     ; 8458

; ----------------------------------------------------------------------------
L8459:  dec     $AB                             ; 8459
        jmp     L80E4                           ; 845B

; ----------------------------------------------------------------------------
        lda     $1A                             ; 845E
        jsr     LE97D                           ; 8460
        cmp     ($80,x)                         ; 8463
        adc     #$84                            ; 8465
        .byte   $83                             ; 8467
        sty     $20                             ; 8468
        .byte   $0F                             ; 846A
        dey                                     ; 846B
        beq     L8458                           ; 846C
        lda     $030B                           ; 846E
        bpl     L8458                           ; 8471
        lda     $2F                             ; 8473
        bne     L8458                           ; 8475
        lda     #$10                            ; 8477
        sta     $2F                             ; 8479
        lda     #$00                            ; 847B
        sta     $030B                           ; 847D
        jmp     L80E4                           ; 8480

; ----------------------------------------------------------------------------
        jsr     L880F                           ; 8483
        beq     L8458                           ; 8486
        lda     $2F                             ; 8488
        bne     L8458                           ; 848A
        lda     $0600                           ; 848C
        bne     L8458                           ; 848F
        jmp     L810B                           ; 8491

; ----------------------------------------------------------------------------
        lda     $1A                             ; 8494
        jsr     LE97D                           ; 8496
        .byte   $9F                             ; 8499
        sty     $DE                             ; 849A
        sty     $38                             ; 849C
        sta     $A2                             ; 849E
        sec                                     ; 84A0
L84A1:  lda     $0600,x                         ; 84A1
        cmp     #$3A                            ; 84A4
        beq     L84B1                           ; 84A6
        txa                                     ; 84A8
        clc                                     ; 84A9
        adc     #$08                            ; 84AA
        tax                                     ; 84AC
        bne     L84A1                           ; 84AD
        beq     L84DB                           ; 84AF
L84B1:  sta     $00                             ; 84B1
        lda     #$84                            ; 84B3
        sta     $01                             ; 84B5
        lda     #$00                            ; 84B7
        sta     $02                             ; 84B9
        lda     #$02                            ; 84BB
        sta     $06                             ; 84BD
        lda     #$30                            ; 84BF
        sta     $07                             ; 84C1
        jsr     LFA31                           ; 84C3
        lda     #$83                            ; 84C6
        sta     $0609,x                         ; 84C8
        lda     #$FF                            ; 84CB
        sta     $060C,x                         ; 84CD
        sta     $0614,x                         ; 84D0
        txa                                     ; 84D3
        clc                                     ; 84D4
        adc     #$08                            ; 84D5
        tax                                     ; 84D7
        jsr     LE0BD                           ; 84D8
L84DB:  jmp     L80C1                           ; 84DB

; ----------------------------------------------------------------------------
L84DE:  jsr     L880F                           ; 84DE
        beq     L8508                           ; 84E1
        lda     $25                             ; 84E3
        beq     L8509                           ; 84E5
        lda     $030A                           ; 84E7
        bne     L84FD                           ; 84EA
        lda     #$00                            ; 84EC
        sta     $25                             ; 84EE
        lda     #$20                            ; 84F0
        sta     $21                             ; 84F2
        sta     $2F                             ; 84F4
        lda     #$40                            ; 84F6
        sta     $030B                           ; 84F8
        bne     L8534                           ; 84FB
L84FD:  lda     $2C                             ; 84FD
        bne     L8508                           ; 84FF
        lda     #$14                            ; 8501
        sta     $2C                             ; 8503
        inc     $030B                           ; 8505
L8508:  rts                                     ; 8508

; ----------------------------------------------------------------------------
L8509:  lda     $0600                           ; 8509
        cmp     #$05                            ; 850C
        beq     L8508                           ; 850E
        lda     $2B                             ; 8510
        bne     L8520                           ; 8512
        lda     #$28                            ; 8514
        sta     $2B                             ; 8516
        ldy     #$20                            ; 8518
        jsr     L8787                           ; 851A
        jmp     L84DE                           ; 851D

; ----------------------------------------------------------------------------
L8520:  lda     $2C                             ; 8520
        bne     L8508                           ; 8522
        lda     #$28                            ; 8524
        sta     $2C                             ; 8526
        ldy     #$10                            ; 8528
        jsr     L8763                           ; 852A
        lda     #$14                            ; 852D
        sta     $2B                             ; 852F
        jmp     L84DE                           ; 8531

; ----------------------------------------------------------------------------
L8534:  jmp     L80E4                           ; 8534

; ----------------------------------------------------------------------------
L8537:  rts                                     ; 8537

; ----------------------------------------------------------------------------
        jsr     L880F                           ; 8538
        beq     L8537                           ; 853B
        lda     #$FF                            ; 853D
        sta     $21                             ; 853F
        lda     $2F                             ; 8541
        bne     L8537                           ; 8543
        sta     $21                             ; 8545
        lda     #$FF                            ; 8547
        jsr     LE992                           ; 8549
        jsr     LEA7E                           ; 854C
        lda     #$81                            ; 854F
        jsr     LE9EB                           ; 8551
        lda     #$07                            ; 8554
        sta     $2F                             ; 8556
L8558:  jsr     LE95B                           ; 8558
        lda     $2F                             ; 855B
        bne     L8558                           ; 855D
        ldx     #$38                            ; 855F
L8561:  sta     $0600,x                         ; 8561
        sta     $0700,x                         ; 8564
        inx                                     ; 8567
        bne     L8561                           ; 8568
        sta     $0600                           ; 856A
        lda     #$82                            ; 856D
        sta     $0601                           ; 856F
        ldx     #$00                            ; 8572
        jsr     LE0A4                           ; 8574
        ldx     #$38                            ; 8577
        lda     #$0C                            ; 8579
        sta     $0600,x                         ; 857B
        lda     #$8E                            ; 857E
        sta     $0601,x                         ; 8580
        lda     #$80                            ; 8583
        sta     $0602,x                         ; 8585
        lda     #$80                            ; 8588
        sta     $0603,x                         ; 858A
        lda     #$0C                            ; 858D
        sta     $00                             ; 858F
        lda     #$8F                            ; 8591
        sta     $01                             ; 8593
        lda     #$00                            ; 8595
        sta     $02                             ; 8597
        jsr     LFA29                           ; 8599
        lda     #$4A                            ; 859C
        jsr     LE992                           ; 859E
        jsr     LE080                           ; 85A1
        jsr     LF09B                           ; 85A4
L85A7:  jsr     LE95B                           ; 85A7
        ldx     #$00                            ; 85AA
        jsr     LE0A0                           ; 85AC
        jsr     LE0B1                           ; 85AF
        jsr     LE09E                           ; 85B2
        ldx     #$38                            ; 85B5
        lda     $0601,x                         ; 85B7
        bne     L85A7                           ; 85BA
        lda     #$80                            ; 85BC
        sta     $031C                           ; 85BE
        lda     #$0F                            ; 85C1
        sta     $2F                             ; 85C3
        lda     #$7F                            ; 85C5
        jsr     LE992                           ; 85C7
L85CA:  jsr     LF0B8                           ; 85CA
        lda     $2F                             ; 85CD
        bne     L85CA                           ; 85CF
        lda     #$06                            ; 85D1
        sta     $11                             ; 85D3
        lda     #$10                            ; 85D5
        sta     $19                             ; 85D7
        lda     #$00                            ; 85D9
        sta     $1A                             ; 85DB
        rts                                     ; 85DD

; ----------------------------------------------------------------------------
        inc     $AB                             ; 85DE
        jsr     L8655                           ; 85E0
        jsr     L86BE                           ; 85E3
        lda     #$7B                            ; 85E6
        jsr     LE992                           ; 85E8
        lda     #$1E                            ; 85EB
        jsr     L865A                           ; 85ED
        jsr     L8674                           ; 85F0
        clc                                     ; 85F3
        jsr     L86A4                           ; 85F4
        ldy     $82                             ; 85F7
        lda     L86E0,y                         ; 85F9
        jsr     LE03F                           ; 85FC
        lda     $82                             ; 85FF
        bne     L8633                           ; 8601
        lda     #$81                            ; 8603
        jsr     LE9EB                           ; 8605
        jsr     LEA7E                           ; 8608
        jsr     LE5B2                           ; 860B
        jsr     LE95B                           ; 860E
        lda     #$80                            ; 8611
        sta     $031C                           ; 8613
        lda     #$04                            ; 8616
        sta     $2F                             ; 8618
        lda     #$39                            ; 861A
        jsr     LE992                           ; 861C
L861F:  jsr     LF0B8                           ; 861F
        lda     $2F                             ; 8622
        bne     L861F                           ; 8624
        sta     $031C                           ; 8626
        lda     #$87                            ; 8629
        jsr     LE03F                           ; 862B
        lda     #$75                            ; 862E
        jsr     LE992                           ; 8630
L8633:  sec                                     ; 8633
        jsr     L86A4                           ; 8634
        jsr     LF785                           ; 8637
        inc     $82                             ; 863A
        jsr     LE02F                           ; 863C
        lda     #$FF                            ; 863F
        jsr     LE992                           ; 8641
        jsr     LE031                           ; 8644
        lda     #$00                            ; 8647
        sta     $030D                           ; 8649
        sta     $87                             ; 864C
        sta     $60                             ; 864E
        lda     #$FF                            ; 8650
        sta     $19                             ; 8652
        rts                                     ; 8654

; ----------------------------------------------------------------------------
L8655:  jsr     LE17B                           ; 8655
        .byte   $1F                             ; 8658
        .byte   $04                             ; 8659
L865A:  sta     $0F                             ; 865A
L865C:  jsr     LF747                           ; 865C
        lda     $031C                           ; 865F
        and     #$CF                            ; 8662
        sta     $031C                           ; 8664
        beq     L866C                           ; 8667
        jsr     LEACA                           ; 8669
L866C:  jsr     LE95B                           ; 866C
        dec     $0F                             ; 866F
        bne     L865C                           ; 8671
        rts                                     ; 8673

; ----------------------------------------------------------------------------
L8674:  ldx     #$00                            ; 8674
L8676:  lda     $0221,x                         ; 8676
        eor     #$10                            ; 8679
        sta     $0221,x                         ; 867B
        lda     $0222,x                         ; 867E
        eor     #$40                            ; 8681
        sta     $0222,x                         ; 8683
        sec                                     ; 8686
        lda     $0220,x                         ; 8687
        sbc     #$04                            ; 868A
        sta     $0220,x                         ; 868C
        inx                                     ; 868F
        inx                                     ; 8690
        inx                                     ; 8691
        inx                                     ; 8692
        cpx     #$10                            ; 8693
        bne     L8676                           ; 8695
        lda     #$0C                            ; 8697
        jsr     L865A                           ; 8699
        lda     $0220                           ; 869C
        cmp     #$48                            ; 869F
        bcs     L8674                           ; 86A1
        rts                                     ; 86A3

; ----------------------------------------------------------------------------
L86A4:  lda     #$05                            ; 86A4
        sta     $0E                             ; 86A6
L86A8:  php                                     ; 86A8
        bcc     L86AE                           ; 86A9
        jsr     LF79E                           ; 86AB
L86AE:  jsr     LF067                           ; 86AE
        lda     #$10                            ; 86B1
        jsr     L865A                           ; 86B3
        plp                                     ; 86B6
        dec     $0E                             ; 86B7
        bne     L86A8                           ; 86B9
        jmp     LE5AA                           ; 86BB

; ----------------------------------------------------------------------------
L86BE:  lda     $82                             ; 86BE
        asl     a                               ; 86C0
        tay                                     ; 86C1
        lda     $F71A,y                         ; 86C2
        sta     $85                             ; 86C5
        lda     $F71B,y                         ; 86C7
        sta     $86                             ; 86CA
L86CC:  lda     #$00                            ; 86CC
        sta     $03ED                           ; 86CE
        jsr     L97A4                           ; 86D1
        lda     $03ED                           ; 86D4
        bne     L86DA                           ; 86D7
        rts                                     ; 86D9

; ----------------------------------------------------------------------------
L86DA:  jsr     LA625                           ; 86DA
        jmp     L86CC                           ; 86DD

; ----------------------------------------------------------------------------
L86E0:  stx     $85                             ; 86E0
        dey                                     ; 86E2
        sta     $20                             ; 86E3
        sta     ($E8),y                         ; 86E5
        jsr     LE0DC                           ; 86E7
        lda     #$80                            ; 86EA
        sta     $19                             ; 86EC
        rts                                     ; 86EE

; ----------------------------------------------------------------------------
L86EF:  .byte   $45                             ; 86EF
L86F0:  brk                                     ; 86F0
L86F1:  brk                                     ; 86F1
L86F2:  clc                                     ; 86F2
L86F3:  .byte   $37                             ; 86F3
L86F4:  brk                                     ; 86F4
L86F5:  brk                                     ; 86F5
        brk                                     ; 86F6
        asl     $01,x                           ; 86F7
        sec                                     ; 86F9
        .byte   $1B                             ; 86FA
        .byte   $37                             ; 86FB
        .byte   $3C                             ; 86FC
        brk                                     ; 86FD
        brk                                     ; 86FE
        .byte   $1F                             ; 86FF
        ora     ($00,x)                         ; 8700
        and     ($37,x)                         ; 8702
        brk                                     ; 8704
        brk                                     ; 8705
        brk                                     ; 8706
        .byte   $1F                             ; 8707
        ora     ($38,x)                         ; 8708
        rol     $37                             ; 870A
        plp                                     ; 870C
        brk                                     ; 870D
        brk                                     ; 870E
        and     #$02                            ; 870F
        lda     $3700,y                         ; 8711
        plp                                     ; 8714
        brk                                     ; 8715
        brk                                     ; 8716
        brk                                     ; 8717
        .byte   $04                             ; 8718
        sec                                     ; 8719
        brk                                     ; 871A
        .byte   $37                             ; 871B
        plp                                     ; 871C
        brk                                     ; 871D
        brk                                     ; 871E
        brk                                     ; 871F
        brk                                     ; 8720
        brk                                     ; 8721
        brk                                     ; 8722
        .byte   $37                             ; 8723
        ora     $00                             ; 8724
        brk                                     ; 8726
        brk                                     ; 8727
        ora     $38                             ; 8728
        brk                                     ; 872A
        .byte   $37                             ; 872B
        .byte   $14                             ; 872C
        plp                                     ; 872D
        brk                                     ; 872E
        brk                                     ; 872F
        brk                                     ; 8730
        brk                                     ; 8731
        brk                                     ; 8732
        .byte   $37                             ; 8733
        brk                                     ; 8734
        brk                                     ; 8735
        brk                                     ; 8736
        rol     $3803,x                         ; 8737
        brk                                     ; 873A
        .byte   $37                             ; 873B
        .byte   $14                             ; 873C
        plp                                     ; 873D
        brk                                     ; 873E
L873F:  .byte   $19                             ; 873F
L8740:  .byte   $1A                             ; 8740
L8741:  asl     a                               ; 8741
L8742:  brk                                     ; 8742
        .byte   $22                             ; 8743
        .byte   $23                             ; 8744
        .byte   $14                             ; 8745
        ora     ($2D,x)                         ; 8746
        rol     a:$14                           ; 8748
        .byte   $37                             ; 874B
        sec                                     ; 874C
        .byte   $32                             ; 874D
        .byte   $02                             ; 874E
        .byte   $43                             ; 874F
        .byte   $44                             ; 8750
        iny                                     ; 8751
        .byte   $02                             ; 8752
        .byte   $47                             ; 8753
        pha                                     ; 8754
        .byte   $32                             ; 8755
        brk                                     ; 8756
        .byte   $1C                             ; 8757
        ora     $030E,x                         ; 8758
        and     ($32),y                         ; 875B
        ora     $4100                           ; 875D
        .byte   $42                             ; 8760
        brk                                     ; 8761
        brk                                     ; 8762
L8763:  jsr     L8878                           ; 8763
        tya                                     ; 8766
        pha                                     ; 8767
        lda     L8742,y                         ; 8768
        jsr     L87AE                           ; 876B
        pla                                     ; 876E
        tay                                     ; 876F
        lda     L8740,y                         ; 8770
        jsr     L887B                           ; 8773
        lda     L8741,y                         ; 8776
        jmp     LE0CD                           ; 8779

; ----------------------------------------------------------------------------
L877C:  jsr     LE97D                           ; 877C
        .byte   $9B                             ; 877F
        dey                                     ; 8780
        sta     ($88,x)                         ; 8781
        dec     $AF8E                           ; 8783
        dey                                     ; 8786
L8787:  jsr     L8878                           ; 8787
        tya                                     ; 878A
        pha                                     ; 878B
        lda     L8742,y                         ; 878C
        jsr     L87AE                           ; 878F
        pla                                     ; 8792
        tay                                     ; 8793
        lda     L8740,y                         ; 8794
        jsr     L887B                           ; 8797
        lda     L8741,y                         ; 879A
        bne     L87A7                           ; 879D
        lda     $E0                             ; 879F
        and     #$03                            ; 87A1
        tay                                     ; 87A3
        lda     L87AA,y                         ; 87A4
L87A7:  jmp     LE0CB                           ; 87A7

; ----------------------------------------------------------------------------
L87AA:  .byte   $02                             ; 87AA
        php                                     ; 87AB
        .byte   $0D                             ; 87AC
        .byte   $05                             ; 87AD
L87AE:  pha                                     ; 87AE
        tay                                     ; 87AF
        lda     L87BA,y                         ; 87B0
        jsr     LE992                           ; 87B3
        pla                                     ; 87B6
        jmp     L877C                           ; 87B7

; ----------------------------------------------------------------------------
L87BA:  lsr     a                               ; 87BA
        and     ($32),y                         ; 87BB
L87BD:  .byte   $2D                             ; 87BD
L87BE:  jsr     L87E3                           ; 87BE
        ldy     $0309                           ; 87C1
        lda     L86F2,y                         ; 87C4
        beq     L87CC                           ; 87C7
L87C9:  jsr     LE096                           ; 87C9
L87CC:  lda     L86F3,y                         ; 87CC
        jsr     LF765                           ; 87CF
        jsr     L8BB5                           ; 87D2
        ldy     $0309                           ; 87D5
        lda     L86F4,y                         ; 87D8
        sta     $2B                             ; 87DB
        lda     L86F5,y                         ; 87DD
        sta     $2C                             ; 87E0
        rts                                     ; 87E2

; ----------------------------------------------------------------------------
L87E3:  lda     $19                             ; 87E3
        sec                                     ; 87E5
        sbc     #$01                            ; 87E6
        asl     a                               ; 87E8
        asl     a                               ; 87E9
        asl     a                               ; 87EA
        tay                                     ; 87EB
        lda     L86EF,y                         ; 87EC
        beq     L87F4                           ; 87EF
        jsr     LE096                           ; 87F1
L87F4:  sty     $0309                           ; 87F4
        jsr     LE8B1                           ; 87F7
        ldy     $0309                           ; 87FA
        lda     L86F0,y                         ; 87FD
        jsr     LE97D                           ; 8800
        .byte   $9B                             ; 8803
        beq     L87C9                           ; 8804
        dey                                     ; 8806
        and     #$89                            ; 8807
        sei                                     ; 8809
        .byte   $89                             ; 880A
        cmp     $89                             ; 880B
        .byte   $3C                             ; 880D
        .byte   $89                             ; 880E
L880F:  lda     $0601                           ; 880F
        beq     L8820                           ; 8812
        jsr     L8076                           ; 8814
        lda     $11                             ; 8817
        cmp     #$06                            ; 8819
        beq     L8826                           ; 881B
        lda     $19                             ; 881D
        rts                                     ; 881F

; ----------------------------------------------------------------------------
L8820:  jsr     LE89D                           ; 8820
        jsr     LE389                           ; 8823
L8826:  lda     #$00                            ; 8826
        rts                                     ; 8828

; ----------------------------------------------------------------------------
L8829:  pha                                     ; 8829
        jsr     LF11C                           ; 882A
        lda     #$06                            ; 882D
        sta     $0600,y                         ; 882F
        pla                                     ; 8832
        ora     #$80                            ; 8833
        sta     $0601,y                         ; 8835
        lda     #$60                            ; 8838
        sta     $0602,y                         ; 883A
        lda     #$80                            ; 883D
        sta     $0603,y                         ; 883F
        tya                                     ; 8842
        tax                                     ; 8843
        jsr     LE0A4                           ; 8844
        jmp     L8872                           ; 8847

; ----------------------------------------------------------------------------
L884A:  ldx     #$00                            ; 884A
L884C:  lda     $0601,x                         ; 884C
        beq     L8861                           ; 884F
        lda     $0600,x                         ; 8851
        cmp     #$06                            ; 8854
        bne     L885E                           ; 8856
        jsr     LE0D3                           ; 8858
        jmp     L8861                           ; 885B

; ----------------------------------------------------------------------------
L885E:  jsr     LE092                           ; 885E
L8861:  txa                                     ; 8861
        clc                                     ; 8862
        adc     #$08                            ; 8863
        tax                                     ; 8865
        bne     L884C                           ; 8866
        jsr     LE094                           ; 8868
        lda     $30                             ; 886B
        beq     L8872                           ; 886D
        jmp     LF1C0                           ; 886F

; ----------------------------------------------------------------------------
L8872:  jsr     LF0B8                           ; 8872
        jmp     L884A                           ; 8875

; ----------------------------------------------------------------------------
L8878:  lda     L873F,y                         ; 8878
L887B:  jsr     LE096                           ; 887B
        jmp     L8BB5                           ; 887E

; ----------------------------------------------------------------------------
        lda     #$10                            ; 8881
        sta     $2E                             ; 8883
        lda     #$31                            ; 8885
        jsr     LE992                           ; 8887
L888A:  lda     $2E                             ; 888A
        cmp     #$06                            ; 888C
        bcc     L8893                           ; 888E
        jsr     LE09A                           ; 8890
L8893:  jsr     LF0B2                           ; 8893
        lda     $2E                             ; 8896
        bne     L888A                           ; 8898
        rts                                     ; 889A

; ----------------------------------------------------------------------------
L889B:  lda     #$08                            ; 889B
        sta     $2E                             ; 889D
        jsr     LEC75                           ; 889F
        jsr     LE09C                           ; 88A2
L88A5:  jsr     LF0B5                           ; 88A5
        lda     $2E                             ; 88A8
        bne     L88A5                           ; 88AA
        jmp     LEC71                           ; 88AC

; ----------------------------------------------------------------------------
        lda     #$08                            ; 88AF
        sta     $2E                             ; 88B1
        lda     #$15                            ; 88B3
        sta     $04A7                           ; 88B5
        sta     $04AB                           ; 88B8
        sta     $04AF                           ; 88BB
        jsr     LF07B                           ; 88BE
        bne     L88A5                           ; 88C1
        ldy     #$1C                            ; 88C3
        lda     #$0F                            ; 88C5
L88C7:  sta     $04A4,y                         ; 88C7
        dey                                     ; 88CA
        bne     L88C7                           ; 88CB
        jsr     L8A61                           ; 88CD
L88D0:  lda     #$40                            ; 88D0
        sta     $00                             ; 88D2
L88D4:  lda     $00                             ; 88D4
        pha                                     ; 88D6
        jsr     LF0B5                           ; 88D7
        pla                                     ; 88DA
        sta     $00                             ; 88DB
        bne     L88E0                           ; 88DD
        rts                                     ; 88DF

; ----------------------------------------------------------------------------
L88E0:  lda     $7F                             ; 88E0
        and     #$07                            ; 88E2
        bne     L88D4                           ; 88E4
        lda     $00                             ; 88E6
        sec                                     ; 88E8
        sbc     #$10                            ; 88E9
        sta     $00                             ; 88EB
        ldx     $0162                           ; 88ED
        lda     #$3F                            ; 88F0
        sta     $0163,x                         ; 88F2
        inx                                     ; 88F5
        lda     #$04                            ; 88F6
        sta     $0163,x                         ; 88F8
        inx                                     ; 88FB
        lda     #$1C                            ; 88FC
        sta     $0163,x                         ; 88FE
        inx                                     ; 8901
        ldy     #$00                            ; 8902
L8904:  lda     $04A4,y                         ; 8904
        cpy     #$0C                            ; 8907
        bcc     L890F                           ; 8909
        cpy     #$10                            ; 890B
        bcc     L8916                           ; 890D
L890F:  sec                                     ; 890F
        sbc     $00                             ; 8910
        bcs     L8916                           ; 8912
        lda     #$0F                            ; 8914
L8916:  sta     $0163,x                         ; 8916
        inx                                     ; 8919
        iny                                     ; 891A
        cpy     #$1C                            ; 891B
        bne     L8904                           ; 891D
        stx     $0162                           ; 891F
        lda     #$00                            ; 8922
        sta     $0163,x                         ; 8924
        beq     L88D4                           ; 8927
        lda     #$80                            ; 8929
        jsr     L8A55                           ; 892B
        lda     #$01                            ; 892E
        sta     $15                             ; 8930
        lda     #$70                            ; 8932
        sta     $14                             ; 8934
        jsr     LF09B                           ; 8936
        jsr     LE95B                           ; 8939
        ldy     $0309                           ; 893C
        lda     L86F1,y                         ; 893F
        asl     $031C                           ; 8942
        asl     a                               ; 8945
        ror     $031C                           ; 8946
        lsr     a                               ; 8949
        jsr     LE992                           ; 894A
L894D:  jsr     LF0B5                           ; 894D
        lda     $15                             ; 8950
        ora     $14                             ; 8952
        bne     L8962                           ; 8954
        jsr     LEA88                           ; 8956
        jsr     LF73D                           ; 8959
        lda     #$40                            ; 895C
        sta     $031C                           ; 895E
        rts                                     ; 8961

; ----------------------------------------------------------------------------
L8962:  lda     $7F                             ; 8962
        and     #$03                            ; 8964
        bne     L894D                           ; 8966
        inc     $14                             ; 8968
        lda     $14                             ; 896A
        cmp     #$F0                            ; 896C
        bcc     L894D                           ; 896E
        lda     #$00                            ; 8970
        sta     $14                             ; 8972
        sta     $15                             ; 8974
        beq     L894D                           ; 8976
        ldy     #$0C                            ; 8978
        lda     #$0F                            ; 897A
L897C:  sta     $04A4,y                         ; 897C
        dey                                     ; 897F
        bpl     L897C                           ; 8980
        jsr     L8A61                           ; 8982
        lda     #$08                            ; 8985
        sta     $2F                             ; 8987
L8989:  jsr     LF0B5                           ; 8989
        lda     $2F                             ; 898C
        bne     L8993                           ; 898E
        jmp     L88D0                           ; 8990

; ----------------------------------------------------------------------------
L8993:  ldy     #$0F                            ; 8993
        cmp     #$02                            ; 8995
        bcc     L89A1                           ; 8997
        lda     $7F                             ; 8999
        and     #$03                            ; 899B
        bne     L89A1                           ; 899D
        ldy     #$20                            ; 899F
L89A1:  ldx     $0162                           ; 89A1
        lda     #$3F                            ; 89A4
        sta     $0163,x                         ; 89A6
        inx                                     ; 89A9
        lda     #$04                            ; 89AA
        sta     $0163,x                         ; 89AC
        inx                                     ; 89AF
        lda     #$4C                            ; 89B0
        sta     $0163,x                         ; 89B2
        inx                                     ; 89B5
        tya                                     ; 89B6
        sta     $0163,x                         ; 89B7
        inx                                     ; 89BA
        lda     #$00                            ; 89BB
        sta     $0163,x                         ; 89BD
        stx     $0162                           ; 89C0
        beq     L8989                           ; 89C3
        lda     $033A                           ; 89C5
        beq     L89DC                           ; 89C8
        lda     $03CA                           ; 89CA
        beq     L89DC                           ; 89CD
        lda     #$05                            ; 89CF
        jsr     L8829                           ; 89D1
        jsr     L889B                           ; 89D4
        lda     #$30                            ; 89D7
        jmp     L887B                           ; 89D9

; ----------------------------------------------------------------------------
L89DC:  lda     #$04                            ; 89DC
        sta     $00                             ; 89DE
L89E0:  lda     $00                             ; 89E0
        pha                                     ; 89E2
        lda     $7F                             ; 89E3
        and     #$03                            ; 89E5
        bne     L89FB                           ; 89E7
        ldy     #$0B                            ; 89E9
L89EB:  lda     $04A4,y                         ; 89EB
        sec                                     ; 89EE
        sbc     #$10                            ; 89EF
        bcs     L89F5                           ; 89F1
        lda     #$0F                            ; 89F3
L89F5:  sta     $04A4,y                         ; 89F5
        dey                                     ; 89F8
        bpl     L89EB                           ; 89F9
L89FB:  jsr     L80C7                           ; 89FB
        pla                                     ; 89FE
        sta     $00                             ; 89FF
        dec     $00                             ; 8A01
        bne     L89E0                           ; 8A03
        lda     #$2F                            ; 8A05
        jmp     L887B                           ; 8A07

; ----------------------------------------------------------------------------
L8A0A:  lda     #$88                            ; 8A0A
        jsr     L8A55                           ; 8A0C
        sta     $12                             ; 8A0F
        lda     #$01                            ; 8A11
        sta     $15                             ; 8A13
        lda     #$EF                            ; 8A15
        sta     $14                             ; 8A17
L8A19:  dec     $14                             ; 8A19
        lda     $14                             ; 8A1B
        cmp     #$70                            ; 8A1D
        beq     L8A2C                           ; 8A1F
        lda     $1E                             ; 8A21
        and     #$04                            ; 8A23
        bne     L8A2C                           ; 8A25
        jsr     LF07B                           ; 8A27
        bne     L8A30                           ; 8A2A
L8A2C:  lda     #$05                            ; 8A2C
        sta     $18                             ; 8A2E
L8A30:  jsr     LF0B2                           ; 8A30
        lda     $14                             ; 8A33
        cmp     #$70                            ; 8A35
        bne     L8A19                           ; 8A37
        lda     #$3A                            ; 8A39
        jmp     L887B                           ; 8A3B

; ----------------------------------------------------------------------------
        lda     $69                             ; 8A3E
        bne     L8A46                           ; 8A40
        lda     #$4A                            ; 8A42
        sta     $69                             ; 8A44
L8A46:  rts                                     ; 8A46

; ----------------------------------------------------------------------------
L8A47:  lda     #$00                            ; 8A47
        sta     $030B                           ; 8A49
        lda     $69                             ; 8A4C
        asl     a                               ; 8A4E
        adc     #$00                            ; 8A4F
        sta     $69                             ; 8A51
        lsr     a                               ; 8A53
        rts                                     ; 8A54

; ----------------------------------------------------------------------------
L8A55:  sta     $0200                           ; 8A55
        lda     #$28                            ; 8A58
        sta     $36                             ; 8A5A
        lda     #$00                            ; 8A5C
        sta     $37                             ; 8A5E
        rts                                     ; 8A60

; ----------------------------------------------------------------------------
L8A61:  jsr     LF09B                           ; 8A61
        jsr     LE95B                           ; 8A64
        jsr     LE080                           ; 8A67
        ldy     $0309                           ; 8A6A
        lda     L86F1,y                         ; 8A6D
        jmp     LE992                           ; 8A70

; ----------------------------------------------------------------------------
L8A73:  jsr     LE17B                           ; 8A73
        .byte   $1B                             ; 8A76
        .byte   $04                             ; 8A77
        jsr     L8AE4                           ; 8A78
        beq     L8ACB                           ; 8A7B
        tay                                     ; 8A7D
        lda     $C4,y                           ; 8A7E
        beq     L8ACB                           ; 8A81
        cmp     #$1E                            ; 8A83
        bcs     L8ACB                           ; 8A85
        sta     $33                             ; 8A87
        cmp     #$09                            ; 8A89
        bcc     L8A9C                           ; 8A8B
        cmp     #$0F                            ; 8A8D
        bcs     L8A9C                           ; 8A8F
        lda     $B2                             ; 8A91
        cmp     #$29                            ; 8A93
        bne     L8A9C                           ; 8A95
        lda     #$03                            ; 8A97
        jmp     LE096                           ; 8A99

; ----------------------------------------------------------------------------
L8A9C:  lda     $33                             ; 8A9C
        jsr     L950F                           ; 8A9E
        bcs     L8ACB                           ; 8AA1
        lda     L98EA,y                         ; 8AA3
        and     #$10                            ; 8AA6
        beq     L8ACC                           ; 8AA8
        jsr     LEAB9                           ; 8AAA
L8AAD:  sec                                     ; 8AAD
        lda     $81                             ; 8AAE
        sbc     L98ED,y                         ; 8AB0
        bcs     L8AC6                           ; 8AB3
        lda     $0306                           ; 8AB5
        beq     L8AC6                           ; 8AB8
        dec     $0306                           ; 8ABA
        clc                                     ; 8ABD
        lda     $81                             ; 8ABE
        adc     #$32                            ; 8AC0
        sta     $81                             ; 8AC2
        bne     L8AAD                           ; 8AC4
L8AC6:  sta     $81                             ; 8AC6
        jmp     L8ACF                           ; 8AC8

; ----------------------------------------------------------------------------
L8ACB:  rts                                     ; 8ACB

; ----------------------------------------------------------------------------
L8ACC:  jsr     L8BE5                           ; 8ACC
L8ACF:  jsr     L8C23                           ; 8ACF
        lda     L98EC,y                         ; 8AD2
        beq     L8ACB                           ; 8AD5
        lda     L98EB,y                         ; 8AD7
        sta     L003E                           ; 8ADA
        lda     L98EC,y                         ; 8ADC
        sta     $3F                             ; 8ADF
        jmp     (L003E)                         ; 8AE1

; ----------------------------------------------------------------------------
L8AE4:  lda     $C2                             ; 8AE4
        lsr     a                               ; 8AE6
        bcs     L8AF1                           ; 8AE7
        lsr     a                               ; 8AE9
        lda     #$00                            ; 8AEA
        bcc     L8AF0                           ; 8AEC
        lda     #$02                            ; 8AEE
L8AF0:  rts                                     ; 8AF0

; ----------------------------------------------------------------------------
L8AF1:  lda     #$01                            ; 8AF1
        rts                                     ; 8AF3

; ----------------------------------------------------------------------------
L8AF4:  lda     $03ED                           ; 8AF4
        beq     L8B07                           ; 8AF7
        jsr     LA625                           ; 8AF9
        lda     #$00                            ; 8AFC
        sta     $03ED                           ; 8AFE
        jsr     L97A4                           ; 8B01
        jmp     L8AF4                           ; 8B04

; ----------------------------------------------------------------------------
L8B07:  lda     $C2                             ; 8B07
        and     #$04                            ; 8B09
        beq     L8B27                           ; 8B0B
        bit     $BF                             ; 8B0D
        bvs     L8B19                           ; 8B0F
        lda     $B2                             ; 8B11
        and     #$E0                            ; 8B13
        cmp     #$20                            ; 8B15
        beq     L8B27                           ; 8B17
L8B19:  jsr     L99F6                           ; 8B19
        inc     $C4                             ; 8B1C
        jsr     LE88D                           ; 8B1E
        jsr     LE035                           ; 8B21
        jmp     L8B49                           ; 8B24

; ----------------------------------------------------------------------------
L8B27:  lda     $C2                             ; 8B27
        and     #$08                            ; 8B29
        beq     L8B6B                           ; 8B2B
        jsr     L99F6                           ; 8B2D
        inc     $C4                             ; 8B30
        bit     $BF                             ; 8B32
        bvs     L8B3E                           ; 8B34
        lda     $B2                             ; 8B36
        and     #$E0                            ; 8B38
        cmp     #$20                            ; 8B3A
        beq     L8B52                           ; 8B3C
L8B3E:  jsr     LE88D                           ; 8B3E
        jsr     L99FB                           ; 8B41
        beq     L8B49                           ; 8B44
        jmp     L8CFE                           ; 8B46

; ----------------------------------------------------------------------------
L8B49:  jsr     LE09C                           ; 8B49
        jsr     L94E5                           ; 8B4C
        jmp     L8B55                           ; 8B4F

; ----------------------------------------------------------------------------
L8B52:  jsr     LA3A5                           ; 8B52
L8B55:  lda     $FFF0                           ; 8B55
        ora     $FFF1                           ; 8B58
        bne     L8B65                           ; 8B5B
        lda     $C0                             ; 8B5D
        and     #$0A                            ; 8B5F
        cmp     #$0A                            ; 8B61
        beq     L8B6C                           ; 8B63
L8B65:  lda     #$00                            ; 8B65
        sta     $6A                             ; 8B67
        sta     $C4                             ; 8B69
L8B6B:  rts                                     ; 8B6B

; ----------------------------------------------------------------------------
L8B6C:  sta     $6A                             ; 8B6C
        lda     $7F                             ; 8B6E
        and     #$07                            ; 8B70
        bne     L8B78                           ; 8B72
        lda     $6A                             ; 8B74
        bne     L8B81                           ; 8B76
L8B78:  jsr     LE0D1                           ; 8B78
        jsr     LF0B2                           ; 8B7B
        jmp     L8B55                           ; 8B7E

; ----------------------------------------------------------------------------
L8B81:  ldy     #$F0                            ; 8B81
        lda     $C0                             ; 8B83
        bmi     L8B8C                           ; 8B85
        ldy     #$10                            ; 8B87
        asl     a                               ; 8B89
        bpl     L8B94                           ; 8B8A
L8B8C:  pha                                     ; 8B8C
        tya                                     ; 8B8D
        clc                                     ; 8B8E
        adc     $AB                             ; 8B8F
        sta     $AB                             ; 8B91
        pla                                     ; 8B93
L8B94:  asl     a                               ; 8B94
        bpl     L8B99                           ; 8B95
        dec     $AB                             ; 8B97
L8B99:  asl     a                               ; 8B99
        bpl     L8B9E                           ; 8B9A
        inc     $AB                             ; 8B9C
L8B9E:  lda     $C0                             ; 8B9E
        and     #$04                            ; 8BA0
        beq     L8B78                           ; 8BA2
        lda     #$00                            ; 8BA4
        sta     $C4                             ; 8BA6
        sta     $19                             ; 8BA8
        sta     $1A                             ; 8BAA
        jsr     LF0B2                           ; 8BAC
        jsr     L8D79                           ; 8BAF
        jmp     LEA7E                           ; 8BB2

; ----------------------------------------------------------------------------
L8BB5:  tya                                     ; 8BB5
        pha                                     ; 8BB6
        txa                                     ; 8BB7
        pha                                     ; 8BB8
        lda     $11                             ; 8BB9
        cmp     #$06                            ; 8BBB
        beq     L8BCF                           ; 8BBD
L8BBF:  jsr     LF0B2                           ; 8BBF
        lda     $24                             ; 8BC2
        beq     L8BC8                           ; 8BC4
        dec     $24                             ; 8BC6
L8BC8:  lda     $18                             ; 8BC8
        ora     $0163                           ; 8BCA
        bne     L8BBF                           ; 8BCD
L8BCF:  lda     $031C                           ; 8BCF
        bpl     L8BD9                           ; 8BD2
        ora     #$40                            ; 8BD4
        sta     $031C                           ; 8BD6
L8BD9:  lda     $031C                           ; 8BD9
        and     #$8F                            ; 8BDC
        bne     L8BBF                           ; 8BDE
        pla                                     ; 8BE0
        tax                                     ; 8BE1
        pla                                     ; 8BE2
        tay                                     ; 8BE3
        rts                                     ; 8BE4

; ----------------------------------------------------------------------------
L8BE5:  lda     L98ED,y                         ; 8BE5
        sta     $00                             ; 8BE8
        lda     L98EE,y                         ; 8BEA
        sta     $01                             ; 8BED
        lda     L98EF,y                         ; 8BEF
        sta     $02                             ; 8BF2
        jsr     LEBFF                           ; 8BF4
        bcs     L8C16                           ; 8BF7
        beq     L8C16                           ; 8BF9
        lda     $0307                           ; 8BFB
        beq     L8C13                           ; 8BFE
        dec     $0307                           ; 8C00
        lda     #$00                            ; 8C03
        sta     $00                             ; 8C05
        sta     $02                             ; 8C07
        lda     #$05                            ; 8C09
        sta     $01                             ; 8C0B
        jsr     LEC21                           ; 8C0D
        jmp     L8BE5                           ; 8C10

; ----------------------------------------------------------------------------
L8C13:  ldy     #$00                            ; 8C13
        rts                                     ; 8C15

; ----------------------------------------------------------------------------
L8C16:  lda     $00                             ; 8C16
        sta     $8C                             ; 8C18
        lda     $01                             ; 8C1A
        sta     $8D                             ; 8C1C
        lda     $02                             ; 8C1E
        sta     $8E                             ; 8C20
        rts                                     ; 8C22

; ----------------------------------------------------------------------------
L8C23:  tya                                     ; 8C23
        bne     L8C28                           ; 8C24
        sta     $33                             ; 8C26
L8C28:  lda     L98E9,y                         ; 8C28
        jsr     LE992                           ; 8C2B
        lda     L98EA,y                         ; 8C2E
        bmi     L8C4D                           ; 8C31
        lda     #$02                            ; 8C33
        sta     $EA                             ; 8C35
        lda     #$00                            ; 8C37
        sta     $EB                             ; 8C39
        lda     L98E8,y                         ; 8C3B
        sta     $EC                             ; 8C3E
        jsr     L9140                           ; 8C40
        lda     L98EA,y                         ; 8C43
        and     #$40                            ; 8C46
        bne     L8C4D                           ; 8C48
        jsr     L8E1F                           ; 8C4A
L8C4D:  tya                                     ; 8C4D
        pha                                     ; 8C4E
        ldy     $33                             ; 8C4F
        lda     L99D8,y                         ; 8C51
        beq     L8C6D                           ; 8C54
        tay                                     ; 8C56
        lda     $0300,y                         ; 8C57
        bne     L8C6D                           ; 8C5A
        cpy     #$20                            ; 8C5C
        bcc     L8C68                           ; 8C5E
        sta     $C5                             ; 8C60
        jsr     LEABD                           ; 8C62
        jmp     L8C6D                           ; 8C65

; ----------------------------------------------------------------------------
L8C68:  sta     $C6                             ; 8C68
        jsr     LEAB9                           ; 8C6A
L8C6D:  pla                                     ; 8C6D
        tay                                     ; 8C6E
        lda     $0314                           ; 8C6F
        sta     $033D                           ; 8C72
        rts                                     ; 8C75

; ----------------------------------------------------------------------------
        jsr     LF082                           ; 8C76
        lda     #$13                            ; 8C79
        sta     $2F                             ; 8C7B
        lda     #$1E                            ; 8C7D
        jsr     LE992                           ; 8C7F
L8C82:  jsr     LE09C                           ; 8C82
        jsr     LF0A8                           ; 8C85
        jsr     LE098                           ; 8C88
        .byte   $20                             ; 8C8B
L8C8C:  clv                                     ; 8C8C
        beq     *-89                            ; 8C8D
        .byte   $2F                             ; 8C8F
        bne     L8C82                           ; 8C90
L8C92:  jsr     LE080                           ; 8C92
        jsr     LF07B                           ; 8C95
        lda     #$06                            ; 8C98
        sta     $2F                             ; 8C9A
        lda     #$08                            ; 8C9C
        jsr     LE096                           ; 8C9E
L8CA1:  jsr     LF0B2                           ; 8CA1
        lda     $2F                             ; 8CA4
        bne     L8CA1                           ; 8CA6
        rts                                     ; 8CA8

; ----------------------------------------------------------------------------
L8CA9:  jsr     LF154                           ; 8CA9
        jsr     LF082                           ; 8CAC
        lda     #$25                            ; 8CAF
        sta     $0205                           ; 8CB1
        lda     #$0B                            ; 8CB4
        jsr     LE992                           ; 8CB6
        lda     #$1B                            ; 8CB9
        sta     $2F                             ; 8CBB
L8CBD:  lda     $2F                             ; 8CBD
        cmp     #$08                            ; 8CBF
        bcc     L8CC6                           ; 8CC1
        jsr     LE09A                           ; 8CC3
L8CC6:  jsr     LF0B2                           ; 8CC6
        lda     $2F                             ; 8CC9
        bne     L8CBD                           ; 8CCB
        beq     L8C92                           ; 8CCD
L8CCF:  lda     #$0C                            ; 8CCF
        jsr     LE992                           ; 8CD1
        lda     #$00                            ; 8CD4
        sta     $32                             ; 8CD6
        sta     $2A                             ; 8CD8
        lda     #$01                            ; 8CDA
        sta     $0600                           ; 8CDC
        lda     $0707                           ; 8CDF
        and     #$ED                            ; 8CE2
        sta     $0707                           ; 8CE4
        and     #$40                            ; 8CE7
        bne     L8CF5                           ; 8CE9
        lda     $0601                           ; 8CEB
        and     #$F0                            ; 8CEE
        ora     #$01                            ; 8CF0
        sta     $0601                           ; 8CF2
L8CF5:  lda     #$70                            ; 8CF5
        sta     $29                             ; 8CF7
L8CF9:  ldx     #$00                            ; 8CF9
        jmp     LE0A4                           ; 8CFB

; ----------------------------------------------------------------------------
L8CFE:  dec     $0311                           ; 8CFE
        tya                                     ; 8D01
        pha                                     ; 8D02
        lda     #$00                            ; 8D03
        sta     $B1                             ; 8D05
        sta     $C4                             ; 8D07
        sta     $AC                             ; 8D09
        sta     $60                             ; 8D0B
        lda     #$FF                            ; 8D0D
        jsr     LE992                           ; 8D0F
        jsr     LE328                           ; 8D12
        lda     #$81                            ; 8D15
        jsr     LF0FF                           ; 8D17
        lda     #$04                            ; 8D1A
        jsr     LE096                           ; 8D1C
        lda     #$0D                            ; 8D1F
        jsr     LE992                           ; 8D21
        lda     #$1E                            ; 8D24
        jsr     LE8C8                           ; 8D26
        lda     $0600                           ; 8D29
        pha                                     ; 8D2C
        lda     #$05                            ; 8D2D
        sta     $0600                           ; 8D2F
        lda     #$8C                            ; 8D32
        sta     $0601                           ; 8D34
        lda     #$81                            ; 8D37
        sta     $0609                           ; 8D39
        lda     #$FF                            ; 8D3C
        sta     $060C                           ; 8D3E
        ldx     #$00                            ; 8D41
        jsr     LE0A4                           ; 8D43
        jsr     L8A73                           ; 8D46
        pla                                     ; 8D49
        asl     a                               ; 8D4A
        lsr     a                               ; 8D4B
        sta     $0600                           ; 8D4C
        lda     #$21                            ; 8D4F
        sta     $0601                           ; 8D51
        jsr     L8CF9                           ; 8D54
        pla                                     ; 8D57
        sta     $00                             ; 8D58
        lda     $82                             ; 8D5A
        asl     a                               ; 8D5C
        asl     a                               ; 8D5D
        asl     a                               ; 8D5E
        adc     $00                             ; 8D5F
        tay                                     ; 8D61
        lda     L98C0,y                         ; 8D62
L8D65:  sta     $AB                             ; 8D65
        lda     $0707                           ; 8D67
        and     #$AF                            ; 8D6A
        sta     $0707                           ; 8D6C
        lda     #$FF                            ; 8D6F
        sta     $060C                           ; 8D71
        lda     #$00                            ; 8D74
        sta     $070F                           ; 8D76
L8D79:  lda     #$00                            ; 8D79
        sta     $95                             ; 8D7B
        jsr     LE08C                           ; 8D7D
        jsr     LE8A8                           ; 8D80
        lda     $B9                             ; 8D83
        ldx     #$00                            ; 8D85
        jsr     LE086                           ; 8D87
        jsr     LE0B7                           ; 8D8A
        rts                                     ; 8D8D

; ----------------------------------------------------------------------------
        ldy     $19                             ; 8D8E
        beq     L8DB0                           ; 8D90
        cpy     #$0B                            ; 8D92
        beq     L8DAD                           ; 8D94
        lda     L8DA2,y                         ; 8D96
        sta     $94                             ; 8D99
        lda     #$00                            ; 8D9B
        sta     $19                             ; 8D9D
        sta     $1A                             ; 8D9F
        .byte   $F0                             ; 8DA1
L8DA2:  ora     $5858,x                         ; 8DA2
        .byte   $6B                             ; 8DA5
        .byte   $6B                             ; 8DA6
        jmp     (L666C)                         ; 8DA7

; ----------------------------------------------------------------------------
        dey                                     ; 8DAA
        .byte   $97                             ; 8DAB
        .byte   $97                             ; 8DAC
L8DAD:  jmp     LF2B4                           ; 8DAD

; ----------------------------------------------------------------------------
L8DB0:  lda     $BF                             ; 8DB0
        and     #$40                            ; 8DB2
        bne     L8DAD                           ; 8DB4
        lda     $B2                             ; 8DB6
        cmp     #$20                            ; 8DB8
        bcs     L8DAD                           ; 8DBA
        and     #$1F                            ; 8DBC
        beq     L8DAD                           ; 8DBE
        ldy     $32                             ; 8DC0
        beq     L8DD7                           ; 8DC2
        lda     $ED2B,y                         ; 8DC4
        and     #$40                            ; 8DC7
        beq     L8DD7                           ; 8DC9
        lda     #$00                            ; 8DCB
        sta     $32                             ; 8DCD
        sta     $0600                           ; 8DCF
        sta     $0707                           ; 8DD2
        sta     $2A                             ; 8DD5
L8DD7:  lda     #$22                            ; 8DD7
        sta     $0601                           ; 8DD9
        ldx     #$00                            ; 8DDC
        jsr     LE0A4                           ; 8DDE
        lda     #$08                            ; 8DE1
        jsr     LE898                           ; 8DE3
        lda     #$FF                            ; 8DE6
        jsr     LE992                           ; 8DE8
        lda     #$00                            ; 8DEB
        sta     $B1                             ; 8DED
        sta     $60                             ; 8DEF
        jsr     LE328                           ; 8DF1
        lda     #$81                            ; 8DF4
        jsr     LF0FF                           ; 8DF6
        lda     #$05                            ; 8DF9
        jsr     LE096                           ; 8DFB
        lda     #$0E                            ; 8DFE
        jsr     LE992                           ; 8E00
        lda     #$03                            ; 8E03
        jsr     LE8C8                           ; 8E05
        lda     #$82                            ; 8E08
        sta     $0609                           ; 8E0A
        ldx     #$08                            ; 8E0D
        jsr     LE0A4                           ; 8E0F
        jsr     L8A73                           ; 8E12
        lda     #$81                            ; 8E15
        sta     $0609                           ; 8E17
        lda     $94                             ; 8E1A
        jmp     L8D65                           ; 8E1C

; ----------------------------------------------------------------------------
L8E1F:  lda     L98EA,y                         ; 8E1F
        and     #$20                            ; 8E22
        bne     L8E29                           ; 8E24
L8E26:  jsr     LEC75                           ; 8E26
L8E29:  tya                                     ; 8E29
        pha                                     ; 8E2A
        txa                                     ; 8E2B
        pha                                     ; 8E2C
        lda     #$03                            ; 8E2D
        sta     $2E                             ; 8E2F
L8E31:  jsr     LF0B2                           ; 8E31
        lda     $18                             ; 8E34
        ora     $2E                             ; 8E36
        bne     L8E31                           ; 8E38
        jmp     L8BCF                           ; 8E3A

; ----------------------------------------------------------------------------
        jsr     L8E26                           ; 8E3D
        ldx     $0332                           ; 8E40
        bne     L8E47                           ; 8E43
        ldx     #$38                            ; 8E45
L8E47:  stx     $0333                           ; 8E47
L8E4A:  lda     $0601,x                         ; 8E4A
        beq     L8EB9                           ; 8E4D
        lda     $0701,x                         ; 8E4F
        beq     L8EB9                           ; 8E52
        lda     $BE                             ; 8E54
        and     #$30                            ; 8E56
        beq     L8E61                           ; 8E58
        lda     $0707,x                         ; 8E5A
        and     #$04                            ; 8E5D
        bne     L8EB9                           ; 8E5F
L8E61:  jsr     LE0BF                           ; 8E61
        bcc     L8EB9                           ; 8E64
        lda     $02                             ; 8E66
        and     #$C0                            ; 8E68
        beq     L8EB9                           ; 8E6A
        sta     $02                             ; 8E6C
        ldy     $33                             ; 8E6E
        lda     L8EC2,y                         ; 8E70
        sta     $04                             ; 8E73
        and     #$C0                            ; 8E75
        cmp     $02                             ; 8E77
        bcc     L8EB9                           ; 8E79
        lda     $04                             ; 8E7B
        and     #$3F                            ; 8E7D
        sta     $00                             ; 8E7F
        lda     $0701,x                         ; 8E81
        beq     L8EB9                           ; 8E84
        clc                                     ; 8E86
        sbc     $00                             ; 8E87
        beq     L8E8D                           ; 8E89
        bcs     L8E8F                           ; 8E8B
L8E8D:  lda     #$00                            ; 8E8D
L8E8F:  sta     $0701,x                         ; 8E8F
        stx     $0333                           ; 8E92
        lda     #$34                            ; 8E95
        jsr     LE992                           ; 8E97
        jsr     L8E29                           ; 8E9A
        lda     $0701,x                         ; 8E9D
        bne     L8EA8                           ; 8EA0
        jsr     LE0BF                           ; 8EA2
        jsr     LE0C7                           ; 8EA5
L8EA8:  clc                                     ; 8EA8
        txa                                     ; 8EA9
        adc     #$08                            ; 8EAA
        sta     $0332                           ; 8EAC
        lda     #$00                            ; 8EAF
        sta     $33                             ; 8EB1
        sta     $0333                           ; 8EB3
        jmp     LF0B2                           ; 8EB6

; ----------------------------------------------------------------------------
L8EB9:  clc                                     ; 8EB9
        txa                                     ; 8EBA
        adc     #$08                            ; 8EBB
        tax                                     ; 8EBD
        bne     L8EC2                           ; 8EBE
        ldx     #$38                            ; 8EC0
L8EC2:  cpx     $0333                           ; 8EC2
        bne     L8E4A                           ; 8EC5
        beq     L8EA8                           ; 8EC7
        .byte   $42                             ; 8EC9
        bne     L8F0E                           ; 8ECA
        dey                                     ; 8ECC
        .byte   $D4                             ; 8ECD
        jsr     LF154                           ; 8ECE
        jsr     LF082                           ; 8ED1
        ldx     #$B8                            ; 8ED4
        lda     #$06                            ; 8ED6
        sta     $00                             ; 8ED8
        sta     $0600,x                         ; 8EDA
        lda     #$2B                            ; 8EDD
        sta     $0601,x                         ; 8EDF
        lda     #$2C                            ; 8EE2
        sta     $01                             ; 8EE4
        lda     #$00                            ; 8EE6
        sta     $02                             ; 8EE8
        sta     $0704,x                         ; 8EEA
        lda     #$60                            ; 8EED
        sta     $0602,x                         ; 8EEF
        lda     #$80                            ; 8EF2
        sta     $0603,x                         ; 8EF4
        jsr     LFA29                           ; 8EF7
        lda     #$32                            ; 8EFA
        jsr     LE992                           ; 8EFC
L8EFF:  lda     $06B9                           ; 8EFF
        bne     L8F0E                           ; 8F02
        jsr     LE080                           ; 8F04
        jsr     LF07B                           ; 8F07
        jsr     LE95B                           ; 8F0A
        rts                                     ; 8F0D

; ----------------------------------------------------------------------------
L8F0E:  ldx     #$00                            ; 8F0E
L8F10:  cpx     #$B8                            ; 8F10
        bcc     L8F1A                           ; 8F12
        jsr     LE0D3                           ; 8F14
        jmp     L8F1D                           ; 8F17

; ----------------------------------------------------------------------------
L8F1A:  jsr     LE092                           ; 8F1A
L8F1D:  clc                                     ; 8F1D
        txa                                     ; 8F1E
        adc     #$08                            ; 8F1F
        tax                                     ; 8F21
        bne     L8F10                           ; 8F22
        lda     $07BC                           ; 8F24
        cmp     #$08                            ; 8F27
        bcc     L8F46                           ; 8F29
        lda     $7F                             ; 8F2B
        and     #$03                            ; 8F2D
        asl     a                               ; 8F2F
        asl     a                               ; 8F30
        asl     a                               ; 8F31
        asl     a                               ; 8F32
        lda     #$15                            ; 8F33
        ldy     #$0B                            ; 8F35
L8F37:  sta     $04A4,y                         ; 8F37
        dey                                     ; 8F3A
        bpl     L8F37                           ; 8F3B
        sta     $04B0                           ; 8F3D
        sta     $04BA                           ; 8F40
        jsr     LF07B                           ; 8F43
L8F46:  jsr     LE09E                           ; 8F46
        jsr     LF0B5                           ; 8F49
        jmp     L8EFF                           ; 8F4C

; ----------------------------------------------------------------------------
        lda     #$0A                            ; 8F4F
        ldy     $33                             ; 8F51
        cpy     #$0F                            ; 8F53
        beq     L8F59                           ; 8F55
        lda     #$32                            ; 8F57
L8F59:  clc                                     ; 8F59
        adc     $81                             ; 8F5A
        bcs     L8F62                           ; 8F5C
        cmp     $91                             ; 8F5E
        bcc     L8F64                           ; 8F60
L8F62:  lda     $91                             ; 8F62
L8F64:  sta     $81                             ; 8F64
        lda     #$1A                            ; 8F66
        jsr     LE992                           ; 8F68
        jsr     LEAB9                           ; 8F6B
        lda     #$00                            ; 8F6E
        sta     $33                             ; 8F70
        rts                                     ; 8F72

; ----------------------------------------------------------------------------
        jsr     LF154                           ; 8F73
        lda     #$A5                            ; 8F76
        sta     $23                             ; 8F78
        rts                                     ; 8F7A

; ----------------------------------------------------------------------------
        ldx     #$00                            ; 8F7B
        lda     #$E2                            ; 8F7D
        sta     $28                             ; 8F7F
        lda     $0707                           ; 8F81
        ora     #$01                            ; 8F84
        sta     $0707                           ; 8F86
        and     #$40                            ; 8F89
        bne     L8F9A                           ; 8F8B
        lda     #$01                            ; 8F8D
        jsr     LF0BE                           ; 8F8F
        jsr     LE0A4                           ; 8F92
        lda     #$00                            ; 8F95
        sta     $0700                           ; 8F97
L8F9A:  jsr     LEC7E                           ; 8F9A
        .byte   $4C                             ; 8F9D
L8F9E:  .byte   $7B                             ; 8F9E
        .byte   $F0                             ; 8F9F
L8FA0:  lda     $33                             ; 8FA0
        cmp     #$0C                            ; 8FA2
        bcc     L8FE0                           ; 8FA4
        cmp     #$0F                            ; 8FA6
        bcs     L8FE0                           ; 8FA8
        jsr     LE0BF                           ; 8FAA
        bcc     L8FE0                           ; 8FAD
        lda     $02                             ; 8FAF
        and     #$30                            ; 8FB1
        asl     a                               ; 8FB3
        asl     a                               ; 8FB4
        beq     L8FE0                           ; 8FB5
        sta     $02                             ; 8FB7
        ldy     $33                             ; 8FB9
        lda     L8FE2,y                         ; 8FBB
        sta     $04                             ; 8FBE
        and     #$C0                            ; 8FC0
        cmp     $02                             ; 8FC2
        .byte   $90                             ; 8FC4
L8FC5:  .byte   $1A                             ; 8FC5
        lda     $04                             ; 8FC6
        and     #$3F                            ; 8FC8
        sta     $04                             ; 8FCA
        lda     $0701,x                         ; 8FCC
        beq     L8FE0                           ; 8FCF
        sec                                     ; 8FD1
        sbc     $04                             ; 8FD2
        beq     L8FD8                           ; 8FD4
        bcs     L8FE1                           ; 8FD6
L8FD8:  lda     #$00                            ; 8FD8
        sta     $0701,x                         ; 8FDA
        jsr     LE0C5                           ; 8FDD
L8FE0:  rts                                     ; 8FE0

; ----------------------------------------------------------------------------
L8FE1:  .byte   $9D                             ; 8FE1
L8FE2:  ora     ($07,x)                         ; 8FE2
        lda     #$E0                            ; 8FE4
        sta     $0702,x                         ; 8FE6
        lda     #$34                            ; 8FE9
        jmp     LE992                           ; 8FEB

; ----------------------------------------------------------------------------
        .byte   $44                             ; 8FEE
        bcc     L8FC5                           ; 8FEF
L8FF1:  lda     $23                             ; 8FF1
        beq     L9038                           ; 8FF3
        lda     $33                             ; 8FF5
        cmp     #$13                            ; 8FF7
        bcc     L9038                           ; 8FF9
        cmp     #$16                            ; 8FFB
        bcs     L9038                           ; 8FFD
        jsr     LE0BF                           ; 8FFF
        bcc     L9038                           ; 9002
        lda     $02                             ; 9004
        and     #$0C                            ; 9006
        lsr     a                               ; 9008
        lsr     a                               ; 9009
        sta     $02                             ; 900A
        beq     L9038                           ; 900C
        lda     $33                             ; 900E
        beq     L9038                           ; 9010
        sec                                     ; 9012
        sbc     #$12                            ; 9013
        cmp     $02                             ; 9015
        bcc     L9038                           ; 9017
        sta     $02                             ; 9019
        lda     $0600,x                         ; 901B
        sta     $0606,x                         ; 901E
        lda     #$10                            ; 9021
        sta     $0600,x                         ; 9023
        lda     #$00                            ; 9026
        jsr     LF0BE                           ; 9028
        lda     $02                             ; 902B
        sta     $0607,x                         ; 902D
        lda     #$3C                            ; 9030
        sta     $0700,x                         ; 9032
        jsr     LE0A4                           ; 9035
L9038:  rts                                     ; 9038

; ----------------------------------------------------------------------------
L9039:  lda     $33                             ; 9039
        cmp     #$01                            ; 903B
        bne     L907E                           ; 903D
        jsr     LE0BF                           ; 903F
        bcc     L907E                           ; 9042
        lda     $02                             ; 9044
        and     #$02                            ; 9046
        beq     L907E                           ; 9048
        lda     $0600,x                         ; 904A
        cmp     #$18                            ; 904D
        bne     L9058                           ; 904F
        lda     $0601,x                         ; 9051
        and     #$0F                            ; 9054
        beq     L907E                           ; 9056
L9058:  lda     $0600,x                         ; 9058
        and     #$7F                            ; 905B
        cmp     #$10                            ; 905D
        beq     L907F                           ; 905F
L9061:  sta     $0600,x                         ; 9061
        sta     $0606,x                         ; 9064
        lda     #$01                            ; 9067
        jsr     LF0BE                           ; 9069
        lda     #$3B                            ; 906C
        jsr     LE992                           ; 906E
        lda     #$3C                            ; 9071
        sta     $0700,x                         ; 9073
        lda     #$00                            ; 9076
        sta     $0701,x                         ; 9078
        jsr     LE0C3                           ; 907B
L907E:  rts                                     ; 907E

; ----------------------------------------------------------------------------
L907F:  lda     $0606,x                         ; 907F
        jmp     L9061                           ; 9082

; ----------------------------------------------------------------------------
        jsr     LF082                           ; 9085
        jsr     LF085                           ; 9088
        lda     $FF                             ; 908B
        jsr     LE992                           ; 908D
        lda     #$25                            ; 9090
        jsr     LE992                           ; 9092
L9095:  ldx     #$00                            ; 9095
L9097:  lda     $0600,x                         ; 9097
        cmp     #$0C                            ; 909A
        bne     L90B2                           ; 909C
        jsr     LE0D3                           ; 909E
        txa                                     ; 90A1
        bne     L90B5                           ; 90A2
        jsr     LEC75                           ; 90A4
        lda     #$09                            ; 90A7
        jsr     LE096                           ; 90A9
        jsr     L8BB5                           ; 90AC
        jmp     LE082                           ; 90AF

; ----------------------------------------------------------------------------
L90B2:  jsr     LE092                           ; 90B2
L90B5:  clc                                     ; 90B5
        txa                                     ; 90B6
        adc     #$08                            ; 90B7
        tax                                     ; 90B9
        bne     L9097                           ; 90BA
        jsr     LE09E                           ; 90BC
        jsr     LF0B5                           ; 90BF
        jmp     L9095                           ; 90C2

; ----------------------------------------------------------------------------
L90C5:  lda     $82                             ; 90C5
        cmp     #$04                            ; 90C7
        bne     L90E7                           ; 90C9
        lda     $88                             ; 90CB
        bne     L90E7                           ; 90CD
        lda     $AB                             ; 90CF
        cmp     #$1A                            ; 90D1
        bne     L90E7                           ; 90D3
        lda     $0322                           ; 90D5
        cmp     #$06                            ; 90D8
        bne     L90E7                           ; 90DA
        lda     $0605                           ; 90DC
        cmp     #$68                            ; 90DF
        beq     L90E8                           ; 90E1
        cmp     #$69                            ; 90E3
        beq     L90E8                           ; 90E5
L90E7:  rts                                     ; 90E7

; ----------------------------------------------------------------------------
L90E8:  inc     $88                             ; 90E8
        jsr     LEC75                           ; 90EA
        lda     #$19                            ; 90ED
        sta     $2E                             ; 90EF
        lda     #$83                            ; 90F1
        jsr     LE992                           ; 90F3
L90F6:  jsr     LF0B2                           ; 90F6
        lda     $2E                             ; 90F9
        bne     L90F6                           ; 90FB
        jsr     LEC71                           ; 90FD
        jsr     LE89D                           ; 9100
        jmp     L94E2                           ; 9103

; ----------------------------------------------------------------------------
L9106:  lda     #$06                            ; 9106
        sta     $C3                             ; 9108
        rts                                     ; 910A

; ----------------------------------------------------------------------------
        jsr     L8FA0                           ; 910B
        jsr     L8FF1                           ; 910E
        jmp     L9039                           ; 9111

; ----------------------------------------------------------------------------
L9114:  sty     $3C                             ; 9114
        ldy     #$00                            ; 9116
L9118:  cmp     L9166,y                         ; 9118
        bcc     L9121                           ; 911B
        iny                                     ; 911D
        iny                                     ; 911E
        bne     L9118                           ; 911F
L9121:  sec                                     ; 9121
        sbc     L9164,y                         ; 9122
        sta     $EC                             ; 9125
        lda     L9163,y                         ; 9127
        sta     $AD                             ; 912A
        lda     #$00                            ; 912C
        sta     $AE                             ; 912E
        lda     #$05                            ; 9130
        sta     $AF                             ; 9132
        ldy     $3C                             ; 9134
        lda     #$00                            ; 9136
        sta     $EA                             ; 9138
        lda     #$06                            ; 913A
        sta     $EB                             ; 913C
        bne     L914C                           ; 913E
L9140:  lda     #$17                            ; 9140
        sta     $AD                             ; 9142
        lda     #$00                            ; 9144
        sta     $AE                             ; 9146
        lda     #$00                            ; 9148
        sta     $AF                             ; 914A
L914C:  lda     $10                             ; 914C
        and     #$7F                            ; 914E
        sta     PPU_CTRL                        ; 9150
        lda     #$FF                            ; 9153
        sta     $18                             ; 9155
        lda     $AD                             ; 9157
        ora     #$80                            ; 9159
        sta     $AD                             ; 915B
        lda     $10                             ; 915D
        sta     PPU_CTRL                        ; 915F
        rts                                     ; 9162

; ----------------------------------------------------------------------------
L9163:  brk                                     ; 9163
L9164:  brk                                     ; 9164
        .byte   $01                             ; 9165
L9166:  bit     $02                             ; 9166
        bmi     L916D                           ; 9168
        rti                                     ; 916A

; ----------------------------------------------------------------------------
        .byte   $04                             ; 916B
        .byte   $50                             ; 916C
L916D:  ora     $60                             ; 916D
        .byte   $07                             ; 916F
        bvs     L917A                           ; 9170
        .byte   $82                             ; 9172
        asl     a                               ; 9173
        bcc     L9181                           ; 9174
        ldy     #$0C                            ; 9176
        bcs     L9187                           ; 9178
L917A:  cpy     #$FF                            ; 917A
        .byte   $FF                             ; 917C
L917D:  jsr     LF510                           ; 917D
        .byte   $20                             ; 9180
L9181:  .byte   $6B                             ; 9181
        .byte   $F4                             ; 9182
        sta     $00                             ; 9183
        beq     L919B                           ; 9185
L9187:  bmi     L919B                           ; 9187
        lda     $0701,x                         ; 9189
        bmi     L91B3                           ; 918C
        lda     #$80                            ; 918E
        sta     $0701,x                         ; 9190
        lda     $0601,x                         ; 9193
        and     #$0F                            ; 9196
        jmp     L9114                           ; 9198

; ----------------------------------------------------------------------------
L919B:  lda     $0701,x                         ; 919B
        bpl     L91A3                           ; 919E
        lsr     $0701,x                         ; 91A0
L91A3:  lda     $0605,x                         ; 91A3
        cmp     $0318                           ; 91A6
        beq     L91B0                           ; 91A9
        cmp     $0317                           ; 91AB
        bne     L91B3                           ; 91AE
L91B0:  stx     $0319                           ; 91B0
L91B3:  lda     $00                             ; 91B3
        and     #$80                            ; 91B5
        rts                                     ; 91B7

; ----------------------------------------------------------------------------
L91B8:  lda     $0601,x                         ; 91B8
        and     #$0F                            ; 91BB
        sta     $0601,x                         ; 91BD
        lda     $0601                           ; 91C0
        and     #$C0                            ; 91C3
        beq     L91CC                           ; 91C5
        eor     #$C0                            ; 91C7
        jmp     L91D3                           ; 91C9

; ----------------------------------------------------------------------------
L91CC:  lda     $0601                           ; 91CC
        and     #$30                            ; 91CF
        eor     #$30                            ; 91D1
L91D3:  ora     $0601,x                         ; 91D3
        sta     $0601,x                         ; 91D6
        jmp     LE0A4                           ; 91D9

; ----------------------------------------------------------------------------
        ldx     $0319                           ; 91DC
        bne     L91E2                           ; 91DF
        rts                                     ; 91E1

; ----------------------------------------------------------------------------
L91E2:  lda     $0600,x                         ; 91E2
        lsr     a                               ; 91E5
        bcs     L91EC                           ; 91E6
        lda     #$6D                            ; 91E8
        bne     L91FC                           ; 91EA
L91EC:  lda     $0701,x                         ; 91EC
        clc                                     ; 91EF
        beq     L9202                           ; 91F0
        sta     $0702,x                         ; 91F2
        lda     $0601,x                         ; 91F5
        and     #$0F                            ; 91F8
        adc     #$10                            ; 91FA
L91FC:  jsr     L9114                           ; 91FC
        jmp     L8BB5                           ; 91FF

; ----------------------------------------------------------------------------
L9202:  lda     $0601,x                         ; 9202
        pha                                     ; 9205
        and     #$0F                            ; 9206
        tay                                     ; 9208
        cmp     #$0A                            ; 9209
        bcc     L921D                           ; 920B
        lda     $0337                           ; 920D
        beq     L9217                           ; 9210
        lda     $03C4                           ; 9212
        bne     L921D                           ; 9215
L9217:  tya                                     ; 9217
        clc                                     ; 9218
        adc     #$10                            ; 9219
        bne     L9220                           ; 921B
L921D:  lda     $05F0,y                         ; 921D
L9220:  jsr     L9114                           ; 9220
        jsr     L91B8                           ; 9223
        jsr     L8BB5                           ; 9226
        pla                                     ; 9229
        sta     $0601,x                         ; 922A
        sta     $0702,x                         ; 922D
        jmp     LE0A4                           ; 9230

; ----------------------------------------------------------------------------
        jsr     LE5AA                           ; 9233
        lda     #$81                            ; 9236
        jsr     LE9EB                           ; 9238
        lda     #$1F                            ; 923B
        jsr     LE8C8                           ; 923D
        lda     #$61                            ; 9240
        jsr     LE096                           ; 9242
        jsr     LEA7E                           ; 9245
        jsr     LE090                           ; 9248
        jsr     L92C2                           ; 924B
        lda     #$60                            ; 924E
        jsr     LE992                           ; 9250
        jsr     L9287                           ; 9253
        lda     #$0C                            ; 9256
        sta     $2F                             ; 9258
        jsr     LF09B                           ; 925A
L925D:  lda     $2F                             ; 925D
        beq     L9264                           ; 925F
        jsr     L92D5                           ; 9261
L9264:  jsr     L92AE                           ; 9264
        bne     L925D                           ; 9267
        lda     #$01                            ; 9269
        sta     $0600                           ; 926B
        lda     #$08                            ; 926E
        sta     $2F                             ; 9270
L9272:  jsr     L92AE                           ; 9272
        lda     $2F                             ; 9275
        bne     L9272                           ; 9277
        sta     $0600                           ; 9279
        sta     $95                             ; 927C
        tax                                     ; 927E
        lda     #$01                            ; 927F
        jsr     LF0BE                           ; 9281
        jmp     LE5AA                           ; 9284

; ----------------------------------------------------------------------------
L9287:  lda     $1E                             ; 9287
        and     #$04                            ; 9289
        beq     L928F                           ; 928B
        lda     #$03                            ; 928D
L928F:  tay                                     ; 928F
        ldx     #$00                            ; 9290
L9292:  lda     L92A8,y                         ; 9292
        sta     $04A5,x                         ; 9295
        iny                                     ; 9298
        inx                                     ; 9299
        cpx     #$03                            ; 929A
        bne     L9292                           ; 929C
        lda     $1E                             ; 929E
        and     #$03                            ; 92A0
        bne     L92A7                           ; 92A2
        jmp     LF07B                           ; 92A4

; ----------------------------------------------------------------------------
L92A7:  rts                                     ; 92A7

; ----------------------------------------------------------------------------
L92A8:  .byte   $27                             ; 92A8
        jsr     L2712                           ; 92A9
        .byte   $20                             ; 92AC
        .byte   $0F                             ; 92AD
L92AE:  ldx     #$00                            ; 92AE
        jsr     LE0D3                           ; 92B0
        jsr     LE09E                           ; 92B3
        jsr     L9287                           ; 92B6
        jsr     LE95B                           ; 92B9
        ldx     #$00                            ; 92BC
        lda     $0704,x                         ; 92BE
        rts                                     ; 92C1

; ----------------------------------------------------------------------------
L92C2:  lda     #$80                            ; 92C2
        sta     $B1                             ; 92C4
        ldx     #$00                            ; 92C6
        lda     #$09                            ; 92C8
        jsr     LF0BE                           ; 92CA
        lda     #$00                            ; 92CD
        jsr     LF951                           ; 92CF
        jsr     LE0A4                           ; 92D2
L92D5:  ldx     #$00                            ; 92D5
        lda     #$10                            ; 92D7
        sta     $0704,x                         ; 92D9
        lda     #$30                            ; 92DC
        sta     $0700,x                         ; 92DE
        rts                                     ; 92E1

; ----------------------------------------------------------------------------
L92E2:  lda     $03DF                           ; 92E2
        bne     L92EC                           ; 92E5
        lda     #$3C                            ; 92E7
        sta     $03DF                           ; 92E9
L92EC:  dec     $03DF                           ; 92EC
        bne     L9328                           ; 92EF
        jsr     L947A                           ; 92F1
        lda     $03DD                           ; 92F4
        beq     L9313                           ; 92F7
        dec     $03DD                           ; 92F9
        bne     L9313                           ; 92FC
        lda     $72                             ; 92FE
        cmp     #$06                            ; 9300
        bne     L9313                           ; 9302
        lda     #$02                            ; 9304
        sta     $72                             ; 9306
        sta     $74                             ; 9308
        lda     #$14                            ; 930A
        sta     $73                             ; 930C
        lda     #$4D                            ; 930E
        jsr     L887B                           ; 9310
L9313:  lda     $03DE                           ; 9313
        bne     L931D                           ; 9316
        lda     #$3C                            ; 9318
        sta     $03DE                           ; 931A
L931D:  dec     $03DE                           ; 931D
        bne     L9328                           ; 9320
        jsr     L9329                           ; 9322
        jsr     L9416                           ; 9325
L9328:  rts                                     ; 9328

; ----------------------------------------------------------------------------
L9329:  lda     $03DC                           ; 9329
        beq     L9366                           ; 932C
        dec     $03DC                           ; 932E
        bne     L9328                           ; 9331
        lda     $03D9                           ; 9333
        ora     $03DA                           ; 9336
        ora     $03DB                           ; 9339
        beq     L9328                           ; 933C
        jsr     L9381                           ; 933E
        bcs     L9357                           ; 9341
        lda     #$00                            ; 9343
        jsr     L9372                           ; 9345
        jsr     LE0AF                           ; 9348
L934B:  lda     $03D9                           ; 934B
        asl     a                               ; 934E
        tay                                     ; 934F
        lda     L94FB,y                         ; 9350
        sta     $03DC                           ; 9353
        rts                                     ; 9356

; ----------------------------------------------------------------------------
L9357:  lda     #$FF                            ; 9357
        jsr     L9372                           ; 9359
        jsr     LE5AA                           ; 935C
        lda     #$00                            ; 935F
        sta     $80                             ; 9361
        pla                                     ; 9363
        pla                                     ; 9364
        rts                                     ; 9365

; ----------------------------------------------------------------------------
L9366:  lda     $03D9                           ; 9366
        ora     $03DA                           ; 9369
        ora     $03DB                           ; 936C
        bne     L934B                           ; 936F
        rts                                     ; 9371

; ----------------------------------------------------------------------------
L9372:  pha                                     ; 9372
        jsr     LE891                           ; 9373
        pla                                     ; 9376
        jsr     LE01D                           ; 9377
        lda     #$FF                            ; 937A
        sta     $6D                             ; 937C
        jmp     LE992                           ; 937E

; ----------------------------------------------------------------------------
L9381:  lda     #$00                            ; 9381
        tax                                     ; 9383
L9384:  sta     $00,x                           ; 9384
        inx                                     ; 9386
        cpx     #$05                            ; 9387
        bne     L9384                           ; 9389
        lda     $03D9                           ; 938B
        asl     a                               ; 938E
        tay                                     ; 938F
        lda     L94FC,y                         ; 9390
        sta     $05                             ; 9393
L9395:  ldy     #$04                            ; 9395
        lda     $05                             ; 9397
        beq     L93AF                           ; 9399
        sec                                     ; 939B
        sbc     #$0A                            ; 939C
        bcc     L93A6                           ; 939E
        sta     $05                             ; 93A0
        dey                                     ; 93A2
        jmp     L93A8                           ; 93A3

; ----------------------------------------------------------------------------
L93A6:  dec     $05                             ; 93A6
L93A8:  jsr     L93DC                           ; 93A8
        bcc     L9395                           ; 93AB
        bcs     L93C4                           ; 93AD
L93AF:  ldy     #$02                            ; 93AF
        sec                                     ; 93B1
        lda     $03                             ; 93B2
        beq     L93BD                           ; 93B4
        jsr     L93F3                           ; 93B6
        bcc     L93BD                           ; 93B9
        bcs     L93C4                           ; 93BB
L93BD:  ldx     #$02                            ; 93BD
        ldy     #$02                            ; 93BF
        jsr     L93DC                           ; 93C1
L93C4:  php                                     ; 93C4
        ldx     #$02                            ; 93C5
L93C7:  lda     $00,x                           ; 93C7
        sta     $03D9,x                         ; 93C9
        clc                                     ; 93CC
        adc     $05                             ; 93CD
        sta     $05                             ; 93CF
        dex                                     ; 93D1
        bpl     L93C7                           ; 93D2
        plp                                     ; 93D4
        bcs     L93DB                           ; 93D5
        lda     $05                             ; 93D7
        cmp     #$1B                            ; 93D9
L93DB:  rts                                     ; 93DB

; ----------------------------------------------------------------------------
L93DC:  ldx     #$02                            ; 93DC
        clc                                     ; 93DE
L93DF:  lda     $03D9,x                         ; 93DF
        adc     $00,y                           ; 93E2
        cmp     #$0A                            ; 93E5
        bcc     L93EC                           ; 93E7
        sbc     #$0A                            ; 93E9
        sec                                     ; 93EB
L93EC:  sta     $00,y                           ; 93EC
        dey                                     ; 93EF
        dex                                     ; 93F0
        bpl     L93DF                           ; 93F1
L93F3:  bcc     L9415                           ; 93F3
        tya                                     ; 93F5
        bmi     L940B                           ; 93F6
        lda     $00,y                           ; 93F8
        adc     #$00                            ; 93FB
        cmp     #$0A                            ; 93FD
        bne     L9404                           ; 93FF
        lda     #$00                            ; 9401
        sec                                     ; 9403
L9404:  sta     $00,y                           ; 9404
        dey                                     ; 9407
        jmp     L93F3                           ; 9408

; ----------------------------------------------------------------------------
L940B:  ldy     #$04                            ; 940B
        lda     #$09                            ; 940D
L940F:  sta     $00,y                           ; 940F
        dey                                     ; 9412
        bpl     L940F                           ; 9413
L9415:  rts                                     ; 9415

; ----------------------------------------------------------------------------
L9416:  lda     $03FC                           ; 9416
        beq     L943D                           ; 9419
        dec     $03FC                           ; 941B
        bne     L9479                           ; 941E
L9420:  lda     #$0A                            ; 9420
        sta     $03FB                           ; 9422
        jsr     LEAB5                           ; 9425
        lda     $03FA                           ; 9428
        beq     L9479                           ; 942B
        lda     #$00                            ; 942D
        sta     $03FA                           ; 942F
        lda     $03F8                           ; 9432
        bne     L9479                           ; 9435
        jsr     LF082                           ; 9437
        jmp     L9468                           ; 943A

; ----------------------------------------------------------------------------
L943D:  lda     $03FB                           ; 943D
        beq     L9420                           ; 9440
        dec     $03FB                           ; 9442
        bne     L9479                           ; 9445
        lda     #$01                            ; 9447
        sta     $03FA                           ; 9449
        lda     $E3                             ; 944C
        and     #$0F                            ; 944E
        cmp     #$0A                            ; 9450
        bcc     L9455                           ; 9452
        lsr     a                               ; 9454
L9455:  sta     $03FC                           ; 9455
        inc     $03FC                           ; 9458
        lda     $03C0                           ; 945B
        beq     L9465                           ; 945E
        lda     #$4C                            ; 9460
        jsr     LE096                           ; 9462
L9465:  jsr     LF085                           ; 9465
L9468:  lda     #$02                            ; 9468
        sta     $2F                             ; 946A
L946C:  jsr     LF0B2                           ; 946C
        lda     $2F                             ; 946F
        bne     L946C                           ; 9471
        jsr     LE080                           ; 9473
        jsr     LF07B                           ; 9476
L9479:  rts                                     ; 9479

; ----------------------------------------------------------------------------
L947A:  lda     $03F8                           ; 947A
        bne     L94A9                           ; 947D
        lda     $B0                             ; 947F
        and     #$F0                            ; 9481
        .byte   $C9                             ; 9483
L9484:  cpx     #$90                            ; 9484
        and     ($AD,x)                         ; 9486
        sbc     $D003,y                         ; 9488
        ora     $A9                             ; 948B
        asl     $8D                             ; 948D
        sbc     $CE03,y                         ; 948F
        sbc     $D003,y                         ; 9492
        .byte   $12                             ; 9495
        lda     $29                             ; 9496
        bne     L94A8                           ; 9498
        lda     $81                             ; 949A
        beq     L94A8                           ; 949C
        dec     $81                             ; 949E
        jsr     LEAB9                           ; 94A0
        lda     #$0A                            ; 94A3
        jsr     LE992                           ; 94A5
L94A8:  rts                                     ; 94A8

; ----------------------------------------------------------------------------
L94A9:  dec     $03F8                           ; 94A9
        bne     L94A8                           ; 94AC
        lda     #$00                            ; 94AE
        sta     $03F7                           ; 94B0
        sta     $03F9                           ; 94B3
        lda     $B0                             ; 94B6
        and     #$F0                            ; 94B8
        cmp     #$E0                            ; 94BA
        bcc     L94DA                           ; 94BC
        lda     #$08                            ; 94BE
        sta     $2F                             ; 94C0
L94C2:  jsr     LF0B2                           ; 94C2
        ldy     #$05                            ; 94C5
        lda     $2F                             ; 94C7
        lsr     a                               ; 94C9
        bcs     L94D4                           ; 94CA
        jsr     LE080                           ; 94CC
        jsr     LF07B                           ; 94CF
        ldy     #$00                            ; 94D2
L94D4:  sty     $18                             ; 94D4
        lda     $2F                             ; 94D6
        bne     L94C2                           ; 94D8
L94DA:  lda     #$4E                            ; 94DA
        jsr     LE096                           ; 94DC
        jmp     LE082                           ; 94DF

; ----------------------------------------------------------------------------
L94E2:  jsr     LE07A                           ; 94E2
L94E5:  jsr     LE07E                           ; 94E5
        jsr     LE080                           ; 94E8
        jsr     LE076                           ; 94EB
        lda     $B8                             ; 94EE
        and     #$3F                            ; 94F0
        jsr     LE8C8                           ; 94F2
        jsr     LE8A8                           ; 94F5
        jmp     LE082                           ; 94F8

; ----------------------------------------------------------------------------
L94FB:  .byte   $1E                             ; 94FB
L94FC:  .byte   $02                             ; 94FC
        asl     $1E02,x                         ; 94FD
        .byte   $04                             ; 9500
        asl     $1404,x                         ; 9501
        php                                     ; 9504
        .byte   $14                             ; 9505
        php                                     ; 9506
        .byte   $14                             ; 9507
        php                                     ; 9508
        .byte   $14                             ; 9509
        php                                     ; 950A
        asl     a                               ; 950B
        .byte   $0C                             ; 950C
        asl     a                               ; 950D
        .byte   $0C                             ; 950E
L950F:  cmp     #$1D                            ; 950F
        beq     L955B                           ; 9511
        cmp     #$18                            ; 9513
        bcc     L955B                           ; 9515
        ldy     $B1                             ; 9517
        bmi     L9576                           ; 9519
        ldy     $03FC                           ; 951B
        beq     L9576                           ; 951E
        cmp     #$1B                            ; 9520
        bcc     L957F                           ; 9522
        lda     $B0                             ; 9524
        and     #$F0                            ; 9526
        cmp     #$E0                            ; 9528
        bcc     L9576                           ; 952A
        ldy     $33                             ; 952C
        cmp     #$F0                            ; 952E
        bne     L9538                           ; 9530
        cpy     #$1C                            ; 9532
        bne     L9576                           ; 9534
        beq     L953C                           ; 9536
L9538:  cpy     #$1B                            ; 9538
        bne     L9576                           ; 953A
L953C:  lda     $19                             ; 953C
        bne     L9576                           ; 953E
        bit     $BF                             ; 9540
        bvs     L954C                           ; 9542
        lda     $B2                             ; 9544
        beq     L954C                           ; 9546
        cmp     #$30                            ; 9548
        bcc     L9576                           ; 954A
L954C:  lda     #$00                            ; 954C
        sta     $03FC                           ; 954E
        jsr     LEAB5                           ; 9551
        jmp     L955B                           ; 9554

; ----------------------------------------------------------------------------
        lda     #$00                            ; 9557
        sta     $33                             ; 9559
L955B:  ldy     $33                             ; 955B
        lda     L99D8,y                         ; 955D
        beq     L956E                           ; 9560
        tay                                     ; 9562
        lda     $0300,y                         ; 9563
        beq     L956E                           ; 9566
        sec                                     ; 9568
        sbc     #$01                            ; 9569
        sta     $0300,y                         ; 956B
L956E:  lda     $33                             ; 956E
        asl     a                               ; 9570
        asl     a                               ; 9571
        asl     a                               ; 9572
        tay                                     ; 9573
        clc                                     ; 9574
        rts                                     ; 9575

; ----------------------------------------------------------------------------
L9576:  lda     #$00                            ; 9576
        sta     $33                             ; 9578
        jsr     LF2B4                           ; 957A
        sec                                     ; 957D
        rts                                     ; 957E

; ----------------------------------------------------------------------------
L957F:  lda     $19                             ; 957F
        bne     L9576                           ; 9581
        bit     $BF                             ; 9583
        bvs     L955B                           ; 9585
        lda     $B2                             ; 9587
        beq     L955B                           ; 9589
        cmp     #$30                            ; 958B
        bcs     L955B                           ; 958D
        bcc     L9576                           ; 958F
        jmp     LE5AA                           ; 9591

; ----------------------------------------------------------------------------
L9594:  ldx     #$14                            ; 9594
        lda     #$F4                            ; 9596
L9598:  sta     $0200,x                         ; 9598
        inx                                     ; 959B
        bne     L9598                           ; 959C
        ldx     #$10                            ; 959E
L95A0:  lda     $0600,x                         ; 95A0
        cmp     #$0B                            ; 95A3
        beq     L95AC                           ; 95A5
        lda     #$00                            ; 95A7
        sta     $0601,x                         ; 95A9
L95AC:  clc                                     ; 95AC
        txa                                     ; 95AD
        adc     #$08                            ; 95AE
        tax                                     ; 95B0
        bne     L95A0                           ; 95B1
        sta     $71                             ; 95B3
        sta     $93                             ; 95B5
        lda     #$04                            ; 95B7
        sta     $2F                             ; 95B9
L95BB:  jsr     LF085                           ; 95BB
L95BE:  jsr     LF0B2                           ; 95BE
        lda     $2F                             ; 95C1
        beq     L95CD                           ; 95C3
        lda     $7F                             ; 95C5
        and     #$0F                            ; 95C7
        bne     L95BE                           ; 95C9
        beq     L95BB                           ; 95CB
L95CD:  lda     #$00                            ; 95CD
        sta     $0E                             ; 95CF
        sta     $0F                             ; 95D1
        lda     #$FF                            ; 95D3
        jsr     LE992                           ; 95D5
        lda     $0601                           ; 95D8
        pha                                     ; 95DB
        lda     #$22                            ; 95DC
        sta     $0601                           ; 95DE
        ldx     #$00                            ; 95E1
        jsr     LE0A4                           ; 95E3
        lda     #$1B                            ; 95E6
        jsr     LE8C8                           ; 95E8
L95EB:  ldy     $0E                             ; 95EB
        lda     L9627,y                         ; 95ED
        cmp     #$FF                            ; 95F0
        beq     L9618                           ; 95F2
        sta     $0D                             ; 95F4
        lda     L9628,y                         ; 95F6
        sta     $0F                             ; 95F9
        iny                                     ; 95FB
        iny                                     ; 95FC
        sty     $0E                             ; 95FD
        lda     $0D                             ; 95FF
        beq     L9608                           ; 9601
        lda     #$39                            ; 9603
        jsr     LE992                           ; 9605
L9608:  lda     $0D                             ; 9608
        beq     L960F                           ; 960A
        jsr     LE078                           ; 960C
L960F:  jsr     LF0B2                           ; 960F
        dec     $0F                             ; 9612
        bne     L9608                           ; 9614
        beq     L95EB                           ; 9616
L9618:  jsr     LE5AA                           ; 9618
        jsr     LF0B8                           ; 961B
        pla                                     ; 961E
L961F:  sta     $0601                           ; 961F
        ldx     #$00                            ; 9622
        jmp     LE0A4                           ; 9624

; ----------------------------------------------------------------------------
L9627:  brk                                     ; 9627
L9628:  ora     ($04,x)                         ; 9628
        asl     a                               ; 962A
        php                                     ; 962B
        php                                     ; 962C
        .byte   $0C                             ; 962D
        asl     $10                             ; 962E
        .byte   $04                             ; 9630
        .byte   $14                             ; 9631
        .byte   $02                             ; 9632
        brk                                     ; 9633
        bpl     L963A                           ; 9634
        asl     a                               ; 9636
        php                                     ; 9637
        php                                     ; 9638
        .byte   $0C                             ; 9639
L963A:  asl     $10                             ; 963A
        .byte   $04                             ; 963C
        .byte   $14                             ; 963D
        .byte   $02                             ; 963E
        brk                                     ; 963F
        asl     a                               ; 9640
        .byte   $14                             ; 9641
        ora     $00                             ; 9642
        asl     a                               ; 9644
        .byte   $14                             ; 9645
        ora     $00                             ; 9646
        asl     a                               ; 9648
        .byte   $14                             ; 9649
        ora     $FF                             ; 964A
        .byte   $FF                             ; 964C
        .byte   $FF                             ; 964D
        .byte   $FF                             ; 964E
        .byte   $FF                             ; 964F
        .byte   $FF                             ; 9650
        lda     #$05                            ; 9651
        sta     $A9                             ; 9653
        ora     $85                             ; 9655
        .byte   $72                             ; 9657
        rts                                     ; 9658

; ----------------------------------------------------------------------------
L9659:  jsr     LE891                           ; 9659
        lda     #$FF                            ; 965C
        jsr     LDE93                           ; 965E
L9661:  lda     #$00                            ; 9661
        sta     $6C                             ; 9663
        sta     $6D                             ; 9665
        jmp     L94E2                           ; 9667

; ----------------------------------------------------------------------------
        lda     #$05                            ; 966A
        sta     $030F                           ; 966C
        sta     $0310                           ; 966F
        sta     $0312                           ; 9672
        lda     #$05                            ; 9675
        sta     $0313                           ; 9677
        lda     #$0A                            ; 967A
        sta     $0306                           ; 967C
        sta     $0307                           ; 967F
        lda     #$0F                            ; 9682
        sta     $0311                           ; 9684
        lda     #$09                            ; 9687
        sta     $0300                           ; 9689
        sta     $0301                           ; 968C
        sta     $89                             ; 968F
        sta     $8A                             ; 9691
        sta     $8B                             ; 9693
        lda     #$00                            ; 9695
        sta     $03D9                           ; 9697
        sta     $03DA                           ; 969A
        sta     $03DB                           ; 969D
        sta     $03DC                           ; 96A0
        jsr     LE891                           ; 96A3
        lda     #$FF                            ; 96A6
        jsr     LE01B                           ; 96A8
        jmp     L9661                           ; 96AB

; ----------------------------------------------------------------------------
L96AE:  jsr     LE891                           ; 96AE
        lda     #$FF                            ; 96B1
        jsr     LE019                           ; 96B3
        jmp     L9661                           ; 96B6

; ----------------------------------------------------------------------------
L96B9:  jsr     L9594                           ; 96B9
        lda     $0601                           ; 96BC
        pha                                     ; 96BF
        lda     #$22                            ; 96C0
        jsr     L961F                           ; 96C2
        jsr     LF09B                           ; 96C5
        lda     #$08                            ; 96C8
        sta     $2F                             ; 96CA
        lda     #$1E                            ; 96CC
        jsr     LE992                           ; 96CE
        lda     #$4F                            ; 96D1
        jsr     LE096                           ; 96D3
L96D6:  jsr     LE098                           ; 96D6
        jsr     LF0B2                           ; 96D9
        lda     $18                             ; 96DC
        bne     L96D6                           ; 96DE
        lda     $2F                             ; 96E0
        bne     L96D6                           ; 96E2
        lda     #$07                            ; 96E4
        sta     $2F                             ; 96E6
L96E8:  jsr     L9712                           ; 96E8
        lda     $2F                             ; 96EB
        bne     L96E8                           ; 96ED
        lda     #$01                            ; 96EF
        sta     $03F7                           ; 96F1
        lda     #$B4                            ; 96F4
        sta     $03F8                           ; 96F6
        lda     #$FF                            ; 96F9
        jsr     LE992                           ; 96FB
        pla                                     ; 96FE
        jsr     L961F                           ; 96FF
L9702:  lda     $B8                             ; 9702
        and     #$3F                            ; 9704
        jsr     LE8C8                           ; 9706
        jsr     LE080                           ; 9709
        jsr     LF07B                           ; 970C
        jmp     LE082                           ; 970F

; ----------------------------------------------------------------------------
L9712:  lda     $81                             ; 9712
        cmp     $91                             ; 9714
        beq     L9722                           ; 9716
        inc     $81                             ; 9718
        jsr     LEAB9                           ; 971A
        lda     #$03                            ; 971D
        jsr     LE992                           ; 971F
L9722:  jmp     LF0B2                           ; 9722

; ----------------------------------------------------------------------------
L9725:  jsr     L9594                           ; 9725
        lda     $0601                           ; 9728
        pha                                     ; 972B
        lda     #$22                            ; 972C
        jsr     L961F                           ; 972E
        jsr     LF09B                           ; 9731
        lda     #$10                            ; 9734
        sta     $2F                             ; 9736
        lda     #$00                            ; 9738
        sta     $0F                             ; 973A
L973C:  lda     $7F                             ; 973C
        and     #$0F                            ; 973E
        bne     L975B                           ; 9740
        ldy     $0F                             ; 9742
        lda     L977B,y                         ; 9744
        iny                                     ; 9747
        cpy     #$03                            ; 9748
        bne     L974E                           ; 974A
        ldy     #$00                            ; 974C
L974E:  sty     $0F                             ; 974E
        ldy     #$0B                            ; 9750
L9752:  sta     $04A4,y                         ; 9752
        dey                                     ; 9755
        bpl     L9752                           ; 9756
        jsr     LF07B                           ; 9758
L975B:  jsr     L9712                           ; 975B
        lda     $2F                             ; 975E
        bne     L973C                           ; 9760
        lda     #$02                            ; 9762
        sta     $03F7                           ; 9764
        lda     #$FF                            ; 9767
        sta     $03F8                           ; 9769
        pla                                     ; 976C
        jsr     L961F                           ; 976D
        jsr     L9702                           ; 9770
        lda     #$50                            ; 9773
        jsr     LE096                           ; 9775
        jmp     L8BB5                           ; 9778

; ----------------------------------------------------------------------------
L977B:  rol     $20                             ; 977B
        rol     a                               ; 977D
        lda     #$51                            ; 977E
        jsr     L887B                           ; 9780
L9783:  jsr     LF0B5                           ; 9783
        lda     $18                             ; 9786
        bne     L9783                           ; 9788
        rts                                     ; 978A

; ----------------------------------------------------------------------------
        jsr     LF70B                           ; 978B
        sec                                     ; 978E
        lda     $00                             ; 978F
        sbc     $85                             ; 9791
        lda     $01                             ; 9793
        sbc     $86                             ; 9795
        bcs     L97A1                           ; 9797
        lda     $00                             ; 9799
        sta     $85                             ; 979B
        lda     $01                             ; 979D
        sta     $86                             ; 979F
L97A1:  jmp     L97A4                           ; 97A1

; ----------------------------------------------------------------------------
L97A4:  lda     $84                             ; 97A4
        cmp     #$18                            ; 97A6
        bcs     L97EB                           ; 97A8
        asl     a                               ; 97AA
        asl     a                               ; 97AB
        tay                                     ; 97AC
        sec                                     ; 97AD
        lda     L97EC,y                         ; 97AE
        sbc     $85                             ; 97B1
        lda     L97ED,y                         ; 97B3
        sbc     $86                             ; 97B6
        bcs     L97EB                           ; 97B8
        inc     $84                             ; 97BA
        lda     L97EE,y                         ; 97BC
        sta     $03ED                           ; 97BF
        lda     L97EF,y                         ; 97C2
        tay                                     ; 97C5
        lda     $0300,y                         ; 97C6
        bne     L97D2                           ; 97C9
        lda     #$01                            ; 97CB
        sta     $0300,y                         ; 97CD
        bne     L97DA                           ; 97D0
L97D2:  lda     $03ED                           ; 97D2
        and     #$F0                            ; 97D5
        sta     $03ED                           ; 97D7
L97DA:  lda     $81                             ; 97DA
        pha                                     ; 97DC
        jsr     LF6BA                           ; 97DD
        pla                                     ; 97E0
        sta     $81                             ; 97E1
        ldy     $84                             ; 97E3
        lda     $F67E,y                         ; 97E5
        sta     $03EF                           ; 97E8
L97EB:  rts                                     ; 97EB

; ----------------------------------------------------------------------------
L97EC:  .byte   $13                             ; 97EC
L97ED:  brk                                     ; 97ED
L97EE:  .byte   $81                             ; 97EE
L97EF:  and     #$4F                            ; 97EF
        brk                                     ; 97F1
        .byte   $C2                             ; 97F2
        .byte   $23                             ; 97F3
        .byte   $EF                             ; 97F4
        brk                                     ; 97F5
        .byte   $A3                             ; 97F6
        bmi     L9828                           ; 97F7
        .byte   $02                             ; 97F9
        cpy     #$00                            ; 97FA
        .byte   $7F                             ; 97FC
        .byte   $02                             ; 97FD
        .byte   $80                             ; 97FE
        brk                                     ; 97FF
        .byte   $0B                             ; 9800
        .byte   $03                             ; 9801
        ldy     $26                             ; 9802
        .byte   $D3                             ; 9804
        .byte   $03                             ; 9805
        cpy     #$00                            ; 9806
        .byte   $FF                             ; 9808
        .byte   $04                             ; 9809
        sbc     $2D                             ; 980A
        .byte   $07                             ; 980C
        .byte   $07                             ; 980D
        .byte   $80                             ; 980E
        brk                                     ; 980F
        .byte   $CF                             ; 9810
        .byte   $07                             ; 9811
        ldx     $24                             ; 9812
        .byte   $5F                             ; 9814
        ora     #$C0                            ; 9815
        brk                                     ; 9817
        .byte   $B7                             ; 9818
        .byte   $0B                             ; 9819
        .byte   $E7                             ; 981A
        rol     $0ED7                           ; 981B
L981E:  iny                                     ; 981E
        .byte   $27                             ; 981F
        .byte   $BF                             ; 9820
        .byte   $12                             ; 9821
        lda     #$31                            ; 9822
        .byte   $4F                             ; 9824
        .byte   $14                             ; 9825
        .byte   $80                             ; 9826
        brk                                     ; 9827
L9828:  .byte   $6F                             ; 9828
        .byte   $17                             ; 9829
        nop                                     ; 982A
        and     $1F                             ; 982B
        .byte   $1C                             ; 982D
        .byte   $80                             ; 982E
        brk                                     ; 982F
        .byte   $5F                             ; 9830
        .byte   $22                             ; 9831
        cpx     #$00                            ; 9832
        .byte   $2F                             ; 9834
        rol     a                               ; 9835
        .byte   $CB                             ; 9836
        .byte   $2F                             ; 9837
        .byte   $23                             ; 9838
        bit     $2AEC                           ; 9839
        ora     $31                             ; 983C
        cpy     #$00                            ; 983E
        cmp     $38,x                           ; 9840
        sbc     L9328                           ; 9842
        .byte   $43                             ; 9845
        txa                                     ; 9846
        brk                                     ; 9847
        .byte   $3F                             ; 9848
        eor     ($80),y                         ; 9849
        brk                                     ; 984B
        jsr     L98A6                           ; 984C
        lda     $031C                           ; 984F
        and     #$10                            ; 9852
        bne     L9881                           ; 9854
        lda     $031C                           ; 9856
        and     #$0F                            ; 9859
        beq     L98A0                           ; 985B
        sta     $00                             ; 985D
        lda     #$01                            ; 985F
        sta     $01                             ; 9861
        ldy     #$FF                            ; 9863
L9865:  iny                                     ; 9865
        asl     $01                             ; 9866
        lsr     $00                             ; 9868
        bcc     L9865                           ; 986A
        lda     $01                             ; 986C
        lsr     a                               ; 986E
        eor     $031C                           ; 986F
        sta     $031C                           ; 9872
        tya                                     ; 9875
        jsr     LE97D                           ; 9876
        cpy     $A1                             ; 9879
        beq     L981E                           ; 987B
        and     $7BA2,y                         ; 987D
        .byte   $A2                             ; 9880
L9881:  lda     $BF                             ; 9881
        bpl     L9898                           ; 9883
        lda     $0338                           ; 9885
        beq     L9898                           ; 9888
        lda     $03C6                           ; 988A
        beq     L9898                           ; 988D
        jsr     L98A1                           ; 988F
        lda     $64                             ; 9892
        cmp     #$02                            ; 9894
        bne     L98A0                           ; 9896
L9898:  lda     $031C                           ; 9898
        and     #$EF                            ; 989B
        sta     $031C                           ; 989D
L98A0:  rts                                     ; 98A0

; ----------------------------------------------------------------------------
L98A1:  jsr     LE17B                           ; 98A1
        .byte   $19                             ; 98A4
        .byte   $04                             ; 98A5
L98A6:  lda     $AC                             ; 98A6
        beq     L98A0                           ; 98A8
        lda     $7F                             ; 98AA
        and     #$07                            ; 98AC
        bne     L98A0                           ; 98AE
        ldy     #$11                            ; 98B0
        lda     $7F                             ; 98B2
        and     #$08                            ; 98B4
        bne     L98BA                           ; 98B6
        ldy     #$20                            ; 98B8
L98BA:  sty     $04AB                           ; 98BA
        jmp     LF07B                           ; 98BD

; ----------------------------------------------------------------------------
L98C0:  brk                                     ; 98C0
        .byte   $17                             ; 98C1
        jsr     L3D7E                           ; 98C2
        .byte   $42                             ; 98C5
        brk                                     ; 98C6
        brk                                     ; 98C7
        ora     #$34                            ; 98C8
        rol     $00                             ; 98CA
        lsr     a:$00                           ; 98CC
        brk                                     ; 98CF
        ora     ($2B,x)                         ; 98D0
        and     $3500                           ; 98D2
        .byte   $33                             ; 98D5
        brk                                     ; 98D6
        brk                                     ; 98D7
        rol     $28                             ; 98D8
        php                                     ; 98DA
        brk                                     ; 98DB
        sec                                     ; 98DC
        rts                                     ; 98DD

; ----------------------------------------------------------------------------
        brk                                     ; 98DE
        brk                                     ; 98DF
        jsr     L061C                           ; 98E0
        brk                                     ; 98E3
        brk                                     ; 98E4
        brk                                     ; 98E5
        brk                                     ; 98E6
        brk                                     ; 98E7
L98E8:  brk                                     ; 98E8
L98E9:  brk                                     ; 98E9
L98EA:  .byte   $26                             ; 98EA
L98EB:  brk                                     ; 98EB
L98EC:  brk                                     ; 98EC
L98ED:  brk                                     ; 98ED
L98EE:  brk                                     ; 98EE
L98EF:  brk                                     ; 98EF
        ora     ($74,x)                         ; 98F0
        rol     L8CA9,x                         ; 98F2
        asl     a:$00,x                         ; 98F5
        .byte   $02                             ; 98F8
        .byte   $1A                             ; 98F9
        rol     L8CCF,x                         ; 98FA
        brk                                     ; 98FD
        brk                                     ; 98FE
        brk                                     ; 98FF
        .byte   $03                             ; 9900
        brk                                     ; 9901
        inc     L8CFE,x                         ; 9902
        brk                                     ; 9905
        brk                                     ; 9906
        brk                                     ; 9907
        .byte   $04                             ; 9908
        brk                                     ; 9909
        inc     a:$00,x                         ; 990A
        brk                                     ; 990D
        brk                                     ; 990E
        brk                                     ; 990F
        ora     $00                             ; 9910
        inc     L9106                           ; 9912
        brk                                     ; 9915
        brk                                     ; 9916
        ora     $06                             ; 9917
        brk                                     ; 9919
        dec     $8E                             ; 991A
        sta     a:$00                           ; 991C
        brk                                     ; 991F
        .byte   $07                             ; 9920
        brk                                     ; 9921
        inc     a:$00,x                         ; 9922
        brk                                     ; 9925
        brk                                     ; 9926
        brk                                     ; 9927
        php                                     ; 9928
        brk                                     ; 9929
        inc     a:$00,x                         ; 992A
        brk                                     ; 992D
        brk                                     ; 992E
        brk                                     ; 992F
        ora     #$74                            ; 9930
        inc     $3D                             ; 9932
        stx     a:$00                           ; 9934
        .byte   $04                             ; 9937
        asl     a                               ; 9938
        .byte   $74                             ; 9939
        inc     $3D                             ; 993A
        stx     $0100                           ; 993C
        ora     $0B                             ; 993F
        .byte   $74                             ; 9941
        inc     $3D                             ; 9942
        stx     $0200                           ; 9944
        brk                                     ; 9947
        .byte   $0C                             ; 9948
        .byte   $74                             ; 9949
        asl     $CE                             ; 994A
        stx     $0200                           ; 994C
        brk                                     ; 994F
        ora     $0674                           ; 9950
        dec     a:$8E                           ; 9953
        .byte   $02                             ; 9956
        ora     $0E                             ; 9957
        .byte   $74                             ; 9959
        asl     $CE                             ; 995A
        stx     $0300                           ; 995C
        brk                                     ; 995F
        .byte   $0F                             ; 9960
        ror     a                               ; 9961
        rol     $4F                             ; 9962
        .byte   $8F                             ; 9964
        brk                                     ; 9965
        brk                                     ; 9966
        .byte   $02                             ; 9967
        bpl     L99D4                           ; 9968
        rol     $4F                             ; 996A
        .byte   $8F                             ; 996C
        brk                                     ; 996D
        brk                                     ; 996E
        .byte   $04                             ; 996F
        ora     ($00),y                         ; 9970
        asl     $00                             ; 9972
        brk                                     ; 9974
        brk                                     ; 9975
        brk                                     ; 9976
        ora     ($12,x)                         ; 9977
        brk                                     ; 9979
        inc     a:$00,x                         ; 997A
        brk                                     ; 997D
        brk                                     ; 997E
        .byte   $02                             ; 997F
        .byte   $13                             ; 9980
        adc     #$06                            ; 9981
        .byte   $73                             ; 9983
        .byte   $8F                             ; 9984
        brk                                     ; 9985
        brk                                     ; 9986
        .byte   $02                             ; 9987
        .byte   $14                             ; 9988
        adc     #$06                            ; 9989
        .byte   $73                             ; 998B
        .byte   $8F                             ; 998C
        brk                                     ; 998D
        brk                                     ; 998E
        .byte   $02                             ; 998F
        ora     $69,x                           ; 9990
        asl     $73                             ; 9992
        .byte   $8F                             ; 9994
        brk                                     ; 9995
        .byte   $02                             ; 9996
        brk                                     ; 9997
        asl     $6A,x                           ; 9998
        rol     $7B                             ; 999A
        .byte   $8F                             ; 999C
        brk                                     ; 999D
        brk                                     ; 999E
        .byte   $02                             ; 999F
        .byte   $17                             ; 99A0
        bvs     L99C9                           ; 99A1
        .byte   $54                             ; 99A3
        stx     $00,y                           ; 99A4
        ora     ($00,x)                         ; 99A6
        clc                                     ; 99A8
        brk                                     ; 99A9
        asl     L9659                           ; 99AA
        brk                                     ; 99AD
        .byte   $02                             ; 99AE
        brk                                     ; 99AF
        ora     $0E39,y                         ; 99B0
        ror     a                               ; 99B3
        stx     $00,y                           ; 99B4
        .byte   $02                             ; 99B6
        brk                                     ; 99B7
        .byte   $1A                             ; 99B8
        brk                                     ; 99B9
        asl     L96AE                           ; 99BA
        brk                                     ; 99BD
        .byte   $02                             ; 99BE
        brk                                     ; 99BF
        .byte   $1B                             ; 99C0
        brk                                     ; 99C1
        ror     L96B9                           ; 99C2
        brk                                     ; 99C5
        .byte   $02                             ; 99C6
        brk                                     ; 99C7
        .byte   $1C                             ; 99C8
L99C9:  brk                                     ; 99C9
        ror     L9725                           ; 99CA
        brk                                     ; 99CD
        .byte   $02                             ; 99CE
        brk                                     ; 99CF
        ora     $F600,x                         ; 99D0
        .byte   $DC                             ; 99D3
L99D4:  sta     ($00),y                         ; 99D4
        brk                                     ; 99D6
        brk                                     ; 99D7
L99D8:  brk                                     ; 99D8
        .byte   $0F                             ; 99D9
        bpl     L99ED                           ; 99DA
        brk                                     ; 99DC
        brk                                     ; 99DD
        brk                                     ; 99DE
        brk                                     ; 99DF
        brk                                     ; 99E0
        brk                                     ; 99E1
        brk                                     ; 99E2
        brk                                     ; 99E3
        brk                                     ; 99E4
        brk                                     ; 99E5
        brk                                     ; 99E6
        brk                                     ; 99E7
        brk                                     ; 99E8
        brk                                     ; 99E9
        brk                                     ; 99EA
        brk                                     ; 99EB
        brk                                     ; 99EC
L99ED:  brk                                     ; 99ED
        brk                                     ; 99EE
        brk                                     ; 99EF
        cpx     #$E1                            ; 99F0
        .byte   $E2                             ; 99F2
        .byte   $E3                             ; 99F3
        cpx     $00                             ; 99F4
L99F6:  lda     #$7D                            ; 99F6
        jmp     LE992                           ; 99F8

; ----------------------------------------------------------------------------
L99FB:  lda     #$03                            ; 99FB
        jsr     LB4DD                           ; 99FD
        lda     #$20                            ; 9A00
        sta     $04B5                           ; 9A02
        sta     $04B9                           ; 9A05
        sta     $04BD                           ; 9A08
        lda     #$0F                            ; 9A0B
        sta     $04B0                           ; 9A0D
        sta     $04BA                           ; 9A10
        jsr     LF07B                           ; 9A13
        jsr     LEA7E                           ; 9A16
        lda     #$28                            ; 9A19
        sta     $0205                           ; 9A1B
        sta     $0209                           ; 9A1E
        lda     #$00                            ; 9A21
        sta     $0206                           ; 9A23
        sta     $020A                           ; 9A26
        lda     #$02                            ; 9A29
        sta     $18                             ; 9A2B
        jsr     L9F81                           ; 9A2D
        jsr     LB541                           ; 9A30
L9A33:  lda     L9AE0,y                         ; 9A33
        jsr     LB5E1                           ; 9A36
        cpy     #$10                            ; 9A39
        bne     L9A33                           ; 9A3B
        jsr     LB4F1                           ; 9A3D
        jsr     L9F81                           ; 9A40
        jsr     L9AF0                           ; 9A43
        jsr     L9B3A                           ; 9A46
        ldx     #$0F                            ; 9A49
        lda     #$00                            ; 9A4B
L9A4D:  sta     $0400,x                         ; 9A4D
        dex                                     ; 9A50
        bpl     L9A4D                           ; 9A51
        jsr     L9D7E                           ; 9A53
        lda     #$1E                            ; 9A56
        sta     $11                             ; 9A58
        lda     $1C                             ; 9A5A
        and     #$FD                            ; 9A5C
        sta     $1C                             ; 9A5E
        jsr     LE95B                           ; 9A60
L9A63:  jsr     L9D9B                           ; 9A63
        lda     $C2                             ; 9A66
        and     #$02                            ; 9A68
        beq     L9A7B                           ; 9A6A
        lda     $0400                           ; 9A6C
        cmp     #$02                            ; 9A6F
        bne     L9A7B                           ; 9A71
        dec     $0400                           ; 9A73
        lda     #$F8                            ; 9A76
        sta     $0208                           ; 9A78
L9A7B:  lda     $C2                             ; 9A7B
        and     #$08                            ; 9A7D
        beq     L9A91                           ; 9A7F
        jsr     L99F6                           ; 9A81
        lda     $0400                           ; 9A84
        cmp     #$02                            ; 9A87
        beq     L9A91                           ; 9A89
        jsr     LE5AA                           ; 9A8B
        lda     #$00                            ; 9A8E
        rts                                     ; 9A90

; ----------------------------------------------------------------------------
L9A91:  lda     $C2                             ; 9A91
        lsr     a                               ; 9A93
        bcc     L9AD4                           ; 9A94
        jsr     L99F6                           ; 9A96
        lda     $0400                           ; 9A99
        cmp     #$02                            ; 9A9C
        bne     L9AAF                           ; 9A9E
        jsr     LE5AA                           ; 9AA0
        jsr     LEA7E                           ; 9AA3
        ldx     $0402                           ; 9AA6
        ldy     $0430,x                         ; 9AA9
        lda     #$01                            ; 9AAC
        rts                                     ; 9AAE

; ----------------------------------------------------------------------------
L9AAF:  ldy     $0401                           ; 9AAF
        lda     $0400                           ; 9AB2
        bne     L9AC2                           ; 9AB5
        lda     $0410,y                         ; 9AB7
        sta     $C5                             ; 9ABA
        jsr     LA239                           ; 9ABC
        jmp     L9AD4                           ; 9ABF

; ----------------------------------------------------------------------------
L9AC2:  lda     $0420,y                         ; 9AC2
        cmp     #$63                            ; 9AC5
        bne     L9ACF                           ; 9AC7
        jsr     L9C36                           ; 9AC9
        jmp     L9AD4                           ; 9ACC

; ----------------------------------------------------------------------------
L9ACF:  sta     $C6                             ; 9ACF
        jsr     LA1F0                           ; 9AD1
L9AD4:  jsr     L9D7E                           ; 9AD4
        jsr     L9D54                           ; 9AD7
        jsr     L9F81                           ; 9ADA
        jmp     L9A63                           ; 9ADD

; ----------------------------------------------------------------------------
L9AE0:  jsr     L0D88                           ; 9AE0
        .byte   $42                             ; 9AE3
        .byte   $34                             ; 9AE4
        .byte   $3B                             ; 9AE5
        .byte   $34                             ; 9AE6
        .byte   $32                             ; 9AE7
        .byte   $43                             ; 9AE8
        bit     $3B3F                           ; 9AE9
        .byte   $34                             ; 9AEC
        bmi     L9B31                           ; 9AED
        .byte   $34                             ; 9AEF
L9AF0:  lda     #$FF                            ; 9AF0
        ldy     #$2F                            ; 9AF2
L9AF4:  sta     $0410,y                         ; 9AF4
        dey                                     ; 9AF7
        bpl     L9AF4                           ; 9AF8
        lda     #$20                            ; 9AFA
        sta     $0405                           ; 9AFC
        lda     #$C5                            ; 9AFF
        sta     $0406                           ; 9B01
        lda     #$91                            ; 9B04
        sta     $0C                             ; 9B06
        lda     #$9F                            ; 9B08
        sta     $0D                             ; 9B0A
        lda     #$00                            ; 9B0C
        sta     $0407                           ; 9B0E
        lda     #$10                            ; 9B11
        sta     $00                             ; 9B13
        sta     $02                             ; 9B15
        lda     #$2C                            ; 9B17
        sta     $01                             ; 9B19
        sta     $03                             ; 9B1B
        jsr     L9B69                           ; 9B1D
        lda     #$0E                            ; 9B20
        sec                                     ; 9B22
        sbc     $0407                           ; 9B23
L9B26:  beq     L9B34                           ; 9B26
        sta     $0F                             ; 9B28
L9B2A:  jsr     L9CD0                           ; 9B2A
        jsr     L9F81                           ; 9B2D
        .byte   $C6                             ; 9B30
L9B31:  .byte   $0F                             ; 9B31
        bne     L9B2A                           ; 9B32
L9B34:  jsr     L9C7B                           ; 9B34
        jmp     L9F81                           ; 9B37

; ----------------------------------------------------------------------------
L9B3A:  lda     #$20                            ; 9B3A
        sta     $0405                           ; 9B3C
        lda     #$D0                            ; 9B3F
        sta     $0406                           ; 9B41
        lda     #$CB                            ; 9B44
        sta     $0C                             ; 9B46
        lda     #$9F                            ; 9B48
        sta     $0D                             ; 9B4A
        lda     #$10                            ; 9B4C
        sta     $0407                           ; 9B4E
        lda     #$11                            ; 9B51
        sta     $00                             ; 9B53
        sta     $02                             ; 9B55
        lda     #$2C                            ; 9B57
        sta     $01                             ; 9B59
        sta     $03                             ; 9B5B
        jsr     L9B69                           ; 9B5D
        lda     #$19                            ; 9B60
        sec                                     ; 9B62
        sbc     $0407                           ; 9B63
        jmp     L9B26                           ; 9B66

; ----------------------------------------------------------------------------
L9B69:  jsr     L9C5B                           ; 9B69
        jsr     L9F81                           ; 9B6C
L9B6F:  jsr     L9C92                           ; 9B6F
        jsr     L9CAC                           ; 9B72
        jsr     L9D1F                           ; 9B75
        inx                                     ; 9B78
        jsr     L9B90                           ; 9B79
        beq     L9B8A                           ; 9B7C
        jsr     L9D1F                           ; 9B7E
        jsr     LB4F1                           ; 9B81
        jsr     L9F81                           ; 9B84
        jsr     L9C83                           ; 9B87
L9B8A:  jsr     L9CBD                           ; 9B8A
        bne     L9B6F                           ; 9B8D
        rts                                     ; 9B8F

; ----------------------------------------------------------------------------
L9B90:  lda     $0402                           ; 9B90
        cmp     #$63                            ; 9B93
        bne     L9BB4                           ; 9B95
        lda     $19                             ; 9B97
        bne     L9BA7                           ; 9B99
        bit     $BF                             ; 9B9B
        bvs     L9BA7                           ; 9B9D
        lda     $B2                             ; 9B9F
        beq     L9BA7                           ; 9BA1
        cmp     #$20                            ; 9BA3
        bcc     L9BD2                           ; 9BA5
L9BA7:  lda     #$0F                            ; 9BA7
        ldy     $049F                           ; 9BA9
        beq     L9BB0                           ; 9BAC
        lda     #$F0                            ; 9BAE
L9BB0:  and     $87                             ; 9BB0
        beq     L9BD2                           ; 9BB2
L9BB4:  lda     $0400                           ; 9BB4
        sta     $00                             ; 9BB7
        lda     $0401                           ; 9BB9
        sta     $01                             ; 9BBC
        lda     $0404                           ; 9BBE
        cmp     #$F0                            ; 9BC1
        beq     L9BE0                           ; 9BC3
        cmp     #$10                            ; 9BC5
        bne     L9C1F                           ; 9BC7
        ldy     #$02                            ; 9BC9
L9BCB:  lda     ($00),y                         ; 9BCB
        bne     L9BD5                           ; 9BCD
        dey                                     ; 9BCF
        bpl     L9BCB                           ; 9BD0
L9BD2:  lda     #$00                            ; 9BD2
        rts                                     ; 9BD4

; ----------------------------------------------------------------------------
L9BD5:  dey                                     ; 9BD5
        bmi     L9BE0                           ; 9BD6
        inc     $0402                           ; 9BD8
        inc     $0403                           ; 9BDB
        bne     L9BD5                           ; 9BDE
L9BE0:  lda     $0403                           ; 9BE0
        jsr     L9D2F                           ; 9BE3
        lda     $0404                           ; 9BE6
        cmp     #$30                            ; 9BE9
        bne     L9C12                           ; 9BEB
        ldy     #$00                            ; 9BED
        lda     ($00),y                         ; 9BEF
        sta     $00                             ; 9BF1
        lda     #$2C                            ; 9BF3
        sta     $03                             ; 9BF5
        lda     #$00                            ; 9BF7
        jsr     LA347                           ; 9BF9
        dex                                     ; 9BFC
        ldy     #$01                            ; 9BFD
        lda     $0402                           ; 9BFF
        cmp     #$63                            ; 9C02
        bne     L9C08                           ; 9C04
        dex                                     ; 9C06
        dey                                     ; 9C07
L9C08:  lda     $08,y                           ; 9C08
        jsr     LB5E1                           ; 9C0B
        cpy     #$02                            ; 9C0E
        bne     L9C08                           ; 9C10
L9C12:  ldy     $0407                           ; 9C12
        lda     $0402                           ; 9C15
        sta     $0410,y                         ; 9C18
        inc     $0407                           ; 9C1B
        rts                                     ; 9C1E

; ----------------------------------------------------------------------------
L9C1F:  ldy     #$00                            ; 9C1F
        lda     ($00),y                         ; 9C21
        beq     L9BD2                           ; 9C23
        ldy     $0404                           ; 9C25
        cpy     #$20                            ; 9C28
        bne     L9BE0                           ; 9C2A
        clc                                     ; 9C2C
        adc     $0403                           ; 9C2D
        sta     $0403                           ; 9C30
        jmp     L9BE0                           ; 9C33

; ----------------------------------------------------------------------------
L9C36:  lda     #$22                            ; 9C36
        sta     $0405                           ; 9C38
        lda     #$30                            ; 9C3B
        sta     $0406                           ; 9C3D
        lda     #$00                            ; 9C40
        sta     $00                             ; 9C42
        jsr     L9C5B                           ; 9C44
        jsr     L9F81                           ; 9C47
        jsr     L9E3F                           ; 9C4A
        lda     #$00                            ; 9C4D
        sta     $0402                           ; 9C4F
        jsr     L9D6D                           ; 9C52
        lda     #$02                            ; 9C55
        sta     $0400                           ; 9C57
        rts                                     ; 9C5A

; ----------------------------------------------------------------------------
L9C5B:  jsr     L9CE4                           ; 9C5B
        ldy     #$00                            ; 9C5E
        jsr     L9CF8                           ; 9C60
        lda     $00                             ; 9C63
        beq     L9C78                           ; 9C65
        txa                                     ; 9C67
        sec                                     ; 9C68
        sbc     #$07                            ; 9C69
        tax                                     ; 9C6B
        ldy     #$00                            ; 9C6C
L9C6E:  lda     $01,y                           ; 9C6E
        jsr     LB5E1                           ; 9C71
        cpy     #$03                            ; 9C74
        bne     L9C6E                           ; 9C76
L9C78:  jmp     L9C83                           ; 9C78

; ----------------------------------------------------------------------------
L9C7B:  jsr     L9CE4                           ; 9C7B
        ldy     #$0B                            ; 9C7E
        jmp     L9CF8                           ; 9C80

; ----------------------------------------------------------------------------
L9C83:  clc                                     ; 9C83
        lda     $0406                           ; 9C84
        adc     #$20                            ; 9C87
        sta     $0406                           ; 9C89
        bcc     L9C91                           ; 9C8C
        inc     $0405                           ; 9C8E
L9C91:  rts                                     ; 9C91

; ----------------------------------------------------------------------------
L9C92:  ldy     #$03                            ; 9C92
L9C94:  lda     ($0C),y                         ; 9C94
        sta     $0400,y                         ; 9C96
        dey                                     ; 9C99
        bpl     L9C94                           ; 9C9A
        lda     $0401                           ; 9C9C
        tay                                     ; 9C9F
        and     #$0F                            ; 9CA0
        sta     $0401                           ; 9CA2
        tya                                     ; 9CA5
        and     #$F0                            ; 9CA6
        sta     $0404                           ; 9CA8
        rts                                     ; 9CAB

; ----------------------------------------------------------------------------
L9CAC:  ldx     $0162                           ; 9CAC
        lda     #$2C                            ; 9CAF
        ldy     #$10                            ; 9CB1
L9CB3:  sta     $0163,x                         ; 9CB3
        inx                                     ; 9CB6
        dey                                     ; 9CB7
        bpl     L9CB3                           ; 9CB8
        jmp     L9CE4                           ; 9CBA

; ----------------------------------------------------------------------------
L9CBD:  clc                                     ; 9CBD
        lda     $0C                             ; 9CBE
        adc     #$04                            ; 9CC0
        sta     $0C                             ; 9CC2
        bcc     L9CC8                           ; 9CC4
        inc     $0D                             ; 9CC6
L9CC8:  ldy     #$00                            ; 9CC8
        lda     ($0C),y                         ; 9CCA
        iny                                     ; 9CCC
        ora     ($0C),y                         ; 9CCD
        rts                                     ; 9CCF

; ----------------------------------------------------------------------------
L9CD0:  jsr     L9CAC                           ; 9CD0
        jsr     L9D1F                           ; 9CD3
        clc                                     ; 9CD6
        txa                                     ; 9CD7
        adc     #$09                            ; 9CD8
        tax                                     ; 9CDA
        jsr     L9D1F                           ; 9CDB
        jsr     LB4F1                           ; 9CDE
        jmp     L9C83                           ; 9CE1

; ----------------------------------------------------------------------------
L9CE4:  ldx     $0162                           ; 9CE4
        lda     $0405                           ; 9CE7
        jsr     LB5E1                           ; 9CEA
        lda     $0406                           ; 9CED
        jsr     LB5E1                           ; 9CF0
        lda     #$0B                            ; 9CF3
        jmp     LB5E1                           ; 9CF5

; ----------------------------------------------------------------------------
L9CF8:  lda     #$0B                            ; 9CF8
        sta     $04                             ; 9CFA
L9CFC:  lda     L9D09,y                         ; 9CFC
        jsr     LB5E1                           ; 9CFF
        dec     $04                             ; 9D02
        bne     L9CFC                           ; 9D04
        jmp     LB4F1                           ; 9D06

; ----------------------------------------------------------------------------
L9D09:  stx     L8C8C                           ; 9D09
        sty     L8C8C                           ; 9D0C
        sty     L8C8C                           ; 9D0F
        sty     L8F9E                           ; 9D12
        sty     L8C8C                           ; 9D15
        sty     L8C8C                           ; 9D18
        sty     L8C8C                           ; 9D1B
        .byte   $9F                             ; 9D1E
L9D1F:  lda     #$8D                            ; 9D1F
        jmp     LB5E1                           ; 9D21

; ----------------------------------------------------------------------------
        ldy     #$00                            ; 9D24
L9D26:  cmp     $A059,y                         ; 9D26
        beq     L9D2E                           ; 9D29
        iny                                     ; 9D2B
        bne     L9D26                           ; 9D2C
L9D2E:  tya                                     ; 9D2E
L9D2F:  asl     a                               ; 9D2F
        tay                                     ; 9D30
        lda     L9FF1,y                         ; 9D31
        sta     $0E                             ; 9D34
        lda     L9FF2,y                         ; 9D36
        sta     $0F                             ; 9D39
        ldy     #$00                            ; 9D3B
L9D3D:  lda     ($0E),y                         ; 9D3D
        pha                                     ; 9D3F
        and     #$7F                            ; 9D40
        jsr     LB5E1                           ; 9D42
        pla                                     ; 9D45
        bpl     L9D3D                           ; 9D46
L9D48:  cpy     #$08                            ; 9D48
        beq     L9D53                           ; 9D4A
        lda     #$2C                            ; 9D4C
        jsr     LB5E1                           ; 9D4E
        bne     L9D48                           ; 9D51
L9D53:  rts                                     ; 9D53

; ----------------------------------------------------------------------------
L9D54:  lda     $0400                           ; 9D54
        cmp     #$02                            ; 9D57
        bne     L9D6C                           ; 9D59
        lda     $1E                             ; 9D5B
        and     #$07                            ; 9D5D
        bne     L9D6C                           ; 9D5F
        lda     $1E                             ; 9D61
        and     #$08                            ; 9D63
        bne     L9D6D                           ; 9D65
        lda     #$F8                            ; 9D67
        sta     $0208                           ; 9D69
L9D6C:  rts                                     ; 9D6C

; ----------------------------------------------------------------------------
L9D6D:  lda     $0402                           ; 9D6D
        asl     a                               ; 9D70
        asl     a                               ; 9D71
        asl     a                               ; 9D72
        adc     #$90                            ; 9D73
        sta     $0208                           ; 9D75
        lda     #$88                            ; 9D78
        sta     $020B                           ; 9D7A
        rts                                     ; 9D7D

; ----------------------------------------------------------------------------
L9D7E:  ldx     #$30                            ; 9D7E
        lda     $0400                           ; 9D80
        beq     L9D8B                           ; 9D83
        ldx     #$88                            ; 9D85
        cmp     #$02                            ; 9D87
        beq     L9D9A                           ; 9D89
L9D8B:  stx     $0207                           ; 9D8B
        lda     $0401                           ; 9D8E
        asl     a                               ; 9D91
        asl     a                               ; 9D92
        asl     a                               ; 9D93
        clc                                     ; 9D94
        adc     #$38                            ; 9D95
        sta     $0204                           ; 9D97
L9D9A:  rts                                     ; 9D9A

; ----------------------------------------------------------------------------
L9D9B:  lda     $C2                             ; 9D9B
        and     #$80                            ; 9D9D
        beq     L9DB9                           ; 9D9F
        lda     $0400                           ; 9DA1
        bne     L9DB9                           ; 9DA4
        inc     $0400                           ; 9DA6
L9DA9:  ldy     $0401                           ; 9DA9
        lda     $0420,y                         ; 9DAC
        cmp     #$FF                            ; 9DAF
        bne     L9DB9                           ; 9DB1
        dec     $0401                           ; 9DB3
        jmp     L9DA9                           ; 9DB6

; ----------------------------------------------------------------------------
L9DB9:  lda     $C2                             ; 9DB9
        and     #$40                            ; 9DBB
        beq     L9DD9                           ; 9DBD
        lda     $0400                           ; 9DBF
        cmp     #$01                            ; 9DC2
        bne     L9DD9                           ; 9DC4
        dec     $0400                           ; 9DC6
L9DC9:  ldy     $0401                           ; 9DC9
        lda     $0410,y                         ; 9DCC
        cmp     #$FF                            ; 9DCF
        bne     L9DD9                           ; 9DD1
        dec     $0401                           ; 9DD3
        jmp     L9DC9                           ; 9DD6

; ----------------------------------------------------------------------------
L9DD9:  lda     $C2                             ; 9DD9
        and     #$20                            ; 9DDB
        beq     L9E0F                           ; 9DDD
        ldy     $0401                           ; 9DDF
        iny                                     ; 9DE2
        lda     $0400                           ; 9DE3
        bne     L9DEE                           ; 9DE6
        lda     $0410,y                         ; 9DE8
        jmp     L9DF5                           ; 9DEB

; ----------------------------------------------------------------------------
L9DEE:  cmp     #$01                            ; 9DEE
        bne     L9E01                           ; 9DF0
        lda     $0420,y                         ; 9DF2
L9DF5:  cmp     #$FF                            ; 9DF5
        bne     L9DFB                           ; 9DF7
        ldy     #$00                            ; 9DF9
L9DFB:  sty     $0401                           ; 9DFB
        jmp     L9E0F                           ; 9DFE

; ----------------------------------------------------------------------------
L9E01:  ldy     $0402                           ; 9E01
        iny                                     ; 9E04
        lda     $0430,y                         ; 9E05
        cmp     #$FF                            ; 9E08
        beq     L9E0F                           ; 9E0A
        sty     $0402                           ; 9E0C
L9E0F:  lda     $C2                             ; 9E0F
        and     #$10                            ; 9E11
        beq     L9E35                           ; 9E13
        lda     $0400                           ; 9E15
        cmp     #$02                            ; 9E18
        beq     L9E36                           ; 9E1A
        dec     $0401                           ; 9E1C
        bpl     L9E35                           ; 9E1F
        lda     #$00                            ; 9E21
        sta     $C2                             ; 9E23
        lda     #$0F                            ; 9E25
        sta     $0401                           ; 9E27
        lda     $0400                           ; 9E2A
        beq     L9E32                           ; 9E2D
        jmp     L9DA9                           ; 9E2F

; ----------------------------------------------------------------------------
L9E32:  jmp     L9DC9                           ; 9E32

; ----------------------------------------------------------------------------
L9E35:  rts                                     ; 9E35

; ----------------------------------------------------------------------------
L9E36:  dec     $0402                           ; 9E36
        bpl     L9E3E                           ; 9E39
        inc     $0402                           ; 9E3B
L9E3E:  rts                                     ; 9E3E

; ----------------------------------------------------------------------------
L9E3F:  lda     $82                             ; 9E3F
        asl     a                               ; 9E41
        asl     a                               ; 9E42
        asl     a                               ; 9E43
        sta     $0E                             ; 9E44
        lda     $87                             ; 9E46
        sta     $0D                             ; 9E48
        lda     #$00                            ; 9E4A
        sta     $0C                             ; 9E4C
        lda     $049F                           ; 9E4E
        beq     L9E66                           ; 9E51
        lsr     $0D                             ; 9E53
        lsr     $0D                             ; 9E55
        lsr     $0D                             ; 9E57
        lsr     $0D                             ; 9E59
        lda     #$04                            ; 9E5B
        sta     $0C                             ; 9E5D
        clc                                     ; 9E5F
        lda     $0E                             ; 9E60
        adc     #$04                            ; 9E62
        sta     $0E                             ; 9E64
L9E66:  lda     #$00                            ; 9E66
        sta     $0B                             ; 9E68
        lda     #$04                            ; 9E6A
        sta     $0A                             ; 9E6C
L9E6E:  lsr     $0D                             ; 9E6E
        bcc     L9E9F                           ; 9E70
        jsr     L9CAC                           ; 9E72
        jsr     L9D1F                           ; 9E75
        inx                                     ; 9E78
        ldy     $0E                             ; 9E79
        lda     L9ED1,y                         ; 9E7B
        tay                                     ; 9E7E
L9E7F:  lda     L9EF9,y                         ; 9E7F
        jsr     LB5E1                           ; 9E82
        tya                                     ; 9E85
        and     #$07                            ; 9E86
        bne     L9E7F                           ; 9E88
        jsr     L9D1F                           ; 9E8A
        jsr     LB4F1                           ; 9E8D
        ldy     $0B                             ; 9E90
        lda     $0C                             ; 9E92
        sta     $0430,y                         ; 9E94
        inc     $0B                             ; 9E97
        jsr     L9C83                           ; 9E99
        jsr     L9F81                           ; 9E9C
L9E9F:  inc     $0E                             ; 9E9F
        inc     $0C                             ; 9EA1
        dec     $0A                             ; 9EA3
        bne     L9E6E                           ; 9EA5
        lda     #$04                            ; 9EA7
        sec                                     ; 9EA9
        sbc     $0B                             ; 9EAA
        beq     L9ECB                           ; 9EAC
        sta     $0F                             ; 9EAE
L9EB0:  jsr     L9CAC                           ; 9EB0
        jsr     L9D1F                           ; 9EB3
        clc                                     ; 9EB6
        txa                                     ; 9EB7
        adc     #$09                            ; 9EB8
        tax                                     ; 9EBA
        jsr     L9D1F                           ; 9EBB
        jsr     LB4F1                           ; 9EBE
        jsr     L9C83                           ; 9EC1
        jsr     L9F81                           ; 9EC4
        dec     $0F                             ; 9EC7
        bne     L9EB0                           ; 9EC9
L9ECB:  jsr     L9C7B                           ; 9ECB
        jmp     L9F81                           ; 9ECE

; ----------------------------------------------------------------------------
L9ED1:  php                                     ; 9ED1
        bpl     L9EEC                           ; 9ED2
        jsr     L2010                           ; 9ED4
        brk                                     ; 9ED7
        brk                                     ; 9ED8
        plp                                     ; 9ED9
        bmi     L9F14                           ; 9EDA
        brk                                     ; 9EDC
        rti                                     ; 9EDD

; ----------------------------------------------------------------------------
        brk                                     ; 9EDE
        brk                                     ; 9EDF
        brk                                     ; 9EE0
        pha                                     ; 9EE1
        bvc     L9F3C                           ; 9EE2
        brk                                     ; 9EE4
        pha                                     ; 9EE5
        bvc     L9EE8                           ; 9EE6
L9EE8:  brk                                     ; 9EE8
        rts                                     ; 9EE9

; ----------------------------------------------------------------------------
        pla                                     ; 9EEA
        .byte   $70                             ; 9EEB
L9EEC:  brk                                     ; 9EEC
        sei                                     ; 9EED
        .byte   $80                             ; 9EEE
        brk                                     ; 9EEF
        brk                                     ; 9EF0
        rts                                     ; 9EF1

; ----------------------------------------------------------------------------
        pla                                     ; 9EF2
        bvs     L9EF5                           ; 9EF3
L9EF5:  brk                                     ; 9EF5
        brk                                     ; 9EF6
        brk                                     ; 9EF7
        brk                                     ; 9EF8
L9EF9:  bit     $2C2C                           ; 9EF9
        bit     $2C2C                           ; 9EFC
        bit     $3C2C                           ; 9EFF
        .byte   $34                             ; 9F02
        .byte   $42                             ; 9F03
        .byte   $37                             ; 9F04
        .byte   $44                             ; 9F05
        .byte   $33                             ; 9F06
        rol     $412C,x                         ; 9F07
        .byte   $44                             ; 9F0A
        .byte   $33                             ; 9F0B
        rol     $3841,x                         ; 9F0C
        bmi     L9F3D                           ; 9F0F
        .byte   $3F                             ; 9F11
        .byte   $3E                             ; 9F12
        .byte   $3F                             ; 9F13
L9F14:  rol     $3E3D,x                         ; 9F14
        .byte   $3B                             ; 9F17
        .byte   $3B                             ; 9F18
        .byte   $37                             ; 9F19
        rol     $3441,x                         ; 9F1A
        and     $2C2C,x                         ; 9F1D
        bit     $303C                           ; 9F20
        .byte   $3B                             ; 9F23
        bmi     L9F67                           ; 9F24
        .byte   $43                             ; 9F26
        bit     $322C                           ; 9F27
        rol     $303F,x                         ; 9F2A
        and     $4234,x                         ; 9F2D
        bit     $4442                           ; 9F30
        .byte   $33                             ; 9F33
        bmi     L9F77                           ; 9F34
        sec                                     ; 9F36
        bit     $302C                           ; 9F37
        .byte   $3B                             ; 9F3A
        .byte   $30                             ; 9F3B
L9F3C:  .byte   $41                             ; 9F3C
L9F3D:  .byte   $43                             ; 9F3D
        bit     $2C2C                           ; 9F3E
        and     $3144,x                         ; 9F41
        sec                                     ; 9F44
        bmi     L9F73                           ; 9F45
        bit     $3A2C                           ; 9F47
        bmi     L9F8E                           ; 9F4A
        sec                                     ; 9F4C
        .byte   $3C                             ; 9F4D
        .byte   $34                             ; 9F4E
        .byte   $34                             ; 9F4F
        .byte   $3B                             ; 9F50
        .byte   $3F                             ; 9F51
        bmi     L9F96                           ; 9F52
        .byte   $42                             ; 9F54
        rol     $3041,x                         ; 9F55
        bit     $4448                           ; 9F58
        and     $3B,x                           ; 9F5B
        bmi     L9F8B                           ; 9F5D
        bit     $3F2C                           ; 9F5F
        bmi     L9FA2                           ; 9F62
        bit     $2C2C                           ; 9F64
L9F67:  bit     $322C                           ; 9F67
        .byte   $37                             ; 9F6A
        sec                                     ; 9F6B
        rol     $41,x                           ; 9F6C
        sec                                     ; 9F6E
        .byte   $42                             ; 9F6F
        bit     $3035                           ; 9F70
L9F73:  eor     ($45,x)                         ; 9F73
        sec                                     ; 9F75
        .byte   $3B                             ; 9F76
L9F77:  bit     $3B2C                           ; 9F77
        bmi     L9FC1                           ; 9F7A
        bmi     L9FAA                           ; 9F7C
        bit     $2C2C                           ; 9F7E
L9F81:  lda     $1C                             ; 9F81
        and     #$FD                            ; 9F83
        sta     $1C                             ; 9F85
        jsr     LEEB3                           ; 9F87
        .byte   $A5                             ; 9F8A
L9F8B:  .byte   $1C                             ; 9F8B
        ora     #$02                            ; 9F8C
L9F8E:  sta     $1C                             ; 9F8E
        rts                                     ; 9F90

; ----------------------------------------------------------------------------
        and     #$03                            ; 9F91
        .byte   $0F                             ; 9F93
        brk                                     ; 9F94
        .byte   $23                             ; 9F95
L9F96:  .byte   $13                             ; 9F96
        ora     #$01                            ; 9F97
        bmi     L9F9E                           ; 9F99
        asl     $04,x                           ; 9F9B
        .byte   $26                             ; 9F9D
L9F9E:  .byte   $13                             ; 9F9E
        .byte   $0C                             ; 9F9F
        .byte   $05                             ; 9FA0
L9FA1:  .byte   $2D                             ; 9FA1
L9FA2:  .byte   $13                             ; 9FA2
        .byte   $13                             ; 9FA3
        php                                     ; 9FA4
        and     ($03),y                         ; 9FA5
        .byte   $17                             ; 9FA7
        .byte   $0B                             ; 9FA8
        rol     a                               ; 9FA9
L9FAA:  .byte   $03                             ; 9FAA
        bpl     L9FB9                           ; 9FAB
        .byte   $13                             ; 9FAD
        .byte   $03                             ; 9FAE
        ora     $0D                             ; 9FAF
        cpx     #$03                            ; 9FB1
        clc                                     ; 9FB3
        asl     $03E1                           ; 9FB4
        .byte   $19                             ; 9FB7
        .byte   $0F                             ; 9FB8
L9FB9:  .byte   $E2                             ; 9FB9
        .byte   $03                             ; 9FBA
        .byte   $1A                             ; 9FBB
        bpl     L9FA1                           ; 9FBC
        .byte   $03                             ; 9FBE
        .byte   $1B                             ; 9FBF
        .byte   $11                             ; 9FC0
L9FC1:  cpx     $03                             ; 9FC1
        .byte   $1C                             ; 9FC3
        .byte   $12                             ; 9FC4
        brk                                     ; 9FC5
        beq     L9FC8                           ; 9FC6
L9FC8:  .byte   $13                             ; 9FC8
        brk                                     ; 9FC9
        brk                                     ; 9FCA
        asl     $1E23                           ; 9FCB
        .byte   $13                             ; 9FCE
        .byte   $22                             ; 9FCF
        .byte   $23                             ; 9FD0
        .byte   $1F                             ; 9FD1
        ora     $F000,y                         ; 9FD2
        ora     $1120,x                         ; 9FD5
        .byte   $33                             ; 9FD8
        .byte   $63                             ; 9FD9
        and     ($10,x)                         ; 9FDA
        .byte   $33                             ; 9FDC
        .byte   $02                             ; 9FDD
        .byte   $22                             ; 9FDE
        .byte   $0F                             ; 9FDF
        .byte   $33                             ; 9FE0
        ora     ($23,x)                         ; 9FE1
        .byte   $12                             ; 9FE3
        .byte   $33                             ; 9FE4
        .byte   $04                             ; 9FE5
        bit     $14                             ; 9FE6
        .byte   $03                             ; 9FE8
        asl     $25                             ; 9FE9
        brk                                     ; 9FEB
        beq     L9FEE                           ; 9FEC
L9FEE:  .byte   $13                             ; 9FEE
        brk                                     ; 9FEF
        brk                                     ; 9FF0
L9FF1:  .byte   $80                             ; 9FF1
L9FF2:  ldy     #$86                            ; 9FF2
        ldy     #$8E                            ; 9FF4
        ldy     #$96                            ; 9FF6
        ldy     #$9E                            ; 9FF8
        ldy     #$A5                            ; 9FFA
        ldy     #$AC                            ; 9FFC
        ldy     #$B3                            ; 9FFE
