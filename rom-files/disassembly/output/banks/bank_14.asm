; ============================================================================
; The Magic of Scheherazade - Bank 14 Disassembly
; ============================================================================
; File Offset: 0x1C000 - 0x1DFFF
; CPU Address: $C000 - $DFFF
; Size: 8192 bytes (8 KB)
; ============================================================================
;
; NOTE: This is a raw disassembly. Data regions interpreted as code will
; appear as garbage instructions. Further analysis needed to identify
; code vs data boundaries.
;
; ============================================================================

; da65 V2.19 - Git 034f73a
; Created:    2026-01-24 04:39:29
; Input file: C:/claude-workspace/TMOS_AI/rom-files/disassembly/output/banks/bank_14.bin
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
L0810           := $0810
PPU_CTRL        := $2000
PPU_MASK        := $2001
PPU_STATUS      := $2002
OAM_ADDR        := $2003
OAM_DATA        := $2004
PPU_SCROLL      := $2005
PPU_ADDR        := $2006
PPU_DATA        := $2007
L2021           := $2021
L2220           := $2220
OAM_DMA         := $4014
APU_STATUS      := $4015
JOY1            := $4016
JOY2_FRAME      := $4017
L4030           := $4030
L9274           := $9274
LB6D5           := $B6D5
LB7A9           := $B7A9
LB859           := $B859
LB8B0           := $B8B0
LBBBA           := $BBBA
LBBBD           := $BBBD
LBFA1           := $BFA1
LE000           := $E000
LE002           := $E002
LE006           := $E006
LE069           := $E069
LE06B           := $E06B
LE0EA           := $E0EA
LE8C8           := $E8C8
LE95B           := $E95B
LE97D           := $E97D
LE992           := $E992
LE9EB           := $E9EB
LEA7E           := $EA7E
LEAC1           := $EAC1
; ----------------------------------------------------------------------------
        .byte   $FF                             ; C000
        sta     $00                             ; C001
        inc     $00                             ; C003
        lda     $00                             ; C005
        sta     PPU_SCROLL                      ; C007
        lda     #$00                            ; C00A
        sta     PPU_SCROLL                      ; C00C
        lda     #$07                            ; C00F
        sta     $01                             ; C011
        ldy     #$01                            ; C013
        ldx     #$05                            ; C015
LC017:  lda     $8C85,y                         ; C017
        clc                                     ; C01A
        adc     $00                             ; C01B
        sta     $0620,x                         ; C01D
        iny                                     ; C020
        iny                                     ; C021
        clc                                     ; C022
        txa                                     ; C023
        adc     #$06                            ; C024
        tax                                     ; C026
        dec     $01                             ; C027
        bne     LC017                           ; C029
        rts                                     ; C02B

; ----------------------------------------------------------------------------
        lda     #$6E                            ; C02C
        jsr     LE992                           ; C02E
        ldy     #$03                            ; C031
LC033:  lda     LC05A,y                         ; C033
        sta     $0200,y                         ; C036
        dey                                     ; C039
        bpl     LC033                           ; C03A
        lda     #$3C                            ; C03C
        sta     $05F6                           ; C03E
        lda     #$00                            ; C041
        sta     $05F7                           ; C043
        sta     $05F8                           ; C046
LC049:  jsr     LE95B                           ; C049
        jsr     LBFA1                           ; C04C
LC04F:  lda     $05F6                           ; C04F
        bne     LC049                           ; C052
        lda     #$F0                            ; C054
        sta     $0200                           ; C056
        rts                                     ; C059

; ----------------------------------------------------------------------------
LC05A:  lsr     $0208,x                         ; C05A
        bmi     LC04F                           ; C05D
        .byte   $02                             ; C05F
        bcs     LC08D                           ; C060
        lda     #$00                            ; C062
        ldy     $0515                           ; C064
        beq     LC08D                           ; C067
        dey                                     ; C069
        sty     $0515                           ; C06A
        lda     #$32                            ; C06D
        sta     $81                             ; C06F
        txa                                     ; C071
        jsr     LCA62                           ; C072
        lda     #$1A                            ; C075
        jsr     LE992                           ; C077
        lda     $05D5                           ; C07A
        jsr     LC66A                           ; C07D
        jsr     LCEAF                           ; C080
        lda     #$43                            ; C083
        jsr     LCFA1                           ; C085
        jsr     LCEAF                           ; C088
        lda     $81                             ; C08B
LC08D:  rts                                     ; C08D

; ----------------------------------------------------------------------------
        beq     LC092                           ; C08E
        bcs     LC0C3                           ; C090
LC092:  lda     $0515,y                         ; C092
        beq     LC0C3                           ; C095
        sec                                     ; C097
        sbc     #$01                            ; C098
        sta     $0515,y                         ; C09A
        lda     #$32                            ; C09D
        sta     $03BE,x                         ; C09F
        txa                                     ; C0A2
        pha                                     ; C0A3
        lsr     a                               ; C0A4
        jsr     LCA62                           ; C0A5
        lda     #$1A                            ; C0A8
        jsr     LE992                           ; C0AA
        lda     $05D5                           ; C0AD
        jsr     LC66A                           ; C0B0
        jsr     LCEAF                           ; C0B3
        lda     #$43                            ; C0B6
        jsr     LCFA1                           ; C0B8
        jsr     LCEAF                           ; C0BB
        pla                                     ; C0BE
        tax                                     ; C0BF
        lda     $03BE,x                         ; C0C0
LC0C3:  rts                                     ; C0C3

; ----------------------------------------------------------------------------
LC0C4:  pha                                     ; C0C4
        jsr     LE95B                           ; C0C5
        pla                                     ; C0C8
        sta     $00                             ; C0C9
        pha                                     ; C0CB
        txa                                     ; C0CC
        pha                                     ; C0CD
        lda     $00                             ; C0CE
        tax                                     ; C0D0
        jsr     LC6F3                           ; C0D1
        lda     $0555,y                         ; C0D4
        php                                     ; C0D7
        txa                                     ; C0D8
        plp                                     ; C0D9
        bne     LC0E2                           ; C0DA
        jsr     LC52E                           ; C0DC
        jmp     LC0E5                           ; C0DF

; ----------------------------------------------------------------------------
LC0E2:  jsr     LC4E3                           ; C0E2
LC0E5:  pla                                     ; C0E5
        tax                                     ; C0E6
        pla                                     ; C0E7
        clc                                     ; C0E8
        adc     #$07                            ; C0E9
        cpx     #$00                            ; C0EB
        bne     LC0F3                           ; C0ED
        jsr     LC185                           ; C0EF
        rts                                     ; C0F2

; ----------------------------------------------------------------------------
LC0F3:  cpx     #$01                            ; C0F3
        bne     LC0FB                           ; C0F5
        jsr     LC1A5                           ; C0F7
        rts                                     ; C0FA

; ----------------------------------------------------------------------------
LC0FB:  cpx     #$02                            ; C0FB
        bne     LC103                           ; C0FD
        jsr     LC1B2                           ; C0FF
        rts                                     ; C102

; ----------------------------------------------------------------------------
LC103:  cpx     #$0C                            ; C103
        bne     LC10B                           ; C105
        jsr     LC124                           ; C107
        rts                                     ; C10A

; ----------------------------------------------------------------------------
LC10B:  pha                                     ; C10B
        lda     LC115,x                         ; C10C
        tax                                     ; C10F
        pla                                     ; C110
        jsr     LC1E1                           ; C111
        rts                                     ; C114

; ----------------------------------------------------------------------------
LC115:  brk                                     ; C115
        brk                                     ; C116
        brk                                     ; C117
        asl     $11,x                           ; C118
        .byte   $12                             ; C11A
        .byte   $13                             ; C11B
        .byte   $14                             ; C11C
        clc                                     ; C11D
        .byte   $1B                             ; C11E
        asl     a:$1F,x                         ; C11F
        .byte   $0E                             ; C122
        brk                                     ; C123
LC124:  pha                                     ; C124
        jsr     LC1B2                           ; C125
        pla                                     ; C128
        sec                                     ; C129
        sbc     #$07                            ; C12A
        pha                                     ; C12C
        jsr     LC6F3                           ; C12D
        lda     $054D,y                         ; C130
        jsr     LB8B0                           ; C133
        pla                                     ; C136
        jsr     LC3F4                           ; C137
        rts                                     ; C13A

; ----------------------------------------------------------------------------
LC13B:  cmp     #$03                            ; C13B
        bcc     LC14C                           ; C13D
        tay                                     ; C13F
        pha                                     ; C140
        txa                                     ; C141
        pha                                     ; C142
        tya                                     ; C143
        sbc     #$03                            ; C144
        jsr     LB7A9                           ; C146
        pla                                     ; C149
        tax                                     ; C14A
        pla                                     ; C14B
LC14C:  cpx     #$00                            ; C14C
        bne     LC154                           ; C14E
        jsr     LC185                           ; C150
        rts                                     ; C153

; ----------------------------------------------------------------------------
LC154:  cpx     #$01                            ; C154
        bne     LC15C                           ; C156
        jsr     LC1A5                           ; C158
        rts                                     ; C15B

; ----------------------------------------------------------------------------
LC15C:  cpx     #$02                            ; C15C
        bne     LC164                           ; C15E
        jsr     LC1B2                           ; C160
        rts                                     ; C163

; ----------------------------------------------------------------------------
LC164:  cpx     #$0C                            ; C164
        bne     LC16C                           ; C166
        jsr     LC1C9                           ; C168
        rts                                     ; C16B

; ----------------------------------------------------------------------------
LC16C:  pha                                     ; C16C
        lda     LC176,x                         ; C16D
        tax                                     ; C170
        pla                                     ; C171
        jsr     LC1E1                           ; C172
        rts                                     ; C175

; ----------------------------------------------------------------------------
LC176:  brk                                     ; C176
        brk                                     ; C177
        brk                                     ; C178
        ora     $0F,x                           ; C179
        bpl     LC17D                           ; C17B
LC17D:  brk                                     ; C17D
        .byte   $17                             ; C17E
        .byte   $1A                             ; C17F
        asl     a:$1F,x                         ; C180
        .byte   $0D                             ; C183
        brk                                     ; C184
LC185:  pha                                     ; C185
        lda     #$15                            ; C186
        jsr     LE992                           ; C188
        pla                                     ; C18B
        ldx     #$27                            ; C18C
LC18E:  jsr     LCF3A                           ; C18E
        txa                                     ; C191
        sta     $0620,y                         ; C192
        lda     #$30                            ; C195
        sta     $0621,y                         ; C197
LC19A:  lda     $0621,y                         ; C19A
        bne     LC19A                           ; C19D
        lda     #$FF                            ; C19F
        sta     $0620,y                         ; C1A1
        rts                                     ; C1A4

; ----------------------------------------------------------------------------
LC1A5:  pha                                     ; C1A5
        lda     #$17                            ; C1A6
        jsr     LE992                           ; C1A8
        pla                                     ; C1AB
        ldx     #$28                            ; C1AC
        jsr     LC18E                           ; C1AE
        rts                                     ; C1B1

; ----------------------------------------------------------------------------
LC1B2:  pha                                     ; C1B2
        lda     #$0F                            ; C1B3
        jsr     LE992                           ; C1B5
        pla                                     ; C1B8
        jsr     LCF3A                           ; C1B9
        lda     #$82                            ; C1BC
        sta     $0620,y                         ; C1BE
LC1C1:  lda     $0620,y                         ; C1C1
        cmp     #$FF                            ; C1C4
        bne     LC1C1                           ; C1C6
        rts                                     ; C1C8

; ----------------------------------------------------------------------------
LC1C9:  pha                                     ; C1C9
        jsr     LC1B2                           ; C1CA
        pla                                     ; C1CD
        sta     $01                             ; C1CE
        jsr     LC6F3                           ; C1D0
        lda     $050E,y                         ; C1D3
        tax                                     ; C1D6
        lda     $01                             ; C1D7
        jsr     LCF3A                           ; C1D9
        txa                                     ; C1DC
        sta     $0620,y                         ; C1DD
        rts                                     ; C1E0

; ----------------------------------------------------------------------------
LC1E1:  tay                                     ; C1E1
        txa                                     ; C1E2
        pha                                     ; C1E3
        tya                                     ; C1E4
        pha                                     ; C1E5
        jsr     LC1B2                           ; C1E6
        pla                                     ; C1E9
        jsr     LCF3A                           ; C1EA
        pla                                     ; C1ED
        sta     $0620,y                         ; C1EE
        lda     #$00                            ; C1F1
        sta     $0621,y                         ; C1F3
        rts                                     ; C1F6

; ----------------------------------------------------------------------------
        clc                                     ; C1F7
        adc     #$07                            ; C1F8
        jsr     LC1FE                           ; C1FA
        rts                                     ; C1FD

; ----------------------------------------------------------------------------
LC1FE:  pha                                     ; C1FE
        lda     #$13                            ; C1FF
        jsr     LE992                           ; C201
        pla                                     ; C204
        jsr     LCF3A                           ; C205
        lda     #$1F                            ; C208
        sta     $0620,y                         ; C20A
LC20D:  jsr     LE95B                           ; C20D
        lda     $0624,y                         ; C210
        tax                                     ; C213
        dex                                     ; C214
        txa                                     ; C215
        sta     $0624,y                         ; C216
        cmp     #$08                            ; C219
        bne     LC20D                           ; C21B
        lda     #$FF                            ; C21D
        sta     $0620,y                         ; C21F
        rts                                     ; C222

; ----------------------------------------------------------------------------
        ldx     #$02                            ; C223
LC225:  txa                                     ; C225
        jsr     LC6F3                           ; C226
        lda     $050E,y                         ; C229
        cmp     #$FF                            ; C22C
        beq     LC23E                           ; C22E
        txa                                     ; C230
        jsr     LCF3A                           ; C231
        lda     $0620,y                         ; C234
        sta     $05,x                           ; C237
        lda     #$82                            ; C239
        sta     $0620,y                         ; C23B
LC23E:  dex                                     ; C23E
        bpl     LC225                           ; C23F
LC241:  lda     $0620                           ; C241
        cmp     #$FF                            ; C244
        bne     LC241                           ; C246
        ldx     #$02                            ; C248
LC24A:  txa                                     ; C24A
        jsr     LCF3A                           ; C24B
        lda     $05,x                           ; C24E
        sta     $0620,y                         ; C250
        dex                                     ; C253
        bpl     LC24A                           ; C254
        rts                                     ; C256

; ----------------------------------------------------------------------------
        clc                                     ; C257
        adc     #$07                            ; C258
        jsr     LC25E                           ; C25A
        rts                                     ; C25D

; ----------------------------------------------------------------------------
LC25E:  pha                                     ; C25E
        lda     #$73                            ; C25F
        jsr     LE992                           ; C261
        pla                                     ; C264
        jsr     LCF3A                           ; C265
        lda     $0624,y                         ; C268
        sec                                     ; C26B
        sbc     #$08                            ; C26C
        sta     $0200                           ; C26E
        lda     #$2D                            ; C271
        sta     $0201                           ; C273
        lda     #$01                            ; C276
        sta     $0202                           ; C278
        clc                                     ; C27B
        lda     $0625,y                         ; C27C
        adc     #$06                            ; C27F
        sta     $0203                           ; C281
        lda     #$3C                            ; C284
        sta     $00                             ; C286
LC288:  jsr     LE95B                           ; C288
        dec     $00                             ; C28B
        bne     LC288                           ; C28D
        lda     #$F0                            ; C28F
        sta     $0200                           ; C291
        rts                                     ; C294

; ----------------------------------------------------------------------------
LC295:  lda     #$0C                            ; C295
        sta     $05DF                           ; C297
        lda     $53                             ; C29A
        sta     $54                             ; C29C
        lda     #$00                            ; C29E
        sta     $D8                             ; C2A0
LC2A2:  lda     $D8                             ; C2A2
        jsr     LCF3A                           ; C2A4
        sty     $D7                             ; C2A7
        lda     $D8                             ; C2A9
        cmp     #$0E                            ; C2AB
        bcs     LC2D2                           ; C2AD
        jsr     LC6F3                           ; C2AF
        lda     $050E,y                         ; C2B2
        cmp     #$FF                            ; C2B5
        bne     LC2C5                           ; C2B7
        ldy     $D7                             ; C2B9
        lda     #$FF                            ; C2BB
        sta     $0620,y                         ; C2BD
        beq     LC2C5                           ; C2C0
        jmp     LC347                           ; C2C2

; ----------------------------------------------------------------------------
LC2C5:  lda     $D8                             ; C2C5
        cmp     #$07                            ; C2C7
        bcc     LC2D2                           ; C2C9
        lda     $0510,y                         ; C2CB
        and     #$0F                            ; C2CE
        nop                                     ; C2D0
        nop                                     ; C2D1
LC2D2:  ldy     $D7                             ; C2D2
        lda     $0620,y                         ; C2D4
        cmp     #$FF                            ; C2D7
        beq     LC347                           ; C2D9
        and     #$80                            ; C2DB
        beq     LC2E4                           ; C2DD
        jsr     LC365                           ; C2DF
        ldy     $D7                             ; C2E2
LC2E4:  lda     $0621,y                         ; C2E4
        beq     LC331                           ; C2E7
        tax                                     ; C2E9
        dex                                     ; C2EA
        txa                                     ; C2EB
        sta     $0621,y                         ; C2EC
        bne     LC331                           ; C2EF
        lda     $0620,y                         ; C2F1
        cmp     #$29                            ; C2F4
        bcc     LC347                           ; C2F6
        cmp     #$32                            ; C2F8
        bcs     LC347                           ; C2FA
        lda     $0622,y                         ; C2FC
        sta     $D0                             ; C2FF
        lda     $0623,y                         ; C301
        sta     $D1                             ; C304
        ldx     $D7                             ; C306
        ldy     #$00                            ; C308
        lda     ($D0),y                         ; C30A
        cmp     #$FF                            ; C30C
        bne     LC315                           ; C30E
        sta     $0620,x                         ; C310
        beq     LC347                           ; C313
LC315:  cmp     #$FE                            ; C315
        beq     LC331                           ; C317
        sta     $0620,x                         ; C319
        iny                                     ; C31C
        lda     ($D0),y                         ; C31D
        sta     $0621,x                         ; C31F
        clc                                     ; C322
        lda     #$02                            ; C323
        adc     $D0                             ; C325
        sta     $0622,x                         ; C327
        lda     #$00                            ; C32A
        adc     $D1                             ; C32C
        sta     $0623,x                         ; C32E
LC331:  ldx     $D7                             ; C331
        lda     $0624,x                         ; C333
        sta     $D3                             ; C336
        lda     $0625,x                         ; C338
        sta     $D4                             ; C33B
        lda     $0620,x                         ; C33D
        cmp     #$FF                            ; C340
        beq     LC347                           ; C342
        jsr     LC391                           ; C344
LC347:  inc     $D8                             ; C347
        lda     $D8                             ; C349
        cmp     #$20                            ; C34B
        beq     LC352                           ; C34D
        jmp     LC2A2                           ; C34F

; ----------------------------------------------------------------------------
LC352:  lda     #$F0                            ; C352
        ldx     $05DF                           ; C354
        ldy     $54                             ; C357
        sty     $53                             ; C359
LC35B:  sta     $0200,x                         ; C35B
        inx                                     ; C35E
        inx                                     ; C35F
        inx                                     ; C360
        inx                                     ; C361
        bne     LC35B                           ; C362
        rts                                     ; C364

; ----------------------------------------------------------------------------
LC365:  lda     $0620,y                         ; C365
        and     #$7F                            ; C368
        sty     $D7                             ; C36A
        sta     $0620,y                         ; C36C
        asl     a                               ; C36F
        tax                                     ; C370
        lda     $8CAC,x                         ; C371
        sta     $0622,y                         ; C374
        sta     $D0                             ; C377
        lda     $8CAD,x                         ; C379
        sta     $0623,y                         ; C37C
        sta     $D1                             ; C37F
        ldy     #$00                            ; C381
        ldx     $D7                             ; C383
        lda     ($D0),y                         ; C385
        sta     $0620,x                         ; C387
        iny                                     ; C38A
        lda     ($D0),y                         ; C38B
        sta     $0621,x                         ; C38D
        rts                                     ; C390

; ----------------------------------------------------------------------------
LC391:  asl     a                               ; C391
        tay                                     ; C392
        lda     $8CC7,y                         ; C393
        sta     $D5                             ; C396
        lda     $8CC8,y                         ; C398
        sta     $D6                             ; C39B
        ldy     #$00                            ; C39D
        lda     ($D5),y                         ; C39F
        sta     $D2                             ; C3A1
        ldy     #$01                            ; C3A3
        ldx     $05DF                           ; C3A5
LC3A8:  lda     ($D5),y                         ; C3A8
        clc                                     ; C3AA
        adc     $D3                             ; C3AB
        sta     $0200,x                         ; C3AD
        iny                                     ; C3B0
        inx                                     ; C3B1
        lda     ($D5),y                         ; C3B2
        sta     $0200,x                         ; C3B4
        inx                                     ; C3B7
        iny                                     ; C3B8
        lda     ($D5),y                         ; C3B9
        sta     $0200,x                         ; C3BB
        inx                                     ; C3BE
        iny                                     ; C3BF
        lda     ($D5),y                         ; C3C0
        clc                                     ; C3C2
        adc     $D4                             ; C3C3
        sta     $0200,x                         ; C3C5
        inx                                     ; C3C8
        iny                                     ; C3C9
        dec     $D2                             ; C3CA
        bne     LC3A8                           ; C3CC
        stx     $05DF                           ; C3CE
        rts                                     ; C3D1

; ----------------------------------------------------------------------------
        lda     #$00                            ; C3D2
