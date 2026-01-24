; ============================================================================
; The Magic of Scheherazade - Bank 07 Disassembly
; ============================================================================
; File Offset: 0x0E000 - 0x0FFFF
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
; Created:    2026-01-24 04:39:26
; Input file: C:/claude-workspace/TMOS_AI/rom-files/disassembly/output/banks/bank_07.bin
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
PPU_CTRL        := $2000
PPU_MASK        := $2001
PPU_STATUS      := $2002
OAM_ADDR        := $2003
OAM_DATA        := $2004
PPU_SCROLL      := $2005
PPU_ADDR        := $2006
PPU_DATA        := $2007
OAM_DMA         := $4014
APU_STATUS      := $4015
JOY1            := $4016
JOY2_FRAME      := $4017
L7FE1           := $7FE1
LA005           := $A005
LA080           := $A080
LA13F           := $A13F
LA33C           := $A33C
LA42B           := $A42B
LA4DE           := $A4DE
LA537           := $A537
LA553           := $A553
LA5F2           := $A5F2
LA607           := $A607
LA66E           := $A66E
LA683           := $A683
LA6B2           := $A6B2
LA6E7           := $A6E7
LA728           := $A728
LA74A           := $A74A
LA8BE           := $A8BE
LA8F8           := $A8F8
LAA82           := $AA82
LAC93           := $AC93
LAD04           := $AD04
LAD21           := $AD21
LAEC9           := $AEC9
LAF1F           := $AF1F
LAF82           := $AF82
LB02B           := $B02B
LB16F           := $B16F
LB1B3           := $B1B3
LB203           := $B203
LB217           := $B217
LB281           := $B281
LB29F           := $B29F
LB2AC           := $B2AC
LB30D           := $B30D
LB35E           := $B35E
LB39B           := $B39B
LB3F7           := $B3F7
LB41A           := $B41A
LB448           := $B448
LB480           := $B480
LB528           := $B528
LB555           := $B555
LB56D           := $B56D
LB593           := $B593
LB6C4           := $B6C4
LB6D5           := $B6D5
LB6F3           := $B6F3
LB71A           := $B71A
LB744           := $B744
LB74C           := $B74C
LB767           := $B767
LB7A9           := $B7A9
LB7E9           := $B7E9
LB805           := $B805
LB8B0           := $B8B0
LB8BF           := $B8BF
LB8EF           := $B8EF
LB8F9           := $B8F9
LB92C           := $B92C
LB941           := $B941
LB94C           := $B94C
LB969           := $B969
LB975           := $B975
LB98B           := $B98B
LB9A1           := $B9A1
LB9D4           := $B9D4
LBA2C           := $BA2C
LBAA1           := $BAA1
LBAD0           := $BAD0
LBAD7           := $BAD7
LBAFA           := $BAFA
LBB00           := $BB00
LBB07           := $BB07
LBB61           := $BB61
LBB67           := $BB67
LBB87           := $BB87
LBB8D           := $BB8D
LBBBA           := $BBBA
LBBDB           := $BBDB
LBC14           := $BC14
LBC1B           := $BC1B
LBC43           := $BC43
LBC8D           := $BC8D
LBCC8           := $BCC8
LBD51           := $BD51
LBD5E           := $BD5E
LBDB3           := $BDB3
LBDD8           := $BDD8
LBE0A           := $BE0A
LBE5A           := $BE5A
LBE90           := $BE90
LBEB0           := $BEB0
LBF12           := $BF12
LC02C           := $C02C
LC05E           := $C05E
LC08E           := $C08E
LC0C4           := $C0C4
LC13B           := $C13B
LC1FE           := $C1FE
LC223           := $C223
LC257           := $C257
LC25E           := $C25E
LC3D2           := $C3D2
LC3F4           := $C3F4
LC4E3           := $C4E3
LC52E           := $C52E
LC536           := $C536
LC551           := $C551
LC5A9           := $C5A9
LC612           := $C612
LC6F3           := $C6F3
LC762           := $C762
LC793           := $C793
LC7F9           := $C7F9
LC837           := $C837
LC8B0           := $C8B0
LC910           := $C910
LC929           := $C929
LC996           := $C996
LC9A7           := $C9A7
LCA04           := $CA04
LCA16           := $CA16
LCA30           := $CA30
LCA62           := $CA62
LCA9A           := $CA9A
LCAE1           := $CAE1
LCAFA           := $CAFA
LCB16           := $CB16
LCB83           := $CB83
LCB8F           := $CB8F
LCB9B           := $CB9B
LCBA7           := $CBA7
LCBB3           := $CBB3
LCBD7           := $CBD7
LCBE3           := $CBE3
LCBEF           := $CBEF
LCC43           := $CC43
LCCA3           := $CCA3
LCCD1           := $CCD1
LCCF1           := $CCF1
LCD8E           := $CD8E
LCDA5           := $CDA5
LCDAE           := $CDAE
LCDD5           := $CDD5
LCE00           := $CE00
LCE39           := $CE39
LCE8D           := $CE8D
LCEAF           := $CEAF
LCECC           := $CECC
LCEE3           := $CEE3
LCEFA           := $CEFA
LCF18           := $CF18
LCF25           := $CF25
LCF3A           := $CF3A
LCF43           := $CF43
LCF88           := $CF88
LCFA1           := $CFA1
LDF16           := $DF16
LDF18           := $DF18
LE029           := $E029
LE95B           := $E95B
LE97D           := $E97D
LE992           := $E992
; ----------------------------------------------------------------------------
        asl     $20                             ; 8000
        rol     a                               ; 8002
        ldy     #$4C                            ; 8003
        .byte   $12                             ; 8005
        ldy     #$20                            ; 8006
        .byte   $47                             ; 8008
        ldy     #$4C                            ; 8009
        .byte   $12                             ; 800B
        ldy     #$A9                            ; 800C
        .byte   $07                             ; 800E
        jsr     LCFA1                           ; 800F
        lda     $05C7                           ; 8012
        jsr     LC6F3                           ; 8015
        lda     $0510,y                         ; 8018
        and     #$02                            ; 801B
        bne     L8029                           ; 801D
        inc     $059D                           ; 801F
        lda     $059D                           ; 8022
        cmp     #$07                            ; 8025
        bne     L7FE1                           ; 8027
L8029:  rts                                     ; 8029

; ----------------------------------------------------------------------------
        lda     #$04                            ; 802A
        sta     $046E                           ; 802C
        lda     #$0D                            ; 802F
        sta     $046F                           ; 8031
        lda     #$14                            ; 8034
        sta     $0470                           ; 8036
        lda     #$05                            ; 8039
        sta     $0471                           ; 803B
        lda     #$02                            ; 803E
        sta     $0472                           ; 8040
        jsr     LA74A                           ; 8043
        rts                                     ; 8046

; ----------------------------------------------------------------------------
        lda     #$02                            ; 8047
        sta     $046E                           ; 8049
        lda     #$04                            ; 804C
        sta     $046F                           ; 804E
        lda     #$13                            ; 8051
        sta     $0470                           ; 8053
        lda     #$04                            ; 8056
        sta     $0471                           ; 8058
        lda     #$04                            ; 805B
        sta     $0472                           ; 805D
        jsr     LA74A                           ; 8060
        rts                                     ; 8063

; ----------------------------------------------------------------------------
        lda     #$01                            ; 8064
        jsr     LA553                           ; 8066
        jsr     LCF43                           ; 8069
        lda     #$20                            ; 806C
        jsr     LDF16                           ; 806E
        lda     #$00                            ; 8071
        ldx     #$06                            ; 8073
L8075:  sta     $0593,x                         ; 8075
        dex                                     ; 8078
        bpl     L8075                           ; 8079
        lda     #$00                            ; 807B
        sta     $059C                           ; 807D
        jsr     LC6F3                           ; 8080
        lda     $054D,y                         ; 8083
        cmp     $0503                           ; 8086
        beq     L808E                           ; 8089
        jmp     LA13F                           ; 808B

; ----------------------------------------------------------------------------
L808E:  lda     $054E,y                         ; 808E
        sta     $0504                           ; 8091
        lda     $054F,y                         ; 8094
        and     #$10                            ; 8097
        bne     L80FF                           ; 8099
        lda     $054F,y                         ; 809B
        sta     $50                             ; 809E
        and     #$01                            ; 80A0
        beq     L80EE                           ; 80A2
        lda     $059C                           ; 80A4
        jsr     LC257                           ; 80A7
        lda     #$34                            ; 80AA
        jsr     LCFA1                           ; 80AC
        lda     $05C7                           ; 80AF
        jsr     LC6F3                           ; 80B2
        lda     $0510,y                         ; 80B5
        and     #$0E                            ; 80B8
        beq     L80BF                           ; 80BA
        jmp     LA13F                           ; 80BC

; ----------------------------------------------------------------------------
L80BF:  lda     $0510,y                         ; 80BF
        ora     #$02                            ; 80C2
        sta     $0510,y                         ; 80C4
        lda     #$03                            ; 80C7
        sta     $0513,y                         ; 80C9
        ldx     $05C7                           ; 80CC
        lda     $1E                             ; 80CF
        and     #$01                            ; 80D1
        sta     $058C,x                         ; 80D3
        clc                                     ; 80D6
        adc     #$04                            ; 80D7
        tax                                     ; 80D9
        lda     $05C7                           ; 80DA
        jsr     LC13B                           ; 80DD
        jsr     LCEAF                           ; 80E0
        lda     #$13                            ; 80E3
        jsr     LCFA1                           ; 80E5
        jsr     LCEAF                           ; 80E8
        jmp     LA13F                           ; 80EB

; ----------------------------------------------------------------------------
L80EE:  lda     $50                             ; 80EE
        and     #$0E                            ; 80F0
        bne     L80FF                           ; 80F2
        lda     $059C                           ; 80F4
        sta     $05C6                           ; 80F7
        jsr     LCC43                           ; 80FA
        bcs     L8107                           ; 80FD
L80FF:  lda     #$07                            ; 80FF
        jsr     LCFA1                           ; 8101
        jmp     LA13F                           ; 8104

; ----------------------------------------------------------------------------
L8107:  lda     $059C                           ; 8107
        jsr     LC6F3                           ; 810A
        lda     $054F,y                         ; 810D
        ora     #$02                            ; 8110
        sta     $054F,y                         ; 8112
        lda     #$03                            ; 8115
        sta     $0552,y                         ; 8117
        ldx     $059C                           ; 811A
        lda     $E0,x                           ; 811D
        and     #$03                            ; 811F
        sta     $0505                           ; 8121
        sta     $0593,x                         ; 8124
        clc                                     ; 8127
        adc     #$04                            ; 8128
        tax                                     ; 812A
        lda     $059C                           ; 812B
        jsr     LC0C4                           ; 812E
        lda     #$13                            ; 8131
        ldx     $0505                           ; 8133
        cpx     #$02                            ; 8136
        bcc     L813C                           ; 8138
        lda     #$17                            ; 813A
L813C:  jsr     LCFA1                           ; 813C
        inc     $059C                           ; 813F
        lda     $059C                           ; 8142
        cmp     #$07                            ; 8145
        beq     L814C                           ; 8147
        jmp     LA080                           ; 8149

; ----------------------------------------------------------------------------
L814C:  ldx     #$00                            ; 814C
        stx     $059A                           ; 814E
        stx     $059B                           ; 8151
        stx     $059C                           ; 8154
L8157:  lda     $0593,x                         ; 8157
        beq     L817F                           ; 815A
        cmp     #$02                            ; 815C
        bcc     L817F                           ; 815E
        sbc     #$02                            ; 8160
        tax                                     ; 8162
        inc     $059A,x                         ; 8163
        ldx     #$02                            ; 8166
        lda     $059C                           ; 8168
        jsr     LC0C4                           ; 816B
        lda     $059C                           ; 816E
        jsr     LC52E                           ; 8171
        lda     $059C                           ; 8174
        jsr     LC6F3                           ; 8177
        lda     #$FF                            ; 817A
        sta     $054D,y                         ; 817C
L817F:  inc     $059C                           ; 817F
        ldx     $059C                           ; 8182
        cpx     #$07                            ; 8185
        bne     L8157                           ; 8187
        lda     #$00                            ; 8189
        sta     $0500                           ; 818B
        sta     $00                             ; 818E
        sta     $01                             ; 8190
        sta     $0503                           ; 8192
        ldx     $059A                           ; 8195
        beq     L81CC                           ; 8198
L819A:  clc                                     ; 819A
        lda     $00                             ; 819B
        adc     #$32                            ; 819D
        sta     $00                             ; 819F
        lda     $01                             ; 81A1
        adc     #$00                            ; 81A3
        sta     $01                             ; 81A5
        dex                                     ; 81A7
        bne     L819A                           ; 81A8
        clc                                     ; 81AA
        lda     $81                             ; 81AB
        adc     $00                             ; 81AD
        sta     $00                             ; 81AF
        sta     $81                             ; 81B1
        lda     #$00                            ; 81B3
        adc     $01                             ; 81B5
        beq     L81BD                           ; 81B7
        lda     #$FF                            ; 81B9
        sta     $81                             ; 81BB
L81BD:  lda     #$00                            ; 81BD
        jsr     LCA62                           ; 81BF
        lda     #$00                            ; 81C2
        jsr     LC5A9                           ; 81C4
        lda     #$43                            ; 81C7
        jsr     LCFA1                           ; 81C9
L81CC:  jsr     LC9A7                           ; 81CC
        lda     #$00                            ; 81CF
        sta     $00                             ; 81D1
        sta     $01                             ; 81D3
        ldx     $059B                           ; 81D5
        beq     L821A                           ; 81D8
L81DA:  clc                                     ; 81DA
        lda     #$32                            ; 81DB
        adc     $00                             ; 81DD
        sta     $00                             ; 81DF
        lda     #$00                            ; 81E1
        adc     $01                             ; 81E3
        sta     $01                             ; 81E5
        dex                                     ; 81E7
        bne     L81DA                           ; 81E8
        clc                                     ; 81EA
        lda     $02                             ; 81EB
        adc     $00                             ; 81ED
        sta     $00                             ; 81EF
        lda     #$00                            ; 81F1
        adc     $01                             ; 81F3
        sta     $01                             ; 81F5
        beq     L81FD                           ; 81F7
        lda     #$FF                            ; 81F9
        sta     $00                             ; 81FB
L81FD:  lda     $00                             ; 81FD
        jsr     LCE39                           ; 81FF
        ldx     #$02                            ; 8202
L8204:  lda     $0D,x                           ; 8204
        sta     $8C,x                           ; 8206
        dex                                     ; 8208
        bpl     L8204                           ; 8209
        lda     #$00                            ; 820B
        jsr     LCA9A                           ; 820D
        lda     #$00                            ; 8210
        jsr     LC612                           ; 8212
        lda     #$44                            ; 8215
        jsr     LCFA1                           ; 8217
L821A:  rts                                     ; 821A

; ----------------------------------------------------------------------------
        lda     #$00                            ; 821B
        jsr     LA553                           ; 821D
        jsr     LCF43                           ; 8220
        lda     #$7F                            ; 8223
        jsr     LE992                           ; 8225
        lda     $0500                           ; 8228
        jsr     LCF25                           ; 822B
        txa                                     ; 822E
        ldx     #$08                            ; 822F
        jsr     LC13B                           ; 8231
        lda     $05C7                           ; 8234
        jsr     LC6F3                           ; 8237
        lda     $0510,y                         ; 823A
        ora     #$01                            ; 823D
        sta     $0510,y                         ; 823F
        lda     #$03                            ; 8242
        sta     $0511,y                         ; 8244
        lda     #$15                            ; 8247
        jsr     LCFA1                           ; 8249
        rts                                     ; 824C

; ----------------------------------------------------------------------------
        lda     #$00                            ; 824D
        jsr     LA553                           ; 824F
        jsr     LCF43                           ; 8252
        lda     #$06                            ; 8255
        sta     $01                             ; 8257
L8259:  lda     $01                             ; 8259
        jsr     LC6F3                           ; 825B
        lda     $054D,y                         ; 825E
        cmp     #$FF                            ; 8261
        beq     L826C                           ; 8263
        lda     $054F,y                         ; 8265
        and     #$10                            ; 8268
        bne     L8276                           ; 826A
L826C:  dec     $01                             ; 826C
        bpl     L8259                           ; 826E
L8270:  lda     #$50                            ; 8270
        jsr     LCFA1                           ; 8272
        rts                                     ; 8275

; ----------------------------------------------------------------------------
L8276:  lda     $054D,y                         ; 8276
        sta     $0503                           ; 8279
        jsr     LCC43                           ; 827C
        bcc     L8270                           ; 827F
        jsr     LBBBA                           ; 8281
        lda     #$19                            ; 8284
        jsr     LCFA1                           ; 8286
        rts                                     ; 8289

; ----------------------------------------------------------------------------
        lda     #$00                            ; 828A
        jsr     LA553                           ; 828C
        jsr     LCF43                           ; 828F
        lda     $05D3                           ; 8292
        bne     L82B3                           ; 8295
        lda     #$7F                            ; 8297
        jsr     LE992                           ; 8299
        jsr     LC223                           ; 829C
        lda     #$20                            ; 829F
        jsr     LB8F9                           ; 82A1
        lda     #$00                            ; 82A4
        sta     $0500                           ; 82A6
        lda     #$18                            ; 82A9
        jsr     LCFA1                           ; 82AB
        lda     #$01                            ; 82AE
        sta     $05D3                           ; 82B0
L82B3:  rts                                     ; 82B3

; ----------------------------------------------------------------------------
        jsr     LCB16                           ; 82B4
        lda     #$1A                            ; 82B7
        jsr     LCFA1                           ; 82B9
        jsr     LCB8F                           ; 82BC
        beq     L82C7                           ; 82BF
        lda     #$32                            ; 82C1
        jsr     LCFA1                           ; 82C3
        rts                                     ; 82C6

; ----------------------------------------------------------------------------
L82C7:  jsr     LCF43                           ; 82C7
        lda     #$00                            ; 82CA
        sta     $059A                           ; 82CC
        sta     $059B                           ; 82CF
L82D2:  jsr     LC6F3                           ; 82D2
        sty     $52                             ; 82D5
        lda     $050E,y                         ; 82D7
        cmp     #$FF                            ; 82DA
        beq     L830F                           ; 82DC
        sta     $0503                           ; 82DE
        ldx     #$4A                            ; 82E1
        lda     $0510,y                         ; 82E3
        and     #$0E                            ; 82E6
        beq     L8301                           ; 82E8
        ldx     #$0C                            ; 82EA
        lda     $059A                           ; 82EC
        jsr     LC13B                           ; 82EF
        ldy     $52                             ; 82F2
        lda     $0510,y                         ; 82F4
        and     #$F1                            ; 82F7
        sta     $0510,y                         ; 82F9
        ldx     #$49                            ; 82FC
        inc     $059B                           ; 82FE
L8301:  lda     $050E,y                         ; 8301
        sta     $0500                           ; 8304
        txa                                     ; 8307
        cmp     #$49                            ; 8308
        bne     L830F                           ; 830A
        jsr     LCFA1                           ; 830C
L830F:  inc     $059A                           ; 830F
        lda     $059A                           ; 8312
        cmp     #$03                            ; 8315
        bne     L82D2                           ; 8317
        lda     $059B                           ; 8319
        bne     L8323                           ; 831C
        lda     #$4A                            ; 831E
        jsr     LCFA1                           ; 8320
L8323:  rts                                     ; 8323

; ----------------------------------------------------------------------------
        jsr     LCB16                           ; 8324
        lda     #$26                            ; 8327
        jsr     LCFA1                           ; 8329
        jsr     LCB8F                           ; 832C
        beq     L8337                           ; 832F
        lda     #$32                            ; 8331
        jsr     LCFA1                           ; 8333
        rts                                     ; 8336

; ----------------------------------------------------------------------------
L8337:  lda     $1E                             ; 8337
        and     #$01                            ; 8339
        tax                                     ; 833B
        jsr     LC6F3                           ; 833C
        lda     $050E,y                         ; 833F
        cmp     #$FF                            ; 8342
        bne     L834F                           ; 8344
        dex                                     ; 8346
        bpl     L834B                           ; 8347
        ldx     #$02                            ; 8349
L834B:  txa                                     ; 834B
        jmp     LA33C                           ; 834C

