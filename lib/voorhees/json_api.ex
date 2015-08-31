defmodule Voorhees.JSONApi do
  import ExUnit.Assertions

  def assert_schema(%{"data" => list } = actual , expected) when is_list(list) do
    list
    |> Enum.map(&(_assert_resource(&1, expected)))

    if included = actual["included"] do
      included
      |> Enum.map(&(_assert_resource(&1, expected)))
    end

    actual
  end

  def assert_schema(%{"data" => resource } = actual , expected) when is_map(resource) do
    _assert_resource(resource, expected)

    actual
  end

  def assert_schema_contains(%{"data" => resource} = actual, expected) when is_map(resource) do
    assert_schema_contains(put_in(actual["data"], [resource]), expected)
  end
  def assert_schema_contains(%{"data" => resources} = actual, expected) when is_list(resources) do
    actual = Enum.map(resources ++ (actual["included"] || []), fn(resource) -> _stringify_keys(resource) end)
    _assert_schema_contains(actual, _stringify_keys(expected))
  end

  defp _assert_schema_contains(actual, expected) do
    actual_types = Enum.map(actual, fn(resource) -> resource["type"] end)
    expected_types = Map.keys(expected)

    assert length(expected_types -- actual_types) == 0,
      "Expected types: #{Enum.join(expected_types, ", ")}\nGot: #{Enum.join(actual_types, ", ")}"

    Enum.each expected_types, fn(expected_type) ->
      expected_attributes = _stringify_items(expected[expected_type]["attributes"])
      Enum.each(actual, fn(resource) ->
        if resource["type"] == expected_type do
          actual_attributes = Map.keys(resource["attributes"])
          assert length(expected_attributes -- actual_attributes) == 0,
            "Expected type: #{expected_type} to contain: #{Enum.join(expected_attributes, ", ")}\nGot: #{Enum.join(actual_attributes, ", ")}"
        end
      end)
    end
  end

  defp _assert_resource(resource, expected) do
    %{"type" => type, "attributes" => attributes} = resource

    expected
    |> Map.fetch(String.to_atom(type))
    |> case do
      :error ->
        assert false, "Expected schema did not contain type: #{type}"
      {:ok, expected_schema} ->
        %{attributes: expected_attributes} = expected_schema
        _assert_attributes(attributes, expected_attributes)
    end
  end

  defp _assert_attributes(attributes, expected_attributes) do
    attribute_names = attributes
    |> Map.keys
    |> Enum.map(&(String.to_atom(&1)))

    extra_attributes = attribute_names -- expected_attributes
    assert [] == extra_attributes, "Payload contained additional attributes: #{extra_attributes |> Enum.join(", ")}"

    missing_attributes = expected_attributes -- attribute_names
    assert [] == missing_attributes, "Payload was missing attributes: #{missing_attributes |> Enum.join(", ")}"
  end

  def assert_payload(actual, expected, options \\ []) do
    assert Voorhees.matches_payload?(actual, expected, options), "Payload did not match expected"

    actual
  end

  defp _stringify_items([]), do: []
  defp _stringify_items([head|tail]) when is_atom(head) do
    [Atom.to_string(head)|_stringify_items(tail)]
  end
  defp _stringify_items([head|tail]) when is_binary(head) do
    [head|_stringify_items(tail)]
  end

  defp _stringify_keys(object) when is_map(object) do
    Enum.into(object, %{}, &_stringify_key(&1))
  end
  defp _stringify_keys(object), do: object
  defp _stringify_key({key, value}) when is_binary(key),
    do: {key, _stringify_keys(value)}
  defp _stringify_key({key, value}) when is_atom(key),
    do: {Atom.to_string(key), _stringify_keys(value)}
end
