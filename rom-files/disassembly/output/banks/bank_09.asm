; ============================================================================
; The Magic of Scheherazade - Bank 09 Disassembly
; ============================================================================
; File Offset: 0x12000 - 0x13FFF
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
; Created:    2026-01-24 04:39:27
; Input file: C:/claude-workspace/TMOS_AI/rom-files/disassembly/output/banks/bank_09.bin
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
L0130           := $0130
PPU_CTRL        := $2000
PPU_MASK        := $2001
PPU_STATUS      := $2002
OAM_ADDR        := $2003
OAM_DATA        := $2004
PPU_SCROLL      := $2005
PPU_ADDR        := $2006
PPU_DATA        := $2007
L2220           := $2220
L2620           := $2620
L31C2           := $31C2
OAM_DMA         := $4014
APU_STATUS      := $4015
JOY1            := $4016
JOY2_FRAME      := $4017
L4DFF           := $4DFF
L6C6C           := $6C6C
L706E           := $706E
LE080           := $E080
LE083           := $E083
LF032           := $F032
LF038           := $F038
LFF21           := $FF21
; ----------------------------------------------------------------------------
        lda     $4C                             ; 8000
        lda     $4C                             ; 8002
        lda     $4C                             ; 8004
        lda     $4C                             ; 8006
        lda     $4C                             ; 8008
        lda     $4C                             ; 800A
        lda     $4C                             ; 800C
L800E:  lda     $4C                             ; 800E
        lda     $4C                             ; 8010
        lda     $4C                             ; 8012
        lda     $4C                             ; 8014
        lda     $4C                             ; 8016
        lda     $4C                             ; 8018
        lda     $4C                             ; 801A
        lda     $4C                             ; 801C
        lda     $4C                             ; 801E
        lda     $4C                             ; 8020
        lda     $4C                             ; 8022
        lda     $4C                             ; 8024
        lda     $4C                             ; 8026
        lda     $4C                             ; 8028
        lda     $4C                             ; 802A
        .byte   $A5                             ; 802C
L802D:  jmp     $4CA5                           ; 802D

; ----------------------------------------------------------------------------
        lda     $4C                             ; 8030
        lda     $4C                             ; 8032
        lda     $4C                             ; 8034
        lda     $4C                             ; 8036
        lda     $4C                             ; 8038
        lda     $BB                             ; 803A
        ldy     #$BB                            ; 803C
        ldy     #$65                            ; 803E
        lda     ($BB,x)                         ; 8040
        ldy     #$BB                            ; 8042
        ldy     #$9D                            ; 8044
        lda     ($CB,x)                         ; 8046
        lda     ($E5,x)                         ; 8048
        lda     ($E5,x)                         ; 804A
        lda     ($2D,x)                         ; 804C
        ldx     #$2D                            ; 804E
        ldx     #$2D                            ; 8050
        ldx     #$2D                            ; 8052
        ldx     #$45                            ; 8054
        ldx     #$45                            ; 8056
        ldx     #$67                            ; 8058
        ldx     #$6F                            ; 805A
        ldx     #$8D                            ; 805C
        ldx     #$8D                            ; 805E
        ldx     #$AB                            ; 8060
        ldx     #$CF                            ; 8062
        ldx     #$D3                            ; 8064
        ldx     #$E1                            ; 8066
        ldx     #$E5                            ; 8068
        ldx     #$ED                            ; 806A
        ldx     #$07                            ; 806C
        .byte   $A3                             ; 806E
        .byte   $0B                             ; 806F
        .byte   $A3                             ; 8070
        sta     $0FA2                           ; 8071
        .byte   $A3                             ; 8074
        .byte   $23                             ; 8075
        .byte   $A3                             ; 8076
        .byte   $2B                             ; 8077
        .byte   $A3                             ; 8078
        .byte   $D3                             ; 8079
        ldx     #$2F                            ; 807A
        .byte   $A3                             ; 807C
        and     $49A3,x                         ; 807D
        .byte   $A3                             ; 8080
        eor     $5FA3,y                         ; 8081
        .byte   $A3                             ; 8084
        adc     L8BA3,y                         ; 8085
        .byte   $A3                             ; 8088
        sta     $ABA3,x                         ; 8089
        .byte   $A3                             ; 808C
        .byte   $AB                             ; 808D
        .byte   $A3                             ; 808E
        .byte   $AB                             ; 808F
        .byte   $A3                             ; 8090
        .byte   $C3                             ; 8091
        .byte   $A3                             ; 8092
        .byte   $C3                             ; 8093
        .byte   $A3                             ; 8094
        .byte   $C3                             ; 8095
        .byte   $A3                             ; 8096
        .byte   $CB                             ; 8097
        .byte   $A3                             ; 8098
        .byte   $CB                             ; 8099
        .byte   $A3                             ; 809A
        .byte   $CB                             ; 809B
        .byte   $A3                             ; 809C
        cmp     $DDA3,x                         ; 809D
        .byte   $A3                             ; 80A0
        cmp     $E7A3,x                         ; 80A1
        .byte   $A3                             ; 80A4
        .byte   $EB                             ; 80A5
        .byte   $A3                             ; 80A6
        .byte   $EF                             ; 80A7
        .byte   $A3                             ; 80A8
        sbc     $09A3,x                         ; 80A9
        ldy     $09                             ; 80AC
        ldy     $09                             ; 80AE
        ldy     $00                             ; 80B0
        brk                                     ; 80B2
        brk                                     ; 80B3
        brk                                     ; 80B4
        ora     $1DA4                           ; 80B5
        ldy     $21                             ; 80B8
        ldy     $8E                             ; 80BA
        lda     $AD7C                           ; 80BC
        ror     a                               ; 80BF
        lda     $AD8F                           ; 80C0
        adc     $6BAD,x                         ; 80C3
        lda     $AC04                           ; 80C6
        ora     $AC,x                           ; 80C9
        rol     $AC                             ; 80CB
        .byte   $37                             ; 80CD
        ldy     $AD7C                           ; 80CE
        adc     $15AD,x                         ; 80D1
        ldy     $AC37                           ; 80D4
        .byte   $FC                             ; 80D7
        lda     $AE12                           ; 80D8
        sbc     $13AD,x                         ; 80DB
        ldx     $ACBE                           ; 80DE
        .byte   $D3                             ; 80E1
        ldy     $AD40                           ; 80E2
        eor     $AD,x                           ; 80E5
        ldy     #$AD                            ; 80E7
        ldx     $AD,y                           ; 80E9
        lda     ($AD,x)                         ; 80EB
        .byte   $B7                             ; 80ED
        lda     $AC66                           ; 80EE
        .byte   $7B                             ; 80F1
        ldy     $ACE8                           ; 80F2
        sbc     $CCAC,x                         ; 80F5
        lda     $ADE2                           ; 80F8
        cmp     $E3AD                           ; 80FB
        lda     $AC90                           ; 80FE
        lda     #$AC                            ; 8101
        .byte   $12                             ; 8103
        lda     $AD2B                           ; 8104
        and     $4AAE,y                         ; 8107
        ldx     $AE5C                           ; 810A
        .byte   $52                             ; 810D
        .byte   $B1                             ; 810E
L810F:  .byte   $63                             ; 810F
        lda     ($7C),y                         ; 8110
        lda     ($9D),y                         ; 8112
        lda     ($B6),y                         ; 8114
        lda     ($F7),y                         ; 8116
        clv                                     ; 8118
        sbc     $F8B8,x                         ; 8119
        clv                                     ; 811C
        .byte   $FE                             ; 811D
L811E:  clv                                     ; 811E
        .byte   $03                             ; 811F
        lda     $B908,y                         ; 8120
        ora     $12B9                           ; 8123
        lda     $B917,y                         ; 8126
        ora     $18B9,x                         ; 8129
        lda     $B91E,y                         ; 812C
        .byte   $23                             ; 812F
        lda     $B928,y                         ; 8130
        and     $32B9                           ; 8133
        lda     $B937,y                         ; 8136
        and     $38B9,x                         ; 8139
        lda     $B93E,y                         ; 813C
        .byte   $47                             ; 813F
        lda     $B950,y                         ; 8140
        eor     $B9,x                           ; 8143
        lsr     $ABB9,x                         ; 8145
        ldx     $AEB5                           ; 8148
        .byte   $BF                             ; 814B
        ldx     $B963                           ; 814C
        .byte   $64                             ; 814F
L8150:  lda     $B969,y                         ; 8150
        ror     $14B9                           ; 8153
        .byte   $AF                             ; 8156
        pha                                     ; 8157
        ldy     $B861                           ; 8158
        .byte   $72                             ; 815B
        clv                                     ; 815C
        .byte   $7B                             ; 815D
        clv                                     ; 815E
        bcs     L810F                           ; 815F
        tsx                                     ; 8161
        ldx     $AC4D                           ; 8162
        asl     a                               ; 8165
        lda     ($13),y                         ; 8166
        lda     ($99),y                         ; 8168
        ldx     $AEA2                           ; 816A
        .byte   $1C                             ; 816D
        lda     ($25),y                         ; 816E
        lda     ($04),y                         ; 8170
        .byte   $B3                             ; 8172
        .byte   $04                             ; 8173
        .byte   $B3                             ; 8174
        adc     $AE                             ; 8175
        ror     $F2AE                           ; 8177
        .byte   $B2                             ; 817A
        .byte   $FB                             ; 817B
        .byte   $B2                             ; 817C
        adc     $B2                             ; 817D
        cpy     $B0                             ; 817F
L8181:  adc     L86AE,x                         ; 8181
        ldx     $B0CD                           ; 8184
        ror     $BBB2                           ; 8187
L818A:  bcs     L8150                           ; 818A
        bcs     L811E                           ; 818C
        ldx     $AE8F                           ; 818E
        cmp     $CDB0                           ; 8191
        bcs     L820E                           ; 8194
        ldx     $AE77                           ; 8196
L8199:  .byte   $04                             ; 8199
        ldy     $AC04                           ; 819A
        .byte   $73                             ; 819D
        lda     $B98C,y                         ; 819E
        lda     $B9                             ; 81A1
        .byte   $5C                             ; 81A3
        .byte   $B2                             ; 81A4
        .byte   $53                             ; 81A5
        ldx     $B12E                           ; 81A6
        .byte   $37                             ; 81A9
        lda     ($40),y                         ; 81AA
        lda     ($49),y                         ; 81AC
        .byte   $B1                             ; 81AE
L81AF:  beq     *-78                            ; 81AF
        sbc     $D6B0,x                         ; 81B1
        bcs     L8199                           ; 81B4
        bcs     L8214                           ; 81B6
        ldx     $AE28                           ; 81B8
        .byte   $C7                             ; 81BB
        lda     $B9D8,y                         ; 81BC
        adc     ($B8,x)                         ; 81BF
        .byte   $72                             ; 81C1
        clv                                     ; 81C2
        .byte   $7B                             ; 81C3
        clv                                     ; 81C4
        .byte   $2B                             ; 81C5
        .byte   $B7                             ; 81C6
        .byte   $1B                             ; 81C7
        lda     $BB1E,x                         ; 81C8
        iny                                     ; 81CB
        ldx     $B152                           ; 81CC
        .byte   $63                             ; 81CF
        lda     ($7C),y                         ; 81D0
        lda     ($9D),y                         ; 81D2
        lda     ($B6),y                         ; 81D4
        lda     ($CD),y                         ; 81D6
        ldx     $AEDE                           ; 81D8
        .byte   $DF                             ; 81DB
        ldx     $AEE8                           ; 81DC
        sbc     ($AE),y                         ; 81DF
        .byte   $FA                             ; 81E1
        ldx     $AF03                           ; 81E2
        ldx     $C0BB                           ; 81E5
        .byte   $BB                             ; 81E8
        .byte   $AF                             ; 81E9
        .byte   $BB                             ; 81EA
        cmp     ($BB,x)                         ; 81EB
        sty     L9DBB                           ; 81ED
        .byte   $BB                             ; 81F0
        .byte   $D2                             ; 81F1
        .byte   $BB                             ; 81F2
        .byte   $E3                             ; 81F3
        .byte   $BB                             ; 81F4
        .byte   $F4                             ; 81F5
        .byte   $BB                             ; 81F6
        inc     $F5BB,x                         ; 81F7
        .byte   $BB                             ; 81FA
        .byte   $FF                             ; 81FB
        .byte   $BB                             ; 81FC
        rol     a                               ; 81FD
        .byte   $BC                             ; 81FE
        .byte   $3C                             ; 81FF
L8200:  ldy     $BC2B,x                         ; 8200
        and     $08BC,x                         ; 8203
        .byte   $BC                             ; 8206
L8207:  ora     $4EBC,y                         ; 8207
        ldy     $BC5F,x                         ; 820A
        brk                                     ; 820D
L820E:  brk                                     ; 820E
        pla                                     ; 820F
        ldy     $BC81,x                         ; 8210
        .byte   $BC                             ; 8213
L8214:  ldy     $BCCE,x                         ; 8214
        lda     $CFBC,x                         ; 8217
        ldy     $BC9A,x                         ; 821A
        .byte   $AB                             ; 821D
        ldy     a:$00,x                         ; 821E
        .byte   $52                             ; 8221
        lda     ($63),y                         ; 8222
        lda     ($7C),y                         ; 8224
        lda     ($9D),y                         ; 8226
        lda     ($B6),y                         ; 8228
        lda     ($CD),y                         ; 822A
        ldx     $AF2C                           ; 822C
        and     $AF,x                           ; 822F
        .byte   $23                             ; 8231
        .byte   $AF                             ; 8232
        ora     $1EAF,y                         ; 8233
        .byte   $AF                             ; 8236
        lda     $AE,x                           ; 8237
        rol     $B5AF,x                         ; 8239
        ldx     $AF4C                           ; 823C
        .byte   $0C                             ; 823F
        .byte   $BB                             ; 8240
        ora     $BB,x                           ; 8241
        .byte   $43                             ; 8243
        .byte   $AF                             ; 8244
        .byte   $9E                             ; 8245
        lda     $16,x                           ; 8246
L8248:  lda     $BD11,x                         ; 8248
        .byte   $DC                             ; 824B
        ldx     $D7,y                           ; 824C
        ldx     $CA,y                           ; 824E
        .byte   $AF                             ; 8250
        .byte   $A7                             ; 8251
        bcs     L8200                           ; 8252
        bcs     L8207                           ; 8254
        bcs     L820E                           ; 8256
        bcs     L82AC                           ; 8258
        .byte   $B2                             ; 825A
        .byte   $57                             ; 825B
        .byte   $B2                             ; 825C
        lda     $6DB4                           ; 825D
        .byte   $B7                             ; 8260
        .byte   $D4                             ; 8261
        .byte   $AF                             ; 8262
        .byte   $02                             ; 8263
        lda     $AEC8,x                         ; 8264
        .byte   $73                             ; 8267
        lda     $B98C,y                         ; 8268
        lda     $B9                             ; 826B
        ldx     $52B9,y                         ; 826D
        lda     ($63),y                         ; 8270
        lda     ($7C),y                         ; 8272
        lda     ($9D),y                         ; 8274
        lda     ($B6),y                         ; 8276
        lda     ($78),y                         ; 8278
        ldx     $AE77                           ; 827A
        ora     $19AF,y                         ; 827D
        .byte   $AF                             ; 8280
        asl     $1EAF,x                         ; 8281
        .byte   $AF                             ; 8284
        adc     L86AE,x                         ; 8285
        ldx     $AE99                           ; 8288
        ldx     #$AE                            ; 828B
        sta     $B5,x                           ; 828D
        sty     $B5,x                           ; 828F
        bvs     L8248                           ; 8291
        .byte   $82                             ; 8293
        lda     $71,x                           ; 8294
        lda     $83,x                           ; 8296
        lda     $2C,x                           ; 8298
        lda     $3D,x                           ; 829A
        lda     $4E,x                           ; 829C
        lda     $5F,x                           ; 829E
        lda     $52,x                           ; 82A0
        lda     ($63),y                         ; 82A2
        lda     ($7C),y                         ; 82A4
        lda     ($9D),y                         ; 82A6
        lda     ($B6),y                         ; 82A8
        lda     ($0B),y                         ; 82AA
L82AC:  ldx     $21,y                           ; 82AC
        ldx     $0C,y                           ; 82AE
        ldx     $22,y                           ; 82B0
        ldx     $C7,y                           ; 82B2
        lda     $D8,x                           ; 82B4
        lda     $E9,x                           ; 82B6
        lda     $FA,x                           ; 82B8
        lda     $2E,x                           ; 82BA
        lda     ($37),y                         ; 82BC
        lda     ($40),y                         ; 82BE
        lda     ($49),y                         ; 82C0
        lda     ($37),y                         ; 82C2
        ldx     $4D,y                           ; 82C4
        ldx     $38,y                           ; 82C6
        ldx     $4E,y                           ; 82C8
        ldx     $76,y                           ; 82CA
        ldx     $64,y                           ; 82CC
        ldx     $59,y                           ; 82CE
        ldy     $6A,x                           ; 82D0
        ldy     $ED,x                           ; 82D2
        ldy     $F6,x                           ; 82D4
        ldy     $07,x                           ; 82D6
        lda     $B2,x                           ; 82D8
        ldy     $B2,x                           ; 82DA
        ldy     $94,x                           ; 82DC
        ldy     $7B,x                           ; 82DE
        ldy     $E0,x                           ; 82E0
        ldy     $BCF5,x                         ; 82E2
        lda     $B5,x                           ; 82E5
        ldx     $A3B5,y                         ; 82E7
        lda     $AC,x                           ; 82EA
        .byte   $B5                             ; 82EC
L82ED:  ora     $2EB3                           ; 82ED
        .byte   $B3                             ; 82F0
        .byte   $4F                             ; 82F1
L82F2:  .byte   $B3                             ; 82F2
        pla                                     ; 82F3
        .byte   $B3                             ; 82F4
        .byte   $82                             ; 82F5
        .byte   $B3                             ; 82F6
        adc     #$B3                            ; 82F7
        .byte   $83                             ; 82F9
        .byte   $B3                             ; 82FA
        .byte   $9C                             ; 82FB
        .byte   $B3                             ; 82FC
L82FD:  ldx     $E0B3,y                         ; 82FD
        .byte   $B3                             ; 8300
        .byte   $AD                             ; 8301
L8302:  .byte   $B3                             ; 8302
        .byte   $CF                             ; 8303
        .byte   $B3                             ; 8304
        sbc     ($B3),y                         ; 8305
        sec                                     ; 8307
        ldy     $37,x                           ; 8308
        ldy     $21,x                           ; 830A
        .byte   $B4                             ; 830C
L830D:  jsr     $67B4                           ; 830D
        tsx                                     ; 8310
        .byte   $07                             ; 8311
L8312:  lda     $BA71,x                         ; 8312
        pla                                     ; 8315
        tsx                                     ; 8316
        php                                     ; 8317
        lda     $BA72,x                         ; 8318
        sbc     $7BB4                           ; 831B
        tsx                                     ; 831E
        .byte   $23                             ; 831F
        .byte   $BB                             ; 8320
        bit     $BB                             ; 8321
        sbc     ($B6,x)                         ; 8323
        .byte   $EB                             ; 8325
        ldx     $E2,y                           ; 8326
        ldx     $EC,y                           ; 8328
        ldx     $CB,y                           ; 832A
        ldy     $DC,x                           ; 832C
        ldy     $52,x                           ; 832E
        lda     ($63),y                         ; 8330
        lda     ($7C),y                         ; 8332
        lda     ($9D),y                         ; 8334
        lda     ($B6),y                         ; 8336
        lda     ($DA),y                         ; 8338
        .byte   $AF                             ; 833A
        cmp     $19AF,y                         ; 833B
        .byte   $B7                             ; 833E
        .byte   $1A                             ; 833F
        .byte   $B7                             ; 8340
        sbc     $B6,x                           ; 8341
        .byte   $07                             ; 8343
        .byte   $B7                             ; 8344
        inc     $B6,x                           ; 8345
        php                                     ; 8347
        .byte   $B7                             ; 8348
        php                                     ; 8349
        tsx                                     ; 834A
        and     ($BA,x)                         ; 834B
        sty     $A5B6                           ; 834D
        ldx     $3A,y                           ; 8350
        tsx                                     ; 8352
        ldx     $D7B6,y                         ; 8353
        ldx     $DC,y                           ; 8356
        ldx     $03,y                           ; 8358
        ldy     $02,x                           ; 835A
        ldy     $32,x                           ; 835C
        ldy     $52,x                           ; 835E
        lda     ($63),y                         ; 8360
        .byte   $B1                             ; 8362
L8363:  .byte   $7C                             ; 8363
        lda     ($9D),y                         ; 8364
        lda     ($B6),y                         ; 8366
        lda     ($6F),y                         ; 8368
L836A:  bcs     L82ED                           ; 836A
        bcs     L83DE                           ; 836C
        bcs     L82F2                           ; 836E
        .byte   $B0                             ; 8370
L8371:  .byte   $8B                             ; 8371
        bcs     L830D                           ; 8372
        bcs     L8302                           ; 8374
        bcs     L8312                           ; 8376
L8378:  .byte   $B0                             ; 8378
L8379:  .byte   $52                             ; 8379
        lda     ($63),y                         ; 837A
        lda     ($7C),y                         ; 837C
        lda     ($9D),y                         ; 837E
        lda     ($B6),y                         ; 8380
        lda     ($D0),y                         ; 8382
        .byte   $B2                             ; 8384
        .byte   $CF                             ; 8385
        .byte   $B2                             ; 8386
        sbc     ($B2,x)                         ; 8387
        sbc     ($B2,x)                         ; 8389
        .byte   $52                             ; 838B
        lda     ($63),y                         ; 838C
        lda     ($7C),y                         ; 838E
        lda     ($9D),y                         ; 8390
        lda     ($B6),y                         ; 8392
        lda     ($C8),y                         ; 8394
        lda     ($C7),y                         ; 8396
        lda     ($D6),y                         ; 8398
        lda     ($D5),y                         ; 839A
        lda     ($52),y                         ; 839C
        lda     ($63),y                         ; 839E
        lda     ($7C),y                         ; 83A0
        lda     ($9D),y                         ; 83A2
        lda     ($B6),y                         ; 83A4
        lda     ($B9),y                         ; 83A6
        .byte   $AF                             ; 83A8
        clv                                     ; 83A9
        .byte   $AF                             ; 83AA
        .byte   $FB                             ; 83AB
        .byte   $AF                             ; 83AC
        ora     $FCB0,y                         ; 83AD
        .byte   $AF                             ; 83B0
        .byte   $1A                             ; 83B1
        bcs     L83E7                           ; 83B2
        bcs     L83EA                           ; 83B4
        bcs     L8409                           ; 83B6
        bcs     L840C                           ; 83B8
        bcs     L8363                           ; 83BA
        bcs     L836A                           ; 83BC
        bcs     L8371                           ; 83BE
        bcs     L8378                           ; 83C0
        bcs     L843B                           ; 83C2
        .byte   $B2                             ; 83C4
        bcc     L8379                           ; 83C5
        lda     #$B2                            ; 83C7
        dex                                     ; 83C9
        .byte   $B2                             ; 83CA
        .byte   $30                             ; 83CB
L83CC:  .byte   $B2                             ; 83CC
        .byte   $2F                             ; 83CD
        .byte   $B2                             ; 83CE
        eor     ($B2,x)                         ; 83CF
        .byte   $E3                             ; 83D1
        lda     ($FC),y                         ; 83D2
        lda     ($16),y                         ; 83D4
        .byte   $B2                             ; 83D6
        sbc     $52B1,x                         ; 83D7
        .byte   $B2                             ; 83DA
        .byte   $57                             ; 83DB
        .byte   $B2                             ; 83DC
        .byte   $55                             ; 83DD
L83DE:  .byte   $AF                             ; 83DE
        ror     $AF,x                           ; 83DF
        .byte   $97                             ; 83E1
        .byte   $AF                             ; 83E2
        dex                                     ; 83E3
        .byte   $AF                             ; 83E4
        .byte   $CF                             ; 83E5
        .byte   $AF                             ; 83E6
L83E7:  rts                                     ; 83E7

; ----------------------------------------------------------------------------
        .byte   $B7                             ; 83E8
        .byte   $F2                             ; 83E9
L83EA:  lda     $BAF3,y                         ; 83EA
        .byte   $4F                             ; 83ED
        .byte   $BB                             ; 83EE
        .byte   $80                             ; 83EF
        clv                                     ; 83F0
        cmp     ($B8,x)                         ; 83F1
        .byte   $D3                             ; 83F3
        clv                                     ; 83F4
        sbc     $B8                             ; 83F5
        .byte   $C2                             ; 83F7
        clv                                     ; 83F8
        .byte   $D4                             ; 83F9
        clv                                     ; 83FA
        inc     $B8                             ; 83FB
        .byte   $72                             ; 83FD
        .byte   $B7                             ; 83FE
        ldy     $73B7,x                         ; 83FF
        .byte   $B7                             ; 8402
        lda     $0BB7,x                         ; 8403
        clv                                     ; 8406
        asl     a                               ; 8407
        clv                                     ; 8408
L8409:  cli                                     ; 8409
        clv                                     ; 840A
        .byte   $FF                             ; 840B
L840C:  lda     $BAD1,y                         ; 840C
        .byte   $E2                             ; 840F
        tsx                                     ; 8410
        .byte   $A3                             ; 8411
        tsx                                     ; 8412
        .byte   $7B                             ; 8413
        tsx                                     ; 8414
        txs                                     ; 8415
        tsx                                     ; 8416
        ldy     $BA,x                           ; 8417
        and     $3EBB                           ; 8419
        .byte   $BB                             ; 841C
        dey                                     ; 841D
        tsx                                     ; 841E
        sta     ($BA),y                         ; 841F
        .byte   $53                             ; 8421
        tsx                                     ; 8422
        eor     $54BA,x                         ; 8423
        tsx                                     ; 8426
        lsr     a:$BA,x                         ; 8427
        ora     ($02,x)                         ; 842A
        inc     $0403,x                         ; 842C
        ora     $FE                             ; 842F
        asl     $07                             ; 8431
        inc     $0908,x                         ; 8433
        inc     $FF0A,x                         ; 8436
        .byte   $0B                             ; 8439
        .byte   $FF                             ; 843A
L843B:  .byte   $0C                             ; 843B
        .byte   $FF                             ; 843C
        ora     $0EFF                           ; 843D
        .byte   $0F                             ; 8440
        .byte   $FF                             ; 8441
        bpl     L8455                           ; 8442
        .byte   $FF                             ; 8444
        .byte   $12                             ; 8445
        .byte   $13                             ; 8446
        .byte   $FF                             ; 8447
        .byte   $14                             ; 8448
        ora     $FF,x                           ; 8449
        asl     $17,x                           ; 844B
        .byte   $FF                             ; 844D
        clc                                     ; 844E
        ora     $1AFF,y                         ; 844F
        .byte   $1B                             ; 8452
        .byte   $FF                             ; 8453
        .byte   $1C                             ; 8454
L8455:  ora     $1EFF,x                         ; 8455
        .byte   $1F                             ; 8458
        .byte   $FF                             ; 8459
        jsr     LFF21                           ; 845A
        .byte   $22                             ; 845D
        .byte   $23                             ; 845E
        .byte   $FF                             ; 845F
        bit     $25                             ; 8460
        .byte   $FF                             ; 8462
        rol     $27                             ; 8463
        plp                                     ; 8465
        .byte   $FF                             ; 8466
        and     #$2A                            ; 8467
        .byte   $2B                             ; 8469
        bit     L802D                           ; 846A
        rol     $FF2F                           ; 846D
        bmi     L84A3                           ; 8470
        .byte   $FF                             ; 8472
        .byte   $32                             ; 8473
        .byte   $33                             ; 8474
        .byte   $FF                             ; 8475
        .byte   $34                             ; 8476
        and     $FF,x                           ; 8477
        rol     $37,x                           ; 8479
        .byte   $FF                             ; 847B
        sec                                     ; 847C
        and     $3AFF,y                         ; 847D
        .byte   $3B                             ; 8480
        .byte   $FF                             ; 8481
        .byte   $3C                             ; 8482
        and     $3EFF,x                         ; 8483
        .byte   $3F                             ; 8486
        .byte   $FF                             ; 8487
        rti                                     ; 8488

; ----------------------------------------------------------------------------
        eor     ($FF,x)                         ; 8489
        .byte   $42                             ; 848B
        .byte   $43                             ; 848C
        .byte   $FF                             ; 848D
        .byte   $44                             ; 848E
        eor     $FF                             ; 848F
        lsr     $FF                             ; 8491
        .byte   $47                             ; 8493
        .byte   $FF                             ; 8494
        pha                                     ; 8495
        .byte   $FF                             ; 8496
        eor     #$FF                            ; 8497
        lsr     a                               ; 8499
        .byte   $FF                             ; 849A
        .byte   $4B                             ; 849B
        .byte   $FF                             ; 849C
        jmp     L4DFF                           ; 849D

; ----------------------------------------------------------------------------
        .byte   $FF                             ; 84A0
        .byte   $4E                             ; 84A1
        .byte   $FF                             ; 84A2
L84A3:  brk                                     ; 84A3
        ora     ($FE,x)                         ; 84A4
        brk                                     ; 84A6
        ora     ($02,x)                         ; 84A7
        .byte   $FF                             ; 84A9
        .byte   $03                             ; 84AA
        .byte   $FF                             ; 84AB
        .byte   $04                             ; 84AC
        .byte   $FF                             ; 84AD
        ora     $06                             ; 84AE
        .byte   $07                             ; 84B0
        php                                     ; 84B1
        .byte   $FF                             ; 84B2
        ora     #$0A                            ; 84B3
        inc     $0C0B,x                         ; 84B5
        inc     $FF0E,x                         ; 84B8
        .byte   $0F                             ; 84BB
