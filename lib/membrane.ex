defmodule Membrane do
  defstruct [
    content: %{},
    reactions: %{},
    children: [],
    parent: nil,
    skin?: false
  ]

  def compounds, do: [:a, :b, :c, :d, :e]

  def init(), do: init(%{parent: self(), skin?: true})
  def init(state), do: spawn_link(fn -> Map.merge(%Membrane{}, state) end)

  defp membrane(state) do
    content = Reaction.run_reactions(state)
    receive do
      {:add, compounds} when is_map(compounds) ->
        membrane(%{state | content: Utils.merge_add(content, compounds)})

      {:division_notice, from, children} when is_list(children)->
        send from, {:kill, :noreply}
        membrane(%{state | children: List.delete(state.children, from) ++ children})

      {:kill, :noreply} ->
        true

      {:kill, from} ->
        send from, {:add, content}

      {:mutate, _from} ->
        # broadcast then mutate and restart
        Enum.map(state.children, fn child -> send child, {:mutate, self()} end)
        membrane(Map.merge(state, Mutation.mutate(state)))

      {:query, from} ->
        send from, {state}
        membrane(state)

      {:query_merge, from} ->
        # no restart
        send from {:reply_merge, state}

      {:reply_merge, merged_state} ->
        membrane(%{state |
                   children: state.children ++ merged_state.children,
                   content:  Utils.merge_add(state.content, merged_state.content)
                  })

      {:add_child, child} ->
        membrane(%{state | children: [child | state.children]})
    end
  end
end
