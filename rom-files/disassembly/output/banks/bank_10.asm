; ============================================================================
; The Magic of Scheherazade - Bank 10 Disassembly
; ============================================================================
; File Offset: 0x14000 - 0x15FFF
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
; Input file: C:/claude-workspace/TMOS_AI/rom-files/disassembly/output/banks/bank_10.bin
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
L0002           := $0002
L1040           := $1040
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
L4020           := $4020
LA01A           := $A01A
LA01B           := $A01B
LA01F           := $A01F
LA09B           := $A09B
LA0E0           := $A0E0
LA135           := $A135
LA16E           := $A16E
LA1A7           := $A1A7
LA383           := $A383
LA3F6           := $A3F6
LA43E           := $A43E
LA482           := $A482
LA4AE           := $A4AE
LA50F           := $A50F
LA52C           := $A52C
LA5AC           := $A5AC
LA5CB           := $A5CB
LA604           := $A604
LA64C           := $A64C
LA666           := $A666
LA839           := $A839
LA874           := $A874
LA92C           := $A92C
LA987           := $A987
LAA1C           := $AA1C
LAAB8           := $AAB8
LAB0A           := $AB0A
LAB25           := $AB25
LAC1D           := $AC1D
LAF74           := $AF74
LB047           := $B047
LB04F           := $B04F
LB0F2           := $B0F2
LB131           := $B131
LB167           := $B167
LBD0F           := $BD0F
LE082           := $E082
LE086           := $E086
LE088           := $E088
LE096           := $E096
LE0A0           := $E0A0
LE0A2           := $E0A2
LE0A4           := $E0A4
LE0FE           := $E0FE
LE108           := $E108
LE110           := $E110
LE114           := $E114
LE399           := $E399
LE39B           := $E39B
LE3A3           := $E3A3
LE8EF           := $E8EF
LE95B           := $E95B
LE964           := $E964
LE97D           := $E97D
LE992           := $E992
LEAB9           := $EAB9
LEABD           := $EABD
LEAC1           := $EAC1
LEBFF           := $EBFF
LEC21           := $EC21
LEC71           := $EC71
LEC75           := $EC75
LEC7E           := $EC7E
LF07B           := $F07B
LF085           := $F085
LF0BE           := $F0BE
LF11C           := $F11C
LF120           := $F120
LF154           := $F154
LF3E0           := $F3E0
LF40D           := $F40D
LF46B           := $F46B
LF510           := $F510
LF6DE           := $F6DE
LF6E8           := $F6E8
LF765           := $F765
LF83C           := $F83C
LF85D           := $F85D
LF877           := $F877
LF8E6           := $F8E6
LF975           := $F975
LF9BB           := $F9BB
LFA29           := $FA29
LFA84           := $FA84
LFAB3           := $FAB3
LFAD7           := $FAD7
LFB62           := $FB62
LFBE9           := $FBE9
LFC90           := $FC90
; ----------------------------------------------------------------------------
        ror     $9B,x                           ; 8000
        .byte   $3A                             ; 8002
        .byte   $80                             ; 8003
        cpx     #$9F                            ; 8004
        .byte   $73                             ; 8006
        lda     ($3E,x)                         ; 8007
        ldy     $82                             ; 8009
        ldy     $0F                             ; 800B
        lda     $2C                             ; 800D
        lda     $9D                             ; 800F
        lda     $5A                             ; 8011
        lda     $04                             ; 8013
        ldx     $39                             ; 8015
        tay                                     ; 8017
        .byte   $74                             ; 8018
        tay                                     ; 8019
        stx     $A8,y                           ; 801A
        asl     $BDAD,x                         ; 801C
        ldx     $AEE3                           ; 801F
        clc                                     ; 8022
        lda     L8028,x                         ; 8023
        .byte   $0D                             ; 8026
        .byte   $AE                             ; 8027
L8028:  lda     #$00                            ; 8028
        sta     $030A                           ; 802A
        ldx     #$08                            ; 802D
L802F:  jsr     L803A                           ; 802F
        clc                                     ; 8032
        txa                                     ; 8033
        adc     #$08                            ; 8034
        tax                                     ; 8036
        bne     L802F                           ; 8037
        rts                                     ; 8039

; ----------------------------------------------------------------------------
L803A:  lda     $0601,x                         ; 803A
        beq     L8086                           ; 803D
        cmp     #$F0                            ; 803F
        bcs     L8086                           ; 8041
        lda     $0600,x                         ; 8043
        and     #$7F                            ; 8046
        cmp     #$10                            ; 8048
        bcc     L8064                           ; 804A
        jsr     L80AD                           ; 804C
        lda     $0701,x                         ; 804F
        beq     L8064                           ; 8052
        lda     $BE                             ; 8054
        and     #$30                            ; 8056
        beq     L8061                           ; 8058
        lda     $0707,x                         ; 805A
        and     #$04                            ; 805D
        bne     L8064                           ; 805F
L8061:  jsr     LE108                           ; 8061
L8064:  lda     $0600,x                         ; 8064
        asl     a                               ; 8067
        tay                                     ; 8068
        lda     L80E5,y                         ; 8069
        sta     $00                             ; 806C
        lda     L80E6,y                         ; 806E
        sta     $01                             ; 8071
        lda     $0601,x                         ; 8073
        and     #$0F                            ; 8076
        asl     a                               ; 8078
        tay                                     ; 8079
        lda     ($00),y                         ; 807A
        sta     L0002                           ; 807C
        iny                                     ; 807E
        lda     ($00),y                         ; 807F
        sta     $03                             ; 8081
        jsr     L8090                           ; 8083
L8086:  lda     $67                             ; 8086
        bpl     L808D                           ; 8088
        jsr     LF6DE                           ; 808A
L808D:  .byte   $4C                             ; 808D
L808E:  .byte   $3C                             ; 808E
        sed                                     ; 808F
L8090:  lda     $19                             ; 8090
        cmp     #$04                            ; 8092
        bne     L809A                           ; 8094
        cpx     #$58                            ; 8096
        beq     L809E                           ; 8098
L809A:  cpx     #$D8                            ; 809A
        bne     L80AA                           ; 809C
L809E:  lda     $11                             ; 809E
        and     #$18                            ; 80A0
        beq     L80AA                           ; 80A2
        jsr     LE8EF                           ; 80A4
        jsr     LF6DE                           ; 80A7
L80AA:  jmp     (L0002)                         ; 80AA

; ----------------------------------------------------------------------------
L80AD:  cmp     #$13                            ; 80AD
        beq     L80DA                           ; 80AF
        cmp     #$14                            ; 80B1
        beq     L80DA                           ; 80B3
        cmp     #$17                            ; 80B5
        beq     L80DA                           ; 80B7
        cmp     #$1C                            ; 80B9
        beq     L80DA                           ; 80BB
        cmp     #$1D                            ; 80BD
        beq     L80DA                           ; 80BF
        cmp     #$3D                            ; 80C1
        beq     L80DA                           ; 80C3
        cmp     #$3F                            ; 80C5
        beq     L80DA                           ; 80C7
        cmp     #$18                            ; 80C9
        beq     L80D1                           ; 80CB
        cmp     #$21                            ; 80CD
        bne     L80D8                           ; 80CF
L80D1:  lda     $0601,x                         ; 80D1
        and     #$0F                            ; 80D4
        beq     L80DA                           ; 80D6
L80D8:  sta     $71                             ; 80D8
L80DA:  rts                                     ; 80DA

; ----------------------------------------------------------------------------
L80DB:  lda     $82                             ; 80DB
        cmp     #$02                            ; 80DD
        bcc     L80E4                           ; 80DF
        jmp     LBD0F                           ; 80E1

; ----------------------------------------------------------------------------
L80E4:  rts                                     ; 80E4

; ----------------------------------------------------------------------------
L80E5:  .byte   $65                             ; 80E5
L80E6:  sta     ($65,x)                         ; 80E6
        sta     ($79,x)                         ; 80E8
        sta     ($8D,x)                         ; 80EA
        sta     ($9D,x)                         ; 80EC
        sta     ($A3,x)                         ; 80EE
        sta     ($C1,x)                         ; 80F0
        sta     ($DB,x)                         ; 80F2
        sta     ($DB,x)                         ; 80F4
        sta     ($DB,x)                         ; 80F6
        sta     ($FB,x)                         ; 80F8
        sta     ($03,x)                         ; 80FA
        .byte   $82                             ; 80FC
        .byte   $0B                             ; 80FD
        .byte   $82                             ; 80FE
        .byte   $2B                             ; 80FF
        .byte   $82                             ; 8100
        .byte   $2B                             ; 8101
        .byte   $82                             ; 8102
        .byte   $4B                             ; 8103
        .byte   $82                             ; 8104
        .byte   $53                             ; 8105
        .byte   $82                             ; 8106
        .byte   $63                             ; 8107
        .byte   $82                             ; 8108
        adc     ($82),y                         ; 8109
        adc     L8582,y                         ; 810B
        .byte   $82                             ; 810E
        .byte   $8F                             ; 810F
        .byte   $82                             ; 8110
        sta     $BD82,x                         ; 8111
        .byte   $82                             ; 8114
        .byte   $C7                             ; 8115
        .byte   $82                             ; 8116
        .byte   $D3                             ; 8117
        .byte   $82                             ; 8118
        cmp     $E782,x                         ; 8119
        .byte   $82                             ; 811C
        sbc     ($82),y                         ; 811D
        sbc     $0782,x                         ; 811F
        .byte   $83                             ; 8122
        .byte   $07                             ; 8123
        .byte   $83                             ; 8124
        ora     ($83),y                         ; 8125
        .byte   $1B                             ; 8127
        .byte   $83                             ; 8128
        .byte   $23                             ; 8129
        .byte   $83                             ; 812A
        and     $83,x                           ; 812B
        .byte   $47                             ; 812D
        .byte   $83                             ; 812E
        eor     $83,x                           ; 812F
        eor     $83,x                           ; 8131
        .byte   $63                             ; 8133
        .byte   $83                             ; 8134
        .byte   $73                             ; 8135
        .byte   $83                             ; 8136
        .byte   $73                             ; 8137
        .byte   $83                             ; 8138
        .byte   $73                             ; 8139
        .byte   $83                             ; 813A
        .byte   $73                             ; 813B
        .byte   $83                             ; 813C
        .byte   $73                             ; 813D
        .byte   $83                             ; 813E
        .byte   $73                             ; 813F
        .byte   $83                             ; 8140
        .byte   $73                             ; 8141
        .byte   $83                             ; 8142
        .byte   $73                             ; 8143
        .byte   $83                             ; 8144
        .byte   $73                             ; 8145
        .byte   $83                             ; 8146
        .byte   $73                             ; 8147
        .byte   $83                             ; 8148
        .byte   $73                             ; 8149
        .byte   $83                             ; 814A
        .byte   $73                             ; 814B
        .byte   $83                             ; 814C
        sta     $83                             ; 814D
        lda     $83                             ; 814F
        .byte   $BB                             ; 8151
        .byte   $83                             ; 8152
        .byte   $D7                             ; 8153
        .byte   $83                             ; 8154
        sbc     $83                             ; 8155
        sbc     ($83),y                         ; 8157
        sbc     $0983,x                         ; 8159
        sty     $09                             ; 815C
        sty     $09                             ; 815E
        sty     $15                             ; 8160
        sty     $1F                             ; 8162
        sty     $27                             ; 8164
        sty     $39                             ; 8166
        sty     $67                             ; 8168
        sty     $D1                             ; 816A
        sty     $36                             ; 816C
        sta     $6F                             ; 816E
        sta     $6F                             ; 8170
        sta     $6F                             ; 8172
        sta     $67                             ; 8174
        sty     $92                             ; 8176
        sta     $39                             ; 8178
        sty     $39                             ; 817A
        sty     $F3                             ; 817C
        sta     $D1                             ; 817E
        sty     $36                             ; 8180
        sta     $6F                             ; 8182
        sta     $6F                             ; 8184
        sta     $6F                             ; 8186
        sta     $F3                             ; 8188
        sta     $92                             ; 818A
        sta     $89                             ; 818C
        stx     $89                             ; 818E
        stx     $89                             ; 8190
        stx     $89                             ; 8192
        stx     $89                             ; 8194
        stx     $89                             ; 8196
        stx     $89                             ; 8198
        stx     $89                             ; 819A
        stx     $A6                             ; 819C
        stx     $22                             ; 819E
        .byte   $87                             ; 81A0
        .byte   $22                             ; 81A1
        .byte   $87                             ; 81A2
        and     $3D87,x                         ; 81A3
        .byte   $87                             ; 81A6
        and     $3D87,x                         ; 81A7
        .byte   $87                             ; 81AA
        and     $5E87,x                         ; 81AB
        .byte   $87                             ; 81AE
        and     $CB87,x                         ; 81AF
        .byte   $87                             ; 81B2
        inc     $87,x                           ; 81B3
        and     $0287,x                         ; 81B5
        dey                                     ; 81B8
        .byte   $1F                             ; 81B9
        dey                                     ; 81BA
        rol     $88,x                           ; 81BB
        rol     $88,x                           ; 81BD
        .byte   $3B                             ; 81BF
        dey                                     ; 81C0
        inc     $88,x                           ; 81C1
        .byte   $54                             ; 81C3
        dey                                     ; 81C4
        inc     $88,x                           ; 81C5
        .byte   $AB                             ; 81C7
        dey                                     ; 81C8
        inc     $88,x                           ; 81C9
        inc     $88,x                           ; 81CB
        inc     $88,x                           ; 81CD
        inc     $88,x                           ; 81CF
        inc     $88,x                           ; 81D1
        inc     $88,x                           ; 81D3
        inc     $88,x                           ; 81D5
        asl     $89,x                           ; 81D7
        .byte   $37                             ; 81D9
        .byte   $89                             ; 81DA
        .byte   $3F                             ; 81DB
        .byte   $89                             ; 81DC
        .byte   $3F                             ; 81DD
        .byte   $89                             ; 81DE
        .byte   $3F                             ; 81DF
        .byte   $89                             ; 81E0
        .byte   $3F                             ; 81E1
        .byte   $89                             ; 81E2
        .byte   $3F                             ; 81E3
        .byte   $89                             ; 81E4
        .byte   $3F                             ; 81E5
        .byte   $89                             ; 81E6
        .byte   $3F                             ; 81E7
        .byte   $89                             ; 81E8
        .byte   $3F                             ; 81E9
        .byte   $89                             ; 81EA
        .byte   $3F                             ; 81EB
        .byte   $89                             ; 81EC
        .byte   $3F                             ; 81ED
        .byte   $89                             ; 81EE
        .byte   $3F                             ; 81EF
        .byte   $89                             ; 81F0
        .byte   $3F                             ; 81F1
        .byte   $89                             ; 81F2
        .byte   $3F                             ; 81F3
        .byte   $89                             ; 81F4
        .byte   $3F                             ; 81F5
        .byte   $89                             ; 81F6
        .byte   $3F                             ; 81F7
        .byte   $89                             ; 81F8
        .byte   $DA                             ; 81F9
        ldy     $CC,x                           ; 81FA
        .byte   $89                             ; 81FC
        cpy     $CC89                           ; 81FD
        .byte   $89                             ; 8200
        cpy     $3389                           ; 8201
        txa                                     ; 8204
        ror     $8A                             ; 8205
        dec     $F68A,x                         ; 8207
        txa                                     ; 820A
        ror     $8B,x                           ; 820B
        ror     $8B,x                           ; 820D
        ror     $8B,x                           ; 820F
        ror     $8B,x                           ; 8211
        ror     $8B,x                           ; 8213
        ror     $8B,x                           ; 8215
        brk                                     ; 8217
        brk                                     ; 8218
        .byte   $53                             ; 8219
        sty     L8937                           ; 821A
        .byte   $6F                             ; 821D
        lda     $7E,x                           ; 821E
        lda     $93,x                           ; 8220
        lda     $00,x                           ; 8222
        brk                                     ; 8224
        .byte   $C2                             ; 8225
        .byte   $8C                             ; 8226
L8227:  bit     $378D                           ; 8227
        .byte   $89                             ; 822A
        eor     $8D                             ; 822B
        eor     $8D                             ; 822D
        eor     $8D                             ; 822F
        eor     $8D                             ; 8231
        .byte   $45                             ; 8233
L8234:  sta     $8D45                           ; 8234
        eor     $8D                             ; 8237
        eor     $8D                             ; 8239
        eor     $8D                             ; 823B
        eor     $8D                             ; 823D
        .byte   $45                             ; 823F
L8240:  sta     $8D45                           ; 8240
        eor     $8D                             ; 8243
        eor     $8D                             ; 8245
        eor     $8D                             ; 8247
        eor     $8D                             ; 8249
        ldy     $8D                             ; 824B
        ldy     $C08D,x                         ; 824D
        sta     L8DCA                           ; 8250
        dec     $F68D                           ; 8253
        sta     L8DF6                           ; 8256
        inc     $8D,x                           ; 8259
        inc     $8D,x                           ; 825B
        inc     $8D,x                           ; 825D
        inc     $8D,x                           ; 825F
        eor     L808E,y                         ; 8261
        stx     L8EB8                           ; 8264
        .byte   $CB                             ; 8267
        stx     L8F29                           ; 8268
        sei                                     ; 826B
        .byte   $8F                             ; 826C
L826D:  ldy     #$8F                            ; 826D
        .byte   $E3                             ; 826F
        .byte   $8F                             ; 8270
        .byte   $EF                             ; 8271
        .byte   $8F                             ; 8272
        clv                                     ; 8273
        stx     L8ECB                           ; 8274
        .byte   $07                             ; 8277
        bcc     L828E                           ; 8278
        bcc     L8234                           ; 827A
        .byte   $8E                             ; 827C
        .byte   $CB                             ; 827D
L827E:  stx     $903F                           ; 827E
        ror     $A390,x                         ; 8281
        bcc     L826D                           ; 8284
        bcc     L8240                           ; 8286
        stx     L8ECB                           ; 8288
        .byte   $0B                             ; 828B
        sta     ($41),y                         ; 828C
L828E:  sta     ($7C),y                         ; 828E
        sta     ($B8),y                         ; 8290
        stx     L8ECB                           ; 8292
        asl     $92                             ; 8295
        .byte   $3A                             ; 8297
        .byte   $92                             ; 8298
        .byte   $80                             ; 8299
        .byte   $92                             ; 829A
        lda     L9B93,y                         ; 829B
        .byte   $92                             ; 829E
        clv                                     ; 829F
        stx     L8ECB                           ; 82A0
        lda     #$92                            ; 82A3
        sei                                     ; 82A5
        .byte   $8F                             ; 82A6
        .byte   $14                             ; 82A7
        .byte   $93                             ; 82A8
        brk                                     ; 82A9
        brk                                     ; 82AA
        brk                                     ; 82AB
        brk                                     ; 82AC
        .byte   $53                             ; 82AD
        .byte   $93                             ; 82AE
        .byte   $53                             ; 82AF
        .byte   $93                             ; 82B0
        .byte   $53                             ; 82B1
        .byte   $93                             ; 82B2
        .byte   $53                             ; 82B3
        .byte   $93                             ; 82B4
        .byte   $53                             ; 82B5
        .byte   $93                             ; 82B6
        .byte   $53                             ; 82B7
L82B8:  .byte   $93                             ; 82B8
        .byte   $53                             ; 82B9
        .byte   $93                             ; 82BA
        .byte   $53                             ; 82BB
        .byte   $93                             ; 82BC
        dec     $93,x                           ; 82BD
        clv                                     ; 82BF
        stx     L8ECB                           ; 82C0
        .byte   $AF                             ; 82C3
        sty     $BC,x                           ; 82C4
        sty     $DA,x                           ; 82C6
        sty     $B8,x                           ; 82C8
        stx     L8ECB                           ; 82CA
        eor     $7795                           ; 82CD
        sta     $9A,x                           ; 82D0
        sta     $F0,x                           ; 82D2
        sta     $B8,x                           ; 82D4
        stx     L8ECB                           ; 82D6
        inc     $95,x                           ; 82D9
        jmp     (L9396)                         ; 82DB

; ----------------------------------------------------------------------------
        .byte   $97                             ; 82DE
        clv                                     ; 82DF
        stx     L8ECB                           ; 82E0
        lda     #$97                            ; 82E3
        lda     #$97                            ; 82E5
        beq     L827E                           ; 82E7
        clv                                     ; 82E9
        stx     L8ECB                           ; 82EA
        and     #$8F                            ; 82ED
        sei                                     ; 82EF
        .byte   $8F                             ; 82F0
        sty     $96,x                           ; 82F1
        clv                                     ; 82F3
        stx     L8ECB                           ; 82F4
        cpy     $0F96                           ; 82F7
        .byte   $97                             ; 82FA
        sec                                     ; 82FB
        .byte   $97                             ; 82FC
        .byte   $E7                             ; 82FD
        bcc     L82B8                           ; 82FE
