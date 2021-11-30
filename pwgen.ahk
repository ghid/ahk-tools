;@Ahk2Exe-ConsoleApp
#Include <cui-libs>
#Include <Flimsydata>
#Include <Optparser>
#Include <System>
#Include <Arrays>
#Include <Random>

class Opt {
	static pattern := "cvccvcvl##"
	static help := false
    static newLine := false
}

Main:
exitapp main()

main() {
	op := new OptParser("pwgen [options]")
	op.add(new OptParser.String(0, "pattern"
			, Opt, "pattern", "Muster"
			, "Muster für die Passwort-Generierung (Standard: "
			. Opt.pattern ")",,, Opt.pattern))
    op.add(new OptParser.Boolean("n", "newline"
            , Opt, "newLine"
            , "Append new line (Default: no)"
            , OptParser.OPT_NEG | OptParser.OPT_NEG_USAGE ))
	op.add(new OptParser.Boolean("h", "help"
			, Opt, "help"
			, "", OptParser.OPT_HIDDEN))

	try {
		args := op.parse(System.vArgs)
		if (args.maxIndex()) {
			throw Exception("Ungültige Argumente: " Arrays.toString(args))
		}
	} catch ex {
		Ansi.writeLine(ex.message)
		Ansi.writeLine(op.usage())
		return 0
	}

	if (Opt.help) {
		Ansi.writeLine(op.usage())
		Ansi.writeLine("Mögliche Muster-Elemente:`n")
		Ansi.writeLine("    v - Vokal kleingeschrieben (a,e,i,o,u)")
		Ansi.writeLine("    V - Vokal großgeschrieben (A,E,I,O,U)")
		Ansi.writeLine("    c - Konsonant kleingeschrieben "
				. "(b,c,d,f,g,h,j,k,l,m,n,p,q,r,s,t,v,w,x,y,z)")
		Ansi.writeLine("    C - Konsonant großgeschrieben "
				. "(B,C,D,F,G,H,J,K,L,M,N,P,Q,R,S,T,V,W,X,Y,Z)")
		Ansi.writeLine("    l - Kleinbuchstabe (a-z)")
		Ansi.writeLine("    L - Großbuchstabe (A-Z)")
		Ansi.writeLine("    x - Buchstabe (a-Z)")
		Ansi.writeLine("    X - Buchstabe oder Leerzeichen (a-Z, )")
		Ansi.writeLine("    # - Ziffer (0-9)")
		Ansi.writeLine("    . - Satzzeichen (,.-;:`´'!?"")")
		Ansi.writeLine("    $ - Sonderzeichen (§$%&/()=\}][{@_#+*~<|>)")
		Ansi.writeLine("    a - Alphabetisch; Kombination aus x.$")
		Ansi.writeLine("    A - Alphanumerisch; Kombination aus x#")
		Ansi.writeLine("    = - Alphanumerisch mit Leerzeichen, "
				. "Tab oder Zeilenumbruch")
		Ansi.writeLine("    %[...,...] - Menge von Elementen, "
				. "z.B. Edelgase: %[He,Ne,Ar,Kr,Xe,Rn]")
		Ansi.writeLine("    \<zeichen> - Explizites Zeichen")
		Ansi.writeLine()
		return ""
	} else {
		fd := new Flimsydata.Pattern(A_TickCount)
		Ansi.write(fd.getPattern(Opt.pattern) (Opt.newLine ? "`n":""))
		return 1
	}
}
