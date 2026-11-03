# Mini Platformer (Godot 4)

Open Godot 4.3+ -> Import -> select `project.godot` -> press F5.

Controls: A/D or Arrow keys = move, Space/W/Up = jump, R = restart level.

Everything is built in code (no art assets). Level layout lives in `main.gd` -> `_build_level()`.

Files: main.gd (level, HUD, game flow), player.gd, enemy.gd, hazard.gd (spikes),
pickup.gd (coins/checkpoints/goal), moving_platform.gd.

Ideas next: power-ups (double jump), more enemy types, real sprites + TileMap,
sound, a title screen, multiple levels.
