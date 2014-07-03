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
end
