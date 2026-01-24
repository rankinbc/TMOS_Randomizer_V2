; ============================================================================
; The Magic of Scheherazade - Bank 04 Disassembly
; ============================================================================
; File Offset: 0x08000 - 0x09FFF
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
; Created:    2026-01-24 04:39:25
; Input file: C:/claude-workspace/TMOS_AI/rom-files/disassembly/output/banks/bank_04.bin
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
L030F           := $030F
L0818           := $0818
L0E0D           := $0E0D
PPU_CTRL        := $2000
PPU_MASK        := $2001
PPU_STATUS      := $2002
OAM_ADDR        := $2003
OAM_DATA        := $2004
PPU_SCROLL      := $2005
PPU_ADDR        := $2006
PPU_DATA        := $2007
L2C42           := $2C42
L3441           := $3441
L3445           := $3445
L34C3           := $34C3
L38BC           := $38BC
L3B3B           := $3B3B
L3BC2           := $3BC2
L3CC2           := $3CC2
OAM_DMA         := $4014
APU_STATUS      := $4015
JOY1            := $4016
JOY2_FRAME      := $4017
L7FFA           := $7FFA
LB445           := $B445
LFA42           := $FA42
LFEFA           := $FEFA
; ----------------------------------------------------------------------------
        sbc     #$A1                            ; 8000
        .byte   $1C                             ; 8002
        ldx     $1A                             ; 8003
        lda     #$74                            ; 8005
        ldy     $99                             ; 8007
        .byte   $A3                             ; 8009
        .byte   $5C                             ; 800A
        lda     $DB                             ; 800B
        ldy     $90                             ; 800D
        tay                                     ; 800F
        ror     a                               ; 8010
        .byte   $A3                             ; 8011
        php                                     ; 8012
        tax                                     ; 8013
        sec                                     ; 8014
        asl     $16                             ; 8015
        .byte   $82                             ; 8017
        cmp     #$82                            ; 8018
        rol     $4583,x                         ; 801A
        asl     $89                             ; 801D
        asl     $A6                             ; 801F
        asl     $EB                             ; 8021
        asl     $23                             ; 8023
        .byte   $07                             ; 8025
        eor     #$07                            ; 8026
        .byte   $FB                             ; 8028
        .byte   $83                             ; 8029
        .byte   $89                             ; 802A
        sty     $94                             ; 802B
        .byte   $07                             ; 802D
        .byte   $BF                             ; 802E
        .byte   $07                             ; 802F
        inx                                     ; 8030
        .byte   $07                             ; 8031
        .byte   $F2                             ; 8032
        .byte   $07                             ; 8033
        bit     $08                             ; 8034
        .byte   $57                             ; 8036
        php                                     ; 8037
        inx                                     ; 8038
        .byte   $07                             ; 8039
        .byte   $C7                             ; 803A
        php                                     ; 803B
        .byte   $12                             ; 803C
        ora     #$CA                            ; 803D
        sty     $40                             ; 803F
        ora     #$3B                            ; 8041
        sta     $86                             ; 8043
        ora     #$B2                            ; 8045
        ora     #$C1                            ; 8047
        ora     #$E0                            ; 8049
        ora     #$35                            ; 804B
        asl     a                               ; 804D
        .byte   $47                             ; 804E
        asl     a                               ; 804F
        adc     ($0A,x)                         ; 8050
        dey                                     ; 8052
        asl     a                               ; 8053
        clv                                     ; 8054
        asl     a                               ; 8055
        .byte   $D0                             ; 8056
L8057:  asl     a                               ; 8057
        sbc     $0A,x                           ; 8058
        eor     #$0B                            ; 805A
        cli                                     ; 805C
        .byte   $0B                             ; 805D
        lda     ($0B,x)                         ; 805E
        ldy     $0B,x                           ; 8060
L8062:  dec     $0B                             ; 8062
        .byte   $EB                             ; 8064
        .byte   $0B                             ; 8065
        rol     a                               ; 8066
        .byte   $0C                             ; 8067
        .byte   $52                             ; 8068
        .byte   $0C                             ; 8069
        .byte   $89                             ; 806A
        .byte   $0C                             ; 806B
        cmp     $85                             ; 806C
        cpx     #$0C                            ; 806E
        ora     $0D                             ; 8070
        .byte   $3F                             ; 8072
        ora     $0D5B                           ; 8073
        .byte   $82                             ; 8076
        ora     $0D9E                           ; 8077
        cpy     #$0D                            ; 807A
        rol     L9B86,x                         ; 807C
        stx     $E7                             ; 807F
        stx     $32                             ; 8081
        .byte   $87                             ; 8083
        dec     $BD0D,x                         ; 8084
        .byte   $87                             ; 8087
        .byte   $0F                             ; 8088
        dey                                     ; 8089
        rol     $6988                           ; 808A
        dey                                     ; 808D
        .byte   $FC                             ; 808E
        dey                                     ; 808F
        eor     $89,x                           ; 8090
        stx     $89                             ; 8092
        .byte   $EB                             ; 8094
L8095:  .byte   $89                             ; 8095
        .byte   $43                             ; 8096
        .byte   $0E                             ; 8097
L8098:  .byte   $64                             ; 8098
        asl     $8A7D                           ; 8099
        .byte   $9F                             ; 809C
        txa                                     ; 809D
        .byte   $1C                             ; 809E
        .byte   $8B                             ; 809F
        .byte   $62                             ; 80A0
        .byte   $8B                             ; 80A1
        sty     $EE8B                           ; 80A2
        .byte   $8B                             ; 80A5
        .byte   $63                             ; 80A6
        sty     L8CDC                           ; 80A7
        .byte   $1A                             ; 80AA
        sta     L8D67                           ; 80AB
        .byte   $C5                             ; 80AE
L80AF:  sta     $8E55                           ; 80AF
        tya                                     ; 80B2
        asl     $0EC1                           ; 80B3
        .byte   $D7                             ; 80B6
        asl     $0EE4                           ; 80B7
        .byte   $FF                             ; 80BA
        asl     $0F15                           ; 80BB
        and     a:$0F,x                         ; 80BE
        bpl     L80CF                           ; 80C1
        bpl     L80EC                           ; 80C3
        bpl     L80EF                           ; 80C5
        bpl     L810D                           ; 80C7
        bpl     L8141                           ; 80C9
L80CB:  bpl     L8057                           ; 80CB
        bpl     L8095                           ; 80CD
L80CF:  bpl     L8098                           ; 80CF
        bpl     L80AF                           ; 80D1
        bpl     L80CB                           ; 80D3
        bpl     L80EF                           ; 80D5
        ora     ($42),y                         ; 80D7
        ora     ($79),y                         ; 80D9
        ora     ($B7),y                         ; 80DB
        ora     ($E2),y                         ; 80DD
        ora     ($13),y                         ; 80DF
        .byte   $12                             ; 80E1
        .byte   $34                             ; 80E2
        .byte   $12                             ; 80E3
        .byte   $47                             ; 80E4
        .byte   $12                             ; 80E5
        .byte   $89                             ; 80E6
        .byte   $12                             ; 80E7
        cmp     $12                             ; 80E8
        sbc     $12,x                           ; 80EA
L80EC:  .byte   $1F                             ; 80EC
        .byte   $13                             ; 80ED
        .byte   $86                             ; 80EE
L80EF:  php                                     ; 80EF
        brk                                     ; 80F0
        brk                                     ; 80F1
        brk                                     ; 80F2
        brk                                     ; 80F3
        brk                                     ; 80F4
        brk                                     ; 80F5
        and     $6413                           ; 80F6
        .byte   $13                             ; 80F9
        sta     ($13,x)                         ; 80FA
        ldy     #$13                            ; 80FC
        clv                                     ; 80FE
        .byte   $13                             ; 80FF
        .byte   $DA                             ; 8100
        .byte   $13                             ; 8101
        ora     $14                             ; 8102
        adc     #$14                            ; 8104
        .byte   $B3                             ; 8106
        .byte   $14                             ; 8107
        cld                                     ; 8108
        .byte   $14                             ; 8109
        asl     $3D15,x                         ; 810A
L810D:  ora     $90,x                           ; 810D
        ora     $A3,x                           ; 810F
        ora     $DC,x                           ; 8111
        ora     $02,x                           ; 8113
        asl     $39,x                           ; 8115
        asl     $65,x                           ; 8117
L8119:  asl     $96,x                           ; 8119
        asl     $BA,x                           ; 811B
        asl     $01,x                           ; 811D
        .byte   $17                             ; 811F
        tya                                     ; 8120
        stx     L8EB1                           ; 8121
        and     #$17                            ; 8124
        eor     $17,x                           ; 8126
        .byte   $77                             ; 8128
        .byte   $17                             ; 8129
        sta     $17,x                           ; 812A
        lda     #$17                            ; 812C
L812E:  cmp     ($17,x)                         ; 812E
        ldx     $EE8E,y                         ; 8130
        .byte   $8F                             ; 8133
        cmp     $0917,y                         ; 8134
        clc                                     ; 8137
        sei                                     ; 8138
        bcc     L812E                           ; 8139
L813B:  bcc     L81A7                           ; 813B
        sta     ($E5),y                         ; 813D
        sta     ($0F),y                         ; 813F
L8141:  .byte   $93                             ; 8141
        lsr     $18                             ; 8142
        adc     $BA18                           ; 8144
        .byte   $93                             ; 8147
        .byte   $82                             ; 8148
        clc                                     ; 8149
        lda     ($18,x)                         ; 814A
        .byte   $C2                             ; 814C
        clc                                     ; 814D
        cld                                     ; 814E
        clc                                     ; 814F
        .byte   $FA                             ; 8150
        clc                                     ; 8151
        .byte   $FB                             ; 8152
        clc                                     ; 8153
        .byte   $FC                             ; 8154
        clc                                     ; 8155
        .byte   $14                             ; 8156
        ora     $1915,y                         ; 8157
        eor     #$19                            ; 815A
        rts                                     ; 815C

; ----------------------------------------------------------------------------
        ora     $1991,y                         ; 815D
        lda     $19,x                           ; 8160
        dec     $19                             ; 8162
        beq     L817F                           ; 8164
        .byte   $0B                             ; 8166
        .byte   $1A                             ; 8167
        .byte   $2F                             ; 8168
        .byte   $1A                             ; 8169
        .byte   $7B                             ; 816A
        .byte   $1A                             ; 816B
        ldy     $1A                             ; 816C
        cpy     #$1A                            ; 816E
        sbc     $0A1A                           ; 8170
        .byte   $1B                             ; 8173
        eor     $1B,x                           ; 8174
        .byte   $7F                             ; 8176
        .byte   $1B                             ; 8177
        lda     #$1B                            ; 8178
        .byte   $D3                             ; 817A
        .byte   $1B                             ; 817B
        .byte   $0C                             ; 817C
        .byte   $1C                             ; 817D
        .byte   $26                             ; 817E
L817F:  .byte   $1C                             ; 817F
        brk                                     ; 8180
        brk                                     ; 8181
        .byte   $BB                             ; 8182
        .byte   $93                             ; 8183
        beq     L8119                           ; 8184
        .byte   $7F                             ; 8186
        .byte   $1C                             ; 8187
        .byte   $93                             ; 8188
        .byte   $1C                             ; 8189
        .byte   $AF                             ; 818A
        .byte   $1C                             ; 818B
        cmp     $251C,x                         ; 818C
        sty     $53,x                           ; 818F
        sty     $90,x                           ; 8191
        sty     $CE,x                           ; 8193
        sty     $10,x                           ; 8195
        sta     $F4,x                           ; 8197
        .byte   $1C                             ; 8199
        .byte   $0F                             ; 819A
        ora     $1D27,x                         ; 819B
        .byte   $3B                             ; 819E
        ora     $1D4F,x                         ; 819F
        .byte   $7F                             ; 81A2
        ora     $1D93,x                         ; 81A3
        .byte   $AF                             ; 81A6
L81A7:  ora     $1DD6,x                         ; 81A7
        .byte   $44                             ; 81AA
        sta     $72,x                           ; 81AB
        sta     $E9,x                           ; 81AD
        ora     $1E0D,x                         ; 81AF
        and     $5E1E,y                         ; 81B2
        asl     L95E4,x                         ; 81B5
        .byte   $D7                             ; 81B8
        stx     $B4,y                           ; 81B9
        asl     $1EC2,x                         ; 81BB
        cmp     ($1E),y                         ; 81BE
        sbc     ($1E,x)                         ; 81C0
        beq     L81E2                           ; 81C2
        sbc     $0B1E,x                         ; 81C4
        .byte   $1F                             ; 81C7
        .byte   $1B                             ; 81C8
        .byte   $1F                             ; 81C9
        rol     a                               ; 81CA
        .byte   $1F                             ; 81CB
        sec                                     ; 81CC
        .byte   $1F                             ; 81CD
        eor     $1F,x                           ; 81CE
        bvs     L81F1                           ; 81D0
        tay                                     ; 81D2
        sta     $BB,x                           ; 81D3
        sta     $D0,x                           ; 81D5
        sta     $00,x                           ; 81D7
        brk                                     ; 81D9
        brk                                     ; 81DA
        brk                                     ; 81DB
        brk                                     ; 81DC
        brk                                     ; 81DD
        brk                                     ; 81DE
        brk                                     ; 81DF
        brk                                     ; 81E0
        brk                                     ; 81E1
L81E2:  brk                                     ; 81E2
        brk                                     ; 81E3
        brk                                     ; 81E4
        brk                                     ; 81E5
        brk                                     ; 81E6
        brk                                     ; 81E7
        brk                                     ; 81E8
        brk                                     ; 81E9
        brk                                     ; 81EA
        brk                                     ; 81EB
        brk                                     ; 81EC
        brk                                     ; 81ED
        brk                                     ; 81EE
        brk                                     ; 81EF
        brk                                     ; 81F0
L81F1:  brk                                     ; 81F1
        brk                                     ; 81F2
        brk                                     ; 81F3
        brk                                     ; 81F4
        brk                                     ; 81F5
        brk                                     ; 81F6
        brk                                     ; 81F7
        brk                                     ; 81F8
        brk                                     ; 81F9
        brk                                     ; 81FA
        brk                                     ; 81FB
        brk                                     ; 81FC
        brk                                     ; 81FD
        brk                                     ; 81FE
        brk                                     ; 81FF
        brk                                     ; 8200
        brk                                     ; 8201
        brk                                     ; 8202
        brk                                     ; 8203
        brk                                     ; 8204
        brk                                     ; 8205
        brk                                     ; 8206
        brk                                     ; 8207
        brk                                     ; 8208
        brk                                     ; 8209
        brk                                     ; 820A
        brk                                     ; 820B
        brk                                     ; 820C
        brk                                     ; 820D
        brk                                     ; 820E
        brk                                     ; 820F
        brk                                     ; 8210
        brk                                     ; 8211
        brk                                     ; 8212
        brk                                     ; 8213
        brk                                     ; 8214
        brk                                     ; 8215
        sec                                     ; 8216
        bit     $3C30                           ; 8217
        bit     $2C9A                           ; 821A
        cpy     $48                             ; 821D
        bit     $3032                           ; 821F
        .byte   $3B                             ; 8222
        .byte   $3B                             ; 8223
        bit     $3039                           ; 8224
        .byte   $33                             ; 8227
        .byte   $4F                             ; 8228
        .byte   $FA                             ; 8229
        .byte   $82                             ; 822A
        .byte   $2C                             ; 822B
L822C:  bmi     *+46                            ; 822C
        .byte   $42                             ; 822E
        .byte   $43                             ; 822F
        eor     ($30,x)                         ; 8230
        and     $3436,x                         ; 8232
        .byte   $FA                             ; 8235
        rol     $343D,x                         ; 8236
        .byte   $2C                             ; 8239
        sec                                     ; 823A
L823B:  bit     $3431                           ; 823B
        .byte   $4F                             ; 823E
        .byte   $FA                             ; 823F
        .byte   $7F                             ; 8240
L8241:  .byte   $43                             ; 8241
        rol     $C42C,x                         ; 8242
        bit     $3034                           ; 8245
        .byte   $42                             ; 8248
        .byte   $43                             ; 8249
        bit     $3D3E                           ; 824A
        bit     $2C30                           ; 824D
        .byte   $3F                             ; 8250
        sec                                     ; 8251
        .byte   $34                             ; 8252
        eor     ($FA,x)                         ; 8253
        lsr     $30                             ; 8255
        .byte   $42                             ; 8257
        bit     $2C30                           ; 8258
        .byte   $33                             ; 825B
        rol     $413E,x                         ; 825C
        .byte   $FA                             ; 825F
        lsr     $37                             ; 8260
        sec                                     ; 8262
        .byte   $32                             ; 8263
        .byte   $37                             ; 8264
        bit     $3032                           ; 8265
        .byte   $3C                             ; 8268
        .byte   $34                             ; 8269
        bit     $4135                           ; 826A
        .byte   $34                             ; 826D
        .byte   $34                             ; 826E
        .byte   $4F                             ; 826F
        .byte   $FA                             ; 8270
        .byte   $7F                             ; 8271
        .byte   $82                             ; 8272
        bit     $3431                           ; 8273
        .byte   $37                             ; 8276
        rol     $333B,x                         ; 8277
        adc     $352C,x                         ; 827A
        sec                                     ; 827D
        and     $43,x                           ; 827E
        pha                                     ; 8280
        bit     $FAD3                           ; 8281
        sec                                     ; 8284
        and     $C42C,x                         ; 8285
        bit     $303F                           ; 8288
        .byte   $42                             ; 828B
        .byte   $43                             ; 828C
        .byte   $FA                             ; 828D
        sec                                     ; 828E
        bit     $3833                           ; 828F
        .byte   $33                             ; 8292
        bit     $3442                           ; 8293
        .byte   $34                             ; 8296
        .byte   $7D                             ; 8297
L8298:  .byte   $FA                             ; 8298
        .byte   $7F                             ; 8299
        sec                                     ; 829A
        .byte   $43                             ; 829B
        bit     $303C                           ; 829C
        pha                                     ; 829F
        bit     $3E42                           ; 82A0
        .byte   $44                             ; 82A3
        and     $FA33,x                         ; 82A4
        .byte   $A7                             ; 82A7
        bit     $2C30                           ; 82A8
        .byte   $33                             ; 82AB
        eor     ($34,x)                         ; 82AC
        bmi     L82EC                           ; 82AE
        .byte   $FA                             ; 82B0
        and     ($44),y                         ; 82B1
        .byte   $43                             ; 82B3
        bit     $2C38                           ; 82B4
        .byte   $42                             ; 82B7
        bmi     L8300                           ; 82B8
        bit     $4338                           ; 82BA
        adc     $432C,y                         ; 82BD
        eor     ($44,x)                         ; 82C0
        .byte   $42                             ; 82C2
        .byte   $43                             ; 82C3
        bit     $4FAC                           ; 82C4
        .byte   $FA                             ; 82C7
        inc     $2C9E,x                         ; 82C8
        cpy     $2C                             ; 82CB
        .byte   $3B                             ; 82CD
        bmi     L830C                           ; 82CE
        .byte   $3F                             ; 82D0
        jmp     L2C42                           ; 82D1

; ----------------------------------------------------------------------------
        cmp     ($79,x)                         ; 82D4
        .byte   $FA                             ; 82D6
        and     $30,x                           ; 82D7
        eor     ($44,x)                         ; 82D9
        .byte   $3A                             ; 82DB
        .byte   $4F                             ; 82DC
        bit     $79FF                           ; 82DD
        bit     $2CD2                           ; 82E0
        sta     ($FA,x)                         ; 82E3
        cpy     $2C                             ; 82E5
        .byte   $33                             ; 82E7
        .byte   $34                             ; 82E8
        .byte   $42                             ; 82E9
        .byte   $32                             ; 82EA
        .byte   $34                             ; 82EB
L82EC:  and     $3033,x                         ; 82EC
        and     $2C43,x                         ; 82EF
        rol     $2C35,x                         ; 82F2
        ldx     #$7D                            ; 82F5
        .byte   $FA                             ; 82F7
        .byte   $D2                             ; 82F8
        bit     $2C81                           ; 82F9
        .byte   $3C                             ; 82FC
        pha                                     ; 82FD
        .byte   $2C                             ; 82FE
        .byte   $3C                             ; 82FF
L8300:  bmi     L8344                           ; 8300
        .byte   $43                             ; 8302
        .byte   $34                             ; 8303
        eor     ($7D,x)                         ; 8304
        .byte   $FA                             ; 8306
        .byte   $7F                             ; 8307
        lda     ($2C,x)                         ; 8308
        and     ($34),y                         ; 830A
L830C:  .byte   $34                             ; 830C
        and     $462C,x                         ; 830D
        bmi     L834A                           ; 8310
        .byte   $43                             ; 8312
        .byte   $A3                             ; 8313
        bit     $3E35                           ; 8314
        eor     ($FA,x)                         ; 8317
        .byte   $D2                             ; 8319
        bit     $3E35                           ; 831A
        eor     ($2C,x)                         ; 831D
        bmi     L834D                           ; 831F
        .byte   $3B                             ; 8321
        rol     $363D,x                         ; 8322
        bit     $4FC9                           ; 8325
        .byte   $FA                             ; 8328
        and     $463E,x                         ; 8329
        bit     $2CAB                           ; 832C
        and     ($34),y                         ; 832F
        rol     $38,x                           ; 8331
        and     $3E2C,x                         ; 8333
        .byte   $44                             ; 8336
        eor     ($FA,x)                         ; 8337
        .byte   $87                             ; 8339
        .byte   $4F                             ; 833A
L833B:  .byte   $FA                             ; 833B
        .byte   $7F                             ; 833C
        inc     $2C9E,x                         ; 833D
        .byte   $C4                             ; 8340
L8341:  bit     $3E35                           ; 8341
L8344:  eor     ($43,x)                         ; 8344
        .byte   $44                             ; 8346
        and     $7B34,x                         ; 8347
L834A:  .byte   $43                             ; 834A
        .byte   $34                             ; 834B
        .byte   $3B                             ; 834C
L834D:  .byte   $3B                             ; 834D
        .byte   $34                             ; 834E
        eor     ($FA,x)                         ; 834F
        .byte   $33                             ; 8351
        rol     $4297,x                         ; 8352
        .byte   $4F                             ; 8355
        .byte   $FA                             ; 8356
        .byte   $7F                             ; 8357
        tsx                                     ; 8358
        bit     $2C9F                           ; 8359
        lsr     $30                             ; 835C
        sec                                     ; 835E
        .byte   $43                             ; 835F
        .byte   $A3                             ; 8360
        bit     $3E35                           ; 8361
        eor     ($FA,x)                         ; 8364
        .byte   $D2                             ; 8366
        bit     $2CCE                           ; 8367
        and     $34,x                           ; 836A
        bmi     L83AF                           ; 836C
        .byte   $42                             ; 836E
        rol     $343C,x                         ; 836F
        bit     $42D6                           ; 8372
        .byte   $FA                             ; 8375
        bmi     L83BB                           ; 8376
        bit     $2CC4                           ; 8378
        bcs     L83A9                           ; 837B
        sec                                     ; 837D
        and     $C42C,x                         ; 837E
        .byte   $FA                             ; 8381
        and     ($3E),y                         ; 8382
        .byte   $43                             ; 8384
        .byte   $43                             ; 8385
        rol     $2C3C,x                         ; 8386
        rol     $2C35,x                         ; 8389
        cpy     $2C                             ; 838C
        .byte   $3B                             ; 838E
        bmi     L83CB                           ; 838F
        .byte   $34                             ; 8391
        .byte   $4F                             ; 8392
        .byte   $FA                             ; 8393
        .byte   $7F                             ; 8394
        and     $38,x                           ; 8395
        and     $2C33,x                         ; 8397
        cpy     $2C                             ; 839A
        lda     $2C                             ; 839C
        cmp     ($79,x)                         ; 839E
        .byte   $FA                             ; 83A0
        and     $30,x                           ; 83A1
        eor     ($44,x)                         ; 83A3
        .byte   $3A                             ; 83A5
        cmp     $FA,x                           ; 83A6
        .byte   $82                             ; 83A8
L83A9:  bit     $4439                           ; 83A9
        .byte   $3C                             ; 83AC
        .byte   $3F                             ; 83AD
        .byte   $2C                             ; 83AE
L83AF:  sec                                     ; 83AF
        and     $3E43,x                         ; 83B0
        bit     $2CC4                           ; 83B3
        .byte   $3B                             ; 83B6
        bmi     L83F3                           ; 83B7
        .byte   $34                             ; 83B9
        .byte   $FA                             ; 83BA
