import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.19
import Qt.labs.platform 1.1
import QtMultimedia 5.15

ApplicationWindow
{
    id: root
    title: "Kutter"
    width: 600
    height: 480

    Page {
        id: page
        anchors.fill: parent

        header: Controls.ToolBar {
            Layout.fillWidth: true
            id: toolbar
            contentItem: ActionToolBar{
                actions: [
                Action {
                    text: "Open"
                    icon.name: "document-open-symbolic"
                    onTriggered: openDialog.open()
                },
                Action {
                    text: "Trim"
                    icon.name: "edit-cut-symbolic"
                    displayHint: Action.DisplayHint.KeepVisible
                    onTriggered: showPassiveNotification(videoView.duration + "")
                }
                ]
            }
        }

        ColumnLayout{
            anchors.fill: parent

            Video {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: videoView
                //autoPlay: true
                focus: true
                Keys.onSpacePressed: {
                    videoView.playbackState == MediaPlayer.PlayingState ? videoView.pause() : videoView.play()
                }

                onPlaying: {
                    videoSlider.from = 0
                    videoSlider.to = videoView.duration
                    endField.text = videoView.duration + ""
                }

                MouseArea {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    onClicked: {
                        videoView.playbackState == MediaPlayer.PlayingState ? videoView.pause() : videoView.play()
                    }
                }
            }

            Controls.RangeSlider {
                    id: videoSlider
                    Layout.fillWidth: true

                    first.onMoved: {
                        videoView.pause()
                        videoView.seek(first.value)
                    }

                    second.onMoved: {
                        videoView.pause()
                        videoView.seek(second.value)
                    }
                }

            RowLayout {
                Controls.ToolButton {
                    icon.name: "media-playback-start-symbolic"
                    onClicked: {
                        videoView.playbackState == MediaPlayer.PlayingState ? videoView.pause() : videoView.play()
                    }
                }
                Controls.Label {
                    text: "Start"
                }
                Controls.TextField {
                    id: startField
                    text: "0"
                    Layout.fillWidth: true
                }

                Controls.Label {
                    text: "End"
                }

                Controls.TextField {
                    id: endField
                    Layout.fillWidth: true
                }
            }

        }
    }
    FileDialog {
        id: openDialog
        title: "Open video"
        fileMode: FileDialog.OpenFile
        onAccepted: {
            videoView.source = file
        }
    }

    FileDialog {
        id: saveDialog
        title: "Save Dialog"
        //folder: myObjHasAPath? myObj.path: "file:///" //Here you can set your default folder
        fileMode: FileDialog.SaveFile
        onAccepted: {
            backend.downloadSub(languageCode, file, translateCode)
        }
    }

    PromptDialog {
        id: aboutDialog
        showCloseButton: false
        title: "About Kutter"
        subtitle: "Trim your videos fast and easy"
        standardButtons: Dialog.Ok
    }

    PromptDialog {
        id: trimmingDialog
        showCloseButton: false
        title: "Trimming..."
        subtitle: "Please wait"
        standardButtons: Dialog.Ok
    }

    Connections {
        target: backend

        function onShowToast(message){
            showPassiveNotification(message)
        }
    }
}
