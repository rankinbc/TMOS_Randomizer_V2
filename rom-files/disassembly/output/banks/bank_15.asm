; ============================================================================
; The Magic of Scheherazade - Bank 15 Disassembly
; ============================================================================
; File Offset: 0x1E000 - 0x1FFFF
; CPU Address: $E000 - $FFFF
; Size: 8192 bytes (8 KB)
; ============================================================================
;
; NOTE: This is a raw disassembly. Data regions interpreted as code will
; appear as garbage instructions. Further analysis needed to identify
; code vs data boundaries.
;
; ============================================================================

; da65 V2.19 - Git 034f73a
; Created:    2026-01-24 04:39:30
; Input file: C:/claude-workspace/TMOS_AI/rom-files/disassembly/output/banks/bank_15.bin
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
L000F           := $000F
L003E           := $003E
L00FC           := $00FC
L0130           := $0130
L041C           := $041C
L1001           := $1001
L1420           := $1420
L1428           := $1428
L1606           := $1606
L1616           := $1616
PPU_CTRL        := $2000
PPU_MASK        := $2001
PPU_STATUS      := $2002
OAM_ADDR        := $2003
OAM_DATA        := $2004
PPU_SCROLL      := $2005
PPU_ADDR        := $2006
PPU_DATA        := $2007
L2011           := $2011
L2020           := $2020
L20F0           := $20F0
L2107           := $2107
L2116           := $2116
L2601           := $2601
L2611           := $2611
L2616           := $2616
L2620           := $2620
L2706           := $2706
L2714           := $2714
L2716           := $2716
L2806           := $2806
L280A           := $280A
L2906           := $2906
L3121           := $3121
OAM_DMA         := $4014
APU_STATUS      := $4015
JOY1            := $4016
JOY2_FRAME      := $4017
L4438           := $4438
L8000           := $8000
L9473           := $9473
L9C38           := $9C38
LB000           := $B000
LCFE0           := $CFE0
; ----------------------------------------------------------------------------
        inc     $3A                             ; E000
        inc     $3A                             ; E002
        inc     $3A                             ; E004
        inc     $3A                             ; E006
        inc     $3A                             ; E008
        sta     $3B                             ; E00A
        lda     #$00                            ; E00C
        jmp     LE11E                           ; E00E

; ----------------------------------------------------------------------------
        inc     $3A                             ; E011
        inc     $3A                             ; E013
        inc     $3A                             ; E015
        inc     $3A                             ; E017
        inc     $3A                             ; E019
        inc     $3A                             ; E01B
        inc     $3A                             ; E01D
        inc     $3A                             ; E01F
        inc     $3A                             ; E021
        inc     $3A                             ; E023
        inc     $3A                             ; E025
        inc     $3A                             ; E027
        inc     $3A                             ; E029
        inc     $3A                             ; E02B
        inc     $3A                             ; E02D
        inc     $3A                             ; E02F
        inc     $3A                             ; E031
LE033:  inc     $3A                             ; E033
        inc     $3A                             ; E035
        inc     $3A                             ; E037
        inc     $3A                             ; E039
        inc     $3A                             ; E03B
        inc     $3A                             ; E03D
        sta     $3B                             ; E03F
        lda     #$01                            ; E041
        jmp     LE11E                           ; E043

; ----------------------------------------------------------------------------
        inc     $3A                             ; E046
        inc     $3A                             ; E048
        inc     $3A                             ; E04A
        inc     $3A                             ; E04C
        inc     $3A                             ; E04E
        inc     $3A                             ; E050
        inc     $3A                             ; E052
        inc     $3A                             ; E054
        inc     $3A                             ; E056
        sta     $3B                             ; E058
        lda     #$02                            ; E05A
        jmp     LE11E                           ; E05C

; ----------------------------------------------------------------------------
        inc     $3A                             ; E05F
        inc     $3A                             ; E061
        inc     $3A                             ; E063
        inc     $3A                             ; E065
        inc     $3A                             ; E067
        inc     $3A                             ; E069
LE06B:  inc     $3A                             ; E06B
        sta     $3B                             ; E06D
        lda     #$03                            ; E06F
        jmp     LE11E                           ; E071

; ----------------------------------------------------------------------------
        inc     $3A                             ; E074
        inc     $3A                             ; E076
        inc     $3A                             ; E078
        inc     $3A                             ; E07A
        inc     $3A                             ; E07C
        inc     $3A                             ; E07E
LE080:  inc     $3A                             ; E080
LE082:  inc     $3A                             ; E082
        inc     $3A                             ; E084
LE086:  inc     $3A                             ; E086
        inc     $3A                             ; E088
LE08A:  inc     $3A                             ; E08A
LE08C:  inc     $3A                             ; E08C
LE08E:  inc     $3A                             ; E08E
        inc     $3A                             ; E090
        inc     $3A                             ; E092
        inc     $3A                             ; E094
LE096:  inc     $3A                             ; E096
        inc     $3A                             ; E098
        inc     $3A                             ; E09A
LE09C:  inc     $3A                             ; E09C
        inc     $3A                             ; E09E
LE0A0:  inc     $3A                             ; E0A0
LE0A2:  inc     $3A                             ; E0A2
LE0A4:  sta     $3B                             ; E0A4
        lda     #$04                            ; E0A6
        jmp     LE11E                           ; E0A8

; ----------------------------------------------------------------------------
        inc     $3A                             ; E0AB
        inc     $3A                             ; E0AD
        inc     $3A                             ; E0AF
        inc     $3A                             ; E0B1
LE0B3:  inc     $3A                             ; E0B3
LE0B5:  inc     $3A                             ; E0B5
        inc     $3A                             ; E0B7
LE0B9:  inc     $3A                             ; E0B9
LE0BB:  inc     $3A                             ; E0BB
        inc     $3A                             ; E0BD
        inc     $3A                             ; E0BF
        inc     $3A                             ; E0C1
        inc     $3A                             ; E0C3
        inc     $3A                             ; E0C5
        inc     $3A                             ; E0C7
        inc     $3A                             ; E0C9
        inc     $3A                             ; E0CB
        inc     $3A                             ; E0CD
LE0CF:  inc     $3A                             ; E0CF
        inc     $3A                             ; E0D1
LE0D3:  inc     $3A                             ; E0D3
        sta     $3B                             ; E0D5
        lda     #$05                            ; E0D7
        jmp     LE11E                           ; E0D9

; ----------------------------------------------------------------------------
        inc     $3A                             ; E0DC
        inc     $3A                             ; E0DE
        inc     $3A                             ; E0E0
        inc     $3A                             ; E0E2
        inc     $3A                             ; E0E4
        inc     $3A                             ; E0E6
        inc     $3A                             ; E0E8
        inc     $3A                             ; E0EA
LE0EC:  inc     $3A                             ; E0EC
LE0EE:  inc     $3A                             ; E0EE
        inc     $3A                             ; E0F0
        inc     $3A                             ; E0F2
        inc     $3A                             ; E0F4
        inc     $3A                             ; E0F6
        inc     $3A                             ; E0F8
LE0FA:  inc     $3A                             ; E0FA
        inc     $3A                             ; E0FC
        inc     $3A                             ; E0FE
        inc     $3A                             ; E100
        inc     $3A                             ; E102
        inc     $3A                             ; E104
        inc     $3A                             ; E106
        inc     $3A                             ; E108
        inc     $3A                             ; E10A
        inc     $3A                             ; E10C
        inc     $3A                             ; E10E
LE110:  inc     $3A                             ; E110
LE112:  inc     $3A                             ; E112
        inc     $3A                             ; E114
LE116:  inc     $3A                             ; E116
        inc     $3A                             ; E118
LE11A:  sta     $3B                             ; E11A
        lda     #$06                            ; E11C
LE11E:  sta     $3D                             ; E11E
        lda     $39                             ; E120
        pha                                     ; E122
        lda     $3D                             ; E123
        sta     $39                             ; E125
        lda     $10                             ; E127
        and     #$7F                            ; E129
        sta     PPU_CTRL                        ; E12B
        lda     $39                             ; E12E
        jsr     LE596                           ; E130
        lda     $10                             ; E133
        sta     PPU_CTRL                        ; E135
        sty     $3C                             ; E138
        asl     $3A                             ; E13A
        ldy     $3A                             ; E13C
        lda     #$00                            ; E13E
        sta     $3A                             ; E140
        jsr     LE16A                           ; E142
        php                                     ; E145
        sta     $3B                             ; E146
        sty     $3C                             ; E148
        pla                                     ; E14A
        sta     $3D                             ; E14B
        pla                                     ; E14D
        sta     $39                             ; E14E
        lda     $10                             ; E150
        and     #$7F                            ; E152
        sta     PPU_CTRL                        ; E154
        lda     $39                             ; E157
        jsr     LE596                           ; E159
        lda     $10                             ; E15C
        sta     PPU_CTRL                        ; E15E
        lda     $3D                             ; E161
        pha                                     ; E163
        lda     $3B                             ; E164
        ldy     $3C                             ; E166
        plp                                     ; E168
        rts                                     ; E169

; ----------------------------------------------------------------------------
LE16A:  lda     L8000,y                         ; E16A
        sta     L003E                           ; E16D
        lda     $8001,y                         ; E16F
        sta     $3F                             ; E172
        ldy     $3C                             ; E174
        lda     $3B                             ; E176
        jmp     (L003E)                         ; E178

; ----------------------------------------------------------------------------
LE17B:  sta     $3B                             ; E17B
        pla                                     ; E17D
        sta     L003E                           ; E17E
        pla                                     ; E180
        sta     $3F                             ; E181
        sty     $3C                             ; E183
        ldy     #$01                            ; E185
        lda     (L003E),y                       ; E187
        sta     $3A                             ; E189
        iny                                     ; E18B
        lda     (L003E),y                       ; E18C
        ldy     $3C                             ; E18E
        jmp     LE11E                           ; E190

; ----------------------------------------------------------------------------
LE193:  jsr     LE2C6                           ; E193
        jmp     LE8B1                           ; E196

; ----------------------------------------------------------------------------
        .byte   $3E                             ; E199
        brk                                     ; E19A
RESET_Handler:
        sei                                     ; E19B
        cld                                     ; E19C
        lda     #$00                            ; E19D
        sta     PPU_CTRL                        ; E19F
        sta     PPU_MASK                        ; E1A2
        ldx     #$03                            ; E1A5
LE1A7:  lda     PPU_STATUS                      ; E1A7
        bpl     LE1A7                           ; E1AA
LE1AC:  lda     PPU_STATUS                      ; E1AC
        bmi     LE1AC                           ; E1AF
        dex                                     ; E1B1
        bpl     LE1A7                           ; E1B2
        txs                                     ; E1B4
        stx     JOY2_FRAME                      ; E1B5
        lda     #$00                            ; E1B8
        sta     APU_STATUS                      ; E1BA
        sta     APU_STATUS                      ; E1BD
        ldx     #$00                            ; E1C0
        txa                                     ; E1C2
LE1C3:  sta     $00,x                           ; E1C3
        sta     $0100,x                         ; E1C5
        sta     $0300,x                         ; E1C8
        sta     $0400,x                         ; E1CB
        sta     $0500,x                         ; E1CE
        inx                                     ; E1D1
        bne     LE1C3                           ; E1D2
        lda     #$0F                            ; E1D4
        ldx     #$1F                            ; E1D6
LE1D8:  sta     $04A0,x                         ; E1D8
        dex                                     ; E1DB
        bpl     LE1D8                           ; E1DC
        lda     #$20                            ; E1DE
        sta     $04A1                           ; E1E0
        sta     $04A2                           ; E1E3
        sta     $04A3                           ; E1E6
        jsr     LE871                           ; E1E9
        jsr     LEA7E                           ; E1EC
        lda     #$A5                            ; E1EF
        sta     $E0                             ; E1F1
        lda     #$14                            ; E1F3
        sta     $1C                             ; E1F5
        lda     #$06                            ; E1F7
        sta     $11                             ; E1F9
        lda     #$A0                            ; E1FB
        sta     $10                             ; E1FD
        sta     PPU_CTRL                        ; E1FF
        lda     #$85                            ; E202
        jsr     LE9EB                           ; E204
        lda     #$02                            ; E207
        sta     $18                             ; E209
LE20B:  jsr     LE5AA                           ; E20B
        jsr     LE95B                           ; E20E
        lda     $1D                             ; E211
        bne     LE23C                           ; E213
        ldx     #$15                            ; E215
LE217:  sta     $80,x                           ; E217
        dex                                     ; E219
        bpl     LE217                           ; E21A
        ldx     #$00                            ; E21C
LE21E:  sta     $0300,x                         ; E21E
        dex                                     ; E221
        bne     LE21E                           ; E222
        jsr     LE3B9                           ; E224
        lda     #$00                            ; E227
        sta     $60                             ; E229
        sta     $89                             ; E22B
        sta     $8B                             ; E22D
        lda     #$05                            ; E22F
        sta     $8A                             ; E231
        jsr     LE3A7                           ; E233
        jsr     LE0EE                           ; E236
        jsr     LE06B                           ; E239
LE23C:  jsr     LE3B6                           ; E23C
        lda     #$03                            ; E23F
        sta     $80                             ; E241
LE243:  jsr     LE5AA                           ; E243
        jsr     LF2BC                           ; E246
        lsr     $1D                             ; E249
        bcs     LE25A                           ; E24B
        jsr     LE06B                           ; E24D
        lda     #$00                            ; E250
        ldx     #$1F                            ; E252
LE254:  sta     $0480,x                         ; E254
        dex                                     ; E257
        bpl     LE254                           ; E258
LE25A:  sta     $1E                             ; E25A
        sta     $1F                             ; E25C
        sta     $C4                             ; E25E
        sta     $C5                             ; E260
        sta     $049F                           ; E262
        sta     $88                             ; E265
        ldx     #$0B                            ; E267
LE269:  sta     $03F1,x                         ; E269
        dex                                     ; E26C
        bpl     LE269                           ; E26D
        ldx     #$03                            ; E26F
LE271:  sta     $03DC,x                         ; E271
        dex                                     ; E274
        bpl     LE271                           ; E275
        sta     $72                             ; E277
        lda     #$10                            ; E279
        sta     $03F4                           ; E27B
        lda     #$1D                            ; E27E
        sta     $C6                             ; E280
        jsr     LE08E                           ; E282
        jsr     LE2C6                           ; E285
        jsr     LE8A8                           ; E288
        lda     #$00                            ; E28B
        jsr     LE898                           ; E28D
LE290:  jsr     LF73D                           ; E290
        lda     $18                             ; E293
        beq     LE29A                           ; E295
        jsr     LE110                           ; E297
LE29A:  jsr     LE11A                           ; E29A
        lda     $19                             ; E29D
        bmi     LE2AA                           ; E29F
        lda     $80                             ; E2A1
        bne     LE290                           ; E2A3
        sta     $60                             ; E2A5
        jsr     LE0EC                           ; E2A7
LE2AA:  lda     #$FF                            ; E2AA
        jsr     LE992                           ; E2AC
        lda     $19                             ; E2AF
        cmp     #$FF                            ; E2B1
        beq     LE243                           ; E2B3
        jmp     LE20B                           ; E2B5

; ----------------------------------------------------------------------------
LE2B8:  jsr     LEEB3                           ; E2B8
        lda     $18                             ; E2BB
        ora     $0162                           ; E2BD
        ora     $0163                           ; E2C0
        bne     LE2B8                           ; E2C3
        rts                                     ; E2C5

; ----------------------------------------------------------------------------
LE2C6:  ldx     #$15                            ; E2C6
        lda     #$00                            ; E2C8
LE2CA:  sta     $20,x                           ; E2CA
        dex                                     ; E2CC
        bpl     LE2CA                           ; E2CD
        sta     $031A                           ; E2CF
        sta     $031B                           ; E2D2
        sta     $93                             ; E2D5
        sta     $95                             ; E2D7
        sta     $0162                           ; E2D9
        sta     $0163                           ; E2DC
        sta     $03A0                           ; E2DF
        sta     $03A1                           ; E2E2
        sta     $6D                             ; E2E5
        tax                                     ; E2E7
LE2E8:  sta     $0600,x                         ; E2E8
        sta     $0700,x                         ; E2EB
        inx                                     ; E2EE
        bne     LE2E8                           ; E2EF
        jsr     LEA7E                           ; E2F1
        jsr     LE08C                           ; E2F4
        ldx     #$00                            ; E2F7
        lda     $B9                             ; E2F9
        jsr     LE086                           ; E2FB
        lda     #$22                            ; E2FE
        sta     $0601                           ; E300
        jsr     LE0B5                           ; E303
        ldx     #$08                            ; E306
        lda     #$04                            ; E308
        sta     $0608                           ; E30A
        lda     #$80                            ; E30D
        sta     $0609                           ; E30F
        lda     $0602                           ; E312
        sta     $060A                           ; E315
        lda     $0603                           ; E318
        sta     $060B                           ; E31B
        jsr     LE0A4                           ; E31E
        lda     $81                             ; E321
        bne     LE328                           ; E323
        jsr     LF6A0                           ; E325
LE328:  lda     #$0F                            ; E328
        sta     $031C                           ; E32A
        jsr     LEA72                           ; E32D
LE330:  jsr     LEACA                           ; E330
        jsr     LE2B8                           ; E333
        lda     $031C                           ; E336
        bne     LE330                           ; E339
        rts                                     ; E33B

; ----------------------------------------------------------------------------
        lda     $7F                             ; E33C
        lsr     a                               ; E33E
        bcs     LE344                           ; E33F
        jsr     LF2C6                           ; E341
LE344:  lda     #$00                            ; E344
        sta     $C3                             ; E346
        sta     $33                             ; E348
        lda     $0600                           ; E34A
        and     #$7F                            ; E34D
        cmp     #$03                            ; E34F
        bcs     LE36F                           ; E351
        lda     $21                             ; E353
        bne     LE366                           ; E355
        bit     $BF                             ; E357
        bvs     LE363                           ; E359
        lda     $B2                             ; E35B
        and     #$E0                            ; E35D
        cmp     #$10                            ; E35F
        beq     LE366                           ; E361
LE363:  jsr     LE0B9                           ; E363
LE366:  jsr     LE112                           ; E366
        jsr     LE116                           ; E369
        jsr     LF2AA                           ; E36C
LE36F:  jsr     LF17F                           ; E36F
        jsr     LF1ED                           ; E372
        jsr     LE0BB                           ; E375
        ldx     #$00                            ; E378
        jsr     LE0D3                           ; E37A
        jsr     LF396                           ; E37D
        jsr     LE0CF                           ; E380
        lda     #$00                            ; E383
        sta     $0319                           ; E385
        rts                                     ; E388

; ----------------------------------------------------------------------------
        dec     $80                             ; E389
        beq     LE398                           ; E38B
        jsr     LE033                           ; E38D
        jsr     LE5AA                           ; E390
        jsr     LE193                           ; E393
        lda     #$01                            ; E396
LE398:  rts                                     ; E398

; ----------------------------------------------------------------------------
        and     $7F                             ; E399
        bne     LE3A0                           ; E39B
LE39D:  jsr     LE0A2                           ; E39D
LE3A0:  jmp     LE0A0                           ; E3A0

; ----------------------------------------------------------------------------
        bne     LE398                           ; E3A3
        beq     LE39D                           ; E3A5
LE3A7:  lda     #$01                            ; E3A7
        sta     $030E                           ; E3A9
        sta     $0313                           ; E3AC
        sta     $0322                           ; E3AF
        sta     $0335                           ; E3B2
        rts                                     ; E3B5

; ----------------------------------------------------------------------------
LE3B6:  jsr     LF6A0                           ; E3B6
LE3B9:  jsr     LF6E8                           ; E3B9
        lda     $00                             ; E3BC
        sta     $8C                             ; E3BE
        lda     $01                             ; E3C0
        sta     $8D                             ; E3C2
        lda     $02                             ; E3C4
        sta     $8E                             ; E3C6
        rts                                     ; E3C8

; ----------------------------------------------------------------------------
NMI_Handler:
        pha                                     ; E3C9
        lda     PPU_STATUS                      ; E3CA
        lda     $1C                             ; E3CD
        ora     #$80                            ; E3CF
        sta     $1C                             ; E3D1
        and     #$01                            ; E3D3
        bne     LE3DF                           ; E3D5
        sta     OAM_ADDR                        ; E3D7
        lda     #$02                            ; E3DA
        sta     OAM_DMA                         ; E3DC
LE3DF:  lda     $10                             ; E3DF
        and     #$68                            ; E3E1
        sta     $10                             ; E3E3
        lda     #$00                            ; E3E5
        sta     PPU_CTRL                        ; E3E7
        sta     PPU_MASK                        ; E3EA
        txa                                     ; E3ED
        pha                                     ; E3EE
        tya                                     ; E3EF
        pha                                     ; E3F0
        lda     $1C                             ; E3F1
        and     #$04                            ; E3F3
        beq     LE41A                           ; E3F5
        lda     $1C                             ; E3F7
        and     #$FB                            ; E3F9
        sta     $1C                             ; E3FB
        lda     $10                             ; E3FD
        and     #$FB                            ; E3FF
        sta     PPU_CTRL                        ; E401
        lda     #$3F                            ; E404
        sta     PPU_ADDR                        ; E406
        lda     #$00                            ; E409
        sta     PPU_ADDR                        ; E40B
        tay                                     ; E40E
LE40F:  lda     $04A0,y                         ; E40F
        sta     PPU_DATA                        ; E412
        iny                                     ; E415
        cpy     #$20                            ; E416
        bne     LE40F                           ; E418
LE41A:  jsr     LEEEE                           ; E41A
LE41D:  lda     $1C                             ; E41D
        and     #$08                            ; E41F
        beq     LE488                           ; E421
        lda     $EC                             ; E423
        lsr     a                               ; E425
        lsr     a                               ; E426
        lsr     a                               ; E427
LE428:  lsr     a                               ; E428
        clc                                     ; E429
        adc     $ED                             ; E42A
        sta     $ED                             ; E42C
        lda     $EC                             ; E42E
        and     #$0F                            ; E430
        sta     $EC                             ; E432
        lda     $ED                             ; E434
        jsr     LEF73                           ; E436
        ldy     #$00                            ; E439
        lda     $EC                             ; E43B
        sta     PPU_ADDR                        ; E43D
        lda     $EB                             ; E440
        sta     PPU_ADDR                        ; E442
        lda     PPU_DATA                        ; E445
