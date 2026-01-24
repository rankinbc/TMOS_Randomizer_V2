; ============================================================================
; The Magic of Scheherazade - Bank 08 Disassembly
; ============================================================================
; File Offset: 0x10000 - 0x11FFF
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
; Input file: C:/claude-workspace/TMOS_AI/rom-files/disassembly/output/banks/bank_08.bin
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
L0B0B           := $0B0B
L1020           := $1020
L1107           := $1107
L1110           := $1110
L1319           := $1319
L1606           := $1606
L160F           := $160F
L1610           := $1610
L161A           := $161A
L1701           := $1701
L1708           := $1708
L170F           := $170F
L1738           := $1738
L1909           := $1909
PPU_CTRL        := $2000
PPU_MASK        := $2001
PPU_STATUS      := $2002
OAM_ADDR        := $2003
OAM_DATA        := $2004
PPU_SCROLL      := $2005
PPU_ADDR        := $2006
PPU_DATA        := $2007
L2122           := $2122
L2611           := $2611
L2701           := $2701
L2706           := $2706
L270A           := $270A
L2711           := $2711
L2716           := $2716
L2721           := $2721
L2A0B           := $2A0B
L2A16           := $2A16
L3616           := $3616
OAM_DMA         := $4014
APU_STATUS      := $4015
JOY1            := $4016
JOY2_FRAME      := $4017
L4848           := $4848
L686D           := $686D
L6CAA           := $6CAA
L7979           := $7979
L7F8B           := $7F8B
LE0A4           := $E0A4
LE0BD           := $E0BD
LE0C1           := $E0C1
LE0D3           := $E0D3
LE106           := $E106
LE110           := $E110
LE5AA           := $E5AA
LE8D1           := $E8D1
LE8E7           := $E8E7
LE8EF           := $E8EF
LE95B           := $E95B
LE97D           := $E97D
LE992           := $E992
LEA7E           := $EA7E
LEA88           := $EA88
LEAAA           := $EAAA
LEC7E           := $EC7E
LEE93           := $EE93
LEEB3           := $EEB3
LF067           := $F067
LF09B           := $F09B
LF0B2           := $F0B2
LF0BE           := $F0BE
LF0CF           := $F0CF
LF11C           := $F11C
LF2DA           := $F2DA
LF6DE           := $F6DE
LF765           := $F765
LF785           := $F785
LF79E           := $F79E
LF83C           := $F83C
LF84D           := $F84D
; ----------------------------------------------------------------------------
        bmi     L7F8B                           ; 8000
        ror     $A789                           ; 8002
        .byte   $89                             ; 8005
        clv                                     ; 8006
        txa                                     ; 8007
        .byte   $FA                             ; 8008
        txa                                     ; 8009
        .byte   $80                             ; 800A
        .byte   $8B                             ; 800B
        stx     $8B                             ; 800C
        inc     $378F                           ; 800E
        sta     L8B19                           ; 8011
        .byte   $E3                             ; 8014
        .byte   $8B                             ; 8015
        rol     $3B81                           ; 8016
        sta     ($D2,x)                         ; 8019
        sta     ($5A,x)                         ; 801B
        .byte   $82                             ; 801D
        .byte   $6B                             ; 801E
        .byte   $82                             ; 801F
        .byte   $82                             ; 8020
        .byte   $82                             ; 8021
        asl     a                               ; 8022
        .byte   $83                             ; 8023
        .byte   $54                             ; 8024
        .byte   $83                             ; 8025
        brk                                     ; 8026
        sta     $40                             ; 8027
        stx     $1B                             ; 8029
        sty     $D2                             ; 802B
        sty     L83DB                           ; 802D
        .byte   $47                             ; 8030
        .byte   $87                             ; 8031
        and     #$8E                            ; 8032
        sbc     ($8E),y                         ; 8034
        .byte   $7B                             ; 8036
        sta     ($4A),y                         ; 8037
        .byte   $92                             ; 8039
        sbc     $92,x                           ; 803A
        .byte   $6F                             ; 803C
        .byte   $92                             ; 803D
        dey                                     ; 803E
        .byte   $92                             ; 803F
        .byte   $34                             ; 8040
        lda     $BD3B,x                         ; 8041
        eor     ($BD,x)                         ; 8044
        eor     #$BD                            ; 8046
        lsr     $54BD                           ; 8048
        lda     $BD5B,x                         ; 804B
        .byte   $5F                             ; 804E
        lda     $BD64,x                         ; 804F
        ror     a                               ; 8052
        lda     $BD6F,x                         ; 8053
        adc     $BD,x                           ; 8056
        sei                                     ; 8058
        lda     $BD7B,x                         ; 8059
        .byte   $83                             ; 805C
        lda     $BD8B,x                         ; 805D
        sta     L90BD                           ; 8060
        lda     $BD94,x                         ; 8063
        .byte   $97                             ; 8066
        lda     $BD9C,x                         ; 8067
        .byte   $A3                             ; 806A
        lda     $BDAA,x                         ; 806B
        ldx     $B3BD                           ; 806E
        lda     $BDB9,x                         ; 8071
        ldy     $BEBD,x                         ; 8074
        lda     $BDC4,x                         ; 8077
        cmp     #$BD                            ; 807A
        .byte   $CF                             ; 807C
        lda     $BDD5,x                         ; 807D
        cld                                     ; 8080
        lda     $BDDB,x                         ; 8081
        .byte   $DF                             ; 8084
        lda     $BDE5,x                         ; 8085
        sbc     #$BD                            ; 8088
        sbc     $F2BD                           ; 808A
        lda     $BDF4,x                         ; 808D
        sbc     $FEBD,y                         ; 8090
        lda     $BE06,x                         ; 8093
        asl     a                               ; 8096
        ldx     $BE0E,y                         ; 8097
        .byte   $12                             ; 809A
        ldx     $BE15,y                         ; 809B
        clc                                     ; 809E
        ldx     $BE1C,y                         ; 809F
        asl     $20BE,x                         ; 80A2
        ldx     $BE23,y                         ; 80A5
        and     $BE                             ; 80A8
        .byte   $27                             ; 80AA
        ldx     $BE2B,y                         ; 80AB
        .byte   $2F                             ; 80AE
        ldx     $BE33,y                         ; 80AF
        sec                                     ; 80B2
        ldx     $BE3C,y                         ; 80B3
        .byte   $3F                             ; 80B6
        ldx     $BE41,y                         ; 80B7
        .byte   $43                             ; 80BA
        ldx     $BE46,y                         ; 80BB
        lsr     a                               ; 80BE
        ldx     $BE50,y                         ; 80BF
        eor     $BE,x                           ; 80C2
        .byte   $5A                             ; 80C4
        ldx     $BE61,y                         ; 80C5
        adc     $BE                             ; 80C8
        adc     #$BE                            ; 80CA
        adc     $BE,x                           ; 80CC
        adc     L83BE,y                         ; 80CE
        ldx     $BE88,y                         ; 80D1
        .byte   $8B                             ; 80D4
        ldx     $BE8F,y                         ; 80D5
        .byte   $93                             ; 80D8
        ldx     $BE98,y                         ; 80D9
        .byte   $9C                             ; 80DC
        ldx     $BE9E,y                         ; 80DD
        tax                                     ; 80E0
        ldx     $BEAE,y                         ; 80E1
        .byte   $B3                             ; 80E4
        ldx     $BEB6,y                         ; 80E5
        .byte   $BB                             ; 80E8
        ldx     $BEBE,y                         ; 80E9
        .byte   $C2                             ; 80EC
L80ED:  ldx     $BEC9,y                         ; 80ED
        cmp     $D1BE                           ; 80F0
        ldx     $BED5,y                         ; 80F3
        cmp     $DCBE,y                         ; 80F6
        ldx     $BEE2,y                         ; 80F9
        cpx     $BE                             ; 80FC
        .byte   $E7                             ; 80FE
        ldx     $BEE9,y                         ; 80FF
        sbc     $F2BE                           ; 8102
        ldx     $BEF8,y                         ; 8105
        sbc     $01BE,x                         ; 8108
        .byte   $BF                             ; 810B
        .byte   $04                             ; 810C
        .byte   $BF                             ; 810D
        .byte   $07                             ; 810E
        .byte   $BF                             ; 810F
        ora     #$BF                            ; 8110
        .byte   $0C                             ; 8112
        .byte   $BF                             ; 8113
        ora     $BF,x                           ; 8114
        .byte   $1B                             ; 8116
        .byte   $BF                             ; 8117
        asl     $21BF,x                         ; 8118
        .byte   $BF                             ; 811B
        and     $BF                             ; 811C
        and     #$BF                            ; 811E
        and     ($BF),y                         ; 8120
        .byte   $37                             ; 8122
        .byte   $BF                             ; 8123
        .byte   $3C                             ; 8124
        .byte   $BF                             ; 8125
        eor     ($BF,x)                         ; 8126
        lsr     $BF                             ; 8128
        .byte   $4B                             ; 812A
        .byte   $BF                             ; 812B
        bvc     L80ED                           ; 812C
        ldy     $82                             ; 812E
        lda     L8136,y                         ; 8130
        sta     $AB                             ; 8133
        rts                                     ; 8135

; ----------------------------------------------------------------------------
L8136:  .byte   $63                             ; 8136
        ora     #$01                            ; 8137
        rol     $20                             ; 8139
        jsr     L819F                           ; 813B
        jsr     LE5AA                           ; 813E
        lda     #$00                            ; 8141
        sta     $60                             ; 8143
        jsr     LE95B                           ; 8145
        jsr     L841B                           ; 8148
        jsr     LE95B                           ; 814B
        jsr     L8500                           ; 814E
        jsr     LE95B                           ; 8151
        jsr     L8354                           ; 8154
        jsr     L83DB                           ; 8157
        lda     $95                             ; 815A
        cmp     #$03                            ; 815C
        bcs     L8170                           ; 815E
        jsr     L8282                           ; 8160
        jsr     L8640                           ; 8163
        jsr     L83F4                           ; 8166
        lda     $B1                             ; 8169
        bpl     L8170                           ; 816B
        jsr     L8BE3                           ; 816D
L8170:  jsr     LEA7E                           ; 8170
        asl     $0600                           ; 8173
        lsr     $0600                           ; 8176
        ldx     #$00                            ; 8179
        jsr     LE0D3                           ; 817B
        jsr     L8AB8                           ; 817E
        jsr     LE95B                           ; 8181
        lda     #$00                            ; 8184
        sta     $03A0                           ; 8186
        sta     $03A1                           ; 8189
        bit     $BF                             ; 818C
        bvs     L8198                           ; 818E
        lda     $B2                             ; 8190
        and     #$E0                            ; 8192
        cmp     #$20                            ; 8194
        beq     L819E                           ; 8196
L8198:  jsr     LF09B                           ; 8198
        jsr     L830A                           ; 819B
L819E:  rts                                     ; 819E

; ----------------------------------------------------------------------------
L819F:  lda     $B0                             ; 819F
        pha                                     ; 81A1
        jsr     L82A1                           ; 81A2
        pla                                     ; 81A5
        eor     $B0                             ; 81A6
        and     #$F0                            ; 81A8
        beq     L81D1                           ; 81AA
        lda     $11                             ; 81AC
        and     #$18                            ; 81AE
        beq     L81D1                           ; 81B0
        lda     $0601                           ; 81B2
        pha                                     ; 81B5
        lda     #$00                            ; 81B6
        sta     $0601                           ; 81B8
        lda     #$61                            ; 81BB
        jsr     LE992                           ; 81BD
        lda     $B1                             ; 81C0
        pha                                     ; 81C2
        lda     #$00                            ; 81C3
        sta     $B1                             ; 81C5
        jsr     L924A                           ; 81C7
        pla                                     ; 81CA
        sta     $B1                             ; 81CB
        pla                                     ; 81CD
        sta     $0601                           ; 81CE
L81D1:  rts                                     ; 81D1

; ----------------------------------------------------------------------------
        stx     $3D                             ; 81D2
        tax                                     ; 81D4
        and     #$0F                            ; 81D5
        sta     $05                             ; 81D7
        txa                                     ; 81D9
        lsr     a                               ; 81DA
        lsr     a                               ; 81DB
        lsr     a                               ; 81DC
        lsr     a                               ; 81DD
        sta     $06                             ; 81DE
        tya                                     ; 81E0
        sta     $0500,x                         ; 81E1
        jsr     L859F                           ; 81E4
        lda     #$00                            ; 81E7
        sta     $03                             ; 81E9
        lda     $06                             ; 81EB
        ora     #$80                            ; 81ED
        lsr     a                               ; 81EF
        ror     $03                             ; 81F0
        lsr     a                               ; 81F2
        ror     $03                             ; 81F3
        sta     $04                             ; 81F5
        lda     $05                             ; 81F7
        asl     a                               ; 81F9
        adc     $03                             ; 81FA
        sta     $03                             ; 81FC
        lda     $04                             ; 81FE
        adc     #$00                            ; 8200
        sta     $04                             ; 8202
        ldy     #$00                            ; 8204
        ldx     $0162                           ; 8206
L8209:  lda     $04                             ; 8209
        sta     $0163,x                         ; 820B
        inx                                     ; 820E
        lda     $03                             ; 820F
        sta     $0163,x                         ; 8211
        inx                                     ; 8214
        ora     #$20                            ; 8215
        sta     $03                             ; 8217
        lda     #$02                            ; 8219
        sta     $0163,x                         ; 821B
        inx                                     ; 821E
        lda     ($07),y                         ; 821F
        sta     $0163,x                         ; 8221
        inx                                     ; 8224
        iny                                     ; 8225
        lda     ($07),y                         ; 8226
        sta     $0163,x                         ; 8228
        inx                                     ; 822B
        iny                                     ; 822C
        cpy     #$04                            ; 822D
        bne     L8209                           ; 822F
        jsr     L85BB                           ; 8231
        sta     $01                             ; 8234
        lda     #$23                            ; 8236
        sta     $0163,x                         ; 8238
        inx                                     ; 823B
        tya                                     ; 823C
        ora     #$C0                            ; 823D
        sta     $0163,x                         ; 823F
        inx                                     ; 8242
        lda     #$01                            ; 8243
        sta     $0163,x                         ; 8245
        inx                                     ; 8248
        lda     $01                             ; 8249
        sta     $0163,x                         ; 824B
        inx                                     ; 824E
        lda     #$00                            ; 824F
        sta     $0163,x                         ; 8251
        stx     $0162                           ; 8254
        ldx     $3D                             ; 8257
        rts                                     ; 8259

; ----------------------------------------------------------------------------
L825A:  sty     $3C                             ; 825A
        tay                                     ; 825C
        lda     $0500,y                         ; 825D
        tay                                     ; 8260
        lda     L99FB,y                         ; 8261
        ldy     $3C                             ; 8264
        lsr     a                               ; 8266
        lsr     a                               ; 8267
        lsr     a                               ; 8268
        lsr     a                               ; 8269
        rts                                     ; 826A

; ----------------------------------------------------------------------------
L826B:  sta     $0605,x                         ; 826B
        and     #$F0                            ; 826E
        ora     #$08                            ; 8270
        sta     $0602,x                         ; 8272
        lda     $0605,x                         ; 8275
        asl     a                               ; 8278
        asl     a                               ; 8279
        asl     a                               ; 827A
        asl     a                               ; 827B
        ora     #$08                            ; 827C
        sta     $0603,x                         ; 827E
        rts                                     ; 8281

; ----------------------------------------------------------------------------
L8282:  stx     $3D                             ; 8282
        ldx     #$14                            ; 8284
        lda     #$F4                            ; 8286
L8288:  sta     $0200,x                         ; 8288
        inx                                     ; 828B
        bne     L8288                           ; 828C
        ldx     #$10                            ; 828E
L8290:  lda     #$00                            ; 8290
        sta     $0601,x                         ; 8292
        clc                                     ; 8295
        txa                                     ; 8296
        adc     #$08                            ; 8297
        tax                                     ; 8299
        bne     L8290                           ; 829A
        sta     $71                             ; 829C
        ldx     $3D                             ; 829E
        rts                                     ; 82A0

; ----------------------------------------------------------------------------
L82A1:  lda     #$18                            ; 82A1
        ldy     $82                             ; 82A3
        jsr     LEE93                           ; 82A5
        lda     #$B0                            ; 82A8
        sta     $E8                             ; 82AA
        lda     #$00                            ; 82AC
        sta     $E9                             ; 82AE
        lda     #$10                            ; 82B0
        sta     $EA                             ; 82B2
        lda     #$00                            ; 82B4
        sta     $EC                             ; 82B6
        lda     $AB                             ; 82B8
        asl     a                               ; 82BA
        rol     $EC                             ; 82BB
        asl     a                               ; 82BD
        rol     $EC                             ; 82BE
        asl     a                               ; 82C0
        rol     $EC                             ; 82C1
        asl     a                               ; 82C3
        rol     $EC                             ; 82C4
        adc     $ED                             ; 82C6
        sta     $EB                             ; 82C8
        lda     $EC                             ; 82CA
        adc     $EE                             ; 82CC
        sta     $EC                             ; 82CE
        lsr     a                               ; 82D0
        lsr     a                               ; 82D1
        lsr     a                               ; 82D2
        lsr     a                               ; 82D3
        clc                                     ; 82D4
        adc     #$17                            ; 82D5
        sta     $ED                             ; 82D7
        lda     $EC                             ; 82D9
        and     #$0F                            ; 82DB
        sta     $EC                             ; 82DD
        jsr     LE8D1                           ; 82DF
        lda     $B1                             ; 82E2
        and     #$08                            ; 82E4
        beq     L82FD                           ; 82E6
        lda     $B1                             ; 82E8
        lsr     a                               ; 82EA
        lsr     a                               ; 82EB
        lsr     a                               ; 82EC
        lsr     a                               ; 82ED
        and     #$07                            ; 82EE
        tay                                     ; 82F0
        iny                                     ; 82F1
        sec                                     ; 82F2
        lda     #$00                            ; 82F3
L82F5:  rol     a                               ; 82F5
        dey                                     ; 82F6
        bne     L82F5                           ; 82F7
        ora     $87                             ; 82F9
        sta     $87                             ; 82FB
L82FD:  lda     $B2                             ; 82FD
        cmp     #$FF                            ; 82FF
        bne     L8309                           ; 8301
        lda     $BF                             ; 8303
        ora     #$40                            ; 8305
        sta     $BF                             ; 8307
L8309:  rts                                     ; 8309

; ----------------------------------------------------------------------------
L830A:  lda     $BF                             ; 830A
        and     #$18                            ; 830C
        bne     L8341                           ; 830E
        bit     $BF                             ; 8310
        bvs     L8328                           ; 8312
        lda     $B2                             ; 8314
        and     #$E0                            ; 8316
        bne     L8324                           ; 8318
        lda     $B2                             ; 831A
        and     #$1F                            ; 831C
        beq     L8328                           ; 831E
        lda     #$2A                            ; 8320
        bne     L8351                           ; 8322
L8324:  cmp     #$20                            ; 8324
        beq     L8341                           ; 8326
L8328:  lda     $71                             ; 8328
        beq     L8330                           ; 832A
        lda     #$4E                            ; 832C
        bne     L8351                           ; 832E
L8330:  lda     $03F7                           ; 8330
        beq     L8341                           ; 8333
        lda     $B0                             ; 8335
        and     #$F0                            ; 8337
        cmp     #$E0                            ; 8339
        bcc     L8341                           ; 833B
        .byte   $A9                             ; 833D
L833E:  eor     $10D0                           ; 833E
L8341:  lda     #$49                            ; 8341
        ldy     $AC                             ; 8343
        bne     L8351                           ; 8345
        lda     $B0                             ; 8347
        lsr     a                               ; 8349
        lsr     a                               ; 834A
        lsr     a                               ; 834B
        lsr     a                               ; 834C
        tay                                     ; 834D
        lda     L93D3,y                         ; 834E
L8351:  jmp     LF765                           ; 8351

; ----------------------------------------------------------------------------
L8354:  ldy     #$00                            ; 8354
        clc                                     ; 8356
        lda     $03F8                           ; 8357
        beq     L8362                           ; 835A
        lda     $B0                             ; 835C
        and     #$F0                            ; 835E
        cmp     #$E0                            ; 8360
L8362:  lda     $BC                             ; 8362
        bcc     L8368                           ; 8364
        adc     #$00                            ; 8366
L8368:  jsr     L8399                           ; 8368
        ldy     #$10                            ; 836B
        lda     $BD                             ; 836D
        jsr     L8399                           ; 836F
        lda     #$0F                            ; 8372
        sta     $04B0                           ; 8374
        sta     $04BA                           ; 8377
        jsr     LEC7E                           ; 837A
        lda     $19                             ; 837D
        bne     L8398                           ; 837F
        lda     $03FC                           ; 8381
        beq     L8398                           ; 8384
        ldy     #$0B                            ; 8386
L8388:  lda     $04A4,y                         ; 8388
        sec                                     ; 838B
        sbc     #$10                            ; 838C
        bcs     L8392                           ; 838E
        lda     #$0F                            ; 8390
L8392:  sta     $04A4,y                         ; 8392
        dey                                     ; 8395
        bpl     L8388                           ; 8396
L8398:  rts                                     ; 8398

; ----------------------------------------------------------------------------
L8399:  stx     $3D                             ; 8399
        ldx     #$00                            ; 839B
        stx     $3F                             ; 839D
        asl     a                               ; 839F
        rol     $3F                             ; 83A0
        asl     a                               ; 83A2
        rol     $3F                             ; 83A3
        adc     #$F3                            ; 83A5
        sta     $3E                             ; 83A7
        lda     #$93                            ; 83A9
        adc     $3F                             ; 83AB
        sta     $3F                             ; 83AD
        tya                                     ; 83AF
        tax                                     ; 83B0
        ldy     #$FF                            ; 83B1
L83B3:  iny                                     ; 83B3
        sty     $3C                             ; 83B4
        cpy     #$04                            ; 83B6
        bne     L83BD                           ; 83B8
        ldx     $3D                             ; 83BA
        rts                                     ; 83BC

; ----------------------------------------------------------------------------
L83BD:  .byte   $B1                             ; 83BD
L83BE:  rol     $A9A8,x                         ; 83BE
        .byte   $0F                             ; 83C1
        sta     $04A0,x                         ; 83C2
        inx                                     ; 83C5
        lda     #$03                            ; 83C6
        sta     $3B                             ; 83C8
L83CA:  lda     L951F,y                         ; 83CA
        sta     $04A0,x                         ; 83CD
        iny                                     ; 83D0
        inx                                     ; 83D1
        dec     $3B                             ; 83D2
        bne     L83CA                           ; 83D4
        ldy     $3C                             ; 83D6
        jmp     L83B3                           ; 83D8

; ----------------------------------------------------------------------------
L83DB:  stx     $3D                             ; 83DB
        lda     $B1                             ; 83DD
        and     #$03                            ; 83DF
        asl     a                               ; 83E1
        asl     a                               ; 83E2
        tay                                     ; 83E3
        ldx     #$00                            ; 83E4
L83E6:  lda     L93E3,y                         ; 83E6
        sta     $C7,x                           ; 83E9
        iny                                     ; 83EB
        inx                                     ; 83EC
        cpx     #$04                            ; 83ED
        bne     L83E6                           ; 83EF
        ldx     $3D                             ; 83F1
        rts                                     ; 83F3

; ----------------------------------------------------------------------------
L83F4:  stx     $3D                             ; 83F4
        lda     $BE                             ; 83F6
        and     #$0F                            ; 83F8
        cmp     #$04                            ; 83FA
        bcc     L8400                           ; 83FC
        lda     #$03                            ; 83FE
L8400:  asl     a                               ; 8400
        asl     a                               ; 8401
        tay                                     ; 8402
        ldx     #$00                            ; 8403
L8405:  lda     L95EB,y                         ; 8405
        sta     $A4,x                           ; 8408
        iny                                     ; 840A
        inx                                     ; 840B
        cpx     #$04                            ; 840C
        bne     L8405                           ; 840E
        lda     $03F3                           ; 8410
        bne     L8418                           ; 8413
        jsr     LF2DA                           ; 8415
L8418:  ldx     $3D                             ; 8418
        rts                                     ; 841A