L83BB:  and     $41,x                           ; 83BB
        rol     $2C3C,x                         ; 83BD
        cpy     $2C                             ; 83C0
        and     $413E,x                         ; 83C2
        .byte   $43                             ; 83C5
        .byte   $37                             ; 83C6
        bit     $3032                           ; 83C7
        .byte   $3F                             ; 83CA
L83CB:  .byte   $34                             ; 83CB
        cmp     $FA,x                           ; 83CC
        .byte   $7F                             ; 83CE
        ror     $3F7E,x                         ; 83CF
        eor     ($34,x)                         ; 83D2
        .byte   $3F                             ; 83D4
        sta     ($2C,x)                         ; 83D5
        .byte   $D2                             ; 83D7
        eor     ($42,x)                         ; 83D8
        .byte   $34                             ; 83DA
        .byte   $3B                             ; 83DB
        and     $79,x                           ; 83DC
        .byte   $FA                             ; 83DE
        sec                                     ; 83DF
        .byte   $43                             ; 83E0
        bit     $2CCD                           ; 83E1
        and     ($34),y                         ; 83E4
        bit     $3E43                           ; 83E6
        .byte   $44                             ; 83E9
        rol     $37,x                           ; 83EA
        .byte   $4F                             ; 83EC
        .byte   $FA                             ; 83ED
        txs                                     ; 83EE
        adc     L9A2C,x                         ; 83EF
        .byte   $2C                             ; 83F2
L83F3:  txs                                     ; 83F3
        bit     $2C9A                           ; 83F4
        txs                                     ; 83F7
        cmp     $FA,x                           ; 83F8
        inc     $3037,x                         ; 83FA
        adc     $3037,y                         ; 83FD
        adc     $3037,y                         ; 8400
        ror     $382C,x                         ; 8403
        bit     $3C30                           ; 8406
        bit     $2CC4                           ; 8409
        sta     $AEFA,y                         ; 840C
        sec                                     ; 840F
        bmi     L844F                           ; 8410
        bit     $4FBA                           ; 8412
        .byte   $FA                             ; 8415
        .byte   $7F                             ; 8416
        .byte   $D2                             ; 8417
        bit     $3433                           ; 8418
        and     $34,x                           ; 841B
        bmi     L8462                           ; 841D
        .byte   $34                             ; 841F
        .byte   $33                             ; 8420
        bit     $3836                           ; 8421
        .byte   $3B                             ; 8424
        rol     $30,x                           ; 8425
        .byte   $4F                             ; 8427
        .byte   $FA                             ; 8428
        sec                                     ; 8429
        .byte   $2C                             ; 842A
        .byte   $30                             ; 842B
L842C:  .byte   $33                             ; 842C
        .byte   $3C                             ; 842D
        sec                                     ; 842E
        eor     ($34,x)                         ; 842F
        bit     $79D2                           ; 8431
        bit     $383A                           ; 8434
        .byte   $33                             ; 8437
        .byte   $4F                             ; 8438
        bit     $4431                           ; 8439
        .byte   $43                             ; 843C
        .byte   $FA                             ; 843D
        .byte   $7F                             ; 843E
        .byte   $D2                             ; 843F
        bit     $4342                           ; 8440
        sec                                     ; 8443
        .byte   $3B                             ; 8444
        .byte   $3B                             ; 8445
        bit     $3037                           ; 8446
        eor     $34                             ; 8449
        bit     $3E43                           ; 844B
        .byte   $2C                             ; 844E
L844F:  and     $38,x                           ; 844F
        rol     $37,x                           ; 8451
        .byte   $43                             ; 8453
        .byte   $FA                             ; 8454
        .byte   $3C                             ; 8455
        bmi     L8495                           ; 8456
        pha                                     ; 8458
        bit     $42D6                           ; 8459
        bit     $3431                           ; 845C
        and     $3E,x                           ; 845F
        .byte   $41                             ; 8461
L8462:  .byte   $34                             ; 8462
        .byte   $FA                             ; 8463
        ldy     $2C4F                           ; 8464
        .byte   $D2                             ; 8467
        bit     $3032                           ; 8468
        and     $322C,x                         ; 846B
        .byte   $37                             ; 846E
        bmi     L84AC                           ; 846F
        .byte   $3B                             ; 8471
        .byte   $34                             ; 8472
        and     $3436,x                         ; 8473
        .byte   $FA                             ; 8476
        ldy     $2C79                           ; 8477
        and     ($44),y                         ; 847A
        .byte   $43                             ; 847C
        bit     $2CD2                           ; 847D
        cmp     $332C                           ; 8480
        sec                                     ; 8483
        .byte   $34                             ; 8484
        .byte   $4F                             ; 8485
        .byte   $FA                             ; 8486
        .byte   $7F                             ; 8487
        inc     $3538,x                         ; 8488
        bit     $2CD2                           ; 848B
        .byte   $8F                             ; 848E
        bit     $4342                           ; 848F
        bmi     L84DC                           ; 8492
        .byte   $2C                             ; 8494
L8495:  bmi     L84D2                           ; 8495
        .byte   $34                             ; 8497
        eor     ($43,x)                         ; 8498
        adc     L7FFA,y                         ; 849A
        .byte   $D2                             ; 849D
        eor     ($2C,x)                         ; 849E
        .byte   $BF                             ; 84A0
        bit     $FAC4                           ; 84A1
        ldy     $2C,x                           ; 84A4
        ldy     $CDFA,x                         ; 84A6
        bit     $3035                           ; 84A9
L84AC:  .byte   $3B                             ; 84AC
        .byte   $3B                             ; 84AD
        bit     $3845                           ; 84AE
        .byte   $32                             ; 84B1
        .byte   $43                             ; 84B2
        sec                                     ; 84B3
        .byte   $3C                             ; 84B4
        bit     $3E43                           ; 84B5
        bit     $FAC4                           ; 84B8
        dec     $4F,x                           ; 84BB
        bit     $3037                           ; 84BD
        adc     $3037,y                         ; 84C0
        adc     $3037,y                         ; 84C3
        ror     L7FFA,x                         ; 84C6
        inc     $373E,x                         ; 84C9
        adc     $FF2C,y                         ; 84CC
        adc     $C52C,x                         ; 84CF
L84D2:  bit     $2C9F                           ; 84D2
        and     $4244,y                         ; 84D5
        .byte   $43                             ; 84D8
        .byte   $FA                             ; 84D9
        lsr     $37                             ; 84DA
L84DC:  bmi     L8521                           ; 84DC
        bit     $3830                           ; 84DE
        eor     ($3E,x)                         ; 84E1
        .byte   $42                             ; 84E3
        .byte   $32                             ; 84E4
        txs                                     ; 84E5
        bit     $3E43                           ; 84E6
        .byte   $3B                             ; 84E9
        .byte   $33                             ; 84EA
        bit     $4FAC                           ; 84EB
        .byte   $FA                             ; 84EE
        .byte   $B3                             ; 84EF
        bit     $343B                           ; 84F0
        .byte   $43                             ; 84F3
        bit     $2CAC                           ; 84F4
        ldy     $2C                             ; 84F7
        .byte   $D2                             ; 84F9
        .byte   $4F                             ; 84FA
        .byte   $FA                             ; 84FB
        .byte   $7F                             ; 84FC
        sec                                     ; 84FD
        jmp     L3B3B                           ; 84FE

; ----------------------------------------------------------------------------
        bit     $3B9A                           ; 8501
        .byte   $3F                             ; 8504
        bit     $2CD2                           ; 8505
        dec     $3C2C                           ; 8508
        pha                                     ; 850B
        .byte   $FA                             ; 850C
        lsr     $37                             ; 850D
        .byte   $9F                             ; 850F
        .byte   $43                             ; 8510
        .byte   $3B                             ; 8511
        .byte   $34                             ; 8512
        .byte   $4F                             ; 8513
        bit     $4338                           ; 8514
        bit     $3032                           ; 8517
        and     $332C,x                         ; 851A
        .byte   $9F                             ; 851D
        .byte   $32                             ; 851E
        .byte   $3B                             ; 851F
        .byte   $3E                             ; 8520
L8521:  .byte   $42                             ; 8521
        .byte   $34                             ; 8522
        .byte   $FA                             ; 8523
        .byte   $32                             ; 8524
        .byte   $44                             ; 8525
        eor     ($3B,x)                         ; 8526
        pha                                     ; 8528
        jmp     L2C42                           ; 8529

; ----------------------------------------------------------------------------
L852C:  .byte   $43                             ; 852C
        eor     ($44,x)                         ; 852D
        .byte   $34                             ; 852F
        bit     $3E32                           ; 8530
        .byte   $3B                             ; 8533
        rol     $4241,x                         ; 8534
        .byte   $4F                             ; 8537
        .byte   $FA                             ; 8538
        .byte   $7F                             ; 8539
        inc     $2C9E,x                         ; 853A
        bmi     L856B                           ; 853D
        and     $4634,x                         ; 853F
        .byte   $7B                             ; 8542
        and     ($3E),y                         ; 8543
        eor     ($3D,x)                         ; 8545
        bit     $FA8A                           ; 8547
        .byte   $43                             ; 854A
        eor     ($34,x)                         ; 854B
        .byte   $34                             ; 854D
        .byte   $4F                             ; 854E
        bit     $2C38                           ; 854F
        .byte   $8F                             ; 8552
        bit     $3037                           ; 8553
        eor     $34                             ; 8556
        bit     $3D30                           ; 8558
        pha                                     ; 855B
        .byte   $FA                             ; 855C
        .byte   $3F                             ; 855D
        rol     $3446,x                         ; 855E
        eor     ($2C,x)                         ; 8561
        and     $463E,x                         ; 8563
        .byte   $4F                             ; 8566
        .byte   $FA                             ; 8567
        .byte   $7F                             ; 8568
        and     ($44),y                         ; 8569
L856B:  .byte   $43                             ; 856B
        bit     $2C38                           ; 856C
        .byte   $3F                             ; 856F
        eor     ($3E,x)                         ; 8570
        .byte   $3C                             ; 8572
        .byte   $9F                             ; 8573
        .byte   $34                             ; 8574
        bit     $3E43                           ; 8575
        bit     $FA95                           ; 8578
        .byte   $D2                             ; 857B
        adc     $C42C,y                         ; 857C
        bit     $79B8                           ; 857F
        .byte   $FA                             ; 8582
        .byte   $3C                             ; 8583
L8584:  pha                                     ; 8584
        bit     $3835                           ; 8585
        eor     ($42,x)                         ; 8588
        .byte   $43                             ; 858A
        bit     $3E31                           ; 858B
        eor     ($3D,x)                         ; 858E
        bit     $FAB9                           ; 8590
        .byte   $03                             ; 8593
        brk                                     ; 8594
        bit     $2CD3                           ; 8595
        .byte   $3B                             ; 8598
        bmi     L85DE                           ; 8599
        .byte   $34                             ; 859B
        eor     ($4F,x)                         ; 859C
        .byte   $FA                             ; 859E
        .byte   $7F                             ; 859F
        .byte   $9B                             ; 85A0
        jmp     L2C42                           ; 85A1

; ----------------------------------------------------------------------------
        cpy     $2C                             ; 85A4
        .byte   $B2                             ; 85A6
        .byte   $FA                             ; 85A7
        .byte   $32                             ; 85A8
        .byte   $37                             ; 85A9
        rol     $3E32,x                         ; 85AA
        .byte   $3B                             ; 85AD
        bmi     L85FF                           ; 85AE
        .byte   $FA                             ; 85B0
        .byte   $B3                             ; 85B1
        bit     $3E33                           ; 85B2
        bit     $3E3D                           ; 85B5
        .byte   $43                             ; 85B8
        bit     $3E35                           ; 85B9
        eor     ($36,x)                         ; 85BC
        .byte   $34                             ; 85BE
        .byte   $43                             ; 85BF
        bit     $4FC5                           ; 85C0
        .byte   $FA                             ; 85C3
        inc     $489A,x                         ; 85C4
        adc     L9E2C,y                         ; 85C7
        bit     $4436                           ; 85CA
        and     ($38),y                         ; 85CD
        and     ($38),y                         ; 85CF
        .byte   $4F                             ; 85D1
        bit     $FAD2                           ; 85D2
        .byte   $32                             ; 85D5
        bmi     L8584                           ; 85D6
        bit     $2C9B                           ; 85D8
        .byte   $43                             ; 85DB
        .byte   $3E                             ; 85DC
        .byte   $2C                             ; 85DD
L85DE:  txs                                     ; 85DE
        .byte   $3B                             ; 85DF
        .byte   $3F                             ; 85E0
        bit     $79AC                           ; 85E1
        .byte   $FA                             ; 85E4
        .byte   $33                             ; 85E5
        sec                                     ; 85E6
        .byte   $33                             ; 85E7
        and     $434C,x                         ; 85E8
        bit     $7CD2                           ; 85EB
        bit     $2CCA                           ; 85EE
        .byte   $D2                             ; 85F1
        adc     L7FFA,x                         ; 85F2
        sec                                     ; 85F5
        bit     $309A                           ; 85F6
        eor     ($33,x)                         ; 85F9
        bit     $2CD2                           ; 85FB
        .byte   $46                             ; 85FE
L85FF:  .byte   $34                             ; 85FF
        eor     ($34,x)                         ; 8600
        bit     $A397                           ; 8602
        .byte   $FA                             ; 8605
        .byte   $43                             ; 8606
        rol     $332C,x                         ; 8607
        .byte   $34                             ; 860A
        and     $34,x                           ; 860B
        bmi     L8652                           ; 860D
        bit     $4FBA                           ; 860F
        .byte   $FA                             ; 8612
        .byte   $3B                             ; 8613
        .byte   $34                             ; 8614
        .byte   $43                             ; 8615
        bit     $2CAC                           ; 8616
        ldy     $2C                             ; 8619
        .byte   $D2                             ; 861B
        adc     $382C,x                         ; 861C
        jmp     L3B3B                           ; 861F

; ----------------------------------------------------------------------------
        .byte   $FA                             ; 8622
        sta     $2C,x                           ; 8623
        .byte   $D2                             ; 8625
        bit     $2CC5                           ; 8626
        .byte   $37                             ; 8629
        rol     $483B,x                         ; 862A
        bit     $3E41                           ; 862D
        and     ($34),y                         ; 8630
        .byte   $4F                             ; 8632
        .byte   $FA                             ; 8633
        .byte   $7F                             ; 8634
        .byte   $AB                             ; 8635
        bit     $7997                           ; 8636
        .byte   $FF                             ; 8639
        adc     L7FFA,x                         ; 863A
        inc     L9B43,x                         ; 863D
        bit     $3046                           ; 8640
        .byte   $42                             ; 8643
        bit     $2C30                           ; 8644
        .byte   $42                             ; 8647
        lsr     $3E                             ; 8648
        eor     ($33,x)                         ; 864A
        bit     $3841                           ; 864C
        rol     $37,x                           ; 864F
        .byte   $43                             ; 8651
L8652:  .byte   $FA                             ; 8652
        sec                                     ; 8653
        and     $352C,x                         ; 8654
        eor     ($3E,x)                         ; 8657
        and     $2C43,x                         ; 8659
        rol     $2C35,x                         ; 865C
        .byte   $FF                             ; 865F
        jmp     L2C42                           ; 8660

; ----------------------------------------------------------------------------
        .byte   $34                             ; 8663
        pha                                     ; 8664
        .byte   $34                             ; 8665
        .byte   $42                             ; 8666
        .byte   $4F                             ; 8667
        .byte   $FA                             ; 8668
        .byte   $FF                             ; 8669
        bit     $3B9A                           ; 866A
        .byte   $33                             ; 866D
        bit     $4338                           ; 866E
        adc     $C42C,y                         ; 8671
        and     $382C,x                         ; 8674
        .byte   $43                             ; 8677
        .byte   $FA                             ; 8678
        eor     ($3E,x)                         ; 8679
        sta     ($33,x)                         ; 867B
        .byte   $4F                             ; 867D
        .byte   $FA                             ; 867E
        .byte   $7F                             ; 867F
        cmp     $2C                             ; 8680
        .byte   $9F                             ; 8682
        bit     $2CC4                           ; 8683
        txs                                     ; 8686
        eor     ($3E,x)                         ; 8687
        .byte   $FA                             ; 8689
        eor     ($3E,x)                         ; 868A
        .byte   $42                             ; 868C
        .byte   $43                             ; 868D
        bmi     L86CC                           ; 868E
        jmp     L2C42                           ; 8690

; ----------------------------------------------------------------------------
        .byte   $42                             ; 8693
        lsr     $3E                             ; 8694
        eor     ($33,x)                         ; 8696
        adc     LFEFA,x                         ; 8698
        sec                                     ; 869B
        bit     $3C30                           ; 869C
        bit     $2CC4                           ; 869F
        .byte   $3A                             ; 86A2
        .byte   $A3                             ; 86A3
        bit     $3435                           ; 86A4
        .byte   $9F                             ; 86A7
        bmi     L86E5                           ; 86A8
        .byte   $4F                             ; 86AA
        .byte   $FA                             ; 86AB
        .byte   $7F                             ; 86AC
        .byte   $FF                             ; 86AD
        adc     $372C,y                         ; 86AE
        rol     $2C46,x                         ; 86B1
        .byte   $32                             ; 86B4
        bmi     L86F4                           ; 86B5
        bit     $2C38                           ; 86B7
        dex                                     ; 86BA
        .byte   $FA                             ; 86BB
        .byte   $D2                             ; 86BC
        .byte   $4F                             ; 86BD
        bit     $2CA1                           ; 86BE
        and     ($34),y                         ; 86C1
        .byte   $34                             ; 86C3
        and     $3B2C,x                         ; 86C4
        rol     $3A32,x                         ; 86C7
        .byte   $34                             ; 86CA
        .byte   $33                             ; 86CB
L86CC:  bit     $3F44                           ; 86CC
        .byte   $FA                             ; 86CF
        and     ($48),y                         ; 86D0
        bit     $FABA                           ; 86D2
        sec                                     ; 86D5
        and     $422C,x                         ; 86D6
        .byte   $44                             ; 86D9
        .byte   $32                             ; 86DA
        .byte   $37                             ; 86DB
        bit     $2C30                           ; 86DC
        .byte   $3F                             ; 86DF
        .byte   $3B                             ; 86E0
        bmi     L8715                           ; 86E1
        .byte   $34                             ; 86E3
        .byte   $4F                             ; 86E4
L86E5:  .byte   $FA                             ; 86E5
        .byte   $7F                             ; 86E6
        .byte   $AB                             ; 86E7
        bit     $2C97                           ; 86E8
        and     ($30),y                         ; 86EB
        .byte   $32                             ; 86ED
        .byte   $3A                             ; 86EE
        bit     $3E43                           ; 86EF
        .byte   $2C                             ; 86F2
        .byte   $C4                             ; 86F3
L86F4:  .byte   $FA                             ; 86F4
        .byte   $3F                             ; 86F5
        eor     ($34,x)                         ; 86F6
        .byte   $42                             ; 86F8
        .byte   $34                             ; 86F9
        and     $2C43,x                         ; 86FA
        cmp     #$4F                            ; 86FD
        .byte   $FA                             ; 86FF
        .byte   $7F                             ; 8700
        .byte   $D2                             ; 8701
        eor     ($2C,x)                         ; 8702
        .byte   $BF                             ; 8704
        bit     $FAC4                           ; 8705
        ldy     $2C,x                           ; 8708
        ldy     $3CFA,x                         ; 870A
        .byte   $44                             ; 870D
        .byte   $42                             ; 870E
        .byte   $43                             ; 870F
        bit     $3431                           ; 8710
        .byte   $2C                             ; 8713
        .byte   $CE                             ; 8714
L8715:  bit     $4FBA                           ; 8715
        .byte   $FA                             ; 8718
        .byte   $7F                             ; 8719
        cmp     $2C                             ; 871A
        cmp     $312C                           ; 871C
        .byte   $34                             ; 871F
        bit     $2CC4                           ; 8720
        .byte   $3B                             ; 8723
        bmi     L8768                           ; 8724
        .byte   $43                             ; 8726
        .byte   $FA                             ; 8727
        and     ($30),y                         ; 8728
        .byte   $43                             ; 872A
        .byte   $43                             ; 872B
        .byte   $3B                             ; 872C
        .byte   $34                             ; 872D
        .byte   $4F                             ; 872E
        .byte   $FA                             ; 872F
        .byte   $7F                             ; 8730
        inc     $2C9E,x                         ; 8731
        .byte   $37                             ; 8734
        bmi     L8779                           ; 8735
        .byte   $42                             ; 8737
        bmi     L8777                           ; 8738
        .byte   $4F                             ; 873A
        bit     $2C38                           ; 873B
        bmi     L877C                           ; 873E
        bit     $3035                           ; 8740
        .byte   $43                             ; 8743
        .byte   $34                             ; 8744
        .byte   $33                             ; 8745
        .byte   $FA                             ; 8746
        .byte   $43                             ; 8747
        rol     $422C,x                         ; 8748
        .byte   $34                             ; 874B
        .byte   $34                             ; 874C
        bit     $2CD2                           ; 874D
        bmi     L8795                           ; 8750
        bit     $2CC5                           ; 8752
        cmp     #$FA                            ; 8755
        bmi     L879B                           ; 8757
        bit     $2C30                           ; 8759
        .byte   $42                             ; 875C
        .byte   $34                             ; 875D
        eor     ($45,x)                         ; 875E
        bmi     L879F                           ; 8760
        .byte   $43                             ; 8762
        bit     $353E                           ; 8763
        .byte   $2C                             ; 8766
        .byte   $A2                             ; 8767
L8768:  .byte   $4F                             ; 8768
        .byte   $FA                             ; 8769
        .byte   $7F                             ; 876A
        bmi     L8799                           ; 876B
        .byte   $D4                             ; 876D
        bit     $2CAD                           ; 876E
        .byte   $3A                             ; 8771
        bmi     L87AD                           ; 8772
        sec                                     ; 8774
        .byte   $2C                             ; 8775
        .byte   $9F                             ; 8776
L8777:  .byte   $2C                             ; 8777
        .byte   $42                             ; 8778
L8779:  .byte   $44                             ; 8779
        .byte   $3F                             ; 877A
        .byte   $7B                             ; 877B
L877C:  .byte   $FA                             ; 877C
        .byte   $3F                             ; 877D
        rol     $3442,x                         ; 877E
        .byte   $33                             ; 8781
        bit     $3E43                           ; 8782
        bit     $3431                           ; 8785
        bit     $4436                           ; 8788
        bmi     L87CE                           ; 878B
        .byte   $33                             ; 878D
        .byte   $A3                             ; 878E
        bit     $FAC4                           ; 878F
        stx     $2C                             ; 8792
        .byte   $3E                             ; 8794
L8795:  and     $2C,x                           ; 8795
        lda     #$79                            ; 8797
L8799:  .byte   $2C                             ; 8799
        .byte   $A2                             ; 879A
L879B:  jmp     LFA42                           ; 879B

; ----------------------------------------------------------------------------
        sec                                     ; 879E
L879F:  and     $419A,x                         ; 879F
        sec                                     ; 87A2
        .byte   $43                             ; 87A3
        bmi     L87E3                           ; 87A4
        .byte   $32                             ; 87A6
        .byte   $34                             ; 87A7
        bit     $3D38                           ; 87A8
        .byte   $2C                             ; 87AB
        .byte   $3F                             ; 87AC
L87AD:  bmi     L87ED                           ; 87AD
        .byte   $4F                             ; 87AF
        .byte   $FA                             ; 87B0
        .byte   $7F                             ; 87B1
        and     $463E,x                         ; 87B2
        bit     $2CAB                           ; 87B5
        .byte   $97                             ; 87B8
        adc     L7FFA,x                         ; 87B9
        inc     $373E,x                         ; 87BC
        adc     $FF2C,x                         ; 87BF
        .byte   $4F                             ; 87C2
        bit     $2CD2                           ; 87C3
        sta     ($2C,x)                         ; 87C6
        cpy     $FA                             ; 87C8
        eor     ($38,x)                         ; 87CA
        rol     $37,x                           ; 87CC
L87CE:  .byte   $43                             ; 87CE
        bit     $389A                           ; 87CF
        eor     ($2C,x)                         ; 87D2
        rol     $2C35,x                         ; 87D4
        ldx     #$7D                            ; 87D7
        .byte   $FA                             ; 87D9
        .byte   $7F                             ; 87DA
        .byte   $97                             ; 87DB
        bit     $3E43                           ; 87DC
        bit     $2CC4                           ; 87DF
        .byte   $42                             ; 87E2
