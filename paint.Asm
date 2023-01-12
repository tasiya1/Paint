.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include paint.inc
include gdi32.inc
includelib gdi32.lib
include RADbg.inc

comment #
4)	Реалізувати Програму Paint. Можливості: малювання, точки, прямої, прямокутника, еліпса, тексту. 
	Вибір шрифту має здійснюватися діалоговим вікном. Реалізувати підтримку зовнішніх шрифтів.
#

.code

start:
	invoke GetModuleHandle,NULL
	mov		hInstance,eax

    invoke InitCommonControls
	invoke DialogBoxParam,hInstance,MAIN_DLG,NULL,addr DlgProc,NULL
	invoke ExitProcess,0

;########################################################################

bitCopy proc
	;перенесення пікселів з одного графічного контексту в інший
	invoke BitBlt, hdc, 0, 0, 1000, 600, hdc_b, 0, 0, SRCCOPY
	ret

bitCopy endp

Flood_Fill proc thex:DWORD,they:DWORD
LOCAL x1
LOCAL y1

mov edx, thex
mov x1, edx
mov edx, they
mov y1, edx

	.if x1>1200
		ret
	.elseif x1<0
		ret
	.elseif y1>800
		ret
	.elseif y1<0
		ret
	.endif
	
	invoke GetPixel,hdc_b, x1, y1
	.if eax == fill_surface
	invoke SetPixel,hdc_b, x1, y1, pen_color.rgbResult
	inc x1
	invoke Flood_Fill,x1, y1 
	sub x1, 2
	invoke Flood_Fill,x1, y1
	inc x1
	inc y1
	invoke Flood_Fill,x1, y1
	sub y1, 2
	invoke Flood_Fill,x1, y1
	;.else
		;invoke SetPixel,hdc_b, x1, y1, brush_color.rgbResult
	.endif
	
	ret

Flood_Fill endp

CircleCoords proc xc:DWORD, yc:DWORD

	fld curAngle
	fcos			;cos(curAngle)
	fimul radius
	fiadd xc
	fistp xpos

	fld curAngle
	fsin			;sin(curAngle)
	fimul radius
	fiadd yc
	fistp ypos
	
	fld curAngle
	fadd deltaAngle
	fstp curAngle
	
	ret

CircleCoords endp

Extra_brush proc xc:DWORD, yc:DWORD
	
	.while (curAngle < 6)
		invoke CircleCoords, xc, yc
		invoke SetPixel, hdc_b, xpos, ypos, pen_color.rgbResult
	.endw
	
	ret

Extra_brush endp

StarInnerFormula proc sx:DWORD, sy:DWORD, ex:DWORD, ey:DWORD, alfax:DWORD, alfay:DWORD
	
	fild sx
	fiadd ex
	fidiv two
	fiadd sx
	fiadd alfax
	fistp star_coord.x
	
	fild sy
	fiadd ey
	fidiv two
	fiadd sy
	fiadd alfay
	fistp star_coord.y
	
	ret

StarInnerFormula endp

StarOuterFormula proc startpo:POINT, endpo:POINT
	
	
	ret

StarOuterFormula endp

Star proc startpo:POINT, endpo:POINT
	
	
	ret

Star endp

