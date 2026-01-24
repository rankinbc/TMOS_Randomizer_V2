; ============================================================================
; The Magic of Scheherazade - Bank 03 Disassembly
; ============================================================================
; File Offset: 0x06000 - 0x07FFF
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
; Input file: C:/claude-workspace/TMOS_AI/rom-files/disassembly/output/banks/bank_03.bin
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
L0120           := $0120
L0190           := $0190
L080B           := $080B
L09C9           := $09C9
L0CA5           := $0CA5
L0EE3           := $0EE3
L0F26           := $0F26
L1019           := $1019
L111A           := $111A
L1306           := $1306
L160F           := $160F
L1611           := $1611
L1716           := $1716
L181B           := $181B
L1A14           := $1A14
L1B07           := $1B07
L1F30           := $1F30
L1F90           := $1F90
PPU_CTRL        := $2000
PPU_MASK        := $2001
PPU_STATUS      := $2002
OAM_ADDR        := $2003
OAM_DATA        := $2004
PPU_SCROLL      := $2005
PPU_ADDR        := $2006
PPU_DATA        := $2007
L222E           := $222E
L23B9           := $23B9
L2600           := $2600
L2601           := $2601
L2606           := $2606
L2706           := $2706
L270A           := $270A
L270B           := $270B
L2711           := $2711
L2714           := $2714
L2811           := $2811
L2813           := $2813
L2A07           := $2A07
L2C14           := $2C14
L2C3C           := $2C3C
L2C42           := $2C42
L2F26           := $2F26
L3028           := $3028
L312C           := $312C
L325A           := $325A
L3445           := $3445
L380F           := $380F
L38AA           := $38AA
L3B3B           := $3B3B
OAM_DMA         := $4014
APU_STATUS      := $4015
JOY1            := $4016
JOY2_FRAME      := $4017
L4261           := $4261
L443A           := $443A
L4A49           := $4A49
L4E4D           := $4E4D
L5259           := $5259
L5B31           := $5B31
L6564           := $6564
L6B2A           := $6B2A
L6C4D           := $6C4D
L6E6D           := $6E6D
L7A6D           := $7A6D
L7F8A           := $7F8A
L7FBE           := $7FBE
L7FE6           := $7FE6
LA03D           := $A03D
LA0D9           := $A0D9
LA10D           := $A10D
LA1A6           := $A1A6
LA1C2           := $A1C2
LA1E9           := $A1E9
LA22D           := $A22D
LA23E           := $A23E
LA26D           := $A26D
LA27F           := $A27F
LA35C           := $A35C
LA3A8           := $A3A8
LA4F5           := $A4F5
LA670           := $A670
LA6D0           := $A6D0
LA6F1           := $A6F1
LA6FE           := $A6FE
LA709           := $A709
LA736           := $A736
LA7A5           := $A7A5
LA7BA           := $A7BA
LA7FF           := $A7FF
LA814           := $A814
LA8A0           := $A8A0
LA91A           := $A91A
LA941           := $A941
LA94D           := $A94D
LA9C7           := $A9C7
LA9D8           := $A9D8
LA9E5           := $A9E5
LA9EF           := $A9EF
LAA00           := $AA00
LAB65           := $AB65
LAC81           := $AC81
LAD00           := $AD00
LAFDB           := $AFDB
LAFF2           := $AFF2
LB06B           := $B06B
LB06D           := $B06D
LB089           := $B089
LB0C3           := $B0C3
LB143           := $B143
LB189           := $B189
LB1A1           := $B1A1
LB1A5           := $B1A5
LB2BB           := $B2BB
LB32E           := $B32E
LB35B           := $B35B
LB37D           := $B37D
LB3D3           := $B3D3
LB3EF           := $B3EF
LB410           := $B410
LB42E           := $B42E
LB457           := $B457
LB45C           := $B45C
LB462           := $B462
LB6A9           := $B6A9
LB6E2           := $B6E2
LB707           := $B707
LB726           := $B726
LC8BE           := $C8BE
LE052           := $E052
LE080           := $E080
LE096           := $E096
LE0E8           := $E0E8
LE8C8           := $E8C8
LE8EF           := $E8EF
LE95B           := $E95B
LE97D           := $E97D
LE992           := $E992
LE9EB           := $E9EB
LEA7E           := $EA7E
LEAC1           := $EAC1
LEBB8           := $EBB8
LEBDD           := $EBDD
LF09B           := $F09B
LF0B5           := $F0B5
LF540           := $F540
LF5A0           := $F5A0
; ----------------------------------------------------------------------------
        bcs     L8072                           ; 8000
        .byte   $D3                             ; 8002
        eor     ($B8,x)                         ; 8003
        .byte   $80                             ; 8005
        cmp     $01,x                           ; 8006
        bcs     L7F8A                           ; 8008
        cmp     $41,x                           ; 800A
        clv                                     ; 800C
        bmi     L801E                           ; 800D
        brk                                     ; 800F
        jsr     L1F30                           ; 8010
        brk                                     ; 8013
        plp                                     ; 8014
        rti                                     ; 8015

; ----------------------------------------------------------------------------
        .byte   $D7                             ; 8016
        brk                                     ; 8017
        jsr     LF540                           ; 8018
        brk                                     ; 801B
        plp                                     ; 801C
        .byte   $30                             ; 801D
L801E:  .byte   $0F                             ; 801E
        rti                                     ; 801F

; ----------------------------------------------------------------------------
        cld                                     ; 8020
        bmi     L8042                           ; 8021
        rti                                     ; 8023

; ----------------------------------------------------------------------------
        bne     L8066                           ; 8024
        .byte   $D7                             ; 8026
        rti                                     ; 8027

; ----------------------------------------------------------------------------
        cld                                     ; 8028
        rti                                     ; 8029

; ----------------------------------------------------------------------------
        sbc     $40,x                           ; 802A
        bne     L7FBE                           ; 802C
        .byte   $0F                             ; 802E
        brk                                     ; 802F
        jsr     L1F90                           ; 8030
        brk                                     ; 8033
        plp                                     ; 8034
        ldy     #$D7                            ; 8035
        brk                                     ; 8037
        jsr     LF5A0                           ; 8038
        brk                                     ; 803B
        plp                                     ; 803C
        bcc     L804E                           ; 803D
        rti                                     ; 803F

; ----------------------------------------------------------------------------
        cld                                     ; 8040
        .byte   $90                             ; 8041
L8042:  .byte   $1F                             ; 8042
        rti                                     ; 8043

; ----------------------------------------------------------------------------
L8044:  bne     L7FE6                           ; 8044
        .byte   $D7                             ; 8046
        rti                                     ; 8047

; ----------------------------------------------------------------------------
        cld                                     ; 8048
        ldy     #$F5                            ; 8049
        rti                                     ; 804B

; ----------------------------------------------------------------------------
        bne     L8096                           ; 804C
L804E:  lda     #$06                            ; 804E
        sta     $11                             ; 8050
        sta     PPU_MASK                        ; 8052
        pla                                     ; 8055
        jsr     LA23E                           ; 8056
        lda     #$00                            ; 8059
        ldx     #$0F                            ; 805B
L805D:  sta     $00,x                           ; 805D
        dex                                     ; 805F
        bpl     L805D                           ; 8060
        rts                                     ; 8062

; ----------------------------------------------------------------------------
        ldx     #$00                            ; 8063
        .byte   $86                             ; 8065
L8066:  ora     L86E8                           ; 8066
        .byte   $0C                             ; 8069
L806A:  jsr     LF0B5                           ; 806A
        inc     $0D                             ; 806D
        lda     $0D                             ; 806F
        .byte   $C9                             ; 8071
L8072:  bpl     L8044                           ; 8072
        sbc     $A9,x                           ; 8074
        brk                                     ; 8076
        sta     $0D                             ; 8077
        clc                                     ; 8079
        lda     $0F                             ; 807A
        adc     #$04                            ; 807C
        sta     $0F                             ; 807E
        jsr     L9F25                           ; 8080
        inc     $0C                             ; 8083
        lda     $0F                             ; 8085
        cmp     #$80                            ; 8087
        bcc     L806A                           ; 8089
        lda     #$80                            ; 808B
        sta     $0F                             ; 808D
        rts                                     ; 808F

; ----------------------------------------------------------------------------
        lda     #$01                            ; 8090
        sta     $0B                             ; 8092
        lda     #$00                            ; 8094
L8096:  sta     $0C                             ; 8096
        sta     $0D                             ; 8098
        jsr     L9F25                           ; 809A
L809D:  jsr     LF0B5                           ; 809D
        inc     $0D                             ; 80A0
        lda     $0D                             ; 80A2
        cmp     #$10                            ; 80A4
        bne     L809D                           ; 80A6
        lda     #$00                            ; 80A8
        sta     $0D                             ; 80AA
        sec                                     ; 80AC
        lda     $0E                             ; 80AD
        sbc     #$04                            ; 80AF
        sta     $0E                             ; 80B1
        jsr     L9F25                           ; 80B3
        inc     $0C                             ; 80B6
        lda     $0A                             ; 80B8
        cmp     $0E                             ; 80BA
        bcc     L809D                           ; 80BC
        sta     $0E                             ; 80BE
        rts                                     ; 80C0

; ----------------------------------------------------------------------------
        lda     #$FF                            ; 80C1
        jsr     LE992                           ; 80C3
        lda     #$B4                            ; 80C6
        sta     $00                             ; 80C8
L80CA:  jsr     LE95B                           ; 80CA
        dec     $00                             ; 80CD
        bne     L80CA                           ; 80CF
        lda     #$0B                            ; 80D1
        sta     $1A                             ; 80D3
        rts                                     ; 80D5

; ----------------------------------------------------------------------------
        jsr     LA10D                           ; 80D6
L80D9:  jsr     LA27F                           ; 80D9
        lda     $1E                             ; 80DC
        and     #$03                            ; 80DE
        bne     L80D9                           ; 80E0
        inc     $14                             ; 80E2
        lda     $14                             ; 80E4
        cmp     #$F0                            ; 80E6
        bcc     L80EE                           ; 80E8
        adc     #$0F                            ; 80EA
        sta     $14                             ; 80EC
L80EE:  and     #$07                            ; 80EE
        bne     L80D9                           ; 80F0
        jsr     LA1C2                           ; 80F2
        dec     $0D                             ; 80F5
        bne     L80D9                           ; 80F7
        ldy     #$00                            ; 80F9
        lda     ($0E),y                         ; 80FB
        cmp     #$FF                            ; 80FD
        beq     L8107                           ; 80FF
        jsr     LA1E9                           ; 8101
        jmp     LA0D9                           ; 8104

; ----------------------------------------------------------------------------
L8107:  jsr     LA27F                           ; 8107
        jmp     LA3A8                           ; 810A

; ----------------------------------------------------------------------------
        lda     #$06                            ; 810D
        sta     $11                             ; 810F
        sta     PPU_MASK                        ; 8111
        lda     #$00                            ; 8114
        jsr     LE8C8                           ; 8116
        lda     #$00                            ; 8119
        ldx     #$0F                            ; 811B
L811D:  sta     $00,x                           ; 811D
        dex                                     ; 811F
        bpl     L811D                           ; 8120
        lda     #$05                            ; 8122
        jsr     LE9EB                           ; 8124
        jsr     LE0E8                           ; 8127
        lda     #$88                            ; 812A
        sta     $0E                             ; 812C
        lda     #$A2                            ; 812E
        sta     $0F                             ; 8130
        lda     #$01                            ; 8132
        sta     $0D                             ; 8134
        lda     #$00                            ; 8136
        sta     $BC                             ; 8138
        .byte   $A0                             ; 813A
L813B:  brk                                     ; 813B
        sty     $BD                             ; 813C
        jsr     LE080                           ; 813E
        lda     #$05                            ; 8141
L8143:  sta     $1A                             ; 8143
        lda     #$03                            ; 8145
        sta     $18                             ; 8147
        jsr     LE95B                           ; 8149
        lda     #$1E                            ; 814C
        sta     $11                             ; 814E
L8150:  lda     #$01                            ; 8150
        sta     $2F                             ; 8152
        sec                                     ; 8154
        lda     $1A                             ; 8155
        sbc     #$02                            ; 8157
        bmi     L8195                           ; 8159
        asl     a                               ; 815B
        asl     a                               ; 815C
        asl     a                               ; 815D
        asl     a                               ; 815E
        sta     $00                             ; 815F
        ldy     #$00                            ; 8161
        ldx     $0162                           ; 8163
        lda     #$3F                            ; 8166
        sta     $0163,x                         ; 8168
        inx                                     ; 816B
        lda     #$00                            ; 816C
        sta     $0163,x                         ; 816E
        inx                                     ; 8171
        lda     #$20                            ; 8172
        sta     $0163,x                         ; 8174
        inx                                     ; 8177
L8178:  lda     $04A0,y                         ; 8178
        sec                                     ; 817B
        sbc     $00                             ; 817C
        beq     L8184                           ; 817E
L8180:  bcs     L8184                           ; 8180
        lda     #$0F                            ; 8182
L8184:  sta     $0163,x                         ; 8184
        inx                                     ; 8187
        iny                                     ; 8188
        cpy     #$20                            ; 8189
        bne     L8178                           ; 818B
        lda     #$00                            ; 818D
        sta     $0163,x                         ; 818F
        stx     $0162                           ; 8192
L8195:  jsr     LE95B                           ; 8195
        lda     $2F                             ; 8198
        bne     L8195                           ; 819A
        dec     $1A                             ; 819C
        bne     L8150                           ; 819E
        lda     #$66                            ; 81A0
        jsr     LE992                           ; 81A2
        rts                                     ; 81A5

; ----------------------------------------------------------------------------
        lda     $14                             ; 81A6
        clc                                     ; 81A8
        adc     #$00                            ; 81A9
        cmp     #$F0                            ; 81AB
        bcc     L81B1                           ; 81AD
        adc     #$0F                            ; 81AF
L81B1:  and     #$F8                            ; 81B1
        sta     $03                             ; 81B3
        lda     #$00                            ; 81B5
        asl     $03                             ; 81B7
        rol     a                               ; 81B9
        asl     $03                             ; 81BA
        rol     a                               ; 81BC
        ora     #$20                            ; 81BD
        sta     $04                             ; 81BF
        rts                                     ; 81C1

; ----------------------------------------------------------------------------
        jsr     LA1A6                           ; 81C2
        ldx     $0162                           ; 81C5
        lda     $04                             ; 81C8
        sta     $0163,x                         ; 81CA
        inx                                     ; 81CD
        lda     $03                             ; 81CE
        sta     $0163,x                         ; 81D0
        inx                                     ; 81D3
        lda     #$60                            ; 81D4
        sta     $0163,x                         ; 81D6
        inx                                     ; 81D9
        lda     #$2C                            ; 81DA
        sta     $0163,x                         ; 81DC
        inx                                     ; 81DF
        lda     #$00                            ; 81E0
        sta     $0163,x                         ; 81E2
        stx     $0162                           ; 81E5
        rts                                     ; 81E8

; ----------------------------------------------------------------------------
        jsr     LA1A6                           ; 81E9
        ldy     #$00                            ; 81EC
        lda     ($0E),y                         ; 81EE
        cmp     #$FF                            ; 81F0
        beq     L823D                           ; 81F2
        clc                                     ; 81F4
        adc     $03                             ; 81F5
        sta     $03                             ; 81F7
        lda     $04                             ; 81F9
        adc     #$00                            ; 81FB
        sta     $04                             ; 81FD
L81FF:  ldx     $6D4C                           ; 81FF
        bcs     L8250                           ; 8202
        lda     #$B6                            ; 8204
        jmp     LA6FE                           ; 8206

; ----------------------------------------------------------------------------
        jmp     LB707                           ; 8209

; ----------------------------------------------------------------------------
        jsr     LA9D8                           ; 820C
        lda     #$00                            ; 820F
        sta     $1A                             ; 8211
        ldx     #$1C                            ; 8213
L8215:  sta     $04D0,x                         ; 8215
        dex                                     ; 8218
        bpl     L8215                           ; 8219
L821B:  jsr     LE95B                           ; 821B
        jsr     LA22D                           ; 821E
        lda     $1A                             ; 8221
        bpl     L8228                           ; 8223
        jsr     LE8EF                           ; 8225
L8228:  bit     $1A                             ; 8228
        bvc     L821B                           ; 822A
        rts                                     ; 822C

; ----------------------------------------------------------------------------
        lda     $1A                             ; 822D
L822F:  and     #$3F                            ; 822F
        jsr     LE97D                           ; 8231
        .byte   $42                             ; 8234
        ldx     #$D2                            ; 8235
        ldx     #$F2                            ; 8237
        ldx     #$11                            ; 8239
        .byte   $A3                             ; 823B
        .byte   $DC                             ; 823C
L823D:  .byte   $A3                             ; 823D
        .byte   $A3                             ; 823E
        .byte   $A7                             ; 823F
        .byte   $93                             ; 8240
        .byte   $A7                             ; 8241
        ldx     $92                             ; 8242
        dex                                     ; 8244
        bne     L824C                           ; 8245
        lda     #$40                            ; 8247
        sta     $04D3                           ; 8249
L824C:  jsr     LA26D                           ; 824C
        .byte   $AE                             ; 824F
L8250:  .byte   $FC                             ; 8250
        .byte   $03                             ; 8251
        beq     L825C                           ; 8252
        sta     $03FC                           ; 8254
        lda     #$80                            ; 8257
        sta     $04D3                           ; 8259
L825C:  lda     $031C                           ; 825C
        and     #$F0                            ; 825F
        ora     #$0F                            ; 8261
        sta     $031C                           ; 8263
        inc     $1A                             ; 8266
        lda     #$FF                            ; 8268
        jmp     LE992                           ; 826A

; ----------------------------------------------------------------------------
        lda     #$03                            ; 826D
        bit     $04D3                           ; 826F
        bmi     L8280                           ; 8272
        lda     $1E                             ; 8274
        ora     $E0                             ; 8276
        and     #$03                            ; 8278
        cmp     #$03                            ; 827A
        bcc     L8280                           ; 827C
        lda     #$02                            ; 827E
L8280:  sta     $04D6                           ; 8280
        asl     a                               ; 8283
        asl     a                               ; 8284
        tax                                     ; 8285
        ora     $E3                             ; 8286
        and     #$07                            ; 8288
        tay                                     ; 828A
        ora     $E4                             ; 828B
        and     #$0F                            ; 828D
        lsr     a                               ; 828F
        ora     #$01                            ; 8290
        sta     $02                             ; 8292
        lda     #$01                            ; 8294
        sta     $00                             ; 8296
L8298:  lda     $A973,x                         ; 8298
        sta     $01                             ; 829B
L829D:  lda     $04D7,y                         ; 829D
        bne     L82B6                           ; 82A0
L82A2:  lda     $00                             ; 82A2
        sta     $04D7,y                         ; 82A4
        sta     $03                             ; 82A7
        dec     $01                             ; 82A9
        bne     L82BC                           ; 82AB
        inx                                     ; 82AD
        inc     $00                             ; 82AE
        txa                                     ; 82B0
        and     #$03                            ; 82B1
        bne     L8298                           ; 82B3
        rts                                     ; 82B5

; ----------------------------------------------------------------------------
L82B6:  cmp     $00                             ; 82B6
        bne     L82BC                           ; 82B8
        iny                                     ; 82BA
        iny                                     ; 82BB
L82BC:  tya                                     ; 82BC
        adc     $02                             ; 82BD
        and     #$07                            ; 82BF
        tay                                     ; 82C1
        dec     $03                             ; 82C2
        bpl     L829D                           ; 82C4
L82C6:  lda     $04D7,y                         ; 82C6
        beq     L82A2                           ; 82C9
        iny                                     ; 82CB
        tya                                     ; 82CC
        and     #$07                            ; 82CD
        tay                                     ; 82CF
        bpl     L82C6                           ; 82D0
        lda     $04D0                           ; 82D2
        bne     L82DC                           ; 82D5
        lda     #$81                            ; 82D7
        jsr     LE9EB                           ; 82D9
L82DC:  lda     $04D0                           ; 82DC
        cmp     #$0D                            ; 82DF
        bcc     L82E9                           ; 82E1
        inc     $1A                             ; 82E3
        ldx     #$02                            ; 82E5
        stx     $18                             ; 82E7
L82E9:  clc                                     ; 82E9
        inc     $04D0                           ; 82EA
        adc     #$06                            ; 82ED
        jmp     LB3D3                           ; 82EF

; ----------------------------------------------------------------------------
        lda     #$06                            ; 82F2
        jsr     LE8C8                           ; 82F4
        lda     #$16                            ; 82F7
        jsr     LB707                           ; 82F9
        jsr     LA7A5                           ; 82FC
        lda     #$83                            ; 82FF
        sta     $1A                             ; 8301
        jsr     LF09B                           ; 8303
L8306:  jsr     LF0B5                           ; 8306
        lda     $031C                           ; 8309
        and     #$0F                            ; 830C
        bne     L8306                           ; 830E
        rts                                     ; 8310

; ----------------------------------------------------------------------------
        lda     $04D1                           ; 8311
        bne     L8335                           ; 8314
        lda     #$3D                            ; 8316
        jsr     LE992                           ; 8318
        lda     #$85                            ; 831B
        sta     $1A                             ; 831D
        ldx     #$00                            ; 831F
        .byte   $AD                             ; 8321
L8322:  .byte   $D3                             ; 8322
        .byte   $04                             ; 8323
        bmi     L832C                           ; 8324
        bit     $04D3                           ; 8326
        bvs     L832F                           ; 8329
        inx                                     ; 832B
L832C:  inx                                     ; 832C
        dec     $1A                             ; 832D
L832F:  lda     $A338,x                         ; 832F
        jsr     LA670                           ; 8332
L8335:  inc     $1A                             ; 8335
        rts                                     ; 8337

; ----------------------------------------------------------------------------
        cpy     $C3                             ; 8338
        .byte   $83                             ; 833A
        lda     $89                             ; 833B
        adc     $04D5                           ; 833D
        sta     $00                             ; 8340
        lda     $8A                             ; 8342
        adc     #$0B                            ; 8344
        lsr     a                               ; 8346
        adc     $00                             ; 8347
        and     #$0F                            ; 8349
        bne     L834F                           ; 834B
        lda     #$02                            ; 834D
L834F:  cmp     #$0A                            ; 834F
        bcc     L8355                           ; 8351
        sbc     #$06                            ; 8353
L8355:  sta     $04D5                           ; 8355
        inc     $04D1                           ; 8358
        rts                                     ; 835B

; ----------------------------------------------------------------------------
        pha                                     ; 835C
        jsr     LA6F1                           ; 835D
        ldx     #$00                            ; 8360
        pla                                     ; 8362
        beq     L8378                           ; 8363
        pha                                     ; 8365
        ldy     #$23                            ; 8366
        lda     #$A9                            ; 8368
        sta     $05                             ; 836A
        lda     #$84                            ; 836C
        sta     $04                             ; 836E
        jsr     LB143                           ; 8370
        stx     $18                             ; 8373
        ldx     #$01                            ; 8375
        pla                                     ; 8377
L8378:  asl     a                               ; 8378
        tay                                     ; 8379
        lda     $A9AE,y                         ; 837A
        sta     $04                             ; 837D
        lda     $A9AF,y                         ; 837F
        sta     $05                             ; 8382
        ldy     #$00                            ; 8384
L8386:  lda     ($04),y                         ; 8386
        sta     $0163,x                         ; 8388
        eor     #$FF                            ; 838B
        beq     L839B                           ; 838D
        cmp     #$FE                            ; 838F
        beq     L83A6                           ; 8391
        cmp     #$34                            ; 8393
        beq     L83AE                           ; 8395
L8397:  iny                                     ; 8397
        inx                                     ; 8398
        bne     L8386                           ; 8399
L839B:  sta     $0163,x                         ; 839B
        stx     $0162                           ; 839E
        lda     $18                             ; 83A1
        bmi     L83C4                           ; 83A3
        rts                                     ; 83A5

; ----------------------------------------------------------------------------
L83A6:  lda     $04D5                           ; 83A6
        sta     $0163,x                         ; 83A9
        bpl     L8397                           ; 83AC
