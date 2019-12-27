-- Lua script of map lake.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local fish_spawner = require("scripts/fishing/fish_spawner")
local fish_slime = require("scripts/fishing/fish_types/fish_slime")
local fish_big = require("scripts/fishing/fish_types/fish_big")
local fish_pointy = require("scripts/fishing/fish_types/fish_pointy")

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  -- init fish spawner
  local max_fishes = 5
  local spawning_positions = {
    {128, 144, 0},
    {64, 168, 0},
    {120, 128, 0}
  }
  local spawning_delay_ms = 5000
  local fish_types = {
    {
      likelihood = 2,
      properties = fish_slime
    },
    {
      likelihood = 3,
      properties = fish_big
    },
    {
      likelihood = 2,
      properties = fish_pointy
    }
  }

  fish_spawner:init(self, spawning_positions, max_fishes, spawning_delay_ms, fish_types)
  fish_spawner:start_spawning()
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end
