; ============================================================================
; The Magic of Scheherazade - Bank 13 Disassembly
; ============================================================================
; File Offset: 0x1A000 - 0x1BFFF
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
; Created:    2026-01-24 04:39:29
; Input file: C:/claude-workspace/TMOS_AI/rom-files/disassembly/output/banks/bank_13.bin
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
L2221           := $2221
L2229           := $2229
L28C0           := $28C0
L2C42           := $2C42
L2DA8           := $2DA8
L3010           := $3010
L3020           := $3020
L3028           := $3028
L3030           := $3030
L4010           := $4010
OAM_DMA         := $4014
APU_STATUS      := $4015
JOY1            := $4016
JOY2_FRAME      := $4017
L4018           := $4018
LA2E9           := $A2E9
LA2FC           := $A2FC
LA309           := $A309
LA347           := $A347
LA3D1           := $A3D1
LA407           := $A407
LA47D           := $A47D
LA494           := $A494
LA4B5           := $A4B5
LA4E8           := $A4E8
LA4F4           := $A4F4
LA522           := $A522
LA57C           := $A57C
LA5A9           := $A5A9
LA5D5           := $A5D5
LA5E0           := $A5E0
LA63D           := $A63D
LA64B           := $A64B
LA691           := $A691
LA69A           := $A69A
LA7BA           := $A7BA
LA7C4           := $A7C4
LA7CE           := $A7CE
LA85B           := $A85B
LA87C           := $A87C
LA89F           := $A89F
LA8AA           := $A8AA
LA925           := $A925
LA92B           := $A92B
LA935           := $A935
LA943           := $A943
LA964           := $A964
LA9C9           := $A9C9
LA9FA           := $A9FA
LAA28           := $AA28
LAA4C           := $AA4C
LAA56           := $AA56
LAA7E           := $AA7E
LAAB0           := $AAB0
LAAED           := $AAED
LAAF6           := $AAF6
LAB17           := $AB17
LAB37           := $AB37
LAB52           := $AB52
LAB72           := $AB72
LABB6           := $ABB6
LABD3           := $ABD3
LAC02           := $AC02
LAC90           := $AC90
LACFB           := $ACFB
LAD96           := $AD96
LADC7           := $ADC7
LAE02           := $AE02
LAE0D           := $AE0D
LAE75           := $AE75
LAED3           := $AED3
LAF44           := $AF44
LAF6A           := $AF6A
LAF91           := $AF91
LAF9C           := $AF9C
LAFB1           := $AFB1
LAFB4           := $AFB4
LAFCD           := $AFCD
LAFE2           := $AFE2
LAFF8           := $AFF8
LB011           := $B011
LB01C           := $B01C
LB039           := $B039
LB05F           := $B05F
LB083           := $B083
LB0B1           := $B0B1
LB0E1           := $B0E1
LB117           := $B117
LB126           := $B126
LB12E           := $B12E
LB166           := $B166
LB17D           := $B17D
LB1BE           := $B1BE
LB226           := $B226
LB287           := $B287
LB296           := $B296
LB2A1           := $B2A1
LB2AC           := $B2AC
LB2EE           := $B2EE
LB3B1           := $B3B1
LB45E           := $B45E
LB465           := $B465
LB4AB           := $B4AB
LB4B0           := $B4B0
LB4DD           := $B4DD
LB4E0           := $B4E0
LB4E8           := $B4E8
LB4F1           := $B4F1
LB4FA           := $B4FA
LB513           := $B513
LB520           := $B520
LB52C           := $B52C
LB533           := $B533
LB53A           := $B53A
LB541           := $B541
LB547           := $B547
LB553           := $B553
LB55B           := $B55B
LB55E           := $B55E
LB561           := $B561
LB567           := $B567
LB569           := $B569
LB575           := $B575
LB587           := $B587
LB5A7           := $B5A7
LB5DB           := $B5DB
LB5E1           := $B5E1
LB5E7           := $B5E7
LB5FD           := $B5FD
LB611           := $B611
LB630           := $B630
LB63E           := $B63E
LB64C           := $B64C
LB698           := $B698
LB6BC           := $B6BC
LB70D           := $B70D
LB74E           := $B74E
LB78C           := $B78C
LB7E6           := $B7E6
LB846           := $B846
LB8D1           := $B8D1
LB8FD           := $B8FD
LB91E           := $B91E
LB928           := $B928
LB98B           := $B98B
LB994           := $B994
LBA25           := $BA25
LBA3C           := $BA3C
LBA42           := $BA42
LBA45           := $BA45
LBAD1           := $BAD1
LBAE2           := $BAE2
LBC7F           := $BC7F
LBC9B           := $BC9B
LBCA6           := $BCA6
LBD40           := $BD40
LBD8E           := $BD8E
LBDD5           := $BDD5
LBDE6           := $BDE6
LBDF8           := $BDF8
LBE19           := $BE19
LBE56           := $BE56
LBE84           := $BE84
LBE8A           := $BE8A
LBF14           := $BF14
LBF30           := $BF30
LBF51           := $BF51
LBF9B           := $BF9B
LBFD1           := $BFD1
LBFDA           := $BFDA
LBFE5           := $BFE5
LBFED           := $BFED
LE02D           := $E02D
LE02F           := $E02F
LE031           := $E031
LE03F           := $E03F
LE07A           := $E07A
LE07E           := $E07E
LE080           := $E080
LE096           := $E096
LE0D1           := $E0D1
LE17B           := $E17B
LE2C6           := $E2C6
LE5AA           := $E5AA
LE5B2           := $E5B2
LE89D           := $E89D
LE8C8           := $E8C8
LE95B           := $E95B
LE97D           := $E97D
LE992           := $E992
LE9EB           := $E9EB
LEA7E           := $EA7E
LEC46           := $EC46
LEEB3           := $EEB3
LF067           := $F067
LF07B           := $F07B
LF09B           := $F09B
LF0B5           := $F0B5
LF785           := $F785
LF79E           := $F79E
LF7B1           := $F7B1
; ----------------------------------------------------------------------------
        ldy     #$BA                            ; 8000
        ldy     #$C1                            ; 8002
        ldy     #$C7                            ; 8004
        ldy     #$CD                            ; 8006
        ldy     #$D4                            ; 8008
        ldy     #$DA                            ; 800A
        ldy     #$DF                            ; 800C
        ldy     #$E5                            ; 800E
        ldy     #$EC                            ; 8010
        ldy     #$F2                            ; 8012
        ldy     #$F9                            ; 8014
        ldy     #$00                            ; 8016
        lda     ($04,x)                         ; 8018
        lda     ($07,x)                         ; 801A
        lda     ($0C,x)                         ; 801C
        lda     ($14,x)                         ; 801E
        lda     ($1B,x)                         ; 8020
        lda     ($22,x)                         ; 8022
        lda     ($26,x)                         ; 8024
        lda     ($2B,x)                         ; 8026
        lda     ($32,x)                         ; 8028
        lda     ($39,x)                         ; 802A
        lda     ($3F,x)                         ; 802C
        lda     ($45,x)                         ; 802E
        lda     ($4B,x)                         ; 8030
        lda     ($50,x)                         ; 8032
        lda     ($56,x)                         ; 8034
        lda     ($5C,x)                         ; 8036
        lda     ($62,x)                         ; 8038
        lda     ($66,x)                         ; 803A
        lda     ($6A,x)                         ; 803C
        lda     ($71,x)                         ; 803E
        lda     ($76,x)                         ; 8040
        lda     ($7E,x)                         ; 8042
        lda     ($83,x)                         ; 8044
        lda     ($87,x)                         ; 8046
        lda     ($88,x)                         ; 8048
        lda     ($89,x)                         ; 804A
        lda     ($8C,x)                         ; 804C
        lda     ($93,x)                         ; 804E
        lda     ($94,x)                         ; 8050
        lda     ($9E,x)                         ; 8052
        lda     ($B2,x)                         ; 8054
        lda     ($BF,x)                         ; 8056
        lda     ($0F,x)                         ; 8058
        ora     #$0A                            ; 805A
        .byte   $0B                             ; 805C
        asl     $0C,x                           ; 805D
        ora     $130E                           ; 805F
        .byte   $14                             ; 8062
        ora     $17,x                           ; 8063
        bpl     L806C                           ; 8065
        clc                                     ; 8067
        ora     $1B1A,y                         ; 8068
        .byte   $1C                             ; 806B
L806C:  brk                                     ; 806C
        .byte   $1F                             ; 806D
        jsr     L2221                           ; 806E
        .byte   $23                             ; 8071
        bit     $25                             ; 8072
        rol     $27                             ; 8074
        plp                                     ; 8076
        and     #$2A                            ; 8077
        ora     $0263,x                         ; 8079
        ora     ($04,x)                         ; 807C
        asl     $FF                             ; 807E
        .byte   $3F                             ; 8080
        bmi     L80BF                           ; 8081
        .byte   $3F                             ; 8083
        rol     $31BE,x                         ; 8084
        rol     $433B,x                         ; 8087
        .byte   $43                             ; 808A
        rol     L8141,x                         ; 808B
        and     ($3E),y                         ; 808E
        .byte   $3B                             ; 8090
        .byte   $43                             ; 8091
        .byte   $43                             ; 8092
        rol     L8241,x                         ; 8093
L8096:  and     ($3E),y                         ; 8096
        .byte   $3B                             ; 8098
        .byte   $43                             ; 8099
        .byte   $43                             ; 809A
        rol     L8341,x                         ; 809B
        .byte   $33                             ; 809E
        .byte   $34                             ; 809F
        and     $34,x                           ; 80A0
        and     $B434,x                         ; 80A2
        and     $3B,x                           ; 80A5
        bmi     L80E5                           ; 80A7
        rol     L813B,x                         ; 80A9
        and     $3B,x                           ; 80AC
        bmi     L80EC                           ; 80AE
        rol     L823B,x                         ; 80B0
        and     $3B,x                           ; 80B3
        bmi     L80F3                           ; 80B5
        rol     L833B,x                         ; 80B7
        .byte   $32                             ; 80BA
        rol     $3141,x                         ; 80BB
        .byte   $3E                             ; 80BE
L80BF:  .byte   $32                             ; 80BF
        tsx                                     ; 80C0
        .byte   $42                             ; 80C1
        .byte   $37                             ; 80C2
        eor     ($38,x)                         ; 80C3
        and     $32BA,x                         ; 80C5
        bmi     L810B                           ; 80C8
        bmi     L80FD                           ; 80CA
        bcs     L810F                           ; 80CC
        bmi     L810C                           ; 80CE
        sec                                     ; 80D0
        .byte   $3F                             ; 80D1
        bmi     L8096                           ; 80D2
        .byte   $3C                             ; 80D4
        bmi     L8118                           ; 80D5
        sec                                     ; 80D7
        .byte   $43                             ; 80D8
        bcs     L8119                           ; 80D9
        .byte   $3F                             ; 80DB
        .byte   $41                             ; 80DC
L80DD:  sec                                     ; 80DD
        lda     $383B,x                         ; 80DE
        and     ($32),y                         ; 80E1
        .byte   $3E                             ; 80E3
        .byte   $BC                             ; 80E4
L80E5:  .byte   $3C                             ; 80E5
        rol     $343D,x                         ; 80E6
        .byte   $32                             ; 80E9
        .byte   $3E                             ; 80EA
        .byte   $BC                             ; 80EB
L80EC:  .byte   $3C                             ; 80EC
        rol     $3242,x                         ; 80ED
        rol     $41BC,x                         ; 80F0
L80F3:  bmi     L812D                           ; 80F3
        and     $3E32,x                         ; 80F5
        ldy     $3F42,x                         ; 80F8
        eor     ($38,x)                         ; 80FB
L80FD:  .byte   $32                             ; 80FD
        rol     $39BC,x                         ; 80FE
L8101:  .byte   $44                             ; 8101
        .byte   $3C                             ; 8102
        .byte   $BF                             ; 8103
        eor     ($3E,x)                         ; 8104
        .byte   $B3                             ; 8106
        and     $3B,x                           ; 8107
        .byte   $30                             ; 8109
L810A:  .byte   $3C                             ; 810A
L810B:  .byte   $B4                             ; 810B
L810C:  .byte   $42                             ; 810C
        .byte   $43                             ; 810D
        .byte   $30                             ; 810E
L810F:  eor     ($33,x)                         ; 810F
        .byte   $44                             ; 8111
        .byte   $42                             ; 8112
        .byte   $C3                             ; 8113
        .byte   $32                             ; 8114
        sec                                     ; 8115
        .byte   $3C                             ; 8116
        .byte   $30                             ; 8117
L8118:  .byte   $41                             ; 8118
L8119:  rol     $32BD,x                         ; 8119
        eor     ($48,x)                         ; 811C
        .byte   $42                             ; 811E
        .byte   $43                             ; 811F
        bmi     L80DD                           ; 8120
        sec                                     ; 8122
        .byte   $42                             ; 8123
        and     $B0,x                           ; 8124
        .byte   $42                             ; 8126
        lsr     $3E                             ; 8127
        eor     ($B3,x)                         ; 8129
        .byte   $42                             ; 812B
        sec                                     ; 812C
L812D:  .byte   $3C                             ; 812D
        sec                                     ; 812E
        .byte   $43                             ; 812F
        bmi     L80F3                           ; 8130
        .byte   $33                             ; 8132
        eor     ($30,x)                         ; 8133
        rol     $3E,x                           ; 8135
        rol     $3ABD,x                         ; 8137
        .byte   $30                             ; 813A
L813B:  .byte   $42                             ; 813B
        .byte   $37                             ; 813C
        sec                                     ; 813D
        ldy     $3E41,x                         ; 813E
L8141:  .byte   $42                             ; 8141
        .byte   $43                             ; 8142
        bmi     L8101                           ; 8143
        .byte   $3B                             ; 8145
        .byte   $34                             ; 8146
L8147:  rol     $34,x                           ; 8147
        and     $42B3,x                         ; 8149
        .byte   $3F                             ; 814C
        .byte   $34                             ; 814D
        bmi     L810A                           ; 814E
        .byte   $32                             ; 8150
        bmi     L8194                           ; 8151
        .byte   $3F                             ; 8153
        .byte   $34                             ; 8154
        .byte   $C3                             ; 8155
        eor     ($4F,x)                         ; 8156
        .byte   $42                             ; 8158
        .byte   $34                             ; 8159
        .byte   $34                             ; 815A
        .byte   $B3                             ; 815B
        .byte   $37                             ; 815C
        bmi     L819B                           ; 815D
        .byte   $3C                             ; 815F
        .byte   $34                             ; 8160
        cmp     ($37,x)                         ; 8161
        rol     $BD41,x                         ; 8163
        eor     ($38,x)                         ; 8166
        and     $35B6,x                         ; 8168
        sec                                     ; 816B
        rol     $37,x                           ; 816C
        .byte   $43                             ; 816E
        .byte   $34                             ; 816F
        cmp     ($42,x)                         ; 8170
        bmi     L81AC                           ; 8172
        and     $3CC3,x                         ; 8174
        bmi     L81AF                           ; 8177
        sec                                     ; 8179
        .byte   $32                             ; 817A
        sec                                     ; 817B
        bmi     L813B                           ; 817C
        .byte   $3C                             ; 817E
        bmi     L81B7                           ; 817F
        sec                                     ; 8181
        .byte   $B2                             ; 8182
        sec                                     ; 8183
        .byte   $43                             ; 8184
        .byte   $34                             ; 8185
        ldy     $ACAC,x                         ; 8186
        .byte   $43                             ; 8189
        .byte   $37                             ; 818A
        ldy     $3C,x                           ; 818B
        bmi     L81D6                           ; 818D
        sec                                     ; 818F
        .byte   $3C                             ; 8190
        .byte   $44                             ; 8191
        .byte   $BC                             ; 8192
        .byte   $BF                             ; 8193
L8194:  .byte   $37                             ; 8194
        bmi     L81D9                           ; 8195
        bit     $3431                           ; 8197
        .byte   $32                             ; 819A
L819B:  rol     $B43C,x                         ; 819B
        rol     $3535,x                         ; 819E
        .byte   $34                             ; 81A1
        and     $3442,x                         ; 81A2
        bit     $3E3F                           ; 81A5
        lsr     $34                             ; 81A8
        eor     ($2C,x)                         ; 81AA
L81AC:  rol     $2C35,x                         ; 81AC
L81AF:  .byte   $43                             ; 81AF
        .byte   $37                             ; 81B0
        ldy     $37,x                           ; 81B1
        bmi     L81F7                           ; 81B3
        .byte   $2C                             ; 81B5
        sec                                     ; 81B6
L81B7:  and     $4132,x                         ; 81B7
        .byte   $34                             ; 81BA
        bmi     L81FF                           ; 81BB
        .byte   $34                             ; 81BD
        .byte   $B3                             ; 81BE
        .byte   $3B                             ; 81BF
        .byte   $34                             ; 81C0
        eor     $34                             ; 81C1
        .byte   $BB                             ; 81C3
        jsr     LB541                           ; 81C4
        lda     #$09                            ; 81C7
        jsr     LA2FC                           ; 81C9
        clc                                     ; 81CC
        lda     #$26                            ; 81CD
        adc     $92                             ; 81CF
        jsr     L9D2F                           ; 81D1
        ldy     #$09                            ; 81D4
L81D6:  lda     #$05                            ; 81D6
        .byte   $20                             ; 81D8
L81D9:  .byte   $FC                             ; 81D9
        ldx     #$A5                            ; 81DA
        sty     $85                             ; 81DC
        brk                                     ; 81DE
        inc     $00                             ; 81DF
        lda     #$00                            ; 81E1
        sta     $03                             ; 81E3
        jsr     LA347                           ; 81E5
        lda     #$02                            ; 81E8
        jsr     LA2E9                           ; 81EA
        jmp     LB4F1                           ; 81ED

; ----------------------------------------------------------------------------
        jsr     LB541                           ; 81F0
        ldy     #$0E                            ; 81F3
        lda     #$04                            ; 81F5
L81F7:  jsr     LA2FC                           ; 81F7
        lda     $C6                             ; 81FA
        cmp     #$1E                            ; 81FC
        .byte   $90                             ; 81FE
L81FF:  ora     $D018                           ; 81FF
        ora     $6D                             ; 8202
        asl     $D003                           ; 8204
        ora     $69                             ; 8207
        ora     $6D                             ; 8209
        .byte   $22                             ; 820B
        .byte   $03                             ; 820C
        jsr     L9D24                           ; 820D
        ldy     #$12                            ; 8210
        lda     #$04                            ; 8212
        jsr     LA2FC                           ; 8214
        lda     $81                             ; 8217
        sta     $00                             ; 8219
        lda     #$2C                            ; 821B
        sta     $03                             ; 821D
        lda     #$00                            ; 821F
        jsr     LA347                           ; 8221
        lda     #$03                            ; 8224
        jsr     LA2E9                           ; 8226
        ldy     #$26                            ; 8229
        lda     #$04                            ; 822B
        jsr     LA2FC                           ; 822D
        lda     $0306                           ; 8230
        jsr     LA309                           ; 8233
        jmp     LB4F1                           ; 8236

; ----------------------------------------------------------------------------
        .byte   $20                             ; 8239
        .byte   $41                             ; 823A
L823B:  lda     $A0,x                           ; 823B
        asl     $A9,x                           ; 823D
        .byte   $04                             ; 823F
        .byte   $20                             ; 8240
L8241:  .byte   $FC                             ; 8241
        ldx     #$A5                            ; 8242
        cmp     $20                             ; 8244
        bit     $9D                             ; 8246
        ldy     #$1A                            ; 8248
        lda     #$04                            ; 824A
        jsr     LA2FC                           ; 824C
        ldy     #$00                            ; 824F
L8251:  lda     $8C,y                           ; 8251
        bne     L8261                           ; 8254
        cpy     #$02                            ; 8256
        beq     L8261                           ; 8258
        lda     #$2C                            ; 825A
        jsr     LB5E1                           ; 825C
        bne     L8251                           ; 825F
L8261:  lda     $8C,y                           ; 8261
        jsr     LB5E1                           ; 8264
        cpy     #$03                            ; 8267
        bne     L8261                           ; 8269
        ldy     #$2A                            ; 826B
        lda     #$04                            ; 826D
        jsr     LA2FC                           ; 826F
        lda     $0307                           ; 8272
        jsr     LA309                           ; 8275
        jmp     LB4F1                           ; 8278

; ----------------------------------------------------------------------------
        ldx     $0162                           ; 827B
        ldy     #$20                            ; 827E
        lda     #$2C                            ; 8280
L8282:  sta     $0163,x                         ; 8282
        inx                                     ; 8285
        dey                                     ; 8286
        bne     L8282                           ; 8287
        jsr     LB541                           ; 8289
        ldy     #$1E                            ; 828C
        lda     #$04                            ; 828E
        jsr     LA2FC                           ; 8290
        lda     $85                             ; 8293
        sta     $00                             ; 8295
        lda     $86                             ; 8297
        sta     $01                             ; 8299
        lda     #$2C                            ; 829B
        sta     $03                             ; 829D
        lda     #$01                            ; 829F
        jsr     LA347                           ; 82A1
        lda     #$05                            ; 82A4
        jsr     LA2E9                           ; 82A6
        inx                                     ; 82A9
        lda     #$13                            ; 82AA
        jsr     LB5E1                           ; 82AC
        lda     $0300                           ; 82AF
        jsr     LB5E1                           ; 82B2
        ldy     #$22                            ; 82B5
        lda     #$04                            ; 82B7
        jsr     LA2FC                           ; 82B9
        ldy     #$00                            ; 82BC
L82BE:  lda     $89,y                           ; 82BE
        bne     L82CE                           ; 82C1
        cpy     #$02                            ; 82C3
        beq     L82CE                           ; 82C5
        lda     #$2C                            ; 82C7
        jsr     LB5E1                           ; 82C9
        bne     L82BE                           ; 82CC
L82CE:  lda     $89,y                           ; 82CE
        jsr     LB5E1                           ; 82D1
        cpy     #$03                            ; 82D4
        bne     L82CE                           ; 82D6
        inx                                     ; 82D8
        inx                                     ; 82D9
        inx                                     ; 82DA
        lda     #$23                            ; 82DB
        jsr     LB5E1                           ; 82DD
        lda     $0301                           ; 82E0
        jsr     LB5E1                           ; 82E3
        jmp     LB4F1                           ; 82E6

; ----------------------------------------------------------------------------
        sta     $0F                             ; 82E9
        sec                                     ; 82EB
        lda     #$05                            ; 82EC
        sbc     $0F                             ; 82EE
        tay                                     ; 82F0
L82F1:  lda     $05,y                           ; 82F1
        jsr     LB5E1                           ; 82F4
        cpy     #$05                            ; 82F7
        bne     L82F1                           ; 82F9
        rts                                     ; 82FB

; ----------------------------------------------------------------------------
        sta     $00                             ; 82FC
L82FE:  lda     $A319,y                         ; 82FE
        jsr     LB5E1                           ; 8301
        dec     $00                             ; 8304
        bne     L82FE                           ; 8306
        rts                                     ; 8308

