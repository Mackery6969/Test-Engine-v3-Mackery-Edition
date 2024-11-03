package funkin.ui.freeplay;

import flixel.FlxSprite;
import funkin.graphics.FunkinCamera;
import funkin.ui.TextMenuList.TextMenuItem;
import funkin.audio.FunkinSound;
import funkin.ui.options.items.CheckboxPreferenceItem;
import funkin.ui.options.items.NumberPreferenceItem;
import funkin.ui.options.items.EnumPreferenceItem;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.text.FlxText;
import funkin.ui.transition.LoadingState;
import funkin.ui.AtlasText.AtlasFont;
import funkin.play.song.Song;
import funkin.ui.mainmenu.MainMenuState;

typedef DefaultPreferences =
{
  var practice:Bool;
  var botPlay:Bool;
  var songSpeed:Float;
  var lossOnComboLoss:Bool;
  var healthGain:Float;
  var healthLoss:Float;
}

class SongLaunchState extends MusicBeatState
{
  public static var curSong:Song;
  public static var curDifficulty:String;
  public static var curVariation:String;
  public static var curInstrumental:String;
  public static var isStoryMode:Bool = false;

  public static var levelId(get, never):Null<String>;

  static function get_levelId():Null<String>
  {
    return _levelId;
  }

  public static var _levelId:String;

  public static var DEFAULT_VALUES:DefaultPreferences =
    {
      practice: false,
      botPlay: false,
      songSpeed: 1.0,
      lossOnComboLoss: false,
      healthGain: 1.0,
      healthLoss: 1.0
    };

  // Define public static variables for preferences
  public static var practice:Bool = DEFAULT_VALUES.practice;
  public static var botPlay:Bool = DEFAULT_VALUES.botPlay;
  public static var songSpeed:Float = DEFAULT_VALUES.songSpeed;
  public static var lossOnComboLoss:Bool = DEFAULT_VALUES.lossOnComboLoss;
  public static var healthGain:Float = DEFAULT_VALUES.healthGain;
  public static var healthLoss:Float = DEFAULT_VALUES.healthLoss;

  var items:TextMenuList;
  var preferenceItems:FlxTypedSpriteGroup<FlxSprite>;
  var menuCamera:FlxCamera;
  var camFollow:FlxObject;
  var bg:FlxSprite;

  var metadata:FlxTypedSpriteGroup<FlxText>;

  public static var saveScore:Bool = true;

  override public function create()
  {
    super.create();

    bg = new FlxSprite(Paths.image('menuBGMagenta'));
    bg.scrollFactor.set(0, 0);
    bg.setGraphicSize(Std.int(bg.width * 1.2));
    bg.updateHitbox();
    bg.screenCenter();
    add(bg);

    menuCamera = new FunkinCamera('prefMenu');
    FlxG.cameras.add(menuCamera, false);
    menuCamera.bgColor = 0x0;
    camera = menuCamera;

    add(items = new TextMenuList());
    add(preferenceItems = new FlxTypedSpriteGroup<FlxSprite>());

    // Add "Start" as the first item
    items.createItem(0, 120 * items.length, "Start", AtlasFont.BOLD, function() {
      start();
    });

    createConfItems();

    camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
    if (items != null) camFollow.y = items.selectedItem.y;

    menuCamera.follow(camFollow, null, 0.06);
    var margin = 160;
    menuCamera.deadzone.set(0, margin, menuCamera.width, 40);
    menuCamera.minScrollY = 0;

    items.onChange.add(function(selected) {
      camFollow.y = selected.y;
    });

    metadata = new FlxTypedSpriteGroup<FlxText>();
    metadata.scrollFactor.set(0, 0);
    add(metadata);

    var metadataSong:FlxText = new FlxText(20, 15, FlxG.width - 40, curSong.songName);
    metadataSong.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, FlxTextAlign.RIGHT);
    metadataSong.scrollFactor.set(0, 0);
    metadata.add(metadataSong);