L84BC:  bpl     L84BC                           ; 84BC
        ora     ($12),y                         ; 84BE
        .byte   $13                             ; 84C0
        .byte   $80                             ; 84C1
        .byte   $14                             ; 84C2
        .byte   $FF                             ; 84C3
        brk                                     ; 84C4
        .byte   $FF                             ; 84C5
        asl     $4F                             ; 84C6
        bvc     L851B                           ; 84C8
        .byte   $FF                             ; 84CA
        .byte   $52                             ; 84CB
        .byte   $FF                             ; 84CC
        .byte   $53                             ; 84CD
        .byte   $FF                             ; 84CE
        .byte   $54                             ; 84CF
        .byte   $FF                             ; 84D0
        asl     $FF,x                           ; 84D1
        brk                                     ; 84D3
        ora     ($FE,x)                         ; 84D4
        .byte   $02                             ; 84D6
        .byte   $FF                             ; 84D7
        .byte   $03                             ; 84D8
        .byte   $FF                             ; 84D9
        .byte   $04                             ; 84DA
        .byte   $FF                             ; 84DB
        ora     $FF                             ; 84DC
        asl     $FF                             ; 84DE
        .byte   $07                             ; 84E0
        .byte   $FF                             ; 84E1
        php                                     ; 84E2
        .byte   $FF                             ; 84E3
        brk                                     ; 84E4
        .byte   $FF                             ; 84E5
        ora     ($02,x)                         ; 84E6
        .byte   $FF                             ; 84E8
        .byte   $03                             ; 84E9
        .byte   $04                             ; 84EA
        inc     $0504,x                         ; 84EB
        inc     $0706,x                         ; 84EE
        php                                     ; 84F1
        ora     #$FC                            ; 84F2
        asl     a                               ; 84F4
        .byte   $0B                             ; 84F5
        inc     $FF0C,x                         ; 84F6
        ora     $0EFF                           ; 84F9
        .byte   $FF                             ; 84FC
        .byte   $0F                             ; 84FD
        .byte   $FF                             ; 84FE
        .byte   $10                             ; 84FF
L8500:  .byte   $FF                             ; 8500
        brk                                     ; 8501
        ora     ($02,x)                         ; 8502
        .byte   $FF                             ; 8504
        .byte   $FF                             ; 8505
        brk                                     ; 8506
        ora     ($02,x)                         ; 8507
        .byte   $03                             ; 8509
        .byte   $04                             ; 850A
        .byte   $80                             ; 850B
        ora     $06                             ; 850C
        inc     $0807,x                         ; 850E
        inc     $0A09,x                         ; 8511
        inc     $0C0B,x                         ; 8514
        inc     $0E0D,x                         ; 8517
        .byte   $FE                             ; 851A
L851B:  .byte   $02                             ; 851B
        .byte   $03                             ; 851C
        inc     $0908,x                         ; 851D
        inc     $0B0A,x                         ; 8520
        inc     $0D0C,x                         ; 8523
        inc     $0F0E,x                         ; 8526
        inc     $1110,x                         ; 8529
        inc     $FF12,x                         ; 852C
        .byte   $13                             ; 852F
        .byte   $FF                             ; 8530
        .byte   $14                             ; 8531
        .byte   $FF                             ; 8532
        ora     $16,x                           ; 8533
        inc     $1817,x                         ; 8535
        inc     $1A19,x                         ; 8538
        inc     $1C1B,x                         ; 853B
        inc     $FF1D,x                         ; 853E
        asl     $201F,x                         ; 8541
        and     ($22,x)                         ; 8544
        .byte   $23                             ; 8546
        .byte   $FF                             ; 8547
        .byte   $0B                             ; 8548
        .byte   $FF                             ; 8549
        asl     $FF,x                           ; 854A
        brk                                     ; 854C
        ora     ($FE,x)                         ; 854D
        .byte   $02                             ; 854F
        .byte   $03                             ; 8550
        inc     $0504,x                         ; 8551
        inc     $0706,x                         ; 8554
        inc     $0908,x                         ; 8557
        inc     $0B0A,x                         ; 855A
        .byte   $0C                             ; 855D
        ora     L800E                           ; 855E
        php                                     ; 8561
        ora     #$0A                            ; 8562
        .byte   $0B                             ; 8564
        .byte   $80                             ; 8565
        brk                                     ; 8566
        ora     ($02,x)                         ; 8567
        .byte   $FF                             ; 8569
        .byte   $02                             ; 856A
        ora     ($00,x)                         ; 856B
        .byte   $80                             ; 856D
        .byte   $03                             ; 856E
        .byte   $04                             ; 856F
        .byte   $FF                             ; 8570
        ora     $06                             ; 8571
        ora     $FF                             ; 8573
        .byte   $03                             ; 8575
        .byte   $FF                             ; 8576
        .byte   $02                             ; 8577
        .byte   $03                             ; 8578
        .byte   $02                             ; 8579
        .byte   $03                             ; 857A
        .byte   $02                             ; 857B
        ora     ($02,x)                         ; 857C
        ora     ($00,x)                         ; 857E
        ora     ($FE,x)                         ; 8580
        brk                                     ; 8582
        .byte   $FF                             ; 8583
        .byte   $02                             ; 8584
        ora     ($00,x)                         ; 8585
        .byte   $FF                             ; 8587
        .byte   $04                             ; 8588
        .byte   $03                             ; 8589
        inc     $0403,x                         ; 858A
        inc     $0807,x                         ; 858D
        ora     #$FD                            ; 8590
        ora     #$08                            ; 8592
        .byte   $07                             ; 8594
        sbc     $0100,x                         ; 8595
        .byte   $02                             ; 8598
        sbc     $0403,x                         ; 8599
        ora     $FD                             ; 859C
        ora     ($00,x)                         ; 859E
        .byte   $FF                             ; 85A0
        brk                                     ; 85A1
        ora     ($FF,x)                         ; 85A2
        brk                                     ; 85A4
        ora     ($02,x)                         ; 85A5
        .byte   $03                             ; 85A7
        .byte   $04                             ; 85A8
        .byte   $80                             ; 85A9
        ora     $06                             ; 85AA
        inc     $0807,x                         ; 85AC
        inc     $0A09,x                         ; 85AF
        inc     $0C0B,x                         ; 85B2
        inc     $0807,x                         ; 85B5
        .byte   $FF                             ; 85B8
        brk                                     ; 85B9
        asl     $FE                             ; 85BA
        .byte   $02                             ; 85BC
        .byte   $07                             ; 85BD
        inc     $0908,x                         ; 85BE
        asl     a                               ; 85C1
        .byte   $0B                             ; 85C2
        .byte   $FC                             ; 85C3
        brk                                     ; 85C4
        .byte   $02                             ; 85C5
        inc     $0302,x                         ; 85C6
        .byte   $FF                             ; 85C9
        .byte   $03                             ; 85CA
        .byte   $04                             ; 85CB
        ora     $06                             ; 85CC
        .byte   $03                             ; 85CE
        .byte   $FF                             ; 85CF
        .byte   $03                             ; 85D0
        asl     $05                             ; 85D1
        .byte   $04                             ; 85D3
        .byte   $03                             ; 85D4
        .byte   $FF                             ; 85D5
        ora     ($02,x)                         ; 85D6
        .byte   $03                             ; 85D8
        .byte   $02                             ; 85D9
        .byte   $FC                             ; 85DA
        .byte   $04                             ; 85DB
        ora     $06                             ; 85DC
        ora     $FC                             ; 85DE
        .byte   $0C                             ; 85E0
        ora     $0EFF                           ; 85E1
        .byte   $0F                             ; 85E4
        .byte   $FF                             ; 85E5
        .byte   $10                             ; 85E6
L85E7:  .byte   $FF                             ; 85E7
        ora     ($FF),y                         ; 85E8
        asl     $07                             ; 85EA
        inc     $0100,x                         ; 85EC
        .byte   $02                             ; 85EF
        asl     $80                             ; 85F0
        .byte   $03                             ; 85F2
        .byte   $04                             ; 85F3
        ora     $06                             ; 85F4
        .byte   $80                             ; 85F6
        brk                                     ; 85F7
        ora     ($02,x)                         ; 85F8
        .byte   $03                             ; 85FA
        .byte   $80                             ; 85FB
        .byte   $04                             ; 85FC
        .byte   $02                             ; 85FD
        ora     $80                             ; 85FE
        php                                     ; 8600
        .byte   $FF                             ; 8601
        ora     #$FF                            ; 8602
        asl     $FF                             ; 8604
        brk                                     ; 8606
        .byte   $FF                             ; 8607
        ora     ($02,x)                         ; 8608
        .byte   $03                             ; 860A
        .byte   $04                             ; 860B
        ora     $06                             ; 860C
        .byte   $FF                             ; 860E
        .byte   $07                             ; 860F
        .byte   $FF                             ; 8610
        php                                     ; 8611
        .byte   $FF                             ; 8612
        ora     ($02,x)                         ; 8613
        .byte   $03                             ; 8615
        .byte   $04                             ; 8616
        ora     $09                             ; 8617
        ora     #$FF                            ; 8619
        ora     ($02,x)                         ; 861B
        .byte   $03                             ; 861D
        .byte   $04                             ; 861E
        ora     $0A                             ; 861F
        .byte   $FF                             ; 8621
        ora     ($02,x)                         ; 8622
        .byte   $03                             ; 8624
        .byte   $04                             ; 8625
        ora     $0B                             ; 8626
        .byte   $FF                             ; 8628
        ora     ($02,x)                         ; 8629
        .byte   $03                             ; 862B
        .byte   $04                             ; 862C
        ora     $0C                             ; 862D
        .byte   $FF                             ; 862F
        brk                                     ; 8630
        .byte   $04                             ; 8631
        php                                     ; 8632
        .byte   $0B                             ; 8633
        rol     $3E3E,x                         ; 8634
        rol     $0400,x                         ; 8637
        php                                     ; 863A
        .byte   $0B                             ; 863B
        asl     $1210                           ; 863C
        .byte   $14                             ; 863F
        .byte   $3A                             ; 8640
        .byte   $3A                             ; 8641
        .byte   $3A                             ; 8642
        .byte   $3A                             ; 8643
        asl     $19,x                           ; 8644
        .byte   $1C                             ; 8646
        .byte   $1F                             ; 8647
        .byte   $22                             ; 8648
        and     $28                             ; 8649
        .byte   $2B                             ; 864B
        rol     $3431                           ; 864C
        .byte   $37                             ; 864F
        brk                                     ; 8650
        .byte   $04                             ; 8651
        php                                     ; 8652
        .byte   $0B                             ; 8653
        sta     L9D9D,x                         ; 8654
        sta     $3E3E,x                         ; 8657
        rol     $3E3E,x                         ; 865A
        rol     $3E3E,x                         ; 865D
        .byte   $FF                             ; 8660
        .byte   $FF                             ; 8661
        .byte   $FF                             ; 8662
        .byte   $FF                             ; 8663
        .byte   $FF                             ; 8664
        .byte   $FF                             ; 8665
        .byte   $FF                             ; 8666
        .byte   $FF                             ; 8667
        .byte   $3A                             ; 8668
        .byte   $3A                             ; 8669
        .byte   $3A                             ; 866A
        .byte   $3A                             ; 866B
        .byte   $44                             ; 866C
        .byte   $47                             ; 866D
        lsr     a                               ; 866E
        eor     $5350                           ; 866F
        lsr     $59,x                           ; 8672
        .byte   $5C                             ; 8674
        .byte   $5F                             ; 8675
        .byte   $62                             ; 8676
        adc     $FF                             ; 8677
        .byte   $FF                             ; 8679
        .byte   $FF                             ; 867A
        .byte   $FF                             ; 867B
        sta     L9D9D,x                         ; 867C
        sta     $3E3E,x                         ; 867F
        rol     $3E3E,x                         ; 8682
        rol     $3E3E,x                         ; 8685
        .byte   $7A                             ; 8688
        .byte   $7A                             ; 8689
L868A:  .byte   $7A                             ; 868A
        .byte   $7A                             ; 868B
L868C:  .byte   $7A                             ; 868C
        .byte   $7A                             ; 868D
        .byte   $7A                             ; 868E
        .byte   $7A                             ; 868F
        .byte   $3A                             ; 8690
        .byte   $3A                             ; 8691
        .byte   $3A                             ; 8692
        .byte   $3A                             ; 8693
        .byte   $FF                             ; 8694
        .byte   $FF                             ; 8695
        .byte   $FF                             ; 8696
        .byte   $FF                             ; 8697
        .byte   $FF                             ; 8698
        .byte   $FF                             ; 8699
        .byte   $FF                             ; 869A
        .byte   $FF                             ; 869B
        .byte   $FF                             ; 869C
        .byte   $FF                             ; 869D
        .byte   $FF                             ; 869E
        .byte   $FF                             ; 869F
        .byte   $7A                             ; 86A0
        .byte   $7A                             ; 86A1
        .byte   $7A                             ; 86A2
        .byte   $7A                             ; 86A3
        sta     L9D9D,x                         ; 86A4
        sta     $7676,x                         ; 86A7
        ror     $76,x                           ; 86AA
        pla                                     ; 86AC
        pla                                     ; 86AD
L86AE:  pla                                     ; 86AE
        pla                                     ; 86AF
        pla                                     ; 86B0
        pla                                     ; 86B1
        pla                                     ; 86B2
        pla                                     ; 86B3
        ldx     #$A2                            ; 86B4
        ldx     #$A2                            ; 86B6
        ror     a                               ; 86B8
        ror     a                               ; 86B9
        ror     a                               ; 86BA
        ror     a                               ; 86BB
        ldy     $A4                             ; 86BC
        ldy     $A4                             ; 86BE
        jmp     (L6C6C)                         ; 86C0

; ----------------------------------------------------------------------------
        jmp     (L706E)                         ; 86C3

; ----------------------------------------------------------------------------
        .byte   $72                             ; 86C6
        .byte   $74                             ; 86C7
        sei                                     ; 86C8
        sei                                     ; 86C9
        sei                                     ; 86CA
        sei                                     ; 86CB
        .byte   $FF                             ; 86CC
        .byte   $FF                             ; 86CD
        .byte   $FF                             ; 86CE
        .byte   $FF                             ; 86CF
        ldx     $A6                             ; 86D0
        ldx     $A6                             ; 86D2
        .byte   $FF                             ; 86D4
        .byte   $FF                             ; 86D5
        .byte   $FF                             ; 86D6
        .byte   $FF                             ; 86D7
        adc     $7D7D,x                         ; 86D8
        adc     L8181,x                         ; 86DB
        sta     ($81,x)                         ; 86DE
        .byte   $83                             ; 86E0
        .byte   $83                             ; 86E1
        .byte   $83                             ; 86E2
        .byte   $83                             ; 86E3
        sta     $85                             ; 86E4
        sta     $85                             ; 86E6
        sta     L8A8D                           ; 86E8
        sta     $FFFF                           ; 86EB
        .byte   $FF                             ; 86EE
        .byte   $FF                             ; 86EF
        .byte   $14                             ; 86F0
        .byte   $14                             ; 86F1
        .byte   $14                             ; 86F2
        .byte   $14                             ; 86F3
        .byte   $83                             ; 86F4
        .byte   $83                             ; 86F5
        .byte   $83                             ; 86F6
        .byte   $83                             ; 86F7
        bcc     L868A                           ; 86F8
        bcc     L868C                           ; 86FA
        .byte   $92                             ; 86FC
        .byte   $92                             ; 86FD
        .byte   $92                             ; 86FE
        .byte   $92                             ; 86FF
        sta     $95,x                           ; 8700
        sta     $95,x                           ; 8702
        sta     L9999,y                         ; 8704
        sta     $2020,y                         ; 8707
        jsr     L2220                           ; 870A
        .byte   $22                             ; 870D
        .byte   $22                             ; 870E
        .byte   $22                             ; 870F
        .byte   $02                             ; 8710
        .byte   $02                             ; 8711
        .byte   $02                             ; 8712
        .byte   $02                             ; 8713
        ora     #$0B                            ; 8714
        ora     #$09                            ; 8716
        .byte   $FF                             ; 8718
        .byte   $FF                             ; 8719
        .byte   $FF                             ; 871A
        .byte   $FF                             ; 871B
        ora     $0D0D                           ; 871C
        ora     $FFFF                           ; 871F
        .byte   $FF                             ; 8722
        .byte   $FF                             ; 8723
        .byte   $23                             ; 8724
        .byte   $23                             ; 8725
        .byte   $23                             ; 8726
        .byte   $23                             ; 8727
        ora     $15,x                           ; 8728
        ora     $15,x                           ; 872A
        .byte   $1C                             ; 872C
        .byte   $1C                             ; 872D
        .byte   $1C                             ; 872E
        .byte   $1C                             ; 872F
        .byte   $FF                             ; 8730
        .byte   $FF                             ; 8731
        .byte   $FF                             ; 8732
        .byte   $FF                             ; 8733
        .byte   $FF                             ; 8734
        .byte   $FF                             ; 8735
        .byte   $FF                             ; 8736
        .byte   $FF                             ; 8737
        .byte   $FF                             ; 8738
        .byte   $FF                             ; 8739
        .byte   $FF                             ; 873A
        .byte   $FF                             ; 873B
        .byte   $FF                             ; 873C
        .byte   $FF                             ; 873D
        .byte   $FF                             ; 873E
        .byte   $FF                             ; 873F
        brk                                     ; 8740
        brk                                     ; 8741
        brk                                     ; 8742
        brk                                     ; 8743
        brk                                     ; 8744
        pha                                     ; 8745
        ora     $0B19,y                         ; 8746
        .byte   $0B                             ; 8749
        .byte   $0B                             ; 874A
        .byte   $0B                             ; 874B
        ora     $0D0D                           ; 874C
        ora     $4E4B                           ; 874F
        .byte   $4B                             ; 8752
        lsr     $5451                           ; 8753
        .byte   $57                             ; 8756
        .byte   $57                             ; 8757
        .byte   $5A                             ; 8758
        .byte   $5A                             ; 8759
        .byte   $5A                             ; 875A
        .byte   $5A                             ; 875B
        .byte   $5C                             ; 875C
        .byte   $5C                             ; 875D
        .byte   $5C                             ; 875E
        .byte   $5C                             ; 875F
        .byte   $FF                             ; 8760
        .byte   $FF                             ; 8761
        .byte   $FF                             ; 8762
        .byte   $FF                             ; 8763
        rts                                     ; 8764

; ----------------------------------------------------------------------------
        rts                                     ; 8765

; ----------------------------------------------------------------------------
        rts                                     ; 8766

; ----------------------------------------------------------------------------
        rts                                     ; 8767

