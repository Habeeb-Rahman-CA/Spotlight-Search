import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Effects

Window {
    id: root
    width: 680
    height: searchInput.text.length > 0
            ? (resultsModel.count > 0
               ? Math.min(72 + resultsModel.count * 52 + 24, 440)
               : 160)
            : 72
    visible: true
    title: qsTr("Trinode")

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
    color: "transparent"

    x: Screen.width / 2 - width / 2
    y: Screen.height / 4

    Behavior on height {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    onActiveChanged: {
        if (!active && root.visible) {
            root.hide()
        }
    }

    Connections {
        target: Backend
        function onToggleSearchWindow() {
            if (root.visible) {
                root.hide()
            } else {
                root.show()
                root.raise()
                root.requestActivate()
                searchInput.forceActiveFocus()
                searchInput.selectAll()
            }
        }
    }

    // Main container with frosted glass look
    Rectangle {
        id: container
        anchors.fill: parent
        radius: 24
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.15, 0.15, 0.18, 0.75) }
            GradientStop { position: 1.0; color: Qt.rgba(0.08, 0.08, 0.1, 0.85) }
        }
        border.color: Qt.rgba(1, 1, 1, 0.2)
        border.width: 1

        // Drop shadow effect
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.4)
            shadowBlur: 2.0
            shadowVerticalOffset: 12
            shadowHorizontalOffset: 0
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ─── Search Bar ───────────────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 72

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 14

                    // Search icon
                    Image {
                        source: "assets/search.svg"
                        width: 20
                        height: 20
                        opacity: 0.5
                        sourceSize: Qt.size(width, height)
                    }

                    TextField {
                        id: searchInput
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        font.pixelSize: 22
                        font.weight: Font.Light
                        font.family: "Segoe UI"
                        placeholderText: "Search apps, files..."
                        placeholderTextColor: Qt.rgba(1, 1, 1, 0.28)
                        color: "#F0F0F0"
                        selectionColor: Qt.rgba(0.4, 0.6, 1.0, 0.4)
                        selectedTextColor: "#FFFFFF"
                        focus: true
                        verticalAlignment: TextInput.AlignVCenter

                        background: Item {} // Invisible background

                        onTextChanged: {
                            resultsModel.clear()
                            if (text.length > 0) {
                                var res = Backend.search(text)
                                for (var i = 0; i < res.length; i++) {
                                    resultsModel.append(res[i])
                                }
                            }
                            resultsList.currentIndex = 0
                        }

                        Keys.onDownPressed: {
                            if (resultsModel.count > 0)
                                resultsList.currentIndex = Math.min(
                                    resultsList.currentIndex + 1,
                                    resultsModel.count - 1)
                        }
                        Keys.onUpPressed: {
                            if (resultsModel.count > 0)
                                resultsList.currentIndex = Math.max(
                                    resultsList.currentIndex - 1, 0)
                        }
                        Keys.onReturnPressed: {
                            if (resultsList.currentIndex >= 0
                                    && resultsList.currentIndex < resultsModel.count) {
                                var item = resultsModel.get(
                                            resultsList.currentIndex)
                                Backend.launch(item.path)
                                root.hide()
                                searchInput.text = ""
                            }
                        }
                        Keys.onEscapePressed: {
                            root.hide()
                            searchInput.text = ""
                        }
                    }

                    // Shortcut hint
                    Text {
                        visible: searchInput.text.length === 0
                        text: "Ctrl+Space"
                        font.pixelSize: 11
                        font.family: "Segoe UI"
                        color: Qt.rgba(1, 1, 1, 0.2)
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -6
                            radius: 8
                            color: Qt.rgba(1, 1, 1, 0.06)
                            z: -1
                        }
                    }
                }
            }

            // ─── Divider ─────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                height: 1
                color: Qt.rgba(1, 1, 1, 0.06)
                visible: resultsModel.count > 0
            }

            // ─── Results List ────────────────────────────────────
            ListView {
                id: resultsList
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 6
                Layout.bottomMargin: 8
                clip: true
                visible: resultsModel.count > 0

                model: ListModel {
                    id: resultsModel
                }

                // Smooth scrolling
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 4
                    contentItem: Rectangle {
                        radius: 2
                        color: Qt.rgba(1, 1, 1, 0.15)
                    }
                }

                delegate: Item {
                    width: resultsList.width
                    height: 52

                    Rectangle {
                        id: delegateBg
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        radius: 14
                        color: resultsList.currentIndex === index
                               ? Qt.rgba(1, 1, 1, 0.12)
                               : hoverArea.containsMouse
                                 ? Qt.rgba(1, 1, 1, 0.06)
                                 : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 14

                            // App icon
                            Rectangle {
                                width: 34
                                height: 34
                                radius: 10
                                color: Qt.rgba(1, 1, 1, 0.06)

                                Image {
                                    anchors.centerIn: parent
                                    width: 24
                                    height: 24
                                    source: model.path ? "image://fileicon/" + model.path : ""
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                }
                            }

                            // Name and path
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: model.name
                                    color: resultsList.currentIndex === index
                                           ? "#FFFFFF" : "#D8D8D8"
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    font.family: "Segoe UI"
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight

                                    Behavior on color {
                                        ColorAnimation { duration: 120 }
                                    }
                                }

                                Text {
                                    text: {
                                        // Show only the filename or last folder
                                        var parts = model.path.replace(/\\/g, "/").split("/")
                                        if (parts.length > 2)
                                            return parts.slice(-2).join(" › ")
                                        return model.path
                                    }
                                    color: Qt.rgba(1, 1, 1, 0.3)
                                    font.pixelSize: 11
                                    font.family: "Segoe UI"
                                    Layout.fillWidth: true
                                    elide: Text.ElideLeft
                                }
                            }

                            // Type badge
                            Rectangle {
                                visible: model.type !== undefined
                                width: typeLabel.implicitWidth + 14
                                height: 22
                                radius: 8
                                color: Qt.rgba(1, 1, 1, 0.05)

                                Text {
                                    id: typeLabel
                                    anchors.centerIn: parent
                                    text: model.type || ""
                                    font.pixelSize: 10
                                    font.family: "Segoe UI"
                                    font.weight: Font.Medium
                                    color: Qt.rgba(1, 1, 1, 0.3)
                                    font.capitalization: Font.AllUppercase
                                }
                            }

                            // Return icon for selected item
                            Image {
                                visible: resultsList.currentIndex === index
                                source: "assets/return.svg"
                                width: 14
                                height: 14
                                opacity: 0.25
                                sourceSize: Qt.size(width, height)
                                Layout.alignment: Qt.AlignVCenter

                                Behavior on opacity {
                                    NumberAnimation { duration: 120 }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: hoverArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: resultsList.currentIndex = index
                        onClicked: {
                            resultsList.currentIndex = index
                            Backend.launch(model.path)
                            root.hide()
                            searchInput.text = ""
                        }
                    }
                }

                // Entry animation
                add: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0; to: 1
                        duration: 150
                    }
                    NumberAnimation {
                        property: "y"
                        from: -10
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // ─── Empty state (when typing but no results) ────────
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                visible: searchInput.text.length > 0 && resultsModel.count === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Image {
                        source: "assets/logo.png"
                        width: 48
                        height: 48
                        Layout.alignment: Qt.AlignHCenter
                        opacity: 0.2
                    }

                    Text {
                        text: "No results found"
                        font.pixelSize: 14
                        font.family: "Segoe UI"
                        color: Qt.rgba(1, 1, 1, 0.25)
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}