SetButtonIcons proc hWin:HWND ;---------СКОРОТИТИ КОД

	invoke LoadIcon, hInstance, 5101
	mov hIcon, eax
	invoke SendDlgItemMessage, hWin, Dropper_BTN, BM_SETIMAGE, IMAGE_ICON, hIcon
	
	invoke LoadIcon, hInstance, 5100
	invoke SendDlgItemMessage, hWin, Pen_BTN, BM_SETIMAGE, IMAGE_ICON, eax
	
	invoke LoadIcon, hInstance, 5102
	invoke SendDlgItemMessage, hWin, Eraser_BTN, BM_SETIMAGE, IMAGE_ICON, eax
	
	;---------СКОРОТИТИ КОД
	
	invoke LoadIcon, hInstance, 5103
	invoke SendDlgItemMessage, hWin, Bucket_BTN, BM_SETIMAGE, IMAGE_ICON, eax
	
	invoke LoadIcon, hInstance, 5105
	invoke SendDlgItemMessage, hWin, Scatter_BTN, BM_SETIMAGE, IMAGE_ICON, eax
	
	invoke LoadIcon, hInstance, 5104
	invoke SendDlgItemMessage, hWin, ExtraPen_BTN, BM_SETIMAGE, IMAGE_ICON, eax
	
	;---------СКОРОТИТИ КОД
	
	invoke LoadIcon, hInstance, 5106
	invoke SendDlgItemMessage, hWin, Dot_BTN, BM_SETIMAGE, IMAGE_ICON, eax
	
	invoke LoadIcon, hInstance, 5107
	invoke SendDlgItemMessage, hWin, Line_BTN, BM_SETIMAGE, IMAGE_ICON, eax
	
	invoke LoadIcon, hInstance, 5108
	invoke SendDlgItemMessage, hWin, Rectangle_BTN, BM_SETIMAGE, IMAGE_ICON, eax
	
	invoke LoadIcon, hInstance, 5109
	invoke SendDlgItemMessage, hWin, Ellipse_BTN, BM_SETIMAGE, IMAGE_ICON, eax
	
	;---------Настя бл№ть
	
	;invoke LoadIcon, hInstance, 5111
	;invoke SendDlgItemMessage, hWin, ChooseFont_BTN, BM_SETIMAGE, IMAGE_ICON, eax

	invoke LoadIcon, hInstance, 5110
	invoke SendDlgItemMessage, hWin, Clear_BTN, BM_SETIMAGE, IMAGE_ICON, eax
	
	invoke LoadIcon, hInstance, 5113
	invoke SendDlgItemMessage, hWin, Grass_BTN, BM_SETIMAGE, IMAGE_ICON, eax
	
	invoke LoadIcon, hInstance, 5114
	invoke SendDlgItemMessage, hWin, ColorChanger_BTN, BM_SETIMAGE, IMAGE_ICON, eax

	invoke LoadIcon, hInstance, 5115
	invoke SendDlgItemMessage, hWin, Save_BTN, BM_SETIMAGE, IMAGE_ICON, eax

	invoke LoadIcon, hInstance, 5116
	invoke SendDlgItemMessage, hWin, Settings_BTN, BM_SETIMAGE, IMAGE_ICON, eax

	ret

SetButtonIcons endp

SaveBMP proc
LOCAL info: BITMAPINFO
LOCAL header: BITMAPFILEHEADER
		
	mov file_struct.lStructSize, sizeof OPENFILENAME ;попередньо заповнюю структуру інф про вибраний файл
	mov file_struct.lpstrFile, offset file_name
	mov file_struct.nMaxFile, 260
	
	invoke GetSaveFileName, addr file_struct
	invoke MessageBox,0,addr file_name,0,MB_OK
	
	mov info.bmiHeader.biSize, sizeof BITMAPINFOHEADER
	mov info.bmiHeader.biWidth, 1200
	mov info.bmiHeader.biHeight, 800
	mov info.bmiHeader.biPlanes, 1
	mov info.bmiHeader.biBitCount, 24 ;не 32, тому не буде екстра 8 для прозорості
	mov info.bmiHeader.biCompression, BI_RGB
	mov info.bmiHeader.biSizeImage, 2880000 ;height*width*(bitsperpixel>24?4:3)
	mov header.bfType, 'BM'
	mov header.bfOffBits, 54 ; 14+40
	;sizeof(BITMAPFILEHEADER) = 14
	;sizeof(BITMAPINFOHEADER) = 40
	
	invoke CreateCompatibleDC, hdc_b
	mov memdc, eax
	
	invoke CreateDIBSection, hdc_b, addr info,DIB_RGB_COLORS,addr pBits,0,0
	mov section, eax
	invoke SelectObject, memdc, section
	invoke DeleteObject, eax
	
	invoke BitBlt,memdc, 0, 0, 1000, 600, hdc_b, 0, 0, SRCCOPY
	invoke DeleteDC, memdc
	
	
	;;;помилка точно десь тут!!! в записі файлу
	;invoke OpenFile, addr file_name, pBits, OF_CREATE
	invoke CreateFile, addr file_name, GENERIC_WRITE + GENERIC_READ,FILE_SHARE_WRITE + FILE_SHARE_READ,0,CREATE_NEW,0,0
	
	.if (eax == INVALID_HANDLE_VALUE)
		ret
	.endif
	
	
	invoke WriteFile, eax, pBits, info.bmiHeader.biSizeImage,0,0
	
	ret

