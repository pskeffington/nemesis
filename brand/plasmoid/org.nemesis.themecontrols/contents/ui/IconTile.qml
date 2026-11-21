import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

// ---------------------------------------------------------------------
// Semantic button for one Nemesis object. Mouse, touch and keyboard
// activation all use AbstractButton's onClicked path; no hardware I/O.
// ---------------------------------------------------------------------
Controls.Button {
    id: tile

    property string channelKey: ""
    property string iconKey: ""
    readonly property int iconStatus: objectIcon.status
    property bool selected: false
    property bool highContrast: false
    property color accentColor: "#883DFF"
    signal activated(string key)

    implicitWidth: 112
    implicitHeight: 92
    checkable: true
    checked: selected
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    Accessible.name: text
    Accessible.description: selected
                            ? qsTr("Selected preview category")
                            : qsTr("Activate preview category")
    onClicked: activated(channelKey)

    background: Rectangle {
        radius: 12
        color: tile.down ? "#382850"
                         : tile.selected ? "#2E254B"
                                         : tile.hovered ? "#26354A" : "#1B2230"
        border.width: tile.activeFocus ? (tile.highContrast ? 4 : 3)
                                       : tile.selected ? 2 : 1
        border.color: tile.activeFocus || tile.selected
                      ? tile.accentColor
                      : tile.hovered ? "#00A8FF" : "#46516B"
        opacity: tile.enabled ? 1 : 0.48
    }

    contentItem: ColumnLayout {
        spacing: 6

        Image {
            id: objectIcon
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            source: Qt.resolvedUrl("../images/" + tile.iconKey + ".svg")
            sourceSize.width: 76
            sourceSize.height: 76
            fillMode: Image.PreserveAspectFit
            smooth: true
            asynchronous: false
            opacity: tile.enabled ? 1 : 0.45
        }

        Controls.Label {
            Layout.fillWidth: true
            text: tile.text
            color: tile.enabled ? "#F0F1F7" : "#93A4BA"
            font.weight: tile.selected ? Font.DemiBold : Font.Normal
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }
}
