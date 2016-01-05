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
      }, "included" => [%{
        "type" => "user",
        "id" => "3",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      }]
    }

    Voorhees.JSONApi.assert_schema payload, %{user: %{attributes: [:email, :name]}}

    payload = %{
      "data" => [%{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      }],
      "included" => [%{
        "type" => "user",
        "id" => "3",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      }]
    }

    Voorhees.JSONApi.assert_schema payload, %{user: %{attributes: [:email, :name]}}

    payload = %{
      "data" => [%{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      },%{
        "type" => "user",
        "id" => "2",
        "attributes" => %{
          "email" => "test2@example.com",
          "name" => "Tester"
        }
      }],
      "included" => [%{
        "type" => "user",
        "id" => "3",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      }]
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

    payload = %{
      "data" => [%{
        "type" => "post",
        "id" => "1",
        "attributes" => %{
          "title" => "Awesome title",
          "body" => "Awesome Body"
        }
      },%{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      }]
    }

    assert_raise ExUnit.AssertionError, "Expected schema did not contain type: user", fn ->
      Voorhees.JSONApi.assert_schema payload, %{post: %{attributes: [:title, :body]}}
    end

    payload = %{
      "data" => [%{
        "type" => "post",
        "id" => "1",
        "attributes" => %{
          "title" => "Awesome title",
          "body" => "Awesome Body"
        }
      },%{
        "type" => "user",
        "id" => "2",
        "attributes" => %{
          "email" => "test2@example.com",
          "name" => "Tester"
        }
      }]
    }

    assert_raise ExUnit.AssertionError, "Expected schema did not contain type: user", fn ->
      Voorhees.JSONApi.assert_schema payload, %{post: %{attributes: [:title, :body]}}
    end

    payload = %{
      "data" => [%{
        "type" => "post",
        "id" => "1",
        "attributes" => %{
          "title" => "Awesome title",
          "body" => "Awesome Body"
        }
      }],
      "included" => [%{
        "type" => "user",
        "id" => "2",
        "attributes" => %{
          "email" => "test2@example.com",
          "name" => "Tester"
        }
      }]
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

    payload = %{
      "data" => [%{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      }]
    }

    assert_raise ExUnit.AssertionError, "Payload was missing attributes: title", fn ->
      Voorhees.JSONApi.assert_schema payload, %{user: %{attributes: [:email, :name, :title]}}
    end

    payload = %{
      "data" => [%{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "title" => "tester of tests",
          "name" => "Tester"
        }
      },%{
        "type" => "user",
        "id" => "2",
        "attributes" => %{
          "email" => "test2@example.com",
          "name" => "Tester"
        }
      }]
    }

    assert_raise ExUnit.AssertionError, "Payload was missing attributes: title", fn ->
      Voorhees.JSONApi.assert_schema payload, %{user: %{attributes: [:email, :name, :title]}}
    end

    payload = %{
      "data" => [%{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "title" => "tester of tests",
          "name" => "Tester"
        }
      }],
      "included" => [%{
        "type" => "user",
        "id" => "2",
        "attributes" => %{
          "email" => "test2@example.com",
          "name" => "Tester"
        }
      }]
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

    payload = %{
      "data" => [%{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      }]
    }

    assert_raise ExUnit.AssertionError, "Payload contained additional attributes: name", fn ->
      Voorhees.JSONApi.assert_schema payload, %{user: %{attributes: [:email]}}
    end

    payload = %{
      "data" => [%{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "name" => "Tester"
        }
      },%{
        "type" => "user",
        "id" => "2",
        "attributes" => %{
          "email" => "test2@example.com"
        }
      }]
    }

    assert_raise ExUnit.AssertionError, "Payload contained additional attributes: name", fn ->
      Voorhees.JSONApi.assert_schema payload, %{user: %{attributes: [:email]}}
    end

    payload = %{
      "data" => [%{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test2@example.com",
        }
      }],
      "included" => [%{
        "type" => "user",
        "id" => "2",
        "attributes" => %{
          "email" => "test2@example.com",
          "name" => "Tester"
        }
      }]
    }

    assert_raise ExUnit.AssertionError, "Payload contained additional attributes: name", fn ->
      Voorhees.JSONApi.assert_schema payload, %{user: %{attributes: [:email]}}
    end
  end

  test "does not throw error when the payloads match" do
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

  test "does not throw errors when list's ordering differs with the `ignore_list_order` flag" do
    payload = %{
      "data" => [%{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      },%{
        "type" => "user",
        "id" => "2",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      }],
      "included" => [%{
        "type" => "member",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      },%{
        "type" => "member",
        "id" => "2",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      }]
    }

    Voorhees.JSONApi.assert_payload(payload, %{
      data: [%{
        id: "2",
        type: "user",
        attributes: %{
          name: "Tester"
        }
      },%{
        id: "1",
        type: "user",
        attributes: %{
          name: "Tester"
        }
      }],
      included: [%{
        id: "2",
        type: "member",
        attributes: %{
          name: "Tester"
        }
      },%{
        id: "1",
        type: "member",
        attributes: %{
          name: "Tester"
        }
      }]
    }, ignore_list_order: true)
  end

  test "throws an error when the actual payload is missing attributes in data as a map" do
    payload = %{
      "data" => %{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "name" => "Tester"
        }
      }
    }

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "data" did not match expected
    Expected:
      %{"attributes" => %{email: "test@example.com", name: "Tester"}, "id" => "1", "type" => "user"}
    Actual (filtered):
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
    Actual (untouched):
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
    """, fn ->
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

  test "resulting payload types are all contained in the expected payload and returns response" do
    expected = %{
      user: %{
        attributes: [:email, :name]
      }
    }

    response = %{
      "data" => %{
        "id": "1",
        "type": "user",
        "attributes": %{
          "email" => "test@example.com",
          "name" => "Tester",
          "is-admin" => false
        }
      },
      "included" => [%{
        "type" => "post",
        "id" => "1",
        "attributes" => %{"body" => "test"}
      }]
    }

    assert response == Voorhees.JSONApi.assert_schema_contains(response, expected)
  end

  test "resulting payload types not contained in the expected payload" do
    expected = %{
      "other-user": %{
        attributes: [:email, :name]
      }
    }

    response = %{
      "data" => %{
        "id": "1",
        "type": "user",
        "attributes": %{
          "email" => "test@example.com",
          "name" => "Tester",
          "is-admin" => false
        }
      },
      "included" => [%{
        "type" => "post",
        "id" => "1",
        "attributes" => %{"body" => "test"}
      }]
    }

    assert_raise ExUnit.AssertionError, "Expected types: other-user\nGot: user, post", fn ->
      Voorhees.JSONApi.assert_schema_contains response, expected
    end
  end

  test "resulting payload attributes contained in the expected payload" do
    expected = %{
      "user": %{
        attributes: [:email, :name]
      }
    }

    response = %{
      "data" => %{
        "id": "1",
        "type": "user",
        "attributes": %{
          "email" => "test@example.com",
          "name" => "Tester",
          "is-admin" => false
        }
      },
      "included" => [%{
        "type" => "post",
        "id" => "1",
        "attributes" => %{"body" => "test"}
      }]
    }

    Voorhees.JSONApi.assert_schema_contains(response, expected)
  end

  test "resulting payload attributes not contained in the expected payload" do
    expected = %{
      "user": %{
        attributes: [:email, :name]
      }
    }

    response = %{
      "data" => %{
        "id": "1",
        "type": "user",
        "attributes": %{
          "email" => "test@example.com",
          "is-admin" => false
        }
      },
      "included" => [%{
        "type" => "post",
        "id" => "1",
        "attributes" => %{"body" => "test"}
      }]
    }

    assert_raise ExUnit.AssertionError, "Expected type: user to contain: email, name\nGot: email, is-admin", fn ->
      Voorhees.JSONApi.assert_schema_contains response, expected
    end
  end

  test "resulting payload data are all contained in the expected payload data and returns response" do
    expected = %{
      user: %{
        attributes: %{
          email: "test@example.com"
        }
      }
    }

    response = %{
      "data" => %{
        "id": "1",
        "type": "user",
        "attributes": %{
          "email" => "test@example.com",
          "name" => "Tester",
          "is-admin" => false
        }
      },
      "included" => [%{
        "type" => "post",
        "id" => "1",
        "attributes" => %{"body" => "test"}
      }]
    }

    assert response == Voorhees.JSONApi.assert_payload_contains(response, expected)
  end

  test "resulting payload data are not all contained in the expected payload" do
    expected = %{
      user: %{
        attributes: %{
          email: "test@example.com",
          name: "Other"
        }
      }
    }

    response = %{
      "data" => %{
        "id": "1",
        "type": "user",
        "attributes": %{
          "email" => "test@example.com",
          "name" => "Tester",
          "is-admin" => false
        }
      },
      "included" => [%{
        "type" => "post",
        "id" => "1",
        "attributes" => %{"body" => "test"}
      }]
    }

    assert_raise ExUnit.AssertionError, "Expected type: user to contain record with values: email: test@example.com, name: Other", fn ->
      Voorhees.JSONApi.assert_payload_contains response, expected
    end
  end

  test "throws an error when the actual payload is missing attributes in data as a list" do
    payload = %{
      "data" => [%{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "name" => "Tester"
        }
      }]
    }

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "data" did not match expected

    Resource at index 0 did not match
    Expected:
      %{"attributes" => %{email: "test@example.com", name: "Tester"}, "id" => "1", "type" => "user"}
    Actual (filtered):
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
    Actual (untouched):
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
    """, fn ->
      Voorhees.JSONApi.assert_payload payload, %{
        data: [%{
          id: "1",
          type: "user",
          attributes: %{
            email: "test@example.com",
            name: "Tester"
          }
        }]
      }
    end
  end

  test "throws an error when the actual payload has a different value for attributes in data as a map" do
    payload = %{
      "data" => %{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "name" => "Tester1"
        }
      }
    }

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "data" did not match expected
    Expected:
      %{"attributes" => %{name: "Tester"}, "id" => "1", "type" => "user"}
    Actual (filtered):
      %{"attributes" => %{"name" => "Tester1"}, "id" => "1", "type" => "user"}
    Actual (untouched):
      %{"attributes" => %{"name" => "Tester1"}, "id" => "1", "type" => "user"}
    """, fn ->
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
  end

  test "throws an error when the actual payload has a different value for attributes as a list" do
    payload = %{
      "data" => [%{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "name" => "Tester1"
        }
      }]
    }

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "data" did not match expected

    Resource at index 0 did not match
    Expected:
      %{"attributes" => %{name: "Tester"}, "id" => "1", "type" => "user"}
    Actual (filtered):
      %{"attributes" => %{"name" => "Tester1"}, "id" => "1", "type" => "user"}
    Actual (untouched):
      %{"attributes" => %{"name" => "Tester1"}, "id" => "1", "type" => "user"}
    """, fn ->
      Voorhees.JSONApi.assert_payload payload, %{
        data: [%{
          id: "1",
          type: "user",
          attributes: %{
            name: "Tester"
          }
        }]
      }
    end
  end

  test "throws an error when the actual payload has a differing list item as a list" do
    payload = %{
      "data" => [%{
        "id" => "1",
        "type" => "user",
        "attributes" => %{
          "name" => "Tester"
        }
        }, %{
        "type" => "user",
        "id" => "2",
        "attributes" => %{
          "name" => "Tester2"
        }
      }]
    }

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "data" did not match expected

    Resource at index 1 did not match
    Expected:
      %{"attributes" => %{name: "Tester3"}, "id" => "2", "type" => "user"}
    Actual (filtered):
      %{"attributes" => %{"name" => "Tester2"}, "id" => "2", "type" => "user"}
    Actual (untouched):
      %{"attributes" => %{"name" => "Tester2"}, "id" => "2", "type" => "user"}
    """, fn ->
      Voorhees.JSONApi.assert_payload payload, %{
        data: [%{
          id: "1",
          type: "user",
          attributes: %{
            name: "Tester"
          }
          }, %{
          id: "2",
          type: "user",
          attributes: %{
            name: "Tester3"
          }
        }]
      }
    end
  end
end
