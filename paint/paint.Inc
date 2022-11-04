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

;chooseFont.dlg
IDD_DLG1						equ 2000
IDC_STC2						equ 2001
IDC_EDT1						equ 2002
IDC_BTN1						equ 2003

;draw.mnu
IDR_MENU						equ 10000
IDM_ChooseColor					equ 10012
IDM_PenWidth					equ 10014
IDM_P1							equ 10015
IDM_P3							equ 10016
IDM_P5							equ 10017
IDM_P10							equ 10018
IDM_Draw						equ 10001
IDM_Dot							equ 10002
IDM_Figure						equ 10010
IDM_StraightLine				equ 10003
IDM_Rectangle					equ 10004
IDM_Ellipse						equ 10005
IDM_Text						equ 10006
IDM_AddText						equ 10013
IDM_Font						equ 10011
IDM_ZombieMonster				equ 10007
IDM_GreenLondon					equ 10008
IDM_Alba						equ 10009

;paint.dlg
IDD_DIALOG1						equ 101

;paint.Rc

;Res\paintRes.rc
MANIFEST						equ 24

;#########################################################################

.data
	
	hdc 		dd 0
	hdc_b 		dd 0
	h_bitmap	dd 0
	
	drawingMode	dd 0
	usercolor 	CHOOSECOLOR <0>
	
	startpos 	POINT	<0, 0>
	endpos 		POINT	<0, 0>
	
	penwi		dd 2
	
	;colr		dd 00FF0000h
	colrBuf		dd 16 dup(0)
	
;---------------------------------------------------------FONTS
	font1 db 'D:\ASM\ASM\Masm\Projects\paint\Zombie Monster.ttf', 0
	font2 db 'D:\ASM\ASM\Masm\Projects\paint\Green London.ttf', 0
	font3 db 'D:\ASM\ASM\Masm\Projects\paint\ALBAS___.ttf', 0
	
	f1 db 'Zombie Monster', 0
	f2 db 'Green London', 0
	f3 db 'Alba Super', 0
	
	
	userText 	db 250 dup(0)
	sizeOfUserText dd $ - userText ; визначити довжину стрічки ($ = поточна адреса змінної)
	
.data?

	hInstance	dd ?
	hPen		dd ?
	hRgn 		dd ?
	hBrush 		dd ?
	hCursor 	dd ?
	hEdit	 	dd ?
	hFont 		dd ?
	hdc0		dd ?
;#########################################################################
