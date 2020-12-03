class B64Tool {

	requires() {
		return [Ansi, Base64, OptParser, String]
	}
	
	class Options {
		static codepage := "cp1251"
		static help := false

		encoding[] {
			get {
				return B64Tool.Options.codePage
			}
			set {
				switch value {
				case "ansi":
					B64Tool.Options.codepage := "cp0"
				case "latin1":
					B64Tool.Options.codepage := "cp1251"
				case "utf-8":
					B64Tool.Options.codepage := "cp65001"
				case "utf-16":
					B64Tool.Options.codepage := "cp1200"
				default:
					B64Tool.Options.codepage := value
				}
				return B64Tool.Options.codepage
			}
		}
	}

	cli() {
		op := new OptParser(Format("{:s}: [-e <encoding>] [string]"
				, A_ScriptName))
		op.add(new OptParser.String("e", ""
				, B64Tool.Options, "encoding", "encoding"
				, "Specify a codepage (default: CP1251)"))
		op.add(new OptParser.Boolean("h", "help"
				, B64Tool.Options, "help"
				, "Display usage", OptParser.OPT_HIDDEN))
		op.add(new OptParser.Group("`nIf no 'string' is provided it will be "
				. "read from standard input."))
		return op
	}
}
