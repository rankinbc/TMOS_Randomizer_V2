; ============================================================================
; The Magic of Scheherazade - Bank 05 Disassembly
; ============================================================================
; File Offset: 0x0A000 - 0x0BFFF
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
; Input file: C:/claude-workspace/TMOS_AI/rom-files/disassembly/output/banks/bank_05.bin
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
L000E           := $000E
L00B3           := $00B3
L0416           := $0416
L0500           := $0500
L1E00           := $1E00
PPU_CTRL        := $2000
PPU_MASK        := $2001
PPU_STATUS      := $2002
OAM_ADDR        := $2003
OAM_DATA        := $2004
PPU_SCROLL      := $2005
PPU_ADDR        := $2006
PPU_DATA        := $2007
L32B7           := $32B7
OAM_DMA         := $4014
APU_STATUS      := $4015
JOY1            := $4016
JOY2_FRAME      := $4017
L4D07           := $4D07
L6B03           := $6B03
L7384           := $7384
LA08C           := $A08C
LA0DB           := $A0DB
LA0F0           := $A0F0
LA0FA           := $A0FA
LA107           := $A107
LA195           := $A195
LA1BC           := $A1BC
LA1C2           := $A1C2
LA1E3           := $A1E3
LA1E9           := $A1E9
LA1FA           := $A1FA
LA23D           := $A23D
LA2C5           := $A2C5
LA309           := $A309
LA32E           := $A32E
LA369           := $A369
LA377           := $A377
LA399           := $A399
LA3C3           := $A3C3
LA3CE           := $A3CE
LA3D8           := $A3D8
LA40B           := $A40B
LA40F           := $A40F
LA42C           := $A42C
LA440           := $A440
LA449           := $A449
LA489           := $A489
LA491           := $A491
LA4A7           := $A4A7
LA4CF           := $A4CF
LA4DB           := $A4DB
LA4E7           := $A4E7
LA4F5           := $A4F5
LA4F8           := $A4F8
LA55C           := $A55C
LA573           := $A573
LA59E           := $A59E
LA5CD           := $A5CD
LA5E1           := $A5E1
LA600           := $A600
LA61C           := $A61C
LA67F           := $A67F
LA695           := $A695
LA6A7           := $A6A7
LA6AA           := $A6AA
LA6DD           := $A6DD
LA6F3           := $A6F3
LA70C           := $A70C
LA744           := $A744
LA74A           := $A74A
LA77D           := $A77D
LA7CD           := $A7CD
LA813           := $A813
LA83A           := $A83A
LA846           := $A846
LA854           := $A854
LA893           := $A893
LA897           := $A897
LA8B2           := $A8B2
LA8D6           := $A8D6
LA901           := $A901
LA91A           := $A91A
LA94E           := $A94E
LA981           := $A981
LA98A           := $A98A
LA9DE           := $A9DE
LAA1D           := $AA1D
LAA32           := $AA32
LABF5           := $ABF5
LAC37           := $AC37
LACBD           := $ACBD
LACCC           := $ACCC
LACCD           := $ACCD
LACDA           := $ACDA
LACE6           := $ACE6
LAD08           := $AD08
LB73E           := $B73E
LB779           := $B779
LB799           := $B799
LB7B3           := $B7B3
LB7D3           := $B7D3
LBC06           := $BC06
LBCA4           := $BCA4
LBE81           := $BE81
LBE94           := $BE94
LBED9           := $BED9
LBEEA           := $BEEA
LBF3B           := $BF3B
LBF64           := $BF64
LBF7F           := $BF7F
LBFC8           := $BFC8
LE017           := $E017
LE021           := $E021
LE025           := $E025
LE027           := $E027
LE035           := $E035
LE8C8           := $E8C8
LE8D1           := $E8D1
LE8EF           := $E8EF
LE95B           := $E95B
LE97D           := $E97D
LE992           := $E992
LEAC1           := $EAC1
; ----------------------------------------------------------------------------
        asl     $2C                             ; 8000
        .byte   $8D                             ; 8002
L8003:  sed                                     ; 8003
        asl     $2C                             ; 8004
        sta     L8DFD                           ; 8006
        sed                                     ; 8009
        asl     $2C                             ; 800A
        sta     $06F8                           ; 800C
        bit     $F88D                           ; 800F
        asl     $2C                             ; 8012
        sta     $06F8                           ; 8014
        bit     $FB8D                           ; 8017
        sta     $06F8                           ; 801A
        bit     $F88D                           ; 801D
        asl     $2C                             ; 8020
        sta     $06F8                           ; 8022
        bit     $F88D                           ; 8025
        asl     $2C                             ; 8028
        sta     L8DFD                           ; 802A
        sed                                     ; 802D
        asl     $2C                             ; 802E
        sta     $06F8                           ; 8030
        bit     $F88D                           ; 8033
        asl     $2C                             ; 8036
        sta     $06F8                           ; 8038
        bit     $FB8D                           ; 803B
        .byte   $8F                             ; 803E
        sed                                     ; 803F
        .byte   $1B                             ; 8040
        sty     $FD9F                           ; 8041
        inc     $F88E,x                         ; 8044
        .byte   $0F                             ; 8047
        sty     $FE9E                           ; 8048
        .byte   $8F                             ; 804B
        sed                                     ; 804C
        .byte   $0F                             ; 804D
        sty     $FE9F                           ; 804E
        sta     $3F2C                           ; 8051
        .byte   $44                             ; 8054
        .byte   $43                             ; 8055
        .byte   $43                             ; 8056
        sec                                     ; 8057
        and     $2C36,x                         ; 8058
        rol     $3535,x                         ; 805B
        sed                                     ; 805E
        .byte   $03                             ; 805F
        bit     $FE8D                           ; 8060
        sta     $0FF8                           ; 8063
        bit     $FE8D                           ; 8066
        sta     $F72C                           ; 8069
        cmp     ($04),y                         ; 806C
        .byte   $32                             ; 806E
        rol     $4144,x                         ; 806F
        .byte   $42                             ; 8072
        .byte   $34                             ; 8073
        sta     L8DFE                           ; 8074
        sed                                     ; 8077
        .byte   $0F                             ; 8078
        bit     $FE8D                           ; 8079
        sta     $F72C                           ; 807C
        .byte   $D2                             ; 807F
        .byte   $04                             ; 8080
        .byte   $32                             ; 8081
        rol     $4144,x                         ; 8082
        .byte   $42                             ; 8085
        .byte   $34                             ; 8086
        sta     L8DFE                           ; 8087
        sed                                     ; 808A
        .byte   $0F                             ; 808B
        bit     $FE8D                           ; 808C
        sta     $F72C                           ; 808F
        .byte   $D3                             ; 8092
        .byte   $04                             ; 8093
        .byte   $32                             ; 8094
        rol     $4144,x                         ; 8095
        .byte   $42                             ; 8098
        .byte   $34                             ; 8099
        sta     L8EFE                           ; 809A
        sed                                     ; 809D
        .byte   $0B                             ; 809E
        sty     $FB9E                           ; 809F
        sta     $F52C                           ; 80A2
        .byte   $74                             ; 80A5
        ora     $2C                             ; 80A6
        sta     L8DFD                           ; 80A8
        sed                                     ; 80AB
        .byte   $0B                             ; 80AC
        bit     $FB8D                           ; 80AD
        sta     $F52C                           ; 80B0
        adc     $05,x                           ; 80B3
        bit     $FD8D                           ; 80B5
        sta     $0BF8                           ; 80B8
        bit     $FB8D                           ; 80BB
        sta     $F52C                           ; 80BE
        ror     $05,x                           ; 80C1
        bit     $FD8D                           ; 80C3
        sta     $0BF8                           ; 80C6
        bit     $FB8D                           ; 80C9
        sta     $F52C                           ; 80CC
        .byte   $77                             ; 80CF
        ora     $2C                             ; 80D0
        sta     L8FFD                           ; 80D2
        sed                                     ; 80D5
        .byte   $0B                             ; 80D6
        sty     $FD9F                           ; 80D7
        inc     $E3AD,x                         ; 80DA
        .byte   $04                             ; 80DD
        bit     $04E3                           ; 80DE
        bvs     L80EC                           ; 80E1
        lda     $11                             ; 80E3
        cmp     #$06                            ; 80E5
        beq     L80EC                           ; 80E7
        jsr     LE8EF                           ; 80E9
L80EC:  jsr     LE95B                           ; 80EC
        rts                                     ; 80EF

; ----------------------------------------------------------------------------
        lda     $11                             ; 80F0
        and     #$E7                            ; 80F2
        sta     $11                             ; 80F4
        sta     PPU_MASK                        ; 80F6
        rts                                     ; 80F9

; ----------------------------------------------------------------------------
        lda     $11                             ; 80FA
        ora     #$18                            ; 80FC
        sta     $11                             ; 80FE
        rts                                     ; 8100

; ----------------------------------------------------------------------------
        ldy     #$00                            ; 8101
        sta     $0C                             ; 8103
        sty     $0D                             ; 8105
        lda     #$FF                            ; 8107
        sta     $07                             ; 8109
        sta     $08                             ; 810B
        sta     $09                             ; 810D
        sta     $0A                             ; 810F
L8111:  inc     $07                             ; 8111
        sec                                     ; 8113
        lda     $0C                             ; 8114
        sbc     #$10                            ; 8116
        sta     $0C                             ; 8118
        lda     $0D                             ; 811A
        sbc     #$27                            ; 811C
        sta     $0D                             ; 811E
        bcs     L8111                           ; 8120
        lda     $0C                             ; 8122
        adc     #$10                            ; 8124
        sta     $0C                             ; 8126
        lda     $0D                             ; 8128
        adc     #$27                            ; 812A
        sta     $0D                             ; 812C
L812E:  inc     $08                             ; 812E
        sec                                     ; 8130
        lda     $0C                             ; 8131
        sbc     #$E8                            ; 8133
        sta     $0C                             ; 8135
        lda     $0D                             ; 8137
        sbc     #$03                            ; 8139
        sta     $0D                             ; 813B
        bcs     L812E                           ; 813D
        lda     $0C                             ; 813F
        adc     #$E8                            ; 8141
        sta     $0C                             ; 8143
        lda     $0D                             ; 8145
        adc     #$03                            ; 8147
        sta     $0D                             ; 8149
L814B:  inc     $09                             ; 814B
        sec                                     ; 814D
        lda     $0C                             ; 814E
        sbc     #$64                            ; 8150
        sta     $0C                             ; 8152
        lda     $0D                             ; 8154
        sbc     #$00                            ; 8156
        sta     $0D                             ; 8158
        bcs     L814B                           ; 815A
        lda     $0C                             ; 815C
        adc     #$64                            ; 815E
        sta     $0C                             ; 8160
        lda     $0D                             ; 8162
        adc     #$00                            ; 8164
        sta     $0D                             ; 8166
L8168:  inc     $0A                             ; 8168
        sec                                     ; 816A
        lda     $0C                             ; 816B
        sbc     #$0A                            ; 816D
L816F:  sta     $0C                             ; 816F
        bcs     L8168                           ; 8171
        adc     #$0A                            ; 8173
        sta     $0B                             ; 8175
        rts                                     ; 8177

; ----------------------------------------------------------------------------
        ldy     #$00                            ; 8178
        ldx     #$00                            ; 817A
L817C:  lda     ($00),y                         ; 817C
        sta     $E8,x                           ; 817E
        iny                                     ; 8180
        inx                                     ; 8181
        cpx     #$07                            ; 8182
        bne     L817C                           ; 8184
        rts                                     ; 8186

; ----------------------------------------------------------------------------
        lda     #$FF                            ; 8187
        sta     $18                             ; 8189
L818B:  jsr     LA0DB                           ; 818B
        lda     $18                             ; 818E
        bne     L818B                           ; 8190
        rts                                     ; 8192

; ----------------------------------------------------------------------------
        lda     #$00                            ; 8193
        ldx     #$78                            ; 8195
L8197:  pha                                     ; 8197
        txa                                     ; 8198
        pha                                     ; 8199
        jsr     LA0DB                           ; 819A
        pla                                     ; 819D
        tax                                     ; 819E
        pla                                     ; 819F
        bmi     L81AC                           ; 81A0
        pha                                     ; 81A2
        lda     $C2                             ; 81A3
        and     #$01                            ; 81A5
        bne     L81B0                           ; 81A7
        pla                                     ; 81A9
        bne     L8197                           ; 81AA
L81AC:  dex                                     ; 81AC
        bne     L8197                           ; 81AD
        rts                                     ; 81AF

; ----------------------------------------------------------------------------
L81B0:  pla                                     ; 81B0
        rts                                     ; 81B1

; ----------------------------------------------------------------------------
        sta     $0C                             ; 81B2
        sty     L000E                           ; 81B4
        lda     #$00                            ; 81B6
        sta     $0D                             ; 81B8
        sta     $0F                             ; 81BA
        lda     #$00                            ; 81BC
        sta     $0A                             ; 81BE
        sta     $0B                             ; 81C0
        lda     $0C                             ; 81C2
        ora     $0D                             ; 81C4
        beq     L81E2                           ; 81C6
        lsr     $0D                             ; 81C8
        ror     $0C                             ; 81CA
        bcc     L81DB                           ; 81CC
        lda     L000E                           ; 81CE
        clc                                     ; 81D0
        adc     $0A                             ; 81D1
        sta     $0A                             ; 81D3
        lda     $0F                             ; 81D5
        adc     $0B                             ; 81D7
        sta     $0B                             ; 81D9
L81DB:  asl     L000E                           ; 81DB
        rol     $0F                             ; 81DD
        jmp     LA1C2                           ; 81DF

; ----------------------------------------------------------------------------
L81E2:  rts                                     ; 81E2

; ----------------------------------------------------------------------------
        lda     #$00                            ; 81E3
        sta     $04                             ; 81E5
        sta     $05                             ; 81E7
        ldx     $0162                           ; 81E9
        beq     L81F4                           ; 81EC
        jsr     LA0DB                           ; 81EE
        jmp     LA1E9                           ; 81F1

; ----------------------------------------------------------------------------
L81F4:  inx                                     ; 81F4
        inx                                     ; 81F5
        inx                                     ; 81F6
        stx     $0505                           ; 81F7
        ldy     #$00                            ; 81FA
        lda     ($00),y                         ; 81FC
        ldx     $050C                           ; 81FE
        beq     L820C                           ; 8201
        dec     $050C                           ; 8203
        jsr     LA377                           ; 8206
        jmp     LA1FA                           ; 8209

; ----------------------------------------------------------------------------
L820C:  cmp     #$F8                            ; 820C
        bne     L8221                           ; 820E
        iny                                     ; 8210
        lda     ($00),y                         ; 8211
        sta     $050C                           ; 8213
        iny                                     ; 8216
        lda     ($00),y                         ; 8217
        sta     $06                             ; 8219
        jsr     LA369                           ; 821B
        jmp     LA1FA                           ; 821E

; ----------------------------------------------------------------------------
L8221:  cmp     #$FE                            ; 8221
        bne     L8229                           ; 8223
        jsr     LA369                           ; 8225
        rts                                     ; 8228

; ----------------------------------------------------------------------------
L8229:  cmp     #$FD                            ; 8229
        bne     L8236                           ; 822B
        jsr     LA4F5                           ; 822D
        jsr     LA55C                           ; 8230
        jmp     LA23D                           ; 8233

; ----------------------------------------------------------------------------
L8236:  cmp     #$FB                            ; 8236
        bne     L8249                           ; 8238
        jsr     LA4F5                           ; 823A
        inc     $05                             ; 823D
        jsr     LA399                           ; 823F
        lda     #$00                            ; 8242
        sta     $04                             ; 8244
        jmp     LA1E9                           ; 8246

; ----------------------------------------------------------------------------
L8249:  cmp     #$FA                            ; 8249
        bne     L8260                           ; 824B
        lda     $0502                           ; 824D
        ora     #$01                            ; 8250
        sta     $0502                           ; 8252
        jsr     LA4F5                           ; 8255
        jsr     LA55C                           ; 8258
        inc     $05                             ; 825B
        jmp     LA23D                           ; 825D

; ----------------------------------------------------------------------------
L8260:  cmp     #$F5                            ; 8260
        bne     L8281                           ; 8262
        jsr     LA3C3                           ; 8264
        jsr     LA369                           ; 8267
        lda     #$08                            ; 826A
L826C:  jsr     LA4CF                           ; 826C
        lda     $00                             ; 826F
        pha                                     ; 8271
        lda     $01                             ; 8272
        pha                                     ; 8274
        jsr     LA3CE                           ; 8275
        pla                                     ; 8278
        sta     $01                             ; 8279
        pla                                     ; 827B
        sta     $00                             ; 827C
        jmp     LA1FA                           ; 827E

; ----------------------------------------------------------------------------
L8281:  cmp     #$F6                            ; 8281
        bne     L828F                           ; 8283
        .byte   $20                             ; 8285
        .byte   $C3                             ; 8286
L8287:  .byte   $A3                             ; 8287
        jsr     LA369                           ; 8288
        lda     #$0E                            ; 828B
        bne     L826C                           ; 828D
L828F:  cmp     #$F7                            ; 828F
        bne     L829D                           ; 8291
        jsr     LA3C3                           ; 8293
        jsr     LA369                           ; 8296
        lda     #$07                            ; 8299
        bne     L826C                           ; 829B
L829D:  cmp     #$F3                            ; 829D
        bne     L82B9                           ; 829F
        jsr     LA3C3                           ; 82A1
        jsr     LA369                           ; 82A4
        lda     $00                             ; 82A7
        pha                                     ; 82A9
        lda     $01                             ; 82AA
        pha                                     ; 82AC
        jsr     LA5E1                           ; 82AD
        pla                                     ; 82B0
        sta     $01                             ; 82B1
        pla                                     ; 82B3
        sta     $00                             ; 82B4
        jmp     LA1FA                           ; 82B6

; ----------------------------------------------------------------------------
L82B9:  cmp     #$F2                            ; 82B9
        bne     L82DA                           ; 82BB
        jsr     LA3C3                           ; 82BD
        jsr     LA369                           ; 82C0
        lda     #$04                            ; 82C3
        jsr     LA4CF                           ; 82C5
        lda     $00                             ; 82C8
        pha                                     ; 82CA
        lda     $01                             ; 82CB
        pha                                     ; 82CD
        jsr     LA489                           ; 82CE
        pla                                     ; 82D1
        sta     $01                             ; 82D2
        pla                                     ; 82D4
        sta     $00                             ; 82D5
        jmp     LA1FA                           ; 82D7

; ----------------------------------------------------------------------------
L82DA:  cmp     #$F1                            ; 82DA
        bne     L82E9                           ; 82DC
        jsr     LA3C3                           ; 82DE
        jsr     LA369                           ; 82E1
        lda     #$03                            ; 82E4
        jmp     LA2C5                           ; 82E6

; ----------------------------------------------------------------------------
L82E9:  cmp     #$F0                            ; 82E9
        bne     L82F8                           ; 82EB
        jsr     LA3C3                           ; 82ED
        jsr     LA369                           ; 82F0
        lda     #$02                            ; 82F3
        jmp     LA2C5                           ; 82F5

; ----------------------------------------------------------------------------
L82F8:  cmp     #$7F                            ; 82F8
        bne     L835E                           ; 82FA
        jsr     LA369                           ; 82FC
        jsr     LA600                           ; 82FF
        lda     #$00                            ; 8302
        sta     $04                             ; 8304
        sta     $0502                           ; 8306
        lda     #$7F                            ; 8309
        sta     $06                             ; 830B
        jsr     LA377                           ; 830D
        jsr     LA4F8                           ; 8310
        jsr     LA55C                           ; 8313
        lda     #$00                            ; 8316
        sta     $04                             ; 8318
        lda     $C2                             ; 831A
        and     #$01                            ; 831C
        bne     L8345                           ; 831E
        lda     $1E                             ; 8320
        and     #$10                            ; 8322
        bne     L833A                           ; 8324
        lda     $0502                           ; 8326
        ora     #$80                            ; 8329
        sta     $0502                           ; 832B
        ldx     $0162                           ; 832E
        inx                                     ; 8331
        inx                                     ; 8332
        inx                                     ; 8333
        stx     $0505                           ; 8334
        jmp     LA309                           ; 8337

; ----------------------------------------------------------------------------
L833A:  lda     $0502                           ; 833A
        and     #$7F                            ; 833D
        sta     $0502                           ; 833F
        jmp     LA32E                           ; 8342

; ----------------------------------------------------------------------------
L8345:  lda     $0502                           ; 8345
        and     #$7F                            ; 8348
        sta     $0502                           ; 834A
        iny                                     ; 834D
        jsr     LA573                           ; 834E
        lda     $052A                           ; 8351
        sta     $02                             ; 8354
        lda     $052B                           ; 8356
        sta     $03                             ; 8359
        jmp     LA1E3                           ; 835B

; ----------------------------------------------------------------------------
L835E:  sta     $06                             ; 835E
        jsr     LA369                           ; 8360
        jsr     LA377                           ; 8363
        jmp     LA1FA                           ; 8366

; ----------------------------------------------------------------------------
        iny                                     ; 8369
        tya                                     ; 836A
        clc                                     ; 836B
        adc     $00                             ; 836C
        sta     $00                             ; 836E
        lda     $01                             ; 8370
        adc     #$00                            ; 8372
        sta     $01                             ; 8374
        rts                                     ; 8376

; ----------------------------------------------------------------------------
        ldx     $0505                           ; 8377
        lda     $06                             ; 837A
        bit     $0502                           ; 837C
        bpl     L8383                           ; 837F
        lda     #$2C                            ; 8381
L8383:  sta     $0163,x                         ; 8383
        inx                                     ; 8386
        stx     $0505                           ; 8387
        inc     $04                             ; 838A
        lda     $04                             ; 838C
        cmp     $052C                           ; 838E
        bne     L8398                           ; 8391
        lda     $052C                           ; 8393
        sta     $04                             ; 8396
L8398:  rts                                     ; 8398

; ----------------------------------------------------------------------------
        lda     #$00                            ; 8399
        sta     L000E                           ; 839B
        sta     $0F                             ; 839D
        ldy     $05                             ; 839F
        beq     L83C2                           ; 83A1
L83A3:  lda     L000E                           ; 83A3
        clc                                     ; 83A5
        adc     #$20                            ; 83A6
        sta     L000E                           ; 83A8
        lda     $0F                             ; 83AA
        adc     #$00                            ; 83AC
        sta     $0F                             ; 83AE
        dey                                     ; 83B0
        bne     L83A3                           ; 83B1
        lda     $052A                           ; 83B3
        clc                                     ; 83B6
        adc     L000E                           ; 83B7
        sta     $02                             ; 83B9
        lda     $052B                           ; 83BB
        adc     $0F                             ; 83BE
        sta     $03                             ; 83C0
L83C2:  rts                                     ; 83C2

; ----------------------------------------------------------------------------
        iny                                     ; 83C3
        lda     ($00),y                         ; 83C4
        sta     L000E                           ; 83C6
        iny                                     ; 83C8
        lda     ($00),y                         ; 83C9
        sta     $0F                             ; 83CB
        rts                                     ; 83CD

; ----------------------------------------------------------------------------
        jsr     LA40B                           ; 83CE
        lda     #$FF                            ; 83D1
        sta     $0550,y                         ; 83D3
        ldy     #$00                            ; 83D6
        lda     ($00),y                         ; 83D8
        sta     $06                             ; 83DA
        bmi     L83EC                           ; 83DC
        lda     $0550,y                         ; 83DE
        cmp     #$FF                            ; 83E1
        beq     L83EC                           ; 83E3
        jsr     LA377                           ; 83E5
        iny                                     ; 83E8
        jmp     LA3D8                           ; 83E9

; ----------------------------------------------------------------------------
L83EC:  lda     $06                             ; 83EC
        and     #$7F                            ; 83EE
        sta     $06                             ; 83F0
        jsr     LA377                           ; 83F2
        lda     $0502                           ; 83F5
        lsr     a                               ; 83F8
        bcs     L840A                           ; 83F9
        lda     #$2C                            ; 83FB
        sta     $06                             ; 83FD
L83FF:  iny                                     ; 83FF
        jsr     LA377                           ; 8400
        lda     $0550,y                         ; 8403
        cmp     #$FF                            ; 8406
        bne     L83FF                           ; 8408
L840A:  rts                                     ; 840A

; ----------------------------------------------------------------------------
        ldy     #$00                            ; 840B
        lda     (L000E),y                       ; 840D
        sta     $0A                             ; 840F
        and     #$F0                            ; 8411
        lsr     a                               ; 8413
        lsr     a                               ; 8414
        lsr     a                               ; 8415
        tay                                     ; 8416
        lda     L99B7,y                         ; 8417
        sta     $00                             ; 841A
        lda     L99B8,y                         ; 841C
        sta     $01                             ; 841F
        lda     $0A                             ; 8421
        stx     $0A                             ; 8423
        ldy     #$00                            ; 8425
        and     #$0F                            ; 8427
        tax                                     ; 8429
        beq     L843E                           ; 842A
L842C:  ldy     #$00                            ; 842C
        lda     ($00),y                         ; 842E
        bmi     L8438                           ; 8430
        jsr     LA369                           ; 8432
        jmp     LA42C                           ; 8435

; ----------------------------------------------------------------------------
L8438:  jsr     LA369                           ; 8438
        dex                                     ; 843B
        bne     L842C                           ; 843C
L843E:  ldy     #$00                            ; 843E
        lda     ($00),y                         ; 8440
        bmi     L8448                           ; 8442
        iny                                     ; 8444
        jmp     LA440                           ; 8445