; ----------------------------------------------------------------------------
L841B:  lda     #$00                            ; 841B
        sta     $03A0                           ; 841D
        sta     $03A1                           ; 8420
        lda     #$1A                            ; 8423
        ldy     #$00                            ; 8425
        jsr     LEE93                           ; 8427
        lda     $ED                             ; 842A
        sta     $A8                             ; 842C
        lda     $EE                             ; 842E
        sta     $A9                             ; 8430
        lda     $B8                             ; 8432
        and     #$3F                            ; 8434
        sta     $38                             ; 8436
        lda     #$00                            ; 8438
        sta     $00                             ; 843A
        sta     $AC                             ; 843C
        lda     $B8                             ; 843E
        asl     a                               ; 8440
        lda     $BA                             ; 8441
        jsr     L844C                           ; 8443
        lda     $B8                             ; 8446
        asl     a                               ; 8448
        asl     a                               ; 8449
        lda     $BB                             ; 844A
L844C:  pha                                     ; 844C
        ldy     #$00                            ; 844D
        sty     $EC                             ; 844F
        rol     $EC                             ; 8451
        asl     a                               ; 8453
        rol     $EC                             ; 8454
        asl     a                               ; 8456
        rol     $EC                             ; 8457
        asl     a                               ; 8459
        rol     $EC                             ; 845A
        asl     a                               ; 845C
        rol     $EC                             ; 845D
        asl     a                               ; 845F
        rol     $EC                             ; 8460
        adc     $A8                             ; 8462
        sta     $EB                             ; 8464
L8466:  lda     $EC                             ; 8466
        adc     $A9                             ; 8468
        sta     $EC                             ; 846A
L846C:  lsr     a                               ; 846C
        lsr     a                               ; 846D
        lsr     a                               ; 846E
        lsr     a                               ; 846F
        clc                                     ; 8470
        adc     #$17                            ; 8471
        sta     $ED                             ; 8473
        lda     $EC                             ; 8475
        and     #$0F                            ; 8477
        sta     $EC                             ; 8479
        lda     #$00                            ; 847B
        sta     $E8                             ; 847D
        lda     #$04                            ; 847F
        sta     $E9                             ; 8481
        lda     #$20                            ; 8483
        sta     $EA                             ; 8485
        jsr     LE8D1                           ; 8487
        pla                                     ; 848A
        cmp     #$FF                            ; 848B
        bne     L84A1                           ; 848D
        lda     $88                             ; 848F
        beq     L84A1                           ; 8491
        lda     #$4D                            ; 8493
        sta     $0404                           ; 8495
        sta     $040C                           ; 8498
        sta     $0414                           ; 849B
        sta     $041C                           ; 849E
L84A1:  ldy     #$00                            ; 84A1
        sty     $01                             ; 84A3
L84A5:  lda     #$00                            ; 84A5
        sta     $05                             ; 84A7
        lda     $0400,y                         ; 84A9
        cmp     #$4D                            ; 84AC
        bne     L84B2                           ; 84AE
        sta     $AC                             ; 84B0
L84B2:  asl     a                               ; 84B2
        rol     $05                             ; 84B3
        asl     a                               ; 84B5
        rol     $05                             ; 84B6
        adc     #$FB                            ; 84B8
        sta     $04                             ; 84BA
        lda     #$9A                            ; 84BC
        adc     $05                             ; 84BE
        sta     $05                             ; 84C0
        ldy     #$00                            ; 84C2
        ldx     $00                             ; 84C4
        jsr     L84FA                           ; 84C6
        iny                                     ; 84C9
        inx                                     ; 84CA
        jsr     L84FA                           ; 84CB
        lda     $00                             ; 84CE
        ora     #$10                            ; 84D0
        tax                                     ; 84D2
        iny                                     ; 84D3
        jsr     L84FA                           ; 84D4
        iny                                     ; 84D7
        inx                                     ; 84D8
        jsr     L84FA                           ; 84D9
        inc     $00                             ; 84DC
        inc     $00                             ; 84DE
        lda     $00                             ; 84E0
        and     #$10                            ; 84E2
        beq     L84F1                           ; 84E4
        clc                                     ; 84E6
        lda     $00                             ; 84E7
        adc     #$10                            ; 84E9
        sta     $00                             ; 84EB
        cmp     #$E0                            ; 84ED
        bcs     L84F9                           ; 84EF
L84F1:  inc     $01                             ; 84F1
        ldy     $01                             ; 84F3
        cpy     #$20                            ; 84F5
        bne     L84A5                           ; 84F7
L84F9:  rts                                     ; 84F9

; ----------------------------------------------------------------------------
L84FA:  lda     ($04),y                         ; 84FA
        sta     $0500,x                         ; 84FC
        rts                                     ; 84FF

; ----------------------------------------------------------------------------
L8500:  lda     #$00                            ; 8500
        sta     $03                             ; 8502
        sta     $05                             ; 8504
        sta     $06                             ; 8506
        lda     #$20                            ; 8508
        sta     $04                             ; 850A
L850C:  jsr     L8583                           ; 850C
        ldx     $0162                           ; 850F
L8512:  lda     $04                             ; 8512
        sta     $0163,x                         ; 8514
        inx                                     ; 8517
        lda     $03                             ; 8518
        sta     $0163,x                         ; 851A
        inx                                     ; 851D
        lda     #$20                            ; 851E
        sta     $0163,x                         ; 8520
        inx                                     ; 8523
L8524:  lda     $06                             ; 8524
        asl     a                               ; 8526
        asl     a                               ; 8527
        asl     a                               ; 8528
        asl     a                               ; 8529
        ora     $05                             ; 852A
        tay                                     ; 852C
        lda     $0500,y                         ; 852D
        cpy     #$C0                            ; 8530
        bcc     L8536                           ; 8532
        lda     #$49                            ; 8534
L8536:  jsr     L859F                           ; 8536
        ldy     #$00                            ; 8539
        lda     $03                             ; 853B
        and     #$20                            ; 853D
        beq     L8546                           ; 853F
        jsr     L85BB                           ; 8541
        ldy     #$02                            ; 8544
L8546:  lda     ($07),y                         ; 8546
        sta     $0163,x                         ; 8548
        inx                                     ; 854B
        iny                                     ; 854C
        lda     ($07),y                         ; 854D
        sta     $0163,x                         ; 854F
        inx                                     ; 8552
        inc     $05                             ; 8553
        lda     $05                             ; 8555
        cmp     #$10                            ; 8557
        bne     L8524                           ; 8559
        lda     #$00                            ; 855B
        sta     $05                             ; 855D
        clc                                     ; 855F
        lda     $03                             ; 8560
        adc     #$20                            ; 8562
        sta     $03                             ; 8564
        lda     $04                             ; 8566
        adc     #$00                            ; 8568
        sta     $04                             ; 856A
        lda     $03                             ; 856C
        and     #$20                            ; 856E
        bne     L8512                           ; 8570
        sta     $0163,x                         ; 8572
        stx     $0162                           ; 8575
        inc     $06                             ; 8578
        lda     $06                             ; 857A
        cmp     #$10                            ; 857C
        bne     L850C                           ; 857E
        jmp     L85F9                           ; 8580

; ----------------------------------------------------------------------------
L8583:  lda     $1C                             ; 8583
        and     #$0C                            ; 8585
        beq     L858F                           ; 8587
        jsr     LE95B                           ; 8589
        jmp     L8583                           ; 858C

; ----------------------------------------------------------------------------
L858F:  lda     $1C                             ; 858F
        and     #$FD                            ; 8591
        sta     $1C                             ; 8593
        jsr     LEEB3                           ; 8595
        lda     $1C                             ; 8598
        ora     #$02                            ; 859A
        sta     $1C                             ; 859C
        rts                                     ; 859E

; ----------------------------------------------------------------------------
L859F:  tay                                     ; 859F
        lda     L99FB,y                         ; 85A0
        sta     $00                             ; 85A3
        lda     #$00                            ; 85A5
        sta     $08                             ; 85A7
        tya                                     ; 85A9
        asl     a                               ; 85AA
        rol     $08                             ; 85AB
        asl     a                               ; 85AD
        rol     $08                             ; 85AE
        adc     #$FB                            ; 85B0
        sta     $07                             ; 85B2
        lda     #$95                            ; 85B4
        adc     $08                             ; 85B6
        sta     $08                             ; 85B8
        rts                                     ; 85BA

; ----------------------------------------------------------------------------
L85BB:  lda     #$03                            ; 85BB
        sta     $01                             ; 85BD
        and     $00                             ; 85BF
        sta     $00                             ; 85C1
        lda     $06                             ; 85C3
        lsr     a                               ; 85C5
        bcc     L85D4                           ; 85C6
        asl     $00                             ; 85C8
        asl     $00                             ; 85CA
        asl     $00                             ; 85CC
        asl     $00                             ; 85CE
        lda     #$30                            ; 85D0
        sta     $01                             ; 85D2
L85D4:  lda     $05                             ; 85D4
        lsr     a                               ; 85D6
        bcc     L85E1                           ; 85D7
        asl     $00                             ; 85D9
        asl     $00                             ; 85DB
        asl     $01                             ; 85DD
        asl     $01                             ; 85DF
L85E1:  lda     $06                             ; 85E1
        lsr     a                               ; 85E3
        asl     a                               ; 85E4
        asl     a                               ; 85E5
        asl     a                               ; 85E6
        asl     a                               ; 85E7
        ora     $05                             ; 85E8
        lsr     a                               ; 85EA
        tay                                     ; 85EB
        lda     $01                             ; 85EC
        eor     #$FF                            ; 85EE
        and     $04C0,y                         ; 85F0
        ora     $00                             ; 85F3
        sta     $04C0,y                         ; 85F5
        rts                                     ; 85F8

; ----------------------------------------------------------------------------
L85F9:  jsr     L8583                           ; 85F9
        ldx     $0162                           ; 85FC
        ldy     #$00                            ; 85FF
        lda     #$23                            ; 8601
        sta     $0163,x                         ; 8603
        inx                                     ; 8606
        lda     #$C0                            ; 8607
        sta     $0163,x                         ; 8609
        inx                                     ; 860C
        lda     #$00                            ; 860D
        sta     $0163,x                         ; 860F
        inx                                     ; 8612
L8613:  lda     $04C0,y                         ; 8613
        bit     $BF                             ; 8616
        bpl     L861C                           ; 8618
        lda     #$FF                            ; 861A
L861C:  sta     $0163,x                         ; 861C
        inx                                     ; 861F
        iny                                     ; 8620
        cpy     #$40                            ; 8621
        bne     L8613                           ; 8623
        lda     #$00                            ; 8625
        sta     $0163,x                         ; 8627
        jsr     L8583                           ; 862A
        lda     $1C                             ; 862D
        and     #$FD                            ; 862F
        sta     $1C                             ; 8631
        lda     $031C                           ; 8633
        ora     #$10                            ; 8636
        sta     $031C                           ; 8638
        lda     #$00                            ; 863B
        sta     $64                             ; 863D
        rts                                     ; 863F

; ----------------------------------------------------------------------------
L8640:  bit     $BF                             ; 8640
        bvs     L8652                           ; 8642
        lda     $B2                             ; 8644
        beq     L8652                           ; 8646
        cmp     #$30                            ; 8648
        bcs     L8652                           ; 864A
        lda     #$C0                            ; 864C
        sta     $77                             ; 864E
        bne     L8655                           ; 8650
L8652:  jsr     L8848                           ; 8652
L8655:  ldy     #$00                            ; 8655
        sty     $93                             ; 8657
        sty     $71                             ; 8659
        sty     $EC                             ; 865B
        lda     #$00                            ; 865D
        ldy     #$10                            ; 865F
L8661:  sta     $05EF,y                         ; 8661
        dey                                     ; 8664
        bne     L8661                           ; 8665
        lda     $82                             ; 8667
        asl     a                               ; 8669
        adc     #$0E                            ; 866A
        ldy     $B3                             ; 866C
        jsr     LEE93                           ; 866E
        lda     $ED                             ; 8671
        sta     $EB                             ; 8673
        lda     $EE                             ; 8675
        sta     $EC                             ; 8677
        ldy     #$00                            ; 8679
        lda     #$30                            ; 867B
        sta     $EA                             ; 867D
        jsr     L8738                           ; 867F
        lda     #$00                            ; 8682
        sta     $31                             ; 8684
L8686:  lda     $0400,y                         ; 8686
        bne     L868E                           ; 8689
        jmp     L871C                           ; 868B

; ----------------------------------------------------------------------------
L868E:  cmp     #$F0                            ; 868E
        bcc     L86A3                           ; 8690
        and     #$0F                            ; 8692
        tax                                     ; 8694
        iny                                     ; 8695
        lda     $0400,y                         ; 8696
        clc                                     ; 8699
        adc     #$20                            ; 869A
        sta     $05F0,x                         ; 869C
        iny                                     ; 869F
        jmp     L8686                           ; 86A0

; ----------------------------------------------------------------------------
L86A3:  sty     $3C                             ; 86A3
        lda     $0400,y                         ; 86A5
        cmp     #$06                            ; 86A8
        bne     L86D2                           ; 86AA
        lda     $0401,y                         ; 86AC
        and     #$0F                            ; 86AF
        cmp     #$01                            ; 86B1
        bne     L86CF                           ; 86B3
        lda     $0336                           ; 86B5
        beq     L86F0                           ; 86B8
        lda     $03C2                           ; 86BA
        beq     L86F0                           ; 86BD
        lda     $82                             ; 86BF
        cmp     #$02                            ; 86C1
        bne     L86CF                           ; 86C3
        lda     $0338                           ; 86C5
        beq     L86F0                           ; 86C8
        lda     $03C6                           ; 86CA
        beq     L86F0                           ; 86CD
L86CF:  lda     $0400,y                         ; 86CF
L86D2:  cmp     #$10                            ; 86D2
        bcc     L86F5                           ; 86D4
        cmp     #$16                            ; 86D6
        bcc     L86DE                           ; 86D8
        cmp     #$19                            ; 86DA
        bcc     L86F5                           ; 86DC
L86DE:  bit     $77                             ; 86DE
        bmi     L86EE                           ; 86E0
        lda     $03F7                           ; 86E2
        cmp     #$01                            ; 86E5
        beq     L86F0                           ; 86E7
        jsr     L87B6                           ; 86E9
        bit     $77                             ; 86EC
L86EE:  bvs     L86F5                           ; 86EE
L86F0:  iny                                     ; 86F0
        iny                                     ; 86F1
        iny                                     ; 86F2
        bne     L8686                           ; 86F3
L86F5:  jsr     LF11C                           ; 86F5
        bne     L871C                           ; 86F8
        tya                                     ; 86FA
        tax                                     ; 86FB
        ldy     $3C                             ; 86FC
        lda     $0400,y                         ; 86FE
        sta     $0600,x                         ; 8701
        iny                                     ; 8704
        lda     $0400,y                         ; 8705
        sta     $0601,x                         ; 8708
        iny                                     ; 870B
        lda     $0400,y                         ; 870C
        iny                                     ; 870F
        jsr     L826B                           ; 8710
        jsr     L8930                           ; 8713
        jsr     LE0BD                           ; 8716
        jmp     L8686                           ; 8719

; ----------------------------------------------------------------------------
L871C:  lda     $031B                           ; 871C
        beq     L8730                           ; 871F
        bit     $BF                             ; 8721
        bvs     L872D                           ; 8723
        lda     $B2                             ; 8725
        and     #$E0                            ; 8727
        cmp     #$20                            ; 8729
        beq     L8730                           ; 872B
L872D:  jsr     LE0C1                           ; 872D
L8730:  lda     $77                             ; 8730
        beq     L8737                           ; 8732
        jsr     L87FF                           ; 8734
L8737:  rts                                     ; 8737

; ----------------------------------------------------------------------------
L8738:  lda     #$17                            ; 8738
        sta     $ED                             ; 873A
        lda     #$00                            ; 873C
        sta     $E8                             ; 873E
        lda     #$04                            ; 8740
        sta     $E9                             ; 8742
        jmp     LE8D1                           ; 8744

; ----------------------------------------------------------------------------
        sta     $0317                           ; 8747
        lda     $0319                           ; 874A
        beq     L8753                           ; 874D
        lda     #$0B                            ; 874F
        bne     L8792                           ; 8751
L8753:  lda     $05                             ; 8753
        jsr     L825A                           ; 8755
        bne     L8792                           ; 8758
        lda     $0601                           ; 875A
        and     #$C0                            ; 875D
        bne     L877F                           ; 875F
        lda     $05                             ; 8761
        and     #$F0                            ; 8763
        sta     $3B                             ; 8765
        lda     $0603                           ; 8767
        and     #$0F                            ; 876A
        cmp     #$08                            ; 876C
        lda     #$F9                            ; 876E
        bcc     L8774                           ; 8770
        lda     #$07                            ; 8772
L8774:  clc                                     ; 8774
        adc     $0603                           ; 8775
        lsr     a                               ; 8778
        lsr     a                               ; 8779
        lsr     a                               ; 877A
        lsr     a                               ; 877B
        jmp     L878D                           ; 877C

; ----------------------------------------------------------------------------
L877F:  lda     $05                             ; 877F
        and     #$0F                            ; 8781
        sta     $3B                             ; 8783
        lda     $0602                           ; 8785
        clc                                     ; 8788
        adc     #$07                            ; 8789
        and     #$F0                            ; 878B
L878D:  ora     $3B                             ; 878D
        jsr     L825A                           ; 878F
L8792:  pha                                     ; 8792
        cmp     #$0B                            ; 8793
        bne     L87B4                           ; 8795
        lda     $0601                           ; 8797
        and     #$C0                            ; 879A
        bne     L87AA                           ; 879C
        lda     $0602                           ; 879E
        and     #$F0                            ; 87A1
        ora     #$08                            ; 87A3
        sta     $0602                           ; 87A5
        bne     L87B4                           ; 87A8
L87AA:  lda     $0603                           ; 87AA
        and     #$F0                            ; 87AD
        ora     #$08                            ; 87AF
        sta     $0603                           ; 87B1
L87B4:  pla                                     ; 87B4
        rts                                     ; 87B5

; ----------------------------------------------------------------------------
L87B6:  sty     $3C                             ; 87B6
        lda     $03DD                           ; 87B8
        bne     L87C8                           ; 87BB
        lda     $E4                             ; 87BD
        and     #$07                            ; 87BF
        sta     $76                             ; 87C1
        lda     #$1E                            ; 87C3
        sta     $03DD                           ; 87C5
L87C8:  ldy     $74                             ; 87C8
        lda     L891B,y                         ; 87CA
        clc                                     ; 87CD
        adc     $75                             ; 87CE
        cmp     #$38                            ; 87D0
        bcc     L87DB                           ; 87D2
        asl     a                               ; 87D4
        lda     #$00                            ; 87D5
        bcs     L87DB                           ; 87D7
        lda     #$30                            ; 87D9
L87DB:  clc                                     ; 87DB
        adc     $76                             ; 87DC
        tay                                     ; 87DE
        lda     L88E3,y                         ; 87DF
        clc                                     ; 87E2
        adc     $79                             ; 87E3
        bcc     L87E9                           ; 87E5
        lda     #$FF                            ; 87E7
L87E9:  sec                                     ; 87E9
        sbc     $7B                             ; 87EA
        bcs     L87F0                           ; 87EC
        lda     #$00                            ; 87EE
L87F0:  ldy     #$80                            ; 87F0
        cmp     $E5                             ; 87F2
        beq     L87FA                           ; 87F4
        bcc     L87FA                           ; 87F6
        ldy     #$C0                            ; 87F8
L87FA:  sty     $77                             ; 87FA
        ldy     $3C                             ; 87FC
        rts                                     ; 87FE

; ----------------------------------------------------------------------------
L87FF:  bit     $77                             ; 87FF
        bvs     L882B                           ; 8801
        inc     $78                             ; 8803
        lda     $78                             ; 8805
        ldy     #$FF                            ; 8807
        cmp     #$04                            ; 8809
        bcs     L881B                           ; 880B
        ldy     #$66                            ; 880D
        cmp     #$03                            ; 880F
        bcs     L881B                           ; 8811
        ldy     #$4D                            ; 8813
        cmp     #$02                            ; 8815
        bcs     L881B                           ; 8817
        ldy     #$00                            ; 8819
L881B:  sty     $79                             ; 881B
        lda     $BE                             ; 881D
        and     #$CF                            ; 881F
        sta     $BE                             ; 8821
        lda     #$00                            ; 8823
        sta     $7A                             ; 8825
        sta     $7B                             ; 8827
        beq     L8845                           ; 8829
L882B:  inc     $7A                             ; 882B
        lda     $7A                             ; 882D
        ldy     #$FF                            ; 882F
        cmp     #$03                            ; 8831
        bcs     L883D                           ; 8833
        ldy     #$33                            ; 8835
        cmp     #$02                            ; 8837
        bcs     L883D                           ; 8839
        ldy     #$00                            ; 883B
L883D:  sty     $7B                             ; 883D
        lda     #$00                            ; 883F
        sta     $78                             ; 8841
        sta     $79                             ; 8843
L8845:  sta     $77                             ; 8845
        rts                                     ; 8847

; ----------------------------------------------------------------------------
L8848:  lda     $72                             ; 8848
        jsr     LE97D                           ; 884A
        .byte   $5B                             ; 884D
        dey                                     ; 884E
        .byte   $6B                             ; 884F
        dey                                     ; 8850
        sei                                     ; 8851
        dey                                     ; 8852
        tya                                     ; 8853
        dey                                     ; 8854
        lda     ($88,x)                         ; 8855
        .byte   $B7                             ; 8857
        dey                                     ; 8858
        iny                                     ; 8859
        dey                                     ; 885A
L885B:  ldx     #$09                            ; 885B
        lda     #$00                            ; 885D
L885F:  sta     $74,x                           ; 885F
        dex                                     ; 8861
        bpl     L885F                           ; 8862
        lda     #$04                            ; 8864
L8866:  sta     $73                             ; 8866
        inc     $72                             ; 8868
L886A:  rts                                     ; 886A

; ----------------------------------------------------------------------------
        jsr     L88D1                           ; 886B
        bcc     L886A                           ; 886E
        lda     #$02                            ; 8870
        sta     $74                             ; 8872
        lda     #$14                            ; 8874
        bne     L8866                           ; 8876
        jsr     L88D1                           ; 8878
        bcc     L888B                           ; 887B
L887D:  ldy     $74                             ; 887D
        iny                                     ; 887F
        lda     L891B,y                         ; 8880
        bpl     L8888                           ; 8883
        and     #$7F                            ; 8885
        tay                                     ; 8887
L8888:  sty     $74                             ; 8888
        rts                                     ; 888A

; ----------------------------------------------------------------------------
L888B:  lda     $84                             ; 888B
        cmp     $82                             ; 888D
        beq     L8897                           ; 888F
        bcc     L8897                           ; 8891
        lda     #$03                            ; 8893
        sta     $72                             ; 8895
L8897:  rts                                     ; 8897

; ----------------------------------------------------------------------------
        lda     #$10                            ; 8898
        sta     $75                             ; 889A
        lda     #$0A                            ; 889C
        jmp     L8866                           ; 889E

; ----------------------------------------------------------------------------
        jsr     L88D1                           ; 88A1
        bcc     L8897                           ; 88A4
        lda     #$00                            ; 88A6
        sta     $75                             ; 88A8
        .byte   $A9                             ; 88AA
L88AB:  .byte   $0B                             ; 88AB
        sta     $74                             ; 88AC
        lda     #$14                            ; 88AE
        sta     $73                             ; 88B0
        lda     #$02                            ; 88B2
        sta     $72                             ; 88B4
        rts                                     ; 88B6

; ----------------------------------------------------------------------------
        jsr     L885B                           ; 88B7
        lda     #$14                            ; 88BA
        sta     $73                             ; 88BC
        lda     #$10                            ; 88BE
        sta     $74                             ; 88C0
        lda     #$1E                            ; 88C2
        sta     $03DD                           ; 88C4
        rts                                     ; 88C7

; ----------------------------------------------------------------------------
        jsr     L88D1                           ; 88C8
        bcc     L88D0                           ; 88CB
        jsr     L887D                           ; 88CD
L88D0:  rts                                     ; 88D0

; ----------------------------------------------------------------------------
L88D1:  sec                                     ; 88D1
        lda     $7D                             ; 88D2
        bne     L88DC                           ; 88D4
        lda     $7C                             ; 88D6
        cmp     $73                             ; 88D8
        bcc     L88E2                           ; 88DA
L88DC:  lda     #$00                            ; 88DC
        sta     $7C                             ; 88DE
        sta     $7D                             ; 88E0
