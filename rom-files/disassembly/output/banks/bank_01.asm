; ============================================================================
; The Magic of Scheherazade - Bank 01 Disassembly
; ============================================================================
; File Offset: 0x02000 - 0x03FFF
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
; Created:    2026-01-24 04:39:24
; Input file: C:/claude-workspace/TMOS_AI/rom-files/disassembly/output/banks/bank_01.bin
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
L02C7           := $02C7
L0686           := $0686
L0698           := $0698
L0C86           := $0C86
L0C8C           := $0C8C
L0CC6           := $0CC6
L0CCF           := $0CCF
L1805           := $1805
L1893           := $1893
L1898           := $1898
L18A4           := $18A4
L1B1F           := $1B1F
L1C1F           := $1C1F
L1D1E           := $1D1E
L1D1F           := $1D1F
PPU_CTRL        := $2000
PPU_MASK        := $2001
PPU_STATUS      := $2002
OAM_ADDR        := $2003
OAM_DATA        := $2004
PPU_SCROLL      := $2005
PPU_ADDR        := $2006
PPU_DATA        := $2007
L201D           := $201D
L201E           := $201E
L2220           := $2220
L2222           := $2222
L2321           := $2321
L2422           := $2422
L2499           := $2499
L249B           := $249B
L2522           := $2522
L2B27           := $2B27
L2C43           := $2C43
L2E05           := $2E05
L2E43           := $2E43
L30B0           := $30B0
OAM_DMA         := $4014
APU_STATUS      := $4015
JOY1            := $4016
JOY2_FRAME      := $4017
L4F00           := $4F00
L5844           := $5844
L5ACC           := $5ACC
L6927           := $6927
L73A1           := $73A1
L7673           := $7673
LA467           := $A467
LAC27           := $AC27
LB000           := $B000
LB05A           := $B05A
LB05B           := $B05B
LB05F           := $B05F
LB078           := $B078
LB0D9           := $B0D9
LB144           := $B144
LB174           := $B174
LB18F           := $B18F
LB1C0           := $B1C0
LB1F5           := $B1F5
LB205           := $B205
LB22E           := $B22E
LB241           := $B241
LB272           := $B272
LB2CE           := $B2CE
LB331           := $B331
LB368           := $B368
LBDBA           := $BDBA
LBE35           := $BE35
LBF7A           := $BF7A
LC300           := $C300
LC500           := $C500
LC514           := $C514
LCFC9           := $CFC9
LCFCF           := $CFCF
LD419           := $D419
LD41B           := $D41B
LDA32           := $DA32
LDA44           := $DA44
LDB4C           := $DB4C
LDB55           := $DB55
LDBC0           := $DBC0
LDBE2           := $DBE2
LDDEA           := $DDEA
LDE51           := $DE51
LDE5B           := $DE5B
LDF79           := $DF79
LE95B           := $E95B
LE97D           := $E97D
; ----------------------------------------------------------------------------
        cmp     $07                             ; 8000
        .byte   $9F                             ; 8002
        .byte   $CF                             ; 8003
        .byte   $0C                             ; 8004
        adc     $8C                             ; 8005
        .byte   $0C                             ; 8007
        rol     a                               ; 8008
        bit     L956E                           ; 8009
        clc                                     ; 800C
        rol     $6E2E                           ; 800D
        clc                                     ; 8010
        bit     L8C69                           ; 8011
        .byte   $0C                             ; 8014
        adc     $A4                             ; 8015
        bit     $CF                             ; 8017
        .byte   $0C                             ; 8019
        adc     $8B                             ; 801A
        .byte   $0C                             ; 801C
        rol     a                               ; 801D
        rol     a                               ; 801E
        and     #$29                            ; 801F
        .byte   $27                             ; 8021
        .byte   $27                             ; 8022
        and     $67                             ; 8023
        .byte   $0C                             ; 8025
        dec     $CF                             ; 8026
        asl     $C0                             ; 8028
        asl     a                               ; 802A
        .byte   $1D                             ; 802B
        .byte   $22                             ; 802C
L802D:  and     $22                             ; 802D
L802F:  and     $29                             ; 802F
L8031:  rol     $2925                           ; 8031
        rol     $2931                           ; 8034
        rol     $C631                           ; 8037
        .byte   $67                             ; 803A
        stx     $06                             ; 803B
        .byte   $22                             ; 803D
        asl     $1B22,x                         ; 803E
        asl     $1E22,x                         ; 8041
        .byte   $27                             ; 8044
        .byte   $22                             ; 8045
        asl     $1B22,x                         ; 8046
        asl     $1E22,x                         ; 8049
        dec     $25                             ; 804C
        jsr     L201D                           ; 804E
        ora     L201D,y                         ; 8051
        ora     $2025,x                         ; 8054
        ora     $1920,x                         ; 8057
L805A:  ora     $1D20,x                         ; 805A
        dec     $17                             ; 805D
        .byte   $0B                             ; 805F
        .byte   $0B                             ; 8060
        .byte   $17                             ; 8061
        .byte   $0B                             ; 8062
        .byte   $0B                             ; 8063
        .byte   $17                             ; 8064
        .byte   $0B                             ; 8065
        asl     $0A,x                           ; 8066
        asl     a                               ; 8068
        asl     $0A,x                           ; 8069
        asl     a                               ; 806B
        asl     $0A,x                           ; 806C
        dec     $DC                             ; 806E
        asl     $30                             ; 8070
        brk                                     ; 8072
        .byte   $C3                             ; 8073
        ldy     $65,x                           ; 8074
        iny                                     ; 8076
        .byte   $0C                             ; 8077
        .byte   $27                             ; 8078
        tax                                     ; 8079
        pha                                     ; 807A
        lda     $0C                             ; 807B
        .byte   $27                             ; 807D
        rol     a                               ; 807E
        .byte   $29                             ; 807F
L8080:  .byte   $27                             ; 8080
        and     $A7                             ; 8081
        clc                                     ; 8083
        tax                                     ; 8084
        .byte   $0C                             ; 8085
        and     #$27                            ; 8086
        and     $A7                             ; 8088
        bmi     L8031                           ; 808A
        .byte   $0C                             ; 808C
        bit     $22                             ; 808D
        .byte   $1F                             ; 808F
        lda     ($30,x)                         ; 8090
        .byte   $CF                             ; 8092
        bmi     L805A                           ; 8093
        adc     $A0,x                           ; 8095
        .byte   $DC                             ; 8097
        asl     $50                             ; 8098
        brk                                     ; 809A
        .byte   $62                             ; 809B
        iny                                     ; 809C
        .byte   $0C                             ; 809D
        bit     $A7                             ; 809E
        pha                                     ; 80A0
        ldx     #$0C                            ; 80A1
        bit     $27                             ; 80A3
        and     $24                             ; 80A5
        .byte   $22                             ; 80A7
        ldy     $18                             ; 80A8
        .byte   $A7                             ; 80AA
        .byte   $0C                             ; 80AB
        and     $24                             ; 80AC
        .byte   $22                             ; 80AE
        ldy     $30                             ; 80AF
        ldx     #$0C                            ; 80B1
        jsr     L1B1F                           ; 80B3
        sta     $CF30,x                         ; 80B6
        bmi     L8080                           ; 80B9
        .byte   $9B                             ; 80BB
        ldy     #$DC                            ; 80BC
        brk                                     ; 80BE
        brk                                     ; 80BF
L80C0:  .byte   $0C                             ; 80C0
        lsr     a                               ; 80C1
        stx     $18                             ; 80C2
        asl     a                               ; 80C4
        asl     a                               ; 80C5
        .byte   $93                             ; 80C6
        .byte   $0C                             ; 80C7
        .byte   $0F                             ; 80C8
        .byte   $C7                             ; 80C9
        .byte   $03                             ; 80CA
        cmp     ($A0,x)                         ; 80CB
        lsr     a                               ; 80CD
        .byte   $04                             ; 80CE
        ora     $0F13                           ; 80CF
        cmp     $C1                             ; 80D2
        ldy     #$DC                            ; 80D4
        bpl     L80D8                           ; 80D6
L80D8:  .byte   $44                             ; 80D8
        cmp     ($D0,x)                         ; 80D9
        lsr     $F0,x                           ; 80DB
        clc                                     ; 80DD
        cmp     ($C0,x)                         ; 80DE
        ora     $C1,x                           ; 80E0
        bcs     L80F8                           ; 80E2
        cmp     ($A0,x)                         ; 80E4
        .byte   $93                             ; 80E6
        and     $C1,x                           ; 80E7
        bcc     L80FD                           ; 80E9
        cmp     ($A0,x)                         ; 80EB
        .byte   $13                             ; 80ED
        cmp     ($B0,x)                         ; 80EE
        .byte   $14                             ; 80F0
        cmp     ($C0,x)                         ; 80F1
        ora     $C5,x                           ; 80F3
        cmp     $DCA0,y                         ; 80F5
L80F8:  asl     a                               ; 80F8
        bpl     L80FB                           ; 80F9
L80FB:  .byte   $C3                             ; 80FB
        .byte   $FF                             ; 80FC
L80FD:  .byte   $CF                             ; 80FD
        pha                                     ; 80FE
        .byte   $C7                             ; 80FF
        .byte   $07                             ; 8100
        sbc     $67A0,x                         ; 8101
        .byte   $9C                             ; 8104
        bit     $67                             ; 8105
        stx     $0C                             ; 8107
        jsr     L6927                           ; 8109
        ldy     $24                             ; 810C
        rol     L8C6C                           ; 810E
        .byte   $0C                             ; 8111
        .byte   $2B                             ; 8112
        and     #$2B                            ; 8113
        .byte   $27                             ; 8115
        .byte   $2B                             ; 8116
        adc     #$A4                            ; 8117
        bit     $6E                             ; 8119
        .byte   $93                             ; 811B
        clc                                     ; 811C
        ror     $0C89                           ; 811D
        .byte   $73                             ; 8120
        .byte   $92                             ; 8121
        .byte   $12                             ; 8122
        ror     $0684                           ; 8123
        ror     L0C86                           ; 8126
        .byte   $C7                             ; 8129
        .byte   $03                             ; 812A
        .byte   $20                             ; 812B
        .byte   $A1                             ; 812C
L812D:  .byte   $73                             ; 812D
        iny                                     ; 812E
        pha                                     ; 812F
        cmp     ($73),y                         ; 8130
        and     $DCFF,y                         ; 8132
        .byte   $07                             ; 8135
        jsr     L4F00                           ; 8136
        .byte   $9C                             ; 8139
        .byte   $24                             ; 813A
L813B:  .byte   $4F                             ; 813B
        stx     $0C                             ; 813C
        asl     a                               ; 813E
        .byte   $0F                             ; 813F
        .byte   $51                             ; 8140
L8141:  ldy     $24                             ; 8141
        asl     $54,x                           ; 8143
        sty     $130C                           ; 8145
        ora     ($13),y                         ; 8148
        .byte   $0F                             ; 814A
        .byte   $13                             ; 814B
        eor     ($8E),y                         ; 814C
        .byte   $12                             ; 814E
        lsr     a                               ; 814F
        sty     $06                             ; 8150
        eor     ($89),y                         ; 8152
        .byte   $0C                             ; 8154
        lsr     $A4,x                           ; 8155
        bit     $D1                             ; 8157
        lsr     $92,x                           ; 8159
        .byte   $12                             ; 815B
        .byte   $54                             ; 815C
        sty     $06                             ; 815D
        .byte   $54                             ; 815F
        .byte   $89                             ; 8160
        .byte   $0C                             ; 8161
        .byte   $54                             ; 8162
        tya                                     ; 8163
        clc                                     ; 8164
        .byte   $53                             ; 8165
        .byte   $89                             ; 8166
        .byte   $0C                             ; 8167
        .byte   $53                             ; 8168
        .byte   $92                             ; 8169
        .byte   $12                             ; 816A
        eor     $86,x                           ; 816B
        asl     $91                             ; 816D
        .byte   $0C                             ; 816F
        .byte   $4F                             ; 8170
        .byte   $92                             ; 8171
        .byte   $12                             ; 8172
        eor     ($86),y                         ; 8173
        asl     $8E                             ; 8175
        .byte   $0C                             ; 8177
        jmp     L1898                           ; 8178

; ----------------------------------------------------------------------------
        lsr     $0C9B                           ; 817B
        .byte   $4F                             ; 817E
        ldy     $24                             ; 817F
        cmp     ($4F),y                         ; 8181
        ldy     $12                             ; 8183
        stx     L8C06                           ; 8185
        .byte   $0C                             ; 8188
        stx     L8A18                           ; 8189
        .byte   $0C                             ; 818C
        dey                                     ; 818D
        .byte   $12                             ; 818E
        .byte   $8F                             ; 818F
        asl     $96                             ; 8190
        .byte   $0C                             ; 8192
        tya                                     ; 8193
        bit     $87                             ; 8194
        .byte   $12                             ; 8196
        stx     L9506                           ; 8197
        .byte   $0C                             ; 819A
        stx     $24,y                           ; 819B
        sta     $12                             ; 819D
        sty     L9306                           ; 819F
        .byte   $0C                             ; 81A2
        sty     $24,x                           ; 81A3
        txa                                     ; 81A5
L81A6:  .byte   $12                             ; 81A6
        sta     ($06),y                         ; 81A7
        tya                                     ; 81A9
        .byte   $0C                             ; 81AA
        txs                                     ; 81AB
        clc                                     ; 81AC
        txa                                     ; 81AD
        .byte   $0C                             ; 81AE
        .byte   $4B                             ; 81AF
        stx     $4B12                           ; 81B0
        sty     $06                             ; 81B3
        .byte   $4B                             ; 81B5
        stx     $0C                             ; 81B6
        .byte   $C7                             ; 81B8
        ora     ($AF,x)                         ; 81B9
        lda     ($4D,x)                         ; 81BB
        stx     $4D12                           ; 81BD
        sty     $06                             ; 81C0
        eor     L0C86                           ; 81C2
        .byte   $C7                             ; 81C5
        ora     ($BC,x)                         ; 81C6
        lda     ($4F,x)                         ; 81C8
        iny                                     ; 81CA
        pha                                     ; 81CB
        cmp     ($4F),y                         ; 81CC
        and     $DCFF,y                         ; 81CE
        brk                                     ; 81D1
        brk                                     ; 81D2
        .byte   $0C                             ; 81D3
        .byte   $CF                             ; 81D4
        bcc     L81A6                           ; 81D5
        bcc     L8234                           ; 81D7
        .byte   $9C                             ; 81D9
        bit     $5B                             ; 81DA
        stx     $0C                             ; 81DC
        asl     $1B,x                           ; 81DE
        eor     $24A4,x                         ; 81E0
        .byte   $22                             ; 81E3
        cmp     ($62),y                         ; 81E4
        sty     $600C                           ; 81E6
        stx     $06                             ; 81E9
        .byte   $1F                             ; 81EB
        eor     L0C8C,x                         ; 81EC
        .byte   $5F                             ; 81EF
        asl     a                               ; 81F0
        .byte   $1B                             ; 81F1
        .byte   $1F                             ; 81F2
        eor     $24A4,x                         ; 81F3
        .byte   $22                             ; 81F6
        cmp     ($62),y                         ; 81F7
        .byte   $92                             ; 81F9
        .byte   $12                             ; 81FA
        rts                                     ; 81FB

; ----------------------------------------------------------------------------
        stx     $06                             ; 81FC
        .byte   $5F                             ; 81FE
        sty     $600C                           ; 81FF
        asl     $1B                             ; 8202
L8204:  jsr     L9862                           ; 8204
        clc                                     ; 8207
        .byte   $64                             ; 8208
        sty     $660C                           ; 8209
        ldy     #$24                            ; 820C
        .byte   $67                             ; 820E
        bit     $24                             ; 820F
        cmp     ($64),y                         ; 8211
        .byte   $92                             ; 8213
        .byte   $12                             ; 8214
        ror     $86                             ; 8215
        asl     $67                             ; 8217
        sty     $660C                           ; 8219
        ldy     $24                             ; 821C
        .byte   $67                             ; 821E
        stx     $6712                           ; 821F
        sty     $06                             ; 8222
        .byte   $67                             ; 8224
        stx     $0C                             ; 8225
        .byte   $C7                             ; 8227
        ora     ($1E,x)                         ; 8228
        ldx     #$69                            ; 822A
        stx     $6912                           ; 822C
        sty     $06                             ; 822F
        adc     #$86                            ; 8231
        .byte   $0C                             ; 8233
L8234:  adc     #$92                            ; 8234
        .byte   $12                             ; 8236
        .byte   $6B                             ; 8237
        stx     $06                             ; 8238
        jmp     (L0C86)                         ; 823A

; ----------------------------------------------------------------------------
        .byte   $6B                             ; 823D
L823E:  iny                                     ; 823E
        pha                                     ; 823F
        .byte   $D1                             ; 8240
L8241:  .byte   $6B                             ; 8241
        and     $DCFF,y                         ; 8242
        .byte   $0B                             ; 8245
        bpl     L8248                           ; 8246
L8248:  .byte   $C3                             ; 8248
        inx                                     ; 8249
        .byte   $CF                             ; 824A
        clc                                     ; 824B
        .byte   $62                             ; 824C
        .byte   $92                             ; 824D
        .byte   $12                             ; 824E
        .byte   $62                             ; 824F
        stx     $06                             ; 8250
        cmp     $0E                             ; 8252
        .byte   $A3                             ; 8254
        and     #$27                            ; 8255
        adc     #$C8                            ; 8257
        pha                                     ; 8259
        .byte   $62                             ; 825A
        .byte   $92                             ; 825B
        .byte   $12                             ; 825C
        .byte   $62                             ; 825D
        stx     $06                             ; 825E
        cmp     $0E                             ; 8260
        .byte   $A3                             ; 8262
        adc     #$98                            ; 8263
        clc                                     ; 8265
        .byte   $67                             ; 8266
        iny                                     ; 8267
        pha                                     ; 8268
        .byte   $62                             ; 8269
        .byte   $92                             ; 826A
        .byte   $12                             ; 826B
        .byte   $62                             ; 826C
        stx     $06                             ; 826D
        cmp     $52                             ; 826F
        ldx     #$DC                            ; 8271
        ora     ($30,x)                         ; 8273
        brk                                     ; 8275
        .byte   $CF                             ; 8276
        bmi     L823E                           ; 8277
        .byte   $46                             ; 8279
L827A:  .byte   $A3                             ; 827A
        bne     L827A                           ; 827B
        .byte   $C5                             ; 827D
L827E:  lsr     $A3                             ; 827E
        bne     L827E                           ; 8280
        cmp     $46                             ; 8282
        .byte   $A3                             ; 8284
        bne     L8289                           ; 8285
        cmp     $46                             ; 8287
L8289:  .byte   $A3                             ; 8289
        bne     L828E                           ; 828A
        cmp     $46                             ; 828C
L828E:  .byte   $A3                             ; 828E
L828F:  bne     L8294                           ; 828F
        cmp     $46                             ; 8291
        .byte   $A3                             ; 8293
L8294:  bne     L828F                           ; 8294
        cmp     $46                             ; 8296
        .byte   $A3                             ; 8298
        bne     L829D                           ; 8299
        cmp     $46                             ; 829B
L829D:  .byte   $A3                             ; 829D
        bne     L82A5                           ; 829E
        cmp     $46                             ; 82A0
L82A2:  .byte   $A3                             ; 82A2
        bne     L82A2                           ; 82A3
L82A5:  .byte   $C5                             ; 82A5
L82A6:  lsr     $A3                             ; 82A6
        bne     L82A6                           ; 82A8
        .byte   $C5                             ; 82AA
L82AB:  lsr     $A3                             ; 82AB
        bne     L82B1                           ; 82AD
        cmp     $46                             ; 82AF
L82B1:  .byte   $A3                             ; 82B1
        bne     L82B6                           ; 82B2
        cmp     $46                             ; 82B4
L82B6:  .byte   $A3                             ; 82B6
        bne     L82BC                           ; 82B7
L82B9:  cmp     $46                             ; 82B9
        .byte   $A3                             ; 82BB
L82BC:  ldy     $2706                           ; 82BC
        jsr     LAC27                           ; 82BF
        .byte   $0C                             ; 82C2
        .byte   $27                             ; 82C3
        ldx     $2906                           ; 82C4
        .byte   $22                             ; 82C7
        and     #$AE                            ; 82C8
        .byte   $0C                             ; 82CA
        and     #$B3                            ; 82CB
        asl     $2E                             ; 82CD
        .byte   $27                             ; 82CF
        rol     $0CB3                           ; 82D0
        rol     $06AE                           ; 82D3
        and     #$22                            ; 82D6
        and     #$AE                            ; 82D8
        .byte   $0C                             ; 82DA
        and     #$C5                            ; 82DB
        sei                                     ; 82DD
        ldx     #$DC                            ; 82DE
        brk                                     ; 82E0
        brk                                     ; 82E1
        clc                                     ; 82E2
L82E3:  .byte   $CF                             ; 82E3
        bmi     L82AB                           ; 82E4
        cli                                     ; 82E6
        .byte   $A3                             ; 82E7
        php                                     ; 82E8
        php                                     ; 82E9
        php                                     ; 82EA
        php                                     ; 82EB
        php                                     ; 82EC
        php                                     ; 82ED
        php                                     ; 82EE
        php                                     ; 82EF
        asl     a                               ; 82F0
        asl     a                               ; 82F1
        asl     a                               ; 82F2
        asl     a                               ; 82F3
        asl     a                               ; 82F4
        asl     a                               ; 82F5
        asl     a                               ; 82F6
        asl     a                               ; 82F7
        cmp     $58                             ; 82F8
        .byte   $A3                             ; 82FA
        php                                     ; 82FB
        php                                     ; 82FC
        php                                     ; 82FD
        php                                     ; 82FE
        asl     a                               ; 82FF
        asl     a                               ; 8300
        asl     a                               ; 8301
        asl     a                               ; 8302
        .byte   $0F                             ; 8303
        .byte   $0F                             ; 8304
        .byte   $0F                             ; 8305
        .byte   $0F                             ; 8306
        asl     a                               ; 8307
        .byte   $0C                             ; 8308
        asl     $C50A                           ; 8309
        sbc     $A2                             ; 830C
        .byte   $67                             ; 830E
        iny                                     ; 830F
        bmi     L82B9                           ; 8310
        .byte   $0C                             ; 8312
        and     #$27                            ; 8313
        rol     $A4                             ; 8315
        bit     $A2                             ; 8317
        .byte   $0C                             ; 8319
        ldx     #$18                            ; 831A
        ldx     #$12                            ; 831C
        ldx     #$06                            ; 831E
        ldy     $AB30                           ; 8320
        .byte   $0C                             ; 8323
        and     #$2B                            ; 8324
        bit     $48A9                           ; 8326
        .byte   $A7                             ; 8329
        .byte   $12                             ; 832A
        .byte   $A7                             ; 832B
        asl     $70                             ; 832C
L832E:  iny                                     ; 832E
        .byte   $3C                             ; 832F
        .byte   $B3                             ; 8330
        .byte   $0C                             ; 8331
        .byte   $32                             ; 8332
        bmi     L82E3                           ; 8333
        bit     $AC                             ; 8335
        .byte   $0C                             ; 8337
        .byte   $AB                             ; 8338
        clc                                     ; 8339
        .byte   $A9                             ; 833A
L833B:  .byte   $12                             ; 833B
        .byte   $AB                             ; 833C
        asl     $AC                             ; 833D
        clc                                     ; 833F
        .byte   $2C                             ; 8340
L8341:  jmp     (L0C8C)                         ; 8341

; ----------------------------------------------------------------------------
        .byte   $2B                             ; 8344
        dec     $73                             ; 8345
        stx     $06                             ; 8347
        rol     $2E27                           ; 8349
        .byte   $B3                             ; 834C
        .byte   $0C                             ; 834D
        rol     $06B3                           ; 834E
        rol     $2E27                           ; 8351
        .byte   $B3                             ; 8354
        .byte   $0C                             ; 8355
        rol     $4FC6                           ; 8356
        sty     $0C                             ; 8359
        .byte   $0F                             ; 835B
        .byte   $0F                             ; 835C
        .byte   $0F                             ; 835D
        asl     $0E0E                           ; 835E
        asl     $0C0C                           ; 8361
        .byte   $0C                             ; 8364
        .byte   $0C                             ; 8365
        asl     a                               ; 8366
        asl     a                               ; 8367
        asl     a                               ; 8368
        asl     a                               ; 8369
        php                                     ; 836A
        php                                     ; 836B
        php                                     ; 836C
        php                                     ; 836D
        php                                     ; 836E
        php                                     ; 836F
        php                                     ; 8370
        php                                     ; 8371
        asl     a                               ; 8372
        asl     a                               ; 8373
        asl     a                               ; 8374
        asl     a                               ; 8375
        asl     a                               ; 8376
        asl     a                               ; 8377
        asl     a                               ; 8378
        asl     a                               ; 8379
        .byte   $0C                             ; 837A
        .byte   $0C                             ; 837B
        .byte   $0C                             ; 837C
