# Fundamentals

## Pattern Matching

The left side of the `=` operator is a pattern. The right side is an expression that evaluates to an Elixir term.

```elixir
person = {"chris", 29}
{name, age } = person
# or
{name, age} = {"chris", 29}

{date, time} = :calendar.local_time()

# example of a 3 term tuple where the first term is an atom of :rectangle
rectangle = {:rectangle, 10, 20}
{:rectangle, width, height} = rectangle

{:square, width, height} = rectangle
# ** (MatchError) no match of right hand side value: {:rectangle, 10, 20}
```

It is a common idiom to see `{:ok, result}` or `{:error, result}`

```elixir
{:ok, contents} = File.read("example.txt")
# ** (MatchError) no match of right hand side value: {:error, :enoent}

{:error, reason} = File.read("example.txt")
# {:error, :enoent}
```

Usuing anonymous variables to pattern match and only get specific values

```elixir
{_, {hour, _, _}} = :calendar.local_time()
```

Using the pin operator to prevent a variable from being matched

```elixir
x = 10
{^x, _} = {10, "hello"}
{^x, _} = {11, "hello"}
# ** (MatchError) no match of right hand side value: {11, "hello"}
```

Matching lists

```elixir
[head | tail] = [1,2,3,4,5]
# iex(11)> head
# 1
# iex(12)> tail
# [2, 3, 4, 5]

[min | _] = Enum.sort([3,5,2,1])
# iex(14)> min
# 1
```

Matching maps

```elixir
# With maps you can use partial matches
%{age: age} = %{name: "chris", age: 29}
```

Chained matches

```elixir
a = (b = 1 + 6)
# iex(16)> a
# 7
# iex(17)> b
# 7

# a more useful example
date_time = {_, {hour, _, _}} = :calendar.local_time()
```

Function argument pattern matching

```elixir
defmodule Geometry do
  def area({:rectangle, a, b}) do
    a * b
  end

  def area({:square, a}) do
    a * a
  end

  def area({:circle, r}) do
    r * r * 3.14159
  end

  def area(unknown) do
    {:error, {:unknown_shape, unknown}}
  end
end

Geometry.area({:rectangle, 2, 5})
Geometry.area({:square, 2})
Geometry.area({:circle, 2})
```

## Guards and Conditional Macros

Guards are an extension of the basic pattern matching mechanism. They allow you to state an additional, broader expectation that must be satisfied.

```elixir
defmodule Sandbox do
  def test(x) when Kernel.is_number(x) < 0 do
    :negative
  end

  def test(0), do: :zero

  def test(x) when Kernel.is_number(x) > 0 do
    :positive
  end
end

# comparing types:
# number < atom < reference < fn < port < pid < tuple < map < list < bitstring

# using a lambda instead of overloading
test = fn
  x when Kernel.is_number(x) and x < 0 ->
    :negative

  0 -> :zero

  x when Kernel.is_number(x) and x > 0 ->
    :positive

end
```

`cond`

```elixir
def max(a, b) do
  cond do
    # if a is gt b, return a
    a >= b -> a
    # *else* return b
    true -> b
  end
end
```

`case`

```elixir
def max(a, b) do
  case a >= b do
    true -> a
    false -> b
    _ -> :error
  end
end
```

`with`

Can help with really gnar case statements

```elixir
defmodule Sandbox do
  def extract_user(user) do
    with {:ok, login} <- extract_login(user),
         {:ok, email} <- extract_email(user),
         {:ok, password} <- extract_password(user) do
      {:ok, %{login: login, email: email, password: password}}
    end
  end

  defp extract_login(%{"login" => login}), do: {:ok, login}
  defp extract_login(_), do: {:error, "login missing"}
  defp extract_email(%{"email" => email}), do: {:ok, email}
  defp extract_email(_), do: {:error, "email missing"}
  defp extract_password(%{"password" => password}), do: {:ok, password}
  defp extract_password(_), do: {:error, "password missing"}
end

r = %{"login" => "cmdallas", "email" => "wojak@cdalla.dev", "password" => "hugs"}
```

## Recursion, Tail Calls and Comprehensions

### How Elixir handles looping

Looping in Elixir is different than mainstream, imperative languages.

`while` and `for` loops arent really provided (at least in the same way).

Looping is done via recursion.

```elixir
defmodule Sandbox do
  # stops recursion
  def print(0), do: :ok

  def print(n) do
    print(n - 1)
    IO.puts(n)
  end

  # stops recursion
  def sum([]), do: 0

  def sum([h|t]) do
    h + sum(t)
  end
end
```