L88E2:  rts                                     ; 88E2

; ----------------------------------------------------------------------------
L88E3:  brk                                     ; 88E3
        brk                                     ; 88E4
        brk                                     ; 88E5
        brk                                     ; 88E6
        brk                                     ; 88E7
        brk                                     ; 88E8
        brk                                     ; 88E9
        brk                                     ; 88EA
        .byte   $1A                             ; 88EB
        .byte   $33                             ; 88EC
        .byte   $1A                             ; 88ED
        brk                                     ; 88EE
        eor     $331A                           ; 88EF
        .byte   $1A                             ; 88F2
        eor     $1A9A                           ; 88F3
        eor     $3366                           ; 88F6
        eor     $6666                           ; 88F9
        and     $CD9A,x                         ; 88FC
        ror     $33                             ; 88FF
        txs                                     ; 8901
        .byte   $B3                             ; 8902
        txs                                     ; 8903
        .byte   $80                             ; 8904
        cmp     $B39A                           ; 8905
        .byte   $44                             ; 8908
        inc     $B3                             ; 8909
        inc     $CD                             ; 890B
        .byte   $FF                             ; 890D
        inc     $CD                             ; 890E
        inc     $B3                             ; 8910
        cmp     $FFFF                           ; 8912
        .byte   $FF                             ; 8915
        .byte   $FF                             ; 8916
        .byte   $FF                             ; 8917
        .byte   $FF                             ; 8918
        .byte   $FF                             ; 8919
        .byte   $FF                             ; 891A
L891B:  brk                                     ; 891B
        .byte   $80                             ; 891C
        php                                     ; 891D
        asl     $24,x                           ; 891E
        .byte   $32                             ; 8920
        rti                                     ; 8921

; ----------------------------------------------------------------------------
        bit     $32                             ; 8922
        rti                                     ; 8924

; ----------------------------------------------------------------------------
        .byte   $82                             ; 8925
        rti                                     ; 8926

; ----------------------------------------------------------------------------
        .byte   $32                             ; 8927
        bit     $32                             ; 8928
        .byte   $8B                             ; 892A
        brk                                     ; 892B
        php                                     ; 892C
        asl     $24,x                           ; 892D
        .byte   $90                             ; 892F
L8930:  sty     $3C                             ; 8930
        lda     $0600,x                         ; 8932
        asl     a                               ; 8935
        tay                                     ; 8936
        lda     L9F3B,y                         ; 8937
        sta     $3E                             ; 893A
        lda     L9F3C,y                         ; 893C
        sta     $3F                             ; 893F
        lda     $0601,x                         ; 8941
        and     #$0F                            ; 8944
        asl     a                               ; 8946
        asl     a                               ; 8947
        tay                                     ; 8948
        dey                                     ; 8949
        lda     $0601,x                         ; 894A
L894D:  iny                                     ; 894D
        asl     a                               ; 894E
        bcc     L894D                           ; 894F
        lda     ($3E),y                         ; 8951
        sta     $0604,x                         ; 8953
        ldy     $3C                             ; 8956
        lda     $0602,x                         ; 8958
        and     #$F0                            ; 895B
        sta     $0605,x                         ; 895D
        lda     $0603,x                         ; 8960
        lsr     a                               ; 8963
        lsr     a                               ; 8964
        lsr     a                               ; 8965
        lsr     a                               ; 8966
        ora     $0605,x                         ; 8967
        sta     $0605,x                         ; 896A
        rts                                     ; 896D

; ----------------------------------------------------------------------------
        sty     $3C                             ; 896E
        lda     $0600,x                         ; 8970
        asl     a                               ; 8973
        tay                                     ; 8974
        lda     L9FBB,y                         ; 8975
        sta     $3E                             ; 8978
        lda     L9FBC,y                         ; 897A
        sta     $3F                             ; 897D
        ldy     $0604,x                         ; 897F
        cpy     #$FF                            ; 8982
        beq     L899D                           ; 8984
        iny                                     ; 8986
L8987:  tya                                     ; 8987
        sta     $0604,x                         ; 8988
        lda     ($3E),y                         ; 898B
        bpl     L899D                           ; 898D
        asl     a                               ; 898F
        beq     L89A0                           ; 8990
        bmi     L8995                           ; 8992
        clc                                     ; 8994
L8995:  ror     a                               ; 8995
        adc     $0604,x                         ; 8996
        tay                                     ; 8999
        jmp     L8987                           ; 899A

; ----------------------------------------------------------------------------
L899D:  ldy     $3C                             ; 899D
        rts                                     ; 899F

; ----------------------------------------------------------------------------
L89A0:  lda     #$FF                            ; 89A0
        sta     $0604,x                         ; 89A2
        bne     L899D                           ; 89A5
L89A7:  sty     $3C                             ; 89A7
        lda     $0600,x                         ; 89A9
        asl     a                               ; 89AC
        cmp     #$04                            ; 89AD
        bne     L89DB                           ; 89AF
        lda     $0601,x                         ; 89B1
        and     #$0F                            ; 89B4
        cmp     #$02                            ; 89B6
        bcc     L89D9                           ; 89B8
        lda     $32                             ; 89BA
        sec                                     ; 89BC
        sbc     #$01                            ; 89BD
        asl     a                               ; 89BF
        asl     a                               ; 89C0
        sta     $00                             ; 89C1
        lda     $0604,x                         ; 89C3
        and     #$01                            ; 89C6
        asl     a                               ; 89C8
        adc     $00                             ; 89C9
        adc     #$65                            ; 89CB
        sta     $00                             ; 89CD
        lda     #$A1                            ; 89CF
        adc     #$00                            ; 89D1
        sta     $01                             ; 89D3
        ldy     #$00                            ; 89D5
        beq     L89FE                           ; 89D7
L89D9:  lda     #$00                            ; 89D9
L89DB:  tay                                     ; 89DB
        lda     $A03B,y                         ; 89DC
        sta     $00                             ; 89DF
        lda     $A03C,y                         ; 89E1
        sta     $01                             ; 89E4
        lda     L9FBB,y                         ; 89E6
        sta     $3E                             ; 89E9
        lda     L9FBC,y                         ; 89EB
        sta     $3F                             ; 89EE
        ldy     $0604,x                         ; 89F0
        cpy     #$FF                            ; 89F3
        bne     L89FA                           ; 89F5
        jmp     L8A87                           ; 89F7

; ----------------------------------------------------------------------------
L89FA:  lda     ($3E),y                         ; 89FA
        asl     a                               ; 89FC
        tay                                     ; 89FD
L89FE:  lda     ($00),y                         ; 89FE
        sta     $3E                             ; 8A00
        iny                                     ; 8A02
        lda     ($00),y                         ; 8A03
        sta     $3F                             ; 8A05
        lda     $0600,x                         ; 8A07
        clc                                     ; 8A0A
        adc     #$80                            ; 8A0B
        and     #$7F                            ; 8A0D
        tay                                     ; 8A0F
        lda     L9EFB,y                         ; 8A10
        bcc     L8A17                           ; 8A13
        ora     #$20                            ; 8A15
L8A17:  sta     $02                             ; 8A17
        lda     $0602,x                         ; 8A19
        sta     $00                             ; 8A1C
        lda     $0601,x                         ; 8A1E
        and     #$C0                            ; 8A21
        beq     L8A2D                           ; 8A23
        lda     $0604,x                         ; 8A25
        lsr     a                               ; 8A28
        bcc     L8A2D                           ; 8A29
        inc     $00                             ; 8A2B
L8A2D:  lda     $0603,x                         ; 8A2D
        sta     $01                             ; 8A30
        ldy     #$00                            ; 8A32
        cmp     #$20                            ; 8A34
        bcs     L8A39                           ; 8A36
        iny                                     ; 8A38
L8A39:  cmp     #$E0                            ; 8A39
        bcc     L8A3E                           ; 8A3B
        dey                                     ; 8A3D
L8A3E:  sty     $03                             ; 8A3E
        ldy     #$00                            ; 8A40
        sty     $06                             ; 8A42
        lda     ($3E),y                         ; 8A44
        beq     L8A87                           ; 8A46
        bpl     L8A5C                           ; 8A48
        sta     $06                             ; 8A4A
        sec                                     ; 8A4C
        lda     $01                             ; 8A4D
        sbc     #$08                            ; 8A4F
        sta     $01                             ; 8A51
        lda     $02                             ; 8A53
        ora     #$40                            ; 8A55
        sta     $02                             ; 8A57
        iny                                     ; 8A59
        lda     ($3E),y                         ; 8A5A
L8A5C:  sta     $04                             ; 8A5C
        iny                                     ; 8A5E
        stx     $3D                             ; 8A5F
        ldx     $16                             ; 8A61
L8A63:  lda     ($3E),y                         ; 8A63
        clc                                     ; 8A65
        bit     $06                             ; 8A66
        bpl     L8A6F                           ; 8A68
        eor     #$FF                            ; 8A6A
L8A6C:  adc     #$01                            ; 8A6C
        clc                                     ; 8A6E
L8A6F:  adc     $01                             ; 8A6F
        sta     $05                             ; 8A71
        lda     $03                             ; 8A73
        beq     L8A8A                           ; 8A75
        eor     $05                             ; 8A77
        bpl     L8A8A                           ; 8A79
        iny                                     ; 8A7B
        iny                                     ; 8A7C
        iny                                     ; 8A7D
L8A7E:  iny                                     ; 8A7E
        dec     $04                             ; 8A7F
        bne     L8A63                           ; 8A81
        stx     $16                             ; 8A83
        ldx     $3D                             ; 8A85
L8A87:  ldy     $3C                             ; 8A87
        rts                                     ; 8A89

; ----------------------------------------------------------------------------
L8A8A:  lda     $05                             ; 8A8A
        sta     $0203,x                         ; 8A8C
        iny                                     ; 8A8F
        lda     ($3E),y                         ; 8A90
        eor     $02                             ; 8A92
        sta     $0202,x                         ; 8A94
        iny                                     ; 8A97
        lda     ($3E),y                         ; 8A98
        sta     $0201,x                         ; 8A9A
        iny                                     ; 8A9D
        lda     ($3E),y                         ; 8A9E
        clc                                     ; 8AA0
        adc     $00                             ; 8AA1
        sta     $0200,x                         ; 8AA3
        txa                                     ; 8AA6
        clc                                     ; 8AA7
        adc     #$84                            ; 8AA8
        cmp     #$14                            ; 8AAA
        bcs     L8AB0                           ; 8AAC
        adc     #$84                            ; 8AAE
L8AB0:  cmp     $17                             ; 8AB0
        beq     L8A7E                           ; 8AB2
        tax                                     ; 8AB4
        .byte   $4C                             ; 8AB5
        .byte   $7E                             ; 8AB6
L8AB7:  txa                                     ; 8AB7
L8AB8:  lda     $19                             ; 8AB8
        and     #$0F                            ; 8ABA
        beq     L8AC4                           ; 8ABC
        lsr     a                               ; 8ABE
        bcs     L8AC4                           ; 8ABF
        jsr     L8C1E                           ; 8AC1
L8AC4:  lda     $B1                             ; 8AC4
        bpl     L8ACB                           ; 8AC6
        jsr     L8BA8                           ; 8AC8
L8ACB:  ldx     $16                             ; 8ACB
        cpx     $17                             ; 8ACD
        beq     L8AE5                           ; 8ACF
L8AD1:  lda     #$F4                            ; 8AD1
        sta     $0200,x                         ; 8AD3
        txa                                     ; 8AD6
        clc                                     ; 8AD7
        adc     #$84                            ; 8AD8
        cmp     #$14                            ; 8ADA
        bcs     L8AE0                           ; 8ADC
        adc     #$84                            ; 8ADE
L8AE0:  tax                                     ; 8AE0
        cpx     $17                             ; 8AE1
        bne     L8AD1                           ; 8AE3
L8AE5:  txa                                     ; 8AE5
        clc                                     ; 8AE6
        adc     #$84                            ; 8AE7
        cmp     #$14                            ; 8AE9
        bcs     L8AEF                           ; 8AEB
        adc     #$84                            ; 8AED
L8AEF:  sta     $16                             ; 8AEF
        sta     $17                             ; 8AF1
        lda     $1C                             ; 8AF3
        and     #$FE                            ; 8AF5
        sta     $1C                             ; 8AF7
        rts                                     ; 8AF9

; ----------------------------------------------------------------------------
        ldx     #$00                            ; 8AFA
L8AFC:  lda     $0333                           ; 8AFC
        beq     L8B0C                           ; 8AFF
        cpx     $0333                           ; 8B01
        bne     L8B0C                           ; 8B04
        lda     $7F                             ; 8B06
        and     #$02                            ; 8B08
        beq     L8B0F                           ; 8B0A
L8B0C:  jsr     L8B19                           ; 8B0C
L8B0F:  txa                                     ; 8B0F
        clc                                     ; 8B10
        adc     #$08                            ; 8B11
        tax                                     ; 8B13
        bne     L8AFC                           ; 8B14
        jmp     L8AB8                           ; 8B16

; ----------------------------------------------------------------------------
L8B19:  lda     $0601,x                         ; 8B19
        beq     L8B7D                           ; 8B1C
        cmp     #$F0                            ; 8B1E
        bcs     L8B25                           ; 8B20
        jmp     L89A7                           ; 8B22

; ----------------------------------------------------------------------------
L8B25:  ldy     #$02                            ; 8B25
        sty     $00                             ; 8B27
        ldy     #$73                            ; 8B29
        sty     $01                             ; 8B2B
        ldy     #$00                            ; 8B2D
        sty     $02                             ; 8B2F
        cmp     #$F0                            ; 8B31
        beq     L8B41                           ; 8B33
        ldy     #$03                            ; 8B35
        sty     $00                             ; 8B37
        ldy     #$2A                            ; 8B39
        sty     $01                             ; 8B3B
        ldy     #$00                            ; 8B3D
        sty     $02                             ; 8B3F
L8B41:  lda     $0602,x                         ; 8B41
        clc                                     ; 8B44
        adc     $00                             ; 8B45
        sta     $0602,x                         ; 8B47
        cmp     #$B0                            ; 8B4A
        bcc     L8B55                           ; 8B4C
        lda     #$00                            ; 8B4E
        sta     $0601,x                         ; 8B50
        beq     L8B7D                           ; 8B53
L8B55:  ldy     $16                             ; 8B55
        cpy     $17                             ; 8B57
        beq     L8B7D                           ; 8B59
        lda     $0602,x                         ; 8B5B
        sta     $0200,y                         ; 8B5E
        lda     $01                             ; 8B61
        sta     $0201,y                         ; 8B63
        lda     $02                             ; 8B66
        sta     $0202,y                         ; 8B68
        lda     $0603,x                         ; 8B6B
        sta     $0203,y                         ; 8B6E
        tya                                     ; 8B71
        clc                                     ; 8B72
        adc     #$84                            ; 8B73
        cmp     #$14                            ; 8B75
        bcs     L8B7B                           ; 8B77
        adc     #$84                            ; 8B79
L8B7B:  sta     $16                             ; 8B7B
L8B7D:  jmp     LF83C                           ; 8B7D

; ----------------------------------------------------------------------------
        lda     #$F0                            ; 8B80
        ldy     #$07                            ; 8B82
        bne     L8B8A                           ; 8B84
        lda     #$F1                            ; 8B86
        ldy     #$03                            ; 8B88
L8B8A:  sta     $00                             ; 8B8A
        tya                                     ; 8B8C
        and     $7F                             ; 8B8D
        bne     L8BA7                           ; 8B8F
        jsr     LF11C                           ; 8B91
        bne     L8BA7                           ; 8B94
        lda     $00                             ; 8B96
        sta     $0601,y                         ; 8B98
        lda     #$00                            ; 8B9B
        sta     $0602,y                         ; 8B9D
        lda     $E0                             ; 8BA0
        and     #$F8                            ; 8BA2
        sta     $0603,y                         ; 8BA4
L8BA7:  rts                                     ; 8BA7

; ----------------------------------------------------------------------------
L8BA8:  ldy     #$00                            ; 8BA8
        ldx     $16                             ; 8BAA
L8BAC:  tya                                     ; 8BAC
        adc     $7F                             ; 8BAD
        and     #$10                            ; 8BAF
        beq     L8BDC                           ; 8BB1
        lda     $0400,y                         ; 8BB3
        cmp     #$90                            ; 8BB6
        bcs     L8BDC                           ; 8BB8
        sta     $0200,x                         ; 8BBA
        lda     #$CB                            ; 8BBD
        sta     $0201,x                         ; 8BBF
        lda     #$23                            ; 8BC2
        sta     $0202,x                         ; 8BC4
        lda     $0401,y                         ; 8BC7
        sta     $0203,x                         ; 8BCA
        txa                                     ; 8BCD
        clc                                     ; 8BCE
        adc     #$84                            ; 8BCF
        cmp     #$14                            ; 8BD1
        bcs     L8BD7                           ; 8BD3
        adc     #$84                            ; 8BD5
L8BD7:  tax                                     ; 8BD7
        cmp     $17                             ; 8BD8
        .byte   $F0                             ; 8BDA
L8BDB:  .byte   $04                             ; 8BDB
L8BDC:  iny                                     ; 8BDC
        iny                                     ; 8BDD
        bpl     L8BAC                           ; 8BDE
L8BE0:  stx     $16                             ; 8BE0
        rts                                     ; 8BE2

; ----------------------------------------------------------------------------
L8BE3:  ldy     #$07                            ; 8BE3
L8BE5:  lda     $E0,y                           ; 8BE5
        sta     $0400,y                         ; 8BE8
        dey                                     ; 8BEB
        bpl     L8BE5                           ; 8BEC
        ldx     #$00                            ; 8BEE
L8BF0:  txa                                     ; 8BF0
        tay                                     ; 8BF1
L8BF2:  lda     $0400,y                         ; 8BF2
        sta     $0408,y                         ; 8BF5
        iny                                     ; 8BF8
        tya                                     ; 8BF9
        and     #$07                            ; 8BFA
        bne     L8BF2                           ; 8BFC
        lda     $0408,x                         ; 8BFE
        and     #$02                            ; 8C01
        sta     $00                             ; 8C03
        lda     $0409,x                         ; 8C05
        and     #$02                            ; 8C08
        eor     $00                             ; 8C0A
        clc                                     ; 8C0C
        beq     L8C10                           ; 8C0D
        sec                                     ; 8C0F
L8C10:  ldy     #$08                            ; 8C10
L8C12:  ror     $0408,x                         ; 8C12
        inx                                     ; 8C15
        dey                                     ; 8C16
        bne     L8C12                           ; 8C17
        cpx     #$78                            ; 8C19
        bne     L8BF0                           ; 8C1B
        rts                                     ; 8C1D

; ----------------------------------------------------------------------------
L8C1E:  lda     $030A                           ; 8C1E
        bne     L8C24                           ; 8C21
        rts                                     ; 8C23

; ----------------------------------------------------------------------------
L8C24:  jsr     L8C92                           ; 8C24
        lda     #$18                            ; 8C27
        sta     $02                             ; 8C29
        .byte   $A9                             ; 8C2B
L8C2C:  jsr     $0385                           ; 8C2C
        ldy     #$00                            ; 8C2F
        ldx     $16                             ; 8C31
L8C33:  lda     L8C90,y                         ; 8C33
        sta     $04                             ; 8C36
        bne     L8C5A                           ; 8C38
        lda     #$E9                            ; 8C3A
        sta     $04                             ; 8C3C
        lda     $00                             ; 8C3E
        beq     L8C47                           ; 8C40
        dec     $00                             ; 8C42
        jmp     L8C5B                           ; 8C44

; ----------------------------------------------------------------------------
L8C47:  lda     $01                             ; 8C47
        and     #$06                            ; 8C49
        beq     L8C57                           ; 8C4B
        ora     $04                             ; 8C4D
        sta     $04                             ; 8C4F
        lda     #$00                            ; 8C51
        sta     $01                             ; 8C53
        beq     L8C5B                           ; 8C55
L8C57:  stx     $16                             ; 8C57
        rts                                     ; 8C59

; ----------------------------------------------------------------------------
L8C5A:  iny                                     ; 8C5A
L8C5B:  lda     $02                             ; 8C5B
        sta     $0200,x                         ; 8C5D
        lda     $04                             ; 8C60
        sta     $0201,x                         ; 8C62
        lda     #$03                            ; 8C65
        sta     $0202,x                         ; 8C67
        lda     $03                             ; 8C6A
        sta     $0203,x                         ; 8C6C
        clc                                     ; 8C6F
        adc     #$08                            ; 8C70
        sta     $03                             ; 8C72
        txa                                     ; 8C74
        clc                                     ; 8C75
        adc     #$84                            ; 8C76
        cmp     #$14                            ; 8C78
        bcs     L8C7E                           ; 8C7A
        adc     #$84                            ; 8C7C
L8C7E:  cmp     $17                             ; 8C7E
        beq     L8C33                           ; 8C80
        tax                                     ; 8C82
        jmp     L8C33                           ; 8C83

; ----------------------------------------------------------------------------
L8C86:  .byte   $01                             ; 8C86
L8C87:  ora     ($00),y                         ; 8C87
        lsr     $00,x                           ; 8C89
        lsr     $00,x                           ; 8C8B
        .byte   $2B                             ; 8C8D
        brk                                     ; 8C8E
        .byte   $21                             ; 8C8F
L8C90:  .byte   $67                             ; 8C90
        brk                                     ; 8C91
L8C92:  lda     $82                             ; 8C92
        asl     a                               ; 8C94
        tay                                     ; 8C95
        lda     L8C86,y                         ; 8C96
        sta     $00                             ; 8C99
        lda     L8C87,y                         ; 8C9B
        sta     $01                             ; 8C9E
        lda     #$00                            ; 8CA0
        sta     $02                             ; 8CA2
        sta     $03                             ; 8CA4
        lda     $030A                           ; 8CA6
        sta     $04                             ; 8CA9
L8CAB:  lsr     $04                             ; 8CAB
        bcc     L8CBC                           ; 8CAD
        clc                                     ; 8CAF
        lda     $01                             ; 8CB0
        adc     $03                             ; 8CB2
        sta     $03                             ; 8CB4
        lda     $00                             ; 8CB6
        adc     $02                             ; 8CB8
        sta     $02                             ; 8CBA
L8CBC:  asl     $01                             ; 8CBC
        rol     $00                             ; 8CBE
        lda     $04                             ; 8CC0
        bne     L8CAB                           ; 8CC2
        lda     $02                             ; 8CC4
        lsr     a                               ; 8CC6
        lsr     a                               ; 8CC7
        lsr     a                               ; 8CC8
        sta     $00                             ; 8CC9
        lda     $02                             ; 8CCB
        and     #$07                            ; 8CCD
        sta     $01                             ; 8CCF
        rts                                     ; 8CD1

; ----------------------------------------------------------------------------
        sta     $00                             ; 8CD2
        lda     #$00                            ; 8CD4
        tay                                     ; 8CD6
        lda     #$08                            ; 8CD7
        sta     $02                             ; 8CD9
        ldx     $16                             ; 8CDB
L8CDD:  lda     #$70                            ; 8CDD
        sta     $03                             ; 8CDF
        lda     #$04                            ; 8CE1
        sta     $04                             ; 8CE3
L8CE5:  lda     L8D23,y                         ; 8CE5
        beq     L8D07                           ; 8CE8
        sta     $0201,x                         ; 8CEA
        lda     $02                             ; 8CED
        sta     $0200,x                         ; 8CEF
        lda     $03                             ; 8CF2
        sta     $0203,x                         ; 8CF4
        lda     #$00                            ; 8CF7
        sta     $0202,x                         ; 8CF9
        txa                                     ; 8CFC
        clc                                     ; 8CFD
        adc     #$84                            ; 8CFE
        cmp     #$14                            ; 8D00
        bcs     L8D06                           ; 8D02
        adc     #$84                            ; 8D04
L8D06:  tax                                     ; 8D06
L8D07:  iny                                     ; 8D07
        dec     $00                             ; 8D08
        beq     L8D20                           ; 8D0A
        clc                                     ; 8D0C
        lda     $03                             ; 8D0D
        adc     #$08                            ; 8D0F
        sta     $03                             ; 8D11
        dec     $04                             ; 8D13
        bne     L8CE5                           ; 8D15
        clc                                     ; 8D17
        lda     $02                             ; 8D18
        adc     #$10                            ; 8D1A
        sta     $02                             ; 8D1C
        bne     L8CDD                           ; 8D1E
