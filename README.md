# Timex Interval

Timex Interval is an extension of [Timex](https://github.com/bitwalker/timex) that deals with date/time intervals.

It's useful to iterate over time intervals, for instance every day between two dates.


## Constructors

There are two ways to generate an interval:

  - by giving the constructor two DateTime objects,
  - by giving the constructor a single DateTime object and a shift (as accepted by Timex.Date.shift).

```elixir
use Timex
use TimexInterval

DateTimeInterval.new(Date.from({2014, 9, 22}), Date.from({2014, 9, 25}))
|> DateTimeInterval.pretty_print()
#=> "[2014-09-22 00:00:00 UTC, 2014-09-25 00:00:00 UTC)"

DateTimeInterval.new(Date.from({2014, 9, 22}), [days: 3])
|> DateTimeInterval.pretty_print()
#=> "[2014-09-22 00:00:00 UTC, 2014-09-25 00:00:00 UTC)"

```

You can also specify whether the left and right bounds are open.

```elixir
use Timex
use TimexInterval

DateTimeInterval.new(Date.from({2014, 9, 22}), [days: 3], false, false)
|> DateTimeInterval.pretty_print()
#=> "[2014-09-22 00:00:00 UTC, 2014-09-25 00:00:00 UTC]"

```


## Iterators

The default behavior is to iterate over each day.

```elixir
use Timex
use TimexInterval

DateTimeInterval.new(Date.from({2014, 9, 22}), [days: 3])
|> DateTimeInterval.iterate()
|> Enum.map(fn(dt) -> DateFormat.format!(dt, "%Y-%m-%d", :strftime) end)
#=> ["2014-09-22", "2014-09-23", "2014-09-24"]
```

You can easily specify whether to exclude the first and last dates:

```elixir
use Timex
use TimexInterval

DateTimeInterval.new(Date.from({2014, 9, 22}), [days: 3], false, false)
|> DateTimeInterval.iterate()
|> Enum.map(fn(dt) -> DateFormat.format!(dt, "%Y-%m-%d", :strftime) end)
#=> ["2014-09-22", "2014-09-23", "2014-09-24", "2014-09-25"]
```

You can of course iterate over anything else, for instance by chunks of 10 minutes:

```elixir
use Timex
use TimexInterval

DateTimeInterval.new(Date.from({{2014, 9, 22}, {15, 0, 0}}), [hours: 1])
|> DateTimeInterval.iterate([mins: 10])
|> Enum.map(fn(dt) -> DateFormat.format!(dt, "%H:%M", :strftime) end)
#=> ["15:00", "15:10", "15:20", "15:30", "15:40", "15:50"]
```
