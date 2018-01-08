defmodule Utils do
  def merge_add(map1, map2) do
    Map.merge(map1, map2, fn (_k, v1, v2) -> v1 + v2 end)
  end

  @doc"""
  Get the maximum length of the chain of children
  allowed at the `current` level
  """
  def remaining_depth(current) do
    Application.get_env(:psystem, :max_depth) - current
  end
end