LC3D4:  pha                                     ; C3D4
        sta     $00                             ; C3D5
        asl     a                               ; C3D7
        asl     a                               ; C3D8
        asl     a                               ; C3D9
        clc                                     ; C3DA
        adc     $00                             ; C3DB
        tay                                     ; C3DD
        lda     $054D,y                         ; C3DE
        bmi     LC3EB                           ; C3E1
        jsr     LB8B0                           ; C3E3
        pla                                     ; C3E6
        pha                                     ; C3E7
        jsr     LC3F4                           ; C3E8
LC3EB:  pla                                     ; C3EB
        tax                                     ; C3EC
        inx                                     ; C3ED
        txa                                     ; C3EE
        cpx     #$07                            ; C3EF
        bne     LC3D4                           ; C3F1
        rts                                     ; C3F3

; ----------------------------------------------------------------------------
LC3F4:  pha                                     ; C3F4
        jsr     LCFA9                           ; C3F5
        lda     $1C                             ; C3F8
        ora     #$02                            ; C3FA
        sta     $1C                             ; C3FC
        pla                                     ; C3FE
        pha                                     ; C3FF
        asl     a                               ; C400
        tay                                     ; C401
        lda     $8BDC,y                         ; C402
        sta     $06                             ; C405
        iny                                     ; C407
        lda     $8BDC,y                         ; C408
        sta     $07                             ; C40B
        pla                                     ; C40D
        sta     $00                             ; C40E
        asl     a                               ; C410
        asl     a                               ; C411
        asl     a                               ; C412
        clc                                     ; C413
        adc     $00                             ; C414
        tay                                     ; C416
        lda     $054D,y                         ; C417
        sta     $05CB                           ; C41A
        sec                                     ; C41D
        sbc     #$0D                            ; C41E
        asl     a                               ; C420
        tay                                     ; C421
        lda     $8ADB,y                         ; C422
        sta     $0A                             ; C425
        lda     $8ADC,y                         ; C427
        sta     $0B                             ; C42A
        ldy     #$00                            ; C42C
        lda     ($0A),y                         ; C42E
        sta     $0D                             ; C430
        lda     #$06                            ; C432
        sec                                     ; C434
        sbc     $0D                             ; C435
        tax                                     ; C437
        beq     LC44A                           ; C438
LC43A:  clc                                     ; C43A
        lda     #$20                            ; C43B
        adc     $06                             ; C43D
        sta     $06                             ; C43F
        lda     #$00                            ; C441
        adc     $07                             ; C443
        sta     $07                             ; C445
        dex                                     ; C447
        bne     LC43A                           ; C448
LC44A:  ldy     #$01                            ; C44A
        ldx     $0162                           ; C44C
        lda     #$04                            ; C44F
        sta     $08                             ; C451
LC453:  lda     $0D                             ; C453
        sta     $09                             ; C455
        lda     $07                             ; C457
        sta     $05                             ; C459
        sta     $0163,x                         ; C45B
        inx                                     ; C45E
        lda     $06                             ; C45F
        sta     $04                             ; C461
        sta     $0163,x                         ; C463
        inx                                     ; C466
        lda     $0D                             ; C467
        ora     #$80                            ; C469
        sta     $0163,x                         ; C46B
        inx                                     ; C46E
LC46F:  lda     ($0A),y                         ; C46F
        sta     $0163,x                         ; C471
        iny                                     ; C474
        inx                                     ; C475
        lda     $04                             ; C476
        lsr     a                               ; C478
        bcs     LC486                           ; C479
        tya                                     ; C47B
        pha                                     ; C47C
        txa                                     ; C47D
        pha                                     ; C47E
        jsr     LB859                           ; C47F
        pla                                     ; C482
        tax                                     ; C483
        pla                                     ; C484
        tay                                     ; C485
LC486:  clc                                     ; C486
        lda     $04                             ; C487
        adc     #$20                            ; C489
        sta     $04                             ; C48B
        lda     $05                             ; C48D
        adc     #$00                            ; C48F
        sta     $05                             ; C491
        dec     $09                             ; C493
        bne     LC46F                           ; C495
        clc                                     ; C497
        lda     $06                             ; C498
        adc     #$01                            ; C49A
        sta     $06                             ; C49C
        lda     $07                             ; C49E
        adc     #$00                            ; C4A0
        sta     $07                             ; C4A2
        dec     $08                             ; C4A4
        bne     LC453                           ; C4A6
        lda     #$00                            ; C4A8
        sta     $0163,x                         ; C4AA
        stx     $0162                           ; C4AD
        lda     $1C                             ; C4B0
        and     #$FD                            ; C4B2
        sta     $1C                             ; C4B4
        jsr     LE95B                           ; C4B6
        ldx     $0162                           ; C4B9
        ldy     #$00                            ; C4BC
        lda     #$23                            ; C4BE
        sta     $0163,x                         ; C4C0
        inx                                     ; C4C3
        lda     #$C0                            ; C4C4
        sta     $0163,x                         ; C4C6
        inx                                     ; C4C9
        lda     #$18                            ; C4CA
        sta     $0163,x                         ; C4CC
        inx                                     ; C4CF
LC4D0:  lda     $04C0,y                         ; C4D0
        sta     $0163,x                         ; C4D3
        iny                                     ; C4D6
        inx                                     ; C4D7
        cpy     #$18                            ; C4D8
        bne     LC4D0                           ; C4DA
LC4DC:  jsr     L9274                           ; C4DC
        jsr     LE95B                           ; C4DF
        rts                                     ; C4E2

; ----------------------------------------------------------------------------
LC4E3:  ldy     #$C6                            ; C4E3
        sty     $04                             ; C4E5
LC4E7:  asl     a                               ; C4E7
        clc                                     ; C4E8
        adc     #$DC                            ; C4E9
        sta     $00                             ; C4EB
        lda     #$8B                            ; C4ED
        adc     #$00                            ; C4EF
        sta     $01                             ; C4F1
        ldy     #$00                            ; C4F3
        lda     ($00),y                         ; C4F5
        sta     $03                             ; C4F7
        iny                                     ; C4F9
        lda     ($00),y                         ; C4FA
        sta     $02                             ; C4FC
        ldx     $0162                           ; C4FE
        ldy     #$04                            ; C501
LC503:  lda     $02                             ; C503
        sta     $0163,x                         ; C505
        inx                                     ; C508
        lda     $03                             ; C509
        sta     $0163,x                         ; C50B
        inx                                     ; C50E
        lda     $04                             ; C50F
        sta     $0163,x                         ; C511
        inx                                     ; C514
        lda     #$2C                            ; C515
        sta     $0163,x                         ; C517
        inx                                     ; C51A
        clc                                     ; C51B
        lda     $03                             ; C51C
        adc     #$01                            ; C51E
        sta     $03                             ; C520
        lda     $02                             ; C522
        adc     #$00                            ; C524
        sta     $02                             ; C526
        dey                                     ; C528
        bne     LC503                           ; C529
        jmp     LC4DC                           ; C52B

; ----------------------------------------------------------------------------
LC52E:  ldy     #$C7                            ; C52E
        sty     $04                             ; C530
        jsr     LC4E7                           ; C532
        rts                                     ; C535

; ----------------------------------------------------------------------------
        ldx     #$00                            ; C536
LC538:  txa                                     ; C538
        pha                                     ; C539
        jsr     LC6F3                           ; C53A
        lda     $054D,y                         ; C53D
        cmp     #$FF                            ; C540
        beq     LC549                           ; C542
        pla                                     ; C544
        pha                                     ; C545
        jsr     LC551                           ; C546
LC549:  pla                                     ; C549
        tax                                     ; C54A
        inx                                     ; C54B
        cpx     #$07                            ; C54C
        bne     LC538                           ; C54E
        rts                                     ; C550

; ----------------------------------------------------------------------------
LC551:  pha                                     ; C551
        jsr     LC6F3                           ; C552
        lda     $0555,y                         ; C555
        jsr     LCE39                           ; C558
        ldx     $0162                           ; C55B
        lda     #$21                            ; C55E
        sta     $0163,x                         ; C560
        pla                                     ; C563
        asl     a                               ; C564
        asl     a                               ; C565
        clc                                     ; C566
        adc     #$42                            ; C567
        inx                                     ; C569
        sta     $0163,x                         ; C56A
        inx                                     ; C56D
        lda     #$03                            ; C56E
        ldy     #$00                            ; C570
        sta     $0163,x                         ; C572
        inx                                     ; C575
LC576:  lda     $0D,y                           ; C576
        sta     $0163,x                         ; C579
        inx                                     ; C57C
        iny                                     ; C57D
        cpy     #$03                            ; C57E
        bne     LC576                           ; C580
        lda     #$00                            ; C582
        sta     $0163,x                         ; C584
        stx     $0162                           ; C587
        jsr     LE95B                           ; C58A
        rts                                     ; C58D

; ----------------------------------------------------------------------------
        ldx     #$00                            ; C58E
LC590:  txa                                     ; C590
        pha                                     ; C591
        jsr     LC6F3                           ; C592
        lda     $050E,y                         ; C595
        cmp     #$FF                            ; C598
        beq     LC5A1                           ; C59A
        pla                                     ; C59C
        pha                                     ; C59D
        jsr     LC5A9                           ; C59E
LC5A1:  pla                                     ; C5A1
        tax                                     ; C5A2
        inx                                     ; C5A3
        cpx     #$03                            ; C5A4
        bne     LC590                           ; C5A6
        rts                                     ; C5A8

; ----------------------------------------------------------------------------
LC5A9:  pha                                     ; C5A9
        jsr     LC6F3                           ; C5AA
        lda     $81                             ; C5AD
        ldx     $050E,y                         ; C5AF
        beq     LC5BA                           ; C5B2
        txa                                     ; C5B4
        asl     a                               ; C5B5
        tax                                     ; C5B6
        lda     $03BE,x                         ; C5B7
LC5BA:  jsr     LCE39                           ; C5BA
        pla                                     ; C5BD
        asl     a                               ; C5BE
        tay                                     ; C5BF
        ldx     $0162                           ; C5C0
        lda     LC5F1,y                         ; C5C3
        sta     $0163,x                         ; C5C6
        inx                                     ; C5C9
        lda     LC5F2,y                         ; C5CA
        sta     $0163,x                         ; C5CD
        inx                                     ; C5D0
        lda     #$03                            ; C5D1
        sta     $0163,x                         ; C5D3
        inx                                     ; C5D6
LC5D7:  ldy     #$00                            ; C5D7
LC5D9:  lda     $0D,y                           ; C5D9
        sta     $0163,x                         ; C5DC
        iny                                     ; C5DF
        inx                                     ; C5E0
        cpy     #$03                            ; C5E1
        bne     LC5D9                           ; C5E3
        lda     #$00                            ; C5E5
        sta     $0163,x                         ; C5E7
        stx     $0162                           ; C5EA
        jsr     LE95B                           ; C5ED
        rts                                     ; C5F0

; ----------------------------------------------------------------------------
LC5F1:  .byte   $21                             ; C5F1
LC5F2:  .byte   $DB                             ; C5F2
        .byte   $23                             ; C5F3
        .byte   $17                             ; C5F4
        .byte   $23                             ; C5F5
        .byte   $1C                             ; C5F6
        ldx     #$00                            ; C5F7
LC5F9:  txa                                     ; C5F9
        pha                                     ; C5FA
        jsr     LC6F3                           ; C5FB
        lda     $050E,y                         ; C5FE
        cmp     #$FF                            ; C601
        beq     LC60A                           ; C603
        pla                                     ; C605
        pha                                     ; C606
        jsr     LC612                           ; C607
LC60A:  pla                                     ; C60A
        tax                                     ; C60B
        inx                                     ; C60C
        cpx     #$03                            ; C60D
        bne     LC5F9                           ; C60F
        rts                                     ; C611

; ----------------------------------------------------------------------------
LC612:  pha                                     ; C612
        jsr     LC6F3                           ; C613
        lda     $050E,y                         ; C616
        bne     LC626                           ; C619
        ldx     #$02                            ; C61B
LC61D:  lda     $8C,x                           ; C61D
        sta     $0D,x                           ; C61F
        dex                                     ; C621
        bpl     LC61D                           ; C622
        bmi     LC62E                           ; C624
LC626:  asl     a                               ; C626
        tax                                     ; C627
        lda     $03BF,x                         ; C628
        jsr     LCE39                           ; C62B
LC62E:  pla                                     ; C62E
        asl     a                               ; C62F
        tay                                     ; C630
        ldx     $0162                           ; C631
        lda     LC5F1,y                         ; C634
        sta     $0163,x                         ; C637
        inx                                     ; C63A
        lda     LC5F2,y                         ; C63B
        clc                                     ; C63E
        adc     #$20                            ; C63F
        sta     $0163,x                         ; C641
        inx                                     ; C644
        lda     #$03                            ; C645
        sta     $0163,x                         ; C647
        inx                                     ; C64A
        jsr     LC5D7                           ; C64B
        rts                                     ; C64E

; ----------------------------------------------------------------------------
        ldx     #$00                            ; C64F
LC651:  txa                                     ; C651
        pha                                     ; C652
        jsr     LC6F3                           ; C653
        lda     $050E,y                         ; C656
        cmp     #$FF                            ; C659
        beq     LC662                           ; C65B
        pla                                     ; C65D
        pha                                     ; C65E
        jsr     LC66A                           ; C65F
LC662:  pla                                     ; C662
        tax                                     ; C663
        inx                                     ; C664
        cpx     #$03                            ; C665
        bne     LC651                           ; C667
        rts                                     ; C669

; ----------------------------------------------------------------------------
LC66A:  pha                                     ; C66A
        asl     a                               ; C66B
        tay                                     ; C66C
        ldx     $0162                           ; C66D
        lda     LC6AA,y                         ; C670
        sta     $0163,x                         ; C673
        inx                                     ; C676
        lda     LC6AB,y                         ; C677
        sta     $0163,x                         ; C67A
        inx                                     ; C67D
        lda     #$02                            ; C67E
        sta     $0163,x                         ; C680
        inx                                     ; C683
        pla                                     ; C684
        jsr     LC6F3                           ; C685
        lda     $0515,y                         ; C688
LC68B:  stx     $00                             ; C68B
        jsr     LCE39                           ; C68D
        ldx     $00                             ; C690
        lda     $0E                             ; C692
        sta     $0163,x                         ; C694
        inx                                     ; C697
        lda     $0F                             ; C698
        sta     $0163,x                         ; C69A
        inx                                     ; C69D
        lda     #$00                            ; C69E
        sta     $0163,x                         ; C6A0
        stx     $0162                           ; C6A3
        jsr     LE95B                           ; C6A6
        rts                                     ; C6A9

; ----------------------------------------------------------------------------
LC6AA:  .byte   $22                             ; C6AA
LC6AB:  .byte   $1B                             ; C6AB
        .byte   $23                             ; C6AC
        .byte   $57                             ; C6AD
        .byte   $23                             ; C6AE
        .byte   $5C                             ; C6AF
        ldx     #$00                            ; C6B0
LC6B2:  txa                                     ; C6B2
        pha                                     ; C6B3
        jsr     LC6F3                           ; C6B4
        lda     $050E,y                         ; C6B7
        cmp     #$FF                            ; C6BA
        beq     LC6C3                           ; C6BC
        pla                                     ; C6BE
        pha                                     ; C6BF
        jsr     LC6CB                           ; C6C0
LC6C3:  pla                                     ; C6C3
        tax                                     ; C6C4
        inx                                     ; C6C5
        cpx     #$03                            ; C6C6
        bne     LC6B2                           ; C6C8
        rts                                     ; C6CA

; ----------------------------------------------------------------------------
LC6CB:  pha                                     ; C6CB
        asl     a                               ; C6CC
        tay                                     ; C6CD
        ldx     $0162                           ; C6CE
        lda     LC6AA,y                         ; C6D1
        sta     $0163,x                         ; C6D4
        inx                                     ; C6D7
        lda     LC6AB,y                         ; C6D8
        clc                                     ; C6DB
        adc     #$20                            ; C6DC
        sta     $0163,x                         ; C6DE
        inx                                     ; C6E1
        lda     #$02                            ; C6E2
        sta     $0163,x                         ; C6E4
        inx                                     ; C6E7
        pla                                     ; C6E8
        jsr     LC6F3                           ; C6E9
        lda     $0516,y                         ; C6EC
        jsr     LC68B                           ; C6EF
        rts                                     ; C6F2

; ----------------------------------------------------------------------------
LC6F3:  sta     $53                             ; C6F3
        asl     a                               ; C6F5
        asl     a                               ; C6F6
        asl     a                               ; C6F7
        clc                                     ; C6F8
        adc     $53                             ; C6F9
        tay                                     ; C6FB
        rts                                     ; C6FC

; ----------------------------------------------------------------------------
        lda     #$00                            ; C6FD
        sta     $00                             ; C6FF
        beq     LC707                           ; C701
        lda     #$01                            ; C703
        sta     $00                             ; C705
LC707:  ldy     #$00                            ; C707
LC709:  tya                                     ; C709
        lsr     a                               ; C70A
        tax                                     ; C70B
        lda     $0335,x                         ; C70C
        beq     LC731                           ; C70F
        lda     $03C0,y                         ; C711
        bne     LC71A                           ; C714
        lda     $00                             ; C716
        bne     LC731                           ; C718
LC71A:  clc                                     ; C71A
        lda     $84                             ; C71B
        adc     #$05                            ; C71D
        sec                                     ; C71F
        sbc     $8CA1,x                         ; C720
        asl     a                               ; C723
        tax                                     ; C724
        lda     $8C10,x                         ; C725
        sta     $03C0,y                         ; C728
        lda     $8C11,x                         ; C72B
        sta     $03C1,y                         ; C72E
LC731:  iny                                     ; C731
        iny                                     ; C732
        cpy     #$16                            ; C733
        bne     LC709                           ; C735
        clc                                     ; C737
        lda     $84                             ; C738
        adc     #$05                            ; C73A
        asl     a                               ; C73C
        tay                                     ; C73D
        lda     $8C10,y                         ; C73E
        sta     $81                             ; C741
        lda     $8C11,y                         ; C743
        jsr     LCE39                           ; C746
        ldx     #$02                            ; C749
LC74B:  lda     $0D,x                           ; C74B
        sta     $8C,x                           ; C74D
        dex                                     ; C74F
        bpl     LC74B                           ; C750
        rts                                     ; C752

; ----------------------------------------------------------------------------
        lda     #$00                            ; C753
LC755:  pha                                     ; C755
        jsr     LC762                           ; C756
        pla                                     ; C759
        tax                                     ; C75A
        inx                                     ; C75B
        txa                                     ; C75C
        cpx     #$03                            ; C75D
        bne     LC755                           ; C75F
        rts                                     ; C761

; ----------------------------------------------------------------------------
LC762:  pha                                     ; C762
        jsr     LC6F3                           ; C763
        lda     $050E,y                         ; C766
        bne     LC782                           ; C769
        jsr     LC9A7                           ; C76B
        sec                                     ; C76E
        lda     $02                             ; C76F
        sbc     $05D2                           ; C771
        jsr     LCE39                           ; C774
        ldx     #$02                            ; C777
LC779:  lda     $0D,x                           ; C779
        sta     $8C,x                           ; C77B
        dex                                     ; C77D
        bpl     LC779                           ; C77E
        bmi     LC78E                           ; C780
LC782:  asl     a                               ; C782
        tax                                     ; C783
        lda     $03BF,x                         ; C784
        sec                                     ; C787
        sbc     $05D2                           ; C788
        sta     $03BF,x                         ; C78B
LC78E:  pla                                     ; C78E
        jsr     LC612                           ; C78F
        rts                                     ; C792

; ----------------------------------------------------------------------------
        pha                                     ; C793
        jsr     LC6F3                           ; C794
        lda     $050E,y                         ; C797
        sty     $52                             ; C79A
        bne     LC7D6                           ; C79C
        jsr     LC9A7                           ; C79E
        lda     $02                             ; C7A1
        sta     $50                             ; C7A3
        cmp     $05D2                           ; C7A5
        bcs     LC7F7                           ; C7A8
        adc     #$32                            ; C7AA
        sta     $50                             ; C7AC
        ldx     $52                             ; C7AE
        dec     $0516,x                         ; C7B0
        pla                                     ; C7B3
        pha                                     ; C7B4
        jsr     LC6CB                           ; C7B5
        lda     $50                             ; C7B8
        sta     $02                             ; C7BA
        jsr     LCAA5                           ; C7BC
LC7BF:  pla                                     ; C7BF
        jsr     LC612                           ; C7C0
        lda     #$1B                            ; C7C3
        jsr     LE992                           ; C7C5
        ldy     $52                             ; C7C8
        lda     $050E,y                         ; C7CA
        sta     $0500                           ; C7CD
        lda     #$44                            ; C7D0
        jsr     LCFA1                           ; C7D2
        rts                                     ; C7D5

; ----------------------------------------------------------------------------
LC7D6:  asl     a                               ; C7D6
        tax                                     ; C7D7
        lda     $03BF,x                         ; C7D8
        cmp     $05D2                           ; C7DB
        bcs     LC7F7                           ; C7DE
        adc     #$32                            ; C7E0
        sta     $03BF,x                         ; C7E2
        ldx     $52                             ; C7E5
        dec     $0516,x                         ; C7E7
        pla                                     ; C7EA
        pha                                     ; C7EB
        jsr     LC6CB                           ; C7EC
        pla                                     ; C7EF
        pha                                     ; C7F0
        jsr     LCA9A                           ; C7F1
        jmp     LC7BF                           ; C7F4

; ----------------------------------------------------------------------------
LC7F7:  pla                                     ; C7F7
        rts                                     ; C7F8

; ----------------------------------------------------------------------------
        lda     #$05                            ; C7F9
        sta     $01                             ; C7FB
LC7FD:  lda     $01                             ; C7FD
        sta     $00                             ; C7FF
        asl     a                               ; C801
        asl     a                               ; C802
        clc                                     ; C803
        adc     $00                             ; C804
        tax                                     ; C806
        lda     #$03                            ; C807
        sta     $02                             ; C809