; ----------------------------------------------------------------------------
        .byte   $63                             ; 8768
        ror     $69                             ; 8769
        adc     #$00                            ; 876B
        pha                                     ; 876D
        ora     $0B19,y                         ; 876E
        .byte   $0B                             ; 8771
        .byte   $0B                             ; 8772
        .byte   $0B                             ; 8773
        eor     ($54),y                         ; 8774
        .byte   $57                             ; 8776
        .byte   $57                             ; 8777
        .byte   $5C                             ; 8778
        .byte   $5C                             ; 8779
        .byte   $5C                             ; 877A
        .byte   $5C                             ; 877B
        .byte   $FF                             ; 877C
        .byte   $FF                             ; 877D
        .byte   $FF                             ; 877E
        .byte   $FF                             ; 877F
        ror     $6E6E                           ; 8780
        ror     $FFFF                           ; 8783
        .byte   $FF                             ; 8786
        .byte   $FF                             ; 8787
        .byte   $FF                             ; 8788
        .byte   $FF                             ; 8789
        .byte   $FF                             ; 878A
        .byte   $FF                             ; 878B
        .byte   $FF                             ; 878C
        .byte   $FF                             ; 878D
        .byte   $FF                             ; 878E
        .byte   $FF                             ; 878F
        .byte   $FF                             ; 8790
        .byte   $FF                             ; 8791
        .byte   $FF                             ; 8792
        .byte   $FF                             ; 8793
        brk                                     ; 8794
        brk                                     ; 8795
        brk                                     ; 8796
        brk                                     ; 8797
        .byte   $03                             ; 8798
        .byte   $03                             ; 8799
        .byte   $03                             ; 879A
        .byte   $03                             ; 879B
        ora     $05                             ; 879C
        ora     $05                             ; 879E
        .byte   $07                             ; 87A0
        .byte   $07                             ; 87A1
        .byte   $07                             ; 87A2
        .byte   $07                             ; 87A3
        ora     #$09                            ; 87A4
        ora     #$09                            ; 87A6
        .byte   $0B                             ; 87A8
        .byte   $0B                             ; 87A9
        .byte   $0B                             ; 87AA
        .byte   $0B                             ; 87AB
        brk                                     ; 87AC
        brk                                     ; 87AD
        brk                                     ; 87AE
        brk                                     ; 87AF
        .byte   $FF                             ; 87B0
        .byte   $FF                             ; 87B1
        .byte   $FF                             ; 87B2
        .byte   $FF                             ; 87B3
        ora     $0D0D                           ; 87B4
        ora     $FFFF                           ; 87B7
        .byte   $FF                             ; 87BA
        .byte   $FF                             ; 87BB
        .byte   $FF                             ; 87BC
        .byte   $FF                             ; 87BD
        .byte   $FF                             ; 87BE
        .byte   $FF                             ; 87BF
        adc     $75,x                           ; 87C0
        adc     $75,x                           ; 87C2
        .byte   $0F                             ; 87C4
        .byte   $0F                             ; 87C5
        .byte   $0F                             ; 87C6
        .byte   $0F                             ; 87C7
        .byte   $3F                             ; 87C8
        .byte   $3F                             ; 87C9
        .byte   $3F                             ; 87CA
        .byte   $3F                             ; 87CB
        .byte   $FF                             ; 87CC
        .byte   $FF                             ; 87CD
        .byte   $FF                             ; 87CE
        .byte   $FF                             ; 87CF
        ora     $0D0D                           ; 87D0
        ora     $1111                           ; 87D3
        ora     ($11),y                         ; 87D6
        ora     ($11),y                         ; 87D8
        ora     ($11),y                         ; 87DA
        .byte   $14                             ; 87DC
        .byte   $14                             ; 87DD
        .byte   $14                             ; 87DE
        .byte   $14                             ; 87DF
        ora     ($11),y                         ; 87E0
        ora     ($11),y                         ; 87E2
        asl     $16,x                           ; 87E4
        asl     $16,x                           ; 87E6
        .byte   $03                             ; 87E8
        .byte   $03                             ; 87E9
        .byte   $03                             ; 87EA
        .byte   $03                             ; 87EB
        .byte   $1C                             ; 87EC
        .byte   $1C                             ; 87ED
        .byte   $1C                             ; 87EE
        .byte   $1C                             ; 87EF
        ora     ($11),y                         ; 87F0
        ora     ($11),y                         ; 87F2
        and     ($21,x)                         ; 87F4
        and     ($21,x)                         ; 87F6
        ora     #$09                            ; 87F8
        ora     #$09                            ; 87FA
        bit     $24                             ; 87FC
        bit     $24                             ; 87FE
        rol     $26                             ; 8800
        rol     $26                             ; 8802
        plp                                     ; 8804
        plp                                     ; 8805
        plp                                     ; 8806
        plp                                     ; 8807
        rol     a                               ; 8808
        rol     a                               ; 8809
        rol     a                               ; 880A
        rol     a                               ; 880B
        bit     $2C2C                           ; 880C
        bit     $1111                           ; 880F
        ora     ($11),y                         ; 8812
        rol     $2E2E                           ; 8814
        rol     $0505                           ; 8817
        ora     $05                             ; 881A
        rol     $2E2E                           ; 881C
        rol     $0505                           ; 881F
        ora     $05                             ; 8822
        .byte   $33                             ; 8824
        .byte   $33                             ; 8825
        .byte   $33                             ; 8826
        .byte   $33                             ; 8827
        and     $3939,y                         ; 8828
        and     $3939,y                         ; 882B
        and     $3C39,y                         ; 882E
        .byte   $3C                             ; 8831
        .byte   $3C                             ; 8832
        .byte   $3C                             ; 8833
        .byte   $3F                             ; 8834
        .byte   $3F                             ; 8835
        .byte   $3F                             ; 8836
        .byte   $3F                             ; 8837
        .byte   $42                             ; 8838
        .byte   $42                             ; 8839
        .byte   $42                             ; 883A
        .byte   $42                             ; 883B
        eor     $45                             ; 883C
        eor     $45                             ; 883E
        .byte   $33                             ; 8840
        .byte   $33                             ; 8841
        .byte   $33                             ; 8842
        .byte   $33                             ; 8843
        brk                                     ; 8844
        brk                                     ; 8845
        brk                                     ; 8846
        brk                                     ; 8847
        .byte   $03                             ; 8848
        asl     $09                             ; 8849
        .byte   $0C                             ; 884B
        .byte   $03                             ; 884C
        asl     $09                             ; 884D
        .byte   $0C                             ; 884F
        .byte   $03                             ; 8850
        asl     $09                             ; 8851
        .byte   $0C                             ; 8853
        .byte   $03                             ; 8854
        asl     $09                             ; 8855
        .byte   $0C                             ; 8857
        .byte   $03                             ; 8858
        asl     $09                             ; 8859
        .byte   $0C                             ; 885B
        brk                                     ; 885C
        brk                                     ; 885D
        brk                                     ; 885E
        brk                                     ; 885F
        .byte   $0F                             ; 8860
        .byte   $0F                             ; 8861
        .byte   $0F                             ; 8862
        .byte   $0F                             ; 8863
        .byte   $03                             ; 8864
        asl     $09                             ; 8865
        .byte   $0C                             ; 8867
        .byte   $03                             ; 8868
        asl     $09                             ; 8869
        .byte   $0C                             ; 886B
        .byte   $03                             ; 886C
        asl     $09                             ; 886D
        .byte   $0C                             ; 886F
        brk                                     ; 8870
        .byte   $03                             ; 8871
        asl     $09                             ; 8872
        brk                                     ; 8874
        .byte   $03                             ; 8875
        asl     $09                             ; 8876
        brk                                     ; 8878
        .byte   $03                             ; 8879
        asl     $09                             ; 887A
        brk                                     ; 887C
        .byte   $03                             ; 887D
        asl     $09                             ; 887E
        sty     $97,x                           ; 8880
        txs                                     ; 8882
        .byte   $9C                             ; 8883
        .byte   $FF                             ; 8884
        .byte   $FF                             ; 8885
        .byte   $FF                             ; 8886
        .byte   $FF                             ; 8887
        brk                                     ; 8888
        brk                                     ; 8889
        brk                                     ; 888A
        brk                                     ; 888B
        brk                                     ; 888C
        brk                                     ; 888D
        brk                                     ; 888E
        brk                                     ; 888F
        brk                                     ; 8890
        brk                                     ; 8891
        brk                                     ; 8892
        brk                                     ; 8893
        brk                                     ; 8894
        brk                                     ; 8895
        brk                                     ; 8896
        brk                                     ; 8897
        brk                                     ; 8898
        brk                                     ; 8899
        brk                                     ; 889A
        brk                                     ; 889B
        brk                                     ; 889C
        brk                                     ; 889D
        brk                                     ; 889E
        brk                                     ; 889F
        .byte   $1A                             ; 88A0
        .byte   $1A                             ; 88A1
        .byte   $1A                             ; 88A2
        .byte   $1A                             ; 88A3
        .byte   $23                             ; 88A4
        .byte   $23                             ; 88A5
        .byte   $23                             ; 88A6
        .byte   $23                             ; 88A7
        .byte   $23                             ; 88A8
        .byte   $23                             ; 88A9
        .byte   $23                             ; 88AA
        .byte   $23                             ; 88AB
        .byte   $22                             ; 88AC
        .byte   $22                             ; 88AD
        .byte   $22                             ; 88AE
        .byte   $22                             ; 88AF
        and     $25                             ; 88B0
        and     $25                             ; 88B2
        .byte   $1A                             ; 88B4
        .byte   $1A                             ; 88B5
        .byte   $1A                             ; 88B6
        .byte   $1A                             ; 88B7
        asl     $1E1E,x                         ; 88B8
        asl     $3636,x                         ; 88BB
        rol     $36,x                           ; 88BE
        rol     $36,x                           ; 88C0
        rol     $36,x                           ; 88C2
        rol     $36,x                           ; 88C4
        rol     $36,x                           ; 88C6
        rol     $36,x                           ; 88C8
        rol     $36,x                           ; 88CA
        rol     $36,x                           ; 88CC
        rol     $36,x                           ; 88CE
        lsr     $56,x                           ; 88D0
        lsr     $56,x                           ; 88D2
        .byte   $FF                             ; 88D4
        .byte   $FF                             ; 88D5
        .byte   $FF                             ; 88D6
        .byte   $FF                             ; 88D7
        .byte   $FF                             ; 88D8
        .byte   $FF                             ; 88D9
        .byte   $FF                             ; 88DA
        .byte   $FF                             ; 88DB
        .byte   $FF                             ; 88DC
        .byte   $FF                             ; 88DD
        .byte   $FF                             ; 88DE
        .byte   $FF                             ; 88DF
        .byte   $FF                             ; 88E0
        .byte   $FF                             ; 88E1
        .byte   $FF                             ; 88E2
        .byte   $FF                             ; 88E3
        .byte   $FF                             ; 88E4
        .byte   $FF                             ; 88E5
        .byte   $FF                             ; 88E6
        .byte   $FF                             ; 88E7
        .byte   $FF                             ; 88E8
        .byte   $FF                             ; 88E9
        .byte   $FF                             ; 88EA
        .byte   $FF                             ; 88EB
        .byte   $FF                             ; 88EC
        .byte   $FF                             ; 88ED
        .byte   $FF                             ; 88EE
        .byte   $FF                             ; 88EF
        .byte   $FF                             ; 88F0
        .byte   $FF                             ; 88F1
        .byte   $FF                             ; 88F2
        .byte   $FF                             ; 88F3
        .byte   $FF                             ; 88F4
        .byte   $FF                             ; 88F5
        .byte   $FF                             ; 88F6
        .byte   $FF                             ; 88F7
        .byte   $FF                             ; 88F8
        .byte   $FF                             ; 88F9
        .byte   $FF                             ; 88FA
        .byte   $FF                             ; 88FB
        .byte   $33                             ; 88FC
        .byte   $33                             ; 88FD
        .byte   $33                             ; 88FE
        .byte   $33                             ; 88FF
        .byte   $33                             ; 8900
        .byte   $33                             ; 8901
        .byte   $33                             ; 8902
        .byte   $33                             ; 8903
        .byte   $2B                             ; 8904
        .byte   $2B                             ; 8905
        .byte   $2B                             ; 8906
        .byte   $2B                             ; 8907
        .byte   $2B                             ; 8908
        .byte   $2B                             ; 8909
        .byte   $2B                             ; 890A
        .byte   $2B                             ; 890B
        rol     $36,x                           ; 890C
        rol     $36,x                           ; 890E
        .byte   $3C                             ; 8910
        .byte   $3F                             ; 8911
        .byte   $42                             ; 8912
        lsr     $3C                             ; 8913
        .byte   $3F                             ; 8915
        .byte   $42                             ; 8916
        lsr     $1A                             ; 8917
        .byte   $1A                             ; 8919
        .byte   $1A                             ; 891A
        .byte   $1A                             ; 891B
        .byte   $3C                             ; 891C
        .byte   $3F                             ; 891D
        .byte   $42                             ; 891E
        lsr     $38                             ; 891F
        sec                                     ; 8921
        sec                                     ; 8922
        sec                                     ; 8923
        .byte   $03                             ; 8924
        asl     $09                             ; 8925
        .byte   $0C                             ; 8927
        .byte   $03                             ; 8928
        asl     $09                             ; 8929
        .byte   $0C                             ; 892B
        .byte   $03                             ; 892C
        asl     $09                             ; 892D
        .byte   $0C                             ; 892F
        .byte   $03                             ; 8930
        asl     $09                             ; 8931
        .byte   $0C                             ; 8933
        .byte   $03                             ; 8934
        asl     $09                             ; 8935
        .byte   $0C                             ; 8937
        .byte   $03                             ; 8938
        asl     $09                             ; 8939
        .byte   $0C                             ; 893B
        .byte   $FF                             ; 893C
        .byte   $FF                             ; 893D
        .byte   $FF                             ; 893E
        .byte   $FF                             ; 893F
        ldy     $B6,x                           ; 8940
        ldy     $B6,x                           ; 8942
        ldy     $B6,x                           ; 8944
        ldy     $B6,x                           ; 8946
        ldy     $B6,x                           ; 8948
        ldy     $B6,x                           ; 894A
        .byte   $9E                             ; 894C
        .byte   $9E                             ; 894D
        .byte   $9E                             ; 894E
        .byte   $9E                             ; 894F
        lda     ($A6,x)                         ; 8950
        lda     ($A6,x)                         ; 8952
        brk                                     ; 8954
        .byte   $03                             ; 8955
        brk                                     ; 8956
        .byte   $03                             ; 8957
        brk                                     ; 8958
        .byte   $03                             ; 8959
        brk                                     ; 895A
        .byte   $03                             ; 895B
        brk                                     ; 895C
        .byte   $03                             ; 895D
        brk                                     ; 895E
        .byte   $03                             ; 895F
        brk                                     ; 8960
        .byte   $03                             ; 8961
        brk                                     ; 8962
        .byte   $03                             ; 8963
        .byte   $FF                             ; 8964
        .byte   $FF                             ; 8965
        .byte   $FF                             ; 8966
        .byte   $FF                             ; 8967
        rol     $36,x                           ; 8968
        rol     $36,x                           ; 896A
        rol     $36,x                           ; 896C
        rol     $36,x                           ; 896E
        rol     $36,x                           ; 8970
        rol     $36,x                           ; 8972
        .byte   $52                             ; 8974
        .byte   $52                             ; 8975
        .byte   $52                             ; 8976
        .byte   $52                             ; 8977
        .byte   $FF                             ; 8978
        .byte   $FF                             ; 8979
        .byte   $FF                             ; 897A
        .byte   $FF                             ; 897B
        rol     $36,x                           ; 897C
        rol     $36,x                           ; 897E
        rol     $36,x                           ; 8980
        rol     $36,x                           ; 8982
        eor     $55,x                           ; 8984
        eor     $55,x                           ; 8986
        .byte   $52                             ; 8988
        .byte   $52                             ; 8989
        .byte   $52                             ; 898A
        .byte   $52                             ; 898B
        cli                                     ; 898C
        cli                                     ; 898D
        cli                                     ; 898E
        cli                                     ; 898F
        clv                                     ; 8990
        .byte   $27                             ; 8991
        clv                                     ; 8992
        .byte   $27                             ; 8993
        clv                                     ; 8994
        .byte   $27                             ; 8995
        clv                                     ; 8996
        .byte   $27                             ; 8997
        clv                                     ; 8998
        .byte   $27                             ; 8999
        clv                                     ; 899A
        .byte   $27                             ; 899B
        .byte   $FF                             ; 899C
        .byte   $FF                             ; 899D
        .byte   $FF                             ; 899E
        .byte   $FF                             ; 899F
        rol     $56,x                           ; 89A0
        rol     $56,x                           ; 89A2
        .byte   $03                             ; 89A4
        asl     $03                             ; 89A5
        asl     $03                             ; 89A7
        asl     $03                             ; 89A9
        asl     $03                             ; 89AB
        asl     $03                             ; 89AD
        asl     $FF                             ; 89AF
        .byte   $FF                             ; 89B1
        .byte   $FF                             ; 89B2
        .byte   $FF                             ; 89B3
        brk                                     ; 89B4
        .byte   $03                             ; 89B5
        brk                                     ; 89B6
        .byte   $03                             ; 89B7
        brk                                     ; 89B8
        .byte   $03                             ; 89B9
        brk                                     ; 89BA
        .byte   $03                             ; 89BB
        brk                                     ; 89BC
        .byte   $03                             ; 89BD
        brk                                     ; 89BE
        .byte   $03                             ; 89BF
        .byte   $23                             ; 89C0
        .byte   $27                             ; 89C1
        .byte   $23                             ; 89C2
        .byte   $27                             ; 89C3
        .byte   $FF                             ; 89C4
        .byte   $FF                             ; 89C5
        .byte   $FF                             ; 89C6
        .byte   $FF                             ; 89C7
        .byte   $FF                             ; 89C8
        .byte   $FF                             ; 89C9
        .byte   $FF                             ; 89CA
        .byte   $FF                             ; 89CB
        .byte   $FF                             ; 89CC
        .byte   $FF                             ; 89CD
        .byte   $FF                             ; 89CE
        .byte   $FF                             ; 89CF
        ora     #$09                            ; 89D0
        ora     #$09                            ; 89D2
        .byte   $FF                             ; 89D4
        .byte   $FF                             ; 89D5
        .byte   $FF                             ; 89D6
        .byte   $FF                             ; 89D7
        brk                                     ; 89D8
        brk                                     ; 89D9
        brk                                     ; 89DA
        brk                                     ; 89DB
        brk                                     ; 89DC
        brk                                     ; 89DD
        brk                                     ; 89DE
        brk                                     ; 89DF
        brk                                     ; 89E0
        brk                                     ; 89E1
        brk                                     ; 89E2
        brk                                     ; 89E3
        brk                                     ; 89E4
        brk                                     ; 89E5
        brk                                     ; 89E6
        brk                                     ; 89E7
        .byte   $FF                             ; 89E8
        .byte   $FF                             ; 89E9
        .byte   $FF                             ; 89EA
        .byte   $FF                             ; 89EB
        .byte   $FF                             ; 89EC
        .byte   $FF                             ; 89ED
        .byte   $FF                             ; 89EE
        .byte   $FF                             ; 89EF
        .byte   $FF                             ; 89F0
        .byte   $FF                             ; 89F1
        .byte   $FF                             ; 89F2
        .byte   $FF                             ; 89F3
        .byte   $1C                             ; 89F4
        .byte   $1C                             ; 89F5
        .byte   $1C                             ; 89F6
        .byte   $1C                             ; 89F7
        cli                                     ; 89F8
        cli                                     ; 89F9
        cli                                     ; 89FA
        cli                                     ; 89FB
        lsr     $5E61,x                         ; 89FC
        adc     ($5E,x)                         ; 89FF
        adc     ($5E,x)                         ; 8A01
        adc     ($5E,x)                         ; 8A03
        adc     ($5E,x)                         ; 8A05
        adc     ($64,x)                         ; 8A07
        .byte   $67                             ; 8A09
        .byte   $64                             ; 8A0A
        .byte   $67                             ; 8A0B
        .byte   $FF                             ; 8A0C
        .byte   $FF                             ; 8A0D
        .byte   $FF                             ; 8A0E
        .byte   $FF                             ; 8A0F
        cli                                     ; 8A10
        cli                                     ; 8A11
        cli                                     ; 8A12
        cli                                     ; 8A13
        cli                                     ; 8A14
        cli                                     ; 8A15
        cli                                     ; 8A16
        cli                                     ; 8A17
        lsr     $5E5E,x                         ; 8A18
        lsr     $5E5E,x                         ; 8A1B
        lsr     $5E5E,x                         ; 8A1E
        lsr     $5E5E,x                         ; 8A21
        ror     a                               ; 8A24
        ror     a                               ; 8A25
        ror     a                               ; 8A26
        ror     a                               ; 8A27
        .byte   $FF                             ; 8A28
        .byte   $FF                             ; 8A29
        .byte   $FF                             ; 8A2A
        .byte   $FF                             ; 8A2B
        cli                                     ; 8A2C
        cli                                     ; 8A2D
        cli                                     ; 8A2E
        cli                                     ; 8A2F
        cli                                     ; 8A30
        cli                                     ; 8A31
        cli                                     ; 8A32
        cli                                     ; 8A33
        lsr     $5E5E,x                         ; 8A34
        lsr     $5E5E,x                         ; 8A37
        lsr     $5E5E,x                         ; 8A3A
        lsr     $5E5E,x                         ; 8A3D
        adc     ($61,x)                         ; 8A40
        adc     ($61,x)                         ; 8A42
        .byte   $FF                             ; 8A44
        .byte   $FF                             ; 8A45
        .byte   $FF                             ; 8A46
        .byte   $FF                             ; 8A47
        cli                                     ; 8A48
        cli                                     ; 8A49
        cli                                     ; 8A4A
        cli                                     ; 8A4B
        cli                                     ; 8A4C
        cli                                     ; 8A4D
        cli                                     ; 8A4E
        cli                                     ; 8A4F
        lsr     $5E5E,x                         ; 8A50
        lsr     $5E5E,x                         ; 8A53
        lsr     $5E5E,x                         ; 8A56
        lsr     $5E5E,x                         ; 8A59
        lsr     $5E5E,x                         ; 8A5C
        lsr     $FFFF,x                         ; 8A5F
        .byte   $FF                             ; 8A62
        .byte   $FF                             ; 8A63
        lsr     $5E5E,x                         ; 8A64
        lsr     $FFFF,x                         ; 8A67
        .byte   $FF                             ; 8A6A
        .byte   $FF                             ; 8A6B
        .byte   $FF                             ; 8A6C
        .byte   $FF                             ; 8A6D
        .byte   $FF                             ; 8A6E
        .byte   $FF                             ; 8A6F
        brk                                     ; 8A70
        .byte   $03                             ; 8A71
        brk                                     ; 8A72
        .byte   $03                             ; 8A73
        brk                                     ; 8A74
        .byte   $03                             ; 8A75
        brk                                     ; 8A76
        .byte   $03                             ; 8A77
        brk                                     ; 8A78
        .byte   $03                             ; 8A79
        brk                                     ; 8A7A
        .byte   $03                             ; 8A7B
        .byte   $23                             ; 8A7C
        .byte   $27                             ; 8A7D
        .byte   $23                             ; 8A7E
        .byte   $27                             ; 8A7F
        adc     $6D70                           ; 8A80
        bvs     L8AA8                           ; 8A83
        .byte   $27                             ; 8A85
        .byte   $23                             ; 8A86
        .byte   $27                             ; 8A87
        .byte   $23                             ; 8A88
        .byte   $27                             ; 8A89
        .byte   $23                             ; 8A8A
        .byte   $27                             ; 8A8B
        .byte   $73                             ; 8A8C
L8A8D:  .byte   $73                             ; 8A8D
        .byte   $73                             ; 8A8E
        .byte   $73                             ; 8A8F
        .byte   $FF                             ; 8A90
        .byte   $FF                             ; 8A91
        .byte   $FF                             ; 8A92
        .byte   $FF                             ; 8A93
        brk                                     ; 8A94
        brk                                     ; 8A95
        brk                                     ; 8A96
        brk                                     ; 8A97
        brk                                     ; 8A98
        brk                                     ; 8A99
        brk                                     ; 8A9A
        brk                                     ; 8A9B
        brk                                     ; 8A9C
        brk                                     ; 8A9D
        brk                                     ; 8A9E
        brk                                     ; 8A9F
        brk                                     ; 8AA0
        brk                                     ; 8AA1
        brk                                     ; 8AA2
        brk                                     ; 8AA3
        sei                                     ; 8AA4
        sei                                     ; 8AA5
        sei                                     ; 8AA6
        sei                                     ; 8AA7
L8AA8:  brk                                     ; 8AA8
        brk                                     ; 8AA9
        brk                                     ; 8AAA
        brk                                     ; 8AAB
        brk                                     ; 8AAC
        brk                                     ; 8AAD
        brk                                     ; 8AAE
        brk                                     ; 8AAF
        .byte   $7C                             ; 8AB0
        .byte   $7C                             ; 8AB1
        .byte   $7C                             ; 8AB2
        .byte   $7C                             ; 8AB3
        .byte   $FF                             ; 8AB4
        .byte   $FF                             ; 8AB5
        .byte   $FF                             ; 8AB6
        .byte   $FF                             ; 8AB7
        brk                                     ; 8AB8
        brk                                     ; 8AB9
        brk                                     ; 8ABA
        brk                                     ; 8ABB
        brk                                     ; 8ABC
        brk                                     ; 8ABD
        brk                                     ; 8ABE
        brk                                     ; 8ABF
        brk                                     ; 8AC0
        brk                                     ; 8AC1
        brk                                     ; 8AC2
        brk                                     ; 8AC3
        .byte   $7B                             ; 8AC4
        .byte   $7B                             ; 8AC5
        .byte   $7B                             ; 8AC6
        .byte   $7B                             ; 8AC7
        ror     $7E84,x                         ; 8AC8
        sty     $7B                             ; 8ACB
        .byte   $7B                             ; 8ACD
        .byte   $7B                             ; 8ACE
        .byte   $7B                             ; 8ACF
        .byte   $7B                             ; 8AD0
        .byte   $7B                             ; 8AD1
        .byte   $7B                             ; 8AD2
        .byte   $7B                             ; 8AD3
        adc     ($61,x)                         ; 8AD4
        adc     ($61,x)                         ; 8AD6
        .byte   $FF                             ; 8AD8
        .byte   $FF                             ; 8AD9
        .byte   $FF                             ; 8ADA
        .byte   $FF                             ; 8ADB
        brk                                     ; 8ADC
        brk                                     ; 8ADD
        brk                                     ; 8ADE
        brk                                     ; 8ADF
        brk                                     ; 8AE0
        brk                                     ; 8AE1
        brk                                     ; 8AE2
        brk                                     ; 8AE3
        brk                                     ; 8AE4
        brk                                     ; 8AE5
        brk                                     ; 8AE6
        brk                                     ; 8AE7
        brk                                     ; 8AE8
        brk                                     ; 8AE9
        brk                                     ; 8AEA
        brk                                     ; 8AEB
        sei                                     ; 8AEC
        sei                                     ; 8AED
        sei                                     ; 8AEE
        sei                                     ; 8AEF
        brk                                     ; 8AF0
        brk                                     ; 8AF1
        brk                                     ; 8AF2
        brk                                     ; 8AF3
        brk                                     ; 8AF4
        brk                                     ; 8AF5
        brk                                     ; 8AF6
        brk                                     ; 8AF7
        .byte   $3F                             ; 8AF8
        .byte   $3F                             ; 8AF9
        .byte   $3F                             ; 8AFA
        .byte   $3F                             ; 8AFB
        rol     $36,x                           ; 8AFC
        rol     $36,x                           ; 8AFE
        lsr     $56,x                           ; 8B00
        lsr     $56,x                           ; 8B02
        lsr     $56,x                           ; 8B04
        lsr     $56,x                           ; 8B06
        rol     $36,x                           ; 8B08
        rol     $63,x                           ; 8B0A
        rol     $36,x                           ; 8B0C
        rol     $36,x                           ; 8B0E
        .byte   $FF                             ; 8B10
        .byte   $FF                             ; 8B11
        .byte   $FF                             ; 8B12
        .byte   $FF                             ; 8B13
        .byte   $FF                             ; 8B14
        .byte   $FF                             ; 8B15
        .byte   $FF                             ; 8B16
        .byte   $FF                             ; 8B17
        .byte   $FF                             ; 8B18
        .byte   $FF                             ; 8B19
        .byte   $FF                             ; 8B1A
        .byte   $FF                             ; 8B1B
        .byte   $FF                             ; 8B1C
        .byte   $FF                             ; 8B1D
        .byte   $FF                             ; 8B1E
        .byte   $FF                             ; 8B1F
        .byte   $FF                             ; 8B20
        .byte   $FF                             ; 8B21
        .byte   $FF                             ; 8B22
        .byte   $FF                             ; 8B23
        .byte   $FF                             ; 8B24
        .byte   $FF                             ; 8B25
L8B26:  .byte   $FF                             ; 8B26
        .byte   $FF                             ; 8B27
L8B28:  .byte   $FF                             ; 8B28
        .byte   $FF                             ; 8B29
        .byte   $FF                             ; 8B2A
        .byte   $FF                             ; 8B2B
        .byte   $FF                             ; 8B2C
        .byte   $FF                             ; 8B2D
        .byte   $FF                             ; 8B2E
        .byte   $FF                             ; 8B2F
        .byte   $FF                             ; 8B30
        .byte   $FF                             ; 8B31
        .byte   $FF                             ; 8B32
        .byte   $FF                             ; 8B33
        .byte   $FF                             ; 8B34
        .byte   $FF                             ; 8B35
        .byte   $FF                             ; 8B36
        .byte   $FF                             ; 8B37
        .byte   $FF                             ; 8B38
        .byte   $FF                             ; 8B39
        .byte   $FF                             ; 8B3A
        .byte   $FF                             ; 8B3B
        .byte   $FF                             ; 8B3C
        .byte   $FF                             ; 8B3D
        .byte   $FF                             ; 8B3E
        .byte   $FF                             ; 8B3F
        lsr     $56,x                           ; 8B40
        lsr     $56,x                           ; 8B42
        lsr     $56,x                           ; 8B44
        lsr     $56,x                           ; 8B46
        rol     $36,x                           ; 8B48
        rol     $36,x                           ; 8B4A
        rol     $36,x                           ; 8B4C
        rol     $36,x                           ; 8B4E
        .byte   $FF                             ; 8B50
        .byte   $FF                             ; 8B51
        .byte   $FF                             ; 8B52
        .byte   $FF                             ; 8B53
        .byte   $FF                             ; 8B54
        .byte   $FF                             ; 8B55
        .byte   $FF                             ; 8B56
        .byte   $FF                             ; 8B57
        .byte   $FF                             ; 8B58
        .byte   $FF                             ; 8B59
        .byte   $FF                             ; 8B5A
        .byte   $FF                             ; 8B5B
        .byte   $FF                             ; 8B5C
        .byte   $FF                             ; 8B5D
        .byte   $FF                             ; 8B5E
        .byte   $FF                             ; 8B5F
        .byte   $FF                             ; 8B60
        .byte   $FF                             ; 8B61
        .byte   $FF                             ; 8B62
        .byte   $FF                             ; 8B63
        .byte   $FF                             ; 8B64
        .byte   $FF                             ; 8B65
        .byte   $FF                             ; 8B66
        .byte   $FF                             ; 8B67
        rol     $36,x                           ; 8B68
        rol     $36,x                           ; 8B6A
        rol     $36,x                           ; 8B6C
        rol     $36,x                           ; 8B6E
        rol     $36,x                           ; 8B70
        rol     $36,x                           ; 8B72
        rol     $36,x                           ; 8B74
        rol     $36,x                           ; 8B76
        .byte   $FF                             ; 8B78
        .byte   $FF                             ; 8B79
        .byte   $FF                             ; 8B7A
        .byte   $FF                             ; 8B7B
        .byte   $FF                             ; 8B7C
        .byte   $FF                             ; 8B7D
        .byte   $FF                             ; 8B7E
        .byte   $FF                             ; 8B7F
        .byte   $FF                             ; 8B80
        .byte   $FF                             ; 8B81
        .byte   $FF                             ; 8B82
        .byte   $FF                             ; 8B83
        .byte   $FF                             ; 8B84
        .byte   $FF                             ; 8B85
        .byte   $FF                             ; 8B86
        .byte   $FF                             ; 8B87
        txa                                     ; 8B88
        txa                                     ; 8B89
        txa                                     ; 8B8A
        txa                                     ; 8B8B
        sta     ($91),y                         ; 8B8C
        sta     ($91),y                         ; 8B8E
        .byte   $8B                             ; 8B90
        .byte   $8B                             ; 8B91
        .byte   $8B                             ; 8B92
        .byte   $8B                             ; 8B93
        bcc     L8B26                           ; 8B94
        bcc     L8B28                           ; 8B96
        sty     L8C8C                           ; 8B98
        sty     L8F8F                           ; 8B9B
        .byte   $8F                             ; 8B9E
        .byte   $8F                             ; 8B9F
        .byte   $FF                             ; 8BA0
        .byte   $FF                             ; 8BA1
        .byte   $FF                             ; 8BA2
L8BA3:  .byte   $FF                             ; 8BA3
        brk                                     ; 8BA4
        .byte   $03                             ; 8BA5
        asl     $06                             ; 8BA6
        .byte   $03                             ; 8BA8
        brk                                     ; 8BA9
        asl     $06                             ; 8BAA
        brk                                     ; 8BAC
        .byte   $03                             ; 8BAD
L8BAE:  asl     $06                             ; 8BAE
L8BB0:  brk                                     ; 8BB0
        .byte   $03                             ; 8BB1
        asl     $06                             ; 8BB2
        brk                                     ; 8BB4
        .byte   $03                             ; 8BB5
        asl     $06                             ; 8BB6
        brk                                     ; 8BB8
        .byte   $03                             ; 8BB9
        asl     $06                             ; 8BBA
        .byte   $FF                             ; 8BBC
        .byte   $FF                             ; 8BBD
        .byte   $FF                             ; 8BBE
        .byte   $FF                             ; 8BBF
        .byte   $FF                             ; 8BC0
        .byte   $FF                             ; 8BC1
        .byte   $FF                             ; 8BC2
        .byte   $FF                             ; 8BC3
        .byte   $FF                             ; 8BC4
        .byte   $FF                             ; 8BC5
        .byte   $FF                             ; 8BC6
        .byte   $FF                             ; 8BC7
        .byte   $FF                             ; 8BC8
        .byte   $FF                             ; 8BC9
        .byte   $FF                             ; 8BCA
        .byte   $FF                             ; 8BCB
        .byte   $FF                             ; 8BCC
        .byte   $FF                             ; 8BCD
        .byte   $FF                             ; 8BCE
        .byte   $FF                             ; 8BCF
        .byte   $FF                             ; 8BD0
        .byte   $FF                             ; 8BD1
        .byte   $FF                             ; 8BD2
        .byte   $FF                             ; 8BD3
        .byte   $FF                             ; 8BD4
        .byte   $FF                             ; 8BD5
        .byte   $FF                             ; 8BD6
        .byte   $FF                             ; 8BD7
        .byte   $FF                             ; 8BD8
        .byte   $FF                             ; 8BD9
        .byte   $FF                             ; 8BDA
        .byte   $FF                             ; 8BDB
        .byte   $FF                             ; 8BDC
        .byte   $FF                             ; 8BDD
        .byte   $FF                             ; 8BDE
        .byte   $FF                             ; 8BDF
        rol     $36,x                           ; 8BE0
        rol     $36,x                           ; 8BE2
        lsr     $56,x                           ; 8BE4
        lsr     $56,x                           ; 8BE6
        .byte   $FF                             ; 8BE8
        .byte   $FF                             ; 8BE9
        .byte   $FF                             ; 8BEA
        .byte   $FF                             ; 8BEB
        .byte   $FF                             ; 8BEC
        .byte   $FF                             ; 8BED
        .byte   $FF                             ; 8BEE
        .byte   $FF                             ; 8BEF
        .byte   $9E                             ; 8BF0
        .byte   $9E                             ; 8BF1
        .byte   $9E                             ; 8BF2
        .byte   $9E                             ; 8BF3
        .byte   $9E                             ; 8BF4
        .byte   $9E                             ; 8BF5
        .byte   $9E                             ; 8BF6
        .byte   $9E                             ; 8BF7
        .byte   $9E                             ; 8BF8
        .byte   $9E                             ; 8BF9
        .byte   $9E                             ; 8BFA
        .byte   $9E                             ; 8BFB
        bcs     L8BAE                           ; 8BFC
        bcs     L8BB0                           ; 8BFE
        .byte   $AB                             ; 8C00
        .byte   $AB                             ; 8C01
        .byte   $AB                             ; 8C02
        .byte   $AB                             ; 8C03
        .byte   $04                             ; 8C04
        sed                                     ; 8C05
        brk                                     ; 8C06
        ora     ($E8,x)                         ; 8C07
        brk                                     ; 8C09
        brk                                     ; 8C0A
        ora     ($E8),y                         ; 8C0B
        sed                                     ; 8C0D
        brk                                     ; 8C0E
        .byte   $03                             ; 8C0F
        sed                                     ; 8C10
        brk                                     ; 8C11
        brk                                     ; 8C12
        .byte   $13                             ; 8C13
        sed                                     ; 8C14
        .byte   $04                             ; 8C15
        sed                                     ; 8C16
        rti                                     ; 8C17

; ----------------------------------------------------------------------------
        ora     ($E8),y                         ; 8C18
        brk                                     ; 8C1A
        rti                                     ; 8C1B

; ----------------------------------------------------------------------------
        ora     ($E8,x)                         ; 8C1C
        sed                                     ; 8C1E
        rti                                     ; 8C1F

; ----------------------------------------------------------------------------
        .byte   $13                             ; 8C20
        sed                                     ; 8C21
        brk                                     ; 8C22
        rti                                     ; 8C23

; ----------------------------------------------------------------------------
        .byte   $03                             ; 8C24
        sed                                     ; 8C25
        .byte   $04                             ; 8C26
        sed                                     ; 8C27
        brk                                     ; 8C28
        and     ($E8,x)                         ; 8C29
        brk                                     ; 8C2B
        brk                                     ; 8C2C
        and     ($E8),y                         ; 8C2D
        sed                                     ; 8C2F
        brk                                     ; 8C30
        .byte   $23                             ; 8C31
        sed                                     ; 8C32
        brk                                     ; 8C33
        brk                                     ; 8C34
        .byte   $33                             ; 8C35
        sed                                     ; 8C36
        .byte   $04                             ; 8C37
        sed                                     ; 8C38
        rti                                     ; 8C39

; ----------------------------------------------------------------------------
        and     ($E8),y                         ; 8C3A
        brk                                     ; 8C3C
        rti                                     ; 8C3D

; ----------------------------------------------------------------------------
        and     ($E8,x)                         ; 8C3E
        sed                                     ; 8C40
        rti                                     ; 8C41

; ----------------------------------------------------------------------------
        .byte   $33                             ; 8C42
        sed                                     ; 8C43
        brk                                     ; 8C44
        rti                                     ; 8C45

; ----------------------------------------------------------------------------
        .byte   $23                             ; 8C46
        sed                                     ; 8C47
        ora     ($FC,x)                         ; 8C48
        brk                                     ; 8C4A
        .byte   $77                             ; 8C4B
        ora     ($06,x)                         ; 8C4C
        inx                                     ; 8C4E
        brk                                     ; 8C4F
        dec     $F0D8                           ; 8C50
        brk                                     ; 8C53
        dec     $F8D8,x                         ; 8C54
        brk                                     ; 8C57
        ldy     a:$D8                           ; 8C58
        brk                                     ; 8C5B
        ldy     $F8D8,x                         ; 8C5C
        brk                                     ; 8C5F
        inc     a:$E8                           ; 8C60
        brk                                     ; 8C63
        inc     $05E8,x                         ; 8C64
        sed                                     ; 8C67
        brk                                     ; 8C68
        ora     ($E8,x)                         ; 8C69
        brk                                     ; 8C6B
        brk                                     ; 8C6C
        ora     ($E8),y                         ; 8C6D
        sed                                     ; 8C6F
        brk                                     ; 8C70
        .byte   $0D                             ; 8C71
        sed                                     ; 8C72
L8C73:  brk                                     ; 8C73
        brk                                     ; 8C74
        ora     $08F8,x                         ; 8C75
        rti                                     ; 8C78

; ----------------------------------------------------------------------------
        and     $05F8,x                         ; 8C79
        sed                                     ; 8C7C
        brk                                     ; 8C7D
        ora     ($F0,x)                         ; 8C7E
        brk                                     ; 8C80
        brk                                     ; 8C81
        ora     ($F0),y                         ; 8C82
        sed                                     ; 8C84
        brk                                     ; 8C85
        .byte   $0B                             ; 8C86
        brk                                     ; 8C87
        brk                                     ; 8C88
        brk                                     ; 8C89
        .byte   $1B                             ; 8C8A
        brk                                     ; 8C8B
