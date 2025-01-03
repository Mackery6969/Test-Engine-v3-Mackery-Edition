package funkin;

import funkin.save.Save;

/**
 * A core class which provides a store of user-configurable, globally relevant values.
 */
class Preferences
{
  /**
   * FPS
   * @default `60`
   */
  public static var framerate(get, set):Int;

  static function get_framerate():Int
  {
    #if web
    return 60;
    #else
    return Save?.instance?.options?.framerate ?? 60;
    #end
  }

  static function set_framerate(value:Int):Int
  {
    #if web
    return 60;
    #else
    var save:Save = Save.instance;
    save.options.framerate = value;
    save.flush();
    FlxG.updateFramerate = value;
    FlxG.drawFramerate = value;
    return value;
    #end
  }

  /**
   * Whether some particularly foul language is displayed.
   * @default `true`
   */
  public static var quality(get, set):String;

  static function get_quality():String
  {
    return Save?.instance?.options?.quality;
  }

  static function set_quality(value:String):String
  {
    var save:Save = Save.instance;
    save.options.quality = value;
    save.flush();
    return value;
  }

  /**
   * Whether some particularly foul language is displayed.
   * @default `true`
   */
  public static var naughtyness(get, set):Bool;

  static function get_naughtyness():Bool
  {
    return Save?.instance?.options?.naughtyness;
  }

