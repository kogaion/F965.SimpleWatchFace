import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Math;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;


class WatchFaceView extends WatchUi.WatchFace {

    var _isAwake = true;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    function getHandPoints(cx as Number, cy as Number, angle as Float, len as Number, halfW as Float) as Array {
        var perpX = (-Math.sin(angle) * halfW);
        var perpY = ( Math.cos(angle) * halfW);
        var tipX  = cx + (len * Math.cos(angle)).toNumber();
        var tipY  = cy + (len * Math.sin(angle)).toNumber();

        return [
            [cx + perpX.toNumber(), cy + perpY.toNumber()],
            [cx - perpX.toNumber(), cy - perpY.toNumber()],
            [tipX, tipY]
        ];
    }

    function drawHandFilled(dc as Dc, cx as Number, cy as Number, angle as Float, len as Number, halfW as Float) as Void {
        var pts = getHandPoints(cx, cy, angle, len, halfW);
        dc.fillPolygon(pts);
    }

    function drawHandOutline(dc as Dc, cx as Number, cy as Number, angle as Float, len as Number, halfW as Float) as Void {
        var pts = getHandPoints(cx, cy, angle, len, halfW);
        dc.setPenWidth(1);
        dc.drawLine(pts[0][0], pts[0][1], pts[1][0], pts[1][1]);
        dc.drawLine(pts[0][0], pts[0][1], pts[2][0], pts[2][1]);
        dc.drawLine(pts[1][0], pts[1][1], pts[2][0], pts[2][1]);
    }

