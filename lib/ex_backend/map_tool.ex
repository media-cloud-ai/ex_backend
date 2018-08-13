defmodule ExBackend.Map do
  def get_by_key_or_atom(dict, atom, default \\ nil) do
    Map.get_lazy(dict, atom, fn -> Map.get(dict, Atom.to_string(atom), default) end)
  end
end