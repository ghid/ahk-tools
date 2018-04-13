; ahk: console
#include <logging>
#include <ansi>

Main:
	rc := 0
	try {
		Ansi.Write(ClipBoard)
		Ansi.WriteLine()
	} catch {
		rc := A_LastError
	}
exitapp rc 
