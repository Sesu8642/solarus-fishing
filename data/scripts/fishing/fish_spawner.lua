local spawner = {}

function spawner:init(map, spawning_positions, max_fishes, spawning_delay_ms, fish_types)
  spawner.map = map
  spawner.max_fishes = max_fishes
  spawner.spawning_positions = spawning_positions
  spawner.spawning_delay_ms = spawning_delay_ms
  spawner.fish_types = fish_types
end

function spawner:start_spawning()
  math.randomseed(os.time())
  for i = 1,spawner.max_fishes,1 do 
    spawner:spawn_random_fish()
  end
end

function spawner:spawn_random_fish()
  -- select random position
  local position = spawner.spawning_positions[math.random(#spawner.spawning_positions)]
  -- select random fish type based on likelihood
  local likelihood_sum = 0
  for key, value in pairs(spawner.fish_types) do
    likelihood_sum = likelihood_sum + value.likelihood
  end
  local random_likelihood_index = math.random(likelihood_sum)
  local traversed_likelihood_index = 0
  local fish_type
  for key, value in pairs(spawner.fish_types) do
    traversed_likelihood_index = traversed_likelihood_index + value.likelihood
    if traversed_likelihood_index >= random_likelihood_index then
      fish_type = value
      break
    end
  end
  -- spawn fish
  local x, y, layer
  x = position[1]
  y = position[2]
  layer = position[3]
  local fish_obj = spawner.map:create_custom_entity({
    x = x,
    y = y,
    -- height and width are set by the fish once it is created
    height = 0,
    width = 0,
    direction = math.random(4),
    layer = layer,
    model = "fish",
    properties = fish_type.properties
  })
  fish_obj.vanished_callback = function()
    sol.timer.start(spawner.spawning_delay_ms, function()
      spawner:spawn_random_fish()
    end)
  end
end

return spawner