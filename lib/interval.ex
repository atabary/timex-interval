defmodule TimexInterval do
  defmacro __using__(_) do
    quote do
      alias TimexInterval.DateTimeInterval
    end
  end
end
