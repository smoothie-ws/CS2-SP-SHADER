import QtQuick 2.7
import QtQuick.Layouts 1.3
import AlgWidgets 2.0
import AlgWidgets.Style 2.0


ColumnLayout {
    id: root
    opacity: enabled ? 1.0 : 0.5
    spacing: 5

    property Component background: Rectangle {
        radius: 10
        clip: true
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 0.05) }
            GradientStop { position: 100 / height; color: Qt.rgba(0, 0, 0, 0) }
        }
    }

    Item {
        width: root.width
        height: root.height

        Loader {
            anchors.fill: parent
            sourceComponent: background
        }
    }

    default property alias children: __contentItem.children

    property alias activeScopeBorder: scopeLine.visible
    property alias toggled: groupButton.toggled
    property alias expandable: groupButton.visible
    property alias text: groupButton.text
    property alias tooltip: groupButton.tooltip
    property int shaderID: 0
    property real padding: 5

    AlgToggleButton {
        id: groupButton
        toggled: true
        Layout.fillWidth: true
        Layout.margins: root.padding
        textAlignment: Text.AlignLeft
        __style: AlgStyle.widget.groupWidget
        iconName: checked ? AlgStyle.icons.groupwidget.expanded : AlgStyle.icons.groupwidget.collapsed
        iconSize: AlgStyle.widget.groupWidget.iconSize
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.margins: root.padding
        Layout.topMargin: groupButton.visible ? 0 : root.padding

        visible: groupButton.toggled

        Item {
            id: scopeLine
            visible: true
            Layout.fillHeight: true
            Layout.preferredWidth: 15

            Repeater {
                model: __contentItem.children
                delegate: Rectangle {
                    x: parent.width / 2 - width / 2
                    y: { 
                        var x0 = 0;

                        for (var i = 0; i < index; ++i) {
                            x0 += __contentItem.children[i].height + __contentItem.spacing;
                        }

                        return x0 + modelData.height / 2 - height / 2
                    }

                    width: 7
                    height: width
                    radius: width
                    visible: modelData.toString().indexOf("SPParameter") != -1 && modelData.visible && modelData.isChanged && modelData.resettable
                    color: Qt.rgba(1, 1, 1, 0.5)
                }
            }
        }

        ColumnLayout {
            id: __contentItem
            Layout.fillWidth: true

            Component.onCompleted: {
                var maxSeparatorX = 0;
                for (var i = 0; i < __contentItem.children.length; ++i) {
                    var child = __contentItem.children[i];
                    child.Layout.fillWidth = true;

                    if (child.toString().indexOf("SPParameter") !== -1) {
                        child.shaderID = root.shaderID;

                        if (child.__separatorX > maxSeparatorX) {
                            maxSeparatorX = child.__separatorX;
                        }
                    }
                }

                for (var i = 0; i < __contentItem.children.length; ++i) {
                    var child = __contentItem.children[i];
                    if (child.toString().indexOf("SPParameter") !== -1) {
                        child.__separatorX = child.__separatorX == 0 ? 0 : maxSeparatorX;
                    }
                }
            }
        }
    }
}