LE448:  lda     PPU_DATA                        ; E448
        sta     ($E8),y                         ; E44B
        iny                                     ; E44D
        dec     $EA                             ; E44E
        beq     LE456                           ; E450
        cpy     #$20                            ; E452
        bne     LE448                           ; E454
LE456:  clc                                     ; E456
        tya                                     ; E457
        adc     $E8                             ; E458
        sta     $E8                             ; E45A
        lda     $E9                             ; E45C
        adc     #$00                            ; E45E
        sta     $E9                             ; E460
        clc                                     ; E462
        tya                                     ; E463
        adc     $EB                             ; E464
        sta     $EB                             ; E466
        lda     $EC                             ; E468
        adc     #$00                            ; E46A
        sta     $EC                             ; E46C
        cmp     #$10                            ; E46E
        bcc     LE478                           ; E470
        and     #$0F                            ; E472
        sta     $EC                             ; E474
        inc     $ED                             ; E476
LE478:  lda     $EA                             ; E478
        beq     LE484                           ; E47A
        lda     $11                             ; E47C
        and     #$18                            ; E47E
        beq     LE41D                           ; E480
        bne     LE488                           ; E482
LE484:  lda     #$F7                            ; E484
        bne     LE48A                           ; E486
LE488:  lda     #$EF                            ; E488
LE48A:  and     $1C                             ; E48A
        sta     $1C                             ; E48C
        lda     $38                             ; E48E
        asl     a                               ; E490
        tay                                     ; E491
        lda     LED43,y                         ; E492
        jsr     LE56E                           ; E495
        lda     LED44,y                         ; E498
        jsr     LE582                           ; E49B
        lda     #$3F                            ; E49E
        sta     PPU_ADDR                        ; E4A0
        lda     #$00                            ; E4A3
        sta     PPU_ADDR                        ; E4A5
        sta     PPU_ADDR                        ; E4A8
        sta     PPU_ADDR                        ; E4AB
        lda     $11                             ; E4AE
        sta     PPU_MASK                        ; E4B0
        lda     $13                             ; E4B3
        ror     a                               ; E4B5
        lda     $15                             ; E4B6
        rol     a                               ; E4B8
        and     #$03                            ; E4B9
        ora     $10                             ; E4BB
        sta     $10                             ; E4BD
        sta     PPU_CTRL                        ; E4BF
        lda     $12                             ; E4C2
        sta     PPU_SCROLL                      ; E4C4
        lda     $14                             ; E4C7
        sta     PPU_SCROLL                      ; E4C9
        asl     $67                             ; E4CC
        lsr     $67                             ; E4CE
        lda     #$02                            ; E4D0
        sta     $D1                             ; E4D2
        lda     #$00                            ; E4D4
LE4D6:  ldy     #$08                            ; E4D6
        sta     $D0                             ; E4D8
        lda     #$01                            ; E4DA
        sta     JOY1                            ; E4DC
        lda     #$00                            ; E4DF
        sta     JOY1                            ; E4E1
LE4E4:  lda     JOY1                            ; E4E4
        sta     $D3                             ; E4E7
        and     #$03                            ; E4E9
        cmp     #$01                            ; E4EB
        ror     $D2                             ; E4ED
        dey                                     ; E4EF
        bne     LE4E4                           ; E4F0
        lda     $D2                             ; E4F2
        cmp     $D0                             ; E4F4
        bne     LE4D6                           ; E4F6
        dec     $D1                             ; E4F8
        bne     LE4D6                           ; E4FA
        eor     $C0                             ; E4FC
        and     $D2                             ; E4FE
        sta     $C2                             ; E500
        lda     $C0                             ; E502
        sta     $C1                             ; E504
        lda     $D2                             ; E506
        sta     $C0                             ; E508
        lda     $E0                             ; E50A
        and     #$02                            ; E50C
        sta     $D0                             ; E50E
        lda     $E7                             ; E510
        and     #$02                            ; E512
        eor     $D0                             ; E514
        clc                                     ; E516
        beq     LE51A                           ; E517
        sec                                     ; E519
LE51A:  ror     $E0                             ; E51A
        ldx     #$07                            ; E51C
LE51E:  ror     $E0,x                           ; E51E
        dex                                     ; E520
        bne     LE51E                           ; E521
        inc     $1E                             ; E523
        bne     LE529                           ; E525
        inc     $1F                             ; E527
LE529:  lda     $C4                             ; E529
        bne     LE548                           ; E52B
        lda     $18                             ; E52D
        bmi     LE548                           ; E52F
        ldx     #$0F                            ; E531
        lda     $1E                             ; E533
        and     #$0F                            ; E535
        beq     LE53F                           ; E537
        ldx     #$07                            ; E539
        and     #$07                            ; E53B
        bne     LE548                           ; E53D
LE53F:  lda     $20,x                           ; E53F
        beq     LE545                           ; E541
        dec     $20,x                           ; E543
LE545:  dex                                     ; E545
        bpl     LE53F                           ; E546
LE548:  lda     #$00                            ; E548
        jsr     LE596                           ; E54A
        jsr     L8000                           ; E54D
        lda     $39                             ; E550
        jsr     LE596                           ; E552
        lda     $57                             ; E555
        beq     LE55C                           ; E557
        jsr     LCFE0                           ; E559
LE55C:  pla                                     ; E55C
        tay                                     ; E55D
        pla                                     ; E55E
        tax                                     ; E55F
        lda     PPU_STATUS                      ; E560
        lda     $10                             ; E563
        ora     #$80                            ; E565
        sta     $10                             ; E567
        sta     PPU_CTRL                        ; E569
        pla                                     ; E56C
        rti                                     ; E56D

; ----------------------------------------------------------------------------
LE56E:  sta     $BFFF                           ; E56E
        lsr     a                               ; E571
        sta     $BFFF                           ; E572
        lsr     a                               ; E575
        sta     $BFFF                           ; E576
        lsr     a                               ; E579
        sta     $BFFF                           ; E57A
        lsr     a                               ; E57D
        sta     $BFFF                           ; E57E
        rts                                     ; E581

; ----------------------------------------------------------------------------
LE582:  sta     $DFFF                           ; E582
        lsr     a                               ; E585
        sta     $DFFF                           ; E586
        lsr     a                               ; E589
        sta     $DFFF                           ; E58A
        lsr     a                               ; E58D
        sta     $DFFF                           ; E58E
        lsr     a                               ; E591
        sta     $DFFF                           ; E592
        rts                                     ; E595

; ----------------------------------------------------------------------------
LE596:  sta     LFFDF                           ; E596
        lsr     a                               ; E599
        sta     LFFDF                           ; E59A
        lsr     a                               ; E59D
        sta     LFFDF                           ; E59E
        lsr     a                               ; E5A1
        sta     LFFDF                           ; E5A2
        lsr     a                               ; E5A5
        sta     LFFDF                           ; E5A6
        rts                                     ; E5A9

; ----------------------------------------------------------------------------
LE5AA:  lda     #$06                            ; E5AA
        sta     PPU_MASK                        ; E5AC
LE5AF:  sta     $11                             ; E5AF
        rts                                     ; E5B1

; ----------------------------------------------------------------------------
LE5B2:  lda     #$1E                            ; E5B2
        bne     LE5AF                           ; E5B4
LE5B6:  lda     $1C                             ; E5B6
        and     #$0A                            ; E5B8
        bne     LE5E5                           ; E5BA
        lda     $18                             ; E5BC
        asl     a                               ; E5BE
        bcs     LE5E6                           ; E5BF
        tay                                     ; E5C1
        lda     $E8                             ; E5C2
        sta     $65                             ; E5C4
        lda     $E9                             ; E5C6
        sta     $66                             ; E5C8
        lda     LEE45,y                         ; E5CA
        sta     $E8                             ; E5CD
        lda     LEE46,y                         ; E5CF
        sta     $E9                             ; E5D2
LE5D4:  ldy     #$00                            ; E5D4
LE5D6:  lda     ($E8),y                         ; E5D6
        bne     LE5F2                           ; E5D8
        lda     $65                             ; E5DA
        sta     $E8                             ; E5DC
        lda     $66                             ; E5DE
        sta     $E9                             ; E5E0
        jmp     LF02F                           ; E5E2

; ----------------------------------------------------------------------------
LE5E5:  rts                                     ; E5E5

; ----------------------------------------------------------------------------
LE5E6:  jsr     LEF7E                           ; E5E6
        beq     LE5EF                           ; E5E9
        lda     $EC                             ; E5EB
        beq     LE5D4                           ; E5ED
LE5EF:  jmp     LE653                           ; E5EF

; ----------------------------------------------------------------------------
LE5F2:  jsr     LE7D7                           ; E5F2
        lda     $D0                             ; E5F5
        pha                                     ; E5F7
        sta     PPU_ADDR                        ; E5F8
        lda     $D1                             ; E5FB
        sta     PPU_ADDR                        ; E5FD
        lda     ($E8),y                         ; E600
        asl     a                               ; E602
        pha                                     ; E603
        lda     $10                             ; E604
        ora     #$04                            ; E606
        bcs     LE60C                           ; E608
        and     #$FB                            ; E60A
LE60C:  sta     PPU_CTRL                        ; E60C
        sta     $10                             ; E60F
        pla                                     ; E611
        asl     a                               ; E612
        php                                     ; E613
        bcc     LE619                           ; E614
        ora     #$02                            ; E616
        iny                                     ; E618
LE619:  plp                                     ; E619
        clc                                     ; E61A
        bne     LE61E                           ; E61B
        sec                                     ; E61D
LE61E:  ror     a                               ; E61E
        lsr     a                               ; E61F
        tax                                     ; E620
LE621:  bcs     LE624                           ; E621
        iny                                     ; E623
LE624:  lda     ($E8),y                         ; E624
        sta     PPU_DATA                        ; E626
        dex                                     ; E629
        bne     LE621                           ; E62A
        pla                                     ; E62C
        cmp     #$3F                            ; E62D
        bne     LE63D                           ; E62F
        sta     PPU_ADDR                        ; E631
        stx     PPU_ADDR                        ; E634
        stx     PPU_ADDR                        ; E637
        stx     PPU_ADDR                        ; E63A
LE63D:  iny                                     ; E63D
        cpy     #$C8                            ; E63E
        bcc     LE650                           ; E640
        clc                                     ; E642
        tya                                     ; E643
        adc     $E8                             ; E644
        sta     $E8                             ; E646
        lda     $E9                             ; E648
        adc     #$00                            ; E64A
        sta     $E9                             ; E64C
        ldy     #$00                            ; E64E
LE650:  jmp     LE5D6                           ; E650

; ----------------------------------------------------------------------------
LE653:  lda     $D9                             ; E653
        beq     LE689                           ; E655
        sta     PPU_ADDR                        ; E657
        lda     $DB                             ; E65A
        sta     PPU_ADDR                        ; E65C
        jmp     LEFCE                           ; E65F

; ----------------------------------------------------------------------------
LE662:  lda     #$00                            ; E662
        sta     $D9                             ; E664
        lda     $DF                             ; E666
        sta     PPU_DATA                        ; E668
        cmp     #$2C                            ; E66B
        beq     LE676                           ; E66D
        lda     $EB                             ; E66F
        beq     LE676                           ; E671
        jsr     LE992                           ; E673
LE676:  sec                                     ; E676
        lda     $10                             ; E677
        and     #$04                            ; E679
        beq     LE67F                           ; E67B
        lda     #$1F                            ; E67D
LE67F:  adc     $DB                             ; E67F
        sta     $DB                             ; E681
        lda     $DA                             ; E683
        adc     #$00                            ; E685
        sta     $DA                             ; E687
LE689:  lda     $18                             ; E689
        asl     a                               ; E68B
        beq     LE6E4                           ; E68C
        lda     #$80                            ; E68E
        sta     $18                             ; E690
LE692:  ldy     #$00                            ; E692
        sty     $68                             ; E694
        jsr     LEFA8                           ; E696
        beq     LE6EB                           ; E699
        jsr     LE7D7                           ; E69B
        lda     $D0                             ; E69E
        sta     $DA                             ; E6A0
        lda     $D1                             ; E6A2
        sta     $DB                             ; E6A4
        lda     $D2                             ; E6A6
        sta     $DC                             ; E6A8
        clc                                     ; E6AA
        lda     $EA                             ; E6AB
        bmi     LE6B5                           ; E6AD
        jsr     LEFA8                           ; E6AF
        asl     a                               ; E6B2
        sta     $DC                             ; E6B3
LE6B5:  lda     $10                             ; E6B5
        ora     #$04                            ; E6B7
        bcs     LE6BD                           ; E6B9
        and     #$FB                            ; E6BB
LE6BD:  sta     $10                             ; E6BD
        lda     $EA                             ; E6BF
        bmi     LE6D0                           ; E6C1
        jsr     LEFA8                           ; E6C3
        and     #$3F                            ; E6C6
        bne     LE6CC                           ; E6C8
        lda     #$40                            ; E6CA
LE6CC:  sta     $DD                             ; E6CC
        iny                                     ; E6CE
        clc                                     ; E6CF
LE6D0:  tya                                     ; E6D0
        adc     $E8                             ; E6D1
        sta     $E8                             ; E6D3
        lda     $E9                             ; E6D5
        adc     #$00                            ; E6D7
        sta     $E9                             ; E6D9
        lda     #$00                            ; E6DB
        sta     $031D                           ; E6DD
        lda     $EC                             ; E6E0
        sta     $DE                             ; E6E2
LE6E4:  lda     $DE                             ; E6E4
        beq     LE6FF                           ; E6E6
        dec     $DE                             ; E6E8
        rts                                     ; E6EA

; ----------------------------------------------------------------------------
LE6EB:  lda     $031C                           ; E6EB
        bpl     LE6F5                           ; E6EE
        ora     #$40                            ; E6F0
        sta     $031C                           ; E6F2
LE6F5:  lda     $68                             ; E6F5
        bne     LE6FC                           ; E6F7
        jmp     LF02F                           ; E6F9

; ----------------------------------------------------------------------------
LE6FC:  jmp     LE7A8                           ; E6FC

; ----------------------------------------------------------------------------
LE6FF:  lda     #$07                            ; E6FF
        sec                                     ; E701
        sbc     $030C                           ; E702
        bpl     LE709                           ; E705
        lda     #$00                            ; E707
LE709:  sta     $DE                             ; E709
LE70B:  ldy     #$00                            ; E70B
        jsr     LEFA8                           ; E70D
        sta     $DF                             ; E710
        lda     $EA                             ; E712
        bpl     LE74C                           ; E714
        lda     $DF                             ; E716
        cmp     #$2F                            ; E718
        beq     LE6EB                           ; E71A
        cmp     #$2E                            ; E71C
        bne     LE73F                           ; E71E
        lda     $DC                             ; E720
        clc                                     ; E722
        adc     #$40                            ; E723
        sta     $DC                             ; E725
        sta     $DB                             ; E727
        lda     $DA                             ; E729
        adc     #$00                            ; E72B
        sta     $DA                             ; E72D
        lda     $E8                             ; E72F
        clc                                     ; E731
        adc     #$01                            ; E732
        sta     $E8                             ; E734
        lda     $E9                             ; E736
        adc     #$00                            ; E738
        sta     $E9                             ; E73A
        jmp     LE70B                           ; E73C

; ----------------------------------------------------------------------------
LE73F:  cmp     #$2D                            ; E73F
        bne     LE74C                           ; E741
        iny                                     ; E743
        jsr     LEFA8                           ; E744
        sta     $DE                             ; E747
        jmp     LE7A8                           ; E749

; ----------------------------------------------------------------------------
LE74C:  lda     $DF                             ; E74C
        bpl     LE7A8                           ; E74E
        lda     $EA                             ; E750
        bpl     LE7A8                           ; E752
        lda     $DF                             ; E754
        cmp     #$FF                            ; E756
        bne     LE764                           ; E758
        lda     #$1E                            ; E75A
        sta     $D0                             ; E75C
        lda     #$03                            ; E75E
        sta     $D1                             ; E760
        bne     LE78E                           ; E762
LE764:  asl     a                               ; E764
        clc                                     ; E765
        bit     $EA                             ; E766
        bvc     LE77B                           ; E768
        adc     #$40                            ; E76A
        sta     $D1                             ; E76C
        lda     #$80                            ; E76E
        adc     #$00                            ; E770
        sta     $D2                             ; E772
        lda     #$04                            ; E774
        jsr     LE596                           ; E776
        beq     LE785                           ; E779
LE77B:  adc     $ED                             ; E77B
        sta     $D1                             ; E77D
        lda     $EE                             ; E77F
        adc     #$00                            ; E781
        sta     $D2                             ; E783
LE785:  lda     ($D1),y                         ; E785
        sta     $D0                             ; E787
        iny                                     ; E789
        lda     ($D1),y                         ; E78A
        sta     $D1                             ; E78C
LE78E:  ldy     $031D                           ; E78E
        lda     ($D0),y                         ; E791
        tay                                     ; E793
        and     #$7F                            ; E794
        sta     $DF                             ; E796
        inc     $031D                           ; E798
        tya                                     ; E79B
        asl     a                               ; E79C
        ldy     #$FF                            ; E79D
        bcc     LE7A8                           ; E79F
        lda     #$00                            ; E7A1
        sta     $031D                           ; E7A3
        ldy     #$00                            ; E7A6
LE7A8:  iny                                     ; E7A8
        sty     $D3                             ; E7A9
        lda     $DA                             ; E7AB
        sta     $D9                             ; E7AD
        lda     $EA                             ; E7AF
        bmi     LE7BB                           ; E7B1
        dec     $DD                             ; E7B3
        beq     LE7BB                           ; E7B5
        lda     $DC                             ; E7B7
        bmi     LE7CC                           ; E7B9
LE7BB:  clc                                     ; E7BB
        lda     $E8                             ; E7BC
        adc     $D3                             ; E7BE
        sta     $E8                             ; E7C0
        lda     $E9                             ; E7C2
        adc     #$00                            ; E7C4
        sta     $E9                             ; E7C6
        lda     $EA                             ; E7C8
        bmi     LE7D4                           ; E7CA
LE7CC:  lda     $DD                             ; E7CC
        bne     LE7D4                           ; E7CE
        lda     #$FF                            ; E7D0
        sta     $18                             ; E7D2
LE7D4:  rts                                     ; E7D4

; ----------------------------------------------------------------------------
        .byte   $4C                             ; E7D5
        .byte   $2D                             ; E7D6
LE7D7:  bmi     LE7E4                           ; E7D7
        sta     $D0                             ; E7D9
        iny                                     ; E7DB
        jsr     LEFA8                           ; E7DC
        sta     $D1                             ; E7DF
        jmp     LE839                           ; E7E1

; ----------------------------------------------------------------------------
LE7E4:  cmp     #$8E                            ; E7E4
        bcs     LE82D                           ; E7E6
        tax                                     ; E7E8
        lda     #$08                            ; E7E9
        sta     $18                             ; E7EB
        lda     #$80                            ; E7ED
        sta     $68                             ; E7EF
        txa                                     ; E7F1
        and     #$0F                            ; E7F2
        tax                                     ; E7F4
        bne     LE7FC                           ; E7F5
        jsr     LE85D                           ; E7F7
        bne     LE82F                           ; E7FA
LE7FC:  lda     #$C2                            ; E7FC
        sta     $020C                           ; E7FE
        sta     $0210                           ; E801
        lda     #$0E                            ; E804
        sta     $020F                           ; E806
        lda     #$16                            ; E809
        sta     $0213                           ; E80B
        lda     LE865,x                         ; E80E
        sta     $020D                           ; E811
        sta     $0211                           ; E814
        lda     #$00                            ; E817
        sta     $020E                           ; E819
        ora     #$40                            ; E81C
        sta     $0212                           ; E81E
        lda     #$29                            ; E821
        sta     $D0                             ; E823
        lda     #$04                            ; E825
        sta     $D1                             ; E827
        lda     #$02                            ; E829
        bne     LE839                           ; E82B
LE82D:  asl     a                               ; E82D
        tax                                     ; E82E
LE82F:  lda     LED84,x                         ; E82F
        sta     $D0                             ; E832
        lda     LED83,x                         ; E834
        sta     $D1                             ; E837
LE839:  sta     $D2                             ; E839
        iny                                     ; E83B
        lda     $60                             ; E83C
        beq     LE85C                           ; E83E
        lda     $D0                             ; E840
        cmp     #$3F                            ; E842
        beq     LE85C                           ; E844
        cmp     #$28                            ; E846
        bcc     LE85C                           ; E848
        lda     #$23                            ; E84A
        sta     $D0                             ; E84C
        lda     $D1                             ; E84E
        sec                                     ; E850
        sbc     #$E0                            ; E851
        sta     $D1                             ; E853
        lda     $D2                             ; E855
        sec                                     ; E857
        sbc     #$E0                            ; E858
        sta     $D2                             ; E85A
LE85C:  rts                                     ; E85C

; ----------------------------------------------------------------------------
LE85D:  lda     #$F8                            ; E85D
        sta     $020C                           ; E85F
        sta     $0210                           ; E862
LE865:  rts                                     ; E865

; ----------------------------------------------------------------------------
        clc                                     ; E866
        .byte   $14                             ; E867
        rol     a                               ; E868
        asl     $24,x                           ; E869
        .byte   $1C                             ; E86B
        .byte   $0C                             ; E86C
        asl     $1A0A                           ; E86D
        .byte   $1E                             ; E870
LE871:  lda     #$FF                            ; E871
        sta     $9FFF                           ; E873
        lda     #$1F                            ; E876
        jsr     LEB93                           ; E878
        lda     #$00                            ; E87B
        jsr     LE56E                           ; E87D
        lda     #$01                            ; E880
        jsr     LE582                           ; E882
        lda     #$06                            ; E885
        sta     $39                             ; E887
        jsr     LE596                           ; E889
        rts                                     ; E88C

; ----------------------------------------------------------------------------
        lda     #$02                            ; E88D
        sta     $18                             ; E88F
        lda     #$00                            ; E891
        sta     $60                             ; E893
        jmp     LE328                           ; E895

; ----------------------------------------------------------------------------
LE898:  jsr     LE17B                           ; E898
        .byte   $1D                             ; E89B
        .byte   $04                             ; E89C
LE89D:  jsr     LE17B                           ; E89D
        .byte   $1C                             ; E8A0
        .byte   $04                             ; E8A1
LE8A2:  jsr     LF747                           ; E8A2
        jmp     LE95B                           ; E8A5