; ----------------------------------------------------------------------------
L834F:  sta     $0503                           ; 834F
        lda     #$00                            ; 8352
        sta     $0504                           ; 8354
        lda     #$0A                            ; 8357
        sta     $0505                           ; 8359
        stx     $51                             ; 835C
        jsr     LCF43                           ; 835E
        lda     $0503                           ; 8361
        bne     L8380                           ; 8364
        jsr     LC9A7                           ; 8366
        clc                                     ; 8369
        lda     $02                             ; 836A
        adc     #$0A                            ; 836C
        bcc     L8372                           ; 836E
        lda     #$FF                            ; 8370
L8372:  jsr     LCE39                           ; 8372
        ldx     #$02                            ; 8375
L8377:  lda     $0D,x                           ; 8377
        sta     $8C,x                           ; 8379
        dex                                     ; 837B
        bpl     L8377                           ; 837C
        bmi     L838F                           ; 837E
L8380:  asl     a                               ; 8380
        tax                                     ; 8381
        lda     $03BF,x                         ; 8382
        clc                                     ; 8385
        adc     #$0A                            ; 8386
        bcc     L838C                           ; 8388
        lda     #$FF                            ; 838A
L838C:  sta     $03BF,x                         ; 838C
L838F:  lda     $51                             ; 838F
        jsr     LCA9A                           ; 8391
        lda     $51                             ; 8394
        jsr     LC612                           ; 8396
        lda     #$25                            ; 8399
        jsr     LCFA1                           ; 839B
        rts                                     ; 839E

; ----------------------------------------------------------------------------
        jsr     LCB16                           ; 839F
        jsr     LCB8F                           ; 83A2
        beq     L83AD                           ; 83A5
        lda     #$32                            ; 83A7
        jsr     LCFA1                           ; 83A9
        rts                                     ; 83AC

; ----------------------------------------------------------------------------
L83AD:  jsr     L99BF                           ; 83AD
        bpl     L83B3                           ; 83B0
        rts                                     ; 83B2

; ----------------------------------------------------------------------------
L83B3:  stx     $51                             ; 83B3
        txa                                     ; 83B5
        jsr     LC6F3                           ; 83B6
        lda     $054F,y                         ; 83B9
        and     #$10                            ; 83BC
        bne     L83EE                           ; 83BE
        jsr     LBBDB                           ; 83C0
        ldx     $03F4                           ; 83C3
        bne     L83CB                           ; 83C6
        asl     a                               ; 83C8
        bne     L83D5                           ; 83C9
L83CB:  cpx     #$08                            ; 83CB
        bne     L83D5                           ; 83CD
        sta     $01                             ; 83CF
        lsr     a                               ; 83D1
        clc                                     ; 83D2
        adc     $01                             ; 83D3
L83D5:  ldx     $05CE                           ; 83D5
        cpx     #$03                            ; 83D8
        bcc     L83E2                           ; 83DA
        sta     $01                             ; 83DC
        lsr     a                               ; 83DE
        clc                                     ; 83DF
        adc     $01                             ; 83E0
L83E2:  sta     $0505                           ; 83E2
        ldx     $51                             ; 83E5
        clc                                     ; 83E7
        adc     $0593,x                         ; 83E8
        sta     $0593,x                         ; 83EB
L83EE:  ldx     $51                             ; 83EE
        lda     $0467,x                         ; 83F0
        bne     L83FE                           ; 83F3
        lda     $059D                           ; 83F5
        sta     $0467,x                         ; 83F8
        inc     $059D                           ; 83FB
L83FE:  ldx     #$04                            ; 83FE
        lda     $0502                           ; 8400
        cmp     #$24                            ; 8403
        beq     L8409                           ; 8405
        ldx     #$05                            ; 8407
L8409:  txa                                     ; 8409
        ldx     $05D9                           ; 840A
        bne     L8414                           ; 840D
        ldx     #$01                            ; 840F
        stx     $05D9                           ; 8411
L8414:  jsr     LCFA1                           ; 8414
        rts                                     ; 8417

; ----------------------------------------------------------------------------
        jsr     LCB16                           ; 8418
        lda     #$02                            ; 841B
        sta     $059C                           ; 841D
        jsr     LCB8F                           ; 8420
        beq     L842B                           ; 8423
        lda     #$32                            ; 8425
        jsr     LCFA1                           ; 8427
L842A:  rts                                     ; 842A

; ----------------------------------------------------------------------------
L842B:  jsr     L99BF                           ; 842B
        bmi     L842A                           ; 842E
        lda     #$03                            ; 8430
        jsr     LCFA1                           ; 8432
        lda     $05C6                           ; 8435
        jsr     LC6F3                           ; 8438
        lda     $054F,y                         ; 843B
        sta     $50                             ; 843E
        and     #$04                            ; 8440
        bne     L846B                           ; 8442
        lda     $50                             ; 8444
        and     #$20                            ; 8446
        beq     L8452                           ; 8448
L844A:  lda     #$08                            ; 844A
        jsr     LCFA1                           ; 844C
        jmp     LA4DE                           ; 844F

; ----------------------------------------------------------------------------
L8452:  lda     $50                             ; 8452
        and     #$10                            ; 8454
        beq     L8460                           ; 8456
        lda     #$4C                            ; 8458
        jsr     LCFA1                           ; 845A
        jmp     LA4DE                           ; 845D

; ----------------------------------------------------------------------------
L8460:  lda     $50                             ; 8460
        and     #$04                            ; 8462
        bne     L846B                           ; 8464
        jsr     LCC43                           ; 8466
        bcc     L844A                           ; 8469
L846B:  lda     #$04                            ; 846B
        jsr     LCE8D                           ; 846D
        bcc     L849D                           ; 8470
        lda     #$6E                            ; 8472
        jsr     LE992                           ; 8474
        lda     $05C6                           ; 8477
        jsr     LBB07                           ; 847A
        lda     #$2A                            ; 847D
        jsr     LCFA1                           ; 847F
        lda     $05C6                           ; 8482
        pha                                     ; 8485
        jsr     LB9A1                           ; 8486
        pla                                     ; 8489
        pha                                     ; 848A
        jsr     LBCC8                           ; 848B
        pla                                     ; 848E
        pha                                     ; 848F
        jsr     LB9A1                           ; 8490
        pla                                     ; 8493
        jsr     LBCC8                           ; 8494
        beq     L84B0                           ; 8497
        asl     $01                             ; 8499
        bne     L84D4                           ; 849B
L849D:  lda     $05C6                           ; 849D
        jsr     LBB00                           ; 84A0
        lda     $05C6                           ; 84A3
        pha                                     ; 84A6
        jsr     LB9A1                           ; 84A7
        pla                                     ; 84AA
        jsr     LBCC8                           ; 84AB
        bne     L84D4                           ; 84AE
L84B0:  lda     $05C6                           ; 84B0
        ldx     #$00                            ; 84B3
        jsr     LC0C4                           ; 84B5
        lda     #$09                            ; 84B8
        jsr     LCFA1                           ; 84BA
        lda     $05C6                           ; 84BD
        jsr     LC6F3                           ; 84C0
        sty     $52                             ; 84C3
        lda     $054D,y                         ; 84C5
        jsr     LCAE1                           ; 84C8
        ldy     $52                             ; 84CB
        lda     #$FF                            ; 84CD
        sta     $054D,y                         ; 84CF
        bne     L84DE                           ; 84D2
L84D4:  lda     $01                             ; 84D4
        sta     $0505                           ; 84D6
        lda     #$06                            ; 84D9
        jsr     LCFA1                           ; 84DB
L84DE:  lda     $0500                           ; 84DE
        cmp     #$0A                            ; 84E1
        bne     L84ED                           ; 84E3
        dec     $059C                           ; 84E5
        beq     L84ED                           ; 84E8
        jmp     LA42B                           ; 84EA

; ----------------------------------------------------------------------------
L84ED:  rts                                     ; 84ED

; ----------------------------------------------------------------------------
        lda     #$00                            ; 84EE
        sta     $0500                           ; 84F0
        lda     #$47                            ; 84F3
        jsr     LCFA1                           ; 84F5
        lda     #$00                            ; 84F8
        jsr     LE992                           ; 84FA
        jsr     LB74C                           ; 84FD
        lda     #$0C                            ; 8500
        sta     $0500                           ; 8502
        lda     #$48                            ; 8505
        jsr     LCFA1                           ; 8507
        lda     #$FF                            ; 850A
        sta     $05A0                           ; 850C
        rts                                     ; 850F

; ----------------------------------------------------------------------------
        lda     #$00                            ; 8510
        sta     $0500                           ; 8512
        jsr     LA537                           ; 8515
        bcc     L852A                           ; 8518
L851A:  lda     #$0F                            ; 851A
        jsr     LCFA1                           ; 851C
        lda     #$FF                            ; 851F
        ldx     #$0D                            ; 8521
L8523:  sta     $05A0,x                         ; 8523
        dex                                     ; 8526
        bpl     L8523                           ; 8527
        rts                                     ; 8529

; ----------------------------------------------------------------------------
L852A:  lda     $0510                           ; 852A
        and     #$0C                            ; 852D
        bne     L851A                           ; 852F
        lda     #$01                            ; 8531
        sta     $0506                           ; 8533
        rts                                     ; 8536

; ----------------------------------------------------------------------------
        lda     $03F4                           ; 8537
        beq     L8540                           ; 853A
        cmp     #$08                            ; 853C
        bne     L8542                           ; 853E
L8540:  clc                                     ; 8540
        rts                                     ; 8541

; ----------------------------------------------------------------------------
L8542:  lda     $05CE                           ; 8542
        cmp     #$03                            ; 8545
        bcc     L854F                           ; 8547
        lda     #$02                            ; 8549
        jsr     LCE8D                           ; 854B
        rts                                     ; 854E

; ----------------------------------------------------------------------------
L854F:  jsr     LC8B0                           ; 854F
        rts                                     ; 8552

; ----------------------------------------------------------------------------
        pha                                     ; 8553
        jsr     LCB16                           ; 8554
        pla                                     ; 8557
        beq     L8562                           ; 8558
        jsr     L99BF                           ; 855A
        bpl     L8562                           ; 855D
        pla                                     ; 855F
        pla                                     ; 8560
L8561:  rts                                     ; 8561

; ----------------------------------------------------------------------------
L8562:  lda     $05C7                           ; 8562
        jsr     LC793                           ; 8565
        lda     #$02                            ; 8568
        ldx     $0502                           ; 856A
        cpx     #$10                            ; 856D
        bne     L8573                           ; 856F
        lda     #$1E                            ; 8571
L8573:  jsr     LCFA1                           ; 8573
        lda     $0502                           ; 8576
        cmp     #$0C                            ; 8579
        beq     L858B                           ; 857B
        cmp     #$0D                            ; 857D
        beq     L858B                           ; 857F
        cmp     #$0E                            ; 8581
        beq     L858B                           ; 8583
        lda     $05C7                           ; 8585
        jsr     LC762                           ; 8588
L858B:  jsr     LCB83                           ; 858B
        beq     L8561                           ; 858E
        lda     #$33                            ; 8590
        jsr     LCFA1                           ; 8592
        pla                                     ; 8595
        pla                                     ; 8596
        rts                                     ; 8597

; ----------------------------------------------------------------------------
        lda     #$00                            ; 8598
        sta     $059C                           ; 859A
L859D:  jsr     LC6F3                           ; 859D
        sty     $52                             ; 85A0
        lda     $054D,y                         ; 85A2
        cmp     #$FF                            ; 85A5
        beq     L8607                           ; 85A7
        sta     $0503                           ; 85A9
        lda     $054E,y                         ; 85AC
        sta     $0504                           ; 85AF
        lda     $0502                           ; 85B2
        cmp     #$02                            ; 85B5
        bne     L85BF                           ; 85B7
        lda     $059C                           ; 85B9
        jsr     LBB00                           ; 85BC
L85BF:  ldy     $52                             ; 85BF
        lda     $0555,y                         ; 85C1
        sec                                     ; 85C4
        sbc     $05D1                           ; 85C5
        bpl     L85CC                           ; 85C8
        lda     #$00                            ; 85CA
L85CC:  sta     $0555,y                         ; 85CC
        pha                                     ; 85CF
        lda     $059C                           ; 85D0
        jsr     LC551                           ; 85D3
        pla                                     ; 85D6
        bne     L8604                           ; 85D7
        lda     $0502                           ; 85D9
        cmp     #$02                            ; 85DC
        bne     L85E9                           ; 85DE
        lda     $059C                           ; 85E0
        jsr     LC52E                           ; 85E3
        jmp     LA5F2                           ; 85E6

; ----------------------------------------------------------------------------
L85E9:  lda     $059C                           ; 85E9
        ldx     $046F                           ; 85EC
        jsr     LC0C4                           ; 85EF
        ldy     $52                             ; 85F2
        lda     $054D,y                         ; 85F4
        jsr     LCAE1                           ; 85F7
        ldy     $52                             ; 85FA
        lda     #$FF                            ; 85FC
        sta     $054D,y                         ; 85FE
        jmp     LA607                           ; 8601

; ----------------------------------------------------------------------------
L8604:  jsr     LCAFA                           ; 8604
L8607:  .byte   $EE                             ; 8607
L8608:  .byte   $9C                             ; 8608
        ora     $AD                             ; 8609
        .byte   $9C                             ; 860B
        ora     $C9                             ; 860C
        .byte   $07                             ; 860E
        bne     L859D                           ; 860F
        jsr     LCA04                           ; 8611
        beq     L8619                           ; 8614
        jsr     LCA30                           ; 8616
L8619:  rts                                     ; 8619

; ----------------------------------------------------------------------------
        lda     $059C                           ; 861A
        jsr     LC6F3                           ; 861D
        sty     $52                             ; 8620
        lda     $054D,y                         ; 8622
        cmp     #$FF                            ; 8625
        beq     L8644                           ; 8627
        lda     $054F,y                         ; 8629
        and     #$10                            ; 862C
        beq     L8645                           ; 862E
        lda     $0502                           ; 8630
        cmp     #$0B                            ; 8633
        beq     L863F                           ; 8635
        cmp     #$0C                            ; 8637
        bcc     L8644                           ; 8639
        cmp     #$0F                            ; 863B
        bcc     L8644                           ; 863D
L863F:  lda     #$07                            ; 863F
        jsr     LCFA1                           ; 8641
L8644:  rts                                     ; 8644

; ----------------------------------------------------------------------------
L8645:  lda     $054F,y                         ; 8645
        and     #$01                            ; 8648
        bne     L864F                           ; 864A
        jmp     LA6E7                           ; 864C

; ----------------------------------------------------------------------------
L864F:  lda     $059C                           ; 864F
        jsr     LC257                           ; 8652
        lda     #$34                            ; 8655
        jsr     LCFA1                           ; 8657
        jsr     LCBD7                           ; 865A
        bne     L8668                           ; 865D
        ldx     $05C7                           ; 865F
        stx     $05D5                           ; 8662
        jmp     LA66E                           ; 8665

; ----------------------------------------------------------------------------
L8668:  jsr     LCBEF                           ; 8668
        beq     L866E                           ; 866B
        rts                                     ; 866D

; ----------------------------------------------------------------------------
L866E:  stx     $05D5                           ; 866E
        stx     $51                             ; 8671
        txa                                     ; 8673
        sec                                     ; 8674
        sbc     #$03                            ; 8675
        bcs     L8680                           ; 8677
        txa                                     ; 8679
        jsr     LBC14                           ; 867A
        jmp     LA683                           ; 867D

; ----------------------------------------------------------------------------
L8680:  jsr     LBAD0                           ; 8680
        jsr     LCEAF                           ; 8683
        lda     $51                             ; 8686
        jsr     LBC43                           ; 8688
        jsr     LCEAF                           ; 868B
        bne     L86D0                           ; 868E
        lda     $046F                           ; 8690
        bne     L86AA                           ; 8693
        lda     $51                             ; 8695
        sec                                     ; 8697
        sbc     #$03                            ; 8698
        bcs     L86A4                           ; 869A
        lda     $51                             ; 869C
        jsr     LB7E9                           ; 869E
        jmp     LA6B2                           ; 86A1

; ----------------------------------------------------------------------------
L86A4:  jsr     LB7A9                           ; 86A4
        jmp     LA6B2                           ; 86A7

; ----------------------------------------------------------------------------
L86AA:  lda     $51                             ; 86AA
        ldx     $046F                           ; 86AC
        jsr     LC13B                           ; 86AF
        jsr     LCEFA                           ; 86B2
        lda     #$45                            ; 86B5
        ldx     $51                             ; 86B7
        cpx     #$03                            ; 86B9
        bcs     L86BF                           ; 86BB
        lda     #$0C                            ; 86BD
L86BF:  jsr     LCFA1                           ; 86BF
        jsr     LCF18                           ; 86C2
        lda     $51                             ; 86C5
        jsr     LC6F3                           ; 86C7
        lda     #$FF                            ; 86CA
        sta     $050E,y                         ; 86CC
        rts                                     ; 86CF

; ----------------------------------------------------------------------------
L86D0:  lda     $51                             ; 86D0
        cmp     #$03                            ; 86D2
        bcs     L86E6                           ; 86D4
        lda     $046E                           ; 86D6
        bne     L86E6                           ; 86D9
        jsr     LCEFA                           ; 86DB
        lda     #$06                            ; 86DE
        jsr     LCFA1                           ; 86E0
        jsr     LCF18                           ; 86E3
L86E6:  rts                                     ; 86E6

; ----------------------------------------------------------------------------
        jsr     LCC43                           ; 86E7
        bcs     L86F2                           ; 86EA
        lda     #$07                            ; 86EC
        jsr     LCFA1                           ; 86EE
        clc                                     ; 86F1
L86F2:  bcc     L8716                           ; 86F2
        inc     $059E                           ; 86F4
        lda     $059C                           ; 86F7
        jsr     LBB00                           ; 86FA
        lda     $059C                           ; 86FD
        jsr     LBCC8                           ; 8700
        beq     L8717                           ; 8703
        lda     $046E                           ; 8705
        bne     L8716                           ; 8708
        lda     $0502                           ; 870A
        cmp     #$0F                            ; 870D
        bcs     L8716                           ; 870F
        lda     #$06                            ; 8711
        jsr     LCFA1                           ; 8713
L8716:  rts                                     ; 8716

; ----------------------------------------------------------------------------
L8717:  lda     $059C                           ; 8717
        ldx     $046F                           ; 871A
        bpl     L8725                           ; 871D
        jsr     LC52E                           ; 871F
        jmp     LA728                           ; 8722

; ----------------------------------------------------------------------------
L8725:  jsr     LC0C4                           ; 8725
        lda     $0502                           ; 8728
        cmp     #$0F                            ; 872B
        bcs     L8734                           ; 872D
        lda     #$09                            ; 872F
        jsr     LCFA1                           ; 8731
L8734:  lda     $059C                           ; 8734
        jsr     LC6F3                           ; 8737
        sty     $52                             ; 873A
        lda     $054D,y                         ; 873C
        jsr     LCAE1                           ; 873F
        ldy     $52                             ; 8742
        lda     #$FF                            ; 8744
        sta     $054D,y                         ; 8746
        rts                                     ; 8749

; ----------------------------------------------------------------------------
        sty     $52                             ; 874A
        tya                                     ; 874C
        lda     $054F,y                         ; 874D
        sta     $51                             ; 8750
        and     #$01                            ; 8752
        beq     L8775                           ; 8754
        lda     $059D                           ; 8756
        jsr     LC257                           ; 8759
        lda     #$34                            ; 875C
        jsr     LCFA1                           ; 875E
        jsr     LCBD7                           ; 8761
        bne     L87B6                           ; 8764
        lda     $0502                           ; 8766
        cmp     #$12                            ; 8769
        bne     L87DB                           ; 876B
        lda     $0510,y                         ; 876D
        and     #$04                            ; 8770
        beq     L87DB                           ; 8772
        rts                                     ; 8774

; ----------------------------------------------------------------------------
L8775:  lda     $51                             ; 8775
        and     $046E                           ; 8777
        bne     L8786                           ; 877A
        jsr     LCC43                           ; 877C
        bcs     L8787                           ; 877F
        lda     #$07                            ; 8781
        jsr     LCFA1                           ; 8783
L8786:  rts                                     ; 8786

