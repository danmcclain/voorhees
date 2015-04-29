defmodule Voorhees.Test.MatchesSchema do
  use ExUnit.Case
  import Voorhees

  test "desired keys can be either strings or atoms" do
    content = Poison.encode! %{ a: 1, b: 2 }
    assert matches_schema?(content, [:a, "b"])
  end

  test "returns false when a key is missing from the passed in value" do
    content = Poison.encode! %{ a: 1 }
    assert !matches_schema?(content, [:a, :b])
  end

  test "returns false when an extra key is present in the the passed in value" do
    content = Poison.encode! %{ a: 1, b: 2, c: 3 }
    assert !matches_schema?(content, [:a, :b])
  end

  test "checks nested keys" do
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
end