; ----------------------------------------------------------------------------
L8448:  rts                                     ; 8448

; ----------------------------------------------------------------------------
        ldy     #$00                            ; 8449
        ldx     $0A                             ; 844B
        lda     #$08                            ; 844D
        sta     $0A                             ; 844F
L8451:  lda     ($00),y                         ; 8451
        bmi     L845F                           ; 8453
        sta     $0163,x                         ; 8455
        inx                                     ; 8458
        iny                                     ; 8459
        dec     $0A                             ; 845A
        bne     L8451                           ; 845C
L845E:  rts                                     ; 845E

; ----------------------------------------------------------------------------
L845F:  and     #$7F                            ; 845F
        sta     $0163,x                         ; 8461
        inx                                     ; 8464
        dec     $0A                             ; 8465
        beq     L845E                           ; 8467
        lda     #$2C                            ; 8469
L846B:  sta     $0163,x                         ; 846B
        inx                                     ; 846E
        dec     $0A                             ; 846F
        bne     L846B                           ; 8471
        rts                                     ; 8473

; ----------------------------------------------------------------------------
        tay                                     ; 8474
        lda     $00                             ; 8475
        pha                                     ; 8477
        lda     $01                             ; 8478
        pha                                     ; 847A
        tya                                     ; 847B
        jsr     LA40F                           ; 847C
        jsr     LA449                           ; 847F
        pla                                     ; 8482
        sta     $01                             ; 8483
        pla                                     ; 8485
        sta     $00                             ; 8486
        rts                                     ; 8488

; ----------------------------------------------------------------------------
        lda     $0502                           ; 8489
        lsr     a                               ; 848C
        bcs     L84B9                           ; 848D
        ldy     #$00                            ; 848F
        lda     (L000E),y                       ; 8491
        bne     L84A7                           ; 8493
        iny                                     ; 8495
        lda     $0550,y                         ; 8496
        cmp     #$FF                            ; 8499
        beq     L84C7                           ; 849B
        lda     #$2C                            ; 849D
        sta     $06                             ; 849F
        jsr     LA377                           ; 84A1
        jmp     LA491                           ; 84A4

; ----------------------------------------------------------------------------
L84A7:  sta     $06                             ; 84A7
        iny                                     ; 84A9
        jsr     LA377                           ; 84AA
        lda     $0550,y                         ; 84AD
        cmp     #$FF                            ; 84B0
        beq     L84CE                           ; 84B2
        lda     (L000E),y                       ; 84B4
        jmp     LA4A7                           ; 84B6

; ----------------------------------------------------------------------------
L84B9:  ldy     #$00                            ; 84B9
L84BB:  lda     (L000E),y                       ; 84BB
        bne     L84A7                           ; 84BD
        iny                                     ; 84BF
        lda     $0550,y                         ; 84C0
        cmp     #$FF                            ; 84C3
        bne     L84BB                           ; 84C5
L84C7:  lda     #$00                            ; 84C7
        sta     $06                             ; 84C9
        jsr     LA377                           ; 84CB
L84CE:  rts                                     ; 84CE

; ----------------------------------------------------------------------------
        pha                                     ; 84CF
        jsr     LA4DB                           ; 84D0
        pla                                     ; 84D3
        tay                                     ; 84D4
        lda     #$FF                            ; 84D5
        sta     $0550,y                         ; 84D7
        rts                                     ; 84DA

; ----------------------------------------------------------------------------
        jsr     LA4E7                           ; 84DB
        ldy     $052C                           ; 84DE
        lda     #$FF                            ; 84E1
        sta     $0550,y                         ; 84E3
        rts                                     ; 84E6

; ----------------------------------------------------------------------------
        ldy     #$00                            ; 84E7
L84E9:  iny                                     ; 84E9
        tya                                     ; 84EA
        dey                                     ; 84EB
        sta     $0550,y                         ; 84EC
        iny                                     ; 84EF
        cpy     #$10                            ; 84F0
        bne     L84E9                           ; 84F2
        rts                                     ; 84F4

; ----------------------------------------------------------------------------
        jsr     LA369                           ; 84F5
        ldx     $0162                           ; 84F8
        lda     $03                             ; 84FB
        sta     $0163,x                         ; 84FD
L8500:  inx                                     ; 8500
        lda     $02                             ; 8501
        .byte   $9D                             ; 8503
        .byte   $63                             ; 8504
L8505:  ora     ($E8,x)                         ; 8505
        lda     $04                             ; 8507
        sta     $0163,x                         ; 8509
        inx                                     ; 850C
        lda     $0502                           ; 850D
        and     #$01                            ; 8510
        bne     L8520                           ; 8512
        ldx     $0505                           ; 8514
        lda     #$00                            ; 8517
        sta     $0163,x                         ; 8519
        stx     $0162                           ; 851C
        rts                                     ; 851F

; ----------------------------------------------------------------------------
L8520:  ldx     #$00                            ; 8520
L8522:  lda     $A555,x                         ; 8522
        sta     $E8,x                           ; 8525
        inx                                     ; 8527
        cpx     #$07                            ; 8528
        bne     L8522                           ; 852A
        lda     $0522                           ; 852C
        cmp     #$02                            ; 852F
        bne     L8537                           ; 8531
        lda     #$00                            ; 8533
        sta     $EB                             ; 8535
L8537:  ldx     $0162                           ; 8537
        inx                                     ; 853A
        lda     $03                             ; 853B
        sta     $0163,x                         ; 853D
        inx                                     ; 8540
        lda     $02                             ; 8541
        sta     $0163,x                         ; 8543
        inx                                     ; 8546
        ldx     $0505                           ; 8547
        lda     #$2F                            ; 854A
        sta     $0163,x                         ; 854C
        lda     #$00                            ; 854F
        sta     $0162                           ; 8551
        rts                                     ; 8554

; ----------------------------------------------------------------------------
        .byte   $64                             ; 8555
        ora     ($82,x)                         ; 8556
        asl     $01                             ; 8558
        .byte   $1B                             ; 855A
        .byte   $97                             ; 855B
        lda     $0502                           ; 855C
        and     #$01                            ; 855F
        beq     L8567                           ; 8561
        lda     #$FF                            ; 8563
        sta     $18                             ; 8565
L8567:  jsr     LA0DB                           ; 8567
        lda     $18                             ; 856A
        bne     L8567                           ; 856C
        lda     #$00                            ; 856E
        sta     $04                             ; 8570
        rts                                     ; 8572

; ----------------------------------------------------------------------------
        inc     $052C                           ; 8573
        inc     $052D                           ; 8576
        lda     $02                             ; 8579
        pha                                     ; 857B
        lda     $03                             ; 857C
        pha                                     ; 857E
        lda     $04                             ; 857F
        pha                                     ; 8581
        .byte   $A5                             ; 8582
L8583:  ora     $48                             ; 8583
        lda     $052A                           ; 8585
        sta     $02                             ; 8588
        lda     $052B                           ; 858A
        sta     $03                             ; 858D
        lda     #$00                            ; 858F
        sta     $04                             ; 8591
        sta     $05                             ; 8593
        lda     $0502                           ; 8595
        pha                                     ; 8598
        lda     #$80                            ; 8599
        sta     $0502                           ; 859B
        ldx     $0162                           ; 859E
        inx                                     ; 85A1
        inx                                     ; 85A2
        inx                                     ; 85A3
        stx     $0505                           ; 85A4
L85A7:  jsr     LA377                           ; 85A7
        lda     $04                             ; 85AA
        cmp     $052C                           ; 85AC
        bne     L85A7                           ; 85AF
        jsr     LA4F8                           ; 85B1
        jsr     LA55C                           ; 85B4
        inc     $05                             ; 85B7
        jsr     LA399                           ; 85B9
        lda     $05                             ; 85BC
        cmp     $052D                           ; 85BE
        beq     L85CA                           ; 85C1
        lda     #$00                            ; 85C3
        sta     $04                             ; 85C5
        jmp     LA59E                           ; 85C7

; ----------------------------------------------------------------------------
L85CA:  pla                                     ; 85CA
        sta     $0502                           ; 85CB
        pla                                     ; 85CE
        sta     $05                             ; 85CF
        pla                                     ; 85D1
        sta     $04                             ; 85D2
        pla                                     ; 85D4
        sta     $03                             ; 85D5
        pla                                     ; 85D7
        sta     $02                             ; 85D8
        dec     $052C                           ; 85DA
        dec     $052D                           ; 85DD
        rts                                     ; 85E0

; ----------------------------------------------------------------------------
        ldy     #$00                            ; 85E1
        lda     (L000E),y                       ; 85E3
        sta     $0C                             ; 85E5
        iny                                     ; 85E7
        lda     (L000E),y                       ; 85E8
        sta     $0D                             ; 85EA
        jsr     LA107                           ; 85EC
        lda     #$05                            ; 85EF
        jsr     LA4CF                           ; 85F1
        lda     #$07                            ; 85F4
        sta     L000E                           ; 85F6
        lda     #$00                            ; 85F8
        sta     $0F                             ; 85FA
        jsr     LA489                           ; 85FC
        rts                                     ; 85FF

; ----------------------------------------------------------------------------
        lda     $052C                           ; 8600
        sta     $04                             ; 8603
        lda     $052D                           ; 8605
        sta     $05                             ; 8608
        jsr     LA399                           ; 860A
        lda     $02                             ; 860D
        clc                                     ; 860F
        adc     $052C                           ; 8610
        sta     $02                             ; 8613
        lda     $03                             ; 8615
        adc     #$00                            ; 8617
        sta     $03                             ; 8619
        rts                                     ; 861B

; ----------------------------------------------------------------------------
        sta     $0508                           ; 861C
        pha                                     ; 861F
        lda     #$3A                            ; 8620
        sta     $08                             ; 8622
        lda     #$9C                            ; 8624
        sta     $09                             ; 8626
        pla                                     ; 8628
        and     #$7F                            ; 8629
        sta     $0C                             ; 862B
        lda     #$00                            ; 862D
        sta     $0D                             ; 862F
        sta     $0F                             ; 8631
        lda     #$06                            ; 8633
        sta     L000E                           ; 8635
        jsr     LA1BC                           ; 8637
        ldy     $0A                             ; 863A
        ldx     #$00                            ; 863C
L863E:  lda     ($08),y                         ; 863E
        sta     $0528,x                         ; 8640
        sta     $00,x                           ; 8643
        iny                                     ; 8645
        inx                                     ; 8646
        cpx     #$06                            ; 8647
        bne     L863E                           ; 8649
        jsr     LA4DB                           ; 864B
        jsr     LA83A                           ; 864E
        lda     $0508                           ; 8651
        bpl     L8667                           ; 8654
        and     #$7F                            ; 8656
        cmp     #$09                            ; 8658
        bne     L8672                           ; 865A
        lda     #$00                            ; 865C
        jsr     LA61C                           ; 865E
        lda     #$81                            ; 8661
        jsr     LA61C                           ; 8663
        rts                                     ; 8666

; ----------------------------------------------------------------------------
L8667:  lda     #$00                            ; 8667
        sta     $0502                           ; 8669
        lda     $0508                           ; 866C
        jmp     LA67F                           ; 866F

; ----------------------------------------------------------------------------
L8672:  lda     #$80                            ; 8672
        sta     $0502                           ; 8674
        lda     $0508                           ; 8677
        and     #$7F                            ; 867A
        jmp     LA695                           ; 867C

; ----------------------------------------------------------------------------
        and     #$7F                            ; 867F
        cmp     #$02                            ; 8681
        bne     L868B                           ; 8683
        jsr     LA854                           ; 8685
        jmp     LA6A7                           ; 8688

; ----------------------------------------------------------------------------
L868B:  cmp     #$09                            ; 868B
        bne     L8695                           ; 868D
        jsr     LA893                           ; 868F
        jmp     LA77D                           ; 8692

; ----------------------------------------------------------------------------
L8695:  .byte   $C9                             ; 8695
L8696:  .byte   $04                             ; 8696
        bne     L869C                           ; 8697
        jmp     LA77D                           ; 8699

; ----------------------------------------------------------------------------
L869C:  cmp     #$05                            ; 869C
        bne     L86A3                           ; 869E
        jmp     LA77D                           ; 86A0

; ----------------------------------------------------------------------------
L86A3:  cmp     #$0D                            ; 86A3
        beq     L86D7                           ; 86A5
        jsr     LA1E3                           ; 86A7
        lda     #$00                            ; 86AA
        sta     $0502                           ; 86AC
        .byte   $AD                             ; 86AF
L86B0:  php                                     ; 86B0
        ora     $30                             ; 86B1
        .byte   $4F                             ; 86B3
        beq     L8703                           ; 86B4
        cmp     #$06                            ; 86B6
        beq     L8703                           ; 86B8
        cmp     #$0B                            ; 86BA
        beq     L8703                           ; 86BC
        cmp     #$0C                            ; 86BE
        beq     L8703                           ; 86C0
        cmp     #$0F                            ; 86C2
        beq     L8703                           ; 86C4
        cmp     #$07                            ; 86C6
        beq     L8704                           ; 86C8
        jsr     LA8B2                           ; 86CA
        jsr     LE027                           ; 86CD
        cmp     #$FB                            ; 86D0
        bne     L86DD                           ; 86D2
        jmp     LA813                           ; 86D4

; ----------------------------------------------------------------------------
L86D7:  jsr     LA901                           ; 86D7
        jmp     LA77D                           ; 86DA

; ----------------------------------------------------------------------------
L86DD:  sta     $050A                           ; 86DD
        lda     $0508                           ; 86E0
        cmp     #$0E                            ; 86E3
        bne     L86F3                           ; 86E5
        jsr     LA6F3                           ; 86E7
        lda     #$8F                            ; 86EA
        jsr     LA61C                           ; 86EC
        lda     $050A                           ; 86EF
        rts                                     ; 86F2

; ----------------------------------------------------------------------------
L86F3:  pha                                     ; 86F3
        ora     #$80                            ; 86F4
        jsr     LA61C                           ; 86F6
        jsr     LA0DB                           ; 86F9
        pla                                     ; 86FC
        sta     $0508                           ; 86FD
        lda     $050A                           ; 8700
L8703:  rts                                     ; 8703

; ----------------------------------------------------------------------------
L8704:  lda     #$00                            ; 8704
        sta     $050C                           ; 8706
        jsr     LA74A                           ; 8709
L870C:  jsr     LA0DB                           ; 870C
        lda     $C2                             ; 870F
        tax                                     ; 8711
        lsr     a                               ; 8712
        bcc     L8720                           ; 8713
        lda     #$7D                            ; 8715
        jsr     LE992                           ; 8717
        lda     $050C                           ; 871A
L871D:  jmp     LA6DD                           ; 871D

; ----------------------------------------------------------------------------
L8720:  lsr     a                               ; 8720
        lda     #$FF                            ; 8721
        bcs     L871D                           ; 8723
        txa                                     ; 8725
        and     #$10                            ; 8726
        beq     L8735                           ; 8728
        ldx     $050C                           ; 872A
        beq     L870C                           ; 872D
        dec     $050C                           ; 872F
        jmp     LA744                           ; 8732

; ----------------------------------------------------------------------------
L8735:  txa                                     ; 8735
        and     #$20                            ; 8736
        beq     L870C                           ; 8738
        ldx     $050C                           ; 873A
        cpx     #$02                            ; 873D
        beq     L870C                           ; 873F
        inc     $050C                           ; 8741
        jsr     LA74A                           ; 8744
        jmp     LA70C                           ; 8747

; ----------------------------------------------------------------------------
        ldx     $0162                           ; 874A
        ldy     #$00                            ; 874D
L874F:  lda     $A76D,y                         ; 874F
        sta     $0163,x                         ; 8752
        inx                                     ; 8755
        iny                                     ; 8756
        cpy     #$0D                            ; 8757
        bne     L874F                           ; 8759
        stx     $0162                           ; 875B
        sec                                     ; 875E
        txa                                     ; 875F
        ldy     $050C                           ; 8760
        sbc     $A77A,y                         ; 8763
        tax                                     ; 8766
        lda     #$7A                            ; 8767
        sta     $0163,x                         ; 8769
        rts                                     ; 876C

; ----------------------------------------------------------------------------
        and     ($AE,x)                         ; 876D
        .byte   $89                             ; 876F
        bit     $2C2C                           ; 8770
        bit     $2C2C                           ; 8773
        bit     $2C2C                           ; 8776
        brk                                     ; 8779
        asl     a                               ; 877A
        asl     $02                             ; 877B
L877D:  ldy     #$00                            ; 877D
        lda     ($00),y                         ; 877F
        pha                                     ; 8781
        jsr     LA369                           ; 8782
        pla                                     ; 8785
        cmp     #$FE                            ; 8786
        bne     L877D                           ; 8788
        lda     $00                             ; 878A
        sta     $051A                           ; 878C
        lda     $01                             ; 878F
        sta     $051B                           ; 8791
L8794:  ldy     #$00                            ; 8794
        lda     ($00),y                         ; 8796
        pha                                     ; 8798
        jsr     LA369                           ; 8799
        pla                                     ; 879C
        cmp     #$FE                            ; 879D
        bne     L8794                           ; 879F
        lda     $00                             ; 87A1
        sta     $0518                           ; 87A3
        lda     $01                             ; 87A6
        sta     $0519                           ; 87A8
        lda     $0528                           ; 87AB
        sta     $00                             ; 87AE
        lda     $0529                           ; 87B0
        sta     $01                             ; 87B3
        jsr     LA1E3                           ; 87B5
        jsr     LA4F8                           ; 87B8
        .byte   $20                             ; 87BB
L87BC:  .byte   $5C                             ; 87BC
L87BD:  .byte   $A5                             ; 87BD
L87BE:  inc     $05                             ; 87BE
        jsr     LA399                           ; 87C0
        lda     $0518                           ; 87C3
        sta     $00                             ; 87C6
        lda     $0519                           ; 87C8
        sta     $01                             ; 87CB
L87CD:  jsr     LA1E9                           ; 87CD
        jsr     LA4F8                           ; 87D0
        lda     #$00                            ; 87D3
        sta     $04                             ; 87D5
        inc     $05                             ; 87D7
        jsr     LA399                           ; 87D9
        ldy     $05                             ; 87DC
        lda     $0560,y                         ; 87DE
        cmp     #$FF                            ; 87E1
        beq     L87F2                           ; 87E3
        tya                                     ; 87E5
        lsr     a                               ; 87E6
        bcs     L87CD                           ; 87E7
        jsr     LA4F8                           ; 87E9
        jsr     LA55C                           ; 87EC
        jmp     LA7CD                           ; 87EF

; ----------------------------------------------------------------------------
L87F2:  jsr     LA4F8                           ; 87F2
        jsr     LA55C                           ; 87F5
        lda     $051A                           ; 87F8
        sta     $00                             ; 87FB
        lda     $051B                           ; 87FD
        sta     $01                             ; 8800
        jsr     LA1E3                           ; 8802
        jsr     LA4F8                           ; 8805
        jsr     LA55C                           ; 8808
        inc     $05                             ; 880B
        jsr     LA399                           ; 880D
        jmp     LA6AA                           ; 8810

; ----------------------------------------------------------------------------
        lda     $0508                           ; 8813
        sta     $0509                           ; 8816
        jsr     LE035                           ; 8819
        jsr     LE025                           ; 881C
        lda     $04E6                           ; 881F
        jsr     LA91A                           ; 8822
        lda     $0509                           ; 8825
        sta     $0508                           ; 8828
        jmp     LA61C                           ; 882B

; ----------------------------------------------------------------------------
        pha                                     ; 882E
        jsr     LA83A                           ; 882F
        pla                                     ; 8832
        tay                                     ; 8833
        lda     #$FF                            ; 8834
        sta     $0560,y                         ; 8836
        rts                                     ; 8839

; ----------------------------------------------------------------------------
        jsr     LA846                           ; 883A
        ldy     $052D                           ; 883D
        lda     #$FF                            ; 8840
        sta     $0560,y                         ; 8842
        rts                                     ; 8845

; ----------------------------------------------------------------------------
        ldy     #$00                            ; 8846
L8848:  iny                                     ; 8848
        tya                                     ; 8849
        dey                                     ; 884A
        sta     $0560,y                         ; 884B
        iny                                     ; 884E
        cpy     #$10                            ; 884F
        bne     L8848                           ; 8851
        rts                                     ; 8853

; ----------------------------------------------------------------------------
        lda     $04E1                           ; 8854
        asl     a                               ; 8857
        asl     a                               ; 8858
        tay                                     ; 8859
        ldx     #$00                            ; 885A
L885C:  lda     $A870,y                         ; 885C
        sta     $0540,x                         ; 885F
        iny                                     ; 8862
        inx                                     ; 8863
        cpx     #$04                            ; 8864
        bne     L885C                           ; 8866
        ldy     #$0D                            ; 8868
        lda     $FF                             ; 886A
        sta     $0550,y                         ; 886C
        rts                                     ; 886F

; ----------------------------------------------------------------------------
        .byte   $33                             ; 8870
        .byte   $34                             ; 8871
        bpl     L88C7                           ; 8872
        .byte   $33                             ; 8874
        .byte   $34                             ; 8875
        .byte   $52                             ; 8876
        eor     ($33),y                         ; 8877
        .byte   $34                             ; 8879
        .byte   $52                             ; 887A
        eor     ($52),y                         ; 887B
        bpl     L88D2                           ; 887D
        ora     ($33),y                         ; 887F
        .byte   $34                             ; 8881
        .byte   $52                             ; 8882
        cli                                     ; 8883
        .byte   $33                             ; 8884
        .byte   $34                             ; 8885
        .byte   $52                             ; 8886
        eor     ($33),y                         ; 8887
        .byte   $34                             ; 8889
        .byte   $52                             ; 888A
        eor     ($52),y                         ; 888B
        bpl     L88E2                           ; 888D
        ora     ($20),y                         ; 888F
        lsr     $A8                             ; 8891
        ldx     #$FF                            ; 8893
        ldy     #$00                            ; 8895
L8897:  inx                                     ; 8897
        cpx     #$0B                            ; 8898
        beq     L88AB                           ; 889A
        lda     $0335,x                         ; 889C
        beq     L8897                           ; 889F
        txa                                     ; 88A1
        ora     #$90                            ; 88A2
        sta     $0540,y                         ; 88A4
        iny                                     ; 88A7
        jmp     LA897                           ; 88A8

; ----------------------------------------------------------------------------
L88AB:  lda     #$FF                            ; 88AB
        iny                                     ; 88AD
        sta     $0560,y                         ; 88AE
        rts                                     ; 88B1

; ----------------------------------------------------------------------------
        lda     $0508                           ; 88B2
        and     #$7F                            ; 88B5
        tay                                     ; 88B7
        cpy     #$09                            ; 88B8
        beq     L88C6                           ; 88BA
        cpy     #$0D                            ; 88BC
        beq     L88E0                           ; 88BE
        lda     $A8F1,y                         ; 88C0
        jmp     LA8D6                           ; 88C3

; ----------------------------------------------------------------------------
L88C6:  .byte   $A0                             ; 88C6
L88C7:  brk                                     ; 88C7
L88C8:  lda     $0560,y                         ; 88C8
        iny                                     ; 88CB
        cmp     #$FF                            ; 88CC
        bne     L88C8                           ; 88CE
        dey                                     ; 88D0
        dey                                     ; 88D1
L88D2:  dey                                     ; 88D2
        tya                                     ; 88D3
        ora     #$10                            ; 88D4
        ldy     $0522                           ; 88D6
        cpy     #$01                            ; 88D9
        beq     L88DF                           ; 88DB
        ora     #$40                            ; 88DD
L88DF:  rts                                     ; 88DF

; ----------------------------------------------------------------------------
L88E0:  ldy     #$00                            ; 88E0
L88E2:  lda     $0560,y                         ; 88E2
        iny                                     ; 88E5
        cmp     #$FF                            ; 88E6
        bne     L88E2                           ; 88E8
        sec                                     ; 88EA
        tya                                     ; 88EB
        sbc     #$06                            ; 88EC
        jmp     LA8D6                           ; 88EE

; ----------------------------------------------------------------------------
        brk                                     ; 88F1
        .byte   $03                             ; 88F2
        .byte   $03                             ; 88F3
        .byte   $02                             ; 88F4
        .byte   $02                             ; 88F5
        .byte   $03                             ; 88F6
        brk                                     ; 88F7
        .byte   $02                             ; 88F8
        .byte   $03                             ; 88F9
        .byte   $1A                             ; 88FA
        ora     ($00,x)                         ; 88FB
        brk                                     ; 88FD
        .byte   $03                             ; 88FE
        .byte   $03                             ; 88FF
        brk                                     ; 8900
        ldx     #$FF                            ; 8901
        ldy     #$00                            ; 8903
L8905:  iny                                     ; 8905
        iny                                     ; 8906
        inx                                     ; 8907
        cpx     #$04                            ; 8908
        beq     L8913                           ; 890A
        lda     $04D1,x                         ; 890C
        beq     L8913                           ; 890F
        bne     L8905                           ; 8911
L8913:  lda     #$FF                            ; 8913
        iny                                     ; 8915
        sta     $0560,y                         ; 8916
        rts                                     ; 8919

; ----------------------------------------------------------------------------
        sta     $04E6                           ; 891A
        ldx     #$0F                            ; 891D
L891F:  lda     $05F0,x                         ; 891F
        sta     $0400,x                         ; 8922
        dex                                     ; 8925
        bpl     L891F                           ; 8926
        lda     $0501                           ; 8928
        bpl     L8933                           ; 892B
        jsr     LA9DE                           ; 892D
        jmp     LA94E                           ; 8930

