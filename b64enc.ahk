#include <logging>
#include <system>
#include <base64>
#include <ansi>

StrPutVar(string, ByRef var, encoding) {
    VarSetCapacity(var, StrPut(string, encoding)
        * ((encoding="utf-16"||encoding="cp1200"||encoding="utf-8") ? 2 : 1) )
    l := StrPut(string, &var, encoding)
	return l-1
}

B64_CP := System.EnvGet("B64_CP")
if (System.vArgs.MaxIndex() < 1) {
	stdin := FileOpen("*", "r")
	st := Trim(stdin.Readline(), "`r`n")
	cp := (B64_CP <> "" ? B64_CP : "cp1252")
} else {
	st := System.vArgs[1]
	cp := (System.vArgs.MaxIndex() > 1 ? System.vArgs[2] : (B64_CP <> "" ? B64_CP : "cp1252"))
}
OutputDebug %A_ScriptName% cp=%cp% st="%st%"
l_cp := StrPutVar(st, st_cp, cp)
st := Base64.Encode(st_cp, l_cp)
OutputDebug %A_ScriptName% l_cp=%l_cp% st="%st%"
Ansi.WriteLine(st)

exitapp 1
