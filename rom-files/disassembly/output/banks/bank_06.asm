; ============================================================================
; The Magic of Scheherazade - Bank 06 Disassembly
; ============================================================================
; File Offset: 0x0C000 - 0x0DFFF
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
; Input file: C:/claude-workspace/TMOS_AI/rom-files/disassembly/output/banks/bank_06.bin
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
L0000           := $0000
L0103           := $0103
L010E           := $010E
L020C           := $020C
L0218           := $0218
L0A02           := $0A02
L0F06           := $0F06
L1020           := $1020
L1616           := $1616
L1B03           := $1B03
L1D1F           := $1D1F
PPU_CTRL        := $2000
PPU_MASK        := $2001
PPU_STATUS      := $2002
OAM_ADDR        := $2003
OAM_DATA        := $2004
PPU_SCROLL      := $2005
PPU_ADDR        := $2006
PPU_DATA        := $2007
L2030           := $2030
L2086           := $2086
L208E           := $208E
L2096           := $2096
L220B           := $220B
L2316           := $2316
L2516           := $2516
L2527           := $2527
L2614           := $2614
L261A           := $261A
L2626           := $2626
L2711           := $2711
L2714           := $2714
L2716           := $2716
L2816           := $2816
L2817           := $2817
L281A           := $281A
L2C26           := $2C26
OAM_DMA         := $4014
APU_STATUS      := $4015
JOY1            := $4016
JOY2_FRAME      := $4017
L4A21           := $4A21
L658E           := $658E
L6B6B           := $6B6B
L7384           := $7384
LA00D           := $A00D
LA012           := $A012
LA4EE           := $A4EE
LA510           := $A510
LA553           := $A553
LA598           := $A598
LA61A           := $A61A
LA81F           := $A81F
LB217           := $B217
LB593           := $B593
LB5AB           := $B5AB
LB5CE           := $B5CE
LB74C           := $B74C
LB826           := $B826
LB8BF           := $B8BF
LB8F9           := $B8F9
LB9A1           := $B9A1
LBA40           := $BA40
LBB00           := $BB00
LBBBA           := $BBBA
LBCC8           := $BCC8
LBD17           := $BD17
LBE3B           := $BE3B
LC0C4           := $C0C4
LC1F7           := $C1F7
LC52E           := $C52E
LC58E           := $C58E
LC5A9           := $C5A9
LC5F7           := $C5F7
LC64F           := $C64F
LC6B0           := $C6B0
LC6F3           := $C6F3
LC753           := $C753
LC762           := $C762
LC793           := $C793
LC7F9           := $C7F9
LC837           := $C837
LC8F9           := $C8F9
LC910           := $C910
LC929           := $C929
LC972           := $C972
LC9C3           := $C9C3
LCA04           := $CA04
LCA62           := $CA62
LCAE1           := $CAE1
LCB16           := $CB16
LCB71           := $CB71
LCB83           := $CB83
LCC43           := $CC43
LCD6A           := $CD6A
LCE00           := $CE00
LCE27           := $CE27
LCE8D           := $CE8D
LCEE3           := $CEE3
LCF3A           := $CF3A
LCF43           := $CF43
LCF51           := $CF51
LCF88           := $CF88
LCFA1           := $CFA1
LCFA9           := $CFA9
LD000           := $D000
LD049           := $D049
LDF16           := $DF16
LE029           := $E029
LE033           := $E033
LE8C8           := $E8C8
LE95B           := $E95B
LE97D           := $E97D
LE992           := $E992
LE9EB           := $E9EB
LEBB8           := $EBB8
LEC46           := $EC46
LFF20           := $FF20
; ----------------------------------------------------------------------------
        lda     $FD90                           ; 8000
        dec     $B2                             ; 8003
        bcc     L800A                           ; 8005
        .byte   $C7                             ; 8007
        sta     $C2,x                           ; 8008
L800A:  brk                                     ; 800A
        brk                                     ; 800B
        brk                                     ; 800C
        brk                                     ; 800D
        brk                                     ; 800E
        brk                                     ; 800F
        .byte   $02                             ; 8010
        sty     $04,x                           ; 8011
        .byte   $03                             ; 8013
        .byte   $57                             ; 8014
        ora     $03                             ; 8015
        .byte   $89                             ; 8017
L8018:  php                                     ; 8018
        .byte   $0F                             ; 8019
        .byte   $1B                             ; 801A
        ora     (L0000,x)                       ; 801B
        .byte   $1F                             ; 801D
        ora     (L0000,x)                       ; 801E
        and     (L0000,x)                       ; 8020
        brk                                     ; 8022
        .byte   $22                             ; 8023
        brk                                     ; 8024
        brk                                     ; 8025
        .byte   $23                             ; 8026
        ora     ($01,x)                         ; 8027
        and     $01                             ; 8029
        brk                                     ; 802B
        rol     a:$01                           ; 802C
        .byte   $37                             ; 802F
        .byte   $02                             ; 8030
        brk                                     ; 8031
        .byte   $3B                             ; 8032
        .byte   $02                             ; 8033
        ora     ($44,x)                         ; 8034
        brk                                     ; 8036
        brk                                     ; 8037
        .byte   $47                             ; 8038
        .byte   $03                             ; 8039
        ora     ($48,x)                         ; 803A
        .byte   $03                             ; 803C
        brk                                     ; 803D
        jmp     L0103                           ; 803E

; ----------------------------------------------------------------------------
        lsr     $01,x                           ; 8041
        ora     ($5E,x)                         ; 8043
        .byte   $02                             ; 8045
        ora     ($10,x)                         ; 8046
        asl     a:$04                           ; 8048
        .byte   $0F                             ; 804B
        .byte   $02                             ; 804C
        brk                                     ; 804D
        bpl     L8050                           ; 804E
L8050:  brk                                     ; 8050
        ora     $01,x                           ; 8051
        brk                                     ; 8053
        bit     $01                             ; 8054
        brk                                     ; 8056
        and     L0000                           ; 8057
        ora     ($32,x)                         ; 8059
        .byte   $04                             ; 805B
        ora     ($3D,x)                         ; 805C
        asl     L0000                           ; 805E
        rti                                     ; 8060

; ----------------------------------------------------------------------------
        brk                                     ; 8061
        ora     ($4A,x)                         ; 8062
        .byte   $04                             ; 8064
        brk                                     ; 8065
        lsr     $87,x                           ; 8066
        brk                                     ; 8068
        .byte   $57                             ; 8069
        .byte   $83                             ; 806A
        ora     ($5C,x)                         ; 806B
        sta     $01                             ; 806D
        .byte   $63                             ; 806F
        asl     $01                             ; 8070
        .byte   $67                             ; 8072
        asl     $01                             ; 8073
        ror     a:$04                           ; 8075
        ora     ($0C),y                         ; 8078
        ora     #$03                            ; 807A
        ora     ($08),y                         ; 807C
        .byte   $03                             ; 807E
        .byte   $1A                             ; 807F
        ora     #$03                            ; 8080
        ora     $030A,x                         ; 8082
        .byte   $22                             ; 8085
        ora     #$00                            ; 8086
        plp                                     ; 8088
        ora     #$03                            ; 8089
        lsr     a                               ; 808B
        ora     #$00                            ; 808C
        bvc     L8018                           ; 808E
        .byte   $03                             ; 8090
        .byte   $53                             ; 8091
        ora     #$03                            ; 8092
        .byte   $55                             ; 8094
L8095:  .byte   $89                             ; 8095
        brk                                     ; 8096
        adc     ($08,x)                         ; 8097
        .byte   $02                             ; 8099
        .byte   $67                             ; 809A
        ora     #$02                            ; 809B
        adc     #$0A                            ; 809D
        ora     ($6D,x)                         ; 809F
        asl     a                               ; 80A1
        brk                                     ; 80A2
        adc     $87,x                           ; 80A3
        brk                                     ; 80A5
        .byte   $7C                             ; 80A6
        sta     L0000                           ; 80A7
        ror     a:$87,x                         ; 80A9
        asl     $0F,x                           ; 80AC
        ora     #$03                            ; 80AE
        .byte   $13                             ; 80B0
        asl     a                               ; 80B1
        .byte   $03                             ; 80B2
        ora     $0C,x                           ; 80B3
        .byte   $03                             ; 80B5
        .byte   $1C                             ; 80B6
        asl     a                               ; 80B7
        .byte   $03                             ; 80B8
        ora     a:$89,x                         ; 80B9
        .byte   $1F                             ; 80BC
        .byte   $0C                             ; 80BD
        .byte   $03                             ; 80BE
        rol     $0C,x                           ; 80BF
        .byte   $03                             ; 80C1
        .byte   $3F                             ; 80C2
        txa                                     ; 80C3
        .byte   $03                             ; 80C4
        eor     ($0B,x)                         ; 80C5
        ora     ($48,x)                         ; 80C7
        txa                                     ; 80C9
        .byte   $03                             ; 80CA
        .byte   $4F                             ; 80CB
        .byte   $0B                             ; 80CC
        .byte   $02                             ; 80CD
        bvc     L80DC                           ; 80CE
        .byte   $02                             ; 80D0
        eor     $0C,x                           ; 80D1
        .byte   $03                             ; 80D3
        .byte   $5B                             ; 80D4
        .byte   $0B                             ; 80D5
        .byte   $02                             ; 80D6
        adc     ($0C,x)                         ; 80D7
        .byte   $03                             ; 80D9
        .byte   $62                             ; 80DA
        asl     a                               ; 80DB
L80DC:  brk                                     ; 80DC
        ror     a                               ; 80DD
        .byte   $0B                             ; 80DE
        .byte   $02                             ; 80DF
        bvs     L80EF                           ; 80E0
        ora     ($77,x)                         ; 80E2
        sta     $7901                           ; 80E4
        .byte   $8B                             ; 80E7
        ora     ($83,x)                         ; 80E8
        .byte   $0C                             ; 80EA
        ora     ($86,x)                         ; 80EB
        .byte   $0B                             ; 80ED
        brk                                     ; 80EE
L80EF:  .byte   $13                             ; 80EF
        .byte   $07                             ; 80F0
        .byte   $0F                             ; 80F1
        .byte   $03                             ; 80F2
        ora     #$0F                            ; 80F3
        .byte   $03                             ; 80F5
        .byte   $13                             ; 80F6
        ora     #$00                            ; 80F7
        asl     $0C,x                           ; 80F9
        .byte   $03                             ; 80FB
        .byte   $22                             ; 80FC
        .byte   $0F                             ; 80FD
        .byte   $03                             ; 80FE
        rol     $8D                             ; 80FF
        .byte   $03                             ; 8101
        bmi     L8095                           ; 8102
        .byte   $03                             ; 8104
        .byte   $37                             ; 8105
        sta     $4A00                           ; 8106
        stx     $3901                           ; 8109
        sta     $4502                           ; 810C
        bcc     L8114                           ; 810F
        jmp     (L010E)                         ; 8111

; ----------------------------------------------------------------------------
L8114:  adc     $0110                           ; 8114
        ror     $010A                           ; 8117
        .byte   $73                             ; 811A
        bpl     L811F                           ; 811B
        adc     $0E,x                           ; 811D
L811F:  .byte   $02                             ; 811F
        .byte   $7A                             ; 8120
        ora     ($03),y                         ; 8121
        .byte   $7B                             ; 8123
        .byte   $0C                             ; 8124
        brk                                     ; 8125
        .byte   $7C                             ; 8126
        bpl     L812C                           ; 8127
        .byte   $02                             ; 8129
        .byte   $04                             ; 812A
        .byte   $05                             ; 812B
L812C:  .byte   $03                             ; 812C
        .byte   $03                             ; 812D
        .byte   $04                             ; 812E
        .byte   $03                             ; 812F
        ora     ($0C,x)                         ; 8130
        ora     ($03,x)                         ; 8132
        ora     $02                             ; 8134
        .byte   $04                             ; 8136
        ora     $09                             ; 8137
        .byte   $03                             ; 8139
        ora     #$03                            ; 813A
        ora     ($0C,x)                         ; 813C
        .byte   $03                             ; 813E
        ora     ($09,x)                         ; 813F
        .byte   $02                             ; 8141
        ora     #$05                            ; 8142
        ora     ($03,x)                         ; 8144
        .byte   $03                             ; 8146
        ora     ($05,x)                         ; 8147
        .byte   $0C                             ; 8149
        .byte   $03                             ; 814A
        ora     ($05,x)                         ; 814B
        .byte   $02                             ; 814D
        asl     $07                             ; 814E
        .byte   $0B                             ; 8150
        .byte   $03                             ; 8151
        asl     $07                             ; 8152
        .byte   $0B                             ; 8154
        .byte   $0C                             ; 8155
        .byte   $0B                             ; 8156
        .byte   $07                             ; 8157
        .byte   $13                             ; 8158
        .byte   $04                             ; 8159
        .byte   $04                             ; 815A
        .byte   $02                             ; 815B
        ora     #$05                            ; 815C
        ora     #$02                            ; 815E
        brk                                     ; 8160
        .byte   $0C                             ; 8161
        brk                                     ; 8162
        .byte   $04                             ; 8163
        brk                                     ; 8164
        .byte   $04                             ; 8165
        clc                                     ; 8166
        .byte   $14                             ; 8167
        .byte   $0B                             ; 8168
        ora     $13                             ; 8169
        clc                                     ; 816B
        .byte   $14                             ; 816C
        .byte   $0C                             ; 816D
        .byte   $13                             ; 816E
        .byte   $14                             ; 816F
        .byte   $13                             ; 8170
        .byte   $04                             ; 8171
        .byte   $03                             ; 8172
        .byte   $0C                             ; 8173
        brk                                     ; 8174
        ora     $0C                             ; 8175
        brk                                     ; 8177
        ora     ($0C,x)                         ; 8178
        brk                                     ; 817A
        ora     ($0C,x)                         ; 817B
        .byte   $04                             ; 817D
        asl     $07                             ; 817E
        .byte   $0B                             ; 8180
        ora     $07                             ; 8181
        clc                                     ; 8183
        asl     $0C                             ; 8184
        .byte   $14                             ; 8186
        asl     $13                             ; 8187
        .byte   $07                             ; 8189
        asl     a                               ; 818A
        .byte   $12                             ; 818B
        .byte   $0C                             ; 818C
        php                                     ; 818D
        php                                     ; 818E
        .byte   $0C                             ; 818F
        .byte   $14                             ; 8190
        .byte   $0C                             ; 8191
        php                                     ; 8192
        .byte   $0F                             ; 8193
        .byte   $14                             ; 8194
        .byte   $07                             ; 8195
        .byte   $0C                             ; 8196
        asl     a                               ; 8197
        php                                     ; 8198
        php                                     ; 8199
        .byte   $12                             ; 819A
        php                                     ; 819B
        .byte   $0F                             ; 819C
        .byte   $0C                             ; 819D
        php                                     ; 819E
        .byte   $12                             ; 819F
        .byte   $0F                             ; 81A0
        .byte   $07                             ; 81A1
        ora     $0D08                           ; 81A2
        php                                     ; 81A5
        .byte   $0F                             ; 81A6
        ora     $0C08                           ; 81A7
        php                                     ; 81AA
        .byte   $0F                             ; 81AB
        .byte   $0F                             ; 81AC
        ora     #$16                            ; 81AD
        bpl     L81CF                           ; 81AF
        asl     a                               ; 81B1
        bit     $1E                             ; 81B2
        asl     $0C,x                           ; 81B4
        asl     $1024,x                         ; 81B6
        ora     #$16                            ; 81B9
        .byte   $17                             ; 81BB
        .byte   $22                             ; 81BC
        asl     a                               ; 81BD
        bit     $22                             ; 81BE
        asl     $170C,x                         ; 81C0
        asl     $0922,x                         ; 81C3
        .byte   $1A                             ; 81C6
        .byte   $14                             ; 81C7
        ora     $0A,x                           ; 81C8
        ora     $27,x                           ; 81CA
        .byte   $1A                             ; 81CC
        .byte   $0C                             ; 81CD
        .byte   $25                             ; 81CE
L81CF:  ora     $1A,x                           ; 81CF
        asl     a                               ; 81D1
        .byte   $1A                             ; 81D2
        .byte   $1F                             ; 81D3
        jsr     L220B                           ; 81D4
        ora     ($1C),y                         ; 81D7
        .byte   $0C                             ; 81D9
        jsr     L2527                           ; 81DA
        asl     a                               ; 81DD
        ora     ($0F),y                         ; 81DE
        asl     L220B                           ; 81E0
        ora     $0C22,x                         ; 81E3
        ora     ($1B),y                         ; 81E6
        .byte   $1C                             ; 81E8
        asl     a                               ; 81E9
        and     $1A                             ; 81EA
        .byte   $22                             ; 81EC
        .byte   $0B                             ; 81ED
        ora     $1C1B,x                         ; 81EE
        .byte   $0C                             ; 81F1
        ora     $2120,y                         ; 81F2
        asl     a                               ; 81F5
        and     $1C                             ; 81F6
        .byte   $27                             ; 81F8
        .byte   $0B                             ; 81F9
        ora     $211B,y                         ; 81FA
        .byte   $0C                             ; 81FD
        jsr     L1D1F                           ; 81FE
        brk                                     ; 8201
        .byte   $FF                             ; 8202
        .byte   $FF                             ; 8203
        ora     $1EFF                           ; 8204
        .byte   $FF                             ; 8207
        .byte   $FF                             ; 8208
        brk                                     ; 8209
        .byte   $FF                             ; 820A
        .byte   $FF                             ; 820B
        ora     ($FF),y                         ; 820C
        asl     $FFFF,x                         ; 820E
        brk                                     ; 8211
        .byte   $FF                             ; 8212
        .byte   $FF                             ; 8213
        ora     $0DFF                           ; 8214
        .byte   $FF                             ; 8217
        .byte   $FF                             ; 8218
        brk                                     ; 8219
        .byte   $FF                             ; 821A
        .byte   $FF                             ; 821B
        ora     ($FF),y                         ; 821C
L821E:  ora     ($FF),y                         ; 821E
        .byte   $FF                             ; 8220
        brk                                     ; 8221
        .byte   $FF                             ; 8222
        plp                                     ; 8223
        .byte   $FF                             ; 8224
        plp                                     ; 8225
        .byte   $FF                             ; 8226
        plp                                     ; 8227
        .byte   $FF                             ; 8228
        brk                                     ; 8229
        .byte   $FF                             ; 822A
        rol     $FF                             ; 822B
        rol     $FF                             ; 822D
        rol     $FF                             ; 822F
        brk                                     ; 8231
        .byte   $FF                             ; 8232
        bit     $FF                             ; 8233
        bit     $FF                             ; 8235
        bit     $FF                             ; 8237
        brk                                     ; 8239
        .byte   $FF                             ; 823A
        .byte   $FF                             ; 823B
        and     ($FF,x)                         ; 823C
        and     ($FF,x)                         ; 823E
        .byte   $FF                             ; 8240
        brk                                     ; 8241
        .byte   $14                             ; 8242
        .byte   $FF                             ; 8243
        .byte   $14                             ; 8244
        .byte   $FF                             ; 8245
        .byte   $1F                             ; 8246
        .byte   $FF                             ; 8247
        .byte   $1F                             ; 8248
        brk                                     ; 8249
        plp                                     ; 824A
        plp                                     ; 824B
        plp                                     ; 824C
        plp                                     ; 824D
        plp                                     ; 824E
        plp                                     ; 824F
        .byte   $FF                             ; 8250
        brk                                     ; 8251
        .byte   $FF                             ; 8252
        .byte   $FF                             ; 8253
        .byte   $14                             ; 8254
        .byte   $FF                             ; 8255
        .byte   $14                             ; 8256
        .byte   $FF                             ; 8257
        .byte   $FF                             ; 8258
        brk                                     ; 8259
        .byte   $FF                             ; 825A
        .byte   $FF                             ; 825B
        .byte   $FF                             ; 825C
        ora     $FFFF,y                         ; 825D
        .byte   $FF                             ; 8260
        brk                                     ; 8261
        ora     $0DFF                           ; 8262
        .byte   $FF                             ; 8265
        ora     $0DFF                           ; 8266
        brk                                     ; 8269
        ora     $0DFF                           ; 826A
        .byte   $FF                             ; 826D
        .byte   $1F                             ; 826E
        .byte   $FF                             ; 826F
        .byte   $1F                             ; 8270
        brk                                     ; 8271
        .byte   $12                             ; 8272
        .byte   $FF                             ; 8273
        .byte   $12                             ; 8274
        .byte   $FF                             ; 8275
        .byte   $1F                             ; 8276
        .byte   $FF                             ; 8277
        .byte   $1F                             ; 8278
        brk                                     ; 8279
        ora     $1C0D                           ; 827A
        .byte   $1C                             ; 827D
        ora     $FF0D                           ; 827E
        ora     ($FF,x)                         ; 8281
        asl     $0EFF                           ; 8283
        .byte   $FF                             ; 8286
        asl     a:$FF                           ; 8287
        .byte   $FF                             ; 828A
        .byte   $12                             ; 828B
        .byte   $FF                             ; 828C
        .byte   $12                             ; 828D
        .byte   $FF                             ; 828E
L828F:  .byte   $12                             ; 828F
        .byte   $FF                             ; 8290
        brk                                     ; 8291
        and     #$29                            ; 8292
        and     #$29                            ; 8294
        and     #$29                            ; 8296
        .byte   $FF                             ; 8298
        brk                                     ; 8299
        bit     $24                             ; 829A
        bit     $19                             ; 829C
        bit     $24                             ; 829E
        bit     L0000                           ; 82A0
        .byte   $FF                             ; 82A2
        .byte   $FF                             ; 82A3
        .byte   $22                             ; 82A4
        .byte   $FF                             ; 82A5
        .byte   $22                             ; 82A6
        .byte   $FF                             ; 82A7
        .byte   $FF                             ; 82A8
        ora     ($FF,x)                         ; 82A9
        .byte   $17                             ; 82AB
        .byte   $FF                             ; 82AC
        .byte   $17                             ; 82AD
        .byte   $FF                             ; 82AE
        .byte   $17                             ; 82AF
        .byte   $FF                             ; 82B0
        brk                                     ; 82B1
        .byte   $FF                             ; 82B2
        .byte   $FF                             ; 82B3
        ora     $FF,x                           ; 82B4
        ora     $FF,x                           ; 82B6
        .byte   $FF                             ; 82B8
        brk                                     ; 82B9
        ora     $FF,x                           ; 82BA
        ora     $FF,x                           ; 82BC
        .byte   $1F                             ; 82BE
        .byte   $FF                             ; 82BF
        .byte   $1F                             ; 82C0
        brk                                     ; 82C1
        .byte   $FF                             ; 82C2
        .byte   $FF                             ; 82C3
        ora     $FF,x                           ; 82C4
        and     ($FF,x)                         ; 82C6
        .byte   $FF                             ; 82C8
        brk                                     ; 82C9
        .byte   $13                             ; 82CA
        .byte   $13                             ; 82CB
        .byte   $27                             ; 82CC
        .byte   $27                             ; 82CD
        .byte   $27                             ; 82CE
        .byte   $27                             ; 82CF
        .byte   $FF                             ; 82D0
        brk                                     ; 82D1
        and     $25                             ; 82D2
        and     $1B                             ; 82D4
        and     $25                             ; 82D6
        and     L0000                           ; 82D8
        asl     $0E0E                           ; 82DA
        asl     $2020                           ; 82DD
        .byte   $FF                             ; 82E0
        brk                                     ; 82E1
        .byte   $12                             ; 82E2
        .byte   $12                             ; 82E3
        .byte   $12                             ; 82E4
        .byte   $12                             ; 82E5
        jsr     LFF20                           ; 82E6
        brk                                     ; 82E9
        .byte   $17                             ; 82EA
        .byte   $17                             ; 82EB
        .byte   $17                             ; 82EC
        .byte   $17                             ; 82ED
        jsr     LFF20                           ; 82EE
        brk                                     ; 82F1
        ora     $FF,x                           ; 82F2
        ora     $FF,x                           ; 82F4
        .byte   $1C                             ; 82F6
        .byte   $FF                             ; 82F7
        .byte   $1C                             ; 82F8
        brk                                     ; 82F9
        asl     $0E0E                           ; 82FA
        asl     $1D1D                           ; 82FD
        .byte   $FF                             ; 8300
        brk                                     ; 8301
        .byte   $12                             ; 8302
        .byte   $12                             ; 8303
        .byte   $12                             ; 8304
        .byte   $12                             ; 8305
        ora     $FF1D,x                         ; 8306
        ora     ($17,x)                         ; 8309
        .byte   $17                             ; 830B
        .byte   $17                             ; 830C
        .byte   $17                             ; 830D
        ora     $FF1D,x                         ; 830E
        ora     ($10,x)                         ; 8311
        bpl     L8325                           ; 8313
        asl     $1010                           ; 8315
        bpl     L831A                           ; 8318
L831A:  brk                                     ; 831A
        brk                                     ; 831B
        brk                                     ; 831C
        brk                                     ; 831D
        brk                                     ; 831E
        brk                                     ; 831F
        brk                                     ; 8320
        ora     ($15,x)                         ; 8321
        .byte   $FF                             ; 8323
        .byte   $15                             ; 8324