L83AE:  lda     $04D6                           ; 83AE
        asl     a                               ; 83B1
        asl     a                               ; 83B2
        iny                                     ; 83B3
        adc     ($04),y                         ; 83B4
        sty     $3C                             ; 83B6
        tay                                     ; 83B8
        inx                                     ; 83B9
        lda     $A3CC,y                         ; 83BA
        sta     $0163,x                         ; 83BD
        ldy     $3C                             ; 83C0
        bcc     L8397                           ; 83C2
L83C4:  sta     $06                             ; 83C4
        jsr     LA6FE                           ; 83C6
        jmp     LA709                           ; 83C9

; ----------------------------------------------------------------------------
        ora     ($03,x)                         ; 83CC
        ora     $00                             ; 83CE
        .byte   $02                             ; 83D0
        .byte   $02                             ; 83D1
        ora     $00                             ; 83D2
        .byte   $02                             ; 83D4
        .byte   $03                             ; 83D5
        .byte   $03                             ; 83D6
        brk                                     ; 83D7
        ora     ($05,x)                         ; 83D8
        ora     $00                             ; 83DA
        lda     $04D1                           ; 83DC
        jsr     LE97D                           ; 83DF
        .byte   $3B                             ; 83E2
        .byte   $A3                             ; 83E3
        .byte   $F4                             ; 83E4
        .byte   $A3                             ; 83E5
        and     $58A4                           ; 83E6
        ldy     $FB                             ; 83E9
        ldy     $1D                             ; 83EB
        lda     $34                             ; 83ED
        ldx     $71                             ; 83EF
        lda     $D3                             ; 83F1
        lda     $A9                             ; 83F3
        ora     ($20,x)                         ; 83F5
        .byte   $5C                             ; 83F7
        .byte   $A3                             ; 83F8
        lda     #$00                            ; 83F9
        jsr     LA670                           ; 83FB
        and     #$FF                            ; 83FE
        beq     L8406                           ; 8400
        lda     #$29                            ; 8402
        bne     L8422                           ; 8404
L8406:  ldx     #$01                            ; 8406
        lda     #$09                            ; 8408
L840A:  cmp     $89,x                           ; 840A
        bne     L8415                           ; 840C
        dex                                     ; 840E
        bpl     L840A                           ; 840F
        lda     #$E6                            ; 8411
        bne     L8422                           ; 8413
L8415:  lda     $8A                             ; 8415
        cmp     $04D5                           ; 8417
        bcs     L8429                           ; 841A
        lda     $89                             ; 841C
        bne     L8429                           ; 841E
        lda     #$E7                            ; 8420
L8422:  sta     $04D2                           ; 8422
        lda     #$86                            ; 8425
        sta     $1A                             ; 8427
L8429:  inc     $04D1                           ; 8429
        rts                                     ; 842C

; ----------------------------------------------------------------------------
        lda     #$8A                            ; 842D
        bit     $04D3                           ; 842F
        bvs     L8452                           ; 8432
        bpl     L8452                           ; 8434
        lda     #$C0                            ; 8436
        sta     $04D3                           ; 8438
        lda     #$82                            ; 843B
        jsr     LA670                           ; 843D
        ldx     #$07                            ; 8440
        lda     #$00                            ; 8442
L8444:  sta     $04D7,x                         ; 8444
        dex                                     ; 8447
        bpl     L8444                           ; 8448
        jsr     LA26D                           ; 844A
        jsr     LA7A5                           ; 844D
        lda     #$C8                            ; 8450
L8452:  inc     $04D1                           ; 8452
        jmp     LA670                           ; 8455

; ----------------------------------------------------------------------------
        ldx     #$04                            ; 8458
L845A:  txa                                     ; 845A
        sta     $04DF,x                         ; 845B
        dex                                     ; 845E
        bne     L845A                           ; 845F
        txa                                     ; 8461
        jsr     LA35C                           ; 8462
        jsr     LA7A5                           ; 8465
        lda     #$B2                            ; 8468
        jsr     LA8A0                           ; 846A
        cmp     #$FB                            ; 846D
        bne     L8474                           ; 846F
        jmp     LA6D0                           ; 8471

; ----------------------------------------------------------------------------
L8474:  tax                                     ; 8474
        inx                                     ; 8475
        cpx     $04DF                           ; 8476
        bne     L847E                           ; 8479
        lsr     $03FD                           ; 847B
L847E:  stx     $04DF                           ; 847E
        stx     $04                             ; 8481
        lda     #$00                            ; 8483
        ldx     #$03                            ; 8485
L8487:  sta     $04E0,x                         ; 8487
        dex                                     ; 848A
        bpl     L8487                           ; 848B
        lda     $1E                             ; 848D
        and     #$03                            ; 848F
        asl     a                               ; 8491
        and     #$07                            ; 8492
        tay                                     ; 8494
L8495:  lda     $04D7,y                         ; 8495
        cmp     $04                             ; 8498
        beq     L84A3                           ; 849A
        iny                                     ; 849C
        tya                                     ; 849D
        and     #$07                            ; 849E
        tay                                     ; 84A0
        bpl     L8495                           ; 84A1
L84A3:  tya                                     ; 84A3
        cpy     #$04                            ; 84A4
        bcc     L84AA                           ; 84A6
        adc     #$F7                            ; 84A8
L84AA:  adc     #$F8                            ; 84AA
        sec                                     ; 84AC
        sbc     $04E4                           ; 84AD
        sta     $00                             ; 84B0
        sta     $04E5                           ; 84B2
        ldx     $03FF                           ; 84B5
        beq     L84C8                           ; 84B8
        dex                                     ; 84BA
        stx     $03FF                           ; 84BB
        bne     L84F5                           ; 84BE
        lda     $03FE                           ; 84C0
        and     #$07                            ; 84C3
        sta     $03FE                           ; 84C5
L84C8:  ldx     $03FD                           ; 84C8
        cpx     #$02                            ; 84CB
        bcc     L84E1                           ; 84CD
        lda     #$09                            ; 84CF
        and     $04D5                           ; 84D1
        bne     L84E1                           ; 84D4
        lda     $89                             ; 84D6
        lsr     a                               ; 84D8
        bcs     L84F5                           ; 84D9
        lda     $8A                             ; 84DB
        and     #$08                            ; 84DD
        beq     L84F5                           ; 84DF
L84E1:  lda     $E3                             ; 84E1
        and     #$07                            ; 84E3
        lsr     a                               ; 84E5
        sta     $01                             ; 84E6
        lda     $00                             ; 84E8
        bcs     L84F0                           ; 84EA
        adc     $01                             ; 84EC
        bcc     L84F2                           ; 84EE
L84F0:  sbc     $01                             ; 84F0
L84F2:  sta     $04E5                           ; 84F2
L84F5:  inc     $1A                             ; 84F5
        inc     $04D1                           ; 84F7
L84FA:  rts                                     ; 84FA

; ----------------------------------------------------------------------------
        lda     #$4F                            ; 84FB
        jsr     LE992                           ; 84FD
        lda     #$25                            ; 8500
        jsr     LA670                           ; 8502
        lda     #$02                            ; 8505
        sta     $04E7                           ; 8507
        lda     $E6                             ; 850A
        clc                                     ; 850C
        and     #$01                            ; 850D
        adc     #$56                            ; 850F
        sta     $01                             ; 8511
        ldx     #$AE                            ; 8513
        stx     $03                             ; 8515
        jsr     LA4F5                           ; 8517
        jmp     LA6F1                           ; 851A

; ----------------------------------------------------------------------------
        clc                                     ; 851D
        lda     $02                             ; 851E
        adc     $03                             ; 8520
        sta     $02                             ; 8522
        bcc     L84FA                           ; 8524
        ldx     $04E5                           ; 8526
        beq     L854F                           ; 8529
        dex                                     ; 852B
        bne     L8532                           ; 852C
        lda     #$04                            ; 852E
        sta     $03                             ; 8530
L8532:  stx     $04E5                           ; 8532
        lda     $04E4                           ; 8535
        adc     #$00                            ; 8538
        and     #$07                            ; 853A
        sta     $04E4                           ; 853C
        cpx     $01                             ; 853F
        bcs     L8547                           ; 8541
        dec     $03                             ; 8543
        .byte   $C6                             ; 8545
L8546:  .byte   $03                             ; 8546
L8547:  lda     #$44                            ; 8547
        jsr     LE992                           ; 8549
        jmp     LA7FF                           ; 854C

; ----------------------------------------------------------------------------
L854F:  ldx     $04E4                           ; 854F
        lda     $04DF                           ; 8552
        ldy     #$07                            ; 8555
        cmp     $04D7,x                         ; 8557
        beq     L8561                           ; 855A
        ldx     #$06                            ; 855C
        iny                                     ; 855E
        lda     #$41                            ; 855F
L8561:  sty     $04D1                           ; 8561
        cmp     #$41                            ; 8564
        beq     L856C                           ; 8566
        ldx     #$0A                            ; 8568
        lda     #$40                            ; 856A
L856C:  stx     $2F                             ; 856C
        jmp     LE992                           ; 856E

; ----------------------------------------------------------------------------
        lda     $2F                             ; 8571
        cmp     #$05                            ; 8573
        bne     L857C                           ; 8575
        lda     #$42                            ; 8577
        jsr     LE992                           ; 8579
L857C:  lda     $2F                             ; 857C
        lsr     a                               ; 857E
        beq     L858A                           ; 857F
        lda     #$14                            ; 8581
        bcs     L8587                           ; 8583
        lda     #$13                            ; 8585
L8587:  jmp     LB3D3                           ; 8587

; ----------------------------------------------------------------------------
L858A:  inc     $1A                             ; 858A
        inc     $04E7                           ; 858C
        dec     $04D1                           ; 858F
        lda     #$80                            ; 8592
        sta     $04D4                           ; 8594
        lda     $04D6                           ; 8597
        asl     a                               ; 859A
        asl     a                               ; 859B
        adc     $04DF                           ; 859C
        tax                                     ; 859F
        lda     $A3CB,x                         ; 85A0
        tax                                     ; 85A3
        lda     $04D5                           ; 85A4
        sta     $00                             ; 85A7
        lda     #$00                            ; 85A9
        sta     $01                             ; 85AB
L85AD:  clc                                     ; 85AD
        adc     $00                             ; 85AE
        cmp     #$0A                            ; 85B0
        bcc     L85B8                           ; 85B2
        sbc     #$0A                            ; 85B4
        inc     $01                             ; 85B6
L85B8:  dex                                     ; 85B8
        bne     L85AD                           ; 85B9
        sta     $00                             ; 85BB
        lda     $01                             ; 85BD
        asl     a                               ; 85BF
        asl     a                               ; 85C0
        asl     a                               ; 85C1
        asl     a                               ; 85C2
        ora     $00                             ; 85C3
        sta     $04D2                           ; 85C5
        lda     #$0B                            ; 85C8
        sta     $04E8                           ; 85CA
        lda     #$00                            ; 85CD
        sta     $03FD                           ; 85CF
        rts                                     ; 85D2

; ----------------------------------------------------------------------------
        lda     $2F                             ; 85D3
        cmp     #$04                            ; 85D5
        bne     L85DE                           ; 85D7
        lda     #$43                            ; 85D9
        jsr     LE992                           ; 85DB
L85DE:  lda     $2F                             ; 85DE
        bne     L8633                           ; 85E0
        lda     $04D5                           ; 85E2
        sta     $04D2                           ; 85E5
        lda     #$0C                            ; 85E8
        sta     $04E8                           ; 85EA
        lda     $04D3                           ; 85ED
        bpl     L8604                           ; 85F0
        lda     $E4                             ; 85F2
        lsr     a                               ; 85F4
        bcs     L8604                           ; 85F5
        lsr     $04D2                           ; 85F7
        nop                                     ; 85FA
        nop                                     ; 85FB
        nop                                     ; 85FC
        nop                                     ; 85FD
        nop                                     ; 85FE
        lda     #$C1                            ; 85FF
        sta     $04E8                           ; 8601
L8604:  inc     $1A                             ; 8604
        lda     #$06                            ; 8606
        sta     $04D1                           ; 8608
        inc     $03FD                           ; 860B
        ldx     $03FE                           ; 860E
        lda     $04D2                           ; 8611
        cmp     #$04                            ; 8614
        bcc     L8623                           ; 8616
        inx                                     ; 8618
        cmp     #$06                            ; 8619
        bcc     L8623                           ; 861B
        inx                                     ; 861D
        cmp     #$08                            ; 861E
        bcc     L8623                           ; 8620
        inx                                     ; 8622
L8623:  stx     $03FE                           ; 8623
        cpx     #$16                            ; 8626
        bcc     L8633                           ; 8628
        lda     $1E                             ; 862A
        and     #$03                            ; 862C
        adc     #$02                            ; 862E
        sta     $03FF                           ; 8630
L8633:  rts                                     ; 8633

; ----------------------------------------------------------------------------
        lda     #$3D                            ; 8634
        jsr     LE992                           ; 8636
        lda     $04E8                           ; 8639
        jsr     LA670                           ; 863C
        lda     #$08                            ; 863F
        sta     $2F                             ; 8641
        jsr     LA709                           ; 8643
        ldx     #$02                            ; 8646
        lda     $04D4                           ; 8648
        bmi     L864E                           ; 864B
        inx                                     ; 864D
L864E:  stx     $04E7                           ; 864E
        jsr     LA814                           ; 8651
        lda     $04D2                           ; 8654
        clc                                     ; 8657
        ldx     $04D4                           ; 8658
        bmi     L865E                           ; 865B
        sec                                     ; 865D
L865E:  jsr     LA736                           ; 865E
        lda     #$00                            ; 8661
        sta     $04D4                           ; 8663
        sta     $04D1                           ; 8666
        sta     $04DF                           ; 8669
        sta     $04D2                           ; 866C
        rts                                     ; 866F

; ----------------------------------------------------------------------------
L8670:  sta     $06                             ; 8670
        jsr     LA6FE                           ; 8672
        jsr     LA6F1                           ; 8675
        lda     $06                             ; 8678
        and     #$1F                            ; 867A
        pha                                     ; 867C
        tay                                     ; 867D
        lda     $A6DB,y                         ; 867E
        sta     $04E7                           ; 8681
        jsr     LA814                           ; 8684
        pla                                     ; 8687
        asl     a                               ; 8688
        tay                                     ; 8689
        iny                                     ; 868A
        lda     #$A9                            ; 868B
        sta     $05                             ; 868D
        lda     #$84                            ; 868F
        sta     $04                             ; 8691
        jsr     LB143                           ; 8693
        stx     $18                             ; 8696
        jsr     LA6FE                           ; 8698
        lda     $06                             ; 869B
        beq     L86BF                           ; 869D
        bmi     L86A7                           ; 869F
        and     #$60                            ; 86A1
        lsr     a                               ; 86A3
        lsr     a                               ; 86A4
        sta     $2F                             ; 86A5
L86A7:  jsr     LA709                           ; 86A7
        bit     $06                             ; 86AA
        bpl     L86CD                           ; 86AC
        bvc     L86CD                           ; 86AE
        clc                                     ; 86B0
        lda     $06                             ; 86B1
        adc     #$0C                            ; 86B3
        and     #$9F                            ; 86B5
        cmp     #$80                            ; 86B7
        bne     L8670                           ; 86B9
        lda     #$30                            ; 86BB
        bne     L8670                           ; 86BD
L86BF:  lda     #$21                            ; 86BF
        jsr     LA8A0                           ; 86C1
        tax                                     ; 86C4
        bpl     L86CD                           ; 86C5
        cmp     #$FF                            ; 86C7
        bne     L86CE                           ; 86C9
        lda     #$01                            ; 86CB
L86CD:  rts                                     ; 86CD

; ----------------------------------------------------------------------------
L86CE:  pla                                     ; 86CE
        pla                                     ; 86CF
        ldx     #$01                            ; 86D0
        stx     $1A                             ; 86D2
        dex                                     ; 86D4
        stx     $04D0                           ; 86D5
        jmp     LA9C7                           ; 86D8

; ----------------------------------------------------------------------------
        brk                                     ; 86DB
        .byte   $04                             ; 86DC
        brk                                     ; 86DD
        brk                                     ; 86DE
        ora     $00                             ; 86DF
        ora     $05                             ; 86E1
        brk                                     ; 86E3
        ora     $01                             ; 86E4
        brk                                     ; 86E6
        .byte   $05                             ; 86E7
L86E8:  brk                                     ; 86E8
        ora     $00                             ; 86E9
        brk                                     ; 86EB
        brk                                     ; 86EC
        brk                                     ; 86ED
        brk                                     ; 86EE
        brk                                     ; 86EF
        brk                                     ; 86F0
        lda     #$15                            ; 86F1
        jsr     LB3D3                           ; 86F3
        jsr     LA6FE                           ; 86F6
        lda     #$18                            ; 86F9
        jsr     LB3D3                           ; 86FB
L86FE:  jsr     LE8EF                           ; 86FE
        jsr     LE95B                           ; 8701
        lda     $18                             ; 8704
        bne     L86FE                           ; 8706
        rts                                     ; 8708

; ----------------------------------------------------------------------------
        bit     $06                             ; 8709
        bpl     L8712                           ; 870B
L870D:  lda     #$16                            ; 870D
L870F:  jsr     LB3D3                           ; 870F
L8712:  jsr     LA6FE                           ; 8712
        sec                                     ; 8715
        lda     $06                             ; 8716
        bmi     L8720                           ; 8718
        lda     $2F                             ; 871A
        beq     L872F                           ; 871C
        bne     L8712                           ; 871E
L8720:  lda     $C2                             ; 8720
        lsr     a                               ; 8722
        bcs     L872F                           ; 8723
        lda     $1E                             ; 8725
        and     #$0F                            ; 8727
        beq     L870D                           ; 8729
        and     #$07                            ; 872B
        bne     L8712                           ; 872D
L872F:  lda     #$17                            ; 872F
        bcc     L870F                           ; 8731
        jmp     LB3D3                           ; 8733

; ----------------------------------------------------------------------------
        php                                     ; 8736
        pha                                     ; 8737
        and     #$0F                            ; 8738
        sta     $04                             ; 873A
        pla                                     ; 873C
        lsr     a                               ; 873D
        lsr     a                               ; 873E
        lsr     a                               ; 873F
        lsr     a                               ; 8740
        sta     $05                             ; 8741
        lda     #$00                            ; 8743
        sta     $06                             ; 8745
L8747:  lda     $1E                             ; 8747
        and     #$03                            ; 8749
        bne     L8752                           ; 874B
        lda     #$00                            ; 874D
        jsr     LE992                           ; 874F
L8752:  ldx     $06                             ; 8752
        bne     L8764                           ; 8754
        ldx     #$0A                            ; 8756
        dec     $04                             ; 8758
        bpl     L8764                           ; 875A
        lda     #$09                            ; 875C
        sta     $04                             ; 875E
L8760:  dec     $05                             ; 8760
        bmi     L8775                           ; 8762
L8764:  dex                                     ; 8764
        stx     $06                             ; 8765
        plp                                     ; 8767
        php                                     ; 8768
        bcs     L8772                           ; 8769
        jsr     LEBB8                           ; 876B
        bcs     L8760                           ; 876E
        bcc     L8775                           ; 8770
L8772:  jsr     LEBDD                           ; 8772
L8775:  ldx     #$02                            ; 8775
L8777:  lda     $04,x                           ; 8777
        pha                                     ; 8779
        dex                                     ; 877A
        bpl     L8777                           ; 877B
        jsr     LEAC1                           ; 877D
        jsr     LF0B5                           ; 8780
        ldx     #$00                            ; 8783
L8785:  pla                                     ; 8785
        sta     $04,x                           ; 8786
        inx                                     ; 8788
        cpx     #$03                            ; 8789
        bcc     L8785                           ; 878B
        lda     $05                             ; 878D
        bpl     L8747                           ; 878F
        plp                                     ; 8791
        rts                                     ; 8792

; ----------------------------------------------------------------------------
        lda     $04D2                           ; 8793
        beq     L879B                           ; 8796
        jsr     LA670                           ; 8798
L879B:  jsr     LA9D8                           ; 879B
        lda     #$40                            ; 879E
        sta     $1A                             ; 87A0
        rts                                     ; 87A2

; ----------------------------------------------------------------------------
        dec     $1A                             ; 87A3
        jsr     LEA7E                           ; 87A5
        jsr     LA7FF                           ; 87A8
        jsr     LA814                           ; 87AB
        ldy     #$00                            ; 87AE
        sty     $3D                             ; 87B0
        sty     $3C                             ; 87B2
        clc                                     ; 87B4
L87B5:  lda     $04D7,y                         ; 87B5
        beq     L87F4                           ; 87B8
        pha                                     ; 87BA
        php                                     ; 87BB
        lda     $3D                             ; 87BC
        asl     a                               ; 87BE
        asl     a                               ; 87BF
        tax                                     ; 87C0
        plp                                     ; 87C1
        lda     $A833,y                         ; 87C2
        sta     $0220,x                         ; 87C5
        bcs     L87CD                           ; 87C8
        sta     $0280,x                         ; 87CA
L87CD:  lda     $A85B,y                         ; 87CD
        sta     $0223,x                         ; 87D0
        bcs     L87DA                           ; 87D3
        adc     #$08                            ; 87D5
        sta     $0283,x                         ; 87D7
L87DA:  pla                                     ; 87DA
        tay                                     ; 87DB
        lda     $A883,y                         ; 87DC
        ror     a                               ; 87DF
        lsr     a                               ; 87E0
        sta     $0221,x                         ; 87E1
        sta     $0281,x                         ; 87E4
        lda     $A883,y                         ; 87E7
        and     #$03                            ; 87EA
        sta     $0222,x                         ; 87EC
        ora     #$40                            ; 87EF
        sta     $0282,x                         ; 87F1
L87F4:  inc     $3C                             ; 87F4
        ldy     $3C                             ; 87F6
L87F8:  inc     $3D                             ; 87F8
        cpy     #$0D                            ; 87FA
        bcc     L87B5                           ; 87FC
        rts                                     ; 87FE

; ----------------------------------------------------------------------------
        lda     #$0D                            ; 87FF
        sta     $3D                             ; 8801
        clc                                     ; 8803
        adc     $04E4                           ; 8804
        sta     $3C                             ; 8807
        tay                                     ; 8809
        sec                                     ; 880A
        lda     #$00                            ; 880B
        jsr     LA7BA                           ; 880D
        asl     $0221,x                         ; 8810
        rts                                     ; 8813

; ----------------------------------------------------------------------------
        ldy     $04E7                           ; 8814
        lda     $A82D,y                         ; 8817
        sta     $08                             ; 881A
        lda     #$78                            ; 881C
        sta     $3E                             ; 881E
        lda     #$90                            ; 8820
        sta     $3F                             ; 8822
        lsr     a                               ; 8824
        sta     $3C                             ; 8825
        ldy     #$32                            ; 8827
        sec                                     ; 8829
        jmp     LB1A5                           ; 882A

; ----------------------------------------------------------------------------
        sec                                     ; 882D
L882E:  and     $3C3A,y                         ; 882E
        and     $283E,x                         ; 8831
        .byte   $32                             ; 8834
        bvc     L88A5                           ; 8835
        sei                                     ; 8837
        ror     $3250                           ; 8838
        tya                                     ; 883B
        .byte   $22                             ; 883C
        .byte   $32                             ; 883D
        .byte   $42                             ; 883E
        .byte   $52                             ; 883F
        sec                                     ; 8840
        rti                                     ; 8841

; ----------------------------------------------------------------------------
        .byte   $54                             ; 8842
        pla                                     ; 8843
        bvs     L88AE                           ; 8844
        .byte   $54                             ; 8846
        rti                                     ; 8847

; ----------------------------------------------------------------------------
        pha                                     ; 8848
        pha                                     ; 8849
        pha                                     ; 884A
        eor     $5959,y                         ; 884B
        eor     $6A6A,y                         ; 884E
        ror     a                               ; 8851
        ror     a                               ; 8852
        bmi     L8885                           ; 8853
        bmi     L8887                           ; 8855
        bmi     L8889                           ; 8857
        bmi     L888B                           ; 8859
        rti                                     ; 885B

