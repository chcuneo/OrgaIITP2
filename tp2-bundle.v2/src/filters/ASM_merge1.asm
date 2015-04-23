; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Merge 1                                    ;
;                                                                           ;
; ************************************************************************* ;
extern malloc
global ASM_merge1

%define PIXEL_SIZE			4
%define OFFSET_RED   		0
%define OFFSET_GREEN 		1
%define OFFSET_BLUE  		2
%define OFFSET_TRANSPARENCY 3

section .text

; void ASM_merge1(uint32_t w, uint32_t h, uint8_t* data1, uint8_t* data2, float value)
ASM_merge1: ;edi = w, esi = h, rdx = data1, rcx = data2, xmm0 = value
	push rbp
	mov  rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub  rsp, 8

	;limpio parte alta
	mov edi, edi
	mov esi, esi

	;guardo a registros seguros
	mov rbx, rdi ; rbx = w
	mov r12, rsi ; r12 = h
	mov r13, rdx ; r13 = data1
	mov r14, rcx ; r14 = data2

	;jmp .CrearMatriz
	;.CrearMatriz:
	mov  rax, r12
	mul  rdi      ; rdi = w * h
	mov  r12, rdi ; r12 = w * h
	;call malloc   ; rax = *mat
	;mov  r15, rax ; r15 = *mat
	jmp  .CargarMerge

	.CargarMerge:
	;cargo 1-value
	mov    r9, 1 	  ; r9   = 1
	movq   xmm1, r9   ; xmm1 = 1
	subss  xmm1, xmm0 ; xmm1 = 1 - value

	;?????? esto no funca, hay que cambiarlo
	;phaddd xmm1, xmm1 ; xmm1 = 1 - value | 1 - value
	;phaddd xmm0, xmm0 ; xmm0 =   value 	 |   value 
	;?????? 

	xor r8, r8


	.cicloCarga:
	;guardo de a 4 pixeles
	movdqu   xmm2, [r13 + r8 * PIXEL_SIZE] ; xmm2 = pixel3 | pixel2 | pixel1 | pixel0
	cvtps2pd xmm3, xmm2  				   ; xmm3 = pixel1 | pixel0
	psrldq   xmm2, 8     				   ; xmm2 =   0	   |	0   | pixel3 | pixel2
	cvtps2pd xmm4, xmm2 				   ; xmm4 = pixel3 | pixel2
	
	;multiplico por value
	mulpd 	 xmm3, xmm0					   ; xmm3 = pixel1 * value | pixel0 * value 
	mulpd 	 xmm4, xmm0					   ; xmm4 = pixel3 * value | pixel2 * value 
	
	;guardo de a 4 pixeles
	movdqu   xmm5, [r14 + r8 * PIXEL_SIZE] ; xmm5 = pixel3' | pixel2' | pixel1' | pixel0'
	cvtps2pd xmm6, xmm5  				   ; xmm6 = pixel1' | pixel0'
	psrldq   xmm5, 8     				   ; xmm5 =   0 	|    0    | pixel3' | pixel2'
	cvtps2pd xmm7, xmm5 				   ; xmm7 = pixel3' | pixel2'

	;multiplico por 1-value
	mulpd 	 xmm6, xmm1					   ; xmm6 = pixel1' * (1-value) | pixel0' * (1-value) 
	mulpd 	 xmm7, xmm1					   ; xmm7 = pixel3' * (1-value) | pixel2' * (1-value) 

    ;sumo los elementos
    movq      xmm8, xmm3				   ; xmm8 = pixel1 * value | pixel0 * value 
    movq      xmm9, xmm3				   ; xmm9 = pixel1 * value | pixel0 * value 
	punpckhbw xmm8, xmm6			       ; xmm8 = A1 | A1' | B1 | B1' | G1 | G1' | R1 | R1' |
    punpcklbw xmm9, xmm6			       ; xmm9 = A0 | A0' | B0 | B0' | G0 | G0' | R0 | R0' |
	phaddw	  xmm8, xmm9				   ; xmm8 = pixel1rec | pixel0 rec

    movq      xmm9 , xmm4				   ; xmm9  = pixel3 * value | pixel2 * value
    movq      xmm10, xmm4				   ; xmm10 = pixel3 * value | pixel2 * value
	punpckhbw xmm9 , xmm7				   ; xmm9  = A3 | A3' | B3 | B3' | G3 | G3' | R3 | R3' |
    punpcklbw xmm10, xmm7				   ; xmm10 = A2 | A2' | B2 | B2' | G2 | G2' | R2 | R2' |
	phaddw	  xmm9 , xmm10				   ; xmm9  = pixel3rec | pixel2 rec

	;convierto a ps y los coloco juntos
	cvtpd2ps xmm9 , xmm9				   ; xmm9  = 0 | 0 | pixel1recalc | pixel0recalc
	cvtpd2ps xmm10, xmm10				   ; xmm10 = 0 | 0 | pixel3recalc | pixel2recalc
	pslldq   xmm10, 8					   ; xmm10 = pixel3recalc | pixel2recalc |  0  |  0  |
	addss	 xmm10, xmm9				   ; xmm10 = pixel3recalc | pixel2recalc | pixel1recalc | pixel0recalc
	movdqu  [r13 + r8 * PIXEL_SIZE], xmm10

	jmp .proximo

	.proximo:
	cmp r8, r12
	jge .termine
	add r8, PIXEL_SIZE * 4
	jmp .cicloCarga

	.termine:
	mov rax, r15

	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
  	ret