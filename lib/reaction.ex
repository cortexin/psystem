defmodule Reaction do
  defstruct [
    reagents: %{}, # compound => amount
    products: %{}  # mode => %{compound => amount}
  ]

  defp react(content, {reagents, products}, state) do
    case Validator.check_reagents(content, reagents) do
      {true, clean} ->
        ModeHandler.handle(products, clean, state)
        |> react({reagents, products}, state)

      _ -> content
    end
  end

  def run_reactions(state) do
    Enum.reduce(
      state.reactions,
      state.content,
      fn (r, c) -> react(c, r, state) end
    )
  end
end


defmodule ModeHandler do
  def handle({mode, products}, content, %Membrane{children: cs, parent: p}) do
    case mode do
      :here ->
        Utils.merge_add(content, products)

      :in when length(cs) ->
        send Enum.random(cs), {:add, products}
        content

      :out when is_pid(p) ->
        send p, {:add, products}
        content

      _ ->
        IO.inspect [mode, products, cs, p]
        raise "Illegal mode or state mismatch."
    end
  end
  def handle(products, content, state), do: Enum.reduce(
        products,
        content,
        fn (p, c) -> handle(p, c, state) end
      )

end
