package characters.player;

import characters.enemies.Enemy;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

enum TuxStates
{
    Small;
    Big;
    Fire;
}

class Tux extends FlxSprite
{
    // Movement
    var tuxAcceleration = 2000;
    var deceleration = 1000;
    var gravity = 1000;
    public var minJumpHeight = 512;
    public var maxJumpHeight = 576;
    var walkSpeed = 230;
    var speed = 0;
    var runSpeed = 320;
    var decelerateOnJumpRelease = 0.5;
    
    // Current State
    public var currentState = Small;

    // (Added by AnatolyStev) Ducking
    var isDucking = false;

    // (Added by AnatolyStev) Holding enemies
    public var heldEnemy:Enemy = null;

    // Direction
    public var direction = 1;

    // Fireball stuff
    var canShoot = true;
    var shootCooldown = 0.5;

    // Invincibility Power-Up (Herring)
    var herringDuration = 14.0;
    public var invincible = false;
    var smallStars:FlxSprite;
    var bigStars:FlxSprite;

    // "Health" stuff
    var canTakeDamage = true;
    var invFrames = 1.0;

    // Spritesheet (finally), if replaced, make sure the replacement image has the same animations!
    var smallTuxImage = FlxAtlasFrames.fromSparrow("assets/images/characters/tux/smalltux.png", "assets/images/characters/tux/smalltux.xml");

    public function new()
    {
        super();

        // Spritesheet
        frames = smallTuxImage;
        animation.addByPrefix("stand", "stand", 10, false);
        animation.addByPrefix("walk", "walk", 10, true);
        animation.addByPrefix("jump", "jump", 10, false);
        animation.play("stand");
        
        // Add deceleration, gravity and make sure Tux is not like Sonic
        drag.x = deceleration;
        acceleration.y = gravity;

        // Hitbox
        setSize(27, 32);
        offset.set(8, 9);

        reloadGraphics();
    }


    override public function update(elapsed:Float)
    {
        // Stop Tux from falling off the map through the left side of the map
        if (x < 0)
        {
            x = 0;
        }

        // Kill Tux when he falls into the void
        if (y > Global.PS.map.height - height)
        {
            die();
        }

        // Functions
        move();
        animate();
        shootFire();

        if (heldEnemy != null)
        {
            if (FlxG.keys.justReleased.CONTROL)
            {
                throwEnemy();
            }
        }

        // Put this after everything
        super.update(elapsed);
    }

    function animate()
    {
        // If Tux is on the floor and staying where he is, stand.
        if (velocity.x == 0 && isTouching(FLOOR))
        {
            animation.play("stand");
        }

        // if Tux is on the floor and moving, walk.
        if (velocity.x != 0 && isTouching(FLOOR))
        {
            animation.play("walk");
        }

        // If Tux is not on the floor, jump
        // TODO: Is velocity.y != 0 needed?
        if (velocity.y != 0 && !isTouching(FLOOR))
        {
            animation.play("jump");
        }
    }

    function move()
    {
        // Speed is 0 at beginning
        acceleration.x = 0;

        if (FlxG.keys.pressed.CONTROL) // Running
        {
            speed = runSpeed;
        }
        else // Walking
        {
            speed = walkSpeed;
        }

        maxVelocity.x = speed; // Tux should not be like Sonic.

        // If player presses left keys, move left, if player presses right keys, move right.
        if (FlxG.keys.anyPressed([LEFT, A]))
        {
            flipX = true; // TODO: Shouldn't this be in animate function?
            direction = -1;
            acceleration.x -= tuxAcceleration;
        }
        else if (FlxG.keys.anyPressed([RIGHT, D]))
        {
            flipX = false;
            direction = 1;
            acceleration.x += tuxAcceleration;
        }

        // If player pressing jump keys and is on ground, jump. 
        // If player is walking at the speed of walkSpeed, jump higher than usual.
        if (FlxG.keys.anyJustPressed([SPACE, W, UP]) && isTouching(FLOOR))
        {
            if (velocity.x == runSpeed || velocity.x == -runSpeed)
            {
                velocity.y = -maxJumpHeight;
            }
            else
            {
                velocity.y = -minJumpHeight;
            }

            // If current state is small, play small jump sound.
            // If current state is not small, play big jump sound.
            if (currentState == Small)
            {
                FlxG.sound.play("assets/sounds/jump.wav");
            }
            else
            {
                FlxG.sound.play("assets/sounds/bigjump.wav");
            }
        }

        if (velocity.y < 0 && FlxG.keys.anyJustReleased([SPACE, W, UP]))
        {
            velocity.y -= velocity.y * decelerateOnJumpRelease;
        }
    }