L837D:  .byte   $0C                             ; 837D
        .byte   $0C                             ; 837E
        .byte   $0C                             ; 837F
        .byte   $0C                             ; 8380
        .byte   $0C                             ; 8381
        .byte   $0F                             ; 8382
        .byte   $0F                             ; 8383
        .byte   $0F                             ; 8384
        .byte   $0F                             ; 8385
        .byte   $0F                             ; 8386
        .byte   $0F                             ; 8387
        .byte   $0F                             ; 8388
        .byte   $0F                             ; 8389
        dec     $DC                             ; 838A
        ora     a:$60                           ; 838C
        .byte   $C3                             ; 838F
        .byte   $FF                             ; 8390
        .byte   $4F                             ; 8391
        stx     $04                             ; 8392
        .byte   $12                             ; 8394
        ora     $18,x                           ; 8395
        .byte   $1B                             ; 8397
        asl     $1E21,x                         ; 8398
        .byte   $1B                             ; 839B
        clc                                     ; 839C
        ora     $12,x                           ; 839D
        .byte   $C7                             ; 839F
        .byte   $07                             ; 83A0
        sta     ($A3),y                         ; 83A1
        clc                                     ; 83A3
        .byte   $1B                             ; 83A4
        .byte   $C7                             ; 83A5
        .byte   $0B                             ; 83A6
        .byte   $A3                             ; 83A7
        .byte   $A3                             ; 83A8
        asl     $C721,x                         ; 83A9
        .byte   $0B                             ; 83AC
        lda     #$A3                            ; 83AD
        cmp     ($10,x)                         ; 83AF
        tay                                     ; 83B1
        asl     $28                             ; 83B2
        .byte   $FF                             ; 83B4
        .byte   $DC                             ; 83B5
        .byte   $0C                             ; 83B6
        jsr     LC500                           ; 83B7
        sed                                     ; 83BA
        .byte   $A3                             ; 83BB
        .byte   $27                             ; 83BC
        bit     $21                             ; 83BD
        asl     $2124,x                         ; 83BF
        asl     $211B,x                         ; 83C2
        asl     $181B,x                         ; 83C5
        asl     $181B,x                         ; 83C8
        ora     $C5,x                           ; 83CB
        sed                                     ; 83CD
        .byte   $A3                             ; 83CE
        and     $272A                           ; 83CF
        bit     $C7                             ; 83D2
        .byte   $03                             ; 83D4
        .byte   $CF                             ; 83D5
        .byte   $A3                             ; 83D6
        .byte   $1B                             ; 83D7
        asl     $2421,x                         ; 83D8
        .byte   $27                             ; 83DB
        rol     a                               ; 83DC
        and     $C730                           ; 83DD
        ora     ($D7,x)                         ; 83E0
        .byte   $A3                             ; 83E2
        .byte   $1B                             ; 83E3
        asl     $2421,x                         ; 83E4
        asl     $2421,x                         ; 83E7
        .byte   $27                             ; 83EA
        and     ($24,x)                         ; 83EB
        .byte   $27                             ; 83ED
        rol     a                               ; 83EE
        bit     $27                             ; 83EF
        rol     a                               ; 83F1
        and     a:$C1                           ; 83F2
        bmi     L8427                           ; 83F5
        .byte   $FF                             ; 83F7
        adc     ($85,x)                         ; 83F8
        asl     $24                             ; 83FA
        .byte   $27                             ; 83FC
        and     #$2C                            ; 83FD
        bmi     L8434                           ; 83FF
        rol     $33,x                           ; 8401
        bmi     L8432                           ; 8403
        rol     a                               ; 8405
        .byte   $27                             ; 8406
        bit     $21                             ; 8407
        asl     $DCC6,x                         ; 8409
        ora     a:$30                           ; 840C
        .byte   $C3                             ; 840F
        cmp     $C5                             ; 8410
        .byte   $EF                             ; 8412
        ldy     $60                             ; 8413
        tya                                     ; 8415
        .byte   $12                             ; 8416
        ldx     #$06                            ; 8417
        ldy     #$18                            ; 8419
        ldx     #$0C                            ; 841B
        bit     $A5                             ; 841D
        .byte   $12                             ; 841F
        ldy     $06                             ; 8420
        .byte   $22                             ; 8422
        jsr     L18A4                           ; 8423
        .byte   $62                             ; 8426
L8427:  sty     $C50C                           ; 8427
        .byte   $EF                             ; 842A
        .byte   $A4                             ; 842B
L842C:  rts                                     ; 842C

; ----------------------------------------------------------------------------
        tya                                     ; 842D
        .byte   $12                             ; 842E
        ldx     #$06                            ; 842F
        .byte   $A0                             ; 8431
L8432:  clc                                     ; 8432
        .byte   $A4                             ; 8433
L8434:  .byte   $0C                             ; 8434
        .byte   $27                             ; 8435
        ldy     #$12                            ; 8436
        sta     L9F06,x                         ; 8438
        .byte   $0C                             ; 843B
        ldy     #$24                            ; 843C
        .byte   $CF                             ; 843E
        .byte   $0C                             ; 843F
        .byte   $5B                             ; 8440
        sty     $1C0C                           ; 8441
        .byte   $1F                             ; 8444
        jsr     L2522                           ; 8445
        .byte   $22                             ; 8448
        jsr     L1C1F                           ; 8449
        .byte   $1A                             ; 844C
        .byte   $5B                             ; 844D
        stx     $06                             ; 844E
        .byte   $1A                             ; 8450
        .byte   $1B                             ; 8451
        .byte   $1C                             ; 8452
        .byte   $1B                             ; 8453
        .byte   $1C                             ; 8454
        .byte   $1B                             ; 8455
        .byte   $1A                             ; 8456
        .byte   $1B                             ; 8457
        .byte   $1C                             ; 8458
        .byte   $1B                             ; 8459
        .byte   $1C                             ; 845A
        .byte   $5B                             ; 845B
        iny                                     ; 845C
        pha                                     ; 845D
        cmp     ($60,x)                         ; 845E
        .byte   $C7                             ; 8460
        ora     ($3E,x)                         ; 8461
        ldy     $C1                             ; 8463
        bmi     L842C                           ; 8465
        ora     ($A4),y                         ; 8467
        .byte   $DC                             ; 8469
        ora     a:$40                           ; 846A
        cmp     $03                             ; 846D
        lda     $19                             ; 846F
        .byte   $1B                             ; 8471
        ora     L9860,x                         ; 8472
        clc                                     ; 8475
        .byte   $5F                             ; 8476
        sty     $C50C                           ; 8477
        .byte   $03                             ; 847A
        lda     $59                             ; 847B
        tya                                     ; 847D
        clc                                     ; 847E
        ora     L8C56,y                         ; 847F
        .byte   $0C                             ; 8482
        clc                                     ; 8483
        .byte   $CF                             ; 8484
        .byte   $0C                             ; 8485
        .byte   $97                             ; 8486
        .byte   $0C                             ; 8487
        ora     $1C1B,y                         ; 8488
        .byte   $1F                             ; 848B
        .byte   $22                             ; 848C
        .byte   $1F                             ; 848D
        .byte   $1C                             ; 848E
        .byte   $1B                             ; 848F
        ora     $5314,y                         ; 8490
L8493:  iny                                     ; 8493
        pha                                     ; 8494
        cmp     ($53),y                         ; 8495
        stx     $06                             ; 8497
        .byte   $12                             ; 8499
        .byte   $13                             ; 849A
        .byte   $14                             ; 849B
        .byte   $13                             ; 849C
        .byte   $14                             ; 849D
        .byte   $53                             ; 849E
        ldy     $24                             ; 849F
        cmp     ($70,x)                         ; 84A1
        .byte   $C7                             ; 84A3
        ora     ($84,x)                         ; 84A4
        ldy     $C1                             ; 84A6
        rti                                     ; 84A8

; ----------------------------------------------------------------------------
        cmp     $6D                             ; 84A9
        ldy     $DC                             ; 84AB
        brk                                     ; 84AD
        brk                                     ; 84AE
        .byte   $0C                             ; 84AF
        cmp     $1E                             ; 84B0
        lda     $56                             ; 84B2
        .byte   $0C                             ; 84B4
        clc                                     ; 84B5
        ora     $5B1A,y                         ; 84B6
        ora     $0F                             ; 84B9
        cmp     $1E                             ; 84BB
        lda     $16                             ; 84BD
        asl     a                               ; 84BF
        .byte   $0F                             ; 84C0
        pha                                     ; 84C1
        ldy     $24                             ; 84C2
        .byte   $4F                             ; 84C4
        stx     $4F12                           ; 84C5
        sty     $06                             ; 84C8
        .byte   $4F                             ; 84CA
        ldx     $4F42,y                         ; 84CB
        sty     $06                             ; 84CE
        .byte   $4F                             ; 84D0
        .byte   $C2                             ; 84D1
        .byte   $42                             ; 84D2
        lsr     a                               ; 84D3
        stx     $06                             ; 84D4
        .byte   $4F                             ; 84D6
        sta     $0C                             ; 84D7
        .byte   $4F                             ; 84D9
        .byte   $92                             ; 84DA
        .byte   $12                             ; 84DB
        lsr     a                               ; 84DC
        stx     $06                             ; 84DD
        .byte   $4F                             ; 84DF
        sta     $0C                             ; 84E0
        .byte   $0F                             ; 84E2
        asl     a                               ; 84E3
        .byte   $0F                             ; 84E4
        asl     a                               ; 84E5
        .byte   $0F                             ; 84E6
        asl     a                               ; 84E7
        .byte   $C7                             ; 84E8
        ora     ($C4,x)                         ; 84E9
        ldy     $C5                             ; 84EB
        bcs     L8493                           ; 84ED
        .byte   $67                             ; 84EF
        tya                                     ; 84F0
        .byte   $12                             ; 84F1
        lda     #$06                            ; 84F2
        .byte   $A7                             ; 84F4
        clc                                     ; 84F5
        lda     #$0C                            ; 84F6
        .byte   $2B                             ; 84F8
        ldy     $A912                           ; 84F9
        asl     $64                             ; 84FC
        ldy     $24                             ; 84FE
        .byte   $CF                             ; 8500
        .byte   $0C                             ; 8501
        dec     $64                             ; 8502
        tya                                     ; 8504
        clc                                     ; 8505
        ldy     $0C                             ; 8506
        ldx     #$18                            ; 8508
        ldx     #$0C                            ; 850A
        ldy     #$18                            ; 850C
        ldy     #$0C                            ; 850E
        .byte   $9F                             ; 8510
        clc                                     ; 8511
        .byte   $9F                             ; 8512
        .byte   $0C                             ; 8513
        sta     L9D18,x                         ; 8514
        .byte   $0C                             ; 8517
        .byte   $9B                             ; 8518
        clc                                     ; 8519
        .byte   $5B                             ; 851A
        sty     $C60C                           ; 851B
        rts                                     ; 851E

; ----------------------------------------------------------------------------
        sty     $540C                           ; 851F
        ora     $20                             ; 8522
        .byte   $5F                             ; 8524
        .byte   $0C                             ; 8525
        .byte   $53                             ; 8526
        ora     $1F                             ; 8527
        eor     $510C,x                         ; 8529
        ora     $1D                             ; 852C
        .byte   $5B                             ; 852E
        .byte   $0C                             ; 852F
        .byte   $4F                             ; 8530
        ora     $1B                             ; 8531
        eor     $4D0C,y                         ; 8533
        ora     $19                             ; 8536
        cli                                     ; 8538
        .byte   $0C                             ; 8539
        jmp     L1805                           ; 853A

; ----------------------------------------------------------------------------
        dec     $DC                             ; 853D
        .byte   $03                             ; 853F
        bmi     L8542                           ; 8540
L8542:  .byte   $C3                             ; 8542
        cmp     #$CF                            ; 8543
        jmp     (L8C5B)                         ; 8545

; ----------------------------------------------------------------------------
        .byte   $0C                             ; 8548
        ora     $BC5E,x                         ; 8549
        pha                                     ; 854C
        .byte   $5B                             ; 854D
        sty     $1D0C                           ; 854E
        .byte   $9E                             ; 8551
        clc                                     ; 8552
        ora     $EC58,y                         ; 8553
        sei                                     ; 8556
        .byte   $5B                             ; 8557
        sty     $1D0C                           ; 8558
        lsr     $48BC,x                         ; 855B
        .byte   $5B                             ; 855E
        sty     $1D0C                           ; 855F
        .byte   $9E                             ; 8562
        clc                                     ; 8563
        clc                                     ; 8564
        adc     ($EC,x)                         ; 8565
        jmp     (L8C62)                         ; 8567

; ----------------------------------------------------------------------------
        .byte   $0C                             ; 856A
        lda     ($18,x)                         ; 856B
        asl     $0C9D,x                         ; 856D
        adc     ($F8,x)                         ; 8570
        sei                                     ; 8572
        .byte   $62                             ; 8573
        sty     $A10C                           ; 8574
        clc                                     ; 8577
        asl     $0C9D,x                         ; 8578
        .byte   $5C                             ; 857B
        sed                                     ; 857C
        sty     $C5                             ; 857D
        lsr     $A5                             ; 857F
        .byte   $DC                             ; 8581
        .byte   $03                             ; 8582
        bvc     L8585                           ; 8583
L8585:  .byte   $CF                             ; 8585
        rts                                     ; 8586

; ----------------------------------------------------------------------------
        .byte   $CF                             ; 8587
        cpy     #$CF                            ; 8588
        rts                                     ; 858A

; ----------------------------------------------------------------------------
        .byte   $CF                             ; 858B
        .byte   $0C                             ; 858C
        cli                                     ; 858D
        sty     $190C                           ; 858E
        .byte   $5B                             ; 8591
        ldy     $5848,x                         ; 8592
        sty     $190C                           ; 8595
        .byte   $9B                             ; 8598
        clc                                     ; 8599
        ora     $5D,x                           ; 859A
        cpx     $5E6C                           ; 859C
        sty     L9D0C                           ; 859F
        clc                                     ; 85A2
        .byte   $1B                             ; 85A3
        sta     $5D0C,y                         ; 85A4
        sed                                     ; 85A7
        sei                                     ; 85A8
        lsr     L0C8C,x                         ; 85A9
        sta     $1B18,x                         ; 85AC
        sta     $580C,y                         ; 85AF
        sed                                     ; 85B2
        sei                                     ; 85B3
        cmp     $87                             ; 85B4
        lda     $DC                             ; 85B6
        brk                                     ; 85B8
        brk                                     ; 85B9
        .byte   $0C                             ; 85BA
        lsr     a                               ; 85BB
        sta     $0C                             ; 85BC
        asl     $0A,x                           ; 85BE
        asl     $0A,x                           ; 85C0
        asl     $0A,x                           ; 85C2
        asl     $0A,x                           ; 85C4
        asl     $0A,x                           ; 85C6
        asl     $0A,x                           ; 85C8
        asl     $0A,x                           ; 85CA
        asl     $C7,x                           ; 85CC
        .byte   $04                             ; 85CE
        cmp     $A5                             ; 85CF
        bne     L85D5                           ; 85D1
        .byte   $C7                             ; 85D3
        .byte   $11                             ; 85D4
L85D5:  cmp     $A5                             ; 85D5
        bne     L85D5                           ; 85D7
        cmp     $C5                             ; 85D9
        lda     $DC                             ; 85DB
        .byte   $03                             ; 85DD
        bmi     L85E0                           ; 85DE
L85E0:  .byte   $C3                             ; 85E0
        .byte   $FF                             ; 85E1
        cmp     $4B                             ; 85E2
        ldx     $25                             ; 85E4
        adc     $83                             ; 85E6
        .byte   $03                             ; 85E8
        rol     $67                             ; 85E9
        cpy     $C55A                           ; 85EB
        .byte   $4B                             ; 85EE
        ldx     $2B                             ; 85EF
        ror     a                               ; 85F1
        .byte   $83                             ; 85F2
        .byte   $03                             ; 85F3
        .byte   $2B                             ; 85F4
        jmp     (L5ACC)                         ; 85F5

; ----------------------------------------------------------------------------
        cmp     $E2                             ; 85F8
        lda     $DC                             ; 85FA
        php                                     ; 85FC
        bvs     L85FF                           ; 85FD
L85FF:  cmp     $6F                             ; 85FF
        ldx     $C5                             ; 8601
        .byte   $6F                             ; 8603
        ldx     $C5                             ; 8604
        .byte   $82                             ; 8606
        ldx     $C5                             ; 8607
        .byte   $82                             ; 8609
        ldx     $C5                             ; 860A
        .byte   $6F                             ; 860C
        ldx     $C5                             ; 860D
        .byte   $6F                             ; 860F
        ldx     $C5                             ; 8610
        .byte   $82                             ; 8612
        ldx     $68                             ; 8613
        .byte   $92                             ; 8615
        .byte   $03                             ; 8616
        .byte   $2B                             ; 8617
        ldy     $A412                           ; 8618
        .byte   $03                             ; 861B
        and     $A7                             ; 861C
        .byte   $12                             ; 861E
        tay                                     ; 861F
        .byte   $03                             ; 8620
        .byte   $2B                             ; 8621
        ldy     $CF12                           ; 8622
        clc                                     ; 8625
        cmp     $FF                             ; 8626
        lda     $DC                             ; 8628
        brk                                     ; 862A
        brk                                     ; 862B
        .byte   $0C                             ; 862C
        cmp     $95                             ; 862D
        ldx     $C5                             ; 862F
        sta     $A6,x                           ; 8631
        cmp     $A4                             ; 8633
        ldx     $C5                             ; 8635
        ldy     $A6                             ; 8637
        cmp     $95                             ; 8639
        ldx     $C5                             ; 863B
        sta     $A6,x                           ; 863D
        cmp     $A4                             ; 863F
        ldx     $54                             ; 8641
        .byte   $89                             ; 8643
        clc                                     ; 8644
        .byte   $1B                             ; 8645
        jsr     LC514                           ; 8646
        and     $64A6                           ; 8649
        ldy     $24                             ; 864C
        lda     $0C                             ; 864E
        tax                                     ; 8650
L8651:  .byte   $03                             ; 8651
        .byte   $2B                             ; 8652
        jmp     (L1893)                         ; 8653

; ----------------------------------------------------------------------------
        .byte   $CF                             ; 8656
        .byte   $12                             ; 8657
        .byte   $A7                             ; 8658
        .byte   $0C                             ; 8659
        and     $24                             ; 865A
        .byte   $CF                             ; 865C
        .byte   $0C                             ; 865D
        bit     $21                             ; 865E
        jsr     L0CCF                           ; 8660
        jmp     (L30B0)                         ; 8663

; ----------------------------------------------------------------------------
        .byte   $AB                             ; 8666
        .byte   $0C                             ; 8667
        ldy     $2B06                           ; 8668
        pla                                     ; 866B
        sty     $C60C                           ; 866C
L866F:  rts                                     ; 866F

; ----------------------------------------------------------------------------
        .byte   $92                             ; 8670
        .byte   $03                             ; 8671
        and     ($A4,x)                         ; 8672
        .byte   $12                             ; 8674
        ldy     #$03                            ; 8675
        and     ($A4,x)                         ; 8677
        .byte   $12                             ; 8679
        ldy     #$03                            ; 867A
        and     ($A4,x)                         ; 867C
        .byte   $12                             ; 867E
        .byte   $CF                             ; 867F
        clc                                     ; 8680
        dec     $64                             ; 8681
        .byte   $92                             ; 8683
        .byte   $03                             ; 8684
        and     $A7                             ; 8685
        .byte   $12                             ; 8687
        ldy     $03                             ; 8688
        and     $A7                             ; 868A
        .byte   $12                             ; 868C
        ldy     $03                             ; 868D
        and     $A7                             ; 868F
        .byte   $12                             ; 8691
        .byte   $CF                             ; 8692
        clc                                     ; 8693
        dec     $54                             ; 8694
        .byte   $89                             ; 8696
        clc                                     ; 8697
        rts                                     ; 8698

; ----------------------------------------------------------------------------
        sty     $0C                             ; 8699
        jsr     L8955                           ; 869B
        clc                                     ; 869E
        adc     ($84,x)                         ; 869F
        .byte   $0C                             ; 86A1
        and     ($C6,x)                         ; 86A2
        .byte   $4F                             ; 86A4
        .byte   $89                             ; 86A5
        clc                                     ; 86A6
        .byte   $5B                             ; 86A7
        sty     $0C                             ; 86A8
        .byte   $1B                             ; 86AA
        eor     $89,x                           ; 86AB
        clc                                     ; 86AD
        .byte   $5B                             ; 86AE
        sty     $0C                             ; 86AF
        .byte   $1B                             ; 86B1
        dec     $DC                             ; 86B2
        asl     a                               ; 86B4
        bmi     L86B7                           ; 86B5
L86B7:  .byte   $C3                             ; 86B7
        lda     $CF,x                           ; 86B8
        .byte   $0C                             ; 86BA
        .byte   $5B                             ; 86BB
        sty     $200C                           ; 86BC
        .byte   $1F                             ; 86BF
        jsr     L2422                           ; 86C0
        jsr     LA467                           ; 86C3
        bit     $A9                             ; 86C6
        .byte   $0C                             ; 86C8
        .byte   $A7                             ; 86C9
        clc                                     ; 86CA
        and     $CF                             ; 86CB
        .byte   $0C                             ; 86CD
        ldy     $0C                             ; 86CE
        and     #$28                            ; 86D0
        and     #$2B                            ; 86D2
        bit     $7029                           ; 86D4
        bcs     L8709                           ; 86D7
        .byte   $2B                             ; 86D9
        .byte   $CF                             ; 86DA
        .byte   $0C                             ; 86DB
        adc     #$85                            ; 86DC
        asl     $2B                             ; 86DE
        ldy     $A90C                           ; 86E0
        asl     $27                             ; 86E3
        adc     #$9E                            ; 86E5
        bit     $A9                             ; 86E7
        .byte   $0C                             ; 86E9
        .byte   $67                             ; 86EA
        ldy     $6C3C,x                         ; 86EB
        stx     $06                             ; 86EE
        .byte   $2B                             ; 86F0
        ldy     $270C                           ; 86F1
        lda     $06                             ; 86F4
        .byte   $27                             ; 86F6
        and     #$27                            ; 86F7
        and     $24                             ; 86F9
        .byte   $22                             ; 86FB
        jsr     L2422                           ; 86FC
        and     $24                             ; 86FF
        .byte   $22                             ; 8701
        jsr     L1D1F                           ; 8702
        rts                                     ; 8705

; ----------------------------------------------------------------------------
        sty     $04                             ; 8706
        .byte   $1F                             ; 8708
L8709:  jsr     L985F                           ; 8709
        clc                                     ; 870C
        sta     $5B0C,x                         ; 870D
        bcs     L8742                           ; 8710
        cmp     $B9                             ; 8712
        ldx     $DC                             ; 8714
        ora     a:$30                           ; 8716
        .byte   $54                             ; 8719
        .byte   $8F                             ; 871A
        clc                                     ; 871B
        php                                     ; 871C
        php                                     ; 871D
        .byte   $14                             ; 871E
        .byte   $13                             ; 871F
        ora     ($13),y                         ; 8720
        .byte   $0F                             ; 8722
        ora     ($05),y                         ; 8723
        ora     $11                             ; 8725
        .byte   $0F                             ; 8727
        asl     $0C0F                           ; 8728
        ora     $190D                           ; 872B
        ora     $0A0C                           ; 872E
        .byte   $0C                             ; 8731
        php                                     ; 8732
        asl     a                               ; 8733
        .byte   $0C                             ; 8734
        ora     $0F0E                           ; 8735
        ora     ($13),y                         ; 8738
        .byte   $0F                             ; 873A
        cmp     $19                             ; 873B
        .byte   $A7                             ; 873D
        .byte   $DC                             ; 873E
        brk                                     ; 873F
        brk                                     ; 8740
        .byte   $0C                             ; 8741
L8742:  cli                                     ; 8742
        .byte   $E2                             ; 8743
        rts                                     ; 8744

; ----------------------------------------------------------------------------
        .byte   $CF                             ; 8745
        .byte   $0C                             ; 8746
        lsr     $8C,x                           ; 8747
        .byte   $0C                             ; 8749
        .byte   $1B                             ; 874A
        .byte   $1A                             ; 874B
        .byte   $1B                             ; 874C
L874D:  ora     L1B1F,x                         ; 874D
        rts                                     ; 8750

; ----------------------------------------------------------------------------
        ldy     $24                             ; 8751
        .byte   $5F                             ; 8753
        sty     $200C                           ; 8754
        .byte   $22                             ; 8757
        bit     $20                             ; 8758
        .byte   $CF                             ; 875A
        .byte   $0C                             ; 875B
        .byte   $1F                             ; 875C
        bit     $23                             ; 875D
        bit     $26                             ; 875F
        .byte   $27                             ; 8761
        bit     $60                             ; 8762
L8764:  .byte   $B3                             ; 8764
        .byte   $3C                             ; 8765
        rts                                     ; 8766

; ----------------------------------------------------------------------------
        stx     $06                             ; 8767
        .byte   $1F                             ; 8769
        rts                                     ; 876A

; ----------------------------------------------------------------------------
        .byte   $9F                             ; 876B
        clc                                     ; 876C
        .byte   $CF                             ; 876D
        .byte   $0C                             ; 876E
        rts                                     ; 876F

; ----------------------------------------------------------------------------
        stx     $06                             ; 8770
        .byte   $22                             ; 8772
        ldy     $0C                             ; 8773
        ldy     #$06                            ; 8775
        .byte   $1F                             ; 8777
        rts                                     ; 8778

; ----------------------------------------------------------------------------
        .byte   $9E                             ; 8779
        bit     $64                             ; 877A
        sty     $5D0C                           ; 877C
        .byte   $9E                             ; 877F
        bit     $5D                             ; 8780
        stx     $0C                             ; 8782
        .byte   $5D                             ; 8784
        .byte   $9E                             ; 8785
