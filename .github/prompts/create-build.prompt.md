---
description: "Налаштування CMake, GoogleTest / CTest і базового тесту BasicAddition для C++ Hello World без небезпечних змін під час повторного запуску orchestrator."
agent: build-engineer
---

# create-build

## 1. Призначення

Команда `create-build` призначена для підготовки кореневої системи складання C++-проєкту на основі CMake після успішного виконання `create-project`. Вона має використовувати інструкції skill `build-and-test`, забезпечити стабільну кросплатформну збірку для MSVC, GCC і Clang, налаштувати базовий тест `BasicAddition` через GoogleTest / CTest і зберегти безпечний режим повторного запуску.

Команда не створює проект «з нуля» без перевірки поточного стану репозиторію. Вона працює у безпечному режимі, перевіряє наявні файли, а якщо конфігурація вже існує і є коректною — не перезаписує її без аналізу.

## 2. Передумови

Перш ніж виконувати `create-build`, агент повинен підтвердити, що:

- репозиторій доступний і має коректну структуру проєкту;
- команда `create-project` виконана або її результати підтверджені;
- файл `src/main.cpp` існує і містить мінімальний Hello World entry point;
- коренева папка проєкту готова до генерації CMake;
- `README.md` і `docs/architecture.md` не змінюються без необхідності;
- `build/` або аналогічний каталог збірки буде використовуватись лише як локальний артефакт і не буде потрапляти до Git без відповідного `.gitignore` правила.

Якщо будь-яка з цих передумов не виконана, команда має зупинитися і повідомити точну причину помилки.

## 3. Вхідні дані

Команда приймає такі параметри:

- назва проєкту;
- шлях до репозиторію;
- мова програмування: `C++`;
- базовий шаблон: Hello World;
- компілятор: `MSVC`, `GCC` або `Clang`;
- тип генератора CMake і платформа: Windows, Linux або macOS;
- каталог збірки: `build/`.

Типовий вхідний сценарій:

```text
Project name: hello-cpp-demo
Repository path: C:/workspace/hello-cpp-demo
Language: C++
Template: Hello World
Compiler: MSVC / GCC / Clang
Build directory: build/
Target: hello
```

## 4. Послідовність реальних дій агента

Команда повинна виконуватися послідовно і безпечно:

1. Перевірити поточний стан репозиторію та підтвердити наявність результатів `create-project`.
2. Перевірити, що `src/main.cpp` існує та містить `main()`.
3. Перевірити відсутність конфліктного або пошкодженого `CMakeLists.txt` перед його генерацією.
4. Якщо `CMakeLists.txt` вже існує і є коректним, не перезаписувати його без аналізу; якщо він відсутній — створити новий кореневий файл.
5. Створити кореневий `CMakeLists.txt` для C++-проєкту, який:
   - задає мінімальну версію CMake;
   - встановлює мову `C++`;
   - визначає виконуваний target `hello`;
   - підключає `src/main.cpp` як частину target;
   - налаштовує `FetchContent` для GoogleTest / CTest;
   - створює окремий executable target для тесту `basic_addition_test`, пов’язаний з GoogleTest і модулем `math_utils`;
   - активує `enable_testing()` або `include(CTest)`;
   - реєструє тест через `add_test(NAME BasicAddition COMMAND basic_addition_test)` без дублювання `gtest_discover_tests` для того самого тесту.