    public function holdEnemy(enemy:Enemy)
    {
        // If there's already a held enemy, return.
        if (heldEnemy != null)
        {
            return;
        }

        // If there's no held enemy and player is pressing control, pick up enemy.
        if (FlxG.keys.pressed.CONTROL)
        {
            heldEnemy = enemy;
            enemy.pickUp(this);
        }
    }

    public function throwEnemy()
    {
        // If there's no held enemy, don't do the rest of the function.
        if (heldEnemy == null)
        {
            return;
        }

        // Throw enemy
        heldEnemy.enemyThrow();
        heldEnemy = null;
    }

    public function takeDamage() //  Makes Tux take damage.
    {
        if (canTakeDamage == true)
        {
            canTakeDamage = false;
            FlxTween.flicker(this, invFrames, 0.1, {type: ONESHOT});
            new FlxTimer().start(invFrames, function(_) {canTakeDamage = true;}, 1);
            FlxG.sound.play('assets/sounds/hurt.wav');
            
            if (currentState == Fire) // If current state is fire, make him go down to just being big.
            {
                currentState = Big;
                reloadGraphics();
            }
            else if (currentState == Big) // If current state is big, make him go down to just being small.
            {
                var prevBottom = y + height;
                currentState = Small;
                reloadGraphics();
                y = prevBottom - height;
            }
            else if (currentState == Small) // If current state is small, kill him.
            {
                die();
            }
        }
    }

    public function bigTux()
    {
        if (currentState == Small)
        {
            var smallHeight = height;
            currentState = Big;
            reloadGraphics();
            y -= height - smallHeight;
        }
    }

    public function fireTux()
    {
        if (currentState == Small)
        {
            var smallHeight = height;
            currentState = Fire;
            reloadGraphics();
            y -= height - smallHeight;
        }
        else
        {
            currentState = Fire;
            reloadGraphics();
        }
    }

    public function herringTux()
    {
        var previousSong = Global.currentSong;

        FlxG.sound.play("assets/sounds/herring.wav", 1, false);
        FlxG.sound.playMusic("assets/music/salcon.ogg", 1, true);

        invincible = true;

        new FlxTimer().start(herringDuration, function(_)
        {
            FlxG.sound.playMusic(previousSong, 1.0, true);
            invincible = false;
        });
    }

    function shootFire()
    {
        if (currentState != Fire)
        {
            return;
        }

        if (FlxG.keys.justPressed.CONTROL && canShoot)
        {
            var fireball:Fireball = new Fireball(x + 16, y + 16);
            fireball.direction = direction;
            Global.PS.items.add(fireball);
            FlxG.sound.play("assets/sounds/shoot.wav");

            canShoot = false;
            new FlxTimer().start(shootCooldown, function(_) canShoot = true);
        }
    }

    public function die()
    {
        currentState = Small;
        Global.tuxState = Small;
        canTakeDamage = false;
        Global.lives -= 1;
        Global.coins = 0;
        FlxG.resetState();
    }

    // copied from peppertux, public due to playstate using it
    public function reloadGraphics()
    {
        animation.reset();

        switch(currentState)
        {
            case Small:
                var fixedMaybeOne = FlxAtlasFrames.fromSparrow("assets/images/characters/tux/smalltux.png", "assets/images/characters/tux/smalltux.xml");
                frames = fixedMaybeOne;

                animation.addByPrefix('stand', 'stand', 10, false);
                animation.addByPrefix('walk', 'walk', 10, true);
                animation.addByPrefix('jump', 'jump', 10, false);
                animation.play('stand');

                setSize(27, 32);
                offset.set(8, 9);

            case Big:
                var fixedMaybeTwo = FlxAtlasFrames.fromSparrow("assets/images/characters/tux/bigtux.png", "assets/images/characters/tux/bigtux.xml");
                frames = fixedMaybeTwo;
                animation.addByPrefix('stand', 'stand', 10, false);
                animation.addByPrefix('walk', 'walk', 10, true);
                animation.addByPrefix('jump', 'jump', 10, false);
                animation.addByPrefix('duck', 'duck', 10, false);
                animation.play('stand');
                setSize(30, 63);
                offset.set(10, 4);
                
            case Fire:
                var fixedMaybeThree = FlxAtlasFrames.fromSparrow("assets/images/characters/tux/firetux.png", "assets/images/characters/tux/firetux.xml");
                frames = fixedMaybeThree;
                animation.addByPrefix('stand', 'stand', 10, false);
                animation.addByPrefix('walk', 'walk', 10, true);
                animation.addByPrefix('jump', 'jump', 10, false);
                animation.addByPrefix('duck', 'duck', 10, false);
                animation.play('stand');
                setSize(30, 63);
                offset.set(10, 4);
        }
    }
}