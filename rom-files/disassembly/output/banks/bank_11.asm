; ============================================================================
; The Magic of Scheherazade - Bank 11 Disassembly
; ============================================================================
; File Offset: 0x16000 - 0x17FFF
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
; Input file: C:/claude-workspace/TMOS_AI/rom-files/disassembly/output/banks/bank_11.bin
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
L0000           := $0000
L0D03           := $0D03
L1080           := $1080
PPU_CTRL        := $2000
PPU_MASK        := $2001
PPU_STATUS      := $2002
OAM_ADDR        := $2003
OAM_DATA        := $2004
PPU_SCROLL      := $2005
PPU_ADDR        := $2006
PPU_DATA        := $2007
L2040           := $2040
OAM_DMA         := $4014
APU_STATUS      := $4015
JOY1            := $4016
JOY2_FRAME      := $4017
LA05B           := $A05B
LA0D5           := $A0D5
LA0FA           := $A0FA
LA1A7           := $A1A7
LA23B           := $A23B
LA24B           := $A24B
LA27B           := $A27B
LA393           := $A393
LA3AB           := $A3AB
LA43E           := $A43E
LA4A8           := $A4A8
LA4E2           := $A4E2
LA50F           := $A50F
LA52C           := $A52C
LA53B           := $A53B
LA57D           := $A57D
LA59D           := $A59D
LA5AC           := $A5AC
LA64C           := $A64C
LA666           := $A666
LA6C8           := $A6C8
LA6CC           := $A6CC
LA6E9           := $A6E9
LA72A           := $A72A
LA72E           := $A72E
LA784           := $A784
LA788           := $A788
LA798           := $A798
LA7A3           := $A7A3
LA7AB           := $A7AB
LA7D1           := $A7D1
LA7E2           := $A7E2
LA839           := $A839
LA874           := $A874
LA8F1           := $A8F1
LA917           := $A917
LA92C           := $A92C
LA987           := $A987
LAA00           := $AA00
LAA1C           := $AA1C
LAA5B           := $AA5B
LAA83           := $AA83
LAA90           := $AA90
LAB0A           := $AB0A
LAB90           := $AB90
LABB9           := $ABB9
LABF2           := $ABF2
LAC1D           := $AC1D
LACF1           := $ACF1
LAD3A           := $AD3A
LAE21           := $AE21
LAE4E           := $AE4E
LAEB8           := $AEB8
LAEBD           := $AEBD
LAF57           := $AF57
LAF74           := $AF74
LAF86           := $AF86
LAF89           := $AF89
LAFE3           := $AFE3
LB000           := $B000
LB0A4           := $B0A4
LB185           := $B185
LB4E8           := $B4E8
LB529           := $B529
LB56F           := $B56F
LB5DA           := $B5DA
LB6AD           := $B6AD
LB7C1           := $B7C1
LBA08           := $BA08
LBADE           := $BADE
LBB2F           := $BB2F
LBB95           := $BB95
LBD0F           := $BD0F
LBD73           := $BD73
LBD7C           := $BD7C
LBD7F           := $BD7F
LBD83           := $BD83
LBD8C           := $BD8C
LBDC4           := $BDC4
LBE36           := $BE36
LBE50           := $BE50
LBE80           := $BE80
LBEA7           := $BEA7
LBEDF           := $BEDF
LBF12           := $BF12
LBF39           := $BF39
LBF7F           := $BF7F
LE03F           := $E03F
LE06D           := $E06D
LE074           := $E074
LE080           := $E080
LE086           := $E086
LE088           := $E088
LE08C           := $E08C
LE096           := $E096
LE0A0           := $E0A0
LE0A2           := $E0A2
LE0A4           := $E0A4
LE110           := $E110
LE17B           := $E17B
LE5AA           := $E5AA
LE891           := $E891
LE898           := $E898
LE89D           := $E89D
LE8B1           := $E8B1
LE964           := $E964
LE97D           := $E97D
LE992           := $E992
LEAB5           := $EAB5
LEAB9           := $EAB9
LEAC1           := $EAC1
LEC46           := $EC46
LEC71           := $EC71
LEC75           := $EC75
LF067           := $F067
LF07B           := $F07B
LF085           := $F085
LF09B           := $F09B
LF0B5           := $F0B5
LF0BE           := $F0BE
LF0CF           := $F0CF
LF0ED           := $F0ED
LF11C           := $F11C
LF12B           := $F12B
LF301           := $F301
LF3E0           := $F3E0
LF41D           := $F41D
LF510           := $F510
LF785           := $F785
LF85D           := $F85D
LF877           := $F877
LF951           := $F951
LFA84           := $FA84
LFAB3           := $FAB3
LFAD7           := $FAD7
LFB62           := $FB62
LFBA5           := $FBA5
LFBE9           := $FBE9
; ----------------------------------------------------------------------------
        ora     $02                             ; 8000
        lda     $0600                           ; 8002
        asl     a                               ; 8005
        lda     #$00                            ; 8006
        bcc     L800C                           ; 8008
        lda     #$20                            ; 800A
L800C:  ora     #$00                            ; 800C
        sta     $0206                           ; 800E
        lda     $0603                           ; 8011
        sec                                     ; 8014
        sbc     #$04                            ; 8015
        sta     $0207                           ; 8017
        rts                                     ; 801A

; ----------------------------------------------------------------------------
        ldy     #$10                            ; 801B
        bne     L8025                           ; 801D
        ldy     #$20                            ; 801F
        bne     L8025                           ; 8021
        ldy     #$30                            ; 8023
L8025:  lda     #$00                            ; 8025
        sta     L0000                           ; 8027
        sta     $01                             ; 8029
        lda     $0601,x                         ; 802B
        and     #$50                            ; 802E
        beq     L8037                           ; 8030
        tya                                     ; 8032
        eor     #$FF                            ; 8033
        tay                                     ; 8035
        iny                                     ; 8036
L8037:  lda     $0602,x                         ; 8037
        and     #$F0                            ; 803A
        sta     $01                             ; 803C
        lda     $0603,x                         ; 803E
        and     #$F0                            ; 8041
        sta     L0000                           ; 8043
        lda     $0601,x                         ; 8045
        and     #$C0                            ; 8048
        beq     L8055                           ; 804A
        clc                                     ; 804C
        tya                                     ; 804D
        adc     L0000                           ; 804E
        sta     L0000                           ; 8050
        jmp     LA05B                           ; 8052

; ----------------------------------------------------------------------------
L8055:  clc                                     ; 8055
        tya                                     ; 8056
        adc     $01                             ; 8057
        sta     $01                             ; 8059
        tya                                     ; 805B
        ror     a                               ; 805C
        and     #$C0                            ; 805D
        beq     L8067                           ; 805F
        cmp     #$C0                            ; 8061
        beq     L8067                           ; 8063
        sec                                     ; 8065
        rts                                     ; 8066

; ----------------------------------------------------------------------------
L8067:  lda     $02                             ; 8067
        cmp     #$01                            ; 8069
        bne     L8071                           ; 806B
        lda     $19                             ; 806D
        beq     L8089                           ; 806F
L8071:  lda     L0000                           ; 8071
        cmp     $C7                             ; 8073
        bcs     L809A                           ; 8075
        lda     $C8                             ; 8077
        cmp     L0000                           ; 8079
        bcs     L809A                           ; 807B
        lda     $01                             ; 807D
        cmp     $C9                             ; 807F
        bcs     L809A                           ; 8081
        lda     $CA                             ; 8083
        cmp     $01                             ; 8085
        bcs     L809A                           ; 8087
L8089:  lda     L0000                           ; 8089
        lsr     a                               ; 808B
        lsr     a                               ; 808C
        lsr     a                               ; 808D
        lsr     a                               ; 808E
        ora     $01                             ; 808F
        jsr     LE088                           ; 8091
        cmp     #$0B                            ; 8094
        sec                                     ; 8096
        beq     L809A                           ; 8097
        clc                                     ; 8099
L809A:  rts                                     ; 809A

; ----------------------------------------------------------------------------
        lda     $C0                             ; 809B
        and     #$F0                            ; 809D
        bne     L80A3                           ; 809F
        ldy     #$00                            ; 80A1
L80A3:  sty     $02                             ; 80A3
        tya                                     ; 80A5
        jsr     LA0D5                           ; 80A6
        bcs     L80B3                           ; 80A9
        lda     $29                             ; 80AB
L80AD:  bne     L80B7                           ; 80AD
        lda     $35                             ; 80AF
        beq     L80B7                           ; 80B1
L80B3:  lda     #$00                            ; 80B3
        sta     $02                             ; 80B5
L80B7:  jsr     L950A                           ; 80B7
        lda     $02                             ; 80BA
        jsr     LF85D                           ; 80BC
        jsr     LE0A4                           ; 80BF
        lda     #$00                            ; 80C2
        sta     $0700,x                         ; 80C4
        lda     #$11                            ; 80C7
        jsr     LE992                           ; 80C9
        lda     $0707,x                         ; 80CC
        ora     #$40                            ; 80CF
        sta     $0707,x                         ; 80D1
L80D4:  rts                                     ; 80D4

; ----------------------------------------------------------------------------
        jsr     LE97D                           ; 80D5
        .byte   $D4                             ; 80D8
        ldy     #$1B                            ; 80D9
        ldy     #$1F                            ; 80DB
        ldy     #$23                            ; 80DD
        ldy     #$A0                            ; 80DF
        clc                                     ; 80E1
        lda     $0601,y                         ; 80E2
        bne     L80D4                           ; 80E5
        dec     $0312                           ; 80E7
        bne     L80EE                           ; 80EA
        sta     $C6                             ; 80EC
L80EE:  lda     #$03                            ; 80EE
        sta     $0600,y                         ; 80F0
        lda     #$FF                            ; 80F3
        sta     $0702,y                         ; 80F5
        lda     #$00                            ; 80F8
        sta     $3B                             ; 80FA
        lda     $0601,x                         ; 80FC
        and     #$F0                            ; 80FF
        ora     $3B                             ; 8101
        sta     $0601,y                         ; 8103
        lda     $0602,x                         ; 8106
        sta     $0602,y                         ; 8109
        lda     $0603,x                         ; 810C
        sta     $0603,y                         ; 810F
        lda     #$00                            ; 8112
        sta     $0700,y                         ; 8114
        txa                                     ; 8117
        pha                                     ; 8118
        tya                                     ; 8119
        tax                                     ; 811A
        jsr     LE0A4                           ; 811B
        pla                                     ; 811E
        tax                                     ; 811F
        lda     #$05                            ; 8120
        jsr     LF0BE                           ; 8122
        jsr     LE0A4                           ; 8125
        lda     #$10                            ; 8128
        jsr     LE992                           ; 812A
        lda     #$08                            ; 812D
        sta     $0700,x                         ; 812F
        lda     #$00                            ; 8132
        rts                                     ; 8134

; ----------------------------------------------------------------------------
        jsr     LF0ED                           ; 8135
        sta     $0F                             ; 8138
        ldy     #$18                            ; 813A
        cmp     #$03                            ; 813C
        bcc     L814E                           ; 813E
        ldy     #$20                            ; 8140
        cmp     #$05                            ; 8142
        bcc     L814E                           ; 8144
        ldy     #$28                            ; 8146
        cmp     #$06                            ; 8148
        bcc     L814E                           ; 814A
        ldy     #$30                            ; 814C
L814E:  lda     $0601,y                         ; 814E
        beq     L815F                           ; 8151
        tya                                     ; 8153
        sec                                     ; 8154
        sbc     #$08                            ; 8155
        tay                                     ; 8157
        cpy     #$10                            ; 8158
        bne     L814E                           ; 815A
        lda     #$01                            ; 815C
        rts                                     ; 815E

; ----------------------------------------------------------------------------
L815F:  lda     #$03                            ; 815F
        sta     $0600,y                         ; 8161
        lda     #$FF                            ; 8164
        sta     $0702,y                         ; 8166
        lda     $0F                             ; 8169
        jmp     LA0FA                           ; 816B

; ----------------------------------------------------------------------------
        jsr     LE17B                           ; 816E
        .byte   $1A                             ; 8171
        .byte   $04                             ; 8172
        lda     $BF                             ; 8173
        and     #$18                            ; 8175
        beq     L81A2                           ; 8177
        lda     $7F                             ; 8179
        and     #$3F                            ; 817B
        bne     L81A2                           ; 817D
        jsr     LF11C                           ; 817F
        bne     L81A2                           ; 8182
        lda     #$05                            ; 8184
        sta     $0600,y                         ; 8186
        lda     #$8E                            ; 8189
        sta     $0601,y                         ; 818B
        lda     $0602                           ; 818E
        sec                                     ; 8191
        sbc     #$0C                            ; 8192
        sta     $0602,y                         ; 8194
        lda     $0603                           ; 8197
        sta     $0603,y                         ; 819A
        tya                                     ; 819D
        tax                                     ; 819E
        jsr     LE0A4                           ; 819F
L81A2:  lda     #$00                            ; 81A2
        sta     $35                             ; 81A4
        rts                                     ; 81A6

; ----------------------------------------------------------------------------
        lda     $0600,x                         ; 81A7
        sec                                     ; 81AA
        and     #$7F                            ; 81AB
        sbc     #$10                            ; 81AD
        asl     a                               ; 81AF
        asl     a                               ; 81B0
        tay                                     ; 81B1
        lda     $B1A5,y                         ; 81B2
        cmp     #$FF                            ; 81B5
        bne     L81BA                           ; 81B7
L81B9:  rts                                     ; 81B9

; ----------------------------------------------------------------------------
L81BA:  lda     $0702,x                         ; 81BA
        bmi     L81B9                           ; 81BD
        beq     L8232                           ; 81BF
        lda     $7F                             ; 81C1
        and     #$0F                            ; 81C3
        bne     L81B9                           ; 81C5
        dec     $0702,x                         ; 81C7
        bne     L81B9                           ; 81CA
L81CC:  jsr     LA23B                           ; 81CC
        stx     $0C                             ; 81CF
        lda     $B1A4,y                         ; 81D1
        sta     $0D                             ; 81D4
        lda     $B1A5,y                         ; 81D6
        sta     $0E                             ; 81D9
        lda     $B1A6,y                         ; 81DB
        sta     $0F                             ; 81DE
        lda     $0602,x                         ; 81E0
        sta     $03                             ; 81E3
        lda     $0603,x                         ; 81E5
        sta     $04                             ; 81E8
        lda     $0601,x                         ; 81EA
        and     #$F0                            ; 81ED
        sta     $01                             ; 81EF
        lda     $0F                             ; 81F1
        and     #$0F                            ; 81F3
        ora     $01                             ; 81F5
        sta     $01                             ; 81F7
        lda     #$0D                            ; 81F9
        sta     L0000                           ; 81FB
        lda     $0F                             ; 81FD
        asl     a                               ; 81FF
        asl     a                               ; 8200
        asl     a                               ; 8201
        asl     a                               ; 8202
        lda     L0000                           ; 8203
        adc     #$00                            ; 8205
        sta     L0000                           ; 8207
        lda     $0F                             ; 8209
        and     #$E0                            ; 820B
        sta     $0F                             ; 820D
        inc     $0601,x                         ; 820F
        jsr     LE0A4                           ; 8212
        lda     #$00                            ; 8215
        sta     $0700,x                         ; 8217
        jsr     LA24B                           ; 821A
        lda     $0E                             ; 821D
        and     #$0F                            ; 821F
        jsr     LE97D                           ; 8221
        .byte   $7B                             ; 8224
        ldx     #$B0                            ; 8225
        ldx     #$D5                            ; 8227
        ldx     #$E4                            ; 8229
        ldx     #$7B                            ; 822B
        ldx     #$FF                            ; 822D
        ldx     #$59                            ; 822F
        .byte   $A3                             ; 8231
L8232:  lda     $B1A5,y                         ; 8232
        and     #$0F                            ; 8235
        cmp     #$03                            ; 8237
        bne     L81CC                           ; 8239
        txa                                     ; 823B
        lsr     a                               ; 823C
        lsr     a                               ; 823D
        lsr     a                               ; 823E
        adc     $E0                             ; 823F
        lsr     a                               ; 8241
        and     #$03                            ; 8242
        adc     $B1A7,y                         ; 8244
        sta     $0702,x                         ; 8247
        rts                                     ; 824A

; ----------------------------------------------------------------------------
        lda     $0600,x                         ; 824B
        and     #$7F                            ; 824E
        tay                                     ; 8250
        lda     $B254,y                         ; 8251
        tay                                     ; 8254
        lda     $0601,x                         ; 8255
        bmi     L825F                           ; 8258
L825A:  iny                                     ; 825A
        iny                                     ; 825B
        asl     a                               ; 825C
        bpl     L825A                           ; 825D
L825F:  clc                                     ; 825F
        lda     $B294,y                         ; 8260
        adc     $04                             ; 8263
        sta     $04                             ; 8265
        clc                                     ; 8267
        lda     $B295,y                         ; 8268
        adc     $03                             ; 826B
        sta     $03                             ; 826D
        lda     $0600,x                         ; 826F
        and     #$7F                            ; 8272
        tay                                     ; 8274
        lda     $B2AC,y                         ; 8275
        jmp     LE992                           ; 8278

; ----------------------------------------------------------------------------
        jsr     LBF7F                           ; 827B
        bne     L82AF                           ; 827E
        lda     L0000                           ; 8280
        sta     $0600,y                         ; 8282
        lda     $01                             ; 8285
        sta     $0601,y                         ; 8287
        lda     $03                             ; 828A
        sta     $0602,y                         ; 828C
        lda     $04                             ; 828F
        sta     $0603,y                         ; 8291
        lda     $0D                             ; 8294
        sta     $0701,y                         ; 8296
        lda     $0E                             ; 8299
        sta     $0702,y                         ; 829B
        lda     $0F                             ; 829E
        sta     $0707,y                         ; 82A0
        tya                                     ; 82A3
        pha                                     ; 82A4
        tax                                     ; 82A5
        jsr     LE0A4                           ; 82A6
        pla                                     ; 82A9
        tay                                     ; 82AA
        ldx     $0C                             ; 82AB
        lda     #$00                            ; 82AD
L82AF:  rts                                     ; 82AF

; ----------------------------------------------------------------------------
        lda     #$00                            ; 82B0
        sta     $05                             ; 82B2
        lda     #$03                            ; 82B4
        sta     $06                             ; 82B6
L82B8:  jsr     LA27B                           ; 82B8
        bne     L82D4                           ; 82BB
        tya                                     ; 82BD
        tax                                     ; 82BE
        lda     #$61                            ; 82BF
        jsr     LFAB3                           ; 82C1
        lda     $05                             ; 82C4
        sta     $0700,x                         ; 82C6
        clc                                     ; 82C9
        adc     #$08                            ; 82CA
        sta     $05                             ; 82CC
        dec     $06                             ; 82CE
        bne     L82B8                           ; 82D0
        ldx     $0C                             ; 82D2
L82D4:  rts                                     ; 82D4

; ----------------------------------------------------------------------------
        jsr     LA27B                           ; 82D5
        bne     L82E3                           ; 82D8
        tya                                     ; 82DA
        tax                                     ; 82DB
        lda     #$25                            ; 82DC
        jsr     LF85D                           ; 82DE
        ldx     $0C                             ; 82E1
L82E3:  rts                                     ; 82E3

; ----------------------------------------------------------------------------
        jsr     LA27B                           ; 82E4
        bne     L82FE                           ; 82E7
        tya                                     ; 82E9
        tax                                     ; 82EA
        lda     #$20                            ; 82EB
        sta     $0607,x                         ; 82ED
        lda     $01                             ; 82F0
        and     #$0F                            ; 82F2
        sta     $0601,x                         ; 82F4
        ldy     #$00                            ; 82F7
        jsr     LFBA5                           ; 82F9
        ldx     $0C                             ; 82FC
L82FE:  rts                                     ; 82FE

; ----------------------------------------------------------------------------
        lda     #$00                            ; 82FF
        sta     $05                             ; 8301
        lda     #$05                            ; 8303
        sta     $06                             ; 8305
        lda     $01                             ; 8307
L8309:  and     #$8F                            ; 8309
        beq     L8311                           ; 830B
        lda     #$0A                            ; 830D
        sta     $05                             ; 830F
L8311:  .byte   $20                             ; 8311
        .byte   $7B                             ; 8312
L8313:  ldx     #$D0                            ; 8313
        rol     $05A6                           ; 8315
        lda     $A345,x                         ; 8318
        and     #$F0                            ; 831B
        ora     $01                             ; 831D
        sta     $0601,y                         ; 831F
        lda     $A345,x                         ; 8322
        and     #$0F                            ; 8325
        sta     $0705,y                         ; 8327
        inx                                     ; 832A
        lda     $A345,x                         ; 832B
        sta     $0706,y                         ; 832E
        lda     #$01                            ; 8331
        sta     $0606,y                         ; 8333
        lda     #$20                            ; 8336
        sta     $0607,y                         ; 8338
        inx                                     ; 833B
        stx     $05                             ; 833C
        ldx     $0C                             ; 833E
        dec     $06                             ; 8340
        bne     L8311                           ; 8342
L8344:  rts                                     ; 8344

; ----------------------------------------------------------------------------
        sta     ($80),y                         ; 8345
        bcc     L8309                           ; 8347
        .byte   $80                             ; 8349
        brk                                     ; 834A
        ldy     #$C0                            ; 834B
        lda     ($80,x)                         ; 834D
        eor     ($80),y                         ; 834F
        bvc     L8313                           ; 8351
        rti                                     ; 8353

; ----------------------------------------------------------------------------
        brk                                     ; 8354
        rts                                     ; 8355

; ----------------------------------------------------------------------------
        cpy     #$61                            ; 8356
        .byte   $80                             ; 8358
        lda     #$00                            ; 8359
        sta     $05                             ; 835B
        lda     #$04                            ; 835D
        sta     $06                             ; 835F
L8361:  jsr     LA27B                           ; 8361
        bne     L8382                           ; 8364
        tya                                     ; 8366
        tax                                     ; 8367
        lda     #$00                            ; 8368
        jsr     LF951                           ; 836A
        clc                                     ; 836D
        lda     $05                             ; 836E
        adc     #$18                            ; 8370
        sta     $05                             ; 8372
        sta     $0606,x                         ; 8374
        lda     $0C                             ; 8377
        sta     $0703,x                         ; 8379
        dec     $06                             ; 837C
        bne     L8361                           ; 837E
        ldx     $0C                             ; 8380