; ----------------------------------------------------------------------------
LE8A8:  jsr     LE95B                           ; E8A8
        jsr     LE8B1                           ; E8AB
        jmp     LF09B                           ; E8AE

; ----------------------------------------------------------------------------
LE8B1:  lda     #$00                            ; E8B1
        sta     $60                             ; E8B3
        lda     $19                             ; E8B5
        cmp     #$04                            ; E8B7
        bcs     LE8C5                           ; E8B9
        inc     $60                             ; E8BB
        jsr     LE328                           ; E8BD
        lda     #$10                            ; E8C0
        sta     $031C                           ; E8C2
LE8C5:  rts                                     ; E8C5

; ----------------------------------------------------------------------------
        .byte   $FF                             ; E8C6
        .byte   $FF                             ; E8C7
        sta     $38                             ; E8C8
        lda     $1C                             ; E8CA
        ora     #$10                            ; E8CC
        sta     $1C                             ; E8CE
        rts                                     ; E8D0

; ----------------------------------------------------------------------------
LE8D1:  lda     #$00                            ; E8D1
        sta     $18                             ; E8D3
        sta     $0162                           ; E8D5
        sta     $0163                           ; E8D8
        lda     $10                             ; E8DB
        and     #$F3                            ; E8DD
        sta     $10                             ; E8DF
        lda     $1C                             ; E8E1
        ora     #$08                            ; E8E3
        sta     $1C                             ; E8E5
LE8E7:  jsr     LE8A2                           ; E8E7
        and     #$08                            ; E8EA
        bne     LE8E7                           ; E8EC
        rts                                     ; E8EE

; ----------------------------------------------------------------------------
LE8EF:  lda     $60                             ; E8EF
        bne     LE90F                           ; E8F1
LE8F3:  bit     PPU_STATUS                      ; E8F3
        bvs     LE8F3                           ; E8F6
LE8F8:  bit     PPU_STATUS                      ; E8F8
        bvc     LE8F8                           ; E8FB
LE8FD:  lda     $36                             ; E8FD
        sta     PPU_ADDR                        ; E8FF
        lda     $37                             ; E902
        sta     PPU_ADDR                        ; E904
        lda     #$00                            ; E907
        sta     PPU_SCROLL                      ; E909
        sta     PPU_SCROLL                      ; E90C
LE90F:  lda     #$80                            ; E90F
        sta     $67                             ; E911
        lda     $18                             ; E913
        ora     $0163                           ; E915
        bne     LE94A                           ; E918
        jsr     LF259                           ; E91A
        lda     $6A                             ; E91D
        beq     LE94A                           ; E91F
        sty     $6B                             ; E921
        ldy     $0162                           ; E923
        lda     #$A9                            ; E926
        sta     $0163,y                         ; E928
        iny                                     ; E92B
        lda     #$02                            ; E92C
        sta     $0163,y                         ; E92E
        iny                                     ; E931
        lda     $AB                             ; E932
        lsr     a                               ; E934
        lsr     a                               ; E935
LE936:  lsr     a                               ; E936
        lsr     a                               ; E937
        jsr     LE94B                           ; E938
        lda     $AB                             ; E93B
        jsr     LE94B                           ; E93D
        lda     #$00                            ; E940
        sta     $0163,y                         ; E942
        sty     $0162                           ; E945
        ldy     $6B                             ; E948
LE94A:  rts                                     ; E94A

; ----------------------------------------------------------------------------
LE94B:  and     #$0F                            ; E94B
        cmp     #$0A                            ; E94D
        bcc     LE953                           ; E94F
        adc     #$25                            ; E951
LE953:  sta     $0163,y                         ; E953
        iny                                     ; E956
        rts                                     ; E957

; ----------------------------------------------------------------------------
        ora     ($C8,x)                         ; E958
        rts                                     ; E95A

; ----------------------------------------------------------------------------
LE95B:  jsr     LF24A                           ; E95B
        inc     $7F                             ; E95E
LE960:  lsr     a                               ; E960
        sta     $1C                             ; E961
        rts                                     ; E963

; ----------------------------------------------------------------------------
        sty     $3C                             ; E964
        ldy     $03A0                           ; E966
        sta     $03A2,y                         ; E969
        iny                                     ; E96C
        lda     $3C                             ; E96D
        sta     $03A2,y                         ; E96F
        iny                                     ; E972
        cpy     #$1E                            ; E973
        bne     LE979                           ; E975
        ldy     #$00                            ; E977
LE979:  sty     $03A0                           ; E979
        rts                                     ; E97C

; ----------------------------------------------------------------------------
LE97D:  asl     a                               ; E97D
        tay                                     ; E97E
        pla                                     ; E97F
        sta     $3C                             ; E980
        pla                                     ; E982
        sta     $3D                             ; E983
        iny                                     ; E985
        lda     ($3C),y                         ; E986
        sta     L003E                           ; E988
        iny                                     ; E98A
        lda     ($3C),y                         ; E98B
        sta     $3F                             ; E98D
        jmp     (L003E)                         ; E98F

; ----------------------------------------------------------------------------
LE992:  cmp     #$00                            ; E992
        beq     LE9DC                           ; E994
        sty     $03E6                           ; E996
        cmp     #$FF                            ; E999
        bne     LE9CA                           ; E99B
        lda     #$00                            ; E99D
        sta     $03E5                           ; E99F
        ldy     #$0A                            ; E9A2
LE9A4:  sta     $F8,y                           ; E9A4
        dey                                     ; E9A7
        bpl     LE9A4                           ; E9A8
        ldy     #$08                            ; E9AA
LE9AC:  sta     $0390,y                         ; E9AC
        dey                                     ; E9AF
        bpl     LE9AC                           ; E9B0
        sta     $4008                           ; E9B2
        sta     APU_STATUS                      ; E9B5
        lda     #$0F                            ; E9B8
        sta     APU_STATUS                      ; E9BA
        lda     #$90                            ; E9BD
        sta     $4000                           ; E9BF
        sta     $4004                           ; E9C2
        sta     $400C                           ; E9C5
        bne     LE9D9                           ; E9C8
LE9CA:  ldy     $03E5                           ; E9CA
        cpy     #$06                            ; E9CD
        bne     LE9D2                           ; E9CF
        dey                                     ; E9D1
LE9D2:  sta     $03E7,y                         ; E9D2
        iny                                     ; E9D5
        sty     $03E5                           ; E9D6
LE9D9:  ldy     $03E6                           ; E9D9
LE9DC:  rts                                     ; E9DC

; ----------------------------------------------------------------------------
        jsr     LE596                           ; E9DD
        jsr     LB000                           ; E9E0
        lda     #$00                            ; E9E3
        jmp     LE596                           ; E9E5

; ----------------------------------------------------------------------------
        ora     $40,x                           ; E9E8
        rts                                     ; E9EA

; ----------------------------------------------------------------------------
LE9EB:  sta     $00                             ; E9EB
        lda     $11                             ; E9ED
        pha                                     ; E9EF
        lda     #$00                            ; E9F0
        sta     $11                             ; E9F2
        sta     $18                             ; E9F4
        sta     $0162                           ; E9F6
        sta     $0163                           ; E9F9
        lda     $10                             ; E9FC
        and     #$7F                            ; E9FE
        sta     PPU_CTRL                        ; EA00
        lda     #$0F                            ; EA03
        asl     $00                             ; EA05
        rol     a                               ; EA07
        jsr     LEB93                           ; EA08
        jsr     LEA65                           ; EA0B
        jsr     LE95B                           ; EA0E
        lsr     $00                             ; EA11
        lda     #$20                            ; EA13
        sta     $01                             ; EA15
LEA17:  lsr     $00                             ; EA17
        bcc     LEA1E                           ; EA19
        jsr     LEA2F                           ; EA1B
LEA1E:  lda     $01                             ; EA1E
        clc                                     ; EA20
        adc     #$04                            ; EA21
        sta     $01                             ; EA23
        lda     $00                             ; EA25
        bne     LEA17                           ; EA27
        pla                                     ; EA29
        sta     $11                             ; EA2A
        jmp     LE95B                           ; EA2C

; ----------------------------------------------------------------------------
LEA2F:  lda     $01                             ; EA2F
        sta     $02                             ; EA31
        lda     #$00                            ; EA33
        sta     $03                             ; EA35
        lda     $10                             ; EA37
        and     #$7F                            ; EA39
        sta     PPU_CTRL                        ; EA3B
        tya                                     ; EA3E
        pha                                     ; EA3F
        lda     $02                             ; EA40
        sta     PPU_ADDR                        ; EA42
        lda     $03                             ; EA45
        sta     PPU_ADDR                        ; EA47
        ldy     #$00                            ; EA4A
        lda     #$2C                            ; EA4C
        jsr     LEA6B                           ; EA4E
        jsr     LEA6B                           ; EA51
        jsr     LEA6B                           ; EA54
        ldy     #$C0                            ; EA57
        jsr     LEA6B                           ; EA59
        ldy     #$40                            ; EA5C
        lda     #$00                            ; EA5E
        jsr     LEA6B                           ; EA60
        pla                                     ; EA63
        tay                                     ; EA64
LEA65:  lda     $10                             ; EA65
        sta     PPU_CTRL                        ; EA67
        rts                                     ; EA6A

; ----------------------------------------------------------------------------
LEA6B:  sta     PPU_DATA                        ; EA6B
        dey                                     ; EA6E
        bne     LEA6B                           ; EA6F
        rts                                     ; EA71

; ----------------------------------------------------------------------------
LEA72:  jsr     LE5AA                           ; EA72
        lda     $60                             ; EA75
        asl     a                               ; EA77
        adc     #$08                            ; EA78
        sta     $18                             ; EA7A
        rts                                     ; EA7C

; ----------------------------------------------------------------------------
        sed                                     ; EA7D
LEA7E:  ldx     #$00                            ; EA7E
        lda     #$F8                            ; EA80
LEA82:  sta     $0200,x                         ; EA82
        inx                                     ; EA85
        bne     LEA82                           ; EA86
        lda     #$28                            ; EA88
        sta     $36                             ; EA8A
        lda     #$E0                            ; EA8C
        sta     $37                             ; EA8E
        lda     #$BF                            ; EA90
        sta     $0200                           ; EA92
        lda     #$2E                            ; EA95
        sta     $0201                           ; EA97
        lda     #$22                            ; EA9A
        sta     $0202                           ; EA9C
        lda     #$DF                            ; EA9F
        sta     $0203                           ; EAA1
        lda     #$14                            ; EAA4
        sta     $16                             ; EAA6
        sta     $17                             ; EAA8
        lda     #$00                            ; EAAA
        sta     $12                             ; EAAC
        sta     $13                             ; EAAE
        sta     $14                             ; EAB0
        sta     $15                             ; EAB2
        rts                                     ; EAB4

; ----------------------------------------------------------------------------
LEAB5:  lda     #$01                            ; EAB5
        bne     LEAC3                           ; EAB7
LEAB9:  lda     #$02                            ; EAB9
        bne     LEAC3                           ; EABB
LEABD:  lda     #$04                            ; EABD
        bne     LEAC3                           ; EABF
LEAC1:  lda     #$08                            ; EAC1
LEAC3:  ora     $031C                           ; EAC3
        sta     $031C                           ; EAC6
        rts                                     ; EAC9

; ----------------------------------------------------------------------------
LEACA:  lda     $1C                             ; EACA
        ora     #$02                            ; EACC
        sta     $1C                             ; EACE
        jsr     LEADC                           ; EAD0
        lda     $1C                             ; EAD3
        and     #$FD                            ; EAD5
        sta     $1C                             ; EAD7
        jmp     LF743                           ; EAD9

; ----------------------------------------------------------------------------
LEADC:  lda     $18                             ; EADC
        bne     LEB2E                           ; EADE
        lda     $7F                             ; EAE0
        and     #$0F                            ; EAE2
        bne     LEB03                           ; EAE4
        lda     $03FC                           ; EAE6
        beq     LEB03                           ; EAE9
        lda     $03FA                           ; EAEB
        beq     LEB03                           ; EAEE
        cmp     #$0C                            ; EAF0
        beq     LEAFA                           ; EAF2
        inc     $03FA                           ; EAF4
        lsr     a                               ; EAF7
        bcc     LEB00                           ; EAF8
LEAFA:  lda     #$07                            ; EAFA
        sta     $18                             ; EAFC
        bcs     LEB03                           ; EAFE
LEB00:  jsr     LEAB5                           ; EB00
LEB03:  ldy     $03A1                           ; EB03
        cpy     $03A0                           ; EB06
        beq     LEB2E                           ; EB09
        lda     $03A2,y                         ; EB0B
        sta     $3B                             ; EB0E
        iny                                     ; EB10
        lda     $03A2,y                         ; EB11
        iny                                     ; EB14
        cpy     #$1E                            ; EB15
        bne     LEB1B                           ; EB17
        ldy     #$00                            ; EB19
LEB1B:  sty     $03A1                           ; EB1B
        tay                                     ; EB1E
        lda     $3B                             ; EB1F
        cpy     #$F0                            ; EB21
        bcs     LEB2B                           ; EB23
        jsr     LE08A                           ; EB25
        jmp     LEB2E                           ; EB28

; ----------------------------------------------------------------------------
LEB2B:  jsr     LE0B3                           ; EB2B
LEB2E:  lda     $C4                             ; EB2E
        bne     LEB7D                           ; EB30
        bit     $031C                           ; EB32
        bvc     LEB43                           ; EB35
        jsr     LEB61                           ; EB37
        lda     $031C                           ; EB3A
        and     #$3F                            ; EB3D
        sta     $031C                           ; EB3F
LEB42:  rts                                     ; EB42

; ----------------------------------------------------------------------------
LEB43:  bpl     LEB67                           ; EB43
        lda     $7F                             ; EB45
        and     #$03                            ; EB47
        bne     LEB5D                           ; EB49
        ldy     #$0C                            ; EB4B
        lda     #$22                            ; EB4D
LEB4F:  sta     $04A4,y                         ; EB4F
        dey                                     ; EB52
        bpl     LEB4F                           ; EB53
        sta     $04B0                           ; EB55
        sta     $04BA                           ; EB58
        bne     LEB64                           ; EB5B
LEB5D:  cmp     #$02                            ; EB5D
        bne     LEB67                           ; EB5F
LEB61:  jsr     LE080                           ; EB61
LEB64:  jmp     LF07B                           ; EB64

; ----------------------------------------------------------------------------
LEB67:  lda     $031C                           ; EB67
        and     #$20                            ; EB6A
        beq     LEB7D                           ; EB6C
        lda     $24                             ; EB6E
        bne     LEB61                           ; EB70
        lda     $031C                           ; EB72
        and     #$DF                            ; EB75
        sta     $031C                           ; EB77
        jmp     LEB61                           ; EB7A

; ----------------------------------------------------------------------------
LEB7D:  lda     $1C                             ; EB7D
        and     #$04                            ; EB7F
        bne     LEB42                           ; EB81
        lda     $68                             ; EB83
        and     #$C0                            ; EB85
        bne     LEB42                           ; EB87
        lda     $0162                           ; EB89
        cmp     #$14                            ; EB8C
        bcs     LEB42                           ; EB8E
        jmp     LE0FA                           ; EB90

; ----------------------------------------------------------------------------
LEB93:  sta     $9FFF                           ; EB93
        lsr     a                               ; EB96
        sta     $9FFF                           ; EB97
        lsr     a                               ; EB9A
        sta     $9FFF                           ; EB9B
        lsr     a                               ; EB9E
        sta     $9FFF                           ; EB9F
        lsr     a                               ; EBA2
        sta     $9FFF                           ; EBA3
        rts                                     ; EBA6

; ----------------------------------------------------------------------------
        .byte   $FF                             ; EBA7
        .byte   $FF                             ; EBA8
        stx     $3D                             ; EBA9
        ldx     #$01                            ; EBAB
        sec                                     ; EBAD
        jsr     LEBBD                           ; EBAE
        bcs     LEBDC                           ; EBB1
        ldx     #$01                            ; EBB3
        sec                                     ; EBB5
        bcs     LEBBD                           ; EBB6
LEBB8:  stx     $3D                             ; EBB8
        ldx     #$02                            ; EBBA
        sec                                     ; EBBC
LEBBD:  lda     $89,x                           ; EBBD
        adc     #$00                            ; EBBF
        sta     $89,x                           ; EBC1
        clc                                     ; EBC3
        adc     #$F6                            ; EBC4
        and     #$0F                            ; EBC6
        bcc     LEBCC                           ; EBC8
        sta     $89,x                           ; EBCA
LEBCC:  dex                                     ; EBCC
        bpl     LEBBD                           ; EBCD
        bcc     LEBDA                           ; EBCF
        ldx     #$02                            ; EBD1
        lda     #$09                            ; EBD3
LEBD5:  sta     $89,x                           ; EBD5
        dex                                     ; EBD7
        bpl     LEBD5                           ; EBD8
LEBDA:  ldx     $3D                             ; EBDA
LEBDC:  rts                                     ; EBDC

; ----------------------------------------------------------------------------
        stx     $3D                             ; EBDD
        ldx     #$02                            ; EBDF
        clc                                     ; EBE1
LEBE2:  lda     $89,x                           ; EBE2
        sbc     #$00                            ; EBE4
        sta     $89,x                           ; EBE6
        bcs     LEBEE                           ; EBE8
        lda     #$09                            ; EBEA
        sta     $89,x                           ; EBEC
LEBEE:  dex                                     ; EBEE
        bpl     LEBE2                           ; EBEF
        bcs     LEBFC                           ; EBF1
        ldx     #$02                            ; EBF3
        lda     #$00                            ; EBF5
LEBF7:  sta     $89,x                           ; EBF7
        dex                                     ; EBF9
        bpl     LEBF7                           ; EBFA
LEBFC:  ldx     $3D                             ; EBFC
        rts                                     ; EBFE

; ----------------------------------------------------------------------------
        stx     $3D                             ; EBFF
        jsr     LEABD                           ; EC01
        ldx     #$02                            ; EC04
        sec                                     ; EC06
LEC07:  lda     $8C,x                           ; EC07
        sbc     $00,x                           ; EC09
        bcs     LEC10                           ; EC0B
        adc     #$0A                            ; EC0D
        clc                                     ; EC0F
LEC10:  sta     $00,x                           ; EC10
        dex                                     ; EC12
        bpl     LEC07                           ; EC13
        ldx     $3D                             ; EC15
        lda     $00                             ; EC17
        ora     $01                             ; EC19
        ora     $02                             ; EC1B
        bne     LEC20                           ; EC1D
        clc                                     ; EC1F
LEC20:  rts                                     ; EC20

; ----------------------------------------------------------------------------
        stx     $3D                             ; EC21
        ldx     #$02                            ; EC23
        clc                                     ; EC25
LEC26:  lda     $8C,x                           ; EC26
        adc     $00,x                           ; EC28
        sta     $8C,x                           ; EC2A
        clc                                     ; EC2C
        adc     #$F6                            ; EC2D
        bcc     LEC35                           ; EC2F
        and     #$0F                            ; EC31
        sta     $8C,x                           ; EC33
LEC35:  dex                                     ; EC35
        bpl     LEC26                           ; EC36
        bcc     LEC43                           ; EC38
        ldx     #$02                            ; EC3A
        lda     #$09                            ; EC3C
LEC3E:  sta     $8C,x                           ; EC3E
        dex                                     ; EC40
        bpl     LEC3E                           ; EC41
LEC43:  ldx     $3D                             ; EC43
        rts                                     ; EC45

; ----------------------------------------------------------------------------
        clc                                     ; EC46
        lda     $85                             ; EC47
        adc     $00                             ; EC49
        sta     $85                             ; EC4B
        lda     $86                             ; EC4D
        adc     $01                             ; EC4F
        sta     $86                             ; EC51
        cmp     #$7F                            ; EC53
        bcc     LEC5F                           ; EC55
        lda     #$FF                            ; EC57
        sta     $85                             ; EC59
        lda     #$7F                            ; EC5B
        sta     $86                             ; EC5D
LEC5F:  clc                                     ; EC5F
        lda     $7C                             ; EC60
        adc     $00                             ; EC62
        sta     $7C                             ; EC64
        lda     $7D                             ; EC66
        adc     $01                             ; EC68
        sta     $7D                             ; EC6A
        jsr     LE17B                           ; EC6C
        .byte   $07                             ; EC6F
        asl     $A9                             ; EC70
        rti                                     ; EC72

; ----------------------------------------------------------------------------
        bne     LEC77                           ; EC73
        lda     #$80                            ; EC75
LEC77:  ora     $031C                           ; EC77
        sta     $031C                           ; EC7A
        rts                                     ; EC7D

; ----------------------------------------------------------------------------
        ldy     #$09                            ; EC7E
        lda     $32                             ; EC80
        bne     LECA8                           ; EC82
        lda     $28                             ; EC84
        bne     LEC90                           ; EC86
        lda     $0302                           ; EC88
        asl     a                               ; EC8B
        adc     $0302                           ; EC8C
        tay                                     ; EC8F
LEC90:  lda     LECF5,y                         ; EC90
        sta     $04B1                           ; EC93
        lda     LECF6,y                         ; EC96
        sta     $04B2                           ; EC99
        lda     LECF7,y                         ; EC9C
        sta     $04B3                           ; EC9F
        jsr     LECB0                           ; ECA2
        jmp     LECC1                           ; ECA5

; ----------------------------------------------------------------------------
LECA8:  asl     a                               ; ECA8
        adc     $32                             ; ECA9
        adc     #$09                            ; ECAB
        tay                                     ; ECAD
        bne     LEC90                           ; ECAE
LECB0:  lda     $BF                             ; ECB0
        bmi     LECC0                           ; ECB2
        lda     $19                             ; ECB4
        cmp     #$05                            ; ECB6
        beq     LECC0                           ; ECB8
        asl     $0338                           ; ECBA
        lsr     $0338                           ; ECBD
LECC0:  rts                                     ; ECC0

; ----------------------------------------------------------------------------
LECC1:  lda     $BE                             ; ECC1
        and     #$30                            ; ECC3
        beq     LECE3                           ; ECC5
LECC7:  lsr     a                               ; ECC7
        lsr     a                               ; ECC8
        lsr     a                               ; ECC9
        sta     $3B                             ; ECCA
        lsr     a                               ; ECCC
        adc     $3B                             ; ECCD
        tay                                     ; ECCF
        lda     LED37,y                         ; ECD0
        sta     $04B5                           ; ECD3
        lda     LED38,y                         ; ECD6
        sta     $04B6                           ; ECD9
        lda     LED39,y                         ; ECDC
        sta     $04B7                           ; ECDF