LC80B:  lda     #$02                            ; C80B
        sta     $03                             ; C80D
LC80F:  lda     $03                             ; C80F
        jsr     LC6F3                           ; C811
        lda     $050E,y                         ; C814
        cmp     $89C0,x                         ; C817
        beq     LC82A                           ; C81A
        dec     $03                             ; C81C
        bpl     LC80F                           ; C81E
        dec     $01                             ; C820
        bpl     LC7FD                           ; C822
        lda     #$00                            ; C824
        sta     $05C2                           ; C826
        rts                                     ; C829

; ----------------------------------------------------------------------------
LC82A:  inx                                     ; C82A
        dec     $02                             ; C82B
        bne     LC80B                           ; C82D
        inc     $01                             ; C82F
        lda     $01                             ; C831
        sta     $05C2                           ; C833
        rts                                     ; C836

; ----------------------------------------------------------------------------
        lda     #$05                            ; C837
        sta     $01                             ; C839
LC83B:  lda     $01                             ; C83B
        asl     a                               ; C83D
        sta     $00                             ; C83E
        asl     a                               ; C840
        adc     $00                             ; C841
        tax                                     ; C843
        lda     #$02                            ; C844
        sta     $02                             ; C846
LC848:  lda     #$06                            ; C848
        sta     $03                             ; C84A
LC84C:  lda     $03                             ; C84C
        jsr     LC6F3                           ; C84E
        lda     $054D,y                         ; C851
        cmp     $899C,x                         ; C854
        bcc     LC85E                           ; C857
        cmp     $899D,x                         ; C859
        bcc     LC86C                           ; C85C
LC85E:  dec     $03                             ; C85E
        bpl     LC84C                           ; C860
        dec     $01                             ; C862
        bpl     LC83B                           ; C864
        lda     #$00                            ; C866
        sta     $05C3                           ; C868
        rts                                     ; C86B

; ----------------------------------------------------------------------------
LC86C:  inx                                     ; C86C
        inx                                     ; C86D
        dec     $02                             ; C86E
        bne     LC848                           ; C870
        inc     $01                             ; C872
        lda     $01                             ; C874
        sta     $05C3                           ; C876
        rts                                     ; C879

; ----------------------------------------------------------------------------
LC87A:  sta     $00                             ; C87A
        asl     a                               ; C87C
        adc     $00                             ; C87D
        tay                                     ; C87F
        lda     $05E0,y                         ; C880
        jsr     LE069                           ; C883
        jsr     LCDD5                           ; C886
        iny                                     ; C889
        lda     $05E0,y                         ; C88A
        tax                                     ; C88D
        ldy     #$02                            ; C88E
        lda     ($00),y                         ; C890
        sta     $00                             ; C892
        lda     #$00                            ; C894
LC896:  clc                                     ; C896
        adc     $00                             ; C897
        dex                                     ; C899
        bne     LC896                           ; C89A
        rts                                     ; C89C

; ----------------------------------------------------------------------------
LC89D:  jsr     LE069                           ; C89D
        jsr     LCDD5                           ; C8A0
        ldy     #$03                            ; C8A3
        lda     ($00),y                         ; C8A5
        cmp     #$FF                            ; C8A7
        clc                                     ; C8A9
        beq     LC8AF                           ; C8AA
        jsr     LCE8D                           ; C8AC
LC8AF:  rts                                     ; C8AF

; ----------------------------------------------------------------------------
LC8B0:  lda     #$06                            ; C8B0
        sta     $02                             ; C8B2
        sta     $03                             ; C8B4
LC8B6:  lda     $03                             ; C8B6
        jsr     LC6F3                           ; C8B8
        lda     $054D,y                         ; C8BB
        bmi     LC8D1                           ; C8BE
        jsr     LCDD5                           ; C8C0
        ldy     #$05                            ; C8C3
        lda     ($00),y                         ; C8C5
        cmp     #$FF                            ; C8C7
        beq     LC8DA                           ; C8C9
        cmp     $02                             ; C8CB
        bcs     LC8D1                           ; C8CD
        sta     $02                             ; C8CF
LC8D1:  dec     $03                             ; C8D1
        bpl     LC8B6                           ; C8D3
        lda     $02                             ; C8D5
        jsr     LCE8D                           ; C8D7
LC8DA:  rts                                     ; C8DA

; ----------------------------------------------------------------------------
        tax                                     ; C8DB
        jsr     LC6F3                           ; C8DC
        lda     $054D,y                         ; C8DF
        cmp     #$FF                            ; C8E2
        beq     LC8F8                           ; C8E4
        lda     #$09                            ; C8E6
        cmp     $0555,y                         ; C8E8
        bcc     LC8F8                           ; C8EB
        lda     $054D,y                         ; C8ED
        jsr     LCDD5                           ; C8F0
        ldy     #$04                            ; C8F3
        jsr     LCE8D                           ; C8F5
LC8F8:  rts                                     ; C8F8

; ----------------------------------------------------------------------------
        ldx     #$06                            ; C8F9
        lda     #$00                            ; C8FB
        sta     $01                             ; C8FD
LC8FF:  txa                                     ; C8FF
        jsr     LC6F3                           ; C900
        lda     $054D,y                         ; C903
        cmp     #$10                            ; C906
        bne     LC90C                           ; C908
        inc     $01                             ; C90A
LC90C:  dex                                     ; C90C
        bpl     LC8FF                           ; C90D
        rts                                     ; C90F

; ----------------------------------------------------------------------------
        lda     #$06                            ; C910
        sta     $01                             ; C912
LC914:  lda     $01                             ; C914
        jsr     LC6F3                           ; C916
        lda     $054D,y                         ; C919
        cmp     #$0D                            ; C91C
        beq     LC928                           ; C91E
        cmp     #$0E                            ; C920
        beq     LC928                           ; C922
        dec     $01                             ; C924
        bpl     LC914                           ; C926
LC928:  rts                                     ; C928

; ----------------------------------------------------------------------------
        ldx     $05C3                           ; C929
        dex                                     ; C92C
        txa                                     ; C92D
        asl     a                               ; C92E
        sta     $00                             ; C92F
        asl     a                               ; C931
        adc     $00                             ; C932
        tax                                     ; C934
        lda     #$02                            ; C935
        sta     $02                             ; C937
LC939:  lda     #$06                            ; C939
        sta     $03                             ; C93B
LC93D:  lda     $03                             ; C93D
        jsr     LC6F3                           ; C93F
        lda     $054D,y                         ; C942
        cmp     $899C,x                         ; C945
        bcc     LC95C                           ; C948
        cmp     $899D,x                         ; C94A
        bcs     LC95C                           ; C94D
        lda     $054F,y                         ; C94F
        and     #$0A                            ; C952
        beq     LC966                           ; C954
        lda     #$01                            ; C956
        sta     $0507                           ; C958
        rts                                     ; C95B

; ----------------------------------------------------------------------------
LC95C:  dec     $03                             ; C95C
        bpl     LC93D                           ; C95E
        lda     #$03                            ; C960
        sta     $0507                           ; C962
        rts                                     ; C965

; ----------------------------------------------------------------------------
LC966:  inx                                     ; C966
        inx                                     ; C967
        dec     $02                             ; C968
        bne     LC939                           ; C96A
        lda     #$00                            ; C96C
        sta     $0507                           ; C96E
        rts                                     ; C971

; ----------------------------------------------------------------------------
        lda     $05C2                           ; C972
        asl     a                               ; C975
        tay                                     ; C976
        lda     $8608,y                         ; C977
        sta     $01                             ; C97A
        ldx     #$02                            ; C97C
LC97E:  txa                                     ; C97E
        jsr     LC6F3                           ; C97F
        lda     $050E,y                         ; C982
        cmp     #$FF                            ; C985
        beq     LC994                           ; C987
        lda     $0510,y                         ; C989
        and     #$0A                            ; C98C
        beq     LC9A2                           ; C98E
        lda     #$01                            ; C990
        bne     LC996                           ; C992
LC994:  lda     #$03                            ; C994
LC996:  sta     $0507                           ; C996
        lda     #$4F                            ; C999
        jsr     LCFA1                           ; C99B
        lda     $0507                           ; C99E
        rts                                     ; C9A1

; ----------------------------------------------------------------------------
LC9A2:  dex                                     ; C9A2
        bpl     LC97E                           ; C9A3
        inx                                     ; C9A5
        rts                                     ; C9A6

; ----------------------------------------------------------------------------
LC9A7:  lda     $8E                             ; C9A7
        sta     $02                             ; C9A9
        ldx     #$01                            ; C9AB
LC9AD:  lda     $8C,x                           ; C9AD
        tay                                     ; C9AF
        beq     LC9BD                           ; C9B0
        lda     $02                             ; C9B2
LC9B4:  clc                                     ; C9B4
        adc     LC9C1,x                         ; C9B5
        dey                                     ; C9B8
        bne     LC9B4                           ; C9B9
        sta     $02                             ; C9BB
LC9BD:  dex                                     ; C9BD
        bpl     LC9AD                           ; C9BE
        rts                                     ; C9C0

; ----------------------------------------------------------------------------
LC9C1:  .byte   $64                             ; C9C1
        asl     a                               ; C9C2
LC9C3:  cmp     #$07                            ; C9C3
        bcs     LC9CB                           ; C9C5
        ldy     $84                             ; C9C7
        beq     LCA03                           ; C9C9
LC9CB:  asl     a                               ; C9CB
        tay                                     ; C9CC
        lda     $8608,y                         ; C9CD
        sta     $00                             ; C9D0
        txa                                     ; C9D2
        pha                                     ; C9D3
        bne     LC9DE                           ; C9D4
        jsr     LC9A7                           ; C9D6
        lda     $02                             ; C9D9
        jmp     LC9E5                           ; C9DB

; ----------------------------------------------------------------------------
LC9DE:  dex                                     ; C9DE
        txa                                     ; C9DF
        asl     a                               ; C9E0
        tay                                     ; C9E1
        lda     $03C1,y                         ; C9E2
LC9E5:  cmp     $00                             ; C9E5
        pla                                     ; C9E7
        bcs     LCA03                           ; C9E8
        sta     $01                             ; C9EA
        ldx     #$02                            ; C9EC
LC9EE:  txa                                     ; C9EE
        jsr     LC6F3                           ; C9EF
        lda     $050E,y                         ; C9F2
        cmp     $01                             ; C9F5
        beq     LC9FE                           ; C9F7
        dex                                     ; C9F9
        bpl     LC9EE                           ; C9FA
        clc                                     ; C9FC
        rts                                     ; C9FD

; ----------------------------------------------------------------------------
LC9FE:  lda     $0516,y                         ; C9FE
        cmp     #$01                            ; CA01
LCA03:  rts                                     ; CA03

; ----------------------------------------------------------------------------
        ldx     #$06                            ; CA04
LCA06:  txa                                     ; CA06
        jsr     LC6F3                           ; CA07
        lda     $054D,y                         ; CA0A
        cmp     #$FF                            ; CA0D
        bne     LCA15                           ; CA0F
        dex                                     ; CA11
        bpl     LCA06                           ; CA12
        inx                                     ; CA14
LCA15:  rts                                     ; CA15

; ----------------------------------------------------------------------------
        ldx     #$06                            ; CA16
LCA18:  txa                                     ; CA18
        jsr     LC6F3                           ; CA19
        lda     $054D,y                         ; CA1C
        cmp     #$19                            ; CA1F
        bcc     LCA27                           ; CA21
        cmp     #$1C                            ; CA23
        bcc     LCA2D                           ; CA25
LCA27:  dex                                     ; CA27
        bpl     LCA18                           ; CA28
        lda     #$45                            ; CA2A
        rts                                     ; CA2C

; ----------------------------------------------------------------------------
LCA2D:  lda     #$00                            ; CA2D
        rts                                     ; CA2F

; ----------------------------------------------------------------------------
        lda     #$3F                            ; CA30
        ldy     $05C3                           ; CA32
        beq     LCA58                           ; CA35
        ldx     $05C2                           ; CA37
        lda     $8C50,x                         ; CA3A
LCA3D:  lsr     a                               ; CA3D
        dey                                     ; CA3E
        bne     LCA3D                           ; CA3F
        lda     #$3F                            ; CA41
        bcs     LCA58                           ; CA43
        ldy     $05C3                           ; CA45
        ldx     $05C2                           ; CA48
        lda     $8C56,y                         ; CA4B
LCA4E:  lsr     a                               ; CA4E
        dex                                     ; CA4F
        bne     LCA4E                           ; CA50
        lda     #$41                            ; CA52
        bcs     LCA58                           ; CA54
        lda     #$3F                            ; CA56
LCA58:  ldx     $05D4                           ; CA58
        stx     $0503                           ; CA5B
        jsr     LCFA1                           ; CA5E
        rts                                     ; CA61

; ----------------------------------------------------------------------------
LCA62:  jsr     LC6F3                           ; CA62
        lda     $050E,y                         ; CA65
        bne     LCA7B                           ; CA68
        clc                                     ; CA6A
        lda     $84                             ; CA6B
        adc     #$05                            ; CA6D
        asl     a                               ; CA6F
        tay                                     ; CA70
        lda     $8C10,y                         ; CA71
        cmp     $81                             ; CA74
        bcs     LCA7A                           ; CA76
        sta     $81                             ; CA78
LCA7A:  rts                                     ; CA7A

; ----------------------------------------------------------------------------
LCA7B:  tay                                     ; CA7B
        asl     a                               ; CA7C
        tax                                     ; CA7D
        lda     $03BE,x                         ; CA7E
        sta     $02                             ; CA81
        clc                                     ; CA83
        lda     $84                             ; CA84
        adc     #$05                            ; CA86
        dey                                     ; CA88
        sec                                     ; CA89
        sbc     $8CA1,y                         ; CA8A
        asl     a                               ; CA8D
        tay                                     ; CA8E
        lda     $8C10,y                         ; CA8F
        cmp     $02                             ; CA92
        bcs     LCA99                           ; CA94
        sta     $03BE,x                         ; CA96
LCA99:  rts                                     ; CA99

; ----------------------------------------------------------------------------
LCA9A:  jsr     LC6F3                           ; CA9A
        lda     $050E,y                         ; CA9D
        bne     LCAC2                           ; CAA0
        jsr     LC9A7                           ; CAA2
LCAA5:  clc                                     ; CAA5
        lda     $84                             ; CAA6
        adc     #$05                            ; CAA8
        asl     a                               ; CAAA
        tay                                     ; CAAB
        lda     $8C11,y                         ; CAAC
        cmp     $02                             ; CAAF
        bcc     LCAB5                           ; CAB1
        lda     $02                             ; CAB3
LCAB5:  jsr     LCE39                           ; CAB5
        ldx     #$02                            ; CAB8
LCABA:  lda     $0D,x                           ; CABA
        sta     $8C,x                           ; CABC
        dex                                     ; CABE
        bpl     LCABA                           ; CABF
        rts                                     ; CAC1

; ----------------------------------------------------------------------------
LCAC2:  tay                                     ; CAC2
        asl     a                               ; CAC3
        tax                                     ; CAC4
        lda     $03BF,x                         ; CAC5
        sta     $02                             ; CAC8
        clc                                     ; CACA
        lda     $84                             ; CACB
        adc     #$05                            ; CACD
        dey                                     ; CACF
        sec                                     ; CAD0
        sbc     $8CA1,y                         ; CAD1
        asl     a                               ; CAD4
        tay                                     ; CAD5
        lda     $8C11,y                         ; CAD6
        cmp     $02                             ; CAD9
        bcs     LCAE0                           ; CADB
        sta     $03BF,x                         ; CADD
LCAE0:  rts                                     ; CAE0

; ----------------------------------------------------------------------------
        jsr     LCDD5                           ; CAE1
        ldy     #$00                            ; CAE4
        lda     ($00),y                         ; CAE6
        clc                                     ; CAE8
        adc     $05C0                           ; CAE9
        sta     $05C0                           ; CAEC
        iny                                     ; CAEF
        lda     ($00),y                         ; CAF0
        clc                                     ; CAF2
        adc     $05C1                           ; CAF3
        sta     $05C1                           ; CAF6
        rts                                     ; CAF9

; ----------------------------------------------------------------------------
        lda     $059C                           ; CAFA
        jsr     LC6F3                           ; CAFD
        lda     $054D,y                         ; CB00
        cmp     #$15                            ; CB03
        beq     LCB0B                           ; CB05
        cmp     #$17                            ; CB07
        bne     LCB15                           ; CB09
LCB0B:  lda     $054F,y                         ; CB0B
        and     #$10                            ; CB0E
        beq     LCB15                           ; CB10
        jsr     LBBBD                           ; CB12
LCB15:  rts                                     ; CB15

; ----------------------------------------------------------------------------
        lda     $05C7                           ; CB16
        cmp     #$03                            ; CB19
        bcs     LCB64                           ; CB1B
        jsr     LC6F3                           ; CB1D
        sty     $52                             ; CB20
        lda     $0510,y                         ; CB22
        sta     $059A                           ; CB25
        lda     #$04                            ; CB28
        sta     $059B                           ; CB2A
        sty     $059C                           ; CB2D
LCB30:  lsr     $059A                           ; CB30
        ldx     $059C                           ; CB33
        bcc     LCB65                           ; CB36
        lda     $0511,x                         ; CB38
        beq     LCB44                           ; CB3B
        dec     $0511,x                         ; CB3D
        cmp     #$03                            ; CB40
        beq     LCB65                           ; CB42
LCB44:  tax                                     ; CB44
        lda     LCB6E,x                         ; CB45
        jsr     LCE8D                           ; CB48
        bcc     LCB65                           ; CB4B
        lda     $05C7                           ; CB4D
        ldx     #$0C                            ; CB50
        jsr     LC13B                           ; CB52
        lda     #$49                            ; CB55
        jsr     LCFA1                           ; CB57
        ldy     $52                             ; CB5A
        lda     $0510,y                         ; CB5C
        and     #$F0                            ; CB5F
        sta     $0510,y                         ; CB61
LCB64:  rts                                     ; CB64

; ----------------------------------------------------------------------------
LCB65:  inc     $059C                           ; CB65
        dec     $059B                           ; CB68
        bne     LCB30                           ; CB6B
        rts                                     ; CB6D

; ----------------------------------------------------------------------------
LCB6E:  .byte   $82                             ; CB6E
        brk                                     ; CB6F
        .byte   $02                             ; CB70
        ldx     #$0D                            ; CB71
LCB73:  txa                                     ; CB73
        jsr     LC6F3                           ; CB74
        lda     $050E,y                         ; CB77
        cmp     $0503                           ; CB7A
        beq     LCB82                           ; CB7D
        dex                                     ; CB7F
        bpl     LCB73                           ; CB80
LCB82:  rts                                     ; CB82

; ----------------------------------------------------------------------------
        lda     $05C7                           ; CB83
        jsr     LC6F3                           ; CB86
        lda     $0510,y                         ; CB89
        and     #$0A                            ; CB8C
        rts                                     ; CB8E

; ----------------------------------------------------------------------------
        lda     $05C7                           ; CB8F
        jsr     LC6F3                           ; CB92
        lda     $0510,y                         ; CB95
        and     #$0C                            ; CB98
        rts                                     ; CB9A

; ----------------------------------------------------------------------------
        lda     $0503                           ; CB9B
        jsr     LCF25                           ; CB9E
        lda     $0510,y                         ; CBA1
        and     #$01                            ; CBA4
        rts                                     ; CBA6

; ----------------------------------------------------------------------------
        lda     $05C8                           ; CBA7
        jsr     LC6F3                           ; CBAA
        lda     $054F,y                         ; CBAD
        and     #$0A                            ; CBB0
        rts                                     ; CBB2

; ----------------------------------------------------------------------------
        lda     $05C8                           ; CBB3
        jsr     LC6F3                           ; CBB6
        lda     $054F,y                         ; CBB9
        and     #$0C                            ; CBBC
        rts                                     ; CBBE

; ----------------------------------------------------------------------------
        lda     $05C6                           ; CBBF
        jsr     LC6F3                           ; CBC2
        lda     $054F,y                         ; CBC5
        and     #$01                            ; CBC8
        rts                                     ; CBCA

; ----------------------------------------------------------------------------
        lda     $05C6                           ; CBCB
        jsr     LC6F3                           ; CBCE
        lda     $054F,y                         ; CBD1
        and     #$10                            ; CBD4
        rts                                     ; CBD6

; ----------------------------------------------------------------------------
        lda     $05C7                           ; CBD7
        jsr     LC6F3                           ; CBDA
        lda     $0510,y                         ; CBDD
        and     #$01                            ; CBE0
        rts                                     ; CBE2

; ----------------------------------------------------------------------------
        lda     $05C8                           ; CBE3
        jsr     LC6F3                           ; CBE6
        lda     $054F,y                         ; CBE9
        and     #$01                            ; CBEC
        rts                                     ; CBEE

; ----------------------------------------------------------------------------
        lda     #$06                            ; CBEF
        sta     $00                             ; CBF1
        ldx     $05C6                           ; CBF3
LCBF6:  txa                                     ; CBF6
        jsr     LC6F3                           ; CBF7
        lda     $050E,y                         ; CBFA
        cmp     #$FF                            ; CBFD
        beq     LCC0D                           ; CBFF
        cpx     $05C7                           ; CC01
        beq     LCC0D                           ; CC04
        lda     $0510,y                         ; CC06
        and     #$01                            ; CC09
        beq     LCC18                           ; CC0B
LCC0D:  inx                                     ; CC0D
        cpx     #$07                            ; CC0E
        bne     LCC14                           ; CC10
        ldx     #$00                            ; CC12
LCC14:  dec     $00                             ; CC14
        bpl     LCBF6                           ; CC16
LCC18:  rts                                     ; CC18

; ----------------------------------------------------------------------------
        lda     #$00                            ; CC19
        sta     $00                             ; CC1B
        ldx     $05C5                           ; CC1D