L8382:  rts                                     ; 8382

; ----------------------------------------------------------------------------
        lda     $22                             ; 8383
        bne     L838F                           ; 8385
        jsr     LA393                           ; 8387
        lda     $0601,x                         ; 838A
        beq     L8392                           ; 838D
L838F:  jsr     LE0A0                           ; 838F
L8392:  rts                                     ; 8392

; ----------------------------------------------------------------------------
        lda     $0702,x                         ; 8393
        and     #$0F                            ; 8396
        jsr     LE97D                           ; 8398
        lda     #$A3                            ; 839B
        .byte   $B2                             ; 839D
        .byte   $A3                             ; 839E
        .byte   $BB                             ; 839F
        .byte   $A3                             ; 83A0
        dec     $A3                             ; 83A1
        cmp     ($A3),y                         ; 83A3
        cmp     $A3,x                           ; 83A5
        dec     $A5A3,x                         ; 83A7
        txs                                     ; 83AA
L83AB:  sta     $03                             ; 83AB
        lda     #$07                            ; 83AD
        jmp     LFB62                           ; 83AF

; ----------------------------------------------------------------------------
        lda     $9A                             ; 83B2
        sta     $03                             ; 83B4
        lda     #$07                            ; 83B6
        jmp     LFAD7                           ; 83B8

; ----------------------------------------------------------------------------
        lda     $99                             ; 83BB
        jsr     LA3AB                           ; 83BD
        beq     L83C5                           ; 83C0
        jsr     LF877                           ; 83C2
L83C5:  rts                                     ; 83C5

; ----------------------------------------------------------------------------
        lda     $99                             ; 83C6
        beq     L83C5                           ; 83C8
        sta     $03                             ; 83CA
        lda     #$07                            ; 83CC
        jmp     LFBE9                           ; 83CE

; ----------------------------------------------------------------------------
        lda     #$03                            ; 83D1
        bne     L83AB                           ; 83D3
        lda     #$08                            ; 83D5
        sta     $03                             ; 83D7
        lda     #$03                            ; 83D9
        jmp     LFBE9                           ; 83DB

; ----------------------------------------------------------------------------
        ldy     $0703,x                         ; 83DE
        lda     $0600,y                         ; 83E1
        eor     #$0F                            ; 83E4
        bne     L83EC                           ; 83E6
        sta     $0601,x                         ; 83E8
        rts                                     ; 83EB

; ----------------------------------------------------------------------------
L83EC:  lda     $9F                             ; 83EC
        bne     L83F3                           ; 83EE
        jsr     LE0A2                           ; 83F0
L83F3:  jmp     LFA84                           ; 83F3

; ----------------------------------------------------------------------------
        lda     $0305                           ; 83F6
        beq     L8402                           ; 83F9
        lda     $0707,x                         ; 83FB
        and     #$20                            ; 83FE
        bne     L8416                           ; 8400
L8402:  lda     $0607                           ; 8402
        asl     a                               ; 8405
        bcc     L843D                           ; 8406
        jsr     LF0CF                           ; 8408
        cmp     #$02                            ; 840B
        bcc     L843D                           ; 840D
        lda     $0707,x                         ; 840F
        and     #$40                            ; 8412
        beq     L843D                           ; 8414
L8416:  lda     $0707,x                         ; 8416
        ora     #$10                            ; 8419
        sta     $0707,x                         ; 841B
        lda     #$00                            ; 841E
        sta     $0702,x                         ; 8420
        lda     $0601                           ; 8423
        and     #$F0                            ; 8426
        sta     L0000                           ; 8428
        lda     $0601,x                         ; 842A
        and     #$0F                            ; 842D
        ora     L0000                           ; 842F
        sta     $0601,x                         ; 8431
        jsr     LE0A4                           ; 8434
        lda     #$21                            ; 8437
        jsr     LE992                           ; 8439
        sec                                     ; 843C
L843D:  rts                                     ; 843D

; ----------------------------------------------------------------------------
        sta     L0000                           ; 843E
        lda     $20                             ; 8440
        ora     $29                             ; 8442
        bne     L843D                           ; 8444
        lda     $0302                           ; 8446
        ora     $28                             ; 8449
        beq     L8458                           ; 844B
        lsr     L0000                           ; 844D
        lda     $0302                           ; 844F
        cmp     #$02                            ; 8452
        bne     L8458                           ; 8454
        lsr     L0000                           ; 8456
L8458:  lda     $81                             ; 8458
        sec                                     ; 845A
        sbc     L0000                           ; 845B
        bcs     L8461                           ; 845D
        lda     #$00                            ; 845F
L8461:  sta     $81                             ; 8461
        lda     $0707                           ; 8463
        ora     #$80                            ; 8466
        sta     $0707                           ; 8468
        inc     $03F6                           ; 846B
        lda     #$00                            ; 846E
        sta     $03F5                           ; 8470
        sta     $03F2                           ; 8473
        lda     #$04                            ; 8476
        sta     $20                             ; 8478
        jsr     LEAB9                           ; 847A
        lda     #$33                            ; 847D
        jmp     LE992                           ; 847F

; ----------------------------------------------------------------------------
        pha                                     ; 8482
        lda     $0600                           ; 8483
        cmp     #$04                            ; 8486
        pla                                     ; 8488
        bcs     L84AD                           ; 8489
        sta     $32                             ; 848B
        lda     #$3A                            ; 848D
        jsr     LE992                           ; 848F
        jsr     L85C2                           ; 8492
        bvs     L84AD                           ; 8495
        lda     #$02                            ; 8497
        sta     $0600                           ; 8499
        lda     $0601                           ; 849C
        and     #$F0                            ; 849F
        sta     $0601                           ; 84A1
        txa                                     ; 84A4
        pha                                     ; 84A5
        ldx     #$00                            ; 84A6
        jsr     LE0A4                           ; 84A8
        pla                                     ; 84AB
        tax                                     ; 84AC
L84AD:  rts                                     ; 84AD

; ----------------------------------------------------------------------------
        lda     $19                             ; 84AE
        bne     L850E                           ; 84B0
        lda     $A6                             ; 84B2
        beq     L850E                           ; 84B4
        cmp     $E0                             ; 84B6
        lda     #$00                            ; 84B8
        bcc     L850E                           ; 84BA
        jsr     LA50F                           ; 84BC
        sta     L0000                           ; 84BF
        lda     $0707,x                         ; 84C1
        lsr     a                               ; 84C4
        lsr     a                               ; 84C5
        lsr     a                               ; 84C6
        and     #$03                            ; 84C7
        beq     L84E2                           ; 84C9
        sta     $01                             ; 84CB
        cmp     #$02                            ; 84CD
        lda     L0000                           ; 84CF
        bcs     L84DA                           ; 84D1
        bne     L84E2                           ; 84D3
        inc     L0000                           ; 84D5
        jmp     LA4E2                           ; 84D7

; ----------------------------------------------------------------------------
L84DA:  cmp     #$02                            ; 84DA
        bcc     L84E2                           ; 84DC
        lda     #$05                            ; 84DE
        sta     L0000                           ; 84E0
L84E2:  jsr     LF11C                           ; 84E2
        bne     L850E                           ; 84E5
        lda     #$0C                            ; 84E7
        sta     $0600,y                         ; 84E9
        lda     L0000                           ; 84EC
        ora     #$80                            ; 84EE
        sta     $0601,y                         ; 84F0
        lda     $0602,x                         ; 84F3
        and     #$F0                            ; 84F6
        ora     #$08                            ; 84F8
        sta     $0602,y                         ; 84FA
        lda     $0603,x                         ; 84FD
        and     #$F0                            ; 8500
        ora     #$08                            ; 8502
        sta     $0603,y                         ; 8504
        txa                                     ; 8507
        pha                                     ; 8508
        tya                                     ; 8509
        tax                                     ; 850A
        jmp     LA4A8                           ; 850B

; ----------------------------------------------------------------------------
L850E:  rts                                     ; 850E

; ----------------------------------------------------------------------------
        lda     $83                             ; 850F
        and     #$03                            ; 8511
        sta     L0000                           ; 8513
        lda     $83                             ; 8515
        lsr     a                               ; 8517
        lsr     a                               ; 8518
        and     #$1F                            ; 8519
        tay                                     ; 851B
        lda     $B2EC,y                         ; 851C
L851F:  dec     L0000                           ; 851F
        bmi     L8527                           ; 8521
        lsr     a                               ; 8523
        lsr     a                               ; 8524
        bne     L851F                           ; 8525
L8527:  inc     $83                             ; 8527
        and     #$03                            ; 8529
        rts                                     ; 852B

; ----------------------------------------------------------------------------
        lda     $0600,x                         ; 852C
        and     #$7F                            ; 852F
        cmp     #$10                            ; 8531
        beq     L854E                           ; 8533
        lda     $0600,x                         ; 8535
        sta     $0606,x                         ; 8538
        lda     #$0F                            ; 853B
        sta     $0600,x                         ; 853D
        lda     #$00                            ; 8540
        jsr     LA57D                           ; 8542
        lda     #$3C                            ; 8545
        sta     $0700,x                         ; 8547
        lda     #$23                            ; 854A
        bne     L855A                           ; 854C
L854E:  lda     $0606,x                         ; 854E
        sta     $0600,x                         ; 8551
        jsr     LA839                           ; 8554
        jmp     LA53B                           ; 8557

; ----------------------------------------------------------------------------
L855A:  jsr     LE992                           ; 855A
        jsr     LE0A4                           ; 855D
        txa                                     ; 8560
        pha                                     ; 8561
        lda     $03                             ; 8562
        and     #$F0                            ; 8564
        lsr     a                               ; 8566
        lsr     a                               ; 8567
        lsr     a                               ; 8568
        tay                                     ; 8569
        lda     $B498,y                         ; 856A
        sta     L0000                           ; 856D
        lda     $B499,y                         ; 856F
        sta     $01                             ; 8572
        jsr     LEC46                           ; 8574
        jsr     LEAC1                           ; 8577
        pla                                     ; 857A
        tax                                     ; 857B
        rts                                     ; 857C

; ----------------------------------------------------------------------------
        jsr     LF0BE                           ; 857D
        lda     $33                             ; 8580
        cmp     #$09                            ; 8582
        bcc     L859C                           ; 8584
        cmp     #$0C                            ; 8586
        bcc     L8596                           ; 8588
        cmp     #$0F                            ; 858A
        bcs     L859C                           ; 858C
        lda     $B1                             ; 858E
        and     #$03                            ; 8590
        cmp     #$01                            ; 8592
        bne     L859C                           ; 8594
L8596:  inc     $0601,x                         ; 8596
        inc     $0601,x                         ; 8599
L859C:  rts                                     ; 859C

; ----------------------------------------------------------------------------
        lda     $0600,x                         ; 859D
        and     #$7F                            ; 85A0
        cmp     #$10                            ; 85A2
        beq     L85BF                           ; 85A4
        lda     $0600,x                         ; 85A6
        sta     $0606,x                         ; 85A9
        lda     #$0F                            ; 85AC
        sta     $0600,x                         ; 85AE
        lda     #$01                            ; 85B1
        jsr     LA57D                           ; 85B3
        lda     #$3C                            ; 85B6
        sta     $0700,x                         ; 85B8
        lda     #$24                            ; 85BB
        bne     L855A                           ; 85BD
L85BF:  lda     $0606,x                         ; 85BF
L85C2:  sta     $0600,x                         ; 85C2
        jsr     LA839                           ; 85C5
        jmp     LA5AC                           ; 85C8

; ----------------------------------------------------------------------------
        cpx     $031B                           ; 85CB
        bne     L85D5                           ; 85CE
        lda     #$00                            ; 85D0
        sta     $031B                           ; 85D2
L85D5:  lda     $0707,x                         ; 85D5
        and     #$40                            ; 85D8
        beq     L85F4                           ; 85DA
        lda     $0606,x                         ; 85DC
        sta     $0600,x                         ; 85DF
        lda     #$05                            ; 85E2
        jsr     LF0BE                           ; 85E4
        jsr     LE0A4                           ; 85E7
        lda     #$00                            ; 85EA
        sta     $0701,x                         ; 85EC
        sta     $0702,x                         ; 85EF
        beq     L85F7                           ; 85F2
L85F4:  sta     $0601,x                         ; 85F4
L85F7:  lda     $0707,x                         ; 85F7
        and     #$20                            ; 85FA
        beq     L8600                           ; 85FC
        dec     $93                             ; 85FE
L8600:  inc     $03F2                           ; 8600
        rts                                     ; 8603

; ----------------------------------------------------------------------------
        lda     $BF                             ; 8604
        and     #$18                            ; 8606
        bne     L864B                           ; 8608
        lda     $B0                             ; 860A
        and     #$F0                            ; 860C
        beq     L8614                           ; 860E
        cmp     #$30                            ; 8610
        bcc     L864B                           ; 8612
L8614:  jsr     LF11C                           ; 8614
        bne     L864B                           ; 8617
        txa                                     ; 8619
        pha                                     ; 861A
        tya                                     ; 861B
        tax                                     ; 861C
        lda     #$20                            ; 861D
        sta     $0600,x                         ; 861F
        lda     #$10                            ; 8622
        sta     $0601,x                         ; 8624
        lda     #$A8                            ; 8627
        sta     $0602,x                         ; 8629
        lda     #$80                            ; 862C
        sta     $0603,x                         ; 862E
        lda     #$00                            ; 8631
        sta     $0700,x                         ; 8633
        lda     $031B                           ; 8636
        beq     L8640                           ; 8639
        lda     #$14                            ; 863B
        sta     $0601,x                         ; 863D
L8640:  jsr     LE0A4                           ; 8640
        jsr     LA874                           ; 8643
        stx     $031B                           ; 8646
        pla                                     ; 8649
        tax                                     ; 864A
L864B:  rts                                     ; 864B

; ----------------------------------------------------------------------------
        lda     $0702,x                         ; 864C
        bpl     L8658                           ; 864F
        inc     $0702,x                         ; 8651
        and     #$02                            ; 8654
        beq     L865B                           ; 8656
L8658:  jsr     LE0A0                           ; 8658
L865B:  lda     $0701,x                         ; 865B
        clc                                     ; 865E
        adc     $030A                           ; 865F
        sta     $030A                           ; 8662
        rts                                     ; 8665

; ----------------------------------------------------------------------------
        jsr     LF3E0                           ; 8666
        sta     $05                             ; 8669
        beq     L8696                           ; 866B
        jsr     LA839                           ; 866D
        sta     L0000                           ; 8670
        lda     $05                             ; 8672
        bpl     L8699                           ; 8674
        lda     $20                             ; 8676
        ora     $29                             ; 8678
        bne     L8696                           ; 867A
        lda     L0000                           ; 867C
        jsr     LA43E                           ; 867E
        lda     $0601,x                         ; 8681
        and     #$C0                            ; 8684
        beq     L868C                           ; 8686
        eor     #$C0                            ; 8688
        bne     L8691                           ; 868A
L868C:  lda     $0601,x                         ; 868C
        eor     #$30                            ; 868F
L8691:  sta     $04                             ; 8691
        jsr     LA6CC                           ; 8693
L8696:  lda     #$00                            ; 8696
        rts                                     ; 8698

; ----------------------------------------------------------------------------
L8699:  lda     $BE                             ; 8699
        and     #$30                            ; 869B
        beq     L86A6                           ; 869D
        lda     $0707,x                         ; 869F
        and     #$04                            ; 86A2
        bne     L8696                           ; 86A4
L86A6:  lda     $0702,x                         ; 86A6
        bmi     L8696                           ; 86A9
        lda     $05                             ; 86AB
        and     #$04                            ; 86AD
        beq     L86BE                           ; 86AF
        lda     $0707,x                         ; 86B1
        and     #$01                            ; 86B4
        beq     L8696                           ; 86B6
        jsr     LA6E9                           ; 86B8
        jmp     LA6C8                           ; 86BB

; ----------------------------------------------------------------------------
L86BE:  lda     $0707,x                         ; 86BE
        and     #$02                            ; 86C1
        beq     L8696                           ; 86C3
        jsr     LA72E                           ; 86C5
        beq     L86E8                           ; 86C8
        bcc     L86E8                           ; 86CA
        php                                     ; 86CC
        lda     #$E0                            ; 86CD
        sta     $0702,x                         ; 86CF
        lda     $02                             ; 86D2
        and     #$01                            ; 86D4
        bne     L86E7                           ; 86D6
        lda     #$02                            ; 86D8
        jsr     LF0BE                           ; 86DA
        lda     $04                             ; 86DD
        and     #$F0                            ; 86DF
        sta     $0606,x                         ; 86E1
        jsr     LE0A4                           ; 86E4
L86E7:  plp                                     ; 86E7
L86E8:  rts                                     ; 86E8

; ----------------------------------------------------------------------------
        lda     $8F                             ; 86E9
        sta     L0000                           ; 86EB
        jsr     LF0CF                           ; 86ED
        sta     $01                             ; 86F0
        cmp     #$03                            ; 86F2
        bcc     L86F8                           ; 86F4
        asl     L0000                           ; 86F6
L86F8:  sec                                     ; 86F8
        lda     $0701,x                         ; 86F9
        sbc     L0000                           ; 86FC
        beq     L8702                           ; 86FE
        bcs     L8704                           ; 8700
L8702:  lda     #$00                            ; 8702
L8704:  sta     $0701,x                         ; 8704
        beq     L8717                           ; 8707
        lda     #$26                            ; 8709
        jsr     LE992                           ; 870B
        lda     $0601                           ; 870E
        sta     $04                             ; 8711
        lda     #$01                            ; 8713
        sec                                     ; 8715
        rts                                     ; 8716

; ----------------------------------------------------------------------------
L8717:  lda     $01                             ; 8717
        cmp     #$02                            ; 8719
        beq     L8727                           ; 871B
        cmp     #$04                            ; 871D
        beq     L8727                           ; 871F
        jsr     LA52C                           ; 8721
        jmp     LA72A                           ; 8724

; ----------------------------------------------------------------------------
L8727:  jsr     LA59D                           ; 8727
        lda     #$01                            ; 872A
        clc                                     ; 872C
        rts                                     ; 872D

; ----------------------------------------------------------------------------
        lda     $8F                             ; 872E
        sta     L0000                           ; 8730
        lda     $0601,y                         ; 8732
        sta     $04                             ; 8735
        lda     #$00                            ; 8737
        sta     $0601,y                         ; 8739
        sta     $01                             ; 873C
        lda     $04                             ; 873E
        and     #$0F                            ; 8740
        beq     L8770                           ; 8742
        cmp     #$07                            ; 8744
        beq     L8757                           ; 8746
        lda     $90                             ; 8748
        sta     L0000                           ; 874A
        jsr     LF0ED                           ; 874C
        sta     $01                             ; 874F
        cmp     #$02                            ; 8751
        bcc     L8757                           ; 8753
        asl     L0000                           ; 8755
L8757:  sec                                     ; 8757
        lda     $0701,x                         ; 8758
        sbc     L0000                           ; 875B
        beq     L8761                           ; 875D
        bcs     L8763                           ; 875F
L8761:  lda     #$00                            ; 8761
L8763:  sta     $0701,x                         ; 8763
        beq     L8771                           ; 8766
        lda     #$27                            ; 8768
        jsr     LE992                           ; 876A
        lda     #$01                            ; 876D
        sec                                     ; 876F
L8770:  rts                                     ; 8770

; ----------------------------------------------------------------------------
L8771:  lda     $01                             ; 8771
        cmp     #$02                            ; 8773
        beq     L8781                           ; 8775
        cmp     #$05                            ; 8777
        beq     L8781                           ; 8779
        jsr     LA52C                           ; 877B
        jmp     LA784                           ; 877E

; ----------------------------------------------------------------------------
L8781:  jsr     LA59D                           ; 8781
        lda     #$01                            ; 8784
        clc                                     ; 8786
        rts                                     ; 8787

; ----------------------------------------------------------------------------
        jsr     LF3E0                           ; 8788
        beq     L87A5                           ; 878B
        sta     $05                             ; 878D
        jsr     LA839                           ; 878F
        sta     L0000                           ; 8792
        lda     $05                             ; 8794
        bpl     L87A6                           ; 8796
        lda     $20                             ; 8798
        ora     $29                             ; 879A
        bne     L87A3                           ; 879C
        lda     L0000                           ; 879E
        jsr     LA43E                           ; 87A0
L87A3:  lda     #$00                            ; 87A3
L87A5:  rts                                     ; 87A5

; ----------------------------------------------------------------------------
L87A6:  lda     $0702,x                         ; 87A6
        bmi     L87A3                           ; 87A9
        lda     $05                             ; 87AB
        and     #$04                            ; 87AD
        beq     L87BE                           ; 87AF
        lda     $0601,x                         ; 87B1
        and     $08                             ; 87B4
        bne     L87E2                           ; 87B6
        jsr     LA6E9                           ; 87B8
        jmp     LA6C8                           ; 87BB

; ----------------------------------------------------------------------------
L87BE:  lda     $05                             ; 87BE
        and     #$02                            ; 87C0
        beq     L87E2                           ; 87C2
        lda     $0601,x                         ; 87C4
        and     $08                             ; 87C7
        bne     L87D1                           ; 87C9
        jsr     LA72E                           ; 87CB
        jmp     LA6C8                           ; 87CE

; ----------------------------------------------------------------------------
L87D1:  lda     $0601,x                         ; 87D1
        and     #$F0                            ; 87D4
        sta     L0000                           ; 87D6
        lda     $0601,y                         ; 87D8
        and     #$0F                            ; 87DB
        ora     L0000                           ; 87DD
        sta     $0601,y                         ; 87DF
L87E2:  lda     #$28                            ; 87E2
        jsr     LE992                           ; 87E4
        jmp     LA7A3                           ; 87E7

