defmodule Membrane do
  defstruct [
    content: %{},
    reactions: %{},
    children: [],
    parent: nil,
    skin?: false
  ]

  def compounds, do: [:a, :b, :c, :d, :e]

  def init(), do: spawn_link(fn -> membrane(%Membrane{parent: self(), skin?: true}) end)

  defp membrane(state) do
    content = Reaction.run_reactions(state)
    receive do
      {:add, compounds} when is_map(compounds) ->
        membrane(%{state | content: Utils.merge_add(content, compounds)})

      {:kill, from} ->
        send from, {:add, content}

      {:mutate, _from} ->
        # broadcast then mutate and restart
        Enum.map(state.children, fn child -> send child, {:mutate, self()} end)
        membrane(Map.merge(state, Mutation.mutate(state)))

      {:query, from} ->
        send from, {state}
        membrane(state)
    end
  end

end
