; ahk: con
#NoEnv
SetBatchLines -1

#Include <logging>
#Include <ansi>
; #Include <optparser>
#Include ..\lib2\optparser.ahk
#Include <calendar>
#Include <system>

Main:
    opts := { h: false
            , q: false
            , r: false
            , adjust: { years: 0
                      , month: 0
                      , days: 0
                      , hours: 0
                      , minutes: 0
                      , seconds: 0 } }

	op := new OptParser(["time2long [-q] [adjustments] [timestamp]", "time2long -r [-q] [adjustments] <long-time>"], OptParser.PARSER_ALLOW_DASHED_ARGS)
	op.Add(new OptParser.Boolean("h", "help", opts, "h", "This help", OptParser.OPT_HIDDEN))
	op.Add(new OptParser.Boolean("q", "quiet", opts, "q", "Run quiet and return result as exit code"))
	op.Add(new OptParser.Boolean("r", "", opts, "r", "Reverse operation: convert long-time to timestamp"))
	op.Add(new OptParser.Group("`nAdjustments:"))
	op.Add(new OptParser.String("y", "", opts.adjust, "years", "adujst-years", "Adjust time +/- years", OptParser.OPT_ARG,, 0))
	op.Add(new OptParser.String("m", "", opts.adjust, "month", "adujst-month", "Adjust time +/- month", OptParser.OPT_ARG,, 0))
	op.Add(new OptParser.String("d", "", opts.adjust, "days", "adujst-days", "Adjust time +/- days", OptParser.OPT_ARG,, 0))
	op.Add(new OptParser.String("H", "", opts.adjust, "hours", "adujst-hours", "Adjust time +/- hours", OptParser.OPT_ARG,, 0))
	op.Add(new OptParser.String("M", "", opts.adjust, "minutes", "adujst-minutes", "Adjust time +/- minutes", OptParser.OPT_ARG,, 0))
	op.Add(new OptParser.String("S", "", opts.adjust, "seconds", "adujst-seconds", "Adjust time +/- seconds", OptParser.OPT_ARG,, 0))
    op.Add(new OptParser.Group("`nThe 'timestamp' may start with 'Today' (or 'T') to set today's date as the date"))
	
	try {
		args := op.Parse(system.vArgs)

		if (opts.h) {
			Ansi.WriteLine(op.Usage())
			exitapp
		} else if (args.MaxIndex() > 1) {
			throw Exception("Too many arguments")
        }else if (opts.r && args.MaxIndex() < 1) {
			throw Exception("Missing argument")
        }

		if (!opts.r) {
            if (RegExMatch(args[1], "i)^T(oday)?(.*)$", $)) {
                args[1] := A_YYYY A_MM A_DD $2
            }
			ts := new Calendar(args[1])
			ts.Adjust(opts.adjust.years+0, opts.adjust.month+0, opts.adjust.days+0, opts.adjust.hours+0, opts.adjust.minutes+0, opts.adjust.seconds+0) 
			if (opts.q) {
				res := ts.Long()
            } else {
				Ansi.WriteLine(ts.FormatTime("dd.MM.yyyy HH.mm.ss") ": " ts.Long())
            }
		} else {
			ts := new Calendar().Long(args[1])
			ts.Adjust(opts.adjust.years+0, opts.adjust.month+0, opts.adjust.days+0, opts.adjust.hours+0, opts.adjust.minutes+0, opts.adjust.seconds+0) 
			if (opts.q) {
				res := ts.Get()
            } else {
				Ansi.WriteLine(ts.Long() ": " ts.FormatTime("dd.MM.yyyy HH.mm.ss"))
            }
		}
	} catch _ex {
		Ansi.WriteLine(_ex.Message)
		Ansi.WriteLine(op.Usage())	
	}

exitapp res
