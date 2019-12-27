# Solarus Fishing Mechanic
This is a basic fishing mechanic similar to the one in Animal Crossing for the Solarus Engine.

![screenshot](screenshots/1.png?raw=true "Screenshot")

## Features
- multiple fish types with different look and behaviour
- some fish types can be more common or rare than others
- multiple spawning locations can be specified and are randomly selected for each new fish
- fishes can spawn pickables and / or enemies

## How to use it
- it's less complicated than it sounds. Just download the demo and try it!
- the map file uses the fish spawner script to spawn fishes (see fishing_demo_map for an example)
- the fish spawner script accepts several parameters which are all required:
    - map: the map to spawn fishes on
    - spawning_positions: array of coordinates (x, y, layer) where fishes can spawn
    - max_fishes: maximum number of fishes that can exist at the same time
    - spawning_delay_ms: how long to wait to spawn a new fish when another one was caught or vanished
    - fish_types: array of objects each containing the information:
        - likelihood: how likely that kind of fish will be spawned --> likelihood for each type is: likelihood of that type / sum of all likelihoods
        - properties: array of properties of the fish
- fishes accept the following properties:
    - max_swimming_distance: how far the fish can swim without stopping
    - swimming_speed: swimming speed
    - seeing angle: viewing angle for spotting the fishing tackle
    - seeing_width: viewing width for spotting the fishing tackle
    - biting_duration_ms: time frame in which the player has to reel in the fish after biting before it vanishes
    - drop_file: string of comma separated file names of files containing information about the stuff that the fish will drop
    - sprite: file name of the sprite the fish will have
- fish properties are objects in the form {key = "key", value = "value"}
- all fish properties have default values and are optional
- fish drops must have a field "drop_type" which can either be "pickable" or "enemy" which changes the type of entity to be spawned
- the other fields of fish drops are passed to map:create_pickable or map:create_enemy
- for better reusability, fish types (properties) and drops are saved in scripts/fishing/fish_types and scripts/fishing/drops

## How to get it into your game
1. Copy the following files into your project (use File --> Import files from a quest):
    - entities/fish.lua
    - items/fishing_rod.lua
    - scripts/fishing/fish_spawner.lua
    - sprites (or create your own):
        - sprites/animals/fish_big.dat
        - sprites/animals/fish_pointy.dat
        - sprites/animals/fish_round.dat
        - sprites/animals/fish.png
        - sprites/entities/fishing_tackle.dat
        - sprites/entities/fishing_tackle.png
        - sprites/hero/eldran_fishing_rod.png
        - sprites/items/fishing_rod.png
        - some default sound effects are also used. You will see error messages if some are missing...

2. Create some fish types and drops in scripts/fishing/fish_types and scripts/fishing/drops or copy some from this demo

3. Create a map that uses the fish spawner (see fishing_demo_map) and give the player a fishing rod pickable

4. create an animation "fishing_rod" in sprites/entities/items with the source image sprites/items/fishing_rod.png

5. create an animation "fishing" for your hero with the source image eldran_fishing_rod.png (or make your own)
  - see this demo project for the correct origin for each direction
  - if you have not modified you sprites/hero/tunic1.dat, you can alternatively just copy and overwrite that file

6. optional: Create a dialog for collecting the fishing rod:
    - \_treasure.fishing_rod.1

## Asset Licensing
The following images are created by me and can be used under the [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) license. I do not require attribution.
  - sprites/animals/fish.png
  - sprites/entities/fishing_tackle.png
  - sprites/items/fishing_rod.png

The image sprites/hero/eldran_fishing_rod.png is based on sprites/hero/eldran_hookshot.png and is licensed under the [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) license.

All the other assets are the defaults from the Solarus project.
