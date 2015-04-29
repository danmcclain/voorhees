defmodule Voorhees do
  require IEx
  def matches_schema?(content, keys) do
    content_map =  Poison.decode!(content)
    content_keys = content_map
    |> Map.keys
    |> _extract_subkeys(content_map)
    |> _normalize_keys

    keys = _normalize_keys(keys)

    Enum.empty?(keys -- content_keys) and Enum.empty?(content_keys -- keys)
  end

  defp _normalize_keys([]), do: []
  defp _normalize_keys([key|rest]) when is_atom(key), do: [key|_normalize_keys(rest)]
  defp _normalize_keys([key|rest]) when is_binary(key), do: [String.to_atom(key)|_normalize_keys(rest)]
  defp _normalize_keys([{key, subkeys}|rest]) when is_atom(key) and is_list(subkeys) do
    [{key, _normalize_keys(subkeys)}|_normalize_keys(rest)]
  end
  defp _normalize_keys([{key, subkeys}|rest]) when is_binary(key) and is_list(subkeys) do
    [{String.to_atom(key), _normalize_keys(subkeys)}|_normalize_keys(rest)]
  end

  defp _extract_subkeys([], _map), do: []
  defp _extract_subkeys([key|rest], map) do
    case map[key] do
      (value) when is_map(value) -> [{key, _extract_subkeys(Map.keys(value), value)}|_extract_subkeys(rest, map)]
      (_) -> [key|_extract_subkeys(rest, map)]
    end
  end
end