L8300:  stx     L8ECB                           ; 8300
        cpx     $2997                           ; 8303
        tya                                     ; 8306
        .byte   $32                             ; 8307
        tya                                     ; 8308
        clv                                     ; 8309
        stx     L8ECB                           ; 830A
        .byte   $52                             ; 830D
        tya                                     ; 830E
L830F:  .byte   $52                             ; 830F
        tya                                     ; 8310
        .byte   $EF                             ; 8311
        .byte   $8F                             ; 8312
        clv                                     ; 8313
        stx     L8ECB                           ; 8314
        lda     $98                             ; 8317
        ldx     $98,y                           ; 8319
        sbc     $B898,y                         ; 831B
        stx     L8ECB                           ; 831E
        and     #$8F                            ; 8321
        ora     $B899                           ; 8323
        stx     L8ECB                           ; 8326
        adc     L9B99,y                         ; 8329
        sta     L990D,y                         ; 832C
        ora     $0D99                           ; 832F
        sta     L8937,y                         ; 8332
        ora     $B899                           ; 8335
        stx     L8ECB                           ; 8338
        .byte   $02                             ; 833B
        txs                                     ; 833C
        .byte   $02                             ; 833D
        txs                                     ; 833E
        ora     $0D99                           ; 833F
        sta     L990D,y                         ; 8342
        .byte   $37                             ; 8345
        .byte   $89                             ; 8346
        sta     ($9A,x)                         ; 8347
        clv                                     ; 8349
        stx     L8ECB                           ; 834A
        cmp     $9A,x                           ; 834D
        lda     ($9B,x)                         ; 834F
        ldx     $9B                             ; 8351
        cmp     $9B                             ; 8353
        sta     ($9A,x)                         ; 8355
        clv                                     ; 8357
        stx     L8ECB                           ; 8358
        dec     $9B,x                           ; 835B
        lda     ($9B,x)                         ; 835D
        ldx     $9B                             ; 835F
        cmp     $9B                             ; 8361
        sta     ($9A,x)                         ; 8363
        clv                                     ; 8365
        stx     L8ECB                           ; 8366
        asl     $9C                             ; 8369
        lda     ($9B,x)                         ; 836B
        ldx     $9B                             ; 836D
        .byte   $17                             ; 836F
        .byte   $9C                             ; 8370
        bvs     L830F                           ; 8371
        .byte   $7F                             ; 8373
        .byte   $9C                             ; 8374
        clv                                     ; 8375
        stx     L8ECB                           ; 8376
        cmp     $499C,y                         ; 8379
        sta     L9D6E,x                         ; 837C
        .byte   $C2                             ; 837F
        sta     L9DC3,x                         ; 8380
        .byte   $37                             ; 8383
        .byte   $89                             ; 8384
        .byte   $12                             ; 8385
        ldx     $5B,y                           ; 8386
        ldx     $5B,y                           ; 8388
        ldx     $6C,y                           ; 838A
        ldx     $BD,y                           ; 838C
        ldx     $FA,y                           ; 838E
        ldx     $12,y                           ; 8390
        ldx     $12,y                           ; 8392
        ldx     $05,y                           ; 8394
        .byte   $B7                             ; 8396
        ora     $B7                             ; 8397
        ora     $B7                             ; 8399
        ora     $B7                             ; 839B
        ora     $B7                             ; 839D
        .byte   $05                             ; 839F
L83A0:  .byte   $B7                             ; 83A0
        ora     $B7                             ; 83A1
        ora     $B7                             ; 83A3
        pha                                     ; 83A5
        .byte   $B7                             ; 83A6
        pha                                     ; 83A7
        .byte   $B7                             ; 83A8
        pha                                     ; 83A9
        .byte   $B7                             ; 83AA
        .byte   $74                             ; 83AB
L83AC:  .byte   $B7                             ; 83AC
        .byte   $74                             ; 83AD
        .byte   $B7                             ; 83AE
        cmp     ($B7,x)                         ; 83AF
        pha                                     ; 83B1
        .byte   $B7                             ; 83B2
        pha                                     ; 83B3
        .byte   $B7                             ; 83B4
        cmp     ($B7),y                         ; 83B5
        cmp     ($B7),y                         ; 83B7
        cmp     ($B7),y                         ; 83B9
        .byte   $F2                             ; 83BB
        .byte   $B7                             ; 83BC
        ora     ($B8),y                         ; 83BD
        ora     ($B8),y                         ; 83BF
        ora     ($B8),y                         ; 83C1
        ora     ($B8),y                         ; 83C3
        and     ($B8),y                         ; 83C5
        ora     ($B8),y                         ; 83C7
        stx     $B8                             ; 83C9
        ora     $B9                             ; 83CB
        ora     $B9                             ; 83CD
        ora     $B9                             ; 83CF
        ora     $B9                             ; 83D1
        ora     $B9                             ; 83D3
        ora     $B9                             ; 83D5
        .byte   $8F                             ; 83D7
        lda     L8EB8,y                         ; 83D8
        .byte   $CB                             ; 83DB
        stx     $B9BF                           ; 83DC
        sei                                     ; 83DF
        .byte   $8F                             ; 83E0
        .byte   $E7                             ; 83E1
        lda     $BA0B,y                         ; 83E2
        sec                                     ; 83E5
        tsx                                     ; 83E6
        sec                                     ; 83E7
        tsx                                     ; 83E8
        sec                                     ; 83E9
        tsx                                     ; 83EA
        sta     L99BA,y                         ; 83EB
        tsx                                     ; 83EE
        cmp     ($B7,x)                         ; 83EF
        .byte   $0C                             ; 83F1
        .byte   $BB                             ; 83F2
        .byte   $0C                             ; 83F3
        .byte   $BB                             ; 83F4
        .byte   $0C                             ; 83F5
        .byte   $BB                             ; 83F6
        .byte   $3A                             ; 83F7
        .byte   $BB                             ; 83F8
        .byte   $3A                             ; 83F9
        .byte   $BB                             ; 83FA
        .byte   $BB                             ; 83FB
        .byte   $BB                             ; 83FC
        asl     $BC                             ; 83FD
        asl     $BC                             ; 83FF
        asl     $BC                             ; 8401
        .byte   $89                             ; 8403
        ldy     $BC89,x                         ; 8404
        sbc     #$BC                            ; 8407
        beq     L83A0                           ; 8409
        clv                                     ; 840B
        stx     L8ECB                           ; 840C
        and     $0F9E                           ; 840F
        .byte   $97                             ; 8412
        tya                                     ; 8413
        .byte   $9E                             ; 8414
        beq     L83AC                           ; 8415
        clv                                     ; 8417
        stx     L8ECB                           ; 8418
        clc                                     ; 841B
        .byte   $9F                             ; 841C
        sei                                     ; 841D
        .byte   $8F                             ; 841E
        .byte   $2B                             ; 841F
        .byte   $9F                             ; 8420
        clv                                     ; 8421
        stx     L8ECB                           ; 8422
        .byte   $33                             ; 8425
        .byte   $9F                             ; 8426
        lda     #$17                            ; 8427
        sta     $20                             ; 8429
L842B:  lda     #$02                            ; 842B
        jsr     LF0BE                           ; 842D
        jsr     LE0A4                           ; 8430
        jsr     L9F62                           ; 8433
        jmp     LA987                           ; 8436

; ----------------------------------------------------------------------------
        lda     $0700,x                         ; 8439
        bne     L8443                           ; 843C
        lda     #$0F                            ; 843E
        jsr     LE992                           ; 8440
L8443:  inc     $0700,x                         ; 8443
        lda     $0700,x                         ; 8446
        cmp     #$3C                            ; 8449
        bne     L845D                           ; 844B
        lda     $28                             ; 844D
        beq     L8456                           ; 844F
        lda     #$7F                            ; 8451
        jsr     LE992                           ; 8453
L8456:  lda     #$00                            ; 8456
        sta     $0700,x                         ; 8458
        beq     L842B                           ; 845B
L845D:  and     #$07                            ; 845D
        sta     $22                             ; 845F
        jmp     L8587                           ; 8461

; ----------------------------------------------------------------------------
        jmp     L9F62                           ; 8464

; ----------------------------------------------------------------------------
        lda     $21                             ; 8467
        bne     L8491                           ; 8469
        ldy     #$02                            ; 846B
        lda     $C2                             ; 846D
        lsr     a                               ; 846F
        bcs     L84BB                           ; 8470
        lsr     a                               ; 8472
        bcs     L8494                           ; 8473
L8475:  lda     $C0                             ; 8475
        and     #$F0                            ; 8477
        bne     L848E                           ; 8479
        lda     $BF                             ; 847B
        and     #$10                            ; 847D
        beq     L848B                           ; 847F
        lda     $9B                             ; 8481
        bne     L848E                           ; 8483
        jsr     LE0A2                           ; 8485
        jmp     L848E                           ; 8488

; ----------------------------------------------------------------------------
L848B:  jsr     LE0A4                           ; 848B
L848E:  jsr     LAB25                           ; 848E
L8491:  jmp     L852B                           ; 8491

; ----------------------------------------------------------------------------
L8494:  lda     $C6                             ; 8494
        beq     L84BF                           ; 8496
        cmp     #$1E                            ; 8498
        beq     L84B4                           ; 849A
        cmp     #$1F                            ; 849C
        beq     L84CB                           ; 849E
        cmp     #$04                            ; 84A0
        bne     L8475                           ; 84A2
        lda     $0312                           ; 84A4
        beq     L8475                           ; 84A7
        lda     $0629                           ; 84A9
        bne     L8475                           ; 84AC
        jsr     LA0E0                           ; 84AE
        jmp     L9F62                           ; 84B1

; ----------------------------------------------------------------------------
L84B4:  jsr     LA135                           ; 84B4
        bne     L8475                           ; 84B7
        beq     L8491                           ; 84B9
L84BB:  lda     $C5                             ; 84BB
        bne     L8475                           ; 84BD
L84BF:  lda     $BF                             ; 84BF
        and     #$10                            ; 84C1
        bne     L8475                           ; 84C3
        jsr     LA09B                           ; 84C5
        jmp     L8491                           ; 84C8

; ----------------------------------------------------------------------------
L84CB:  jsr     LA16E                           ; 84CB
        jmp     L9F62                           ; 84CE

; ----------------------------------------------------------------------------
        lda     $21                             ; 84D1
        bne     L8533                           ; 84D3
        jsr     LF877                           ; 84D5
        beq     L84E9                           ; 84D8
        lda     $32                             ; 84DA
        beq     L8533                           ; 84DC
        lda     $7F                             ; 84DE
        and     #$07                            ; 84E0
        bne     L8533                           ; 84E2
        jsr     LF877                           ; 84E4
        bne     L8533                           ; 84E7
L84E9:  lda     $0707,x                         ; 84E9
        and     #$AF                            ; 84EC
        sta     $0707,x                         ; 84EE
        jsr     LAAB8                           ; 84F1
        sta     $95                             ; 84F4
        jsr     LAC1D                           ; 84F6
        lda     $0601,x                         ; 84F9
        and     #$0F                            ; 84FC
        cmp     #$03                            ; 84FE
        bne     L8510                           ; 8500
L8502:  ldy     #$02                            ; 8502
        lda     $BF                             ; 8504
        and     #$10                            ; 8506
        beq     L850C                           ; 8508
        ldy     #$08                            ; 850A
L850C:  tya                                     ; 850C
        jsr     LF0BE                           ; 850D
L8510:  lda     $32                             ; 8510
        beq     L8525                           ; 8512
        lda     $0600,x                         ; 8514
        and     #$7F                            ; 8517
        bne     L8525                           ; 8519
        lda     #$02                            ; 851B
        sta     $0600,x                         ; 851D
        lda     #$00                            ; 8520
        jsr     LF0BE                           ; 8522
L8525:  jsr     LE0A4                           ; 8525
        jsr     LA987                           ; 8528
L852B:  lda     $0607,x                         ; 852B
        and     #$7F                            ; 852E
        sta     $0607,x                         ; 8530
L8533:  jmp     L9F62                           ; 8533

; ----------------------------------------------------------------------------
        lda     $0700,x                         ; 8536
        bne     L8543                           ; 8539
        jsr     L8742                           ; 853B
        lda     #$FF                            ; 853E
        jmp     LE992                           ; 8540

; ----------------------------------------------------------------------------
L8543:  dec     $0700,x                         ; 8543
        lda     $0700,x                         ; 8546
        and     #$0F                            ; 8549
        bne     L8550                           ; 854B
        jsr     LE0A2                           ; 854D
L8550:  lda     $C2                             ; 8550
        lsr     a                               ; 8552
        bcs     L855B                           ; 8553
        lsr     a                               ; 8555
        bcs     L8560                           ; 8556
L8558:  jmp     L9F62                           ; 8558

; ----------------------------------------------------------------------------
L855B:  lda     $C5                             ; 855B
        jmp     L8562                           ; 855D

; ----------------------------------------------------------------------------
L8560:  lda     $C6                             ; 8560
L8562:  bne     L8558                           ; 8562
        dec     $0701,x                         ; 8564
        bne     L8558                           ; 8567
        jsr     L8641                           ; 8569
        jmp     L8558                           ; 856C

; ----------------------------------------------------------------------------
        lda     $21                             ; 856F
        bne     L858C                           ; 8571
        lda     #$08                            ; 8573
        sta     $9B                             ; 8575
        jsr     LAB25                           ; 8577
        lda     $0700,x                         ; 857A
        beq     L858F                           ; 857D
        dec     $0700,x                         ; 857F
L8582:  lda     $0700,x                         ; 8582
        and     #$03                            ; 8585
L8587:  bne     L858C                           ; 8587
        jsr     LE0A2                           ; 8589
L858C:  jmp     L9F62                           ; 858C

; ----------------------------------------------------------------------------
L858F:  jmp     L8502                           ; 858F

; ----------------------------------------------------------------------------
        lda     $0704,x                         ; 8592
        beq     L85C1                           ; 8595
        dec     $0700,x                         ; 8597
        bne     L85AE                           ; 859A
        lda     #$10                            ; 859C
        sta     $0700,x                         ; 859E
        dec     $0704,x                         ; 85A1
        lda     $0704,x                         ; 85A4
        and     #$03                            ; 85A7
        bne     L85AE                           ; 85A9
        jsr     LE0A2                           ; 85AB
L85AE:  lda     #$80                            ; 85AE
        sta     $0602,x                         ; 85B0
        lda     #$80                            ; 85B3
        sta     $0603,x                         ; 85B5
        jsr     LF975                           ; 85B8
        jsr     LF9BB                           ; 85BB
        jmp     LE0A0                           ; 85BE

; ----------------------------------------------------------------------------
L85C1:  rts                                     ; 85C1

; ----------------------------------------------------------------------------
        jsr     L85C9                           ; 85C2
        bit     $0707                           ; 85C5
        rts                                     ; 85C8

; ----------------------------------------------------------------------------
L85C9:  lda     $0339                           ; 85C9
        beq     L85DB                           ; 85CC
        lda     $03C8                           ; 85CE
        beq     L85DB                           ; 85D1
        lda     #$04                            ; 85D3
        sta     $30                             ; 85D5
        lda     #$0A                            ; 85D7
        bne     L85E5                           ; 85D9
L85DB:  lda     $0301                           ; 85DB
        beq     L85EF                           ; 85DE
        dec     $0301                           ; 85E0
        lda     #$0A                            ; 85E3
L85E5:  sta     $2A                             ; 85E5
        lda     $0707                           ; 85E7
        ora     #$02                            ; 85EA
        sta     $0707                           ; 85EC
L85EF:  jsr     LEAC1                           ; 85EF
        rts                                     ; 85F2

; ----------------------------------------------------------------------------
        lda     $21                             ; 85F3
        bne     L861D                           ; 85F5
        lda     $0707,x                         ; 85F7
        and     #$02                            ; 85FA
        beq     L8620                           ; 85FC
        lda     $2A                             ; 85FE
        bne     L8620                           ; 8600
        sta     $0707,x                         ; 8602
        sta     $32                             ; 8605
        sta     $0600,x                         ; 8607
        sta     $20                             ; 860A
        sta     $0700,x                         ; 860C
        lda     #$01                            ; 860F
        jsr     LF0BE                           ; 8611
        jsr     LE0A4                           ; 8614
        jsr     LEC7E                           ; 8617
        jsr     LF07B                           ; 861A
L861D:  jmp     L9F62                           ; 861D

; ----------------------------------------------------------------------------
L8620:  ldy     $32                             ; 8620
        lda     $ED2B,y                         ; 8622
        and     #$03                            ; 8625
        jsr     L8636                           ; 8627
        lda     $7F                             ; 862A
        and     #$03                            ; 862C
        bne     L8633                           ; 862E
        jsr     LE0A2                           ; 8630
L8633:  jmp     L861D                           ; 8633

; ----------------------------------------------------------------------------
L8636:  jsr     LE97D                           ; 8636
        eor     ($86,x)                         ; 8639
        eor     $F286                           ; 863B
        sta     $70                             ; 863E
        .byte   $86                             ; 8640
L8641:  ldy     #$01                            ; 8641
        lda     $C0                             ; 8643
        and     #$F0                            ; 8645
        bne     L8666                           ; 8647
        ldy     #$00                            ; 8649
        beq     L866C                           ; 864B
        ldy     #$01                            ; 864D
        lda     $C2                             ; 864F
        lsr     a                               ; 8651
        bcs     L865C                           ; 8652
        lsr     a                               ; 8654
        bcc     L866F                           ; 8655
        lda     $C5                             ; 8657
        jmp     L865E                           ; 8659

; ----------------------------------------------------------------------------
L865C:  lda     $C6                             ; 865C
L865E:  bne     L866F                           ; 865E
        lda     $C0                             ; 8660
        and     #$F0                            ; 8662
        beq     L866F                           ; 8664
L8666:  jsr     LAB0A                           ; 8666
        sta     $0601,x                         ; 8669
L866C:  jmp     LA09B                           ; 866C

; ----------------------------------------------------------------------------
L866F:  rts                                     ; 866F

; ----------------------------------------------------------------------------
        jsr     LE114                           ; 8670
        bne     L8678                           ; 8673
L8675:  jmp     LAB25                           ; 8675

; ----------------------------------------------------------------------------
L8678:  tay                                     ; 8678
        cmp     #$03                            ; 8679
        bne     L867F                           ; 867B
        ldy     #$01                            ; 867D
L867F:  lda     $C4,y                           ; 867F
        bne     L8675                           ; 8682
        ldy     #$01                            ; 8684
        jmp     LA09B                           ; 8686

; ----------------------------------------------------------------------------
        lda     $A1                             ; 8689
        sta     $03                             ; 868B
        lda     $0702,x                         ; 868D
        sec                                     ; 8690
        sbc     $03                             ; 8691
        sta     $0702,x                         ; 8693
        bcs     L869E                           ; 8696
        lda     #$00                            ; 8698
        sta     $0601,x                         ; 869A
        rts                                     ; 869D

; ----------------------------------------------------------------------------
L869E:  lda     #$03                            ; 869E
        jsr     LFB62                           ; 86A0
        jmp     LE0A0                           ; 86A3

; ----------------------------------------------------------------------------
        lda     $21                             ; 86A6
        bne     L86FE                           ; 86A8
        lda     $0600                           ; 86AA
        and     #$7F                            ; 86AD
        cmp     #$03                            ; 86AF
        bcs     L86BA                           ; 86B1
        lda     $0707                           ; 86B3
        and     #$10                            ; 86B6
        beq     L86C0                           ; 86B8
L86BA:  inc     $0601,x                         ; 86BA
        jmp     LE0A4                           ; 86BD

; ----------------------------------------------------------------------------
L86C0:  bit     $0707                           ; 86C0
        bvc     L86ED                           ; 86C3
        lda     $0707,x                         ; 86C5
        and     #$40                            ; 86C8
        bne     L86E0                           ; 86CA
        lda     $0601                           ; 86CC
        and     #$F0                            ; 86CF
        sta     $0601,x                         ; 86D1
        lda     #$04                            ; 86D4
        jsr     LF85D                           ; 86D6
        lda     #$40                            ; 86D9
        sta     $0707,x                         ; 86DB
        bne     L86FE                           ; 86DE
L86E0:  lda     $0607                           ; 86E0
        and     #$1F                            ; 86E3
        beq     L86FE                           ; 86E5
        jsr     LF877                           ; 86E7
        jmp     L86F8                           ; 86EA

; ----------------------------------------------------------------------------
L86ED:  lda     #$00                            ; 86ED
        sta     $0707,x                         ; 86EF
        lda     $0602                           ; 86F2
        sta     $0602,x                         ; 86F5
L86F8:  lda     $0603                           ; 86F8
        sta     $0603,x                         ; 86FB
