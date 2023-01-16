;Tohar Mualem 
IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
	;Key
	KeyPressed db 0 ;1-Yes,0-No



	;Border Parameter
	BorderX dw 310
	BorderY dw 190
	;Check If Lost
	LostParameter db 0 ;0=NotLost, 1=Lost
	
	;CheckOneSec 
	Clock equ es:6Ch
	;Snake
	XArray dw 540 dup (0)
	YArray dw 540 dup (0)
	StartX dw 160
	StartY dw 100
	SituationOfStartSnake db 2;1-right 2-up 3-left 4-down
	NumOfSquares dw 1
	a db 1
	EndSnakeX dw 0
	EndSnakeY dw 0	
	
	;Apple
	AppleX dw 10
	AppleY dw 10
	AmIScored db 0;1=Score,0=No Score
	FreeXArray dw 30 dup (0)
	FreeYArray dw 18 dup (0)
	FreeRowX db 0
	FreeLineY db 0
	FreeX dw 10
	FreeY dw 10
	;Print Square 
	
	SquareX dw 0
	SquareY dw 0
	SquareColor db 4
	CountSquareX db 0
	CountSquareY db 0
; --------------------------
CODESEG
	proc PrintSquare
	push [SquareY]
	PrintTheLineXTimes:
		push [SquareX]
	PrintLine:
		mov bh,0h
		mov cx,[SquareX]
		mov dx,[SquareY]
		mov al,[SquareColor]
		mov ah,0ch
		int 10h
		add [CountSquareX],1
		add [SquareX],1
		cmp [CountSquareX],10
	jne PrintLine
		mov [CountSquareX],0
		pop [SquareX]
		add [CountSquareY],1
		add [SquareY],1
		cmp [CountSquareY],10
	jne PrintTheLineXTimes
		mov [CountSquareY],0
		pop [SquareY]
		ret
	endp PrintSquare
	
	proc PrintApple
	YLoop:
		mov bh,0h
		mov cx,[FreeX]
		mov dx,[FreeY]
		mov ah,0Dh
		int 10h 
		cmp al,0
	jne NotFree
		xor ax,ax
		mov ax,2
		mul [FreeRowX]
		mov di,ax
		mov bx,offset FreeXArray
		mov ax,[FreeX]
		mov [bx+di],ax
		inc [FreeRowX]
		jmp TheRowIsFree
	NotFree:
		add [FreeY],10
		cmp [FreeY],190
	jne YLoop
		mov [FreeY],10
		add [FreeX],10
		cmp [FreeX],310
	jne YLoop
	TheRowIsFree:
		mov [FreeY],10
		add [FreeX],10
		cmp [FreeX],310
	jl YLoop
		dec [FreeRowX]
		mov ax, 40h
		mov es, ax
		mov bx,0
		mov ax, [Clock] 
		mov ah, [byte cs:bx] 
		xor al, ah 
		and al, [FreeRowX]
		xor ah,ah
		xor bx,bx
		mov bx,2
		mul bx
		mov di,ax
		mov bx,offset FreeXArray
		mov ax,[bx+di]
		
		
		
		mov [FreeX],ax
		mov [AppleX],ax
	CheckFreeY:
		mov bh,0h
		mov cx,[FreeX]
		mov dx,[FreeY]
		mov ah,0Dh
		int 10h
		cmp al,0
	jne NotFree1
		xor ax,ax
		mov ax,2
		mul [FreeLineY]
		mov di,ax
		mov bx,offset FreeYArray
		mov ax,[FreeY]
		mov [bx+di],ax
		inc [FreeLineY]
	NotFree1:
		add [FreeY],10
		cmp [FreeY],190
	jne CheckFreeY
		dec [FreeLineY]
		mov ax, 40h
		mov es, ax
		mov bx,0
		mov ax, [Clock] 
		mov ah, [byte cs:bx] 
		xor al, ah 
		and al, [FreeLineY]
		xor ah,ah
		xor bx,bx
		mov bx,2
		mul bx
		mov di,ax
		mov bx,offset FreeYArray
		mov ax,[bx+di]
		mov [AppleY],ax
	
	
	
		
		mov ax,[AppleX]
		mov [SquareX],ax
		mov ax,[AppleY]
		mov [SquareY],ax
		mov [SquareColor],5
		call PrintSquare
		mov [SquareColor],4
		mov [FreeLineY],0
		mov [FreeRowX],0
		mov [FreeX],10
		mov [FreeY],10
		ret
	endp PrintApple
	
	
	proc Iscored
		mov bh,0h
		mov cx,[StartX]
		mov dx,[StartY]
		mov ah,0Dh
		int 10h
		cmp al,5
	jne YouDidntScore
		mov [AmIScored],1
	YouDidntScore:
		ret
	endp Iscored
	
	
	
	proc PrintBorders
		mov [SquareColor],14
	UpAndDownBorder:
		mov [SquareY],0
		mov ax,[BorderX]
		mov [SquareX],ax
		call PrintSquare
		mov [SquareY],190
		call PrintSquare
		sub [BorderX],10
		cmp [BorderX],0
	jge UpAndDownBorder
	RightAndLeftBorder:
		mov [SquareX],0
		mov ax,[BorderY]
		mov [SquareY],ax
		call PrintSquare
		mov [SquareX],310
		call PrintSquare
		sub [BorderY],10
		cmp [BorderY],0
	jge RightAndLeftBorder
		mov [SquareColor],4
		ret
	endp PrintBorders
	
	proc CheckIfILostBySnake
		mov bh,0h
		mov cx,[StartX]
		mov dx,[StartY]
		mov ah,0Dh
		int 10h
		cmp al,4
	jne NotHitYourself
		mov [LostParameter],1
	NotHitYourself:
		ret
	endp CheckIfILostBySnake
	
	
	proc CheckIfILostByBorder
		cmp [StartX],310
	jne LostByBorderX1
		mov [LostParameter],1	
	LostByBorderX1:
		cmp [StartX],0
	jne LostByBorderX2
		mov [LostParameter],1
	LostByBorderX2:
		cmp [StartY],190
	jne LostByBorderY1
		mov [LostParameter],1
	LostByBorderY1:
		cmp [StartY],0
	jne LostByBorderY2
		mov [LostParameter],1
	LostByBorderY2:
		ret
	endp CheckIfILostByBorder
	
	proc AddSquare
		xor ax,ax
		mov ax,2
		mul [NumOfSquares]
		mov di,ax
		mov bx,offset XArray
		mov ax,[EndSnakeX]
		mov [word ptr bx+di],ax
		mov [SquareX],ax
		mov bx,offset YArray
		mov ax,[EndSnakeY]
		mov [word ptr bx+di],ax
		mov [SquareY],ax
		call PrintSquare
		inc [NumOfSquares]
		ret
	endp AddSquare
	
	proc MoveSnake
		xor ax,ax
		mov ax,2
		mul [NumOfSquares]
		mov di,ax
		mov [SquareColor],0
		mov bx,offset XArray
		mov ax,[word ptr bx+di-2]
		mov [EndSnakeX],ax
		mov [SquareX],ax
		mov bx,offset YArray
		mov ax,[word ptr bx+di-2]
		mov [EndSnakeY],ax
		mov [SquareY],ax
		call PrintSquare
		mov [SquareColor],4
		
		cmp [SituationOfStartSnake],1
	jne NotRightStart1
		add [StartX],10
	NotRightStart1:
		cmp [SituationOfStartSnake],2
	jne NotUpStart1
		sub [StartY],10
	NotUpStart1:
		cmp [SituationOfStartSnake],3
	jne NotLeftStart1
		sub [StartX],10
	NotLeftStart1:
		cmp [SituationOfStartSnake],4
	jne NotDownStart1
		add [StartY],10
	NotDownStart1:
	
		xor ax,ax
		mov ax,2
		mul [NumOfSquares]
		mov di,ax
		mov bx,offset XArray
	loopla1:
		mov ax,[word ptr bx+di-4]
		mov [word ptr bx+di-2],ax
		sub di,2
		cmp di,2
	jne loopla1
		xor ax,ax
		mov ax,2
		mul [NumOfSquares]
		mov di,ax
		mov bx,offset YArray
	looplb1:
		mov ax,[word ptr bx+di-4]
		mov [word ptr bx+di-2],ax
		sub di,2
		cmp di,2
	jne looplb1
		call CheckIfILostByBorder
		call CheckIfILostBySnake
		call Iscored
		mov bx,offset XArray
		mov ax,[StartX]
		mov [bx],ax
		mov bx,offset YArray
		mov ax,[StartY]
		mov [bx],ax
		mov ax,[StartX]
		mov [SquareX],ax
		mov ax,[StartY]
		mov [SquareY],ax
		call PrintSquare
		ret
	endp MoveSnake
	
	
	
	
	
	
	proc Key
		in al, 64h ; Read keyboard status port
		cmp al, 10b ; Data in buffer ?
	je NoKeyPressed ; Wait until data available
		in al, 60h ; Get keyboard data
	;Check If Up
		cmp al, 11h	
	jne Up
		cmp [SituationOfStartSnake],4
	je YouCantUp
		cmp [SituationOfStartSnake],2
	je YouCantUp
		mov [KeyPressed],1
		mov [SituationOfStartSnake],2			
	Up:
	YouCantUp:
	;Check If Left
		cmp al,1Eh
	jne Left
		cmp [SituationOfStartSnake],1
	je YouCantLeft
		cmp [SituationOfStartSnake],3
	je YouCantLeft
		mov [KeyPressed],1
		mov [SituationOfStartSnake],3	
	Left:
	YouCantLeft:
	;Check If Down
		cmp al,1Fh
	jne Down
		cmp [SituationOfStartSnake],2
	je YouCantDown
		cmp [SituationOfStartSnake],4
	je YouCantDown
		mov [KeyPressed],1
		mov [SituationOfStartSnake],4
	Down:
	YouCantDown:
	;Check If Right
		cmp al,20h
	jne Right
		cmp [SituationOfStartSnake],3
	je YouCantRight
		cmp [SituationOfStartSnake],1
	je YouCantRight
		mov [KeyPressed],1
		mov [SituationOfStartSnake],1	
	Right:
	YouCantRight:
	NoKeyPressed:
	mov ah,0Ch
	int 21h
		ret
	endp Key
	



