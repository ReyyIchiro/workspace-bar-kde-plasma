import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import Qt5Compat.GraphicalEffects
import "../common" as Common

// workspace-bar style: [number | app icons] rendered inside DesktopButton's chip
RowLayout {
    id: iconStrip
    property QtObject config: plasmoid.configuration
    property string desktopUuid: ""
    property bool isCurrent: false
    property int desktopNumber: 0
    function wsbInt(key, fallback) {
        var v = config[key];
        return v === undefined ? fallback : v;
    }
    function wsbBool(key, fallback) {
        var v = config[key];
        return v === undefined ? fallback : v;
    }
    property int wsbIconSize: wsbInt("WsbSizeMode", 1) === 0 ? 16 : (wsbInt("WsbSizeMode", 1) === 2 ? 26 : 20)
    // Chip background is drawn by DesktopButton; the strip only lays out content
    property bool wsbFillOn: wsbBool("WsbShowIconsBackground", true)
    spacing: 6 // gap between the number and the icon row
    Layout.alignment: Qt.AlignVCenter
    SystemPalette { id: sysPal }

    // Mirrored from DesktopButton's mouse area for hover feedback
    property bool hovered: false

    Text {
        id: numLabel
        Layout.alignment: Qt.AlignVCenter
        text: iconStrip.desktopNumber
        font.pixelSize: iconStrip.wsbIconSize * 0.64
        font.bold: true
        color: iconStrip.wsbFillOn ? "#f4f4f5" : Kirigami.Theme.textColor
        Behavior on color {
            enabled: config.AnimationsEnable
            ColorAnimation { duration: 120 }
        }
    }

    Row {
        id: iconsRow
        Layout.alignment: Qt.AlignVCenter
        spacing: iconStrip.spacing
        visible: iconsModel.count > 0
        Repeater {
                model: ListModel { id: iconsModel }
                delegate: Item {
                    width: iconStrip.wsbIconSize
                    height: iconStrip.wsbIconSize
                    Kirigami.Icon {
                        anchors.fill: parent
                        source: model.iconName
                        opacity: (!model.isActive && iconStrip.wsbBool("WsbDimInactive", false)) ? 0.5 : 1.0
                        layer.enabled: !model.isActive && iconStrip.wsbBool("WsbDesaturateInactive", false)
                        layer.effect: Desaturate { desaturation: 1.0 }
                    }
                    // GNOME dash-style dot marking the focused window (current desktop only)
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -3
                        width: 4
                        height: 4
                        radius: 2
                        visible: model.isActive && iconStrip.isCurrent
                        color: sysPal.highlight
                    }
                    Rectangle {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: -1
                        anchors.bottomMargin: -1
                        width: Math.max(11, countLabel.implicitWidth + 5)
                        height: 11
                        radius: 5.5
                        visible: iconStrip.wsbBool("WsbCombineIcons", true) && model.windowCount > 1
                        color: sysPal.highlight
                        border.width: 1
                        border.color: iconStrip.wsbBool("WsbShowIconsBackground", true) ? "#1e1f22" : "transparent"
                        Text {
                            id: countLabel
                            anchors.centerIn: parent
                            text: model.windowCount
                            font.pixelSize: 8
                            font.bold: true
                            color: "white"
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: function(mouse) {
                            var winIdList = String(model.winIds).split(",");
                            if (mouse.button === Qt.MiddleButton && iconStrip.wsbBool("WsbMiddleClickClose", true)) {
                                Common.TaskManager.requestCloseWindows(winIdList, iconStrip.desktopUuid);
                                mouse.accepted = true;
                                return;
                            }
                            Common.TaskManager.activateWindow(winIdList[0], iconStrip.desktopUuid, model.activityId);
                            mouse.accepted = true;
                        }
                    }
            }
        }
    }

    property string _modelSig: ""

    function refresh() {
        if (!wsbBool("WsbShowIcons", true)) {
            if (iconsModel.count > 0) { iconsModel.clear(); }
            _modelSig = "";
            return;
        }
        var activityId = backend.getCurrentActivityId();
        var wins = Common.TaskManager.getWindowsForDesktop(iconStrip.desktopUuid, activityId);
        var combine = wsbBool("WsbCombineIcons", true);

        // Skip rebuild when nothing changed (refresh runs every 500ms)
        var sig = (combine ? "c|" : "n|");
        for (var n = 0; n < wins.length; n++) {
            sig += wins[n].appId + ":" + wins[n].winId + ":" + (wins[n].isActive ? "1" : "0") + ";";
        }
        if (sig === _modelSig) { return; }
        _modelSig = sig;

        iconsModel.clear();
        if (combine) {
            var byApp = {};
            var order = [];
            var i;
            for (i = 0; i < wins.length; i++) {
                var w = wins[i];
                if (!byApp[w.appId]) {
                    byApp[w.appId] = { appName: w.appName, winIds: [], isActive: false, act: w.activityId };
                    order.push(w.appId);
                }
                byApp[w.appId].winIds.push(w.winId);
                if (w.isActive) { byApp[w.appId].isActive = true; }
            }
            for (var k = 0; k < order.length; k++) {
                var g = byApp[order[k]];
                iconsModel.append({
                    iconName: backend.getIconFromDesktopFile(order[k]),
                    appName: g.appName,
                    winIds: g.winIds.join(","),
                    windowCount: g.winIds.length,
                    isActive: g.isActive,
                    activityId: g.act
                });
            }
        } else {
            for (var j = 0; j < wins.length; j++) {
                var s = wins[j];
                iconsModel.append({
                    iconName: backend.getIconFromDesktopFile(s.appId),
                    appName: s.appName,
                    winIds: s.winId,
                    windowCount: 1,
                    isActive: s.isActive,
                    activityId: s.activityId
                });
            }
        }
    }
}