    var metadataArtist = new FlxText(20, metadataSong.y + 32, FlxG.width - 40, 'Artist: ${curSong.songArtist}');
    metadataArtist.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, FlxTextAlign.RIGHT);
    metadataArtist.scrollFactor.set(0, 0);
    metadata.add(metadataArtist);

    var metadataDifficulty:FlxText = new FlxText(20, metadataArtist.y + 32, FlxG.width - 40, 'Difficulty: ${curDifficulty}');
    metadataDifficulty.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, FlxTextAlign.RIGHT);
    metadataDifficulty.scrollFactor.set(0, 0);
    metadata.add(metadataDifficulty);

    markModifiedOptions();
  }

  /**
   * Checks if any preferences or modifiers are not set to their default values
   * to determine if saveScore should be set to false.
   */
  function checkModifiers():Void
  {
    saveScore = (songSpeed == DEFAULT_VALUES.songSpeed
      && lossOnComboLoss == DEFAULT_VALUES.lossOnComboLoss
      && healthGain == DEFAULT_VALUES.healthGain
      && healthLoss == DEFAULT_VALUES.healthLoss
      && practice == DEFAULT_VALUES.practice
      && DEFAULT_VALUES.botPlay);
  }

  /**
   * Mark modified options by adding an asterisk (*) to their labels if they differ from default values.
   */
  function markModifiedOptions():Void
  {
    items.forEach(function(daItem:TextMenuItem) {
      var labelText = daItem.label.text; // Get the label's text

      // Check specific option names and update labels if they differ from defaults
      if (labelText.indexOf("Practice Mode") != -1)
      {
        daItem.label.set_text((practice != DEFAULT_VALUES.practice) ? "Practice Mode*" : "Practice Mode");
      }
      else if (labelText.indexOf("BotPlay") != -1)
      {
        daItem.label.set_text((botPlay != DEFAULT_VALUES.botPlay) ? "BotPlay*" : "BotPlay");
      }
      else if (labelText.indexOf("Song Speed") != -1)
      {
        daItem.label.set_text((songSpeed != DEFAULT_VALUES.songSpeed) ? "Song Speed*" : "Song Speed");
      }
      /*
        else if (labelText.indexOf("Loss on Combo Loss") != -1)
        {
          daItem.label.set_text((lossOnComboLoss != DEFAULT_VALUES.lossOnComboLoss) ? "Loss on Combo Loss*" : "Loss on Combo Loss");
        }
       */
      else if (labelText.indexOf("Health Gain") != -1)
      {
        daItem.label.set_text((healthGain != DEFAULT_VALUES.healthGain) ? "Health Gain*" : "Health Gain");
      }
      else if (labelText.indexOf("Health Loss") != -1)
      {
        daItem.label.set_text((healthLoss != DEFAULT_VALUES.healthLoss) ? "Health Loss*" : "Health Loss");
      }
    });
  }

  /**
   * Create the menu items for each of the preferences.
   */
  function createConfItems():Void
  {
    createConfItemCheckbox('Practice Mode', function(value:Bool):Void {
      practice = value;
      markModifiedOptions();
      checkModifiers();
    }, practice);

    createConfItemCheckbox('BotPlay', function(value:Bool):Void {
      botPlay = value;
      markModifiedOptions();
      checkModifiers();
    }, botPlay);

    createConfItemPercentage('Song Speed', function(value:Int):Void {
      songSpeed = value / 100.0;
      markModifiedOptions();
      checkModifiers();
    }, Std.int(songSpeed * 100), 5, 1000);

    createConfItemCheckbox('Loss on Combo Loss', function(value:Bool):Void {
      lossOnComboLoss = value;
      markModifiedOptions();
      checkModifiers();
    }, lossOnComboLoss);

    createConfItemPercentage('Health Gain', function(value:Int):Void {
      healthGain = value / 100.0;
      markModifiedOptions();
      checkModifiers();
    }, Std.int(healthGain * 100), 0, 1000);

    createConfItemPercentage('Health Loss', function(value:Int):Void {
      healthLoss = value / 100.0;
      markModifiedOptions();
      checkModifiers();
    }, Std.int(healthLoss * 100), 0, 1000);
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (FlxG.keys.justPressed.ESCAPE)
    {
      trace('Back to Main Menu?????');
      // FlxG.switchState(() -> new MainMenuState());
      openSubState(new FreeplayState(null));
    }

    // Adjust positioning of menu items
    items.forEach(function(daItem:TextMenuItem) {
      var thyOffset:Int = 0;
      var thyTextWidth:Int = 0;
      if (Std.isOfType(daItem, EnumPreferenceItem)) thyTextWidth = cast(daItem, EnumPreferenceItem).lefthandText.getWidth();
      else if (Std.isOfType(daItem, NumberPreferenceItem)) thyTextWidth = cast(daItem, NumberPreferenceItem).lefthandText.getWidth();

      if (thyTextWidth != 0)
      {
        thyOffset += thyTextWidth - 75;
      }

      if (items.selectedItem == daItem)
      {
        thyOffset += 150;
      }
      else
      {
        thyOffset += 120;
      }

      daItem.x = thyOffset;
    });
  }

  function createConfItemCheckbox(prefName:String, onChange:Bool->Void, defaultValue:Bool):Void
  {
    var checkbox:CheckboxPreferenceItem = new CheckboxPreferenceItem(0, 120 * (items.length - 1 + 1), defaultValue, prefName);

    items.createItem(0, (120 * items.length) + 30, prefName, AtlasFont.BOLD, function() {
      var value = !checkbox.currentValue;
      onChange(value);
      checkbox.currentValue = value;
      markModifiedOptions(); // Refresh option labels
    });

    preferenceItems.add(checkbox);
  }

  function createConfItemNumber(prefName:String, onChange:Float->Void, ?valueFormatter:Float->String, defaultValue:Int, min:Int, max:Int, step:Float = 0.1,
      precision:Int):Void
  {
    var item = new NumberPreferenceItem(0, (120 * items.length) + 30, prefName, defaultValue, min, max, step, precision, onChange, valueFormatter);
    items.addItem(prefName, item);
    preferenceItems.add(item.lefthandText);
    markModifiedOptions(); // Update option label on creation
  }

  function createConfItemPercentage(prefName:String, onChange:Int->Void, defaultValue:Int, min:Int = 0, max:Int = 100):Void
  {
    var newCallback = function(value:Float) {
      onChange(Std.int(value));
      markModifiedOptions(); // Refresh option labels
    };
    var formatter = function(value:Float) {
      return '${value}%';
    };
    var item = new NumberPreferenceItem(0, (120 * items.length) + 30, prefName, defaultValue, min, max, 5, 0, newCallback, formatter);
    items.addItem(prefName, item);
    preferenceItems.add(item.lefthandText);
  }

  function createConfItemEnum(prefName:String, values:Map<String, String>, onChange:String->Void, defaultValue:String):Void
  {
    var item = new EnumPreferenceItem(0, (120 * items.length) + 30, prefName, values, defaultValue, onChange);
    items.addItem(prefName, item);
    preferenceItems.add(item.lefthandText);
    markModifiedOptions(); // Update option label on creation
  }

  function start():Void
  {
    FunkinSound.emptyPartialQueue();

    Paths.setCurrentLevel(levelId);
    LoadingState.loadPlayState(
      {
        targetSong: curSong,
        targetDifficulty: curDifficulty,
        targetVariation: curVariation,
        targetInstrumental: curInstrumental,
        practiceMode: practice,
        minimalMode: false,
        botPlayMode: botPlay,
        playbackRate: songSpeed,
      }, true);
  }
}