L87E3:  .byte   $34                             ; 87E3
        bmi     L8812                           ; 87E4
        and     $41,x                           ; 87E6
        rol     $FA3C,x                         ; 87E8
        and     ($34),y                         ; 87EB
L87ED:  .byte   $43                             ; 87ED
        lsr     $34                             ; 87EE
        .byte   $34                             ; 87F0
        and     $C42C,x                         ; 87F1
        bit     $4143                           ; 87F4
        .byte   $34                             ; 87F7
        .byte   $34                             ; 87F8
        .byte   $42                             ; 87F9
        bit     $3E43                           ; 87FA
        .byte   $FA                             ; 87FD
        cpy     $2C                             ; 87FE
        .byte   $42                             ; 8800
        rol     $4344,x                         ; 8801
        .byte   $37                             ; 8804
        bit     $353E                           ; 8805
        bit     $2CC5                           ; 8808
        .byte   $CB                             ; 880B
        adc     L7FFA,y                         ; 880C
        cpy     $3D                             ; 880F
        .byte   $2C                             ; 8811
L8812:  rol     $34,x                           ; 8812
        .byte   $43                             ; 8814
        bit     $2CC4                           ; 8815
        stx     $2C                             ; 8818
        rol     $FA35,x                         ; 881A
        lda     #$2C                            ; 881D
        .byte   $82                             ; 881F
        bit     $2C97                           ; 8820
        .byte   $43                             ; 8823
        rol     $BAFA,x                         ; 8824
        jmp     L2C42                           ; 8827

; ----------------------------------------------------------------------------
        bcs     L887B                           ; 882A
        .byte   $FA                             ; 882C
        inc     $2C30,x                         ; 882D
        eor     $3E                             ; 8830
        sec                                     ; 8832
        .byte   $32                             ; 8833
        .byte   $34                             ; 8834
        bit     $2C9F                           ; 8835
        txs                                     ; 8838
        bmi     L887C                           ; 8839
        .byte   $33                             ; 883B
        bit     $4135                           ; 883C
        rol     $FA3C,x                         ; 883F
        .byte   $42                             ; 8842
        rol     $46AC,x                         ; 8843
        .byte   $9B                             ; 8846
        ror     $FA7E,x                         ; 8847
        .byte   $7F                             ; 884A
        .byte   $D4                             ; 884B
        bit     $7EAD                           ; 884C
        .byte   $FA                             ; 884F
        .byte   $D4                             ; 8850
        bit     $2CAD                           ; 8851
        .byte   $CF                             ; 8854
        bit     $3D38                           ; 8855
        txs                                     ; 8858
        eor     ($38,x)                         ; 8859
        .byte   $43                             ; 885B
        .byte   $42                             ; 885C
        .byte   $FA                             ; 885D
        .byte   $3C                             ; 885E
        pha                                     ; 885F
        bit     $303D                           ; 8860
        ldy     $7E7E                           ; 8863
        .byte   $FA                             ; 8866
        .byte   $7F                             ; 8867
        inc     L9A46,x                         ; 8868
        and     $302C,x                         ; 886B
        bit     L9F3C                           ; 886E
        and     $3E,x                           ; 8871
        eor     ($43,x)                         ; 8873
        .byte   $44                             ; 8875
        and     $FA34,x                         ; 8876
        .byte   $3E                             ; 8879
        .byte   $32                             ; 887A
L887B:  .byte   $32                             ; 887B
L887C:  .byte   $44                             ; 887C
        eor     ($42,x)                         ; 887D
        adc     $3F2C,y                         ; 887F
        .byte   $44                             ; 8882
        .byte   $43                             ; 8883
        bit     $3D3E                           ; 8884
        bit     $2CC4                           ; 8887
        stx     $FA                             ; 888A
        rol     $2C35,x                         ; 888C
        lda     #$2C                            ; 888F
        .byte   $82                             ; 8891
        bit     $3835                           ; 8892
        rol     $37,x                           ; 8895
        .byte   $43                             ; 8897
        bit     $FACE                           ; 8898
        ldx     #$4C                            ; 889B
        .byte   $42                             ; 889D
        bit     $3E41                           ; 889E
        .byte   $33                             ; 88A1
        .byte   $4F                             ; 88A2
        .byte   $FA                             ; 88A3
        .byte   $7F                             ; 88A4
        .byte   $D2                             ; 88A5
        jmp     L3445                           ; 88A6

; ----------------------------------------------------------------------------
        bit     $3431                           ; 88A9
        .byte   $32                             ; 88AC
        rol     $2CAC,x                         ; 88AD
        bmi     L88F4                           ; 88B0
        bit     $4342                           ; 88B2
        eor     ($3E,x)                         ; 88B5
        and     $FA36,x                         ; 88B7
        bmi     L88FE                           ; 88BA
        bit     $4FAC                           ; 88BC
        .byte   $FA                             ; 88BF
        .byte   $D2                             ; 88C0
        bit     $2C81                           ; 88C1
        cpy     $2C                             ; 88C4
        and     $4634,x                         ; 88C6
        bit     $FAA2                           ; 88C9
        and     $463E,x                         ; 88CC
        adc     L7FFA,x                         ; 88CF
        and     ($41),y                         ; 88D2
        .byte   $A3                             ; 88D4
        bit     $343F                           ; 88D5
        bmi     L890C                           ; 88D8
        .byte   $34                             ; 88DA
        bit     $3031                           ; 88DB
        .byte   $32                             ; 88DE
        .byte   $3A                             ; 88DF
        bit     $3E43                           ; 88E0
        .byte   $FA                             ; 88E3
        cpy     $2C                             ; 88E4
        sta     $CC2C,x                         ; 88E6
        .byte   $4F                             ; 88E9
        .byte   $FA                             ; 88EA
        .byte   $7F                             ; 88EB
        .byte   $43                             ; 88EC
        bmi     L8929                           ; 88ED
        .byte   $34                             ; 88EF
        bit     $2CC5                           ; 88F0
        .byte   $42                             ; 88F3
L88F4:  lsr     $3E                             ; 88F4
        eor     ($33,x)                         ; 88F6
        adc     L7FFA,x                         ; 88F8
        inc     $2CD4,x                         ; 88FB
L88FE:  lda     $CF2C                           ; 88FE
        bit     $3D38                           ; 8901
        txs                                     ; 8904
        eor     ($38,x)                         ; 8905
        .byte   $43                             ; 8907
        .byte   $42                             ; 8908
        .byte   $FA                             ; 8909
        .byte   $3C                             ; 890A
        pha                                     ; 890B
L890C:  bit     $303D                           ; 890C
        ldy     $2C79                           ; 890F
        eor     ($34,x)                         ; 8912
        ldy     $313C                           ; 8914
        .byte   $34                             ; 8917
        eor     ($2C,x)                         ; 8918
        cpy     $42                             ; 891A
        .byte   $34                             ; 891C
        .byte   $FA                             ; 891D
        lsr     $3E                             ; 891E
        eor     ($33,x)                         ; 8920
        .byte   $42                             ; 8922
        adc     $4D2C,y                         ; 8923
        .byte   $3B                             ; 8926
        .byte   $9F                             ; 8927
        .byte   $43                             ; 8928
L8929:  .byte   $34                             ; 8929
        and     $432C,x                         ; 892A
        rol     $C42C,x                         ; 892D
        .byte   $FA                             ; 8930
        .byte   $3F                             ; 8931
        sec                                     ; 8932
        .byte   $3B                             ; 8933
        .byte   $3B                             ; 8934
        bmi     L8978                           ; 8935
        jmp     L2C42                           ; 8937

; ----------------------------------------------------------------------------
        eor     $3E                             ; 893A
        sec                                     ; 893C
        .byte   $32                             ; 893D
        .byte   $34                             ; 893E
        .byte   $4F                             ; 893F
        jmp     L7FFA                           ; 8940

; ----------------------------------------------------------------------------
        and     $463E,x                         ; 8943
        adc     $3A2C,y                         ; 8946
        .byte   $34                             ; 8949
        .byte   $34                             ; 894A
        .byte   $3F                             ; 894B
        bit     $A397                           ; 894C
        adc     $FF2C,y                         ; 894F
        adc     LFEFA,x                         ; 8952
        .byte   $97                             ; 8955
        .byte   $A3                             ; 8956
        bit     $3E33                           ; 8957
        lsr     $3D                             ; 895A
        bit     $2CC4                           ; 895C
        .byte   $42                             ; 895F
        .byte   $43                             ; 8960
        bmi     L899B                           ; 8961
        eor     ($42,x)                         ; 8963
        ror     $FA7E,x                         ; 8965
        .byte   $43                             ; 8968
        .byte   $9B                             ; 8969
        bit     $3046                           ; 896A
        .byte   $42                             ; 896D
        bit     $2CC4                           ; 896E
        stx     $2C                             ; 8971
        rol     $FA35,x                         ; 8973
        lda     #$4F                            ; 8976
L8978:  .byte   $FF                             ; 8978
        bit     $443F                           ; 8979
        .byte   $43                             ; 897C
        bit     $4338                           ; 897D
        bit     $3D3E                           ; 8980
        .byte   $4F                             ; 8983
        .byte   $FA                             ; 8984
        .byte   $7F                             ; 8985
        .byte   $9B                             ; 8986
        jmp     L2C42                           ; 8987

; ----------------------------------------------------------------------------
        .byte   $42                             ; 898A
        rol     $43AC,x                         ; 898B
        .byte   $37                             ; 898E
        .byte   $A3                             ; 898F
        bit     $4146                           ; 8990
        sec                                     ; 8993
        .byte   $43                             ; 8994
        .byte   $43                             ; 8995
        .byte   $34                             ; 8996
        and     $3EFA,x                         ; 8997
        .byte   $3D                             ; 899A
L899B:  bit     $2CC4                           ; 899B
        and     ($30),y                         ; 899E
        .byte   $42                             ; 89A0
        .byte   $34                             ; 89A1
        bit     $353E                           ; 89A2
        bit     $FAC4                           ; 89A5
        .byte   $32                             ; 89A8
        rol     $443B,x                         ; 89A9
        .byte   $3C                             ; 89AC
        and     $FA4F,x                         ; 89AD
        .byte   $7F                             ; 89B0
        eor     $2C38                           ; 89B1
        bmi     L89F2                           ; 89B4
        bit     $2CC4                           ; 89B6
        .byte   $3F                             ; 89B9
        sec                                     ; 89BA
        .byte   $3B                             ; 89BB
        .byte   $3B                             ; 89BC
        bmi     L8A00                           ; 89BD
        bit     $FACF                           ; 89BF
        .byte   $42                             ; 89C2
        .byte   $34                             ; 89C3
        .byte   $3F                             ; 89C4
        bmi     L8A08                           ; 89C5
        bmi     L8A0C                           ; 89C7
        .byte   $34                             ; 89C9
        .byte   $42                             ; 89CA
        bit     $2C82                           ; 89CB
        .byte   $42                             ; 89CE
        .byte   $44                             ; 89CF
        .byte   $3F                             ; 89D0
        .byte   $3F                             ; 89D1
        rol     $4341,x                         ; 89D2
        .byte   $42                             ; 89D5
        .byte   $FA                             ; 89D6
        cpy     $2C                             ; 89D7
        sta     $CC2C,x                         ; 89D9
        bit     $FA82                           ; 89DC
        cpy     $2C                             ; 89DF
        .byte   $33                             ; 89E1
        bmi     L8A25                           ; 89E2
        .byte   $3A                             ; 89E4
        bit     $4FCC                           ; 89E5
        jmp     L7FFA                           ; 89E8

; ----------------------------------------------------------------------------
        eor     $343B                           ; 89EB
        .byte   $43                             ; 89EE
        .byte   $2C                             ; 89EF
        .byte   $C4                             ; 89F0
L89F1:  .byte   $2C                             ; 89F1
L89F2:  ldx     $3038                           ; 89F2
        and     $43FA,x                         ; 89F5
        eor     ($30,x)                         ; 89F8
        eor     $34                             ; 89FA
        .byte   $3B                             ; 89FC
        .byte   $A3                             ; 89FD
        .byte   $2C                             ; 89FE
        .byte   $3E                             ; 89FF
L8A00:  eor     $34                             ; 8A00
        eor     ($2C,x)                         ; 8A02
        cpy     $2C                             ; 8A04
        cmp     #$79                            ; 8A06
L8A08:  .byte   $FA                             ; 8A08
        .byte   $43                             ; 8A09
        bmi     L8A46                           ; 8A0A
L8A0C:  .byte   $34                             ; 8A0C
        bit     $2C30                           ; 8A0D
        eor     ($3E,x)                         ; 8A10
        .byte   $33                             ; 8A12
        bit     $FA82                           ; 8A13
        .byte   $C3                             ; 8A16
        bit     $4FAC                           ; 8A17
        jmp     L7FFA                           ; 8A1A

; ----------------------------------------------------------------------------
        eor     $4342                           ; 8A1D
        .byte   $82                             ; 8A20
        bit     $3D3E                           ; 8A21
        .byte   $2C                             ; 8A24
L8A25:  cpy     $2C                             ; 8A25
        eor     ($34,x)                         ; 8A27
        .byte   $33                             ; 8A29
        bit     $3E3C                           ; 8A2A
        rol     $FA3D,x                         ; 8A2D
        .byte   $82                             ; 8A30
        bit     $2CC3                           ; 8A31
        ldy     $2C4F                           ; 8A34
        .byte   $42                             ; 8A37
        .byte   $43                             ; 8A38
        .byte   $82                             ; 8A39
        bit     $3D3E                           ; 8A3A
        .byte   $FA                             ; 8A3D
        cpy     $2C                             ; 8A3E
        lsr     $37                             ; 8A40
        sec                                     ; 8A42
        .byte   $43                             ; 8A43
        .byte   $34                             ; 8A44
        .byte   $2C                             ; 8A45
L8A46:  .byte   $42                             ; 8A46
        .byte   $44                             ; 8A47
        and     L822C,x                         ; 8A48
        bit     $FAC3                           ; 8A4B
        ldy     $4C4F                           ; 8A4E
        .byte   $FA                             ; 8A51
        .byte   $7F                             ; 8A52
        eor     $2CC3                           ; 8A53
        ldy     $462C                           ; 8A56
        txs                                     ; 8A59
        and     $302C,x                         ; 8A5A
        sec                                     ; 8A5D
        eor     ($3E,x)                         ; 8A5E
        .byte   $42                             ; 8A60
        .byte   $32                             ; 8A61
        .byte   $37                             ; 8A62
        .byte   $34                             ; 8A63
        .byte   $FA                             ; 8A64
        .byte   $3C                             ; 8A65
        bmi     L8AA2                           ; 8A66
        .byte   $34                             ; 8A68
        .byte   $42                             ; 8A69
        bit     $2CC4                           ; 8A6A
        .byte   $42                             ; 8A6D
        .byte   $43                             ; 8A6E
        bmi     L8AB2                           ; 8A6F
        bit     $3742                           ; 8A71
        sec                                     ; 8A74
        and     $FA34,x                         ; 8A75
        dey                                     ; 8A78
        .byte   $4F                             ; 8A79
        jmp     LFEFA                           ; 8A7A

; ----------------------------------------------------------------------------
        .byte   $9E                             ; 8A7D
        bit     $4FBA                           ; 8A7E
        .byte   $FA                             ; 8A81
        sec                                     ; 8A82
        .byte   $43                             ; 8A83
        jmp     L2C42                           ; 8A84

; ----------------------------------------------------------------------------
        and     ($34),y                         ; 8A87
        .byte   $34                             ; 8A89
        and     $302C,x                         ; 8A8A
        bit     $3E3B                           ; 8A8D
        and     $2C36,x                         ; 8A90
        cmp     #$79                            ; 8A93
        .byte   $FA                             ; 8A95
        .byte   $FF                             ; 8A96
        .byte   $4F                             ; 8A97
        .byte   $FA                             ; 8A98
        .byte   $7F                             ; 8A99
        lda     ($7E,x)                         ; 8A9A
        ror     L7FFA,x                         ; 8A9C
        lda     ($2C,x)                         ; 8A9F
        .byte   $3C                             ; 8AA1
L8AA2:  bmi     L8AD7                           ; 8AA2
        .byte   $34                             ; 8AA4
        bit     $2C30                           ; 8AA5
        .byte   $43                             ; 8AA8
        .byte   $34                             ; 8AA9
        eor     ($41,x)                         ; 8AAA
        sec                                     ; 8AAC
        and     ($3B),y                         ; 8AAD
        .byte   $34                             ; 8AAF
        .byte   $FA                             ; 8AB0
        .byte   $3C                             ; 8AB1
L8AB2:  .byte   $9F                             ; 8AB2
        .byte   $43                             ; 8AB3
        bmi     L8AF0                           ; 8AB4
        .byte   $34                             ; 8AB6
        .byte   $4F                             ; 8AB7
        bit     $2C38                           ; 8AB8
        .byte   $42                             ; 8ABB
        .byte   $34                             ; 8ABC
        .byte   $43                             ; 8ABD
        bit     $3E3B                           ; 8ABE
        rol     $3442,x                         ; 8AC1
        bit     $FAC4                           ; 8AC4
        sta     $D62C,y                         ; 8AC7
        bit     L9898                           ; 8ACA
        adc     $C4FA,y                         ; 8ACD
        bit     $443F                           ; 8AD0
        eor     ($34,x)                         ; 8AD3
        .byte   $2C                             ; 8AD5
        .byte   $34                             ; 8AD6
L8AD7:  eor     $38                             ; 8AD7
        .byte   $3B                             ; 8AD9
        adc     L7FFA,y                         ; 8ADA
        and     $3E,x                           ; 8ADD
        eor     ($2C,x)                         ; 8ADF
        .byte   $3C                             ; 8AE1
        pha                                     ; 8AE2
        bit     $3442                           ; 8AE3
        .byte   $3B                             ; 8AE6
        and     $9F,x                           ; 8AE7
        .byte   $37                             ; 8AE9
        bit     $3433                           ; 8AEA
        .byte   $42                             ; 8AED
        sec                                     ; 8AEE
        .byte   $41                             ; 8AEF
L8AF0:  .byte   $34                             ; 8AF0
        .byte   $4F                             ; 8AF1
        .byte   $FA                             ; 8AF2
        and     ($44),y                         ; 8AF3
        .byte   $43                             ; 8AF5
        bit     $2C38                           ; 8AF6
        .byte   $33                             ; 8AF9
        sec                                     ; 8AFA
        .byte   $33                             ; 8AFB
        and     $434C,x                         ; 8AFC
        bit     $3037                           ; 8AFF
        eor     $34                             ; 8B02
        bit     $FAC4                           ; 8B04
        .byte   $3F                             ; 8B07
        rol     $3446,x                         ; 8B08
        eor     ($2C,x)                         ; 8B0B
        .byte   $43                             ; 8B0D
        rol     $432C,x                         ; 8B0E
        bmi     L8B4D                           ; 8B11
        .byte   $34                             ; 8B13
        bit     $2C9C                           ; 8B14
        rol     $4F3D,x                         ; 8B17
        .byte   $FA                             ; 8B1A
        .byte   $7F                             ; 8B1B
        and     $463E,x                         ; 8B1C
        bit     $2CC4                           ; 8B1F
        .byte   $CF                             ; 8B22
        .byte   $3B                             ; 8B23
        .byte   $34                             ; 8B24
        bit     $2CCC                           ; 8B25
        cmp     $31FA                           ; 8B28
        .byte   $34                             ; 8B2B
        bit     L9898                           ; 8B2C
        jmp     L2C42                           ; 8B2F

; ----------------------------------------------------------------------------
        .byte   $3F                             ; 8B32
        eor     ($34,x)                         ; 8B33
        pha                                     ; 8B35
        .byte   $4F                             ; 8B36
        .byte   $FA                             ; 8B37
        .byte   $7F                             ; 8B38
        .byte   $FF                             ; 8B39
        adc     $B32C,x                         ; 8B3A
        adc     $B32C,x                         ; 8B3D
        .byte   $FA                             ; 8B40
        .byte   $33                             ; 8B41
        .byte   $34                             ; 8B42
        .byte   $42                             ; 8B43
        .byte   $43                             ; 8B44
        eor     ($3E,x)                         ; 8B45
        pha                                     ; 8B47
        bit     L9898                           ; 8B48
        .byte   $7D                             ; 8B4B
        .byte   $FA                             ; 8B4C
L8B4D:  bmi     L8B91                           ; 8B4D
        bit     $2C30                           ; 8B4F
        eor     ($34,x)                         ; 8B52
        lsr     $30                             ; 8B54
        eor     ($33,x)                         ; 8B56
        bit     $4135                           ; 8B58
        rol     $2C3C,x                         ; 8B5B
        ldy     $FA79                           ; 8B5E
        .byte   $7F                             ; 8B61
        sec                                     ; 8B62
        jmp     L3B3B                           ; 8B63

; ----------------------------------------------------------------------------
        bit     $2C95                           ; 8B66
        .byte   $D2                             ; 8B69
        bit     $3031                           ; 8B6A
        .byte   $32                             ; 8B6D
        .byte   $3A                             ; 8B6E
        bit     $41D2                           ; 8B6F
        .byte   $FA                             ; 8B72
        .byte   $BF                             ; 8B73
        bit     $79BC                           ; 8B74
        .byte   $FA                             ; 8B77
        cpy     $2C                             ; 8B78
        ldy     $4F,x                           ; 8B7A
        .byte   $FA                             ; 8B7C
        .byte   $7F                             ; 8B7D
        and     ($44),y                         ; 8B7E
        .byte   $43                             ; 8B80
        bit     L9F3B                           ; 8B81
        .byte   $43                             ; 8B84
        .byte   $34                             ; 8B85
        and     $FF79,x                         ; 8B86
        .byte   $4F                             ; 8B89
        .byte   $FA                             ; 8B8A
        .byte   $7F                             ; 8B8B
        lsr     $9A                             ; 8B8C
        and     $382C,x                         ; 8B8E
L8B91:  bit     $3032                           ; 8B91
        .byte   $3F                             ; 8B94
        .byte   $43                             ; 8B95
        .byte   $44                             ; 8B96
        eor     ($34,x)                         ; 8B97
        .byte   $33                             ; 8B99
        bit     $FAC4                           ; 8B9A
        ldy     $79,x                           ; 8B9D
        bit     $2C38                           ; 8B9F
        .byte   $44                             ; 8BA2
        .byte   $42                             ; 8BA3
        .byte   $34                             ; 8BA4
        .byte   $33                             ; 8BA5
        bit     $FAAE                           ; 8BA6
        .byte   $82                             ; 8BA9
        bit     $3732                           ; 8BAA
        bmi     L8BEC                           ; 8BAD
        rol     $34,x                           ; 8BAF
        .byte   $33                             ; 8BB1
        bit     $419A                           ; 8BB2
        bit     $3835                           ; 8BB5
        rol     $44,x                           ; 8BB8
        eor     ($34,x)                         ; 8BBA
        .byte   $4F                             ; 8BBC
        .byte   $FA                             ; 8BBD
        .byte   $7F                             ; 8BBE
        and     ($44),y                         ; 8BBF
        .byte   $43                             ; 8BC1
        bit     $2CC2                           ; 8BC2
        eor     ($30,x)                         ; 8BC5
        and     $302C,x                         ; 8BC7
        lsr     $30                             ; 8BCA
        pha                                     ; 8BCC
        bit     $4135                           ; 8BCD
        rol     $2C3C,x                         ; 8BD0
        ldy     $35FA                           ; 8BD3
        rol     $2C41,x                         ; 8BD6
        txs                                     ; 8BD9
        eor     ($2C,x)                         ; 8BDA
        .byte   $33                             ; 8BDC
        .byte   $34                             ; 8BDD
        .byte   $34                             ; 8BDE
        .byte   $3F                             ; 8BDF
        bit     $3E3B                           ; 8BE0
        eor     $34                             ; 8BE3
        bit     $3E35                           ; 8BE5
        eor     ($FA,x)                         ; 8BE8
        .byte   $D2                             ; 8BEA
        .byte   $4F                             ; 8BEB
