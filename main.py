import sys
from PySide2.QtWidgets import QApplication
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtCore import QObject, Signal, Slot


class MainWindow(QObject):

    def __init__(self):
        QObject.__init__(self)

    showToast = Signal(str)

    @Slot(str)
    def trimVideo(self, path):
        pass


if __name__ == '__main__':
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    main = MainWindow()

    engine.rootContext().setContextProperty('backend', main)
    engine.load('main.qml')

    sys.exit(app.exec_())
