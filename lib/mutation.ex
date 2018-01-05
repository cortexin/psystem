defmodule Mutation do
  def mutate(state=%Membrane{children: cs}) do
    case Enum.random(1..10) do
      x when x > 1 -> mutate_reaction(state)
      x when x > 5 -> spawn_child(state)
      x when x > 6 and length(cs) -> dissolve_child(state)
      _ -> %{}
    end
  end

  #### CHILD MUTATIONS
  defp spawn_child(state) do
    IO.puts("Spawning a child")
    child = spawn_link(fn -> %Membrane{parent: self} end)
    %{children: [child | state.children]}
  end

  defp dissolve_child(%{reactions: reactions, children: children}) do
    IO.puts("Dissolving a child")
    child = Enum.random(children)
    send child, {:kill, self}

    %{children: List.delete(children, child) |> Validator.check_downward(reactions)}
  end

  #### REACTION MUTATIONS
  defp mutate_reaction(state) do

    d = %{reactions: Enum.random([&add_reaction/1, &add_reaction/1, &drop_reaction/1]) |> apply([state])}
    IO.inspect d
    d
  end

  defp add_reaction(state) do
    IO.puts("Adding a reaction")
    reagents = generate_compounds
    products = generate_compounds

    unless balance_valid?(reagents, products) do
      add_reaction(state)
    else
      Map.put(
        state.reactions,
        reagents,
        possible_modes(state) |> split_into_modes(products)
      )
    end
  end

  defp drop_reaction(%{}), do: %{}
  defp drop_reaction(%{reactions: reactions}) do
    IO.puts("Dropping a reaction")
    Map.delete(
        reactions,
        Map.keys(reactions) |> Enum.random
    )
  end

  defp generate_compounds(n \\ 3) do
    for molecule <- Enum.take_random(
          Membrane.compounds,
          Enum.random(1..n)), into: %{} do
        {molecule, Enum.random(1..n)}
    end
  end

  defp split_into_modes(modes, products) do
    with_modes = for m <- modes, into: %{} do
      {m, %{}}
    end
    IO.inspect ["MODES ", with_modes]
    Enum.reduce(products, with_modes,
      fn ({name, amount}, acc) -> Map.update!(acc, Enum.random(modes), &(Map.put(&1, name, amount))) end
    )
  end

  defp possible_modes(%{children: cs}) do
    case cs do
      [] -> [:here, :out]
      _  -> [:here, :in, :out]
    end
  end

  @doc"""
  Validate that the reaction does not break the
  law of energy conservation. Of course this is an
  oversimplification and many other reaction types
  are theoretically possible. But they are rather hard
  to validate, so we'll disallow them altogether for now.
  """
  def balance_valid?(reagents, products) do
    rset = MapSet.new(Map.keys(reagents))
    pset = MapSet.new(Map.keys(products))

    has_difference(rset, pset) and has_difference(pset, rset)
  end

  defp has_difference(r, p), do: MapSet.size(MapSet.difference(r, p)) > 0

end
