import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Math;

class WatchFaceView extends WatchUi.WatchFace {

    var _isAwake = true;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    // Returnează cele 3 puncte ale limbii: [bazaStanga, bazaDreapta, varf]
    function getHandPoints(cx as Number, cy as Number, angle as Float, len as Number, halfW as Float) as Array {
        var perpX = (-Math.sin(angle) * halfW);
        var perpY = ( Math.cos(angle) * halfW);
        var tipX  = cx + (len * Math.cos(angle)).toNumber();
        var tipY  = cy + (len * Math.sin(angle)).toNumber();

        return [
            [cx + perpX.toNumber(), cy + perpY.toNumber()], // baza stanga
            [cx - perpX.toNumber(), cy - perpY.toNumber()], // baza dreapta
            [tipX, tipY]                                     // varf ascutit
        ];
    }

    // Mod activ: umple forma
    function drawHandFilled(dc as Dc, cx as Number, cy as Number, angle as Float, len as Number, halfW as Float) as Void {
        var pts = getHandPoints(cx, cy, angle, len, halfW);
        dc.fillPolygon(pts);
    }

    // Sleep mode: conturul aceleiasi forme
    function drawHandOutline(dc as Dc, cx as Number, cy as Number, angle as Float, len as Number, halfW as Float) as Void {
        var pts = getHandPoints(cx, cy, angle, len, halfW);
        dc.setPenWidth(1);
        dc.drawLine(pts[0][0], pts[0][1], pts[1][0], pts[1][1]); // baza
        dc.drawLine(pts[0][0], pts[0][1], pts[2][0], pts[2][1]); // stanga → varf
        dc.drawLine(pts[1][0], pts[1][1], pts[2][0], pts[2][1]); // dreapta → varf
    }

    function onUpdate(dc as Dc) as Void {
        var width   = dc.getWidth();
        var height  = dc.getHeight();
        var centerX = width  / 2;
        var centerY = height / 2;
        var radius  = (width < height ? width : height) / 2 - 10;

        // --- Fundal negru ---
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // --- Cerc exterior cadran ---
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawCircle(centerX, centerY, radius);

        // --- Marcaje ore + cifre 12, 3, 6, 9 ---
        var hourLabels = {0 => "12", 3 => "3", 6 => "6", 9 => "9"};
        for (var i = 0; i < 12; i++) {
            var angle  = Math.toRadians(i * 30.0 - 90.0);
            var outerX = centerX + (radius * Math.cos(angle)).toNumber();
            var outerY = centerY + (radius * Math.sin(angle)).toNumber();
            var innerX = centerX + ((radius - 12) * Math.cos(angle)).toNumber();
            var innerY = centerY + ((radius - 12) * Math.sin(angle)).toNumber();

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(i % 3 == 0 ? 4 : 2);
            dc.drawLine(innerX, innerY, outerX, outerY);

            if (_isAwake && hourLabels.hasKey(i)) {
                var labelRadius = radius - 28;
                var labelX = centerX + (labelRadius * Math.cos(angle)).toNumber();
                var labelY = centerY + (labelRadius * Math.sin(angle)).toNumber();
                dc.drawText(labelX, labelY, Graphics.FONT_TINY, hourLabels[i],
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }

        // --- Timp curent ---
        var clockTime   = System.getClockTime();
        var hours       = clockTime.hour % 12;
        var minutes     = clockTime.min;
        var seconds     = clockTime.sec;

        var hourAngle   = Math.toRadians((hours   * 30.0) + (minutes * 0.5) - 90.0);
        var minuteAngle = Math.toRadians((minutes *  6.0) - 90.0);
        var secondAngle = Math.toRadians((seconds *  6.0) - 90.0);

        var hourLen   = (radius * 0.50).toNumber();
        var minuteLen = (radius * 0.75).toNumber();
        var secondLen = (radius * 0.85).toNumber();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        if (_isAwake) {
            // --- Activ: limbi pline ---
            drawHandFilled(dc, centerX, centerY, hourAngle,   hourLen,   6.0f);
            drawHandFilled(dc, centerX, centerY, minuteAngle, minuteLen, 4.0f);

            // Secundar roșu
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(2);
            dc.drawLine(
                centerX, centerY,
                centerX + (secondLen * Math.cos(secondAngle)).toNumber(),
                centerY + (secondLen * Math.sin(secondAngle)).toNumber()
            );

            // Punct central
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(centerX, centerY, 5);
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(centerX, centerY, 3);

        } else {
            // --- Sleep: conturul aceleiasi forme ---
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            drawHandOutline(dc, centerX, centerY, hourAngle,   hourLen,   6.0f);
            drawHandOutline(dc, centerX, centerY, minuteAngle, minuteLen, 4.0f);

            // Punct central mic
            dc.fillCircle(centerX, centerY, 3);
        }
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
        _isAwake = true;
        WatchUi.requestUpdate();
    }

    function onEnterSleep() as Void {
        _isAwake = false;
        WatchUi.requestUpdate();
    }
}