//------------------------------------------------------------------------------
//
//  PMDG 747QOTSII EFB connection sample 
// 
//------------------------------------------------------------------------------

#include <windows.h>
#include <wchar.h>
#include "PMDG_777X_SDK.h"
#include <gdiplus.h>
#include "SimConnect.h"

using namespace Gdiplus;

#define TIMER_ID	1

enum EVENT_ID {
	EVENT_EFB_SCREEN_ACTION,
	EVENT_EFB_MENU,
	EVENT_EFB_BACK,
};

int side = 0;  // The left EFB is displayed; set to 1 to display the right EFB

HANDLE  hSimConnect = NULL;
HANDLE hEFBChangeEvent;
BYTE* pEFBScreenBuff;
WCHAR errStr[1024] = L"Uninitialized";

RectF rctScreen(0, 0, EFB_SCREEN_WIDTH, EFB_SCREEN_HEIGHT);
RectF rctMenu(EFB_SCREEN_WIDTH + 5, 0, 75, 25);
RectF rctBack(EFB_SCREEN_WIDTH + 5, 30, 75, 25);


void OnPaint(HDC hdc)
{
	FontFamily   fontFamily(L"Microsoft Sans Serif");
	Font	     font(&fontFamily, 16, FontStyleRegular, UnitPixel);

	Graphics graphics(hdc);
	
	if (wcslen(errStr) == 0)
	{
 		Bitmap bmp(EFB_SCREEN_WIDTH, EFB_SCREEN_HEIGHT, 2 * EFB_SCREEN_WIDTH, PixelFormat16bppRGB555, pEFBScreenBuff);
		graphics.DrawImage(&bmp, 0, 0, 0, 0, EFB_SCREEN_WIDTH, EFB_SCREEN_HEIGHT, UnitPixel);

		SolidBrush   brush(Color::Black);
		Pen  pen(Color::Black);
		StringFormat format;
		format.SetAlignment(StringAlignmentCenter);
		format.SetLineAlignment(StringAlignmentCenter);

		graphics.DrawRectangle(&pen, rctMenu);
		graphics.DrawString(L"MENU", -1, &font, rctMenu, &format, &brush);

		graphics.DrawRectangle(&pen, rctBack);
		graphics.DrawString(L"BACK", -1, &font, rctBack, &format, &brush);
	}
	else
	{
		SolidBrush   brush(Color::Blue);
		graphics.DrawString(errStr, -1, &font, PointF(0, 0), &brush);
	}
}

bool initSimConnectEvents()
{
	HRESULT hr;

	if (SUCCEEDED(SimConnect_Open(&hSimConnect, "PMDG 777X Test", NULL, 0, 0, 0)))
	{
		if (side == 0)
		{
			hr = SimConnect_MapClientEventToSimEvent(hSimConnect, EVENT_EFB_SCREEN_ACTION, "#71532");	// EVT_EFB_L_SCREEN_ACTION 
			hr = SimConnect_MapClientEventToSimEvent(hSimConnect, EVENT_EFB_MENU, "#71332");			// EVT_EFB_L_MENU
			hr = SimConnect_MapClientEventToSimEvent(hSimConnect, EVENT_EFB_BACK, "#71333");			// EVT_EFB_L_BACK
		}
		else
		{
			hr = SimConnect_MapClientEventToSimEvent(hSimConnect, EVENT_EFB_SCREEN_ACTION, "#71533");	// EVT_EFB_R_SCREEN_ACTION
			hr = SimConnect_MapClientEventToSimEvent(hSimConnect, EVENT_EFB_MENU, "#71412");			// EVT_EFB_R_MENU
			hr = SimConnect_MapClientEventToSimEvent(hSimConnect, EVENT_EFB_BACK, "#71413");			// EVT_EFB_R_BACK
		}

		return true;
	}
	else
	{
		wcscpy(errStr, L"Unable to connect to SimConnect");
		return false;
	}
}

