defmodule Voorhees.Test.MatchesSchema do
  use ExUnit.Case
  import Voorhees

  test "desired keys can be either strings or atoms" do
    assert matches_schema?("{ \"a\": 1, \"b\": 2 }", [:a, "b"])
  end

  test "returns false when a key is missing from the passed in value" do
    assert !matches_schema?("{ \"a\": 1 }", [:a, :b])
  end

  test "returns false when an extra key is present in the the passed in value" do
    assert !matches_schema?("{ \"a\": 1, \"b\": 2, \"c\": 3 }", [:a, :b])
  end
end
