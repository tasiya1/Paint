.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include paint.inc
include gdi32.inc
includelib gdi32.lib
include RADbg.inc

include comdlg32.inc
includelib comdlg32.lib

comment #
4)	Реалізувати Програму Paint. Можливості: малювання, точки, прямої, прямокутника, еліпса, тексту. 
	Вибір шрифту має здійснюватися діалоговим вікном. Реалізувати підтримку зовнішніх шрифтів.
#

.code

start:
	invoke GetModuleHandle,NULL
	mov		hInstance,eax

    invoke InitCommonControls
	invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
	invoke ExitProcess,0

;########################################################################

bitCopy proc
	;перенесення пікселів з одного графічного контексту в інший
	invoke BitBlt, hdc, 0, 0, 1200, 800, hdc_b, 0, 0, SRCCOPY
	ret

bitCopy endp

flood_Fill proc thex:DWORD,they:DWORD
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
	.if eax == fill_surface.rgbResult
	invoke SetPixel,hdc_b, x1, y1, pen_color.rgbResult
	inc x1
	invoke flood_Fill,x1, y1 
	sub x1, 2
	invoke flood_Fill,x1, y1
	inc x1
	inc y1
	invoke flood_Fill,x1, y1
	sub y1, 2
	invoke flood_Fill,x1, y1
	;.else
		;invoke SetPixel,hdc_b, x1, y1, brush_color.rgbResult
	.endif
	
	ret

flood_Fill endp

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

extra_brush proc xc:DWORD, yc:DWORD
	
	.while (curAngle < 6)
		invoke CircleCoords, xc, yc
		invoke SetPixel, hdc_b, xpos, ypos, pen_color.rgbResult
	.endw
	
	ret

extra_brush endp

randomnyk proc divider:DWORD
LOCAL time_seed:SYSTEMTIME
	
	invoke GetSystemTime, addr time_seed
	lea eax, time_seed.wMilliseconds
	mov ecx, divider
	div ecx
	mov eax, edx
	ret

randomnyk endp


scatter proc

	ret