L86FE:  lda     $0600                           ; 86FE
        asl     a                               ; 8701
        php                                     ; 8702
        asl     $0600,x                         ; 8703
        plp                                     ; 8706
        ror     $0600,x                         ; 8707
        lda     #$FF                            ; 870A
        sta     $0604,x                         ; 870C
        lda     $0600                           ; 870F
        asl     a                               ; 8712
        bne     L871E                           ; 8713
        lda     $29                             ; 8715
        bne     L871E                           ; 8717
        bit     $0707                           ; 8719
        bvc     L8721                           ; 871C
L871E:  jmp     L89A6                           ; 871E

; ----------------------------------------------------------------------------
L8721:  rts                                     ; 8721

; ----------------------------------------------------------------------------
        lda     $0601                           ; 8722
        beq     L873A                           ; 8725
        lda     $0600                           ; 8727
        and     #$7F                            ; 872A
        cmp     #$03                            ; 872C
        bcs     L873A                           ; 872E
        lda     $0707                           ; 8730
        and     #$10                            ; 8733
        bne     L873A                           ; 8735
        dec     $0601,x                         ; 8737
L873A:  jmp     LE0A4                           ; 873A

; ----------------------------------------------------------------------------
        jsr     L874F                           ; 873D
        bne     L875D                           ; 8740
L8742:  jsr     L8A60                           ; 8742
        sta     $0607,x                         ; 8745
        sta     $81                             ; 8748
        lda     #$FF                            ; 874A
        jmp     LE992                           ; 874C

; ----------------------------------------------------------------------------
L874F:  lda     #$02                            ; 874F
        sta     $22                             ; 8751
        dec     $0700,x                         ; 8753
        beq     L875D                           ; 8756
        jsr     L8782                           ; 8758
        lda     #$01                            ; 875B
L875D:  rts                                     ; 875D

; ----------------------------------------------------------------------------
        lda     $0701,x                         ; 875E
        jsr     LE97D                           ; 8761
        jmp     (L8787)                         ; 8764

; ----------------------------------------------------------------------------
        .byte   $87                             ; 8767
        .byte   $9B                             ; 8768
        .byte   $87                             ; 8769
        .byte   $AF                             ; 876A
        .byte   $87                             ; 876B
        lda     $0602,x                         ; 876C
        sta     $0606,x                         ; 876F
        lda     #$15                            ; 8772
        sta     $0601,x                         ; 8774
L8777:  lda     #$13                            ; 8777
        jsr     LE992                           ; 8779
        inc     $0701,x                         ; 877C
        jsr     LE0A4                           ; 877F
L8782:  lda     #$07                            ; 8782
        jmp     LE399                           ; 8784

; ----------------------------------------------------------------------------
L8787:  lda     $0602,x                         ; 8787
        sec                                     ; 878A
        sbc     #$02                            ; 878B
        sta     $0602,x                         ; 878D
        cmp     #$18                            ; 8790
        bcs     L8782                           ; 8792
        lda     #$25                            ; 8794
        sta     $0601,x                         ; 8796
        bne     L8777                           ; 8799
        lda     $0602,x                         ; 879B
        clc                                     ; 879E
        adc     #$02                            ; 879F
        sta     $0602,x                         ; 87A1
        cmp     #$B0                            ; 87A4
        bcc     L8782                           ; 87A6
        lda     #$15                            ; 87A8
        sta     $0601,x                         ; 87AA
        bne     L8777                           ; 87AD
        lda     $0602,x                         ; 87AF
        sec                                     ; 87B2
        sbc     #$02                            ; 87B3
        sta     $0602,x                         ; 87B5
        cmp     $0606,x                         ; 87B8
        bcs     L8782                           ; 87BB
        dec     $0601,x                         ; 87BD
        jsr     LE0A4                           ; 87C0
        lda     #$18                            ; 87C3
        jsr     LE992                           ; 87C5
        jmp     LE0A0                           ; 87C8

; ----------------------------------------------------------------------------
        jsr     L874F                           ; 87CB
        bne     L87F2                           ; 87CE
        lda     $033E                           ; 87D0
        beq     L87F3                           ; 87D3
L87D5:  lda     $BF                             ; 87D5
        and     #$04                            ; 87D7
        beq     L87F3                           ; 87D9
        lda     #$00                            ; 87DB
        ldy     $32                             ; 87DD
        beq     L87E3                           ; 87DF
        lda     #$02                            ; 87E1
L87E3:  sta     $0600,x                         ; 87E3
        lda     #$08                            ; 87E6
        jsr     LF0BE                           ; 87E8
        jsr     LE0A4                           ; 87EB
        lda     #$08                            ; 87EE
        sta     $95                             ; 87F0
L87F2:  rts                                     ; 87F2

; ----------------------------------------------------------------------------
L87F3:  jmp     L8742                           ; 87F3

; ----------------------------------------------------------------------------
        jsr     L874F                           ; 87F6
        bne     L87F2                           ; 87F9
        lda     $0303                           ; 87FB
        beq     L87F3                           ; 87FE
        bne     L87D5                           ; 8800
        lda     $0602                           ; 8802
        sta     $0602,x                         ; 8805
        lda     $0603                           ; 8808
        sta     $0603,x                         ; 880B
        lda     $0601                           ; 880E
        bne     L8817                           ; 8811
        sta     $0601,x                         ; 8813
        rts                                     ; 8816

; ----------------------------------------------------------------------------
L8817:  lda     #$03                            ; 8817
        jmp     LE399                           ; 8819

; ----------------------------------------------------------------------------
        jmp     LE0A0                           ; 881C

; ----------------------------------------------------------------------------
        lda     $0700,x                         ; 881F
        beq     L8833                           ; 8822
        dec     $0700,x                         ; 8824
        lda     #$01                            ; 8827
        sta     $03                             ; 8829
        lda     #$07                            ; 882B
        jsr     LFBE9                           ; 882D
        jmp     LE0A0                           ; 8830

; ----------------------------------------------------------------------------
L8833:  jmp     L8742                           ; 8833

; ----------------------------------------------------------------------------
        lda     #$07                            ; 8836
        jmp     LE399                           ; 8838

; ----------------------------------------------------------------------------
        lda     $7F                             ; 883B
        and     #$03                            ; 883D
        sta     $00                             ; 883F
        lda     $0602,x                         ; 8841
        sec                                     ; 8844
        sbc     $00                             ; 8845
        sta     $0602,x                         ; 8847
        cmp     #$10                            ; 884A
        bcs     L8851                           ; 884C
        jmp     L8A60                           ; 884E

; ----------------------------------------------------------------------------
L8851:  jmp     LE0A0                           ; 8851

; ----------------------------------------------------------------------------
        lda     $0336                           ; 8854
        beq     L885E                           ; 8857
        lda     $03C2                           ; 8859
        bne     L8861                           ; 885C
L885E:  jmp     L8A60                           ; 885E

; ----------------------------------------------------------------------------
L8861:  lda     $82                             ; 8861
        cmp     #$02                            ; 8863
        bne     L8871                           ; 8865
        lda     $0338                           ; 8867
        beq     L885E                           ; 886A
        lda     $03C6                           ; 886C
        beq     L885E                           ; 886F
L8871:  lda     #$20                            ; 8871
        sta     $0607,x                         ; 8873
        ldy     #$02                            ; 8876
        lda     $0601,x                         ; 8878
        and     #$50                            ; 887B
        beq     L8881                           ; 887D
        ldy     #$FE                            ; 887F
L8881:  lda     #$00                            ; 8881
        sty     $00                             ; 8883
        sta     $01                             ; 8885
        lda     $0601,x                         ; 8887
        and     #$30                            ; 888A
        bne     L8894                           ; 888C
        lda     #$00                            ; 888E
        sta     $00                             ; 8890
        sty     $01                             ; 8892
L8894:  jsr     LF8E6                           ; 8894
        beq     L88AA                           ; 8897
        lda     #$0F                            ; 8899
        jsr     LE399                           ; 889B
        lda     $0700,x                         ; 889E
        bne     L88AA                           ; 88A1
        lda     #$01                            ; 88A3
        sta     $30                             ; 88A5
        sta     $0700,x                         ; 88A7
L88AA:  rts                                     ; 88AA

; ----------------------------------------------------------------------------
        lda     $0700,x                         ; 88AB
        bne     L88B5                           ; 88AE
        lda     #$1C                            ; 88B0
        jsr     LE992                           ; 88B2
L88B5:  inc     $0700,x                         ; 88B5
        lda     $0700,x                         ; 88B8
        cmp     #$3C                            ; 88BB
        beq     L88D5                           ; 88BD
        bcc     L88D0                           ; 88BF
L88C1:  cmp     #$78                            ; 88C1
        bne     L88CB                           ; 88C3
        lda     #$00                            ; 88C5
        sta     $0601,x                         ; 88C7
        rts                                     ; 88CA

; ----------------------------------------------------------------------------
L88CB:  and     #$03                            ; 88CB
        jmp     LE3A3                           ; 88CD

; ----------------------------------------------------------------------------
L88D0:  and     #$07                            ; 88D0
        jmp     LE39B                           ; 88D2

; ----------------------------------------------------------------------------
L88D5:  lda     $BE                             ; 88D5
        and     #$30                            ; 88D7
        sta     $0334                           ; 88D9
        beq     L88EA                           ; 88DC
        lda     $031C                           ; 88DE
        ora     #$20                            ; 88E1
        sta     $031C                           ; 88E3
        lda     #$18                            ; 88E6
        sta     $24                             ; 88E8
L88EA:  lda     $BE                             ; 88EA
        and     #$CF                            ; 88EC
        sta     $BE                             ; 88EE
        lda     #$03                            ; 88F0
        sta     $30                             ; 88F2
        bne     L88D0                           ; 88F4
        inc     $0700,x                         ; 88F6
        lda     $0700,x                         ; 88F9
        cmp     #$3C                            ; 88FC
        php                                     ; 88FE
        bne     L8911                           ; 88FF
        lda     $0601,x                         ; 8901
        and     #$0F                            ; 8904
        sta     $30                             ; 8906
        cmp     #$06                            ; 8908
        bne     L8911                           ; 890A
        lda     #$1D                            ; 890C
        jsr     LE992                           ; 890E
L8911:  plp                                     ; 8911
        bcc     L88D0                           ; 8912
        bcs     L88C1                           ; 8914
        clc                                     ; 8916
        lda     $0704,x                         ; 8917
        adc     #$01                            ; 891A
        sta     $0704,x                         ; 891C
        cmp     #$20                            ; 891F
        bcc     L8936                           ; 8921
        stx     $3D                             ; 8923
        ldy     #$09                            ; 8925
L8927:  lda     #$00                            ; 8927
        sta     $0601,x                         ; 8929
        txa                                     ; 892C
        clc                                     ; 892D
        adc     #$08                            ; 892E
        tax                                     ; 8930
        dey                                     ; 8931
        bne     L8927                           ; 8932
        ldx     $3D                             ; 8934
L8936:  rts                                     ; 8936

; ----------------------------------------------------------------------------
L8937:  jsr     LFA84                           ; 8937
        lda     #$01                            ; 893A
        jmp     LE399                           ; 893C

; ----------------------------------------------------------------------------
        jsr     LE0FE                           ; 893F
        bne     L89A6                           ; 8942
        lda     $0702,x                         ; 8944
        beq     L894E                           ; 8947
        lda     #$00                            ; 8949
        sta     $0702,x                         ; 894B
L894E:  lda     $0601,x                         ; 894E
        and     #$0F                            ; 8951
        tay                                     ; 8953
        lda     L89BC,y                         ; 8954
        bne     L89A9                           ; 8957
        lda     $0700,x                         ; 8959
        beq     L8964                           ; 895C
        dec     $0700,x                         ; 895E
        jmp     L89A9                           ; 8961

; ----------------------------------------------------------------------------
L8964:  jsr     LA92C                           ; 8964
        bcs     L897F                           ; 8967
        cmp     #$03                            ; 8969
        bcs     L897F                           ; 896B
        ldy     #$02                            ; 896D
        lda     $9B,y                           ; 896F
        bne     L8977                           ; 8972
        jsr     LE0A2                           ; 8974
L8977:  lda     $96,y                           ; 8977
        jsr     LAA1C                           ; 897A
        bcs     L89A9                           ; 897D
L897F:  txa                                     ; 897F
        lsr     a                               ; 8980
        lsr     a                               ; 8981
        lsr     a                               ; 8982
        and     #$07                            ; 8983
        tay                                     ; 8985
        lda     $E0,y                           ; 8986
        and     #$1F                            ; 8989
        adc     #$06                            ; 898B
        sta     $0700,x                         ; 898D
        lda     $0703,x                         ; 8990
        and     #$0F                            ; 8993
        tay                                     ; 8995
        lda     $0601,x                         ; 8996
        and     #$0F                            ; 8999
        ora     L89AC,y                         ; 899B
        sta     $0601,x                         ; 899E
        iny                                     ; 89A1
        tya                                     ; 89A2
        sta     $0703,x                         ; 89A3
L89A6:  jsr     LE0A4                           ; 89A6
L89A9:  jmp     LE0A0                           ; 89A9

; ----------------------------------------------------------------------------
L89AC:  bpl     L89BE                           ; 89AC
        .byte   $80                             ; 89AE
        .byte   $80                             ; 89AF
        jsr     L4020                           ; 89B0
        rti                                     ; 89B3

; ----------------------------------------------------------------------------
        jsr     L4020                           ; 89B4
        rti                                     ; 89B7

; ----------------------------------------------------------------------------
        bpl     L89CA                           ; 89B8
        .byte   $80                             ; 89BA
        .byte   $80                             ; 89BB
L89BC:  brk                                     ; 89BC
        .byte   $01                             ; 89BD
L89BE:  ora     ($00,x)                         ; 89BE
        brk                                     ; 89C0
        ora     ($01,x)                         ; 89C1
        ora     ($00,x)                         ; 89C3
        brk                                     ; 89C5
        brk                                     ; 89C6
        ora     ($00,x)                         ; 89C7
        .byte   $01                             ; 89C9
L89CA:  ora     ($00,x)                         ; 89CA
        lda     $0605,x                         ; 89CC
        cmp     $0605                           ; 89CF
        bne     L8A22                           ; 89D2
        bit     $0707                           ; 89D4
        bvc     L8A22                           ; 89D7
        lda     $0601,x                         ; 89D9
        and     #$0F                            ; 89DC
        tay                                     ; 89DE
        lda     #$00                            ; 89DF
        sta     $0601,x                         ; 89E1
        lda     L8A23,y                         ; 89E4
        sta     $00                             ; 89E7
        lda     L8A27,y                         ; 89E9
        sta     $01                             ; 89EC
        lda     L8A2B,y                         ; 89EE
        sta     L0002                           ; 89F1
        tya                                     ; 89F3
        clc                                     ; 89F4
        adc     #$59                            ; 89F5
        sta     $03                             ; 89F7
        lda     $0496,y                         ; 89F9
        cmp     L8A2F,y                         ; 89FC
        bcs     L8A22                           ; 89FF
        clc                                     ; 8A01
        adc     #$01                            ; 8A02
        sta     $0496,y                         ; 8A04
        ldy     $00                             ; 8A07
        clc                                     ; 8A09
        lda     $0300,y                         ; 8A0A
        adc     $01                             ; 8A0D
        bcs     L8A15                           ; 8A0F
        cmp     L0002                           ; 8A11
        bcc     L8A17                           ; 8A13
L8A15:  lda     L0002                           ; 8A15
L8A17:  sta     $0300,y                         ; 8A17
        lda     $03                             ; 8A1A
L8A1C:  jsr     LE096                           ; 8A1C
        jmp     LE110                           ; 8A1F

; ----------------------------------------------------------------------------
L8A22:  rts                                     ; 8A22

; ----------------------------------------------------------------------------
L8A23:  asl     $07                             ; 8A23
        php                                     ; 8A25
        php                                     ; 8A26
L8A27:  ora     ($01,x)                         ; 8A27
        .byte   $32                             ; 8A29
        .byte   $64                             ; 8A2A
L8A2B:  asl     a                               ; 8A2B
        asl     a                               ; 8A2C
        .byte   $FF                             ; 8A2D
        .byte   $FF                             ; 8A2E
L8A2F:  .byte   $03                             ; 8A2F
        .byte   $03                             ; 8A30
        ora     ($01,x)                         ; 8A31
        lda     $0605,x                         ; 8A33
        jsr     LE088                           ; 8A36
        cmp     #$08                            ; 8A39
        beq     L8A65                           ; 8A3B
        lda     $0606,x                         ; 8A3D
        bne     L8A46                           ; 8A40
        lda     $C3                             ; 8A42
        beq     L8A65                           ; 8A44
L8A46:  ldy     #$13                            ; 8A46
        lda     $0605,x                         ; 8A48
        jsr     LE964                           ; 8A4B
        lda     $0606,x                         ; 8A4E
        bne     L8A65                           ; 8A51
        inc     $0606,x                         ; 8A53
        lda     #$67                            ; 8A56
        jsr     LE992                           ; 8A58
        lda     #$02                            ; 8A5B
        jmp     L8A1C                           ; 8A5D

; ----------------------------------------------------------------------------
L8A60:  lda     #$00                            ; 8A60
        sta     $0601,x                         ; 8A62
L8A65:  rts                                     ; 8A65

; ----------------------------------------------------------------------------
        lda     $0606,x                         ; 8A66
        beq     L8A77                           ; 8A69
L8A6B:  ldy     $0605,x                         ; 8A6B
        lda     $0500,y                         ; 8A6E
        cmp     #$1F                            ; 8A71
        beq     L8ADD                           ; 8A73
        bne     L8A92                           ; 8A75
L8A77:  jsr     LF510                           ; 8A77
        jsr     LF46B                           ; 8A7A
        asl     a                               ; 8A7D
        bcc     L8ADD                           ; 8A7E
        lda     $0602                           ; 8A80
        cmp     #$29                            ; 8A83
        bcc     L8A92                           ; 8A85
        lda     $0300                           ; 8A87
        beq     L8ADD                           ; 8A8A
        dec     $0300                           ; 8A8C
        jsr     LEAC1                           ; 8A8F
L8A92:  lda     $0601,x                         ; 8A92
        and     #$C0                            ; 8A95
        beq     L8AAF                           ; 8A97
        ldy     #$1F                            ; 8A99
        lda     $0605,x                         ; 8A9B
        jsr     LE964                           ; 8A9E
        ldy     #$1F                            ; 8AA1
        lda     $0605,x                         ; 8AA3
        sec                                     ; 8AA6
        sbc     #$10                            ; 8AA7
        jsr     LE964                           ; 8AA9
        jmp     L8AD8                           ; 8AAC

; ----------------------------------------------------------------------------
L8AAF:  ldy     #$1F                            ; 8AAF
        lda     $0605,x                         ; 8AB1
        jsr     LE964                           ; 8AB4
        ldy     #$1F                            ; 8AB7
        lda     $0605,x                         ; 8AB9
        clc                                     ; 8ABC
        adc     #$01                            ; 8ABD
        jsr     LE964                           ; 8ABF
        ldy     #$B6                            ; 8AC2
        lda     $0605,x                         ; 8AC4
        sec                                     ; 8AC7
        sbc     #$10                            ; 8AC8
        jsr     LE964                           ; 8ACA
        ldy     #$B6                            ; 8ACD
        lda     $0605,x                         ; 8ACF
        sec                                     ; 8AD2
        sbc     #$0F                            ; 8AD3
        jsr     LE964                           ; 8AD5
L8AD8:  lda     #$01                            ; 8AD8
        sta     $0606,x                         ; 8ADA
L8ADD:  rts                                     ; 8ADD

; ----------------------------------------------------------------------------
        lda     $0606,x                         ; 8ADE
        beq     L8AE6                           ; 8AE1
        jmp     L8A6B                           ; 8AE3

; ----------------------------------------------------------------------------
L8AE6:  lda     $93                             ; 8AE6
        and     #$3F                            ; 8AE8
        beq     L8A92                           ; 8AEA
        lda     $0602                           ; 8AEC
        cmp     #$29                            ; 8AEF
        bcs     L8ADD                           ; 8AF1
        jmp     L8A92                           ; 8AF3

; ----------------------------------------------------------------------------
        lda     $0700,x                         ; 8AF6
        bne     L8B07                           ; 8AF9
        ldy     $031A                           ; 8AFB
        lda     $0601,y                         ; 8AFE
        bne     L8B75                           ; 8B01
        lda     #$40                            ; 8B03
        sta     $93                             ; 8B05
