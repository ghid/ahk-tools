#include <logging>
#include <system>
#include <ansi>

DetectHiddenWindows on

OnMessage(0x4a, "Receive_Message")
OnMessage(0x4107, "Logging_Consumer")

; Send(System.vArgs[1])
pid := System.vArgs[1]
my_pid := DllCall("GetCurrentProcessId")
; SendMessage 0x4106, %my_pid%,,, ahk_pid %pid%
OutputDebug SendMessage 0x4106, %my_pid%,,, ahk_id 0xFFFF
SendMessage 0x4106, %my_pid%,,, ahk_id 0xFFFF

exitapp

Send(pid) {
	c_pid := DllCall("GetCurrentProcessId")
	SendMessage 0x4106, %c_pid%,,, ahk_pid %pid%
	; ll := "*=warning"
	; VarSetCapacity(data, 3*A_PtrSize, 0)
	; size := (StrLen(ll) + 1)*(A_IsUnicode?2:1)
	; NumPut(size, data, A_PtrSize)
	; NumPut(&ll, data, 2*A_PtrSize)
	; OutputDebug % "SEND: (" pid " / " c_pid ") " LoggingHelper.HexDump(&data, 0, size)

	; SendMessage, 0x4a, 0, &data,, ahk_pid %pid%

	return ErrorLevel
}

Receive_Message(wParam, lParam) {
	OutputDebug RECEIVED_MESSAGE
	addr := NumGet(lParam + 2*A_PtrSize)
	data := StrGet(addr)
	Ansi.WriteLine(data)

	return true
}

Logging_Consumer(w, l) {
	OutputDebug %A_ThisFunc% %w%
	Ansi.WriteLine(w)
}