L8786:  bit     $56                             ; 8786
        sty     $590C                           ; 8788
        ldy     $583C,x                         ; 878B
        txa                                     ; 878E
        .byte   $0C                             ; 878F
        cli                                     ; 8790
        .byte   $0C                             ; 8791
        asl     $C5,x                           ; 8792
        .byte   $42                             ; 8794
        .byte   $A7                             ; 8795
        .byte   $DC                             ; 8796
        ora     #$10                            ; 8797
        brk                                     ; 8799
        .byte   $C3                             ; 879A
        sbc     $40CF                           ; 879B
        .byte   $62                             ; 879E
        tya                                     ; 879F
        php                                     ; 87A0
        .byte   $A7                             ; 87A1
        bpl     L874D                           ; 87A2
        php                                     ; 87A4
        tax                                     ; 87A5
        clc                                     ; 87A6
        .byte   $A7                             ; 87A7
        plp                                     ; 87A8
        ldy     $AA08                           ; 87A9
        asl     $2C                             ; 87AC
        rol     a                               ; 87AE
        .byte   $27                             ; 87AF
        lda     $10                             ; 87B0
        .byte   $67                             ; 87B2
        dey                                     ; 87B3
        .byte   $12                             ; 87B4
        .byte   $CF                             ; 87B5
        asl     $08AD,x                         ; 87B6
        bit     $272A                           ; 87B9
        ror     a                               ; 87BC
        tya                                     ; 87BD
        clc                                     ; 87BE
        .byte   $A7                             ; 87BF
        bpl     L8764                           ; 87C0
        php                                     ; 87C2
        lda     $10                             ; 87C3
        .byte   $67                             ; 87C5
        dey                                     ; 87C6
        clc                                     ; 87C7
        tax                                     ; 87C8
        php                                     ; 87C9
        cmp     ($6A),y                         ; 87CA
        stx     $18,y                           ; 87CC
        ror     a                               ; 87CE
        .byte   $87                             ; 87CF
        php                                     ; 87D0
        rol     a                               ; 87D1
        .byte   $27                             ; 87D2
        rol     a                               ; 87D3
        rol     a                               ; 87D4
        .byte   $27                             ; 87D5
        rol     a                               ; 87D6
        rol     a                               ; 87D7
        .byte   $27                             ; 87D8
        jmp     (L1898)                         ; 87D9

; ----------------------------------------------------------------------------
        tax                                     ; 87DC
        bpl     L8786                           ; 87DD
        php                                     ; 87DF
        tax                                     ; 87E0
        bpl     L884F                           ; 87E1
        dey                                     ; 87E3
        clc                                     ; 87E4
        lda     $D108                           ; 87E5
        adc     L1898                           ; 87E8
        bit     $10AA                           ; 87EB
        ldx     #$08                            ; 87EE
        lda     $10                             ; 87F0
        .byte   $67                             ; 87F2
        dey                                     ; 87F3
        php                                     ; 87F4
        cmp     $9C                             ; 87F5
        .byte   $A7                             ; 87F7
        .byte   $DC                             ; 87F8
        ora     a:$40                           ; 87F9
        .byte   $4F                             ; 87FC
        bcc     L880F                           ; 87FD
        eor     $1888,y                         ; 87FF
        .byte   $4F                             ; 8802
        dey                                     ; 8803
        php                                     ; 8804
        eor     L30B0,y                         ; 8805
        .byte   $54                             ; 8808
        bcc     L881B                           ; 8809
        cli                                     ; 880B
        dey                                     ; 880C
        clc                                     ; 880D
        .byte   $94                             ; 880E
L880F:  php                                     ; 880F
        cli                                     ; 8810
        bcs     L8843                           ; 8811
        eor     $1090                           ; 8813
        .byte   $57                             ; 8816
        dey                                     ; 8817
        clc                                     ; 8818
        .byte   $8D                             ; 8819
        php                                     ; 881A
L881B:  .byte   $57                             ; 881B
        bcs     L884E                           ; 881C
        .byte   $52                             ; 881E
        bcc     L8831                           ; 881F
        lsr     $88,x                           ; 8821
        clc                                     ; 8823
        .byte   $92                             ; 8824
        php                                     ; 8825
        lsr     $B0,x                           ; 8826
        bmi     L8875                           ; 8828
L882A:  bcc     L883C                           ; 882A
        eor     $88,x                           ; 882C
        clc                                     ; 882E
        .byte   $8B                             ; 882F
        php                                     ; 8830
L8831:  eor     $B0,x                           ; 8831
        bmi     L8886                           ; 8833
        bcc     L8847                           ; 8835
L8837:  eor     $88,x                           ; 8837
L8839:  clc                                     ; 8839
        sta     ($08),y                         ; 883A
L883C:  eor     $B0,x                           ; 883C
        bmi     L888A                           ; 883E
        bcc     L8852                           ; 8840
        .byte   $54                             ; 8842
L8843:  dey                                     ; 8843
        clc                                     ; 8844
        txa                                     ; 8845
        php                                     ; 8846
L8847:  .byte   $54                             ; 8847
        bcs     L887A                           ; 8848
        cmp     $FC                             ; 884A
        .byte   $A7                             ; 884C
        .byte   $DC                             ; 884D
L884E:  brk                                     ; 884E
L884F:  brk                                     ; 884F
        .byte   $0C                             ; 8850
        .byte   $CF                             ; 8851
L8852:  bpl     L88B3                           ; 8852
        dey                                     ; 8854
        jsr     LB05F                           ; 8855
        bmi     L882A                           ; 8858
        .byte   $FF                             ; 885A
        .byte   $C7                             ; 885B
        .byte   $04                             ; 885C
        eor     ($A8),y                         ; 885D
        .byte   $C2                             ; 885F
        .byte   $0C                             ; 8860
        .byte   $CF                             ; 8861
        bpl     L88BF                           ; 8862
        dey                                     ; 8864
        jsr     LB05B                           ; 8865
        bmi     L8839                           ; 8868
        bpl     L88C6                           ; 886A
        dey                                     ; 886C
        jsr     LB05A                           ; 886D
        bmi     L8837                           ; 8870
        eor     ($A8),y                         ; 8872
        .byte   $DC                             ; 8874
L8875:  brk                                     ; 8875
        jsr     L5844                           ; 8876
        .byte   $93                             ; 8879
L887A:  clc                                     ; 887A
        stx     $10,y                           ; 887B
        stx     $08,y                           ; 887D
        stx     $18,y                           ; 887F
        stx     $10,y                           ; 8881
        stx     $08,y                           ; 8883
        .byte   $C5                             ; 8885
L8886:  sei                                     ; 8886
        tay                                     ; 8887
        .byte   $DC                             ; 8888
        .byte   $06                             ; 8889
L888A:  bpl     L888C                           ; 888A
L888C:  .byte   $C3                             ; 888C
        .byte   $AB                             ; 888D
        .byte   $CF                             ; 888E
        .byte   $0C                             ; 888F
        lsr     $98,x                           ; 8890
        .byte   $0C                             ; 8892
        .byte   $1B                             ; 8893
        ora     $221E,x                         ; 8894
        .byte   $27                             ; 8897
        rol     a                               ; 8898
        ldx     $AC18                           ; 8899
        .byte   $0C                             ; 889C
        rol     a                               ; 889D
        and     #$2A                            ; 889E
        .byte   $27                             ; 88A0
        and     $67                             ; 88A1
        bne     L88F5                           ; 88A3
        .byte   $FF                             ; 88A5
        .byte   $DC                             ; 88A6
        asl     $20                             ; 88A7
        brk                                     ; 88A9
        .byte   $CF                             ; 88AA
        rts                                     ; 88AB

; ----------------------------------------------------------------------------
        .byte   $67                             ; 88AC
        dex                                     ; 88AD
        clc                                     ; 88AE
        .byte   $23                             ; 88AF
        ldy     #$30                            ; 88B0
        .byte   $9F                             ; 88B2
L88B3:  .byte   $03                             ; 88B3
        ora     $4A9F,x                         ; 88B4
        .byte   $FF                             ; 88B7
        .byte   $DC                             ; 88B8
        brk                                     ; 88B9
        brk                                     ; 88BA
        .byte   $0C                             ; 88BB
        .byte   $CF                             ; 88BC
        rts                                     ; 88BD

; ----------------------------------------------------------------------------
        .byte   $57                             ; 88BE
L88BF:  bne     L88D9                           ; 88BF
        .byte   $14                             ; 88C1
        asl     $0A,x                           ; 88C2
        .byte   $8F                             ; 88C4
        .byte   $50                             ; 88C5
L88C6:  .byte   $FF                             ; 88C6
        .byte   $DC                             ; 88C7
        .byte   $0F                             ; 88C8
        jsr     LC300                           ; 88C9
        sbc     ($67,x)                         ; 88CC
        sty     $06                             ; 88CE
        .byte   $27                             ; 88D0
        and     #$29                            ; 88D1
        .byte   $2B                             ; 88D3
        .byte   $2B                             ; 88D4
        bit     $2E2C                           ; 88D5
        .byte   $2E                             ; 88D8
L88D9:  and     ($31),y                         ; 88D9
        .byte   $33                             ; 88DB
        .byte   $CF                             ; 88DC
        .byte   $02                             ; 88DD
        .byte   $73                             ; 88DE
        .byte   $83                             ; 88DF
        .byte   $04                             ; 88E0
        .byte   $73                             ; 88E1
        ldy     $30                             ; 88E2
        cmp     $67                             ; 88E4
        .byte   $AF                             ; 88E6
        .byte   $DC                             ; 88E7
        .byte   $0F                             ; 88E8
        bmi     L88EB                           ; 88E9
L88EB:  .byte   $5F                             ; 88EB
        sty     $06                             ; 88EC
        .byte   $1F                             ; 88EE
        jsr     L2220                           ; 88EF
        .byte   $22                             ; 88F2
        and     $25                             ; 88F3
L88F5:  and     #$29                            ; 88F5
        bit     $2B2C                           ; 88F7
        .byte   $CF                             ; 88FA
        .byte   $02                             ; 88FB
        .byte   $6B                             ; 88FC
        .byte   $83                             ; 88FD
        .byte   $04                             ; 88FE
        .byte   $6B                             ; 88FF
        ldy     $30                             ; 8900
        cmp     $A5                             ; 8902
        .byte   $AF                             ; 8904
        .byte   $DC                             ; 8905
        brk                                     ; 8906
        brk                                     ; 8907
        .byte   $0C                             ; 8908
        .byte   $4F                             ; 8909
        sty     $06                             ; 890A
        .byte   $0F                             ; 890C
        asl     $16,x                           ; 890D
        .byte   $1B                             ; 890F
        .byte   $1B                             ; 8910
        ora     $191D,x                         ; 8911
        ora     $1616,y                         ; 8914
        .byte   $0F                             ; 8917
        .byte   $CF                             ; 8918
        .byte   $02                             ; 8919
        .byte   $4F                             ; 891A
        .byte   $83                             ; 891B
        .byte   $04                             ; 891C
        .byte   $4F                             ; 891D
        ldy     $30                             ; 891E
        cmp     $D9                             ; 8920
        .byte   $AF                             ; 8922
        .byte   $DC                             ; 8923
        ora     a:$10                           ; 8924
        .byte   $C3                             ; 8927
        .byte   $BB                             ; 8928
        .byte   $73                             ; 8929
        tya                                     ; 892A
        clc                                     ; 892B
        and     ($B0),y                         ; 892C
        .byte   $0C                             ; 892E
        ldx     $A904                           ; 892F
        php                                     ; 8932
        jmp     (L2E05)                         ; 8933

; ----------------------------------------------------------------------------
        bmi     L89A6                           ; 8936
        bcs     L896A                           ; 8938
        .byte   $FF                             ; 893A
        .byte   $DC                             ; 893B
        ora     a:$20                           ; 893C
        .byte   $6B                             ; 893F
        .byte   $93                             ; 8940
        clc                                     ; 8941
        .byte   $2B                             ; 8942
        ldy     $AB0C                           ; 8943
        .byte   $04                             ; 8946
        ldy     $08                             ; 8947
        adc     #$05                            ; 8949
        and     #$29                            ; 894B
        .byte   $6B                             ; 894D
        bcs     L8980                           ; 894E
        .byte   $FF                             ; 8950
        .byte   $DC                             ; 8951
        brk                                     ; 8952
        brk                                     ; 8953
        .byte   $0C                             ; 8954
L8955:  cli                                     ; 8955
        .byte   $89                             ; 8956
        .byte   $0C                             ; 8957
        cli                                     ; 8958
        .byte   $83                             ; 8959
        .byte   $04                             ; 895A
        cli                                     ; 895B
        dey                                     ; 895C
        php                                     ; 895D
        .byte   $5B                             ; 895E
        ora     $1B                             ; 895F
        .byte   $1B                             ; 8961
        eor     $0C8A,x                         ; 8962
        eor     $0483,x                         ; 8965
        .byte   $5D                             ; 8968
        .byte   $8C                             ; 8969
L896A:  php                                     ; 896A
        eor     $1905,y                         ; 896B
        ora     LB05B,y                         ; 896E
        .byte   $30                             ; 8971
L8972:  .byte   $FF                             ; 8972
        .byte   $DC                             ; 8973
        bpl     L8976                           ; 8974
L8976:  brk                                     ; 8976
        .byte   $C3                             ; 8977
        inc     $C5,x                           ; 8978
        and     $C0AA,y                         ; 897A
        ora     #$62                            ; 897D
        .byte   $A4                             ; 897F
L8980:  bit     $A7                             ; 8980
        clc                                     ; 8982
        .byte   $2B                             ; 8983
        ldx     $AD0C                           ; 8984
        bit     $AC                             ; 8987
        asl     $2D                             ; 8989
        .byte   $73                             ; 898B
        .byte   $9C                             ; 898C
        bit     $A7                             ; 898D
        asl     $29                             ; 898F
        ror     a                               ; 8991
        cpx     #$24                            ; 8992
        lda     #$18                            ; 8994
        .byte   $A7                             ; 8996
        .byte   $0C                             ; 8997
        and     $29                             ; 8998
        .byte   $A7                             ; 899A
        rts                                     ; 899B

; ----------------------------------------------------------------------------
        cmp     ($27),y                         ; 899C
        .byte   $FF                             ; 899E
        .byte   $DC                             ; 899F
        bpl     L89C2                           ; 89A0
L89A2:  brk                                     ; 89A2
        bne     L89A2                           ; 89A3
        .byte   $C5                             ; 89A5
L89A6:  and     $D0AA,y                         ; 89A6
        .byte   $03                             ; 89A9
        cpy     #$0D                            ; 89AA
        eor     L0C8C,y                         ; 89AC
        lsr     $04,x                           ; 89AF
        .byte   $0F                             ; 89B1
        eor     $560C,y                         ; 89B2
        .byte   $04                             ; 89B5
        .byte   $0F                             ; 89B6
        eor     $4F0C,y                         ; 89B7
        .byte   $04                             ; 89BA
        cli                                     ; 89BB
        .byte   $0C                             ; 89BC
        eor     $04,x                           ; 89BD
        .byte   $0F                             ; 89BF
        cli                                     ; 89C0
        .byte   $0C                             ; 89C1
L89C2:  eor     $04,x                           ; 89C2
        .byte   $0F                             ; 89C4
        cli                                     ; 89C5
        .byte   $0C                             ; 89C6
        .byte   $4F                             ; 89C7
        .byte   $04                             ; 89C8
        .byte   $57                             ; 89C9
        .byte   $0C                             ; 89CA
        lsr     $04,x                           ; 89CB
        .byte   $0F                             ; 89CD
        eor     $540C,y                         ; 89CE
        .byte   $04                             ; 89D1
        ora     $0C59                           ; 89D2
        .byte   $54                             ; 89D5
        .byte   $04                             ; 89D6
        .byte   $4F                             ; 89D7
        .byte   $9C                             ; 89D8
        .byte   $3C                             ; 89D9
        .byte   $5A                             ; 89DA
        sty     $06                             ; 89DB
        .byte   $1A                             ; 89DD
        .byte   $1B                             ; 89DE
        .byte   $1B                             ; 89DF
        asl     $16,x                           ; 89E0
        .byte   $4F                             ; 89E2
        cpx     #$60                            ; 89E3
        .byte   $FF                             ; 89E5
        .byte   $DC                             ; 89E6
        brk                                     ; 89E7
        brk                                     ; 89E8
        .byte   $0C                             ; 89E9
        .byte   $CF                             ; 89EA
        rts                                     ; 89EB

; ----------------------------------------------------------------------------
        .byte   $5F                             ; 89EC
        stx     $06                             ; 89ED
        ora     L1B1F,x                         ; 89EF
        .byte   $C7                             ; 89F2
        .byte   $03                             ; 89F3
        cpx     $1DA9                           ; 89F4
        .byte   $1B                             ; 89F7
        ora     $C718,x                         ; 89F8
        .byte   $03                             ; 89FB
        inc     $A9,x                           ; 89FC
        asl     $1E1D,x                         ; 89FE
        .byte   $1B                             ; 8A01
        asl     L201D,x                         ; 8A02
        asl     $1D20,x                         ; 8A05
        jsr     L201E                           ; 8A08
        ora     $1E20,x                         ; 8A0B
        .byte   $CF                             ; 8A0E
        .byte   $0C                             ; 8A0F
        rts                                     ; 8A10

; ----------------------------------------------------------------------------
        .byte   $04                             ; 8A11
        jsr     L2222                           ; 8A12
        ora     $1F1D,x                         ; 8A15
L8A18:  .byte   $5F                             ; 8A18
        lda     $D12A,y                         ; 8A19
        .byte   $5F                             ; 8A1C
        cpy     $FF60                           ; 8A1D
        .byte   $DC                             ; 8A20
        bpl     L8A43                           ; 8A21
        .byte   $44                             ; 8A23
        jmp     L0698                           ; 8A24

; ----------------------------------------------------------------------------
        ora     $0F0E                           ; 8A27
        bcc     L8A34                           ; 8A2A
        ora     ($12),y                         ; 8A2C
        .byte   $93                             ; 8A2E
        .byte   $0C                             ; 8A2F
        .byte   $14                             ; 8A30
        ora     $16,x                           ; 8A31
        .byte   $97                             ; 8A33
L8A34:  clc                                     ; 8A34
        clc                                     ; 8A35
        ora     $FF1A,y                         ; 8A36
        .byte   $74                             ; 8A39
        sty     $04                             ; 8A3A
        and     $36,x                           ; 8A3C
        .byte   $37                             ; 8A3E
        rol     $35,x                           ; 8A3F
        .byte   $34                             ; 8A41
        .byte   $33                             ; 8A42
L8A43:  .byte   $32                             ; 8A43
        and     ($30),y                         ; 8A44
        .byte   $2F                             ; 8A46
        rol     $2C2D                           ; 8A47
        .byte   $2B                             ; 8A4A
        rol     a                               ; 8A4B
        and     #$28                            ; 8A4C
        .byte   $27                             ; 8A4E
        rol     $25                             ; 8A4F
        bit     $23                             ; 8A51
        dec     $DC                             ; 8A53
        ora     a:$40                           ; 8A55
        .byte   $C3                             ; 8A58
        cmp     $D6                             ; 8A59
        brk                                     ; 8A5B
        .byte   $53                             ; 8A5C
        .byte   $89                             ; 8A5D
        .byte   $0C                             ; 8A5E
        .byte   $13                             ; 8A5F
        .byte   $CF                             ; 8A60
        bit     $53                             ; 8A61
        sty     $06                             ; 8A63
        .byte   $14                             ; 8A65
        .byte   $17                             ; 8A66
        clc                                     ; 8A67
        .byte   $5A                             ; 8A68
        .byte   $89                             ; 8A69
        .byte   $0C                             ; 8A6A
        .byte   $CF                             ; 8A6B
        bit     $13                             ; 8A6C
        .byte   $13                             ; 8A6E
        .byte   $47                             ; 8A6F
        .byte   $80                             ; 8A70
        bit     $53                             ; 8A71
        sty     $06                             ; 8A73
        .byte   $14                             ; 8A75
        .byte   $13                             ; 8A76
        ora     ($4E),y                         ; 8A77
        .byte   $89                             ; 8A79
        .byte   $0C                             ; 8A7A
        .byte   $CF                             ; 8A7B
        bit     $C7                             ; 8A7C
        ora     ($5C,x)                         ; 8A7E
        tax                                     ; 8A80
        cmp     $E6                             ; 8A81
        tax                                     ; 8A83
        eor     ($80),y                         ; 8A84
        bit     $C5                             ; 8A86
        inc     $AA,x                           ; 8A88
        .byte   $CF                             ; 8A8A
        bit     $C7                             ; 8A8B
        ora     ($81,x)                         ; 8A8D
        tax                                     ; 8A8F
        .byte   $C5                             ; 8A90
L8A91:  inc     $AA                             ; 8A91
        .byte   $CF                             ; 8A93
        .byte   $0C                             ; 8A94
        cmp     $F6                             ; 8A95
        tax                                     ; 8A97
        .byte   $CF                             ; 8A98
        .byte   $0C                             ; 8A99
        .byte   $C7                             ; 8A9A
        ora     ($90,x)                         ; 8A9B
        tax                                     ; 8A9D
        cmp     $5C                             ; 8A9E
        tax                                     ; 8AA0
        .byte   $DC                             ; 8AA1
        asl     $40                             ; 8AA2
        brk                                     ; 8AA4
        .byte   $CF                             ; 8AA5
        cpy     #$CF                            ; 8AA6
        pha                                     ; 8AA8
        .byte   $C7                             ; 8AA9
        ora     ($A5,x)                         ; 8AAA
        tax                                     ; 8AAC
        .byte   $5F                             ; 8AAD
        cpx     #$60                            ; 8AAE
        .byte   $1A                             ; 8AB0
        ora     $1718,y                         ; 8AB1
        asl     $15,x                           ; 8AB4
        .byte   $14                             ; 8AB6
        .byte   $13                             ; 8AB7
        cmp     $A5                             ; 8AB8
        tax                                     ; 8ABA
        .byte   $DC                             ; 8ABB
        brk                                     ; 8ABC
        brk                                     ; 8ABD
        .byte   $0C                             ; 8ABE
        .byte   $53                             ; 8ABF
        .byte   $89                             ; 8AC0
        .byte   $0C                             ; 8AC1
        .byte   $13                             ; 8AC2
        .byte   $CF                             ; 8AC3
        bit     $13                             ; 8AC4
        .byte   $13                             ; 8AC6
        .byte   $CF                             ; 8AC7
        bmi     L8A91                           ; 8AC8
        .byte   $03                             ; 8ACA
        .byte   $BF                             ; 8ACB
        tax                                     ; 8ACC
        .byte   $53                             ; 8ACD
        .byte   $93                             ; 8ACE
        clc                                     ; 8ACF
        .byte   $13                             ; 8AD0
        .byte   $13                             ; 8AD1
        .byte   $13                             ; 8AD2
        .byte   $13                             ; 8AD3
        .byte   $C7                             ; 8AD4
        .byte   $03                             ; 8AD5
        cmp     $47AA                           ; 8AD6
        .byte   $89                             ; 8AD9
        .byte   $0C                             ; 8ADA
        .byte   $53                             ; 8ADB
        sty     $06                             ; 8ADC
        .byte   $13                             ; 8ADE
        .byte   $C7                             ; 8ADF
        .byte   $0F                             ; 8AE0
        cld                                     ; 8AE1
        tax                                     ; 8AE2
        cmp     $BF                             ; 8AE3
        tax                                     ; 8AE5
        .byte   $53                             ; 8AE6
        .byte   $89                             ; 8AE7
        .byte   $0C                             ; 8AE8
        .byte   $13                             ; 8AE9
        .byte   $CF                             ; 8AEA
        clc                                     ; 8AEB
        .byte   $53                             ; 8AEC
        sty     $06                             ; 8AED
        .byte   $14                             ; 8AEF
        .byte   $17                             ; 8AF0
        clc                                     ; 8AF1
        .byte   $5A                             ; 8AF2
        .byte   $89                             ; 8AF3
        .byte   $0C                             ; 8AF4
        dec     $53                             ; 8AF5
        .byte   $89                             ; 8AF7
        .byte   $0C                             ; 8AF8
        .byte   $13                             ; 8AF9
        .byte   $CF                             ; 8AFA
        clc                                     ; 8AFB
        .byte   $53                             ; 8AFC
        sty     $06                             ; 8AFD
        .byte   $14                             ; 8AFF
        .byte   $13                             ; 8B00
        ora     ($4E),y                         ; 8B01
        .byte   $89                             ; 8B03
        .byte   $0C                             ; 8B04
        dec     $DC                             ; 8B05
        ora     $0130                           ; 8B07
        .byte   $C3                             ; 8B0A
        tsx                                     ; 8B0B
        .byte   $CF                             ; 8B0C
        clc                                     ; 8B0D
        cmp     $BD                             ; 8B0E