; ----------------------------------------------------------------------------
L8787:  ldx     $046F                           ; 8787
        lda     $51                             ; 878A
        and     $0472                           ; 878C
        beq     L8793                           ; 878F
        ldx     #$09                            ; 8791
L8793:  lda     $059D                           ; 8793
        jsr     LC0C4                           ; 8796
        lda     $0470                           ; 8799
        jsr     LCFA1                           ; 879C
        ldy     $52                             ; 879F
        lda     $054F,y                         ; 87A1
        ora     $046E                           ; 87A4
        sta     $054F,y                         ; 87A7
        tya                                     ; 87AA
        clc                                     ; 87AB
        adc     $0471                           ; 87AC
        tay                                     ; 87AF
        lda     #$03                            ; 87B0
        sta     $054D,y                         ; 87B2
        rts                                     ; 87B5

; ----------------------------------------------------------------------------
L87B6:  ldx     #$02                            ; 87B6
L87B8:  txa                                     ; 87B8
        jsr     LC6F3                           ; 87B9
        lda     $050E,y                         ; 87BC
        cmp     #$FF                            ; 87BF
        beq     L87D7                           ; 87C1
        cpx     $05C7                           ; 87C3
        beq     L87D7                           ; 87C6
        lda     $0510,y                         ; 87C8
        and     #$08                            ; 87CB
        bne     L87D7                           ; 87CD
        lda     $0510,y                         ; 87CF
        and     $046E                           ; 87D2
        beq     L87DE                           ; 87D5
L87D7:  dex                                     ; 87D7
        bpl     L87B8                           ; 87D8
        rts                                     ; 87DA

; ----------------------------------------------------------------------------
L87DB:  ldx     $05C7                           ; 87DB
L87DE:  stx     $51                             ; 87DE
        sty     $52                             ; 87E0
        ldx     $046F                           ; 87E2
        lda     $0510,y                         ; 87E5
        and     $0472                           ; 87E8
        beq     L87EF                           ; 87EB
        ldx     #$09                            ; 87ED
L87EF:  lda     $51                             ; 87EF
        jsr     LC13B                           ; 87F1
        jsr     LCEAF                           ; 87F4
        ldy     $52                             ; 87F7
        lda     $050E,y                         ; 87F9
        sta     $0503                           ; 87FC
        lda     $0470                           ; 87FF
        jsr     LCFA1                           ; 8802
        jsr     LCEAF                           ; 8805
        ldy     $52                             ; 8808
        lda     $0510,y                         ; 880A
        ora     $046E                           ; 880D
        sta     $0510,y                         ; 8810
        tya                                     ; 8813
        clc                                     ; 8814
        adc     $0471                           ; 8815
        tay                                     ; 8818
        lda     #$03                            ; 8819
        sta     $050E,y                         ; 881B
        rts                                     ; 881E

; ----------------------------------------------------------------------------
        jsr     LCECC                           ; 881F
        lda     $01                             ; 8822
        sta     $059D                           ; 8824
        lda     #$00                            ; 8827
        sta     $059E                           ; 8829
        sta     $059F                           ; 882C
        lda     $05C8                           ; 882F
        jsr     LC6F3                           ; 8832
        lda     $0502                           ; 8835
        cmp     #$03                            ; 8838
        bne     L8881                           ; 883A
        lda     $054D,y                         ; 883C
        cmp     #$10                            ; 883F
        beq     L884C                           ; 8841
L8843:  jsr     LC929                           ; 8843
        beq     L88A0                           ; 8846
        jsr     LC996                           ; 8848
        rts                                     ; 884B

; ----------------------------------------------------------------------------
L884C:  jsr     LCCF1                           ; 884C
        jsr     LCBA7                           ; 884F
        beq     L885A                           ; 8852
L8854:  lda     #$33                            ; 8854
        jsr     LCFA1                           ; 8856
        rts                                     ; 8859

; ----------------------------------------------------------------------------
L885A:  lda     #$36                            ; 885A
        jsr     LCFA1                           ; 885C
        jsr     LA8BE                           ; 885F
        lda     #$10                            ; 8862
        sta     $0500                           ; 8864
        jsr     LCEAF                           ; 8867
        lda     #$0C                            ; 886A
        jsr     LCFA1                           ; 886C
        lda     $05C8                           ; 886F
        jsr     LC52E                           ; 8872
        lda     $05C8                           ; 8875
        jsr     LC6F3                           ; 8878
        lda     #$FF                            ; 887B
        sta     $054D,y                         ; 887D
        rts                                     ; 8880

; ----------------------------------------------------------------------------
L8881:  cmp     #$01                            ; 8881
        bne     L8843                           ; 8883
        lda     $054D,y                         ; 8885
        cmp     #$1A                            ; 8888
        beq     L8890                           ; 888A
        cmp     #$1B                            ; 888C
        bne     L8843                           ; 888E
L8890:  jsr     LCCF1                           ; 8890
        jsr     LCBA7                           ; 8893
        bne     L8854                           ; 8896
        lda     #$02                            ; 8898
        jsr     LCFA1                           ; 889A
        jmp     LA8BE                           ; 889D

; ----------------------------------------------------------------------------
L88A0:  jsr     LCECC                           ; 88A0
        lda     $01                             ; 88A3
        sta     $059D                           ; 88A5
        lda     #$00                            ; 88A8
        sta     $059E                           ; 88AA
        sta     $059F                           ; 88AD
        lda     $05D4                           ; 88B0
        sta     $0500                           ; 88B3
        lda     #$37                            ; 88B6
        jsr     LCFA1                           ; 88B8
        jsr     LCF43                           ; 88BB
        lda     #$00                            ; 88BE
        sta     $5F                             ; 88C0
        jsr     LCD8E                           ; 88C2
        sta     $5E                             ; 88C5
        ldx     $0502                           ; 88C7
        dex                                     ; 88CA
        txa                                     ; 88CB
        jsr     LE97D                           ; 88CC
        .byte   $DB                             ; 88CF
        tay                                     ; 88D0
        ror     a                               ; 88D1
        lda     #$82                            ; 88D2
        lda     #$AC                            ; 88D4
        tax                                     ; 88D6
        dec     $F0AA                           ; 88D7
        tax                                     ; 88DA
        lda     #$77                            ; 88DB
        jsr     LE992                           ; 88DD
        lda     #$01                            ; 88E0
        jsr     LE029                           ; 88E2
        lda     #$77                            ; 88E5
        jsr     LE992                           ; 88E7
        jsr     LC02C                           ; 88EA
        lda     $0502                           ; 88ED
        jsr     LCE00                           ; 88F0
        lda     #$03                            ; 88F3
        sta     $059C                           ; 88F5
        lda     $059C                           ; 88F8
        jsr     LC6F3                           ; 88FB
        lda     $050E,y                         ; 88FE
        cmp     #$FF                            ; 8901
        beq     L8950                           ; 8903
        sta     $0503                           ; 8905
        tay                                     ; 8908
        iny                                     ; 8909
        lda     ($58),y                         ; 890A
        tay                                     ; 890C
        and     #$07                            ; 890D
        tax                                     ; 890F
        tya                                     ; 8910
        and     #$08                            ; 8911
        beq     L8919                           ; 8913
        txa                                     ; 8915
        ora     #$80                            ; 8916
        tax                                     ; 8918
L8919:  txa                                     ; 8919
        jsr     LCE8D                           ; 891A
        bcc     L8950                           ; 891D
        inc     $059E                           ; 891F
        lda     $059C                           ; 8922
        cmp     #$03                            ; 8925
        bcc     L8939                           ; 8927
        sbc     #$03                            ; 8929
        sta     $50                             ; 892B
        jsr     LBAD0                           ; 892D
        lda     $50                             ; 8930
        jsr     LB7A9                           ; 8932
        inc     $5F                             ; 8935
        bne     L8945                           ; 8937
L8939:  jsr     LBC14                           ; 8939
        lda     $059C                           ; 893C
        jsr     LB7E9                           ; 893F
        jsr     LCDA5                           ; 8942
L8945:  lda     $059C                           ; 8945
        jsr     LC6F3                           ; 8948
        lda     #$FF                            ; 894B
        sta     $050E,y                         ; 894D
L8950:  inc     $059C                           ; 8950
        lda     $059C                           ; 8953
        cmp     #$03                            ; 8956
        bne     L895E                           ; 8958
        .byte   $20                             ; 895A
L895B:  .byte   $82                             ; 895B
        tax                                     ; 895C
        rts                                     ; 895D

; ----------------------------------------------------------------------------
L895E:  cmp     #$07                            ; 895E
        bne     L8967                           ; 8960
        lda     #$00                            ; 8962
        sta     $059C                           ; 8964
L8967:  jmp     LA8F8                           ; 8967

; ----------------------------------------------------------------------------
        lda     #$77                            ; 896A
        jsr     LE992                           ; 896C
        lda     #$07                            ; 896F
        jsr     LE029                           ; 8971
        lda     #$77                            ; 8974
        jsr     LE992                           ; 8976
        lda     #$3B                            ; 8979
        sta     $0470                           ; 897B
        jsr     LB29F                           ; 897E
        rts                                     ; 8981

; ----------------------------------------------------------------------------
        lda     #$0E                            ; 8982
        jsr     LE029                           ; 8984
        jsr     LC02C                           ; 8987
        lda     $0502                           ; 898A
        jsr     LCE00                           ; 898D
        lda     #$03                            ; 8990
        sta     $059C                           ; 8992
        lda     #$00                            ; 8995
L8997:  sta     $059E                           ; 8997
        sta     $059F                           ; 899A
L899D:  lda     $059C                           ; 899D
        jsr     LC6F3                           ; 89A0
        lda     $050E,y                         ; 89A3
        cmp     #$FF                            ; 89A6
        beq     L89D1                           ; 89A8
        sta     $0503                           ; 89AA
        jsr     LCCA3                           ; 89AD
        bcc     L89D1                           ; 89B0
        inc     $059E                           ; 89B2
        lda     $059C                           ; 89B5
        jsr     LC6F3                           ; 89B8
        lda     $0510,y                         ; 89BB
        ora     #$40                            ; 89BE
        sta     $0510,y                         ; 89C0
        lda     $059C                           ; 89C3
        cmp     #$03                            ; 89C6
        bcc     L89CC                           ; 89C8
        inc     $5F                             ; 89CA
L89CC:  ldx     #$0A                            ; 89CC
        jsr     LC13B                           ; 89CE
L89D1:  inc     $059C                           ; 89D1
        lda     $059C                           ; 89D4
        cmp     #$07                            ; 89D7
        bne     L89E0                           ; 89D9
        lda     #$00                            ; 89DB
        .byte   $8D                             ; 89DD
L89DE:  .byte   $9C                             ; 89DE
        .byte   $05                             ; 89DF
L89E0:  cmp     #$03                            ; 89E0
        bne     L899D                           ; 89E2
        lda     #$03                            ; 89E4
        sta     $059C                           ; 89E6
L89E9:  jsr     LC6F3                           ; 89E9
        lda     $050E,y                         ; 89EC
        cmp     #$FF                            ; 89EF
        beq     L8A00                           ; 89F1
        lda     $0510,y                         ; 89F3
        and     #$40                            ; 89F6
        beq     L8A00                           ; 89F8
        lda     $059C                           ; 89FA
        jsr     LC1FE                           ; 89FD
L8A00:  .byte   $EE                             ; 8A00
        .byte   $9C                             ; 8A01
L8A02:  ora     $AD                             ; 8A02
        .byte   $9C                             ; 8A04
        ora     $C9                             ; 8A05
        .byte   $07                             ; 8A07
        bne     L8A0F                           ; 8A08
        lda     #$00                            ; 8A0A
        sta     $059C                           ; 8A0C
L8A0F:  cmp     #$03                            ; 8A0F
        bne     L89E9                           ; 8A11
        lda     #$0E                            ; 8A13
        sta     $00                             ; 8A15
        ldy     #$00                            ; 8A17
        ldx     #$04                            ; 8A19
L8A1B:  lda     L8C85,y                         ; 8A1B
        sta     $0620,x                         ; 8A1E
        iny                                     ; 8A21
        lda     L8C85,y                         ; 8A22
        .byte   $9D                             ; 8A25
L8A26:  and     ($06,x)                         ; 8A26
        iny                                     ; 8A28
        txa                                     ; 8A29
        clc                                     ; 8A2A
        adc     #$06                            ; 8A2B
        tax                                     ; 8A2D
        dec     $00                             ; 8A2E
        bne     L8A1B                           ; 8A30
        lda     $059E                           ; 8A32
        beq     L8A48                           ; 8A35
        sta     $01                             ; 8A37
        lda     #$77                            ; 8A39
        jsr     LE992                           ; 8A3B
        lda     #$0C                            ; 8A3E
        jsr     LE029                           ; 8A40
L8A43:  lda     #$77                            ; 8A43
        jsr     LE992                           ; 8A45
L8A48:  lda     #$00                            ; 8A48
        sta     $059C                           ; 8A4A
L8A4D:  jsr     LC6F3                           ; 8A4D
        lda     $050E,y                         ; 8A50
        sta     $0503                           ; 8A53
        cmp     #$FF                            ; 8A56
        beq     L8A78                           ; 8A58
        lda     $0510,y                         ; 8A5A
        and     #$40                            ; 8A5D
        beq     L8A78                           ; 8A5F
        lda     #$FF                            ; 8A61
        sta     $050E,y                         ; 8A63
        lda     #$00                            ; 8A66
        sta     $0510,y                         ; 8A68
        lda     $059C                           ; 8A6B
        cmp     #$03                            ; 8A6E
        bcs     L8A78                           ; 8A70
        lda     $0503                           ; 8A72
        jsr     LCDAE                           ; 8A75
L8A78:  inc     $059C                           ; 8A78
        lda     $059C                           ; 8A7B
        cmp     #$07                            ; 8A7E
        bne     L8A4D                           ; 8A80
        lda     #$00                            ; 8A82
        sta     $0503                           ; 8A84
        lda     $05D4                           ; 8A87
        sta     $0500                           ; 8A8A
        lda     #$73                            ; 8A8D
        ldx     $059E                           ; 8A8F
        beq     L8A9C                           ; 8A92
        lda     #$41                            ; 8A94
        cpx     #$03                            ; 8A96
        bcc     L8A9C                           ; 8A98
        lda     #$3F                            ; 8A9A
L8A9C:  jsr     LCFA1                           ; 8A9C
        lda     $050E                           ; 8A9F
        cmp     #$FF                            ; 8AA2
        bne     L8AAB                           ; 8AA4
        lda     #$0C                            ; 8AA6
        jsr     LCFA1                           ; 8AA8
L8AAB:  rts                                     ; 8AAB

; ----------------------------------------------------------------------------
        lda     #$77                            ; 8AAC
        jsr     LE992                           ; 8AAE
        lda     #$03                            ; 8AB1
        jsr     LE029                           ; 8AB3
        lda     #$77                            ; 8AB6
        jsr     LE992                           ; 8AB8
        lda     #$26                            ; 8ABB
        jsr     LDF18                           ; 8ABD
        lda     #$01                            ; 8AC0
        sta     $046F                           ; 8AC2
        lda     #$3D                            ; 8AC5
        sta     $0470                           ; 8AC7
        jsr     LB29F                           ; 8ACA
        rts                                     ; 8ACD

; ----------------------------------------------------------------------------
        lda     #$77                            ; 8ACE
        jsr     LE992                           ; 8AD0
        lda     #$05                            ; 8AD3
        jsr     LE029                           ; 8AD5
        lda     #$77                            ; 8AD8
        jsr     LE992                           ; 8ADA
        lda     #$21                            ; 8ADD
        jsr     LDF18                           ; 8ADF
        lda     #$00                            ; 8AE2
        sta     $046F                           ; 8AE4
        lda     #$3A                            ; 8AE7
        sta     $0470                           ; 8AE9
        jsr     LB29F                           ; 8AEC
        rts                                     ; 8AEF

; ----------------------------------------------------------------------------
        lda     #$0B                            ; 8AF0
        jsr     LE029                           ; 8AF2
        lda     #$28                            ; 8AF5
        jsr     LDF18                           ; 8AF7
        lda     #$00                            ; 8AFA
        sta     $046F                           ; 8AFC
        lda     #$3C                            ; 8AFF
        sta     $0470                           ; 8B01
        jsr     LB29F                           ; 8B04
        rts                                     ; 8B07

; ----------------------------------------------------------------------------
        jsr     LCCF1                           ; 8B08
        ldx     $05C6                           ; 8B0B
L8B0E:  txa                                     ; 8B0E
        stx     $51                             ; 8B0F
        jsr     LC6F3                           ; 8B11
        lda     $054D,y                         ; 8B14
        cmp     #$FF                            ; 8B17
        bne     L8B24                           ; 8B19
        inx                                     ; 8B1B
        cpx     #$07                            ; 8B1C
        bne     L8B0E                           ; 8B1E
        ldx     #$00                            ; 8B20
        beq     L8B0E                           ; 8B22
L8B24:  sta     $0503                           ; 8B24
        lda     $054E,y                         ; 8B27
        sta     $0504                           ; 8B2A
        lda     $0500                           ; 8B2D
        cmp     #$10                            ; 8B30
        bne     L8B46                           ; 8B32
        jsr     LC910                           ; 8B34
        bmi     L8B46                           ; 8B37
        ldx     $01                             ; 8B39
        stx     $51                             ; 8B3B
        sta     $0503                           ; 8B3D
        lda     $054E,y                         ; 8B40
        sta     $0504                           ; 8B43
L8B46:  lda     #$02                            ; 8B46
        jsr     LCFA1                           ; 8B48
        jsr     LCBA7                           ; 8B4B
        beq     L8B56                           ; 8B4E
        lda     #$33                            ; 8B50
        jsr     LCFA1                           ; 8B52
        rts                                     ; 8B55

; ----------------------------------------------------------------------------
L8B56:  jsr     LCF43                           ; 8B56
        lda     $51                             ; 8B59
        jsr     LC6F3                           ; 8B5B
        lda     $0555,y                         ; 8B5E
        clc                                     ; 8B61
        adc     $05D1                           ; 8B62
        sta     $0555,y                         ; 8B65
        lda     $51                             ; 8B68
        jsr     LCCD1                           ; 8B6A
        lda     $51                             ; 8B6D
        jsr     LC551                           ; 8B6F
        lda     #$1B                            ; 8B72
        jsr     LCFA1                           ; 8B74
        rts                                     ; 8B77

; ----------------------------------------------------------------------------
        jsr     LB281                           ; 8B78
        jsr     L9770                           ; 8B7B
        jsr     LCF43                           ; 8B7E
        lda     #$77                            ; 8B81
        jsr     LE992                           ; 8B83
        lda     #$08                            ; 8B86
        jsr     LE029                           ; 8B88
        lda     #$77                            ; 8B8B
        jsr     LE992                           ; 8B8D
        lda     #$00                            ; 8B90
        sta     $046E                           ; 8B92
        lda     #$01                            ; 8B95
        sta     $046F                           ; 8B97
        jsr     LB35E                           ; 8B9A
        rts                                     ; 8B9D

; ----------------------------------------------------------------------------
        jsr     LB281                           ; 8B9E
        jsr     LCF43                           ; 8BA1
        lda     #$00                            ; 8BA4
        ldx     #$0D                            ; 8BA6
L8BA8:  sta     $058C,x                         ; 8BA8
        dex                                     ; 8BAB
        bpl     L8BA8                           ; 8BAC
        lda     #$34                            ; 8BAE
        jsr     LE992                           ; 8BB0
        lda     $0502                           ; 8BB3
        sec                                     ; 8BB6
        sbc     #$0C                            ; 8BB7
        tax                                     ; 8BB9
        lda     L9F3F,x                         ; 8BBA
        sta     $059C                           ; 8BBD
        lda     L9F42,x                         ; 8BC0
        sta     $059D                           ; 8BC3
        jsr     LE029                           ; 8BC6
        jsr     LC02C                           ; 8BC9
L8BCC:  jsr     L9770                           ; 8BCC
        lda     #$01                            ; 8BCF
        sta     $046E                           ; 8BD1
        sta     $046F                           ; 8BD4
        jsr     LB35E                           ; 8BD7
        lda     $050E                           ; 8BDA
        cmp     #$FF                            ; 8BDD
        bne     L8BE7                           ; 8BDF
        lda     #$0C                            ; 8BE1
        jsr     LCFA1                           ; 8BE3
        rts                                     ; 8BE6

