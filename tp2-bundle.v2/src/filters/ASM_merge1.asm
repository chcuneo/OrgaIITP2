; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Merge 1                                    ;
;                                                                           ;
; ************************************************************************* ;

; void ASM_merge1(uint32_t w, uint32_t h, uint8_t* data1, uint8_t* data2, float value)
global ASM_merge1


;value--> xmm0

section .data
uno: dd 1.0, 0.0, 0.0, 0.0
mask_ordenar: db 0x00, 0x04,0x08, 0x0c, 0x01, 0x05, 0x09, 0x0d, 0x02,0x06, 0x0a, 0x0e, 0x03, 0x07, 0x0b, 0x0f
mak_vovler: db 0x00, 

section .text


ASM_merge1:
	push rbp
	mov  rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub  rsp, 8


	mov r13, rdx ; r13 = data1
	mov r14, rcx ; r14 = data2



	;limpio parte alta
	mov edi, edi
	mov esi, esi

	mov r12d, edi
	mov r15d, esi
	mov rax, r12
	mul r15
	shr rax, 2
	xor r12, r12
	mov r12, rax

xorps xmm5, xmm5


movss xmm1, xmm0
shufps xmm1, xmm1 , 00h ; xmm9 = value | value | value | value



mov    r9d, 1 
xorps xmm9, xmm9			 
cvtsi2ss xmm9, r9d ; xmm9 = 1
subss  xmm9, xmm0 ; xmm9 = 1 - value
shufps xmm9, xmm9 , 00h ; xmm9 = 1-value | 1-value | 1-value | 1-value


.ciclo:

	movdqu xmm3, [r13]     ;en xmm3 4 pixeles a procesar
	movdqu xmm2, [mask_ordenar]
	pshufb xmm3, xmm2
	movdqu xmm4, xmm3
	punpcklbw xmm4, xmm5  ; extendemos a 16 bits los 8 numeros de la parte baja.
	movdqu xmm6, xmm4     ; los 8 numeros de la parte baja en 32 bit
	punpcklwd xmm4,xmm5   ; extendemos a 32 bits los 4 numeros de la parte baja-baja.
	punpckhwd xmm6,xmm5   ; extendemos a 32 bits los 4 numeros de la parte baja-alta.


	movdqu xmm7, xmm3
	punpckhbw xmm7, xmm5  ; extendemos a 16 bits los 8 numeros de la parte alta.
	movdqu xmm8, xmm7     ; los 8 numeros de la parte alta en 32 bit
	punpcklwd xmm7,xmm5   ; extendemos a 32 bits los 4 numeros de la parte alta-baja.
	punpckhwd xmm8,xmm5   ; extendemos a 32 bits los 4 numeros de la parte alta-alta.

	cvtdq2ps xmm6,xmm6    ; convertimos a float		
	mulps xmm6,xmm1       ; multiplicamos por value

	cvtdq2ps xmm7,xmm7    ; convertimos a float		
	mulps xmm7,xmm1       ; multiplicamos por value


	cvtdq2ps xmm8,xmm8    ; convertimos a float		
	mulps xmm8,xmm1       ; multiplicamos por value



	movdqu xmm10, [r14]
	pshufb xmm10, xmm2
	movdqu xmm11, xmm10
	punpcklbw xmm11, xmm5  ; extendemos a 16 bits los 8 numeros de la parte baja.
	movdqu xmm12, xmm11     ; los 8 numeros de la parte baja en 32 bit
	;punpcklwd xmm11,xmm5   ; extendemos a 32 bits los 4 numeros de la parte baja-baja.
	punpckhwd xmm12,xmm5   ; extendemos a 32 bits los 4 numeros de la parte baja-alta.


	movdqu xmm13, xmm10
	punpckhbw xmm13, xmm5  ; extendemos a 16 bits los 8 numeros de la parte alta.
	movdqu xmm14, xmm13     ; los 8 numeros de la parte alta en 32 bit
	punpcklwd xmm13,xmm5   ; extendemos a 32 bits los 4 numeros de la parte alta-baja.
	punpckhwd xmm14,xmm5   ; extendemos a 32 bits los 4 numeros de la parte alta-alta.
	
	

	cvtdq2ps xmm12,xmm12    ; convertimos a float		
	mulps xmm12,xmm9       ; multiplicamos por value


	cvtdq2ps xmm13,xmm13    ; convertimos a float		
	mulps xmm13,xmm9       ; multiplicamos por 1-value
	



	cvtdq2ps xmm14,xmm14    ; convertimos a float		
	mulps xmm14,xmm9       ; multiplicamos por value


	addps xmm6, xmm12
	addps xmm7, xmm13
	addps xmm8, xmm14





; proceso de empaquetado:

 ; lo volvemos a convertir en enteros de 32
	cvtps2dq xmm6, xmm6  
	cvtps2dq xmm7, xmm7  
	cvtps2dq xmm8, xmm8  



	packusdw xmm4, xmm6 
	packusdw xmm7, xmm8 

	packuswb xmm4, xmm7


	pshufb xmm4, xmm2

	movdqu [r13], xmm4
	add r13, 16
	add r14, 16
	
	dec r12
	cmp r12, 0
	je .fin
	jmp .ciclo
	
	.fin:

	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp

 ret



















