package characters.enemies;

// made by vaesea and anatolystev (mostly anatolystev)
// might be the worst code in the entire game, please remind me or anatolystev to put a better fix later.
// also might be the most boring boss ever.

import characters.player.Tux;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import worldmap.WorldMapState;

enum NolokStatesOne
{
    Normal;
    Running;
    Throwing;
}

enum NolokStatesTwo
{
    Alive;
    Dead;
}

class Nolok extends FlxSprite
{
    // Health and stuff like that
    var health = 5;
    var invFrames = 2;
    var canTakeDamage = true;

    // Movement
    var speed = 180;
    var jumpHeight = 800;
    var stompHeight = 250;
    var gravity = 1000;
    var fallForce = 128;

    // Score
    var scoreAmount = 5000;
    
    // Direction
    var direction = -1;

    // Current States
    var currentStateOne = Normal;
    var currentStateTwo = Alive;
    var changeToThrowingTimer = 0.5; // unused
    var startTimer = 2;

    // Throwing Vicious Ivys
    var nolokIsVeryBusyThrowingViciousIvysRightNow = false; // do i get a reward for this

    // Spritesheet
    var nolokImage = FlxAtlasFrames.fromSparrow("assets/images/characters/nolok.png", "assets/images/characters/nolok.xml");

    public function new(x:Float, y:Float)
    {
        super(x, y);

        // Images / Spritesheet stuff
        frames = nolokImage;
        animation.addByPrefix("stand", "stand", 10, false);
        animation.addByPrefix("walk", "walk", 10, true);
        animation.addByPrefix("throw", "throw", 10, false);
        animation.addByPrefix("fall", "fall", 10, false);
        animation.play("stand");

        // Gravity
        acceleration.y = gravity;

        // Hitbox
        setSize(48, 151);
        offset.set(33, 27);

        new FlxTimer().start(startTimer, function(_)
        {
            currentStateOne = Running;
        }, 1);
    }

    override public function update(elapsed:Float)
    {
        // apparently putting random stuff in update = bad
        if (currentStateTwo == Alive)
        {
            updateState();
        }

        trace(currentStateOne);

        super.update(elapsed);
    }

    function updateState()
    {
        switch (currentStateOne)
        {
            case Normal:
                velocity.x = 0;
                animation.play("stand");

            case Running:
                velocity.x = direction * speed;
                animation.play("walk");

                if ((direction == -1 && isTouching(LEFT)) || (direction == 1 && isTouching(RIGHT))) // i swear to god this has to be the worst fix of all time...
                {
                    flipDirection();
                    currentStateOne = Throwing;
                }

            case Throwing:
                velocity.x = 0;
                if (!nolokIsVeryBusyThrowingViciousIvysRightNow)
                {
                    nolokIsVeryBusyThrowingViciousIvysRightNow = true;
                    animation.play("stand");
                    
                    new FlxTimer().start(1, function(_)
                    {
                        throwViciousIvy();
                        new FlxTimer().start(1, function(_)
                        {
                            throwViciousIvy();
                            new FlxTimer().start(2, function(_)
                            {
                                nolokIsVeryBusyThrowingViciousIvysRightNow = false; // amazing variable name i think
                                currentStateOne = Running;
                            }, 1);
                        }, 1);
                    }, 1);
                }
        }
    }

    function throwViciousIvy()
    {
        animation.play("throw");
        var viciousIvy:ViciousIvy = new ViciousIvy(this.x + 24, this.y + 75);
        viciousIvy.direction = this.direction;
        viciousIvy.flipX = this.flipX;
        Global.PS.enemies.add(viciousIvy);
        new FlxTimer().start(0.2, function(_)
        {
            animation.play("stand");
        }, 1);
    }

    function flipDirection()
    {
        flipX = !flipX;
        direction = -direction;
    }

    public function interact(tux:Tux)
    {
        var tuxStomp = (tux.velocity.y > 0 && tux.y + tux.height < y + 10); // This checks for Tux stomping the enemy... or does it?

        if (currentStateTwo != Alive)
        {
            return;
        }

        if (tuxStomp && canTakeDamage && currentStateOne == Running) // Can't just do the simple isTouching UP thing because then if the player hits the corner of the enemy, they take damage. That's not exactly fair.
        {
            tux.y = y - tux.height - 1; // prevent falling into boss otherwise tux would be damaged. i know this looks like an ai ass solution but it's good enough for now.

            if (FlxG.keys.anyPressed([SPACE, UP, W]))
            {
                tux.velocity.y = -tux.maxJumpHeight;
            }
            else
            {
                tux.velocity.y = -tux.minJumpHeight / 2;
            }

            health -= 1;
            canTakeDamage = false;

            if (health <= 0)
            {
                die(tux);
            }

            FlxTween.flicker(this, invFrames, 0.1, {type: ONESHOT});

            new FlxTimer().start(invFrames, function(_)
            {
                canTakeDamage = true;
            }, 1);

            return; // this has to be here to stop tux from taking damage if he hit nolok without being hit
        }

        // well hopefully this fixes it!
        if (!tuxStomp && currentStateTwo == Alive)
        {
            tux.takeDamage();
        }
    }

    public function die(tux:Tux)
    {
        Global.score += scoreAmount;
        flipY = true;
        velocity.y = -fallForce;
        solid = false;

        if (FlxG.sound.music != null) // Check if song is playing, if it is, stop song.
        {
            FlxG.sound.music.stop();
        }

        new FlxTimer().start(1, function(_)
        {
            FlxG.sound.playMusic("assets/music/leveldone-special.ogg", 1.0, true);

            Global.tuxState = tux.currentState;

            if (!Global.completedLevels.contains(Global.currentLevel))
            {
                Global.completedLevels.push(Global.currentLevel);
            }

            new FlxTimer().start(8, function(_)
            {
                Global.saveProgress();
                FlxG.switchState(WorldMapState.new);
            }, 1);
        }, 1);
    }
}