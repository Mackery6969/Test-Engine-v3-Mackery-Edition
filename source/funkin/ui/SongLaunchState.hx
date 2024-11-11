package funkin.ui;

import flixel.FlxSprite;
import funkin.graphics.FunkinCamera;
import funkin.ui.TextMenuList.TextMenuItem;
import funkin.audio.FunkinSound;
import funkin.ui.options.items.ButtonPreferenceItem;
import funkin.ui.options.items.CheckboxPreferenceItem;
import funkin.ui.options.items.NumberPreferenceItem;
import funkin.ui.options.items.EnumPreferenceItem;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.text.FlxText;
import funkin.ui.transition.LoadingState;
import funkin.play.PlayStatePlaylist;
import funkin.ui.AtlasText.AtlasFont;
import funkin.play.song.Song;
import funkin.ui.freeplay.FreeplayState;
import funkin.ui.story.StoryMenuState;
import funkin.data.story.level.LevelRegistry;
import funkin.data.song.SongRegistry;

typedef DefaultPreferences =
{
  var practice:Bool;
  var botPlay:Bool;
  var songSpeed:Float;
  var instaDeathMode:String;
  var healthGain:Float;
  var healthLoss:Float;
  var healthDrainType:String;
  var healthDrainAmount:Float;
}

class SongLaunchState extends MusicBeatState
{
  // Freeplay
  public static var curSong:Song;
  public static var curInstrumental:String;

  // Story Mode
  public static var curWeek:String;
  public static var curWeekId:Null<String> = null;
  public static var weekSongIds:Array<String> = [];

  // Both Freeplay and Story Mode
  public static var curDifficulty:String;
  public static var curVariation:String;

  var isStoryMode:Bool;