; ----------------------------------------------------------------------------
        sta     $00                             ; 8309
        lda     #$2C                            ; 830B
        sta     $03                             ; 830D
        lda     #$00                            ; 830F
        jsr     LA347                           ; 8311
        lda     #$02                            ; 8314
        jmp     LA2E9                           ; 8316

; ----------------------------------------------------------------------------
        and     #$02                            ; 8319
        asl     $3B32                           ; 831B
        bmi     L8362                           ; 831E
        .byte   $42                             ; 8320
        bit     $1129                           ; 8321
        .byte   $04                             ; 8324
        .byte   $3B                             ; 8325
        eor     $29                             ; 8326
        .byte   $42                             ; 8328
        ora     #$11                            ; 8329
        and     #$2C                            ; 832B
        .byte   $04                             ; 832D
        jsr     L2229                           ; 832E
        ora     #$10                            ; 8331
        and     #$4C                            ; 8333
        .byte   $04                             ; 8335
        and     ($29,x)                         ; 8336
        and     ($09),y                         ; 8338
        .byte   $12                             ; 833A
L833B:  and     #$51                            ; 833B
        ora     #$22                            ; 833D
        and     #$3B                            ; 833F
L8341:  .byte   $03                             ; 8341
        lsr     a                               ; 8342
        and     #$5B                            ; 8343
        .byte   $03                             ; 8345
        .byte   $4B                             ; 8346
        sta     $05                             ; 8347
        txa                                     ; 8349
        pha                                     ; 834A
        tya                                     ; 834B
        pha                                     ; 834C
        ldx     $05                             ; 834D
        bne     L8353                           ; 834F
        stx     $01                             ; 8351
L8353:  ldy     #$06                            ; 8353
        ldx     #$00                            ; 8355
L8357:  lda     #$FF                            ; 8357
        sta     $09                             ; 8359
        sec                                     ; 835B
L835C:  inc     $09                             ; 835C
        lda     $00                             ; 835E
        .byte   $F9                             ; 8360
        .byte   $9D                             ; 8361
L8362:  .byte   $A3                             ; 8362
        sta     $00                             ; 8363
        lda     $01                             ; 8365
        sbc     $A39E,y                         ; 8367
        sta     $01                             ; 836A
        bcs     L835C                           ; 836C
        lda     $00                             ; 836E
        adc     $A39D,y                         ; 8370
        sta     $00                             ; 8373
        lda     $01                             ; 8375
        adc     $A39E,y                         ; 8377
        sta     $01                             ; 837A
        lda     $09                             ; 837C
        sta     $05,x                           ; 837E
        inx                                     ; 8380
        dey                                     ; 8381
        dey                                     ; 8382
        bpl     L8357                           ; 8383
        lda     $00                             ; 8385
        sta     $05,x                           ; 8387
        ldx     #$00                            ; 8389
L838B:  lda     $05,x                           ; 838B
        bne     L8398                           ; 838D
        lda     $03                             ; 838F
        sta     $05,x                           ; 8391
        inx                                     ; 8393
        cpx     #$04                            ; 8394
        bne     L838B                           ; 8396
L8398:  pla                                     ; 8398
        tay                                     ; 8399
        pla                                     ; 839A
        tax                                     ; 839B
        rts                                     ; 839C

; ----------------------------------------------------------------------------
        asl     a                               ; 839D
        brk                                     ; 839E
        .byte   $64                             ; 839F
        brk                                     ; 83A0
        inx                                     ; 83A1
        .byte   $03                             ; 83A2
        bpl     L83CC                           ; 83A3
        lda     $031C                           ; 83A5
        and     #$F0                            ; 83A8
        sta     $031C                           ; 83AA
        jsr     LA4B5                           ; 83AD
        jsr     LA407                           ; 83B0
L83B3:  jsr     LA3D1                           ; 83B3
        jsr     LE0D1                           ; 83B6
        jsr     LEEB3                           ; 83B9
        .byte   $A5                             ; 83BC
L83BD:  .byte   $C2                             ; 83BD
        and     #$08                            ; 83BE
        beq     L83B3                           ; 83C0
        jsr     L99F6                           ; 83C2
        jsr     LA5E0                           ; 83C5
        lda     $031C                           ; 83C8
        .byte   $09                             ; 83CB
L83CC:  .byte   $0F                             ; 83CC
        sta     $031C                           ; 83CD
        rts                                     ; 83D0

; ----------------------------------------------------------------------------
        lda     $C2                             ; 83D1
        lsr     a                               ; 83D3
        bcc     L83DC                           ; 83D4
        jsr     L99F6                           ; 83D6
        jmp     LA47D                           ; 83D9

; ----------------------------------------------------------------------------
L83DC:  lda     $C2                             ; 83DC
        asl     a                               ; 83DE
        bcc     L840E                           ; 83DF
        lda     $0D                             ; 83E1
        and     #$10                            ; 83E3
        bne     L83F6                           ; 83E5
        lda     $0D                             ; 83E7
        and     #$03                            ; 83E9
        tay                                     ; 83EB
L83EC:  lda     $0A,y                           ; 83EC
        cmp     #$FF                            ; 83EF
        bne     L83F7                           ; 83F1
        dey                                     ; 83F3
        bpl     L83EC                           ; 83F4
L83F6:  rts                                     ; 83F6

; ----------------------------------------------------------------------------
L83F7:  tya                                     ; 83F7
        ora     #$10                            ; 83F8
        tay                                     ; 83FA
L83FB:  tya                                     ; 83FB
        pha                                     ; 83FC
        lda     #$2C                            ; 83FD
        sta     $0E                             ; 83FF
        .byte   $20                             ; 8401
        .byte   $7C                             ; 8402
L8403:  lda     $68                             ; 8403
        sta     $0D                             ; 8405
        lda     #$7A                            ; 8407
        sta     $0E                             ; 8409
        jmp     LA57C                           ; 840B

; ----------------------------------------------------------------------------
L840E:  asl     a                               ; 840E
        bcc     L8427                           ; 840F
        lda     $0D                             ; 8411
        and     #$10                            ; 8413
        beq     L8426                           ; 8415
        lda     $0D                             ; 8417
        and     #$03                            ; 8419
        tay                                     ; 841B
L841C:  lda     $07,y                           ; 841C
        cmp     #$FF                            ; 841F
        bne     L83FB                           ; 8421
        dey                                     ; 8423
        bpl     L841C                           ; 8424
L8426:  rts                                     ; 8426

; ----------------------------------------------------------------------------
L8427:  asl     a                               ; 8427
        bcc     L845A                           ; 8428
        lda     $0D                             ; 842A
        and     #$03                            ; 842C
        cmp     #$02                            ; 842E
        beq     L844D                           ; 8430
        tay                                     ; 8432
        lda     $0D                             ; 8433
        and     #$10                            ; 8435
        beq     L843C                           ; 8437
        iny                                     ; 8439
        iny                                     ; 843A
        iny                                     ; 843B
L843C:  iny                                     ; 843C
L843D:  lda     $07,y                           ; 843D
        cmp     #$FF                            ; 8440
        bne     L844E                           ; 8442
        iny                                     ; 8444
        cpy     #$03                            ; 8445
        beq     L844D                           ; 8447
        cpy     #$06                            ; 8449
        bne     L843D                           ; 844B
L844D:  rts                                     ; 844D

; ----------------------------------------------------------------------------
L844E:  cpy     #$03                            ; 844E
        bcc     L83FB                           ; 8450
        tya                                     ; 8452
        sbc     #$03                            ; 8453
        ora     #$10                            ; 8455
        tay                                     ; 8457
        bne     L83FB                           ; 8458
L845A:  asl     a                               ; 845A
        bcc     L847C                           ; 845B
        lda     $0D                             ; 845D
        and     #$03                            ; 845F
        beq     L847C                           ; 8461
        tay                                     ; 8463
        lda     $0D                             ; 8464
        and     #$10                            ; 8466
        beq     L846D                           ; 8468
        iny                                     ; 846A
        iny                                     ; 846B
        iny                                     ; 846C
L846D:  dey                                     ; 846D
L846E:  lda     $07,y                           ; 846E
        cmp     #$FF                            ; 8471
        bne     L844E                           ; 8473
        dey                                     ; 8475
        bmi     L847C                           ; 8476
        cpy     #$02                            ; 8478
        bne     L846E                           ; 847A
L847C:  rts                                     ; 847C

; ----------------------------------------------------------------------------
        lda     $06                             ; 847D
        bne     L8497                           ; 847F
        lda     #$00                            ; 8481
        sta     $05                             ; 8483
        inc     $06                             ; 8485
        lda     $0D                             ; 8487
        beq     L8491                           ; 8489
        lda     #$1A                            ; 848B
        sta     $05                             ; 848D
        inc     $06                             ; 848F
L8491:  jsr     LA4E8                           ; 8491
        jmp     LA407                           ; 8494

; ----------------------------------------------------------------------------
L8497:  lda     $0D                             ; 8497
        and     #$10                            ; 8499
        php                                     ; 849B
        lda     $0D                             ; 849C
        and     #$03                            ; 849E
        plp                                     ; 84A0
        beq     L84A6                           ; 84A1
        clc                                     ; 84A3
        adc     #$03                            ; 84A4
L84A6:  tay                                     ; 84A6
        lda     $07,y                           ; 84A7
        ldy     $06                             ; 84AA
        sta     $C4,y                           ; 84AC
        jsr     LA4B5                           ; 84AF
        jmp     LA494                           ; 84B2

; ----------------------------------------------------------------------------
        jsr     LA5D5                           ; 84B5
        jsr     LA5E0                           ; 84B8
        lda     #$00                            ; 84BB
        sta     $0D                             ; 84BD
        sta     $06                             ; 84BF
        sta     $07                             ; 84C1
        sta     $09                             ; 84C3
        lda     #$29                            ; 84C5
        sta     $00                             ; 84C7
L84C9:  jsr     LA5A9                           ; 84C9
        lda     $00                             ; 84CC
        jsr     L9D2F                           ; 84CE
        jsr     LB4F1                           ; 84D1
        jsr     LEEB3                           ; 84D4
        inc     $00                             ; 84D7
        inc     $0D                             ; 84D9
        inc     $0D                             ; 84DB
        lda     $0D                             ; 84DD
        cmp     #$03                            ; 84DF
        bcc     L84C9                           ; 84E1
        lda     #$00                            ; 84E3
        sta     $0D                             ; 84E5
        rts                                     ; 84E7

; ----------------------------------------------------------------------------
        jsr     LA5D5                           ; 84E8
        jsr     LA5E0                           ; 84EB
        lda     #$00                            ; 84EE
        sta     $04                             ; 84F0
        sta     $0D                             ; 84F2
        ldx     #$00                            ; 84F4
        ldy     $05                             ; 84F6
L84F8:  lda     $A5F9,y                         ; 84F8
        sta     $00,x                           ; 84FB
        iny                                     ; 84FD
        inx                                     ; 84FE
        cpx     #$04                            ; 84FF
        bne     L84F8                           ; 8501
        sty     $05                             ; 8503
        lda     $00                             ; 8505
        ora     $01                             ; 8507
        bne     L850E                           ; 8509
        sta     $0D                             ; 850B
        rts                                     ; 850D

; ----------------------------------------------------------------------------
L850E:  lda     $01                             ; 850E
        and     #$F0                            ; 8510
        pha                                     ; 8512
        lda     $01                             ; 8513
        and     #$0F                            ; 8515
        sta     $01                             ; 8517
        pla                                     ; 8519
        bne     L8548                           ; 851A
        ldy     #$00                            ; 851C
        lda     ($00),y                         ; 851E
        beq     L8542                           ; 8520
L8522:  ldy     $04                             ; 8522
        lda     $02                             ; 8524
        sta     $07,y                           ; 8526
        jsr     LA5A9                           ; 8529
        lda     $03                             ; 852C
        jsr     L9D2F                           ; 852E
        jsr     LB4F1                           ; 8531
        inc     $04                             ; 8534
        inc     $0D                             ; 8536
        lda     $0D                             ; 8538
        cmp     #$03                            ; 853A
        bne     L8542                           ; 853C
        lda     #$10                            ; 853E
        sta     $0D                             ; 8540
L8542:  jsr     LEEB3                           ; 8542
        jmp     LA4F4                           ; 8545

; ----------------------------------------------------------------------------
L8548:  cmp     #$F0                            ; 8548
        beq     L8522                           ; 854A
        cmp     #$10                            ; 854C
        bne     L8567                           ; 854E
        ldy     #$02                            ; 8550
L8552:  lda     ($00),y                         ; 8552
        bne     L855B                           ; 8554
        dey                                     ; 8556
        bpl     L8552                           ; 8557
        bmi     L8542                           ; 8559
L855B:  tya                                     ; 855B
        beq     L8522                           ; 855C
L855E:  inc     $02                             ; 855E
        inc     $03                             ; 8560
        dey                                     ; 8562
        bne     L855E                           ; 8563
        beq     L8522                           ; 8565
L8567:  cmp     #$20                            ; 8567
        bne     L8542                           ; 8569
        ldy     #$00                            ; 856B
        lda     ($00),y                         ; 856D
        beq     L8542                           ; 856F
        tay                                     ; 8571
        dey                                     ; 8572
        tya                                     ; 8573
        clc                                     ; 8574
        adc     $03                             ; 8575
        sta     $03                             ; 8577
        jmp     LA522                           ; 8579

; ----------------------------------------------------------------------------
        lda     $0D                             ; 857C
        and     #$10                            ; 857E
        php                                     ; 8580
        lda     $0D                             ; 8581
        and     #$03                            ; 8583
        plp                                     ; 8585
        beq     L858B                           ; 8586
        clc                                     ; 8588
        adc     #$03                            ; 8589
L858B:  asl     a                               ; 858B
        tay                                     ; 858C
        ldx     $0162                           ; 858D
        lda     $A5ED,y                         ; 8590
        jsr     LB5E1                           ; 8593
        lda     $A5ED,y                         ; 8596
        jsr     LB5E1                           ; 8599
        lda     #$01                            ; 859C
        jsr     LB5E1                           ; 859E
        lda     $0E                             ; 85A1
        jsr     LB5E1                           ; 85A3
        jmp     LB4F1                           ; 85A6

; ----------------------------------------------------------------------------
        lda     $0D                             ; 85A9
        and     #$10                            ; 85AB
        php                                     ; 85AD
        lda     $0D                             ; 85AE
        and     #$03                            ; 85B0
        plp                                     ; 85B2
        beq     L85B8                           ; 85B3
        clc                                     ; 85B5
        adc     #$03                            ; 85B6
L85B8:  asl     a                               ; 85B8
        tay                                     ; 85B9
        ldx     $0162                           ; 85BA
        inx                                     ; 85BD
        lda     $A5EE,y                         ; 85BE
        adc     #$01                            ; 85C1
        sta     $0163,x                         ; 85C3
        dex                                     ; 85C6
        lda     $A5ED,y                         ; 85C7
        adc     #$00                            ; 85CA
        jsr     LB5E1                           ; 85CC
        inx                                     ; 85CF
        lda     #$08                            ; 85D0
        jmp     LB5E1                           ; 85D2

; ----------------------------------------------------------------------------
        ldy     #$05                            ; 85D5
        lda     #$FF                            ; 85D7
L85D9:  sta     $07,y                           ; 85D9
        dey                                     ; 85DC
        bpl     L85D9                           ; 85DD
        rts                                     ; 85DF

; ----------------------------------------------------------------------------
        lda     #$08                            ; 85E0
        sta     $18                             ; 85E2
L85E4:  jsr     LEEB3                           ; 85E4
        jsr     LA87C                           ; 85E7
        bne     L85E4                           ; 85EA
        rts                                     ; 85EC

; ----------------------------------------------------------------------------
        and     #$02                            ; 85ED
        and     #$22                            ; 85EF
        and     #$42                            ; 85F1
        and     #$12                            ; 85F3
        and     #$32                            ; 85F5
        and     #$52                            ; 85F7
        and     #$03                            ; 85F9
        .byte   $0F                             ; 85FB
        brk                                     ; 85FC
        .byte   $23                             ; 85FD
        .byte   $13                             ; 85FE
        ora     #$01                            ; 85FF
        bmi     L8606                           ; 8601
        asl     $04,x                           ; 8603
        .byte   $26                             ; 8605
L8606:  .byte   $13                             ; 8606
        .byte   $0C                             ; 8607
        ora     $2A                             ; 8608
        .byte   $03                             ; 860A
        bpl     L8619                           ; 860B
        brk                                     ; 860D
        beq     L8610                           ; 860E
L8610:  .byte   $13                             ; 8610
        brk                                     ; 8611
        brk                                     ; 8612
        asl     $1E23                           ; 8613
        .byte   $14                             ; 8616
        .byte   $22                             ; 8617
        .byte   $23                             ; 8618
L8619:  .byte   $1F                             ; 8619
        .byte   $1A                             ; 861A
        .byte   $14                             ; 861B
        .byte   $03                             ; 861C
        asl     $25                             ; 861D
        brk                                     ; 861F
        beq     L8622                           ; 8620
L8622:  .byte   $13                             ; 8622
        brk                                     ; 8623
        brk                                     ; 8624
        lda     $03ED                           ; 8625
        bpl     L864A                           ; 8628
        lda     #$00                            ; 862A
        sta     $0A                             ; 862C
        lda     #$3C                            ; 862E
        sta     $01                             ; 8630
        lda     #$00                            ; 8632
        sta     $02                             ; 8634
        sta     $6D                             ; 8636
        lda     #$65                            ; 8638
        jsr     LE992                           ; 863A
        lda     $0A                             ; 863D
        bmi     L864A                           ; 863F
        jsr     LA64B                           ; 8641
        jsr     LEEB3                           ; 8644
        jmp     LA63D                           ; 8647

; ----------------------------------------------------------------------------
L864A:  rts                                     ; 864A

; ----------------------------------------------------------------------------
        jsr     LE97D                           ; 864B
        .byte   $64                             ; 864E
        ldx     $7C                             ; 864F
        ldx     $AE                             ; 8651
        .byte   $A7                             ; 8653
        .byte   $9F                             ; 8654
        ldx     $AE                             ; 8655
        .byte   $A7                             ; 8657
        .byte   $02                             ; 8658
        .byte   $A7                             ; 8659
        ldx     $3BA7                           ; 865A
        .byte   $A7                             ; 865D
        ldx     L91A7                           ; 865E
        .byte   $A7                             ; 8661
        sta     $38A7,x                         ; 8662
        lda     $01                             ; 8665
        sbc     #$01                            ; 8667
        sta     $01                             ; 8669
        lda     $02                             ; 866B
        sbc     #$00                            ; 866D
        sta     $02                             ; 866F
        ora     $01                             ; 8671
        bne     L867B                           ; 8673
        lda     #$08                            ; 8675
        sta     $18                             ; 8677
        inc     $0A                             ; 8679
L867B:  rts                                     ; 867B

; ----------------------------------------------------------------------------
        lda     $03ED                           ; 867C
        bpl     L869A                           ; 867F
        jsr     LA87C                           ; 8681
        bne     L8699                           ; 8684
        ldx     $0162                           ; 8686
        jsr     LA7BA                           ; 8689
        lda     #$00                            ; 868C
        jsr     LA7CE                           ; 868E
        jsr     LA7C4                           ; 8691
        jsr     LA85B                           ; 8694
        inc     $0A                             ; 8697
L8699:  rts                                     ; 8699

; ----------------------------------------------------------------------------
L869A:  inc     $0A                             ; 869A
        inc     $0A                             ; 869C
        rts                                     ; 869E

; ----------------------------------------------------------------------------
        jsr     LA87C                           ; 869F
        bne     L86FE                           ; 86A2
        lda     $03EE                           ; 86A4
        sta     $00                             ; 86A7
        lda     #$2C                            ; 86A9
        sta     $03                             ; 86AB
        lda     #$00                            ; 86AD
        jsr     LA347                           ; 86AF
        ldx     $0162                           ; 86B2
        jsr     LA7BA                           ; 86B5
        lda     #$01                            ; 86B8
        jsr     LA7CE                           ; 86BA
        txa                                     ; 86BD
        pha                                     ; 86BE
        sec                                     ; 86BF
        sbc     #$03                            ; 86C0
        tax                                     ; 86C2
        ldy     #$02                            ; 86C3
L86C5:  lda     $07,y                           ; 86C5
        sta     $0163,x                         ; 86C8
        dex                                     ; 86CB
        dey                                     ; 86CC
        bpl     L86C5                           ; 86CD
        lda     $03EF                           ; 86CF
        sta     $00                             ; 86D2
        lda     #$2C                            ; 86D4
        sta     $03                             ; 86D6
        lda     #$00                            ; 86D8
        jsr     LA347                           ; 86DA
        pla                                     ; 86DD
        tax                                     ; 86DE
        jsr     LA7BA                           ; 86DF
        lda     #$02                            ; 86E2
        jsr     LA7CE                           ; 86E4
        txa                                     ; 86E7
        pha                                     ; 86E8
        sec                                     ; 86E9
        sbc     #$02                            ; 86EA
        tax                                     ; 86EC
        ldy     #$02                            ; 86ED
L86EF:  lda     $07,y                           ; 86EF
        sta     $0163,x                         ; 86F2
        dex                                     ; 86F5
        dey                                     ; 86F6
        bpl     L86EF                           ; 86F7
        pla                                     ; 86F9
        tax                                     ; 86FA
        jsr     LA691                           ; 86FB
L86FE:  rts                                     ; 86FE

; ----------------------------------------------------------------------------
        jmp     LA69A                           ; 86FF

; ----------------------------------------------------------------------------
        lda     $03ED                           ; 8702
        and     #$60                            ; 8705
        beq     L8738                           ; 8707
        jsr     LA87C                           ; 8709
        bne     L8737                           ; 870C
        ldx     $0162                           ; 870E
        jsr     LA7BA                           ; 8711
        lda     $03ED                           ; 8714
        and     #$40                            ; 8717
        beq     L872F                           ; 8719
        lda     #$03                            ; 871B
        jsr     LA7CE                           ; 871D
        lda     $03ED                           ; 8720
        and     #$20                            ; 8723
        beq     L8734                           ; 8725
        lda     #$7F                            ; 8727
        jsr     LB5E1                           ; 8729
        jsr     LA7BA                           ; 872C
L872F:  lda     #$04                            ; 872F
        jsr     LA7CE                           ; 8731
L8734:  jsr     LA691                           ; 8734
L8737:  rts                                     ; 8737

; ----------------------------------------------------------------------------
L8738:  jmp     LA69A                           ; 8738

; ----------------------------------------------------------------------------
        lda     $03ED                           ; 873B
        and     #$0F                            ; 873E
        beq     L878E                           ; 8740
        sta     $02                             ; 8742
        jsr     LA87C                           ; 8744
        bne     L878D                           ; 8747
        ldx     $0162                           ; 8749
        jsr     LA7BA                           ; 874C
        ldy     $02                             ; 874F
        lda     $A886,y                         ; 8751
        bpl     L8773                           ; 8754
        lda     #$06                            ; 8756
        jsr     LA7CE                           ; 8758
        txa                                     ; 875B
        pha                                     ; 875C
        sec                                     ; 875D
        sbc     #$13                            ; 875E
        tax                                     ; 8760
        ldy     $02                             ; 8761
        lda     $A886,y                         ; 8763
        tay                                     ; 8766
        dey                                     ; 8767
        tya                                     ; 8768
        ora     #$80                            ; 8769
        jsr     LB5E1                           ; 876B
        pla                                     ; 876E
        tax                                     ; 876F
        jsr     LA7BA                           ; 8770