LCC20:  txa                                     ; CC20
        jsr     LC6F3                           ; CC21
        lda     $054D,y                         ; CC24
        cmp     #$FF                            ; CC27
        beq     LCC37                           ; CC29
        cpx     $05C8                           ; CC2B
        beq     LCC37                           ; CC2E
        lda     $0550,y                         ; CC30
        and     #$01                            ; CC33
        beq     LCC42                           ; CC35
LCC37:  inx                                     ; CC37
        cpx     #$07                            ; CC38
        bne     LCC3E                           ; CC3A
        ldx     #$00                            ; CC3C
LCC3E:  dec     $00                             ; CC3E
        bpl     LCC20                           ; CC40
LCC42:  rts                                     ; CC42

; ----------------------------------------------------------------------------
        lda     $0502                           ; CC43
        jsr     LCE00                           ; CC46
        txa                                     ; CC49
        beq     LCC8A                           ; CC4A
        lda     $0503                           ; CC4C
        tax                                     ; CC4F
        cmp     #$0D                            ; CC50
        bmi     LCC58                           ; CC52
        cmp     #$0E                            ; CC54
        bne     LCC69                           ; CC56
LCC58:  lda     $05C6                           ; CC58
        jsr     LC6F3                           ; CC5B
        lda     $054F,y                         ; CC5E
        and     #$20                            ; CC61
        beq     LCC7F                           ; CC63
        ldx     #$0F                            ; CC65
        bne     LCC7F                           ; CC67
LCC69:  cmp     #$15                            ; CC69
        beq     LCC71                           ; CC6B
        cmp     #$17                            ; CC6D
        bne     LCC7F                           ; CC6F
LCC71:  lda     $05C6                           ; CC71
        jsr     LC6F3                           ; CC74
        lda     $054F,y                         ; CC77
        and     #$10                            ; CC7A
        beq     LCC7F                           ; CC7C
        inx                                     ; CC7E
LCC7F:  txa                                     ; CC7F
        tay                                     ; CC80
        iny                                     ; CC81
        lda     ($58),y                         ; CC82
        and     #$0F                            ; CC84
        cmp     #$0F                            ; CC86
        bne     LCC8C                           ; CC88
LCC8A:  sec                                     ; CC8A
        rts                                     ; CC8B

; ----------------------------------------------------------------------------
LCC8C:  tay                                     ; CC8C
        and     #$07                            ; CC8D
        tax                                     ; CC8F
        tya                                     ; CC90
        and     #$08                            ; CC91
        beq     LCC99                           ; CC93
        txa                                     ; CC95
        ora     #$80                            ; CC96
        tax                                     ; CC98
LCC99:  txa                                     ; CC99
        cmp     #$86                            ; CC9A
        clc                                     ; CC9C
        beq     LCCA2                           ; CC9D
        jsr     LCE8D                           ; CC9F
LCCA2:  rts                                     ; CCA2

; ----------------------------------------------------------------------------
        lda     $0502                           ; CCA3
        jsr     LCE00                           ; CCA6
        txa                                     ; CCA9
        beq     LCCB8                           ; CCAA
        ldy     $0503                           ; CCAC
        iny                                     ; CCAF
        lda     ($58),y                         ; CCB0
        and     #$0F                            ; CCB2
        cmp     #$0F                            ; CCB4
        bne     LCCBA                           ; CCB6
LCCB8:  sec                                     ; CCB8
        rts                                     ; CCB9

; ----------------------------------------------------------------------------
LCCBA:  tay                                     ; CCBA
        and     #$07                            ; CCBB
        tax                                     ; CCBD
        tya                                     ; CCBE
        and     #$08                            ; CCBF
        beq     LCCC7                           ; CCC1
        txa                                     ; CCC3
        ora     #$80                            ; CCC4
        tax                                     ; CCC6
LCCC7:  txa                                     ; CCC7
        cmp     #$86                            ; CCC8
        clc                                     ; CCCA
        beq     LCCD0                           ; CCCB
        jsr     LCE8D                           ; CCCD
LCCD0:  rts                                     ; CCD0

; ----------------------------------------------------------------------------
        jsr     LC6F3                           ; CCD1
        sty     $52                             ; CCD4
        lda     $054D,y                         ; CCD6
        jsr     LCDD5                           ; CCD9
        ldy     #$07                            ; CCDC
        lda     ($00),y                         ; CCDE
        sta     $00                             ; CCE0
        ldy     $52                             ; CCE2
        lda     $0555,y                         ; CCE4
        cmp     $00                             ; CCE7
        bcc     LCCF0                           ; CCE9
        lda     $00                             ; CCEB
        sta     $0555,y                         ; CCED
LCCF0:  rts                                     ; CCF0

; ----------------------------------------------------------------------------
        lda     $05C8                           ; CCF1
        jsr     LC6F3                           ; CCF4
        sty     $52                             ; CCF7
        lda     $054F,y                         ; CCF9
        and     #$10                            ; CCFC
        beq     LCD18                           ; CCFE
        ldx     $05DA                           ; CD00
        cpx     #$03                            ; CD03
        beq     LCD17                           ; CD05
        lda     LCD67,x                         ; CD07
        jsr     LCE8D                           ; CD0A
        bcc     LCD17                           ; CD0D
        jsr     LBBBA                           ; CD0F
        lda     #$49                            ; CD12
        jsr     LCFA1                           ; CD14
LCD17:  rts                                     ; CD17

; ----------------------------------------------------------------------------
LCD18:  lda     $054F,y                         ; CD18
        sta     $059A                           ; CD1B
        lda     #$04                            ; CD1E
        sta     $059B                           ; CD20
        sty     $059C                           ; CD23
LCD26:  lsr     $059A                           ; CD26
        ldx     $059C                           ; CD29
        bcc     LCD5B                           ; CD2C
        lda     $0550,x                         ; CD2E
        beq     LCD3A                           ; CD31
        dec     $0550,x                         ; CD33
        cmp     #$03                            ; CD36
        beq     LCD5B                           ; CD38
LCD3A:  tax                                     ; CD3A
        lda     LCD64,x                         ; CD3B
        jsr     LCE8D                           ; CD3E
        bcc     LCD5B                           ; CD41
        lda     $05C8                           ; CD43
        ldx     #$0C                            ; CD46
        jsr     LC0C4                           ; CD48
        lda     #$49                            ; CD4B
        jsr     LCFA1                           ; CD4D
        ldy     $52                             ; CD50
        lda     $054F,y                         ; CD52
        and     #$F0                            ; CD55
        sta     $054F,y                         ; CD57
        rts                                     ; CD5A

; ----------------------------------------------------------------------------
LCD5B:  inc     $059C                           ; CD5B
        dec     $059B                           ; CD5E
        bne     LCD26                           ; CD61
        rts                                     ; CD63

; ----------------------------------------------------------------------------
LCD64:  .byte   $82                             ; CD64
        brk                                     ; CD65
        .byte   $02                             ; CD66
LCD67:  sty     $82                             ; CD67
        brk                                     ; CD69
        ldx     #$06                            ; CD6A
LCD6C:  txa                                     ; CD6C
        jsr     LC6F3                           ; CD6D
        lda     $050E,y                         ; CD70
        cmp     #$FF                            ; CD73
        bne     LCD7C                           ; CD75
        dex                                     ; CD77
        bpl     LCD6C                           ; CD78
        lda     #$00                            ; CD7A
LCD7C:  rts                                     ; CD7C

; ----------------------------------------------------------------------------
        sec                                     ; CD7D
        ldx     $05C2                           ; CD7E
        beq     LCD8D                           ; CD81
        ldy     $05C3                           ; CD83
        lda     $8C56,y                         ; CD86
LCD89:  lsr     a                               ; CD89
        dex                                     ; CD8A
        bne     LCD89                           ; CD8B
LCD8D:  rts                                     ; CD8D

; ----------------------------------------------------------------------------
        lda     #$00                            ; CD8E
        sta     $01                             ; CD90
        ldx     #$03                            ; CD92
LCD94:  txa                                     ; CD94
        jsr     LC6F3                           ; CD95
        lda     $0529,y                         ; CD98
        bmi     LCD9F                           ; CD9B
        inc     $01                             ; CD9D
LCD9F:  dex                                     ; CD9F
        bpl     LCD94                           ; CDA0
        lda     $01                             ; CDA2
        rts                                     ; CDA4

; ----------------------------------------------------------------------------
        lda     $059C                           ; CDA5
        jsr     LC6F3                           ; CDA8
        lda     $050E,y                         ; CDAB
        asl     a                               ; CDAE
        tay                                     ; CDAF
        lda     #$00                            ; CDB0
        sta     $03BE,y                         ; CDB2
        sta     $03BF,y                         ; CDB5
        rts                                     ; CDB8

; ----------------------------------------------------------------------------
LCDB9:  cmp     #$07                            ; CDB9
        bcs     LCDD1                           ; CDBB
        pha                                     ; CDBD
        jsr     LC9C3                           ; CDBE
        pla                                     ; CDC1
        bcc     LCDD4                           ; CDC2
        pha                                     ; CDC4
        ldx     $0517                           ; CDC5
        jsr     LC9C3                           ; CDC8
        pla                                     ; CDCB
        bcc     LCDD4                           ; CDCC
        ldx     $0520                           ; CDCE
LCDD1:  jsr     LC9C3                           ; CDD1
LCDD4:  rts                                     ; CDD4

; ----------------------------------------------------------------------------
LCDD5:  sec                                     ; CDD5
        sbc     #$0D                            ; CDD6
        sta     $02                             ; CDD8
        lda     #$00                            ; CDDA
        sta     $00                             ; CDDC
        sta     $01                             ; CDDE
        ldx     #$0A                            ; CDE0
LCDE2:  clc                                     ; CDE2
        lda     $00                             ; CDE3
        adc     $02                             ; CDE5
        sta     $00                             ; CDE7
        lda     $01                             ; CDE9
        adc     #$00                            ; CDEB
        sta     $01                             ; CDED
        dex                                     ; CDEF
        bne     LCDE2                           ; CDF0
        clc                                     ; CDF2
        lda     #$41                            ; CDF3
        adc     $00                             ; CDF5
        sta     $00                             ; CDF7
        lda     #$83                            ; CDF9
        adc     $01                             ; CDFB
        sta     $01                             ; CDFD
        rts                                     ; CDFF

; ----------------------------------------------------------------------------
LCE00:  sta     $059A                           ; CE00
        lda     #$55                            ; CE03
        sta     $58                             ; CE05
        lda     #$86                            ; CE07
        sta     $59                             ; CE09
        ldx     #$12                            ; CE0B
LCE0D:  ldy     #$00                            ; CE0D
        lda     ($58),y                         ; CE0F
        cmp     $059A                           ; CE11
        beq     LCE26                           ; CE14
        clc                                     ; CE16
        lda     #$2B                            ; CE17
        adc     $58                             ; CE19
        sta     $58                             ; CE1B
        lda     #$00                            ; CE1D
        adc     $59                             ; CE1F
        sta     $59                             ; CE21
        dex                                     ; CE23
        bne     LCE0D                           ; CE24
LCE26:  rts                                     ; CE26

; ----------------------------------------------------------------------------
LCE27:  ldx     #$00                            ; CE27
LCE29:  lda     $40,x                           ; CE29
        asl     a                               ; CE2B
        inx                                     ; CE2C
        rol     $40,x                           ; CE2D
        dex                                     ; CE2F
        rol     $40,x                           ; CE30
        inx                                     ; CE32
        inx                                     ; CE33
        cpx     #$10                            ; CE34
        bne     LCE29                           ; CE36
        rts                                     ; CE38

; ----------------------------------------------------------------------------
LCE39:  sta     $0C                             ; CE39
        ldx     #$00                            ; CE3B
        stx     $0D                             ; CE3D
        stx     $0E                             ; CE3F
        and     #$07                            ; CE41
        sta     $0F                             ; CE43
        ldy     #$05                            ; CE45
LCE47:  asl     $0C                             ; CE47
        bcc     LCE7A                           ; CE49
        tya                                     ; CE4B
        sta     $0B                             ; CE4C
        asl     a                               ; CE4E
        adc     $0B                             ; CE4F
        tax                                     ; CE51
        dex                                     ; CE52
        sty     $0B                             ; CE53
        ldy     #$02                            ; CE55
LCE57:  lda     LCE7E,x                         ; CE57
        adc     $0D,y                           ; CE5A
        sta     $0D,y                           ; CE5D
        dex                                     ; CE60
        dey                                     ; CE61
        bpl     LCE57                           ; CE62
        ldy     #$02                            ; CE64
        clc                                     ; CE66
LCE67:  lda     $0D,y                           ; CE67
        adc     #$00                            ; CE6A
        cmp     #$0A                            ; CE6C
        bcc     LCE72                           ; CE6E
        sbc     #$0A                            ; CE70
LCE72:  sta     $0D,y                           ; CE72
        dey                                     ; CE75
        bpl     LCE67                           ; CE76
        ldy     $0B                             ; CE78
LCE7A:  dey                                     ; CE7A
        bne     LCE47                           ; CE7B
        rts                                     ; CE7D

; ----------------------------------------------------------------------------
LCE7E:  brk                                     ; CE7E
        brk                                     ; CE7F
        php                                     ; CE80
        brk                                     ; CE81
        ora     ($06,x)                         ; CE82
        brk                                     ; CE84
        .byte   $03                             ; CE85
        .byte   $02                             ; CE86
        brk                                     ; CE87
        asl     $04                             ; CE88
        ora     ($02,x)                         ; CE8A
        php                                     ; CE8C
LCE8D:  pha                                     ; CE8D
        lda     $1E                             ; CE8E
        and     #$07                            ; CE90
        tay                                     ; CE92
        iny                                     ; CE93
LCE94:  jsr     LCE27                           ; CE94
        dey                                     ; CE97
        bne     LCE94                           ; CE98
        pla                                     ; CE9A
        tax                                     ; CE9B
        asl     a                               ; CE9C
        tay                                     ; CE9D
        lda     $40,y                           ; CE9E
        sta     $00                             ; CEA1
        txa                                     ; CEA3
        bpl     LCEAC                           ; CEA4
        lda     $00                             ; CEA6
        eor     #$FF                            ; CEA8
        sta     $00                             ; CEAA
LCEAC:  lsr     $00                             ; CEAC
        rts                                     ; CEAE

; ----------------------------------------------------------------------------
LCEAF:  php                                     ; CEAF
        pha                                     ; CEB0
        lda     $0500                           ; CEB1
        ldy     $0503                           ; CEB4
        sta     $0503                           ; CEB7
        sty     $0500                           ; CEBA
        lda     $0501                           ; CEBD
        ldy     $0504                           ; CEC0
        sta     $0504                           ; CEC3
        sty     $0501                           ; CEC6
        pla                                     ; CEC9
        plp                                     ; CECA
        rts                                     ; CECB

; ----------------------------------------------------------------------------
        lda     #$00                            ; CECC
        sta     $01                             ; CECE
        ldx     #$06                            ; CED0
LCED2:  txa                                     ; CED2
        jsr     LC6F3                           ; CED3
        lda     $050E,y                         ; CED6
        cmp     #$FF                            ; CED9
        beq     LCEDF                           ; CEDB
        inc     $01                             ; CEDD
LCEDF:  dex                                     ; CEDF
        bpl     LCED2                           ; CEE0
        rts                                     ; CEE2

; ----------------------------------------------------------------------------
        lda     #$00                            ; CEE3
        sta     $01                             ; CEE5
        ldx     #$06                            ; CEE7
LCEE9:  txa                                     ; CEE9
        jsr     LC6F3                           ; CEEA
        lda     $054D,y                         ; CEED
        cmp     #$FF                            ; CEF0
        beq     LCEF6                           ; CEF2
        inc     $01                             ; CEF4
LCEF6:  dex                                     ; CEF6
        bpl     LCEE9                           ; CEF7
        rts                                     ; CEF9

; ----------------------------------------------------------------------------
        lda     $51                             ; CEFA
        jsr     LC6F3                           ; CEFC
        lda     $050E,y                         ; CEFF
        ldx     $0503                           ; CF02
        sta     $0503                           ; CF05
        stx     $05BB                           ; CF08
        lda     $050F,y                         ; CF0B
        ldx     $0504                           ; CF0E
        sta     $0504                           ; CF11
        stx     $05BC                           ; CF14
        rts                                     ; CF17

; ----------------------------------------------------------------------------
        lda     $05BB                           ; CF18
        sta     $0503                           ; CF1B
        lda     $05BC                           ; CF1E
        sta     $0504                           ; CF21
        rts                                     ; CF24

; ----------------------------------------------------------------------------
LCF25:  ldy     #$00                            ; CF25
        ldx     #$00                            ; CF27
        sta     $00                             ; CF29
LCF2B:  lda     $050E,y                         ; CF2B
        cmp     $00                             ; CF2E
        beq     LCF39                           ; CF30
        inx                                     ; CF32
        txa                                     ; CF33
        jsr     LC6F3                           ; CF34
        bne     LCF2B                           ; CF37
LCF39:  rts                                     ; CF39

; ----------------------------------------------------------------------------
LCF3A:  asl     a                               ; CF3A
        sta     $53                             ; CF3B
        asl     a                               ; CF3D
        clc                                     ; CF3E
        adc     $53                             ; CF3F
        tay                                     ; CF41
        rts                                     ; CF42

; ----------------------------------------------------------------------------
        ldx     $0502                           ; CF43
        lda     $8BE9,x                         ; CF46
        cmp     #$FF                            ; CF49
        beq     LCF50                           ; CF4B
        jsr     LE992                           ; CF4D
LCF50:  rts                                     ; CF50

; ----------------------------------------------------------------------------
        ldx     #$00                            ; CF51
        lda     #$F0                            ; CF53
LCF55:  sta     $0200,x                         ; CF55
        inx                                     ; CF58
        inx                                     ; CF59
        inx                                     ; CF5A
        inx                                     ; CF5B
        bne     LCF55                           ; CF5C
        rts                                     ; CF5E

; ----------------------------------------------------------------------------
LCF5F:  ldx     #$00                            ; CF5F
        stx     $51                             ; CF61
LCF63:  txa                                     ; CF63
        jsr     LC6F3                           ; CF64
        lda     $054D,y                         ; CF67
        cmp     $0500                           ; CF6A
        bne     LCF79                           ; CF6D
        lda     #$FF                            ; CF6F
        sta     $054D,y                         ; CF71
        lda     $51                             ; CF74
        jsr     LC52E                           ; CF76
LCF79:  inc     $51                             ; CF79
        ldx     $51                             ; CF7B
        cpx     #$07                            ; CF7D
        bne     LCF63                           ; CF7F
        jsr     LCF88                           ; CF81
        jsr     LB6D5                           ; CF84
        rts                                     ; CF87

; ----------------------------------------------------------------------------
LCF88:  lda     #$07                            ; CF88
        sta     $50                             ; CF8A
LCF8C:  lda     #$04                            ; CF8C
        jsr     LE992                           ; CF8E
        lda     #$05                            ; CF91
        sta     $51                             ; CF93
LCF95:  jsr     LE95B                           ; CF95
        dec     $51                             ; CF98
        bne     LCF95                           ; CF9A
        dec     $50                             ; CF9C
        bne     LCF8C                           ; CF9E
        rts                                     ; CFA0

; ----------------------------------------------------------------------------
LCFA1:  pha                                     ; CFA1
        jsr     LCFA9                           ; CFA2
        pla                                     ; CFA5
        jsr     LE006                           ; CFA6
LCFA9:  jsr     LE95B                           ; CFA9
        lda     $0162                           ; CFAC
        ora     $0163                           ; CFAF
        bne     LCFA9                           ; CFB2
        rts                                     ; CFB4

; ----------------------------------------------------------------------------
        brk                                     ; CFB5
        brk                                     ; CFB6
        brk                                     ; CFB7
        brk                                     ; CFB8
        brk                                     ; CFB9
        brk                                     ; CFBA
        brk                                     ; CFBB
        brk                                     ; CFBC
LCFBD:  jmp     LCE8D                           ; CFBD

; ----------------------------------------------------------------------------
LCFC0:  jmp     LC87A                           ; CFC0

; ----------------------------------------------------------------------------
LCFC3:  jmp     LC89D                           ; CFC3

; ----------------------------------------------------------------------------
        jmp     LC8B0                           ; CFC6

; ----------------------------------------------------------------------------
        jmp     LC9A7                           ; CFC9

; ----------------------------------------------------------------------------
LCFCC:  jmp     LCDB9                           ; CFCC

; ----------------------------------------------------------------------------
LCFCF:  jmp     LCE39                           ; CFCF

; ----------------------------------------------------------------------------
LCFD2:  jmp     LCF5F                           ; CFD2

; ----------------------------------------------------------------------------
        brk                                     ; CFD5
        brk                                     ; CFD6
        brk                                     ; CFD7
        brk                                     ; CFD8
        brk                                     ; CFD9
        brk                                     ; CFDA
        brk                                     ; CFDB
        brk                                     ; CFDC
        brk                                     ; CFDD
        brk                                     ; CFDE
        brk                                     ; CFDF
        lda     #$03                            ; CFE0
        ldx     #$05                            ; CFE2
LCFE4:  sta     $FFDF                           ; CFE4
        lsr     a                               ; CFE7
        dex                                     ; CFE8
        bne     LCFE4                           ; CFE9
        jsr     LC295                           ; CFEB
        lda     $39                             ; CFEE
        ldx     #$05                            ; CFF0
LCFF2:  sta     $FFDF                           ; CFF2
        lsr     a                               ; CFF5
        dex                                     ; CFF6
        bne     LCFF2                           ; CFF7
        rts                                     ; CFF9

