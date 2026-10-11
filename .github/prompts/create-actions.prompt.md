---
description: "Створення GitHub Actions workflow і CI-скриптів для кросплатформного C++-проєкту з CMake, GoogleTest / CTest та артефактами збірки."
agent: build-engineer
---

# create-actions

## 1. Призначення

Команда `create-actions` призначена для генерації GitHub Actions workflow і CI-скриптів після успішного локального складання та проходження `BasicAddition` через CTest. Вона має використовувати skill `github-actions`, забезпечити запуск на Ubuntu, Windows і macOS, а також гарантувати, що конфігурація CI виконує збірку та тести без дублювання команд у `ci.yml` і без приховування помилок.

Команда не є просто формальним шаблоном: вона має бути придатною для реального виконання агентом у репозиторії, де вже є кореневий `CMakeLists.txt`, `src/main.cpp`, `tests/BasicAdditionTest.cpp` і локально успішні результати збірки та тестів.

## 2. Передумови

Перед виконанням команди агент повинен підтвердити, що:

- репозиторій доступний і має коректну структуру проєкту;
- кореневий `CMakeLists.txt` існує і налаштований для C++-проєкту;
- `src/main.cpp` існує і містить виконуваний `main()`;
- `tests/BasicAdditionTest.cpp` існує і містить GoogleTest-тест `TEST(MathTest, BasicAddition)` з перевіркою `add(2, 3) == 5`;
- локальний CMake-цікл пройшов успішно: `cmake -S . -B build`, `cmake --build ...` і `ctest ...` без помилок;
- `hello` або `hello.exe` генерується локально в збірці;
- `.gitignore` налаштовано для `build/` та локальних артефактів збірки;
- `README.md` і `docs/architecture.md` не змінюються без необхідності;
- файл `.github/workflows/ci.yml` або скрипти `ci.sh` / `ci.bat` ще не створені або є коректними і не потребують небезпечного перезапису.

Якщо будь-яка з передумов не підтверджена, команда має зупинитися і повідомити точну причину помилки.

## 3. Вхідні дані

Команда приймає такі параметри:

- назва репозиторію;
- гілки запуску: `develop` і `main`;
- платформи: `ubuntu-latest`, `windows-latest`, `macos-latest`;
- тип checkout: `actions/checkout`;
- сценарії CI: `ci.sh` для Linux/macOS, `ci.bat` для Windows;
- структура проєкту: `src/`, `tests/`, `build/`.

Приклад вхідних даних:

```text
Repository: ai-agent-cpp-lab1
Branches: develop, main
Platforms: ubuntu-latest, windows-latest, macos-latest
Build system: CMake
Test runner: CTest / GoogleTest
Scripts: ci.sh, ci.bat
Artifacts: hello, hello.exe
```

## 4. Послідовність дій агента

Команда повинна діяти послідовно і безпечно:

1. Перевірити наявність кореневого `CMakeLists.txt`, `src/main.cpp` і `tests/BasicAdditionTest.cpp`.
2. Перевірити, що локальна збірка та тестування вже пройшли успішно, оскільки `create-actions` не повинен запускатися на непідготовленому проєкті.
3. Перевірити, що workflow або CI-скрипти не дублюються і що виконуються правила безпечного повторного запуску.
4. Створити каталог `.github/workflows/`, якщо він відсутній.
5. Створити файл `.github/workflows/ci.yml` з одним job і matrix для `ubuntu-latest`, `windows-latest` і `macos-latest`.
6. У кожному matrix-запуску виконати `actions/checkout`.
7. Для Linux/macOS викликати `bash ./ci.sh`.
8. Для Windows викликати `cmd /c ci.bat`.
9. Забезпечити, що `ci.yml` не дублює команди складання й тестування безпосередньо в workflow, якщо вони вже реалізовані в скриптах.
10. Створити `ci.sh` для Linux/macOS і `ci.bat` для Windows. У кожному скрипті виконати:
    - конфігурацію CMake;
    - збірку проекту;
    - запуск `ctest`;
    - перевірку результатів тесту `BasicAddition`;
    - завершення зі статусом помилки при будь-якому збоях.
11. Для Windows врахувати багатоконфігураційний режим: `cmake --build build --config Debug` і `ctest --test-dir build -C Debug --output-on-failure`.
12. Для Linux/macOS використовувати відповідні команди CMake/CTest без `--config`.
13. Використовувати `actions/upload-artifact` для збереження `hello` або `hello.exe` з актуального каталогу вихідних файлів, зокрема `build/Debug/hello.exe` для Visual Studio.
14. Дати окремі назви artifact для кожної ОС, наприклад `hello-linux`, `hello-windows`, `hello-macos`, щоб уникнути конфліктів між артефактами.
15. Перевірити, що `build/` і інші локальні бінарні артефакти не додаються до Git.
16. Перевірити синтаксис YAML, наявність matrix з трьома ОС, правильні виклики скриптів і коректні artifact-етапи.
17. Розрізнити локальну перевірку workflow-файлів від фактичної перевірки GitHub Actions після `push` або `pull_request`.
18. У разі помилки CMake, компілятора, скрипта, `ctest` або artifact-етапу — зупинити orchestrator і пояснити точну причину.