L8325:  .byte   $FF                             ; 8325
        ora     $FF,x                           ; 8326
        ora     L0000,x                         ; 8328
        .byte   $FF                             ; 832A
        .byte   $1A                             ; 832B
        .byte   $FF                             ; 832C
        .byte   $1A                             ; 832D
        .byte   $FF                             ; 832E
        .byte   $1A                             ; 832F
        .byte   $FF                             ; 8330
        brk                                     ; 8331
        brk                                     ; 8332
        brk                                     ; 8333
        brk                                     ; 8334
        brk                                     ; 8335
        brk                                     ; 8336
        brk                                     ; 8337
        brk                                     ; 8338
        brk                                     ; 8339
        .byte   $FF                             ; 833A
        .byte   $23                             ; 833B
        .byte   $FF                             ; 833C
        .byte   $23                             ; 833D
        .byte   $FF                             ; 833E
        .byte   $23                             ; 833F
        .byte   $FF                             ; 8340
        .byte   $07                             ; 8341
        ora     $14                             ; 8342
        .byte   $82                             ; 8344
        .byte   $04                             ; 8345
        ora     ($04,x)                         ; 8346
        bpl     L8350                           ; 8348
        .byte   $02                             ; 834A
        bpl     L8357                           ; 834B
        plp                                     ; 834D
        .byte   $82                             ; 834E
        .byte   $04                             ; 834F
L8350:  ora     ($04,x)                         ; 8350
        rol     $10,x                           ; 8352
        .byte   $02                             ; 8354
        bpl     L8361                           ; 8355
L8357:  brk                                     ; 8357
        .byte   $FF                             ; 8358
        .byte   $04                             ; 8359
        ora     ($04,x)                         ; 835A
        rol     $10,x                           ; 835C
        .byte   $02                             ; 835E
        asl     a                               ; 835F
        .byte   $01                             ; 8360
L8361:  .byte   $14                             ; 8361
        .byte   $82                             ; 8362
        .byte   $FF                             ; 8363
        ora     ($04,x)                         ; 8364
        .byte   $0C                             ; 8366
        asl     $02                             ; 8367
        .byte   $04                             ; 8369
        ora     $14,x                           ; 836A
        .byte   $82                             ; 836C
        .byte   $03                             ; 836D
        ora     ($04,x)                         ; 836E
        .byte   $0C                             ; 8370
        .byte   $04                             ; 8371
        .byte   $02                             ; 8372
        bpl     L837F                           ; 8373
        asl     $0382,x                         ; 8375
        ora     ($04,x)                         ; 8378
        rol     $14,x                           ; 837A
        .byte   $02                             ; 837C
        clc                                     ; 837D
        php                                     ; 837E
L837F:  asl     $0482,x                         ; 837F
        ora     ($04,x)                         ; 8382
        pha                                     ; 8384
        .byte   $14                             ; 8385
        .byte   $02                             ; 8386
        php                                     ; 8387
        asl     a                               ; 8388
        .byte   $14                             ; 8389
        .byte   $82                             ; 838A
        .byte   $04                             ; 838B
        ora     ($04,x)                         ; 838C
        clc                                     ; 838E
        php                                     ; 838F
        .byte   $02                             ; 8390
        .byte   $0C                             ; 8391
        bpl     L83BC                           ; 8392
        .byte   $82                             ; 8394
        .byte   $03                             ; 8395
        ora     ($04,x)                         ; 8396
        bit     $10                             ; 8398
        .byte   $02                             ; 839A
        .byte   $0C                             ; 839B
        bpl     L839E                           ; 839C
L839E:  .byte   $FF                             ; 839E
        .byte   $FF                             ; 839F
        ora     ($04,x)                         ; 83A0
        bit     $10                             ; 83A2
        .byte   $02                             ; 83A4
        bpl     L83CF                           ; 83A5
        asl     $0482,x                         ; 83A7
        ora     ($04,x)                         ; 83AA
        rol     $14,x                           ; 83AC
        .byte   $02                             ; 83AE
        bpl     L83B1                           ; 83AF
L83B1:  brk                                     ; 83B1
        .byte   $FF                             ; 83B2
        .byte   $FF                             ; 83B3
        ora     ($04,x)                         ; 83B4
        rol     $14,x                           ; 83B6
        .byte   $02                             ; 83B8
        .byte   $14                             ; 83B9
        .byte   $04                             ; 83BA
        .byte   $32                             ; 83BB
L83BC:  .byte   $02                             ; 83BC
        .byte   $FF                             ; 83BD
        ora     ($04,x)                         ; 83BE
        clc                                     ; 83C0
        asl     $02                             ; 83C1
        .byte   $22                             ; 83C3
        .byte   $22                             ; 83C4
        lsr     $02                             ; 83C5
        .byte   $FF                             ; 83C7
        ora     ($04,x)                         ; 83C8
        cli                                     ; 83CA
        .byte   $14                             ; 83CB
        .byte   $02                             ; 83CC
        .byte   $AE                             ; 83CD
        .byte   $01                             ; 83CE
L83CF:  lsr     $02                             ; 83CF
        .byte   $FF                             ; 83D1
        ora     ($04,x)                         ; 83D2
        .byte   $7A                             ; 83D4
        clc                                     ; 83D5
        .byte   $02                             ; 83D6
        .byte   $12                             ; 83D7
        asl     $28,x                           ; 83D8
        .byte   $02                             ; 83DA
        .byte   $FF                             ; 83DB
        ora     ($04,x)                         ; 83DC
        rol     $14,x                           ; 83DE
        .byte   $02                             ; 83E0
        asl     $3C22,x                         ; 83E1
        .byte   $02                             ; 83E4
        .byte   $FF                             ; 83E5
        ora     ($04,x)                         ; 83E6
        .byte   $6F                             ; 83E8
        jsr     L0A02                           ; 83E9
        asl     a                               ; 83EC
        plp                                     ; 83ED
        .byte   $02                             ; 83EE
        .byte   $FF                             ; 83EF
        ora     ($04,x)                         ; 83F0
        bpl     L83FA                           ; 83F2
        .byte   $02                             ; 83F4
        .byte   $0F                             ; 83F5
        .byte   $0F                             ; 83F6
        .byte   $3C                             ; 83F7
        .byte   $02                             ; 83F8
        .byte   $FF                             ; 83F9
L83FA:  ora     ($04,x)                         ; 83FA
        rol     a                               ; 83FC
        bpl     L8401                           ; 83FD
        .byte   $14                             ; 83FF
        .byte   $1D                             ; 8400
L8401:  bvc     L8405                           ; 8401
        .byte   $FF                             ; 8403
        .byte   $01                             ; 8404
L8405:  .byte   $04                             ; 8405
        jmp     L0218                           ; 8406

; ----------------------------------------------------------------------------
        ora     $14                             ; 8409
        asl     $0482,x                         ; 840B
        ora     ($03,x)                         ; 840E
        asl     a                               ; 8410
        php                                     ; 8411
        .byte   $02                             ; 8412
        .byte   $0F                             ; 8413
        asl     L821E,x                         ; 8414
        .byte   $04                             ; 8417
        ora     ($03,x)                         ; 8418
        jsr     L020C                           ; 841A
        ora     $1E28,y                         ; 841D
        .byte   $82                             ; 8420
        .byte   $04                             ; 8421
        ora     ($03,x)                         ; 8422
        rol     L0218,x                         ; 8424
        .byte   $02                             ; 8427
        ora     ($14,x)                         ; 8428
        .byte   $82                             ; 842A
        .byte   $03                             ; 842B
        ora     ($FF,x)                         ; 842C
        .byte   $03                             ; 842E
        .byte   $02                             ; 842F
        .byte   $02                             ; 8430
        .byte   $04                             ; 8431
        brk                                     ; 8432
        .byte   $14                             ; 8433
        .byte   $82                             ; 8434
        .byte   $04                             ; 8435
        ora     ($FF,x)                         ; 8436
        .byte   $0C                             ; 8438
        php                                     ; 8439
        .byte   $02                             ; 843A
        .byte   $03                             ; 843B
        asl     a                               ; 843C
        asl     a                               ; 843D
        .byte   $82                             ; 843E
        .byte   $03                             ; 843F
        ora     ($FF,x)                         ; 8440
        .byte   $04                             ; 8442
        .byte   $02                             ; 8443
        .byte   $02                             ; 8444
        ora     $03                             ; 8445
        .byte   $14                             ; 8447
        .byte   $82                             ; 8448
        .byte   $03                             ; 8449
        ora     ($FF,x)                         ; 844A
        .byte   $0C                             ; 844C
        php                                     ; 844D
        .byte   $02                             ; 844E
        .byte   $02                             ; 844F
        ora     $14                             ; 8450
        .byte   $82                             ; 8452
        .byte   $FF                             ; 8453
        ora     ($FF,x)                         ; 8454
        .byte   $03                             ; 8456
        .byte   $02                             ; 8457
        .byte   $02                             ; 8458
        .byte   $04                             ; 8459
        .byte   $03                             ; 845A
        .byte   $14                             ; 845B
        .byte   $82                             ; 845C
        .byte   $FF                             ; 845D
        ora     ($FF,x)                         ; 845E
        .byte   $0C                             ; 8460
        php                                     ; 8461
        .byte   $02                             ; 8462
        php                                     ; 8463
        php                                     ; 8464
        .byte   $0F                             ; 8465
        .byte   $0C                             ; 8466
        asl     $230A                           ; 8467
        rol     $FF                             ; 846A
        .byte   $FF                             ; 846C
        .byte   $03                             ; 846D
        .byte   $23                             ; 846E
        .byte   $1A                             ; 846F
        .byte   $12                             ; 8470
        .byte   $FF                             ; 8471
        .byte   $FF                             ; 8472
        .byte   $FF                             ; 8473
        .byte   $FF                             ; 8474
        .byte   $FF                             ; 8475
        .byte   $FF                             ; 8476
        .byte   $02                             ; 8477
        bit     $15                             ; 8478
        .byte   $FF                             ; 847A
        .byte   $FF                             ; 847B
        .byte   $FF                             ; 847C
        .byte   $FF                             ; 847D
        .byte   $FF                             ; 847E
        .byte   $FF                             ; 847F
        .byte   $FF                             ; 8480
        .byte   $03                             ; 8481
        rol     $0C                             ; 8482
        asl     $FF,x                           ; 8484
        .byte   $FF                             ; 8486
        .byte   $FF                             ; 8487
        .byte   $FF                             ; 8488
        .byte   $FF                             ; 8489
        .byte   $FF                             ; 848A
        .byte   $03                             ; 848B
        bit     $0B                             ; 848C
        clc                                     ; 848E
        .byte   $FF                             ; 848F
        .byte   $FF                             ; 8490
        .byte   $FF                             ; 8491
        .byte   $FF                             ; 8492
        .byte   $FF                             ; 8493
        .byte   $FF                             ; 8494
        .byte   $03                             ; 8495
        .byte   $23                             ; 8496
        .byte   $1A                             ; 8497
        asl     $FFFF,x                         ; 8498
        .byte   $FF                             ; 849B
        .byte   $FF                             ; 849C
        .byte   $FF                             ; 849D
        .byte   $FF                             ; 849E
        .byte   $03                             ; 849F
        rol     $12                             ; 84A0
        .byte   $0C                             ; 84A2
        .byte   $FF                             ; 84A3
        .byte   $FF                             ; 84A4
        .byte   $FF                             ; 84A5
        .byte   $FF                             ; 84A6
        .byte   $FF                             ; 84A7
        .byte   $FF                             ; 84A8
        .byte   $03                             ; 84A9
        rol     $1A                             ; 84AA
        ora     $FFFF,x                         ; 84AC
        .byte   $FF                             ; 84AF
        .byte   $FF                             ; 84B0
        .byte   $FF                             ; 84B1
        .byte   $FF                             ; 84B2
        .byte   $03                             ; 84B3
        .byte   $23                             ; 84B4
        bpl     L84C0                           ; 84B5
        .byte   $FF                             ; 84B7
        .byte   $FF                             ; 84B8
        .byte   $FF                             ; 84B9
        .byte   $FF                             ; 84BA
        .byte   $FF                             ; 84BB
        .byte   $FF                             ; 84BC
        .byte   $03                             ; 84BD
        bit     $0D                             ; 84BE
L84C0:  ora     $FF,x                           ; 84C0
        .byte   $FF                             ; 84C2
        .byte   $FF                             ; 84C3
        .byte   $FF                             ; 84C4
        .byte   $FF                             ; 84C5
        .byte   $FF                             ; 84C6
        .byte   $02                             ; 84C7
        rol     $0B                             ; 84C8
        .byte   $FF                             ; 84CA
        .byte   $FF                             ; 84CB
        .byte   $FF                             ; 84CC
        .byte   $FF                             ; 84CD
        .byte   $FF                             ; 84CE
        .byte   $FF                             ; 84CF
        .byte   $FF                             ; 84D0
        .byte   $03                             ; 84D1
        rol     $11                             ; 84D2
        .byte   $14                             ; 84D4
        .byte   $FF                             ; 84D5
        .byte   $FF                             ; 84D6
        .byte   $FF                             ; 84D7
        .byte   $FF                             ; 84D8
        .byte   $FF                             ; 84D9
        .byte   $FF                             ; 84DA
        ora     ($26,x)                         ; 84DB
        .byte   $FF                             ; 84DD
        .byte   $FF                             ; 84DE
        .byte   $FF                             ; 84DF
        .byte   $FF                             ; 84E0
        .byte   $FF                             ; 84E1
        .byte   $FF                             ; 84E2
        .byte   $FF                             ; 84E3
        .byte   $FF                             ; 84E4
        php                                     ; 84E5
        .byte   $1C                             ; 84E6
        .byte   $0B                             ; 84E7
        .byte   $0B                             ; 84E8
        .byte   $0B                             ; 84E9
        .byte   $1C                             ; 84EA
        .byte   $1C                             ; 84EB
        .byte   $1C                             ; 84EC
        .byte   $1C                             ; 84ED
        .byte   $1C                             ; 84EE
        php                                     ; 84EF
        .byte   $1C                             ; 84F0
        asl     $1C1D                           ; 84F1
        .byte   $1C                             ; 84F4
        ora     $1C0E,x                         ; 84F5
        .byte   $1C                             ; 84F8
        php                                     ; 84F9
        .byte   $1C                             ; 84FA
        .byte   $0B                             ; 84FB
        ora     $0B0B,x                         ; 84FC
        .byte   $0B                             ; 84FF
        .byte   $0B                             ; 8500
        .byte   $0B                             ; 8501
        .byte   $0B                             ; 8502
        php                                     ; 8503
        .byte   $1C                             ; 8504
        asl     a                               ; 8505
        asl     a                               ; 8506
        .byte   $1C                             ; 8507
        .byte   $1C                             ; 8508
        .byte   $1C                             ; 8509
        asl     a                               ; 850A
        .byte   $1C                             ; 850B
        .byte   $1C                             ; 850C
        php                                     ; 850D
        rol     $0B                             ; 850E
        .byte   $1F                             ; 8510
        .byte   $1F                             ; 8511
        .byte   $1F                             ; 8512
        .byte   $1F                             ; 8513
        .byte   $0B                             ; 8514
        .byte   $0B                             ; 8515
        .byte   $0B                             ; 8516
        php                                     ; 8517
        rol     $0B                             ; 8518
        .byte   $1F                             ; 851A
        rol     $26                             ; 851B
        rol     $10                             ; 851D
        bpl     L8531                           ; 851F
        php                                     ; 8521
        rol     $0B                             ; 8522
        ora     ($11),y                         ; 8524
        ora     ($11),y                         ; 8526
        rol     $26                             ; 8528
        rol     $08                             ; 852A
        rol     $0F                             ; 852C
        .byte   $0F                             ; 852E
        .byte   $0F                             ; 852F
        .byte   $0F                             ; 8530
L8531:  .byte   $0F                             ; 8531
        rol     $26                             ; 8532
        rol     $08                             ; 8534
        rol     $11                             ; 8536
        ora     $1D26,x                         ; 8538
        rol     $11                             ; 853B
        ora     ($11),y                         ; 853D
        php                                     ; 853F
        rol     $11                             ; 8540
        ora     $1111,y                         ; 8542
        rol     $26                             ; 8545
        ora     $0819,y                         ; 8547
        rol     $19                             ; 854A
        ora     $0C0C,x                         ; 854C
        ora     $191D,x                         ; 854F
        ora     $2608,y                         ; 8552
        .byte   $0C                             ; 8555
        ora     $0C19,x                         ; 8556
        .byte   $0C                             ; 8559
        .byte   $0C                             ; 855A
        ora     $081D,x                         ; 855B
        bit     $0E                             ; 855E
        and     ($24,x)                         ; 8560
        asl     $2421                           ; 8562
        asl     $0821                           ; 8565
        bit     $24                             ; 8568
        bit     $0E                             ; 856A
        and     ($24,x)                         ; 856C
        and     ($0E,x)                         ; 856E
        asl     $0E08                           ; 8570
        asl     $2424                           ; 8573
        bit     $0E                             ; 8576
        and     ($01,x)                         ; 8578
        and     ($08,x)                         ; 857A
        rol     $15                             ; 857C
        php                                     ; 857E
        rol     $15                             ; 857F
        php                                     ; 8581
        php                                     ; 8582
        .byte   $26                             ; 8583
L8584:  rol     $08                             ; 8584
        rol     $15                             ; 8586
        ora     $15,x                           ; 8588
        asl     a                               ; 858A
        rol     $26                             ; 858B
        rol     $26                             ; 858D
        php                                     ; 858F
        .byte   $23                             ; 8590
        ora     $23,x                           ; 8591
        ora     $23,x                           ; 8593
        ora     $23,x                           ; 8595
        ora     $23,x                           ; 8597
        php                                     ; 8599
        .byte   $23                             ; 859A
        ora     $0A,x                           ; 859B
        .byte   $12                             ; 859D
        asl     a                               ; 859E
        .byte   $23                             ; 859F
        .byte   $23                             ; 85A0
        .byte   $23                             ; 85A1
        .byte   $12                             ; 85A2
        php                                     ; 85A3
        .byte   $23                             ; 85A4
        ora     $23,x                           ; 85A5
        .byte   $12                             ; 85A7
        .byte   $12                             ; 85A8
        .byte   $23                             ; 85A9
        ora     $16,x                           ; 85AA
        .byte   $1B                             ; 85AC
        php                                     ; 85AD
        rol     $26                             ; 85AE
        rol     $26                             ; 85B0
        rol     $26                             ; 85B2
        rol     $26                             ; 85B4
        rol     $08                             ; 85B6
        rol     $26                             ; 85B8
        rol     $26                             ; 85BA
        rol     $26                             ; 85BC
        rol     $26                             ; 85BE
        rol     $08                             ; 85C0
        rol     $26                             ; 85C2
        rol     $26                             ; 85C4
        rol     $26                             ; 85C6
        rol     $26                             ; 85C8
        rol     $08                             ; 85CA
        rol     $26                             ; 85CC
        ora     L2626,x                         ; 85CE
        rol     $1D                             ; 85D1
        rol     $26                             ; 85D3
        php                                     ; 85D5
        .byte   $12                             ; 85D6
        rol     $1D                             ; 85D7
        rol     $26                             ; 85D9
        rol     $1D                             ; 85DB
        rol     $12                             ; 85DD
        php                                     ; 85DF
        rol     $08                             ; 85E0
        rol     $26                             ; 85E2
        rol     $26                             ; 85E4
        rol     $08                             ; 85E6
        rol     $08                             ; 85E8
        asl     a                               ; 85EA
        rol     $0A                             ; 85EB
        rol     $26                             ; 85ED
        rol     $0A                             ; 85EF
        rol     $0A                             ; 85F1
        php                                     ; 85F3
        rol     $26                             ; 85F4
        jsr     L2626                           ; 85F6
        rol     $26                             ; 85F9
        rol     $26                             ; 85FB
        php                                     ; 85FD
        rol     $20                             ; 85FE
        rol     $26                             ; 8600
        rol     $26                             ; 8602
        rol     $26                             ; 8604
        jsr     L0000                           ; 8606
        .byte   $02                             ; 8609
        asl     a                               ; 860A
        php                                     ; 860B
        ora     L0A02,y                         ; 860C
        asl     $040F,x                         ; 860F
        .byte   $0F                             ; 8612
        .byte   $0C                             ; 8613
        .byte   $14                             ; 8614
        .byte   $02                             ; 8615
        brk                                     ; 8616
        .byte   $14                             ; 8617
        .byte   $02                             ; 8618
        .byte   $14                             ; 8619
        php                                     ; 861A
        .byte   $32                             ; 861B
        .byte   $04                             ; 861C
        php                                     ; 861D
        .byte   $02                             ; 861E
        .byte   $03                             ; 861F
        .byte   $03                             ; 8620
        .byte   $02                             ; 8621
        ora     ($04,x)                         ; 8622
        .byte   $04                             ; 8624
        ora     $07                             ; 8625
        asl     a                               ; 8627
        php                                     ; 8628
        .byte   $0C                             ; 8629
        .byte   $0C                             ; 862A
        brk                                     ; 862B
        .byte   $02                             ; 862C
        brk                                     ; 862D
        .byte   $02                             ; 862E
        brk                                     ; 862F
        php                                     ; 8630
        brk                                     ; 8631
        .byte   $04                             ; 8632
        brk                                     ; 8633
        .byte   $04                             ; 8634
        brk                                     ; 8635
        brk                                     ; 8636
        brk                                     ; 8637
        brk                                     ; 8638
        brk                                     ; 8639
        brk                                     ; 863A
        brk                                     ; 863B
        php                                     ; 863C
        brk                                     ; 863D
        brk                                     ; 863E
        .byte   $04                             ; 863F
        brk                                     ; 8640
        brk                                     ; 8641
        brk                                     ; 8642
        brk                                     ; 8643
        brk                                     ; 8644
        php                                     ; 8645
        brk                                     ; 8646
        brk                                     ; 8647
        brk                                     ; 8648
        brk                                     ; 8649
        brk                                     ; 864A
        brk                                     ; 864B
        brk                                     ; 864C
        ora     (L0000,x)                       ; 864D
        .byte   $02                             ; 864F
        brk                                     ; 8650
        asl     L0000                           ; 8651
        .byte   $02                             ; 8653
        brk                                     ; 8654
        clc                                     ; 8655
        .byte   $FF                             ; 8656
        .byte   $FF                             ; 8657
        .byte   $FF                             ; 8658
        .byte   $FF                             ; 8659
        .byte   $FF                             ; 865A
        .byte   $FF                             ; 865B
        .byte   $FF                             ; 865C
        .byte   $FF                             ; 865D
        .byte   $FF                             ; 865E
        .byte   $FF                             ; 865F
        .byte   $FF                             ; 8660
        .byte   $FF                             ; 8661
        .byte   $FF                             ; 8662
        .byte   $FF                             ; 8663
        .byte   $FF                             ; 8664
        .byte   $FF                             ; 8665
        .byte   $FF                             ; 8666
        .byte   $FF                             ; 8667
        .byte   $FF                             ; 8668
        .byte   $FF                             ; 8669
        .byte   $FF                             ; 866A
        .byte   $FF                             ; 866B
        .byte   $0B                             ; 866C
        .byte   $FF                             ; 866D
        asl     a                               ; 866E
        .byte   $FF                             ; 866F
        .byte   $FF                             ; 8670
        .byte   $FF                             ; 8671
        .byte   $FF                             ; 8672
        .byte   $FF                             ; 8673
        .byte   $FF                             ; 8674
        .byte   $FF                             ; 8675
        .byte   $FF                             ; 8676
        .byte   $FF                             ; 8677
        .byte   $FF                             ; 8678
        .byte   $FF                             ; 8679
        .byte   $FF                             ; 867A
        .byte   $FF                             ; 867B
        .byte   $FF                             ; 867C
        .byte   $FF                             ; 867D
        .byte   $FF                             ; 867E
        .byte   $FF                             ; 867F
        .byte   $0B                             ; 8680
        .byte   $FF                             ; 8681
        .byte   $FF                             ; 8682
        .byte   $FF                             ; 8683
        .byte   $FF                             ; 8684
        .byte   $FF                             ; 8685
        .byte   $FF                             ; 8686
        .byte   $FF                             ; 8687
        .byte   $FF                             ; 8688
        .byte   $FF                             ; 8689
        .byte   $FF                             ; 868A
        .byte   $FF                             ; 868B
        .byte   $FF                             ; 868C
        .byte   $FF                             ; 868D
        .byte   $FF                             ; 868E
        .byte   $FF                             ; 868F
        .byte   $FF                             ; 8690
        .byte   $FF                             ; 8691
        .byte   $FF                             ; 8692
        .byte   $FF                             ; 8693
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
        .byte   $FF                             ; 86A0
        .byte   $FF                             ; 86A1
        .byte   $F3                             ; 86A2
        .byte   $F3                             ; 86A3
        .byte   $F4                             ; 86A4
        .byte   $FF                             ; 86A5
        .byte   $FF                             ; 86A6
        .byte   $FF                             ; 86A7
        .byte   $FF                             ; 86A8
        .byte   $FF                             ; 86A9
        .byte   $FF                             ; 86AA
        .byte   $0C                             ; 86AB
        .byte   $FF                             ; 86AC
        .byte   $FF                             ; 86AD
        .byte   $FF                             ; 86AE
        .byte   $FF                             ; 86AF
        .byte   $FF                             ; 86B0
        .byte   $FF                             ; 86B1
        .byte   $FF                             ; 86B2
        .byte   $FF                             ; 86B3
        .byte   $FF                             ; 86B4
        .byte   $FF                             ; 86B5
        .byte   $FF                             ; 86B6
        .byte   $FF                             ; 86B7
        .byte   $FF                             ; 86B8
        .byte   $FF                             ; 86B9
        .byte   $FF                             ; 86BA
        .byte   $FF                             ; 86BB
        .byte   $FF                             ; 86BC
        .byte   $FF                             ; 86BD
        .byte   $FF                             ; 86BE
        .byte   $FF                             ; 86BF
        .byte   $FF                             ; 86C0
        .byte   $FF                             ; 86C1
        .byte   $FF                             ; 86C2
        .byte   $FF                             ; 86C3
        .byte   $FF                             ; 86C4
        .byte   $FF                             ; 86C5
        .byte   $FF                             ; 86C6
        .byte   $FF                             ; 86C7
        .byte   $FF                             ; 86C8
        .byte   $FF                             ; 86C9
        .byte   $FF                             ; 86CA
        .byte   $FF                             ; 86CB
        .byte   $FF                             ; 86CC
        .byte   $F3                             ; 86CD
        .byte   $F3                             ; 86CE
        .byte   $F4                             ; 86CF
        .byte   $FF                             ; 86D0
        .byte   $FF                             ; 86D1
        .byte   $FF                             ; 86D2
        .byte   $FF                             ; 86D3
        .byte   $FF                             ; 86D4
        .byte   $FF                             ; 86D5
        ora     $FFFF                           ; 86D6
        .byte   $FF                             ; 86D9
        .byte   $FF                             ; 86DA
        .byte   $FF                             ; 86DB
        .byte   $FF                             ; 86DC
        .byte   $FF                             ; 86DD
        .byte   $FF                             ; 86DE
        .byte   $FF                             ; 86DF
        .byte   $FF                             ; 86E0
        .byte   $FF                             ; 86E1
        .byte   $FF                             ; 86E2
        .byte   $FF                             ; 86E3
        .byte   $FF                             ; 86E4
        .byte   $FF                             ; 86E5
        .byte   $FF                             ; 86E6
        .byte   $FF                             ; 86E7
        .byte   $FF                             ; 86E8
        .byte   $FF                             ; 86E9
        .byte   $FF                             ; 86EA
        .byte   $FF                             ; 86EB
        .byte   $FF                             ; 86EC
        .byte   $FF                             ; 86ED
        .byte   $FF                             ; 86EE
        .byte   $FF                             ; 86EF
        .byte   $FF                             ; 86F0
        .byte   $FF                             ; 86F1
        .byte   $FF                             ; 86F2
        .byte   $FF                             ; 86F3
        .byte   $FF                             ; 86F4
        .byte   $FF                             ; 86F5
        .byte   $FF                             ; 86F6
        .byte   $FF                             ; 86F7
        .byte   $F3                             ; 86F8
        .byte   $F3                             ; 86F9
        .byte   $F4                             ; 86FA
        .byte   $FF                             ; 86FB
        .byte   $FF                             ; 86FC
        .byte   $FF                             ; 86FD
        .byte   $FF                             ; 86FE
        .byte   $FF                             ; 86FF
        .byte   $FF                             ; 8700
        asl     $FFFF                           ; 8701
        .byte   $FF                             ; 8704
        .byte   $FF                             ; 8705
        .byte   $FF                             ; 8706
        .byte   $FF                             ; 8707
        .byte   $FF                             ; 8708
        .byte   $FF                             ; 8709
        .byte   $FF                             ; 870A
        .byte   $FF                             ; 870B
        .byte   $FF                             ; 870C
        .byte   $FF                             ; 870D
        .byte   $FF                             ; 870E
        .byte   $FF                             ; 870F
        .byte   $FF                             ; 8710
        .byte   $FF                             ; 8711
        .byte   $FF                             ; 8712
        .byte   $FF                             ; 8713
        .byte   $FF                             ; 8714
        .byte   $FF                             ; 8715
        .byte   $FF                             ; 8716
        .byte   $FF                             ; 8717
        .byte   $FF                             ; 8718
        .byte   $FF                             ; 8719
        .byte   $FF                             ; 871A
        .byte   $FF                             ; 871B
        .byte   $FF                             ; 871C
        .byte   $FF                             ; 871D
        .byte   $FF                             ; 871E
        .byte   $FF                             ; 871F
        .byte   $FF                             ; 8720
        .byte   $FF                             ; 8721
        .byte   $FF                             ; 8722
        .byte   $F3                             ; 8723
        .byte   $F3                             ; 8724
        .byte   $F4                             ; 8725
        .byte   $FF                             ; 8726
        .byte   $FF                             ; 8727
        .byte   $FF                             ; 8728
        .byte   $FF                             ; 8729
        .byte   $FF                             ; 872A
        .byte   $FF                             ; 872B
        .byte   $0F                             ; 872C
        .byte   $FF                             ; 872D
        .byte   $FF                             ; 872E
        .byte   $FF                             ; 872F
        .byte   $FF                             ; 8730
        .byte   $1F                             ; 8731
        .byte   $FF                             ; 8732
        .byte   $FF                             ; 8733
        .byte   $1F                             ; 8734
        .byte   $FF                             ; 8735
        .byte   $FF                             ; 8736
        .byte   $FF                             ; 8737
        .byte   $FF                             ; 8738
        .byte   $FF                             ; 8739
        .byte   $1F                             ; 873A
        .byte   $1F                             ; 873B
        .byte   $1F                             ; 873C
        .byte   $1F                             ; 873D
        .byte   $FF                             ; 873E
        .byte   $FF                             ; 873F
        .byte   $FF                             ; 8740
        .byte   $FF                             ; 8741
        .byte   $FF                             ; 8742
        .byte   $FF                             ; 8743
        .byte   $FF                             ; 8744
        .byte   $FF                             ; 8745
        .byte   $FF                             ; 8746
        .byte   $FF                             ; 8747
        .byte   $FF                             ; 8748
        .byte   $FF                             ; 8749
        .byte   $FF                             ; 874A
        .byte   $FF                             ; 874B
        .byte   $FF                             ; 874C
        .byte   $FF                             ; 874D
        .byte   $F3                             ; 874E
        .byte   $F3                             ; 874F
        .byte   $F4                             ; 8750
        .byte   $FF                             ; 8751
        .byte   $FF                             ; 8752
        .byte   $FF                             ; 8753
        .byte   $FF                             ; 8754
        .byte   $1F                             ; 8755
        .byte   $FF                             ; 8756
        .byte   $10                             ; 8757
