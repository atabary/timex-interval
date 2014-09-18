defmodule TimexInterval.DateTime do

  @infinity :infinity

  @derive Access
  defstruct start_instant: @infinity,
            end_instant:   @infinity,
            start_open:    false,
            end_open:      true

  def new(start_instant, end_instant) do
    %TimexInterval.DateTime{start_instant: start_instant, end_instant: end_instant}
  end

end
