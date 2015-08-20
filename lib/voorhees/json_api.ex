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
end