L8758:  .byte   $FF                             ; 8758
        .byte   $FF                             ; 8759
        .byte   $FF                             ; 875A
        .byte   $FF                             ; 875B
        .byte   $FF                             ; 875C
        .byte   $FF                             ; 875D
        .byte   $FF                             ; 875E
        .byte   $FF                             ; 875F
        inc     $FFFF,x                         ; 8760
        .byte   $FF                             ; 8763
        .byte   $FF                             ; 8764
        .byte   $FF                             ; 8765
        .byte   $FF                             ; 8766
        .byte   $FF                             ; 8767
        .byte   $FF                             ; 8768
        .byte   $FF                             ; 8769
        .byte   $FF                             ; 876A
        .byte   $1F                             ; 876B
        .byte   $1F                             ; 876C
        .byte   $1F                             ; 876D
        .byte   $FF                             ; 876E
        .byte   $FF                             ; 876F
        .byte   $FF                             ; 8770
        .byte   $FF                             ; 8771
        .byte   $FF                             ; 8772
        .byte   $FF                             ; 8773
        .byte   $FF                             ; 8774
        .byte   $FF                             ; 8775
        .byte   $FF                             ; 8776
        .byte   $FF                             ; 8777
        .byte   $FF                             ; 8778
        .byte   $F3                             ; 8779
        .byte   $F3                             ; 877A
        .byte   $F4                             ; 877B
        .byte   $FF                             ; 877C
        .byte   $FF                             ; 877D
        .byte   $FF                             ; 877E
        .byte   $1F                             ; 877F
        .byte   $FF                             ; 8780
        .byte   $FF                             ; 8781
        ora     ($FF),y                         ; 8782
        .byte   $FF                             ; 8784
        .byte   $FF                             ; 8785
        .byte   $FF                             ; 8786
        .byte   $1F                             ; 8787
        .byte   $FF                             ; 8788
        .byte   $FF                             ; 8789
        .byte   $1F                             ; 878A
        .byte   $FF                             ; 878B
        .byte   $FF                             ; 878C
        .byte   $FF                             ; 878D
        .byte   $FF                             ; 878E
        .byte   $FF                             ; 878F
        .byte   $1F                             ; 8790
        .byte   $1F                             ; 8791
        .byte   $1F                             ; 8792
        .byte   $1F                             ; 8793
        .byte   $FF                             ; 8794
        .byte   $FF                             ; 8795
        .byte   $FF                             ; 8796
        .byte   $FF                             ; 8797
        .byte   $FF                             ; 8798
        .byte   $FF                             ; 8799
        .byte   $FF                             ; 879A
        .byte   $FF                             ; 879B
        .byte   $FF                             ; 879C
        .byte   $FF                             ; 879D
        .byte   $FF                             ; 879E
        .byte   $FF                             ; 879F
L87A0:  .byte   $FF                             ; 87A0
        .byte   $FF                             ; 87A1
        .byte   $FF                             ; 87A2
        .byte   $FF                             ; 87A3
        .byte   $F3                             ; 87A4
L87A5:  .byte   $F3                             ; 87A5
        .byte   $F4                             ; 87A6
        .byte   $FF                             ; 87A7
L87A8:  .byte   $FF                             ; 87A8
        .byte   $FF                             ; 87A9
L87AA:  .byte   $FF                             ; 87AA
        .byte   $1F                             ; 87AB
        .byte   $FF                             ; 87AC
L87AD:  .byte   $12                             ; 87AD
        beq     L87A0                           ; 87AE
L87B0:  .byte   $F2                             ; 87B0
        .byte   $F0                             ; 87B1
L87B2:  .byte   $F2                             ; 87B2
        .byte   $FE                             ; 87B3
L87B4:  beq     L87A8                           ; 87B4
        beq     L87A8                           ; 87B6
        .byte   $F0                             ; 87B8
L87B9:  beq     *+1                             ; 87B9
L87BB:  beq     L87AD                           ; 87BB
L87BD:  .byte   $F3                             ; 87BD
        .byte   $F0                             ; 87BE
L87BF:  beq     *-14                            ; 87BF
L87C1:  beq     *-14                            ; 87C1
        beq     *+1                             ; 87C3
        .byte   $F0                             ; 87C5
L87C6:  .byte   $FF                             ; 87C6
        beq     L87B9                           ; 87C7
        beq     L87BB                           ; 87C9
        beq     L87BD                           ; 87CB
        .byte   $F0                             ; 87CD
L87CE:  beq     *-14                            ; 87CE
L87D0:  beq     *-11                            ; 87D0
        .byte   $FA                             ; 87D2
L87D3:  .byte   $FF                             ; 87D3
        .byte   $FA                             ; 87D4
L87D5:  .byte   $FF                             ; 87D5
        .byte   $FA                             ; 87D6
        .byte   $FF                             ; 87D7
L87D8:  ora     $F0,x                           ; 87D8
        .byte   $F0                             ; 87DA
L87DB:  .byte   $F2                             ; 87DB
        .byte   $F0                             ; 87DC
L87DD:  .byte   $F2                             ; 87DD
        .byte   $FE                             ; 87DE
L87DF:  beq     L87D3                           ; 87DF
        beq     L87D3                           ; 87E1
        .byte   $F0                             ; 87E3
L87E4:  beq     *+1                             ; 87E4
L87E6:  beq     L87D8                           ; 87E6
L87E8:  .byte   $F3                             ; 87E8
        .byte   $F0                             ; 87E9
L87EA:  beq     *-14                            ; 87EA
L87EC:  beq     *-14                            ; 87EC
        beq     *+1                             ; 87EE
        .byte   $F0                             ; 87F0
L87F1:  .byte   $FF                             ; 87F1
        beq     L87E4                           ; 87F2
        beq     L87E6                           ; 87F4
        beq     L87E8                           ; 87F6
        .byte   $F0                             ; 87F8
L87F9:  beq     *-14                            ; 87F9
L87FB:  beq     *-11                            ; 87FB
        .byte   $F0                             ; 87FD
L87FE:  .byte   $FF                             ; 87FE
        .byte   $F0                             ; 87FF
L8800:  .byte   $FF                             ; 8800
        .byte   $F0                             ; 8801
L8802:  .byte   $FF                             ; 8802
        and     ($F0,x)                         ; 8803
        beq     L87F9                           ; 8805
        beq     L87FB                           ; 8807
        inc     $F2F0,x                         ; 8809
        beq     L87FE                           ; 880C
        beq     L8800                           ; 880E
        .byte   $FF                             ; 8810
        .byte   $FF                             ; 8811
        .byte   $FF                             ; 8812
        .byte   $FF                             ; 8813
        .byte   $FF                             ; 8814
        .byte   $FF                             ; 8815
        .byte   $FF                             ; 8816
        .byte   $FF                             ; 8817
        .byte   $FF                             ; 8818
        .byte   $FF                             ; 8819
        .byte   $FF                             ; 881A
        .byte   $FF                             ; 881B
        .byte   $FF                             ; 881C
        .byte   $FA                             ; 881D
        .byte   $FA                             ; 881E
        .byte   $FA                             ; 881F
        .byte   $FF                             ; 8820
        .byte   $FF                             ; 8821
        .byte   $FF                             ; 8822
        .byte   $FF                             ; 8823
        .byte   $FF                             ; 8824
        .byte   $FF                             ; 8825
        .byte   $FF                             ; 8826
        .byte   $FF                             ; 8827
        .byte   $FF                             ; 8828
        .byte   $FF                             ; 8829
        .byte   $FF                             ; 882A
        .byte   $FF                             ; 882B
        .byte   $FF                             ; 882C
        .byte   $FF                             ; 882D
L882E:  .byte   $14                             ; 882E
        .byte   $FF                             ; 882F
        .byte   $FF                             ; 8830
L8831:  .byte   $FF                             ; 8831
        .byte   $FF                             ; 8832
L8833:  .byte   $FF                             ; 8833
        .byte   $FE                             ; 8834
L8835:  .byte   $FF                             ; 8835
        .byte   $FF                             ; 8836
        .byte   $FF                             ; 8837
        .byte   $FF                             ; 8838
        .byte   $FF                             ; 8839
        .byte   $FF                             ; 883A
        .byte   $FF                             ; 883B
        beq     L882E                           ; 883C
        .byte   $F3                             ; 883E
        beq     L8831                           ; 883F
        .byte   $F0                             ; 8841
L8842:  beq     *-14                            ; 8842
        beq     *+1                             ; 8844
        .byte   $F0                             ; 8846
L8847:  .byte   $FF                             ; 8847
        .byte   $F3                             ; 8848
        .byte   $F3                             ; 8849
        .byte   $F3                             ; 884A
        .byte   $F3                             ; 884B
L884C:  .byte   $F3                             ; 884C
        .byte   $F3                             ; 884D
        .byte   $F3                             ; 884E
        .byte   $F3                             ; 884F
        .byte   $F0                             ; 8850
L8851:  beq     *-11                            ; 8851
        .byte   $FA                             ; 8853
L8854:  .byte   $FF                             ; 8854
        .byte   $FA                             ; 8855
L8856:  .byte   $FF                             ; 8856
        .byte   $FA                             ; 8857
        .byte   $FF                             ; 8858
L8859:  .byte   $13                             ; 8859
        beq     L884C                           ; 885A
L885C:  .byte   $F2                             ; 885C
        .byte   $F0                             ; 885D
L885E:  .byte   $F2                             ; 885E
        .byte   $FE                             ; 885F
L8860:  beq     L8854                           ; 8860
        beq     L8854                           ; 8862
        .byte   $F0                             ; 8864
L8865:  beq     *+1                             ; 8865
L8867:  beq     L8859                           ; 8867
L8869:  .byte   $F3                             ; 8869
        .byte   $F0                             ; 886A
L886B:  beq     *-14                            ; 886B
L886D:  beq     *-14                            ; 886D
L886F:  beq     *+1                             ; 886F
        .byte   $F0                             ; 8871
L8872:  .byte   $FF                             ; 8872
        beq     L8865                           ; 8873
        beq     L8867                           ; 8875
        beq     L8869                           ; 8877
        beq     L886B                           ; 8879
        beq     L886D                           ; 887B
        beq     L886F                           ; 887D
        .byte   $FF                             ; 887F
        .byte   $F0                             ; 8880
L8881:  .byte   $FF                             ; 8881
        .byte   $F0                             ; 8882
L8883:  .byte   $FF                             ; 8883
L8884:  rol     $FF                             ; 8884
        .byte   $FF                             ; 8886
        .byte   $FF                             ; 8887
        .byte   $FF                             ; 8888
        .byte   $FF                             ; 8889
        .byte   $FF                             ; 888A
        .byte   $FF                             ; 888B
        .byte   $FF                             ; 888C
        .byte   $FF                             ; 888D
        .byte   $FF                             ; 888E
        .byte   $FF                             ; 888F
        .byte   $FF                             ; 8890
        .byte   $FF                             ; 8891
        beq     L8884                           ; 8892
        .byte   $FF                             ; 8894
        .byte   $F0                             ; 8895
L8896:  .byte   $FF                             ; 8896
        .byte   $FF                             ; 8897
        .byte   $FF                             ; 8898
        .byte   $FF                             ; 8899
        .byte   $FF                             ; 889A
        .byte   $FF                             ; 889B
        .byte   $FF                             ; 889C
        .byte   $FF                             ; 889D
        .byte   $FF                             ; 889E
        .byte   $FF                             ; 889F
        .byte   $FF                             ; 88A0
        .byte   $0F                             ; 88A1
        .byte   $0F                             ; 88A2
        .byte   $FF                             ; 88A3
        .byte   $FF                             ; 88A4
        .byte   $FF                             ; 88A5
        .byte   $FF                             ; 88A6
        .byte   $FF                             ; 88A7
        .byte   $FF                             ; 88A8
        .byte   $FF                             ; 88A9
        .byte   $FF                             ; 88AA
        .byte   $FF                             ; 88AB
        .byte   $FF                             ; 88AC
        .byte   $FF                             ; 88AD
        .byte   $FF                             ; 88AE
        bit     $FF                             ; 88AF
        .byte   $FF                             ; 88B1
        .byte   $FF                             ; 88B2
        .byte   $FF                             ; 88B3
        .byte   $FF                             ; 88B4
        .byte   $FF                             ; 88B5
        .byte   $FF                             ; 88B6
        .byte   $FF                             ; 88B7
        .byte   $FF                             ; 88B8
        .byte   $FF                             ; 88B9
        .byte   $FF                             ; 88BA
        .byte   $FF                             ; 88BB
        .byte   $FF                             ; 88BC
        .byte   $FF                             ; 88BD
        .byte   $FF                             ; 88BE
        .byte   $FF                             ; 88BF
        .byte   $FF                             ; 88C0
        .byte   $FF                             ; 88C1
        .byte   $FF                             ; 88C2
        .byte   $FF                             ; 88C3
        .byte   $FF                             ; 88C4
        .byte   $FF                             ; 88C5
        .byte   $FF                             ; 88C6
        .byte   $FF                             ; 88C7
        .byte   $FF                             ; 88C8
        .byte   $FF                             ; 88C9
        .byte   $FF                             ; 88CA
        .byte   $FF                             ; 88CB
        .byte   $0F                             ; 88CC
        .byte   $0F                             ; 88CD
        .byte   $FF                             ; 88CE
        .byte   $FF                             ; 88CF
        .byte   $FF                             ; 88D0
        .byte   $FF                             ; 88D1
        .byte   $FF                             ; 88D2
        .byte   $FF                             ; 88D3
        .byte   $FF                             ; 88D4
        .byte   $FF                             ; 88D5
        .byte   $FF                             ; 88D6
        .byte   $FF                             ; 88D7
        .byte   $FF                             ; 88D8
        .byte   $FF                             ; 88D9
        .byte   $23                             ; 88DA
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
        .byte   $0F                             ; 88F7
        .byte   $0F                             ; 88F8
        .byte   $FF                             ; 88F9
        .byte   $FF                             ; 88FA
        .byte   $FF                             ; 88FB
        .byte   $FF                             ; 88FC
        .byte   $FF                             ; 88FD
        .byte   $FF                             ; 88FE
        .byte   $FF                             ; 88FF
        .byte   $FF                             ; 8900
        .byte   $FF                             ; 8901
        .byte   $FF                             ; 8902
        .byte   $FF                             ; 8903
        .byte   $FF                             ; 8904
        ora     ($F2,x)                         ; 8905
        .byte   $F3                             ; 8907
        .byte   $FA                             ; 8908
        .byte   $FA                             ; 8909
        .byte   $F3                             ; 890A
        inc     $F3F2,x                         ; 890B
        .byte   $FA                             ; 890E
        .byte   $F3                             ; 890F
        .byte   $F3                             ; 8910
        .byte   $F3                             ; 8911
        .byte   $F2                             ; 8912
        .byte   $F2                             ; 8913
        .byte   $F2                             ; 8914
        .byte   $F2                             ; 8915
        .byte   $F2                             ; 8916
        .byte   $FA                             ; 8917
        .byte   $FA                             ; 8918
        .byte   $F3                             ; 8919
        .byte   $F2                             ; 891A
        .byte   $F2                             ; 891B
        .byte   $F2                             ; 891C
        .byte   $F2                             ; 891D
        .byte   $F2                             ; 891E
        .byte   $F3                             ; 891F
        .byte   $F3                             ; 8920
        .byte   $F3                             ; 8921
        .byte   $F2                             ; 8922
        .byte   $F2                             ; 8923
        .byte   $F2                             ; 8924
        .byte   $F2                             ; 8925
        .byte   $F2                             ; 8926
L8927:  .byte   $F3                             ; 8927
        .byte   $F3                             ; 8928
L8929:  .byte   $F3                             ; 8929
        .byte   $FA                             ; 892A
        .byte   $FF                             ; 892B
        .byte   $FA                             ; 892C
        .byte   $FF                             ; 892D
        .byte   $FA                             ; 892E
        .byte   $FF                             ; 892F
        .byte   $03                             ; 8930
        .byte   $F2                             ; 8931
        beq     L8927                           ; 8932
        .byte   $F3                             ; 8934
L8935:  .byte   $F0                             ; 8935
L8936:  inc     $F0F0,x                         ; 8936
        .byte   $F3                             ; 8939
        .byte   $F3                             ; 893A
        .byte   $F3                             ; 893B
        .byte   $FF                             ; 893C
        .byte   $F2                             ; 893D
        .byte   $FA                             ; 893E
        .byte   $FA                             ; 893F
        .byte   $FA                             ; 8940
        beq     L8936                           ; 8941
        .byte   $F3                             ; 8943
        .byte   $F2                             ; 8944
        .byte   $F3                             ; 8945
        .byte   $F3                             ; 8946
        .byte   $F3                             ; 8947
        .byte   $F2                             ; 8948
        .byte   $F2                             ; 8949
        .byte   $F3                             ; 894A
        .byte   $F3                             ; 894B
        .byte   $F3                             ; 894C
        .byte   $F2                             ; 894D
        .byte   $F2                             ; 894E
        .byte   $F2                             ; 894F
        .byte   $F2                             ; 8950
        .byte   $F2                             ; 8951
        .byte   $F3                             ; 8952
        .byte   $F3                             ; 8953
        .byte   $F3                             ; 8954
        .byte   $FA                             ; 8955
        .byte   $FF                             ; 8956
        .byte   $FA                             ; 8957
        .byte   $FF                             ; 8958
        .byte   $FA                             ; 8959
        .byte   $FF                             ; 895A
        ora     ($01,x)                         ; 895B
        ora     ($02,x)                         ; 895D
        ora     ($02,x)                         ; 895F
        ora     ($02,x)                         ; 8961
        ora     ($02,x)                         ; 8963
        ora     ($02,x)                         ; 8965
        ora     ($02,x)                         ; 8967
        ora     ($03,x)                         ; 8969
        .byte   $02                             ; 896B
        .byte   $03                             ; 896C
        .byte   $02                             ; 896D
        .byte   $04                             ; 896E
        .byte   $02                             ; 896F
        .byte   $04                             ; 8970
        .byte   $03                             ; 8971
        .byte   $04                             ; 8972
        .byte   $03                             ; 8973
        ora     $04                             ; 8974
        asl     $04                             ; 8976
        asl     $05                             ; 8978
        asl     $05                             ; 897A
        .byte   $07                             ; 897C
        asl     $08                             ; 897D
        asl     $0A                             ; 897F
        .byte   $07                             ; 8981
        asl     a                               ; 8982
        .byte   $07                             ; 8983
        asl     a                               ; 8984
        php                                     ; 8985
        .byte   $0C                             ; 8986
        php                                     ; 8987
        .byte   $0C                             ; 8988
        asl     a                               ; 8989
        asl     $0F0A                           ; 898A
        .byte   $0C                             ; 898D
        bpl     L899C                           ; 898E
        .byte   $12                             ; 8990
        asl     $1012                           ; 8991
        .byte   $12                             ; 8994
        bpl     L89A9                           ; 8995
        .byte   $02                             ; 8997
        .byte   $04                             ; 8998
        php                                     ; 8999
        .byte   $0C                             ; 899A
        .byte   $10                             ; 899B
L899C:  ora     $1E10                           ; 899C
        and     ($01,x)                         ; 899F
        brk                                     ; 89A1
        ora     $1C10                           ; 89A2
        asl     a:$02,x                         ; 89A5
        .byte   $14                             ; 89A8
