# TextMap
Is a grid/cell based text editor saving your project natively to a TileMap usable in the Godot game engine.

## Intention
The idea that drove me to do this project is a reimagination of old text adventures (interactive fiction) like zork, where the world is described
with text and you had to enter commands to control your character and your actions.  
Instead of just described by, I wanted the world to be actually _shaped_ by the text, so that you can walk within it like in modern top down role playing games.
But this is just one idea that could be realized with this editor.

## Grid/Cell Based
* Two empty cells will separate text from each other. This is the basic concept. All controls are adapted to this (Home, End, Enter...).
* You can write on the workspace whereever you want.
* Text entered in a line will not affect text that come later in the same line except it's immediately adjacent (less that two empty cells).
* Every character of text entered will use the same amount of space.

## Saves as tile map
* The selected font will be converted to a tile set.
* Collision shapes will be added to all used cells.
* TileSet nodes will be created for all layers (text, terrain) and saved as Godots text scene format (TSCN).

## Usage
You can run and use the editor inside Godot. Most likely however you want to export it to a standalone executable first
as you want to use the saved tile map simultaneously in your game project within Godot.

## Status
The editor itself and especially the export to tile maps are working stable.  
What's missing by now are mostly usability features: There is no menu, no build in settings, no explanation, no shortcut description, et cetera.
But most shortcuts are intuitive and settings can be made in the exported plain text config files.