SaveBMP endp

InitializeTrackBar proc hWin:HWND
LOCAL i:DWORD
mov i, 1
	invoke GetDlgItem, hWin, PEN_WIDTH_SCROLL
	mov hTrack, eax
	invoke SendMessage, hTrack, TBM_SETRANGEMAX, TRUE, 40
	invoke SendMessage, hTrack, TBM_SETRANGEMIN, TRUE, 1
	.while (i < 20)
		invoke SendMessage, hTrack, TBM_SETTIC, 0, i
		inc i
	.endw
	invoke SendMessage, hTrack, TBM_SETPOS, TRUE, 2
	
	ret

InitializeTrackBar endp

UpdatePen proc
	
	.if (drawingMode == DRAW || drawingMode == DOT || drawingMode == LINE || drawingMode == BUCKET)
		invoke SendMessage, hTrack, TBM_GETPOS, 0,0
		mov penwi, eax
		invoke CreatePen,PS_SOLID, penwi, pen_color.rgbResult
		invoke SelectObject, hdc_b, eax
		invoke DeleteObject, eax
	.elseif (drawingMode == SCATTER || drawingMode == GRASS)
		invoke CreatePen,PS_SOLID, particle_size, pen_color.rgbResult
		invoke SelectObject, hdc_b, eax
		invoke DeleteObject, eax
	.elseif (drawingMode == ERASE)
		invoke SendMessage, hTrack, TBM_GETPOS, 0,0
		mov penwi, eax
		invoke CreatePen,PS_SOLID, penwi, brush_color.rgbResult
		invoke SelectObject, hdc_b, eax
		invoke DeleteObject, eax
	.elseif (drawingMode == ELLIPSE || drawingMode == RECTANG || drawingMode == EXTRAPEN)
		invoke SendMessage, hTrack, TBM_GETPOS, 0,0
		mov penwi, eax
		invoke CreatePen,PS_SOLID, penwi, pen_color.rgbResult
		invoke SelectObject, hdc_b, eax
		invoke DeleteObject, eax
		
		invoke CreateSolidBrush, brush_color.rgbResult
		invoke SelectObject, hdc_b, eax
		invoke DeleteObject, eax
	.endif
	
	ret
UpdatePen endp

ChangeColor proc
	
;	xor edx, edx
;	mov eax, color_changing_counter
;	mov ecx, 20
;	div ecx		
;		.if (edx == 0)
;			.if (increment_vector == 0)
;				mov increment_vector, 1
;			.else
;				mov increment_vector, 0
;			.endif
;		.endif
;####################################################### almost working version!!
	
;	.if (color_changing_counter > 20)
;		mov increment_vector, 0
;	.elseif (color_changing_counter < 1)
;		mov increment_vector, 1
;	.endif
;	
;	.if (increment_vector == 0)
;		inc color_changing_counter
;	
;		add pen_color.rgbResult, 1
;		add brush_color.rgbResult, 1
;	.else
;		dec color_changing_counter
;	
;		sub pen_color.rgbResult, 1
;		sub brush_color.rgbResult, 1
;	.endif
	
	;#######################################
	
	add pen_color.rgbResult, 2
	;add brush_color.rgbResult, 2
	
	ret