When we call to a function a stack push is performed. This consume some memory. When we have very deep recursion we can have stack overflows. This isnt neccessarily a problem because Elixir has tail call optimization. A tail call is when a function calls to another function as the last thing the function does. So in this case, calling the function *does not result in a stack push*. A go-to or jump statement essentially happens. Because of this we dont have to allocate additional stack space for calling to the function. This means the tail call function consumes *no additional memory*.


In this example, this function uses a tail call optimization because the last term in the function is to call `loop_forever`

```elixir
def  loop_forever do
  loop_forever()
end
```

### Builtins that use recursion

```elixir
Enum.each([1,2,3], fn x -> IO.puts(x) end)

Enum.map([1,2,3], fn x -> 2 * x end)

Enum.filter([1,2,3,4,5], fn x -> rem(x,2) == 1 end)

Enum.reduce([1,2,3,4,5], 0, fn x, y -> x + y end)
# x = 0, y = 1 => 1
# x = 1, y = 2 => 3
# x = 3, y = 3 => 6
# x = 6, y = 4 => 10
# x = 10, y = 5 => 15
```

### Comprehensions

```elixir
for x <- [1,2,3], do: x * x

# nested comprehension
# traditionally looks like: for (x) { for (y) {}}
for x <- [1,2,3], y <- [1,2,3], do: {x, y, x*y}

# putting values into a map using into
for x <- 1..9, y <- 1..9, into: %{}, do: {{x, y}, x*y}

# using a filter
for x <- 1..9, y <- 1..9, x < y, into: %{}, do: {{x, y}, x*y}
```

## Data Abstraction, Function Pipelines and Structs

Modules should be stateless.
The main data abstraction should be the first arg of the function.

```elixir
defmodule TaskList do
  def new(), do: %{}

  def add_task(task_list, entry) do
    MultiStorage.add(task_list, entry.date, entry)
  end

  def get_tasks(task_list, date) do
    MultiStorage.get(task_list, date)
  end
end

defmodule MultiStorage do
  def new(), do: %{}

  def add(storage, date, body) do
    Map.update(
      storage,
      date,
      [body],
      fn tasks -> [body|tasks] end
    )
  end

  def get(storage, key) do
    Map.get(storage, key [])
  end
end


entry = %{date: ~D[2020-12-10]}, task: "Buy Bitcoin"}
task_list = TaskList.new() |> TaskList.add_task(entry)
TaskList.get_tasks(entry.date)
```

You can only have 1 struct per module and it is bound to the module.

You cannot call Enum functions on a struct. You could, however do something like: `x |> Map.to_list()`

## Concurrency Primitives, Processes, and Message Passing

### Synchronous execution

```elixir
sync_fn = fn x ->
  Process.sleep(100)
  "#{x}"
end

Enum.map(1..5, &sync_fn.("#{&1}"))
```

### Concurrent execution

`Spawn` takes a 0 arity lambda. The provided lambda is executed in the new process and runs concurrent to any other processes running in the BEAM. That includes iex, which is inside of its own process.

```elixir
spawn(fn -> IO.puts(sync_fn.(1)) end)
```

We can take a sync function and wrap it in an async wrapper

```elixir
async_fn = fn x -> spawn(fn -> IO.puts(sync_fn.(x)) end) end

Enum.map(1..5, &async_fn.("#{&1}"))
```

### Passing data between processes

Each process contains a mailbox. The mailbox allows processes to accept messages. This is message passing.

The main construct to handle this is a macro called `receive`. The construct to send the message is a function called `send`. To send a message to a process we need to PID of the process.

```elixir
# Get the PID of the current process
self()

# Put a message in the iex terminal mailbox
send(self(), "message")

# Receive it. If there are no messages, receive will wait indefinitely and block the shell.
# The `after clause will make it so the thread of execution is not blocked
receive do
  msg -> IO.puts(msg)
  after 1000 -> IO.puts("no messages")
end

send(self(), {:msg, 10})
result = receive do
  {:msg, x} -> x * x
end
```

### Creating a stateful server process

```elixir
defmodule Calculator do
  def start do
    spawn(fn -> loop(0) end)
  end

  # interface for our process to be a ble to call the view message in our calculator process
  def view(server_pid) do
    send(server_pid, {:view, self()})

    receive do
      {:response, value} -> value
    end
  end

  def add(server_pid, value), do: send(server_pid, {:add, value})
  def sub(server_pid, value), do: send(server_pid, {:sub, value})
  def mult(server_pid, value), do: send(server_pid, {:mult, value})
  def div(server_pid, value), do: send(server_pid, {:div, value})

  defp loop(current_value) do
    new_value =
      receive do
        {:view, caller_pid} ->
          send(caller_pid, {:response, current_value})
          current_value

        {:add, value} -> current_value + value

        {:sub, value} -> current_value * value

        {:mult, value} -> current_value * value

        {:div, value} -> current_value / value

        _ -> IO.puts("invalid message")
    end
    loop(new_value)
  end