; ----------------------------------------------------------------------------
L8933:  and     #$0F                            ; 8933
        asl     a                               ; 8935
        asl     a                               ; 8936
        tay                                     ; 8937
        ldx     #$00                            ; 8938
L893A:  lda     $A9CA,y                         ; 893A
        sta     $052A,x                         ; 893D
        sta     $02,x                           ; 8940
        iny                                     ; 8942
L8943:  inx                                     ; 8943
        cpx     #$04                            ; 8944
        bne     L893A                           ; 8946
        jsr     LA573                           ; 8948
        jsr     LA9DE                           ; 894B
        lda     $01                             ; 894E
        bmi     L8955                           ; 8950
        jsr     LA98A                           ; 8952
L8955:  lda     #$01                            ; 8955
        sta     $0502                           ; 8957
        lda     $00                             ; 895A
        sta     $0528                           ; 895C
        lda     $01                             ; 895F
        sta     $0529                           ; 8961
        lda     $0501                           ; 8964
        bmi     L89C3                           ; 8967
        lda     $052A                           ; 8969
        sta     $02                             ; 896C
        lda     $052B                           ; 896E
        sta     $03                             ; 8971
        jsr     LA1E3                           ; 8973
        ldx     #$0F                            ; 8976
L8978:  lda     $0400,x                         ; 8978
        sta     $05F0,x                         ; 897B
        dex                                     ; 897E
        bpl     L8978                           ; 897F
        lda     #$00                            ; 8981
        sta     $0162                           ; 8983
        sta     $0163                           ; 8986
        rts                                     ; 8989

; ----------------------------------------------------------------------------
        lda     $1C                             ; 898A
        ora     #$02                            ; 898C
        sta     $1C                             ; 898E
        jsr     LA0DB                           ; 8990
        lda     $00                             ; 8993
        sta     $EB                             ; 8995
        lda     $01                             ; 8997
        sta     $EC                             ; 8999
        lda     #$80                            ; 899B
        sta     $E8                             ; 899D
        sta     $00                             ; 899F
        lda     #$05                            ; 89A1
        sta     $E9                             ; 89A3
        sta     $01                             ; 89A5
        lda     #$80                            ; 89A7
        sta     $EA                             ; 89A9
        lda     #$15                            ; 89AB
        sta     $ED                             ; 89AD
        lda     $01                             ; 89AF
        and     #$10                            ; 89B1
        beq     L89B9                           ; 89B3
        lda     #$16                            ; 89B5
        sta     $ED                             ; 89B7
L89B9:  jsr     LE8D1                           ; 89B9
        lda     $1C                             ; 89BC
        and     #$FD                            ; 89BE
        sta     $1C                             ; 89C0
        rts                                     ; 89C2

; ----------------------------------------------------------------------------
L89C3:  jsr     LA1E9                           ; 89C3
        nop                                     ; 89C6
        jmp     LA981                           ; 89C7

; ----------------------------------------------------------------------------
        sty     $20                             ; 89CA
        clc                                     ; 89CC
        asl     $64                             ; 89CD
        and     ($16,x)                         ; 89CF
        asl     $C4                             ; 89D1
        and     ($18,x)                         ; 89D3
        asl     $C6                             ; 89D5
        jsr     L0416                           ; 89D7
        sty     $20                             ; 89DA
        .byte   $17                             ; 89DC
        asl     $AD                             ; 89DD
        jsr     L8505                           ; 89DF
        brk                                     ; 89E2
        lda     $0521                           ; 89E3
        sta     $01                             ; 89E6
        lda     $04E6                           ; 89E8
        asl     a                               ; 89EB
        tay                                     ; 89EC
        bcc     L89FC                           ; 89ED
        lda     $00                             ; 89EF
        clc                                     ; 89F1
        adc     #$00                            ; 89F2
        sta     $00                             ; 89F4
        lda     $01                             ; 89F6
        adc     #$01                            ; 89F8
        sta     $01                             ; 89FA
L89FC:  lda     ($00),y                         ; 89FC
        pha                                     ; 89FE
        iny                                     ; 89FF
        lda     ($00),y                         ; 8A00
        sta     $01                             ; 8A02
        pla                                     ; 8A04
        sta     $00                             ; 8A05
        rts                                     ; 8A07

; ----------------------------------------------------------------------------
        lda     #$00                            ; 8A08
        jsr     LE97D                           ; 8A0A
        ora     a:$AA,x                         ; 8A0D
        brk                                     ; 8A10
        brk                                     ; 8A11
        brk                                     ; 8A12
        brk                                     ; 8A13
        brk                                     ; 8A14
        brk                                     ; 8A15
        brk                                     ; 8A16
        brk                                     ; 8A17
        brk                                     ; 8A18
        brk                                     ; 8A19
        brk                                     ; 8A1A
        brk                                     ; 8A1B
        brk                                     ; 8A1C
        ldy     #$00                            ; 8A1D
        lda     ($CE),y                         ; 8A1F
        asl     a                               ; 8A21
        tax                                     ; 8A22
        lda     $AC9D,x                         ; 8A23
        sta     L000E                           ; 8A26
        lda     $AC9E,x                         ; 8A28
        sta     $0F                             ; 8A2B
        jsr     LACCC                           ; 8A2D
        ldy     #$00                            ; 8A30
L8A32:  jmp     (L000E)                         ; 8A32

; ----------------------------------------------------------------------------
        jsr     LACDA                           ; 8A35
        lda     L000E                           ; 8A38
        ora     $0F                             ; 8A3A
        bne     L8A32                           ; 8A3C
        rts                                     ; 8A3E

; ----------------------------------------------------------------------------
        ldx     #$01                            ; 8A3F
        jsr     LACBD                           ; 8A41
        lda     $04D0                           ; 8A44
        sta     $0526                           ; 8A47
        jsr     LE992                           ; 8A4A
        jmp     LAA1D                           ; 8A4D

; ----------------------------------------------------------------------------
        lda     #$01                            ; 8A50
        jsr     LACBD                           ; 8A52
        lda     $04D0                           ; 8A55
        jsr     LE8C8                           ; 8A58
        jmp     LAA1D                           ; 8A5B

; ----------------------------------------------------------------------------
        lda     ($CE),y                         ; 8A5E
        pha                                     ; 8A60
        iny                                     ; 8A61
        lda     ($CE),y                         ; 8A62
        sta     $CF                             ; 8A64
        pla                                     ; 8A66
        sta     $CE                             ; 8A67
        jmp     LAA1D                           ; 8A69

; ----------------------------------------------------------------------------
        jsr     LACDA                           ; 8A6C
        jsr     LACCC                           ; 8A6F
        jsr     LAA32                           ; 8A72
        jmp     LAA1D                           ; 8A75

; ----------------------------------------------------------------------------
        ldx     #$02                            ; 8A78
        jsr     LACBD                           ; 8A7A
        lda     $04D0                           ; 8A7D
        jsr     LACE6                           ; 8A80
L8A83:  lda     $04D0                           ; 8A83
        and     #$1F                            ; 8A86
        tay                                     ; 8A88
        lda     $04D1                           ; 8A89
        sta     (L000E),y                       ; 8A8C
        jmp     LAA1D                           ; 8A8E

; ----------------------------------------------------------------------------
        ldx     #$03                            ; 8A91
        jsr     LACBD                           ; 8A93
        lda     $04D2                           ; 8A96
        and     #$08                            ; 8A99
        beq     L8AA2                           ; 8A9B
        jsr     LA0F0                           ; 8A9D
        bne     L8AA5                           ; 8AA0
L8AA2:  jsr     LA0FA                           ; 8AA2
L8AA5:  lda     $04D0                           ; 8AA5
        sta     $E8                             ; 8AA8
        lda     $04D1                           ; 8AAA
        sta     $E9                             ; 8AAD
        lda     $04D2                           ; 8AAF
        and     #$87                            ; 8AB2
        sta     $EA                             ; 8AB4
        lda     #$06                            ; 8AB6
        sta     $EB                             ; 8AB8
        lda     #$01                            ; 8ABA
        sta     $EC                             ; 8ABC
        lda     $04D2                           ; 8ABE
        and     #$70                            ; 8AC1
        lsr     a                               ; 8AC3
        lsr     a                               ; 8AC4
        lsr     a                               ; 8AC5
        tax                                     ; 8AC6
        lda     $AC74,x                         ; 8AC7
        sta     $ED                             ; 8ACA
        lda     $AC75,x                         ; 8ACC
        sta     $EE                             ; 8ACF
        lda     #$FF                            ; 8AD1
        sta     $18                             ; 8AD3
L8AD5:  jsr     LA0DB                           ; 8AD5
        lda     $18                             ; 8AD8
        bne     L8AD5                           ; 8ADA
        jmp     LAA1D                           ; 8ADC

; ----------------------------------------------------------------------------
        ldx     #$01                            ; 8ADF
        jsr     LACBD                           ; 8AE1
        lda     $04D0                           ; 8AE4
        jsr     LA91A                           ; 8AE7
        jmp     LAA1D                           ; 8AEA

; ----------------------------------------------------------------------------
        ldx     #$02                            ; 8AED
        jsr     LACBD                           ; 8AEF
        lda     #$0A                            ; 8AF2
        jsr     LA61C                           ; 8AF4
        beq     L8B03                           ; 8AF7
        lda     $04D0                           ; 8AF9
        sta     $CE                             ; 8AFC
        .byte   $AD                             ; 8AFE
        .byte   $D1                             ; 8AFF
L8B00:  .byte   $04                             ; 8B00
        sta     $CF                             ; 8B01
L8B03:  jmp     LAA1D                           ; 8B03

; ----------------------------------------------------------------------------
        ldx     #$07                            ; 8B06
        jsr     LACBD                           ; 8B08
        lda     $04D0                           ; 8B0B
        jsr     LACE6                           ; 8B0E
        lda     $04D0                           ; 8B11
        and     #$1F                            ; 8B14
        tay                                     ; 8B16
        lda     (L000E),y                       ; 8B17
        cmp     $04D1                           ; 8B19
        bcc     L8B4E                           ; 8B1C
        beq     L8B37                           ; 8B1E
        lda     $04D2                           ; 8B20
        and     #$04                            ; 8B23
        beq     L8B2A                           ; 8B25
        jsr     LAD08                           ; 8B27
L8B2A:  lda     $04D3                           ; 8B2A
        sta     $CE                             ; 8B2D
        lda     $04D4                           ; 8B2F
        sta     $CF                             ; 8B32
        jmp     LAA1D                           ; 8B34

; ----------------------------------------------------------------------------
L8B37:  lda     $04D2                           ; 8B37
        and     #$02                            ; 8B3A
        beq     L8B41                           ; 8B3C
        jsr     LAD08                           ; 8B3E
L8B41:  lda     $04D5                           ; 8B41
        sta     $CE                             ; 8B44
        lda     $04D6                           ; 8B46
        sta     $CF                             ; 8B49
        jmp     LAA1D                           ; 8B4B

; ----------------------------------------------------------------------------
L8B4E:  lda     $04D2                           ; 8B4E
        and     #$01                            ; 8B51
        beq     L8B58                           ; 8B53
        jsr     LAD08                           ; 8B55
L8B58:  jmp     LAA1D                           ; 8B58

; ----------------------------------------------------------------------------
        ldx     #$02                            ; 8B5B
        jsr     LACBD                           ; 8B5D
        lda     $04D0                           ; 8B60
        sta     $0523                           ; 8B63
        cmp     #$06                            ; 8B66
        bne     L8B6F                           ; 8B68
        ldx     #$33                            ; 8B6A
        stx     $0524                           ; 8B6C
L8B6F:  cmp     #$07                            ; 8B6F
        bne     L8B78                           ; 8B71
        ldx     #$2D                            ; 8B73
        stx     $0524                           ; 8B75
L8B78:  jsr     LE025                           ; 8B78
        lda     $04D1                           ; 8B7B
        jsr     LA91A                           ; 8B7E
        jmp     LAA1D                           ; 8B81

; ----------------------------------------------------------------------------
        ldx     #$03                            ; 8B84
        jsr     LACBD                           ; 8B86
        lda     #$00                            ; 8B89
        sta     $08                             ; 8B8B
        ldx     #$07                            ; 8B8D
        lda     #$2C                            ; 8B8F
L8B91:  sta     $00,x                           ; 8B91
        dex                                     ; 8B93
        bpl     L8B91                           ; 8B94
        lda     #$30                            ; 8B96
        sta     $00                             ; 8B98
L8B9A:  jsr     LA0DB                           ; 8B9A
        lda     $C2                             ; 8B9D
        lsr     a                               ; 8B9F
        bcc     L8BB9                           ; 8BA0
        lda     #$00                            ; 8BA2
        sta     $1E                             ; 8BA4
        jsr     LAC37                           ; 8BA6
        ldx     $08                             ; 8BA9
        cpx     #$07                            ; 8BAB
        beq     L8B9A                           ; 8BAD
        inx                                     ; 8BAF
        lda     #$30                            ; 8BB0
        sta     $00,x                           ; 8BB2
        stx     $08                             ; 8BB4
        jmp     LABF5                           ; 8BB6

; ----------------------------------------------------------------------------
L8BB9:  lsr     a                               ; 8BB9
        bcc     L8BD1                           ; 8BBA
        lda     #$04                            ; 8BBC
        sta     $1E                             ; 8BBE
        jsr     LAC37                           ; 8BC0
        ldx     $08                             ; 8BC3
        beq     L8B9A                           ; 8BC5
        lda     #$2C                            ; 8BC7
        sta     $00,x                           ; 8BC9
        dex                                     ; 8BCB
        stx     $08                             ; 8BCC
        jmp     LABF5                           ; 8BCE

; ----------------------------------------------------------------------------
L8BD1:  lda     $C2                             ; 8BD1
        ldx     $08                             ; 8BD3
        and     #$10                            ; 8BD5
        beq     L8BE4                           ; 8BD7
        ldy     $00,x                           ; 8BD9
        dey                                     ; 8BDB
        cpy     #$30                            ; 8BDC
        bcs     L8BE2                           ; 8BDE
        ldy     #$49                            ; 8BE0
L8BE2:  sty     $00,x                           ; 8BE2
L8BE4:  lda     $C2                             ; 8BE4
        and     #$20                            ; 8BE6
        beq     L8BF5                           ; 8BE8
        ldy     $00,x                           ; 8BEA
        iny                                     ; 8BEC
        cpy     #$4A                            ; 8BED
        bcc     L8BF3                           ; 8BEF
        ldy     #$30                            ; 8BF1
L8BF3:  sty     $00,x                           ; 8BF3
L8BF5:  jsr     LAC37                           ; 8BF5
        lda     $08                             ; 8BF8
        cmp     #$07                            ; 8BFA
        bne     L8B9A                           ; 8BFC
        jsr     LA573                           ; 8BFE
        lda     $04D0                           ; 8C01
        asl     a                               ; 8C04
        asl     a                               ; 8C05
        asl     a                               ; 8C06
        tay                                     ; 8C07
        ldx     #$00                            ; 8C08
L8C0A:  lda     $AC27,y                         ; 8C0A
        cmp     $00,x                           ; 8C0D
        bne     L8C1A                           ; 8C0F
        iny                                     ; 8C11
        inx                                     ; 8C12
        cpx     #$07                            ; 8C13
        bne     L8C0A                           ; 8C15
        jmp     LAA1D                           ; 8C17

; ----------------------------------------------------------------------------
L8C1A:  lda     $04D1                           ; 8C1A
        sta     $CE                             ; 8C1D
        lda     $04D2                           ; 8C1F
        sta     $CF                             ; 8C22
        jmp     LAA1D                           ; 8C24

; ----------------------------------------------------------------------------
        .byte   $32                             ; 8C27
        .byte   $37                             ; 8C28
        rol     $3E32,x                         ; 8C29
        .byte   $3B                             ; 8C2C
        bmi     L8C5B                           ; 8C2D
        .byte   $32                             ; 8C2F
        rol     $3E41,x                         ; 8C30
        and     $3048,x                         ; 8C33
        bit     $1EA5                           ; 8C36
        and     #$03                            ; 8C39
        bne     L8C73                           ; 8C3B
        ldx     $0162                           ; 8C3D
        clc                                     ; 8C40
        lda     #$EC                            ; 8C41
        adc     $08                             ; 8C43
        sta     $0164,x                         ; 8C45
        lda     #$20                            ; 8C48
        adc     #$00                            ; 8C4A
        .byte   $9D                             ; 8C4C
L8C4D:  .byte   $63                             ; 8C4D
        ora     ($E8,x)                         ; 8C4E
        inx                                     ; 8C50
        lda     #$01                            ; 8C51
        sta     $0163,x                         ; 8C53
        inx                                     ; 8C56
        lda     #$2C                            ; 8C57
        .byte   $9D                             ; 8C59
        .byte   $63                             ; 8C5A
L8C5B:  ora     ($A5,x)                         ; 8C5B
        asl     $0429,x                         ; 8C5D
        bne     L8C6A                           ; 8C60
        ldy     $08                             ; 8C62
        lda     $00,y                           ; 8C64
        sta     $0163,x                         ; 8C67
L8C6A:  inx                                     ; 8C6A
        lda     #$00                            ; 8C6B
        sta     $0163,x                         ; 8C6D
        stx     $0162                           ; 8C70
L8C73:  rts                                     ; 8C73

; ----------------------------------------------------------------------------
        .byte   $1B                             ; 8C74
        .byte   $97                             ; 8C75
        brk                                     ; 8C76
        brk                                     ; 8C77
        brk                                     ; 8C78
        brk                                     ; 8C79
        brk                                     ; 8C7A
        brk                                     ; 8C7B
        ldx     #$02                            ; 8C7C
        jsr     LACBD                           ; 8C7E
        lda     $CE                             ; 8C81
        pha                                     ; 8C83
        lda     $CF                             ; 8C84
        pha                                     ; 8C86
        lda     $04D0                           ; 8C87
        sta     $CE                             ; 8C8A
        lda     $04D1                           ; 8C8C
        sta     $CF                             ; 8C8F
        jmp     LAA1D                           ; 8C91

; ----------------------------------------------------------------------------
        pla                                     ; 8C94
        sta     $CF                             ; 8C95
        pla                                     ; 8C97
        sta     $CE                             ; 8C98
        jmp     LAA1D                           ; 8C9A

; ----------------------------------------------------------------------------
        and     $AA,x                           ; 8C9D
        .byte   $3F                             ; 8C9F
        tax                                     ; 8CA0
        bvc     L8C4D                           ; 8CA1
        lsr     $6CAA,x                         ; 8CA3
        tax                                     ; 8CA6
        sei                                     ; 8CA7
        tax                                     ; 8CA8
        sta     ($AA),y                         ; 8CA9
        .byte   $DF                             ; 8CAB
        tax                                     ; 8CAC
        sbc     $06AA                           ; 8CAD
        .byte   $AB                             ; 8CB0
        .byte   $5B                             ; 8CB1
        .byte   $AB                             ; 8CB2
        sty     $AB                             ; 8CB3
        .byte   $7C                             ; 8CB5
        ldy     $AC94                           ; 8CB6
        brk                                     ; 8CB9
        brk                                     ; 8CBA
        ora     $A0AA,x                         ; 8CBB
        brk                                     ; 8CBE
L8CBF:  lda     ($CE),y                         ; 8CBF
        sta     $04D0,y                         ; 8CC1
        iny                                     ; 8CC4
        dex                                     ; 8CC5
        bne     L8CBF                           ; 8CC6
        jsr     LACCD                           ; 8CC8
        rts                                     ; 8CCB

; ----------------------------------------------------------------------------
        iny                                     ; 8CCC
        tya                                     ; 8CCD
        clc                                     ; 8CCE
        adc     $CE                             ; 8CCF
        sta     $CE                             ; 8CD1
        lda     $CF                             ; 8CD3
        adc     #$00                            ; 8CD5
        sta     $CF                             ; 8CD7
        rts                                     ; 8CD9

; ----------------------------------------------------------------------------
        ldy     #$00                            ; 8CDA
        lda     ($CE),y                         ; 8CDC
        sta     L000E                           ; 8CDE
        iny                                     ; 8CE0
        lda     ($CE),y                         ; 8CE1
        sta     $0F                             ; 8CE3
        rts                                     ; 8CE5

; ----------------------------------------------------------------------------
        and     #$E0                            ; 8CE6
        lsr     a                               ; 8CE8
        lsr     a                               ; 8CE9
        lsr     a                               ; 8CEA
        lsr     a                               ; 8CEB
        tax                                     ; 8CEC
        lda     $ACF8,x                         ; 8CED
        sta     L000E                           ; 8CF0
        lda     $ACF9,x                         ; 8CF2
        sta     $0F                             ; 8CF5
        rts                                     ; 8CF7

; ----------------------------------------------------------------------------
        ldy     #$00                            ; 8CF8
        brk                                     ; 8CFA
        .byte   $03                             ; 8CFB
        jsr     L8003                           ; 8CFC
        brk                                     ; 8CFF
L8D00:  .byte   $80                             ; 8D00
        .byte   $04                             ; 8D01
        cpx     #$03                            ; 8D02
        brk                                     ; 8D04
        brk                                     ; 8D05
        brk                                     ; 8D06
        brk                                     ; 8D07
        lda     $04D1                           ; 8D08
        sta     (L000E),y                       ; 8D0B
        rts                                     ; 8D0D

; ----------------------------------------------------------------------------
        brk                                     ; 8D0E
        brk                                     ; 8D0F
        brk                                     ; 8D10
        brk                                     ; 8D11
        brk                                     ; 8D12
        brk                                     ; 8D13
        brk                                     ; 8D14
        brk                                     ; 8D15
        brk                                     ; 8D16
        brk                                     ; 8D17
        brk                                     ; 8D18
        brk                                     ; 8D19
        brk                                     ; 8D1A
        brk                                     ; 8D1B
        brk                                     ; 8D1C
        brk                                     ; 8D1D
        brk                                     ; 8D1E
        brk                                     ; 8D1F
        brk                                     ; 8D20
        brk                                     ; 8D21
        brk                                     ; 8D22
        brk                                     ; 8D23
        brk                                     ; 8D24
        brk                                     ; 8D25
        brk                                     ; 8D26
        brk                                     ; 8D27
        brk                                     ; 8D28
        brk                                     ; 8D29
        brk                                     ; 8D2A
        brk                                     ; 8D2B
        brk                                     ; 8D2C
        brk                                     ; 8D2D
        brk                                     ; 8D2E
        brk                                     ; 8D2F
        brk                                     ; 8D30
        brk                                     ; 8D31
        brk                                     ; 8D32
        brk                                     ; 8D33
        brk                                     ; 8D34
        brk                                     ; 8D35
        brk                                     ; 8D36
        brk                                     ; 8D37
        brk                                     ; 8D38
        brk                                     ; 8D39
        brk                                     ; 8D3A
        brk                                     ; 8D3B
        brk                                     ; 8D3C
        brk                                     ; 8D3D
        brk                                     ; 8D3E
        brk                                     ; 8D3F
        brk                                     ; 8D40
        brk                                     ; 8D41
        brk                                     ; 8D42
        brk                                     ; 8D43
        brk                                     ; 8D44
        brk                                     ; 8D45
        brk                                     ; 8D46
        brk                                     ; 8D47
        brk                                     ; 8D48
        brk                                     ; 8D49
        brk                                     ; 8D4A
        brk                                     ; 8D4B
        brk                                     ; 8D4C
        brk                                     ; 8D4D
        brk                                     ; 8D4E
        brk                                     ; 8D4F
        brk                                     ; 8D50
        brk                                     ; 8D51
        brk                                     ; 8D52
        brk                                     ; 8D53
        brk                                     ; 8D54
        brk                                     ; 8D55
        brk                                     ; 8D56
        brk                                     ; 8D57
        brk                                     ; 8D58
        brk                                     ; 8D59
        brk                                     ; 8D5A
        brk                                     ; 8D5B
        brk                                     ; 8D5C
        brk                                     ; 8D5D
        brk                                     ; 8D5E
        brk                                     ; 8D5F
        brk                                     ; 8D60
        brk                                     ; 8D61
        brk                                     ; 8D62
        brk                                     ; 8D63
        brk                                     ; 8D64
        brk                                     ; 8D65
        brk                                     ; 8D66
        brk                                     ; 8D67
        brk                                     ; 8D68
        brk                                     ; 8D69
        brk                                     ; 8D6A
        brk                                     ; 8D6B
        brk                                     ; 8D6C
        brk                                     ; 8D6D
        brk                                     ; 8D6E
        brk                                     ; 8D6F
        brk                                     ; 8D70
        brk                                     ; 8D71
        brk                                     ; 8D72
        brk                                     ; 8D73
        brk                                     ; 8D74
        brk                                     ; 8D75
        brk                                     ; 8D76
        brk                                     ; 8D77
        brk                                     ; 8D78
        brk                                     ; 8D79
        brk                                     ; 8D7A
        brk                                     ; 8D7B
        brk                                     ; 8D7C
        brk                                     ; 8D7D
        brk                                     ; 8D7E
        brk                                     ; 8D7F
        brk                                     ; 8D80
        brk                                     ; 8D81
        brk                                     ; 8D82
        brk                                     ; 8D83
        brk                                     ; 8D84
        brk                                     ; 8D85
        brk                                     ; 8D86
        brk                                     ; 8D87
        brk                                     ; 8D88
        brk                                     ; 8D89
        brk                                     ; 8D8A
        brk                                     ; 8D8B
        brk                                     ; 8D8C
        brk                                     ; 8D8D
        brk                                     ; 8D8E
        brk                                     ; 8D8F
        brk                                     ; 8D90
        brk                                     ; 8D91
        brk                                     ; 8D92
        brk                                     ; 8D93
        brk                                     ; 8D94
        brk                                     ; 8D95
        brk                                     ; 8D96
        brk                                     ; 8D97
        brk                                     ; 8D98
        brk                                     ; 8D99
        brk                                     ; 8D9A
        brk                                     ; 8D9B
        brk                                     ; 8D9C
        brk                                     ; 8D9D
        brk                                     ; 8D9E
        brk                                     ; 8D9F
        brk                                     ; 8DA0
        brk                                     ; 8DA1
        brk                                     ; 8DA2
        brk                                     ; 8DA3
        brk                                     ; 8DA4
        brk                                     ; 8DA5
        brk                                     ; 8DA6
        brk                                     ; 8DA7
        brk                                     ; 8DA8
        brk                                     ; 8DA9
        brk                                     ; 8DAA
        brk                                     ; 8DAB
        brk                                     ; 8DAC
        brk                                     ; 8DAD
        brk                                     ; 8DAE
        brk                                     ; 8DAF