; ----------------------------------------------------------------------------
        eor     $5D68,x                         ; 885C
        rti                                     ; 885F

; ----------------------------------------------------------------------------
        .byte   $23                             ; 8860
        clc                                     ; 8861
        .byte   $23                             ; 8862
        jsr     L9090                           ; 8863
        bcc     L87F8                           ; 8866
        .byte   $44                             ; 8868
        cli                                     ; 8869
        rts                                     ; 886A

; ----------------------------------------------------------------------------
        cli                                     ; 886B
        .byte   $44                             ; 886C
        bmi     L8897                           ; 886D
        .byte   $32                             ; 886F
        and     ($32,x)                         ; 8870
        .byte   $43                             ; 8872
        bpl     L8896                           ; 8873
        .byte   $32                             ; 8875
        .byte   $43                             ; 8876
        bpl     L889A                           ; 8877
        .byte   $32                             ; 8879
        .byte   $43                             ; 887A
        bpl     L8895                           ; 887B
        jsr     L3028                           ; 887D
        sec                                     ; 8880
        rti                                     ; 8881

; ----------------------------------------------------------------------------
        pha                                     ; 8882
        lda     ($73),y                         ; 8883
L8885:  sec                                     ; 8885
        .byte   $30                             ; 8886
L8887:  .byte   $63                             ; 8887
        .byte   $61                             ; 8888
L8889:  eor     ($A9),y                         ; 8889
L888B:  eor     $7191,y                         ; 888B
        and     ($39),y                         ; 888E
        and     #$69                            ; 8890
        adc     $7F5F,y                         ; 8892
L8895:  rts                                     ; 8895

; ----------------------------------------------------------------------------
L8896:  .byte   $50                             ; 8896
L8897:  tay                                     ; 8897
        cli                                     ; 8898
        .byte   $90                             ; 8899
L889A:  bvs     L88CC                           ; 889A
        sec                                     ; 889C
        plp                                     ; 889D
        pla                                     ; 889E
        sei                                     ; 889F
        sta     $3D                             ; 88A0
        and     #$0F                            ; 88A2
        .byte   $85                             ; 88A4
L88A5:  .byte   $3C                             ; 88A5
        tay                                     ; 88A6
        lda     $3D                             ; 88A7
        and     #$30                            ; 88A9
        lsr     a                               ; 88AB
        lsr     a                               ; 88AC
        lsr     a                               ; 88AD
L88AE:  tax                                     ; 88AE
        lda     $A921,x                         ; 88AF
        sta     $3E                             ; 88B2
        lda     $A922,x                         ; 88B4
        sta     $3F                             ; 88B7
L88B9:  lda     ($3E),y                         ; 88B9
        sta     $04F0,y                         ; 88BB
        dey                                     ; 88BE
        bpl     L88B9                           ; 88BF
        iny                                     ; 88C1
        sty     $3B                             ; 88C2
L88C4:  lda     #$00                            ; 88C4
        sta     $3E                             ; 88C6
L88C8:  .byte   $20                             ; 88C8
L88C9:  eor     ($A9,x)                         ; 88C9
        .byte   $20                             ; 88CB
L88CC:  inc     $E6A6,x                         ; 88CC
        rol     $C2A5,x                         ; 88CF
        lsr     a                               ; 88D2
        bcc     L88DF                           ; 88D3
        lda     #$7D                            ; 88D5
        jsr     LE992                           ; 88D7
        ldy     $3B                             ; 88DA
        jmp     LA91A                           ; 88DC

; ----------------------------------------------------------------------------
L88DF:  .byte   $A4                             ; 88DF
L88E0:  .byte   $3B                             ; 88E0
        lsr     a                               ; 88E1
        bit     $3D                             ; 88E2
        bmi     L88EC                           ; 88E4
        bcc     L88EC                           ; 88E6
        ldy     #$FF                            ; 88E8
        bne     L891A                           ; 88EA
L88EC:  lsr     a                               ; 88EC
        bcc     L88F5                           ; 88ED
        bvs     L88F5                           ; 88EF
        ldy     #$FB                            ; 88F1
        .byte   $D0                             ; 88F3
L88F4:  .byte   $25                             ; 88F4
L88F5:  lsr     a                               ; 88F5
        lsr     a                               ; 88F6
        bcc     L8909                           ; 88F7
        jsr     LA94D                           ; 88F9
        dey                                     ; 88FC
        dec     $3B                             ; 88FD
        bpl     L88C4                           ; 88FF
        tya                                     ; 8901
L8902:  and     $3C                             ; 8902
        sta     $3B                             ; 8904
        tay                                     ; 8906
        bpl     L88C4                           ; 8907
L8909:  lsr     a                               ; 8909
        bcc     L88C8                           ; 890A
        jsr     LA94D                           ; 890C
        cpy     $3C                             ; 890F
        bcc     L8915                           ; 8911
        ldy     #$FF                            ; 8913
L8915:  iny                                     ; 8915
        sty     $3B                             ; 8916
        bpl     L88C4                           ; 8918
L891A:  tya                                     ; 891A
        pha                                     ; 891B
        jsr     LA6FE                           ; 891C
        pla                                     ; 891F
        rts                                     ; 8920

; ----------------------------------------------------------------------------
        and     #$A9                            ; 8921
        and     $38A9                           ; 8923
        lda     #$3A                            ; 8926
        lda     #$21                            ; 8928
        and     ($22,x)                         ; 892A
        .byte   $22                             ; 892C
        bcs     L88E0                           ; 892D
        dex                                     ; 892F
        lda     $CB,x                           ; 8930
        tsx                                     ; 8932
        cpy     $CECD                           ; 8933
        .byte   $CF                             ; 8936
        bne     L88F4                           ; 8937
        .byte   $BF                             ; 8939
        .byte   $B2                             ; 893A
        ldx     $BB,y                           ; 893B
        ldx     $2EEE                           ; 893D
        ror     $28A2                           ; 8940
        lda     $3E                             ; 8943
        and     #$0F                            ; 8945
        beq     L894F                           ; 8947
        and     #$07                            ; 8949
        bne     L8972                           ; 894B
        ldx     #$2C                            ; 894D
L894F:  txa                                     ; 894F
        ldx     $0162                           ; 8950
        pha                                     ; 8953
        lda     $04F0,y                         ; 8954
        sta     $0163,x                         ; 8957
        bmi     L8963                           ; 895A
        lda     $A93D,y                         ; 895C
        inx                                     ; 895F
        sta     $0163,x                         ; 8960
L8963:  inx                                     ; 8963
        lda     #$01                            ; 8964
        sta     $0163,x                         ; 8966
        inx                                     ; 8969
        pla                                     ; 896A
        sta     $0163,x                         ; 896B
        inx                                     ; 896E
        jsr     LB3EF                           ; 896F
L8972:  rts                                     ; 8972

; ----------------------------------------------------------------------------
        .byte   $04                             ; 8973
        .byte   $02                             ; 8974
        ora     ($01,x)                         ; 8975
        .byte   $03                             ; 8977
        .byte   $03                             ; 8978
        ora     ($01,x)                         ; 8979
        .byte   $03                             ; 897B
        .byte   $02                             ; 897C
        .byte   $02                             ; 897D
        ora     ($05,x)                         ; 897E
        ora     ($01,x)                         ; 8980
        ora     ($01,x)                         ; 8982
        adc     $B9                             ; 8984
        ror     $B9,x                           ; 8986
        stx     $B9,y                           ; 8988
        lda     $CEB9,x                         ; 898A
        lda     $B9F4,y                         ; 898D
        .byte   $FC                             ; 8990
        lda     $BA14,y                         ; 8991
        .byte   $34                             ; 8994
        tsx                                     ; 8995
        .byte   $54                             ; 8996
        tsx                                     ; 8997
        adc     ($BA,x)                         ; 8998
        .byte   $74                             ; 899A
        tsx                                     ; 899B
        .byte   $7F                             ; 899C
        tsx                                     ; 899D
        stx     $ABBA                           ; 899E
L89A1:  tsx                                     ; 89A1
        .byte   $AB                             ; 89A2
L89A3:  tsx                                     ; 89A3
        cmp     $64BA                           ; 89A4
        ora     ($FB,x)                         ; 89A7
        tsx                                     ; 89A9
        .byte   $0C                             ; 89AA
        .byte   $BB                             ; 89AB
        jsr     LB2BB                           ; 89AC
        lda     #$E3                            ; 89AF
        tsx                                     ; 89B1
        .byte   $B3                             ; 89B2
        .byte   $03                             ; 89B3
        bit     a:$CB                           ; 89B4
        .byte   $B7                             ; 89B7
        .byte   $03                             ; 89B8
        bit     $01CB                           ; 89B9
        lda     $2C03,x                         ; 89BC
        .byte   $CB                             ; 89BF
        .byte   $02                             ; 89C0
        cmp     ($03,x)                         ; 89C1
        bit     $03CB                           ; 89C3
        .byte   $FF                             ; 89C6
        .byte   $20                             ; 89C7
        cld                                     ; 89C8
L89C9:  .byte   $A9                             ; 89C9
L89CA:  jsr     LE95B                           ; 89CA
        jsr     LA9EF                           ; 89CD
        bit     $04C0                           ; 89D0
        bvc     L89CA                           ; 89D3
        jmp     LE95B                           ; 89D5

; ----------------------------------------------------------------------------
        ldx     #$00                            ; 89D8
        stx     $04C0                           ; 89DA
        stx     $04C1                           ; 89DD
        stx     $12                             ; 89E0
        inx                                     ; 89E2
        stx     $18                             ; 89E3
        lda     $11                             ; 89E5
        and     #$E7                            ; 89E7
        sta     $11                             ; 89E9
        sta     PPU_MASK                        ; 89EB
        rts                                     ; 89EE

; ----------------------------------------------------------------------------
        lda     $04C0                           ; 89EF
        and     #$3F                            ; 89F2
        jsr     LAA00                           ; 89F4
        bit     $04C0                           ; 89F7
        bpl     L89FF                           ; 89FA
        jsr     LE8EF                           ; 89FC
L89FF:  rts                                     ; 89FF

; ----------------------------------------------------------------------------
        jsr     LE97D                           ; 8A00
        ora     ($AA),y                         ; 8A03
        jsr     L38AA                           ; 8A05
        tax                                     ; 8A08
        .byte   $9B                             ; 8A09
        tax                                     ; 8A0A
        .byte   $F4                             ; 8A0B
        tax                                     ; 8A0C
        .byte   $42                             ; 8A0D
        ldy     $AD6B                           ; 8A0E
        lda     #$03                            ; 8A11
        jsr     LE8C8                           ; 8A13
        lda     #$00                            ; 8A16
        sta     $00                             ; 8A18
        inc     $04C0                           ; 8A1A
        jmp     LEA7E                           ; 8A1D

; ----------------------------------------------------------------------------
        lda     $00                             ; 8A20
        bne     L8A29                           ; 8A22
        lda     #$81                            ; 8A24
        jsr     LE9EB                           ; 8A26
L8A29:  lda     $00                             ; 8A29
        cmp     #$04                            ; 8A2B
        bcc     L8A32                           ; 8A2D
L8A2F:  inc     $04C0                           ; 8A2F
L8A32:  jsr     LB3D3                           ; 8A32
        inc     $00                             ; 8A35
        rts                                     ; 8A37

; ----------------------------------------------------------------------------
        lda     #$02                            ; 8A38
        sta     $18                             ; 8A3A
        lda     #$11                            ; 8A3C
        jsr     LB707                           ; 8A3E
        jsr     LE95B                           ; 8A41
        jsr     LF09B                           ; 8A44
        lda     #$83                            ; 8A47
        sta     $04C0                           ; 8A49
        ldx     #$00                            ; 8A4C
        stx     $3B                             ; 8A4E
        stx     $3D                             ; 8A50
        ldy     #$15                            ; 8A52
        sty     $3C                             ; 8A54
L8A56:  lda     $0335,x                         ; 8A56
        beq     L8A6D                           ; 8A59
        txa                                     ; 8A5B
        asl     a                               ; 8A5C
        tax                                     ; 8A5D
        lda     $03C0,x                         ; 8A5E
        beq     L8A65                           ; 8A61
        lda     #$0D                            ; 8A63
L8A65:  clc                                     ; 8A65
        adc     $3B                             ; 8A66
        adc     #$05                            ; 8A68
        jsr     LA7BA                           ; 8A6A
L8A6D:  inc     $3B                             ; 8A6D
        ldx     $3B                             ; 8A6F
        cpx     #$0B                            ; 8A71
        bcc     L8A56                           ; 8A73
        ldx     $82                             ; 8A75
        beq     L8A9A                           ; 8A77
        cpx     #$05                            ; 8A79
        bcc     L8A7E                           ; 8A7B
        dex                                     ; 8A7D
L8A7E:  stx     $3B                             ; 8A7E
        ldy     #$20                            ; 8A80
        sty     $3C                             ; 8A82
L8A84:  lda     #$10                            ; 8A84
        sec                                     ; 8A86
        jsr     LA7BA                           ; 8A87
        asl     $0221,x                         ; 8A8A
        lda     #$11                            ; 8A8D
        sec                                     ; 8A8F
        jsr     LA7BA                           ; 8A90
        asl     $0221,x                         ; 8A93
        dec     $3B                             ; 8A96
        bne     L8A84                           ; 8A98
L8A9A:  rts                                     ; 8A9A

; ----------------------------------------------------------------------------
        lda     #$00                            ; 8A9B
        sta     $06                             ; 8A9D
        sta     $0F                             ; 8A9F
        sta     $0C                             ; 8AA1
        inc     $04C0                           ; 8AA3
        tay                                     ; 8AA6
        lda     $030D                           ; 8AA7
        beq     L8AC9                           ; 8AAA
        lda     $B0                             ; 8AAC
        and     #$0F                            ; 8AAE
        beq     L8AC9                           ; 8AB0
        ldy     #$00                            ; 8AB2
L8AB4:  iny                                     ; 8AB4
        cmp     $AAE7,y                         ; 8AB5
        bne     L8AB4                           ; 8AB8
        tya                                     ; 8ABA
        asl     a                               ; 8ABB
        tay                                     ; 8ABC
        lda     $ADBF,y                         ; 8ABD
        sta     $0A                             ; 8AC0
        lda     $ADC0,y                         ; 8AC2
        sta     $0B                             ; 8AC5
        tya                                     ; 8AC7
        lsr     a                               ; 8AC8
L8AC9:  sta     $0D                             ; 8AC9
        asl     a                               ; 8ACB
        tay                                     ; 8ACC
        lda     $ADD9,y                         ; 8ACD
        sta     $02                             ; 8AD0
        lda     $ADDA,y                         ; 8AD2
        sta     $03                             ; 8AD5
        tya                                     ; 8AD7
        asl     a                               ; 8AD8
        asl     a                               ; 8AD9
        sta     $00                             ; 8ADA
        lda     #$22                            ; 8ADC
        sta     $08                             ; 8ADE
        lda     #$02                            ; 8AE0
        sta     $09                             ; 8AE2
        lsr     a                               ; 8AE4
        sta     $04                             ; 8AE5
        rts                                     ; 8AE7

; ----------------------------------------------------------------------------
        ora     ($03,x)                         ; 8AE8
        .byte   $04                             ; 8AEA
        ora     $07                             ; 8AEB
        php                                     ; 8AED
        ora     #$0A                            ; 8AEE
        .byte   $0C                             ; 8AF0
        ora     $0F0E                           ; 8AF1
        ldx     #$00                            ; 8AF4
        ldy     $00                             ; 8AF6
        inc     $00                             ; 8AF8
        lda     $ADF3,y                         ; 8AFA
        sta     $01                             ; 8AFD
        lda     #$08                            ; 8AFF
        sta     $05                             ; 8B01
        jsr     LAB65                           ; 8B03
L8B06:  asl     $01                             ; 8B06
        .byte   $B0                             ; 8B08
L8B09:  .byte   $04                             ; 8B09
        lda     #$2C                            ; 8B0A
        bne     L8B3B                           ; 8B0C
L8B0E:  ldy     $06                             ; 8B0E
        lda     ($02),y                         ; 8B10
        dec     $04                             ; 8B12
        bne     L8B1A                           ; 8B14
        inc     $04                             ; 8B16
        inc     $06                             ; 8B18
L8B1A:  cmp     #$2C                            ; 8B1A
        bcs     L8B22                           ; 8B1C
        sta     $04                             ; 8B1E
        bcc     L8B0E                           ; 8B20
L8B22:  pha                                     ; 8B22
        lda     $0D                             ; 8B23
        beq     L8B3A                           ; 8B25
        ldy     $0C                             ; 8B27
        lda     ($0A),y                         ; 8B29
        iny                                     ; 8B2B
        .byte   $84                             ; 8B2C
L8B2D:  .byte   $0C                             ; 8B2D
        cmp     $AB                             ; 8B2E
        bne     L8B3A                           ; 8B30
        pla                                     ; 8B32
        pha                                     ; 8B33
        .byte   $85                             ; 8B34
L8B35:  .byte   $0F                             ; 8B35
        lda     $09                             ; 8B36
        sta     $0E                             ; 8B38
L8B3A:  pla                                     ; 8B3A
L8B3B:  sta     $0163,x                         ; 8B3B
        inx                                     ; 8B3E
        inc     $09                             ; 8B3F
        dec     $05                             ; 8B41
        bne     L8B06                           ; 8B43
        jsr     LB3EF                           ; 8B45
        lda     $09                             ; 8B48
        clc                                     ; 8B4A
        adc     #$18                            ; 8B4B
        sta     $09                             ; 8B4D
        lda     $08                             ; 8B4F
        adc     #$00                            ; 8B51
        sta     $08                             ; 8B53
        cmp     #$23                            ; 8B55
        bcc     L8B64                           ; 8B57
        inc     $04C0                           ; 8B59
        lda     #$20                            ; 8B5C
        sta     $08                             ; 8B5E
        lda     #$AA                            ; 8B60
        sta     $09                             ; 8B62
L8B64:  rts                                     ; 8B64

; ----------------------------------------------------------------------------
        sta     $0165,x                         ; 8B65
        lda     $08                             ; 8B68
        sta     $0163,x                         ; 8B6A
        inx                                     ; 8B6D
        lda     $09                             ; 8B6E
        sta     $0163,x                         ; 8B70
        inx                                     ; 8B73
        inx                                     ; 8B74
        rts                                     ; 8B75

; ----------------------------------------------------------------------------
        .byte   $1F                             ; 8B76
        bmi     L8BAA                           ; 8B77
        .byte   $32                             ; 8B79
        rti                                     ; 8B7A

; ----------------------------------------------------------------------------
        bvc     L8BCE                           ; 8B7B
        .byte   $52                             ; 8B7D
        .byte   $53                             ; 8B7E
        .byte   $54                             ; 8B7F
        eor     $60,x                           ; 8B80
        ror     $77,x                           ; 8B82
        adc     $7E7A,x                         ; 8B84
        bvs     L8B09                           ; 8B87
        sta     ($82,x)                         ; 8B89
        .byte   $83                             ; 8B8B
        sty     $58                             ; 8B8C
        .byte   $73                             ; 8B8E
        .byte   $77                             ; 8B8F
        brk                                     ; 8B90
        brk                                     ; 8B91
        sty     $D1A7                           ; 8B92
        ldx     $8E                             ; 8B95
        lda     $D8                             ; 8B97
        tay                                     ; 8B99
        .byte   $CF                             ; 8B9A
        txa                                     ; 8B9B
        bcc     L8B35                           ; 8B9C
        sta     L8902,y                         ; 8B9E
        .byte   $07                             ; 8BA1
        .byte   $02                             ; 8BA2
        php                                     ; 8BA3
        .byte   $92                             ; 8BA4
        .byte   $02                             ; 8BA5
        .byte   $93                             ; 8BA6
        .byte   $EB                             ; 8BA7
        sty     $E4,x                           ; 8BA8
L8BAA:  sta     $E0,x                           ; 8BAA
        stx     $82,y                           ; 8BAC
        ora     ($83,x)                         ; 8BAE
        .byte   $03                             ; 8BB0
        sta     ($05,x)                         ; 8BB1
        ora     ($06,x)                         ; 8BB3
        .byte   $04                             ; 8BB5
        .byte   $02                             ; 8BB6
        .byte   $03                             ; 8BB7
        .byte   $04                             ; 8BB8
        ora     $0E                             ; 8BB9
        .byte   $0F                             ; 8BBB
        bpl     L8BCF                           ; 8BBC
        .byte   $12                             ; 8BBE
        .byte   $13                             ; 8BBF
        .byte   $14                             ; 8BC0
        .byte   $22                             ; 8BC1
        and     #$2B                            ; 8BC2
        bmi     L8BF3                           ; 8BC4
        and     ($23),y                         ; 8BC6
        cpx     #$E1                            ; 8BC8
        .byte   $E2                             ; 8BCA
        .byte   $E3                             ; 8BCB
        cpx     $0D                             ; 8BCC
L8BCE:  .byte   $26                             ; 8BCE
L8BCF:  rol     a                               ; 8BCF
        .byte   $E2                             ; 8BD0
        .byte   $AB                             ; 8BD1
        sbc     $F8AB                           ; 8BD2
        .byte   $AB                             ; 8BD5
        .byte   $03                             ; 8BD6
        ldy     $AC0E                           ; 8BD7
        ora     $24AC,y                         ; 8BDA
        ldy     $AC2D                           ; 8BDD
        sec                                     ; 8BE0
        ldy     L8C8E                           ; 8BE1
        sty     L8C8C                           ; 8BE4
        sty     L8C8C                           ; 8BE7
        sty     $079E                           ; 8BEA
        sta     $2C2C                           ; 8BED
        bit     $2C2C                           ; 8BF0
L8BF3:  bit     $2C2C                           ; 8BF3
        sta     L8D07                           ; 8BF6
        sty     L8C8C                           ; 8BF9
        sty     L8C8C                           ; 8BFC
        sty     L8D8C                           ; 8BFF
        .byte   $07                             ; 8C02
        .byte   $8F                             ; 8C03
        sty     $3C8C                           ; 8C04
        bmi     L8C3F                           ; 8C07
        sec                                     ; 8C09
        .byte   $32                             ; 8C0A
        sty     $079F                           ; 8C0B
        .byte   $8F                             ; 8C0E
        sty     $388C                           ; 8C0F
        .byte   $43                             ; 8C12
        .byte   $34                             ; 8C13
        .byte   $3C                             ; 8C14
        sty     L9F8C                           ; 8C15
        .byte   $07                             ; 8C18
        bit     a:$E7                           ; 8C19
        bit     $462C                           ; 8C1C
        ora     ($2C,x)                         ; 8C1F
        bit     $072C                           ; 8C21
        bit     $3433                           ; 8C24
        and     ($43),y                         ; 8C27
        bit     $2C02                           ; 8C29
L8C2C:  .byte   $07                             ; 8C2C
        sta     $4143                           ; 8C2D
        rol     $3F3E,x                         ; 8C30
        .byte   $34                             ; 8C33
        eor     ($2C,x)                         ; 8C34
        sta     L8D07                           ; 8C36
        bit     $2C2C                           ; 8C39
        bit     $2C2C                           ; 8C3C
L8C3F:  .byte   $03                             ; 8C3F
        sta     $A207                           ; 8C40
        brk                                     ; 8C43
        stx     $3E                             ; 8C44
        lda     #$14                            ; 8C46
        jsr     LAB65                           ; 8C48
        ldy     $04C1                           ; 8C4B
        lda     $AB90,y                         ; 8C4E
        inc     $04C1                           ; 8C51
        jsr     LAC81                           ; 8C54
        ldy     $04C1                           ; 8C57
        lda     $AB90,y                         ; 8C5A
        inc     $04C1                           ; 8C5D
        jsr     LAC81                           ; 8C60
        jsr     LB3EF                           ; 8C63
        clc                                     ; 8C66
        lda     $09                             ; 8C67
        adc     #$20                            ; 8C69
        sta     $09                             ; 8C6B
        lda     $08                             ; 8C6D
        adc     #$00                            ; 8C6F
        sta     $08                             ; 8C71
        cmp     #$23                            ; 8C73
        bne     L8C80                           ; 8C75
        inc     $04C0                           ; 8C77
        dec     $08                             ; 8C7A
        lda     $0E                             ; 8C7C
        sta     $09                             ; 8C7E