; ----------------------------------------------------------------------------
        lda     $BE                             ; 87EA
        and     #$C0                            ; 87EC
        cmp     #$80                            ; 87EE
        bcc     L882A                           ; 87F0
        beq     L882D                           ; 87F2
        jsr     LF3E0                           ; 87F4
        beq     L880B                           ; 87F7
        sta     $05                             ; 87F9
        jsr     LA839                           ; 87FB
        sta     L0000                           ; 87FE
        lda     $05                             ; 8800
        bmi     L8830                           ; 8802
        lda     $0702,x                         ; 8804
        bpl     L880C                           ; 8807
        lda     #$00                            ; 8809
L880B:  rts                                     ; 880B

; ----------------------------------------------------------------------------
L880C:  lda     $0601,x                         ; 880C
        ora     $08                             ; 880F
        sta     $01                             ; 8811
        and     #$C0                            ; 8813
        cmp     #$C0                            ; 8815
        beq     L8833                           ; 8817
        lda     $01                             ; 8819
        and     #$30                            ; 881B
        cmp     #$30                            ; 881D
        beq     L8833                           ; 881F
        lda     $05                             ; 8821
        and     #$02                            ; 8823
        beq     L8836                           ; 8825
        jmp     LA7D1                           ; 8827

; ----------------------------------------------------------------------------
L882A:  jmp     LA666                           ; 882A

; ----------------------------------------------------------------------------
L882D:  jmp     LA788                           ; 882D

; ----------------------------------------------------------------------------
L8830:  jmp     LA798                           ; 8830

; ----------------------------------------------------------------------------
L8833:  jmp     LA7AB                           ; 8833

; ----------------------------------------------------------------------------
L8836:  jmp     LA7E2                           ; 8836

; ----------------------------------------------------------------------------
        lda     $0600,x                         ; 8839
        and     #$7F                            ; 883C
        cmp     #$10                            ; 883E
        bcc     L8873                           ; 8840
        pha                                     ; 8842
        jsr     L80AD                           ; 8843
        pla                                     ; 8846
        asl     a                               ; 8847
        rol     $01                             ; 8848
        asl     a                               ; 884A
        rol     $01                             ; 884B
        asl     a                               ; 884D
        rol     $01                             ; 884E
        clc                                     ; 8850
        adc     #$8C                            ; 8851
        sta     L0000                           ; 8853
        lda     $01                             ; 8855
        and     #$07                            ; 8857
        adc     #$B2                            ; 8859
        sta     $01                             ; 885B
        sty     $3C                             ; 885D
        ldy     #$00                            ; 885F
        lda     (L0000),y                       ; 8861
        sta     $02                             ; 8863
        iny                                     ; 8865
        lda     (L0000),y                       ; 8866
        sta     $03                             ; 8868
        and     #$0F                            ; 886A
        tay                                     ; 886C
        lda     $B48C,y                         ; 886D
        ldy     $3C                             ; 8870
        sec                                     ; 8872
L8873:  rts                                     ; 8873

; ----------------------------------------------------------------------------
        jsr     LA839                           ; 8874
        bcc     L8895                           ; 8877
        ldy     #$02                            ; 8879
        lda     (L0000),y                       ; 887B
        sta     $0707,x                         ; 887D
        ldy     $82                             ; 8880
        iny                                     ; 8882
        iny                                     ; 8883
        iny                                     ; 8884
        lda     (L0000),y                       ; 8885
        sta     $0701,x                         ; 8887
        ldy     $3C                             ; 888A
        lda     $0707,x                         ; 888C
        and     #$20                            ; 888F
        beq     L8895                           ; 8891
        inc     $93                             ; 8893
L8895:  rts                                     ; 8895

; ----------------------------------------------------------------------------
        jsr     LF301                           ; 8896
        lda     $7F                             ; 8899
        and     #$03                            ; 889B
        sta     $3B                             ; 889D
        clc                                     ; 889F
        adc     $A0                             ; 88A0
        tay                                     ; 88A2
        lda     $B4AE,y                         ; 88A3
        sta     $96                             ; 88A6
        lda     $3B                             ; 88A8
        clc                                     ; 88AA
        adc     $A2                             ; 88AB
        tay                                     ; 88AD
        lda     $B4AE,y                         ; 88AE
        sta     $A1                             ; 88B1
        clc                                     ; 88B3
        lda     $3B                             ; 88B4
        adc     $70                             ; 88B6
        tay                                     ; 88B8
        lda     $B4A6,y                         ; 88B9
        sta     $97                             ; 88BC
        lda     $B4AA,y                         ; 88BE
        sta     $98                             ; 88C1
        lda     $B4AE,y                         ; 88C3
        sta     $99                             ; 88C6
        lda     $B4B2,y                         ; 88C8
        sta     $9A                             ; 88CB
        ldy     #$04                            ; 88CD
L88CF:  lda     $9B,y                           ; 88CF
        bne     L88D6                           ; 88D2
        lda     #$06                            ; 88D4
L88D6:  sec                                     ; 88D6
        sbc     $96,y                           ; 88D7
        sta     $9B,y                           ; 88DA
        bcs     L88E4                           ; 88DD
        lda     #$00                            ; 88DF
        sta     $9B,y                           ; 88E1
L88E4:  dey                                     ; 88E4
        bpl     L88CF                           ; 88E5
        lda     $29                             ; 88E7
        bne     L88EE                           ; 88E9
        jsr     LA8F1                           ; 88EB
L88EE:  jmp     LA917                           ; 88EE

; ----------------------------------------------------------------------------
        lda     $95                             ; 88F1
        cmp     #$02                            ; 88F3
        bne     L890E                           ; 88F5
        lda     $92                             ; 88F7
        cmp     #$01                            ; 88F9
        bne     L8902                           ; 88FB
        lda     $0304                           ; 88FD
        bne     L890E                           ; 8900
L8902:  lda     $A0                             ; 8902
        lsr     a                               ; 8904
        clc                                     ; 8905
        adc     $3B                             ; 8906
        tay                                     ; 8908
        lda     $B4AE,y                         ; 8909
        sta     $96                             ; 890C
L890E:  lda     $19                             ; 890E
        cmp     #$04                            ; 8910
        bne     L8916                           ; 8912
        asl     $96                             ; 8914
L8916:  rts                                     ; 8916

; ----------------------------------------------------------------------------
        jsr     LF0ED                           ; 8917
        cmp     #$03                            ; 891A
        bcc     L892B                           ; 891C
        clc                                     ; 891E
        lda     #$04                            ; 891F
        adc     $3B                             ; 8921
        adc     $A2                             ; 8923
        tay                                     ; 8925
        lda     $B4AE,y                         ; 8926
        sta     $A1                             ; 8929
L892B:  rts                                     ; 892B

; ----------------------------------------------------------------------------
        lda     $0605,x                         ; 892C
        sta     $05                             ; 892F
        lda     $0601,x                         ; 8931
        bpl     L893C                           ; 8934
        inc     $05                             ; 8936
        lda     #$00                            ; 8938
        beq     L8943                           ; 893A
L893C:  asl     a                               ; 893C
        bpl     L8949                           ; 893D
        dec     $05                             ; 893F
        lda     #$0F                            ; 8941
L8943:  sta     L0000                           ; 8943
        lda     #$0F                            ; 8945
        bne     L8966                           ; 8947
L8949:  asl     a                               ; 8949
        bpl     L8957                           ; 894A
        clc                                     ; 894C
        lda     $05                             ; 894D
        adc     #$10                            ; 894F
        sta     $05                             ; 8951
        lda     #$C0                            ; 8953
        bne     L8962                           ; 8955
L8957:  sec                                     ; 8957
        lda     $05                             ; 8958
        sbc     #$10                            ; 895A
        sta     $05                             ; 895C
        lda     $CA                             ; 895E
        and     #$F0                            ; 8960
L8962:  sta     L0000                           ; 8962
        lda     #$F0                            ; 8964
L8966:  and     $05                             ; 8966
        cmp     L0000                           ; 8968
        bne     L8970                           ; 896A
        sec                                     ; 896C
        lda     #$0B                            ; 896D
        rts                                     ; 896F

; ----------------------------------------------------------------------------
L8970:  lda     $05                             ; 8970
        jsr     LE088                           ; 8972
        cmp     #$03                            ; 8975
        bcc     L8983                           ; 8977
        cmp     #$04                            ; 8979
        beq     L8983                           ; 897B
        cmp     #$0B                            ; 897D
        beq     L8985                           ; 897F
        bcc     L8985                           ; 8981
L8983:  lda     #$00                            ; 8983
L8985:  clc                                     ; 8985
        rts                                     ; 8986

; ----------------------------------------------------------------------------
        lda     $0605                           ; 8987
        sta     $0318                           ; 898A
        lda     $BF                             ; 898D
        and     #$10                            ; 898F
        beq     L8997                           ; 8991
        lda     $6F                             ; 8993
        bne     L899A                           ; 8995
L8997:  lda     $0601                           ; 8997
L899A:  bpl     L89A3                           ; 899A
        inc     $0318                           ; 899C
        lda     #$00                            ; 899F
        beq     L89AB                           ; 89A1
L89A3:  asl     a                               ; 89A3
        bpl     L89BC                           ; 89A4
        dec     $0318                           ; 89A6
        lda     #$0F                            ; 89A9
L89AB:  sta     L0000                           ; 89AB
        lda     $0318                           ; 89AD
        sta     $05                             ; 89B0
        clc                                     ; 89B2
        adc     #$10                            ; 89B3
        sta     $0318                           ; 89B5
        lda     #$0F                            ; 89B8
        bne     L89E3                           ; 89BA
L89BC:  asl     a                               ; 89BC
        bpl     L89D0                           ; 89BD
        clc                                     ; 89BF
        lda     $0318                           ; 89C0
        adc     #$10                            ; 89C3
        sta     $05                             ; 89C5
        adc     #$10                            ; 89C7
        sta     $0318                           ; 89C9
        lda     #$C0                            ; 89CC
        bne     L89DF                           ; 89CE
L89D0:  sec                                     ; 89D0
        lda     $0318                           ; 89D1
        sbc     #$10                            ; 89D4
        sta     $05                             ; 89D6
        sbc     #$10                            ; 89D8
        sta     $0318                           ; 89DA
        lda     #$00                            ; 89DD
L89DF:  sta     L0000                           ; 89DF
        lda     #$F0                            ; 89E1
L89E3:  and     $05                             ; 89E3
        cmp     L0000                           ; 89E5
        beq     L8A13                           ; 89E7
        lda     $0319                           ; 89E9
        php                                     ; 89EC
        lda     $BF                             ; 89ED
        asl     a                               ; 89EF
        asl     a                               ; 89F0
        asl     a                               ; 89F1
        asl     a                               ; 89F2
        lda     $05                             ; 89F3
        bcc     L89FD                           ; 89F5
        jsr     LE088                           ; 89F7
        jmp     LAA00                           ; 89FA

; ----------------------------------------------------------------------------
L89FD:  jsr     LE074                           ; 89FD
        plp                                     ; 8A00
        bne     L8A0D                           ; 8A01
        cmp     #$0B                            ; 8A03
        beq     L8A13                           ; 8A05
        bcc     L8A0B                           ; 8A07
        lda     #$00                            ; 8A09
L8A0B:  clc                                     ; 8A0B
        rts                                     ; 8A0C

; ----------------------------------------------------------------------------
L8A0D:  asl     $0600,x                         ; 8A0D
        lsr     $0600,x                         ; 8A10
L8A13:  lda     $05                             ; 8A13
        sta     $0317                           ; 8A15
        lda     #$0B                            ; 8A18
L8A1A:  sec                                     ; 8A1A
        rts                                     ; 8A1B

; ----------------------------------------------------------------------------
        beq     L8A1A                           ; 8A1C
        sta     L0000                           ; 8A1E
        txa                                     ; 8A20
        bne     L8A2D                           ; 8A21
        lda     $BF                             ; 8A23
        and     #$10                            ; 8A25
        beq     L8A2D                           ; 8A27
        lda     $6F                             ; 8A29
        bne     L8A30                           ; 8A2B
L8A2D:  lda     $0601,x                         ; 8A2D
L8A30:  sta     $03                             ; 8A30
        and     #$A0                            ; 8A32
        sta     $02                             ; 8A34
        bne     L8A3D                           ; 8A36
        sec                                     ; 8A38
        sbc     L0000                           ; 8A39
        sta     L0000                           ; 8A3B
L8A3D:  lda     $03                             ; 8A3D
        and     #$30                            ; 8A3F
        beq     L8A6B                           ; 8A41
        lda     $0602,x                         ; 8A43
        sta     $01                             ; 8A46
        cmp     $CA                             ; 8A48
        bcs     L8A53                           ; 8A4A
        lda     $CA                             ; 8A4C
        adc     #$01                            ; 8A4E
        jmp     LAA5B                           ; 8A50

; ----------------------------------------------------------------------------
L8A53:  cmp     $C9                             ; 8A53
        bcc     L8A60                           ; 8A55
        lda     $C9                             ; 8A57
        sbc     #$01                            ; 8A59
        sta     $0602,x                         ; 8A5B
        sta     $01                             ; 8A5E
L8A60:  clc                                     ; 8A60
        adc     L0000                           ; 8A61
        sta     L0000                           ; 8A63
        sta     $0602,x                         ; 8A65
        jmp     LAA90                           ; 8A68

; ----------------------------------------------------------------------------
L8A6B:  lda     $0603,x                         ; 8A6B
        sta     $01                             ; 8A6E
        cmp     $C8                             ; 8A70
        bcs     L8A7B                           ; 8A72
        lda     $C8                             ; 8A74
        adc     #$01                            ; 8A76
        jmp     LAA83                           ; 8A78

; ----------------------------------------------------------------------------
L8A7B:  cmp     $C7                             ; 8A7B
        bcc     L8A88                           ; 8A7D
        lda     $C7                             ; 8A7F
        sbc     #$01                            ; 8A81
        sta     $0603,x                         ; 8A83
        sta     $01                             ; 8A86
L8A88:  clc                                     ; 8A88
        adc     L0000                           ; 8A89
        sta     L0000                           ; 8A8B
        sta     $0603,x                         ; 8A8D
        lda     $02                             ; 8A90
        beq     L8AA8                           ; 8A92
        lda     $01                             ; 8A94
        and     #$0F                            ; 8A96
        cmp     #$08                            ; 8A98
        bcs     L8AA4                           ; 8A9A
        lda     L0000                           ; 8A9C
        and     #$0F                            ; 8A9E
        cmp     #$08                            ; 8AA0
        bcs     L8AB8                           ; 8AA2
L8AA4:  lda     #$00                            ; 8AA4
        sec                                     ; 8AA6
        rts                                     ; 8AA7

; ----------------------------------------------------------------------------
L8AA8:  lda     $01                             ; 8AA8
        and     #$0F                            ; 8AAA
        cmp     #$09                            ; 8AAC
        bcc     L8AA4                           ; 8AAE
        lda     L0000                           ; 8AB0
        and     #$0F                            ; 8AB2
        cmp     #$09                            ; 8AB4
        bcs     L8AA4                           ; 8AB6
L8AB8:  lda     $0602,x                         ; 8AB8
        and     #$F0                            ; 8ABB
        sta     $02                             ; 8ABD
        lda     $0603,x                         ; 8ABF
        lsr     a                               ; 8AC2
        lsr     a                               ; 8AC3
        lsr     a                               ; 8AC4
        lsr     a                               ; 8AC5
        ora     $02                             ; 8AC6
        sta     $0605,x                         ; 8AC8
        sta     $02                             ; 8ACB
        jsr     LE088                           ; 8ACD
        pha                                     ; 8AD0
        txa                                     ; 8AD1
        bne     L8AEA                           ; 8AD2
        lda     $031C                           ; 8AD4
        ora     #$10                            ; 8AD7
        sta     $031C                           ; 8AD9
        lda     #$00                            ; 8ADC
        sta     $64                             ; 8ADE
        lda     $BF                             ; 8AE0
        and     #$10                            ; 8AE2
        beq     L8AEA                           ; 8AE4
        lda     $6F                             ; 8AE6
        bne     L8AED                           ; 8AE8
L8AEA:  lda     $0601,x                         ; 8AEA
L8AED:  and     #$C0                            ; 8AED
        bne     L8AFD                           ; 8AEF
        lda     $0602,x                         ; 8AF1
        and     #$F0                            ; 8AF4
        ora     #$08                            ; 8AF6
        sta     $0602,x                         ; 8AF8
        bne     L8B07                           ; 8AFB
L8AFD:  lda     $0603,x                         ; 8AFD
        and     #$F0                            ; 8B00
        ora     #$08                            ; 8B02
        sta     $0603,x                         ; 8B04
L8B07:  pla                                     ; 8B07
        clc                                     ; 8B08
        rts                                     ; 8B09

; ----------------------------------------------------------------------------
        asl     a                               ; 8B0A
        bcc     L8B10                           ; 8B0B
        lda     #$80                            ; 8B0D
        rts                                     ; 8B0F

; ----------------------------------------------------------------------------
L8B10:  asl     a                               ; 8B10
        bcc     L8B16                           ; 8B11
        lda     #$40                            ; 8B13
        rts                                     ; 8B15

; ----------------------------------------------------------------------------
L8B16:  asl     a                               ; 8B16
        bcc     L8B1C                           ; 8B17
        lda     #$20                            ; 8B19
        rts                                     ; 8B1B

; ----------------------------------------------------------------------------
L8B1C:  asl     a                               ; 8B1C
        lda     #$00                            ; 8B1D
        bcc     L8B23                           ; 8B1F
        lda     #$10                            ; 8B21
L8B23:  rts                                     ; 8B23

; ----------------------------------------------------------------------------
L8B24:  rts                                     ; 8B24

; ----------------------------------------------------------------------------
        lda     $21                             ; 8B25
        bne     L8B24                           ; 8B27
        lda     $C0                             ; 8B29
        jsr     LAB0A                           ; 8B2B
        sta     $6F                             ; 8B2E
        and     $0601,x                         ; 8B30
        bne     L8B72                           ; 8B33
        lda     $34                             ; 8B35
        beq     L8B3E                           ; 8B37
        dec     $34                             ; 8B39
        jmp     LAB90                           ; 8B3B

; ----------------------------------------------------------------------------
L8B3E:  lda     $BF                             ; 8B3E
        and     #$10                            ; 8B40
        beq     L8B4A                           ; 8B42
        lda     $6F                             ; 8B44
        and     #$30                            ; 8B46
        bne     L8B72                           ; 8B48
L8B4A:  lda     $6F                             ; 8B4A
        and     #$F0                            ; 8B4C
        beq     L8BB1                           ; 8B4E
        lda     $0601,x                         ; 8B50
        and     #$0F                            ; 8B53
        cmp     #$05                            ; 8B55
        bcc     L8B5D                           ; 8B57
        cmp     #$08                            ; 8B59
        bcc     L8B72                           ; 8B5B
L8B5D:  sta     $0601,x                         ; 8B5D
        lda     $6F                             ; 8B60
        jsr     LAB0A                           ; 8B62
        ora     $0601,x                         ; 8B65
        sta     $0601,x                         ; 8B68
        lda     #$0A                            ; 8B6B
        sta     $9B                             ; 8B6D
        jsr     LE0A4                           ; 8B6F
L8B72:  lda     $9B                             ; 8B72
        bne     L8B79                           ; 8B74
        jsr     LE0A2                           ; 8B76
L8B79:  lda     $7F                             ; 8B79
        and     #$0F                            ; 8B7B
        bne     L8B90                           ; 8B7D
        lda     $B0                             ; 8B7F
        and     #$F0                            ; 8B81
        cmp     #$50                            ; 8B83
        beq     L8B8B                           ; 8B85
        cmp     #$90                            ; 8B87
        bne     L8B90                           ; 8B89
L8B8B:  lda     #$04                            ; 8B8B
        jsr     LE992                           ; 8B8D
L8B90:  lda     $95                             ; 8B90
        cmp     #$0B                            ; 8B92
        bcs     L8B9B                           ; 8B94
        jsr     LA987                           ; 8B96
        bcs     L8BB1                           ; 8B99
L8B9B:  lda     $96                             ; 8B9B
        jsr     LAA1C                           ; 8B9D
        php                                     ; 8BA0
        pha                                     ; 8BA1
        jsr     LABF2                           ; 8BA2
        pla                                     ; 8BA5
        plp                                     ; 8BA6
        bcs     L8BB1                           ; 8BA7
        sta     $95                             ; 8BA9
        jsr     LABB9                           ; 8BAB
L8BAE:  jmp     LAC1D                           ; 8BAE

; ----------------------------------------------------------------------------
L8BB1:  jsr     LABB9                           ; 8BB1
        bne     L8BAE                           ; 8BB4
        jmp     LACF1                           ; 8BB6

; ----------------------------------------------------------------------------
        lda     $29                             ; 8BB9
        bne     L8BEF                           ; 8BBB
        lda     $96                             ; 8BBD
        sta     L0000                           ; 8BBF
        lda     $35                             ; 8BC1
        beq     L8BEA                           ; 8BC3
        lda     $0601,x                         ; 8BC5
        pha                                     ; 8BC8
        and     #$30                            ; 8BC9
        beq     L8BCF                           ; 8BCB
        lsr     L0000                           ; 8BCD
L8BCF:  lda     $35                             ; 8BCF
        sta     $0601,x                         ; 8BD1
        lda     L0000                           ; 8BD4
        sta     $96                             ; 8BD6
        jsr     LA987                           ; 8BD8
        bcs     L8BEB                           ; 8BDB
        lda     $96                             ; 8BDD
        jsr     LAA1C                           ; 8BDF
        bcs     L8BEB                           ; 8BE2
        sta     $95                             ; 8BE4
        pla                                     ; 8BE6
        sta     $0601,x                         ; 8BE7
L8BEA:  rts                                     ; 8BEA

; ----------------------------------------------------------------------------
L8BEB:  pla                                     ; 8BEB
        sta     $0601,x                         ; 8BEC
L8BEF:  lda     #$00                            ; 8BEF
        rts                                     ; 8BF1

; ----------------------------------------------------------------------------
        lda     $0601,x                         ; 8BF2
        and     #$10                            ; 8BF5
        beq     L8C1A                           ; 8BF7
        lda     $0605,x                         ; 8BF9
        and     #$0F                            ; 8BFC
        sta     $3B                             ; 8BFE
        lda     $0602,x                         ; 8C00
        sec                                     ; 8C03
        sbc     #$08                            ; 8C04
        bcc     L8C1A                           ; 8C06
        and     #$F0                            ; 8C08
        ora     $3B                             ; 8C0A
        jsr     LE088                           ; 8C0C
        cmp     #$0C                            ; 8C0F
        bcc     L8C1A                           ; 8C11
        asl     $0600,x                         ; 8C13
        sec                                     ; 8C16
        ror     $0600,x                         ; 8C17
