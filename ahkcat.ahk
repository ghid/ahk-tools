#include <logging>
#include <ansi>
#include <system>

st := ""
loop % System.vArgs.MaxIndex() {
    st .= (st = "" ? "" : " ") System.vArgs[A_Index]
}

Ansi.Write(st)

exitapp