L8773:  lda     #$05                            ; 8773
        jsr     LA7CE                           ; 8775
        txa                                     ; 8778
        pha                                     ; 8779
        sec                                     ; 877A
        sbc     #$02                            ; 877B
        tax                                     ; 877D
        ldy     $02                             ; 877E
        lda     $A886,y                         ; 8780
        ora     #$80                            ; 8783
        jsr     LB5E1                           ; 8785
        pla                                     ; 8788
        tax                                     ; 8789
        jsr     LA691                           ; 878A
L878D:  rts                                     ; 878D

; ----------------------------------------------------------------------------
L878E:  jmp     LA69A                           ; 878E

; ----------------------------------------------------------------------------
        jsr     LA87C                           ; 8791
        bne     L879C                           ; 8794
        lda     #$0C                            ; 8796
        sta     $00                             ; 8798
        inc     $0A                             ; 879A
L879C:  rts                                     ; 879C

; ----------------------------------------------------------------------------
        dec     $00                             ; 879D
        bne     L87AD                           ; 879F
        lda     $031C                           ; 87A1
        ora     #$0F                            ; 87A4
        sta     $031C                           ; 87A6
        lda     #$FF                            ; 87A9
        sta     $0A                             ; 87AB
L87AD:  rts                                     ; 87AD

; ----------------------------------------------------------------------------
        jsr     LA87C                           ; 87AE
        bne     L87B9                           ; 87B1
        lda     #$08                            ; 87B3
        sta     $18                             ; 87B5
        inc     $0A                             ; 87B7
L87B9:  rts                                     ; 87B9

; ----------------------------------------------------------------------------
        lda     #$80                            ; 87BA
        jmp     LB5E1                           ; 87BC

; ----------------------------------------------------------------------------
        lda     #$2E                            ; 87BF
        jmp     LB5E1                           ; 87C1

; ----------------------------------------------------------------------------
        lda     #$2F                            ; 87C4
        jsr     LB5E1                           ; 87C6
        lda     #$00                            ; 87C9
        jmp     LB5E1                           ; 87CB

; ----------------------------------------------------------------------------
        asl     a                               ; 87CE
        tay                                     ; 87CF
        lda     $A7E6,y                         ; 87D0
        sta     $00                             ; 87D3
        lda     $A7E7,y                         ; 87D5
        sta     $01                             ; 87D8
        ldy     #$00                            ; 87DA
L87DC:  lda     ($00),y                         ; 87DC
        beq     L87E5                           ; 87DE
        jsr     LB5E1                           ; 87E0
        bne     L87DC                           ; 87E3
L87E5:  rts                                     ; 87E5

; ----------------------------------------------------------------------------
        .byte   $F4                             ; 87E6
        .byte   $A7                             ; 87E7
        ora     ($A8,x)                         ; 87E8
        ora     ($A8),y                         ; 87EA
        jsr     L2DA8                           ; 87EC
        tay                                     ; 87EF
        sec                                     ; 87F0
        tay                                     ; 87F1
        .byte   $47                             ; 87F2
        tay                                     ; 87F3
        .byte   $FF                             ; 87F4
        jmp     L2C42                           ; 87F5

; ----------------------------------------------------------------------------
        .byte   $B3                             ; 87F8
        bit     $3841                           ; 87F9
        .byte   $42                             ; 87FC
        .byte   $34                             ; 87FD
        .byte   $42                             ; 87FE
        .byte   $4F                             ; 87FF
        brk                                     ; 8800
        lda     $AE2C                           ; 8801
        bit     $4F37                           ; 8804
        .byte   $3F                             ; 8807
        rol     $2CB0                           ; 8808
        bit     $2C2C                           ; 880B
        .byte   $4F                             ; 880E
        .byte   $7F                             ; 880F
        brk                                     ; 8810
        lda     $AE2C                           ; 8811
        bit     $4F3C                           ; 8814
        .byte   $3F                             ; 8817
        rol     $2CB0                           ; 8818
        bit     $2C2C                           ; 881B
        .byte   $4F                             ; 881E
        brk                                     ; 881F
        lda     $B12C                           ; 8820
        rol     $4642                           ; 8823
        rol     $3341,x                         ; 8826
        bit     $4FB2                           ; 8829
        brk                                     ; 882C
        lda     $B12C                           ; 882D
        rol     $3E41                           ; 8830
        .byte   $33                             ; 8833
        bit     $4FB2                           ; 8834
        brk                                     ; 8837
        .byte   $FF                             ; 8838
        bit     $343C                           ; 8839
        .byte   $3C                             ; 883C
        rol     $3841,x                         ; 883D
        eor     #$34                            ; 8840
        .byte   $33                             ; 8842
        bit     $4F80                           ; 8843
        brk                                     ; 8846
        .byte   $80                             ; 8847
        jmp     L2C42                           ; 8848

; ----------------------------------------------------------------------------
        .byte   $B3                             ; 884B
        rol     $3037                           ; 884C
        .byte   $42                             ; 884F
        bit     $3E36                           ; 8850
        and     $2C34,x                         ; 8853
        .byte   $44                             ; 8856
        .byte   $3F                             ; 8857
        .byte   $4F                             ; 8858
        .byte   $7F                             ; 8859
        brk                                     ; 885A
        lda     #$63                            ; 885B
        sta     $E8                             ; 885D
        lda     #$01                            ; 885F
        sta     $E9                             ; 8861
        lda     #$86                            ; 8863
        sta     $EA                             ; 8865
        lda     #$06                            ; 8867
        sta     $EB                             ; 8869
        lda     #$01                            ; 886B
        sta     $EC                             ; 886D
        lda     #$F1                            ; 886F
        sta     $ED                             ; 8871
        lda     #$9F                            ; 8873
        sta     $EE                             ; 8875
        lda     #$FF                            ; 8877
        sta     $18                             ; 8879
        rts                                     ; 887B

; ----------------------------------------------------------------------------
        lda     $18                             ; 887C
        bne     L8886                           ; 887E
        sta     $0162                           ; 8880
        sta     $0163                           ; 8883
L8886:  rts                                     ; 8886

; ----------------------------------------------------------------------------
        brk                                     ; 8887
        ora     ($04,x)                         ; 8888
        ora     $08                             ; 888A
        .byte   $82                             ; 888C
        .byte   $89                             ; 888D
        stx     $0B                             ; 888E
        .byte   $83                             ; 8890
        txa                                     ; 8891
        .byte   $0C                             ; 8892
        .byte   $87                             ; 8893
        .byte   $2B                             ; 8894
        bit     a:$A9                           ; 8895
        jsr     LF7B1                           ; 8898
        lda     #$00                            ; 889B
        sta     $1A                             ; 889D
        jsr     LE95B                           ; 889F
        lda     $1A                             ; 88A2
        jsr     LA8AA                           ; 88A4
        jmp     LA89F                           ; 88A7

; ----------------------------------------------------------------------------
        jsr     LE97D                           ; 88AA
        sbc     ($A8,x)                         ; 88AD
        sbc     $B0A8,y                         ; 88AF
        tax                                     ; 88B2
        inc     $AA,x                           ; 88B3
        brk                                     ; 88B5
        brk                                     ; 88B6
        brk                                     ; 88B7
        brk                                     ; 88B8
        .byte   $D3                             ; 88B9
        .byte   $AB                             ; 88BA
        .byte   $0B                             ; 88BB
        ldy     $AD44                           ; 88BC
        sta     $CCB1,x                         ; 88BF
        lda     ($01),y                         ; 88C2
        .byte   $B3                             ; 88C4
        .byte   $2B                             ; 88C5
        .byte   $B3                             ; 88C6
        eor     $B2,x                           ; 88C7
        .byte   $32                             ; 88C9
        lda     #$01                            ; 88CA
        .byte   $B3                             ; 88CC
        .byte   $2B                             ; 88CD
        .byte   $B3                             ; 88CE
        .byte   $8F                             ; 88CF
        .byte   $B3                             ; 88D0
        ldx     a:$B3                           ; 88D1
        brk                                     ; 88D4
        brk                                     ; 88D5
        brk                                     ; 88D6
        .byte   $C7                             ; 88D7
        .byte   $B3                             ; 88D8
        cmp     $F7B3                           ; 88D9
        .byte   $B3                             ; 88DC
        .byte   $44                             ; 88DD
        lda     $B46D                           ; 88DE
        lda     #$0F                            ; 88E1
        ldx     #$1F                            ; 88E3
L88E5:  sta     $04A0,x                         ; 88E5
        dex                                     ; 88E8
        bpl     L88E5                           ; 88E9
        jsr     LB533                           ; 88EB
        lda     $0587                           ; 88EE
        sta     $030C                           ; 88F1
        inc     $1A                             ; 88F4
        jmp     LEA7E                           ; 88F6

; ----------------------------------------------------------------------------
        lda     $0E                             ; 88F9
        ora     $0F                             ; 88FB
        bne     L8913                           ; 88FD
        lda     #$00                            ; 88FF
        jsr     LB4DD                           ; 8901
        lda     #$5D                            ; 8904
        jsr     LB55B                           ; 8906
        lda     #$04                            ; 8909
        sta     $0D                             ; 890B
        lda     #$B5                            ; 890D
        sta     $0E                             ; 890F
        dec     $0F                             ; 8911
L8913:  jsr     LA925                           ; 8913
        lda     $0D                             ; 8916
        cmp     #$01                            ; 8918
        bne     L8920                           ; 891A
        jsr     LA92B                           ; 891C
        rts                                     ; 891F

; ----------------------------------------------------------------------------
L8920:  dec     $0E                             ; 8920
        jmp     LAA56                           ; 8922

; ----------------------------------------------------------------------------
        lda     $C2                             ; 8925
        and     #$0C                            ; 8927
        beq     L8934                           ; 8929
L892B:  lda     #$07                            ; 892B
        sta     $1A                             ; 892D
        jsr     LB52C                           ; 892F
        pla                                     ; 8932
        pla                                     ; 8933
L8934:  rts                                     ; 8934

; ----------------------------------------------------------------------------
        jsr     LEA7E                           ; 8935
        ldx     #$3B                            ; 8938
L893A:  lda     $A969,x                         ; 893A
        sta     $0200,x                         ; 893D
        dex                                     ; 8940
        bpl     L893A                           ; 8941
        ldx     #$48                            ; 8943
        ldy     #$00                            ; 8945
L8947:  lda     $A9A5,y                         ; 8947
        jsr     LA964                           ; 894A
        iny                                     ; 894D
        lda     #$E7                            ; 894E
        jsr     LA964                           ; 8950
        lda     #$20                            ; 8953
        .byte   $20                             ; 8955
        .byte   $64                             ; 8956
L8957:  .byte   $A9                             ; 8957
L8958:  lda     $A9A5,y                         ; 8958
        .byte   $20                             ; 895B
L895C:  .byte   $64                             ; 895C
L895D:  lda     #$C8                            ; 895D
        cpy     #$24                            ; 895F
        bne     L8947                           ; 8961
        rts                                     ; 8963

; ----------------------------------------------------------------------------
        sta     $0200,x                         ; 8964
        inx                                     ; 8967
        rts                                     ; 8968

; ----------------------------------------------------------------------------
        bmi     L8934                           ; 8969
        .byte   $20                             ; 896B
L896C:  bpl     L899E                           ; 896C
        cmp     $1820,y                         ; 896E
        bmi     L895C                           ; 8971
        jsr     L3020                           ; 8973
        .byte   $03                             ; 8976
        jsr     L3028                           ; 8977
        .byte   $EB                             ; 897A
        jsr     L3030                           ; 897B
        ora     ($20),y                         ; 897E
L8980:  sec                                     ; 8980
        rti                                     ; 8981

; ----------------------------------------------------------------------------
        .byte   $CB                             ; 8982
        jsr     L4010                           ; 8983
        .byte   $DB                             ; 8986
        jsr     L4018                           ; 8987
        ora     ($20,x)                         ; 898A
        sec                                     ; 898C
        bvc     L8958                           ; 898D
        ldy     #$10                            ; 898F
        bvc     L896C                           ; 8991
        ldy     #$18                            ; 8993
        bvc     L8980                           ; 8995
        ldy     #$20                            ; 8997
        bvc     L899E                           ; 8999
        ldy     #$28                            ; 899B
        .byte   $50                             ; 899D
L899E:  .byte   $EB                             ; 899E
        ldy     #$30                            ; 899F
        bvc     L89B4                           ; 89A1
        ldy     #$38                            ; 89A3
        php                                     ; 89A5
        rti                                     ; 89A6

; ----------------------------------------------------------------------------
        bpl     L89B1                           ; 89A7
        bpl     L892B                           ; 89A9
        bpl     L895D                           ; 89AB
        clc                                     ; 89AD
        beq     L89D0                           ; 89AE
        rts                                     ; 89B0

; ----------------------------------------------------------------------------
L89B1:  jsr     L28C0                           ; 89B1
L89B4:  sei                                     ; 89B4
        bmi     L8957                           ; 89B5
        rti                                     ; 89B7

; ----------------------------------------------------------------------------
        bcc     L89FA                           ; 89B8
        inx                                     ; 89BA
        pha                                     ; 89BB
        bne     L8A0E                           ; 89BC
        pla                                     ; 89BE
        cli                                     ; 89BF
        dey                                     ; 89C0
        pla                                     ; 89C1
        bmi     L8A2C                           ; 89C2
        tay                                     ; 89C4
        pla                                     ; 89C5
        cld                                     ; 89C6
        bvs     L8A21                           ; 89C7
        lda     $00                             ; 89C9
        beq     L89D0                           ; 89CB
        dec     $00                             ; 89CD
        rts                                     ; 89CF

; ----------------------------------------------------------------------------
L89D0:  lda     $E0                             ; 89D0
        and     #$3F                            ; 89D2
        sta     $00                             ; 89D4
        lda     $E7                             ; 89D6
        and     #$03                            ; 89D8
        sta     $01                             ; 89DA
        beq     L89F9                           ; 89DC
        lda     $E1                             ; 89DE
        adc     $E3                             ; 89E0
        adc     $E5                             ; 89E2
        jsr     LA9FA                           ; 89E4
        lda     $E2                             ; 89E7
        adc     $E4                             ; 89E9
        adc     $E6                             ; 89EB
        jsr     LA9FA                           ; 89ED
        lda     $E3                             ; 89F0
        adc     $E4                             ; 89F2
        adc     $E5                             ; 89F4
        jsr     LA9FA                           ; 89F6
L89F9:  rts                                     ; 89F9

; ----------------------------------------------------------------------------
L89FA:  and     #$3F                            ; 89FA
        cmp     #$12                            ; 89FC
        bcs     L8A04                           ; 89FE
        adc     #$12                            ; 8A00
        bne     L8A0C                           ; 8A02
L8A04:  cmp     #$24                            ; 8A04
        bcc     L8A0C                           ; 8A06
        sbc     #$12                            ; 8A08
        bne     L8A04                           ; 8A0A
L8A0C:  sta     $02                             ; 8A0C
L8A0E:  asl     a                               ; 8A0E
        asl     a                               ; 8A0F
        tax                                     ; 8A10
        lda     #$F0                            ; 8A11
        sta     $0200,x                         ; 8A13
        lda     $02                             ; 8A16
        sec                                     ; 8A18
        sbc     #$12                            ; 8A19
        tax                                     ; 8A1B
        lda     #$1E                            ; 8A1C
        sta     $07E0,x                         ; 8A1E
L8A21:  dec     $01                             ; 8A21
        bne     L8A27                           ; 8A23
        pla                                     ; 8A25
        pla                                     ; 8A26
L8A27:  rts                                     ; 8A27

; ----------------------------------------------------------------------------
        ldx     #$11                            ; 8A28
L8A2A:  .byte   $BD                             ; 8A2A
        .byte   $E0                             ; 8A2B
L8A2C:  .byte   $07                             ; 8A2C
        beq     L8A48                           ; 8A2D
        dec     $07E0,x                         ; 8A2F
        bne     L8A48                           ; 8A32
        txa                                     ; 8A34
        tay                                     ; 8A35
        pha                                     ; 8A36
        asl     a                               ; 8A37
        asl     a                               ; 8A38
        clc                                     ; 8A39
        adc     #$48                            ; 8A3A
        tax                                     ; 8A3C
        tya                                     ; 8A3D
        asl     a                               ; 8A3E
        tay                                     ; 8A3F
        lda     $A9A5,y                         ; 8A40
        sta     $0200,x                         ; 8A43
        pla                                     ; 8A46
        tax                                     ; 8A47
L8A48:  dex                                     ; 8A48
        bpl     L8A2A                           ; 8A49
        rts                                     ; 8A4B

; ----------------------------------------------------------------------------
        ldy     #$0E                            ; 8A4C
        jsr     LB45E                           ; 8A4E
        ldy     #$0F                            ; 8A51
        jmp     LB45E                           ; 8A53

; ----------------------------------------------------------------------------
        lda     $0F                             ; 8A56
        bpl     L8A6C                           ; 8A58
        lda     $1A                             ; 8A5A
        cmp     #$02                            ; 8A5C
        bne     L8A71                           ; 8A5E
        lda     $0E                             ; 8A60
        ldx     #$04                            ; 8A62
L8A64:  cmp     $050F,x                         ; 8A64
        beq     L8A6D                           ; 8A67
        dex                                     ; 8A69
        bpl     L8A64                           ; 8A6A
L8A6C:  rts                                     ; 8A6C

; ----------------------------------------------------------------------------
L8A6D:  jsr     LAA7E                           ; 8A6D
        rts                                     ; 8A70

; ----------------------------------------------------------------------------
L8A71:  lda     $0E                             ; 8A71
        ldx     #$04                            ; 8A73
L8A75:  cmp     $0514,x                         ; 8A75
        beq     L8A6D                           ; 8A78
        dex                                     ; 8A7A
        bpl     L8A75                           ; 8A7B
        rts                                     ; 8A7D

; ----------------------------------------------------------------------------
        lda     $0D                             ; 8A7E
        beq     L8AAF                           ; 8A80
        dec     $0D                             ; 8A82
        bne     L8A89                           ; 8A84
        jsr     LAA4C                           ; 8A86
L8A89:  ldx     $0162                           ; 8A89
        lda     #$3F                            ; 8A8C
        jsr     LB5E1                           ; 8A8E
        lda     #$00                            ; 8A91
        jsr     LB5E1                           ; 8A93
        lda     #$04                            ; 8A96
        jsr     LB5E1                           ; 8A98
        sta     $0C                             ; 8A9B
        lda     $0D                             ; 8A9D
        asl     a                               ; 8A9F
        asl     a                               ; 8AA0
        tay                                     ; 8AA1
L8AA2:  lda     $0519,y                         ; 8AA2
        jsr     LB5E1                           ; 8AA5
        dec     $0C                             ; 8AA8
        bne     L8AA2                           ; 8AAA
        jsr     LB4F1                           ; 8AAC
L8AAF:  rts                                     ; 8AAF

; ----------------------------------------------------------------------------
        lda     $0E                             ; 8AB0
        ora     $0F                             ; 8AB2
        bne     L8AED                           ; 8AB4
        lda     #$00                            ; 8AB6
        jsr     LB4DD                           ; 8AB8
        lda     #$5E                            ; 8ABB
        jsr     LE096                           ; 8ABD
        jsr     LA935                           ; 8AC0
        lda     #$04                            ; 8AC3
        sta     $0D                             ; 8AC5
        lda     #$00                            ; 8AC7
        ldx     #$1F                            ; 8AC9
L8ACB:  sta     $07E0,x                         ; 8ACB
        dex                                     ; 8ACE
        bpl     L8ACB                           ; 8ACF
        lda     #$05                            ; 8AD1
        jsr     LE992                           ; 8AD3
        lda     #$00                            ; 8AD6
        sta     $0B                             ; 8AD8
        jsr     LB520                           ; 8ADA
        jsr     LB55E                           ; 8ADD
        lda     #$00                            ; 8AE0
        sta     $00                             ; 8AE2
        lda     #$01                            ; 8AE4
        sta     $0F                             ; 8AE6
        lda     #$30                            ; 8AE8
        sta     $0E                             ; 8AEA
        rts                                     ; 8AEC

; ----------------------------------------------------------------------------
L8AED:  jsr     LA9C9                           ; 8AED
        jsr     LAA28                           ; 8AF0
        jmp     LAA56                           ; 8AF3

; ----------------------------------------------------------------------------
        lda     $0E                             ; 8AF6
        ora     $0F                             ; 8AF8
        bne     L8B14                           ; 8AFA
        lda     #$04                            ; 8AFC
        sta     $0D                             ; 8AFE
        inc     $0B                             ; 8B00
        lda     $0B                             ; 8B02
        cmp     #$07                            ; 8B04
        bcs     L8B0D                           ; 8B06
        dec     $1A                             ; 8B08
        jmp     LB520                           ; 8B0A

; ----------------------------------------------------------------------------
L8B0D:  inc     $1A                             ; 8B0D
        inc     $1A                             ; 8B0F
        inc     $1A                             ; 8B11
        rts                                     ; 8B13

; ----------------------------------------------------------------------------
L8B14:  jmp     LAAED                           ; 8B14

; ----------------------------------------------------------------------------
        lda     $0B                             ; 8B17
        bmi     L8B3A                           ; 8B19
        dec     $0B                             ; 8B1B
        bmi     L8B3B                           ; 8B1D
        beq     L8B41                           ; 8B1F
        ldx     #$00                            ; 8B21
        lda     #$04                            ; 8B23
        sta     $09                             ; 8B25
        lda     $0B                             ; 8B27
        asl     a                               ; 8B29
        asl     a                               ; 8B2A
        tay                                     ; 8B2B
L8B2C:  lda     $0568,y                         ; 8B2C
        jsr     LB553                           ; 8B2F
        bne     L8B2C                           ; 8B32
        jsr     LF07B                           ; 8B34
L8B37:  jmp     LB53A                           ; 8B37

; ----------------------------------------------------------------------------
L8B3A:  rts                                     ; 8B3A

; ----------------------------------------------------------------------------
L8B3B:  jsr     LAB72                           ; 8B3B
        jmp     LAB37                           ; 8B3E

; ----------------------------------------------------------------------------
L8B41:  ldx     #$00                            ; 8B41
        lda     #$F0                            ; 8B43
L8B45:  sta     $0200,x                         ; 8B45
        inx                                     ; 8B48
        inx                                     ; 8B49
        inx                                     ; 8B4A
        inx                                     ; 8B4B
        cpx     #$3C                            ; 8B4C
        bne     L8B45                           ; 8B4E
        beq     L8B37                           ; 8B50
        lda     $0A                             ; 8B52
        bmi     L8B71                           ; 8B54
        dec     $0A                             ; 8B56
        bmi     L8B6E                           ; 8B58
        ldx     #$04                            ; 8B5A
        stx     $09                             ; 8B5C
        lda     $0A                             ; 8B5E
        asl     a                               ; 8B60
        asl     a                               ; 8B61
        tay                                     ; 8B62