LECE2:  rts                                     ; ECE2

; ----------------------------------------------------------------------------
LECE3:  lda     $24                             ; ECE3
        beq     LECE2                           ; ECE5
        lda     $7F                             ; ECE7
        and     #$03                            ; ECE9
        bne     LECE2                           ; ECEB
        lda     $0334                           ; ECED
        .byte   $29                             ; ECF0
LECF1:  bmi     *+78                            ; ECF1
        .byte   $C7                             ; ECF3
        .byte   $EC                             ; ECF4
LECF5:  .byte   $27                             ; ECF5
LECF6:  .byte   $20                             ; ECF6
LECF7:  ora     ($27),y                         ; ECF7
        jsr     L2714                           ; ECF9
        jsr     L2716                           ; ECFC
        jsr     L2616                           ; ECFF
        jsr     L2616                           ; ED02
        jsr     L2806                           ; ED05
        jsr     L2116                           ; ED08
        jsr     L2601                           ; ED0B
        jsr     L2611                           ; ED0E
        jsr     L2906                           ; ED11
        jsr     L280A                           ; ED14
        jsr     L1616                           ; ED17
        jsr     L2706                           ; ED1A
        jsr     L1606                           ; ED1D
        jsr     L1001                           ; ED20
        jsr     L2616                           ; ED23
        jsr     L2011                           ; ED26
        bpl     LED2B                           ; ED29
LED2B:  brk                                     ; ED2B
        rti                                     ; ED2C

; ----------------------------------------------------------------------------
        brk                                     ; ED2D
        rti                                     ; ED2E

; ----------------------------------------------------------------------------
        .byte   $42                             ; ED2F
        ora     ($40,x)                         ; ED30
        rti                                     ; ED32

; ----------------------------------------------------------------------------
        brk                                     ; ED33
        rti                                     ; ED34

; ----------------------------------------------------------------------------
        cmp     ($80,x)                         ; ED35
LED37:  .byte   $C2                             ; ED37
LED38:  .byte   $43                             ; ED38
LED39:  .byte   $42                             ; ED39
        jsr     L2020                           ; ED3A
        ora     ($11),y                         ; ED3D
        ora     (L000F),y                       ; ED3F
        .byte   $0F                             ; ED41
        .byte   $0F                             ; ED42
LED43:  brk                                     ; ED43
LED44:  .byte   $14                             ; ED44
        ora     $14                             ; ED45
        ora     $06                             ; ED47
        .byte   $07                             ; ED49
        asl     $0908                           ; ED4A
        bpl     LED58                           ; ED4D
        ora     $0A06                           ; ED4F
        .byte   $14                             ; ED52
        .byte   $02                             ; ED53
        asl     $03                             ; ED54
        asl     $04                             ; ED56
LED58:  asl     $01                             ; ED58
        asl     $07                             ; ED5A
        asl     $0F07                           ; ED5C
        asl     a                               ; ED5F
        ora     ($0A),y                         ; ED60
        .byte   $12                             ; ED62
        asl     a                               ; ED63
        .byte   $13                             ; ED64
        .byte   $0C                             ; ED65
        ora     ($07),y                         ; ED66
        asl     $060B                           ; ED68
        ora     $12                             ; ED6B
        .byte   $07                             ; ED6D
        .byte   $0F                             ; ED6E
        ora     $11                             ; ED6F
        ora     $12                             ; ED71
        ora     $13                             ; ED73
        .byte   $07                             ; ED75
        .byte   $14                             ; ED76
        .byte   $0C                             ; ED77
        asl     $0A                             ; ED78
        ora     #$0C                            ; ED7A
        .byte   $13                             ; ED7C
        ora     $06                             ; ED7D
        .byte   $0B                             ; ED7F
        .byte   $14                             ; ED80
        brk                                     ; ED81
        .byte   $06                             ; ED82
LED83:  .byte   $02                             ; ED83
LED84:  and     #$23                            ; ED84
        brk                                     ; ED86
        rti                                     ; ED87

; ----------------------------------------------------------------------------
        bit     $4023                           ; ED88
        rti                                     ; ED8B

; ----------------------------------------------------------------------------
        bit     $8023                           ; ED8C
        rti                                     ; ED8F

; ----------------------------------------------------------------------------
        bit     LF023                           ; ED90
        bvc     LED95                           ; ED93
LED95:  brk                                     ; ED95
        brk                                     ; ED96
        brk                                     ; ED97
        brk                                     ; ED98
        brk                                     ; ED99
        brk                                     ; ED9A
        brk                                     ; ED9B
        brk                                     ; ED9C
        brk                                     ; ED9D
        brk                                     ; ED9E
        adc     ($29),y                         ; ED9F
        .byte   $42                             ; EDA1
        and     #$C0                            ; EDA2
        .byte   $23                             ; EDA4
        iny                                     ; EDA5
        .byte   $23                             ; EDA6
        bne     LEDCC                           ; EDA7
        cld                                     ; EDA9
        .byte   $23                             ; EDAA
        cpx     #$23                            ; EDAB
        inx                                     ; EDAD
        .byte   $23                             ; EDAE
        beq     LEDD4                           ; EDAF
        sed                                     ; EDB1
        .byte   $23                             ; EDB2
        ror     $AE22                           ; EDB3
        .byte   $22                             ; EDB6
        inc     $2E22                           ; EDB7
        .byte   $23                             ; EDBA
        ror     $22,x                           ; EDBB
        ldx     $22,y                           ; EDBD
        inc     $22,x                           ; EDBF
        .byte   $17                             ; EDC1
        and     ($02,x)                         ; EDC2
        and     #$23                            ; EDC4
        and     #$2C                            ; EDC6
        and     #$2D                            ; EDC8
        and     #$22                            ; EDCA
LEDCC:  and     #$43                            ; EDCC
        and     #$4C                            ; EDCE
        and     #$4D                            ; EDD0
        and     #$42                            ; EDD2
LEDD4:  and     #$6E                            ; EDD4
        and     #$67                            ; EDD6
        and     #$68                            ; EDD8
        and     #$69                            ; EDDA
        and     #$6A                            ; EDDC
        and     #$6C                            ; EDDE
        and     #$EB                            ; EDE0
        .byte   $22                             ; EDE2
        bcc     LEE05                           ; EDE3
        bcs     LEE07                           ; EDE5
        lda     ($20),y                         ; EDE7
        lda     $20,x                           ; EDE9
        .byte   $D7                             ; EDEB
        jsr     L20F0                           ; EDEC
        sbc     ($20),y                         ; EDEF
        sbc     $20,x                           ; EDF1
        .byte   $F7                             ; EDF3
        jsr     L2107                           ; EDF4
        bmi     LEE1A                           ; EDF7
        and     ($21),y                         ; EDF9
        .byte   $33                             ; EDFB
        and     ($35,x)                         ; EDFC
        and     ($47,x)                         ; EDFE
        and     ($71,x)                         ; EE00
        and     ($73,x)                         ; EE02
        .byte   $21                             ; EE04
LEE05:  adc     $21,x                           ; EE05
LEE07:  .byte   $87                             ; EE07
        and     ($B5,x)                         ; EE08
        and     ($B8,x)                         ; EE0A
        and     ($C7,x)                         ; EE0C
        and     ($F5,x)                         ; EE0E
        and     ($F8,x)                         ; EE10
        and     ($07,x)                         ; EE12
        .byte   $22                             ; EE14
        bvs     LEE37                           ; EE15
        bne     LEE39                           ; EE17
        .byte   $10                             ; EE19
LEE1A:  and     ($50,x)                         ; EE1A
        and     ($70,x)                         ; EE1C
        and     ($90,x)                         ; EE1E
        and     ($B0,x)                         ; EE20
        and     ($D0,x)                         ; EE22
        and     ($F0,x)                         ; EE24
        and     ($10,x)                         ; EE26
        .byte   $22                             ; EE28
        bmi     LEE4D                           ; EE29
        bvc     LEE4F                           ; EE2B
        bvs     LEE51                           ; EE2D
        bcc     LEE53                           ; EE2F
        sty     $20                             ; EE31
        .byte   $77                             ; EE33
        and     ($1A,x)                         ; EE34
        .byte   $21                             ; EE36
LEE37:  .byte   $7A                             ; EE37
        .byte   $21                             ; EE38
LEE39:  .byte   $63                             ; EE39
        .byte   $22                             ; EE3A
        .byte   $A3                             ; EE3B
        .byte   $22                             ; EE3C
        .byte   $E3                             ; EE3D
        .byte   $22                             ; EE3E
        .byte   $23                             ; EE3F
        .byte   $23                             ; EE40
        .byte   $6B                             ; EE41
        .byte   $22                             ; EE42
        .byte   $AB                             ; EE43
        .byte   $22                             ; EE44
LEE45:  .byte   $63                             ; EE45
LEE46:  ora     ($5B,x)                         ; EE46
        inc     LEE5C                           ; EE48
        adc     $EE                             ; EE4B
LEE4D:  ror     a                               ; EE4D
        .byte   $EE                             ; EE4E
LEE4F:  .byte   $6F                             ; EE4F
        .byte   $EE                             ; EE50
LEE51:  .byte   $77                             ; EE51
        .byte   $EE                             ; EE52
LEE53:  sei                                     ; EE53
        inc     LEE89                           ; EE54
        stx     $85EE                           ; EE57
        .byte   $ED                             ; EE5A
        brk                                     ; EE5B
LEE5C:  .byte   $23                             ; EE5C
        brk                                     ; EE5D
        rts                                     ; EE5E

; ----------------------------------------------------------------------------
        and     LF023                           ; EE5F
        pha                                     ; EE62
        .byte   $FF                             ; EE63
        brk                                     ; EE64
        .byte   $3F                             ; EE65
        brk                                     ; EE66
        rts                                     ; EE67

; ----------------------------------------------------------------------------
        .byte   $0F                             ; EE68
        brk                                     ; EE69
        .byte   $3F                             ; EE6A
        .byte   $04                             ; EE6B
        jmp     L000F                           ; EE6C

; ----------------------------------------------------------------------------
        .byte   $3F                             ; EE6F
        .byte   $04                             ; EE70
        eor     $3F15                           ; EE71
        .byte   $1A                             ; EE74
        ora     ($15,x)                         ; EE75
        brk                                     ; EE77
        ldy     #$0E                            ; EE78
        .byte   $42                             ; EE7A
        rol     $303B,x                         ; EE7B
        eor     ($2C,x)                         ; EE7E
        .byte   $34                             ; EE80
        .byte   $32                             ; EE81
        .byte   $3B                             ; EE82
        sec                                     ; EE83
        .byte   $3F                             ; EE84
        .byte   $42                             ; EE85
        .byte   $34                             ; EE86
        .byte   $2C                             ; EE87
        brk                                     ; EE88
LEE89:  and     #$00                            ; EE89
        rti                                     ; EE8B

; ----------------------------------------------------------------------------
        bit     $2900                           ; EE8C
        rti                                     ; EE8F

; ----------------------------------------------------------------------------
        rti                                     ; EE90

; ----------------------------------------------------------------------------
        bit     $8500                           ; EE91
        nop                                     ; EE94
        sty     $EC                             ; EE95
        lda     #$17                            ; EE97
        sta     $AD                             ; EE99
        lda     #$00                            ; EE9B
        sta     $AE                             ; EE9D
        lda     #$00                            ; EE9F
        sta     $AF                             ; EEA1
LEEA3:  lda     $AD                             ; EEA3
        ora     #$80                            ; EEA5
        sta     $AD                             ; EEA7
LEEA9:  jsr     LEEB3                           ; EEA9
        lda     $AD                             ; EEAC
        and     #$80                            ; EEAE
        bne     LEEA9                           ; EEB0
        rts                                     ; EEB2

; ----------------------------------------------------------------------------
LEEB3:  txa                                     ; EEB3
        pha                                     ; EEB4
        tya                                     ; EEB5
        pha                                     ; EEB6
        lda     $11                             ; EEB7
        and     #$18                            ; EEB9
        beq     LEED2                           ; EEBB
        jsr     LF74D                           ; EEBD
        lda     $031C                           ; EEC0
        and     #$C0                            ; EEC3
        beq     LEECA                           ; EEC5
        jsr     LEACA                           ; EEC7
LEECA:  jsr     LE95B                           ; EECA
LEECD:  pla                                     ; EECD
        tay                                     ; EECE
        pla                                     ; EECF
        tax                                     ; EED0
        rts                                     ; EED1

; ----------------------------------------------------------------------------
LEED2:  lda     $1C                             ; EED2
        and     #$0C                            ; EED4
        bne     LEECA                           ; EED6
        lda     $10                             ; EED8
        pha                                     ; EEDA
        and     #$7B                            ; EEDB
        sta     $10                             ; EEDD
        sta     PPU_CTRL                        ; EEDF
        jsr     LEEEE                           ; EEE2
        pla                                     ; EEE5
        sta     $10                             ; EEE6
        sta     PPU_CTRL                        ; EEE8
        jmp     LEECD                           ; EEEB

; ----------------------------------------------------------------------------
LEEEE:  lda     $AD                             ; EEEE
        bmi     LEEF5                           ; EEF0
        jmp     LE5B6                           ; EEF2

; ----------------------------------------------------------------------------
LEEF5:  and     #$7F                            ; EEF5
        sta     $AD                             ; EEF7
        jsr     LEF73                           ; EEF9
        lda     $AE                             ; EEFC
        clc                                     ; EEFE
        adc     $EA                             ; EEFF
        pha                                     ; EF01
        lda     $AF                             ; EF02
        adc     #$00                            ; EF04
        sta     PPU_ADDR                        ; EF06
        pla                                     ; EF09
        sta     PPU_ADDR                        ; EF0A
        lda     PPU_DATA                        ; EF0D
        lda     PPU_DATA                        ; EF10
        sta     $E8                             ; EF13
        lda     PPU_DATA                        ; EF15
        sta     $E9                             ; EF18
        lda     $EC                             ; EF1A
        asl     a                               ; EF1C
        bcc     LEF21                           ; EF1D
        inc     $E9                             ; EF1F
LEF21:  clc                                     ; EF21
        adc     $E8                             ; EF22
        sta     $E8                             ; EF24
        lda     $E9                             ; EF26
        adc     #$00                            ; EF28
        sta     $E9                             ; EF2A
        lsr     a                               ; EF2C
        lsr     a                               ; EF2D
        lsr     a                               ; EF2E
        lsr     a                               ; EF2F
        clc                                     ; EF30
        adc     $AD                             ; EF31
        jsr     LEF73                           ; EF33
        lda     $E9                             ; EF36
        and     #$0F                            ; EF38
        sta     PPU_ADDR                        ; EF3A
        lda     $E8                             ; EF3D
        sta     PPU_ADDR                        ; EF3F
        lda     PPU_DATA                        ; EF42
        lda     PPU_DATA                        ; EF45
        sta     $ED                             ; EF48
        lda     PPU_DATA                        ; EF4A
        sta     $EE                             ; EF4D
        lda     $1C                             ; EF4F
        ora     #$10                            ; EF51
        sta     $1C                             ; EF53
        lda     $18                             ; EF55
        bpl     LEF61                           ; EF57
        lda     $EE                             ; EF59
        bpl     LEF62                           ; EF5B
        lda     #$00                            ; EF5D
        sta     $18                             ; EF5F
LEF61:  rts                                     ; EF61

; ----------------------------------------------------------------------------
LEF62:  sta     $E9                             ; EF62
        lda     $ED                             ; EF64
        sta     $E8                             ; EF66
        lda     $AD                             ; EF68
        ora     #$E0                            ; EF6A
        sta     $EA                             ; EF6C
        lda     #$01                            ; EF6E
        sta     $EC                             ; EF70
        rts                                     ; EF72

; ----------------------------------------------------------------------------
LEF73:  pha                                     ; EF73
        jsr     LE56E                           ; EF74
        pla                                     ; EF77
        clc                                     ; EF78
        adc     #$01                            ; EF79
        jmp     LE582                           ; EF7B

; ----------------------------------------------------------------------------
LEF7E:  php                                     ; EF7E
        lda     $EA                             ; EF7F
        and     #$20                            ; EF81
        beq     LEF9F                           ; EF83
        lda     $E9                             ; EF85
        lsr     a                               ; EF87
        lsr     a                               ; EF88
        lsr     a                               ; EF89
        lsr     a                               ; EF8A
        and     #$03                            ; EF8B
        clc                                     ; EF8D
        adc     $EA                             ; EF8E
        sta     $EA                             ; EF90
        and     #$1F                            ; EF92
        jsr     LEF73                           ; EF94
        lda     $E9                             ; EF97
        and     #$CF                            ; EF99
        sta     $E9                             ; EF9B
        plp                                     ; EF9D
        rts                                     ; EF9E

; ----------------------------------------------------------------------------
LEF9F:  lda     $EA                             ; EF9F
        and     #$07                            ; EFA1
        jsr     LE596                           ; EFA3
        plp                                     ; EFA6
        rts                                     ; EFA7

; ----------------------------------------------------------------------------
LEFA8:  lda     $18                             ; EFA8
        bpl     LEFB2                           ; EFAA
        lda     $EA                             ; EFAC
        and     #$20                            ; EFAE
        bne     LEFB5                           ; EFB0
LEFB2:  lda     ($E8),y                         ; EFB2
        rts                                     ; EFB4

; ----------------------------------------------------------------------------
LEFB5:  tya                                     ; EFB5
        clc                                     ; EFB6
        adc     $E8                             ; EFB7
        pha                                     ; EFB9
        lda     $E9                             ; EFBA
        adc     #$00                            ; EFBC
        and     #$3F                            ; EFBE
        sta     PPU_ADDR                        ; EFC0
        pla                                     ; EFC3
        sta     PPU_ADDR                        ; EFC4
        lda     PPU_DATA                        ; EFC7
        lda     PPU_DATA                        ; EFCA
        rts                                     ; EFCD

; ----------------------------------------------------------------------------
LEFCE:  lda     $68                             ; EFCE
        beq     LEFDF                           ; EFD0
        ldx     $DF                             ; EFD2
        cpx     #$2D                            ; EFD4
        bne     LEFE2                           ; EFD6
        lda     $DE                             ; EFD8
        beq     LEFF0                           ; EFDA
        dec     $DE                             ; EFDC
        rts                                     ; EFDE

; ----------------------------------------------------------------------------
LEFDF:  jmp     LE662                           ; EFDF

; ----------------------------------------------------------------------------
LEFE2:  cpx     #$2F                            ; EFE2
        beq     LEFEA                           ; EFE4
        cpx     #$7F                            ; EFE6
        bne     LEFDF                           ; EFE8
LEFEA:  lda     $C2                             ; EFEA
        and     #$03                            ; EFEC
        beq     LF00A                           ; EFEE
LEFF0:  lda     #$00                            ; EFF0
        sta     $D9                             ; EFF2
        cpx     #$7F                            ; EFF4
        beq     LF007                           ; EFF6
        lda     $EA                             ; EFF8
        and     #$20                            ; EFFA
        beq     LF039                           ; EFFC
        bit     $E9                             ; EFFE
        bvs     LF039                           ; F000
        lda     #$08                            ; F002
        sta     $18                             ; F004
        rts                                     ; F006

; ----------------------------------------------------------------------------
LF007:  jmp     LE692                           ; F007

; ----------------------------------------------------------------------------
LF00A:  lda     $60                             ; F00A
        beq     LF017                           ; F00C
        lda     #$23                            ; F00E
        sta     PPU_ADDR                        ; F010
        lda     #$7C                            ; F013
        bne     LF01E                           ; F015
LF017:  lda     #$29                            ; F017
        sta     PPU_ADDR                        ; F019
        lda     #$5C                            ; F01C
LF01E:  sta     PPU_ADDR                        ; F01E
        ldx     #$7F                            ; F021
LF023:  lda     $1E                             ; F023
        and     #$08                            ; F025
        beq     LF02B                           ; F027
        ldx     #$2C                            ; F029
LF02B:  stx     PPU_DATA                        ; F02B
        rts                                     ; F02E

; ----------------------------------------------------------------------------
LF02F:  lda     $18                             ; F02F
        bne     LF042                           ; F031
        sta     $0162                           ; F033
        sta     $0163                           ; F036
LF039:  lda     #$00                            ; F039
        sta     $18                             ; F03B
        sta     $68                             ; F03D
        sta     $D9                             ; F03F
        rts                                     ; F041

; ----------------------------------------------------------------------------
LF042:  cmp     #$08                            ; F042
        bne     LF049                           ; F044
        inc     $18                             ; F046
        rts                                     ; F048

; ----------------------------------------------------------------------------
LF049:  cmp     #$09                            ; F049
        bne     LF039                           ; F04B
        lda     $68                             ; F04D
        bpl     LF056                           ; F04F
        sta     $18                             ; F051
        lsr     $68                             ; F053
        rts                                     ; F055

; ----------------------------------------------------------------------------
LF056:  asl     a                               ; F056
        bpl     LF039                           ; F057
        lda     $031C                           ; F059
        ora     #$0F                            ; F05C
        sta     $031C                           ; F05E
        jsr     LE85D                           ; F061
        bne     LF039                           ; F064
        .byte   $FF                             ; F066
        ldy     #$1F                            ; F067
LF069:  sec                                     ; F069
        lda     $04A0,y                         ; F06A
        sbc     #$10                            ; F06D
        beq     LF075                           ; F06F
        bcs     LF075                           ; F071
        lda     #$0F                            ; F073
LF075:  sta     $04A0,y                         ; F075
        dey                                     ; F078
        bpl     LF069                           ; F079
LF07B:  lda     $1C                             ; F07B
        ora     #$04                            ; F07D
        sta     $1C                             ; F07F
        rts                                     ; F081

; ----------------------------------------------------------------------------
        jsr     LE080                           ; F082
        ldy     #$0B                            ; F085
LF087:  sec                                     ; F087
        lda     $04A4,y                         ; F088
        sbc     #$10                            ; F08B
        beq     LF093                           ; F08D
        bcs     LF093                           ; F08F
        lda     #$0F                            ; F091
LF093:  sta     $04A4,y                         ; F093
        dey                                     ; F096
        bpl     LF087                           ; F097
        bmi     LF07B                           ; F099
LF09B:  lda     #$03                            ; F09B
        sta     $18                             ; F09D
        jsr     LE95B                           ; F09F
        jsr     LE5B2                           ; F0A2
        jmp     LF07B                           ; F0A5

