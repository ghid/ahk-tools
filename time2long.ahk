#NoEnv
SetBatchLines -1

#Include <logging>
#Include <console>
#Include <optparser>
#Include <calendar>
#Include <system>

Main:
	op := new OptParser("time2long [adjustments] [timestamp]", OptParser.PARSER_ALLOW_DASHED_ARGS)
	op.Add(new OptParser.Group("Adjustments:"))
	op.Add(new OptParser.Boolean("h", "help", _h, "This help", OptParser.OPT_HIDDEN))
	op.Add(new OptParser.String("y", "", _adj_years, "adujst-years", "Adjust time +/- years", OptParser.OPT_OPTARG,, 0))
	op.Add(new OptParser.String("m", "", _adj_month, "adujst-month", "Adjust time +/- month", OptParser.OPT_OPTARG,, 0))
	op.Add(new OptParser.String("d", "", _adj_days, "adujst-days", "Adjust time +/- days", OptParser.OPT_OPTARG,, 0))
	op.Add(new OptParser.String("H", "", _adj_hours, "adujst-hours", "Adjust time +/- hours", OptParser.OPT_OPTARG,, 0))
	op.Add(new OptParser.String("M", "", _adj_minutes, "adujst-minutes", "Adjust time +/- minutes", OptParser.OPT_OPTARG,, 0))
	op.Add(new OptParser.String("S", "", _adj_seconds, "adujst-seconds", "Adjust time +/- seconds", OptParser.OPT_OPTARG,, 0))
	
	try {
		args := op.Parse(system.vArgs)
		if (_h) {
			Console.Write(op.Usage() "`n")
			exitapp
		}
		else if (args.MaxIndex() > 1)
			throw Exception("Too many arguments")

		ts := new Calendar(args[1])
		ts.Adjust(_adj_years+0, _adj_month+0, _adj_days+0, _adj_hours+0, _adj_minutes+0, _adj_seconds+0) 
		Console.Write(ts.FormatTime("dd.MM.yyyy HH.mm.ss") ": " ts.Long() "`n")
	} catch _ex {
		Console.Write(_ex.Message "`n")
		Console.Write(op.Usage() "`n")	
	}
exitapp
