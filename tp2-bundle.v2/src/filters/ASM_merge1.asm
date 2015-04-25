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

;mov r12, 65536
;cvtsi2ss xmm2, r8


xorps xmm5, xmm5

xorps xmm2, xmm2
movdqu xmm2, [uno]



xorps xmm1, xmm1        ; xmm1 = 0 | 0 | 0 | 0
addss xmm1, xmm0        ; xmm1 = 0 | 0 | 0 | value
pslldq xmm1, 4          ; xmm1 = 0 | 0 | value | 0
addss xmm1, xmm0        ; xmm1 = 0 | 0 | value | value
pslldq xmm1, 4          ; xmm1 = 0 | value | value | 0
addss xmm1, xmm0        ; xmm1 = 0 | value | value | value
pslldq xmm1, 4          ; xmm1 = value | value | value | 0
addss xmm1, xmm2        ; xmm1 = value | value | value | 1



mov    r9d, 1 
xorps xmm2, xmm2			 
cvtsi2ss xmm2, r9d
subss  xmm2, xmm0 ; xmm1 = 1 - value


xorps xmm9, xmm9        ; xmm9 = 0 | 0 | 0 | 0
addss xmm9, xmm2        ; xmm9 = 0 | 0 | 0 | 1-value
pslldq xmm9, 4          ; xmm9 = 0 | 0 | 1-value | 0
addss xmm9, xmm2        ; xmm9 = 0 | 0 | 1-value |1- value
pslldq xmm9, 4          ; xmm9 = 0 | 1-value | 1-value | 0
addss xmm9, xmm2        ; xmm9 = 0 | 1-value | 1-value | 1-value
pslldq xmm9, 4          ; xmm9 = 1-value | 1-value | 1-value | 0



.ciclo:

	movdqu xmm3, [r13]
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
	
	
	cvtdq2ps xmm4,xmm4    ; convertimos a float		
	mulps xmm4,xmm1       ; multiplicamos por value
	
	;packssdw xmm4,xmm5    ; xmm4 = primeros 4 resultados
	;packuswb xmm4,xmm5    ; los devolvemos a byte
	

	cvtdq2ps xmm6,xmm6    ; convertimos a float		
	mulps xmm6,xmm1       ; multiplicamos por value
	;packssdw xmm6,xmm5    ; xmm4 = primeros 4 resultados
	;packuswb xmm6,xmm5    ; los devolvemos a byte

	cvtdq2ps xmm7,xmm7    ; convertimos a float		
	mulps xmm7,xmm1       ; multiplicamos por value
	
	;packssdw xmm7,xmm7    ; xmm4 = primeros 4 resultados
	;packuswb xmm7,xmm7    ; los devolvemos a byte



	cvtdq2ps xmm8,xmm8    ; convertimos a float		
	mulps xmm8,xmm1       ; multiplicamos por value
;	packssdw xmm8,xmm8    ; xmm4 = primeros 4 resultados
;	packuswb xmm8,xmm8    ; los devolvemos a byte
	

	

	movdqu xmm10, [r14]
	movdqu xmm11, xmm10
	punpcklbw xmm11, xmm5  ; extendemos a 16 bits los 8 numeros de la parte baja.
	movdqu xmm12, xmm11     ; los 8 numeros de la parte baja en 32 bit
	punpcklwd xmm11,xmm5   ; extendemos a 32 bits los 4 numeros de la parte baja-baja.
	punpckhwd xmm12,xmm5   ; extendemos a 32 bits los 4 numeros de la parte baja-alta.


	movdqu xmm13, xmm10
	punpckhbw xmm13, xmm5  ; extendemos a 16 bits los 8 numeros de la parte alta.
	movdqu xmm14, xmm13     ; los 8 numeros de la parte alta en 32 bit
	punpcklwd xmm13,xmm5   ; extendemos a 32 bits los 4 numeros de la parte alta-baja.
	punpckhwd xmm14,xmm5   ; extendemos a 32 bits los 4 numeros de la parte alta-alta.
	
	
	cvtdq2ps xmm11,xmm11    ; convertimos a float		
	mulps xmm11,xmm9       ; multiplicamos por 1- value
	
	;packssdw xmm4,xmm5    ; xmm4 = primeros 4 resultados
	;packuswb xmm4,xmm5    ; los devolvemos a byte
	

	cvtdq2ps xmm12,xmm12    ; convertimos a float		
	mulps xmm12,xmm9       ; multiplicamos por value
	;packssdw xmm6,xmm5    ; xmm4 = primeros 4 resultados
	;packuswb xmm6,xmm5    ; los devolvemos a byte

	cvtdq2ps xmm13,xmm13    ; convertimos a float		
	mulps xmm13,xmm9       ; multiplicamos por 1-value
	
	;packssdw xmm7,xmm7    ; xmm4 = primeros 4 resultados
	;packuswb xmm7,xmm7    ; los devolvemos a byte



	cvtdq2ps xmm14,xmm14    ; convertimos a float		
	mulps xmm14,xmm9       ; multiplicamos por value
;	packssdw xmm8,xmm8    ; xmm4 = primeros 4 resultados
;	packuswb xmm8,xmm8    ; los devolvemos a byte

	addps xmm4, xmm11
	addps xmm6, xmm12
	addps xmm7, xmm13
	addps xmm8, xmm14





; proceso de empaquetado:


	cvtps2dq xmm4, xmm4   ; lo volvemos a convertir en enteros de 32
	cvtps2dq xmm6, xmm6   ; lo volvemos a convertir en enteros de 32
	cvtps2dq xmm7, xmm7   ; lo volvemos a convertir en enteros de 32
	cvtps2dq xmm8, xmm8   ; lo volvemos a convertir en enteros de 32



	packusdw xmm4, xmm6 
	packusdw xmm7, xmm8 

	packuswb xmm4, xmm7

	;packusdw xmm6, xmm4 
	;packusdw xmm8, xmm7

	;packuswb xmm8, xmm6




	;xorps xmm9, xmm9        ; xmm9 = 0 | 0 | 0 | 0
	;paddb xmm9, xmm4        ; xmm9 = 0 | 0 | 0 | baja-baja
	;pslldq xmm9, 4          ; xmm9 = 0 | 0 | baja-baja | 0
	;paddb xmm9, xmm6        ; xmm9 = 0 | 0 | baja-baja | baja-alta
	;pslldq xmm9, 4          ; xmm9 = 0 | baja-baja | baja-alta | 0
	;paddb xmm9, xmm7        ; xmm9 = 0 | baja-baja | baja-alta | alta-baja
	;pslldq xmm9, 4          ; xmm9 = baja-baja | baja-alta | alta-baja | 0
	;paddb xmm9, xmm8        ; xmm9 = baja-baja | baja-alta | alta-baja | alta-alta



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



















