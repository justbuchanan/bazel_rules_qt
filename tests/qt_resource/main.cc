#include <QtCore/QFile>
#include <iostream>

int main(int argc, char** argv) {
  QString path = ":tests/qt_resource/file1.txt";
  QFile file(path);

  if (!file.open(QIODevice::ReadOnly)) {
    std::cerr << "failed to open resource file" << std::endl;
    exit(1);
  }

  std::cerr << "opened resource file" << std::endl;
  QString data = file.readAll();
  file.close();

  std::cout << data.toStdString() << std::endl;
}