L8BEC:  .byte   $FA                             ; 8BEC
        .byte   $7F                             ; 8BED
        .byte   $C2                             ; 8BEE
        bit     $3E32                           ; 8BEF
        .byte   $44                             ; 8BF2
        .byte   $3B                             ; 8BF3
        .byte   $33                             ; 8BF4
        and     $434C,x                         ; 8BF5
        bit     $3338                           ; 8BF8
        .byte   $34                             ; 8BFB
        and     $3843,x                         ; 8BFC
        and     $48,x                           ; 8BFF
        .byte   $FA                             ; 8C01
        txs                                     ; 8C02
        eor     ($42,x)                         ; 8C03
        .byte   $34                             ; 8C05
        .byte   $3B                             ; 8C06
        and     $2C,x                           ; 8C07
        .byte   $34                             ; 8C09
        eor     $34                             ; 8C0A
        and     $382C,x                         ; 8C0C
        and     $2C,x                           ; 8C0F
        .byte   $C2                             ; 8C11
        .byte   $FA                             ; 8C12
        .byte   $32                             ; 8C13
        rol     $3B44,x                         ; 8C14
        .byte   $33                             ; 8C17
        bit     $34AC                           ; 8C18
        .byte   $43                             ; 8C1B
        bit     $79D2                           ; 8C1C
        bit     $3431                           ; 8C1F
        .byte   $32                             ; 8C22
        bmi     L8C69                           ; 8C23
        .byte   $42                             ; 8C25
        .byte   $34                             ; 8C26
        .byte   $FA                             ; 8C27
        rol     $323D,x                         ; 8C28
        .byte   $34                             ; 8C2B
        bit     $2CC2                           ; 8C2C
        .byte   $42                             ; 8C2F
        bmi     L8C6A                           ; 8C30
        .byte   $33                             ; 8C32
        bit     $419A                           ; 8C33
        bit     $303D                           ; 8C36
        ldy     $FA79                           ; 8C39
        .byte   $7F                             ; 8C3C
        txs                                     ; 8C3D
        eor     ($2C,x)                         ; 8C3E
        .byte   $42                             ; 8C40
        rol     $3B44,x                         ; 8C41
        bit     $2CD0                           ; 8C44
        and     ($34),y                         ; 8C47
        .byte   $FA                             ; 8C49
        .byte   $42                             ; 8C4A
        .byte   $37                             ; 8C4B
        bmi     L8C91                           ; 8C4C
        .byte   $43                             ; 8C4E
        .byte   $34                             ; 8C4F
        eor     ($34,x)                         ; 8C50
        .byte   $33                             ; 8C52
        bit     $4831                           ; 8C53
        bit     $2CC4                           ; 8C56
        ldx     $3FFA                           ; 8C59
        rol     $3446,x                         ; 8C5C
        eor     ($4F,x)                         ; 8C5F
        .byte   $FA                             ; 8C61
        .byte   $7F                             ; 8C62
        .byte   $C2                             ; 8C63
        jmp     L2C42                           ; 8C64

; ----------------------------------------------------------------------------
        bmi     L8CA4                           ; 8C67
L8C69:  .byte   $46                             ; 8C69
L8C6A:  bmi     L8CB4                           ; 8C6A
        .byte   $42                             ; 8C6C
        bit     $3431                           ; 8C6D
        .byte   $34                             ; 8C70
        and     $CE2C,x                         ; 8C71
        .byte   $FA                             ; 8C74
        .byte   $D2                             ; 8C75
        .byte   $4F                             ; 8C76
        bit     $3E33                           ; 8C77
        bit     $2CD2                           ; 8C7A
        .byte   $3A                             ; 8C7D
        and     $463E,x                         ; 8C7E
        bit     $2CCF                           ; 8C81
        .byte   $C2                             ; 8C84
        .byte   $FA                             ; 8C85
        .byte   $9F                             ; 8C86
        .byte   $7C                             ; 8C87
        bit     $3538                           ; 8C88
        bit     $41D2                           ; 8C8B
        bit     $3D30                           ; 8C8E
L8C91:  .byte   $42                             ; 8C91
        lsr     $34                             ; 8C92
        eor     ($2C,x)                         ; 8C94
        .byte   $9F                             ; 8C96
        .byte   $FA                             ; 8C97
        lsr     $41                             ; 8C98
        rol     $363D,x                         ; 8C9A
        adc     L7FFA,y                         ; 8C9D
        .byte   $43                             ; 8CA0
        .byte   $37                             ; 8CA1
        eor     ($34,x)                         ; 8CA2
L8CA4:  .byte   $34                             ; 8CA4
        bit     $353E                           ; 8CA5
        bit     $4244                           ; 8CA8
        bit     $2CCD                           ; 8CAB
        .byte   $33                             ; 8CAE
        sec                                     ; 8CAF
        .byte   $34                             ; 8CB0
        .byte   $4F                             ; 8CB1
        .byte   $FA                             ; 8CB2
        .byte   $3D                             ; 8CB3
L8CB4:  rol     $2C46,x                         ; 8CB4
        bmi     L8CF6                           ; 8CB7
        .byte   $42                             ; 8CB9
        lsr     $34                             ; 8CBA
        eor     ($2C,x)                         ; 8CBC
        ldy     L822C                           ; 8CBE
        .byte   $FA                             ; 8CC1
        and     ($41),y                         ; 8CC2
        .byte   $34                             ; 8CC4
        bmi     L8D01                           ; 8CC5
        bit     $2CC4                           ; 8CC7
        .byte   $42                             ; 8CCA
        .byte   $3F                             ; 8CCB
        .byte   $34                             ; 8CCC
        .byte   $3B                             ; 8CCD
        .byte   $3B                             ; 8CCE
        adc     $CF2C,y                         ; 8CCF
        bit     $FA9F                           ; 8CD2
        cpy     $2C                             ; 8CD5
        ldy     $7C,x                           ; 8CD7
        .byte   $FA                             ; 8CD9
        .byte   $7F                             ; 8CDA
        .byte   $FE                             ; 8CDB
L8CDC:  pha                                     ; 8CDC
        .byte   $34                             ; 8CDD
        .byte   $42                             ; 8CDE
        adc     $3841,y                         ; 8CDF
        rol     $37,x                           ; 8CE2
        .byte   $43                             ; 8CE4
        adc     $C4FA,x                         ; 8CE5
        bit     $3F42                           ; 8CE8
        .byte   $34                             ; 8CEB
        .byte   $3B                             ; 8CEC
        .byte   $3B                             ; 8CED
        bit     $3037                           ; 8CEE
        .byte   $42                             ; 8CF1
        bit     $3D97                           ; 8CF2
        .byte   $34                             ; 8CF5
L8CF6:  bit     $3E3D                           ; 8CF6
        lsr     $4F                             ; 8CF9
        .byte   $FA                             ; 8CFB
        sec                                     ; 8CFC
        .byte   $43                             ; 8CFD
        jmp     L2C42                           ; 8CFE

; ----------------------------------------------------------------------------
L8D01:  rol     L3445,x                         ; 8D01
        eor     ($4F,x)                         ; 8D04
        bit     $2C96                           ; 8D06
        and     ($48),y                         ; 8D09
        .byte   $34                             ; 8D0B
        adc     L99FA,y                         ; 8D0C
        bit     $38AE                           ; 8D0F
        bmi     L8D51                           ; 8D12
        bit     $7DA2                           ; 8D14
        .byte   $FA                             ; 8D17
        .byte   $7F                             ; 8D18
        inc     $373E,x                         ; 8D19
        adc     $FF2C,x                         ; 8D1C
        adc     L7FFA,x                         ; 8D1F
        lsr     $34                             ; 8D22
        bit     $3032                           ; 8D24
        and     $352C,x                         ; 8D27
        sec                                     ; 8D2A
L8D2B:  and     $3B30,x                         ; 8D2B
        .byte   $3B                             ; 8D2E
        pha                                     ; 8D2F
        bit     $3C34                           ; 8D30
        and     ($41),y                         ; 8D33
        bmi     L8D69                           ; 8D35
        .byte   $34                             ; 8D37
        .byte   $FA                             ; 8D38
        .byte   $34                             ; 8D39
        bmi     L8D6E                           ; 8D3A
        .byte   $37                             ; 8D3C
        bit     $C43E                           ; 8D3D
        eor     ($4F,x)                         ; 8D40
        bit     $3E3D                           ; 8D42
        lsr     $79                             ; 8D45
        bit     $3446                           ; 8D47
        bit     $3E35                           ; 8D4A
        .byte   $44                             ; 8D4D
        eor     ($FA,x)                         ; 8D4E
        .byte   $42                             ; 8D50
L8D51:  .byte   $9F                             ; 8D51
        .byte   $43                             ; 8D52
        .byte   $34                             ; 8D53
        eor     ($42,x)                         ; 8D54
        bit     $FA81                           ; 8D56
        bmi     L8D96                           ; 8D59
        .byte   $3B                             ; 8D5B
        bit     $3E43                           ; 8D5C
        rol     $34,x                           ; 8D5F
        cpy     $41                             ; 8D61
        .byte   $4F                             ; 8D63
        .byte   $FA                             ; 8D64
        .byte   $7F                             ; 8D65
        .byte   $FE                             ; 8D66
L8D67:  bmi     L8D2B                           ; 8D67
L8D69:  .byte   $3B                             ; 8D69
        bmi     L8DAF                           ; 8D6A
        .byte   $3E                             ; 8D6C
        .byte   $79                             ; 8D6D
L8D6E:  bit     $379F                           ; 8D6E
        .byte   $44                             ; 8D71
        .byte   $43                             ; 8D72
        bmi     L8DB0                           ; 8D73
        adc     $41FA,y                         ; 8D75
        rol     $3047,x                         ; 8D78
        and     $343D,x                         ; 8D7B
        adc     $BC2C,y                         ; 8D7E
        .byte   $FA                             ; 8D81
        .byte   $3F                             ; 8D82
        .byte   $44                             ; 8D83
        .byte   $43                             ; 8D84
        bit     $3D38                           ; 8D85
        sec                                     ; 8D88
        .byte   $43                             ; 8D89
        sec                                     ; 8D8A
        bmi     L8DC8                           ; 8D8B
        .byte   $42                             ; 8D8D
        bit     $353E                           ; 8D8E
        bit     $2CC4                           ; 8D91
        and     $3E,x                           ; 8D94
L8D96:  .byte   $44                             ; 8D96
        eor     ($FA,x)                         ; 8D97
        .byte   $42                             ; 8D99
        .byte   $9F                             ; 8D9A
        .byte   $43                             ; 8D9B
        .byte   $34                             ; 8D9C
        eor     ($42,x)                         ; 8D9D
        bit     $2CBD                           ; 8D9F
        and     ($48),y                         ; 8DA2
        bit     $7EBD                           ; 8DA4
        .byte   $FA                             ; 8DA7
        .byte   $7F                             ; 8DA8
        .byte   $82                             ; 8DA9
        bit     $303C                           ; 8DAA
        .byte   $3A                             ; 8DAD
        .byte   $34                             ; 8DAE
L8DAF:  .byte   $2C                             ; 8DAF
L8DB0:  bmi     L8DEF                           ; 8DB0
        bit     $2C08                           ; 8DB2
        .byte   $3B                             ; 8DB5
        .byte   $34                             ; 8DB6
        .byte   $43                             ; 8DB7
        .byte   $43                             ; 8DB8
        .byte   $34                             ; 8DB9
        eor     ($42,x)                         ; 8DBA
        .byte   $FA                             ; 8DBC
        lsr     $3E                             ; 8DBD
        eor     ($33,x)                         ; 8DBF
        .byte   $4F                             ; 8DC1
        .byte   $FA                             ; 8DC2
        .byte   $7F                             ; 8DC3
        inc     $3448,x                         ; 8DC4
        .byte   $42                             ; 8DC7
L8DC8:  adc     $462C,y                         ; 8DC8
        .byte   $34                             ; 8DCB
        bit     $2C81                           ; 8DCC
        cpy     $2C                             ; 8DCF
        eor     ($34,x)                         ; 8DD1
        and     ($38),y                         ; 8DD3
        eor     ($43,x)                         ; 8DD5
        .byte   $37                             ; 8DD7
        .byte   $FA                             ; 8DD8
        rol     $2C35,x                         ; 8DD9
        cpy     $2C                             ; 8DDC
        dey                                     ; 8DDE
        bit     $4342                           ; 8DDF
        bmi     L8E25                           ; 8DE2
        jmp     LFA42                           ; 8DE4

; ----------------------------------------------------------------------------
        cmp     ($79,x)                         ; 8DE7
        bit     $3830                           ; 8DE9
        eor     ($3E,x)                         ; 8DEC
        .byte   $42                             ; 8DEE
L8DEF:  .byte   $32                             ; 8DEF
        txs                                     ; 8DF0
        .byte   $4F                             ; 8DF1
        .byte   $FA                             ; 8DF2
        .byte   $7F                             ; 8DF3
        and     $463E,x                         ; 8DF4
        adc     $432C,y                         ; 8DF7
        .byte   $30                             ; 8DFA
L8DFB:  .byte   $3A                             ; 8DFB
        .byte   $34                             ; 8DFC
L8DFD:  .byte   $2C                             ; 8DFD
L8DFE:  ldx     #$4C                            ; 8DFE
        .byte   $42                             ; 8E00
        bit     $3E41                           ; 8E01
        .byte   $33                             ; 8E04
        .byte   $4F                             ; 8E05
        .byte   $FA                             ; 8E06
        .byte   $33                             ; 8E07
        .byte   $34                             ; 8E08
        and     $34,x                           ; 8E09
        bmi     L8E50                           ; 8E0B
        bit     L9898                           ; 8E0D
        bit     $FACE                           ; 8E10
        cpy     $2C                             ; 8E13
        ldx     $3E2C                           ; 8E15
        and     $FA,x                           ; 8E18
        and     ($3E),y                         ; 8E1A
        .byte   $3B                             ; 8E1C
        .byte   $43                             ; 8E1D
        .byte   $43                             ; 8E1E
        rol     $4F41,x                         ; 8E1F
        .byte   $FA                             ; 8E22
        .byte   $7F                             ; 8E23
        tya                                     ; 8E24
L8E25:  tya                                     ; 8E25
        bit     $2C9F                           ; 8E26
        sec                                     ; 8E29
        and     $C42C,x                         ; 8E2A
        bit     $3033                           ; 8E2D
        eor     ($3A,x)                         ; 8E30
        .byte   $FA                             ; 8E32
        cpy     $2C4F                           ; 8E33
L8E36:  .byte   $97                             ; 8E36
        bit     L9B43                           ; 8E37
        bit     $3743                           ; 8E3A
        eor     ($3E,x)                         ; 8E3D
        .byte   $44                             ; 8E3F
        rol     $37,x                           ; 8E40
        .byte   $FA                             ; 8E42
        cpy     $2C                             ; 8E43
        .byte   $3F                             ; 8E45
        sec                                     ; 8E46
        .byte   $3B                             ; 8E47
        .byte   $3B                             ; 8E48
        bmi     L8E8C                           ; 8E49
        jmp     L2C42                           ; 8E4B

; ----------------------------------------------------------------------------
        eor     ($3E,x)                         ; 8E4E
L8E50:  rol     $4F3C,x                         ; 8E50
        .byte   $FA                             ; 8E53
        inc     $2CD2,x                         ; 8E54
        sec                                     ; 8E57
        .byte   $33                             ; 8E58
        sec                                     ; 8E59
        rol     $7D43,x                         ; 8E5A
        bit     $3037                           ; 8E5D
        eor     $34                             ; 8E60
        and     $434C,x                         ; 8E62
        bit     $FAD2                           ; 8E65
        .byte   $34                             ; 8E68
        eor     $34                             ; 8E69
        and     $3D2C,x                         ; 8E6B
        rol     $3843,x                         ; 8E6E
        .byte   $32                             ; 8E71
        .byte   $34                             ; 8E72
        .byte   $33                             ; 8E73
        bit     $4CD2                           ; 8E74
        eor     $34                             ; 8E77
        bit     $3431                           ; 8E79
        .byte   $34                             ; 8E7C
        and     $36FA,x                         ; 8E7D
        .byte   $44                             ; 8E80
        sec                                     ; 8E81
        .byte   $33                             ; 8E82
        .byte   $34                             ; 8E83
        .byte   $33                             ; 8E84
        bit     $2C82                           ; 8E85
        lsr     $30                             ; 8E88
        .byte   $43                             ; 8E8A
        .byte   $32                             ; 8E8B
L8E8C:  txs                                     ; 8E8C
        .byte   $33                             ; 8E8D
        bit     $4831                           ; 8E8E
        .byte   $FA                             ; 8E91
        cpy     $2C                             ; 8E92
        ldy     $7C,x                           ; 8E94
        .byte   $FA                             ; 8E96
        inc     $D1F5,x                         ; 8E97
        .byte   $04                             ; 8E9A
        bit     $798B                           ; 8E9B
        .byte   $F3                             ; 8E9E
        .byte   $D7                             ; 8E9F
        .byte   $04                             ; 8EA0
        bit     $FAB5                           ; 8EA1
        sbc     $D2,x                           ; 8EA4
        .byte   $04                             ; 8EA6
        bit     $798B                           ; 8EA7
        .byte   $F3                             ; 8EAA
        cmp     $2C04,y                         ; 8EAB
        lda     $FA,x                           ; 8EAE
        .byte   $FE                             ; 8EB0
L8EB1:  sbc     $D3,x                           ; 8EB1
        .byte   $04                             ; 8EB3
        bit     $798B                           ; 8EB4
        .byte   $F3                             ; 8EB7
        .byte   $DB                             ; 8EB8
        .byte   $04                             ; 8EB9
        bit     $FAB5                           ; 8EBA
        inc     L9A46,x                         ; 8EBD
        and     L852C,x                         ; 8EC0
        bit     $FAC0                           ; 8EC3
        sta     ($2C),y                         ; 8EC6
        rol     $3232,x                         ; 8EC8
        .byte   $44                             ; 8ECB
        eor     ($42,x)                         ; 8ECC
        adc     $382C,y                         ; 8ECE
        .byte   $43                             ; 8ED1
        .byte   $FA                             ; 8ED2
        .byte   $42                             ; 8ED3
        .byte   $43                             ; 8ED4
        eor     ($34,x)                         ; 8ED5
        and     $C436,x                         ; 8ED7
        and     L2C42,x                         ; 8EDA
        cpy     $2C                             ; 8EDD
        .byte   $3F                             ; 8EDF
        rol     $3446,x                         ; 8EE0
        eor     ($2C,x)                         ; 8EE3
        rol     $FA35,x                         ; 8EE5
        dey                                     ; 8EE8
        bit     $4342                           ; 8EE9
        bmi     L8F2F                           ; 8EEC
        jmp     L2C42                           ; 8EEE

; ----------------------------------------------------------------------------
        cmp     ($FA,x)                         ; 8EF1
        .byte   $7F                             ; 8EF3
        bmi     L8F2E                           ; 8EF4
        eor     ($3E,x)                         ; 8EF6
        .byte   $42                             ; 8EF8
        .byte   $32                             ; 8EF9
        txs                                     ; 8EFA
        adc     $C42C,y                         ; 8EFB
L8EFE:  bit     $3D84                           ; 8EFE
        .byte   $FA                             ; 8F01
        rol     $44,x                           ; 8F02
        bmi     L8F47                           ; 8F04
        .byte   $33                             ; 8F06
        sec                                     ; 8F07
        bmi     L8F47                           ; 8F08
        bit     $3433                           ; 8F0A
        sec                                     ; 8F0D
        .byte   $43                             ; 8F0E
        pha                                     ; 8F0F
        adc     $31FA,y                         ; 8F10
        .byte   $34                             ; 8F13
        .byte   $32                             ; 8F14
        bmi     L8F5B                           ; 8F15
        .byte   $42                             ; 8F17
        .byte   $34                             ; 8F18
        bit     $4338                           ; 8F19
        bit     $3742                           ; 8F1C
        .byte   $44                             ; 8F1F
        .byte   $43                             ; 8F20
        .byte   $42                             ; 8F21
        bit     $443E                           ; 8F22
        .byte   $43                             ; 8F25
        bit     $3B30                           ; 8F26
        .byte   $3B                             ; 8F29
        .byte   $FA                             ; 8F2A
        cpy     $2C                             ; 8F2B
        .byte   $42                             ; 8F2D
L8F2E:  .byte   $44                             ; 8F2E
L8F2F:  and     $4FA9,x                         ; 8F2F
        bit     $FAC5                           ; 8F32
        .byte   $7F                             ; 8F35
        .byte   $32                             ; 8F36
        bmi     L8F7D                           ; 8F37
        .byte   $42                             ; 8F39
        .byte   $34                             ; 8F3A
        .byte   $42                             ; 8F3B
        bit     $3B30                           ; 8F3C
        .byte   $3B                             ; 8F3F
        bit     $383A                           ; 8F40
        and     $4233,x                         ; 8F43
        .byte   $2C                             ; 8F46
L8F47:  rol     $FA35,x                         ; 8F47
        and     $30,x                           ; 8F4A
        eor     $3E                             ; 8F4C
        eor     ($30,x)                         ; 8F4E
        and     ($3B),y                         ; 8F50
        .byte   $34                             ; 8F52
        bit     $383C                           ; 8F53
        eor     ($30,x)                         ; 8F56
        .byte   $32                             ; 8F58
        .byte   $3B                             ; 8F59
        .byte   $34                             ; 8F5A
L8F5B:  .byte   $42                             ; 8F5B
        bit     $3D38                           ; 8F5C
        .byte   $FA                             ; 8F5F
        sta     $4F                             ; 8F60
        bit     $42C4                           ; 8F62
        .byte   $34                             ; 8F65
        bit     $383C                           ; 8F66
        eor     ($30,x)                         ; 8F69
        .byte   $32                             ; 8F6B
        .byte   $3B                             ; 8F6C
        .byte   $34                             ; 8F6D
        .byte   $42                             ; 8F6E
        .byte   $FA                             ; 8F6F
        .byte   $32                             ; 8F70
        bmi     L8FB0                           ; 8F71
        bit     $3431                           ; 8F73
        bit     $303C                           ; 8F76
        .byte   $47                             ; 8F79
        sec                                     ; 8F7A
        .byte   $3C                             ; 8F7B
        sec                                     ; 8F7C
L8F7D:  eor     #$34                            ; 8F7D
        .byte   $33                             ; 8F7F
        bit     $3538                           ; 8F80
        .byte   $FA                             ; 8F83
        .byte   $7F                             ; 8F84
        .byte   $D2                             ; 8F85
        bit     $3B3F                           ; 8F86
        bmi     L8FC8                           ; 8F89
        .byte   $43                             ; 8F8B
        bit     $2CC4                           ; 8F8C
        eor     ($44,x)                         ; 8F8F
        .byte   $3F                             ; 8F91
        sec                                     ; 8F92
        bmi     L8FE1                           ; 8F93
        .byte   $42                             ; 8F95
        .byte   $FA                             ; 8F96
        .byte   $42                             ; 8F97
L8F98:  .byte   $34                             ; 8F98
        .byte   $34                             ; 8F99
        .byte   $33                             ; 8F9A
        bit     $4433                           ; 8F9B
        eor     ($A3,x)                         ; 8F9E
        bit     $FAC5                           ; 8FA0
        .byte   $3F                             ; 8FA3
        .byte   $34                             ; 8FA4
        eor     ($38,x)                         ; 8FA5
        rol     $7933,x                         ; 8FA7
        bit     $3E35                           ; 8FAA
        eor     ($2C,x)                         ; 8FAD
        .byte   $34                             ; 8FAF
L8FB0:  .byte   $47                             ; 8FB0
        bmi     L8FEF                           ; 8FB1
        .byte   $3F                             ; 8FB3
        .byte   $3B                             ; 8FB4
        .byte   $34                             ; 8FB5
        adc     $D22C,y                         ; 8FB6
        .byte   $FA                             ; 8FB9
        bne     L8FE8                           ; 8FBA
        and     ($34),y                         ; 8FBC
        bit     $3130                           ; 8FBE
        .byte   $3B                             ; 8FC1
        .byte   $34                             ; 8FC2
        bit     $3E43                           ; 8FC3
        .byte   $2C                             ; 8FC6
        .byte   $44                             ; 8FC7
L8FC8:  .byte   $42                             ; 8FC8
        .byte   $34                             ; 8FC9
        .byte   $FA                             ; 8FCA
        .byte   $7F                             ; 8FCB
        cpy     $2C                             ; 8FCC
        sta     $AE2C,y                         ; 8FCE
        bit     $413E                           ; 8FD1
        bit     $3846                           ; 8FD4
        and     $302C,x                         ; 8FD7
        .byte   $FA                             ; 8FDA
        rol     $30,x                           ; 8FDB
        ldy     $302C                           ; 8FDD
        .byte   $43                             ; 8FE0
L8FE1:  bit     $2CC4                           ; 8FE1
        .byte   $32                             ; 8FE4
        bmi     L9029                           ; 8FE5
        sec                                     ; 8FE7
L8FE8:  and     $4F3E,x                         ; 8FE8
        .byte   $FA                             ; 8FEB
        .byte   $7F                             ; 8FEC
        .byte   $FE                             ; 8FED
        .byte   $43                             ; 8FEE