; ----------------------------------------------------------------------------
LF0A8:  lda     $67                             ; F0A8
        bpl     LF0AF                           ; F0AA
        jsr     LF6DE                           ; F0AC
LF0AF:  jmp     LE8EF                           ; F0AF

; ----------------------------------------------------------------------------
        jsr     LE09C                           ; F0B2
        jsr     LF0A8                           ; F0B5
        jsr     LEACA                           ; F0B8
        jmp     LE95B                           ; F0BB

; ----------------------------------------------------------------------------
        pha                                     ; F0BE
        lda     $0601,x                         ; F0BF
        and     #$F0                            ; F0C2
        sta     $0601,x                         ; F0C4
        pla                                     ; F0C7
        ora     $0601,x                         ; F0C8
        sta     $0601,x                         ; F0CB
        rts                                     ; F0CE

; ----------------------------------------------------------------------------
LF0CF:  lda     $0322                           ; F0CF
        beq     LF0DB                           ; F0D2
        lda     $92                             ; F0D4
        bne     LF0DC                           ; F0D6
        lda     $0322                           ; F0D8
LF0DB:  rts                                     ; F0DB

; ----------------------------------------------------------------------------
LF0DC:  cmp     #$01                            ; F0DC
        bne     LF0EA                           ; F0DE
        lda     $0322                           ; F0E0
        cmp     #$05                            ; F0E3
        bcc     LF0EA                           ; F0E5
        lda     #$05                            ; F0E7
        rts                                     ; F0E9

; ----------------------------------------------------------------------------
LF0EA:  lda     #$01                            ; F0EA
        rts                                     ; F0EC

; ----------------------------------------------------------------------------
        lda     $030E                           ; F0ED
        beq     LF0DB                           ; F0F0
        lda     $92                             ; F0F2
        cmp     #$02                            ; F0F4
        bne     LF0FC                           ; F0F6
        lda     $030E                           ; F0F8
        rts                                     ; F0FB

; ----------------------------------------------------------------------------
LF0FC:  lda     #$01                            ; F0FC
        rts                                     ; F0FE

; ----------------------------------------------------------------------------
LF0FF:  jsr     LE9EB                           ; F0FF
        asl     $BF                             ; F102
        lsr     $BF                             ; F104
        rts                                     ; F106

; ----------------------------------------------------------------------------
        .byte   $FF                             ; F107
        .byte   $FF                             ; F108
        .byte   $FF                             ; F109
        pha                                     ; F10A
        jsr     LE89D                           ; F10B
        lda     #$FF                            ; F10E
        jsr     LE992                           ; F110
        lda     #$81                            ; F113
        jsr     LF0FF                           ; F115
        pla                                     ; F118
        jmp     LE096                           ; F119

; ----------------------------------------------------------------------------
        ldy     $31                             ; F11C
        bne     LF124                           ; F11E
        ldy     #$38                            ; F120
        sty     $31                             ; F122
LF124:  lda     $0601,y                         ; F124
        bne     LF144                           ; F127
        sty     $31                             ; F129
        sta     $0606,y                         ; F12B
        sta     $0607,y                         ; F12E
        tya                                     ; F131
        pha                                     ; F132
LF133:  lda     #$00                            ; F133
        sta     $0700,y                         ; F135
        iny                                     ; F138
        tya                                     ; F139
        and     #$07                            ; F13A
        bne     LF133                           ; F13C
        pla                                     ; F13E
        tay                                     ; F13F
        lda     #$00                            ; F140
        rts                                     ; F142

; ----------------------------------------------------------------------------
        nop                                     ; F143
LF144:  tya                                     ; F144
        clc                                     ; F145
        adc     #$08                            ; F146
        tay                                     ; F148
        bne     LF14D                           ; F149
        ldy     #$38                            ; F14B
LF14D:  cmp     $31                             ; F14D
        bne     LF124                           ; F14F
        ldy     #$38                            ; F151
        rts                                     ; F153

; ----------------------------------------------------------------------------
        ldy     #$38                            ; F154
LF156:  lda     $0601,y                         ; F156
        beq     LF16B                           ; F159
        lda     $0600,y                         ; F15B
        cmp     #$0D                            ; F15E
        beq     LF166                           ; F160
        cmp     #$0E                            ; F162
        bne     LF16B                           ; F164
LF166:  lda     #$00                            ; F166
        sta     $0601,y                         ; F168
LF16B:  clc                                     ; F16B
        tya                                     ; F16C
        adc     #$08                            ; F16D
        tay                                     ; F16F
        bne     LF156                           ; F170
        sta     $0619                           ; F172
        sta     $0621                           ; F175
        sta     $0629                           ; F178
        sta     $0631                           ; F17B
        rts                                     ; F17E

; ----------------------------------------------------------------------------
LF17F:  lda     $BE                             ; F17F
        and     #$30                            ; F181
        beq     LF1B4                           ; F183
        lda     $0338                           ; F185
        beq     LF1B4                           ; F188
        bmi     LF1B4                           ; F18A
        lda     $03C6                           ; F18C
        beq     LF1B4                           ; F18F
        lda     $0611                           ; F191
        bne     LF1B4                           ; F194
        lda     #$06                            ; F196
        sta     $0610                           ; F198
        lda     #$13                            ; F19B
        sta     $0611                           ; F19D
        lda     #$60                            ; F1A0
        sta     $0612                           ; F1A2
        lda     #$80                            ; F1A5
        sta     $0613                           ; F1A7
        lda     #$00                            ; F1AA
        sta     $0710                           ; F1AC
        ldx     #$10                            ; F1AF
        jsr     LE0A4                           ; F1B1
LF1B4:  lda     $30                             ; F1B4
        beq     LF1BB                           ; F1B6
        jsr     LF1C0                           ; F1B8
LF1BB:  rts                                     ; F1BB

; ----------------------------------------------------------------------------
        jsr     LF1C0                           ; F1BC
        rts                                     ; F1BF

; ----------------------------------------------------------------------------
LF1C0:  cmp     #$0B                            ; F1C0
        bcs     LF1C7                           ; F1C2
        jsr     LE898                           ; F1C4
LF1C7:  lda     $30                             ; F1C7
        ldy     #$00                            ; F1C9
        sty     $30                             ; F1CB
        jsr     LE97D                           ; F1CD
        cpx     LECF1                           ; F1D0
        sbc     ($EC),y                         ; F1D3
        sbc     ($EC),y                         ; F1D5
        sbc     ($EC),y                         ; F1D7
        sbc     ($EC),y                         ; F1D9
        sbc     ($EC),y                         ; F1DB
        sbc     ($0E),y                         ; F1DD
        sbc     ($EC,x)                         ; F1DF
        sbc     ($EC),y                         ; F1E1
        sbc     ($EC),y                         ; F1E3
        sbc     ($02),y                         ; F1E5
        sbc     ($E2,x)                         ; F1E7
        cpx     #$EC                            ; F1E9
        .byte   $F1                             ; F1EB
LF1EC:  rts                                     ; F1EC

; ----------------------------------------------------------------------------
LF1ED:  lda     $0600                           ; F1ED
        and     #$7F                            ; F1F0
        cmp     #$03                            ; F1F2
        bcs     LF1EC                           ; F1F4
        lda     $81                             ; F1F6
        bne     LF20E                           ; F1F8
        lda     $0306                           ; F1FA
        beq     LF220                           ; F1FD
        dec     $0306                           ; F1FF
        lda     #$32                            ; F202
        sta     $81                             ; F204
        lda     #$1A                            ; F206
        jsr     LE992                           ; F208
        jsr     LEAB9                           ; F20B
LF20E:  lda     $7F                             ; F20E
        and     #$0F                            ; F210
        bne     LF21F                           ; F212
        lda     $81                             ; F214
        cmp     #$0A                            ; F216
        bcs     LF21F                           ; F218
        lda     #$4C                            ; F21A
        jsr     LE992                           ; F21C
LF21F:  rts                                     ; F21F

; ----------------------------------------------------------------------------
LF220:  lda     #$05                            ; F220
        sta     $0600                           ; F222
        sta     $0610                           ; F225
        lda     #$19                            ; F228
        sta     $0601                           ; F22A
        lda     #$1A                            ; F22D
        sta     $0611                           ; F22F
        ldx     #$00                            ; F232
        jsr     LE0A4                           ; F234
        ldx     #$10                            ; F237
        jsr     LE0A4                           ; F239
        lda     #$00                            ; F23C
        sta     $1E                             ; F23E
        lda     #$C8                            ; F240
        sta     $0700                           ; F242
        lda     #$09                            ; F245
        jmp     LE992                           ; F247

; ----------------------------------------------------------------------------
LF24A:  lda     $1C                             ; F24A
        bpl     LF252                           ; F24C
        and     #$7F                            ; F24E
        sta     $1C                             ; F250
LF252:  lda     $1C                             ; F252
        bpl     LF252                           ; F254
        asl     a                               ; F256
        rts                                     ; F257

; ----------------------------------------------------------------------------
        nop                                     ; F258
LF259:  lda     $6A                             ; F259
        beq     LF264                           ; F25B
        lda     $0200                           ; F25D
        eor     #$BF                            ; F260
        beq     LF266                           ; F262
LF264:  pla                                     ; F264
        pla                                     ; F265
LF266:  rts                                     ; F266

; ----------------------------------------------------------------------------
        clc                                     ; F267
        bne     LF26D                           ; F268
        jmp     LF83C                           ; F26A

; ----------------------------------------------------------------------------
LF26D:  rts                                     ; F26D

; ----------------------------------------------------------------------------
        .byte   $9B                             ; F26E
        sbc     $A0                             ; F26F
        ora     $D0                             ; F271
        asl     $A0                             ; F273
        asl     $D0                             ; F275
        .byte   $02                             ; F277
        ldy     #$07                            ; F278
        lda     $0335,y                         ; F27A
        beq     LF2A9                           ; F27D
        bmi     LF2A9                           ; F27F
        lda     $0611                           ; F281
        bne     LF2A9                           ; F284
        lda     #$06                            ; F286
        sta     $0610                           ; F288
        tya                                     ; F28B
        ora     #$10                            ; F28C
        sta     $0611                           ; F28E
        lda     #$60                            ; F291
        sta     $0612                           ; F293
        lda     #$80                            ; F296
        sta     $0613                           ; F298
        lda     #$00                            ; F29B
        sta     $0710                           ; F29D
        txa                                     ; F2A0
        pha                                     ; F2A1
        ldx     #$10                            ; F2A2
        jsr     LE0A4                           ; F2A4
        pla                                     ; F2A7
        tax                                     ; F2A8
LF2A9:  rts                                     ; F2A9

; ----------------------------------------------------------------------------
LF2AA:  lda     $C3                             ; F2AA
        beq     LF2A9                           ; F2AC
        lda     $BF                             ; F2AE
        and     #$20                            ; F2B0
        bne     LF2A9                           ; F2B2
        lda     #$03                            ; F2B4
        jsr     LE096                           ; F2B6
        jmp     LE110                           ; F2B9

; ----------------------------------------------------------------------------
LF2BC:  lda     #$00                            ; F2BC
        sta     $19                             ; F2BE
        sta     $1A                             ; F2C0
LF2C2:  sta     $60                             ; F2C2
        rts                                     ; F2C4

; ----------------------------------------------------------------------------
        .byte   $E1                             ; F2C5
LF2C6:  lda     $0308                           ; F2C6
        beq     LF2D9                           ; F2C9
        dec     $0308                           ; F2CB
        jsr     LEBB8                           ; F2CE
        jsr     LEAC1                           ; F2D1
        lda     #$03                            ; F2D4
        jsr     LE992                           ; F2D6
LF2D9:  rts                                     ; F2D9

; ----------------------------------------------------------------------------
LF2DA:  lda     $A4                             ; F2DA
        sta     $70                             ; F2DC
        clc                                     ; F2DE
        lda     $03F4                           ; F2DF
        adc     $03F5                           ; F2E2
        tay                                     ; F2E5
        lda     LF366,y                         ; F2E6
        sta     $70                             ; F2E9
        lda     LF367,y                         ; F2EB
        sta     $03F3                           ; F2EE
        iny                                     ; F2F1
        iny                                     ; F2F2
        tya                                     ; F2F3
        and     #$07                            ; F2F4
        sta     $03F5                           ; F2F6
        and     #$03                            ; F2F9
        bne     LF300                           ; F2FB
        inc     $03F1                           ; F2FD
LF300:  rts                                     ; F300

; ----------------------------------------------------------------------------
        jsr     LF758                           ; F301
        lda     $7F                             ; F304
        and     #$07                            ; F306
        bne     LF300                           ; F308
        dec     $03F3                           ; F30A
        bmi     LF311                           ; F30D
        bne     LF350                           ; F30F
LF311:  lda     $03F6                           ; F311
        beq     LF333                           ; F314
        ldy     $03F4                           ; F316
        cpy     #$10                            ; F319
        bcc     LF321                           ; F31B
        cmp     #$05                            ; F31D
        bcc     LF350                           ; F31F
LF321:  cmp     #$03                            ; F321
        bcc     LF342                           ; F323
        lda     $03F4                           ; F325
        beq     LF342                           ; F328
        sec                                     ; F32A
        sbc     #$08                            ; F32B
        sta     $03F4                           ; F32D
        jmp     LF342                           ; F330

; ----------------------------------------------------------------------------
LF333:  lda     $03F4                           ; F333
        clc                                     ; F336
        adc     #$08                            ; F337
        cmp     #$30                            ; F339
        bne     LF33F                           ; F33B
        lda     #$10                            ; F33D
LF33F:  sta     $03F4                           ; F33F
LF342:  lda     #$00                            ; F342
        sta     $03F6                           ; F344
        sta     $03F1                           ; F347
        sta     $03F2                           ; F34A
        jmp     LF2DA                           ; F34D

; ----------------------------------------------------------------------------
LF350:  lda     $03F4                           ; F350
        cmp     #$10                            ; F353
        bcc     LF365                           ; F355
        lda     $03F2                           ; F357
        cmp     #$0A                            ; F35A
        bcs     LF333                           ; F35C
        lda     $03F1                           ; F35E
        cmp     #$05                            ; F361
        bcs     LF333                           ; F363
LF365:  rts                                     ; F365

; ----------------------------------------------------------------------------
LF366:  .byte   $0C                             ; F366
LF367:  .byte   $4B                             ; F367
        .byte   $0C                             ; F368
        .byte   $4B                             ; F369
        .byte   $0C                             ; F36A
LF36B:  .byte   $4B                             ; F36B
        .byte   $0C                             ; F36C
        .byte   $4B                             ; F36D
        bpl     LF3BB                           ; F36E
        bpl     LF3BD                           ; F370
        bpl     LF3BF                           ; F372
        bpl     LF3C1                           ; F374
        .byte   $14                             ; F376
        .byte   $4B                             ; F377
        clc                                     ; F378
        rol     $14                             ; F379
        .byte   $4B                             ; F37B
        clc                                     ; F37C
        rol     $14                             ; F37D
        .byte   $4B                             ; F37F
        clc                                     ; F380
        .byte   $4B                             ; F381
        .byte   $14                             ; F382
        .byte   $4B                             ; F383
        clc                                     ; F384
        .byte   $4B                             ; F385
        .byte   $14                             ; F386
        .byte   $4B                             ; F387
        clc                                     ; F388
        adc     ($14),y                         ; F389
        .byte   $4B                             ; F38B
        clc                                     ; F38C
        adc     ($14),y                         ; F38D
        .byte   $4B                             ; F38F
        clc                                     ; F390
        stx     $14,y                           ; F391
        .byte   $4B                             ; F393
        clc                                     ; F394
        .byte   $96                             ; F395
LF396:  ldy     #$00                            ; F396
        lda     $0607                           ; F398
        sta     $CB                             ; F39B
        lda     $32                             ; F39D
        beq     LF3A8                           ; F39F
        asl     a                               ; F3A1
        asl     a                               ; F3A2
        adc     #$20                            ; F3A3
        tay                                     ; F3A5
        bne     LF3C3                           ; F3A6
LF3A8:  lda     $CB                             ; F3A8
        bpl     LF3C3                           ; F3AA
        lda     $0601                           ; F3AC
LF3AF:  iny                                     ; F3AF
        asl     a                               ; F3B0
        bcc     LF3AF                           ; F3B1
        tya                                     ; F3B3
        asl     a                               ; F3B4
        asl     a                               ; F3B5
        tay                                     ; F3B6
        jsr     LF0CF                           ; F3B7
        .byte   $C9                             ; F3BA
LF3BB:  ora     $90                             ; F3BB
LF3BD:  ora     $18                             ; F3BD
LF3BF:  tya                                     ; F3BF
        .byte   $69                             ; F3C0
LF3C1:  bpl     LF36B                           ; F3C1
LF3C3:  clc                                     ; F3C3
        lda     $0602                           ; F3C4
        adc     LF56B,y                         ; F3C7
        sta     $CD                             ; F3CA
        clc                                     ; F3CC
        lda     $0603                           ; F3CD
        adc     LF56C,y                         ; F3D0
        sta     $CC                             ; F3D3
        lda     LF56D,y                         ; F3D5
        sta     $CF                             ; F3D8
        lda     LF56E,y                         ; F3DA
        sta     $CE                             ; F3DD
        rts                                     ; F3DF

; ----------------------------------------------------------------------------
        jsr     LF510                           ; F3E0
        txa                                     ; F3E3
        lsr     a                               ; F3E4
        lsr     a                               ; F3E5
        lsr     a                               ; F3E6
        eor     $7F                             ; F3E7
        and     #$01                            ; F3E9
        bne     LF3FF                           ; F3EB
        jsr     LF41D                           ; F3ED
        bne     LF3FE                           ; F3F0
        lda     $0600                           ; F3F2
        and     #$7F                            ; F3F5
        cmp     #$03                            ; F3F7
        bcs     LF3FF                           ; F3F9
        jmp     LF46B                           ; F3FB

; ----------------------------------------------------------------------------
LF3FE:  rts                                     ; F3FE

; ----------------------------------------------------------------------------
LF3FF:  lda     $CC                             ; F3FF
        sta     $09                             ; F401
        lda     $CD                             ; F403
        sta     $0A                             ; F405
        jsr     LF53C                           ; F407
LF40A:  lda     #$00                            ; F40A
        rts                                     ; F40C

; ----------------------------------------------------------------------------
        lda     $29                             ; F40D
        bne     LF40A                           ; F40F
        lda     $0600                           ; F411
        and     #$7F                            ; F414
        cmp     #$03                            ; F416
        bcs     LF40A                           ; F418
        jmp     LF4B9                           ; F41A

; ----------------------------------------------------------------------------
LF41D:  ldy     #$18                            ; F41D
LF41F:  lda     $0601,y                         ; F41F
        bne     LF430                           ; F422
LF424:  tya                                     ; F424
        clc                                     ; F425
        adc     #$08                            ; F426
        tay                                     ; F428
        cpy     #$38                            ; F429
        bne     LF41F                           ; F42B
        lda     #$00                            ; F42D
        rts                                     ; F42F

; ----------------------------------------------------------------------------
LF430:  lda     $0602,y                         ; F430
        sta     $0A                             ; F433
        lda     $0603,y                         ; F435
        sta     $09                             ; F438
        jsr     LF53C                           ; F43A
        clc                                     ; F43D
        lda     $0E                             ; F43E
        adc     #$04                            ; F440
        cmp     $09                             ; F442
        bcc     LF424                           ; F444
        clc                                     ; F446
        lda     L000F                           ; F447
        adc     #$04                            ; F449
        cmp     $0A                             ; F44B
        bcc     LF424                           ; F44D
        lda     $0B                             ; F44F
        bmi     LF456                           ; F451
LF453:  lda     #$01                            ; F453
        rts                                     ; F455

; ----------------------------------------------------------------------------
LF456:  lda     $0601,x                         ; F456
        and     $08                             ; F459
        ora     $0601,y                         ; F45B
        and     #$F0                            ; F45E
        cmp     #$30                            ; F460
        beq     LF468                           ; F462
        cmp     #$C0                            ; F464
        bne     LF453                           ; F466
LF468:  lda     #$02                            ; F468
        rts                                     ; F46A

; ----------------------------------------------------------------------------
LF46B:  lda     $CC                             ; F46B
        sta     $09                             ; F46D
        lda     $CD                             ; F46F
        sta     $0A                             ; F471
        jsr     LF53C                           ; F473
        clc                                     ; F476
        lda     $0E                             ; F477
        adc     $CE                             ; F479
        cmp     $09                             ; F47B
        bcc     LF488                           ; F47D
        clc                                     ; F47F
        lda     L000F                           ; F480
        adc     $CF                             ; F482
        cmp     $0A                             ; F484
        bcs     LF48B                           ; F486
LF488:  lda     #$00                            ; F488
        rts                                     ; F48A

; ----------------------------------------------------------------------------
LF48B:  lda     $CB                             ; F48B
        bpl     LF4A8                           ; F48D
        lda     $0601                           ; F48F
        and     #$F0                            ; F492
        lsr     a                               ; F494
        sta     $00                             ; F495
        and     #$50                            ; F497
        bne     LF49F                           ; F499
        asl     $00                             ; F49B
        asl     $00                             ; F49D
LF49F:  lda     $08                             ; F49F
        and     $00                             ; F4A1
        beq     LF4A8                           ; F4A3
        lda     #$04                            ; F4A5
        rts                                     ; F4A7

; ----------------------------------------------------------------------------
LF4A8:  lda     $0600                           ; F4A8
        and     #$7F                            ; F4AB
        bne     LF4B6                           ; F4AD
        lda     $0707                           ; F4AF
        and     #$40                            ; F4B2
        bne     LF488                           ; F4B4
LF4B6:  lda     #$80                            ; F4B6
        rts                                     ; F4B8

; ----------------------------------------------------------------------------
LF4B9:  lda     $CC                             ; F4B9
        sta     $09                             ; F4BB
        lda     $CD                             ; F4BD
        sta     $0A                             ; F4BF
        jsr     LF53C                           ; F4C1
        clc                                     ; F4C4
        lda     #$04                            ; F4C5
        adc     $CE                             ; F4C7
        cmp     $09                             ; F4C9
        bcc     LF4D6                           ; F4CB
        clc                                     ; F4CD
        lda     #$04                            ; F4CE
        adc     $CF                             ; F4D0
        cmp     $0A                             ; F4D2
        bcs     LF4D9                           ; F4D4
LF4D6:  lda     #$00                            ; F4D6
        rts                                     ; F4D8