L8C1A:  lda     $95                             ; 8C1A
        rts                                     ; 8C1C

; ----------------------------------------------------------------------------
        lda     $95                             ; 8C1D
        cmp     #$0C                            ; 8C1F
        bcc     L8C27                           ; 8C21
        lda     #$00                            ; 8C23
        sta     $95                             ; 8C25
L8C27:  lda     $0601,x                         ; 8C27
        and     #$30                            ; 8C2A
        beq     L8C36                           ; 8C2C
        php                                     ; 8C2E
        asl     $0600,x                         ; 8C2F
        plp                                     ; 8C32
        ror     $0600,x                         ; 8C33
L8C36:  jsr     LABF2                           ; 8C36
        cmp     #$01                            ; 8C39
        bne     L8C48                           ; 8C3B
        lda     #$0A                            ; 8C3D
        ldy     $29                             ; 8C3F
        beq     L8C45                           ; 8C41
        lda     #$00                            ; 8C43
L8C45:  sta     $34                             ; 8C45
L8C47:  rts                                     ; 8C47

; ----------------------------------------------------------------------------
L8C48:  ldy     #$00                            ; 8C48
        sty     $34                             ; 8C4A
        sec                                     ; 8C4C
        sbc     #$03                            ; 8C4D
        bcc     L8C47                           ; 8C4F
        cmp     #$05                            ; 8C51
        bcs     L8C47                           ; 8C53
        ldy     $29                             ; 8C55
        bne     L8C47                           ; 8C57
        jsr     LE97D                           ; 8C59
        ror     $AC                             ; 8C5C
        ldy     #$AC                            ; 8C5E
        cmp     $CDAC                           ; 8C60
        ldy     $ACCD                           ; 8C63
        lda     $32                             ; 8C66
        beq     L8C70                           ; 8C68
        lda     #$06                            ; 8C6A
        sta     $95                             ; 8C6C
        bne     L8CCD                           ; 8C6E
L8C70:  lda     #$3C                            ; 8C70
        sta     $0700,x                         ; 8C72
        lda     #$05                            ; 8C75
        sta     $0701,x                         ; 8C77
        lda     #$04                            ; 8C7A
        jsr     LF0BE                           ; 8C7C
        lda     $0707,x                         ; 8C7F
        ora     #$10                            ; 8C82
        sta     $0707,x                         ; 8C84
        lda     #$07                            ; 8C87
L8C89:  jsr     LE992                           ; 8C89
        jsr     LE0A4                           ; 8C8C
        jsr     L96F4                           ; 8C8F
        ldy     #$04                            ; 8C92
        lda     #$F8                            ; 8C94
L8C96:  sta     $0200,y                         ; 8C96
        iny                                     ; 8C99
        iny                                     ; 8C9A
        iny                                     ; 8C9B
        iny                                     ; 8C9C
        bne     L8C96                           ; 8C9D
        rts                                     ; 8C9F

; ----------------------------------------------------------------------------
        lda     $92                             ; 8CA0
        cmp     #$01                            ; 8CA2
        bne     L8CAB                           ; 8CA4
        lda     $0304                           ; 8CA6
        bne     L8CCC                           ; 8CA9
L8CAB:  lda     $81                             ; 8CAB
        beq     L8CB8                           ; 8CAD
        sec                                     ; 8CAF
        sbc     #$02                            ; 8CB0
        bcs     L8CB6                           ; 8CB2
        lda     #$00                            ; 8CB4
L8CB6:  sta     $81                             ; 8CB6
L8CB8:  lda     #$0A                            ; 8CB8
        jsr     LE992                           ; 8CBA
        jsr     LEAB9                           ; 8CBD
        lda     #$03                            ; 8CC0
        sta     $20                             ; 8CC2
        lda     $0707,x                         ; 8CC4
        ora     #$80                            ; 8CC7
        sta     $0707,x                         ; 8CC9
L8CCC:  rts                                     ; 8CCC

; ----------------------------------------------------------------------------
L8CCD:  lda     $BF                             ; 8CCD
        cmp     #$47                            ; 8CCF
        bne     L8CDB                           ; 8CD1
        lda     $82                             ; 8CD3
        beq     L8CDB                           ; 8CD5
        lda     #$08                            ; 8CD7
        bne     L8CE0                           ; 8CD9
L8CDB:  lda     $95                             ; 8CDB
        clc                                     ; 8CDD
        adc     #$01                            ; 8CDE
L8CE0:  jsr     LF0BE                           ; 8CE0
        lda     #$05                            ; 8CE3
        sta     $0600,x                         ; 8CE5
        lda     #$C8                            ; 8CE8
        sta     $0700,x                         ; 8CEA
        lda     #$08                            ; 8CED
        bne     L8C89                           ; 8CEF
        lda     $95                             ; 8CF1
        cmp     #$05                            ; 8CF3
        bcs     L8D08                           ; 8CF5
        ldy     $29                             ; 8CF7
        bne     L8D08                           ; 8CF9
        jsr     LE97D                           ; 8CFB
        php                                     ; 8CFE
        lda     $AD09                           ; 8CFF
        php                                     ; 8D02
        lda     $AD08                           ; 8D03
        php                                     ; 8D06
        .byte   $AD                             ; 8D07
L8D08:  rts                                     ; 8D08

; ----------------------------------------------------------------------------
        lda     $C0                             ; 8D09
        and     #$F0                            ; 8D0B
        beq     L8D1D                           ; 8D0D
        lda     $7F                             ; 8D0F
        and     #$0F                            ; 8D11
        bne     L8D1D                           ; 8D13
        lda     $34                             ; 8D15
        cmp     #$10                            ; 8D17
        bcs     L8D1D                           ; 8D19
        inc     $34                             ; 8D1B
L8D1D:  rts                                     ; 8D1D

; ----------------------------------------------------------------------------
        lda     $0707                           ; 8D1E
        and     #$40                            ; 8D21
        bne     L8D33                           ; 8D23
        lda     $95                             ; 8D25
        cmp     #$03                            ; 8D27
        bcc     L8D65                           ; 8D29
        cmp     #$08                            ; 8D2B
        beq     L8DAC                           ; 8D2D
        cmp     #$09                            ; 8D2F
        beq     L8DAC                           ; 8D31
L8D33:  rts                                     ; 8D33

; ----------------------------------------------------------------------------
L8D34:  bit     $BF                             ; 8D34
        lda     $B2                             ; 8D36
        bvs     L8DA8                           ; 8D38
        pha                                     ; 8D3A
        jsr     LE89D                           ; 8D3B
        jsr     LE891                           ; 8D3E
        pla                                     ; 8D41
        jsr     LE03F                           ; 8D42
        lda     $11                             ; 8D45
        and     #$18                            ; 8D47
        beq     L8D4E                           ; 8D49
        jsr     LF785                           ; 8D4B
L8D4E:  lda     #$00                            ; 8D4E
        sta     $6D                             ; 8D50
        lda     $03FC                           ; 8D52
        beq     L8D5A                           ; 8D55
        jsr     LEAB5                           ; 8D57
L8D5A:  bit     $BF                             ; 8D5A
        bvs     L8D33                           ; 8D5C
        ldx     #$00                            ; 8D5E
        lda     #$00                            ; 8D60
        jmp     LAE21                           ; 8D62

; ----------------------------------------------------------------------------
L8D65:  lda     $0601                           ; 8D65
        sta     L0000                           ; 8D68
        lda     #$0F                            ; 8D6A
        ldx     #$0F                            ; 8D6C
        ldy     #$F1                            ; 8D6E
        asl     L0000                           ; 8D70
        bcs     L8D8A                           ; 8D72
        ldx     #$00                            ; 8D74
        ldy     #$0F                            ; 8D76
        asl     L0000                           ; 8D78
        bcs     L8D8A                           ; 8D7A
        lda     #$F0                            ; 8D7C
        ldx     #$B0                            ; 8D7E
        ldy     #$70                            ; 8D80
        asl     L0000                           ; 8D82
        bcs     L8D8A                           ; 8D84
        ldx     #$10                            ; 8D86
        ldy     #$90                            ; 8D88
L8D8A:  stx     L0000                           ; 8D8A
        and     $0605                           ; 8D8C
        cmp     L0000                           ; 8D8F
        beq     L8D94                           ; 8D91
        rts                                     ; 8D93

; ----------------------------------------------------------------------------
L8D94:  sty     L0000                           ; 8D94
        ldy     #$FF                            ; 8D96
        lda     $0601                           ; 8D98
L8D9B:  iny                                     ; 8D9B
        asl     a                               ; 8D9C
        bcc     L8D9B                           ; 8D9D
        lda     $B4,y                           ; 8D9F
        cmp     #$FE                            ; 8DA2
        beq     L8D34                           ; 8DA4
        bcs     L8DAB                           ; 8DA6
L8DA8:  jsr     LAE4E                           ; 8DA8
L8DAB:  rts                                     ; 8DAB

; ----------------------------------------------------------------------------
L8DAC:  lda     #$00                            ; 8DAC
        sta     $AC                             ; 8DAE
        sta     $6D                             ; 8DB0
        lda     #$FF                            ; 8DB2
        jsr     LE992                           ; 8DB4
        lda     #$05                            ; 8DB7
        sta     $1A                             ; 8DB9
        lda     $95                             ; 8DBB
        cmp     #$09                            ; 8DBD
        bne     L8DD7                           ; 8DBF
        lda     #$19                            ; 8DC1
        jsr     LE992                           ; 8DC3
        lda     #$01                            ; 8DC6
        sta     $1A                             ; 8DC8
        jsr     LF067                           ; 8DCA
        jsr     LF067                           ; 8DCD
        jsr     LF067                           ; 8DD0
        lda     #$12                            ; 8DD3
        bne     L8DD9                           ; 8DD5
L8DD7:  lda     #$01                            ; 8DD7
L8DD9:  sta     $2F                             ; 8DD9
        jsr     LF067                           ; 8DDB
        lda     $1A                             ; 8DDE
        cmp     #$05                            ; 8DE0
        bne     L8DF2                           ; 8DE2
        lda     $BF                             ; 8DE4
        lsr     a                               ; 8DE6
        lsr     a                               ; 8DE7
        lsr     a                               ; 8DE8
        lda     #$00                            ; 8DE9
        bcs     L8DEF                           ; 8DEB
        lda     #$61                            ; 8DED
L8DEF:  jsr     LE992                           ; 8DEF
L8DF2:  jsr     LF0B5                           ; 8DF2
        lda     $2F                             ; 8DF5
        bne     L8DF2                           ; 8DF7
        dec     $1A                             ; 8DF9
        bne     L8DD7                           ; 8DFB
        jsr     LE5AA                           ; 8DFD
        bit     $BF                             ; 8E00
        lda     $B2                             ; 8E02
        bvs     L8E0B                           ; 8E04
        lda     $B2                             ; 8E06
        jmp     LAD3A                           ; 8E08

; ----------------------------------------------------------------------------
L8E0B:  sta     $AB                             ; 8E0B
        lda     #$00                            ; 8E0D
        sta     $95                             ; 8E0F
        jsr     LB185                           ; 8E11
        lda     $B9                             ; 8E14
        ldx     #$00                            ; 8E16
        jsr     LE086                           ; 8E18
        jsr     LAEBD                           ; 8E1B
        jmp     LAEB8                           ; 8E1E

; ----------------------------------------------------------------------------
        jsr     LE086                           ; 8E21
        jsr     LB185                           ; 8E24
        ldx     #$00                            ; 8E27
        lda     $0605                           ; 8E29
        bne     L8E36                           ; 8E2C
        lda     $B9                             ; 8E2E
        jsr     LE086                           ; 8E30
        lda     $0605                           ; 8E33
L8E36:  jsr     LE088                           ; 8E36
        stx     $95                             ; 8E39
        asl     $0600                           ; 8E3B
        cmp     #$0C                            ; 8E3E
        php                                     ; 8E40
        ror     $0600                           ; 8E41
        asl     $0608                           ; 8E44
        plp                                     ; 8E47
        ror     $0608                           ; 8E48
        jmp     LAEBD                           ; 8E4B

; ----------------------------------------------------------------------------
        ldx     #$00                            ; 8E4E
        pha                                     ; 8E50
        lda     $AB                             ; 8E51
        sta     $94                             ; 8E53
        pla                                     ; 8E55
        sta     $AB                             ; 8E56
        clc                                     ; 8E58
        lda     $0605                           ; 8E59
        adc     L0000                           ; 8E5C
        sta     $0605                           ; 8E5E
        lda     $B2                             ; 8E61
        cmp     #$FF                            ; 8E63
        bne     L8E96                           ; 8E65
        lda     #$00                            ; 8E67
        ldy     $72                             ; 8E69
        cpy     #$06                            ; 8E6B
        beq     L8E77                           ; 8E6D
        clc                                     ; 8E6F
        .byte   $AD                             ; 8E70
L8E71:  .byte   $F4                             ; 8E71
        .byte   $03                             ; 8E72
        adc     $03F5                           ; 8E73
        lsr     a                               ; 8E76
L8E77:  tay                                     ; 8E77
        lda     $03F0                           ; 8E78
        inc     $03F0                           ; 8E7B
        and     #$07                            ; 8E7E
        tax                                     ; 8E80
        lda     $AE9A,y                         ; 8E81
L8E84:  rol     a                               ; 8E84
        dex                                     ; 8E85
        bpl     L8E84                           ; 8E86
        bcc     L8E96                           ; 8E88
        jsr     LE891                           ; 8E8A
        jsr     LE06D                           ; 8E8D
        jsr     LF785                           ; 8E90
        jsr     LE5AA                           ; 8E93
L8E96:  ldx     #$00                            ; 8E96
        beq     L8EB2                           ; 8E98
        ora     ($01,x)                         ; 8E9A
        brk                                     ; 8E9C
        ora     ($11,x)                         ; 8E9D
        ora     $11,x                           ; 8E9F
        ora     $15,x                           ; 8EA1
        ora     ($15),y                         ; 8EA3
        ora     ($5C),y                         ; 8EA5
        eor     $CC,x                           ; 8EA7
        tax                                     ; 8EA9
        beq     L8E71                           ; 8EAA
        lda     $C5                             ; 8EAC
        cmp     $AC75                           ; 8EAE
        .byte   $AE                             ; 8EB1
L8EB2:  lda     $0605                           ; 8EB2
        jsr     LAE21                           ; 8EB5
        lda     #$00                            ; 8EB8
        jmp     LE898                           ; 8EBA

; ----------------------------------------------------------------------------
        lda     $BF                             ; 8EBD
        and     #$40                            ; 8EBF
        bne     L8EE3                           ; 8EC1
        lda     $B2                             ; 8EC3
        and     #$E0                            ; 8EC5
        bne     L8EE3                           ; 8EC7
        lda     $B2                             ; 8EC9
        cmp     #$01                            ; 8ECB
        bcc     L8EE3                           ; 8ECD
        ldx     #$00                            ; 8ECF
        lda     $B9                             ; 8ED1
        jsr     LE086                           ; 8ED3
        lda     #$01                            ; 8ED6
        jsr     LF0BE                           ; 8ED8
        lda     $0707,x                         ; 8EDB
        and     #$03                            ; 8EDE
        sta     $0707,x                         ; 8EE0
L8EE3:  lda     #$10                            ; 8EE3
        sta     L0000                           ; 8EE5
        lda     $0602,x                         ; 8EE7
        cmp     #$A0                            ; 8EEA
        bcs     L8F11                           ; 8EEC
        asl     L0000                           ; 8EEE
        cmp     #$20                            ; 8EF0
        bcc     L8F11                           ; 8EF2
        asl     L0000                           ; 8EF4
        lda     $0603,x                         ; 8EF6
        cmp     #$E0                            ; 8EF9
        bcs     L8F11                           ; 8EFB
        asl     L0000                           ; 8EFD
        cmp     #$20                            ; 8EFF
        bcc     L8F11                           ; 8F01
        lda     #$20                            ; 8F03
        sta     L0000                           ; 8F05
        lda     $0601,x                         ; 8F07
        and     #$0F                            ; 8F0A
        ora     L0000                           ; 8F0C
        sta     $0601,x                         ; 8F0E
L8F11:  lda     $BF                             ; 8F11
        and     #$10                            ; 8F13
        beq     L8F30                           ; 8F15
        lda     L0000                           ; 8F17
        and     #$00                            ; 8F19
        ora     #$08                            ; 8F1B
        sta     $0601,x                         ; 8F1D
        lda     $0603,x                         ; 8F20
        asl     a                               ; 8F23
        lda     #$80                            ; 8F24
        bcc     L8F2A                           ; 8F26
        lda     #$40                            ; 8F28
L8F2A:  ora     $0601,x                         ; 8F2A
        sta     $0601,x                         ; 8F2D
L8F30:  lda     #$00                            ; 8F30
        sta     $23                             ; 8F32
        sta     $33                             ; 8F34
        sta     $030A                           ; 8F36
        sta     $030B                           ; 8F39
        sta     $031A                           ; 8F3C
        sta     $0332                           ; 8F3F
        sta     $0334                           ; 8F42
        sta     $0702                           ; 8F45
        jsr     LE0A4                           ; 8F48
        lda     $0602                           ; 8F4B
        sta     $060A                           ; 8F4E
        lda     $0603                           ; 8F51
        sta     $060B                           ; 8F54
        bit     $BF                             ; 8F57
        bvs     L8F73                           ; 8F59
        lda     $B2                             ; 8F5B
        and     #$E0                            ; 8F5D
        cmp     #$20                            ; 8F5F
        bne     L8F73                           ; 8F61
        lda     $B2                             ; 8F63
        and     #$0F                            ; 8F65
        sta     $19                             ; 8F67
        beq     L8F71                           ; 8F69
        lda     #$00                            ; 8F6B
        sta     $6C                             ; 8F6D
        sta     $6D                             ; 8F6F
L8F71:  sta     $1A                             ; 8F71
L8F73:  rts                                     ; 8F73

; ----------------------------------------------------------------------------
        lda     $22                             ; 8F74
        bne     L8F9D                           ; 8F76
        jsr     LA92C                           ; 8F78
        bcs     L8F86                           ; 8F7B
        cmp     #$03                            ; 8F7D
        bcc     L8F9E                           ; 8F7F
        lda     $0707,x                         ; 8F81
        bmi     L8F9E                           ; 8F84
L8F86:  inc     $0703,x                         ; 8F86
        lda     $0703,x                         ; 8F89
        and     #$0F                            ; 8F8C
        sta     $0703,x                         ; 8F8E
        tay                                     ; 8F91
        lda     $0601,x                         ; 8F92
        and     #$0F                            ; 8F95
        ora     $B036,y                         ; 8F97
        sta     $0601,x                         ; 8F9A
L8F9D:  rts                                     ; 8F9D

; ----------------------------------------------------------------------------
L8F9E:  lda     $0703,x                         ; 8F9E
        bmi     L8FAE                           ; 8FA1
        lda     $0703,x                         ; 8FA3
        ora     #$80                            ; 8FA6
        sta     $0703,x                         ; 8FA8
        jsr     LE0A4                           ; 8FAB
L8FAE:  lda     $9B,y                           ; 8FAE
        bne     L8FB6                           ; 8FB1
        jsr     LE0A2                           ; 8FB3
L8FB6:  lda     $96,y                           ; 8FB6
        jsr     LAA1C                           ; 8FB9
        bcs     L8F9D                           ; 8FBC
        lda     $0704,x                         ; 8FBE
        beq     L8FC6                           ; 8FC1
        dec     $0704,x                         ; 8FC3
L8FC6:  lda     $0704,x                         ; 8FC6
        asl     a                               ; 8FC9
        bne     L9019                           ; 8FCA
        bcc     L8FD8                           ; 8FCC
        lda     $A5                             ; 8FCE
        and     #$0F                            ; 8FD0
        sta     $0704,x                         ; 8FD2
        jmp     LAF86                           ; 8FD5

; ----------------------------------------------------------------------------
L8FD8:  lda     $A5                             ; 8FD8
        lsr     a                               ; 8FDA
        lsr     a                               ; 8FDB
        lsr     a                               ; 8FDC
        lsr     a                               ; 8FDD
        ora     #$80                            ; 8FDE
        sta     $0704,x                         ; 8FE0
L8FE3:  lda     $0703,x                         ; 8FE3
        and     #$0F                            ; 8FE6
        tay                                     ; 8FE8
        lda     $09                             ; 8FE9
        cmp     #$08                            ; 8FEB
        bcs     L8FF6                           ; 8FED
        lda     $08                             ; 8FEF
        and     #$30                            ; 8FF1
        jmp     LB000                           ; 8FF3

; ----------------------------------------------------------------------------
L8FF6:  lda     $0A                             ; 8FF6
        cmp     #$08                            ; 8FF8
        lda     $08                             ; 8FFA
        bcs     L9000                           ; 8FFC
        and     #$C0                            ; 8FFE
L9000:  sta     L0000                           ; 9000
        eor     $B036,y                         ; 9002
        bne     L9008                           ; 9005
        rts                                     ; 9007

; ----------------------------------------------------------------------------
L9008:  lda     $B036,y                         ; 9008
        eor     #$FF                            ; 900B
        and     $08                             ; 900D
        lsr     a                               ; 900F
        lsr     a                               ; 9010
        lsr     a                               ; 9011
        lsr     a                               ; 9012
        sta     $0703,x                         ; 9013
        jmp     LAF89                           ; 9016

; ----------------------------------------------------------------------------
L9019:  lda     $23                             ; 9019
        beq     L9026                           ; 901B
        lda     $08                             ; 901D
        eor     #$F0                            ; 901F
        sta     $08                             ; 9021
        jmp     LAFE3                           ; 9023

; ----------------------------------------------------------------------------
L9026:  lda     $0704,x                         ; 9026
        bmi     L8FE3                           ; 9029
        lda     $0703,x                         ; 902B
        adc     $E0                             ; 902E
        sta     $0703,x                         ; 9030
        jmp     LAF89                           ; 9033