L8B10:  .byte   $AB                             ; 8B10
        .byte   $CF                             ; 8B11
        clc                                     ; 8B12
        cmp     $BD                             ; 8B13
        .byte   $AB                             ; 8B15
        .byte   $47                             ; 8B16
        sty     $090C                           ; 8B17
        lsr     a                               ; 8B1A
        .byte   $9C                             ; 8B1B
        bit     $4A                             ; 8B1C
        sty     $4C0C                           ; 8B1E
        tya                                     ; 8B21
        bit     $4C                             ; 8B22
        sty     $4E0C                           ; 8B24
        .byte   $A3                             ; 8B27
        bit     $50                             ; 8B28
        stx     $06                             ; 8B2A
        ora     ($53),y                         ; 8B2C
        .byte   $9B                             ; 8B2E
        bit     $47                             ; 8B2F
        stx     $06                             ; 8B31
        ora     #$4A                            ; 8B33
        txs                                     ; 8B35
        bit     $4A                             ; 8B36
        sty     $4C0C                           ; 8B38
        sta     $4C24,y                         ; 8B3B
        sty     $490C                           ; 8B3E
        ldy     $24                             ; 8B41
        eor     L0686                           ; 8B43
        bpl     L8B9D                           ; 8B46
        txs                                     ; 8B48
        bmi     L8B10                           ; 8B49
        asl     $DCAB                           ; 8B4B
        asl     $0170                           ; 8B4E
        .byte   $CF                             ; 8B51
        clc                                     ; 8B52
        cmp     $0E                             ; 8B53
        ldy     $18CF                           ; 8B55
        cmp     $0E                             ; 8B58
        ldy     $0C9F                           ; 8B5A
        and     ($C5,x)                         ; 8B5D
        .byte   $5B                             ; 8B5F
        ldy     $06A1                           ; 8B60
        and     $2629                           ; 8B63
        ora     $2629,x                         ; 8B66
        and     ($1A,x)                         ; 8B69
        rol     $21                             ; 8B6B
        ora     $0C9F,x                         ; 8B6D
        and     ($C5,x)                         ; 8B70
        .byte   $5B                             ; 8B72
        ldy     $2125                           ; 8B73
        and     ($28),y                         ; 8B76
        lda     ($24),y                         ; 8B78
        .byte   $CF                             ; 8B7A
        .byte   $0C                             ; 8B7B
        cmp     $53                             ; 8B7C
        .byte   $AB                             ; 8B7E
        .byte   $DC                             ; 8B7F
        ora     $0D00                           ; 8B80
        .byte   $62                             ; 8B83
        tya                                     ; 8B84
        clc                                     ; 8B85
        cmp     $6D                             ; 8B86
        ldy     L8C61                           ; 8B88
        .byte   $0C                             ; 8B8B
        .byte   $22                             ; 8B8C
        cmp     $6D                             ; 8B8D
        ldy     L8C62                           ; 8B8F
        .byte   $0C                             ; 8B92
        bit     $66                             ; 8B93
        ldy     $24                             ; 8B95
        adc     #$8C                            ; 8B97
        .byte   $0C                             ; 8B99
        pla                                     ; 8B9A
        ldy     $24                             ; 8B9B
L8B9D:  .byte   $64                             ; 8B9D
        sty     $660C                           ; 8B9E
        .byte   $D4                             ; 8BA1
        .byte   $54                             ; 8BA2
        .byte   $64                             ; 8BA3
        sty     $660C                           ; 8BA4
        ldy     $24                             ; 8BA7
        adc     #$86                            ; 8BA9
        asl     $2B                             ; 8BAB
        pla                                     ; 8BAD
        ldy     $24                             ; 8BAE
        adc     #$86                            ; 8BB0
        asl     $2B                             ; 8BB2
        adc     $48C8                           ; 8BB4
        .byte   $62                             ; 8BB7
        tya                                     ; 8BB8
        clc                                     ; 8BB9
        cmp     $86                             ; 8BBA
        .byte   $AB                             ; 8BBC
        jmp     L2499                           ; 8BBD

; ----------------------------------------------------------------------------
        .byte   $4F                             ; 8BC0
        .byte   $1C                             ; 8BC1
        .byte   $4F                             ; 8BC2
        sty     $110C                           ; 8BC3
        .byte   $53                             ; 8BC6
        tya                                     ; 8BC7
        asl     L8651,x                         ; 8BC8
        asl     $4E                             ; 8BCB
        sty     $4C0C                           ; 8BCD
        bcc     L8BEA                           ; 8BD0
        jmp     L0C8C                           ; 8BD2

; ----------------------------------------------------------------------------
        asl     L9B4F                           ; 8BD5
        bit     $56                             ; 8BD8
        bit     $55                             ; 8BDA
        stx     $06                             ; 8BDC
        .byte   $13                             ; 8BDE
        eor     ($8C),y                         ; 8BDF
        .byte   $0C                             ; 8BE1
        .byte   $53                             ; 8BE2
        .byte   $9B                             ; 8BE3
        bit     $53                             ; 8BE4
        and     $51                             ; 8BE6
        .byte   $8C                             ; 8BE8
        .byte   $0C                             ; 8BE9
L8BEA:  .byte   $0F                             ; 8BEA
        lsr     $249C                           ; 8BEB
        asl     L8C4E                           ; 8BEE
        .byte   $0C                             ; 8BF1
        ora     ($53),y                         ; 8BF2
        txs                                     ; 8BF4
        bit     $53                             ; 8BF5
        bit     $51                             ; 8BF7
        sty     $0E0C                           ; 8BF9
        jmp     L249B                           ; 8BFC

; ----------------------------------------------------------------------------
        .byte   $0C                             ; 8BFF
        jmp     L0686                           ; 8C00

; ----------------------------------------------------------------------------
        asl     L8C4C                           ; 8C03
L8C06:  .byte   $0C                             ; 8C06
        .byte   $47                             ; 8C07
        tya                                     ; 8C08
        bit     $47                             ; 8C09
        ldy     $24                             ; 8C0B
        dec     $64                             ; 8C0D
        sta     $0C                             ; 8C0F
        .byte   $2B                             ; 8C11
        .byte   $27                             ; 8C12
        .byte   $2B                             ; 8C13
        bit     $2B                             ; 8C14
        .byte   $27                             ; 8C16
        .byte   $2B                             ; 8C17
        .byte   $22                             ; 8C18
        .byte   $2B                             ; 8C19
        lda     #$06                            ; 8C1A
L8C1C:  .byte   $27                             ; 8C1C
        ldx     $0C                             ; 8C1D
        bit     $2B                             ; 8C1F
        .byte   $27                             ; 8C21
        .byte   $2B                             ; 8C22
        .byte   $27                             ; 8C23
        rol     $2E2B                           ; 8C24
        .byte   $27                             ; 8C27
        rol     $06AD                           ; 8C28
        .byte   $2B                             ; 8C2B
        lda     #$0C                            ; 8C2C
        .byte   $2B                             ; 8C2E
        rol     $22                             ; 8C2F
        rol     $2B                             ; 8C31
        rol     $2E32                           ; 8C33
        and     $2429                           ; 8C36
        and     #$24                            ; 8C39
        and     #$2D                            ; 8C3B
        and     #$2B                            ; 8C3D
        .byte   $1F                             ; 8C3F
        .byte   $22                             ; 8C40
        rol     $1F                             ; 8C41
        .byte   $2B                             ; 8C43
        lda     #$06                            ; 8C44
        .byte   $27                             ; 8C46
        ldx     $0C                             ; 8C47
        bit     $27                             ; 8C49
        .byte   $2B                             ; 8C4B
L8C4C:  .byte   $27                             ; 8C4C
        .byte   $30                             ; 8C4D
L8C4E:  rol     $06AD                           ; 8C4E
        .byte   $2B                             ; 8C51
        lda     #$0C                            ; 8C52
        .byte   $2B                             ; 8C54
        .byte   $26                             ; 8C55
L8C56:  .byte   $22                             ; 8C56
        .byte   $26                             ; 8C57
L8C58:  .byte   $AB                             ; 8C58
        clc                                     ; 8C59
        .byte   $C6                             ; 8C5A
L8C5B:  .byte   $62                             ; 8C5B
        sta     $06                             ; 8C5C
        .byte   $1A                             ; 8C5E
        .byte   $1D                             ; 8C5F
        .byte   $22                             ; 8C60
L8C61:  .byte   $9D                             ; 8C61
L8C62:  .byte   $0C                             ; 8C62
        rol     $A4                             ; 8C63
        asl     $28                             ; 8C65
        .byte   $1F                             ; 8C67
        .byte   $24                             ; 8C68
L8C69:  .byte   $9C                             ; 8C69
        .byte   $0C                             ; 8C6A
        .byte   $1F                             ; 8C6B
L8C6C:  dec     $64                             ; 8C6C
        bcs     L8C88                           ; 8C6E
        .byte   $AB                             ; 8C70
        bmi     L8C1C                           ; 8C71
        .byte   $0C                             ; 8C73
        .byte   $27                             ; 8C74
        ror     $97                             ; 8C75
        clc                                     ; 8C77
        ror     $C8                             ; 8C78
        asl     $24                             ; 8C7A
        ldx     #$0C                            ; 8C7C
        ldy     $18                             ; 8C7E
        .byte   $A7                             ; 8C80
        .byte   $0C                             ; 8C81
        and     #$AB                            ; 8C82
        clc                                     ; 8C84
        ldx     $AD30                           ; 8C85
L8C88:  asl     $2B                             ; 8C88
        lda     #$0C                            ; 8C8A
        .byte   $AB                             ; 8C8C
        pha                                     ; 8C8D
        ldx     $300C                           ; 8C8E
        lda     $AB48                           ; 8C91
        .byte   $0C                             ; 8C94
        and     #$AB                            ; 8C95
        pha                                     ; 8C97
        lda     #$0C                            ; 8C98
        rol     $A4                             ; 8C9A
        pha                                     ; 8C9C
        lda     ($06,x)                         ; 8C9D
        .byte   $22                             ; 8C9F
        lda     ($0C,x)                         ; 8CA0
        .byte   $5F                             ; 8CA2
        dec     $48                             ; 8CA3
        dec     $DC                             ; 8CA5
        .byte   $04                             ; 8CA7
        brk                                     ; 8CA8
        brk                                     ; 8CA9
        .byte   $C3                             ; 8CAA
        .byte   $CF                             ; 8CAB
        .byte   $62                             ; 8CAC
        cpx     #$04                            ; 8CAD
        .byte   $23                             ; 8CAF
        ldy     $58                             ; 8CB0
        lda     #$04                            ; 8CB2
        rol     a                               ; 8CB4
        .byte   $AB                             ; 8CB5
        cli                                     ; 8CB6
        tay                                     ; 8CB7
        .byte   $04                             ; 8CB8
        and     #$AA                            ; 8CB9
        cli                                     ; 8CBB
        ldy     $04                             ; 8CBC
        and     $A6                             ; 8CBE
        cli                                     ; 8CC0
        .byte   $A7                             ; 8CC1
        .byte   $04                             ; 8CC2
        plp                                     ; 8CC3
        lda     #$58                            ; 8CC4
        ldx     $04                             ; 8CC6
        .byte   $27                             ; 8CC8
        tay                                     ; 8CC9
        cli                                     ; 8CCA
        .byte   $9E                             ; 8CCB
        .byte   $04                             ; 8CCC
        .byte   $1F                             ; 8CCD
        ldy     #$58                            ; 8CCE
        lda     $04                             ; 8CD0
        rol     $A7                             ; 8CD2
        cli                                     ; 8CD4
        .byte   $C7                             ; 8CD5
        ora     ($AC,x)                         ; 8CD6
        ldy     L8C58                           ; 8CD8
        .byte   $0C                             ; 8CDB
        .byte   $17                             ; 8CDC
        clc                                     ; 8CDD
        .byte   $1A                             ; 8CDE
        clc                                     ; 8CDF
        .byte   $1A                             ; 8CE0
        .byte   $1B                             ; 8CE1
        ora     L1D1E,x                         ; 8CE2
        asl     $1E20,x                         ; 8CE5
        jsr     L1D1E                           ; 8CE8
        clc                                     ; 8CEB
        .byte   $17                             ; 8CEC
        clc                                     ; 8CED
        .byte   $1A                             ; 8CEE
        clc                                     ; 8CEF
        .byte   $1A                             ; 8CF0
        .byte   $1B                             ; 8CF1
        ora     L1D1E,x                         ; 8CF2
        asl     $2120,x                         ; 8CF5
        jsr     L2321                           ; 8CF8
        cmp     $AC                             ; 8CFB
        ldy     $0DDC                           ; 8CFD
        rts                                     ; 8D00

; ----------------------------------------------------------------------------
        brk                                     ; 8D01
        .byte   $CF                             ; 8D02
        clc                                     ; 8D03
        .byte   $5F                             ; 8D04
        sty     $1D0C                           ; 8D05
        .byte   $1B                             ; 8D08
        .byte   $1A                             ; 8D09
        clc                                     ; 8D0A
        asl     $CF,x                           ; 8D0B
        clc                                     ; 8D0D
        bit     $22                             ; 8D0E
        jsr     L1D1F                           ; 8D10
        .byte   $1B                             ; 8D13
        .byte   $CF                             ; 8D14
        clc                                     ; 8D15
        bit     $22                             ; 8D16
        and     ($1F,x)                         ; 8D18
        asl     $CF1B,x                         ; 8D1A
        clc                                     ; 8D1D
        .byte   $23                             ; 8D1E
        jsr     L1D1F                           ; 8D1F
        .byte   $1B                             ; 8D22
        .byte   $1A                             ; 8D23
        .byte   $CF                             ; 8D24
        clc                                     ; 8D25
        and     $24                             ; 8D26
        .byte   $22                             ; 8D28
        jsr     L1D1F                           ; 8D29
        .byte   $CF                             ; 8D2C
        clc                                     ; 8D2D
        .byte   $22                             ; 8D2E
        jsr     L1D1F                           ; 8D2F
        .byte   $1C                             ; 8D32
        ora     $18CF,y                         ; 8D33
        .byte   $1F                             ; 8D36
        ora     $1A1B,x                         ; 8D37
        clc                                     ; 8D3A
        asl     $CF,x                           ; 8D3B
        clc                                     ; 8D3D
        .byte   $23                             ; 8D3E
        jsr     L1D1F                           ; 8D3F
        .byte   $1B                             ; 8D42
        .byte   $1A                             ; 8D43
        .byte   $C7                             ; 8D44
        ora     ($02,x)                         ; 8D45
        lda     $1113                           ; 8D47
        .byte   $13                             ; 8D4A
        .byte   $14                             ; 8D4B
        .byte   $13                             ; 8D4C
        .byte   $14                             ; 8D4D
        asl     $18,x                           ; 8D4E
        ora     $1918,y                         ; 8D50
        .byte   $1B                             ; 8D53
        ora     $191B,y                         ; 8D54
        clc                                     ; 8D57
        .byte   $13                             ; 8D58
        ora     ($13),y                         ; 8D59
        .byte   $14                             ; 8D5B
        .byte   $13                             ; 8D5C
        .byte   $14                             ; 8D5D
        asl     $18,x                           ; 8D5E
        ora     $1918,y                         ; 8D60
        .byte   $1B                             ; 8D63
        .byte   $1C                             ; 8D64
        .byte   $1B                             ; 8D65
        .byte   $1C                             ; 8D66
        asl     $02C5,x                         ; 8D67
        lda     a:$DC                           ; 8D6A
        brk                                     ; 8D6D
        .byte   $0C                             ; 8D6E
        jmp     L0C8C                           ; 8D6F

; ----------------------------------------------------------------------------
        .byte   $13                             ; 8D72
        .byte   $1B                             ; 8D73
        .byte   $1A                             ; 8D74
        clc                                     ; 8D75
        asl     $14,x                           ; 8D76
        .byte   $13                             ; 8D78
        ora     ($18),y                         ; 8D79
        jsr     L1D1F                           ; 8D7B
        .byte   $1B                             ; 8D7E
        .byte   $1A                             ; 8D7F
        clc                                     ; 8D80
        asl     $2118                           ; 8D81
        .byte   $1F                             ; 8D84
        asl     $1A1B,x                         ; 8D85
        clc                                     ; 8D88
        .byte   $13                             ; 8D89
        .byte   $1A                             ; 8D8A
        .byte   $1F                             ; 8D8B
        ora     $1A1B,x                         ; 8D8C
        clc                                     ; 8D8F
        .byte   $17                             ; 8D90
        asl     a                               ; 8D91
        ora     ($1D),y                         ; 8D92
        .byte   $1B                             ; 8D94
        ora     $1618,y                         ; 8D95
        .byte   $14                             ; 8D98
        .byte   $0C                             ; 8D99
        .byte   $13                             ; 8D9A
        .byte   $1F                             ; 8D9B
        ora     $191C,x                         ; 8D9C
        clc                                     ; 8D9F
        asl     $05,x                           ; 8DA0
        .byte   $0C                             ; 8DA2
        .byte   $1B                             ; 8DA3
        .byte   $1A                             ; 8DA4
        clc                                     ; 8DA5
        asl     $14,x                           ; 8DA6
        .byte   $13                             ; 8DA8
        .byte   $07                             ; 8DA9
        .byte   $13                             ; 8DAA
        .byte   $1F                             ; 8DAB
        ora     $1A1B,x                         ; 8DAC
        clc                                     ; 8DAF
        .byte   $17                             ; 8DB0
        .byte   $C7                             ; 8DB1
        ora     ($6F,x)                         ; 8DB2
        lda     $0E0F                           ; 8DB4
        .byte   $0F                             ; 8DB7
        ora     ($0F),y                         ; 8DB8
        ora     ($13),y                         ; 8DBA
        .byte   $14                             ; 8DBC
        asl     $14,x                           ; 8DBD
        asl     $18,x                           ; 8DBF
        asl     $18,x                           ; 8DC1
        asl     $14,x                           ; 8DC3
        .byte   $0F                             ; 8DC5
        asl     $110F                           ; 8DC6
        .byte   $0F                             ; 8DC9
        ora     ($13),y                         ; 8DCA
        .byte   $14                             ; 8DCC
        asl     $14,x                           ; 8DCD
        asl     $18,x                           ; 8DCF
        ora     $1918,y                         ; 8DD1
        .byte   $1B                             ; 8DD4
        cmp     $6F                             ; 8DD5
        lda     $09DC                           ; 8DD7
        jsr     LC300                           ; 8DDA
        cmp     $C5                             ; 8DDD
        stx     $AE                             ; 8DDF
        cmp     $9B                             ; 8DE1
        ldx     $0464                           ; 8DE3
        rol     $22                             ; 8DE6
        .byte   $64                             ; 8DE8
        ldy     $24                             ; 8DE9
        bne     L8DF0                           ; 8DEB
        cmp     $86                             ; 8DED
        .byte   $AE                             ; 8DEF
L8DF0:  cmp     $9B                             ; 8DF0
        ldx     $FBD0                           ; 8DF2
        cmp     $9B                             ; 8DF5
        ldx     $02D0                           ; 8DF7
        .byte   $62                             ; 8DFA
        tya                                     ; 8DFB
        clc                                     ; 8DFC
        lda     $0C                             ; 8DFD
        ldx     #$18                            ; 8DFF
        lda     $0C                             ; 8E01
        .byte   $62                             ; 8E03
        ldy     $26                             ; 8E04
        .byte   $CF                             ; 8E06
        .byte   $22                             ; 8E07
        cmp     $DE                             ; 8E08
        lda     $09DC                           ; 8E0A
        bmi     L8E0F                           ; 8E0D
L8E0F:  cmp     $A8                             ; 8E0F
        ldx     $BDC5                           ; 8E11
        ldx     $045B                           ; 8E14
        ora     $611D,x                         ; 8E17
        ldy     $24                             ; 8E1A
        bne     L8E21                           ; 8E1C
        cmp     $A8                             ; 8E1E
        .byte   $AE                             ; 8E20
L8E21:  cmp     $BD                             ; 8E21
        ldx     $FBD0                           ; 8E23
        cmp     $BD                             ; 8E26
        ldx     $02D0                           ; 8E28
        .byte   $5F                             ; 8E2B
        tya                                     ; 8E2C
        clc                                     ; 8E2D
        ldy     #$0C                            ; 8E2E
        .byte   $9F                             ; 8E30
        clc                                     ; 8E31
        sta     $5F0C,x                         ; 8E32
        ldy     $26                             ; 8E35
        .byte   $CF                             ; 8E37
        .byte   $22                             ; 8E38
        cmp     $0F                             ; 8E39
        ldx     a:$DC                           ; 8E3B
        brk                                     ; 8E3E
        .byte   $0C                             ; 8E3F
        eor     ($9C),y                         ; 8E40
        bit     $0F                             ; 8E42
        ora     ($0F),y                         ; 8E44
        ora     L924F                           ; 8E46
        .byte   $12                             ; 8E49
        sta     ($06),y                         ; 8E4A
        .byte   $93                             ; 8E4C
        .byte   $0C                             ; 8E4D
        .byte   $54                             ; 8E4E
        .byte   $04                             ; 8E4F
        asl     $1A,x                           ; 8E50
        eor     $1292,x                         ; 8E52
        tya                                     ; 8E55
        asl     $91                             ; 8E56
        .byte   $0C                             ; 8E58
        .byte   $54                             ; 8E59
        .byte   $9C                             ; 8E5A
        bit     $12                             ; 8E5B
        .byte   $14                             ; 8E5D
        .byte   $12                             ; 8E5E
        bpl     L8EB3                           ; 8E5F
        .byte   $92                             ; 8E61
        .byte   $12                             ; 8E62
        sty     $06,x                           ; 8E63
        stx     $0C,y                           ; 8E65
        .byte   $57                             ; 8E67
        .byte   $9C                             ; 8E68
        bit     $99                             ; 8E69
        .byte   $12                             ; 8E6B
        .byte   $9B                             ; 8E6C
        asl     $9D                             ; 8E6D
        .byte   $0C                             ; 8E6F
        .byte   $9B                             ; 8E70
        clc                                     ; 8E71
        stx     $0C,y                           ; 8E72
        .byte   $9B                             ; 8E74
        clc                                     ; 8E75
        stx     $0C,y                           ; 8E76
        .byte   $9B                             ; 8E78
        clc                                     ; 8E79
        stx     $0C,y                           ; 8E7A
        .byte   $8F                             ; 8E7C
        .byte   $12                             ; 8E7D
        sta     ($06),y                         ; 8E7E
        .byte   $53                             ; 8E80
        sty     $C50C                           ; 8E81
        rti                                     ; 8E84

; ----------------------------------------------------------------------------
        ldx     $A461                           ; 8E85
        .byte   $12                             ; 8E88
        ldx     #$06                            ; 8E89
        ldy     $0C                             ; 8E8B
        lda     #$24                            ; 8E8D
        lda     ($12,x)                         ; 8E8F
        ldx     #$06                            ; 8E91
        ldy     $0C                             ; 8E93
        lda     #$18                            ; 8E95
        .byte   $67                             ; 8E97
        sty     $C60C                           ; 8E98
        adc     #$98                            ; 8E9B
        .byte   $12                             ; 8E9D
        .byte   $AB                             ; 8E9E
        asl     $AC                             ; 8E9F
        .byte   $0C                             ; 8EA1
        lda     #$18                            ; 8EA2
        .byte   $67                             ; 8EA4
        sty     $C60C                           ; 8EA5
        cli                                     ; 8EA8
        ldy     $24                             ; 8EA9
        .byte   $9F                             ; 8EAB
        .byte   $12                             ; 8EAC
        lda     ($06,x)                         ; 8EAD
        ldx     #$0C                            ; 8EAF
        .byte   $CF                             ; 8EB1
        .byte   $0C                             ; 8EB2
L8EB3:  clc                                     ; 8EB3
        ora     $129F,x                         ; 8EB4
        lda     ($06,x)                         ; 8EB7
        .byte   $62                             ; 8EB9
L8EBA:  sty     $C60C                           ; 8EBA
        rts                                     ; 8EBD

; ----------------------------------------------------------------------------
        ldy     $24                             ; 8EBE
        .byte   $9F                             ; 8EC0
        .byte   $12                             ; 8EC1
        ldy     #$06                            ; 8EC2
        .byte   $62                             ; 8EC4
        sty     $C60C                           ; 8EC5
        .byte   $DC                             ; 8EC8
L8EC9:  .byte   $02                             ; 8EC9
        brk                                     ; 8ECA
        brk                                     ; 8ECB
        .byte   $C3                             ; 8ECC
        sta     ($D0),y                         ; 8ECD
        .byte   $0C                             ; 8ECF
        cmp     $34                             ; 8ED0
        .byte   $AF                             ; 8ED2
        bne     L8EC9                           ; 8ED3
        lsr     $C8,x                           ; 8ED5
        pha                                     ; 8ED7
        cmp     $40                             ; 8ED8
        .byte   $AF                             ; 8EDA
        cmp     $D8                             ; 8EDB
        ldx     $03DC                           ; 8EDD
        rti                                     ; 8EE0

; ----------------------------------------------------------------------------
        brk                                     ; 8EE1
        cmp     $34                             ; 8EE2
        .byte   $AF                             ; 8EE4
        lsr     a                               ; 8EE5
        iny                                     ; 8EE6
        pha                                     ; 8EE7
        .byte   $CF                             ; 8EE8
        bcc     L8EBA                           ; 8EE9
        bcc     L8F43                           ; 8EEB
        iny                                     ; 8EED
        pha                                     ; 8EEE
        cmp     ($16),y                         ; 8EEF
        ora     $D1,x                           ; 8EF1
        ora     $54,x                           ; 8EF3
        eor     $54                             ; 8EF5
        tya                                     ; 8EF7
        clc                                     ; 8EF8
        .byte   $17                             ; 8EF9
        ora     $C856,y                         ; 8EFA
        pha                                     ; 8EFD
        cmp     ($56),y                         ; 8EFE
        eor     $C5                             ; 8F00
        cpx     $DCAE                           ; 8F02
        brk                                     ; 8F05
        brk                                     ; 8F06
        .byte   $0C                             ; 8F07