; ----------------------------------------------------------------------------
LF4D9:  lda     $CB                             ; F4D9
        bmi     LF4E3                           ; F4DB
        lda     $92                             ; F4DD
        cmp     #$01                            ; F4DF
        bne     LF4FF                           ; F4E1
LF4E3:  lda     $0601                           ; F4E3
        and     #$F0                            ; F4E6
        lsr     a                               ; F4E8
        sta     $00                             ; F4E9
        and     #$50                            ; F4EB
        bne     LF4F3                           ; F4ED
        asl     $00                             ; F4EF
        asl     $00                             ; F4F1
LF4F3:  lda     $08                             ; F4F3
        and     $0601,x                         ; F4F5
        and     $00                             ; F4F8
        beq     LF4FF                           ; F4FA
        lda     #$10                            ; F4FC
        rts                                     ; F4FE

; ----------------------------------------------------------------------------
LF4FF:  lda     $0600                           ; F4FF
        and     #$7F                            ; F502
        bne     LF50D                           ; F504
        lda     $0707                           ; F506
        and     #$40                            ; F509
        bne     LF4D6                           ; F50B
LF50D:  lda     #$20                            ; F50D
        rts                                     ; F50F

; ----------------------------------------------------------------------------
LF510:  lda     $0600,x                         ; F510
        and     #$7F                            ; F513
        tay                                     ; F515
        lda     LF5CB,y                         ; F516
        tay                                     ; F519
        lda     $0607,x                         ; F51A
        sta     $0B                             ; F51D
        clc                                     ; F51F
        lda     $0602,x                         ; F520
        adc     LF60B,y                         ; F523
        sta     $0D                             ; F526
        clc                                     ; F528
        lda     $0603,x                         ; F529
        adc     LF60C,y                         ; F52C
        sta     $0C                             ; F52F
        lda     LF60D,y                         ; F531
        sta     L000F                           ; F534
        lda     LF60E,y                         ; F536
        sta     $0E                             ; F539
        rts                                     ; F53B

; ----------------------------------------------------------------------------
LF53C:  lda     #$20                            ; F53C
        sta     $08                             ; F53E
        sec                                     ; F540
        lda     $0A                             ; F541
        sbc     $0D                             ; F543
        sta     $0A                             ; F545
        bcs     LF551                           ; F547
        eor     #$FF                            ; F549
        adc     #$01                            ; F54B
        sta     $0A                             ; F54D
        lsr     $08                             ; F54F
LF551:  sec                                     ; F551
        lda     $09                             ; F552
        sbc     $0C                             ; F554
        sta     $09                             ; F556
        lda     #$80                            ; F558
        bcs     LF566                           ; F55A
        lda     $09                             ; F55C
        eor     #$FF                            ; F55E
        adc     #$01                            ; F560
        sta     $09                             ; F562
        lda     #$40                            ; F564
LF566:  ora     $08                             ; F566
        sta     $08                             ; F568
        rts                                     ; F56A

; ----------------------------------------------------------------------------
LF56B:  .byte   $FC                             ; F56B
LF56C:  brk                                     ; F56C
LF56D:  asl     a                               ; F56D
LF56E:  asl     L00FC                           ; F56E
        php                                     ; F570
        bpl     LF57B                           ; F571
        .byte   $FC                             ; F573
        sed                                     ; F574
        bpl     LF57F                           ; F575
        php                                     ; F577
        brk                                     ; F578
        php                                     ; F579
        .byte   $10                             ; F57A
LF57B:  .byte   $F4                             ; F57B
LF57C:  brk                                     ; F57C
        .byte   $0C                             ; F57D
        .byte   $10                             ; F57E
LF57F:  .byte   $FC                             ; F57F
        .byte   $0C                             ; F580
        bpl     LF58F                           ; F581
        .byte   $FC                             ; F583
        .byte   $F4                             ; F584
        bpl     LF593                           ; F585
        .byte   $0C                             ; F587
        brk                                     ; F588
        .byte   $0C                             ; F589
        bpl     LF57C                           ; F58A
        brk                                     ; F58C
        .byte   $0C                             ; F58D
        .byte   $10                             ; F58E
LF58F:  brk                                     ; F58F
        brk                                     ; F590
        asl     $06                             ; F591
LF593:  brk                                     ; F593
        brk                                     ; F594
        asl     $06                             ; F595
        brk                                     ; F597
        brk                                     ; F598
        asl     $06                             ; F599
        brk                                     ; F59B
        brk                                     ; F59C
        asl     $06                             ; F59D
        brk                                     ; F59F
        brk                                     ; F5A0
        asl     $06                             ; F5A1
        brk                                     ; F5A3
        brk                                     ; F5A4
        asl     $06                             ; F5A5
        brk                                     ; F5A7
        brk                                     ; F5A8
        asl     $06                             ; F5A9
        brk                                     ; F5AB
        brk                                     ; F5AC
        asl     $06                             ; F5AD
        brk                                     ; F5AF
        brk                                     ; F5B0
        asl     $06                             ; F5B1
        brk                                     ; F5B3
        brk                                     ; F5B4
        asl     $06                             ; F5B5
        brk                                     ; F5B7
        brk                                     ; F5B8
        asl     $06                             ; F5B9
        brk                                     ; F5BB
        brk                                     ; F5BC
        asl     $06                             ; F5BD
        brk                                     ; F5BF
        brk                                     ; F5C0
        asl     $04                             ; F5C1
        brk                                     ; F5C3
        brk                                     ; F5C4
        asl     $06                             ; F5C5
        brk                                     ; F5C7
        brk                                     ; F5C8
        asl     $06                             ; F5C9
LF5CB:  brk                                     ; F5CB
        brk                                     ; F5CC
        brk                                     ; F5CD
        brk                                     ; F5CE
        brk                                     ; F5CF
        brk                                     ; F5D0
        brk                                     ; F5D1
        rti                                     ; F5D2

; ----------------------------------------------------------------------------
        rti                                     ; F5D3

; ----------------------------------------------------------------------------
        brk                                     ; F5D4
        brk                                     ; F5D5
        rti                                     ; F5D6

; ----------------------------------------------------------------------------
        .byte   $44                             ; F5D7
        .byte   $0C                             ; F5D8
        .byte   $0C                             ; F5D9
        brk                                     ; F5DA
        bpl     LF5E1                           ; F5DB
        .byte   $04                             ; F5DD
        .byte   $04                             ; F5DE
        .byte   $04                             ; F5DF
        .byte   $14                             ; F5E0
LF5E1:  clc                                     ; F5E1
        php                                     ; F5E2
        .byte   $1C                             ; F5E3
        jsr     L041C                           ; F5E4
        php                                     ; F5E7
        php                                     ; F5E8
        .byte   $14                             ; F5E9
        .byte   $14                             ; F5EA
        jsr     L1420                           ; F5EB
        plp                                     ; F5EE
        .byte   $1C                             ; F5EF
        bit     $1C1C                           ; F5F0
        bmi     LF625                           ; F5F3
        bmi     LF60B                           ; F5F5
        .byte   $14                             ; F5F7
        .byte   $14                             ; F5F8
        jsr     L2020                           ; F5F9
        jsr     L2020                           ; F5FC
        .byte   $34                             ; F5FF
        .byte   $14                             ; F600
        php                                     ; F601
        sec                                     ; F602
        brk                                     ; F603
        .byte   $3C                             ; F604
        php                                     ; F605
        brk                                     ; F606
        brk                                     ; F607
        .byte   $04                             ; F608
        php                                     ; F609
        php                                     ; F60A
LF60B:  brk                                     ; F60B
LF60C:  brk                                     ; F60C
LF60D:  .byte   $06                             ; F60D
LF60E:  asl     L00FC                           ; F60E
        brk                                     ; F610
        .byte   $0C                             ; F611
        php                                     ; F612
        brk                                     ; F613
        brk                                     ; F614
        php                                     ; F615
        php                                     ; F616
        brk                                     ; F617
        brk                                     ; F618
        .byte   $04                             ; F619
        .byte   $04                             ; F61A
        brk                                     ; F61B
        brk                                     ; F61C
        php                                     ; F61D
        .byte   $04                             ; F61E
        sed                                     ; F61F
        brk                                     ; F620
        bpl     LF62F                           ; F621
        brk                                     ; F623
        brk                                     ; F624
LF625:  .byte   $0C                             ; F625
        php                                     ; F626
        sed                                     ; F627
        brk                                     ; F628
        bpl     LF633                           ; F629
        sed                                     ; F62B
        brk                                     ; F62C
        bpl     LF63F                           ; F62D
LF62F:  brk                                     ; F62F
        brk                                     ; F630
        php                                     ; F631
        .byte   $10                             ; F632
LF633:  brk                                     ; F633
        brk                                     ; F634
        clc                                     ; F635
        .byte   $0C                             ; F636
        inc     $0C00,x                         ; F637
        asl     a                               ; F63A
        beq     LF63D                           ; F63B
LF63D:  clc                                     ; F63D
        .byte   $0C                             ; F63E
LF63F:  brk                                     ; F63F
        brk                                     ; F640
        php                                     ; F641
        .byte   $0C                             ; F642
        cpx     $00                             ; F643
        jsr     LFC18                           ; F645
        brk                                     ; F648
        .byte   $0C                             ; F649
        jsr     L00FC                           ; F64A
        .byte   $14                             ; F64D
        .byte   $0C                             ; F64E
        brk                                     ; F64F
        brk                                     ; F650
        .byte   $0C                             ; F651
        php                                     ; F652
        brk                                     ; F653
        brk                                     ; F654
        brk                                     ; F655
        brk                                     ; F656
LF657:  bpl     LF669                           ; F657
        jsr     L3121                           ; F659
        and     ($32),y                         ; F65C
        .byte   $42                             ; F65E
        .byte   $53                             ; F65F
        .byte   $53                             ; F660
        .byte   $54                             ; F661
        .byte   $64                             ; F662
        adc     $85,x                           ; F663
        stx     $86                             ; F665
        .byte   $97                             ; F667
        .byte   $97                             ; F668
LF669:  tay                                     ; F669
        clv                                     ; F66A
        cmp     #$D9                            ; F66B
        .byte   $DA                             ; F66D
        .byte   $DC                             ; F66E
        .byte   $DC                             ; F66F
LF670:  ora     ($02,x)                         ; F670
        .byte   $03                             ; F672
        .byte   $04                             ; F673
        ora     $06                             ; F674
        .byte   $07                             ; F676
        php                                     ; F677
        asl     a                               ; F678
        .byte   $0C                             ; F679
        asl     $100F                           ; F67A
        .byte   $12                             ; F67D
LF67E:  bpl     LF694                           ; F67E
        .byte   $34                             ; F680
        .byte   $44                             ; F681
        lsr     $5E54                           ; F682
        .byte   $64                             ; F685
        jmp     (L9473)                         ; F686

; ----------------------------------------------------------------------------
        .byte   $9B                             ; F689
        lda     $B4                             ; F68A
        lda     $C8BE,y                         ; F68C
        cpy     $DAD0                           ; F68F
        .byte   $DC                             ; F692
        .byte   $E4                             ; F693
LF694:  cpx     LFFF5                           ; F694
        jsr     LE5AA                           ; F697
        lda     #$08                            ; F69A
        sta     $18                             ; F69C
        rts                                     ; F69E

; ----------------------------------------------------------------------------
        .byte   $FF                             ; F69F
LF6A0:  ldy     $92                             ; F6A0
        lda     LF6B1,y                         ; F6A2
        sta     $A3                             ; F6A5
        lda     #$10                            ; F6A7
        sta     $A0                             ; F6A9
        lda     #$24                            ; F6AB
        sta     $A2                             ; F6AD
        bne     LF6BA                           ; F6AF
LF6B1:  tax                                     ; F6B1
        .byte   $BB                             ; F6B2
        cpy     $85F6                           ; F6B3
        ldx     #$4C                            ; F6B6
        .byte   $BD                             ; F6B8
        .byte   $F6                             ; F6B9
LF6BA:  ldy     $84                             ; F6BA
        lda     LF724,y                         ; F6BC
        sta     $81                             ; F6BF
        sta     $91                             ; F6C1
        sta     $03EE                           ; F6C3
        lda     LF657,y                         ; F6C6
        pha                                     ; F6C9
        lsr     a                               ; F6CA
        lsr     a                               ; F6CB
        lsr     a                               ; F6CC
        lsr     a                               ; F6CD
        tay                                     ; F6CE
        lda     LF670,y                         ; F6CF
        sta     $8F                             ; F6D2
        pla                                     ; F6D4
        and     #$0F                            ; F6D5
        tay                                     ; F6D7
        lda     LF670,y                         ; F6D8
        sta     $90                             ; F6DB
LF6DD:  rts                                     ; F6DD

; ----------------------------------------------------------------------------
LF6DE:  lda     $60                             ; F6DE
        bne     LF6DD                           ; F6E0
        jsr     LF24A                           ; F6E2
        jmp     LE960                           ; F6E5

; ----------------------------------------------------------------------------
LF6E8:  lda     #$FF                            ; F6E8
        sta     $00                             ; F6EA
        sta     $01                             ; F6EC
        ldy     $84                             ; F6EE
        lda     LF67E,y                         ; F6F0
        sec                                     ; F6F3
LF6F4:  inc     $00                             ; F6F4
        sbc     #$64                            ; F6F6
        bcs     LF6F4                           ; F6F8
        adc     #$64                            ; F6FA
        sec                                     ; F6FC
LF6FD:  inc     $01                             ; F6FD
        sbc     #$0A                            ; F6FF
        bcs     LF6FD                           ; F701
        adc     #$0A                            ; F703
        sta     $02                             ; F705
        rts                                     ; F707

; ----------------------------------------------------------------------------
        sta     $02                             ; F708
        rts                                     ; F70A

; ----------------------------------------------------------------------------
        lda     $82                             ; F70B
        asl     a                               ; F70D
        tay                                     ; F70E
        lda     LF71A,y                         ; F70F
        sta     $00                             ; F712
        lda     LF71B,y                         ; F714
        sta     $01                             ; F717
        rts                                     ; F719

; ----------------------------------------------------------------------------
LF71A:  .byte   $30                             ; F71A
LF71B:  .byte   $02                             ; F71B
        php                                     ; F71C
        .byte   $07                             ; F71D
        cpy     #$12                            ; F71E
        bmi     LF74C                           ; F720
        rti                                     ; F722

; ----------------------------------------------------------------------------
        .byte   $51                             ; F723
LF724:  .byte   $32                             ; F724
        .byte   $3A                             ; F725
        .byte   $42                             ; F726
        lsr     a                               ; F727
        .byte   $52                             ; F728
        .byte   $5A                             ; F729
        .byte   $62                             ; F72A
        .byte   $74                             ; F72B
        .byte   $7C                             ; F72C
        sty     $8C                             ; F72D
        sty     $9C,x                           ; F72F
        ldy     $AC                             ; F731
        ldy     $BC,x                           ; F733
        cpy     $CC                             ; F735
        .byte   $D4                             ; F737
        .byte   $DC                             ; F738
        cpx     $EC                             ; F739
        .byte   $F4                             ; F73B
        .byte   $FF                             ; F73C
LF73D:  jsr     LF743                           ; F73D
        jmp     LE95B                           ; F740

; ----------------------------------------------------------------------------
LF743:  lda     $1C                             ; F743
        bpl     LF757                           ; F745
LF747:  lda     $11                             ; F747
        and     #$18                            ; F749
        .byte   $F0                             ; F74B
LF74C:  asl     a                               ; F74C
LF74D:  lda     $0200                           ; F74D
        cmp     #$F8                            ; F750
        beq     LF757                           ; F752
        jmp     LE8EF                           ; F754

; ----------------------------------------------------------------------------
LF757:  rts                                     ; F757

; ----------------------------------------------------------------------------
LF758:  lda     $71                             ; F758
        bne     LF75F                           ; F75A
        jmp     LE082                           ; F75C

; ----------------------------------------------------------------------------
LF75F:  lda     #$00                            ; F75F
        sta     $71                             ; F761
        beq     LF767                           ; F763
        sta     $6C                             ; F765
LF767:  lda     $6D                             ; F767
        cmp     $6C                             ; F769
        beq     LF784                           ; F76B
        cmp     #$4E                            ; F76D
        bne     LF779                           ; F76F
        lda     #$0B                            ; F771
        sta     $27                             ; F773
        lda     #$86                            ; F775
        bne     LF77F                           ; F777
LF779:  lda     $27                             ; F779
        bne     LF784                           ; F77B
        lda     $6C                             ; F77D
LF77F:  sta     $6D                             ; F77F
        jmp     LE992                           ; F781

; ----------------------------------------------------------------------------
LF784:  rts                                     ; F784

; ----------------------------------------------------------------------------
LF785:  jsr     LE95B                           ; F785
        lda     $1E                             ; F788
        and     #$03                            ; F78A
        bne     LF785                           ; F78C
        jsr     LF79E                           ; F78E
        bne     LF785                           ; F791
        lda     #$07                            ; F793
        sta     $27                             ; F795
LF797:  lda     $27                             ; F797
        bne     LF797                           ; F799
        sta     $6D                             ; F79B
        rts                                     ; F79D

; ----------------------------------------------------------------------------
LF79E:  lda     $0390                           ; F79E
        clc                                     ; F7A1
        adc     #$20                            ; F7A2
        sta     $0390                           ; F7A4
        bne     LF7B0                           ; F7A7
        lda     #$FF                            ; F7A9
        jsr     LE992                           ; F7AB
        lda     #$00                            ; F7AE
LF7B0:  rts                                     ; F7B0

; ----------------------------------------------------------------------------
        sta     $3B                             ; F7B1
        sty     $3C                             ; F7B3
        stx     $3D                             ; F7B5
        asl     a                               ; F7B7
        adc     $3B                             ; F7B8
        asl     a                               ; F7BA
        sta     $3B                             ; F7BB
        tay                                     ; F7BD
        lda     LF82C,y                         ; F7BE
        sta     $EA                             ; F7C1
        lda     LF82D,y                         ; F7C3
        sta     $AD                             ; F7C6
        lda     LF82E,y                         ; F7C8
        sta     $AE                             ; F7CB
        lda     LF82F,y                         ; F7CD
        sta     $AF                             ; F7D0
        lda     #$00                            ; F7D2
        sta     $EC                             ; F7D4
        jsr     LEEA3                           ; F7D6
        lda     $1C                             ; F7D9
        ora     #$02                            ; F7DB
        sta     $1C                             ; F7DD
        lda     $ED                             ; F7DF
        sta     $EB                             ; F7E1
        lda     $EE                             ; F7E3
        and     #$0F                            ; F7E5
        sta     $EC                             ; F7E7
        lda     $EE                             ; F7E9
        lsr     a                               ; F7EB
        lsr     a                               ; F7EC
        lsr     a                               ; F7ED
        lsr     a                               ; F7EE
        clc                                     ; F7EF
        adc     $AD                             ; F7F0
        sta     $ED                             ; F7F2
        ldy     $3B                             ; F7F4
        lda     LF82B,y                         ; F7F6
        and     #$F0                            ; F7F9
        sta     $EA                             ; F7FB
        lda     LF82B,y                         ; F7FD
        and     #$0F                            ; F800
        sta     $E9                             ; F802
        lda     LF82A,y                         ; F804
        and     #$F0                            ; F807
        sta     $E8                             ; F809
        lda     LF82A,y                         ; F80B
        and     #$0F                            ; F80E
        sta     $3B                             ; F810
        lda     $EA                             ; F812
LF814:  sta     $EA                             ; F814
        pha                                     ; F816
        jsr     LE8D1                           ; F817
        pla                                     ; F81A
        dec     $3B                             ; F81B
        bne     LF814                           ; F81D
        ldx     $3D                             ; F81F
        ldy     $3C                             ; F821
        lda     $1C                             ; F823
        and     #$FD                            ; F825
        sta     $1C                             ; F827
        rts                                     ; F829

; ----------------------------------------------------------------------------
LF82A:  .byte   $CD                             ; F82A
LF82B:  .byte   $44                             ; F82B
LF82C:  .byte   $0C                             ; F82C
LF82D:  .byte   $17                             ; F82D
LF82E:  brk                                     ; F82E
LF82F:  brk                                     ; F82F
        cmp     $44                             ; F830
        brk                                     ; F832
        bpl     LF835                           ; F833
LF835:  ora     $CD                             ; F835
        .byte   $44                             ; F837
        brk                                     ; F838
        bpl     LF83B                           ; F839
LF83B:  .byte   $05                             ; F83B
LF83C:  lda     $67                             ; F83C
        bmi     LF85C                           ; F83E
        lda     $11                             ; F840
        and     #$18                            ; F842
        beq     LF85C                           ; F844
        lda     $0200                           ; F846
        cmp     #$F8                            ; F849
        beq     LF85C                           ; F84B
        lda     $60                             ; F84D
        bne     LF859                           ; F84F
        bit     PPU_STATUS                      ; F851
        bvc     LF85C                           ; F854
        jmp     LE8FD                           ; F856

; ----------------------------------------------------------------------------
LF859:  jmp     LE90F                           ; F859

; ----------------------------------------------------------------------------
LF85C:  rts                                     ; F85C

; ----------------------------------------------------------------------------
        sty     $3C                             ; F85D
        sta     $0607,x                         ; F85F
        and     #$1F                            ; F862
        asl     a                               ; F864
        asl     a                               ; F865
        tay                                     ; F866
        lda     $0601,x                         ; F867
LF86A:  iny                                     ; F86A
        asl     a                               ; F86B
        bcc     LF86A                           ; F86C
        lda     LFCB4,y                         ; F86E
        sta     $0606,x                         ; F871
        ldy     $3C                             ; F874
        rts                                     ; F876

; ----------------------------------------------------------------------------
        lda     $0700,x                         ; F877
        beq     LF882                           ; F87A
        dec     $0700,x                         ; F87C
        jmp     LF8BB                           ; F87F

; ----------------------------------------------------------------------------
LF882:  lda     $0607,x                         ; F882
        and     #$1F                            ; F885
        asl     a                               ; F887
        tay                                     ; F888
        lda     LFCCD,y                         ; F889
        sta     L003E                           ; F88C
        lda     LFCCE,y                         ; F88E
        sta     $3F                             ; F891
