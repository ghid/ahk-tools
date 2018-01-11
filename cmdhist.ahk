#InstallKeybdHook
#include <logging>
#include <ansi>

G_WIN := WinExist("A")

cmd := ""

StringReplace PROMPT, PROMPT, $E, , All 
StringReplace PROMPT, PROMPT, $S, %A_Space%, All
StringReplace PROMPT, PROMPT, $P, %A_WorkingDir%, All
StringReplace PROMPT, PROMPT, $F, ), All
StringReplace PROMPT, PROMPT, $+,, All

loop {
	Hotkey ^d, quit, On
	Ansi.Write(PROMPT)
	Ansi.ReadLine(false, cmd)
	OutputDebug %cmd%
	if (cmd = "x")
		exitapp
	else
		RunWait %comspec% /c "%cmd%"
}

quit:
exitapp