scatter endp

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

	invoke LoadIcon,hInstance, IDI_APPLICATION
	mov hBut1, eax

	;сумісний графічний контекст (бітмап для компіювання)
	invoke CreateCompatibleDC, hdc0
	mov hdc_b, eax
	invoke CreateCompatibleBitmap, hdc0, 1200, 800
	mov h_bitmap, eax
	invoke SelectObject, hdc_b, h_bitmap
	invoke Rectangle, hdc_b, -1, -1, 1201, 801
	
	invoke SetTimer, hWin, 17, 1, addr bitCopy
	
	invoke LoadCursor, hInstance, 4002
	mov hCursor, eax
	invoke SendDlgItemMessage, hInstance, IDD_DIALOG1, WM_SETCURSOR, hWin, NULL
	
	;ініціалізація структури для вибору кольору
	mov pen_color.lStructSize, sizeof CHOOSECOLOR
	mov pen_color.lpCustColors, offset colrBuf ;буфер на кастомні кольори
	mov pen_color.Flags, CC_FULLOPEN + CC_RGBINIT	;щоб повний вигляд палітри був одразу
	
	mov brush_color.lStructSize, sizeof CHOOSECOLOR
	mov brush_color.lpCustColors, offset colrBuf ;буфер на кастомні кольори
	mov brush_color.Flags, CC_FULLOPEN + CC_RGBINIT	;щоб повний вигляд палітри був одразу
	
	;set icon
	invoke LoadIcon, hInstance, 5000
	invoke SendMessage,hWin,STM_SETIMAGE,IMAGE_ICON,eax
	
	invoke CreatePen,PS_SOLID, penwi, pen_color.rgbResult
	invoke SelectObject, hdc_b, eax
	
	.elseif eax == WM_SETCURSOR
		invoke SetCursor,hCursor
		ret
	
	.elseif eax==WM_COMMAND
		
		.if wParam == IDM_Clear ;очищення екрана
			invoke Rectangle, hdc_b, -30, -30, 1230, 830
		
	   	.elseif wParam == Color1_BTN
	   		invoke ChooseColor, addr pen_color
	   		invoke CreatePen,PS_SOLID, penwi, pen_color.rgbResult
			invoke SelectObject, hdc_b, eax
		.elseif wParam == Color2_BTN
	   		invoke ChooseColor, addr brush_color
	   		invoke CreateSolidBrush,brush_color.rgbResult
			invoke SelectObject, hdc_b, eax
		
		.elseif wParam == Dropper_BTN
			mov drawingMode, DROPPER
		;встановлення модів малювання, від яких залежать дії при натисненні мишки	
		.elseif wParam == Bucket_BTN
			mov drawingMode, BUCKET
	   	.elseif wParam == Pen_BTN
			mov drawingMode, DRAW
		.elseif wParam == Eraser_BTN
			invoke CreatePen,PS_SOLID, penwi, brush_color.rgbResult
			invoke SelectObject, hdc_b, eax
			mov drawingMode, DRAW
		.elseif wParam == Scatter_BTN
			mov drawingMode, SCATTER
      	.elseif wParam == ExtraPen_BTN
      		mov drawingMode, EXTRAPEN
      	.elseif wParam == Dot_BTN ; "Dot"
      		mov drawingMode, DOT
      	.elseif wParam == Line_BTN ; "Straight Line"
			mov drawingMode, LINE
      	.elseif wParam == Rectangle_BTN ; "Rectangle"
			mov drawingMode, RECTANG
      	.elseif wParam == Ellipse_BTN ; "Ellipse"
			mov drawingMode, ELLIPSE
			
		.elseif wParam == IDM_P1
			mov penwi, 1
			invoke CreatePen,PS_SOLID, penwi, pen_color.rgbResult
			invoke SelectObject, hdc_b, eax
			
		.elseif wParam == IDM_P3
			mov penwi, 3
			invoke CreatePen,PS_SOLID, penwi, pen_color.rgbResult
			invoke SelectObject, hdc_b, eax
		.elseif wParam == IDM_P5
			mov penwi, 5
			invoke CreatePen,PS_SOLID, penwi, pen_color.rgbResult
			invoke SelectObject, hdc_b, eax
		.elseif wParam == IDM_P10
			mov penwi, 10
			invoke CreatePen,PS_SOLID, penwi, pen_color.rgbResult
			invoke SelectObject, hdc_b, eax
      	.elseif wParam == IDM_AddText
      		invoke DialogBoxParam,hInstance,IDD_DLG1,NULL,addr FontWindowProc,NULL
			
      	.elseif wParam == IDM_Alba ; "Alba"

      		invoke AddFontResource,addr font3
			invoke GetDeviceCaps,hdc_b,LOGPIXELSY ;кількість пікселів на логічний дюйм
			invoke MulDiv,40,eax,72 ;для знаходження логічної висоти шрифту
			neg eax ; -eax
			invoke CreateFont, eax, 40, 0, 0, 500, 0, 0 , 0, DEFAULT_CHARSET,\ 
 	 		OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,DEFAULT_PITCH,addr f3
 	 		invoke SelectObject,hdc_b,eax ;аpply новий шрифт
 	 		invoke DeleteObject, eax
			invoke SetTextColor,hdc_b,pen_color.rgbResult
			invoke SetBkMode,hdc_b,TRANSPARENT ;фон тексту
			
      	.elseif wParam == IDM_ZombieMonster ; 
      	
      		invoke AddFontResource,addr font1
			invoke GetDeviceCaps,hdc_b,LOGPIXELSY ;кількість пікселів на логічний дюйм
			invoke MulDiv,50,eax,72 ;для знаходження логічної висоти шрифту
			neg eax ; -eax
			invoke CreateFont, eax, 50, 0, 0, 300, 0, 0 , 0, DEFAULT_CHARSET,\ 
 	 		OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,DEFAULT_PITCH,addr f1
 	 		invoke SelectObject,hdc_b,eax ;аpply новий шрифт
 	 		invoke DeleteObject, eax
			invoke SetTextColor,hdc_b,pen_color.rgbResult
			invoke SetBkMode,hdc_b,TRANSPARENT ;фон тексту
      	
      	.elseif wParam == IDM_GreenLondon ; 
      	
      		invoke AddFontResource,addr font2
			invoke GetDeviceCaps,hdc_b,LOGPIXELSY ;кількість пікселів на логічний дюйм
			invoke MulDiv,30,eax,72 ;для знаходження логічної висоти шрифту
			neg eax ; -eax
			invoke CreateFont, eax, 30, 0, 0, 300, 0, 0 , 0, DEFAULT_CHARSET,\ 
 	 		OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,DEFAULT_PITCH,addr f2
 	 		invoke SelectObject,hdc_b,eax ;аpply новий шрифт
 	 		invoke DeleteObject, eax
			invoke SetTextColor,hdc_b,pen_color.rgbResult
			invoke SetBkMode,hdc_b,TRANSPARENT ;фон тексту
      	
      	.endif