L8B07:  inc     $0700,x                         ; 8B07
        lda     $0700,x                         ; 8B0A
        cmp     #$78                            ; 8B0D
        beq     L8B66                           ; 8B0F
        and     #$0F                            ; 8B11
        bne     L8B36                           ; 8B13
        lda     $04AD                           ; 8B15
        sta     $00                             ; 8B18
        lda     $04AE                           ; 8B1A
        sta     $01                             ; 8B1D
        lda     $04AF                           ; 8B1F
        sta     L0002                           ; 8B22
        jsr     LF085                           ; 8B24
        lda     $00                             ; 8B27
        sta     $04AD                           ; 8B29
        lda     $01                             ; 8B2C
        sta     $04AE                           ; 8B2E
        lda     L0002                           ; 8B31
        sta     $04AF                           ; 8B33
L8B36:  lda     $0700,x                         ; 8B36
        cmp     #$6E                            ; 8B39
        bne     L8B75                           ; 8B3B
        ldy     #$E3                            ; 8B3D
        lda     $0605,x                         ; 8B3F
        jsr     LE964                           ; 8B42
        ldy     #$E4                            ; 8B45
        lda     $0605,x                         ; 8B47
        clc                                     ; 8B4A
        adc     #$01                            ; 8B4B
        jsr     LE964                           ; 8B4D
        ldy     #$1F                            ; 8B50
        lda     $0605,x                         ; 8B52
        sec                                     ; 8B55
        sbc     #$10                            ; 8B56
        jsr     LE964                           ; 8B58
        ldy     #$1F                            ; 8B5B
        lda     $0605,x                         ; 8B5D
        sec                                     ; 8B60
        sbc     #$0F                            ; 8B61
        jmp     LE964                           ; 8B63

; ----------------------------------------------------------------------------
L8B66:  lda     #$00                            ; 8B66
        sta     $0601,x                         ; 8B68
        sta     $2A                             ; 8B6B
        lda     $0707                           ; 8B6D
        ora     #$02                            ; 8B70
        sta     $0707                           ; 8B72
L8B75:  rts                                     ; 8B75

; ----------------------------------------------------------------------------
        lda     $7F                             ; 8B76
        and     #$03                            ; 8B78
        bne     L8B7F                           ; 8B7A
        jsr     LE0A2                           ; 8B7C
L8B7F:  lda     $0603,x                         ; 8B7F
        lsr     a                               ; 8B82
        lsr     a                               ; 8B83
        lsr     a                               ; 8B84
        lsr     a                               ; 8B85
        sta     $00                             ; 8B86
        lda     $0602,x                         ; 8B88
        and     #$F0                            ; 8B8B
        ora     $00                             ; 8B8D
        cmp     $0605                           ; 8B8F
        beq     L8BA9                           ; 8B92
        cmp     $0317                           ; 8B94
        beq     L8BA9                           ; 8B97
        cmp     $0318                           ; 8B99
        beq     L8BA9                           ; 8B9C
        inc     $0700,x                         ; 8B9E
        bne     L8BA6                           ; 8BA1
        jmp     L8A60                           ; 8BA3

; ----------------------------------------------------------------------------
L8BA6:  jmp     LE0A0                           ; 8BA6

; ----------------------------------------------------------------------------
L8BA9:  lda     $0601,x                         ; 8BA9
        and     #$0F                            ; 8BAC
        tay                                     ; 8BAE
        lda     #$00                            ; 8BAF
        sta     $0601,x                         ; 8BB1
        tya                                     ; 8BB4
        jsr     LE97D                           ; 8BB5
        cpy     $8B                             ; 8BB8
        iny                                     ; 8BBA
        .byte   $8B                             ; 8BBB
        .byte   $D2                             ; 8BBC
        .byte   $8B                             ; 8BBD
        sbc     #$8B                            ; 8BBE
        ora     $8C,x                           ; 8BC0
        .byte   $27                             ; 8BC2
        sty     $01A9                           ; 8BC3
        bne     L8BCA                           ; 8BC6
        lda     #$14                            ; 8BC8
L8BCA:  clc                                     ; 8BCA
        adc     $0308                           ; 8BCB
        sta     $0308                           ; 8BCE
        rts                                     ; 8BD1

; ----------------------------------------------------------------------------
        clc                                     ; 8BD2
        lda     $81                             ; 8BD3
        adc     #$14                            ; 8BD5
        bcs     L8BDD                           ; 8BD7
        cmp     $91                             ; 8BD9
        bcc     L8BDF                           ; 8BDB
L8BDD:  lda     $91                             ; 8BDD
L8BDF:  sta     $81                             ; 8BDF
        lda     #$1A                            ; 8BE1
        jsr     LE992                           ; 8BE3
        jmp     LEAB9                           ; 8BE6

; ----------------------------------------------------------------------------
        lda     #$00                            ; 8BE9
        sta     $00                             ; 8BEB
        sta     L0002                           ; 8BED
        lda     #$02                            ; 8BEF
        sta     $01                             ; 8BF1
        jsr     LEC21                           ; 8BF3
        jsr     LF6E8                           ; 8BF6
        jsr     LEBFF                           ; 8BF9
        bcc     L8C0D                           ; 8BFC
        jsr     LF6E8                           ; 8BFE
        lda     $00                             ; 8C01
        sta     $8C                             ; 8C03
        lda     $01                             ; 8C05
        sta     $8D                             ; 8C07
        lda     L0002                           ; 8C09
        sta     $8E                             ; 8C0B
L8C0D:  lda     #$1B                            ; 8C0D
        jsr     LE992                           ; 8C0F
        jmp     LEABD                           ; 8C12

; ----------------------------------------------------------------------------
        lda     $0300                           ; 8C15
        cmp     #$09                            ; 8C18
        bcs     L8C1F                           ; 8C1A
        inc     $0300                           ; 8C1C
L8C1F:  lda     #$1F                            ; 8C1F
        jsr     LE992                           ; 8C21
        jmp     LEAC1                           ; 8C24

; ----------------------------------------------------------------------------
        ldy     $32                             ; 8C27
        beq     L8C41                           ; 8C29
        lda     $0707                           ; 8C2B
        and     #$02                            ; 8C2E
        bne     L8C41                           ; 8C30
        lda     #$0A                            ; 8C32
        sta     $2A                             ; 8C34
        lda     $0707                           ; 8C36
        ora     #$02                            ; 8C39
        sta     $0707                           ; 8C3B
        jmp     L8C4B                           ; 8C3E

; ----------------------------------------------------------------------------
L8C41:  lda     $0301                           ; 8C41
        cmp     #$09                            ; 8C44
        bcs     L8C4B                           ; 8C46
        inc     $0301                           ; 8C48
L8C4B:  lda     #$20                            ; 8C4B
        jsr     LE992                           ; 8C4D
        jmp     LEAC1                           ; 8C50

; ----------------------------------------------------------------------------
        lda     #$70                            ; 8C53
        sta     $0602,x                         ; 8C55
        lda     #$80                            ; 8C58
        sta     $0603,x                         ; 8C5A
        lda     $0704,x                         ; 8C5D
        bne     L8C9D                           ; 8C60
        jsr     LF3E0                           ; 8C62
        bpl     L8CC1                           ; 8C65
        jsr     LA50F                           ; 8C67
        beq     L8C72                           ; 8C6A
        jsr     L9F57                           ; 8C6C
        jmp     L8A60                           ; 8C6F

; ----------------------------------------------------------------------------
L8C72:  lda     $0602,x                         ; 8C72
        sta     $0602                           ; 8C75
        sta     $060A                           ; 8C78
        lda     $0603,x                         ; 8C7B
        sta     $0603                           ; 8C7E
        sta     $060B                           ; 8C81
        lda     #$28                            ; 8C84
        sta     $01                             ; 8C86
        lda     #$00                            ; 8C88
        sta     L0002                           ; 8C8A
        lda     #$0C                            ; 8C8C
        sta     $00                             ; 8C8E
        lda     #$30                            ; 8C90
        sta     $0704,x                         ; 8C92
        jsr     LFA29                           ; 8C95
        lda     #$0B                            ; 8C98
        sta     $30                             ; 8C9A
        rts                                     ; 8C9C

; ----------------------------------------------------------------------------
L8C9D:  sec                                     ; 8C9D
        sbc     #$01                            ; 8C9E
        sta     $0704,x                         ; 8CA0
        bne     L8CC1                           ; 8CA3
        jsr     LF6E8                           ; 8CA5
        lda     $00                             ; 8CA8
        sta     $8C                             ; 8CAA
        lda     $01                             ; 8CAC
        sta     $8D                             ; 8CAE
        lda     L0002                           ; 8CB0
        sta     $8E                             ; 8CB2
        jsr     LEABD                           ; 8CB4
        lda     #$00                            ; 8CB7
        sta     $0601,x                         ; 8CB9
        jsr     L9960                           ; 8CBC
        ldx     #$00                            ; 8CBF
L8CC1:  rts                                     ; 8CC1

; ----------------------------------------------------------------------------
        lda     $33                             ; 8CC2
        cmp     #$0C                            ; 8CC4
        bcc     L8CD3                           ; 8CC6
        cmp     #$0F                            ; 8CC8
        bcs     L8CD3                           ; 8CCA
        lda     #$00                            ; 8CCC
        sta     $03                             ; 8CCE
        jmp     LA5AC                           ; 8CD0

; ----------------------------------------------------------------------------
L8CD3:  lda     $0704,x                         ; 8CD3
        bne     L8D02                           ; 8CD6
        lda     #$FF                            ; 8CD8
        sta     $0604,x                         ; 8CDA
        lda     $0700,x                         ; 8CDD
        bne     L8CEB                           ; 8CE0
        lda     $E3                             ; 8CE2
        and     #$1F                            ; 8CE4
        adc     #$46                            ; 8CE6
        sta     $0700,x                         ; 8CE8
L8CEB:  dec     $0700,x                         ; 8CEB
        bne     L8D01                           ; 8CEE
        lda     $0605,x                         ; 8CF0
        sta     $0704,x                         ; 8CF3
L8CF6:  lda     #$67                            ; 8CF6
        jsr     LFAB3                           ; 8CF8
        jsr     LE0A4                           ; 8CFB
L8CFE:  jmp     LE0A0                           ; 8CFE

; ----------------------------------------------------------------------------
L8D01:  rts                                     ; 8D01

; ----------------------------------------------------------------------------
L8D02:  jsr     LF3E0                           ; 8D02
        bpl     L8D12                           ; 8D05
        lda     $20                             ; 8D07
        ora     $29                             ; 8D09
        bne     L8D12                           ; 8D0B
        lda     #$04                            ; 8D0D
        jsr     LA43E                           ; 8D0F
L8D12:  lda     #$01                            ; 8D12
        sta     $03                             ; 8D14
        lda     #$03                            ; 8D16
        jsr     LFAD7                           ; 8D18
        beq     L8D21                           ; 8D1B
        bcs     L8CF6                           ; 8D1D
        bcc     L8CFE                           ; 8D1F
L8D21:  lda     L0002                           ; 8D21
        sta     $0601,x                         ; 8D23
        lda     $0704,x                         ; 8D26
        jmp     LE086                           ; 8D29

; ----------------------------------------------------------------------------
L8D2C:  lda     $0704,x                         ; 8D2C
        bne     L8D36                           ; 8D2F
        lda     #$20                            ; 8D31
        sta     $0704,x                         ; 8D33
L8D36:  lda     $7F                             ; 8D36
        and     #$03                            ; 8D38
        bne     L8D44                           ; 8D3A
        dec     $0704,x                         ; 8D3C
        bne     L8D44                           ; 8D3F
        jmp     L8A60                           ; 8D41

; ----------------------------------------------------------------------------
L8D44:  rts                                     ; 8D44

; ----------------------------------------------------------------------------
        lda     $0707,x                         ; 8D45
        and     #$10                            ; 8D48
        bne     L8DA1                           ; 8D4A
        lda     $20                             ; 8D4C
        ora     $22                             ; 8D4E
        ora     $29                             ; 8D50
        bne     L8DA1                           ; 8D52
        lda     $0602,x                         ; 8D54
        sta     $0D                             ; 8D57
        lda     $0603,x                         ; 8D59
        sta     $0C                             ; 8D5C
        jsr     LF40D                           ; 8D5E
        beq     L8DA1                           ; 8D61
        and     #$10                            ; 8D63
        beq     L8D6C                           ; 8D65
        jsr     LA3F6                           ; 8D67
        bcs     L8DA1                           ; 8D6A
L8D6C:  lda     $0701,x                         ; 8D6C
        jsr     LA43E                           ; 8D6F
        lda     #$22                            ; 8D72
        jsr     LE992                           ; 8D74
        lda     $0702,x                         ; 8D77
        and     #$F0                            ; 8D7A
        beq     L8D96                           ; 8D7C
        sta     $00                             ; 8D7E
        inc     $0702                           ; 8D80
        lda     $0702                           ; 8D83
        eor     #$02                            ; 8D86
        bne     L8D96                           ; 8D88
        sta     $0702                           ; 8D8A
        lda     $00                             ; 8D8D
        lsr     a                               ; 8D8F
        lsr     a                               ; 8D90
        lsr     a                               ; 8D91
        lsr     a                               ; 8D92
        jsr     LA482                           ; 8D93
L8D96:  lda     $0707,x                         ; 8D96
        bmi     L8DA1                           ; 8D99
        lda     #$00                            ; 8D9B
        sta     $0601,x                         ; 8D9D
        rts                                     ; 8DA0

; ----------------------------------------------------------------------------
L8DA1:  jmp     LA383                           ; 8DA1

; ----------------------------------------------------------------------------
        lda     #$03                            ; 8DA4
L8DA6:  dec     $0700,x                         ; 8DA6
        beq     L8DB6                           ; 8DA9
L8DAB:  and     $0700,x                         ; 8DAB
        bne     L8DB3                           ; 8DAE
        jsr     LE0A2                           ; 8DB0
L8DB3:  jmp     LE0A0                           ; 8DB3

; ----------------------------------------------------------------------------
L8DB6:  jsr     LA4AE                           ; 8DB6
        jmp     LA5CB                           ; 8DB9

; ----------------------------------------------------------------------------
        lda     #$07                            ; 8DBC
        bne     L8DA6                           ; 8DBE
        lda     #$03                            ; 8DC0
L8DC2:  dec     $0700,x                         ; 8DC2
        bne     L8DAB                           ; 8DC5
        jmp     LA5CB                           ; 8DC7

; ----------------------------------------------------------------------------
L8DCA:  lda     #$07                            ; 8DCA
        bne     L8DC2                           ; 8DCC
        dec     $0700,x                         ; 8DCE
        beq     L8DDB                           ; 8DD1
        lda     $0700,x                         ; 8DD3
        and     #$07                            ; 8DD6
        jmp     LE39B                           ; 8DD8

; ----------------------------------------------------------------------------
L8DDB:  lda     $0607,x                         ; 8DDB
        sta     $00                             ; 8DDE
        cmp     #$03                            ; 8DE0
        bcc     L8DEE                           ; 8DE2
        txa                                     ; 8DE4
        lsr     a                               ; 8DE5
        lsr     a                               ; 8DE6
        lsr     a                               ; 8DE7
        and     #$03                            ; 8DE8
        adc     $00                             ; 8DEA
        sta     $00                             ; 8DEC
L8DEE:  lda     $00                             ; 8DEE
        jsr     LF0BE                           ; 8DF0
        jmp     LE0A4                           ; 8DF3

; ----------------------------------------------------------------------------
L8DF6:  lda     $23                             ; 8DF6
        bne     L8E12                           ; 8DF8
        lda     #$07                            ; 8DFA
        jsr     LF0BE                           ; 8DFC
        lda     #$3C                            ; 8DFF
        sta     $0700,x                         ; 8E01
        lda     #$00                            ; 8E04
        sta     $0701,x                         ; 8E06
        sta     $0702,x                         ; 8E09
        jsr     LE0A4                           ; 8E0C
L8E0F:  jmp     LA64C                           ; 8E0F

; ----------------------------------------------------------------------------
L8E12:  jsr     LF3E0                           ; 8E12
        beq     L8E1D                           ; 8E15
        jsr     LA52C                           ; 8E17
        jmp     L8E0F                           ; 8E1A

; ----------------------------------------------------------------------------
L8E1D:  lda     $22                             ; 8E1D
        bne     L8E0F                           ; 8E1F
        jsr     LA92C                           ; 8E21
        bcs     L8E2A                           ; 8E24
        cmp     #$03                            ; 8E26
        bcc     L8E40                           ; 8E28
L8E2A:  lda     $7F                             ; 8E2A
L8E2C:  and     #$03                            ; 8E2C
        tay                                     ; 8E2E
        lda     $0601,x                         ; 8E2F
        and     #$0F                            ; 8E32
        ora     L8E55,y                         ; 8E34
        sta     $0601,x                         ; 8E37
        jsr     LE0A4                           ; 8E3A
        jmp     L8E0F                           ; 8E3D

; ----------------------------------------------------------------------------
L8E40:  lda     $9E                             ; 8E40
        bne     L8E47                           ; 8E42
        jsr     LE0A2                           ; 8E44
L8E47:  lda     $99                             ; 8E47
        jsr     LAA1C                           ; 8E49
        beq     L8E0F                           ; 8E4C
        lda     $E0                             ; 8E4E
        lsr     a                               ; 8E50
        bcs     L8E2C                           ; 8E51
        bcc     L8E0F                           ; 8E53
L8E55:  .byte   $80                             ; 8E55
        jsr     L1040                           ; 8E56
        lda     $0700,x                         ; 8E59
        beq     L8E66                           ; 8E5C
        dec     $0700,x                         ; 8E5E
        and     #$07                            ; 8E61
        jmp     LE39B                           ; 8E63

; ----------------------------------------------------------------------------
L8E66:  lda     $0606,x                         ; 8E66
        sta     $0600,x                         ; 8E69
        lda     #$00                            ; 8E6C
        sta     $0606,x                         ; 8E6E
        sta     $0607,x                         ; 8E71
        jsr     L950A                           ; 8E74
        jsr     LA874                           ; 8E77
        jsr     LE0A4                           ; 8E7A
        jmp     LE0A0                           ; 8E7D

; ----------------------------------------------------------------------------
L8E80:  lda     $0700,x                         ; 8E80
        bne     L8E9C                           ; 8E83
        sta     $0701,x                         ; 8E85
        txa                                     ; 8E88
        lsr     a                               ; 8E89
        lsr     a                               ; 8E8A
        lsr     a                               ; 8E8B
        and     #$07                            ; 8E8C
        tay                                     ; 8E8E
        lda     $E0,y                           ; 8E8F
        and     #$1F                            ; 8E92
        adc     #$1E                            ; 8E94
        sta     $0700,x                         ; 8E96
L8E99:  jmp     LA64C                           ; 8E99

; ----------------------------------------------------------------------------
L8E9C:  and     #$1F                            ; 8E9C
        bne     L8EA3                           ; 8E9E
        jsr     LE0A2                           ; 8EA0
L8EA3:  dec     $0700,x                         ; 8EA3
        bne     L8E99                           ; 8EA6
        lda     #$05                            ; 8EA8
        jsr     LF0BE                           ; 8EAA
        lda     #$23                            ; 8EAD
        jsr     LF85D                           ; 8EAF
        jsr     LE0A4                           ; 8EB2
        jmp     LA874                           ; 8EB5

; ----------------------------------------------------------------------------
L8EB8:  dec     $0700,x                         ; 8EB8
        lda     $0700,x                         ; 8EBB
        beq     L8EC5                           ; 8EBE
        and     #$01                            ; 8EC0
        jmp     LE3A3                           ; 8EC2

; ----------------------------------------------------------------------------
L8EC5:  jsr     LA4AE                           ; 8EC5
        jmp     LA5CB                           ; 8EC8

; ----------------------------------------------------------------------------
L8ECB:  inc     $0606,x                         ; 8ECB
        lda     $0606,x                         ; 8ECE
        and     #$0F                            ; 8ED1
        cmp     #$09                            ; 8ED3
        bne     L8EFC                           ; 8ED5
        jsr     L950A                           ; 8ED7
        lda     #$00                            ; 8EDA
        sta     $0606,x                         ; 8EDC
        sta     $0700,x                         ; 8EDF
        lda     $0602,x                         ; 8EE2
        and     #$F0                            ; 8EE5
        ora     #$08                            ; 8EE7
        sta     $0602,x                         ; 8EE9
        lda     $0603,x                         ; 8EEC
        and     #$F0                            ; 8EEF
        ora     #$08                            ; 8EF1
        sta     $0603,x                         ; 8EF3
        jsr     LE0A4                           ; 8EF6
L8EF9:  jmp     LA64C                           ; 8EF9