L8C8C:  .byte   $FB                             ; 8C8C
        .byte   $80                             ; 8C8D
        and     $060E                           ; 8C8E
        sed                                     ; 8C91
        brk                                     ; 8C92
        ora     ($E8,x)                         ; 8C93
        brk                                     ; 8C95
        brk                                     ; 8C96
        ora     ($E8),y                         ; 8C97
        sed                                     ; 8C99
        brk                                     ; 8C9A
        ora     a:$F8                           ; 8C9B
        brk                                     ; 8C9E
        .byte   $1D                             ; 8C9F
        sed                                     ; 8CA0
L8CA1:  php                                     ; 8CA1
        rti                                     ; 8CA2

; ----------------------------------------------------------------------------
        and     $10F8,y                         ; 8CA3
        rti                                     ; 8CA6

; ----------------------------------------------------------------------------
        .byte   $3B                             ; 8CA7
        sed                                     ; 8CA8
        ora     $F8                             ; 8CA9
        brk                                     ; 8CAB
        ora     ($F0,x)                         ; 8CAC
        brk                                     ; 8CAE
        brk                                     ; 8CAF
        ora     ($F0),y                         ; 8CB0
        sed                                     ; 8CB2
        brk                                     ; 8CB3
        .byte   $0B                             ; 8CB4
        brk                                     ; 8CB5
        brk                                     ; 8CB6
        brk                                     ; 8CB7
        .byte   $1B                             ; 8CB8
        brk                                     ; 8CB9
        .byte   $FB                             ; 8CBA
        .byte   $80                             ; 8CBB
        .byte   $2B                             ; 8CBC
        asl     $F805                           ; 8CBD
        brk                                     ; 8CC0
        ora     ($E8,x)                         ; 8CC1
        brk                                     ; 8CC3
        brk                                     ; 8CC4
        ora     ($E8),y                         ; 8CC5
        sed                                     ; 8CC7
        brk                                     ; 8CC8
        ora     a:$F8                           ; 8CC9
        brk                                     ; 8CCC
        ora     $08F8,x                         ; 8CCD
        rti                                     ; 8CD0

; ----------------------------------------------------------------------------
        .byte   $3F                             ; 8CD1
        sed                                     ; 8CD2
        ora     $F8                             ; 8CD3
        brk                                     ; 8CD5
        ora     ($F0,x)                         ; 8CD6
        brk                                     ; 8CD8
        brk                                     ; 8CD9
        ora     ($F0),y                         ; 8CDA
        sed                                     ; 8CDC
        brk                                     ; 8CDD
        .byte   $0B                             ; 8CDE
        brk                                     ; 8CDF
        brk                                     ; 8CE0
        brk                                     ; 8CE1
        .byte   $1B                             ; 8CE2
        brk                                     ; 8CE3
        .byte   $FB                             ; 8CE4
        .byte   $80                             ; 8CE5
        .byte   $2F                             ; 8CE6
        asl     $F805                           ; 8CE7
        brk                                     ; 8CEA
        and     ($E8,x)                         ; 8CEB
        brk                                     ; 8CED
        rti                                     ; 8CEE

; ----------------------------------------------------------------------------
        and     ($E8,x)                         ; 8CEF
        beq     L8C73                           ; 8CF1
        and     $F8F4,x                         ; 8CF3
        brk                                     ; 8CF6
        .byte   $23                             ; 8CF7
        sed                                     ; 8CF8
        brk                                     ; 8CF9
        brk                                     ; 8CFA
        .byte   $33                             ; 8CFB
        sed                                     ; 8CFC
        ora     $FE                             ; 8CFD
        rti                                     ; 8CFF

; ----------------------------------------------------------------------------
        and     $F8DB                           ; 8D00
        brk                                     ; 8D03
        and     ($E8,x)                         ; 8D04
        brk                                     ; 8D06
        brk                                     ; 8D07
        and     $E8,x                           ; 8D08
        sed                                     ; 8D0A
        brk                                     ; 8D0B
        .byte   $23                             ; 8D0C
        sed                                     ; 8D0D
        brk                                     ; 8D0E
        brk                                     ; 8D0F
        .byte   $33                             ; 8D10
        sed                                     ; 8D11
        asl     $F8                             ; 8D12
        brk                                     ; 8D14
        and     ($E8,x)                         ; 8D15
        brk                                     ; 8D17
        rti                                     ; 8D18

; ----------------------------------------------------------------------------
        and     ($E8,x)                         ; 8D19
        inx                                     ; 8D1B
        .byte   $80                             ; 8D1C
        .byte   $3B                             ; 8D1D
        .byte   $F4                             ; 8D1E
        beq     L8CA1                           ; 8D1F
        and     $F8F4,y                         ; 8D21
        brk                                     ; 8D24
        .byte   $23                             ; 8D25
        sed                                     ; 8D26
        brk                                     ; 8D27
        brk                                     ; 8D28
        .byte   $33                             ; 8D29
        sed                                     ; 8D2A
        ora     $FE                             ; 8D2B
        rti                                     ; 8D2D

; ----------------------------------------------------------------------------
        .byte   $2B                             ; 8D2E
        .byte   $DB                             ; 8D2F
        sed                                     ; 8D30
        brk                                     ; 8D31
        and     ($E8,x)                         ; 8D32
        brk                                     ; 8D34
        brk                                     ; 8D35
        and     $E8,x                           ; 8D36
        sed                                     ; 8D38
        brk                                     ; 8D39
        .byte   $23                             ; 8D3A
        sed                                     ; 8D3B
        brk                                     ; 8D3C
        brk                                     ; 8D3D
        .byte   $33                             ; 8D3E
        sed                                     ; 8D3F
        ora     $F8                             ; 8D40
        brk                                     ; 8D42
        and     ($E8,x)                         ; 8D43
        brk                                     ; 8D45
        rti                                     ; 8D46

; ----------------------------------------------------------------------------
        and     ($E8,x)                         ; 8D47
        beq     L8D4B                           ; 8D49
L8D4B:  .byte   $3F                             ; 8D4B
        sed                                     ; 8D4C
        sed                                     ; 8D4D
        brk                                     ; 8D4E
        .byte   $23                             ; 8D4F
        sed                                     ; 8D50
        brk                                     ; 8D51
        brk                                     ; 8D52
        .byte   $33                             ; 8D53
        sed                                     ; 8D54
        ora     $00                             ; 8D55
        brk                                     ; 8D57
        .byte   $2F                             ; 8D58
        .byte   $DB                             ; 8D59
        sed                                     ; 8D5A
        brk                                     ; 8D5B
        and     ($E8,x)                         ; 8D5C
        brk                                     ; 8D5E
        brk                                     ; 8D5F
        and     $E8,x                           ; 8D60
        sed                                     ; 8D62
        brk                                     ; 8D63
        .byte   $23                             ; 8D64
        sed                                     ; 8D65
        brk                                     ; 8D66
        brk                                     ; 8D67
        .byte   $33                             ; 8D68
        sed                                     ; 8D69
        .byte   $FF                             ; 8D6A
        .byte   $04                             ; 8D6B
        sed                                     ; 8D6C
        brk                                     ; 8D6D
        ora     $E8                             ; 8D6E
        brk                                     ; 8D70
        brk                                     ; 8D71
        ora     $E8,x                           ; 8D72
        sed                                     ; 8D74
        brk                                     ; 8D75
        .byte   $27                             ; 8D76
        sed                                     ; 8D77
        brk                                     ; 8D78
        brk                                     ; 8D79
        .byte   $37                             ; 8D7A
        sed                                     ; 8D7B
        .byte   $FF                             ; 8D7C
        .byte   $04                             ; 8D7D
        sed                                     ; 8D7E
        brk                                     ; 8D7F
        ora     $E8                             ; 8D80
        brk                                     ; 8D82
        brk                                     ; 8D83
        ora     $E8,x                           ; 8D84
        sed                                     ; 8D86
        brk                                     ; 8D87
        .byte   $07                             ; 8D88
        sed                                     ; 8D89
        brk                                     ; 8D8A
        brk                                     ; 8D8B
        .byte   $17                             ; 8D8C
        sed                                     ; 8D8D
        .byte   $FF                             ; 8D8E
        .byte   $04                             ; 8D8F
        sed                                     ; 8D90
        brk                                     ; 8D91
        adc     #$E8                            ; 8D92
        brk                                     ; 8D94
        brk                                     ; 8D95
        adc     $F8E8,y                         ; 8D96
        brk                                     ; 8D99
        .byte   $6B                             ; 8D9A
        sed                                     ; 8D9B
        brk                                     ; 8D9C
        brk                                     ; 8D9D
        .byte   $7B                             ; 8D9E
        sed                                     ; 8D9F
        .byte   $FF                             ; 8DA0
        ora     $F8                             ; 8DA1
        brk                                     ; 8DA3
        and     $F8DE                           ; 8DA4
        brk                                     ; 8DA7
        eor     $E8,y                           ; 8DA8
        brk                                     ; 8DAB
        ora     $E8,x                           ; 8DAC
        sed                                     ; 8DAE
        brk                                     ; 8DAF
        and     #$F8                            ; 8DB0
        brk                                     ; 8DB2
        brk                                     ; 8DB3
        ora     $FFF8,y                         ; 8DB4
        ora     $F8                             ; 8DB7
        brk                                     ; 8DB9
        ora     $E8                             ; 8DBA
        brk                                     ; 8DBC
        brk                                     ; 8DBD
        ora     $E8,x                           ; 8DBE
        beq     L8DC2                           ; 8DC0
L8DC2:  and     $F8F8,x                         ; 8DC2
        brk                                     ; 8DC5
        ora     #$F8                            ; 8DC6
        brk                                     ; 8DC8
        brk                                     ; 8DC9
        ora     $FFF8,y                         ; 8DCA
        ora     $F8                             ; 8DCD
        brk                                     ; 8DCF
        .byte   $2B                             ; 8DD0
        dec     a:$F8,x                         ; 8DD1
        eor     $E8,y                           ; 8DD4
        brk                                     ; 8DD7
        ora     $E8,x                           ; 8DD8
        sed                                     ; 8DDA
        brk                                     ; 8DDB
        and     #$F8                            ; 8DDC
        brk                                     ; 8DDE
        brk                                     ; 8DDF
        ora     $FFF8,y                         ; 8DE0
        asl     $F8                             ; 8DE3
        brk                                     ; 8DE5
        ora     $E8                             ; 8DE6
        brk                                     ; 8DE8
        brk                                     ; 8DE9
        ora     $E8,x                           ; 8DEA
        inx                                     ; 8DEC
        brk                                     ; 8DED
        .byte   $3B                             ; 8DEE
        sed                                     ; 8DEF
        beq     L8DF2                           ; 8DF0
L8DF2:  and     $F8F8,y                         ; 8DF2
        brk                                     ; 8DF5
        ora     #$F8                            ; 8DF6
        brk                                     ; 8DF8
        brk                                     ; 8DF9
        ora     $FFF8,y                         ; 8DFA
        ora     $F8                             ; 8DFD
        brk                                     ; 8DFF
        .byte   $2F                             ; 8E00
        dec     a:$F8,x                         ; 8E01
        eor     $E8,y                           ; 8E04
        brk                                     ; 8E07
        ora     $E8,x                           ; 8E08
        sed                                     ; 8E0A
        brk                                     ; 8E0B
        and     #$F8                            ; 8E0C
        brk                                     ; 8E0E
        brk                                     ; 8E0F
        ora     $FFF8,y                         ; 8E10
        ora     $F8                             ; 8E13
        brk                                     ; 8E15
        ora     $E8                             ; 8E16
        brk                                     ; 8E18
        brk                                     ; 8E19
        ora     $E8,x                           ; 8E1A
        beq     L8E1E                           ; 8E1C
L8E1E:  .byte   $3F                             ; 8E1E
        sed                                     ; 8E1F
        sed                                     ; 8E20
        brk                                     ; 8E21
        ora     #$F8                            ; 8E22
        brk                                     ; 8E24
        brk                                     ; 8E25
        ora     $04F8,y                         ; 8E26
        sed                                     ; 8E29
        brk                                     ; 8E2A
        eor     $E8                             ; 8E2B
        brk                                     ; 8E2D
        rti                                     ; 8E2E

; ----------------------------------------------------------------------------
        eor     $E8                             ; 8E2F
        sed                                     ; 8E31
        brk                                     ; 8E32
        .byte   $47                             ; 8E33
        sed                                     ; 8E34
        brk                                     ; 8E35
        rti                                     ; 8E36

; ----------------------------------------------------------------------------
        .byte   $47                             ; 8E37
        sed                                     ; 8E38
        .byte   $04                             ; 8E39
        sed                                     ; 8E3A
        brk                                     ; 8E3B
        .byte   $1F                             ; 8E3C
        inx                                     ; 8E3D
        brk                                     ; 8E3E
        rti                                     ; 8E3F

; ----------------------------------------------------------------------------
        .byte   $1F                             ; 8E40
        inx                                     ; 8E41
        sed                                     ; 8E42
        brk                                     ; 8E43
        .byte   $0F                             ; 8E44
        sed                                     ; 8E45
        brk                                     ; 8E46
        rti                                     ; 8E47

; ----------------------------------------------------------------------------
        .byte   $0F                             ; 8E48
        sed                                     ; 8E49
        .byte   $02                             ; 8E4A
        sed                                     ; 8E4B
        brk                                     ; 8E4C
        .byte   $1F                             ; 8E4D
        sed                                     ; 8E4E
        brk                                     ; 8E4F
        rti                                     ; 8E50

; ----------------------------------------------------------------------------
        .byte   $1F                             ; 8E51
        sed                                     ; 8E52
        .byte   $02                             ; 8E53
        sed                                     ; 8E54
        .byte   $02                             ; 8E55
        eor     ($F8,x)                         ; 8E56
        brk                                     ; 8E58
        .byte   $42                             ; 8E59
        eor     ($F8,x)                         ; 8E5A
        .byte   $02                             ; 8E5C
        sed                                     ; 8E5D
        brk                                     ; 8E5E
        eor     ($F8),y                         ; 8E5F
        brk                                     ; 8E61
        rti                                     ; 8E62

; ----------------------------------------------------------------------------
        eor     ($F8),y                         ; 8E63
        .byte   $02                             ; 8E65
        sed                                     ; 8E66
        brk                                     ; 8E67
        eor     a:$F8                           ; 8E68
        rti                                     ; 8E6B

; ----------------------------------------------------------------------------
        eor     $02F8                           ; 8E6C
        sed                                     ; 8E6F
        brk                                     ; 8E70
        eor     a:$F8,x                         ; 8E71
        rti                                     ; 8E74

; ----------------------------------------------------------------------------
        eor     $FFF8,x                         ; 8E75
        ora     ($FC,x)                         ; 8E78
        brk                                     ; 8E7A
        .byte   $4B                             ; 8E7B
        sed                                     ; 8E7C
        .byte   $02                             ; 8E7D
        sed                                     ; 8E7E
        brk                                     ; 8E7F
        .byte   $4F                             ; 8E80
        sed                                     ; 8E81
        brk                                     ; 8E82
        rti                                     ; 8E83

; ----------------------------------------------------------------------------
        .byte   $4F                             ; 8E84
        sed                                     ; 8E85
        .byte   $02                             ; 8E86
        sed                                     ; 8E87
        brk                                     ; 8E88
        .byte   $5F                             ; 8E89
        sed                                     ; 8E8A
        brk                                     ; 8E8B
        rti                                     ; 8E8C

; ----------------------------------------------------------------------------
        .byte   $5F                             ; 8E8D
        sed                                     ; 8E8E
        .byte   $FF                             ; 8E8F
        .byte   $02                             ; 8E90
        sed                                     ; 8E91
        brk                                     ; 8E92
        adc     a:$F8                           ; 8E93
        brk                                     ; 8E96
        adc     $02F8,x                         ; 8E97
        sed                                     ; 8E9A
        brk                                     ; 8E9B
        .byte   $6F                             ; 8E9C
        sed                                     ; 8E9D
        brk                                     ; 8E9E
        rti                                     ; 8E9F

; ----------------------------------------------------------------------------
        .byte   $6F                             ; 8EA0
        sed                                     ; 8EA1
        .byte   $02                             ; 8EA2
        sed                                     ; 8EA3
        brk                                     ; 8EA4
        .byte   $7F                             ; 8EA5
        sed                                     ; 8EA6
        brk                                     ; 8EA7
        rti                                     ; 8EA8

; ----------------------------------------------------------------------------
        .byte   $7F                             ; 8EA9
        sed                                     ; 8EAA
        ora     ($FC,x)                         ; 8EAB
        brk                                     ; 8EAD
        .byte   $63                             ; 8EAE
        sed                                     ; 8EAF
        ora     ($FC,x)                         ; 8EB0
        .byte   $02                             ; 8EB2
        .byte   $43                             ; 8EB3
        sed                                     ; 8EB4
        ora     ($FC,x)                         ; 8EB5
        brk                                     ; 8EB7
        .byte   $73                             ; 8EB8
        sed                                     ; 8EB9
        ora     ($FC,x)                         ; 8EBA
        .byte   $02                             ; 8EBC
        and     $F8                             ; 8EBD
        .byte   $02                             ; 8EBF
        sed                                     ; 8EC0
        brk                                     ; 8EC1
        eor     $F8,x                           ; 8EC2
        brk                                     ; 8EC4
        rti                                     ; 8EC5

; ----------------------------------------------------------------------------
        eor     $F8,x                           ; 8EC6
        ora     ($FC,x)                         ; 8EC8
        .byte   $02                             ; 8ECA
        .byte   $5B                             ; 8ECB
        sed                                     ; 8ECC
        .byte   $04                             ; 8ECD
        sed                                     ; 8ECE
        brk                                     ; 8ECF
        .byte   $C3                             ; 8ED0
        inx                                     ; 8ED1
        brk                                     ; 8ED2
        rti                                     ; 8ED3

; ----------------------------------------------------------------------------
        .byte   $C3                             ; 8ED4
        inx                                     ; 8ED5
        sed                                     ; 8ED6
        brk                                     ; 8ED7
        cmp     $F8                             ; 8ED8
        brk                                     ; 8EDA
        rti                                     ; 8EDB

; ----------------------------------------------------------------------------
        cmp     $F8                             ; 8EDC
        .byte   $FF                             ; 8EDE
        .byte   $02                             ; 8EDF
        sed                                     ; 8EE0
        brk                                     ; 8EE1
        asl     a:$F8                           ; 8EE2
        brk                                     ; 8EE5
        .byte   $0C                             ; 8EE6
        sed                                     ; 8EE7
        .byte   $02                             ; 8EE8
        sed                                     ; 8EE9
        brk                                     ; 8EEA
        asl     $E8,x                           ; 8EEB
        brk                                     ; 8EED
        rti                                     ; 8EEE

; ----------------------------------------------------------------------------
        asl     $E8,x                           ; 8EEF
        .byte   $02                             ; 8EF1
        sed                                     ; 8EF2
        brk                                     ; 8EF3
        sbc     $F8                             ; 8EF4
        brk                                     ; 8EF6
        brk                                     ; 8EF7
        sbc     $F8,x                           ; 8EF8
        .byte   $02                             ; 8EFA
        sed                                     ; 8EFB
        brk                                     ; 8EFC
        asl     a:$F8,x                         ; 8EFD
        rti                                     ; 8F00

; ----------------------------------------------------------------------------
        asl     $04F8,x                         ; 8F01
        sed                                     ; 8F04
        brk                                     ; 8F05
        .byte   $1C                             ; 8F06
        inx                                     ; 8F07
        brk                                     ; 8F08
        rti                                     ; 8F09

; ----------------------------------------------------------------------------
        .byte   $1C                             ; 8F0A
        inx                                     ; 8F0B
        sed                                     ; 8F0C
        brk                                     ; 8F0D
        plp                                     ; 8F0E
        sed                                     ; 8F0F
        brk                                     ; 8F10
        rti                                     ; 8F11

; ----------------------------------------------------------------------------
        plp                                     ; 8F12
        sed                                     ; 8F13
        ora     ($FC,x)                         ; 8F14
        brk                                     ; 8F16
        .byte   $53                             ; 8F17
        sed                                     ; 8F18
        ora     ($FC,x)                         ; 8F19
        brk                                     ; 8F1B
        adc     $F8                             ; 8F1C
        ora     ($FC,x)                         ; 8F1E
        brk                                     ; 8F20
        adc     $F8,x                           ; 8F21
        .byte   $02                             ; 8F23
        sed                                     ; 8F24
        brk                                     ; 8F25
        .byte   $67                             ; 8F26
        sed                                     ; 8F27
        brk                                     ; 8F28
        rti                                     ; 8F29

; ----------------------------------------------------------------------------
        .byte   $67                             ; 8F2A
        sed                                     ; 8F2B
        .byte   $02                             ; 8F2C
        sed                                     ; 8F2D
        brk                                     ; 8F2E
        adc     ($F8),y                         ; 8F2F
        brk                                     ; 8F31
        rti                                     ; 8F32

; ----------------------------------------------------------------------------
        adc     ($F8),y                         ; 8F33
        .byte   $02                             ; 8F35
        sed                                     ; 8F36
        brk                                     ; 8F37
        adc     ($F8,x)                         ; 8F38
        brk                                     ; 8F3A
        rti                                     ; 8F3B

; ----------------------------------------------------------------------------
        adc     ($F8,x)                         ; 8F3C
        ora     ($FC,x)                         ; 8F3E
        brk                                     ; 8F40
        .byte   $F3                             ; 8F41
        sed                                     ; 8F42
        .byte   $02                             ; 8F43
        sed                                     ; 8F44
        .byte   $03                             ; 8F45
        .byte   $CF                             ; 8F46
        sed                                     ; 8F47
        brk                                     ; 8F48
        .byte   $03                             ; 8F49
        .byte   $DF                             ; 8F4A
        sed                                     ; 8F4B
        .byte   $02                             ; 8F4C
        sed                                     ; 8F4D
        .byte   $03                             ; 8F4E
        .byte   $CF                             ; 8F4F
        sed                                     ; 8F50
        brk                                     ; 8F51
        .byte   $03                             ; 8F52
L8F53:  .byte   $DF                             ; 8F53
        sed                                     ; 8F54
        php                                     ; 8F55
        .byte   $F0                             ; 8F56
L8F57:  ora     ($C1,x)                         ; 8F57
L8F59:  beq     L8F53                           ; 8F59
        ora     ($D1,x)                         ; 8F5B
        beq     L8F5F                           ; 8F5D
L8F5F:  eor     ($D1,x)                         ; 8F5F
        beq     L8F6B                           ; 8F61
        eor     ($C1,x)                         ; 8F63
        beq     L8F57                           ; 8F65
        ora     ($C3,x)                         ; 8F67
        brk                                     ; 8F69
        sed                                     ; 8F6A
L8F6B:  ora     ($D3,x)                         ; 8F6B
        brk                                     ; 8F6D
        brk                                     ; 8F6E
        ora     ($E3,x)                         ; 8F6F
        brk                                     ; 8F71
        php                                     ; 8F72
        .byte   $01                             ; 8F73
L8F74:  .byte   $B3                             ; 8F74
        brk                                     ; 8F75
        php                                     ; 8F76
        .byte   $F0                             ; 8F77
L8F78:  ora     ($A1,x)                         ; 8F78
L8F7A:  beq     L8F74                           ; 8F7A
        ora     ($B1,x)                         ; 8F7C
        beq     L8F80                           ; 8F7E
L8F80:  eor     ($B1,x)                         ; 8F80
        beq     L8F8C                           ; 8F82
        eor     ($A1,x)                         ; 8F84
        beq     L8F78                           ; 8F86
        eor     ($B3,x)                         ; 8F88
        brk                                     ; 8F8A
        sed                                     ; 8F8B
L8F8C:  eor     ($E3,x)                         ; 8F8C
        brk                                     ; 8F8E
L8F8F:  brk                                     ; 8F8F
        eor     ($D3,x)                         ; 8F90
        brk                                     ; 8F92
        php                                     ; 8F93
        .byte   $41                             ; 8F94
L8F95:  .byte   $C3                             ; 8F95
        brk                                     ; 8F96
        php                                     ; 8F97
        .byte   $F0                             ; 8F98
L8F99:  ora     ($A5,x)                         ; 8F99
L8F9B:  beq     L8F95                           ; 8F9B
        ora     ($E5,x)                         ; 8F9D
        beq     L8FA1                           ; 8F9F
L8FA1:  eor     ($E5,x)                         ; 8FA1
        beq     L8FAD                           ; 8FA3
        eor     ($A5,x)                         ; 8FA5
        beq     L8F99                           ; 8FA7
        ora     ($A7,x)                         ; 8FA9
        brk                                     ; 8FAB
        sed                                     ; 8FAC
L8FAD:  ora     ($E7,x)                         ; 8FAD
        brk                                     ; 8FAF
        brk                                     ; 8FB0
        eor     ($E7,x)                         ; 8FB1
        brk                                     ; 8FB3
        php                                     ; 8FB4
        ora     ($E9,x)                         ; 8FB5
        brk                                     ; 8FB7
        .byte   $FF                             ; 8FB8
        .byte   $04                             ; 8FB9
        sed                                     ; 8FBA
        .byte   $02                             ; 8FBB
        .byte   $89                             ; 8FBC
        beq     L8FBF                           ; 8FBD
L8FBF:  .byte   $02                             ; 8FBF
        sta     $F8F0,y                         ; 8FC0
        .byte   $02                             ; 8FC3
        .byte   $8B                             ; 8FC4
        brk                                     ; 8FC5
        brk                                     ; 8FC6
        .byte   $02                             ; 8FC7
        .byte   $9B                             ; 8FC8
        brk                                     ; 8FC9
        ora     ($FC,x)                         ; 8FCA
        .byte   $02                             ; 8FCC
        sbc     ($F8,x)                         ; 8FCD
        ora     ($FC,x)                         ; 8FCF
        .byte   $02                             ; 8FD1
        sbc     ($F8),y                         ; 8FD2
        ora     ($FC,x)                         ; 8FD4
        ora     ($84,x)                         ; 8FD6
        sed                                     ; 8FD8
        .byte   $FF                             ; 8FD9
        php                                     ; 8FDA
        beq     L8FDF                           ; 8FDB
        .byte   $CD                             ; 8FDD
        inx                                     ; 8FDE
L8FDF:  sed                                     ; 8FDF
        .byte   $02                             ; 8FE0
        cmp     a:$E8,x                         ; 8FE1
        .byte   $02                             ; 8FE4
        sbc     $08E8                           ; 8FE5
        .byte   $02                             ; 8FE8
        sbc     $F0E8,x                         ; 8FE9
        .byte   $02                             ; 8FEC
        .byte   $CF                             ; 8FED
        sed                                     ; 8FEE
        sed                                     ; 8FEF
        .byte   $02                             ; 8FF0
        .byte   $DF                             ; 8FF1
        sed                                     ; 8FF2
        brk                                     ; 8FF3
        .byte   $02                             ; 8FF4
        .byte   $EF                             ; 8FF5
        sed                                     ; 8FF6
        php                                     ; 8FF7
        .byte   $02                             ; 8FF8
        .byte   $FF                             ; 8FF9
        sed                                     ; 8FFA
        .byte   $FF                             ; 8FFB
        .byte   $07                             ; 8FFC
        .byte   $FC                             ; 8FFD
        brk                                     ; 8FFE
        sbc     $D8,x                           ; 8FFF
        .byte   $F4                             ; 9001
        brk                                     ; 9002
        lda     $E8,x                           ; 9003
        .byte   $FC                             ; 9005
        brk                                     ; 9006
        cmp     $E8                             ; 9007
        .byte   $04                             ; 9009
        brk                                     ; 900A
        cmp     $E8,x                           ; 900B
        .byte   $F4                             ; 900D
        brk                                     ; 900E
        .byte   $B7                             ; 900F
        sed                                     ; 9010
        .byte   $FC                             ; 9011
        brk                                     ; 9012
        .byte   $C7                             ; 9013
        sed                                     ; 9014
        .byte   $04                             ; 9015
        brk                                     ; 9016
        .byte   $D7                             ; 9017
        sed                                     ; 9018
        .byte   $FF                             ; 9019
        asl     $FC                             ; 901A
        brk                                     ; 901C
        sbc     $D8,x                           ; 901D
        .byte   $F4                             ; 901F
        brk                                     ; 9020
        lda     $E8,x                           ; 9021
        .byte   $FC                             ; 9023
        brk                                     ; 9024
        cmp     $E8                             ; 9025
        .byte   $04                             ; 9027
        brk                                     ; 9028
        cmp     $E8,x                           ; 9029
        .byte   $FA                             ; 902B
        brk                                     ; 902C
        cmp     $02F8,y                         ; 902D
        brk                                     ; 9030
        .byte   $EB                             ; 9031
        sed                                     ; 9032
        .byte   $FF                             ; 9033
        .byte   $07                             ; 9034
        .byte   $FC                             ; 9035
        brk                                     ; 9036
        sbc     $D8,x                           ; 9037
        .byte   $F4                             ; 9039
        brk                                     ; 903A
        lda     $FCE8,y                         ; 903B
        brk                                     ; 903E
        cmp     #$E8                            ; 903F
        .byte   $04                             ; 9041
        brk                                     ; 9042
        cmp     $E8,x                           ; 9043
        .byte   $F4                             ; 9045
        brk                                     ; 9046
        .byte   $BB                             ; 9047
        sed                                     ; 9048
        .byte   $FC                             ; 9049
        brk                                     ; 904A
        .byte   $CB                             ; 904B
        sed                                     ; 904C
        .byte   $04                             ; 904D
        brk                                     ; 904E
        .byte   $DB                             ; 904F
        sed                                     ; 9050
        .byte   $FF                             ; 9051
        .byte   $07                             ; 9052
        .byte   $FC                             ; 9053
        brk                                     ; 9054
        sbc     $D8,x                           ; 9055
        .byte   $F4                             ; 9057
        brk                                     ; 9058
        lda     $FCE8                           ; 9059
        brk                                     ; 905C
        lda     $04E8,x                         ; 905D
        brk                                     ; 9060
        cmp     $E8,x                           ; 9061
        .byte   $F4                             ; 9063
        brk                                     ; 9064
        .byte   $AF                             ; 9065
        sed                                     ; 9066
        .byte   $FC                             ; 9067
        brk                                     ; 9068
        .byte   $BF                             ; 9069
        sed                                     ; 906A
        .byte   $04                             ; 906B
        brk                                     ; 906C
        .byte   $DB                             ; 906D
        sed                                     ; 906E
        .byte   $FF                             ; 906F
        .byte   $04                             ; 9070
        sed                                     ; 9071
        brk                                     ; 9072
        sta     ($E8,x)                         ; 9073
        brk                                     ; 9075
        brk                                     ; 9076
        sta     ($E8),y                         ; 9077
        sed                                     ; 9079
        brk                                     ; 907A
        .byte   $83                             ; 907B
        sed                                     ; 907C
        brk                                     ; 907D
        brk                                     ; 907E
        .byte   $93                             ; 907F
        sed                                     ; 9080
        .byte   $FF                             ; 9081
        .byte   $02                             ; 9082
        sed                                     ; 9083
        brk                                     ; 9084
        sta     $F8                             ; 9085
        brk                                     ; 9087
        brk                                     ; 9088
        sta     $F8,x                           ; 9089
        .byte   $FF                             ; 908B
        .byte   $03                             ; 908C
        .byte   $F4                             ; 908D
        brk                                     ; 908E
        .byte   $87                             ; 908F
        sed                                     ; 9090
        .byte   $FC                             ; 9091
        brk                                     ; 9092
        .byte   $97                             ; 9093
        sed                                     ; 9094
        .byte   $04                             ; 9095
        brk                                     ; 9096
        .byte   $AB                             ; 9097
        sed                                     ; 9098
        .byte   $FF                             ; 9099
        .byte   $03                             ; 909A
        .byte   $F4                             ; 909B
        brk                                     ; 909C
        .byte   $87                             ; 909D
        sed                                     ; 909E
        .byte   $FC                             ; 909F
        brk                                     ; 90A0
        lda     #$F8                            ; 90A1
        .byte   $04                             ; 90A3
        brk                                     ; 90A4
        .byte   $AB                             ; 90A5
        sed                                     ; 90A6
        ora     ($FC,x)                         ; 90A7
        ora     ($F3,x)                         ; 90A9
        sed                                     ; 90AB
        ora     ($FC,x)                         ; 90AC
        sta     ($F3,x)                         ; 90AE
        sed                                     ; 90B0
        ora     ($FC,x)                         ; 90B1
        cmp     ($F3,x)                         ; 90B3
        sed                                     ; 90B5
        ora     ($FC,x)                         ; 90B6
        eor     ($F3,x)                         ; 90B8
        sed                                     ; 90BA
        .byte   $02                             ; 90BB
        sed                                     ; 90BC
        brk                                     ; 90BD
        cmp     a:$F8                           ; 90BE
        rti                                     ; 90C1