L8B63:  lda     $0578,y                         ; 8B63
        jsr     LB553                           ; 8B66
        bne     L8B63                           ; 8B69
        .byte   $20                             ; 8B6B
        .byte   $7B                             ; 8B6C
L8B6D:  .byte   $F0                             ; 8B6D
L8B6E:  jmp     LB53A                           ; 8B6E

; ----------------------------------------------------------------------------
L8B71:  rts                                     ; 8B71

; ----------------------------------------------------------------------------
        ldx     #$37                            ; 8B72
L8B74:  lda     $AB7E,x                         ; 8B74
        .byte   $9D                             ; 8B77
        brk                                     ; 8B78
L8B79:  .byte   $02                             ; 8B79
        dex                                     ; 8B7A
        bpl     L8B74                           ; 8B7B
        rts                                     ; 8B7D

; ----------------------------------------------------------------------------
        bmi     L8B6D                           ; 8B7E
        .byte   $21                             ; 8B80
L8B81:  clc                                     ; 8B81
        bmi     L8B81                           ; 8B82
        .byte   $21                             ; 8B84
L8B85:  jsr     $FD30                           ; 8B85
        adc     ($28,x)                         ; 8B88
        bmi     L8B79                           ; 8B8A
        .byte   $61                             ; 8B8C
L8B8D:  bmi     *+66                            ; 8B8D
        .byte   $CF                             ; 8B8F
        and     ($18,x)                         ; 8B90
        rti                                     ; 8B92

; ----------------------------------------------------------------------------
        .byte   $DF                             ; 8B93
        and     ($20,x)                         ; 8B94
        rti                                     ; 8B96

; ----------------------------------------------------------------------------
        .byte   $EF                             ; 8B97
        and     ($28,x)                         ; 8B98
        rti                                     ; 8B9A

; ----------------------------------------------------------------------------
        .byte   $CF                             ; 8B9B
        adc     ($30,x)                         ; 8B9C
        bvc     L8B6D                           ; 8B9E
        and     ($10,x)                         ; 8BA0
        bvc     L8B81                           ; 8BA2
        and     ($18,x)                         ; 8BA4
        .byte   $50                             ; 8BA6
L8BA7:  .byte   $FF                             ; 8BA7
        and     ($20,x)                         ; 8BA8
        .byte   $50                             ; 8BAA
L8BAB:  .byte   $FF                             ; 8BAB
        adc     ($28,x)                         ; 8BAC
        bvc     L8B8D                           ; 8BAE
        adc     ($30,x)                         ; 8BB0
        bvc     L8B81                           ; 8BB2
        adc     ($38,x)                         ; 8BB4
        lda     $0E                             ; 8BB6
        ldx     #$04                            ; 8BB8
L8BBA:  cmp     $0514,x                         ; 8BBA
        beq     L8BC3                           ; 8BBD
        dex                                     ; 8BBF
        bpl     L8BBA                           ; 8BC0
        rts                                     ; 8BC2

; ----------------------------------------------------------------------------
L8BC3:  jsr     LF067                           ; 8BC3
        dec     $0D                             ; 8BC6
        bpl     L8BD2                           ; 8BC8
        jsr     LE5AA                           ; 8BCA
        jsr     LB52C                           ; 8BCD
        inc     $1A                             ; 8BD0
L8BD2:  rts                                     ; 8BD2

; ----------------------------------------------------------------------------
        lda     $0E                             ; 8BD3
        ora     $0F                             ; 8BD5
        bne     L8BEB                           ; 8BD7
        lda     #$04                            ; 8BD9
        sta     $0D                             ; 8BDB
        sta     $0B                             ; 8BDD
        lda     #$02                            ; 8BDF
        sta     $0A                             ; 8BE1
        jsr     LB53A                           ; 8BE3
        lda     #$07                            ; 8BE6
        jmp     LB520                           ; 8BE8

; ----------------------------------------------------------------------------
L8BEB:  lda     $1E                             ; 8BEB
        cmp     #$07                            ; 8BED
        bne     L8C02                           ; 8BEF
        lda     $0B                             ; 8BF1
        bmi     L8BFB                           ; 8BF3
        jsr     LAB17                           ; 8BF5
        jmp     LAC02                           ; 8BF8

; ----------------------------------------------------------------------------
L8BFB:  lda     $0A                             ; 8BFB
        bmi     L8C02                           ; 8BFD
        jsr     LAB52                           ; 8BFF
L8C02:  jsr     LA9C9                           ; 8C02
        jsr     LAA28                           ; 8C05
        jmp     LABB6                           ; 8C08

; ----------------------------------------------------------------------------
        lda     $0E                             ; 8C0B
        ora     $0F                             ; 8C0D
        bne     L8C58                           ; 8C0F
        jsr     LB4E0                           ; 8C11
        lda     #$5F                            ; 8C14
        jsr     LE096                           ; 8C16
        lda     #$10                            ; 8C19
        jsr     LB4E8                           ; 8C1B
        jsr     LEA7E                           ; 8C1E
        jsr     LA943                           ; 8C21
        lda     #$04                            ; 8C24
        sta     $0D                             ; 8C26
        jsr     LB53A                           ; 8C28
        sta     $09                             ; 8C2B
        ldy     #$FF                            ; 8C2D
        lda     $030C                           ; 8C2F
L8C32:  iny                                     ; 8C32
        cmp     $0586,y                         ; 8C33
        bne     L8C32                           ; 8C36
        sty     $08                             ; 8C38
        ldy     #$0B                            ; 8C3A
        lda     #$0F                            ; 8C3C
L8C3E:  sta     $04A4,y                         ; 8C3E
        dey                                     ; 8C41
        bpl     L8C3E                           ; 8C42
        jsr     LB55E                           ; 8C44
        jsr     LAC90                           ; 8C47
        lda     #$05                            ; 8C4A
        jsr     LE992                           ; 8C4C
        lda     #$94                            ; 8C4F
        sta     $0E                             ; 8C51
        lda     #$11                            ; 8C53
        sta     $0F                             ; 8C55
        rts                                     ; 8C57

; ----------------------------------------------------------------------------
L8C58:  jsr     LA9C9                           ; 8C58
        jsr     LAA28                           ; 8C5B
        lda     $0D                             ; 8C5E
        bmi     L8C65                           ; 8C60
        jsr     LACFB                           ; 8C62
L8C65:  lda     $C2                             ; 8C65
        and     #$08                            ; 8C67
        beq     L8C83                           ; 8C69
        lda     #$7F                            ; 8C6B
        jsr     LE992                           ; 8C6D
        lda     #$0F                            ; 8C70
        sta     $1A                             ; 8C72
        lda     $09                             ; 8C74
        and     #$01                            ; 8C76
        sta     $1D                             ; 8C78
        beq     L8C80                           ; 8C7A
        lda     #$09                            ; 8C7C
        sta     $1A                             ; 8C7E
L8C80:  jmp     LB52C                           ; 8C80

; ----------------------------------------------------------------------------
L8C83:  lda     $C2                             ; 8C83
        asl     a                               ; 8C85
        bcc     L8CB8                           ; 8C86
        lda     $08                             ; 8C88
        cmp     #$02                            ; 8C8A
        beq     L8CB7                           ; 8C8C
        inc     $08                             ; 8C8E
        ldy     $08                             ; 8C90
        lda     $0586,y                         ; 8C92
        sta     $030C                           ; 8C95
        jsr     LB541                           ; 8C98
L8C9B:  lda     $0589,y                         ; 8C9B
        jsr     LB5E1                           ; 8C9E
        cpy     #$0C                            ; 8CA1
        bne     L8C9B                           ; 8CA3
        lda     $08                             ; 8CA5
        asl     a                               ; 8CA7
        asl     a                               ; 8CA8
        adc     #$03                            ; 8CA9
        adc     $0162                           ; 8CAB
        tay                                     ; 8CAE
        lda     #$28                            ; 8CAF
        sta     $0163,y                         ; 8CB1
        jsr     LB4F1                           ; 8CB4
L8CB7:  rts                                     ; 8CB7

; ----------------------------------------------------------------------------
L8CB8:  asl     a                               ; 8CB8
        bcc     L8CC4                           ; 8CB9
        lda     $08                             ; 8CBB
        beq     L8CB7                           ; 8CBD
        dec     $08                             ; 8CBF
        jmp     LAC90                           ; 8CC1

; ----------------------------------------------------------------------------
L8CC4:  lda     $C2                             ; 8CC4
        and     #$04                            ; 8CC6
        beq     L8CB7                           ; 8CC8
        inc     $09                             ; 8CCA
        ldy     #$03                            ; 8CCC
        lda     $09                             ; 8CCE
        lsr     a                               ; 8CD0
        bcs     L8CD5                           ; 8CD1
        ldy     #$00                            ; 8CD3
L8CD5:  ldx     $0162                           ; 8CD5
        lda     #$22                            ; 8CD8
        sta     $0163,x                         ; 8CDA
        inx                                     ; 8CDD
        lda     #$0B                            ; 8CDE
        sta     $0163,x                         ; 8CE0
        inx                                     ; 8CE3
        lda     #$83                            ; 8CE4
        sta     $0163,x                         ; 8CE6
        inx                                     ; 8CE9
        lda     #$03                            ; 8CEA
        sta     $00                             ; 8CEC
L8CEE:  lda     $0580,y                         ; 8CEE
        jsr     LB5E1                           ; 8CF1
        dec     $00                             ; 8CF4
        bne     L8CEE                           ; 8CF6
        jmp     LB4F1                           ; 8CF8

; ----------------------------------------------------------------------------
        lda     $1E                             ; 8CFB
        cmp     #$07                            ; 8CFD
        bne     L8D0A                           ; 8CFF
        ldy     $0D                             ; 8D01
        bmi     L8D0A                           ; 8D03
        dey                                     ; 8D05
        sty     $0D                             ; 8D06
        bpl     L8D0B                           ; 8D08
L8D0A:  rts                                     ; 8D0A

; ----------------------------------------------------------------------------
L8D0B:  ldx     $0162                           ; 8D0B
        lda     #$3F                            ; 8D0E
        sta     $0163,x                         ; 8D10
        inx                                     ; 8D13
        lda     #$04                            ; 8D14
        sta     $0163,x                         ; 8D16
        inx                                     ; 8D19
        lda     #$0C                            ; 8D1A
        sta     $0163,x                         ; 8D1C
        inx                                     ; 8D1F
        tya                                     ; 8D20
        asl     a                               ; 8D21
        asl     a                               ; 8D22
        asl     a                               ; 8D23
        asl     a                               ; 8D24
        sta     $07                             ; 8D25
        ldy     #$00                            ; 8D27
L8D29:  lda     $05C3,y                         ; 8D29
        cmp     #$0F                            ; 8D2C
        beq     L8D37                           ; 8D2E
        sec                                     ; 8D30
        sbc     $07                             ; 8D31
        bcs     L8D37                           ; 8D33
        lda     #$0F                            ; 8D35
L8D37:  jsr     LB5E1                           ; 8D37
        cpy     #$0C                            ; 8D3A
        bne     L8D29                           ; 8D3C
        jsr     LB4F1                           ; 8D3E
        jmp     LB53A                           ; 8D41

; ----------------------------------------------------------------------------
        lda     $0F                             ; 8D44
        bne     L8D79                           ; 8D46
        lda     #$04                            ; 8D48
        jsr     LB4DD                           ; 8D4A
        jsr     LEA7E                           ; 8D4D
        lda     #$60                            ; 8D50
        jsr     LE096                           ; 8D52
        lda     #$09                            ; 8D55
        jsr     LB513                           ; 8D57
        lda     #$05                            ; 8D5A
        jsr     LE992                           ; 8D5C
        lda     #$06                            ; 8D5F
        sta     $EB                             ; 8D61
        inc     $0F                             ; 8D63
        jsr     LE5B2                           ; 8D65
L8D68:  jsr     LE95B                           ; 8D68
        lda     $18                             ; 8D6B
        bne     L8D68                           ; 8D6D
        lda     #$17                            ; 8D6F
        jsr     LB547                           ; 8D71
        lda     #$00                            ; 8D74
        sta     $09                             ; 8D76
        rts                                     ; 8D78

; ----------------------------------------------------------------------------
L8D79:  lda     $C2                             ; 8D79
        bpl     L8D8A                           ; 8D7B
        lda     $09                             ; 8D7D
        cmp     #$02                            ; 8D7F
        beq     L8D99                           ; 8D81
        inc     $09                             ; 8D83
        lda     $09                             ; 8D85
        jmp     LAD96                           ; 8D87

; ----------------------------------------------------------------------------
L8D8A:  and     #$40                            ; 8D8A
        beq     L8D9A                           ; 8D8C
        lda     $09                             ; 8D8E
        beq     L8D99                           ; 8D90
        dec     $09                             ; 8D92
        lda     $09                             ; 8D94
        jsr     LADC7                           ; 8D96
L8D99:  rts                                     ; 8D99

; ----------------------------------------------------------------------------
L8D9A:  lda     $C2                             ; 8D9A
        and     #$0F                            ; 8D9C
        beq     L8DC6                           ; 8D9E
        jsr     L99F6                           ; 8DA0
        lda     $09                             ; 8DA3
        sta     $92                             ; 8DA5
        lda     #$0B                            ; 8DA7
        jsr     LB513                           ; 8DA9
        lda     #$06                            ; 8DAC
        sta     $EB                             ; 8DAE
L8DB0:  lda     $18                             ; 8DB0
        bne     L8DB0                           ; 8DB2
        jsr     LB533                           ; 8DB4
        lda     $1A                             ; 8DB7
        inc     $1A                             ; 8DB9
        cmp     #$0F                            ; 8DBB
        bcs     L8DC6                           ; 8DBD
        jsr     LB4B0                           ; 8DBF
        lda     #$0E                            ; 8DC2
        sta     $1A                             ; 8DC4
L8DC6:  rts                                     ; 8DC6

; ----------------------------------------------------------------------------
        sta     $01                             ; 8DC7
        jsr     LB541                           ; 8DC9
L8DCC:  lda     $05CF,y                         ; 8DCC
        jsr     LB5E1                           ; 8DCF
        cpy     #$0C                            ; 8DD2
        bne     L8DCC                           ; 8DD4
        lda     #$00                            ; 8DD6
        sta     $0163,x                         ; 8DD8
        stx     $00                             ; 8DDB
        inc     $01                             ; 8DDD
        asl     $01                             ; 8DDF
        asl     $01                             ; 8DE1
        dec     $01                             ; 8DE3
        lda     $0162                           ; 8DE5
        adc     $01                             ; 8DE8
        tax                                     ; 8DEA
        lda     #$28                            ; 8DEB
        sta     $0163,x                         ; 8DED
        ldx     $00                             ; 8DF0
        stx     $0162                           ; 8DF2
        rts                                     ; 8DF5

; ----------------------------------------------------------------------------
        jsr     LE5AA                           ; 8DF6
        lda     #$00                            ; 8DF9
        jsr     LF7B1                           ; 8DFB
        lda     #$00                            ; 8DFE
        sta     $1A                             ; 8E00
        jsr     LE95B                           ; 8E02
        lda     $1A                             ; 8E05
        jsr     LAE0D                           ; 8E07
        jmp     LAE02                           ; 8E0A

; ----------------------------------------------------------------------------
        jsr     LE97D                           ; 8E0D
        .byte   $1A                             ; 8E10
        ldx     $AE47                           ; 8E11
        cli                                     ; 8E14
        ldx     $AE7E                           ; 8E15
        txa                                     ; 8E18
        ldx     a:$A9                           ; 8E19
        jsr     LB4DD                           ; 8E1C
        lda     #$3C                            ; 8E1F
        jsr     LE992                           ; 8E21
        jsr     LEA7E                           ; 8E24
        ldy     #$12                            ; 8E27
        jsr     LB45E                           ; 8E29
        jsr     LE5B2                           ; 8E2C
        lda     #$D2                            ; 8E2F
        sta     $0F                             ; 8E31
        lsr     $8B                             ; 8E33
        ldx     #$01                            ; 8E35
L8E37:  lsr     $89,x                           ; 8E37
        bcc     L8E41                           ; 8E39
        lda     $8A,x                           ; 8E3B
        adc     #$04                            ; 8E3D
        sta     $8A,x                           ; 8E3F
L8E41:  dex                                     ; 8E41
        bpl     L8E37                           ; 8E42
        inc     $1A                             ; 8E44
        rts                                     ; 8E46

; ----------------------------------------------------------------------------
        lda     $1E                             ; 8E47
        lsr     a                               ; 8E49
        bcc     L8E57                           ; 8E4A
        dec     $0F                             ; 8E4C
        bne     L8E57                           ; 8E4E
        lda     #$FF                            ; 8E50
        jsr     LE992                           ; 8E52
        inc     $1A                             ; 8E55
L8E57:  rts                                     ; 8E57

; ----------------------------------------------------------------------------
        jsr     LB4E0                           ; 8E58
        lda     #$5F                            ; 8E5B
        jsr     LE992                           ; 8E5D
        jsr     LE5B2                           ; 8E60
        lda     #$0C                            ; 8E63
        jsr     LB513                           ; 8E65
        jsr     LAE75                           ; 8E68
L8E6B:  lda     $18                             ; 8E6B
        bne     L8E6B                           ; 8E6D
        jsr     LAED3                           ; 8E6F
        inc     $1A                             ; 8E72
        rts                                     ; 8E74

; ----------------------------------------------------------------------------
        jsr     LB6BC                           ; 8E75
        jsr     LB70D                           ; 8E78
        jmp     LB74E                           ; 8E7B

; ----------------------------------------------------------------------------
        lda     #$11                            ; 8E7E
        jsr     LB547                           ; 8E80
        lda     #$01                            ; 8E83
        sta     $09                             ; 8E85
        inc     $1A                             ; 8E87
        rts                                     ; 8E89

; ----------------------------------------------------------------------------
        lda     $C2                             ; 8E8A
        and     #$08                            ; 8E8C
        beq     L8E9E                           ; 8E8E
        lda     #$FF                            ; 8E90
        jsr     LE992                           ; 8E92
        lda     $09                             ; 8E95
        and     #$01                            ; 8E97
        sta     $1D                             ; 8E99
        pla                                     ; 8E9B
        pla                                     ; 8E9C
        rts                                     ; 8E9D

; ----------------------------------------------------------------------------
L8E9E:  lda     $C2                             ; 8E9E
        and     #$04                            ; 8EA0
        beq     L8ED2                           ; 8EA2
        inc     $09                             ; 8EA4
        ldx     $0162                           ; 8EA6
        lda     #$22                            ; 8EA9
        jsr     LB5E1                           ; 8EAB
        lda     #$AA                            ; 8EAE
        jsr     LB5E1                           ; 8EB0
        lda     #$83                            ; 8EB3
        jsr     LB5E1                           ; 8EB5
        ldy     #$00                            ; 8EB8
        lda     $09                             ; 8EBA
        lsr     a                               ; 8EBC
        bcc     L8EC1                           ; 8EBD
        ldy     #$03                            ; 8EBF
L8EC1:  lda     #$03                            ; 8EC1
        sta     $00                             ; 8EC3
L8EC5:  lda     $0580,y                         ; 8EC5
        jsr     LB5E1                           ; 8EC8
        dec     $00                             ; 8ECB
        bne     L8EC5                           ; 8ECD
        jsr     LB4F1                           ; 8ECF
L8ED2:  rts                                     ; 8ED2

; ----------------------------------------------------------------------------
        ldy     #$00                            ; 8ED3
        lda     #$21                            ; 8ED5
        sta     $0440                           ; 8ED7
        lda     #$06                            ; 8EDA
        sta     $0441                           ; 8EDC
L8EDF:  ldx     #$03                            ; 8EDF
        sty     $05                             ; 8EE1
        ldy     #$13                            ; 8EE3
        lda     $00                             ; 8EE5
        cmp     #$0F                            ; 8EE7
        bcs     L8EFC                           ; 8EE9
        ldy     #$04                            ; 8EEB
        cmp     #$0C                            ; 8EED
        bcs     L8EFC                           ; 8EEF
        dey                                     ; 8EF1
        cmp     #$08                            ; 8EF2
        bcs     L8EFC                           ; 8EF4
        dey                                     ; 8EF6
        cmp     #$04                            ; 8EF7
        bcs     L8EFC                           ; 8EF9
        dey                                     ; 8EFB
L8EFC:  sty     $04                             ; 8EFC
        cpy     #$13                            ; 8EFE
        beq     L8F09                           ; 8F00
        sty     $07                             ; 8F02
        clc                                     ; 8F04
        adc     $07                             ; 8F05
        sta     $04                             ; 8F07
L8F09:  ldy     $05                             ; 8F09
        lda     #$00                            ; 8F0B
        sta     $02                             ; 8F0D
L8F0F:  lda     $0400,y                         ; 8F0F
        sta     $0440,x                         ; 8F12
        inx                                     ; 8F15
        iny                                     ; 8F16
        inc     $02                             ; 8F17
        lda     $02                             ; 8F19
        cmp     #$04                            ; 8F1B
        beq     L8F27                           ; 8F1D
        cmp     #$09                            ; 8F1F
        beq     L8F27                           ; 8F21
        cmp     #$0E                            ; 8F23
        bne     L8F37                           ; 8F25
L8F27:  lda     $04                             ; 8F27
        cmp     #$01                            ; 8F29
        beq     L8F37                           ; 8F2B
        lda     #$2C                            ; 8F2D
        sta     $0440,x                         ; 8F2F
        inx                                     ; 8F32
        dec     $04                             ; 8F33
        inc     $02                             ; 8F35
L8F37:  dec     $00                             ; 8F37
        bmi     L8F44                           ; 8F39
        dec     $04                             ; 8F3B
        bne     L8F0F                           ; 8F3D
        jsr     LAF44                           ; 8F3F
        bne     L8EDF                           ; 8F42
L8F44:  lda     #$00                            ; 8F44
        sta     $0440,x                         ; 8F46
        dex                                     ; 8F49
        dex                                     ; 8F4A
        dex                                     ; 8F4B
        stx     $0442                           ; 8F4C
        lda     #$0C                            ; 8F4F
        jsr     LB4FA                           ; 8F51
        lda     #$01                            ; 8F54
        sta     $EC                             ; 8F56
        lda     #$FF                            ; 8F58
        sta     $18                             ; 8F5A
L8F5C:  lda     $18                             ; 8F5C
        bne     L8F5C                           ; 8F5E
        lda     $0441                           ; 8F60
        clc                                     ; 8F63
        adc     #$40                            ; 8F64
        sta     $0441                           ; 8F66
        rts                                     ; 8F69