; ----------------------------------------------------------------------------
L8EFC:  jsr     LA839                           ; 8EFC
        lda     L0002                           ; 8EFF
        and     #$01                            ; 8F01
        bne     L8EF9                           ; 8F03
        lda     $0601,x                         ; 8F05
        pha                                     ; 8F08
        lda     $0606,x                         ; 8F09
        sta     $0601,x                         ; 8F0C
        jsr     LA92C                           ; 8F0F
        bcs     L8F22                           ; 8F12
        cmp     #$03                            ; 8F14
        bcc     L8F1D                           ; 8F16
        lda     $0707,x                         ; 8F18
        bpl     L8F22                           ; 8F1B
L8F1D:  lda     #$02                            ; 8F1D
        jsr     LAA1C                           ; 8F1F
L8F22:  pla                                     ; 8F22
        sta     $0601,x                         ; 8F23
        jmp     L8EF9                           ; 8F26

; ----------------------------------------------------------------------------
L8F29:  jsr     LA666                           ; 8F29
        bne     L8F58                           ; 8F2C
        ldy     #$02                            ; 8F2E
        lda     $BE                             ; 8F30
        bpl     L8F35                           ; 8F32
        iny                                     ; 8F34
L8F35:  jsr     LAF74                           ; 8F35
        bit     $BE                             ; 8F38
        bvs     L8F3F                           ; 8F3A
L8F3C:  jmp     LA64C                           ; 8F3C

; ----------------------------------------------------------------------------
L8F3F:  lda     $0702,x                         ; 8F3F
        bmi     L8F75                           ; 8F42
        cmp     #$01                            ; 8F44
        bne     L8F52                           ; 8F46
        lda     $0601,x                         ; 8F48
        and     $08                             ; 8F4B
        bne     L8F52                           ; 8F4D
        inc     $0702,x                         ; 8F4F
L8F52:  jsr     LA1A7                           ; 8F52
        jmp     L8F3C                           ; 8F55

; ----------------------------------------------------------------------------
L8F58:  lda     $0705,x                         ; 8F58
        beq     L8F3C                           ; 8F5B
        lda     #$00                            ; 8F5D
        sta     $0705,x                         ; 8F5F
        lda     #$3E                            ; 8F62
        sta     $0600,x                         ; 8F64
        jsr     L950A                           ; 8F67
        jsr     LE0A4                           ; 8F6A
        jsr     LA874                           ; 8F6D
        lda     #$3A                            ; 8F70
        jsr     LE992                           ; 8F72
L8F75:  jmp     LA64C                           ; 8F75

; ----------------------------------------------------------------------------
        lda     $0700,x                         ; 8F78
        cmp     #$1E                            ; 8F7B
        beq     L8F8C                           ; 8F7D
        inc     $0700,x                         ; 8F7F
        and     #$07                            ; 8F82
        bne     L8F97                           ; 8F84
        jsr     LE0A2                           ; 8F86
        jmp     L8F97                           ; 8F89

; ----------------------------------------------------------------------------
L8F8C:  lda     #$00                            ; 8F8C
        sta     $0700,x                         ; 8F8E
        jsr     L950A                           ; 8F91
        jsr     LE0A4                           ; 8F94
L8F97:  jsr     LA666                           ; 8F97
        php                                     ; 8F9A
        jsr     LA64C                           ; 8F9B
        plp                                     ; 8F9E
        rts                                     ; 8F9F

; ----------------------------------------------------------------------------
        jsr     LF877                           ; 8FA0
        bne     L8FDA                           ; 8FA3
        lda     $0601,x                         ; 8FA5
        bne     L8FAF                           ; 8FA8
        lda     L0002                           ; 8FAA
        sta     $0601,x                         ; 8FAC
L8FAF:  lda     $0602,x                         ; 8FAF
        and     #$F0                            ; 8FB2
        sta     $00                             ; 8FB4
        lda     $0603,x                         ; 8FB6
        lsr     a                               ; 8FB9
        lsr     a                               ; 8FBA
        lsr     a                               ; 8FBB
        lsr     a                               ; 8FBC
        ora     $00                             ; 8FBD
        jsr     LE086                           ; 8FBF
        lda     $0605,x                         ; 8FC2
        jsr     LE088                           ; 8FC5
        cmp     #$0B                            ; 8FC8
        bne     L8FDD                           ; 8FCA
        lda     $E0                             ; 8FCC
        and     #$0F                            ; 8FCE
        tay                                     ; 8FD0
        lda     $B036,y                         ; 8FD1
        sta     $0601,x                         ; 8FD4
L8FD7:  jsr     LE0A4                           ; 8FD7
L8FDA:  jmp     LA64C                           ; 8FDA

; ----------------------------------------------------------------------------
L8FDD:  jsr     L950A                           ; 8FDD
        jmp     L8FD7                           ; 8FE0

; ----------------------------------------------------------------------------
        jsr     L8E80                           ; 8FE3
        lda     $0701,x                         ; 8FE6
        beq     L8FEE                           ; 8FE9
        sta     $0705,x                         ; 8FEB
L8FEE:  rts                                     ; 8FEE

; ----------------------------------------------------------------------------
        jsr     L950A                           ; 8FEF
        sta     $0601,x                         ; 8FF2
L8FF5:  jsr     LA874                           ; 8FF5
        lda     $0707,x                         ; 8FF8
        and     #$20                            ; 8FFB
        beq     L9001                           ; 8FFD
        dec     $93                             ; 8FFF
L9001:  jsr     LE0A4                           ; 9001
        jmp     LA64C                           ; 9004

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 9007
        bne     L9011                           ; 900A
        ldy     #$01                            ; 900C
        jsr     LAF74                           ; 900E
L9011:  jmp     LA64C                           ; 9011

; ----------------------------------------------------------------------------
L9014:  lda     $0700,x                         ; 9014
        bne     L9021                           ; 9017
        sta     $0701,x                         ; 9019
        lda     #$3C                            ; 901C
        sta     $0700,x                         ; 901E
L9021:  dec     $0700,x                         ; 9021
        beq     L9030                           ; 9024
        and     #$03                            ; 9026
        bne     L903E                           ; 9028
        jsr     LE0A2                           ; 902A
        jmp     L903B                           ; 902D

; ----------------------------------------------------------------------------
L9030:  jsr     L950A                           ; 9030
        lda     #$F0                            ; 9033
        sta     $0705,x                         ; 9035
        jmp     L8FF5                           ; 9038

; ----------------------------------------------------------------------------
L903B:  jmp     LA64C                           ; 903B

; ----------------------------------------------------------------------------
L903E:  rts                                     ; 903E

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 903F
        bne     L907B                           ; 9042
        ldy     #$02                            ; 9044
        jsr     LAF74                           ; 9046
        lda     $0702,x                         ; 9049
        cmp     #$01                            ; 904C
        bne     L905A                           ; 904E
        lda     $0601,x                         ; 9050
        and     $08                             ; 9053
        bne     L905A                           ; 9055
        inc     $0702,x                         ; 9057
L905A:  lda     $BE                             ; 905A
        and     #$40                            ; 905C
        beq     L9063                           ; 905E
        jsr     LA1A7                           ; 9060
L9063:  dec     $0705,x                         ; 9063
        bne     L907B                           ; 9066
        lda     #$00                            ; 9068
        sta     $0700,x                         ; 906A
        sta     $0701,x                         ; 906D
        sta     $0702,x                         ; 9070
        lda     #$05                            ; 9073
        jsr     LF0BE                           ; 9075
        jsr     LE0A4                           ; 9078
L907B:  jmp     LA64C                           ; 907B

; ----------------------------------------------------------------------------
        lda     $0700,x                         ; 907E
        cmp     #$1E                            ; 9081
        beq     L9092                           ; 9083
        inc     $0700,x                         ; 9085
        and     #$03                            ; 9088
        bne     L909D                           ; 908A
        jsr     LE0A2                           ; 908C
        jmp     L909D                           ; 908F

; ----------------------------------------------------------------------------
L9092:  lda     #$00                            ; 9092
        sta     $0700,x                         ; 9094
        jsr     L950A                           ; 9097
        jsr     LE0A4                           ; 909A
L909D:  jsr     LA666                           ; 909D
        jmp     LA64C                           ; 90A0

; ----------------------------------------------------------------------------
L90A3:  lda     $0700,x                         ; 90A3
        bne     L90AD                           ; 90A6
        lda     #$3C                            ; 90A8
        sta     $0700,x                         ; 90AA
L90AD:  dec     $0700,x                         ; 90AD
        nop                                     ; 90B0
        nop                                     ; 90B1
        lda     $0706,x                         ; 90B2
        cmp     #$1F                            ; 90B5
        bcc     L90BD                           ; 90B7
        cmp     #$C0                            ; 90B9
        bcc     L90CA                           ; 90BB
L90BD:  lda     $E0                             ; 90BD
        and     #$FF                            ; 90BF
        beq     L90E4                           ; 90C1
        adc     $0605,x                         ; 90C3
        sta     $0706,x                         ; 90C6
L90C9:  rts                                     ; 90C9

; ----------------------------------------------------------------------------
L90CA:  jsr     LE088                           ; 90CA
        cmp     #$00                            ; 90CD
        bne     L90BD                           ; 90CF
        lda     $0700,x                         ; 90D1
        bne     L90C9                           ; 90D4
        lda     #$00                            ; 90D6
        jsr     LF0BE                           ; 90D8
        lda     $0706,x                         ; 90DB
        jsr     LE086                           ; 90DE
        jsr     LE0A4                           ; 90E1
L90E4:  jmp     LA64C                           ; 90E4

; ----------------------------------------------------------------------------
L90E7:  lda     $0600,x                         ; 90E7
        cmp     #$14                            ; 90EA
        bne     L9102                           ; 90EC
        lda     #$00                            ; 90EE
        sta     $0702,x                         ; 90F0
        inc     $0700,x                         ; 90F3
        lda     $0700,x                         ; 90F6
        cmp     #$3C                            ; 90F9
        bne     L9108                           ; 90FB
        lda     #$00                            ; 90FD
        sta     $0700,x                         ; 90FF
L9102:  jsr     L950A                           ; 9102
        jmp     L8FF5                           ; 9105

; ----------------------------------------------------------------------------
L9108:  jmp     LA64C                           ; 9108

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 910B
        bne     L912F                           ; 910E
        lda     $05                             ; 9110
        bpl     L9132                           ; 9112
        lda     $29                             ; 9114
        bne     L9132                           ; 9116
        lda     #$04                            ; 9118
        jsr     LF0BE                           ; 911A
        lda     #$02                            ; 911D
        sta     $21                             ; 911F
        lda     #$00                            ; 9121
        sta     $0700,x                         ; 9123
        sta     $0701,x                         ; 9126
        sta     $0702,x                         ; 9129
        jsr     LE0A4                           ; 912C
L912F:  jmp     LA64C                           ; 912F

; ----------------------------------------------------------------------------
L9132:  ldy     #$01                            ; 9132
        jsr     L80DB                           ; 9134
        bne     L913B                           ; 9137
        iny                                     ; 9139
        iny                                     ; 913A
L913B:  jsr     LB0F2                           ; 913B
        jmp     L912F                           ; 913E

; ----------------------------------------------------------------------------
        lda     $29                             ; 9141
        bne     L9102                           ; 9143
        lda     #$02                            ; 9145
        sta     $21                             ; 9147
        lda     $0602                           ; 9149
        sta     $0602,x                         ; 914C
        lda     $0603                           ; 914F
        sta     $0603,x                         ; 9152
        lda     $7F                             ; 9155
        and     #$1F                            ; 9157
        bne     L9163                           ; 9159
        sta     $0700,x                         ; 915B
        lda     #$02                            ; 915E
        jsr     LA43E                           ; 9160
L9163:  lda     $C2                             ; 9163
        and     #$F3                            ; 9165
        beq     L9179                           ; 9167
        inc     $0700,x                         ; 9169
        lda     $0700,x                         ; 916C
        cmp     #$03                            ; 916F
        bne     L9179                           ; 9171
        jsr     LA839                           ; 9173
        jsr     LA52C                           ; 9176
L9179:  jmp     LA64C                           ; 9179

; ----------------------------------------------------------------------------
        lda     $033A                           ; 917C
        bmi     L9181                           ; 917F
L9181:  lda     #$00                            ; 9181
        sta     $0701,x                         ; 9183
        lda     $0605,x                         ; 9186
        jsr     LE088                           ; 9189
        lsr     a                               ; 918C
        bne     L919A                           ; 918D
        lda     $0605,x                         ; 918F
        cmp     #$3F                            ; 9192
        bcc     L919A                           ; 9194
        cmp     #$B0                            ; 9196
        bcc     L91A4                           ; 9198
L919A:  lda     $E1                             ; 919A
        and     #$3F                            ; 919C
        adc     $0605,x                         ; 919E
        jmp     LE086                           ; 91A1

; ----------------------------------------------------------------------------
L91A4:  jsr     L91BB                           ; 91A4
        beq     L919A                           ; 91A7
        ora     #$05                            ; 91A9
        sta     $0601,x                         ; 91AB
        lda     #$03                            ; 91AE
        sta     $0703,x                         ; 91B0
        lda     #$1F                            ; 91B3
        sta     $0700,x                         ; 91B5
        jmp     LE0A4                           ; 91B8

; ----------------------------------------------------------------------------
L91BB:  lda     #$00                            ; 91BB
        sta     $00                             ; 91BD
        lda     $0704,x                         ; 91BF
        inc     $0704,x                         ; 91C2
        and     #$03                            ; 91C5
        tay                                     ; 91C7
        lda     $0605,x                         ; 91C8
        adc     L9202,y                         ; 91CB
        sta     $01                             ; 91CE
        ror     a                               ; 91D0
        eor     L9202,y                         ; 91D1
        bmi     L91FF                           ; 91D4
        lda     $01                             ; 91D6
        cmp     #$3F                            ; 91D8
        bcc     L91FF                           ; 91DA
        cmp     #$B0                            ; 91DC
        bcs     L91FF                           ; 91DE
        sty     $01                             ; 91E0
        jsr     LE088                           ; 91E2
        ldy     $01                             ; 91E5
        cmp     #$01                            ; 91E7
        bcs     L91FF                           ; 91E9
        tya                                     ; 91EB
        and     #$02                            ; 91EC
        sec                                     ; 91EE
        beq     L91F4                           ; 91EF
        clc                                     ; 91F1
        lda     #$80                            ; 91F2
L91F4:  ror     a                               ; 91F4
        sta     $00                             ; 91F5
        tya                                     ; 91F7
        and     #$01                            ; 91F8
        adc     #$62                            ; 91FA
        jsr     LFAB3                           ; 91FC
L91FF:  lda     $00                             ; 91FF
        rts                                     ; 9201

; ----------------------------------------------------------------------------
L9202:  .byte   $D4                             ; 9202
        .byte   $34                             ; 9203
        cpy     $BD2C                           ; 9204
        brk                                     ; 9207
        .byte   $07                             ; 9208
        beq     L9218                           ; 9209
        dec     $0700,x                         ; 920B
        and     #$0F                            ; 920E
        bne     L9215                           ; 9210
        jsr     LE0A2                           ; 9212
L9215:  jmp     L9709                           ; 9215

; ----------------------------------------------------------------------------
L9218:  jsr     L91BB                           ; 9218
        beq     L9225                           ; 921B
        ora     #$04                            ; 921D
        sta     $0601,x                         ; 921F
        jmp     L9237                           ; 9222

; ----------------------------------------------------------------------------
L9225:  lda     #$86                            ; 9225
        sta     $0601,x                         ; 9227
        lda     #$00                            ; 922A
        sta     $0701,x                         ; 922C
        lda     #$3C                            ; 922F
L9231:  sta     $0700,x                         ; 9231
        jsr     LE0A4                           ; 9234
L9237:  jmp     LA64C                           ; 9237

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 923A
        bne     L9237                           ; 923D
        lda     #$01                            ; 923F
        sta     $03                             ; 9241
        jsr     LFAD7                           ; 9243
        beq     L9271                           ; 9246
        bcs     L9256                           ; 9248
        jsr     L80DB                           ; 924A
        bne     L9237                           ; 924D
        jsr     LFAD7                           ; 924F
        beq     L9271                           ; 9252
        bcc     L9237                           ; 9254
L9256:  dec     $0703,x                         ; 9256
        beq     L9271                           ; 9259
        dec     $0601,x                         ; 925B
        lda     $03CA                           ; 925E
        beq     L9266                           ; 9261
        lda     $033A                           ; 9263
L9266:  asl     a                               ; 9266
        asl     a                               ; 9267
        asl     a                               ; 9268
        asl     a                               ; 9269
        asl     a                               ; 926A
        adc     #$1E                            ; 926B
        asl     a                               ; 926D
        jmp     L9231                           ; 926E

; ----------------------------------------------------------------------------
L9271:  lda     #$86                            ; 9271
        sta     $0601,x                         ; 9273
        lda     #$00                            ; 9276
        sta     $0701,x                         ; 9278
        lda     #$3C                            ; 927B
        jmp     L9231                           ; 927D

; ----------------------------------------------------------------------------
        dec     $0700,x                         ; 9280
        lda     $0700,x                         ; 9283
        beq     L9292                           ; 9286
        and     #$0F                            ; 9288
        bne     L9298                           ; 928A
        jsr     LE0A2                           ; 928C
        jmp     L9298                           ; 928F

; ----------------------------------------------------------------------------
L9292:  dec     $0601,x                         ; 9292
        jmp     L8FF5                           ; 9295

; ----------------------------------------------------------------------------
L9298:  jmp     LA64C                           ; 9298

; ----------------------------------------------------------------------------
        dec     $0700,x                         ; 929B
        bne     L92A8                           ; 929E
        jsr     L950A                           ; 92A0
        lda     #$65                            ; 92A3
        jmp     L969E                           ; 92A5

; ----------------------------------------------------------------------------
L92A8:  rts                                     ; 92A8

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 92A9
        beq     L92B0                           ; 92AC
        bcc     L92EC                           ; 92AE
L92B0:  jsr     L92EF                           ; 92B0
        lda     $22                             ; 92B3
        bne     L92EC                           ; 92B5
        lda     $BE                             ; 92B7
        and     #$40                            ; 92B9
        beq     L92E7                           ; 92BB
        lda     $7F                             ; 92BD
        and     #$0F                            ; 92BF
        bne     L92E4                           ; 92C1
        lda     $E0                             ; 92C3
        and     #$01                            ; 92C5
        clc                                     ; 92C7
        adc     #$02                            ; 92C8
        sta     $00                             ; 92CA
        lda     $0702,x                         ; 92CC
        cmp     $00                             ; 92CF
        bcs     L92E4                           ; 92D1
        pha                                     ; 92D3
        lda     #$01                            ; 92D4
        sta     $0702,x                         ; 92D6
        jsr     LA1A7                           ; 92D9
        pla                                     ; 92DC
        beq     L92E7                           ; 92DD
        sta     $0702,x                         ; 92DF
        bne     L92E7                           ; 92E2
L92E4:  jsr     LA1A7                           ; 92E4
L92E7:  lda     #$03                            ; 92E7
L92E9:  jsr     LF0BE                           ; 92E9
L92EC:  jmp     LA64C                           ; 92EC

; ----------------------------------------------------------------------------
L92EF:  lda     $22                             ; 92EF
        bne     L9313                           ; 92F1
        lda     #$02                            ; 92F3
        sta     $03                             ; 92F5
        lda     #$00                            ; 92F7
        jsr     LFAD7                           ; 92F9
        beq     L9313                           ; 92FC
        bcc     L9313                           ; 92FE
        lda     $0603,x                         ; 9300
        cmp     #$D8                            ; 9303
        bcs     L930B                           ; 9305
        cmp     #$28                            ; 9307
        bcs     L9313                           ; 9309
L930B:  lda     $0601,x                         ; 930B
        eor     #$C0                            ; 930E
        sta     $0601,x                         ; 9310
L9313:  rts                                     ; 9313

; ----------------------------------------------------------------------------
        lda     #$FF                            ; 9314
        sta     $0701,x                         ; 9316
        ldy     $0703,x                         ; 9319
        lda     $0600,y                         ; 931C
        cmp     #$16                            ; 931F
        bne     L9350                           ; 9321
        lda     $0702,y                         ; 9323
        sta     $0702,x                         ; 9326
        jsr     LA666                           ; 9329
        beq     L9330                           ; 932C
        bcc     L934D                           ; 932E
L9330:  lda     $22                             ; 9330
        bne     L934D                           ; 9332
        lda     $0700,x                         ; 9334
        bne     L9340                           ; 9337
        jsr     L92EF                           ; 9339
        lda     #$05                            ; 933C
        bne     L92E9                           ; 933E
L9340:  dec     $0700,x                         ; 9340
        bne     L934D                           ; 9343
        lda     #$65                            ; 9345
        jsr     LFAB3                           ; 9347
        jsr     LE0A4                           ; 934A
L934D:  jmp     LA64C                           ; 934D

; ----------------------------------------------------------------------------
L9350:  jmp     L8A60                           ; 9350

