package funkin.play.event;

// Data from the chart
import funkin.data.song.SongData;
import funkin.data.song.SongData.SongEventData;
// Data from the event schema
import funkin.play.event.SongEvent;
import funkin.data.event.SongEventSchema;
import funkin.data.event.SongEventSchema.SongEventFieldType;

class ChangeCharacterSongEvent extends SongEvent
{
  public function new()
  {
    super('ChangeCharacter');
  }

  static final DEFAULT_CHARACTERTYPE:String = 'Boyfriend';
  static final DEFAULT_NEWCHAR:String = 'bf';

  public override function handleEvent(data:SongEventData):Void
  {
    // Does nothing if there is no PlayState camera or stage.
    if (PlayState.instance == null || PlayState.instance.currentStage == null) return;

    // Does nothing if we are minimal mode.
    if (PlayState.instance.isMinimalMode) return;

    var characterType:String = data.getString('characterType') ?? DEFAULT_CHARACTERTYPE;
    var newCharacter:String = data.getString('newCharacter') ?? DEFAULT_NEWCHAR;

    PlayState.instance.switchCharacter(characterType, newCharacter);
  }

  public override function getTitle():String
  {
    return 'Change Character';
  }

  public override function getEventSchema():SongEventSchema
  {
    return new SongEventSchema([
      {
        name: 'characterType',
        title: 'Character Type',
        defaultValue: 'Boyfriend',
        type: SongEventFieldType.ENUM,
        keys: ['BF' => 'boyfriend', 'GF' => 'girlfriend', 'Dad' => 'dad']
      },
      {
        name: 'newCharacter',
        title: 'New Character ID',
        defaultValue: 'bf',
        type: SongEventFieldType.STRING,
      }
    ]);
  }
}