; ----------------------------------------------------------------------------
L8BE7:  lda     $05C8                           ; 8BE7
        jsr     LC6F3                           ; 8BEA
        lda     $054D,y                         ; 8BED
        cmp     #$FF                            ; 8BF0
        beq     L8BF9                           ; 8BF2
        dec     $059C                           ; 8BF4
        bne     L8BCC                           ; 8BF7
L8BF9:  jsr     LBDB3                           ; 8BF9
        rts                                     ; 8BFC

; ----------------------------------------------------------------------------
        jsr     LB281                           ; 8BFD
        jsr     LCF43                           ; 8C00
        lda     #$00                            ; 8C03
        sta     $059F                           ; 8C05
        sta     $5F                             ; 8C08
        jsr     LCD8E                           ; 8C0A
        sta     $5E                             ; 8C0D
        lda     #$77                            ; 8C0F
        jsr     LE992                           ; 8C11
        lda     #$0A                            ; 8C14
        ldx     $0502                           ; 8C16
        cpx     #$10                            ; 8C19
        beq     L8C1F                           ; 8C1B
        lda     #$0D                            ; 8C1D
L8C1F:  jsr     LE029                           ; 8C1F
        jsr     LC02C                           ; 8C22
        lda     #$77                            ; 8C25
        jsr     LE992                           ; 8C27
        lda     #$03                            ; 8C2A
        sta     $059C                           ; 8C2C
L8C2F:  sta     $05D5                           ; 8C2F
        jsr     LC6F3                           ; 8C32
        lda     $050E,y                         ; 8C35
        sta     $0503                           ; 8C38
        cmp     #$FF                            ; 8C3B
        beq     L8C53                           ; 8C3D
        lda     #$01                            ; 8C3F
        sta     $046E                           ; 8C41
        ldx     $0502                           ; 8C44
        cpx     #$10                            ; 8C47
        bne     L8C4D                           ; 8C49
        lda     #$FF                            ; 8C4B
L8C4D:  sta     $046F                           ; 8C4D
        jsr     LB35E                           ; 8C50
L8C53:  lda     $050E                           ; 8C53
        cmp     #$FF                            ; 8C56
        beq     L8C9D                           ; 8C58
        lda     $05C8                           ; 8C5A
L8C5D:  jsr     LC6F3                           ; 8C5D
        lda     $054D,y                         ; 8C60
        cmp     #$FF                            ; 8C63
        beq     L8C8E                           ; 8C65
        inc     $059C                           ; 8C67
        lda     $059C                           ; 8C6A
        cmp     #$07                            ; 8C6D
        bne     L8C8A                           ; 8C6F
        lda     $5E                             ; 8C71
        beq     L8C85                           ; 8C73
        lda     $5F                             ; 8C75
        beq     L8C85                           ; 8C77
        ldx     #$72                            ; 8C79
        cmp     $5E                             ; 8C7B
        beq     L8C81                           ; 8C7D
        ldx     #$71                            ; 8C7F
L8C81:  txa                                     ; 8C81
        jsr     LCFA1                           ; 8C82
L8C85:  lda     #$00                            ; 8C85
        sta     $059C                           ; 8C87
L8C8A:  cmp     #$03                            ; 8C8A
        bne     L8C2F                           ; 8C8C
L8C8E:  lda     $059F                           ; 8C8E
        beq     L8C9D                           ; 8C91
        lda     #$00                            ; 8C93
        sta     $0503                           ; 8C95
        lda     #$41                            ; 8C98
        jsr     LCFA1                           ; 8C9A
L8C9D:  rts                                     ; 8C9D

; ----------------------------------------------------------------------------
        jsr     LCCF1                           ; 8C9E
L8CA1:  lda     #$02                            ; 8CA1
        jsr     LCFA1                           ; 8CA3
        lda     #$03                            ; 8CA6
        sta     $01                             ; 8CA8
        ldx     #$02                            ; 8CAA
        lda     $0502                           ; 8CAC
        cmp     #$15                            ; 8CAF
        beq     L8CB5                           ; 8CB1
        ldx     #$04                            ; 8CB3
L8CB5:  stx     $02                             ; 8CB5
        lda     $E0                             ; 8CB7
        and     #$01                            ; 8CB9
        tax                                     ; 8CBB
L8CBC:  jsr     LC6F3                           ; 8CBC
        lda     $050E,y                         ; 8CBF
        cmp     #$FF                            ; 8CC2
        beq     L8CCD                           ; 8CC4
        lda     $0510,y                         ; 8CC6
        and     $02                             ; 8CC9
        beq     L8CDA                           ; 8CCB
L8CCD:  inx                                     ; 8CCD
        cpx     #$03                            ; 8CCE
        bne     L8CD4                           ; 8CD0
        ldx     #$00                            ; 8CD2
L8CD4:  txa                                     ; 8CD4
        dec     $01                             ; 8CD5
        bne     L8CBC                           ; 8CD7
        rts                                     ; 8CD9

; ----------------------------------------------------------------------------
L8CDA:  stx     $05D5                           ; 8CDA
        lda     $050E,y                         ; 8CDD
        sta     $0503                           ; 8CE0
        lda     #$00                            ; 8CE3
        sta     $0504                           ; 8CE5
        sty     $52                             ; 8CE8
        jsr     LCBA7                           ; 8CEA
        beq     L8CF5                           ; 8CED
        lda     #$33                            ; 8CEF
        jsr     LCFA1                           ; 8CF1
        rts                                     ; 8CF4

; ----------------------------------------------------------------------------
L8CF5:  lda     $0502                           ; 8CF5
        cmp     #$12                            ; 8CF8
        bne     L8D00                           ; 8CFA
        jsr     LAD04                           ; 8CFC
        rts                                     ; 8CFF

; ----------------------------------------------------------------------------
L8D00:  jsr     LAD21                           ; 8D00
        rts                                     ; 8D03

; ----------------------------------------------------------------------------
        lda     #$04                            ; 8D04
        sta     $046E                           ; 8D06
        lda     #$0D                            ; 8D09
        sta     $046F                           ; 8D0B
        lda     #$14                            ; 8D0E
        sta     $0470                           ; 8D10
        lda     #$05                            ; 8D13
        sta     $0471                           ; 8D15
        lda     #$02                            ; 8D18
        sta     $0472                           ; 8D1A
        jsr     LB480                           ; 8D1D
        rts                                     ; 8D20

; ----------------------------------------------------------------------------
        lda     #$02                            ; 8D21
        sta     $046E                           ; 8D23
        lda     #$04                            ; 8D26
        sta     $046F                           ; 8D28
        lda     #$13                            ; 8D2B
        sta     $0470                           ; 8D2D
        lda     #$04                            ; 8D30
        sta     $0471                           ; 8D32
        lda     #$04                            ; 8D35
        sta     $0472                           ; 8D37
        jsr     LB480                           ; 8D3A
        rts                                     ; 8D3D

; ----------------------------------------------------------------------------
        jsr     LCCF1                           ; 8D3E
        lda     #$2C                            ; 8D41
        jsr     LCFA1                           ; 8D43
        lda     #$03                            ; 8D46
        sta     $01                             ; 8D48
        lda     $E0                             ; 8D4A
        and     #$01                            ; 8D4C
        tax                                     ; 8D4E
L8D4F:  jsr     LC6F3                           ; 8D4F
        lda     $050E,y                         ; 8D52
        cmp     #$FF                            ; 8D55
        beq     L8D6A                           ; 8D57
        lda     $0510,y                         ; 8D59
        sta     $50                             ; 8D5C
        and     #$08                            ; 8D5E
        bne     L8D6A                           ; 8D60
        lda     $50                             ; 8D62
        and     #$06                            ; 8D64
        cmp     #$06                            ; 8D66
        bne     L8D77                           ; 8D68
L8D6A:  inx                                     ; 8D6A
        cpx     #$03                            ; 8D6B
        bne     L8D71                           ; 8D6D
        ldx     #$00                            ; 8D6F
L8D71:  txa                                     ; 8D71
        dec     $01                             ; 8D72
        bne     L8D4F                           ; 8D74
        rts                                     ; 8D76

; ----------------------------------------------------------------------------
L8D77:  stx     $05D5                           ; 8D77
        lda     $050E,y                         ; 8D7A
        sta     $0503                           ; 8D7D
        lda     #$00                            ; 8D80
        sta     $0504                           ; 8D82
        jsr     LCBA7                           ; 8D85
        beq     L8D90                           ; 8D88
        lda     #$4A                            ; 8D8A
        jsr     LCFA1                           ; 8D8C
        rts                                     ; 8D8F

; ----------------------------------------------------------------------------
L8D90:  lda     $05D5                           ; 8D90
        bne     L8DA0                           ; 8D93
        lda     $0305                           ; 8D95
        beq     L8DA0                           ; 8D98
        lda     #$2F                            ; 8D9A
        jsr     LCFA1                           ; 8D9C
        rts                                     ; 8D9F

; ----------------------------------------------------------------------------
L8DA0:  lda     $05D5                           ; 8DA0
        jsr     LC6F3                           ; 8DA3
        sty     $52                             ; 8DA6
        lda     $0510,y                         ; 8DA8
        sta     $50                             ; 8DAB
        and     #$01                            ; 8DAD
        beq     L8DC3                           ; 8DAF
        lda     $05D5                           ; 8DB1
        jsr     LC25E                           ; 8DB4
        lda     #$34                            ; 8DB7
        jsr     LCFA1                           ; 8DB9
        jsr     LCBE3                           ; 8DBC
        bne     L8DF5                           ; 8DBF
        beq     L8E00                           ; 8DC1
L8DC3:  lda     $05D5                           ; 8DC3
        jsr     LBC14                           ; 8DC6
        jsr     LCCA3                           ; 8DC9
        bcs     L8DD4                           ; 8DCC
        lda     #$2E                            ; 8DCE
        jsr     LCFA1                           ; 8DD0
        rts                                     ; 8DD3

; ----------------------------------------------------------------------------
L8DD4:  ldx     #$09                            ; 8DD4
        lda     $05D5                           ; 8DD6
        jsr     LC13B                           ; 8DD9
        lda     #$AD                            ; 8DDC
        jsr     LCFA1                           ; 8DDE
        lda     $05D5                           ; 8DE1
        jsr     LC6F3                           ; 8DE4
        lda     $0510,y                         ; 8DE7
        ora     #$08                            ; 8DEA
        sta     $0510,y                         ; 8DEC
        lda     #$03                            ; 8DEF
        sta     $0514,y                         ; 8DF1
        rts                                     ; 8DF4

; ----------------------------------------------------------------------------
L8DF5:  lda     #$06                            ; 8DF5
        sta     $046E                           ; 8DF7
        jsr     LB528                           ; 8DFA
        bne     L8E03                           ; 8DFD
        rts                                     ; 8DFF

; ----------------------------------------------------------------------------
L8E00:  ldx     $05C8                           ; 8E00
L8E03:  stx     $51                             ; 8E03
        txa                                     ; 8E05
        jsr     LBB00                           ; 8E06
        lda     $51                             ; 8E09
        ldx     #$09                            ; 8E0B
        jsr     LC0C4                           ; 8E0D
        lda     #$30                            ; 8E10
        jsr     LCFA1                           ; 8E12
        lda     $51                             ; 8E15
        jsr     LC6F3                           ; 8E17
        lda     $054F,y                         ; 8E1A
        ora     #$08                            ; 8E1D
        sta     $054F,y                         ; 8E1F
        lda     #$03                            ; 8E22
        sta     $0553,y                         ; 8E24
        rts                                     ; 8E27

; ----------------------------------------------------------------------------
        jsr     LCCF1                           ; 8E28
        lda     $05C8                           ; 8E2B
        jsr     LC6F3                           ; 8E2E
        lda     $054F,y                         ; 8E31
        and     #$10                            ; 8E34
        bne     L8E47                           ; 8E36
        lda     #$02                            ; 8E38
        jsr     LCFA1                           ; 8E3A
        jsr     LCBA7                           ; 8E3D
        beq     L8E48                           ; 8E40
        lda     #$33                            ; 8E42
        jsr     LCFA1                           ; 8E44
L8E47:  rts                                     ; 8E47

; ----------------------------------------------------------------------------
L8E48:  jsr     LCF43                           ; 8E48
        lda     #$00                            ; 8E4B
        sta     $059A                           ; 8E4D
L8E50:  jsr     LC6F3                           ; 8E50
        lda     $054D,y                         ; 8E53
        cmp     $0500                           ; 8E56
        bne     L8E72                           ; 8E59
        lda     $054F,y                         ; 8E5B
        and     #$0E                            ; 8E5E
        beq     L8E72                           ; 8E60
        lda     $054F,y                         ; 8E62
        and     #$F0                            ; 8E65
        sta     $054F,y                         ; 8E67
        lda     $059A                           ; 8E6A
        ldx     #$0C                            ; 8E6D
        jsr     LC0C4                           ; 8E6F
L8E72:  inc     $059A                           ; 8E72
        lda     $059A                           ; 8E75
        cmp     #$07                            ; 8E78
        bne     L8E50                           ; 8E7A
        jsr     LBB8D                           ; 8E7C
        lda     #$03                            ; 8E7F
        sta     $05D1                           ; 8E81
        rts                                     ; 8E84

; ----------------------------------------------------------------------------
        jsr     LB281                           ; 8E85
        jsr     LCF43                           ; 8E88
        lda     #$7F                            ; 8E8B
        jsr     LE992                           ; 8E8D
        lda     $05C8                           ; 8E90
        ldx     #$08                            ; 8E93
        jsr     LC0C4                           ; 8E95
        lda     #$15                            ; 8E98
        jsr     LCFA1                           ; 8E9A
        lda     $05C8                           ; 8E9D
        jsr     LC6F3                           ; 8EA0
        lda     $054F,y                         ; 8EA3
        ora     #$01                            ; 8EA6
        sta     $054F,y                         ; 8EA8
        lda     #$03                            ; 8EAB
        sta     $0550,y                         ; 8EAD
        rts                                     ; 8EB0

; ----------------------------------------------------------------------------
        jsr     LCCF1                           ; 8EB1
        lda     #$24                            ; 8EB4
        jsr     LCFA1                           ; 8EB6
        jsr     LCBB3                           ; 8EB9
        beq     L8EC4                           ; 8EBC
        lda     #$32                            ; 8EBE
        jsr     LCFA1                           ; 8EC0
        rts                                     ; 8EC3

; ----------------------------------------------------------------------------
L8EC4:  lda     $1E                             ; 8EC4
        and     #$01                            ; 8EC6
        tax                                     ; 8EC8
        jsr     LC6F3                           ; 8EC9
        lda     $050E,y                         ; 8ECC
        cmp     #$FF                            ; 8ECF
        bne     L8EDC                           ; 8ED1
        dex                                     ; 8ED3
        bpl     L8ED8                           ; 8ED4
        ldx     #$02                            ; 8ED6
L8ED8:  txa                                     ; 8ED8
        jmp     LAEC9                           ; 8ED9

; ----------------------------------------------------------------------------
L8EDC:  sta     $0503                           ; 8EDC
        stx     $51                             ; 8EDF
        lda     $0500                           ; 8EE1
        ldx     #$0F                            ; 8EE4
        cmp     #$17                            ; 8EE6
        beq     L8EF0                           ; 8EE8
        cmp     #$25                            ; 8EEA
        beq     L8EF0                           ; 8EEC
        ldx     #$05                            ; 8EEE
L8EF0:  stx     $0505                           ; 8EF0
        jsr     LCF43                           ; 8EF3
        lda     $51                             ; 8EF6
        bne     L8F2A                           ; 8EF8
        jsr     LC9A7                           ; 8EFA
        lda     $02                             ; 8EFD
        bne     L8F07                           ; 8EFF
L8F01:  lda     #$CA                            ; 8F01
        jsr     LCFA1                           ; 8F03
        rts                                     ; 8F06

; ----------------------------------------------------------------------------
L8F07:  cmp     $0505                           ; 8F07
        bcs     L8F0F                           ; 8F0A
        sta     $0505                           ; 8F0C
L8F0F:  sec                                     ; 8F0F
        sbc     $0505                           ; 8F10
        jsr     LCE39                           ; 8F13
        ldx     #$02                            ; 8F16
L8F18:  lda     $0D,x                           ; 8F18
        sta     $8C,x                           ; 8F1A
        dex                                     ; 8F1C
        bpl     L8F18                           ; 8F1D
        lda     $51                             ; 8F1F
        jsr     LC612                           ; 8F21
        lda     #$A7                            ; 8F24
        jsr     LCFA1                           ; 8F26
        rts                                     ; 8F29

; ----------------------------------------------------------------------------
L8F2A:  lda     $0503                           ; 8F2A
        asl     a                               ; 8F2D
        tax                                     ; 8F2E
        lda     $03BF,x                         ; 8F2F
        beq     L8F01                           ; 8F32
        cmp     $0505                           ; 8F34
        bcs     L8F3C                           ; 8F37
        sta     $0505                           ; 8F39
L8F3C:  sec                                     ; 8F3C
        sbc     $0505                           ; 8F3D
        sta     $03BF,x                         ; 8F40
        jmp     LAF1F                           ; 8F43

; ----------------------------------------------------------------------------
        jsr     LCCF1                           ; 8F46
        lda     #$22                            ; 8F49
        jsr     LCFA1                           ; 8F4B
        jsr     LCBA7                           ; 8F4E
        beq     L8F5E                           ; 8F51
        lda     #$00                            ; 8F53
        sta     $0503                           ; 8F55
        lda     #$4A                            ; 8F58
        jsr     LCFA1                           ; 8F5A
        rts                                     ; 8F5D

; ----------------------------------------------------------------------------
L8F5E:  jsr     LCF43                           ; 8F5E
        lda     #$10                            ; 8F61
        jsr     LE029                           ; 8F63
        lda     #$00                            ; 8F66
        sta     $0503                           ; 8F68
        lda     #$23                            ; 8F6B
        jsr     LCFA1                           ; 8F6D
        jsr     LCD8E                           ; 8F70
        sta     $5E                             ; 8F73
        jsr     LC02C                           ; 8F75
        lda     #$00                            ; 8F78
        sta     $059E                           ; 8F7A
        lda     #$03                            ; 8F7D
        sta     $059C                           ; 8F7F
        jsr     LC6F3                           ; 8F82
        lda     $050E,y                         ; 8F85
        cmp     #$FF                            ; 8F88
        beq     L8FC7                           ; 8F8A
        sta     $0503                           ; 8F8C
        lda     $059C                           ; 8F8F
        sta     $05D5                           ; 8F92
        jsr     LBC43                           ; 8F95
        php                                     ; 8F98
        lda     $059C                           ; 8F99
        cmp     #$03                            ; 8F9C
        bcs     L8FA3                           ; 8F9E
        jsr     LC5A9                           ; 8FA0
L8FA3:  plp                                     ; 8FA3
        bne     L8FC7                           ; 8FA4
        lda     $059C                           ; 8FA6
        cmp     #$03                            ; 8FA9
        bcc     L8FB7                           ; 8FAB
        ldx     #$00                            ; 8FAD
        jsr     LC13B                           ; 8FAF
        inc     $059E                           ; 8FB2
        bne     L8FBC                           ; 8FB5
L8FB7:  ldx     #$00                            ; 8FB7
        jsr     LC13B                           ; 8FB9
L8FBC:  lda     $059C                           ; 8FBC
        jsr     LC6F3                           ; 8FBF
        lda     #$FF                            ; 8FC2
        sta     $050E,y                         ; 8FC4
L8FC7:  inc     $059C                           ; 8FC7
        lda     $059C                           ; 8FCA
        cmp     #$07                            ; 8FCD
        bne     L8FEC                           ; 8FCF
        lda     $059E                           ; 8FD1
        sta     $0504                           ; 8FD4
        beq     L8FE7                           ; 8FD7
        lda     #$71                            ; 8FD9
        ldx     $059E                           ; 8FDB
        cpx     $5E                             ; 8FDE
        bne     L8FE4                           ; 8FE0
        lda     #$72                            ; 8FE2
L8FE4:  jsr     LCFA1                           ; 8FE4
L8FE7:  lda     #$00                            ; 8FE7
        sta     $059C                           ; 8FE9
L8FEC:  cmp     #$03                            ; 8FEC
        beq     L8FF3                           ; 8FEE
        jmp     LAF82                           ; 8FF0