L8F08:  bne     L8F11                           ; 8F08
        cmp     $34                             ; 8F0A
        .byte   $AF                             ; 8F0C
        bne     L8F08                           ; 8F0D
        .byte   $51                             ; 8F0F
L8F10:  iny                                     ; 8F10
L8F11:  pha                                     ; 8F11
        bne     L8F20                           ; 8F12
        cmp     $40                             ; 8F14
        .byte   $AF                             ; 8F16
        cmp     $40                             ; 8F17
        .byte   $AF                             ; 8F19
        bne     L8F10                           ; 8F1A
        .byte   $52                             ; 8F1C
        iny                                     ; 8F1D
        pha                                     ; 8F1E
        .byte   $D1                             ; 8F1F
L8F20:  .byte   $12                             ; 8F20
        ora     ($D1),y                         ; 8F21
        ora     ($50),y                         ; 8F23
        eor     $50                             ; 8F25
        tya                                     ; 8F27
        clc                                     ; 8F28
        .byte   $14                             ; 8F29
        asl     $53,x                           ; 8F2A
        iny                                     ; 8F2C
        pha                                     ; 8F2D
        cmp     ($53),y                         ; 8F2E
        eor     $C5                             ; 8F30
        .byte   $1C                             ; 8F32
        .byte   $AF                             ; 8F33
        .byte   $43                             ; 8F34
        sty     $0408                           ; 8F35
        .byte   $07                             ; 8F38
        asl     a                               ; 8F39
        .byte   $0B                             ; 8F3A
        asl     $0E0F                           ; 8F3B
        .byte   $0B                             ; 8F3E
        dec     $43                             ; 8F3F
        .byte   $93                             ; 8F41
        clc                                     ; 8F42
L8F43:  .byte   $43                             ; 8F43
        stx     $08                             ; 8F44
        .byte   $03                             ; 8F46
        .byte   $03                             ; 8F47
        .byte   $43                             ; 8F48
        .byte   $93                             ; 8F49
        clc                                     ; 8F4A
        .byte   $03                             ; 8F4B
        .byte   $43                             ; 8F4C
        .byte   $89                             ; 8F4D
        .byte   $0C                             ; 8F4E
        .byte   $03                             ; 8F4F
        .byte   $43                             ; 8F50
        .byte   $93                             ; 8F51
        clc                                     ; 8F52
        dec     $DC                             ; 8F53
        .byte   $0C                             ; 8F55
        jsr     LC300                           ; 8F56
        .byte   $FF                             ; 8F59
        .byte   $67                             ; 8F5A
        sty     $2B08                           ; 8F5B
        rol     L866F                           ; 8F5E
        .byte   $0C                             ; 8F61
        and     ($2C),y                         ; 8F62
        ror     $24A4                           ; 8F64
        .byte   $C3                             ; 8F67
        dec     $08C0                           ; 8F68
        .byte   $62                             ; 8F6B
        stx     $06                             ; 8F6C
        .byte   $27                             ; 8F6E
        bit     $29                             ; 8F6F
        rol     $2B                             ; 8F71
        .byte   $27                             ; 8F73
        bit     $2B26                           ; 8F74
        bit     $29                             ; 8F77
        .byte   $C7                             ; 8F79
        .byte   $02                             ; 8F7A
        .byte   $6B                             ; 8F7B
        .byte   $AF                             ; 8F7C
        .byte   $22                             ; 8F7D
        .byte   $27                             ; 8F7E
        bit     $29                             ; 8F7F
        rol     $2B                             ; 8F81
        .byte   $27                             ; 8F83
        bit     $302C                           ; 8F84
        bmi     L8FBC                           ; 8F87
        bne     L8F8E                           ; 8F89
L8F8B:  .byte   $C7                             ; 8F8B
        ora     ($6B),y                         ; 8F8C
L8F8E:  .byte   $AF                             ; 8F8E
        bne     L8F8B                           ; 8F8F
        cmp     $6B                             ; 8F91
        .byte   $AF                             ; 8F93
        .byte   $DC                             ; 8F94
        .byte   $0C                             ; 8F95
        bmi     L8F98                           ; 8F96
L8F98:  .byte   $62                             ; 8F98
        sty     $2708                           ; 8F99
        .byte   $2B                             ; 8F9C
        jmp     (L0C86)                         ; 8F9D

; ----------------------------------------------------------------------------
        bit     $6B29                           ; 8FA0
        ldy     $24                             ; 8FA3
        .byte   $4F                             ; 8FA5
        stx     $4F12                           ; 8FA6
        sty     $06                             ; 8FA9
        .byte   $4F                             ; 8FAB
        .byte   $93                             ; 8FAC
        clc                                     ; 8FAD
        lsr     a                               ; 8FAE
        stx     $0C                             ; 8FAF
        asl     $C7,x                           ; 8FB1
        .byte   $02                             ; 8FB3
        lda     $AF                             ; 8FB4
        .byte   $4F                             ; 8FB6
        .byte   $04                             ; 8FB7
        asl     a                               ; 8FB8
        asl     $0F,x                           ; 8FB9
        asl     a                               ; 8FBB
L8FBC:  asl     $D0,x                           ; 8FBC
        .byte   $03                             ; 8FBE
L8FBF:  .byte   $C7                             ; 8FBF
        ora     ($A5),y                         ; 8FC0
        .byte   $AF                             ; 8FC2
        bne     L8FBF                           ; 8FC3
        cmp     $A5                             ; 8FC5
        .byte   $AF                             ; 8FC7
        .byte   $DC                             ; 8FC8
        brk                                     ; 8FC9
        brk                                     ; 8FCA
        .byte   $0C                             ; 8FCB
        .byte   $5F                             ; 8FCC
        sty     $2208                           ; 8FCD
        .byte   $27                             ; 8FD0
        pla                                     ; 8FD1
        stx     $0C                             ; 8FD2
        and     #$25                            ; 8FD4
        .byte   $67                             ; 8FD6
        ldy     $24                             ; 8FD7
        .byte   $5F                             ; 8FD9
        stx     $0C                             ; 8FDA
        jsr     L2422                           ; 8FDC
        .byte   $22                             ; 8FDF
        jsr     L02C7                           ; 8FE0
        cmp     $1FAF,y                         ; 8FE3
        jsr     L2422                           ; 8FE6
        .byte   $27                             ; 8FE9
        bit     $03D0                           ; 8FEA
L8FED:  .byte   $C7                             ; 8FED
        ora     ($D9),y                         ; 8FEE
        .byte   $AF                             ; 8FF0
        bne     L8FED                           ; 8FF1
        cmp     $D9                             ; 8FF3
        .byte   $AF                             ; 8FF5
        .byte   $DC                             ; 8FF6
        php                                     ; 8FF7
        brk                                     ; 8FF8
        brk                                     ; 8FF9
        .byte   $C3                             ; 8FFA
        .byte   $FF                             ; 8FFB
        .byte   $CF                             ; 8FFC
        .byte   $2F                             ; 8FFD
        .byte   $DA                             ; 8FFE
        .byte   $FF                             ; 8FFF
        pha                                     ; 9000
        jsr     LE95B                           ; 9001
        pla                                     ; 9004
        jsr     LDE5B                           ; 9005
        asl     a                               ; 9008
        php                                     ; 9009
        sta     $0422                           ; 900A
        ldx     $0415                           ; 900D
        beq     L901B                           ; 9010
        ldx     #$00                            ; 9012
        stx     $0415                           ; 9014
        cmp     #$1C                            ; 9017
        beq     L906C                           ; 9019
L901B:  tax                                     ; 901B
        lda     $BBA2,x                         ; 901C
        ora     $BBA1,x                         ; 901F
        bne     L9026                           ; 9022
        plp                                     ; 9024
        rts                                     ; 9025

; ----------------------------------------------------------------------------
L9026:  lda     $042E                           ; 9026
        sta     $0423                           ; 9029
        .byte   $B0                             ; 902C
L902D:  .byte   $0F                             ; 902D
        .byte   $A9                             ; 902E
L902F:  brk                                     ; 902F
        sta     $042E                           ; 9030
        lda     #$23                            ; 9033
        sta     $0426                           ; 9035
        lda     #$33                            ; 9038
        sta     $0427                           ; 903A
L903D:  lda     $042E                           ; 903D
        bne     L9047                           ; 9040
        lda     #$DA                            ; 9042
        sta     $0423                           ; 9044
L9047:  lda     $0423                           ; 9047
        and     #$07                            ; 904A
        asl     a                               ; 904C
        tax                                     ; 904D
L904E:  stx     $04                             ; 904E
        lda     $B06C,x                         ; 9050
        sta     $09                             ; 9053
        lda     $B06D,x                         ; 9055
        sta     $08                             ; 9058
        lda     #$12                            ; 905A
        sta     $0A                             ; 905C
        jsr     LDDEA                           ; 905E
        jsr     LE95B                           ; 9061
        ldx     $04                             ; 9064
        inx                                     ; 9066
        inx                                     ; 9067
        cpx     #$0C                            ; 9068
        bcc     L904E                           ; 906A
L906C:  plp                                     ; 906C
        bne     L9078                           ; 906D
        rts                                     ; 906F

; ----------------------------------------------------------------------------
        .byte   $62                             ; 9070
        .byte   $22                             ; 9071
        ldx     #$22                            ; 9072
        .byte   $E2                             ; 9074
        .byte   $22                             ; 9075
        .byte   $22                             ; 9076
        .byte   $23                             ; 9077
L9078:  jsr     LE95B                           ; 9078
        lda     $1C                             ; 907B
        ora     #$02                            ; 907D
        sta     $1C                             ; 907F
        lda     #$01                            ; 9081
        sta     $3D                             ; 9083
        ldx     $0423                           ; 9085
        bne     L9093                           ; 9088
        ldx     #$21                            ; 908A
        lda     #$2E                            ; 908C
        sta     $016A                           ; 908E
        inc     $3D                             ; 9091
L9093:  inx                                     ; 9093
        stx     $0169                           ; 9094
        ldx     $0422                           ; 9097
        lda     #$A0                            ; 909A
        clc                                     ; 909C
        adc     $BBA2,x                         ; 909D
        sta     $08                             ; 90A0
        lda     $BBA1,x                         ; 90A2
        and     #$07                            ; 90A5
        adc     #$B3                            ; 90A7
        sta     $09                             ; 90A9
        lda     $BBA1,x                         ; 90AB
        lsr     a                               ; 90AE
        lsr     a                               ; 90AF
        lsr     a                               ; 90B0
        and     #$03                            ; 90B1
        beq     L90CB                           ; 90B3
        tay                                     ; 90B5
        lda     $0500                           ; 90B6
        bmi     L90CB                           ; 90B9
        cmp     #$0D                            ; 90BB
        bcc     L90CB                           ; 90BD
        lda     $B1F1,y                         ; 90BF
        clc                                     ; 90C2
        adc     $08                             ; 90C3
        sta     $08                             ; 90C5
        bcc     L90CB                           ; 90C7
        inc     $09                             ; 90C9
L90CB:  jsr     LB1F5                           ; 90CB
        jsr     LB205                           ; 90CE
        ldx     $3D                             ; 90D1
        ldy     #$00                            ; 90D3
L90D5:  inc     $0423                           ; 90D5
L90D8:  inx                                     ; 90D8
        lda     ($08),y                         ; 90D9
        sta     $0168,x                         ; 90DB
        iny                                     ; 90DE
        cmp     #$80                            ; 90DF
        bcs     L90F5                           ; 90E1
        cmp     #$2F                            ; 90E3
        beq     L9117                           ; 90E5
        bcs     L90D8                           ; 90E7
        cmp     #$2E                            ; 90E9
        beq     L90D5                           ; 90EB
        cmp     #$2C                            ; 90ED
        beq     L90D8                           ; 90EF
        bcc     L90FF                           ; 90F1
        bcs     L910C                           ; 90F3
L90F5:  cmp     #$8B                            ; 90F5
        bcs     L90D8                           ; 90F7
        jsr     LB241                           ; 90F9
        jmp     LB0D9                           ; 90FC

; ----------------------------------------------------------------------------
L90FF:  sty     $3B                             ; 90FF
        clc                                     ; 9101
        adc     #$E0                            ; 9102
        jsr     LB331                           ; 9104
        ldy     $3B                             ; 9107
        jmp     LB0D9                           ; 9109

; ----------------------------------------------------------------------------
L910C:  lda     #$4F                            ; 910C
        sta     $0168,x                         ; 910E
        inx                                     ; 9111
        lda     #$2F                            ; 9112
        sta     $0168,x                         ; 9114
L9117:  stx     $3D                             ; 9117
        txa                                     ; 9119
        clc                                     ; 911A
        adc     #$06                            ; 911B
        sta     $0162                           ; 911D
        tay                                     ; 9120
        lda     #$00                            ; 9121
        sta     $0163,y                         ; 9123
        lda     $0422                           ; 9126
        ldy     #$00                            ; 9129
L912B:  .byte   $D9                             ; 912B
L912C:  cpx     $B1                             ; 912C
        bne     L913F                           ; 912E
        lda     $B1E7,y                         ; 9130
        sta     $0422                           ; 9133
        jsr     LB144                           ; 9136
        lda     $0422                           ; 9139
        jmp     LB000                           ; 913C

; ----------------------------------------------------------------------------
L913F:  iny                                     ; 913F
        cpy     #$03                            ; 9140
        bcc     L912B                           ; 9142
        ldx     #$06                            ; 9144
        lda     $042E                           ; 9146
        bne     L9157                           ; 9149
        lda     $0423                           ; 914B
        cmp     #$DE                            ; 914E
        bcc     L9154                           ; 9150
        lda     #$00                            ; 9152
L9154:  sta     $042E                           ; 9154
L9157:  lda     $B1EA,x                         ; 9157
        sta     $E8,x                           ; 915A
        dex                                     ; 915C
        bpl     L9157                           ; 915D
        stx     $18                             ; 915F
        lda     $1C                             ; 9161
        and     #$FD                            ; 9163
        sta     $1C                             ; 9165
L9167:  jsr     LE95B                           ; 9167
        lda     $18                             ; 916A
        bne     L9167                           ; 916C
        jsr     LB174                           ; 916E
        jmp     LE95B                           ; 9171

; ----------------------------------------------------------------------------
        lda     #$21                            ; 9174
        sta     $04                             ; 9176
        lda     $0425                           ; 9178
        bit     $0425                           ; 917B
        bmi     L9184                           ; 917E
        bvs     L9197                           ; 9180
        bpl     L9196                           ; 9182
L9184:  ldx     $030C                           ; 9184
        beq     L9197                           ; 9187
        cpx     #$05                            ; 9189
        bne     L918F                           ; 918B
        bvs     L9197                           ; 918D
L918F:  jsr     LE95B                           ; 918F
        dec     $04                             ; 9192
        bne     L918F                           ; 9194
L9196:  rts                                     ; 9196

; ----------------------------------------------------------------------------
L9197:  jsr     LE95B                           ; 9197
        dec     $04                             ; 919A
        lda     $04                             ; 919C
        ldx     #$7F                            ; 919E
        and     #$0F                            ; 91A0
        beq     L91AA                           ; 91A2
        ldx     #$2C                            ; 91A4
        and     #$07                            ; 91A6
        bne     L91AD                           ; 91A8
L91AA:  jsr     LB1C0                           ; 91AA
L91AD:  lda     $C2                             ; 91AD
        lsr     a                               ; 91AF
        bcc     L9197                           ; 91B0
        ldx     #$7F                            ; 91B2
        jsr     LB1C0                           ; 91B4
        lda     #$08                            ; 91B7
        sta     $04                             ; 91B9
        jsr     LB18F                           ; 91BB
        ldx     #$2C                            ; 91BE
        txa                                     ; 91C0
        ldx     $0162                           ; 91C1
        sta     $0166,x                         ; 91C4
        lda     $0426                           ; 91C7
        sta     $0163,x                         ; 91CA
        lda     $0427                           ; 91CD
        sta     $0164,x                         ; 91D0
        txa                                     ; 91D3
        clc                                     ; 91D4
        adc     #$04                            ; 91D5
        sta     $0162                           ; 91D7
        lda     #$01                            ; 91DA
        sta     $0165,x                         ; 91DC
        lsr     a                               ; 91DF
        sta     $0167,x                         ; 91E0
        rts                                     ; 91E3

; ----------------------------------------------------------------------------
        stx     $88                             ; 91E4
        bmi     L9254                           ; 91E6
        .byte   $6B                             ; 91E8
        .byte   $2B                             ; 91E9
        adc     #$01                            ; 91EA
        cpy     #$00                            ; 91EC
        ora     ($B3,x)                         ; 91EE
        clv                                     ; 91F0
        brk                                     ; 91F1
        ora     #$0B                            ; 91F2
        asl     $A1BD                           ; 91F4
        .byte   $BB                             ; 91F7
        sta     $0425                           ; 91F8
        and     #$20                            ; 91FB
        lsr     a                               ; 91FD
        lsr     a                               ; 91FE
        lsr     a                               ; 91FF
        lsr     a                               ; 9200
        sta     $0424                           ; 9201
        rts                                     ; 9204

; ----------------------------------------------------------------------------
        ldy     #$04                            ; 9205
        txa                                     ; 9207
L9208:  cmp     $B23C,y                         ; 9208
        beq     L9211                           ; 920B
        dey                                     ; 920D
        bpl     L9208                           ; 920E
        rts                                     ; 9210

; ----------------------------------------------------------------------------
L9211:  tya                                     ; 9211
        lsr     a                               ; 9212
        beq     L921B                           ; 9213
        lda     $0505                           ; 9215
        jmp     LB22E                           ; 9218

; ----------------------------------------------------------------------------
L921B:  lda     $05C1                           ; 921B
        jsr     LCFCF                           ; 921E
        ldx     #$02                            ; 9221
L9223:  lda     $0D,x                           ; 9223
        sta     $042B,x                         ; 9225
        dex                                     ; 9228
        bpl     L9223                           ; 9229
        lda     $05C0                           ; 922B
        jsr     LCFCF                           ; 922E
        ldx     #$02                            ; 9231
L9233:  lda     $0D,x                           ; 9233
        sta     $0428,x                         ; 9235
        dex                                     ; 9238
        bpl     L9233                           ; 9239
        rts                                     ; 923B

; ----------------------------------------------------------------------------
        jsr     L0CC6                           ; 923C
        lsr     a                               ; 923F
        lsr     $3B85                           ; 9240
        tya                                     ; 9243
        pha                                     ; 9244
        lda     $3B                             ; 9245
        and     #$0F                            ; 9247
        jsr     LE97D                           ; 9249
        .byte   $5C                             ; 924C
        .byte   $B2                             ; 924D
        .byte   $6C                             ; 924E
L924F:  .byte   $B2                             ; 924F
        cmp     ($B2),y                         ; 9250
        .byte   $D9                             ; 9252
        .byte   $B2                             ; 9253
L9254:  sbc     $B2                             ; 9254
        sbc     #$B2                            ; 9256
        .byte   $0C                             ; 9258
        .byte   $B3                             ; 9259
        asl     $ACB3,x                         ; 925A
        brk                                     ; 925D
        ora     $AD                             ; 925E
        .byte   $22                             ; 9260
        .byte   $04                             ; 9261
        cmp     #$40                            ; 9262
        beq     L926F                           ; 9264
        lda     $0501                           ; 9266
        jmp     LB272                           ; 9269

; ----------------------------------------------------------------------------
        ldy     $0503                           ; 926C
L926F:  lda     $0504                           ; 926F
        sta     $3B                             ; 9272
        dey                                     ; 9274
        clc                                     ; 9275
        tya                                     ; 9276
        bmi     L9281                           ; 9277
        ldy     $0424                           ; 9279
        cmp     #$0C                            ; 927C
        bcc     L9281                           ; 927E
        iny                                     ; 9280
L9281:  php                                     ; 9281
        cpy     #$02                            ; 9282
        bne     L9288                           ; 9284
        lda     #$FF                            ; 9286
L9288:  cpy     #$03                            ; 9288
        bne     L92A8                           ; 928A
        ldy     $05CC                           ; 928C
        beq     L9295                           ; 928F
        lda     #$12                            ; 9291
        bne     L929B                           ; 9293
L9295:  cmp     #$29                            ; 9295
        bcc     L92A8                           ; 9297
        sbc     #$29                            ; 9299
L929B:  asl     a                               ; 929B
        tay                                     ; 929C
        lda     $DE5D,y                         ; 929D
        pha                                     ; 92A0
        lda     $DE5C,y                         ; 92A1
        jsr     LB331                           ; 92A4
        pla                                     ; 92A7
L92A8:  jsr     LB331                           ; 92A8
        plp                                     ; 92AB
        ldy     $0424                           ; 92AC
        bcc     L92B2                           ; 92AF
        iny                                     ; 92B1
L92B2:  cpy     #$02                            ; 92B2
        bne     L92C3                           ; 92B4
        lda     #$DD                            ; 92B6
        jsr     LD41B                           ; 92B8
        lda     #$B4                            ; 92BB
        jsr     LB331                           ; 92BD
        jmp     LB2CE                           ; 92C0

; ----------------------------------------------------------------------------
L92C3:  cpy     #$01                            ; 92C3
        bne     L92CE                           ; 92C5
        lda     $3B                             ; 92C7
        beq     L92CE                           ; 92C9
        jsr     LD41B                           ; 92CB
L92CE:  pla                                     ; 92CE
        tay                                     ; 92CF
        rts                                     ; 92D0

; ----------------------------------------------------------------------------
        lda     $0502                           ; 92D1
        clc                                     ; 92D4
        adc     #$BB                            ; 92D5
        bne     L92DF                           ; 92D7
        lda     $0505                           ; 92D9
        clc                                     ; 92DC
        adc     #$E5                            ; 92DD
L92DF:  jsr     LB331                           ; 92DF
        pla                                     ; 92E2
        tay                                     ; 92E3
        rts                                     ; 92E4

; ----------------------------------------------------------------------------
        ldy     #$00                            ; 92E5
        beq     L92EB                           ; 92E7
        ldy     #$03                            ; 92E9
L92EB:  lda     $0428,y                         ; 92EB
        bne     L92FC                           ; 92EE
        iny                                     ; 92F0
        cpy     #$02                            ; 92F1
        beq     L92F9                           ; 92F3
        cpy     #$05                            ; 92F5
        bne     L92EB                           ; 92F7
L92F9:  lda     $0428,y                         ; 92F9
L92FC:  sta     $0168,x                         ; 92FC
        iny                                     ; 92FF
        inx                                     ; 9300
        cpy     #$03                            ; 9301
        beq     L9309                           ; 9303
        .byte   $C0                             ; 9305
L9306:  asl     $D0                             ; 9306
        .byte   $F0                             ; 9308
L9309:  pla                                     ; 9309
        tay                                     ; 930A
        rts                                     ; 930B

; ----------------------------------------------------------------------------
        lda     $0503                           ; 930C
        ldy     #$00                            ; 930F
        cmp     #$0B                            ; 9311
        bcc     L9316                           ; 9313
        iny                                     ; 9315
L9316:  lda     $05C2,y                         ; 9316
        clc                                     ; 9319
        adc     #$B5                            ; 931A
        bne     L92DF                           ; 931C
        lda     $0505                           ; 931E
        asl     a                               ; 9321
        tay                                     ; 9322
        lda     $B8B3,y                         ; 9323
        sta     $04                             ; 9326
        lda     $B8B4,y                         ; 9328
        jsr     LB368                           ; 932B
        pla                                     ; 932E
        tay                                     ; 932F
        rts                                     ; 9330

; ----------------------------------------------------------------------------
        cmp     #$FF                            ; 9331
        bne     L933D                           ; 9333
        lda     #$1E                            ; 9335
        sta     $04                             ; 9337
        lda     #$03                            ; 9339
        bne     L9368                           ; 933B
L933D:  cmp     #$A9                            ; 933D
        beq     L937B                           ; 933F
        and     #$7F                            ; 9341
        ldy     #$00                            ; 9343
        pha                                     ; 9345
L9346:  cmp     #$20                            ; 9346
        bcc     L9350                           ; 9348
        sbc     #$20                            ; 934A
        iny                                     ; 934C
        iny                                     ; 934D
        bne     L9346                           ; 934E
L9350:  lda     $B8E2,y                         ; 9350
        sta     $04                             ; 9353
        lda     $B8E3,y                         ; 9355
        sta     $05                             ; 9358
        pla                                     ; 935A
        tay                                     ; 935B
        lda     $BC8F,y                         ; 935C
        clc                                     ; 935F
        adc     $04                             ; 9360
        sta     $04                             ; 9362
        lda     $05                             ; 9364
        adc     #$00                            ; 9366
L9368:  sta     $05                             ; 9368
        ldy     #$00                            ; 936A
L936C:  lda     ($04),y                         ; 936C
        bmi     L9376                           ; 936E
        iny                                     ; 9370
        jsr     LD41B                           ; 9371
        bne     L936C                           ; 9374
L9376:  and     #$7F                            ; 9376
        jmp     LD41B                           ; 9378

