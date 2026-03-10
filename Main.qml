import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root
    width: 640
    height: 400
    visible: true
    title: qsTr("Spotlight Search")
    
    // Modern frameless styling
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
    color: "transparent"

    // Center window
    x: Screen.width / 2 - width / 2
    y: Screen.height / 3 - height / 2

    // Manage visibility when focus changes
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

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: Qt.rgba(0.1, 0.1, 0.1, 0.75) // Frosted glass dark theme
        border.color: Qt.rgba(1, 1, 1, 0.15)
        border.width: 1

        // Subtle gradient to emulate light reflection
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.15, 0.15, 0.15, 0.6) }
            GradientStop { position: 1.0; color: Qt.rgba(0.05, 0.05, 0.05, 0.8) }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            TextField {
                id: searchInput
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                font.pixelSize: 24
                placeholderText: "Search apps..."
                color: "#FFFFFF"
                background: Rectangle { // No border, just text
                    color: "transparent"
                }
                
                // Keep focus here when the window is shown
                focus: true

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
                    if (resultsModel.count > 0) {
                        resultsList.currentIndex = Math.min(resultsList.currentIndex + 1, resultsModel.count - 1)
                    }
                }
                Keys.onUpPressed: {
                    if (resultsModel.count > 0) {
                        resultsList.currentIndex = Math.max(resultsList.currentIndex - 1, 0)
                    }
                }
                Keys.onReturnPressed: {
                    if (resultsList.currentIndex >= 0 && resultsList.currentIndex < resultsModel.count) {
                        var item = resultsModel.get(resultsList.currentIndex)
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

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.1)
            }

            ListView {
                id: resultsList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                model: ListModel {
                    id: resultsModel
                }

                delegate: Rectangle {
                    width: resultsList.width
                    height: 60
                    radius: 8
                    
                    // Highlight selected item with glass effect
                    color: resultsList.currentIndex === index ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        
                        Image {
                            width: 36
                            height: 36
                            source: model.path ? "image://fileicon/" + model.path : ""
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: model.name
                                color: "#FFFFFF"
                                font.pixelSize: 18
                                font.weight: Font.Medium
                                Layout.fillWidth: true
                            }
                            Text {
                                text: model.path
                                color: "#A0A0A0"
                                font.pixelSize: 12
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            resultsList.currentIndex = index
                        }
                        onClicked: {
                            resultsList.currentIndex = index
                            Backend.launch(model.path)
                            root.hide()
                            searchInput.text = ""
                        }
                    }
                }
            }
        }
    }
}