; ----------------------------------------------------------------------------
        cmp     $02F8                           ; 90C2
        sed                                     ; 90C5
        brk                                     ; 90C6
        cmp     a:$F8,x                         ; 90C7
        rti                                     ; 90CA

; ----------------------------------------------------------------------------
        cmp     $02F8,x                         ; 90CB
        sed                                     ; 90CE
        brk                                     ; 90CF
        sbc     a:$F8                           ; 90D0
        rti                                     ; 90D3

; ----------------------------------------------------------------------------
        sbc     $03F8                           ; 90D4
        sed                                     ; 90D7
        ora     ($ED,x)                         ; 90D8
        beq     L90DC                           ; 90DA
L90DC:  eor     ($ED,x)                         ; 90DC
        beq     L90DC                           ; 90DE
        ora     ($FD,x)                         ; 90E0
        brk                                     ; 90E2
        .byte   $03                             ; 90E3
        sed                                     ; 90E4
        ora     ($ED,x)                         ; 90E5
        beq     L90E9                           ; 90E7
L90E9:  eor     ($ED,x)                         ; 90E9
        beq     L90E9                           ; 90EB
        .byte   $41                             ; 90ED
L90EE:  sbc     $0300,x                         ; 90EE
        .byte   $FC                             ; 90F1
        sta     ($FD,x)                         ; 90F2
        beq     L90EE                           ; 90F4
        sta     ($ED,x)                         ; 90F6
        brk                                     ; 90F8
        brk                                     ; 90F9
        .byte   $C1                             ; 90FA
L90FB:  sbc     $0300                           ; 90FB
        .byte   $FC                             ; 90FE
        cmp     ($FD,x)                         ; 90FF
        beq     L90FB                           ; 9101
        sta     ($ED,x)                         ; 9103
        brk                                     ; 9105
        brk                                     ; 9106
        cmp     ($ED,x)                         ; 9107
        brk                                     ; 9109
        .byte   $02                             ; 910A
        sed                                     ; 910B
        brk                                     ; 910C
        .byte   $EF                             ; 910D
        sed                                     ; 910E
        brk                                     ; 910F
        rti                                     ; 9110

; ----------------------------------------------------------------------------
        .byte   $EF                             ; 9111
        sed                                     ; 9112
        .byte   $02                             ; 9113
        sed                                     ; 9114
        brk                                     ; 9115
        .byte   $FF                             ; 9116
        sed                                     ; 9117
        brk                                     ; 9118
        rti                                     ; 9119

; ----------------------------------------------------------------------------
        .byte   $FF                             ; 911A
        sed                                     ; 911B
        .byte   $02                             ; 911C
        sed                                     ; 911D
        brk                                     ; 911E
        .byte   $CF                             ; 911F
        sed                                     ; 9120
        brk                                     ; 9121
        rti                                     ; 9122

; ----------------------------------------------------------------------------
        .byte   $CF                             ; 9123
        sed                                     ; 9124
        .byte   $02                             ; 9125
        sed                                     ; 9126
        brk                                     ; 9127
        .byte   $DF                             ; 9128
        sed                                     ; 9129
        brk                                     ; 912A
        rti                                     ; 912B

; ----------------------------------------------------------------------------
        .byte   $DF                             ; 912C
        sed                                     ; 912D
        .byte   $02                             ; 912E
        sed                                     ; 912F
        ora     ($9D,x)                         ; 9130
        sed                                     ; 9132
        brk                                     ; 9133
        eor     ($9D,x)                         ; 9134
        sed                                     ; 9136
        .byte   $02                             ; 9137
        sed                                     ; 9138
        ora     ($8D,x)                         ; 9139
        sed                                     ; 913B
        brk                                     ; 913C
        eor     ($8D,x)                         ; 913D
        sed                                     ; 913F
        .byte   $02                             ; 9140
        sed                                     ; 9141
        ora     ($9F,x)                         ; 9142
        sed                                     ; 9144
        brk                                     ; 9145
        eor     ($9F,x)                         ; 9146
        sed                                     ; 9148
        .byte   $02                             ; 9149
        sed                                     ; 914A
        ora     ($8F,x)                         ; 914B
        sed                                     ; 914D
        brk                                     ; 914E
        eor     ($8F,x)                         ; 914F
        sed                                     ; 9151
        .byte   $04                             ; 9152
        sed                                     ; 9153
        brk                                     ; 9154
        .byte   $FB                             ; 9155
        inx                                     ; 9156
        brk                                     ; 9157
        rti                                     ; 9158

; ----------------------------------------------------------------------------
        .byte   $FB                             ; 9159
        inx                                     ; 915A
        sed                                     ; 915B
        brk                                     ; 915C
        .byte   $77                             ; 915D
        sed                                     ; 915E
        brk                                     ; 915F
        rti                                     ; 9160

; ----------------------------------------------------------------------------
        .byte   $77                             ; 9161
        sed                                     ; 9162
        asl     $F8                             ; 9163
        brk                                     ; 9165
        sbc     $D8,y                           ; 9166
        rti                                     ; 9169

; ----------------------------------------------------------------------------
        sbc     $F8D8,y                         ; 916A
        brk                                     ; 916D
        .byte   $FB                             ; 916E
        inx                                     ; 916F
        brk                                     ; 9170
        rti                                     ; 9171

; ----------------------------------------------------------------------------
        .byte   $FB                             ; 9172
        inx                                     ; 9173
        sed                                     ; 9174
        brk                                     ; 9175
        .byte   $77                             ; 9176
        sed                                     ; 9177
        brk                                     ; 9178
        rti                                     ; 9179

; ----------------------------------------------------------------------------
        .byte   $77                             ; 917A
        sed                                     ; 917B
        php                                     ; 917C
        sed                                     ; 917D
        brk                                     ; 917E
        .byte   $F7                             ; 917F
        iny                                     ; 9180
        brk                                     ; 9181
        rti                                     ; 9182

; ----------------------------------------------------------------------------
        .byte   $F7                             ; 9183
        iny                                     ; 9184
        sed                                     ; 9185
        brk                                     ; 9186
        sbc     $D8,y                           ; 9187
        rti                                     ; 918A

; ----------------------------------------------------------------------------
        sbc     $F8D8,y                         ; 918B
        brk                                     ; 918E
        .byte   $FB                             ; 918F
        inx                                     ; 9190
        brk                                     ; 9191
        rti                                     ; 9192

; ----------------------------------------------------------------------------
        .byte   $FB                             ; 9193
        inx                                     ; 9194
        sed                                     ; 9195
        brk                                     ; 9196
        .byte   $77                             ; 9197
        sed                                     ; 9198
        brk                                     ; 9199
        rti                                     ; 919A

; ----------------------------------------------------------------------------
        .byte   $77                             ; 919B
        sed                                     ; 919C
        asl     $F8                             ; 919D
        brk                                     ; 919F
        .byte   $F7                             ; 91A0
        iny                                     ; 91A1
        brk                                     ; 91A2
        rti                                     ; 91A3

; ----------------------------------------------------------------------------
        .byte   $F7                             ; 91A4
        iny                                     ; 91A5
        sed                                     ; 91A6
        brk                                     ; 91A7
        sbc     $D8,y                           ; 91A8
        rti                                     ; 91AB

; ----------------------------------------------------------------------------
        sbc     $F8D8,y                         ; 91AC
        brk                                     ; 91AF
        .byte   $77                             ; 91B0
        sed                                     ; 91B1
        brk                                     ; 91B2
        rti                                     ; 91B3

; ----------------------------------------------------------------------------
        .byte   $77                             ; 91B4
        sed                                     ; 91B5
        .byte   $04                             ; 91B6
        sed                                     ; 91B7
        brk                                     ; 91B8
        sbc     $D8,y                           ; 91B9
        rti                                     ; 91BC

; ----------------------------------------------------------------------------
        sbc     $F8D8,y                         ; 91BD
        brk                                     ; 91C0
        .byte   $77                             ; 91C1
        sed                                     ; 91C2
        brk                                     ; 91C3
        rti                                     ; 91C4

; ----------------------------------------------------------------------------
        .byte   $77                             ; 91C5
        sed                                     ; 91C6
        .byte   $FF                             ; 91C7
        .byte   $03                             ; 91C8
        sed                                     ; 91C9
        .byte   $80                             ; 91CA
        .byte   $83                             ; 91CB
        inx                                     ; 91CC
        brk                                     ; 91CD
        .byte   $80                             ; 91CE
        .byte   $93                             ; 91CF
        inx                                     ; 91D0
        brk                                     ; 91D1
        .byte   $80                             ; 91D2
        sta     $F8                             ; 91D3
        .byte   $FF                             ; 91D5
        .byte   $03                             ; 91D6
        brk                                     ; 91D7
        brk                                     ; 91D8
        sta     $E8                             ; 91D9
        sed                                     ; 91DB
        brk                                     ; 91DC
        sta     ($F8,x)                         ; 91DD
        brk                                     ; 91DF
        brk                                     ; 91E0
        sta     ($F8),y                         ; 91E1
        asl     $F8                             ; 91E3
        brk                                     ; 91E5
        sbc     ($E8,x)                         ; 91E6
        brk                                     ; 91E8
        rti                                     ; 91E9

; ----------------------------------------------------------------------------
        sbc     ($E8,x)                         ; 91EA
        beq     L91EE                           ; 91EC
L91EE:  cmp     $F8                             ; 91EE
        sed                                     ; 91F0
        brk                                     ; 91F1
        .byte   $E3                             ; 91F2
        sed                                     ; 91F3
        brk                                     ; 91F4
        rti                                     ; 91F5

; ----------------------------------------------------------------------------
        .byte   $E3                             ; 91F6
        sed                                     ; 91F7
        php                                     ; 91F8
        rti                                     ; 91F9

; ----------------------------------------------------------------------------
        cmp     $F8                             ; 91FA
        .byte   $FF                             ; 91FC
        asl     $F8                             ; 91FD
        brk                                     ; 91FF
        lda     $E8                             ; 9200
        brk                                     ; 9202
        brk                                     ; 9203
        lda     $E8,x                           ; 9204
        beq     L9208                           ; 9206
L9208:  .byte   $C7                             ; 9208
        sed                                     ; 9209
        sed                                     ; 920A
        brk                                     ; 920B
        .byte   $A7                             ; 920C
        sed                                     ; 920D
        brk                                     ; 920E
        brk                                     ; 920F
        .byte   $B7                             ; 9210
        sed                                     ; 9211
        php                                     ; 9212
        rti                                     ; 9213

; ----------------------------------------------------------------------------
        .byte   $C7                             ; 9214
        sed                                     ; 9215
        asl     $F8                             ; 9216
        brk                                     ; 9218
        sta     $E8,y                           ; 9219
        rti                                     ; 921C

; ----------------------------------------------------------------------------
        sta     $F0E8,y                         ; 921D
        brk                                     ; 9220
        cmp     $F8                             ; 9221
        sed                                     ; 9223
        brk                                     ; 9224
        .byte   $8B                             ; 9225
        sed                                     ; 9226
        brk                                     ; 9227
        rti                                     ; 9228

; ----------------------------------------------------------------------------
        .byte   $8B                             ; 9229
        sed                                     ; 922A
        php                                     ; 922B
        rti                                     ; 922C

; ----------------------------------------------------------------------------
        cmp     $F8                             ; 922D
        .byte   $FF                             ; 922F
        .byte   $04                             ; 9230
        sed                                     ; 9231
        brk                                     ; 9232
        lda     ($E8,x)                         ; 9233
        brk                                     ; 9235
        brk                                     ; 9236
        lda     ($E8),y                         ; 9237
        sed                                     ; 9239
        brk                                     ; 923A
        .byte   $A3                             ; 923B
        sed                                     ; 923C
        brk                                     ; 923D
        brk                                     ; 923E
        .byte   $B3                             ; 923F
        sed                                     ; 9240
        .byte   $04                             ; 9241
        sed                                     ; 9242
        brk                                     ; 9243
        cmp     ($E8,x)                         ; 9244
        brk                                     ; 9246
        brk                                     ; 9247
        cmp     ($E8),y                         ; 9248
        sed                                     ; 924A
        brk                                     ; 924B
        .byte   $C3                             ; 924C
        sed                                     ; 924D
        brk                                     ; 924E
        brk                                     ; 924F
        .byte   $D3                             ; 9250
        sed                                     ; 9251
        ora     ($FC,x)                         ; 9252
        brk                                     ; 9254
        sbc     ($F8),y                         ; 9255
        ora     ($FC,x)                         ; 9257
        brk                                     ; 9259
        .byte   $F3                             ; 925A
        sed                                     ; 925B
        .byte   $02                             ; 925C
        sed                                     ; 925D
        brk                                     ; 925E
        .byte   $8F                             ; 925F
        sed                                     ; 9260
        brk                                     ; 9261
        brk                                     ; 9262
        sta     $02F8                           ; 9263
        sed                                     ; 9266
        brk                                     ; 9267
        cmp     a:$F8                           ; 9268
        rti                                     ; 926B

; ----------------------------------------------------------------------------
        cmp     $02F8                           ; 926C
        sed                                     ; 926F
        brk                                     ; 9270
        sbc     a:$F8,x                         ; 9271
        rti                                     ; 9274

; ----------------------------------------------------------------------------
        sbc     $06F8,x                         ; 9275
        .byte   $F4                             ; 9278
        brk                                     ; 9279
        lda     #$E8                            ; 927A
        .byte   $FC                             ; 927C
        brk                                     ; 927D
        lda     $04E8,y                         ; 927E
        brk                                     ; 9281
        cmp     #$E8                            ; 9282
        .byte   $F4                             ; 9284
        brk                                     ; 9285
        .byte   $AB                             ; 9286
        sed                                     ; 9287
        .byte   $FC                             ; 9288
        brk                                     ; 9289
        .byte   $BB                             ; 928A
        sed                                     ; 928B
        .byte   $04                             ; 928C
        brk                                     ; 928D
        .byte   $CB                             ; 928E
        sed                                     ; 928F
        asl     $F4                             ; 9290
        brk                                     ; 9292
        cmp     $FCE8,y                         ; 9293
        brk                                     ; 9296
        sbc     #$E8                            ; 9297
        .byte   $04                             ; 9299
        brk                                     ; 929A
        sbc     $E8                             ; 929B
        .byte   $F4                             ; 929D
        brk                                     ; 929E
        .byte   $DB                             ; 929F
        sed                                     ; 92A0
        .byte   $FC                             ; 92A1
        brk                                     ; 92A2
        .byte   $EB                             ; 92A3
        sed                                     ; 92A4
        .byte   $04                             ; 92A5
        brk                                     ; 92A6
        .byte   $E7                             ; 92A7
        sed                                     ; 92A8
        php                                     ; 92A9
        sed                                     ; 92AA
        brk                                     ; 92AB
        lda     a:$D8                           ; 92AC
        brk                                     ; 92AF
        lda     $F4D8,x                         ; 92B0
        brk                                     ; 92B3
        .byte   $9F                             ; 92B4
        inx                                     ; 92B5
        .byte   $FC                             ; 92B6
        brk                                     ; 92B7
        .byte   $AF                             ; 92B8
        inx                                     ; 92B9
        .byte   $04                             ; 92BA
        brk                                     ; 92BB
        .byte   $BF                             ; 92BC
        inx                                     ; 92BD
        .byte   $F4                             ; 92BE
        brk                                     ; 92BF
        .byte   $AB                             ; 92C0
        sed                                     ; 92C1
        .byte   $FC                             ; 92C2
        brk                                     ; 92C3
        .byte   $BB                             ; 92C4
        sed                                     ; 92C5
        .byte   $04                             ; 92C6
        brk                                     ; 92C7
        .byte   $CB                             ; 92C8
        sed                                     ; 92C9
        ora     ($FC,x)                         ; 92CA
        ora     ($F5,x)                         ; 92CC
L92CE:  sed                                     ; 92CE
        .byte   $FF                             ; 92CF
        .byte   $04                             ; 92D0
        .byte   $FC                             ; 92D1
        brk                                     ; 92D2
        .byte   $87                             ; 92D3
        beq     L92DA                           ; 92D4
        brk                                     ; 92D6
        .byte   $97                             ; 92D7
        beq     L92CE                           ; 92D8
L92DA:  brk                                     ; 92DA
        sta     $00,x                           ; 92DB
        .byte   $FC                             ; 92DD
        brk                                     ; 92DE
L92DF:  .byte   $89                             ; 92DF
        brk                                     ; 92E0
        .byte   $04                             ; 92E1
        .byte   $FC                             ; 92E2
        cpy     #$89                            ; 92E3
        beq     L92EB                           ; 92E5
        cpy     #$95                            ; 92E7
        beq     L92DF                           ; 92E9
L92EB:  cpy     #$97                            ; 92EB
        brk                                     ; 92ED
        .byte   $FC                             ; 92EE
        cpy     #$87                            ; 92EF
        brk                                     ; 92F1
        .byte   $02                             ; 92F2
        sed                                     ; 92F3
        ora     ($EF,x)                         ; 92F4
        sed                                     ; 92F6
        brk                                     ; 92F7
        eor     ($EF,x)                         ; 92F8
        sed                                     ; 92FA
        .byte   $02                             ; 92FB
        sed                                     ; 92FC
        brk                                     ; 92FD
        .byte   $FF                             ; 92FE
        sed                                     ; 92FF
        brk                                     ; 9300
        rti                                     ; 9301

; ----------------------------------------------------------------------------
        .byte   $FF                             ; 9302
        sed                                     ; 9303
        .byte   $02                             ; 9304
        sed                                     ; 9305
        brk                                     ; 9306
        .byte   $CF                             ; 9307
        sed                                     ; 9308
        brk                                     ; 9309
        brk                                     ; 930A
        .byte   $DF                             ; 930B
        sed                                     ; 930C
        php                                     ; 930D
        .byte   $F4                             ; 930E
        brk                                     ; 930F
        .byte   $BB                             ; 9310
        cld                                     ; 9311
        .byte   $04                             ; 9312
        rti                                     ; 9313

; ----------------------------------------------------------------------------
        .byte   $BB                             ; 9314
        cld                                     ; 9315
        .byte   $F4                             ; 9316
        brk                                     ; 9317
        .byte   $A7                             ; 9318
        inx                                     ; 9319
        .byte   $FC                             ; 931A
        brk                                     ; 931B
        .byte   $B7                             ; 931C
        inx                                     ; 931D
        .byte   $04                             ; 931E
        rti                                     ; 931F

; ----------------------------------------------------------------------------
        .byte   $A7                             ; 9320
        inx                                     ; 9321
        .byte   $F4                             ; 9322
        brk                                     ; 9323
        lda     #$F8                            ; 9324
        .byte   $FC                             ; 9326
        brk                                     ; 9327
        lda     $04F8,y                         ; 9328
        rti                                     ; 932B

; ----------------------------------------------------------------------------
        lda     #$F8                            ; 932C
        php                                     ; 932E
        .byte   $F4                             ; 932F
        brk                                     ; 9330
        .byte   $AB                             ; 9331
        cld                                     ; 9332
        .byte   $04                             ; 9333
        rti                                     ; 9334

; ----------------------------------------------------------------------------
        .byte   $AB                             ; 9335
        cld                                     ; 9336
        .byte   $F4                             ; 9337
        brk                                     ; 9338
        lda     $FCE8                           ; 9339
        brk                                     ; 933C
        lda     $04E8,x                         ; 933D
        rti                                     ; 9340

; ----------------------------------------------------------------------------
        lda     $F4E8                           ; 9341
        brk                                     ; 9344
        .byte   $AF                             ; 9345
        sed                                     ; 9346
        .byte   $FC                             ; 9347
        brk                                     ; 9348
        .byte   $BF                             ; 9349
        sed                                     ; 934A
        .byte   $04                             ; 934B
        rti                                     ; 934C

; ----------------------------------------------------------------------------
        .byte   $AF                             ; 934D
        sed                                     ; 934E
        asl     $F4                             ; 934F
        brk                                     ; 9351
        cmp     #$E8                            ; 9352
        .byte   $FC                             ; 9354
        brk                                     ; 9355
        cmp     $04E8,y                         ; 9356
        rti                                     ; 9359

; ----------------------------------------------------------------------------
        cmp     #$E8                            ; 935A
        .byte   $F4                             ; 935C
        brk                                     ; 935D
        .byte   $CB                             ; 935E
        sed                                     ; 935F
        .byte   $FC                             ; 9360
        brk                                     ; 9361
        .byte   $DB                             ; 9362
        sed                                     ; 9363
        .byte   $04                             ; 9364
        rti                                     ; 9365

; ----------------------------------------------------------------------------
        .byte   $CB                             ; 9366
        sed                                     ; 9367
        .byte   $FF                             ; 9368
        asl     $F4                             ; 9369
        brk                                     ; 936B
        .byte   $B3                             ; 936C
        inx                                     ; 936D
        .byte   $FC                             ; 936E
        brk                                     ; 936F
        .byte   $C3                             ; 9370
        inx                                     ; 9371
        .byte   $04                             ; 9372
        rti                                     ; 9373

; ----------------------------------------------------------------------------
        .byte   $B3                             ; 9374
        inx                                     ; 9375
        .byte   $F4                             ; 9376
        brk                                     ; 9377
        lda     $F8,x                           ; 9378
        .byte   $FC                             ; 937A
        brk                                     ; 937B
        cmp     $F8                             ; 937C
        .byte   $04                             ; 937E
        rti                                     ; 937F

; ----------------------------------------------------------------------------
        lda     $F8,x                           ; 9380
        .byte   $FF                             ; 9382
        asl     $F4                             ; 9383
        brk                                     ; 9385
        sbc     $E8                             ; 9386
        .byte   $FC                             ; 9388
        brk                                     ; 9389
        .byte   $C7                             ; 938A
        inx                                     ; 938B
        .byte   $04                             ; 938C
        rti                                     ; 938D

; ----------------------------------------------------------------------------
        sbc     $E8                             ; 938E
        .byte   $F4                             ; 9390
        brk                                     ; 9391
        .byte   $E7                             ; 9392
        sed                                     ; 9393
        .byte   $FC                             ; 9394
        brk                                     ; 9395
        .byte   $D7                             ; 9396
        sed                                     ; 9397
        .byte   $04                             ; 9398
        rti                                     ; 9399

; ----------------------------------------------------------------------------
        .byte   $E7                             ; 939A
        sed                                     ; 939B
        .byte   $04                             ; 939C
        sed                                     ; 939D
        brk                                     ; 939E
        .byte   $A3                             ; 939F
        inx                                     ; 93A0
        brk                                     ; 93A1
        rti                                     ; 93A2

; ----------------------------------------------------------------------------
        .byte   $A3                             ; 93A3
        inx                                     ; 93A4
        sed                                     ; 93A5
        brk                                     ; 93A6
        lda     $F8                             ; 93A7
        brk                                     ; 93A9
        rti                                     ; 93AA

; ----------------------------------------------------------------------------
        lda     $F8                             ; 93AB
        .byte   $04                             ; 93AD
        sed                                     ; 93AE
        .byte   $80                             ; 93AF
        lda     $E8                             ; 93B0
        brk                                     ; 93B2
        cpy     #$A5                            ; 93B3
        inx                                     ; 93B5
        sed                                     ; 93B6
        .byte   $80                             ; 93B7
        .byte   $A3                             ; 93B8
        sed                                     ; 93B9
        brk                                     ; 93BA
        cpy     #$A3                            ; 93BB
        sed                                     ; 93BD
        .byte   $04                             ; 93BE
        sed                                     ; 93BF
        brk                                     ; 93C0
        .byte   $83                             ; 93C1
        inx                                     ; 93C2
        brk                                     ; 93C3
        rti                                     ; 93C4

; ----------------------------------------------------------------------------
        .byte   $83                             ; 93C5
        inx                                     ; 93C6
        sed                                     ; 93C7
        brk                                     ; 93C8
        lda     $F8                             ; 93C9
        brk                                     ; 93CB
        rti                                     ; 93CC

; ----------------------------------------------------------------------------
        lda     $F8                             ; 93CD
        .byte   $04                             ; 93CF
        sed                                     ; 93D0
        .byte   $80                             ; 93D1
        lda     $E8                             ; 93D2
        brk                                     ; 93D4
        cpy     #$A5                            ; 93D5
        inx                                     ; 93D7
        sed                                     ; 93D8
        .byte   $80                             ; 93D9
        .byte   $83                             ; 93DA
        sed                                     ; 93DB
        brk                                     ; 93DC
        cpy     #$83                            ; 93DD
        sed                                     ; 93DF
        .byte   $04                             ; 93E0
        sed                                     ; 93E1
        brk                                     ; 93E2
        .byte   $93                             ; 93E3
        inx                                     ; 93E4
        brk                                     ; 93E5
        rti                                     ; 93E6

; ----------------------------------------------------------------------------
        .byte   $93                             ; 93E7
        inx                                     ; 93E8
        sed                                     ; 93E9
        brk                                     ; 93EA
        lda     $F8                             ; 93EB
        brk                                     ; 93ED
        rti                                     ; 93EE

; ----------------------------------------------------------------------------
        lda     $F8                             ; 93EF
        .byte   $04                             ; 93F1
        sed                                     ; 93F2
        .byte   $80                             ; 93F3
        lda     $E8                             ; 93F4
        brk                                     ; 93F6
        cpy     #$A5                            ; 93F7
        inx                                     ; 93F9
        sed                                     ; 93FA
        .byte   $80                             ; 93FB
        .byte   $93                             ; 93FC
        sed                                     ; 93FD
        brk                                     ; 93FE
        cpy     #$93                            ; 93FF
        sed                                     ; 9401
        .byte   $FF                             ; 9402
        .byte   $07                             ; 9403
        .byte   $F4                             ; 9404
        ora     ($81,x)                         ; 9405
        cld                                     ; 9407
        .byte   $F4                             ; 9408
        ora     ($91,x)                         ; 9409
        inx                                     ; 940B
        .byte   $FC                             ; 940C
        ora     ($A1,x)                         ; 940D
        inx                                     ; 940F
        .byte   $04                             ; 9410
        eor     ($B1,x)                         ; 9411
        inx                                     ; 9413
        .byte   $F4                             ; 9414
        ora     ($C1,x)                         ; 9415
        sed                                     ; 9417
        .byte   $FC                             ; 9418
        ora     ($D1,x)                         ; 9419
        sed                                     ; 941B
        .byte   $04                             ; 941C
        ora     ($E1,x)                         ; 941D
        sed                                     ; 941F
        .byte   $FF                             ; 9420
        .byte   $04                             ; 9421
        sed                                     ; 9422
        brk                                     ; 9423
        .byte   $D3                             ; 9424
        inx                                     ; 9425
        brk                                     ; 9426
        brk                                     ; 9427
        .byte   $F3                             ; 9428
L9429:  inx                                     ; 9429
        sed                                     ; 942A
        brk                                     ; 942B
        cmp     $F8,x                           ; 942C
        brk                                     ; 942E
        brk                                     ; 942F
        .byte   $F5                             ; 9430
