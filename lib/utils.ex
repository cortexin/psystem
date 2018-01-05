defmodule Utils do
  def merge_add(map1, map2) do
    Map.merge(map1, map2, fn (_k, v1, v2) -> v1 + v2 end)
  end
end