L8C80:  rts                                     ; 8C80

; ----------------------------------------------------------------------------
        pha                                     ; 8C81
        tay                                     ; 8C82
        bpl     L8C87                           ; 8C83
        lda     #$01                            ; 8C85
L8C87:  jsr     LAD00                           ; 8C87
        pla                                     ; 8C8A
        tay                                     ; 8C8B
L8C8C:  bmi     L8C8F                           ; 8C8C
L8C8E:  rts                                     ; 8C8E

; ----------------------------------------------------------------------------
L8C8F:  txa                                     ; 8C8F
        pha                                     ; 8C90
        sec                                     ; 8C91
        sbc     #$09                            ; 8C92
        sta     $0D                             ; 8C94
        tya                                     ; 8C96
        asl     a                               ; 8C97
        sta     $01                             ; 8C98
        tya                                     ; 8C9A
        and     #$1F                            ; 8C9B
        tay                                     ; 8C9D
        lda     $ABB6,y                         ; 8C9E
        sta     $0B                             ; 8CA1
        lda     #$03                            ; 8CA3
        sta     $0C                             ; 8CA5
        lda     $AB76,y                         ; 8CA7
        sta     $02                             ; 8CAA
        ldy     #$00                            ; 8CAC
        lda     ($0B),y                         ; 8CAE
        beq     L8CFD                           ; 8CB0
        bit     $01                             ; 8CB2
        bpl     L8CCE                           ; 8CB4
        bvs     L8CC9                           ; 8CB6
        ldy     #$01                            ; 8CB8
        lda     $01                             ; 8CBA
        cmp     #$9E                            ; 8CBC
        bcc     L8CC1                           ; 8CBE
        iny                                     ; 8CC0
L8CC1:  lda     ($0B),y                         ; 8CC1
        bne     L8CC8                           ; 8CC3
        dey                                     ; 8CC5
        bne     L8CC1                           ; 8CC6
L8CC8:  tya                                     ; 8CC8
L8CC9:  clc                                     ; 8CC9
        adc     $02                             ; 8CCA
        sta     $02                             ; 8CCC
L8CCE:  lda     $01                             ; 8CCE
        pha                                     ; 8CD0
        lda     $0B                             ; 8CD1
        pha                                     ; 8CD3
        lda     $02                             ; 8CD4
        ldx     $0D                             ; 8CD6
        jsr     LE052                           ; 8CD8
        pla                                     ; 8CDB
        sta     $0B                             ; 8CDC
        pla                                     ; 8CDE
        and     #$C0                            ; 8CDF
        cmp     #$40                            ; 8CE1
        bne     L8CFD                           ; 8CE3
        lda     #$03                            ; 8CE5
        sta     $0C                             ; 8CE7
        ldy     #$00                            ; 8CE9
        lda     ($0B),y                         ; 8CEB
        cmp     #$0A                            ; 8CED
        bcc     L8CFA                           ; 8CEF
        sbc     #$0A                            ; 8CF1
        pha                                     ; 8CF3
        lda     #$01                            ; 8CF4
        sta     $0161,x                         ; 8CF6
        pla                                     ; 8CF9
L8CFA:  sta     $0162,x                         ; 8CFA
L8CFD:  pla                                     ; 8CFD
        tax                                     ; 8CFE
        rts                                     ; 8CFF

; ----------------------------------------------------------------------------
        asl     a                               ; 8D00
        tay                                     ; 8D01
        lda     $ABD0,y                         ; 8D02
        sta     $0B                             ; 8D05
L8D07:  lda     $ABD1,y                         ; 8D07
        sta     $0C                             ; 8D0A
        ldy     #$00                            ; 8D0C
L8D0E:  lda     ($0B),y                         ; 8D0E
        iny                                     ; 8D10
        cmp     #$07                            ; 8D11
        beq     L8D1D                           ; 8D13
        bcc     L8D1E                           ; 8D15
        sta     $0163,x                         ; 8D17
        inx                                     ; 8D1A
        bpl     L8D0E                           ; 8D1B
L8D1D:  rts                                     ; 8D1D

; ----------------------------------------------------------------------------
L8D1E:  sty     $3D                             ; 8D1E
        dey                                     ; 8D20
        asl     a                               ; 8D21
        adc     ($0B),y                         ; 8D22
        tay                                     ; 8D24
        lda     $AD5F,y                         ; 8D25
        sta     $3E                             ; 8D28
        .byte   $B9                             ; 8D2A
        rts                                     ; 8D2B

; ----------------------------------------------------------------------------
L8D2C:  lda     $3F85                           ; 8D2C
        lda     $AD61,y                         ; 8D2F
        sta     $3C                             ; 8D32
        ldy     #$00                            ; 8D34
        and     #$03                            ; 8D36
        sta     $3B                             ; 8D38
        bne     L8D4A                           ; 8D3A
        lda     ($3E),y                         ; 8D3C
        tay                                     ; 8D3E
        bit     $3C                             ; 8D3F
        bpl     L8D44                           ; 8D41
        dey                                     ; 8D43
L8D44:  bvc     L8D47                           ; 8D44
        iny                                     ; 8D46
L8D47:  tya                                     ; 8D47
        bpl     L8D4C                           ; 8D48
L8D4A:  lda     ($3E),y                         ; 8D4A
L8D4C:  sta     $0163,x                         ; 8D4C
        inx                                     ; 8D4F
        iny                                     ; 8D50
        cpy     $3B                             ; 8D51
        bcc     L8D4A                           ; 8D53
        ldy     $3D                             ; 8D55
        bcs     L8D0E                           ; 8D57
        bit     $2C2C                           ; 8D59
        bit     $4069                           ; 8D5C
        .byte   $80                             ; 8D5F
        brk                                     ; 8D60
        .byte   $80                             ; 8D61
        .byte   $82                             ; 8D62
        brk                                     ; 8D63
        rti                                     ; 8D64

; ----------------------------------------------------------------------------
        cmp     $0303,y                         ; 8D65
        dec     $03,x                           ; 8D68
        .byte   $02                             ; 8D6A
        ldx     #$00                            ; 8D6B
        ldy     $0F                             ; 8D6D
        beq     L8D8A                           ; 8D6F
        lda     $1E                             ; 8D71
        and     #$1F                            ; 8D73
        beq     L8D7D                           ; 8D75
        and     #$0F                            ; 8D77
        bne     L8D8A                           ; 8D79
        ldy     #$2C                            ; 8D7B
L8D7D:  tya                                     ; 8D7D
        sta     $0166,x                         ; 8D7E
        lda     #$01                            ; 8D81
        jsr     LAB65                           ; 8D83
        inx                                     ; 8D86
        jsr     LB3EF                           ; 8D87
L8D8A:  lda     $C2                             ; 8D8A
L8D8C:  and     #$04                            ; 8D8C
        beq     L8D9B                           ; 8D8E
        jsr     LA9E5                           ; 8D90
        lda     #$40                            ; 8D93
        sta     $04C0                           ; 8D95
        jsr     LEA7E                           ; 8D98
L8D9B:  rts                                     ; 8D9B

; ----------------------------------------------------------------------------
        .byte   $23                             ; 8D9C
        cpy     #$58                            ; 8D9D
        eor     $00,x                           ; 8D9F
        .byte   $23                             ; 8DA1
        cld                                     ; 8DA2
        cli                                     ; 8DA3
        eor     $00,x                           ; 8DA4
        .byte   $23                             ; 8DA6
        cpx     #$03                            ; 8DA7
        .byte   $FF                             ; 8DA9
        .byte   $FF                             ; 8DAA
        .byte   $77                             ; 8DAB
        brk                                     ; 8DAC
        .byte   $23                             ; 8DAD
        inx                                     ; 8DAE
        .byte   $03                             ; 8DAF
        .byte   $FF                             ; 8DB0
        .byte   $FF                             ; 8DB1
        .byte   $77                             ; 8DB2
        brk                                     ; 8DB3
        and     ($22,x)                         ; 8DB4
        .byte   $02                             ; 8DB6
        .byte   $80                             ; 8DB7
        bcc     L8DDB                           ; 8DB8
        .byte   $42                             ; 8DBA
        .byte   $02                             ; 8DBB
        sta     ($91,x)                         ; 8DBC
        brk                                     ; 8DBE
        cmp     #$AE                            ; 8DBF
        cmp     #$AE                            ; 8DC1
        dec     $E4AE,x                         ; 8DC3
        ldx     $AEF7                           ; 8DC6
        .byte   $03                             ; 8DC9
        .byte   $AF                             ; 8DCA
        .byte   $1C                             ; 8DCB
        .byte   $AF                             ; 8DCC
        .byte   $2B                             ; 8DCD
        .byte   $AF                             ; 8DCE
        .byte   $4F                             ; 8DCF
        .byte   $AF                             ; 8DD0
        lsr     $AF,x                           ; 8DD1
        .byte   $7C                             ; 8DD3
        .byte   $AF                             ; 8DD4
        .byte   $93                             ; 8DD5
        .byte   $AF                             ; 8DD6
        txs                                     ; 8DD7
        .byte   $AF                             ; 8DD8
        .byte   $5B                             ; 8DD9
        .byte   $AE                             ; 8DDA
L8DDB:  adc     $72AE                           ; 8DDB
        ldx     $AE76                           ; 8DDE
        .byte   $7B                             ; 8DE1
        ldx     $AE80                           ; 8DE2
        sta     ($AE),y                         ; 8DE5
        .byte   $97                             ; 8DE7
        ldx     $AEAF                           ; 8DE8
        .byte   $B2                             ; 8DEB
        ldx     $AEB4                           ; 8DEC
        cpy     $AE                             ; 8DEF
        .byte   $C7                             ; 8DF1
        ldx     L81FF                           ; 8DF2
        sta     $BD81,y                         ; 8DF5
        lda     $FF81,x                         ; 8DF8
        bvs     L8E6F                           ; 8DFB
        ror     $061E,x                         ; 8DFD
        asl     $00                             ; 8E00
        brk                                     ; 8E02
        brk                                     ; 8E03
        brk                                     ; 8E04
        brk                                     ; 8E05
        brk                                     ; 8E06
        brk                                     ; 8E07
        asl     $06                             ; 8E08
        asl     $3C                             ; 8E0A
        asl     $0F1F,x                         ; 8E0C
        .byte   $0C                             ; 8E0F
        brk                                     ; 8E10
        brk                                     ; 8E11
        brk                                     ; 8E12
        sec                                     ; 8E13
        sei                                     ; 8E14
        sec                                     ; 8E15
        clc                                     ; 8E16
        brk                                     ; 8E17
        brk                                     ; 8E18
        brk                                     ; 8E19
        brk                                     ; 8E1A
        brk                                     ; 8E1B
        brk                                     ; 8E1C
        brk                                     ; 8E1D
        cpx     #$E0                            ; 8E1E
        .byte   $F7                             ; 8E20
        .byte   $77                             ; 8E21
        .byte   $77                             ; 8E22
        .byte   $1C                             ; 8E23
        asl     $707C,x                         ; 8E24
        brk                                     ; 8E27
        brk                                     ; 8E28
        brk                                     ; 8E29
        brk                                     ; 8E2A
        .byte   $0D                             ; 8E2B
L8E2C:  .byte   $0F                             ; 8E2C
        .byte   $0F                             ; 8E2D
        .byte   $EF                             ; 8E2E
        cpx     #$EE                            ; 8E2F
        dec     $048E                           ; 8E31
        .byte   $04                             ; 8E34
        .byte   $0C                             ; 8E35
        .byte   $0C                             ; 8E36
        .byte   $04                             ; 8E37
        brk                                     ; 8E38
        brk                                     ; 8E39
        brk                                     ; 8E3A
        .byte   $3C                             ; 8E3B
        .byte   $3C                             ; 8E3C
        ror     $3E3E,x                         ; 8E3D
        ror     $3C3C,x                         ; 8E40
        brk                                     ; 8E43
        bmi     L8E76                           ; 8E44
        brk                                     ; 8E46
        bit     $7C7E                           ; 8E47
        .byte   $7C                             ; 8E4A
        .byte   $04                             ; 8E4B
        .byte   $04                             ; 8E4C
        .byte   $0C                             ; 8E4D
        .byte   $0C                             ; 8E4E
        .byte   $04                             ; 8E4F
        brk                                     ; 8E50
        brk                                     ; 8E51
        brk                                     ; 8E52
        brk                                     ; 8E53
        brk                                     ; 8E54
        brk                                     ; 8E55
        rts                                     ; 8E56

; ----------------------------------------------------------------------------
L8E57:  beq     L8E57                           ; 8E57
        inc     $0BFE,x                         ; 8E59
        .byte   $FB                             ; 8E5C
        nop                                     ; 8E5D
        .byte   $EB                             ; 8E5E
        .byte   $04                             ; 8E5F
        .byte   $FB                             ; 8E60
        cpy     $ECDC                           ; 8E61
        .byte   $FC                             ; 8E64
        .byte   $FB                             ; 8E65
        .byte   $FB                             ; 8E66
        cmp     $EDDD                           ; 8E67
        sbc     $FB00,x                         ; 8E6A
        asl     $F2                             ; 8E6D
L8E6F:  .byte   $E3                             ; 8E6F
        asl     $F2F2                           ; 8E70
        beq     L8E79                           ; 8E73
        .byte   $F2                             ; 8E75
L8E76:  .byte   $03                             ; 8E76
        sbc     $E3,x                           ; 8E77
L8E79:  .byte   $0F                             ; 8E79
        sbc     $04,x                           ; 8E7A
        sbc     $F3,x                           ; 8E7C
        .byte   $07                             ; 8E7E
        sbc     $E2,x                           ; 8E7F
        .byte   $E2                             ; 8E81
L8E82:  cpx     #$07                            ; 8E82
        .byte   $E2                             ; 8E84
        .byte   $03                             ; 8E85
        .byte   $F2                             ; 8E86
        .byte   $03                             ; 8E87
        .byte   $E2                             ; 8E88
        .byte   $F2                             ; 8E89
L8E8A:  .byte   $E3                             ; 8E8A
        .byte   $F2                             ; 8E8B
        .byte   $03                             ; 8E8C
        .byte   $E2                             ; 8E8D
        beq     L8E82                           ; 8E8E
        .byte   $F2                             ; 8E90
        sbc     $F5,x                           ; 8E91
        .byte   $F3                             ; 8E93
        .byte   $0B                             ; 8E94
        sbc     $F3,x                           ; 8E95
        sbc     $F5,x                           ; 8E97
        .byte   $E3                             ; 8E99
        php                                     ; 8E9A
        sbc     $E2,x                           ; 8E9B
        .byte   $E2                             ; 8E9D
        cpx     #$F3                            ; 8E9E
L8EA0:  .byte   $03                             ; 8EA0
        sbc     $06,x                           ; 8EA1
        .byte   $E2                             ; 8EA3
        .byte   $F2                             ; 8EA4
        .byte   $F2                             ; 8EA5
        beq     L8E8A                           ; 8EA6
        .byte   $E2                             ; 8EA8
        .byte   $03                             ; 8EA9
        .byte   $F2                             ; 8EAA
        .byte   $E2                             ; 8EAB
        beq     L8EA0                           ; 8EAC
        .byte   $F2                             ; 8EAE
        .byte   $E3                             ; 8EAF
        asl     $F2                             ; 8EB0
        .byte   $27                             ; 8EB2
        .byte   $E2                             ; 8EB3
        .byte   $04                             ; 8EB4
        beq     L8EBA                           ; 8EB5
        .byte   $E2                             ; 8EB7
        cpx     #$E2                            ; 8EB8
L8EBA:  .byte   $E2                             ; 8EBA
        cpx     #$E0                            ; 8EBB
        asl     $E2                             ; 8EBD
        cpx     #$E0                            ; 8EBF
        .byte   $E2                             ; 8EC1
        .byte   $E2                             ; 8EC2
        cpx     #$F0                            ; 8EC3
        asl     $F2                             ; 8EC5
        .byte   $1B                             ; 8EC7
        .byte   $E2                             ; 8EC8
        .byte   $5C                             ; 8EC9
        eor     $595E,x                         ; 8ECA
        .byte   $5A                             ; 8ECD
        .byte   $5B                             ; 8ECE
        brk                                     ; 8ECF
        .byte   $53                             ; 8ED0
        .byte   $54                             ; 8ED1
        eor     $56,x                           ; 8ED2
        .byte   $57                             ; 8ED4
        cli                                     ; 8ED5
        .byte   $4F                             ; 8ED6
        bvc     L8F2A                           ; 8ED7
        .byte   $52                             ; 8ED9
        eor     $4B4E                           ; 8EDA
        jmp     L4A49                           ; 8EDD

; ----------------------------------------------------------------------------
        .byte   $47                             ; 8EE0
        pha                                     ; 8EE1
        eor     $46                             ; 8EE2
        adc     $6F6E                           ; 8EE4
        brk                                     ; 8EE7
        adc     #$6A                            ; 8EE8
        .byte   $6B                             ; 8EEA
        jmp     (L6564)                         ; 8EEB

; ----------------------------------------------------------------------------
        ror     $67                             ; 8EEE
        pla                                     ; 8EF0
        rts                                     ; 8EF1

; ----------------------------------------------------------------------------
        adc     ($62,x)                         ; 8EF2
        .byte   $63                             ; 8EF4
        lsr     $5B5F,x                         ; 8EF5
        .byte   $5C                             ; 8EF8
        eor     $5857,x                         ; 8EF9
        eor     $545A,y                         ; 8EFC
        eor     $56,x                           ; 8EFF
        .byte   $52                             ; 8F01
        .byte   $53                             ; 8F02
        pla                                     ; 8F03
        adc     #$6A                            ; 8F04
        adc     $66                             ; 8F06
        .byte   $67                             ; 8F08
        adc     ($62,x)                         ; 8F09
        .byte   $63                             ; 8F0B
        .byte   $64                             ; 8F0C
        adc     ($72),y                         ; 8F0D
        .byte   $73                             ; 8F0F
        lsr     $605F,x                         ; 8F10
        ror     $7000                           ; 8F13
        .byte   $5B                             ; 8F16
        .byte   $5C                             ; 8F17
        eor     $6C6B,x                         ; 8F18
        adc     L8180                           ; 8F1B
        .byte   $82                             ; 8F1E
        .byte   $7C                             ; 8F1F
        adc     $7F7E,x                         ; 8F20
        .byte   $77                             ; 8F23
        sei                                     ; 8F24
        adc     $7B7A,y                         ; 8F25
        .byte   $74                             ; 8F28
        .byte   $75                             ; 8F29
L8F2A:  ror     $89,x                           ; 8F2A
        txa                                     ; 8F2C
        .byte   $8B                             ; 8F2D
        sta     $86                             ; 8F2E
        .byte   $87                             ; 8F30
        dey                                     ; 8F31
        sta     ($82,x)                         ; 8F32
        .byte   $83                             ; 8F34
        sty     $71                             ; 8F35
        .byte   $72                             ; 8F37
        .byte   $73                             ; 8F38
        adc     $7F7E,x                         ; 8F39
        .byte   $80                             ; 8F3C
        ror     $706F                           ; 8F3D
        .byte   $6B                             ; 8F40
        jmp     (L7A6D)                         ; 8F41

; ----------------------------------------------------------------------------
        .byte   $7B                             ; 8F44
        .byte   $7C                             ; 8F45
        adc     #$6A                            ; 8F46
        .byte   $77                             ; 8F48
        sei                                     ; 8F49
        adc     $7468,y                         ; 8F4A
        adc     $76,x                           ; 8F4D
        .byte   $67                             ; 8F4F
        ror     $64                             ; 8F50
        adc     $62                             ; 8F52
        .byte   $63                             ; 8F54
        adc     ($64,x)                         ; 8F55
        adc     $66                             ; 8F57
        .byte   $67                             ; 8F59
        rts                                     ; 8F5A

; ----------------------------------------------------------------------------
        adc     ($62,x)                         ; 8F5B
        .byte   $63                             ; 8F5D
        .byte   $5A                             ; 8F5E
        .byte   $5B                             ; 8F5F
        .byte   $5C                             ; 8F60
        eor     $5F5E,x                         ; 8F61
        eor     $56,x                           ; 8F64
        .byte   $57                             ; 8F66
        cli                                     ; 8F67
        eor     $5150,y                         ; 8F68
        .byte   $52                             ; 8F6B
        .byte   $53                             ; 8F6C
        .byte   $54                             ; 8F6D
        lsr     a                               ; 8F6E
        .byte   $4B                             ; 8F6F
        jmp     L4E4D                           ; 8F70

; ----------------------------------------------------------------------------
        .byte   $4F                             ; 8F73
        lsr     $47                             ; 8F74
        pha                                     ; 8F76
        eor     #$42                            ; 8F77
        .byte   $43                             ; 8F79
        .byte   $44                             ; 8F7A
        eor     $39                             ; 8F7B
        .byte   $3A                             ; 8F7D
        .byte   $37                             ; 8F7E
        sec                                     ; 8F7F
        .byte   $34                             ; 8F80
        and     $36,x                           ; 8F81
        rol     $302F                           ; 8F83
L8F86:  and     ($32),y                         ; 8F86
        .byte   $33                             ; 8F88
        and     #$2A                            ; 8F89
        .byte   $2B                             ; 8F8B
        bit     $242D                           ; 8F8C
        and     $26                             ; 8F8F
        .byte   $27                             ; 8F91
        plp                                     ; 8F92
        eor     ($40,x)                         ; 8F93
        rol     $3C3F,x                         ; 8F95
        and     L813B,x                         ; 8F98
        .byte   $82                             ; 8F9B
        adc     $7F7E,x                         ; 8F9C
        .byte   $80                             ; 8F9F
        ror     $77,x                           ; 8FA0
        sei                                     ; 8FA2
        adc     $7B7A,y                         ; 8FA3
        .byte   $7C                             ; 8FA6
        .byte   $6F                             ; 8FA7
        bvs     L901B                           ; 8FA8
        .byte   $72                             ; 8FAA
        .byte   $73                             ; 8FAB
        .byte   $74                             ; 8FAC
        adc     $68,x                           ; 8FAD
        adc     #$6A                            ; 8FAF
        .byte   $6B                             ; 8FB1
        jmp     (L6E6D)                         ; 8FB2

; ----------------------------------------------------------------------------
        jsr     LA9D8                           ; 8FB5
        dex                                     ; 8FB8
        stx     $1A                             ; 8FB9
        lda     #$FF                            ; 8FBB
        ldx     $82                             ; 8FBD
        cpx     #$08                            ; 8FBF
        bcs     L8FC6                           ; 8FC1
        jsr     LE992                           ; 8FC3
L8FC6:  lda     #$81                            ; 8FC6
        jsr     LE9EB                           ; 8FC8
        jsr     LEA7E                           ; 8FCB
L8FCE:  jsr     LE95B                           ; 8FCE
        jsr     LAFDB                           ; 8FD1
        lda     $1A                             ; 8FD4
        bpl     L8FCE                           ; 8FD6
        asl     $1A                             ; 8FD8
        rts                                     ; 8FDA

; ----------------------------------------------------------------------------
        lda     $1A                             ; 8FDB
        and     #$3F                            ; 8FDD
        jsr     LAFF2                           ; 8FDF
        lda     $0F                             ; 8FE2
        adc     #$80                            ; 8FE4
        sta     $0F                             ; 8FE6
        lda     $12                             ; 8FE8
        adc     #$00                            ; 8FEA
        sta     $12                             ; 8FEC
        .byte   $20                             ; 8FEE
        .byte   $EF                             ; 8FEF
L8FF0:  inx                                     ; 8FF0
        rts                                     ; 8FF1

