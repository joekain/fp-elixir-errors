defmodule HandlingErrorsWithoutExceptionsTest do
  use ExUnit.Case

  alias HandlingErrorsWithoutExceptions, as: Sut

  test "map ok value" do
    assert Sut.map(Sut.some(2), &(&1 + 2)) == 4
  end
end