6. Розмістити логіку додавання у окремому заголовку і/або файлі реалізації, наприклад `src/math_utils.h` і `src/math_utils.cpp`, з функцією `add(int a, int b)`.
7. Забезпечити, щоб `add()` була доступна для тесту без конфлікту з `main()`. Для цього логіку слід виділити в окремий модуль, а не вкладати її безпосередньо в `main.cpp`.
8. Створити `tests/BasicAdditionTest.cpp` з GoogleTest-тестом `TEST(MathTest, BasicAddition)`, який перевіряє `add(2, 3) == 5`.
9. Підключити GoogleTest через CMake `FetchContent` з фіксованою версією залежності та локальним, відтворюваним способом завантаження. Якщо мережевий доступ недоступний, повідомити про помилку завантаження та зупинити orchestrator.
10. Увімкнути `CTest` і зареєструвати тест `BasicAddition` через `add_test(NAME BasicAddition COMMAND basic_addition_test)`, щоб CTest бачив тест з точною назвою `BasicAddition`.
11. Додати правила `gitignore` для `build/` і локальних артефактів складання, якщо це необхідно і якщо це ще не зроблено; не змінювати README.md, docs/architecture.md, GitHub Actions, `ci.sh` і `ci.bat` без потреби.
12. Перевірити, що повторний запуск не дублює target-цілі, тестові файли, залежності або конфігурації.
13. Перед завершенням перевірити локальну збірку через реальні команди CMake і CTest, включаючи `ctest --test-dir build -C Debug -N` і `ctest --test-dir build -C Debug --output-on-failure`.
14. Якщо виявлено помилку CMake, компілятора, GoogleTest або тесту — зупинити orchestrator і пояснити причину.

## 5. Очікувані файли

Після успішного виконання `create-build` у репозиторії мають бути присутніми мінімальні файли:

```text
<repo>/
  CMakeLists.txt
  src/
    main.cpp
    math_utils.h
    math_utils.cpp
  tests/
    BasicAdditionTest.cpp
  build/
```

Зверніть увагу:

- `README.md` і `docs/architecture.md` не слід змінювати без абсолютної потреби;
- `build/` є локальним каталогом збірки і має ігноруватися Git;
- `CMakeLists.txt`, тестові файли і залежності GoogleTest не створюються повторно, якщо вони вже існують і коректні;
- `ci.sh`, `ci.bat` і workflow GitHub Actions не генеруються на цьому етапі і не повинні змінюватися без необхідності.

## 6. Команди перевірки

Команда повинна виконувати реальні локальні перевірки, відповідно до платформи:

### Загальний сценарій

```bash
cmake -S . -B build
cmake --build build --config Debug
ctest --test-dir build -C Debug -N
ctest --test-dir build -C Debug --output-on-failure
```

### Для Linux/macOS

```bash
cmake -S . -B build
cmake --build build
ctest --test-dir build -N
ctest --test-dir build --output-on-failure
```

### Важливі відмінності

- Для одноконфігураційних генераторів (наприклад `Unix Makefiles`, Ninja) використовується стандартний `cmake --build build` без `--config`.
- Для багатоконфігураційних генераторів (наприклад Visual Studio) потрібний параметр `--config Debug`, а також `ctest --test-dir build -C Debug`.
- Для Windows компілятор може бути MSVC; для Linux/macOS — GCC або Clang.
- Для перевірки реєстрації тесту слід виконувати `ctest --test-dir build -C Debug -N`; для виконання тесту — `ctest --test-dir build -C Debug --output-on-failure`.

Агент має перевіряти фактичний результат виконання цих команд, а не лише припускати, що збірка або тести пройшли успішно. Не повідомляти PASS без реального виконання CTest.

## 7. Критерії успіху

Команда `create-build` вважається успішною, якщо:

- `CMakeLists.txt` створено або оновлено без перезапису коректної конфігурації;
- `hello` target відповідає вимогам C++ Hello World-проєкту;
- логіка додавання реалізована в окремому модулі, наприклад `add(int a, int b)`;
- `tests/BasicAdditionTest.cpp` містить `TEST(MathTest, BasicAddition)` і перевіряє `add(2, 3) == 5`;
- створено окремий executable target `basic_addition_test`, пов’язаний з GoogleTest і `math_utils`;
- `enable_testing()` або `include(CTest)` увімкнено;
- `CTest` зареєстровано через `add_test(NAME BasicAddition COMMAND basic_addition_test)` без дублювання `gtest_discover_tests` для того самого тесту;
- локальна збірка проходить через `cmake` і `ctest` без помилок, включаючи `ctest --test-dir build -C Debug -N` і `ctest --test-dir build -C Debug --output-on-failure`;
- повторний запуск не дублює target, файли або налаштування;
- `build/` і інші локальні артефакти складання відсутні у Git-стеженні;
- `README.md`, `docs/architecture.md`, GitHub Actions, `ci.sh` і `ci.bat` не змінюються без обґрунтованої необхідності.