; ----------------------------------------------------------------------------
        lda     #$06                            ; 8F6A
        sta     $EA                             ; 8F6C
        lda     #$00                            ; 8F6E
        sta     $EB                             ; 8F70
        sta     $EC                             ; 8F72
        lda     #$FA                            ; 8F74
        sta     $E8                             ; 8F76
        lda     #$05                            ; 8F78
        sta     $E9                             ; 8F7A
        lda     $1A                             ; 8F7C
        cmp     #$0B                            ; 8F7E
        bcc     L8F8A                           ; 8F80
        lda     #$34                            ; 8F82
        sta     $E8                             ; 8F84
        lda     #$06                            ; 8F86
        sta     $E9                             ; 8F88
L8F8A:  lda     #$FF                            ; 8F8A
        sta     $18                             ; 8F8C
        jmp     LE95B                           ; 8F8E

; ----------------------------------------------------------------------------
        lda     #$21                            ; 8F91
        sta     $00                             ; 8F93
        lda     #$A6                            ; 8F95
        sta     $01                             ; 8F97
        jmp     LB64C                           ; 8F99

; ----------------------------------------------------------------------------
        lda     $00                             ; 8F9C
        asl     a                               ; 8F9E
        asl     a                               ; 8F9F
        asl     a                               ; 8FA0
        asl     a                               ; 8FA1
        clc                                     ; 8FA2
        adc     #$68                            ; 8FA3
        sta     $0200                           ; 8FA5
        lda     $01                             ; 8FA8
        asl     a                               ; 8FAA
        asl     a                               ; 8FAB
        asl     a                               ; 8FAC
        sta     $0203                           ; 8FAD
        rts                                     ; 8FB0

; ----------------------------------------------------------------------------
        jmp     LB698                           ; 8FB1

; ----------------------------------------------------------------------------
        asl     a                               ; 8FB4
        bcc     L8FBA                           ; 8FB5
        jmp     LAFF8                           ; 8FB7

; ----------------------------------------------------------------------------
L8FBA:  asl     a                               ; 8FBA
        bcc     L8FC0                           ; 8FBB
        jmp     LB011                           ; 8FBD

; ----------------------------------------------------------------------------
L8FC0:  asl     a                               ; 8FC0
        bcc     L8FC6                           ; 8FC1
        jmp     LAFE2                           ; 8FC3

; ----------------------------------------------------------------------------
L8FC6:  asl     a                               ; 8FC6
        bcc     L8FCC                           ; 8FC7
        jmp     LAFCD                           ; 8FC9

; ----------------------------------------------------------------------------
L8FCC:  rts                                     ; 8FCC

; ----------------------------------------------------------------------------
        ldy     $01                             ; 8FCD
        lda     $00                             ; 8FCF
        beq     L8FE1                           ; 8FD1
        cmp     #$03                            ; 8FD3
        bne     L8FDF                           ; 8FD5
        cpy     #$17                            ; 8FD7
        bne     L8FDF                           ; 8FD9
        dec     $01                             ; 8FDB
        dec     $01                             ; 8FDD
L8FDF:  dec     $00                             ; 8FDF
L8FE1:  rts                                     ; 8FE1

; ----------------------------------------------------------------------------
        ldy     $01                             ; 8FE2
        ldx     $00                             ; 8FE4
        cpx     #$03                            ; 8FE6
        beq     L8FF7                           ; 8FE8
        txa                                     ; 8FEA
        bne     L8FF5                           ; 8FEB
        cpy     #$17                            ; 8FED
        bne     L8FF5                           ; 8FEF
        dec     $01                             ; 8FF1
        dec     $01                             ; 8FF3
L8FF5:  inc     $00                             ; 8FF5
L8FF7:  rts                                     ; 8FF7

; ----------------------------------------------------------------------------
        ldy     $01                             ; 8FF8
        cpy     #$17                            ; 8FFA
        beq     L9010                           ; 8FFC
        lda     $00                             ; 8FFE
        cmp     #$01                            ; 9000
        beq     L9008                           ; 9002
        cmp     #$02                            ; 9004
        bne     L900C                           ; 9006
L9008:  cpy     #$15                            ; 9008
        beq     L9010                           ; 900A
L900C:  iny                                     ; 900C
        iny                                     ; 900D
        sty     $01                             ; 900E
L9010:  rts                                     ; 9010

; ----------------------------------------------------------------------------
        ldy     $01                             ; 9011
        cpy     #$05                            ; 9013
        beq     L901B                           ; 9015
        dey                                     ; 9017
        dey                                     ; 9018
        sty     $01                             ; 9019
L901B:  rts                                     ; 901B

; ----------------------------------------------------------------------------
        clc                                     ; 901C
        lda     #$00                            ; 901D
        sta     $0D                             ; 901F
        lda     $02                             ; 9021
        ldx     #$06                            ; 9023
L9025:  rol     a                               ; 9025
        rol     $0D                             ; 9026
        dex                                     ; 9028
        bne     L9025                           ; 9029
        ora     $03                             ; 902B
        clc                                     ; 902D
        adc     #$C0                            ; 902E
        sta     $0E                             ; 9030
        lda     $0D                             ; 9032
        adc     #$20                            ; 9034
        sta     $0D                             ; 9036
        rts                                     ; 9038

; ----------------------------------------------------------------------------
        inc     $03                             ; 9039
        lda     $03                             ; 903B
        cmp     #$0A                            ; 903D
        beq     L9049                           ; 903F
        cmp     #$0F                            ; 9041
        beq     L9049                           ; 9043
        cmp     #$14                            ; 9045
        bne     L904C                           ; 9047
L9049:  inc     $03                             ; 9049
        rts                                     ; 904B

; ----------------------------------------------------------------------------
L904C:  cmp     #$19                            ; 904C
        bne     L905E                           ; 904E
        dec     $03                             ; 9050
        ldx     $02                             ; 9052
        cpx     #$02                            ; 9054
        beq     L905E                           ; 9056
        inc     $02                             ; 9058
        lda     #$06                            ; 905A
        sta     $03                             ; 905C
L905E:  rts                                     ; 905E

; ----------------------------------------------------------------------------
        dec     $03                             ; 905F
        lda     $03                             ; 9061
        cmp     #$14                            ; 9063
        beq     L906F                           ; 9065
        cmp     #$0F                            ; 9067
        beq     L906F                           ; 9069
        cmp     #$0A                            ; 906B
        bne     L9072                           ; 906D
L906F:  dec     $03                             ; 906F
        rts                                     ; 9071

; ----------------------------------------------------------------------------
L9072:  cmp     #$05                            ; 9072
        bne     L9082                           ; 9074
        inc     $03                             ; 9076
        ldx     $02                             ; 9078
        beq     L9082                           ; 907A
        dec     $02                             ; 907C
        lda     #$18                            ; 907E
        sta     $03                             ; 9080
L9082:  rts                                     ; 9082

; ----------------------------------------------------------------------------
        lda     $1E                             ; 9083
        and     #$0F                            ; 9085
        bne     L90B0                           ; 9087
        jsr     LB01C                           ; 9089
        jsr     LB5E7                           ; 908C
        ldy     $04                             ; 908F
        lda     $0400,y                         ; 9091
        ldy     #$2C                            ; 9094
        cmp     #$2C                            ; 9096
        bne     L909C                           ; 9098
        ldy     #$7C                            ; 909A
L909C:  lda     $1E                             ; 909C
        and     #$10                            ; 909E
        bne     L90A8                           ; 90A0
        ldy     $04                             ; 90A2
        lda     $0400,y                         ; 90A4
        tay                                     ; 90A7
L90A8:  tya                                     ; 90A8
        sta     $0163,x                         ; 90A9
        inx                                     ; 90AC
        jsr     LB4F1                           ; 90AD
L90B0:  rts                                     ; 90B0

; ----------------------------------------------------------------------------
        lda     $C2                             ; 90B1
        and     #$F0                            ; 90B3
        beq     L90C3                           ; 90B5
        sta     $07                             ; 90B7
        lda     $C2                             ; 90B9
        jsr     LAFB4                           ; 90BB
        lda     #$1E                            ; 90BE
        sta     $06                             ; 90C0
        rts                                     ; 90C2

; ----------------------------------------------------------------------------
L90C3:  lda     $07                             ; 90C3
        beq     L90DC                           ; 90C5
        lda     $C0                             ; 90C7
        and     #$F0                            ; 90C9
        and     $07                             ; 90CB
        beq     L90DC                           ; 90CD
        dec     $06                             ; 90CF
        bne     L90E0                           ; 90D1
        jsr     LAFB4                           ; 90D3
        lda     #$0A                            ; 90D6
        sta     $06                             ; 90D8
        bne     L90E0                           ; 90DA
L90DC:  lda     #$00                            ; 90DC
        sta     $07                             ; 90DE
L90E0:  rts                                     ; 90E0

; ----------------------------------------------------------------------------
        lda     $01                             ; 90E1
        cmp     #$15                            ; 90E3
        bne     L90F8                           ; 90E5
        lda     $00                             ; 90E7
        cmp     #$01                            ; 90E9
        bne     L90F1                           ; 90EB
        jsr     LB12E                           ; 90ED
        rts                                     ; 90F0

; ----------------------------------------------------------------------------
L90F1:  cmp     #$02                            ; 90F1
        bne     L90F8                           ; 90F3
        jmp     LB17D                           ; 90F5

; ----------------------------------------------------------------------------
L90F8:  jsr     LB01C                           ; 90F8
        jsr     LB698                           ; 90FB
        jsr     LB5FD                           ; 90FE
        cpx     #$2F                            ; 9101
        beq     L9113                           ; 9103
        inx                                     ; 9105
        stx     $04                             ; 9106
        txa                                     ; 9108
        cmp     $05                             ; 9109
        bcc     L910F                           ; 910B
        sta     $05                             ; 910D
L910F:  jsr     LB039                           ; 910F
        rts                                     ; 9112

; ----------------------------------------------------------------------------
L9113:  inx                                     ; 9113
        stx     $05                             ; 9114
        rts                                     ; 9116

; ----------------------------------------------------------------------------
        lda     $04                             ; 9117
        beq     L912D                           ; 9119
        jsr     LB53A                           ; 911B
        jsr     LB083                           ; 911E
        dec     $04                             ; 9121
        jsr     LB05F                           ; 9123
        lda     #$10                            ; 9126
        sta     $1E                             ; 9128
        jsr     LB083                           ; 912A
L912D:  rts                                     ; 912D

; ----------------------------------------------------------------------------
        ldx     $05                             ; 912E
        beq     L917C                           ; 9130
        cpx     $04                             ; 9132
        beq     L917C                           ; 9134
        ldx     $04                             ; 9136
L9138:  inx                                     ; 9138
        lda     $0400,x                         ; 9139
        dex                                     ; 913C
        sta     $0400,x                         ; 913D
L9140:  inx                                     ; 9140
        cpx     $05                             ; 9141
        bmi     L9138                           ; 9143
        lda     $02                             ; 9145
        pha                                     ; 9147
        lda     $03                             ; 9148
        pha                                     ; 914A
        lda     $04                             ; 914B
        pha                                     ; 914D
L914E:  jsr     LB53A                           ; 914E
        lda     $1A                             ; 9151
        cmp     #$0C                            ; 9153
        beq     L9160                           ; 9155
        jsr     LB083                           ; 9157
        jsr     LB039                           ; 915A
        jmp     LB166                           ; 915D

; ----------------------------------------------------------------------------
L9160:  jsr     LB083                           ; 9160
        jsr     LB296                           ; 9163
        jsr     LE95B                           ; 9166
        inc     $04                             ; 9169
        lda     $05                             ; 916B
        cmp     $04                             ; 916D
        bpl     L914E                           ; 916F
        dec     $05                             ; 9171
        pla                                     ; 9173
        sta     $04                             ; 9174
        pla                                     ; 9176
        sta     $03                             ; 9177
        pla                                     ; 9179
        sta     $02                             ; 917A
L917C:  rts                                     ; 917C

; ----------------------------------------------------------------------------
        lda     $04                             ; 917D
        cmp     $05                             ; 917F
        bcs     L917C                           ; 9181
        jsr     LB53A                           ; 9183
        jsr     LB083                           ; 9186
        inc     $04                             ; 9189
        lda     $1A                             ; 918B
        cmp     #$0C                            ; 918D
        beq     L9197                           ; 918F
        jsr     LB039                           ; 9191
        jmp     LB126                           ; 9194

; ----------------------------------------------------------------------------
L9197:  jsr     LB296                           ; 9197
        jmp     LB126                           ; 919A

; ----------------------------------------------------------------------------
        lda     #$03                            ; 919D
        jsr     LB569                           ; 919F
        ldx     #$40                            ; 91A2
        lda     #$2C                            ; 91A4
L91A6:  .byte   $9D                             ; 91A6
L91A7:  brk                                     ; 91A7
        .byte   $04                             ; 91A8
        dex                                     ; 91A9
        bpl     L91A6                           ; 91AA
        ldx     #$0F                            ; 91AC
        lda     #$00                            ; 91AE
L91B0:  sta     $00,x                           ; 91B0
        dex                                     ; 91B2
        bpl     L91B0                           ; 91B3
        lda     #$06                            ; 91B5
        sta     $03                             ; 91B7
        lda     #$5F                            ; 91B9
        jsr     LE992                           ; 91BB
        jsr     LB575                           ; 91BE
        lda     #$0F                            ; 91C1
        sta     $04B0                           ; 91C3
        jsr     LB55E                           ; 91C6
        inc     $1A                             ; 91C9
        rts                                     ; 91CB

; ----------------------------------------------------------------------------
        jsr     LB083                           ; 91CC
        jsr     LB0B1                           ; 91CF
        jsr     LAF9C                           ; 91D2
        lda     $C2                             ; 91D5
        lsr     a                               ; 91D7
        bcc     L91E0                           ; 91D8
        jsr     L99F6                           ; 91DA
        jmp     LB0E1                           ; 91DD

; ----------------------------------------------------------------------------
L91E0:  lsr     a                               ; 91E0
        bcc     L91E6                           ; 91E1
        jmp     LB117                           ; 91E3

; ----------------------------------------------------------------------------
L91E6:  lsr     a                               ; 91E6
        lsr     a                               ; 91E7
        bcs     L91EB                           ; 91E8
        rts                                     ; 91EA

; ----------------------------------------------------------------------------
L91EB:  jsr     L99F6                           ; 91EB
        jsr     LB53A                           ; 91EE
        jsr     LB083                           ; 91F1
        jsr     LB78C                           ; 91F4
        bne     L9226                           ; 91F7
        jsr     LB7E6                           ; 91F9
        bpl     L9219                           ; 91FC
        lda     #$00                            ; 91FE
        sta     $0C                             ; 9200
L9202:  lda     #$F8                            ; 9202
        sta     $0200                           ; 9204
        lda     $0C                             ; 9207
        cmp     #$02                            ; 9209
        bcc     L920F                           ; 920B
        lda     #$00                            ; 920D
L920F:  adc     #$62                            ; 920F
        jsr     LE096                           ; 9211
        lda     #$0D                            ; 9214
        sta     $1A                             ; 9216
        rts                                     ; 9218

; ----------------------------------------------------------------------------
L9219:  bne     L9239                           ; 9219
        jsr     LB846                           ; 921B
        bne     L9239                           ; 921E
        ldx     $0401                           ; 9220
        dex                                     ; 9223
        stx     $82                             ; 9224
L9226:  lda     #$FF                            ; 9226
        jsr     LE992                           ; 9228
        asl     $0C                             ; 922B
        lda     #$0B                            ; 922D
        bcs     L9236                           ; 922F
        .byte   $20                             ; 9231
        .byte   $B0                             ; 9232
L9233:  ldy     $A9,x                           ; 9233
        .byte   $0E                             ; 9235
L9236:  sta     $1A                             ; 9236
        rts                                     ; 9238

; ----------------------------------------------------------------------------
L9239:  lda     $0C                             ; 9239
        cmp     #$03                            ; 923B
        bcc     L9202                           ; 923D
        lda     $0401                           ; 923F
        sec                                     ; 9242
        sbc     #$01                            ; 9243
        sta     $3B                             ; 9245
        pha                                     ; 9247
        jsr     LBAD1                           ; 9248
        lda     #$00                            ; 924B
        sta     $87                             ; 924D
        pla                                     ; 924F
        sta     $82                             ; 9250
        jmp     LB226                           ; 9252

; ----------------------------------------------------------------------------
        jsr     LB5A7                           ; 9255
        bne     L9286                           ; 9258
        jsr     LB287                           ; 925A
        lda     $0C                             ; 925D
        cmp     #$02                            ; 925F
        bne     L926C                           ; 9261
        lda     #$64                            ; 9263
        jsr     LE096                           ; 9265
        inc     $0C                             ; 9268
        bne     L9286                           ; 926A
L926C:  inc     $0C                             ; 926C
        lda     #$00                            ; 926E
        sta     $06                             ; 9270
        sta     $07                             ; 9272
        sta     $04                             ; 9274
        sta     $02                             ; 9276
        sta     $00                             ; 9278
        lda     #$05                            ; 927A
        sta     $01                             ; 927C
        lda     #$06                            ; 927E
        sta     $03                             ; 9280
        lda     #$0A                            ; 9282
        sta     $1A                             ; 9284
L9286:  rts                                     ; 9286

; ----------------------------------------------------------------------------
        lda     #$14                            ; 9287
        jsr     LB4E8                           ; 9289
        lda     #$15                            ; 928C
        jsr     LB4E8                           ; 928E
        lda     #$16                            ; 9291
        jmp     LB4E8                           ; 9293

; ----------------------------------------------------------------------------
        inc     $03                             ; 9296
        lda     $03                             ; 9298
        cmp     #$31                            ; 929A
        bne     L92A0                           ; 929C
        dec     $03                             ; 929E
L92A0:  rts                                     ; 92A0

; ----------------------------------------------------------------------------
        dec     $03                             ; 92A1
        lda     $03                             ; 92A3
        cmp     #$2C                            ; 92A5
        bne     L92AB                           ; 92A7
        inc     $03                             ; 92A9
L92AB:  rts                                     ; 92AB

; ----------------------------------------------------------------------------
        lda     $01                             ; 92AC
        cmp     #$15                            ; 92AE
        bne     L92CA                           ; 92B0
        lda     $00                             ; 92B2
        cmp     #$01                            ; 92B4
        bne     L92BC                           ; 92B6
        jsr     LB12E                           ; 92B8
        rts                                     ; 92BB

; ----------------------------------------------------------------------------
L92BC:  cmp     #$02                            ; 92BC
        bne     L92CA                           ; 92BE
        lda     $04                             ; 92C0
        cmp     #$03                            ; 92C2
        beq     L92C9                           ; 92C4
        jsr     LB17D                           ; 92C6
L92C9:  rts                                     ; 92C9

; ----------------------------------------------------------------------------
L92CA:  jsr     LB01C                           ; 92CA
        jsr     LAFB1                           ; 92CD
        jsr     LB5FD                           ; 92D0
        cpx     #$03                            ; 92D3
        beq     L92E5                           ; 92D5
        inx                                     ; 92D7
        stx     $04                             ; 92D8
        txa                                     ; 92DA
        cmp     $05                             ; 92DB
        bcc     L92E1                           ; 92DD
        sta     $05                             ; 92DF
L92E1:  jsr     LB296                           ; 92E1
L92E4:  rts                                     ; 92E4

; ----------------------------------------------------------------------------
L92E5:  lda     $05                             ; 92E5
        cmp     #$04                            ; 92E7
        beq     L92E4                           ; 92E9
        inc     $05                             ; 92EB
        rts                                     ; 92ED

; ----------------------------------------------------------------------------
        lda     $04                             ; 92EE
        beq     L9300                           ; 92F0
        jsr     LB53A                           ; 92F2
        jsr     LB083                           ; 92F5
        dec     $04                             ; 92F8
        jsr     LB2A1                           ; 92FA
        jmp     LB126                           ; 92FD

; ----------------------------------------------------------------------------
L9300:  rts                                     ; 9300

; ----------------------------------------------------------------------------
        jsr     LE5AA                           ; 9301
        lda     #$00                            ; 9304
        jsr     LF7B1                           ; 9306
        jsr     LB567                           ; 9309
        ldx     #$04                            ; 930C
        lda     #$2C                            ; 930E
L9310:  sta     $0400,x                         ; 9310
        dex                                     ; 9313
        bpl     L9310                           ; 9314
        ldx     #$0F                            ; 9316
        lda     #$00                            ; 9318
L931A:  sta     $00,x                           ; 931A
        dex                                     ; 931C
        bpl     L931A                           ; 931D
        lda     #$2D                            ; 931F
        sta     $03                             ; 9321
        lda     #$05                            ; 9323
        jsr     LE992                           ; 9325
        jmp     LB1BE                           ; 9328

; ----------------------------------------------------------------------------
        jsr     LB083                           ; 932B
        jsr     LB0B1                           ; 932E
        jsr     LAF9C                           ; 9331
        lda     $C2                             ; 9334
        lsr     a                               ; 9336
        bcc     L933F                           ; 9337
        jsr     L99F6                           ; 9339
        jmp     LB2AC                           ; 933C

; ----------------------------------------------------------------------------
L933F:  lsr     a                               ; 933F
        bcc     L9345                           ; 9340
        jmp     LB2EE                           ; 9342

; ----------------------------------------------------------------------------
L9345:  lsr     a                               ; 9345
        lsr     a                               ; 9346
        bcc     L938E                           ; 9347
        jsr     L99F6                           ; 9349
        lda     $0400                           ; 934C
        cmp     #$2C                            ; 934F
        beq     L938E                           ; 9351
        ldy     #$04                            ; 9353
        lda     #$00                            ; 9355
L9357:  sta     $031D,y                         ; 9357
        dey                                     ; 935A
        bpl     L9357                           ; 935B
        tay                                     ; 935D
L935E:  lda     $0400,y                         ; 935E
        cmp     #$2C                            ; 9361
        beq     L936D                           ; 9363
        sta     $031E,y                         ; 9365
        iny                                     ; 9368
        cpy     #$04                            ; 9369
        bne     L935E                           ; 936B
L936D:  dey                                     ; 936D
        lda     $031E,y                         ; 936E
        ora     #$80                            ; 9371
        sta     $031E,y                         ; 9373
        lda     #$A0                            ; 9376
        sta     $10                             ; 9378
        lda     #$03                            ; 937A
        jsr     LE8C8                           ; 937C
        jsr     LB52C                           ; 937F
        lda     $1A                             ; 9382
        inc     $1A                             ; 9384
        cmp     #$0F                            ; 9386
        bcs     L938E                           ; 9388
        lda     #$08                            ; 938A
        sta     $1A                             ; 938C
L938E:  rts                                     ; 938E

; ----------------------------------------------------------------------------
        jsr     LAAB0                           ; 938F
        lda     $0F                             ; 9392
        bmi     L93A4                           ; 9394
        jsr     LB587                           ; 9396
        bne     L93A3                           ; 9399
        lda     #$51                            ; 939B
        sta     $0E                             ; 939D
        lda     #$FF                            ; 939F
        sta     $0F                             ; 93A1
L93A3:  rts                                     ; 93A3

; ----------------------------------------------------------------------------
L93A4:  dec     $0E                             ; 93A4
        bne     L93AD                           ; 93A6
        jsr     LB533                           ; 93A8
        inc     $1A                             ; 93AB
