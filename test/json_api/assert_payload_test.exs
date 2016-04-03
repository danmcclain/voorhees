defmodule Voorhees.Test.JSONApi.AssertPayloadTest do
  use ExUnit.Case

  test "does not throw error when the payloads match" do
    payload = %{
      "data" => %{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      },
      "included" => [%{
        "type" => "post",
        "id" => "1",
        "attributes" => %{
          "content" => "test content"
        }
      }],
      "meta" => %{
        "test" => "value"
      },
      "links" => %{
        "self" => "http://example.com/payload"
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
      },
      included: [%{
        id: "1",
        type: "post",
        attributes: %{
          content: "test content"
        }
      }],
      meta: %{
        test: "value"
      },
      links: %{
        self: "http://example.com/payload"
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
        },
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
      %{"attributes" => %{"email" => "test@example.com", "name" => "Tester"}, "id" => "1", "relationships" => %{"thing" => %{"data" => %{"id" => "1", "type" => "thing"}}}, "type" => "user"}
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
          },
          relationships: %{
            thing: %{data: %{id: "1", type: "thing"}}
          }
        }
      }
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
      %{"attributes" => %{"email" => "test@example.com", "name" => "Tester"}, "id" => "1", "type" => "user"}
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
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
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
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
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
      %{"attributes" => %{"name" => "Tester3"}, "id" => "2", "type" => "user"}
    Actual (filtered):
      %{"attributes" => %{"name" => "Tester2"}, "id" => "2", "type" => "user"}
    Actual (untouched):
      %{"attributes" => %{"name" => "Tester2"}, "id" => "2", "type" => "user"}
    """, fn ->
      Voorhees.JSONApi.assert_payload payload, %{
        data: [
          %{
            id: "1",
            type: "user",
            attributes:
              %{
                name: "Tester"
              }
          },%{
            id: "2",
            type: "user",
            attributes:
              %{
                name: "Tester3"
              }
          }
        ]
      }
    end
  end

  test "throw an error when the `ignore_list_order` flag is set, but is missing a resource in data" do
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

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "data" did not match expected
    Missing resources:
      %{"attributes" => %{"name" => "Tester"}, "id" => "2", "type" => "user"}
    """, fn ->
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
        }]
      }, ignore_list_order: true)
    end

    payload = %{
      "data" => []
    }

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "data" did not match expected
    Missing resources:
      %{"attributes" => %{"name" => "Tester"}, "id" => "2", "type" => "user"},
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
    """, fn ->
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
        }]
      }, ignore_list_order: true)
    end
  end

  test "throw an error when the `ignore_list_order` flag is set, but is an extra resource in data" do
    payload = %{
      "data" => [%{
        "type" => "user",
        "id" => "2",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
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

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "data" did not match expected
    Contained extra resources:
      %{"attributes" => %{"name" => "Tester"}, "id" => "2", "type" => "user"}
    """, fn ->
      Voorhees.JSONApi.assert_payload(payload, %{
        data: [%{
          id: "1",
          type: "user",
          attributes: %{
            name: "Tester"
          }
        }]
      }, ignore_list_order: true)
    end

    payload = %{
      "data" => [%{
        "type" => "user",
        "id" => "2",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
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

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "data" did not match expected
    Contained extra resources:
      %{"attributes" => %{"email" => "test@example.com", "name" => "Tester"}, "id" => "2", "type" => "user"},
      %{"attributes" => %{"email" => "test@example.com", "name" => "Tester"}, "id" => "1", "type" => "user"}
    """, fn ->
      Voorhees.JSONApi.assert_payload(payload, %{
        data: []
      }, ignore_list_order: true)
    end
  end

  test "throw an error when the `ignore_list_order` flag is set, but a resource is incorrect in data" do
    payload = %{
      "data" => [%{
        "type" => "user",
        "id" => "2",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester1"
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

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "data" did not match expected
    Contained extra resources:
      %{"attributes" => %{"name" => "Tester1"}, "id" => "2", "type" => "user"}
    Missing resources:
      %{"attributes" => %{"name" => "Tester"}, "id" => "2", "type" => "user"}
    """, fn ->
      Voorhees.JSONApi.assert_payload(payload, %{
        data: [%{
          id: "1",
          type: "user",
          attributes: %{
            name: "Tester"
          }
        },%{
          id: "2",
          type: "user",
          attributes: %{
            name: "Tester"
          }
        }]
      }, ignore_list_order: true)
    end
  end

  test "throw an error when resources are correct but out of order" do
    payload = %{
      "data" => [%{
        "type" => "user",
        "id" => "2",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
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

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "data" did not match expected

    Resource at index 0 did not match
    Expected:
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
    Actual (filtered):
      %{"attributes" => %{"name" => "Tester"}, "id" => "2", "type" => "user"}
    Actual (untouched):
      %{"attributes" => %{"email" => "test@example.com", "name" => "Tester"}, "id" => "2", "type" => "user"}

    Resource at index 1 did not match
    Expected:
      %{"attributes" => %{"name" => "Tester"}, "id" => "2", "type" => "user"}
    Actual (filtered):
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
    Actual (untouched):
      %{"attributes" => %{"email" => "test@example.com", "name" => "Tester"}, "id" => "1", "type" => "user"}
    """, fn ->
      Voorhees.JSONApi.assert_payload(payload, %{
        data: [%{
          id: "1",
          type: "user",
          attributes: %{
            name: "Tester"
          }
        },%{
          id: "2",
          type: "user",
          attributes: %{
            name: "Tester"
          }
        }]
      })
    end
  end

  test "throws an error when the actual payload is missing attributes in included as a list" do
    payload = %{
      "included" => [%{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "name" => "Tester"
        }
      }]
    }

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "included" did not match expected

    Resource at index 0 did not match
    Expected:
      %{"attributes" => %{"email" => "test@example.com", "name" => "Tester"}, "id" => "1", "type" => "user"}
    Actual (filtered):
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
    Actual (untouched):
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
    """, fn ->
      Voorhees.JSONApi.assert_payload payload, %{
        included: [%{
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

  test "throws an error when the actual payload included has a different value for attributes as a list" do
    payload = %{
      "included" => [%{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "name" => "Tester1"
        }
      }]
    }

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "included" did not match expected

    Resource at index 0 did not match
    Expected:
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
    Actual (filtered):
      %{"attributes" => %{"name" => "Tester1"}, "id" => "1", "type" => "user"}
    Actual (untouched):
      %{"attributes" => %{"name" => "Tester1"}, "id" => "1", "type" => "user"}
    """, fn ->
      Voorhees.JSONApi.assert_payload payload, %{
        included: [%{
          id: "1",
          type: "user",
          attributes: %{
            name: "Tester"
          }
        }]
      }
    end
  end

  test "throw an error when the `ignore_list_order` flag is not set, but is missing a resource in included" do
    payload = %{
      "included" => [%{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      }]
    }

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "included" did not match expected

    Resource at index 1 did not match
    Expected:
      %{"attributes" => %{"name" => "Tester"}, "id" => "2", "type" => "user"}
    Actual (filtered):
      nil
    Actual (untouched):
      nil
    """, fn ->
      Voorhees.JSONApi.assert_payload(payload, %{
        included: [%{
          id: "1",
          type: "user",
          attributes: %{
            name: "Tester"
          }
        },%{
          id: "2",
          type: "user",
          attributes: %{
            name: "Tester"
          }
        }]
      })
    end

    payload = %{
      "included" => []
    }

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "included" did not match expected

    Resource at index 0 did not match
    Expected:
      %{"attributes" => %{"name" => "Tester"}, "id" => "2", "type" => "user"}
    Actual (filtered):
      nil
    Actual (untouched):
      nil

    Resource at index 1 did not match
    Expected:
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
    Actual (filtered):
      nil
    Actual (untouched):
      nil
    """, fn ->
      Voorhees.JSONApi.assert_payload(payload, %{
        included: [%{
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
        }]
      })
    end
  end

  test "throws an error when the included payload has a resource that does not match the expected" do
    payload = %{
      "included" => [%{
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
        }
      ]
    }

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "included" did not match expected

    Resource at index 1 did not match
    Expected:
      %{"attributes" => %{"name" => "Tester3"}, "id" => "2", "type" => "user"}
    Actual (filtered):
      %{"attributes" => %{"name" => "Tester2"}, "id" => "2", "type" => "user"}
    Actual (untouched):
      %{"attributes" => %{"name" => "Tester2"}, "id" => "2", "type" => "user"}
    """, fn ->
      Voorhees.JSONApi.assert_payload payload, %{
        included: [
          %{
            id: "1",
            type: "user",
            attributes:
              %{
                name: "Tester"
              }
          },%{
            id: "2",
            type: "user",
            attributes:
              %{
                name: "Tester3"
              }
          }
        ]
      }
    end
  end

  test "throw an error when the `ignore_list_order` flag is set, but is missing a resource in included" do
    payload = %{
      "included" => [%{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      }]
    }

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "included" did not match expected
    Missing resources:
      %{"attributes" => %{"name" => "Tester"}, "id" => "2", "type" => "user"}
    """, fn ->
      Voorhees.JSONApi.assert_payload(payload, %{
        included: [%{
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
        }]
      }, ignore_list_order: true)
    end

    payload = %{
      "included" => []
    }

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "included" did not match expected
    Missing resources:
      %{"attributes" => %{"name" => "Tester"}, "id" => "2", "type" => "user"},
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
    """, fn ->
      Voorhees.JSONApi.assert_payload(payload, %{
        included: [%{
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
        }]
      }, ignore_list_order: true)
    end
  end

  test "throw an error when the `ignore_list_order` flag is set, but is an extra resource in included" do
    payload = %{
      "included" => [%{
        "type" => "user",
        "id" => "2",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
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

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "included" did not match expected
    Contained extra resources:
      %{"attributes" => %{"name" => "Tester"}, "id" => "2", "type" => "user"}
    """, fn ->
      Voorhees.JSONApi.assert_payload(payload, %{
        included: [%{
          id: "1",
          type: "user",
          attributes: %{
            name: "Tester"
          }
        }]
      }, ignore_list_order: true)
    end

    payload = %{
      "included" => [%{
        "type" => "user",
        "id" => "2",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
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

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "included" did not match expected
    Contained extra resources:
      %{"attributes" => %{"email" => "test@example.com", "name" => "Tester"}, "id" => "2", "type" => "user"},
      %{"attributes" => %{"email" => "test@example.com", "name" => "Tester"}, "id" => "1", "type" => "user"}
    """, fn ->
      Voorhees.JSONApi.assert_payload(payload, %{
        included: []
      }, ignore_list_order: true)
    end
  end

  test "throw an error when the `ignore_list_order` flag is set, but a resource is incorrect in included" do
    payload = %{
      "included" => [%{
        "type" => "user",
        "id" => "2",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester1"
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

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "included" did not match expected
    Contained extra resources:
      %{"attributes" => %{"name" => "Tester1"}, "id" => "2", "type" => "user"}
    Missing resources:
      %{"attributes" => %{"name" => "Tester"}, "id" => "2", "type" => "user"}
    """, fn ->
      Voorhees.JSONApi.assert_payload(payload, %{
        included: [%{
          id: "1",
          type: "user",
          attributes: %{
            name: "Tester"
          }
        },%{
          id: "2",
          type: "user",
          attributes: %{
            name: "Tester"
          }
        }]
      }, ignore_list_order: true)
    end
  end

  test "throw an error when resources are correct but out of order in included" do
    payload = %{
      "included" => [%{
        "type" => "user",
        "id" => "2",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
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

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "included" did not match expected

    Resource at index 0 did not match
    Expected:
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
    Actual (filtered):
      %{"attributes" => %{"name" => "Tester"}, "id" => "2", "type" => "user"}
    Actual (untouched):
      %{"attributes" => %{"email" => "test@example.com", "name" => "Tester"}, "id" => "2", "type" => "user"}

    Resource at index 1 did not match
    Expected:
      %{"attributes" => %{"name" => "Tester"}, "id" => "2", "type" => "user"}
    Actual (filtered):
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
    Actual (untouched):
      %{"attributes" => %{"email" => "test@example.com", "name" => "Tester"}, "id" => "1", "type" => "user"}
    """, fn ->
      Voorhees.JSONApi.assert_payload(payload, %{
        included: [%{
          id: "1",
          type: "user",
          attributes: %{
            name: "Tester"
          }
        },%{
          id: "2",
          type: "user",
          attributes: %{
            name: "Tester"
          }
        }]
      })
    end
  end

  test "should pass with equal payloads containing both data and included" do
    payload = %{
      "data" => %{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      },
      "included" => [%{
        "id" => "1",
        "type" => "user",
        "attributes" => %{
          "name" => "Tester1"
        }
      }]
    }

    Voorhees.JSONApi.assert_payload payload, %{
      "data" => %{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      },
      "included" => [%{
        id: "1",
        type: "user",
        attributes: %{
          name: "Tester1"
        }
      }]
    }
  end

  test "throw an error when payload does not contain data or included, but is expected" do
    payload = %{}

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "data" was expected, but was not present

    "included" was expected, but was not present
    """, fn ->
      Voorhees.JSONApi.assert_payload(payload, %{
      "data" => %{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "email" => "test@example.com",
          "name" => "Tester"
        }
      },
      "included" => [%{
          id: "1",
          type: "user",
          attributes: %{
            name: "Tester1"
          }
        }]
      })
    end
  end

  test "doesn't throw an error when payload contains data or included, but is not expected" do
    payload = %{
      "data" => %{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "name" => "Tester"
        }
      },
      "included" => [%{
        "id" => "1",
        "type" => "user",
        "attributes" => %{
          "name" => "Tester"
        }
      }]
    }

    Voorhees.JSONApi.assert_payload(payload, %{})
  end

  test "throws the right error message when all parts of the payload are incorrect" do
    payload = %{
      "data" => %{
        "type" => "user",
        "id" => "1",
        "attributes" => %{
          "name" => "Tester"
        }
      },
      "included" => [%{
        "id" => "1",
        "type" => "user",
        "attributes" => %{
          "name" => "Tester"
        }
      }],
      "meta" => %{
        "test" => "value"
      },
      "links" => %{
        "self" => "http://example.com/payload"
      }
    }

    assert_raise ExUnit.AssertionError, """
    Payload did not match expected

    "data" did not match expected
    Expected:
      %{"attributes" => %{"email" => "test@example.com", "name" => "Tester"}, "id" => "1", "type" => "user"}
    Actual (filtered):
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
    Actual (untouched):
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}

    "included" did not match expected

    Resource at index 0 did not match
    Expected:
      %{"attributes" => %{"name" => "Tester1"}, "id" => "1", "type" => "user"}
    Actual (filtered):
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}
    Actual (untouched):
      %{"attributes" => %{"name" => "Tester"}, "id" => "1", "type" => "user"}

    "meta" did not match expected
    Expected:
      %{"other" => "value"}
    Actual (filtered):
      %{}
    Actual (untouched):
      %{"test" => "value"}

    "links" did not match expected
    Expected:
      %{"self" => "http://google.com"}
    Actual (filtered):
      %{"self" => "http://example.com/payload"}
    Actual (untouched):
      %{"self" => "http://example.com/payload"}
    """, fn ->
      Voorhees.JSONApi.assert_payload(payload, %{
        "data" => %{
          "type" => "user",
          "id" => "1",
          "attributes" => %{
            "email" => "test@example.com",
            "name" => "Tester"
          }
        },
        "included" => [%{
            id: "1",
            type: "user",
            attributes: %{
              name: "Tester1"
            }
        }],
        meta: %{
          other: "value"
        },
        links: %{
          self: "http://google.com"
        }
      })
    end
  end
end
