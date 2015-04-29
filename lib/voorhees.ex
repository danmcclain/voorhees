defmodule Voorhees do
  def matches_schema?(content, keys) do
    content_keys = Poison.decode!(content)
    |> Map.keys
    |> _normalize_keys

    keys = _normalize_keys(keys)

    Enum.empty?(keys -- content_keys) and Enum.empty?(content_keys -- keys)
  end

  defp _normalize_keys([]), do: []
  defp _normalize_keys([key|rest]) when is_atom(key), do: [key|_normalize_keys(rest)]
  defp _normalize_keys([key|rest]) when is_binary(key), do: [String.to_atom(key)|_normalize_keys(rest)]
end
