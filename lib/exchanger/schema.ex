defmodule Exchanger.Schema do
  @moduledoc "Common dependencies for schemas"
  defmacro __using__(_opts) do
    quote do
      use TypedEctoSchema
      import Ecto.Query, warn: false
      import Ecto.Changeset

      @timestamps_opts [type: :utc_datetime]
    end
  end
end
