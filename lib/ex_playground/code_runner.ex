defmodule ExPlayground.CodeRunner do
  use GenServer

  @docker_args [
    "run",
    "-i",
    "--rm",
    "-c", "2",
    "-m", "80m",
    "--memory-swap=-1",
    "--net=none",
    "--cap-drop=all",
    "--privileged=false",
    "stevedomin/ex_playground"
  ]

  # Client

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def run(pid, code) do
    GenServer.cast(__MODULE__, {:run, pid, code})
  end

  # Server (callbacks)

  def handle_cast({:run, pid, code}, _state) do
    opts = [
      in: code,
      out: {:send, pid},
      err: {:send, pid},
    ]
    Porcelain.spawn("/usr/local/bin/docker", @docker_args, opts)
    {:noreply, []}
  end
end
