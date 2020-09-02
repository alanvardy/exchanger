defmodule ExchangerWeb.Schema.Queries.UserTest do
  use Exchanger.DataCase, async: true
  alias Exchanger.Accounts
  alias ExchangerWeb.Schema

  @user_doc """
    query findUser($first_name: String, $last_name: String) {
      user(first_name: $first_name, last_name: $last_name) {
        id,
        first_name,
        last_name
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

  describe "@user" do
    test "Can get user by name" do
      assert {:ok, user} = Accounts.create_user(@user_params)

      assert {:ok, %{data: data}} =
               Absinthe.run(@user_doc, Schema,
                 variables: %{"first_name" => "Nancy", "last_name" => "Bell"}
               )

      user_id =
        data
        |> get_in(["user", "id"])
        |> String.to_integer()

      assert user_id === user.id
    end
  end

  describe "@users" do
    test "Can get users by name" do
      assert {:ok, user} = Accounts.create_user(@user_params)

      assert {:ok, %{data: data}} =
               Absinthe.run(@users_doc, Schema,
                 variables: %{"first_name" => "Nancy", "last_name" => "Bell"}
               )

      user_ids =
        data
        |> Map.get("users")
        |> Enum.map(&String.to_integer(&1["id"]))

      assert user_ids === [user.id]
    end
  end
end
