defmodule Exchanger.ExchangeRate.ExchangeRate do
  @moduledoc "Represents an exchange rate at a point in time"
  use TypedStruct

  typedstruct do
    @typedoc @moduledoc

    field :from, String.t(), enforce: true
    field :to, String.t(), enforce: true
    field :rate, float()
    field :updated, DateTime.t(), enforce: true
  end
end
