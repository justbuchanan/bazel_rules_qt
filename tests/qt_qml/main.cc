#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtQuick/QQuickView>
#include <QtWidgets/QApplication>
#include <iostream>

int main(int argc, char *argv[]) {
  QApplication app(argc, argv);
  app.setOrganizationName("justbuchanan");
  app.setApplicationName("bazel rules_qt qml demo");

  QQmlApplicationEngine engine(nullptr);
  engine.rootContext()->setContextProperty("main", &engine);

  // load main.qml from qt resources, which are baked into the binary. Path is
  // relative to the bazel workspace root.
  engine.load((QUrl("qrc:///tests/qt_qml/main.qml")));

  // get reference to main window from qml
  auto win = static_cast<QQuickView *>(engine.rootObjects()[0]);
  if (!win) {
    std::cerr << "Failed to load qml" << std::endl;
    exit(1);
  }

  win->show();

  return app.exec();
}
