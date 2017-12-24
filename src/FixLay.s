.include "def.inc"
.globl      ClearFixlay
.globl		SetFixlayText
.globl		SetFixlayTextEx

ClearFixlay:                                                                    
        lea     (REG_VRAMRW).l, a0        | REG_VRAMRW
        move.w  #0x7002, d0
        move.w  d0, d3
        moveq   #0x27, d1               | loop time 0x28

_fix_out_dbfLoop:                              
        moveq   #0x1B, d2               | loop time 0x1c

_fix_in_dbfLoop:                               
        move.w  d3, -2(a0)              | REG_VRAMADDR
        move.w  #0xF20, (a0)
        addq.w  #1, d3
        dbf     d2, _fix_in_dbfLoop            
        addi.w  #0x20, d0               | to next cloumn
        move.w  d0, d3
        dbf     d1, _fix_out_dbfLoop          | loop time 0x1c

        st      A5Seg.TextOutputDefaultPalIndex(a5) | bit0~4: Pal index
                                        | bit7: 0, use this index
        rts



| params:
|     a0: ptr to fixlay output struct
SetFixlayText:                                                              
        move.w (a0), d0               
        move.w  d0, d2                
| End of function SetFixlayText

| params:
|     a0: ptr to fixlay output struct
|     d2: offset in SCB1
SetFixlayTextEx:                        
                                        
        addq.l  #2, a0
        tst.b   A5Seg.TextOutputDefaultPalIndex(a5) | bit0~4: Pal index
                                        | bit7: 0, use this index
        bmi.s   _SetFixlayTextEx_doNotUseDefaultPal
        move.b  A5Seg.TextOutputDefaultPalIndex(a5), d1 | bit0~4: Pal index
                                        | bit7: 0, use this index
        andi.w  #0xF, d1                | d1: pal index
        ror.w   #4, d1
        move.b  (a0)+, d0               | d0: pal | tilenum.high
        andi.w  #0xF, d0
        move.b  d0, -(sp)
        move.w  (sp)+, d0
        clr.b   d0
        or.w    d1, d0
        bra.s   loc_6F96
| ---------------------------------------------------------------------------

_SetFixlayTextEx_doNotUseDefaultPal:                    | CODE XREF: SetFixlayTextEx+6j
        move.b  (a0)+, d0
        move.b  d0, -(sp)
        move.w  (sp)+, d0
        clr.b   d0

loc_6F96:                                                                      
        move.w  d2, A5Seg.TextOutputOffset(a5)
        move.w  d0, A5Seg.TextOutputEntryHigh(a5)

loc_6F9E:                               | CODE XREF: SetFixlayTextEx+6Ej
        moveq   #0, d1
        move.b  (a0)+, d1
        cmpi.b  #0xD, d1
        bne.s   _SetFixlayTextEx_putChar
        cmpi.b  #0xA, (a0)
        bne.s   _SetFixlayTextEx_putChar
        tst.b   (a0)+                   | ����� $D(\r) �� $A(\n)
        move.w  A5Seg.TextOutputOffset(a5), d2
        addq.w  #1, d2
        move.w  A5Seg.TextOutputEntryHigh(a5), d0
        bra.s   loc_6F96
| ---------------------------------------------------------------------------

_SetFixlayTextEx_putChar:              
                                       
        cmpi.b  #0xFE, d1
        beq   SetFixlayText           | params:
                                        |     a0: ptr to fixlay output struct
        cmpi.b  #0xFF, d1
        beq.s   _SetFixlayTextEx_End
        or.w    d0, d1                  | d1: pal num | tile num
        swap    d2
        move.w  d1, d2
        move.l  d2, (REG_VRAMADDR).l      
        swap    d2
        addi.w  #0x20, d2               | ����һ��
        bra.s   loc_6F9E
| ---------------------------------------------------------------------------

_SetFixlayTextEx_End:                                  
        addq.w  #1, A5Seg.TextOutputOffset(a5)
        rts
| End of function SetFixlayTextEx