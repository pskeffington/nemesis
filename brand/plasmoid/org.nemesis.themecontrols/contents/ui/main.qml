import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid

// ---------------------------------------------------------------------
// Plasma 6 shell wrapper: the testable ModeBoard contains all interaction.
// Installing the widget does not add it to a panel or enable autostart.
// ---------------------------------------------------------------------
PlasmoidItem {
    id: root
    Plasmoid.icon: "nemesis"
    Plasmoid.title: qsTr("Nemesis Theme Inspector")
    toolTipMainText: qsTr("Nemesis Theme Inspector")
    toolTipSubText: qsTr("Interactive icon preview; no live connections")

    fullRepresentation: ModeBoard {
        Layout.minimumWidth: 480
        Layout.minimumHeight: 440
        Layout.preferredWidth: 520
        Layout.preferredHeight: 470
    }
}