  static function set_naughtyness(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.naughtyness = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, the strumline is at the bottom of the screen rather than the top.
   * @default `false`
   */
  public static var downscroll(get, set):Bool;

  static function get_downscroll():Bool
  {
    return Save?.instance?.options?.downscroll;
  }

  static function set_downscroll(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.downscroll = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, pressing a note when none is there wont count as a miss.
   * @default `true`
   */
  public static var ghostTapping(get, set):Bool;

  static function get_ghostTapping():Bool
  {
    return Save?.instance?.options?.ghostTapping;
  }

  static function set_ghostTapping(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.ghostTapping = value;
    save.flush();
    return value;
  }

  /**
   * If disabled, flashing lights in the main menu and other areas will be less intense.
   * @default `true`
   */
  public static var flashingLights(get, set):Bool;

  static function get_flashingLights():Bool
  {
    return Save?.instance?.options?.flashingLights ?? true;
  }

  static function set_flashingLights(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.flashingLights = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, the score text will be unchanged from the original game!
   * @default `false`
   */
  public static var oldScoreText(get, set):Bool;

  static function get_oldScoreText():Bool
  {
    return Save?.instance?.options?.oldScoreText ?? true;
  }

  static function set_oldScoreText(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.oldScoreText = value;
    save.flush();
    return value;
  }

  /**
   * If disabled, the camera bump synchronized to the beat.
   * @default `false`
   */
  public static var zoomCamera(get, set):Bool;

  static function get_zoomCamera():Bool
  {
    return Save?.instance?.options?.zoomCamera;
  }

  static function set_zoomCamera(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.zoomCamera = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, an FPS and memory counter will be displayed even if this is not a debug build.
   * @default `false`
   */
  public static var debugDisplay(get, set):Bool;

  static function get_debugDisplay():Bool
  {
    return Save?.instance?.options?.debugDisplay;
  }

  static function set_debugDisplay(value:Bool):Bool
  {
    if (value != Save.instance.options.debugDisplay)
    {
      toggleDebugDisplay(value);
    }

    var save = Save.instance;
    save.options.debugDisplay = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, the game will automatically pause when tabbing out.
   * @default `true`
   */
  public static var autoPause(get, set):Bool;

  static function get_autoPause():Bool
  {
    return Save?.instance?.options?.autoPause ?? true;
  }

  static function set_autoPause(value:Bool):Bool
  {
    if (value != Save.instance.options.autoPause) FlxG.autoPause = value;

    var save:Save = Save.instance;
    save.options.autoPause = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, when selecting a week or song, you will be sent to a state to select modifiers.
   * @default `true`
   */
  public static var songLaunchScreen(get, set):Bool;

  static function get_songLaunchScreen():Bool
  {
    return Save?.instance?.options?.songLaunchScreen;
  }

  static function set_songLaunchScreen(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.songLaunchScreen = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, when selecting a week or song, you will be sent to a state to select modifiers.
   * @default `true`
   */
  public static var instrumentalSelect(get, set):Bool;

  static function get_instrumentalSelect():Bool
  {
    return Save?.instance?.options?.instrumentalSelect;
  }

  static function set_instrumentalSelect(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.instrumentalSelect = value;
    save.flush();
    return value;
  }

  public static var unlockedFramerate(get, set):Bool;

  static function get_unlockedFramerate():Bool
  {
    return Save?.instance?.options?.unlockedFramerate;
  }

  static function set_unlockedFramerate(value:Bool):Bool
  {
    if (value != Save.instance.options.unlockedFramerate)
    {
      #if web
      toggleFramerateCap(value);
      #end
    }

    var save:Save = Save.instance;
    save.options.unlockedFramerate = value;
    save.flush();
    return value;
  }

  #if web
  // We create a haxe version of this just for readability.
  // We use these to override `window.requestAnimationFrame` in Javascript to uncap the framerate / "animation" request rate
  // Javascript is crazy since u can just do stuff like that lol

  public static function unlockedFramerateFunction(callback, element)
  {
    var currTime = Date.now().getTime();
    var timeToCall = 0;
    var id = js.Browser.window.setTimeout(function() {
      callback(currTime + timeToCall);
    }, timeToCall);
    return id;
  }

  // Lime already implements their own little framerate cap, so we can just use that
  // This also gets set in the init function in Main.hx, since we need to definitely override it
  public static var lockedFramerateFunction = untyped js.Syntax.code("window.requestAnimationFrame");
  #end

  public static var experimentalOptions(get, set):Bool;

  static function get_experimentalOptions():Bool
  {
    return Save?.instance?.options?.experimentalOptions;
  }

  static function set_experimentalOptions(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.experimentalOptions = value;
    save.flush();
    return value;
  }

  public static var seenFlashingState(get, set):Bool;

  static function get_seenFlashingState():Bool
  {
    return Save?.instance?.options?.seenFlashingState;
  }

  static function set_seenFlashingState(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.seenFlashingState = value;
    save.flush();
    return value;
  }

  public static var comboMilestone(get, set):Bool;

  static function get_comboMilestone():Bool
  {
    return Save?.instance?.options?.comboMilestone;
  }

  static function set_comboMilestone(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.comboMilestone = value;
    save.flush();
    return value;
  }

  // MODIFIERS

  /**
   * If Enabled, the game will play itself.
   * Score will not be saved
   * @default 'false'
   */
  public static var botPlay(get, set):Bool;

  static function get_botPlay():Bool
  {
    return Save?.instance?.options?.botPlay;
  }

  static function set_botPlay(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.botPlay = value;
    save.flush();
    return value;
  }

  public static var practice(get, set):Bool;

  static function get_practice():Bool
  {
    return Save?.instance?.options?.practice;
  }

  static function set_practice(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.practice = value;
    save.flush();
    return value;
  }

  public static var songSpeed(get, set):Int;

  static function get_songSpeed():Int
  {
    return Save?.instance?.options?.songSpeed;
  }

  static function set_songSpeed(value:Int):Int
  {
    var save:Save = Save.instance;
    save.options.songSpeed = value;
    save.flush();
    return value;
  }

  public static var instaDeathMode(get, set):String;

  static function get_instaDeathMode():String
  {
    return Save?.instance?.options?.instaDeathMode;
  }

  static function set_instaDeathMode(value:String):String
  {
    var save:Save = Save.instance;
    save.options.instaDeathMode = value;
    save.flush();
    return value;
  }

  public static var healthGain(get, set):Int;

  static function get_healthGain():Int
  {
    return Save?.instance?.options?.healthGain;
  }

  static function set_healthGain(value:Int):Int
  {
    var save:Save = Save.instance;
    save.options.healthGain = value;
    save.flush();
    return value;
  }

  public static var healthLoss(get, set):Int;

  static function get_healthLoss():Int
  {
    return Save?.instance?.options?.healthLoss;
  }

  static function set_healthLoss(value:Int):Int
  {
    var save:Save = Save.instance;
    save.options.healthLoss = value;
    save.flush();
    return value;
  }

  public static var healthDrainType(get, set):String;

  static function get_healthDrainType():String
  {
    return Save?.instance?.options?.healthDrainType;
  }

  static function set_healthDrainType(value:String):String
  {
    var save:Save = Save.instance;
    save.options.healthDrainType = value;
    save.flush();
    return value;
  }

  public static var healthDrainAmount(get, set):Float;

  static function get_healthDrainAmount():Float
  {
    return Save?.instance?.options?.healthDrainAmount;
  }

  static function set_healthDrainAmount(value:Float):Float
  {
    var save:Save = Save.instance;
    save.options.healthDrainAmount = value;
    save.flush();
    return value;
  }

  /**
   * Loads the user's preferences from the save data and apply them.
   */
  public static function init():Void
  {
    // Apply the autoPause setting (enables automatic pausing on focus lost).
    FlxG.autoPause = Preferences.autoPause;
    // Apply the debugDisplay setting (enables the FPS and RAM display).
    toggleDebugDisplay(Preferences.debugDisplay);
    #if web
    toggleFramerateCap(Preferences.unlockedFramerate);
    #end
  }

  static function toggleFramerateCap(unlocked:Bool):Void
  {
    #if web
    var framerateFunction = unlocked ? unlockedFramerateFunction : lockedFramerateFunction;
    untyped js.Syntax.code("window.requestAnimationFrame = framerateFunction;");
    #end
  }

  static function toggleDebugDisplay(show:Bool):Void
  {
    if (show)
    {
      // Enable the debug display.
      FlxG.stage.addChild(Main.fpsCounter);
      #if !html5
      FlxG.stage.addChild(Main.memoryCounter);
      #end
    }
    else
    {
      // Disable the debug display.
      FlxG.stage.removeChild(Main.fpsCounter);
      #if !html5
      FlxG.stage.removeChild(Main.memoryCounter);
      #end
    }
  }
}