end

calc_pid = Calculator.start

Calculator.view(calc_pid)
Calculator.add(calc_pid, 5)
Calculator.view(calc_pid)

# Create a pool of calculator processes
# Each will have their own state
# Each process takes up about 2kb of memory
# They take up no CPU while waiting for messages
pool = Enum.map(1..100, fn _ -> Calculator.start end)
```

## Generic Server, OTP, Register Processes

### GenServer+OTP example from scratch

```elixir
defmodule GenericServer do
  # take in a module atom, which is the concrete impl or callback module
  def start(module) do
    spawn(fn ->
      init_state = module.init()
      loop(module, init_state)
    end)
  end

  defp loop(module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} =
          module.handle_call(request, current_state)

        send(caller, {:response, response})
        loop(module, new_state)

      {:cast, request} ->
        new_state =
          module.handle_cast(request, current_state)

        loop(module, new_state)
    end
  end

  def call(server_pid, request) do
    # This is what the call will actually look like:
    # send(server_pid, {:call, {:get_tasks, date}, self()})
    send(server_pid, {:call, request, self()})

    receive do
      {:response, response} -> response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end
end


defmodule TaskList do
  defstruct id: 0, entries: %{}
  
  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TaskList{},
      fn entry, acc -> add_task(acc, entry) end
    )
  end

  def add_task(task_list, entry) do
    entry = Map.put(entry, :id, task_list.id)

    new_entries =
      Map.put(
        task_list.entries,
        task_list.id,
        entry
      )

    %TaskList{
      task_list
      | entries: new_entries,
        id: task_list.id + 1
    }
  end

  def get_tasks(task_list, date) do
    task_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_task(task_list, %{} = new_entry) do
    update_task(task_list, new_entry.id, fn _ -> new_entry end)
  end

  def update_task(task_list, entry_id, update_fn) do
    case Map.fetch(task_list.entries, entry_id) do
      :error -> task_list

      {:ok, old_entry} ->
        new_entry = update_fn.(old_entry)

        new_entries =
          Map.put(
            task_list.entries,
            new_entry.id,
            new_entry
          )

        %TaskList{task_list | entries: new_entries}
    end
  end
end

defmodule TaskServer do
  # client side
  # defines callback functions used to interface with the server
  def start do
    GenericServer.start(TaskServer)
  end

  def add_task(server_pid, new_entry) do
    GenericServer.cast(server_pid, {:add_task, new_entry})
  end

  def get_tasks(server_pid, date) do
    GenericServer.call(server_pid, {:get_tasks, date})
  end

  # server side
  # set the initial state of the process.
  def init do
    TaskList.new()
  end

  def handle_call({:get_tasks, date}, task_list) do
    {TaskList.get_tasks(task_list, date), task_list}
  end

  def handle_cast({:add_task, new_entry}, task_list) do
    TaskList.add_task(task_list, new_entry)
  end
end

pid = TaskServer.start
entry = %{date: ~D[2019-01-02], title: "Buy Bitcoin"}
pid |> TaskServer.add_task(entry)
pid |> TaskServer.get_tasks(entry.date)
```

### Registering Processes

In the BEAM a process is identified with a corresponding PID. To make the process send messages to another process you have to bring the process id of the process to the other process. The PID is a reference or a pointer to a process.
When dealing with hundreds or thousands of processes, it can be a pain to pass these around in code.
We can register PIDs with atoms

```elixir
Process.register(pid, :task_server)
:task_server |> TaskServer.get_tasks(entry.date)
```

#### Rules of process registration

1. The name of the process can only be an :atom
2. A single process can only have 1 name
3. Two processes cannot have the same name

### Bottlenecking the BEAM

All process run in parrallel but call to a sync process.

```elixir
defmodule Server do
  def start do
    Process.register(GenericServer.start(Server), :server)
  end

  def init do
    []
  end

  def call_server(msg) do
    GenericServer.call(:server, {:request, "Message: #{msg}"})
  end

  def handle_call({:request, msg}, _state) do
    Process.sleep(1000)
    {msg, []}
  end
end

Server.start
Enum.each(1..10, fn x ->
    spawn(fn -> IO.puts("Sending msg #{x}")
    resp = Server.call_server(x)
    IO.puts("response: #{resp}")
  end)
end)
```

## GenServer, Links and Message Handling
