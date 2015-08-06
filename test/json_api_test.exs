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

  test "does not throw error when the data objects match" do
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

    Voorhees.JSONApi.assert_payload payload, %{
      data: %{
        id: "1",
        type: "user",
        attributes: %{
          email: "test@example.com",
          name: "Tester"
        }
      }
    }
  end

  test "does not throw error when the payload has attributes not in the expected payload" do
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

    Voorhees.JSONApi.assert_payload payload, %{
      data: %{
        id: "1",
        type: "user",
        attributes: %{
          name: "Tester"
        }
      }
    }
  end

  test "throws an error when the actual payload is missing attributes" do
    payload = %{
      "data" => %{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "name" => "Tester"
        }
      }
    }

    assert_raise ExUnit.AssertionError, "Payload did not match expected", fn ->
      Voorhees.JSONApi.assert_payload payload, %{
        data: %{
          id: "1",
          type: "user",
          attributes: %{
            email: "test@example.com",
            name: "Tester"
          }
        }
      }
    end
  end
end