L9431:  sed                                     ; 9431
        ora     ($FC,x)                         ; 9432
        ora     ($F1,x)                         ; 9434
        sed                                     ; 9436
        .byte   $FF                             ; 9437
        php                                     ; 9438
        beq     L943B                           ; 9439
L943B:  .byte   $80                             ; 943B
        inx                                     ; 943C
        sed                                     ; 943D
        brk                                     ; 943E
        bcc     L9429                           ; 943F
        brk                                     ; 9441
        brk                                     ; 9442
        ldy     #$E8                            ; 9443
        php                                     ; 9445
        brk                                     ; 9446
        bcs     L9431                           ; 9447
        beq     L944B                           ; 9449
L944B:  .byte   $82                             ; 944B
        sed                                     ; 944C
        sed                                     ; 944D
        brk                                     ; 944E
        .byte   $92                             ; 944F
        sed                                     ; 9450
        brk                                     ; 9451
        brk                                     ; 9452
        ldx     #$F8                            ; 9453
        php                                     ; 9455
        brk                                     ; 9456
        .byte   $B2                             ; 9457
        sed                                     ; 9458
        .byte   $04                             ; 9459
        sed                                     ; 945A
        brk                                     ; 945B
        lda     $E8                             ; 945C
        brk                                     ; 945E
        rti                                     ; 945F

; ----------------------------------------------------------------------------
        lda     $E8                             ; 9460
        sed                                     ; 9462
        brk                                     ; 9463
        .byte   $A3                             ; 9464
        sed                                     ; 9465
        brk                                     ; 9466
        rti                                     ; 9467

; ----------------------------------------------------------------------------
        .byte   $A3                             ; 9468
        sed                                     ; 9469
        .byte   $04                             ; 946A
        sed                                     ; 946B
        brk                                     ; 946C
        lda     ($E8),y                         ; 946D
        brk                                     ; 946F
        rti                                     ; 9470

; ----------------------------------------------------------------------------
        lda     ($E8),y                         ; 9471
        sed                                     ; 9473
        brk                                     ; 9474
        .byte   $B3                             ; 9475
        sed                                     ; 9476
        brk                                     ; 9477
        rti                                     ; 9478

; ----------------------------------------------------------------------------
        .byte   $B3                             ; 9479
        sed                                     ; 947A
        asl     $F8                             ; 947B
        brk                                     ; 947D
        lda     #$E8                            ; 947E
        brk                                     ; 9480
        rti                                     ; 9481

; ----------------------------------------------------------------------------
        tay                                     ; 9482
        inx                                     ; 9483
L9484:  beq     L9486                           ; 9484
L9486:  .byte   $AB                             ; 9486
        sed                                     ; 9487
        sed                                     ; 9488
        brk                                     ; 9489
        lda     a:$F8                           ; 948A
        rti                                     ; 948D

; ----------------------------------------------------------------------------
        lda     $08F8                           ; 948E
        rti                                     ; 9491

; ----------------------------------------------------------------------------
        .byte   $AB                             ; 9492
        sed                                     ; 9493
        asl     $F8                             ; 9494
        brk                                     ; 9496
        lda     $E8,y                           ; 9497
        rti                                     ; 949A

; ----------------------------------------------------------------------------
        lda     $F0E8,y                         ; 949B
        brk                                     ; 949E
        .byte   $AB                             ; 949F
        sed                                     ; 94A0
        sed                                     ; 94A1
        brk                                     ; 94A2
        .byte   $BB                             ; 94A3
        sed                                     ; 94A4
        brk                                     ; 94A5
        rti                                     ; 94A6

; ----------------------------------------------------------------------------
        .byte   $BB                             ; 94A7
        sed                                     ; 94A8
        php                                     ; 94A9
        rti                                     ; 94AA

; ----------------------------------------------------------------------------
        .byte   $AB                             ; 94AB
        sed                                     ; 94AC
        ora     ($FC,x)                         ; 94AD
        brk                                     ; 94AF
        sbc     $F8,x                           ; 94B0
        asl     $F8                             ; 94B2
        brk                                     ; 94B4
        lda     #$E8                            ; 94B5
        brk                                     ; 94B7
        rti                                     ; 94B8

; ----------------------------------------------------------------------------
        lda     #$E8                            ; 94B9
        beq     L94BD                           ; 94BB
L94BD:  .byte   $DB                             ; 94BD
        sed                                     ; 94BE
        sed                                     ; 94BF
        brk                                     ; 94C0
        .byte   $EB                             ; 94C1
        sed                                     ; 94C2
        brk                                     ; 94C3
        rti                                     ; 94C4

; ----------------------------------------------------------------------------
        .byte   $EB                             ; 94C5
        sed                                     ; 94C6
        php                                     ; 94C7
        rti                                     ; 94C8

; ----------------------------------------------------------------------------
        .byte   $DB                             ; 94C9
        sed                                     ; 94CA
        .byte   $04                             ; 94CB
        sed                                     ; 94CC
        brk                                     ; 94CD
        lda     #$E8                            ; 94CE
        brk                                     ; 94D0
        rti                                     ; 94D1

; ----------------------------------------------------------------------------
        lda     #$E8                            ; 94D2
        sed                                     ; 94D4
        brk                                     ; 94D5
        .byte   $BF                             ; 94D6
        sed                                     ; 94D7
        brk                                     ; 94D8
        rti                                     ; 94D9

; ----------------------------------------------------------------------------
        .byte   $BF                             ; 94DA
        sed                                     ; 94DB
        .byte   $04                             ; 94DC
        sed                                     ; 94DD
        brk                                     ; 94DE
        lda     $E8,y                           ; 94DF
        rti                                     ; 94E2

; ----------------------------------------------------------------------------
        lda     $F8E8,y                         ; 94E3
        brk                                     ; 94E6
        .byte   $BF                             ; 94E7
        sed                                     ; 94E8
        brk                                     ; 94E9
        rti                                     ; 94EA

; ----------------------------------------------------------------------------
        .byte   $BF                             ; 94EB
        sed                                     ; 94EC
        .byte   $02                             ; 94ED
        sed                                     ; 94EE
        brk                                     ; 94EF
        lda     #$F8                            ; 94F0
        brk                                     ; 94F2
        rti                                     ; 94F3

; ----------------------------------------------------------------------------
        lda     #$F8                            ; 94F4
        .byte   $04                             ; 94F6
        sed                                     ; 94F7
        brk                                     ; 94F8
        lda     $F3,y                           ; 94F9
        rti                                     ; 94FC

; ----------------------------------------------------------------------------
        lda     $F8F3,y                         ; 94FD
        brk                                     ; 9500
        .byte   $BF                             ; 9501
        .byte   $03                             ; 9502
        brk                                     ; 9503
        rti                                     ; 9504

; ----------------------------------------------------------------------------
        .byte   $BF                             ; 9505
        .byte   $03                             ; 9506
        ora     #$F8                            ; 9507
        brk                                     ; 9509
        lda     $D8,y                           ; 950A
        rti                                     ; 950D

; ----------------------------------------------------------------------------
        lda     $F0D8,y                         ; 950E
        brk                                     ; 9511
        .byte   $AB                             ; 9512
        inx                                     ; 9513
        sed                                     ; 9514
        brk                                     ; 9515
        .byte   $BB                             ; 9516
        inx                                     ; 9517
        brk                                     ; 9518
        rti                                     ; 9519

; ----------------------------------------------------------------------------
        .byte   $BB                             ; 951A
        inx                                     ; 951B
        php                                     ; 951C
        rti                                     ; 951D

; ----------------------------------------------------------------------------
        .byte   $AB                             ; 951E
        inx                                     ; 951F
        .byte   $F4                             ; 9520
        brk                                     ; 9521
        lda     $FCF8                           ; 9522
        brk                                     ; 9525
        lda     $04F8,x                         ; 9526
        rti                                     ; 9529

; ----------------------------------------------------------------------------
        lda     $04F8                           ; 952A
        sed                                     ; 952D
        brk                                     ; 952E
        .byte   $87                             ; 952F
        inx                                     ; 9530
        brk                                     ; 9531
        rti                                     ; 9532

; ----------------------------------------------------------------------------
        .byte   $87                             ; 9533
        inx                                     ; 9534
        sed                                     ; 9535
        brk                                     ; 9536
        .byte   $89                             ; 9537
        sed                                     ; 9538
        brk                                     ; 9539
        brk                                     ; 953A
        sta     $04F8,y                         ; 953B
        sed                                     ; 953E
        brk                                     ; 953F
        .byte   $87                             ; 9540
        inx                                     ; 9541
        brk                                     ; 9542
        rti                                     ; 9543

; ----------------------------------------------------------------------------
        .byte   $87                             ; 9544
        inx                                     ; 9545
        sed                                     ; 9546
        rti                                     ; 9547

; ----------------------------------------------------------------------------
        sta     $F8,y                           ; 9548
        rti                                     ; 954B

; ----------------------------------------------------------------------------
        .byte   $89                             ; 954C
        sed                                     ; 954D
        .byte   $04                             ; 954E
        sed                                     ; 954F
        brk                                     ; 9550
        .byte   $97                             ; 9551
        inx                                     ; 9552
        brk                                     ; 9553
        rti                                     ; 9554

; ----------------------------------------------------------------------------
        .byte   $97                             ; 9555
        inx                                     ; 9556
        sed                                     ; 9557
        brk                                     ; 9558
        sta     $F8                             ; 9559
        brk                                     ; 955B
        brk                                     ; 955C
        sta     $F8,x                           ; 955D
        .byte   $04                             ; 955F
        sed                                     ; 9560
        brk                                     ; 9561
        .byte   $97                             ; 9562
        inx                                     ; 9563
        brk                                     ; 9564
        rti                                     ; 9565

; ----------------------------------------------------------------------------
        .byte   $97                             ; 9566
        inx                                     ; 9567
        sed                                     ; 9568
        rti                                     ; 9569

; ----------------------------------------------------------------------------
        sta     $F8,x                           ; 956A
        brk                                     ; 956C
        rti                                     ; 956D

; ----------------------------------------------------------------------------
        sta     $F8                             ; 956E
        .byte   $FF                             ; 9570
        .byte   $04                             ; 9571
        sed                                     ; 9572
        brk                                     ; 9573
        .byte   $8B                             ; 9574
        inx                                     ; 9575
        brk                                     ; 9576
        brk                                     ; 9577
        .byte   $9B                             ; 9578
        inx                                     ; 9579
        sed                                     ; 957A
        brk                                     ; 957B
        .byte   $8F                             ; 957C
        sed                                     ; 957D
        brk                                     ; 957E
        brk                                     ; 957F
        .byte   $9F                             ; 9580
        sed                                     ; 9581
        .byte   $FF                             ; 9582
        .byte   $04                             ; 9583
        sed                                     ; 9584
        brk                                     ; 9585
        .byte   $8B                             ; 9586
        inx                                     ; 9587
        brk                                     ; 9588
        brk                                     ; 9589
        .byte   $9B                             ; 958A
        inx                                     ; 958B
        sed                                     ; 958C
        brk                                     ; 958D
        sta     a:$F8                           ; 958E
        brk                                     ; 9591
        sta     $FFF8,x                         ; 9592
        .byte   $02                             ; 9595
        sed                                     ; 9596
        brk                                     ; 9597
        .byte   $8B                             ; 9598
        sed                                     ; 9599
        brk                                     ; 959A
        brk                                     ; 959B
        .byte   $9B                             ; 959C
        sed                                     ; 959D
        ora     ($FC,x)                         ; 959E
        brk                                     ; 95A0
        sbc     $F8,x                           ; 95A1
        .byte   $02                             ; 95A3
        sed                                     ; 95A4
        brk                                     ; 95A5
        .byte   $AF                             ; 95A6
        sed                                     ; 95A7
        brk                                     ; 95A8
        rti                                     ; 95A9

; ----------------------------------------------------------------------------
        .byte   $AF                             ; 95AA
        sed                                     ; 95AB
        .byte   $02                             ; 95AC
        sed                                     ; 95AD
        brk                                     ; 95AE
        .byte   $BF                             ; 95AF
        sed                                     ; 95B0
        brk                                     ; 95B1
        rti                                     ; 95B2

; ----------------------------------------------------------------------------
        .byte   $BF                             ; 95B3
        sed                                     ; 95B4
        .byte   $02                             ; 95B5
        sed                                     ; 95B6
        brk                                     ; 95B7
        lda     a:$F8                           ; 95B8
        rti                                     ; 95BB

; ----------------------------------------------------------------------------
        lda     $02F8                           ; 95BC
        sed                                     ; 95BF
        brk                                     ; 95C0
        lda     a:$F8,x                         ; 95C1
        rti                                     ; 95C4

; ----------------------------------------------------------------------------
        lda     $04F8,x                         ; 95C5
        sed                                     ; 95C8
        brk                                     ; 95C9
        .byte   $A3                             ; 95CA
        inx                                     ; 95CB
        brk                                     ; 95CC
        rti                                     ; 95CD

; ----------------------------------------------------------------------------
        .byte   $A3                             ; 95CE
        inx                                     ; 95CF
        sed                                     ; 95D0
        brk                                     ; 95D1
        lda     $F8                             ; 95D2
        brk                                     ; 95D4
        brk                                     ; 95D5
        lda     $F8,x                           ; 95D6
        .byte   $04                             ; 95D8
        sed                                     ; 95D9
        brk                                     ; 95DA
        .byte   $A3                             ; 95DB
        inx                                     ; 95DC
        brk                                     ; 95DD
        rti                                     ; 95DE

; ----------------------------------------------------------------------------
        .byte   $A3                             ; 95DF
        inx                                     ; 95E0
        sed                                     ; 95E1
        rti                                     ; 95E2

; ----------------------------------------------------------------------------
        lda     $F8,x                           ; 95E3
        brk                                     ; 95E5
        rti                                     ; 95E6

; ----------------------------------------------------------------------------
        lda     $F8                             ; 95E7
        .byte   $04                             ; 95E9
        sed                                     ; 95EA
        brk                                     ; 95EB
        sbc     ($E8,x)                         ; 95EC
        brk                                     ; 95EE
        rti                                     ; 95EF

; ----------------------------------------------------------------------------
        sbc     ($E8,x)                         ; 95F0
        sed                                     ; 95F2
        brk                                     ; 95F3
        .byte   $E3                             ; 95F4
        sed                                     ; 95F5
        brk                                     ; 95F6
        brk                                     ; 95F7
        sbc     $F8                             ; 95F8
        .byte   $04                             ; 95FA
        sed                                     ; 95FB
        brk                                     ; 95FC
        sbc     ($E8,x)                         ; 95FD
        brk                                     ; 95FF
        rti                                     ; 9600

; ----------------------------------------------------------------------------
        sbc     ($E8,x)                         ; 9601
        sed                                     ; 9603
        rti                                     ; 9604

; ----------------------------------------------------------------------------
        sbc     $F8                             ; 9605
        brk                                     ; 9607
        rti                                     ; 9608

; ----------------------------------------------------------------------------
        .byte   $E3                             ; 9609
        sed                                     ; 960A
        .byte   $FF                             ; 960B
        ora     $F4                             ; 960C
        brk                                     ; 960E
        .byte   $E7                             ; 960F
        cpx     #$FC                            ; 9610
        brk                                     ; 9612
        sta     ($E8),y                         ; 9613
        .byte   $F4                             ; 9615
        brk                                     ; 9616
        sta     ($F0,x)                         ; 9617
        .byte   $FC                             ; 9619
        brk                                     ; 961A
        .byte   $83                             ; 961B
        sed                                     ; 961C
        .byte   $04                             ; 961D
        brk                                     ; 961E
        .byte   $93                             ; 961F
        sed                                     ; 9620
        .byte   $FF                             ; 9621
        ora     $F4                             ; 9622
        brk                                     ; 9624
        .byte   $E7                             ; 9625
        cpx     #$FC                            ; 9626
        brk                                     ; 9628
        sta     ($E8),y                         ; 9629
        .byte   $F4                             ; 962B
        brk                                     ; 962C
        sta     ($F0,x)                         ; 962D
        .byte   $FC                             ; 962F
        brk                                     ; 9630
        lda     ($F8,x)                         ; 9631
        .byte   $04                             ; 9633
        brk                                     ; 9634
        lda     ($F8),y                         ; 9635
        .byte   $FF                             ; 9637
        ora     $F4                             ; 9638
        brk                                     ; 963A
        .byte   $E7                             ; 963B
        cpx     #$FC                            ; 963C
        brk                                     ; 963E
        sta     ($E8),y                         ; 963F
        .byte   $F4                             ; 9641
L9642:  brk                                     ; 9642
        .byte   $B7                             ; 9643
        beq     L9642                           ; 9644
        brk                                     ; 9646
        .byte   $83                             ; 9647
        sed                                     ; 9648
        .byte   $04                             ; 9649
        brk                                     ; 964A
        .byte   $93                             ; 964B
        sed                                     ; 964C
        .byte   $FF                             ; 964D
        ora     $F4                             ; 964E
        brk                                     ; 9650
        .byte   $E7                             ; 9651
        cpx     #$FC                            ; 9652
        brk                                     ; 9654
        sta     ($E8),y                         ; 9655
        .byte   $F4                             ; 9657
L9658:  brk                                     ; 9658
        .byte   $B7                             ; 9659
        beq     L9658                           ; 965A
        brk                                     ; 965C
        lda     ($F8,x)                         ; 965D
        .byte   $04                             ; 965F
        brk                                     ; 9660
        lda     ($F8),y                         ; 9661
        .byte   $FF                             ; 9663
        .byte   $04                             ; 9664
        sed                                     ; 9665
        brk                                     ; 9666
        sbc     ($E8,x)                         ; 9667
        brk                                     ; 9669
        rti                                     ; 966A

; ----------------------------------------------------------------------------
        sbc     ($E8,x)                         ; 966B
        sed                                     ; 966D
        brk                                     ; 966E
        .byte   $E3                             ; 966F
        sed                                     ; 9670
        brk                                     ; 9671
        brk                                     ; 9672
        sbc     $F8                             ; 9673
        .byte   $FF                             ; 9675
        .byte   $04                             ; 9676
        sed                                     ; 9677
        brk                                     ; 9678
        .byte   $B3                             ; 9679
        inx                                     ; 967A
        brk                                     ; 967B
        rti                                     ; 967C

; ----------------------------------------------------------------------------
        .byte   $B3                             ; 967D
        inx                                     ; 967E
        sed                                     ; 967F
        brk                                     ; 9680
        lda     $F8                             ; 9681
        brk                                     ; 9683
        brk                                     ; 9684
        lda     $F8,x                           ; 9685
        ora     ($FC,x)                         ; 9687
        ora     ($F5,x)                         ; 9689
        sed                                     ; 968B
        asl     $F4                             ; 968C
        brk                                     ; 968E
        sta     $E8                             ; 968F
        .byte   $FC                             ; 9691
        brk                                     ; 9692
        sta     $E8,x                           ; 9693
        .byte   $04                             ; 9695
        brk                                     ; 9696
        .byte   $8F                             ; 9697
        inx                                     ; 9698
        .byte   $F4                             ; 9699
        brk                                     ; 969A
        .byte   $87                             ; 969B
        sed                                     ; 969C
        .byte   $FC                             ; 969D
        brk                                     ; 969E
        .byte   $97                             ; 969F
        sed                                     ; 96A0
        .byte   $04                             ; 96A1
        brk                                     ; 96A2
        sta     $06F8,x                         ; 96A3
        .byte   $F4                             ; 96A6
        brk                                     ; 96A7
        sta     $E8                             ; 96A8
        .byte   $FC                             ; 96AA
        brk                                     ; 96AB
        sta     $E8,x                           ; 96AC
        .byte   $04                             ; 96AE
        brk                                     ; 96AF
        .byte   $9B                             ; 96B0
        inx                                     ; 96B1
        .byte   $F4                             ; 96B2
        brk                                     ; 96B3
        .byte   $89                             ; 96B4
        sed                                     ; 96B5
        .byte   $FC                             ; 96B6
        brk                                     ; 96B7
        sta     $04F8,y                         ; 96B8
        brk                                     ; 96BB
        sta     $06F8                           ; 96BC
        .byte   $F4                             ; 96BF
        brk                                     ; 96C0
        sta     $E8                             ; 96C1
        .byte   $FC                             ; 96C3
        brk                                     ; 96C4
        sta     $E8,x                           ; 96C5
        .byte   $04                             ; 96C7
        brk                                     ; 96C8
        .byte   $9B                             ; 96C9
        inx                                     ; 96CA
        .byte   $F4                             ; 96CB
        brk                                     ; 96CC
        .byte   $87                             ; 96CD
        sed                                     ; 96CE
        .byte   $FC                             ; 96CF
        brk                                     ; 96D0
        .byte   $97                             ; 96D1
        sed                                     ; 96D2
        .byte   $04                             ; 96D3
        brk                                     ; 96D4
        sta     $01F8,x                         ; 96D5
        .byte   $FC                             ; 96D8
        brk                                     ; 96D9
        .byte   $9F                             ; 96DA
        sed                                     ; 96DB
        ora     ($FC,x)                         ; 96DC
        rti                                     ; 96DE

; ----------------------------------------------------------------------------
        .byte   $9F                             ; 96DF
        sed                                     ; 96E0
        .byte   $FF                             ; 96E1
        .byte   $02                             ; 96E2
        sed                                     ; 96E3
        brk                                     ; 96E4
        sta     ($F8,x)                         ; 96E5
        brk                                     ; 96E7
        brk                                     ; 96E8
        sta     ($F8),y                         ; 96E9
        .byte   $FF                             ; 96EB
        .byte   $02                             ; 96EC
        sed                                     ; 96ED
        brk                                     ; 96EE
        sta     ($F8,x)                         ; 96EF
        brk                                     ; 96F1
        brk                                     ; 96F2
        lda     ($F8,x)                         ; 96F3
        .byte   $FF                             ; 96F5
        .byte   $04                             ; 96F6
        beq     L96F9                           ; 96F7
L96F9:  .byte   $D7                             ; 96F9
        sed                                     ; 96FA
        sed                                     ; 96FB
        brk                                     ; 96FC
        .byte   $E7                             ; 96FD
        sed                                     ; 96FE
        brk                                     ; 96FF
        brk                                     ; 9700
        .byte   $83                             ; 9701
        sed                                     ; 9702
        php                                     ; 9703
        brk                                     ; 9704
        .byte   $93                             ; 9705
        sed                                     ; 9706
        .byte   $FF                             ; 9707
        .byte   $04                             ; 9708
        beq     L970B                           ; 9709
L970B:  .byte   $D7                             ; 970B
        sed                                     ; 970C
        sed                                     ; 970D
        brk                                     ; 970E
        .byte   $E7                             ; 970F
        sed                                     ; 9710
        brk                                     ; 9711
        brk                                     ; 9712
        cmp     $F8,x                           ; 9713
        php                                     ; 9715
        brk                                     ; 9716
        sbc     $F8                             ; 9717
        .byte   $FF                             ; 9719
        .byte   $04                             ; 971A
        beq     L971D                           ; 971B
L971D:  sbc     #$F8                            ; 971D
        sed                                     ; 971F
        brk                                     ; 9720
        .byte   $E7                             ; 9721
        sed                                     ; 9722
        brk                                     ; 9723
        brk                                     ; 9724
        cmp     $F8,x                           ; 9725
        php                                     ; 9727
        brk                                     ; 9728
        sbc     $F8                             ; 9729
        ora     a:$F4                           ; 972B
        lda     $FCE8,y                         ; 972E
        brk                                     ; 9731
        .byte   $A7                             ; 9732
        inx                                     ; 9733
        .byte   $04                             ; 9734
        brk                                     ; 9735
        .byte   $B7                             ; 9736
        inx                                     ; 9737
        cpx     $BD00                           ; 9738
        sed                                     ; 973B
        .byte   $F4                             ; 973C
        brk                                     ; 973D
        .byte   $C3                             ; 973E
        sed                                     ; 973F
        .byte   $FC                             ; 9740
        brk                                     ; 9741
        .byte   $A3                             ; 9742
        sed                                     ; 9743
        .byte   $04                             ; 9744
        brk                                     ; 9745
        .byte   $B3                             ; 9746
        sed                                     ; 9747
        .byte   $0C                             ; 9748
        brk                                     ; 9749
        lda     ($F8,x)                         ; 974A
        cpx     $B100                           ; 974C
        php                                     ; 974F
        .byte   $F4                             ; 9750
        brk                                     ; 9751
        lda     ($08),y                         ; 9752
        .byte   $FC                             ; 9754
        brk                                     ; 9755
        lda     ($08),y                         ; 9756
        .byte   $04                             ; 9758
        brk                                     ; 9759
        lda     ($08),y                         ; 975A
        .byte   $0C                             ; 975C
        brk                                     ; 975D
        lda     ($08),y                         ; 975E
        .byte   $03                             ; 9760
        .byte   $F4                             ; 9761
        ora     ($81,x)                         ; 9762
        sed                                     ; 9764
        .byte   $FC                             ; 9765
        ora     ($91,x)                         ; 9766
        sed                                     ; 9768
        .byte   $04                             ; 9769
        eor     ($81,x)                         ; 976A
        sed                                     ; 976C
        ora     ($FC,x)                         ; 976D
        ora     ($24,x)                         ; 976F
        sed                                     ; 9771
        .byte   $FF                             ; 9772
        .byte   $12                             ; 9773
        beq     L9776                           ; 9774
L9776:  cld                                     ; 9776
        iny                                     ; 9777
        sed                                     ; 9778
        brk                                     ; 9779
        inx                                     ; 977A
        iny                                     ; 977B
        brk                                     ; 977C
        brk                                     ; 977D
        sed                                     ; 977E
        iny                                     ; 977F
        inx                                     ; 9780
        brk                                     ; 9781
        dex                                     ; 9782
        cld                                     ; 9783
        beq     L9786                           ; 9784
L9786:  .byte   $DA                             ; 9786
        cld                                     ; 9787
        sed                                     ; 9788
        brk                                     ; 9789
        nop                                     ; 978A
        cld                                     ; 978B
        brk                                     ; 978C
        brk                                     ; 978D
        .byte   $FA                             ; 978E
        cld                                     ; 978F
        php                                     ; 9790
        brk                                     ; 9791
        cpy     $D8                             ; 9792
        bpl     L9796                           ; 9794
L9796:  .byte   $D4                             ; 9796
        cld                                     ; 9797
        inx                                     ; 9798
        brk                                     ; 9799
        cpy     $F0E8                           ; 979A
        brk                                     ; 979D
        inc     $E8                             ; 979E
        sed                                     ; 97A0
        brk                                     ; 97A1
        cpx     a:$E8                           ; 97A2
        brk                                     ; 97A5
        .byte   $FC                             ; 97A6
        inx                                     ; 97A7
        php                                     ; 97A8
        brk                                     ; 97A9
        cpx     $E8                             ; 97AA
        bpl     L97AE                           ; 97AC
L97AE:  .byte   $F4                             ; 97AE
        inx                                     ; 97AF
        sed                                     ; 97B0
        brk                                     ; 97B1
        asl     a:$F8                           ; 97B2
        brk                                     ; 97B5
        asl     $08F8,x                         ; 97B6
        brk                                     ; 97B9
        inc     $F8,x                           ; 97BA
        .byte   $FF                             ; 97BC
        .byte   $13                             ; 97BD
        beq     L97C0                           ; 97BE
L97C0:  cld                                     ; 97C0
        iny                                     ; 97C1
        sed                                     ; 97C2
        brk                                     ; 97C3
        inx                                     ; 97C4
        iny                                     ; 97C5
        brk                                     ; 97C6
        brk                                     ; 97C7
        sed                                     ; 97C8
        iny                                     ; 97C9
        inx                                     ; 97CA
        brk                                     ; 97CB
        iny                                     ; 97CC
        cld                                     ; 97CD
        beq     L97D0                           ; 97CE
L97D0:  .byte   $DA                             ; 97D0
        cld                                     ; 97D1
        sed                                     ; 97D2
        brk                                     ; 97D3
        nop                                     ; 97D4
        cld                                     ; 97D5
        brk                                     ; 97D6
        brk                                     ; 97D7
        .byte   $FA                             ; 97D8
        cld                                     ; 97D9
        php                                     ; 97DA
        brk                                     ; 97DB
        cpy     $D8                             ; 97DC
        bpl     L97E0                           ; 97DE
L97E0:  .byte   $D4                             ; 97E0
        cld                                     ; 97E1
        inx                                     ; 97E2
        brk                                     ; 97E3
        dec     $E8                             ; 97E4
        beq     L97E8                           ; 97E6
L97E8:  dec     $E8,x                           ; 97E8
        sed                                     ; 97EA
        brk                                     ; 97EB
        cpx     a:$E8                           ; 97EC
        brk                                     ; 97EF
        .byte   $FC                             ; 97F0
        inx                                     ; 97F1
        php                                     ; 97F2
        brk                                     ; 97F3
        cpx     $E8                             ; 97F4
        bpl     L97F8                           ; 97F6
L97F8:  .byte   $F4                             ; 97F8
        inx                                     ; 97F9
        beq     L97FC                           ; 97FA
L97FC:  .byte   $D2                             ; 97FC
        sed                                     ; 97FD
L97FE:  sed                                     ; 97FE
        brk                                     ; 97FF
        .byte   $E2                             ; 9800
        sed                                     ; 9801
        brk                                     ; 9802
        brk                                     ; 9803
        beq     L97FE                           ; 9804
        php                                     ; 9806
        brk                                     ; 9807
        .byte   $F2                             ; 9808
        sed                                     ; 9809
        .byte   $FF                             ; 980A
        .byte   $13                             ; 980B
        beq     L980E                           ; 980C
