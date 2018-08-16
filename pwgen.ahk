; ahk: con
#include <logging>
#include <ansi>
#include <flimsydata>
#include <optparser>
#include <system>
#include <arrays>

class Opt {
	static pattern := "cvccvcvl##"
}

Main:
	_main := new Logger("app.pwgen.Main")
	main()
exitapp _main.Exit()

main() {
	_log := new Logger("app.pwgen." A_ThisFunc)

	op := new OptParser("pwgen [options]")
	op.Add(new OptParser.String(0, "pattern", _pattern, "Muster", "Muster für die Passwort-Generierung (Standard: " Opt.pattern ")",,, Opt.pattern))
	op.Add(new OptParser.Boolean("h", "help", _help, "", OptParser.OPT_HIDDEN))

	try {
		args := op.Parse(System.vArgs)
		if (args.MaxIndex())	
			throw _log.Exit(Exception("Ungültige Argumente: " Arrays.ToString(args)))
		Opt.pattern := OptParser.TrimArg(_pattern)
	} catch _ex {
		Ansi.WriteLine(_ex.Message)
		Ansi.WriteLine(op.Usage())
	}

	if (_help) {
		Ansi.WriteLine(op.Usage())
		Ansi.WriteLine("Mögliche Muster-Elemente:`n")
		Ansi.WriteLine("    v - Vokal kleingeschrieben (a,e,i,o,u)")
		Ansi.WriteLine("    V - Vokal großgeschrieben (A,E,I,O,U)")
		Ansi.WriteLine("    c - Konsonant kleingeschrieben (b,c,d,f,g,h,j,k,l,m,n,p,q,r,s,t,v,w,x,y,z)")
		Ansi.WriteLine("    C - Konsonant großgeschrieben (B,C,D,F,G,H,J,K,L,M,N,P,Q,R,S,T,V,W,X,Y,Z)")
		Ansi.WriteLine("    l - Kleinbuchstabe (a-z)")
		Ansi.WriteLine("    L - Großbuchstabe (A-Z)")
		Ansi.WriteLine("    x - Buchstabe (a-Z)")
		Ansi.WriteLine("    X - Buchstabe oder Leerzeichen (a-Z, )")
		Ansi.WriteLine("    # - Ziffer (0-9)")
		Ansi.WriteLine("    . - Satzzeichen (,.-;:`´'!?"")")
		Ansi.WriteLine("    $ - Sonderzeichen (§$%&/()=\}][{@_#+*~<|>)")
		Ansi.WriteLine("    a - Alphabetisch; Kombination aus x.$")
		Ansi.WriteLine("    A - Alphanumerisch; Kombination aus a#")
		Ansi.WriteLine("    * - Alphanumerisch mit Leerzeichen, Tab oder Zeilenumbruch")
		Ansi.WriteLine("    %[...,...] - Menge von Elementen, z.B. Edelgase: %[He,Ne,Ar,Kr,Xe,Rn]")
		Ansi.WriteLine("    \<zeichen> - Explizites Zeichen")
		Ansi.WriteLine()
	} else {
		fd := new Flimsydata.Simple(A_TickCount)
		Ansi.WriteLine(fd.GetPattern(Opt.pattern))
	}

	return _log.Exit()
}

