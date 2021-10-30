;------------------------------------------------------------------------
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2020/2021
;--------------------------------------------------------------
;
;		arrow keys to move 
;		press ESC to exit
;
;--------------------------------------------------------------

.8086
.model small
.stack 2048

dseg	segment para public 'data'

		Construir_nome	db	    "                            $"
		buffer	db	'                             ',13,10
				db 	'                             ',13,10
				db	'                             ',13,10
				db 	'                             ',13,10
				db	'                             ',13,10
				db	'                             ',13,10
				db	'                             ',13,10
				db	'                             ',13,10
				db	'                             ',13,10
				db	'                             ',13,10	
				db	'                             $',13,10
        String_nome1  	db	    "TAC$"
		String_nome2  	db	    "RATO$"
		String_nome3  	db	    "VINTE$"
		String_nome4  	db	    "GELADO$"
		String_nome5  	db	    "ASSEMBLY$"					
		Construir_nome2	db	    "TESTLEL              $"
		introduznome    db	    "Nome do Utilizador:$"
		pntinsufuciente	db	    "Pontuacao Insuficiente, Prima qualquer tecla$"
		labirinto		db		2000 dup (?)
		STR12	 		DB 		"            "		; String para 12 digitos
		DDMMAAAA 		db		"                     "
		Horas			dw		0					; Vai guardar a HORA actual
		Minutos			dw		0					; Vai guardar os minutos actuais
		Segundos	    dw		0					; Vai guardar os segundos actuais
		Old_seg			dw		0					; Guarda os últimos segundos que foram lidos
		Tempo_init		dw		0					; Guarda O Tempo de inicio do jogo
		Tempo_j			dw		0					; Guarda O Tempo que decorre o  jogo	
		String_TJ		db		"    $"
		String_num 		db 		"  0 $"
		indice_nome		dw		0					; indice que aponta para Construir_nome
        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'nivel1.TXT',0  	; Ficheiro Labirinto
		Menu_prin		db		'menu.TXT',0  		; Menu Principal
		jogo_acabou		db		'gameover.TXT',0	; Meno Game_Over
		player_won		db		'winner.TXT',0  	; Menu Winner
		top10fich		db		'top10.TXT',0  		; Menu Top10
		editorfich		db		'editor.TXT',0
		editorfich2		db		'editor2.TXT',0
		building		db		' '
        HandleFich      dw      0
        car_fich        db      ?

		msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$"
		msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$"
		msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$"

		POSyplayer      db	10						; Posição de da string para introduzir Nome de Utilizador
		POSxplayer		db	29						; Posição de da string para introduzir Nome de Utilizador

		string			db	"Teste pr�tico de T.I",0
		Car				db	32						; Guarda um caracter do Ecran 
		Cor				db	7						; Guarda os atributos de cor do caracter
		POSy			db	2						; a linha pode ir de [1 .. 25]
		POSx			db	3						; POSx pode ir [1..80]	
		POSya			db	2						; Posição anterior de y
		POSxa			db	3						; Posição anterior de x
		POSyteste       db	3						; Posição de teste para fazer verificações
		POSxteste		db	3						; Posição de teste para fazer verificações
		POSyRand		dw	3						; Posição Random
		POSxRand		dw	3						; Posição Random
		time		    dw	0						; Para o timer
		ultimo_num_aleat dw 0
		displacement    dw	?						; Para escrever no índice certo das matrizes
		nivel		    dw	1						; nivel atual
		Carteste		db	32  					; Guarda um caracter de teste para fazer verificações
		tam_palavra		dw	0						; Tamanho da palavra
		apanhadas		dw	0						; Letras apanhadas
		POSpontosx		db	45						; Posição dos pontos
		POSpontosy		db	20						; Posição dos pontos
		;count			dw  9900
		pontuacao		dw  500						; Guarda a pontuação do jogador
		extraipontuacao dw  0						; Para ler o top10
		guardar			db	1						; Guarda se construimos com paredes ou espaços no editor
		tamanhomatriz   dw  0 						; Para usar com o exportar matriz
		mode            db  0						; Guarda se estamos no jogo ou no editor, para o Trata_Horas
		teclaseditar    db  "(Home) - gravar | (DEL) - construir paredes | (PAGE UP) - por letras$"
		makeletter		db 	'@'
		nomeplayerTEXT	db		"          $"
dseg	ends	

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg

;########################################################################
;Para controlar o cursor
goto_xy	macro		POSx,POSy			;FUNÇÃO PARA METER O CURSOR EM QUALQUER POSIÇÃO
		mov		ah,02h
		mov		bh,0					; numero da página
		mov		dl,POSx
		mov		dh,POSy
		int		10h						;interrupt para pôr o cursor num certo sítio, ver INTERRUP.TXT
endm
;########################################################################
; MOSTRA - Faz o display de uma string terminada em $   ;MOSTRA stringnome - imprime a string
MOSTRA MACRO STR 
MOV AH,09H
LEA DX,STR 
INT 21H
ENDM

; ------ FIM DAS MACROS ------
;########################################################################
	; $$\      $$\  $$$$$$\  $$$$$$\ $$\   $$\ 
	; $$$\    $$$ |$$  __$$\ \_$$  _|$$$\  $$ |
	; $$$$\  $$$$ |$$ /  $$ |  $$ |  $$$$\ $$ |
	; $$\$$\$$ $$ |$$$$$$$$ |  $$ |  $$ $$\$$ |
	; $$ \$$$  $$ |$$  __$$ |  $$ |  $$ \$$$$ |
	; $$ |\$  /$$ |$$ |  $$ |  $$ |  $$ |\$$$ |
	; $$ | \_/ $$ |$$ |  $$ |$$$$$$\ $$ | \$$ |
	; \__|     \__|\__|  \__|\______|\__|  \__|
;#######################################################################
Main  proc
		mov			ax, dseg
		mov			ds,ax
		
		mov			ax,0B800h
		mov			es,ax

		lea			dx,top10fich		; ler o top10.txt para a matriz
		call		LER_FICH
;################################################
	;$$\      $$\ $$$$$$$$\ $$\   $$\ $$\   $$\ 
	;$$$\    $$$ |$$  _____|$$$\  $$ |$$ |  $$ |
	;$$$$\  $$$$ |$$ |      $$$$\ $$ |$$ |  $$ |
	;$$\$$\$$ $$ |$$$$$\    $$ $$\$$ |$$ |  $$ |
	;$$ \$$$  $$ |$$  __|   $$ \$$$$ |$$ |  $$ |
	;$$ |\$  /$$ |$$ |      $$ |\$$$ |$$ |  $$ |
	;$$ | \_/ $$ |$$$$$$$$\ $$ | \$$ |\$$$$$$  |
	;\__|     \__|\________|\__|  \__| \______/ 