; ----------------------------------------------------------------------------
        jsr     LE97D                           ; 8FF2
        sbc     L9CAF,x                         ; 8FF5
        bcs     L8FF0                           ; 8FF8
        bcs     L9059                           ; 8FFA
        lda     ($A9),y                         ; 8FFC
        asl     $C820,x                         ; 8FFE
        inx                                     ; 9001
        sec                                     ; 9002
        jsr     LB06B                           ; 9003
        lda     #$04                            ; 9006
        bit     $82                             ; 9008
        beq     L9013                           ; 900A
        lda     #$19                            ; 900C
        jsr     LE8C8                           ; 900E
        lda     #$05                            ; 9011
L9013:  jsr     LE096                           ; 9013
        lda     #$00                            ; 9016
        jsr     LB707                           ; 9018
L901B:  jsr     LF09B                           ; 901B
        inc     $1A                             ; 901E
        lda     #$FE                            ; 9020
        sta     $1E                             ; 9022
        lda     $82                             ; 9024
        cmp     #$08                            ; 9026
        bcs     L902F                           ; 9028
        lda     #$3E                            ; 902A
        jsr     LE992                           ; 902C
L902F:  ldx     #$05                            ; 902F
L9031:  .byte   $BD                             ; 9031
        .byte   $57                             ; 9032
L9033:  bcs     *-105                           ; 9033
L9035:  asl     a                               ; 9035
        dex                                     ; 9036
        bpl     L9031                           ; 9037
        ldx     $82                             ; 9039
        dex                                     ; 903B
        lda     $B05D,x                         ; 903C
        sta     $09                             ; 903F
        txa                                     ; 9041
        sec                                     ; 9042
        sbc     #$05                            ; 9043
        bcs     L9049                           ; 9045
        lda     #$04                            ; 9047
L9049:  tax                                     ; 9049
        lda     $B065,x                         ; 904A
        sta     $04C4                           ; 904D
        lda     $B066,x                         ; 9050
        sta     $04C5                           ; 9053
        rts                                     ; 9056

; ----------------------------------------------------------------------------
        brk                                     ; 9057
        brk                                     ; 9058
L9059:  ora     ($80,x)                         ; 9059
        .byte   $80                             ; 905B
        brk                                     ; 905C
        cpy     #$C8                            ; 905D
        bne     L9031                           ; 905F
        bne     L9033                           ; 9061
        bne     L9035                           ; 9063
        bcs     L9069                           ; 9065
        cpy     #$01                            ; 9067
L9069:  brk                                     ; 9069
        brk                                     ; 906A
        ldy     #$02                            ; 906B
        ldx     #$03                            ; 906D
L906F:  lda     $B07D,y                         ; 906F
        sta     $04C0,x                         ; 9072
        dey                                     ; 9075
        dex                                     ; 9076
        bne     L906F                           ; 9077
        ror     $04C1                           ; 9079
        rts                                     ; 907C

; ----------------------------------------------------------------------------
        asl     $FCFF,x                         ; 907D
        asl     $FD01,x                         ; 9080
        asl     $F8FF,x                         ; 9083
        asl     $FBFE,x                         ; 9086
        lda     $82                             ; 9089
        cmp     #$04                            ; 908B
        bcc     L9095                           ; 908D
        .byte   $29                             ; 908F
L9090:  .byte   $04                             ; 9090
        bne     L9095                           ; 9091
        lda     #$01                            ; 9093
L9095:  asl     a                               ; 9095
        asl     a                               ; 9096
        adc     #$17                            ; 9097
        jmp     LB6A9                           ; 9099

; ----------------------------------------------------------------------------
        lda     $04C1                           ; 909C
        beq     L90A4                           ; 909F
        jsr     LB089                           ; 90A1
L90A4:  lda     $0B                             ; 90A4
        bpl     L90D6                           ; 90A6
        inc     $1A                             ; 90A8
        clc                                     ; 90AA
        jsr     LB06B                           ; 90AB
        stx     $2F                             ; 90AE
        ldy     $82                             ; 90B0
        dey                                     ; 90B2
        lda     $B2C7,y                         ; 90B3
        sta     $01                             ; 90B6
        lda     $B30D,y                         ; 90B8
        sta     $04                             ; 90BB
        lda     $B311,y                         ; 90BD
        sta     $05                             ; 90C0
        rts                                     ; 90C2

; ----------------------------------------------------------------------------
        lda     $0B                             ; 90C3
        and     #$07                            ; 90C5
        bne     L90D6                           ; 90C7
        lda     $0D                             ; 90C9
        clc                                     ; 90CB
        adc     #$40                            ; 90CC
        sta     $0D                             ; 90CE
        lda     $0C                             ; 90D0
        adc     #$00                            ; 90D2
        sta     $0C                             ; 90D4
L90D6:  clc                                     ; 90D6
        lda     $0E                             ; 90D7
        adc     $0D                             ; 90D9
        sta     $0E                             ; 90DB
        php                                     ; 90DD
        lda     $09                             ; 90DE
        adc     $0C                             ; 90E0
        sta     $09                             ; 90E2
        plp                                     ; 90E4
        lda     $0B                             ; 90E5
        adc     $0C                             ; 90E7
        sta     $0B                             ; 90E9
        bcc     L90F3                           ; 90EB
        lda     $0A                             ; 90ED
        eor     #$01                            ; 90EF
        sta     $0A                             ; 90F1
L90F3:  jmp     LB189                           ; 90F3

; ----------------------------------------------------------------------------
        lda     $04C4                           ; 90F6
        ora     $04C5                           ; 90F9
        beq     L910D                           ; 90FC
        lda     $04C4                           ; 90FE
        sec                                     ; 9101
        sbc     #$01                            ; 9102
        sta     $04C4                           ; 9104
        bcs     L910C                           ; 9107
        dec     $04C5                           ; 9109
L910C:  rts                                     ; 910C

; ----------------------------------------------------------------------------
L910D:  lda     $2F                             ; 910D
        bne     L9142                           ; 910F
        lda     $18                             ; 9111
        bne     L9142                           ; 9113
        asl     $01                             ; 9115
        lda     #$FF                            ; 9117
        bit     $01                             ; 9119
        bcc     L9123                           ; 911B
        bne     L9128                           ; 911D
        .byte   $E6                             ; 911F
L9120:  .byte   $1A                             ; 9120
        .byte   $D0                             ; 9121
L9122:  .byte   $1F                             ; 9122
L9123:  sec                                     ; 9123
        ror     $01                             ; 9124
        bne     L913E                           ; 9126
L9128:  sta     $18                             ; 9128
        lsr     $01                             ; 912A
        ldy     $01                             ; 912C
        jsr     LB143                           ; 912E
        sty     $01                             ; 9131
        dey                                     ; 9133
        bpl     L913E                           ; 9134
        lda     #$08                            ; 9136
        sta     $18                             ; 9138
        lda     #$02                            ; 913A
        bne     L9140                           ; 913C
L913E:  lda     #$01                            ; 913E
L9140:  sta     $2F                             ; 9140
L9142:  rts                                     ; 9142

; ----------------------------------------------------------------------------
        ldx     #$06                            ; 9143
L9145:  lda     $B156,x                         ; 9145
        sta     $E8,x                           ; 9148
        dex                                     ; 914A
        cpx     #$02                            ; 914B
        bcs     L9145                           ; 914D
L914F:  lda     ($04),y                         ; 914F
        sta     $E8,x                           ; 9151
        dey                                     ; 9153
        dex                                     ; 9154
        bpl     L914F                           ; 9155
        rts                                     ; 9157

; ----------------------------------------------------------------------------
        sta     ($06,x)                         ; 9158
        ora     ($56,x)                         ; 915A
        clv                                     ; 915C
        lda     $0B                             ; 915D
        cmp     #$0A                            ; 915F
        beq     L9174                           ; 9161
        lda     $0A                             ; 9163
        beq     L9186                           ; 9165
        lda     $04C1                           ; 9167
        bne     L9178                           ; 916A
        lda     #$FF                            ; 916C
        jsr     LE992                           ; 916E
        jmp     LB457                           ; 9171

; ----------------------------------------------------------------------------
L9174:  lda     #$00                            ; 9174
        sta     $1E                             ; 9176
L9178:  clc                                     ; 9178
        lda     $0390                           ; 9179
        adc     #$10                            ; 917C
        beq     L9183                           ; 917E
        sta     $0390                           ; 9180
L9183:  jsr     LB089                           ; 9183
L9186:  jmp     LB0C3                           ; 9186

; ----------------------------------------------------------------------------
        ldx     $82                             ; 9189
        dex                                     ; 918B
        lda     $B205,x                         ; 918C
        sta     $08                             ; 918F
        ldy     #$04                            ; 9191
        lda     $09                             ; 9193
        sta     $3F                             ; 9195
        lda     $0B                             ; 9197
        asl     a                               ; 9199
        lda     $0A                             ; 919A
        ror     a                               ; 919C
        ror     a                               ; 919D
        sta     $3C                             ; 919E
        sec                                     ; 91A0
        lda     #$40                            ; 91A1
        sta     $3E                             ; 91A3
        lda     #$00                            ; 91A5
        ror     a                               ; 91A7
        sta     $3B                             ; 91A8
L91AA:  lda     $B20D,y                         ; 91AA
        asl     a                               ; 91AD
        asl     a                               ; 91AE
        tax                                     ; 91AF
        lda     $B20D,y                         ; 91B0
        and     #$C0                            ; 91B3
        lsr     a                               ; 91B5
        sta     $3D                             ; 91B6
        lda     $B24B,y                         ; 91B8
        lsr     a                               ; 91BB
        ora     $3B                             ; 91BC
        sta     $0241,x                         ; 91BE
        lda     $3D                             ; 91C1
        rol     a                               ; 91C3
        sta     $0242,x                         ; 91C4
        lda     #$F8                            ; 91C7
        sta     $0240,x                         ; 91C9
        sta     $0243,x                         ; 91CC
        lda     $B289,y                         ; 91CF
        and     #$0F                            ; 91D2
        asl     a                               ; 91D4
        asl     a                               ; 91D5
        asl     a                               ; 91D6
        clc                                     ; 91D7
        adc     $3F                             ; 91D8
        bit     $3C                             ; 91DA
        bmi     L91EC                           ; 91DC
        bvs     L91E6                           ; 91DE
        cmp     #$C0                            ; 91E0
        bcc     L91F0                           ; 91E2
        bcs     L91FF                           ; 91E4
L91E6:  cmp     #$40                            ; 91E6
        bcs     L91F0                           ; 91E8
        bcc     L91FF                           ; 91EA
L91EC:  cmp     #$7F                            ; 91EC
        bcc     L91FF                           ; 91EE
L91F0:  sta     $0243,x                         ; 91F0
        lda     $B289,y                         ; 91F3
        and     #$F0                            ; 91F6
        lsr     a                               ; 91F8
        clc                                     ; 91F9
        adc     $3E                             ; 91FA
        sta     $0240,x                         ; 91FC
L91FF:  iny                                     ; 91FF
        cpy     $08                             ; 9200
        bne     L91AA                           ; 9202
        rts                                     ; 9204

; ----------------------------------------------------------------------------
        .byte   $13                             ; 9205
        ora     $2C29,x                         ; 9206
        .byte   $32                             ; 9209
        .byte   $32                             ; 920A
        .byte   $32                             ; 920B
        .byte   $32                             ; 920C
        brk                                     ; 920D
        ora     ($02,x)                         ; 920E
        .byte   $03                             ; 9210
        brk                                     ; 9211
        ora     ($02,x)                         ; 9212
        .byte   $03                             ; 9214
        .byte   $04                             ; 9215
        ora     $06                             ; 9216
        .byte   $07                             ; 9218
        php                                     ; 9219
        ora     #$0A                            ; 921A
        .byte   $0B                             ; 921C
        .byte   $0C                             ; 921D
        ora     $020E                           ; 921E
        ora     $06                             ; 9221
        .byte   $0F                             ; 9223
        bpl     L9237                           ; 9224
        .byte   $12                             ; 9226
        .byte   $13                             ; 9227
        .byte   $14                             ; 9228
        ora     $0F,x                           ; 9229
        .byte   $10                             ; 922B
L922C:  .byte   $12                             ; 922C
        .byte   $13                             ; 922D
        asl     $17,x                           ; 922E
        clc                                     ; 9230
        ora     $1B1A,y                         ; 9231
        .byte   $1C                             ; 9234
        .byte   $1D                             ; 9235
        .byte   $0C                             ; 9236
L9237:  .byte   $12                             ; 9237
        .byte   $13                             ; 9238
        .byte   $04                             ; 9239
        .byte   $07                             ; 923A
        php                                     ; 923B
        .byte   $03                             ; 923C
        ora     #$0E                            ; 923D
L923F:  plp                                     ; 923F
        adc     #$2A                            ; 9240
        .byte   $6B                             ; 9242
L9243:  bit     $2D6D                           ; 9243
        .byte   $6C                             ; 9246
        rol     a                               ; 9247
L9248:  .byte   $6B                             ; 9248
        bit     $026D                           ; 9249
        .byte   $22                             ; 924C
        asl     $26                             ; 924D
        lsr     $76,x                           ; 924F
        .byte   $72                             ; 9251
        lsr     $4A6E                           ; 9252
        ror     a                               ; 9255
        lsr     $66                             ; 9256
        .byte   $42                             ; 9258
        .byte   $62                             ; 9259
        .byte   $62                             ; 925A
        .byte   $62                             ; 925B
        .byte   $62                             ; 925C
        .byte   $62                             ; 925D
        .byte   $22                             ; 925E
        .byte   $5A                             ; 925F
        ror     L2606,x                         ; 9260
        .byte   $02                             ; 9263
        lsr     $627A,x                         ; 9264
        .byte   $62                             ; 9267
        asl     $26                             ; 9268
        asl     a                               ; 926A
        rol     a                               ; 926B
        rol     $7A0E                           ; 926C
        .byte   $62                             ; 926F
        .byte   $32                             ; 9270
        rol     $12,x                           ; 9271
        asl     $1A,x                           ; 9273
        .byte   $82                             ; 9275
        ldx     #$52                            ; 9276
        .byte   $C2                             ; 9278
        .byte   $E2                             ; 9279
        .byte   $52                             ; 927A
        .byte   $C2                             ; 927B
        .byte   $62                             ; 927C
        .byte   $C2                             ; 927D
        .byte   $C2                             ; 927E
        dec     $E6CE                           ; 927F
        inc     $E2                             ; 9282
        .byte   $E2                             ; 9284
        dec     $C6                             ; 9285
        inc     $E6                             ; 9287
        jmp     L6C4D                           ; 9289

; ----------------------------------------------------------------------------
        adc     L1716                           ; 928C
        rol     $37,x                           ; 928F
        sec                                     ; 9291
L9292:  eor     $56,x                           ; 9292
        .byte   $57                             ; 9294
        cli                                     ; 9295
        eor     $7675,y                         ; 9296
        .byte   $77                             ; 9299
        sei                                     ; 929A
        adc     $5636,y                         ; 929B
        eor     $13,x                           ; 929E
        .byte   $14                             ; 92A0
        and     $54,x                           ; 92A1
        .byte   $53                             ; 92A3
        .byte   $73                             ; 92A4
        .byte   $74                             ; 92A5
        .byte   $03                             ; 92A6
        .byte   $04                             ; 92A7
        .byte   $53                             ; 92A8
        .byte   $54                             ; 92A9
        .byte   $34                             ; 92AA
        .byte   $33                             ; 92AB
        .byte   $52                             ; 92AC
        .byte   $72                             ; 92AD
        ora     ($31),y                         ; 92AE
        bpl     L92E2                           ; 92B0
        .byte   $77                             ; 92B2
        .byte   $53                             ; 92B3
        .byte   $54                             ; 92B4
        .byte   $37                             ; 92B5
        .byte   $57                             ; 92B6
        cli                                     ; 92B7
        .byte   $37                             ; 92B8
        .byte   $57                             ; 92B9
        sei                                     ; 92BA
        pla                                     ; 92BB
        .byte   $67                             ; 92BC
        .byte   $47                             ; 92BD
        pha                                     ; 92BE
        ror     $69                             ; 92BF
        adc     #$66                            ; 92C1
        pha                                     ; 92C3
        .byte   $47                             ; 92C4
        ror     $69                             ; 92C5
        php                                     ; 92C7
        asl     $1612                           ; 92C8
        brk                                     ; 92CB
        brk                                     ; 92CC
        brk                                     ; 92CD
        brk                                     ; 92CE
        cmp     ($BB,x)                         ; 92CF
        lda     $BB                             ; 92D1
        .byte   $82                             ; 92D3
        .byte   $BB                             ; 92D4
        bvs     L9292                           ; 92D5
        cmp     ($BB,x)                         ; 92D7
        .byte   $3F                             ; 92D9
        ldy     $BC15,x                         ; 92DA
        .byte   $04                             ; 92DD
        ldy     $BBEC,x                         ; 92DE
        .byte   $D9                             ; 92E1
L92E2:  .byte   $BB                             ; 92E2
        .byte   $C3                             ; 92E3
        .byte   $BB                             ; 92E4
        cmp     ($BB,x)                         ; 92E5
        .byte   $FA                             ; 92E7
        ldy     $BCF4,x                         ; 92E8
        dec     $C2BC,x                         ; 92EB
        ldy     $BCA1,x                         ; 92EE
        .byte   $82                             ; 92F1
        ldy     $BC71,x                         ; 92F2
        lsr     $C1BC                           ; 92F5
        .byte   $BB                             ; 92F8
        ora     ($BE,x)                         ; 92F9
        .byte   $EB                             ; 92FB
        lda     $BDCC,x                         ; 92FC
        .byte   $AB                             ; 92FF
        lda     $BD81,x                         ; 9300
        pla                                     ; 9303
        lda     $BD5E,x                         ; 9304
        lsr     $BD                             ; 9307
        .byte   $27                             ; 9309
        lda     $BD06,x                         ; 930A
        dec     $E4D6                           ; 930D
        inc     $B2,x                           ; 9310
        .byte   $B2                             ; 9312
        .byte   $B2                             ; 9313
        .byte   $B2                             ; 9314
        jsr     LA9D8                           ; 9315
        asl     $18                             ; 9318
        dex                                     ; 931A
        stx     $1A                             ; 931B
L931D:  jsr     LE95B                           ; 931D
        lda     $1A                             ; 9320
        and     #$3F                            ; 9322
        jsr     LB32E                           ; 9324
        lda     $1A                             ; 9327
        bpl     L931D                           ; 9329
        asl     $1A                             ; 932B
        rts                                     ; 932D

; ----------------------------------------------------------------------------
        jsr     LE97D                           ; 932E
        .byte   $3B                             ; 9331
        .byte   $B3                             ; 9332
        sed                                     ; 9333
        .byte   $B3                             ; 9334
        asl     $B4,x                           ; 9335
        .byte   $3B                             ; 9337
        ldy     $4F,x                           ; 9338
        ldy     $A9,x                           ; 933A
        brk                                     ; 933C
L933D:  sta     $1E                             ; 933D
        lda     #$00                            ; 933F
        .byte   $20                             ; 9341
L9342:  iny                                     ; 9342
        inx                                     ; 9343
        jsr     LB410                           ; 9344
        lda     #$81                            ; 9347
        jsr     LE9EB                           ; 9349
        jsr     LB35B                           ; 934C
        lda     #$06                            ; 934F
        jsr     LE096                           ; 9351
        nop                                     ; 9354
        nop                                     ; 9355
        inc     $1A                             ; 9356
        jmp     LEA7E                           ; 9358

; ----------------------------------------------------------------------------
        ldx     $0162                           ; 935B
        lda     #$CD                            ; 935E
        sta     $04                             ; 9360
        lda     #$B3                            ; 9362
        sta     $05                             ; 9364
        jsr     LB37D                           ; 9366
        lda     $82                             ; 9369
        asl     a                               ; 936B
        tay                                     ; 936C
        lsr     a                               ; 936D
        adc     #$01                            ; 936E
        sta     $0162,x                         ; 9370
        lda     $B3C3,y                         ; 9373
        sta     $04                             ; 9376
        lda     $B3C4,y                         ; 9378
        sta     $05                             ; 937B
        ldy     #$00                            ; 937D
        lda     #$03                            ; 937F
        sta     $00                             ; 9381
L9383:  lda     ($04),y                         ; 9383
        sta     $0163,x                         ; 9385
        iny                                     ; 9388
        inx                                     ; 9389
        dec     $00                             ; 938A
        bne     L9383                           ; 938C
        sta     $00                             ; 938E
L9390:  .byte   $B1                             ; 9390
L9391:  .byte   $04                             ; 9391
        bmi     L93A0                           ; 9392
L9394:  sta     $0163,x                         ; 9394
        iny                                     ; 9397
        inx                                     ; 9398
        dec     $00                             ; 9399
        bne     L9390                           ; 939B
        jmp     LB3EF                           ; 939D

; ----------------------------------------------------------------------------
L93A0:  sty     $01                             ; 93A0
        asl     a                               ; 93A2
        tay                                     ; 93A3
        lda     $B856,y                         ; 93A4
        sta     $02                             ; 93A7
        lda     $B857,y                         ; 93A9
        sta     $03                             ; 93AC
        ldy     #$00                            ; 93AE
L93B0:  lda     ($02),y                         ; 93B0
        bmi     L93BD                           ; 93B2
        sta     $0163,x                         ; 93B4
        dec     $00                             ; 93B7
        iny                                     ; 93B9
        inx                                     ; 93BA
        bne     L93B0                           ; 93BB
L93BD:  ldy     $01                             ; 93BD
        and     #$7F                            ; 93BF
        bpl     L9394                           ; 93C1
        bit     $BB                             ; 93C3
        rol     $BB,x                           ; 93C5
        .byte   $47                             ; 93C7
        .byte   $BB                             ; 93C8
        .byte   $52                             ; 93C9
        .byte   $BB                             ; 93CA
        .byte   $5F                             ; 93CB
        .byte   $BB                             ; 93CC
        jsr     L09C9                           ; 93CD
        .byte   $8B                             ; 93D0
        bit     $AE2C                           ; 93D1
        .byte   $62                             ; 93D4
        ora     ($0A,x)                         ; 93D5
        tay                                     ; 93D7
        lda     $B4BA,y                         ; 93D8
        sta     $04                             ; 93DB
        lda     $B4BB,y                         ; 93DD
        sta     $05                             ; 93E0
        ldy     #$00                            ; 93E2
L93E4:  lda     ($04),y                         ; 93E4
        sta     $0163,x                         ; 93E6
        beq     L93EF                           ; 93E9
        iny                                     ; 93EB
        inx                                     ; 93EC
        bne     L93E4                           ; 93ED
L93EF:  lda     #$00                            ; 93EF
        sta     $0163,x                         ; 93F1
        stx     $0162                           ; 93F4
        rts                                     ; 93F7

; ----------------------------------------------------------------------------
        lda     $18                             ; 93F8
        bne     L940F                           ; 93FA
        lda     #$FB                            ; 93FC
        sta     $1E                             ; 93FE
        inc     $1A                             ; 9400
        lda     #$00                            ; 9402
        jsr     LB707                           ; 9404
        jsr     LB45C                           ; 9407
        lda     #$3F                            ; 940A
        jsr     LE992                           ; 940C
L940F:  rts                                     ; 940F

; ----------------------------------------------------------------------------
        sec                                     ; 9410
        ldy     #$0B                            ; 9411
        jmp     LB06B                           ; 9413

; ----------------------------------------------------------------------------
        jsr     LB42E                           ; 9416
        lda     $02                             ; 9419
        lda     #$0F                            ; 941B
        sta     $04A2                           ; 941D
        lda     $04C1                           ; 9420
        bne     L942D                           ; 9423
        inc     $1A                             ; 9425
        ldy     #$05                            ; 9427
        sec                                     ; 9429
        jsr     LB06D                           ; 942A
L942D:  rts                                     ; 942D

; ----------------------------------------------------------------------------
        lda     $82                             ; 942E
        asl     a                               ; 9430
        asl     a                               ; 9431
        adc     #$38                            ; 9432
        jsr     LB6A9                           ; 9434
        lda     $04C1                           ; 9437
        rts                                     ; 943A

