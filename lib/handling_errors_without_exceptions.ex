defmodule HandlingErrorsWithoutExceptions do
  # Constructors for optinal values
  #
  # I've choosen to use the Elixir idiom of using tupples starting
  # with :ok and :error to represent Some() and None here.
  #
  # Also, there is no real reason to use these constructures over
  # produces the tuples directly but the some / none vocabulary
  # gives consistency with the text.
  def some(value), do: {:ok, value}
  def none(), do: {:error}

  def map({:ok, value}, f), do: some(f.(value))
  def map({:error}, f), do: none()

  def flat_map({:error}, _f), do: none()
  def flat_map({:ok, value}, f), do: f.(value)

  def get_or_else({:error}, default), do: default
  def get_or_else({:ok, value}, _default), do: value

  # Is this the best solution?  I don't like that the map produces
  # {:ok, {:ok, value}} only to have the outer tuple stripped by get_or_else.
  def or_else(v, ob), do: get_or_else(map(v, fn (any) -> some(any) end), ob)
end
