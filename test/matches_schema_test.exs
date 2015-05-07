defmodule Voorhees.Test.MatchesSchema do
  use ExUnit.Case
  import Voorhees

  test "desired keys can be either strings or atoms" do
    content = Poison.encode! %{ a: 1, b: 2 }
    assert matches_schema?(content, [:a, "b"])
  end

  test "order of keys does not matter" do
    content = Poison.encode! %{ b: 1, a: 2 }
    assert matches_schema?(content, [:a, :b])

    content = Poison.encode! %{ user: %{ id: 1, username: 2 } }
    assert matches_schema?(content, [user: [:username, :id]])

    content = Poison.encode! %{ user: [%{ id: 1, username: 2 }, %{ username: 1, id: 2 }] }
    assert matches_schema?(content, [user: [:username, :id]])
    assert matches_schema?(content, [user: [:id, :username]])

    content = Poison.encode! %{ user: [%{ id: 1, username: %{ test: 2, bob: 3 } }, %{ username: %{ bob: 3, test: 5 }, id: 2 }] }
    assert matches_schema?(content, [user: [:id, username: [:test, :bob]]])
    assert matches_schema?(content, [user: [:id, username: [:bob, :test]]])
  end

  test "empty lists in expected keys should be lists of scalars in content" do
    content = Poison.encode! %{ a: 1, b: 2, c: [1, 2, 3, nil, "test"] }
    assert matches_schema?(content, [:a, "b", c: []])

    content = Poison.encode! %{ a: 1, b: 2, c: [1, %{ b: 1 }, 3] }
    assert !matches_schema?(content, [:a, "b", c: []])
  end

  test "returns false when a key is missing from the passed in value" do
    content = Poison.encode! %{ a: 1 }
    assert !matches_schema?(content, [:a, :b])
  end

  test "returns false when an extra key is present in the the passed in value" do
    content = Poison.encode! %{ a: 1, b: 2, c: 3 }
    assert !matches_schema?(content, [:a, :b])
  end

  test "checks nested object" do
    content = Poison.encode! %{ a: 1, b: 2, c: %{ d: 4 } }
    assert matches_schema?(content, [:a, :b, c: [:d]])

    content = Poison.encode! %{ a: 1, b: 2, c: %{ d: 4, e: %{ f: 5 } } }
    assert matches_schema?(content, [:a, :b, c: [:d, e: [:f]]])

    content = Poison.encode! %{ a: 1, b: 2, c: %{ d: 4, e: 6 } }
    assert !matches_schema?(content, [:a, :b, c: [:d, e: [:f]]])

    content = Poison.encode! %{ a: 1, b: 2, c: %{ d: 4, e: 6, f: 7 } }
    assert !matches_schema?(content, [:a, :b, c: [:d, e: [:f]]])

    content = Poison.encode! %{ a: 1, b: 2, c: %{ d: 4, e: %{ f: 7, g: 8 } } }
    assert !matches_schema?(content, [:a, :b, c: [:d, e: [:f]]])
  end

  test "checks lists" do
    content = Poison.encode! [%{ a: 1, b: 2, c: %{ d: 4 } }]
    assert matches_schema?(content, [:a, :b, c: [:d]])

    content = Poison.encode! [%{ a: 1, b: 2, c: 3 }]
    assert !matches_schema?(content, [:a, :b, c: [:d]])
  end

  test "check nested lists" do
    content = Poison.encode! %{ a: 1, b: 2, c: [%{ d: 4 }, %{ d: 5 }] }
    assert matches_schema?(content, [:a, :b, c: [:d]])

    content = Poison.encode! %{ a: [%{ d: 4 }, %{ d: 5 }] }
    assert matches_schema?(content, [a: [:d]])

    content = Poison.encode! [%{ a: 1, b: 2, c: [%{ d: 4 }] }]
    assert matches_schema?(content, [:a, :b, c: [:d]])

    content = Poison.encode! [%{ a: 1, b: 2, c: [%{ d: 4, e: 5 }] }]
    assert !matches_schema?(content, [:a, :b, c: [:d]])

    content = Poison.encode! [%{ a: 1, b: 2, c: [%{ d: 4 }, %{ d: 4, e: 5 }] }]
    assert !matches_schema?(content, [:a, :b, c: [:d]])
  end
end