; ----------------------------------------------------------------------------
        jsr     LB42E                           ; 943B
        bne     L944E                           ; 943E
        inc     $1A                             ; 9440
        clc                                     ; 9442
        jsr     LB06B                           ; 9443
        lda     #$A0                            ; 9446
        sta     $1E                             ; 9448
L944A:  lda     $1E                             ; 944A
        bne     L944A                           ; 944C
L944E:  rts                                     ; 944E

; ----------------------------------------------------------------------------
        jsr     LB42E                           ; 944F
        bne     L945B                           ; 9452
        jsr     LA9D8                           ; 9454
        lda     #$80                            ; 9457
        sta     $1A                             ; 9459
L945B:  rts                                     ; 945B

; ----------------------------------------------------------------------------
        lda     $11                             ; 945C
        ora     #$18                            ; 945E
        sta     $11                             ; 9460
        lda     $1C                             ; 9462
        ora     #$04                            ; 9464
        sta     $1C                             ; 9466
        rts                                     ; 9468

; ----------------------------------------------------------------------------
        jsr     LA9D8                           ; 9469
        lda     #$11                            ; 946C
        jsr     LB707                           ; 946E
        jsr     LE95B                           ; 9471
        lda     #$FF                            ; 9474
        lsr     $57                             ; 9476
        jsr     LE992                           ; 9478
        jsr     LEA7E                           ; 947B
        lda     #$06                            ; 947E
        jsr     LE8C8                           ; 9480
        lda     #$81                            ; 9483
        jsr     LE9EB                           ; 9485
        lda     #$04                            ; 9488
        sta     $08                             ; 948A
        lda     #$F8                            ; 948C
        sta     $3F                             ; 948E
        ldy     #$00                            ; 9490
        sty     $3C                             ; 9492
        clc                                     ; 9494
        jsr     LB1A1                           ; 9495
        lda     #$05                            ; 9498
        jsr     LB3D3                           ; 949A
        ldx     $82                             ; 949D
        inx                                     ; 949F
        stx     $016E                           ; 94A0
        ldx     $80                             ; 94A3
        dex                                     ; 94A5
L94A6:  stx     $0175                           ; 94A6
        jsr     LB45C                           ; 94A9
        lda     #$0C                            ; 94AC
        sta     $2F                             ; 94AE
L94B0:  lda     $2F                             ; 94B0
        bne     L94B0                           ; 94B2
        jsr     LA9D8                           ; 94B4
        jmp     LEA7E                           ; 94B7

; ----------------------------------------------------------------------------
        .byte   $9C                             ; 94BA
        lda     $ADA1                           ; 94BB
        ldx     $AD                             ; 94BE
        lda     $B4AD                           ; 94C0
        lda     $B4EC                           ; 94C3
        ora     ($B5,x)                         ; 94C6
        asl     $B5,x                           ; 94C8
        rol     $B5,x                           ; 94CA
        eor     $7CB5,y                         ; 94CC
        lda     $9F,x                           ; 94CF
        lda     $C1,x                           ; 94D1
        lda     $DE,x                           ; 94D3
        lda     $F2,x                           ; 94D5
        lda     $1A,x                           ; 94D7
        ldx     $32,y                           ; 94D9
        ldx     $51,y                           ; 94DB
        ldx     $8F,y                           ; 94DD
        ldx     $55,y                           ; 94DF
        ldx     $66,y                           ; 94E1
        ldx     $77,y                           ; 94E3
        ldx     $85,y                           ; 94E5
        ldx     $8A,y                           ; 94E7
        ldx     $7E,y                           ; 94E9
        ldx     $21,y                           ; 94EB
        .byte   $4B                             ; 94ED
        asl     a                               ; 94EE
        .byte   $32                             ; 94EF
        .byte   $37                             ; 94F0
        bmi     L9532                           ; 94F1
        .byte   $43                             ; 94F3
        .byte   $34                             ; 94F4
        eor     ($2C,x)                         ; 94F5
        bit     $212C                           ; 94F7
        .byte   $CF                             ; 94FA
        .byte   $04                             ; 94FB
        .byte   $CB                             ; 94FC
        bit     $2C2C                           ; 94FD
        brk                                     ; 9500
        jsr     L0190                           ; 9501
        stx     L9120                           ; 9504
        eor     $208C                           ; 9507
        .byte   $9E                             ; 950A
        ora     ($9E,x)                         ; 950B
        jsr     LC8BE                           ; 950D
        sta     $BE21                           ; 9510
        ora     ($9F,x)                         ; 9513
        brk                                     ; 9515
        jsr     L0CA5                           ; 9516
        .byte   $D2                             ; 9519
        txa                                     ; 951A
        .byte   $2F                             ; 951B
        .byte   $2F                             ; 951C
        .byte   $2F                             ; 951D
        .byte   $2F                             ; 951E
        txs                                     ; 951F
        .byte   $C2                             ; 9520
        bit     $2C2C                           ; 9521
        sta     $C420                           ; 9524
        ora     $2DD2                           ; 9527
        dey                                     ; 952A
        .byte   $2F                             ; 952B
        .byte   $2F                             ; 952C
        .byte   $2F                             ; 952D
        .byte   $2F                             ; 952E
        tya                                     ; 952F
        .byte   $2D                             ; 9530
        .byte   $C2                             ; 9531
L9532:  bit     L8D2C                           ; 9532
        brk                                     ; 9535
        jsr     L0EE3                           ; 9536
        .byte   $D2                             ; 9539
        and     $2D2D                           ; 953A
        txa                                     ; 953D
        iny                                     ; 953E
        ldy     #$9A                            ; 953F
        and     $2D2D                           ; 9541
        .byte   $C2                             ; 9544
        bit     $218D                           ; 9545
        .byte   $03                             ; 9548
        asl     $B9AB                           ; 9549
        and     L88C9                           ; 954C
        .byte   $2F                             ; 954F
        .byte   $2F                             ; 9550
        tya                                     ; 9551
        cmp     #$2D                            ; 9552
        lda     #$BB                            ; 9554
        bit     a:$8D                           ; 9556
        and     ($23,x)                         ; 9559
        asl     $2F2F                           ; 955B
        .byte   $AB                             ; 955E
        lda     $A3C3,y                         ; 955F
        lda     ($B3),y                         ; 9562
        lda     #$BB                            ; 9564
        .byte   $2F                             ; 9566
        .byte   $2F                             ; 9567
        bit     $218D                           ; 9568
        .byte   $43                             ; 956B
        asl     $2F2F                           ; 956C
        bcs     L95A0                           ; 956F
        .byte   $A3                             ; 9571
        .byte   $A3                             ; 9572
        lda     ($B1),y                         ; 9573
        .byte   $2F                             ; 9575
        bcs     L95A7                           ; 9576
        .byte   $2F                             ; 9578
        bit     a:$8D                           ; 9579
        and     ($63,x)                         ; 957C
        asl     $2F2F                           ; 957E
        lda     ($2F,x)                         ; 9581
        ldx     #$A2                            ; 9583
        .byte   $B2                             ; 9585
        .byte   $B2                             ; 9586
        .byte   $2F                             ; 9587
        lda     ($2F,x)                         ; 9588
        .byte   $2F                             ; 958A
        bit     $218D                           ; 958B
        .byte   $83                             ; 958E
        asl     $2F2F                           ; 958F
        tax                                     ; 9592
        clv                                     ; 9593
        .byte   $C2                             ; 9594
        ldx     #$B2                            ; 9595
        .byte   $D2                             ; 9597
        tay                                     ; 9598
        tsx                                     ; 9599
        .byte   $2F                             ; 959A
        .byte   $2F                             ; 959B
        bit     a:$8D                           ; 959C
        .byte   $21                             ; 959F
L95A0:  .byte   $A3                             ; 95A0
        asl     $B8AA                           ; 95A1
        and     L89C9                           ; 95A4
L95A7:  .byte   $2F                             ; 95A7
        .byte   $2F                             ; 95A8
        sta     $2DC9,y                         ; 95A9
        tay                                     ; 95AC
        tsx                                     ; 95AD
        bit     $218F                           ; 95AE
        .byte   $C3                             ; 95B1
        ora     $2DB3                           ; 95B2
        and     L8B2D                           ; 95B5
        iny                                     ; 95B8
        ldy     #$9B                            ; 95B9
        and     $2D2D                           ; 95BB
        .byte   $C3                             ; 95BE
        bit     $2100                           ; 95BF
        lda     ($4D),y                         ; 95C2
        sty     $E421                           ; 95C4
        asl     a                               ; 95C7
        .byte   $B3                             ; 95C8
        and     $2F89                           ; 95C9
        .byte   $2F                             ; 95CC
        .byte   $2F                             ; 95CD
        .byte   $2F                             ; 95CE
        sta     $C32D,y                         ; 95CF
        .byte   $22                             ; 95D2
        ora     $08                             ; 95D3
        .byte   $B3                             ; 95D5
        .byte   $8B                             ; 95D6
        .byte   $2F                             ; 95D7
        .byte   $2F                             ; 95D8
        .byte   $2F                             ; 95D9
        .byte   $2F                             ; 95DA
        .byte   $9B                             ; 95DB
        .byte   $C3                             ; 95DC
        brk                                     ; 95DD
        and     ($F1,x)                         ; 95DE
        jmp     L222E                           ; 95E0

; ----------------------------------------------------------------------------
        ora     ($4C),y                         ; 95E3
        rol     $3122                           ; 95E5
        jmp     L222E                           ; 95E8

; ----------------------------------------------------------------------------
        .byte   $43                             ; 95EB
        .byte   $04                             ; 95EC
        stx     L8C8C                           ; 95ED
        .byte   $9E                             ; 95F0
        brk                                     ; 95F1
        .byte   $22                             ; 95F2
        .byte   $63                             ; 95F3
        .byte   $04                             ; 95F4
        sta     $2C2C                           ; 95F5
        sta     L8322                           ; 95F8
        .byte   $04                             ; 95FB
        sta     $2C2C                           ; 95FC
        sta     $A322                           ; 95FF
        .byte   $04                             ; 9602
        .byte   $8F                             ; 9603
        sty     L9F8C                           ; 9604
        .byte   $22                             ; 9607
        eor     ($01),y                         ; 9608
        .byte   $80                             ; 960A
        .byte   $22                             ; 960B
        .byte   $5C                             ; 960C
        ora     ($91,x)                         ; 960D
        .byte   $22                             ; 960F
        adc     ($02),y                         ; 9610
        .byte   $80                             ; 9612
        .byte   $80                             ; 9613
        .byte   $22                             ; 9614
        .byte   $7B                             ; 9615
        .byte   $02                             ; 9616
        sta     ($91),y                         ; 9617
        brk                                     ; 9619
        .byte   $22                             ; 961A
        .byte   $52                             ; 961B
        lsr     a                               ; 961C
        rol     $7322                           ; 961D
        pha                                     ; 9620
        rol     L9122                           ; 9621
        .byte   $0C                             ; 9624
        sbc     $80,x                           ; 9625
        .byte   $82                             ; 9627
        .byte   $81                             ; 9628
L9629:  .byte   $82                             ; 9629
        sta     ($82,x)                         ; 962A
        sta     ($82,x)                         ; 962C
        sta     ($91,x)                         ; 962E
        sbc     $00,x                           ; 9630
        .byte   $22                             ; 9632
        lda     ($0C),y                         ; 9633
        cpx     $2414                           ; 9635
        cpx     $EC14                           ; 9638
        beq     L9629                           ; 963B
        .byte   $14                             ; 963D
        .byte   $92                             ; 963E
        bit     $F0                             ; 963F
        .byte   $22                             ; 9641
        cmp     ($0C),y                         ; 9642
        sbc     $15                             ; 9644
        and     $E5                             ; 9646
        ora     $E5,x                           ; 9648
        cpx     #$E5                            ; 964A
        ora     $93,x                           ; 964C
        and     $E0                             ; 964E
        brk                                     ; 9650
        .byte   $23                             ; 9651
        cpy     #$40                            ; 9652
        eor     $23,x                           ; 9654
        iny                                     ; 9656
        .byte   $44                             ; 9657
        tax                                     ; 9658
        .byte   $23                             ; 9659
        bne     L96A0                           ; 965A
        tax                                     ; 965C
        .byte   $23                             ; 965D
        cld                                     ; 965E
        .byte   $44                             ; 965F
        tax                                     ; 9660
        .byte   $23                             ; 9661
        cpx     #$44                            ; 9662
        .byte   $5A                             ; 9664
        brk                                     ; 9665
        .byte   $23                             ; 9666
        iny                                     ; 9667
        .byte   $44                             ; 9668
        .byte   $FF                             ; 9669
        .byte   $23                             ; 966A
        bne     L96B1                           ; 966B
        .byte   $FF                             ; 966D
        .byte   $23                             ; 966E
        cld                                     ; 966F
        .byte   $44                             ; 9670
        .byte   $FF                             ; 9671
        .byte   $23                             ; 9672
        cpx     #$44                            ; 9673
        .byte   $5F                             ; 9675
        brk                                     ; 9676
        .byte   $B2                             ; 9677
        eor     $B62C                           ; 9678
        eor     a:$2C                           ; 967B
        .byte   $BB                             ; 967E
        eor     $BF2C                           ; 967F
        eor     a:$2C                           ; 9682
        and     ($9D,x)                         ; 9685
        ora     ($7F,x)                         ; 9687
        brk                                     ; 9689
        and     ($9D,x)                         ; 968A
        ora     ($2C,x)                         ; 968C
        brk                                     ; 968E
        .byte   $22                             ; 968F
        .byte   $67                             ; 9690
        ora     #$43                            ; 9691
        .byte   $37                             ; 9693
        .byte   $34                             ; 9694
        bit     $3743                           ; 9695
        sec                                     ; 9698
        and     $2236,x                         ; 9699
        .byte   $87                             ; 969C
        asl     a                               ; 969D
        pha                                     ; 969E
        .byte   $3E                             ; 969F
L96A0:  .byte   $44                             ; 96A0
        bit     $3732                           ; 96A1
        rol     $3442,x                         ; 96A4
        .byte   $4F                             ; 96A7
        brk                                     ; 96A8
        ldx     $1E                             ; 96A9
        bne     L9706                           ; 96AB
        jsr     LB707                           ; 96AD
        .byte   $AD                             ; 96B0
L96B1:  cmp     ($04,x)                         ; 96B1
        clc                                     ; 96B3
        bpl     L96BC                           ; 96B4
        eor     #$30                            ; 96B6
        and     #$30                            ; 96B8
        bcc     L96C0                           ; 96BA
L96BC:  adc     #$10                            ; 96BC
        and     #$70                            ; 96BE
L96C0:  sta     $00                             ; 96C0
        lda     $04C1                           ; 96C2
        adc     #$10                            ; 96C5
        sta     $01                             ; 96C7
        bit     $01                             ; 96C9
        bvc     L96CF                           ; 96CB
        lda     #$00                            ; 96CD
L96CF:  sta     $04C1                           ; 96CF
        lda     $04C2                           ; 96D2
        sta     $02                             ; 96D5
        lda     $04C3                           ; 96D7
        sta     $1E                             ; 96DA
        jsr     LB6E2                           ; 96DC
        jmp     LB462                           ; 96DF

; ----------------------------------------------------------------------------
        ldx     #$00                            ; 96E2
L96E4:  ldy     #$04                            ; 96E4
        lda     $01                             ; 96E6
        lsr     $02                             ; 96E8
        bcc     L96EE                           ; 96EA
        sta     $03                             ; 96EC
L96EE:  lsr     $03                             ; 96EE
        bcc     L96FE                           ; 96F0
        lda     $04A0,x                         ; 96F2
        sbc     $00                             ; 96F5
        bcs     L96FB                           ; 96F7
        lda     #$0F                            ; 96F9
L96FB:  sta     $04A0,x                         ; 96FB
L96FE:  inx                                     ; 96FE
        dey                                     ; 96FF
        bne     L96EE                           ; 9700
        lda     $02                             ; 9702
        bne     L96E4                           ; 9704
L9706:  rts                                     ; 9706

; ----------------------------------------------------------------------------
        pha                                     ; 9707
        and     #$03                            ; 9708
        asl     a                               ; 970A
        asl     a                               ; 970B
        ldx     #$1F                            ; 970C
        jsr     LB726                           ; 970E
        pla                                     ; 9711
        and     #$FC                            ; 9712
        pha                                     ; 9714
        jsr     LB726                           ; 9715
        pla                                     ; 9718
        lsr     a                               ; 9719
        lsr     a                               ; 971A
        tay                                     ; 971B
        lda     $B83A,y                         ; 971C
        sta     $04B0                           ; 971F
        sta     $04BA                           ; 9722
        rts                                     ; 9725

; ----------------------------------------------------------------------------
L9726:  pha                                     ; 9726
        tay                                     ; 9727
        lda     $B74C,y                         ; 9728
        tay                                     ; 972B
L972C:  lda     $B7B0,y                         ; 972C
        sta     $04A0,x                         ; 972F
        dey                                     ; 9732
        dex                                     ; 9733
        txa                                     ; 9734
        and     #$03                            ; 9735
        bne     L972C                           ; 9737
        lda     #$0F                            ; 9739
        sta     $04A0,x                         ; 973B
        txa                                     ; 973E
        dex                                     ; 973F
        and     #$0F                            ; 9740
        beq     L974A                           ; 9742
        pla                                     ; 9744
        clc                                     ; 9745
        adc     #$01                            ; 9746
        bcc     L9726                           ; 9748
L974A:  pla                                     ; 974A
        rts                                     ; 974B

; ----------------------------------------------------------------------------
        .byte   $02                             ; 974C
        .byte   $02                             ; 974D
        .byte   $02                             ; 974E
        .byte   $02                             ; 974F
        .byte   $2F                             ; 9750
        .byte   $02                             ; 9751
        asl     $5305                           ; 9752
        .byte   $14                             ; 9755
        lsr     $11,x                           ; 9756
        .byte   $02                             ; 9758
        .byte   $02                             ; 9759
        .byte   $02                             ; 975A
        ora     $05                             ; 975B
        ora     L080B,x                         ; 975D
        .byte   $1A                             ; 9760
        .byte   $17                             ; 9761
        bit     $3B08                           ; 9762
        sec                                     ; 9765
        .byte   $02                             ; 9766
        php                                     ; 9767
        eor     ($47,x)                         ; 9768
        .byte   $02                             ; 976A
        php                                     ; 976B
        lsr     a                               ; 976C
        sec                                     ; 976D
        .byte   $02                             ; 976E
        php                                     ; 976F
        .byte   $02                             ; 9770
        eor     $0802                           ; 9771
        .byte   $02                             ; 9774
        jsr     L080B                           ; 9775
        .byte   $02                             ; 9778
        .byte   $23                             ; 9779
        .byte   $0B                             ; 977A
        php                                     ; 977B
        .byte   $02                             ; 977C
        rol     $0B                             ; 977D
        php                                     ; 977F
        .byte   $02                             ; 9780
        .byte   $32                             ; 9781
        .byte   $0B                             ; 9782
        php                                     ; 9783
        ror     $686B                           ; 9784
        eor     $6B6E,y                         ; 9787
        pla                                     ; 978A
        .byte   $5C                             ; 978B
        ror     $686B                           ; 978C
        .byte   $5F                             ; 978F
        ror     $686B                           ; 9790
        .byte   $62                             ; 9793
        ror     $686B                           ; 9794
        adc     $74                             ; 9797
        adc     ($0B),y                         ; 9799
        php                                     ; 979B
        .byte   $80                             ; 979C
        adc     ($0B),y                         ; 979D
        php                                     ; 979F
        .byte   $74                             ; 97A0
        adc     L080B,x                         ; 97A1
        adc     ($7A),y                         ; 97A4
        .byte   $0B                             ; 97A6
        php                                     ; 97A7
        .byte   $89                             ; 97A8
        .byte   $83                             ; 97A9
        .byte   $0B                             ; 97AA
        php                                     ; 97AB
        .byte   $80                             ; 97AC
        stx     $0B                             ; 97AD
        php                                     ; 97AF
        .byte   $0F                             ; 97B0
        .byte   $0F                             ; 97B1
        .byte   $0F                             ; 97B2
        .byte   $27                             ; 97B3
        jsr     L1611                           ; 97B4
        jsr     L2711                           ; 97B7
        jsr     L1019                           ; 97BA
        jsr     L2600                           ; 97BD
        jsr     L2811                           ; 97C0
        jsr     L380F                           ; 97C3
        .byte   $2B                             ; 97C6
        plp                                     ; 97C7
        ora     ($20),y                         ; 97C8
        asl     $26,x                           ; 97CA
        jsr     L2606                           ; 97CC
        jsr     L270A                           ; 97CF
        jsr     L2601                           ; 97D2
        rol     $07,x                           ; 97D5
        rol     $3B                             ; 97D7
        ora     ($28,x)                         ; 97D9
        jsr     L270B                           ; 97DB
        jsr     L2A07                           ; 97DE
        jsr     L1B07                           ; 97E1
        jsr     L181B                           ; 97E4
        plp                                     ; 97E7
        clc                                     ; 97E8
        asl     $20,x                           ; 97E9
        php                                     ; 97EB
        .byte   $0F                             ; 97EC
        jsr     L160F                           ; 97ED
        jsr     L1306                           ; 97F0
        jsr     L2813                           ; 97F3
        .byte   $2B                             ; 97F6
        .byte   $1B                             ; 97F7
        ora     ($20),y                         ; 97F8
        .byte   $0B                             ; 97FA
        jsr     L0120                           ; 97FB
        ora     ($20),y                         ; 97FE
        ora     ($27),y                         ; 9800
        jsr     L2706                           ; 9802
        .byte   $0F                             ; 9805
        asl     $00,x                           ; 9806
        and     ($00),y                         ; 9808
        brk                                     ; 980A
        .byte   $37                             ; 980B
        brk                                     ; 980C
        brk                                     ; 980D
        and     $00,y                           ; 980E
        and     $00,x                           ; 9811
        brk                                     ; 9813
        rol     $00,x                           ; 9814
        ora     ($20),y                         ; 9816
        .byte   $0B                             ; 9818
        .byte   $27                             ; 9819
        ora     $1609,y                         ; 981A
        plp                                     ; 981D
        .byte   $0F                             ; 981E
        .byte   $27                             ; 981F
        jsr     L111A                           ; 9820
        .byte   $37                             ; 9823
        rol     $28                             ; 9824
        jsr     L2714                           ; 9826
        .byte   $37                             ; 9829
        .byte   $1C                             ; 982A
        plp                                     ; 982B
        jsr     L2C14                           ; 982C
        .byte   $37                             ; 982F
        asl     $26,x                           ; 9830
        jsr     L1716                           ; 9832
        jsr     L1A14                           ; 9835
        jsr     L0F26                           ; 9838
        .byte   $0F                             ; 983B
        .byte   $0F                             ; 983C
        .byte   $0F                             ; 983D
        .byte   $0F                             ; 983E
        .byte   $0F                             ; 983F
        .byte   $13                             ; 9840
        ora     ($16,x)                         ; 9841
        .byte   $0F                             ; 9843
        .byte   $0F                             ; 9844
        .byte   $0F                             ; 9845
        .byte   $0F                             ; 9846
        .byte   $0F                             ; 9847
        .byte   $0F                             ; 9848
        .byte   $0F                             ; 9849
        .byte   $0F                             ; 984A
        .byte   $0F                             ; 984B
        .byte   $0F                             ; 984C
        .byte   $0F                             ; 984D
        .byte   $0F                             ; 984E
        .byte   $0F                             ; 984F
        .byte   $0F                             ; 9850
        .byte   $0F                             ; 9851
        .byte   $0F                             ; 9852
        .byte   $0F                             ; 9853
        .byte   $0F                             ; 9854
        .byte   $0F                             ; 9855
        .byte   $B2                             ; 9856
        clv                                     ; 9857
        .byte   $B7                             ; 9858
        clv                                     ; 9859
        lda     $BBB8,y                         ; 985A
        clv                                     ; 985D
        ldx     $C2B8,y                         ; 985E
        clv                                     ; 9861
        .byte   $C7                             ; 9862
        clv                                     ; 9863
        cmp     #$B8                            ; 9864
        cpy     $D0B8                           ; 9866
        clv                                     ; 9869
        .byte   $D4                             ; 986A
        clv                                     ; 986B
        .byte   $DA                             ; 986C
        clv                                     ; 986D
        sbc     ($B8,x)                         ; 986E
        nop                                     ; 9870
        clv                                     ; 9871
        sbc     $F0B8                           ; 9872
        clv                                     ; 9875
        .byte   $F3                             ; 9876
        clv                                     ; 9877