L89A9:  ora     $211E,y                         ; 89A9
        .byte   $03                             ; 89AC
        brk                                     ; 89AD
        .byte   $14                             ; 89AE
        ora     $1E1C,y                         ; 89AF
        .byte   $04                             ; 89B2
        brk                                     ; 89B3
        ora     ($14),y                         ; 89B4
        asl     $0521,x                         ; 89B6
        brk                                     ; 89B9
        ora     ($14),y                         ; 89BA
        .byte   $1C                             ; 89BC
        asl     a:$06,x                         ; 89BD
        brk                                     ; 89C0
        ora     ($0A,x)                         ; 89C1
        ora     (L0000,x)                       ; 89C3
        brk                                     ; 89C5
        .byte   $04                             ; 89C6
        asl     $02                             ; 89C7
        brk                                     ; 89C9
        brk                                     ; 89CA
        .byte   $03                             ; 89CB
        ora     #$03                            ; 89CC
        brk                                     ; 89CE
        brk                                     ; 89CF
        asl     a                               ; 89D0
        .byte   $0B                             ; 89D1
        .byte   $04                             ; 89D2
        brk                                     ; 89D3
        brk                                     ; 89D4
        .byte   $07                             ; 89D5
        .byte   $02                             ; 89D6
        ora     L0000                           ; 89D7
        brk                                     ; 89D9
        ora     $08                             ; 89DA
        asl     L0000                           ; 89DC
        bpl     L89F0                           ; 89DE
        bpl     L89F2                           ; 89E0
        bpl     L89F4                           ; 89E2
        bpl     L8A16                           ; 89E4
        bpl     L89F8                           ; 89E6
        bpl     L89FA                           ; 89E8
        bpl     L89FC                           ; 89EA
        bpl     L89FE                           ; 89EC
        bpl     L8A00                           ; 89EE
L89F0:  bmi     L8A22                           ; 89F0
L89F2:  bmi     L8A24                           ; 89F2
L89F4:  bmi     L8A26                           ; 89F4
        bpl     L8A08                           ; 89F6
L89F8:  bmi     L8A0A                           ; 89F8
L89FA:  bpl     L8A0C                           ; 89FA
L89FC:  bpl     L8A0E                           ; 89FC
L89FE:  bpl     L8A30                           ; 89FE
L8A00:  bpl     L8A12                           ; 8A00
        bpl     L8A14                           ; 8A02
        bpl     L8A16                           ; 8A04
L8A06:  bpl     L8A18                           ; 8A06
L8A08:  .byte   $20                             ; 8A08
        .byte   $10                             ; 8A09
L8A0A:  .byte   $20                             ; 8A0A
        .byte   $20                             ; 8A0B
L8A0C:  .byte   $20                             ; 8A0C
        .byte   $30                             ; 8A0D
L8A0E:  bpl     L8A20                           ; 8A0E
        bpl     L8A22                           ; 8A10
L8A12:  bpl     L8A24                           ; 8A12
L8A14:  .byte   $20                             ; 8A14
        .byte   $20                             ; 8A15
L8A16:  .byte   $20                             ; 8A16
        .byte   $20                             ; 8A17
L8A18:  jsr     L1020                           ; 8A18
        jsr     L2030                           ; 8A1B
        .byte   $20                             ; 8A1E
        .byte   $20                             ; 8A1F
L8A20:  .byte   $20                             ; 8A20
        .byte   $30                             ; 8A21
L8A22:  .byte   $20                             ; 8A22
L8A23:  .byte   $10                             ; 8A23
L8A24:  .byte   $20                             ; 8A24
        .byte   $20                             ; 8A25
L8A26:  dey                                     ; 8A26
        .byte   $89                             ; 8A27
        txa                                     ; 8A28
        txa                                     ; 8A29
        sta     $86                             ; 8A2A
        .byte   $87                             ; 8A2C
        .byte   $8B                             ; 8A2D
        .byte   $8C                             ; 8A2E
        .byte   $A1                             ; 8A2F
L8A30:  sta     $C8A1                           ; 8A30
        bne     L8A06                           ; 8A33
        .byte   $D4                             ; 8A35
        iny                                     ; 8A36
        .byte   $D2                             ; 8A37
        .byte   $D3                             ; 8A38
        dec     $CE,x                           ; 8A39
        .byte   $CF                             ; 8A3B
        cmp     $94,x                           ; 8A3C
        dey                                     ; 8A3E
        .byte   $C3                             ; 8A3F
        cpy     $C3                             ; 8A40
        cpy     $C8                             ; 8A42
        cmp     #$CA                            ; 8A44
        txa                                     ; 8A46
        sta     $86                             ; 8A47
        .byte   $87                             ; 8A49
        .byte   $8B                             ; 8A4A
        sty     L8DA1                           ; 8A4B
        lda     ($C8,x)                         ; 8A4E
        bne     L8A23                           ; 8A50
        .byte   $D4                             ; 8A52
        iny                                     ; 8A53
        .byte   $D2                             ; 8A54
        .byte   $D3                             ; 8A55
        dec     $CE,x                           ; 8A56
        .byte   $CF                             ; 8A58
        cmp     $94,x                           ; 8A59
        dey                                     ; 8A5B
        .byte   $C3                             ; 8A5C
        cpy     $C3                             ; 8A5D
        cpy     $27                             ; 8A5F
        jsr     L2711                           ; 8A61
        jsr     L2714                           ; 8A64
        jsr     L2516                           ; 8A67
        jsr     L2816                           ; 8A6A
        jsr     L2817                           ; 8A6D
        jsr     L2714                           ; 8A70
        .byte   $37                             ; 8A73
        .byte   $1C                             ; 8A74
        .byte   $26                             ; 8A75
L8A76:  sec                                     ; 8A76
        .byte   $16                             ; 8A77
L8A78:  .byte   $27                             ; 8A78
        .byte   $20                             ; 8A79
L8A7A:  .byte   $1A                             ; 8A7A
        plp                                     ; 8A7B
L8A7C:  .byte   $20                             ; 8A7C
        .byte   $14                             ; 8A7D
L8A7E:  rol     $31                             ; 8A7E
        .byte   $17                             ; 8A80
        rol     $20                             ; 8A81
        asl     $17,x                           ; 8A83
        jsr     L2714                           ; 8A85
        jsr     L261A                           ; 8A88
        jsr     L2316                           ; 8A8B
        .byte   $32                             ; 8A8E
        .byte   $12                             ; 8A8F
        rol     $20                             ; 8A90
        .byte   $13                             ; 8A92
        .byte   $23                             ; 8A93
        asl     $14,x                           ; 8A94
        ora     ($37),y                         ; 8A96
        rol     $1A                             ; 8A98
        jsr     L2C26                           ; 8A9A
        .byte   $37                             ; 8A9D
        asl     $24,x                           ; 8A9E
        sec                                     ; 8AA0
        bpl     L8AB9                           ; 8AA1
        sec                                     ; 8AA3
        .byte   $27                             ; 8AA4
        plp                                     ; 8AA5
        .byte   $0F                             ; 8AA6
        asl     $21,x                           ; 8AA7
        jsr     L1B03                           ; 8AA9
        jsr     L0F06                           ; 8AAC
        .byte   $0F                             ; 8AAF
        .byte   $0F                             ; 8AB0
        plp                                     ; 8AB1
        plp                                     ; 8AB2
        plp                                     ; 8AB3
        and     ($21,x)                         ; 8AB4
        and     ($20,x)                         ; 8AB6
        .byte   $20                             ; 8AB8
L8AB9:  jsr     L1616                           ; 8AB9
        asl     $27,x                           ; 8ABC
        jsr     L2716                           ; 8ABE
        sec                                     ; 8AC1
        .byte   $13                             ; 8AC2
        ora     ($11),y                         ; 8AC3
        ora     (L0000),y                       ; 8AC5
        brk                                     ; 8AC7
        brk                                     ; 8AC8
        brk                                     ; 8AC9
        brk                                     ; 8ACA
        brk                                     ; 8ACB
        brk                                     ; 8ACC
        brk                                     ; 8ACD
        brk                                     ; 8ACE
        brk                                     ; 8ACF
        brk                                     ; 8AD0
        brk                                     ; 8AD1
        brk                                     ; 8AD2
        brk                                     ; 8AD3
        brk                                     ; 8AD4
        brk                                     ; 8AD5
        brk                                     ; 8AD6
        brk                                     ; 8AD7
        brk                                     ; 8AD8
        brk                                     ; 8AD9
        brk                                     ; 8ADA
        ora     $8B,x                           ; 8ADB
        ora     $8B,x                           ; 8ADD
        ora     $8B,x                           ; 8ADF
        rol     $378B                           ; 8AE1
        .byte   $8B                             ; 8AE4
        .byte   $37                             ; 8AE5
        .byte   $8B                             ; 8AE6
        .byte   $37                             ; 8AE7
        .byte   $8B                             ; 8AE8
        bvc     L8A76                           ; 8AE9
        bvc     L8A78                           ; 8AEB
        bvc     L8A7A                           ; 8AED
        bvc     L8A7C                           ; 8AEF
        bvc     L8A7E                           ; 8AF1
        adc     $8B                             ; 8AF3
        adc     $8B                             ; 8AF5
        adc     $8B                             ; 8AF7
        ror     $7E8B,x                         ; 8AF9
        .byte   $8B                             ; 8AFC
        .byte   $93                             ; 8AFD
        .byte   $8B                             ; 8AFE
        .byte   $93                             ; 8AFF
        .byte   $8B                             ; 8B00
        .byte   $93                             ; 8B01
        .byte   $8B                             ; 8B02
        ldy     $8B                             ; 8B03
        .byte   $A4                             ; 8B05
L8B06:  .byte   $8B                             ; 8B06
        ldy     $8B                             ; 8B07
        lda     $B98B,y                         ; 8B09
        .byte   $8B                             ; 8B0C
        .byte   $C2                             ; 8B0D
        .byte   $8B                             ; 8B0E
        .byte   $C2                             ; 8B0F
        .byte   $8B                             ; 8B10
        .byte   $CF                             ; 8B11
        .byte   $8B                             ; 8B12
        .byte   $CF                             ; 8B13
        .byte   $8B                             ; 8B14
        asl     $2C                             ; 8B15
        bit     $0AD9                           ; 8B17
        .byte   $0B                             ; 8B1A
        bit     $D5D4                           ; 8B1B
        .byte   $D6                             ; 8B1E
L8B1F:  .byte   $D7                             ; 8B1F
        cld                                     ; 8B20
        bit     $E5E4                           ; 8B21
        inc     $E7                             ; 8B24
        inx                                     ; 8B26
        sbc     #$F4                            ; 8B27
        sbc     $F6,x                           ; 8B29
        .byte   $F7                             ; 8B2B
        sed                                     ; 8B2C
        sbc     $2C02,y                         ; 8B2D
        bit     $D3D2                           ; 8B30
        bne     L8B06                           ; 8B33
        bit     $062C                           ; 8B35
        ldy     $DCDB                           ; 8B38
        cmp     $DFDE,x                         ; 8B3B
        nop                                     ; 8B3E
        .byte   $EB                             ; 8B3F
        cpx     $EEED                           ; 8B40
        .byte   $EF                             ; 8B43
        .byte   $FA                             ; 8B44
        .byte   $FB                             ; 8B45
        .byte   $FC                             ; 8B46
        sbc     $FF2C,x                         ; 8B47
        bit     $2C2C                           ; 8B4A
        bit     $2C2C                           ; 8B4D
        ora     $A6                             ; 8B50
        .byte   $A7                             ; 8B52
        tay                                     ; 8B53
        lda     #$AA                            ; 8B54
        ldx     $B7,y                           ; 8B56
        clv                                     ; 8B58
        lda     $C6BA,y                         ; 8B59
        .byte   $C7                             ; 8B5C
        iny                                     ; 8B5D
        cmp     #$CA                            ; 8B5E
        bit     $2C2C                           ; 8B60
        bit     $062C                           ; 8B63
        ldy     #$A1                            ; 8B66
        ldx     #$A3                            ; 8B68
        ldy     $A5                             ; 8B6A
        bcs     L8B1F                           ; 8B6C
        .byte   $B2                             ; 8B6E
        .byte   $B3                             ; 8B6F
        ldy     $B5,x                           ; 8B70
        cpy     #$C1                            ; 8B72
        .byte   $C2                             ; 8B74
        .byte   $C3                             ; 8B75
        cpy     $C5                             ; 8B76
        bit     $2C2C                           ; 8B78
        bit     $2C2C                           ; 8B7B
        ora     $AF                             ; 8B7E
        bit     $FECB                           ; 8B80
        bit     L9BCC                           ; 8B83
        lda     $2CAE                           ; 8B86
        .byte   $2C                             ; 8B89
        .byte   $BB                             ; 8B8A
L8B8B:  lda     $BFBE,x                         ; 8B8B
        bit     $CD2C                           ; 8B8E
        dec     $04CF                           ; 8B91
        bit     $E2E1                           ; 8B94
        .byte   $E3                             ; 8B97
        beq     L8B8B                           ; 8B98
        .byte   $F2                             ; 8B9A
        .byte   $F3                             ; 8B9B
        .byte   $1A                             ; 8B9C
        .byte   $1B                             ; 8B9D
        .byte   $1C                             ; 8B9E
        ora     $0D0C,x                         ; 8B9F
        cpx     #$0F                            ; 8BA2
        ora     $2C                             ; 8BA4
        dey                                     ; 8BA6
        .byte   $89                             ; 8BA7
        txa                                     ; 8BA8
        .byte   $8B                             ; 8BA9
        bit     $98                             ; 8BAA
        sta     $2C9A,y                         ; 8BAC
        bit     $25                             ; 8BAF
        rol     $27                             ; 8BB1
        sta     $2C,x                           ; 8BB3
        ora     $16,x                           ; 8BB5
        .byte   $17                             ; 8BB7
        clc                                     ; 8BB8
        .byte   $02                             ; 8BB9
        .byte   $DA                             ; 8BBA
        ldy     L9796,x                         ; 8BBB
        stx     $87                             ; 8BBE
        bit     $032C                           ; 8BC0
        sta     ($82,x)                         ; 8BC3
        .byte   $83                             ; 8BC5
        sta     ($92),y                         ; 8BC6
        .byte   $93                             ; 8BC8
        .byte   $AB                             ; 8BC9
        .byte   $82                             ; 8BCA
        .byte   $83                             ; 8BCB
        bit     $2C2C                           ; 8BCC
        .byte   $03                             ; 8BCF
        bit     L9080                           ; 8BD0
        bit     L8584                           ; 8BD3
        bit     $1994                           ; 8BD6
        bit     $2C2C                           ; 8BD9
        .byte   $82                             ; 8BDC
        jsr     L2086                           ; 8BDD
        txa                                     ; 8BE0
        jsr     L208E                           ; 8BE1
        .byte   $92                             ; 8BE4
        jsr     L2096                           ; 8BE5
        txs                                     ; 8BE8
        jsr     L6B6B                           ; 8BE9
        .byte   $6B                             ; 8BEC
        .byte   $6B                             ; 8BED
        .byte   $6B                             ; 8BEE
        .byte   $6B                             ; 8BEF
        brk                                     ; 8BF0
        ror     a                               ; 8BF1
        ror     a                               ; 8BF2
        ror     a                               ; 8BF3
        .byte   $74                             ; 8BF4
        .byte   $74                             ; 8BF5
        .byte   $74                             ; 8BF6
        .byte   $74                             ; 8BF7
        .byte   $74                             ; 8BF8
        .byte   $74                             ; 8BF9
        .byte   $74                             ; 8BFA
        adc     #$2D                            ; 8BFB
        adc     #$69                            ; 8BFD
        adc     #$2D                            ; 8BFF
        bvs     L8C30                           ; 8C01
        ror     a                               ; 8C03
        and     $7000                           ; 8C04
        adc     #$6F                            ; 8C07
        adc     $712D                           ; 8C09
        brk                                     ; 8C0C
        brk                                     ; 8C0D
        brk                                     ; 8C0E
        brk                                     ; 8C0F
        .byte   $14                             ; 8C10
        asl     a                               ; 8C11
        ora     $1E0A,y                         ; 8C12
        asl     a                               ; 8C15
        .byte   $22                             ; 8C16
        asl     a                               ; 8C17
        rol     a                               ; 8C18
        .byte   $0C                             ; 8C19
        .byte   $32                             ; 8C1A
        bpl     L8C57                           ; 8C1B
        .byte   $14                             ; 8C1D
        .byte   $42                             ; 8C1E
        .byte   $34                             ; 8C1F
        lsr     a                               ; 8C20
        .byte   $44                             ; 8C21
        .byte   $52                             ; 8C22
        lsr     $545A                           ; 8C23
        .byte   $62                             ; 8C26
        lsr     $6474,x                         ; 8C27
        .byte   $7C                             ; 8C2A
        jmp     (L7384)                         ; 8C2B

; ----------------------------------------------------------------------------
        .byte   $8C                             ; 8C2E
        .byte   $94                             ; 8C2F
L8C30:  sty     $9B,x                           ; 8C30
        .byte   $9C                             ; 8C32
        lda     $A4                             ; 8C33
        ldy     $AC,x                           ; 8C35
        lda     $BEB4,y                         ; 8C37
        ldy     $C4C8,x                         ; 8C3A
        cpy     $D0CC                           ; 8C3D
        .byte   $D4                             ; 8C40
        .byte   $DA                             ; 8C41
        .byte   $DC                             ; 8C42
        .byte   $DC                             ; 8C43
        cpx     $E4                             ; 8C44
        cpx     $F4EC                           ; 8C46
        sbc     $FF,x                           ; 8C49
        .byte   $FF                             ; 8C4B
        ora     $0A                             ; 8C4C
        .byte   $0F                             ; 8C4E
        .byte   $14                             ; 8C4F
        ora     $0210,y                         ; 8C50
        ora     ($21,x)                         ; 8C53
        .byte   $04                             ; 8C55
        php                                     ; 8C56
L8C57:  bmi     L8C89                           ; 8C57
        ora     ($01,x)                         ; 8C59
        asl     $06                             ; 8C5B
        rol     a                               ; 8C5D
        .byte   $2F                             ; 8C5E
        ora     $2811                           ; 8C5F
        rol     $24                             ; 8C62
        and     ($32,x)                         ; 8C64
        plp                                     ; 8C66
        .byte   $14                             ; 8C67
        ora     $2B0D,y                         ; 8C68
        bmi     L8CA2                           ; 8C6B
        asl     $2912                           ; 8C6D
        rol     $1622                           ; 8C70
L8C73:  ora     $33,x                           ; 8C73
        rol     $2E3B                           ; 8C75
        bit     $3431                           ; 8C78
        and     $3A36,y                         ; 8C7B
        sec                                     ; 8C7E
        .byte   $37                             ; 8C7F
        .byte   $2E                             ; 8C80
        .byte   $15                             ; 8C81
L8C82:  .byte   $1A                             ; 8C82
        .byte   $23                             ; 8C83
        .byte   $23                             ; 8C84
L8C85:  .byte   $7C                             ; 8C85
L8C86:  cpy     #$B0                            ; 8C86
        .byte   $C0                             ; 8C88
L8C89:  bcs     L8C73                           ; 8C89
        pla                                     ; 8C8B
        clv                                     ; 8C8C
        pla                                     ; 8C8D
        iny                                     ; 8C8E
        pla                                     ; 8C8F
        cld                                     ; 8C90
        pla                                     ; 8C91
        inx                                     ; 8C92
        pha                                     ; 8C93
        .byte   $1C                             ; 8C94
        sec                                     ; 8C95
        .byte   $3C                             ; 8C96
        pha                                     ; 8C97
        .byte   $5C                             ; 8C98
        sec                                     ; 8C99
        .byte   $7C                             ; 8C9A
        pha                                     ; 8C9B
        .byte   $9C                             ; 8C9C
        sec                                     ; 8C9D
        ldy     $DC48,x                         ; 8C9E
        .byte   $05                             ; 8CA1
L8CA2:  .byte   $07                             ; 8CA2
        .byte   $04                             ; 8CA3
        .byte   $04                             ; 8CA4
        asl     $03                             ; 8CA5
        asl     $05                             ; 8CA7
        ora     $01                             ; 8CA9
        brk                                     ; 8CAB
        .byte   $B2                             ; 8CAC
L8CAD:  sty     L8CB5                           ; 8CAD
        ldy     $298C,x                         ; 8CB0
        .byte   $1E                             ; 8CB3
        .byte   $FF                             ; 8CB4
L8CB5:  rol     a                               ; 8CB5
        .byte   $07                             ; 8CB6
        .byte   $2B                             ; 8CB7
L8CB8:  .byte   $07                             ; 8CB8
        bit     $FF07                           ; 8CB9
        and     $2E0A                           ; 8CBC
L8CBF:  asl     a                               ; 8CBF
        .byte   $2F                             ; 8CC0
        asl     a                               ; 8CC1
        bmi     L8CCE                           ; 8CC2
        and     ($0A),y                         ; 8CC4
L8CC6:  .byte   $FF                             ; 8CC6
        .byte   $3B                             ; 8CC7
        sta     L8D4C                           ; 8CC8
        adc     #$8D                            ; 8CCB
L8CCD:  .byte   $7E                             ; 8CCD
L8CCE:  sta     L8DAF                           ; 8CCE
        cpx     #$8D                            ; 8CD1
        .byte   $F9                             ; 8CD3
L8CD4:  sta     $8E1A                           ; 8CD4
        .byte   $33                             ; 8CD7
        stx     $8E4C                           ; 8CD8
L8CDB:  adc     $8E                             ; 8CDB
        stx     $8E,y                           ; 8CDD
        .byte   $C7                             ; 8CDF
        .byte   $8E                             ; 8CE0
        cld                                     ; 8CE1
L8CE2:  stx     $8EE1                           ; 8CE2
        nop                                     ; 8CE5
        stx     L8EF3                           ; 8CE6
        sed                                     ; 8CE9
        stx     L8F01                           ; 8CEA
        asl     $8F                             ; 8CED
        .byte   $0B                             ; 8CEF
        .byte   $8F                             ; 8CF0
        bpl     L8C82                           ; 8CF1
        ora     $228F,y                         ; 8CF3
        .byte   $8F                             ; 8CF6
        .byte   $2B                             ; 8CF7
        .byte   $8F                             ; 8CF8
        .byte   $34                             ; 8CF9
        .byte   $8F                             ; 8CFA
        and     $428F,y                         ; 8CFB
        .byte   $8F                             ; 8CFE
        .byte   $4B                             ; 8CFF
        .byte   $8F                             ; 8D00
        .byte   $54                             ; 8D01
        .byte   $8F                             ; 8D02
        eor     $668F,x                         ; 8D03
        .byte   $8F                             ; 8D06
        .byte   $73                             ; 8D07
        .byte   $8F                             ; 8D08
        sei                                     ; 8D09
        .byte   $8F                             ; 8D0A
        adc     L828F,x                         ; 8D0B
        .byte   $8F                             ; 8D0E
        .byte   $87                             ; 8D0F
        .byte   $8F                             ; 8D10
        sty     L918F                           ; 8D11
        .byte   $8F                             ; 8D14
        stx     $8F,y                           ; 8D15
        .byte   $9B                             ; 8D17
        .byte   $8F                             ; 8D18
        ldy     $8F                             ; 8D19
        cmp     $8F                             ; 8D1B
        dec     $E78F                           ; 8D1D
        .byte   $8F                             ; 8D20
        .byte   $0C                             ; 8D21
        bcc     L8D41                           ; 8D22
        bcc     L8D5C                           ; 8D24
        bcc     L8D7F                           ; 8D26
        bcc     L8D9A                           ; 8D28
        bcc     L8CAD                           ; 8D2A
        bcc     L8CB8                           ; 8D2C
        bcc     L8CBF                           ; 8D2E
        bcc     L8CC6                           ; 8D30
        bcc     L8CCD                           ; 8D32
        bcc     L8CD4                           ; 8D34
        bcc     L8CDB                           ; 8D36
        bcc     L8CE2                           ; 8D38
        .byte   $90                             ; 8D3A
L8D3B:  .byte   $04                             ; 8D3B
        beq     L8D3F                           ; 8D3C
        brk                                     ; 8D3E
L8D3F:  sed                                     ; 8D3F
L8D40:  brk                                     ; 8D40
L8D41:  .byte   $03                             ; 8D41
        brk                                     ; 8D42
        sed                                     ; 8D43
        .byte   $F0                             ; 8D44
L8D45:  ora     (L0000),y                       ; 8D45
        brk                                     ; 8D47
        brk                                     ; 8D48
        .byte   $13                             ; 8D49
        brk                                     ; 8D4A
        brk                                     ; 8D4B
L8D4C:  .byte   $07                             ; 8D4C
        inx                                     ; 8D4D
        sta     $F000,y                         ; 8D4E
L8D51:  inx                                     ; 8D51
        .byte   $9B                             ; 8D52
        brk                                     ; 8D53
        sed                                     ; 8D54
        inx                                     ; 8D55
        .byte   $AB                             ; 8D56
L8D57:  brk                                     ; 8D57
        brk                                     ; 8D58
        inx                                     ; 8D59
        lda     #$00                            ; 8D5A
L8D5C:  php                                     ; 8D5C
        sed                                     ; 8D5D
        lda     $F000                           ; 8D5E
        sed                                     ; 8D61
        .byte   $BD                             ; 8D62
        brk                                     ; 8D63
L8D64:  sed                                     ; 8D64
        sed                                     ; 8D65
        .byte   $CD                             ; 8D66
        brk                                     ; 8D67
L8D68:  brk                                     ; 8D68
        ora     $E8                             ; 8D69
        lda     (L0000,x)                       ; 8D6B
        sed                                     ; 8D6D
        inx                                     ; 8D6E
        .byte   $B1                             ; 8D6F
L8D70:  brk                                     ; 8D70
L8D71:  brk                                     ; 8D71
        inx                                     ; 8D72
        cmp     (L0000,x)                       ; 8D73
        php                                     ; 8D75
        sed                                     ; 8D76
        .byte   $A3                             ; 8D77
        brk                                     ; 8D78
        sed                                     ; 8D79
        sed                                     ; 8D7A
        .byte   $B3                             ; 8D7B
