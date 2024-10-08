import QtQuick 6.7
import QtQuick.Controls 6.7
import QtQuick.Layouts 6.7
import QtQuick.Controls.Material 6.7
import QtQuick.Dialogs 6.7

Item {
    id: imagePage
    width: parent.width
    height: parent.height

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(parent.height * 0.7, 300)
            color: "transparent"
            border.width: 2
            border.color: dropArea.containsDrag ? Material.accent : "lightgray"
            radius: 8

            DropArea {
                id: dropArea
                anchors.fill: parent
                onEntered: (drag) => { drag.accept(Qt.LinkAction); }
                onDropped: (drop) => { handleDrop(drop) }

                Image {
                    id: imagePreview
                    anchors.fill: parent
                    anchors.margins: 4
                    fillMode: Image.PreserveAspectFit
                    visible: source.toString() !== ""
                    opacity: dropArea.containsDrag ? 0.7 : 1

                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 10
                    visible: imagePreview.source.toString() === ""

                    Image {
                        Layout.alignment: Qt.AlignHCenter
                        source: "qrc:/resources/icons/upload.svg"
                        width: 48
                        height: 48
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        color: "white"
                        text: "Drag and drop an image here\nor click to select"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: fileDialog.open()
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: imagePreview.source.toString() !== ""
            spacing: 2

            ToolButton {
                icon.source: "qrc:/resources/icons/upload.svg"
                onClicked: fileDialog.open()
            }

            ToolButton {
                icon.source: "qrc:/resources/icons/trash.svg"

                onClicked: {
                    imagePreview.source = ""
                    videoController.background = { "type": "color", "value": "#000000" }
                    if (!isPlaying) {
                        videoController.get_current_frame()
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            color: "white"
            text: imagePreview.source.toString() !== ""
                ? "Current image: " + imagePreview.source.toString().split('/').pop()
                : "No image selected"
            elide: Text.ElideMiddle
            font.italic: true
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    FileDialog {
        id: fileDialog
        title: "Select an image"
        nameFilters: ["Image files (*.png *.jpg *.jpeg *.bmp)"]
        onAccepted: {
            handleFileSelection(selectedFile)
        }
    }

    function handleDrop(drop) {
        if (drop.hasUrls) {
            imagePreview.source = drop.urls[0]
            updateBackgroundImage(drop.urls[0])
        }
    }

    function handleFileSelection(file) {
        imagePreview.source = file
        updateBackgroundImage(file)
    }

    function updateBackgroundImage(file) {
        videoController.background = {
            "type": "image",
            "value": file
        }
        if (!isPlaying) {
            videoController.get_current_frame()
        }
    }
}