L980E:  cld                                     ; 980E
        iny                                     ; 980F
        sed                                     ; 9810
        brk                                     ; 9811
        inx                                     ; 9812
        iny                                     ; 9813
        brk                                     ; 9814
        brk                                     ; 9815
        sed                                     ; 9816
        iny                                     ; 9817
        inx                                     ; 9818
        brk                                     ; 9819
        dex                                     ; 981A
        cld                                     ; 981B
        beq     L981E                           ; 981C
L981E:  .byte   $DA                             ; 981E
        cld                                     ; 981F
        sed                                     ; 9820
        brk                                     ; 9821
        nop                                     ; 9822
        cld                                     ; 9823
        brk                                     ; 9824
        brk                                     ; 9825
        .byte   $FA                             ; 9826
        cld                                     ; 9827
        php                                     ; 9828
        brk                                     ; 9829
        cpy     $D8                             ; 982A
        bpl     L982E                           ; 982C
L982E:  .byte   $D4                             ; 982E
        cld                                     ; 982F
        inx                                     ; 9830
        brk                                     ; 9831
        cpy     $F0E8                           ; 9832
        brk                                     ; 9835
        .byte   $DC                             ; 9836
        inx                                     ; 9837
        sed                                     ; 9838
        brk                                     ; 9839
        cpx     a:$E8                           ; 983A
        brk                                     ; 983D
        .byte   $FC                             ; 983E
        inx                                     ; 983F
        php                                     ; 9840
        brk                                     ; 9841
        cpx     $E8                             ; 9842
        bpl     L9846                           ; 9844
L9846:  .byte   $F4                             ; 9846
        inx                                     ; 9847
        beq     L984A                           ; 9848
L984A:  dec     $F8F8,x                         ; 984A
        brk                                     ; 984D
        inc     a:$F8                           ; 984E
        brk                                     ; 9851
        inc     $08F8,x                         ; 9852
        brk                                     ; 9855
        dec     $02F8                           ; 9856
        sed                                     ; 9859
        ora     ($A1,x)                         ; 985A
        sed                                     ; 985C
        brk                                     ; 985D
        eor     ($A1,x)                         ; 985E
        sed                                     ; 9860
        .byte   $04                             ; 9861
        .byte   $F4                             ; 9862
        brk                                     ; 9863
        cmp     ($F0,x)                         ; 9864
        .byte   $FC                             ; 9866
        brk                                     ; 9867
        cmp     $04F0                           ; 9868
        brk                                     ; 986B
        adc     $F0,x                           ; 986C
        .byte   $FC                             ; 986E
        brk                                     ; 986F
        .byte   $65                             ; 9870
L9871:  brk                                     ; 9871
L9872:  .byte   $02                             ; 9872
        sed                                     ; 9873
        brk                                     ; 9874
L9875:  adc     ($F8,x)                         ; 9875
        brk                                     ; 9877
        brk                                     ; 9878
        adc     ($F8),y                         ; 9879
        ora     ($FC,x)                         ; 987B
        brk                                     ; 987D
        .byte   $DB                             ; 987E
        sed                                     ; 987F
        bpl     L9872                           ; 9880
        brk                                     ; 9882
        .byte   $80                             ; 9883
        inx                                     ; 9884
        sed                                     ; 9885
        brk                                     ; 9886
        bcc     L9871                           ; 9887
        brk                                     ; 9889
        rti                                     ; 988A

; ----------------------------------------------------------------------------
        bcc     L9875                           ; 988B
        php                                     ; 988D
        rti                                     ; 988E

; ----------------------------------------------------------------------------
        .byte   $80                             ; 988F
        inx                                     ; 9890
        .byte   $F0                             ; 9891
L9892:  brk                                     ; 9892
L9893:  .byte   $82                             ; 9893
        sed                                     ; 9894
        sed                                     ; 9895
        brk                                     ; 9896
        .byte   $92                             ; 9897
        sed                                     ; 9898
        brk                                     ; 9899
        rti                                     ; 989A

; ----------------------------------------------------------------------------
        .byte   $92                             ; 989B
        sed                                     ; 989C
        php                                     ; 989D
        rti                                     ; 989E

; ----------------------------------------------------------------------------
        .byte   $82                             ; 989F
        sed                                     ; 98A0
        sed                                     ; 98A1
        brk                                     ; 98A2
        .byte   $F2                             ; 98A3
        php                                     ; 98A4
        brk                                     ; 98A5
        brk                                     ; 98A6
        .byte   $F4                             ; 98A7
        php                                     ; 98A8
        beq     L98AB                           ; 98A9
L98AB:  .byte   $E2                             ; 98AB
        bpl     L98B6                           ; 98AC
        rti                                     ; 98AE

; ----------------------------------------------------------------------------
        .byte   $E2                             ; 98AF
L98B0:  bpl     L9892                           ; 98B0
        brk                                     ; 98B2
L98B3:  cpx     #$18                            ; 98B3
        inx                                     ; 98B5
L98B6:  brk                                     ; 98B6
        beq     L98D1                           ; 98B7
        bpl     L98FB                           ; 98B9
        beq     L98D5                           ; 98BB
        clc                                     ; 98BD
        rti                                     ; 98BE

; ----------------------------------------------------------------------------
        cpx     #$18                            ; 98BF
        .byte   $FF                             ; 98C1
        .byte   $04                             ; 98C2
        sed                                     ; 98C3
        brk                                     ; 98C4
        ldy     #$E8                            ; 98C5
        brk                                     ; 98C7
        brk                                     ; 98C8
        bcs     L98B3                           ; 98C9
        sed                                     ; 98CB
        brk                                     ; 98CC
L98CD:  ldx     #$F8                            ; 98CD
        brk                                     ; 98CF
        brk                                     ; 98D0
L98D1:  .byte   $B2                             ; 98D1
        sed                                     ; 98D2
        .byte   $FF                             ; 98D3
        .byte   $04                             ; 98D4
L98D5:  inx                                     ; 98D5
        brk                                     ; 98D6
        cpy     #$F0                            ; 98D7
        beq     L98DB                           ; 98D9
L98DB:  .byte   $D0                             ; 98DB
L98DC:  beq     *-6                             ; 98DC
        brk                                     ; 98DE
        .byte   $C2                             ; 98DF
        sed                                     ; 98E0
        brk                                     ; 98E1
        brk                                     ; 98E2
        .byte   $D2                             ; 98E3
        sed                                     ; 98E4
        .byte   $FF                             ; 98E5
        .byte   $04                             ; 98E6
        inx                                     ; 98E7
        brk                                     ; 98E8
        dec     $F0F8                           ; 98E9
        brk                                     ; 98EC
        dec     $F8F8,x                         ; 98ED
        brk                                     ; 98F0
        inc     a:$F8                           ; 98F1
        brk                                     ; 98F4
        inc     $FFF8,x                         ; 98F5
        ora     ($F8,x)                         ; 98F8
        brk                                     ; 98FA
L98FB:  .byte   $2F                             ; 98FB
        dec     $01FF,x                         ; 98FC
        beq     L9901                           ; 98FF
L9901:  .byte   $3F                             ; 9901
        sed                                     ; 9902
        ora     ($08,x)                         ; 9903
        rti                                     ; 9905

; ----------------------------------------------------------------------------
        .byte   $3F                             ; 9906
        sed                                     ; 9907
        ora     ($FB,x)                         ; 9908
        .byte   $80                             ; 990A
        .byte   $2F                             ; 990B
        asl     $F001                           ; 990C
        .byte   $80                             ; 990F
        .byte   $3F                             ; 9910
        sed                                     ; 9911
        ora     ($00,x)                         ; 9912
        brk                                     ; 9914
        .byte   $2F                             ; 9915
        dec     $01FF,x                         ; 9916
        sed                                     ; 9919
        brk                                     ; 991A
        and     $FFDE                           ; 991B
        ora     ($F0,x)                         ; 991E
        brk                                     ; 9920
        and     $01F8,x                         ; 9921
        php                                     ; 9924
        rti                                     ; 9925

; ----------------------------------------------------------------------------
        and     $01F8,x                         ; 9926
        .byte   $FB                             ; 9929
        .byte   $80                             ; 992A
        and     $010E                           ; 992B
        beq     L98B0                           ; 992E
        and     $01FA,x                         ; 9930
        inc     $2D40,x                         ; 9933
        .byte   $E3                             ; 9936
        .byte   $FF                             ; 9937
        ora     ($F8,x)                         ; 9938
        brk                                     ; 993A
        .byte   $2B                             ; 993B
        dec     $02FF,x                         ; 993C
        inx                                     ; 993F
        brk                                     ; 9940
        .byte   $3B                             ; 9941
        sed                                     ; 9942
        beq     L9945                           ; 9943
L9945:  and     $02F8,y                         ; 9945
        bpl     L998A                           ; 9948
        .byte   $3B                             ; 994A
        sed                                     ; 994B
        php                                     ; 994C
        rti                                     ; 994D

; ----------------------------------------------------------------------------
        and     $01F8,y                         ; 994E
        .byte   $FB                             ; 9951
        .byte   $80                             ; 9952
        .byte   $2B                             ; 9953
        asl     $E802                           ; 9954
        .byte   $80                             ; 9957
        .byte   $3B                             ; 9958
        .byte   $FA                             ; 9959
        beq     L98DC                           ; 995A
        and     $01FA,y                         ; 995C
        inc     $2B40,x                         ; 995F
        .byte   $E3                             ; 9962
        .byte   $FF                             ; 9963
        ora     ($FC,x)                         ; 9964
        brk                                     ; 9966
        and     $01F8,x                         ; 9967
        .byte   $FC                             ; 996A
        .byte   $80                             ; 996B
        and     $01F8                           ; 996C
        .byte   $FC                             ; 996F
        rti                                     ; 9970

; ----------------------------------------------------------------------------
        and     $06F8                           ; 9971
        .byte   $FC                             ; 9974
        brk                                     ; 9975
        eor     #$F5                            ; 9976
        sbc     $4900,y                         ; 9978
        inc     $F9,x                           ; 997B
        brk                                     ; 997D
        eor     #$FA                            ; 997E
        .byte   $FC                             ; 9980
        brk                                     ; 9981
        eor     #$FB                            ; 9982
        .byte   $FF                             ; 9984
        brk                                     ; 9985
        eor     #$FA                            ; 9986
        .byte   $FF                             ; 9988
        brk                                     ; 9989
L998A:  eor     #$F6                            ; 998A
        asl     $FC                             ; 998C
        brk                                     ; 998E
        eor     #$F2                            ; 998F
        .byte   $F7                             ; 9991
        brk                                     ; 9992
        eor     #$F5                            ; 9993
        .byte   $F7                             ; 9995
        brk                                     ; 9996
        eor     #$FB                            ; 9997
L9999:  .byte   $FC                             ; 9999
        brk                                     ; 999A
        eor     #$FE                            ; 999B
        ora     ($00,x)                         ; 999D
        eor     #$FB                            ; 999F
        ora     ($00,x)                         ; 99A1
        eor     #$F5                            ; 99A3
        asl     $FC                             ; 99A5
        brk                                     ; 99A7
        eor     #$EC                            ; 99A8
        .byte   $F2                             ; 99AA
        brk                                     ; 99AB
        eor     #$F2                            ; 99AC
        .byte   $F2                             ; 99AE
        brk                                     ; 99AF
        eor     #$FE                            ; 99B0
        .byte   $FC                             ; 99B2
        brk                                     ; 99B3
        eor     #$04                            ; 99B4
        asl     $00                             ; 99B6
        eor     #$FE                            ; 99B8
        asl     $00                             ; 99BA
        eor     #$F2                            ; 99BC
        .byte   $02                             ; 99BE
        sed                                     ; 99BF
        brk                                     ; 99C0
        eor     ($F8,x)                         ; 99C1
        brk                                     ; 99C3
        rti                                     ; 99C4

; ----------------------------------------------------------------------------
        eor     ($F8,x)                         ; 99C5
        .byte   $04                             ; 99C7
        .byte   $F4                             ; 99C8
        brk                                     ; 99C9
        .byte   $73                             ; 99CA
        .byte   $F4                             ; 99CB
        sed                                     ; 99CC
        brk                                     ; 99CD
        .byte   $73                             ; 99CE
        inx                                     ; 99CF
        brk                                     ; 99D0
        brk                                     ; 99D1
        .byte   $73                             ; 99D2
        inx                                     ; 99D3
        .byte   $04                             ; 99D4
        brk                                     ; 99D5
        .byte   $73                             ; 99D6
        .byte   $F4                             ; 99D7
        .byte   $04                             ; 99D8
        cpx     $7300                           ; 99D9
        inx                                     ; 99DC
        .byte   $F4                             ; 99DD
        brk                                     ; 99DE
        .byte   $73                             ; 99DF
        cpx     #$04                            ; 99E0
        brk                                     ; 99E2
        .byte   $73                             ; 99E3
        cpx     #$0C                            ; 99E4
        brk                                     ; 99E6
        .byte   $73                             ; 99E7
        inx                                     ; 99E8
        .byte   $02                             ; 99E9
        sed                                     ; 99EA
        rti                                     ; 99EB

; ----------------------------------------------------------------------------
        lda     $F8,y                           ; 99EC
        rti                                     ; 99EF

; ----------------------------------------------------------------------------
        lda     #$F8                            ; 99F0
        .byte   $03                             ; 99F2
        .byte   $04                             ; 99F3
        .byte   $42                             ; 99F4
        sta     ($F8,x)                         ; 99F5
        .byte   $FC                             ; 99F7
        .byte   $42                             ; 99F8
        sta     ($F8),y                         ; 99F9
        .byte   $F4                             ; 99FB
        .byte   $02                             ; 99FC
        sta     ($F8,x)                         ; 99FD
        .byte   $02                             ; 99FF
        brk                                     ; 9A00
        .byte   $42                             ; 9A01
        lda     ($F8,x)                         ; 9A02
        sed                                     ; 9A04
        .byte   $02                             ; 9A05
        lda     ($F8,x)                         ; 9A06
        asl     $04                             ; 9A08
        rti                                     ; 9A0A

; ----------------------------------------------------------------------------
        sta     $E8                             ; 9A0B
        .byte   $FC                             ; 9A0D
        rti                                     ; 9A0E

; ----------------------------------------------------------------------------
        sta     $E8,x                           ; 9A0F
        .byte   $F4                             ; 9A11
        rti                                     ; 9A12

; ----------------------------------------------------------------------------
        .byte   $8F                             ; 9A13
        inx                                     ; 9A14
        .byte   $04                             ; 9A15
        rti                                     ; 9A16

; ----------------------------------------------------------------------------
        .byte   $87                             ; 9A17
        sed                                     ; 9A18
        .byte   $FC                             ; 9A19
        rti                                     ; 9A1A

; ----------------------------------------------------------------------------
        .byte   $97                             ; 9A1B
        sed                                     ; 9A1C
        .byte   $F4                             ; 9A1D
        rti                                     ; 9A1E

; ----------------------------------------------------------------------------
        sta     $06F8,x                         ; 9A1F
        .byte   $04                             ; 9A22
        rti                                     ; 9A23

; ----------------------------------------------------------------------------
        sta     $E8                             ; 9A24
        .byte   $FC                             ; 9A26
        rti                                     ; 9A27

; ----------------------------------------------------------------------------
        sta     $E8,x                           ; 9A28
        .byte   $F4                             ; 9A2A
        rti                                     ; 9A2B

; ----------------------------------------------------------------------------
        .byte   $9B                             ; 9A2C
        inx                                     ; 9A2D
        .byte   $04                             ; 9A2E
        rti                                     ; 9A2F

; ----------------------------------------------------------------------------
        .byte   $89                             ; 9A30
        sed                                     ; 9A31
        .byte   $FC                             ; 9A32
        rti                                     ; 9A33

; ----------------------------------------------------------------------------
        sta     $F4F8,y                         ; 9A34
        rti                                     ; 9A37

; ----------------------------------------------------------------------------
        sta     $06F8                           ; 9A38
        .byte   $04                             ; 9A3B
        rti                                     ; 9A3C

; ----------------------------------------------------------------------------
        sta     $E8                             ; 9A3D
        .byte   $FC                             ; 9A3F
        rti                                     ; 9A40

; ----------------------------------------------------------------------------
        sta     $E8,x                           ; 9A41
        .byte   $F4                             ; 9A43
        rti                                     ; 9A44

; ----------------------------------------------------------------------------
        .byte   $9B                             ; 9A45
        inx                                     ; 9A46
        .byte   $04                             ; 9A47
        rti                                     ; 9A48

; ----------------------------------------------------------------------------
        .byte   $87                             ; 9A49
        sed                                     ; 9A4A
        .byte   $FC                             ; 9A4B
        rti                                     ; 9A4C

; ----------------------------------------------------------------------------
        .byte   $97                             ; 9A4D
        sed                                     ; 9A4E
        .byte   $F4                             ; 9A4F
        rti                                     ; 9A50

; ----------------------------------------------------------------------------
        sta     $FFF8,x                         ; 9A51
        .byte   $02                             ; 9A54
        sed                                     ; 9A55
        .byte   $03                             ; 9A56
        cmp     ($F8),y                         ; 9A57
        brk                                     ; 9A59
        .byte   $43                             ; 9A5A
        cmp     ($F8),y                         ; 9A5B
        .byte   $FF                             ; 9A5D
        .byte   $02                             ; 9A5E
        sed                                     ; 9A5F
        .byte   $03                             ; 9A60
        cmp     ($F8,x)                         ; 9A61
        brk                                     ; 9A63
        .byte   $43                             ; 9A64
        cmp     ($F8,x)                         ; 9A65
        .byte   $FF                             ; 9A67
        .byte   $02                             ; 9A68
        sed                                     ; 9A69
        brk                                     ; 9A6A
        sbc     ($F8,x)                         ; 9A6B
        brk                                     ; 9A6D
        brk                                     ; 9A6E
        sbc     ($F8),y                         ; 9A6F
        .byte   $FF                             ; 9A71
        .byte   $02                             ; 9A72
        sed                                     ; 9A73
        brk                                     ; 9A74
        .byte   $C3                             ; 9A75
        sed                                     ; 9A76
        brk                                     ; 9A77
        brk                                     ; 9A78
        .byte   $D3                             ; 9A79
        sed                                     ; 9A7A
        .byte   $03                             ; 9A7B
        .byte   $F4                             ; 9A7C
        brk                                     ; 9A7D
        lda     $FCF8                           ; 9A7E
        brk                                     ; 9A81
        lda     $04F8,x                         ; 9A82
        rti                                     ; 9A85

; ----------------------------------------------------------------------------
        lda     $02F8                           ; 9A86
        sed                                     ; 9A89
        brk                                     ; 9A8A
        lda     $F8,x                           ; 9A8B
        brk                                     ; 9A8D
        brk                                     ; 9A8E
        cmp     $F8                             ; 9A8F
        .byte   $02                             ; 9A91
        sed                                     ; 9A92
        brk                                     ; 9A93
        .byte   $B7                             ; 9A94
        sed                                     ; 9A95
        brk                                     ; 9A96
        brk                                     ; 9A97
        .byte   $C7                             ; 9A98
        sed                                     ; 9A99
        .byte   $02                             ; 9A9A
        sed                                     ; 9A9B
        brk                                     ; 9A9C
        .byte   $AF                             ; 9A9D
        sed                                     ; 9A9E
        brk                                     ; 9A9F
        rti                                     ; 9AA0

; ----------------------------------------------------------------------------
        .byte   $AF                             ; 9AA1
        sed                                     ; 9AA2
        .byte   $04                             ; 9AA3
        sed                                     ; 9AA4
        brk                                     ; 9AA5
        .byte   $A7                             ; 9AA6
        .byte   $F3                             ; 9AA7
        brk                                     ; 9AA8
        rti                                     ; 9AA9

; ----------------------------------------------------------------------------
        .byte   $A7                             ; 9AAA
        .byte   $F3                             ; 9AAB
        sed                                     ; 9AAC
        brk                                     ; 9AAD
        .byte   $BF                             ; 9AAE
        .byte   $03                             ; 9AAF
        brk                                     ; 9AB0
        rti                                     ; 9AB1

; ----------------------------------------------------------------------------
        .byte   $BF                             ; 9AB2
        .byte   $03                             ; 9AB3
        .byte   $07                             ; 9AB4
        sed                                     ; 9AB5
        brk                                     ; 9AB6
        .byte   $A7                             ; 9AB7
        cld                                     ; 9AB8
        brk                                     ; 9AB9
        rti                                     ; 9ABA

; ----------------------------------------------------------------------------
        .byte   $A7                             ; 9ABB
        cld                                     ; 9ABC
        sed                                     ; 9ABD
        brk                                     ; 9ABE
        cmp     $E8,y                           ; 9ABF
        rti                                     ; 9AC2

; ----------------------------------------------------------------------------
        cmp     $F4E8,y                         ; 9AC3
        brk                                     ; 9AC6
        lda     $FCF8                           ; 9AC7
        brk                                     ; 9ACA
        lda     $04F8,x                         ; 9ACB
        rti                                     ; 9ACE

; ----------------------------------------------------------------------------
        lda     $04F8                           ; 9ACF
        sed                                     ; 9AD2
        brk                                     ; 9AD3
        .byte   $A7                             ; 9AD4
        inx                                     ; 9AD5
        brk                                     ; 9AD6
        rti                                     ; 9AD7

; ----------------------------------------------------------------------------
        .byte   $A7                             ; 9AD8
        inx                                     ; 9AD9
        sed                                     ; 9ADA
        brk                                     ; 9ADB
        cmp     $F8,y                           ; 9ADC
        rti                                     ; 9ADF

; ----------------------------------------------------------------------------
        cmp     $04F8,y                         ; 9AE0
        sed                                     ; 9AE3
        brk                                     ; 9AE4
        .byte   $A7                             ; 9AE5
        inx                                     ; 9AE6
        brk                                     ; 9AE7
        rti                                     ; 9AE8

; ----------------------------------------------------------------------------
        .byte   $A7                             ; 9AE9
        inx                                     ; 9AEA
        sed                                     ; 9AEB
        brk                                     ; 9AEC
        cmp     #$F8                            ; 9AED
        brk                                     ; 9AEF
        rti                                     ; 9AF0

; ----------------------------------------------------------------------------
        cmp     #$F8                            ; 9AF1
        asl     $F4                             ; 9AF3
        brk                                     ; 9AF5
        ldy     #$F0                            ; 9AF6
        .byte   $FC                             ; 9AF8
        brk                                     ; 9AF9
        stx     $F0                             ; 9AFA
        .byte   $04                             ; 9AFC
        rti                                     ; 9AFD

; ----------------------------------------------------------------------------
        ldy     #$F0                            ; 9AFE
        .byte   $F4                             ; 9B00
        .byte   $80                             ; 9B01
        ldy     #$00                            ; 9B02
        .byte   $FC                             ; 9B04
        brk                                     ; 9B05
        dey                                     ; 9B06
        brk                                     ; 9B07
        .byte   $04                             ; 9B08
        cpy     #$A0                            ; 9B09
        brk                                     ; 9B0B
        .byte   $02                             ; 9B0C
        sed                                     ; 9B0D
        ora     ($E9,x)                         ; 9B0E
        sed                                     ; 9B10
        brk                                     ; 9B11
        ora     ($EB,x)                         ; 9B12
        sed                                     ; 9B14
        .byte   $02                             ; 9B15
        brk                                     ; 9B16
        eor     ($E9,x)                         ; 9B17
        sed                                     ; 9B19
        sed                                     ; 9B1A
        eor     ($EB,x)                         ; 9B1B
        sed                                     ; 9B1D
        ora     ($FC,x)                         ; 9B1E
        brk                                     ; 9B20
        .byte   $C7                             ; 9B21
        sed                                     ; 9B22
        .byte   $FF                             ; 9B23
        .byte   $02                             ; 9B24
        sed                                     ; 9B25
        brk                                     ; 9B26
        .byte   $13                             ; 9B27
        sed                                     ; 9B28
        brk                                     ; 9B29
        brk                                     ; 9B2A
        sta     $04F8,x                         ; 9B2B
        sed                                     ; 9B2E
        brk                                     ; 9B2F
        cmp     $E8                             ; 9B30
        brk                                     ; 9B32
        rti                                     ; 9B33

; ----------------------------------------------------------------------------
        cmp     $E8                             ; 9B34
        sed                                     ; 9B36
        brk                                     ; 9B37
        eor     a:$F8                           ; 9B38
        rti                                     ; 9B3B

; ----------------------------------------------------------------------------
        eor     $04F8                           ; 9B3C
        sed                                     ; 9B3F
        brk                                     ; 9B40
        cmp     $E8                             ; 9B41
        brk                                     ; 9B43
        rti                                     ; 9B44

; ----------------------------------------------------------------------------
        cmp     $E8                             ; 9B45
        sed                                     ; 9B47
        brk                                     ; 9B48
        eor     a:$F8,x                         ; 9B49
        rti                                     ; 9B4C

; ----------------------------------------------------------------------------
        eor     $0FF8,x                         ; 9B4D
        .byte   $F0                             ; 9B50
L9B51:  brk                                     ; 9B51
L9B52:  cld                                     ; 9B52
        cpx     #$F8                            ; 9B53
        brk                                     ; 9B55
        inx                                     ; 9B56
        cpx     #$00                            ; 9B57
        brk                                     ; 9B59
        sed                                     ; 9B5A
        cpx     #$E8                            ; 9B5B
L9B5D:  brk                                     ; 9B5D
        iny                                     ; 9B5E
        beq     L9B51                           ; 9B5F
        brk                                     ; 9B61
        .byte   $DA                             ; 9B62
        beq     L9B5D                           ; 9B63
        brk                                     ; 9B65
        nop                                     ; 9B66
        beq     L9B69                           ; 9B67
L9B69:  brk                                     ; 9B69
        .byte   $FA                             ; 9B6A
        beq     L9B75                           ; 9B6B
        brk                                     ; 9B6D
        cpy     $F0                             ; 9B6E
        bpl     L9B72                           ; 9B70
L9B72:  .byte   $D4                             ; 9B72
        beq     L9B5D                           ; 9B73
L9B75:  brk                                     ; 9B75
        dec     $00                             ; 9B76
        beq     L9B7A                           ; 9B78
L9B7A:  dec     $00,x                           ; 9B7A
        sed                                     ; 9B7C
        brk                                     ; 9B7D
        cpx     a:$00                           ; 9B7E
        brk                                     ; 9B81
        .byte   $FC                             ; 9B82
        brk                                     ; 9B83
        php                                     ; 9B84
        brk                                     ; 9B85
        cpx     $00                             ; 9B86
        bpl     L9B8A                           ; 9B88
L9B8A:  .byte   $F4                             ; 9B8A
        brk                                     ; 9B8B
        .byte   $04                             ; 9B8C
        sed                                     ; 9B8D
        brk                                     ; 9B8E
        .byte   $8F                             ; 9B8F
        inx                                     ; 9B90
        brk                                     ; 9B91
        rti                                     ; 9B92

; ----------------------------------------------------------------------------
        .byte   $8F                             ; 9B93
        inx                                     ; 9B94
        sed                                     ; 9B95
        brk                                     ; 9B96
        .byte   $83                             ; 9B97
        sed                                     ; 9B98
        brk                                     ; 9B99
        brk                                     ; 9B9A
        .byte   $93                             ; 9B9B
        sed                                     ; 9B9C
        .byte   $04                             ; 9B9D
        sed                                     ; 9B9E
        brk                                     ; 9B9F
        .byte   $8F                             ; 9BA0
        inx                                     ; 9BA1
        brk                                     ; 9BA2
        rti                                     ; 9BA3

; ----------------------------------------------------------------------------
        .byte   $8F                             ; 9BA4
        inx                                     ; 9BA5
        sed                                     ; 9BA6
        rti                                     ; 9BA7

; ----------------------------------------------------------------------------
        .byte   $93                             ; 9BA8
        sed                                     ; 9BA9
        brk                                     ; 9BAA
        rti                                     ; 9BAB

; ----------------------------------------------------------------------------
        .byte   $83                             ; 9BAC
        sed                                     ; 9BAD
        .byte   $FF                             ; 9BAE
        .byte   $04                             ; 9BAF
        sed                                     ; 9BB0
        brk                                     ; 9BB1
        .byte   $9F                             ; 9BB2
        inx                                     ; 9BB3
        brk                                     ; 9BB4
        brk                                     ; 9BB5
        lda     ($E8),y                         ; 9BB6
        sed                                     ; 9BB8
        brk                                     ; 9BB9
        .byte   $83                             ; 9BBA
        sed                                     ; 9BBB
        brk                                     ; 9BBC
        brk                                     ; 9BBD
        .byte   $93                             ; 9BBE
        sed                                     ; 9BBF
        .byte   $FF                             ; 9BC0
        .byte   $04                             ; 9BC1
        sed                                     ; 9BC2
        brk                                     ; 9BC3
        .byte   $9F                             ; 9BC4
        inx                                     ; 9BC5
        brk                                     ; 9BC6
        brk                                     ; 9BC7
        lda     ($E8),y                         ; 9BC8
        sed                                     ; 9BCA
        rti                                     ; 9BCB

; ----------------------------------------------------------------------------
        .byte   $93                             ; 9BCC
        sed                                     ; 9BCD
        brk                                     ; 9BCE
        rti                                     ; 9BCF

; ----------------------------------------------------------------------------
        .byte   $83                             ; 9BD0
        sed                                     ; 9BD1
        .byte   $04                             ; 9BD2
        sed                                     ; 9BD3
        brk                                     ; 9BD4
        .byte   $87                             ; 9BD5
        inx                                     ; 9BD6
        brk                                     ; 9BD7
        rti                                     ; 9BD8

; ----------------------------------------------------------------------------
        .byte   $87                             ; 9BD9
        inx                                     ; 9BDA
        sed                                     ; 9BDB
        brk                                     ; 9BDC
        .byte   $89                             ; 9BDD
        sed                                     ; 9BDE
        brk                                     ; 9BDF
        rti                                     ; 9BE0