L8D7C:  brk                                     ; 8D7C
        brk                                     ; 8D7D
        .byte   $0C                             ; 8D7E
L8D7F:  cpx     #$BF                            ; 8D7F
        rti                                     ; 8D81

; ----------------------------------------------------------------------------
        beq     L8D64                           ; 8D82
L8D84:  .byte   $AF                             ; 8D84
        rti                                     ; 8D85

; ----------------------------------------------------------------------------
        sed                                     ; 8D86
        cpx     #$AF                            ; 8D87
        brk                                     ; 8D89
        brk                                     ; 8D8A
        cpx     #$BF                            ; 8D8B
        brk                                     ; 8D8D
        php                                     ; 8D8E
        beq     L8D70                           ; 8D8F
        rti                                     ; 8D91

; ----------------------------------------------------------------------------
        beq     L8D84                           ; 8D92
        .byte   $CF                             ; 8D94
L8D95:  rti                                     ; 8D95

; ----------------------------------------------------------------------------
        sed                                     ; 8D96
        beq     L8D68                           ; 8D97
        brk                                     ; 8D99
L8D9A:  brk                                     ; 8D9A
        beq     L8D7C                           ; 8D9B
        brk                                     ; 8D9D
        php                                     ; 8D9E
        brk                                     ; 8D9F
L8DA0:  .byte   $FF                             ; 8DA0
L8DA1:  rti                                     ; 8DA1

; ----------------------------------------------------------------------------
        beq     L8DA4                           ; 8DA2
L8DA4:  .byte   $EF                             ; 8DA4
        rti                                     ; 8DA5

; ----------------------------------------------------------------------------
        sed                                     ; 8DA6
        brk                                     ; 8DA7
        .byte   $EF                             ; 8DA8
        brk                                     ; 8DA9
        brk                                     ; 8DAA
        brk                                     ; 8DAB
        .byte   $FF                             ; 8DAC
        brk                                     ; 8DAD
        php                                     ; 8DAE
L8DAF:  .byte   $0C                             ; 8DAF
        cpx     #$81                            ; 8DB0
        brk                                     ; 8DB2
        beq     L8D95                           ; 8DB3
L8DB5:  sta     (L0000),y                       ; 8DB5
        sed                                     ; 8DB7
        cpx     #$A5                            ; 8DB8
        brk                                     ; 8DBA
        brk                                     ; 8DBB
        cpx     #$81                            ; 8DBC
        rti                                     ; 8DBE

; ----------------------------------------------------------------------------
        php                                     ; 8DBF
        beq     L8D45                           ; 8DC0
        brk                                     ; 8DC2
        beq     L8DB5                           ; 8DC3
        .byte   $93                             ; 8DC5
        brk                                     ; 8DC6
        sed                                     ; 8DC7
        beq     L8D71                           ; 8DC8
        brk                                     ; 8DCA
        brk                                     ; 8DCB
        beq     L8D51                           ; 8DCC
        rti                                     ; 8DCE

; ----------------------------------------------------------------------------
        php                                     ; 8DCF
        brk                                     ; 8DD0
        lda     L0000,x                         ; 8DD1
        beq     L8DD5                           ; 8DD3
L8DD5:  sta     L0000,x                         ; 8DD5
        sed                                     ; 8DD7
        brk                                     ; 8DD8
        sta     $40,x                           ; 8DD9
        brk                                     ; 8DDB
        brk                                     ; 8DDC
        .byte   $B5                             ; 8DDD
L8DDE:  rti                                     ; 8DDE

; ----------------------------------------------------------------------------
        php                                     ; 8DDF
        asl     $E8                             ; 8DE0
        .byte   $BB                             ; 8DE2
        brk                                     ; 8DE3
        sed                                     ; 8DE4
        inx                                     ; 8DE5
        .byte   $CB                             ; 8DE6
        brk                                     ; 8DE7
        brk                                     ; 8DE8
        beq     L8DA0                           ; 8DE9
        brk                                     ; 8DEB
        .byte   $F0                             ; 8DEC
L8DED:  beq     L8DA4                           ; 8DED
        rti                                     ; 8DEF

; ----------------------------------------------------------------------------
        php                                     ; 8DF0
        sed                                     ; 8DF1
        cmp     #$40                            ; 8DF2
        sed                                     ; 8DF4
        sed                                     ; 8DF5
        .byte   $C9                             ; 8DF6
L8DF7:  brk                                     ; 8DF7
        brk                                     ; 8DF8
L8DF9:  php                                     ; 8DF9
        cpx     #$87                            ; 8DFA
        rti                                     ; 8DFC

; ----------------------------------------------------------------------------
        sed                                     ; 8DFD
        cpx     #$87                            ; 8DFE
        brk                                     ; 8E00
        brk                                     ; 8E01
        beq     L8DED                           ; 8E02
        rti                                     ; 8E04

; ----------------------------------------------------------------------------
        beq     L8DF7                           ; 8E05
        .byte   $89                             ; 8E07
        rti                                     ; 8E08

; ----------------------------------------------------------------------------
        sed                                     ; 8E09
        beq     L8D95                           ; 8E0A
        brk                                     ; 8E0C
        brk                                     ; 8E0D
        beq     L8DF9                           ; 8E0E
        brk                                     ; 8E10
        php                                     ; 8E11
        brk                                     ; 8E12
        .byte   $8B                             ; 8E13
        rti                                     ; 8E14

; ----------------------------------------------------------------------------
        sed                                     ; 8E15
        brk                                     ; 8E16
        .byte   $8B                             ; 8E17
        brk                                     ; 8E18
        brk                                     ; 8E19
        asl     $E8                             ; 8E1A
        .byte   $D7                             ; 8E1C
        rti                                     ; 8E1D

; ----------------------------------------------------------------------------
        sed                                     ; 8E1E
        inx                                     ; 8E1F
L8E20:  .byte   $D7                             ; 8E20
        brk                                     ; 8E21
        brk                                     ; 8E22
        sed                                     ; 8E23
        lda     L0000,x                         ; 8E24
        beq     L8E20                           ; 8E26
        cmp     $F840,y                         ; 8E28
        sed                                     ; 8E2B
        cmp     L0000,y                         ; 8E2C
        sed                                     ; 8E2F
        lda     $40,x                           ; 8E30
        php                                     ; 8E32
L8E33:  asl     $E8                             ; 8E33
        .byte   $EB                             ; 8E35
        rti                                     ; 8E36

; ----------------------------------------------------------------------------
        sed                                     ; 8E37
        inx                                     ; 8E38
        .byte   $EB                             ; 8E39
L8E3A:  brk                                     ; 8E3A
        brk                                     ; 8E3B
        sed                                     ; 8E3C
        cmp     $F040,x                         ; 8E3D
        sed                                     ; 8E40
        .byte   $DB                             ; 8E41
        rti                                     ; 8E42

; ----------------------------------------------------------------------------
        sed                                     ; 8E43
        sed                                     ; 8E44
        .byte   $DB                             ; 8E45
        brk                                     ; 8E46
        brk                                     ; 8E47
        sed                                     ; 8E48
        .byte   $DD                             ; 8E49
        brk                                     ; 8E4A
L8E4B:  php                                     ; 8E4B
        asl     $E8                             ; 8E4C
        .byte   $C7                             ; 8E4E
        rti                                     ; 8E4F

; ----------------------------------------------------------------------------
        beq     L8E3A                           ; 8E50
        .byte   $B7                             ; 8E52
L8E53:  rti                                     ; 8E53

; ----------------------------------------------------------------------------
        sed                                     ; 8E54
        inx                                     ; 8E55
        .byte   $B7                             ; 8E56
        brk                                     ; 8E57
        brk                                     ; 8E58
        inx                                     ; 8E59
        .byte   $C7                             ; 8E5A
        brk                                     ; 8E5B
        php                                     ; 8E5C
        sed                                     ; 8E5D
        lda     $F840,y                         ; 8E5E
        sed                                     ; 8E61
        lda     L0000,y                         ; 8E62
        .byte   $0C                             ; 8E65
        cpx     #$F1                            ; 8E66
        rti                                     ; 8E68

; ----------------------------------------------------------------------------
        beq     L8E4B                           ; 8E69
L8E6B:  cmp     ($40),y                         ; 8E6B
        sed                                     ; 8E6D
        cpx     #$D1                            ; 8E6E
        brk                                     ; 8E70
        brk                                     ; 8E71
        cpx     #$F1                            ; 8E72
        brk                                     ; 8E74
        php                                     ; 8E75
        .byte   $F0                             ; 8E76
L8E77:  .byte   $F3                             ; 8E77
        rti                                     ; 8E78

; ----------------------------------------------------------------------------
        beq     L8E6B                           ; 8E79
        .byte   $D3                             ; 8E7B
L8E7C:  rti                                     ; 8E7C

; ----------------------------------------------------------------------------
        sed                                     ; 8E7D
        beq     L8E53                           ; 8E7E
        brk                                     ; 8E80
        brk                                     ; 8E81
        beq     L8E77                           ; 8E82
        brk                                     ; 8E84
        php                                     ; 8E85
        brk                                     ; 8E86
        cmp     L0000                           ; 8E87
        beq     L8E8B                           ; 8E89
L8E8B:  cmp     L0000,x                         ; 8E8B
        sed                                     ; 8E8D
        brk                                     ; 8E8E
        sbc     L0000                           ; 8E8F
        brk                                     ; 8E91
        brk                                     ; 8E92
        .byte   $F5                             ; 8E93
L8E94:  brk                                     ; 8E94
        php                                     ; 8E95
L8E96:  .byte   $0C                             ; 8E96
        cpx     #$F1                            ; 8E97
        rti                                     ; 8E99

; ----------------------------------------------------------------------------
        beq     L8E7C                           ; 8E9A
L8E9C:  sbc     ($40,x)                         ; 8E9C
        sed                                     ; 8E9E
        cpx     #$E1                            ; 8E9F
        brk                                     ; 8EA1
        brk                                     ; 8EA2
        cpx     #$F1                            ; 8EA3
        brk                                     ; 8EA5
        php                                     ; 8EA6
        .byte   $F0                             ; 8EA7
L8EA8:  .byte   $F3                             ; 8EA8
        rti                                     ; 8EA9

; ----------------------------------------------------------------------------
        beq     L8E9C                           ; 8EAA
        .byte   $E3                             ; 8EAC
        rti                                     ; 8EAD

; ----------------------------------------------------------------------------
        sed                                     ; 8EAE
        beq     L8E94                           ; 8EAF
        brk                                     ; 8EB1
        brk                                     ; 8EB2
        beq     L8EA8                           ; 8EB3
        brk                                     ; 8EB5
        php                                     ; 8EB6
        brk                                     ; 8EB7
        cmp     L0000                           ; 8EB8
        beq     L8EBC                           ; 8EBA
L8EBC:  cmp     L0000,x                         ; 8EBC
        sed                                     ; 8EBE
        brk                                     ; 8EBF
        sbc     L0000                           ; 8EC0
        brk                                     ; 8EC2
        brk                                     ; 8EC3
        sbc     L0000,x                         ; 8EC4
        php                                     ; 8EC6
        .byte   $04                             ; 8EC7
        beq     L8F0F                           ; 8EC8
        brk                                     ; 8ECA
        sed                                     ; 8ECB
        beq     L8F13                           ; 8ECC
        rti                                     ; 8ECE

; ----------------------------------------------------------------------------
        brk                                     ; 8ECF
        brk                                     ; 8ED0
        lsr     L0000                           ; 8ED1
        sed                                     ; 8ED3
        brk                                     ; 8ED4
        .byte   $47                             ; 8ED5
        rti                                     ; 8ED6

; ----------------------------------------------------------------------------
        brk                                     ; 8ED7
L8ED8:  .byte   $02                             ; 8ED8
        sed                                     ; 8ED9
        .byte   $7F                             ; 8EDA
        ora     ($F8,x)                         ; 8EDB
        sed                                     ; 8EDD
        .byte   $7F                             ; 8EDE
        eor     (L0000,x)                       ; 8EDF
        .byte   $02                             ; 8EE1
        sed                                     ; 8EE2
        .byte   $6F                             ; 8EE3
        .byte   $03                             ; 8EE4
        sed                                     ; 8EE5
        sed                                     ; 8EE6
        .byte   $6F                             ; 8EE7
        .byte   $43                             ; 8EE8
        brk                                     ; 8EE9
        .byte   $02                             ; 8EEA
        sed                                     ; 8EEB
        eor     ($01),y                         ; 8EEC
        sed                                     ; 8EEE
        sed                                     ; 8EEF
        eor     ($41),y                         ; 8EF0
        brk                                     ; 8EF2
L8EF3:  ora     ($F8,x)                         ; 8EF3
        .byte   $4B                             ; 8EF5
        ora     ($FC,x)                         ; 8EF6
        .byte   $02                             ; 8EF8
        sed                                     ; 8EF9
        .byte   $37                             ; 8EFA
        .byte   $03                             ; 8EFB
        sed                                     ; 8EFC
        sed                                     ; 8EFD
        .byte   $37                             ; 8EFE
        .byte   $43                             ; 8EFF
        brk                                     ; 8F00
L8F01:  ora     ($F8,x)                         ; 8F01
        ora     $03,x                           ; 8F03
        .byte   $FC                             ; 8F05
        ora     ($F8,x)                         ; 8F06
        adc     L0000                           ; 8F08
        .byte   $FC                             ; 8F0A
        ora     ($F8,x)                         ; 8F0B
        adc     L0000,x                         ; 8F0D
L8F0F:  .byte   $FC                             ; 8F0F
        .byte   $02                             ; 8F10
        sed                                     ; 8F11
        .byte   $23                             ; 8F12
L8F13:  ora     ($F8,x)                         ; 8F13
        sed                                     ; 8F15
        .byte   $33                             ; 8F16
        ora     (L0000,x)                       ; 8F17
        .byte   $02                             ; 8F19
        sed                                     ; 8F1A
        .byte   $0F                             ; 8F1B
        .byte   $03                             ; 8F1C
        sed                                     ; 8F1D
        sed                                     ; 8F1E
        .byte   $1F                             ; 8F1F
        .byte   $03                             ; 8F20
        brk                                     ; 8F21
        .byte   $02                             ; 8F22
        sed                                     ; 8F23
        .byte   $2F                             ; 8F24
        ora     ($F8,x)                         ; 8F25
        sed                                     ; 8F27
        .byte   $3F                             ; 8F28
        ora     (L0000,x)                       ; 8F29
        .byte   $02                             ; 8F2B
        sed                                     ; 8F2C
        sta     $03                             ; 8F2D
        sed                                     ; 8F2F
        sed                                     ; 8F30
        .byte   $97                             ; 8F31
        .byte   $03                             ; 8F32
        brk                                     ; 8F33
        ora     ($F8,x)                         ; 8F34
        and     $FC01                           ; 8F36
        .byte   $02                             ; 8F39
        sed                                     ; 8F3A
        and     ($01,x)                         ; 8F3B
        sed                                     ; 8F3D
        sed                                     ; 8F3E
        and     ($01),y                         ; 8F3F
        brk                                     ; 8F41
        .byte   $02                             ; 8F42
        sed                                     ; 8F43
        and     $F803,y                         ; 8F44
        sed                                     ; 8F47
        .byte   $E7                             ; 8F48
        .byte   $03                             ; 8F49
        brk                                     ; 8F4A
        .byte   $02                             ; 8F4B
        sed                                     ; 8F4C
        eor     $F802,y                         ; 8F4D
        sed                                     ; 8F50
        adc     #$02                            ; 8F51
        brk                                     ; 8F53
        .byte   $02                             ; 8F54
        sed                                     ; 8F55
        adc     #$42                            ; 8F56
        sed                                     ; 8F58
        sed                                     ; 8F59
        eor     $42,y                           ; 8F5A
        .byte   $02                             ; 8F5D
        sed                                     ; 8F5E
        .byte   $8F                             ; 8F5F
        ora     ($F8,x)                         ; 8F60
        sed                                     ; 8F62
        .byte   $8F                             ; 8F63
        eor     (L0000,x)                       ; 8F64
        .byte   $03                             ; 8F66
        sed                                     ; 8F67
        .byte   $8F                             ; 8F68
        ora     ($F8,x)                         ; 8F69
        sed                                     ; 8F6B
        .byte   $8F                             ; 8F6C
        eor     (L0000,x)                       ; 8F6D
        php                                     ; 8F6F
        sta     $FC01,x                         ; 8F70
        ora     ($F8,x)                         ; 8F73
        rol     a                               ; 8F75
        brk                                     ; 8F76
        .byte   $FC                             ; 8F77
        ora     ($F8,x)                         ; 8F78
        .byte   $9F                             ; 8F7A
        ora     ($FC,x)                         ; 8F7B
        ora     ($F8,x)                         ; 8F7D
        .byte   $9F                             ; 8F7F
        eor     ($FC,x)                         ; 8F80
        ora     ($F8,x)                         ; 8F82
        .byte   $5B                             ; 8F84
        .byte   $02                             ; 8F85
        .byte   $FC                             ; 8F86
        ora     ($F8,x)                         ; 8F87
        .byte   $63                             ; 8F89
        brk                                     ; 8F8A
        .byte   $FC                             ; 8F8B
        ora     ($F8,x)                         ; 8F8C
        .byte   $63                             ; 8F8E
        rti                                     ; 8F8F

; ----------------------------------------------------------------------------
        .byte   $FC                             ; 8F90
        ora     ($F8,x)                         ; 8F91
        .byte   $73                             ; 8F93
        brk                                     ; 8F94
        .byte   $FC                             ; 8F95
        ora     ($F8,x)                         ; 8F96
        eor     #$00                            ; 8F98
L8F9A:  .byte   $FC                             ; 8F9A
        .byte   $02                             ; 8F9B
        sed                                     ; 8F9C
        eor     ($02,x)                         ; 8F9D
        sed                                     ; 8F9F
        sed                                     ; 8FA0
        eor     ($42,x)                         ; 8FA1
        brk                                     ; 8FA3
        php                                     ; 8FA4
        beq     L8FEA                           ; 8FA5
        .byte   $82                             ; 8FA7
        beq     L8F9A                           ; 8FA8
        .byte   $53                             ; 8FAA
        .byte   $82                             ; 8FAB
        sed                                     ; 8FAC
        beq     L9002                           ; 8FAD
        .byte   $C2                             ; 8FAF
        brk                                     ; 8FB0
        beq     L8FF6                           ; 8FB1
        .byte   $C2                             ; 8FB3
        php                                     ; 8FB4
        brk                                     ; 8FB5
        .byte   $43                             ; 8FB6
        .byte   $02                             ; 8FB7
        beq     L8FBA                           ; 8FB8
L8FBA:  .byte   $53                             ; 8FBA
        .byte   $02                             ; 8FBB
        sed                                     ; 8FBC
        brk                                     ; 8FBD
        .byte   $53                             ; 8FBE
        .byte   $42                             ; 8FBF
        brk                                     ; 8FC0
        brk                                     ; 8FC1
        .byte   $43                             ; 8FC2
        .byte   $42                             ; 8FC3
        php                                     ; 8FC4
        .byte   $02                             ; 8FC5
        sed                                     ; 8FC6
        ora     $F800,y                         ; 8FC7
        sed                                     ; 8FCA
        and     #$00                            ; 8FCB
        brk                                     ; 8FCD
        asl     $F8                             ; 8FCE
        ora     $F800,y                         ; 8FD0
        sed                                     ; 8FD3
        and     #$00                            ; 8FD4
        brk                                     ; 8FD6
        php                                     ; 8FD7
        .byte   $0B                             ; 8FD8
        brk                                     ; 8FD9
        beq     L8FE4                           ; 8FDA
        .byte   $1B                             ; 8FDC
        brk                                     ; 8FDD
        sed                                     ; 8FDE
        php                                     ; 8FDF
        .byte   $2B                             ; 8FE0
        brk                                     ; 8FE1
        brk                                     ; 8FE2
        php                                     ; 8FE3
L8FE4:  .byte   $3B                             ; 8FE4
        brk                                     ; 8FE5
        php                                     ; 8FE6
        ora     #$F8                            ; 8FE7
        .byte   $19                             ; 8FE9
L8FEA:  brk                                     ; 8FEA
        sed                                     ; 8FEB
        sed                                     ; 8FEC
        and     #$00                            ; 8FED
        brk                                     ; 8FEF
        php                                     ; 8FF0
        .byte   $0B                             ; 8FF1
        brk                                     ; 8FF2
        beq     L8FFD                           ; 8FF3
        .byte   $1B                             ; 8FF5
L8FF6:  brk                                     ; 8FF6
        sed                                     ; 8FF7
        php                                     ; 8FF8
        .byte   $2B                             ; 8FF9
        brk                                     ; 8FFA
        brk                                     ; 8FFB
        php                                     ; 8FFC
L8FFD:  .byte   $3B                             ; 8FFD
        brk                                     ; 8FFE
        php                                     ; 8FFF
        clc                                     ; 9000
        .byte   $0D                             ; 9001
L9002:  brk                                     ; 9002
        beq     L901D                           ; 9003
        ora     $F800,x                         ; 9005
        clc                                     ; 9008
        and     $0800,x                         ; 9009
        .byte   $04                             ; 900C
        inx                                     ; 900D
        .byte   $FB                             ; 900E
        ora     ($F8,x)                         ; 900F
        inx                                     ; 9011
        .byte   $FB                             ; 9012
        eor     (L0000,x)                       ; 9013
        sed                                     ; 9015
        .byte   $77                             ; 9016
        ora     ($F8,x)                         ; 9017
        sed                                     ; 9019
        .byte   $77                             ; 901A
        eor     (L0000,x)                       ; 901B
L901D:  asl     $E8                             ; 901D
        .byte   $FB                             ; 901F
        ora     ($F8,x)                         ; 9020
        inx                                     ; 9022
        .byte   $FB                             ; 9023
        eor     (L0000,x)                       ; 9024
        sed                                     ; 9026
        .byte   $77                             ; 9027
        ora     ($F8,x)                         ; 9028
        sed                                     ; 902A
        .byte   $77                             ; 902B
        eor     (L0000,x)                       ; 902C
        cld                                     ; 902E
        sbc     $F801,y                         ; 902F
        cld                                     ; 9032
        sbc     $41,y                           ; 9033
        php                                     ; 9036
        inx                                     ; 9037
        .byte   $FB                             ; 9038
        ora     ($F8,x)                         ; 9039
        inx                                     ; 903B
        .byte   $FB                             ; 903C
        eor     (L0000,x)                       ; 903D
        sed                                     ; 903F
        .byte   $77                             ; 9040
        ora     ($F8,x)                         ; 9041
        sed                                     ; 9043
        .byte   $77                             ; 9044
        eor     (L0000,x)                       ; 9045
        cld                                     ; 9047
        sbc     $F801,y                         ; 9048
        cld                                     ; 904B
        sbc     $41,y                           ; 904C
        iny                                     ; 904F
        .byte   $F7                             ; 9050
        ora     ($F8,x)                         ; 9051
        iny                                     ; 9053
        .byte   $F7                             ; 9054
        eor     (L0000,x)                       ; 9055
        asl     $F8                             ; 9057
        .byte   $77                             ; 9059
        ora     ($F8,x)                         ; 905A
        sed                                     ; 905C
        .byte   $77                             ; 905D
        eor     (L0000,x)                       ; 905E
        cld                                     ; 9060
        sbc     $F801,y                         ; 9061
        cld                                     ; 9064
        sbc     $41,y                           ; 9065
        iny                                     ; 9068
        .byte   $F7                             ; 9069
        ora     ($F8,x)                         ; 906A
        iny                                     ; 906C
        .byte   $F7                             ; 906D
        eor     (L0000,x)                       ; 906E
        .byte   $04                             ; 9070
        sed                                     ; 9071
        .byte   $77                             ; 9072
        ora     ($F8,x)                         ; 9073
        sed                                     ; 9075
        .byte   $77                             ; 9076
        eor     (L0000,x)                       ; 9077
        cld                                     ; 9079
        sbc     $F801,y                         ; 907A
        cld                                     ; 907D
        .byte   $F9                             ; 907E
        .byte   $41                             ; 907F
L9080:  brk                                     ; 9080
        .byte   $02                             ; 9081
        sed                                     ; 9082
        .byte   $6B                             ; 9083
        ora     ($F8,x)                         ; 9084
        sed                                     ; 9086
        .byte   $7B                             ; 9087
        ora     (L0000,x)                       ; 9088
        ora     ($F8,x)                         ; 908A
        .byte   $57                             ; 908C
        brk                                     ; 908D
        .byte   $FC                             ; 908E
        ora     ($F8,x)                         ; 908F
        ora     L0000                           ; 9091
        .byte   $FC                             ; 9093
        ora     ($F8,x)                         ; 9094
        adc     $FC01,y                         ; 9096
        ora     ($F8,x)                         ; 9099
        eor     L0000,x                         ; 909B
        .byte   $FC                             ; 909D
        ora     ($F8,x)                         ; 909E
        adc     (L0000,x)                       ; 90A0
        .byte   $FC                             ; 90A2
        ora     ($F8,x)                         ; 90A3
        adc     L0000                           ; 90A5
        .byte   $FC                             ; 90A7
        ora     ($F8,x)                         ; 90A8
        adc     L0000,x                         ; 90AA
        .byte   $FC                             ; 90AC
        jsr     LB593                           ; 90AD
        beq     L90B3                           ; 90B0
        rts                                     ; 90B2

