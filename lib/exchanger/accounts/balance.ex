defmodule Exchanger.Accounts.Balance do
  @moduledoc "A wallet or aggregate balance"
  use TypedStruct

  typedstruct do
    @typedoc @moduledoc

    field :amount, integer, enforce: true
    field :currency, String.t(), enforce: true
    field :timestamp, DateTime.t(), enforce: true
  end
end
