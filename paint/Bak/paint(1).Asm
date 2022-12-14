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
4)	??????????? ???????? Paint. ??????????: ?????????, ?????, ??????, ????????????, ??????, ??????. 
	????? ?????? ??? ????????????? ?????????? ??????. ??????????? ????????? ????????? ???????.
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
	;??????????? ???????? ? ?????? ?????????? ????????? ? ?????
	invoke BitBlt, hdc, 0, 0, 1200, 800, hdc_b, 0, 0, SRCCOPY
	ret

bitCopy endp

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
;LOCAL y,x, col:dword
	mov		eax,uMsg
	.if eax==WM_INITDIALOG
	
	invoke GetDC, hWin ;0 - ??????? ????
	mov hdc, eax
	invoke GetDC, 0
	mov hdc0, eax
	
	;???????? ????????? ???????? (?????? ??? ???????????)
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
	
	;????????????? ????????? ??? ?????? ???????
	mov usercolor.lStructSize, sizeof CHOOSECOLOR
	;mov usercolor.hwndOwner, hWin
	mov usercolor.lpCustColors, offset colrBuf ;????? ?? ???????? ???????
	mov usercolor.Flags, CC_FULLOPEN + CC_RGBINIT	;??? ?????? ?????? ??????? ??? ??????
	
	invoke CreatePen,PS_SOLID, penwi, usercolor.rgbResult
	invoke SelectObject, hdc_b, eax
	
	.elseif eax == WM_SETCURSOR
		invoke SetCursor,hCursor
		ret
	
	.elseif eax==WM_COMMAND
		;???????????? ????? ?????????, ??? ???? ???????? 䳿 ??? ?????????? ?????
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
			mov penwi, 1
			invoke CreatePen,PS_SOLID, penwi, usercolor.rgbResult
			invoke SelectObject, hdc_b, eax
			
		.elseif wParam == IDM_P3
			mov penwi, 3
			invoke CreatePen,PS_SOLID, penwi, usercolor.rgbResult
			invoke SelectObject, hdc_b, eax
		.elseif wParam == IDM_P5
			mov penwi, 5
			invoke CreatePen,PS_SOLID, penwi, usercolor.rgbResult
			invoke SelectObject, hdc_b, eax
		.elseif wParam == IDM_P10
			mov penwi, 10
			invoke CreatePen,PS_SOLID, penwi, usercolor.rgbResult
			invoke SelectObject, hdc_b, eax
		
      	.elseif wParam == IDM_AddText
      		invoke DialogBoxParam,hInstance,IDD_DLG1,NULL,addr FontWindowProc,NULL
			
      	.elseif wParam == IDM_Alba ; "Alba"

      		invoke AddFontResource,addr font3
			invoke GetDeviceCaps,hdc_b,LOGPIXELSY ;????????? ???????? ?? ???????? ????
			invoke MulDiv,40,eax,72 ;??? ??????????? ???????? ?????? ??????
			neg eax ; -eax
			invoke CreateFont, eax, 40, 0, 0, 500, 0, 0 , 0, DEFAULT_CHARSET,\ 
 	 		OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,DEFAULT_PITCH,addr f3
 	 		invoke SelectObject,hdc_b,eax ;?pply ????? ?????
 	 		invoke DeleteObject, eax
			invoke SetTextColor,hdc_b,usercolor.rgbResult
			invoke SetBkMode,hdc_b,TRANSPARENT ;??? ??????
			
      	.elseif wParam == IDM_ZombieMonster ; 
      	
      		invoke AddFontResource,addr font1
			invoke GetDeviceCaps,hdc_b,LOGPIXELSY ;????????? ???????? ?? ???????? ????
			invoke MulDiv,50,eax,72 ;??? ??????????? ???????? ?????? ??????
			neg eax ; -eax
			invoke CreateFont, eax, 50, 0, 0, 300, 0, 0 , 0, DEFAULT_CHARSET,\ 
 	 		OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,DEFAULT_PITCH,addr f1
 	 		invoke SelectObject,hdc_b,eax ;?pply ????? ?????
 	 		invoke DeleteObject, eax
			invoke SetTextColor,hdc_b,usercolor.rgbResult
			invoke SetBkMode,hdc_b,TRANSPARENT ;??? ??????
      	
      	.elseif wParam == IDM_GreenLondon ; 
      	
      		invoke AddFontResource,addr font2
			invoke GetDeviceCaps,hdc_b,LOGPIXELSY ;????????? ???????? ?? ???????? ????
			invoke MulDiv,30,eax,72 ;??? ??????????? ???????? ?????? ??????
			neg eax ; -eax
			invoke CreateFont, eax, 30, 0, 0, 300, 0, 0 , 0, DEFAULT_CHARSET,\ 
 	 		OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,DEFAULT_PITCH,addr f2
 	 		invoke SelectObject,hdc_b,eax ;?pply ????? ?????
 	 		invoke DeleteObject, eax
			invoke SetTextColor,hdc_b,usercolor.rgbResult
			invoke SetBkMode,hdc_b,TRANSPARENT ;??? ??????
      	
      	.endif
;	
	.elseif eax == WM_LBUTTONDBLCLK
		invoke GetCursorPos, addr startpos
		invoke ScreenToClient, hWin, addr startpos
		invoke DialogBoxParam,hInstance,IDD_DLG1,NULL,addr FontWindowProc,NULL

	.elseif eax == WM_LBUTTONDOWN
		;mov draws, 1; ??????, ??? ??? ?????? ?? ?????????, ????? ???? ?? ????????? ??????? ? ?? ?? ???????????
		
		invoke GetCursorPos, addr startpos ;???? ??????? ?????? ?? ?????'???????? ?????????? ?? ???????
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
		.if wParam == MK_LBUTTON ;???? ????????? ???? ?????? ????
			.if drawingMode == DRAW ;???? ????? ?????????? ????? ?????????? ?????????
				;y - ?????? ??????? ????????, x - ?????
				mov ecx,lParam ;? ??????????????? ? ???
				mov eax,lParam
				shr ecx,16 ;???????? ??? ???????? ?????? ?
				shl eax, 16 ;?? ? ???? ??? ?
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
			invoke TextOut, hdc_b, startpos.x, startpos.y, addr userText, sizeOfUserText ;????????? ?????? ?? ????
			call clearStr ;????????? ???????
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