L93AD:  rts                                     ; 93AD

; ----------------------------------------------------------------------------
        jsr     LAAF6                           ; 93AE
        lda     $0F                             ; 93B1
        bmi     L93A4                           ; 93B3
        ora     $0E                             ; 93B5
        beq     L93C6                           ; 93B7
        jsr     LB587                           ; 93B9
        bne     L93C6                           ; 93BC
        lda     #$51                            ; 93BE
        sta     $0E                             ; 93C0
        lda     #$FF                            ; 93C2
        sta     $0F                             ; 93C4
L93C6:  rts                                     ; 93C6

; ----------------------------------------------------------------------------
        jsr     LABD3                           ; 93C7
        jmp     LB3B1                           ; 93CA

; ----------------------------------------------------------------------------
        lda     $0F                             ; 93CD
        bne     L93ED                           ; 93CF
        lda     #$04                            ; 93D1
        jsr     LB4DD                           ; 93D3
        jsr     LEA7E                           ; 93D6
        lda     #$60                            ; 93D9
        jsr     LE096                           ; 93DB
        lda     #$05                            ; 93DE
        jsr     LE992                           ; 93E0
        lda     #$08                            ; 93E3
        jsr     LB513                           ; 93E5
        inc     $0F                             ; 93E8
        jmp     LE5B2                           ; 93EA

; ----------------------------------------------------------------------------
L93ED:  lda     $18                             ; 93ED
        bne     L93F6                           ; 93EF
        jsr     LB533                           ; 93F1
        inc     $1A                             ; 93F4
L93F6:  rts                                     ; 93F6

; ----------------------------------------------------------------------------
        lda     $0F                             ; 93F7
        bne     L940B                           ; 93F9
        lda     $18                             ; 93FB
        bne     L9444                           ; 93FD
        lda     #$04                            ; 93FF
        jsr     LB547                           ; 9401
        inc     $0F                             ; 9404
        lda     #$00                            ; 9406
        sta     $0E                             ; 9408
        rts                                     ; 940A

; ----------------------------------------------------------------------------
L940B:  lda     $C2                             ; 940B
        and     #$30                            ; 940D
        beq     L9417                           ; 940F
        lda     $0E                             ; 9411
        eor     #$01                            ; 9413
        sta     $0E                             ; 9415
L9417:  ldx     $0162                           ; 9417
        ldy     #$00                            ; 941A
L941C:  lda     $0667,y                         ; 941C
        jsr     LB5E1                           ; 941F
        cpy     #$06                            ; 9422
        bne     L941C                           ; 9424
        jsr     LB4F1                           ; 9426
        dex                                     ; 9429
        lda     $0E                             ; 942A
        bne     L9430                           ; 942C
        dex                                     ; 942E
        dex                                     ; 942F
L9430:  lda     #$7A                            ; 9430
        sta     $0163,x                         ; 9432
        lda     $C2                             ; 9435
        and     #$0F                            ; 9437
        beq     L9444                           ; 9439
        lda     $0E                             ; 943B
        bne     L9445                           ; 943D
        jsr     LB52C                           ; 943F
        inc     $1A                             ; 9442
L9444:  rts                                     ; 9444

; ----------------------------------------------------------------------------
L9445:  ldy     #$01                            ; 9445
        jsr     LB45E                           ; 9447
        ldy     #$02                            ; 944A
        jsr     LB45E                           ; 944C
        ldy     #$03                            ; 944F
        jsr     LB45E                           ; 9451
        lda     #$0A                            ; 9454
        jsr     LB513                           ; 9456
        lda     #$00                            ; 9459
        sta     $0F                             ; 945B
        rts                                     ; 945D

; ----------------------------------------------------------------------------
        jsr     LB465                           ; 945E
        tya                                     ; 9461
        jsr     LB547                           ; 9462
L9465:  lda     $18                             ; 9465
        ora     $0163                           ; 9467
        bne     L9465                           ; 946A
        rts                                     ; 946C

; ----------------------------------------------------------------------------
        jsr     LB4B0                           ; 946D
        lda     #$01                            ; 9470
        jsr     LF7B1                           ; 9472
        lda     #$00                            ; 9475
        tax                                     ; 9477
L9478:  sta     $0600,x                         ; 9478
        sta     $0700,x                         ; 947B
        inx                                     ; 947E
        bne     L9478                           ; 947F
        lda     #$00                            ; 9481
        jsr     LBDE6                           ; 9483
        lda     #$80                            ; 9486
        sta     $0E                             ; 9488
        lda     #$80                            ; 948A
        sta     $0F                             ; 948C
        lda     #$49                            ; 948E
        jsr     LE992                           ; 9490
        lda     #$40                            ; 9493
        sta     $0A                             ; 9495
        lda     #$01                            ; 9497
        sta     $0B                             ; 9499
        jsr     LBE19                           ; 949B
        jsr     LB4AB                           ; 949E
        lda     #$20                            ; 94A1
        jsr     LE03F                           ; 94A3
        lda     #$0E                            ; 94A6
        sta     $1A                             ; 94A8
        rts                                     ; 94AA

; ----------------------------------------------------------------------------
        jsr     LE17B                           ; 94AB
        asl     $A904,x                         ; 94AE
        .byte   $03                             ; 94B1
        sta     $2F                             ; 94B2
L94B4:  lda     $2F                             ; 94B4
        bne     L94B4                           ; 94B6
        lda     #$05                            ; 94B8
        sta     $1A                             ; 94BA
L94BC:  lda     #$01                            ; 94BC
        sta     $2F                             ; 94BE
        jsr     LF067                           ; 94C0
        jsr     LF79E                           ; 94C3
L94C6:  lda     $2F                             ; 94C6
        bne     L94C6                           ; 94C8
        dec     $1A                             ; 94CA
        bne     L94BC                           ; 94CC
        jsr     LF785                           ; 94CE
        jsr     LE5AA                           ; 94D1
        jsr     LE2C6                           ; 94D4
        jsr     L9233                           ; 94D7
        jmp     LE031                           ; 94DA

; ----------------------------------------------------------------------------
        jsr     LE8C8                           ; 94DD
        jsr     LE5AA                           ; 94E0
        lda     #$81                            ; 94E3
        jmp     LE9EB                           ; 94E5

; ----------------------------------------------------------------------------
        jsr     LB547                           ; 94E8
        jsr     LE95B                           ; 94EB
        jmp     LE95B                           ; 94EE

; ----------------------------------------------------------------------------
        lda     #$00                            ; 94F1
        sta     $0163,x                         ; 94F3
        stx     $0162                           ; 94F6
        rts                                     ; 94F9

; ----------------------------------------------------------------------------
        sty     $3C                             ; 94FA
        asl     a                               ; 94FC
        tay                                     ; 94FD
        lda     $B5AB,y                         ; 94FE
        sta     $E8                             ; 9501
        lda     $B5AC,y                         ; 9503
        sta     $E9                             ; 9506
        lda     #$06                            ; 9508
        sta     $EA                             ; 950A
        lda     #$00                            ; 950C
        sta     $EB                             ; 950E
        ldy     $3C                             ; 9510
        rts                                     ; 9512

; ----------------------------------------------------------------------------
        sta     $EC                             ; 9513
        lda     #$08                            ; 9515
        sta     $EA                             ; 9517
        lda     #$00                            ; 9519
        sta     $EB                             ; 951B
        jmp     L9140                           ; 951D

; ----------------------------------------------------------------------------
        jsr     LB513                           ; 9520
        lda     #$84                            ; 9523
        sta     $0E                             ; 9525
        lda     #$01                            ; 9527
        sta     $0F                             ; 9529
        rts                                     ; 952B

; ----------------------------------------------------------------------------
        jsr     LE5AA                           ; 952C
        lda     #$03                            ; 952F
        sta     $18                             ; 9531
        lda     #$00                            ; 9533
        sta     $0E                             ; 9535
        sta     $0F                             ; 9537
        rts                                     ; 9539

; ----------------------------------------------------------------------------
        lda     #$00                            ; 953A
        sta     $1E                             ; 953C
        sta     $1F                             ; 953E
        rts                                     ; 9540

; ----------------------------------------------------------------------------
        ldx     $0162                           ; 9541
        ldy     #$00                            ; 9544
        rts                                     ; 9546

; ----------------------------------------------------------------------------
        jsr     LB4FA                           ; 9547
        lda     #$00                            ; 954A
        sta     $EC                             ; 954C
        lda     #$FF                            ; 954E
        sta     $18                             ; 9550
        rts                                     ; 9552

; ----------------------------------------------------------------------------
        sta     $04B0,x                         ; 9553
        inx                                     ; 9556
        iny                                     ; 9557
        dec     $09                             ; 9558
        rts                                     ; 955A

; ----------------------------------------------------------------------------
        jsr     LE096                           ; 955B
        jsr     LF07B                           ; 955E
        jsr     LE95B                           ; 9561
        jmp     LE5B2                           ; 9564

; ----------------------------------------------------------------------------
        lda     #$03                            ; 9567
        jsr     LB4DD                           ; 9569
        jsr     LEA7E                           ; 956C
        jsr     LAF6A                           ; 956F
        jmp     LAF91                           ; 9572

; ----------------------------------------------------------------------------
        lda     #$05                            ; 9575
        sta     $01                             ; 9577
        jsr     LAF9C                           ; 9579
        lda     #$28                            ; 957C
        sta     $0201                           ; 957E
        lda     #$00                            ; 9581
        sta     $0202                           ; 9583
        rts                                     ; 9586

; ----------------------------------------------------------------------------
        ldx     #$07                            ; 9587
L9589:  lda     $18                             ; 9589
        bne     L95A6                           ; 958B
        lda     $C2                             ; 958D
        and     #$03                            ; 958F
        beq     L9597                           ; 9591
        lda     #$00                            ; 9593
        beq     L95A0                           ; 9595
L9597:  lda     $1E                             ; 9597
        and     #$08                            ; 9599
        beq     L959E                           ; 959B
        inx                                     ; 959D
L959E:  lda     #$01                            ; 959E
L95A0:  pha                                     ; 95A0
        txa                                     ; 95A1
        jsr     LB547                           ; 95A2
        pla                                     ; 95A5
L95A6:  rts                                     ; 95A6

; ----------------------------------------------------------------------------
        ldx     #$09                            ; 95A7
        bne     L9589                           ; 95A9
        brk                                     ; 95AB
        brk                                     ; 95AC
        and     $4605,x                         ; 95AD
        ora     $4F                             ; 95B0
        ora     $5C                             ; 95B2
        ora     $00                             ; 95B4
        brk                                     ; 95B6
        brk                                     ; 95B7
        brk                                     ; 95B8
        and     #$05                            ; 95B9
        rol     $3305                           ; 95BB
        ora     $38                             ; 95BE
        ora     $00                             ; 95C0
        brk                                     ; 95C2
        rti                                     ; 95C3

; ----------------------------------------------------------------------------
        .byte   $04                             ; 95C4
        brk                                     ; 95C5
        brk                                     ; 95C6
        ora     ($05,x)                         ; 95C7
        php                                     ; 95C9
        ora     $95                             ; 95CA
        ora     $D4                             ; 95CC
        .byte   $04                             ; 95CE
        cpy     #$04                            ; 95CF
        brk                                     ; 95D1
        brk                                     ; 95D2
        .byte   $F2                             ; 95D3
        .byte   $04                             ; 95D4
        .byte   $F7                             ; 95D5
        .byte   $04                             ; 95D6
        .byte   $FC                             ; 95D7
        .byte   $04                             ; 95D8
        .byte   $DB                             ; 95D9
        ora     $9D                             ; 95DA
        .byte   $63                             ; 95DC
        ora     ($E8,x)                         ; 95DD
        dey                                     ; 95DF
        rts                                     ; 95E0

; ----------------------------------------------------------------------------
        sta     $0163,x                         ; 95E1
        inx                                     ; 95E4
        iny                                     ; 95E5
        rts                                     ; 95E6

; ----------------------------------------------------------------------------
        ldx     $0162                           ; 95E7
        lda     $0D                             ; 95EA
        sta     $0163,x                         ; 95EC
        inx                                     ; 95EF
        lda     $0E                             ; 95F0
        sta     $0163,x                         ; 95F2
        inx                                     ; 95F5
        lda     #$01                            ; 95F6
        sta     $0163,x                         ; 95F8
        inx                                     ; 95FB
        rts                                     ; 95FC

; ----------------------------------------------------------------------------
        jsr     LB5E7                           ; 95FD
        lda     $0F                             ; 9600
        sta     $0163,x                         ; 9602
        inx                                     ; 9605
        jsr     LB4F1                           ; 9606
        ldx     $04                             ; 9609
        lda     $0F                             ; 960B
        sta     $0400,x                         ; 960D
        rts                                     ; 9610

; ----------------------------------------------------------------------------
        lda     #$2C                            ; 9611
L9613:  jsr     LB5DB                           ; 9613
        bne     L9613                           ; 9616
        tya                                     ; 9618
        sta     $0163,x                         ; 9619
        txa                                     ; 961C
        ldx     $0162                           ; 961D
        sta     $0162                           ; 9620
        lda     $00                             ; 9623
        sta     $0163,x                         ; 9625
        inx                                     ; 9628
        lda     $01                             ; 9629
        sta     $0163,x                         ; 962B
        inx                                     ; 962E
        rts                                     ; 962F

; ----------------------------------------------------------------------------
        ldy     #$02                            ; 9630
L9632:  lda     $B63B,y                         ; 9632
        jsr     LB5DB                           ; 9635
        bpl     L9632                           ; 9638
        rts                                     ; 963A

; ----------------------------------------------------------------------------
        .byte   $33                             ; 963B
        lsr     $35                             ; 963C
        ldy     #$02                            ; 963E
L9640:  lda     $B649,y                         ; 9640
        jsr     LB5DB                           ; 9643
        bpl     L9640                           ; 9646
        rts                                     ; 9648

; ----------------------------------------------------------------------------
        .byte   $3B                             ; 9649
        .byte   $34                             ; 964A
        .byte   $33                             ; 964B
        lda     #$00                            ; 964C
        sta     $02                             ; 964E
L9650:  ldx     $0162                           ; 9650
        ldy     #$16                            ; 9653
        jsr     LB611                           ; 9655
        lda     #$13                            ; 9658
        sta     $0163,x                         ; 965A
        inx                                     ; 965D
        ldy     #$0A                            ; 965E
L9660:  lda     $02                             ; 9660
        jsr     LB98B                           ; 9662
        sta     $0163,x                         ; 9665
        inx                                     ; 9668
        inx                                     ; 9669
        inc     $02                             ; 966A
        dey                                     ; 966C
        beq     L9681                           ; 966D
        lda     $02                             ; 966F
        cmp     #$12                            ; 9671
        bne     L967A                           ; 9673
        jsr     LB63E                           ; 9675
        bmi     L9681                           ; 9678
L967A:  cmp     #$1A                            ; 967A
        bne     L9660                           ; 967C
        jsr     LB630                           ; 967E
L9681:  jsr     LE95B                           ; 9681
        clc                                     ; 9684
        lda     $01                             ; 9685
        adc     #$40                            ; 9687
        sta     $01                             ; 9689
        lda     $00                             ; 968B
        adc     #$00                            ; 968D
        sta     $00                             ; 968F
        lda     $02                             ; 9691
        cmp     #$24                            ; 9693
        bne     L9650                           ; 9695
        rts                                     ; 9697

; ----------------------------------------------------------------------------
        lda     $00                             ; 9698
        asl     a                               ; 969A
        asl     a                               ; 969B
        adc     $00                             ; 969C
        asl     a                               ; 969E
        cmp     #$14                            ; 969F
        bne     L96A5                           ; 96A1
        lda     #$12                            ; 96A3
L96A5:  cmp     #$1E                            ; 96A5
        bne     L96AB                           ; 96A7
        lda     #$1A                            ; 96A9
L96AB:  sta     $0F                             ; 96AB
        lda     $01                             ; 96AD
        sec                                     ; 96AF
        sbc     #$05                            ; 96B0
        lsr     a                               ; 96B2
        clc                                     ; 96B3
        adc     $0F                             ; 96B4
        jsr     LB98B                           ; 96B6
        sta     $0F                             ; 96B9
        rts                                     ; 96BB

; ----------------------------------------------------------------------------
        lda     #$00                            ; 96BC
        sta     $00                             ; 96BE
        sta     $06                             ; 96C0
L96C2:  jsr     LB8D1                           ; 96C2
        lda     $03                             ; 96C5
        beq     L96E6                           ; 96C7
        ldy     #$00                            ; 96C9
L96CB:  lda     ($01),y                         ; 96CB
        sta     $08                             ; 96CD
        lda     #$08                            ; 96CF
        sec                                     ; 96D1
        sbc     $03                             ; 96D2
        tax                                     ; 96D4
        beq     L96DC                           ; 96D5
L96D7:  asl     $08                             ; 96D7
        dex                                     ; 96D9
        bne     L96D7                           ; 96DA
L96DC:  jsr     LB8FD                           ; 96DC
        iny                                     ; 96DF
        cpy     $04                             ; 96E0
        bne     L96CB                           ; 96E2
        beq     L96C2                           ; 96E4
L96E6:  lda     #$00                            ; 96E6
        sta     $08                             ; 96E8
        lda     #$D8                            ; 96EA
        sec                                     ; 96EC
        sbc     $06                             ; 96ED
        sta     $03                             ; 96EF
        beq     L96F6                           ; 96F1
        jsr     LB8FD                           ; 96F3
L96F6:  lda     $82                             ; 96F6
        sta     $0460                           ; 96F8
        inc     $0460                           ; 96FB
        jsr     LB928                           ; 96FE
        ldy     #$02                            ; 9701
L9703:  lda     $0460,y                         ; 9703
        sta     $0440,y                         ; 9706
        dey                                     ; 9709
        bpl     L9703                           ; 970A
        rts                                     ; 970C

; ----------------------------------------------------------------------------
        ldx     #$00                            ; 970D
        stx     $0460                           ; 970F
        stx     $0461                           ; 9712
        stx     $0462                           ; 9715
        ldy     #$03                            ; 9718
L971A:  clc                                     ; 971A
        lda     $0440,x                         ; 971B
        beq     L9725                           ; 971E
        sta     $0460,y                         ; 9720
        iny                                     ; 9723
        sec                                     ; 9724
L9725:  jsr     LB91E                           ; 9725
        inx                                     ; 9728
        cpx     #$18                            ; 9729
        bne     L971A                           ; 972B
        tya                                     ; 972D
        ldx     #$FF                            ; 972E
        asl     a                               ; 9730
        asl     a                               ; 9731
        asl     a                               ; 9732
L9733:  inx                                     ; 9733
        sec                                     ; 9734
        sbc     #$05                            ; 9735
        bcs     L9733                           ; 9737
        adc     #$05                            ; 9739
        beq     L973E                           ; 973B
        inx                                     ; 973D
L973E:  stx     $01                             ; 973E
        inx                                     ; 9740
        inx                                     ; 9741
        stx     $00                             ; 9742
L9744:  lda     $0460,y                         ; 9744
        sta     $0440,y                         ; 9747
        dey                                     ; 974A
        bpl     L9744                           ; 974B
        rts                                     ; 974D

; ----------------------------------------------------------------------------
        lda     $B9BC                           ; 974E
        sta     $0400                           ; 9751
        lda     $82                             ; 9754
        sta     $0401                           ; 9756
        inc     $0401                           ; 9759
        lda     $E1                             ; 975C
        and     #$1F                            ; 975E
        sta     $02                             ; 9760
        jsr     LB98B                           ; 9762
        sta     $0402                           ; 9765
        ldy     #$03                            ; 9768
        lda     #$05                            ; 976A
        sta     $03                             ; 976C
        lda     $01                             ; 976E
        sta     $04                             ; 9770
L9772:  jsr     LB8FD                           ; 9772
        clc                                     ; 9775
        lda     $07                             ; 9776
        adc     $02                             ; 9778
        cmp     #$20                            ; 977A
        bcc     L9780                           ; 977C
        sbc     #$20                            ; 977E
L9780:  jsr     LB98B                           ; 9780
        sta     $0400,y                         ; 9783
        iny                                     ; 9786
        dec     $04                             ; 9787
        bne     L9772                           ; 9789
        rts                                     ; 978B

; ----------------------------------------------------------------------------
        ldx     #$00                            ; 978C
        stx     $3B                             ; 978E
L9790:  inc     $3B                             ; 9790
        lda     $B7CC,x                         ; 9792
        beq     L97C2                           ; 9795
        sta     $3D                             ; 9797
        inx                                     ; 9799
        ldy     #$00                            ; 979A
L979C:  lda     $B7CC,x                         ; 979C
        cmp     $0400,y                         ; 979F
        bne     L97C5                           ; 97A2
        inx                                     ; 97A4
        iny                                     ; 97A5
        dec     $3D                             ; 97A6
        bne     L979C                           ; 97A8
        cpy     $05                             ; 97AA
        bne     L97C2                           ; 97AC
        lda     $3B                             ; 97AE
        cmp     #$06                            ; 97B0
        bcc     L97BC                           ; 97B2
        bne     L97B9                           ; 97B4
        jmp     LBA25                           ; 97B6

; ----------------------------------------------------------------------------
L97B9:  jmp     LBA3C                           ; 97B9

; ----------------------------------------------------------------------------
L97BC:  jsr     LBAD1                           ; 97BC
        lda     #$01                            ; 97BF
        rts                                     ; 97C1

; ----------------------------------------------------------------------------
L97C2:  lda     #$00                            ; 97C2
        rts                                     ; 97C4

; ----------------------------------------------------------------------------
L97C5:  inx                                     ; 97C5
        dec     $3D                             ; 97C6
        bne     L97C5                           ; 97C8
        beq     L9790                           ; 97CA
        .byte   $02                             ; 97CC
        ora     ($46,x)                         ; 97CD
        .byte   $02                             ; 97CF
        .byte   $02                             ; 97D0
        lsr     $02                             ; 97D1
        .byte   $03                             ; 97D3
        lsr     $02                             ; 97D4
        .byte   $04                             ; 97D6
        lsr     $02                             ; 97D7
        ora     $46                             ; 97D9
        .byte   $03                             ; 97DB
        .byte   $34                             ; 97DC
        and     $0533,x                         ; 97DD
        .byte   $42                             ; 97E0
        rol     $3D44,x                         ; 97E1
        .byte   $33                             ; 97E4
        brk                                     ; 97E5
        lda     $0400                           ; 97E6
        cmp     $B9BC                           ; 97E9
        bne     L9843                           ; 97EC
        lda     $0401                           ; 97EE
        beq     L9843                           ; 97F1
        cmp     #$06                            ; 97F3
        bcs     L9843                           ; 97F5
        lda     $05                             ; 97F7
        cmp     #$08                            ; 97F9
        bcc     L9840                           ; 97FB
        lda     $0402                           ; 97FD
        jsr     LB994                           ; 9800
        sta     $02                             ; 9803
        lda     #$00                            ; 9805
        sta     $06                             ; 9807
        lda     #$05                            ; 9809
        sta     $03                             ; 980B
        ldx     #$03                            ; 980D
