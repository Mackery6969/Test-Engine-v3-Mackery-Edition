package funkin.play.event;

// Data from the chart
import funkin.data.song.SongData;
import funkin.data.song.SongData.SongEventData;
// Data from the event schema
import funkin.play.event.SongEvent;
import funkin.data.event.SongEventSchema;
import funkin.data.event.SongEventSchema.SongEventFieldType;

class ScreenShakeSongEvent extends SongEvent
{
  public function new()
  {
    super('ScreenShake');
  }

  static final DEFAULT_DURATION:Float = 4.0;
  static final DEFAULT_INTENSITY:Float = 0.02;

  public override function handleEvent(data:SongEventData):Void
  {
    // Does nothing if there is no PlayState camera or stage.
    if (PlayState.instance == null || PlayState.instance.currentStage == null) return;

    // Does nothing if we are minimal mode.
    if (PlayState.instance.isMinimalMode) return;

    var duration:Float = data.getFloat('duration') ?? DEFAULT_DURATION;
    var intensity:Float = data.getFloat('intensity') ?? DEFAULT_INTENSITY;

    var durSeconds:Float = Conductor.instance.stepLengthMs * duration / 1000;
    PlayState.instance.shakeCamera(durSeconds, intensity);
  }

  public override function getTitle():String
  {
    return 'Shake Camera';
  }

  public override function getEventSchema():SongEventSchema
  {
    return new SongEventSchema([
      {
        name: 'duration',
        title: 'Duration',
        defaultValue: 4.0,
        step: 0.5,
        type: SongEventFieldType.FLOAT,
        units: 'steps'
      },
      {
        name: 'intensity',
        title: 'Intensity',
        defaultValue: 0.02,
        step: 0.005,
        type: SongEventFieldType.FLOAT,
        units: "x"
      }
    ]);
  }
}