L8D20:  stx     $16                             ; 8D20
        rts                                     ; 8D22

; ----------------------------------------------------------------------------
L8D23:  brk                                     ; 8D23
        brk                                     ; 8D24
        and     $35                             ; 8D25
        brk                                     ; 8D27
        .byte   $17                             ; 8D28
        .byte   $27                             ; 8D29
        brk                                     ; 8D2A
        brk                                     ; 8D2B
        ora     $29,y                           ; 8D2C
        .byte   $0B                             ; 8D2F
        .byte   $1B                             ; 8D30
        .byte   $2B                             ; 8D31
        .byte   $3B                             ; 8D32
        ora     a:$1D                           ; 8D33
        and     $19A5,x                         ; 8D36
        and     #$0F                            ; 8D39
        beq     L8D43                           ; 8D3B
        lsr     a                               ; 8D3D
        bcs     L8D43                           ; 8D3E
        jsr     L8D78                           ; 8D40
L8D43:  lda     $67                             ; 8D43
        bpl     L8D4A                           ; 8D45
        jsr     LF6DE                           ; 8D47
L8D4A:  lda     $B1                             ; 8D4A
        bpl     L8D51                           ; 8D4C
        jsr     L8DE7                           ; 8D4E
L8D51:  lda     $67                             ; 8D51
        bmi     L8D5E                           ; 8D53
        ldx     $16                             ; 8D55
        cpx     $17                             ; 8D57
        bne     L8D61                           ; 8D59
        jsr     LE8EF                           ; 8D5B
L8D5E:  jmp     L8ACB                           ; 8D5E

; ----------------------------------------------------------------------------
L8D61:  lda     #$F4                            ; 8D61
        sta     $0200,x                         ; 8D63
        txa                                     ; 8D66
        clc                                     ; 8D67
        adc     #$84                            ; 8D68
        cmp     #$14                            ; 8D6A
        bcs     L8D70                           ; 8D6C
        adc     #$84                            ; 8D6E
L8D70:  sta     $16                             ; 8D70
        jsr     LF84D                           ; 8D72
        jmp     L8D51                           ; 8D75

; ----------------------------------------------------------------------------
L8D78:  lda     $030A                           ; 8D78
        bne     L8D7E                           ; 8D7B
        rts                                     ; 8D7D

; ----------------------------------------------------------------------------
L8D7E:  jsr     L8C92                           ; 8D7E
        lda     #$18                            ; 8D81
        sta     $02                             ; 8D83
        lda     #$20                            ; 8D85
        sta     $03                             ; 8D87
        ldy     #$00                            ; 8D89
        ldx     $16                             ; 8D8B
L8D8D:  lda     L8C90,y                         ; 8D8D
        sta     $04                             ; 8D90
        bne     L8DB4                           ; 8D92
        lda     #$E9                            ; 8D94
        sta     $04                             ; 8D96
        lda     $00                             ; 8D98
        beq     L8DA1                           ; 8D9A
L8D9C:  dec     $00                             ; 8D9C
        jmp     L8DB5                           ; 8D9E

; ----------------------------------------------------------------------------
L8DA1:  lda     $01                             ; 8DA1
        and     #$06                            ; 8DA3
        beq     L8DB1                           ; 8DA5
        ora     $04                             ; 8DA7
        sta     $04                             ; 8DA9
        lda     #$00                            ; 8DAB
        sta     $01                             ; 8DAD
        beq     L8DB5                           ; 8DAF
L8DB1:  stx     $16                             ; 8DB1
        rts                                     ; 8DB3

; ----------------------------------------------------------------------------
L8DB4:  iny                                     ; 8DB4
L8DB5:  lda     $02                             ; 8DB5
        sta     $0200,x                         ; 8DB7
        lda     $04                             ; 8DBA
        sta     $0201,x                         ; 8DBC
        lda     #$03                            ; 8DBF
        sta     $0202,x                         ; 8DC1
        lda     $03                             ; 8DC4
        sta     $0203,x                         ; 8DC6
        clc                                     ; 8DC9
        adc     #$08                            ; 8DCA
        sta     $03                             ; 8DCC
        lda     $67                             ; 8DCE
        bmi     L8DD5                           ; 8DD0
        jsr     LF84D                           ; 8DD2
L8DD5:  txa                                     ; 8DD5
        clc                                     ; 8DD6
        adc     #$84                            ; 8DD7
        cmp     #$14                            ; 8DD9
        bcs     L8DDF                           ; 8DDB
        adc     #$84                            ; 8DDD
L8DDF:  cmp     $17                             ; 8DDF
        beq     L8D8D                           ; 8DE1
        tax                                     ; 8DE3
        jmp     L8D8D                           ; 8DE4

; ----------------------------------------------------------------------------
L8DE7:  ldy     #$00                            ; 8DE7
        ldx     $16                             ; 8DE9
L8DEB:  tya                                     ; 8DEB
        adc     $7F                             ; 8DEC
        and     #$10                            ; 8DEE
        beq     L8E1B                           ; 8DF0
        lda     $0400,y                         ; 8DF2
        cmp     #$90                            ; 8DF5
        bcs     L8E1B                           ; 8DF7
        sta     $0200,x                         ; 8DF9
        lda     #$CB                            ; 8DFC
        sta     $0201,x                         ; 8DFE
        lda     #$23                            ; 8E01
        sta     $0202,x                         ; 8E03
        lda     $0401,y                         ; 8E06
        sta     $0203,x                         ; 8E09
        txa                                     ; 8E0C
        clc                                     ; 8E0D
        adc     #$84                            ; 8E0E
        cmp     #$14                            ; 8E10
        bcs     L8E16                           ; 8E12
        adc     #$84                            ; 8E14
L8E16:  tax                                     ; 8E16
        cmp     $17                             ; 8E17
        beq     L8E26                           ; 8E19
L8E1B:  lda     $67                             ; 8E1B
        bmi     L8E22                           ; 8E1D
        jsr     LF84D                           ; 8E1F
L8E22:  iny                                     ; 8E22
        iny                                     ; 8E23
        bpl     L8DEB                           ; 8E24
L8E26:  stx     $16                             ; 8E26
        rts                                     ; 8E28

; ----------------------------------------------------------------------------
        lda     #$05                            ; 8E29
        sta     $00                             ; 8E2B
        lda     #$04                            ; 8E2D
        sta     $01                             ; 8E2F
        lda     $0605                           ; 8E31
        and     #$0F                            ; 8E34
        sec                                     ; 8E36
        sbc     #$02                            ; 8E37
        bcs     L8E41                           ; 8E39
        adc     $00                             ; 8E3B
        sta     $00                             ; 8E3D
        lda     #$00                            ; 8E3F
L8E41:  sta     $02                             ; 8E41
        lda     $0605                           ; 8E43
        lsr     a                               ; 8E46
        lsr     a                               ; 8E47
        lsr     a                               ; 8E48
        lsr     a                               ; 8E49
        sec                                     ; 8E4A
        sbc     #$02                            ; 8E4B
        bcs     L8E55                           ; 8E4D
        adc     $01                             ; 8E4F
        sta     $01                             ; 8E51
        lda     #$00                            ; 8E53
L8E55:  sta     $03                             ; 8E55
        ldy     #$3F                            ; 8E57
        lda     #$00                            ; 8E59
L8E5B:  sta     $0190,y                         ; 8E5B
        dey                                     ; 8E5E
        cpy     #$2F                            ; 8E5F
        bne     L8E5B                           ; 8E61
        lda     #$FF                            ; 8E63
L8E65:  sta     $0190,y                         ; 8E65
        dey                                     ; 8E68
        bpl     L8E65                           ; 8E69
L8E6B:  lda     $00                             ; 8E6B
        sta     $04                             ; 8E6D
        lda     $02                             ; 8E6F
        sta     $05                             ; 8E71
L8E73:  jsr     L8EC1                           ; 8E73
        inc     $05                             ; 8E76
        lda     $05                             ; 8E78
        cmp     #$10                            ; 8E7A
        bcs     L8E82                           ; 8E7C
        dec     $04                             ; 8E7E
        bne     L8E73                           ; 8E80
L8E82:  inc     $03                             ; 8E82
        lda     $03                             ; 8E84
        cmp     #$C0                            ; 8E86
        bcs     L8E8E                           ; 8E88
        dec     $01                             ; 8E8A
        bne     L8E6B                           ; 8E8C
L8E8E:  ldx     $0162                           ; 8E8E
        ldy     #$00                            ; 8E91
        lda     $64                             ; 8E93
        lsr     a                               ; 8E95
        lda     #$90                            ; 8E96
        bcc     L8E9E                           ; 8E98
        ldy     #$20                            ; 8E9A
        lda     #$94                            ; 8E9C
L8E9E:  sta     $0163,x                         ; 8E9E
        inx                                     ; 8EA1
        lda     #$20                            ; 8EA2
        sta     $0163,x                         ; 8EA4
        inx                                     ; 8EA7
        sta     $00                             ; 8EA8
L8EAA:  lda     $0190,y                         ; 8EAA
        sta     $0163,x                         ; 8EAD
        iny                                     ; 8EB0
        inx                                     ; 8EB1
        dec     $00                             ; 8EB2
        bne     L8EAA                           ; 8EB4
        lda     #$00                            ; 8EB6
        sta     $0163,x                         ; 8EB8
        stx     $0162                           ; 8EBB
        inc     $64                             ; 8EBE
        rts                                     ; 8EC0

; ----------------------------------------------------------------------------
L8EC1:  ldy     #$03                            ; 8EC1
        lda     $03                             ; 8EC3
        lsr     a                               ; 8EC5
        bcc     L8ECA                           ; 8EC6
        ldy     #$30                            ; 8EC8
L8ECA:  sty     $06                             ; 8ECA
        asl     a                               ; 8ECC
        asl     a                               ; 8ECD
        asl     a                               ; 8ECE
        sta     $07                             ; 8ECF
        lda     $05                             ; 8ED1
        lsr     a                               ; 8ED3
        bcc     L8EDA                           ; 8ED4
        asl     $06                             ; 8ED6
        asl     $06                             ; 8ED8
L8EDA:  ora     $07                             ; 8EDA
        tay                                     ; 8EDC
        lda     $04C0,y                         ; 8EDD
        and     $06                             ; 8EE0
        sta     $07                             ; 8EE2
        lda     $06                             ; 8EE4
        eor     #$FF                            ; 8EE6
        and     $0190,y                         ; 8EE8
        ora     $07                             ; 8EEB
        sta     $0190,y                         ; 8EED
        rts                                     ; 8EF0

; ----------------------------------------------------------------------------
        jsr     LF0CF                           ; 8EF1
        sta     $0F                             ; 8EF4
        cmp     #$03                            ; 8EF6
        bcc     L8EFD                           ; 8EF8
        jsr     L8F23                           ; 8EFA
L8EFD:  lda     $92                             ; 8EFD
        beq     L8F09                           ; 8EFF
        lda     $0F                             ; 8F01
        cmp     #$05                            ; 8F03
        lda     #$06                            ; 8F05
        bcc     L8F0B                           ; 8F07
L8F09:  lda     #$07                            ; 8F09
L8F0B:  jsr     LF0BE                           ; 8F0B
        jsr     LE0A4                           ; 8F0E
        lda     #$10                            ; 8F11
        sta     $0700,x                         ; 8F13
        lda     $0607,x                         ; 8F16
        ora     #$80                            ; 8F19
        sta     $0607,x                         ; 8F1B
        lda     #$12                            ; 8F1E
        jmp     LE992                           ; 8F20

; ----------------------------------------------------------------------------
L8F23:  cmp     #$06                            ; 8F23
        beq     L8F2E                           ; 8F25
        lda     $91                             ; 8F27
        lsr     a                               ; 8F29
        cmp     $81                             ; 8F2A
        bcs     L8F59                           ; 8F2C
L8F2E:  lda     #$FF                            ; 8F2E
        sta     $0E                             ; 8F30
        lda     $0F                             ; 8F32
        cmp     #$05                            ; 8F34
        bcs     L8F40                           ; 8F36
        lsr     $0E                             ; 8F38
        cmp     #$04                            ; 8F3A
        bcs     L8F40                           ; 8F3C
        lsr     $0E                             ; 8F3E
L8F40:  lda     #$00                            ; 8F40
        sta     $00                             ; 8F42
        sta     $01                             ; 8F44
        ldy     #$18                            ; 8F46
        lda     $0F                             ; 8F48
        cmp     #$05                            ; 8F4A
        bcc     L8F51                           ; 8F4C
        jmp     L8F5A                           ; 8F4E

; ----------------------------------------------------------------------------
L8F51:  lda     $0601,y                         ; 8F51
        bne     L8F59                           ; 8F54
        jmp     L8FB4                           ; 8F56

; ----------------------------------------------------------------------------
L8F59:  rts                                     ; 8F59

; ----------------------------------------------------------------------------
L8F5A:  ldy     #$FC                            ; 8F5A
        lda     $0601,x                         ; 8F5C
L8F5F:  iny                                     ; 8F5F
        iny                                     ; 8F60
        iny                                     ; 8F61
        iny                                     ; 8F62
        asl     a                               ; 8F63
        bcc     L8F5F                           ; 8F64
        lda     L8FA4,y                         ; 8F66
        sta     $00                             ; 8F69
        lda     L8FA5,y                         ; 8F6B
        sta     $01                             ; 8F6E
        lda     L8FA6,y                         ; 8F70
        sta     $02                             ; 8F73
        lda     L8FA7,y                         ; 8F75
        sta     $03                             ; 8F78
        ldy     #$18                            ; 8F7A
        lda     $0601,y                         ; 8F7C
        beq     L8F8F                           ; 8F7F
        lda     $0F                             ; 8F81
        cmp     #$06                            ; 8F83
        bne     L8F8E                           ; 8F85
        ldy     #$20                            ; 8F87
        lda     $0601,y                         ; 8F89
        beq     L8F8F                           ; 8F8C
L8F8E:  rts                                     ; 8F8E

; ----------------------------------------------------------------------------
L8F8F:  tya                                     ; 8F8F
        pha                                     ; 8F90
        jsr     L8FB4                           ; 8F91
        pla                                     ; 8F94
        clc                                     ; 8F95
        adc     #$10                            ; 8F96
        tay                                     ; 8F98
        lda     $02                             ; 8F99
        sta     $00                             ; 8F9B
        .byte   $A5                             ; 8F9D
L8F9E:  .byte   $03                             ; 8F9E
        sta     $01                             ; 8F9F
        jmp     L8FB4                           ; 8FA1

; ----------------------------------------------------------------------------
L8FA4:  brk                                     ; 8FA4
L8FA5:  brk                                     ; 8FA5
L8FA6:  .byte   $F0                             ; 8FA6
L8FA7:  .byte   $04                             ; 8FA7
        brk                                     ; 8FA8
        brk                                     ; 8FA9
        beq     L8FA4                           ; 8FAA
        brk                                     ; 8FAC
        .byte   $FC                             ; 8FAD
        sed                                     ; 8FAE
        brk                                     ; 8FAF
        brk                                     ; 8FB0
        .byte   $FC                             ; 8FB1
        sed                                     ; 8FB2
        brk                                     ; 8FB3
L8FB4:  lda     #$03                            ; 8FB4
        sta     $0600,y                         ; 8FB6
        lda     $0601,x                         ; 8FB9
        and     #$F0                            ; 8FBC
        ora     #$07                            ; 8FBE
        sta     $0601,y                         ; 8FC0
        clc                                     ; 8FC3
        lda     $0602,x                         ; 8FC4
        adc     $00                             ; 8FC7
        sta     $0602,y                         ; 8FC9
        clc                                     ; 8FCC
        lda     $0603,x                         ; 8FCD
        adc     $01                             ; 8FD0
        sta     $0603,y                         ; 8FD2
        lda     #$00                            ; 8FD5
        sta     $0700,y                         ; 8FD7
        lda     $0E                             ; 8FDA
        sta     $0702,y                         ; 8FDC
        lda     #$10                            ; 8FDF
        jsr     LE992                           ; 8FE1
        txa                                     ; 8FE4
L8FE5:  pha                                     ; 8FE5
        tya                                     ; 8FE6
        tax                                     ; 8FE7
        jsr     L8930                           ; 8FE8
        pla                                     ; 8FEB
        tax                                     ; 8FEC
        rts                                     ; 8FED

; ----------------------------------------------------------------------------
        pha                                     ; 8FEE
        jsr     L912B                           ; 8FEF
        pla                                     ; 8FF2
        sta     $EC                             ; 8FF3
        lda     #$06                            ; 8FF5
        sta     $EA                             ; 8FF7
        lda     #$00                            ; 8FF9
        sta     $EB                             ; 8FFB
        jsr     LE106                           ; 8FFD
L9000:  lda     $AD                             ; 9000
        and     #$80                            ; 9002
        beq     L900C                           ; 9004
        jsr     LEEB3                           ; 9006
        jmp     L9000                           ; 9009

; ----------------------------------------------------------------------------
L900C:  bit     $EE                             ; 900C
        bmi     L9011                           ; 900E
        rts                                     ; 9010

; ----------------------------------------------------------------------------
L9011:  jsr     LE5AA                           ; 9011
        jsr     LE95B                           ; 9014
        lda     $1C                             ; 9017
        ora     #$02                            ; 9019
        sta     $1C                             ; 901B
        lda     $ED                             ; 901D
        sta     $035D                           ; 901F
        lda     $EE                             ; 9022
        and     #$0F                            ; 9024
        sta     $035E                           ; 9026
        lda     $EE                             ; 9029
        lsr     a                               ; 902B
        lsr     a                               ; 902C
        lsr     a                               ; 902D
        lsr     a                               ; 902E
        and     #$03                            ; 902F
        clc                                     ; 9031
        adc     #$17                            ; 9032
        sta     $035F                           ; 9034
        lda     #$00                            ; 9037
        sta     $035C                           ; 9039
        bit     $EE                             ; 903C
        bvs     L904E                           ; 903E
        lda     #$02                            ; 9040
        sta     $18                             ; 9042
        jsr     L9059                           ; 9044
L9047:  jsr     LEEB3                           ; 9047
        lda     $18                             ; 904A
        bne     L9047                           ; 904C
L904E:  lda     $1C                             ; 904E
        ora     #$02                            ; 9050
        sta     $1C                             ; 9052
        jsr     L9060                           ; 9054
        ldy     $3C                             ; 9057
L9059:  lda     $1C                             ; 9059
        and     #$FD                            ; 905B
        sta     $1C                             ; 905D
        rts                                     ; 905F

; ----------------------------------------------------------------------------
L9060:  stx     $3D                             ; 9060
L9062:  lda     #$00                            ; 9062
        sta     $0162                           ; 9064
L9067:  ldx     $0162                           ; 9067
        jsr     L9133                           ; 906A
        sta     $0163,x                         ; 906D
        ora     #$00                            ; 9070
        beq     L90B7                           ; 9072
        bmi     L907D                           ; 9074
        inx                                     ; 9076
        jsr     L9133                           ; 9077
        sta     $0163,x                         ; 907A
L907D:  inx                                     ; 907D
        jsr     L9133                           ; 907E
        sta     $0163,x                         ; 9081
        inx                                     ; 9084
        sta     $3E                             ; 9085
        and     #$3F                            ; 9087
        sta     $035B                           ; 9089
        jsr     L9133                           ; 908C
        .byte   $9D                             ; 908F
L9090:  .byte   $63                             ; 9090
        ora     ($E8,x)                         ; 9091
        bit     $3E                             ; 9093
        bvs     L90A5                           ; 9095
L9097:  dec     $035B                           ; 9097
        beq     L90A5                           ; 909A
        .byte   $20                             ; 909C
L909D:  .byte   $33                             ; 909D
        sta     ($9D),y                         ; 909E
        .byte   $63                             ; 90A0
        ora     ($E8,x)                         ; 90A1
        bne     L9097                           ; 90A3
L90A5:  stx     $0162                           ; 90A5
        cpx     #$50                            ; 90A8
        bcc     L9067                           ; 90AA
        lda     #$00                            ; 90AC
        sta     $0163,x                         ; 90AE
        jsr     L90BD                           ; 90B1
        jmp     L9062                           ; 90B4

; ----------------------------------------------------------------------------
L90B7:  jsr     L90BD                           ; 90B7
        ldx     $3D                             ; 90BA
        rts                                     ; 90BC

; ----------------------------------------------------------------------------
L90BD:  lda     #$63                            ; 90BD
        sta     $E8                             ; 90BF
        lda     #$01                            ; 90C1
        sta     $E9                             ; 90C3
        lda     #$04                            ; 90C5
        sta     $EA                             ; 90C7
        lda     #$00                            ; 90C9
        sta     $EB                             ; 90CB
        sta     $EC                             ; 90CD
        tax                                     ; 90CF
        lda     $0163,x                         ; 90D0
        bne     L90D6                           ; 90D3
        rts                                     ; 90D5

; ----------------------------------------------------------------------------
L90D6:  lda     $0163,x                         ; 90D6
        cmp     #$3F                            ; 90D9
        bne     L9100                           ; 90DB
        inx                                     ; 90DD
        lda     $0163,x                         ; 90DE
        tay                                     ; 90E1
        inx                                     ; 90E2
        lda     $0163,x                         ; 90E3
        sta     $3E                             ; 90E6
        inx                                     ; 90E8
L90E9:  lda     $0163,x                         ; 90E9
        sta     $04A0,y                         ; 90EC
        inx                                     ; 90EF
        iny                                     ; 90F0
        dec     $3E                             ; 90F1
        bne     L90E9                           ; 90F3
        bit     $EE                             ; 90F5
        bvs     L90D6                           ; 90F7
        lda     #$00                            ; 90F9
        sta     $0163                           ; 90FB
        beq     L90D6                           ; 90FE
L9100:  lda     $0163                           ; 9100
        bne     L911E                           ; 9103
        clc                                     ; 9105
        txa                                     ; 9106
        adc     $E8                             ; 9107
        sta     $E8                             ; 9109
        lda     $E9                             ; 910B
        adc     #$00                            ; 910D
        sta     $E9                             ; 910F
        lda     $04B0                           ; 9111
        sta     $04BA                           ; 9114
        jsr     LEC7E                           ; 9117
        lda     #$FF                            ; 911A
        sta     $18                             ; 911C
L911E:  jsr     L9059                           ; 911E
L9121:  lda     $0163                           ; 9121
        cmp     #$3F                            ; 9124
        beq     L912B                           ; 9126
        jsr     LEEB3                           ; 9128
L912B:  lda     $18                             ; 912B
        ora     $0163                           ; 912D
        bne     L9121                           ; 9130
        rts                                     ; 9132

; ----------------------------------------------------------------------------
L9133:  ldy     $035C                           ; 9133
        bne     L916D                           ; 9136
        lda     #$60                            ; 9138
        sta     $E8                             ; 913A
        lda     #$03                            ; 913C
        sta     $E9                             ; 913E
        lda     #$20                            ; 9140
        sta     $EA                             ; 9142
        lda     $035D                           ; 9144
        sta     $EB                             ; 9147
        lda     $035E                           ; 9149
        and     #$0F                            ; 914C
        sta     $EC                             ; 914E
        lda     $035F                           ; 9150
        sta     $ED                             ; 9153
        lda     $1C                             ; 9155
        ora     #$08                            ; 9157
        sta     $1C                             ; 9159
        jsr     LE8E7                           ; 915B
        lda     $EB                             ; 915E
        sta     $035D                           ; 9160
        lda     $EC                             ; 9163
        sta     $035E                           ; 9165
        lda     $ED                             ; 9168
        sta     $035F                           ; 916A
L916D:  lda     $0360,y                         ; 916D
        iny                                     ; 9170
        cpy     #$20                            ; 9171
        bne     L9177                           ; 9173
        ldy     #$00                            ; 9175
L9177:  sty     $035C                           ; 9177
        rts                                     ; 917A

; ----------------------------------------------------------------------------
        jsr     L8282                           ; 917B
        lda     #$68                            ; 917E
        sta     $0602                           ; 9180
        sta     $060A                           ; 9183
        lda     #$08                            ; 9186
        sta     $0603                           ; 9188
        sta     $060B                           ; 918B
        jsr     LEA88                           ; 918E
        jsr     L91EA                           ; 9191
        lda     #$02                            ; 9194
        sta     $1A                             ; 9196
        lda     #$13                            ; 9198
        sta     $2F                             ; 919A
