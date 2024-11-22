package funkin.save.migrator;

import funkin.save.Save;
import funkin.save.migrator.RawSaveData_v1_0_0;
import thx.semver.Version;
import funkin.util.VersionUtil;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;

@:nullSafety
class SaveDataMigrator
{
  /**
   * Migrate from one 2.x version to another.
   */
  public static function migrate(inputData:Dynamic):Save
  {
    var version:Null<thx.semver.Version> = VersionUtil.parseVersion(inputData?.version ?? null);

    if (version == null)
    {
      trace("[SAVE] No version found in save data! Returning blank data.");
      trace(inputData);
      archiveInvalidSaveData(inputData, "Invalid or missing version");
      return new Save(Save.getDefault());
    }
    else
    {
      // Sometimes the Haxe serializer has issues with the version, so we fix it here.
      version = VersionUtil.repairVersion(version);
      if (VersionUtil.validateVersion(version, Save.SAVE_DATA_VERSION_RULE))
      {
        // Import the structured data.
        var saveDataWithDefaults:RawSaveData = cast thx.Objects.deepCombine(Save.getDefault(), inputData);
        return new Save(saveDataWithDefaults);
      }
      else
      {
        var message:String = "Error migrating save data, expected ${Save.SAVE_DATA_VERSION}.";
        archiveInvalidSaveData(inputData, message);
        lime.app.Application.current.window.alert("An error occurred migrating your save data.\n${message}\nInvalid data has been archived.",
          "Save Data Failure");
        return new Save(Save.getDefault());
      }
    }
  }

  /**
   * Migrate from 1.x to the latest version.
   */
  public static function migrateFromLegacy(inputData:Dynamic):Save
  {
    var inputSaveData:RawSaveData_v1_0_0 = cast inputData;

    var result:Save = new Save(Save.getDefault());

    result.volume = inputSaveData.volume;
    result.mute = inputSaveData.mute;

    // result.ngSessionId = inputSaveData.sessionId;

    migrateLegacyScores(result, inputSaveData);

    migrateLegacyControls(result, inputSaveData);

    return result;
  }

  static function archiveInvalidSaveData(data:Dynamic, reason:String):Void
  {
    trace("[SAVE] Archiving invalid save data due to: " + reason);

    // Ensure save directory exists
    if (!FileSystem.exists(Save.SAVE_DIRECTORY))
    {
      FileSystem.createDirectory(Save.SAVE_DIRECTORY);
    }

    // Create a timestamped archive file
    var timestamp:String = Date.now().toString().replace(":", "-");
    var archiveFile:String = Save.SAVE_DIRECTORY + "/invalid_save_" + timestamp + ".json";

    try
    {
      var saveJson = Json.stringify(data, '\t');
      File.saveContent(archiveFile, saveJson);
      trace("[SAVE] Invalid save data archived to: " + archiveFile);
    }
    catch (e:Dynamic)
    {
      trace("[SAVE] Failed to archive invalid save data: " + e);
    }
  }

  static function migrateLegacyScores(result:Save, inputSaveData:RawSaveData_v1_0_0):Void
  {
    // Legacy score migration logic
    if (inputSaveData.songCompletion == null)
    {
      inputSaveData.songCompletion = [];
    }

    if (inputSaveData.songScores == null)
    {
      inputSaveData.songScores = [];
    }

    for (levelId in ["week0", "week1", "week2", "week3", "week4", "week5", "week6", "week7"])
    {
      migrateLegacyLevelScore(result, inputSaveData, levelId);
    }

    for (songIdGroup in [
      ["tutorial", "Tutorial"],
      ["bopeebo", "Bopeebo"],
      ["fresh", "Fresh"],
      ["dadbattle", "Dadbattle"],
      ["monster", "Monster"],
      ["south", "South"],
      ["spookeez", "Spookeez"],
      ["pico", "Pico"],
      ["philly-nice", "Philly", "philly", "Philly-Nice"],
      ["blammed", "Blammed"],
      ["satin-panties", "Satin-Panties"],
      ["high", "High"],
      ["milf", "Milf", "MILF"],
      ["cocoa", "Cocoa"],
      ["eggnog", "Eggnog"],
      ["winter-horrorland", "Winter-Horrorland"],
      ["senpai", "Senpai"],
      ["roses", "Roses"],
      ["thorns", "Thorns"],
      ["ugh", "Ugh"],
      ["guns", "Guns"],
      ["stress", "Stress"]
    ])
    {
      migrateLegacySongScore(result, inputSaveData, songIdGroup);
    }
  }

