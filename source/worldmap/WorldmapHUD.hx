package worldmap;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class WorldmapHUD extends FlxState
{
    var scoreText:FlxText;
    var coinText:FlxText;
    var lifeText:FlxText; // oh for fuck sake the other HUD isn't lifeText????
    var levelNameText:FlxText;

    public function new()
    {
        super();

        // Create Score Text
        scoreText = new FlxText(4, 4, 0, "Score: " + Global.score, 18);
        scoreText.setFormat("assets/fonts/SuperTux-Medium.ttf", 18, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        scoreText.scrollFactor.set();
        scoreText.borderSize = 1.25;

        // Create Coin Text
        coinText = new FlxText(0, 4, 640, "Coins: " + Global.coins, 18);
        coinText.setFormat("assets/fonts/SuperTux-Medium.ttf", 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        coinText.scrollFactor.set();
        coinText.borderSize = 1.25;

        // Create Lives Text
        lifeText = new FlxText(-4, 4, FlxG.width, "Lives: " + Global.lives, 18);
        lifeText.setFormat("assets/fonts/SuperTux-Medium.ttf", 18, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        lifeText.scrollFactor.set();
        lifeText.borderSize = 1.25;

        // Create level name text
        levelNameText = new FlxText(0, 26, FlxG.width, Global.dotLevelName, 18);
        levelNameText.setFormat("assets/fonts/SuperTux-Medium.ttf", 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        levelNameText.scrollFactor.set();
        levelNameText.borderSize = 1.25;

        // Add all text
        add(scoreText);
        add(coinText);
        add(lifeText);
        add(levelNameText);
    }

    override public function update(elapsed:Float)
    {
        // Update Score Text
        scoreText.text = "Score:\n" + 
        StringTools.lpad(Std.string(Global.score), "0", 5);

        // Update Coin Text
        coinText.text = "Coins: " + (Global.coins);
        
        // Update Lives Text
        lifeText.text = "Lives: " + (Global.lives);

        // Update Level Name Text
        levelNameText.text = Global.dotLevelName;

        super.update(elapsed);
    }
}