    function drawBattery(dc as Dc, cx as Number, cy as Number) as Void {
        var stats = System.getSystemStats();
        var pct   = stats.battery.toNumber();

        var color;
        if (pct > 50) {
            color = Graphics.COLOR_GREEN;
        } else if (pct > 20) {
            color = Graphics.COLOR_YELLOW;
        } else {
            color = Graphics.COLOR_RED;
        }

        var bW    = 18;
        var bH    = 9;
        var poleW = 3;
        var poleH = 4;
        var gap   = 4; // spatiu intre iconita si text

        var pctStr     = Lang.format("$1$%", [pct]);
        var textWidth  = dc.getTextWidthInPixels(pctStr, Graphics.FONT_XTINY);
        var totalWidth = bW + poleW + gap + textWidth;

        // Punctul de start al iconitei astfel incat totul sa fie centrat
        var startX = cx - totalWidth / 2;
        var bX     = startX;
        var bY     = cy - bH / 2;

        // Corp baterie (contur)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawRectangle(bX, bY, bW, bH);

        // Polul +
        dc.fillRectangle(bX + bW, cy - poleH / 2, poleW, poleH);

        // Umplere proportionala
        var fillW = ((bW - 4) * pct / 100).toNumber();
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(bX + 2, bY + 2, fillW, bH - 4);

        // Procent text
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            bX + bW + poleW + gap,
            cy,
            Graphics.FONT_XTINY,
            pctStr,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function formatSteps(steps as Number) as String {
        if (steps >= 10000) {
            var k    = (steps / 100).toFloat() / 10.0;
            var full = k.toNumber();
            var dec  = ((k - full) * 10).toNumber();
            if (dec == 0) {
                return Lang.format("$1$K", [full]);
            }
            return Lang.format("$1$.$2$K", [full, dec]);
        }
        return steps.toString();
    }

    function drawDigitalTime(dc as Dc, cx as Number, cy as Number) as Void {
        var clockTime = System.getClockTime();
        var timeStr   = Lang.format("$1$:$2$", [
            clockTime.hour.format("%02d"),
            clockTime.min.format("%02d")
        ]);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            cy,
            Graphics.FONT_XTINY,
            timeStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawIntensity(dc as Dc, cx as Number, cy as Number) as Void {
        var info     = ActivityMonitor.getInfo();
        var minutes  = (info.activeMinutesWeek != null) ? info.activeMinutesWeek.total : 0;

        // Iconita sus
        var icon  = WatchUi.loadResource(Rez.Drawables.IntensityIcon) as BitmapResource;
        var iconW = 40;
        var iconH = 40;
        dc.drawBitmap(cx - iconW / 2, cy - iconH - 2, icon);

        // Text jos
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            cy + 4,
            Graphics.FONT_XTINY,
            minutes.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawSteps(dc as Dc, cx as Number, cy as Number) as Void {
        var info     = ActivityMonitor.getInfo();
        var steps    = (info.steps != null) ? info.steps : 0;
        var stepsStr = formatSteps(steps);

        // --- Iconita PNG centrata sus ---
        var icon  = WatchUi.loadResource(Rez.Drawables.StepsIcon) as BitmapResource;
        var iconW = 40;
        var iconH = 40;
        dc.drawBitmap(cx - iconW / 2, cy - iconH - 2, icon);

        // --- Text pasi centrat jos ---
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            cy + 4,
            Graphics.FONT_XTINY,
            stepsStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawFloors(dc as Dc, cx as Number, cy as Number) as Void {
        var info   = ActivityMonitor.getInfo();
        var floors = (info.floorsClimbed != null) ? info.floorsClimbed : 0;

        // Iconita sus
        // --- Iconita PNG centrata sus ---
        var icon  = WatchUi.loadResource(Rez.Drawables.FloorsIcon) as BitmapResource;
        var iconW = 40;
        var iconH = 40;
        dc.drawBitmap(cx - iconW / 2, cy - iconH - 2, icon);
        
        // Text jos
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            cy + 4,
            Graphics.FONT_XTINY,
            floors.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function getDayAbbr(day as Number) as String {
        // Gregorian.info().day_of_week: 1=Sun, 2=Mon, ... 7=Sat
        var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        return days[day - 1];
    }

    function getMonthAbbr(month as Number) as String {
        var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        return months[month - 1];
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
        if (_isAwake) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(3);
            dc.drawCircle(centerX, centerY, radius);
        }

        // --- Data curenta DOW DD ---
        if (_isAwake) {
            var labelRadius = radius - 28;
            var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
            // var dateStr = Lang.format("$1$ $2$", [getMonthAbbr(today.month), today.day.format("%02d")]);
            var dateStr = Lang.format("$1$ $2$", [getDayAbbr(today.day_of_week), today.day.format("%02d")]);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                centerX,
                // centerY - (radius * 0.55).toNumber(), // sus, deasupra centrului
                centerY - labelRadius, // --- Data (unde era 12, sus) ---
                Graphics.FONT_XTINY,
                dateStr,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }

        if (_isAwake) {
            // Baterie (simetric cu data, jos)
            // drawBattery(dc, centerX, centerY + (radius * 0.55).toNumber());
            // --- Baterie (unde era 6, jos) ---
            var labelRadius = radius - 28;
            drawBattery(dc, centerX, centerY + labelRadius);
        }

        if (_isAwake) {
            // --- Pasi (pozitia orei 10) ---
            var stepsAngle  = Math.toRadians(10 * 30.0 - 90.0);
            var stepsRadius = radius * 0.70; // mai spre centru
            var stepsX = centerX + (stepsRadius * Math.cos(stepsAngle)).toNumber();
            var stepsY = centerY + (stepsRadius * Math.sin(stepsAngle)).toNumber();
            drawSteps(dc, stepsX, stepsY);
        }

        if (_isAwake) {
            // --- Etaje (pozitia orei 8) ---
            var floorsAngle  = Math.toRadians(8 * 30.0 - 90.0);
            var floorsRadius = radius * 0.70;
            var floorsX = centerX + (floorsRadius * Math.cos(floorsAngle)).toNumber();
            var floorsY = centerY + (floorsRadius * Math.sin(floorsAngle)).toNumber();
            drawFloors(dc, floorsX, floorsY);
        }

        if (_isAwake) {
            // --- Intensitate saptamanala (pozitia orei 2) ---
            var intensityAngle  = Math.toRadians(2 * 30.0 - 90.0);
            var intensityRadius = radius * 0.7;
            var intensityX = centerX + (intensityRadius * Math.cos(intensityAngle)).toNumber();
            var intensityY = centerY + (intensityRadius * Math.sin(intensityAngle)).toNumber();
            drawIntensity(dc, intensityX, intensityY);
        }

        if (_isAwake) {
            // --- Ora digitala (pozitia orei 4) ---
            var digitalAngle  = Math.toRadians(4 * 30.0 - 90.0);
            var digitalRadius = radius * 0.7;
            var digitalX = centerX + (digitalRadius * Math.cos(digitalAngle)).toNumber();
            var digitalY = centerY + (digitalRadius * Math.sin(digitalAngle)).toNumber();
            drawDigitalTime(dc, digitalX, digitalY);
        }

        // --- Marcaje ore + cifre 12, 3, 6, 9 ---
        var hourLabels = {/*0 => "12", 2 => "2", 4 => "4", 6 => "6", 8 => "8", 9 => "9", 10 => "10"*/};
        for (var i = 0; i < 12; i++) {
            var angle  = Math.toRadians(i * 30.0 - 90.0);
            var outerX = centerX + (radius * Math.cos(angle)).toNumber();
            var outerY = centerY + (radius * Math.sin(angle)).toNumber();
            var innerX = centerX + ((radius - 12) * Math.cos(angle)).toNumber();
            var innerY = centerY + ((radius - 12) * Math.sin(angle)).toNumber();

            dc.setColor(i % 3 == 0 && _isAwake ? Graphics.COLOR_RED : 0x00AAFF, Graphics.COLOR_TRANSPARENT);
            // dc.setPenWidth(i % 3 == 0 ? 4 : 1);
            dc.setPenWidth(4);
            dc.drawLine(innerX, innerY, outerX, outerY);
            // dc.setColor(0x00AAFF, Graphics.COLOR_TRANSPARENT);

            if (_isAwake && hourLabels.hasKey(i)) {
                var labelRadius = radius - 28;
                var labelX = centerX + (labelRadius * Math.cos(angle)).toNumber();
                var labelY = centerY + (labelRadius * Math.sin(angle)).toNumber();
                dc.drawText(labelX, labelY, Graphics.FONT_XTINY, hourLabels[i],
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

        dc.setColor(0x00AAFF, Graphics.COLOR_TRANSPARENT);

        if (_isAwake) {
            drawHandFilled(dc, centerX, centerY, hourAngle,   hourLen,   6.0f);
            drawHandFilled(dc, centerX, centerY, minuteAngle, minuteLen, 4.0f);

            // dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(2);
            dc.drawLine(
                centerX, centerY,
                centerX + (secondLen * Math.cos(secondAngle)).toNumber(),
                centerY + (secondLen * Math.sin(secondAngle)).toNumber()
            );

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(centerX, centerY, 5);
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(centerX, centerY, 3);

        } else {
            // dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            // drawHandOutline(dc, centerX, centerY, hourAngle,   hourLen,   6.0f);
            // drawHandOutline(dc, centerX, centerY, minuteAngle, minuteLen, 4.0f);
            drawHandFilled(dc, centerX, centerY, hourAngle,   hourLen,   6.0f);
            drawHandFilled(dc, centerX, centerY, minuteAngle, minuteLen, 4.0f);
            dc.fillCircle(centerX, centerY, 5);
            // dc.fillCircle(centerX, centerY, 3);
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