; ----------------------------------------------------------------------------
L8FF3:  jmp     LAC93                           ; 8FF3

; ----------------------------------------------------------------------------
        jsr     LCCF1                           ; 8FF6
        jsr     LCEE3                           ; 8FF9
        lda     $01                             ; 8FFC
        cmp     #$07                            ; 8FFE
        beq     L900F                           ; 9000
        lda     $05C8                           ; 9002
        jsr     LC6F3                           ; 9005
        lda     $054F,y                         ; 9008
        and     #$10                            ; 900B
        beq     L9015                           ; 900D
L900F:  lda     #$55                            ; 900F
        jsr     LCFA1                           ; 9011
        rts                                     ; 9014

; ----------------------------------------------------------------------------
L9015:  lda     $054F,y                         ; 9015
        and     #$04                            ; 9018
        beq     L9022                           ; 901A
        lda     #$55                            ; 901C
        jsr     LCFA1                           ; 901E
        rts                                     ; 9021

; ----------------------------------------------------------------------------
L9022:  lda     $054D,y                         ; 9022
        sta     $50                             ; 9025
        lda     $05C8                           ; 9027
        tax                                     ; 902A
        jsr     LC6F3                           ; 902B
        lda     $054D,y                         ; 902E
        cmp     #$FF                            ; 9031
        beq     L903E                           ; 9033
        dex                                     ; 9035
        bpl     L903A                           ; 9036
        ldx     #$06                            ; 9038
L903A:  txa                                     ; 903A
        jmp     LB02B                           ; 903B

; ----------------------------------------------------------------------------
L903E:  stx     $51                             ; 903E
        sty     $52                             ; 9040
        txa                                     ; 9042
        asl     a                               ; 9043
        tax                                     ; 9044
        lda     #$FF                            ; 9045
        sta     $05AE,x                         ; 9047
        ldx     #$08                            ; 904A
        lda     #$00                            ; 904C
L904E:  sta     $054D,y                         ; 904E
        iny                                     ; 9051
        dex                                     ; 9052
        bpl     L904E                           ; 9053
        ldy     $52                             ; 9055
        lda     $50                             ; 9057
        sta     $054D,y                         ; 9059
        jsr     LB744                           ; 905C
        ldy     $52                             ; 905F
        sta     $0555,y                         ; 9061
        ldx     #$00                            ; 9064
L9066:  lda     $05E0,x                         ; 9066
        cmp     $50                             ; 9069
        beq     L9072                           ; 906B
        inx                                     ; 906D
        inx                                     ; 906E
        inx                                     ; 906F
        bne     L9066                           ; 9070
L9072:  inx                                     ; 9072
        inx                                     ; 9073
        lda     $05E0,x                         ; 9074
        cmp     #$09                            ; 9077
        bne     L9081                           ; 9079
        lda     #$FF                            ; 907B
        sta     $054D,y                         ; 907D
        rts                                     ; 9080

; ----------------------------------------------------------------------------
L9081:  inc     $05E0,x                         ; 9081
        lda     $05E0,x                         ; 9084
        ldy     $52                             ; 9087
        sta     $054E,y                         ; 9089
        sta     $0504                           ; 908C
        lda     $50                             ; 908F
        sta     $0503                           ; 9091
        jsr     LCF43                           ; 9094
        lda     #$1F                            ; 9097
        jsr     LCFA1                           ; 9099
        ldx     #$02                            ; 909C
        lda     $51                             ; 909E
        jsr     LC0C4                           ; 90A0
        ldy     $52                             ; 90A3
        lda     $054D,y                         ; 90A5
        jsr     LB8B0                           ; 90A8
        lda     $51                             ; 90AB
        jsr     LC3F4                           ; 90AD
        lda     $51                             ; 90B0
        jsr     LC551                           ; 90B2
        lda     #$20                            ; 90B5
        jsr     LCFA1                           ; 90B7
        rts                                     ; 90BA

; ----------------------------------------------------------------------------
        jsr     LCCF1                           ; 90BB
        jsr     LCBB3                           ; 90BE
        beq     L90C9                           ; 90C1
        lda     #$32                            ; 90C3
        jsr     LCFA1                           ; 90C5
        rts                                     ; 90C8

; ----------------------------------------------------------------------------
L90C9:  jsr     L9770                           ; 90C9
        lda     $05D5                           ; 90CC
        jsr     LBBDB                           ; 90CF
        ldx     $05D5                           ; 90D2
        clc                                     ; 90D5
        adc     $058C,x                         ; 90D6
        sta     $058C,x                         ; 90D9
        lda     $0460,x                         ; 90DC
        bne     L90EA                           ; 90DF
        lda     $059D                           ; 90E1
        sta     $0460,x                         ; 90E4
        inc     $059D                           ; 90E7
L90EA:  lda     #$04                            ; 90EA
        ldx     $0502                           ; 90EC
        cpx     #$24                            ; 90EF
        beq     L90F5                           ; 90F1
        lda     #$05                            ; 90F3
L90F5:  ldx     $05D9                           ; 90F5
        bne     L90FF                           ; 90F8
        ldx     #$01                            ; 90FA
        stx     $05D9                           ; 90FC
L90FF:  jsr     LCFA1                           ; 90FF
        rts                                     ; 9102

; ----------------------------------------------------------------------------
        lda     #$02                            ; 9103
        sta     $059D                           ; 9105
        jsr     LCCF1                           ; 9108
        jsr     LCBB3                           ; 910B
        beq     L9116                           ; 910E
        lda     #$32                            ; 9110
        jsr     LCFA1                           ; 9112
        rts                                     ; 9115

; ----------------------------------------------------------------------------
L9116:  lda     $05C8                           ; 9116
        jsr     LC6F3                           ; 9119
        sty     $52                             ; 911C
        lda     $0500                           ; 911E
        cmp     #$0D                            ; 9121
        beq     L9129                           ; 9123
        cmp     #$0E                            ; 9125
        bne     L916F                           ; 9127
L9129:  ldy     $52                             ; 9129
        lda     $054F,y                         ; 912B
        sta     $50                             ; 912E
        and     #$20                            ; 9130
        beq     L914F                           ; 9132
        lda     #$01                            ; 9134
        jsr     LCE8D                           ; 9136
        bcc     L916F                           ; 9139
        lda     #$56                            ; 913B
        jsr     LCFA1                           ; 913D
        lda     #$71                            ; 9140
        jsr     LE992                           ; 9142
        lda     $50                             ; 9145
        and     #$DF                            ; 9147
        ldy     $52                             ; 9149
        sta     $054F,y                         ; 914B
L914E:  rts                                     ; 914E

; ----------------------------------------------------------------------------
L914F:  lda     #$00                            ; 914F
        jsr     LCE8D                           ; 9151
        bcc     L916F                           ; 9154
        lda     #$28                            ; 9156
        jsr     LCFA1                           ; 9158
        lda     #$A9                            ; 915B
        jsr     LCFA1                           ; 915D
        lda     #$71                            ; 9160
        jsr     LE992                           ; 9162
        ldy     $52                             ; 9165
        lda     $054F,y                         ; 9167
        ora     #$20                            ; 916A
        sta     $054F,y                         ; 916C
L916F:  lda     $050E                           ; 916F
        bmi     L914E                           ; 9172
        jsr     L9770                           ; 9174
        lda     #$03                            ; 9177
        jsr     LCFA1                           ; 9179
        lda     #$00                            ; 917C
        sta     $05F6                           ; 917E
        lda     $0500                           ; 9181
        jsr     LCDD5                           ; 9184
        ldy     #$06                            ; 9187
        lda     ($00),y                         ; 9189
        cmp     #$FF                            ; 918B
        clc                                     ; 918D
        beq     L9193                           ; 918E
        jsr     LCE8D                           ; 9190
L9193:  lda     #$33                            ; 9193
        php                                     ; 9195
        bcc     L919D                           ; 9196
        jsr     LC02C                           ; 9198
        lda     #$6E                            ; 919B
L919D:  jsr     LE992                           ; 919D
        lda     $05D5                           ; 91A0
        cmp     #$03                            ; 91A3
        bcs     L91AD                           ; 91A5
        jsr     LBC1B                           ; 91A7
        jmp     LB1B3                           ; 91AA

; ----------------------------------------------------------------------------
L91AD:  sec                                     ; 91AD
        sbc     #$03                            ; 91AE
        jsr     LBAD7                           ; 91B0
        plp                                     ; 91B3
        bcc     L91CE                           ; 91B4
        lda     #$2A                            ; 91B6
        jsr     LCFA1                           ; 91B8
        lda     $05D5                           ; 91BB
        jsr     LBC43                           ; 91BE
        lda     $05D5                           ; 91C1
        jsr     LBC43                           ; 91C4
        beq     L91D6                           ; 91C7
        asl     $01                             ; 91C9
        jmp     LB203                           ; 91CB

; ----------------------------------------------------------------------------
L91CE:  lda     $05D5                           ; 91CE
        jsr     LBC43                           ; 91D1
        bne     L91F9                           ; 91D4
L91D6:  lda     $05D5                           ; 91D6
        ldx     #$00                            ; 91D9
        jsr     LC13B                           ; 91DB
        lda     #$0C                            ; 91DE
        ldx     $05D5                           ; 91E0
        cpx     #$03                            ; 91E3
        bcc     L91E9                           ; 91E5
        lda     #$45                            ; 91E7
L91E9:  jsr     LCFA1                           ; 91E9
        lda     $05D5                           ; 91EC
        jsr     LC6F3                           ; 91EF
        lda     #$FF                            ; 91F2
        sta     $050E,y                         ; 91F4
        bne     L9203                           ; 91F7
L91F9:  lda     $01                             ; 91F9
        sta     $0505                           ; 91FB
        lda     #$06                            ; 91FE
        jsr     LCFA1                           ; 9200
L9203:  lda     $0500                           ; 9203
        cmp     #$0D                            ; 9206
        beq     L920E                           ; 9208
        cmp     #$0E                            ; 920A
        bne     L9216                           ; 920C
L920E:  dec     $059D                           ; 920E
        beq     L9216                           ; 9211
        jmp     LB16F                           ; 9213

; ----------------------------------------------------------------------------
L9216:  rts                                     ; 9216

; ----------------------------------------------------------------------------
        lda     $049D                           ; 9217
        beq     L927E                           ; 921A
        lda     $05C8                           ; 921C
        jsr     LC6F3                           ; 921F
        lda     $0555,y                         ; 9222
        cmp     #$09                            ; 9225
        bcs     L927E                           ; 9227
        lda     $054D,y                         ; 9229
        jsr     LCDD5                           ; 922C
        ldy     #$04                            ; 922F
        lda     ($00),y                         ; 9231
        cmp     #$FF                            ; 9233
        beq     L927E                           ; 9235
        jsr     LCE8D                           ; 9237
        bcc     L927E                           ; 923A
        lda     $05C8                           ; 923C
        jsr     LC6F3                           ; 923F
        lda     $054D,y                         ; 9242
        sta     $0500                           ; 9245
        lda     $054E,y                         ; 9248
        sta     $0501                           ; 924B
        lda     $054F,y                         ; 924E
        and     #$0C                            ; 9251
        bne     L9279                           ; 9253
        lda     $05C8                           ; 9255
        jsr     LC52E                           ; 9258
        jsr     LCF88                           ; 925B
        lda     #$74                            ; 925E
        jsr     LCFA1                           ; 9260
        lda     $05C8                           ; 9263
        jsr     LC6F3                           ; 9266
        lda     #$FF                            ; 9269
        sta     $054D,y                         ; 926B
        jsr     LCA04                           ; 926E
        bne     L9278                           ; 9271
        .byte   $A9                             ; 9273
L9274:  .byte   $02                             ; 9274
        sta     $0506                           ; 9275
L9278:  rts                                     ; 9278

; ----------------------------------------------------------------------------
L9279:  lda     #$52                            ; 9279
        jsr     LCFA1                           ; 927B
L927E:  lda     #$00                            ; 927E
        rts                                     ; 9280

; ----------------------------------------------------------------------------
        jsr     LCCF1                           ; 9281
        lda     #$02                            ; 9284
        ldx     $0502                           ; 9286
        cpx     #$10                            ; 9289
        bne     L928F                           ; 928B
        lda     #$1E                            ; 928D
L928F:  jsr     LCFA1                           ; 928F
        jsr     LCBA7                           ; 9292
        beq     L929E                           ; 9295
        lda     #$33                            ; 9297
        jsr     LCFA1                           ; 9299
        pla                                     ; 929C
        pla                                     ; 929D
L929E:  rts                                     ; 929E

; ----------------------------------------------------------------------------
        jsr     LC02C                           ; 929F
        lda     #$00                            ; 92A2
        sta     $059E                           ; 92A4
        lda     #$03                            ; 92A7
        sta     $059C                           ; 92A9
        sta     $05D5                           ; 92AC
        jsr     LC6F3                           ; 92AF
        sty     $52                             ; 92B2
        lda     $050E,y                         ; 92B4
        cmp     #$FF                            ; 92B7
        beq     L9321                           ; 92B9
        sta     $0503                           ; 92BB
        lda     $059C                           ; 92BE
        jsr     LBC43                           ; 92C1
        php                                     ; 92C4
        lda     $059C                           ; 92C5
        cmp     #$03                            ; 92C8
        bcs     L92CF                           ; 92CA
        jsr     LC5A9                           ; 92CC
L92CF:  plp                                     ; 92CF
        bne     L9321                           ; 92D0
        lda     $059C                           ; 92D2
        cmp     #$03                            ; 92D5
        bcc     L92DB                           ; 92D7
        inc     $5F                             ; 92D9
L92DB:  lda     $0502                           ; 92DB
        cmp     #$02                            ; 92DE
        bne     L9304                           ; 92E0
        lda     $059C                           ; 92E2
        cmp     #$03                            ; 92E5
        bcc     L92F8                           ; 92E7
        sbc     #$03                            ; 92E9
        sta     $50                             ; 92EB
        jsr     LBAD0                           ; 92ED
        lda     $50                             ; 92F0
        jsr     LB7A9                           ; 92F2
        jmp     LB30D                           ; 92F5

; ----------------------------------------------------------------------------
L92F8:  jsr     LBC14                           ; 92F8
        lda     $059C                           ; 92FB
        jsr     LB7E9                           ; 92FE
        jmp     LB30D                           ; 9301

; ----------------------------------------------------------------------------
L9304:  lda     $059C                           ; 9304
        ldx     $046F                           ; 9307
        jsr     LC13B                           ; 930A
        lda     $059C                           ; 930D
        cmp     #$03                            ; 9310
        bcs     L931A                           ; 9312
        lda     $0470                           ; 9314
        jsr     LCFA1                           ; 9317
L931A:  ldy     $52                             ; 931A
        lda     #$FF                            ; 931C
        sta     $050E,y                         ; 931E
L9321:  inc     $059C                           ; 9321
        lda     $059C                           ; 9324
        cmp     #$07                            ; 9327
        bne     L9340                           ; 9329
        lda     $5E                             ; 932B
        beq     L933B                           ; 932D
        ldx     #$72                            ; 932F
        cmp     $5F                             ; 9331
        beq     L9337                           ; 9333
        ldx     #$71                            ; 9335
L9337:  txa                                     ; 9337
        jsr     LCFA1                           ; 9338
L933B:  lda     #$00                            ; 933B
        sta     $059C                           ; 933D
L9340:  cmp     #$03                            ; 9340
        beq     L9347                           ; 9342
        jmp     LB2AC                           ; 9344

; ----------------------------------------------------------------------------
L9347:  lda     #$00                            ; 9347
        sta     $0503                           ; 9349
        lda     #$41                            ; 934C
        jsr     LCFA1                           ; 934E
        lda     $050E                           ; 9351
        cmp     #$FF                            ; 9354
        bne     L935D                           ; 9356
        lda     #$0C                            ; 9358
        jsr     LCFA1                           ; 935A
L935D:  rts                                     ; 935D

; ----------------------------------------------------------------------------
        jsr     LCB9B                           ; 935E
        beq     L93D0                           ; 9361
        lda     $05D5                           ; 9363
        jsr     LC25E                           ; 9366
        lda     #$34                            ; 9369
        jsr     LCFA1                           ; 936B
        lda     $05C8                           ; 936E
        jsr     LC6F3                           ; 9371
        lda     $054F,y                         ; 9374
        and     #$10                            ; 9377
        beq     L937C                           ; 9379
        rts                                     ; 937B

; ----------------------------------------------------------------------------
L937C:  lda     $05C8                           ; 937C
        jsr     LBB00                           ; 937F
        lda     $05C8                           ; 9382
        jsr     LBCC8                           ; 9385
        bne     L93B8                           ; 9388
        lda     $05C8                           ; 938A
        ldx     $046F                           ; 938D
        bpl     L9398                           ; 9390
        jsr     LC52E                           ; 9392
        jmp     LB39B                           ; 9395

; ----------------------------------------------------------------------------
L9398:  jsr     LC0C4                           ; 9398
        jsr     LCEAF                           ; 939B
        lda     #$09                            ; 939E
        jsr     LCFA1                           ; 93A0
        jsr     LCEAF                           ; 93A3
        lda     $0500                           ; 93A6
        jsr     LCAE1                           ; 93A9
        lda     $05C8                           ; 93AC
        jsr     LC6F3                           ; 93AF
        lda     #$FF                            ; 93B2
        sta     $054D,y                         ; 93B4
        rts                                     ; 93B7

; ----------------------------------------------------------------------------
L93B8:  lda     $046E                           ; 93B8
        beq     L93C4                           ; 93BB
        lda     $0502                           ; 93BD
        cmp     #$0F                            ; 93C0
        bcc     L93CF                           ; 93C2
L93C4:  jsr     LCEAF                           ; 93C4
        lda     #$06                            ; 93C7
        jsr     LCFA1                           ; 93C9
        jsr     LCEAF                           ; 93CC
L93CF:  rts                                     ; 93CF

; ----------------------------------------------------------------------------
L93D0:  jsr     LCCA3                           ; 93D0
        bcc     L93CF                           ; 93D3
        inc     $059F                           ; 93D5
        lda     $0502                           ; 93D8
        cmp     #$0F                            ; 93DB
        bcc     L93E3                           ; 93DD
        cmp     #$12                            ; 93DF
        bcc     L93F7                           ; 93E1
L93E3:  lda     $05D5                           ; 93E3
        sec                                     ; 93E6
        sbc     #$03                            ; 93E7
        bcs     L93F4                           ; 93E9
        lda     $05D5                           ; 93EB
        jsr     LBC14                           ; 93EE
        jmp     LB3F7                           ; 93F1

; ----------------------------------------------------------------------------
L93F4:  jsr     LBAD0                           ; 93F4
L93F7:  lda     $05D5                           ; 93F7
        jsr     LBC43                           ; 93FA
        bne     L946E                           ; 93FD
        lda     $0502                           ; 93FF
        cmp     #$10                            ; 9402
        bne     L941A                           ; 9404
        lda     $05D5                           ; 9406
        sec                                     ; 9409
        sbc     #$03                            ; 940A
        bcs     L9417                           ; 940C
        lda     $05D5                           ; 940E
        jsr     LBC14                           ; 9411
        jmp     LB41A                           ; 9414

; ----------------------------------------------------------------------------
L9417:  jsr     LBAD0                           ; 9417
L941A:  lda     $05D5                           ; 941A
        cmp     #$03                            ; 941D
        bcc     L9423                           ; 941F
        inc     $5F                             ; 9421
L9423:  lda     $046F                           ; 9423
        bpl     L943F                           ; 9426
        lda     $05D5                           ; 9428
        sec                                     ; 942B
        sbc     #$03                            ; 942C
        bcc     L9436                           ; 942E
        jsr     LB7A9                           ; 9430
        jmp     LB448                           ; 9433

; ----------------------------------------------------------------------------
L9436:  lda     $05D5                           ; 9436
        jsr     LB7E9                           ; 9439
        jmp     LB448                           ; 943C

; ----------------------------------------------------------------------------
L943F:  ldx     $046F                           ; 943F
        lda     $05D5                           ; 9442
        jsr     LC13B                           ; 9445
        lda     $046E                           ; 9448
        bne     L9462                           ; 944B
        lda     #$0C                            ; 944D
        ldx     $05D5                           ; 944F
        cpx     #$03                            ; 9452
        bcc     L945F                           ; 9454
        ldx     $0502                           ; 9456
        cpx     #$0F                            ; 9459
        bcs     L9462                           ; 945B
        lda     #$45                            ; 945D