;	
	.elseif eax == WM_LBUTTONDBLCLK
		invoke GetCursorPos, addr startpos
		invoke ScreenToClient, hWin, addr startpos
		invoke DialogBoxParam,hInstance,IDD_DLG1,NULL,addr FontWindowProc,NULL
	;.elseif eax == WM_SETICON
		;invoke 
	.elseif eax == WM_LBUTTONDOWN
		;mov draws, 1; змінна, яка дає дозвіл на малювання, після того як затиснута клавіша і до її відпускання
		
		invoke GetCursorPos, addr startpos ;коли малюємо фігуру то замап'ятовуємо координати її початку
		invoke ScreenToClient, hWin, addr startpos
		invoke MoveToEx, hdc_b, startpos.x, startpos.y, NULL
		;.elseif (drawingMode == ELLIPSE) || (drawingMode == RECTANG) || (drawingMode == LINE) || (drawingMode == DOT)	
		
		.if drawingMode == BUCKET
			invoke GetPixel, hdc_b, startpos.x, startpos.y ;визначаю колір стартової точки
			mov fill_surface.rgbResult, eax
			invoke flood_Fill, startpos.x, startpos.y ;далі, буде відбуватися філл до межі поверхні заповнення(за кольором поверхні, визначеному вище)
		
		.elseif drawingMode == EXTRAPEN
			;invoke extra_brush, startpos.x, startpos.y
		.elseif drawingMode == SCATTER
			invoke scatter
		.elseif drawingMode == DROPPER
			invoke GetCursorPos, addr startpos
			invoke GetPixel, hdc_b, startpos.x, startpos.y
			;mov usercolor.rgbResult, eax
			invoke CreatePen,PS_SOLID, penwi, eax
			invoke SelectObject, hdc_b, eax
		.endif

	.elseif eax == WM_LBUTTONUP
		invoke GetCursorPos, addr endpos
		invoke ScreenToClient, hWin, addr endpos

		;.if drawingMode == DRAW
			;mov draws, 0	

		.if drawingMode == DOT
			invoke LineTo, hdc_b, startpos.x, startpos.y
				
		.elseif drawingMode == LINE
			invoke LineTo, hdc_b, endpos.x, endpos.y
			
		.elseif drawingMode == RECTANG
			invoke Rectangle, hdc_b, startpos.x, startpos.y, endpos.x, endpos.y
		
		.elseif drawingMode == ELLIPSE
			invoke Ellipse, hdc_b, startpos.x, startpos.y, endpos.x, endpos.y
				
		.endif
;

	.elseif eax == WM_MOUSEMOVE
		.if wParam == MK_LBUTTON ;якщо затиснута ліва кнопка миші
			;y - верхня частина пааметру, x - нижня
			mov ecx,lParam ;у зберігатиметься в есх
			mov eax,lParam
			shr ecx,16 ;зсуваємо щоб отримати чистий у
			shl eax, 16 ;те ж саме для х
			shr eax, 16
			mov startpos.x, eax
			mov startpos.y, ecx
			
			.if drawingMode == DRAW ;якщо зараз увімкнений режим звичайного малювання
				invoke LineTo, hdc_b, startpos.x, startpos.y
			
			.elseif drawingMode == EXTRAPEN

				mov eax, startpos.x
				mov startpoint.x, eax
				sub startpoint.x, 20
				
				mov eax, startpos.y
				mov startpoint.y, eax
				sub startpoint.y, 20
				
				mov eax, startpos.x
				mov endpoint.x, eax
				add endpoint.x, 20
				
				mov eax, startpos.y
				mov endpoint.y, eax
				add endpoint.y, 20
				invoke Ellipse,hdc_b,startpoint.x, startpoint.y, endpoint.x, endpoint.y
			.elseif drawingMode == SCATTER
				
			.endif
			
		.endif
	
	.elseif eax==WM_CLOSE
	
		invoke KillTimer, hWin, 7000
		invoke DeleteDC, hdc_b
		invoke ReleaseDC, hWin, hdc
		invoke ReleaseDC, hWin, hdc0
		invoke EndDialog,hWin,0
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
