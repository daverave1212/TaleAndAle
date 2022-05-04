
import com.stencyl.graphics.G;

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
import com.stencyl.utils.Utils;

import nme.ui.Mouse;
import nme.display.Graphics;

import com.stencyl.utils.motion.*;

// NOTE: Coordinates are SCREEN coordinates!!

class ScrollingTextManager_Text {
    public var text: String = '';
    public var x: Float = 0;
    public var y: Float = 0;
    public var speedY: Float = 0;
    public var gravityY: Float = 0;
    public var age: Int = 0;    // Milliseconds
    public var isAlive = true;
    public function new(_text, _x, _y, _speedY, _gravityY) {
        text = _text;
        x = _x;
        y = _y;
        speedY = _speedY;
        gravityY = _gravityY;
        age = 0;
    }
    public function draw(g: G) {
        g.drawString(text, x, y);
    }
    public function tick() {
        if (isAlive == false) return;
        age += 5;
        y += speedY;
        speedY += gravityY;
        if (age == 300) {
            isAlive = false;
        }
    }
}

class ScrollingTextManager extends SceneScript {

    var texts: Array<ScrollingTextManager_Text>;
    var font: Font;

    public function new(f: Font) {
        super();
        font = f;
        texts = [];
        runPeriodically(5, function(_: TimedTask): Void {
            updatePositions();
        }, null);
        addWhenDrawingListener(null, function(g: G, x: Float, y: Float, _: Array<Dynamic>): Void {
            drawTexts(g);
        });
    }

    public function pump(text: String, x: Float, y: Float) {
        texts = texts.filter(text -> text.isAlive);
        final textWidth = font.getTextWidth(text) / Engine.SCALE;
        texts.push(new ScrollingTextManager_Text(
            text,
            x - textWidth / 2, y,
            -1.8, 0.03
        ));
    }

    function updatePositions() {
        for (text in texts) {
            if (text.isAlive == false) continue;
            text.tick();
        }
    }

    function drawTexts(g: G) {
        g.setFont(font);
        for (text in texts) {
            if (text.isAlive)
                text.draw(g);
        }
    }

}