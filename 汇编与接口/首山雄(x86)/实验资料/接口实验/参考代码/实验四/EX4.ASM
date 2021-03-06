dseg	segment
msg	db	"Hello!",13,10,"$"
flag	db	0
dseg	ends
;----------------
cseg	segment
	assume	cs:cseg,ds:dseg
main	proc	far
	mov	ax,dseg
	mov	ds,ax
	mov	es,ax
	lea	dx,msg
	mov	ah,9
	int	21h
;使能9052
	mov	dx,0dd80h + 4ch
	mov	al,5bh
	out	dx,al

;中断主程序
;1:取原中断，保存 int 72h
	mov	ax,3572h
	int	21h		;es:bx
	push	es
	push	bx
;2:设置新中断
	mov	ax,cx
	mov	ds,ax
	lea	dx,ints
	mov	ax,2572h
	int	21h
;3:开屏蔽
	in	al,0a1h
	and	al,11111011B
	out	0a1h,al

	mov	cx,0h
;4:中断处理
lp:	mov	al,flag
	cmp	al,1
	jnz	lp

	inc	cx
	
	lea	dx,msg
	mov	ah,9
	int	21h

	mov	flag,0

	cmp	cx,4
	jb	lp
;5:屏蔽
	in	al,0a1h
	or	al,100b
	out	0a1h,al

;6:恢复原中断
	pop	dx
	pop	ds
	mov	ax,2572h
	int	21h
;关闭9052
	mov	dx, 0dd80h + 4ch
	mov	al,17h
	out	dx,al

	mov	ah,4ch
	int	21h
main	endp
ints	proc	far
;1:保护现场
	push	ds
	push	dx
	push	ax

;2:中断处理
	mov	ax,dseg
	mov	ds,ax
	mov	es,ax
	
	mov	flag,1

;3:中断结束
	mov	al,00000010b
	out	0a0h,al

	mov	dx,0dd80h + 4ch
	in	al,dx
	or	al,0ch
	out	dx,al
;4:恢复现场
	pop	ax
	pop	dx
	pop	ds
;5:IRET
	iret
ints	endp
cseg	ends
	end	main