; ----------------------------------------------------------------------------
L937B:  jsr     LD419                           ; 937B
        lda     #$22                            ; 937E
        jsr     LD41B                           ; 9380
        ldy     #$00                            ; 9383
L9385:  lda     $89,y                           ; 9385
        bne     L9395                           ; 9388
        jsr     LD419                           ; 938A
        iny                                     ; 938D
        cpy     #$02                            ; 938E
        bcc     L9385                           ; 9390
L9392:  lda     $89,y                           ; 9392
L9395:  jsr     LD41B                           ; 9395
        iny                                     ; 9398
        cpy     #$03                            ; 9399
        bcc     L9392                           ; 939B
        jmp     LD419                           ; 939D

; ----------------------------------------------------------------------------
        .byte   $80                             ; 93A0
        rol     $7D8E                           ; 93A1
        .byte   $2F                             ; 93A4
        .byte   $80                             ; 93A5
        bit     $33D4                           ; 93A6
        rol     $2CC9                           ; 93A9
        clv                                     ; 93AC
        bit     $2EBC                           ; 93AD
        .byte   $82                             ; 93B0
        and     $DD80                           ; 93B1
        bit     $2D13                           ; 93B4
        .byte   $80                             ; 93B7
        bit     $3742                           ; 93B8
        rol     L2E43,x                         ; 93BB
        cmp     #$2C                            ; 93BE
        clv                                     ; 93C0
        bit     $4130                           ; 93C1
        eor     ($3E,x)                         ; 93C4
        lsr     $2D                             ; 93C6
        .byte   $80                             ; 93C8
        rol     $4131                           ; 93C9
        .byte   $8B                             ; 93CC
        bcs     L9406                           ; 93CD
        .byte   $0F                             ; 93CF
        rol     $2CC9                           ; 93D0
        clv                                     ; 93D3
        bit     $3E41                           ; 93D4
        .byte   $33                             ; 93D7
        and     $2C81                           ; 93D8
        sbc     $2E                             ; 93DB
        sta     $2C33,x                         ; 93DD
        .byte   $DF                             ; 93E0
        bit     $2D84                           ; 93E1
        cmp     #$2C                            ; 93E4
        clv                                     ; 93E6
        bit     $349A                           ; 93E7
        .byte   $42                             ; 93EA
        and     $434C,x                         ; 93EB
        rol     $2CEE                           ; 93EE
        .byte   $E7                             ; 93F1
        rol     $2D81                           ; 93F2
        sta     ($2C,x)                         ; 93F5
        .byte   $E2                             ; 93F7
        rol     $DD80                           ; 93F8
        bit     $2D13                           ; 93FB
        sta     ($2E,x)                         ; 93FE
        cpx     L9B2C                           ; 9400
        .byte   $1B                             ; 9403
        .byte   $7D                             ; 9404
        .byte   $2F                             ; 9405
L9406:  .byte   $80                             ; 9406
        rol     $0F9B                           ; 9407
        rol     $7D81                           ; 940A
        .byte   $2F                             ; 940D
        sta     ($DD,x)                         ; 940E
        bit     $2EEB                           ; 9410
        lda     $E92C                           ; 9413
        and     $DD81                           ; 9416
        bit     $2EE8                           ; 9419
        lda     $E92C                           ; 941C
        and     $2C81                           ; 941F
        lda     $332C                           ; 9422
        sec                                     ; 9425
        .byte   $1B                             ; 9426
        and     $2C81                           ; 9427
        sbc     $042E                           ; 942A
        .byte   $3B                             ; 942D
        bit     $1B9B                           ; 942E
        and     $2EDB                           ; 9431
        ldy     L9E2C                           ; 9434
        .byte   $33                             ; 9437
        and     $2E80                           ; 9438
        lda     L9E2C                           ; 943B
        .byte   $33                             ; 943E
        and     $2C90                           ; 943F
        .byte   $DA                             ; 9442
        bit     $2C16                           ; 9443
        cpx     $422E                           ; 9446
        .byte   $37                             ; 9449
        .byte   $44                             ; 944A
        .byte   $43                             ; 944B
        bit     $35BC                           ; 944C
        and     $2CFF                           ; 944F
        sbc     $2C                             ; 9452
        sty     $2E                             ; 9454
        .byte   $34                             ; 9456
        .byte   $47                             ; 9457
        .byte   $3F                             ; 9458
        .byte   $34                             ; 9459
        eor     ($38,x)                         ; 945A
        .byte   $34                             ; 945C
        and     $3432,x                         ; 945D
        bit     $3E3F                           ; 9460
        ldy     $43,x                           ; 9463
        .byte   $42                             ; 9465
        rol     $2C8B                           ; 9466
        sta     $2C                             ; 9469
        nop                                     ; 946B
        and     $2E81                           ; 946C
        inc     $2C                             ; 946F
        .byte   $87                             ; 9471
        .byte   $4F                             ; 9472
        rol     $2C80                           ; 9473
        sbc     $2E                             ; 9476
        .byte   $87                             ; 9478
        and     $2CEB                           ; 9479
        bcs     L94AA                           ; 947C
        asl     $43                             ; 947E
        bit     $0634                           ; 9480
        .byte   $44                             ; 9483
        rol     $37,x                           ; 9484
        and     $2C80                           ; 9486
        .byte   $E3                             ; 9489
        rol     $DD81                           ; 948A
        bit     $2DB8                           ; 948D
        sta     ($DD,x)                         ; 9490
        bit     $2EB8                           ; 9492
        sbc     $2C                             ; 9495
        .byte   $E3                             ; 9497
        and     L802D,x                         ; 9498
        bit     $2EE3                           ; 949B
        sta     ($DD,x)                         ; 949E
        rol     $34BA                           ; 94A0
        .byte   $3C                             ; 94A3
        .byte   $34                             ; 94A4
        and     $2D43,x                         ; 94A5
        sta     ($DD,x)                         ; 94A8
L94AA:  rol     $34BA                           ; 94AA
        .byte   $3C                             ; 94AD
        .byte   $34                             ; 94AE
        and     L2C43,x                         ; 94AF
        sbc     $2E                             ; 94B2
        .byte   $E3                             ; 94B4
        and     L802D,x                         ; 94B5
        bit     $2E0D                           ; 94B8
        ldy     $CE,x                           ; 94BB
        bit     $2C30                           ; 94BD
        asl     L812D                           ; 94C0
        bit     $2E0D                           ; 94C3
        ldy     $CE,x                           ; 94C6
        rol     $2D07                           ; 94C8
        sta     ($2C,x)                         ; 94CB
        ora     $B42E                           ; 94CD
        dec     L832E                           ; 94D0
        and     $2C81                           ; 94D3
        sbc     $422E                           ; 94D6
        lsr     $04                             ; 94D9
        .byte   $3B                             ; 94DB
        rol     $0F46,x                         ; 94DC
        .byte   $44                             ; 94DF
        .byte   $3F                             ; 94E0
        .byte   $2C                             ; 94E1
        .byte   $DF                             ; 94E2
L94E3:  rol     $2CC9                           ; 94E3
        dec     $462C,x                         ; 94E6
        bmi     L9530                           ; 94E9
        .byte   $34                             ; 94EB
        and     $DD81                           ; 94EC
        bit     $2EB8                           ; 94EF
        cpx     $332C                           ; 94F2
        bcs     L9539                           ; 94F5
        rol     $453B,x                         ; 94F7
        .byte   $1B                             ; 94FA
        .byte   $4F                             ; 94FB
        rol     $2E81                           ; 94FC
        stx     L802D                           ; 94FF
        bit     $3E3F                           ; 9502
        .byte   $44                             ; 9505
L9506:  bpl     L9536                           ; 9506
        cmp     #$2C                            ; 9508
        .byte   $42                             ; 950A
        bmi     L953F                           ; 950B
        bpl     L9555                           ; 950D
        bmi     L94E3                           ; 950F
        and     $2C80                           ; 9511
        and     ($3B),y                         ; 9514
        .byte   $34                             ; 9516
        lsr     $2C                             ; 9517
        bmi     L9549                           ; 9519
        clc                                     ; 951B
        eor     ($30,x)                         ; 951C
        and     $3436,x                         ; 951E
        bit     $3746                           ; 9521
        sec                                     ; 9524
        clc                                     ; 9525
        .byte   $3B                             ; 9526
        .byte   $34                             ; 9527
        and     $3B04                           ; 9528
        bit     $2CBC                           ; 952B
        cmp     #$2C                            ; 952E
L9530:  .byte   $04                             ; 9530
        .byte   $3B                             ; 9531
        sec                                     ; 9532
        .byte   $34                             ; 9533
        .byte   $42                             ; 9534
        .byte   $2E                             ; 9535
L9536:  ldy     $E92C                           ; 9536
L9539:  rol     $2DE8                           ; 9539
        .byte   $80                             ; 953C
        .byte   $2C                             ; 953D
        .byte   $12                             ; 953E
L953F:  rol     $2CE7                           ; 953F
        cmp     #$2C                            ; 9542
        bmi     L9587                           ; 9544
        .byte   $3C                             ; 9546
        .byte   $3E                             ; 9547
        .byte   $41                             ; 9548
L9549:  .byte   $42                             ; 9549
        rol     $2CBC                           ; 954A
        .byte   $3B                             ; 954D
        sec                                     ; 954E
        rol     $37,x                           ; 954F
        .byte   $43                             ; 9551
        and     $2C80                           ; 9552
L9555:  .byte   $32                             ; 9555
        rol     $3445,x                         ; 9556
        bpl     L9589                           ; 9559
        cmp     $2C,x                           ; 955B
        and     ($3B),y                         ; 955D
        bmi     L9593                           ; 955F
        .byte   $3A                             ; 9561
        bit     $3E35                           ; 9562
        rol     $2D,x                           ; 9565
        .byte   $80                             ; 9567
        bit     $4442                           ; 9568
        .byte   $3C                             ; 956B
        .byte   $3C                             ; 956C
        .byte   $E7                             ; 956D
L956E:  .byte   $0F                             ; 956E
        rol     $2CC9                           ; 956F
        eor     ($30,x)                         ; 9572
        ldy     $2D,x                           ; 9574
        .byte   $80                             ; 9576
        bit     $0432                           ; 9577
        .byte   $3B                             ; 957A
        .byte   $0F                             ; 957B
        rol     $2CC9                           ; 957C
        .byte   $03                             ; 957F
        and     $2C80                           ; 9580
        .byte   $42                             ; 9583
        bmi     L95C3                           ; 9584
        .byte   $36                             ; 9586
L9587:  .byte   $2C                             ; 9587
        .byte   $30                             ; 9588
L9589:  rol     $E742                           ; 9589
        rol     $2D,x                           ; 958C
        .byte   $80                             ; 958E
        bit     $368F                           ; 958F
        .byte   $30                             ; 9592
L9593:  and     $CE2C,x                         ; 9593
        rol     $3742                           ; 9596
        lda     L812D,x                         ; 9599
        cmp     $EB2C,x                         ; 959C
        rol     $2CAD                           ; 959F
        sbc     #$2E                            ; 95A2
        .byte   $DF                             ; 95A4
        bit     $2D84                           ; 95A5
        sta     ($2C,x)                         ; 95A8
        .byte   $3B                             ; 95AA
        rol     $2E18,x                         ; 95AB
        cmp     #$2C                            ; 95AE
        .byte   $EB                             ; 95B0
        bit     $2CDF                           ; 95B1
        sty     $2D                             ; 95B4
        .byte   $80                             ; 95B6
        rol     $3B35                           ; 95B7
        .byte   $44                             ; 95BA
        .byte   $43                             ; 95BB
        .byte   $D2                             ; 95BC
        .byte   $1B                             ; 95BD
        and     $2C80                           ; 95BE
        bcs     L95EF                           ; 95C1
L95C3:  .byte   $9F                             ; 95C3
        .byte   $B2                             ; 95C4
        rol     $3130                           ; 95C5
        lda     $C92C,x                         ; 95C8
        bit     $3830                           ; 95CB
        eor     ($2D,x)                         ; 95CE
        .byte   $32                             ; 95D0
        .byte   $3B                             ; 95D1
        .byte   $34                             ; 95D2
        bmi     L9612                           ; 95D3
        bit     $B137                           ; 95D5
        adc     $C92F,x                         ; 95D8
        sec                                     ; 95DB
        eor     ($2C,x)                         ; 95DC
        .byte   $33                             ; 95DE
        .byte   $34                             ; 95DF
        and     $34,x                           ; 95E0
        and     $3432,x                         ; 95E2
        rol     $2CC1                           ; 95E5
        ldy     $32,x                           ; 95E8
        eor     ($34,x)                         ; 95EA
        bmi     L9630                           ; 95EC
        .byte   $1B                             ; 95EE
L95EF:  adc     L802F,x                         ; 95EF
        cmp     $342C,x                         ; 95F2
        ora     $2E                             ; 95F5
        and     $3B,x                           ; 95F7
        bmi     L963D                           ; 95F9
        .byte   $37                             ; 95FB
        .byte   $1B                             ; 95FC
        adc     L802F,x                         ; 95FD
        bit     $2E0D                           ; 9600
        dec     $C82C                           ; 9603
        and     $2C80                           ; 9606
        txs                                     ; 9609
        .byte   $34                             ; 960A
        .byte   $42                             ; 960B
        and     $434C,x                         ; 960C
        rol     $4443                           ; 960F
L9612:  eor     ($3D,x)                         ; 9612
        bit     $2CCE                           ; 9614
        iny                                     ; 9617
        and     $2C81                           ; 9618
        .byte   $32                             ; 961B
        .byte   $3B                             ; 961C
        rol     $2E11,x                         ; 961D
        sta     ($DD,x)                         ; 9620
        bit     $0534                           ; 9622
        .byte   $4F                             ; 9625
        rol     $3437                           ; 9626
        bit     $2CE2                           ; 9629
        cmp     #$2E                            ; 962C
        sbc     ($2D,x)                         ; 962E
L9630:  sta     ($2C,x)                         ; 9630
        ora     $CE2E                           ; 9632
        bit     $2DC8                           ; 9635
        .byte   $80                             ; 9638
        bit     $4C92                           ; 9639
        .byte   $43                             ; 963C
L963D:  rol     $34BA                           ; 963D
        and     $2E80                           ; 9640
        eor     ($34,x)                         ; 9643
        .byte   $3B                             ; 9645
        .byte   $34                             ; 9646
        bmi     L965A                           ; 9647
        .byte   $A3                             ; 9649
        rol     $2CC9                           ; 964A
        clv                                     ; 964D
        and     $4C80                           ; 964E
        .byte   $42                             ; 9651
        bit     $2EB8                           ; 9652
        lda     L912C                           ; 9655
        .byte   $2C                             ; 9658
        .byte   $E3                             ; 9659
L965A:  and     L902D,x                         ; 965A
        bit     $2E81                           ; 965D
        and     ($3E),y                         ; 9660
        .byte   $44                             ; 9662
        and     $0F32,x                         ; 9663
        lda     ($2C),y                         ; 9666
        and     ($30),y                         ; 9668
        .byte   $32                             ; 966A
        .byte   $3A                             ; 966B
        rol     $2CD5                           ; 966C
        cmp     #$2C                            ; 966F
        asl     L802D                           ; 9671
        bit     $4442                           ; 9674
        .byte   $3C                             ; 9677
        .byte   $3C                             ; 9678
        .byte   $E7                             ; 9679
        .byte   $0F                             ; 967A
        rol     $3F44                           ; 967B
        bit     $3B04                           ; 967E
        bit     $2CC9                           ; 9681
        cmp     ($2E,x)                         ; 9684
        .byte   $8B                             ; 9686
        bit     $33D4                           ; 9687
        bit     $2CC9                           ; 968A
        clv                                     ; 968D
        rol     $2CBC                           ; 968E
        .byte   $82                             ; 9691
        and     $2E80                           ; 9692
        .byte   $32                             ; 9695
        rol     $313C,x                         ; 9696
        ldy     $0F,x                           ; 9699
        cmp     #$38                            ; 969B
        eor     ($2E,x)                         ; 969D
        cmp     ($42,x)                         ; 969F
        bit     $2CCE                           ; 96A1
        .byte   $D4                             ; 96A4
        rol     $2CC9                           ; 96A5
        .byte   $82                             ; 96A8
        and     $2E81                           ; 96A9
        eor     ($34,x)                         ; 96AC
        .byte   $32                             ; 96AE
        .byte   $34                             ; 96AF
        sec                                     ; 96B0
        eor     $0F                             ; 96B1
        .byte   $3C                             ; 96B3
        bmi     L96EF                           ; 96B4
        rol     $2E41,x                         ; 96B6
        sta     L812D,x                         ; 96B9
        rol     $2CE5                           ; 96BC
        sta     $2D33,x                         ; 96BF
        bcc     L973D                           ; 96C2
        sta     ($2E,x)                         ; 96C4
        lda     $332C                           ; 96C6
        sec                                     ; 96C9
        .byte   $1B                             ; 96CA
        and     $2C80                           ; 96CB
        bmi     L9713                           ; 96CE
        .byte   $34                             ; 96D0
        rol     $2D07                           ; 96D1
        .byte   $80                             ; 96D4
        bit     $4133                           ; 96D5
        .byte   $44                             ; 96D8
        and     $2E3A,x                         ; 96D9
        php                                     ; 96DC
        and     $2CC9                           ; 96DD
        .byte   $03                             ; 96E0
        rol     $2CEC                           ; 96E1
        .byte   $9B                             ; 96E4
        .byte   $1B                             ; 96E5
        adc     L902F,x                         ; 96E6
        bit     $43BB                           ; 96E9
        .byte   $37                             ; 96EC
        .byte   $B2                             ; 96ED
        .byte   $2E                             ; 96EE
L96EF:  .byte   $37                             ; 96EF
        bmi     L9731                           ; 96F0
        .byte   $3F                             ; 96F2
        .byte   $34                             ; 96F3
        and     $2D1B,x                         ; 96F4
        sta     ($2E,x)                         ; 96F7
        txs                                     ; 96F9
        .byte   $34                             ; 96FA
        .byte   $42                             ; 96FB
        and     $434C,x                         ; 96FC
        bit     $3436                           ; 96FF
        .byte   $43                             ; 9702
        rol     $339D                           ; 9703
        and     $2C80                           ; 9706
        lda     $0D2E                           ; 9709
        bit     $2CCE                           ; 970C
        iny                                     ; 970F
        and     $2CC9                           ; 9710
L9713:  clv                                     ; 9713
        rol     $3D99                           ; 9714
        jmp     L2C43                           ; 9717

; ----------------------------------------------------------------------------
        inc     L802D                           ; 971A
        cmp     $EB2C,x                         ; 971D
        rol     $2CAD                           ; 9720
        sbc     #$2D                            ; 9723
        .byte   $80                             ; 9725
        cmp     $E82C,x                         ; 9726
        rol     $2CAD                           ; 9729
        sbc     #$2D                            ; 972C
        .byte   $80                             ; 972E
        .byte   $2C                             ; 972F
        .byte   $92                             ; 9730
L9731:  jmp     L2C43                           ; 9731

; ----------------------------------------------------------------------------
        .byte   $D4                             ; 9734
        rol     $2D82                           ; 9735
        .byte   $80                             ; 9738
        bit     $2CE0                           ; 9739
        txs                                     ; 973C
L973D:  lsr     $3D                             ; 973D
        rol     $2CE7                           ; 973F
        cmp     #$2C                            ; 9742
        rol     $41,x                           ; 9744
        rol     $3D44,x                         ; 9746
        .byte   $33                             ; 9749
        and     $2E80                           ; 974A
        .byte   $D4                             ; 974D
        .byte   $33                             ; 974E
        bit     $2EC9                           ; 974F
        .byte   $A7                             ; 9752
        bit     $7DB8                           ; 9753
        .byte   $2F                             ; 9756
        cmp     #$2C                            ; 9757
        inx                                     ; 9759
        bit     $2E8B                           ; 975A
        cmp     #$2C                            ; 975D
        .byte   $EB                             ; 975F
        bit     $2EAC                           ; 9760
        sbc     #$2D                            ; 9763
        cmp     #$2C                            ; 9765
        .byte   $33                             ; 9767
        .byte   $34                             ; 9768
        bmi     L979E                           ; 9769
        rol     $3B04                           ; 976B
        pha                                     ; 976E
        bit     $2EAD                           ; 976F
        eor     ($34,x)                         ; 9772
        eor     $38                             ; 9774
        eor     $1B                             ; 9776
        and     $2CDB                           ; 9778
        .byte   $92                             ; 977B
        jmp     L2C43                           ; 977C

; ----------------------------------------------------------------------------
        .byte   $3C                             ; 977F
        bmi     L97BC                           ; 9780
        .byte   $34                             ; 9782
        rol     $3D30                           ; 9783
        pha                                     ; 9786
        bit     $30A1                           ; 9787
        .byte   $43                             ; 978A
        sec                                     ; 978B
        .byte   $E7                             ; 978C
        rol     $3448                           ; 978D
        .byte   $43                             ; 9790
        .byte   $2D                             ; 9791
L9792:  .byte   $FF                             ; 9792
        bit     $2E00                           ; 9793
        .byte   $83                             ; 9796
        rol     $2C14                           ; 9797
        and     $41,x                           ; 979A
        sec                                     ; 979C
        .byte   $1C                             ; 979D
L979E:  .byte   $42                             ; 979E
        and     $2E80                           ; 979F
        lda     $332C                           ; 97A2
        sec                                     ; 97A5
        .byte   $1B                             ; 97A6
        and     $2C17                           ; 97A7
        .byte   $D7                             ; 97AA
        bit     $2EDB                           ; 97AB
        ora     $2C,x                           ; 97AE
        asl     a                               ; 97B0
        bit     $7CCE                           ; 97B1
        .byte   $2F                             ; 97B4
        .byte   $80                             ; 97B5
        bit     $3315                           ; 97B6
        rol     $2C0A                           ; 97B9
L97BC:  cmp     $2E,x                           ; 97BC
        sta     ($2D,x)                         ; 97BE
        .byte   $BB                             ; 97C0
        bit     $7D16                           ; 97C1
        bit     $2C38                           ; 97C4
        .byte   $D7                             ; 97C7
        rol     $2C9B                           ; 97C8
        .byte   $DB                             ; 97CB
        and     $2C81                           ; 97CC
        lsr     $E7                             ; 97CF
        jmp     L2E43                           ; 97D1

; ----------------------------------------------------------------------------
        .byte   $3B                             ; 97D4
        sec                                     ; 97D5
        clc                                     ; 97D6
        .byte   $34                             ; 97D7
        and     $CE2C,x                         ; 97D8
        bit     $2DDB                           ; 97DB
        rol     $793A,x                         ; 97DE
        bit     $2C38                           ; 97E1
        .byte   $D7                             ; 97E4
        bit     $3043                           ; 97E5
        .byte   $3A                             ; 97E8
        .byte   $34                             ; 97E9
        bit     $2EB1                           ; 97EA
        ldy     #$2C                            ; 97ED
        sta     $2C                             ; 97EF
        nop                                     ; 97F1
        and     $2C81                           ; 97F2
        eor     ($34,x)                         ; 97F5
        .byte   $32                             ; 97F7
        .byte   $34                             ; 97F8
        sec                                     ; 97F9
        eor     $0F                             ; 97FA
        rol     $E73C                           ; 97FC
        .byte   $34                             ; 97FF
        pha                                     ; 9800
        bit     $2C8B                           ; 9801
        .byte   $3B                             ; 9804
        .byte   $34                             ; 9805
        and     $43,x                           ; 9806
        rol     $2CC9                           ; 9808
        cpy     #$2D                            ; 980B
        bcc     L983B                           ; 980D
        cpy     $B02C                           ; 980F
        bit     $2EBB                           ; 9812
        .byte   $03                             ; 9815
        bit     $2DAB                           ; 9816
        .byte   $17                             ; 9819
        bit     $2CD7                           ; 981A
        .byte   $DB                             ; 981D
        rol     $7C13                           ; 981E
        .byte   $2F                             ; 9821
        .byte   $17                             ; 9822
        bit     $2CD7                           ; 9823
        .byte   $DB                             ; 9826
        rol     $2CD4                           ; 9827
        cmp     #$2C                            ; 982A
        clv                                     ; 982C
        bit     $7CE7                           ; 982D
        .byte   $2F                             ; 9830
        .byte   $DB                             ; 9831
        bit     $2CAC                           ; 9832
        .byte   $3C                             ; 9835
        bmi     L986B                           ; 9836
        .byte   $34                             ; 9838
        .byte   $2E                             ; 9839
        .byte   $C9                             ; 983A
L983B:  bit     $30A1                           ; 983B
        .byte   $43                             ; 983E
        sec                                     ; 983F
        .byte   $E7                             ; 9840
        adc     $C92F,x                         ; 9841
        bit     $2C03                           ; 9844
        cpx     L9B2E                           ; 9847
        .byte   $1B                             ; 984A
        and     $2CCE                           ; 984B
        .byte   $33                             ; 984E
        sec                                     ; 984F
        clc                                     ; 9850
        eor     ($38,x)                         ; 9851
        bcc     L9889                           ; 9853
        .byte   $7C                             ; 9855
        .byte   $2F                             ; 9856
        txs                                     ; 9857
        bit     $2CDB                           ; 9858
        lsr     $30                             ; 985B
        .byte   $3D                             ; 985D
        .byte   $43                             ; 985E
