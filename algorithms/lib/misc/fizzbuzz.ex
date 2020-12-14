defmodule Misc do

  @doc """
    iex> Misc.fizzbuzz(1..15)
    [1, 2, "Fizz", 4, "Buzz", "Fizz", 7, 8, "Fizz", "Buzz", 11, "Fizz", 13, 14, "FizzBuzz"]
  """
  def fizzbuzz(range) do
    range |> Enum.map(fn
      num when rem(num, 15) == 0 -> "FizzBuzz"
      num when rem(num, 3) == 0 -> "Fizz"
      num when rem(num, 5) == 0 -> "Buzz"
      num -> num
    end)
  end

end
