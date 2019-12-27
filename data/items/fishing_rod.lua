-- Lua script of item fishing_rod.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

active_fishing_tackle = nil

local hero_fishing_state
local ignore_next_fishing_attempt = false

local item = ...
local game = item:get_game()

local currently_fishing = false -- to prevent the fishing rod from being used again when the player wants to stop fishing by using it again

-- Event called when the game is initialized.
function item:on_started()
  self:set_assignable(true)
  self:set_savegame_variable("possession_fishing_rod")
  hero_fishing_state = sol.state.create("fishing")
  hero_fishing_state:set_can_control_movement(false)
  hero_fishing_state:set_can_control_direction(false)
  hero_fishing_state:set_can_use_sword(false)
  hero_fishing_state:set_can_use_shield(false)
  hero_fishing_state:set_can_interact(false)
  hero_fishing_state:set_can_use_item(false)
  hero_fishing_state:set_can_use_item("fishing_rod", true)
  function hero_fishing_state:on_finished(next_state_name, next_state)
    if next_state_name == "using item" then
      currently_fishing = true
    end
    item:stop_fishing()
  end
end

-- Event called when the hero is using this item.
function item:on_using()
  if currently_fishing then
    currently_fishing = false
  else
    item:start_fishing()
  end
  self:set_finished()
end

function item:start_fishing()
  local hero = self:get_map():get_entity("hero")
  local x, y, layer = hero:get_position()
  local direction = hero:get_direction()
  local distance = 48
  if direction == 0 then
    x = x + distance
  elseif direction == 1 then
    y = y - distance
  elseif direction == 2 then
    x = x - distance
  elseif direction == 3 then
    y = y + distance
  end
  if self:get_map():get_ground(x, y, layer) == "deep_water" then
    self:place_tackle(layer, x, y)
    hero:start_state(hero_fishing_state)
    hero:set_animation("fishing")
  end
end

function item:stop_fishing()
  local fish = active_fishing_tackle.fish_on_hook
  if fish then
    local hero = fish:get_map():get_hero()
    sol.audio.play_sound("throw")
    local map = active_fishing_tackle.fish_on_hook:get_map()
    local x, y = fish:get_position()
    layer = select(3, hero:get_position())
    if fish:get_property("drop_files") then
      for file in string.gmatch(fish:get_property("drop_files"), "[^,%s]+") do
        drop = require(file)
        drop.x = x
        drop.y = y
        drop.layer = layer
        local drop_obj
        local movement_speed
        if drop.drop_type == "enemy" then
          drop.direction = fish:get_direction4_to(hero)
          drop_obj = map:create_enemy(drop)
          movement_speed = 50
        elseif drop.drop_type == "pickable" then
          drop_obj = map:create_pickable(drop)
          movement_speed = 200
        end
        local target_movement = sol.movement.create("target")
        target_movement:set_target(hero)
        target_movement:set_speed(movement_speed)
        target_movement:set_ignore_obstacles(true)
        target_movement:start(drop_obj)
      end
    end
    fish.caught = true
    fish:remove()
    fish:vanished_callback()
  end
  item:remove_tackle()
end

function item:place_tackle(layer, x, y)
    active_fishing_tackle = self:get_map():create_custom_entity{
      x = x,
      y = y,
      height = 8,
      width = 8,
      direction = 0,
      layer = layer,
      sprite = "entities/fishing_tackle"
    }
end

function item:remove_tackle()
    active_fishing_tackle:remove()
    active_fishing_tackle = nil
end

function item:on_obtained()
  game:set_item_assigned(1, game:get_item("fishing_rod"))
end
