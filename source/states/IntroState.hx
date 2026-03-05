package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import worldmap.WorldMapState;

class IntroState extends FlxState
{
    var introText:FlxText;

    var speed = 20;
    var increaseOrDecreaseSpeed = 10;

    override public function create()
    {
        super.create();

        var bg = new FlxSprite();
        bg.loadGraphic("assets/images/background/extro.png", false);
        add(bg);
        
        introText = new FlxText(-65, 480, 0, "
        Entering Nolok's Throne Room
        
        Tux ran into Nolok's throne room, frantically 
        searching for his beloved.
        
        Alas, he found neither Penny nor Nolok there, 
        but instead, another note.
        
        The note told Tux that if he was reading this,
        he had removed Nolok's control over this icy
        fortress. But as he could see, his beloved
        Penny is not here. What Tux did not realize is
        that this is just one of Nolok's many 
        fortresses, spread far across the lands!
        
        The note said that Tux's ambition is most 
        honorable, but futile nonetheless. With every 
        one of Nolok's fortresses that Tux conquers, 
        Nolok will escape to another, and take Penny 
        with him. The note said to Tux to not be silly, 
        and it said that it is best that Tux gives up 
        now.
        
        Tux was sadly leaving the room, when he felt 
        something beneath his foot... an envelope, 
        addressed to him! Inside was a roughly sketched 
        map with fortresses drawn in various lands. On 
        the corner of the map was Penny's signature, a 
        drawing of the fire flower.
        
        Tux ran out of the fortress, map in hand. No, he 
        decided, he would not give up. Penny was counting 
        on him.
        
        He knew where to go next due to the map. It was a
        forest with dangerous enemies, and a castle at the 
        end. But no, as stated earlier, he would not give 
        up. Penny was counting on him to not give up, so he 
        wouldn't. He got on a boat and went to the Forest 
        World.


        
        SuperTux - Milestone Mix - Chapter 1
        
        Press SPACE to go to the worldmap.", 18);
        introText.setFormat("assets/fonts/SuperTux-Medium.ttf", 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        introText.borderSize = 1.25;
        introText.moves = true;
        introText.velocity.y = -speed;
        add(introText);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.SPACE)
        {
            FlxG.switchState(WorldMapState.new); // Switch State
        }
        
        if (FlxG.keys.justPressed.DOWN)
        {
            introText.velocity.y -= increaseOrDecreaseSpeed;
        }
        else if (FlxG.keys.justPressed.UP)
        {
            introText.velocity.y += increaseOrDecreaseSpeed;
        }
    }
}