; ----------------------------------------------------------------------------
        brk                                     ; CFFA
        brk                                     ; CFFB
        brk                                     ; CFFC
        brk                                     ; CFFD
        brk                                     ; CFFE
        brk                                     ; CFFF
        lda     $1A                             ; D000
        pha                                     ; D002
        jsr     LD034                           ; D003
        jsr     LE95B                           ; D006
LD009:  lda     #$01                            ; D009
        sta     $0404                           ; D00B
        lda     #$82                            ; D00E
        jsr     LD0E4                           ; D010
        dey                                     ; D013
        bmi     LD009                           ; D014
        bne     LD01B                           ; D016
        jmp     LD5A5                           ; D018

; ----------------------------------------------------------------------------
LD01B:  dey                                     ; D01B
        bne     LD021                           ; D01C
        jmp     LD594                           ; D01E

; ----------------------------------------------------------------------------
LD021:  inc     $0404                           ; D021
        jsr     LD4C6                           ; D024
        lda     $05E0                           ; D027
        bpl     LD009                           ; D02A
        pla                                     ; D02C
        sta     $1A                             ; D02D
        pla                                     ; D02F
        pla                                     ; D030
        jmp     LEAC1                           ; D031

; ----------------------------------------------------------------------------
LD034:  lda     #$00                            ; D034
        ldx     #$2F                            ; D036
LD038:  sta     $0400,x                         ; D038
        dex                                     ; D03B
        bpl     LD038                           ; D03C
        sta     $1A                             ; D03E
        ldx     #$05                            ; D040
LD042:  sta     $0500,x                         ; D042
        dex                                     ; D045
        bpl     LD042                           ; D046
        rts                                     ; D048

; ----------------------------------------------------------------------------
        lda     $1A                             ; D049
        pha                                     ; D04B
        jsr     LD034                           ; D04C
        sta     $02                             ; D04F
        jsr     LD073                           ; D051
        jsr     LD49C                           ; D054
        jsr     LD034                           ; D057
        jsr     LD2EE                           ; D05A
        pla                                     ; D05D
        sta     $1A                             ; D05E
LD060:  lda     #$00                            ; D060
LD062:  pha                                     ; D062
        jsr     LE95B                           ; D063
        pla                                     ; D066
        jsr     LD38C                           ; D067
        rol     a                               ; D06A
        cmp     #$08                            ; D06B
        bcc     LD062                           ; D06D
        jsr     LE95B                           ; D06F
        rts                                     ; D072

; ----------------------------------------------------------------------------
LD073:  jsr     LE95B                           ; D073
        jsr     LD0C8                           ; D076
        bcs     LD0AF                           ; D079
        lda     $1A                             ; D07B
        clc                                     ; D07D
        adc     #$04                            ; D07E
        jsr     LD0E4                           ; D080
        and     #$FF                            ; D083
        bpl     LD09B                           ; D085
LD087:  lda     $1A                             ; D087
        beq     LD073                           ; D089
        dec     $1A                             ; D08B
        lda     $02                             ; D08D
        sec                                     ; D08F
        sbc     #$09                            ; D090
        sta     $02                             ; D092
        jsr     LD0C8                           ; D094
        bcs     LD087                           ; D097
        bcc     LD073                           ; D099
LD09B:  lda     $05A0                           ; D09B
        cmp     #$28                            ; D09E
        beq     LD0A7                           ; D0A0
        pha                                     ; D0A2
        jsr     LD48C                           ; D0A3
        pla                                     ; D0A6
LD0A7:  cmp     #$27                            ; D0A7
        beq     LD0BD                           ; D0A9
        cmp     #$07                            ; D0AB
        bcc     LD0BD                           ; D0AD
LD0AF:  inc     $1A                             ; D0AF
        lda     $02                             ; D0B1
        clc                                     ; D0B3
        adc     #$09                            ; D0B4
        sta     $02                             ; D0B6
        cmp     #$1B                            ; D0B8
        bcc     LD073                           ; D0BA
        rts                                     ; D0BC

; ----------------------------------------------------------------------------
LD0BD:  lda     #$FF                            ; D0BD
        ldx     #$04                            ; D0BF
LD0C1:  sta     $05A1,x                         ; D0C1
        dex                                     ; D0C4
        bpl     LD0C1                           ; D0C5
        rts                                     ; D0C7

; ----------------------------------------------------------------------------
LD0C8:  ldx     $02                             ; D0C8
        lda     $050E,x                         ; D0CA
        pha                                     ; D0CD
        clc                                     ; D0CE
        adc     #$7F                            ; D0CF
        ora     #$80                            ; D0D1
        sta     $0404                           ; D0D3
        pla                                     ; D0D6
        asl     a                               ; D0D7
        bcs     LD0E3                           ; D0D8
        tax                                     ; D0DA
        beq     LD0E3                           ; D0DB
        lda     $03BE,x                         ; D0DD
        bne     LD0E3                           ; D0E0
        sec                                     ; D0E2
LD0E3:  rts                                     ; D0E3

; ----------------------------------------------------------------------------
LD0E4:  sta     $0400                           ; D0E4
        and     #$7F                            ; D0E7
LD0E9:  sta     $0401                           ; D0E9
LD0EC:  jsr     LD2EE                           ; D0EC
        jsr     LD060                           ; D0EF
        jsr     LDCF1                           ; D0F2
        jsr     LDBFF                           ; D0F5
LD0F8:  jsr     LE95B                           ; D0F8
        jsr     LDF79                           ; D0FB
        and     #$FF                            ; D0FE
        beq     LD0F8                           ; D100
        bpl     LD10A                           ; D102
        bit     $0400                           ; D104
        bmi     LD0F8                           ; D107
LD109:  rts                                     ; D109

; ----------------------------------------------------------------------------
LD10A:  jsr     LDE51                           ; D10A
        bit     $0400                           ; D10D
        bmi     LD109                           ; D110
        lda     $0408,y                         ; D112
        sta     $01                             ; D115
        cmp     #$D2                            ; D117
        bne     LD122                           ; D119
        jsr     LD151                           ; D11B
        lda     #$02                            ; D11E
        bne     LD141                           ; D120
LD122:  ldx     #$02                            ; D122
        cmp     #$8B                            ; D124
        bne     LD12C                           ; D126
        lda     #$03                            ; D128
        bne     LD141                           ; D12A
LD12C:  cmp     #$E2                            ; D12C
        bne     LD13B                           ; D12E
        lda     $0404                           ; D130
        bpl     LD13A                           ; D133
        lda     #$27                            ; D135
        sta     $05A0                           ; D137
LD13A:  rts                                     ; D13A

; ----------------------------------------------------------------------------
LD13B:  jsr     LD151                           ; D13B
        jsr     LD178                           ; D13E
LD141:  sta     $00                             ; D141
LD143:  jsr     LE95B                           ; D143
        jsr     LD191                           ; D146
        lda     $00                             ; D149
        bpl     LD143                           ; D14B
        asl     a                               ; D14D
        bne     LD0EC                           ; D14E
        rts                                     ; D150

; ----------------------------------------------------------------------------
LD151:  pha                                     ; D151
        lda     $02                             ; D152
        ora     $84                             ; D154
        bne     LD174                           ; D156
        pla                                     ; D158
        cmp     #$D2                            ; D159
        .byte   $F0                             ; D15B
LD15C:  .byte   $0C                             ; D15C
        cmp     #$DE                            ; D15D
        bne     LD177                           ; D15F
        ldx     $030E                           ; D161
        bne     LD177                           ; D164
        lsr     a                               ; D166
        bne     LD170                           ; D167
LD169:  sbc     #$BB                            ; D169
        sta     $0502                           ; D16B
        lda     #$4F                            ; D16E
LD170:  jsr     LE006                           ; D170
        pla                                     ; D173
LD174:  pla                                     ; D174
        ora     #$80                            ; D175
LD177:  rts                                     ; D177

; ----------------------------------------------------------------------------
LD178:  ldy     #$01                            ; D178
LD17A:  cmp     LD185,x                         ; D17A
        beq     LD183                           ; D17D
        dex                                     ; D17F
        bpl     LD17A                           ; D180
        dey                                     ; D182
LD183:  tya                                     ; D183
        rts                                     ; D184

; ----------------------------------------------------------------------------
LD185:  sbc     ($DE,x)                         ; D185
        .byte   $DF                             ; D187
        .byte   $C7                             ; D188
        dec     $CD                             ; D189
        bne     LD15C                           ; D18B
        iny                                     ; D18D
        cmp     #$C3                            ; D18E
        .byte   $C5                             ; D190
LD191:  lda     $00                             ; D191
        jsr     LE97D                           ; D193
        ldy     #$D1                            ; D196
        cmp     $D1,x                           ; D198
        and     $47D2                           ; D19A
        .byte   $D2                             ; D19D
        .byte   $9B                             ; D19E
        .byte   $D2                             ; D19F
        lda     $02                             ; D1A0
        pha                                     ; D1A2
        tay                                     ; D1A3
        lda     $01                             ; D1A4
        pha                                     ; D1A6
        sec                                     ; D1A7
        sbc     #$BB                            ; D1A8
        pha                                     ; D1AA
        ldx     $050E,y                         ; D1AB
        jsr     LCFCC                           ; D1AE
        pla                                     ; D1B1
        bcc     LD1CC                           ; D1B2
        clc                                     ; D1B4
        jsr     LD223                           ; D1B5
        pla                                     ; D1B8
        pha                                     ; D1B9
        ldx     #$0B                            ; D1BA
        jsr     LD178                           ; D1BC
        bcs     LD1C3                           ; D1BF
        ldy     #$80                            ; D1C1
LD1C3:  pla                                     ; D1C3
        sta     $01                             ; D1C4
        pla                                     ; D1C6
        sta     $02                             ; D1C7
        sty     $00                             ; D1C9
        rts                                     ; D1CB

; ----------------------------------------------------------------------------
LD1CC:  lda     #$12                            ; D1CC
        jsr     LE006                           ; D1CE
        ldy     #$FF                            ; D1D1
        bne     LD1C3                           ; D1D3
        lda     $01                             ; D1D5
        ldx     #$09                            ; D1D7
        jsr     LD178                           ; D1D9
        lsr     a                               ; D1DC
        php                                     ; D1DD
        lda     #$67                            ; D1DE
        bcc     LD1E4                           ; D1E0
        lda     #$66                            ; D1E2
LD1E4:  jsr     LE006                           ; D1E4
        lda     $01                             ; D1E7
        sec                                     ; D1E9
        sbc     #$BB                            ; D1EA
        clc                                     ; D1EC
        jsr     LD223                           ; D1ED
        lda     $01                             ; D1F0
        ldx     #$09                            ; D1F2
        jsr     LD178                           ; D1F4
        jsr     LDC6E                           ; D1F7
        plp                                     ; D1FA
        and     #$FF                            ; D1FB
        bmi     LD220                           ; D1FD
        bcc     LD20B                           ; D1FF
        tax                                     ; D201
        beq     LD206                           ; D202
        ldx     #$03                            ; D204
LD206:  lda     $05E0,x                         ; D206
        bpl     LD21A                           ; D209
LD20B:  ldx     #$12                            ; D20B
        lsr     a                               ; D20D
        bne     LD215                           ; D20E
        bcc     LD214                           ; D210
        lda     #$09                            ; D212
LD214:  tax                                     ; D214
LD215:  lda     $050E,x                         ; D215
        bmi     LD20B                           ; D218
LD21A:  sec                                     ; D21A
        jsr     LD223                           ; D21B
        lda     #$80                            ; D21E
LD220:  sta     $00                             ; D220
        rts                                     ; D222

; ----------------------------------------------------------------------------
LD223:  pha                                     ; D223
        lda     $1A                             ; D224
        rol     a                               ; D226
        tax                                     ; D227
        pla                                     ; D228
        sta     $05A0,x                         ; D229
        rts                                     ; D22C

; ----------------------------------------------------------------------------
        lda     #$07                            ; D22D
        jsr     LD0E9                           ; D22F
        ldx     #$04                            ; D232
        stx     $0401                           ; D234
        and     #$FF                            ; D237
        bpl     LD242                           ; D239
        jsr     LD2EE                           ; D23B
LD23E:  lda     #$FF                            ; D23E
        bne     LD244                           ; D240
LD242:  lda     #$80                            ; D242
LD244:  sta     $00                             ; D244
        rts                                     ; D246

; ----------------------------------------------------------------------------
        lda     #$03                            ; D247
        jsr     LD2F1                           ; D249
        jsr     LD48C                           ; D24C
        ldx     #$00                            ; D24F
        ldy     #$01                            ; D251
LD253:  lda     $0529,x                         ; D253
        bpl     LD259                           ; D256
        iny                                     ; D258
LD259:  txa                                     ; D259
        clc                                     ; D25A
        adc     #$09                            ; D25B
        tax                                     ; D25D
        cpx     #$24                            ; D25E
        bcc     LD253                           ; D260
        sty     $0C                             ; D262
        lda     $03D6                           ; D264
        ora     $03D7                           ; D267
        bne     LD278                           ; D26A
        lda     #$65                            ; D26C
        jsr     LE006                           ; D26E
        lda     #$04                            ; D271
        sta     $0401                           ; D273
        bne     LD23E                           ; D276
LD278:  sta     $0413                           ; D278
        lda     #$00                            ; D27B
LD27D:  jsr     LD38C                           ; D27D
        jsr     LE95B                           ; D280
        lda     $0F                             ; D283
        cmp     #$08                            ; D285
        bcc     LD27D                           ; D287
        lda     #$60                            ; D289
        sta     $03                             ; D28B
        ldx     #$03                            ; D28D
        jsr     LDBFF                           ; D28F
        lda     #$00                            ; D292
        sta     $05                             ; D294
        sta     $06                             ; D296
        inc     $00                             ; D298
        rts                                     ; D29A

; ----------------------------------------------------------------------------
        jsr     LD42B                           ; D29B
        and     #$FF                            ; D29E
        beq     LD2BB                           ; D2A0
        cpy     #$03                            ; D2A2
        bne     LD2BB                           ; D2A4
        lda     $06                             ; D2A6
        bne     LD2AF                           ; D2A8
        lda     #$FF                            ; D2AA
LD2AC:  sta     $00                             ; D2AC
        rts                                     ; D2AE

; ----------------------------------------------------------------------------
LD2AF:  sta     $0402                           ; D2AF
        lda     #$28                            ; D2B2
        sta     $05A0                           ; D2B4
        lda     #$80                            ; D2B7
        bmi     LD2AC                           ; D2B9
LD2BB:  ldy     #$04                            ; D2BB
        ldx     $0162                           ; D2BD
        lda     LD47D,y                         ; D2C0
        sta     $0163,x                         ; D2C3
        inx                                     ; D2C6
        lda     LD47C,y                         ; D2C7
        sta     $0163,x                         ; D2CA
        ldy     #$04                            ; D2CD
LD2CF:  lda     LD482,y                         ; D2CF
        sta     $0164,x                         ; D2D2
        inx                                     ; D2D5
        dey                                     ; D2D6
        bpl     LD2CF                           ; D2D7
        stx     $0162                           ; D2D9
LD2DC:  lda     #$0E                            ; D2DC
        sta     $0160,x                         ; D2DE
        lda     $05                             ; D2E1
        beq     LD2E8                           ; D2E3
        sta     $0161,x                         ; D2E5
LD2E8:  lda     $06                             ; D2E8
        sta     $0162,x                         ; D2EA
        rts                                     ; D2ED

; ----------------------------------------------------------------------------
LD2EE:  lda     $0401                           ; D2EE
LD2F1:  pha                                     ; D2F1
        jsr     LD8EB                           ; D2F2
        pla                                     ; D2F5
        asl     a                               ; D2F6
        tax                                     ; D2F7
        beq     LD314                           ; D2F8
        cmp     #$0A                            ; D2FA
        bcs     LD321                           ; D2FC
        cmp     #$04                            ; D2FE
        beq     LD315                           ; D300
        lda     LD36B,x                         ; D302
        ldy     LD36C,x                         ; D305
        tax                                     ; D308
LD309:  lda     LD375,x                         ; D309
        sta     $0409,y                         ; D30C
        dex                                     ; D30F
        dey                                     ; D310
        bpl     LD309                           ; D311
        nop                                     ; D313
LD314:  rts                                     ; D314

; ----------------------------------------------------------------------------
LD315:  nop                                     ; D315
        ldy     #$02                            ; D316
        lda     $05CC                           ; D318
        beq     LD309                           ; D31B
        dex                                     ; D31D
        dey                                     ; D31E
        bpl     LD309                           ; D31F
LD321:  sbc     #$0E                            ; D321
        bne     LD340                           ; D323
        tax                                     ; D325
        ldy     #$05                            ; D326
        lda     $84                             ; D328
LD32A:  cmp     LD386,y                         ; D32A
        bcs     LD332                           ; D32D
        dey                                     ; D32F
        bne     LD32A                           ; D330
LD332:  sty     $3D                             ; D332
        jsr     LD356                           ; D334
        lda     $05C2                           ; D337
        beq     LD314                           ; D33A
        inc     $3D                             ; D33C
        bpl     LD35B                           ; D33E
LD340:  dex                                     ; D340
        cpx     #$09                            ; D341
        beq     LD347                           ; D343
        ldx     #$12                            ; D345
LD347:  lda     $050E,x                         ; D347
        asl     a                               ; D34A
        asl     a                               ; D34B
        adc     $050E,x                         ; D34C
        asl     a                               ; D34F
        tax                                     ; D350
        lda     $8463,x                         ; D351
        sta     $3D                             ; D354
LD356:  ldy     #$00                            ; D356
        lda     $8464,x                         ; D358
LD35B:  clc                                     ; D35B
        adc     #$BB                            ; D35C
        sta     $0409,y                         ; D35E
        iny                                     ; D361
        cpy     #$04                            ; D362
        bne     LD367                           ; D364
        iny                                     ; D366
LD367:  inx                                     ; D367
        dec     $3D                             ; D368
        .byte   $D0                             ; D36A
LD36B:  .byte   $EC                             ; D36B
LD36C:  rts                                     ; D36C

; ----------------------------------------------------------------------------
        ora     ($01,x)                         ; D36D
        .byte   $04                             ; D36F
        ora     ($0B,x)                         ; D370
        asl     $11                             ; D372
        .byte   $05                             ; D374
LD375:  sbc     $E1FA,y                         ; D375
        .byte   $E2                             ; D378
        nop                                     ; D379
        brk                                     ; D37A
        .byte   $8B                             ; D37B
        .byte   $DB                             ; D37C
        brk                                     ; D37D
        brk                                     ; D37E
        brk                                     ; D37F
        brk                                     ; D380
        sbc     ($DE,x)                         ; D381
        .byte   $D2                             ; D383
        .byte   $8B                             ; D384
        brk                                     ; D385
LD386:  .byte   $E2                             ; D386
        ora     ($06,x)                         ; D387
        asl     a                               ; D389
        bpl     LD3A0                           ; D38A
LD38C:  sta     $0F                             ; D38C
        tax                                     ; D38E
        lda     #$22                            ; D38F
        sta     $09                             ; D391
        sta     $08                             ; D393
        clc                                     ; D395
LD396:  lda     $09                             ; D396
        jsr     LDE46                           ; D398
        dex                                     ; D39B
        bpl     LD396                           ; D39C
LD39E:  lda     #$12                            ; D39E
LD3A0:  sta     $0A                             ; D3A0
        lda     $0F                             ; D3A2
        bne     LD3AA                           ; D3A4
        lda     #$80                            ; D3A6
        bne     LD3B6                           ; D3A8
LD3AA:  cmp     #$08                            ; D3AA
        bne     LD3B2                           ; D3AC
        lda     #$C0                            ; D3AE
        bne     LD3B6                           ; D3B0
LD3B2:  bcs     LD3E6                           ; D3B2
        lda     #$40                            ; D3B4
LD3B6:  jsr     LDDEA                           ; D3B6
        lda     $0F                             ; D3B9
        lsr     a                               ; D3BB
        bcs     LD3DA                           ; D3BC
        bne     LD3C3                           ; D3BE
        jsr     LD3EE                           ; D3C0
LD3C3:  cmp     #$02                            ; D3C3
        bne     LD3E6                           ; D3C5
        lda     $0413                           ; D3C7
        beq     LD3E6                           ; D3CA
        lda     #$00                            ; D3CC
        sta     $05                             ; D3CE
        sta     $06                             ; D3D0
        ldx     #$10                            ; D3D2
        jsr     LD2DC                           ; D3D4
        jmp     LD3E6                           ; D3D7

; ----------------------------------------------------------------------------
LD3DA:  clc                                     ; D3DA
        pha                                     ; D3DB
        jsr     LD910                           ; D3DC
        pla                                     ; D3DF
        clc                                     ; D3E0
        adc     #$05                            ; D3E1
        jsr     LD910                           ; D3E3
LD3E6:  inc     $0F                             ; D3E6
        lda     $0F                             ; D3E8
        lsr     a                               ; D3EA
        bcc     LD39E                           ; D3EB
        rts                                     ; D3ED

; ----------------------------------------------------------------------------
LD3EE:  lda     $0404                           ; D3EE
        bne     LD3F4                           ; D3F1
LD3F3:  rts                                     ; D3F3

; ----------------------------------------------------------------------------
LD3F4:  ldx     #$2C                            ; D3F4
        stx     $0169                           ; D3F6
        tay                                     ; D3F9
        pha                                     ; D3FA
        bmi     LD401                           ; D3FB
        dey                                     ; D3FD
        lda     LD420,y                         ; D3FE
LD401:  ldx     #$02                            ; D401
        jsr     LE002                           ; D403
        pla                                     ; D406
        tay                                     ; D407
        jsr     LD419                           ; D408
        cpy     #$02                            ; D40B
        bne     LD3F3                           ; D40D
        txa                                     ; D40F
        clc                                     ; D410
        adc     #$00                            ; D411
        tax                                     ; D413
        lda     #$A9                            ; D414
        jmp     LE002                           ; D416