; ----------------------------------------------------------------------------
        rti                                     ; 9036

; ----------------------------------------------------------------------------
        bpl     L9059                           ; 9037
        .byte   $80                             ; 9039
        rti                                     ; 903A

; ----------------------------------------------------------------------------
        bpl     L905D                           ; 903B
        rti                                     ; 903D

; ----------------------------------------------------------------------------
        .byte   $80                             ; 903E
        bpl     L9061                           ; 903F
        .byte   $80                             ; 9041
        rti                                     ; 9042

; ----------------------------------------------------------------------------
        bpl     L9065                           ; 9043
        .byte   $80                             ; 9045
        rts                                     ; 9046

; ----------------------------------------------------------------------------
        lda     $09                             ; 9047
        cmp     $0A                             ; 9049
        lda     #$30                            ; 904B
        bcc     L9051                           ; 904D
        lda     #$C0                            ; 904F
L9051:  sta     $0703,x                         ; 9051
        and     $08                             ; 9054
        sta     L0000                           ; 9056
        .byte   $BD                             ; 9058
L9059:  ora     ($06,x)                         ; 9059
        and     #$0F                            ; 905B
L905D:  ora     L0000                           ; 905D
        .byte   $9D                             ; 905F
        .byte   $01                             ; 9060
L9061:  asl     $9D                             ; 9061
        .byte   $04                             ; 9063
        .byte   $07                             ; 9064
L9065:  and     #$30                            ; 9065
        beq     L907D                           ; 9067
        lda     #$30                            ; 9069
        sta     L0000                           ; 906B
        lda     $0A                             ; 906D
        sta     $01                             ; 906F
        lda     $09                             ; 9071
        cmp     #$08                            ; 9073
        bcc     L9091                           ; 9075
        lda     #$C0                            ; 9077
        sta     L0000                           ; 9079
        bne     L909B                           ; 907B
L907D:  lda     #$C0                            ; 907D
        sta     L0000                           ; 907F
        lda     $09                             ; 9081
        sta     $01                             ; 9083
        lda     $0A                             ; 9085
        cmp     #$08                            ; 9087
        bcc     L9091                           ; 9089
        lda     #$30                            ; 908B
        sta     L0000                           ; 908D
        bne     L909B                           ; 908F
L9091:  lda     $01                             ; 9091
        cmp     #$40                            ; 9093
        bcc     L90A0                           ; 9095
        cmp     #$50                            ; 9097
        bcc     L90A0                           ; 9099
L909B:  lda     $08                             ; 909B
        jmp     LB0A4                           ; 909D

; ----------------------------------------------------------------------------
L90A0:  lda     $08                             ; 90A0
        eor     #$F0                            ; 90A2
        and     L0000                           ; 90A4
        sta     $03                             ; 90A6
        lda     $08                             ; 90A8
        and     $0703,x                         ; 90AA
        sta     L0000                           ; 90AD
        and     $0601,x                         ; 90AF
        bne     L90C4                           ; 90B2
        lda     $0601,x                         ; 90B4
        and     #$0F                            ; 90B7
        ora     L0000                           ; 90B9
        sta     $0601,x                         ; 90BB
        sta     $0704,x                         ; 90BE
        jsr     LE0A4                           ; 90C1
L90C4:  lda     $03                             ; 90C4
        sta     $0601,x                         ; 90C6
        jsr     LA92C                           ; 90C9
        bcs     L90EB                           ; 90CC
        cmp     #$03                            ; 90CE
        bcc     L90D7                           ; 90D0
        lda     $0707,x                         ; 90D2
        bpl     L90EB                           ; 90D5
L90D7:  lda     $96,y                           ; 90D7
        jsr     LAA1C                           ; 90DA
        lda     $0704,x                         ; 90DD
        sta     $0601,x                         ; 90E0
        lda     $9B,y                           ; 90E3
        bne     L90EB                           ; 90E6
        jsr     LE0A2                           ; 90E8
L90EB:  lda     $0704,x                         ; 90EB
        sta     $0601,x                         ; 90EE
        rts                                     ; 90F1

; ----------------------------------------------------------------------------
        lda     $22                             ; 90F2
        bne     L912C                           ; 90F4
        jsr     LA92C                           ; 90F6
        bcs     L9104                           ; 90F9
        cmp     #$03                            ; 90FB
        bcc     L9117                           ; 90FD
        lda     $0707,x                         ; 90FF
        bmi     L9117                           ; 9102
L9104:  lda     $7F                             ; 9104
L9106:  and     #$03                            ; 9106
        tay                                     ; 9108
        lda     $0601,x                         ; 9109
        and     #$0F                            ; 910C
        ora     $B12D,y                         ; 910E
        sta     $0601,x                         ; 9111
        jmp     LE0A4                           ; 9114

; ----------------------------------------------------------------------------
L9117:  lda     $9B,y                           ; 9117
        bne     L911F                           ; 911A
        jsr     LE0A2                           ; 911C
L911F:  lda     $96,y                           ; 911F
        jsr     LAA1C                           ; 9122
        beq     L912C                           ; 9125
        lda     $E7                             ; 9127
        lsr     a                               ; 9129
        bcc     L9106                           ; 912A
L912C:  rts                                     ; 912C

; ----------------------------------------------------------------------------
        rti                                     ; 912D

; ----------------------------------------------------------------------------
        jsr     L1080                           ; 912E
        lda     $0703,x                         ; 9131
        and     #$87                            ; 9134
        sta     $0703,x                         ; 9136
        and     #$07                            ; 9139
        tay                                     ; 913B
        lda     $B19C,y                         ; 913C
        sta     L0000                           ; 913F
        inc     $0703,x                         ; 9141
        lda     $32                             ; 9144
        beq     L915C                           ; 9146
        lda     $09                             ; 9148
        cmp     $0A                             ; 914A
        bcc     L9154                           ; 914C
        lda     $08                             ; 914E
        and     #$C0                            ; 9150
        bne     L915A                           ; 9152
L9154:  lda     $08                             ; 9154
        and     #$30                            ; 9156
        beq     L915C                           ; 9158
L915A:  sta     L0000                           ; 915A
L915C:  lda     $0601,x                         ; 915C
        and     #$0F                            ; 915F
        ora     L0000                           ; 9161
        sta     $0601,x                         ; 9163
        rts                                     ; 9166

; ----------------------------------------------------------------------------
        bcs     L917C                           ; 9167
        cmp     #$03                            ; 9169
        bcs     L917C                           ; 916B
        lda     $0707,x                         ; 916D
        asl     a                               ; 9170
        bcs     L917C                           ; 9171
        lda     $0703,x                         ; 9173
        and     #$07                            ; 9176
        sta     $0703,x                         ; 9178
        rts                                     ; 917B

; ----------------------------------------------------------------------------
L917C:  lda     $0703,x                         ; 917C
        ora     #$80                            ; 917F
        sta     $0703,x                         ; 9181
        rts                                     ; 9184

; ----------------------------------------------------------------------------
        jsr     LE08C                           ; 9185
        jsr     LAF57                           ; 9188
        lda     $11                             ; 918B
        pha                                     ; 918D
        jsr     LE8B1                           ; 918E
        pla                                     ; 9191
        sta     $11                             ; 9192
        lda     $80                             ; 9194
        bne     L919B                           ; 9196
        jsr     LE5AA                           ; 9198
L919B:  rts                                     ; 919B

; ----------------------------------------------------------------------------
        .byte   $80                             ; 919C
        jsr     L2040                           ; 919D
        .byte   $80                             ; 91A0
        bpl     L91E3                           ; 91A1
        bpl     L91A5                           ; 91A3
L91A5:  .byte   $FF                             ; 91A5
        brk                                     ; 91A6
        brk                                     ; 91A7
        php                                     ; 91A8
        .byte   $03                             ; 91A9
        rts                                     ; 91AA

; ----------------------------------------------------------------------------
        .byte   $04                             ; 91AB
        brk                                     ; 91AC
        .byte   $FF                             ; 91AD
        brk                                     ; 91AE
        brk                                     ; 91AF
        .byte   $14                             ; 91B0
        .byte   $03                             ; 91B1
        and     ($04,x)                         ; 91B2
        brk                                     ; 91B4
        .byte   $FF                             ; 91B5
        brk                                     ; 91B6
        brk                                     ; 91B7
        brk                                     ; 91B8
        .byte   $FF                             ; 91B9
        brk                                     ; 91BA
        brk                                     ; 91BB
        .byte   $14                             ; 91BC
        .byte   $03                             ; 91BD
        .byte   $62                             ; 91BE
        php                                     ; 91BF
        brk                                     ; 91C0
        .byte   $FF                             ; 91C1
        brk                                     ; 91C2
        brk                                     ; 91C3
        brk                                     ; 91C4
        .byte   $FF                             ; 91C5
        brk                                     ; 91C6
        brk                                     ; 91C7
        brk                                     ; 91C8
        .byte   $FF                             ; 91C9
        brk                                     ; 91CA
        brk                                     ; 91CB
        brk                                     ; 91CC
        .byte   $FF                             ; 91CD
        brk                                     ; 91CE
        brk                                     ; 91CF
        php                                     ; 91D0
        .byte   $03                             ; 91D1
        .byte   $23                             ; 91D2
        .byte   $04                             ; 91D3
        brk                                     ; 91D4
        .byte   $FF                             ; 91D5
        brk                                     ; 91D6
        brk                                     ; 91D7
        brk                                     ; 91D8
        .byte   $FF                             ; 91D9
        brk                                     ; 91DA
        brk                                     ; 91DB
        brk                                     ; 91DC
        .byte   $FF                             ; 91DD
        brk                                     ; 91DE
        brk                                     ; 91DF
        .byte   $12                             ; 91E0
        .byte   $03                             ; 91E1
        ror     a                               ; 91E2
L91E3:  .byte   $04                             ; 91E3
        brk                                     ; 91E4
        .byte   $FF                             ; 91E5
        brk                                     ; 91E6
        brk                                     ; 91E7
        brk                                     ; 91E8
        .byte   $FF                             ; 91E9
        brk                                     ; 91EA
        brk                                     ; 91EB
        asl     a                               ; 91EC
        ora     $04                             ; 91ED
        .byte   $02                             ; 91EF
        .byte   $14                             ; 91F0
        asl     $85                             ; 91F1
        .byte   $03                             ; 91F3
        brk                                     ; 91F4
        .byte   $FF                             ; 91F5
        brk                                     ; 91F6
        brk                                     ; 91F7
        brk                                     ; 91F8
        .byte   $FF                             ; 91F9
        brk                                     ; 91FA
        brk                                     ; 91FB
        brk                                     ; 91FC
        .byte   $FF                             ; 91FD
        brk                                     ; 91FE
        brk                                     ; 91FF
        brk                                     ; 9200
        .byte   $FF                             ; 9201
        brk                                     ; 9202
        brk                                     ; 9203
        asl     $10                             ; 9204
        asl     $08                             ; 9206
        asl     $22                             ; 9208
        asl     $08                             ; 920A
        asl     $31                             ; 920C
        asl     $08                             ; 920E
        .byte   $07                             ; 9210
        .byte   $42                             ; 9211
        .byte   $07                             ; 9212
        .byte   $07                             ; 9213
        .byte   $07                             ; 9214
        .byte   $52                             ; 9215
        .byte   $07                             ; 9216
        .byte   $07                             ; 9217
        .byte   $07                             ; 9218
        adc     ($07,x)                         ; 9219
        .byte   $07                             ; 921B
        php                                     ; 921C
        adc     ($08),y                         ; 921D
        asl     $08                             ; 921F
        sta     ($08,x)                         ; 9221
        asl     $08                             ; 9223
        sta     ($08),y                         ; 9225
        asl     $09                             ; 9227
        lda     ($09,x)                         ; 9229
        asl     $09                             ; 922B
        lda     ($09),y                         ; 922D
        asl     $09                             ; 922F
        .byte   $C2                             ; 9231
        ora     #$06                            ; 9232
        brk                                     ; 9234
        .byte   $FF                             ; 9235
        brk                                     ; 9236
        brk                                     ; 9237
        asl     a                               ; 9238
        .byte   $03                             ; 9239
        .byte   $0B                             ; 923A
        .byte   $04                             ; 923B
        .byte   $14                             ; 923C
        .byte   $04                             ; 923D
        .byte   $0C                             ; 923E
        .byte   $04                             ; 923F
        jsr     L0D03                           ; 9240
        .byte   $04                             ; 9243
        .byte   $32                             ; 9244
        brk                                     ; 9245
        asl     a:$01                           ; 9246
        .byte   $FF                             ; 9249
        brk                                     ; 924A
        brk                                     ; 924B
        brk                                     ; 924C
        .byte   $FF                             ; 924D
        brk                                     ; 924E
        brk                                     ; 924F
        brk                                     ; 9250
        .byte   $FF                             ; 9251
        brk                                     ; 9252
        brk                                     ; 9253
        brk                                     ; 9254
        .byte   $FF                             ; 9255
        brk                                     ; 9256
        brk                                     ; 9257
        .byte   $04                             ; 9258
        .byte   $03                             ; 9259
        .byte   $6F                             ; 925A
        .byte   $02                             ; 925B
        .byte   $04                             ; 925C
        .byte   $03                             ; 925D
        rts                                     ; 925E

; ----------------------------------------------------------------------------
        .byte   $04                             ; 925F
        brk                                     ; 9260
        .byte   $FF                             ; 9261
        brk                                     ; 9262
        brk                                     ; 9263
        brk                                     ; 9264
        brk                                     ; 9265
        brk                                     ; 9266
        brk                                     ; 9267
        brk                                     ; 9268
        brk                                     ; 9269
        brk                                     ; 926A
        brk                                     ; 926B
        brk                                     ; 926C
        brk                                     ; 926D
        brk                                     ; 926E
        brk                                     ; 926F
        brk                                     ; 9270
        brk                                     ; 9271
        brk                                     ; 9272
        brk                                     ; 9273
        brk                                     ; 9274
        brk                                     ; 9275
        brk                                     ; 9276
        brk                                     ; 9277
        brk                                     ; 9278
        brk                                     ; 9279
        brk                                     ; 927A
        brk                                     ; 927B
        php                                     ; 927C
        php                                     ; 927D
        php                                     ; 927E
        php                                     ; 927F
        php                                     ; 9280
        php                                     ; 9281
        php                                     ; 9282
        php                                     ; 9283
        php                                     ; 9284
        php                                     ; 9285
        php                                     ; 9286
        php                                     ; 9287
        brk                                     ; 9288
        brk                                     ; 9289
        brk                                     ; 928A
        bpl     L928D                           ; 928B
L928D:  brk                                     ; 928D
        brk                                     ; 928E
        brk                                     ; 928F
        brk                                     ; 9290
        brk                                     ; 9291
        brk                                     ; 9292
        brk                                     ; 9293
        brk                                     ; 9294
        brk                                     ; 9295
        brk                                     ; 9296
        brk                                     ; 9297
        brk                                     ; 9298
        brk                                     ; 9299
        brk                                     ; 929A
        brk                                     ; 929B
        brk                                     ; 929C
        sed                                     ; 929D
        brk                                     ; 929E
        sed                                     ; 929F
        brk                                     ; 92A0
        brk                                     ; 92A1
        brk                                     ; 92A2
        brk                                     ; 92A3
        brk                                     ; 92A4
        cpx     #$00                            ; 92A5
        cpx     #$00                            ; 92A7
        cpx     #$00                            ; 92A9
        cpx     #$00                            ; 92AB
        brk                                     ; 92AD
        brk                                     ; 92AE
        brk                                     ; 92AF
        brk                                     ; 92B0
        brk                                     ; 92B1
        brk                                     ; 92B2
        brk                                     ; 92B3
        brk                                     ; 92B4
        brk                                     ; 92B5
        brk                                     ; 92B6
        brk                                     ; 92B7
        brk                                     ; 92B8
        brk                                     ; 92B9
        brk                                     ; 92BA
        brk                                     ; 92BB
        brk                                     ; 92BC
        rol     L0000,x                         ; 92BD
        rol     L0000,x                         ; 92BF
        brk                                     ; 92C1
        rol     L0000,x                         ; 92C2
        brk                                     ; 92C4
        brk                                     ; 92C5
        brk                                     ; 92C6
        rol     L0000,x                         ; 92C7
        brk                                     ; 92C9
        brk                                     ; 92CA
        rol     L0000,x                         ; 92CB
        brk                                     ; 92CD
        .byte   $72                             ; 92CE
        rol     L0000,x                         ; 92CF
        brk                                     ; 92D1
        brk                                     ; 92D2
        brk                                     ; 92D3
        rol     $36,x                           ; 92D4
        rol     $36,x                           ; 92D6
        rol     $36,x                           ; 92D8
        rol     $36,x                           ; 92DA
        rol     $36,x                           ; 92DC
        rol     $36,x                           ; 92DE
        brk                                     ; 92E0
        rol     $36,x                           ; 92E1
        rol     $36,x                           ; 92E3
        brk                                     ; 92E5
        brk                                     ; 92E6
        brk                                     ; 92E7
        brk                                     ; 92E8
        rol     $36,x                           ; 92E9
        brk                                     ; 92EB
        brk                                     ; 92EC
        brk                                     ; 92ED
        brk                                     ; 92EE
        brk                                     ; 92EF
        brk                                     ; 92F0
        bpl     L92F3                           ; 92F1
L92F3:  jsr     L0000                           ; 92F3
        ora     ($30,x)                         ; 92F6
        brk                                     ; 92F8
        brk                                     ; 92F9
        brk                                     ; 92FA
        rti                                     ; 92FB

; ----------------------------------------------------------------------------
        jsr     L0000                           ; 92FC
        brk                                     ; 92FF
        .byte   $34                             ; 9300
        brk                                     ; 9301
        brk                                     ; 9302
        php                                     ; 9303
        rti                                     ; 9304

; ----------------------------------------------------------------------------
        brk                                     ; 9305
        brk                                     ; 9306
        brk                                     ; 9307
        ora     (L0000,x)                       ; 9308
        bmi     L930C                           ; 930A
L930C:  .byte   $52                             ; 930C
        brk                                     ; 930D
        .byte   $23                             ; 930E
        ora     ($01,x)                         ; 930F
        ora     ($01,x)                         ; 9311
        ora     ($56,x)                         ; 9313
        ora     ($27),y                         ; 9315
        ora     ($02,x)                         ; 9317
        .byte   $04                             ; 9319
        php                                     ; 931A
        php                                     ; 931B
        inc     $239B,x                         ; 931C
        bpl     L9331                           ; 931F
        bpl     L9333                           ; 9321
        bpl     L9383                           ; 9323
        rol     $33                             ; 9325
        .byte   $02                             ; 9327
        .byte   $04                             ; 9328
        php                                     ; 9329
        .byte   $0C                             ; 932A
        asl     $2752                           ; 932B
        .byte   $BB                             ; 932E
        .byte   $14                             ; 932F
        .byte   $14                             ; 9330
L9331:  .byte   $14                             ; 9331
        .byte   $14                             ; 9332
L9333:  .byte   $14                             ; 9333
        .byte   $52                             ; 9334
        sty     $3B                             ; 9335
        php                                     ; 9337
        php                                     ; 9338
        php                                     ; 9339
        .byte   $0C                             ; 933A
        .byte   $0C                             ; 933B
        .byte   $53                             ; 933C
        .byte   $3B                             ; 933D
        ldx     #$0A                            ; 933E
        .byte   $14                             ; 9340
        asl     $4628,x                         ; 9341
        .byte   $52                             ; 9344
        asl     $21                             ; 9345
        .byte   $02                             ; 9347
        .byte   $04                             ; 9348
        php                                     ; 9349
        .byte   $0C                             ; 934A
        bpl     L939F                           ; 934B
        .byte   $3B                             ; 934D
        and     ($14,x)                         ; 934E
        asl     $503C,x                         ; 9350
        .byte   $64                             ; 9353
        lsr     $2369,x                         ; 9354
        .byte   $64                             ; 9357
        .byte   $64                             ; 9358
        .byte   $64                             ; 9359
        sty     $528C                           ; 935A
        .byte   $3A                             ; 935D
        .byte   $A3                             ; 935E
        asl     a                               ; 935F
        asl     a                               ; 9360
        asl     a                               ; 9361
        .byte   $0C                             ; 9362
        .byte   $0C                             ; 9363
        lsr     $11,x                           ; 9364
        .byte   $27                             ; 9366
        .byte   $02                             ; 9367
        .byte   $04                             ; 9368
        php                                     ; 9369
        .byte   $0C                             ; 936A
        .byte   $0C                             ; 936B
        .byte   $53                             ; 936C
        ora     ($A3),y                         ; 936D
        ora     ($02,x)                         ; 936F
        .byte   $04                             ; 9371
        php                                     ; 9372
        php                                     ; 9373
        lsr     $A3A1,x                         ; 9374
        ora     ($01,x)                         ; 9377
        ora     ($01,x)                         ; 9379
        ora     ($1F,x)                         ; 937B
        .byte   $82                             ; 937D
        and     $0202,y                         ; 937E
        .byte   $02                             ; 9381
        .byte   $02                             ; 9382
L9383:  .byte   $02                             ; 9383
        .byte   $1F                             ; 9384
        sty     $39                             ; 9385
        .byte   $02                             ; 9387
        .byte   $02                             ; 9388
        .byte   $02                             ; 9389
        .byte   $02                             ; 938A
        .byte   $02                             ; 938B
        asl     L8B79,x                         ; 938C
        .byte   $3C                             ; 938F
        sei                                     ; 9390
        ldy     $FA,x                           ; 9391
        .byte   $FA                             ; 9393
        lsr     $2334                           ; 9394
        .byte   $04                             ; 9397
        .byte   $04                             ; 9398
        php                                     ; 9399
        .byte   $0C                             ; 939A
        .byte   $0C                             ; 939B
        inc     $AB56,x                         ; 939C