L8DB0:  brk                                     ; 8DB0
        brk                                     ; 8DB1
        brk                                     ; 8DB2
        brk                                     ; 8DB3
        brk                                     ; 8DB4
        brk                                     ; 8DB5
        brk                                     ; 8DB6
        brk                                     ; 8DB7
        brk                                     ; 8DB8
        brk                                     ; 8DB9
        brk                                     ; 8DBA
        brk                                     ; 8DBB
        brk                                     ; 8DBC
        brk                                     ; 8DBD
        brk                                     ; 8DBE
        brk                                     ; 8DBF
        brk                                     ; 8DC0
        brk                                     ; 8DC1
        brk                                     ; 8DC2
        brk                                     ; 8DC3
        brk                                     ; 8DC4
        brk                                     ; 8DC5
        brk                                     ; 8DC6
        brk                                     ; 8DC7
        brk                                     ; 8DC8
        brk                                     ; 8DC9
        brk                                     ; 8DCA
        brk                                     ; 8DCB
        brk                                     ; 8DCC
        brk                                     ; 8DCD
        brk                                     ; 8DCE
        brk                                     ; 8DCF
        brk                                     ; 8DD0
        brk                                     ; 8DD1
        brk                                     ; 8DD2
        brk                                     ; 8DD3
        brk                                     ; 8DD4
        brk                                     ; 8DD5
        brk                                     ; 8DD6
        brk                                     ; 8DD7
        brk                                     ; 8DD8
        brk                                     ; 8DD9
        brk                                     ; 8DDA
        brk                                     ; 8DDB
        brk                                     ; 8DDC
        brk                                     ; 8DDD
        brk                                     ; 8DDE
        brk                                     ; 8DDF
        brk                                     ; 8DE0
        brk                                     ; 8DE1
        brk                                     ; 8DE2
        brk                                     ; 8DE3
        brk                                     ; 8DE4
        brk                                     ; 8DE5
        brk                                     ; 8DE6
        brk                                     ; 8DE7
        brk                                     ; 8DE8
        brk                                     ; 8DE9
        brk                                     ; 8DEA
        brk                                     ; 8DEB
        brk                                     ; 8DEC
        brk                                     ; 8DED
        brk                                     ; 8DEE
        brk                                     ; 8DEF
        brk                                     ; 8DF0
        brk                                     ; 8DF1
        brk                                     ; 8DF2
        brk                                     ; 8DF3
        brk                                     ; 8DF4
        brk                                     ; 8DF5
        brk                                     ; 8DF6
        brk                                     ; 8DF7
        brk                                     ; 8DF8
        brk                                     ; 8DF9
        brk                                     ; 8DFA
L8DFB:  brk                                     ; 8DFB
        brk                                     ; 8DFC
L8DFD:  brk                                     ; 8DFD
L8DFE:  brk                                     ; 8DFE
        brk                                     ; 8DFF
        brk                                     ; 8E00
        brk                                     ; 8E01
        brk                                     ; 8E02
        brk                                     ; 8E03
        brk                                     ; 8E04
        brk                                     ; 8E05
        brk                                     ; 8E06
        brk                                     ; 8E07
        brk                                     ; 8E08
        brk                                     ; 8E09
        brk                                     ; 8E0A
        brk                                     ; 8E0B
        brk                                     ; 8E0C
        brk                                     ; 8E0D
        brk                                     ; 8E0E
        brk                                     ; 8E0F
        brk                                     ; 8E10
        brk                                     ; 8E11
        brk                                     ; 8E12
        brk                                     ; 8E13
        brk                                     ; 8E14
        brk                                     ; 8E15
        brk                                     ; 8E16
        brk                                     ; 8E17
        brk                                     ; 8E18
        brk                                     ; 8E19
        brk                                     ; 8E1A
        brk                                     ; 8E1B
        brk                                     ; 8E1C
        brk                                     ; 8E1D
        brk                                     ; 8E1E
        brk                                     ; 8E1F
        brk                                     ; 8E20
        brk                                     ; 8E21
        brk                                     ; 8E22
        brk                                     ; 8E23
        brk                                     ; 8E24
        brk                                     ; 8E25
        brk                                     ; 8E26
        brk                                     ; 8E27
        brk                                     ; 8E28
        brk                                     ; 8E29
        brk                                     ; 8E2A
        brk                                     ; 8E2B
        brk                                     ; 8E2C
        brk                                     ; 8E2D
        brk                                     ; 8E2E
        brk                                     ; 8E2F
        brk                                     ; 8E30
        brk                                     ; 8E31
        brk                                     ; 8E32
        brk                                     ; 8E33
        brk                                     ; 8E34
        brk                                     ; 8E35
        brk                                     ; 8E36
        brk                                     ; 8E37
        brk                                     ; 8E38
        brk                                     ; 8E39
        brk                                     ; 8E3A
        brk                                     ; 8E3B
        brk                                     ; 8E3C
        brk                                     ; 8E3D
        brk                                     ; 8E3E
        brk                                     ; 8E3F
        brk                                     ; 8E40
        brk                                     ; 8E41
        brk                                     ; 8E42
        brk                                     ; 8E43
        brk                                     ; 8E44
        brk                                     ; 8E45
        brk                                     ; 8E46
        brk                                     ; 8E47
        brk                                     ; 8E48
        brk                                     ; 8E49
        brk                                     ; 8E4A
        brk                                     ; 8E4B
        brk                                     ; 8E4C
        brk                                     ; 8E4D
        brk                                     ; 8E4E
        brk                                     ; 8E4F
        brk                                     ; 8E50
        brk                                     ; 8E51
        brk                                     ; 8E52
        brk                                     ; 8E53
        brk                                     ; 8E54
        brk                                     ; 8E55
        brk                                     ; 8E56
        brk                                     ; 8E57
        brk                                     ; 8E58
        brk                                     ; 8E59
        brk                                     ; 8E5A
        brk                                     ; 8E5B
        brk                                     ; 8E5C
        brk                                     ; 8E5D
        brk                                     ; 8E5E
        brk                                     ; 8E5F
        brk                                     ; 8E60
        brk                                     ; 8E61
        brk                                     ; 8E62
        brk                                     ; 8E63
        brk                                     ; 8E64
        brk                                     ; 8E65
        brk                                     ; 8E66
        brk                                     ; 8E67
        brk                                     ; 8E68
        brk                                     ; 8E69
        brk                                     ; 8E6A
        brk                                     ; 8E6B
        brk                                     ; 8E6C
        brk                                     ; 8E6D
        brk                                     ; 8E6E
        brk                                     ; 8E6F
        brk                                     ; 8E70
        brk                                     ; 8E71
        brk                                     ; 8E72
        brk                                     ; 8E73
        brk                                     ; 8E74
        brk                                     ; 8E75
        brk                                     ; 8E76
        brk                                     ; 8E77
        brk                                     ; 8E78
        brk                                     ; 8E79
        brk                                     ; 8E7A
        brk                                     ; 8E7B
        brk                                     ; 8E7C
        brk                                     ; 8E7D
        brk                                     ; 8E7E
        brk                                     ; 8E7F
        brk                                     ; 8E80
        brk                                     ; 8E81
        brk                                     ; 8E82
        brk                                     ; 8E83
        brk                                     ; 8E84
        brk                                     ; 8E85
        brk                                     ; 8E86
        brk                                     ; 8E87
        brk                                     ; 8E88
        brk                                     ; 8E89
        brk                                     ; 8E8A
        brk                                     ; 8E8B
        brk                                     ; 8E8C
        brk                                     ; 8E8D
        brk                                     ; 8E8E
        brk                                     ; 8E8F
        brk                                     ; 8E90
        brk                                     ; 8E91
        brk                                     ; 8E92
        brk                                     ; 8E93
        brk                                     ; 8E94
        brk                                     ; 8E95
        brk                                     ; 8E96
        brk                                     ; 8E97
        brk                                     ; 8E98
        brk                                     ; 8E99
        brk                                     ; 8E9A
        brk                                     ; 8E9B
        brk                                     ; 8E9C
        brk                                     ; 8E9D
        brk                                     ; 8E9E
        brk                                     ; 8E9F
        brk                                     ; 8EA0
        brk                                     ; 8EA1
        brk                                     ; 8EA2
        brk                                     ; 8EA3
        brk                                     ; 8EA4
        brk                                     ; 8EA5
        brk                                     ; 8EA6
        brk                                     ; 8EA7
        brk                                     ; 8EA8
        brk                                     ; 8EA9
        brk                                     ; 8EAA
        brk                                     ; 8EAB
        brk                                     ; 8EAC
        brk                                     ; 8EAD
        brk                                     ; 8EAE
        brk                                     ; 8EAF
        brk                                     ; 8EB0
        brk                                     ; 8EB1
        brk                                     ; 8EB2
        brk                                     ; 8EB3
        brk                                     ; 8EB4
        brk                                     ; 8EB5
        brk                                     ; 8EB6
        brk                                     ; 8EB7
        brk                                     ; 8EB8
        brk                                     ; 8EB9
        brk                                     ; 8EBA
        brk                                     ; 8EBB
        brk                                     ; 8EBC
        brk                                     ; 8EBD
        brk                                     ; 8EBE
        brk                                     ; 8EBF
        brk                                     ; 8EC0
        brk                                     ; 8EC1
        brk                                     ; 8EC2
        brk                                     ; 8EC3
        brk                                     ; 8EC4
        brk                                     ; 8EC5
        brk                                     ; 8EC6
        brk                                     ; 8EC7
        brk                                     ; 8EC8
        brk                                     ; 8EC9
        brk                                     ; 8ECA
        brk                                     ; 8ECB
        brk                                     ; 8ECC
        brk                                     ; 8ECD
        brk                                     ; 8ECE
        brk                                     ; 8ECF
        brk                                     ; 8ED0
        brk                                     ; 8ED1
        brk                                     ; 8ED2
        brk                                     ; 8ED3
        brk                                     ; 8ED4
        brk                                     ; 8ED5
        brk                                     ; 8ED6
        brk                                     ; 8ED7
        brk                                     ; 8ED8
        brk                                     ; 8ED9
        brk                                     ; 8EDA
        brk                                     ; 8EDB
        brk                                     ; 8EDC
        brk                                     ; 8EDD
        brk                                     ; 8EDE
        brk                                     ; 8EDF
        brk                                     ; 8EE0
        brk                                     ; 8EE1
        brk                                     ; 8EE2
        brk                                     ; 8EE3
        brk                                     ; 8EE4
        brk                                     ; 8EE5
        brk                                     ; 8EE6
        brk                                     ; 8EE7
        brk                                     ; 8EE8
        brk                                     ; 8EE9
        brk                                     ; 8EEA
        brk                                     ; 8EEB
        brk                                     ; 8EEC
        brk                                     ; 8EED
        brk                                     ; 8EEE
        brk                                     ; 8EEF
        brk                                     ; 8EF0
        brk                                     ; 8EF1
        brk                                     ; 8EF2
        brk                                     ; 8EF3
        brk                                     ; 8EF4
        brk                                     ; 8EF5
        brk                                     ; 8EF6
        brk                                     ; 8EF7
        brk                                     ; 8EF8
        brk                                     ; 8EF9
        brk                                     ; 8EFA
        brk                                     ; 8EFB
        brk                                     ; 8EFC
        brk                                     ; 8EFD
L8EFE:  brk                                     ; 8EFE
        brk                                     ; 8EFF
L8F00:  jsr     LA5CD                           ; 8F00
        jsr     LA08C                           ; 8F03
        rts                                     ; 8F06

; ----------------------------------------------------------------------------
        brk                                     ; 8F07
        brk                                     ; 8F08
        brk                                     ; 8F09
        brk                                     ; 8F0A
        brk                                     ; 8F0B
        brk                                     ; 8F0C
        brk                                     ; 8F0D
        brk                                     ; 8F0E
        brk                                     ; 8F0F
        brk                                     ; 8F10
        brk                                     ; 8F11
        brk                                     ; 8F12
        brk                                     ; 8F13
        brk                                     ; 8F14
        brk                                     ; 8F15
        brk                                     ; 8F16
        brk                                     ; 8F17
        brk                                     ; 8F18
        brk                                     ; 8F19
        brk                                     ; 8F1A
        brk                                     ; 8F1B
        brk                                     ; 8F1C
        brk                                     ; 8F1D
        brk                                     ; 8F1E
        brk                                     ; 8F1F
        brk                                     ; 8F20
        brk                                     ; 8F21
        brk                                     ; 8F22
        brk                                     ; 8F23
        brk                                     ; 8F24
        brk                                     ; 8F25
        brk                                     ; 8F26
        brk                                     ; 8F27
        brk                                     ; 8F28
        brk                                     ; 8F29
        brk                                     ; 8F2A
        brk                                     ; 8F2B
        brk                                     ; 8F2C
        brk                                     ; 8F2D
        brk                                     ; 8F2E
        brk                                     ; 8F2F
        brk                                     ; 8F30
        brk                                     ; 8F31
        brk                                     ; 8F32
        brk                                     ; 8F33
        brk                                     ; 8F34
        brk                                     ; 8F35
        brk                                     ; 8F36
        brk                                     ; 8F37
        brk                                     ; 8F38
        brk                                     ; 8F39
        brk                                     ; 8F3A
        brk                                     ; 8F3B
        brk                                     ; 8F3C
        brk                                     ; 8F3D
        brk                                     ; 8F3E
        brk                                     ; 8F3F
        brk                                     ; 8F40
        brk                                     ; 8F41
        brk                                     ; 8F42
        brk                                     ; 8F43
        brk                                     ; 8F44
        brk                                     ; 8F45
        brk                                     ; 8F46
        brk                                     ; 8F47
        brk                                     ; 8F48
        brk                                     ; 8F49
        brk                                     ; 8F4A
        brk                                     ; 8F4B
        brk                                     ; 8F4C
        brk                                     ; 8F4D
        brk                                     ; 8F4E
        brk                                     ; 8F4F
        brk                                     ; 8F50
        brk                                     ; 8F51
        brk                                     ; 8F52
        brk                                     ; 8F53
        brk                                     ; 8F54
        brk                                     ; 8F55
        brk                                     ; 8F56
        brk                                     ; 8F57
        brk                                     ; 8F58
        brk                                     ; 8F59
        brk                                     ; 8F5A
        brk                                     ; 8F5B
        brk                                     ; 8F5C
        brk                                     ; 8F5D
        brk                                     ; 8F5E
        brk                                     ; 8F5F
        brk                                     ; 8F60
        brk                                     ; 8F61
        brk                                     ; 8F62
        brk                                     ; 8F63
        brk                                     ; 8F64
        brk                                     ; 8F65
        brk                                     ; 8F66
        brk                                     ; 8F67
        brk                                     ; 8F68
        brk                                     ; 8F69
        brk                                     ; 8F6A
        brk                                     ; 8F6B
        brk                                     ; 8F6C
        brk                                     ; 8F6D
        brk                                     ; 8F6E
        brk                                     ; 8F6F
        brk                                     ; 8F70
        brk                                     ; 8F71
        brk                                     ; 8F72
        brk                                     ; 8F73
        brk                                     ; 8F74
        brk                                     ; 8F75
        brk                                     ; 8F76
        brk                                     ; 8F77
        brk                                     ; 8F78
        brk                                     ; 8F79
        brk                                     ; 8F7A
        brk                                     ; 8F7B
        brk                                     ; 8F7C
        brk                                     ; 8F7D
        brk                                     ; 8F7E
        brk                                     ; 8F7F
        brk                                     ; 8F80
        brk                                     ; 8F81
        brk                                     ; 8F82
        brk                                     ; 8F83
        brk                                     ; 8F84
        brk                                     ; 8F85
        brk                                     ; 8F86
        brk                                     ; 8F87
        brk                                     ; 8F88
        brk                                     ; 8F89
        brk                                     ; 8F8A
        brk                                     ; 8F8B
        brk                                     ; 8F8C
        brk                                     ; 8F8D
        brk                                     ; 8F8E
        brk                                     ; 8F8F
        brk                                     ; 8F90
        brk                                     ; 8F91
        brk                                     ; 8F92
        brk                                     ; 8F93
        brk                                     ; 8F94
L8F95:  brk                                     ; 8F95
        brk                                     ; 8F96
        brk                                     ; 8F97
        brk                                     ; 8F98
        brk                                     ; 8F99
        brk                                     ; 8F9A
        brk                                     ; 8F9B
        brk                                     ; 8F9C
        brk                                     ; 8F9D
        brk                                     ; 8F9E
L8F9F:  brk                                     ; 8F9F
        brk                                     ; 8FA0
        brk                                     ; 8FA1
        brk                                     ; 8FA2
        brk                                     ; 8FA3
        brk                                     ; 8FA4
        brk                                     ; 8FA5
        brk                                     ; 8FA6
        brk                                     ; 8FA7
        brk                                     ; 8FA8
L8FA9:  brk                                     ; 8FA9
        brk                                     ; 8FAA
        brk                                     ; 8FAB
        brk                                     ; 8FAC
        brk                                     ; 8FAD
        brk                                     ; 8FAE
        brk                                     ; 8FAF
        brk                                     ; 8FB0
        brk                                     ; 8FB1
        brk                                     ; 8FB2
L8FB3:  brk                                     ; 8FB3
        brk                                     ; 8FB4
        brk                                     ; 8FB5
        brk                                     ; 8FB6
        brk                                     ; 8FB7
        brk                                     ; 8FB8
        brk                                     ; 8FB9
        brk                                     ; 8FBA
        brk                                     ; 8FBB
        brk                                     ; 8FBC
L8FBD:  brk                                     ; 8FBD
        brk                                     ; 8FBE
        brk                                     ; 8FBF
        brk                                     ; 8FC0
        brk                                     ; 8FC1
        brk                                     ; 8FC2
        brk                                     ; 8FC3
        brk                                     ; 8FC4
        brk                                     ; 8FC5
        brk                                     ; 8FC6
L8FC7:  brk                                     ; 8FC7
        brk                                     ; 8FC8
        brk                                     ; 8FC9
        brk                                     ; 8FCA
        brk                                     ; 8FCB
        brk                                     ; 8FCC
        brk                                     ; 8FCD
        brk                                     ; 8FCE
        brk                                     ; 8FCF
        brk                                     ; 8FD0
L8FD1:  brk                                     ; 8FD1
        brk                                     ; 8FD2
        brk                                     ; 8FD3
        brk                                     ; 8FD4
        brk                                     ; 8FD5
        brk                                     ; 8FD6
        brk                                     ; 8FD7
        brk                                     ; 8FD8
        brk                                     ; 8FD9
        brk                                     ; 8FDA
L8FDB:  brk                                     ; 8FDB
        brk                                     ; 8FDC
        brk                                     ; 8FDD
        brk                                     ; 8FDE
        brk                                     ; 8FDF
        brk                                     ; 8FE0
        brk                                     ; 8FE1
        brk                                     ; 8FE2
        brk                                     ; 8FE3
        brk                                     ; 8FE4
L8FE5:  brk                                     ; 8FE5
        brk                                     ; 8FE6
        brk                                     ; 8FE7
        brk                                     ; 8FE8
        brk                                     ; 8FE9
        brk                                     ; 8FEA
        brk                                     ; 8FEB
        brk                                     ; 8FEC
        brk                                     ; 8FED
        brk                                     ; 8FEE
L8FEF:  brk                                     ; 8FEF
        brk                                     ; 8FF0
        brk                                     ; 8FF1
        brk                                     ; 8FF2
        brk                                     ; 8FF3
        brk                                     ; 8FF4
        brk                                     ; 8FF5
        brk                                     ; 8FF6
        brk                                     ; 8FF7
        brk                                     ; 8FF8
L8FF9:  brk                                     ; 8FF9
        brk                                     ; 8FFA
L8FFB:  brk                                     ; 8FFB
        brk                                     ; 8FFC
L8FFD:  brk                                     ; 8FFD
        brk                                     ; 8FFE
        brk                                     ; 8FFF
        jsr     LBE81                           ; 9000
L9003:  jsr     LB73E                           ; 9003
        rts                                     ; 9006

; ----------------------------------------------------------------------------
        eor     ($B0),y                         ; 9007
        eor     $61B0,y                         ; 9009
        .byte   $B0                             ; 900C
L900D:  adc     #$B0                            ; 900D
L900F:  adc     ($B0),y                         ; 900F
        adc     L81B0,y                         ; 9011
        bcs     L8F9F                           ; 9014
        .byte   $B0                             ; 9016
L9017:  sta     ($B0),y                         ; 9017
        sta     $A1B0,y                         ; 9019
        bcs     L8FC7                           ; 901C
        bcs     L8FD1                           ; 901E
        .byte   $B0                             ; 9020
L9021:  lda     $C1B0,y                         ; 9021
        bcs     L8FEF                           ; 9024
        bcs     L8FF9                           ; 9026
        bcs     L9003                           ; 9028
        .byte   $B0                             ; 902A
L902B:  sbc     ($B0,x)                         ; 902B
        sbc     #$B0                            ; 902D
        sbc     ($B0),y                         ; 902F
        sbc     $01B0,y                         ; 9031
        .byte   $B1                             ; 9034
L9035:  ora     #$B1                            ; 9035
        ora     ($B1),y                         ; 9037
        ora     $21B1,y                         ; 9039
        lda     ($29),y                         ; 903C
        lda     ($31),y                         ; 903E
        lda     ($39),y                         ; 9040
        lda     ($41),y                         ; 9042
        lda     ($49),y                         ; 9044
        lda     ($51),y                         ; 9046
        lda     ($00),y                         ; 9048
        brk                                     ; 904A
        brk                                     ; 904B
        brk                                     ; 904C
        brk                                     ; 904D
        brk                                     ; 904E
        brk                                     ; 904F
        brk                                     ; 9050
        brk                                     ; 9051
        brk                                     ; 9052
        .byte   $67                             ; 9053
        .byte   $B2                             ; 9054
        brk                                     ; 9055
        brk                                     ; 9056
        brk                                     ; 9057
        brk                                     ; 9058
        brk                                     ; 9059
        brk                                     ; 905A
        bvs     L900F                           ; 905B
        brk                                     ; 905D
        brk                                     ; 905E
        brk                                     ; 905F
        brk                                     ; 9060
        brk                                     ; 9061
        brk                                     ; 9062
        .byte   $7A                             ; 9063
        .byte   $B2                             ; 9064
        brk                                     ; 9065
        brk                                     ; 9066
        brk                                     ; 9067
        brk                                     ; 9068
        brk                                     ; 9069
        brk                                     ; 906A
        .byte   $9B                             ; 906B
        .byte   $B2                             ; 906C
        brk                                     ; 906D
        brk                                     ; 906E
        iny                                     ; 906F
        .byte   $B2                             ; 9070
        brk                                     ; 9071
        brk                                     ; 9072
        cmp     $B2,x                           ; 9073
        brk                                     ; 9075
        brk                                     ; 9076
L9077:  brk                                     ; 9077
        brk                                     ; 9078
        brk                                     ; 9079
        brk                                     ; 907A
        dec     a:$B2,x                         ; 907B
        brk                                     ; 907E
        brk                                     ; 907F
        brk                                     ; 9080
L9081:  brk                                     ; 9081
        brk                                     ; 9082
        .byte   $E7                             ; 9083
        .byte   $B2                             ; 9084
        brk                                     ; 9085
        brk                                     ; 9086
        brk                                     ; 9087
        brk                                     ; 9088
        brk                                     ; 9089
        brk                                     ; 908A
L908B:  cpx     a:$B2                           ; 908B
        brk                                     ; 908E
        sbc     $B2,y                           ; 908F
        brk                                     ; 9092
        asl     L00B3,x                         ; 9093
        brk                                     ; 9095
        brk                                     ; 9096
        brk                                     ; 9097
        brk                                     ; 9098
        brk                                     ; 9099
        brk                                     ; 909A
        .byte   $03                             ; 909B
        lda     $00,x                           ; 909C
        brk                                     ; 909E
        inc     $B4,x                           ; 909F
        brk                                     ; 90A1
        brk                                     ; 90A2
        brk                                     ; 90A3
        brk                                     ; 90A4
        brk                                     ; 90A5
        brk                                     ; 90A6
        brk                                     ; 90A7
        brk                                     ; 90A8
        brk                                     ; 90A9
        brk                                     ; 90AA
        brk                                     ; 90AB
        brk                                     ; 90AC
        brk                                     ; 90AD
        brk                                     ; 90AE
        brk                                     ; 90AF
        brk                                     ; 90B0
        brk                                     ; 90B1
        brk                                     ; 90B2
        brk                                     ; 90B3
        brk                                     ; 90B4
        brk                                     ; 90B5
        brk                                     ; 90B6
        clc                                     ; 90B7
