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

  def map({:ok, value}, f), do: f.(value)
end
