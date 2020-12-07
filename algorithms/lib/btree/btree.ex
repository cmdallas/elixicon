defmodule BTree do

  defstruct [:value, :left, :right]

  @doc """
  invert: Inverts a binary tree

  ## Examples

    Given a tree with the structure:
         1
        / \
       2   3
            \
             4

    Return:
         1
        / \
       3   2
     /      
    4 

    iex> tree = %BTree{value: 1, left: %BTree{value: 2, left: nil, right: nil}, right: %BTree{value: 3, left: nil, right: %BTree{value: 4, left: nil, right: nil}}}
    iex> BTree.invert(tree)
    %BTree{
      left: %BTree{
        left: %BTree{left: nil, right: nil, value: 4},
        right: nil,
        value: 3
      },
      right: %BTree{left: nil, right: nil, value: 2},
      value: 1
    }
  """
  def invert(%BTree{left: left, right: right} = root) do
    %{root | left: BTree.invert(right), right: BTree.invert(left)}
  end

  def invert(nil), do: nil
end