L980F:  lda     $0400,x                         ; 980F
        jsr     LB994                           ; 9812
        sec                                     ; 9815
        sbc     $02                             ; 9816
        bcs     L9820                           ; 9818
        adc     #$20                            ; 981A
        cmp     #$20                            ; 981C
        bcs     L9840                           ; 981E
L9820:  asl     a                               ; 9820
        asl     a                               ; 9821
        asl     a                               ; 9822
        sta     $08                             ; 9823
        jsr     LB8FD                           ; 9825
        inx                                     ; 9828
        cpx     $05                             ; 9829
        bne     L980F                           ; 982B
        lda     $06                             ; 982D
        cmp     #$F0                            ; 982F
        bcs     L9840                           ; 9831
        lda     #$F0                            ; 9833
        sec                                     ; 9835
        sbc     $06                             ; 9836
        sta     $03                             ; 9838
        jsr     LB8FD                           ; 983A
        lda     #$00                            ; 983D
        rts                                     ; 983F

; ----------------------------------------------------------------------------
L9840:  lda     #$01                            ; 9840
        rts                                     ; 9842

; ----------------------------------------------------------------------------
L9843:  lda     #$80                            ; 9843
        rts                                     ; 9845

; ----------------------------------------------------------------------------
        ldy     #$1B                            ; 9846
L9848:  lda     $0440,y                         ; 9848
        sta     $0460,y                         ; 984B
        dey                                     ; 984E
        bpl     L9848                           ; 984F
        ldx     #$03                            ; 9851
        ldy     #$00                            ; 9853
L9855:  clc                                     ; 9855
        lda     #$00                            ; 9856
        jsr     LB91E                           ; 9858
        bcc     L9861                           ; 985B
        lda     $0460,x                         ; 985D
        inx                                     ; 9860
L9861:  sta     $0440,y                         ; 9861
        iny                                     ; 9864
        cpy     #$18                            ; 9865
        bne     L9855                           ; 9867
        lda     $0401                           ; 9869
        sta     $0460                           ; 986C
        jsr     LB928                           ; 986F
        lda     $0460                           ; 9872
        ora     $0461                           ; 9875
        ora     $0462                           ; 9878
        beq     L98B3                           ; 987B
        ldy     #$02                            ; 987D
L987F:  lda     $0460,y                         ; 987F
        cmp     $0440,y                         ; 9882
        bne     L98B3                           ; 9885
        dey                                     ; 9887
        bpl     L987F                           ; 9888
        lda     #$18                            ; 988A
        sta     $03                             ; 988C
        jsr     LB8FD                           ; 988E
        ldy     #$00                            ; 9891
        sty     $00                             ; 9893
        sty     $06                             ; 9895
L9897:  jsr     LB8D1                           ; 9897
        lda     $03                             ; 989A
        beq     L98B6                           ; 989C
L989E:  jsr     LB8FD                           ; 989E
        lda     $0B                             ; 98A1
        cmp     $07                             ; 98A3
        bcc     L98B3                           ; 98A5
        lda     $07                             ; 98A7
        sta     $0180,y                         ; 98A9
        iny                                     ; 98AC
        dec     $04                             ; 98AD
        bne     L989E                           ; 98AF
        beq     L9897                           ; 98B1
L98B3:  lda     #$01                            ; 98B3
L98B5:  rts                                     ; 98B5

; ----------------------------------------------------------------------------
L98B6:  lda     #$00                            ; 98B6
        sta     $00                             ; 98B8
        tax                                     ; 98BA
L98BB:  jsr     LB8D1                           ; 98BB
        lda     $03                             ; 98BE
        beq     L98B5                           ; 98C0
        ldy     #$00                            ; 98C2
L98C4:  lda     $0180,x                         ; 98C4
        sta     ($01),y                         ; 98C7
        inx                                     ; 98C9
        iny                                     ; 98CA
        cpy     $04                             ; 98CB
        bne     L98C4                           ; 98CD
        beq     L98BB                           ; 98CF
        sty     $3C                             ; 98D1
        ldy     $00                             ; 98D3
        lda     $B9CA,y                         ; 98D5
        sta     $01                             ; 98D8
        iny                                     ; 98DA
        lda     $B9CA,y                         ; 98DB
        sta     $02                             ; 98DE
        iny                                     ; 98E0
        lda     $B9CA,y                         ; 98E1
        lsr     a                               ; 98E4
        lsr     a                               ; 98E5
        lsr     a                               ; 98E6
        lsr     a                               ; 98E7
        sta     $03                             ; 98E8
        lda     $B9CA,y                         ; 98EA
        and     #$0F                            ; 98ED
        sta     $04                             ; 98EF
        iny                                     ; 98F1
        lda     $B9CA,y                         ; 98F2
        sta     $0B                             ; 98F5
        iny                                     ; 98F7
        sty     $00                             ; 98F8
        ldy     $3C                             ; 98FA
        rts                                     ; 98FC

; ----------------------------------------------------------------------------
        stx     $3D                             ; 98FD
        sty     $3C                             ; 98FF
        lda     #$00                            ; 9901
        sta     $07                             ; 9903
        ldy     $03                             ; 9905
        lda     $08                             ; 9907
L9909:  ldx     #$1D                            ; 9909
        asl     a                               ; 990B
L990C:  rol     $0440,x                         ; 990C
        dex                                     ; 990F
        bpl     L990C                           ; 9910
        rol     $07                             ; 9912
        inc     $06                             ; 9914
        dey                                     ; 9916
        bne     L9909                           ; 9917
        ldx     $3D                             ; 9919
        ldy     $3C                             ; 991B
        rts                                     ; 991D

; ----------------------------------------------------------------------------
        rol     $0462                           ; 991E
        rol     $0461                           ; 9921
        rol     $0460                           ; 9924
        rts                                     ; 9927

; ----------------------------------------------------------------------------
        stx     $3D                             ; 9928
        lda     #$00                            ; 992A
        sta     $0461                           ; 992C
        sta     $0462                           ; 992F
        ldy     #$15                            ; 9932
L9934:  lda     #$00                            ; 9934
        ldx     #$03                            ; 9936
L9938:  sta     $0464,x                         ; 9938
        dex                                     ; 993B
        bpl     L9938                           ; 993C
        lda     $0442,y                         ; 993E
        sta     $0465                           ; 9941
        sty     $0463                           ; 9944
        ldx     #$05                            ; 9947
L9949:  lsr     $0463                           ; 9949
        bcc     L9961                           ; 994C
        clc                                     ; 994E
        lda     $0465                           ; 994F
        adc     $0467                           ; 9952
        sta     $0467                           ; 9955
        lda     $0464                           ; 9958
        adc     $0466                           ; 995B
        sta     $0466                           ; 995E
L9961:  asl     $0465                           ; 9961
        rol     $0464                           ; 9964
        dex                                     ; 9967
        bne     L9949                           ; 9968
        clc                                     ; 996A
        lda     $0462                           ; 996B
        adc     $0467                           ; 996E
        sta     $0462                           ; 9971
        lda     $0461                           ; 9974
        adc     $0466                           ; 9977
        sta     $0461                           ; 997A
        lda     $0460                           ; 997D
        adc     #$00                            ; 9980
        sta     $0460                           ; 9982
        dey                                     ; 9985
        bne     L9934                           ; 9986
        ldx     $3D                             ; 9988
        rts                                     ; 998A

; ----------------------------------------------------------------------------
        sty     $3C                             ; 998B
        tay                                     ; 998D
        lda     $B9A6,y                         ; 998E
        ldy     $3C                             ; 9991
        rts                                     ; 9993

; ----------------------------------------------------------------------------
        sty     $3C                             ; 9994
        ldy     #$FF                            ; 9996
L9998:  iny                                     ; 9998
        cpy     #$24                            ; 9999
        beq     L99A2                           ; 999B
        cmp     $B9A6,y                         ; 999D
        bne     L9998                           ; 99A0
L99A2:  tya                                     ; 99A2
        ldy     $3C                             ; 99A3
        rts                                     ; 99A5

; ----------------------------------------------------------------------------
        bmi     L99D9                           ; 99A6
        .byte   $32                             ; 99A8
        .byte   $33                             ; 99A9
        .byte   $34                             ; 99AA
        and     $36,x                           ; 99AB
        .byte   $37                             ; 99AD
        sec                                     ; 99AE
        and     $3B3A,y                         ; 99AF
        .byte   $3C                             ; 99B2
        and     $3F3E,x                         ; 99B3
        rti                                     ; 99B6

; ----------------------------------------------------------------------------
        eor     ($42,x)                         ; 99B7
        .byte   $43                             ; 99B9
        .byte   $44                             ; 99BA
        eor     $46                             ; 99BB
        .byte   $47                             ; 99BD
        pha                                     ; 99BE
        eor     #$01                            ; 99BF
        .byte   $02                             ; 99C1
        .byte   $03                             ; 99C2
        .byte   $04                             ; 99C3
        ora     $06                             ; 99C4
        .byte   $07                             ; 99C6
        php                                     ; 99C7
        ora     #$4F                            ; 99C8
        sta     $00                             ; 99CA
        .byte   $83                             ; 99CC
        .byte   $FF                             ; 99CD
        asl     L8403,x                         ; 99CE
        .byte   $FF                             ; 99D1
        .byte   $89                             ; 99D2
        brk                                     ; 99D3
        .byte   $43                             ; 99D4
        ora     #$11                            ; 99D5
        .byte   $03                             ; 99D7
        .byte   $41                             ; 99D8
L99D9:  .byte   $0F                             ; 99D9
        .byte   $92                             ; 99DA
        brk                                     ; 99DB
        and     ($02,x)                         ; 99DC
        asl     $3103                           ; 99DE
        asl     $12                             ; 99E1
        .byte   $03                             ; 99E3
        and     ($05),y                         ; 99E4
        brk                                     ; 99E6
        .byte   $03                             ; 99E7
        .byte   $42                             ; 99E8
        ora     #$02                            ; 99E9
        .byte   $03                             ; 99EB
        and     ($02,x)                         ; 99EC
        .byte   $0F                             ; 99EE
        .byte   $03                             ; 99EF
        .byte   $32                             ; 99F0
        ora     $06                             ; 99F1
        .byte   $03                             ; 99F3
        .byte   $42                             ; 99F4
        asl     a                               ; 99F5
L99F6:  sty     $00                             ; 99F6
        eor     ($18),y                         ; 99F8
        .byte   $03                             ; 99FA
        .byte   $03                             ; 99FB
        .byte   $13                             ; 99FC
        ora     ($0D,x)                         ; 99FD
        .byte   $03                             ; 99FF
        ora     ($01),y                         ; 9A00
        .byte   $22                             ; 9A02
        .byte   $03                             ; 9A03
        and     ($06),y                         ; 9A04
        dec     $03,x                           ; 9A06
        .byte   $42                             ; 9A08
        ora     #$D9                            ; 9A09
        .byte   $03                             ; 9A0B
        .byte   $43                             ; 9A0C
        ora     #$13                            ; 9A0D
        .byte   $03                             ; 9A0F
        .byte   $12                             ; 9A10
        ora     ($23,x)                         ; 9A11
        .byte   $03                             ; 9A13
        clc                                     ; 9A14
        ora     ($2D,x)                         ; 9A15
        .byte   $03                             ; 9A17
        ora     $01,x                           ; 9A18
        and     $03,x                           ; 9A1A
        .byte   $1B                             ; 9A1C
        ora     ($E0,x)                         ; 9A1D
        .byte   $03                             ; 9A1F
        ora     $01,x                           ; 9A20
        brk                                     ; 9A22
        brk                                     ; 9A23
        brk                                     ; 9A24
        lda     #$38                            ; 9A25
        sta     $031E                           ; 9A27
        lda     #$42                            ; 9A2A
        sta     $031F                           ; 9A2C
        lda     #$35                            ; 9A2F
        sta     $0320                           ; 9A31
        lda     #$B0                            ; 9A34
        sta     $0321                           ; 9A36
        jmp     LBC7F                           ; 9A39

; ----------------------------------------------------------------------------
        lda     #$00                            ; 9A3C
        sta     $00                             ; 9A3E
        lda     #$FF                            ; 9A40
        jsr     LE992                           ; 9A42
L9A45:  jsr     LE95B                           ; 9A45
        lda     $C2                             ; 9A48
        and     #$08                            ; 9A4A
        beq     L9A63                           ; 9A4C
        lda     #$FF                            ; 9A4E
        jsr     LE992                           ; 9A50
        lda     #$04                            ; 9A53
        sta     $2F                             ; 9A55
L9A57:  lda     $2F                             ; 9A57
        bne     L9A57                           ; 9A59
        ldy     $00                             ; 9A5B
        lda     $BAAE,y                         ; 9A5D
        jmp     LBA42                           ; 9A60

; ----------------------------------------------------------------------------
L9A63:  lda     $1E                             ; 9A63
        and     #$07                            ; 9A65
        bne     L9A45                           ; 9A67
        lda     $C0                             ; 9A69
        and     #$50                            ; 9A6B
        beq     L9A7C                           ; 9A6D
        inc     $00                             ; 9A6F
        ldy     $00                             ; 9A71
        lda     $BAAE,y                         ; 9A73
        bne     L9A7C                           ; 9A76
        lda     #$00                            ; 9A78
        sta     $00                             ; 9A7A
L9A7C:  lda     $C0                             ; 9A7C
        and     #$A0                            ; 9A7E
        beq     L9A88                           ; 9A80
        dec     $00                             ; 9A82
        bpl     L9A88                           ; 9A84
        inc     $00                             ; 9A86
L9A88:  lda     #$FF                            ; 9A88
        sta     $0165                           ; 9A8A
        lda     $00                             ; 9A8D
        sec                                     ; 9A8F
L9A90:  inc     $0165                           ; 9A90
        sbc     #$0A                            ; 9A93
        bcs     L9A90                           ; 9A95
        adc     #$0A                            ; 9A97
        sta     $0166                           ; 9A99
        lda     #$00                            ; 9A9C
        sta     $0167                           ; 9A9E
        lda     #$02                            ; 9AA1
        sta     $0164                           ; 9AA3
        lda     #$CA                            ; 9AA6
        sta     $0163                           ; 9AA8
        jmp     LBA45                           ; 9AAB

; ----------------------------------------------------------------------------
        ora     $5F                             ; 9AAE
        rts                                     ; 9AB0

; ----------------------------------------------------------------------------
        .byte   $53                             ; 9AB1
        bvc     L9AFC                           ; 9AB2
        eor     #$5C                            ; 9AB4
        and     $2A4E,x                         ; 9AB6
        .byte   $62                             ; 9AB9
        adc     $5A65,y                         ; 9ABA
        .byte   $7A                             ; 9ABD
        ora     $7C5B                           ; 9ABE
        rol     $555D,x                         ; 9AC1
        .byte   $54                             ; 9AC4
        .byte   $4B                             ; 9AC5
        and     $5E                             ; 9AC6
        .byte   $52                             ; 9AC8
        .byte   $57                             ; 9AC9
        eor     $6864,y                         ; 9ACA
        .byte   $63                             ; 9ACD
        brk                                     ; 9ACE
        brk                                     ; 9ACF
        brk                                     ; 9AD0
        ldy     $3B                             ; 9AD1
        dey                                     ; 9AD3
        bmi     L9B11                           ; 9AD4
        sty     $82                             ; 9AD6
        lda     #$1F                            ; 9AD8
        sta     $00                             ; 9ADA
        lda     #$BB                            ; 9ADC
        sta     $01                             ; 9ADE
        ldx     $82                             ; 9AE0
        ldy     #$00                            ; 9AE2
L9AE4:  lda     ($00),y                         ; 9AE4
        sta     $02,y                           ; 9AE6
        iny                                     ; 9AE9
        cpy     #$07                            ; 9AEA
        bne     L9AE4                           ; 9AEC
        clc                                     ; 9AEE
        tya                                     ; 9AEF
        adc     $00                             ; 9AF0
        sta     $00                             ; 9AF2
        lda     $01                             ; 9AF4
        adc     #$00                            ; 9AF6
        sta     $01                             ; 9AF8
        lda     $02                             ; 9AFA
L9AFC:  cmp     #$FF                            ; 9AFC
        bne     L9B16                           ; 9AFE
        lda     $82                             ; 9B00
        asl     a                               ; 9B02
        tay                                     ; 9B03
        lda     $F71A,y                         ; 9B04
        sta     $00                             ; 9B07
        lda     $F71B,y                         ; 9B09
        sta     $01                             ; 9B0C
        jsr     LEC46                           ; 9B0E
L9B11:  lda     #$80                            ; 9B11
        sta     $0C                             ; 9B13
        rts                                     ; 9B15

; ----------------------------------------------------------------------------
L9B16:  ldy     #$00                            ; 9B16
        lda     $04,x                           ; 9B18
        sta     ($02),y                         ; 9B1A
        jmp     LBAE2                           ; 9B1C

; ----------------------------------------------------------------------------
        sty     $00                             ; 9B1F
        .byte   $04                             ; 9B21
        ora     #$0E                            ; 9B22
        .byte   $13                             ; 9B24
        clc                                     ; 9B25
        .byte   $87                             ; 9B26
        brk                                     ; 9B27
        .byte   $3F                             ; 9B28
        .byte   $17                             ; 9B29
        .byte   $37                             ; 9B2A
        .byte   $37                             ; 9B2B
        .byte   $07                             ; 9B2C
        .byte   $89                             ; 9B2D
        brk                                     ; 9B2E
        ora     ($02,x)                         ; 9B2F
        .byte   $03                             ; 9B31
        .byte   $04                             ; 9B32
        ora     $00                             ; 9B33
        .byte   $03                             ; 9B35
        .byte   $03                             ; 9B36
        .byte   $04                             ; 9B37
        ora     $06                             ; 9B38
        .byte   $07                             ; 9B3A
        ora     ($03,x)                         ; 9B3B
        .byte   $03                             ; 9B3D
        .byte   $04                             ; 9B3E
        ora     $06                             ; 9B3F
        .byte   $07                             ; 9B41
        .byte   $02                             ; 9B42
        .byte   $03                             ; 9B43
        brk                                     ; 9B44
        brk                                     ; 9B45
        ora     ($01,x)                         ; 9B46
        .byte   $02                             ; 9B48
        .byte   $03                             ; 9B49
        .byte   $03                             ; 9B4A
        brk                                     ; 9B4B
        brk                                     ; 9B4C
        brk                                     ; 9B4D
        ora     ($01,x)                         ; 9B4E
        .byte   $04                             ; 9B50
        .byte   $03                             ; 9B51
        brk                                     ; 9B52
        ora     ($01,x)                         ; 9B53
        ora     ($01,x)                         ; 9B55
        ora     $03                             ; 9B57
        ora     ($01,x)                         ; 9B59
        ora     ($01,x)                         ; 9B5B
        ora     ($06,x)                         ; 9B5D
        .byte   $03                             ; 9B5F
        asl     $07                             ; 9B60
        php                                     ; 9B62
        ora     #$0A                            ; 9B63
        .byte   $07                             ; 9B65
        .byte   $03                             ; 9B66
        asl     $07                             ; 9B67
        php                                     ; 9B69
        ora     #$0A                            ; 9B6A
        ora     $0103                           ; 9B6C
        ora     ($01,x)                         ; 9B6F
        ora     ($01,x)                         ; 9B71
        asl     $0203                           ; 9B73
        .byte   $03                             ; 9B76
        .byte   $04                             ; 9B77
        ora     $06                             ; 9B78
        .byte   $0F                             ; 9B7A
        .byte   $03                             ; 9B7B
        .byte   $02                             ; 9B7C
        .byte   $02                             ; 9B7D
        .byte   $03                             ; 9B7E
        .byte   $04                             ; 9B7F
        ora     $10                             ; 9B80
        .byte   $03                             ; 9B82
        .byte   $02                             ; 9B83
        .byte   $02                             ; 9B84
        .byte   $03                             ; 9B85
        .byte   $04                             ; 9B86
        ora     $11                             ; 9B87
        .byte   $03                             ; 9B89
        asl     $07                             ; 9B8A
        php                                     ; 9B8C
        ora     #$0A                            ; 9B8D
        .byte   $12                             ; 9B8F
        .byte   $03                             ; 9B90
        .byte   $03                             ; 9B91
        .byte   $03                             ; 9B92
        .byte   $03                             ; 9B93
        .byte   $03                             ; 9B94
        .byte   $03                             ; 9B95
        .byte   $13                             ; 9B96
        .byte   $03                             ; 9B97
        ora     ($01,x)                         ; 9B98
        ora     ($01,x)                         ; 9B9A
        ora     ($14,x)                         ; 9B9C
        .byte   $03                             ; 9B9E
        ora     ($01,x)                         ; 9B9F
        ora     ($01,x)                         ; 9BA1
        ora     ($22,x)                         ; 9BA3
        .byte   $03                             ; 9BA5
        .byte   $02                             ; 9BA6
        .byte   $03                             ; 9BA7
        .byte   $04                             ; 9BA8
        ora     $06                             ; 9BA9
        .byte   $23                             ; 9BAB
        .byte   $03                             ; 9BAC
        ora     ($01,x)                         ; 9BAD
        ora     ($01,x)                         ; 9BAF
        ora     ($24,x)                         ; 9BB1
        .byte   $03                             ; 9BB3
        brk                                     ; 9BB4
        brk                                     ; 9BB5
        ora     ($01,x)                         ; 9BB6
        ora     ($25,x)                         ; 9BB8
        .byte   $03                             ; 9BBA
        brk                                     ; 9BBB
        brk                                     ; 9BBC
        brk                                     ; 9BBD
        ora     ($01,x)                         ; 9BBE
        rol     $03                             ; 9BC0
        brk                                     ; 9BC2
        ora     ($01,x)                         ; 9BC3
        ora     ($01,x)                         ; 9BC5
        .byte   $27                             ; 9BC7
        .byte   $03                             ; 9BC8
        brk                                     ; 9BC9
        brk                                     ; 9BCA
        ora     ($01,x)                         ; 9BCB
        ora     ($28,x)                         ; 9BCD
        .byte   $03                             ; 9BCF
        brk                                     ; 9BD0
        brk                                     ; 9BD1
        brk                                     ; 9BD2
        brk                                     ; 9BD3
        ora     ($29,x)                         ; 9BD4
        .byte   $03                             ; 9BD6
        ora     ($01,x)                         ; 9BD7
        ora     ($01,x)                         ; 9BD9
        ora     ($2A,x)                         ; 9BDB
        .byte   $03                             ; 9BDD
        brk                                     ; 9BDE
        brk                                     ; 9BDF
        brk                                     ; 9BE0
        brk                                     ; 9BE1
        ora     ($2D,x)                         ; 9BE2
        .byte   $03                             ; 9BE4
        brk                                     ; 9BE5
        ora     ($01,x)                         ; 9BE6
        ora     ($01,x)                         ; 9BE8
        rol     a:$03                           ; 9BEA
        brk                                     ; 9BED
        ora     ($01,x)                         ; 9BEE
        ora     ($2F,x)                         ; 9BF0
        .byte   $03                             ; 9BF2
        brk                                     ; 9BF3
        brk                                     ; 9BF4
        brk                                     ; 9BF5
        ora     ($01,x)                         ; 9BF6
        bmi     L9BFD                           ; 9BF8
        ora     ($01,x)                         ; 9BFA
        .byte   $01                             ; 9BFC