L90B8:  lda     $00,x                           ; 90B8
        brk                                     ; 90BA
        .byte   $1B                             ; 90BB
        .byte   $B3                             ; 90BC
        brk                                     ; 90BD
        brk                                     ; 90BE
        brk                                     ; 90BF
        brk                                     ; 90C0
        brk                                     ; 90C1
        brk                                     ; 90C2
        jsr     L00B3                           ; 90C3
        brk                                     ; 90C6
        brk                                     ; 90C7
        brk                                     ; 90C8
        brk                                     ; 90C9
        brk                                     ; 90CA
        and     (L00B3),y                       ; 90CB
        brk                                     ; 90CD
        brk                                     ; 90CE
        brk                                     ; 90CF
        brk                                     ; 90D0
        brk                                     ; 90D1
        brk                                     ; 90D2
        rol     L00B3,x                         ; 90D3
        brk                                     ; 90D5
        brk                                     ; 90D6
        brk                                     ; 90D7
        brk                                     ; 90D8
        brk                                     ; 90D9
        brk                                     ; 90DA
        .byte   $47                             ; 90DB
        .byte   $B3                             ; 90DC
        brk                                     ; 90DD
        brk                                     ; 90DE
        brk                                     ; 90DF
        brk                                     ; 90E0
        brk                                     ; 90E1
        brk                                     ; 90E2
        jmp     (L00B3)                         ; 90E3

; ----------------------------------------------------------------------------
        brk                                     ; 90E6
        brk                                     ; 90E7
        brk                                     ; 90E8
        brk                                     ; 90E9
        brk                                     ; 90EA
        sta     a:L00B3,x                       ; 90EB
        brk                                     ; 90EE
        brk                                     ; 90EF
        brk                                     ; 90F0
        brk                                     ; 90F1
        brk                                     ; 90F2
        sbc     ($B4),y                         ; 90F3
        brk                                     ; 90F5
        brk                                     ; 90F6
        brk                                     ; 90F7
        brk                                     ; 90F8
        brk                                     ; 90F9
        brk                                     ; 90FA
        tsx                                     ; 90FB
        .byte   $B3                             ; 90FC
        brk                                     ; 90FD
        brk                                     ; 90FE
        brk                                     ; 90FF
        brk                                     ; 9100
        .byte   $BF                             ; 9101
        .byte   $B3                             ; 9102
        bne     L90B8                           ; 9103
        sbc     (L00B3,x)                       ; 9105
        brk                                     ; 9107
        brk                                     ; 9108
        brk                                     ; 9109
        brk                                     ; 910A
        .byte   $F2                             ; 910B
        .byte   $B3                             ; 910C
        brk                                     ; 910D
        brk                                     ; 910E
        brk                                     ; 910F
        brk                                     ; 9110
        brk                                     ; 9111
        brk                                     ; 9112
        .byte   $F7                             ; 9113
        .byte   $B3                             ; 9114
        brk                                     ; 9115
        brk                                     ; 9116
        brk                                     ; 9117
        ldy     $00,x                           ; 9118
        brk                                     ; 911A
        ora     $B4                             ; 911B
        brk                                     ; 911D
        brk                                     ; 911E
        brk                                     ; 911F
        brk                                     ; 9120
        brk                                     ; 9121
        brk                                     ; 9122
        asl     $B4,x                           ; 9123
        brk                                     ; 9125
        brk                                     ; 9126
        brk                                     ; 9127
        brk                                     ; 9128
        brk                                     ; 9129
        brk                                     ; 912A
        and     a:$B5                           ; 912B
        brk                                     ; 912E
        brk                                     ; 912F
        brk                                     ; 9130
        brk                                     ; 9131
        brk                                     ; 9132
        .byte   $2F                             ; 9133
        ldy     $00,x                           ; 9134
        brk                                     ; 9136
        pla                                     ; 9137
        ldy     $00,x                           ; 9138
        brk                                     ; 913A
        .byte   $89                             ; 913B
        ldy     $00,x                           ; 913C
        brk                                     ; 913E
        brk                                     ; 913F
        brk                                     ; 9140
        brk                                     ; 9141
        brk                                     ; 9142
        .byte   $9E                             ; 9143
        ldy     $00,x                           ; 9144
        brk                                     ; 9146
        .byte   $B7                             ; 9147
        ldy     $00,x                           ; 9148
        brk                                     ; 914A
        inx                                     ; 914B
        ldy     $E8,x                           ; 914C
        ldy     $00,x                           ; 914E
        brk                                     ; 9150
        brk                                     ; 9151
        brk                                     ; 9152
        brk                                     ; 9153
        brk                                     ; 9154
        brk                                     ; 9155
        brk                                     ; 9156
        brk                                     ; 9157
        ldx     $BE11,y                         ; 9158
        lsr     a                               ; 915B
        lda     $72,x                           ; 915C
        lda     $C6,x                           ; 915E
        lda     $CB,x                           ; 9160
        lda     $DE,x                           ; 9162
        lda     $ED,x                           ; 9164
        lda     $DD,x                           ; 9166
        ldx     $A9,y                           ; 9168
        lda     $25,x                           ; 916A
        ldx     $0A,y                           ; 916C
        ldx     $2E,y                           ; 916E
        ldx     $45,y                           ; 9170
        ldx     $7C,y                           ; 9172
        ldx     $6B,y                           ; 9174
        lda     $AD,x                           ; 9176
        ldx     $8B,y                           ; 9178
        ldx     $98,y                           ; 917A
        ldx     $CE,y                           ; 917C
        ldx     $F2,y                           ; 917E
        ldx     $0D,y                           ; 9180
        .byte   $B7                             ; 9182
        jsr     L32B7                           ; 9183
        ldx     $BE67,y                         ; 9186
        beq     L9192                           ; 9189
        ror     $07,x                           ; 918B
        .byte   $12                             ; 918D
        .byte   $07                             ; 918E
        ldx     $4E06                           ; 918F
L9192:  asl     $F3                             ; 9192
        ora     $9E                             ; 9194
        ora     $4D                             ; 9196
        ora     $01                             ; 9198
        ora     $B9                             ; 919A
        .byte   $04                             ; 919C
        adc     $04,x                           ; 919D
        and     $04,x                           ; 919F
        sed                                     ; 91A1
        .byte   $03                             ; 91A2
        .byte   $BF                             ; 91A3
        .byte   $03                             ; 91A4
        .byte   $89                             ; 91A5
        .byte   $03                             ; 91A6
        .byte   $57                             ; 91A7
        .byte   $03                             ; 91A8
        .byte   $27                             ; 91A9
        .byte   $03                             ; 91AA
        sbc     $CF02,y                         ; 91AB
        .byte   $02                             ; 91AE
        ldx     $02                             ; 91AF
        .byte   $80                             ; 91B1
        .byte   $02                             ; 91B2
        .byte   $5C                             ; 91B3
        .byte   $02                             ; 91B4
        .byte   $3C                             ; 91B5
        .byte   $02                             ; 91B6
        .byte   $1A                             ; 91B7
        .byte   $02                             ; 91B8
        .byte   $FC                             ; 91B9
        ora     ($DF,x)                         ; 91BA
        ora     ($C4,x)                         ; 91BC
        ora     ($AB,x)                         ; 91BE
        ora     ($93,x)                         ; 91C0
        ora     ($7C,x)                         ; 91C2
        ora     ($67,x)                         ; 91C4
        ora     ($52,x)                         ; 91C6
        ora     ($3F,x)                         ; 91C8
        ora     ($2D,x)                         ; 91CA
        ora     ($1C,x)                         ; 91CC
        ora     ($0C,x)                         ; 91CE
        ora     ($FD,x)                         ; 91D0
        brk                                     ; 91D2
        inc     $E100                           ; 91D3
        brk                                     ; 91D6
        .byte   $D4                             ; 91D7
        brk                                     ; 91D8
        iny                                     ; 91D9
        brk                                     ; 91DA
        lda     $B200,x                         ; 91DB
        brk                                     ; 91DE
        tay                                     ; 91DF
        brk                                     ; 91E0
        .byte   $9F                             ; 91E1
        brk                                     ; 91E2
        stx     $00,y                           ; 91E3
        sta     L8500                           ; 91E5
        brk                                     ; 91E8
        ror     $7600,x                         ; 91E9
        brk                                     ; 91EC
        bvs     L91EF                           ; 91ED
L91EF:  adc     #$00                            ; 91EF
        .byte   $63                             ; 91F1
        brk                                     ; 91F2
        lsr     $5800,x                         ; 91F3
        brk                                     ; 91F6
        .byte   $53                             ; 91F7
        brk                                     ; 91F8
        .byte   $4F                             ; 91F9
        brk                                     ; 91FA
        lsr     a                               ; 91FB
        brk                                     ; 91FC
        lsr     $00                             ; 91FD
        .byte   $42                             ; 91FF
        brk                                     ; 9200
        rol     $3A00,x                         ; 9201
        brk                                     ; 9204
        .byte   $37                             ; 9205
        brk                                     ; 9206
        .byte   $34                             ; 9207
        brk                                     ; 9208
        and     ($00),y                         ; 9209
        rol     $2B00                           ; 920B
        brk                                     ; 920E
        and     #$00                            ; 920F
        .byte   $27                             ; 9211
        brk                                     ; 9212
        bit     $00                             ; 9213
        .byte   $22                             ; 9215
        brk                                     ; 9216
        jsr     L1E00                           ; 9217
        brk                                     ; 921A
        .byte   $1C                             ; 921B
        brk                                     ; 921C
        .byte   $1B                             ; 921D
        brk                                     ; 921E
        .byte   $1A                             ; 921F
        brk                                     ; 9220
        ora     $1800,y                         ; 9221
        brk                                     ; 9224
        .byte   $17                             ; 9225
        brk                                     ; 9226
        .byte   $0F                             ; 9227
        brk                                     ; 9228
        asl     $0D00                           ; 9229
        brk                                     ; 922C
        .byte   $0C                             ; 922D
        brk                                     ; 922E
        .byte   $0B                             ; 922F
        brk                                     ; 9230
        asl     a                               ; 9231
        brk                                     ; 9232
        ora     #$00                            ; 9233
        php                                     ; 9235
        brk                                     ; 9236
        .byte   $07                             ; 9237
        brk                                     ; 9238
        asl     $00                             ; 9239
        ora     $00                             ; 923B
        .byte   $04                             ; 923D
        brk                                     ; 923E
        .byte   $03                             ; 923F
        brk                                     ; 9240
        .byte   $02                             ; 9241
        brk                                     ; 9242
        ora     ($00,x)                         ; 9243
        brk                                     ; 9245
        brk                                     ; 9246
        .byte   $8F                             ; 9247
        brk                                     ; 9248
        stx     L8D00                           ; 9249
        brk                                     ; 924C
        sty     L8B00                           ; 924D
        brk                                     ; 9250
        txa                                     ; 9251
        brk                                     ; 9252
        .byte   $89                             ; 9253
        brk                                     ; 9254
        dey                                     ; 9255
        brk                                     ; 9256
        .byte   $87                             ; 9257
        brk                                     ; 9258
        stx     $00                             ; 9259
        sta     $00                             ; 925B
        sty     $00                             ; 925D
        .byte   $83                             ; 925F
        brk                                     ; 9260
        .byte   $82                             ; 9261
        brk                                     ; 9262
        sta     ($00,x)                         ; 9263
        .byte   $80                             ; 9265
        brk                                     ; 9266
        eor     ($81,x)                         ; 9267
        brk                                     ; 9269
        and     L8943,x                         ; 926A
        brk                                     ; 926D
        .byte   $3F                             ; 926E
        brk                                     ; 926F
        cmp     ($89,x)                         ; 9270
        brk                                     ; 9272
        .byte   $3A                             ; 9273
        brk                                     ; 9274
        ldy     #$82                            ; 9275
        brk                                     ; 9277
        .byte   $33                             ; 9278
        brk                                     ; 9279
        .byte   $62                             ; 927A
        sta     ($95),y                         ; 927B
        bit     L9762                           ; 927D
        stx     $6F23                           ; 9280
        dey                                     ; 9283
        stx     $28,y                           ; 9284
        .byte   $62                             ; 9286
        sta     ($95),y                         ; 9287
        bit     L9762                           ; 9289
        stx     $6F23                           ; 928C
        dey                                     ; 928F
        stx     $28,y                           ; 9290
        .byte   $62                             ; 9292
        .byte   $97                             ; 9293
        lda     $33                             ; 9294
        .byte   $62                             ; 9296
        sta     ($95),y                         ; 9297
        plp                                     ; 9299
        brk                                     ; 929A
        .byte   $BF                             ; 929B
        .byte   $83                             ; 929C
        txa                                     ; 929D
        bit     $BF                             ; 929E
        .byte   $83                             ; 92A0
        txa                                     ; 92A1
        bit     $BF                             ; 92A2
        .byte   $83                             ; 92A4
        txa                                     ; 92A5
        bit     $BF                             ; 92A6
        .byte   $83                             ; 92A8
        txa                                     ; 92A9
        bit     $BF                             ; 92AA
        .byte   $83                             ; 92AC
        txa                                     ; 92AD
        bit     $BF                             ; 92AE
        .byte   $83                             ; 92B0
        txa                                     ; 92B1
        and     $BF                             ; 92B2
        .byte   $83                             ; 92B4
        txa                                     ; 92B5
        rol     $BF                             ; 92B6
        .byte   $83                             ; 92B8
        txa                                     ; 92B9
        .byte   $27                             ; 92BA
        ldy     L8A83,x                         ; 92BB
        plp                                     ; 92BE
        lda     L8A83,y                         ; 92BF
        and     #$B6                            ; 92C2
        .byte   $83                             ; 92C4
        txa                                     ; 92C5
        rol     a                               ; 92C6
        brk                                     ; 92C7
        .byte   $1F                             ; 92C8
        ora     ($00,x)                         ; 92C9
        ora     #$2F                            ; 92CB
        .byte   $02                             ; 92CD
        brk                                     ; 92CE
        .byte   $0C                             ; 92CF
        tax                                     ; 92D0
        jsr     L0500                           ; 92D1
        brk                                     ; 92D4
        .byte   $BF                             ; 92D5
        tya                                     ; 92D6
        sta     $3F,x                           ; 92D7
        .byte   $BF                             ; 92D9
        sta     $3F95,y                         ; 92DA
        brk                                     ; 92DD
        .byte   $3F                             ; 92DE
        tya                                     ; 92DF
        sta     $1E,x                           ; 92E0
        .byte   $3F                             ; 92E2
        sta     $2195,y                         ; 92E3
        brk                                     ; 92E6
        .byte   $AF                             ; 92E7
        .byte   $80                             ; 92E8
        brk                                     ; 92E9
        .byte   $2B                             ; 92EA
        brk                                     ; 92EB
        .byte   $3F                             ; 92EC
        .byte   $80                             ; 92ED
        brk                                     ; 92EE
        asl     L816F                           ; 92EF
        txa                                     ; 92F2
        .byte   $04                             ; 92F3
        .byte   $6F                             ; 92F4
        sty     $8A                             ; 92F5
        asl     $3F00                           ; 92F7
        brk                                     ; 92FA
        brk                                     ; 92FB
        ora     #$3F                            ; 92FC
        .byte   $03                             ; 92FE
        brk                                     ; 92FF
        asl     a:$3F                           ; 9300
        brk                                     ; 9303
        ora     #$3F                            ; 9304
        brk                                     ; 9306
        brk                                     ; 9307
        .byte   $07                             ; 9308
        .byte   $3F                             ; 9309
        brk                                     ; 930A
        brk                                     ; 930B
        ora     $3F                             ; 930C
        .byte   $04                             ; 930E
        brk                                     ; 930F
        ora     $39                             ; 9310
        .byte   $02                             ; 9312
        brk                                     ; 9313
        .byte   $0B                             ; 9314
        brk                                     ; 9315
        ldy     $90                             ; 9316
        sta     a:$20                           ; 9318
        .byte   $BF                             ; 931B
        .byte   $9F                             ; 931C
        sty     $3F,x                           ; 931D
        brk                                     ; 931F
        .byte   $BF                             ; 9320
        sta     $00                             ; 9321
        .byte   $32                             ; 9323
        .byte   $BF                             ; 9324
        sta     $00                             ; 9325
        .byte   $33                             ; 9327
        .byte   $BF                             ; 9328
        sta     $00                             ; 9329
        .byte   $34                             ; 932B
        sty     $90                             ; 932C
        brk                                     ; 932E
        and     $00,x                           ; 932F
        lda     ($A5,x)                         ; 9331
        .byte   $DA                             ; 9333
        asl     $BF00                           ; 9334
        .byte   $83                             ; 9337
        brk                                     ; 9338
        and     ($BF),y                         ; 9339
        .byte   $83                             ; 933B
        brk                                     ; 933C
        rol     $BF,x                           ; 933D
        .byte   $83                             ; 933F
        brk                                     ; 9340
        .byte   $3A                             ; 9341
        .byte   $83                             ; 9342
        txa                                     ; 9343
        brk                                     ; 9344
        and     $BF00,x                         ; 9345
        .byte   $83                             ; 9348
        .byte   $9B                             ; 9349
        asl     a                               ; 934A
        ldx     L8583,y                         ; 934B
        .byte   $1B                             ; 934E
        lda     L8583,x                         ; 934F
        .byte   $1A                             ; 9352
        tsx                                     ; 9353
        .byte   $83                             ; 9354
        .byte   $9B                             ; 9355
        asl     a                               ; 9356
        lda     L8583,y                         ; 9357
        .byte   $1B                             ; 935A
        clv                                     ; 935B
        .byte   $83                             ; 935C
        sta     $1A                             ; 935D
        lda     $83,x                           ; 935F
        .byte   $9B                             ; 9361
        asl     a                               ; 9362
        ldy     $83,x                           ; 9363
        sta     $1B                             ; 9365
        .byte   $B3                             ; 9367
        .byte   $83                             ; 9368
L9369:  sta     $1A                             ; 9369
        brk                                     ; 936B
        .byte   $BF                             ; 936C
L936D:  .byte   $87                             ; 936D
        .byte   $9C                             ; 936E
        rol     L87BE                           ; 936F
        .byte   $9C                             ; 9372
        and     L87BD                           ; 9373
        .byte   $9C                             ; 9376
        bit     L87BC                           ; 9377
        .byte   $9C                             ; 937A
        .byte   $2B                             ; 937B
        .byte   $BB                             ; 937C
        .byte   $87                             ; 937D
        .byte   $9C                             ; 937E
        rol     a                               ; 937F
        tsx                                     ; 9380
        .byte   $87                             ; 9381
        .byte   $9C                             ; 9382
        and     #$B9                            ; 9383
        .byte   $87                             ; 9385
        .byte   $9C                             ; 9386
        plp                                     ; 9387
        clv                                     ; 9388
        .byte   $87                             ; 9389
        .byte   $9C                             ; 938A
        .byte   $27                             ; 938B
        .byte   $B7                             ; 938C
        .byte   $87                             ; 938D
        .byte   $9C                             ; 938E
        rol     $B6                             ; 938F
        .byte   $87                             ; 9391
        .byte   $9C                             ; 9392
        and     $B5                             ; 9393
        .byte   $87                             ; 9395
        .byte   $9C                             ; 9396
        bit     $B4                             ; 9397
        .byte   $87                             ; 9399
        .byte   $9C                             ; 939A
        .byte   $23                             ; 939B
        brk                                     ; 939C
        .byte   $FF                             ; 939D
        tax                                     ; 939E
        .byte   $FB                             ; 939F
        .byte   $32                             ; 93A0
        .byte   $FF                             ; 93A1
        tax                                     ; 93A2
L93A3:  .byte   $FB                             ; 93A3
        .byte   $34                             ; 93A4
        .byte   $FF                             ; 93A5
        tax                                     ; 93A6
        .byte   $FB                             ; 93A7
        rol     $FF,x                           ; 93A8
        tax                                     ; 93AA
        .byte   $FB                             ; 93AB
        sec                                     ; 93AC
        .byte   $FF                             ; 93AD
        tax                                     ; 93AE
        .byte   $FB                             ; 93AF
        .byte   $3A                             ; 93B0
        .byte   $FF                             ; 93B1
        tax                                     ; 93B2
        .byte   $FB                             ; 93B3
L93B4:  .byte   $3C                             ; 93B4
        .byte   $FF                             ; 93B5
        tax                                     ; 93B6
        .byte   $FB                             ; 93B7
        rol     $A100,x                         ; 93B8
        stx     $00                             ; 93BB
        .byte   $3F                             ; 93BD
        brk                                     ; 93BE
        .byte   $6F                             ; 93BF
        stx     $00                             ; 93C0
        plp                                     ; 93C2
        .byte   $6F                             ; 93C3
        stx     $00                             ; 93C4
        and     #$6F                            ; 93C6
        .byte   $86                             ; 93C8
L93C9:  brk                                     ; 93C9
        rol     a                               ; 93CA
        ror     $8F                             ; 93CB
        brk                                     ; 93CD
        .byte   $2B                             ; 93CE
        brk                                     ; 93CF
        .byte   $6F                             ; 93D0
        stx     $00                             ; 93D1
        bit     $6F                             ; 93D3
        stx     $00                             ; 93D5
        and     $6F                             ; 93D7
        stx     $00                             ; 93D9
        rol     $66                             ; 93DB
        .byte   $8F                             ; 93DD
        brk                                     ; 93DE
        .byte   $27                             ; 93DF
        brk                                     ; 93E0
        bcs     L9369                           ; 93E1
        brk                                     ; 93E3
        .byte   $2B                             ; 93E4
        bcs     L936D                           ; 93E5
        brk                                     ; 93E7
        bit     L86B0                           ; 93E8
        brk                                     ; 93EB
        and     L8DB0                           ; 93EC
        brk                                     ; 93EF
        rol     L8F00                           ; 93F0
        .byte   $83                             ; 93F3
        .byte   $89                             ; 93F4
        .byte   $03                             ; 93F5
        brk                                     ; 93F6
        .byte   $BF                             ; 93F7
        sta     $8A                             ; 93F8
        asl     a                               ; 93FA
        ror     a                               ; 93FB
        sty     $84,x                           ; 93FC
        and     LA600,x                         ; 93FE
        ora     $0700,y                         ; 9401
        brk                                     ; 9404
        ldy     #$B0                            ; 9405
        .byte   $9C                             ; 9407
        bpl     L93C9                           ; 9408
        sta     $91                             ; 940A
        .byte   $3F                             ; 940C
        bcs     L940F                           ; 940D
L940F:  brk                                     ; 940F
        brk                                     ; 9410
        lda     L8287,y                         ; 9411
        and     $FF00,x                         ; 9414
        stx     $00                             ; 9417
        .byte   $2F                             ; 9419
        beq     L93A3                           ; 941A
        brk                                     ; 941C
        brk                                     ; 941D
        .byte   $FF                             ; 941E
        dey                                     ; 941F
        brk                                     ; 9420
        .byte   $33                             ; 9421
        .byte   $FF                             ; 9422
        .byte   $89                             ; 9423
        brk                                     ; 9424
        .byte   $2F                             ; 9425
        beq     L93B4                           ; 9426
        brk                                     ; 9428
        brk                                     ; 9429
        .byte   $FF                             ; 942A
        ldy     #$A7                            ; 942B
        and     $3300                           ; 942D
        brk                                     ; 9430
        brk                                     ; 9431
        rol     $37                             ; 9432
        brk                                     ; 9434
        brk                                     ; 9435
        rol     $BB                             ; 9436
        brk                                     ; 9438
        brk                                     ; 9439
        rol     $BE                             ; 943A
        brk                                     ; 943C
        brk                                     ; 943D
        rol     $BF                             ; 943E
        ora     ($00,x)                         ; 9440
        asl     $017F,x                         ; 9442
        brk                                     ; 9445
        asl     $017B,x                         ; 9446
        brk                                     ; 9449
        asl     $0178,x                         ; 944A
        brk                                     ; 944D
        asl     $0377,x                         ; 944E
        brk                                     ; 9451
        asl     $0376,x                         ; 9452
        brk                                     ; 9455
        asl     $0377,x                         ; 9456
        brk                                     ; 9459
        asl     $0374,x                         ; 945A
        brk                                     ; 945D
        asl     $0373,x                         ; 945E
        brk                                     ; 9461
        asl     $0372,x                         ; 9462
        brk                                     ; 9465
        asl     $3F00,x                         ; 9466
        ora     ($00,x)                         ; 9469
        .byte   $74                             ; 946B
        .byte   $3A                             ; 946C
        ora     ($00,x)                         ; 946D
        .byte   $73                             ; 946F
        rol     $01,x                           ; 9470
        brk                                     ; 9472
        .byte   $72                             ; 9473
        and     $02,x                           ; 9474
        brk                                     ; 9476
        adc     ($34),y                         ; 9477
        .byte   $02                             ; 9479
        brk                                     ; 947A
        adc     ($33),y                         ; 947B
        .byte   $02                             ; 947D
        brk                                     ; 947E
        adc     ($32),y                         ; 947F
        .byte   $02                             ; 9481
        brk                                     ; 9482
        adc     ($31),y                         ; 9483
        .byte   $02                             ; 9485
        brk                                     ; 9486
        adc     ($00),y                         ; 9487
        .byte   $EF                             ; 9489
        sty     $86,x                           ; 948A
        ora     $30,x                           ; 948C
        asl     a:$00                           ; 948E
        cpx     L8696                           ; 9491