  static function migrateLegacyLevelScore(result:Save, inputSaveData:RawSaveData_v1_0_0, levelId:String):Void
  {
    // Migrate scores for each difficulty
    for (difficulty in ["easy", "normal", "hard"])
    {
      var key:String = (difficulty == "normal") ? levelId : "${levelId}-${difficulty}";
      var score:SaveScoreData =
        {
          score: Std.int(inputSaveData.songScores.get(key) ?? 0),
          tallies:
            {
              sick: 0,
              good: 0,
              bad: 0,
              shit: 0,
              missed: 0,
              combo: 0,
              maxCombo: 0,
              totalNotesHit: 0,
              totalNotes: 0
            }
        };
      result.setLevelScore(levelId, difficulty, score);
    }
  }

  static function migrateLegacySongScore(result:Save, inputSaveData:RawSaveData_v1_0_0, songIds:Array<String>):Void
  {
    for (difficulty in ["easy", "normal", "hard"])
    {
      var score:SaveScoreData =
        {
          score: 0,
          tallies:
            {
              sick: 0,
              good: 0,
              bad: 0,
              shit: 0,
              missed: 0,
              combo: 0,
              maxCombo: 0,
              totalNotesHit: 0,
              totalNotes: 0,
            }
        };

      for (songId in songIds)
      {
        var key:String = (difficulty == "normal") ? songId : "${songId}-${difficulty}";
        score.score = Std.int(Math.max(score.score, inputSaveData.songScores.get(key) ?? 0));
      }

      result.setSongScore(songIds[0], difficulty, score);
    }
  }

  static function migrateLegacyControls(result:Save, inputSaveData:RawSaveData_v1_0_0):Void
  {
    var p1Data = inputSaveData?.controls?.p1;
    if (p1Data != null)
    {
      migrateLegacyPlayerControls(result, 1, p1Data);
    }

    var p2Data = inputSaveData?.controls?.p2;
    if (p2Data != null)
    {
      migrateLegacyPlayerControls(result, 2, p2Data);
    }
  }

  static function migrateLegacyPlayerControls(result:Save, playerId:Int, controlsData:SavePlayerControlsData_v1_0_0):Void
  {
    var outputKeyControls:SaveControlsData =
      {
        ACCEPT: controlsData?.keys?.ACCEPT ?? null,
        BACK: controlsData?.keys?.BACK ?? null,
        CUTSCENE_ADVANCE: controlsData?.keys?.CUTSCENE_ADVANCE ?? null,
        NOTE_DOWN: controlsData?.keys?.NOTE_DOWN ?? null,
        NOTE_LEFT: controlsData?.keys?.NOTE_LEFT ?? null,
        NOTE_RIGHT: controlsData?.keys?.NOTE_RIGHT ?? null,
        NOTE_UP: controlsData?.keys?.NOTE_UP ?? null,
        PAUSE: controlsData?.keys?.PAUSE ?? null,
        RESET: controlsData?.keys?.RESET ?? null,
        UI_DOWN: controlsData?.keys?.UI_DOWN ?? null,
        UI_LEFT: controlsData?.keys?.UI_LEFT ?? null,
        UI_RIGHT: controlsData?.keys?.UI_RIGHT ?? null,
        UI_UP: controlsData?.keys?.UI_UP ?? null,
        VOLUME_DOWN: controlsData?.keys?.VOLUME_DOWN ?? null,
        VOLUME_MUTE: controlsData?.keys?.VOLUME_MUTE ?? null,
        VOLUME_UP: controlsData?.keys?.VOLUME_UP ?? null,
      };

    result.setControls(playerId, Keys, outputKeyControls);

    var outputPadControls:SaveControlsData =
      {
        ACCEPT: controlsData?.pad?.ACCEPT ?? null,
        BACK: controlsData?.pad?.BACK ?? null,
        CUTSCENE_ADVANCE: controlsData?.pad?.CUTSCENE_ADVANCE ?? null,
        NOTE_DOWN: controlsData?.pad?.NOTE_DOWN ?? null,
        NOTE_LEFT: controlsData?.pad?.NOTE_LEFT ?? null,
        NOTE_RIGHT: controlsData?.pad?.NOTE_RIGHT ?? null,
        NOTE_UP: controlsData?.pad?.NOTE_UP ?? null,
        PAUSE: controlsData?.pad?.PAUSE ?? null,
        RESET: controlsData?.pad?.RESET ?? null,
        UI_DOWN: controlsData?.pad?.UI_DOWN ?? null,
        UI_LEFT: controlsData?.pad?.UI_LEFT ?? null,
        UI_RIGHT: controlsData?.pad?.UI_RIGHT ?? null,
        UI_UP: controlsData?.pad?.UI_UP ?? null,
        VOLUME_DOWN: controlsData?.pad?.VOLUME_DOWN ?? null,
        VOLUME_MUTE: controlsData?.pad?.VOLUME_MUTE ?? null,
        VOLUME_UP: controlsData?.pad?.VOLUME_UP ?? null,
      };

    result.setControls(playerId, Gamepad(0), outputPadControls);
  }
}