; ----------------------------------------------------------------------------
        lda     #$00                            ; 9353
        sta     $0701,x                         ; 9355
        lda     $0601,x                         ; 9358
        and     #$07                            ; 935B
        asl     a                               ; 935D
        asl     a                               ; 935E
        asl     a                               ; 935F
        asl     a                               ; 9360
        asl     a                               ; 9361
        adc     #$01                            ; 9362
        sta     $0700,x                         ; 9364
        sta     $00                             ; 9367
        lda     #$00                            ; 9369
        jsr     LF0BE                           ; 936B
        lda     $0601,x                         ; 936E
        sta     L0002                           ; 9371
        lda     $0600,x                         ; 9373
        sta     $01                             ; 9376
        lda     #$04                            ; 9378
        sta     $03                             ; 937A
        lda     $0602,x                         ; 937C
        sta     $05                             ; 937F
        lda     $0603,x                         ; 9381
        sta     $06                             ; 9384
L9386:  jsr     LF11C                           ; 9386
        bne     L93B8                           ; 9389
        lda     $01                             ; 938B
        sta     $0600,y                         ; 938D
        lda     L0002                           ; 9390
        ora     #$05                            ; 9392
        .byte   $99                             ; 9394
        .byte   $01                             ; 9395
L9396:  asl     $A5                             ; 9396
        ora     $99                             ; 9398
        .byte   $02                             ; 939A
        asl     $A5                             ; 939B
        asl     $99                             ; 939D
        .byte   $03                             ; 939F
        asl     $A5                             ; 93A0
        brk                                     ; 93A2
        clc                                     ; 93A3
        adc     #$04                            ; 93A4
        sta     $00                             ; 93A6
        sta     $0700,y                         ; 93A8
        lda     #$FF                            ; 93AB
        sta     $0604,y                         ; 93AD
        txa                                     ; 93B0
        sta     $0703,y                         ; 93B1
        dec     $03                             ; 93B4
        bne     L9386                           ; 93B6
L93B8:  rts                                     ; 93B8

; ----------------------------------------------------------------------------
        dec     $0700,x                         ; 93B9
        lda     $0700,x                         ; 93BC
        beq     L93CB                           ; 93BF
        and     #$0F                            ; 93C1
        bne     L93D3                           ; 93C3
        jsr     LE0A2                           ; 93C5
        jmp     L93D3                           ; 93C8

; ----------------------------------------------------------------------------
L93CB:  lda     #$00                            ; 93CB
        jsr     LF0BE                           ; 93CD
        jsr     LE0A4                           ; 93D0
L93D3:  jmp     LA64C                           ; 93D3

; ----------------------------------------------------------------------------
        lda     $0603,x                         ; 93D6
        and     #$0F                            ; 93D9
        beq     L93E6                           ; 93DB
        clc                                     ; 93DD
        lda     $0603,x                         ; 93DE
        adc     #$08                            ; 93E1
        sta     $0603,x                         ; 93E3
L93E6:  lda     #$00                            ; 93E6
        sta     $0701,x                         ; 93E8
        lda     $93                             ; 93EB
        cmp     #$06                            ; 93ED
        beq     L93FA                           ; 93EF
        lda     $7F                             ; 93F1
        and     #$0F                            ; 93F3
        bne     L93FA                           ; 93F5
        jsr     L940F                           ; 93F7
L93FA:  jsr     L9440                           ; 93FA
        beq     L9409                           ; 93FD
        jsr     L9470                           ; 93FF
        lda     $0706,x                         ; 9402
        cmp     #$04                            ; 9405
        beq     L940C                           ; 9407
L9409:  jmp     LA64C                           ; 9409

; ----------------------------------------------------------------------------
L940C:  jmp     L8A60                           ; 940C

; ----------------------------------------------------------------------------
L940F:  jsr     LF120                           ; 940F
        bne     L943F                           ; 9412
        lda     $0600,x                         ; 9414
        sta     $0600,y                         ; 9417
        lda     #$24                            ; 941A
        sta     $0601,y                         ; 941C
        lda     $0602,x                         ; 941F
        sta     $0602,y                         ; 9422
        lda     $0603,x                         ; 9425
        sta     $0603,y                         ; 9428
        txa                                     ; 942B
        pha                                     ; 942C
        tya                                     ; 942D
        tax                                     ; 942E
        jsr     LE0A4                           ; 942F
        jsr     LE0A0                           ; 9432
        jsr     LA874                           ; 9435
        lda     #$10                            ; 9438
        sta     $0700,x                         ; 943A
        pla                                     ; 943D
        tax                                     ; 943E
L943F:  rts                                     ; 943F

; ----------------------------------------------------------------------------
L9440:  lda     $0702,x                         ; 9440
        bmi     L946D                           ; 9443
        jsr     LF3E0                           ; 9445
        beq     L946D                           ; 9448
        bmi     L946D                           ; 944A
        and     #$04                            ; 944C
        bne     L9460                           ; 944E
        lda     $0601,y                         ; 9450
        and     #$0F                            ; 9453
        sta     $00                             ; 9455
        lda     #$00                            ; 9457
        sta     $0601,y                         ; 9459
        lda     $00                             ; 945C
        beq     L946D                           ; 945E
L9460:  lda     #$E0                            ; 9460
        sta     $0702,x                         ; 9462
        lda     #$29                            ; 9465
        jsr     LE992                           ; 9467
        lda     #$01                            ; 946A
        rts                                     ; 946C

; ----------------------------------------------------------------------------
L946D:  lda     #$00                            ; 946D
        rts                                     ; 946F

; ----------------------------------------------------------------------------
L9470:  lda     $0706,x                         ; 9470
        asl     a                               ; 9473
        asl     a                               ; 9474
        sta     $00                             ; 9475
        lda     #$03                            ; 9477
        sta     $01                             ; 9479
        inc     $0706,x                         ; 947B
L947E:  ldy     $01                             ; 947E
        clc                                     ; 9480
        lda     $0605,x                         ; 9481
        adc     L949B,y                         ; 9484
        sta     L0002                           ; 9487
        ldy     $00                             ; 9489
        lda     L949F,y                         ; 948B
        tay                                     ; 948E
        lda     L0002                           ; 948F
        jsr     LE964                           ; 9491
        inc     $00                             ; 9494
        dec     $01                             ; 9496
        bpl     L947E                           ; 9498
        rts                                     ; 949A

; ----------------------------------------------------------------------------
L949B:  sbc     ($F0),y                         ; 949B
        ora     ($00,x)                         ; 949D
L949F:  .byte   $17                             ; 949F
        clc                                     ; 94A0
        ora     $16,x                           ; 94A1
        .byte   $1B                             ; 94A3
        .byte   $1C                             ; 94A4
        ora     $1B1A,y                         ; 94A5
        .byte   $1C                             ; 94A8
        ora     $CD1A,y                         ; 94A9
        cmp     $CDCD                           ; 94AC
        jsr     LA666                           ; 94AF
        bne     L94B9                           ; 94B2
        ldy     #$02                            ; 94B4
        jsr     LB0F2                           ; 94B6
L94B9:  jmp     LA64C                           ; 94B9

; ----------------------------------------------------------------------------
        dec     $0700,x                         ; 94BC
        inc     $0602,x                         ; 94BF
        lda     $0700,x                         ; 94C2
        beq     L94D1                           ; 94C5
        and     #$03                            ; 94C7
        bne     L94D7                           ; 94C9
        jsr     LE0A2                           ; 94CB
        jmp     L94D7                           ; 94CE

; ----------------------------------------------------------------------------
L94D1:  dec     $0601,x                         ; 94D1
        jsr     LE0A4                           ; 94D4
L94D7:  jmp     LA64C                           ; 94D7

; ----------------------------------------------------------------------------
        lda     #$00                            ; 94DA
        sta     $0701,x                         ; 94DC
        lda     $93                             ; 94DF
        bmi     L94EB                           ; 94E1
        beq     L9500                           ; 94E3
        jsr     L950F                           ; 94E5
        jmp     L9500                           ; 94E8

; ----------------------------------------------------------------------------
L94EB:  jsr     L9503                           ; 94EB
        lda     #$00                            ; 94EE
        sta     $0700,x                         ; 94F0
        jsr     LE0A4                           ; 94F3
        jsr     LA874                           ; 94F6
        dec     $93                             ; 94F9
        lda     #$21                            ; 94FB
        sta     $0707,x                         ; 94FD
L9500:  jmp     LA64C                           ; 9500

; ----------------------------------------------------------------------------
L9503:  lda     #$4E                            ; 9503
        sta     $71                             ; 9505
        jsr     LF765                           ; 9507
L950A:  lda     #$03                            ; 950A
        jmp     LF0BE                           ; 950C

; ----------------------------------------------------------------------------
L950F:  jsr     LF3E0                           ; 950F
        beq     L953A                           ; 9512
        bmi     L952A                           ; 9514
        and     #$04                            ; 9516
        bne     L952A                           ; 9518
        lda     $0601,y                         ; 951A
        and     #$0F                            ; 951D
        sta     $00                             ; 951F
        lda     #$00                            ; 9521
        sta     $0601,y                         ; 9523
        lda     $00                             ; 9526
        beq     L953B                           ; 9528
L952A:  lda     $93                             ; 952A
        ora     #$80                            ; 952C
        sta     $93                             ; 952E
        lda     #$7E                            ; 9530
        jsr     LE992                           ; 9532
        lda     #$01                            ; 9535
        jsr     LE096                           ; 9537
L953A:  rts                                     ; 953A

; ----------------------------------------------------------------------------
L953B:  jsr     LA50F                           ; 953B
        bne     L952A                           ; 953E
        lda     #$02                            ; 9540
        jsr     LE992                           ; 9542
        lda     #$00                            ; 9545
        sta     $93                             ; 9547
        jsr     LE096                           ; 9549
        rts                                     ; 954C

; ----------------------------------------------------------------------------
        lda     $0700,x                         ; 954D
        cmp     #$3C                            ; 9550
        beq     L9561                           ; 9552
        inc     $0700,x                         ; 9554
        and     #$0F                            ; 9557
        bne     L9574                           ; 9559
        jsr     LE0A2                           ; 955B
        jmp     L9574                           ; 955E

; ----------------------------------------------------------------------------
L9561:  lda     #$4B                            ; 9561
        sta     $0700,x                         ; 9563
        inc     $0601,x                         ; 9566
        lda     $0707,x                         ; 9569
        and     #$F9                            ; 956C
        sta     $0707,x                         ; 956E
        jsr     LE0A4                           ; 9571
L9574:  jmp     LA64C                           ; 9574

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 9577
        bne     L9597                           ; 957A
        ldy     #$03                            ; 957C
        jsr     LAF74                           ; 957E
        lda     $7F                             ; 9581
        and     #$03                            ; 9583
        bne     L9597                           ; 9585
        dec     $0700,x                         ; 9587
        bne     L9597                           ; 958A
        inc     $0601,x                         ; 958C
        lda     #$78                            ; 958F
        sta     $0700,x                         ; 9591
        jmp     L8FF5                           ; 9594

; ----------------------------------------------------------------------------
L9597:  jmp     LA64C                           ; 9597

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 959A
        bne     L95ED                           ; 959D
        dec     $0700,x                         ; 959F
        beq     L95E2                           ; 95A2
        lda     $09                             ; 95A4
        cmp     #$20                            ; 95A6
        bcs     L95B2                           ; 95A8
        lda     $08                             ; 95AA
        and     #$30                            ; 95AC
        bne     L95BE                           ; 95AE
        beq     L95CD                           ; 95B0
L95B2:  lda     $0A                             ; 95B2
        cmp     #$20                            ; 95B4
        bcs     L95D5                           ; 95B6
        lda     $08                             ; 95B8
        and     #$C0                            ; 95BA
        beq     L95CD                           ; 95BC
L95BE:  sta     $00                             ; 95BE
        lda     $0601,x                         ; 95C0
        and     #$0F                            ; 95C3
        ora     $08                             ; 95C5
        sta     $0601,x                         ; 95C7
        jsr     LE0A4                           ; 95CA
L95CD:  lda     $09                             ; 95CD
        ora     $0A                             ; 95CF
        and     #$E0                            ; 95D1
        beq     L95E2                           ; 95D3
L95D5:  lda     $0700,x                         ; 95D5
        and     #$0F                            ; 95D8
        bne     L95ED                           ; 95DA
        jsr     LE0A2                           ; 95DC
        jmp     L95ED                           ; 95DF

; ----------------------------------------------------------------------------
L95E2:  lda     #$00                            ; 95E2
        sta     $0700,x                         ; 95E4
        jsr     L950A                           ; 95E7
        jsr     LE0A4                           ; 95EA
L95ED:  jmp     LA64C                           ; 95ED

; ----------------------------------------------------------------------------
        jsr     L950A                           ; 95F0
        jmp     L9001                           ; 95F3

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 95F6
        beq     L9603                           ; 95F9
        bcc     L9633                           ; 95FB
        jsr     L9636                           ; 95FD
        jmp     L9633                           ; 9600

; ----------------------------------------------------------------------------
L9603:  ldy     #$01                            ; 9603
        jsr     LAF74                           ; 9605
        lda     $7F                             ; 9608
        and     #$03                            ; 960A
        ora     $21                             ; 960C
        bne     L9633                           ; 960E
        lda     $0700,x                         ; 9610
        bne     L961A                           ; 9613
        lda     #$69                            ; 9615
        sta     $0700,x                         ; 9617
L961A:  dec     $0700,x                         ; 961A
        bne     L9633                           ; 961D
        lda     #$17                            ; 961F
        sta     $21                             ; 9621
        lda     #$0A                            ; 9623
        jsr     LE096                           ; 9625
        inc     $0601,x                         ; 9628
        lda     #$78                            ; 962B
        sta     $0700,x                         ; 962D
        jsr     LE0A4                           ; 9630
L9633:  jmp     LA64C                           ; 9633

; ----------------------------------------------------------------------------
L9636:  lda     #$10                            ; 9636
        sta     $00                             ; 9638
        txa                                     ; 963A
        pha                                     ; 963B
        tay                                     ; 963C
        lda     $0602,x                         ; 963D
        sta     $01                             ; 9640
        lda     $0603,x                         ; 9642
        sta     L0002                           ; 9645
L9647:  tya                                     ; 9647
        tax                                     ; 9648
        lda     #$1A                            ; 9649
        sta     $0600,x                         ; 964B
        lda     $00                             ; 964E
        sta     $0601,x                         ; 9650
        lda     $01                             ; 9653
        sta     $0602,x                         ; 9655
        lda     L0002                           ; 9658
        sta     $0603,x                         ; 965A
        jsr     LE0A4                           ; 965D
        asl     $00                             ; 9660
        bcs     L9669                           ; 9662
        jsr     LF11C                           ; 9664
        beq     L9647                           ; 9667
L9669:  pla                                     ; 9669
        tax                                     ; 966A
        rts                                     ; 966B

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 966C
        beq     L9679                           ; 966F
        bcs     L9691                           ; 9671
        jsr     L9636                           ; 9673
        jmp     L9691                           ; 9676

; ----------------------------------------------------------------------------
L9679:  dec     $0700,x                         ; 9679
        lda     $0700,x                         ; 967C
        beq     L968B                           ; 967F
        and     #$0F                            ; 9681
        bne     L9691                           ; 9683
        jsr     LE0A2                           ; 9685
        jmp     L9691                           ; 9688

; ----------------------------------------------------------------------------
L968B:  dec     $0601,x                         ; 968B
        jsr     LE0A4                           ; 968E
L9691:  jmp     LA64C                           ; 9691

; ----------------------------------------------------------------------------
        jsr     L96A5                           ; 9694
        bne     L96A4                           ; 9697
        jsr     L950A                           ; 9699
        lda     #$64                            ; 969C
L969E:  jsr     LFAB3                           ; 969E
        jmp     L8FF5                           ; 96A1

; ----------------------------------------------------------------------------
L96A4:  rts                                     ; 96A4

; ----------------------------------------------------------------------------
L96A5:  lda     #$00                            ; 96A5
        sta     $0701,x                         ; 96A7
        sta     $0702,x                         ; 96AA
        lda     $0700,x                         ; 96AD
        bne     L96BE                           ; 96B0
        lda     #$FF                            ; 96B2
        sta     $0604,x                         ; 96B4
        txa                                     ; 96B7
        sec                                     ; 96B8
        sbc     #$30                            ; 96B9
        sta     $0700,x                         ; 96BB
L96BE:  lda     $7F                             ; 96BE
        and     #$03                            ; 96C0
        bne     L96CB                           ; 96C2
        lda     $22                             ; 96C4
        bne     L96CB                           ; 96C6
        dec     $0700,x                         ; 96C8
L96CB:  rts                                     ; 96CB

; ----------------------------------------------------------------------------
        lda     $22                             ; 96CC
        bne     L9709                           ; 96CE
        lda     #$02                            ; 96D0
        sta     $03                             ; 96D2
        lda     #$00                            ; 96D4
        jsr     LFAD7                           ; 96D6
        bne     L9709                           ; 96D9
        lda     L0002                           ; 96DB
        and     #$F0                            ; 96DD
        eor     #$C0                            ; 96DF
        sta     $0601,x                         ; 96E1
        lda     $E1                             ; 96E4
        and     #$07                            ; 96E6
        adc     $0602                           ; 96E8
        cmp     #$40                            ; 96EB
        bcs     L96F1                           ; 96ED
        adc     #$20                            ; 96EF
L96F1:  jmp     L96FB                           ; 96F1

; ----------------------------------------------------------------------------
L96F4:  lda     $0602,x                         ; 96F4
        and     #$F0                            ; 96F7
        ora     #$08                            ; 96F9
L96FB:  sta     $0602,x                         ; 96FB
        lda     $0603,x                         ; 96FE
        and     #$F0                            ; 9701
        ora     #$08                            ; 9703
        sta     $0603,x                         ; 9705
        rts                                     ; 9708

; ----------------------------------------------------------------------------
L9709:  jsr     LA666                           ; 9709
        jmp     LA64C                           ; 970C

; ----------------------------------------------------------------------------
        jsr     L96A5                           ; 970F
        beq     L972E                           ; 9712
        lda     $0700,x                         ; 9714
        cmp     #$04                            ; 9717
        bne     L9726                           ; 9719
        lda     #$07                            ; 971B
        jsr     LE992                           ; 971D
        jsr     LE0A4                           ; 9720
        jmp     LA64C                           ; 9723

; ----------------------------------------------------------------------------
L9726:  bcs     L972B                           ; 9726
        jsr     LE0A2                           ; 9728
L972B:  jmp     LA64C                           ; 972B

; ----------------------------------------------------------------------------
L972E:  lda     #$05                            ; 972E
        jsr     LF0BE                           ; 9730
        lda     #$66                            ; 9733
        jmp     L969E                           ; 9735

; ----------------------------------------------------------------------------
        lda     $22                             ; 9738
        bne     L9781                           ; 973A
        lda     #$02                            ; 973C
        sta     $03                             ; 973E
        lda     #$00                            ; 9740
        jsr     LFAD7                           ; 9742
        bne     L9765                           ; 9745
        lda     L0002                           ; 9747
        sta     $0601,x                         ; 9749
L974C:  lda     $0601,x                         ; 974C
        eor     #$C1                            ; 974F
        sta     $0601,x                         ; 9751
        lda     #$FF                            ; 9754
        sta     $0604,x                         ; 9756
        lda     $E1                             ; 9759
        and     #$1F                            ; 975B
        adc     #$50                            ; 975D
        sta     $0700,x                         ; 975F
        jmp     L96F4                           ; 9762

; ----------------------------------------------------------------------------
L9765:  bcs     L974C                           ; 9765
        lda     $0606,x                         ; 9767
        cmp     #$1C                            ; 976A
        beq     L977E                           ; 976C
        cmp     #$10                            ; 976E
        beq     L977E                           ; 9770
        cmp     #$04                            ; 9772
        beq     L977E                           ; 9774
        cmp     #$03                            ; 9776
        beq     L977E                           ; 9778
        cmp     #$02                            ; 977A
        bne     L9781                           ; 977C
L977E:  jsr     LE0A2                           ; 977E
L9781:  jsr     LA666                           ; 9781
        beq     L9790                           ; 9784
        bcc     L9790                           ; 9786
        lda     #$05                            ; 9788
        jsr     LF0BE                           ; 978A
        jsr     LE0A4                           ; 978D
L9790:  jmp     LA64C                           ; 9790

; ----------------------------------------------------------------------------
        jsr     LA874                           ; 9793
        lda     #$21                            ; 9796
        jsr     LF85D                           ; 9798
        lda     $0605,x                         ; 979B
        jsr     LE086                           ; 979E
        lda     #$04                            ; 97A1
        jsr     LF0BE                           ; 97A3
        jmp     L9001                           ; 97A6

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 97A9
        bne     L97E9                           ; 97AC
        jsr     LF877                           ; 97AE
        bne     L97E9                           ; 97B1
        lda     $0601,x                         ; 97B3
        bne     L97BD                           ; 97B6
        lda     L0002                           ; 97B8
        sta     $0601,x                         ; 97BA
