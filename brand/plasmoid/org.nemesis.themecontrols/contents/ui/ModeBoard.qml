import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

// ---------------------------------------------------------------------
// Interactive preview of Nemesis UI objects; no network or device I/O.
// Each object changes selection, label and accent/focus styling.
// ---------------------------------------------------------------------
Item {
    id: board
    implicitWidth: 520
    implicitHeight: 470

    property string selectedKey: "terminal"
    property bool useCyan: false
    property bool highContrast: false
    readonly property color primary: "#883DFF"
    readonly property color cyan: "#00A8FF"
    readonly property color currentAccent: useCyan ? cyan : primary
    readonly property var channels: [
        { key: "terminal", title: qsTr("Console"), note: qsTr("Command interface object. Visual preview only.") },
        { key: "radio", title: qsTr("Signals"), note: qsTr("Radio and spectral object. No receiver is connected.") },
        { key: "database", title: qsTr("Data"), note: qsTr("Database object. No records are loaded.") },
        { key: "location", title: qsTr("GIS"), note: qsTr("Location object. No coordinates are requested.") },
        { key: "drone", title: qsTr("Platform"), note: qsTr("Platform object. No vehicle controls are available.") },
        { key: "satellite", title: qsTr("Satcom"), note: qsTr("Satellite object. No telemetry is ingested.") },
        { key: "headphones", title: qsTr("Audio"), note: qsTr("Audio object. No microphone is active.") },
        { key: "shield", title: qsTr("Defense"), note: qsTr("Defense object. No network or policy changes occur.") }
    ]
    readonly property string selectedTitle: {
        for (let i = 0; i < channels.length; ++i) {
            if (channels[i].key === selectedKey) {
                return channels[i].title
            }
        }
        return ""
    }
    readonly property string selectedDescription: {
        for (let i = 0; i < channels.length; ++i) {
            if (channels[i].key === selectedKey) {
                return channels[i].note
            }
        }
        return ""
    }
    property alias cyanControl: cyanControl
    property alias contrastControl: contrastControl
    property alias resetControl: resetControl

    function selectChannel(key) {
        for (let i = 0; i < channels.length; ++i) {
            if (channels[i].key === key) {
                selectedKey = key
                return
            }
        }
    }

    function tileAt(index) {
        return tiles.itemAt(index)
    }

    function resetPreview() {
        selectedKey = "terminal"
        useCyan = false
        highContrast = false
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: "#0B0E14"
        border.color: board.highContrast ? "#00A8FF" : "#35425B"
        border.width: board.highContrast ? 3 : 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Controls.Label {
            text: qsTr("NEMESIS  /  OBJECT INSPECTOR")
            font.pixelSize: 17
            font.weight: Font.Bold
            color: "#F0F1F7"
            Layout.fillWidth: true
        }

        Controls.Label {
            text: qsTr("Theme interaction sandbox · no live telemetry")
            font.pixelSize: 12
            color: "#93A4BA"
            Layout.fillWidth: true
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 4
            columnSpacing: 8
            rowSpacing: 8

            Repeater {
                id: tiles
                model: board.channels

                delegate: IconTile {
                    required property var modelData
                    channelKey: modelData.key
                    iconKey: modelData.key
                    text: modelData.title
                    selected: board.selectedKey === channelKey
                    highContrast: board.highContrast
                    accentColor: board.currentAccent
                    Layout.fillWidth: true
                    Layout.preferredWidth: 114
                    Layout.preferredHeight: 92
                    onActivated: key => board.selectChannel(key)
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 104
            color: "#1B2230"
            radius: 10
            border.width: board.highContrast ? 2 : 1
            border.color: board.currentAccent

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Controls.Label {
                    text: qsTr("SELECTED OBJECT: ") + board.selectedTitle
                    font.weight: Font.DemiBold
                    font.pixelSize: 13
                    color: "#F0F1F7"
                }
                Controls.Label {
                    text: board.selectedDescription
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12
                    color: "#D7D9DE"
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Controls.CheckBox {
                id: cyanControl
                text: qsTr("Cyan selection")
                checked: board.useCyan
                onToggled: board.useCyan = checked
                Accessible.description: qsTr("Use cyan instead of purple on selected objects")
            }

            Controls.CheckBox {
                id: contrastControl
                text: qsTr("Strong focus")
                checked: board.highContrast
                onToggled: board.highContrast = checked
                Accessible.description: qsTr("Use thicker keyboard focus outlines")
            }
        }

        Controls.Button {
            id: resetControl
            Layout.alignment: Qt.AlignRight
            text: qsTr("Reset preview")
            icon.name: "edit-undo"
            onClicked: board.resetPreview()
            Accessible.description: qsTr("Restore default object selection and accent settings")
        }

        Controls.Label {
            text: qsTr("Controls affect only this preview. No system settings are written.")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            font.pixelSize: 11
            color: "#93A4BA"
        }
    }
}