L985F:  .byte   $2C                             ; 985F
L9860:  .byte   $CE                             ; 9860
        .byte   $2E                             ; 9861
L9862:  .byte   $42                             ; 9862
        .byte   $34                             ; 9863
        eor     ($45,x)                         ; 9864
        .byte   $34                             ; 9866
        bit     $3630                           ; 9867
        .byte   $30                             ; 986A
L986B:  ldy     $7C,x                           ; 986B
        .byte   $2F                             ; 986D
        .byte   $80                             ; 986E
        bit     $0432                           ; 986F
        .byte   $3B                             ; 9872
        .byte   $0F                             ; 9873
        rol     $B037                           ; 9874
        bit     $3B04                           ; 9877
        pha                                     ; 987A
        and     $2CFF                           ; 987B
        .byte   $37                             ; 987E
        sec                                     ; 987F
        .byte   $33                             ; 9880
        bit     $378F                           ; 9881
        ldy     $33,x                           ; 9884
        rol     $2CC9                           ; 9886
L9889:  asl     $422C                           ; 9889
        .byte   $37                             ; 988C
        sec                                     ; 988D
        .byte   $34                             ; 988E
        .byte   $3B                             ; 988F
        .byte   $33                             ; 9890
        .byte   $4F                             ; 9891
        rol     $3437                           ; 9892
        bit     $2CE2                           ; 9895
        cmp     #$2E                            ; 9898
        sbc     ($2D,x)                         ; 989A
        .byte   $DB                             ; 989C
        bit     $4C92                           ; 989D
        .byte   $43                             ; 98A0
        bit     $303C                           ; 98A1
        .byte   $3A                             ; 98A4
        .byte   $34                             ; 98A5
        rol     $2CC9                           ; 98A6
        lda     ($30,x)                         ; 98A9
        .byte   $43                             ; 98AB
        sec                                     ; 98AC
        .byte   $E7                             ; 98AD
        and     $7C7C                           ; 98AE
        .byte   $7C                             ; 98B1
        .byte   $2F                             ; 98B2
        .byte   $C3                             ; 98B3
        clv                                     ; 98B4
        cmp     #$B8                            ; 98B5
        .byte   $CF                             ; 98B7
        clv                                     ; 98B8
        cmp     $B8,x                           ; 98B9
        .byte   $DB                             ; 98BB
        clv                                     ; 98BC
        .byte   $DF                             ; 98BD
        clv                                     ; 98BE
        and     $42BB,x                         ; 98BF
        .byte   $BB                             ; 98C2
        .byte   $32                             ; 98C3
        bmi     L9907                           ; 98C4
        .byte   $3F                             ; 98C6
        .byte   $34                             ; 98C7
        .byte   $C3                             ; 98C8
        .byte   $37                             ; 98C9
        bmi     L9908                           ; 98CA
        .byte   $3C                             ; 98CC
        .byte   $34                             ; 98CD
        cmp     ($41,x)                         ; 98CE
        .byte   $4F                             ; 98D0
        .byte   $42                             ; 98D1
        .byte   $34                             ; 98D2
        .byte   $34                             ; 98D3
        .byte   $B3                             ; 98D4
        bmi     L9913                           ; 98D5
        .byte   $44                             ; 98D7
        .byte   $3B                             ; 98D8
        .byte   $34                             ; 98D9
        .byte   $C3                             ; 98DA
        .byte   $37                             ; 98DB
        rol     $BD41,x                         ; 98DC
        .byte   $3A                             ; 98DF
        .byte   $34                             ; 98E0
        iny                                     ; 98E1
        nop                                     ; 98E2
        clv                                     ; 98E3
        sta     $55B9,y                         ; 98E4
        tsx                                     ; 98E7
L98E8:  asl     $32BB,x                         ; 98E8
        rol     $3E41,x                         ; 98EB
        and     $B048,x                         ; 98EE
        .byte   $42                             ; 98F1
        .byte   $44                             ; 98F2
        .byte   $3F                             ; 98F3
        sec                                     ; 98F4
        .byte   $32                             ; 98F5
        bcs     L992E                           ; 98F6
        .byte   $44                             ; 98F8
        and     $3C2C,x                         ; 98F9
        .byte   $34                             ; 98FC
        .byte   $32                             ; 98FD
        bcs     L993F                           ; 98FE
        .byte   $44                             ; 9900
        .byte   $3A                             ; 9901
        sec                                     ; 9902
        lda     $4436,x                         ; 9903
        .byte   $31                             ; 9906
L9907:  sec                                     ; 9907
L9908:  and     ($B8),y                         ; 9908
        .byte   $3C                             ; 990A
        .byte   $44                             ; 990B
        .byte   $42                             ; 990C
        .byte   $43                             ; 990D
        bmi     L9945                           ; 990E
        bcs     L9946                           ; 9910
        .byte   $3F                             ; 9912
L9913:  sec                                     ; 9913
        lda     $3041,x                         ; 9914
        sec                                     ; 9917
L9918:  and     $3AC8,x                         ; 9918
        .byte   $34                             ; 991B
        and     ($30),y                         ; 991C
        and     ($C4),y                         ; 991E
        and     $30,x                           ; 9920
        eor     ($44,x)                         ; 9922
        tsx                                     ; 9924
        .byte   $37                             ; 9925
        bmi     L996A                           ; 9926
        .byte   $42                             ; 9928
        bmi     L98E8                           ; 9929
        .byte   $43                             ; 992B
        eor     ($3E,x)                         ; 992C
L992E:  rol     $343F,x                         ; 992E
        cmp     ($3F,x)                         ; 9931
        bmi     L9972                           ; 9933
        .byte   $33                             ; 9935
        bmi     L9979                           ; 9936
        ldy     $373F,x                         ; 9938
        bmi     L997E                           ; 993B
        pha                                     ; 993D
        .byte   $30                             ; 993E
L993F:  .byte   $B3                             ; 993F
        .byte   $3C                             ; 9940
        sec                                     ; 9941
        and     $4838,x                         ; 9942
L9945:  .byte   $30                             ; 9945
L9946:  .byte   $B3                             ; 9946
        bmi     L9985                           ; 9947
        bmi     L998C                           ; 9949
        sec                                     ; 994B
        .byte   $34                             ; 994C
        .byte   $C2                             ; 994D
        lsr     $30                             ; 994E
        eor     #$30                            ; 9950
        eor     ($BD,x)                         ; 9952
        rol     $38,x                           ; 9954
        rol     $30,x                           ; 9956
        .byte   $33                             ; 9958
        bmi     L9918                           ; 9959
        .byte   $32                             ; 995B
        pha                                     ; 995C
        .byte   $43                             ; 995D
        eor     ($3E,x)                         ; 995E
        lda     $3036,x                         ; 9960
        eor     #$34                            ; 9963
        sec                                     ; 9965
        .byte   $BB                             ; 9966
        rol     $30,x                           ; 9967
        .byte   $3D                             ; 9969
L996A:  rol     $30,x                           ; 996A
        cmp     ($3C,x)                         ; 996C
L996E:  .byte   $34                             ; 996E
        .byte   $33                             ; 996F
        .byte   $44                             ; 9970
        .byte   $42                             ; 9971
L9972:  bcs     L99AA                           ; 9972
        rol     $3641,x                         ; 9974
        .byte   $3E                             ; 9977
        .byte   $BD                             ; 9978
L9979:  eor     ($3E,x)                         ; 9979
        .byte   $3C                             ; 997B
        .byte   $42                             ; 997C
        .byte   $30                             ; 997D
L997E:  eor     ($B1,x)                         ; 997E
        eor     ($30,x)                         ; 9980
        eor     #$30                            ; 9982
        .byte   $3B                             ; 9984
L9985:  .byte   $34                             ; 9985
        ldx     $3E32,y                         ; 9986
        eor     ($42,x)                         ; 9989
        .byte   $B0                             ; 998B
L998C:  .byte   $3C                             ; 998C
        .byte   $34                             ; 998D
        rol     $30,x                           ; 998E
        eor     ($BB,x)                         ; 9990
        eor     #$30                            ; 9992
        .byte   $37                             ; 9994
        .byte   $37                             ; 9995
        bmi     L99D9                           ; 9996
        tsx                                     ; 9998
        .byte   $32                             ; 9999
        .byte   $44                             ; 999A
        eor     ($36,x)                         ; 999B
        rol     $33C3,x                         ; 999D
        bmi     L99DD                           ; 99A0
        .byte   $49                             ; 99A2
L99A3:  bmi     *+67                            ; 99A3
        tsx                                     ; 99A5
        rol     $3E,x                           ; 99A6
        eor     ($3B,x)                         ; 99A8
L99AA:  bcs     L99DD                           ; 99AA
        .byte   $3B                             ; 99AC
        sec                                     ; 99AD
        .byte   $3C                             ; 99AE
        eor     ($BE,x)                         ; 99AF
        and     ($34),y                         ; 99B1
        eor     ($3B,x)                         ; 99B3
        bmi     L996E                           ; 99B5
        .byte   $3C                             ; 99B7
        .byte   $34                             ; 99B8
        .byte   $3B                             ; 99B9
        .byte   $33                             ; 99BA
        ldx     $3433,y                         ; 99BB
        eor     ($3E,x)                         ; 99BE
        .byte   $BB                             ; 99C0
        .byte   $42                             ; 99C1
        bmi     L9A00                           ; 99C2
        eor     ($38,x)                         ; 99C4
        .byte   $3C                             ; 99C6
        bcs     L9A03                           ; 99C7
        bmi     L9A05                           ; 99C9
        .byte   $3A                             ; 99CB
        bmi     L9A0F                           ; 99CC
        bcs     L9A00                           ; 99CE
        sec                                     ; 99D0
L99D1:  cmp     ($31,x)                         ; 99D1
        bmi     L9A17                           ; 99D3
        sec                                     ; 99D5
        .byte   $33                             ; 99D6
        .byte   $BE                             ; 99D7
        .byte   $35                             ; 99D8
L99D9:  sec                                     ; 99D9
        eor     ($B4,x)                         ; 99DA
        .byte   $36                             ; 99DC
L99DD:  sec                                     ; 99DD
        .byte   $3B                             ; 99DE
        bmi     L99A3                           ; 99DF
        .byte   $3C                             ; 99E1
        bmi     L9A1A                           ; 99E2
        .byte   $3C                             ; 99E4
        bcs     L9A30                           ; 99E5
        rol     $3E33,x                         ; 99E7
        cmp     ($3C,x)                         ; 99EA
        bmi     L9A30                           ; 99EC
        .byte   $3A                             ; 99EE
        .byte   $34                             ; 99EF
        .byte   $B3                             ; 99F0
        bit     $4042                           ; 99F1
        .byte   $44                             ; 99F4
        bmi     L99AA                           ; 99F5
        bit     $3833                           ; 99F7
        eor     $38                             ; 99FA
        .byte   $42                             ; 99FC
        sec                                     ; 99FD
        .byte   $3E                             ; 99FE
        .byte   $BD                             ; 99FF
L9A00:  bit     $3441                           ; 9A00
L9A03:  rol     $38,x                           ; 9A03
L9A05:  .byte   $3C                             ; 9A05
        .byte   $34                             ; 9A06
        and     $2CC3,x                         ; 9A07
        .byte   $3F                             ; 9A0A
        bmi     L9A4E                           ; 9A0B
        .byte   $43                             ; 9A0D
        iny                                     ; 9A0E
L9A0F:  bit     $3B32                           ; 9A0F
        bmi     L99D1                           ; 9A12
        .byte   $32                             ; 9A14
        pha                                     ; 9A15
        .byte   $36                             ; 9A16
L9A17:  and     $C244,x                         ; 9A17
L9A1A:  .byte   $42                             ; 9A1A
        sec                                     ; 9A1B
        eor     ($38,x)                         ; 9A1C
        .byte   $44                             ; 9A1E
        .byte   $C2                             ; 9A1F
        .byte   $3B                             ; 9A20
        sec                                     ; 9A21
        and     ($41),y                         ; 9A22
        bcs     L9A59                           ; 9A24
        eor     ($30,x)                         ; 9A26
        rol     $3E,x                           ; 9A28
        lda     $4130,x                         ; 9A2A
        sec                                     ; 9A2D
        .byte   $34                             ; 9A2E
        .byte   $C2                             ; 9A2F
L9A30:  .byte   $3A                             ; 9A30
        bmi     L9A6B                           ; 9A31
        .byte   $43                             ; 9A33
        rol     $36C2,x                         ; 9A34
        pha                                     ; 9A37
        rol     $30,x                           ; 9A38
        .byte   $43                             ; 9A3A
        rol     $BD41,x                         ; 9A3B
        .byte   $42                             ; 9A3E
        .byte   $43                             ; 9A3F
        bmi     L9A83                           ; 9A40
        .byte   $33                             ; 9A42
        rol     $3CBD,x                         ; 9A43
        rol     $383D,x                         ; 9A46
        and     ($44),y                         ; 9A49
        eor     ($BD,x)                         ; 9A4B
        .byte   $35                             ; 9A4D
L9A4E:  sec                                     ; 9A4E
        eor     ($34,x)                         ; 9A4F
        and     ($3E),y                         ; 9A51
        .byte   $3B                             ; 9A53
        .byte   $C3                             ; 9A54
        .byte   $43                             ; 9A55
        rol     $3D41,x                         ; 9A56
L9A59:  bmi     L9A8E                           ; 9A59
        rol     $43C1,x                         ; 9A5B
        .byte   $37                             ; 9A5E
        .byte   $44                             ; 9A5F
        and     $3433,x                         ; 9A60
        eor     ($BD,x)                         ; 9A63
        .byte   $3F                             ; 9A65
        bmi     L9AA4                           ; 9A66
        .byte   $3F                             ; 9A68
        .byte   $3E                             ; 9A69
        .byte   $BE                             ; 9A6A
L9A6B:  .byte   $3C                             ; 9A6B
        bmi     L9AB1                           ; 9A6C
        bmi     L9AB3                           ; 9A6E
        ldx     $303C,y                         ; 9A70
L9A73:  eor     ($38,x)                         ; 9A73
        .byte   $43                             ; 9A75
        bcs     L9AAE                           ; 9A76
        sec                                     ; 9A78
        .byte   $3B                             ; 9A79
        eor     #$30                            ; 9A7A
        .byte   $33                             ; 9A7C
        ldy     $31,x                           ; 9A7D
        rol     $433B,x                         ; 9A7F
        .byte   $43                             ; 9A82
L9A83:  rol     L8241,x                         ; 9A83
        and     ($3E),y                         ; 9A86
        .byte   $3B                             ; 9A88
        .byte   $43                             ; 9A89
        .byte   $43                             ; 9A8A
        rol     L8141,x                         ; 9A8B
L9A8E:  and     ($3E),y                         ; 9A8E
        .byte   $3B                             ; 9A90
        .byte   $43                             ; 9A91
        .byte   $43                             ; 9A92
        rol     L8341,x                         ; 9A93
        and     $3B,x                           ; 9A96
        bmi     L9AD6                           ; 9A98
        rol     L813B,x                         ; 9A9A
        .byte   $3F                             ; 9A9D
        .byte   $34                             ; 9A9E
        eor     ($38,x)                         ; 9A9F
        .byte   $44                             ; 9AA1
        .byte   $C2                             ; 9AA2
        .byte   $35                             ; 9AA3
L9AA4:  .byte   $3B                             ; 9AA4
        bmi     L9AE3                           ; 9AA5
        rol     L833B,x                         ; 9AA7
        .byte   $3C                             ; 9AAA
        pha                                     ; 9AAB
        .byte   $3C                             ; 9AAC
        iny                                     ; 9AAD
L9AAE:  .byte   $32                             ; 9AAE
        bmi     L9AF2                           ; 9AAF
L9AB1:  bmi     L9AE4                           ; 9AB1
L9AB3:  bcs     L9AF7                           ; 9AB3
        .byte   $34                             ; 9AB5
        bmi     L9A73                           ; 9AB6
        .byte   $42                             ; 9AB8
        sec                                     ; 9AB9
        .byte   $3B                             ; 9ABA
        .byte   $3B                             ; 9ABB
        .byte   $34                             ; 9ABC
        sec                                     ; 9ABD
        .byte   $C3                             ; 9ABE
        .byte   $3C                             ; 9ABF
        bmi     L9AF8                           ; 9AC0
        sec                                     ; 9AC2
        .byte   $B2                             ; 9AC3
        eor     $34                             ; 9AC4
        .byte   $3B                             ; 9AC6
        eor     $34                             ; 9AC7
        cmp     ($42,x)                         ; 9AC9
        sec                                     ; 9ACB
        .byte   $3B                             ; 9ACC
        .byte   $44                             ; 9ACD
        .byte   $34                             ; 9ACE
        .byte   $43                             ; 9ACF
        .byte   $43                             ; 9AD0
        ldy     $33,x                           ; 9AD1
        .byte   $34                             ; 9AD3
        and     $34,x                           ; 9AD4
L9AD6:  and     $B434,x                         ; 9AD6
        .byte   $32                             ; 9AD9
        rol     $3C3C,x                         ; 9ADA
        bmi     L9B1C                           ; 9ADD
        .byte   $B3                             ; 9ADF
        and     $3E,x                           ; 9AE0
        .byte   $41                             ; 9AE2
L9AE3:  .byte   $3C                             ; 9AE3
L9AE4:  bmi     L9B29                           ; 9AE4
        sec                                     ; 9AE6
        rol     $46BD,x                         ; 9AE7
        .byte   $37                             ; 9AEA
        sec                                     ; 9AEB
        .byte   $42                             ; 9AEC
        .byte   $43                             ; 9AED
        .byte   $3B                             ; 9AEE
        ldy     $41,x                           ; 9AEF
        .byte   $34                             ; 9AF1
L9AF2:  .byte   $42                             ; 9AF2
        .byte   $34                             ; 9AF3
        .byte   $30                             ; 9AF4
L9AF5:  .byte   $3B                             ; 9AF5
        .byte   $BE                             ; 9AF6
L9AF7:  pha                                     ; 9AF7
L9AF8:  rol     $2C44,x                         ; 9AF8
        and     $38,x                           ; 9AFB
        rol     $37,x                           ; 9AFD
        .byte   $43                             ; 9AFF
        bit     $3B30                           ; 9B00
        rol     $B43D,x                         ; 9B03
        and     $38,x                           ; 9B06
        and     $4238,x                         ; 9B08
        .byte   $B7                             ; 9B0B
        lsr     a                               ; 9B0C
        bit     $3742                           ; 9B0D
        bmi     L9B53                           ; 9B10
        .byte   $34                             ; 9B12
        .byte   $C2                             ; 9B13
        eor     ($3E,x)                         ; 9B14
        .byte   $B3                             ; 9B16
        bmi     L9B5A                           ; 9B17
        eor     ($3E,x)                         ; 9B19
        .byte   $C6                             ; 9B1B
L9B1C:  .byte   $4B                             ; 9B1C
        bit     $3742                           ; 9B1D
        bmi     L9B63                           ; 9B20
        .byte   $34                             ; 9B22
        .byte   $C2                             ; 9B23
        and     $38,x                           ; 9B24
        rol     $37,x                           ; 9B26
        .byte   $C3                             ; 9B28
L9B29:  .byte   $34                             ; 9B29
        .byte   $42                             ; 9B2A
        .byte   $32                             ; 9B2B
L9B2C:  bmi     L9B6D                           ; 9B2C
L9B2E:  ldy     $43,x                           ; 9B2E
        .byte   $41                             ; 9B30
L9B31:  rol     $3F3E,x                         ; 9B31
        .byte   $34                             ; 9B34
        cmp     ($30,x)                         ; 9B35
        .byte   $BB                             ; 9B37
        pha                                     ; 9B38
        .byte   $34                             ; 9B39
        .byte   $C2                             ; 9B3A
        and     $31BE,x                         ; 9B3B
        eor     ($34,x)                         ; 9B3E
        bmi     L9AF5                           ; 9B40
        .byte   $3C                             ; 9B42
        bmi     L9B87                           ; 9B43
        .byte   $37                             ; 9B45
        eor     ($3E,x)                         ; 9B46
        rol     $30B1,x                         ; 9B48
        .byte   $43                             ; 9B4B
        .byte   $43                             ; 9B4C
        bmi     L9B81                           ; 9B4D
L9B4F:  tsx                                     ; 9B4F
        .byte   $3F                             ; 9B50
        .byte   $34                             ; 9B51
        .byte   $30                             ; 9B52
L9B53:  .byte   $32                             ; 9B53
        ldy     $41,x                           ; 9B54
        .byte   $34                             ; 9B56
        .byte   $43                             ; 9B57
        eor     ($C8,x)                         ; 9B58
L9B5A:  .byte   $42                             ; 9B5A
        .byte   $34                             ; 9B5B
        .byte   $3B                             ; 9B5C
        .byte   $34                             ; 9B5D
        .byte   $32                             ; 9B5E
        .byte   $43                             ; 9B5F
        bit     $303F                           ; 9B60
L9B63:  eor     ($43,x)                         ; 9B63
        and     $C134,x                         ; 9B65
        .byte   $43                             ; 9B68
        .byte   $44                             ; 9B69
        eor     ($3D,x)                         ; 9B6A
        .byte   $34                             ; 9B6C
L9B6D:  .byte   $B3                             ; 9B6D
        .byte   $3C                             ; 9B6E
        sec                                     ; 9B6F
        eor     ($41,x)                         ; 9B70
        rol     $41C1,x                         ; 9B72
        .byte   $34                             ; 9B75
        .byte   $33                             ; 9B76
        ldy     $3442                           ; 9B77
        .byte   $33                             ; 9B7A
        ldy     $443F                           ; 9B7B
        .byte   $C3                             ; 9B7E
        .byte   $30                             ; 9B7F
L9B80:  .byte   $43                             ; 9B80
L9B81:  .byte   $43                             ; 9B81
        bmi     L9BB6                           ; 9B82
        tsx                                     ; 9B84
        bmi     L9BC3                           ; 9B85
L9B87:  rol     $B63D,x                         ; 9B87
        .byte   $3F                             ; 9B8A
        eor     ($3E,x)                         ; 9B8B
        .byte   $3F                             ; 9B8D
        rol     $B442,x                         ; 9B8E
        lsr     $30                             ; 9B91
        iny                                     ; 9B93
        lsr     $37                             ; 9B94
        ldx     $C342,y                         ; 9B96
        and     $433E,x                         ; 9B99
        bit     $303F                           ; 9B9C
        iny                                     ; 9B9F
        .byte   $34                             ; 9BA0
        and     $60B3,x                         ; 9BA1
        brk                                     ; 9BA4
        .byte   $80                             ; 9BA5
        ora     $80                             ; 9BA6
        .byte   $12                             ; 9BA8
        .byte   $80                             ; 9BA9
        .byte   $17                             ; 9BAA
        .byte   $80                             ; 9BAB
        plp                                     ; 9BAC
        .byte   $80                             ; 9BAD
        and     $4480,y                         ; 9BAE
        .byte   $80                             ; 9BB1
        eor     $C0,x                           ; 9BB2
        .byte   $5E                             ; 9BB4
        rts                                     ; 9BB5

; ----------------------------------------------------------------------------
L9BB6:  ror     $80                             ; 9BB6
        .byte   $6E                             ; 9BB8
        .byte   $C0                             ; 9BB9
L9BBA:  .byte   $80                             ; 9BBA
        rts                                     ; 9BBB

; ----------------------------------------------------------------------------
        dey                                     ; 9BBC
        ldy     #$92                            ; 9BBD
        cpy     #$A0                            ; 9BBF
        rti                                     ; 9BC1

; ----------------------------------------------------------------------------
        .byte   $B0                             ; 9BC2
L9BC3:  rts                                     ; 9BC3