L919C:  jsr     L91AC                           ; 919C
        jsr     LF0B2                           ; 919F
        lda     $1A                             ; 91A2
        bne     L919C                           ; 91A4
        jsr     L924A                           ; 91A6
        jmp     LEAAA                           ; 91A9

; ----------------------------------------------------------------------------
L91AC:  clc                                     ; 91AC
        lda     $12                             ; 91AD
        adc     #$02                            ; 91AF
        sta     $12                             ; 91B1
        lda     $1A                             ; 91B3
        jsr     LE97D                           ; 91B5
        ldx     $BF91,y                         ; 91B8
        sta     ($D4),y                         ; 91BB
        .byte   $91                             ; 91BD
L91BE:  rts                                     ; 91BE

; ----------------------------------------------------------------------------
        lda     $0603                           ; 91BF
        clc                                     ; 91C2
        adc     #$01                            ; 91C3
        sta     $0603                           ; 91C5
        sta     $060B                           ; 91C8
        cmp     #$F8                            ; 91CB
        bcc     L91BE                           ; 91CD
        lda     #$00                            ; 91CF
        sta     $1A                             ; 91D1
        rts                                     ; 91D3

; ----------------------------------------------------------------------------
        lda     $0603                           ; 91D4
        cmp     #$80                            ; 91D7
        bcs     L91E3                           ; 91D9
        adc     #$01                            ; 91DB
        sta     $0603                           ; 91DD
        sta     $060B                           ; 91E0
L91E3:  lda     $2F                             ; 91E3
        bne     L91BE                           ; 91E5
        dec     $1A                             ; 91E7
        rts                                     ; 91E9

; ----------------------------------------------------------------------------
L91EA:  lda     #$05                            ; 91EA
        sta     $1A                             ; 91EC
        lda     #$1E                            ; 91EE
        sta     $11                             ; 91F0
        lda     #$03                            ; 91F2
        sta     $18                             ; 91F4
        jsr     LE95B                           ; 91F6
L91F9:  lda     #$01                            ; 91F9
        sta     $2F                             ; 91FB
        sec                                     ; 91FD
        lda     $1A                             ; 91FE
        sbc     #$02                            ; 9200
        bmi     L923E                           ; 9202
        asl     a                               ; 9204
        asl     a                               ; 9205
        asl     a                               ; 9206
        asl     a                               ; 9207
        sta     $00                             ; 9208
        ldy     #$00                            ; 920A
        ldx     $0162                           ; 920C
        lda     #$3F                            ; 920F
        sta     $0163,x                         ; 9211
        inx                                     ; 9214
        lda     #$00                            ; 9215
        sta     $0163,x                         ; 9217
        inx                                     ; 921A
        lda     #$20                            ; 921B
        sta     $0163,x                         ; 921D
        inx                                     ; 9220
L9221:  lda     $04A0,y                         ; 9221
        sec                                     ; 9224
        sbc     $00                             ; 9225
        beq     L922D                           ; 9227
        bcs     L922D                           ; 9229
        lda     #$0F                            ; 922B
L922D:  sta     $0163,x                         ; 922D
        inx                                     ; 9230
        iny                                     ; 9231
        cpy     #$20                            ; 9232
        bne     L9221                           ; 9234
        lda     #$00                            ; 9236
        sta     $0163,x                         ; 9238
        stx     $0162                           ; 923B
L923E:  jsr     LF0B2                           ; 923E
        lda     $2F                             ; 9241
        bne     L923E                           ; 9243
        dec     $1A                             ; 9245
        bne     L91F9                           ; 9247
        rts                                     ; 9249

; ----------------------------------------------------------------------------
L924A:  lda     $11                             ; 924A
        and     #$18                            ; 924C
        beq     L9269                           ; 924E
        lda     #$05                            ; 9250
        sta     $1A                             ; 9252
L9254:  lda     #$01                            ; 9254
        sta     $2F                             ; 9256
        jsr     LF067                           ; 9258
        jsr     LF79E                           ; 925B
L925E:  jsr     LF0B2                           ; 925E
        lda     $2F                             ; 9261
        bne     L925E                           ; 9263
        dec     $1A                             ; 9265
        bne     L9254                           ; 9267
L9269:  jsr     LF785                           ; 9269
        jmp     LE5AA                           ; 926C

; ----------------------------------------------------------------------------
        lda     #$05                            ; 926F
        sta     $1A                             ; 9271
L9273:  lda     #$01                            ; 9273
        sta     $2F                             ; 9275
        jsr     LF067                           ; 9277
L927A:  jsr     LF0B2                           ; 927A
        lda     $2F                             ; 927D
        bne     L927A                           ; 927F
        dec     $1A                             ; 9281
        bne     L9273                           ; 9283
        jmp     LE5AA                           ; 9285

; ----------------------------------------------------------------------------
        lda     #$00                            ; 9288
        sta     $031C                           ; 928A
        tax                                     ; 928D
L928E:  sta     $0600,x                         ; 928E
        sta     $0700,x                         ; 9291
        inx                                     ; 9294
        bne     L928E                           ; 9295
        jsr     LEA7E                           ; 9297
        ldx     #$0F                            ; 929A
L929C:  lda     L92C5,x                         ; 929C
        sta     $0220,x                         ; 929F
        dex                                     ; 92A2
        bpl     L929C                           ; 92A3
        ldy     #$00                            ; 92A5
        ldx     #$00                            ; 92A7
        .byte   $A5                             ; 92A9
L92AA:  .byte   $82                             ; 92AA
        cmp     #$03                            ; 92AB
        .byte   $D0                             ; 92AD
L92AE:  .byte   $02                             ; 92AE
        ldx     #$10                            ; 92AF
L92B1:  lda     L92D5,x                         ; 92B1
        sta     $0230,y                         ; 92B4
        inx                                     ; 92B7
        iny                                     ; 92B8
        cpy     #$10                            ; 92B9
        bne     L92B1                           ; 92BB
        jsr     LF09B                           ; 92BD
        lda     #$FF                            ; 92C0
        jmp     LE992                           ; 92C2

; ----------------------------------------------------------------------------
L92C5:  bcc     L92E8                           ; 92C5
        brk                                     ; 92C7
        sei                                     ; 92C8
        .byte   $90                             ; 92C9
L92CA:  and     ($00),y                         ; 92CA
        .byte   $80                             ; 92CC
        .byte   $A0                             ; 92CD
L92CE:  .byte   $23                             ; 92CE
        brk                                     ; 92CF
        sei                                     ; 92D0
        ldy     #$33                            ; 92D1
        brk                                     ; 92D3
        .byte   $80                             ; 92D4
L92D5:  bmi     L92AA                           ; 92D5
        ora     ($78,x)                         ; 92D7
        bmi     L92AE                           ; 92D9
        eor     ($80,x)                         ; 92DB
        rti                                     ; 92DD

; ----------------------------------------------------------------------------
        cmp     $01,x                           ; 92DE
        sei                                     ; 92E0
        rti                                     ; 92E1

; ----------------------------------------------------------------------------
        cmp     $41,x                           ; 92E2
        .byte   $80                             ; 92E4
        bmi     L92CA                           ; 92E5
        .byte   $03                             ; 92E7
L92E8:  sei                                     ; 92E8
        bmi     L92CE                           ; 92E9
        .byte   $43                             ; 92EB
        .byte   $80                             ; 92EC
        rti                                     ; 92ED

; ----------------------------------------------------------------------------
        sbc     $03                             ; 92EE
        sei                                     ; 92F0
        rti                                     ; 92F1

; ----------------------------------------------------------------------------
        sbc     $43                             ; 92F2
        .byte   $80                             ; 92F4
        sta     $00                             ; 92F5
        asl     a                               ; 92F7
        tay                                     ; 92F8
        bne     L9359                           ; 92F9
        .byte   $A0                             ; 92FB
L92FC:  .byte   $06                             ; 92FC
L92FD:  cpy     #$02                            ; 92FD
        beq     L9309                           ; 92FF
        lda     $0336,y                         ; 9301
        and     #$7F                            ; 9304
        sta     $0336,y                         ; 9306
L9309:  dey                                     ; 9309
        bpl     L92FD                           ; 930A
        lda     $0335                           ; 930C
        beq     L9378                           ; 930F
        lda     $03C0                           ; 9311
        beq     L9378                           ; 9314
        lda     $BF                             ; 9316
        and     #$03                            ; 9318
        beq     L9378                           ; 931A
        sta     $00                             ; 931C
        lda     $82                             ; 931E
        asl     a                               ; 9320
        asl     a                               ; 9321
        adc     $00                             ; 9322
        sta     $00                             ; 9324
        asl     a                               ; 9326
        tay                                     ; 9327
        lda     L93AB,y                         ; 9328
        sta     $3E                             ; 932B
        lda     L93AC,y                         ; 932D
        sta     $3F                             ; 9330
        ldy     #$00                            ; 9332
        lda     $3F                             ; 9334
        beq     L934A                           ; 9336
        pha                                     ; 9338
        and     #$0F                            ; 9339
        sta     $3F                             ; 933B
        pla                                     ; 933D
        bmi     L9346                           ; 933E
        lda     ($3E),y                         ; 9340
        bne     L9378                           ; 9342
        beq     L934A                           ; 9344
L9346:  lda     ($3E),y                         ; 9346
        beq     L9378                           ; 9348
L934A:  lda     #$04                            ; 934A
        sta     $EA                             ; 934C
        lda     #$06                            ; 934E
        sta     $EB                             ; 9350
        lda     $00                             ; 9352
        sta     $EC                             ; 9354
        jmp     L9372                           ; 9356

; ----------------------------------------------------------------------------
L9359:  sty     $01                             ; 9359
        ldy     $00                             ; 935B
        lda     $0335,y                         ; 935D
        beq     L9378                           ; 9360
        bmi     L9378                           ; 9362
        cpy     #$06                            ; 9364
        bcs     L936D                           ; 9366
        ora     #$80                            ; 9368
        sta     $0335,y                         ; 936A
L936D:  ldy     $01                             ; 936D
        jsr     L9379                           ; 936F
L9372:  jsr     LE106                           ; 9372
        jmp     LE110                           ; 9375

; ----------------------------------------------------------------------------
L9378:  rts                                     ; 9378

; ----------------------------------------------------------------------------
L9379:  lda     L9395,y                         ; 9379
        asl     a                               ; 937C
        sta     $EA                             ; 937D
        lda     #$06                            ; 937F
        sta     $EB                             ; 9381
        lda     L9396,y                         ; 9383
        sta     $EC                             ; 9386
        bcs     L9394                           ; 9388
        lda     $031C                           ; 938A
        and     #$3F                            ; 938D
        ora     #$80                            ; 938F
        sta     $031C                           ; 9391
L9394:  rts                                     ; 9394

; ----------------------------------------------------------------------------
L9395:  .byte   $80                             ; 9395
L9396:  brk                                     ; 9396
        .byte   $80                             ; 9397
        ora     ($80,x)                         ; 9398
        .byte   $02                             ; 939A
        brk                                     ; 939B
        .byte   $03                             ; 939C
        .byte   $80                             ; 939D
        .byte   $04                             ; 939E
        brk                                     ; 939F
        ora     $00                             ; 93A0
        asl     $80                             ; 93A2
        .byte   $07                             ; 93A4
        ora     ($06,x)                         ; 93A5
        ora     ($07,x)                         ; 93A7
        ora     ($08,x)                         ; 93A9
L93AB:  brk                                     ; 93AB
L93AC:  brk                                     ; 93AC
        brk                                     ; 93AD
        brk                                     ; 93AE
        brk                                     ; 93AF
        brk                                     ; 93B0
        brk                                     ; 93B1
        brk                                     ; 93B2
        brk                                     ; 93B3
        brk                                     ; 93B4
        brk                                     ; 93B5
        brk                                     ; 93B6
        brk                                     ; 93B7
        brk                                     ; 93B8
        .byte   $37                             ; 93B9
        .byte   $03                             ; 93BA
        brk                                     ; 93BB
        brk                                     ; 93BC
        brk                                     ; 93BD
        brk                                     ; 93BE
        brk                                     ; 93BF
        brk                                     ; 93C0
        brk                                     ; 93C1
        brk                                     ; 93C2
        brk                                     ; 93C3
        brk                                     ; 93C4
        brk                                     ; 93C5
        brk                                     ; 93C6
        brk                                     ; 93C7
        brk                                     ; 93C8
        brk                                     ; 93C9
        brk                                     ; 93CA
        brk                                     ; 93CB
        brk                                     ; 93CC
        brk                                     ; 93CD
        brk                                     ; 93CE
        brk                                     ; 93CF
        brk                                     ; 93D0
        brk                                     ; 93D1
        brk                                     ; 93D2
L93D3:  ora     ($50,x)                         ; 93D3
        eor     ($52),y                         ; 93D5
        .byte   $53                             ; 93D7
        .byte   $54                             ; 93D8
        eor     $56,x                           ; 93D9
        .byte   $57                             ; 93DB
        cli                                     ; 93DC
        eor     $5B5A,y                         ; 93DD
L93E0:  .byte   $5C                             ; 93E0
        .byte   $5D                             ; 93E1
        .byte   $5E                             ; 93E2
L93E3:  sed                                     ; 93E3
L93E4:  php                                     ; 93E4
        clv                                     ; 93E5
        bpl     L93E0                           ; 93E6
L93E8:  php                                     ; 93E8
        clv                                     ; 93E9
        bpl     L93E4                           ; 93EA
        php                                     ; 93EC
        clv                                     ; 93ED
        bcc     L93E8                           ; 93EE
        php                                     ; 93F0
        clv                                     ; 93F1
        clc                                     ; 93F2
        .byte   $B7                             ; 93F3
        .byte   $0F                             ; 93F4
        .byte   $0C                             ; 93F5
        .byte   $3F                             ; 93F6
        .byte   $B7                             ; 93F7
        .byte   $12                             ; 93F8
        .byte   $0C                             ; 93F9
        .byte   $3F                             ; 93FA
        .byte   $B7                             ; 93FB
        ora     $0C,x                           ; 93FC
        .byte   $3F                             ; 93FE
        .byte   $B7                             ; 93FF
        clc                                     ; 9400
        .byte   $0C                             ; 9401
        .byte   $33                             ; 9402
L9403:  .byte   $B7                             ; 9403
        .byte   $1B                             ; 9404
        .byte   $0C                             ; 9405
        .byte   $33                             ; 9406
        .byte   $B7                             ; 9407
        clc                                     ; 9408
        .byte   $0C                             ; 9409
        and     $1BB7,y                         ; 940A
        .byte   $0C                             ; 940D
        and     $06B7,y                         ; 940E
        .byte   $0C                             ; 9411
        .byte   $33                             ; 9412
        .byte   $B7                             ; 9413
        .byte   $42                             ; 9414
        .byte   $0C                             ; 9415
        .byte   $33                             ; 9416
        .byte   $B7                             ; 9417
        clc                                     ; 9418
        .byte   $0C                             ; 9419
        bit     $B7                             ; 941A
        and     $330C,y                         ; 941C
        .byte   $B7                             ; 941F
        .byte   $03                             ; 9420
        .byte   $0C                             ; 9421
L9422:  bit     $B7                             ; 9422
        .byte   $3F                             ; 9424
        .byte   $0C                             ; 9425
        .byte   $87                             ; 9426
        .byte   $B7                             ; 9427
        .byte   $3F                             ; 9428
        .byte   $0C                             ; 9429
        .byte   $87                             ; 942A
        .byte   $B7                             ; 942B
        .byte   $1B                             ; 942C
        .byte   $0C                             ; 942D
        .byte   $87                             ; 942E
        .byte   $B7                             ; 942F
        eor     $0C                             ; 9430
        .byte   $87                             ; 9432
        .byte   $B7                             ; 9433
        pha                                     ; 9434
        .byte   $0C                             ; 9435
        .byte   $87                             ; 9436
        .byte   $B7                             ; 9437
        lda     $8D                             ; 9438
        ldx     $24B7                           ; 943A
        .byte   $0C                             ; 943D
        and     $27B7                           ; 943E
        .byte   $0C                             ; 9441
        rol     a                               ; 9442
        .byte   $B7                             ; 9443
        ora     #$0C                            ; 9444
        .byte   $33                             ; 9446
        .byte   $B7                             ; 9447
        bmi     L9456                           ; 9448
        bmi     L9403                           ; 944A
        rol     $0C,x                           ; 944C
        and     $21B7                           ; 944E
        .byte   $0C                             ; 9451
        .byte   $B7                             ; 9452
        .byte   $B7                             ; 9453
        .byte   $4B                             ; 9454
        .byte   $42                             ; 9455
L9456:  .byte   $B7                             ; 9456
        .byte   $B7                             ; 9457
        stx     $63,y                           ; 9458
        stx     $B7,y                           ; 945A
        lsr     $4E3C                           ; 945C
        .byte   $B7                             ; 945F
        eor     ($63),y                         ; 9460
        eor     ($B7),y                         ; 9462
        .byte   $54                             ; 9464
L9465:  .byte   $3F                             ; 9465
        .byte   $54                             ; 9466
        .byte   $B7                             ; 9467
        .byte   $57                             ; 9468
        .byte   $63                             ; 9469
        .byte   $57                             ; 946A
        .byte   $B7                             ; 946B
        .byte   $4B                             ; 946C
        eor     $B7                             ; 946D
        .byte   $B7                             ; 946F
        lda     $63                             ; 9470
        lda     $B7                             ; 9472
        ldx     $AE63                           ; 9474
        .byte   $B7                             ; 9477
        eor     $7566,x                         ; 9478
        .byte   $B7                             ; 947B
        .byte   $5A                             ; 947C
        .byte   $63                             ; 947D
        .byte   $72                             ; 947E
        .byte   $B7                             ; 947F
        rts                                     ; 9480

; ----------------------------------------------------------------------------
        adc     #$78                            ; 9481
        .byte   $B7                             ; 9483
        .byte   $5A                             ; 9484
        .byte   $63                             ; 9485
        .byte   $72                             ; 9486
        .byte   $B7                             ; 9487
        tay                                     ; 9488
        .byte   $7B                             ; 9489
        .byte   $03                             ; 948A
        .byte   $B7                             ; 948B
        .byte   $5A                             ; 948C
        .byte   $63                             ; 948D
        ora     #$B7                            ; 948E
        bcc     L9422                           ; 9490
        asl     L8AB7,x                         ; 9492
        txa                                     ; 9495
        .byte   $AE                             ; 9496
L9497:  .byte   $B7                             ; 9497
        .byte   $5A                             ; 9498
        .byte   $63                             ; 9499
        sty     $B7                             ; 949A
        .byte   $5D                             ; 949C
        .byte   $66                             ; 949D
L949E:  sty     $B7                             ; 949E
        rts                                     ; 94A0

; ----------------------------------------------------------------------------
        adc     #$84                            ; 94A1
        .byte   $B7                             ; 94A3
        .byte   $5A                             ; 94A4
        .byte   $63                             ; 94A5
        sty     $B7                             ; 94A6
        ror     L846C,x                         ; 94A8
        .byte   $B7                             ; 94AB
        asl     $63                             ; 94AC
        asl     $B7                             ; 94AE
        .byte   $5A                             ; 94B0
        .byte   $63                             ; 94B1
        ldx     L96B7                           ; 94B2
        stx     $B1,y                           ; 94B5
        .byte   $B7                             ; 94B7
        .byte   $9F                             ; 94B8
        .byte   $9F                             ; 94B9
        .byte   $9F                             ; 94BA
        .byte   $B7                             ; 94BB
        eor     $B163,x                         ; 94BC
        .byte   $B7                             ; 94BF
        eor     $B463,x                         ; 94C0
        .byte   $B7                             ; 94C3
        bcc     L9465                           ; 94C4
        .byte   $9C                             ; 94C6
        .byte   $B7                             ; 94C7
        .byte   $4B                             ; 94C8
        .byte   $3C                             ; 94C9
        .byte   $B7                             ; 94CA
        .byte   $B7                             ; 94CB
        asl     $63                             ; 94CC
        ldx     $06B7                           ; 94CE
        .byte   $63                             ; 94D1
        sty     $B7                             ; 94D2
        sta     L9396,y                         ; 94D4
        .byte   $B7                             ; 94D7
        rts                                     ; 94D8

; ----------------------------------------------------------------------------
        adc     #$AE                            ; 94D9
        .byte   $B7                             ; 94DB
        .byte   $4B                             ; 94DC
        .byte   $3F                             ; 94DD
        .byte   $B7                             ; 94DE
        .byte   $B7                             ; 94DF
        txa                                     ; 94E0
        .byte   $6F                             ; 94E1
        sty     $B7                             ; 94E2
        pha                                     ; 94E4
        pha                                     ; 94E5
        .byte   $AB                             ; 94E6
        .byte   $B7                             ; 94E7
        tsx                                     ; 94E8
        .byte   $0C                             ; 94E9
        .byte   $63                             ; 94EA
        .byte   $B7                             ; 94EB
        lda     $C00C,x                         ; 94EC
        .byte   $B7                             ; 94EF
        .byte   $3C                             ; 94F0
        .byte   $3C                             ; 94F1
        lda     $B7                             ; 94F2
        .byte   $AB                             ; 94F4
        .byte   $AB                             ; 94F5
        .byte   $AB                             ; 94F6
        .byte   $B7                             ; 94F7
        ror     $037B,x                         ; 94F8
        .byte   $B7                             ; 94FB
        .byte   $5A                             ; 94FC
        .byte   $63                             ; 94FD
        .byte   $72                             ; 94FE
        .byte   $B7                             ; 94FF
        lda     $8D                             ; 9500
        asl     L90B7,x                         ; 9502
        sta     $B71E                           ; 9505
        eor     $AE66,x                         ; 9508
        .byte   $B7                             ; 950B
        bcc     L949E                           ; 950C
        eor     $B7                             ; 950E
        ror     $AE7B,x                         ; 9510
        .byte   $B7                             ; 9513
        .byte   $C3                             ; 9514
        .byte   $6F                             ; 9515
        .byte   $3F                             ; 9516
        .byte   $B7                             ; 9517
        lda     $3F                             ; 9518
        lda     $B7                             ; 951A
        lda     $3C                             ; 951C
        .byte   $C9                             ; 951E
L951F:  plp                                     ; 951F
        jsr     L3616                           ; 9520
        jsr     L1738                           ; 9523
        .byte   $37                             ; 9526
        ora     $2010,y                         ; 9527
        ora     $0F28,y                         ; 952A
        asl     $28,x                           ; 952D
        rol     $16,x                           ; 952F
        bit     $3B                             ; 9531
        ora     ($2B),y                         ; 9533
        and     $2718,y                         ; 9535
        jsr     L1606                           ; 9538
        jsr     L1708                           ; 953B
        bpl     L954F                           ; 953E
        bpl     L9578                           ; 9540
        brk                                     ; 9542
        rol     $20                             ; 9543
        asl     $1A,x                           ; 9545
        jsr     L2A16                           ; 9547
        jsr     L270A                           ; 954A
        .byte   $20                             ; 954D
        .byte   $04                             ; 954E
L954F:  .byte   $27                             ; 954F
        jsr     L2A0B                           ; 9550
        jsr     L2716                           ; 9553
        sec                                     ; 9556
        asl     $28                             ; 9557
        jsr     L1909                           ; 9559
        bmi     L9568                           ; 955C
        asl     $27,x                           ; 955E
        asl     $21                             ; 9560
        jsr     L1701                           ; 9562
        plp                                     ; 9565
        asl     $16                             ; 9566
L9568:  jsr     L170F                           ; 9568
        .byte   $27                             ; 956B
        .byte   $0F                             ; 956C
        .byte   $07                             ; 956D
        .byte   $37                             ; 956E
        asl     $10                             ; 956F
        jsr     L2721                           ; 9571
        sec                                     ; 9574
        asl     $13                             ; 9575
        .byte   $3B                             ; 9577