L9494:  .byte   $13                             ; 9494
        bmi     L94A5                           ; 9495
        brk                                     ; 9497
        brk                                     ; 9498
        inx                                     ; 9499
        .byte   $9C                             ; 949A
        stx     $11                             ; 949B
        brk                                     ; 949D
        and     ($08),y                         ; 949E
        brk                                     ; 94A0
        brk                                     ; 94A1
        .byte   $3F                             ; 94A2
        ora     ($00,x)                         ; 94A3
L94A5:  rol     $013C                           ; 94A5
        brk                                     ; 94A8
        rol     $0139                           ; 94A9
        brk                                     ; 94AC
        rol     $0136                           ; 94AD
        brk                                     ; 94B0
        rol     $0133                           ; 94B1
        brk                                     ; 94B4
        rol     $3F00                           ; 94B5
        brk                                     ; 94B8
L94B9:  brk                                     ; 94B9
        .byte   $8B                             ; 94BA
        .byte   $3F                             ; 94BB
        brk                                     ; 94BC
        brk                                     ; 94BD
        sei                                     ; 94BE
        .byte   $3F                             ; 94BF
        brk                                     ; 94C0
        brk                                     ; 94C1
        .byte   $77                             ; 94C2
L94C3:  .byte   $3F                             ; 94C3
        brk                                     ; 94C4
        brk                                     ; 94C5
        ror     $3F,x                           ; 94C6
        brk                                     ; 94C8
        brk                                     ; 94C9
        adc     $3F,x                           ; 94CA
        brk                                     ; 94CC
        brk                                     ; 94CD
        .byte   $74                             ; 94CE
        .byte   $3F                             ; 94CF
        brk                                     ; 94D0
        brk                                     ; 94D1
        .byte   $73                             ; 94D2
        .byte   $3F                             ; 94D3
        .byte   $02                             ; 94D4
        brk                                     ; 94D5
        sta     ($3E,x)                         ; 94D6
        ora     ($00,x)                         ; 94D8
        sta     ($3C,x)                         ; 94DA
        ora     ($00,x)                         ; 94DC
        sta     ($3A,x)                         ; 94DE
        ora     ($00,x)                         ; 94E0
        sta     ($38,x)                         ; 94E2
        ora     ($00,x)                         ; 94E4
        sta     ($00,x)                         ; 94E6
        bcs     L954A                           ; 94E8
        brk                                     ; 94EA
        brk                                     ; 94EB
        bcs     L9532                           ; 94EC
        brk                                     ; 94EE
        brk                                     ; 94EF
        brk                                     ; 94F0
        bcs     L94F4                           ; 94F1
        brk                                     ; 94F3
L94F4:  brk                                     ; 94F4
        brk                                     ; 94F5
        .byte   $7F                             ; 94F6
        ora     ($00,x)                         ; 94F7
        asl     a                               ; 94F9
        adc     $01,x                           ; 94FA
        brk                                     ; 94FC
        asl     a                               ; 94FD
        .byte   $72                             ; 94FE
        ora     ($00,x)                         ; 94FF
        asl     a                               ; 9501
        brk                                     ; 9502
        .byte   $BF                             ; 9503
        ora     ($00,x)                         ; 9504
        bvc     L94C3                           ; 9506
        ora     ($00,x)                         ; 9508
        lda     ($78,x)                         ; 950A
        ora     ($00,x)                         ; 950C
        .byte   $9F                             ; 950E
        adc     $01,x                           ; 950F
        brk                                     ; 9511
        sta     $0172,x                         ; 9512
        brk                                     ; 9515
        .byte   $9B                             ; 9516
        brk                                     ; 9517
        ora     ($39,x)                         ; 9518
        brk                                     ; 951A
        brk                                     ; 951B
        bmi     L955D                           ; 951C
        brk                                     ; 951E
        brk                                     ; 951F
        ora     ($39,x)                         ; 9520
        brk                                     ; 9522
        brk                                     ; 9523
        bmi     L95A5                           ; 9524
        brk                                     ; 9526
        brk                                     ; 9527
        ora     ($4A,x)                         ; 9528
        brk                                     ; 952A
        brk                                     ; 952B
        brk                                     ; 952C
        .byte   $BF                             ; 952D
        .byte   $02                             ; 952E
        brk                                     ; 952F
        cli                                     ; 9530
        .byte   $BF                             ; 9531
L9532:  .byte   $02                             ; 9532
        brk                                     ; 9533
        lsr     $BF                             ; 9534
        .byte   $02                             ; 9536
        brk                                     ; 9537
        .byte   $3A                             ; 9538
        .byte   $BF                             ; 9539
        .byte   $02                             ; 953A
        brk                                     ; 953B
        .byte   $2B                             ; 953C
        .byte   $BB                             ; 953D
        ora     ($00,x)                         ; 953E
        .byte   $2B                             ; 9540
        .byte   $B7                             ; 9541
        ora     ($00,x)                         ; 9542
        .byte   $2B                             ; 9544
        .byte   $B3                             ; 9545
        .byte   $02                             ; 9546
        brk                                     ; 9547
        .byte   $2B                             ; 9548
        brk                                     ; 9549
L954A:  .byte   $BF                             ; 954A
        brk                                     ; 954B
        .byte   $EF                             ; 954C
        brk                                     ; 954D
        cmp     ($09,x)                         ; 954E
        cmp     $FD00                           ; 9550
        brk                                     ; 9553
        cmp     ($09,x)                         ; 9554
        .byte   $BB                             ; 9556
        brk                                     ; 9557
        .byte   $EB                             ; 9558
        brk                                     ; 9559
        cmp     ($09,x)                         ; 955A
        .byte   $C9                             ; 955C
L955D:  brk                                     ; 955D
        sbc     $C100,y                         ; 955E
        ora     #$B7                            ; 9561
        brk                                     ; 9563
        .byte   $E7                             ; 9564
        brk                                     ; 9565
        lda     ($09),y                         ; 9566
        cmp     $01                             ; 9568
        brk                                     ; 956A
L956B:  tsx                                     ; 956B
        brk                                     ; 956C
        inx                                     ; 956D
        brk                                     ; 956E
        and     ($02),y                         ; 956F
        brk                                     ; 9571
        .byte   $1F                             ; 9572
        asl     $2F                             ; 9573
        asl     $3F                             ; 9575
        asl     $4F                             ; 9577
        asl     $5F                             ; 9579
        asl     $6F                             ; 957B
        asl     $7F                             ; 957D
        asl     $8F                             ; 957F
        asl     $9F                             ; 9581
        asl     $AF                             ; 9583
        asl     $BF                             ; 9585
        asl     $CF                             ; 9587
        asl     $DF                             ; 9589
        bpl     L956B                           ; 958B
        asl     a                               ; 958D
        cmp     $DC0A,x                         ; 958E
        asl     a                               ; 9591
        .byte   $DB                             ; 9592
        asl     a                               ; 9593
        .byte   $DA                             ; 9594
        asl     a                               ; 9595
        cmp     $D80A,y                         ; 9596
        asl     a                               ; 9599
        .byte   $D7                             ; 959A
        asl     a                               ; 959B
        dec     $0A,x                           ; 959C
        cmp     $0A,x                           ; 959E
        .byte   $D4                             ; 95A0
        asl     a                               ; 95A1
        .byte   $D3                             ; 95A2
        asl     a                               ; 95A3
        .byte   $D2                             ; 95A4
L95A5:  asl     a                               ; 95A5
        cmp     ($0A),y                         ; 95A6
        brk                                     ; 95A8
        .byte   $FF                             ; 95A9
        .byte   $80                             ; 95AA
        .byte   $EF                             ; 95AB
        .byte   $80                             ; 95AC
        .byte   $DF                             ; 95AD
        .byte   $80                             ; 95AE
        .byte   $CF                             ; 95AF
        .byte   $80                             ; 95B0
        .byte   $BF                             ; 95B1
        .byte   $80                             ; 95B2
        .byte   $AF                             ; 95B3
        .byte   $80                             ; 95B4
        .byte   $9F                             ; 95B5
        sta     $AF                             ; 95B6
        sta     ($AD),y                         ; 95B8
        sta     ($AB,x)                         ; 95BA
        sta     ($A9,x)                         ; 95BC
        sta     ($A7,x)                         ; 95BE
        sta     ($A5,x)                         ; 95C0
        sta     ($A3,x)                         ; 95C2
        sta     ($00,x)                         ; 95C4
        .byte   $CF                             ; 95C6
        .byte   $02                             ; 95C7
        .byte   $3F                             ; 95C8
        ora     ($00,x)                         ; 95C9
        .byte   $3B                             ; 95CB
        .byte   $02                             ; 95CC
        .byte   $5C                             ; 95CD
        ora     $7D                             ; 95CE
        .byte   $04                             ; 95D0
        .byte   $9E                             ; 95D1
        ora     $AF                             ; 95D2
        .byte   $04                             ; 95D4
        .byte   $BF                             ; 95D5
        .byte   $04                             ; 95D6
        .byte   $CF                             ; 95D7
        .byte   $03                             ; 95D8
        .byte   $DF                             ; 95D9
        .byte   $02                             ; 95DA
        .byte   $EF                             ; 95DB
        .byte   $2F                             ; 95DC
        brk                                     ; 95DD
        .byte   $8F                             ; 95DE
        .byte   $07                             ; 95DF
        .byte   $EF                             ; 95E0
        .byte   $03                             ; 95E1
        .byte   $CF                             ; 95E2
        .byte   $03                             ; 95E3
        .byte   $AF                             ; 95E4
        .byte   $03                             ; 95E5
        .byte   $BF                             ; 95E6
        ora     $8F                             ; 95E7
        .byte   $03                             ; 95E9
        .byte   $4F                             ; 95EA
        .byte   $03                             ; 95EB
        brk                                     ; 95EC
        .byte   $CF                             ; 95ED
        .byte   $02                             ; 95EE
        .byte   $AF                             ; 95EF
        .byte   $02                             ; 95F0
        .byte   $8F                             ; 95F1
        .byte   $03                             ; 95F2
        .byte   $6F                             ; 95F3
        .byte   $03                             ; 95F4
        .byte   $CF                             ; 95F5
        .byte   $02                             ; 95F6
        .byte   $AF                             ; 95F7
        .byte   $02                             ; 95F8
        .byte   $8F                             ; 95F9
        .byte   $03                             ; 95FA
        .byte   $6F                             ; 95FB
        .byte   $03                             ; 95FC
        .byte   $CF                             ; 95FD
        .byte   $04                             ; 95FE
        .byte   $AF                             ; 95FF
        .byte   $04                             ; 9600
        .byte   $8F                             ; 9601
        .byte   $04                             ; 9602
        .byte   $6F                             ; 9603
        .byte   $1B                             ; 9604
        .byte   $4F                             ; 9605
        .byte   $1C                             ; 9606
        .byte   $3F                             ; 9607
        ora     $BF00,x                         ; 9608
        brk                                     ; 960B
        .byte   $7F                             ; 960C
        brk                                     ; 960D
        .byte   $6F                             ; 960E
        brk                                     ; 960F
        .byte   $5F                             ; 9610
        brk                                     ; 9611
        .byte   $4F                             ; 9612
        brk                                     ; 9613
        .byte   $1F                             ; 9614
        ora     ($1D,x)                         ; 9615
        ora     ($1B,x)                         ; 9617
        ora     ($19,x)                         ; 9619
        ora     ($17,x)                         ; 961B
        ora     ($15,x)                         ; 961D
        ora     ($13,x)                         ; 961F
        ora     ($11,x)                         ; 9621
        ora     ($00,x)                         ; 9623
        .byte   $EF                             ; 9625
        .byte   $07                             ; 9626
        cpx     $E902                           ; 9627
        .byte   $02                             ; 962A
        inc     $02                             ; 962B
        brk                                     ; 962D
        .byte   $9F                             ; 962E
        brk                                     ; 962F
        .byte   $EF                             ; 9630
        ora     ($DF,x)                         ; 9631
        brk                                     ; 9633
        cmp     ($00),y                         ; 9634
        .byte   $EF                             ; 9636
        brk                                     ; 9637
        .byte   $5F                             ; 9638
        brk                                     ; 9639
        .byte   $BF                             ; 963A
        .byte   $03                             ; 963B
        ldy     $E902,x                         ; 963C
        .byte   $02                             ; 963F
        dec     $02,x                           ; 9640
        .byte   $E3                             ; 9642
        .byte   $02                             ; 9643
        brk                                     ; 9644
        .byte   $BF                             ; 9645
        .byte   $02                             ; 9646
        .byte   $3F                             ; 9647
        brk                                     ; 9648
        .byte   $4F                             ; 9649
        brk                                     ; 964A
        .byte   $5F                             ; 964B
        brk                                     ; 964C
        .byte   $6F                             ; 964D
        brk                                     ; 964E
        .byte   $7F                             ; 964F
        brk                                     ; 9650
        .byte   $AF                             ; 9651
        .byte   $02                             ; 9652
        .byte   $1F                             ; 9653
        .byte   $02                             ; 9654
        .byte   $2F                             ; 9655
        brk                                     ; 9656
        .byte   $3F                             ; 9657
        brk                                     ; 9658
        .byte   $4F                             ; 9659
        brk                                     ; 965A
        .byte   $5F                             ; 965B
        brk                                     ; 965C
        .byte   $6F                             ; 965D
        brk                                     ; 965E
        .byte   $7F                             ; 965F
        brk                                     ; 9660
        .byte   $8F                             ; 9661
        brk                                     ; 9662
        .byte   $9F                             ; 9663
        brk                                     ; 9664
        .byte   $AF                             ; 9665
        brk                                     ; 9666
        .byte   $BF                             ; 9667
        brk                                     ; 9668
        .byte   $CF                             ; 9669
        .byte   $04                             ; 966A
        cmp     $EC03,x                         ; 966B
        ora     $EA                             ; 966E
        .byte   $02                             ; 9670
        sbc     #$02                            ; 9671
        inx                                     ; 9673
        .byte   $02                             ; 9674
        .byte   $E7                             ; 9675
        .byte   $02                             ; 9676
        inc     $02                             ; 9677
        sbc     $05                             ; 9679
        brk                                     ; 967B
        .byte   $6F                             ; 967C
        brk                                     ; 967D
        .byte   $DF                             ; 967E
        .byte   $03                             ; 967F
        .byte   $8F                             ; 9680
        brk                                     ; 9681
        .byte   $7F                             ; 9682
        brk                                     ; 9683
        .byte   $6F                             ; 9684
        brk                                     ; 9685
        .byte   $5F                             ; 9686
        brk                                     ; 9687
        .byte   $4F                             ; 9688
        ora     ($00,x)                         ; 9689
        .byte   $9F                             ; 968B
        .byte   $03                             ; 968C
        .byte   $5F                             ; 968D
        .byte   $03                             ; 968E
        .byte   $9F                             ; 968F
        .byte   $03                             ; 9690
L9691:  .byte   $5F                             ; 9691
        .byte   $03                             ; 9692
        .byte   $9F                             ; 9693
        .byte   $03                             ; 9694
        .byte   $5F                             ; 9695
        .byte   $03                             ; 9696
        brk                                     ; 9697
        .byte   $CF                             ; 9698
        .byte   $82                             ; 9699
        .byte   $BF                             ; 969A
        .byte   $83                             ; 969B
        .byte   $AF                             ; 969C
        .byte   $03                             ; 969D
        .byte   $9F                             ; 969E
        stx     $9F                             ; 969F
        ora     $CE                             ; 96A1
        sta     $BD                             ; 96A3
        sty     $DC                             ; 96A5
        .byte   $83                             ; 96A7
        .byte   $EB                             ; 96A8
        .byte   $82                             ; 96A9
        .byte   $FA                             ; 96AA
        ora     ($00,x)                         ; 96AB
        cld                                     ; 96AD
        .byte   $03                             ; 96AE
        tax                                     ; 96AF
        ora     ($7C,x)                         ; 96B0
        ora     ($6E,x)                         ; 96B2
        .byte   $02                             ; 96B4
        dec     $03,x                           ; 96B5
        tay                                     ; 96B7
        ora     ($7A,x)                         ; 96B8
        ora     ($6C,x)                         ; 96BA
        .byte   $02                             ; 96BC
        cmp     $03,x                           ; 96BD
        .byte   $A7                             ; 96BF
        ora     ($79,x)                         ; 96C0
        ora     ($6B,x)                         ; 96C2
        .byte   $02                             ; 96C4
        .byte   $D4                             ; 96C5
        .byte   $03                             ; 96C6
        ldx     $01                             ; 96C7
        sei                                     ; 96C9
        ora     ($6A,x)                         ; 96CA
        .byte   $02                             ; 96CC
        brk                                     ; 96CD
        .byte   $EF                             ; 96CE
        .byte   $3F                             ; 96CF
        sbc     $EB03                           ; 96D0
        .byte   $03                             ; 96D3
        sbc     #$03                            ; 96D4
        .byte   $E7                             ; 96D6
        .byte   $03                             ; 96D7
        sbc     $03                             ; 96D8
        .byte   $E3                             ; 96DA
        .byte   $03                             ; 96DB
        brk                                     ; 96DC
        .byte   $A7                             ; 96DD
        .byte   $04                             ; 96DE
        lda     #$30                            ; 96DF
        .byte   $AB                             ; 96E1
        bmi     L9691                           ; 96E2
        php                                     ; 96E4
        ldy     $AA08                           ; 96E5
        php                                     ; 96E8
        tay                                     ; 96E9
        php                                     ; 96EA
        ldx     $08                             ; 96EB
        ldy     $08                             ; 96ED
        ldx     #$08                            ; 96EF
        brk                                     ; 96F1
        .byte   $44                             ; 96F2
        ora     $46                             ; 96F3
        ora     $48                             ; 96F5
        ora     $4A                             ; 96F7
        ora     $3C                             ; 96F9
        bpl     L9737                           ; 96FB
        bpl     L9737                           ; 96FD
        bpl     L9738                           ; 96FF
        bpl     L9739                           ; 9701
        bpl     L973A                           ; 9703
        bpl     L973B                           ; 9705
        bpl     L973C                           ; 9707
        bpl     L973D                           ; 9709
        rti                                     ; 970B

; ----------------------------------------------------------------------------
        brk                                     ; 970C
        ora     ($81,x)                         ; 970D
        bpl     L971D                           ; 970F
        ora     ($81,x)                         ; 9711
        bpl     L9727                           ; 9713
        ora     ($81,x)                         ; 9715
        bpl     L9721                           ; 9717
        ora     ($81,x)                         ; 9719
        bpl     L9725                           ; 971B
L971D:  ora     ($81,x)                         ; 971D
        brk                                     ; 971F
        .byte   $4D                             ; 9720
L9721:  sei                                     ; 9721
        eor     $4C78                           ; 9722
L9725:  php                                     ; 9725
        .byte   $4B                             ; 9726
L9727:  php                                     ; 9727
        lsr     a                               ; 9728
        php                                     ; 9729
        eor     #$08                            ; 972A
        pha                                     ; 972C
        php                                     ; 972D
        .byte   $47                             ; 972E
        php                                     ; 972F
        lsr     $08                             ; 9730
        eor     $08                             ; 9732
        .byte   $44                             ; 9734
        php                                     ; 9735
        .byte   $43                             ; 9736
L9737:  php                                     ; 9737
L9738:  .byte   $42                             ; 9738
L9739:  php                                     ; 9739
L973A:  .byte   $41                             ; 973A
L973B:  php                                     ; 973B
L973C:  brk                                     ; 973C
L973D:  rts                                     ; 973D

; ----------------------------------------------------------------------------
        lda     $FA                             ; 973E
        beq     L976E                           ; 9740
        cmp     #$14                            ; 9742
        bne     L9750                           ; 9744
        lda     $FE                             ; 9746
        beq     L974E                           ; 9748
        cmp     #$14                            ; 974A
        bne     L976E                           ; 974C
L974E:  lda     $FA                             ; 974E
L9750:  sta     $FE                             ; 9750
        asl     a                               ; 9752
        tay                                     ; 9753
        lda     $0394                           ; 9754
        lda     $B157,y                         ; 9757
        sta     $0158                           ; 975A
        lda     $B158,y                         ; 975D
        .byte   $8D                             ; 9760
        .byte   $59                             ; 9761
L9762:  ora     ($A9,x)                         ; 9762
        php                                     ; 9764
        sta     $0396                           ; 9765
        lda     #$00                            ; 9768
        sta     $FA                             ; 976A
        beq     L9779                           ; 976C
L976E:  lda     $FE                             ; 976E
        beq     L973D                           ; 9770
        lda     $015A                           ; 9772
        and     #$7F                            ; 9775
        bne     L97C2                           ; 9777
L9779:  lda     $0158                           ; 9779
        sta     $D0                             ; 977C
        lda     $0159                           ; 977E
        sta     $D1                             ; 9781
        ldy     #$00                            ; 9783
        lda     ($D0),y                         ; 9785
        beq     L97C6                           ; 9787
        cmp     #$01                            ; 9789
        beq     L97D3                           ; 978B
        pha                                     ; 978D
        and     #$0F                            ; 978E
        ora     #$F0                            ; 9790
        sta     $400C                           ; 9792
        lda     #$00                            ; 9795
        sta     $D5                             ; 9797
        iny                                     ; 9799
        lda     ($D0),y                         ; 979A
        sta     $015A                           ; 979C
        bpl     L97A4                           ; 979F
        sec                                     ; 97A1
        ror     $D5                             ; 97A2
L97A4:  pla                                     ; 97A4
        lsr     a                               ; 97A5
        lsr     a                               ; 97A6
        lsr     a                               ; 97A7
        lsr     a                               ; 97A8
        ora     $D5                             ; 97A9
        sta     $400E                           ; 97AB
        lda     #$88                            ; 97AE
        sta     $400F                           ; 97B0
        lda     $0158                           ; 97B3
        clc                                     ; 97B6
        adc     #$02                            ; 97B7
        sta     $0158                           ; 97B9
        bcc     L97C1                           ; 97BC
        inc     $0159                           ; 97BE
L97C1:  rts                                     ; 97C1

; ----------------------------------------------------------------------------
L97C2:  dec     $015A                           ; 97C2
        rts                                     ; 97C5

; ----------------------------------------------------------------------------
L97C6:  lda     #$00                            ; 97C6
        sta     $FE                             ; 97C8
        sta     $0396                           ; 97CA
        lda     #$30                            ; 97CD
        sta     $400C                           ; 97CF
        rts                                     ; 97D2

; ----------------------------------------------------------------------------
L97D3:  iny                                     ; 97D3
        lda     ($D0),y                         ; 97D4
        sta     $039A                           ; 97D6
        jsr     LB7B3                           ; 97D9
        jmp     LB779                           ; 97DC

; ----------------------------------------------------------------------------
        eor     $6001,y                         ; 97DF
        dec     $015A                           ; 97E2
        rts                                     ; 97E5

; ----------------------------------------------------------------------------
        lda     #$00                            ; 97E6
        sta     $FE                             ; 97E8
        sta     $0396                           ; 97EA
        lda     #$30                            ; 97ED
        sta     $400C                           ; 97EF
        rts                                     ; 97F2

; ----------------------------------------------------------------------------
        iny                                     ; 97F3
        lda     ($D0),y                         ; 97F4
        sta     $039A                           ; 97F6
        jsr     LB7D3                           ; 97F9
        jmp     LB799                           ; 97FC

; ----------------------------------------------------------------------------
        brk                                     ; 97FF
        ora     ($5F,x)                         ; 9800
        asl     a                               ; 9802
        .byte   $03                             ; 9803
        ora     ($00,x)                         ; 9804
        asl     $BC                             ; 9806
        ora     #$5E                            ; 9808
        ora     ($00,x)                         ; 980A
        and     $B8                             ; 980C
        and     $B8                             ; 980E
        ora     ($49,x)                         ; 9810
        asl     a                               ; 9812
        txa                                     ; 9813
        .byte   $02                             ; 9814
        ora     ($7A,x)                         ; 9815
        .byte   $07                             ; 9817
        .byte   $D3                             ; 9818
        ora     $5E                             ; 9819
        ora     ($05,x)                         ; 981B
        bcc     L9828                           ; 981D
        .byte   $04                             ; 981F
        ldy     $BC                             ; 9820
        .byte   $03                             ; 9822
        ora     $B8                             ; 9823
        ora     ($FF,x)                         ; 9825
        asl     a                               ; 9827
L9828:  brk                                     ; 9828
        brk                                     ; 9829
        .byte   $03                             ; 982A
        ora     $B8                             ; 982B
        ora     ($5F,x)                         ; 982D
        asl     a                               ; 982F
        ora     $03                             ; 9830
        .byte   $03                             ; 9832
        ora     $B8                             ; 9833
        ora     #$5D                            ; 9835
        ora     ($00,x)                         ; 9837
        and     $B8                             ; 9839
        and     $B8                             ; 983B
        ora     ($49,x)                         ; 983D
        asl     a                               ; 983F
        .byte   $89                             ; 9840
        .byte   $04                             ; 9841
        php                                     ; 9842
        lsr     a                               ; 9843
        clv                                     ; 9844
        .byte   $07                             ; 9845
        ora     $03                             ; 9846
        ora     $B8                             ; 9848
        .byte   $07                             ; 984A
        asl     $01                             ; 984B
        .byte   $7A                             ; 984D
        .byte   $07                             ; 984E
        .byte   $D4                             ; 984F
        ora     $5D                             ; 9850
        ora     ($05,x)                         ; 9852
        .byte   $34                             ; 9854
        ora     ($05,x)                         ; 9855
        and     $01                             ; 9857
        ora     $90                             ; 9859
        php                                     ; 985B
        .byte   $03                             ; 985C
        .byte   $1F                             ; 985D
        clv                                     ; 985E
        ora     ($FF,x)                         ; 985F
        ora     #$5D                            ; 9861
        ora     ($00,x)                         ; 9863