; ----------------------------------------------------------------------------
L90B3:  lda     #$FF                            ; 90B3
        jsr     LE992                           ; 90B5
        lda     $32                             ; 90B8
        beq     L90C8                           ; 90BA
        lda     #$03                            ; 90BC
        sta     $2A                             ; 90BE
        lda     $0707                           ; 90C0
        ora     #$02                            ; 90C3
        sta     $0707                           ; 90C5
L90C8:  lda     #$62                            ; 90C8
        jsr     LE992                           ; 90CA
        lda     #$05                            ; 90CD
        jsr     LE8C8                           ; 90CF
        lda     $E0                             ; 90D2
        lsr     a                               ; 90D4
        adc     $E1                             ; 90D5
        sta     $56                             ; 90D7
        jsr     L940A                           ; 90D9
        jsr     L9374                           ; 90DC
        jsr     LB5AB                           ; 90DF
        lda     $05D4                           ; 90E2
        sta     $0500                           ; 90E5
        lda     #$01                            ; 90E8
        jsr     LCFA1                           ; 90EA
        jsr     LD000                           ; 90ED
        lda     $0506                           ; 90F0
        bne     L911E                           ; 90F3
        jsr     LCA04                           ; 90F5
        beq     L9133                           ; 90F8
        jsr     L9444                           ; 90FA
        lda     #$01                            ; 90FD
        sta     $57                             ; 90FF
L9101:  jsr     LB826                           ; 9101
        lda     $05DA                           ; 9104
        beq     L910C                           ; 9107
        dec     $05DA                           ; 9109
L910C:  jsr     L9857                           ; 910C
        jsr     LD049                           ; 910F
        jsr     LCFA9                           ; 9112
        jsr     L987F                           ; 9115
        jsr     L9658                           ; 9118
        inc     $05CE                           ; 911B
L911E:  ldx     $0506                           ; 911E
        beq     L9155                           ; 9121
        cpx     #$02                            ; 9123
        beq     L9133                           ; 9125
        lda     #$0E                            ; 9127
        cpx     #$01                            ; 9129
        bne     L9139                           ; 912B
        jsr     LCFA1                           ; 912D
        jsr     LCF88                           ; 9130
L9133:  jsr     L91C3                           ; 9133
        jsr     L947F                           ; 9136
L9139:  jsr     LE95B                           ; 9139
        lda     #$00                            ; 913C
        ldx     #$FF                            ; 913E
L9140:  sta     $0600,x                         ; 9140
        sta     $0700,x                         ; 9143
        dex                                     ; 9146
        cpx     #$1F                            ; 9147
        bne     L9140                           ; 9149
        lda     #$0E                            ; 914B
        sta     $031C                           ; 914D
        lda     #$00                            ; 9150
        sta     $57                             ; 9152
        rts                                     ; 9154

; ----------------------------------------------------------------------------
L9155:  lda     $050E                           ; 9155
        cmp     #$FF                            ; 9158
        bne     L9182                           ; 915A
        dec     $80                             ; 915C
        beq     L9133                           ; 915E
        jsr     LCD6A                           ; 9160
        bne     L916F                           ; 9163
        lda     #$0D                            ; 9165
        ldx     #$00                            ; 9167
        stx     $0503                           ; 9169
        jsr     LCFA1                           ; 916C
L916F:  lda     $91                             ; 916F
        sta     $81                             ; 9171
        jsr     LE033                           ; 9173
        lda     $94                             ; 9176
        sta     $AB                             ; 9178
        lda     #$00                            ; 917A
        sta     $0605                           ; 917C
        jmp     L9133                           ; 917F

; ----------------------------------------------------------------------------
L9182:  jsr     LCA04                           ; 9182
        beq     L918A                           ; 9185
        jmp     L9101                           ; 9187

; ----------------------------------------------------------------------------
L918A:  lda     #$79                            ; 918A
        jsr     LE992                           ; 918C
L918F:  lda     #$00                            ; 918F
        sta     $0500                           ; 9191
        lda     $05D4                           ; 9194
        sta     $0503                           ; 9197
        lda     #$0A                            ; 919A
        jsr     LCFA1                           ; 919C
        lda     #$10                            ; 919F
        jsr     LCFA1                           ; 91A1
        lda     $05C0                           ; 91A4
        sta     L0000                           ; 91A7
        lda     #$00                            ; 91A9
        sta     $01                             ; 91AB
        jsr     LEC46                           ; 91AD
        lda     $05C1                           ; 91B0
        beq     L91BD                           ; 91B3
L91B5:  jsr     LEBB8                           ; 91B5
        dec     $05C1                           ; 91B8
        bne     L91B5                           ; 91BB
L91BD:  jsr     L94AE                           ; 91BD
        jmp     L9133                           ; 91C0

; ----------------------------------------------------------------------------
L91C3:  clc                                     ; 91C3
        lda     $0515                           ; 91C4
        adc     $051E                           ; 91C7
        adc     $0527                           ; 91CA
        sta     $0306                           ; 91CD
        clc                                     ; 91D0
        lda     $0516                           ; 91D1
        adc     $051F                           ; 91D4
        adc     $0528                           ; 91D7
        sta     $0307                           ; 91DA
        rts                                     ; 91DD

; ----------------------------------------------------------------------------
L91DE:  lda     #$0F                            ; 91DE
        ldx     #$1F                            ; 91E0
L91E2:  sta     $04A0,x                         ; 91E2
        dex                                     ; 91E5
        bpl     L91E2                           ; 91E6
        lda     #$00                            ; 91E8
        jsr     LB8BF                           ; 91EA
        lda     #$5A                            ; 91ED
        jsr     LB8BF                           ; 91EF
        ldx     #$03                            ; 91F2
        stx     $059A                           ; 91F4
L91F7:  ldx     $059A                           ; 91F7
        lda     L9218,x                         ; 91FA
        jsr     LB8F9                           ; 91FD
        dec     $059A                           ; 9200
        bpl     L91F7                           ; 9203
        lda     #$01                            ; 9205
        ldx     $0302                           ; 9207
        cpx     #$01                            ; 920A
        beq     L9214                           ; 920C
        lda     #$1F                            ; 920E
        cpx     #$02                            ; 9210
        bne     L9217                           ; 9212
L9214:  jsr     LB8F9                           ; 9214
L9217:  rts                                     ; 9217

; ----------------------------------------------------------------------------
L9218:  brk                                     ; 9218
        .byte   $42                             ; 9219
        .byte   $97                             ; 921A
        cld                                     ; 921B
L921C:  lda     #$00                            ; 921C
        ldx     #$3F                            ; 921E
L9220:  sta     $04C0,x                         ; 9220
        dex                                     ; 9223
        bpl     L9220                           ; 9224
        ldx     #$0F                            ; 9226
L9228:  lda     L927F,x                         ; 9228
        sta     $04D8,x                         ; 922B
        dex                                     ; 922E
        bpl     L9228                           ; 922F
        ldx     $0162                           ; 9231
        ldy     #$00                            ; 9234
L9236:  lda     L927D,y                         ; 9236
        sta     $0163,x                         ; 9239
        inx                                     ; 923C
        iny                                     ; 923D
        cpy     #$11                            ; 923E
        bne     L9236                           ; 9240
        lda     #$21                            ; 9242
        sta     $01                             ; 9244
        lda     #$83                            ; 9246
        sta     L0000                           ; 9248
        ldy     #$06                            ; 924A
L924C:  lda     $01                             ; 924C
        sta     $0163,x                         ; 924E
        inx                                     ; 9251
        lda     L0000                           ; 9252
        sta     $0163,x                         ; 9254
        inx                                     ; 9257
        lda     #$52                            ; 9258
        sta     $0163,x                         ; 925A
        inx                                     ; 925D
        lda     #$2D                            ; 925E
        sta     $0163,x                         ; 9260
        inx                                     ; 9263
        clc                                     ; 9264
        lda     #$20                            ; 9265
        adc     L0000                           ; 9267
        sta     L0000                           ; 9269
        lda     #$00                            ; 926B
        adc     $01                             ; 926D
        sta     $01                             ; 926F
        dey                                     ; 9271
        bne     L924C                           ; 9272
L9274:  lda     #$00                            ; 9274
        sta     $0163,x                         ; 9276
        stx     $0162                           ; 9279
        rts                                     ; 927C

; ----------------------------------------------------------------------------
L927D:  .byte   $23                             ; 927D
        cld                                     ; 927E
L927F:  asl     $5544                           ; 927F
        eor     $55,x                           ; 9282
        eor     $11,x                           ; 9284
        brk                                     ; 9286
        brk                                     ; 9287
        .byte   $04                             ; 9288
        ora     $05                             ; 9289
        ora     $05                             ; 928B
        .byte   $01                             ; 928D
L928E:  ldx     #$00                            ; 928E
        txa                                     ; 9290
L9291:  sta     $0500,x                         ; 9291
        inx                                     ; 9294
        bne     L9291                           ; 9295
        ldy     #$0E                            ; 9297
        ldx     #$00                            ; 9299
L929B:  lda     #$FF                            ; 929B
        sta     $050E,x                         ; 929D
        txa                                     ; 92A0
        clc                                     ; 92A1
        adc     #$09                            ; 92A2
        tax                                     ; 92A4
        dey                                     ; 92A5
        bne     L929B                           ; 92A6
        lda     #$01                            ; 92A8
        sta     $05CE                           ; 92AA
        ldx     #$0D                            ; 92AD
L92AF:  lda     L92C9,x                         ; 92AF
        sta     $40,x                           ; 92B2
        dex                                     ; 92B4
        bpl     L92AF                           ; 92B5
        lda     #$00                            ; 92B7
        sta     $050E                           ; 92B9
        lda     $0306                           ; 92BC
        sta     $0515                           ; 92BF
        lda     $0307                           ; 92C2
        sta     $0516                           ; 92C5
        rts                                     ; 92C8

; ----------------------------------------------------------------------------
L92C9:  .byte   $D4                             ; 92C9
        ldy     $18,x                           ; 92CA
        lda     $04                             ; 92CC
        sta     (L0000),y                       ; 92CE
        ora     #$08                            ; 92D0
        brk                                     ; 92D2
        and     $EFB6,y                         ; 92D3
        .byte   $EB                             ; 92D6
L92D7:  lda     L8D3B                           ; 92D7
        sta     L0000                           ; 92DA
        lda     L8C85                           ; 92DC
        sta     $01                             ; 92DF
        lda     L8C86                           ; 92E1
        sta     $02                             ; 92E4
        ldx     #$01                            ; 92E6
        ldy     #$00                            ; 92E8
L92EA:  lda     L8D3B,x                         ; 92EA
        clc                                     ; 92ED
        adc     $01                             ; 92EE
        sta     $0200,y                         ; 92F0
        inx                                     ; 92F3
        iny                                     ; 92F4
        lda     L8D3B,x                         ; 92F5
        sta     $0200,y                         ; 92F8
        iny                                     ; 92FB
        inx                                     ; 92FC
        lda     L8D3B,x                         ; 92FD
        sta     $0200,y                         ; 9300
        inx                                     ; 9303
        iny                                     ; 9304
        lda     L8D3B,x                         ; 9305
        clc                                     ; 9308
        adc     $02                             ; 9309
        sta     $0200,y                         ; 930B
        inx                                     ; 930E
        iny                                     ; 930F
        dec     L0000                           ; 9310
        bne     L92EA                           ; 9312
        rts                                     ; 9314

; ----------------------------------------------------------------------------
L9315:  lda     #$02                            ; 9315
        sta     $50                             ; 9317
L9319:  lda     $50                             ; 9319
        jsr     LC6F3                           ; 931B
        lda     $050E,y                         ; 931E
        cmp     #$FF                            ; 9321
        beq     L9359                           ; 9323
        lda     $50                             ; 9325
        asl     a                               ; 9327
        tay                                     ; 9328
        ldx     $0162                           ; 9329
        lda     L936A,y                         ; 932C
        sta     $0163,x                         ; 932F
        inx                                     ; 9332
        lda     L936B,y                         ; 9333
        sta     $0163,x                         ; 9336
        inx                                     ; 9339
        lda     #$84                            ; 933A
        sta     $0163,x                         ; 933C
        inx                                     ; 933F
        ldy     #$00                            ; 9340
L9342:  lda     L9370,y                         ; 9342
        sta     $0163,x                         ; 9345
        inx                                     ; 9348
        iny                                     ; 9349
        cpy     #$04                            ; 934A
        bne     L9342                           ; 934C
        lda     #$00                            ; 934E
        sta     $0163,x                         ; 9350
        stx     $0162                           ; 9353
        jsr     LE95B                           ; 9356
L9359:  dec     $50                             ; 9359
        bpl     L9319                           ; 935B
        jsr     LC58E                           ; 935D
        jsr     LC5F7                           ; 9360
        jsr     LC64F                           ; 9363
        jsr     LC6B0                           ; 9366
        rts                                     ; 9369

; ----------------------------------------------------------------------------
L936A:  .byte   $21                             ; 936A
L936B:  .byte   $DA                             ; 936B
        .byte   $23                             ; 936C
        asl     $23,x                           ; 936D
        .byte   $1B                             ; 936F
L9370:  jsr     L4A21                           ; 9370
        .byte   $4B                             ; 9373
L9374:  ldy     #$00                            ; 9374
        ldx     $0162                           ; 9376
L9379:  lda     L9388,y                         ; 9379
        sta     $0163,x                         ; 937C
        iny                                     ; 937F
        inx                                     ; 9380
        cpy     #$20                            ; 9381
        bne     L9379                           ; 9383
        jmp     L9274                           ; 9385

; ----------------------------------------------------------------------------
L9388:  .byte   $22                             ; 9388
        .byte   $42                             ; 9389
        ora     ($8E,x)                         ; 938A
        .byte   $22                             ; 938C
        eor     $01,x                           ; 938D
        .byte   $9E                             ; 938F
        .byte   $23                             ; 9390
        .byte   $42                             ; 9391
        ora     ($8F,x)                         ; 9392
        .byte   $23                             ; 9394
        eor     $01,x                           ; 9395
        .byte   $9F                             ; 9397
        .byte   $22                             ; 9398
        .byte   $43                             ; 9399
        .byte   $52                             ; 939A
        sty     $4323                           ; 939B
        .byte   $52                             ; 939E
        sty     $6222                           ; 939F
        .byte   $C7                             ; 93A2
        sta     $7522                           ; 93A3
        .byte   $C7                             ; 93A6
        .byte   $8D                             ; 93A7
L93A8:  ldx     #$DF                            ; 93A8
        lda     #$00                            ; 93AA
L93AC:  sta     $0620,x                         ; 93AC
        dex                                     ; 93AF
        bpl     L93AC                           ; 93B0
        ldy     #$20                            ; 93B2
        ldx     #$00                            ; 93B4
L93B6:  lda     #$FF                            ; 93B6
        sta     $0620,x                         ; 93B8
        txa                                     ; 93BB
        clc                                     ; 93BC
        adc     #$06                            ; 93BD
        tax                                     ; 93BF
        dey                                     ; 93C0
        bne     L93B6                           ; 93C1
        lda     #$0E                            ; 93C3
        sta     L0000                           ; 93C5
        ldy     #$00                            ; 93C7
        ldx     #$04                            ; 93C9
L93CB:  lda     L8C85,y                         ; 93CB
        sta     $0620,x                         ; 93CE
        iny                                     ; 93D1
        lda     L8C85,y                         ; 93D2
        sta     $0621,x                         ; 93D5
        iny                                     ; 93D8
        txa                                     ; 93D9
        clc                                     ; 93DA
        adc     #$06                            ; 93DB
        tax                                     ; 93DD
        dec     L0000                           ; 93DE
        bne     L93CB                           ; 93E0
        lda     #$02                            ; 93E2
        sta     $50                             ; 93E4
L93E6:  lda     $50                             ; 93E6
        jsr     LC6F3                           ; 93E8
        lda     $050E,y                         ; 93EB
        cmp     #$FF                            ; 93EE
        beq     L93F8                           ; 93F0
        tax                                     ; 93F2
        lda     $50                             ; 93F3
        jsr     L93FD                           ; 93F5
L93F8:  dec     $50                             ; 93F8
        bpl     L93E6                           ; 93FA
        rts                                     ; 93FC

; ----------------------------------------------------------------------------
L93FD:  jsr     LCF3A                           ; 93FD
        txa                                     ; 9400
        sta     $0620,y                         ; 9401
        lda     #$00                            ; 9404
        sta     $0621,y                         ; 9406
        rts                                     ; 9409

; ----------------------------------------------------------------------------
L940A:  lda     $11                             ; 940A
        and     #$06                            ; 940C
        sta     $11                             ; 940E
        sta     PPU_MASK                        ; 9410
        lda     #$81                            ; 9413
        jsr     LE9EB                           ; 9415
        jsr     L91DE                           ; 9418
        jsr     L921C                           ; 941B
        jsr     L928E                           ; 941E
        jsr     LCF51                           ; 9421
        jsr     L9315                           ; 9424
        jsr     L92D7                           ; 9427
        lda     $1E                             ; 942A
        and     #$0F                            ; 942C
        sta     $50                             ; 942E
L9430:  jsr     LCE27                           ; 9430
        dec     $50                             ; 9433
        bne     L9430                           ; 9435
        lda     $11                             ; 9437
        ora     #$18                            ; 9439
        sta     $11                             ; 943B
        lda     $05D4                           ; 943D
        sta     $0500                           ; 9440
        rts                                     ; 9443

; ----------------------------------------------------------------------------
L9444:  lda     $11                             ; 9444
        and     #$06                            ; 9446
        sta     $11                             ; 9448
        sta     PPU_MASK                        ; 944A
        lda     #$81                            ; 944D
        jsr     LE9EB                           ; 944F
        jsr     LCF51                           ; 9452
        jsr     L921C                           ; 9455
        jsr     LE95B                           ; 9458
        lda     #$00                            ; 945B
        sta     $05CC                           ; 945D
        jsr     LB593                           ; 9460
        iny                                     ; 9463
        lda     #$01                            ; 9464
        sta     $05D8                           ; 9466
        jsr     LB5CE                           ; 9469
        jsr     LB74C                           ; 946C
        jsr     L93A8                           ; 946F
        jsr     L9315                           ; 9472
        jsr     L9374                           ; 9475
        lda     $11                             ; 9478
        ora     #$18                            ; 947A
        sta     $11                             ; 947C
        rts                                     ; 947E

; ----------------------------------------------------------------------------
L947F:  lda     #$00                            ; 947F
        sta     $01                             ; 9481
        ldx     #$03                            ; 9483
L9485:  txa                                     ; 9485
        jsr     LC6F3                           ; 9486
        lda     $0529,y                         ; 9489
        bmi     L9490                           ; 948C
        inc     $01                             ; 948E
L9490:  dex                                     ; 9490
        bpl     L9485                           ; 9491
        clc                                     ; 9493
        lda     $03D7                           ; 9494
        adc     $01                             ; 9497
        sta     $03D7                           ; 9499
        cmp     #$0A                            ; 949C
        bcc     L94AD                           ; 949E
        sbc     #$0A                            ; 94A0
        sta     $03D7                           ; 94A2
        lda     $03D6                           ; 94A5
        adc     #$00                            ; 94A8
        sta     $03D6                           ; 94AA
L94AD:  rts                                     ; 94AD

; ----------------------------------------------------------------------------
L94AE:  lda     #$01                            ; 94AE
        jsr     LCE8D                           ; 94B0
        bcc     L94E3                           ; 94B3
        jsr     LB593                           ; 94B5
        iny                                     ; 94B8
        iny                                     ; 94B9
        lda     (L0000),y                       ; 94BA
        asl     a                               ; 94BC
        asl     a                               ; 94BD
        sta     L0000                           ; 94BE
        lda     $1E                             ; 94C0
        and     #$03                            ; 94C2
        clc                                     ; 94C4
        adc     L0000                           ; 94C5
        tay                                     ; 94C7
        lda     L9524,y                         ; 94C8
        asl     a                               ; 94CB
        asl     a                               ; 94CC
        tay                                     ; 94CD
        ldx     #$00                            ; 94CE
L94D0:  lda     L9534,y                         ; 94D0
        sta     L0000,x                         ; 94D3
        iny                                     ; 94D5
        inx                                     ; 94D6
        cpx     #$04                            ; 94D7
        bne     L94D0                           ; 94D9
        ldy     #$00                            ; 94DB
        lda     (L0000),y                       ; 94DD
        cmp     $02                             ; 94DF
        bcc     L94E4                           ; 94E1
L94E3:  rts                                     ; 94E3

; ----------------------------------------------------------------------------
L94E4:  tax                                     ; 94E4
        inx                                     ; 94E5
        txa                                     ; 94E6
        sta     (L0000),y                       ; 94E7
        lda     $03                             ; 94E9
        sec                                     ; 94EB
        sbc     #$06                            ; 94EC
        bcc     L94F4                           ; 94EE
        tax                                     ; 94F0
        inc     $0515,x                         ; 94F1
L94F4:  lda     $03                             ; 94F4
        sta     $0505                           ; 94F6
        cmp     #$04                            ; 94F9
        bne     L9501                           ; 94FB
        lda     #$05                            ; 94FD
        sta     (L0000),y                       ; 94FF
L9501:  lda     $05D4                           ; 9501
        sta     $0503                           ; 9504
        lda     #$78                            ; 9507
        sta     $0678                           ; 9509
        lda     #$60                            ; 950C
        sta     $0679                           ; 950E
        lda     #$00                            ; 9511
        sta     $0675                           ; 9513
        clc                                     ; 9516
        lda     $03                             ; 9517
        adc     #$32                            ; 9519
        sta     $0674                           ; 951B
        lda     #$11                            ; 951E
        jsr     LCFA1                           ; 9520
        rts                                     ; 9523

; ----------------------------------------------------------------------------
L9524:  brk                                     ; 9524
        ora     ($06,x)                         ; 9525
        .byte   $07                             ; 9527
        brk                                     ; 9528
        ora     ($05,x)                         ; 9529
        .byte   $02                             ; 952B
        brk                                     ; 952C
        ora     ($03,x)                         ; 952D
        .byte   $04                             ; 952F
        brk                                     ; 9530
        ora     ($03,x)                         ; 9531
        .byte   $02                             ; 9533
L9534:  ora     ($03),y                         ; 9534
        .byte   $0F                             ; 9536
        brk                                     ; 9537
        .byte   $0F                             ; 9538
        .byte   $03                             ; 9539
        ora     ($01,x)                         ; 953A
        bpl     L9541                           ; 953C
        ora     ($02,x)                         ; 953E
        .byte   $01                             ; 9540
L9541:  .byte   $03                             ; 9541
        ora     ($03,x)                         ; 9542
        .byte   $12                             ; 9544
        .byte   $03                             ; 9545
        ora     $04                             ; 9546
        brk                                     ; 9548
        .byte   $03                             ; 9549
        ora     #$05                            ; 954A
        asl     $03                             ; 954C
        asl     a                               ; 954E
        asl     $07                             ; 954F
        .byte   $03                             ; 9551
        asl     a                               ; 9552
        .byte   $07                             ; 9553
L9554:  lda     $05CD                           ; 9554
        asl     a                               ; 9557
        tay                                     ; 9558
        lda     L95D0,y                         ; 9559
        sta     $03                             ; 955C
        lda     L95D1,y                         ; 955E
        sta     $04                             ; 9561
        lda     $E0                             ; 9563
        ror     a                               ; 9565
        ror     a                               ; 9566
        sta     $01                             ; 9567
        lda     #$07                            ; 9569
        sta     $02                             ; 956B
L956D:  lda     $05C7                           ; 956D
        jsr     LC6F3                           ; 9570
        lda     $050E,y                         ; 9573
        cmp     #$FF                            ; 9576
        beq     L958A                           ; 9578
        lda     $05C7                           ; 957A
        asl     a                               ; 957D
        tay                                     ; 957E
        lda     $05A0,y                         ; 957F
        cmp     $03                             ; 9582
        bcc     L958A                           ; 9584
        cmp     $04                             ; 9586
        bcc     L95A9                           ; 9588
L958A:  ldx     $05C7                           ; 958A
        lda     $01                             ; 958D
        bmi     L959A                           ; 958F
        inx                                     ; 9591
        cpx     #$07                            ; 9592
        bne     L959F                           ; 9594
        ldx     #$00                            ; 9596
        beq     L959F                           ; 9598
L959A:  dex                                     ; 959A
        bpl     L959F                           ; 959B
        ldx     #$06                            ; 959D
L959F:  stx     $05C7                           ; 959F
        dec     $02                             ; 95A2
        bne     L956D                           ; 95A4
        lda     #$45                            ; 95A6
        rts                                     ; 95A8

; ----------------------------------------------------------------------------
L95A9:  sta     $0502                           ; 95A9
        lda     #$FF                            ; 95AC
        sta     $05A0,y                         ; 95AE
        iny                                     ; 95B1
        lda     $05A0,y                         ; 95B2
        sta     $0503                           ; 95B5
        lda     $05C7                           ; 95B8
        jsr     LC6F3                           ; 95BB
        lda     $050E,y                         ; 95BE
        sta     $0500                           ; 95C1
        lda     $0510,y                         ; 95C4
        sta     $0501                           ; 95C7
        jsr     L99FB                           ; 95CA
        lda     #$00                            ; 95CD
        rts                                     ; 95CF

; ----------------------------------------------------------------------------
L95D0:  .byte   $01                             ; 95D0
L95D1:  .byte   $07                             ; 95D1
        .byte   $07                             ; 95D2
        php                                     ; 95D3
        php                                     ; 95D4
        .byte   $1C                             ; 95D5
        .byte   $23                             ; 95D6
        and     $25                             ; 95D7
        .byte   $27                             ; 95D9
        .byte   $1C                             ; 95DA
        .byte   $22                             ; 95DB
