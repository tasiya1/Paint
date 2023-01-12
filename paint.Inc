include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include shell32.inc
include masm32.inc
include comdlg32.inc

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib shell32.lib
includelib masm32.lib
includelib comdlg32.lib

;PROTO

	DlgProc			PROTO	:HWND,:UINT,:WPARAM,:LPARAM
	FontWindowProc	PROTO 	:HWND,:UINT,:WPARAM,:LPARAM
	SettingsProc	PROTO 	:HWND,:UINT,:WPARAM,:LPARAM
	
.const

;TOOLS
	PEN 		equ 51
	ERASER 		equ 52
	BRUSH 		equ 53

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
	ERASE		equ 10
	TEXT		equ 11
	SELECTION 	equ 12
	GRASS 		equ 13
	
	STOPDRAWING	equ 17451
	
;chooseFont.dlg
TEXT_DLG						equ 2000
IDC_STC2						equ 2001
IDC_EDT1						equ 2002
IDC_BTN1						equ 2003


;settings.dlg
SETTINGS_DLG					equ 1000
IDC_GRP4						equ 1003
IDC_GRP5						equ 1005
IDC_STC6						equ 1004
IDC_STC7						equ 1006
IDC_STC8						equ 1007
PARTICLE_DENSITY_TRB			equ 1008
PARTICLE_SIZE_TRB				equ 1009
Apply_BTN						equ 1010
Cancel_BTN						equ 1011
SCATTER_SIZE_TRB				equ 1012
IDC_STC9						equ 1013
Gradient_Switch					equ 1014
GRADIENT_STATUS					equ 1001



;paint.dlg
MAIN_DLG						equ 101
IDC_GRP1						equ 1001
IDC_GRP2						equ 1002
IDC_GRP3						equ 1003
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
IDC_IMG1						equ 1018
Clear_BTN						equ 1019
IDC_STC1						equ 1020
ColorChanger_BTN				equ 1021
IDC_STC3						equ 1022
ColorChangerStatus				equ 1023
Save_BTN						equ 1024
IDC_STC4						equ 1025
PEN_WIDTH_SCROLL				equ 1026
SELECTED_TOOL					equ 1027
Settings_BTN					equ 1028
IDC_STC5						equ 1004
Grass_BTN 						equ 1017

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
	
	logo_path db 'D:\ASM\ASM\Masm\Projects\paint\design\11.bmp',0
	
	drawingMode	dd 1
	pen_color 	CHOOSECOLOR <0>
	brush_color	CHOOSECOLOR <0>
	
	fill_surface COLORREF 0
	first_pen_color COLORREF 0
	first_brush_color COLORREF 0
	
	increment_vector 		dd 0
	color_changing_counter 	dd 0
	
	particle_density 		dd 7
	particle_size 			dd 2
	scatter_size 			dd 45
	
	always_or_before 		dd 0
	always 	db 'Always, when pen is down.', 0
	before 	db 'Before each time the pen is down.', 0
	
	choose_font CHOOSEFONT <0>
	
	startpos 	POINT	<0, 0>
	endpos 		POINT	<0, 0>
	
	startpoint 	POINT <0,0>
	endpoint 	POINT <0,0>
	
	alfa		dd 20
	two			dd 2
	
	star_coord	POINT <0,0>
	
	selection 		dd 0
	penwi			dd 15
	
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
	warning 		db 'Warning', 0
	warning_text_clear	db 'Are you sure you want to clear the canvas?', 0
	warning_text_exit	db 'Are you sure you want to exit?', 0
	
	dropper_text 	db 'Dropper', 0
	bucket_text 	db 'Bucket', 0
	pen_text		db 'Pen	', 0		
	eraser_text		db 'Eraser', 0
	scatter_text 	db 'Scatter', 0
	extrapen_text 	db 'Extra pen', 0
	dot_text 		db 'Dot', 0
	line_text 		db 'Line', 0
	rectangle_text 	db 'Rectangle', 0
	ellipse_text 	db 'Ellipse', 0
	grass_text 		db 'Grass', 0
	
	
;---------------------------------------------------------FONTS
	font1 db 'D:\ASM\ASM\Masm\Projects\paint\fonts\Zombie Monster.ttf', 0
	font2 db 'D:\ASM\ASM\Masm\Projects\paint\fonts\Green London.ttf', 0
	font3 db 'D:\ASM\ASM\Masm\Projects\paint\fonts\ALBAS___.ttf', 0
	
	f1 db 'Zombie Monster', 0
	f2 db 'Green London', 0
	f3 db 'Alba Super', 0
	
	selected db 'ON', 0
	deselected db 'OFF', 0
	
	userText 	db 250 dup(0)
	sizeOfUserText dd $ - userText ; визначити довжину стрічки ($ = поточна адреса змінної)
	newfile db '1.bmp', 0
	
	file_struct OPENFILENAME <0>
	;bmp_format db '*.BMP', 0
	file_name db 250 dup(0)
	
	;info 	BITMAPINFO			<0, 0>
	;header 	BITMAPFILEHEADER	<0>
	
	pixels 	db 0
	pBits	dd 0
	
	file_size dd 0
	
	trackbar_class db 'TRACKBAR_CLASS', 0
.data?
	hW			dd ?
	hInstance	dd ?
	hPen		dd ?
	hEraser 	dd ?
	hRgn 		dd ?
	hBrush 		dd ?
	hCursor 	dd ?
	hEdit	 	dd ?
	hFont 		dd ?
	hdc0		dd ?
	pMem		dd ?
	hLogo		dd ?
	
	hTrack		dd ?
	hDensity	dd ?
	hSize		dd ?
	hScatterSize		dd ?
	
	hButton		dd ?
	hIcon 		dd ?
	hSelectionStatus	dd ?
	
	memdc 		dd ?
	section 	dd ?
;#########################################################################
