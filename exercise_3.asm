.MODEL TINY 
IO8259_0 EQU 0250H;ż��ַ
IO8259_1 EQU 0251H;���ַ
COM_8255 EQU 0273H ;8255���ƿڵ�ַ
PA_8255  EQU 0270H  ;A�˿ڵ�ַ
PB_8255  EQU 0271H
PC_8255  EQU 0272H
COM_ADDR EQU 0263H;�����������ֵ�ַ
T0_ADDR EQU 0260H;�������˿�0
T1_ADDR EQU 0261H;�������˿�1
        .STACK 100
        .DATA
BUFFER  DB 8 DUP(?) 
SEG_TAB DB 0C0H,0F9H,0A4H,0B0H, 99H, 92H, 82H,0F8H
DB 080H, 90H, 88H, 83H,0C6H,0A1H, 86H,0c7h,08ch,0ffh;0-f,�����λ����С�����ȫ��
deng db 01111111B,00111111B,00011111B,00001111B,00000111b,00000011B,00110011B;��0����ʾ��������
Counter DB 0
my_num DB 0
        .CODE
START:  MOV AX,@DATA
        MOV DS,AX
        MOV ES,AX
        NOP
        CLD ;0->DF, ��ַ�Զ�����
        MOV DX,COM_8255
	MOV AL,80H;��ʽѡ�������
	OUT DX,AL ;PA��PB �����PC ���
	MOV Counter,0;�жϴ���
	CALL Init8259;8259A��ʼ��
    CALL WriIntver;�����ж�����
    call WriIntver_2; ���ö�ʱ���ж�����
    CALL Init8253;8253��ʼ��
    call LED_quanmie 
	STI ;���ж�
	
A:	mov dx,5; ÿλ����5��λ��״̬
        mov bx,0; BUFFE���������ֵ������������,led�������2016������������ϵ�ѭ���ƶ�
led:	LEA DI,buffer;��ȡbuffer���������׵�ַ
        MOV AL,11H   ;�����ֻ����ʾ16����0-F,10H�޷���ʾ
        MOV CX,08H    
        REP STOSB;   alѭ��8�δ���ES:DI
        mov buffer[bx],8
        mov buffer[bx+1],1
   	mov buffer[bx+2],0
  	mov buffer[bx+3],2
   	call dir;������ʾ����
   	inc bx;2018��5��λ�����������ƶ�һλ
   	dec dx
   	jnz led;
   	LEA DI,buffer
   	MOV AL,11H
  	MOV CX,08H
  	REP STOSB
   	mov buffer[7],0
   	mov buffer[0],2
   	mov buffer[6],1
   	mov buffer[5],8
        call dir
   	LEA DI,buffer
   	MOV AL,11H
  	MOV CX,08H
  	REP STOSB
  	mov buffer[1],2
        mov buffer[0],0
 	mov buffer[7],1
        mov buffer[6],8
        call dir
        LEA DI,buffer
      	MOV AL,11H
   	MOV CX,08H
   	REP STOSB
   	mov buffer[2],2
   	mov buffer[1],0
   	mov buffer[0],1
   	mov buffer[7],8
   	call dir	

	jmp a;ѭ��
	
Init8259 PROC NEAR;8259��ʼ���ӳ���
	Push  dx
	Push  ax
        MOV DX,IO8259_0
        MOV AL,13H;        icw1
        OUT DX,AL
        MOV DX,IO8259_1
        MOV AL,08H;        icw2���ж����ͺ�
        OUT DX,AL
        MOV AL,09H;        icw4
        OUT DX,AL
        MOV AL,0fcH;       ocw1,IR1��ir0 ���β�������
        OUT DX,AL
        mov al,21h ;       ocw2,ir1
        out dx,al
        mov al,20h ;       ocw2,ir0
        out dx,al
	Pop ax
	Pop dx
	RET
Init8259 ENDP

