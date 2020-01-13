#NoEnv
SetBatchLines -1
ListLines Off
#include <logging>
#include <system>
#include <ansi>
#include <string>

Main:
    if (System.vArgs.MaxIndex() < 1)
    {
        stdin := FileOpen("*", "r")
        st := stdin.Read()
    }
    else if (System.vArgs[1] = "-h" || System.vArgs[1] = "--help" || System.vArgs[1] = "/?")
    {
        Ansi.WriteLine("usage: cdata <string>")
        Ansi.WriteLine("   or: Command | cdata")
        Ansi.WriteLine("   or: cdata (to read vom StdIn)")
        exitapp
    }
    else
    {
        st := System.vArgs[1]
    }
    try
    {
        OutputDebug %A_ScriptName% st="%st%"
        Ansi.WriteLine("<![CDATA[" st "]]>")
    }
    catch err
    {
        Ansi.WriteLine(err.Message "(" err.Extra ")")
        exitapp 0
    }
exitapp 1

conv(c) {
    OutputDebug %A_ScriptName% c=%c%
    return "&#" Asc(c) ";"
}
