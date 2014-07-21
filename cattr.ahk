#NoEnv
SetBatchLines -1

pHandle := DllCall("GetStdHandle", "UInt", -11, "Ptr")
nArgs = %0%
if (nArgs >= 1) {
	attr = %1%
	msg = %2%
	OutputDebug attr = %attr%`; msg = %msg%
	StringReplace msg, msg, ^_, %A_Space%, All
	StringReplace msg, msg, \n, `n
	DllCall("SetConsoleTextAttribute", "Ptr", pHandle, "UShort", attr, "Int")
	FileAppend %msg%, CONOUT$, cp850
	exit attr
} else {
	VarSetCapacity(_csbi, 22, 0)
	DllCall("GetConsoleScreenBufferInfo", "Ptr", pHandle, "Ptr", &_csbi)
	exit NumGet(_csbi, 8, "UShort")
}