## 8. Типові помилки та їх обробка

### Типові помилки

- `src/main.cpp` відсутній або не є коректним entry point;
- CMakeLists.txt є пошкодженим або конфліктує з існуючою конфігурацією;
- компілятор не знайдений або не налаштований для платформи;
- GoogleTest не завантажується через `FetchContent`;
- `FetchContent` вимагає доступу до мережі, а доступ відсутній;
- функція `add()` реалізована всередині `main.cpp`, через що вона недоступна для unit-теста;
- `BasicAddition` тест не реєструється в CTest;
- CTest повертає помилку через неправильний результат расчунку;
- локальний каталог збірки потрапляє до Git.

### Порядок обробки

1. Виявити точну причину помилки за текстом `CMake`, компілятора або `ctest`.
2. Зупинити виконання `create-build` і не дозволяти наступним етапам orchestrator продовжувати роботу.
3. Перевірити наявність `src/main.cpp`, `CMakeLists.txt`, `math_utils.*` і `tests/BasicAdditionTest.cpp`.
4. Перевірити використання `FetchContent` для GoogleTest і фіксовану версію залежності.
5. Якщо помилка пов’язана з доступом до мережі або відсутністю компілятора, зафіксувати це як блокуючу причину.
6. Не маскувати помилки і не повідомляти PASS, якщо реальна збірка або тестування не виконані.
7. Зберегти коректні файли, не перезаписуючи їх без аналізу.

## 9. Приклад виконання

```text
Вхідні дані:
Project name: hello-cpp-demo
Repository path: C:/workspace/hello-cpp-demo
Compiler: GCC
Build directory: build/
Target: hello

Дії:
- перевірено присутність результатів create-project;
- підтверджено існування src/main.cpp;
- перевірено, що CMakeLists.txt відсутній або коректний і не потребує небезпечного перезапису;
- створено кореневий CMakeLists.txt з target hello;
- додано math_utils.h і math_utils.cpp з функцією add(int a, int b);
- створено tests/BasicAdditionTest.cpp з GoogleTest;
- налаштовано FetchContent для GoogleTest з фіксованою версією;
- увімкнено CTest і зареєстровано BasicAddition;
- виконано локальну перевірку через cmake і ctest;
- перевірено, що build/ не потрапляє до Git.

Результат:
CMake config: OK
Build: OK
BasicAddition: PASS
CTest: OK
```

## 10. Правила безпеки та повторного виконання

Команда `create-build` має:

- не перезаписувати коректний `CMakeLists.txt` без попереднього аналізу;
- не дублювати `math_utils.h`, `math_utils.cpp`, `BasicAdditionTest.cpp` або target `hello`, якщо вони вже існують і працюють;
- не створювати повторні конфігурації в уже налаштованому проєкті;
- не оновлювати `README.md`, `docs/architecture.md`, workflow GitHub Actions або CI-скрипти без необхідності;
- бути безпечною для повторного запуску;
- перевіряти поточний стан репозиторію перед модифікаціями;
- зупинятися при першій помилці CMake, компілятора, GoogleTest або тесту.

## 11. Підсумок

Команда `create-build` є ключовим етапом після `create-project`. Вона готує кореневу конфігурацію CMake, створює виконуваний target `hello`, організовує базову функцію `add(int a, int b)`, підключає GoogleTest / CTest і гарантує, що результати складання та тестування перевіряються реально до переходу до наступних етапів роботи агента.