L9BFD:  ora     ($01,x)                         ; 9BFD
        and     ($03),y                         ; 9BFF
        brk                                     ; 9C01
        brk                                     ; 9C02
        ora     ($01,x)                         ; 9C03
        ora     ($36,x)                         ; 9C05
        .byte   $03                             ; 9C07
        brk                                     ; 9C08
        ora     ($01,x)                         ; 9C09
        ora     ($01,x)                         ; 9C0B
        .byte   $37                             ; 9C0D
        .byte   $03                             ; 9C0E
        brk                                     ; 9C0F
        ora     ($01,x)                         ; 9C10
        ora     ($01,x)                         ; 9C12
        sec                                     ; 9C14
        .byte   $03                             ; 9C15
        brk                                     ; 9C16
        brk                                     ; 9C17
        ora     ($01,x)                         ; 9C18
        ora     ($39,x)                         ; 9C1A
        .byte   $03                             ; 9C1C
        brk                                     ; 9C1D
        brk                                     ; 9C1E
        brk                                     ; 9C1F
        ora     ($01,x)                         ; 9C20
        .byte   $3A                             ; 9C22
        .byte   $03                             ; 9C23
        brk                                     ; 9C24
        brk                                     ; 9C25
        ora     ($01,x)                         ; 9C26
        ora     ($3B,x)                         ; 9C28
        .byte   $03                             ; 9C2A
        brk                                     ; 9C2B
        ora     ($01,x)                         ; 9C2C
        ora     ($01,x)                         ; 9C2E
        .byte   $3C                             ; 9C30
        .byte   $03                             ; 9C31
        brk                                     ; 9C32
        brk                                     ; 9C33
        brk                                     ; 9C34
        ora     ($01,x)                         ; 9C35
        and     $0103,x                         ; 9C37
        ora     ($01,x)                         ; 9C3A
        ora     ($01,x)                         ; 9C3C
        rol     $0103,x                         ; 9C3E
        ora     ($01,x)                         ; 9C41
        ora     ($01,x)                         ; 9C43
        .byte   $3F                             ; 9C45
        .byte   $03                             ; 9C46
        brk                                     ; 9C47
        brk                                     ; 9C48
        brk                                     ; 9C49
        brk                                     ; 9C4A
        ora     ($D6,x)                         ; 9C4B
        .byte   $03                             ; 9C4D
        ora     ($02,x)                         ; 9C4E
        .byte   $03                             ; 9C50
        .byte   $04                             ; 9C51
        ora     $D7                             ; 9C52
        .byte   $03                             ; 9C54
        ora     $05                             ; 9C55
        ora     $05                             ; 9C57
        ora     $E0                             ; 9C59
        .byte   $03                             ; 9C5B
        brk                                     ; 9C5C
        brk                                     ; 9C5D
        brk                                     ; 9C5E
        brk                                     ; 9C5F
        ora     ($E1,x)                         ; 9C60
        .byte   $03                             ; 9C62
        ora     ($01,x)                         ; 9C63
        ora     ($01,x)                         ; 9C65
        ora     ($E2,x)                         ; 9C67
        .byte   $03                             ; 9C69
        brk                                     ; 9C6A
L9C6B:  brk                                     ; 9C6B
        brk                                     ; 9C6C
        ora     ($01,x)                         ; 9C6D
        .byte   $E3                             ; 9C6F
        .byte   $03                             ; 9C70
        brk                                     ; 9C71
L9C72:  ora     ($01,x)                         ; 9C72
        ora     ($01,x)                         ; 9C74
        cpx     $03                             ; 9C76
        brk                                     ; 9C78
        brk                                     ; 9C79
        ora     ($01,x)                         ; 9C7A
        ora     ($FF,x)                         ; 9C7C
        .byte   $FF                             ; 9C7E
        jsr     LE5AA                           ; 9C7F
        lda     #$01                            ; 9C82
        jsr     LF7B1                           ; 9C84
        lda     #$00                            ; 9C87
        sta     $031C                           ; 9C89
        ldx     #$00                            ; 9C8C
L9C8E:  sta     $0600,x                         ; 9C8E
        sta     $0700,x                         ; 9C91
        inx                                     ; 9C94
        bne     L9C8E                           ; 9C95
        lda     #$01                            ; 9C97
        sta     $1A                             ; 9C99
        jsr     LE95B                           ; 9C9B
        lda     $1A                             ; 9C9E
        jsr     LBCA6                           ; 9CA0
        jmp     LBC9B                           ; 9CA3

; ----------------------------------------------------------------------------
        jsr     LE97D                           ; 9CA6
        brk                                     ; 9CA9
        brk                                     ; 9CAA
        cmp     ($BC,x)                         ; 9CAB
        bne     L9C6B                           ; 9CAD
        .byte   $DB                             ; 9CAF
        ldy     $BCFF,x                         ; 9CB0
        bmi     L9C72                           ; 9CB3
        lsr     a                               ; 9CB5
        lda     $BD54,x                         ; 9CB6
        adc     L83BD,y                         ; 9CB9
        lda     $BE3E,x                         ; 9CBC
        .byte   $53                             ; 9CBF
        ldx     $63A9,y                         ; 9CC0
        jsr     LE992                           ; 9CC3
        lda     #$00                            ; 9CC6
        jsr     LBFE5                           ; 9CC8
        lda     #$02                            ; 9CCB
L9CCD:  sta     $1A                             ; 9CCD
        rts                                     ; 9CCF

; ----------------------------------------------------------------------------
        lda     #$06                            ; 9CD0
        sta     $82                             ; 9CD2
        jsr     LBFDA                           ; 9CD4
        lda     #$03                            ; 9CD7
        bne     L9CCD                           ; 9CD9
        lda     #$00                            ; 9CDB
        jsr     LBDE6                           ; 9CDD
        lda     #$80                            ; 9CE0
        sta     $0E                             ; 9CE2
        lda     #$10                            ; 9CE4
        sta     $0F                             ; 9CE6
        lda     #$49                            ; 9CE8
        jsr     LE992                           ; 9CEA
        jsr     LBDF8                           ; 9CED
        lda     #$40                            ; 9CF0
        sta     $0A                             ; 9CF2
        jsr     LBE19                           ; 9CF4
        jsr     LE89D                           ; 9CF7
        lda     #$04                            ; 9CFA
        sta     $1A                             ; 9CFC
        rts                                     ; 9CFE

; ----------------------------------------------------------------------------
        lda     #$08                            ; 9CFF
        jsr     LBDE6                           ; 9D01
        lda     #$A8                            ; 9D04
        sta     $0E                             ; 9D06
        lda     #$80                            ; 9D08
        sta     $0F                             ; 9D0A
        lda     #$01                            ; 9D0C
        sta     $0B                             ; 9D0E
        jsr     LBD8E                           ; 9D10
        jsr     LBDD5                           ; 9D13
        lda     #$64                            ; 9D16
        jsr     LE992                           ; 9D18
        lda     #$1E                            ; 9D1B
        sta     $00                             ; 9D1D
        lda     #$05                            ; 9D1F
        sta     $01                             ; 9D21
L9D23:  .byte   $20                             ; 9D23
L9D24:  lda     $F0,x                           ; 9D24
        dec     $00                             ; 9D26
        bne     L9D23                           ; 9D28
        dec     $01                             ; 9D2A
        bpl     L9D23                           ; 9D2C
        .byte   $E6                             ; 9D2E
L9D2F:  .byte   $1A                             ; 9D2F
        lda     #$68                            ; 9D30
        jsr     LE992                           ; 9D32
        lda     #$80                            ; 9D35
        sta     $0A                             ; 9D37
        jsr     LBE19                           ; 9D39
        lda     #$3C                            ; 9D3C
        sta     $00                             ; 9D3E
L9D40:  jsr     LF0B5                           ; 9D40
        dec     $00                             ; 9D43
        bne     L9D40                           ; 9D45
        inc     $1A                             ; 9D47
        rts                                     ; 9D49

; ----------------------------------------------------------------------------
        lda     #$01                            ; 9D4A
        jsr     LBFE5                           ; 9D4C
        lda     #$07                            ; 9D4F
        sta     $1A                             ; 9D51
        rts                                     ; 9D53

; ----------------------------------------------------------------------------
        lda     #$08                            ; 9D54
        jsr     LBDE6                           ; 9D56
        lda     #$80                            ; 9D59
        sta     $0E                             ; 9D5B
        lda     #$80                            ; 9D5D
        sta     $0F                             ; 9D5F
        lda     #$01                            ; 9D61
        sta     $0B                             ; 9D63
        jsr     LBD8E                           ; 9D65
        jsr     LBDD5                           ; 9D68
        lda     #$60                            ; 9D6B
        sta     $0A                             ; 9D6D
        jsr     LBE19                           ; 9D6F
        lda     #$3C                            ; 9D72
        sta     $00                             ; 9D74
        jmp     LBD40                           ; 9D76

; ----------------------------------------------------------------------------
        lda     #$02                            ; 9D79
        jsr     LBFE5                           ; 9D7B
        lda     #$09                            ; 9D7E
L9D80:  sta     $1A                             ; 9D80
        rts                                     ; 9D82

; ----------------------------------------------------------------------------
        lda     #$08                            ; 9D83
        sta     $82                             ; 9D85
        jsr     LBFDA                           ; 9D87
        lda     #$0A                            ; 9D8A
        bne     L9D80                           ; 9D8C
        lda     #$C0                            ; 9D8E
        sta     $00                             ; 9D90
        lda     #$04                            ; 9D92
        sta     $01                             ; 9D94
        lda     $0B                             ; 9D96
        lsr     a                               ; 9D98
        bcc     L9DA3                           ; 9D99
        lda     #$E0                            ; 9D9B
        sta     $00                             ; 9D9D
        lda     #$04                            ; 9D9F
        sta     $01                             ; 9DA1
L9DA3:  ldy     #$00                            ; 9DA3
        ldx     #$10                            ; 9DA5
        lda     $0C                             ; 9DA7
        lsr     a                               ; 9DA9
        bcc     L9DAE                           ; 9DAA
        ldy     #$10                            ; 9DAC
L9DAE:  clc                                     ; 9DAE
        lda     ($00),y                         ; 9DAF
        adc     $0F                             ; 9DB1
        sta     $0203,x                         ; 9DB3
        inx                                     ; 9DB6
        iny                                     ; 9DB7
        lda     ($00),y                         ; 9DB8
        sta     $0201,x                         ; 9DBA
        inx                                     ; 9DBD
        iny                                     ; 9DBE
        lda     ($00),y                         ; 9DBF
        sta     $01FF,x                         ; 9DC1
        inx                                     ; 9DC4
        iny                                     ; 9DC5
        clc                                     ; 9DC6
        lda     ($00),y                         ; 9DC7
        adc     $0E                             ; 9DC9
        sta     $01FD,x                         ; 9DCB
        inx                                     ; 9DCE
        iny                                     ; 9DCF
        cpx     #$20                            ; 9DD0
        bne     L9DAE                           ; 9DD2
        rts                                     ; 9DD4

; ----------------------------------------------------------------------------
        ldx     #$20                            ; 9DD5
        ldy     #$00                            ; 9DD7
L9DD9:  lda     $0500,y                         ; 9DD9
        sta     $0200,x                         ; 9DDC
        inx                                     ; 9DDF
        iny                                     ; 9DE0
        cpy     #$90                            ; 9DE1
        bne     L9DD9                           ; 9DE3
        rts                                     ; 9DE5

; ----------------------------------------------------------------------------
        pha                                     ; 9DE6
        jsr     LE5AA                           ; 9DE7
        pla                                     ; 9DEA
        jsr     LBF9B                           ; 9DEB
        lda     #$00                            ; 9DEE
        ldx     #$0F                            ; 9DF0
L9DF2:  sta     $00,x                           ; 9DF2
        dex                                     ; 9DF4
        bpl     L9DF2                           ; 9DF5
        rts                                     ; 9DF7

; ----------------------------------------------------------------------------
        ldx     #$00                            ; 9DF8
        stx     $0D                             ; 9DFA
        inx                                     ; 9DFC
        stx     $0C                             ; 9DFD
L9DFF:  jsr     LBFED                           ; 9DFF
        clc                                     ; 9E02
        lda     $0F                             ; 9E03
        adc     #$04                            ; 9E05
        sta     $0F                             ; 9E07
        jsr     LBD8E                           ; 9E09
        inc     $0C                             ; 9E0C
        lda     $0F                             ; 9E0E
        cmp     #$80                            ; 9E10
        bcc     L9DFF                           ; 9E12
        lda     #$80                            ; 9E14
        sta     $0F                             ; 9E16
        rts                                     ; 9E18

; ----------------------------------------------------------------------------
        lda     #$01                            ; 9E19
        sta     $0B                             ; 9E1B
        lda     #$00                            ; 9E1D
        sta     $0C                             ; 9E1F
        sta     $0D                             ; 9E21
        jsr     LBD8E                           ; 9E23
L9E26:  jsr     LBFED                           ; 9E26
        sec                                     ; 9E29
        lda     $0E                             ; 9E2A
        sbc     #$04                            ; 9E2C
        sta     $0E                             ; 9E2E
        jsr     LBD8E                           ; 9E30
        inc     $0C                             ; 9E33
        lda     $0A                             ; 9E35
        cmp     $0E                             ; 9E37
        bcc     L9E26                           ; 9E39
        sta     $0E                             ; 9E3B
        rts                                     ; 9E3D

; ----------------------------------------------------------------------------
        lda     #$02                            ; 9E3E
        jsr     LF7B1                           ; 9E40
        lda     #$B4                            ; 9E43
        sta     $00                             ; 9E45
L9E47:  jsr     LE95B                           ; 9E47
        dec     $00                             ; 9E4A
        bne     L9E47                           ; 9E4C
        lda     #$0B                            ; 9E4E
        sta     $1A                             ; 9E50
        rts                                     ; 9E52

; ----------------------------------------------------------------------------
        jsr     LBE8A                           ; 9E53
L9E56:  jsr     LBFD1                           ; 9E56
        lda     $1E                             ; 9E59
        and     #$03                            ; 9E5B
        bne     L9E56                           ; 9E5D
        inc     $14                             ; 9E5F
        lda     $14                             ; 9E61
        cmp     #$F0                            ; 9E63
        bcc     L9E6B                           ; 9E65
        adc     #$0F                            ; 9E67
        sta     $14                             ; 9E69
L9E6B:  and     #$07                            ; 9E6B
        bne     L9E56                           ; 9E6D
        jsr     LBF30                           ; 9E6F
        dec     $0D                             ; 9E72
        bne     L9E56                           ; 9E74
        ldy     #$00                            ; 9E76
        lda     ($0E),y                         ; 9E78
        cmp     #$FF                            ; 9E7A
        beq     L9E84                           ; 9E7C
        jsr     LBF51                           ; 9E7E
        jmp     LBE56                           ; 9E81

; ----------------------------------------------------------------------------
L9E84:  jsr     LBFD1                           ; 9E84
        jmp     LBE84                           ; 9E87

; ----------------------------------------------------------------------------
        jsr     LE5AA                           ; 9E8A
        lda     #$00                            ; 9E8D
        jsr     LE8C8                           ; 9E8F
        lda     #$00                            ; 9E92
        ldx     #$0F                            ; 9E94
L9E96:  sta     $00,x                           ; 9E96
        dex                                     ; 9E98
        bpl     L9E96                           ; 9E99
        lda     #$05                            ; 9E9B
        jsr     LE9EB                           ; 9E9D
        jsr     LA935                           ; 9EA0
        lda     #$A0                            ; 9EA3
        sta     $0E                             ; 9EA5
        lda     #$05                            ; 9EA7
        sta     $0F                             ; 9EA9
        lda     #$01                            ; 9EAB
        sta     $0D                             ; 9EAD
        lda     #$00                            ; 9EAF
        sta     $BC                             ; 9EB1
        ldy     #$00                            ; 9EB3
        sty     $BD                             ; 9EB5
        jsr     LE080                           ; 9EB7
        lda     #$05                            ; 9EBA
        sta     $1A                             ; 9EBC
        lda     #$03                            ; 9EBE
        sta     $18                             ; 9EC0
        jsr     LB561                           ; 9EC2
L9EC5:  lda     #$01                            ; 9EC5
        sta     $2F                             ; 9EC7
        sec                                     ; 9EC9
        lda     $1A                             ; 9ECA
        sbc     #$02                            ; 9ECC
        bmi     L9F03                           ; 9ECE
        asl     a                               ; 9ED0
        asl     a                               ; 9ED1
        asl     a                               ; 9ED2
        asl     a                               ; 9ED3
        sta     $00                             ; 9ED4
        ldy     #$00                            ; 9ED6
        ldx     $0162                           ; 9ED8
        lda     #$3F                            ; 9EDB
        sta     $0163,x                         ; 9EDD
        inx                                     ; 9EE0
        lda     #$00                            ; 9EE1
        sta     $0163,x                         ; 9EE3
        inx                                     ; 9EE6
        lda     #$20                            ; 9EE7
        sta     $0163,x                         ; 9EE9
        inx                                     ; 9EEC
L9EED:  lda     $04A0,y                         ; 9EED
        sec                                     ; 9EF0
        sbc     $00                             ; 9EF1
        beq     L9EF9                           ; 9EF3
        bcs     L9EF9                           ; 9EF5
        lda     #$0F                            ; 9EF7
L9EF9:  jsr     LB5E1                           ; 9EF9
        cpy     #$20                            ; 9EFC
        bne     L9EED                           ; 9EFE
        jsr     LB4F1                           ; 9F00
L9F03:  jsr     LE95B                           ; 9F03
        lda     $2F                             ; 9F06
        bne     L9F03                           ; 9F08
        dec     $1A                             ; 9F0A
        bne     L9EC5                           ; 9F0C
        lda     #$66                            ; 9F0E
        jsr     LE992                           ; 9F10
        rts                                     ; 9F13

; ----------------------------------------------------------------------------
        lda     $14                             ; 9F14
        clc                                     ; 9F16
        adc     #$00                            ; 9F17
        cmp     #$F0                            ; 9F19
        bcc     L9F1F                           ; 9F1B
        adc     #$0F                            ; 9F1D
L9F1F:  and     #$F8                            ; 9F1F
        sta     $03                             ; 9F21
        lda     #$00                            ; 9F23
        asl     $03                             ; 9F25
        rol     a                               ; 9F27
        asl     $03                             ; 9F28
        rol     a                               ; 9F2A
        ora     #$20                            ; 9F2B
        sta     $04                             ; 9F2D
        rts                                     ; 9F2F

; ----------------------------------------------------------------------------
        jsr     LBF14                           ; 9F30
        ldx     $0162                           ; 9F33
        lda     $04                             ; 9F36
        sta     $0163,x                         ; 9F38
        inx                                     ; 9F3B
        lda     $03                             ; 9F3C
        sta     $0163,x                         ; 9F3E
        inx                                     ; 9F41
        lda     #$60                            ; 9F42
        sta     $0163,x                         ; 9F44
        inx                                     ; 9F47
        lda     #$2C                            ; 9F48
        sta     $0163,x                         ; 9F4A
        inx                                     ; 9F4D
        jmp     LB4F1                           ; 9F4E

; ----------------------------------------------------------------------------
        jsr     LBF14                           ; 9F51
        ldy     #$00                            ; 9F54
        lda     ($0E),y                         ; 9F56
        cmp     #$FF                            ; 9F58
        beq     L9F9A                           ; 9F5A
        clc                                     ; 9F5C
        adc     $03                             ; 9F5D
        sta     $03                             ; 9F5F
        lda     $04                             ; 9F61
        adc     #$00                            ; 9F63
        sta     $04                             ; 9F65
        ldx     $0162                           ; 9F67
        lda     $04                             ; 9F6A
        jsr     LB5E1                           ; 9F6C
        lda     $03                             ; 9F6F
        jsr     LB5E1                           ; 9F71
        ldy     #$01                            ; 9F74
        lda     ($0E),y                         ; 9F76
        sta     $05                             ; 9F78
        jsr     LB5E1                           ; 9F7A
L9F7D:  lda     ($0E),y                         ; 9F7D
        jsr     LB5E1                           ; 9F7F
        dec     $05                             ; 9F82
        bne     L9F7D                           ; 9F84
        jsr     LB4F1                           ; 9F86
        lda     ($0E),y                         ; 9F89
        sta     $0D                             ; 9F8B
        iny                                     ; 9F8D
        tya                                     ; 9F8E
        clc                                     ; 9F8F
        adc     $0E                             ; 9F90
        sta     $0E                             ; 9F92
        lda     $0F                             ; 9F94
        adc     #$00                            ; 9F96
        sta     $0F                             ; 9F98
L9F9A:  rts                                     ; 9F9A

; ----------------------------------------------------------------------------
        tay                                     ; 9F9B
        ldx     #$00                            ; 9F9C
L9F9E:  lda     $0590,y                         ; 9F9E
        sta     $B8,x                           ; 9FA1
        iny                                     ; 9FA3
        inx                                     ; 9FA4
        cpx     #$06                            ; 9FA5
        bne     L9F9E                           ; 9FA7
        lda     $0590,y                         ; 9FA9
        sta     $B1                             ; 9FAC
        lda     $0591,y                         ; 9FAE
        sta     $B2                             ; 9FB1
        jsr     LEA7E                           ; 9FB3
        jsr     LE07A                           ; 9FB6
        jsr     LE07E                           ; 9FB9
        jsr     LE080                           ; 9FBC
        lda     #$01                            ; 9FBF
        jsr     LF7B1                           ; 9FC1
        jmp     LF09B                           ; 9FC4

; ----------------------------------------------------------------------------
        sta     $BC                             ; 9FC7
        sty     $BD                             ; 9FC9
        jsr     LE080                           ; 9FCB
        jmp     LF07B                           ; 9FCE

; ----------------------------------------------------------------------------
        jsr     LE95B                           ; 9FD1
        jsr     LA9C9                           ; 9FD4
        jmp     LAA28                           ; 9FD7

; ----------------------------------------------------------------------------
        jsr     LE02F                           ; 9FDA
        lda     #$01                            ; 9FDD
        jsr     LF7B1                           ; 9FDF
        jmp     LF785                           ; 9FE2

; ----------------------------------------------------------------------------
        jsr     LE02D                           ; 9FE5
        lda     #$01                            ; 9FE8
        jmp     LF7B1                           ; 9FEA

; ----------------------------------------------------------------------------
L9FED:  jsr     LF0B5                           ; 9FED
        inc     $0D                             ; 9FF0
        lda     $0D                             ; 9FF2
        cmp     #$10                            ; 9FF4
        bne     L9FED                           ; 9FF6
        lda     #$00                            ; 9FF8
        sta     $0D                             ; 9FFA
        rts                                     ; 9FFC

; ----------------------------------------------------------------------------
        .byte   $FF                             ; 9FFD
        .byte   $FF                             ; 9FFE
        .byte   $FF                             ; 9FFF
