; code is setup for timer 1 in 8-bit mode with timer 2. code for timer 0 is commented out


.include "m8535def.inc"
.cseg

.org $0000
	rjmp RESET      ;Reset handle
   rjmp ext_int0
   rjmp ext_int1
   rjmp t2_comp_int                    ; t2comp
   rjmp t2_OV_int
   rjmp t1cap
   rjmp t1compa
   rjmp t1compb
   rjmp t1overflow
   rjmp t0overflow                     ; 10
   rjmp wut                            ; 11
   rjmp wut                            ; 12
   rjmp wut                            ; 13
   rjmp wut                            ; 14
   rjmp adc_int                        ; 15
   rjmp wut                            ; 16
   rjmp wut                            ; 17
   rjmp wut                            ; 18
   rjmp ext_int2                       ; 19


.DSEG

.org SRAM_START

compare:                                           .BYTE 1   
dir:                                               .BYTE 1   


.CSEG


ext_int0:
ext_int1:
t2_OV_int:
t1cap:
t1compb:
t1overflow:
t0overflow:
adc_int:                            ; 17
wut:                            ; 18
ext_int2:                       ; 19

   reti


;-----------------------------------------------

t1compa:    

   reti

;-----------------------------------------------


t2_comp_int:                           ; t2comp

   push r16
   push r17
   push r28

   in r28,sreg
  
   lds r16,compare
   lds r17,dir

   cpi r17,1
   breq increasing

   cpi r16,0
   brne line92

   ldi r17,1
   sts dir,r17

   ldi r16,1
   rjmp wrap_up

line92:

   dec r16

   rjmp wrap_up

increasing:

   cpi r16,255
   brne line82

   clr r17
   sts dir,r17

   ldi r16,254
   rjmp wrap_up

line82:

   inc r16

wrap_up:

   sts compare,r16
   out ocr2,r16
;   out ocr0,r16
 
   clr r17                             ; write hi then lo. read lo then hi
   out ocr1ah,r17

   out ocr1al,r16                   

  
   out sreg,r28

   pop r28
   pop r17
   pop r16

   reti

;-----------------------------------------------


init_ports:		;uses no regs

   sbi ddrd,pd7                        ; oc2
   
;   sbi ddrb,pb3                        ; oc0
   
   sbi ddrd,pd5                        ; oc1a

   ret
	
;----------------------------------------

;init_timer_0:
;	
;
;
;   ldi r29, (1<<wgm00) | (1<<wgm01) | (1<<com01) | (1<<cs02)    ; 256 prescale
;
;	out	tccr0,r29
;
;   ldi r16,250
;   out ocr0,r16                        ; compare value
;
;	ret		

;----------------------------------------

init_timer_1:


   ; fast pwm 8-bit

   ldi r29, (1<<wgm10) | (1<<com1a1)

	out	tccr1a,r29                    ; com1a1 com1a0 com1b1 com1b0 ... wgm11 wgm10

   ldi r29, (1<<wgm12) | (1<<cs12) 

   out tccr1b,r29                      ; ... wgm13 wgm12 cs12 cs11 cs10

   clr r16                             ; write hi then lo. read lo then hi
   out ocr1ah,r16

   ldi r16,250
   out ocr1al,r16                        ; compare value

	ret		


;---------------------------------------
init_timer_2:
	

   ldi r29, (1<<wgm20) | (1<<wgm21) | (1<<com21) | (1<<com20)  | (1<<cs22) | (1<<cs21)    ; 256 prescale

	out	tccr2,r29

   ldi r16,250
   out ocr2,r16                        ; compare value

   in r29,timsk
   ldi r16,1<<ocie2                    ; compare match interrupt enabled
   or r29,r16
   out timsk,r29

	ret		


;------------------------------------------


RESET:
	ldi	r16,high(RAMEND) 
	out	SPH,r16	         
	ldi	r16,low(RAMEND)	 
	out	SPL,r16
	
   rcall init_ports

   ;rcall init_timer_0
   
   rcall init_timer_1
   
   rcall init_timer_2

   sei

main_loop:

   rjmp main_loop

