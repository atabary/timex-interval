defmodule TimexInterval.DateTimeInterval do
  use Timex

  @default_start Date.now()
  @default_end Date.shift(@default_start, days: 7)

  @derive Access
  defstruct start_instant: @default_start,
            end_instant:   @default_end,
            start_open:    false,
            end_open:      true,
            step:          [days: 1]

  @doc """
  Make a new interval given a DateTime objects and a shift, or two DateTime objects
  """
  def new(start_instant, end_instant_or_keywords, start_open \\ false, end_open \\ true, step \\ [days: 1]) do
    end_instant = if is_list(end_instant_or_keywords) do
      Date.shift(start_instant, end_instant_or_keywords)
    else
      end_instant_or_keywords
    end
    %TimexInterval.DateTimeInterval{start_instant: start_instant, end_instant: end_instant,
                                    start_open: start_open, end_open: end_open, step: step}
  end

  @doc """
  Update the step for this interval.

  The step should be a keyword list: anything that is valid for the Timex.Date.shift function,
  which is used underneath.
  """
  def set_step(interval, step) do
    %TimexInterval.DateTimeInterval{interval | step: step}
  end

  @doc """
  Return a list of DateTime that spans the DateTimeInterval structure, by default with steps of one day.

  The keyword list can be anything that is valid for he Timex.Date.shift function, which is used underneath.

  ## Examples

    > use Timex
    > DateTimeInterval.new(Date.from({2014, 9, 22}), Date.from({2014, 9, 29}))
      |> DateTimeInterval.to_list()
      |> Enum.map(fn(dt) -> DateFormat.format!(dt, "%Y-%m-%d", :strftime) end)
    #> ["2014-09-22", "2014-09-23", "2014-09-24", "2014-09-25", "2014-09-26", "2014-09-27", "2014-09-28"]

  """
  def to_list(interval) do
    if interval.start_open do
      Date.shift(interval.start_instant, interval.step)
    else
      interval.start_instant
    end
    |> to_list(interval.end_instant, interval.end_open, interval.step, [])
  end

  @doc """
  Return a human readable version of the interval.

  ## Examples

    > use Timex
    > DateTimeInterval.new(Date.from({2014, 9, 22}), Date.from({2014, 9, 29}))
      |> DateTimeInterval.pretty_print()
    #=> "[2014-09-22 00:00:00 UTC, 2014-09-29 00:00:00 UTC)"

  """
  def pretty_print(interval) do
    s1 = if interval.start_open, do: "(", else: "["
    s2 = DateFormat.format!(interval.start_instant, "%Y-%m-%d %T %Z", :strftime)
    s3 = ", "
    s4 = DateFormat.format!(interval.end_instant, "%Y-%m-%d %T %Z", :strftime)
    s5 = if interval.end_open, do: ")", else: "]"
    s1 <> s2 <> s3 <> s4 <> s5
  end


  ## Private

  defp to_list(current_date, end_date, end_open, keywords, enumeration) do
    if has_recursion_ended?(current_date, end_date, end_open) do
      Enum.reverse(enumeration)
    else
      next_date = Date.shift(current_date, keywords)
      to_list(next_date, end_date, end_open, keywords, [current_date|enumeration])
    end
  end

  defp to_list(current_date, end_date, end_open, keywords, enumeration) do
    if has_recursion_ended?(current_date, end_date, end_open) do
      Enum.reverse(enumeration)
    else
      next_date = Date.shift(current_date, keywords)
      to_list(next_date, end_date, end_open, keywords, [current_date|enumeration])
    end
  end

  defp has_recursion_ended?(current_date, end_date,  true), do: Date.compare(end_date, current_date) <= 0
  defp has_recursion_ended?(current_date, end_date, false), do: Date.compare(end_date, current_date) <  0
end

defimpl Enumerable, for: TimexInterval.DateTimeInterval do
  def reduce(interval, acc, fun) do
    do_reduce(TimexInterval.DateTimeInterval.to_list(interval), acc, fun)
  end

  defp do_reduce(_,     {:halt, acc}, _fun),   do: {:halted, acc}
  defp do_reduce(list,  {:suspend, acc}, fun), do: {:suspended, acc, &do_reduce(list, &1, fun)}
  defp do_reduce([],    {:cont, acc}, _fun),   do: {:done, acc}
  defp do_reduce([h|t], {:cont, acc}, fun),    do: do_reduce(t, fun.(h, acc), fun)

  def member?(_list, _value),
    do: {:error, __MODULE__}
  def count(_list),
    do: {:error, __MODULE__}
end