  public function new(isStoryMode:Bool = false)
  {
    this.isStoryMode = isStoryMode;
    super();
  }

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
      instaDeathMode: 'None',
      healthGain: 1.0,
      healthLoss: 1.0,
      healthDrainType: 'None',
      healthDrainAmount: 0.02
    };

  var items:TextMenuList;
  var preferenceItems:FlxTypedSpriteGroup<FlxSprite>;
  var menuCamera:FlxCamera;
  var camFollow:FlxObject;
  var bg:FlxSprite;

  public var busy:Bool = false;

  var metadata:FlxTypedSpriteGroup<FlxText>;

  public static var saveScore:Bool = true;

  override public function create():Void
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

    createConfItems();

    camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
    if (items != null) camFollow.y = items.selectedItem.y;

    menuCamera.follow(camFollow, null, 0.06);
    var margin:Int = 160;
    menuCamera.deadzone.set(0, margin, menuCamera.width, 40);
    menuCamera.minScrollY = 0;

    items.onChange.add(function(selected) {
      camFollow.y = selected.y;
    });

    metadata = new FlxTypedSpriteGroup<FlxText>();
    metadata.scrollFactor.set(0, 0);
    add(metadata);

    if (isStoryMode)
    {
      // in story mode this should be the week name
      var metadataWeek:FlxText = new FlxText(20, 15, FlxG.width - 40, curWeek);
      metadataWeek.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, FlxTextAlign.RIGHT);
      metadataWeek.scrollFactor.set(0, 0);
      metadata.add(metadataWeek);

      // might do some other time...
      // in story mode it should take all the artists for every song in the week
      var metadataArtist:FlxText = new FlxText(20, metadataWeek.y + 32, FlxG.width - 40, 'Artist: UNKNOWN');
      metadataArtist.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, FlxTextAlign.RIGHT);
      metadataArtist.scrollFactor.set(0, 0);
      metadata.add(metadataArtist);

      // curDifficulty
      var metadataDifficulty:FlxText = new FlxText(20, metadataArtist.y + 32, FlxG.width - 40, 'Difficulty: ${curDifficulty}');
      metadataDifficulty.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, FlxTextAlign.RIGHT);
      metadataDifficulty.scrollFactor.set(0, 0);
      metadata.add(metadataDifficulty);
    }
    else
    {
      var metadataSong:FlxText = new FlxText(20, 15, FlxG.width - 40, curSong.songName);
      metadataSong.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, FlxTextAlign.RIGHT);
      metadataSong.scrollFactor.set(0, 0);
      metadata.add(metadataSong);

      var metadataArtist:FlxText = new FlxText(20, metadataSong.y + 32, FlxG.width - 40, 'Artist: ${curSong.songArtist}');
      metadataArtist.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, FlxTextAlign.RIGHT);
      metadataArtist.scrollFactor.set(0, 0);
      metadata.add(metadataArtist);

      var metadataDifficulty:FlxText = new FlxText(20, metadataArtist.y + 32, FlxG.width - 40, 'Difficulty: ${curDifficulty}');
      metadataDifficulty.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, FlxTextAlign.RIGHT);
      metadataDifficulty.scrollFactor.set(0, 0);
      metadata.add(metadataDifficulty);
    }

    markModifiedOptions();
  }

  /**
   * Checks if any preferences or modifiers are not set to their default values
   * to determine if saveScore should be set to false.
   */
  function checkModifiers():Void
  {
    saveScore = (Preferences.practice == DEFAULT_VALUES.practice
      && Preferences.botPlay == DEFAULT_VALUES.botPlay
      && Preferences.songSpeed == DEFAULT_VALUES.songSpeed
      && Preferences.instaDeathMode == DEFAULT_VALUES.instaDeathMode
      && Preferences.healthGain == DEFAULT_VALUES.healthGain
      && Preferences.healthLoss == DEFAULT_VALUES.healthLoss
      && Preferences.healthDrainType == DEFAULT_VALUES.healthDrainType);
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
        daItem.label.set_text((Preferences.practice != DEFAULT_VALUES.practice) ? "Practice Mode*" : "Practice Mode");
      }
      else if (labelText.indexOf("BotPlay") != -1)
      {
        daItem.label.set_text((Preferences.botPlay != DEFAULT_VALUES.botPlay) ? "BotPlay*" : "BotPlay");
      }
      else if (labelText.indexOf("Song Speed") != -1)
      {
        daItem.label.set_text((Preferences.songSpeed != DEFAULT_VALUES.songSpeed) ? "Song Speed*" : "Song Speed");
      }
      else if (labelText.indexOf("Health Gain") != -1)
      {
        daItem.label.set_text((Preferences.healthGain != DEFAULT_VALUES.healthGain) ? "Health Gain*" : "Health Gain");
      }
      else if (labelText.indexOf("Health Loss") != -1)
      {
        daItem.label.set_text((Preferences.healthLoss != DEFAULT_VALUES.healthLoss) ? "Health Loss*" : "Health Loss");
      }
      else if (labelText.indexOf('Health Drain') != -1)
      {
        daItem.label.set_text((Preferences.healthDrainType != DEFAULT_VALUES.healthDrainType) ? "Health Drain*" : "Health Drain");
      }
    });
  }

  /**
   * Create the menu items for each of the preferences.
   */
  function createConfItems():Void
  {
    createConfItemButton('Start', function():Void {
      if (!busy) start();
    });

    createConfItemCheckbox('Practice Mode', function(value:Bool):Void {
      Preferences.practice = value;
      markModifiedOptions();
      checkModifiers();
    }, Preferences.practice);

    createConfItemCheckbox('BotPlay', function(value:Bool):Void {
      Preferences.botPlay = value;
      markModifiedOptions();
      checkModifiers();
    }, Preferences.botPlay);

    createConfItemPercentage('Song Speed', function(value:Int):Void {
      Preferences.songSpeed = value / 100.0;
      markModifiedOptions();
      checkModifiers();
    }, Std.int(Preferences.songSpeed * 100), 5, 1000);

    createConfItemEnum('Death Mode', ["None" => "None", "SFC" => "Sick FC", "GFC" => "Good FC", "FC" => "FC"], function(value:String) {
      Preferences.instaDeathMode = value;
      markModifiedOptions();
      checkModifiers();
    }, Preferences.instaDeathMode);

    createConfItemPercentage('Health Gain', function(value:Int):Void {
      Preferences.healthGain = value / 100.0;
      markModifiedOptions();
      checkModifiers();
    }, Std.int(Preferences.healthGain * 100), 0, 1000);

    createConfItemPercentage('Health Loss', function(value:Int):Void {
      Preferences.healthLoss = value / 100.0;
      markModifiedOptions();
      checkModifiers();
    }, Std.int(Preferences.healthLoss * 100), 0, 1000);

    createConfItemEnum('Health Drain', [
      "None" => "None",
      "Penalty" => "Karma",
      "Fair Fight" => "Fair Fight",
      "Constant" => "Constant"
    ], function(value:String) {
      Preferences.healthDrainType = value;
      markModifiedOptions();
      checkModifiers();
    }, Preferences.healthDrainType);

    createConfItemDecimal('Health Drain Amount', function(value:Float) {
      Preferences.healthDrainAmount = value;
      markModifiedOptions();
      checkModifiers();
    }, null, Preferences.healthDrainAmount, 0.005, 1, 0.0005, 3);
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (FlxG.keys.justPressed.ESCAPE && !busy)
    {
      trace('Back to Main Menu?????');
      // FlxG.switchState(() -> new MainMenuState());
      killAll();
      if (isStoryMode)
      {
        FlxG.switchState(() -> new StoryMenuState());
      }
      else
      {
        openSubState(new FreeplayState(null));
      }
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

  function createConfItemButton(prefName:String, onClick:Void->Void):Void
  {
    var button:ButtonPreferenceItem = new ButtonPreferenceItem(0, (120 * (items.length - 1 + 1)), prefName);

    items.createItem(0, (120 * items.length) + 30, prefName, AtlasFont.BOLD, function() {
      onClick();
      markModifiedOptions(); // Refresh option labels
    });

    preferenceItems.add(button);
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

  function createConfItemDecimal(prefName:String, onChange:Float->Void, ?valueFormatter:Float->String, defaultValue:Float, min:Float, max:Float,
      step:Float = 0.1, precision:Int = 2):Void
  {
    var item = new NumberPreferenceItem(0, (120 * items.length) + 30, prefName, defaultValue, min, max, step, precision, onChange, valueFormatter);
    item.allowHolding = false;
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
    var item:NumberPreferenceItem = new NumberPreferenceItem(0, (120 * items.length) + 30, prefName, defaultValue, min, max, 5, 0, newCallback, formatter);
    items.addItem(prefName, item);
    preferenceItems.add(item.lefthandText);
  }

  function createConfItemEnum(prefName:String, values:Map<String, String>, onChange:String->Void, defaultValue:String):Void
  {
    var item:EnumPreferenceItem = new EnumPreferenceItem(0, (120 * items.length) + 30, prefName, values, defaultValue, onChange);
    items.addItem(prefName, item);
    preferenceItems.add(item.lefthandText);
    markModifiedOptions(); // Update option label on creation
  }

  function start():Void
  {
    busy = true;
    killAll();

    if (isStoryMode)
    {
      Paths.setCurrentLevel(curWeekId);

      Highscore.talliesLevel = new funkin.Highscore.Tallies();

      PlayStatePlaylist.playlistSongIds = weekSongIds;
      PlayStatePlaylist.isStoryMode = true;
      PlayStatePlaylist.campaignScore = 0;

      var targetSongId:String = weekSongIds.shift();

      var targetSong:Song = SongRegistry.instance.fetchEntry(targetSongId);

      PlayStatePlaylist.campaignId = curWeekId;
      PlayStatePlaylist.campaignTitle = curWeek;
      PlayStatePlaylist.campaignDifficulty = curDifficulty;

      var targetVariation:String = targetSong.getFirstValidVariation(PlayStatePlaylist.campaignDifficulty);

      LoadingState.loadPlayState(
        {
          targetSong: targetSong,
          targetDifficulty: PlayStatePlaylist.campaignDifficulty,
          targetVariation: targetVariation,
          practiceMode: Preferences.practice,
          botPlayMode: Preferences.botPlay,
          playbackRate: Preferences.songSpeed,
        }, true);
    }
    else
    {
      Paths.setCurrentLevel(levelId);

      PlayStatePlaylist.isStoryMode = false;

      LoadingState.loadPlayState(
        {
          targetSong: curSong,
          targetDifficulty: curDifficulty,
          targetVariation: curVariation,
          targetInstrumental: curInstrumental,
          practiceMode: Preferences.practice,
          minimalMode: false,
          botPlayMode: Preferences.botPlay,
          playbackRate: Preferences.songSpeed,
        }, true);
    }
  }

  /**
   * Kills all objects in this state, for optimization
   */
  function killAll():Void
  {
    bg.kill();
    metadata.kill();
    for (item in items)
    {
      item.kill();
    }
    for (preferenceItem in preferenceItems)
    {
      preferenceItem.kill();
    }
    FunkinSound.emptyPartialQueue();
  }
}
