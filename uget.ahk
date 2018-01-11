#include <logging>
#include <system>
#include <ansi>

Ansi.WriteLine("TEST")
if (system.vArgs.MaxIndex() <> 2) {
	Ansi.WriteLine("nexusget <url> <outfile>`n")
	Ansi.WriteLine("You may use the &x=Parameters of the URL to make an outfile-name")
	exitapp 1
}

url := system.vArgs[1]
outfile := system.vArgs[2]
OutputDebug url=%url%
OutputDebug outfile=%outfile%

url_parts := StrSplit(url, "?")
param_list := StrSplit(url_parts[url_parts.MaxIndex()], "&")
params := {}
for n, p in param_list {
	prop := StrSplit(p, "=")
	params[prop[1]] := prop[2]
}
OutputDebug % "Parameters:`n" LoggingHelper.Dump(params)

while (RegExMatch(outfile, "(?<=&\()\w+?(?=\))", $)) {
	outfile := StrReplace(outfile, "&(" $ ")", params[$], All)
}

OutputDebug outfile=%outfile%
	
UrlDownloadToFile %url%, %outfile%
ret := ErrorLevel
OutputDebug ret=%ret%

exitapp %ret%