Init8253 PROC NEAR;8253��ʼ��
    Push  dx
	Push  ax
	MOV DX,COM_ADDR
	MOV AL,35H
	OUT DX,AL ;������T0������ģʽ2״̬,BCD�����
	MOV DX,T0_ADDR
	MOV AL,00H	
	OUT DX,AL
	MOV AL,10H
	OUT DX,AL ;CLK0/1000
	MOV DX,COM_ADDR
	MOV AL,77H
	OUT DX,AL ;������T12״̬���������,BCD�����
	MOV DX,T1_ADDR
	MOV AL,00H
	OUT DX,AL
	MOV AL,10H
	OUT DX,AL ;CLK1/1000
    Pop ax
	Pop dx
	RET
Init8253 ENDP

LED_quanmie PROC NEAR ;LEDȫ��
	PUSH DX;�ó���Ϊ��ʱ���жϷ����ӳ���
        PUSH AX
        push bx
        mov bl,counter
        mov dx,pc_8255;deng���������������״̬��Ϣ��Ϊ0ʱ��Ӧ�����ܷ��⣬����ͨ��8255C�����
	mov al,0ffh;������ȫ��
	out dx,al;��������������ܷ���
        pop bx
        POP AX
        POP DX   
        RET 
LED_quanmie ENDP


WriIntver PROC NEAR;�ó�����Ϊ�����ж�����
          PUSH ES;    es:di=cs:si
          push ax
          push ds
          MOV AX,0
          MOV ES,AX
       	  MOV DI,24H;�ж�������ַ
          LEA AX,INT_2
          STOSW;   AX-ES:DI
          MOV AX,CS
          STOSW 
          POP ES
          pop ax
          pop ds
          RET
WriIntver ENDP

WriIntver_2 PROC NEAR;�ó�����Ϊ���ö�ʱ���ж�����
          PUSH ES;    es:di=cs:si
	  push ax
	  push ds
          MOV AX,0
          MOV ES,AX
       	  MOV DI,20H;�ж�������ַ
          LEA AX,INT_3
          STOSW;   AX-ES:DI
          MOV AX,CS
          STOSW 
          POP ES
          pop ax
          pop ds
          RET
WriIntver_2 ENDP

LedDisplay PROC NEAR;�ó�����Ϊ�ж���ʾ
          push cx
          push si
          mov cx,8
          mov si,0
yazhan: ;��Ϊ�������й����л�ı�buffer��������ֵ�����Խ�ֵ�����ڶ�ջ��
 	and ax,0000h
 	mov al,buffer[si] 
 	push ax
 	inc si
	loop yazhan
	MOV AL,Counter
	mov cl,counter
	and cx,0000000000000111b;��Ϊ��ĿҪ�������1-7����counter��8ʱ������ظ�Ϊ0
	cmp cx,0
	jnz jixu
	mov counter,1  ;ԭ����add counter, 1 �д�
	mov cx,1
jixu:   cmp cx,07h
 	jz teshu
	MOV buffer,cl
	MOV Buffer + 1,cl
	MOV Buffer + 2,cl 
	MOV Buffer + 3,cl
	MOV Buffer + 4,cl
	MOV Buffer + 5,cl
	MOV Buffer + 6,cl
	MOV Buffer + 7,cl
	call dir2
	jmp e
teshu: 	mov buffer,10h;��counterΪ7ʱ��Ҫ����ʾ2016LOOP�����������
	MOV Buffer + 1,00h
	MOV Buffer + 2,00h; ����λ����Ҫ��ʾ
	MOV Buffer + 3,0fh
	MOV Buffer + 4,08h
	MOV Buffer + 5,01h
	MOV Buffer + 6,00h
	MOV Buffer + 7,02h
	call dir2
e:	mov cx,8
	mov si,7	
chuzhan:and ax,0000h;�ظ�buffer�ֽڻ���������
  	pop ax
  	mov buffer[si],al
  	dec si
  	loop chuzhan
  	pop si
  	pop cx
  	RET
LedDisplay ENDP

INT_2: PUSH DX;�ó���Ϊ�ⲿ�жϷ����ӳ���
       PUSH AX
       MOV AL,Counter
       ADD AL,1
       MOV Counter,AL
       test AL,0000000000000001b
	JNZ delay1s
	MOV DX,T1_ADDR
	MOV AL,00H
	OUT DX,AL
	MOV AL,20H
	OUT DX,AL ;ż���ӳ�2s	
	JMP NEXT_0
