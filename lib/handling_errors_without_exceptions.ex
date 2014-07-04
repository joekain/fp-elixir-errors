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

  # Exercise 1: map, flat_map, get_or_else, or_else, filter
  def map({:ok, value}, f), do: some(f.(value))
  def map({:error}, _f), do: none()

  def flat_map({:error}, _f), do: none()
  def flat_map({:ok, value}, f), do: f.(value)

  def get_or_else({:error}, default), do: default
  def get_or_else({:ok, value}, _default), do: value

  # Is this the best solution?  I don't like that the map produces
  # {:ok, {:ok, value}} only to have the outer tuple stripped by get_or_else.
  def or_else(v, ob), do: map(v, fn (any) -> some(any) end) |> get_or_else(ob)

  # This was my original solution
  # def filter(v, f) do
  #   if map(v, f) |> get_or_else(false), do: v, else: none
  # end
  #
  # Based on the solutions from the text I can move the evaluation into
  # the flat_map to avoid calling get_or_else.
  def filter(v, f) do
    flat_map(v, fn (x) -> if f.(x), do: some(x), else: none end)
  end


  # Exercise 2

  # Adapted from the example in the text
  def mean([]), do: none
  def mean(xs), do: some(Enum.sum(xs) / Enum.count(xs))

  def variance(xs) do
    mean(xs)
      |> map(fn (m) -> Enum.map(xs, &(:math.pow(&1 - m, 2))) end)
      |> flat_map(fn (seq) -> mean(seq) end)
  end


  # Exercise 3

  # My first attempt, using pattern matching
  # def map2({:error}, _b, _f), do: none
  # def map2(_a, {:error}, _f), do: none
  # def map2({:ok, a}, {:ok, b}, f), do: some(f.(a, b))

  # Adapted from the book's solution
  def map2(a, b, f), do: flat_map(a,
    fn (aa) ->
      map(b, fn (bb) -> f.(aa, bb) end)
    end
  )

  # Exercise 4
  # My first attempt used pattern matching but I wanted to rewrite using fold.
  # The text does not reuse map2 but instead seems to reimplement it.
  #
  # def sequence([]), do: some([])
  # def sequence([h | t]), do: map2(h, sequence(t), fn (a, b) -> [a | b] end)

  # A second implementation using List.foldr/3, this does the same thing
  def sequence(l), do: List.foldr(l, some([]), fn (x, acc) ->
      map2(x, acc, fn (h, t) -> [h | t] end)
    end
  )


  # Exercise 5

  # This is my adaptation of the initial implementation described by the text.
  # I used this version to verify my tests were correct.  This implementation
  # is inefficient so the exercise is to implement a more efficient, single pass
  # version.
  #
  # def traverse(l, f), do: Enum.map(l, f) |> sequence

  # Perform one fold over the list.  This is basically the same code as
  # sequence from Exercise 4 with the addition that I apply the function
  # f to x instead of just using x.
  def traverse(l, f), do: List.foldr(l, some([]), fn (x, acc) ->
      map2(f.(x), acc, fn (h, t) -> [h | t] end)
    end
  )

  def sequence_via_traverse(l), do: traverse(l, fn (x) -> x end)


  defmodule Either do
    def some(value), do: {:ok, value}
    def none(reason), do: {:error, reason}

    # Exercise 6
    def map({:ok, value}, f), do: some(f.(value))
    def map({:error, reason}, _f), do: none(reason)

    def flat_map({:error, reason}, _f), do: none(reason)
    def flat_map({:ok, value}, f), do: f.(value)

    def get_or_else({:error, _reason}, default), do: default
    def get_or_else({:ok, value}, _default), do: value

    # Is this the best solution?  I don't like that the map produces
    # {:ok, {:ok, value}} only to have the outer tuple stripped by get_or_else.
    def or_else(v, ob), do: map(v, fn (any) -> some(any) end) |> get_or_else(ob)

    def map2(a, b, f), do: flat_map(a,
      fn (aa) ->
        map(b, fn (bb) -> f.(aa, bb) end)
      end
    )
  end
end