L8FEF:  .byte   $9B                             ; 8FEF
        bit     $2C81                           ; 8FF0
        and     $38,x                           ; 8FF3
        eor     $34                             ; 8FF5
        bit     $2CD1                           ; 8FF7
        .byte   $AC                             ; 8FFA
L8FFB:  .byte   $3D                             ; 8FFB
        .byte   $FA                             ; 8FFC
L8FFD:  sec                                     ; 8FFD
        and     $302C,x                         ; 8FFE
        eor     ($30,x)                         ; 9001
        and     ($38),y                         ; 9003
        bmi     L9056                           ; 9005
        bit     $3034                           ; 9007
        .byte   $32                             ; 900A
        .byte   $37                             ; 900B
        bit     $353E                           ; 900C
        .byte   $FA                             ; 900F
        cpy     $3C                             ; 9010
        bit     $3032                           ; 9012
        and     L952C,x                         ; 9015
        bit     $2CD2                           ; 9018
        cpy     $FA                             ; 901B
        ldx     $D22C                           ; 901D
        bit     $343D                           ; 9020
        .byte   $34                             ; 9023
        .byte   $33                             ; 9024
        .byte   $4F                             ; 9025
        .byte   $FA                             ; 9026
        .byte   $7F                             ; 9027
        .byte   $3C                             ; 9028
L9029:  rol     $413E,x                         ; 9029
        rol     $3D3E,x                         ; 902C
        jmp     L2C42                           ; 902F

; ----------------------------------------------------------------------------
        cmp     ($2C),y                         ; 9032
        lda     $AA2C                           ; 9034
        .byte   $42                             ; 9037
        .byte   $FA                             ; 9038
        sec                                     ; 9039
        and     $302C,x                         ; 903A
        bit     $303C                           ; 903D
        eor     #$34                            ; 9040
        bit     $3E42                           ; 9042
        .byte   $44                             ; 9045
        .byte   $43                             ; 9046
        .byte   $37                             ; 9047
        .byte   $34                             ; 9048
        bmi     L908D                           ; 9049
        .byte   $43                             ; 904B
        .byte   $FA                             ; 904C
        rol     $2C35,x                         ; 904D
        cmp     $2C                             ; 9050
        .byte   $CB                             ; 9052
        .byte   $4F                             ; 9053
        .byte   $FA                             ; 9054
        .byte   $7F                             ; 9055
L9056:  txs                                     ; 9056
        bit     $3032                           ; 9057
        and     L952C,x                         ; 905A
        bit     $FAD2                           ; 905D
        cpy     $2C                             ; 9060
        sta     $AE2C,y                         ; 9062
        bit     $3032                           ; 9065
        .byte   $3B                             ; 9068
        .byte   $3B                             ; 9069
        .byte   $34                             ; 906A
        .byte   $33                             ; 906B
        .byte   $FA                             ; 906C
        .byte   $3C                             ; 906D
        rol     $343D,x                         ; 906E
        .byte   $32                             ; 9071
        rol     $4F3C,x                         ; 9072
        .byte   $FA                             ; 9075
        .byte   $7F                             ; 9076
        inc     $2C30,x                         ; 9077
        cmp     ($2C),y                         ; 907A
        lda     $CD2C                           ; 907C
        bit     $3F30                           ; 907F
        .byte   $3F                             ; 9082
        .byte   $34                             ; 9083
        bmi     L90C7                           ; 9084
        .byte   $FA                             ; 9086
        sec                                     ; 9087
        and     $302C,x                         ; 9088
        .byte   $2C                             ; 908B
        .byte   $33                             ; 908C
L908D:  .byte   $34                             ; 908D
        .byte   $42                             ; 908E
        .byte   $34                             ; 908F
        eor     ($43,x)                         ; 9090
        bit     $3742                           ; 9092
        eor     ($38,x)                         ; 9095
        and     $2C34,x                         ; 9097
        ora     $00                             ; 909A
        brk                                     ; 909C
        .byte   $FA                             ; 909D
        .byte   $D3                             ; 909E
        bit     $303B                           ; 909F
        .byte   $43                             ; 90A2
        .byte   $34                             ; 90A3
        eor     ($4F,x)                         ; 90A4
        .byte   $FA                             ; 90A6
        .byte   $7F                             ; 90A7
        txs                                     ; 90A8
        bit     $3032                           ; 90A9
        and     L952C,x                         ; 90AC
        bit     $FAD2                           ; 90AF
        cpy     $2C                             ; 90B2
        sta     $AE2C,y                         ; 90B4
        bit     $3032                           ; 90B7
        .byte   $3B                             ; 90BA
        .byte   $3B                             ; 90BB
        .byte   $34                             ; 90BC
        .byte   $33                             ; 90BD
        .byte   $FA                             ; 90BE
        eor     ($30,x)                         ; 90BF
        sec                                     ; 90C1
        and     $3E32,x                         ; 90C2
        .byte   $3C                             ; 90C5
        .byte   $4F                             ; 90C6
L90C7:  .byte   $FA                             ; 90C7
        .byte   $7F                             ; 90C8
        cmp     $2C                             ; 90C9
        ldx     $CD2C                           ; 90CB
        .byte   $FA                             ; 90CE
        rol     $41,x                           ; 90CF
        rol     $2C46,x                         ; 90D1
        and     $3E,x                           ; 90D4
        eor     ($43,x)                         ; 90D6
        .byte   $37                             ; 90D8
        bit     $4534                           ; 90D9
        .byte   $34                             ; 90DC
        and     $352C,x                         ; 90DD
        eor     ($3E,x)                         ; 90E0
        .byte   $3C                             ; 90E2
        bit     $FAC4                           ; 90E3
        .byte   $33                             ; 90E6
        eor     ($48,x)                         ; 90E7
        bit     $3034                           ; 90E9
        eor     ($43,x)                         ; 90EC
        .byte   $37                             ; 90EE
        .byte   $4F                             ; 90EF
        .byte   $FA                             ; 90F0
        .byte   $7F                             ; 90F1
        inc     $2C30,x                         ; 90F2
        cmp     ($2C),y                         ; 90F5
        lda     $CD2C                           ; 90F7
        bit     $3F30                           ; 90FA
        .byte   $3F                             ; 90FD
        .byte   $34                             ; 90FE
        bmi     L9142                           ; 90FF
        .byte   $FA                             ; 9101
        .byte   $03                             ; 9102
        brk                                     ; 9103
        bit     $2CD3                           ; 9104
        .byte   $3B                             ; 9107
        bmi     L914D                           ; 9108
        .byte   $34                             ; 910A
        eor     ($2C,x)                         ; 910B
        sec                                     ; 910D
        and     $302C,x                         ; 910E
        .byte   $FA                             ; 9111
        .byte   $42                             ; 9112
        .byte   $37                             ; 9113
        eor     ($38,x)                         ; 9114
        and     $2C34,x                         ; 9116
        and     $413E,x                         ; 9119
        .byte   $43                             ; 911C
        .byte   $37                             ; 911D
        lsr     $34                             ; 911E
        .byte   $42                             ; 9120
        .byte   $43                             ; 9121
        bit     $353E                           ; 9122
        .byte   $FA                             ; 9125
        and     $3144,x                         ; 9126
        sec                                     ; 9129
        bmi     L917B                           ; 912A
        .byte   $FA                             ; 912C
        .byte   $7F                             ; 912D
        txs                                     ; 912E
        bit     $2CCD                           ; 912F
        sta     $2C,x                           ; 9132
        .byte   $D2                             ; 9134
        .byte   $FA                             ; 9135
        cpy     $2C                             ; 9136
        sta     $AE2C,y                         ; 9138
        bit     $353E                           ; 913B
        .byte   $FA                             ; 913E
        .byte   $42                             ; 913F
        .byte   $3F                             ; 9140
        .byte   $41                             ; 9141
L9142:  sec                                     ; 9142
        .byte   $32                             ; 9143
        rol     $4F3C,x                         ; 9144
        .byte   $FA                             ; 9147
        .byte   $7F                             ; 9148
        cmp     $2C                             ; 9149
        .byte   $AE                             ; 914B
        .byte   $2C                             ; 914C
L914D:  cmp     $31FA                           ; 914D
        eor     ($A3,x)                         ; 9150
        bit     $3F42                           ; 9152
        eor     ($A3,x)                         ; 9155
        bit     L9B46                           ; 9157
        bit     $4338                           ; 915A
        bit     $FA9F                           ; 915D
        and     $41,x                           ; 9160
        rol     $3449,x                         ; 9162
        and     $FA4F,x                         ; 9165
        .byte   $7F                             ; 9168
        inc     $2CC4,x                         ; 9169
        cmp     ($2C),y                         ; 916C
        lda     $3E2C                           ; 916E
        and     $FA,x                           ; 9171
        .byte   $32                             ; 9173
        .byte   $34                             ; 9174
        .byte   $3B                             ; 9175
        .byte   $34                             ; 9176
        .byte   $42                             ; 9177
        .byte   $43                             ; 9178
        .byte   $34                             ; 9179
        .byte   $41                             ; 917A
L917B:  and     $442C,x                         ; 917B
        .byte   $42                             ; 917E
        .byte   $34                             ; 917F
        .byte   $33                             ; 9180
        bit     $3E43                           ; 9181
        bit     $FAAA                           ; 9184
        sec                                     ; 9187
        and     $C42C,x                         ; 9188
        bit     $4448                           ; 918B
        and     $3B,x                           ; 918E
        bmi     L91BE                           ; 9190
        bcs     L91C0                           ; 9192
        .byte   $03                             ; 9194
        brk                                     ; 9195
        brk                                     ; 9196
        brk                                     ; 9197
        .byte   $FA                             ; 9198
        .byte   $D3                             ; 9199
        bit     L9730                           ; 919A
        .byte   $4F                             ; 919D
        bit     $2CC5                           ; 919E
        ldx     L7FFA                           ; 91A1
        .byte   $3C                             ; 91A4
        bmi     L91E1                           ; 91A5
        .byte   $34                             ; 91A7
        .byte   $42                             ; 91A8
        bit     $2CC4                           ; 91A9
        .byte   $3C                             ; 91AC
        rol     $4042,x                         ; 91AD
        .byte   $44                             ; 91B0
        .byte   $34                             ; 91B1
        bit     $3F30                           ; 91B2
        .byte   $3F                             ; 91B5
        .byte   $34                             ; 91B6
        bmi     L91FA                           ; 91B7
        .byte   $FA                             ; 91B9
        .byte   $82                             ; 91BA
        bit     $343B                           ; 91BB
L91BE:  .byte   $43                             ; 91BE
        .byte   $42                             ; 91BF
L91C0:  bit     $2CD2                           ; 91C0
        .byte   $32                             ; 91C3
        .byte   $37                             ; 91C4
        bmi     L9204                           ; 91C5
        rol     $34,x                           ; 91C7
        bit     $41D2                           ; 91C9
        .byte   $FA                             ; 91CC
        .byte   $32                             ; 91CD
        .byte   $3B                             ; 91CE
        bmi     L9213                           ; 91CF
        .byte   $42                             ; 91D1
        .byte   $4F                             ; 91D2
        cpy     $2C                             ; 91D3
        and     $AC30,x                         ; 91D5
        bit     $FA9F                           ; 91D8
        .byte   $3C                             ; 91DB
        rol     $3242,x                         ; 91DC
        .byte   $3E                             ; 91DF
        .byte   $3C                             ; 91E0
L91E1:  .byte   $4F                             ; 91E1
        .byte   $FA                             ; 91E2
        .byte   $7F                             ; 91E3
        inc     $2CC4,x                         ; 91E4
        cmp     ($2C),y                         ; 91E7
        lda     $3E2C                           ; 91E9
        and     $FA,x                           ; 91EC
        .byte   $32                             ; 91EE
        .byte   $34                             ; 91EF
        .byte   $3B                             ; 91F0
        .byte   $34                             ; 91F1
        .byte   $42                             ; 91F2
        .byte   $43                             ; 91F3
        .byte   $34                             ; 91F4
        eor     ($3D,x)                         ; 91F5
        bit     $42AA                           ; 91F7
L91FA:  bit     $3D38                           ; 91FA
        bit     $FA30                           ; 91FD
        .byte   $42                             ; 9200
        .byte   $37                             ; 9201
        eor     ($38,x)                         ; 9202
L9204:  and     $2C34,x                         ; 9204
        lsr     $34                             ; 9207
        .byte   $42                             ; 9209
        .byte   $43                             ; 920A
        bit     $353E                           ; 920B
        bit     $2CC4                           ; 920E
        .byte   $93                             ; 9211
        .byte   $FA                             ; 9212
L9213:  bcs     L9264                           ; 9213
        .byte   $FA                             ; 9215
        .byte   $7F                             ; 9216
        txs                                     ; 9217
        bit     $2CCD                           ; 9218
        sta     $2C,x                           ; 921B
        .byte   $D2                             ; 921D
        .byte   $FA                             ; 921E
        cpy     $2C                             ; 921F
        sta     $AE2C,y                         ; 9221
        bit     $3032                           ; 9224
        .byte   $3B                             ; 9227
        .byte   $3B                             ; 9228
        .byte   $34                             ; 9229
        .byte   $33                             ; 922A
        .byte   $FA                             ; 922B
        .byte   $3B                             ; 922C
        sec                                     ; 922D
        and     ($32),y                         ; 922E
        rol     $4F3C,x                         ; 9230
        bit     $2CC5                           ; 9233
        .byte   $9F                             ; 9236
        bit     $FAC4                           ; 9237
        ldx     $3E2C                           ; 923A
        and     $2C,x                           ; 923D
        .byte   $3B                             ; 923F
        sec                                     ; 9240
        and     $34,x                           ; 9241
        bit     $3746                           ; 9243
        sec                                     ; 9246
        .byte   $32                             ; 9247
        .byte   $37                             ; 9248
        .byte   $FA                             ; 9249
        .byte   $7F                             ; 924A
        and     ($41),y                         ; 924B
        .byte   $A3                             ; 924D
        .byte   $42                             ; 924E
        bit     $2CC4                           ; 924F
        .byte   $33                             ; 9252
        .byte   $34                             ; 9253
        bmi     L9289                           ; 9254
        bit     $3031                           ; 9256
        .byte   $32                             ; 9259
        .byte   $3A                             ; 925A
        .byte   $FA                             ; 925B
        .byte   $43                             ; 925C
        rol     $3B2C,x                         ; 925D
        sec                                     ; 9260
        and     $34,x                           ; 9261
        .byte   $2C                             ; 9263
L9264:  .byte   $82                             ; 9264
        bit     $309A                           ; 9265
        .byte   $3B                             ; 9268
        .byte   $42                             ; 9269
        bit     $FAC4                           ; 926A
        lsr     $3E                             ; 926D
        .byte   $44                             ; 926F
        and     $3433,x                         ; 9270
        .byte   $33                             ; 9273
        .byte   $4F                             ; 9274
        .byte   $FA                             ; 9275
        .byte   $7F                             ; 9276
        .byte   $43                             ; 9277
        rol     $3F2C,x                         ; 9278
        eor     ($3E,x)                         ; 927B
        eor     $34                             ; 927D
        bit     $3743                           ; 927F
        bmi     L92C7                           ; 9282
        bit     $2CD2                           ; 9284
        .byte   $37                             ; 9287
        .byte   $30                             ; 9288
L9289:  eor     $34                             ; 9289
        .byte   $FA                             ; 928B
        .byte   $3F                             ; 928C
        bmi     L92D1                           ; 928D
        .byte   $42                             ; 928F
        .byte   $34                             ; 9290
        .byte   $33                             ; 9291
        bit     $2CC4                           ; 9292
        .byte   $32                             ; 9295
        .byte   $3B                             ; 9296
        bmi     L92DB                           ; 9297
        .byte   $42                             ; 9299
        adc     $382C,y                         ; 929A
        bit     $FACD                           ; 929D
        sta     $2C,x                           ; 92A0
        .byte   $D2                             ; 92A2
        ror     $7E7E,x                         ; 92A3
        bit     $3C37                           ; 92A6
        .byte   $3C                             ; 92A9
        adc     $382C,x                         ; 92AA
        bit     $FA8F                           ; 92AD
        .byte   $37                             ; 92B0
        bmi     L92F8                           ; 92B1
        .byte   $34                             ; 92B3
        bit     $3D30                           ; 92B4
        pha                                     ; 92B7
        .byte   $43                             ; 92B8
        .byte   $37                             ; 92B9
        .byte   $A3                             ; 92BA
        bit     $FAC5                           ; 92BB
        .byte   $7F                             ; 92BE
        cmp     #$4F                            ; 92BF
        bit     $2C38                           ; 92C1
        rol     $44,x                           ; 92C4
        .byte   $34                             ; 92C6
L92C7:  .byte   $42                             ; 92C7
        .byte   $42                             ; 92C8
        bit     $2CD2                           ; 92C9
        lsr     $34                             ; 92CC
        eor     ($34,x)                         ; 92CE
        .byte   $FA                             ; 92D0
L92D1:  .byte   $34                             ; 92D1
        .byte   $47                             ; 92D2
        .byte   $3F                             ; 92D3
        .byte   $34                             ; 92D4
        .byte   $32                             ; 92D5
        .byte   $43                             ; 92D6
        .byte   $A3                             ; 92D7
        bit     $3E42                           ; 92D8
L92DB:  ldy     $3743                           ; 92DB
        .byte   $A3                             ; 92DE
        adc     $31FA,y                         ; 92DF
        .byte   $44                             ; 92E2
        .byte   $43                             ; 92E3
        ror     $7E7E,x                         ; 92E4
        ror     L9A2C,x                         ; 92E7
        .byte   $37                             ; 92EA
        adc     L9A2C,y                         ; 92EB
        .byte   $37                             ; 92EE
        adc     L9A2C,y                         ; 92EF
        .byte   $37                             ; 92F2
        .byte   $4F                             ; 92F3
        .byte   $FA                             ; 92F4
        .byte   $7F                             ; 92F5
        bmi     L9335                           ; 92F6
L92F8:  pha                                     ; 92F8
        lsr     $30                             ; 92F9
        pha                                     ; 92FB
        bit     $2C38                           ; 92FC
        lsr     $9F                             ; 92FF
        .byte   $37                             ; 9301
        bit     $FAD2                           ; 9302
        stx     $2C,y                           ; 9305
        .byte   $3B                             ; 9307
        .byte   $44                             ; 9308
        .byte   $32                             ; 9309
        .byte   $3A                             ; 930A
        .byte   $4F                             ; 930B
        .byte   $FA                             ; 930C
        .byte   $7F                             ; 930D
        inc     $2CC4,x                         ; 930E
        sty     $2C,x                           ; 9311
        .byte   $9F                             ; 9313
        bit     $FA30                           ; 9314
        .byte   $42                             ; 9317
        .byte   $43                             ; 9318
        eor     ($30,x)                         ; 9319
        .byte   $43                             ; 931B
        .byte   $34                             ; 931C
        rol     $48,x                           ; 931D
        bit     $3E43                           ; 931F
        bit     $3433                           ; 9322
        and     $34,x                           ; 9325
        bmi     L936C                           ; 9327
        bit     $FAC4                           ; 9329
        .byte   $34                             ; 932C
        and     $3C34,x                         ; 932D
        pha                                     ; 9330
        bit     $4F83                           ; 9331
        .byte   $FA                             ; 9334
L9335:  .byte   $42                             ; 9335
        .byte   $34                             ; 9336
        .byte   $3B                             ; 9337
        .byte   $34                             ; 9338
        .byte   $32                             ; 9339
        .byte   $43                             ; 933A
        bit     $2CC4                           ; 933B
        sty     $FA,x                           ; 933E
        .byte   $7F                             ; 9340
        .byte   $82                             ; 9341
        bit     $3835                           ; 9342
        rol     $37,x                           ; 9345
        .byte   $43                             ; 9347
        adc     $3DC4,y                         ; 9348
        bit     $41D2                           ; 934B
        .byte   $FA                             ; 934E
        .byte   $33                             ; 934F
        .byte   $34                             ; 9350
        and     $34,x                           ; 9351
        and     $3442,x                         ; 9353
        bit     $3E3F                           ; 9356
        lsr     $34                             ; 9359
        eor     ($2C,x)                         ; 935B
        sec                                     ; 935D
        and     $4132,x                         ; 935E
        .byte   $34                             ; 9361
        bmi     L93A6                           ; 9362
        .byte   $34                             ; 9364
        .byte   $42                             ; 9365
        .byte   $FA                             ; 9366
        .byte   $82                             ; 9367
        bit     $2CD2                           ; 9368
        .byte   $32                             ; 936B
L936C:  bmi     L93AB                           ; 936C
        bit     $4244                           ; 936E
        .byte   $34                             ; 9371
        bit     $30AE                           ; 9372
        .byte   $3B                             ; 9375
        .byte   $FA                             ; 9376
        .byte   $3F                             ; 9377
        rol     $3446,x                         ; 9378
        eor     ($42,x)                         ; 937B
        .byte   $4F                             ; 937D
        .byte   $FA                             ; 937E
        .byte   $7F                             ; 937F
        .byte   $37                             ; 9380
        rol     $3446,x                         ; 9381
        eor     $34                             ; 9384
        eor     ($79,x)                         ; 9386
        rol     $3B3D,x                         ; 9388
        pha                                     ; 938B
        .byte   $FA                             ; 938C
        cpy     $2C                             ; 938D
        sty     $2C,x                           ; 938F
        lsr     $37                             ; 9391
        sec                                     ; 9393
        .byte   $32                             ; 9394
        .byte   $37                             ; 9395
        bit     $3835                           ; 9396
        .byte   $43                             ; 9399
        .byte   $42                             ; 939A
        .byte   $FA                             ; 939B
        cpy     $2C                             ; 939C
        .byte   $34                             ; 939E
        and     $3C34,x                         ; 939F
        pha                                     ; 93A2
        jmp     L2C42                           ; 93A3

; ----------------------------------------------------------------------------
L93A6:  .byte   $32                             ; 93A6
        .byte   $37                             ; 93A7
        bmi     L93EB                           ; 93A8
        .byte   $30                             ; 93AA
L93AB:  .byte   $32                             ; 93AB
        .byte   $43                             ; 93AC
        .byte   $34                             ; 93AD
        eor     ($FA,x)                         ; 93AE
        cmp     $462C                           ; 93B0
        rol     $3A41,x                         ; 93B3
        .byte   $4F                             ; 93B6
        .byte   $FA                             ; 93B7
        .byte   $7F                             ; 93B8
        inc     $2CFE,x                         ; 93B9
        .byte   $7B                             ; 93BC
        ldy     $FA7B,x                         ; 93BD
        dex                                     ; 93C0
        bit     $79D2                           ; 93C1
        .byte   $FF                             ; 93C4
        .byte   $4F                             ; 93C5
        bit     $2CD2                           ; 93C6
        .byte   $37                             ; 93C9
        bmi     L9411                           ; 93CA
        .byte   $34                             ; 93CC
        .byte   $FA                             ; 93CD
        .byte   $33                             ; 93CE
        .byte   $34                             ; 93CF
        and     $34,x                           ; 93D0
        bmi     L9417                           ; 93D2
        .byte   $34                             ; 93D4
        .byte   $33                             ; 93D5
        bit     $2CC4                           ; 93D6
        sta     $D62C,y                         ; 93D9
        bit     L98FA                           ; 93DC
        tya                                     ; 93DF
        adc     $C42C,y                         ; 93E0
        bit     $443F                           ; 93E3
        eor     ($34,x)                         ; 93E6
        bit     $4534                           ; 93E8
L93EB:  sec                                     ; 93EB
        .byte   $3B                             ; 93EC
        .byte   $4F                             ; 93ED
        .byte   $FA                             ; 93EE
        .byte   $7F                             ; 93EF
        sty     $2C                             ; 93F0
        cmp     $312C                           ; 93F2
        .byte   $34                             ; 93F5
        bit     $2C30                           ; 93F6
        .byte   $33                             ; 93F9
        eor     ($34,x)                         ; 93FA
        bmi     L943A                           ; 93FC
        .byte   $FA                             ; 93FE
        cpy     $302C                           ; 93FF
        rol     $30,x                           ; 9402
        sec                                     ; 9404
        and     $FA4F,x                         ; 9405
        and     $463E,x                         ; 9408
        adc     $AB2C,y                         ; 940B
        bit     $2C97                           ; 940E
L9411:  .byte   $82                             ; 9411
        bit     $3442                           ; 9412
        .byte   $34                             ; 9415
        .byte   $FA                             ; 9416