; ----------------------------------------------------------------------------
L9BC4:  cmp     $DA80                           ; 9BC4
        dey                                     ; 9BC7
        .byte   $E7                             ; 9BC8
        tya                                     ; 9BC9
        .byte   $FA                             ; 9BCA
        sta     ($17,x)                         ; 9BCB
        lda     ($22,x)                         ; 9BCD
        sta     ($2B,x)                         ; 9BCF
        adc     ($9C,x)                         ; 9BD1
        sta     ($4D,x)                         ; 9BD3
        sta     ($61,x)                         ; 9BD5
        .byte   $80                             ; 9BD7
        .byte   $77                             ; 9BD8
        lda     ($89,x)                         ; 9BD9
        sta     ($B3,x)                         ; 9BDB
        sta     ($C7,x)                         ; 9BDD
        .byte   $04                             ; 9BDF
        dec     a:$80                           ; 9BE0
        sta     $0F                             ; 9BE3
        sta     ($E1,x)                         ; 9BE5
        lda     ($34,x)                         ; 9BE7
        ora     ($EE,x)                         ; 9BE9
        sta     ($FB,x)                         ; 9BEB
        sta     ($72,x)                         ; 9BED
        .byte   $82                             ; 9BEF
        php                                     ; 9BF0
        .byte   $02                             ; 9BF1
        asl     $C2,x                           ; 9BF2
        .byte   $1F                             ; 9BF4
        .byte   $82                             ; 9BF5
        bmi     L9BBA                           ; 9BF6
        .byte   $3A                             ; 9BF8
        .byte   $02                             ; 9BF9
        eor     ($82),y                         ; 9BFA
        bcc     L9B80                           ; 9BFC
        adc     $DC84,y                         ; 9BFE
        .byte   $82                             ; 9C01
        .byte   $5F                             ; 9C02
        .byte   $82                             ; 9C03
        .byte   $67                             ; 9C04
        .byte   $C2                             ; 9C05
        tya                                     ; 9C06
        .byte   $C2                             ; 9C07
        .byte   $AF                             ; 9C08
        .byte   $82                             ; 9C09
        ldy     a:$00,x                         ; 9C0A
        .byte   $82                             ; 9C0D
        .byte   $D3                             ; 9C0E
        ldx     #$F3                            ; 9C0F
        brk                                     ; 9C11
        brk                                     ; 9C12
        brk                                     ; 9C13
        brk                                     ; 9C14
        brk                                     ; 9C15
        brk                                     ; 9C16
        brk                                     ; 9C17
        brk                                     ; 9C18
        brk                                     ; 9C19
        brk                                     ; 9C1A
        brk                                     ; 9C1B
        brk                                     ; 9C1C
        .byte   $80                             ; 9C1D
        eor     $E3,x                           ; 9C1E
        asl     a                               ; 9C20
        brk                                     ; 9C21
        brk                                     ; 9C22
        .byte   $A3                             ; 9C23
        .byte   $1B                             ; 9C24
        .byte   $83                             ; 9C25
        .byte   $22                             ; 9C26
        .byte   $43                             ; 9C27
        bit     $3443                           ; 9C28
        .byte   $83                             ; 9C2B
        rol     a:$00,x                         ; 9C2C
        sta     ($D6,x)                         ; 9C2F
        .byte   $80                             ; 9C31
        brk                                     ; 9C32
        .byte   $82                             ; 9C33
        lda     ($83,x)                         ; 9C34
        pha                                     ; 9C36
        .byte   $C3                             ; 9C37
        .byte   $67                             ; 9C38
        .byte   $83                             ; 9C39
        .byte   $57                             ; 9C3A
        sta     $0F                             ; 9C3B
        sta     $0F                             ; 9C3D
        .byte   $83                             ; 9C3F
        stx     $7183                           ; 9C40
        sta     $0F                             ; 9C43
        brk                                     ; 9C45
        brk                                     ; 9C46
        brk                                     ; 9C47
        brk                                     ; 9C48
        brk                                     ; 9C49
        brk                                     ; 9C4A
        brk                                     ; 9C4B
        brk                                     ; 9C4C
        .byte   $83                             ; 9C4D
        tya                                     ; 9C4E
        .byte   $C3                             ; 9C4F
        .byte   $AB                             ; 9C50
        .byte   $83                             ; 9C51
        .byte   $B7                             ; 9C52
        .byte   $43                             ; 9C53
        cmp     $C3                             ; 9C54
        cmp     $F203,y                         ; 9C56
        .byte   $44                             ; 9C59
        brk                                     ; 9C5A
        sty     $08                             ; 9C5B
        .byte   $44                             ; 9C5D
        php                                     ; 9C5E
        .byte   $04                             ; 9C5F
        php                                     ; 9C60
        cpy     $15                             ; 9C61
        cpy     $20                             ; 9C63
        .byte   $44                             ; 9C65
        and     $3E44                           ; 9C66
        cpy     $53                             ; 9C69
        sty     $6D                             ; 9C6B
        .byte   $04                             ; 9C6D
        adc     L8204,y                         ; 9C6E
        .byte   $43                             ; 9C71
        .byte   $B7                             ; 9C72
        sty     $91                             ; 9C73
        brk                                     ; 9C75
        brk                                     ; 9C76
        .byte   $C3                             ; 9C77
        .byte   $7C                             ; 9C78
        .byte   $C3                             ; 9C79
        sta     $85                             ; 9C7A
        .byte   $0F                             ; 9C7C
        .byte   $C2                             ; 9C7D
        .byte   $87                             ; 9C7E
        sta     $0F                             ; 9C7F
        .byte   $C3                             ; 9C81
        asl     a                               ; 9C82
        .byte   $83                             ; 9C83
        .byte   $1B                             ; 9C84
        cpy     $A3                             ; 9C85
        ldy     #$44                            ; 9C87
        .byte   $80                             ; 9C89
        sta     $B704,y                         ; 9C8A
        sty     $FC                             ; 9C8D
        brk                                     ; 9C8F
        .byte   $07                             ; 9C90
        ora     $1A15                           ; 9C91
        jsr     L2B27                           ; 9C94
        bmi     L9CCF                           ; 9C97
        .byte   $3B                             ; 9C99
        eor     ($48,x)                         ; 9C9A
        .byte   $4F                             ; 9C9C
        lsr     $56,x                           ; 9C9D
        eor     $6A64,x                         ; 9C9F
        adc     ($77),y                         ; 9CA2
        adc     L837D,x                         ; 9CA4
        .byte   $83                             ; 9CA7
        .byte   $89                             ; 9CA8
        .byte   $89                             ; 9CA9
        .byte   $8F                             ; 9CAA
        stx     $9D,y                           ; 9CAB
        ldx     #$A8                            ; 9CAD
        brk                                     ; 9CAF
        asl     $0D                             ; 9CB0
        .byte   $12                             ; 9CB2
        clc                                     ; 9CB3
        asl     $2823,x                         ; 9CB4
        .byte   $2F                             ; 9CB7
        rol     $36,x                           ; 9CB8
        and     $433F,y                         ; 9CBA
        pha                                     ; 9CBD
        eor     $5852                           ; 9CBE
        lsr     $7067,x                         ; 9CC1
        ror     $7B,x                           ; 9CC4
        sta     ($87,x)                         ; 9CC6
        sty     L9792                           ; 9CC8
        sta     $ACA5,x                         ; 9CCB
        .byte   $B4                             ; 9CCE
L9CCF:  brk                                     ; 9CCF
        php                                     ; 9CD0
        bpl     L9CE3                           ; 9CD1
        asl     $1C,x                           ; 9CD3
        .byte   $22                             ; 9CD5
        and     #$31                            ; 9CD6
        and     $4841,y                         ; 9CD8
        lsr     $5855                           ; 9CDB
        eor     $635F,y                         ; 9CDE
        ror     a                               ; 9CE1
        .byte   $6F                             ; 9CE2
L9CE3:  adc     $7D,x                           ; 9CE3
        sty     $8B                             ; 9CE5
        sty     $9B,x                           ; 9CE7
        ldx     #$B1                            ; 9CE9
        .byte   $B7                             ; 9CEB
        .byte   $C7                             ; 9CEC
        .byte   $BF                             ; 9CED
        .byte   $C2                             ; 9CEE
        brk                                     ; 9CEF
        asl     $0B                             ; 9CF0
        ora     ($18),y                         ; 9CF2
        .byte   $1A                             ; 9CF4
        ora     $241F,x                         ; 9CF5
        bit     $3732                           ; 9CF8
        .byte   $3C                             ; 9CFB
        lsr     a                               ; 9CFC
        bvc     L9D56                           ; 9CFD
        lsr     $5A,x                           ; 9CFF
        lsr     $6761,x                         ; 9D01
        jmp     (L7673)                         ; 9D04

; ----------------------------------------------------------------------------
        adc     $7B7F,y                         ; 9D07
        .byte   $4E                             ; 9D0A
        .byte   $82                             ; 9D0B
L9D0C:  lda     $00                             ; 9D0C
        and     #$07                            ; 9D0E
        jsr     LE97D                           ; 9D10
        ora     #$BF                            ; 9D13
        .byte   $1F                             ; 9D15
        .byte   $BD                             ; 9D16
        .byte   $1F                             ; 9D17
L9D18:  lda     $BD6C,x                         ; 9D18
        .byte   $44                             ; 9D1B
        ldx     $BE45,y                         ; 9D1C
        jsr     LDF79                           ; 9D1F
        and     #$03                            ; 9D22
        beq     L9D33                           ; 9D24
        cpy     #$03                            ; 9D26
        bne     L9D34                           ; 9D28
        jsr     LDE51                           ; 9D2A
        jsr     LDBE2                           ; 9D2D
        jsr     LDA32                           ; 9D30
L9D33:  rts                                     ; 9D33

; ----------------------------------------------------------------------------
L9D34:  pha                                     ; 9D34
        ldx     $00                             ; 9D35
        dey                                     ; 9D37
        tya                                     ; 9D38
        beq     L9D3D                           ; 9D39
        adc     #$08                            ; 9D3B
L9D3D:  adc     $00                             ; 9D3D
        tay                                     ; 9D3F
        pla                                     ; 9D40
        lsr     a                               ; 9D41
        lda     $051D,y                         ; 9D42
L9D45:  bcs     L9D4C                           ; 9D45
        sbc     #$00                            ; 9D47
        bcs     L9D52                           ; 9D49
L9D4B:  rts                                     ; 9D4B

; ----------------------------------------------------------------------------
L9D4C:  adc     #$00                            ; 9D4C
        cmp     #$0A                            ; 9D4E
        bcs     L9D4B                           ; 9D50
L9D52:  sta     $01                             ; 9D52
        .byte   $BD                             ; 9D54
        .byte   $14                             ; 9D55
L9D56:  ora     $B0                             ; 9D56
        asl     $F0                             ; 9D58
        beq     L9D45                           ; 9D5A
        brk                                     ; 9D5C
        bpl     L9D61                           ; 9D5D
        adc     #$00                            ; 9D5F
L9D61:  sta     $0514,x                         ; 9D61
        lda     $01                             ; 9D64
        sta     $051D,y                         ; 9D66
        jmp     LDBC0                           ; 9D69

; ----------------------------------------------------------------------------
        lda     $0515                           ; 9D6C
        cmp     #$02                            ; 9D6F
        bcs     L9D7E                           ; 9D71
        lda     $0516                           ; 9D73
        cmp     #$02                            ; 9D76
        bcs     L9D7E                           ; 9D78
        ldx     #$04                            ; 9D7A
        bne     L9DB7                           ; 9D7C
L9D7E:  ldx     $0306                           ; 9D7E
        dex                                     ; 9D81
        beq     L9D95                           ; 9D82
        bmi     L9D95                           ; 9D84
        stx     $02                             ; 9D86
        lda     $81                             ; 9D88
        sta     $06                             ; 9D8A
        clc                                     ; 9D8C
        jsr     LBDBA                           ; 9D8D
        ldy     #$00                            ; 9D90
        jsr     LBE35                           ; 9D92
L9D95:  ldx     $0307                           ; 9D95
        dex                                     ; 9D98
        bmi     L9DB2                           ; 9D99
        beq     L9DB2                           ; 9D9B
        txa                                     ; 9D9D
        pha                                     ; 9D9E
        jsr     LCFC9                           ; 9D9F
        pla                                     ; 9DA2
        ldx     $02                             ; 9DA3
        sta     $02                             ; 9DA5
        stx     $06                             ; 9DA7
        sec                                     ; 9DA9
        jsr     LBDBA                           ; 9DAA
        ldy     #$01                            ; 9DAD
        jsr     LBE35                           ; 9DAF
L9DB2:  jsr     LDBC0                           ; 9DB2
        ldx     #$03                            ; 9DB5
L9DB7:  jmp     LDA44                           ; 9DB7

; ----------------------------------------------------------------------------
        php                                     ; 9DBA
        ldx     #$00                            ; 9DBB
        stx     $04                             ; 9DBD
        stx     $05                             ; 9DBF
        inx                                     ; 9DC1
        stx     $03                             ; 9DC2
        lda     $0517                           ; 9DC4
        bpl     L9DCC                           ; 9DC7
        plp                                     ; 9DC9
        beq     L9E2D                           ; 9DCA
L9DCC:  asl     a                               ; 9DCC
        plp                                     ; 9DCD
        php                                     ; 9DCE
        adc     #$00                            ; 9DCF
        tax                                     ; 9DD1
        lda     $03BE,x                         ; 9DD2
        sta     $07                             ; 9DD5
        lda     $0520                           ; 9DD7
        bpl     L9DE2                           ; 9DDA
        plp                                     ; 9DDC
        sec                                     ; 9DDD
        ror     $05                             ; 9DDE
        bne     L9DEC                           ; 9DE0
L9DE2:  asl     a                               ; 9DE2
        plp                                     ; 9DE3
        adc     #$00                            ; 9DE4
        tax                                     ; 9DE6
        lda     $03BE,x                         ; 9DE7
        sta     $08                             ; 9DEA
L9DEC:  ldx     #$02                            ; 9DEC
        bit     $05                             ; 9DEE
        bmi     L9DF8                           ; 9DF0
        lda     $08                             ; 9DF2
        cmp     $07                             ; 9DF4
        bcc     L9DFF                           ; 9DF6
L9DF8:  dex                                     ; 9DF8
        lda     $07                             ; 9DF9
        bit     $04                             ; 9DFB
        bmi     L9E03                           ; 9DFD
L9DFF:  cmp     $06                             ; 9DFF
        bcc     L9E07                           ; 9E01
L9E03:  ldx     #$00                            ; 9E03
        lda     $06                             ; 9E05
L9E07:  clc                                     ; 9E07
        adc     #$28                            ; 9E08
        sta     $06,x                           ; 9E0A
        inc     $03,x                           ; 9E0C
        lda     $03,x                           ; 9E0E
        bcs     L9E1A                           ; 9E10
        cpx     #$00                            ; 9E12
        beq     L9E1E                           ; 9E14
        cmp     #$09                            ; 9E16
        bcc     L9E1E                           ; 9E18
L9E1A:  ora     #$80                            ; 9E1A
        sta     $03,x                           ; 9E1C
L9E1E:  dec     $02                             ; 9E1E
        bne     L9DEC                           ; 9E20
        ldx     #$02                            ; 9E22
        lda     $03,x                           ; 9E24
        and     #$3F                            ; 9E26
        sta     $03,x                           ; 9E28
        dex                                     ; 9E2A
        .byte   $10                             ; 9E2B
L9E2C:  .byte   $F7                             ; 9E2C
L9E2D:  clc                                     ; 9E2D
        lda     $02                             ; 9E2E
        adc     $03                             ; 9E30
        sta     $03                             ; 9E32
        rts                                     ; 9E34

; ----------------------------------------------------------------------------
        lda     $03                             ; 9E35
        sta     $0515,y                         ; 9E37
        lda     $04                             ; 9E3A
        sta     $051E,y                         ; 9E3C
        lda     $05                             ; 9E3F
        sta     $0527,y                         ; 9E41
L9E44:  rts                                     ; 9E44

; ----------------------------------------------------------------------------
        inc     $ED                             ; 9E45
        lda     $ED                             ; 9E47
        lsr     a                               ; 9E49
        lsr     a                               ; 9E4A
        lsr     a                               ; 9E4B
        lsr     a                               ; 9E4C
        jsr     LDB55                           ; 9E4D
        ldy     $01                             ; 9E50
        lda     $C2                             ; 9E52
        lsr     a                               ; 9E54
        bcc     L9E93                           ; 9E55
        clc                                     ; 9E57
        jsr     LDB55                           ; 9E58
        ldy     $01                             ; 9E5B
        lda     $DB81,y                         ; 9E5D
        sta     $0500                           ; 9E60
        asl     a                               ; 9E63
        tax                                     ; 9E64
        lda     $03BE,x                         ; 9E65
        beq     L9E8B                           ; 9E68
        ldx     #$00                            ; 9E6A
L9E6C:  lda     $0517,x                         ; 9E6C
        cmp     $DB81,y                         ; 9E6F
        beq     L9E44                           ; 9E72
        cmp     #$FF                            ; 9E74
        beq     L9E80                           ; 9E76
        dex                                     ; 9E78
        bpl     L9E7F                           ; 9E79
        ldx     #$09                            ; 9E7B
        bne     L9E6C                           ; 9E7D
L9E7F:  inx                                     ; 9E7F
L9E80:  lda     $DB81,y                         ; 9E80
        sta     $0517,x                         ; 9E83
        inc     $00                             ; 9E86
        jmp     LDE51                           ; 9E88

; ----------------------------------------------------------------------------
L9E8B:  ldx     #$02                            ; 9E8B
        jsr     LDA44                           ; 9E8D
L9E90:  jmp     LDB4C                           ; 9E90

; ----------------------------------------------------------------------------
L9E93:  lsr     a                               ; 9E93
        bcs     L9E90                           ; 9E94
        tax                                     ; 9E96
        lda     $02                             ; 9E97
        pha                                     ; 9E99
        txa                                     ; 9E9A
        lsr     a                               ; 9E9B
        lsr     a                               ; 9E9C
        lsr     a                               ; 9E9D
        bit     $02                             ; 9E9E
        bcs     L9EA7                           ; 9EA0
        lsr     a                               ; 9EA2
        bcc     L9EC3                           ; 9EA3
        bcs     L9EA8                           ; 9EA5
L9EA7:  clc                                     ; 9EA7
L9EA8:  bvc     L9EAF                           ; 9EA8
        dey                                     ; 9EAA
        lda     #$00                            ; 9EAB
        sta     $02                             ; 9EAD
L9EAF:  tya                                     ; 9EAF
        bcs     L9EB8                           ; 9EB0
        sbc     #$02                            ; 9EB2
        sbc     #$00                            ; 9EB4
        bcs     L9EBE                           ; 9EB6
L9EB8:  adc     #$02                            ; 9EB8
        cmp     #$0F                            ; 9EBA
        adc     #$00                            ; 9EBC
L9EBE:  and     #$0F                            ; 9EBE
        tay                                     ; 9EC0
        bpl     L9EEF                           ; 9EC1
L9EC3:  lsr     a                               ; 9EC3
        bcc     L9ED9                           ; 9EC4
        bit     $02                             ; 9EC6
        bmi     L9EF7                           ; 9EC8
L9ECA:  clc                                     ; 9ECA
        lda     #$40                            ; 9ECB
        adc     $02                             ; 9ECD
        sta     $02                             ; 9ECF
        iny                                     ; 9ED1
        lda     $DB81,y                         ; 9ED2
        bmi     L9ECA                           ; 9ED5
        bpl     L9EEF                           ; 9ED7
L9ED9:  lsr     a                               ; 9ED9
        bcc     L9EF7                           ; 9EDA
        bit     $02                             ; 9EDC
        bvs     L9EE2                           ; 9EDE
        bpl     L9EF7                           ; 9EE0
L9EE2:  sec                                     ; 9EE2
        lda     $02                             ; 9EE3
        sbc     #$40                            ; 9EE5
        sta     $02                             ; 9EE7
        dey                                     ; 9EE9
        lda     $DB81,y                         ; 9EEA
        bmi     L9EE2                           ; 9EED
L9EEF:  ldx     $DB81,y                         ; 9EEF
        lda     $0334,x                         ; 9EF2
        bne     L9EFB                           ; 9EF5
L9EF7:  pla                                     ; 9EF7
        sta     $02                             ; 9EF8
        rts                                     ; 9EFA

; ----------------------------------------------------------------------------
L9EFB:  tya                                     ; 9EFB
        pha                                     ; 9EFC
        sec                                     ; 9EFD
        jsr     LDB55                           ; 9EFE
        pla                                     ; 9F01
        sta     $01                             ; 9F02
        pla                                     ; 9F04
        clc                                     ; 9F05
L9F06:  jmp     LDB55                           ; 9F06

; ----------------------------------------------------------------------------
        lda     #$40                            ; 9F09
        ldx     $01                             ; 9F0B
        bne     L9F12                           ; 9F0D
        asl     a                               ; 9F0F
        bcc     L9F18                           ; 9F10
L9F12:  cpx     #$0A                            ; 9F12
        bcc     L9F18                           ; 9F14
        lda     #$C0                            ; 9F16
L9F18:  jsr     LDDEA                           ; 9F18
        lda     $01                             ; 9F1B
        lsr     a                               ; 9F1D
        bcc     L9F32                           ; 9F1E
        beq     L9F27                           ; 9F20
        bit     $00                             ; 9F22
        clc                                     ; 9F24
        bvs     L9F32                           ; 9F25
L9F27:  pha                                     ; 9F27
        jsr     LBF7A                           ; 9F28
        pla                                     ; 9F2B
        clc                                     ; 9F2C
        adc     #$05                            ; 9F2D
        jsr     LBF7A                           ; 9F2F
L9F32:  inc     $01                             ; 9F32
        lda     $01                             ; 9F34
        cmp     #$0B                            ; 9F36
        bcs     L9F3B                           ; 9F38
        rts                                     ; 9F3A

; ----------------------------------------------------------------------------
L9F3B:  lda     $00                             ; 9F3B
        bit     $00                             ; 9F3D
        bpl     L9F43                           ; 9F3F
        ora     #$04                            ; 9F41
L9F43:  and     #$BF                            ; 9F43
        sta     $00                             ; 9F45
        bvc     L9F66                           ; 9F47
        lda     $0422                           ; 9F49
        beq     L9F51                           ; 9F4C
        jsr     LB078                           ; 9F4E
L9F51:  lda     $0414                           ; 9F51
        cmp     #$03                            ; 9F54
        beq     L9F6D                           ; 9F56
        cmp     #$05                            ; 9F58
        beq     L9F6D                           ; 9F5A
        lda     $0416                           ; 9F5C
        sta     $0414                           ; 9F5F
        lda     #$01                            ; 9F62
        sta     $1A                             ; 9F64
L9F66:  inc     $1A                             ; 9F66
        lda     #$00                            ; 9F68
        sta     $01                             ; 9F6A
        rts                                     ; 9F6C

; ----------------------------------------------------------------------------
L9F6D:  lda     #$05                            ; 9F6D
        sta     $01                             ; 9F6F
        lda     #$AD                            ; 9F71
        sta     $09                             ; 9F73
        lda     #$22                            ; 9F75
        sta     $08                             ; 9F77
L9F79:  rts                                     ; 9F79

; ----------------------------------------------------------------------------
        tay                                     ; 9F7A
        lda     $0409,y                         ; 9F7B
        beq     L9F79                           ; 9F7E
        ldx     #$00                            ; 9F80
        bcc     L9F85                           ; 9F82
        inx                                     ; 9F84
L9F85:  cpy     #$05                            ; 9F85
        bcc     L9F8B                           ; 9F87
        ldx     #$08                            ; 9F89
L9F8B:  jmp     LB331                           ; 9F8B

; ----------------------------------------------------------------------------
        .byte   $FF                             ; 9F8E
        .byte   $FF                             ; 9F8F
        .byte   $FF                             ; 9F90
        .byte   $FF                             ; 9F91
        .byte   $FF                             ; 9F92
        .byte   $FF                             ; 9F93
        .byte   $FF                             ; 9F94
        .byte   $FF                             ; 9F95
        .byte   $FF                             ; 9F96
        .byte   $FF                             ; 9F97
        .byte   $FF                             ; 9F98
        .byte   $FF                             ; 9F99
        .byte   $FF                             ; 9F9A
        .byte   $FF                             ; 9F9B
        .byte   $FF                             ; 9F9C
        .byte   $FF                             ; 9F9D
        .byte   $FF                             ; 9F9E
        .byte   $FF                             ; 9F9F
        .byte   $FF                             ; 9FA0
        .byte   $FF                             ; 9FA1
        .byte   $FF                             ; 9FA2
        .byte   $FF                             ; 9FA3
        .byte   $FF                             ; 9FA4
        .byte   $FF                             ; 9FA5
        .byte   $FF                             ; 9FA6
        .byte   $FF                             ; 9FA7
        .byte   $FF                             ; 9FA8
        .byte   $FF                             ; 9FA9
        .byte   $FF                             ; 9FAA
        .byte   $FF                             ; 9FAB
        .byte   $FF                             ; 9FAC
        .byte   $FF                             ; 9FAD
        .byte   $FF                             ; 9FAE
        .byte   $FF                             ; 9FAF
        .byte   $FF                             ; 9FB0
        .byte   $FF                             ; 9FB1
        .byte   $FF                             ; 9FB2
        .byte   $FF                             ; 9FB3
        .byte   $FF                             ; 9FB4
        .byte   $FF                             ; 9FB5
        .byte   $FF                             ; 9FB6
        .byte   $FF                             ; 9FB7
        .byte   $FF                             ; 9FB8
        .byte   $FF                             ; 9FB9
        .byte   $FF                             ; 9FBA
        .byte   $FF                             ; 9FBB
        .byte   $FF                             ; 9FBC
        .byte   $FF                             ; 9FBD
        .byte   $FF                             ; 9FBE
        .byte   $FF                             ; 9FBF
        .byte   $FF                             ; 9FC0
        .byte   $FF                             ; 9FC1
        .byte   $FF                             ; 9FC2
        .byte   $FF                             ; 9FC3
        .byte   $FF                             ; 9FC4
        .byte   $FF                             ; 9FC5
        .byte   $FF                             ; 9FC6
        .byte   $FF                             ; 9FC7
        .byte   $FF                             ; 9FC8
        .byte   $FF                             ; 9FC9
        .byte   $FF                             ; 9FCA
        .byte   $FF                             ; 9FCB
        .byte   $FF                             ; 9FCC
        .byte   $FF                             ; 9FCD
        .byte   $FF                             ; 9FCE
        .byte   $FF                             ; 9FCF
        .byte   $FF                             ; 9FD0
        .byte   $FF                             ; 9FD1
        .byte   $FF                             ; 9FD2
        .byte   $FF                             ; 9FD3
        .byte   $FF                             ; 9FD4
        .byte   $FF                             ; 9FD5
        .byte   $FF                             ; 9FD6
        .byte   $FF                             ; 9FD7
        .byte   $FF                             ; 9FD8
        .byte   $FF                             ; 9FD9
        .byte   $FF                             ; 9FDA
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
