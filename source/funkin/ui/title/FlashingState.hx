package funkin.ui.title;

import funkin.ui.AtlasText;
import funkin.save.Save;
import funkin.ui.MusicBeatState;
import flixel.FlxSprite;
import funkin.ui.mainmenu.MainMenuState;
import funkin.save.Save;

/**
 * state to warn the user of flashing lights
 */
class FlashingState extends MusicBeatState
{
  var bg:FlxSprite;
  var warning:AtlasText;
  var text:AtlasText;

  override public function create():Void
  {
    super.create();

    Preferences.seenFlashingState = true;
    var save:Save = Save.instance;
    save.options.seenFlashingState = true;
    save.flush();

    bg = new FlxSprite(Paths.image('menuDesat'));
    bg.scrollFactor.set(0, 0);
    bg.setGraphicSize(Std.int(bg.width * 1.2));
    bg.updateHitbox();
    bg.screenCenter();
    add(bg);

    warning = new AtlasText(FlxG.width / 2 - 100, 20, "WARNING", AtlasFont.BOLD);
    add(warning);

    text = new AtlasText(20, 125, "This Game contains FLASHING LIGHTS,\nyou can disable these by pressing ENTER,\notherwise press ESCAPE", AtlasFont.DEFAULT);
    add(text);
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (FlxG.keys.justPressed.ENTER)
    {
      trace('Player Disabled Flashing Lights!');
      Preferences.flashingLights = false;
      var save:Save = Save.instance;
      save.options.flashingLights = false;
      save.flush();
      exit();
    }
    else if (FlxG.keys.justPressed.ESCAPE)
    {
      trace("Player Enabled Flashing Lights!");
      Preferences.flashingLights = true;
      var save:Save = Save.instance;
      save.options.flashingLights = true;
      save.flush();
      exit();
    }
  }

  function exit():Void
  {
    Preferences.seenFlashingState = true;
    var save:Save = Save.instance;
    save.options.seenFlashingState = true;
    save.flush();
    bg.kill();
    warning.kill();
    text.kill();
    FlxG.switchState(() -> new MainMenuState());
  }
}