;################################################
Menu:
		call		apaga_ecran
		goto_xy		0,0
		lea			dx,Menu_prin  		; carregar para dx o ficheiro que queremos imprimir
		call		IMP_FICH  			; imprimir o ficheiro

		mov  ah, 07h 					; Espera para que o utilizador insira um caracter
  		int  21h
  		cmp  al, '1' 					; Se inserir o numero 1
  		je   nivel1_start 				; Vai para o labirinto
  		cmp  al, '2' 					; Se inserir o numero 2
  		je   top10 						; Vai para a lista do top10
		cmp  al, '3' 					; Se inserir o numero 3
		je  sair 						; Sai do programa
		cmp  al, '4' 					; Se inserir o numero 4
		je  editor 						; Vai para o dditor
		jmp Menu 						; Se nao inserir nenhum dos valores volta a pedir

;############################################################################################
	;$$\        $$$$$$\  $$$$$$$\  $$$$$$\ $$$$$$$\  $$$$$$\ $$\   $$\ $$$$$$$$\  $$$$$$\  
	;$$ |      $$  __$$\ $$  __$$\ \_$$  _|$$  __$$\ \_$$  _|$$$\  $$ |\__$$  __|$$  __$$\ 
	;$$ |      $$ /  $$ |$$ |  $$ |  $$ |  $$ |  $$ |  $$ |  $$$$\ $$ |   $$ |   $$ /  $$ |
	;$$ |      $$$$$$$$ |$$$$$$$\ |  $$ |  $$$$$$$  |  $$ |  $$ $$\$$ |   $$ |   $$ |  $$ |
	;$$ |      $$  __$$ |$$  __$$\   $$ |  $$  __$$<   $$ |  $$ \$$$$ |   $$ |   $$ |  $$ |
	;$$ |      $$ |  $$ |$$ |  $$ |  $$ |  $$ |  $$ |  $$ |  $$ |\$$$ |   $$ |   $$ |  $$ |
	;$$$$$$$$\ $$ |  $$ |$$$$$$$  |$$$$$$\ $$ |  $$ |$$$$$$\ $$ | \$$ |   $$ |    $$$$$$  |
	;\________|\__|  \__|\_______/ \______|\__|  \__|\______|\__|  \__|   \__|    \______/ 
;############################################################################################
				; _   _ _______      ________ _        __ 
				;| \ | |_   _\ \    / /  ____| |      /_ |
				;|  \| | | |  \ \  / /| |__  | |       | |
				;| . ` | | |   \ \/ / |  __| | |       | |
				;| |\  |_| |_   \  /  | |____| |____   | |
				;|_| \_|_____|   \/   |______|______|  |_| V2

nivel1_start:
	lea 		bx,String_nome1		; vê o tamanho da nova string
	call		tam_str				;

	mov			pontuacao,500

	call			apaga_ecran
	goto_xy			0,0				; print do labirinto	
	lea  			dx, Fich
	call 			IMP_FICH
	call 		resetvars
	

	mov			time,99
	GOTO_XY		10,20
	MOSTRA 		String_nome1

	goto_xy 	71,20				; print do nivel em que estamos
	mov			ax,nivel
	call		PRINTDIG
nivel1_ciclo:						; só passa por aqui quando faz um movimento
	goto_xy	POSxa,POSya				; Vai para a posição anterior do cursor
	mov		ah, 02h					
	mov		dl, Car					; Repoe Caracter guardado 
	int		21H		
		
	goto_xy	POSx,POSy				; Vai para nova posição
	mov 	ah, 08h
	mov		bh,0					; numero da página
	int		10h		
	mov		Car, al					; Guarda o Caracter que está na posição do Cursor
	mov		Cor, ah					; Guarda a cor que está na posição do Cursor

	call	pontosmoveu				; subtrai os pontos que custam mover

	; verifica se estamos numa letra, se é uma letra que queremos e imprime-a 
	lea 	bx,String_nome1
	call	Verificar_Letra 

	goto_xy POSpontosx,POSpontosy 	; desenha a pontuação
	mov		ax,pontuacao
	call 	PRINTDIG

	mov		ax,apanhadas			; vê se já acabámos o nivel
	cmp		tam_palavra,ax
	je		nivel2_start

	call 	prosseguir
	jmp 	nivel1_ciclo

				; _   _ _______      ________ _        ___  
				;| \ | |_   _\ \    / /  ____| |      |__ \ 
				;|  \| | | |  \ \  / /| |__  | |         ) |
				;| . ` | | |   \ \/ / |  __| | |        / / 
				;| |\  |_| |_   \  /  | |____| |____   / /_ 
				;|_| \_|_____|   \/   |______|______| |____| V2

nivel2_start:
	lea 		bx,String_nome2		; vê o tamanho da nova string
	call		tam_str				;
			
	call			apaga_ecran
	goto_xy			0,0				; print do labirinto	
	lea  			dx, Fich
	call 			IMP_FICH
	call 		resetvars

	mov			time,90
	GOTO_XY		10,20
	MOSTRA 		String_nome2

	mov 		nivel,2
	goto_xy 	71,20				; print do nivel em que estamos
	mov			ax,nivel
	call		PRINTDIG
nivel2_ciclo:
	goto_xy	POSxa,POSya				; Vai para a posição anterior do cursor
	mov		ah, 02h					
	mov		dl, Car					; Repoe Caracter guardado 
	int		21H		
		
	goto_xy	POSx,POSy				; Vai para nova posição
	mov 	ah, 08h
	mov		bh,0					; numero da página
	int		10h		
	mov		Car, al					; Guarda o Caracter que está na posição do Cursor
	mov		Cor, ah					; Guarda a cor que está na posição do Cursor

	call	pontosmoveu				; subtrai os pontos que custam mover

	; verifica se estamos numa letra, se é uma letra que queremos e imprime-a 
	lea 	bx,String_nome2	
	call	Verificar_Letra 

	goto_xy POSpontosx,POSpontosy 	; desenha a pontuação
	mov		ax,pontuacao
	call 	PRINTDIG

	mov		ax,apanhadas			; vê se já acabámos o nivel
	cmp		tam_palavra,ax
	je 		nivel3_start
			
	call 	prosseguir
	jmp 	nivel2_ciclo

				; _   _ _______      ________ _        ____  
				;| \ | |_   _\ \    / /  ____| |      |___ \ 
				;|  \| | | |  \ \  / /| |__  | |        __) |
				;| . ` | | |   \ \/ / |  __| | |       |__ < 
				;| |\  |_| |_   \  /  | |____| |____   ___) |
				;|_| \_|_____|   \/   |______|______| |____/  V2
nivel3_start:
	lea 		bx,String_nome3		; vê o tamanho da nova string
	call		tam_str				;

	call			apaga_ecran
	goto_xy			0,0				; print do labirinto	
	lea  			dx, Fich
	call 			IMP_FICH
	call 		resetvars

	mov			time,80
	GOTO_XY		10,20
	MOSTRA 		String_nome3

	mov 		nivel,3
	goto_xy 	71,20				; print do nivel em que estamos
	mov			ax,nivel
	call		PRINTDIG
nivel3_ciclo:
	goto_xy	POSxa,POSya				; Vai para a posição anterior do cursor
	mov		ah, 02h					
	mov		dl, Car					; Repoe Caracter guardado 
	int		21H		
		
	goto_xy	POSx,POSy				; Vai para nova posição
	mov 	ah, 08h
	mov		bh,0					; numero da página
	int		10h		
	mov		Car, al					; Guarda o Caracter que está na posição do Cursor
	mov		Cor, ah					; Guarda a cor que está na posição do Cursor

	call	pontosmoveu				; subtrai os pontos que custam mover

	; verifica se estamos numa letra, se é uma letra que queremos e imprime-a 
	lea 	bx,String_nome3
	call	Verificar_Letra

	goto_xy POSpontosx,POSpontosy 	; desenha a pontuação
	mov		ax,pontuacao
	call 	PRINTDIG

	mov		ax,apanhadas			; vê se já acabámos o nivel
	cmp		tam_palavra,ax
	jbe 		nivel4_start

	call	prosseguir
	jmp 	nivel3_ciclo

				; _   _ _______      ________ _        _  _   
				;| \ | |_   _\ \    / /  ____| |      | || |  
				;|  \| | | |  \ \  / /| |__  | |      | || |_ 
				;| . ` | | |   \ \/ / |  __| | |      |__   _|
				;| |\  |_| |_   \  /  | |____| |____     | |  
				;|_| \_|_____|   \/   |______|______|    |_|  V2