L939F:  .byte   $14                             ; 939F
        plp                                     ; 93A0
        bvc     L941B                           ; 93A1
        ldy     #$8E                            ; 93A3
        .byte   $7B                             ; 93A5
        tax                                     ; 93A6
        plp                                     ; 93A7
        plp                                     ; 93A8
        plp                                     ; 93A9
        plp                                     ; 93AA
        .byte   $3C                             ; 93AB
        lsr     $6317,x                         ; 93AC
        .byte   $02                             ; 93AF
        .byte   $02                             ; 93B0
        asl     a                               ; 93B1
        asl     a                               ; 93B2
        .byte   $14                             ; 93B3
        lsr     $6218,x                         ; 93B4
        .byte   $02                             ; 93B7
        .byte   $04                             ; 93B8
        .byte   $04                             ; 93B9
        .byte   $0F                             ; 93BA
        ora     $199E,y                         ; 93BB
        adc     ($02,x)                         ; 93BE
        .byte   $04                             ; 93C0
        asl     a                               ; 93C1
        asl     a                               ; 93C2
        .byte   $14                             ; 93C3
        stx     $601A                           ; 93C4
        .byte   $02                             ; 93C7
        .byte   $04                             ; 93C8
        php                                     ; 93C9
        .byte   $0F                             ; 93CA
        ora     $5256,y                         ; 93CB
        .byte   $0F                             ; 93CE
        ora     $05                             ; 93CF
        .byte   $3C                             ; 93D1
        .byte   $3C                             ; 93D2
        sei                                     ; 93D3
        lsr     $52,x                           ; 93D4
        .byte   $0F                             ; 93D6
        ora     $05                             ; 93D7
        .byte   $3C                             ; 93D9
        .byte   $3C                             ; 93DA
        sei                                     ; 93DB
        lsr     $52,x                           ; 93DC
        .byte   $0F                             ; 93DE
        ora     $05                             ; 93DF
        .byte   $3C                             ; 93E1
        .byte   $3C                             ; 93E2
        sei                                     ; 93E3
        .byte   $5A                             ; 93E4
        .byte   $63                             ; 93E5
        .byte   $0F                             ; 93E6
        .byte   $14                             ; 93E7
        .byte   $14                             ; 93E8
        .byte   $14                             ; 93E9
        .byte   $64                             ; 93EA
        ldy     #$5A                            ; 93EB
        .byte   $63                             ; 93ED
        .byte   $0F                             ; 93EE
        .byte   $14                             ; 93EF
        .byte   $14                             ; 93F0
        .byte   $14                             ; 93F1
        .byte   $64                             ; 93F2
        ldy     #$5A                            ; 93F3
        .byte   $63                             ; 93F5
        .byte   $0F                             ; 93F6
        .byte   $14                             ; 93F7
        .byte   $14                             ; 93F8
        .byte   $14                             ; 93F9
        .byte   $64                             ; 93FA
        ldy     #$9E                            ; 93FB
        .byte   $74                             ; 93FD
        .byte   $0F                             ; 93FE
        plp                                     ; 93FF
        plp                                     ; 9400
        .byte   $3C                             ; 9401
        .byte   $3C                             ; 9402
        sei                                     ; 9403
        .byte   $9E                             ; 9404
        .byte   $74                             ; 9405
        .byte   $0F                             ; 9406
        plp                                     ; 9407
        plp                                     ; 9408
        .byte   $3C                             ; 9409
        .byte   $3C                             ; 940A
        sei                                     ; 940B
        .byte   $9E                             ; 940C
        .byte   $74                             ; 940D
        .byte   $0F                             ; 940E
        plp                                     ; 940F
        plp                                     ; 9410
        .byte   $3C                             ; 9411
        .byte   $3C                             ; 9412
        sei                                     ; 9413
        stx     $0F75                           ; 9414
        .byte   $3C                             ; 9417
        .byte   $3C                             ; 9418
        .byte   $3C                             ; 9419
        .byte   $64                             ; 941A
L941B:  ldy     #$8E                            ; 941B
        adc     $0F,x                           ; 941D
        .byte   $3C                             ; 941F
        .byte   $3C                             ; 9420
        .byte   $3C                             ; 9421
        .byte   $64                             ; 9422
        ldy     #$8E                            ; 9423
        adc     $0F,x                           ; 9425
        .byte   $3C                             ; 9427
        .byte   $3C                             ; 9428
        .byte   $3C                             ; 9429
        .byte   $64                             ; 942A
        ldy     #$51                            ; 942B
        brk                                     ; 942D
        .byte   $E2                             ; 942E
        .byte   $04                             ; 942F
        .byte   $04                             ; 9430
        .byte   $04                             ; 9431
        .byte   $04                             ; 9432
        .byte   $04                             ; 9433
        and     (L0000,x)                       ; 9434
        .byte   $E2                             ; 9436
        .byte   $14                             ; 9437
        .byte   $14                             ; 9438
        .byte   $14                             ; 9439
        .byte   $14                             ; 943A
        .byte   $14                             ; 943B
        cmp     (L0000),y                       ; 943C
        .byte   $E2                             ; 943E
        .byte   $14                             ; 943F
        .byte   $14                             ; 9440
        .byte   $14                             ; 9441
        .byte   $14                             ; 9442
        .byte   $14                             ; 9443
        cmp     (L0000),y                       ; 9444
        .byte   $E2                             ; 9446
        sei                                     ; 9447
        sei                                     ; 9448
        sei                                     ; 9449
        sei                                     ; 944A
        sei                                     ; 944B
        ora     (L0000,x)                       ; 944C
        .byte   $E2                             ; 944E
        .byte   $FF                             ; 944F
        .byte   $FF                             ; 9450
        .byte   $FF                             ; 9451
        .byte   $FF                             ; 9452
        .byte   $FF                             ; 9453
        .byte   $53                             ; 9454
        brk                                     ; 9455
        .byte   $E2                             ; 9456
        .byte   $64                             ; 9457
        .byte   $64                             ; 9458
        .byte   $64                             ; 9459
        .byte   $64                             ; 945A
        .byte   $64                             ; 945B
        ora     (L0000,x)                       ; 945C
        .byte   $E2                             ; 945E
        .byte   $FF                             ; 945F
        .byte   $FF                             ; 9460
        .byte   $FF                             ; 9461
        .byte   $FF                             ; 9462
        .byte   $FF                             ; 9463
        brk                                     ; 9464
        brk                                     ; 9465
        brk                                     ; 9466
        brk                                     ; 9467
        brk                                     ; 9468
        brk                                     ; 9469
        brk                                     ; 946A
        brk                                     ; 946B
        brk                                     ; 946C
        brk                                     ; 946D
        brk                                     ; 946E
        brk                                     ; 946F
        brk                                     ; 9470
        brk                                     ; 9471
        brk                                     ; 9472
        brk                                     ; 9473
        .byte   $57                             ; 9474
        ora     ($A3),y                         ; 9475
        ora     ($02,x)                         ; 9477
        .byte   $04                             ; 9479
        php                                     ; 947A
        php                                     ; 947B
        lsr     $11,x                           ; 947C
        .byte   $27                             ; 947E
        ora     ($02,x)                         ; 947F
        .byte   $04                             ; 9481
        php                                     ; 9482
        php                                     ; 9483
        lsr     $A311,x                         ; 9484
        ora     ($01,x)                         ; 9487
        ora     ($01,x)                         ; 9489
        ora     (L0000,x)                       ; 948B
        .byte   $04                             ; 948D
        asl     $07                             ; 948E
        php                                     ; 9490
        ora     #$0A                            ; 9491
        .byte   $0C                             ; 9493
        asl     $1210                           ; 9494
        .byte   $14                             ; 9497
        brk                                     ; 9498
        brk                                     ; 9499
        .byte   $02                             ; 949A
        brk                                     ; 949B
        ora     L0000                           ; 949C
        asl     a                               ; 949E
        brk                                     ; 949F
        .byte   $14                             ; 94A0
        brk                                     ; 94A1
        asl     $2800,x                         ; 94A2
        brk                                     ; 94A5
        .byte   $32                             ; 94A6
        brk                                     ; 94A7
        .byte   $04                             ; 94A8
        brk                                     ; 94A9
        .byte   $0C                             ; 94AA
        brk                                     ; 94AB
        ora     (L0000,x)                       ; 94AC
        brk                                     ; 94AE
        brk                                     ; 94AF
        brk                                     ; 94B0
        brk                                     ; 94B1
        brk                                     ; 94B2
        brk                                     ; 94B3
        brk                                     ; 94B4
        ora     (L0000,x)                       ; 94B5
        ora     (L0000,x)                       ; 94B7
        ora     (L0000,x)                       ; 94B9
        ora     ($01,x)                         ; 94BB
        ora     ($01,x)                         ; 94BD
        ora     ($01,x)                         ; 94BF
        ora     ($01,x)                         ; 94C1
        ora     ($01,x)                         ; 94C3
        .byte   $02                             ; 94C5
        ora     ($02,x)                         ; 94C6
        ora     ($02,x)                         ; 94C8
        ora     ($02,x)                         ; 94CA
        .byte   $02                             ; 94CC
        .byte   $02                             ; 94CD
        .byte   $02                             ; 94CE
        .byte   $02                             ; 94CF
        .byte   $02                             ; 94D0
        .byte   $02                             ; 94D1
        .byte   $03                             ; 94D2
        .byte   $02                             ; 94D3
        .byte   $03                             ; 94D4
        .byte   $02                             ; 94D5
        .byte   $03                             ; 94D6
        .byte   $04                             ; 94D7
        .byte   $03                             ; 94D8
        .byte   $04                             ; 94D9
        lda     $0706,x                         ; 94DA
        jsr     LE97D                           ; 94DD
        adc     ($B5,x)                         ; 94E0
        ora     #$B5                            ; 94E2
        bit     $36B5                           ; 94E4
        lda     $BD,x                           ; 94E7
        brk                                     ; 94E9
        .byte   $07                             ; 94EA
        bne     L94F7                           ; 94EB
        lda     #$3C                            ; 94ED
        sta     $0700,x                         ; 94EF
        lda     #$0F                            ; 94F2
        jsr     LE992                           ; 94F4
L94F7:  dec     $0700,x                         ; 94F7
        lda     $0700,x                         ; 94FA
        beq     L9526                           ; 94FD
        and     #$07                            ; 94FF
        bne     L9529                           ; 9501
        jsr     LE0A2                           ; 9503
        jmp     LB529                           ; 9506

; ----------------------------------------------------------------------------
        .byte   $BD                             ; 9509
L950A:  .byte   $02                             ; 950A
        .byte   $07                             ; 950B
        bne     L9515                           ; 950C
        lda     #$0C                            ; 950E
        sta     $30                             ; 9510
        sta     $0702,x                         ; 9512
L9515:  lda     $30                             ; 9515
        bne     L9529                           ; 9517
        lda     #$78                            ; 9519
        sta     $0700,x                         ; 951B
        jsr     LEC75                           ; 951E
L9521:  lda     #$2E                            ; 9521
        jsr     LE992                           ; 9523
L9526:  inc     $0706,x                         ; 9526
L9529:  jmp     LE0A0                           ; 9529

; ----------------------------------------------------------------------------
        dec     $0700,x                         ; 952C
        bne     L9529                           ; 952F
        jsr     LEC71                           ; 9531
        bne     L9521                           ; 9534
        lda     $0700,x                         ; 9536
        cmp     #$0C                            ; 9539
        beq     L955B                           ; 953B
        and     #$0C                            ; 953D
        tay                                     ; 953F
        lda     $FFA5,y                         ; 9540
        sta     $04AD                           ; 9543
        lda     $FFA6,y                         ; 9546
        sta     $04AE                           ; 9549
        lda     $FFA7,y                         ; 954C
        sta     $04AF                           ; 954F
        jsr     LF07B                           ; 9552
        inc     $0700,x                         ; 9555
        jmp     LB529                           ; 9558

; ----------------------------------------------------------------------------
L955B:  lda     #$00                            ; 955B
        sta     $0601,x                         ; 955D
        rts                                     ; 9560

; ----------------------------------------------------------------------------
        lda     $0302                           ; 9561
        cmp     #$02                            ; 9564
        bne     L956F                           ; 9566
        jsr     LF0ED                           ; 9568
        cmp     #$06                            ; 956B
        beq     L9575                           ; 956D
L956F:  lda     #$00                            ; 956F
        sta     $0601,x                         ; 9571
        rts                                     ; 9574

; ----------------------------------------------------------------------------
L9575:  lda     #$80                            ; 9575
        sta     $0603,x                         ; 9577
        jmp     LB4E8                           ; 957A

; ----------------------------------------------------------------------------
L957D:  rts                                     ; 957D

; ----------------------------------------------------------------------------
        jsr     LBE50                           ; 957E
        beq     L9592                           ; 9581
        bcc     L957D                           ; 9583
        lda     #$40                            ; 9585
        sta     $030B                           ; 9587
        lda     #$2F                            ; 958A
        jsr     LE992                           ; 958C
        jmp     LB56F                           ; 958F

; ----------------------------------------------------------------------------
L9592:  rts                                     ; 9592

; ----------------------------------------------------------------------------
        lda     $0606,x                         ; 9593
        jsr     LE97D                           ; 9596
        lda     ($B5,x)                         ; 9599
        .byte   $C2                             ; 959B
        lda     $DE,x                           ; 959C
        lda     $E5,x                           ; 959E
        lda     $A9,x                           ; 95A0
        .byte   $FF                             ; 95A2
        sta     $0604,x                         ; 95A3
        jsr     LBE50                           ; 95A6
        beq     L95DD                           ; 95A9
        bcc     L957D                           ; 95AB
        bit     $030B                           ; 95AD
        bvc     L957D                           ; 95B0
        lda     #$80                            ; 95B2
        sta     $0603,x                         ; 95B4
        jsr     LE0A4                           ; 95B7
        lda     #$2F                            ; 95BA
        jsr     LE992                           ; 95BC
        jmp     LB5DA                           ; 95BF

; ----------------------------------------------------------------------------
        lda     #$20                            ; 95C2
        sta     $2F                             ; 95C4
        jsr     LBF39                           ; 95C6
        bne     L95CE                           ; 95C9
        jmp     LE0A0                           ; 95CB

; ----------------------------------------------------------------------------
L95CE:  bcc     L957D                           ; 95CE
        lda     #$FF                            ; 95D0
        sta     $0604,x                         ; 95D2
        lda     #$80                            ; 95D5
        sta     $030B                           ; 95D7
L95DA:  inc     $0606,x                         ; 95DA
L95DD:  rts                                     ; 95DD

; ----------------------------------------------------------------------------
        lda     $2F                             ; 95DE
        cmp     #$18                            ; 95E0
        beq     L95DA                           ; 95E2
        rts                                     ; 95E4

; ----------------------------------------------------------------------------
        lda     $2F                             ; 95E5
        cmp     #$10                            ; 95E7
        bcc     L95F1                           ; 95E9
        lda     $7F                             ; 95EB
        ora     #$20                            ; 95ED
        sta     $7F                             ; 95EF
L95F1:  jsr     LBDC4                           ; 95F1
        jsr     LBE80                           ; 95F4
        lda     $E0                             ; 95F7
        sta     $0602,x                         ; 95F9
        lda     $E1                             ; 95FC
        sta     $0603,x                         ; 95FE
        lda     $2F                             ; 9601
        cmp     #$01                            ; 9603
        bne     L9611                           ; 9605
        lda     #$38                            ; 9607
        sta     $0600,x                         ; 9609
        lda     #$80                            ; 960C
        sta     $0601,x                         ; 960E
L9611:  rts                                     ; 9611

; ----------------------------------------------------------------------------
        dec     $0700,x                         ; 9612
        bne     L9658                           ; 9615
        ldy     $0705,x                         ; 9617
        lda     $0706,x                         ; 961A
        jsr     LE964                           ; 961D
        inc     $0706,x                         ; 9620
        lda     $0706,x                         ; 9623
        cmp     #$02                            ; 9626
        bne     L9630                           ; 9628
        jsr     LE0A4                           ; 962A
        jmp     LE0A0                           ; 962D

; ----------------------------------------------------------------------------
L9630:  lda     $0706,x                         ; 9630
        cmp     #$04                            ; 9633
        beq     L963E                           ; 9635
        lda     #$3C                            ; 9637
        sta     $0700,x                         ; 9639
        bne     L9658                           ; 963C
L963E:  lda     #$83                            ; 963E
        sta     $0601,x                         ; 9640
        jsr     LA874                           ; 9643
        dec     $93                             ; 9646
        lda     $0705,x                         ; 9648
        and     #$07                            ; 964B
        tay                                     ; 964D
        lda     $E0,y                           ; 964E
        and     #$3F                            ; 9651
        adc     #$64                            ; 9653
        sta     $0700,x                         ; 9655
L9658:  jmp     LE0A0                           ; 9658

; ----------------------------------------------------------------------------
        inc     $0702,x                         ; 965B
        bne     L9669                           ; 965E
        jsr     L950A                           ; 9660
        jsr     LE0A4                           ; 9663
        inc     $030B                           ; 9666
L9669:  jmp     LE0A0                           ; 9669

; ----------------------------------------------------------------------------
        jsr     LBD7C                           ; 966C
        bne     L96BA                           ; 966F
        ldy     #$03                            ; 9671
        lda     $09                             ; 9673
        cmp     #$10                            ; 9675
        bcc     L967F                           ; 9677
        iny                                     ; 9679
        lda     $08                             ; 967A
        bpl     L967F                           ; 967C
        iny                                     ; 967E
L967F:  tya                                     ; 967F
        cmp     $0706,x                         ; 9680
        beq     L968E                           ; 9683
        sta     $0706,x                         ; 9685
        ldy     $0705,x                         ; 9688
        jsr     LE964                           ; 968B
L968E:  dec     $0700,x                         ; 968E
        bne     L96AD                           ; 9691
        lda     #$00                            ; 9693
        sta     $0701,x                         ; 9695
        sta     $0707,x                         ; 9698
        lda     #$84                            ; 969B
        sta     $0601,x                         ; 969D
        lda     #$03                            ; 96A0
        sta     $0706,x                         ; 96A2
        lda     #$01                            ; 96A5
        sta     $0700,x                         ; 96A7
        jsr     LE0A4                           ; 96AA
L96AD:  lda     $0702,x                         ; 96AD
        bpl     L96BA                           ; 96B0
        lda     #$22                            ; 96B2
        sta     $0601,x                         ; 96B4
        jsr     LE0A4                           ; 96B7
L96BA:  jmp     LA64C                           ; 96BA

; ----------------------------------------------------------------------------
        dec     $0700,x                         ; 96BD
        bne     L96F7                           ; 96C0
        ldy     $0705,x                         ; 96C2
        lda     $0706,x                         ; 96C5
        jsr     LE964                           ; 96C8
        dec     $0706,x                         ; 96CB
        bmi     L96DC                           ; 96CE
        lda     #$3C                            ; 96D0
        sta     $0700,x                         ; 96D2
        lda     $0706,x                         ; 96D5
        bne     L96F7                           ; 96D8
        beq     L96F1                           ; 96DA
L96DC:  lda     #$00                            ; 96DC
        sta     $0706,x                         ; 96DE
        lda     #$80                            ; 96E1
        sta     $0601,x                         ; 96E3
        lda     $0705,x                         ; 96E6
        and     #$07                            ; 96E9
        lda     $E0,y                           ; 96EB
        sta     $0700,x                         ; 96EE
L96F1:  lda     #$FF                            ; 96F1
        .byte   $9D                             ; 96F3
L96F4:  .byte   $04                             ; 96F4
        asl     $60                             ; 96F5
L96F7:  jmp     LE0A0                           ; 96F7

; ----------------------------------------------------------------------------
        ldy     $0705,x                         ; 96FA
        lda     #$06                            ; 96FD
        jsr     LE964                           ; 96FF
        jmp     LB56F                           ; 9702

; ----------------------------------------------------------------------------
        lda     #$00                            ; 9705
        sta     $0701,x                         ; 9707
        sta     $0707,x                         ; 970A
        lda     $0601,x                         ; 970D
        and     #$07                            ; 9710
        ora     #$F0                            ; 9712
        sta     $0705,x                         ; 9714
        tay                                     ; 9717
        lda     #$00                            ; 9718
        jsr     LE964                           ; 971A
        lda     #$80                            ; 971D
        sta     $0601,x                         ; 971F
        lda     $0705,x                         ; 9722
        and     #$0F                            ; 9725
        tay                                     ; 9727
        lda     $E0,y                           ; 9728
        sta     $0700,x                         ; 972B
        lda     #$FF                            ; 972E
        sta     $0604,x                         ; 9730
        lda     $0705,x                         ; 9733
        and     #$07                            ; 9736
        asl     a                               ; 9738
        asl     a                               ; 9739
        tay                                     ; 973A
        lda     $FF26,y                         ; 973B
        sta     $0602,x                         ; 973E
        lda     $FF27,y                         ; 9741
        sta     $0603,x                         ; 9744
        rts                                     ; 9747

; ----------------------------------------------------------------------------
        lda     #$20                            ; 9748
        sta     L0000                           ; 974A
        lda     $0702,x                         ; 974C
        beq     L975B                           ; 974F
        and     #$01                            ; 9751
        beq     L9763                           ; 9753
        lda     #$26                            ; 9755
        sta     L0000                           ; 9757
        bne     L9763                           ; 9759
L975B:  lda     #$23                            ; 975B
        sta     $0601,x                         ; 975D
        jsr     LE0A4                           ; 9760
L9763:  lda     $0705,x                         ; 9763
        asl     a                               ; 9766
        asl     a                               ; 9767
        tay                                     ; 9768
        lda     L0000                           ; 9769
        sta     $04A7,x                         ; 976B
        jsr     LF07B                           ; 976E
        jmp     LA64C                           ; 9771

; ----------------------------------------------------------------------------
        jsr     LBD7C                           ; 9774
        bne     L97BE                           ; 9777
        ldy     #$00                            ; 9779
        lda     $09                             ; 977B
        cmp     #$10                            ; 977D
        bcc     L9787                           ; 977F
        iny                                     ; 9781
        cmp     #$28                            ; 9782
        bcc     L9787                           ; 9784
        iny                                     ; 9786
L9787:  lda     $08                             ; 9787
        bmi     L9790                           ; 9789
        tya                                     ; 978B
        eor     #$FF                            ; 978C
        tay                                     ; 978E
        iny                                     ; 978F