L9578:  .byte   $03                             ; 9578
        .byte   $17                             ; 9579
        and     #$19                            ; 957A
        .byte   $1B                             ; 957C
        .byte   $2B                             ; 957D
        .byte   $0B                             ; 957E
        .byte   $17                             ; 957F
        jsr     L1110                           ; 9580
        jsr     L1319                           ; 9583
        jsr     L0B0B                           ; 9586
        jsr     L1610                           ; 9589
        plp                                     ; 958C
        sec                                     ; 958D
        bpl     L95B0                           ; 958E
        brk                                     ; 9590
        asl     $2B,x                           ; 9591
        ora     $1A28,y                         ; 9593
        .byte   $0B                             ; 9596
        jsr     L1020                           ; 9597
        ora     ($20),y                         ; 959A
        sec                                     ; 959C
        rol     $29,x                           ; 959D
        sec                                     ; 959F
        rol     $29,x                           ; 95A0
        bpl     L95B5                           ; 95A2
        jsr     L2701                           ; 95A4
        jsr     L1107                           ; 95A7
        and     #$09                            ; 95AA
        .byte   $13                             ; 95AC
        jsr     L160F                           ; 95AD
L95B0:  plp                                     ; 95B0
        .byte   $0F                             ; 95B1
        bit     $1120                           ; 95B2
L95B5:  ora     ($31),y                         ; 95B5
        ora     ($06,x)                         ; 95B7
        .byte   $17                             ; 95B9
        ora     $2011,y                         ; 95BA
        ora     ($16,x)                         ; 95BD
        rol     $06,x                           ; 95BF
        .byte   $07                             ; 95C1
        asl     $38                             ; 95C2
        .byte   $17                             ; 95C4
        .byte   $2B                             ; 95C5
        .byte   $0F                             ; 95C6
        .byte   $17                             ; 95C7
        .byte   $37                             ; 95C8
        sec                                     ; 95C9
        .byte   $0F                             ; 95CA
        .byte   $0F                             ; 95CB
        .byte   $0F                             ; 95CC
        .byte   $17                             ; 95CD
        plp                                     ; 95CE
        .byte   $03                             ; 95CF
        ora     ($31),y                         ; 95D0
        asl     $17                             ; 95D2
        plp                                     ; 95D4
        ora     ($16),y                         ; 95D5
        jsr     L2611                           ; 95D7
        jsr     L2706                           ; 95DA
L95DD:  jsr     L2711                           ; 95DD
        .byte   $20                             ; 95E0
        .byte   $1A                             ; 95E1
L95E2:  asl     $37,x                           ; 95E2
        .byte   $0B                             ; 95E4
L95E5:  .byte   $07                             ; 95E5
        .byte   $37                             ; 95E6
        .byte   $0F                             ; 95E7
L95E8:  .byte   $0F                             ; 95E8
        .byte   $0F                             ; 95E9
        .byte   $0F                             ; 95EA
L95EB:  .byte   $14                             ; 95EB
        and     $99,x                           ; 95EC
        .byte   $FF                             ; 95EE
        .byte   $14                             ; 95EF
        and     $00,x                           ; 95F0
        .byte   $FF                             ; 95F2
        .byte   $14                             ; 95F3
        and     $40,x                           ; 95F4
        .byte   $FF                             ; 95F6
        .byte   $14                             ; 95F7
        and     $60,x                           ; 95F8
        .byte   $FF                             ; 95FA
        beq     L95DD                           ; 95FB
        cpx     #$F0                            ; 95FD
L95FF:  beq     L95E2                           ; 95FF
        sbc     ($F1,x)                         ; 9601
        beq     L95E5                           ; 9603
        beq     L95E8                           ; 9605
        sbc     ($E1,x)                         ; 9607
        sbc     ($F1),y                         ; 9609
        .byte   $E2                             ; 960B
        .byte   $F2                             ; 960C
        .byte   $E3                             ; 960D
        .byte   $F2                             ; 960E
        sbc     $F5,x                           ; 960F
L9611:  sbc     $F5,x                           ; 9611
        .byte   $E3                             ; 9613
        .byte   $F2                             ; 9614
        cpx     $F3                             ; 9615
        .byte   $F2                             ; 9617
        .byte   $F2                             ; 9618
        .byte   $F3                             ; 9619
        .byte   $F3                             ; 961A
        .byte   $F2                             ; 961B
        .byte   $F4                             ; 961C
        .byte   $F3                             ; 961D
        sbc     $F2                             ; 961E
        .byte   $F2                             ; 9620
        .byte   $F2                             ; 9621
        .byte   $F2                             ; 9622
        .byte   $F2                             ; 9623
        .byte   $F4                             ; 9624
        .byte   $F2                             ; 9625
        .byte   $F4                             ; 9626
        ldy     $A4                             ; 9627
        ldy     $A4                             ; 9629
        sbc     ($F1),y                         ; 962B
        sbc     ($F1),y                         ; 962D
        beq     L9611                           ; 962F
        sbc     ($F0,x)                         ; 9631
        sbc     ($F1,x)                         ; 9633
        sbc     ($F1),y                         ; 9635
        .byte   $E3                             ; 9637
        .byte   $F2                             ; 9638
        .byte   $E3                             ; 9639
        .byte   $F2                             ; 963A
        .byte   $E2                             ; 963B
        .byte   $F2                             ; 963C
        cpx     $F3                             ; 963D
        cmp     $A4DD                           ; 963F
        ldy     $CE                             ; 9642
        dec     $DFCF,x                         ; 9644
        ldx     $AFBE                           ; 9647
        .byte   $BF                             ; 964A
        stx     L8F9E                           ; 964B
        .byte   $9F                             ; 964E
        bit     $E8E8                           ; 964F
        sed                                     ; 9652
        sbc     $E92C,y                         ; 9653
        sbc     $F6E7,y                         ; 9656
        .byte   $E7                             ; 9659
        dec     $E6                             ; 965A
        .byte   $F7                             ; 965C
        dec     $F7,x                           ; 965D
        bit     $2C2C                           ; 965F
L9662:  inc     $2C                             ; 9662
        bit     $2CF6                           ; 9664
        bit     $2CE7                           ; 9667
        bit     $2CF7                           ; 966A
        bit     $E02C                           ; 966D
        beq     L9662                           ; 9670
        sbc     ($F2,x)                         ; 9672
        .byte   $F4                             ; 9674
        .byte   $F3                             ; 9675
        sbc     $2C                             ; 9676
        bit     $2C2C                           ; 9678
        .byte   $80                             ; 967B
        bcc     L95FF                           ; 967C
        sta     ($82),y                         ; 967E
        .byte   $92                             ; 9680
        .byte   $83                             ; 9681
        .byte   $93                             ; 9682
        ldy     #$B0                            ; 9683
        lda     ($B1,x)                         ; 9685
        ldx     #$B2                            ; 9687
        .byte   $A3                             ; 9689
        .byte   $B3                             ; 968A
        sty     $94                             ; 968B
        sta     $95                             ; 968D
        stx     $96                             ; 968F
        .byte   $87                             ; 9691
        .byte   $97                             ; 9692
        ldy     $B4                             ; 9693
        lda     $B5                             ; 9695
        ldx     $B6                             ; 9697
        .byte   $A7                             ; 9699
        .byte   $B7                             ; 969A
        dey                                     ; 969B
        tya                                     ; 969C
        .byte   $89                             ; 969D
        sta     L9A8A,y                         ; 969E
        .byte   $8B                             ; 96A1
        .byte   $9B                             ; 96A2
        tay                                     ; 96A3
        clv                                     ; 96A4
        lda     #$B9                            ; 96A5
L96A7:  tax                                     ; 96A7
        tsx                                     ; 96A8
        .byte   $AB                             ; 96A9
        .byte   $BB                             ; 96AA
L96AB:  sty     L8D9C                           ; 96AB
        sta     $BCAC,x                         ; 96AE
        lda     $EABD                           ; 96B1
        .byte   $FA                             ; 96B4
        .byte   $CE                             ; 96B5
        .byte   $2E                             ; 96B6
L96B7:  dec     $CFDE                           ; 96B7
        .byte   $DF                             ; 96BA
        .byte   $FA                             ; 96BB
        .byte   $FB                             ; 96BC
        rol     $EEFE                           ; 96BD
        inc     $FFEF,x                         ; 96C0
        .byte   $E2                             ; 96C3
        and     $2D2D                           ; 96C4
        and     $2DF2                           ; 96C7
        and     $2D2D                           ; 96CA
        .byte   $E3                             ; 96CD
        and     $2D2D                           ; 96CE
        and     $E0F3                           ; 96D1
        bne     L96A7                           ; 96D4
        cmp     ($D0),y                         ; 96D6
        beq     L96AB                           ; 96D8
        cmp     ($D1),y                         ; 96DA
        cmp     ($E1),y                         ; 96DC
        cmp     ($D1),y                         ; 96DE
        cmp     ($D1),y                         ; 96E0
        sbc     ($D0),y                         ; 96E2
        bne     L96B7                           ; 96E4
        cmp     ($D1),y                         ; 96E6
        cmp     ($D1),y                         ; 96E8
        cmp     ($E4),y                         ; 96EA
        cpx     $F4                             ; 96EC
        .byte   $F4                             ; 96EE
        .byte   $F4                             ; 96EF
        .byte   $F4                             ; 96F0
        .byte   $F4                             ; 96F1
        .byte   $F4                             ; 96F2
        .byte   $F4                             ; 96F3
        .byte   $F4                             ; 96F4
        sbc     $E5                             ; 96F5
        inx                                     ; 96F7
        .byte   $EB                             ; 96F8
        .byte   $EB                             ; 96F9
        .byte   $EB                             ; 96FA
        .byte   $EB                             ; 96FB
        sed                                     ; 96FC
        .byte   $EB                             ; 96FD
        .byte   $EB                             ; 96FE
L96FF:  .byte   $EB                             ; 96FF
        .byte   $EB                             ; 9700
        sbc     #$EB                            ; 9701
        .byte   $EB                             ; 9703
        .byte   $EB                             ; 9704
        .byte   $EB                             ; 9705
        sbc     $F5E6,y                         ; 9706
        sbc     $F5,x                           ; 9709
        sbc     $F6,x                           ; 970B
L970D:  sbc     $F5,x                           ; 970D
        sbc     $F5,x                           ; 970F
        .byte   $E7                             ; 9711
        sbc     $F5,x                           ; 9712
        sbc     $F5,x                           ; 9714
        .byte   $F7                             ; 9716
        sbc     $F5,x                           ; 9717
        sbc     $F5,x                           ; 9719
        .byte   $EB                             ; 971B
        .byte   $EB                             ; 971C
        .byte   $EB                             ; 971D
        .byte   $EB                             ; 971E
        and     $2D2D                           ; 971F
        and     $C0C0                           ; 9722
        cpy     #$C0                            ; 9725
        cpx     $EBEB                           ; 9727
        .byte   $EB                             ; 972A
        .byte   $EB                             ; 972B
        .byte   $FC                             ; 972C
        .byte   $EB                             ; 972D
        .byte   $EB                             ; 972E
        .byte   $EB                             ; 972F
        .byte   $EB                             ; 9730
        sbc     $EBEB                           ; 9731
        .byte   $EB                             ; 9734
        .byte   $EB                             ; 9735
        sbc     $D1D1,x                         ; 9736
        cmp     ($D1),y                         ; 9739
        bne     L970D                           ; 973B
        cmp     ($D1),y                         ; 973D
        and     $2D2D                           ; 973F
        and     $D0D0                           ; 9742
        cmp     ($D1),y                         ; 9745
        cmp     ($D1),y                         ; 9747
        cmp     ($D1),y                         ; 9749
        cmp     $DCDC,x                         ; 974B
        cmp     $CDCC,x                         ; 974E
        cmp     $D7CC                           ; 9751
        dec     $D7                             ; 9754
        .byte   $C7                             ; 9756
        .byte   $D7                             ; 9757
        iny                                     ; 9758
        cmp     $D6C9,y                         ; 9759
        .byte   $D7                             ; 975C
        and     $D8D7                           ; 975D
        .byte   $D7                             ; 9760
        cmp     #$D9                            ; 9761
        dex                                     ; 9763
        .byte   $DA                             ; 9764
        sta     L8BDB,y                         ; 9765
        .byte   $9B                             ; 9768
        .byte   $89                             ; 9769
        .byte   $DB                             ; 976A
        sty     $94                             ; 976B
        sta     $95                             ; 976D
        lda     $A8BD                           ; 976F
        clv                                     ; 9772
        .byte   $FC                             ; 9773
        .byte   $9B                             ; 9774
        .byte   $89                             ; 9775
        .byte   $DB                             ; 9776
        .byte   $8B                             ; 9777
        .byte   $FC                             ; 9778
        .byte   $89                             ; 9779
        .byte   $DB                             ; 977A
        .byte   $80                             ; 977B
        bcc     L96FF                           ; 977C
        sta     ($82),y                         ; 977E
        .byte   $92                             ; 9780
        .byte   $83                             ; 9781
        .byte   $93                             ; 9782
        ldy     #$B0                            ; 9783
        lda     ($B1,x)                         ; 9785
        ldx     #$B2                            ; 9787
        .byte   $A3                             ; 9789
        .byte   $B3                             ; 978A
        sty     $94                             ; 978B
        sta     $95                             ; 978D
        stx     $96                             ; 978F
        .byte   $87                             ; 9791
        .byte   $97                             ; 9792
        ldy     $B4                             ; 9793
        lda     $B5                             ; 9795
        ldx     $B6                             ; 9797
        .byte   $A7                             ; 9799
        .byte   $B7                             ; 979A
        .byte   $FA                             ; 979B
        .byte   $FA                             ; 979C
        dec     $E4FE                           ; 979D
        .byte   $F4                             ; 97A0
        sbc     $F5                             ; 97A1
        dex                                     ; 97A3
        .byte   $DA                             ; 97A4
        tay                                     ; 97A5
        clv                                     ; 97A6
        tay                                     ; 97A7
        clv                                     ; 97A8
        tay                                     ; 97A9
        clv                                     ; 97AA
        tay                                     ; 97AB
        clv                                     ; 97AC
        lda     #$B9                            ; 97AD
        .byte   $CB                             ; 97AF
        .byte   $CB                             ; 97B0
        .byte   $D7                             ; 97B1
        .byte   $D7                             ; 97B2
        .byte   $CB                             ; 97B3
        .byte   $CB                             ; 97B4
        .byte   $DB                             ; 97B5
        .byte   $DB                             ; 97B6
        iny                                     ; 97B7
        cld                                     ; 97B8
        .byte   $CB                             ; 97B9
        .byte   $CB                             ; 97BA
        cmp     #$D9                            ; 97BB
        .byte   $CB                             ; 97BD
        .byte   $CB                             ; 97BE
        .byte   $FC                             ; 97BF
        rol     $2EFD                           ; 97C0
        rol     $2EFC                           ; 97C3
        sbc     $2EEC,x                         ; 97C6
        sbc     $2EF7                           ; 97C9
        cpx     $EDF7                           ; 97CC
        inx                                     ; 97CF
        sed                                     ; 97D0
        sbc     #$2C                            ; 97D1
        dec     $D6                             ; 97D3
        bit     $F92C                           ; 97D5
        .byte   $C7                             ; 97D8
L97D9:  bit     $D72C                           ; 97D9
        inc     $2C                             ; 97DC
        .byte   $E7                             ; 97DE
        inc     $F6,x                           ; 97DF
        inc     $F6,x                           ; 97E1
        ldy     $ADBC                           ; 97E3
        lda     $BAAA,x                         ; 97E6
        tax                                     ; 97E9
        tsx                                     ; 97EA
        tax                                     ; 97EB
        tsx                                     ; 97EC
        .byte   $AB                             ; 97ED
        .byte   $BB                             ; 97EE
        sty     L8D9C                           ; 97EF
        sta     $FAEA,x                         ; 97F2
        dec     $EAFE                           ; 97F5
        .byte   $FA                             ; 97F8
        dec     $CE2E                           ; 97F9
        dec     $DFCF,x                         ; 97FC
        .byte   $FA                             ; 97FF
        .byte   $FB                             ; 9800
        rol     $EEFE                           ; 9801
        inc     $FFEF,x                         ; 9804
        bne     L97D9                           ; 9807
L9809:  cmp     ($D1),y                         ; 9809
        cmp     ($D1),y                         ; 980B
        cmp     ($D1),y                         ; 980D
        .byte   $F2                             ; 980F
        .byte   $F2                             ; 9810
        .byte   $F3                             ; 9811
        .byte   $F3                             ; 9812
        .byte   $F3                             ; 9813
        .byte   $F3                             ; 9814
        .byte   $F3                             ; 9815
        .byte   $F3                             ; 9816
        cpy     #$F3                            ; 9817
        cpy     #$F3                            ; 9819
        .byte   $F3                             ; 981B
        cmp     ($F3,x)                         ; 981C
        cmp     ($E2,x)                         ; 981E
        .byte   $E2                             ; 9820
        .byte   $E3                             ; 9821
        .byte   $E3                             ; 9822
        .byte   $CD                             ; 9823
        .byte   $DD                             ; 9824
L9825:  cmp     $D1DD                           ; 9825
        cmp     ($D1),y                         ; 9828
        sbc     ($F5),y                         ; 982A
        sbc     $F5,x                           ; 982C
        sbc     $E0,x                           ; 982E
        bne     *-45                            ; 9830
        cmp     ($D0),y                         ; 9832
        beq     *-45                            ; 9834
        cmp     ($D0),y                         ; 9836
        bne     *-13                            ; 9838
        bne     *-120                           ; 983A
        stx     $86                             ; 983C
        stx     $87                             ; 983E
        .byte   $87                             ; 9840
        lda     $A5                             ; 9841
        lda     $A5                             ; 9843
        lda     $A5                             ; 9845
        lda     $A5                             ; 9847
        .byte   $B7                             ; 9849
        .byte   $B7                             ; 984A
        stx     $96,y                           ; 984B
        stx     $96,y                           ; 984D
        .byte   $D7                             ; 984F
        bit     $2C2C                           ; 9850
        bit     $2CE7                           ; 9853
        bit     $D8C8                           ; 9856
        cmp     #$D9                            ; 9859
        cmp     #$D9                            ; 985B
        .byte   $B7                             ; 985D
        dex                                     ; 985E
        inx                                     ; 985F
        sed                                     ; 9860
        sbc     #$F9                            ; 9861
        sbc     #$F9                            ; 9863
        .byte   $DA                             ; 9865
        .byte   $B7                             ; 9866
        lda     $A8                             ; 9867
        lda     $A9                             ; 9869
        clv                                     ; 986B
        lda     $B9                             ; 986C
        lda     $B4                             ; 986E
        ldy     $B4,x                           ; 9870
        ldy     $AB,x                           ; 9872
        .byte   $AB                             ; 9874
        .byte   $AB                             ; 9875
        .byte   $AB                             ; 9876
        .byte   $BB                             ; 9877
        .byte   $2F                             ; 9878
        .byte   $BB                             ; 9879
        .byte   $2F                             ; 987A
        .byte   $D3                             ; 987B
        .byte   $E2                             ; 987C
        .byte   $BB                             ; 987D
        .byte   $E3                             ; 987E
        .byte   $BB                             ; 987F
        cpx     $D4                             ; 9880
        .byte   $D4                             ; 9882
        .byte   $C2                             ; 9883
        .byte   $D2                             ; 9884
        .byte   $C3                             ; 9885
        .byte   $BB                             ; 9886
        cpy     $BB                             ; 9887
        cmp     $D5                             ; 9889
        .byte   $F2                             ; 988B
        .byte   $D3                             ; 988C
        .byte   $F3                             ; 988D
        .byte   $BB                             ; 988E
        .byte   $F4                             ; 988F
        .byte   $BB                             ; 9890
        .byte   $D4                             ; 9891
        .byte   $D4                             ; 9892
        sbc     $9E,x                           ; 9893
        .byte   $BB                             ; 9895
        .byte   $9F                             ; 9896
        .byte   $BB                             ; 9897
        stx     L8FE5                           ; 9898
        sty     $94,x                           ; 989B
        sty     $94,x                           ; 989D
        stx     $86                             ; 989F
        stx     $CB                             ; 98A1
        stx     $86                             ; 98A3
        .byte   $DB                             ; 98A5
        stx     $86                             ; 98A6
        cpy     L8686                           ; 98A8
        .byte   $DC                             ; 98AB
        stx     $86                             ; 98AC
        stx     $D6                             ; 98AE
        .byte   $87                             ; 98B0
        .byte   $D7                             ; 98B1
        bit     $E687                           ; 98B2
        bit     $BBE7                           ; 98B5
        .byte   $2F                             ; 98B8
        tax                                     ; 98B9
        tsx                                     ; 98BA
        sty     $C6,x                           ; 98BB
        sty     $C7,x                           ; 98BD
        inc     $94,x                           ; 98BF
        .byte   $F7                             ; 98C1
        sty     $2F,x                           ; 98C2
        .byte   $2F                             ; 98C4
        .byte   $B7                             ; 98C5
        .byte   $B7                             ; 98C6
        sty     $97,x                           ; 98C7
        .byte   $B7                             ; 98C9
        .byte   $B7                             ; 98CA
        .byte   $97                             ; 98CB
        sty     $97,x                           ; 98CC
        sty     $94,x                           ; 98CE
        .byte   $97                             ; 98D0
        sty     $97,x                           ; 98D1
        bit     $2C2C                           ; 98D3
        bit     L9497                           ; 98D6
        .byte   $B7                             ; 98D9
        .byte   $B7                             ; 98DA
        sty     $94,x                           ; 98DB
        .byte   $B7                             ; 98DD
        .byte   $B7                             ; 98DE
        bit     $2C2C                           ; 98DF
        bit     $D2C2                           ; 98E2
        .byte   $C3                             ; 98E5
        .byte   $D3                             ; 98E6
        cpy     $C1                             ; 98E7
        .byte   $C3                             ; 98E9
        .byte   $D3                             ; 98EA
        bit     $EC2C                           ; 98EB
        cpx     $ECEC                           ; 98EE
        bit     $2C2C                           ; 98F1
        cpx     $EC2C                           ; 98F4
        cpx     $EC2C                           ; 98F7
        bit     $D7D7                           ; 98FA
        cld                                     ; 98FD
        cld                                     ; 98FE
        cmp     $DAD9,y                         ; 98FF
        .byte   $DA                             ; 9902
        cmp     $D5,x                           ; 9903
        cmp     $D5,x                           ; 9905
        cmp     $D6,x                           ; 9907
        bit     $0E2C                           ; 9909
        plp                                     ; 990C
        .byte   $0F                             ; 990D
        and     #$2C                            ; 990E
        sbc     $BCAC                           ; 9910
        bit     $C4EC                           ; 9913
        cmp     ($EC,x)                         ; 9916
        bit     $C1C4                           ; 9918
        .byte   $C3                             ; 991B
        .byte   $D3                             ; 991C
        .byte   $C2                             ; 991D
        .byte   $D2                             ; 991E
        .byte   $C3                             ; 991F
        .byte   $D3                             ; 9920
        bit     $C3EC                           ; 9921
        .byte   $D3                             ; 9924
        cpx     L8C2C                           ; 9925
        .byte   $9C                             ; 9928
        sta     $AC9D                           ; 9929
        ldy     $BDAD,x                         ; 992C
        .byte   $D4                             ; 992F
        .byte   $D4                             ; 9930
        .byte   $D4                             ; 9931
        .byte   $D4                             ; 9932
        bit     $F1C0                           ; 9933
        sbc     ($F1),y                         ; 9936
        sbc     ($D0),y                         ; 9938
        bit     $F2E2                           ; 993A
        .byte   $E3                             ; 993D
        .byte   $F3                             ; 993E
        cpx     $F4                             ; 993F
        cpx     $F4                             ; 9941
        cpx     $F4                             ; 9943
        .byte   $E3                             ; 9945
        .byte   $F3                             ; 9946
        .byte   $DB                             ; 9947
        .byte   $DB                             ; 9948
        .byte   $DB                             ; 9949
        .byte   $DB                             ; 994A
        .byte   $DB                             ; 994B
        .byte   $DB                             ; 994C
        cld                                     ; 994D
        cld                                     ; 994E
        .byte   $9E                             ; 994F
        .byte   $9E                             ; 9950
        .byte   $9E                             ; 9951
        .byte   $9E                             ; 9952
        .byte   $9E                             ; 9953
        .byte   $9E                             ; 9954
        stx     L9E8F                           ; 9955
        .byte   $9E                             ; 9958
        .byte   $9F                             ; 9959
        .byte   $9E                             ; 995A
        stx     $96                             ; 995B
        .byte   $87                             ; 995D
        .byte   $97                             ; 995E
        bit     $2CCB                           ; 995F
        .byte   $CB                             ; 9962
        inc     $2C                             ; 9963
        .byte   $E7                             ; 9965
        bit     $F62C                           ; 9966
        bit     $F8F7                           ; 9969
        sbc     $F62C,y                         ; 996C
        bit     $F1C0                           ; 996F
        sbc     ($E8),y                         ; 9972
        sed                                     ; 9974
        inc     $2C                             ; 9975
        ldx     $B6                             ; 9977
        .byte   $A7                             ; 9979
        .byte   $B7                             ; 997A
        .byte   $C2                             ; 997B
        cpy     $C3                             ; 997C
        cmp     $D2                             ; 997E
        dec     $C7                             ; 9980
        .byte   $D2                             ; 9982
        .byte   $87                             ; 9983
        .byte   $87                             ; 9984
        lda     $A5                             ; 9985
        cpy     $CDDC                           ; 9987
        cmp     $FCEC,x                         ; 998A
        sbc     $C1FD                           ; 998D
        dec     $C6                             ; 9990
        .byte   $D2                             ; 9992
        bit     $C12C                           ; 9993
        cmp     ($2C,x)                         ; 9996
        cmp     ($C1,x)                         ; 9998
        dec     $2C                             ; 999A
        bit     $2CC1                           ; 999C
        bit     $2CC1                           ; 999F
        cmp     ($C6,x)                         ; 99A2
        cmp     ($C6,x)                         ; 99A4
        cmp     ($2C,x)                         ; 99A6
        cmp     ($C1,x)                         ; 99A8
        dec     $2C                             ; 99AA
        bit     $C12C                           ; 99AC
        .byte   $D4                             ; 99AF
        .byte   $D4                             ; 99B0
        .byte   $D4                             ; 99B1
        .byte   $D4                             ; 99B2
        cmp     ($2C,x)                         ; 99B3
        cmp     ($C1,x)                         ; 99B5
        .byte   $D2                             ; 99B7
        cmp     ($C7,x)                         ; 99B8
        cmp     ($C1,x)                         ; 99BA
        .byte   $D2                             ; 99BC
        .byte   $D2                             ; 99BD
        .byte   $C7                             ; 99BE
        cmp     #$C9                            ; 99BF
        bit     $C12C                           ; 99C1
        .byte   $D2                             ; 99C4
        cmp     $C8C7                           ; 99C5
        .byte   $C7                             ; 99C8
        .byte   $C7                             ; 99C9
        iny                                     ; 99CA
        cmp     #$CD                            ; 99CB
        bit     $C7C9                           ; 99CD
        .byte   $D2                             ; 99D0
        cmp     $2DCD                           ; 99D1
        and     $F32D                           ; 99D4
        and     $E32D                           ; 99D7
        and     $DBDB                           ; 99DA
        .byte   $DB                             ; 99DD
        .byte   $DB                             ; 99DE
        .byte   $D4                             ; 99DF
        .byte   $D4                             ; 99E0
        .byte   $D4                             ; 99E1
        .byte   $D4                             ; 99E2
        cmp     $D5,x                           ; 99E3
        dec     $D6,x                           ; 99E5
        dec     $CFDE                           ; 99E7
        .byte   $DF                             ; 99EA
        inc     $EFFE                           ; 99EB
        .byte   $FF                             ; 99EE
        .byte   $DB                             ; 99EF
        .byte   $DB                             ; 99F0
        .byte   $DB                             ; 99F1
        .byte   $DB                             ; 99F2
        .byte   $CB                             ; 99F3
        .byte   $CB                             ; 99F4
        .byte   $DB                             ; 99F5
        .byte   $DB                             ; 99F6
        inc     $EFFE                           ; 99F7
        .byte   $FF                             ; 99FA