LF893:  ldy     $0606,x                         ; F893
        inc     $0606,x                         ; F896
        lda     (L003E),y                       ; F899
        asl     $0607,x                         ; F89B
        asl     a                               ; F89E
        ror     $0607,x                         ; F89F
        lsr     a                               ; F8A2
        cmp     #$40                            ; F8A3
        bne     LF8B0                           ; F8A5
        iny                                     ; F8A7
        lda     (L003E),y                       ; F8A8
        sta     $0606,x                         ; F8AA
        bne     LF893                           ; F8AD
        rts                                     ; F8AF

; ----------------------------------------------------------------------------
LF8B0:  bcc     LF8C5                           ; F8B0
        and     #$3F                            ; F8B2
        cmp     #$3F                            ; F8B4
        beq     LF8BF                           ; F8B6
        sta     $0700,x                         ; F8B8
LF8BB:  lda     $0601,x                         ; F8BB
        rts                                     ; F8BE

; ----------------------------------------------------------------------------
LF8BF:  jsr     LE0A2                           ; F8BF
        jmp     LF882                           ; F8C2

; ----------------------------------------------------------------------------
LF8C5:  sta     $00                             ; F8C5
        lsr     a                               ; F8C7
        lsr     a                               ; F8C8
        lsr     a                               ; F8C9
        and     #$07                            ; F8CA
        cmp     #$04                            ; F8CC
        bcc     LF8D2                           ; F8CE
        ora     #$F8                            ; F8D0
LF8D2:  sta     $01                             ; F8D2
        lda     $00                             ; F8D4
        and     #$07                            ; F8D6
        cmp     #$04                            ; F8D8
        bcc     LF8DE                           ; F8DA
        ora     #$F8                            ; F8DC
LF8DE:  sta     $00                             ; F8DE
        jsr     LF8E6                           ; F8E0
        jmp     LF8BB                           ; F8E3

; ----------------------------------------------------------------------------
LF8E6:  clc                                     ; F8E6
        lda     $0602,x                         ; F8E7
        adc     $00                             ; F8EA
        sta     $00                             ; F8EC
        clc                                     ; F8EE
        lda     $0603,x                         ; F8EF
        adc     $01                             ; F8F2
        sta     $01                             ; F8F4
        lda     $0607,x                         ; F8F6
        and     #$20                            ; F8F9
        beq     LF90C                           ; F8FB
        lda     $0601,x                         ; F8FD
        sta     $02                             ; F900
        bpl     LF926                           ; F902
        lda     $01                             ; F904
        cmp     #$F8                            ; F906
        bcs     LF930                           ; F908
        bcc     LF926                           ; F90A
LF90C:  lda     $00                             ; F90C
        sta     $0602,x                         ; F90E
        and     #$F0                            ; F911
        sta     $00                             ; F913
        lda     $01                             ; F915
        sta     $0603,x                         ; F917
        lsr     a                               ; F91A
        lsr     a                               ; F91B
        lsr     a                               ; F91C
        lsr     a                               ; F91D
        ora     $00                             ; F91E
        sta     $0605,x                         ; F920
        lda     #$01                            ; F923
        rts                                     ; F925

; ----------------------------------------------------------------------------
LF926:  asl     $02                             ; F926
        bpl     LF93B                           ; F928
        lda     #$08                            ; F92A
        cmp     $01                             ; F92C
        bcc     LF93B                           ; F92E
LF930:  lda     $0601,x                         ; F930
        sta     $02                             ; F933
        lda     #$00                            ; F935
        sta     $0601,x                         ; F937
        rts                                     ; F93A

; ----------------------------------------------------------------------------
LF93B:  asl     $02                             ; F93B
        bpl     LF945                           ; F93D
        lda     $00                             ; F93F
        cmp     #$B8                            ; F941
        bcs     LF930                           ; F943
LF945:  asl     $02                             ; F945
        bpl     LF90C                           ; F947
        lda     #$10                            ; F949
        cmp     $00                             ; F94B
        bcs     LF930                           ; F94D
        bcc     LF90C                           ; F94F
LF951:  sty     $3C                             ; F951
        sta     $0607,x                         ; F953
        asl     a                               ; F956
        bpl     LF95C                           ; F957
        clc                                     ; F959
        adc     #$01                            ; F95A
LF95C:  and     #$7F                            ; F95C
        tay                                     ; F95E
        lda     LFE9A,y                         ; F95F
        sta     $0606,x                         ; F962
        lda     #$00                            ; F965
        sta     $0705,x                         ; F967
        sta     $0706,x                         ; F96A
        lda     #$10                            ; F96D
        sta     $0704,x                         ; F96F
        ldy     $3C                             ; F972
        rts                                     ; F974

; ----------------------------------------------------------------------------
LF975:  sty     $3C                             ; F975
        lda     $0607,x                         ; F977
        asl     a                               ; F97A
        and     #$3F                            ; F97B
        tay                                     ; F97D
        lda     LFE9C,y                         ; F97E
        sta     L003E                           ; F981
        lda     LFE9D,y                         ; F983
        sta     $3F                             ; F986
        ldy     $0606,x                         ; F988
        lda     $0607,x                         ; F98B
        asl     a                               ; F98E
        bmi     LF996                           ; F98F
        iny                                     ; F991
        iny                                     ; F992
        jmp     LF998                           ; F993

; ----------------------------------------------------------------------------
LF996:  dey                                     ; F996
        dey                                     ; F997
LF998:  lda     (L003E),y                       ; F998
        cmp     #$80                            ; F99A
        bne     LF9A9                           ; F99C
        iny                                     ; F99E
        lda     (L003E),y                       ; F99F
        tay                                     ; F9A1
        bne     LF998                           ; F9A2
        ldy     $3C                             ; F9A4
        lda     #$00                            ; F9A6
        rts                                     ; F9A8

; ----------------------------------------------------------------------------
LF9A9:  sta     $0706,x                         ; F9A9
        tya                                     ; F9AC
        sta     $0606,x                         ; F9AD
        iny                                     ; F9B0
        lda     (L003E),y                       ; F9B1
        sta     $0705,x                         ; F9B3
        ldy     $3C                             ; F9B6
        lda     #$01                            ; F9B8
        rts                                     ; F9BA

; ----------------------------------------------------------------------------
LF9BB:  sty     $3C                             ; F9BB
        lda     $0704,x                         ; F9BD
        sta     $00                             ; F9C0
        lda     $0602,x                         ; F9C2
        sta     $02                             ; F9C5
        lda     $0705,x                         ; F9C7
        jsr     LF9E1                           ; F9CA
        sta     $0602,x                         ; F9CD
        lda     $0603,x                         ; F9D0
        sta     $02                             ; F9D3
        lda     $0706,x                         ; F9D5
        jsr     LF9E1                           ; F9D8
        sta     $0603,x                         ; F9DB
        ldy     $3C                             ; F9DE
        rts                                     ; F9E0

; ----------------------------------------------------------------------------
LF9E1:  clc                                     ; F9E1
        php                                     ; F9E2
        bpl     LF9E9                           ; F9E3
        eor     #$FF                            ; F9E5
        adc     #$01                            ; F9E7
LF9E9:  sta     $01                             ; F9E9
        ldy     #$08                            ; F9EB
        lda     #$00                            ; F9ED
        lsr     $01                             ; F9EF
LF9F1:  bcc     LF9F6                           ; F9F1
        clc                                     ; F9F3
        adc     $00                             ; F9F4
LF9F6:  ror     a                               ; F9F6
        ror     $01                             ; F9F7
        dey                                     ; F9F9
        bne     LF9F1                           ; F9FA
        asl     $01                             ; F9FC
        rol     a                               ; F9FE
        asl     $01                             ; F9FF
        rol     a                               ; FA01
        asl     $01                             ; FA02
        rol     a                               ; FA04
        asl     $01                             ; FA05
        rol     a                               ; FA07
        plp                                     ; FA08
        bpl     LFA0F                           ; FA09
        eor     #$FF                            ; FA0B
        adc     #$01                            ; FA0D
LFA0F:  sta     $01                             ; FA0F
        clc                                     ; FA11
        adc     $02                             ; FA12
        sta     $02                             ; FA14
        ror     a                               ; FA16
        eor     $01                             ; FA17
        bpl     LFA26                           ; FA19
        lda     $01                             ; FA1B
        rol     a                               ; FA1D
        lda     #$08                            ; FA1E
        bcs     LFA24                           ; FA20
        lda     #$F8                            ; FA22
LFA24:  sta     $02                             ; FA24
LFA26:  lda     $02                             ; FA26
        rts                                     ; FA28

; ----------------------------------------------------------------------------
        lda     #$08                            ; FA29
        sta     $06                             ; FA2B
        lda     #$0C                            ; FA2D
        sta     $07                             ; FA2F
        txa                                     ; FA31
        pha                                     ; FA32
        lda     $0602,x                         ; FA33
        sta     $03                             ; FA36
        lda     $0603,x                         ; FA38
        sta     $04                             ; FA3B
        ldy     #$00                            ; FA3D
        sty     $05                             ; FA3F
LFA41:  txa                                     ; FA41
        clc                                     ; FA42
        adc     #$08                            ; FA43
        tax                                     ; FA45
        lda     $00                             ; FA46
        sta     $0600,x                         ; FA48
        lda     $01                             ; FA4B
        sta     $0601,x                         ; FA4D
        lda     $03                             ; FA50
        sta     $0602,x                         ; FA52
        lda     $04                             ; FA55
        sta     $0603,x                         ; FA57
        pla                                     ; FA5A
        pha                                     ; FA5B
        sta     $0703,x                         ; FA5C
        lda     #$00                            ; FA5F
        sta     $0704,x                         ; FA61
        sta     $0705,x                         ; FA64
        sta     $0706,x                         ; FA67
        jsr     LE0A4                           ; FA6A
        lda     $02                             ; FA6D
        jsr     LF951                           ; FA6F
        clc                                     ; FA72
        lda     $05                             ; FA73
        adc     $07                             ; FA75
        sta     $05                             ; FA77
        sta     $0606,x                         ; FA79
        iny                                     ; FA7C
        cpy     $06                             ; FA7D
        bne     LFA41                           ; FA7F
        pla                                     ; FA81
        tax                                     ; FA82
        rts                                     ; FA83

; ----------------------------------------------------------------------------
        sty     $3C                             ; FA84
        ldy     $0703,x                         ; FA86
        lda     $0601,y                         ; FA89
        bne     LFA96                           ; FA8C
        sta     $0601,x                         ; FA8E
        ldy     $3C                             ; FA91
        lda     #$00                            ; FA93
        rts                                     ; FA95

; ----------------------------------------------------------------------------
LFA96:  lda     $0704,y                         ; FA96
        sta     $0704,x                         ; FA99
        lda     $0602,y                         ; FA9C
        sta     $0602,x                         ; FA9F
        lda     $0603,y                         ; FAA2
        sta     $0603,x                         ; FAA5
        jsr     LF975                           ; FAA8
        jsr     LF9BB                           ; FAAB
        ldy     $3C                             ; FAAE
        lda     #$01                            ; FAB0
        rts                                     ; FAB2

; ----------------------------------------------------------------------------
LFAB3:  sty     $3C                             ; FAB3
        sta     $0607,x                         ; FAB5
        and     #$5F                            ; FAB8
        asl     a                               ; FABA
        asl     a                               ; FABB
        tay                                     ; FABC
        lda     LFF06,y                         ; FABD
        bcc     LFAC6                           ; FAC0
        eor     #$FF                            ; FAC2
        adc     #$00                            ; FAC4
LFAC6:  sta     $0705,x                         ; FAC6
        lda     #$00                            ; FAC9
        sta     $0706,x                         ; FACB
        lda     LFF07,y                         ; FACE
        sta     $0606,x                         ; FAD1
        ldy     $3C                             ; FAD4
        rts                                     ; FAD6

; ----------------------------------------------------------------------------
        beq     LFAE0                           ; FAD7
        and     $7F                             ; FAD9
        bne     LFAE0                           ; FADB
        jsr     LE0A2                           ; FADD
LFAE0:  lda     $03                             ; FAE0
        sta     $00                             ; FAE2
        sta     $01                             ; FAE4
        sty     $3C                             ; FAE6
        lda     $0607,x                         ; FAE8
        and     #$5F                            ; FAEB
        asl     a                               ; FAED
        asl     a                               ; FAEE
        tay                                     ; FAEF
        bcc     LFB08                           ; FAF0
        clc                                     ; FAF2
        lda     $0706,x                         ; FAF3
        adc     LFF05,y                         ; FAF6
        sta     $0706,x                         ; FAF9
        lda     $0705,x                         ; FAFC
        adc     LFF04,y                         ; FAFF
        sta     $0705,x                         ; FB02
        jmp     LFB1B                           ; FB05

; ----------------------------------------------------------------------------
LFB08:  sec                                     ; FB08
        lda     $0706,x                         ; FB09
        sbc     LFF05,y                         ; FB0C
        sta     $0706,x                         ; FB0F
        lda     $0705,x                         ; FB12
        sbc     LFF04,y                         ; FB15
        sta     $0705,x                         ; FB18
LFB1B:  sta     $02                             ; FB1B
        lda     $0601,x                         ; FB1D
        and     #$C0                            ; FB20
        beq     LFB35                           ; FB22
        bmi     LFB2E                           ; FB24
        lda     $01                             ; FB26
        eor     #$FF                            ; FB28
        sta     $01                             ; FB2A
        inc     $01                             ; FB2C
LFB2E:  lda     $02                             ; FB2E
        sta     $00                             ; FB30
        jmp     LFB48                           ; FB32

; ----------------------------------------------------------------------------
LFB35:  lda     $02                             ; FB35
        sta     $01                             ; FB37
        lda     $0601,x                         ; FB39
        and     #$10                            ; FB3C
        beq     LFB48                           ; FB3E
        lda     $00                             ; FB40
        eor     #$FF                            ; FB42
        sta     $00                             ; FB44
        inc     $00                             ; FB46
LFB48:  ldy     $3C                             ; FB48
        dec     $0606,x                         ; FB4A
        jsr     LF8E6                           ; FB4D
        pha                                     ; FB50
        clc                                     ; FB51
        lda     $0606,x                         ; FB52
        bne     LFB60                           ; FB55
        lda     $0607,x                         ; FB57
        eor     #$40                            ; FB5A
        jsr     LFAB3                           ; FB5C
        sec                                     ; FB5F
LFB60:  pla                                     ; FB60
        rts                                     ; FB61

; ----------------------------------------------------------------------------
        beq     LFB6B                           ; FB62
        and     $7F                             ; FB64
        bne     LFB6B                           ; FB66
        jsr     LE0A2                           ; FB68
LFB6B:  lda     #$00                            ; FB6B
        sta     $00                             ; FB6D
        sta     $01                             ; FB6F
        lda     $0601,x                         ; FB71
        sta     $02                             ; FB74
        asl     $02                             ; FB76
        bcc     LFB7E                           ; FB78
        lda     $03                             ; FB7A
        sta     $01                             ; FB7C
LFB7E:  asl     $02                             ; FB7E
        bcc     LFB88                           ; FB80
        lda     #$00                            ; FB82
        sbc     $03                             ; FB84
        sta     $01                             ; FB86
LFB88:  asl     $02                             ; FB88
        bcc     LFB90                           ; FB8A
        lda     $03                             ; FB8C
        sta     $00                             ; FB8E
LFB90:  asl     $02                             ; FB90
        bcc     LFB9A                           ; FB92
        lda     #$00                            ; FB94
        sbc     $03                             ; FB96
        sta     $00                             ; FB98
LFB9A:  lda     $0607,x                         ; FB9A
        ora     #$A0                            ; FB9D
        sta     $0607,x                         ; FB9F
        jmp     LF8E6                           ; FBA2

; ----------------------------------------------------------------------------
        lda     #$00                            ; FBA5
        sta     $0606,x                         ; FBA7
        sta     $0704,x                         ; FBAA
        lda     $0601,x                         ; FBAD
        and     #$0F                            ; FBB0
        sta     $0601,x                         ; FBB2
        jsr     LFC42                           ; FBB5
        ora     $0601,x                         ; FBB8
        sta     $0601,x                         ; FBBB
        lda     L000F                           ; FBBE
        cmp     $0E                             ; FBC0
        beq     LFBE8                           ; FBC2
        bcc     LFBD2                           ; FBC4
        inc     $0606,x                         ; FBC6
        sta     $00                             ; FBC9
        lda     $0E                             ; FBCB
        sta     $01                             ; FBCD
        jmp     LFBDB                           ; FBCF

; ----------------------------------------------------------------------------
LFBD2:  dec     $0606,x                         ; FBD2
        sta     $01                             ; FBD5
        lda     $0E                             ; FBD7
        sta     $00                             ; FBD9
LFBDB:  jsr     LFC75                           ; FBDB
        lda     $01                             ; FBDE
        sta     $0705,x                         ; FBE0
        lda     $02                             ; FBE3
        sta     $0706,x                         ; FBE5
LFBE8:  rts                                     ; FBE8

; ----------------------------------------------------------------------------
        beq     LFBF2                           ; FBE9
        and     $7F                             ; FBEB
        bne     LFBF2                           ; FBED
        jsr     LE0A2                           ; FBEF
LFBF2:  lda     $03                             ; FBF2
        sta     $00                             ; FBF4
        sta     $01                             ; FBF6
        lda     #$00                            ; FBF8
        sta     $02                             ; FBFA
LFBFC:  clc                                     ; FBFC
        lda     $0704,x                         ; FBFD
        adc     $0706,x                         ; FC00
        sta     $0704,x                         ; FC03
        lda     $02                             ; FC06
        adc     $0705,x                         ; FC08
        sta     $02                             ; FC0B
        dec     $03                             ; FC0D
        beq     LFC17                           ; FC0F
        lda     $03                             ; FC11
        cmp     #$07                            ; FC13
        bcc     LFBFC                           ; FC15
LFC17:  .byte   $BD                             ; FC17
LFC18:  asl     $06                             ; FC18
        beq     LFC27                           ; FC1A
        asl     a                               ; FC1C
        lda     $02                             ; FC1D
        bcs     LFC25                           ; FC1F
        sta     $00                             ; FC21
        bcc     LFC27                           ; FC23
LFC25:  sta     $01                             ; FC25
LFC27:  lda     $0601,x                         ; FC27
        and     #$20                            ; FC2A
        bne     LFC33                           ; FC2C
        sec                                     ; FC2E
        sbc     $00                             ; FC2F
        sta     $00                             ; FC31
LFC33:  lda     $0601,x                         ; FC33
        and     #$80                            ; FC36
        bne     LFC3F                           ; FC38
        sec                                     ; FC3A
        sbc     $01                             ; FC3B
        sta     $01                             ; FC3D
LFC3F:  jmp     LF8E6                           ; FC3F

; ----------------------------------------------------------------------------
LFC42:  lda     #$20                            ; FC42
        sta     $0D                             ; FC44
        sec                                     ; FC46
        lda     $0602,y                         ; FC47
        sbc     $0602,x                         ; FC4A
        sta     $0E                             ; FC4D
        bcs     LFC59                           ; FC4F
        eor     #$FF                            ; FC51
        adc     #$01                            ; FC53
        sta     $0E                             ; FC55
        lsr     $0D                             ; FC57
LFC59:  sec                                     ; FC59
        lda     $0603,y                         ; FC5A
        sbc     $0603,x                         ; FC5D
        sta     L000F                           ; FC60
        lda     #$80                            ; FC62
        bcs     LFC70                           ; FC64
        lda     L000F                           ; FC66
        eor     #$FF                            ; FC68
        adc     #$01                            ; FC6A
        sta     L000F                           ; FC6C
        lda     #$40                            ; FC6E
LFC70:  ora     $0D                             ; FC70
        sta     $0D                             ; FC72
        rts                                     ; FC74

; ----------------------------------------------------------------------------
LFC75:  tya                                     ; FC75
        pha                                     ; FC76
        ldy     #$11                            ; FC77
        lda     #$00                            ; FC79
        sta     $02                             ; FC7B
LFC7D:  sec                                     ; FC7D
        sbc     $00                             ; FC7E
        bcs     LFC85                           ; FC80
        adc     $00                             ; FC82
        clc                                     ; FC84
LFC85:  rol     $02                             ; FC85
        rol     $01                             ; FC87
        rol     a                               ; FC89
        dey                                     ; FC8A
        bne     LFC7D                           ; FC8B
        pla                                     ; FC8D
        tay                                     ; FC8E
        rts                                     ; FC8F

; ----------------------------------------------------------------------------
        jsr     LFC42                           ; FC90
        lda     $0601,x                         ; FC93
        and     $0D                             ; FC96
        beq     LFCB2                           ; FC98
        lda     L000F                           ; FC9A
        sta     $00                             ; FC9C
        lda     $0E                             ; FC9E
        sta     $01                             ; FCA0
        jsr     LFC75                           ; FCA2
        lda     $01                             ; FCA5
        bne     LFCB2                           ; FCA7
        lda     #$30                            ; FCA9
        cmp     $02                             ; FCAB
        bcc     LFCB2                           ; FCAD
        lda     #$00                            ; FCAF
        rts                                     ; FCB1

; ----------------------------------------------------------------------------
LFCB2:  lda     #$01                            ; FCB2
LFCB4:  rts                                     ; FCB4

; ----------------------------------------------------------------------------
        ora     ($01,x)                         ; FCB5
        ora     ($01,x)                         ; FCB7
        ora     ($13,x)                         ; FCB9
        and     $36                             ; FCBB
        ora     ($23,x)                         ; FCBD
        eor     $65                             ; FCBF
        ora     ($23,x)                         ; FCC1
        eor     $65                             ; FCC3
        ora     ($33,x)                         ; FCC5
        adc     $97                             ; FCC7
        ora     (L000F,x)                       ; FCC9
        ora     (L000F,x)                       ; FCCB
LFCCD:  cld                                     ; FCCD
LFCCE:  .byte   $FC                             ; FCCE
        sbc     #$FC                            ; FCCF
        .byte   $2F                             ; FCD1
        sbc     LFD2F,x                         ; FCD2
        lda     $FD,x                           ; FCD5
        adc     $05FE,x                         ; FCD7
        ora     $05                             ; FCDA
        ora     $05                             ; FCDC
        ora     $07                             ; FCDE
        .byte   $44                             ; FCE0
        ora     ($03,x)                         ; FCE1
        .byte   $03                             ; FCE3
        .byte   $03                             ; FCE4
        .byte   $03                             ; FCE5
        .byte   $03                             ; FCE6
        .byte   $03                             ; FCE7
        rti                                     ; FCE8