L945F:  jsr     LCFA1                           ; 945F
L9462:  lda     $05D5                           ; 9462
        jsr     LC6F3                           ; 9465
        lda     #$FF                            ; 9468
        sta     $050E,y                         ; 946A
        rts                                     ; 946D

; ----------------------------------------------------------------------------
L946E:  lda     $05D5                           ; 946E
        cmp     #$03                            ; 9471
        bcs     L947F                           ; 9473
        lda     $046E                           ; 9475
        bne     L947F                           ; 9478
        lda     #$06                            ; 947A
        jsr     LCFA1                           ; 947C
L947F:  rts                                     ; 947F

; ----------------------------------------------------------------------------
        ldy     $52                             ; 9480
        lda     $0510,y                         ; 9482
        sta     $51                             ; 9485
        and     #$01                            ; 9487
        beq     L94AA                           ; 9489
        lda     $05D5                           ; 948B
        jsr     LC25E                           ; 948E
        lda     #$34                            ; 9491
        jsr     LCFA1                           ; 9493
        jsr     LCBE3                           ; 9496
        bne     L94EB                           ; 9499
        lda     $0502                           ; 949B
        cmp     #$12                            ; 949E
        bne     L94EC                           ; 94A0
        lda     $054F,y                         ; 94A2
        and     #$04                            ; 94A5
        beq     L94EC                           ; 94A7
        rts                                     ; 94A9

; ----------------------------------------------------------------------------
L94AA:  lda     $51                             ; 94AA
        and     $046E                           ; 94AC
        bne     L94BB                           ; 94AF
        jsr     LCCA3                           ; 94B1
        bcs     L94BC                           ; 94B4
        lda     #$07                            ; 94B6
        jsr     LCFA1                           ; 94B8
L94BB:  rts                                     ; 94BB

; ----------------------------------------------------------------------------
L94BC:  ldx     $046F                           ; 94BC
        lda     $51                             ; 94BF
        and     $0472                           ; 94C1
        beq     L94C8                           ; 94C4
        ldx     #$09                            ; 94C6
L94C8:  lda     $05D5                           ; 94C8
        jsr     LC13B                           ; 94CB
        lda     $0470                           ; 94CE
        jsr     LCFA1                           ; 94D1
        ldy     $52                             ; 94D4
        lda     $0510,y                         ; 94D6
        ora     $046E                           ; 94D9
        sta     $0510,y                         ; 94DC
        tya                                     ; 94DF
        clc                                     ; 94E0
        adc     $0471                           ; 94E1
        tay                                     ; 94E4
        lda     #$03                            ; 94E5
        sta     $050E,y                         ; 94E7
        rts                                     ; 94EA

; ----------------------------------------------------------------------------
L94EB:  rts                                     ; 94EB

; ----------------------------------------------------------------------------
L94EC:  ldx     $05C8                           ; 94EC
        stx     $51                             ; 94EF
        sty     $52                             ; 94F1
        ldx     $046F                           ; 94F3
        lda     $054F,y                         ; 94F6
        and     $0472                           ; 94F9
        beq     L9500                           ; 94FC
        ldx     #$09                            ; 94FE
L9500:  lda     $51                             ; 9500
        jsr     LC0C4                           ; 9502
        jsr     LCEAF                           ; 9505
        lda     $0470                           ; 9508
        jsr     LCFA1                           ; 950B
        jsr     LCEAF                           ; 950E
        ldy     $52                             ; 9511
        lda     $054F,y                         ; 9513
        ora     $046E                           ; 9516
        sta     $054F,y                         ; 9519
        tya                                     ; 951C
        clc                                     ; 951D
        adc     $0471                           ; 951E
        tay                                     ; 9521
        lda     #$03                            ; 9522
        sta     $054D,y                         ; 9524
        rts                                     ; 9527

; ----------------------------------------------------------------------------
        ldx     $05C7                           ; 9528
        txa                                     ; 952B
L952C:  jsr     LC6F3                           ; 952C
        lda     $054D,y                         ; 952F
        cmp     #$FF                            ; 9532
        beq     L9545                           ; 9534
        cpx     $05C8                           ; 9536
        beq     L9545                           ; 9539
        lda     $054F,y                         ; 953B
        and     #$18                            ; 953E
        bne     L9545                           ; 9540
        jsr     LB555                           ; 9542
L9545:  inx                                     ; 9545
        cpx     #$07                            ; 9546
        bne     L954C                           ; 9548
        ldx     #$00                            ; 954A
L954C:  txa                                     ; 954C
        cmp     $05C7                           ; 954D
        bne     L952C                           ; 9550
        pla                                     ; 9552
        pla                                     ; 9553
        rts                                     ; 9554

; ----------------------------------------------------------------------------
        ldy     $0502                           ; 9555
        cpy     #$21                            ; 9558
        bne     L9567                           ; 955A
        and     $046E                           ; 955C
        cmp     $046E                           ; 955F
        beq     L9566                           ; 9562
L9564:  pla                                     ; 9564
        pla                                     ; 9565
L9566:  rts                                     ; 9566

; ----------------------------------------------------------------------------
L9567:  and     $046E                           ; 9567
        beq     L9564                           ; 956A
        rts                                     ; 956C

; ----------------------------------------------------------------------------
        lda     #$19                            ; 956D
        sta     $00                             ; 956F
        lda     #$80                            ; 9571
        sta     $01                             ; 9573
        ldx     $82                             ; 9575
        beq     L9592                           ; 9577
L9579:  ldy     #$00                            ; 9579
        lda     ($00),y                         ; 957B
        sta     $02                             ; 957D
        inc     $02                             ; 957F
        asl     a                               ; 9581
        adc     $02                             ; 9582
        clc                                     ; 9584
        adc     $00                             ; 9585
        sta     $00                             ; 9587
        lda     $01                             ; 9589
        adc     #$00                            ; 958B
        sta     $01                             ; 958D
        dex                                     ; 958F
        bne     L9579                           ; 9590
L9592:  rts                                     ; 9592

; ----------------------------------------------------------------------------
        jsr     LB56D                           ; 9593
        ldy     #$00                            ; 9596
        lda     ($00),y                         ; 9598
        tax                                     ; 959A
        iny                                     ; 959B
L959C:  lda     ($00),y                         ; 959C
        cmp     $94                             ; 959E
        beq     L95AA                           ; 95A0
        iny                                     ; 95A2
        iny                                     ; 95A3
        iny                                     ; 95A4
        dex                                     ; 95A5
        bne     L959C                           ; 95A6
        lda     #$45                            ; 95A8
L95AA:  rts                                     ; 95AA

; ----------------------------------------------------------------------------
        jsr     LB593                           ; 95AB
        iny                                     ; 95AE
        lda     ($00),y                         ; 95AF
        and     #$80                            ; 95B1
        sta     $05CC                           ; 95B3
        beq     L95CE                           ; 95B6
        tya                                     ; 95B8
        pha                                     ; 95B9
        lda     #$02                            ; 95BA
        ldx     $00                             ; 95BC
        stx     $02                             ; 95BE
        jsr     LCE8D                           ; 95C0
        ldx     $02                             ; 95C3
        stx     $00                             ; 95C5
        pla                                     ; 95C7
        tay                                     ; 95C8
        bcs     L95CE                           ; 95C9
        asl     $05CC                           ; 95CB
L95CE:  lda     ($00),y                         ; 95CE
        and     #$7F                            ; 95D0
        ldx     #$00                            ; 95D2
        stx     $00                             ; 95D4
        stx     $01                             ; 95D6
        tax                                     ; 95D8
        beq     L95EB                           ; 95D9
L95DB:  clc                                     ; 95DB
        lda     #$0C                            ; 95DC
        adc     $00                             ; 95DE
        sta     $00                             ; 95E0
        lda     #$00                            ; 95E2
        adc     $01                             ; 95E4
        sta     $01                             ; 95E6
        dex                                     ; 95E8
        bne     L95DB                           ; 95E9
L95EB:  clc                                     ; 95EB
        lda     #$29                            ; 95EC
        adc     $00                             ; 95EE
        sta     $00                             ; 95F0
        lda     #$81                            ; 95F2
        adc     $01                             ; 95F4
        sta     $01                             ; 95F6
        jsr     LB6C4                           ; 95F8
        ldy     #$00                            ; 95FB
L95FD:  lda     $05C9                           ; 95FD
        cmp     ($00),y                         ; 9600
        bcc     L960A                           ; 9602
        iny                                     ; 9604
        iny                                     ; 9605
        iny                                     ; 9606
        iny                                     ; 9607
        bne     L95FD                           ; 9608
L960A:  iny                                     ; 960A
        lda     $56                             ; 960B
        and     #$03                            ; 960D
        cmp     #$03                            ; 960F
        bne     L9615                           ; 9611
        lda     #$00                            ; 9613
L9615:  sta     $02                             ; 9615
        tya                                     ; 9617
        clc                                     ; 9618
        adc     $02                             ; 9619
        tay                                     ; 961B
        lda     ($00),y                         ; 961C
        sta     $05D6                           ; 961E
        tay                                     ; 9621
        lda     L8C5D,y                         ; 9622
        sta     $05D4                           ; 9625
        tya                                     ; 9628
        ldx     #$00                            ; 9629
        stx     $01                             ; 962B
        sta     $00                             ; 962D
        ldx     #$03                            ; 962F
L9631:  asl     $00                             ; 9631
        rol     $01                             ; 9633
        dex                                     ; 9635
        bne     L9631                           ; 9636
        clc                                     ; 9638
        lda     #$01                            ; 9639
        adc     $00                             ; 963B
        sta     $00                             ; 963D
        lda     #$82                            ; 963F
        adc     $01                             ; 9641
        sta     $01                             ; 9643
        ldy     #$00                            ; 9645
        lda     ($00),y                         ; 9647
        sta     $05CA                           ; 9649
        lda     $05D8                           ; 964C
        bne     L967B                           ; 964F
        lda     #$00                            ; 9651
        ldy     #$3E                            ; 9653
L9655:  sta     $054D,y                         ; 9655
        dey                                     ; 9658
        bpl     L9655                           ; 9659
        ldx     #$00                            ; 965B
        ldy     #$01                            ; 965D
L965F:  lda     ($00),y                         ; 965F
        sta     $054D,x                         ; 9661
        cmp     #$21                            ; 9664
        bcc     L9671                           ; 9666
        cmp     #$24                            ; 9668
        bcs     L9671                           ; 966A
        lda     #$FF                            ; 966C
        sta     $0554,x                         ; 966E
L9671:  iny                                     ; 9671
        clc                                     ; 9672
        txa                                     ; 9673
        adc     #$09                            ; 9674
        tax                                     ; 9676
        cpy     #$08                            ; 9677
        bne     L965F                           ; 9679
L967B:  jsr     LB6D5                           ; 967B
        ldx     #$07                            ; 967E
        ldy     #$01                            ; 9680
L9682:  lda     $05E0,y                         ; 9682
        iny                                     ; 9685
        sta     $05E0,y                         ; 9686
        iny                                     ; 9689
        iny                                     ; 968A
        dex                                     ; 968B
        bne     L9682                           ; 968C
        jsr     LB71A                           ; 968E
        lda     #$00                            ; 9691
        sta     $03                             ; 9693
L9695:  ldy     $03                             ; 9695
        lda     $054D,y                         ; 9697
        jsr     LB744                           ; 969A
        tax                                     ; 969D
        clc                                     ; 969E
        lda     $03                             ; 969F
        adc     #$08                            ; 96A1
        tay                                     ; 96A3
        txa                                     ; 96A4
        sta     $054D,y                         ; 96A5
        iny                                     ; 96A8
        sty     $03                             ; 96A9
        cpy     #$3F                            ; 96AB
        bne     L9695                           ; 96AD
        lda     $05CC                           ; 96AF
        bne     L96C3                           ; 96B2
        jsr     LC3D2                           ; 96B4
        lda     $1C                             ; 96B7
        ora     #$04                            ; 96B9
        sta     $1C                             ; 96BB
        jsr     LE95B                           ; 96BD
        jsr     LC536                           ; 96C0
L96C3:  rts                                     ; 96C3

; ----------------------------------------------------------------------------
        ldy     #$0A                            ; 96C4
        ldx     #$00                            ; 96C6
L96C8:  lda     $0335,y                         ; 96C8
        beq     L96CE                           ; 96CB
        inx                                     ; 96CD
L96CE:  dey                                     ; 96CE
        bpl     L96C8                           ; 96CF
        stx     $05C9                           ; 96D1
        rts                                     ; 96D4

; ----------------------------------------------------------------------------
        ldy     #$00                            ; 96D5
L96D7:  lda     #$FF                            ; 96D7
        sta     $05E0,y                         ; 96D9
        iny                                     ; 96DC
        lda     #$00                            ; 96DD
        sta     $05E0,y                         ; 96DF
        iny                                     ; 96E2
        iny                                     ; 96E3
        cpy     #$15                            ; 96E4
        bne     L96D7                           ; 96E6
        ldy     #$00                            ; 96E8
        sty     $00                             ; 96EA
L96EC:  lda     $054D,y                         ; 96EC
        bmi     L970D                           ; 96EF
        ldx     #$00                            ; 96F1
        lda     $05E0,x                         ; 96F3
        bmi     L9703                           ; 96F6
        cmp     $054D,y                         ; 96F8
        beq     L9703                           ; 96FB
        inx                                     ; 96FD
        inx                                     ; 96FE
        inx                                     ; 96FF
        jmp     LB6F3                           ; 9700

; ----------------------------------------------------------------------------
L9703:  lda     $054D,y                         ; 9703
        sta     $05E0,x                         ; 9706
        inx                                     ; 9709
        inc     $05E0,x                         ; 970A
L970D:  lda     $00                             ; 970D
        clc                                     ; 970F
        adc     #$09                            ; 9710
        sta     $00                             ; 9712
        tay                                     ; 9714
        cpy     #$3F                            ; 9715
        bne     L96EC                           ; 9717
        rts                                     ; 9719

; ----------------------------------------------------------------------------
        ldy     #$00                            ; 971A
L971C:  ldx     #$00                            ; 971C
        lda     #$01                            ; 971E
        sta     $00                             ; 9720
L9722:  lda     $05E0,y                         ; 9722
        bmi     L973C                           ; 9725
        cmp     $054D,x                         ; 9727
        bne     L9733                           ; 972A
        lda     $00                             ; 972C
        sta     $054E,x                         ; 972E
        inc     $00                             ; 9731
L9733:  clc                                     ; 9733
        txa                                     ; 9734
        adc     #$09                            ; 9735
        tax                                     ; 9737
        cmp     #$3F                            ; 9738
        bne     L9722                           ; 973A
L973C:  iny                                     ; 973C
        iny                                     ; 973D
        iny                                     ; 973E
        cpy     #$15                            ; 973F
        bne     L971C                           ; 9741
        rts                                     ; 9743

; ----------------------------------------------------------------------------
        jsr     LCDD5                           ; 9744
        ldy     #$07                            ; 9747
        lda     ($00),y                         ; 9749
        rts                                     ; 974B

; ----------------------------------------------------------------------------
        ldx     #$00                            ; 974C
L974E:  txa                                     ; 974E
        pha                                     ; 974F
        jsr     LC6F3                           ; 9750
        lda     $0529,y                         ; 9753
        cmp     #$FF                            ; 9756
        beq     L975F                           ; 9758
        pla                                     ; 975A
        pha                                     ; 975B
        jsr     LB767                           ; 975C
L975F:  pla                                     ; 975F
        tax                                     ; 9760
        inx                                     ; 9761
        cpx     #$04                            ; 9762
        bne     L974E                           ; 9764
        rts                                     ; 9766

; ----------------------------------------------------------------------------
        asl     a                               ; 9767
        sta     $00                             ; 9768
        ldx     $0162                           ; 976A
        ldy     #$00                            ; 976D
L976F:  .byte   $B9                             ; 976F
L9770:  .byte   $9F                             ; 9770
        .byte   $B7                             ; 9771
        sta     $0163,x                         ; 9772
        inx                                     ; 9775
        iny                                     ; 9776
        cpy     #$0A                            ; 9777
        bne     L976F                           ; 9779
        stx     $01                             ; 977B
        ldx     $0162                           ; 977D
        inx                                     ; 9780
        lda     $0163,x                         ; 9781
        clc                                     ; 9784
        adc     $00                             ; 9785
        sta     $0163,x                         ; 9787
        lda     $0162                           ; 978A
        clc                                     ; 978D
        adc     #$06                            ; 978E
        tax                                     ; 9790
        lda     $0163,x                         ; 9791
        adc     $00                             ; 9794
        sta     $0163,x                         ; 9796
        ldx     $01                             ; 9799
        jsr     L9274                           ; 979B
        rts                                     ; 979E

; ----------------------------------------------------------------------------
        and     ($96,x)                         ; 979F
        .byte   $02                             ; 97A1
        .byte   $9C                             ; 97A2
        asl     $B621,x                         ; 97A3
        .byte   $02                             ; 97A6
        sta     $0A1F,x                         ; 97A7
        sta     $00                             ; 97AA
        ldx     $0162                           ; 97AC
        ldy     #$00                            ; 97AF
L97B1:  lda     $B7E1,y                         ; 97B1
        sta     $0163,x                         ; 97B4
        inx                                     ; 97B7
        iny                                     ; 97B8
        cpy     #$08                            ; 97B9
        bne     L97B1                           ; 97BB
        stx     $01                             ; 97BD
        ldx     $0162                           ; 97BF
        inx                                     ; 97C2
        lda     $0163,x                         ; 97C3
        clc                                     ; 97C6
        adc     $00                             ; 97C7
        sta     $0163,x                         ; 97C9
        lda     $0162                           ; 97CC
        clc                                     ; 97CF
        adc     #$05                            ; 97D0
        tax                                     ; 97D2
        lda     $0163,x                         ; 97D3
        adc     $00                             ; 97D6
        sta     $0163,x                         ; 97D8
        ldx     $01                             ; 97DB
        jsr     L9274                           ; 97DD
        rts                                     ; 97E0

; ----------------------------------------------------------------------------
        and     ($96,x)                         ; 97E1
        .byte   $42                             ; 97E3
        bit     $B621                           ; 97E4
        .byte   $42                             ; 97E7
        bit     $3A20                           ; 97E8
        .byte   $CF                             ; 97EB
        lda     #$FF                            ; 97EC
        sta     $0620,y                         ; 97EE
        rts                                     ; 97F1

; ----------------------------------------------------------------------------
        lda     #$00                            ; 97F2
        sta     $05C8                           ; 97F4
L97F7:  jsr     LB217                           ; 97F7
        inc     $05C8                           ; 97FA
        lda     $05C8                           ; 97FD
        cmp     #$07                            ; 9800
        bne     L97F7                           ; 9802
        rts                                     ; 9804

; ----------------------------------------------------------------------------
        ldx     #$06                            ; 9805
L9807:  txa                                     ; 9807
        jsr     LC6F3                           ; 9808
        lda     $054D,y                         ; 980B
        bmi     L9822                           ; 980E
        cmp     $05E0                           ; 9810
        bne     L981A                           ; 9813
        inc     $05E1                           ; 9815
        bne     L9822                           ; 9818
L981A:  cmp     $05E3                           ; 981A
        bne     L9822                           ; 981D
        inc     $05E4                           ; 981F
L9822:  dex                                     ; 9822
        bpl     L9807                           ; 9823
        rts                                     ; 9825

; ----------------------------------------------------------------------------
        lda     #$00                            ; 9826
        sta     $05E1                           ; 9828
        sta     $05E4                           ; 982B
        jsr     LB805                           ; 982E
        ldx     #$FF                            ; 9831
        lda     $05E1                           ; 9833
        bne     L983B                           ; 9836
        stx     $05E0                           ; 9838
L983B:  lda     $05E4                           ; 983B
        bne     L9843                           ; 983E
        stx     $05E3                           ; 9840
L9843:  lda     $05E0                           ; 9843
        bpl     L9858                           ; 9846
        ldx     #$02                            ; 9848
L984A:  lda     $05E3,x                         ; 984A
        sta     $05E0,x                         ; 984D
        dex                                     ; 9850
        bpl     L984A                           ; 9851
        lda     #$FF                            ; 9853
        sta     $05E3                           ; 9855
