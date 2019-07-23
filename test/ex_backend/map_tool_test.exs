defmodule ExBackend.MapToolTest do
  use ExUnit.Case

  test "get dict atom parameter value by atom" do
    atom_value = "atom_value"
    atom_dict = %{
      atom_key: atom_value
    }

    atom_value = ExBackend.Map.get_by_key_or_atom(atom_dict, :atom_key)
    assert atom_value =~ "atom_value"
  end

  test "get dict string parameter value by atom" do
    string_dict = %{
      "string_key" => "string_value"
    }

    string_value = ExBackend.Map.get_by_key_or_atom(string_dict, :string_key)
    assert string_value =~ "string_value"
  end

  test "replace dict atom parameter value" do
    atom_value = "atom_value"
    atom_dict = %{
      atom_key: atom_value
    }

    atom_dict = ExBackend.Map.replace_by_atom(atom_dict, :atom_key, "new_atom_value")
    assert atom_dict.atom_key =~ "new_atom_value"
  end

  test "replace dict string parameter value" do
    string_dict = %{
      "string_key" => "string_value"
    }

    string_dict = ExBackend.Map.replace_by_atom(string_dict, :string_key, "new_string_value")
    assert string_dict.string_key =~ "new_string_value"
  end

end