; ----------------------------------------------------------------------------
LD419:  lda     #$2C                            ; D419
        sta     $0168,x                         ; D41B
        inx                                     ; D41E
        rts                                     ; D41F

; ----------------------------------------------------------------------------
LD420:  dec     $EA,x                           ; D420
        ldx     $B7,y                           ; D422
        clv                                     ; D424
        lda     LBBBA,y                         ; D425
        eor     $4868,x                         ; D428
LD42B:  jsr     LDF79                           ; D42B
        and     #$03                            ; D42E
        beq     LD47B                           ; D430
        pha                                     ; D432
        jsr     LDE51                           ; D433
        pla                                     ; D436
        lsr     a                               ; D437
        lda     $0417,y                         ; D438
        bne     LD47B                           ; D43B
        lda     $06                             ; D43D
        bcs     LD447                           ; D43F
        sbc     #$00                            ; D441
        bcc     LD47B                           ; D443
        bcs     LD44D                           ; D445
LD447:  adc     #$00                            ; D447
        cmp     $0C                             ; D449
        bcs     LD47B                           ; D44B
LD44D:  sta     $06                             ; D44D
LD44F:  lda     $03D7                           ; D44F
        bcs     LD466                           ; D452
        sbc     #$00                            ; D454
        bcs     LD45A                           ; D456
        lda     #$09                            ; D458
LD45A:  pha                                     ; D45A
        lda     $03D6                           ; D45B
        sbc     #$00                            ; D45E
        bcs     LD474                           ; D460
        dec     $06                             ; D462
        pla                                     ; D464
        rts                                     ; D465

; ----------------------------------------------------------------------------
LD466:  adc     #$00                            ; D466
        cmp     #$0A                            ; D468
        bcc     LD46E                           ; D46A
        lda     #$00                            ; D46C
LD46E:  pha                                     ; D46E
        lda     $03D6                           ; D46F
        adc     #$00                            ; D472
LD474:  sta     $03D6                           ; D474
        pla                                     ; D477
        sta     $03D7                           ; D478
LD47B:  rts                                     ; D47B

; ----------------------------------------------------------------------------
LD47C:  .byte   $77                             ; D47C
LD47D:  .byte   $22                             ; D47D
        .byte   $D7                             ; D47E
        and     ($AC,x)                         ; D47F
        .byte   $22                             ; D481
LD482:  brk                                     ; D482
        brk                                     ; D483
        bit     $030E                           ; D484
LD487:  ora     $0A                             ; D487
        .byte   $0F                             ; D489
        .byte   $14                             ; D48A
        .byte   $19                             ; D48B
LD48C:  ldx     $0402                           ; D48C
        beq     LD49B                           ; D48F
LD491:  sec                                     ; D491
        jsr     LD44F                           ; D492
        dex                                     ; D495
        bne     LD491                           ; D496
        stx     $0402                           ; D498
LD49B:  rts                                     ; D49B

; ----------------------------------------------------------------------------
LD49C:  ldx     #$00                            ; D49C
        ldy     $82                             ; D49E
        lda     LD487,y                         ; D4A0
        ldy     $0402                           ; D4A3
        beq     LD4C5                           ; D4A6
LD4A8:  pha                                     ; D4A8
        lda     $0529,x                         ; D4A9
        bpl     LD4BB                           ; D4AC
        lda     #$0C                            ; D4AE
        sta     $0529,x                         ; D4B0
        pla                                     ; D4B3
        sta     $0531,x                         ; D4B4
        dey                                     ; D4B7
        beq     LD4C5                           ; D4B8
        pha                                     ; D4BA
LD4BB:  txa                                     ; D4BB
        clc                                     ; D4BC
        adc     #$09                            ; D4BD
        tax                                     ; D4BF
        pla                                     ; D4C0
        cpx     #$24                            ; D4C1
        bcc     LD4A8                           ; D4C3
LD4C5:  rts                                     ; D4C5

; ----------------------------------------------------------------------------
LD4C6:  jsr     LD060                           ; D4C6
        lda     #$02                            ; D4C9
        sta     $0406                           ; D4CB
        lda     #$5F                            ; D4CE
        jsr     LE006                           ; D4D0
        lda     #$01                            ; D4D3
        jsr     LDC6E                           ; D4D5
        and     #$81                            ; D4D8
        bmi     LD4C5                           ; D4DA
        tax                                     ; D4DC
        beq     LD4E1                           ; D4DD
        ldx     #$03                            ; D4DF
LD4E1:  lda     $05E0,x                         ; D4E1
        sta     $0503                           ; D4E4
        txa                                     ; D4E7
        lsr     a                               ; D4E8
        tax                                     ; D4E9
        lda     #$62                            ; D4EA
        ldy     $0407,x                         ; D4EC
        beq     LD4F4                           ; D4EF
        jmp     LD590                           ; D4F1

; ----------------------------------------------------------------------------
LD4F4:  inc     $0407,x                         ; D4F4
        lda     #$60                            ; D4F7
        jsr     LE006                           ; D4F9
        lda     $0503                           ; D4FC
        pha                                     ; D4FF
        jsr     LCFC3                           ; D500
        pla                                     ; D503
        tax                                     ; D504
        php                                     ; D505
        clc                                     ; D506
        adc     #$7F                            ; D507
        sta     $07                             ; D509
        plp                                     ; D50B
        bcc     LD578                           ; D50C
        ldy     #$00                            ; D50E
        cpx     $05E0                           ; D510
        beq     LD517                           ; D513
        iny                                     ; D515
        nop                                     ; D516
LD517:  tya                                     ; D517
        jsr     LCFC0                           ; D518
        sta     $05C1                           ; D51B
        lda     #$63                            ; D51E
        jsr     LD57A                           ; D520
        lda     #$81                            ; D523
        jsr     LD0E4                           ; D525
        cpy     #$01                            ; D528
        bne     LD578                           ; D52A
        lda     $05C1                           ; D52C
        jsr     LCFCF                           ; D52F
        ldx     #$00                            ; D532
LD534:  lda     $89,x                           ; D534
        cmp     $0D,x                           ; D536
        bcc     LD578                           ; D538
        bne     LD541                           ; D53A
        inx                                     ; D53C
        cpx     #$03                            ; D53D
        bcc     LD534                           ; D53F
LD541:  ldx     #$02                            ; D541
LD543:  lda     $89,x                           ; D543
        cmp     $0D,x                           ; D545
        bcs     LD54D                           ; D547
        adc     #$0B                            ; D549
        dec     $88,x                           ; D54B
LD54D:  sbc     $0D,x                           ; D54D
        sta     $89,x                           ; D54F
        dex                                     ; D551
        bpl     LD543                           ; D552
        jsr     LD060                           ; D554
        ldx     #$00                            ; D557
        sec                                     ; D559
        jsr     LDC4A                           ; D55A
        lda     $0503                           ; D55D
        sta     $0500                           ; D560
        jsr     LCFD2                           ; D563
        lda     #$00                            ; D566
        sta     $0500                           ; D568
        lda     $0407                           ; D56B
        and     $0408                           ; D56E
        sta     $0407                           ; D571
        lda     #$64                            ; D574
        bne     LD590                           ; D576
LD578:  lda     #$61                            ; D578
LD57A:  pha                                     ; D57A
        jsr     LE95B                           ; D57B
        lda     $07                             ; D57E
        sta     $0409                           ; D580
        lda     #$01                            ; D583
        jsr     LD38C                           ; D585
        lda     #$DB                            ; D588
        sta     $042E                           ; D58A
        pla                                     ; D58D
        ora     #$80                            ; D58E
LD590:  jsr     LE006                           ; D590
        rts                                     ; D593

; ----------------------------------------------------------------------------
LD594:  jsr     LD932                           ; D594
        bcc     LD5A0                           ; D597
        lda     #$01                            ; D599
        sta     $0506                           ; D59B
        bne     LD5C0                           ; D59E
LD5A0:  lda     #$0F                            ; D5A0
        jsr     LE006                           ; D5A2
LD5A5:  jsr     LD5C4                           ; D5A5
        jsr     LD034                           ; D5A8
        sta     $00                             ; D5AB
        sta     $05C1                           ; D5AD
        jsr     LDD49                           ; D5B0
LD5B3:  jsr     LE95B                           ; D5B3
        jsr     LD5E0                           ; D5B6
        lda     $1A                             ; D5B9
        bpl     LD5B3                           ; D5BB
        jsr     LD49C                           ; D5BD
LD5C0:  pla                                     ; D5C0
        sta     $1A                             ; D5C1
        rts                                     ; D5C3

; ----------------------------------------------------------------------------
LD5C4:  lda     $11                             ; D5C4
        and     #$E7                            ; D5C6
        sta     $11                             ; D5C8
        sta     PPU_MASK                        ; D5CA
        jsr     LE95B                           ; D5CD
        jsr     LEA7E                           ; D5D0
        lda     #$81                            ; D5D3
        jsr     LE9EB                           ; D5D5
        rts                                     ; D5D8

; ----------------------------------------------------------------------------
LD5D9:  lda     $11                             ; D5D9
        ora     #$18                            ; D5DB
        sta     $11                             ; D5DD
        rts                                     ; D5DF

; ----------------------------------------------------------------------------
LD5E0:  lda     $1A                             ; D5E0
        jsr     LE97D                           ; D5E2
        sbc     ($D5),y                         ; D5E5
        sed                                     ; D5E7
        dec     $07,x                           ; D5E8
        cld                                     ; D5EA
        brk                                     ; D5EB
        cpx     #$99                            ; D5EC
        cmp     LDB06,y                         ; D5EE
LD5F1:  ldx     #$00                            ; D5F1
        stx     $02                             ; D5F3
        stx     $03                             ; D5F5
        ldy     #$00                            ; D5F7
LD5F9:  lda     $0335,x                         ; D5F9
        beq     LD614                           ; D5FC
        lda     $02                             ; D5FE
        tax                                     ; D600
        asl     a                               ; D601
        tay                                     ; D602
        lda     LD6ED,x                         ; D603
        sta     $04                             ; D606
        lda     $03C0,y                         ; D608
        bne     LD60E                           ; D60B
        sec                                     ; D60D
LD60E:  jsr     LD624                           ; D60E
        jsr     LE95B                           ; D611
LD614:  inc     $02                             ; D614
        ldx     $02                             ; D616
        ldy     $02                             ; D618
        cpx     #$0B                            ; D61A
        bcs     LD621                           ; D61C
        jmp     LD5F9                           ; D61E

; ----------------------------------------------------------------------------
LD621:  inc     $1A                             ; D621
        rts                                     ; D623

; ----------------------------------------------------------------------------
LD624:  ldy     $04                             ; D624
        ldx     $03                             ; D626
        lda     LD69B,y                         ; D628
        sta     $06                             ; D62B
        iny                                     ; D62D
        iny                                     ; D62E
        lda     #$00                            ; D62F
        sta     $05                             ; D631
        lda     LD69A,y                         ; D633
        bcc     LD647                           ; D636
        ldy     #$00                            ; D638
        and     #$F0                            ; D63A
        cmp     #$50                            ; D63C
        beq     LD647                           ; D63E
        bne     LD644                           ; D640
LD642:  lda     $07                             ; D642
LD644:  clc                                     ; D644
        adc     #$08                            ; D645
LD647:  sta     $07                             ; D647
LD649:  lda     LD69B,y                         ; D649
        cmp     #$FF                            ; D64C
        beq     LD682                           ; D64E
        pha                                     ; D650
        ora     #$81                            ; D651
        sta     $0201,x                         ; D653
        pla                                     ; D656
        lsr     a                               ; D657
        and     #$40                            ; D658
        sta     $0202,x                         ; D65A
        lda     $07                             ; D65D
        sta     $0203,x                         ; D65F
        lda     $06                             ; D662
        sta     $0200,x                         ; D664
        inx                                     ; D667
        inx                                     ; D668
        inx                                     ; D669
        inx                                     ; D66A
        iny                                     ; D66B
        bcc     LD676                           ; D66C
        ror     $05                             ; D66E
        adc     #$10                            ; D670
        sta     $06                             ; D672
        bne     LD649                           ; D674
LD676:  lda     $05                             ; D676
        bpl     LD642                           ; D678
        lda     $07                             ; D67A
        sbc     #$07                            ; D67C
        sta     $07                             ; D67E
        bcs     LD649                           ; D680
LD682:  stx     $03                             ; D682
LD684:  rts                                     ; D684

; ----------------------------------------------------------------------------
        jsr     L2021                           ; D685
        .byte   $22                             ; D688
        ldx     #$22                            ; D689
        and     ($A2,x)                         ; D68B
        .byte   $20                             ; D68D
        .byte   $20                             ; D68E
LD68F:  .byte   $22                             ; D68F
        eor     #$89                            ; D690
        .byte   $C3                             ; D692
        ora     #$CA                            ; D693
        .byte   $23                             ; D695
        .byte   $83                             ; D696
        .byte   $C7                             ; D697
        .byte   $43                             ; D698
LD699:  .byte   $C9                             ; D699
LD69A:  .byte   $A3                             ; D69A
LD69B:  .byte   $42                             ; D69B
        .byte   $FF                             ; D69C
        clc                                     ; D69D
        rti                                     ; D69E

; ----------------------------------------------------------------------------
        clc                                     ; D69F
        .byte   $1A                             ; D6A0
        rol     a                               ; D6A1
        plp                                     ; D6A2
        .byte   $FF                             ; D6A3
        pla                                     ; D6A4
        .byte   $44                             ; D6A5
        jsr     L4030                           ; D6A6
        .byte   $FF                             ; D6A9
        sec                                     ; D6AA
        clc                                     ; D6AB
        ldx     $4E2F                           ; D6AC
        dec     $88FF                           ; D6AF
        rti                                     ; D6B2

; ----------------------------------------------------------------------------
        brk                                     ; D6B3
        bpl     LD6DA                           ; D6B4
        sta     ($82,x)                         ; D6B6
        rol     $12                             ; D6B8
        .byte   $02                             ; D6BA
        .byte   $FF                             ; D6BB
        clv                                     ; D6BC
        bvc     LD6F9                           ; D6BD
        lsr     a                               ; D6BF
        .byte   $FF                             ; D6C0
        bcc     LD6DB                           ; D6C1
        stx     $06                             ; D6C3
        .byte   $FF                             ; D6C5
LD6C6:  pla                                     ; D6C6
        clc                                     ; D6C7
        dec     $56,x                           ; D6C8
        .byte   $FF                             ; D6CA
        clv                                     ; D6CB
        sec                                     ; D6CC
        nop                                     ; D6CD
        ror     a                               ; D6CE
        .byte   $FF                             ; D6CF
        clc                                     ; D6D0
        bpl     LD699                           ; D6D1
        ldx     $36,y                           ; D6D3
        lsr     $FF                             ; D6D5
        sec                                     ; D6D7
        rti                                     ; D6D8

; ----------------------------------------------------------------------------
        .byte   $F0                             ; D6D9
LD6DA:  .byte   $D0                             ; D6DA
LD6DB:  bvc     LD74E                           ; D6DB
        .byte   $72                             ; D6DD
        .byte   $52                             ; D6DE
        .byte   $D2                             ; D6DF
        .byte   $F2                             ; D6E0
        .byte   $FF                             ; D6E1
        bcs     LD6F4                           ; D6E2
        beq     LD6C6                           ; D6E4
        rts                                     ; D6E6

; ----------------------------------------------------------------------------
        adc     ($72),y                         ; D6E7
        .byte   $62                             ; D6E9
        .byte   $E2                             ; D6EA
        .byte   $F2                             ; D6EB
        .byte   $FF                             ; D6EC
LD6ED:  .byte   $02                             ; D6ED
        ora     #$0F                            ; D6EE
        asl     $21,x                           ; D6F0
        rol     $2B                             ; D6F2
LD6F4:  bmi     LD72B                           ; D6F4
        .byte   $3C                             ; D6F6
        .byte   $47                             ; D6F7
LD6F8:  .byte   $A5                             ; D6F8
LD6F9:  brk                                     ; D6F9
        bne     LD712                           ; D6FA
        jsr     LD5D9                           ; D6FC
        lda     #$20                            ; D6FF
        sta     $08                             ; D701
        lsr     a                               ; D703
        sta     $0A                             ; D704
        lda     #$6D                            ; D706
        sta     $09                             ; D708
        lda     #$00                            ; D70A
        sta     $01                             ; D70C
        sta     $02                             ; D70E
        sta     $03                             ; D710
LD712:  lda     #$40                            ; D712
        ldx     $03                             ; D714
        bne     LD71B                           ; D716
        asl     a                               ; D718
        bne     LD727                           ; D719
LD71B:  cpx     #$0C                            ; D71B
        bcc     LD727                           ; D71D
        lda     #$C0                            ; D71F
        jsr     LDDEA                           ; D721
        inc     $1A                             ; D724
LD726:  rts                                     ; D726

; ----------------------------------------------------------------------------
LD727:  jsr     LDDEA                           ; D727
        .byte   $E6                             ; D72A
LD72B:  .byte   $03                             ; D72B
        ldx     $02                             ; D72C
        inc     $02                             ; D72E
        txa                                     ; D730
        ora     $01                             ; D731
        beq     LD76E                           ; D733
        ldy     $01                             ; D735
        dex                                     ; D737
        bmi     LD77C                           ; D738
        bne     LD74A                           ; D73A
        cpy     #$1B                            ; D73C
        bcs     LD726                           ; D73E
        lda     $050E,y                         ; D740
        bmi     LD726                           ; D743
        sbc     #$00                            ; D745
        jmp     LE002                           ; D747

; ----------------------------------------------------------------------------
LD74A:  dex                                     ; D74A
        stx     $02                             ; D74B
        tya                                     ; D74D
LD74E:  bne     LD753                           ; D74E
        jmp     LD781                           ; D750

; ----------------------------------------------------------------------------
LD753:  cpy     #$1B                            ; D753
        bcs     LD75A                           ; D755
        jmp     LD7A3                           ; D757

; ----------------------------------------------------------------------------
LD75A:  lda     #$8B                            ; D75A
        jsr     LE002                           ; D75C
        lda     $03D6                           ; D75F
        sta     $05                             ; D762
        lda     $03D7                           ; D764
        sta     $06                             ; D767
        ldx     #$10                            ; D769
        jmp     LD2DC                           ; D76B

; ----------------------------------------------------------------------------
LD76E:  ldx     $05C2                           ; D76E
        beq     LD779                           ; D771
        inx                                     ; D773
        inx                                     ; D774
        txa                                     ; D775
        jsr     LD3F4                           ; D776
LD779:  inc     $00                             ; D779
        rts                                     ; D77B

; ----------------------------------------------------------------------------
LD77C:  cpy     #$1B                            ; D77C
        bcs     LD779                           ; D77E
        rts                                     ; D780

; ----------------------------------------------------------------------------
LD781:  lda     $81                             ; D781
        jsr     LCFCF                           ; D783
        ldx     #$02                            ; D786
LD788:  lda     $0D,x                           ; D788
        sta     $0168,x                         ; D78A
        dex                                     ; D78D
        bpl     LD788                           ; D78E
        ldx     #$02                            ; D790
LD792:  lda     $8C,x                           ; D792
        sta     $016D,x                         ; D794
        dex                                     ; D797
        bpl     LD792                           ; D798
        ldy     #$00                            ; D79A
        jsr     LD972                           ; D79C
        jsr     LD7EB                           ; D79F
        rts                                     ; D7A2

; ----------------------------------------------------------------------------
LD7A3:  lda     $050E,y                         ; D7A3
        cmp     #$FF                            ; D7A6
        beq     LD7FF                           ; D7A8
        sty     $04                             ; D7AA
        asl     a                               ; D7AC
        tax                                     ; D7AD
        lda     $03BF,x                         ; D7AE
        sta     $05                             ; D7B1
        lda     $03BE,x                         ; D7B3
        jsr     LCFCF                           ; D7B6
        ldx     #$02                            ; D7B9
LD7BB:  lda     $0D,x                           ; D7BB
        sta     $0168,x                         ; D7BD
        dex                                     ; D7C0
        bpl     LD7BB                           ; D7C1
        lda     $05                             ; D7C3
        jsr     LCFCF                           ; D7C5
        ldx     #$02                            ; D7C8
LD7CA:  lda     $0D,x                           ; D7CA
        sta     $016D,x                         ; D7CC
        dex                                     ; D7CF
        bpl     LD7CA                           ; D7D0
        ldy     $04                             ; D7D2
        jsr     LD972                           ; D7D4
        lda     $0173                           ; D7D7
        sta     $0172                           ; D7DA
        lda     $0176                           ; D7DD
        sta     $0175                           ; D7E0
        lda     #$2C                            ; D7E3
        sta     $0173                           ; D7E5
        sta     $0176                           ; D7E8
LD7EB:  lda     #$20                            ; D7EB
        sta     $0167                           ; D7ED
        lda     #$21                            ; D7F0
        sta     $016C                           ; D7F2
        lda     #$4A                            ; D7F5
        sta     $0171                           ; D7F7
        lda     #$4B                            ; D7FA
        sta     $0174                           ; D7FC
LD7FF:  lda     $01                             ; D7FF
        clc                                     ; D801
        adc     #$09                            ; D802
        sta     $01                             ; D804
        rts                                     ; D806

; ----------------------------------------------------------------------------
LD807:  jsr     LD8EB                           ; D807
        sta     $00                             ; D80A
        sta     $01                             ; D80C
        sta     $0401                           ; D80E
        ldx     #$09                            ; D811
