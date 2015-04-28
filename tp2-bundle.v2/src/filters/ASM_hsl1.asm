; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion HSL 1                                      ;
;                                                                           ;
; ************************************************************************* ;
extern malloc
extern free  
extern rgbTOhsl2
extern hslTOrgb2

%define PIXEL_SIZE      4h
%define OFFSET_A?		0h
%define OFFSET_BLUE		1h
%define OFFSET_GREEN	2h
%define OFFSET_RED		3h

lemask: dd 0.0, 1.0, 1.0, 360.0, ; 360 | 1 | 1 | 0
shuf: db 0x00,0x04,0x08,0x0C, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF

; void ASM_hsl1(uint32_t w, uint32_t h, uint8_t* data, float hh, float ss, float ll)
global ASM_hsl1
ASM_hsl1: ;edi w, esi h, rdx data, xmm0 hh, xmm1 ss, xmm2 ll
	push rbp
	mov  rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub  rbp, 8

	mov edi, edi ;limpio parte alta
	mov esi, esi 
	xor r15, r15

	movq   xmm8, xmm2   ;xmm8 = ll
	pslldq xmm8, 4 		;xmm8 = 0 | 0 | ll | 0
	addps  xmm8, xmm1   ;xmm8 = 0 | 0 | ll | ss
	pslldq xmm8, 4      ;xmm8 = 0 | ll | ss | 0
	addps  xmm8, xmm0   ;xmm8 = 0 | ll | ss | hh
	pslldq xmm8, 4  	;xmm8 = ll | ss | hh | 0

	movdqu xmm9, [lemask] ;xmm9 = 360 | 1 | 1 | 0
	movdqu xmm6, xmm9	  ;xmm6 = 360 | 1 | 1 | 0
	movdqu xmm10, [shuf] 
	movdqu xmm7, xmm6
	psrldq xmm7, 12		  ;xmm7 =  0  | 0 | 0 | 360
	pslldq xmm7, 12		  ;xmm7 = 360 | 0 | 0 | 0
	psubd  xmm6, xmm7	  ;xmm6 =  0  | 1 | 1 | 0 


	mov rbx, rdi ;rbx = w
	mov r12, rsi ;r12 = h
	mov r13, rdx ;r13 = data

	mov rax, r12 ;rax = h
	mul rbx 	 ;rax = w * h
	mov r9, 4
	mul r9
	mov r14, rax ;r14 = w * h * 4

	mov rdi, 16
	call malloc
	mov r12, rax ;r12 = *dst

	.ciclo:
		mov rsi, r12
		lea rdi, [r13 + r15] ;rdi = posicion hasta donde se modificaron los pixeles
		call rgbTOhsl2 		   ;rsi = pixel en hsl ;pixel en registro = l s h a

		movdqu 	 xmm0, [r12]   ;xmm0 = pixel3 | pixel2 | pixel1 | pixel0
		cvtdq2pd xmm1, xmm0    ;xmm1 = pixel1 | pixel0
		
		pxor xmm3, xmm3		   ;xmm3 = 0
		punpcklbw xmm3, xmm1   ;xmm3 = l0 | s0 | h0 | a0
		movdqu xmm11, xmm3	   ;xmm11= xmm3
		call .sumar
		pshufb xmm11, xmm10	   ;xmm11=  0 | 0 | 0 | l0|s0|h0|a0
		addps  xmm12, xmm11    ;xmm12=  0 | 0 | 0 | pixel0
  
		pxor xmm3, xmm3		   ;xmm3 = 0
		punpckhbw xmm3, xmm1   ;xmm3 = l1 | s1 | h1 | a1 
		movdqu xmm11, xmm3
		call .sumar
		pshufb xmm11, xmm10	   ;xmm11=  0 | 0 | 0 | l1|s1|h1|a1
		pslldq  xmm11, 4	   ;xmm11=  0 | 0 | pixel1 | 0
		addps  xmm12, xmm11    ;xmm12=  0 | 0 | pixel1 | pixel0

		psrlw xmm0, 2 		   ;xmm0 = 0 | 0 | pixel3 | pixel2 
		cvtdq2pd xmm1, xmm0    ;xmm1 = pixel3 | pixel2

		pxor xmm3, xmm3		   ;xmm3 = 0
		punpcklbw xmm3, xmm1   ;xmm3 = l2 | s2 | h2 | a2
		movdqu xmm11, xmm3
		call .sumar
		pshufb xmm11, xmm10	   ;xmm11=  0 | 0 | 0 | l2|s2|h2|a2
		pslldq  xmm11, 8	   ;xmm11=  0 | pixel2 | 0 | 0
		addps  xmm12, xmm11    ;xmm12=  0 | pixel2 | pixel1 | pixel0

		pxor xmm3, xmm3		   ;xmm3 = 0
		punpckhbw xmm3, xmm1   ;xmm3 = l3 | s3 | h3 | a3 
		movdqu xmm11, xmm3
		call .sumar
		pshufb xmm11, xmm10	   ;xmm11=  0 | 0 | 0 | l3|s3|h3|a3
		pslldq  xmm11, 12	   ;xmm11=  pixel3 | 0 | 0 | 0
		addps  xmm12, xmm11    ;xmm12=  pixel3 | pixel2 | pixel1 | pixel0

		movdqu   [r12], xmm12
		movdqu   [r12], xmm0
		mov 	 rdi, r12
		lea 	 rsi, [r13 + r15]
		call 	 hslTOrgb2

		add r15, PIXEL_SIZE*5
		cmp r15, r14
	jl  .ciclo
	jmp .fin

	.sumar:
	pxor   xmm5 , xmm5
	pxor   xmm15, xmm15
	addps  xmm11, xmm8 	 ;xmm11 = l+ll | s+ss | h+hh | 0
	movdqu  xmm13, xmm9	 ;xmm13 = 360 | 1 | 1 | 0
	cmpleps xmm13, xmm11 ;xmm13 = 360 <= l+ll | 1 <= s+ss | 1 <= h+hh | 0
	
	movdqu  xmm5, xmm13  ;xmm5 = 360 <= l+ll | 1 <= s+ss | 1 <= h+hh | 0
	pand    xmm5, xmm7   ;xmm7 = 360 o 0 | 0 | 0 | 0
	subps   xmm11, xmm5  ;xmm11 = l+ll o l+ll-360 | s+ss | h+hh | 0

	movdqu  xmm5, xmm8	 ;xmm5 = l+ll |  s+ss  |  h+hh  | 0
	addps   xmm5, xmm6	 ;xmm5 = l+ll | s+ss+1 | h+hh+1 | 0
	pand    xmm5, xmm13  ;xmm5 = l+ll o 0 | s+ss+1 o 0 | h+hh+1 o 0 | 0
	pslldq  xmm5, 4 	 ;xmm5 = s+ss+1 o 0 | h+hh+1 o 0 | 0 | 0
	psrldq  xmm5, 4 	 ;xmm5 = 0 | s+ss+1 o 0 | h+hh+1 o 0 | 0
	subps   xmm11, xmm5  ;xmm11 = l+ll o l+ll-360 | s+ss o 1 | h+hh o 1 | 0
	 

	movdqu  xmm14, xmm11 ;xmm14 = l+ll | s+ss | h+hh | 0
	cmpltps xmm14, xmm15 ;xmm14 = l+ll < 0 | s+ss < 0 | h+hh < 0 | 0 

	movdqu  xmm5, xmm14  ;xmm5 = l+ll < 0 | s+ss < 0 | h+hh < 0 | 0 
	pand    xmm5, xmm7   ;xmm7 = 360 o 0 | 0 | 0 | 0
	addps   xmm11, xmm5  ;xmm11 = l+ll o l+ll-360 o l+ll+360 | s+ss o 1 | h+hh o 1 | 0

	movdqu  xmm5, xmm8	 ;xmm5 = l+ll |  s+ss  |  h+hh  | 0
	pslldq  xmm5, 4 	 ;xmm5 = s+ss o 0 | h+hh o 0 | 0 | 0
	psrldq  xmm5, 4 	 ;xmm5 = 0 | s+ss o 0 | h+hh o 0 | 0
	subps   xmm11, xmm5  ;xmm11 = l+ll o l+ll-360 o l+ll+360 | s+ss o 1 o 0 | h+hh o 1 o 0 | 0
	ret

	.fin:
	add rbp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
  ret