L9858:  rts                                     ; 9858

; ----------------------------------------------------------------------------
        lda     $04                             ; 9859
        lsr     a                               ; 985B
        lsr     a                               ; 985C
        and     #$07                            ; 985D
        sta     $00                             ; 985F
        lda     $05                             ; 9861
        sta     $01                             ; 9863
        lda     $04                             ; 9865
        ldx     #$04                            ; 9867
L9869:  lsr     $01                             ; 9869
        ror     a                               ; 986B
        dex                                     ; 986C
        bne     L9869                           ; 986D
        and     #$38                            ; 986F
        ora     $00                             ; 9871
        ora     #$C0                            ; 9873
        sta     $00                             ; 9875
        lda     #$04                            ; 9877
        sta     $01                             ; 9879
        lda     #$00                            ; 987B
        sta     $02                             ; 987D
        lda     $04                             ; 987F
        and     #$02                            ; 9881
        beq     L9887                           ; 9883
        inc     $02                             ; 9885
L9887:  lda     $04                             ; 9887
        and     #$40                            ; 9889
        beq     L9891                           ; 988B
        inc     $02                             ; 988D
        inc     $02                             ; 988F
L9891:  ldy     #$00                            ; 9891
        ldx     $02                             ; 9893
        lda     ($00),y                         ; 9895
        and     $B8AC,x                         ; 9897
        sta     ($00),y                         ; 989A
        lda     $03                             ; 989C
        ldx     $02                             ; 989E
        beq     L98A7                           ; 98A0
L98A2:  asl     a                               ; 98A2
        asl     a                               ; 98A3
        dex                                     ; 98A4
        bne     L98A2                           ; 98A5
L98A7:  ora     ($00),y                         ; 98A7
        sta     ($00),y                         ; 98A9
        rts                                     ; 98AB

; ----------------------------------------------------------------------------
        .byte   $FC                             ; 98AC
        .byte   $F3                             ; 98AD
        .byte   $CF                             ; 98AE
        .byte   $3F                             ; 98AF
        sec                                     ; 98B0
        sbc     #$0D                            ; 98B1
        tay                                     ; 98B3
        lda     L8A26,y                         ; 98B4
        ldx     $05CA                           ; 98B7
        beq     L98BF                           ; 98BA
        lda     L8A43,y                         ; 98BC
L98BF:  pha                                     ; 98BF
        ldx     #$00                            ; 98C0
        stx     $03                             ; 98C2
        asl     a                               ; 98C4
        rol     $03                             ; 98C5
        asl     a                               ; 98C7
        rol     $03                             ; 98C8
        pla                                     ; 98CA
        and     #$3F                            ; 98CB
        sta     $00                             ; 98CD
        asl     a                               ; 98CF
        adc     $00                             ; 98D0
        clc                                     ; 98D2
        adc     #$60                            ; 98D3
        sta     $00                             ; 98D5
        lda     #$8A                            ; 98D7
        adc     #$00                            ; 98D9
        sta     $01                             ; 98DB
        lda     $03                             ; 98DD
        asl     a                               ; 98DF
        asl     a                               ; 98E0
        tax                                     ; 98E1
        ldy     #$00                            ; 98E2
L98E4:  lda     ($00),y                         ; 98E4
        sta     $04A1,x                         ; 98E6
        inx                                     ; 98E9
        iny                                     ; 98EA
        cpy     #$03                            ; 98EB
        bne     L98E4                           ; 98ED
        lda     $1C                             ; 98EF
        ora     #$04                            ; 98F1
        sta     $1C                             ; 98F3
        jsr     LE95B                           ; 98F5
        rts                                     ; 98F8

; ----------------------------------------------------------------------------
        pha                                     ; 98F9
        ldx     #$00                            ; 98FA
        stx     $03                             ; 98FC
        asl     a                               ; 98FE
        rol     $03                             ; 98FF
        asl     a                               ; 9901
        rol     $03                             ; 9902
        pla                                     ; 9904
        and     #$3F                            ; 9905
        sta     $00                             ; 9907
        asl     a                               ; 9909
        adc     $00                             ; 990A
        clc                                     ; 990C
        adc     #$60                            ; 990D
        sta     $00                             ; 990F
        lda     #$8A                            ; 9911
        adc     #$00                            ; 9913
        sta     $01                             ; 9915
        lda     $03                             ; 9917
        asl     a                               ; 9919
        asl     a                               ; 991A
        tax                                     ; 991B
        ldy     #$00                            ; 991C
L991E:  lda     ($00),y                         ; 991E
        sta     $04B1,x                         ; 9920
        inx                                     ; 9923
        iny                                     ; 9924
        cpy     #$03                            ; 9925
        bne     L991E                           ; 9927
        jmp     LB8EF                           ; 9929

; ----------------------------------------------------------------------------
        cmp     #$07                            ; 992C
        beq     L9939                           ; 992E
        asl     a                               ; 9930
        tay                                     ; 9931
        lda     L8607,y                         ; 9932
        ldx     L8608,y                         ; 9935
        rts                                     ; 9938

; ----------------------------------------------------------------------------
L9939:  ldy     $82                             ; 9939
        lda     L8997,y                         ; 993B
        ldx     #$00                            ; 993E
        rts                                     ; 9940

; ----------------------------------------------------------------------------
        lda     $0500                           ; 9941
        jsr     LCDD5                           ; 9944
        ldy     #$08                            ; 9947
        lda     ($00),y                         ; 9949
        rts                                     ; 994B

; ----------------------------------------------------------------------------
        clc                                     ; 994C
        lda     $84                             ; 994D
        adc     #$05                            ; 994F
        ldy     $0500                           ; 9951
        beq     L995B                           ; 9954
        dey                                     ; 9956
        sec                                     ; 9957
        sbc     L8CA1,y                         ; 9958
L995B:  asl     a                               ; 995B
        tay                                     ; 995C
        lda     $0502                           ; 995D
        cmp     #$25                            ; 9960
        bcc     L9965                           ; 9962
        iny                                     ; 9964
L9965:  lda     L895B,y                         ; 9965
        rts                                     ; 9968

; ----------------------------------------------------------------------------
        clc                                     ; 9969
        lda     $84                             ; 996A
        adc     #$05                            ; 996C
        asl     a                               ; 996E
        tay                                     ; 996F
        iny                                     ; 9970
        lda     L895B,y                         ; 9971
        rts                                     ; 9974

; ----------------------------------------------------------------------------
        ldx     $05C3                           ; 9975
        dex                                     ; 9978
        txa                                     ; 9979
        asl     a                               ; 997A
        sta     $00                             ; 997B
        asl     a                               ; 997D
        clc                                     ; 997E
        adc     $00                             ; 997F
        clc                                     ; 9981
        adc     $05C2                           ; 9982
        tay                                     ; 9985
        dey                                     ; 9986
        lda     L8A02,y                         ; 9987
        rts                                     ; 998A

; ----------------------------------------------------------------------------
        ldx     $05C2                           ; 998B
        dex                                     ; 998E
        txa                                     ; 998F
        asl     a                               ; 9990
        sta     $00                             ; 9991
        asl     a                               ; 9993
        clc                                     ; 9994
        adc     $00                             ; 9995
        clc                                     ; 9997
        adc     $05C3                           ; 9998
        tay                                     ; 999B
        dey                                     ; 999C
        lda     L89DE,y                         ; 999D
        rts                                     ; 99A0

; ----------------------------------------------------------------------------
        lda     #$00                            ; 99A1
        sta     $05D1                           ; 99A3
        sta     $05D2                           ; 99A6
        jsr     LC837                           ; 99A9
        lda     $0502                           ; 99AC
        cmp     #$07                            ; 99AF
        bcs     L99F3                           ; 99B1
        lda     $05C3                           ; 99B3
        beq     L99C5                           ; 99B6
        jsr     LB98B                           ; 99B8
        lsr     a                               ; 99BB
        lsr     a                               ; 99BC
        lsr     a                               ; 99BD
        lsr     a                               ; 99BE
L99BF:  sta     $05D1                           ; 99BF
        jmp     LB9D4                           ; 99C2

; ----------------------------------------------------------------------------
L99C5:  lda     #$03                            ; 99C5
        sta     $05D1                           ; 99C7
        jsr     LCA16                           ; 99CA
        bne     L99D4                           ; 99CD
        lda     #$01                            ; 99CF
        sta     $05D1                           ; 99D1
L99D4:  jsr     LB969                           ; 99D4
        ldx     $05D1                           ; 99D7
        sta     $05D1                           ; 99DA
        lda     #$00                            ; 99DD
L99DF:  clc                                     ; 99DF
        adc     $05D1                           ; 99E0
        dex                                     ; 99E3
        bne     L99DF                           ; 99E4
        sta     $05D1                           ; 99E6
        lda     $0502                           ; 99E9
        jsr     LB92C                           ; 99EC
        stx     $05D2                           ; 99EF
        rts                                     ; 99F2

; ----------------------------------------------------------------------------
L99F3:  cmp     #$23                            ; 99F3
        bcs     L9A33                           ; 99F5
        jsr     LB92C                           ; 99F7
        sta     $05D1                           ; 99FA
        stx     $05D2                           ; 99FD
        lda     $0502                           ; 9A00
        cmp     #$07                            ; 9A03
        beq     L9A0F                           ; 9A05
        cmp     #$0B                            ; 9A07
        bcc     L9A32                           ; 9A09
        cmp     #$12                            ; 9A0B
        bcs     L9A32                           ; 9A0D
L9A0F:  lda     #$00                            ; 9A0F
        sta     $00                             ; 9A11
        lda     $05C2                           ; 9A13
        beq     L9A23                           ; 9A16
        lda     $05C3                           ; 9A18
        beq     L9A32                           ; 9A1B
        jsr     LB975                           ; 9A1D
        jmp     LBA2C                           ; 9A20

; ----------------------------------------------------------------------------
L9A23:  lda     #$00                            ; 9A23
        ldx     $05C3                           ; 9A25
        beq     L9A2C                           ; 9A28
        lda     #$00                            ; 9A2A
L9A2C:  lsr     a                               ; 9A2C
        bcc     L9A32                           ; 9A2D
        lsr     $05D1                           ; 9A2F
L9A32:  rts                                     ; 9A32

; ----------------------------------------------------------------------------
L9A33:  jsr     LB94C                           ; 9A33
        sta     $05D1                           ; 9A36
        lda     #$00                            ; 9A39
        sta     $05D2                           ; 9A3B
        beq     L9A0F                           ; 9A3E
        lda     #$00                            ; 9A40
        sta     $05D1                           ; 9A42
        sta     $05D2                           ; 9A45
        jsr     LC7F9                           ; 9A48
        lda     $0502                           ; 9A4B
        cmp     #$07                            ; 9A4E
        bcs     L9A7B                           ; 9A50
        lda     $05C2                           ; 9A52
        bne     L9A5B                           ; 9A55
        lda     #$03                            ; 9A57
        bne     L9A62                           ; 9A59
L9A5B:  jsr     LB975                           ; 9A5B
        lsr     a                               ; 9A5E
        lsr     a                               ; 9A5F
        lsr     a                               ; 9A60
        lsr     a                               ; 9A61
L9A62:  sta     $05D1                           ; 9A62
        jsr     LB969                           ; 9A65
        ldx     $05D1                           ; 9A68
        sta     $05D1                           ; 9A6B
        lda     #$00                            ; 9A6E
L9A70:  clc                                     ; 9A70
        adc     $05D1                           ; 9A71
        dex                                     ; 9A74
        bne     L9A70                           ; 9A75
        sta     $05D1                           ; 9A77
        rts                                     ; 9A7A

; ----------------------------------------------------------------------------
L9A7B:  cmp     #$23                            ; 9A7B
        bcs     L9A95                           ; 9A7D
        cmp     #$1C                            ; 9A7F
        beq     L9A95                           ; 9A81
        jsr     LB92C                           ; 9A83
        ldx     $05D3                           ; 9A86
        beq     L9A8C                           ; 9A89
        lsr     a                               ; 9A8B
L9A8C:  stx     $05D2                           ; 9A8C
        sta     $05D1                           ; 9A8F
        jmp     LBAA1                           ; 9A92

; ----------------------------------------------------------------------------
L9A95:  jsr     LB941                           ; 9A95
        ldx     $05D3                           ; 9A98
        beq     L9A9E                           ; 9A9B
        lsr     a                               ; 9A9D
L9A9E:  sta     $05D1                           ; 9A9E
        lda     $0502                           ; 9AA1
        cmp     #$24                            ; 9AA4
        beq     L9AAC                           ; 9AA6
        cmp     #$23                            ; 9AA8
        bne     L9ACF                           ; 9AAA
L9AAC:  jsr     LC7F9                           ; 9AAC
        jsr     LC837                           ; 9AAF
        beq     L9ACF                           ; 9AB2
        ldy     $05C2                           ; 9AB4
        beq     L9AC1                           ; 9AB7
        lda     $BCC1,y                         ; 9AB9
        cmp     $05C3                           ; 9ABC
        beq     L9AC5                           ; 9ABF
L9AC1:  asl     $05D1                           ; 9AC1
        rts                                     ; 9AC4

; ----------------------------------------------------------------------------
L9AC5:  lsr     $05D1                           ; 9AC5
        bne     L9ACF                           ; 9AC8
        lda     #$01                            ; 9ACA
        sta     $05D1                           ; 9ACC
L9ACF:  rts                                     ; 9ACF

; ----------------------------------------------------------------------------
        pha                                     ; 9AD0
        lda     #$33                            ; 9AD1
        jsr     LE992                           ; 9AD3
        pla                                     ; 9AD6
        sta     $059B                           ; 9AD7
        ldx     #$0A                            ; 9ADA
        stx     $059A                           ; 9ADC
L9ADF:  jsr     LE95B                           ; 9ADF
        lda     $1E                             ; 9AE2
        and     #$03                            ; 9AE4
        bne     L9ADF                           ; 9AE6
        lda     $059A                           ; 9AE8
        lsr     a                               ; 9AEB
        lda     $059B                           ; 9AEC
        bcs     L9AF7                           ; 9AEF
        jsr     LB7A9                           ; 9AF1
        jmp     LBAFA                           ; 9AF4

; ----------------------------------------------------------------------------
L9AF7:  jsr     LB767                           ; 9AF7
        dec     $059A                           ; 9AFA
        bne     L9ADF                           ; 9AFD
        rts                                     ; 9AFF

; ----------------------------------------------------------------------------
        pha                                     ; 9B00
        lda     #$26                            ; 9B01
        jsr     LE992                           ; 9B03
        pla                                     ; 9B06
        sta     $059B                           ; 9B07
        jsr     LCF3A                           ; 9B0A
        lda     $064A,y                         ; 9B0D
        sta     $05F5                           ; 9B10
        ldx     #$0A                            ; 9B13
        stx     $059A                           ; 9B15
L9B18:  jsr     LE95B                           ; 9B18
        lda     $1E                             ; 9B1B
        and     #$04                            ; 9B1D
        bne     L9B18                           ; 9B1F
        lda     $059B                           ; 9B21
        jsr     LCF3A                           ; 9B24
        lda     $059A                           ; 9B27
        lsr     a                               ; 9B2A
        lda     $059B                           ; 9B2B
        bcs     L9B43                           ; 9B2E
        ldx     $05F5                           ; 9B30
        bpl     L9B3B                           ; 9B33
        jsr     LC4E3                           ; 9B35
        jmp     LBB61                           ; 9B38

; ----------------------------------------------------------------------------
L9B3B:  lda     #$FF                            ; 9B3B
        sta     $064A,y                         ; 9B3D
        jmp     LBB61                           ; 9B40

; ----------------------------------------------------------------------------
L9B43:  lda     $059B                           ; 9B43
        ldx     $05F5                           ; 9B46
        bmi     L9B52                           ; 9B49
        txa                                     ; 9B4B
        sta     $064A,y                         ; 9B4C
        jmp     LBB61                           ; 9B4F

; ----------------------------------------------------------------------------
L9B52:  jsr     LC6F3                           ; 9B52
        lda     $054D,y                         ; 9B55
        jsr     LB8B0                           ; 9B58
        lda     $059B                           ; 9B5B
        jsr     LC3F4                           ; 9B5E
        dec     $059A                           ; 9B61
        bne     L9B18                           ; 9B64
        rts                                     ; 9B66

; ----------------------------------------------------------------------------
        lda     #$0A                            ; 9B67
        sta     $059A                           ; 9B69
L9B6C:  lda     $1E                             ; 9B6C
        and     #$07                            ; 9B6E
        bne     L9B6C                           ; 9B70
        lda     $059A                           ; 9B72
        lsr     a                               ; 9B75
        bcs     L9B82                           ; 9B76
        lda     #$80                            ; 9B78
        ora     #$21                            ; 9B7A
        jsr     LB8BF                           ; 9B7C
        jmp     LBB87                           ; 9B7F

; ----------------------------------------------------------------------------
L9B82:  lda     #$17                            ; 9B82
        jsr     LB8B0                           ; 9B84
        dec     $059A                           ; 9B87
        bne     L9B6C                           ; 9B8A
        rts                                     ; 9B8C

; ----------------------------------------------------------------------------
        jsr     LBB67                           ; 9B8D
        lda     #$80                            ; 9B90
        ora     #$21                            ; 9B92
        jsr     LB8BF                           ; 9B94
        ldx     #$06                            ; 9B97
        txa                                     ; 9B99
L9B9A:  jsr     LC6F3                           ; 9B9A
        lda     $054D,y                         ; 9B9D
        cmp     #$15                            ; 9BA0
        beq     L9BA8                           ; 9BA2
        cmp     #$17                            ; 9BA4
        bne     L9BB0                           ; 9BA6
L9BA8:  lda     $054F,y                         ; 9BA8
        ora     #$10                            ; 9BAB
        sta     $054F,y                         ; 9BAD
L9BB0:  dex                                     ; 9BB0
        txa                                     ; 9BB1
        bpl     L9B9A                           ; 9BB2
        lda     #$1D                            ; 9BB4
        jsr     LCFA1                           ; 9BB6
        rts                                     ; 9BB9

; ----------------------------------------------------------------------------
        jsr     LBB67                           ; 9BBA
        ldx     #$06                            ; 9BBD
        txa                                     ; 9BBF
L9BC0:  jsr     LC6F3                           ; 9BC0
        lda     $054D,y                         ; 9BC3
        cmp     #$15                            ; 9BC6
        beq     L9BCE                           ; 9BC8
        cmp     #$17                            ; 9BCA
        bne     L9BD6                           ; 9BCC
L9BCE:  lda     $054F,y                         ; 9BCE
        and     #$EF                            ; 9BD1
        sta     $054F,y                         ; 9BD3
L9BD6:  dex                                     ; 9BD6
        txa                                     ; 9BD7
        bpl     L9BC0                           ; 9BD8
        rts                                     ; 9BDA

; ----------------------------------------------------------------------------
        lda     $0502                           ; 9BDB
        jsr     LCE00                           ; 9BDE
        txa                                     ; 9BE1
        beq     L9BFE                           ; 9BE2
        ldy     $0503                           ; 9BE4
        iny                                     ; 9BE7
        lda     ($58),y                         ; 9BE8
        and     #$F0                            ; 9BEA
        bne     L9BFA                           ; 9BEC
        lsr     $05D1                           ; 9BEE
        bne     L9BFE                           ; 9BF1
        lda     #$01                            ; 9BF3
        sta     $05D1                           ; 9BF5
        bne     L9BFE                           ; 9BF8
L9BFA:  cmp     #$F0                            ; 9BFA
        bne     L9C02                           ; 9BFC
L9BFE:  lda     $05D1                           ; 9BFE
        rts                                     ; 9C01

; ----------------------------------------------------------------------------
L9C02:  lsr     a                               ; 9C02
        lsr     a                               ; 9C03
        lsr     a                               ; 9C04
        lsr     a                               ; 9C05
        tax                                     ; 9C06
        lda     $05D1                           ; 9C07
        sta     $00                             ; 9C0A
L9C0C:  clc                                     ; 9C0C
        adc     $00                             ; 9C0D
        dex                                     ; 9C0F
        bne     L9C0C                           ; 9C10
        tax                                     ; 9C12
        rts                                     ; 9C13

