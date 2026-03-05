package objects;

// Made by Vaesea, fixed by AnatolyStev
// Well actually it came from Discover Haxeflixel but still

// Snow Brick Blocks have been deleted.

import characters.player.Tux;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.particles.FlxParticle;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import objects.Coin;

class EmptyNormalBrickBlock extends FlxSprite
{
    var scoreAmount = 25;
    var gravity = 1000;

    var brickImage = FlxAtlasFrames.fromSparrow('assets/images/objects/bonus/brick.png', 'assets/images/objects/bonus/brick.xml');
    
    public function new(x:Float, y:Float)
    {
        super(x, y);
        immovable = true;

        frames = brickImage;
        animation.addByPrefix('normal', 'normal', 12, false);
        animation.play("normal");
    }

    // TODO: is this needed??? 3:
    override public function update(elapsed:Float)
    {
        if (isOnScreen())
        {
            super.update(elapsed);
        }
    }
    
    public function hit(tux:Tux)
    {
        if (tux.currentState == Small && (tux.isTouching(UP) || tux.wasTouching == UP))
        {
            var currentY = y;
            FlxTween.tween(this, {y: currentY - 4}, 0.05)
            .wait(0.05)
            .then(FlxTween.tween(this, {y: currentY}, 0.05));
            return;
        }

        if (tux.isTouching(UP) || tux.wasTouching == UP)
        {
            FlxObject.separateY(this, tux);
            Global.score += scoreAmount;
            FlxG.sound.play('assets/sounds/brick.wav');
            
            for (i in 0...4)
            {
                var debris:FlxParticle = new FlxParticle();
                debris.loadGraphic('assets/images/particles/brick.png', true, 8, 8);
                debris.animation.add("rotate", [0, 1], 16, true);
                debris.animation.play("rotate");

                var countX = (i % 2 == 0) ? 1 : -1;
                var countY = (Math.floor(i / 2)) == 0 ? -1 : 1;

                debris.setPosition(4 + x + countX * 4, 4 + y + countY * 4);
                debris.lifespan = 6;
                debris.acceleration.y = gravity;
                debris.velocity.y = -160 + (10 * countY);
                debris.velocity.x = 40 * countX;
                debris.exists = true;

                Global.PS.add(debris);
            }

            kill();
        }
    }
}

class CoinNormalBrickBlock extends FlxSprite
{
    var scoreAmount = 25;
    var gravity = 1000;

    var howManyHits = 5;
    var isHit = false;

    var brickCoinImage = FlxAtlasFrames.fromSparrow('assets/images/objects/bonus/brick.png', 'assets/images/objects/bonus/brick.xml');
    
    public function new(x:Float, y:Float)
    {
        super(x, y);
        solid = true;
        immovable = true;

        frames = brickCoinImage;
        animation.addByPrefix('normal', 'normal', 12, false);
        animation.addByPrefix('empty', 'empty', 12, false);
        animation.play("normal");
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (howManyHits == 0)
        {
            animation.play("empty");
        }
    }
    
    public function hit(tux:Tux)
    {
        if (isHit)
        {
            return;
        }

        if (howManyHits > 0 && (tux.isTouching(UP) || tux.wasTouching == UP))
        {
            FlxObject.separateY(this, tux);
            var currentY = y;
            howManyHits -= 1;
            isHit = true;
            FlxTween.tween(this, {y: currentY - 4}, 0.05)
            .wait(0.05)
            .then(FlxTween.tween(this, {y: currentY}, 0.05, {onComplete: function (_)
            {
                isHit = false;
            }}));
            createItem();
        }
    }

    function createItem()
    {
        FlxG.sound.play('assets/sounds/brick.wav');
        var coin:Coin = new Coin(Std.int(x), Std.int(y - 32));
        coin.setFromBlock();
        Global.PS.items.add(coin);
    }
}