start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
	mov ax, 13h
	int 10h
	call PrintBorders
	
	mov bx,offset XArray
	mov ax,[StartX]
	mov [bx],ax
	mov bx,offset YArray
	mov ax,[StartY]
	mov [bx],ax
	mov ax,[StartX]
	mov [SquareX],ax
	mov ax,[StartY]
	mov [SquareY],ax
	call PrintSquare
	mov ax,[StartX]
	mov [EndSnakeX],ax
	mov ax,[StartY]
	mov [EndSnakeY],ax
	cmp [SituationOfStartSnake],1
	jne NotRightStart3
		add [EndSnakeX],10
	NotRightStart3:
		cmp [SituationOfStartSnake],2
	jne NotUpStart3
		sub [EndSnakeY],10
	NotUpStart3:
		cmp [SituationOfStartSnake],3
	jne NotLeftStart3
		sub [EndSnakeX],10
	NotLeftStart3:
		cmp [SituationOfStartSnake],4
	jne NotDownStart3
		add [EndSnakeY],10
	NotDownStart3:
		call AddSquare
		call AddSquare
		call AddSquare
		call PrintApple
	loopgame:
	mov ax, 40h
		mov es, ax
		mov ax, [Clock]
	FirstTick:
		cmp ax, [Clock]
	je FirstTick
		mov cx, 1
	DelayLoop:
		mov ax, [Clock]
	Tick:
		cmp ax, [Clock]
	je Tick
	call Key
		cmp [KeyPressed],1
		jne NoKey1
			cmp [LostParameter],1
			je exit
			cmp [AmIScored],1
			jne NO1
				call AddSquare
				call PrintApple
				mov [AmIScored],0
			NO1:
		NoKey1:
		mov [KeyPressed],0
	loop DelayLoop
		call MoveSnake
		cmp [LostParameter],1
		je exit
		cmp [AmIScored],1
		jne NO2
			call AddSquare
			call PrintApple
			mov [AmIScored],0
		NO2:
		mov cx,1
		cmp cx,0
	jne loopgame
	
	
	
	
	
	
	
	



; --------------------------
	
exit:
	mov ax, 4c00h
	int 21h
END start
