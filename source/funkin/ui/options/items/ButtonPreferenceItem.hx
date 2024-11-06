package funkin.ui.options.items;

import funkin.ui.AtlasText;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;

/**
 * Allows easy actions to be called upon pressing a button.
 */
class ButtonPreferenceItem extends FlxSprite
{
  public var label:String;

  public function new(x:Float, y:Float, label:String)
  {
    super(x, y);

    this.label = label;

    setGraphicSize(Std.int(width * 0.7));
    updateHitbox();
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);
  }
}