; ----------------------------------------------------------------------------
        pha                                     ; 9C14
        lda     #$33                            ; 9C15
        jsr     LE992                           ; 9C17
        pla                                     ; 9C1A
        jsr     LCF3A                           ; 9C1B
        sty     $00                             ; 9C1E
        lda     #$0A                            ; 9C20
        sta     $01                             ; 9C22
        lda     $0620,y                         ; 9C24
        sta     $02                             ; 9C27
L9C29:  jsr     LE95B                           ; 9C29
        lda     $1E                             ; 9C2C
        and     #$03                            ; 9C2E
        bne     L9C29                           ; 9C30
        lda     $01                             ; 9C32
        lsr     a                               ; 9C34
        lda     $02                             ; 9C35
        bcs     L9C3B                           ; 9C37
        lda     #$FF                            ; 9C39
L9C3B:  sta     $0620,y                         ; 9C3B
        dec     $01                             ; 9C3E
        bne     L9C29                           ; 9C40
        rts                                     ; 9C42

; ----------------------------------------------------------------------------
        pha                                     ; 9C43
        jsr     LBBDB                           ; 9C44
        ldy     $0502                           ; 9C47
        cpy     #$07                            ; 9C4A
        bcc     L9C70                           ; 9C4C
        pha                                     ; 9C4E
        jsr     LC7F9                           ; 9C4F
        jsr     LC837                           ; 9C52
        beq     L9C6F                           ; 9C55
        ldy     $05C2                           ; 9C57
        beq     L9C64                           ; 9C5A
        lda     $BCC1,y                         ; 9C5C
        cmp     $05C3                           ; 9C5F
        beq     L9C68                           ; 9C62
L9C64:  pla                                     ; 9C64
        asl     a                               ; 9C65
        bne     L9C6E                           ; 9C66
L9C68:  pla                                     ; 9C68
        lsr     a                               ; 9C69
        bne     L9C6E                           ; 9C6A
        lda     #$01                            ; 9C6C
L9C6E:  pha                                     ; 9C6E
L9C6F:  pla                                     ; 9C6F
L9C70:  sta     $0505                           ; 9C70
        sta     $01                             ; 9C73
        pla                                     ; 9C75
        tax                                     ; 9C76
        clc                                     ; 9C77
        lda     $058C,x                         ; 9C78
        adc     $01                             ; 9C7B
        sta     $058C,x                         ; 9C7D
        txa                                     ; 9C80
        bne     L9C96                           ; 9C81
        sec                                     ; 9C83
        lda     $81                             ; 9C84
        sbc     $01                             ; 9C86
        jsr     LC05E                           ; 9C88
        sta     $81                             ; 9C8B
        php                                     ; 9C8D
        lda     $05D5                           ; 9C8E
        jsr     LC5A9                           ; 9C91
        plp                                     ; 9C94
        rts                                     ; 9C95

; ----------------------------------------------------------------------------
L9C96:  cmp     #$03                            ; 9C96
        bcs     L9CB1                           ; 9C98
        jsr     LC6F3                           ; 9C9A
        lda     $050E,y                         ; 9C9D
        asl     a                               ; 9CA0
        tax                                     ; 9CA1
        sec                                     ; 9CA2
        lda     $03BE,x                         ; 9CA3
        sbc     $01                             ; 9CA6
        jsr     LC08E                           ; 9CA8
        sta     $03BE,x                         ; 9CAB
        jmp     LBC8D                           ; 9CAE

; ----------------------------------------------------------------------------
L9CB1:  jsr     LC6F3                           ; 9CB1
        lda     $0516,y                         ; 9CB4
        sec                                     ; 9CB7
        sbc     $01                             ; 9CB8
        bcs     L9CBE                           ; 9CBA
        lda     #$00                            ; 9CBC
L9CBE:  sta     $0516,y                         ; 9CBE
        rts                                     ; 9CC1

; ----------------------------------------------------------------------------
        ora     $02                             ; 9CC2
        ora     ($06,x)                         ; 9CC4
        .byte   $03                             ; 9CC6
        .byte   $04                             ; 9CC7
        pha                                     ; 9CC8
        jsr     LBBDB                           ; 9CC9
        bne     L9CD0                           ; 9CCC
        lda     #$01                            ; 9CCE
L9CD0:  ldx     $03F4                           ; 9CD0
        bne     L9CD8                           ; 9CD3
        asl     a                               ; 9CD5
        bne     L9CE2                           ; 9CD6
L9CD8:  cpx     #$08                            ; 9CD8
        bne     L9CE2                           ; 9CDA
        sta     $01                             ; 9CDC
        lsr     a                               ; 9CDE
        clc                                     ; 9CDF
        adc     $01                             ; 9CE0
L9CE2:  ldx     $05CE                           ; 9CE2
        cpx     #$03                            ; 9CE5
        bcc     L9CEF                           ; 9CE7
        sta     $01                             ; 9CE9
        lsr     a                               ; 9CEB
        clc                                     ; 9CEC
        adc     $01                             ; 9CED
L9CEF:  sta     $0505                           ; 9CEF
        sta     $01                             ; 9CF2
        pla                                     ; 9CF4
        tax                                     ; 9CF5
        lda     $0593,x                         ; 9CF6
        clc                                     ; 9CF9
        adc     $01                             ; 9CFA
        sta     $0593,x                         ; 9CFC
        txa                                     ; 9CFF
        jsr     LC6F3                           ; 9D00
        lda     $0555,y                         ; 9D03
        sec                                     ; 9D06
        sbc     $01                             ; 9D07
        bcs     L9D0D                           ; 9D09
        lda     #$00                            ; 9D0B
L9D0D:  sta     $0555,y                         ; 9D0D
        php                                     ; 9D10
        txa                                     ; 9D11
        jsr     LC551                           ; 9D12
        plp                                     ; 9D15
        rts                                     ; 9D16

; ----------------------------------------------------------------------------
        ldx     #$00                            ; 9D17
        stx     $059C                           ; 9D19
L9D1C:  txa                                     ; 9D1C
        jsr     LC6F3                           ; 9D1D
        lda     $054D,y                         ; 9D20
        cmp     $0503                           ; 9D23
        bne     L9D54                           ; 9D26
        lda     $054F,y                         ; 9D28
        and     #$10                            ; 9D2B
        beq     L9D3C                           ; 9D2D
        lda     #$00                            ; 9D2F
        sta     $0504                           ; 9D31
        lda     #$07                            ; 9D34
        jsr     LCFA1                           ; 9D36
        jmp     LBD5E                           ; 9D39

; ----------------------------------------------------------------------------
L9D3C:  lda     $054E,y                         ; 9D3C
        sta     $0504                           ; 9D3F
        lda     $0593,x                         ; 9D42
        sta     $0505                           ; 9D45
        bne     L9D4F                           ; 9D48
        lda     #$07                            ; 9D4A
        jmp     LBD51                           ; 9D4C

; ----------------------------------------------------------------------------
L9D4F:  lda     #$06                            ; 9D4F
        jsr     LCFA1                           ; 9D51
L9D54:  inc     $059C                           ; 9D54
        ldx     $059C                           ; 9D57
        cpx     #$07                            ; 9D5A
        bne     L9D1C                           ; 9D5C
        ldx     #$00                            ; 9D5E
        stx     $0504                           ; 9D60
        stx     $059C                           ; 9D63
L9D66:  lda     $058C,x                         ; 9D66
        beq     L9D85                           ; 9D69
        sta     $02                             ; 9D6B
        txa                                     ; 9D6D
        jsr     LC6F3                           ; 9D6E
        lda     $050E,y                         ; 9D71
        cmp     #$FF                            ; 9D74
        beq     L9D85                           ; 9D76
        sta     $0503                           ; 9D78
        lda     $02                             ; 9D7B
        sta     $0505                           ; 9D7D
        lda     #$06                            ; 9D80
        jsr     LCFA1                           ; 9D82
L9D85:  inc     $059C                           ; 9D85
        ldx     $059C                           ; 9D88
        cpx     #$03                            ; 9D8B
        bne     L9D66                           ; 9D8D
L9D8F:  lda     $058C,x                         ; 9D8F
        beq     L9DA8                           ; 9D92
        txa                                     ; 9D94
        jsr     LC6F3                           ; 9D95
        lda     $050E,y                         ; 9D98
        cmp     #$FF                            ; 9D9B
        beq     L9DA8                           ; 9D9D
        sta     $0503                           ; 9D9F
        lda     #$45                            ; 9DA2
        jsr     LCFA1                           ; 9DA4
        rts                                     ; 9DA7

; ----------------------------------------------------------------------------
L9DA8:  inc     $059C                           ; 9DA8
        ldx     $059C                           ; 9DAB
        cpx     #$07                            ; 9DAE
        bne     L9D8F                           ; 9DB0
        rts                                     ; 9DB2

; ----------------------------------------------------------------------------
        ldx     #$00                            ; 9DB3
        stx     $0504                           ; 9DB5
        stx     $059C                           ; 9DB8
L9DBB:  txa                                     ; 9DBB
        jsr     LC6F3                           ; 9DBC
        lda     $050E,y                         ; 9DBF
        cmp     #$FF                            ; 9DC2
        beq     L9DDB                           ; 9DC4
        sta     $0503                           ; 9DC6
        lda     $058C,x                         ; 9DC9
        sta     $0505                           ; 9DCC
        bne     L9DD6                           ; 9DCF
        lda     #$07                            ; 9DD1
        jmp     LBDD8                           ; 9DD3

; ----------------------------------------------------------------------------
L9DD6:  lda     #$06                            ; 9DD6
        jsr     LCFA1                           ; 9DD8
L9DDB:  inc     $059C                           ; 9DDB
        ldx     $059C                           ; 9DDE
        cpx     #$03                            ; 9DE1
        bne     L9DBB                           ; 9DE3
L9DE5:  lda     $058C,x                         ; 9DE5
        beq     L9E00                           ; 9DE8
        txa                                     ; 9DEA
        jsr     LC6F3                           ; 9DEB
        lda     $050E,y                         ; 9DEE
        cmp     #$FF                            ; 9DF1
        bne     L9E00                           ; 9DF3
        sta     $0503                           ; 9DF5
        lda     #$45                            ; 9DF8
        jsr     LCFA1                           ; 9DFA
        jmp     LBE0A                           ; 9DFD

; ----------------------------------------------------------------------------
L9E00:  inc     $059C                           ; 9E00
        ldx     $059C                           ; 9E03
        cpx     #$07                            ; 9E06
        bne     L9DE5                           ; 9E08
        ldx     #$00                            ; 9E0A
        stx     $059C                           ; 9E0C
L9E0F:  lda     $0593,x                         ; 9E0F
        sta     $0505                           ; 9E12
        beq     L9E30                           ; 9E15
        txa                                     ; 9E17
        jsr     LC6F3                           ; 9E18
        lda     $054D,y                         ; 9E1B
        cmp     #$FF                            ; 9E1E
        beq     L9E30                           ; 9E20
        sta     $0503                           ; 9E22
        lda     $054E,y                         ; 9E25
        sta     $0504                           ; 9E28
        lda     #$06                            ; 9E2B
        jsr     LCFA1                           ; 9E2D
L9E30:  inc     $059C                           ; 9E30
        ldx     $059C                           ; 9E33
        cpx     #$07                            ; 9E36
        bne     L9E0F                           ; 9E38
        rts                                     ; 9E3A

; ----------------------------------------------------------------------------
        lda     $05D9                           ; 9E3B
        bne     L9E41                           ; 9E3E
        rts                                     ; 9E40

; ----------------------------------------------------------------------------
L9E41:  lda     #$00                            ; 9E41
        jsr     LCFA1                           ; 9E43
        lda     #$77                            ; 9E46
        jsr     LE992                           ; 9E48
        lda     #$00                            ; 9E4B
        jsr     LE029                           ; 9E4D
        lda     #$77                            ; 9E50
        jsr     LE992                           ; 9E52
        lda     #$01                            ; 9E55
        sta     $059C                           ; 9E57
        ldx     #$0D                            ; 9E5A
        txa                                     ; 9E5C
L9E5D:  lda     $0460,x                         ; 9E5D
        cmp     $059C                           ; 9E60
        beq     L9E69                           ; 9E63
        dex                                     ; 9E65
        bpl     L9E5D                           ; 9E66
        rts                                     ; 9E68

; ----------------------------------------------------------------------------
L9E69:  inc     $059C                           ; 9E69
        stx     $05D5                           ; 9E6C
        stx     $51                             ; 9E6F
        cpx     #$07                            ; 9E71
        bcc     L9E78                           ; 9E73
        jmp     LBF12                           ; 9E75

; ----------------------------------------------------------------------------
L9E78:  lda     #$10                            ; 9E78
        sta     $0500                           ; 9E7A
        txa                                     ; 9E7D
        cmp     #$03                            ; 9E7E
        bcc     L9E8D                           ; 9E80
        sec                                     ; 9E82
        sbc     #$03                            ; 9E83
        sta     $50                             ; 9E85
        jsr     LBAD0                           ; 9E87
        jmp     LBE90                           ; 9E8A

; ----------------------------------------------------------------------------
L9E8D:  jsr     LBC14                           ; 9E8D
        lda     $51                             ; 9E90
        tax                                     ; 9E92
        jsr     LC6F3                           ; 9E93
        lda     $050E,y                         ; 9E96
        sta     $0503                           ; 9E99
        lda     $058C,x                         ; 9E9C
        sta     $0505                           ; 9E9F
        txa                                     ; 9EA2
        bne     L9EE3                           ; 9EA3
        sec                                     ; 9EA5
        lda     $81                             ; 9EA6
        sbc     $0505                           ; 9EA8
        jsr     LC05E                           ; 9EAB
        sta     $81                             ; 9EAE
        php                                     ; 9EB0
        lda     $51                             ; 9EB1
        jsr     LC5A9                           ; 9EB3
        plp                                     ; 9EB6
        beq     L9EC1                           ; 9EB7
        lda     #$06                            ; 9EB9
        jsr     LCFA1                           ; 9EBB
        jmp     LBE5A                           ; 9EBE

; ----------------------------------------------------------------------------
L9EC1:  lda     $51                             ; 9EC1
        ldx     #$00                            ; 9EC3
        jsr     LC13B                           ; 9EC5
        ldx     #$0C                            ; 9EC8
        lda     $51                             ; 9ECA
        cmp     #$03                            ; 9ECC
        bcc     L9ED2                           ; 9ECE
        ldx     #$45                            ; 9ED0
L9ED2:  txa                                     ; 9ED2
        jsr     LCFA1                           ; 9ED3
        lda     $51                             ; 9ED6
        jsr     LC6F3                           ; 9ED8
        lda     #$FF                            ; 9EDB
        sta     $050E,y                         ; 9EDD
        jmp     LBE5A                           ; 9EE0

; ----------------------------------------------------------------------------
L9EE3:  cmp     #$03                            ; 9EE3
        bcs     L9EFC                           ; 9EE5
        lda     $050E,y                         ; 9EE7
        asl     a                               ; 9EEA
        tax                                     ; 9EEB
        sec                                     ; 9EEC
        lda     $03BE,x                         ; 9EED
        sbc     $0505                           ; 9EF0
        jsr     LC08E                           ; 9EF3
        sta     $03BE,x                         ; 9EF6
        jmp     LBEB0                           ; 9EF9

; ----------------------------------------------------------------------------
L9EFC:  jsr     LC6F3                           ; 9EFC
        lda     $0516,y                         ; 9EFF
        sec                                     ; 9F02
        sbc     $0505                           ; 9F03
        bpl     L9F0A                           ; 9F06
        lda     #$00                            ; 9F08
L9F0A:  sta     $0516,y                         ; 9F0A
        beq     L9EC1                           ; 9F0D
        jmp     LBE5A                           ; 9F0F

; ----------------------------------------------------------------------------
        txa                                     ; 9F12
        sec                                     ; 9F13
        sbc     #$07                            ; 9F14
        sta     $51                             ; 9F16
        jsr     LC6F3                           ; 9F18
        lda     $054F,y                         ; 9F1B
        and     #$10                            ; 9F1E
        beq     L9F3B                           ; 9F20
        lda     #$00                            ; 9F22
        sta     $0500                           ; 9F24
        lda     $054D,y                         ; 9F27
        sta     $0503                           ; 9F2A
        lda     $054E,y                         ; 9F2D
        sta     $0504                           ; 9F30
        lda     #$4C                            ; 9F33
        jsr     LCFA1                           ; 9F35
        jmp     LBE5A                           ; 9F38

; ----------------------------------------------------------------------------
L9F3B:  lda     $51                             ; 9F3B
        .byte   $20                             ; 9F3D
        brk                                     ; 9F3E
L9F3F:  .byte   $BB                             ; 9F3F
        lda     $51                             ; 9F40
L9F42:  jsr     LC6F3                           ; 9F42
        lda     #$00                            ; 9F45
        sta     $0500                           ; 9F47
        lda     $054D,y                         ; 9F4A
        sta     $0503                           ; 9F4D
        lda     $054E,y                         ; 9F50
        sta     $0504                           ; 9F53
        ldx     $51                             ; 9F56
        lda     $0593,x                         ; 9F58
        sta     $0505                           ; 9F5B
        lda     $0555,y                         ; 9F5E
        sec                                     ; 9F61
        sbc     $0505                           ; 9F62
        bpl     L9F69                           ; 9F65
        lda     #$00                            ; 9F67
L9F69:  sta     $0555,y                         ; 9F69
        php                                     ; 9F6C
        lda     $51                             ; 9F6D
        jsr     LC551                           ; 9F6F
        plp                                     ; 9F72
        beq     L9F7D                           ; 9F73
        lda     #$06                            ; 9F75
        jsr     LCFA1                           ; 9F77
        jmp     LBE5A                           ; 9F7A

; ----------------------------------------------------------------------------
L9F7D:  lda     $51                             ; 9F7D
        ldx     #$00                            ; 9F7F
        jsr     LC0C4                           ; 9F81
        lda     $51                             ; 9F84
        jsr     LC52E                           ; 9F86
        lda     #$09                            ; 9F89
        jsr     LCFA1                           ; 9F8B
        lda     $51                             ; 9F8E
        jsr     LC6F3                           ; 9F90
        lda     #$FF                            ; 9F93
        sta     $054D,y                         ; 9F95
        lda     $0503                           ; 9F98
        jsr     LCAE1                           ; 9F9B
        jmp     LBE5A                           ; 9F9E

; ----------------------------------------------------------------------------
        ldx     $05F6                           ; 9FA1
        beq     L9FCF                           ; 9FA4
        dex                                     ; 9FA6
        stx     $05F6                           ; 9FA7
        bne     L9FD0                           ; 9FAA
        stx     $12                             ; 9FAC
        stx     $13                             ; 9FAE
        lda     #$0E                            ; 9FB0
        sta     $00                             ; 9FB2
        ldy     #$00                            ; 9FB4
        ldx     #$04                            ; 9FB6
L9FB8:  lda     L8C85,y                         ; 9FB8
        sta     $0620,x                         ; 9FBB
        iny                                     ; 9FBE
        lda     L8C85,y                         ; 9FBF
        sta     $0621,x                         ; 9FC2
        iny                                     ; 9FC5
        txa                                     ; 9FC6
        clc                                     ; 9FC7
        adc     #$06                            ; 9FC8
        tax                                     ; 9FCA
        dec     $00                             ; 9FCB
        bne     L9FB8                           ; 9FCD
L9FCF:  rts                                     ; 9FCF

; ----------------------------------------------------------------------------
L9FD0:  lda     $1E                             ; 9FD0
        and     #$03                            ; 9FD2
        bne     L9FCF                           ; 9FD4
L9FD6:  lda     PPU_STATUS                      ; 9FD6
        and     #$40                            ; 9FD9
        beq     L9FD6                           ; 9FDB
        clc                                     ; 9FDD
        lda     $05F8                           ; 9FDE
        adc     #$01                            ; 9FE1
        sta     $05F8                           ; 9FE3
        cmp     #$04                            ; 9FE6
        bcc     L9FEF                           ; 9FE8
        lda     #$03                            ; 9FEA
        sta     $05F8                           ; 9FEC
L9FEF:  lda     $05F7                           ; 9FEF
        eor     #$01                            ; 9FF2
        sta     $05F7                           ; 9FF4
        lsr     a                               ; 9FF7
        lda     $05F8                           ; 9FF8
        sta     $00                             ; 9FFB
        bcs     LA005                           ; 9FFD
        .byte   $49                             ; 9FFF
