

import com.stencyl.graphics.G;
import com.stencyl.graphics.BitmapWrapper;

import com.stencyl.behavior.Script;
import com.stencyl.behavior.Script.*;
import com.stencyl.behavior.ActorScript;
import com.stencyl.behavior.SceneScript;
import com.stencyl.behavior.TimedTask;

import com.stencyl.models.Actor;
import com.stencyl.models.GameModel;
import com.stencyl.models.actor.Animation;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.actor.Collision;
import com.stencyl.models.actor.Group;
import com.stencyl.models.Scene;
import com.stencyl.models.Sound;
import com.stencyl.models.Region;
import com.stencyl.models.Font;
import com.stencyl.models.Joystick;

import com.stencyl.Engine;
import com.stencyl.Input;
import com.stencyl.Key;
import com.stencyl.utils.Utils;

import openfl.ui.Mouse;
import openfl.display.Graphics;
import openfl.display.BlendMode;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.TouchEvent;
import openfl.net.URLLoader;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.joints.B2Joint;

import com.stencyl.utils.motion.*;



class ParticleImage {
    public var image: ImageX;
    public var age: Float = 0;
    public var speedX: Float;
    public var speedY: Float;
    public var opacitySpeed: Float = 0;

    public function new(img) {
        image = img;
    }
}



class ParticleSpawner {

    var constants = {
        ageImagesFrequency: 20
    }

    var timeSinceLastSpawn: Float = 0;

    public var isEnabled = true;

    public var centerX: Float = 0;
    public var centerY: Float = 0;
    public var radius: Float = 10;
    public var frequency: Float = 1000;
    public var imageLifetime: Float = 1000;
    public var sizeMin: Float = 1;
    public var sizeMax: Float = 1;
    public var hasRandomRotation: Bool = false;
    public var rotationSpeed: Float = 0;
    public var direction: Float = 0;           // Angle
    public var directionVariance: Float = 0;   // + / - an amount from direction
    public var directionSpreads: Bool = false;  // If true, the angle of the particle directions will always seem to originate from the center
    public var speedMin: Float = 0;            // Pixels per second
    public var speedMax: Float = 0;            // Pixels per second
    public var opacityStart: Float = 1;
    public var opacityEnd: Float = 1;
    public var gravityX: Float = 0;
    public var gravityY: Float = 0;

    var bitmapData: BitmapData;

    var imagesQueue: Array<ParticleImage>;

    function spawnImage() {
        function sin(angle: Float) return Math.sin(angle * Utils.RAD);
        function cos(angle: Float) return Math.cos(angle * Utils.RAD);
        var img = new ImageX(bitmapData, 'Particles');
        var particle = new ParticleImage(img);
        var spawnRadius = radius;//randomFloatBetween(0, radius);
        var spawnAngle: Float;
        if (directionSpreads) {
            spawnAngle = direction + randomFloatBetween(-directionVariance, directionVariance);
        } else {
            spawnAngle = Utils.DEG * randomInt(0, 360);
        }
        var cx = spawnRadius * cos(spawnAngle) + centerX;
        var cy = spawnRadius * sin(spawnAngle) + centerY;
        var newScale = img.image.scaleX * randomFloatBetween(sizeMin, sizeMax);
        var particleDirection : Float;
        if (directionSpreads) {
            particleDirection = spawnAngle;
        } else {
            particleDirection = direction + randomFloatBetween(-directionVariance, directionVariance);
        }
        var ticksPerSeconds = 1000 / constants.ageImagesFrequency;
        var particleSpeed = randomFloatBetween(speedMin, speedMax);
        var pixelsPerTick = particleSpeed / ticksPerSeconds;
        var speedX = pixelsPerTick * cos(particleDirection);
        var speedY = pixelsPerTick * sin(particleDirection);
        var ticksPerLifetime = imageLifetime / constants.ageImagesFrequency;
        var opacityDelta = opacityEnd - opacityStart;
        var opacityDeltaPerTick = opacityDelta / ticksPerLifetime;
        img.setOriginToCenter();
        img.setX(cx);
        img.setY(cy);
        img.image.scaleX = newScale;
        img.image.scaleY = newScale;
        if (hasRandomRotation) img.setAngle(randomFloatBetween(0, 360));
        particle.speedX = speedX;
        particle.speedY = speedY;
        particle.opacitySpeed = opacityDeltaPerTick;
        imagesQueue.push(particle);
        timeSinceLastSpawn = 0;
    }

    function trySpawnImage() {
        if (!isEnabled) return;
        if (timeSinceLastSpawn >= frequency) spawnImage();
        else timeSinceLastSpawn += 20;
    }

    function ageImages() {
        for (particle in imagesQueue) {
            particle.age += constants.ageImagesFrequency;
            particle.image.setAngle(particle.image.getAngle() + rotationSpeed);
            particle.image.addX(particle.speedX);
            particle.image.addY(particle.speedY);
            particle.image.addAlpha(particle.opacitySpeed);
            particle.speedX += gravityX;
            particle.speedY += gravityY;
            if (particle.age >= imageLifetime) {
                particle.image.kill();
                imagesQueue.remove(particle);
            }
        }
    }

    public function new(centerX: Float, centerY: Float, ?settings: Dynamic) {
        this.centerX        = centerX;
        this.centerY        = centerY;
        if (settings != null)
            setFromDynamic(settings);
        else
            disable();

        imagesQueue = [];
        U.repeat(trySpawnImage, constants.ageImagesFrequency);
        U.repeat(ageImages, constants.ageImagesFrequency);
    }

    public function setFromDynamic(settings: Dynamic) {
        if (settings.radius != null) radius = settings.radius;
        if (settings.frequency != null) frequency = settings.frequency;
        if (settings.sizeMin != null) sizeMin = settings.sizeMin;
        if (settings.sizeMax != null) sizeMax = settings.sizeMax;
        if (settings.hasRandomRotation != null) hasRandomRotation = settings.hasRandomRotation;
        if (settings.rotationSpeed != null) rotationSpeed = settings.rotationSpeed;
        if (settings.imageLifetime != null) imageLifetime = settings.imageLifetime;
        if (settings.direction != null) direction = -settings.direction;
        if (settings.directionVariance != null) directionVariance = settings.directionVariance;
        trace('Direction spreads: ${directionSpreads}');
        if (settings.directionSpreads != null) {
            trace('Direction spreads settings NOT NULL: ${settings.directionSpreads}');
            directionSpreads = settings.directionSpreads;
        }
        trace('Direction spreads: ${directionSpreads}');
        if (settings.speedMin != null) speedMin = settings.speedMin;
        if (settings.speedMax != null) speedMax = settings.speedMax;
        if (settings.opacityStart != null) opacityStart = settings.opacityStart;
        if (settings.opacityEnd != null) opacityEnd = settings.opacityEnd;
        if (settings.gravityX != null) gravityX = settings.gravityX;
        if (settings.gravityY != null) gravityY = settings.gravityY;
        trace('Settings:');
        trace(settings);
        trace('Getting image: ${settings.imagePath}');
        bitmapData          = getExternalImage(settings.imagePath);
    }

    public inline function enable() isEnabled = true;
    public inline function disable() isEnabled = false;
    public inline function setX(x) centerX = x;
    public inline function setY(y) centerY = y;

    public function burst(nParticles: Int) {
        for (_ in 0...nParticles) spawnImage();
    }

}