L9865:  .byte   $6F                             ; 9865
        clv                                     ; 9866
        .byte   $6F                             ; 9867
        clv                                     ; 9868
        asl     a                               ; 9869
        brk                                     ; 986A
        .byte   $07                             ; 986B
        .byte   $03                             ; 986C
        ora     $B8                             ; 986D
        asl     a                               ; 986F
        brk                                     ; 9870
        php                                     ; 9871
        ora     $0B                             ; 9872
        .byte   $54                             ; 9874
        .byte   $03                             ; 9875
        ora     $B8                             ; 9876
        ora     #$A1                            ; 9878
        ora     ($00,x)                         ; 987A
        and     $B8                             ; 987C
        and     $B8                             ; 987E
        ora     ($49,x)                         ; 9880
        .byte   $04                             ; 9882
        and     $BC,x                           ; 9883
        asl     a                               ; 9885
        ora     ($B5,x)                         ; 9886
        .byte   $04                             ; 9888
        .byte   $13                             ; 9889
        cpx     #$03                            ; 988A
        ora     $B8                             ; 988C
        ora     ($7B,x)                         ; 988E
        asl     a                               ; 9890
        .byte   $0F                             ; 9891
        ora     #$00                            ; 9892
        and     ($BC,x)                         ; 9894
        ora     ($4B,x)                         ; 9896
        asl     a                               ; 9898
        .byte   $07                             ; 9899
        asl     a                               ; 989A
        .byte   $07                             ; 989B
        .byte   $0B                             ; 989C
        .byte   $03                             ; 989D
        .byte   $93                             ; 989E
        clv                                     ; 989F
        ora     #$88                            ; 98A0
        ora     ($00,x)                         ; 98A2
        and     $B8                             ; 98A4
        and     $B8                             ; 98A6
        .byte   $03                             ; 98A8
        bvc     L9865                           ; 98A9
        ora     #$57                            ; 98AB
        ora     ($00,x)                         ; 98AD
        and     $B8                             ; 98AF
        and     $B8                             ; 98B1
        ora     ($49,x)                         ; 98B3
        ora     #$81                            ; 98B5
        ora     ($00,x)                         ; 98B7
        .byte   $CB                             ; 98B9
        clv                                     ; 98BA
        .byte   $CB                             ; 98BB
        clv                                     ; 98BC
        ora     #$82                            ; 98BD
        ora     ($00,x)                         ; 98BF
        .byte   $CB                             ; 98C1
        clv                                     ; 98C2
        .byte   $CB                             ; 98C3
        clv                                     ; 98C4
        asl     a                               ; 98C5
        .byte   $83                             ; 98C6
        .byte   $0C                             ; 98C7
        .byte   $03                             ; 98C8
        ora     $B8                             ; 98C9
        asl     a                               ; 98CB
        .byte   $83                             ; 98CC
        ora     $7A01                           ; 98CD
        .byte   $07                             ; 98D0
        cmp     $05,x                           ; 98D1
        .byte   $57                             ; 98D3
        ora     ($05,x)                         ; 98D4
        bcc     L98DA                           ; 98D6
        .byte   $03                             ; 98D8
        .byte   $1F                             ; 98D9
L98DA:  clv                                     ; 98DA
        ora     ($5F,x)                         ; 98DB
        ora     #$57                            ; 98DD
        ora     ($00,x)                         ; 98DF
        .byte   $EB                             ; 98E1
        clv                                     ; 98E2
        .byte   $EB                             ; 98E3
        clv                                     ; 98E4
        asl     a                               ; 98E5
        .byte   $03                             ; 98E6
        asl     $0503                           ; 98E7
        clv                                     ; 98EA
        ora     #$24                            ; 98EB
        ora     ($00,x)                         ; 98ED
        asl     $B9                             ; 98EF
        asl     $B9                             ; 98F1
        asl     a                               ; 98F3
        .byte   $03                             ; 98F4
        .byte   $0F                             ; 98F5
        php                                     ; 98F6
        inc     $07B8,x                         ; 98F7
        bpl     L98FF                           ; 98FA
        ora     $B8                             ; 98FC
        .byte   $07                             ; 98FE
L98FF:  ora     ($05),y                         ; 98FF
        bit     $01                             ; 9901
        .byte   $03                             ; 9903
        ora     $B8                             ; 9904
        ora     ($5F,x)                         ; 9906
        asl     a                               ; 9908
        .byte   $03                             ; 9909
        adc     $0503                           ; 990A
        clv                                     ; 990D
        ora     #$56                            ; 990E
        ora     ($00,x)                         ; 9910
        and     $B8                             ; 9912
        and     $B8                             ; 9914
        ora     ($49,x)                         ; 9916
        ora     #$57                            ; 9918
        ora     ($00,x)                         ; 991A
        rol     $B9                             ; 991C
        rol     $B9                             ; 991E
        asl     a                               ; 9920
        .byte   $82                             ; 9921
        .byte   $12                             ; 9922
        .byte   $03                             ; 9923
        ora     $B8                             ; 9924
        ora     #$24                            ; 9926
        ora     ($00,x)                         ; 9928
        .byte   $34                             ; 992A
        lda     $B934,y                         ; 992B
        asl     a                               ; 992E
        .byte   $82                             ; 992F
        .byte   $13                             ; 9930
        .byte   $03                             ; 9931
        ora     $B8                             ; 9932
        asl     a                               ; 9934
        .byte   $82                             ; 9935
L9936:  .byte   $14                             ; 9936
        ora     ($7A,x)                         ; 9937
        .byte   $07                             ; 9939
        dec     $05,x                           ; 993A
        lsr     $01,x                           ; 993C
        ora     $90                             ; 993E
        ora     ($03,x)                         ; 9940
        .byte   $1F                             ; 9942
        clv                                     ; 9943
        ora     #$5B                            ; 9944
        ora     ($00,x)                         ; 9946
        and     $B8                             ; 9948
        and     $B8                             ; 994A
        ora     ($49,x)                         ; 994C
        asl     a                               ; 994E
        .byte   $87                             ; 994F
        ora     $01,x                           ; 9950
        .byte   $7A                             ; 9952
        .byte   $07                             ; 9953
        .byte   $D7                             ; 9954
        ora     $5B                             ; 9955
        ora     ($05,x)                         ; 9957
        bcc     L9961                           ; 9959
        .byte   $03                             ; 995B
        .byte   $1F                             ; 995C
        clv                                     ; 995D
        ora     #$A3                            ; 995E
        .byte   $01                             ; 9960
L9961:  brk                                     ; 9961
        and     $B8                             ; 9962
        and     $B8                             ; 9964
        .byte   $03                             ; 9966
        .byte   $80                             ; 9967
        clv                                     ; 9968
        ora     ($7B,x)                         ; 9969
        asl     a                               ; 996B
        bpl     L9984                           ; 996C
        .byte   $03                             ; 996E
        .byte   $93                             ; 996F
        clv                                     ; 9970
        ora     #$86                            ; 9971
        ora     ($00,x)                         ; 9973
        and     $B8                             ; 9975
        and     $B8                             ; 9977
        .byte   $03                             ; 9979
        bvc     L9936                           ; 997A
        ora     ($5F,x)                         ; 997C
        asl     a                               ; 997E
        asl     $17                             ; 997F
        .byte   $03                             ; 9981
        ora     $B8                             ; 9982
L9984:  ora     ($5F,x)                         ; 9984
        ora     #$72                            ; 9986
        ora     ($00,x)                         ; 9988
        stx     L94B9                           ; 998A
        lda     $060A,y                         ; 998D
        asl     $0503,x                         ; 9990
        clv                                     ; 9993
        ora     #$2E                            ; 9994
        .byte   $04                             ; 9996
        brk                                     ; 9997
        lda     $BDB9,x                         ; 9998
        lda     $060A,y                         ; 999B
        clc                                     ; 999E
        php                                     ; 999F
        .byte   $A7                             ; 99A0
        lda     $1907,y                         ; 99A1
        .byte   $03                             ; 99A4
        ora     $B8                             ; 99A5
        .byte   $07                             ; 99A7
        .byte   $1A                             ; 99A8
        .byte   $0B                             ; 99A9
        brk                                     ; 99AA
        clv                                     ; 99AB
        lda     $1B07,y                         ; 99AC
        ora     $2E                             ; 99AF
        .byte   $04                             ; 99B1
        .byte   $04                             ; 99B2
        tsx                                     ; 99B3
        inc     $03,x                           ; 99B4
        .byte   $05                             ; 99B6
L99B7:  clv                                     ; 99B7
L99B8:  .byte   $07                             ; 99B8
        .byte   $1C                             ; 99B9
        .byte   $03                             ; 99BA
L99BB:  ora     $B8                             ; 99BB
        asl     a                               ; 99BD
        asl     $1D                             ; 99BE
        .byte   $03                             ; 99C0
        ora     $B8                             ; 99C1
        ora     #$58                            ; 99C3
        brk                                     ; 99C5
        brk                                     ; 99C6
        cmp     $B9,x                           ; 99C7
        .byte   $CB                             ; 99C9
        lda     $4901,y                         ; 99CA
        ora     #$2E                            ; 99CD
        .byte   $04                             ; 99CF
        brk                                     ; 99D0
        cmp     $DDB9,x                         ; 99D1
        lda     $4901,y                         ; 99D4
        asl     a                               ; 99D7
        ora     ($1F,x)                         ; 99D8
        .byte   $03                             ; 99DA
        ora     $B8                             ; 99DB
        asl     a                               ; 99DD
        ora     ($20,x)                         ; 99DE
        .byte   $04                             ; 99E0
        txa                                     ; 99E1
        ldy     L840A,x                         ; 99E2
        and     ($05,x)                         ; 99E5
        cli                                     ; 99E7
        ora     ($01,x)                         ; 99E8
        .byte   $7A                             ; 99EA
        .byte   $07                             ; 99EB
        cld                                     ; 99EC
        ora     $90                             ; 99ED
        .byte   $03                             ; 99EF
        .byte   $03                             ; 99F0
        .byte   $1F                             ; 99F1
        clv                                     ; 99F2
        ora     #$42                            ; 99F3
        .byte   $04                             ; 99F5
        brk                                     ; 99F6
        .byte   $0C                             ; 99F7
        tsx                                     ; 99F8
        .byte   $0C                             ; 99F9
        tsx                                     ; 99FA
        ora     ($49,x)                         ; 99FB
        asl     a                               ; 99FD
        brk                                     ; 99FE
        .byte   $22                             ; 99FF
        .byte   $04                             ; 9A00
        .byte   $13                             ; 9A01
        cpx     #$05                            ; 9A02
        .byte   $42                             ; 9A04
        .byte   $04                             ; 9A05
        .byte   $04                             ; 9A06
        tsx                                     ; 9A07
        inc     $03,x                           ; 9A08
        ora     $B8                             ; 9A0A
        ora     ($FF,x)                         ; 9A0C
        asl     a                               ; 9A0E
        brk                                     ; 9A0F
        .byte   $23                             ; 9A10
        .byte   $03                             ; 9A11
        ora     $B8                             ; 9A12
        ora     #$5A                            ; 9A14
        ora     ($00,x)                         ; 9A16
        and     $B8                             ; 9A18
        and     $B8                             ; 9A1A
        ora     ($49,x)                         ; 9A1C
        asl     a                               ; 9A1E
        stx     $24                             ; 9A1F
        php                                     ; 9A21
        rol     a                               ; 9A22
        tsx                                     ; 9A23
        .byte   $04                             ; 9A24
        .byte   $5B                             ; 9A25
        ldy     $0503,x                         ; 9A26
        clv                                     ; 9A29
        .byte   $07                             ; 9A2A
        rol     $03                             ; 9A2B
        ora     $B8                             ; 9A2D
        ora     ($FF,x)                         ; 9A2F
        ora     #$5A                            ; 9A31
        ora     ($00,x)                         ; 9A33
        .byte   $3F                             ; 9A35
        tsx                                     ; 9A36
        .byte   $3F                             ; 9A37
        tsx                                     ; 9A38
        asl     a                               ; 9A39
        brk                                     ; 9A3A
        plp                                     ; 9A3B
        .byte   $03                             ; 9A3C
        ora     $B8                             ; 9A3D
        asl     a                               ; 9A3F
        brk                                     ; 9A40
        and     #$05                            ; 9A41
        .byte   $0B                             ; 9A43
        sta     $03                             ; 9A44
        ora     $B8                             ; 9A46
        ora     #$86                            ; 9A48
        ora     ($00,x)                         ; 9A4A
        and     $B8                             ; 9A4C
        and     $B8                             ; 9A4E
        ora     ($48,x)                         ; 9A50
        asl     a                               ; 9A52
        .byte   $04                             ; 9A53
        rol     a                               ; 9A54
        .byte   $04                             ; 9A55
        sed                                     ; 9A56
        .byte   $BB                             ; 9A57
        .byte   $03                             ; 9A58
        ora     $B8                             ; 9A59
        ora     #$A4                            ; 9A5B
        ora     ($00,x)                         ; 9A5D
        and     $B8                             ; 9A5F
        and     $B8                             ; 9A61
        .byte   $03                             ; 9A63
        .byte   $80                             ; 9A64
        clv                                     ; 9A65
        ora     ($7B,x)                         ; 9A66
        asl     a                               ; 9A68
        ora     ($2B),y                         ; 9A69
        .byte   $03                             ; 9A6B
        .byte   $93                             ; 9A6C
        clv                                     ; 9A6D
        ora     #$59                            ; 9A6E
        ora     ($00,x)                         ; 9A70
        and     $B8                             ; 9A72
        and     $B8                             ; 9A74
        ora     ($49,x)                         ; 9A76
        asl     a                               ; 9A78
        sta     $2C                             ; 9A79
        ora     ($7A,x)                         ; 9A7B
        .byte   $07                             ; 9A7D
        .byte   $DA                             ; 9A7E
        ora     $59                             ; 9A7F
        ora     ($05,x)                         ; 9A81
        .byte   $23                             ; 9A83
        ora     ($05,x)                         ; 9A84
        bcc     L9A8C                           ; 9A86
        .byte   $03                             ; 9A88
        .byte   $1F                             ; 9A89
        clv                                     ; 9A8A
        .byte   $09                             ; 9A8B
L9A8C:  .byte   $5C                             ; 9A8C
        ora     ($00,x)                         ; 9A8D
        and     $B8                             ; 9A8F
        and     $B8                             ; 9A91
        ora     ($49,x)                         ; 9A93
        ora     #$72                            ; 9A95
        brk                                     ; 9A97
        brk                                     ; 9A98
        sta     $A3BA,x                         ; 9A99
        tsx                                     ; 9A9C
        asl     a                               ; 9A9D
        dey                                     ; 9A9E
        and     $0503                           ; 9A9F
        clv                                     ; 9AA2
        asl     a                               ; 9AA3
        dey                                     ; 9AA4
        rol     $AE08                           ; 9AA5
        tsx                                     ; 9AA8
        .byte   $07                             ; 9AA9
        .byte   $2F                             ; 9AAA
        brk                                     ; 9AAB
        inc     $07BB,x                         ; 9AAC
        bmi     L9AB9                           ; 9AAF
        clv                                     ; 9AB1
        tsx                                     ; 9AB2
        .byte   $07                             ; 9AB3
        and     ($03),y                         ; 9AB4
        .byte   $AB                             ; 9AB6
        tsx                                     ; 9AB7
        .byte   $07                             ; 9AB8
L9AB9:  .byte   $32                             ; 9AB9
        ora     ($7A,x)                         ; 9ABA
        .byte   $07                             ; 9ABC
        .byte   $DB                             ; 9ABD
        ora     $5C                             ; 9ABE
        ora     ($05,x)                         ; 9AC0
        bcc     L9ACB                           ; 9AC2
        .byte   $03                             ; 9AC4
        .byte   $1F                             ; 9AC5
        clv                                     ; 9AC6
        ora     ($FF,x)                         ; 9AC7
        asl     a                               ; 9AC9
        brk                                     ; 9ACA
L9ACB:  .byte   $33                             ; 9ACB
        ora     $0B                             ; 9ACC
        pla                                     ; 9ACE
        .byte   $03                             ; 9ACF
        ora     $B8                             ; 9AD0
        ora     #$42                            ; 9AD2
L9AD4:  ora     $00                             ; 9AD4
        .byte   $EB                             ; 9AD6
        tsx                                     ; 9AD7
        .byte   $EB                             ; 9AD8
        tsx                                     ; 9AD9
        ora     ($49,x)                         ; 9ADA
        asl     a                               ; 9ADC
        brk                                     ; 9ADD
        .byte   $34                             ; 9ADE
        .byte   $04                             ; 9ADF
        .byte   $13                             ; 9AE0
        cpx     #$05                            ; 9AE1
        .byte   $42                             ; 9AE3
        ora     $04                             ; 9AE4
        tsx                                     ; 9AE6
        inc     $03,x                           ; 9AE7
        ora     $B8                             ; 9AE9
        asl     a                               ; 9AEB
        brk                                     ; 9AEC
        .byte   $23                             ; 9AED
        .byte   $03                             ; 9AEE
        ora     $B8                             ; 9AEF
        ora     #$A2                            ; 9AF1
        ora     ($00,x)                         ; 9AF3
        and     $B8                             ; 9AF5
        and     $B8                             ; 9AF7
        .byte   $03                             ; 9AF9
        .byte   $80                             ; 9AFA
        clv                                     ; 9AFB
        ora     ($7B,x)                         ; 9AFC
        asl     a                               ; 9AFE
        ora     #$35                            ; 9AFF
        .byte   $03                             ; 9B01
        .byte   $93                             ; 9B02
        clv                                     ; 9B03
        ora     #$A3                            ; 9B04
        ora     ($00,x)                         ; 9B06
        and     $B8                             ; 9B08
        and     $B8                             ; 9B0A
        .byte   $03                             ; 9B0C
        .byte   $80                             ; 9B0D
        clv                                     ; 9B0E
        ora     #$87                            ; 9B0F
        ora     ($00,x)                         ; 9B11
        and     $B8                             ; 9B13
        and     $B8                             ; 9B15
        .byte   $03                             ; 9B17
        bvc     L9AD4                           ; 9B18
        ora     #$5F                            ; 9B1A
        ora     ($00,x)                         ; 9B1C
        and     $B8                             ; 9B1E
        and     $B8                             ; 9B20
        ora     ($49,x)                         ; 9B22
        asl     a                               ; 9B24
        .byte   $8B                             ; 9B25
        .byte   $37                             ; 9B26
        ora     $5F                             ; 9B27
        ora     ($01,x)                         ; 9B29
        .byte   $7A                             ; 9B2B
        .byte   $07                             ; 9B2C
        .byte   $DC                             ; 9B2D
        ora     $90                             ; 9B2E
        asl     a                               ; 9B30
        .byte   $03                             ; 9B31
        .byte   $1F                             ; 9B32
        clv                                     ; 9B33
        ora     ($5F,x)                         ; 9B34
        ora     #$42                            ; 9B36
        asl     $00                             ; 9B38
        .byte   $44                             ; 9B3A
        .byte   $BB                             ; 9B3B
        .byte   $44                             ; 9B3C
        .byte   $BB                             ; 9B3D
        asl     a                               ; 9B3E
        .byte   $03                             ; 9B3F
        sec                                     ; 9B40
        .byte   $03                             ; 9B41
        ora     $B8                             ; 9B42
        asl     a                               ; 9B44
        .byte   $03                             ; 9B45
        and     $0503,y                         ; 9B46
        clv                                     ; 9B49
        ora     #$42                            ; 9B4A
        asl     $00                             ; 9B4C
        .byte   $67                             ; 9B4E
        .byte   $BB                             ; 9B4F
        .byte   $67                             ; 9B50
        .byte   $BB                             ; 9B51
        ora     ($49,x)                         ; 9B52
        asl     a                               ; 9B54
        brk                                     ; 9B55
        .byte   $3B                             ; 9B56
        .byte   $07                             ; 9B57
        .byte   $3C                             ; 9B58
        .byte   $04                             ; 9B59
        .byte   $13                             ; 9B5A
        cpx     #$07                            ; 9B5B
        and     $4205,x                         ; 9B5D
        asl     $04                             ; 9B60
        tsx                                     ; 9B62
        inc     $03,x                           ; 9B63
        ora     $B8                             ; 9B65
        asl     a                               ; 9B67
        brk                                     ; 9B68
        and     $0503,x                         ; 9B69
        clv                                     ; 9B6C
        ora     ($5F,x)                         ; 9B6D
        ora     #$22                            ; 9B6F
        .byte   $02                             ; 9B71
        brk                                     ; 9B72
        .byte   $83                             ; 9B73
        .byte   $BB                             ; 9B74
        .byte   $83                             ; 9B75
        .byte   $BB                             ; 9B76
        ora     $22                             ; 9B77
        .byte   $02                             ; 9B79
        .byte   $04                             ; 9B7A
        tsx                                     ; 9B7B
        inc     $0A,x                           ; 9B7C
        brk                                     ; 9B7E
        rol     $0503,x                         ; 9B7F
        clv                                     ; 9B82
        asl     a                               ; 9B83
        brk                                     ; 9B84
        .byte   $3F                             ; 9B85
        .byte   $03                             ; 9B86
        ora     $B8                             ; 9B87
        ora     ($FF,x)                         ; 9B89
        ora     #$5F                            ; 9B8B
        ora     ($00,x)                         ; 9B8D
        sta     L99BB,y                         ; 9B8F
        .byte   $BB                             ; 9B92
        asl     a                               ; 9B93
        brk                                     ; 9B94
        eor     ($03,x)                         ; 9B95
        ora     $B8                             ; 9B97
        ora     #$22                            ; 9B99
        .byte   $02                             ; 9B9B
        brk                                     ; 9B9C
        .byte   $A7                             ; 9B9D
        .byte   $BB                             ; 9B9E
        .byte   $A7                             ; 9B9F
        .byte   $BB                             ; 9BA0
        asl     a                               ; 9BA1
        brk                                     ; 9BA2
        .byte   $42                             ; 9BA3
        .byte   $03                             ; 9BA4
        ora     $B8                             ; 9BA5
        ora     $0B                             ; 9BA7
        eor     $00                             ; 9BA9
        .byte   $0B                             ; 9BAB
        ldy     $2E09,x                         ; 9BAC
        asl     $00                             ; 9BAF
        .byte   $25                             ; 9BB1
L9BB2:  clv                                     ; 9BB2
        and     $B8                             ; 9BB3
        ora     ($4B,x)                         ; 9BB5
        asl     a                               ; 9BB7
        .byte   $07                             ; 9BB8
        .byte   $43                             ; 9BB9
        .byte   $0B                             ; 9BBA
        ora     ($D5,x)                         ; 9BBB
        .byte   $BB                             ; 9BBD
        .byte   $07                             ; 9BBE
        lsr     a                               ; 9BBF
        ora     ($63,x)                         ; 9BC0
        ora     $55                             ; 9BC2
        brk                                     ; 9BC4
        asl     a                               ; 9BC5
        .byte   $12                             ; 9BC6
        .byte   $4B                             ; 9BC7
        .byte   $07                             ; 9BC8
        jmp     L4D07                           ; 9BC9

; ----------------------------------------------------------------------------
        ora     $2E                             ; 9BCC
        asl     $04                             ; 9BCE
        tsx                                     ; 9BD0
        inc     $03,x                           ; 9BD1
        ora     $B8                             ; 9BD3
        .byte   $07                             ; 9BD5
        lsr     $AB03                           ; 9BD6
        tsx                                     ; 9BD9
        ora     ($5F,x)                         ; 9BDA
        asl     a                               ; 9BDC
        ora     ($4F,x)                         ; 9BDD
        .byte   $03                             ; 9BDF
        ora     $B8                             ; 9BE0
        ora     #$A0                            ; 9BE2
        ora     ($00,x)                         ; 9BE4
        and     $B8                             ; 9BE6
        and     $B8                             ; 9BE8
        .byte   $03                             ; 9BEA
        .byte   $80                             ; 9BEB
        clv                                     ; 9BEC
        ora     #$88                            ; 9BED
        ora     ($00,x)                         ; 9BEF
        and     $B8                             ; 9BF1
        and     $B8                             ; 9BF3
        .byte   $03                             ; 9BF5
        bvc     L9BB2                           ; 9BF6
        lda     #$05                            ; 9BF8
        jsr     LE021                           ; 9BFA
        rts                                     ; 9BFD

; ----------------------------------------------------------------------------
        jsr     LBC06                           ; 9BFE
        lda     #$00                            ; 9C01
        sta     $80                             ; 9C03
        rts                                     ; 9C05

; ----------------------------------------------------------------------------
        lda     #$01                            ; 9C06
        jsr     LA195                           ; 9C08
        ldx     $04E1                           ; 9C0B
        lda     $0480,x                         ; 9C0E
        bne     L9C16                           ; 9C11
        inc     $0480,x                         ; 9C13
