# credo:disable-for-this-file Credo.Check.Readability.Specs
defmodule ExchangerWeb.GraphQL.Middleware.HandleChangesetErrors do
  @moduledoc "Format Changeset Errors"
  @behaviour Absinthe.Middleware

  def call(resolution, _config) do
    %{resolution | errors: Enum.flat_map(resolution.errors, &handle_error/1)}
  end

  defp handle_error(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {err, _opts} -> err end)
    |> Enum.map(fn {k, v} -> "#{k}: #{v}" end)
  end

  defp handle_error(error), do: [error]
end