L9878:  .byte   $F7                             ; 9878
        clv                                     ; 9879
        sbc     $FCB8,y                         ; 987A
        clv                                     ; 987D
        .byte   $FF                             ; 987E
        clv                                     ; 987F
        ora     ($B9,x)                         ; 9880
        .byte   $03                             ; 9882
        lda     $B907,y                         ; 9883
        .byte   $0B                             ; 9886
        lda     $B90F,y                         ; 9887
        .byte   $14                             ; 988A
        lda     $B918,y                         ; 988B
        .byte   $1A                             ; 988E
        lda     $B91C,y                         ; 988F
        jsr     L23B9                           ; 9892
        lda     $B928,y                         ; 9895
        bit     $33B9                           ; 9898
        lda     $B939,y                         ; 989B
        rti                                     ; 989E

; ----------------------------------------------------------------------------
        lda     $B949,y                         ; 989F
        eor     $4FB9                           ; 98A2
        lda     $B952,y                         ; 98A5
        .byte   $54                             ; 98A8
        lda     $B958,y                         ; 98A9
        .byte   $5A                             ; 98AC
        lda     $B95D,y                         ; 98AD
        rts                                     ; 98B0

; ----------------------------------------------------------------------------
        .byte   $B9                             ; 98B1
L98B2:  bmi     *+56                            ; 98B2
        .byte   $30                             ; 98B4
L98B5:  sec                                     ; 98B5
        lda     $BB30,x                         ; 98B6
        bmi     L9878                           ; 98B9
        bmi     L98FE                           ; 98BB
        ldy     $31,x                           ; 98BD
        bmi     L98F3                           ; 98BF
        tsx                                     ; 98C1
        rol     $3B44,x                         ; 98C2
        .byte   $33                             ; 98C5
        ldy     $B431                           ; 98C6
        and     ($38),y                         ; 98C9
        ldx     $31,y                           ; 98CB
        .byte   $44                             ; 98CD
        .byte   $43                             ; 98CE
        ldy     $3E32                           ; 98CF
        .byte   $3C                             ; 98D2
        ldy     $32,x                           ; 98D3
        .byte   $37                             ; 98D5
        rol     $423E,x                         ; 98D6
        ldy     $32,x                           ; 98D9
        .byte   $37                             ; 98DB
        bmi     L991D                           ; 98DC
        .byte   $43                             ; 98DE
        .byte   $34                             ; 98DF
        cmp     ($32,x)                         ; 98E0
        .byte   $34                             ; 98E2
        .byte   $3B                             ; 98E3
        .byte   $34                             ; 98E4
        .byte   $42                             ; 98E5
        .byte   $43                             ; 98E6
        .byte   $34                             ; 98E7
        eor     ($BD,x)                         ; 98E8
        .byte   $33                             ; 98EA
        bmi     L98B5                           ; 98EB
        .byte   $34                             ; 98ED
L98EE:  bmi     L98B2                           ; 98EE
        and     $3E,x                           ; 98F0
        .byte   $C1                             ; 98F2
L98F3:  .byte   $36                             ; 98F3
L98F4:  bmi     *+62                            ; 98F4
        ldy     $36,x                           ; 98F6
        ldx     $3037,y                         ; 98F8
L98FB:  .byte   $B7                             ; 98FB
        sec                                     ; 98FC
        .byte   $3D                             ; 98FD
L98FE:  ldx     $38,y                           ; 98FE
        .byte   $C2                             ; 9900
        sec                                     ; 9901
        .byte   $C3                             ; 9902
        .byte   $3B                             ; 9903
        sec                                     ; 9904
        .byte   $3A                             ; 9905
        ldy     $3C,x                           ; 9906
        rol     $B445,x                         ; 9908
        .byte   $3C                             ; 990B
        rol     $B441,x                         ; 990C
        .byte   $3C                             ; 990F
        rol     $343D,x                         ; 9910
        iny                                     ; 9913
        and     $4734,x                         ; 9914
        .byte   $C3                             ; 9917
        and     $3EBE,x                         ; 9918
        lda     $3E,x                           ; 991B
L991D:  .byte   $37                             ; 991D
        adc     $3EAC,y                         ; 991E
        .byte   $44                             ; 9921
        .byte   $C3                             ; 9922
        .byte   $3F                             ; 9923
        .byte   $3B                             ; 9924
        bmi     L9959                           ; 9925
        .byte   $B4                             ; 9927
L9928:  .byte   $3F                             ; 9928
        .byte   $3B                             ; 9929
        bmi     L98F4                           ; 992A
        .byte   $3F                             ; 992C
        .byte   $3B                             ; 992D
        .byte   $34                             ; 992E
        bmi     L9973                           ; 992F
        .byte   $34                             ; 9931
        ldy     $4441                           ; 9932
        .byte   $3F                             ; 9935
        sec                                     ; 9936
        bmi     L98FB                           ; 9937
        .byte   $42                             ; 9939
        bmi     L996D                           ; 993A
        bmi     L997F                           ; 993C
        rol     $42BD,x                         ; 993E
        bmi     L997F                           ; 9941
        bmi     L9980                           ; 9943
        .byte   $3A                             ; 9945
        bmi     L9985                           ; 9946
        .byte   $B3                             ; 9948
        .byte   $42                             ; 9949
        .byte   $34                             ; 994A
        .byte   $3B                             ; 994B
        lda     $43,x                           ; 994C
        .byte   $B7                             ; 994E
        .byte   $43                             ; 994F
        .byte   $37                             ; 9950
        ldy     $43,x                           ; 9951
        ldx     $3446,y                         ; 9953
        .byte   $3B                             ; 9956
        .byte   $BB                             ; 9957
        .byte   $42                             ; 9958
L9959:  ldx     $3E48,y                         ; 9959
        cpy     $46                             ; 995C
        bmi     L9928                           ; 995E
        lsr     $3E                             ; 9960
        eor     ($3B,x)                         ; 9962
        .byte   $B3                             ; 9964
        .byte   $B2                             ; 9965
        ldy     #$2C                            ; 9966
        ldx     $94                             ; 9968
        rol     $7C90                           ; 996A
L996D:  rol     $482C                           ; 996D
        .byte   $34                             ; 9970
        .byte   $42                             ; 9971
        .byte   $2E                             ; 9972
L9973:  bit     $2F9B                           ; 9973
        .byte   $B2                             ; 9976
        sta     $2CAB,x                         ; 9977
        .byte   $83                             ; 997A
        rol     $2CAA                           ; 997B
        .byte   $44                             ; 997E
L997F:  .byte   $3D                             ; 997F
L9980:  .byte   $3B                             ; 9980
        .byte   $44                             ; 9981
        .byte   $32                             ; 9982
        .byte   $3A                             ; 9983
        pha                                     ; 9984
L9985:  .byte   $4F                             ; 9985
        rol     $A688                           ; 9986
        sty     $2C,x                           ; 9989
        sty     $2E,x                           ; 998B
        bmi     L99BB                           ; 998D
        .byte   $42                             ; 998F
        .byte   $3F                             ; 9990
        .byte   $34                             ; 9991
        .byte   $32                             ; 9992
        sec                                     ; 9993
        sta     ($2F,x)                         ; 9994
        .byte   $B2                             ; 9996
        sec                                     ; 9997
        jmp     L3B3B                           ; 9998

; ----------------------------------------------------------------------------
        bit     $3732                           ; 999B
        bmi     L99DD                           ; 999E
        rol     $34,x                           ; 99A0
        rol     $2CA7                           ; 99A2
        eor     ($3E,x)                         ; 99A5
        .byte   $44                             ; 99A7
        .byte   $3B                             ; 99A8
        .byte   $34                             ; 99A9
        .byte   $43                             ; 99AA
        .byte   $43                             ; 99AB
        .byte   $34                             ; 99AC
        rol     $4234                           ; 99AD
        .byte   $3F                             ; 99B0
        .byte   $34                             ; 99B1
        .byte   $32                             ; 99B2
        sec                                     ; 99B3
        sta     ($3B,x)                         ; 99B4
        pha                                     ; 99B6
        rol     $2C8F                           ; 99B7
        .byte   $AB                             ; 99BA
L99BB:  .byte   $4F                             ; 99BB
        .byte   $2F                             ; 99BC
        .byte   $B2                             ; 99BD
        lsr     $34                             ; 99BE
        .byte   $3B                             ; 99C0
        .byte   $89                             ; 99C1
        bit     $2EA8                           ; 99C2
        .byte   $A7                             ; 99C5
        bit     $3032                           ; 99C6
        .byte   $42                             ; 99C9
        sec                                     ; 99CA
        .byte   $9B                             ; 99CB
        .byte   $4F                             ; 99CC
        .byte   $2F                             ; 99CD
        .byte   $B2                             ; 99CE
        sta     $4F9B,x                         ; 99CF
        bit     $4C95                           ; 99D2
        .byte   $42                             ; 99D5
        rol     $3D44                           ; 99D6
        bmi     L9A0D                           ; 99D9
        .byte   $32                             ; 99DB
        .byte   $34                             ; 99DC
L99DD:  .byte   $3F                             ; 99DD
        .byte   $43                             ; 99DE
        bmi     L9A12                           ; 99DF
        .byte   $3B                             ; 99E1
        .byte   $34                             ; 99E2
        rol     $2C8F                           ; 99E3
        bmi     L9A14                           ; 99E6
        .byte   $42                             ; 99E8
        bmi     L9A23                           ; 99E9
        and     $2E43,x                         ; 99EB
        tay                                     ; 99EE
        bit     $2C89                           ; 99EF
        tay                                     ; 99F2
        .byte   $2F                             ; 99F3
        .byte   $B2                             ; 99F4
        .byte   $42                             ; 99F5
        .byte   $43                             ; 99F6
        bmi     L9A3A                           ; 99F7
        .byte   $43                             ; 99F9
        .byte   $4F                             ; 99FA
        .byte   $2F                             ; 99FB
        .byte   $B2                             ; 99FC
        sta     $4C95,x                         ; 99FD
        .byte   $42                             ; 9A00
        rol     $3C81                           ; 9A01
        rol     $4342,x                         ; 9A04
        rol     $3B32                           ; 9A07
        rol     L9342,x                         ; 9A0A
L9A0D:  rol     $3843                           ; 9A0D
        .byte   $3C                             ; 9A10
        .byte   $34                             ; 9A11
L9A12:  .byte   $4F                             ; 9A12
        .byte   $2F                             ; 9A13
L9A14:  .byte   $B2                             ; 9A14
        sec                                     ; 9A15
        jmp     L2C3C                           ; 9A16

; ----------------------------------------------------------------------------
        tax                                     ; 9A19
        eor     ($41,x)                         ; 9A1A
        pha                                     ; 9A1C
        adc     L882E,y                         ; 9A1D
        bit     $41AB                           ; 9A20
L9A23:  rol     $2C99                           ; 9A23
        sty     $2C,x                           ; 9A26
        .byte   $9B                             ; 9A28
        .byte   $43                             ; 9A29
        rol     $3D34                           ; 9A2A
        rol     $3644,x                         ; 9A2D
        .byte   $37                             ; 9A30
        bit     $2FA8                           ; 9A31
        .byte   $B2                             ; 9A34
        .byte   $9B                             ; 9A35
        lsr     $2C                             ; 9A36
        .byte   $AB                             ; 9A38
        .byte   $2C                             ; 9A39
L9A3A:  lsr     $38                             ; 9A3A
        .byte   $3B                             ; 9A3C
        .byte   $3B                             ; 9A3D
        rol     $3846                           ; 9A3E
        and     L8E2C,x                         ; 9A41
        sec                                     ; 9A44
        .byte   $3B                             ; 9A45
        pha                                     ; 9A46
        .byte   $4F                             ; 9A47
        rol     $2C8A                           ; 9A48
        .byte   $82                             ; 9A4B
        rol     $3882                           ; 9A4C
        .byte   $3C                             ; 9A4F
        sta     ($2C,x)                         ; 9A50
        .byte   $AB                             ; 9A52
        .byte   $2F                             ; 9A53
        .byte   $B2                             ; 9A54
        rol     $7D3A,x                         ; 9A55
        rol     L89A1                           ; 9A58
        rol     $2C84                           ; 9A5B
        .byte   $80                             ; 9A5E
        .byte   $4F                             ; 9A5F
        .byte   $2F                             ; 9A60
        .byte   $B2                             ; 9A61
        .byte   $A7                             ; 9A62
        and     $2C79,x                         ; 9A63
        txa                                     ; 9A66
        rol     $2C82                           ; 9A67
        .byte   $82                             ; 9A6A
        sec                                     ; 9A6B
        .byte   $3C                             ; 9A6C
        sta     ($2E,x)                         ; 9A6D
        .byte   $AB                             ; 9A6F
        bit     $4F96                           ; 9A70
        .byte   $2F                             ; 9A73
        .byte   $B2                             ; 9A74
        sta     $2CAB,x                         ; 9A75
        .byte   $37                             ; 9A78
        sec                                     ; 9A79
        .byte   $43                             ; 9A7A
        rol     $7D95                           ; 9A7B
        .byte   $2F                             ; 9A7E
        .byte   $B2                             ; 9A7F
        sta     $2CAB,x                         ; 9A80
        .byte   $83                             ; 9A83
        rol     $3D44                           ; 9A84
        .byte   $3B                             ; 9A87
        .byte   $44                             ; 9A88
        .byte   $32                             ; 9A89
        .byte   $3A                             ; 9A8A
        pha                                     ; 9A8B
        .byte   $4F                             ; 9A8C
        .byte   $2F                             ; 9A8D
        .byte   $B2                             ; 9A8E
        sta     $2C79                           ; 9A8F
        tax                                     ; 9A92
        bit     $4C38                           ; 9A93
        .byte   $3B                             ; 9A96
        .byte   $3B                             ; 9A97
        rol     $3836                           ; 9A98
        eor     $34                             ; 9A9B
        bit     $2CAB                           ; 9A9D
        bmi     L9AD0                           ; 9AA0
        .byte   $33                             ; 9AA2
        sty     $32,x                           ; 9AA3
        rol     $3D44,x                         ; 9AA5
        .byte   $43                             ; 9AA8
        .byte   $4F                             ; 9AA9
        .byte   $2F                             ; 9AAA
        .byte   $B2                             ; 9AAB
        lsr     $34                             ; 9AAC
        jmp     L3445                           ; 9AAE

; ----------------------------------------------------------------------------
        bit     $2C30                           ; 9AB1
        .byte   $87                             ; 9AB4
        rol     $3031                           ; 9AB5
        eor     ($36,x)                         ; 9AB8
        bmi     L9AF4                           ; 9ABA
        and     $A82E,x                         ; 9ABC
        sta     $2C4F                           ; 9ABF
        .byte   $34                             ; 9AC2
        and     $3E39,x                         ; 9AC3
        pha                                     ; 9AC6
        rol     $41AB                           ; 9AC7
        lda     $4F                             ; 9ACA
        .byte   $2F                             ; 9ACC
        .byte   $B2                             ; 9ACD
        .byte   $42                             ; 9ACE
        .byte   $44                             ; 9ACF
L9AD0:  .byte   $32                             ; 9AD0
        .byte   $37                             ; 9AD1
        bit     $2E30                           ; 9AD2
        .byte   $9F                             ; 9AD5
        .byte   $4F                             ; 9AD6
        rol     $3BA1                           ; 9AD7
        .byte   $34                             ; 9ADA
        bmi     L9B22                           ; 9ADB
        .byte   $34                             ; 9ADD
        rol     $469B                           ; 9ADE
        .byte   $4F                             ; 9AE1
        .byte   $2F                             ; 9AE2
        .byte   $B2                             ; 9AE3
        .byte   $A7                             ; 9AE4
        bit     $4386                           ; 9AE5
        bit     $2E94                           ; 9AE8
        bit     a:$01                           ; 9AEB
        bit     $4FA2                           ; 9AEE
        rol     L8546                           ; 9AF1
L9AF4:  .byte   $AB                             ; 9AF4
        rol     $2C96                           ; 9AF5
        tay                                     ; 9AF8
        .byte   $2F                             ; 9AF9
        .byte   $FF                             ; 9AFA
        .byte   $B2                             ; 9AFB
        .byte   $32                             ; 9AFC
        sta     $AB                             ; 9AFD
        rol     $32A1                           ; 9AFF
        sta     ($3B,x)                         ; 9B02
        rol     $2C95                           ; 9B04
        bmi     L9B35                           ; 9B07
        sta     $2F7C                           ; 9B09
        .byte   $B2                             ; 9B0C
        ldy     #$2C                            ; 9B0D
        bit     $4290                           ; 9B0F
        .byte   $4F                             ; 9B12
        rol     L89A1                           ; 9B13
        rol     $2C84                           ; 9B16
        .byte   $3B                             ; 9B19
        bmi     L9B5F                           ; 9B1A
        .byte   $34                             ; 9B1C
        eor     ($4F,x)                         ; 9B1D
        .byte   $2F                             ; 9B1F
        .byte   $B2                             ; 9B20
        .byte   $96                             ; 9B21
L9B22:  .byte   $4F                             ; 9B22
        .byte   $2F                             ; 9B23
        and     ($05,x)                         ; 9B24
        .byte   $13                             ; 9B26
        lsr     $30                             ; 9B27
        .byte   $43                             ; 9B29
        .byte   $34                             ; 9B2A
        eor     ($2C,x)                         ; 9B2B
        lda     $3C2C                           ; 9B2D
        rol     $413E,x                         ; 9B30
        .byte   $3E                             ; 9B33
        .byte   $3E                             ; 9B34
L9B35:  and     $0521,x                         ; 9B35
        .byte   $14                             ; 9B38
        .byte   $33                             ; 9B39
        .byte   $34                             ; 9B3A
        .byte   $42                             ; 9B3B
        .byte   $34                             ; 9B3C
        eor     ($43,x)                         ; 9B3D
        bit     $2CAD                           ; 9B3F
        sta     ($81,x)                         ; 9B42
        bmi     L9B87                           ; 9B44
        .byte   $43                             ; 9B46
        and     ($05,x)                         ; 9B47
        asl     $8F,x                           ; 9B49
        .byte   $34                             ; 9B4B
        .byte   $42                             ; 9B4C
        .byte   $43                             ; 9B4D
        bit     $2CAD                           ; 9B4E
        ldy     $21                             ; 9B51
        ora     $16                             ; 9B53
        and     $3B,x                           ; 9B55
        rol     $3446,x                         ; 9B57
        eor     ($2C,x)                         ; 9B5A
        lda     L8C2C                           ; 9B5C
L9B5F:  and     ($05,x)                         ; 9B5F
        ora     $34,x                           ; 9B61
        eor     $38                             ; 9B63
        .byte   $3B                             ; 9B65
        bit     $303C                           ; 9B66
        rol     $38,x                           ; 9B69
        .byte   $32                             ; 9B6B
        sec                                     ; 9B6C
        .byte   $82                             ; 9B6D
        bit     L89A3                           ; 9B6E
        lsr     $37                             ; 9B71
        .byte   $34                             ; 9B73
        eor     ($34,x)                         ; 9B74
        bit     $2C83                           ; 9B76
        lsr     $34                             ; 9B79
        bit     L9391                           ; 9B7B
        bit     $7C9A                           ; 9B7E
        .byte   $2F                             ; 9B81
        txa                                     ; 9B82
        .byte   $3C                             ; 9B83
        bmi     L9BC3                           ; 9B84
        pha                                     ; 9B86
L9B87:  bit     $3435                           ; 9B87
        bmi     L9BCD                           ; 9B8A
        and     $44,x                           ; 9B8C
        .byte   $3B                             ; 9B8E
        bit     $3D34                           ; 9B8F
        .byte   $34                             ; 9B92
        .byte   $3C                             ; 9B93
        sec                                     ; 9B94
        .byte   $34                             ; 9B95
        .byte   $42                             ; 9B96
        bit     $2E83                           ; 9B97
        lsr     $30                             ; 9B9A
        sta     $93,x                           ; 9B9C
        bit     $2C8F                           ; 9B9E
        .byte   $44                             ; 9BA1
        .byte   $42                             ; 9BA2
        .byte   $4F                             ; 9BA3
        .byte   $2F                             ; 9BA4
        sta     ($A7,x)                         ; 9BA5
        eor     ($34,x)                         ; 9BA7
        bit     $2C95                           ; 9BA9
        sty     $7D,x                           ; 9BAC
        bit     $2CA7                           ; 9BAE
        .byte   $33                             ; 9BB1
        .byte   $34                             ; 9BB2
        .byte   $42                             ; 9BB3
        .byte   $34                             ; 9BB4
        eor     ($43,x)                         ; 9BB5
        rol     $2CAD                           ; 9BB7
        sta     ($81,x)                         ; 9BBA
        bmi     L9BFF                           ; 9BBC
        .byte   $43                             ; 9BBE
        .byte   $4F                             ; 9BBF
        .byte   $2F                             ; 9BC0
        .byte   $80                             ; 9BC1
        .byte   $2F                             ; 9BC2
L9BC3:  .byte   $83                             ; 9BC3
        .byte   $37                             ; 9BC4
        .byte   $34                             ; 9BC5
        pha                                     ; 9BC6
        adc     $3B2C,x                         ; 9BC7
        .byte   $34                             ; 9BCA
        .byte   $43                             ; 9BCB
        .byte   $4C                             ; 9BCC
L9BCD:  .byte   $42                             ; 9BCD
        bit     $4437                           ; 9BCE
        eor     ($41,x)                         ; 9BD1
        pha                                     ; 9BD3
        bit     $3F44                           ; 9BD4
        adc     L822F,x                         ; 9BD7
        .byte   $92                             ; 9BDA
        adc     L922C,y                         ; 9BDB
        adc     $382C,x                         ; 9BDE
        jmp     L2C3C                           ; 9BE1

; ----------------------------------------------------------------------------
        and     $30,x                           ; 9BE4
        .byte   $42                             ; 9BE6
        .byte   $43                             ; 9BE7
        .byte   $34                             ; 9BE8
        eor     ($4F,x)                         ; 9BE9
        .byte   $2F                             ; 9BEB
        .byte   $89                             ; 9BEC
        .byte   $32                             ; 9BED
        sta     $AB                             ; 9BEE
        bit     $2C86                           ; 9BF0
        bmi     L9C21                           ; 9BF3
        .byte   $3B                             ; 9BF5
        sta     $43,x                           ; 9BF6
        .byte   $3B                             ; 9BF8
        .byte   $34                             ; 9BF9
        rol     $2C98                           ; 9BFA
        rti                                     ; 9BFD

; ----------------------------------------------------------------------------
        .byte   $44                             ; 9BFE
L9BFF:  sec                                     ; 9BFF
        .byte   $34                             ; 9C00
        .byte   $43                             ; 9C01
        .byte   $7C                             ; 9C02
        .byte   $2F                             ; 9C03
        txa                                     ; 9C04
        lda     #$79                            ; 9C05
        bit     $3E33                           ; 9C07
        and     $434C,x                         ; 9C0A
        bit     $3042                           ; 9C0D
        pha                                     ; 9C10
        bit     $4FAA                           ; 9C11
        .byte   $2F                             ; 9C14
        .byte   $87                             ; 9C15
        .byte   $43                             ; 9C16
        bmi     L9C53                           ; 9C17
        .byte   $34                             ; 9C19
        bit     $2C95                           ; 9C1A
        stx     $4F48                           ; 9C1D
        .byte   $2C                             ; 9C20
