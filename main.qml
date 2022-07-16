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
                    onTriggered: backend.trimVideo(openDialog.file, toHMS(videoSlider.first.value), toHMS(videoSlider.second.value))
                }
                ,
                Action {
                    text: "About"
                    icon.name: "help-about-symbolic"
                    displayHint: Action.DisplayHint.AlwaysHide
                    onTriggered: aboutDialog.open()
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
                autoPlay: true
                focus: true
                Keys.onSpacePressed: {
                    videoView.playbackState == MediaPlayer.PlayingState ? videoView.pause() : videoView.play()
                }

                onStatusChanged: {
                    if(status == 6){
                        videoSlider.from = 0
                        videoSlider.to = videoView.duration
                        videoSlider.first.value = 0
                        videoSlider.second.value = videoView.duration
                        endField.text = toHMS(videoView.duration)
                        startField.text = "00:00:00"
                    }else {
                        console.log(status)
                    }
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
                        startField.text = toHMS(first.value)
                    }

                    second.onMoved: {
                        videoView.pause()
                        videoView.seek(second.value)
                        endField.text = toHMS(second.value)
                    }
                }

            RowLayout {
                Controls.ToolButton {
                    icon.name: "media-playback-start-symbolic"
                    onClicked: {
                        if(videoView.playbackState == MediaPlayer.PlayingState){
                           videoView.pause()
                           icon.name = "media-playback-start-symbolic"
                        }else {
                            videoView.seek(videoSlider.first.value)
                            videoView.play()
                            icon.name = "media-playback-pause-symbolic"
                        }
                    }
                }
                Controls.Label {
                    text: "Start"
                }
                Controls.TextField {
                    id: startField
                    text: "00:00:00"
                    Layout.fillWidth: true
                }

                Controls.Label {
                    text: "End"
                }

                Controls.TextField {
                    id: endField
                    Layout.fillWidth: true
                    text: "00:00:00"
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

    function toHMS(ms){
        return new Date(ms).toISOString().substr(11, 8);
    }

    Connections {
        target: backend

        function onShowToast(message){
            showPassiveNotification(message)
        }
    }
}