L9417:  cpy     $2C                             ; 9417
        .byte   $3A                             ; 9419
        .byte   $A3                             ; 941A
        bit     $3435                           ; 941B
        .byte   $9F                             ; 941E
        bmi     L945C                           ; 941F
        .byte   $4F                             ; 9421
        .byte   $FA                             ; 9422
        .byte   $7F                             ; 9423
        inc     $7B2C,x                         ; 9424
        and     $34,x                           ; 9427
        .byte   $9F                             ; 9429
        bmi     L9467                           ; 942A
        .byte   $7B                             ; 942C
        .byte   $FA                             ; 942D
        cpy     $2C                             ; 942E
        .byte   $3F                             ; 9430
        .byte   $44                             ; 9431
        eor     ($34,x)                         ; 9432
        bit     $4534                           ; 9434
        sec                                     ; 9437
        .byte   $3B                             ; 9438
        .byte   $2C                             ; 9439
L943A:  tya                                     ; 943A
        tya                                     ; 943B
        .byte   $FA                             ; 943C
        .byte   $37                             ; 943D
        bmi     L9482                           ; 943E
        bit     $3431                           ; 9440
        .byte   $34                             ; 9443
        and     $332C,x                         ; 9444
        .byte   $34                             ; 9447
        .byte   $42                             ; 9448
        .byte   $43                             ; 9449
        eor     ($3E,x)                         ; 944A
        pha                                     ; 944C
        .byte   $34                             ; 944D
        .byte   $33                             ; 944E
        bit     $FA82                           ; 944F
        .byte   $7F                             ; 9452
        cpy     $2C                             ; 9453
        .byte   $3F                             ; 9455
        rol     $3446,x                         ; 9456
        eor     ($2C,x)                         ; 9459
        .byte   $3E                             ; 945B
L945C:  and     $2C,x                           ; 945C
        cpy     $2C                             ; 945E
        and     $4244,y                         ; 9460
        .byte   $43                             ; 9463
        sec                                     ; 9464
        .byte   $32                             ; 9465
        .byte   $34                             ; 9466
L9467:  .byte   $FA                             ; 9467
        bmi     L94A2                           ; 9468
        eor     ($3E,x)                         ; 946A
        .byte   $42                             ; 946C
        .byte   $32                             ; 946D
        txs                                     ; 946E
        bit     $3037                           ; 946F
        .byte   $42                             ; 9472
        bit     L3441                           ; 9473
        .byte   $32                             ; 9476
        rol     L3445,x                         ; 9477
        eor     ($34,x)                         ; 947A
        .byte   $33                             ; 947C
        .byte   $4F                             ; 947D
        .byte   $FA                             ; 947E
        sec                                     ; 947F
        .byte   $2C                             ; 9480
        dex                                     ; 9481
L9482:  bit     $2CD2                           ; 9482
        eor     $34                             ; 9485
        eor     ($48,x)                         ; 9487
        bit     $443C                           ; 9489
        .byte   $32                             ; 948C
        .byte   $37                             ; 948D
        .byte   $FA                             ; 948E
        .byte   $7F                             ; 948F
        rol     $2C3D,x                         ; 9490
        and     ($34),y                         ; 9493
        .byte   $37                             ; 9495
        bmi     L94D3                           ; 9496
        and     $2C,x                           ; 9498
        rol     $2C35,x                         ; 949A
        cpy     $2C                             ; 949D
        sty     $3D                             ; 949F
        .byte   $FA                             ; 94A1
L94A2:  .byte   $3F                             ; 94A2
        .byte   $34                             ; 94A3
        rol     $3B3F,x                         ; 94A4
        .byte   $34                             ; 94A7
        .byte   $4F                             ; 94A8
        .byte   $FA                             ; 94A9
        and     ($48),y                         ; 94AA
        bit     $2CC4                           ; 94AC
        lsr     $30                             ; 94AF
        pha                                     ; 94B1
        adc     $FF2C,y                         ; 94B2
        adc     $462C,y                         ; 94B5
        .byte   $37                             ; 94B8
        bmi     L94FE                           ; 94B9
        .byte   $FA                             ; 94BB
        cmp     $D22C                           ; 94BC
        bit     $3E33                           ; 94BF
        bit     $4135                           ; 94C2
        rol     $2C3C,x                         ; 94C5
        and     $463E,x                         ; 94C8
        .byte   $7C                             ; 94CB
        .byte   $FA                             ; 94CC
        .byte   $7F                             ; 94CD
        bit     $FF7B                           ; 94CE
        .byte   $7B                             ; 94D1
        .byte   $FA                             ; 94D2
L94D3:  bmi     L9517                           ; 94D3
        bit     $3E3B                           ; 94D5
        and     $2C36,x                         ; 94D8
        bmi     L951F                           ; 94DB
        bit     $2CC4                           ; 94DD
        .byte   $3C                             ; 94E0
        pha                                     ; 94E1
        .byte   $42                             ; 94E2
        .byte   $43                             ; 94E3
        .byte   $34                             ; 94E4
        eor     ($38,x)                         ; 94E5
        .byte   $7B                             ; 94E7
        .byte   $FA                             ; 94E8
        rol     $4244,x                         ; 94E9
        bit     $2CCC                           ; 94EC
        .byte   $32                             ; 94EF
        bmi     L952D                           ; 94F0
        .byte   $3B                             ; 94F2
        .byte   $42                             ; 94F3
        bit     $79AC                           ; 94F4
        .byte   $FA                             ; 94F7
        sec                                     ; 94F8
        bit     $3E32                           ; 94F9
        .byte   $3D                             ; 94FC
        .byte   $43                             ; 94FD
L94FE:  sec                                     ; 94FE
        and     $3444,x                         ; 94FF
        bit     $483C                           ; 9502
        bit     $3E39                           ; 9505
        .byte   $44                             ; 9508
        eor     ($3D,x)                         ; 9509
        .byte   $34                             ; 950B
        pha                                     ; 950C
        .byte   $4F                             ; 950D
        .byte   $FA                             ; 950E
        .byte   $7F                             ; 950F
        bit     $357B                           ; 9510
        .byte   $34                             ; 9513
        .byte   $9F                             ; 9514
        bmi     L9552                           ; 9515
L9517:  .byte   $7B                             ; 9517
        .byte   $FA                             ; 9518
        sec                                     ; 9519
        bit     $3442                           ; 951A
        .byte   $34                             ; 951D
        .byte   $4F                             ; 951E
L951F:  bit     $2CD2                           ; 951F
        .byte   $33                             ; 9522
        rol     $4C3D,x                         ; 9523
        .byte   $43                             ; 9526
        bit     $4342                           ; 9527
        bmi     L9574                           ; 952A
L952C:  .byte   $2C                             ; 952C
L952D:  sec                                     ; 952D
        and     $30FA,x                         ; 952E
        bit     $3042                           ; 9531
        ldy     $3F2C                           ; 9534
        .byte   $3B                             ; 9537
        bmi     L956C                           ; 9538
        .byte   $34                             ; 953A
        bit     $3E3B                           ; 953B
        and     $4F36,x                         ; 953E
        .byte   $FA                             ; 9541
        .byte   $7F                             ; 9542
        inc     $7B2C,x                         ; 9543
        sbc     $40,x                           ; 9546
        ora     $7B                             ; 9548
        .byte   $FA                             ; 954A
        ldy     $2C79,x                         ; 954B
        .byte   $8F                             ; 954E
        .byte   $FA                             ; 954F
        lsr     $3E                             ; 9550
L9552:  eor     ($41,x)                         ; 9552
        pha                                     ; 9554
        bit     $3130                           ; 9555
        rol     $4344,x                         ; 9558
        bit     $4FFF                           ; 955B
        .byte   $FA                             ; 955E
        txs                                     ; 955F
        bit     $3B30                           ; 9560
        lsr     $30                             ; 9563
        pha                                     ; 9565
        .byte   $42                             ; 9566
        bit     $3037                           ; 9567
        .byte   $42                             ; 956A
        .byte   $2C                             ; 956B
L956C:  .byte   $44                             ; 956C
        .byte   $42                             ; 956D
        adc     L7FFA,x                         ; 956E
        inc     $7B2C,x                         ; 9571
L9574:  sbc     $40,x                           ; 9574
        ora     $7B                             ; 9576
        .byte   $FA                             ; 9578
        sec                                     ; 9579
        and     $2C,x                           ; 957A
        lsr     $34                             ; 957C
        bit     $3E46                           ; 957E
        eor     ($3A,x)                         ; 9581
        bit     $3E43                           ; 9583
        rol     $34,x                           ; 9586
        cpy     $41                             ; 9588
        adc     $43FA,y                         ; 958A
        .byte   $9B                             ; 958D
        jmp     L2C42                           ; 958E

; ----------------------------------------------------------------------------
        and     $433E,x                         ; 9591
        .byte   $37                             ; 9594
        .byte   $A3                             ; 9595
        bit     $3E43                           ; 9596
        bit     $3431                           ; 9599
        .byte   $FA                             ; 959C
        .byte   $42                             ; 959D
        .byte   $32                             ; 959E
        sta     ($33,x)                         ; 959F
        bit     $353E                           ; 95A1
        .byte   $4F                             ; 95A4
        .byte   $FA                             ; 95A5
        .byte   $7F                             ; 95A6
        inc     $7B2C,x                         ; 95A7
        .byte   $3F                             ; 95AA
        .byte   $44                             ; 95AB
        .byte   $3A                             ; 95AC
        sec                                     ; 95AD
        and     $FA7B,x                         ; 95AE
        .byte   $AB                             ; 95B1
        bit     $7997                           ; 95B2
        bit     $4FFF                           ; 95B5
        .byte   $FA                             ; 95B8
        .byte   $7F                             ; 95B9
        inc     $7B2C,x                         ; 95BA
        .byte   $3C                             ; 95BD
        .byte   $44                             ; 95BE
        .byte   $42                             ; 95BF
        .byte   $43                             ; 95C0
        bmi     L95F8                           ; 95C1
        bmi     L9640                           ; 95C3
        .byte   $FA                             ; 95C5
        .byte   $AB                             ; 95C6
        bit     $7997                           ; 95C7
        bit     $4FFF                           ; 95CA
        .byte   $FA                             ; 95CD
        .byte   $7F                             ; 95CE
        inc     $7B2C,x                         ; 95CF
        .byte   $37                             ; 95D2
        bmi     L9617                           ; 95D3
        .byte   $42                             ; 95D5
        bmi     L9615                           ; 95D6
        .byte   $7B                             ; 95D8
        .byte   $FA                             ; 95D9
        .byte   $AB                             ; 95DA
        bit     $7997                           ; 95DB
        bit     $4FFF                           ; 95DE
        .byte   $FA                             ; 95E1
        .byte   $7F                             ; 95E2
        .byte   $FE                             ; 95E3
L95E4:  tsx                                     ; 95E4
        bit     $3E43                           ; 95E5
        rol     $2C3A,x                         ; 95E8
        bmi     L9633                           ; 95EB
        bmi     L9637                           ; 95ED
        .byte   $FA                             ; 95EF
        cpy     $2C                             ; 95F0
        sta     L842C,y                         ; 95F2
        and     $3A2C,x                         ; 95F5
L95F8:  .byte   $A3                             ; 95F8
        .byte   $FA                             ; 95F9
        and     $34,x                           ; 95FA
        .byte   $9F                             ; 95FC
        bmi     L963A                           ; 95FD
        bit     $2C82                           ; 95FF
        .byte   $37                             ; 9602
        .byte   $9F                             ; 9603
        bit     $3E35                           ; 9604
        .byte   $44                             ; 9607
        eor     ($FA,x)                         ; 9608
        ldy     $34,x                           ; 960A
        .byte   $42                             ; 960C
        .byte   $4F                             ; 960D
        .byte   $FA                             ; 960E
        .byte   $7F                             ; 960F
        pha                                     ; 9610
        .byte   $34                             ; 9611
        .byte   $42                             ; 9612
        .byte   $79                             ; 9613
        .byte   $2C                             ; 9614
L9615:  .byte   $D2                             ; 9615
        .byte   $41                             ; 9616
L9617:  bit     $FABF                           ; 9617
        ldy     $2C,x                           ; 961A
        ldy     $FA79,x                         ; 961C
        .byte   $43                             ; 961F
        rol     $4F3E,x                         ; 9620
        bit     $79FF                           ; 9623
        bit     $3835                           ; 9626
        and     $2C33,x                         ; 9629
        tsx                                     ; 962C
        .byte   $FA                             ; 962D
        .byte   $82                             ; 962E
        bit     $3433                           ; 962F
        .byte   $35                             ; 9632
L9633:  .byte   $34                             ; 9633
        bmi     L9679                           ; 9634
        .byte   $2C                             ; 9636
L9637:  .byte   $9C                             ; 9637
        .byte   $4F                             ; 9638
        .byte   $FA                             ; 9639
L963A:  .byte   $7F                             ; 963A
        .byte   $D2                             ; 963B
        jmp     L3441                           ; 963C

; ----------------------------------------------------------------------------
        .byte   $2C                             ; 963F
L9640:  cpy     $2C                             ; 9640
        rol     $3B3D,x                         ; 9642
        pha                                     ; 9645
        bit     $3E37                           ; 9646
        .byte   $3F                             ; 9649
        .byte   $34                             ; 964A
        bit     $3E35                           ; 964B
        eor     ($FA,x)                         ; 964E
        sty     $4F                             ; 9650
        .byte   $FA                             ; 9652
        .byte   $D2                             ; 9653
        bit     $3032                           ; 9654
        and     $332C,x                         ; 9657
        rol     $382C,x                         ; 965A
        .byte   $43                             ; 965D
        adc     L7FFA,x                         ; 965E
        and     $38,x                           ; 9661
        eor     ($42,x)                         ; 9663
        .byte   $43                             ; 9665
        adc     $432C,y                         ; 9666
        bmi     L96A6                           ; 9669
        .byte   $3A                             ; 966B
        bit     $3E43                           ; 966C
        bit     $2CC4                           ; 966F
        .byte   $CB                             ; 9672
        .byte   $FA                             ; 9673
        .byte   $3F                             ; 9674
        .byte   $34                             ; 9675
        rol     $3B3F,x                         ; 9676
L9679:  .byte   $34                             ; 9679
        .byte   $4F                             ; 967A
        bit     $413F                           ; 967B
        .byte   $34                             ; 967E
        .byte   $42                             ; 967F
        .byte   $42                             ; 9680
        bit     $2CC4                           ; 9681
        .byte   $42                             ; 9684
        .byte   $43                             ; 9685
        bmi     L96C9                           ; 9686
        .byte   $43                             ; 9688
        .byte   $FA                             ; 9689
        and     ($44),y                         ; 968A
        .byte   $43                             ; 968C
        .byte   $43                             ; 968D
        rol     $4F3D,x                         ; 968E
        bit     $3DC4                           ; 9691
        adc     $422C,y                         ; 9694
        .byte   $34                             ; 9697
        .byte   $3B                             ; 9698
        .byte   $34                             ; 9699
        .byte   $32                             ; 969A
        .byte   $43                             ; 969B
        .byte   $FA                             ; 969C
        eor     $3F42                           ; 969D
        .byte   $34                             ; 96A0
        bmi     L96DD                           ; 96A1
        jmp     L7FFA                           ; 96A3

; ----------------------------------------------------------------------------
L96A6:  .byte   $82                             ; 96A6
        bit     $3043                           ; 96A7
        .byte   $3B                             ; 96AA
        .byte   $3A                             ; 96AB
        bit     $3E43                           ; 96AC
        bit     $343F                           ; 96AF
        rol     $3B3F,x                         ; 96B2
        .byte   $34                             ; 96B5
        .byte   $FA                             ; 96B6
        dec     $C42C                           ; 96B7
        bit     $2C31                           ; 96BA
        and     ($44),y                         ; 96BD
        .byte   $43                             ; 96BF
        .byte   $43                             ; 96C0
        rol     $4F3D,x                         ; 96C1
        .byte   $FA                             ; 96C4
        and     $463E,x                         ; 96C5
        .byte   $79                             ; 96C8
L96C9:  bit     $4F97                           ; 96C9
        bit     $2C96                           ; 96CC
        .byte   $3B                             ; 96CF
        .byte   $44                             ; 96D0
L96D1:  .byte   $32                             ; 96D1
        .byte   $3A                             ; 96D2
        adc     L7FFA,x                         ; 96D3
        inc     $2C38,x                         ; 96D6
        .byte   $8F                             ; 96D9
        bit     $3431                           ; 96DA
L96DD:  .byte   $3B                             ; 96DD
        sec                                     ; 96DE
        .byte   $34                             ; 96DF
        eor     $34                             ; 96E0
        bit     $3746                           ; 96E2
        bmi     L972A                           ; 96E5
        bit     $FAD2                           ; 96E7
        .byte   $42                             ; 96EA
        bmi     L9725                           ; 96EB
        .byte   $33                             ; 96ED
        .byte   $4F                             ; 96EE
        bit     $2CD2                           ; 96EF
        sta     ($2C,x)                         ; 96F2
        cpy     $2C                             ; 96F4
        rol     $3B3D,x                         ; 96F6
        pha                                     ; 96F9
        .byte   $FA                             ; 96FA
        .byte   $37                             ; 96FB
        rol     $343F,x                         ; 96FC
        bit     $3E35                           ; 96FF
        eor     ($2C,x)                         ; 9702
        .byte   $44                             ; 9704
        .byte   $42                             ; 9705
        .byte   $4F                             ; 9706
        bit     $3E46                           ; 9707
        and     $434C,x                         ; 970A
        bit     $FAD2                           ; 970D
        .byte   $97                             ; 9710
        bit     $3E35                           ; 9711
        eor     ($2C,x)                         ; 9714
        sec                                     ; 9716
        .byte   $43                             ; 9717
        .byte   $7C                             ; 9718
        .byte   $FA                             ; 9719
        inc     L97FB,x                         ; 971A
        .byte   $FF                             ; 971D
        .byte   $97                             ; 971E
        .byte   $02                             ; 971F
        tya                                     ; 9720
        ora     $98                             ; 9721
        .byte   $0B                             ; 9723
        tya                                     ; 9724
L9725:  ora     ($98),y                         ; 9725
        clc                                     ; 9727
        tya                                     ; 9728
        .byte   $1D                             ; 9729
L972A:  tya                                     ; 972A
        rol     $98                             ; 972B
        rol     a                               ; 972D
        tya                                     ; 972E
        .byte   $30                             ; 972F
L9730:  tya                                     ; 9730
        .byte   $37                             ; 9731
        tya                                     ; 9732
        and     $4C98,x                         ; 9733
        tya                                     ; 9736
        bvc     L96D1                           ; 9737
        eor     $98,x                           ; 9739
        .byte   $5A                             ; 973B
        tya                                     ; 973C
        rts                                     ; 973D

; ----------------------------------------------------------------------------
        tya                                     ; 973E
        .byte   $67                             ; 973F
        tya                                     ; 9740
        adc     $7198                           ; 9741
        tya                                     ; 9744
        .byte   $7A                             ; 9745
        tya                                     ; 9746
        ror     L8298,x                         ; 9747
        tya                                     ; 974A
        sty     $98                             ; 974B
        dey                                     ; 974D
        tya                                     ; 974E
        sta     L8F98                           ; 974F
        tya                                     ; 9752
        .byte   $93                             ; 9753
        tya                                     ; 9754
        stx     $98,y                           ; 9755
        .byte   $9B                             ; 9757
        tya                                     ; 9758
        .byte   $9E                             ; 9759
        tya                                     ; 975A
        ldy     #$98                            ; 975B
        ldy     $98                             ; 975D
        tay                                     ; 975F
        tya                                     ; 9760
        ldy     $AF98                           ; 9761
        tya                                     ; 9764
        .byte   $B3                             ; 9765
        tya                                     ; 9766
        lda     $C198,y                         ; 9767
        tya                                     ; 976A
        cmp     $98                             ; 976B
        iny                                     ; 976D
        tya                                     ; 976E
        cmp     $D198                           ; 976F
        tya                                     ; 9772
        dec     $98,x                           ; 9773
        cld                                     ; 9775
        tya                                     ; 9776
        .byte   $DB                             ; 9777
        tya                                     ; 9778
        cpx     #$98                            ; 9779
        cpx     $98                             ; 977B
        nop                                     ; 977D
        tya                                     ; 977E
        inc     $F698                           ; 977F
        tya                                     ; 9782
        .byte   $FC                             ; 9783
        tya                                     ; 9784
        .byte   $04                             ; 9785
        sta     L990A,y                         ; 9786
        .byte   $0F                             ; 9789
        sta     L9913,y                         ; 978A
        clc                                     ; 978D
        sta     L991B,y                         ; 978E
        .byte   $22                             ; 9791
        sta     L992C,y                         ; 9792
        sec                                     ; 9795
        sta     L993C,y                         ; 9796
        eor     ($99,x)                         ; 9799
        .byte   $4B                             ; 979B
        sta     L9950,y                         ; 979C
        lsr     $99,x                           ; 979F
        eor     $5E99,y                         ; 97A1
        sta     L9961,y                         ; 97A4
        adc     $99                             ; 97A7
        adc     $7299                           ; 97A9
        sta     L997C,y                         ; 97AC
        .byte   $80                             ; 97AF
        sta     L9985,y                         ; 97B0
        .byte   $89                             ; 97B3
        sta     L998E,y                         ; 97B4
        .byte   $92                             ; 97B7
        sta     L9996,y                         ; 97B8
        sta     L9E99,y                         ; 97BB
        sta     L99A2,y                         ; 97BE
        lda     $99                             ; 97C1
        tax                                     ; 97C3
        sta     L99AF,y                         ; 97C4
        .byte   $B2                             ; 97C7
        sta     $00,y                           ; 97C8
        brk                                     ; 97CB
        brk                                     ; 97CC
        brk                                     ; 97CD
        brk                                     ; 97CE
        brk                                     ; 97CF
        brk                                     ; 97D0
        brk                                     ; 97D1
        brk                                     ; 97D2
        brk                                     ; 97D3
        brk                                     ; 97D4
        brk                                     ; 97D5
        brk                                     ; 97D6
        brk                                     ; 97D7
        brk                                     ; 97D8
        brk                                     ; 97D9
        brk                                     ; 97DA
        brk                                     ; 97DB
        brk                                     ; 97DC
        brk                                     ; 97DD
        brk                                     ; 97DE
        brk                                     ; 97DF
        brk                                     ; 97E0
        brk                                     ; 97E1
        brk                                     ; 97E2
        brk                                     ; 97E3
        brk                                     ; 97E4
        brk                                     ; 97E5
        brk                                     ; 97E6
        brk                                     ; 97E7
        brk                                     ; 97E8
        brk                                     ; 97E9
        brk                                     ; 97EA
        brk                                     ; 97EB
        brk                                     ; 97EC
        brk                                     ; 97ED
        brk                                     ; 97EE
        brk                                     ; 97EF
        brk                                     ; 97F0
        brk                                     ; 97F1
        brk                                     ; 97F2
        brk                                     ; 97F3
        brk                                     ; 97F4
        brk                                     ; 97F5
        brk                                     ; 97F6
        brk                                     ; 97F7
        brk                                     ; 97F8
        brk                                     ; 97F9
        brk                                     ; 97FA
L97FB:  bmi     L983D                           ; 97FB
        .byte   $44                             ; 97FD
        bcs     L9830                           ; 97FE
        eor     ($B4,x)                         ; 9800
        bmi     L9841                           ; 9802
        .byte   $B3                             ; 9804
        bmi     L9848                           ; 9805
        .byte   $3C                             ; 9807
        sec                                     ; 9808
        .byte   $34                             ; 9809
        .byte   $C2                             ; 980A
        bmi     L984E                           ; 980B
        bmi     L9840                           ; 980D
        sec                                     ; 980F
        bcs     L9842                           ; 9810
        .byte   $3B                             ; 9812
        bmi     L9850                           ; 9813
        bmi     L9858                           ; 9815
        .byte   $C3                             ; 9817
        bmi     L985B                           ; 9818
        .byte   $3C                             ; 981A
        rol     $30C1,x                         ; 981B
        .byte   $33                             ; 981E
        eor     $34                             ; 981F
        and     $4443,x                         ; 9821
        eor     ($B4,x)                         ; 9824
        and     ($3B),y                         ; 9826
        .byte   $44                             ; 9828
        ldy     $31,x                           ; 9829
        .byte   $34                             ; 982B
        pha                                     ; 982C
        rol     $B33D,x                         ; 982D