L97BD:  lda     $09                             ; 97BD
        cmp     $0A                             ; 97BF
        bcc     L97C9                           ; 97C1
        lda     $08                             ; 97C3
        and     #$C0                            ; 97C5
        bne     L97CF                           ; 97C7
L97C9:  lda     $08                             ; 97C9
        and     #$30                            ; 97CB
        beq     L97E4                           ; 97CD
L97CF:  sta     $08                             ; 97CF
        lda     $0601,x                         ; 97D1
        and     #$0F                            ; 97D4
        ora     $08                             ; 97D6
        sta     $0601,x                         ; 97D8
        jsr     LE0A4                           ; 97DB
        lda     $0605,x                         ; 97DE
        jsr     LE086                           ; 97E1
L97E4:  lda     #$21                            ; 97E4
        jsr     LF85D                           ; 97E6
L97E9:  jmp     LA64C                           ; 97E9

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 97EC
        bne     L97F6                           ; 97EF
        lda     $0702,x                         ; 97F1
        bpl     L9816                           ; 97F4
L97F6:  bmi     L9826                           ; 97F6
        lda     $0705,x                         ; 97F8
        beq     L9826                           ; 97FB
        lda     #$18                            ; 97FD
        sta     $26                             ; 97FF
        lda     #$E0                            ; 9801
        sta     $0702,x                         ; 9803
        lda     #$3F                            ; 9806
        sta     $0600,x                         ; 9808
        jsr     L950A                           ; 980B
        lda     #$3A                            ; 980E
        jsr     LE992                           ; 9810
        jmp     L8FF5                           ; 9813

; ----------------------------------------------------------------------------
L9816:  lda     $22                             ; 9816
        bne     L9826                           ; 9818
        ldy     #$02                            ; 981A
        jsr     L80DB                           ; 981C
        bne     L9823                           ; 981F
        ldy     #$04                            ; 9821
L9823:  jsr     LB0F2                           ; 9823
L9826:  jmp     LA64C                           ; 9826

; ----------------------------------------------------------------------------
        jsr     L90E7                           ; 9829
        lda     #$01                            ; 982C
        sta     $0705,x                         ; 982E
        rts                                     ; 9831

; ----------------------------------------------------------------------------
        lda     #$00                            ; 9832
        sta     $0701,x                         ; 9834
        lda     $0700,x                         ; 9837
        bne     L9840                           ; 983A
        txa                                     ; 983C
        sta     $0700,x                         ; 983D
L9840:  dec     $0700,x                         ; 9840
        bne     L9851                           ; 9843
        sta     $0706,x                         ; 9845
        jsr     L950A                           ; 9848
        jsr     LE0A4                           ; 984B
        jsr     LA874                           ; 984E
L9851:  rts                                     ; 9851

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 9852
        bne     L98A2                           ; 9855
        inc     $0700,x                         ; 9857
        lda     $0700,x                         ; 985A
        cmp     #$5A                            ; 985D
        beq     L9889                           ; 985F
        and     #$0F                            ; 9861
        bne     L9868                           ; 9863
        jsr     LE0A2                           ; 9865
L9868:  lda     $0700,x                         ; 9868
        cmp     #$3C                            ; 986B
        bcc     L98A2                           ; 986D
        lda     $0601,x                         ; 986F
        and     $08                             ; 9872
        bne     L9883                           ; 9874
        lda     $0601,x                         ; 9876
        and     #$0F                            ; 9879
        ora     $08                             ; 987B
        sta     $0601,x                         ; 987D
        jsr     LE0A4                           ; 9880
L9883:  jsr     LA1A7                           ; 9883
        jmp     L98A2                           ; 9886

; ----------------------------------------------------------------------------
L9889:  lda     #$00                            ; 9889
        sta     $0700,x                         ; 988B
        inc     $0601,x                         ; 988E
        lda     $0601,x                         ; 9891
        and     #$0F                            ; 9894
        cmp     #$04                            ; 9896
        bcc     L989F                           ; 9898
        lda     #$00                            ; 989A
        jsr     LF0BE                           ; 989C
L989F:  jsr     LE0A4                           ; 989F
L98A2:  jmp     LA64C                           ; 98A2

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 98A5
        bne     L98AF                           ; 98A8
        ldy     #$00                            ; 98AA
        jsr     LAF74                           ; 98AC
L98AF:  lda     #$00                            ; 98AF
        sta     $26                             ; 98B1
        jmp     LA64C                           ; 98B3

; ----------------------------------------------------------------------------
        lda     $0700,x                         ; 98B6
        bne     L98DE                           ; 98B9
        lda     $0601                           ; 98BB
        and     #$F0                            ; 98BE
        ora     #$04                            ; 98C0
        sta     $0601,x                         ; 98C2
        lda     $0602                           ; 98C5
        sta     $0602,x                         ; 98C8
        lda     $0603                           ; 98CB
        sta     $0603,x                         ; 98CE
        lda     #$00                            ; 98D1
        sta     $0701,x                         ; 98D3
        lda     #$3C                            ; 98D6
        sta     $0700,x                         ; 98D8
        jsr     LE0A4                           ; 98DB
L98DE:  dec     $0700,x                         ; 98DE
        bne     L98F0                           ; 98E1
        lda     $0605,x                         ; 98E3
        cmp     $0605                           ; 98E6
        bne     L98F1                           ; 98E9
        lda     #$3C                            ; 98EB
        sta     $0700,x                         ; 98ED
L98F0:  rts                                     ; 98F0

; ----------------------------------------------------------------------------
L98F1:  lda     #$00                            ; 98F1
        jsr     LF0BE                           ; 98F3
        jmp     LE0A4                           ; 98F6

; ----------------------------------------------------------------------------
        lda     #$00                            ; 98F9
        sta     $0701,x                         ; 98FB
        lda     $95                             ; 98FE
        cmp     #$02                            ; 9900
        bne     L990A                           ; 9902
L9904:  jsr     L9503                           ; 9904
        jsr     LE0A4                           ; 9907
L990A:  jmp     LA64C                           ; 990A

; ----------------------------------------------------------------------------
L990D:  lda     $0700,x                         ; 990D
        bne     L9915                           ; 9910
        jsr     L992E                           ; 9912
L9915:  cmp     #$01                            ; 9915
        beq     L991D                           ; 9917
        inc     $0700,x                         ; 9919
L991C:  rts                                     ; 991C

; ----------------------------------------------------------------------------
L991D:  jsr     L994D                           ; 991D
        bne     L991C                           ; 9920
        jsr     L950A                           ; 9922
        jsr     LE0A4                           ; 9925
        jsr     LA874                           ; 9928
        jmp     LA64C                           ; 992B

; ----------------------------------------------------------------------------
L992E:  lda     #$00                            ; 992E
        sta     $0701,x                         ; 9930
        lda     #$10                            ; 9933
        sta     $0704,x                         ; 9935
        lda     $0600,x                         ; 9938
        sta     $00                             ; 993B
        lda     #$88                            ; 993D
        sta     $01                             ; 993F
        lda     #$00                            ; 9941
        sta     L0002                           ; 9943
        jsr     LFA29                           ; 9945
        lda     #$08                            ; 9948
        sta     $21                             ; 994A
        rts                                     ; 994C

; ----------------------------------------------------------------------------
L994D:  lda     $7F                             ; 994D
        and     #$01                            ; 994F
        bne     L9978                           ; 9951
        dec     $0704,x                         ; 9953
        bne     L9978                           ; 9956
        lda     #$00                            ; 9958
        sta     $0700,x                         ; 995A
        sta     $0641,x                         ; 995D
L9960:  sta     $0609,x                         ; 9960
        sta     $0611,x                         ; 9963
        sta     $0619,x                         ; 9966
        sta     $0621,x                         ; 9969
        sta     $0629,x                         ; 996C
        sta     $0631,x                         ; 996F
        sta     $0639,x                         ; 9972
        sta     $0641,x                         ; 9975
L9978:  rts                                     ; 9978

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 9979
        bne     L9998                           ; 997C
        ldy     #$03                            ; 997E
        jsr     LB04F                           ; 9980
        lda     $0700,x                         ; 9983
        beq     L9992                           ; 9986
        dec     $0700,x                         ; 9988
        bne     L9998                           ; 998B
        lda     #$3C                            ; 998D
        sta     $0700,x                         ; 998F
L9992:  inc     $0601,x                         ; 9992
        jsr     LE0A4                           ; 9995
L9998:  jmp     LA64C                           ; 9998

; ----------------------------------------------------------------------------
        lda     $35                             ; 999B
        beq     L99AA                           ; 999D
        lda     $7F                             ; 999F
        and     #$1F                            ; 99A1
        bne     L99AA                           ; 99A3
        lda     #$01                            ; 99A5
        jsr     LA43E                           ; 99A7
L99AA:  ldy     #$00                            ; 99AA
        sty     $35                             ; 99AC
        jsr     LFC90                           ; 99AE
        bne     L99BA                           ; 99B1
        lda     $0601,x                         ; 99B3
        and     #$C0                            ; 99B6
        sta     $35                             ; 99B8
L99BA:  jsr     LA666                           ; 99BA
        bne     L99FF                           ; 99BD
        lda     $0700,x                         ; 99BF
        bne     L99CD                           ; 99C2
        lda     $E1                             ; 99C4
        and     #$3F                            ; 99C6
        adc     #$78                            ; 99C8
        sta     $0700,x                         ; 99CA
L99CD:  and     #$0F                            ; 99CD
        bne     L99D4                           ; 99CF
        jsr     LE0A2                           ; 99D1
L99D4:  lda     $0601,x                         ; 99D4
        pha                                     ; 99D7
        lda     $0604,x                         ; 99D8
        pha                                     ; 99DB
        lda     $0700,x                         ; 99DC
        pha                                     ; 99DF
        jsr     LA1A7                           ; 99E0
        pla                                     ; 99E3
        sta     $0700,x                         ; 99E4
        pla                                     ; 99E7
        sta     $0604,x                         ; 99E8
        pla                                     ; 99EB
        sta     $0601,x                         ; 99EC
        dec     $0700,x                         ; 99EF
        bne     L99FF                           ; 99F2
        lda     #$3C                            ; 99F4
        sta     $0700,x                         ; 99F6
        dec     $0601,x                         ; 99F9
        jsr     LE0A4                           ; 99FC
L99FF:  jmp     LA64C                           ; 99FF

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 9A02
        bne     L9A5A                           ; 9A05
        ldy     #$03                            ; 9A07
        lda     $0704,x                         ; 9A09
        pha                                     ; 9A0C
        lda     $0706,x                         ; 9A0D
        sta     $0704,x                         ; 9A10
        jsr     LB047                           ; 9A13
        lda     $0704,x                         ; 9A16
        sta     $0706,x                         ; 9A19
        pla                                     ; 9A1C
        sta     $0704,x                         ; 9A1D
        bne     L9A39                           ; 9A20
        lda     #$01                            ; 9A22
        sta     $0700,x                         ; 9A24
        jsr     LA1A7                           ; 9A27
        lda     $0700,x                         ; 9A2A
        bne     L9A5A                           ; 9A2D
        sta     $0705,x                         ; 9A2F
        lda     #$01                            ; 9A32
        sta     $0704,x                         ; 9A34
        bne     L9A5A                           ; 9A37
L9A39:  lda     $0621,x                         ; 9A39
        bne     L9A48                           ; 9A3C
        lda     #$00                            ; 9A3E
        sta     $31                             ; 9A40
        sta     $0704,x                         ; 9A42
        jmp     L9904                           ; 9A45

; ----------------------------------------------------------------------------
L9A48:  ldy     $0705,x                         ; 9A48
        lda     $0704,x                         ; 9A4B
        cmp     L9A7C,y                         ; 9A4E
        beq     L9A5D                           ; 9A51
        clc                                     ; 9A53
        adc     L9A7B,y                         ; 9A54
        sta     $0704,x                         ; 9A57
L9A5A:  jmp     LA64C                           ; 9A5A

; ----------------------------------------------------------------------------
L9A5D:  lda     $25                             ; 9A5D
        bne     L9A5A                           ; 9A5F
        iny                                     ; 9A61
        iny                                     ; 9A62
        cpy     #$06                            ; 9A63
        bne     L9A6D                           ; 9A65
        ldy     #$00                            ; 9A67
        lda     #$18                            ; 9A69
        sta     $25                             ; 9A6B
L9A6D:  tya                                     ; 9A6D
        sta     $0705,x                         ; 9A6E
        cmp     #$02                            ; 9A71
        bne     L9A5A                           ; 9A73
        lda     #$12                            ; 9A75
        sta     $25                             ; 9A77
        bne     L9A5A                           ; 9A79
L9A7B:  .byte   $01                             ; 9A7B
L9A7C:  php                                     ; 9A7C
        ora     ($20,x)                         ; 9A7D
        .byte   $FF                             ; 9A7F
        php                                     ; 9A80
        lda     #$00                            ; 9A81
        sta     $0701,x                         ; 9A83
        lda     $0700,x                         ; 9A86
        bne     L9A99                           ; 9A89
        lda     #$FF                            ; 9A8B
        sta     $0604,x                         ; 9A8D
        lda     $93                             ; 9A90
        bpl     L9AD4                           ; 9A92
        inc     $93                             ; 9A94
        jsr     LE0A4                           ; 9A96
L9A99:  inc     $0700,x                         ; 9A99
        lda     $0700,x                         ; 9A9C
        cmp     #$5A                            ; 9A9F
        beq     L9AAD                           ; 9AA1
        and     #$07                            ; 9AA3
        bne     L9AD1                           ; 9AA5
        jsr     LE0A2                           ; 9AA7
        jmp     L9AD1                           ; 9AAA

; ----------------------------------------------------------------------------
L9AAD:  dec     $93                             ; 9AAD
        lda     #$00                            ; 9AAF
        sta     $0700,x                         ; 9AB1
        txa                                     ; 9AB4
        lsr     a                               ; 9AB5
        lsr     a                               ; 9AB6
        lsr     a                               ; 9AB7
        ora     #$80                            ; 9AB8
        sta     $0703,x                         ; 9ABA
        lda     #$F0                            ; 9ABD
        sta     $0705,x                         ; 9ABF
        jsr     L950A                           ; 9AC2
        jsr     LE0A4                           ; 9AC5
        jsr     LA874                           ; 9AC8
        lda     $0605,x                         ; 9ACB
        sta     $0704,x                         ; 9ACE
L9AD1:  jsr     LE0A0                           ; 9AD1
L9AD4:  rts                                     ; 9AD4

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 9AD5
        beq     L9AE4                           ; 9AD8
        asl     $0703,x                         ; 9ADA
        sec                                     ; 9ADD
        ror     $0703,x                         ; 9ADE
        jmp     LA64C                           ; 9AE1

; ----------------------------------------------------------------------------
L9AE4:  lda     $05                             ; 9AE4
        bpl     L9AF0                           ; 9AE6
        jsr     L9B30                           ; 9AE8
        beq     L9AF0                           ; 9AEB
L9AED:  jmp     L9B1B                           ; 9AED

; ----------------------------------------------------------------------------
L9AF0:  lda     $22                             ; 9AF0
        bne     L9AED                           ; 9AF2
        lda     $0703,x                         ; 9AF4
        bpl     L9B09                           ; 9AF7
        jsr     LB131                           ; 9AF9
        jsr     LA01B                           ; 9AFC
        jsr     LB167                           ; 9AFF
        bcs     L9AED                           ; 9B02
        lda     #$21                            ; 9B04
L9B06:  jsr     LF85D                           ; 9B06
L9B09:  jsr     LF877                           ; 9B09
        bne     L9AED                           ; 9B0C
        lda     #$0C                            ; 9B0E
        sta     $0700,x                         ; 9B10
L9B13:  lda     $0703,x                         ; 9B13
        ora     #$80                            ; 9B16
        sta     $0703,x                         ; 9B18
L9B1B:  jsr     L9E8C                           ; 9B1B
        bit     $93                             ; 9B1E
        bvc     L9B2F                           ; 9B20
        lda     #$3C                            ; 9B22
        sta     $0700,x                         ; 9B24
        lda     #$86                            ; 9B27
        sta     $0601,x                         ; 9B29
        jsr     LE0A4                           ; 9B2C
L9B2F:  rts                                     ; 9B2F

; ----------------------------------------------------------------------------
L9B30:  lda     $0601                           ; 9B30
        and     #$0F                            ; 9B33
        cmp     #$02                            ; 9B35
        bcc     L9B59                           ; 9B37
        lda     $32                             ; 9B39
        beq     L9B59                           ; 9B3B
        cmp     #$0A                            ; 9B3D
        bcc     L9B48                           ; 9B3F
        sbc     #$07                            ; 9B41
        sta     $00                             ; 9B43
        jmp     L9B50                           ; 9B45

; ----------------------------------------------------------------------------
L9B48:  lda     $0600,x                         ; 9B48
        sec                                     ; 9B4B
        sbc     #$24                            ; 9B4C
        sta     $00                             ; 9B4E
L9B50:  jsr     L9B5A                           ; 9B50
        lda     #$00                            ; 9B53
        sta     $32                             ; 9B55
        lda     #$01                            ; 9B57
L9B59:  rts                                     ; 9B59

; ----------------------------------------------------------------------------
L9B5A:  lda     #$00                            ; 9B5A
        sta     $0700,x                         ; 9B5C
        sta     $0701,x                         ; 9B5F
        lda     #$04                            ; 9B62
        jsr     LF0BE                           ; 9B64
        jsr     LE0A4                           ; 9B67
        lda     $0602                           ; 9B6A
        sta     $0602,x                         ; 9B6D
        lda     $0603                           ; 9B70
        sta     $0603,x                         ; 9B73
        lda     #$05                            ; 9B76
        sta     $0600                           ; 9B78
        lda     $0601                           ; 9B7B
        and     #$F0                            ; 9B7E
        ora     $00                             ; 9B80
        sta     $0601                           ; 9B82
        txa                                     ; 9B85
        pha                                     ; 9B86
        ldx     #$00                            ; 9B87
        jsr     LE0A4                           ; 9B89
        pla                                     ; 9B8C
        tax                                     ; 9B8D
        lda     #$C8                            ; 9B8E
        sta     $0700                           ; 9B90
L9B93:  ldy     $00                             ; 9B93
        lda     L9B9B,y                         ; 9B95
        .byte   $4C                             ; 9B98
L9B99:  .byte   $92                             ; 9B99
        .byte   $E9                             ; 9B9A
L9B9B:  .byte   $14                             ; 9B9B
        ora     $16,x                           ; 9B9C
        .byte   $17                             ; 9B9E
        clc                                     ; 9B9F
        .byte   $13                             ; 9BA0
        lda     #$07                            ; 9BA1
        jmp     LE399                           ; 9BA3

; ----------------------------------------------------------------------------
        bit     $93                             ; 9BA6
        bvs     L9BC4                           ; 9BA8
        bpl     L9BC4                           ; 9BAA
        lda     #$00                            ; 9BAC
        jsr     LF0BE                           ; 9BAE
        lda     #$01                            ; 9BB1
        sta     $0700,x                         ; 9BB3
        inc     $93                             ; 9BB6
        lda     $0704,x                         ; 9BB8
        jsr     LE086                           ; 9BBB
        jsr     LE0A4                           ; 9BBE
        jsr     LE0A0                           ; 9BC1
L9BC4:  rts                                     ; 9BC4

; ----------------------------------------------------------------------------
        dec     $0700,x                         ; 9BC5
        lda     $0700,x                         ; 9BC8
        beq     L9BD2                           ; 9BCB
        and     #$07                            ; 9BCD
        jmp     LE3A3                           ; 9BCF

; ----------------------------------------------------------------------------
L9BD2:  sta     $0601,x                         ; 9BD2
        rts                                     ; 9BD5

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 9BD6
        bne     L9C00                           ; 9BD9
        lda     $05                             ; 9BDB
        bpl     L9BE4                           ; 9BDD
        jsr     L9B30                           ; 9BDF
        bne     L9BFD                           ; 9BE2
L9BE4:  lda     $22                             ; 9BE4
        bne     L9BFD                           ; 9BE6
        lda     $0703,x                         ; 9BE8
        bpl     L9C03                           ; 9BEB
        jsr     LB131                           ; 9BED
        jsr     LA01F                           ; 9BF0
        jsr     LB167                           ; 9BF3
        bcs     L9BFD                           ; 9BF6
        lda     #$22                            ; 9BF8
        jmp     L9B06                           ; 9BFA

; ----------------------------------------------------------------------------
L9BFD:  jmp     L9B1B                           ; 9BFD

