; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 1                                     ;
;                                                                           ;
; ************************************************************************* ;
	%define elimprim 	00000000h
; void ASM_blur1( uint32_t w, uint32_t h, uint8_t* data )
; 					rdi 	, rsi 		, rdx
global ASM_blur1
	divs: dd 9.0, 9.0, 9.0, 9.0
	shuf: db 0x00,0x04,0x08,0x0C, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
ASM_blur1:
	mov edi, edi 	; Extiendo ceros
	mov esi, esi 	
	mov r8, rdi 	; r8 = w 		Copio tamaños para calcular direcciones
	mov r9, rsi 	; r9 = h
	mov eax, elimprim
	dec rdi 		; rdi = w-1 : Limite del loop de pixeles en fila
	dec rsi 		; rsi = h-1 : Limite del loop de filas
	mov rbx, 1 		; rbx = 1 : "iw" itera pixeles en fila
	mov rcx, 1 		; rcx = 1 : "ih" itera filas
	movdqu xmm9, [divs] 	; xmm9 = | 9.0 | 9.0 | 9.0 | 9.0 |
	movdqu xmm10, [shuf] 	; Shuffle para pasar dword int a byte int

	; d es data

	loopw:
		movdqu xmm1, [rdx + rbx*4 - 4] 		; xmm1 = |d[0][iw+2]|d[0][iw+1]|d[0][iw]|d[0][iw-1]| d son 4 bytes A R G y B
		lea r12, [rdx + r8*4]
		lea r12, [r12 + rbx*4 - 4]
		movdqu xmm3, [r12]	; xmm3 = |d[1][iw+2]|d[1][iw+1]|d[1][iw]|d[1][iw-1]|
		pinsrd xmm1, eax, 03h 		; xmm1 = | 	0 		|d[0][iw+1]|d[0][iw]|d[0][iw-1]|
		pinsrd xmm3, eax, 03h  		; xmm3 = | 	0 		|d[1][iw+1]|d[1][iw]|d[1][iw-1]|
		movdqu xmm2, xmm1  			; xmm2 = xmm1
		movdqu xmm4, xmm3 			; xmm4 = xmm3
		pxor xmm8, xmm8 			; xmm8 = |0|
		punpcklbw xmm1, xmm8 		; xmm1 = |d[0][iw]	|d[0][iw-1]|  d ahora son 4 words A R G y B extendidos con ceros
		punpckhbw xmm2, xmm8 		; xmm2 = |  0 		|d[0][iw+1]|
		punpcklbw xmm3, xmm8 		; xmm3 = |d[1][iw]	|d[1][iw-1]|
		punpckhbw xmm4, xmm8 		; xmm4 = |  0 		|d[1][iw+1]|
		paddw xmm1, xmm2 			; xmm1 = |d[0][iw]|d[0][iw-1]+d[0][iw+1]|
		paddw xmm3, xmm4 			; xmm3 = |d[1][iw]|d[1][iw-1]+d[1][iw+1]|
		movdqu xmm2, xmm1 			; xmm2 = xmm1
		movdqu xmm4, xmm3 			; xmm4 = xmm3
		psrldq xmm2, 8 				; xmm2 = | 0 		|d[0][iw]|
		psrldq xmm4, 8 				; xmm4 = | 0 		|d[1][iw]|
		paddw xmm1, xmm2 			; xmm1 = | X 		|d[0][iw-1]+d[0][iw+1]+d[0][iw]| 
		paddw xmm3, xmm4 			; xmm3 = | X 		|d[1][iw-1]+d[1][iw+1]+d[1][iw]| 
		movdqu xmm2, xmm3 			; xmm2 = xmm3 
		lea r13, [r12 + 4] 			; posicion del pixel a calcular
		lea r12, [r12 + r8*4] 		; posicion del pixel de la fila siguiente a procesar
		looph:
			movdqu xmm0, xmm1 				;xmm0 suma pixeles fila anterior
			movdqu xmm1, xmm2 				;xmm1 suma pixeles fila actual
			movdqu xmm2, [r12 + rbx*4 - 4] ; xmm2 = |d[ih+1][iw+2] |d[ih+1][iw+1]|d[ih+1][iw]|d[ih+1][iw -1]|
			pinsrd xmm2, eax, 03h  						; xmm2 = | 	0 			|d[ih+1][iw+1]|d[ih+1][iw]|d[ih+1][iw -1]|
			movdqu xmm3, xmm2 			; xmm3 = xmm2
			punpcklbw xmm2, xmm8 		; xmm2 = |d[ih+1][iw]	|d[ih+1][iw-1]|  d ahora son 4 words A R G y B extendidos con ceros
			punpckhbw xmm3, xmm8 		; xmm3 = |  0 			|d[ih+1][iw+1]|
			paddw xmm2, xmm3 			; xmm2 = |d[ih+1][iw]|d[ih+1][iw-1]+d[ih+1][iw+1]|
			movdqu xmm3, xmm2 			; xmm3 = xmm2
			psrldq xmm3, 8 				; xmm3 = | 0 		|d[ih+1][iw]|
			paddw xmm2, xmm3 			; xmm2 = | X 		|d[ih+1][iw-1]+d[ih+1][iw+1]+d[ih+1][iw]| 
			paddw xmm0, xmm2
			paddw xmm0, xmm1 			; xmm0 = | X 		|SUMA d[x][y] con x = {ih-1, ih, ih+1} y = {iw-1, iw, iw+1}|
			punpcklwd xmm0, xmm8 		; xmm0 = |SUMA d[x][y] con x = {ih-1, ih, ih+1} y = {iw-1, iw, iw+1}|  4 dwords A R G y B extendidos con ceros
			CVTDQ2PS xmm3, xmm0 		; xmm3 = |	R 	| 	A 	| B 	| G 	|
			divps xmm3, xmm9 			; xmm3 = |	R/9	| 	A/9	| B/9 	| G/9 	|
			CVTPS2DQ xmm0, xmm3 		; xmm0 = |	R'	| 	A'	| B' 	| G' 	|
			pshufb xmm0, xmm10 			; xmm0 = |	0	| 	0	| 0 	|R|A|G|B|
			PEXTRD [r13], xmm0, 00b 	; grabo a memoria
			lea r13, [r13 + r8*4]
			lea r12, [r12 + r8*4]

			inc rcx
			cmp rcx, rsi
			jne looph
		mov rcx, 1
		inc rbx
		cmp rbx, rdi
		jne loopw

	ret