L9830:  .byte   $32                             ; 9830
        sec                                     ; 9831
        .byte   $3C                             ; 9832
        bmi     L9876                           ; 9833
        rol     $32BD,x                         ; 9835
        rol     $4144,x                         ; 9838
        .byte   $42                             ; 983B
        .byte   $B4                             ; 983C
L983D:  .byte   $32                             ; 983D
        .byte   $3E                             ; 983E
        .byte   $3D                             ; 983F
L9840:  .byte   $36                             ; 9840
L9841:  .byte   $41                             ; 9841
L9842:  bmi     L9887                           ; 9842
        .byte   $44                             ; 9844
        .byte   $3B                             ; 9845
        bmi     L988B                           ; 9846
L9848:  sec                                     ; 9848
        rol     $C23D,x                         ; 9849
        .byte   $33                             ; 984C
        .byte   $3E                             ; 984D
L984E:  .byte   $3B                             ; 984E
        .byte   $BB                             ; 984F
L9850:  .byte   $33                             ; 9850
        .byte   $34                             ; 9851
        eor     $38                             ; 9852
        .byte   $BB                             ; 9854
        .byte   $33                             ; 9855
        .byte   $3E                             ; 9856
        .byte   $3D                             ; 9857
L9858:  jmp     L34C3                           ; 9858

; ----------------------------------------------------------------------------
L985B:  and     $443E,x                         ; 985B
        rol     $B7,x                           ; 985E
        .byte   $34                             ; 9860
        .byte   $32                             ; 9861
        .byte   $3B                             ; 9862
        sec                                     ; 9863
        .byte   $3F                             ; 9864
        .byte   $42                             ; 9865
        ldy     $34,x                           ; 9866
        and     $3C34,x                         ; 9868
        sec                                     ; 986B
        ldy     $35,x                           ; 986C
        sec                                     ; 986E
        eor     ($B4,x)                         ; 986F
        and     $3E,x                           ; 9871
        eor     ($3C,x)                         ; 9873
        .byte   $30                             ; 9875
L9876:  .byte   $43                             ; 9876
        sec                                     ; 9877
        rol     $36BD,x                         ; 9878
        sec                                     ; 987B
        eor     $B4                             ; 987C
        .byte   $36                             ; 987E
L987F:  rol     $B33E,x                         ; 987F
        rol     $BE,x                           ; 9882
        rol     $3E,x                           ; 9884
        .byte   $41                             ; 9886
L9887:  bcs     L98BF                           ; 9887
        eor     ($34,x)                         ; 9889
L988B:  bmi     L9850                           ; 988B
        .byte   $37                             ; 988D
        ldy     $37,x                           ; 988E
        .byte   $34                             ; 9890
        eor     ($B4,x)                         ; 9891
        .byte   $37                             ; 9893
        sec                                     ; 9894
        ldy     $4437,x                         ; 9895
L9898:  .byte   $3C                             ; 9898
        bmi     L9858                           ; 9899
        sec                                     ; 989B
        jmp     L38BC                           ; 989C

; ----------------------------------------------------------------------------
        .byte   $C2                             ; 989F
        sec                                     ; 98A0
        rol     $CE3D,x                         ; 98A1
        sec                                     ; 98A4
        jmp     LB445                           ; 98A5

; ----------------------------------------------------------------------------
        sec                                     ; 98A8
        .byte   $42                             ; 98A9
        and     $B0,x                           ; 98AA
        sec                                     ; 98AC
        and     $39B6,x                         ; 98AD
        rol     $BD38,x                         ; 98B0
        .byte   $3B                             ; 98B3
        bmi     L98F2                           ; 98B4
        .byte   $3F                             ; 98B6
        jmp     L3BC2                           ; 98B7

; ----------------------------------------------------------------------------
        bmi     L98F9                           ; 98BA
        rol     $44,x                           ; 98BC
        .byte   $30                             ; 98BE
L98BF:  rol     $B4,x                           ; 98BF
        .byte   $3B                             ; 98C1
        sec                                     ; 98C2
        .byte   $3A                             ; 98C3
        ldy     $3B,x                           ; 98C4
        bmi     L987F                           ; 98C6
        .byte   $3B                             ; 98C8
        sec                                     ; 98C9
        rol     $37,x                           ; 98CA
L98CC:  .byte   $C3                             ; 98CC
        .byte   $3B                             ; 98CD
        sec                                     ; 98CE
        eor     $B4                             ; 98CF
        .byte   $3B                             ; 98D1
        .byte   $34                             ; 98D2
        .byte   $43                             ; 98D3
        jmp     L3CC2                           ; 98D4

; ----------------------------------------------------------------------------
        ldy     $3C,x                           ; 98D7
        bmi     L9898                           ; 98D9
        .byte   $3C                             ; 98DB
        bmi     L9914                           ; 98DC
        sec                                     ; 98DE
        .byte   $B2                             ; 98DF
        rol     $343F,x                         ; 98E0
        lda     $303F,x                         ; 98E3
        .byte   $3B                             ; 98E6
        bmi     L991B                           ; 98E7
        ldy     $3F,x                           ; 98E9
        .byte   $34                             ; 98EB
        .byte   $3A                             ; 98EC
        ldy     $3F,x                           ; 98ED
        bmi     L9933                           ; 98EF
        .byte   $42                             ; 98F1
L98F2:  lsr     $3E                             ; 98F2
        eor     ($B3,x)                         ; 98F4
        .byte   $3F                             ; 98F6
        .byte   $3B                             ; 98F7
        .byte   $34                             ; 98F8
L98F9:  .byte   $30                             ; 98F9
L98FA:  .byte   $42                             ; 98FA
        ldy     $3F,x                           ; 98FB
        eor     ($38,x)                         ; 98FD
        and     $3432,x                         ; 98FF
        .byte   $42                             ; 9902
        .byte   $C2                             ; 9903
        eor     ($44,x)                         ; 9904
        .byte   $3F                             ; 9906
        sec                                     ; 9907
        bmi     L98CC                           ; 9908
L990A:  .byte   $42                             ; 990A
        rol     $3D44,x                         ; 990B
        .byte   $B3                             ; 990E
        .byte   $42                             ; 990F
        sec                                     ; 9910
        rol     $B7,x                           ; 9911
L9913:  .byte   $42                             ; 9913
L9914:  bmi     L994E                           ; 9914
        and     $42C3,x                         ; 9916
        .byte   $3E                             ; 9919
        .byte   $BD                             ; 991A
L991B:  .byte   $42                             ; 991B
        bmi     L994F                           ; 991C
        bmi     L9961                           ; 991E
        rol     $42BD,x                         ; 9920
        bmi     L9960                           ; 9923
        bmi     L9963                           ; 9925
        bmi     L9966                           ; 9927
        .byte   $33                             ; 9929
        .byte   $34                             ; 992A
        .byte   $C1                             ; 992B
L992C:  .byte   $42                             ; 992C
        .byte   $32                             ; 992D
        .byte   $37                             ; 992E
        .byte   $34                             ; 992F
L9930:  .byte   $37                             ; 9930
        .byte   $34                             ; 9931
        .byte   $41                             ; 9932
L9933:  bmi     L997E                           ; 9933
        bmi     L996A                           ; 9935
        ldy     $42,x                           ; 9937
        sec                                     ; 9939
        .byte   $33                             ; 993A
        .byte   $B4                             ; 993B
L993C:  .byte   $42                             ; 993C
        .byte   $43                             ; 993D
        sec                                     ; 993E
        .byte   $32                             ; 993F
        tsx                                     ; 9940
        .byte   $42                             ; 9941
        lsr     $34                             ; 9942
        .byte   $34                             ; 9944
        .byte   $43                             ; 9945
        .byte   $37                             ; 9946
        .byte   $34                             ; 9947
        bmi     L998B                           ; 9948
        .byte   $C3                             ; 994A
        .byte   $42                             ; 994B
        .byte   $3E                             ; 994C
        .byte   $3B                             ; 994D
L994E:  .byte   $30                             ; 994E
L994F:  .byte   $C1                             ; 994F
L9950:  .byte   $42                             ; 9950
        .byte   $3F                             ; 9951
        sec                                     ; 9952
        eor     ($38,x)                         ; 9953
        .byte   $C3                             ; 9955
        .byte   $42                             ; 9956
        .byte   $37                             ; 9957
        ldy     $42,x                           ; 9958
        .byte   $37                             ; 995A
        rol     $C33E,x                         ; 995B
        .byte   $43                             ; 995E
        .byte   $37                             ; 995F
L9960:  .byte   $B4                             ; 9960
L9961:  .byte   $43                             ; 9961
        .byte   $37                             ; 9962
L9963:  sec                                     ; 9963
        .byte   $C2                             ; 9964
        .byte   $43                             ; 9965
L9966:  eor     ($30,x)                         ; 9966
L9968:  .byte   $3D                             ; 9968
        .byte   $42                             ; 9969
L996A:  .byte   $3B                             ; 996A
        bmi     L9930                           ; 996B
        .byte   $43                             ; 996D
        .byte   $37                             ; 996E
        .byte   $34                             ; 996F
        eor     ($B4,x)                         ; 9970
        .byte   $43                             ; 9972
        .byte   $34                             ; 9973
        eor     ($41,x)                         ; 9974
        sec                                     ; 9976
        and     $48,x                           ; 9977
        sec                                     ; 9979
        .byte   $3D                             ; 997A
        .byte   $B6                             ; 997B
L997C:  .byte   $43                             ; 997C
        sec                                     ; 997D
L997E:  .byte   $3C                             ; 997E
        ldy     $43,x                           ; 997F
        .byte   $37                             ; 9981
        bmi     L99C1                           ; 9982
        tsx                                     ; 9984
L9985:  .byte   $43                             ; 9985
        rol     $BD46,x                         ; 9986
        lsr     $3E                             ; 9989
L998B:  eor     ($3B,x)                         ; 998B
        .byte   $B3                             ; 998D
L998E:  lsr     $38                             ; 998E
        .byte   $3B                             ; 9990
        .byte   $BB                             ; 9991
        lsr     $38                             ; 9992
        .byte   $43                             ; 9994
        .byte   $B7                             ; 9995
L9996:  lsr     $37                             ; 9996
        ldx     $3E46,y                         ; 9998
        .byte   $44                             ; 999B
        .byte   $3B                             ; 999C
        .byte   $B3                             ; 999D
        lsr     $38                             ; 999E
        .byte   $42                             ; 99A0
        .byte   $B4                             ; 99A1
L99A2:  pha                                     ; 99A2
        rol     $48C4,x                         ; 99A3
        .byte   $34                             ; 99A6
        bmi     L99EA                           ; 99A7
        .byte   $C2                             ; 99A9
        pha                                     ; 99AA
        rol     $3D44,x                         ; 99AB
        .byte   $B6                             ; 99AE
L99AF:  adc     $FD7D,x                         ; 99AF
        .byte   $33                             ; 99B2
        .byte   $34                             ; 99B3
        .byte   $3C                             ; 99B4
        rol     $D7BD,x                         ; 99B5
        sta     L99DF,y                         ; 99B8
        inx                                     ; 99BB
        sta     L99F6,y                         ; 99BC
        .byte   $1A                             ; 99BF
        txs                                     ; 99C0
L99C1:  and     $619A,x                         ; 99C1
        txs                                     ; 99C4
L99C5:  .byte   $87                             ; 99C5
        txs                                     ; 99C6
        inc     $0F9A                           ; 99C7
        .byte   $9B                             ; 99CA
        bvc     L9968                           ; 99CB
        .byte   $64                             ; 99CD
        .byte   $9B                             ; 99CE
        adc     $9B                             ; 99CF
        .byte   $AF                             ; 99D1
        .byte   $9B                             ; 99D2
        sec                                     ; 99D3
        .byte   $9C                             ; 99D4
        and     $2C9C,y                         ; 99D5
        bit     $2C2C                           ; 99D8
        bit     $2C2C                           ; 99DB
        .byte   $AC                             ; 99DE
L99DF:  .byte   $3A                             ; 99DF
        .byte   $34                             ; 99E0
        iny                                     ; 99E1
        bmi     L9A20                           ; 99E2
        .byte   $44                             ; 99E4
        .byte   $3B                             ; 99E5
        .byte   $34                             ; 99E6
        .byte   $C3                             ; 99E7
        eor     ($4F,x)                         ; 99E8
L99EA:  bmi     L9A2D                           ; 99EA
        .byte   $3C                             ; 99EC
        rol     $3BC1,x                         ; 99ED
        .byte   $4F                             ; 99F0
        bmi     L9A34                           ; 99F1
        .byte   $3C                             ; 99F3
L99F4:  .byte   $3E                             ; 99F4
        .byte   $C1                             ; 99F5
L99F6:  .byte   $37                             ; 99F6
        rol     $483B,x                         ; 99F7
L99FA:  eor     ($3E,x)                         ; 99FA
        and     ($B4),y                         ; 99FC
        .byte   $3C                             ; 99FE
        .byte   $4F                             ; 99FF
        and     ($3E),y                         ; 9A00
        rol     $C243,x                         ; 9A02
        .byte   $3C                             ; 9A05
        .byte   $4F                             ; 9A06
        .byte   $42                             ; 9A07
        .byte   $37                             ; 9A08
        sec                                     ; 9A09
        .byte   $34                             ; 9A0A
        .byte   $3B                             ; 9A0B
        .byte   $B3                             ; 9A0C
        and     ($41),y                         ; 9A0D
        .byte   $34                             ; 9A0F
        bmi     L99C5                           ; 9A10
        .byte   $3C                             ; 9A12
        bmi     L9A57                           ; 9A13
        .byte   $37                             ; 9A15
        eor     ($3E,x)                         ; 9A16
        rol     $ACB1,x                         ; 9A18
        eor     ($3E,x)                         ; 9A1B
        .byte   $B3                             ; 9A1D
        and     $3B,x                           ; 9A1E
L9A20:  bmi     L9A5E                           ; 9A20
        ldy     $42,x                           ; 9A22
        .byte   $43                             ; 9A24
        bmi     L9A68                           ; 9A25
        .byte   $33                             ; 9A27
        .byte   $44                             ; 9A28
        .byte   $42                             ; 9A29
        .byte   $C3                             ; 9A2A
        .byte   $32                             ; 9A2B
L9A2C:  sec                                     ; 9A2C
L9A2D:  .byte   $3C                             ; 9A2D
        .byte   $30                             ; 9A2E
L9A2F:  eor     ($3E,x)                         ; 9A2F
        lda     $4132,x                         ; 9A31
L9A34:  pha                                     ; 9A34
        .byte   $42                             ; 9A35
        .byte   $43                             ; 9A36
        bmi     L99F4                           ; 9A37
        sec                                     ; 9A39
        .byte   $42                             ; 9A3A
        and     $B0,x                           ; 9A3B
L9A3D:  .byte   $37                             ; 9A3D
        bmi     L9A7C                           ; 9A3E
        .byte   $3C                             ; 9A40
        .byte   $34                             ; 9A41
        cmp     ($41,x)                         ; 9A42
        .byte   $4F                             ; 9A44
        .byte   $42                             ; 9A45
L9A46:  .byte   $34                             ; 9A46
        .byte   $34                             ; 9A47
        .byte   $B3                             ; 9A48
        .byte   $32                             ; 9A49
        bmi     L9A8D                           ; 9A4A
        .byte   $3F                             ; 9A4C
        .byte   $34                             ; 9A4D
        .byte   $C3                             ; 9A4E
        .byte   $37                             ; 9A4F
        rol     $BD41,x                         ; 9A50
        rol     $413F,x                         ; 9A53
        sec                                     ; 9A56
L9A57:  lda     $3841,x                         ; 9A57
        and     $ACB6,x                         ; 9A5A
        .byte   $AC                             ; 9A5D
L9A5E:  .byte   $3C                             ; 9A5E
        bmi     L9A20                           ; 9A5F
        ldy     $4642                           ; 9A61
        rol     $B341,x                         ; 9A64
        .byte   $42                             ; 9A67
L9A68:  sec                                     ; 9A68
        .byte   $3C                             ; 9A69
        sec                                     ; 9A6A
        .byte   $43                             ; 9A6B
        bmi     L9A2F                           ; 9A6C
        .byte   $33                             ; 9A6E
        eor     ($30,x)                         ; 9A6F
L9A71:  rol     $3E,x                           ; 9A71
        rol     $3ABD,x                         ; 9A73
        bmi     L9ABA                           ; 9A76
        .byte   $37                             ; 9A78
        sec                                     ; 9A79
        .byte   $BC                             ; 9A7A
        .byte   $41                             ; 9A7B
L9A7C:  rol     $4342,x                         ; 9A7C
        bmi     L9A3D                           ; 9A7F
        .byte   $3B                             ; 9A81
        .byte   $34                             ; 9A82
        rol     $34,x                           ; 9A83
        and     $31B3,x                         ; 9A85
        rol     $433B,x                         ; 9A88
        .byte   $43                             ; 9A8B
        .byte   $3E                             ; 9A8C
L9A8D:  eor     ($81,x)                         ; 9A8D
        and     ($3E),y                         ; 9A8F
        .byte   $3B                             ; 9A91
        .byte   $43                             ; 9A92
        .byte   $43                             ; 9A93
        rol     L8241,x                         ; 9A94
        and     ($3E),y                         ; 9A97
        .byte   $3B                             ; 9A99
        .byte   $43                             ; 9A9A
        .byte   $43                             ; 9A9B
        rol     L8341,x                         ; 9A9C
        and     $3B,x                           ; 9A9F
        bmi     L9ADF                           ; 9AA1
        rol     L813B,x                         ; 9AA3
        and     $3B,x                           ; 9AA6
        bmi     L9AE6                           ; 9AA8
        .byte   $3E                             ; 9AAA
        .byte   $3B                             ; 9AAB
L9AAC:  .byte   $82                             ; 9AAC
        and     $3B,x                           ; 9AAD
        bmi     L9AED                           ; 9AAF
        rol     L833B,x                         ; 9AB1
        .byte   $3F                             ; 9AB4
        bmi     L9AF3                           ; 9AB5
        .byte   $3F                             ; 9AB7
        .byte   $3E                             ; 9AB8
        .byte   $BE                             ; 9AB9
L9ABA:  .byte   $3C                             ; 9ABA
        bmi     L9AFE                           ; 9ABB
        sec                                     ; 9ABD
        .byte   $43                             ; 9ABE
        bcs     L9B02                           ; 9ABF
        .byte   $34                             ; 9AC1
        .byte   $42                             ; 9AC2
        .byte   $34                             ; 9AC3
        bmi     L9B01                           ; 9AC4
        ldx     L3445,y                         ; 9AC6
        .byte   $3B                             ; 9AC9
        eor     $34                             ; 9ACA
        cmp     ($32,x)                         ; 9ACC
        rol     $3141,x                         ; 9ACE
        rol     $BA32,x                         ; 9AD1
        .byte   $42                             ; 9AD4
        .byte   $37                             ; 9AD5
        eor     ($38,x)                         ; 9AD6
        and     $32BA,x                         ; 9AD8
        bmi     L9B1E                           ; 9ADB
        bmi     L9B10                           ; 9ADD
L9ADF:  bcs     L9B14                           ; 9ADF
        .byte   $34                             ; 9AE1
        and     $34,x                           ; 9AE2
        .byte   $3D                             ; 9AE4
        .byte   $34                             ; 9AE5
L9AE6:  ldy     $41,x                           ; 9AE6
        bmi     L9B26                           ; 9AE8
        sec                                     ; 9AEA
        .byte   $3F                             ; 9AEB
        .byte   $30                             ; 9AEC
L9AED:  .byte   $C2                             ; 9AED
        .byte   $3B                             ; 9AEE
        sec                                     ; 9AEF
        and     ($32),y                         ; 9AF0
        .byte   $3E                             ; 9AF2
L9AF3:  ldy     $3E3C,x                         ; 9AF3
        and     $3234,x                         ; 9AF6
        rol     $3CBC,x                         ; 9AF9
        .byte   $3E                             ; 9AFC
        .byte   $42                             ; 9AFD
L9AFE:  .byte   $32                             ; 9AFE
        .byte   $3E                             ; 9AFF
        .byte   $BC                             ; 9B00
L9B01:  .byte   $41                             ; 9B01
L9B02:  bmi     L9B3C                           ; 9B02
        and     $3E32,x                         ; 9B04
        ldy     $3F42,x                         ; 9B07
        eor     ($38,x)                         ; 9B0A
        .byte   $32                             ; 9B0C
L9B0D:  rol     $32BC,x                         ; 9B0D
L9B10:  rol     $3E41,x                         ; 9B10
        .byte   $3D                             ; 9B13
L9B14:  pha                                     ; 9B14
        bcs     L9B59                           ; 9B15
        .byte   $44                             ; 9B17
        .byte   $3F                             ; 9B18
        sec                                     ; 9B19
        .byte   $32                             ; 9B1A
        bcs     L9B53                           ; 9B1B
        .byte   $44                             ; 9B1D
L9B1E:  and     $3C2C,x                         ; 9B1E
L9B21:  .byte   $34                             ; 9B21
        .byte   $32                             ; 9B22
        bcs     L9B64                           ; 9B23
        .byte   $44                             ; 9B25
L9B26:  .byte   $3A                             ; 9B26
        sec                                     ; 9B27
        lda     $4436,x                         ; 9B28
        and     ($38),y                         ; 9B2B
        and     ($B8),y                         ; 9B2D
        .byte   $3C                             ; 9B2F
        .byte   $44                             ; 9B30
        .byte   $42                             ; 9B31
        .byte   $43                             ; 9B32
        bmi     L9B6A                           ; 9B33
        bcs     L9B6B                           ; 9B35
        .byte   $3F                             ; 9B37
        sec                                     ; 9B38
        lda     $3041,x                         ; 9B39
L9B3C:  sec                                     ; 9B3C
        and     $3AC8,x                         ; 9B3D
        .byte   $34                             ; 9B40
        and     ($30),y                         ; 9B41
L9B43:  and     ($C4),y                         ; 9B43
        .byte   $35                             ; 9B45
L9B46:  bmi     L9B89                           ; 9B46
        .byte   $44                             ; 9B48
        tsx                                     ; 9B49
        .byte   $37                             ; 9B4A
        bmi     L9B8F                           ; 9B4B
        .byte   $42                             ; 9B4D
        bmi     L9B0D                           ; 9B4E
        and     $38,x                           ; 9B50
        .byte   $36                             ; 9B52
L9B53:  .byte   $37                             ; 9B53
        .byte   $43                             ; 9B54
        .byte   $34                             ; 9B55
        cmp     ($42,x)                         ; 9B56
        .byte   $30                             ; 9B58
L9B59:  sec                                     ; 9B59
        and     $3CC3,x                         ; 9B5A
        bmi     L9B95                           ; 9B5D
        sec                                     ; 9B5F
        .byte   $32                             ; 9B60
        sec                                     ; 9B61
        bmi     L9B21                           ; 9B62
L9B64:  ldy     $4832                           ; 9B64
        rol     $3D,x                           ; 9B67
        .byte   $44                             ; 9B69
L9B6A:  .byte   $C2                             ; 9B6A
L9B6B:  .byte   $3B                             ; 9B6B
        sec                                     ; 9B6C
        .byte   $31                             ; 9B6D
L9B6E:  eor     ($B0,x)                         ; 9B6E
        bmi     *+67                            ; 9B70
        sec                                     ; 9B72
        .byte   $34                             ; 9B73
        .byte   $C2                             ; 9B74
        .byte   $42                             ; 9B75
        sec                                     ; 9B76
L9B77:  eor     ($38,x)                         ; 9B77
        .byte   $44                             ; 9B79
        .byte   $C2                             ; 9B7A
        .byte   $3A                             ; 9B7B
        bmi     L9BB6                           ; 9B7C
        .byte   $43                             ; 9B7E
        .byte   $3E                             ; 9B7F
        .byte   $C2                             ; 9B80
L9B81:  .byte   $33                             ; 9B81
        eor     ($30,x)                         ; 9B82
        rol     $3E,x                           ; 9B84
L9B86:  lda     $3B30,x                         ; 9B86
L9B89:  bmi     L9BC6                           ; 9B89
        bmi     L9BCE                           ; 9B8B
        .byte   $C3                             ; 9B8D
        .byte   $3C                             ; 9B8E
L9B8F:  rol     $343D,x                         ; 9B8F
        .byte   $32                             ; 9B92
        .byte   $3E                             ; 9B93
        .byte   $BC                             ; 9B94
L9B95:  eor     ($30,x)                         ; 9B95
        sec                                     ; 9B97
        and     $3E32,x                         ; 9B98
        ldy     $3F42,x                         ; 9B9B
        eor     ($38,x)                         ; 9B9E
        .byte   $32                             ; 9BA0
