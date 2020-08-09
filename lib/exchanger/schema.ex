defmodule Exchanger.Schema do
  use Boundary
  @moduledoc "Common dependencies for schemas"
  defmacro __using__(_) do
    quote do
      use TypedEctoSchema
      import Ecto.Query, warn: false
      import Ecto.Changeset

      @timestamps_opts [type: :utc_datetime]
    end
  end
end
