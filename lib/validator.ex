defmodule Validator do
  def check_reagents(content, reagents) do
    if Enum.all?(reagents, fn {k,v} -> Map.get(content, k, 0) >= v end) do
      {true, drop_reagents(content, reagents)}
    else
      content
    end
  end

  defp drop_reagents(content, reagents), do: Enum.reduce(
        reagents, content,
        fn ({name, amount}, content) ->
          Map.update!(content, name, &(&1 - amount)) end
      )

  def check_downward([], reactions) do
    {downward, rest} = Map.pop(reactions, [:in])
    Utils.merge_add(rest, %{here: downward})
  end
  def check_downward(_, reactions), do: reactions
end
