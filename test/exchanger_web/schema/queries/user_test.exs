defmodule ExchangerWeb.Schema.Queries.UserTest do
  use Exchanger.DataCase, async: true

  @user_doc """
    query findUser($first_name: String, $last_name: String) {
      user(first_name: $first_name, last_name: $last_name) {
        id,
        first_name,
        last_name,
        wallets {
          id,
          currency,
          balance
        }
      }
    }
  """

  @users_doc """
    query findUsers($first_name: String, $last_name: String) {
      users(first_name: $first_name, last_name: $last_name) {
        id,
        first_name,
        last_name
      }
    }
  """

  @user_params %{
    first_name: "Nancy",
    last_name: "Bell"
  }

  setup do
    %{user: create_user(@user_params)}
  end

  describe "@user" do
    test "Can get user by name", %{user: user} do
      user_id =
        @user_doc
        |> run_schema(%{"first_name" => "Nancy", "last_name" => "Bell"})
        |> get_in(["user", "id"])
        |> String.to_integer()

      assert user_id === user.id
    end

    test "Can get user by id", %{user: user} do
      user_id =
        @user_doc
        |> run_schema(%{"id" => user.id})
        |> get_in(["user", "id"])
        |> String.to_integer()

      assert user_id === user.id
    end

    test "Can get wallets with user", %{user: user} do
      wallet = insert(:wallet, user_id: user.id)

      [%{"id" => id, "currency" => currency}] =
        @user_doc
        |> run_schema(%{"id" => user.id})
        |> get_in(["user", "wallets"])

      assert id === Integer.to_string(wallet.id)
      assert currency === wallet.currency
    end
  end

  describe "@users" do
    test "Can get users by name", %{user: user} do
      user_ids =
        @users_doc
        |> run_schema(%{"first_name" => "Nancy", "last_name" => "Bell"})
        |> Map.get("users")
        |> Enum.map(&String.to_integer(&1["id"]))

      assert user_ids === [user.id]
    end
  end
end