; ----------------------------------------------------------------------------
L9C00:  jmp     L9B13                           ; 9C00

; ----------------------------------------------------------------------------
L9C03:  jmp     L9B09                           ; 9C03

; ----------------------------------------------------------------------------
        jsr     L9014                           ; 9C06
        lda     $0700,x                         ; 9C09
        bne     L9C16                           ; 9C0C
        lda     #$06                            ; 9C0E
        jsr     LF0BE                           ; 9C10
        jsr     LE0A4                           ; 9C13
L9C16:  rts                                     ; 9C16

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 9C17
        bne     L9C00                           ; 9C1A
        lda     $05                             ; 9C1C
        bpl     L9C25                           ; 9C1E
        jsr     L9B30                           ; 9C20
        bne     L9C53                           ; 9C23
L9C25:  lda     $22                             ; 9C25
        bne     L9C53                           ; 9C27
        lda     $0703,x                         ; 9C29
        bpl     L9C39                           ; 9C2C
        jsr     LB131                           ; 9C2E
        jsr     LA01B                           ; 9C31
        jsr     LB167                           ; 9C34
        bcs     L9C53                           ; 9C37
L9C39:  ldy     #$02                            ; 9C39
        lda     $9B,y                           ; 9C3B
        bne     L9C43                           ; 9C3E
        jsr     LE0A2                           ; 9C40
L9C43:  lda     $96,y                           ; 9C43
        jsr     LAA1C                           ; 9C46
        bcs     L9C53                           ; 9C49
        lda     $0703,x                         ; 9C4B
        ora     #$80                            ; 9C4E
        sta     $0703,x                         ; 9C50
L9C53:  dec     $0705,x                         ; 9C53
        bne     L9C66                           ; 9C56
        lda     #$00                            ; 9C58
        sta     $0700,x                         ; 9C5A
        sta     $0701,x                         ; 9C5D
        inc     $0601,x                         ; 9C60
        jsr     LE0A4                           ; 9C63
L9C66:  bit     $93                             ; 9C66
        bvc     L9C6D                           ; 9C68
        jmp     L8A60                           ; 9C6A

; ----------------------------------------------------------------------------
L9C6D:  jmp     LA64C                           ; 9C6D

; ----------------------------------------------------------------------------
        jsr     L90A3                           ; 9C70
        lda     $0700,x                         ; 9C73
        bne     L9C7E                           ; 9C76
        jsr     L950A                           ; 9C78
        jsr     LE0A4                           ; 9C7B
L9C7E:  rts                                     ; 9C7E

; ----------------------------------------------------------------------------
        lda     $0700,x                         ; 9C7F
        bne     L9C93                           ; 9C82
        jsr     LEC75                           ; 9C84
        lda     #$02                            ; 9C87
        sta     $21                             ; 9C89
        ldy     #$0B                            ; 9C8B
        jsr     L9CC6                           ; 9C8D
        jsr     L992E                           ; 9C90
L9C93:  cmp     #$0C                            ; 9C93
        beq     L9C9B                           ; 9C95
        inc     $0700,x                         ; 9C97
L9C9A:  rts                                     ; 9C9A

; ----------------------------------------------------------------------------
L9C9B:  jsr     L994D                           ; 9C9B
        bne     L9C9A                           ; 9C9E
        sta     $21                             ; 9CA0
        jsr     LEC71                           ; 9CA2
        stx     $031A                           ; 9CA5
        lda     #$05                            ; 9CA8
        jsr     LF0BE                           ; 9CAA
        jsr     LE0A4                           ; 9CAD
        jsr     LA874                           ; 9CB0
        jsr     LA64C                           ; 9CB3
        lda     #$00                            ; 9CB6
        sta     $93                             ; 9CB8
        jsr     LE95B                           ; 9CBA
        lda     #$26                            ; 9CBD
        sta     $2B                             ; 9CBF
        lda     #$71                            ; 9CC1
        sta     $2C                             ; 9CC3
        rts                                     ; 9CC5

; ----------------------------------------------------------------------------
L9CC6:  lda     $0600,x                         ; 9CC6
        and     #$7F                            ; 9CC9
        sec                                     ; 9CCB
        sbc     #$28                            ; 9CCC
        dey                                     ; 9CCE
L9CCF:  iny                                     ; 9CCF
        sec                                     ; 9CD0
        sbc     #$03                            ; 9CD1
        bcs     L9CCF                           ; 9CD3
        tya                                     ; 9CD5
        jmp     LE096                           ; 9CD6

; ----------------------------------------------------------------------------
        jsr     L9D41                           ; 9CD9
        jsr     L9CF7                           ; 9CDC
        bne     L9CE9                           ; 9CDF
        ldy     #$03                            ; 9CE1
        jsr     LB047                           ; 9CE3
        jsr     L9D0F                           ; 9CE6
L9CE9:  lda     $7F                             ; 9CE9
        and     #$7F                            ; 9CEB
        bne     L9CF4                           ; 9CED
        lda     #$2B                            ; 9CEF
        jsr     LE992                           ; 9CF1
L9CF4:  jmp     LA64C                           ; 9CF4

; ----------------------------------------------------------------------------
L9CF7:  jsr     LA666                           ; 9CF7
        beq     L9D0E                           ; 9CFA
        lda     $93                             ; 9CFC
        and     #$7F                            ; 9CFE
        sta     $93                             ; 9D00
        bcs     L9D0E                           ; 9D02
        jsr     LE082                           ; 9D04
        lda     $93                             ; 9D07
        ora     #$40                            ; 9D09
        sta     $93                             ; 9D0B
        clc                                     ; 9D0D
L9D0E:  rts                                     ; 9D0E

; ----------------------------------------------------------------------------
L9D0F:  lda     $0600                           ; 9D0F
        cmp     #$04                            ; 9D12
        bcs     L9D0E                           ; 9D14
        lda     $93                             ; 9D16
        and     #$3F                            ; 9D18
        bne     L9D22                           ; 9D1A
        lda     #$05                            ; 9D1C
        sta     $00                             ; 9D1E
        bne     L9D2E                           ; 9D20
L9D22:  bit     $BE                             ; 9D22
        bpl     L9D41                           ; 9D24
        lda     $2B                             ; 9D26
        bne     L9D41                           ; 9D28
        lda     #$07                            ; 9D2A
        sta     $00                             ; 9D2C
L9D2E:  lda     #$00                            ; 9D2E
        sta     $0700,x                         ; 9D30
        lda     $00                             ; 9D33
        jsr     LF0BE                           ; 9D35
        lda     #$02                            ; 9D38
        sta     $21                             ; 9D3A
        sta     $22                             ; 9D3C
        jmp     LE0A4                           ; 9D3E

; ----------------------------------------------------------------------------
L9D41:  lda     $32                             ; 9D41
        bne     L9D48                           ; 9D43
        jsr     LA1A7                           ; 9D45
L9D48:  rts                                     ; 9D48

; ----------------------------------------------------------------------------
        lda     $0700,x                         ; 9D49
        inc     $0700,x                         ; 9D4C
        lda     $0700,x                         ; 9D4F
        cmp     #$1E                            ; 9D52
        beq     L9D5D                           ; 9D54
        and     #$07                            ; 9D56
        bne     L9D68                           ; 9D58
        jsr     LE0A2                           ; 9D5A
L9D5D:  lda     #$00                            ; 9D5D
        sta     $0700,x                         ; 9D5F
        dec     $0601,x                         ; 9D62
        jsr     LE0A4                           ; 9D65
L9D68:  jsr     L9D0F                           ; 9D68
        jmp     LA64C                           ; 9D6B

; ----------------------------------------------------------------------------
L9D6E:  lda     $0700,x                         ; 9D6E
        bne     L9D80                           ; 9D71
        lda     #$0F                            ; 9D73
        jsr     LE096                           ; 9D75
        lda     $93                             ; 9D78
        ora     #$80                            ; 9D7A
        sta     $93                             ; 9D7C
        bne     L9D84                           ; 9D7E
L9D80:  asl     $93                             ; 9D80
        lsr     $93                             ; 9D82
L9D84:  lda     $82                             ; 9D84
        cmp     #$01                            ; 9D86
        lda     #$F0                            ; 9D88
        bcc     L9D8E                           ; 9D8A
        lda     #$5A                            ; 9D8C
L9D8E:  cmp     $0700,x                         ; 9D8E
        beq     L9DA8                           ; 9D91
        lda     $0700,x                         ; 9D93
        and     #$0F                            ; 9D96
        bne     L9DA2                           ; 9D98
        lda     #$2B                            ; 9D9A
        jsr     LE992                           ; 9D9C
        jsr     LE0A2                           ; 9D9F
L9DA2:  inc     $0700,x                         ; 9DA2
        jmp     L9DBC                           ; 9DA5

; ----------------------------------------------------------------------------
L9DA8:  jsr     LE082                           ; 9DA8
        lda     #$00                            ; 9DAB
        sta     $0700,x                         ; 9DAD
        lda     $93                             ; 9DB0
        and     #$7F                            ; 9DB2
        sta     $93                             ; 9DB4
        jsr     L950A                           ; 9DB6
        jsr     LE0A4                           ; 9DB9
L9DBC:  jsr     L9CF7                           ; 9DBC
        jmp     LA64C                           ; 9DBF

; ----------------------------------------------------------------------------
        rts                                     ; 9DC2

; ----------------------------------------------------------------------------
L9DC3:  lda     $0700,x                         ; 9DC3
        bne     L9DDE                           ; 9DC6
        lda     #$02                            ; 9DC8
        sta     $21                             ; 9DCA
        sta     $22                             ; 9DCC
        jsr     LEC75                           ; 9DCE
        ldy     #$11                            ; 9DD1
        jsr     L9CC6                           ; 9DD3
        lda     #$2D                            ; 9DD6
        jsr     LE992                           ; 9DD8
        jsr     LF154                           ; 9DDB
L9DDE:  inc     $0700,x                         ; 9DDE
        lda     $0700,x                         ; 9DE1
        cmp     #$08                            ; 9DE4
        beq     L9DF2                           ; 9DE6
        and     #$03                            ; 9DE8
        bne     L9DEF                           ; 9DEA
        jsr     LE0A2                           ; 9DEC
L9DEF:  jmp     L9E2A                           ; 9DEF

; ----------------------------------------------------------------------------
L9DF2:  lda     $32                             ; 9DF2
        beq     L9E02                           ; 9DF4
        lda     $2A                             ; 9DF6
        beq     L9E11                           ; 9DF8
        clc                                     ; 9DFA
        adc     #$0A                            ; 9DFB
        sta     $2A                             ; 9DFD
        jmp     L9E11                           ; 9DFF

; ----------------------------------------------------------------------------
L9E02:  lda     $29                             ; 9E02
        bne     L9E11                           ; 9E04
        lda     $0600,x                         ; 9E06
        and     #$7F                            ; 9E09
        sec                                     ; 9E0B
        sbc     #$27                            ; 9E0C
        jsr     LA482                           ; 9E0E
L9E11:  lda     #$00                            ; 9E11
        sta     $0700,x                         ; 9E13
        jsr     L950A                           ; 9E16
        jsr     LE0A4                           ; 9E19
        jsr     LEC71                           ; 9E1C
        clc                                     ; 9E1F
        lda     $2C                             ; 9E20
        adc     #$25                            ; 9E22
        sta     $2C                             ; 9E24
        lda     #$26                            ; 9E26
        sta     $2B                             ; 9E28
L9E2A:  jmp     LA64C                           ; 9E2A

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 9E2D
        bne     L9E95                           ; 9E30
        lda     $0601,x                         ; 9E32
        and     #$30                            ; 9E35
        beq     L9E62                           ; 9E37
        inc     $0602,x                         ; 9E39
        lda     $0602,x                         ; 9E3C
        cmp     #$B0                            ; 9E3F
        bcs     L9E51                           ; 9E41
        lda     $08                             ; 9E43
        and     #$10                            ; 9E45
        bne     L9E6F                           ; 9E47
        lda     $0A                             ; 9E49
        cmp     #$20                            ; 9E4B
        bcs     L9E8C                           ; 9E4D
        bcc     L9E6F                           ; 9E4F
L9E51:  lda     $08                             ; 9E51
        and     #$C0                            ; 9E53
        ora     #$03                            ; 9E55
        sta     $0601,x                         ; 9E57
        lda     #$66                            ; 9E5A
        jsr     LFAB3                           ; 9E5C
        jmp     LA64C                           ; 9E5F

; ----------------------------------------------------------------------------
L9E62:  lda     $0606,x                         ; 9E62
        cmp     #$0D                            ; 9E65
        bcs     L9E7D                           ; 9E67
        lda     $0A                             ; 9E69
        cmp     #$50                            ; 9E6B
        bcs     L9E76                           ; 9E6D
L9E6F:  lda     $0602,x                         ; 9E6F
        cmp     #$40                            ; 9E72
        bcs     L9E51                           ; 9E74
L9E76:  lda     #$33                            ; 9E76
        sta     $0601,x                         ; 9E78
        bne     L9E8C                           ; 9E7B
L9E7D:  lda     $22                             ; 9E7D
        bne     L9E95                           ; 9E7F
        lda     #$01                            ; 9E81
        sta     $03                             ; 9E83
        lda     #$00                            ; 9E85
        jsr     LFAD7                           ; 9E87
        beq     L9E6F                           ; 9E8A
L9E8C:  lda     $7F                             ; 9E8C
        and     #$07                            ; 9E8E
        bne     L9E95                           ; 9E90
        jsr     LE0A2                           ; 9E92
L9E95:  jmp     LA64C                           ; 9E95

; ----------------------------------------------------------------------------
        lda     $22                             ; 9E98
        bne     L9EFD                           ; 9E9A
        lda     #$00                            ; 9E9C
        sta     $03                             ; 9E9E
        lda     $0700,x                         ; 9EA0
        beq     L9EAA                           ; 9EA3
        dec     $0700,x                         ; 9EA5
        bne     L9ED1                           ; 9EA8
L9EAA:  lda     $0601,x                         ; 9EAA
        and     #$0F                            ; 9EAD
        ora     #$80                            ; 9EAF
        sta     $0601,x                         ; 9EB1
        jsr     LFAD7                           ; 9EB4
        beq     L9EBB                           ; 9EB7
        bcc     L9ED1                           ; 9EB9
L9EBB:  lda     #$84                            ; 9EBB
        sta     $0601,x                         ; 9EBD
        lda     #$FF                            ; 9EC0
        sta     $0604,x                         ; 9EC2
        lda     $E2                             ; 9EC5
        and     #$3F                            ; 9EC7
        adc     #$3C                            ; 9EC9
        sta     $0700,x                         ; 9ECB
        jmp     L96F4                           ; 9ECE

; ----------------------------------------------------------------------------
L9ED1:  lda     $0606,x                         ; 9ED1
        pha                                     ; 9ED4
        cmp     #$10                            ; 9ED5
        bne     L9EE1                           ; 9ED7
        lda     $7F                             ; 9ED9
        lsr     a                               ; 9EDB
        adc     #$1E                            ; 9EDC
        sta     $0700,x                         ; 9EDE
L9EE1:  pla                                     ; 9EE1
        cmp     #$02                            ; 9EE2
        bcc     L9EF7                           ; 9EE4
        and     #$03                            ; 9EE6
        bne     L9EFA                           ; 9EE8
        lda     $0606,x                         ; 9EEA
        and     #$04                            ; 9EED
        bne     L9EF7                           ; 9EEF
        jsr     LE0A4                           ; 9EF1
        jmp     L9EFA                           ; 9EF4

; ----------------------------------------------------------------------------
L9EF7:  jsr     LE0A2                           ; 9EF7
L9EFA:  jsr     LA1A7                           ; 9EFA
L9EFD:  jsr     LA666                           ; 9EFD
        beq     L9F04                           ; 9F00
        bcc     L9F15                           ; 9F02
L9F04:  lda     $0601,x                         ; 9F04
        and     #$0F                            ; 9F07
        cmp     #$05                            ; 9F09
        beq     L9F15                           ; 9F0B
        lda     #$15                            ; 9F0D
        sta     $0601,x                         ; 9F0F
        jsr     LE0A4                           ; 9F12
L9F15:  jmp     LA64C                           ; 9F15

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 9F18
        bne     L9F15                           ; 9F1B
        ldy     #$02                            ; 9F1D
        lda     $BE                             ; 9F1F
        bpl     L9F25                           ; 9F21
        ldy     #$03                            ; 9F23
L9F25:  jsr     LB0F2                           ; 9F25
        jmp     L8F3F                           ; 9F28

; ----------------------------------------------------------------------------
        jsr     L90E7                           ; 9F2B
        lda     #$30                            ; 9F2E
        sta     $26                             ; 9F30
        rts                                     ; 9F32

; ----------------------------------------------------------------------------
        jsr     LA666                           ; 9F33
        bne     L9F48                           ; 9F36
        lda     $22                             ; 9F38
        bne     L9F48                           ; 9F3A
        ldy     #$02                            ; 9F3C
        jsr     L80DB                           ; 9F3E
        bne     L9F45                           ; 9F41
        ldy     #$04                            ; 9F43
L9F45:  jsr     LB0F2                           ; 9F45
L9F48:  jsr     LA64C                           ; 9F48
        lda     $26                             ; 9F4B
        beq     L9F61                           ; 9F4D
        cmp     #$03                            ; 9F4F
        bcs     L9F61                           ; 9F51
        lda     #$00                            ; 9F53
        sta     $26                             ; 9F55
L9F57:  jsr     LA604                           ; 9F57
        lda     #$4E                            ; 9F5A
        sta     $71                             ; 9F5C
        jmp     LE082                           ; 9F5E

; ----------------------------------------------------------------------------
L9F61:  rts                                     ; 9F61

; ----------------------------------------------------------------------------
L9F62:  lda     $29                             ; 9F62
        bne     L9FA6                           ; 9F64
        lda     $0707                           ; 9F66
        and     #$40                            ; 9F69
        bne     L9FBC                           ; 9F6B
        lda     $0600                           ; 9F6D
        cmp     #$01                            ; 9F70
        bne     L9F8E                           ; 9F72
        lda     #$03                            ; 9F74
        sta     $22                             ; 9F76
        lda     $0601                           ; 9F78
        and     #$F0                            ; 9F7B
        ora     #$01                            ; 9F7D
        sta     $0601                           ; 9F7F
        jsr     LE0A4                           ; 9F82
        lda     #$00                            ; 9F85
        sta     $32                             ; 9F87
        sta     $2A                             ; 9F89
        sta     $0600                           ; 9F8B
L9F8E:  lda     $28                             ; 9F8E
        bne     L9FA6                           ; 9F90
        lda     $0707                           ; 9F92
        lsr     a                               ; 9F95
        bcc     L9FA6                           ; 9F96
L9F98:  lda     $0707                           ; 9F98
        and     #$7E                            ; 9F9B
        sta     $0707                           ; 9F9D
        jsr     LEC7E                           ; 9FA0
        jsr     LF07B                           ; 9FA3
L9FA6:  lda     $20                             ; 9FA6
        bne     L9FB1                           ; 9FA8
        lda     $0707                           ; 9FAA
        bmi     L9F98                           ; 9FAD
        bpl     L9FBC                           ; 9FAF
L9FB1:  lda     $0707                           ; 9FB1
        bmi     L9FC2                           ; 9FB4
        lda     $7F                             ; 9FB6
        and     #$01                            ; 9FB8
        bne     L9FBF                           ; 9FBA
L9FBC:  jsr     LE0A0                           ; 9FBC
L9FBF:  jmp     L9FE0                           ; 9FBF

; ----------------------------------------------------------------------------
L9FC2:  jsr     LEC7E                           ; 9FC2
        lda     $7F                             ; 9FC5
        and     #$03                            ; 9FC7
        beq     L9FBC                           ; 9FC9
        cmp     #$03                            ; 9FCB
        beq     L9FDA                           ; 9FCD
        lda     #$26                            ; 9FCF
        sta     $04B1                           ; 9FD1
        sta     $04B2                           ; 9FD4
        sta     $04B3                           ; 9FD7
L9FDA:  jsr     LF07B                           ; 9FDA
        jmp     L9FBC                           ; 9FDD

; ----------------------------------------------------------------------------
L9FE0:  lda     #$F8                            ; 9FE0
        sta     $0204                           ; 9FE2
        sta     $0207                           ; 9FE5
        sta     $0208                           ; 9FE8
        sta     $020B                           ; 9FEB
        lda     $C6                             ; 9FEE
        cmp     #$01                            ; 9FF0
        bne     LA01A                           ; 9FF2
        lda     $0602                           ; 9FF4
        sec                                     ; 9FF7
        sbc     #$20                            ; 9FF8
        sta     $0204                           ; 9FFA
        lda     #$57                            ; 9FFD
        .byte   $8D                             ; 9FFF