ChangeColor endp

Scatter proc x:DWORD, y:DWORD
LOCAL lcx, lcy:DWORD
	
	call UpdatePen
	mov lcx, 0
	mov edi, x
	mov esi, y
	
	mov ebx, particle_density
	
	.while (lcx < ebx)
		invoke nrandom,scatter_size
		sub x, eax
		invoke nrandom,scatter_size
		sub y, eax
		invoke MoveToEx, hdc_b, x, y, 0
		invoke LineTo, hdc_b, x, y
		
		mov x, edi
		;mov lcx, eax
		mov y, esi
		invoke nrandom,scatter_size
		add x, eax
		invoke nrandom,scatter_size
		sub y, eax
		invoke MoveToEx, hdc_b, x, y, 0
		invoke LineTo, hdc_b, x, y
		
		mov x, edi
		;mov lcx, eax
		mov y, esi
		invoke nrandom,scatter_size
		sub x, eax
		invoke nrandom,scatter_size
		add y, eax
		invoke MoveToEx, hdc_b, x, y, 0
		invoke LineTo, hdc_b, x, y
		
		mov x, edi
		mov y, esi
		invoke nrandom,scatter_size
		add x, eax
		invoke nrandom,scatter_size
		add y, eax
		invoke MoveToEx, hdc_b, x, y, 0
		invoke LineTo, hdc_b, x, y
		inc lcx
	.endw	
	ret

Scatter endp


Grass proc x:DWORD, y:DWORD
;LOCAL lcx, lcy:DWORD
;	call UpdatePen
;	
;	mov lcx, 0
;	mov edi, x
;	;mov lcx, eax
;	mov esi, y
;	xor ebx, ebx
;	mov ebx, particle_density
;	
;	.while (lcx < ebx)
;	
;		mov x, edi
;		mov y, esi
;		sub x, 45
;		sub y, 45
;		invoke nrandom,90
;		add x, eax
;		invoke nrandom,90
;		add y, eax
;		invoke MoveToEx, hdc_b, x, y, 0
;		invoke LineTo, hdc_b, x, y
;		mov x, edi
;		mov y, esi
;		sub x, 30
;		sub y, 30
;		invoke nrandom,60
;		add x, eax
;		invoke nrandom,60
;		add y, eax
;		;invoke MoveToEx, hdc_b, x, y, 0
;		invoke LineTo, hdc_b, x, y
;		sub x, 10
;		sub y, 10
;		invoke nrandom,20
;		add x, eax
;		invoke nrandom,20
;		add y, eax
;		;invoke MoveToEx, hdc_b, x, y, 0
;		invoke LineTo, hdc_b, x, y
;		inc lcx
;	.endw
LOCAL lcx, lcy:DWORD
	
	call UpdatePen
	mov lcx, 0
	mov edi, x
	mov esi, y
	
	mov ebx, particle_density
	
	.while (lcx < ebx)
		invoke nrandom,scatter_size
		sub x, eax
		invoke nrandom,scatter_size
		sub y, eax
		;invoke MoveToEx, hdc_b, x, y, 0
		invoke LineTo, hdc_b, x, y
		
		mov x, edi
		;mov lcx, eax
		mov y, esi
		invoke nrandom,scatter_size
		add x, eax
		invoke nrandom,scatter_size
		sub y, eax
		;invoke MoveToEx, hdc_b, x, y, 0
		invoke LineTo, hdc_b, x, y
		
		mov x, edi
		;mov lcx, eax
		mov y, esi
		invoke nrandom,scatter_size
		sub x, eax
		invoke nrandom,scatter_size
		add y, eax
		;invoke MoveToEx, hdc_b, x, y, 0
		invoke LineTo, hdc_b, x, y
		
		mov x, edi
		mov y, esi
		invoke nrandom,scatter_size
		add x, eax
		invoke nrandom,scatter_size
		add y, eax
		;invoke MoveToEx, hdc_b, x, y, 0
		invoke LineTo, hdc_b, x, y
		inc lcx
	.endw	
	ret

