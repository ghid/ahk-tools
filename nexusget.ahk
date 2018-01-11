#NoEnv
#NoTrayIcon

#include <logging>
#include <system>
#include <ansi>
#include <arrays>
#include <string>

if (system.vArgs.MaxIndex() < 2 or system.vArgs.MaxIndex() > 3) {
	Ansi.WriteLine("nexusget [--parse-only] <URL> <output>`n")
	Ansi.WriteLine("${x} notations notations in the output will be substitued by &x= parameters of the URL")
	exitapp 1
}

arg := Arrays.Shift(system.vArgs, 1)
if (arg = "--parse-only") {
	parse_only := true
	arg := Arrays.Shift(system.vArgs, 1)
} else
	parse_only := false
url := arg.Trim()
arg := Arrays.Shift(system.vArgs, 1)
output := arg
OutputDebug parse_only=%parse_only%
OutputDebug url=%url%
OutputDebug output=%output%

url_parts := StrSplit(url, "?")
param_list := StrSplit(url_parts[url_parts.MaxIndex()], "&")
params := {}
for n, p in param_list {
	prop := StrSplit(p, "=")
	params[prop[1]] := prop[2]
}
OutputDebug % "Parameters:`n" LoggingHelper.Dump(params)

while (RegExMatch(output, "(?<=\$\{)\w+?(?=\})", $)) {
	output := StrReplace(output, "${" $ "}", params[$], All)
}

OutputDebug output=%output%
	
if (!parse_only) {
	UrlDownloadToFile %url%, %output%
	if (!ErrorLevel)
		Ansi.WriteLine(output)
	else
		Ansi.WriteLine("")
} else {
	output := output.Trim()
	Ansi.WriteLine(output)
	OutputDebug % "output:`n" LoggingHelper.HexDump(&output, 0, StrLen(output)*(A_IsUnicode?2:1))
}

exitapp