## 5. Очікувана структура файлів

Після успішного виконання `create-actions` повинна бути така структура:

```text
.github/
  workflows/
    ci.yml
ci.sh
ci.bat
CMakeLists.txt
src/
  main.cpp
tests/
  BasicAdditionTest.cpp
build/
```

Зверніть увагу:

- `build/` — локальний каталог збірки, не має потрапляти до Git;
- `ci.yml` запускає matrix job для трьох ОС;
- `ci.sh` і `ci.bat` містять лише виконання CMake і CTest;
- `README.md`, `docs/architecture.md` не змінюються без обґрунтованої потреби;
- workflow і CI-скрипти не дублюються при повторному запуску;
- `ci.sh`, `ci.bat` і workflow не створюються повторно, якщо вже існують і коректні.

## 6. Правила для ci.yml, ci.sh і ci.bat

### 6.1. ci.yml

Файл `.github/workflows/ci.yml` має:

- тригеритися на `push` і `pull_request` до `develop` і `main`;
- містити одну job з `strategy.matrix.os` для `ubuntu-latest`, `windows-latest`, `macos-latest`;
- використовувати `actions/checkout` у кожному запуску;
- викликати `bash ./ci.sh` для Linux/macOS;
- викликати `cmd /c ci.bat` для Windows;
- використовувати `actions/upload-artifact` для збереження `hello` або `hello.exe`;
- мати окремі `name` або `path` artifact для кожної ОС;
- використовувати `if-no-files-found: error` для `upload-artifact`, щоб відсутність `hello` або `hello.exe` призводила до помилки CI;
- форматувати YAML синтаксично коректно;
- не дублювати команди збірки та тесту безпосередньо в workflow, якщо уже покладено на скрипти.

### 6.2. ci.sh

`ci.sh` для Linux/macOS має:

- починатися з `set -euo pipefail`;
- виконувати `cmake -S . -B build`;
- виконувати `cmake --build build`;
- виконувати `ctest --test-dir build --output-on-failure`;
- завершуватися з ненульовим кодом при збоях;
- не приховувати помилки збірки або тестів;
- використовувати локальні шляхи до виконуваного файлу `hello` для artifact upload.

### 6.3. ci.bat

`ci.bat` для Windows має:

- починатися з перевірки помилок після кожної критичної команди;
- виконувати `cmake -S . -B build` і після неї перевіряти `if errorlevel 1 exit /b 1`;
- виконувати `cmake --build build --config Debug` і після неї перевіряти `if errorlevel 1 exit /b 1`;
- виконувати `ctest --test-dir build -C Debug --output-on-failure` і після неї перевіряти `if errorlevel 1 exit /b 1`;
- завершуватися з ненульовим кодом при помилках;
- не маскувати помилки або невдачі тестів;
- вказувати коректний шлях до `hello.exe`, зокрема `build\Debug\hello.exe` для Visual Studio.

## 7. Локальні перевірки

Перед завершенням команді потрібно провести локальні перевірки без запуску реального GitHub Actions:

1. Перевірити, що `.github/workflows/ci.yml` створено і має синтаксично коректний YAML.
2. Перевірити, що `ci.sh` і `ci.bat` існують і містять команди CMake та CTest.
3. Перевірити, що матриця OS містить `ubuntu-latest`, `windows-latest` і `macos-latest`.
4. Перевірити, що `actions/checkout` є в кожному запуску.
5. Перевірити, що `bash ./ci.sh` і `cmd /c ci.bat` викликаються коректно в залежності від ОС.
6. Перевірити, що artifact upload відслідковує реальний бінарний файл для кожної ОС і що `if-no-files-found: error` активовано, щоб відсутність `hello` або `hello.exe` спричиняла помилку CI.
7. Перевірити, що `build/` і інші локальні артефакти не входять до Git.
8. Якщо локальна перевірка завершується з помилкою, повідомити точну причину і зупинити orchestrator.

Важливо відрізняти:

- локальну перевірку workflow і скриптів;
- фактичну перевірку GitHub Actions тільки після `push` або `pull_request`;
- реальний PASS лише після успішного запуску jobs у GitHub Actions.

## 8. Критерії успіху

Команда `create-actions` вважається успішною, якщо:

- створено `.github/workflows/ci.yml`;
- створено `ci.sh` і `ci.bat`;
- workflow запускається при `push` і `pull_request` до `develop` і `main`;
- job містить matrix для `ubuntu-latest`, `windows-latest`, `macos-latest`;
- кожен matrix-випуск виконує `actions/checkout`;
- Linux/macOS викликають `bash ./ci.sh`, а Windows — `cmd /c ci.bat`;
- скрипти виконують CMake config, build і `ctest` без дублювання команди в YAML;
- `actions/upload-artifact` зберігає `hello` або `hello.exe` з правильного каталогу для кожної ОС і має `if-no-files-found: error`;
- назви artifact для кожної ОС унікальні;
- локальна валідація workflow і скриптів пройдена;
- `build/` і інші локальні результати не додаються до Git;
- повторний запуск не дублює workflow, скрипти або ARTIFACT-налаштування;
- `README.md`, `docs/architecture.md`, `ci.sh` і `ci.bat` не змінюються без необхідності.

## 9. Типові помилки та їх обробка

### Типові помилки

- workflow не містить matrix для трьох ОС;
- `ci.sh` або `ci.bat` відсутні або неправильно названі;
- `ci.yml` викликає команди збірки безпосередньо, дублюючи логіку скриптів;
- Windows-скрипт використовує неправильний шлях до `hello.exe`;
- `ctest` падає через невдалий `BasicAddition` тест;
- `actions/upload-artifact` не знаходить коректний бінарний файл або відсутній `hello` / `hello.exe` при `if-no-files-found: error`;
- YAML має синтаксичну помилку;
- `build/` або інші артефакти потрапляють до Git;
- workflow запускається, але реальний GitHub Actions status ще не підтверджений.

### Порядок обробки

1. Показати точний текст помилки з YAML, shell-скрипта або CTest.
2. Зупинити виконання orchestrator і не продовжувати наступні кроки.
3. Перевірити, чи присутні `ci.sh`, `ci.bat` і `.github/workflows/ci.yml`.
4. Перевірити, що matrix містить три ОС і що `actions/checkout` виконується у кожному job.
5. Перевірити, що `ci.sh`/`ci.bat` повністю контролюють CMake config, build і `ctest`.
6. Перевірити правильний шлях до `hello` або `hello.exe` для each OS.
7. Не позначати GitHub Actions як PASS без реального успішного виконання jobs.
8. Не перезаписувати коректні файли workflow або скриптів без розумного обґрунтування.

## 10. Приклад виконання

```text
Вхідні дані:
Repository: ai-agent-cpp-lab1
Branches: develop, main
Platforms: ubuntu-latest, windows-latest, macos-latest
Build system: CMake
Test runner: CTest
Artifacts: hello, hello.exe

Дії:
- перевірено наявність CMakeLists.txt, src/main.cpp і tests/BasicAdditionTest.cpp;
- перевірено, що локальна збірка та CTest пройшли успішно;
- створено .github/workflows/ci.yml з matrix на ubuntu-latest, windows-latest і macos-latest;
- створено ci.sh для Linux/macOS і ci.bat для Windows;
- workflow викликає checkout і запускає platform-specific сценарії;
- скрипти виконують CMake config, build і CTest;
- додано actions/upload-artifact з `if-no-files-found: error` та назвами hello-linux, hello-windows, hello-macos;
- перевірено, що build/ не потрапляє у Git.

Результат:
Локальна валідація workflow і скриптів: OK
Фактичний GitHub Actions status: not verified until jobs run on GitHub
```

## 11. Правила безпеки та повторного виконання

Команда `create-actions` має:

- не перезаписувати коректні `ci.yml`, `ci.sh` або `ci.bat` без попереднього аналізу;
- не дублювати workflow, artifact-етапи, target або скрипти, якщо вони вже існують і є коректними;
- не виконувати `commit`, `push`, `merge` чи `publish` без явної інструкції користувача;
- не змінювати `README.md`, `docs/architecture.md` або правила захисту гілок без необхідності;
- бути безпечною для повторного запуску;
- перевіряти поточний стан репозиторію перед модифікаціями;
- зупинятися при першій помилці зі скрипта, workflow або artifact-вивантаження.

## 12. Підсумок

Команда `create-actions` завершує цикл автоматизації C++-проєкту після локальної збірки та тестування. Вона створює GitHub Actions workflow з matrix для Ubuntu, Windows і macOS, організовує запуск `ci.sh` і `ci.bat`, зберігає артефакти збірки, а також гарантує, що локальна перевірка workflow і скриптів відбувається без приховування помилок, а фактичний GitHub Actions результат підтверджується лише реальним запуском jobs.
