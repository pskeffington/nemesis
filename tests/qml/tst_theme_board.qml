import QtQuick
import QtTest
import "../../brand/plasmoid/org.nemesis.themecontrols/contents/ui" as Nemesis

// ---------------------------------------------------------------------
// Real Qt Quick interaction tests; no KDE session/device access required.
// QtTest synthesizes click and keyboard events against the reusable board.
// ---------------------------------------------------------------------
TestCase {
    id: suite
    name: "NemesisObjectInteractivity"
    when: windowShown
    width: 620
    height: 590

    Nemesis.ModeBoard {
        id: board
        anchors.fill: parent
    }

    function init() {
        board.resetPreview()
        wait(35)
    }

    function clickControl(control) {
        verify(control.visible && control.width > 20 && control.height > 20)
        mouseMove(control, control.width / 2, control.height / 2)
        wait(8)
        mouseClick(control, control.width / 2, control.height / 2)
        wait(8)
    }

    function test_defaultState() {
        compare(board.selectedKey, "terminal")
        compare(board.selectedTitle, "Console")
        compare(board.useCyan, false)
        compare(board.highContrast, false)
        verify(board.tileAt(0).selected)
        verify(!board.tileAt(1).selected)
    }

    function test_eightObjectsPresent() {
        compare(board.channels.length, 8)
        for (let i = 0; i < board.channels.length; ++i) {
            const tile = board.tileAt(i)
            verify(tile !== null)
            compare(tile.channelKey, board.channels[i].key)
            compare(tile.iconKey, board.channels[i].key)
        }
    }

    function test_clickSelectsAndUpdatesContent() {
        const radio = board.tileAt(1)
        clickControl(radio)
        compare(board.selectedKey, "radio")
        compare(board.selectedTitle, "Signals")
        verify(board.selectedDescription.indexOf("No receiver") >= 0)
        compare(radio.selected, true)
        compare(board.tileAt(0).selected, false)
    }

    function test_keyboardActivatesWithoutMouse() {
        const shield = board.tileAt(7)
        shield.forceActiveFocus()
        verify(shield.activeFocus)
        keyClick(Qt.Key_Space)
        compare(board.selectedKey, "shield")
        compare(board.selectedTitle, "Defense")
    }

    function test_cyanAccentControl() {
        clickControl(board.cyanControl)
        compare(board.useCyan, true)
        compare(board.tileAt(0).accentColor, board.cyan)
    }

    function test_highContrastControl() {
        clickControl(board.contrastControl)
        compare(board.highContrast, true)
        compare(board.tileAt(0).highContrast, true)
    }

    function test_resetIsFunctional() {
        clickControl(board.tileAt(5))
        compare(board.selectedKey, "satellite")
        clickControl(board.cyanControl)
        compare(board.useCyan, true)
        clickControl(board.contrastControl)
        compare(board.highContrast, true)
        clickControl(board.resetControl)
        compare(board.selectedKey, "terminal")
        compare(board.useCyan, false)
        compare(board.highContrast, false)
    }

    function test_unknownObjectDoesNotChangeSelection() {
        board.selectChannel("nonexistent")
        compare(board.selectedKey, "terminal")
    }
}