L95DC:  lda     $05CD                           ; 95DC
        asl     a                               ; 95DF
        tay                                     ; 95E0
        lda     L95D0,y                         ; 95E1
        sta     $03                             ; 95E4
        lda     L95D1,y                         ; 95E6
        sta     $04                             ; 95E9
        lda     $E1                             ; 95EB
        ror     a                               ; 95ED
        ror     a                               ; 95EE
        sta     $01                             ; 95EF
        lda     #$07                            ; 95F1
        sta     $02                             ; 95F3
L95F5:  lda     $05C8                           ; 95F5
        jsr     LC6F3                           ; 95F8
        lda     $054D,y                         ; 95FB
        cmp     #$FF                            ; 95FE
        beq     L9612                           ; 9600
        lda     $05C8                           ; 9602
        asl     a                               ; 9605
        tay                                     ; 9606
        lda     $05AE,y                         ; 9607
        cmp     $03                             ; 960A
        bcc     L9612                           ; 960C
        cmp     $04                             ; 960E
        bcc     L9631                           ; 9610
L9612:  ldx     $05C8                           ; 9612
        lda     $01                             ; 9615
        bmi     L9622                           ; 9617
        inx                                     ; 9619
        cpx     #$07                            ; 961A
        bne     L9627                           ; 961C
        ldx     #$00                            ; 961E
        beq     L9627                           ; 9620
L9622:  dex                                     ; 9622
        bpl     L9627                           ; 9623
        ldx     #$06                            ; 9625
L9627:  stx     $05C8                           ; 9627
        dec     $02                             ; 962A
        bne     L95F5                           ; 962C
        lda     #$45                            ; 962E
        rts                                     ; 9630

; ----------------------------------------------------------------------------
L9631:  sta     $0502                           ; 9631
        lda     #$FF                            ; 9634
        sta     $05AE,y                         ; 9636
        iny                                     ; 9639
        lda     $05AE,y                         ; 963A
        sta     $0503                           ; 963D
        lda     $05C8                           ; 9640
        jsr     LC6F3                           ; 9643
        lda     $054D,y                         ; 9646
        sta     $0500                           ; 9649
        lda     $054E,y                         ; 964C
        sta     $0501                           ; 964F
        jsr     L9A52                           ; 9652
        lda     #$00                            ; 9655
        rts                                     ; 9657

; ----------------------------------------------------------------------------
L9658:  lda     #$00                            ; 9658
        sta     $05D7                           ; 965A
        sta     $05CD                           ; 965D
        sta     $05D9                           ; 9660
        sta     $0506                           ; 9663
        lda     $05A0                           ; 9666
        cmp     #$28                            ; 9669
        bne     L9670                           ; 966B
        jsr     LA4EE                           ; 966D
L9670:  lda     $05A0                           ; 9670
        cmp     #$27                            ; 9673
        bne     L967A                           ; 9675
        jsr     LA510                           ; 9677
L967A:  jsr     LE95B                           ; 967A
        jsr     LC7F9                           ; 967D
        jsr     LC837                           ; 9680
        lda     $0506                           ; 9683
        bne     L9694                           ; 9686
        lda     $050E                           ; 9688
        cmp     #$FF                            ; 968B
        beq     L9694                           ; 968D
        jsr     LCA04                           ; 968F
        bne     L9695                           ; 9692
L9694:  rts                                     ; 9694

; ----------------------------------------------------------------------------
L9695:  lda     $E0                             ; 9695
        lsr     a                               ; 9697
        bcs     L96A6                           ; 9698
        jsr     L9554                           ; 969A
        beq     L967A                           ; 969D
        jsr     L95DC                           ; 969F
        beq     L967A                           ; 96A2
        bne     L96B0                           ; 96A4
L96A6:  jsr     L95DC                           ; 96A6
        beq     L967A                           ; 96A9
        jsr     L9554                           ; 96AB
        beq     L967A                           ; 96AE
L96B0:  inc     $05CD                           ; 96B0
        ldx     $05CD                           ; 96B3
        cpx     #$03                            ; 96B6
        bne     L96CF                           ; 96B8
        lda     #$01                            ; 96BA
        sta     $059D                           ; 96BC
        sta     $059B                           ; 96BF
        lda     #$00                            ; 96C2
        ldy     #$0D                            ; 96C4
L96C6:  sta     $058C,y                         ; 96C6
        sta     $0460,y                         ; 96C9
        dey                                     ; 96CC
        bpl     L96C6                           ; 96CD
L96CF:  cpx     #$04                            ; 96CF
        bne     L96D6                           ; 96D1
        jsr     LBE3B                           ; 96D3
L96D6:  lda     $05CD                           ; 96D6
        cmp     #$06                            ; 96D9
        bne     L967A                           ; 96DB
        rts                                     ; 96DD

; ----------------------------------------------------------------------------
        ldy     #$19                            ; 96DE
        lda     #$FF                            ; 96E0
L96E2:  sta     $05A0,y                         ; 96E2
        dey                                     ; 96E5
        bpl     L96E2                           ; 96E6
        lda     #$06                            ; 96E8
        sta     $05CD                           ; 96EA
        rts                                     ; 96ED

; ----------------------------------------------------------------------------
        lda     #$06                            ; 96EE
        sta     $01                             ; 96F0
L96F2:  lda     $01                             ; 96F2
        jsr     LC6F3                           ; 96F4
        lda     $054D,y                         ; 96F7
        cmp     #$0D                            ; 96FA
        beq     L9702                           ; 96FC
        lda     #$0E                            ; 96FE
        bne     L9719                           ; 9700
L9702:  lda     $054F,y                         ; 9702
        and     #$20                            ; 9705
        beq     L9719                           ; 9707
        lda     $01                             ; 9709
        asl     a                               ; 970B
        tay                                     ; 970C
        lda     $05AE,y                         ; 970D
        cmp     #$0D                            ; 9710
        bne     L9719                           ; 9712
        lda     #$0B                            ; 9714
        sta     $05AE,y                         ; 9716
L9719:  dec     $01                             ; 9719
        bpl     L96F2                           ; 971B
        rts                                     ; 971D

; ----------------------------------------------------------------------------
L971E:  ldx     #$00                            ; 971E
        stx     $01                             ; 9720
        sta     L0000                           ; 9722
        asl     a                               ; 9724
        tay                                     ; 9725
        ldx     #$03                            ; 9726
L9728:  asl     L0000                           ; 9728
        rol     $01                             ; 972A
        dex                                     ; 972C
        bne     L9728                           ; 972D
        tya                                     ; 972F
        adc     L0000                           ; 9730
        sta     L0000                           ; 9732
        lda     #$00                            ; 9734
        adc     $01                             ; 9736
        sta     $01                             ; 9738
        lda     #$63                            ; 973A
        adc     L0000                           ; 973C
        sta     L0000                           ; 973E
        lda     #$84                            ; 9740
        adc     $01                             ; 9742
        sta     $01                             ; 9744
        lda     $1E                             ; 9746
        adc     $E0                             ; 9748
        sta     $1E                             ; 974A
        and     #$07                            ; 974C
        tay                                     ; 974E
        iny                                     ; 974F
        lda     (L0000),y                       ; 9750
        rts                                     ; 9752

; ----------------------------------------------------------------------------
L9753:  ldx     #$02                            ; 9753
L9755:  txa                                     ; 9755
        jsr     LC6F3                           ; 9756
        lda     #$00                            ; 9759
        sta     $050F,y                         ; 975B
        dex                                     ; 975E
        bpl     L9755                           ; 975F
        ldx     #$03                            ; 9761
L9763:  txa                                     ; 9763
        jsr     LC6F3                           ; 9764
        lda     #$00                            ; 9767
        sta     $0530,y                         ; 9769
        dex                                     ; 976C
        bpl     L9763                           ; 976D
        rts                                     ; 976F

; ----------------------------------------------------------------------------
L9770:  ldx     #$04                            ; 9770
L9772:  lda     $05D0                           ; 9772
        jsr     LC6F3                           ; 9775
        lda     $0529,y                         ; 9778
        bmi     L979D                           ; 977B
        lda     $0530,y                         ; 977D
        bne     L979D                           ; 9780
        lda     #$01                            ; 9782
        sta     $0530,y                         ; 9784
        lda     $0529,y                         ; 9787
        sta     $0503                           ; 978A
        lda     $052A,y                         ; 978D
        sta     $0504                           ; 9790
        lda     $05D0                           ; 9793
L9796:  clc                                     ; 9796
        adc     #$03                            ; 9797
        sta     $05D5                           ; 9799
        rts                                     ; 979C

; ----------------------------------------------------------------------------
L979D:  inc     $05D0                           ; 979D
        ldy     $05D0                           ; 97A0
        cpy     #$04                            ; 97A3
        bne     L97AC                           ; 97A5
        lda     #$00                            ; 97A7
        sta     $05D0                           ; 97A9
L97AC:  dex                                     ; 97AC
        bne     L9772                           ; 97AD
        lda     $05C8                           ; 97AF
        jsr     LC6F3                           ; 97B2
        lda     $054D,y                         ; 97B5
        cmp     #$21                            ; 97B8
        bcc     L97EC                           ; 97BA
        cmp     #$24                            ; 97BC
        bcs     L97EC                           ; 97BE
        lda     $0554,y                         ; 97C0
        bmi     L97EC                           ; 97C3
        sta     $01                             ; 97C5
        sty     $02                             ; 97C7
        ldx     #$02                            ; 97C9
L97CB:  txa                                     ; 97CB
        jsr     LC6F3                           ; 97CC
        lda     $050E,y                         ; 97CF
        cmp     $01                             ; 97D2
        bne     L97E2                           ; 97D4
        sta     $0503                           ; 97D6
        stx     $05D5                           ; 97D9
        lda     #$00                            ; 97DC
        sta     $0504                           ; 97DE
        rts                                     ; 97E1

; ----------------------------------------------------------------------------
L97E2:  dex                                     ; 97E2
        bpl     L97CB                           ; 97E3
        ldy     $02                             ; 97E5
        lda     #$FF                            ; 97E7
        sta     $0554,y                         ; 97E9
L97EC:  ldx     #$03                            ; 97EC
L97EE:  lda     $05C5                           ; 97EE
        jsr     LC6F3                           ; 97F1
        lda     $050E,y                         ; 97F4
        cmp     #$FF                            ; 97F7
        beq     L9827                           ; 97F9
        lda     $050F,y                         ; 97FB
        bne     L9827                           ; 97FE
        sta     $0504                           ; 9800
        lda     #$01                            ; 9803
        sta     $050F,y                         ; 9805
        lda     $050E,y                         ; 9808
        sta     $0503                           ; 980B
        jsr     L983F                           ; 980E
        lda     $05C5                           ; 9811
        sta     $05D5                           ; 9814
        inc     $05C5                           ; 9817
        ldy     $05C5                           ; 981A
        cpy     #$03                            ; 981D
        bne     L9826                           ; 981F
        ldy     #$00                            ; 9821
        sty     $05C5                           ; 9823
L9826:  rts                                     ; 9826

; ----------------------------------------------------------------------------
L9827:  inc     $05C5                           ; 9827
        ldy     $05C5                           ; 982A
        cpy     #$03                            ; 982D
        bne     L9836                           ; 982F
        ldy     #$00                            ; 9831
        sty     $05C5                           ; 9833
L9836:  dex                                     ; 9836
        bne     L97EE                           ; 9837
        jsr     L9753                           ; 9839
        jmp     L9770                           ; 983C

; ----------------------------------------------------------------------------
L983F:  lda     $05C8                           ; 983F
        jsr     LC6F3                           ; 9842
        lda     $054D,y                         ; 9845
        cmp     #$21                            ; 9848
        bcc     L9856                           ; 984A
        cmp     #$24                            ; 984C
        bcs     L9856                           ; 984E
        lda     $0503                           ; 9850
        sta     $0554,y                         ; 9853
L9856:  rts                                     ; 9856

; ----------------------------------------------------------------------------
L9857:  lda     #$FF                            ; 9857
        ldy     #$0D                            ; 9859
L985B:  sta     $05A0,y                         ; 985B
        dey                                     ; 985E
        bpl     L985B                           ; 985F
        lda     #$03                            ; 9861
        sta     $01                             ; 9863
L9865:  lda     $01                             ; 9865
        jsr     LC6F3                           ; 9867
        lda     $0529,y                         ; 986A
        cmp     #$FF                            ; 986D
        beq     L987A                           ; 986F
        lda     $01                             ; 9871
        asl     a                               ; 9873
        tay                                     ; 9874
        lda     #$07                            ; 9875
        sta     $05A6,y                         ; 9877
L987A:  dec     $01                             ; 987A
        bpl     L9865                           ; 987C
        rts                                     ; 987E

; ----------------------------------------------------------------------------
L987F:  lda     #$FF                            ; 987F
        ldy     #$0D                            ; 9881
L9883:  sta     $05AE,y                         ; 9883
        dey                                     ; 9886
        bpl     L9883                           ; 9887
        jsr     LC837                           ; 9889
        beq     L98A7                           ; 988C
        lda     #$02                            ; 988E
        jsr     LCE8D                           ; 9890
        bcc     L98A7                           ; 9893
        jsr     LC929                           ; 9895
        bne     L98A7                           ; 9898
        jsr     LCA04                           ; 989A
        txa                                     ; 989D
        asl     a                               ; 989E
        tax                                     ; 989F
        lda     $05C3                           ; 98A0
        sta     $05AE,x                         ; 98A3
        rts                                     ; 98A6

; ----------------------------------------------------------------------------
L98A7:  lda     #$06                            ; 98A7
        sta     $02                             ; 98A9
L98AB:  lda     $02                             ; 98AB
        jsr     LC6F3                           ; 98AD
        lda     $054D,y                         ; 98B0
        sta     $50                             ; 98B3
        cmp     #$FF                            ; 98B5
        beq     L992B                           ; 98B7
        cmp     #$10                            ; 98B9
        bne     L98C3                           ; 98BB
        jsr     L9933                           ; 98BD
        jmp     L9907                           ; 98C0

; ----------------------------------------------------------------------------
L98C3:  jsr     L971E                           ; 98C3
        cmp     #$07                            ; 98C6
        bcs     L98DE                           ; 98C8
        tax                                     ; 98CA
        lda     #$FF                            ; 98CB
        ldy     #$0D                            ; 98CD
L98CF:  sta     $05AE,y                         ; 98CF
        dey                                     ; 98D2
        bpl     L98CF                           ; 98D3
        lda     $02                             ; 98D5
        asl     a                               ; 98D7
        tay                                     ; 98D8
        txa                                     ; 98D9
        sta     $05AE,y                         ; 98DA
        rts                                     ; 98DD

; ----------------------------------------------------------------------------
L98DE:  tax                                     ; 98DE
        lda     $02                             ; 98DF
        asl     a                               ; 98E1
        tay                                     ; 98E2
        sty     $52                             ; 98E3
        txa                                     ; 98E5
        sta     $05AE,y                         ; 98E6
        cmp     #$26                            ; 98E9
        bne     L992B                           ; 98EB
        lda     $50                             ; 98ED
        cmp     #$11                            ; 98EF
        bcc     L9907                           ; 98F1
        cmp     #$14                            ; 98F3
        bcs     L9907                           ; 98F5
        lda     #$03                            ; 98F7
        jsr     LCE8D                           ; 98F9
        bcc     L992B                           ; 98FC
        ldy     $52                             ; 98FE
        lda     #$1F                            ; 9900
        sta     $05AE,y                         ; 9902
        bne     L992B                           ; 9905
L9907:  cmp     #$14                            ; 9907
        beq     L990F                           ; 9909
        cmp     #$15                            ; 990B
        bne     L992B                           ; 990D
L990F:  lda     #$04                            ; 990F
        jsr     LCE8D                           ; 9911
        bcc     L992B                           ; 9914
        lda     $05CE                           ; 9916
        cmp     #$05                            ; 9919
        bcc     L9924                           ; 991B
        lda     #$00                            ; 991D
        jsr     LCE8D                           ; 991F
        bcc     L992B                           ; 9922
L9924:  ldy     $52                             ; 9924
        lda     #$20                            ; 9926
        sta     $05AE,y                         ; 9928
L992B:  dec     $02                             ; 992B
        bmi     L9932                           ; 992D
        jmp     L98AB                           ; 992F

; ----------------------------------------------------------------------------
L9932:  rts                                     ; 9932

; ----------------------------------------------------------------------------
L9933:  jsr     LC910                           ; 9933
        beq     L9959                           ; 9936
        jsr     LC8F9                           ; 9938
        lda     $01                             ; 993B
        cmp     #$01                            ; 993D
        bne     L9959                           ; 993F
        lda     #$FF                            ; 9941
        ldy     #$0D                            ; 9943
L9945:  sta     $05AE,y                         ; 9945
        dey                                     ; 9948
        bpl     L9945                           ; 9949
        lda     $02                             ; 994B
        asl     a                               ; 994D
        tay                                     ; 994E
        lda     #$03                            ; 994F
        sta     $05AE,y                         ; 9951
        lda     #$00                            ; 9954
        sta     $02                             ; 9956
        rts                                     ; 9958

; ----------------------------------------------------------------------------
L9959:  jsr     LC910                           ; 9959
        bne     L996D                           ; 995C
        tax                                     ; 995E
        lda     $02                             ; 995F
        asl     a                               ; 9961
        tay                                     ; 9962
        lda     #$08                            ; 9963
        sta     $05AE,y                         ; 9965
        txa                                     ; 9968
        sta     $05AF,y                         ; 9969
        rts                                     ; 996C

; ----------------------------------------------------------------------------
L996D:  lda     $02                             ; 996D
        jsr     LC6F3                           ; 996F
        lda     $054D,y                         ; 9972
        pha                                     ; 9975
        jsr     L971E                           ; 9976
        tax                                     ; 9979
        lda     $02                             ; 997A
        asl     a                               ; 997C
        tay                                     ; 997D
        txa                                     ; 997E
        sta     $05AE,y                         ; 997F
        pla                                     ; 9982
        cpx     #$08                            ; 9983
        bne     L998A                           ; 9985
        sta     $05AF,y                         ; 9987
L998A:  rts                                     ; 998A

; ----------------------------------------------------------------------------
L998B:  inc     $05C6                           ; 998B
        lda     $05C6                           ; 998E
        cmp     #$07                            ; 9991
        bne     L999A                           ; 9993
        lda     #$00                            ; 9995
        sta     $05C6                           ; 9997
L999A:  jsr     LC6F3                           ; 999A
        lda     $054D,y                         ; 999D
        cmp     #$FF                            ; 99A0
        bne     L99B5                           ; 99A2
        inc     $05C6                           ; 99A4
        lda     $05C6                           ; 99A7
        cmp     #$07                            ; 99AA
        bne     L999A                           ; 99AC
        lda     #$00                            ; 99AE
        sta     $05C6                           ; 99B0
        beq     L999A                           ; 99B3
L99B5:  sta     $0503                           ; 99B5
        lda     $054E,y                         ; 99B8
        sta     $0504                           ; 99BB
        rts                                     ; 99BE

; ----------------------------------------------------------------------------
L99BF:  ldx     $05C6                           ; 99BF
        inx                                     ; 99C2
        cpx     #$07                            ; 99C3
        bne     L99C9                           ; 99C5
        ldx     #$00                            ; 99C7
L99C9:  stx     $05C6                           ; 99C9
        txa                                     ; 99CC
        ldx     #$06                            ; 99CD
L99CF:  jsr     LC6F3                           ; 99CF
        lda     $054D,y                         ; 99D2
        cmp     #$FF                            ; 99D5
        beq     L99DE                           ; 99D7
        cmp     $0503                           ; 99D9
        beq     L99F1                           ; 99DC
L99DE:  inc     $05C6                           ; 99DE
        lda     $05C6                           ; 99E1
        cmp     #$07                            ; 99E4
        bne     L99ED                           ; 99E6
        lda     #$00                            ; 99E8
        sta     $05C6                           ; 99EA
L99ED:  dex                                     ; 99ED
        bpl     L99CF                           ; 99EE
        rts                                     ; 99F0

; ----------------------------------------------------------------------------
L99F1:  lda     $054E,y                         ; 99F1
        sta     $0504                           ; 99F4
        ldx     $05C6                           ; 99F7
        rts                                     ; 99FA

; ----------------------------------------------------------------------------
L99FB:  jsr     LCFA9                           ; 99FB
        jsr     LB9A1                           ; 99FE
        lda     $0502                           ; 9A01
        cmp     #$07                            ; 9A04
        bcs     L9A0C                           ; 9A06
        jsr     L9AB1                           ; 9A08
        rts                                     ; 9A0B

; ----------------------------------------------------------------------------
L9A0C:  sec                                     ; 9A0C
        sbc     #$07                            ; 9A0D
        jsr     LE97D                           ; 9A0F
        .byte   $44                             ; 9A12
        sta     L9DB8,x                         ; 9A13
        clv                                     ; 9A16
        sta     L9DB8,x                         ; 9A17
        ror     $AF9E,x                         ; 9A1A
        .byte   $9E                             ; 9A1D
        .byte   $AF                             ; 9A1E
        .byte   $9E                             ; 9A1F
        .byte   $AF                             ; 9A20
        .byte   $9E                             ; 9A21
        eor     $9F                             ; 9A22
        eor     $9F                             ; 9A24
        eor     $9F                             ; 9A26
        .byte   $D4                             ; 9A28
        .byte   $9F                             ; 9A29
        .byte   $0B                             ; 9A2A
        txs                                     ; 9A2B
        .byte   $64                             ; 9A2C
        ldy     #$D4                            ; 9A2D
        .byte   $9F                             ; 9A2F
        .byte   $1B                             ; 9A30
        ldx     #$0B                            ; 9A31
        txs                                     ; 9A33
        eor     $0BA2                           ; 9A34
        txs                                     ; 9A37
        txa                                     ; 9A38
        ldx     #$0B                            ; 9A39
        txs                                     ; 9A3B
        .byte   $0B                             ; 9A3C
        txs                                     ; 9A3D
        bit     $A3                             ; 9A3E
        ldy     $A2,x                           ; 9A40
        .byte   $0B                             ; 9A42
        txs                                     ; 9A43
        .byte   $0B                             ; 9A44
        txs                                     ; 9A45
        .byte   $0B                             ; 9A46
        txs                                     ; 9A47
        .byte   $0B                             ; 9A48
        txs                                     ; 9A49
        .byte   $9F                             ; 9A4A
        .byte   $A3                             ; 9A4B
        .byte   $9F                             ; 9A4C
        .byte   $A3                             ; 9A4D
        clc                                     ; 9A4E
        ldy     $18                             ; 9A4F
        .byte   $A4                             ; 9A51
L9A52:  jsr     LCFA9                           ; 9A52
        jsr     LBA40                           ; 9A55
        lda     $0502                           ; 9A58
        cmp     #$07                            ; 9A5B
        bcs     L9A63                           ; 9A5D
        jsr     LA81F                           ; 9A5F
L9A62:  rts                                     ; 9A62

; ----------------------------------------------------------------------------
L9A63:  jsr     LB217                           ; 9A63
        .byte   $D0                             ; 9A66
L9A67:  .byte   $FA                             ; 9A67
        lda     $0502                           ; 9A68
        sec                                     ; 9A6B
        sbc     #$07                            ; 9A6C
        jsr     LE97D                           ; 9A6E
        .byte   $62                             ; 9A71
        txs                                     ; 9A72
        php                                     ; 9A73
        .byte   $AB                             ; 9A74
        .byte   $62                             ; 9A75
        txs                                     ; 9A76
        php                                     ; 9A77
        .byte   $AB                             ; 9A78
        sei                                     ; 9A79
        .byte   $AB                             ; 9A7A
        .byte   $9E                             ; 9A7B
        .byte   $AB                             ; 9A7C
        .byte   $9E                             ; 9A7D
        .byte   $AB                             ; 9A7E
        .byte   $9E                             ; 9A7F
        .byte   $AB                             ; 9A80
        sbc     $FDAB,x                         ; 9A81
        .byte   $AB                             ; 9A84
        sbc     L9EAB,x                         ; 9A85
        ldy     L9A62                           ; 9A88
        .byte   $62                             ; 9A8B
        txs                                     ; 9A8C
        .byte   $9E                             ; 9A8D
        ldy     $AE85                           ; 9A8E
        .byte   $62                             ; 9A91
        txs                                     ; 9A92
        .byte   $62                             ; 9A93
        txs                                     ; 9A94
        plp                                     ; 9A95
        ldx     L9A62                           ; 9A96
        .byte   $62                             ; 9A99
        txs                                     ; 9A9A
        .byte   $03                             ; 9A9B
        lda     ($B1),y                         ; 9A9C
        ldx     L9A62                           ; 9A9E
        lsr     $AF                             ; 9AA1
        inc     $AF,x                           ; 9AA3
        rol     $62AD,x                         ; 9AA5
        txs                                     ; 9AA8
        .byte   $BB                             ; 9AA9
        bcs     L9A67                           ; 9AAA
        bcs     L9AB1                           ; 9AAC
        lda     ($03),y                         ; 9AAE
        .byte   $B1                             ; 9AB0
L9AB1:  jsr     LC972                           ; 9AB1
        beq     L9AB7                           ; 9AB4
        rts                                     ; 9AB6

; ----------------------------------------------------------------------------
L9AB7:  lda     #$00                            ; 9AB7
L9AB9:  pha                                     ; 9AB9
        jsr     LC793                           ; 9ABA
        pla                                     ; 9ABD
        tax                                     ; 9ABE
        inx                                     ; 9ABF
        txa                                     ; 9AC0
        cpx     #$03                            ; 9AC1
        bne     L9AB9                           ; 9AC3
        lda     #$FF                            ; 9AC5
        ldx     #$0B                            ; 9AC7
