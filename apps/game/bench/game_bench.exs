defmodule GameBench do
  use Benchfella

  bench "tick 10x10", [state: gen_state(10)] do
    Game.tick(state)
  end

  bench "tick 30x30", [state: gen_state(30)] do
    Game.tick(state)
  end

  bench "tick 50x50", [state: gen_state(50)] do
    Game.tick(state)
  end

  bench "tick 100x100", [state: gen_state(100)] do
    Game.tick(state)
  end

  defp gen_state(size) do
    GameUtils.random_state(size)
  end
end