Grass endp

UpdateSettings proc
	
	invoke SendMessage, hDensity, TBM_GETPOS, 0,0
	mov particle_density, eax
	
	invoke SendMessage, hSize, TBM_GETPOS, 0,0
	mov particle_size, eax
	
	invoke SendMessage, hScatterSize, TBM_GETPOS, 0,0
	mov scatter_size, eax
	
	ret

UpdateSettings endp

SettingsProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL i:DWORD
		mov		eax,uMsg
	.if eax==WM_INITDIALOG
	
	mov i, 1
	invoke GetDlgItem, hWin, PARTICLE_DENSITY_TRB
	mov hDensity, eax
	invoke SendMessage, hDensity, TBM_SETRANGEMAX, TRUE, 25
	invoke SendMessage, hDensity, TBM_SETRANGEMIN, TRUE, 1
	.while (i < 25)
		invoke SendMessage, hDensity, TBM_SETTIC, 0, i
		inc i
	.endw
	invoke SendMessage, hDensity, TBM_SETPOS, TRUE, particle_density
	
	mov i, 1
	invoke GetDlgItem, hWin, PARTICLE_SIZE_TRB
	mov hSize, eax
	invoke SendMessage, hSize, TBM_SETRANGEMAX, TRUE, 20
	invoke SendMessage, hSize, TBM_SETRANGEMIN, TRUE, 1
	.while (i < 20)
		invoke SendMessage, hSize, TBM_SETTIC, 0, i
		inc i
	.endw
	invoke SendMessage, hSize, TBM_SETPOS, TRUE, particle_size
	
	mov i, 10
	invoke GetDlgItem, hWin, SCATTER_SIZE_TRB
	mov hScatterSize, eax
	invoke SendMessage, hScatterSize, TBM_SETRANGEMAX, TRUE, 50
	invoke SendMessage, hScatterSize, TBM_SETRANGEMIN, TRUE, 10
	.while (i < 50)
		invoke SendMessage, hScatterSize, TBM_SETTIC, 0, i
		inc i
	.endw
	invoke SendMessage, hScatterSize, TBM_SETPOS, TRUE, scatter_size
	
	.if (always_or_before == 0)
				mov always_or_before, 1
				invoke SetDlgItemText, hWin, GRADIENT_STATUS, addr before
			.else
				mov always_or_before, 0
				invoke SetDlgItemText, hWin, GRADIENT_STATUS, addr always
			.endif
	
	.elseif eax==WM_COMMAND	
		.if wParam == Gradient_Switch
			.if (always_or_before == 0)
				mov always_or_before, 1
				invoke SetDlgItemText, hWin, GRADIENT_STATUS, addr before
			.else
				mov always_or_before, 0
				invoke SetDlgItemText, hWin, GRADIENT_STATUS, addr always
			.endif
		.elseif wParam == Apply_BTN
			call UpdateSettings
			jmp @F
		.elseif wParam == Cancel_BTN
			jmp @F
		.endif
		
	.elseif eax==WM_CLOSE
		@@:
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	
	mov		eax,TRUE
	ret