VOID initEFBMapping()
{
	DWORD dErr = 0;

	// Note: If the event and/or the file mapping have already been created by the PMDG SDK then 
	// CreateEvent() and CreateFileMapping() will not create a new event/file mapping but will 
	// return handles to the already existing ones

	// Handle of event that notifies when EFB screen contents are changed
	//
	hEFBChangeEvent = NULL;
	if (side == 0)
		hEFBChangeEvent = CreateEvent(NULL, FALSE, FALSE, TEXT(EFB_L_OUTPUTCHANGED_EVENT));
	else
		hEFBChangeEvent = CreateEvent(NULL, FALSE, FALSE, TEXT(EFB_R_OUTPUTCHANGED_EVENT));
	if (hEFBChangeEvent == NULL)
	{
		dErr = GetLastError();
		swprintf(errStr, L"CreateEvent error %d", (int)dErr);
		return;
	}

	// Handle of memory mapping that contains EFB image raw data
	//
	HANDLE hMapFileEFBContents = NULL;
	if (side == 0)
		hMapFileEFBContents = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, EFB_SCREEN_BUFF_SIZE, TEXT(EFB_L_SCREEN_CONTENTS));
	else
		hMapFileEFBContents = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, EFB_SCREEN_BUFF_SIZE, TEXT(EFB_R_SCREEN_CONTENTS));
	if (hMapFileEFBContents == NULL)
	{
		dErr = GetLastError();
		CloseHandle(hEFBChangeEvent);
		swprintf(errStr, L"CreateFileMapping error %d", (int)dErr);
		return;
	}

	// Pointer to the EFB image raw data
	//
	pEFBScreenBuff = (BYTE*)MapViewOfFile(hMapFileEFBContents, FILE_MAP_READ, 0, 0, EFB_SCREEN_BUFF_SIZE);
	if (pEFBScreenBuff == NULL)
	{
		dErr = GetLastError();
		CloseHandle(hEFBChangeEvent);
		CloseHandle(hMapFileEFBContents);
		swprintf(errStr, L"MapViewOfFile %d", (int)dErr);
		return;
	}

	wcscpy(errStr, L"");
}

bool checkEFBRefresh()
{
	DWORD res = WaitForSingleObject(hEFBChangeEvent, 0);

	return (res == WAIT_OBJECT_0);

	// res could be: WAIT_ABANDONED, WAIT_OBJECT_0, WAIT_TIMEOUT, WAIT_FAILED
}

void screenMouseAction(UINT message, WPARAM wParam, LPARAM lParam)
{
	POINTS pts = MAKEPOINTS(lParam);
	PointF point(pts.x, pts.y);

	SIMCONNECT_CLIENT_EVENT_ID evtID = -1;
	DWORD dwData = -1;

	if (rctScreen.Contains(point))	// EFB screen area was clicked: EFB SCREEN_ACTION event to be transmitted
	{
		// Event ID
		evtID = EVENT_EFB_SCREEN_ACTION;

		// Mouse action code
		int action = -1;
		if (message == WM_MOUSEMOVE)
			action = 0;
		else if (message == WM_LBUTTONDOWN)
			action = 1;
		else if (message == WM_LBUTTONUP)
			action = 2;
		else if (message == WM_MOUSEWHEEL)
			action = GET_WHEEL_DELTA_WPARAM(wParam) > 0 ? 3 : 4;

		// Construct parameter as combination of action code and position coordinates
		if (action >= 0)
		{
			// Screen coordinates expressed and 1/1000s of EFB screen width or height
			int xPos = (int)(1000.0*point.X / EFB_SCREEN_WIDTH);
			int yPos = (int)(1000.0*point.Y / EFB_SCREEN_HEIGHT);

			dwData = 1000000 * action + 1000 * xPos + yPos;
		}
	}
	else	// MENU or BACK boxes were clicked: EFB MENU or BACK button events to be transmitted
	{
		// Determine event ID
		if (rctMenu.Contains(point))
			evtID = EVENT_EFB_MENU;
		else if (rctBack.Contains(point))
			evtID = EVENT_EFB_BACK;

		// Determine parameter (mouse down or release)
		if (evtID)
		{
			if (message == WM_LBUTTONDOWN)
				dwData = MOUSE_FLAG_LEFTSINGLE;
			else if (message = WM_LBUTTONUP)
				dwData = MOUSE_FLAG_LEFTRELEASE;
		}
	}
	
	// Transmit the event with the appropriate parameter
	if (evtID >= 0 && dwData >= 0)
		SimConnect_TransmitClientEvent(hSimConnect, 0, evtID, dwData,
			SIMCONNECT_GROUP_PRIORITY_HIGHEST, SIMCONNECT_EVENT_FLAG_GROUPID_IS_PRIORITY);
}


LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);

INT WINAPI WinMain(HINSTANCE hInstance, HINSTANCE, PSTR, INT iCmdShow)
{
	HWND hWnd;
	MSG msg;
	WNDCLASS wndClass;
	GdiplusStartupInput gdiplusStartupInput;
	ULONG_PTR gdiplusToken;

	// Initialize GDI+.
	GdiplusStartup(&gdiplusToken, &gdiplusStartupInput, NULL);

	wndClass.style = CS_HREDRAW | CS_VREDRAW;
	wndClass.lpfnWndProc = WndProc;
	wndClass.cbClsExtra = 0;
	wndClass.cbWndExtra = 0;
	wndClass.hInstance = hInstance;
	wndClass.hIcon = LoadIcon(NULL, IDI_APPLICATION);
	wndClass.hCursor = LoadCursor(NULL, IDC_ARROW);
	wndClass.hbrBackground = (HBRUSH)GetStockObject(WHITE_BRUSH);
	wndClass.lpszMenuName = NULL;
	wndClass.lpszClassName = TEXT("PMDG 777X EFB Connection Test");
	RegisterClass(&wndClass);

	hWnd = CreateWindow(
		TEXT("PMDG 777X EFB Connection Test"), // window class name
		TEXT("PMDG 777X EFB Connection Test"), // window caption
		WS_OVERLAPPEDWINDOW, // window style
		CW_USEDEFAULT, // initial x position
		CW_USEDEFAULT, // initial y position
		CW_USEDEFAULT, // initial x size
		CW_USEDEFAULT, // initial y size
		NULL, // parent window handle
		NULL, // window menu handle
		hInstance, // program instance handle
		NULL); // creation parameters

	ShowWindow(hWnd, iCmdShow);
	UpdateWindow(hWnd);

	while(GetMessage(&msg, NULL, 0, 0))
	{
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

	GdiplusShutdown(gdiplusToken);
	return msg.wParam;
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT message,
	WPARAM wParam, LPARAM lParam)
{
	HDC hdc;
	PAINTSTRUCT ps;
	switch(message)
	{
	case WM_CREATE:
		if (initSimConnectEvents())						// Open SimConnect and set up the required EFB events 
		{
			initEFBMapping();							// Set up mapping and refresh event for the EFB screen 
			SetTimer(hWnd, TIMER_ID, 100, NULL);		// Set up a timer to check 10 times a second if EFB screen redrawing is required
		}		
		return 0;

	case WM_PAINT:
		hdc = BeginPaint(hWnd, &ps);
		OnPaint(hdc);
		EndPaint(hWnd, &ps);
		return 0;

	case WM_LBUTTONDOWN:
	case WM_LBUTTONUP:
	case WM_MOUSEWHEEL:
	case WM_MOUSEMOVE:
		if (wcslen(errStr) == 0)
			screenMouseAction(message, wParam, lParam);	// Handle mouse actions
		return 0;

	case WM_DESTROY:
		KillTimer(hWnd, TIMER_ID);
		PostQuitMessage(0);
		CloseHandle(hEFBChangeEvent);
		UnmapViewOfFile(pEFBScreenBuff);
		return 0;

	case WM_TIMER:
		if (checkEFBRefresh())						// Check if EFB screen contents have changed
			InvalidateRect(hWnd, NULL, NULL);		// Redraw the window 
		return 0;

	default:
		return DefWindowProc(hWnd, message, wParam, lParam);
	}
} 


