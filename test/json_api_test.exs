defmodule Voorhees.Test.JSONApi do
  use ExUnit.Case

  test "does not throw errors when conforms to schema" do
    payload = %{
      "data" => %{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      }
    }

    Voorhees.JSONApi.assert_schema payload, %{user: %{attributes: [:email, :name]}}
  end

  test "throws an assertion error when an unexpected type is provided" do
    payload = %{
      "data" => %{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      }
    }

    assert_raise ExUnit.AssertionError, "Expected schema did not contain type: user", fn ->
      Voorhees.JSONApi.assert_schema payload, %{post: %{attributes: [:title, :body]}}
    end
  end

  test "throws an assertion error when it is missing attributes" do
    payload = %{
      "data" => %{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      }
    }

    assert_raise ExUnit.AssertionError, "Payload was missing attributes: title", fn ->
      Voorhees.JSONApi.assert_schema payload, %{user: %{attributes: [:email, :name, :title]}}
    end
  end

  test "throws an assertion error when it has extra attributes" do
    payload = %{
      "data" => %{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      }
    }

    assert_raise ExUnit.AssertionError, "Payload contained additional attributes: name", fn ->
      Voorhees.JSONApi.assert_schema payload, %{user: %{attributes: [:email]}}
    end
  end
end