SettingsProc endp

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
;LOCAL y,x, col:dword
	mov		eax,uMsg
	.if eax==WM_INITDIALOG
	
	invoke GetDC, hWin ;0 - робочий стіл
	mov hdc, eax
	invoke GetDC, 0
	mov hdc0, eax
	
	mov eax, hWin
	mov hW, eax
	
	invoke GetDlgItem, hWin, IDC_IMG1
	mov hLogo, eax
	
	invoke LoadIcon, hInstance, 5000
	invoke SendMessage, hWin, WM_SETICON,ICON_SMALL, eax
	invoke LoadIcon, hInstance, 5000
	invoke SendMessage, hWin, WM_SETICON,ICON_BIG, eax
	
	invoke LoadBitmap, hInstance, 5001
	invoke SendMessage, hLogo, STM_SETIMAGE, IMAGE_BITMAP, eax
	
	invoke InitializeTrackBar, hWin
	
	;сумісний графічний контекст (бітмап для компіювання)
	invoke CreateCompatibleDC, hdc0
	mov hdc_b, eax
	invoke CreateCompatibleBitmap, hdc0, 1000, 600
	mov h_bitmap, eax
	invoke SelectObject, hdc_b, h_bitmap
	invoke Rectangle, hdc_b, -1, -1, 1201, 801
	invoke GetPixel, hdc_b, 5, 5
	mov brush_color.rgbResult, eax
	invoke UpdatePen
	
	invoke SetTimer, hWin, 17, 1, addr bitCopy
	
	invoke LoadCursor, hInstance, 4002
	mov hCursor, eax

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;ініціалізація структури для вибору кольору
	mov pen_color.lStructSize, sizeof CHOOSECOLOR
	mov pen_color.lpCustColors, offset colrBuf ;буфер на кастомні кольори
	mov pen_color.Flags, CC_FULLOPEN + CC_RGBINIT	;щоб повний вигляд палітри був одразу
	
	mov brush_color.lStructSize, sizeof CHOOSECOLOR
	mov brush_color.lpCustColors, offset colrBuf ;буфер на кастомні кольори
	mov brush_color.Flags, CC_FULLOPEN + CC_RGBINIT	;щоб повний вигляд палітри був одразу

	invoke SetButtonIcons, hWin	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	mov choose_font.lStructSize, sizeof CHOOSEFONT
	;mov choose_font.hDC, hdc_b
	mov choose_font.iPointSize, 10
	mov choose_font.Flags, CF_EFFECTS
	mov choose_font.nFontType, REGULAR_FONTTYPE	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;set icon
	invoke LoadIcon, hInstance, 5000
	;invoke SendMessage,hWin,STM_SETIMAGE,IMAGE_ICON,eax
	invoke SendDlgItemMessage, hWin, 101, BM_SETIMAGE, IMAGE_ICON, eax
	
	call UpdatePen
	
	.elseif eax == WM_SETCURSOR
		invoke SetCursor,hCursor
		
	.elseif eax==WM_COMMAND
		
		.if wParam == Clear_BTN ;очищення екрана
			invoke MessageBox, hWin, addr warning_text_clear, addr warning, MB_YESNO
			.if eax == IDYES
				invoke Rectangle, hdc_b, -30, -30, 1230, 830
			.endif
			
		.elseif wParam == Save_BTN
			invoke SaveBMP
			
		.elseif wParam == Settings_BTN
			invoke DialogBoxParam,hInstance,SETTINGS_DLG,hWin,addr SettingsProc,NULL
			
		.elseif wParam == ColorChanger_BTN
			.if (selection == 0)
				mov selection, 1
				invoke SetDlgItemText, hWin, ColorChangerStatus, addr selected
			.else
				mov selection, 0
				invoke SetDlgItemText, hWin, ColorChangerStatus, addr deselected
			.endif
			
			
	   	.elseif wParam == Color1_BTN
	   		invoke ChooseColor, addr pen_color
	   		.if (eax != 0)
	   			mov eax, pen_color.rgbResult
	   			mov first_pen_color, eax
	   		.endif
	   		call UpdatePen
		.elseif wParam == Color2_BTN
	   		invoke ChooseColor, addr brush_color
	   		.if (eax != 0)
	   			mov eax, brush_color.rgbResult
	   			mov first_brush_color, eax
	   		.endif
	   		call UpdatePen
		
		.elseif wParam == Dropper_BTN
			mov drawingMode, DROPPER
			invoke SetDlgItemText, hWin, SELECTED_TOOL, addr dropper_text
		;встановлення модів малювання, від яких залежать дії при натисненні мишки	
		.elseif wParam == Bucket_BTN
			mov drawingMode, BUCKET
			invoke SetDlgItemText, hWin, SELECTED_TOOL, addr bucket_text
	   	.elseif wParam == Pen_BTN
			mov drawingMode, DRAW
			invoke SetDlgItemText, hWin, SELECTED_TOOL, addr pen_text		
		.elseif wParam == Eraser_BTN
			call UpdatePen
			mov drawingMode, ERASE
			invoke SetDlgItemText, hWin, SELECTED_TOOL, addr eraser_text
		.elseif wParam == Scatter_BTN
			mov drawingMode, SCATTER
			invoke SetDlgItemText, hWin, SELECTED_TOOL, addr scatter_text
		.elseif wParam == Grass_BTN
			mov drawingMode, GRASS
			invoke SetDlgItemText, hWin, SELECTED_TOOL, addr grass_text
      	.elseif wParam == ExtraPen_BTN
      		mov drawingMode, EXTRAPEN
      		invoke SetDlgItemText, hWin, SELECTED_TOOL, addr extrapen_text
      	.elseif wParam == Dot_BTN ; "Dot"
      		mov drawingMode, DOT
      		invoke SetDlgItemText, hWin, SELECTED_TOOL, addr dot_text
      	.elseif wParam == Line_BTN ; "Straight Line"
			mov drawingMode, LINE
			invoke SetDlgItemText, hWin, SELECTED_TOOL, addr line_text
      	.elseif wParam == Rectangle_BTN ; "Rectangle"
			mov drawingMode, RECTANG
			invoke SetDlgItemText, hWin, SELECTED_TOOL, addr rectangle_text
      	.elseif wParam == Ellipse_BTN ; "Ellipse"
			mov drawingMode, ELLIPSE
			invoke SetDlgItemText, hWin, SELECTED_TOOL, addr ellipse_text
      	.endif