; ----------------------------------------------------------------------------
        brk                                     ; FCE9
        asl     $0E0E                           ; FCEA
        asl     $0F0E                           ; FCED
        .byte   $0F                             ; FCF0
        php                                     ; FCF1
        php                                     ; FCF2
        ora     #$09                            ; FCF3
        asl     a                               ; FCF5
        asl     a                               ; FCF6
        asl     a                               ; FCF7
        asl     a                               ; FCF8
        asl     a                               ; FCF9
        rti                                     ; FCFA

; ----------------------------------------------------------------------------
        brk                                     ; FCFB
        rol     $3E3E,x                         ; FCFC
        rol     $3F3E,x                         ; FCFF
        .byte   $3F                             ; FD02
LFD03:  sec                                     ; FD03
        sec                                     ; FD04
        and     $3A39,y                         ; FD05
        .byte   $3A                             ; FD08
        .byte   $3A                             ; FD09
        .byte   $3A                             ; FD0A
        .byte   $3A                             ; FD0B
        rti                                     ; FD0C

; ----------------------------------------------------------------------------
        brk                                     ; FD0D
        asl     $06                             ; FD0E
        .byte   $02                             ; FD10
        .byte   $02                             ; FD11
        .byte   $02                             ; FD12
        ora     ($01,x)                         ; FD13
        ora     ($01,x)                         ; FD15
        ora     ($01,x)                         ; FD17
        .byte   $02                             ; FD19
        .byte   $02                             ; FD1A
        .byte   $02                             ; FD1B
        .byte   $02                             ; FD1C
        rti                                     ; FD1D

; ----------------------------------------------------------------------------
        brk                                     ; FD1E
        asl     $06                             ; FD1F
        asl     $06                             ; FD21
        .byte   $07                             ; FD23
        .byte   $07                             ; FD24
        .byte   $07                             ; FD25
        .byte   $07                             ; FD26
        .byte   $07                             ; FD27
        .byte   $07                             ; FD28
        asl     $06                             ; FD29
        asl     $02                             ; FD2B
        .byte   $02                             ; FD2D
        rti                                     ; FD2E

; ----------------------------------------------------------------------------
LFD2F:  brk                                     ; FD2F
        ora     $0E0E                           ; FD30
        asl     $080F                           ; FD33
        .byte   $0F                             ; FD36
        .byte   $0F                             ; FD37
        php                                     ; FD38
        .byte   $0F                             ; FD39
        php                                     ; FD3A
        .byte   $0F                             ; FD3B
        php                                     ; FD3C
        .byte   $0F                             ; FD3D
        php                                     ; FD3E
        php                                     ; FD3F
        php                                     ; FD40
        php                                     ; FD41
        ora     #$08                            ; FD42
        ora     #$08                            ; FD44
        ora     #$08                            ; FD46
        ora     #$09                            ; FD48
        ora     #$09                            ; FD4A
        ora     #$0A                            ; FD4C
        asl     a                               ; FD4E
        .byte   $0B                             ; FD4F
        rti                                     ; FD50

; ----------------------------------------------------------------------------
        brk                                     ; FD51
        and     $3E3E,x                         ; FD52
        rol     $383F,x                         ; FD55
        .byte   $3F                             ; FD58
        .byte   $3F                             ; FD59
        sec                                     ; FD5A
        .byte   $3F                             ; FD5B
        sec                                     ; FD5C
        .byte   $3F                             ; FD5D
        sec                                     ; FD5E
        .byte   $3F                             ; FD5F
        sec                                     ; FD60
        sec                                     ; FD61
        sec                                     ; FD62
        sec                                     ; FD63
        and     $3938,y                         ; FD64
        sec                                     ; FD67
        and     $3938,y                         ; FD68
        and     $3939,y                         ; FD6B
        and     $3A3A,y                         ; FD6E
        .byte   $3B                             ; FD71
        rti                                     ; FD72

; ----------------------------------------------------------------------------
        brk                                     ; FD73
        ora     $06                             ; FD74
        asl     $02                             ; FD76
        .byte   $02                             ; FD78
        ora     ($01,x)                         ; FD79
        ora     ($01,x)                         ; FD7B
        ora     ($01,x)                         ; FD7D
        ora     ($01,x)                         ; FD7F
        ora     ($01,x)                         ; FD81
        ora     ($01,x)                         ; FD83
        ora     ($01,x)                         ; FD85
        ora     ($01,x)                         ; FD87
        .byte   $02                             ; FD89
        .byte   $02                             ; FD8A
        .byte   $02                             ; FD8B
        .byte   $02                             ; FD8C
        .byte   $02                             ; FD8D
        .byte   $02                             ; FD8E
        .byte   $02                             ; FD8F
        .byte   $02                             ; FD90
        .byte   $03                             ; FD91
        rti                                     ; FD92

; ----------------------------------------------------------------------------
        brk                                     ; FD93
        ora     $06                             ; FD94
        asl     $06                             ; FD96
        asl     $06                             ; FD98
        asl     $06                             ; FD9A
        .byte   $07                             ; FD9C
        .byte   $07                             ; FD9D
        .byte   $07                             ; FD9E
        .byte   $07                             ; FD9F
        .byte   $07                             ; FDA0
        .byte   $07                             ; FDA1
        .byte   $07                             ; FDA2
        .byte   $07                             ; FDA3
        .byte   $07                             ; FDA4
        .byte   $07                             ; FDA5
        .byte   $07                             ; FDA6
        .byte   $07                             ; FDA7
        .byte   $07                             ; FDA8
        .byte   $07                             ; FDA9
        .byte   $07                             ; FDAA
        .byte   $07                             ; FDAB
        .byte   $07                             ; FDAC
        .byte   $07                             ; FDAD
        asl     $06                             ; FDAE
        .byte   $02                             ; FDB0
        .byte   $02                             ; FDB1
        .byte   $02                             ; FDB2
        .byte   $03                             ; FDB3
        rti                                     ; FDB4

; ----------------------------------------------------------------------------
        brk                                     ; FDB5
        php                                     ; FDB6
        php                                     ; FDB7
        php                                     ; FDB8
        php                                     ; FDB9
        php                                     ; FDBA
        php                                     ; FDBB
        php                                     ; FDBC
        php                                     ; FDBD
        php                                     ; FDBE
        php                                     ; FDBF
        php                                     ; FDC0
        php                                     ; FDC1
        php                                     ; FDC2
        php                                     ; FDC3
        php                                     ; FDC4
        php                                     ; FDC5
        php                                     ; FDC6
        php                                     ; FDC7
        php                                     ; FDC8
        php                                     ; FDC9
        php                                     ; FDCA
        php                                     ; FDCB
        php                                     ; FDCC
        php                                     ; FDCD
        php                                     ; FDCE
        php                                     ; FDCF
        php                                     ; FDD0
        php                                     ; FDD1
        php                                     ; FDD2
        php                                     ; FDD3
        php                                     ; FDD4
        php                                     ; FDD5
        php                                     ; FDD6
        php                                     ; FDD7
        php                                     ; FDD8
        php                                     ; FDD9
        php                                     ; FDDA
        php                                     ; FDDB
        php                                     ; FDDC
        php                                     ; FDDD
        php                                     ; FDDE
        php                                     ; FDDF
        php                                     ; FDE0
        php                                     ; FDE1
        php                                     ; FDE2
        php                                     ; FDE3
        php                                     ; FDE4
        php                                     ; FDE5
        rti                                     ; FDE6

; ----------------------------------------------------------------------------
        brk                                     ; FDE7
        sec                                     ; FDE8
        sec                                     ; FDE9
        sec                                     ; FDEA
        sec                                     ; FDEB
        sec                                     ; FDEC
        sec                                     ; FDED
        sec                                     ; FDEE
        sec                                     ; FDEF
        sec                                     ; FDF0
        sec                                     ; FDF1
        sec                                     ; FDF2
        sec                                     ; FDF3
        sec                                     ; FDF4
        sec                                     ; FDF5
        sec                                     ; FDF6
        sec                                     ; FDF7
        sec                                     ; FDF8
        sec                                     ; FDF9
        sec                                     ; FDFA
        sec                                     ; FDFB
        sec                                     ; FDFC
        sec                                     ; FDFD
        sec                                     ; FDFE
        sec                                     ; FDFF
        sec                                     ; FE00
        sec                                     ; FE01
LFE02:  sec                                     ; FE02
        sec                                     ; FE03
        sec                                     ; FE04
        sec                                     ; FE05
        sec                                     ; FE06
        sec                                     ; FE07
        sec                                     ; FE08
        sec                                     ; FE09
        sec                                     ; FE0A
        sec                                     ; FE0B
        sec                                     ; FE0C
        sec                                     ; FE0D
        sec                                     ; FE0E
        sec                                     ; FE0F
        sec                                     ; FE10
        sec                                     ; FE11
        sec                                     ; FE12
        sec                                     ; FE13
        sec                                     ; FE14
        sec                                     ; FE15
        sec                                     ; FE16
        sec                                     ; FE17
        rti                                     ; FE18

; ----------------------------------------------------------------------------
        brk                                     ; FE19
        ora     ($01,x)                         ; FE1A
        ora     ($01,x)                         ; FE1C
        ora     ($01,x)                         ; FE1E
        ora     ($01,x)                         ; FE20
        ora     ($01,x)                         ; FE22
        ora     ($01,x)                         ; FE24
        ora     ($01,x)                         ; FE26
        ora     ($01,x)                         ; FE28
        ora     ($01,x)                         ; FE2A
        ora     ($01,x)                         ; FE2C
        ora     ($01,x)                         ; FE2E
        ora     ($01,x)                         ; FE30
        ora     ($01,x)                         ; FE32
        ora     ($01,x)                         ; FE34
        ora     ($01,x)                         ; FE36
        ora     ($01,x)                         ; FE38
        ora     ($01,x)                         ; FE3A
        ora     ($01,x)                         ; FE3C
        ora     ($01,x)                         ; FE3E
        ora     ($01,x)                         ; FE40
        ora     ($01,x)                         ; FE42
        ora     ($01,x)                         ; FE44
        ora     ($01,x)                         ; FE46
        ora     ($01,x)                         ; FE48
        rti                                     ; FE4A

; ----------------------------------------------------------------------------
        brk                                     ; FE4B
        .byte   $07                             ; FE4C
        .byte   $07                             ; FE4D
        .byte   $07                             ; FE4E
        .byte   $07                             ; FE4F
        .byte   $07                             ; FE50
        .byte   $07                             ; FE51
        .byte   $07                             ; FE52
        .byte   $07                             ; FE53
        .byte   $07                             ; FE54
        .byte   $07                             ; FE55
        .byte   $07                             ; FE56
        .byte   $07                             ; FE57
        .byte   $07                             ; FE58
        .byte   $07                             ; FE59
        .byte   $07                             ; FE5A
        .byte   $07                             ; FE5B
        .byte   $07                             ; FE5C
        .byte   $07                             ; FE5D
        .byte   $07                             ; FE5E
        .byte   $07                             ; FE5F
        .byte   $07                             ; FE60
        .byte   $07                             ; FE61
        .byte   $07                             ; FE62
        .byte   $07                             ; FE63
        .byte   $07                             ; FE64
        .byte   $07                             ; FE65
        .byte   $07                             ; FE66
        .byte   $07                             ; FE67
        .byte   $07                             ; FE68
        .byte   $07                             ; FE69
        .byte   $07                             ; FE6A
        .byte   $07                             ; FE6B
        .byte   $07                             ; FE6C
        .byte   $07                             ; FE6D
        .byte   $07                             ; FE6E
        .byte   $07                             ; FE6F
        .byte   $07                             ; FE70
        .byte   $07                             ; FE71
        .byte   $07                             ; FE72
        .byte   $07                             ; FE73
        .byte   $07                             ; FE74
        .byte   $07                             ; FE75
        .byte   $07                             ; FE76
        .byte   $07                             ; FE77
        .byte   $07                             ; FE78
        .byte   $07                             ; FE79
        .byte   $07                             ; FE7A
        .byte   $07                             ; FE7B
        rti                                     ; FE7C

; ----------------------------------------------------------------------------
        brk                                     ; FE7D
        .byte   $83                             ; FE7E
        .byte   $93                             ; FE7F
        .byte   $92                             ; FE80
        stx     $95,y                           ; FE81
        sta     $85                             ; FE83
        lda     $B6,x                           ; FE85
        .byte   $B2                             ; FE87
        .byte   $B3                             ; FE88
        .byte   $83                             ; FE89
        rti                                     ; FE8A

; ----------------------------------------------------------------------------
        ora     ($83,x)                         ; FE8B
        .byte   $B3                             ; FE8D
        .byte   $B2                             ; FE8E
        ldx     $B5,y                           ; FE8F
        sta     $85                             ; FE91
        sta     $96,x                           ; FE93
        .byte   $92                             ; FE95
        .byte   $93                             ; FE96
        .byte   $83                             ; FE97
        rti                                     ; FE98

; ----------------------------------------------------------------------------
        .byte   $0F                             ; FE99
LFE9A:  .byte   $02                             ; FE9A
        rts                                     ; FE9B

; ----------------------------------------------------------------------------
LFE9C:  .byte   $9E                             ; FE9C
LFE9D:  inc     $6280,x                         ; FE9D
        brk                                     ; FEA0
        plp                                     ; FEA1
        php                                     ; FEA2
        plp                                     ; FEA3
        bpl     LFECD                           ; FEA4
LFEA6:  .byte   $17                             ; FEA6
        and     $1E                             ; FEA7
LFEA9:  .byte   $23                             ; FEA9
        bit     $21                             ; FEAA
        rol     a                               ; FEAC
        .byte   $1E                             ; FEAD
        .byte   $30                             ; FEAE
LFEAF:  .byte   $1B                             ; FEAF
        rol     $17,x                           ; FEB0
        .byte   $3B                             ; FEB2
        .byte   $13                             ; FEB3
        rol     $410E,x                         ; FEB4
        php                                     ; FEB7
        .byte   $42                             ; FEB8
        brk                                     ; FEB9
        eor     ($F8,x)                         ; FEBA
        rol     $3BF2,x                         ; FEBC
        sbc     LE936                           ; FEBF
        bmi     LFEA9                           ; FEC2
        rol     a                               ; FEC4
LFEC5:  .byte   $E2                             ; FEC5
        bit     $DF                             ; FEC6
        asl     $17DD,x                         ; FEC8
        .byte   $DB                             ; FECB
        .byte   $10                             ; FECC
LFECD:  cmp     $D812,y                         ; FECD
        brk                                     ; FED0
        cld                                     ; FED1
        sed                                     ; FED2
        cld                                     ; FED3
        beq     LFEAF                           ; FED4
        sbc     #$DB                            ; FED6
        .byte   $E2                             ; FED8
        cmp     $DFDC,x                         ; FED9
        dec     $E3,x                           ; FEDC
        bne     LFEC5                           ; FEDE
        dex                                     ; FEE0
        sbc     #$C5                            ; FEE1
        sbc     LF2C2                           ; FEE3
        .byte   $BF                             ; FEE6
        sed                                     ; FEE7
        ldx     $BF00,y                         ; FEE8
        php                                     ; FEEB
        .byte   $C2                             ; FEEC
        asl     $13C5                           ; FEED
        dex                                     ; FEF0
        .byte   $17                             ; FEF1
        bne     LFF0F                           ; FEF2
        dec     $1E,x                           ; FEF4
        .byte   $DC                             ; FEF6
        and     ($E2,x)                         ; FEF7
        .byte   $23                             ; FEF9
        sbc     #$25                            ; FEFA
        beq     LFF25                           ; FEFC
        sed                                     ; FEFE
        plp                                     ; FEFF
        brk                                     ; FF00
        plp                                     ; FF01
        .byte   $80                             ; FF02
        .byte   $02                             ; FF03
LFF04:  .byte   $01                             ; FF04
LFF05:  brk                                     ; FF05
LFF06:  .byte   $07                             ; FF06
LFF07:  ora     a:$01                           ; FF07
        asl     $0B                             ; FF0A
        brk                                     ; FF0C
        .byte   $1E                             ; FF0D
        .byte   $04                             ; FF0E
LFF0F:  rti                                     ; FF0F

; ----------------------------------------------------------------------------
        brk                                     ; FF10
        rol     a                               ; FF11
        .byte   $04                             ; FF12
        rti                                     ; FF13

; ----------------------------------------------------------------------------
        brk                                     ; FF14
        rol     OAM_DATA,x                      ; FF15
        ora     ($00,x)                         ; FF18
        .byte   $06                             ; FF1A
LFF1B:  .byte   $0C                             ; FF1B
        brk                                     ; FF1C
        cli                                     ; FF1D
        ora     $20                             ; FF1E
        brk                                     ; FF20
        lda     $04,x                           ; FF21
        bpl     LFEA6                           ; FF23
LFF25:  .byte   $20                             ; FF25
LFF26:  plp                                     ; FF26
        .byte   $14                             ; FF27
        .byte   $C7                             ; FF28
        jsr     L4438                           ; FF29
        .byte   $D2                             ; FF2C
        jsr     L9C38                           ; FF2D
        .byte   $9B                             ; FF30
        jsr     LE428                           ; FF31
        .byte   $44                             ; FF34
        and     ($58,x)                         ; FF35
        bit     $2157                           ; FF37
        cli                                     ; FF3A
        cpy     $8A                             ; FF3B
        and     ($68,x)                         ; FF3D
        .byte   $5C                             ; FF3F
        sta     ($21),y                         ; FF40
        pla                                     ; FF42
        sty     $68,x                           ; FF43
        bmi     LFF8F                           ; FF45
LFF47:  .byte   $80                             ; FF47
        pla                                     ; FF48
        bne     LFF47                           ; FF49
        sed                                     ; FF4B
        .byte   $FF                             ; FF4C
        .byte   $FC                             ; FF4D
        brk                                     ; FF4E
        brk                                     ; FF4F
        .byte   $FF                             ; FF50
        .byte   $04                             ; FF51
        .byte   $FC                             ; FF52
        php                                     ; FF53
        bit     $2C2C                           ; FF54
        bit     $2C2C                           ; FF57
        cmp     ($D1,x)                         ; FF5A
        cpx     #$B7                            ; FF5C
        clv                                     ; FF5E
        sty     $9484                           ; FF5F
        lda     ($D0),y                         ; FF62
        bcs     LFF26                           ; FF64
        txa                                     ; FF66
        sta     $83                             ; FF67
        bne     LFF1B                           ; FF69
        cpy     #$8A                            ; FF6B
        sta     $83                             ; FF6D
        .byte   $8B                             ; FF6F
        .byte   $9B                             ; FF70
        cpy     #$8A                            ; FF71
        sta     $83                             ; FF73
        bne     LFF26                           ; FF75
        .byte   $BF                             ; FF77
        pha                                     ; FF78
        tay                                     ; FF79
        pha                                     ; FF7A
        cli                                     ; FF7B
        rts                                     ; FF7C

; ----------------------------------------------------------------------------
        tay                                     ; FF7D
        rts                                     ; FF7E

; ----------------------------------------------------------------------------
        cli                                     ; FF7F
        sei                                     ; FF80
        tay                                     ; FF81
        sei                                     ; FF82
        cli                                     ; FF83
        ora     ($FF,x)                         ; FF84
        ora     ($FF,x)                         ; FF86
        ora     ($FF,x)                         ; FF88
        ora     ($FF,x)                         ; FF8A
        ora     ($FE,x)                         ; FF8C
        .byte   $02                             ; FF8E
LFF8F:  .byte   $FF                             ; FF8F
        ora     ($FE,x)                         ; FF90
        .byte   $02                             ; FF92
        .byte   $FF                             ; FF93
        .byte   $02                             ; FF94
        inc     LFE02,x                         ; FF95
        .byte   $02                             ; FF98
        inc     LFE02,x                         ; FF99
        .byte   $03                             ; FF9C
        sbc     LFD03,x                         ; FF9D
        .byte   $03                             ; FFA0
        sbc     LFD03,x                         ; FFA1
        .byte   $0F                             ; FFA4
        brk                                     ; FFA5
        brk                                     ; FFA6
        asl     L000F                           ; FFA7
        bpl     LFFBB                           ; FFA9
        asl     L000F,x                         ; FFAB
        jsr     L2620                           ; FFAD
        .byte   $44                             ; FFB0
        cli                                     ; FFB1
        .byte   $FF                             ; FFB2
        .byte   $FF                             ; FFB3
        jmp     (L0130)                         ; FFB4

; ----------------------------------------------------------------------------
        .byte   $FF                             ; FFB7
        sty     $58,x                           ; FFB8
        .byte   $01                             ; FFBA
LFFBB:  ora     ($44,x)                         ; FFBB
        tay                                     ; FFBD
        .byte   $FF                             ; FFBE
        ora     ($6C,x)                         ; FFBF
        cld                                     ; FFC1
        ora     ($01,x)                         ; FFC2
        sty     $A8,x                           ; FFC4
        ora     ($FF,x)                         ; FFC6
        bmi     LFFCB                           ; FFC8
        .byte   $FF                             ; FFCA
LFFCB:  sty     $58,x                           ; FFCB
        ora     ($01,x)                         ; FFCD
        .byte   $44                             ; FFCF
        tay                                     ; FFD0
        .byte   $FF                             ; FFD1
        ora     ($6C,x)                         ; FFD2
        cld                                     ; FFD4
        ora     ($01,x)                         ; FFD5
        sty     $A8,x                           ; FFD7
        ora     ($FF,x)                         ; FFD9
        .byte   $FF                             ; FFDB
        .byte   $FF                             ; FFDC
        .byte   $FF                             ; FFDD
        .byte   $FF                             ; FFDE
LFFDF:  .byte   $FF                             ; FFDF
        .byte   $53                             ; FFE0
        .byte   $43                             ; FFE1
        pha                                     ; FFE2
        eor     $48                             ; FFE3
        eor     $52                             ; FFE5
        eor     ($5A,x)                         ; FFE7
        eor     ($44,x)                         ; FFE9
        eor     $20                             ; FFEB
        eor     $53,x                           ; FFED
        eor     ($18,x)                         ; FFEF
        iny                                     ; FFF1
        sta     $6A                             ; FFF2
        .byte   $33                             ; FFF4
LFFF5:  .byte   $04                             ; FFF5
        ora     (L000F,x)                       ; FFF6
        tsx                                     ; FFF8
        .byte   $10                             ; FFF9
Vector_NMI:
        .byte   $C9,$E3                         ; FFFA
Vector_RESET:
        .byte   $9B,$E1                         ; FFFC
Vector_IRQ:
        .byte   $9B,$E1                         ; FFFE