LD813:  sta     $0418,x                         ; D813
        dex                                     ; D816
        bpl     LD813                           ; D817
        lda     #$22                            ; D819
        sta     $08                             ; D81B
        lda     #$0D                            ; D81D
        sta     $09                             ; D81F
        lda     #$10                            ; D821
        sta     $0A                             ; D823
        lda     #$01                            ; D825
        sta     $0403                           ; D827
        lda     $0414                           ; D82A
        inc     $1A                             ; D82D
        cmp     #$0A                            ; D82F
        bcs     LD85B                           ; D831
        jsr     LD860                           ; D833
        jsr     LE97D                           ; D836
        .byte   $5F                             ; D839
        cld                                     ; D83A
        .byte   $5F                             ; D83B
        cld                                     ; D83C
        .byte   $97                             ; D83D
        cld                                     ; D83E
        eor     $F6D8                           ; D83F
        cld                                     ; D842
        eor     ($D8),y                         ; D843
        .byte   $5F                             ; D845
        cld                                     ; D846
        .byte   $3F                             ; D847
        cmp     LD85F,y                         ; D848
        and     $D9                             ; D84B
        ldx     #$05                            ; D84D
        bne     LD853                           ; D84F
        ldx     #$06                            ; D851
LD853:  jsr     LDA44                           ; D853
        inc     $0403                           ; D856
        inc     $1A                             ; D859
LD85B:  lda     #$40                            ; D85B
        sta     $00                             ; D85D
LD85F:  rts                                     ; D85F

; ----------------------------------------------------------------------------
LD860:  pha                                     ; D860
        tax                                     ; D861
        lda     LDD89,x                         ; D862
        beq     LD895                           ; D865
        sta     $3B                             ; D867
        ldy     LDD92,x                         ; D869
        ldx     #$01                            ; D86C
        asl     $3B                             ; D86E
        bcc     LD879                           ; D870
        lda     LDD9B,y                         ; D872
        sta     $0409                           ; D875
        iny                                     ; D878
LD879:  asl     $3B                             ; D879
        bcc     LD88A                           ; D87B
        lda     LDD9B,y                         ; D87D
        sta     $0409,x                         ; D880
        lda     LDDB0,x                         ; D883
        sta     $0418,x                         ; D886
        iny                                     ; D889
LD88A:  inx                                     ; D88A
        cpx     #$04                            ; D88B
        bne     LD891                           ; D88D
        ldx     #$05                            ; D88F
LD891:  lda     $3B                             ; D891
        bne     LD879                           ; D893
LD895:  pla                                     ; D895
        rts                                     ; D896

; ----------------------------------------------------------------------------
        lda     #$06                            ; D897
        sta     $04                             ; D899
        lda     #$01                            ; D89B
        sta     $03                             ; D89D
        ldx     $0335                           ; D89F
        sta     $0335                           ; D8A2
        tay                                     ; D8A5
        txa                                     ; D8A6
        pha                                     ; D8A7
        sty     $02                             ; D8A8
LD8AA:  ldx     $89C0,y                         ; D8AA
        lda     $0334,x                         ; D8AD
        beq     LD8D6                           ; D8B0
        ldx     $89C1,y                         ; D8B2
        lda     $0334,x                         ; D8B5
        beq     LD8D6                           ; D8B8
        ldx     $03                             ; D8BA
        cpx     #$04                            ; D8BC
        bne     LD8C2                           ; D8BE
        inx                                     ; D8C0
        inx                                     ; D8C1
LD8C2:  txa                                     ; D8C2
        bcc     LD8C7                           ; D8C3
        sbc     #$02                            ; D8C5
LD8C7:  adc     #$97                            ; D8C7
        sta     $0418,x                         ; D8C9
        lda     $02                             ; D8CC
        adc     #$B5                            ; D8CE
        sta     $0409,x                         ; D8D0
        inx                                     ; D8D3
        stx     $03                             ; D8D4
LD8D6:  clc                                     ; D8D6
        tya                                     ; D8D7
        adc     #$05                            ; D8D8
        tay                                     ; D8DA
        inc     $02                             ; D8DB
        dec     $04                             ; D8DD
        bne     LD8AA                           ; D8DF
        pla                                     ; D8E1
        sta     $0335                           ; D8E2
        lda     #$D7                            ; D8E5
        sta     $0409                           ; D8E7
        rts                                     ; D8EA

; ----------------------------------------------------------------------------
LD8EB:  ldx     #$0A                            ; D8EB
        lda     #$00                            ; D8ED
LD8EF:  sta     $0409,x                         ; D8EF
        dex                                     ; D8F2
        bpl     LD8EF                           ; D8F3
        rts                                     ; D8F5

; ----------------------------------------------------------------------------
        lda     $0517                           ; D8F6
        and     $0520                           ; D8F9
        bmi     LD906                           ; D8FC
        lda     $0515                           ; D8FE
        ora     $0516                           ; D901
        bne     LD909                           ; D904
LD906:  jmp     LDA16                           ; D906

; ----------------------------------------------------------------------------
LD909:  lda     #$03                            ; D909
        sta     $00                             ; D90B
        jmp     LE000                           ; D90D

; ----------------------------------------------------------------------------
LD910:  tay                                     ; D910
        lda     $0409,y                         ; D911
        beq     LD924                           ; D914
        ldx     #$00                            ; D916
        bcc     LD91B                           ; D918
        inx                                     ; D91A
LD91B:  cpy     #$05                            ; D91B
        bcc     LD921                           ; D91D
        ldx     #$08                            ; D91F
LD921:  jsr     LE002                           ; D921
LD924:  rts                                     ; D924

; ----------------------------------------------------------------------------
        lda     #$80                            ; D925
        sta     $1A                             ; D927
        lda     $0506                           ; D929
        bne     LD931                           ; D92C
        jsr     LD5C4                           ; D92E
LD931:  rts                                     ; D931

; ----------------------------------------------------------------------------
LD932:  sec                                     ; D932
        lda     $03F4                           ; D933
        and     #$F7                            ; D936
        beq     LD931                           ; D938
        lda     #$00                            ; D93A
        jmp     LCFBD                           ; D93C

; ----------------------------------------------------------------------------
        lda     #$04                            ; D93F
        sta     $0402                           ; D941
        lda     $03D7                           ; D944
        cmp     #$04                            ; D947
        bcs     LD963                           ; D949
        lda     $03D6                           ; D94B
        bne     LD958                           ; D94E
        lda     $03D7                           ; D950
        sta     $0402                           ; D953
        bcc     LD963                           ; D956
LD958:  dec     $03D6                           ; D958
        lda     $03D7                           ; D95B
        adc     #$0A                            ; D95E
        sta     $03D7                           ; D960
LD963:  sec                                     ; D963
        lda     $03D7                           ; D964
        sbc     $0402                           ; D967
        sta     $03D7                           ; D96A
        lda     #$08                            ; D96D
        jmp     LDA2F                           ; D96F

; ----------------------------------------------------------------------------
LD972:  tya                                     ; D972
        pha                                     ; D973
        lda     $0516,y                         ; D974
        pha                                     ; D977
        lda     $0515,y                         ; D978
        jsr     LCFCF                           ; D97B
        ldx     #$01                            ; D97E
LD980:  lda     $0E,x                           ; D980
        sta     $0172,x                         ; D982
        dex                                     ; D985
        bpl     LD980                           ; D986
        pla                                     ; D988
        jsr     LCFCF                           ; D989
        ldx     #$01                            ; D98C
LD98E:  lda     $0E,x                           ; D98E
        sta     $0175,x                         ; D990
        dex                                     ; D993
        bpl     LD98E                           ; D994
        pla                                     ; D996
        tay                                     ; D997
        rts                                     ; D998

; ----------------------------------------------------------------------------
        lda     $0401                           ; D999
        beq     LD9A1                           ; D99C
        jmp     LE000                           ; D99E

; ----------------------------------------------------------------------------
LD9A1:  lda     $0414                           ; D9A1
        asl     a                               ; D9A4
        tax                                     ; D9A5
        lda     LDD78,x                         ; D9A6
        tay                                     ; D9A9
        beq     LD9BB                           ; D9AA
        lda     LDD77,x                         ; D9AC
        ldx     #$00                            ; D9AF
LD9B1:  sta     $040A,x                         ; D9B1
        inx                                     ; D9B4
        clc                                     ; D9B5
        adc     #$01                            ; D9B6
        dey                                     ; D9B8
        bne     LD9B1                           ; D9B9
LD9BB:  jsr     LE95B                           ; D9BB
        jsr     LDF79                           ; D9BE
        and     #$FF                            ; D9C1
        beq     LD9BB                           ; D9C3
        bmi     LD9FA                           ; D9C5
        jsr     LDE51                           ; D9C7
        sty     $00                             ; D9CA
        ldx     $0409,y                         ; D9CC
        bpl     LD9D3                           ; D9CF
        ldx     #$07                            ; D9D1
LD9D3:  dex                                     ; D9D3
        txa                                     ; D9D4
        jsr     LE97D                           ; D9D5
        .byte   $12                             ; D9D8
        .byte   $DA                             ; D9D9
        .byte   $37                             ; D9DA
        .byte   $DA                             ; D9DB
        adc     $A6D9                           ; D9DC
        .byte   $DA                             ; D9DF
        .byte   $1A                             ; D9E0
        .byte   $DA                             ; D9E1
        tsx                                     ; D9E2
        .byte   $DA                             ; D9E3
        .byte   $64                             ; D9E4
        .byte   $DA                             ; D9E5
        bit     $DA                             ; D9E6
        tsx                                     ; D9E8
        .byte   $DA                             ; D9E9
        asl     $DA,x                           ; D9EA
        and     #$DA                            ; D9EC
        cmp     ($DA,x)                         ; D9EE
        cmp     $DA                             ; D9F0
        and     $25DA                           ; D9F2
        cmp     LDABA,y                         ; D9F5
        txa                                     ; D9F8
        .byte   $DA                             ; D9F9
LD9FA:  lda     $0414                           ; D9FA
        jsr     LE97D                           ; D9FD
        inc     $BADA,x                         ; DA00
        .byte   $DA                             ; DA03
        tsx                                     ; DA04
        .byte   $DA                             ; DA05
        tsx                                     ; DA06
        .byte   $DA                             ; DA07
        inc     $BADA,x                         ; DA08
        .byte   $DA                             ; DA0B
        sbc     $FEDA,y                         ; DA0C
        .byte   $DA                             ; DA0F
        tsx                                     ; DA10
        .byte   $DA                             ; DA11
        lda     #$01                            ; DA12
        bne     LDA2F                           ; DA14
LDA16:  lda     #$07                            ; DA16
        bne     LDA2F                           ; DA18
        ldx     #$07                            ; DA1A
        lda     $0517                           ; DA1C
        and     $0520                           ; DA1F
        bmi     LDA26                           ; DA22
LDA24:  ldx     #$04                            ; DA24
LDA26:  txa                                     ; DA26
        bne     LDA2F                           ; DA27
        lda     #$06                            ; DA29
        bne     LDA2F                           ; DA2B
        lda     #$05                            ; DA2D
LDA2F:  sta     $0414                           ; DA2F
LDA32:  lda     #$02                            ; DA32
        sta     $1A                             ; DA34
        rts                                     ; DA36

; ----------------------------------------------------------------------------
        lda     $033E                           ; DA37
        bne     LDA40                           ; DA3A
        ldx     #$00                            ; DA3C
        beq     LDA44                           ; DA3E
LDA40:  lda     #$02                            ; DA40
        bne     LDA2F                           ; DA42
LDA44:  lda     LDDB7,x                         ; DA44
        sta     $0422                           ; DA47
        lda     #$00                            ; DA4A
        sta     $0423                           ; DA4C
        lda     #$23                            ; DA4F
        sta     $0426                           ; DA51
        lda     #$3C                            ; DA54
        sta     $0427                           ; DA56
        lda     LDDC7,x                         ; DA59
        sta     $0416                           ; DA5C
        lda     LDDBF,x                         ; DA5F
        bne     LDA2F                           ; DA62
        ldy     $00                             ; DA64
        lda     $0409,y                         ; DA66
        sec                                     ; DA69
        sbc     #$B5                            ; DA6A
        tay                                     ; DA6C
        jsr     LDB90                           ; DA6D
        lda     $05C2                           ; DA70
        beq     LDA86                           ; DA73
        lda     $04                             ; DA75
        sta     $0517                           ; DA77
        lda     $05                             ; DA7A
        sta     $0520                           ; DA7C
LDA7F:  jsr     LDBC0                           ; DA7F
        lda     #$03                            ; DA82
        bne     LDA2F                           ; DA84
LDA86:  ldx     #$01                            ; DA86
        bne     LDA44                           ; DA88
        jsr     LD932                           ; DA8A
        php                                     ; DA8D
        ldx     #$07                            ; DA8E
        jsr     LDA44                           ; DA90
        plp                                     ; DA93
        bcc     LDAA5                           ; DA94
        ldx     #$01                            ; DA96
        stx     $0415                           ; DA98
        stx     $0506                           ; DA9B
        dex                                     ; DA9E
        stx     $0422                           ; DA9F
        stx     $0500                           ; DAA2
LDAA5:  rts                                     ; DAA5

; ----------------------------------------------------------------------------
        ldx     #$FF                            ; DAA6
        stx     $ED                             ; DAA8
        inx                                     ; DAAA
        stx     $02                             ; DAAB
        lda     $0335                           ; DAAD
        bne     LDAB4                           ; DAB0
        ldx     #$03                            ; DAB2
LDAB4:  stx     $01                             ; DAB4
        lda     #$05                            ; DAB6
        bne     LDABC                           ; DAB8
LDABA:  lda     #$00                            ; DABA
LDABC:  sta     $00                             ; DABC
        inc     $1A                             ; DABE
        rts                                     ; DAC0

; ----------------------------------------------------------------------------
        lda     #$01                            ; DAC1
        bne     LDAC7                           ; DAC3
        lda     #$02                            ; DAC5
LDAC7:  pha                                     ; DAC7
        pha                                     ; DAC8
        jsr     LE95B                           ; DAC9
        jsr     LDBE2                           ; DACC
        ldx     #$00                            ; DACF
        lda     #$FC                            ; DAD1
        jsr     LE002                           ; DAD3
        pla                                     ; DAD6
        tax                                     ; DAD7
        lda     #$E0                            ; DAD8
        sta     $03                             ; DADA
        jsr     LDBFF                           ; DADC
        lda     #$01                            ; DADF
        bit     $0520                           ; DAE1
        bpl     LDAE9                           ; DAE4
        sta     $041A                           ; DAE6
LDAE9:  bit     $0517                           ; DAE9
        bpl     LDAF3                           ; DAEC
        lda     #$03                            ; DAEE
        sta     $0419                           ; DAF0
LDAF3:  sta     $0403                           ; DAF3
        pla                                     ; DAF6
        bpl     LDABC                           ; DAF7
        lda     #$06                            ; DAF9
        jmp     LDA2F                           ; DAFB

; ----------------------------------------------------------------------------
        rts                                     ; DAFE

; ----------------------------------------------------------------------------
        lda     #$04                            ; DAFF
        sta     $00                             ; DB01
LDB03:  jmp     LE000                           ; DB03

; ----------------------------------------------------------------------------
LDB06:  lda     $00                             ; DB06
        bne     LDB0D                           ; DB08
        jmp     LDD3C                           ; DB0A

; ----------------------------------------------------------------------------
LDB0D:  sec                                     ; DB0D
        sbc     #$06                            ; DB0E
        bne     LDB03                           ; DB10
        lda     $0520                           ; DB12
        bmi     LDB49                           ; DB15
        lda     #$00                            ; DB17
LDB19:  tay                                     ; DB19
        iny                                     ; DB1A
        jsr     LDB90                           ; DB1B
        pha                                     ; DB1E
        ldx     #$01                            ; DB1F
        lda     $0517                           ; DB21
        cmp     $04                             ; DB24
        beq     LDB2D                           ; DB26
        dex                                     ; DB28
        cmp     $05                             ; DB29
        bne     LDB34                           ; DB2B
LDB2D:  lda     $0520                           ; DB2D
        cmp     $04,x                           ; DB30
        beq     LDB43                           ; DB32
LDB34:  pla                                     ; DB34
        cmp     #$06                            ; DB35
        bcc     LDB19                           ; DB37
        jsr     LDA24                           ; DB39
        lda     #$00                            ; DB3C
        sta     $05C2                           ; DB3E
        beq     LDB49                           ; DB41
LDB43:  jsr     LDA7F                           ; DB43
        pla                                     ; DB46
        bpl     LDB4C                           ; DB47
LDB49:  jsr     LDBC0                           ; DB49
LDB4C:  lda     #$00                            ; DB4C
        sta     $0401                           ; DB4E
        jsr     LDA32                           ; DB51
        sec                                     ; DB54
        lda     #$2C                            ; DB55
        bcs     LDB5B                           ; DB57
        lda     #$7F                            ; DB59
LDB5B:  ldx     $0162                           ; DB5B
        sta     $0166,x                         ; DB5E
        lda     #$01                            ; DB61
        sta     $0165,x                         ; DB63
        ldy     $01                             ; DB66
        lda     LDB81,y                         ; DB68
        tay                                     ; DB6B
        lda     LD684,y                         ; DB6C
        and     #$3F                            ; DB6F
        sta     $0163,x                         ; DB71
        lda     LD68F,y                         ; DB74
        sta     $0164,x                         ; DB77
        inx                                     ; DB7A
        inx                                     ; DB7B
        inx                                     ; DB7C
        inx                                     ; DB7D
        jmp     LDC65                           ; DB7E

; ----------------------------------------------------------------------------
LDB81:  ora     ($FF,x)                         ; DB81
        ora     #$0A                            ; DB83
        .byte   $FF                             ; DB85
        .byte   $03                             ; DB86
        .byte   $02                             ; DB87
        .byte   $FF                             ; DB88
        .byte   $07                             ; DB89
        .byte   $04                             ; DB8A
        .byte   $FF                             ; DB8B
        asl     $05                             ; DB8C
        php                                     ; DB8E
        .byte   $0B                             ; DB8F
LDB90:  tya                                     ; DB90
        pha                                     ; DB91
        sta     $05C2                           ; DB92
        asl     a                               ; DB95
        asl     a                               ; DB96
        adc     $05C2                           ; DB97
        tay                                     ; DB9A
        lda     $89BC,y                         ; DB9B
        sta     $04                             ; DB9E
        lda     $89BD,y                         ; DBA0
        sta     $05                             ; DBA3
        ldx     #$01                            ; DBA5
LDBA7:  ldy     $04,x                           ; DBA7
        lda     $0334,y                         ; DBA9
        beq     LDBBB                           ; DBAC
        tya                                     ; DBAE
        asl     a                               ; DBAF
        tay                                     ; DBB0
        lda     $03BE,y                         ; DBB1
        beq     LDBBB                           ; DBB4
        dex                                     ; DBB6
        bpl     LDBA7                           ; DBB7
        bmi     LDBBE                           ; DBB9
LDBBB:  sta     $05C2                           ; DBBB
LDBBE:  pla                                     ; DBBE
        rts                                     ; DBBF

; ----------------------------------------------------------------------------
LDBC0:  lda     $1A                             ; DBC0
        pha                                     ; DBC2
        lda     $00                             ; DBC3
        pha                                     ; DBC5
        lda     $01                             ; DBC6
        pha                                     ; DBC8
        lda     #$00                            ; DBC9
        sta     $00                             ; DBCB
LDBCD:  jsr     LE95B                           ; DBCD
        jsr     LD6F8                           ; DBD0
        lda     $00                             ; DBD3
        lsr     a                               ; DBD5
        bcs     LDBCD                           ; DBD6
        pla                                     ; DBD8
        sta     $01                             ; DBD9
        pla                                     ; DBDB
        sta     $00                             ; DBDC
        pla                                     ; DBDE
        sta     $1A                             ; DBDF
        rts                                     ; DBE1

; ----------------------------------------------------------------------------
LDBE2:  ldx     $0162                           ; DBE2
        ldy     #$0B                            ; DBE5
LDBE7:  lda     LDBF3,y                         ; DBE7
        sta     $0163,x                         ; DBEA
        inx                                     ; DBED
        dey                                     ; DBEE
        bne     LDBE7                           ; DBEF
        .byte   $4C                             ; DBF1
        .byte   $65                             ; DBF2
LDBF3:  .byte   $DC                             ; DBF3
        sta     $2C2C                           ; DBF4
        bit     $2C2C                           ; DBF7
        bit     $082C                           ; DBFA
        .byte   $B7                             ; DBFD
        .byte   $21                             ; DBFE
LDBFF:  lda     #$01                            ; DBFF
        sta     $0403                           ; DC01
        ldy     #$09                            ; DC04
        lsr     a                               ; DC06
LDC07:  sta     $0418,y                         ; DC07
        dey                                     ; DC0A
        bpl     LDC07                           ; DC0B
        sty     $ED                             ; DC0D
        lda     LDC32,x                         ; DC0F
        tax                                     ; DC12
        lda     $03                             ; DC13
        sta     $04                             ; DC15
        bmi     LDC1C                           ; DC17
        asl     $0403                           ; DC19
LDC1C:  iny                                     ; DC1C
LDC1D:  asl     $04                             ; DC1D
        bcc     LDC27                           ; DC1F
        lda     LDC36,x                         ; DC21
        sta     $0419,y                         ; DC24
LDC27:  beq     LDC31                           ; DC27
        inx                                     ; DC29
        iny                                     ; DC2A
        cpy     #$04                            ; DC2B
        beq     LDC1C                           ; DC2D
        bne     LDC1D                           ; DC2F
LDC31:  rts                                     ; DC31

; ----------------------------------------------------------------------------
LDC32:  brk                                     ; DC32
        .byte   $07                             ; DC33
        asl     a                               ; DC34
        .byte   $0D                             ; DC35
LDC36:  tya                                     ; DC36
        sta     $9B9A,y                         ; DC37
        .byte   $9C                             ; DC3A
        sta     $9F9E,x                         ; DC3B
        cld                                     ; DC3E
        cpy     $D9                             ; DC3F
        .byte   $DA                             ; DC41
        cpy     $DB                             ; DC42
        .byte   $DC                             ; DC44
        cmp     LDFDE,x                         ; DC45
        cpx     #$AF                            ; DC48
