defmodule HandlingErrorsWithoutExceptionsTest do
  use ExUnit.Case

  alias HandlingErrorsWithoutExceptions, as: Sut

  test "map ok value" do
    assert Sut.map(Sut.some(2), &(&1 + 2)) == Sut.some(4)
  end

  test "map error value" do
    assert Sut.map(Sut.none, &(&1 + 2)) == Sut.none
  end

  test "flat_map ok value" do
    assert Sut.flat_map(Sut.some(2), &(Sut.some(&1 + 2))) == Sut.some(4)
  end

  test "flat_map on error value" do
    assert Sut.flat_map(Sut.none, &(Sut.some(&1 + 2))) == Sut.none
  end

  test "flat_map with failing function" do
    failing_function = fn
      (true)  -> Sut.some(1)
      (false) -> Sut.none
    end
    assert Sut.flat_map(Sut.some(false), failing_function) == Sut.none
  end

  test "get_or_else with ok value" do
    assert Sut.get_or_else(Sut.some(2), 3) == 2
  end

  test "get_or_else with error value" do
    assert Sut.get_or_else(Sut.none, 3) == 3
  end

  test "or_else with ok value" do
    assert Sut.or_else(Sut.some(2), Sut.some(3)) == Sut.some(2)
  end

  test "or_else with error value" do
    assert Sut.or_else(Sut.none, Sut.some(3)) == Sut.some(3)
  end

  test "filter with ok value matching filter" do
    assert Sut.filter(Sut.some(3), fn
        (3) -> true
        (_) -> false
      end
    ) == Sut.some(3)
  end

  test "filter with ok value not matching filter" do
    assert Sut.filter(Sut.some(2), fn
        (3) -> true
        (_) -> false
      end
    ) == Sut.none
  end

  test "filter with error value" do
    assert Sut.filter(Sut.none, fn
        (3) -> true
        (_) -> false
      end
    ) == Sut.none
  end

  test "variance of an empty sequence" do
    assert Sut.variance([]) == Sut.none
  end

  test "variance of a non-empty sequence" do
    assert Sut.variance([1, 2, 3]) == Sut.some(2.0 / 3.0)
  end

  test "map2 with two ok values" do
    assert Sut.map2( Sut.some(2), Sut.some(3), &(&1 + &2)) == Sut.some(5)
  end

  test "map2 with ok and error values" do
    assert Sut.map2( Sut.some(2), Sut.none, &(&1 + &2)) == Sut.none
  end

  test "map2 with error and ok values" do
    assert Sut.map2( Sut.none, Sut.some(3), &(&1 + &2)) == Sut.none
  end

  test "sequence of list of ok values" do
    list = [Sut.some(1), Sut.some(2), Sut.some(3)]
    assert Sut.sequence(list) == Sut.some([1,2,3])
  end

  test "sequence of list with one error value" do
    list = [Sut.some(1), Sut.none, Sut.some(3)]
    assert Sut.sequence(list) == Sut.none
  end

  test "sequence of empty list" do
    assert Sut.sequence([]) == Sut.some([])
  end

  def parse_int(s) do
    try do
      {:ok, String.to_integer(s)}
    catch
      :error, :badarg -> :error
    end
  end

  test "traverse list of values that will succeed" do
    list = ["1", "2", "3"]
    assert Sut.traverse(list, &(parse_int(&1))) == Sut.some([1, 2, 3])
  end

  test "traverse list containing one value that will fail" do
    list = ["1", "a", "3"]
    assert Sut.traverse(list, &(parse_int(&1))) == Sut.none
  end

  test "traverse empty list" do
    assert Sut.traverse([], &(parse_int(&1))) == Sut.some([])
  end

  test "sequence via traverse of list of ok values" do
    list = [Sut.some(1), Sut.some(2), Sut.some(3)]
    assert Sut.sequence_via_traverse(list) == Sut.some([1,2,3])
  end

  test "sequence via traverse of list with one error value" do
    list = [Sut.some(1), Sut.none, Sut.some(3)]
    assert Sut.sequence_via_traverse(list) == Sut.none
  end

  test "sequence via traverse of empty list" do
    assert Sut.sequence_via_traverse([]) == Sut.some([])
  end


  alias HandlingErrorsWithoutExceptions.Either, as: Sut


  test "Either: map ok value" do
    assert Sut.map(Sut.some(2), &(&1 + 2)) == Sut.some(4)
  end

  test "Either: map error value" do
    assert Sut.map(Sut.none("Some reason"), &(&1 + 2)) == Sut.none("Some reason")
  end

  test "Either: flat_map ok value" do
    assert Sut.flat_map(Sut.some(2), &(Sut.some(&1 + 2))) == Sut.some(4)
  end

  test "Either: flat_map on error value" do
    assert Sut.flat_map(Sut.none("Some reason"), &(Sut.some(&1 + 2))) == Sut.none("Some reason")
  end

  test "Either: flat_map with failing function" do
    failing_function = fn
      (true)  -> Sut.some(1)
      (false) -> Sut.none("Some reason")
    end
    assert Sut.flat_map(Sut.some(false), failing_function) == Sut.none("Some reason")
  end

  test "Either: or_else with ok value" do
    assert Sut.or_else(Sut.some(2), Sut.some(3)) == Sut.some(2)
  end

  test "Either: or_else with error value" do
    assert Sut.or_else(Sut.none("Some reason"), Sut.some(3)) == Sut.some(3)
  end

  test "Either: map2 with two ok values" do
    assert Sut.map2(Sut.some(2), Sut.some(3), &(&1 + &2)) == Sut.some(5)
  end

  test "Either: map2 with ok and error values" do
    assert Sut.map2(Sut.some(2), Sut.none("A reason"), &(&1 + &2)) == Sut.none("A reason")
  end

  test "Either: map2 with error and ok values" do
    assert Sut.map2(Sut.none("A reason"), Sut.some(3), &(&1 + &2)) == Sut.none("A reason")
  end

  test "Either: map2 with two errors" do
    assert Sut.map2(Sut.none("Reason 1"), Sut.none("Reason 2"), &(&1 + &2)) == Sut.none("Reason 1")
  end

  def parse_int_with_reason(s) do
    try do
      {:ok, String.to_integer(s)}
    catch
      :error, :badarg -> {:error, "#{s} is not an integer"}
    end
  end

  test "Either: traverse list of values that will succeed" do
    list = ["1", "2", "3"]
    assert Sut.traverse(list, &(parse_int_with_reason(&1))) == Sut.some([1, 2, 3])
  end

  test "Either: traverse list containing one value that will fail" do
    list = ["1", "a", "3"]
    assert Sut.traverse(list, &(parse_int_with_reason(&1))) == Sut.none("a is not an integer")
  end

  test "Either: traverse empty list" do
    assert Sut.traverse([], &(parse_int_with_reason(&1))) == Sut.some([])
  end

  test "Either: sequence via traverse of list of ok values" do
    list = [Sut.some(1), Sut.some(2), Sut.some(3)]
    assert Sut.sequence(list) == Sut.some([1,2,3])
  end

  test "Either: sequence via traverse of list with one error value" do
    list = [Sut.some(1), Sut.none("A reason"), Sut.some(3)]
    assert Sut.sequence(list) == Sut.none("A reason")
  end

  test "Either: sequence via traverse of empty list" do
    assert Sut.sequence([]) == Sut.some([])
  end
end
