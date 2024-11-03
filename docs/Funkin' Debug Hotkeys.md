# Funkin' Debug Hotkeys

Most of this functionality is only available on debug builds of the game!

## Any State

- `F2`: **_OVERLAY_**: Enables the Flixel debug overlay, which has partial
  support for scripting.
- `F3`: **_SCREENSHOT_**: Takes a screenshot of the game and saves it to the
  local `screenshots` directory. Works outside of debug builds too!
- `F4`: **_EJECT_**: Forcibly switch state to the Main Menu (with no extra
  transition). Useful if you're stuck in a level and you need to get out!
- `F5`: **_HOT RELOAD_**: Forcibly reload the game's scripts and data files,
  then restart the current state. If any files in the `assets` folder have been
  modified, the game should process the changes for you! NOTE: Known bug, this
  does not reset song charts or song scripts, but it should reset everything
  else (such as stage layout data and character animation data).
- `CTRL-SHIFT-L`: **_FORCE CRASH_**: Immediately crash the game with a detailed
  crash log and a stack trace.

## **Play State**

- `H`: **_HIDE UI_**: Makes the user interface invisible. Works in Pause Menu,
  great for screenshots.
- `1`: **_END SONG_**: Immediately ends the song and moves to Results Screen on
  Freeplay, or next song on Story Mode.
- `2`: **_GAIN HEALTH_**: Debug function, add 10% to the player's health.
- `3`: **_LOSE HEALTH_**: Debug function, subtract 5% to the player's health.
- `9`: NEATO!
- `PAGEUP` (MacOS: `Fn-Up`): **_FORWARDS TIME TRAVEL_**: Move forward by 2
  sections. Hold SHIFT to move forward by 20 sections instead.
- `PAGEDOWN` (MacOS: `Fn-Down`): **_BACKWARDS TIME TRAVEL_**: Move backward by 2
  sections. Hold SHIFT to move backward by 20 sections instead.

## **Freeplay State**

- `F` (Freeplay Menu) - Move to Favorites
- `Q` (Freeplay Menu) - Back one category
- `E` (Freeplay Menu) - Forward one category

## **Title State**

- `Y` - WOAH

## **Main Menu**

- `~`: **_DEBUG_**: Opens a menu to access the Chart Editor and other
  work-in-progress editors. Rebindable in the options menu.
- `CTRL-ALT-SHIFT-W`: **_ALL ACCESS_**: Unlocks all songs in Freeplay. Only
  available on debug builds.