L9C16:  jsr     LA0F0                           ; 9C16
        lda     #$01                            ; 9C19
        sta     $18                             ; 9C1B
        jsr     LE95B                           ; 9C1D
        rts                                     ; 9C20

; ----------------------------------------------------------------------------
        lda     #$80                            ; 9C21
        jsr     LA195                           ; 9C23
        ldx     $04E1                           ; 9C26
        lda     $0480,x                         ; 9C29
        bne     L9C31                           ; 9C2C
        inc     $0480,x                         ; 9C2E
L9C31:  jsr     LE95B                           ; 9C31
        rts                                     ; 9C34

; ----------------------------------------------------------------------------
        ldx     $82                             ; 9C35
        lda     $BC56,x                         ; 9C37
        tax                                     ; 9C3A
        lda     $82                             ; 9C3B
        cmp     #$03                            ; 9C3D
        bne     L9C4A                           ; 9C3F
        lda     $04E1                           ; 9C41
        cmp     #$06                            ; 9C44
        bne     L9C4A                           ; 9C46
        ldx     #$03                            ; 9C48
L9C4A:  lda     #$01                            ; 9C4A
        sta     $03E0,x                         ; 9C4C
        txa                                     ; 9C4F
        ora     #$80                            ; 9C50
        sta     $0540                           ; 9C52
        rts                                     ; 9C55

; ----------------------------------------------------------------------------
        ora     ($03,x)                         ; 9C56
        .byte   $04                             ; 9C58
        .byte   $02                             ; 9C59
        brk                                     ; 9C5A
        lda     #$64                            ; 9C5B
        jsr     LE017                           ; 9C5D
        bcs     L9C68                           ; 9C60
        lda     #$27                            ; 9C62
        jsr     LA91A                           ; 9C64
        rts                                     ; 9C67

; ----------------------------------------------------------------------------
L9C68:  dec     $89                             ; 9C68
        lda     #$25                            ; 9C6A
        jsr     LA91A                           ; 9C6C
        lda     #$7A                            ; 9C6F
        jsr     LE992                           ; 9C71
        lda     #$D9                            ; 9C74
        jsr     LA91A                           ; 9C76
        lda     #$01                            ; 9C79
        sta     $033A                           ; 9C7B
        lda     #$05                            ; 9C7E
        sta     $0490                           ; 9C80
        jsr     LBCA4                           ; 9C83
        jsr     LEAC1                           ; 9C86
        rts                                     ; 9C89

; ----------------------------------------------------------------------------
        lda     $11                             ; 9C8A
        and     #$E7                            ; 9C8C
        sta     $11                             ; 9C8E
        lda     #$80                            ; 9C90
        jsr     LE992                           ; 9C92
        ldx     #$78                            ; 9C95
L9C97:  jsr     LE95B                           ; 9C97
        dex                                     ; 9C9A
        bne     L9C97                           ; 9C9B
        lda     $11                             ; 9C9D
        ora     #$18                            ; 9C9F
        sta     $11                             ; 9CA1
        rts                                     ; 9CA3

; ----------------------------------------------------------------------------
        clc                                     ; 9CA4
        lda     $84                             ; 9CA5
        adc     #$05                            ; 9CA7
        ldx     $0490                           ; 9CA9
        sec                                     ; 9CAC
        sbc     $BCC4,x                         ; 9CAD
        asl     a                               ; 9CB0
        tay                                     ; 9CB1
        lda     $0490                           ; 9CB2
        asl     a                               ; 9CB5
        tax                                     ; 9CB6
        lda     $BCCF,y                         ; 9CB7
        sta     $03C0,x                         ; 9CBA
        lda     $BCD0,y                         ; 9CBD
        sta     $03C1,x                         ; 9CC0
        rts                                     ; 9CC3

; ----------------------------------------------------------------------------
        ora     $07                             ; 9CC4
        .byte   $04                             ; 9CC6
        .byte   $04                             ; 9CC7
        asl     $03                             ; 9CC8
        asl     $05                             ; 9CCA
        ora     $01                             ; 9CCC
        brk                                     ; 9CCE
        .byte   $14                             ; 9CCF
        asl     a                               ; 9CD0
        ora     $1E0A,y                         ; 9CD1
        asl     a                               ; 9CD4
        .byte   $22                             ; 9CD5
        asl     a                               ; 9CD6
        rol     a                               ; 9CD7
        .byte   $0C                             ; 9CD8
        .byte   $32                             ; 9CD9
        bpl     L9D16                           ; 9CDA
        .byte   $14                             ; 9CDC
        .byte   $42                             ; 9CDD
        .byte   $34                             ; 9CDE
        lsr     a                               ; 9CDF
        .byte   $44                             ; 9CE0
        .byte   $52                             ; 9CE1
        lsr     $545A                           ; 9CE2
        .byte   $62                             ; 9CE5
        lsr     $6474,x                         ; 9CE6
        .byte   $7C                             ; 9CE9
        jmp     (L7384)                         ; 9CEA

; ----------------------------------------------------------------------------
        sty     L9494                           ; 9CED
        .byte   $9B                             ; 9CF0
        .byte   $9C                             ; 9CF1
        lda     $A4                             ; 9CF2
        ldy     $AC,x                           ; 9CF4
        lda     $BEB4,y                         ; 9CF6
        ldy     $C4C8,x                         ; 9CF9
        cpy     $D0CC                           ; 9CFC
        .byte   $D4                             ; 9CFF
        .byte   $DA                             ; 9D00
        .byte   $DC                             ; 9D01
        .byte   $DC                             ; 9D02
        cpx     $E4                             ; 9D03
        cpx     $F4EC                           ; 9D05
        sbc     $FF,x                           ; 9D08
        .byte   $FF                             ; 9D0A
        cpy     $CC                             ; 9D0B
        cpy     $D4D0                           ; 9D0D
        .byte   $DA                             ; 9D10
        .byte   $DC                             ; 9D11
        .byte   $DC                             ; 9D12
        cpx     $E4                             ; 9D13
        .byte   $EC                             ; 9D15
L9D16:  cpx     $F5F4                           ; 9D16
        .byte   $FF                             ; 9D19
        .byte   $FF                             ; 9D1A
        brk                                     ; 9D1B
        brk                                     ; 9D1C
        brk                                     ; 9D1D
        brk                                     ; 9D1E
        brk                                     ; 9D1F
        brk                                     ; 9D20
        brk                                     ; 9D21
        brk                                     ; 9D22
        brk                                     ; 9D23
        brk                                     ; 9D24
        brk                                     ; 9D25
        brk                                     ; 9D26
        brk                                     ; 9D27
        brk                                     ; 9D28
        brk                                     ; 9D29
        brk                                     ; 9D2A
        brk                                     ; 9D2B
        brk                                     ; 9D2C
        brk                                     ; 9D2D
        brk                                     ; 9D2E
        brk                                     ; 9D2F
        brk                                     ; 9D30
        brk                                     ; 9D31
        brk                                     ; 9D32
        brk                                     ; 9D33
        brk                                     ; 9D34
        brk                                     ; 9D35
        brk                                     ; 9D36
        brk                                     ; 9D37
        brk                                     ; 9D38
        brk                                     ; 9D39
        brk                                     ; 9D3A
        brk                                     ; 9D3B
        brk                                     ; 9D3C
        brk                                     ; 9D3D
        brk                                     ; 9D3E
        brk                                     ; 9D3F
        brk                                     ; 9D40
        brk                                     ; 9D41
        brk                                     ; 9D42
        brk                                     ; 9D43
        brk                                     ; 9D44
        brk                                     ; 9D45
        brk                                     ; 9D46
        brk                                     ; 9D47
        brk                                     ; 9D48
        brk                                     ; 9D49
        brk                                     ; 9D4A
        brk                                     ; 9D4B
        brk                                     ; 9D4C
        brk                                     ; 9D4D
        brk                                     ; 9D4E
        brk                                     ; 9D4F
        brk                                     ; 9D50
        brk                                     ; 9D51
        brk                                     ; 9D52
        brk                                     ; 9D53
        brk                                     ; 9D54
        brk                                     ; 9D55
        brk                                     ; 9D56
        brk                                     ; 9D57
        brk                                     ; 9D58
        brk                                     ; 9D59
        brk                                     ; 9D5A
        brk                                     ; 9D5B
        brk                                     ; 9D5C
        brk                                     ; 9D5D
        brk                                     ; 9D5E
        brk                                     ; 9D5F
        brk                                     ; 9D60
        brk                                     ; 9D61
        brk                                     ; 9D62
        brk                                     ; 9D63
        brk                                     ; 9D64
        brk                                     ; 9D65
        brk                                     ; 9D66
        brk                                     ; 9D67
        brk                                     ; 9D68
        brk                                     ; 9D69
        brk                                     ; 9D6A
        brk                                     ; 9D6B
        brk                                     ; 9D6C
        brk                                     ; 9D6D
        brk                                     ; 9D6E
        brk                                     ; 9D6F
        brk                                     ; 9D70
        brk                                     ; 9D71
        brk                                     ; 9D72
        brk                                     ; 9D73
        brk                                     ; 9D74
        brk                                     ; 9D75
        brk                                     ; 9D76
        brk                                     ; 9D77
        brk                                     ; 9D78
        brk                                     ; 9D79
        brk                                     ; 9D7A
        brk                                     ; 9D7B
        brk                                     ; 9D7C
        brk                                     ; 9D7D
        brk                                     ; 9D7E
        brk                                     ; 9D7F
        brk                                     ; 9D80
        brk                                     ; 9D81
        brk                                     ; 9D82
        brk                                     ; 9D83
        brk                                     ; 9D84
        brk                                     ; 9D85
        brk                                     ; 9D86
        brk                                     ; 9D87
        brk                                     ; 9D88
        brk                                     ; 9D89
        brk                                     ; 9D8A
        brk                                     ; 9D8B
        brk                                     ; 9D8C
        brk                                     ; 9D8D
        brk                                     ; 9D8E
        brk                                     ; 9D8F
        brk                                     ; 9D90
        brk                                     ; 9D91
        brk                                     ; 9D92
        brk                                     ; 9D93
        brk                                     ; 9D94
        brk                                     ; 9D95
        brk                                     ; 9D96
        brk                                     ; 9D97
        brk                                     ; 9D98
        brk                                     ; 9D99
        brk                                     ; 9D9A
        brk                                     ; 9D9B
        brk                                     ; 9D9C
        brk                                     ; 9D9D
        brk                                     ; 9D9E
        brk                                     ; 9D9F
        brk                                     ; 9DA0
        brk                                     ; 9DA1
        brk                                     ; 9DA2
        brk                                     ; 9DA3
        brk                                     ; 9DA4
        brk                                     ; 9DA5
        brk                                     ; 9DA6
        brk                                     ; 9DA7
        brk                                     ; 9DA8
        brk                                     ; 9DA9
        brk                                     ; 9DAA
        brk                                     ; 9DAB
        brk                                     ; 9DAC
        brk                                     ; 9DAD
        brk                                     ; 9DAE
        brk                                     ; 9DAF
        brk                                     ; 9DB0
        brk                                     ; 9DB1
        brk                                     ; 9DB2
        brk                                     ; 9DB3
        brk                                     ; 9DB4
        brk                                     ; 9DB5
        brk                                     ; 9DB6
        brk                                     ; 9DB7
        brk                                     ; 9DB8
        brk                                     ; 9DB9
        brk                                     ; 9DBA
        brk                                     ; 9DBB
        brk                                     ; 9DBC
        brk                                     ; 9DBD
        brk                                     ; 9DBE
        brk                                     ; 9DBF
        brk                                     ; 9DC0
        brk                                     ; 9DC1
        brk                                     ; 9DC2
        brk                                     ; 9DC3
        brk                                     ; 9DC4
        brk                                     ; 9DC5
        brk                                     ; 9DC6
        brk                                     ; 9DC7
        brk                                     ; 9DC8
        brk                                     ; 9DC9
        brk                                     ; 9DCA
        brk                                     ; 9DCB
        brk                                     ; 9DCC
        brk                                     ; 9DCD
        brk                                     ; 9DCE
        brk                                     ; 9DCF
        brk                                     ; 9DD0
        brk                                     ; 9DD1
        brk                                     ; 9DD2
        brk                                     ; 9DD3
        brk                                     ; 9DD4
        brk                                     ; 9DD5
        brk                                     ; 9DD6
        brk                                     ; 9DD7
        brk                                     ; 9DD8
        brk                                     ; 9DD9
        brk                                     ; 9DDA
        brk                                     ; 9DDB
        brk                                     ; 9DDC
        brk                                     ; 9DDD
        brk                                     ; 9DDE
        brk                                     ; 9DDF
        brk                                     ; 9DE0
        brk                                     ; 9DE1
        brk                                     ; 9DE2
        brk                                     ; 9DE3
        brk                                     ; 9DE4
        brk                                     ; 9DE5
        brk                                     ; 9DE6
        brk                                     ; 9DE7
        brk                                     ; 9DE8
        brk                                     ; 9DE9
        brk                                     ; 9DEA
        brk                                     ; 9DEB
        brk                                     ; 9DEC
        brk                                     ; 9DED
        brk                                     ; 9DEE
        brk                                     ; 9DEF
        brk                                     ; 9DF0
        brk                                     ; 9DF1
        brk                                     ; 9DF2
        brk                                     ; 9DF3
        brk                                     ; 9DF4
        brk                                     ; 9DF5
        brk                                     ; 9DF6
        brk                                     ; 9DF7
        brk                                     ; 9DF8
        brk                                     ; 9DF9
        brk                                     ; 9DFA
        brk                                     ; 9DFB
        brk                                     ; 9DFC
        brk                                     ; 9DFD
        brk                                     ; 9DFE
        brk                                     ; 9DFF
        .byte   $3F                             ; 9E00
        .byte   $07                             ; 9E01
        brk                                     ; 9E02
        asl     $023C                           ; 9E03
        brk                                     ; 9E06
        asl     $0239                           ; 9E07
        brk                                     ; 9E0A
        asl     $0236                           ; 9E0B
        brk                                     ; 9E0E
        asl     $C600                           ; 9E0F
        brk                                     ; 9E12
        lda     $AC00,y                         ; 9E13
        brk                                     ; 9E16
        .byte   $9F                             ; 9E17
        brk                                     ; 9E18
        cmp     ($02,x)                         ; 9E19
        stx     $01,y                           ; 9E1B
        sty     $7F01                           ; 9E1D
        ora     ($6C,x)                         ; 9E20
        brk                                     ; 9E22
        .byte   $5A                             ; 9E23
        brk                                     ; 9E24
        pha                                     ; 9E25
        brk                                     ; 9E26
        .byte   $37                             ; 9E27
        brk                                     ; 9E28
        rol     $00,x                           ; 9E29
        eor     $00                             ; 9E2B
        .byte   $44                             ; 9E2D
        ora     ($53,x)                         ; 9E2E
        ora     $00                             ; 9E30
        .byte   $1F                             ; 9E32
        .byte   $04                             ; 9E33
        .byte   $2F                             ; 9E34
        .byte   $04                             ; 9E35
        .byte   $3F                             ; 9E36
        .byte   $04                             ; 9E37
        .byte   $4F                             ; 9E38
        .byte   $04                             ; 9E39
        .byte   $5F                             ; 9E3A
        .byte   $04                             ; 9E3B
        .byte   $6F                             ; 9E3C
        .byte   $04                             ; 9E3D
        .byte   $7F                             ; 9E3E
        .byte   $04                             ; 9E3F
        .byte   $8F                             ; 9E40
        .byte   $04                             ; 9E41
        .byte   $9F                             ; 9E42
        .byte   $04                             ; 9E43
        .byte   $AF                             ; 9E44
        .byte   $04                             ; 9E45
        .byte   $BF                             ; 9E46
        .byte   $04                             ; 9E47
        .byte   $CF                             ; 9E48
        .byte   $04                             ; 9E49
        dec     $DD20,x                         ; 9E4A
        asl     $DC                             ; 9E4D
        asl     $DB                             ; 9E4F
        asl     $DA                             ; 9E51
        asl     $D9                             ; 9E53
        asl     $D8                             ; 9E55
        asl     $D7                             ; 9E57
        asl     $D6                             ; 9E59
        asl     $D5                             ; 9E5B
        asl     $D4                             ; 9E5D
        asl     $D3                             ; 9E5F
        asl     $D2                             ; 9E61
        asl     $D1                             ; 9E63
        asl     $00                             ; 9E65
        ror     $6D3F                           ; 9E67
        .byte   $03                             ; 9E6A
        jmp     (L6B03)                         ; 9E6B

; ----------------------------------------------------------------------------
        .byte   $03                             ; 9E6E
        ror     a                               ; 9E6F
        .byte   $03                             ; 9E70
        adc     #$03                            ; 9E71
        pla                                     ; 9E73
        .byte   $03                             ; 9E74
        .byte   $67                             ; 9E75
        .byte   $03                             ; 9E76
        ror     $03                             ; 9E77
        adc     $03                             ; 9E79
        .byte   $64                             ; 9E7B
        .byte   $03                             ; 9E7C
        .byte   $63                             ; 9E7D
        .byte   $03                             ; 9E7E
        brk                                     ; 9E7F
L9E80:  rts                                     ; 9E80

; ----------------------------------------------------------------------------
        lda     $F9                             ; 9E81
        beq     L9E8A                           ; 9E83
        sta     $FD                             ; 9E85
        jsr     LBF7F                           ; 9E87
L9E8A:  lda     $FD                             ; 9E8A
        beq     L9E80                           ; 9E8C
        lda     #$01                            ; 9E8E
        sta     $D4                             ; 9E90
        ldx     #$00                            ; 9E92
L9E94:  lda     $0380,x                         ; 9E94
        sta     $D0                             ; 9E97
        lda     $0381,x                         ; 9E99
        sta     $D1                             ; 9E9C
        beq     L9EEA                           ; 9E9E
        lda     $0382,x                         ; 9EA0
        and     #$7F                            ; 9EA3
        bne     L9ED3                           ; 9EA5
        ldy     #$00                            ; 9EA7
        lda     ($D0),y                         ; 9EA9
        beq     L9F07                           ; 9EAB
        lda     ($D0),y                         ; 9EAD
        cmp     #$01                            ; 9EAF
        beq     L9ED0                           ; 9EB1
        cpx     #$08                            ; 9EB3
        bne     L9EB9                           ; 9EB5
        ora     #$80                            ; 9EB7
L9EB9:  sta     $4000,x                         ; 9EB9
        iny                                     ; 9EBC
        lda     ($D0),y                         ; 9EBD
        sta     $0382,x                         ; 9EBF
        bpl     L9ECA                           ; 9EC2
        jsr     LBF3B                           ; 9EC4
        jmp     LBED9                           ; 9EC7

; ----------------------------------------------------------------------------
L9ECA:  jsr     LBF64                           ; 9ECA
        jmp     LBED9                           ; 9ECD

; ----------------------------------------------------------------------------
L9ED0:  jmp     LBFC8                           ; 9ED0

; ----------------------------------------------------------------------------
L9ED3:  dec     $0382,x                         ; 9ED3
        jmp     LBEEA                           ; 9ED6

; ----------------------------------------------------------------------------
        lda     $0380,x                         ; 9ED9
        clc                                     ; 9EDC
        adc     #$04                            ; 9EDD
        sta     $0380,x                         ; 9EDF
        lda     $0381,x                         ; 9EE2
        adc     #$00                            ; 9EE5
        sta     $0381,x                         ; 9EE7
L9EEA:  asl     $D4                             ; 9EEA
        inx                                     ; 9EEC
        inx                                     ; 9EED
        inx                                     ; 9EEE
        inx                                     ; 9EEF
        cpx     #$10                            ; 9EF0
        bne     L9E94                           ; 9EF2
        lda     $0381                           ; 9EF4
        ora     $0385                           ; 9EF7
        ora     $0389                           ; 9EFA
        ora     $038D                           ; 9EFD
        bne     L9F06                           ; 9F00
        lda     #$00                            ; 9F02
        sta     $FD                             ; 9F04
L9F06:  rts                                     ; 9F06

; ----------------------------------------------------------------------------
L9F07:  ldy     $D4                             ; 9F07
        lda     $BF32,y                         ; 9F09
        tay                                     ; 9F0C
        lda     $0114,y                         ; 9F0D
        ora     #$80                            ; 9F10
        sta     $0114,y                         ; 9F12
        lda     #$00                            ; 9F15
        sta     $0381,x                         ; 9F17
        lda     #$00                            ; 9F1A
        cpx     #$08                            ; 9F1C
        beq     L9F22                           ; 9F1E
        lda     #$30                            ; 9F20
L9F22:  sta     $4000,x                         ; 9F22
        lda     $D4                             ; 9F25
        eor     #$0F                            ; 9F27
        and     $0394                           ; 9F29
        sta     $0394                           ; 9F2C
        jmp     LBEEA                           ; 9F2F

; ----------------------------------------------------------------------------
        brk                                     ; 9F32
        brk                                     ; 9F33
        asl     $00,x                           ; 9F34
        bit     a:$00                           ; 9F36
        brk                                     ; 9F39
        .byte   $42                             ; 9F3A
        iny                                     ; 9F3B
        lda     ($D0),y                         ; 9F3C
        sta     $4001,x                         ; 9F3E
        iny                                     ; 9F41
        lda     ($D0),y                         ; 9F42
        asl     a                               ; 9F44
        tay                                     ; 9F45
        lda     $B189,y                         ; 9F46
        cpx     #$0C                            ; 9F49
        bne     L9F50                           ; 9F4B
        lda     $B1D8,y                         ; 9F4D
L9F50:  sta     $4002,x                         ; 9F50
        lda     $B18A,y                         ; 9F53
        cmp     $0383,x                         ; 9F56
        beq     L9F63                           ; 9F59
        sta     $0383,x                         ; 9F5B
        ora     #$78                            ; 9F5E
        sta     $4003,x                         ; 9F60
L9F63:  rts                                     ; 9F63

; ----------------------------------------------------------------------------
        lda     #$7F                            ; 9F64
        sta     $4001,x                         ; 9F66
        iny                                     ; 9F69
        iny                                     ; 9F6A
        lda     ($D0),y                         ; 9F6B
        sta     $4002,x                         ; 9F6D
        dey                                     ; 9F70
        lda     ($D0),y                         ; 9F71
        cmp     $0383,x                         ; 9F73
        beq     L9F7E                           ; 9F76
        sta     $4003,x                         ; 9F78
        sta     $0383,x                         ; 9F7B
L9F7E:  rts                                     ; 9F7E

; ----------------------------------------------------------------------------
        asl     a                               ; 9F7F
        tay                                     ; 9F80
        lda     $B005,y                         ; 9F81
        sta     $D0                             ; 9F84
        lda     $B006,y                         ; 9F86
        sta     $D1                             ; 9F89
        lda     #$01                            ; 9F8B
        sta     $D4                             ; 9F8D
        ldx     #$00                            ; 9F8F
        ldy     #$00                            ; 9F91
L9F93:  lda     ($D0),y                         ; 9F93
        sta     $D2                             ; 9F95
        iny                                     ; 9F97
        lda     ($D0),y                         ; 9F98
        sta     $D3                             ; 9F9A
        iny                                     ; 9F9C
        lda     $D3                             ; 9F9D
        beq     L9FBD                           ; 9F9F
        lda     $D4                             ; 9FA1
        ora     $0394                           ; 9FA3
        sta     $0394                           ; 9FA6
        lda     $D2                             ; 9FA9
        sta     $0380,x                         ; 9FAB
        lda     $D3                             ; 9FAE
        sta     $0381,x                         ; 9FB0
        lda     #$FF                            ; 9FB3
        sta     $0383,x                         ; 9FB5
        lda     #$00                            ; 9FB8
        sta     $0382,x                         ; 9FBA
L9FBD:  asl     $D4                             ; 9FBD
        inx                                     ; 9FBF
        inx                                     ; 9FC0
        inx                                     ; 9FC1
        inx                                     ; 9FC2
        cpx     #$10                            ; 9FC3
        bne     L9F93                           ; 9FC5
        rts                                     ; 9FC7

; ----------------------------------------------------------------------------
        iny                                     ; 9FC8
        lda     ($D0),y                         ; 9FC9
        sta     $039A                           ; 9FCB
        lda     $0380,x                         ; 9FCE
        clc                                     ; 9FD1
        adc     #$04                            ; 9FD2
        sta     $0380,x                         ; 9FD4
        lda     $0381,x                         ; 9FD7
        adc     #$00                            ; 9FDA
        sta     $0381,x                         ; 9FDC
        jmp     LBE94                           ; 9FDF

; ----------------------------------------------------------------------------
        brk                                     ; 9FE2
        brk                                     ; 9FE3
        brk                                     ; 9FE4
        brk                                     ; 9FE5
        brk                                     ; 9FE6
        brk                                     ; 9FE7
        brk                                     ; 9FE8
        brk                                     ; 9FE9
        brk                                     ; 9FEA
        brk                                     ; 9FEB
        brk                                     ; 9FEC
        brk                                     ; 9FED
        brk                                     ; 9FEE
        brk                                     ; 9FEF
        brk                                     ; 9FF0
        brk                                     ; 9FF1
        brk                                     ; 9FF2
        brk                                     ; 9FF3
        brk                                     ; 9FF4
        brk                                     ; 9FF5
        brk                                     ; 9FF6
        brk                                     ; 9FF7
        brk                                     ; 9FF8
        brk                                     ; 9FF9
        brk                                     ; 9FFA
        brk                                     ; 9FFB
        brk                                     ; 9FFC
        brk                                     ; 9FFD
        brk                                     ; 9FFE
        brk                                     ; 9FFF