L9AC9:  sta     $05A2,x                         ; 9AC9
        dex                                     ; 9ACC
        bpl     L9AC9                           ; 9ACD
        jsr     LCEE3                           ; 9ACF
        lda     $01                             ; 9AD2
        sta     $059D                           ; 9AD4
        lda     #$00                            ; 9AD7
        sta     $059E                           ; 9AD9
        lda     #$00                            ; 9ADC
        sta     $0500                           ; 9ADE
        lda     #$37                            ; 9AE1
        jsr     LCFA1                           ; 9AE3
        jsr     LCF43                           ; 9AE6
        jsr     LC753                           ; 9AE9
        jsr     LC5F7                           ; 9AEC
        ldx     #$06                            ; 9AEF
L9AF1:  txa                                     ; 9AF1
        jsr     LC6F3                           ; 9AF2
        lda     $054D,y                         ; 9AF5
        cmp     #$15                            ; 9AF8
        beq     L9B00                           ; 9AFA
        cmp     #$17                            ; 9AFC
        bne     L9B1D                           ; 9AFE
L9B00:  lda     $054F,y                         ; 9B00
        and     #$10                            ; 9B03
        beq     L9B1D                           ; 9B05
        lda     $054D,y                         ; 9B07
        sta     $0503                           ; 9B0A
        lda     #$00                            ; 9B0D
        sta     $0504                           ; 9B0F
        jsr     LBBBA                           ; 9B12
        lda     #$19                            ; 9B15
        jsr     LCFA1                           ; 9B17
        jmp     L9B20                           ; 9B1A

; ----------------------------------------------------------------------------
L9B1D:  dex                                     ; 9B1D
        bpl     L9AF1                           ; 9B1E
L9B20:  ldx     $0502                           ; 9B20
        dex                                     ; 9B23
        txa                                     ; 9B24
        jsr     LE97D                           ; 9B25
        .byte   $34                             ; 9B28
        .byte   $9B                             ; 9B29
        cmp     #$9B                            ; 9B2A
        sbc     ($9B,x)                         ; 9B2C
        inx                                     ; 9B2E
        .byte   $9C                             ; 9B2F
        asl     a                               ; 9B30
        sta     L9D2C,x                         ; 9B31
        lda     #$77                            ; 9B34
        jsr     LE992                           ; 9B36
        lda     #$02                            ; 9B39
        jsr     LE029                           ; 9B3B
        lda     #$77                            ; 9B3E
        jsr     LE992                           ; 9B40
        lda     $0502                           ; 9B43
        jsr     LCE00                           ; 9B46
        lda     #$00                            ; 9B49
        sta     $059C                           ; 9B4B
L9B4E:  lda     $059C                           ; 9B4E
        jsr     LC6F3                           ; 9B51
        lda     $054D,y                         ; 9B54
        cmp     #$FF                            ; 9B57
        beq     L9BA0                           ; 9B59
        sta     $0503                           ; 9B5B
        lda     $054E,y                         ; 9B5E
        sta     $0504                           ; 9B61
        lda     $054D,y                         ; 9B64
        tay                                     ; 9B67
        iny                                     ; 9B68
        lda     ($58),y                         ; 9B69
        tay                                     ; 9B6B
        and     #$07                            ; 9B6C
        tax                                     ; 9B6E
        tya                                     ; 9B6F
        and     #$08                            ; 9B70
        beq     L9B78                           ; 9B72
        txa                                     ; 9B74
        ora     #$80                            ; 9B75
        tax                                     ; 9B77
L9B78:  txa                                     ; 9B78
        jsr     LCE8D                           ; 9B79
        bcc     L9BA0                           ; 9B7C
        inc     $059E                           ; 9B7E
        lda     $059C                           ; 9B81
        jsr     LBB00                           ; 9B84
        lda     $059C                           ; 9B87
        jsr     LC52E                           ; 9B8A
        lda     $059C                           ; 9B8D
        jsr     LC6F3                           ; 9B90
        lda     $054D,y                         ; 9B93
        tax                                     ; 9B96
        lda     #$FF                            ; 9B97
        sta     $054D,y                         ; 9B99
        txa                                     ; 9B9C
        jsr     LCAE1                           ; 9B9D
L9BA0:  inc     $059C                           ; 9BA0
        lda     $059C                           ; 9BA3
        cmp     #$07                            ; 9BA6
        bne     L9B4E                           ; 9BA8
L9BAA:  lda     #$00                            ; 9BAA
        sta     $0500                           ; 9BAC
        lda     $05D4                           ; 9BAF
        sta     $0503                           ; 9BB2
        ldx     #$73                            ; 9BB5
        lda     $059E                           ; 9BB7
        beq     L9BC4                           ; 9BBA
        ldx     #$3F                            ; 9BBC
        cmp     #$03                            ; 9BBE
        bcs     L9BC4                           ; 9BC0
        ldx     #$41                            ; 9BC2
L9BC4:  txa                                     ; 9BC4
        jsr     LCFA1                           ; 9BC5
        rts                                     ; 9BC8

; ----------------------------------------------------------------------------
        lda     #$77                            ; 9BC9
        .byte   $20                             ; 9BCB
L9BCC:  .byte   $92                             ; 9BCC
        sbc     #$A9                            ; 9BCD
        .byte   $07                             ; 9BCF
        jsr     LE029                           ; 9BD0
        lda     #$77                            ; 9BD3
        jsr     LE992                           ; 9BD5
        lda     #$3B                            ; 9BD8
        sta     $0470                           ; 9BDA
        jsr     LA598                           ; 9BDD
        rts                                     ; 9BE0

; ----------------------------------------------------------------------------
        lda     #$0E                            ; 9BE1
        jsr     LE029                           ; 9BE3
        lda     $0502                           ; 9BE6
        jsr     LCE00                           ; 9BE9
        lda     #$00                            ; 9BEC
        sta     $059C                           ; 9BEE
        sta     $059E                           ; 9BF1
L9BF4:  lda     $059C                           ; 9BF4
        jsr     LC6F3                           ; 9BF7
        lda     $054D,y                         ; 9BFA
        cmp     #$FF                            ; 9BFD
        beq     L9C43                           ; 9BFF
        sta     $0503                           ; 9C01
        lda     $054E,y                         ; 9C04
        sta     $0504                           ; 9C07
        lda     $054D,y                         ; 9C0A
        tay                                     ; 9C0D
        iny                                     ; 9C0E
        lda     ($58),y                         ; 9C0F
        tay                                     ; 9C11
        and     #$07                            ; 9C12
        tax                                     ; 9C14
        tya                                     ; 9C15
        and     #$08                            ; 9C16
        beq     L9C1E                           ; 9C18
        txa                                     ; 9C1A
        ora     #$80                            ; 9C1B
        tax                                     ; 9C1D
L9C1E:  txa                                     ; 9C1E
        jsr     LCE8D                           ; 9C1F
        bcc     L9C43                           ; 9C22
        inc     $059E                           ; 9C24
        lda     $059C                           ; 9C27
        jsr     LC6F3                           ; 9C2A
        lda     $054F,y                         ; 9C2D
        ora     #$40                            ; 9C30
        sta     $054F,y                         ; 9C32
        lda     $059C                           ; 9C35
        jsr     LC52E                           ; 9C38
        lda     $059C                           ; 9C3B
        ldx     #$0A                            ; 9C3E
        jsr     LC0C4                           ; 9C40
L9C43:  inc     $059C                           ; 9C43
        lda     $059C                           ; 9C46
        cmp     #$07                            ; 9C49
        bne     L9BF4                           ; 9C4B
        lda     #$00                            ; 9C4D
        sta     $059C                           ; 9C4F
L9C52:  lda     $059C                           ; 9C52
        jsr     LC6F3                           ; 9C55
        lda     $054D,y                         ; 9C58
        cmp     #$FF                            ; 9C5B
        beq     L9C6C                           ; 9C5D
        lda     $054F,y                         ; 9C5F
        and     #$40                            ; 9C62
        beq     L9C6C                           ; 9C64
        lda     $059C                           ; 9C66
        jsr     LC1F7                           ; 9C69
L9C6C:  inc     $059C                           ; 9C6C
        lda     $059C                           ; 9C6F
        cmp     #$07                            ; 9C72
        bne     L9C52                           ; 9C74
        lda     $059E                           ; 9C76
        sta     $01                             ; 9C79
        beq     L9C8C                           ; 9C7B
        lda     #$77                            ; 9C7D
        jsr     LE992                           ; 9C7F
        lda     #$0C                            ; 9C82
        jsr     LE029                           ; 9C84
        lda     #$77                            ; 9C87
        jsr     LE992                           ; 9C89
L9C8C:  lda     #$0E                            ; 9C8C
        sta     L0000                           ; 9C8E
        ldy     #$00                            ; 9C90
        ldx     #$04                            ; 9C92
L9C94:  lda     L8C85,y                         ; 9C94
        sta     $0620,x                         ; 9C97
        iny                                     ; 9C9A
        lda     L8C85,y                         ; 9C9B
        sta     $0621,x                         ; 9C9E
        iny                                     ; 9CA1
        txa                                     ; 9CA2
        clc                                     ; 9CA3
        adc     #$06                            ; 9CA4
        tax                                     ; 9CA6
        dec     L0000                           ; 9CA7
        bne     L9C94                           ; 9CA9
        lda     #$00                            ; 9CAB
        sta     $059C                           ; 9CAD
L9CB0:  lda     $059C                           ; 9CB0
        jsr     LC6F3                           ; 9CB3
        lda     $054E,y                         ; 9CB6
        sta     $0504                           ; 9CB9
        lda     $054D,y                         ; 9CBC
        sta     $0503                           ; 9CBF
        cmp     #$FF                            ; 9CC2
        beq     L9CDB                           ; 9CC4
        lda     $054F,y                         ; 9CC6
        and     #$40                            ; 9CC9
        bne     L9CD0                           ; 9CCB
        jmp     L9CDB                           ; 9CCD

; ----------------------------------------------------------------------------
L9CD0:  lda     #$FF                            ; 9CD0
        sta     $054D,y                         ; 9CD2
        lda     $0503                           ; 9CD5
        jsr     LCAE1                           ; 9CD8
L9CDB:  inc     $059C                           ; 9CDB
        lda     $059C                           ; 9CDE
        cmp     #$07                            ; 9CE1
        bne     L9CB0                           ; 9CE3
        jmp     L9BAA                           ; 9CE5

; ----------------------------------------------------------------------------
        lda     #$77                            ; 9CE8
        jsr     LE992                           ; 9CEA
        lda     #$04                            ; 9CED
        jsr     LE029                           ; 9CEF
        lda     #$77                            ; 9CF2
        jsr     LE992                           ; 9CF4
        lda     #$26                            ; 9CF7
        jsr     LDF16                           ; 9CF9
        lda     #$01                            ; 9CFC
        sta     $046F                           ; 9CFE
        lda     #$3D                            ; 9D01
        sta     $0470                           ; 9D03
        jsr     LA598                           ; 9D06
        rts                                     ; 9D09

; ----------------------------------------------------------------------------
        lda     #$77                            ; 9D0A
        jsr     LE992                           ; 9D0C
        lda     #$06                            ; 9D0F
        jsr     LE029                           ; 9D11
        lda     #$77                            ; 9D14
        jsr     LE992                           ; 9D16
        lda     #$21                            ; 9D19
        jsr     LDF16                           ; 9D1B
        lda     #$00                            ; 9D1E
        sta     $046F                           ; 9D20
        lda     #$3A                            ; 9D23
        sta     $0470                           ; 9D25
        jsr     LA598                           ; 9D28
        rts                                     ; 9D2B

; ----------------------------------------------------------------------------
L9D2C:  lda     #$0B                            ; 9D2C
        jsr     LE029                           ; 9D2E
        lda     #$28                            ; 9D31
        jsr     LDF16                           ; 9D33
        lda     #$00                            ; 9D36
        sta     $046F                           ; 9D38
        lda     #$3C                            ; 9D3B
        sta     $0470                           ; 9D3D
        jsr     LA598                           ; 9D40
        rts                                     ; 9D43

; ----------------------------------------------------------------------------
        lda     $05D7                           ; 9D44
        bne     L9D53                           ; 9D47
        lda     #$01                            ; 9D49
        sta     $05D7                           ; 9D4B
        lda     #$03                            ; 9D4E
        jsr     LCFA1                           ; 9D50
L9D53:  jsr     L998B                           ; 9D53
        lda     $05C6                           ; 9D56
        jsr     LC6F3                           ; 9D59
        lda     $054F,y                         ; 9D5C
        sta     $50                             ; 9D5F
        and     #$20                            ; 9D61
        beq     L9D6B                           ; 9D63
L9D65:  lda     #$08                            ; 9D65
        jsr     LCFA1                           ; 9D67
        rts                                     ; 9D6A

; ----------------------------------------------------------------------------
L9D6B:  lda     $50                             ; 9D6B
        and     #$10                            ; 9D6D
        beq     L9D77                           ; 9D6F
        lda     #$4C                            ; 9D71
        jsr     LCFA1                           ; 9D73
        rts                                     ; 9D76

; ----------------------------------------------------------------------------
L9D77:  jsr     LCC43                           ; 9D77
        bcc     L9D65                           ; 9D7A
        lda     $05C6                           ; 9D7C
        jsr     LBB00                           ; 9D7F
        lda     $05C6                           ; 9D82
        jsr     LBCC8                           ; 9D85
        bne     L9DAD                           ; 9D88
        lda     $05C6                           ; 9D8A
        ldx     #$00                            ; 9D8D
        jsr     LC0C4                           ; 9D8F
        lda     #$09                            ; 9D92
        jsr     LCFA1                           ; 9D94
        lda     $05C6                           ; 9D97
        jsr     LC6F3                           ; 9D9A
        sty     $52                             ; 9D9D
        lda     $054D,y                         ; 9D9F
        jsr     LCAE1                           ; 9DA2
        ldy     $52                             ; 9DA5
        lda     #$FF                            ; 9DA7
        sta     $054D,y                         ; 9DA9
        rts                                     ; 9DAC

; ----------------------------------------------------------------------------
L9DAD:  lda     $01                             ; 9DAD
        sta     $0505                           ; 9DAF
        lda     #$06                            ; 9DB2
        jsr     LCFA1                           ; 9DB4
        rts                                     ; 9DB7

; ----------------------------------------------------------------------------
L9DB8:  jsr     LCB16                           ; 9DB8
        lda     $0502                           ; 9DBB
        cmp     #$09                            ; 9DBE
        bne     L9DC7                           ; 9DC0
        jsr     LCB71                           ; 9DC2
        bne     L9DE2                           ; 9DC5
L9DC7:  lda     $05C7                           ; 9DC7
        jsr     LC793                           ; 9DCA
        lda     #$02                            ; 9DCD
        jsr     LCFA1                           ; 9DCF
        lda     $05C7                           ; 9DD2
        jsr     LC762                           ; 9DD5
        jsr     LCB83                           ; 9DD8
        beq     L9DE3                           ; 9DDB
        lda     #$33                            ; 9DDD
        jsr     LCFA1                           ; 9DDF
L9DE2:  rts                                     ; 9DE2

; ----------------------------------------------------------------------------
L9DE3:  jsr     LCF43                           ; 9DE3
        lda     $0502                           ; 9DE6
        cmp     #$09                            ; 9DE9
        beq     L9E2F                           ; 9DEB
        lda     $0503                           ; 9DED
        bne     L9E01                           ; 9DF0
        lda     $81                             ; 9DF2
        clc                                     ; 9DF4
        adc     $05D1                           ; 9DF5
        bcc     L9DFC                           ; 9DF8
        lda     #$FF                            ; 9DFA
L9DFC:  sta     $81                             ; 9DFC
        jmp     L9E16                           ; 9DFE

; ----------------------------------------------------------------------------
L9E01:  jsr     LCB71                           ; 9E01
        bne     L9E2E                           ; 9E04
        asl     a                               ; 9E06
        tax                                     ; 9E07
        lda     $03BE,x                         ; 9E08
        clc                                     ; 9E0B
        adc     $05D1                           ; 9E0C
        bcc     L9E13                           ; 9E0F
        lda     #$FF                            ; 9E11
L9E13:  sta     $03BE,x                         ; 9E13
L9E16:  lda     $0503                           ; 9E16
        jsr     LCB71                           ; 9E19
        bne     L9E2E                           ; 9E1C
        stx     $51                             ; 9E1E
        txa                                     ; 9E20
        jsr     LCA62                           ; 9E21
        lda     $51                             ; 9E24
        jsr     LC5A9                           ; 9E26
        lda     #$1B                            ; 9E29
        jsr     LCFA1                           ; 9E2B
L9E2E:  rts                                     ; 9E2E

; ----------------------------------------------------------------------------
L9E2F:  ldx     #$02                            ; 9E2F
        stx     $51                             ; 9E31
L9E33:  ldx     $51                             ; 9E33
        bne     L9E4B                           ; 9E35
        lda     $050E                           ; 9E37
        bmi     L9E67                           ; 9E3A
        lda     $81                             ; 9E3C
        clc                                     ; 9E3E
        adc     $05D1                           ; 9E3F
        bcc     L9E46                           ; 9E42
        lda     #$FF                            ; 9E44
L9E46:  sta     $81                             ; 9E46
        jmp     L9E67                           ; 9E48

; ----------------------------------------------------------------------------
L9E4B:  lda     $51                             ; 9E4B
        jsr     LC6F3                           ; 9E4D
        lda     $050E,y                         ; 9E50
        cmp     #$FF                            ; 9E53
        beq     L9E67                           ; 9E55
        asl     a                               ; 9E57
        tax                                     ; 9E58
        lda     $03BE,x                         ; 9E59
        clc                                     ; 9E5C
        adc     $05D1                           ; 9E5D
        bcc     L9E64                           ; 9E60
        lda     #$FF                            ; 9E62
L9E64:  sta     $03BE,x                         ; 9E64
L9E67:  lda     $51                             ; 9E67
        jsr     LCA62                           ; 9E69
        dec     $51                             ; 9E6C
        bpl     L9E33                           ; 9E6E
        jsr     LC58E                           ; 9E70
        lda     #$00                            ; 9E73
        sta     $0503                           ; 9E75
        lda     #$1C                            ; 9E78
        jsr     LCFA1                           ; 9E7A
        rts                                     ; 9E7D

; ----------------------------------------------------------------------------
        lda     #$01                            ; 9E7E
        jsr     LA553                           ; 9E80
        jsr     LCF43                           ; 9E83
        lda     $05C7                           ; 9E86
        lda     $05C7                           ; 9E89
        lda     #$77                            ; 9E8C
        jsr     LE992                           ; 9E8E
        lda     #$09                            ; 9E91
        jsr     LE029                           ; 9E93
        lda     #$77                            ; 9E96
        jsr     LE992                           ; 9E98
        lda     $05C6                           ; 9E9B
        sta     $059C                           ; 9E9E
        lda     #$00                            ; 9EA1
        sta     $046E                           ; 9EA3
        lda     #$01                            ; 9EA6
        sta     $046F                           ; 9EA8
L9EAB:  jsr     LA61A                           ; 9EAB
        rts                                     ; 9EAE

; ----------------------------------------------------------------------------
        lda     #$01                            ; 9EAF
        jsr     LA553                           ; 9EB1
        jsr     LCF43                           ; 9EB4
        lda     #$00                            ; 9EB7
        ldx     #$0D                            ; 9EB9
L9EBB:  sta     $058C,x                         ; 9EBB
        dex                                     ; 9EBE
        bpl     L9EBB                           ; 9EBF
        lda     #$34                            ; 9EC1
        jsr     LE992                           ; 9EC3
        lda     $0502                           ; 9EC6
        sec                                     ; 9EC9
        sbc     #$0C                            ; 9ECA
        tax                                     ; 9ECC
        lda     L9F3F,x                         ; 9ECD
        sta     $059F                           ; 9ED0
        lda     L9F42,x                         ; 9ED3
        jsr     LE029                           ; 9ED6
L9ED9:  lda     $05C6                           ; 9ED9
        sta     $059C                           ; 9EDC
        lda     $0502                           ; 9EDF
        ldx     $0500                           ; 9EE2
        jsr     LC9C3                           ; 9EE5
        bcs     L9EEF                           ; 9EE8
        lda     $0516,y                         ; 9EEA
        beq     L9F33                           ; 9EED
L9EEF:  lda     $05C7                           ; 9EEF
        jsr     LC793                           ; 9EF2
        lda     $05C7                           ; 9EF5
        jsr     LC762                           ; 9EF8
        lda     #$34                            ; 9EFB
        jsr     LE992                           ; 9EFD
        lda     #$01                            ; 9F00
        sta     $046E                           ; 9F02
        sta     $046F                           ; 9F05
        jsr     LA61A                           ; 9F08
        lda     $050E                           ; 9F0B
        cmp     #$FF                            ; 9F0E
        bne     L9F13                           ; 9F10
        rts                                     ; 9F12

; ----------------------------------------------------------------------------
L9F13:  lda     $05C7                           ; 9F13
        jsr     LC6F3                           ; 9F16
        lda     $050E,y                         ; 9F19
        cmp     #$FF                            ; 9F1C
        beq     L9F3B                           ; 9F1E
        lda     $0503                           ; 9F20
        jsr     L99BF                           ; 9F23
        bpl     L9F33                           ; 9F26
        lda     #$00                            ; 9F28
        sta     $0504                           ; 9F2A
        lda     #$0A                            ; 9F2D
        jsr     LCFA1                           ; 9F2F
        rts                                     ; 9F32

; ----------------------------------------------------------------------------
L9F33:  dec     $059F                           ; 9F33
        beq     L9F3B                           ; 9F36
        jmp     L9ED9                           ; 9F38

; ----------------------------------------------------------------------------
L9F3B:  jsr     LBD17                           ; 9F3B
        rts                                     ; 9F3E

; ----------------------------------------------------------------------------
L9F3F:  asl     $04                             ; 9F3F
        php                                     ; 9F41
L9F42:  .byte   $0F                             ; 9F42
        bpl     L9F56                           ; 9F43
        lda     #$00                            ; 9F45
        jsr     LA553                           ; 9F47
        jsr     LCF43                           ; 9F4A
        lda     #$0D                            ; 9F4D
        ldx     $0502                           ; 9F4F
        cpx     #$10                            ; 9F52
        bne     L9F58                           ; 9F54
L9F56:  lda     #$0A                            ; 9F56
L9F58:  pha                                     ; 9F58
        lda     #$77                            ; 9F59
        jsr     LE992                           ; 9F5B
        pla                                     ; 9F5E
        jsr     LE029                           ; 9F5F
        lda     #$77                            ; 9F62
        jsr     LE992                           ; 9F64
        lda     #$00                            ; 9F67
        sta     $059E                           ; 9F69
        sta     $059C                           ; 9F6C
L9F6F:  lda     $059C                           ; 9F6F
        jsr     LC6F3                           ; 9F72
        lda     $054D,y                         ; 9F75
        cmp     #$FF                            ; 9F78
        bne     L9F7F                           ; 9F7A
        jmp     L9FA0                           ; 9F7C

; ----------------------------------------------------------------------------
L9F7F:  sty     $52                             ; 9F7F
        sta     $0503                           ; 9F81
        lda     $054E,y                         ; 9F84
        sta     $0504                           ; 9F87
        lda     #$00                            ; 9F8A
        sta     $046E                           ; 9F8C
        lda     #$01                            ; 9F8F
        ldx     $0502                           ; 9F91
        cpx     #$10                            ; 9F94
        bne     L9F9A                           ; 9F96
        lda     #$FF                            ; 9F98
L9F9A:  sta     $046F                           ; 9F9A
        jsr     LA61A                           ; 9F9D
L9FA0:  lda     $050E                           ; 9FA0
        cmp     #$FF                            ; 9FA3
        beq     L9FD3                           ; 9FA5
        lda     $05C7                           ; 9FA7
        jsr     LC6F3                           ; 9FAA
        lda     $050E,y                         ; 9FAD
        cmp     #$FF                            ; 9FB0
        beq     L9FD3                           ; 9FB2
        jsr     LCA04                           ; 9FB4
        beq     L9FD3                           ; 9FB7
        inc     $059C                           ; 9FB9
        lda     $059C                           ; 9FBC
        cmp     #$07                            ; 9FBF
        bne     L9F6F                           ; 9FC1
        lda     $059E                           ; 9FC3
        beq     L9FD3                           ; 9FC6
        lda     $05D4                           ; 9FC8
        sta     $0503                           ; 9FCB
        lda     #$41                            ; 9FCE
        jsr     LCFA1                           ; 9FD0
L9FD3:  rts                                     ; 9FD3

; ----------------------------------------------------------------------------
        lda     #$00                            ; 9FD4
        jsr     LA553                           ; 9FD6
        jsr     LCF43                           ; 9FD9
        lda     #$00                            ; 9FDC
        sta     $059D                           ; 9FDE
        jsr     LC6F3                           ; 9FE1
        lda     $054D,y                         ; 9FE4
        cmp     $0503                           ; 9FE7
        bne     LA012                           ; 9FEA
        lda     $054E,y                         ; 9FEC
        sta     $0504                           ; 9FEF
        lda     $054F,y                         ; 9FF2
        tax                                     ; 9FF5
        and     #$10                            ; 9FF6
        bne     LA00D                           ; 9FF8
        lda     $0502                           ; 9FFA
        cmp     #$12                            ; 9FFD
        .byte   $D0                             ; 9FFF
