-- Lua script of custom entity fish.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()

entity.caught = false

-- default properties
local default_properties = {
  max_swimming_distance = 1000,
  swimming_speed = 20,
  seeing_angle = 2,
  seeing_width = 50,
  biting_duration_ms = 2000,
  drop_files = nil,
  sprite = "animals/fish_big",
}

function entity:apply_default_properties()
  for key, value in pairs(default_properties) do
    if not entity:get_property(key) then
      entity:set_property(key, value)
    end
  end
end


function entity:on_created()
  entity:apply_default_properties()
  entity:set_can_traverse_ground("deep_water", true)
  entity:set_can_traverse_ground("lava", true)
  entity:set_can_traverse_ground("empty", false)
  entity:set_can_traverse_ground("grass", false)
  entity:set_can_traverse_ground("traversable", false)
  -- set size to size of the sprite
  entity:create_sprite(entity:get_property("sprite"))
  local width, height = entity:get_sprite():get_size()
  entity:set_size(width, height)
  entity:get_sprite():fade_in(100)
  entity:start_wander()
end

function entity:start_wander()
  local random_movement = sol.movement.create("random")
  random_movement:set_smooth(false)
  random_movement:set_speed(entity:get_property("swimming_speed"))
  random_movement:set_max_distance(entity:get_property("max_swimming_distance"))
  function random_movement:on_changed()
    -- update sprite
    entity:get_sprite():set_direction(random_movement:get_direction4())
    -- check for tackle
    if not active_fishing_tackle then
      return true
    end
    -- ignore tackle if there already is a fish on it
    if active_fishing_tackle.fish_on_hook then
      return true
    end
    -- only move to tackle if it can be seen
    local tackle_angle = entity:get_angle(active_fishing_tackle)
    local tackle_distance = entity:get_distance(active_fishing_tackle)
    if (tackle_angle <= tonumber(entity:get_property("seeing_angle")) and tackle_distance <= tonumber(entity:get_property("seeing_width"))) then
      random_movement:stop()
      entity:approach_tackle()
    end
  end
  random_movement:start(entity)
end

function entity:approach_tackle()
  local target_movement = sol.movement.create("target")
  target_movement:set_smooth(true)
  target_movement:set_speed(entity:get_property("swimming_speed"))
  target_movement:set_target(active_fishing_tackle)
  -- if the tackle is removed or occupied while approaching, wander again
  function target_movement:on_position_changed()
    if ((not active_fishing_tackle) or active_fishing_tackle.fish_on_hook) then
      -- cancel if the tackle is gone or occupied
      target_movement:stop()
      entity:start_wander()
      return true
    end
    if entity:overlaps(active_fishing_tackle, "touching") then
      -- bite
      target_movement:stop()
      entity:bite()
    end
  end
  function target_movement:on_finished() entity:bite() end
  target_movement:start(entity)
  -- update sprite
  entity:get_sprite():set_direction(target_movement:get_direction4())
end

function entity:bite()
  if active_fishing_tackle.fish_on_hook then
    -- too late, wander again
    entity:start_wander()
    return true
  end
  active_fishing_tackle.fish_on_hook = entity
  active_fishing_tackle:get_sprite():set_animation("catch")
  sol.audio.play_sound("cane3")
  sol.timer.start(tonumber(entity:get_property("biting_duration_ms")), function()
    if (entity.caught) then
      -- fish was caught
      entity:remove()
      return true
    end
    -- fish escapes
    active_fishing_tackle.fish_on_hook = nil
    active_fishing_tackle:get_sprite():set_animation("idle")
    sol.audio.play_sound("cane")
    local random_movement = sol.movement.create("random")
    random_movement:set_ignore_obstacles(true)
    random_movement:start(entity)
    entity:get_sprite():set_direction(random_movement:get_direction4())
    entity:get_sprite():fade_out(20, function() entity:remove() entity:vanished_callback() end)
  end)
end