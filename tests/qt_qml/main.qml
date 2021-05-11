import QtQuick 2.6
import QtQuick.Window 2.1
import QtQuick.Controls 1.2

ApplicationWindow {
    title: "bazel rules_qt qml demo"

    Label {
        text: "Hello world"
        font.pixelSize: 24
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