L99FB:  lda     ($B1),y                         ; 99FB
        lda     ($B1),y                         ; 99FD
        .byte   $B2                             ; 99FF
        .byte   $03                             ; 9A00
        .byte   $B2                             ; 9A01
        .byte   $B2                             ; 9A02
        .byte   $B2                             ; 9A03
        .byte   $B2                             ; 9A04
        .byte   $B2                             ; 9A05
        .byte   $B2                             ; 9A06
        lda     ($B1),y                         ; 9A07
        lda     ($B2),y                         ; 9A09
        .byte   $B2                             ; 9A0B
        .byte   $B2                             ; 9A0C
        cmp     ($80,x)                         ; 9A0D
        .byte   $80                             ; 9A0F
        .byte   $B2                             ; 9A10
        .byte   $B2                             ; 9A11
        .byte   $B2                             ; 9A12
        .byte   $B2                             ; 9A13
        .byte   $B2                             ; 9A14
        .byte   $B2                             ; 9A15
        .byte   $B2                             ; 9A16
        .byte   $B2                             ; 9A17
        lda     ($B2),y                         ; 9A18
        brk                                     ; 9A1A
        .byte   $B3                             ; 9A1B
        .byte   $B3                             ; 9A1C
        .byte   $B3                             ; 9A1D
        .byte   $B3                             ; 9A1E
        .byte   $B3                             ; 9A1F
        .byte   $B3                             ; 9A20
        .byte   $B3                             ; 9A21
        .byte   $B3                             ; 9A22
        lda     ($B1),y                         ; 9A23
        lda     ($B1),y                         ; 9A25
        .byte   $B3                             ; 9A27
        lda     ($B1),y                         ; 9A28
        lda     ($B1),y                         ; 9A2A
        lda     ($02),y                         ; 9A2C
        .byte   $02                             ; 9A2E
        .byte   $02                             ; 9A2F
        .byte   $02                             ; 9A30
        .byte   $62                             ; 9A31
        .byte   $62                             ; 9A32
        .byte   $62                             ; 9A33
        .byte   $62                             ; 9A34
        .byte   $62                             ; 9A35
        .byte   $62                             ; 9A36
        ora     ($01,x)                         ; 9A37
        ora     ($03,x)                         ; 9A39
        .byte   $03                             ; 9A3B
        .byte   $03                             ; 9A3C
        .byte   $03                             ; 9A3D
        .byte   $23                             ; 9A3E
        .byte   $23                             ; 9A3F
        .byte   $23                             ; 9A40
        .byte   $23                             ; 9A41
        .byte   $23                             ; 9A42
        .byte   $03                             ; 9A43
        ora     ($41,x)                         ; 9A44
        .byte   $03                             ; 9A46
        .byte   $03                             ; 9A47
        .byte   $03                             ; 9A48
        .byte   $03                             ; 9A49
        .byte   $72                             ; 9A4A
        .byte   $72                             ; 9A4B
        .byte   $02                             ; 9A4C
        .byte   $32                             ; 9A4D
        .byte   $32                             ; 9A4E
        .byte   $02                             ; 9A4F
        .byte   $12                             ; 9A50
        lda     ($B1),y                         ; 9A51
        lda     ($B1),y                         ; 9A53
        lda     ($B1),y                         ; 9A55
        .byte   $C3                             ; 9A57
        lda     ($B1),y                         ; 9A58
        lda     ($03),y                         ; 9A5A
        .byte   $03                             ; 9A5C
        .byte   $03                             ; 9A5D
        .byte   $03                             ; 9A5E
        .byte   $03                             ; 9A5F
        .byte   $03                             ; 9A60
        .byte   $03                             ; 9A61
        .byte   $03                             ; 9A62
        lda     ($B3),y                         ; 9A63
        .byte   $B3                             ; 9A65
        .byte   $B3                             ; 9A66
        .byte   $B3                             ; 9A67
        .byte   $B3                             ; 9A68
        .byte   $B3                             ; 9A69
        .byte   $B3                             ; 9A6A
        .byte   $B3                             ; 9A6B
        .byte   $B3                             ; 9A6C
        .byte   $B3                             ; 9A6D
        .byte   $B3                             ; 9A6E
        .byte   $B3                             ; 9A6F
        .byte   $C3                             ; 9A70
        .byte   $C3                             ; 9A71
        .byte   $C3                             ; 9A72
        .byte   $C3                             ; 9A73
        .byte   $03                             ; 9A74
        .byte   $52                             ; 9A75
        .byte   $52                             ; 9A76
        .byte   $52                             ; 9A77
        .byte   $53                             ; 9A78
        eor     ($51),y                         ; 9A79
        eor     ($51),y                         ; 9A7B
        eor     ($63),y                         ; 9A7D
        .byte   $63                             ; 9A7F
        .byte   $02                             ; 9A80
        .byte   $02                             ; 9A81
        .byte   $02                             ; 9A82
        .byte   $02                             ; 9A83
        .byte   $52                             ; 9A84
        .byte   $B2                             ; 9A85
        .byte   $72                             ; 9A86
        sta     ($72),y                         ; 9A87
        .byte   $72                             ; 9A89
L9A8A:  .byte   $72                             ; 9A8A
        .byte   $B3                             ; 9A8B
        .byte   $B3                             ; 9A8C
        .byte   $B3                             ; 9A8D
        .byte   $B3                             ; 9A8E
        .byte   $03                             ; 9A8F
        .byte   $C3                             ; 9A90
        .byte   $C3                             ; 9A91
        .byte   $B3                             ; 9A92
        .byte   $B3                             ; 9A93
        .byte   $B3                             ; 9A94
        .byte   $B3                             ; 9A95
        .byte   $B3                             ; 9A96
        .byte   $B3                             ; 9A97
L9A98:  .byte   $03                             ; 9A98
        .byte   $03                             ; 9A99
        .byte   $B2                             ; 9A9A
        .byte   $B2                             ; 9A9B
        .byte   $B2                             ; 9A9C
        .byte   $B2                             ; 9A9D
        .byte   $B2                             ; 9A9E
        .byte   $B2                             ; 9A9F
        .byte   $B2                             ; 9AA0
        .byte   $B2                             ; 9AA1
        .byte   $B2                             ; 9AA2
        .byte   $B3                             ; 9AA3
        .byte   $02                             ; 9AA4
        .byte   $02                             ; 9AA5
        .byte   $02                             ; 9AA6
        .byte   $02                             ; 9AA7
        .byte   $C3                             ; 9AA8
        .byte   $C3                             ; 9AA9
        .byte   $B2                             ; 9AAA
        .byte   $B3                             ; 9AAB
        .byte   $B3                             ; 9AAC
        .byte   $B3                             ; 9AAD
        .byte   $B3                             ; 9AAE
        .byte   $B3                             ; 9AAF
        .byte   $B3                             ; 9AB0
        .byte   $C3                             ; 9AB1
        .byte   $B3                             ; 9AB2
        .byte   $B3                             ; 9AB3
        lda     ($B1),y                         ; 9AB4
        lda     ($01),y                         ; 9AB6
        ora     ($01,x)                         ; 9AB8
        ora     ($B2,x)                         ; 9ABA
        .byte   $B2                             ; 9ABC
        .byte   $62                             ; 9ABD
        ora     ($03,x)                         ; 9ABE
        .byte   $03                             ; 9AC0
        lda     ($B1),y                         ; 9AC1
        lda     ($B1),y                         ; 9AC3
        lda     ($B1),y                         ; 9AC5
        .byte   $B2                             ; 9AC7
        ora     ($B3,x)                         ; 9AC8
        .byte   $C3                             ; 9ACA
        .byte   $B3                             ; 9ACB
        .byte   $B3                             ; 9ACC
        .byte   $B3                             ; 9ACD
        .byte   $02                             ; 9ACE
        .byte   $B2                             ; 9ACF
        .byte   $B3                             ; 9AD0
        .byte   $B3                             ; 9AD1
        .byte   $B3                             ; 9AD2
        .byte   $C3                             ; 9AD3
        ora     ($03,x)                         ; 9AD4
        .byte   $03                             ; 9AD6
        .byte   $C3                             ; 9AD7
        cmp     ($C3,x)                         ; 9AD8
        .byte   $C3                             ; 9ADA
        lda     ($02),y                         ; 9ADB
        .byte   $C3                             ; 9ADD
        .byte   $03                             ; 9ADE
        .byte   $03                             ; 9ADF
        .byte   $02                             ; 9AE0
        .byte   $02                             ; 9AE1
        .byte   $02                             ; 9AE2
        .byte   $02                             ; 9AE3
        .byte   $02                             ; 9AE4
        .byte   $02                             ; 9AE5
        .byte   $02                             ; 9AE6
        .byte   $02                             ; 9AE7
        .byte   $72                             ; 9AE8
        .byte   $02                             ; 9AE9
        .byte   $02                             ; 9AEA
        .byte   $02                             ; 9AEB
        .byte   $02                             ; 9AEC
        .byte   $02                             ; 9AED
        .byte   $02                             ; 9AEE
        .byte   $02                             ; 9AEF
        .byte   $02                             ; 9AF0
        ora     ($01,x)                         ; 9AF1
        lda     ($62),y                         ; 9AF3
        .byte   $B2                             ; 9AF5
        cmp     ($C1,x)                         ; 9AF6
        .byte   $B2                             ; 9AF8
        .byte   $C3                             ; 9AF9
        cmp     ($00,x)                         ; 9AFA
        brk                                     ; 9AFC
        brk                                     ; 9AFD
        brk                                     ; 9AFE
        ora     ($00,x)                         ; 9AFF
        .byte   $0C                             ; 9B01
        ora     $0302                           ; 9B02
        asl     $050C                           ; 9B05
        ora     $05                             ; 9B08
        ora     $05                             ; 9B0A
        ora     $05                             ; 9B0C
        .byte   $14                             ; 9B0E
        ora     $05                             ; 9B0F
        ora     $13                             ; 9B11
        .byte   $04                             ; 9B13
        ora     #$0F                            ; 9B14
        asl     a                               ; 9B16
        asl     $07                             ; 9B17
        .byte   $02                             ; 9B19
        ora     $0707,x                         ; 9B1A
        .byte   $02                             ; 9B1D
        ora     $1E07,x                         ; 9B1E
        .byte   $02                             ; 9B21
        ora     $0710,x                         ; 9B22
        .byte   $02                             ; 9B25
        ora     $6260,x                         ; 9B26
        adc     ($63,x)                         ; 9B29
        lsr     a                               ; 9B2B
        lsr     a                               ; 9B2C
        bit     $092C                           ; 9B2D
        ora     #$09                            ; 9B30
        ora     #$04                            ; 9B32
        asl     a                               ; 9B34
        .byte   $0F                             ; 9B35
        asl     a                               ; 9B36
        .byte   $0F                             ; 9B37
        asl     a                               ; 9B38
        .byte   $0F                             ; 9B39
        asl     a                               ; 9B3A
        ora     #$0A                            ; 9B3B
        .byte   $0F                             ; 9B3D
        asl     a                               ; 9B3E
        asl     $1E                             ; 9B3F
        .byte   $02                             ; 9B41
        ora     $1615,x                         ; 9B42
        .byte   $17                             ; 9B45
        clc                                     ; 9B46
        sta     L9D9D,x                         ; 9B47
        sta     $0A09,x                         ; 9B4A
        ora     #$0A                            ; 9B4D
        .byte   $0F                             ; 9B4F
        ora     #$0F                            ; 9B50
        asl     a                               ; 9B52
        .byte   $0F                             ; 9B53
        ora     #$0F                            ; 9B54
        ora     #$09                            ; 9B56
        ora     #$0F                            ; 9B58
        .byte   $09                             ; 9B5A
L9B5B:  ora     #$09                            ; 9B5B
        ora     #$0A                            ; 9B5D
        .byte   $04                             ; 9B5F
        ora     #$0F                            ; 9B60
        ora     #$09                            ; 9B62
        ora     #$0F                            ; 9B64
        asl     a                               ; 9B66
        ora     $14                             ; 9B67
        ora     $05                             ; 9B69
        ora     $13                             ; 9B6B
        ora     $05                             ; 9B6D
        cli                                     ; 9B6F
        lsr     $59,x                           ; 9B70
        .byte   $57                             ; 9B72
        .byte   $54                             ; 9B73
        .byte   $14                             ; 9B74
        .byte   $54                             ; 9B75
        .byte   $54                             ; 9B76
        .byte   $54                             ; 9B77
        .byte   $13                             ; 9B78
        .byte   $54                             ; 9B79
        .byte   $54                             ; 9B7A
        jsr     L2122                           ; 9B7B
        .byte   $23                             ; 9B7E
        bit     $26                             ; 9B7F
        and     $27                             ; 9B81
        rol     a                               ; 9B83
        rol     a                               ; 9B84
        .byte   $2B                             ; 9B85
        .byte   $2B                             ; 9B86
        plp                                     ; 9B87
        plp                                     ; 9B88
        and     #$29                            ; 9B89
        .byte   $3C                             ; 9B8B
        .byte   $3C                             ; 9B8C
        and     $3D3D,x                         ; 9B8D
        and     $3D3D,x                         ; 9B90
        and     $3E3D,x                         ; 9B93
        rol     $4932,x                         ; 9B96
        eor     #$49                            ; 9B99
        eor     #$33                            ; 9B9B
        eor     #$49                            ; 9B9D
        eor     #$49                            ; 9B9F
        .byte   $34                             ; 9BA1
        eor     #$49                            ; 9BA2
        eor     #$49                            ; 9BA4
        and     $4B,x                           ; 9BA6
        pha                                     ; 9BA8
        pha                                     ; 9BA9
        pha                                     ; 9BAA
        pha                                     ; 9BAB
        jmp     L4848                           ; 9BAC

; ----------------------------------------------------------------------------
        pha                                     ; 9BAF
        pha                                     ; 9BB0
        eor     L4848                           ; 9BB1
        pha                                     ; 9BB4
        pha                                     ; 9BB5
        lsr     $3A36                           ; 9BB6
        .byte   $3B                             ; 9BB9
        .byte   $3B                             ; 9BBA
        .byte   $3A                             ; 9BBB
        .byte   $37                             ; 9BBC
        .byte   $3B                             ; 9BBD
        .byte   $3B                             ; 9BBE
        .byte   $3B                             ; 9BBF
        .byte   $3B                             ; 9BC0
        sec                                     ; 9BC1
        .byte   $3B                             ; 9BC2
        .byte   $3B                             ; 9BC3
        .byte   $3B                             ; 9BC4
        .byte   $3B                             ; 9BC5
        and     $508D,y                         ; 9BC6
        .byte   $4F                             ; 9BC9
        .byte   $4F                             ; 9BCA
        bvc     L9B5B                           ; 9BCB
        .byte   $4F                             ; 9BCD
        .byte   $4F                             ; 9BCE
        .byte   $4F                             ; 9BCF
        .byte   $4F                             ; 9BD0
        .byte   $8F                             ; 9BD1
        .byte   $4F                             ; 9BD2
        .byte   $4F                             ; 9BD3
        .byte   $4F                             ; 9BD4
        .byte   $4F                             ; 9BD5
        .byte   $8B                             ; 9BD6
        .byte   $43                             ; 9BD7
        .byte   $47                             ; 9BD8
        .byte   $47                             ; 9BD9
        .byte   $47                             ; 9BDA
        .byte   $47                             ; 9BDB
        .byte   $44                             ; 9BDC
        .byte   $47                             ; 9BDD
        .byte   $47                             ; 9BDE
        .byte   $47                             ; 9BDF
        .byte   $47                             ; 9BE0
        eor     $47                             ; 9BE1
        .byte   $47                             ; 9BE3
        .byte   $47                             ; 9BE4
        .byte   $47                             ; 9BE5
        lsr     $3F                             ; 9BE6
        pha                                     ; 9BE8
        pha                                     ; 9BE9
        pha                                     ; 9BEA
        pha                                     ; 9BEB
        rti                                     ; 9BEC

; ----------------------------------------------------------------------------
        pha                                     ; 9BED
        pha                                     ; 9BEE
        pha                                     ; 9BEF
        pha                                     ; 9BF0
        eor     ($48,x)                         ; 9BF1
        pha                                     ; 9BF3
        pha                                     ; 9BF4
        pha                                     ; 9BF5
        .byte   $42                             ; 9BF6
        .byte   $3A                             ; 9BF7
        .byte   $3A                             ; 9BF8
        .byte   $3B                             ; 9BF9
        .byte   $3B                             ; 9BFA
        bvc     L9C4D                           ; 9BFB
        .byte   $4F                             ; 9BFD
        .byte   $4F                             ; 9BFE
        .byte   $3B                             ; 9BFF
        .byte   $3B                             ; 9C00
        .byte   $3B                             ; 9C01
        .byte   $3B                             ; 9C02
        .byte   $4F                             ; 9C03
        .byte   $4F                             ; 9C04
        .byte   $4F                             ; 9C05
        .byte   $4F                             ; 9C06
        pha                                     ; 9C07
        pha                                     ; 9C08
        pha                                     ; 9C09
        pha                                     ; 9C0A
        .byte   $47                             ; 9C0B
        .byte   $47                             ; 9C0C
        .byte   $47                             ; 9C0D
        .byte   $47                             ; 9C0E
        lsr     a                               ; 9C0F
        lsr     a                               ; 9C10
        lsr     a                               ; 9C11
        lsr     a                               ; 9C12
        eor     #$49                            ; 9C13
        eor     #$49                            ; 9C15
        rol     $2F30                           ; 9C17
        and     ($2C),y                         ; 9C1A
        bit     $4949                           ; 9C1C
        eor     #$49                            ; 9C1F
        bit     $2C2C                           ; 9C21
        eor     #$2C                            ; 9C24
        eor     #$49                            ; 9C26
        bit     $2C49                           ; 9C28
        and     $2D2D                           ; 9C2B
        and     $5151                           ; 9C2E
        eor     ($51),y                         ; 9C31
        eor     #$13                            ; 9C33
        eor     #$49                            ; 9C35
        .byte   $BB                             ; 9C37
        .byte   $BB                             ; 9C38
        tsx                                     ; 9C39
        tsx                                     ; 9C3A
        tsx                                     ; 9C3B
        tsx                                     ; 9C3C
        tsx                                     ; 9C3D
        tsx                                     ; 9C3E
        .byte   $1F                             ; 9C3F
        .byte   $1F                             ; 9C40
        .byte   $1F                             ; 9C41
        dec     $1F                             ; 9C42
        .byte   $1F                             ; 9C44
        .byte   $C7                             ; 9C45
        .byte   $1F                             ; 9C46
        .byte   $CB                             ; 9C47
        .byte   $CB                             ; 9C48
        eor     $2A5D,x                         ; 9C49
        rol     a                               ; 9C4C