; ----------------------------------------------------------------------------
        .byte   $89                             ; 9BE1
        sed                                     ; 9BE2
        .byte   $04                             ; 9BE3
        sed                                     ; 9BE4
        brk                                     ; 9BE5
        .byte   $97                             ; 9BE6
        inx                                     ; 9BE7
        brk                                     ; 9BE8
        rti                                     ; 9BE9

; ----------------------------------------------------------------------------
        .byte   $97                             ; 9BEA
        inx                                     ; 9BEB
        sed                                     ; 9BEC
        brk                                     ; 9BED
        sta     $F8,y                           ; 9BEE
        rti                                     ; 9BF1

; ----------------------------------------------------------------------------
        sta     $FFF8,y                         ; 9BF2
        .byte   $02                             ; 9BF5
        sed                                     ; 9BF6
        brk                                     ; 9BF7
        .byte   $8B                             ; 9BF8
        sed                                     ; 9BF9
        brk                                     ; 9BFA
        brk                                     ; 9BFB
        sta     $F8                             ; 9BFC
        .byte   $FF                             ; 9BFE
        .byte   $02                             ; 9BFF
        sed                                     ; 9C00
        brk                                     ; 9C01
        .byte   $8B                             ; 9C02
        sed                                     ; 9C03
        brk                                     ; 9C04
        brk                                     ; 9C05
        sta     $F8,x                           ; 9C06
        .byte   $04                             ; 9C08
        sed                                     ; 9C09
        brk                                     ; 9C0A
        sta     a:$E8                           ; 9C0B
        rti                                     ; 9C0E

; ----------------------------------------------------------------------------
        sta     $F8E8                           ; 9C0F
        brk                                     ; 9C12
        .byte   $A3                             ; 9C13
        sed                                     ; 9C14
        brk                                     ; 9C15
        brk                                     ; 9C16
        .byte   $B3                             ; 9C17
        sed                                     ; 9C18
        .byte   $04                             ; 9C19
        sed                                     ; 9C1A
        brk                                     ; 9C1B
        sta     a:$E8                           ; 9C1C
        rti                                     ; 9C1F

; ----------------------------------------------------------------------------
        sta     $F8E8                           ; 9C20
        rti                                     ; 9C23

; ----------------------------------------------------------------------------
        .byte   $B3                             ; 9C24
        sed                                     ; 9C25
        brk                                     ; 9C26
        rti                                     ; 9C27

; ----------------------------------------------------------------------------
        .byte   $A3                             ; 9C28
        sed                                     ; 9C29
        .byte   $FF                             ; 9C2A
        .byte   $04                             ; 9C2B
        sed                                     ; 9C2C
        brk                                     ; 9C2D
        lda     $E8                             ; 9C2E
        brk                                     ; 9C30
        brk                                     ; 9C31
        lda     $E8,x                           ; 9C32
        sed                                     ; 9C34
        brk                                     ; 9C35
        .byte   $A3                             ; 9C36
        sed                                     ; 9C37
        brk                                     ; 9C38
        brk                                     ; 9C39
        .byte   $B3                             ; 9C3A
        sed                                     ; 9C3B
        .byte   $FF                             ; 9C3C
        .byte   $04                             ; 9C3D
        sed                                     ; 9C3E
        brk                                     ; 9C3F
        lda     $E8                             ; 9C40
        brk                                     ; 9C42
        brk                                     ; 9C43
        lda     $E8,x                           ; 9C44
        sed                                     ; 9C46
        rti                                     ; 9C47

; ----------------------------------------------------------------------------
        .byte   $B3                             ; 9C48
        sed                                     ; 9C49
        brk                                     ; 9C4A
        rti                                     ; 9C4B

; ----------------------------------------------------------------------------
        .byte   $A3                             ; 9C4C
        sed                                     ; 9C4D
        .byte   $04                             ; 9C4E
        sed                                     ; 9C4F
        brk                                     ; 9C50
        .byte   $A7                             ; 9C51
        inx                                     ; 9C52
        brk                                     ; 9C53
        rti                                     ; 9C54

; ----------------------------------------------------------------------------
        .byte   $A7                             ; 9C55
        inx                                     ; 9C56
        sed                                     ; 9C57
        brk                                     ; 9C58
        .byte   $B7                             ; 9C59
        sed                                     ; 9C5A
        brk                                     ; 9C5B
        rti                                     ; 9C5C

; ----------------------------------------------------------------------------
        .byte   $B7                             ; 9C5D
        sed                                     ; 9C5E
        .byte   $02                             ; 9C5F
        sed                                     ; 9C60
        brk                                     ; 9C61
        lda     #$E8                            ; 9C62
        brk                                     ; 9C64
        rti                                     ; 9C65

; ----------------------------------------------------------------------------
        lda     #$E8                            ; 9C66
        asl     $F4                             ; 9C68
        brk                                     ; 9C6A
        .byte   $9B                             ; 9C6B
        inx                                     ; 9C6C
        .byte   $FC                             ; 9C6D
        brk                                     ; 9C6E
        .byte   $AB                             ; 9C6F
        inx                                     ; 9C70
        .byte   $04                             ; 9C71
        rti                                     ; 9C72

; ----------------------------------------------------------------------------
        .byte   $9B                             ; 9C73
        inx                                     ; 9C74
        .byte   $F4                             ; 9C75
        brk                                     ; 9C76
        sta     $FCF8,x                         ; 9C77
        brk                                     ; 9C7A
        lda     $04F8                           ; 9C7B
        rti                                     ; 9C7E

; ----------------------------------------------------------------------------
        sta     $06F8,x                         ; 9C7F
        .byte   $F4                             ; 9C82
        brk                                     ; 9C83
        .byte   $BB                             ; 9C84
        inx                                     ; 9C85
        .byte   $FC                             ; 9C86
        brk                                     ; 9C87
        .byte   $AB                             ; 9C88
        inx                                     ; 9C89
        .byte   $04                             ; 9C8A
        rti                                     ; 9C8B

; ----------------------------------------------------------------------------
        .byte   $BB                             ; 9C8C
        inx                                     ; 9C8D
        .byte   $F4                             ; 9C8E
        brk                                     ; 9C8F
        lda     $FCF8,x                         ; 9C90
        brk                                     ; 9C93
        lda     $04F8                           ; 9C94
        rti                                     ; 9C97

; ----------------------------------------------------------------------------
        lda     $04F8,x                         ; 9C98
        sed                                     ; 9C9B
        brk                                     ; 9C9C
        sta     a:$E8                           ; 9C9D
        rti                                     ; 9CA0

; ----------------------------------------------------------------------------
        sta     $F8E8                           ; 9CA1
        brk                                     ; 9CA4
        .byte   $AF                             ; 9CA5
        sed                                     ; 9CA6
        brk                                     ; 9CA7
        brk                                     ; 9CA8
        .byte   $BF                             ; 9CA9
        sed                                     ; 9CAA
        .byte   $04                             ; 9CAB
        sed                                     ; 9CAC
        brk                                     ; 9CAD
        sta     a:$E8                           ; 9CAE
        rti                                     ; 9CB1

; ----------------------------------------------------------------------------
        sta     $F8E8                           ; 9CB2
        rti                                     ; 9CB5

; ----------------------------------------------------------------------------
        .byte   $BF                             ; 9CB6
        sed                                     ; 9CB7
        brk                                     ; 9CB8
        rti                                     ; 9CB9

; ----------------------------------------------------------------------------
        .byte   $AF                             ; 9CBA
        sed                                     ; 9CBB
        .byte   $FF                             ; 9CBC
        .byte   $04                             ; 9CBD
        sed                                     ; 9CBE
        brk                                     ; 9CBF
        lda     $E8                             ; 9CC0
        brk                                     ; 9CC2
        brk                                     ; 9CC3
        lda     $E8,x                           ; 9CC4
        sed                                     ; 9CC6
        brk                                     ; 9CC7
        .byte   $AF                             ; 9CC8
        sed                                     ; 9CC9
        brk                                     ; 9CCA
        brk                                     ; 9CCB
        .byte   $BF                             ; 9CCC
        sed                                     ; 9CCD
        .byte   $FF                             ; 9CCE
        .byte   $04                             ; 9CCF
        sed                                     ; 9CD0
        brk                                     ; 9CD1
        lda     $E8                             ; 9CD2
        brk                                     ; 9CD4
        brk                                     ; 9CD5
        lda     $E8,x                           ; 9CD6
        sed                                     ; 9CD8
        rti                                     ; 9CD9

; ----------------------------------------------------------------------------
        .byte   $BF                             ; 9CDA
        sed                                     ; 9CDB
        brk                                     ; 9CDC
        rti                                     ; 9CDD

; ----------------------------------------------------------------------------
        .byte   $AF                             ; 9CDE
        sed                                     ; 9CDF
        ora     $F8                             ; 9CE0
        brk                                     ; 9CE2
        cmp     ($F0,x)                         ; 9CE3
        brk                                     ; 9CE5
        rti                                     ; 9CE6

; ----------------------------------------------------------------------------
        cmp     ($F0,x)                         ; 9CE7
        sed                                     ; 9CE9
        brk                                     ; 9CEA
        .byte   $C3                             ; 9CEB
        brk                                     ; 9CEC
        brk                                     ; 9CED
        rti                                     ; 9CEE

; ----------------------------------------------------------------------------
        .byte   $C3                             ; 9CEF
        brk                                     ; 9CF0
        .byte   $FC                             ; 9CF1
        brk                                     ; 9CF2
        .byte   $D3                             ; 9CF3
        bpl     L9CF9                           ; 9CF4
        sed                                     ; 9CF6
        brk                                     ; 9CF7
        .byte   $D1                             ; 9CF8
L9CF9:  sed                                     ; 9CF9
        brk                                     ; 9CFA
        rti                                     ; 9CFB

; ----------------------------------------------------------------------------
        cmp     ($F8),y                         ; 9CFC
        .byte   $FC                             ; 9CFE
        brk                                     ; 9CFF
        .byte   $D3                             ; 9D00
        bpl     L9D04                           ; 9D01
        .byte   $FC                             ; 9D03
L9D04:  brk                                     ; 9D04
        cmp     ($F8),y                         ; 9D05
        .byte   $FF                             ; 9D07
        .byte   $02                             ; 9D08
        sed                                     ; 9D09
        brk                                     ; 9D0A
        .byte   $E3                             ; 9D0B
        sed                                     ; 9D0C
        brk                                     ; 9D0D
        brk                                     ; 9D0E
        sbc     ($F8),y                         ; 9D0F
        ora     ($FC,x)                         ; 9D11
        brk                                     ; 9D13
        sbc     ($F8),y                         ; 9D14
        ora     ($FC,x)                         ; 9D16
        brk                                     ; 9D18
        .byte   $F3                             ; 9D19
        sed                                     ; 9D1A
        asl     $F8                             ; 9D1B
        .byte   $03                             ; 9D1D
        .byte   $CF                             ; 9D1E
        cld                                     ; 9D1F
        brk                                     ; 9D20
        .byte   $03                             ; 9D21
        .byte   $DF                             ; 9D22
        cld                                     ; 9D23
        sed                                     ; 9D24
        brk                                     ; 9D25
        cmp     $E8,y                           ; 9D26
        rti                                     ; 9D29

; ----------------------------------------------------------------------------
        cmp     $F8E8,y                         ; 9D2A
        brk                                     ; 9D2D
        cmp     #$F8                            ; 9D2E
        brk                                     ; 9D30
        rti                                     ; 9D31

; ----------------------------------------------------------------------------
L9D32:  cmp     #$F8                            ; 9D32
        .byte   $32                             ; 9D34
        rol     $3E41,x                         ; 9D35
        and     $B048,x                         ; 9D38
        .byte   $42                             ; 9D3B
        .byte   $44                             ; 9D3C
        .byte   $3F                             ; 9D3D
        sec                                     ; 9D3E
        .byte   $32                             ; 9D3F
        bcs     L9D78                           ; 9D40
        .byte   $44                             ; 9D42
        and     $3C2C,x                         ; 9D43
        .byte   $34                             ; 9D46
        .byte   $32                             ; 9D47
        bcs     L9D89                           ; 9D48
        .byte   $44                             ; 9D4A
        .byte   $3A                             ; 9D4B
        sec                                     ; 9D4C
        lda     $4436,x                         ; 9D4D
        and     ($38),y                         ; 9D50
        and     ($B8),y                         ; 9D52
        .byte   $3C                             ; 9D54
        .byte   $44                             ; 9D55
        .byte   $42                             ; 9D56
        .byte   $43                             ; 9D57
        bmi     L9D8F                           ; 9D58
        bcs     L9D90                           ; 9D5A
        .byte   $3F                             ; 9D5C
        sec                                     ; 9D5D
        lda     $3041,x                         ; 9D5E
        sec                                     ; 9D61
        and     $3AC8,x                         ; 9D62
        .byte   $34                             ; 9D65
        and     ($30),y                         ; 9D66
        and     ($C4),y                         ; 9D68
        and     $30,x                           ; 9D6A
        eor     ($44,x)                         ; 9D6C
        tsx                                     ; 9D6E
        .byte   $37                             ; 9D6F
        bmi     L9DB4                           ; 9D70
        .byte   $42                             ; 9D72
        bmi     L9D32                           ; 9D73
        bmi     L9DB4                           ; 9D75
        .byte   $B3                             ; 9D77
L9D78:  bmi     L9DBB                           ; 9D78
        ldy     $30,x                           ; 9D7A
        sec                                     ; 9D7C
        eor     ($3E,x)                         ; 9D7D
        .byte   $42                             ; 9D7F
        .byte   $32                             ; 9D80
        .byte   $37                             ; 9D81
        ldy     $30,x                           ; 9D82
        .byte   $3F                             ; 9D84
        .byte   $3F                             ; 9D85
        .byte   $34                             ; 9D86
L9D87:  bmi     L9DCA                           ; 9D87
L9D89:  .byte   $34                             ; 9D89
        .byte   $B3                             ; 9D8A
        and     ($B4),y                         ; 9D8B
        and     ($44),y                         ; 9D8D
L9D8F:  .byte   $C3                             ; 9D8F
L9D90:  and     ($34),y                         ; 9D90
        .byte   $34                             ; 9D92
        lda     $3032,x                         ; 9D93
        lda     $4432,x                         ; 9D96
        eor     ($3B,x)                         ; 9D99
        iny                                     ; 9D9B
        .byte   $32                             ; 9D9C
L9D9D:  sec                                     ; 9D9D
        .byte   $3C                             ; 9D9E
        bmi     L9DE2                           ; 9D9F
        rol     $32BD,x                         ; 9DA1
        rol     $3D44,x                         ; 9DA4
        .byte   $43                             ; 9DA7
        eor     ($C8,x)                         ; 9DA8
        .byte   $32                             ; 9DAA
        rol     $B43C,x                         ; 9DAB
        .byte   $32                             ; 9DAE
        rol     $3E3B,x                         ; 9DAF
        cmp     ($33,x)                         ; 9DB2
L9DB4:  .byte   $34                             ; 9DB4
        .byte   $42                             ; 9DB5
        .byte   $34                             ; 9DB6
        eor     ($C3,x)                         ; 9DB7
        .byte   $33                             ; 9DB9
        sec                                     ; 9DBA
L9DBB:  .byte   $B3                             ; 9DBB
L9DBC:  .byte   $33                             ; 9DBC
        ldx     $3433,y                         ; 9DBD
        and     $34,x                           ; 9DC0
        bmi     L9D87                           ; 9DC2
        .byte   $33                             ; 9DC4
        .byte   $34                             ; 9DC5
        .byte   $3C                             ; 9DC6
        rol     $33BD,x                         ; 9DC7
L9DCA:  bmi     L9E08                           ; 9DCA
        bmi     L9E04                           ; 9DCC
        ldy     $34,x                           ; 9DCE
        .byte   $42                             ; 9DD0
        .byte   $32                             ; 9DD1
        bmi     L9E13                           ; 9DD2
        ldy     $35,x                           ; 9DD4
        .byte   $3B                             ; 9DD6
L9DD7:  iny                                     ; 9DD7
        and     $3E,x                           ; 9DD8
        cmp     ($35,x)                         ; 9DDA
        rol     $BC41,x                         ; 9DDC
        and     $3E,x                           ; 9DDF
        .byte   $41                             ; 9DE1
L9DE2:  .byte   $34                             ; 9DE2
        .byte   $42                             ; 9DE3
        .byte   $C3                             ; 9DE4
        and     $41,x                           ; 9DE5
        rol     $35BC,x                         ; 9DE7
        sec                                     ; 9DEA
        eor     ($B4,x)                         ; 9DEB
        and     $41,x                           ; 9DED
        .byte   $44                             ; 9DEF
        sec                                     ; 9DF0
        .byte   $C3                             ; 9DF1
        rol     $BE,x                           ; 9DF2
        rol     $41,x                           ; 9DF4
        .byte   $34                             ; 9DF6
        bmi     L9DBC                           ; 9DF7
        rol     $38,x                           ; 9DF9
        .byte   $3B                             ; 9DFB
        rol     $B0,x                           ; 9DFC
        rol     $3E,x                           ; 9DFE
        eor     ($30,x)                         ; 9E00
        rol     $3E,x                           ; 9E02
L9E04:  eor     ($B0,x)                         ; 9E04
        .byte   $37                             ; 9E06
        .byte   $34                             ; 9E07
L9E08:  eor     ($BE,x)                         ; 9E08
        .byte   $37                             ; 9E0A
        .byte   $34                             ; 9E0B
        eor     ($B4,x)                         ; 9E0C
        .byte   $37                             ; 9E0E
        bmi     L9E56                           ; 9E0F
        ldy     $37,x                           ; 9E11
L9E13:  bmi     L9DD7                           ; 9E13
        .byte   $37                             ; 9E15
        sec                                     ; 9E16
        ldy     $4238,x                         ; 9E17
        and     $B0,x                           ; 9E1A
        sec                                     ; 9E1C
        .byte   $C2                             ; 9E1D
        sec                                     ; 9E1E
        .byte   $C3                             ; 9E1F
        sec                                     ; 9E20
        and     $38B6,x                         ; 9E21
        lda     $38,x                           ; 9E24
        lda     $3D3A,x                         ; 9E26
        rol     $3BC6,x                         ; 9E29
        sec                                     ; 9E2C
        .byte   $3A                             ; 9E2D
        ldy     $3B,x                           ; 9E2E
        bmi     L9E6C                           ; 9E30
        ldy     $3C,x                           ; 9E32
        bmi     L9E6C                           ; 9E34
        sec                                     ; 9E36
        .byte   $B2                             ; 9E37
        .byte   $3C                             ; 9E38
        .byte   $34                             ; 9E39
        .byte   $34                             ; 9E3A
        .byte   $C3                             ; 9E3B
        .byte   $3C                             ; 9E3C
        rol     $3DC5,x                         ; 9E3D
        ldx     $B53E,y                         ; 9E40
        rol     $C344,x                         ; 9E43
        rol     $3B3D,x                         ; 9E46
        iny                                     ; 9E49
        .byte   $3F                             ; 9E4A
        bmi     L9E88                           ; 9E4B
        bmi     L9E81                           ; 9E4D
        ldy     $3F,x                           ; 9E4F
        .byte   $3B                             ; 9E51
        bmi     L9E86                           ; 9E52
        ldy     $3F,x                           ; 9E54
L9E56:  rol     $3446,x                         ; 9E56
        cmp     ($42,x)                         ; 9E59
        bmi     L9E8E                           ; 9E5B
        bmi     L9EA0                           ; 9E5D
        rol     $42BD,x                         ; 9E5F
        rol     $BD3E,x                         ; 9E62
        .byte   $42                             ; 9E65
        rol     $B43C,x                         ; 9E66
        .byte   $42                             ; 9E69
        .byte   $32                             ; 9E6A
        .byte   $37                             ; 9E6B
L9E6C:  .byte   $34                             ; 9E6C
        .byte   $37                             ; 9E6D
        .byte   $34                             ; 9E6E
        eor     ($30,x)                         ; 9E6F
        eor     #$30                            ; 9E71
        .byte   $33                             ; 9E73
        ldy     $42,x                           ; 9E74
        sec                                     ; 9E76
        .byte   $33                             ; 9E77
        ldy     $42,x                           ; 9E78
        bmi     L9EB7                           ; 9E7A
        bmi     L9EBA                           ; 9E7C
        bmi     L9EBD                           ; 9E7E
        .byte   $33                             ; 9E80
L9E81:  .byte   $34                             ; 9E81
        cmp     ($42,x)                         ; 9E82
        .byte   $43                             ; 9E84
        .byte   $3E                             ; 9E85
L9E86:  .byte   $3D                             ; 9E86
        .byte   $B4                             ; 9E87
L9E88:  .byte   $43                             ; 9E88
        .byte   $37                             ; 9E89
        ldy     $43,x                           ; 9E8A
        .byte   $37                             ; 9E8C
        .byte   $30                             ; 9E8D
L9E8E:  .byte   $C3                             ; 9E8E
        .byte   $43                             ; 9E8F
        rol     $BD46,x                         ; 9E90
        .byte   $43                             ; 9E93
        .byte   $37                             ; 9E94
        .byte   $34                             ; 9E95
        eor     ($B4,x)                         ; 9E96
L9E98:  .byte   $43                             ; 9E98
        .byte   $37                             ; 9E99
        sec                                     ; 9E9A
        .byte   $C2                             ; 9E9B
        .byte   $43                             ; 9E9C
        ldx     $4143,y                         ; 9E9D
L9EA0:  bmi     L9EDF                           ; 9EA0
        .byte   $42                             ; 9EA2
        .byte   $3B                             ; 9EA3
        bmi     L9EE9                           ; 9EA4
        sec                                     ; 9EA6
        rol     $CE3D,x                         ; 9EA7
        .byte   $43                             ; 9EAA
        sec                                     ; 9EAB
        .byte   $3C                             ; 9EAC
        ldy     $43,x                           ; 9EAD
        bmi     L9EEB                           ; 9EAF
        .byte   $34                             ; 9EB1
        lda     $3443,x                         ; 9EB2
        cmp     ($43,x)                         ; 9EB5
L9EB7:  eor     ($3E,x)                         ; 9EB7
        .byte   $3B                             ; 9EB9
L9EBA:  .byte   $BB                             ; 9EBA
        .byte   $44                             ; 9EBB
        .byte   $42                             ; 9EBC
L9EBD:  ldy     $46,x                           ; 9EBD
        sec                                     ; 9EBF
        .byte   $43                             ; 9EC0
        .byte   $B7                             ; 9EC1
        lsr     $34                             ; 9EC2
        .byte   $3B                             ; 9EC4
        .byte   $32                             ; 9EC5
        rol     $B43C,x                         ; 9EC6
        lsr     $38                             ; 9EC9
        .byte   $3B                             ; 9ECB
        .byte   $BB                             ; 9ECC
        lsr     $30                             ; 9ECD
        sec                                     ; 9ECF
        .byte   $C3                             ; 9ED0
        lsr     $37                             ; 9ED1
        bmi     L9E98                           ; 9ED3
        pha                                     ; 9ED5
        rol     $C144,x                         ; 9ED6
        pha                                     ; 9ED9
        rol     $49C4,x                         ; 9EDA
L9EDD:  bmi     L9F17                           ; 9EDD
L9EDF:  and     $B130,x                         ; 9EDF
        jmp     L31C2                           ; 9EE2

; ----------------------------------------------------------------------------
        sec                                     ; 9EE5
        ldx     $31,y                           ; 9EE6
        iny                                     ; 9EE8
L9EE9:  .byte   $32                             ; 9EE9
        .byte   $30                             ; 9EEA
L9EEB:  .byte   $3C                             ; 9EEB
        ldy     $32,x                           ; 9EEC
        .byte   $44                             ; 9EEE
        eor     ($42,x)                         ; 9EEF
        ldy     $33,x                           ; 9EF1
        rol     $3633,x                         ; 9EF3
        .byte   $34                             ; 9EF6
        .byte   $B3                             ; 9EF7
        and     $41,x                           ; 9EF8
        rol     $B449,x                         ; 9EFA
        rol     $30,x                           ; 9EFD
        eor     $B4                             ; 9EFF
        rol     $3E,x                           ; 9F01
        .byte   $C3                             ; 9F03
        .byte   $37                             ; 9F04
        bmi     L9EBA                           ; 9F05
        rol     $37BD,x                         ; 9F07
        .byte   $4F                             ; 9F0A
        .byte   $BF                             ; 9F0B
        eor     ($34,x)                         ; 9F0C
        .byte   $32                             ; 9F0E
        rol     $3445,x                         ; 9F0F
        eor     ($34,x)                         ; 9F12
        .byte   $B3                             ; 9F14
        eor     ($44,x)                         ; 9F15
L9F17:  .byte   $3F                             ; 9F17
        sec                                     ; 9F18
        bmi     L9EDD                           ; 9F19
L9F1B:  .byte   $3C                             ; 9F1B
        .byte   $4F                             ; 9F1C
        .byte   $BF                             ; 9F1D
        lsr     $30                             ; 9F1E
        .byte   $C2                             ; 9F20
        lsr     $34                             ; 9F21
        eor     ($B4,x)                         ; 9F23
        .byte   $46                             ; 9F25
L9F26:  rol     $BA41,x                         ; 9F26
        .byte   $3F                             ; 9F29
        bmi     L9F6E                           ; 9F2A
        .byte   $42                             ; 9F2C
        lsr     $3E                             ; 9F2D
        eor     ($B3,x)                         ; 9F2F
        .byte   $3F                             ; 9F31
        .byte   $3B                             ; 9F32
        .byte   $34                             ; 9F33
        bmi     L9F78                           ; 9F34
        ldy     $46,x                           ; 9F36
        eor     ($3E,x)                         ; 9F38
        and     $42B6,x                         ; 9F3A
        .byte   $43                             ; 9F3D
        sec                                     ; 9F3E
        .byte   $3B                             ; 9F3F
        .byte   $BB                             ; 9F40
        .byte   $32                             ; 9F41
        .byte   $37                             ; 9F42
        .byte   $34                             ; 9F43
        .byte   $32                             ; 9F44
        tsx                                     ; 9F45
        .byte   $34                             ; 9F46
        and     $3443,x                         ; 9F47
        cmp     ($30,x)                         ; 9F4A
        rol     $30,x                           ; 9F4C
        sec                                     ; 9F4E
        lda     $343B,x                         ; 9F4F
        .byte   $C3                             ; 9F52
        php                                     ; 9F53
        bit     $2C2C                           ; 9F54
        bit     $2C2C                           ; 9F57
        cmp     ($D1,x)                         ; 9F5A
        cpx     #$B7                            ; 9F5C
        clv                                     ; 9F5E
        sty     L9484                           ; 9F5F
        lda     ($D0),y                         ; 9F62
        bcs     L9F26                           ; 9F64
        txa                                     ; 9F66
        sta     $83                             ; 9F67
        bne     L9F1B                           ; 9F69
        cpy     #$8A                            ; 9F6B
        .byte   $85                             ; 9F6D
L9F6E:  .byte   $83                             ; 9F6E
        .byte   $8B                             ; 9F6F
        .byte   $9B                             ; 9F70
        cpy     #$8A                            ; 9F71
        sta     $83                             ; 9F73
        bne     L9F26                           ; 9F75
        .byte   $BF                             ; 9F77
L9F78:  pha                                     ; 9F78
        tay                                     ; 9F79
        pha                                     ; 9F7A
        cli                                     ; 9F7B
        rts                                     ; 9F7C

; ----------------------------------------------------------------------------
        tay                                     ; 9F7D
        rts                                     ; 9F7E

; ----------------------------------------------------------------------------
        cli                                     ; 9F7F
        sei                                     ; 9F80
        tay                                     ; 9F81
        sei                                     ; 9F82
        cli                                     ; 9F83
        ora     ($FF,x)                         ; 9F84
        ora     ($FF,x)                         ; 9F86
        ora     ($FF,x)                         ; 9F88
        ora     ($FF,x)                         ; 9F8A
        ora     ($FE,x)                         ; 9F8C
        .byte   $02                             ; 9F8E
        .byte   $FF                             ; 9F8F
        ora     ($FE,x)                         ; 9F90
        .byte   $02                             ; 9F92
        .byte   $FF                             ; 9F93
        .byte   $02                             ; 9F94
        inc     $FE02,x                         ; 9F95
        .byte   $02                             ; 9F98
        inc     $FE02,x                         ; 9F99
        .byte   $03                             ; 9F9C
        sbc     $FD03,x                         ; 9F9D
        .byte   $03                             ; 9FA0
        sbc     $FD03,x                         ; 9FA1
        .byte   $0F                             ; 9FA4
        brk                                     ; 9FA5
        brk                                     ; 9FA6
        asl     $0F                             ; 9FA7
        bpl     L9FBB                           ; 9FA9
        asl     $0F,x                           ; 9FAB
        jsr     L2620                           ; 9FAD
        .byte   $44                             ; 9FB0
        cli                                     ; 9FB1
        .byte   $FF                             ; 9FB2
        .byte   $FF                             ; 9FB3
        jmp     (L0130)                         ; 9FB4

; ----------------------------------------------------------------------------
        .byte   $FF                             ; 9FB7
        sty     $58,x                           ; 9FB8
        .byte   $01                             ; 9FBA
L9FBB:  ora     ($44,x)                         ; 9FBB
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
        nop                                     ; 9FDB
        nop                                     ; 9FDC
        nop                                     ; 9FDD
        nop                                     ; 9FDE
        nop                                     ; 9FDF
        nop                                     ; 9FE0
        nop                                     ; 9FE1
        nop                                     ; 9FE2
        jsr     LE083                           ; 9FE3
        jsr     LF038                           ; 9FE6
        jsr     LE080                           ; 9FE9
        jmp     LF032                           ; 9FEC

; ----------------------------------------------------------------------------
        nop                                     ; 9FEF
        rts                                     ; 9FF0

; ----------------------------------------------------------------------------
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
