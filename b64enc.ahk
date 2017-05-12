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

OutputDebug % System.vArgs.MaxIndex() " arg(s) provided"
if (System.vArgs.MaxIndex() < 1) {
	Ansi.WriteLine("Usage: b64enc <text> [encoding]")
	exitapp 1
}
st := System.vArgs[1]
cp := "cp1252"
if (System.vArgs.MaxIndex() > 1)
	cp := System.vArgs[2]
OutputDebug st=%st%
OutputDebug cp=%cp%
l_cp := StrPutVar(st, st_cp, cp)
Ansi.WriteLine(Base64.Encode(st_cp, l_cp))

exitapp 0