L9790:  iny                                     ; 9790
        iny                                     ; 9791
        tya                                     ; 9792
        asl     a                               ; 9793
        tay                                     ; 9794
        lda     $FF4A,y                         ; 9795
        sta     L0000                           ; 9798
        lda     $FF4B,y                         ; 979A
        sta     $01                             ; 979D
        lda     $0705,x                         ; 979F
        asl     a                               ; 97A2
        tay                                     ; 97A3
        lda     $FF44,y                         ; 97A4
        clc                                     ; 97A7
        adc     L0000                           ; 97A8
        sta     $0602,x                         ; 97AA
        lda     $FF45,y                         ; 97AD
        clc                                     ; 97B0
        adc     $01                             ; 97B1
        sta     $0603,x                         ; 97B3
        jsr     LA1A7                           ; 97B6
        lda     #$23                            ; 97B9
        sta     $0601,x                         ; 97BB
L97BE:  jmp     LB6AD                           ; 97BE

; ----------------------------------------------------------------------------
        lda     $030A                           ; 97C1
        bne     L97CD                           ; 97C4
        lda     $2F                             ; 97C6
        beq     L97CD                           ; 97C8
        jsr     LBF12                           ; 97CA
L97CD:  rts                                     ; 97CD

; ----------------------------------------------------------------------------
        jmp     L8A60                           ; 97CE

; ----------------------------------------------------------------------------
        lda     $0601,x                         ; 97D1
        and     #$07                            ; 97D4
        sta     $0705,x                         ; 97D6
        asl     a                               ; 97D9
        tay                                     ; 97DA
        lda     $FF44,y                         ; 97DB
        sta     $0602,x                         ; 97DE
        lda     $FF45,y                         ; 97E1
        sta     $0603,x                         ; 97E4
        lda     #$23                            ; 97E7
        sta     $0601,x                         ; 97E9
        jsr     LE0A4                           ; 97EC
        jmp     LA64C                           ; 97EF

; ----------------------------------------------------------------------------
        lda     #$83                            ; 97F2
        sta     $0601,x                         ; 97F4
        lda     #$58                            ; 97F7
        sta     $0602,x                         ; 97F9
        lda     #$80                            ; 97FC
        sta     $0603,x                         ; 97FE
        lda     #$20                            ; 9801
        sta     $0701,x                         ; 9803
        jsr     LE0A4                           ; 9806
        lda     #$20                            ; 9809
        sta     $0707,x                         ; 980B
        jmp     LE0A0                           ; 980E

; ----------------------------------------------------------------------------
        jsr     LBD7C                           ; 9811
        bne     L9824                           ; 9814
        lda     $7F                             ; 9816
        and     #$0F                            ; 9818
        bne     L981F                           ; 981A
        jsr     LE0A2                           ; 981C
L981F:  lda     #$83                            ; 981F
        sta     $0601,x                         ; 9821
L9824:  lda     $0702,x                         ; 9824
        cmp     #$FF                            ; 9827
        bne     L982E                           ; 9829
        inc     $030B                           ; 982B
L982E:  jmp     LA64C                           ; 982E

; ----------------------------------------------------------------------------
        lda     $0705,x                         ; 9831
        and     #$0F                            ; 9834
        sta     L0000                           ; 9836
        lda     $030B                           ; 9838
        and     #$0F                            ; 983B
        cmp     L0000                           ; 983D
        bne     L9868                           ; 983F
        lda     $030A                           ; 9841
        beq     L9868                           ; 9844
        lda     $0705,x                         ; 9846
        sta     $0601,x                         ; 9849
        jsr     LA874                           ; 984C
        asl     $0707,x                         ; 984F
        sec                                     ; 9852
        ror     $0707,x                         ; 9853
        lda     $0701,x                         ; 9856
        clc                                     ; 9859
        adc     $030A                           ; 985A
        sta     $030A                           ; 985D
        lda     #$80                            ; 9860
        sta     $030B                           ; 9862
        jmp     LE0A4                           ; 9865

; ----------------------------------------------------------------------------
L9868:  lda     $0705,x                         ; 9868
        and     #$0F                            ; 986B
        cmp     #$08                            ; 986D
        bne     L9885                           ; 986F
        lda     $12                             ; 9871
        clc                                     ; 9873
        adc     #$80                            ; 9874
        sta     $0603,x                         ; 9876
        lda     #$58                            ; 9879
        sta     $0602,x                         ; 987B
        lda     $21                             ; 987E
        beq     L9885                           ; 9880
        jsr     LB7C1                           ; 9882
L9885:  rts                                     ; 9885

; ----------------------------------------------------------------------------
        lda     #$00                            ; 9886
        sta     $0701,x                         ; 9888
        lda     $030B                           ; 988B
        bpl     L98CA                           ; 988E
        lda     $25                             ; 9890
        beq     L98B8                           ; 9892
        lda     $7F                             ; 9894
        and     #$03                            ; 9896
        bne     L98CA                           ; 9898
        jsr     LE080                           ; 989A
        lda     $7F                             ; 989D
        and     #$04                            ; 989F
        bne     L98C1                           ; 98A1
        ldy     #$02                            ; 98A3
L98A5:  lda     #$20                            ; 98A5
        sta     $04A9,y                         ; 98A7
        sta     $04AD,y                         ; 98AA
        sta     $04B5,y                         ; 98AD
        sta     $04B9,y                         ; 98B0
        dey                                     ; 98B3
        bpl     L98A5                           ; 98B4
        bmi     L98C1                           ; 98B6
L98B8:  asl     $030B                           ; 98B8
        lsr     $030B                           ; 98BB
        jsr     LE080                           ; 98BE
L98C1:  lda     $04B0                           ; 98C1
        sta     $04BA                           ; 98C4
        jsr     LF07B                           ; 98C7
L98CA:  lda     $0700,x                         ; 98CA
        bne     L98E3                           ; 98CD
        lda     $0706,x                         ; 98CF
        clc                                     ; 98D2
        adc     #$01                            ; 98D3
        and     #$1F                            ; 98D5
        sta     $0706,x                         ; 98D7
        lda     $E0                             ; 98DA
        and     #$1F                            ; 98DC
        ora     #$07                            ; 98DE
        sta     $0700,x                         ; 98E0
L98E3:  dec     $0700,x                         ; 98E3
        lda     $030A                           ; 98E6
        beq     L98FE                           ; 98E9
        ldy     $0706,x                         ; 98EB
        lda     $FF84,y                         ; 98EE
        clc                                     ; 98F1
        adc     $12                             ; 98F2
        cmp     #$48                            ; 98F4
        bcc     L98FC                           ; 98F6
        cmp     #$B8                            ; 98F8
        bcc     L98FF                           ; 98FA
L98FC:  sta     $12                             ; 98FC
L98FE:  rts                                     ; 98FE

; ----------------------------------------------------------------------------
L98FF:  lda     #$00                            ; 98FF
        sta     $0700,x                         ; 9901
        rts                                     ; 9904

; ----------------------------------------------------------------------------
        lda     $0601,x                         ; 9905
        sta     $0705,x                         ; 9908
        and     #$07                            ; 990B
        asl     a                               ; 990D
        tay                                     ; 990E
        lda     $FF78,y                         ; 990F
        sta     $0602,x                         ; 9912
        lda     $FF79,y                         ; 9915
        sec                                     ; 9918
        sbc     $12                             ; 9919
        sta     $0603,x                         ; 991B
        jsr     LBD73                           ; 991E
        beq     L992E                           ; 9921
        bcc     L998C                           ; 9923
        lda     $0705,x                         ; 9925
        sta     $0601,x                         ; 9928
        jsr     LE0A4                           ; 992B
L992E:  lda     $0707,x                         ; 992E
        bmi     L994B                           ; 9931
        lda     $0702,x                         ; 9933
        bpl     L9956                           ; 9936
        lda     #$00                            ; 9938
        sta     $0702,x                         ; 993A
        lda     $030B                           ; 993D
        ora     #$80                            ; 9940
        sta     $030B                           ; 9942
        lda     #$03                            ; 9945
        sta     $25                             ; 9947
        bne     L9956                           ; 9949
L994B:  lda     $0702,x                         ; 994B
        bmi     L9956                           ; 994E
        asl     $0707,x                         ; 9950
        lsr     $0707,x                         ; 9953
L9956:  lda     $0601,x                         ; 9956
        and     #$0F                            ; 9959
        sta     L0000                           ; 995B
        lda     $030B                           ; 995D
        and     #$0F                            ; 9960
        cmp     L0000                           ; 9962
        bne     L9970                           ; 9964
        lda     #$14                            ; 9966
        sta     $0701,x                         ; 9968
        lda     #$80                            ; 996B
        sta     $030B                           ; 996D
L9970:  lda     $0604,x                         ; 9970
        pha                                     ; 9973
        lda     $0702,x                         ; 9974
        bne     L997F                           ; 9977
        txa                                     ; 9979
        lsr     a                               ; 997A
        lsr     a                               ; 997B
        sta     $0702,x                         ; 997C
L997F:  jsr     LA1A7                           ; 997F
        pla                                     ; 9982
        sta     $0604,x                         ; 9983
        lda     $0705,x                         ; 9986
        sta     $0601,x                         ; 9989
L998C:  jmp     L9E8C                           ; 998C

; ----------------------------------------------------------------------------
        lda     #$00                            ; 998F
        sta     $0701,x                         ; 9991
        sta     $0707,x                         ; 9994
        lda     $0338                           ; 9997
        bpl     L99BE                           ; 999A
        lda     #$26                            ; 999C
        sta     $0601,x                         ; 999E
        lda     #$58                            ; 99A1
        sta     $0602,x                         ; 99A3
        jsr     LBE36                           ; 99A6
        jsr     LE0A4                           ; 99A9
        dec     $93                             ; 99AC
        jsr     LA874                           ; 99AE
        lda     #$3C                            ; 99B1
        sta     $0700,x                         ; 99B3
        lda     $0707,x                         ; 99B6
        ora     #$40                            ; 99B9
        sta     $0707,x                         ; 99BB
L99BE:  rts                                     ; 99BE

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 99BF
        bne     L99E4                           ; 99C2
        ldy     #$03                            ; 99C4
        jsr     LBD0F                           ; 99C6
        bpl     L99CD                           ; 99C9
        ldy     #$02                            ; 99CB
L99CD:  jsr     LAF74                           ; 99CD
        lda     $0702,x                         ; 99D0
        cmp     #$01                            ; 99D3
        bne     L99E1                           ; 99D5
        lda     $0601,x                         ; 99D7
        and     $08                             ; 99DA
        bne     L99E1                           ; 99DC
        inc     $0702,x                         ; 99DE
L99E1:  jsr     LA1A7                           ; 99E1
L99E4:  jmp     LA64C                           ; 99E4

; ----------------------------------------------------------------------------
        bit     $030B                           ; 99E7
        bpl     L9A03                           ; 99EA
        and     #$7F                            ; 99EC
        sta     $030B                           ; 99EE
        lda     #$88                            ; 99F1
        sta     $CA                             ; 99F3
        lda     #$23                            ; 99F5
        sta     $0601,x                         ; 99F7
        jsr     LE0A4                           ; 99FA
        jsr     LA874                           ; 99FD
        jmp     LBA08                           ; 9A00

; ----------------------------------------------------------------------------
L9A03:  bvc     L9A08                           ; 9A03
        jsr     LB7C1                           ; 9A05
L9A08:  jmp     LA64C                           ; 9A08

; ----------------------------------------------------------------------------
        dec     $0700,x                         ; 9A0B
        bne     L9A18                           ; 9A0E
        jsr     LBE36                           ; 9A10
        lda     #$3C                            ; 9A13
        sta     $0700,x                         ; 9A15
L9A18:  lda     $0601,x                         ; 9A18
        sta     $0705,x                         ; 9A1B
        jsr     LBD7C                           ; 9A1E
        beq     L9A25                           ; 9A21
        bcc     L9A35                           ; 9A23
L9A25:  lda     $0705,x                         ; 9A25
        sta     $0601,x                         ; 9A28
        lda     $0702,x                         ; 9A2B
        cmp     #$FF                            ; 9A2E
        bne     L9A35                           ; 9A30
        inc     $030B                           ; 9A32
L9A35:  jmp     LA64C                           ; 9A35

; ----------------------------------------------------------------------------
        lda     #$00                            ; 9A38
        sta     $0701,x                         ; 9A3A
        lda     $030B                           ; 9A3D
        bmi     L9A98                           ; 9A40
        lda     $0602                           ; 9A42
        clc                                     ; 9A45
        sbc     #$30                            ; 9A46
        sta     $01                             ; 9A48
        lda     $E6                             ; 9A4A
        and     #$3F                            ; 9A4C
        adc     $01                             ; 9A4E
        sta     $01                             ; 9A50
        lda     $E7                             ; 9A52
        and     #$3F                            ; 9A54
        adc     $0603                           ; 9A56
        sta     $02                             ; 9A59
        lda     #$20                            ; 9A5B
        sta     L0000                           ; 9A5D
        lda     $033C                           ; 9A5F
        bpl     L9A6A                           ; 9A62
        lda     #$10                            ; 9A64
        sta     $01                             ; 9A66
        bne     L9A7A                           ; 9A68
L9A6A:  lda     #$80                            ; 9A6A
        sta     L0000                           ; 9A6C
        ldy     #$09                            ; 9A6E
        lda     $E0                             ; 9A70
        bpl     L9A78                           ; 9A72
        lsr     L0000                           ; 9A74
        ldy     #$F7                            ; 9A76
L9A78:  sty     $02                             ; 9A78
L9A7A:  lda     L0000                           ; 9A7A
        sta     $0601,x                         ; 9A7C
        lda     $01                             ; 9A7F
        sta     $0602,x                         ; 9A81
        lda     $02                             ; 9A84
        sta     $0603,x                         ; 9A86
        lda     #$10                            ; 9A89
        sta     $7E                             ; 9A8B
        jsr     LA1A7                           ; 9A8D
        lda     #$80                            ; 9A90
        sta     $0601,x                         ; 9A92
        jsr     LE0A4                           ; 9A95
L9A98:  rts                                     ; 9A98

; ----------------------------------------------------------------------------
        jsr     LBD7C                           ; 9A99
        beq     L9AA0                           ; 9A9C
        bcc     L9B0B                           ; 9A9E
L9AA0:  lda     #$23                            ; 9AA0
        sta     $0601,x                         ; 9AA2
        lda     $0700,x                         ; 9AA5
        bne     L9ABE                           ; 9AA8
        inc     $0706,x                         ; 9AAA
        lda     $0706,x                         ; 9AAD
        and     #$1F                            ; 9AB0
        sta     $0706,x                         ; 9AB2
        lda     $E0                             ; 9AB5
        and     #$3F                            ; 9AB7
        ora     #$01                            ; 9AB9
        sta     $0700,x                         ; 9ABB
L9ABE:  dec     $0700,x                         ; 9ABE
        beq     L9ADE                           ; 9AC1
        ldy     $0706,x                         ; 9AC3
        lda     $FF84,y                         ; 9AC6
        clc                                     ; 9AC9
        adc     $12                             ; 9ACA
        cmp     #$48                            ; 9ACC
        bcc     L9AD4                           ; 9ACE
        cmp     #$B8                            ; 9AD0
        bcc     L9AD9                           ; 9AD2
L9AD4:  sta     $12                             ; 9AD4
        jmp     LBADE                           ; 9AD6

; ----------------------------------------------------------------------------
L9AD9:  lda     #$00                            ; 9AD9
        sta     $0700,x                         ; 9ADB
L9ADE:  lda     #$38                            ; 9ADE
        sta     $0602,x                         ; 9AE0
        lda     #$80                            ; 9AE3
        sec                                     ; 9AE5
        sbc     $12                             ; 9AE6
        sta     $0603,x                         ; 9AE8
        jsr     LA64C                           ; 9AEB
        lda     $0702,x                         ; 9AEE
        beq     L9B0B                           ; 9AF1
        jsr     LE080                           ; 9AF3
        lda     $0702,x                         ; 9AF6
        beq     L9B08                           ; 9AF9
        lsr     a                               ; 9AFB
        bcs     L9B08                           ; 9AFC
        ldy     #$02                            ; 9AFE
L9B00:  lda     #$26                            ; 9B00
        sta     $04A9,y                         ; 9B02
        dey                                     ; 9B05
        .byte   $10                             ; 9B06
L9B07:  sed                                     ; 9B07
L9B08:  jmp     LF07B                           ; 9B08

; ----------------------------------------------------------------------------
L9B0B:  rts                                     ; 9B0B

; ----------------------------------------------------------------------------
        lda     #$00                            ; 9B0C
        sta     $0701,x                         ; 9B0E
        sta     $0700,x                         ; 9B11
        lda     $25                             ; 9B14
        bne     L9B39                           ; 9B16
        jsr     LF07B                           ; 9B18
        lda     #$23                            ; 9B1B
        sta     $0601,x                         ; 9B1D
        txa                                     ; 9B20
        pha                                     ; 9B21
        lda     #$3E                            ; 9B22
        jsr     LE096                           ; 9B24
        jsr     LF09B                           ; 9B27
        pla                                     ; 9B2A
        tax                                     ; 9B2B
        jsr     LA874                           ; 9B2C
        lda     #$80                            ; 9B2F
        sta     $0603,x                         ; 9B31
        lda     #$6C                            ; 9B34
        sta     $0602,x                         ; 9B36
L9B39:  rts                                     ; 9B39

; ----------------------------------------------------------------------------
        bit     $030B                           ; 9B3A
        bvs     L9B95                           ; 9B3D
        jsr     LBEA7                           ; 9B3F
        bne     L9BBA                           ; 9B42
        lda     $0700,x                         ; 9B44
        jsr     LE97D                           ; 9B47
        bvc     L9B07                           ; 9B4A
        .byte   $5B                             ; 9B4C
        .byte   $BB                             ; 9B4D
        ror     $A0BB,x                         ; 9B4E
        brk                                     ; 9B51
        jsr     LFBA5                           ; 9B52
L9B55:  inc     $0700,x                         ; 9B55
        jmp     LBB95                           ; 9B58

; ----------------------------------------------------------------------------
        lda     #$01                            ; 9B5B
        sta     $03                             ; 9B5D
        jsr     LFBE9                           ; 9B5F
        lda     $0602,x                         ; 9B62
        cmp     #$B8                            ; 9B65
        bcs     L9B55                           ; 9B67
        lda     $0603,x                         ; 9B69
        cmp     #$47                            ; 9B6C
        bcs     L9B72                           ; 9B6E
        lda     #$48                            ; 9B70
L9B72:  cmp     #$B8                            ; 9B72
        bcc     L9B78                           ; 9B74
        lda     #$B8                            ; 9B76
L9B78:  sta     $0603,x                         ; 9B78
        jmp     LBB95                           ; 9B7B

; ----------------------------------------------------------------------------
        lda     $0602,x                         ; 9B7E
        sec                                     ; 9B81
        sbc     $97                             ; 9B82
        sta     $0602,x                         ; 9B84
        cmp     #$58                            ; 9B87
        bcs     L9B95                           ; 9B89
        lda     #$58                            ; 9B8B
        sta     $0602,x                         ; 9B8D
        lda     #$00                            ; 9B90
        sta     $0700,x                         ; 9B92
L9B95:  lda     $0603,x                         ; 9B95
        sec                                     ; 9B98
        sbc     #$80                            ; 9B99
        eor     #$FF                            ; 9B9B
        clc                                     ; 9B9D
        adc     #$01                            ; 9B9E
        sta     $12                             ; 9BA0
        lda     #$6C                            ; 9BA2
        sec                                     ; 9BA4
        sbc     $0602,x                         ; 9BA5
        sta     $14                             ; 9BA8
        asl     a                               ; 9BAA
        lda     #$00                            ; 9BAB
        sta     $15                             ; 9BAD
        bcc     L9BBA                           ; 9BAF
        inc     $15                             ; 9BB1
        lda     $14                             ; 9BB3
        sec                                     ; 9BB5
        sbc     #$10                            ; 9BB6
        sta     $14                             ; 9BB8
L9BBA:  rts                                     ; 9BBA

; ----------------------------------------------------------------------------
        lda     $0700,x                         ; 9BBB
        bne     L9BD1                           ; 9BBE
        jsr     LEC75                           ; 9BC0
        lda     #$04                            ; 9BC3
        sta     $2F                             ; 9BC5
        lda     #$46                            ; 9BC7
        sta     $0700,x                         ; 9BC9
        lda     #$30                            ; 9BCC
        jsr     LE992                           ; 9BCE
L9BD1:  lda     $2F                             ; 9BD1
        bne     L9BDF                           ; 9BD3
        lda     $031C                           ; 9BD5
        and     #$C0                            ; 9BD8
        beq     L9BDF                           ; 9BDA
        jsr     LEC71                           ; 9BDC
L9BDF:  dec     $0700,x                         ; 9BDF
        bne     L9C05                           ; 9BE2
        lda     #$04                            ; 9BE4
        sta     $18                             ; 9BE6
        lda     #$80                            ; 9BE8
        sta     $0601,x                         ; 9BEA
        lda     #$4B                            ; 9BED
        sta     $25                             ; 9BEF
        lda     #$00                            ; 9BF1
        sta     $12                             ; 9BF3
        sta     $14                             ; 9BF5
        sta     $15                             ; 9BF7
        txa                                     ; 9BF9
        pha                                     ; 9BFA
        lda     #$3D                            ; 9BFB
        jsr     LE096                           ; 9BFD
        jsr     LF09B                           ; 9C00
        pla                                     ; 9C03
        tax                                     ; 9C04
L9C05:  rts                                     ; 9C05

; ----------------------------------------------------------------------------
        lda     #$00                            ; 9C06
        sta     $0701,x                         ; 9C08
        lda     $0706,x                         ; 9C0B
        jsr     LE97D                           ; 9C0E
        ora     $31BC,y                         ; 9C11
        ldy     $BC35,x                         ; 9C14
        .byte   $43                             ; 9C17
        ldy     $25A5,x                         ; 9C18
        beq     L9C34                           ; 9C1B
        ldy     $0705,x                         ; 9C1D
        lda     $FFB0,y                         ; 9C20
        sta     $0602,x                         ; 9C23
        lda     $FFB1,y                         ; 9C26
        sta     $0603,x                         ; 9C29
        lda     #$00                            ; 9C2C
        sta     $0704,x                         ; 9C2E
L9C31:  inc     $0706,x                         ; 9C31
L9C34:  rts                                     ; 9C34

