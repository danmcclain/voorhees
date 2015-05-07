defmodule Voorhees do
  @moduledoc """
  A library for validating JSON responses
  """

  @doc """
  Returns true if the payload matches the format of the expected keys matched in.

  ## Examples

  Validating simple objects

      iex> payload = ~S[{ "foo": 1, "bar": "baz" }]
      iex> Voorhees.matches_schema?(payload, [:foo, "bar"]) # Property names can be strings or atoms
      true

      # Extra keys
      iex> payload = ~S[{ "foo": 1, "bar": "baz", "boo": 3 }]
      iex> Voorhees.matches_schema?(payload, [:foo, "bar"])
      false

      # Missing keys
      iex> payload = ~S[{ "foo": 1 }]
      iex> Voorhees.matches_schema?(payload, [:foo, "bar"])
      false

  Validating lists of objects

      iex> payload = ~S/[{ "foo": 1, "bar": "baz" },{ "foo": 2, "bar": "baz" }]/
      iex> Voorhees.matches_schema?(payload, [:foo, "bar"])
      true


  Validating nested lists of objects

      iex> payload = ~S/{ "foo": 1, "bar": [{ "baz": 2 }]}/
      iex> Voorhees.matches_schema?(payload, [:foo, bar: [:baz]])
      true

  Validating that a property is a list of scalar values

      iex> payload = ~S/{ "foo": 1, "bar": ["baz", 2]}/
      iex> Voorhees.matches_schema?(payload, [:foo, bar: []])
      true

  """
  @spec matches_schema?(String.t, list) :: boolean
  def matches_schema?(payload, expected_keys) do
    expected_keys = _normalize_key_list(expected_keys)
    parsed_payload =  Poison.decode!(payload)

    _matches_schema?(parsed_payload, expected_keys)
  end

  @doc """
  Returns true if the payload matches the values from expected payload.
  Key/value pairs in the payload that are not in the expected payload are ignored.
  Key/value pairs in the expected payload that are not in the payload cause
  `matches_payload?` to return false

  ## Examples

  Expected payload keys can be either strings or atoms

      iex> payload = ~S[{ "foo": 1, "bar": "baz" }]
      iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => "baz" })
      true

  Extra key/value pairs in payload are ignored

      iex> payload = ~S[{ "foo": 1, "bar": "baz", "boo": 3 }]
      iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => "baz" })
      true

  Extra key/value pairs in expected payload cause the validation to fail

      iex> payload = ~S[{ "foo": 1, "bar": "baz"}]
      iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => "baz", :boo => 3 })
      false

  Validates scalar lists

      iex> payload = ~S/{ "foo": 1, "bar": ["baz"]}/
      iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => ["baz"] })
      true

      # Order is respected
      iex> payload = ~S/{ "foo": 1, "bar": [1, "baz"]}/
      iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => ["baz", 1] })
      false

  Validates lists of objects

      iex> payload = ~S/[{ "foo": 1, "bar": { "baz": 2 }}]/
      iex> Voorhees.matches_payload?(payload, [%{ :foo => 1, "bar" => %{ "baz" => 2 } }])
      true

  Validates nested objects

      iex> payload = ~S/{ "foo": 1, "bar": { "baz": 2 }}/
      iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => %{ "baz" => 2 } })
      true

  Validates nested lists of objects

      iex> payload = ~S/{ "foo": 1, "bar": [{ "baz": 2 }]}/
      iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => [%{ "baz" => 2 }] })
      true

  """
  @spec matches_payload?(String.t, list | map) :: boolean
  def matches_payload?(payload, expected_payload) do
    expected_payload = _normalize_map(expected_payload)
    parsed_payload =  Poison.decode!(payload)
    |> _filter_out_extra_keys(expected_payload)

    parsed_payload == expected_payload
  end

  defp _filter_out_extra_keys(payload, expected_payload) when is_list(payload) do
    payload
    |> Enum.with_index
    |> Enum.map(fn {value, index} -> _filter_out_extra_keys(value, Enum.at(expected_payload, index)) end)
  end

  defp _filter_out_extra_keys(payload, nil) when is_map(payload), do: payload

  defp _filter_out_extra_keys(payload, expected_payload) when is_map(payload) do
    payload
    |> Enum.filter(fn
      {key, _value} ->
        expected_payload
        |> Map.keys
        |> Enum.member?(key)
    end)
    |> Enum.map(fn
      {key, value} when is_map(value) or is_list(value) -> {key, _filter_out_extra_keys(value, expected_payload[key])}
      entry -> entry
    end)
    |> Enum.into(%{})
  end

  defp _filter_out_extra_keys(payload, _expected_payload), do: payload

  defp _normalize_map(map) when is_map(map) do
    map
    |> Enum.map(&(_normalize_map_entry(&1)))
    |> Enum.into(%{})
  end

  defp _normalize_map(list) when is_list(list), do: Enum.map(list, &(_normalize_map(&1)))
  defp _normalize_map(value), do: value

  defp _normalize_map_entry({key, value}) when is_map(value) or is_list(value), do: {_normalize_key(key), _normalize_map(value)}
  defp _normalize_map_entry({key, value}), do: {_normalize_key(key), value}

  defp _matches_schema?(payload, expected_keys) when is_list(payload) do
    payload
    |> Enum.map(fn (element) -> _matches_schema?(element, expected_keys) end)
    |> Enum.all?
  end

  defp _matches_schema?(payload, expected_keys) when is_map(payload) do
    content_keys = payload
    |> Map.keys
    |> _extract_subkeys(payload)
    |> _normalize_key_list

    extra_keys = content_keys -- expected_keys
    missing_keys = expected_keys -- content_keys

    Enum.empty?(extra_keys) and Enum.empty?(missing_keys)
  end


  defp _normalize_key_list([]), do: []
  defp _normalize_key_list([{key, subkeys}|rest]) when is_list(subkeys) do
    [{_normalize_key(key), Enum.sort(_normalize_key_list(subkeys))}|_normalize_key_list(rest)]
  end
  defp _normalize_key_list([key|rest]), do: [_normalize_key(key)|_normalize_key_list(rest)]

  defp _normalize_key(key) when is_atom(key), do: Atom.to_string(key)
  defp _normalize_key(key), do: key

  defp _extract_subkeys([], _map), do: []
  defp _extract_subkeys([key|rest], map) do
    case map[key] do
      (value) when is_map(value) -> [{key, _extract_subkeys(Map.keys(value), value)}|_extract_subkeys(rest, map)]
      (value) when is_list(value) ->
        subkey_arrays = value
        |> Enum.map(fn
          (element) when is_map(element) -> _extract_subkeys(Map.keys(element), element)
          (_) -> []
        end)
        |> Enum.uniq

        if Enum.count(subkey_arrays) == 1, do: [subkey_arrays] = subkey_arrays

        [{key, subkey_arrays}|_extract_subkeys(rest, map)]
      (_) -> [key|_extract_subkeys(rest, map)]
    end
  end
end