L9C4D:  .byte   $2B                             ; 9C4D
        .byte   $2B                             ; 9C4E
        .byte   $CB                             ; 9C4F
        .byte   $CB                             ; 9C50
        .byte   $CB                             ; 9C51
        eor     $2ACB,x                         ; 9C52
        .byte   $CB                             ; 9C55
        .byte   $2B                             ; 9C56
        .byte   $CB                             ; 9C57
        .byte   $CB                             ; 9C58
        eor     $CB24,x                         ; 9C59
        .byte   $CB                             ; 9C5C
        .byte   $12                             ; 9C5D
        .byte   $FF                             ; 9C5E
        .byte   $CB                             ; 9C5F
        .byte   $CB                             ; 9C60
        rol     $5D                             ; 9C61
        and     #$29                            ; 9C63
        .byte   $5B                             ; 9C65
        .byte   $5F                             ; 9C66
        and     #$29                            ; 9C67
        lsr     $2A5B,x                         ; 9C69
        .byte   $CB                             ; 9C6C
        .byte   $2B                             ; 9C6D
        .byte   $CB                             ; 9C6E
        .byte   $CB                             ; 9C6F
        .byte   $CB                             ; 9C70
        eor     $CBCB,x                         ; 9C71
        .byte   $54                             ; 9C74
        .byte   $CB                             ; 9C75
        .byte   $54                             ; 9C76
        .byte   $54                             ; 9C77
        .byte   $54                             ; 9C78
        .byte   $54                             ; 9C79
        .byte   $54                             ; 9C7A
        .byte   $54                             ; 9C7B
        .byte   $CB                             ; 9C7C
        .byte   $54                             ; 9C7D
        .byte   $CB                             ; 9C7E
        .byte   $CB                             ; 9C7F
        .byte   $54                             ; 9C80
        .byte   $CB                             ; 9C81
        .byte   $CB                             ; 9C82
        .byte   $54                             ; 9C83
        .byte   $54                             ; 9C84
        .byte   $CB                             ; 9C85
        .byte   $CB                             ; 9C86
        .byte   $54                             ; 9C87
        .byte   $CB                             ; 9C88
        .byte   $CB                             ; 9C89
        .byte   $CB                             ; 9C8A
        .byte   $CB                             ; 9C8B
        eor     $CB,x                           ; 9C8C
        eor     $55,x                           ; 9C8E
        eor     $55,x                           ; 9C90
        eor     $55,x                           ; 9C92
        .byte   $CB                             ; 9C94
        eor     $CB,x                           ; 9C95
        .byte   $CB                             ; 9C97
        eor     $CB,x                           ; 9C98
        .byte   $CB                             ; 9C9A
        eor     $55,x                           ; 9C9B
        .byte   $CB                             ; 9C9D
        .byte   $CB                             ; 9C9E
        eor     $CB,x                           ; 9C9F
        .byte   $CB                             ; 9CA1
        .byte   $CB                             ; 9CA2
        .byte   $CB                             ; 9CA3
        lsr     $5D,x                           ; 9CA4
        .byte   $57                             ; 9CA6
        cli                                     ; 9CA7
        lsr     $59,x                           ; 9CA8
        .byte   $57                             ; 9CAA
        cli                                     ; 9CAB
        .byte   $CB                             ; 9CAC
        eor     $2A5D,y                         ; 9CAD
        lsr     $2B,x                           ; 9CB0
        .byte   $57                             ; 9CB2
        cli                                     ; 9CB3
        rol     a                               ; 9CB4
        eor     $522B,y                         ; 9CB5
        .byte   $52                             ; 9CB8
        .byte   $53                             ; 9CB9
        .byte   $53                             ; 9CBA
        .byte   $53                             ; 9CBB
        .byte   $53                             ; 9CBC
        .byte   $53                             ; 9CBD
        .byte   $53                             ; 9CBE
        lsr     a                               ; 9CBF
        lsr     a                               ; 9CC0
        lsr     a                               ; 9CC1
        lsr     a                               ; 9CC2
        ora     $8C                             ; 9CC3
        sty     $1F05                           ; 9CC5
        .byte   $1F                             ; 9CC8
        .byte   $1F                             ; 9CC9
        .byte   $1F                             ; 9CCA
        .byte   $CB                             ; 9CCB
        lsr     $CB,x                           ; 9CCC
        .byte   $57                             ; 9CCE
        cli                                     ; 9CCF
        .byte   $CB                             ; 9CD0
        eor     $20CB,y                         ; 9CD1
        .byte   $22                             ; 9CD4
        .byte   $CB                             ; 9CD5
        .byte   $CB                             ; 9CD6
        rol     a                               ; 9CD7
        and     $2B                             ; 9CD8
        plp                                     ; 9CDA
        .byte   $27                             ; 9CDB
        rol     a                               ; 9CDC
        .byte   $5A                             ; 9CDD
        .byte   $2B                             ; 9CDE
        .byte   $3C                             ; 9CDF
        .byte   $3C                             ; 9CE0
        rol     L833E,x                         ; 9CE1
        .byte   $83                             ; 9CE4
        sty     $84                             ; 9CE5
        sty     $84                             ; 9CE7
        sty     $84                             ; 9CE9
        .byte   $7B                             ; 9CEB
        .byte   $83                             ; 9CEC
        .byte   $7B                             ; 9CED
        sty     $7C                             ; 9CEE
        sty     $84                             ; 9CF0
        sty     $89                             ; 9CF2
        .byte   $89                             ; 9CF4
        sty     $84                             ; 9CF5
        .byte   $89                             ; 9CF7
        .byte   $89                             ; 9CF8
        .byte   $7B                             ; 9CF9
        sty     $7F                             ; 9CFA
        sta     ($80,x)                         ; 9CFC
        .byte   $82                             ; 9CFE
        .byte   $89                             ; 9CFF
        .byte   $89                             ; 9D00
        .byte   $80                             ; 9D01
        .byte   $82                             ; 9D02
        .byte   $89                             ; 9D03
        .byte   $89                             ; 9D04
        .byte   $7B                             ; 9D05
        .byte   $82                             ; 9D06
        .byte   $7C                             ; 9D07
        ror     $7E7E,x                         ; 9D08
        pla                                     ; 9D0B
        sta     ($8A,x)                         ; 9D0C
        .byte   $82                             ; 9D0E
        pla                                     ; 9D0F
        pla                                     ; 9D10
        adc     $696D                           ; 9D11
        pla                                     ; 9D14
        ror     a                               ; 9D15
        pla                                     ; 9D16
        .byte   $6B                             ; 9D17
        pla                                     ; 9D18
        jmp     (L686D)                         ; 9D19

; ----------------------------------------------------------------------------
        pla                                     ; 9D1C
        pla                                     ; 9D1D
        ror     $6968                           ; 9D1E
        adc     $796A                           ; 9D21
        jmp     (L7979)                         ; 9D24

; ----------------------------------------------------------------------------
        pla                                     ; 9D27
        pla                                     ; 9D28
        adc     $756D                           ; 9D29
        ror     $1F,x                           ; 9D2C
        .byte   $1F                             ; 9D2E
        .byte   $77                             ; 9D2F
        sei                                     ; 9D30
L9D31:  .byte   $1F                             ; 9D31
        .byte   $1F                             ; 9D32
        .byte   $1F                             ; 9D33
        .byte   $1F                             ; 9D34
        adc     $6879,y                         ; 9D35
        pla                                     ; 9D38
        ror     $1F68                           ; 9D39
        bit     $2C1F                           ; 9D3C
        bit     $2C1F                           ; 9D3F
        .byte   $1F                             ; 9D42
        adc     #$68                            ; 9D43
        ror     a                               ; 9D45
        adc     $796C                           ; 9D46
        adc     $6879,y                         ; 9D49
        adc     #$68                            ; 9D4C
        ror     a                               ; 9D4E
        pla                                     ; 9D4F
        .byte   $6B                             ; 9D50
        adc     L8A6C                           ; 9D51
        .byte   $83                             ; 9D54
        txa                                     ; 9D55
        sty     $7C                             ; 9D56
        .byte   $83                             ; 9D58
        sty     $84                             ; 9D59
        pla                                     ; 9D5B
        pla                                     ; 9D5C
        .byte   $6F                             ; 9D5D
        bvs     L9DC8                           ; 9D5E
        pla                                     ; 9D60
        .byte   $6F                             ; 9D61
        ror     $6868                           ; 9D62
        ror     $6970                           ; 9D65
        adc     ($6A),y                         ; 9D68
        .byte   $73                             ; 9D6A
        .byte   $72                             ; 9D6B
        adc     #$74                            ; 9D6C
        ror     a                               ; 9D6E
L9D6F:  adc     L7979,y                         ; 9D6F
        adc     $6260,y                         ; 9D72
        adc     ($63,x)                         ; 9D75
        .byte   $64                             ; 9D77
        ror     $65                             ; 9D78
        .byte   $67                             ; 9D7A
        pla                                     ; 9D7B
        txa                                     ; 9D7C
        pla                                     ; 9D7D
        txa                                     ; 9D7E
        pla                                     ; 9D7F
        adc     $7968,y                         ; 9D80
        pla                                     ; 9D83
        .byte   $79                             ; 9D84
L9D85:  pla                                     ; 9D85
        pla                                     ; 9D86
        .byte   $79                             ; 9D87
        .byte   $79                             ; 9D88
L9D89:  pla                                     ; 9D89
        pla                                     ; 9D8A
        sta     $85                             ; 9D8B
        .byte   $86                             ; 9D8D
L9D8E:  stx     $87                             ; 9D8E
L9D90:  dey                                     ; 9D90
        .byte   $87                             ; 9D91
        dey                                     ; 9D92
        .byte   $86                             ; 9D93
L9D94:  dey                                     ; 9D94
        stx     $88                             ; 9D95
        .byte   $87                             ; 9D97
        stx     $87                             ; 9D98
        stx     $86                             ; 9D9A
        .byte   $86                             ; 9D9C
L9D9D:  stx     $86                             ; 9D9D
        bcc     L9D31                           ; 9D9F
        sta     ($91),y                         ; 9DA1
        .byte   $92                             ; 9DA3
        .byte   $92                             ; 9DA4
        .byte   $93                             ; 9DA5
        .byte   $93                             ; 9DA6
        .byte   $97                             ; 9DA7
L9DA8:  sta     L9A98,y                         ; 9DA8
        .byte   $92                             ; 9DAB
        plp                                     ; 9DAC
        .byte   $93                             ; 9DAD
        .byte   $93                             ; 9DAE
        .byte   $92                             ; 9DAF
        and     #$93                            ; 9DB0
        .byte   $93                             ; 9DB2
        eor     #$49                            ; 9DB3
        eor     #$2D                            ; 9DB5
        .byte   $9B                             ; 9DB7
        .byte   $9C                             ; 9DB8
        .byte   $93                             ; 9DB9
        .byte   $93                             ; 9DBA
        .byte   $95                             ; 9DBB
L9DBC:  stx     $1F,y                           ; 9DBC
L9DBE:  .byte   $1F                             ; 9DBE
        lda     #$AA                            ; 9DBF
        .byte   $AB                             ; 9DC1
        ldy     L9F9F                           ; 9DC2
        .byte   $AF                             ; 9DC5
        .byte   $AF                             ; 9DC6
        .byte   $B9                             ; 9DC7
L9DC8:  lda     $1111,y                         ; 9DC8
        adc     $497D,x                         ; 9DCB
        eor     #$90                            ; 9DCE
        bcc     L9D6F                           ; 9DD0
        sta     L909D,x                         ; 9DD2
        sta     L9090,x                         ; 9DD5
        sta     L9D90,x                         ; 9DD8
        .byte   $93                             ; 9DDB
        .byte   $93                             ; 9DDC
        tay                                     ; 9DDD
        tay                                     ; 9DDE
        tay                                     ; 9DDF
        tay                                     ; 9DE0
        clv                                     ; 9DE1
        clv                                     ; 9DE2
        .byte   $1F                             ; 9DE3
        .byte   $1F                             ; 9DE4
        .byte   $12                             ; 9DE5
        .byte   $12                             ; 9DE6
        sta     L909D,x                         ; 9DE7
        bcc     L9D8E                           ; 9DEA
        ldy     #$A3                            ; 9DEC
        lda     ($A4,x)                         ; 9DEE
        ldx     $A5                             ; 9DF0
        .byte   $A7                             ; 9DF2
        bcc     L9D85                           ; 9DF3
        bcc     L9D94                           ; 9DF5
        bcc     L9D89                           ; 9DF7
        sta     L9090,x                         ; 9DF9
        .byte   $9E                             ; 9DFC
        bcc     L9D9D                           ; 9DFD
        .byte   $7B                             ; 9DFF
        sta     ($7B,x)                         ; 9E00
        .byte   $82                             ; 9E02
        .byte   $54                             ; 9E03
        .byte   $54                             ; 9E04
        .byte   $CB                             ; 9E05
        .byte   $54                             ; 9E06
        .byte   $9E                             ; 9E07
        bcc     L9DA8                           ; 9E08
        bcc     L9DBE                           ; 9E0A
        .byte   $B2                             ; 9E0C
        bcs     L9DBC                           ; 9E0D
        lda     $1F,x                           ; 9E0F
        .byte   $B3                             ; 9E11
        sty     $B2,x                           ; 9E12
        .byte   $B2                             ; 9E14
        ldx     $1FB1                           ; 9E15
        ldy     $94,x                           ; 9E18
        .byte   $B7                             ; 9E1A
        sta     L909D,x                         ; 9E1B
        sta     $2C1F,x                         ; 9E1E
        bit     $2C2C                           ; 9E21
        .byte   $1F                             ; 9E24
        bit     $BE2C                           ; 9E25
        iny                                     ; 9E28
        .byte   $1F                             ; 9E29
        cmp     #$C8                            ; 9E2A
        .byte   $BF                             ; 9E2C
        dex                                     ; 9E2D
        .byte   $1F                             ; 9E2E
        cpy     #$1F                            ; 9E2F
        .byte   $1F                             ; 9E31
        .byte   $1F                             ; 9E32
        .byte   $1F                             ; 9E33
        .byte   $C2                             ; 9E34
        .byte   $1F                             ; 9E35
        .byte   $1F                             ; 9E36
        .byte   $CF                             ; 9E37
        .byte   $CF                             ; 9E38
        cld                                     ; 9E39
        .byte   $DF                             ; 9E3A
        inc     $FEFE,x                         ; 9E3B
        inc     $1FBB,x                         ; 9E3E
        tsx                                     ; 9E41
        .byte   $BB                             ; 9E42
        .byte   $1F                             ; 9E43
        .byte   $BB                             ; 9E44
        .byte   $BB                             ; 9E45
        tsx                                     ; 9E46
        .byte   $1F                             ; 9E47
        .byte   $1F                             ; 9E48
        cmp     $1F                             ; 9E49
        .byte   $1F                             ; 9E4B
        .byte   $1F                             ; 9E4C
        .byte   $1F                             ; 9E4D
        cpy     $8A                             ; 9E4E
        txa                                     ; 9E50
        txa                                     ; 9E51
L9E52:  txa                                     ; 9E52
        txa                                     ; 9E53
        txa                                     ; 9E54
        txa                                     ; 9E55
        txa                                     ; 9E56
        adc     $2C2C,y                         ; 9E57
        bit     L9D90                           ; 9E5A
        sta     L9D9D,x                         ; 9E5D
        sta     L9D9D,x                         ; 9E60
        cpx     #$1F                            ; 9E63
        cpx     #$1F                            ; 9E65
        .byte   $1F                             ; 9E67
L9E68:  .byte   $1F                             ; 9E68
        bit     $E02C                           ; 9E69
        sbc     ($E0,x)                         ; 9E6C
        cpx     #$E1                            ; 9E6E
        beq     L9E52                           ; 9E70
        cpx     #$E1                            ; 9E72
        sbc     $E0                             ; 9E74
        cpx     #$E6                            ; 9E76
        inx                                     ; 9E78
        sbc     ($E5,x)                         ; 9E79
        .byte   $54                             ; 9E7B
        .byte   $54                             ; 9E7C
        .byte   $54                             ; 9E7D
        bit     $E01F                           ; 9E7E
        .byte   $1F                             ; 9E81
        cpx     #$90                            ; 9E82
        bcc     L9E68                           ; 9E84
        .byte   $E2                             ; 9E86
        sbc     ($E0,x)                         ; 9E87
        cpx     #$E0                            ; 9E89
        eor     #$49                            ; 9E8B
        eor     #$F6                            ; 9E8D
L9E8F:  bvc     L9EE1                           ; 9E8F
        ora     $05                             ; 9E91
        sbc     $F9F9,y                         ; 9E93
        sbc     $C2C2,y                         ; 9E96
        .byte   $FA                             ; 9E99
        .byte   $FA                             ; 9E9A
        sbc     $FDFD,x                         ; 9E9B
        sbc     $F649,x                         ; 9E9E
        sed                                     ; 9EA1
        sed                                     ; 9EA2
        sed                                     ; 9EA3
        sed                                     ; 9EA4
        .byte   $FA                             ; 9EA5
        .byte   $FA                             ; 9EA6
        sbc     $FDD4,x                         ; 9EA7
        cmp     ($52,x)                         ; 9EAA
        .byte   $52                             ; 9EAC
        ora     $05                             ; 9EAD
        ldx     $B6,y                           ; 9EAF
L9EB1:  .byte   $1F                             ; 9EB1
        .byte   $1F                             ; 9EB2
        bit     $2C2C                           ; 9EB3
        bit     $C0C0                           ; 9EB6
        cmp     ($C1,x)                         ; 9EB9
        cpx     $F2EE                           ; 9EBB
        .byte   $EF                             ; 9EBE
        beq     L9EB1                           ; 9EBF
        sbc     ($F5),y                         ; 9EC1
        .byte   $F3                             ; 9EC3
        .byte   $F5                             ; 9EC4
L9EC5:  .byte   $F4                             ; 9EC5
        .byte   $F4                             ; 9EC6
        lda     $B9B9,y                         ; 9EC7
        lda     $DDDD,y                         ; 9ECA
        .byte   $CF                             ; 9ECD
        .byte   $CF                             ; 9ECE
        cmp     $D5,x                           ; 9ECF
        dec     $D7,x                           ; 9ED1
        cpx     #$E0                            ; 9ED3
        cpx     #$E0                            ; 9ED5
        cpx     #$E0                            ; 9ED7
        cpx     #$1F                            ; 9ED9
        cpx     #$E0                            ; 9EDB
        .byte   $1F                             ; 9EDD
        cpx     #$E0                            ; 9EDE
        .byte   $E0                             ; 9EE0
L9EE1:  .byte   $1F                             ; 9EE1
        .byte   $1F                             ; 9EE2
        cmp     $D5,x                           ; 9EE3
        cmp     $D5,x                           ; 9EE5
        .byte   $CF                             ; 9EE7
        .byte   $CF                             ; 9EE8
        dec     $DECE                           ; 9EE9
        .byte   $DC                             ; 9EEC
        .byte   $DA                             ; 9EED
        .byte   $DB                             ; 9EEE
        .byte   $D3                             ; 9EEF
        .byte   $D3                             ; 9EF0
        .byte   $D3                             ; 9EF1
        .byte   $D3                             ; 9EF2
        bne     L9EC5                           ; 9EF3
        cmp     ($D1),y                         ; 9EF5
        sbc     $EDED                           ; 9EF7
        .byte   $ED                             ; 9EFA
L9EFB:  brk                                     ; 9EFB
        brk                                     ; 9EFC
        brk                                     ; 9EFD
        brk                                     ; 9EFE
        brk                                     ; 9EFF
        brk                                     ; 9F00
        brk                                     ; 9F01
        ora     ($00,x)                         ; 9F02
        brk                                     ; 9F04
        brk                                     ; 9F05
        brk                                     ; 9F06
        brk                                     ; 9F07
        brk                                     ; 9F08
        brk                                     ; 9F09
        brk                                     ; 9F0A
L9F0B:  brk                                     ; 9F0B
        ora     ($01,x)                         ; 9F0C
        ora     ($03,x)                         ; 9F0E
        ora     ($01,x)                         ; 9F10
        .byte   $03                             ; 9F12
        ora     ($01,x)                         ; 9F13
        ora     ($01,x)                         ; 9F15
        .byte   $03                             ; 9F17
        .byte   $03                             ; 9F18
        ora     ($01,x)                         ; 9F19
        brk                                     ; 9F1B
        ora     ($01,x)                         ; 9F1C
        brk                                     ; 9F1E
        .byte   $03                             ; 9F1F
        .byte   $03                             ; 9F20
        .byte   $03                             ; 9F21
        brk                                     ; 9F22
        ora     ($01,x)                         ; 9F23
        ora     ($01,x)                         ; 9F25
        ora     ($01,x)                         ; 9F27
        ora     ($01,x)                         ; 9F29
        ora     ($00,x)                         ; 9F2B
        brk                                     ; 9F2D
        brk                                     ; 9F2E
        brk                                     ; 9F2F
        ora     ($01,x)                         ; 9F30
        .byte   $01                             ; 9F32
L9F33:  brk                                     ; 9F33
        brk                                     ; 9F34
        brk                                     ; 9F35
        brk                                     ; 9F36
        brk                                     ; 9F37
        ora     ($01,x)                         ; 9F38
        brk                                     ; 9F3A
L9F3B:  .byte   $30                             ; 9F3B
L9F3C:  .byte   $A6                             ; 9F3C
L9F3D:  cli                                     ; 9F3D
        .byte   $A6                             ; 9F3E
L9F3F:  .byte   $80                             ; 9F3F
        .byte   $A6                             ; 9F40
L9F41:  tay                                     ; 9F41
        ldx     $C8                             ; 9F42
        ldx     $D4                             ; 9F44
        ldx     $10                             ; 9F46
        .byte   $A7                             ; 9F48
        .byte   $44                             ; 9F49
        .byte   $A7                             ; 9F4A
        .byte   $44                             ; 9F4B
        .byte   $A7                             ; 9F4C
        sty     $A7                             ; 9F4D
        sty     $A7                             ; 9F4F
        sty     $A7                             ; 9F51
        sty     $A7,x                           ; 9F53
        .byte   $D4                             ; 9F55
        .byte   $A7                             ; 9F56
        .byte   $D4                             ; 9F57
        .byte   $A7                             ; 9F58
        .byte   $14                             ; 9F59
        tay                                     ; 9F5A
        bit     $A8                             ; 9F5B
        .byte   $44                             ; 9F5D
        tay                                     ; 9F5E
        rts                                     ; 9F5F

; ----------------------------------------------------------------------------
        tay                                     ; 9F60
        bvs     L9F0B                           ; 9F61
        dey                                     ; 9F63
        tay                                     ; 9F64
        ldy     #$A8                            ; 9F65
        ldy     $F8A8,x                         ; 9F67
        tay                                     ; 9F6A
        .byte   $0C                             ; 9F6B
        lda     #$88                            ; 9F6C
        tay                                     ; 9F6E
        dey                                     ; 9F6F
        tay                                     ; 9F70
        bit     $A9                             ; 9F71
        .byte   $3C                             ; 9F73
        lda     #$54                            ; 9F74
        lda     #$64                            ; 9F76
        lda     #$78                            ; 9F78
        lda     #$8C                            ; 9F7A
        lda     #$A0                            ; 9F7C
        lda     #$B0                            ; 9F7E
        lda     #$D4                            ; 9F80
        lda     #$F8                            ; 9F82
        lda     #$14                            ; 9F84
        tax                                     ; 9F86
        bmi     L9F33                           ; 9F87
        jmp     L6CAA                           ; 9F89

; ----------------------------------------------------------------------------
        tax                                     ; 9F8C
        jmp     (L6CAA)                         ; 9F8D

; ----------------------------------------------------------------------------
        tax                                     ; 9F90
        bcc     L9F3D                           ; 9F91
        bcc     L9F3F                           ; 9F93
        bcc     L9F41                           ; 9F95
        ldy     $AA,x                           ; 9F97
        ldy     $AA,x                           ; 9F99
        ldy     $AA,x                           ; 9F9B
        cld                                     ; 9F9D
        tax                                     ; 9F9E
L9F9F:  cld                                     ; 9F9F
        tax                                     ; 9FA0
        cld                                     ; 9FA1
        tax                                     ; 9FA2
        .byte   $FC                             ; 9FA3
        tax                                     ; 9FA4
        .byte   $3C                             ; 9FA5
        .byte   $AB                             ; 9FA6
        pla                                     ; 9FA7
        .byte   $AB                             ; 9FA8
        ldy     #$AB                            ; 9FA9
        ldy     $BCAB,x                         ; 9FAB
        .byte   $AB                             ; 9FAE
        .byte   $D4                             ; 9FAF
        .byte   $AB                             ; 9FB0
        brk                                     ; 9FB1
        brk                                     ; 9FB2
        brk                                     ; 9FB3
        brk                                     ; 9FB4
        cpx     L88AB                           ; 9FB5
        tay                                     ; 9FB8
        .byte   $54                             ; 9FB9
        .byte   $A9                             ; 9FBA
L9FBB:  .byte   $29                             ; 9FBB
L9FBC:  ldy     $29                             ; 9FBC
        ldy     $29                             ; 9FBE
        ldy     $29                             ; 9FC0
        ldy     $29                             ; 9FC2
        ldy     $29                             ; 9FC4
        ldy     $06                             ; 9FC6
        ldx     $D3                             ; 9FC8
        ldy     $D3                             ; 9FCA
        ldy     $D3                             ; 9FCC
        ldy     $D3                             ; 9FCE
        ldy     $D3                             ; 9FD0
        ldy     $D3                             ; 9FD2
        ldy     $D3                             ; 9FD4
        ldy     $D3                             ; 9FD6
        ldy     $D3                             ; 9FD8
        ldy     $D3                             ; 9FDA
        ldy     $4C                             ; 9FDC
        lda     $4C                             ; 9FDE
        lda     $4C                             ; 9FE0
        lda     $4C                             ; 9FE2
        lda     $4C                             ; 9FE4
        lda     $4C                             ; 9FE6
        lda     $4C                             ; 9FE8
        lda     $4C                             ; 9FEA
        lda     $4C                             ; 9FEC
        lda     $4C                             ; 9FEE
        lda     $4C                             ; 9FF0
        lda     $4C                             ; 9FF2
        lda     $4C                             ; 9FF4
        lda     $4C                             ; 9FF6
        lda     $4C                             ; 9FF8
        lda     $4C                             ; 9FFA
        lda     $4C                             ; 9FFC
        lda     $4C                             ; 9FFE
