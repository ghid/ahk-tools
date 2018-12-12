#include <logging>
#include <system>
#include <base64>
#include <ansi>

StrPutVar(string, ByRef var, encoding)
{
    VarSetCapacity(var, StrPut(string, encoding)
        * ((encoding="utf-16"||encoding="cp1200"||encoding="utf-8") ? 2 : 1) )
    l := StrPut(string, &var, encoding)
	return l-1
}

Main:
    B64_CP := System.EnvGet("B64_CP")
    if (System.vArgs.MaxIndex() < 1)
    {
        stdin := FileOpen("*", "r")
        st := stdin.Read()
        cp := (B64_CP <> "" ? B64_CP : "cp1252")
    }
    else if (System.vArgs[1] = "-h" || System.vArgs[1] = "--help" || System.vArgs[1] = "/?")
    {
        Ansi.WriteLine("usage: b64enc <string> [encoding]")
        Ansi.WriteLine("   or: Command | b64enc")
        Ansi.WriteLine("   or: b64enc (to read vom StdIn)")
        Ansi.WriteLine("`nSet environment variable B64_CP "
            . "to use a different encoding (Default: cp1252)")
        exitapp
    }
    else
    {
        st := System.vArgs[1]
        cp := (System.vArgs.MaxIndex() > 1 ? System.vArgs[2] : (B64_CP <> "" ? B64_CP : "cp1252"))
    }
    try
    {
    OutputDebug %A_ScriptName% cp=%cp% st="%st%"
    l_cp := StrPutVar(st, st_cp, cp)
    st := Base64.Encode(st_cp, l_cp)
    OutputDebug %A_ScriptName% l_cp=%l_cp% st="%st%"
    Ansi.WriteLine(st)
    }
    catch err
    {
        Ansi.WriteLine(err.Message "(" err.Extra ")")
        exitapp 0
    }
exitapp 1
