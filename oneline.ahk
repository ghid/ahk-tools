stdin := FileOpen("*", "r `n")
data := StrReplace(Trim(stdin.Read(), "`n"), "`n", "")
data := StrReplace(data, "ä", "&auml;")
data := StrReplace(data, "ö", "&ouml;")
data := StrReplace(data, "ü", "&uuml;")
data := StrReplace(data, "Ä", "&Auml;")
data := StrReplace(data, "Ö", "&Ouml;")
data := StrReplace(data, "Ü", "&Uuml;")
data := StrReplace(data, "ß", "&szlig;")
data := RegExReplace(data, "(?<=\>)\s+(?=\<)", "")
OutputDebug data=%data%
Clipboard = %data%
stdin.Close()
