include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include shell32.inc

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib shell32.lib

	DlgProc			PROTO	:HWND,:UINT,:WPARAM,:LPARAM
	FontWindowProc	PROTO 	:HWND,:UINT,:WPARAM,:LPARAM
.const

;DRAWING MODES
	DRAW		equ 1
	DOT			equ 2
	LINE		equ 3
	RECTANG		equ 4
	ELLIPSE		equ 5
	BUCKET		equ 6
	DROPPER 	equ 7
	EXTRAPEN	equ 8
	SCATTER		equ 9



;chooseFont.dlg
IDD_DLG1						equ 2000
IDC_STC2						equ 2001
IDC_EDT1						equ 2002
IDC_BTN1						equ 2003

;draw.mnu
IDR_MENU						equ 10000
IDM_Color						equ 10023
IDM_Color1						equ 10012
IDM_Color2						equ 10025
IDM_Dropper						equ 10022
IDM_PenWidth					equ 10014
IDM_P1							equ 10015
IDM_P3							equ 10016
IDM_P5							equ 10017
IDM_P10							equ 10018
IDM_Tools						equ 10024
IDM_Pen							equ 10001
IDM_Eraser						equ 10028
IDM_Bucket						equ 10021
IDM_Scatter						equ 10027
IDM_ExtraPen					equ 10026
IDM_Shapes						equ 10010
IDM_Dot							equ 10002
IDM_StraightLine				equ 10003
IDM_Rectangle					equ 10004
IDM_Ellipse						equ 10005
IDM_Text						equ 10006
IDM_AddText						equ 10013
IDM_Font						equ 10011
IDM_ZombieMonster				equ 10007
IDM_GreenLondon					equ 10008
IDM_Alba						equ 10009
IDM_Canvas						equ 10019
IDM_Clear						equ 10020

;paint.dlg
IDD_DIALOG1						equ 101
IDC_GRP1						equ 1001
IDC_GRP2						equ 1002
IDC_GRP3						equ 1003
IDC_GRP4						equ 1004
Color1_BTN						equ 1005
Color2_BTN						equ 1006
Dropper_BTN						equ 1007
Pen_BTN							equ 1008
Eraser_BTN						equ 1009
Bucket_BTN						equ 1010
Scatter_BTN						equ 1011
ExtraPen_BTN					equ 1012
Dot_BTN							equ 1013
Line_BTN						equ 1014
Rectangle_BTN					equ 1015
Ellipse_BTN						equ 1016
ChooseFont_BTN					equ 1017
;paint.Rc

;Res\paintRes.rc
MANIFEST						equ 24

;#########################################################################

.data
	
vp macro x, y
LOCAL r
	.data
	r dd x
	.code
	inc r
	exitm<r>
	
endm
	
	hdc 		dd 0
	hdc_b 		dd 0
	h_bitmap	dd 0
	
	drawingMode	dd 1
	pen_color 	CHOOSECOLOR <0>
	brush_color	CHOOSECOLOR <0>
	
	fill_surface CHOOSECOLOR <0>
	
	startpos 	POINT	<0, 0>
	endpos 		POINT	<0, 0>
	
	startpoint 	POINT <0,0>
	endpoint 	POINT <0,0>
	
	penwi		dd 2
	
	;colr		dd 00FF0000h
	colrBuf		dd 16 dup(0)
	
	xpos			dd 320
	ypos			dd 200
	res 			dd 0
   
	curAngle		dd 0.00
	deltaAngle		dd 0.017
	radius 			dd 120
	xcentre 			dd 200
	ycentre 			dd 200

;---------------------------------------------------------BUTTON THINGS
	buttonClass db 'Button', 0
	buttonName db 'Button', 0
	
	
	
	
;---------------------------------------------------------FONTS
	font1 db 'D:\ASM\ASM\Masm\Projects\paint\fonts\Zombie Monster.ttf', 0
	font2 db 'D:\ASM\ASM\Masm\Projects\paint\fonts\Green London.ttf', 0
	font3 db 'D:\ASM\ASM\Masm\Projects\paint\fonts\ALBAS___.ttf', 0
	
	f1 db 'Zombie Monster', 0
	f2 db 'Green London', 0
	f3 db 'Alba Super', 0
	
	
	userText 	db 250 dup(0)
	sizeOfUserText dd $ - userText ; визначити довжину стрічки ($ = поточна адреса змінної)
	newfile db '1.bmp', 0
	
	file_size dd 0
.data?
	hW			dd ?
	hInstance	dd ?
	hPen		dd ?
	hRgn 		dd ?
	hBrush 		dd ?
	hCursor 	dd ?
	hEdit	 	dd ?
	hFont 		dd ?
	hdc0		dd ?
	pMem		dd ?
	hBut1		dd ?
;#########################################################################
