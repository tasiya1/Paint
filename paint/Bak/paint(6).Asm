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

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
;LOCAL y,x, col:dword
	mov		eax,uMsg
	.if eax==WM_INITDIALOG
	
	invoke GetDC, hWin ;0 - робочий стіл
	
	mov hdc, eax
	invoke GetDC, 0
	mov hdc0, eax
	
	;сумісний графічний контекст (бітмап для компіювання)
	invoke CreateCompatibleDC, hdc0
	mov hdc_b, eax
	invoke CreateCompatibleBitmap, hdc0, 1200, 800
	mov h_bitmap, eax
	invoke SelectObject, hdc_b, h_bitmap
	invoke Rectangle, hdc_b, -1, -1, 1201, 801
	
	invoke SetTimer, hWin, 17, 1, addr bitCopy
	
	invoke LoadCursor, hInstance, 4000
	mov hCursor, eax
	invoke SendDlgItemMessage, hInstance, IDD_DIALOG1, WM_SETCURSOR, hWin, NULL
	
	;ініціалізація структури для вибору кольору
	mov usercolor.lStructSize, sizeof CHOOSECOLOR
	;mov usercolor.hwndOwner, hWin
	mov usercolor.lpCustColors, offset colrBuf ;буфер на кастомні кольори
	mov usercolor.Flags, CC_FULLOPEN + CC_RGBINIT	;щоб повний вигляд палітри був одразу
	
	invoke CreatePen,PS_SOLID, 2, usercolor.rgbResult
	invoke SelectObject, hdc_b, eax
	
	.elseif eax == WM_SETCURSOR
		invoke SetCursor,hCursor
		ret
	
	.elseif eax==WM_COMMAND
		;встановлення модів малювання, від яких залежать дії при натисненні мишки
	   	.if wParam == IDM_ChooseColor 
	   		invoke ChooseColor, addr usercolor
	   	
	   	.elseif wParam == IDM_Draw ; "Draw"
			mov drawingMode, DRAW
      	.elseif wParam == IDM_Dot ; "Dot"
      		mov drawingMode, DOT
      	.elseif wParam == IDM_StraightLine ; "Straight Line"
			mov drawingMode, LINE
      	.elseif wParam == IDM_Rectangle ; "Rectangle"
			mov drawingMode, RECTANG
      	.elseif wParam == IDM_Ellipse ; "Ellipse"
			mov drawingMode, ELLIPSE
			
		.elseif wParam == IDM_P1
		mov eax, usercolor.rgbResult
			invoke CreatePen,PS_SOLID, 10, usercolor.rgbResult
			invoke SelectObject, hdc_b, eax
			
		.elseif wParam == IDM_P3
			invoke CreatePen,PS_SOLID, 3, usercolor.rgbResult
			invoke SelectObject, hdc_b, eax
		.elseif wParam == IDM_P5
			invoke CreatePen,PS_SOLID, 5, usercolor.rgbResult
			invoke SelectObject, hdc_b, eax
		.elseif wParam == IDM_P10
			invoke CreatePen,PS_SOLID, 10, usercolor.rgbResult
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
			invoke SetTextColor,hdc_b,usercolor.rgbResult
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
			invoke SetTextColor,hdc_b,usercolor.rgbResult
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
			invoke SetTextColor,hdc_b,usercolor.rgbResult
			invoke SetBkMode,hdc_b,TRANSPARENT ;фон тексту
      	
      	.endif
;	
	.elseif eax == WM_LBUTTONDBLCLK
		invoke GetCursorPos, addr startpos
		invoke ScreenToClient, hWin, addr startpos
		invoke DialogBoxParam,hInstance,IDD_DLG1,NULL,addr FontWindowProc,NULL

	.elseif eax == WM_LBUTTONDOWN
		;mov draws, 1; змінна, яка дає дозвіл на малювання, після того як затиснута клавіша і до її відпускання
		
		invoke GetCursorPos, addr startpos ;коли малюємо фігуру то замап'ятовуємо координати її початку
		invoke ScreenToClient, hWin, addr startpos
		invoke MoveToEx, hdc_b, startpos.x, startpos.y, NULL
		;.elseif (drawingMode == ELLIPSE) || (drawingMode == RECTANG) || (drawingMode == LINE) || (drawingMode == DOT)	
			

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
			.if drawingMode == DRAW ;якщо зараз увімкнений режим звичайного малювання
				;y - верхня частина пааметру, x - нижня
				mov ecx,lParam ;у зберігатиметься в есх
				mov eax,lParam
				shr ecx,16 ;зсуваємо щоб отримати чистий у
				shl eax, 16 ;те ж саме для х
				shr eax, 16
				mov endpos.x, eax
				mov endpos.y, ecx
				invoke LineTo, hdc_b, endpos.x, endpos.y 	
			.endif
			
		.endif
	
	.elseif eax==WM_CLOSE
		invoke KillTimer, hWin, 17
		invoke DeleteDC, hdc_b
		invoke ReleaseDC, hWin, hdc
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
