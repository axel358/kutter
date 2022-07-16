import sys
import os
from PySide2.QtWidgets import QApplication
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtCore import QObject, Signal, Slot
import subprocess


class MainWindow(QObject):

    def __init__(self):
        QObject.__init__(self)

    showToast = Signal(str)

    @Slot(str, str, str)
    def trimVideo(self, path, start, end):
        video = path.replace('file://', '')
        output = os.path.splitext(video)[0] + ' (trimmed) ' + '.' + os.path.splitext(video)[1]
        subprocess.run(['ffmpeg', '-i', video, '-ss', start, '-to', end, '-c', 'copy', output])
        self.showToast.emit('Trimed and saved as ' + output)


if __name__ == '__main__':
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    main = MainWindow()

    engine.rootContext().setContextProperty('backend', main)
    engine.load('main.qml')

    sys.exit(app.exec_())