L9C21:  sta     $4C,x                           ; 9C21
        .byte   $42                             ; 9C23
        bit     $2C30                           ; 9C24
        .byte   $3B                             ; 9C27
        sta     $43,x                           ; 9C28
        .byte   $3B                             ; 9C2A
        .byte   $34                             ; 9C2B
        rol     $3441                           ; 9C2C
        .byte   $42                             ; 9C2F
        .byte   $43                             ; 9C30
        bit     L8F86                           ; 9C31
        .byte   $34                             ; 9C34
        bit     $2CA7                           ; 9C35
        and     $38,x                           ; 9C38
        rol     $37,x                           ; 9C3A
        .byte   $43                             ; 9C3C
        .byte   $4F                             ; 9C3D
        .byte   $2F                             ; 9C3E
        sta     ($FF,x)                         ; 9C3F
        adc     $A72C,y                         ; 9C41
        bit     $2C9A                           ; 9C44
        .byte   $9F                             ; 9C47
        bit     $2E94                           ; 9C48
        ldy     $4F                             ; 9C4B
        .byte   $2F                             ; 9C4D
        sty     $9D                             ; 9C4E
        ldx     $94                             ; 9C50
        .byte   $2C                             ; 9C52
L9C53:  sty     $2C,x                           ; 9C53
        .byte   $A7                             ; 9C55
        bit     $3686                           ; 9C56
        sec                                     ; 9C59
        and     L933D,x                         ; 9C5A
        rol     $2C9C                           ; 9C5D
        bmi     L9C8E                           ; 9C60
        and     $4634,x                         ; 9C62
        bit     $3330                           ; 9C65
        eor     $34                             ; 9C68
        and     $4443,x                         ; 9C6A
        eor     ($34,x)                         ; 9C6D
        .byte   $4F                             ; 9C6F
        .byte   $2F                             ; 9C70
        stx     $38                             ; 9C71
        bit     $343D                           ; 9C73
        .byte   $34                             ; 9C76
        .byte   $33                             ; 9C77
        bit     a:$01                           ; 9C78
        brk                                     ; 9C7B
        bit     $2C98                           ; 9C7C
        ldx     #$4F                            ; 9C7F
        .byte   $2F                             ; 9C81
L9C82:  .byte   $89                             ; 9C82
        sta     $3E31,x                         ; 9C83
        pha                                     ; 9C86
        adc     $AB2C,x                         ; 9C87
        bit     LAC81                           ; 9C8A
        .byte   $42                             ; 9C8D
L9C8E:  bit     L8143                           ; 9C8E
        .byte   $3A                             ; 9C91
        rol     $3130                           ; 9C92
        .byte   $9E                             ; 9C95
        bit     $4F99                           ; 9C96
        bit     $A842                           ; 9C99
        .byte   $3F                             ; 9C9C
        bit     $7D95                           ; 9C9D
        .byte   $2F                             ; 9CA0
        .byte   $82                             ; 9CA1
        .byte   $AB                             ; 9CA2
        bit     LAC81                           ; 9CA3
        .byte   $42                             ; 9CA6
        bit     $303C                           ; 9CA7
        .byte   $3A                             ; 9CAA
        .byte   $34                             ; 9CAB
        bit     $2C30                           ; 9CAC
L9CAF:  .byte   $87                             ; 9CAF
        rol     $3433                           ; 9CB0
        sta     ($2C,x)                         ; 9CB3
        .byte   $9E                             ; 9CB5
        bit     $2C9C                           ; 9CB6
        .byte   $34                             ; 9CB9
        eor     $34                             ; 9CBA
        eor     ($48,x)                         ; 9CBC
        ldx     $93                             ; 9CBE
        .byte   $4F                             ; 9CC0
        .byte   $2F                             ; 9CC1
        .byte   $83                             ; 9CC2
        .byte   $3C                             ; 9CC3
        bmi     L9D0E                           ; 9CC4
        stx     $2C                             ; 9CC6
        .byte   $42                             ; 9CC8
        .byte   $37                             ; 9CC9
        .byte   $34                             ; 9CCA
        bit     $3032                           ; 9CCB
        and     $432C,x                         ; 9CCE
        sta     ($3A,x)                         ; 9CD1
        rol     $2CA3                           ; 9CD3
        tay                                     ; 9CD6
        bit     $3433                           ; 9CD7
        bmi     L9C82                           ; 9CDA
        .byte   $4F                             ; 9CDC
        .byte   $2F                             ; 9CDD
        txa                                     ; 9CDE
        .byte   $A7                             ; 9CDF
        pha                                     ; 9CE0
        bit     $3042                           ; 9CE1
        pha                                     ; 9CE4
        bit     $2CA3                           ; 9CE5
        sty     $2C,x                           ; 9CE8
        sec                                     ; 9CEA
        and     $A72E,x                         ; 9CEB
        bit     $2C9A                           ; 9CEE
        lda     $2F4F                           ; 9CF1
        .byte   $87                             ; 9CF4
        pha                                     ; 9CF5
        .byte   $34                             ; 9CF6
        .byte   $42                             ; 9CF7
        .byte   $4F                             ; 9CF8
        .byte   $2F                             ; 9CF9
        sta     ($31,x)                         ; 9CFA
        eor     ($30,x)                         ; 9CFC
        .byte   $32                             ; 9CFE
        .byte   $34                             ; 9CFF
        bit     $41AB                           ; 9D00
        lda     $7D                             ; 9D03
        .byte   $2F                             ; 9D05
        txa                                     ; 9D06
        .byte   $9B                             ; 9D07
        lsr     $79                             ; 9D08
        bit     $343B                           ; 9D0A
        .byte   $43                             ; 9D0D
L9D0E:  jmp     L2C42                           ; 9D0E

; ----------------------------------------------------------------------------
        eor     ($34,x)                         ; 9D11
        .byte   $43                             ; 9D13
        .byte   $44                             ; 9D14
        eor     ($3D,x)                         ; 9D15
        bit     $2CA8                           ; 9D17
        .byte   $A7                             ; 9D1A
        rol     $413F                           ; 9D1B
        .byte   $34                             ; 9D1E
        .byte   $42                             ; 9D1F
        .byte   $34                             ; 9D20
        and     $2C43,x                         ; 9D21
        sty     $2F7D                           ; 9D24
        stx     $37                             ; 9D27
        .byte   $34                             ; 9D29
        pha                                     ; 9D2A
        adc     $382C,y                         ; 9D2B
        bit     $3742                           ; 9D2E
        sta     $37                             ; 9D31
        bmi     L9D7A                           ; 9D33
        .byte   $34                             ; 9D35
        bit     $4391                           ; 9D36
        .byte   $43                             ; 9D39
        .byte   $34                             ; 9D3A
        and     $012E,x                         ; 9D3B
        brk                                     ; 9D3E
        brk                                     ; 9D3F
        bit     $2C98                           ; 9D40
        ldx     #$4F                            ; 9D43
        .byte   $2F                             ; 9D45
        .byte   $89                             ; 9D46
        .byte   $3C                             ; 9D47
        .byte   $44                             ; 9D48
        .byte   $42                             ; 9D49
        .byte   $43                             ; 9D4A
        bmi     L9D82                           ; 9D4B
        bmi     L9DCC                           ; 9D4D
        bit     $2C38                           ; 9D4F
        .byte   $42                             ; 9D52
        bmi     L9D8D                           ; 9D53
        .byte   $33                             ; 9D55
        bit     $A842                           ; 9D56
        .byte   $3F                             ; 9D59
        bit     $7D95                           ; 9D5A
        .byte   $2F                             ; 9D5D
        .byte   $82                             ; 9D5E
        lsr     $37                             ; 9D5F
        rol     $3F3E,x                         ; 9D61
        .byte   $34                             ; 9D64
        .byte   $34                             ; 9D65
        adc     L872F,x                         ; 9D66
        .byte   $37                             ; 9D69
        .byte   $34                             ; 9D6A
        pha                                     ; 9D6B
        adc     $332C,x                         ; 9D6C
        rol     $4C3D,x                         ; 9D6F
        .byte   $43                             ; 9D72
        bit     $3E35                           ; 9D73
        rol     $2C3B,x                         ; 9D76
        .byte   $30                             ; 9D79
L9D7A:  eor     ($3E,x)                         ; 9D7A
        .byte   $44                             ; 9D7C
        and     $4F33,x                         ; 9D7D
        .byte   $2F                             ; 9D80
        .byte   $83                             ; 9D81
L9D82:  ldx     $30                             ; 9D82
        .byte   $43                             ; 9D84
        jmp     L2C42                           ; 9D85

; ----------------------------------------------------------------------------
        eor     ($38,x)                         ; 9D88
        rol     $37,x                           ; 9D8A
        .byte   $43                             ; 9D8C
L9D8D:  .byte   $4F                             ; 9D8D
        bit     L94A6                           ; 9D8E
        bit     $3846                           ; 9D91
        .byte   $3B                             ; 9D94
        .byte   $3B                             ; 9D95
        bit     $2E86                           ; 9D96
        .byte   $A7                             ; 9D99
        bit     $3433                           ; 9D9A
        .byte   $32                             ; 9D9D
        sty     $38,x                           ; 9D9E
        eor     $34                             ; 9DA0
        bit     $3031                           ; 9DA2
        .byte   $43                             ; 9DA5
        .byte   $43                             ; 9DA6
        .byte   $3B                             ; 9DA7
        .byte   $34                             ; 9DA8
        .byte   $4F                             ; 9DA9
        .byte   $2F                             ; 9DAA
        sty     $38                             ; 9DAB
        jmp     L2C3C                           ; 9DAD

; ----------------------------------------------------------------------------
        .byte   $43                             ; 9DB0
        eor     ($34,x)                         ; 9DB1
        .byte   $3C                             ; 9DB3
        and     ($3B),y                         ; 9DB4
        .byte   $93                             ; 9DB6
        bit     $3846                           ; 9DB7
        ldx     $2E                             ; 9DBA
        .byte   $34                             ; 9DBC
        .byte   $47                             ; 9DBD
        .byte   $32                             ; 9DBE
        sta     $34,x                           ; 9DBF
        .byte   $3C                             ; 9DC1
        .byte   $34                             ; 9DC2
        and     $7943,x                         ; 9DC3
        bit     $3842                           ; 9DC6
        eor     ($4F,x)                         ; 9DC9
        .byte   $2F                             ; 9DCB
L9DCC:  dey                                     ; 9DCC
        sec                                     ; 9DCD
        jmp     L2C3C                           ; 9DCE

; ----------------------------------------------------------------------------
        .byte   $9B                             ; 9DD1
        .byte   $43                             ; 9DD2
        bit     $3530                           ; 9DD3
        eor     ($30,x)                         ; 9DD6
        sec                                     ; 9DD8
        .byte   $33                             ; 9DD9
        .byte   $4F                             ; 9DDA
        bit     $4C38                           ; 9DDB
        .byte   $3C                             ; 9DDE
        bit     $439B                           ; 9DDF
        rol     $3530                           ; 9DE2
        eor     ($30,x)                         ; 9DE5
        sec                                     ; 9DE7
        .byte   $33                             ; 9DE8
        .byte   $4F                             ; 9DE9
        .byte   $2F                             ; 9DEA
        sta     $95                             ; 9DEB
        jmp     L2C42                           ; 9DED

; ----------------------------------------------------------------------------
        sta     ($3B,x)                         ; 9DF0
        bit     $3841                           ; 9DF2
        rol     $37,x                           ; 9DF5
        .byte   $43                             ; 9DF7
        adc     $412C,y                         ; 9DF8
        bmi     L9E35                           ; 9DFB
        and     $4F48,x                         ; 9DFD
        .byte   $2F                             ; 9E00
        sta     ($A6,x)                         ; 9E01
        sty     $2C,x                           ; 9E03
        lsr     $38                             ; 9E05
        .byte   $3B                             ; 9E07
        .byte   $3B                             ; 9E08
        bit     $2C86                           ; 9E09
        .byte   $A7                             ; 9E0C
        bit     $303B                           ; 9E0D
        .byte   $42                             ; 9E10
        .byte   $43                             ; 9E11
        rol     $3031                           ; 9E12
        .byte   $43                             ; 9E15
        .byte   $43                             ; 9E16
        .byte   $3B                             ; 9E17
        .byte   $34                             ; 9E18
        adc     $FF2C,y                         ; 9E19
        adc     $2F7D,x                         ; 9E1C
        .byte   $34                             ; 9E1F
        adc     $FF2C,y                         ; 9E20
        adc     $2F7D,x                         ; 9E23
        .byte   $42                             ; 9E26
        rol     $62,x                           ; 9E27
        bit     $5D5B                           ; 9E29
        .byte   $3A                             ; 9E2C
        and     $2E,x                           ; 9E2D
        bmi     L9E72                           ; 9E2F
        lsr     L4261                           ; 9E31
        .byte   $31                             ; 9E34
L9E35:  cli                                     ; 9E35
        .byte   $AB                             ; 9E36
        .byte   $6B                             ; 9E37
        rol     $2F                             ; 9E38
        .byte   $80                             ; 9E3A
        .byte   $2F                             ; 9E3B
        sta     ($98,x)                         ; 9E3C
        .byte   $9B                             ; 9E3E
        txs                                     ; 9E3F
        rol     $2CA2                           ; 9E40
        eor     $2F,x                           ; 9E43
        .byte   $82                             ; 9E45
        .byte   $A7                             ; 9E46
        .byte   $27                             ; 9E47
        ldx     $2E                             ; 9E48
        .byte   $62                             ; 9E4A
        bit     $6130                           ; 9E4B
        .byte   $3F                             ; 9E4E
        bit     $6CA5                           ; 9E4F
        .byte   $47                             ; 9E52
        .byte   $2F                             ; 9E53
        .byte   $89                             ; 9E54
        ldx     $49                             ; 9E55
        bit     $5736                           ; 9E57
        rol     $ABAC                           ; 9E5A
        and     L9243,y                         ; 9E5D
        rol     $2F                             ; 9E60
        txa                                     ; 9E62
        .byte   $33                             ; 9E63
        .byte   $33                             ; 9E64
        .byte   $7C                             ; 9E65
        .byte   $9B                             ; 9E66
        pha                                     ; 9E67
        .byte   $34                             ; 9E68
        .byte   $32                             ; 9E69
        .byte   $62                             ; 9E6A
        rol     $5736                           ; 9E6B
        ldy     L4261                           ; 9E6E
        .byte   $7C                             ; 9E71
L9E72:  .byte   $2F                             ; 9E72
        .byte   $83                             ; 9E73
        and     ($4E),y                         ; 9E74
        ror     $5A                             ; 9E76
        .byte   $9B                             ; 9E78
        eor     #$34                            ; 9E79
        .byte   $34                             ; 9E7B
        rol     $5B3A                           ; 9E7C
        .byte   $63                             ; 9E7F
        jmp     (L325A)                         ; 9E80

; ----------------------------------------------------------------------------
        ror     L2F26,x                         ; 9E83
        .byte   $87                             ; 9E86
        eor     #$53                            ; 9E87
        .byte   $37                             ; 9E89
        bit     $6131                           ; 9E8A
        .byte   $42                             ; 9E8D
        .byte   $27                             ; 9E8E
        lda     #$2E                            ; 9E8F
        .byte   $5C                             ; 9E91
        bit     $3C3F                           ; 9E92
        sec                                     ; 9E95
        .byte   $42                             ; 9E96
        .byte   $53                             ; 9E97
        .byte   $5A                             ; 9E98
        .byte   $32                             ; 9E99
        eor     $26,x                           ; 9E9A
        .byte   $2F                             ; 9E9C
        sta     ($98,x)                         ; 9E9D
        sta     $2E9A,x                         ; 9E9F
        .byte   $A3                             ; 9EA2
        bit     $2655                           ; 9EA3
        .byte   $2F                             ; 9EA6
        sty     $A3                             ; 9EA7
        eor     #$2C                            ; 9EA9
        .byte   $43                             ; 9EAB
        .byte   $42                             ; 9EAC
        .byte   $52                             ; 9EAD
        rol     $5936                           ; 9EAE
        and     ($44),y                         ; 9EB1
        lda     $2C                             ; 9EB3
        .byte   $44                             ; 9EB5
        eor     $616C,x                         ; 9EB6
        .byte   $42                             ; 9EB9
        .byte   $7C                             ; 9EBA
        .byte   $2F                             ; 9EBB
        stx     $3E                             ; 9EBC
        eor     $2C52,y                         ; 9EBE
        .byte   $53                             ; 9EC1
        eor     #$57                            ; 9EC2
        .byte   $27                             ; 9EC4
        rol     $489F                           ; 9EC5
        bit     $3B3A                           ; 9EC8
        .byte   $62                             ; 9ECB
        .byte   $47                             ; 9ECC
        and     $26,x                           ; 9ECD
        .byte   $2F                             ; 9ECF
        .byte   $83                             ; 9ED0
        .byte   $A7                             ; 9ED1
        eor     #$2C                            ; 9ED2
        rol     $6C32,x                         ; 9ED4
        adc     ($3F,x)                         ; 9ED7
        rol     $2E                             ; 9ED9
        .byte   $3B                             ; 9EDB
        and     $3B,x                           ; 9EDC
        .byte   $27                             ; 9EDE
        and     ($4E),y                         ; 9EDF
        .byte   $6F                             ; 9EE1
        eor     #$7E                            ; 9EE2
        rol     $2F                             ; 9EE4
        txa                                     ; 9EE6
        tay                                     ; 9EE7
        bit     $484D                           ; 9EE8
        .byte   $34                             ; 9EEB
        pha                                     ; 9EEC
        rol     $684E                           ; 9EED
        eor     $2C62,x                         ; 9EF0
        bmi     L9F4B                           ; 9EF3
        .byte   $5B                             ; 9EF5
        eor     $483F,y                         ; 9EF6
        jmp     (L2F26)                         ; 9EF9

; ----------------------------------------------------------------------------
        .byte   $89                             ; 9EFC
        .byte   $A3                             ; 9EFD
        eor     #$27                            ; 9EFE
        lsr     $5D68                           ; 9F00
        rol     $2C45                           ; 9F03
        .byte   $53                             ; 9F06
        rol     $41,x                           ; 9F07
        .byte   $37                             ; 9F09
        lda     L9248                           ; 9F0A
        rol     $2F                             ; 9F0D
        .byte   $82                             ; 9F0F
        .byte   $9F                             ; 9F10
        adc     ($42,x)                         ; 9F11
        .byte   $27                             ; 9F13
        eor     $435D                           ; 9F14
        eor     $2E                             ; 9F17
        .byte   $5B                             ; 9F19
        cli                                     ; 9F1A
        and     ($53),y                         ; 9F1B
        eor     ($6C,x)                         ; 9F1D
        .byte   $44                             ; 9F1F
        rol     $2F                             ; 9F20
        .byte   $87                             ; 9F22
        .byte   $43                             ; 9F23
        .byte   $45                             ; 9F24
L9F25:  and     $37,x                           ; 9F25
        bit     $2EA3                           ; 9F27
        jmp     L312C                           ; 9F2A

; ----------------------------------------------------------------------------
        adc     ($42,x)                         ; 9F2D
        .byte   $4F                             ; 9F2F
        eor     $32,x                           ; 9F30
        eor     $26,x                           ; 9F32
        .byte   $2F                             ; 9F34
        sta     ($31,x)                         ; 9F35
        eor     $31,x                           ; 9F37
        eor     $2C,x                           ; 9F39
        pha                                     ; 9F3B
        and     $3058,y                         ; 9F3C
        and     ($42),y                         ; 9F3F
        rol     $2749                           ; 9F41
        .byte   $9F                             ; 9F44
        eor     $26,x                           ; 9F45
        .byte   $2F                             ; 9F47
        sta     $9F                             ; 9F48
        .byte   $49                             ; 9F4A
L9F4B:  bit     $3970                           ; 9F4B
        eor     $31                             ; 9F4E
        cli                                     ; 9F50
        rol     $3548                           ; 9F51
        .byte   $44                             ; 9F54
        .byte   $7C                             ; 9F55
        .byte   $2F                             ; 9F56
        dey                                     ; 9F57
        lsr     $2C6C                           ; 9F58
        jmp     (L5259)                         ; 9F5B

; ----------------------------------------------------------------------------
        bit     $2E9F                           ; 9F5E
        eor     $2C                             ; 9F61
        bmi     L9FC6                           ; 9F63
        .byte   $3F                             ; 9F65
        and     $6243,y                         ; 9F66
        .byte   $44                             ; 9F69
        and     ($5D),y                         ; 9F6A
        jmp     (L2F26)                         ; 9F6C

; ----------------------------------------------------------------------------
        stx     $9F                             ; 9F6F
        eor     #$2C                            ; 9F71
        .byte   $44                             ; 9F73
        .byte   $6B                             ; 9F74
        eor     $2E                             ; 9F75
        eor     ($41,x)                         ; 9F77
        lsr     $3F59                           ; 9F79
        bit     $5D68                           ; 9F7C
        .byte   $73                             ; 9F7F
        eor     ($6C,x)                         ; 9F80
        rol     $2F                             ; 9F82
        .byte   $83                             ; 9F84
        .byte   $43                             ; 9F85
        eor     $35                             ; 9F86
        .byte   $37                             ; 9F88
        bit     $5C9F                           ; 9F89
L9F8C:  rol     $623A                           ; 9F8C
        .byte   $3B                             ; 9F8F
        jmp     (L443A)                         ; 9F90

; ----------------------------------------------------------------------------
        sec                                     ; 9F93
        eor     $7E71,y                         ; 9F94
        rol     $2F                             ; 9F97
        .byte   $89                             ; 9F99
        and     $5548,y                         ; 9F9A
        eor     $2C                             ; 9F9D
        jmp     L5B31                           ; 9F9F

; ----------------------------------------------------------------------------
        .byte   $5C                             ; 9FA2
        rol     $3F52                           ; 9FA3
        lsr     $3C,x                           ; 9FA6
        .byte   $3F                             ; 9FA8
        eor     ($45),y                         ; 9FA9
        rol     $2F                             ; 9FAB
        .byte   $82                             ; 9FAD
        tax                                     ; 9FAE
        bit     $5D62                           ; 9FAF
        adc     ($58),y                         ; 9FB2
        .byte   $6B                             ; 9FB4
        adc     L872F,x                         ; 9FB5
        tax                                     ; 9FB8
        jmp     (L4261)                         ; 9FB9

; ----------------------------------------------------------------------------
        adc     L8A2F,x                         ; 9FBC
        .byte   $44                             ; 9FBF
        bmi     LA03D                           ; 9FC0
        eor     $2C                             ; 9FC2
        .byte   $9F                             ; 9FC4
        .byte   $44                             ; 9FC5
L9FC6:  .byte   $6B                             ; 9FC6
        rol     $3E34                           ; 9FC7
        eor     $3958,y                         ; 9FCA
        .byte   $43                             ; 9FCD
        eor     #$44                            ; 9FCE
        and     ($3A),y                         ; 9FD0
        rol     $2F                             ; 9FD2
        sty     $A9                             ; 9FD4
        pha                                     ; 9FD6
        bit     $3540                           ; 9FD7
        lsr     $5C,x                           ; 9FDA
        rol     $5B30                           ; 9FDC
        and     $2742,x                         ; 9FDF
        .byte   $62                             ; 9FE2
        eor     $5A71,x                         ; 9FE3
        .byte   $32                             ; 9FE6
        rol     $2F                             ; 9FE7
        .byte   $FF                             ; 9FE9
        .byte   $FF                             ; 9FEA
        .byte   $FF                             ; 9FEB
        .byte   $FF                             ; 9FEC
        .byte   $FF                             ; 9FED
        .byte   $FF                             ; 9FEE
        .byte   $FF                             ; 9FEF
        lsr     $57                             ; 9FF0
        jmp     LE992                           ; 9FF2

; ----------------------------------------------------------------------------
        ldx     $82                             ; 9FF5
        cpx     #$05                            ; 9FF7
        bcs     L9FFE                           ; 9FF9
        jsr     LE992                           ; 9FFB
L9FFE:  rts                                     ; 9FFE

; ----------------------------------------------------------------------------
        brk                                     ; 9FFF