nivel4_start:
	lea 		bx,String_nome4		; vê o tamanho da nova string
	call		tam_str
	
	call			apaga_ecran
	goto_xy			0,0				; print do labirinto	
	lea  			dx, Fich
	call 			IMP_FICH
	call 		resetvars

	mov			time,70
	GOTO_XY		10,20
	MOSTRA 		String_nome4

	mov 		nivel,4
	goto_xy 	71,20				; print do nivel em que estamos
	mov			ax,nivel
	call		PRINTDIG
nivel4_ciclo:
	goto_xy	POSxa,POSya				; Vai para a posição anterior do cursor
	mov		ah, 02h					
	mov		dl, Car					; Repoe Caracter guardado 
	int		21H		
		
	goto_xy	POSx,POSy				; Vai para nova posição
	mov 	ah, 08h
	mov		bh,0					; numero da página
	int		10h		
	mov		Car, al					; Guarda o Caracter que está na posição do Cursor
	mov		Cor, ah					; Guarda a cor que está na posição do Cursor

	call	pontosmoveu				; subtrai os pontos que custam mover

	; verifica se estamos numa letra, se é uma letra que queremos e imprime-a 
	lea 	bx,String_nome4
	call	Verificar_Letra

	goto_xy POSpontosx,POSpontosy 	; desenha a pontuação
	mov		ax,pontuacao
	call 	PRINTDIG

	mov		ax,apanhadas			; vê se já acabámos o nivel
	cmp		tam_palavra,ax
	je 		nivel5_start
			
	call	prosseguir
	jmp 	nivel4_ciclo				

				; _   _ _______      ________ _        _____ 
				;| \ | |_   _\ \    / /  ____| |      | ____|
				;|  \| | | |  \ \  / /| |__  | |      | |__  
				;| . ` | | |   \ \/ / |  __| | |      |___ \ 
				;| |\  |_| |_   \  /  | |____| |____   ___) |
				;|_| \_|_____|   \/   |______|______| |____/  V2

nivel5_start:
	lea 		bx,String_nome5		; vê o tamanho da nova string
	call		tam_str
	
	call			apaga_ecran
	goto_xy			0,0				; print do labirinto	
	lea  			dx, Fich
	call 			IMP_FICH
	call 		resetvars

	mov			time,60
	GOTO_XY		10,20
	MOSTRA 		String_nome5

	mov 		nivel,5
	goto_xy 	71,20				; print do nivel em que estamos
	mov			ax,nivel
	call		PRINTDIG
nivel5_ciclo:
	goto_xy	POSxa,POSya				; Vai para a posição anterior do cursor
	mov		ah, 02h					
	mov		dl, Car					; Repoe Caracter guardado 
	int		21H		
		
	goto_xy	POSx,POSy				; Vai para nova posição
	mov 	ah, 08h
	mov		bh,0					; numero da página
	int		10h		
	mov		Car, al					; Guarda o Caracter que está na posição do Cursor
	mov		Cor, ah					; Guarda a cor que está na posição do Cursor

	call	pontosmoveu				; subtrai os pontos que custam mover

	; verifica se estamos numa letra, se é uma letra que queremos e imprime-a 
	lea 	bx,String_nome5
	call	Verificar_Letra

	goto_xy POSpontosx,POSpontosy 	; desenha a pontuação
	mov		ax,pontuacao
	call 	PRINTDIG

	mov		ax,apanhadas			; vê se já acabámos o nivel
	cmp		tam_palavra,ax
	je 		won
	
	call	prosseguir
	jmp 	nivel5_ciclo		
;##################################################################
	;$$$$$$$$\ $$$$$$$\  $$$$$$\ $$$$$$$$\  $$$$$$\  $$$$$$$\  
	;$$  _____|$$  __$$\ \_$$  _|\__$$  __|$$  __$$\ $$  __$$\ 
	;$$ |      $$ |  $$ |  $$ |     $$ |   $$ /  $$ |$$ |  $$ |
	;$$$$$\    $$ |  $$ |  $$ |     $$ |   $$ |  $$ |$$$$$$$  |
	;$$  __|   $$ |  $$ |  $$ |     $$ |   $$ |  $$ |$$  __$$< 
	;$$ |      $$ |  $$ |  $$ |     $$ |   $$ |  $$ |$$ |  $$ |
	;$$$$$$$$\ $$$$$$$  |$$$$$$\    $$ |    $$$$$$  |$$ |  $$ |
	;\________|\_______/ \______|   \__|    \______/ \__|  \__|
;##################################################################
editor:
	call	apaga_ecran
nivel1_startv:
	mov			pontuacao,500
	call 		resetvars
	goto_xy			0,0
	lea  			dx, editorfich
	call 			IMP_FICH		; Imprime o template para fazer o labirinto
	goto_xy 	5,18
	mostra teclaseditar 

nivel1_ciclov:						; só passa por aqui quando faz um movimento
	mov		time,99
	mov 	guardar,1
	goto_xy	POSxa,POSya				; Vai para a posição anterior do cursor
	mov		ah, 02h					
	mov		dl,building				; Repoe Caracter guardado 
	int		21H		

	call 	prosseguir2				
	cmp 	guardar,0
	je		makeedit
	jmp 	nivel1_ciclov
paragrafo:							; adiciona o parágrafo: ,13,10
	mov al, 13
	mov	es:[bx+si],al
	mov al,10
	mov	es:[bx+si],al
	add dx,160
	jmp ciclo20
makeedit:
	mov	cx,2000						; repete 4000 vezes para 4000 bytes
	xor si,si
	xor bx,bx
	xor ax,ax
	xor dx,dx
	mov dx,158
	
ciclo20:							; copia o ecrã para a variavel labirinto
	mov	al,es:[bx+si]				; mov para o labirinto o caracter atual do ecrã
	mov	labirinto[si],al			;
	mov ax,bx
	add ax,si
	inc bx
	inc si
	cmp ax,dx
	je  paragrafo					; 25 linhas, 80 colunas, no final da coluna põe um parágrafo
	loop ciclo20

	lea		dx, editorfich2			
	lea		si, labirinto
	mov  	tamanhomatriz, 2000
	call 	exportarmatriz			; exporta uma matriz para um ficheiro

	call 	apaga_ecran

	call	Main
;########################################################################
won:
	call 	winner
;########################################################################
	; $$$$$$$$\  $$$$$$\  $$$$$$$\          $$\   $$$$$$\  
	; \__$$  __|$$  __$$\ $$  __$$\       $$$$ | $$$ __$$\ 
	;    $$ |   $$ /  $$ |$$ |  $$ |      \_$$ | $$$$\ $$ |
	;    $$ |   $$ |  $$ |$$$$$$$  |        $$ | $$\$$\$$ |
	;    $$ |   $$ |  $$ |$$  ____/         $$ | $$ \$$$$ |
	;    $$ |   $$ |  $$ |$$ |              $$ | $$ |\$$$ |
	;    $$ |    $$$$$$  |$$ |            $$$$$$\\$$$$$$  /
	;    \__|    \______/ \__|            \______|\______/ 
;########################################################################
top10:
	call	apaga_ecran
	goto_xy 0,0
	lea  	dx, top10fich   		; carregar para dx o ficheiro que queremos imprimir
    call 	IMP_FICH   				; imprimir o ficheiro

	mov  	ah, 07h 				; Espera para que o utilizador clique em alguma coisa
  	int  	21h
	call	Main
;-----------------------
sair:
	call 	END_GAME
;-----------------------
Main	endp
;########################################################################
tam_str proc
	push 	di
	mov 	di,0
tam_string:							; ver o tamanho da nossa string e guardá-lo
	inc 	di
	cmp 	byte ptr [bx+di],'$'	; ver se já chegámos ao fim da string
	jne 	tam_string
	mov 	tam_palavra,di
	pop 	di
	ret
tam_str endp
;########################################################################
resetvars proc
	mov 	indice_nome,0	
	mov		apanhadas,0
	mov		bx,0

	mov		cx, 12
res_str:
	mov		Construir_nome[bx],' '
	inc		bx
	loop	res_str
inwall:
	call	novorandNum

setrandpos:
	mov		ax,POSxRand				; pões o POSxRand no POSx
	mov 	POSx,al
	mov 	POSxa,al
	mov		ax,POSyRand				; pões o POSyRand no POSy
	mov 	POSy,al
	mov 	POSya,al

	goto_xy	POSx,POSy				; Vai para nova posição
	mov 	ah, 08h
	mov		bh,0					; numero da página
	int		10h		
	mov		Car, al

	cmp		Car,' '
	jne		inwall
	ret
resetvars endp
;########################################################################
prosseguir proc
			
			goto_xy	78,0			; Mostra o caracter que está na posição do AVATAR
			mov		ah, 02h			; IMPRIME caracter da posição no canto
			mov		dl, Car				
			int		21H							
			goto_xy	POSx,POSy		; Vai para posição do cursor
;NAO_IMPRIME
IMPRIME:	mov		ah, 02h
			mov		dl, 190			; Coloca AVATAR
			int		21H	
			goto_xy	POSx,POSy		; Vai para posição do cursor
		
			mov		al, POSx		; Guarda a posição do cursor    If encontrou parede, 
			mov		POSxa, al
			mov		al, POSy		; Guarda a posição do cursor
			mov 	POSya, al
			mov     mode, 1
		
LER_SETA:	call 	LE_TECLA
			cmp		ah, 1
			je		ESTEND
			CMP 	AL, 27			; ESCAPE
			JE		FIM
			jmp		LER_SETA
		
ESTEND:		cmp 	al,48h			; compara se estás a pressionar uma seta de cima
			jne		BAIXO   		; se não, continua a testar se pressionou mais alguma seta
			call 	vercima
			ret

BAIXO:		cmp		al,50h
			jne		ESQUERDA
			call 	verbaixo
			ret

ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA
			call 	veresquerda
			ret

DIREITA:
			cmp		al,4Dh
			jne		LER_SETA 
			call 	verdireita
			ret

fim:				
			call MAIN
prosseguir endp
;########################################################################
prosseguir2 proc					; Para o editor
			
			goto_xy	78,0			; Mostra o caracter que está na posição do AVATAR
			mov		ah, 02h			; IMPRIME caracter da posição no canto
			mov		dl, Car				
			int		21H							
			goto_xy	POSx,POSy		; Vai para posição do cursor

;NAO_IMPRIME
IMPRIME:	mov		ah, 02h
			mov		dl, 190			; Coloca AVATAR
			int		21H	
			goto_xy	POSx,POSy		; Vai para posição do cursor
		
			mov		al, POSx		; Guarda a posição do cursor    If encontrou parede, 
			mov		POSxa, al
			mov		al, POSy		; Guarda a posição do cursor
			mov 	POSya, al
			mov mode,2
LER_SETA:	call 	LE_TECLA
			cmp		ah, 1
			je		ESTEND
			CMP 	AL, 27			; ESCAPE
			JE		FIM
			jmp		LER_SETA
		
ESTEND:		cmp 	al,48h			; compara se estás a pressionar uma seta de cima
			jne		BAIXO   		; se não, continua a testar se pressionou mais alguma seta
			cmp     POSy,3
			jb		outofboundcima
			dec 	POSy
			ret
outofboundcima:
			inc		POSy
			jmp 	ESTEND

BAIXO:  	cmp		al,50h
			jne		ESQUERDA
			cmp     POSy,17
			ja		outofboundbaixo
			inc		POSy
			ret
outofboundbaixo:
			dec 	POSy
			jmp 	baixo	

ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA
			cmp 	POSx,3
			jb		outofboundesq
			dec		POSx
			ret

outofboundesq:
			inc 	POSx
			jmp 	ESQUERDA

DIREITA:
			cmp		al,4Dh
			jne		BUILD
			cmp 	POSx,74
			ja		outofbounddir
			inc		POSx
			ret
outofbounddir: 
			dec 	POSx
			jmp 	Direita	
BUILD:								; Precionou o DEL
			cmp		al,53h
			jne		BLETRA
			cmp		building,177
			je		buildempty
buildparede:
			mov		building,177
			ret
buildempty:
			mov		building,' '
			ret
BLETRA:								; Precionou o PAGE UP
			cmp 	al,49H
			jne 	PRINTW
			inc		makeletter
			dec 	POSxa
			goto_xy	POSxa,POSya		; Vai para a posição anterior do cursor
			mov		ah, 02h					
			mov		dl,makeletter	; Repoe Caracter guardado 
			int		21H
			inc 	POSxa
			cmp   	makeletter,'Z'
			je    	resetletter
			ret
resetletter:
			mov 	makeletter,'@'
			jmp		BLETRA	
PRINTW:		
			cmp   	al,47h
			jne 	LER_SETA
			mov 	guardar,0		
			ret



fim:				
			call MAIN
prosseguir2 endp

;########################################################################
Verificar_Letra PROC
	mov	al,Car				; mete em al o car que vai asseguir
	cmp al, ' '				; compara com um espaço em branco
	push di
	push si
	mov di,0
	mov si,0
	jne letra_inicio		; jump se não for um espaço em branco
	jmp no_letra

letra_inicio:
	cmp al, 177				; compara se é uma parede
	je no_letra				; se é, então sai
letra_str:
	cmp [bx+di],al			; compara a letra com o car da string

	push bx					; guarda o estado do bx - apontar para a string_nome
	lea bx, Construir_nome	; bx fica a apontar para Construir_nome
	je meter_letra			; Se encontrou letra da palavra salta
							; se a letra atual não é uma letra da nossa string_nome
	pop bx
	inc di
	inc si

	cmp byte ptr [bx+di],'$'; ver se já chegámos ao fim da string
	jne letra_str			; se ainda não, continuamos a ver a palavra toda
							; se chegámos ao fim:
	goto_xy 10,21			;
	MOSTRA Construir_nome
	jmp no_letra			; sair da função

meter_letra:
	cmp di,tam_palavra
	ja	outofbounds

	goto_xy	POSxa,POSya		; se é uma letra que queremos, come-a
	mov CAR, ' '

	mov [bx+si],al			; move o car apanhado para a posição certa
	inc apanhadas
	inc di					; na mesma incrementa
	inc si					; na mesma incrementa
	pop bx					; bx volta ao valor inicial - apontar para string_nome

	add     pontuacao, 750

	jmp letra_str			; para voltar ao letra_str 
outofbounds:
	pop bx
	goto_xy 10,21			
	MOSTRA Construir_nome
no_letra:
	pop di
	pop si
	ret
Verificar_Letra ENDP
;########################################################################
apaga_ecran	proc
		mov		ax,0B800h
		mov		es,ax
		xor		bx,bx
		mov		cx,25*80
		
apaga:	mov		byte ptr es:[bx],' '
		mov		byte ptr es:[bx+1],7
		inc		bx
		inc 	bx
		loop	apaga
		ret
apaga_ecran	endp
;########################################################################
ADDPOINTS PROC
		goto_xy POSpontosx,POSpontosy
		add     pontuacao, 750
		mov		ax,pontuacao
		call 	PRINTDIG
		RET
ADDPOINTS ENDP

;########################################################################
PRINTDIG PROC          
    mov cx,0
    mov dx,0
	;chama o valor que está no registo
	;divide o valor por 10
	;push o resto para o stack
	;aumenta a contagem
	;repete o número de passos até o valor do registo é maior que 0
	;até o contador ser maior que 0
	;pop do stack
	;adiciona 48 ao elemento mais alto para em ASCII
	;imprime o caracter com uma interrupção
	;decrementa a contagem
	cmp ax,0			; compara se tem zero, mostra apenas zero
	je	exit1
parte1:
    	cmp ax,0		; se ax é zero
        je print1   

        mov bx,10       ; bx inicializado a 10
         
        div bx 			; extrai o ultimo digito
         
        push dx 		; guarda-o na stack
         
        inc cx 			; incrementa o contador
         
        xor dx,dx		; dx a zero
        jmp parte1
print1:
        cmp cx,0		; ver se o contador é zero
        je exit
         
        pop dx 			; pop topo da stack
         
        add dx,48		; adicionar 48 para representar o valor ASCII dos digitos
         
        mov ah,02h		; para dar print
        int 21h
         
        dec cx			; decrementa o contador
        jmp print1

exit1:
		mov dx,'0'
		mov ah,02h
        int 21h
exit:
		mov dx,' '
		mov ah,02h		; para dar print de um espaço no fim caso fique com menos um digito
        int 21h
		RET
PRINTDIG ENDP
;#######################################################################
PRINTDIGSTR PROC          
    mov cx,0
    mov dx,0
	;chama o valor que está no registo
	;divide o valor por 10
	;push o resto para o stack
	;aumenta a contagem
	;repete o número de passos até o valor do registo é maior que 0
	;até o contador ser maior que 0
	;pop do stack
	;adiciona 48 ao elemento mais alto para em ASCII
	;imprime o caracter com uma interrupção
	;decrementa a contagem
	cmp ax,0
	je	exit1

parte1:
    	cmp ax,0		; se ax é zero
        je print1   

		push bx
        mov bx,10       ; bx inicializado a 10
         
        div bx 			; extrai o ultimo digito
        pop bx
        
		push dx 		; guarda-o na stack
         
        inc cx 			; incrementa o contador
         
        xor dx,dx		; dx a zero
        jmp parte1
print1:
        cmp cx,0		;ver se o contador é zero
        je exit
         
        pop dx 			; pop topo da stack
         
        add dx,48		; adicionar 48 para representar o valor ASCII dos digitos

		mov	si,displacement	
		sub	si,cx		; tá invertido
		mov [bx+si],dl

        dec cx			; decrementa o contador
        jmp print1

exit1:
		mov dx,'0'
		mov ah,02h
        int 21h
exit:
		mov dx,' '
		mov ah,02h		; para dar print de um espaço no fim caso fique com menos um digito
        int 21h
		RET
PRINTDIGSTR ENDP
;#######################################################################
LER_FICH	PROC

		;abre ficheiro
        mov     ah,3dh
        mov     al,0
		mov		di,0
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo
erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f
ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0		
		je		fecha_ficheiro
		mov		dl,car_fich
		mov		buffer[di],dl
		inc		di
		jmp		ler_ciclo
erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h
fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:	
		RET
		
LER_FICH	endp
;#######################################################################
exportarmatriz proc
		mov		ah, 3ch				; Abrir o ficheiro para escrita
		mov		cx, 00H				; Define o tipo de ficheiro 	
		int		21h					; Abre efectivamente o ficheiro (AX fica com o Handle do ficheiro)
		jnc		escreve				; Se não existir erro escreve no ficheiro
									; handle é tipo, apontar para o sitio onde está a memória	
		mov		ah, 09h
		lea		dx, msgErrorCreate
		int		21h

		jmp fim
	
escreve:
		mov		bx, ax				; Coloca em BX o Handle
    	mov		ah, 40h				; indica que é para escrever
    	
		mov		dx, si				; DX aponta para a infromação a escrever
    	mov		cx, tamanhomatriz	; CX fica com o numero de bytes a escrever
		int		21h					; Chama a rotina de escrita
		jnc		close				; Se não existir erro na escrita fecha o ficheiro
	
		mov		ah, 09h
		lea		dx, msgErrorWrite
		int		21h
close:
		mov		ah,3eh				; fecha o ficheiro
		int		21h
		jnc		fim
	
		mov		ah, 09h
		lea		dx, msgErrorClose
		int		21h
fim:
		ret
exportarmatriz endp
;#######################################################################
; IMP_FICH
IMP_FICH	PROC

		;abre ficheiro
        mov     ah,3dh
        mov     al,0
        ;lea     dx,Fich			;Vai-se manualmente carregar o ficheiro que queremos imprimir cada vez que chamarmos a funcao
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0		;EOF?
		je		fecha_ficheiro
        mov     ah,02h
		mov		dl,car_fich
		int		21h
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:	
		RET
		
IMP_FICH	endp
;********************************************************************************	
Ler_TEMPO PROC	
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
	
		PUSHF
		
		MOV AH, 2CH             ; Buscar a hORAS
		INT 21H                 
		
		XOR AX,AX
		MOV AL, DH              ; segundos para al
		mov Segundos,AX
		
		XOR AX,AX
		MOV AL, CL              ; Minutos para al
		mov Minutos, AX         ; guarda MINUTOS na variavel correspondente
		
		XOR AX,AX
		MOV AL, CH              ; Horas para al
		mov Horas,AX			; guarda HORAS na variavel correspondente
 
		POPF
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
Ler_TEMPO   ENDP 
;********************************************************************************
;-------------------------------------------------------------------
; HOJE - LE DATA DO SISTEMA E COLOCA NUMA STRING NA FORMA DD/MM/AAAA
; CX - ANO, DH - MES, DL - DIA
;-------------------------------------------------------------------
HOJE PROC	

		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI
		PUSHF
		
		MOV AH, 2AH             ; Buscar a data
		INT 21H                 
		PUSH CX                 ; Ano-> PILHA
		XOR CX,CX              	; limpa CX
		MOV CL, DH              ; Mes para CL
		PUSH CX                 ; Mes-> PILHA
		MOV CL, DL				; Dia para CL
		PUSH CX                 ; Dia -> PILHA
		XOR DH,DH                    
		XOR	SI,SI
; DIA ------------------ 
; DX=DX/AX --- RESTO DX   
		XOR DX,DX               ; Limpa DX
		POP AX                  ; Tira dia da pilha
		MOV CX, 0               ; CX = 0 
		MOV BX, 10              ; Divisor
		MOV	CX,2
DD_DIV:                         
		DIV BX                  ; Divide por 10
		PUSH DX                 ; Resto para pilha
		MOV DX, 0               ; Limpa resto
		loop dd_div
		MOV	CX,2
DD_RESTO:
		POP DX                  ; Resto da divisao
		ADD DL, 30h             ; ADD 30h (2) to DL
		MOV DDMMAAAA[SI],DL
		INC	SI
		LOOP DD_RESTO            
		MOV DL, '/'             ; Separador
		MOV DDMMAAAA[SI],DL
		INC SI
; MES -------------------
; DX=DX/AX --- RESTO DX
		MOV DX, 0               ; Limpar DX
		POP AX                  ; Tira mes da pilha
		XOR CX,CX               
		MOV BX, 10				; Divisor
		MOV CX,2
MM_DIV:                         
		DIV BX                  ; Divisao or 10
		PUSH DX                 ; Resto para pilha
		MOV DX, 0               ; Limpa resto
		LOOP MM_DIV
		MOV CX,2 
MM_RESTO:
		POP DX                  ; Resto
		ADD DL, 30h             ; SOMA 30h
		MOV DDMMAAAA[SI],DL
		INC SI		
		LOOP MM_RESTO
		
		MOV DL, '/'             ; Character to display goes in DL
		MOV DDMMAAAA[SI],DL
		INC SI

;  ANO ----------------------
		MOV DX, 0               
		POP AX                  ; mes para AX
		MOV CX, 0               ; 
		MOV BX, 10              ; 
 AA_DIV:                         
		DIV BX                   
		PUSH DX                 ; Guarda resto
		ADD CX, 1               ; Soma 1 contador
		MOV DX, 0               ; Limpa resto
		CMP AX, 0               ; Compara quotient com zero
		JNE AA_DIV              ; Se nao zero
AA_RESTO:
		POP DX                  
		ADD DL, 30h             ; ADD 30h (2) to DL
		MOV DDMMAAAA[SI],DL
		INC SI
		LOOP AA_RESTO
		POPF
		POP SI
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
HOJE   ENDP 
;********************************************************************************

;########################################################################
; LE UMA TECLA 
LE_TECLA	PROC
			cmp mode,1
			je sem_tecla
			jmp sem_tecla2
sem_tecla: ;subfuncao tipo
		call Trata_Horas

		MOV	AH,0BH
		INT 21h
		cmp AL,0
		je	sem_tecla
		
		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
		jmp SAI_TECLA
sem_tecla2: ;subfuncao tipo
		MOV	AH,0BH
		INT 21h
		cmp AL,0
		je	sem_tecla2
		
		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp

;********************************************************************************

Trata_Horas PROC      				; Muda-se aqui os GOTO_XY para mudares o sitio das horas

		PUSHF
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX		

		CALL 	Ler_TEMPO			; Horas MINUTOS e segundos do Sistema
		
		MOV		AX, Segundos
		cmp		AX, Old_seg			; VErifica se os segundos mudaram desde a ultima leitura
		je		fim_horas2			; Se a hora não mudou desde a última leitura sai.
		mov		Old_seg, AX			; Se segundos são diferentes actualiza informação do tempo 
		
		mov 	ax,Horas
		MOV		bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'h'		
		MOV 	STR12[3],'$'
		GOTO_XY 24,0
		MOSTRA STR12 		
        
		mov 	ax,Minutos
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'m'		
		MOV 	STR12[3],'$'
		GOTO_XY	27,0
		MOSTRA	STR12 		
		
		mov 	ax,Segundos
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'s'		
		MOV 	STR12[3],'$'
		GOTO_XY	30,0
		MOSTRA	STR12 
		
		mov		ax,time
		dec		time
		MOV 	bl, 10   
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	String_TJ[0],'0'			
		MOV 	String_TJ[1],al
		MOV 	String_TJ[2],ah	
		GOTO_XY	57,0
		MOSTRA	String_TJ

		cmp     pontuacao,15
		jbe		pontuacaominima
		goto_xy POSpontosx,POSpontosy
		sub     pontuacao, 15
		mov		ax,pontuacao
		call 	PRINTDIG
		jmp 	ifstatement
pontuacaominima:
		mov		pontuacao,0
		goto_xy POSpontosx,POSpontosy
		mov		ax,pontuacao
		call 	PRINTDIG

ifstatement:
		;If statement
		cmp		time,0
		jnl		continue1
		call 	GAME_OVER
		
continue1:

		CALL 	HOJE				; Data de HOJE
		MOV 	al ,DDMMAAAA[0]	
		MOV 	STR12[0], al	
		MOV 	al ,DDMMAAAA[1]	
		MOV 	STR12[1], al	
		MOV 	al ,DDMMAAAA[2]	
		MOV 	STR12[2], al	
		MOV 	al ,DDMMAAAA[3]	
		MOV 	STR12[3], al	
		MOV 	al ,DDMMAAAA[4]	
		MOV 	STR12[4], al	
		MOV 	al ,DDMMAAAA[5]	
		MOV 	STR12[5], al	
		MOV 	al ,DDMMAAAA[6]	
		MOV 	STR12[6], al	
		MOV 	al ,DDMMAAAA[7]	
		MOV 	STR12[7], al	
		MOV 	al ,DDMMAAAA[8]	
		MOV 	STR12[8], al
		MOV 	al ,DDMMAAAA[9]	
		MOV 	STR12[9], al		
		MOV 	STR12[10],'$'
		GOTO_XY	67,0
		MOSTRA	STR12							
fim_horas2:		
		goto_xy	POSx,POSy			; Coloca o cursor onde estava antes de actualizar as horas
		
		POPF
		POP DX		
		POP CX
		POP BX
		POP AX
		RET		
			
Trata_Horas ENDP
;########################################################################
winner PROC
ciclo5:
	call	apaga_ecran
	goto_xy	0,0   				;apaga o ecra a partir do 0 0
    lea  	dx,player_won   	;carregar para dx o ficheiro que queremos imprimir
    call 	IMP_FICH   			;imprimir o ficheiro

	goto_xy 45,22				; print da pontuacao
	mov		ax,pontuacao
	call 	PRINTDIG

	goto_xy 70,22				; print do nivel
	mov		ax,nivel
	call 	PRINTDIG

	mov 	ah, 07h 			; Espera para que o utilizador insira um caracter
  	int 	21h					;

	cmp al,'1'
	je jogar_novamente2
	cmp al,'2'
	je tops10x
	cmp al,'3'
	je sair2
	jmp ciclo5
tops10x:
	call addtop10
jogar_novamente2:
	call MAIN
sair2:
	call END_GAME
winner ENDP
;########################################################################
GAME_OVER PROC
ciclo2:
	call	apaga_ecran
	goto_xy	0,0   				;apaga o ecra a partir do 0 0
    lea  	dx,jogo_acabou		;carregar para dx o ficheiro que queremos imprimir
    call 	IMP_FICH  			;imprimir o ficheiro

	goto_xy 45,22				; print da pontuacao
	mov		ax,pontuacao
	call 	PRINTDIG

	goto_xy 70,22				; print do nivel
	mov		ax,nivel
	call 	PRINTDIG

	mov  	ah, 07h 			; Espera para que o utilizador insira um caracter
  	int  	21h

	cmp al,'1'
	je jogar_novamente
	cmp al,'2'
	je tops10
	cmp al,'3'
	je sair
	jmp ciclo2
tops10:
	call addtop10
jogar_novamente:
	call MAIN
sair:
	call END_GAME
GAME_OVER endp
;########################################################################
addtop10 proc
	goto_xy 0,0
	call 	apaga_ecran
	call 	resetplayer			; esvazia o nomeplayerText
;---------------------------------------------------------verificar top 10------------
	mov		si,0
	mov		displacement,0 		; inicio da primeira linha
	jmp		verpreenchido
noob:
	call	apaga_ecran
	goto_xy 10,10
	MOSTRA	pntinsufuciente
	mov  	ah, 07h 			; Espera para que o utilizador insira um caracter
  	int  	21h
	call	Main
pontosmenores:
	cmp		si,270				; testar se há espaço para o novo jogador
	jae		noob
	add		si,30
	add		displacement,30

verpreenchido:
	; sabendo que o displacement está a apontar para o inicio da linha, extrai a pontuação desse jogador para extraipontuacao
	call    extrainumero

	mov		ax,extraipontuacao
	cmp		pontuacao,ax
	jbe		pontosmenores

	;max displacement is 299
;---------------------------------------------------------verificar top 10------------
	; Deixa o jogador escrever uma string e põe-na na matriz de acordo com a var displacement
	call 	nplayer

	lea 	bx,buffer
	mov		ax,pontuacao
	add		displacement,20		; pôr a pontuacao no sitio certo 
	call	PRINTDIGSTR

	lea		dx, top10fich
	lea		si, buffer
	mov     tamanhomatriz,290
	call 	exportarmatriz
	ret
addtop10 endp
;########################################################################
extrainumero proc
	push si
	xor si,si
	mov	di,1
	xor ax,ax
	xor dx,dx
	mov extraipontuacao,0

	add displacement,19			; displacement aponta para o ultimo digito da pontuação
	mov si,displacement
ciclobom:
	goto_xy 0,0
	lea bx,buffer
	mov dl, [bx+si]				; aponta para o sitio do buffer
	mov ah, 02h 				; dá print da porra que fica no al
	int 21h						; Display the character
	; o al está com o nosso caracter extraido
	sub	al,'0'					; transformar num numero
	
	mov		ah,0 				; al = number
	mul	di						; multiplica o novo numero extraido por 10
	add	extraipontuacao,ax

	sub	si,1

	cmp buffer[si],' '
	je	embora

	mov ax,10					; multiplicar di por 10
	mul	di
	mov	di,ax

	jmp	ciclobom
embora:
	sub displacement,19			; displacement volta a apontar para o inicio da linha
	pop si
	ret
extrainumero endp
;########################################################################
nplayer proc					; Introduzir o nome do utilizador
	xor si,si
	mov cx,10					; clear the space
	mov bx,displacement			;
res_player:						;
	mov buffer[bx+si],' '		;
	inc si						;
	loop res_player				;

	xor si,si
	goto_xy 10,10
	mostra introduznome
	mov POSxplayer,29
	mov POSyplayer,10

player:
	goto_xy POSxplayer ,POSyplayer 
	mov ah,07h
  	int  21h
ciclo:	
	cmp al ,0DH
	je sos
	cmp al,'A'
	jb player
	cmp al,'Z'
	ja player
	jmp letra
letra:
	mov nomeplayerText[si],al
	mov bx,displacement
	mov buffer[si+bx],al		; salva o input na matriz buffer
	inc si
	cmp si, 10
	je sos
	jmp lel
lel:
	goto_xy 29 ,10
	mostra nomeplayerTEXT
	inc POSxplayer
	jmp player
sos:
	RET
nplayer endp
;########################################################################
novorandNum proc
		call	CalcAleat
		pop		ax
		goto_xy	0,0
		sub ax,500
		mov	di,20
		div	di					; para dar até 17 linhas
		add	ax,2
		mov POSyRand,ax

		call	CalcAleat
		pop		ax
		goto_xy	0,0
		sub ax,499
		mov	di,4
		div	di					; para dar até 78 linhas
		mov POSxRand,ax
		ret
novorandNum endp
;########################################################################
resetplayer proc
	mov bx,0
	mov cx,10
res_player:
	mov				nomeplayerText[bx],' '
	inc				bx
	loop			res_player
	ret
resetplayer endp
;########################################################################
vercima proc	
	mov al, POSy 				; guarda POSy numa var de test
    mov POSyteste, al
    dec POSyteste 				; ando com a var de teste
	goto_xy	POSx,POSyteste	 	; coloco as POS no novo local
	mov 	ah, 08h				; Guarda o Caracter que está na posição do Cursor
	mov		bh,0				; numero da página
	int		10h					; write character only at cursor position
	mov		Carteste, al		; Guarda o Caracter que está na posição do Curso numa var de teste
	cmp 	Carteste, 177		;Compara o caracter de teste com as paredes: ±. Se for parede salta fora e não mexe o avatar
	je return1
	mov   al, POSyteste 		; Reset na posiçao do avatar teste
    mov   POSy,al
    jmp return1	
return1:
    ret
vercima    endp
;--------------------------
verbaixo proc
	mov al, POSy 				; guarda POSy numa var de test
    mov POSyteste, al
    inc POSyteste 				; ando com a var de teste
	goto_xy	POSx,POSyteste 		; coloco as POS no novo local
	mov 	ah, 08h				; Guarda o Caracter que está na posição do Cursor
	mov		bh,0				; numero da página
	int		10h
	mov		Carteste, al		; Guarda o Caracter que está na posição do Curso numa var de teste
	cmp 	Carteste, 177		;Compara o caracter de teste com as paredes: ±. Se for parede salta fora e não mexe o avatar
	je return2
	mov   al, POSyteste			; Reset na posiçao do avatar teste
    mov   POSy,al
    jmp return2
return2:
    ret
verbaixo endp
;--------------------------
veresquerda proc
	mov al, POSx 				; guarda POSy numa var de test
    mov POSxteste, al
    dec POSxteste 				; ando com a var de teste
	goto_xy	POSxteste,POSy 		; coloco as POS no novo local
	mov 	ah, 08h				; Guarda o Caracter que está na posição do Cursor
	mov		bh,0				; numero da página
	int		10h
	mov		Carteste, al		; Guarda o Caracter que está na posição do Curso numa var de teste
	cmp 	Carteste, 177 		;Compara o caracter de teste com as paredes: ±. Se for parede salta fora e não mexe o avatar
	je return3
	mov   al, POSxteste 		; Reset na posiçao do avatar teste
    mov   POSx,al
    jmp return3	
return3:
    ret
veresquerda endp
;--------------------------
verdireita proc
	mov al, POSx 				; guarda POSy numa var de test
    mov POSxteste, al
    inc POSxteste 				; ando com a var de teste
	goto_xy	POSxteste,POSy		; coloco as POS no novo local
	mov 	ah, 08h				; Guarda o Caracter que está na posição do Cursor
	mov		bh,0				; numero da página
	int		10h
	mov		Carteste, al		; Guarda o Caracter que está na posição do Curso numa var de teste
	cmp 	Carteste, 177		;Compara o caracter de teste com as paredes: ±. Se for parede salta fora e não mexe o avatar
	je return4
	mov   al, POSxteste 		; Reset na posiçao do avatar teste
    mov   POSx,al
    jmp return4	
return4:
    ret
verdireita endp
;########################################################################
CalcAleat proc near
	; coloca no topo da pilha um valor aleatório
	sub	sp,2
	push	bp
	mov	bp,sp
	push	ax
	push	cx
	push	dx	
	mov	ax,[bp+4]
	mov	[bp+2],ax

	mov	ah,00h
	int	1ah

	add	dx,ultimo_num_aleat
	add	cx,dx	
	mov	ax,65521
	push	dx
	mul	cx
	pop	dx
	xchg	dl,dh
	add	dx,32749
	add	dx,ax

	mov	ultimo_num_aleat,dx

	mov	[BP+4],dx

	pop	dx
	pop	cx
	pop	ax
	pop	bp
	ret
CalcAleat endp
;########################################################################
pontosmoveu proc
		cmp     pontuacao,15
		jbe		minimpontos
		sub     pontuacao,1
minimpontos:
		goto_xy POSpontosx,POSpontosy
		mov		ax,pontuacao
		call 	PRINTDIG
		RET
pontosmoveu endp
;########################################################################
END_GAME proc
		call		apaga_ecran
        goto_xy 	0,0
		mov			ah,4CH   	;parte do Interrupt para sair
		INT			21H   		;Interrupt para sair
END_GAME endp
;########################################################################

Cseg	ends
end	Main
;########################################################################
; ---------- Pilha de comentários: ----------
;MENU:
	;mov  ah, 07h ; Espera para que o utilizador clique me alguma coisa
  	;int  21h
;------------------------------------------------Tests
		;lea			dx,top10fich
		;call		LER_FICH
		;goto_xy		0,0
		;MOSTRA		Construir_nome2

		;mov			dl,0
		;add dl,48		; adicionar 48 para representar o valor ASCII dos digitos
		;lea 	bx,buffer
		;mov [bx+5],dl
		;mov 		buffer[10],dl

		;lea 		bx,buffer
		;mov			ax,pontuacao
		;mov			displacement,20	;place of the last digit in string
		;call		PRINTDIGSTR

		;lea 		bx,buffer
		;mov			ax,pontuacao
		;add			displacement,30	;place of the last digit in string
		;call		PRINTDIGSTR

		;goto_xy		0,0  			;print the matrix
		;MOSTRA		buffer

		;call exportarmatriz
		;call novorandNum
		;mov	ax,POSxRand
		;call	PRINTDIG
		;	min 500, max 800
		;	25 linhas, 80 colunas
		;	17 linhas, 78 colunas
;------------------------------------------------Tests
	; print de variáveis
	;goto_xy 10,10
	;mov		ax,tam_palavra
	;call 	PRINTDIG

	; print de variáveis
	;goto_xy 10,12
	;mov		ax,apanhadas
	;call 	PRINTDIG
;#######################
;EDITOR:
;ciclosx:    					; print da matriz labirinto para ecrã de forma manual
	;mov	al,labirinto[bx]	; mov para o ecrã o caracter atual do labirinto
	;mov	es:[bx],al			;
	;inc	bx
	;loop	ciclosx
;#######################
;VERIFICAR_LETRA:
	;mov ah,09h						; mostra manual
	;mov dx, offset Construir_nome2	; mostra manual
	;int 21h						; mostra manual
;#######################
;TOP10:
	;mov		displacement,30 	;inicio da segunda linha

	;cmp		buffer[si],' '	; verifica se está vazio

	;goto_xy		0,0		;Mostra o buffer (tem que ter um $ no fim)
	;MOSTRA		buffer
	;mov  ah, 07h ; Espera para que o utilizador insira um caracter
	;int  21h

	; da linha 1505 dentro do embora:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1	
	; Extract a character from the string
	;goto_xy 0,6
	;lea bx,Construir_nome2
	;mov dl, [bx+1]  	; Retrieve the last inputted character (right before the terminating CR)
	;mov ah, 02h 		; dá print da porra que fica no al
	;int 21h				; Display the character
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
	;goto_xy 0,6				; print do coiso extraido
	;mov		ah,0
	;mov		al,extraipontuacao
	;mov		ax,extraipontuacao
	;call 	PRINTDIG

	;goto_xy 0,8
	;mov	Construir_nome2[10],al
	;mostra Construir_nome2
	;call PRINTDIG
	
; FIQUEI NA LINHA 1370