; ----------------------------------------------------------------------------
        lda     $0704,x                         ; 9C35
        clc                                     ; 9C38
        adc     #$02                            ; 9C39
        sta     $0704,x                         ; 9C3B
        cmp     #$08                            ; 9C3E
        beq     L9C31                           ; 9C40
        rts                                     ; 9C42

; ----------------------------------------------------------------------------
        lda     $25                             ; 9C43
        bne     L9C4D                           ; 9C45
        lda     #$00                            ; 9C47
        sta     $0706,x                         ; 9C49
        rts                                     ; 9C4C

; ----------------------------------------------------------------------------
L9C4D:  lda     #$00                            ; 9C4D
        sta     L0000                           ; 9C4F
        ldy     $0705,x                         ; 9C51
        lda     $0602,x                         ; 9C54
        cmp     $FFB0,y                         ; 9C57
        beq     L9C65                           ; 9C5A
        inc     L0000                           ; 9C5C
        clc                                     ; 9C5E
        adc     $FFB2,y                         ; 9C5F
        sta     $0602,x                         ; 9C62
L9C65:  lda     $0603,x                         ; 9C65
        cmp     $FFB1,y                         ; 9C68
        beq     L9C76                           ; 9C6B
        inc     L0000                           ; 9C6D
        clc                                     ; 9C6F
        adc     $FFB3,y                         ; 9C70
        sta     $0603,x                         ; 9C73
L9C76:  lda     L0000                           ; 9C76
        bne     L9C88                           ; 9C78
        iny                                     ; 9C7A
        iny                                     ; 9C7B
        iny                                     ; 9C7C
        iny                                     ; 9C7D
        cpy     #$18                            ; 9C7E
        bne     L9C84                           ; 9C80
        ldy     #$00                            ; 9C82
L9C84:  tya                                     ; 9C84
        sta     $0705,x                         ; 9C85
L9C88:  rts                                     ; 9C88

; ----------------------------------------------------------------------------
        ldy     $0703,x                         ; 9C89
        lda     $0706,y                         ; 9C8C
        jsr     LE97D                           ; 9C8F
        txs                                     ; 9C92
        ldy     $BCA0,x                         ; 9C93
        ldx     $BC                             ; 9C96
        ldx     $BC                             ; 9C98
        lda     #$FF                            ; 9C9A
        sta     $0604,x                         ; 9C9C
        rts                                     ; 9C9F

; ----------------------------------------------------------------------------
        jsr     LE0A4                           ; 9CA0
        jmp     LA64C                           ; 9CA3

; ----------------------------------------------------------------------------
        lda     $0601,x                         ; 9CA6
        pha                                     ; 9CA9
        lda     $0604,x                         ; 9CAA
        pha                                     ; 9CAD
        jsr     LBEDF                           ; 9CAE
        beq     L9CB8                           ; 9CB1
        bcs     L9CB8                           ; 9CB3
        pla                                     ; 9CB5
        pla                                     ; 9CB6
        rts                                     ; 9CB7

; ----------------------------------------------------------------------------
L9CB8:  pla                                     ; 9CB8
        sta     $0604,x                         ; 9CB9
        pla                                     ; 9CBC
        sta     $0601,x                         ; 9CBD
        jsr     LFA84                           ; 9CC0
        jsr     LA64C                           ; 9CC3
        lda     $0601,x                         ; 9CC6
        and     #$0F                            ; 9CC9
        cmp     #$03                            ; 9CCB
        bne     L9CE8                           ; 9CCD
        lda     $030B                           ; 9CCF
        cmp     #$0A                            ; 9CD2
        bne     L9CE8                           ; 9CD4
        lda     #$00                            ; 9CD6
        sta     $030B                           ; 9CD8
        lda     $0701,x                         ; 9CDB
        clc                                     ; 9CDE
        adc     #$20                            ; 9CDF
        bcc     L9CE5                           ; 9CE1
        lda     #$FF                            ; 9CE3
L9CE5:  sta     $0701,x                         ; 9CE5
L9CE8:  rts                                     ; 9CE8

; ----------------------------------------------------------------------------
        bit     $030B                           ; 9CE9
        bvs     L9D02                           ; 9CEC
        ldy     $0703,x                         ; 9CEE
        lda     #$00                            ; 9CF1
        sta     $0601,y                         ; 9CF3
        sta     $93                             ; 9CF6
        lda     #$FF                            ; 9CF8
        sta     $25                             ; 9CFA
        jsr     LF07B                           ; 9CFC
        jmp     LBB2F                           ; 9CFF

; ----------------------------------------------------------------------------
L9D02:  lda     #$80                            ; 9D02
        sta     $0603,x                         ; 9D04
        lda     #$6C                            ; 9D07
        sta     $0602,x                         ; 9D09
        jmp     LB7C1                           ; 9D0C

; ----------------------------------------------------------------------------
        lda     $03CA                           ; 9D0F
        beq     L9D17                           ; 9D12
        lda     $033A                           ; 9D14
L9D17:  rts                                     ; 9D17

; ----------------------------------------------------------------------------
        cmp     #$06                            ; 9D18
        bcc     L9D1E                           ; 9D1A
        lda     #$00                            ; 9D1C
L9D1E:  asl     a                               ; 9D1E
        sta     L0000                           ; 9D1F
        asl     a                               ; 9D21
        adc     L0000                           ; 9D22
        sta     L0000                           ; 9D24
        tya                                     ; 9D26
        and     #$0F                            ; 9D27
        asl     a                               ; 9D29
        asl     a                               ; 9D2A
        tay                                     ; 9D2B
        lda     $FF24,y                         ; 9D2C
        sta     $02                             ; 9D2F
        lda     $FF25,y                         ; 9D31
        sta     $01                             ; 9D34
        lda     #$02                            ; 9D36
        sta     $03                             ; 9D38
L9D3A:  ldx     $0162                           ; 9D3A
        lda     $01                             ; 9D3D
        sta     $0163,x                         ; 9D3F
        inx                                     ; 9D42
        lda     $02                             ; 9D43
        sta     $0163,x                         ; 9D45
        inx                                     ; 9D48
        clc                                     ; 9D49
        adc     #$20                            ; 9D4A
        sta     $02                             ; 9D4C
        lda     #$03                            ; 9D4E
        sta     $0163,x                         ; 9D50
        inx                                     ; 9D53
        sta     $04                             ; 9D54
        ldy     L0000                           ; 9D56
L9D58:  lda     $FF54,y                         ; 9D58
        sta     $0163,x                         ; 9D5B
        iny                                     ; 9D5E
        inx                                     ; 9D5F
        dec     $04                             ; 9D60
        bne     L9D58                           ; 9D62
        stx     $0162                           ; 9D64
        sty     L0000                           ; 9D67
        dec     $03                             ; 9D69
        bne     L9D3A                           ; 9D6B
        lda     #$00                            ; 9D6D
        sta     $0163,x                         ; 9D6F
        rts                                     ; 9D72

; ----------------------------------------------------------------------------
        jsr     LF510                           ; 9D73
        jsr     LF41D                           ; 9D76
        jmp     LBD7F                           ; 9D79

; ----------------------------------------------------------------------------
        jsr     LF3E0                           ; 9D7C
        sta     $05                             ; 9D7F
        beq     L9D97                           ; 9D81
        jsr     LA839                           ; 9D83
        sta     L0000                           ; 9D86
        lda     $05                             ; 9D88
        bpl     L9D9A                           ; 9D8A
        lda     $20                             ; 9D8C
        ora     $29                             ; 9D8E
        bne     L9D97                           ; 9D90
        lda     L0000                           ; 9D92
        jsr     LA43E                           ; 9D94
L9D97:  lda     #$00                            ; 9D97
        rts                                     ; 9D99

; ----------------------------------------------------------------------------
L9D9A:  lda     $0702,x                         ; 9D9A
        bmi     L9D97                           ; 9D9D
        lda     $05                             ; 9D9F
        and     #$01                            ; 9DA1
        beq     L9D97                           ; 9DA3
        lda     $0707,x                         ; 9DA5
        and     #$02                            ; 9DA8
        beq     L9DC3                           ; 9DAA
        jsr     LA72E                           ; 9DAC
        beq     L9DC3                           ; 9DAF
        bcc     L9DC3                           ; 9DB1
        lda     #$02                            ; 9DB3
        jsr     LF0BE                           ; 9DB5
        lda     #$E0                            ; 9DB8
        sta     $0702,x                         ; 9DBA
        jsr     LE0A4                           ; 9DBD
        lda     #$01                            ; 9DC0
        sec                                     ; 9DC2
L9DC3:  rts                                     ; 9DC3

; ----------------------------------------------------------------------------
        txa                                     ; 9DC4
        lsr     a                               ; 9DC5
        lsr     a                               ; 9DC6
        lsr     a                               ; 9DC7
        and     #$07                            ; 9DC8
        tay                                     ; 9DCA
        lda     $0700,x                         ; 9DCB
        bne     L9E32                           ; 9DCE
        lda     $E0,y                           ; 9DD0
        lda     #$0F                            ; 9DD3
        adc     #$07                            ; 9DD5
        sta     $0700,x                         ; 9DD7
        tya                                     ; 9DDA
        and     #$06                            ; 9DDB
        tay                                     ; 9DDD
        lda     $E0,y                           ; 9DDE
        and     #$1F                            ; 9DE1
        adc     $0602,x                         ; 9DE3
        cmp     #$20                            ; 9DE6
        bcs     L9DEC                           ; 9DE8
        lda     #$20                            ; 9DEA
L9DEC:  cmp     #$B0                            ; 9DEC
        bcc     L9DF2                           ; 9DEE
        lda     #$B0                            ; 9DF0
L9DF2:  sta     L0000                           ; 9DF2
        lda     $E1,y                           ; 9DF4
        and     #$1F                            ; 9DF7
        adc     $0603,x                         ; 9DF9
        sta     $01                             ; 9DFC
        jsr     LF11C                           ; 9DFE
        bne     L9E35                           ; 9E01
        lda     #$0F                            ; 9E03
        sta     $0600,y                         ; 9E05
        lda     #$80                            ; 9E08
        sta     $0601,y                         ; 9E0A
        lda     L0000                           ; 9E0D
        sta     $0602,y                         ; 9E0F
        lda     $01                             ; 9E12
        sta     $0603,y                         ; 9E14
        lda     #$0F                            ; 9E17
        sta     $0700,y                         ; 9E19
        lda     #$00                            ; 9E1C
        sta     $0701,y                         ; 9E1E
        sta     $0707,y                         ; 9E21
        txa                                     ; 9E24
        pha                                     ; 9E25
        tya                                     ; 9E26
        tax                                     ; 9E27
        jsr     LE0A4                           ; 9E28
        pla                                     ; 9E2B
        tax                                     ; 9E2C
        lda     #$23                            ; 9E2D
        jsr     LE992                           ; 9E2F
L9E32:  dec     $0700,x                         ; 9E32
L9E35:  rts                                     ; 9E35

; ----------------------------------------------------------------------------
        lda     $E0                             ; 9E36
        and     #$0F                            ; 9E38
L9E3A:  sec                                     ; 9E3A
        sbc     #$05                            ; 9E3B
        bcs     L9E3A                           ; 9E3D
        adc     #$05                            ; 9E3F
        sta     L0000                           ; 9E41
        asl     a                               ; 9E43
        adc     L0000                           ; 9E44
        asl     a                               ; 9E46
        asl     a                               ; 9E47
        asl     a                               ; 9E48
        asl     a                               ; 9E49
        adc     #$20                            ; 9E4A
        sta     $0603,x                         ; 9E4C
        rts                                     ; 9E4F

; ----------------------------------------------------------------------------
        lda     $0601                           ; 9E50
        and     #$10                            ; 9E53
        beq     L9E78                           ; 9E55
        jsr     LF3E0                           ; 9E57
        and     #$84                            ; 9E5A
        beq     L9E78                           ; 9E5C
        bpl     L9E79                           ; 9E5E
        lda     $0601                           ; 9E60
        and     #$0F                            ; 9E63
        cmp     #$05                            ; 9E65
        bne     L9E7D                           ; 9E67
        jsr     LF0ED                           ; 9E69
        cmp     #$06                            ; 9E6C
        bne     L9E79                           ; 9E6E
        lda     $C6                             ; 9E70
        cmp     #$1E                            ; 9E72
        bne     L9E79                           ; 9E74
        lda     #$01                            ; 9E76
L9E78:  rts                                     ; 9E78

; ----------------------------------------------------------------------------
L9E79:  lda     #$01                            ; 9E79
        clc                                     ; 9E7B
        rts                                     ; 9E7C

; ----------------------------------------------------------------------------
L9E7D:  lda     #$00                            ; 9E7D
        rts                                     ; 9E7F

; ----------------------------------------------------------------------------
        lda     $7F                             ; 9E80
        and     #$3F                            ; 9E82
        bne     L9E89                           ; 9E84
        jsr     LF085                           ; 9E86
L9E89:  lda     $7F                             ; 9E89
        .byte   $29                             ; 9E8B
L9E8C:  ora     ($D0,x)                         ; 9E8C
        ora     $A0,x                           ; 9E8E
        .byte   $0B                             ; 9E90
        lda     $04B0                           ; 9E91
        sta     L0000                           ; 9E94
L9E96:  lda     $04A4,y                         ; 9E96
        sta     $04A5,y                         ; 9E99
        dey                                     ; 9E9C
        bpl     L9E96                           ; 9E9D
        lda     L0000                           ; 9E9F
        sta     $04A4                           ; 9EA1
        jmp     LF07B                           ; 9EA4

; ----------------------------------------------------------------------------
        jsr     LF3E0                           ; 9EA7
        and     #$80                            ; 9EAA
        bpl     L9EDE                           ; 9EAC
        txa                                     ; 9EAE
        tay                                     ; 9EAF
        pha                                     ; 9EB0
        lda     #$05                            ; 9EB1
        sta     $0600                           ; 9EB3
        lda     #$8B                            ; 9EB6
        sta     $0601                           ; 9EB8
        ldx     #$00                            ; 9EBB
        jsr     LE0A4                           ; 9EBD
        jsr     LFBA5                           ; 9EC0
        lda     #$C8                            ; 9EC3
        sta     $0700                           ; 9EC5
        lda     #$19                            ; 9EC8
        jsr     LE992                           ; 9ECA
        lda     #$40                            ; 9ECD
        jsr     LE096                           ; 9ECF
        jsr     LE110                           ; 9ED2
        pla                                     ; 9ED5
        tax                                     ; 9ED6
        lda     #$00                            ; 9ED7
        sta     $0601,x                         ; 9ED9
        lda     #$01                            ; 9EDC
L9EDE:  rts                                     ; 9EDE

; ----------------------------------------------------------------------------
        jsr     LF3E0                           ; 9EDF
        beq     L9EF8                           ; 9EE2
        sta     $05                             ; 9EE4
        and     #$01                            ; 9EE6
        beq     L9EF9                           ; 9EE8
        lda     $0601,y                         ; 9EEA
        and     #$0F                            ; 9EED
        cmp     #$06                            ; 9EEF
        beq     L9EF9                           ; 9EF1
        lda     #$00                            ; 9EF3
        sta     $060B,x                         ; 9EF5
L9EF8:  rts                                     ; 9EF8

; ----------------------------------------------------------------------------
L9EF9:  lda     $0601,x                         ; 9EF9
        and     #$0F                            ; 9EFC
        cmp     #$03                            ; 9EFE
        beq     L9F0C                           ; 9F00
        jsr     LA839                           ; 9F02
        sta     L0000                           ; 9F05
        lda     $05                             ; 9F07
        bmi     L9F0F                           ; 9F09
        rts                                     ; 9F0B

; ----------------------------------------------------------------------------
L9F0C:  jmp     LBD83                           ; 9F0C

; ----------------------------------------------------------------------------
L9F0F:  jmp     LBD8C                           ; 9F0F

; ----------------------------------------------------------------------------
        lda     $2F                             ; 9F12
        cmp     #$04                            ; 9F14
        bcc     L9F2F                           ; 9F16
        jsr     LBDC4                           ; 9F18
        lda     $7F                             ; 9F1B
        and     #$03                            ; 9F1D
        bne     L9F2B                           ; 9F1F
        lda     $7F                             ; 9F21
        and     #$04                            ; 9F23
        bne     L9F2C                           ; 9F25
        lda     #$05                            ; 9F27
        sta     $18                             ; 9F29
L9F2B:  rts                                     ; 9F2B

; ----------------------------------------------------------------------------
L9F2C:  jmp     LF07B                           ; 9F2C

; ----------------------------------------------------------------------------
L9F2F:  lda     $7F                             ; 9F2F
        and     #$07                            ; 9F31
        bne     L9F38                           ; 9F33
        jsr     LF067                           ; 9F35
L9F38:  rts                                     ; 9F38

; ----------------------------------------------------------------------------
        lda     $0700,x                         ; 9F39
        bne     L9F5F                           ; 9F3C
        lda     #$B4                            ; 9F3E
        sta     $0700,x                         ; 9F40
        lda     $0702,x                         ; 9F43
        cmp     #$05                            ; 9F46
        bcc     L9F4F                           ; 9F48
        lda     #$00                            ; 9F4A
        sta     $0702,x                         ; 9F4C
L9F4F:  tay                                     ; 9F4F
        lda     $BF7A,y                         ; 9F50
        sta     $04BD                           ; 9F53
        inc     $0702,x                         ; 9F56
        jsr     LF07B                           ; 9F59
        lda     #$00                            ; 9F5C
        rts                                     ; 9F5E

; ----------------------------------------------------------------------------
L9F5F:  dec     $0700,x                         ; 9F5F
        jsr     LBE50                           ; 9F62
        beq     L9F79                           ; 9F65
        bcc     L9F79                           ; 9F67
        lda     #$00                            ; 9F69
        sta     $0700,x                         ; 9F6B
        lda     $04BD                           ; 9F6E
        cmp     $BF7D                           ; 9F71
        beq     L9F77                           ; 9F74
        clc                                     ; 9F76
L9F77:  lda     #$01                            ; 9F77
L9F79:  rts                                     ; 9F79

; ----------------------------------------------------------------------------
        asl     $18,x                           ; 9F7A
        .byte   $0F                             ; 9F7C
        ora     ($1A),y                         ; 9F7D
        lda     $7E                             ; 9F7F
        bne     L9F87                           ; 9F81
        lda     #$03                            ; 9F83
        sta     $7E                             ; 9F85
L9F87:  ldy     #$38                            ; 9F87
L9F89:  lda     $0601,y                         ; 9F89
        bne     L9F93                           ; 9F8C
        sta     $7E                             ; 9F8E
        jmp     LF12B                           ; 9F90

; ----------------------------------------------------------------------------
L9F93:  lda     $0600,y                         ; 9F93
        cmp     #$0D                            ; 9F96
        beq     L9F9E                           ; 9F98
        cmp     #$0E                            ; 9F9A
        bne     L9FAA                           ; 9F9C
L9F9E:  dec     $7E                             ; 9F9E
        bne     L9FAA                           ; 9FA0
        lda     $0E                             ; 9FA2
        and     #$0F                            ; 9FA4
        cmp     #$05                            ; 9FA6
        bcc     L9FB1                           ; 9FA8
L9FAA:  tya                                     ; 9FAA
        clc                                     ; 9FAB
        adc     #$08                            ; 9FAC
        tay                                     ; 9FAE
        bne     L9F89                           ; 9FAF
L9FB1:  sta     $7E                             ; 9FB1
        ldy     #$38                            ; 9FB3
        rts                                     ; 9FB5

; ----------------------------------------------------------------------------
        ora     ($FF,x)                         ; 9FB6
        sty     $58,x                           ; 9FB8
        ora     ($01,x)                         ; 9FBA
        .byte   $44                             ; 9FBC
        tay                                     ; 9FBD
        .byte   $FF                             ; 9FBE
        ora     ($6C,x)                         ; 9FBF
        cld                                     ; 9FC1
        ora     ($01,x)                         ; 9FC2
        sty     $A8,x                           ; 9FC4
        ora     ($FF,x)                         ; 9FC6
        bmi     L9FCB                           ; 9FC8
        .byte   $FF                             ; 9FCA
L9FCB:  sty     $58,x                           ; 9FCB
        ora     ($01,x)                         ; 9FCD
        .byte   $44                             ; 9FCF
        tay                                     ; 9FD0
        .byte   $FF                             ; 9FD1
        ora     ($6C,x)                         ; 9FD2
        cld                                     ; 9FD4
        ora     ($01,x)                         ; 9FD5
        sty     $A8,x                           ; 9FD7
        ora     ($FF,x)                         ; 9FD9
        .byte   $FF                             ; 9FDB
        .byte   $FF                             ; 9FDC
        .byte   $FF                             ; 9FDD
        .byte   $FF                             ; 9FDE
        .byte   $FF                             ; 9FDF
        .byte   $FF                             ; 9FE0
        .byte   $FF                             ; 9FE1
        .byte   $FF                             ; 9FE2
        .byte   $FF                             ; 9FE3
        .byte   $FF                             ; 9FE4
        .byte   $FF                             ; 9FE5
        .byte   $FF                             ; 9FE6
        .byte   $FF                             ; 9FE7
        .byte   $FF                             ; 9FE8
        .byte   $FF                             ; 9FE9
        .byte   $FF                             ; 9FEA
        .byte   $FF                             ; 9FEB
        .byte   $FF                             ; 9FEC
        .byte   $FF                             ; 9FED
        .byte   $FF                             ; 9FEE
        .byte   $FF                             ; 9FEF
        .byte   $FF                             ; 9FF0
        .byte   $FF                             ; 9FF1
        .byte   $FF                             ; 9FF2
        .byte   $FF                             ; 9FF3
        .byte   $FF                             ; 9FF4
        .byte   $FF                             ; 9FF5
        .byte   $FF                             ; 9FF6
        .byte   $FF                             ; 9FF7
        .byte   $FF                             ; 9FF8
        .byte   $FF                             ; 9FF9
        .byte   $FF                             ; 9FFA
        .byte   $FF                             ; 9FFB
        .byte   $FF                             ; 9FFC
        .byte   $FF                             ; 9FFD
        .byte   $FF                             ; 9FFE
        .byte   $FF                             ; 9FFF