delay1s:
	MOV DX,T1_ADDR
	MOV AL,00H
	OUT DX,AL
	MOV AL,10H
	OUT DX,AL ;�����ӳ�1s
NEXT_0:
	STI;��ǰ���ж�
	MOV DX,IO8259_1
       MOV AL,0fcH;       ocw1,��IR0
       OUT DX,AL
       call leddisplay
       MOV DX,IO8259_1
       MOV AL,0fdH;       ocw1,�ر�IR0
       OUT DX,AL
       call LED_quanmie
       MOV DX,IO8259_0
       MOV AL,21H
       OUT DX,AL
       POP AX
       POP DX                                                                                                                                                                                                                                                  
       IRET
       
INT_3: PUSH DX;�ó���Ϊ��ʱ���жϷ����ӳ���
       PUSH AX
       push bx
       mov bl, my_num
       inc bl
       mov my_num, bl
       mov bx,0
       mov bl,Counter
       AND BL,07H;��7ȡģ
       mov dx,pc_8255;deng���������������״̬��Ϣ��Ϊ0ʱ��Ӧ�����ܷ��⣬����ͨ��8255C�����
       mov al, my_num
       and al,01h ;  my_numֻ����1/2��仯
       jz mie_0
       mov al,deng[bx-1] ;�����ܶ�Ӧ���⣬��˸��ͨ��ʹ�����ܲ�ͬ����ʵ��
       jmp dshuchu_0
mie_0: 	mov al,0ffh;������ȫ��

dshuchu_0: out dx,al;��������������ܷ���
       
       MOV DX,IO8259_0
       MOV AL,20H
       OUT DX,AL
       ;MOV AL,21H
       ;OUT DX,AL
       pop bx
       POP AX
       POP DX                                                                                                                                                                                                                                                  
       IRET      
      
dir    PROC NEAR;��������ʾ����
	PUSH AX
	PUSH BX
	PUSH DX
	PUSH CX
	sti
	mov cx,30;CX��ֵ���ơ�2018���������ƶ��ٶ�
keng:	LEA SI,buffer ;����ʾ��������ֵ
	MOV AH,0FeH    ;������ʾ������λ����Ϊ0��λ����ʾ����
	LEA BX,SEG_TAB
ld0:    MOV DX,PA_8255
	LODSB
	XLAT ;ȡ��ʾ����
	OUT DX,AL ;������->8255 PA ��
	INC DX ;ɨ��ģʽ->8255 PB ��
	MOV AL,AH
	OUT DX,AL
	CALL dl1;�ӳ�1ms;
	MOV DX,PB_8255
	MOV AL,0FFH
	OUT DX,AL
	TEST AH,80H
	JZ LD1
	ROL AH,01H
	JMP ld0
LD1:	loop keng
	pop cx
	pop dx
	pop bx
	pop ax
	ret	    
dir 	ENDP

DL1     PROC NEAR ;�ӳ��ӳ���
   	PUSH CX
    	MOV CX,500
    	LOOP $;�Զ�ѭ��
	POP CX
	RET
DL1 	ENDP

DIR2    PROC NEAR;�ж��е���ʾ����
	push cx
	PUSH AX
	PUSH BX
	PUSH DX
	mov cx,300;    ����LED�Ƶ���˸ʱ��
again:  LEA SI,buffer ;����ʾ��������ֵ
	MOV AH,0FEH
    LEA BX,SEG_TAB
        
xunhuan:MOV DX,PA_8255
	LODSB
	XLAT ;ȡ��ʾ����
	OUT DX,AL ;������->8255 PA ��
	INC DX ;ɨ��ģʽ->8255 PB ��
	MOV AL,AH
	OUT DX,AL
	CALL DL1 ;�ӳ�1ms
	MOV DX,PB_8255
	MOV AL,0FFH
	OUT DX,AL
	TEST AH,80H;�������ɨ�赽��Եʱ���������ö����ܵĳ���
	JZ tiaochu
	ROL AH,01H;���ƣ�����������¸������
	JMP xunhuan
tiaochu: loop again
	 
	 POP DX
  	 POP BX
	 POP AX
	 pop cx
	 RET
DIR2 ENDP

end start