L9BA1:  rol     $3CBC,x                         ; 9BA1
        rol     $3242,x                         ; 9BA4
        rol     $3BBC,x                         ; 9BA7
        sec                                     ; 9BAA
        and     ($32),y                         ; 9BAB
        rol     $31BC,x                         ; 9BAD
        bmi     L9BF4                           ; 9BB0
        sec                                     ; 9BB2
        .byte   $33                             ; 9BB3
        .byte   $3E                             ; 9BB4
        .byte   $2C                             ; 9BB5
L9BB6:  .byte   $42                             ; 9BB6
        rti                                     ; 9BB7

; ----------------------------------------------------------------------------
        .byte   $44                             ; 9BB8
        bmi     L9B6E                           ; 9BB9
        bmi     L9BF5                           ; 9BBB
        eor     ($2C,x)                         ; 9BBD
        .byte   $42                             ; 9BBF
        rti                                     ; 9BC0

; ----------------------------------------------------------------------------
        .byte   $44                             ; 9BC1
        bmi     L9B77                           ; 9BC2
        and     $38,x                           ; 9BC4
L9BC6:  eor     ($34,x)                         ; 9BC6
        bit     $4042                           ; 9BC8
L9BCB:  .byte   $44                             ; 9BCB
        bmi     L9B81                           ; 9BCC
L9BCE:  rol     $38,x                           ; 9BCE
        .byte   $3B                             ; 9BD0
        bmi     L9C15                           ; 9BD1
        bit     L3441                           ; 9BD3
        rol     $38,x                           ; 9BD6
        .byte   $3C                             ; 9BD8
        .byte   $34                             ; 9BD9
        and     $3CC3,x                         ; 9BDA
        bmi     L9C15                           ; 9BDD
        .byte   $3C                             ; 9BDF
        bmi     L9C0E                           ; 9BE0
        eor     ($34,x)                         ; 9BE2
        rol     $38,x                           ; 9BE4
        .byte   $3C                             ; 9BE6
        .byte   $34                             ; 9BE7
        and     $49C3,x                         ; 9BE8
        rol     $3E33,x                         ; 9BEB
        eor     ($2C,x)                         ; 9BEE
        .byte   $33                             ; 9BF0
        sec                                     ; 9BF1
        eor     $38                             ; 9BF2
L9BF4:  .byte   $42                             ; 9BF4
L9BF5:  sec                                     ; 9BF5
        rol     $30BD,x                         ; 9BF6
        .byte   $3C                             ; 9BF9
        bmi     L9C3D                           ; 9BFA
        sec                                     ; 9BFC
        .byte   $34                             ; 9BFD
        .byte   $C2                             ; 9BFE
        .byte   $32                             ; 9BFF
        rol     $4241,x                         ; 9C00
        bcs     L9C44                           ; 9C03
        bmi     L9C44                           ; 9C05
        .byte   $33                             ; 9C07
        bmi     L9C4B                           ; 9C08
        ldy     $4832,x                         ; 9C0A
        .byte   $43                             ; 9C0D
L9C0E:  eor     ($3E,x)                         ; 9C0E
        lda     $373F,x                         ; 9C10
        bmi     L9C56                           ; 9C13
L9C15:  pha                                     ; 9C15
        bmi     L9BCB                           ; 9C16
        eor     ($3E,x)                         ; 9C18
        .byte   $3C                             ; 9C1A
        .byte   $42                             ; 9C1B
        bmi     L9C5F                           ; 9C1C
        lda     ($46),y                         ; 9C1E
        bmi     L9C6B                           ; 9C20
        bmi     L9C65                           ; 9C22
        lda     $3036,x                         ; 9C24
        eor     #$34                            ; 9C27
        sec                                     ; 9C29
        .byte   $BB                             ; 9C2A
        eor     ($30,x)                         ; 9C2B
        eor     #$30                            ; 9C2D
        .byte   $3B                             ; 9C2F
        .byte   $34                             ; 9C30
        ldx     $343C,y                         ; 9C31
        rol     $30,x                           ; 9C34
        eor     ($BB,x)                         ; 9C36
        ldy     L9AAC                           ; 9C38
        .byte   $9C                             ; 9C3B
        .byte   $63                             ; 9C3C
L9C3D:  jsr     L0818                           ; 9C3D
        cmp     $9C,x                           ; 9C40
        .byte   $8D                             ; 9C42
        .byte   $21                             ; 9C43
L9C44:  ora     $2209                           ; 9C44
        sta     $218D,x                         ; 9C47
        .byte   $0F                             ; 9C4A
L9C4B:  ora     #$5D                            ; 9C4B
        sta     $218D,x                         ; 9C4D
        ora     $B707                           ; 9C50
        sta     $218D,x                         ; 9C53
L9C56:  ora     $B706                           ; 9C56
        sta     $218D,x                         ; 9C59
        ora     $1908                           ; 9C5C
L9C5F:  .byte   $9E                             ; 9C5F
        dex                                     ; 9C60
        jsr     L030F                           ; 9C61
        .byte   $3F                             ; 9C64
L9C65:  .byte   $9E                             ; 9C65
        sta     $0D21                           ; 9C66
        .byte   $07                             ; 9C69
        tsx                                     ; 9C6A
L9C6B:  .byte   $9E                             ; 9C6B
        sta     $0D21                           ; 9C6C
        .byte   $07                             ; 9C6F
        .byte   $0B                             ; 9C70
        .byte   $9F                             ; 9C71
        .byte   $6F                             ; 9C72
        jsr     L0E0D                           ; 9C73
        .byte   $6F                             ; 9C76
        .byte   $9F                             ; 9C77
        sta     $0D21                           ; 9C78
        .byte   $07                             ; 9C7B
        .byte   $9B                             ; 9C7C
        .byte   $9F                             ; 9C7D
        lda     ($21,x)                         ; 9C7E
        php                                     ; 9C80
        php                                     ; 9C81
        cpy     $A19F                           ; 9C82
        and     ($1D,x)                         ; 9C85
        php                                     ; 9C87
        eor     $A0                             ; 9C88
        sta     $0F21                           ; 9C8A
        php                                     ; 9C8D
        .byte   $9C                             ; 9C8E
        ldy     #$8D                            ; 9C8F
        and     ($0D,x)                         ; 9C91
        php                                     ; 9C93
        txs                                     ; 9C94
        .byte   $9C                             ; 9C95
        .byte   $A3                             ; 9C96
        and     ($18,x)                         ; 9C97
        php                                     ; 9C99
        stx     $1AF8                           ; 9C9A
        sty     $FB9E                           ; 9C9D
        sta     $1AF8                           ; 9CA0
        bit     $FD8D                           ; 9CA3
        sta     $1AF8                           ; 9CA6
        bit     $FB8D                           ; 9CA9
        sta     $1AF8                           ; 9CAC
        bit     $FD8D                           ; 9CAF
L9CB2:  sta     $1AF8                           ; 9CB2
        bit     $FB8D                           ; 9CB5
        sta     $1AF8                           ; 9CB8
        bit     $FD8D                           ; 9CBB
        sta     $1AF8                           ; 9CBE
        bit     $FB8D                           ; 9CC1
        sta     $1AF8                           ; 9CC4
        bit     $FD8D                           ; 9CC7
        .byte   $8F                             ; 9CCA
        sed                                     ; 9CCB
        .byte   $1A                             ; 9CCC
        sty     $FB9F                           ; 9CCD
        sed                                     ; 9CD0
        .byte   $1C                             ; 9CD1
        bit     $FEFD                           ; 9CD2
        stx     $0FF8                           ; 9CD5
        sty     $FB9E                           ; 9CD8
        sta     $422C                           ; 9CDB
        .byte   $37                             ; 9CDE
        rol     $F83F,x                         ; 9CDF
        asl     a                               ; 9CE2
        bit     $FD8D                           ; 9CE3
L9CE6:  sta     $0FF8                           ; 9CE6
        bit     $FB8D                           ; 9CE9
        sta     $3B2C                           ; 9CEC
        rol     $3D30,x                         ; 9CEF
        sed                                     ; 9CF2
        asl     a                               ; 9CF3
        bit     $FD8D                           ; 9CF4
        sta     $0FF8                           ; 9CF7
        bit     $FB8D                           ; 9CFA
        sta     $412C                           ; 9CFD
        .byte   $34                             ; 9D00
        .byte   $3F                             ; 9D01
        bmi     L9D4C                           ; 9D02
        sed                                     ; 9D04
        ora     #$2C                            ; 9D05
        sta     L8DFD                           ; 9D07
        sed                                     ; 9D0A
        .byte   $0F                             ; 9D0B
        bit     $FB8D                           ; 9D0C
        sta     $3B2C                           ; 9D0F
        .byte   $34                             ; 9D12
        bmi     L9D5A                           ; 9D13
        .byte   $34                             ; 9D15
        sed                                     ; 9D16
        ora     #$2C                            ; 9D17
        sta     L8FFD                           ; 9D19
        sed                                     ; 9D1C
        .byte   $0F                             ; 9D1D
        sty     $FD9F                           ; 9D1E
        inc     $F88E,x                         ; 9D21
        bpl     L9CB2                           ; 9D24
        .byte   $9E                             ; 9D26
        .byte   $FB                             ; 9D27
        sta     $F62C                           ; 9D28
        rti                                     ; 9D2B

; ----------------------------------------------------------------------------
        ora     $8D                             ; 9D2C
        sbc     $F88D,x                         ; 9D2E
        bpl     L9D5F                           ; 9D31
        sta     L8DFB                           ; 9D33
        bit     $41F6                           ; 9D36
        ora     $8D                             ; 9D39
        sbc     $F88D,x                         ; 9D3B
        bpl     L9D6C                           ; 9D3E
        sta     L8DFB                           ; 9D40
        bit     $42F6                           ; 9D43
        ora     $8D                             ; 9D46
        sbc     $F88D,x                         ; 9D48
        .byte   $10                             ; 9D4B
L9D4C:  bit     $FB8D                           ; 9D4C
        sta     $F62C                           ; 9D4F
        .byte   $43                             ; 9D52
        ora     $8D                             ; 9D53
        sbc     $F88F,x                         ; 9D55
        bpl     L9CE6                           ; 9D58
L9D5A:  .byte   $9F                             ; 9D5A
        sbc     L8EFE,x                         ; 9D5B
        sed                                     ; 9D5E
L9D5F:  .byte   $0F                             ; 9D5F
        sty     $FB9E                           ; 9D60
        sta     $482C                           ; 9D63
        .byte   $34                             ; 9D66
        .byte   $42                             ; 9D67
        sed                                     ; 9D68
        .byte   $0B                             ; 9D69
        .byte   $2C                             ; 9D6A
        .byte   $8D                             ; 9D6B
L9D6C:  sbc     $F88D,x                         ; 9D6C
        .byte   $0F                             ; 9D6F
        bit     $FB8D                           ; 9D70
        sta     $332C                           ; 9D73
        sec                                     ; 9D76
        .byte   $42                             ; 9D77
        .byte   $32                             ; 9D78
        rol     $3D44,x                         ; 9D79
        .byte   $43                             ; 9D7C
        .byte   $4F                             ; 9D7D
        sed                                     ; 9D7E
        ora     $2C                             ; 9D7F
        sta     L8DFD                           ; 9D81
        sed                                     ; 9D84
        .byte   $0F                             ; 9D85
        bit     $FB8D                           ; 9D86
        sta     $3D2C                           ; 9D89
        rol     $2C4F,x                         ; 9D8C
        sec                                     ; 9D8F
        bit     $3E33                           ; 9D90
        and     $434C,x                         ; 9D93
        sed                                     ; 9D96
        .byte   $03                             ; 9D97
        bit     $FD8D                           ; 9D98
        sta     $0FF8                           ; 9D9B
        bit     $FB8D                           ; 9D9E
        sta     $462C                           ; 9DA1
        bmi     L9DE3                           ; 9DA4
        .byte   $43                             ; 9DA6
        bit     $4338                           ; 9DA7
        .byte   $4F                             ; 9DAA
        sed                                     ; 9DAB
        asl     $2C                             ; 9DAC
        sta     L8FFB                           ; 9DAE
        sed                                     ; 9DB1
        .byte   $0F                             ; 9DB2
        sty     $FD9F                           ; 9DB3
        inc     $F88E,x                         ; 9DB6
        .byte   $0F                             ; 9DB9
        sty     $FE9E                           ; 9DBA
        .byte   $8F                             ; 9DBD
        sed                                     ; 9DBE
        .byte   $0F                             ; 9DBF
        sty     $FE9F                           ; 9DC0
        sta     $02F8                           ; 9DC3
        bit     a:$05                           ; 9DC6
        bit     $4441                           ; 9DC9
        .byte   $3F                             ; 9DCC
        sec                                     ; 9DCD
        bmi     L9E12                           ; 9DCE
        sed                                     ; 9DD0
        .byte   $04                             ; 9DD1
        bit     $FE8D                           ; 9DD2
        sta     $0FF8                           ; 9DD5
        bit     $FE8D                           ; 9DD8
        sta     $012C                           ; 9DDB
        brk                                     ; 9DDE
        brk                                     ; 9DDF
        bit     $4441                           ; 9DE0
L9DE3:  .byte   $3F                             ; 9DE3
        sec                                     ; 9DE4
        bmi     L9E29                           ; 9DE5
        sed                                     ; 9DE7
        .byte   $04                             ; 9DE8
        bit     $FE8D                           ; 9DE9
        sta     $0FF8                           ; 9DEC
        bit     $FE8D                           ; 9DEF
        sta     $012C                           ; 9DF2
        ora     $00                             ; 9DF5
        bit     $4441                           ; 9DF7
        .byte   $3F                             ; 9DFA
        sec                                     ; 9DFB
        bmi     L9E40                           ; 9DFC
        sed                                     ; 9DFE
        .byte   $04                             ; 9DFF
        bit     $FE8D                           ; 9E00
        sta     $0FF8                           ; 9E03
        bit     $FE8D                           ; 9E06
        sta     $412C                           ; 9E09
        .byte   $34                             ; 9E0C
        .byte   $3F                             ; 9E0D
        bmi     L9E58                           ; 9E0E
        .byte   $2C                             ; 9E10
        .byte   $30                             ; 9E11
L9E12:  .byte   $3B                             ; 9E12
        .byte   $3B                             ; 9E13
        sed                                     ; 9E14
        ora     $2C                             ; 9E15
        sta     $37FE                           ; 9E17
        bmi     L9E61                           ; 9E1A
        .byte   $34                             ; 9E1C
        bit     L89F1                           ; 9E1D
        brk                                     ; 9E20
        bit     $4441                           ; 9E21
        .byte   $3F                             ; 9E24
        sec                                     ; 9E25
        bmi     L9E6A                           ; 9E26
        .byte   $FD                             ; 9E28
L9E29:  sed                                     ; 9E29
        bpl     L9E58                           ; 9E2A
L9E2C:  sbc     $3433,x                         ; 9E2C
        and     ($43),y                         ; 9E2F
        bit     $D9F1                           ; 9E31
        .byte   $03                             ; 9E34
        bit     $4441                           ; 9E35
        .byte   $3F                             ; 9E38
        sec                                     ; 9E39
        bmi     L9E7E                           ; 9E3A
        sbc     $FE7F,x                         ; 9E3C
        .byte   $8E                             ; 9E3F
L9E40:  sed                                     ; 9E40
        .byte   $0F                             ; 9E41
        sty     $FB9E                           ; 9E42
        sta     $312C                           ; 9E45
        eor     ($38,x)                         ; 9E48
        and     $3836,x                         ; 9E4A
        and     $2C36,x                         ; 9E4D
        .byte   $3B                             ; 9E50
        sec                                     ; 9E51
        and     $34,x                           ; 9E52
        sed                                     ; 9E54
        ora     ($2C,x)                         ; 9E55
        .byte   $8D                             ; 9E57
L9E58:  sbc     $F88D,x                         ; 9E58
        .byte   $0F                             ; 9E5B
        bit     $FB8D                           ; 9E5C
        .byte   $8D                             ; 9E5F
        .byte   $2C                             ; 9E60
L9E61:  .byte   $43                             ; 9E61
        rol     $352C,x                         ; 9E62
        eor     ($38,x)                         ; 9E65
        .byte   $34                             ; 9E67
        .byte   $3D                             ; 9E68
        .byte   $33                             ; 9E69
L9E6A:  .byte   $4F                             ; 9E6A
        sed                                     ; 9E6B
        .byte   $04                             ; 9E6C
        bit     $FD8D                           ; 9E6D
        sta     $0FF8                           ; 9E70
        bit     $FB8D                           ; 9E73
        sta     $322C                           ; 9E76
        .byte   $37                             ; 9E79
        bmi     L9EB9                           ; 9E7A
        rol     $38,x                           ; 9E7C
L9E7E:  and     $2C36,x                         ; 9E7E
        .byte   $43                             ; 9E81
        .byte   $37                             ; 9E82
        .byte   $34                             ; 9E83
        sed                                     ; 9E84
        .byte   $02                             ; 9E85
        bit     $FD8D                           ; 9E86
        sta     $0FF8                           ; 9E89
        bit     $FB8D                           ; 9E8C
        sta     $322C                           ; 9E8F
        .byte   $3B                             ; 9E92
        bmi     L9ED7                           ; 9E93
        .byte   $42                             ; 9E95
        .byte   $4F                             ; 9E96
        sed                                     ; 9E97
        php                                     ; 9E98
L9E99:  bit     $FD8D                           ; 9E99
        sta     $0FF8                           ; 9E9C
        bit     $FB8D                           ; 9E9F
        sta     $3F2C                           ; 9EA2
        bmi     L9EE9                           ; 9EA5
        .byte   $42                             ; 9EA7
        bit     $3E46                           ; 9EA8
        eor     ($33,x)                         ; 9EAB
        .byte   $4F                             ; 9EAD
        sed                                     ; 9EAE
        .byte   $04                             ; 9EAF
        bit     $FD8D                           ; 9EB0
        .byte   $8F                             ; 9EB3
        sed                                     ; 9EB4
        .byte   $0F                             ; 9EB5
        sty     $FD9F                           ; 9EB6
L9EB9:  inc     $F88E,x                         ; 9EB9
        .byte   $0F                             ; 9EBC
        sty     $FB9E                           ; 9EBD
        sta     $422C                           ; 9EC0
        bmi     L9EFD                           ; 9EC3
        and     $F843,x                         ; 9EC5
        ora     #$2C                            ; 9EC8
        sta     L8DFD                           ; 9ECA
        sed                                     ; 9ECD
        .byte   $0F                             ; 9ECE
        bit     $FB8D                           ; 9ECF
        sta     $352C                           ; 9ED2
        sec                                     ; 9ED5
        .byte   $36                             ; 9ED6
L9ED7:  .byte   $37                             ; 9ED7
        .byte   $43                             ; 9ED8
        .byte   $34                             ; 9ED9
        eor     ($F8,x)                         ; 9EDA
        .byte   $07                             ; 9EDC
        bit     $FD8D                           ; 9EDD
        sta     $0FF8                           ; 9EE0
        bit     $FB8D                           ; 9EE3
        sta     $3C2C                           ; 9EE6
L9EE9:  bmi     L9F21                           ; 9EE9
        sec                                     ; 9EEB
        .byte   $32                             ; 9EEC
        sec                                     ; 9EED
        bmi     L9F2D                           ; 9EEE
        sed                                     ; 9EF0
        asl     $2C                             ; 9EF1
        sta     L8DFD                           ; 9EF3
        sed                                     ; 9EF6
        .byte   $0F                             ; 9EF7
        bit     $FB8D                           ; 9EF8
        .byte   $8D                             ; 9EFB
        .byte   $2C                             ; 9EFC
L9EFD:  and     $F83E,x                         ; 9EFD
        .byte   $0C                             ; 9F00
        bit     $FD8D                           ; 9F01
        .byte   $8F                             ; 9F04
        sed                                     ; 9F05
        .byte   $0F                             ; 9F06
        sty     $FD9F                           ; 9F07
        inc     $F88E,x                         ; 9F0A
        .byte   $0B                             ; 9F0D
        sty     $FE9E                           ; 9F0E
        .byte   $8F                             ; 9F11
        sed                                     ; 9F12
        .byte   $0B                             ; 9F13
        sty     $FE9F                           ; 9F14
        sta     $F52C                           ; 9F17
        rti                                     ; 9F1A

; ----------------------------------------------------------------------------
        ora     $2C                             ; 9F1B
        sta     L8DFE                           ; 9F1D
        .byte   $2C                             ; 9F20
L9F21:  sbc     $41,x                           ; 9F21
        ora     $2C                             ; 9F23
        sta     L8DFE                           ; 9F25
        bit     $42F5                           ; 9F28
        ora     $2C                             ; 9F2B
L9F2D:  sta     L8DFE                           ; 9F2D
        bit     $43F5                           ; 9F30
        ora     $2C                             ; 9F33
        sta     L8DFE                           ; 9F35
        bit     $44F5                           ; 9F38
L9F3B:  .byte   $05                             ; 9F3B
L9F3C:  bit     $FE8D                           ; 9F3C
        sta     $F52C                           ; 9F3F
        eor     $05                             ; 9F42
        bit     $FE8D                           ; 9F44
        sta     $F52C                           ; 9F47
        lsr     $05                             ; 9F4A
        bit     $FE8D                           ; 9F4C
        sta     $F52C                           ; 9F4F
        .byte   $47                             ; 9F52
        ora     $2C                             ; 9F53
        sta     L8DFE                           ; 9F55
        bit     $48F5                           ; 9F58
        ora     $2C                             ; 9F5B
        sta     L8DFE                           ; 9F5D
        bit     $49F5                           ; 9F60
        ora     $2C                             ; 9F63
        sta     L8DFE                           ; 9F65
        bit     $4AF5                           ; 9F68
        ora     $2C                             ; 9F6B
        sta     L8EFE                           ; 9F6D
        sed                                     ; 9F70
        .byte   $0F                             ; 9F71
        sty     $FB9E                           ; 9F72
        sta     $482C                           ; 9F75
        .byte   $34                             ; 9F78
        .byte   $42                             ; 9F79
        sed                                     ; 9F7A
        .byte   $0B                             ; 9F7B
        bit     $FB8D                           ; 9F7C
        sta     $0FF8                           ; 9F7F
        bit     $FD8D                           ; 9F82
        sta     $3D2C                           ; 9F85
        .byte   $3E                             ; 9F88
        sed                                     ; 9F89
L9F8A:  .byte   $0C                             ; 9F8A
        bit     $FB8D                           ; 9F8B
        sta     $0FF8                           ; 9F8E
        bit     $FD8D                           ; 9F91
        .byte   $8F                             ; 9F94
        sed                                     ; 9F95
        .byte   $0F                             ; 9F96
        sty     $FD9F                           ; 9F97
        inc     $F88E,x                         ; 9F9A
        asl     $8C                             ; 9F9D
        .byte   $9E                             ; 9F9F
        .byte   $FB                             ; 9FA0
        sta     $06F8                           ; 9FA1
        bit     $FD8D                           ; 9FA4
        sta     $06F8                           ; 9FA7
        bit     $FB8D                           ; 9FAA
        sta     $06F8                           ; 9FAD
        bit     $FD8D                           ; 9FB0
        sta     $06F8                           ; 9FB3
        bit     $FB8D                           ; 9FB6
        sta     $06F8                           ; 9FB9
        bit     $FD8D                           ; 9FBC
        sta     $06F8                           ; 9FBF
        bit     $FB8D                           ; 9FC2
        .byte   $8F                             ; 9FC5
        sed                                     ; 9FC6
        asl     $8C                             ; 9FC7
        .byte   $9F                             ; 9FC9
        sbc     L8EFE,x                         ; 9FCA
        sed                                     ; 9FCD
        .byte   $1B                             ; 9FCE
        sty     $FB9E                           ; 9FCF
        sta     $06F8                           ; 9FD2
        bit     $F88D                           ; 9FD5
        asl     $2C                             ; 9FD8
        sta     $06F8                           ; 9FDA
        bit     $F88D                           ; 9FDD
        asl     $2C                             ; 9FE0
        sta     L8DFD                           ; 9FE2
        sed                                     ; 9FE5
        asl     $2C                             ; 9FE6
        sta     $06F8                           ; 9FE8
        bit     $F88D                           ; 9FEB
        asl     $2C                             ; 9FEE
        sta     $06F8                           ; 9FF0
        bit     $FB8D                           ; 9FF3
        sta     $06F8                           ; 9FF6
        bit     $F88D                           ; 9FF9
        asl     $2C                             ; 9FFC
        .byte   $8D                             ; 9FFE
        sed                                     ; 9FFF
