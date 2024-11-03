package funkin.ui.options.items;

import flixel.FlxSprite.FlxSprite;

class CheckboxPreferenceItem extends FlxSprite
{
  public var currentValue(default, set):Bool;
  public var label:String; // Add a label property to identify this preference

  public function new(x:Float, y:Float, defaultValue:Bool = false, label:String)
  {
    super(x, y);

    this.label = label; // Set the label

    frames = Paths.getSparrowAtlas('checkboxThingie');
    animation.addByPrefix('static', 'Check Box unselected', 24, false);
    animation.addByPrefix('checked', 'Check Box selecting animation', 24, false);

    setGraphicSize(Std.int(width * 0.7));
    updateHitbox();

    this.currentValue = defaultValue;
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    switch (animation.curAnim.name)
    {
      case 'static':
        offset.set();
      case 'checked':
        offset.set(17, 70);
    }
  }

  function set_currentValue(value:Bool):Bool
  {
    if (value)
    {
      animation.play('checked', true);
    }
    else
    {
      animation.play('static');
    }

    return currentValue = value;
  }
}