;	
	.elseif eax == WM_LBUTTONDBLCLK
		invoke GetCursorPos, addr startpos
		invoke ScreenToClient, hWin, addr startpos
		invoke DialogBoxParam,hInstance,TEXT_DLG,NULL,addr FontWindowProc,NULL
	;.elseif eax == WM_SETICON
		;invoke 
	.elseif eax == WM_LBUTTONDOWN
		;mov draws, 1; змінна, яка дає дозвіл на малювання, після того як затиснута клавіша і до її відпускання
		call UpdatePen
		
		invoke GetCursorPos, addr startpos ;коли малюємо фігуру то замап'ятовуємо координати її початку
		invoke ScreenToClient, hWin, addr startpos
		invoke MoveToEx, hdc_b, startpos.x, startpos.y, NULL
		;.elseif (drawingMode == ELLIPSE) || (drawingMode == RECTANG) || (drawingMode == LINE) || (drawingMode == DOT)	
		
		.if drawingMode == EXTRAPEN
			;invoke extra_brush, startpos.x, startpos.y

		.elseif drawingMode == DROPPER
			invoke GetCursorPos, addr startpos
			invoke GetPixel, hdc0, startpos.x, startpos.y
			mov pen_color.rgbResult, eax
			call UpdatePen
			
		.endif

	.elseif eax == WM_LBUTTONUP
		invoke GetCursorPos, addr endpos
		invoke ScreenToClient, hWin, addr endpos
		
		.if drawingMode == BUCKET
			invoke GetPixel, hdc_b, endpos.x, endpos.y ;визначаю колір стартової точки
			mov fill_surface, eax
			invoke Flood_Fill, endpos.x, endpos.y ;далі, буде відбуватися філл до межі поверхні заповнення(за кольором поверхні, визначеному вище)
			
		.elseif drawingMode == DOT
			invoke MoveToEx, hdc_b, endpos.x, endpos.y, NULL
			invoke LineTo, hdc_b, endpos.x, endpos.y
				
		.elseif drawingMode == LINE
			invoke LineTo, hdc_b, endpos.x, endpos.y
			
		.elseif drawingMode == RECTANG
			invoke Rectangle, hdc_b, startpos.x, startpos.y, endpos.x, endpos.y
		
		.elseif drawingMode == ELLIPSE
			invoke Ellipse, hdc_b, startpos.x, startpos.y, endpos.x, endpos.y
				
		.endif
	
	.elseif eax == WM_MOUSEMOVE
		.if (selection == 1)
			call ChangeColor
			call UpdatePen
		.endif
		
		.if wParam == MK_LBUTTON ;якщо затиснута ліва кнопка миші
			;y - верхня частина пааметру, x - нижня
			mov ecx,lParam ;у зберігатиметься в есх
			mov eax,lParam
			shr ecx,16 ;зсуваємо щоб отримати чистий у
			shl eax, 16 ;те ж саме для х
			shr eax, 16
			
			.if drawingMode == DRAW ;якщо зараз увімкнений режим звичайного малювання
				mov startpos.x, eax
				mov startpos.y, ecx
				invoke LineTo, hdc_b, startpos.x, startpos.y	
			.elseif drawingMode == ERASE
				mov startpos.x, eax
				mov startpos.y, ecx
				invoke LineTo, hdc_b, startpos.x, startpos.y	
			.elseif drawingMode == SCATTER
				invoke Scatter, eax, ecx
			.elseif drawingMode == GRASS
				invoke Grass, eax, ecx
			.elseif drawingMode == EXTRAPEN
				mov startpos.x, eax
				mov startpos.y, ecx
				
				mov ebx, penwi
				mov eax, startpos.x
				mov startpoint.x, eax
				sub startpoint.x, ebx
				
				mov eax, startpos.y
				mov startpoint.y, eax
				sub startpoint.y, ebx
				
				mov eax, startpos.x
				mov endpoint.x, eax
				add endpoint.x, ebx
				
				mov eax, startpos.y
				mov endpoint.y, eax
				add endpoint.y, ebx
				invoke Ellipse,hdc_b,startpoint.x, startpoint.y, endpoint.x, endpoint.y
			.endif
			
		.endif
	
	.elseif eax==WM_CLOSE
		invoke MessageBox, hWin, addr warning_text_exit, addr warning, MB_YESNO
		.if eax == IDYES
			invoke KillTimer, hWin, 7000
			invoke DeleteDC, hdc_b
			invoke ReleaseDC, hWin, hdc
			invoke ReleaseDC, hWin, hdc0
			invoke EndDialog,hWin,0
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp


FontWindowProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
		mov		eax,uMsg
	.if eax==WM_INITDIALOG
	
	invoke GetDlgItem, hWin, IDC_EDT1
	mov hEdit, eax
	
	.elseif eax==WM_COMMAND	
		.if wParam == IDC_BTN1
			invoke GetWindowText,hEdit,addr userText,MAX_PATH
			invoke SetBkMode, hdc_b, TRANSPARENT
			invoke TextOut, hdc_b, startpos.x, startpos.y, addr userText, sizeOfUserText ;виведення тексту із буфе
			call clearStr ;занулення стрічки
			invoke EndDialog,hWin,0
		.endif
		
	.elseif eax==WM_CLOSE
		invoke SetWindowText, hEdit, NULL
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	
	mov		eax,TRUE
	ret

FontWindowProc endp

clearStr proc	
	mov ebx, 0
	.while (ebx < 250)
		mov userText[ebx], 0
		inc ebx
	.endw
	ret
clearStr endp

end start
