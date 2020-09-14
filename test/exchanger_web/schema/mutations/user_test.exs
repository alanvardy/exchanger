defmodule ExchangerWeb.Schema.Mutations.UserTest do
  use Exchanger.DataCase, async: true
  alias Exchanger.Accounts

  @create_user_doc """
    mutation createUser($first_name: String, $last_name: String) {
      create_user(first_name: $first_name, last_name: $last_name) {
        first_name
        last_name
      }
    }
  """

  describe "@create_user" do
    test "creates a user" do
      {:ok, users} = Accounts.all_users(%{})
      assert Enum.empty?(users)

      run_schema(@create_user_doc, %{"first_name" => "Bobby", "last_name" => "Dogooder"})

      {:ok, users} = Accounts.all_users(%{})
      assert Enum.count(users) == 1
      assert List.first(users).first_name == "Bobby"
      assert List.first(users).last_name == "Dogooder"
    end
  end

  @update_user_doc """
    mutation updateUser($id: ID, $first_name: String, $last_name: String) {
      update_user(id: $id, first_name: $first_name, last_name: $last_name) {
        id
        first_name
        last_name
      }
    }
  """

  describe "@update_user" do
    setup do
      %{user: insert(:user)}
    end

    test "updates a user", %{user: user} do
      run_schema(@update_user_doc, %{
        "id" => user.id,
        "first_name" => "Buffy",
        "last_name" => "DoBad"
      })

      {:ok, user} = Accounts.find_user(%{"id" => to_string(user.id)})
      assert user.first_name == "Buffy"
      assert user.last_name == "DoBad"
    end
  end
end