LDC4A:  lda     #$28                            ; DC4A
        bcs     LDC50                           ; DC4C
        lda     #$2C                            ; DC4E
LDC50:  sec                                     ; DC50
        sta     $0165,x                         ; DC51
        ldy     $0403                           ; DC54
        lda     $0418,y                         ; DC57
        sta     $0163,x                         ; DC5A
        inx                                     ; DC5D
        lda     #$01                            ; DC5E
        sta     $0163,x                         ; DC60
        inx                                     ; DC63
        inx                                     ; DC64
LDC65:  lda     #$00                            ; DC65
        sta     $0163,x                         ; DC67
        stx     $0162                           ; DC6A
        rts                                     ; DC6D

; ----------------------------------------------------------------------------
LDC6E:  pha                                     ; DC6E
        jsr     LD8EB                           ; DC6F
        pla                                     ; DC72
        lsr     a                               ; DC73
        tay                                     ; DC74
        sta     $03                             ; DC75
        bcc     LDC91                           ; DC77
LDC79:  tax                                     ; DC79
        lda     $05E0,x                         ; DC7A
        bmi     LDC88                           ; DC7D
        adc     #$7E                            ; DC7F
        sta     $040B,y                         ; DC81
        jsr     LDCE3                           ; DC84
        iny                                     ; DC87
LDC88:  cpx     #$03                            ; DC88
        beq     LDCB1                           ; DC8A
        lda     #$03                            ; DC8C
        sec                                     ; DC8E
        bcs     LDC79                           ; DC8F
LDC91:  tax                                     ; DC91
        lda     $050E,x                         ; DC92
        bmi     LDCA9                           ; DC95
        sec                                     ; DC97
        sbc     #$01                            ; DC98
        ora     #$80                            ; DC9A
        sta     $040B,y                         ; DC9C
        jsr     LDCE3                           ; DC9F
        iny                                     ; DCA2
        cpy     #$02                            ; DCA3
        bne     LDCA9                           ; DCA5
        ldy     #$05                            ; DCA7
LDCA9:  txa                                     ; DCA9
        clc                                     ; DCAA
        adc     #$09                            ; DCAB
        cmp     #$1B                            ; DCAD
        bcc     LDC91                           ; DCAF
LDCB1:  lda     #$05                            ; DCB1
LDCB3:  pha                                     ; DCB3
        jsr     LE95B                           ; DCB4
        pla                                     ; DCB7
        jsr     LD38C                           ; DCB8
        asl     a                               ; DCBB
        adc     #$01                            ; DCBC
        cmp     #$09                            ; DCBE
        bcc     LDCB3                           ; DCC0
        ldx     #$03                            ; DCC2
        jsr     LDBFF                           ; DCC4
        inc     $0403                           ; DCC7
LDCCA:  jsr     LE95B                           ; DCCA
        jsr     LDF79                           ; DCCD
        and     #$FF                            ; DCD0
        beq     LDCCA                           ; DCD2
        bmi     LDCE2                           ; DCD4
        jsr     LDE51                           ; DCD6
        cmp     #$05                            ; DCD9
        bcc     LDCDF                           ; DCDB
        sbc     #$03                            ; DCDD
LDCDF:  sec                                     ; DCDF
        sbc     #$03                            ; DCE0
LDCE2:  rts                                     ; DCE2

; ----------------------------------------------------------------------------
LDCE3:  lda     LDCEB,y                         ; DCE3
        ora     $03                             ; DCE6
        sta     $03                             ; DCE8
        rts                                     ; DCEA

; ----------------------------------------------------------------------------
LDCEB:  jsr     L0810                           ; DCEB
        php                                     ; DCEE
        .byte   $04                             ; DCEF
        .byte   $02                             ; DCF0
LDCF1:  ldx     $0401                           ; DCF1
        dex                                     ; DCF4
        lda     LDD32,x                         ; DCF5
        sta     $03                             ; DCF8
        bne     LDD13                           ; DCFA
        tay                                     ; DCFC
        lda     $84                             ; DCFD
LDCFF:  iny                                     ; DCFF
        cmp     LD386,y                         ; DD00
        bcs     LDCFF                           ; DD03
        lda     $05C2                           ; DD05
        bne     LDD0B                           ; DD08
        dey                                     ; DD0A
LDD0B:  sec                                     ; DD0B
        ror     $03                             ; DD0C
        dey                                     ; DD0E
        bne     LDD0B                           ; DD0F
        beq     LDD2F                           ; DD11
LDD13:  lda     $0520                           ; DD13
        dex                                     ; DD16
        bne     LDD1E                           ; DD17
        ldx     $05CC                           ; DD19
        bne     LDD2D                           ; DD1C
LDD1E:  cpx     #$03                            ; DD1E
        bcc     LDD2F                           ; DD20
        bne     LDD27                           ; DD22
        lda     $0517                           ; DD24
LDD27:  eor     #$02                            ; DD27
        and     #$07                            ; DD29
        bne     LDD2F                           ; DD2B
LDD2D:  asl     $03                             ; DD2D
LDD2F:  ldx     #$03                            ; DD2F
        rts                                     ; DD31

; ----------------------------------------------------------------------------
LDD32:  cpy     #$E0                            ; DD32
        rts                                     ; DD34

; ----------------------------------------------------------------------------
        sed                                     ; DD35
        cpx     #$E0                            ; DD36
        brk                                     ; DD38
        brk                                     ; DD39
        brk                                     ; DD3A
        brk                                     ; DD3B
LDD3C:  ldx     #$01                            ; DD3C
        stx     $1A                             ; DD3E
        dex                                     ; DD40
        stx     $00                             ; DD41
        stx     $0400                           ; DD43
        stx     $0401                           ; DD46
LDD49:  lda     #$00                            ; DD49
        sta     $0414                           ; DD4B
        ldx     #$09                            ; DD4E
LDD50:  lda     #$FF                            ; DD50
        sta     $0517,x                         ; DD52
        lda     #$00                            ; DD55
        sta     $051E,x                         ; DD57
        sta     $051F,x                         ; DD5A
        dex                                     ; DD5D
        bmi     LDD64                           ; DD5E
        ldx     #$00                            ; DD60
        beq     LDD50                           ; DD62
LDD64:  lda     $0306                           ; DD64
        sta     $0515                           ; DD67
        lda     $0307                           ; DD6A
        sta     $0516                           ; DD6D
        jsr     LD48C                           ; DD70
        stx     $05C2                           ; DD73
        rts                                     ; DD76

; ----------------------------------------------------------------------------
LDD77:  .byte   $01                             ; DD77
LDD78:  .byte   $03                             ; DD78
        .byte   $04                             ; DD79
        .byte   $03                             ; DD7A
LDD7B:  .byte   $07                             ; DD7B
        brk                                     ; DD7C
        .byte   $07                             ; DD7D
        .byte   $03                             ; DD7E
        asl     a                               ; DD7F
LDD80:  brk                                     ; DD80
        ora     #$03                            ; DD81
        .byte   $0C                             ; DD83
        .byte   $03                             ; DD84
        .byte   $0F                             ; DD85
        brk                                     ; DD86
        .byte   $0F                             ; DD87
        .byte   $03                             ; DD88
LDD89:  beq     LDD7B                           ; DD89
        brk                                     ; DD8B
        bmi     LDD8E                           ; DD8C
LDD8E:  bmi     LDD80                           ; DD8E
        rts                                     ; DD90

; ----------------------------------------------------------------------------
        .byte   $F0                             ; DD91
LDD92:  brk                                     ; DD92
        .byte   $04                             ; DD93
        brk                                     ; DD94
        php                                     ; DD95
        brk                                     ; DD96
        asl     a                               ; DD97
        .byte   $0C                             ; DD98
        bpl     LDDAD                           ; DD99
LDD9B:  dec     $EC,x                           ; DD9B
        .byte   $D7                             ; DD9D
        .byte   $DA                             ; DD9E
        dec     $EC,x                           ; DD9F
        .byte   $DB                             ; DDA1
        .byte   $EB                             ; DDA2
        .byte   $DB                             ; DDA3
        .byte   $EB                             ; DDA4
        inc     $E5                             ; DDA5
        dec     $DC,x                           ; DDA7
        cmp     $8BDB,x                         ; DDA9
        .byte   $DB                             ; DDAC
LDDAD:  dec     $E1,x                           ; DDAD
        .byte   $EB                             ; DDAF
LDDB0:  .byte   $E2                             ; DDB0
        tya                                     ; DDB1
        sta     $9C9A,y                         ; DDB2
        .byte   $9D                             ; DDB5
        .byte   $9E                             ; DDB6
LDDB7:  ldy     $EC,x                           ; DDB7
        clv                                     ; DDB9
        brk                                     ; DDBA
        brk                                     ; DDBB
        .byte   $D2                             ; DDBC
        nop                                     ; DDBD
        .byte   $1E                             ; DDBE
LDDBF:  asl     a                               ; DDBF
        .byte   $0B                             ; DDC0
        .byte   $0C                             ; DDC1
        ora     $030E                           ; DDC2
        ora     $0F                             ; DDC5
LDDC7:  brk                                     ; DDC7
        .byte   $02                             ; DDC8
        ora     ($05,x)                         ; DDC9
        ora     $00                             ; DDCB
        brk                                     ; DDCD
        .byte   $09                             ; DDCE
LDDCF:  pha                                     ; DDCF
        ldx     #$00                            ; DDD0
        jsr     LDA44                           ; DDD2
        pla                                     ; DDD5
        sta     $0422                           ; DDD6
        jsr     LD85B                           ; DDD9
        jsr     LD807                           ; DDDC
LDDDF:  jsr     LE95B                           ; DDDF
        jsr     LE000                           ; DDE2
        lda     $00                             ; DDE5
        bne     LDDDF                           ; DDE7
        rts                                     ; DDE9

; ----------------------------------------------------------------------------
LDDEA:  sta     $3B                             ; DDEA
        bit     $3B                             ; DDEC
        ldy     #$2C                            ; DDEE
        asl     a                               ; DDF0
        bcc     LDDF5                           ; DDF1
        ldy     #$8C                            ; DDF3
LDDF5:  php                                     ; DDF5
        lda     $0162                           ; DDF6
        clc                                     ; DDF9
        adc     $0A                             ; DDFA
        sta     $3B                             ; DDFC
        tax                                     ; DDFE
        tya                                     ; DDFF
        ldy     $0A                             ; DE00
LDE02:  sta     $0166,x                         ; DE02
        dex                                     ; DE05
        dey                                     ; DE06
        bne     LDE02                           ; DE07
        ldy     #$8D                            ; DE09
        plp                                     ; DE0B
        php                                     ; DE0C
        bcc     LDE13                           ; DE0D
        iny                                     ; DE0F
        bvc     LDE13                           ; DE10
        iny                                     ; DE12
LDE13:  tya                                     ; DE13
        sta     $0166,x                         ; DE14
        plp                                     ; DE17
        bcc     LDE1C                           ; DE18
        adc     #$0F                            ; DE1A
LDE1C:  tay                                     ; DE1C
        lda     $3B                             ; DE1D
        tax                                     ; DE1F
        tya                                     ; DE20
        sta     $0167,x                         ; DE21
        inx                                     ; DE24
        lda     #$00                            ; DE25
        sta     $0167,x                         ; DE27
        inx                                     ; DE2A
        ldy     $0162                           ; DE2B
        txa                                     ; DE2E
        clc                                     ; DE2F
        adc     #$03                            ; DE30
        sta     $0162                           ; DE32
        lda     $0A                             ; DE35
        adc     #$02                            ; DE37
        sta     $0165,y                         ; DE39
        lda     $08                             ; DE3C
        sta     $0163,y                         ; DE3E
        lda     $09                             ; DE41
        sta     $0164,y                         ; DE43
LDE46:  adc     #$20                            ; DE46
        sta     $09                             ; DE48
        lda     $08                             ; DE4A
        adc     #$00                            ; DE4C
        sta     $08                             ; DE4E
        rts                                     ; DE50

; ----------------------------------------------------------------------------
LDE51:  tya                                     ; DE51
        pha                                     ; DE52
        lda     #$7D                            ; DE53
        jsr     LE992                           ; DE55
        pla                                     ; DE58
        tay                                     ; DE59
        rts                                     ; DE5A

; ----------------------------------------------------------------------------
        rts                                     ; DE5B

; ----------------------------------------------------------------------------
        tax                                     ; DE5C
        lda     ($AA),y                         ; DE5D
        .byte   $B3                             ; DE5F
        tax                                     ; DE60
        .byte   $B2                             ; DE61
        .byte   $D2                             ; DE62
        lda     ($D2),y                         ; DE63
        lda     ($AB),y                         ; DE65
        lda     ($AB),y                         ; DE67
        .byte   $B3                             ; DE69
        .byte   $AB                             ; DE6A
        .byte   $B2                             ; DE6B
        ldy     $ACB1                           ; DE6C
        .byte   $B3                             ; DE6F
        ldy     $ADB2                           ; DE70
        .byte   $B3                             ; DE73
        lda     $ADB2                           ; DE74
        lda     $AE,x                           ; DE77
        .byte   $B2                             ; DE79
        ldx     $AFB3                           ; DE7A
        .byte   $B2                             ; DE7D
        ldy     $B0B4                           ; DE7E
        .byte   $B3                             ; DE81
        .byte   $FF                             ; DE82
        .byte   $FF                             ; DE83
        .byte   $FF                             ; DE84
        .byte   $FF                             ; DE85
        .byte   $FF                             ; DE86
        .byte   $FF                             ; DE87
        .byte   $FF                             ; DE88
        .byte   $FF                             ; DE89
        .byte   $FF                             ; DE8A
        .byte   $FF                             ; DE8B
        .byte   $FF                             ; DE8C
        .byte   $FF                             ; DE8D
        .byte   $FF                             ; DE8E
        .byte   $FF                             ; DE8F
        .byte   $FF                             ; DE90
        .byte   $FF                             ; DE91
        .byte   $FF                             ; DE92
        lda     $1A                             ; DE93
        pha                                     ; DE95
        jsr     LD5C4                           ; DE96
        jsr     LD034                           ; DE99
        sta     $00                             ; DE9C
        lda     #$05                            ; DE9E
        jsr     LE8C8                           ; DEA0
        lda     #$81                            ; DEA3
        jsr     LE9EB                           ; DEA5
        lda     #$03                            ; DEA8
        sta     $0401                           ; DEAA
        jsr     LE95B                           ; DEAD
        jsr     LD5F1                           ; DEB0
        jsr     LD5D9                           ; DEB3
        lda     #$B0                            ; DEB6
        jsr     LDDCF                           ; DEB8
        lda     #$00                            ; DEBB
LDEBD:  tax                                     ; DEBD
        ldy     $0335,x                         ; DEBE
        beq     LDECB                           ; DEC1
        asl     a                               ; DEC3
        tax                                     ; DEC4
        ldy     $03C0,x                         ; DEC5
        beq     LDED4                           ; DEC8
        lsr     a                               ; DECA
LDECB:  clc                                     ; DECB
        adc     #$01                            ; DECC
        cmp     #$0B                            ; DECE
        bne     LDEBD                           ; DED0
        beq     LDED9                           ; DED2
LDED4:  lda     #$B2                            ; DED4
        jsr     LDDCF                           ; DED6
LDED9:  jsr     LE06B                           ; DED9
        jsr     LD5F1                           ; DEDC
        lda     #$06                            ; DEDF
        sta     $2F                             ; DEE1
LDEE3:  jsr     LE95B                           ; DEE3
        lda     $2F                             ; DEE6
        bne     LDEE3                           ; DEE8
        jsr     LD5C4                           ; DEEA
        lda     #$81                            ; DEED
        jsr     LE9EB                           ; DEEF
        jsr     LEA7E                           ; DEF2
        lda     #$02                            ; DEF5
        sta     $18                             ; DEF7
        jsr     LE95B                           ; DEF9
        pla                                     ; DEFC
        sta     $1A                             ; DEFD
        lda     #$0F                            ; DEFF
        jsr     LE8C8                           ; DF01
        lda     $031C                           ; DF04
        ora     #$0F                            ; DF07
        sta     $031C                           ; DF09
        jsr     LD5D9                           ; DF0C
        jmp     LE0EA                           ; DF0F

; ----------------------------------------------------------------------------
        ldy     #$00                            ; DF12
        beq     LDF18                           ; DF14
        ldy     #$03                            ; DF16
LDF18:  sta     $02                             ; DF18
        sty     $01                             ; DF1A
        ldx     #$48                            ; DF1C
        stx     $00                             ; DF1E
        jsr     LDF3E                           ; DF20
LDF23:  jsr     LE95B                           ; DF23
        lda     $00                             ; DF26
        and     #$07                            ; DF28
        beq     LDF30                           ; DF2A
        and     #$03                            ; DF2C
        bne     LDF39                           ; DF2E
LDF30:  jsr     LDF46                           ; DF30
        lda     $1C                             ; DF33
        ora     #$04                            ; DF35
        sta     $1C                             ; DF37
LDF39:  dec     $00                             ; DF39
        bne     LDF23                           ; DF3B
        rts                                     ; DF3D

; ----------------------------------------------------------------------------
LDF3E:  ldx     #$09                            ; DF3E
LDF40:  sta     $04,x                           ; DF40
        dex                                     ; DF42
        bpl     LDF40                           ; DF43
        rts                                     ; DF45

; ----------------------------------------------------------------------------
LDF46:  ldx     $01                             ; DF46
        stx     $02                             ; DF48
        lda     #$00                            ; DF4A
        sta     $03                             ; DF4C
LDF4E:  ldy     LDF72,x                         ; DF4E
        bpl     LDF54                           ; DF51
        rts                                     ; DF53

; ----------------------------------------------------------------------------
LDF54:  ldx     $03                             ; DF54
LDF56:  lda     $04A0,y                         ; DF56
        pha                                     ; DF59
        lda     $04,x                           ; DF5A
        sta     $04A0,y                         ; DF5C
        pla                                     ; DF5F
        sta     $04,x                           ; DF60
        inx                                     ; DF62
        iny                                     ; DF63
        tya                                     ; DF64
        and     #$03                            ; DF65
        bne     LDF56                           ; DF67
        stx     $03                             ; DF69
        inc     $02                             ; DF6B
        ldx     $02                             ; DF6D
        bpl     LDF4E                           ; DF6F
        rts                                     ; DF71

; ----------------------------------------------------------------------------
LDF72:  ora     ($15),y                         ; DF72
        .byte   $FF                             ; DF74
        ora     #$0D                            ; DF75
        .byte   $1D                             ; DF77
        .byte   $FF                             ; DF78
LDF79:  inc     $ED                             ; DF79
        lda     $ED                             ; DF7B
        sec                                     ; DF7D
        and     #$0F                            ; DF7E
        beq     LDF87                           ; DF80
        and     #$07                            ; DF82
        bne     LDF8C                           ; DF84
        clc                                     ; DF86
LDF87:  ldx     #$00                            ; DF87
        jsr     LDC4A                           ; DF89
LDF8C:  ldy     $0403                           ; DF8C
        lda     $C2                             ; DF8F
        lsr     a                               ; DF91
        bcc     LDF98                           ; DF92
        lda     #$01                            ; DF94
        bne     LDFEB                           ; DF96
LDF98:  lsr     a                               ; DF98
        bcc     LDF9F                           ; DF99
        lda     #$FE                            ; DF9B
        bne     LDFEB                           ; DF9D
LDF9F:  lsr     a                               ; DF9F
        lsr     a                               ; DFA0
        lsr     a                               ; DFA1
        bcc     LDFB1                           ; DFA2
LDFA4:  lda     $0417,y                         ; DFA4
        beq     LDFFE                           ; DFA7
        bmi     LDFAE                           ; DFA9
        dey                                     ; DFAB
        bpl     LDFA4                           ; DFAC
LDFAE:  dey                                     ; DFAE
        bpl     LDFE9                           ; DFAF
LDFB1:  lsr     a                               ; DFB1
        bcc     LDFC1                           ; DFB2
LDFB4:  lda     $0419,y                         ; DFB4
        beq     LDFFE                           ; DFB7
        bmi     LDFBE                           ; DFB9
        iny                                     ; DFBB
        bpl     LDFB4                           ; DFBC
LDFBE:  iny                                     ; DFBE
        bpl     LDFE9                           ; DFBF
LDFC1:  lsr     a                               ; DFC1
        bcc     LDFD5                           ; DFC2
        lda     #$00                            ; DFC4
        cpy     #$05                            ; DFC6
        bcc     LDFFE                           ; DFC8
        tya                                     ; DFCA
        sbc     #$05                            ; DFCB
        tax                                     ; DFCD
        lda     $0418,x                         ; DFCE
        beq     LDFFE                           ; DFD1
        bne     LDFE7                           ; DFD3
LDFD5:  lsr     a                               ; DFD5
        bcc     LDFFE                           ; DFD6
        lda     #$00                            ; DFD8
        cpy     #$05                            ; DFDA
        bcs     LDFFE                           ; DFDC
LDFDE:  tya                                     ; DFDE
        adc     #$05                            ; DFDF
        tax                                     ; DFE1
        lda     $0418,x                         ; DFE2
        beq     LDFFE                           ; DFE5
LDFE7:  txa                                     ; DFE7
        tay                                     ; DFE8
LDFE9:  lda     #$00                            ; DFE9
LDFEB:  pha                                     ; DFEB
        sty     $3C                             ; DFEC
        clc                                     ; DFEE
        ldx     #$00                            ; DFEF
        jsr     LDC4A                           ; DFF1
        lda     $3C                             ; DFF4
        sta     $0403                           ; DFF6
        sec                                     ; DFF9
        jsr     LDC4A                           ; DFFA
        pla                                     ; DFFD
LDFFE:  rts                                     ; DFFE

; ----------------------------------------------------------------------------
        .byte   $FF                             ; DFFF
