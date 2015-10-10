defmodule TimexInterval.DateTimeInterval do
  use Timex

  @default_from       Date.now()
  @default_until      Date.shift(@default_from, days: 7)
  @default_left_open  false
  @default_right_open true
  @default_step       [days: 1]

  defstruct from:       @default_from,
            until:      @default_until,
            left_open:  @default_left_open,
            right_open: @default_right_open,
            step:       @default_step

  @doc """
  Make a new interval.

  Note that by default intervals are right open.

  Valid keywords:
  - from: the date the interval starts at (defaults to `Date.now()`)
  - until: either the date the interval ends at, or a time shift that will be applied to the "from" date (defaults to `[days: 7]`)
  - left_open: whether the interval is left open, defaults to #{@default_left_open}
  - right_open: whether the interval is right open, defaults to #{@default_right_open}
  - step: the iteration step for enumerations, defaults to `[days: 1]`

  Shifts should be keyword lists valid for use with `Timex.Date.shift`.

  ## Examples

    iex> use Timex
    ...> use TimexInterval
    ...> DateTimeInterval.new(from: Date.from({2014, 9, 22}), until: Date.from({2014, 9, 29}))
    ...> |> DateTimeInterval.format!("%Y-%m-%d")
    "[2014-09-22, 2014-09-29)"

    iex> use Timex
    ...> use TimexInterval
    ...> DateTimeInterval.new(from: Date.from({2014, 9, 22}), until: [days: 7])
    ...> |> DateTimeInterval.format!("%Y-%m-%d")
    "[2014-09-22, 2014-09-29)"

    iex> use Timex
    ...> use TimexInterval
    ...> DateTimeInterval.new(from: Date.from({2014, 9, 22}), until: [days: 7], left_open: true, right_open: false)
    ...> |> DateTimeInterval.format!("%Y-%m-%d")
    "(2014-09-22, 2014-09-29]"

    iex> use Timex
    ...> use TimexInterval
    ...> DateTimeInterval.new(from: Date.from({{2014, 9, 22}, {15, 30, 0}}), until: [mins: 20], right_open: false)
    ...> |> DateTimeInterval.format!("%H:%M")
    "[15:30, 15:50]"

  """
  def new(keywords \\ []) do
    from       = Dict.get(keywords, :from,       Date.now())
    until      = Dict.get(keywords, :until,      [days: 7])
    left_open  = Dict.get(keywords, :left_open,  @default_left_open)
    right_open = Dict.get(keywords, :right_open, @default_right_open)
    step       = Dict.get(keywords, :step,       @default_step)

    %TimexInterval.DateTimeInterval{from: from, until: (if is_list(until), do: Date.shift(from, until), else: until),
                                    left_open: left_open, right_open: right_open, step: step}
  end

  @doc """
  Return the interval duration, given a unit.

  When the unit is one of `:secs`, `:mins`, `:hours`, `:days`, `:weeks`, `:months`, `:years`, the result is an `integer`.

  When the unit is `:timestamp`, the result is a tuple representing a valid `Timex.Time`.

  ## Example

    iex> use Timex
    ...> use TimexInterval
    ...> DateTimeInterval.new(from: Date.from({2014, 9, 22}), until: [months: 5])
    ...> |> DateTimeInterval.duration(:months)
    5

    iex> use Timex
    ...> use TimexInterval
    ...> DateTimeInterval.new(from: Date.from({{2014, 9, 22}, {15, 30, 0}}), until: [mins: 20])
    ...> |> DateTimeInterval.duration(:timestamp)
    {0, 1200, 0}

  """
  def duration(interval, unit) do
    Date.diff(interval.from, interval.until, unit)
  end

  @doc """
  Update the step for this interval.

  The step should be a keyword list valid for use with `Timex.Date.shift`.

  ## Examples

    iex> use Timex
    ...> use TimexInterval
    ...> DateTimeInterval.new(from: Date.from({2014, 9, 22}), until: [days: 3], right_open: false)
    ...> |> DateTimeInterval.with_step([days: 1]) |> Enum.map(&DateFormat.format!(&1, "%Y-%m-%d", :strftime))
    ["2014-09-22", "2014-09-23", "2014-09-24", "2014-09-25"]

    iex> use Timex
    ...> use TimexInterval
    ...> DateTimeInterval.new(from: Date.from({2014, 9, 22}), until: [days: 3], right_open: false)
    ...> |> DateTimeInterval.with_step([days: 2]) |> Enum.map(&DateFormat.format!(&1, "%Y-%m-%d", :strftime))
    ["2014-09-22", "2014-09-24"]

    iex> use Timex
    ...> use TimexInterval
    ...> DateTimeInterval.new(from: Date.from({2014, 9, 22}), until: [days: 3], right_open: false)
    ...> |> DateTimeInterval.with_step([days: 3]) |> Enum.map(&DateFormat.format!(&1, "%Y-%m-%d", :strftime))
    ["2014-09-22", "2014-09-25"]

  """
  def with_step(interval, step) do
    %TimexInterval.DateTimeInterval{interval | step: step}
  end

  @doc """
  Return a human readable version of the interval.

  The default formatter is `:strftime`, with the format `%Y-%m-%d %H:%M`

  ## Examples

    iex> use Timex
    ...> use TimexInterval
    ...> DateTimeInterval.new(from: Date.from({2014, 9, 22}), until: [days: 3])
    ...> |> DateTimeInterval.format!()
    "[2014-09-22 00:00, 2014-09-25 00:00)"

    iex> use Timex
    ...> use TimexInterval
    ...> DateTimeInterval.new(from: Date.from({2014, 9, 22}), until: [days: 3])
    ...> |> DateTimeInterval.format!("%Y-%m-%d")
    "[2014-09-22, 2014-09-25)"

  """
  def format!(interval, format_string \\ "%Y-%m-%d %H:%M", formatter \\ :strftime) do
    s1 = if interval.left_open, do: "(", else: "["
    s2 = DateFormat.format!(interval.from, format_string, formatter)
    s3 = ", "
    s4 = DateFormat.format!(interval.until, format_string, formatter)
    s5 = if interval.right_open, do: ")", else: "]"
    s1 <> s2 <> s3 <> s4 <> s5
  end

  defimpl Enumerable do
    def reduce(interval, acc, fun) do
      do_reduce({get_starting_date(interval), interval.until, interval.right_open, interval.step}, acc, fun)
    end

    def member?(_interval, _value),
      do: {:error, __MODULE__}

    def count(_interval),
      do: {:error, __MODULE__}

    ## Private

    defp do_reduce(_state, {:halt,    acc}, _fun), do: {:halted, acc}
    defp do_reduce( state, {:suspend, acc},  fun), do: {:suspended, acc, &do_reduce(state, &1, fun)}

    defp do_reduce({current_date, end_date, right_open, keywords}, {:cont, acc}, fun) do
      if has_recursion_ended?(current_date, end_date, right_open) do
        {:done, acc}
      else
        next_date = Date.shift(current_date, keywords)
        do_reduce({next_date, end_date, right_open, keywords}, fun.(current_date, acc), fun)
      end
    end

    defp get_starting_date(interval) do
      if interval.left_open do
        Date.shift(interval.from, interval.step)
      else
        interval.from
      end
    end

    defp has_recursion_ended?(current_date, end_date,  true), do: Date.compare(end_date, current_date) <= 0
    defp has_recursion_ended?(current_date, end_date, false), do: Date.compare(end_date, current_date) <  0
  end
end
