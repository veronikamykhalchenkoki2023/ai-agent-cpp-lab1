---
description: "Діагностична перевірка готового C++-проєкту, його структури, локальної збірки, CTest і GitHub Actions-підготовки без змін у вихідних файлах."
agent: build-engineer
---

# check

## 1. Призначення

Команда `check` призначена для діагностичної перевірки повної готовності C++-проєкту до завершення лабораторної роботи. Вона має бути придатною для реального виконання агентом і перевіряти стан проєкту без внесення змін до вихідних файлів або конфігурацій. Основна мета — зафіксувати, чи проєкт відповідає вимогам лабораторної роботи: структурі репозиторію, локальній збірці, CTest, Git, GitHub Actions і захисту локальних артефактів.

Команда не є редактором проєкту. Вона лише аналізує поточний стан, виконує реальні перевірки і формує підсумковий звіт з результатами: `PASS`, `FAIL` або `NOT VERIFIED`.

## 2. Передумови

Перш ніж запускати `check`, агент повинен підтвердити, що:

- поточна папка є Git-репозиторієм або правильним коренем проєкту;
- `README.md` і `docs/architecture.md` доступні для перевірки;
- структура проєкту має бути створена відповідно до лабораторної роботи;
- якщо локальна збірка ще не виконувалася, команда `check` повинна спробувати виконати її реально і зафіксувати результат;
- GitHub Actions workflow і CI-скрипти перевіряються лише за їх наявності, але фактичний PASS віддаленого CI можливий лише за реальними логами GitHub Actions.

## 3. Вхідні дані
і
Команда приймає такі параметри:

- шлях до репозиторію;
- поточна гілка Git;
- коренева структура проєкту;
- платформа виконання: `Windows`, `Linux` або `macOS`;
- наявність або відсутність локальної збірки `build/`;
- наявність або відсутність `ci.yml`, `ci.sh`, `ci.bat`.

Приклад вхідних даних:

```text
Repository path: C:/workspace/ai-agent-cpp-lab1
Current branch: develop
OS: Windows
Project type: C++ / CMake / GoogleTest / CTest
Build dir: build/
```

## 4. Послідовність реальних перевірок

Команда `check` має виконуватися послідовно і безпечним способом:

1. Перевірити Git-репозиторій: `git rev-parse --is-inside-work-tree`.
2. Визначити поточну гілку: `git branch --show-current`.
3. Виконати `git status --short --branch` і зафіксувати поточний стан репозиторію.
4. Перевірити наявність основних файлів і директорій:
   - `README.md`
   - `docs/architecture.md`
   - `.gitignore`
   - `src/main.cpp`
   - `CMakeLists.txt`
   - `tests/BasicAdditionTest.cpp`
5. Перевірити наявність `.github/agents/build-engineer.agent.md`.
6. Перевірити наявність трьох skill-файлів:
   - `.github/skills/project-scaffold/SKILL.md`
   - `.github/skills/build-and-test/SKILL.md`
   - `.github/skills/github-actions/SKILL.md`
7. Перевірити наявність п’яти command prompt files:
   - `.github/prompts/git-init.prompt.md`
   - `.github/prompts/create-project.prompt.md`
   - `.github/prompts/create-build.prompt.md`
   - `.github/prompts/create-actions.prompt.md`
   - `.github/prompts/check.prompt.md`
8. Перевірити наявність orchestrator prompt-файлу `init.prompt.md` за очікуваною структурою проекту.
9. Перевірити, що в проєкті є target `hello` і тест `BasicAddition`.
10. Виконати реальні локальні команди CMake і CTest залежно від поточної операційної системи:
    - `cmake -S . -B build`
    - `cmake --build build --config Debug` для багатоконфігураційного генератора або `cmake --build build` для одноконфігураційного генератора
    - `ctest --test-dir build -C Debug -N`
    - `ctest --test-dir build -C Debug --output-on-failure`
11. Для Linux/macOS використовувати відповідні локальні варіанти CMake/CTest без `--config` там, де це не потрібно.
12. Перевірити, що `hello` або `hello.exe` реально створено в відповідному каталозі збірки.
13. Якщо можливо, запустити виконуваний файл і перевірити його вихід, який має містити інформацію Hello World.
14. Перевірити, що `BasicAddition` зареєстровано в CTest і успішно проходить.
15. Перевірити `build/` і інші локальні артефакти на наявність виключень у Git: `git check-ignore -v` для `build/hello`, `build/Debug/hello.exe` або аналогічних локальних шляхів.
16. Перевірити `.github/workflows/ci.yml` на наявність:
    - trigger на `push` і `pull_request` для `develop` і `main`;
    - одна job із `matrix.os` для `ubuntu-latest`, `windows-latest`, `macos-latest`;
    - `actions/checkout`;
    - виклик `ci.sh` або `ci.bat` залежно від ОС;
    - `actions/upload-artifact`;
    - `if-no-files-found: error`.
17. Перевірити, що `ci.sh` і `ci.bat` містять CMake configure/build і CTest, а також обробку помилок через завершення з ненульовим кодом.
18. Якщо локальний сценарій поточної ОС доступний, виконати його реально. Не припускати, що інші ОС виконані локально.
19. Розмежувати:
    - локальні перевірки;
    - фактичний результат GitHub Actions після `push` або `pull_request`.
20. Якщо локальна перевірка не пройшла або CMake/CTest не працюють, зупинити виконання `check` і повідомити точну причину, місце проблеми та рекомендацію щодо виправлення.
21. Не позначати віддалений GitHub Actions як `PASS`, якщо реальних логів виконання workflow немає.

## 5. Критерії PASS / FAIL / NOT VERIFIED

### Local check: PASS

Локальний результат команди `check` має статус `PASS`, якщо всі обов’язкові локальні перевірки успішні:

- Git-репозиторій підтверджено;
- поточна гілка визначена і `git status` без критичних помилок;
- всі обов’язкові файли та каталоги присутні;
- `CMakeLists.txt` і `tests/BasicAdditionTest.cpp` знайдені;
- `hello` target і `BasicAddition` test наявні;
- локальна конфігурація CMake пройшла;
- локальна збірка пройшла;
- `ctest --test-dir build -C Debug -N` показує реєстрований тест `BasicAddition`;
- `ctest --test-dir build -C Debug --output-on-failure` завершився успішно;
- `hello` або `hello.exe` реально створений і, якщо можливо, працює;
- `build/` і локальні артефакти не потрапляють до Git;
- `.github/workflows/ci.yml`, `ci.sh` і `ci.bat` відповідають вимогам workflow;
- локальна структура, Git, CMake, CTest, Hello World, BasicAddition і CI-конфігурація всі успішні.

### Local check: FAIL

Локальний результат команди `check` має статус `FAIL`, якщо хоча б одна обов’язкова локальна перевірка завершується з помилкою:

- відсутній один або кілька обов’язкових файлів;
- `CMake` або `ctest` не виконується;
- скомпільована збірка або тест недоступні;
- `BasicAddition` не зареєстрований або не проходить;
- бінарний файл `hello` або `hello.exe` не створений;
- workflow або CI-скрипти мають конфлікти або синтаксичні помилки;
- `build/` не ігнорується Git;
- будь-яка критична локальна перевірка завершилася помилкою.

### Remote GitHub Actions: NOT VERIFIED

Фактичний статус віддаленого GitHub Actions має бути `NOT VERIFIED`, якщо:

- workflow ще не запускався;
- немає підтверджених логів виконання jobs;
- одна або кілька платформ не були перевірені у реальному GitHub Actions;
- локальний workflow виглядає коректно, але віддалений запуск не підтверджений фактично.

Відсутність запуску віддаленого CI сама по собі не повинна спричиняти `FAIL` або блокувати успішне завершення локального orchestrator init. Це не означає, що лабораторна робота повністю завершена: повна лабораторна робота вважається підтвердженою лише після успішного GitHub Actions на Windows, Linux і macOS.

У підсумковому звіті потрібно окремо відображати:

- `Local check status: PASS / FAIL`
- `Remote CI status: PASS / FAIL / NOT VERIFIED`

Це розмежування є обов’язковим.

## 6. Структура підсумкового звіту перевірки

Після виконання `check` агент має сформувати звіт у такій структурі:

```text
=== CHECK REPORT ===
1. Repository status
   - git repo: PASS/FAIL
   - current branch: <branch or unknown>
   - git status: <summary>

2. Project structure
   - README.md: PASS/FAIL
   - docs/architecture.md: PASS/FAIL
   - .gitignore: PASS/FAIL
   - src/main.cpp: PASS/FAIL
   - CMakeLists.txt: PASS/FAIL
   - tests/BasicAdditionTest.cpp: PASS/FAIL
   - build-engineer.agent.md: PASS/FAIL
   - three skills: PASS/FAIL
   - five command prompts: PASS/FAIL
   - orchestrator init.prompt.md: PASS/FAIL

3. Build and tests
   - cmake configure: PASS/FAIL
   - build: PASS/FAIL
   - ctest listing: PASS/FAIL
   - ctest execution: PASS/FAIL
   - hello / hello.exe exists: PASS/FAIL
   - Hello World output: PASS/FAIL/NOT VERIFIED
   - BasicAddition registration: PASS/FAIL
   - BasicAddition result: PASS/FAIL

4. Git and artifacts
   - build/ ignored by Git: PASS/FAIL/NOT VERIFIED

5. CI configuration (local validation)
   - ci.yml exists: PASS/FAIL
   - push/pull_request triggers: PASS/FAIL
   - matrix OS: PASS/FAIL
   - checkout: PASS/FAIL
   - script call: PASS/FAIL
   - artifact upload: PASS/FAIL
   - if-no-files-found: error: PASS/FAIL

6. Final status
   - Local check status: PASS / FAIL
   - Remote CI status: PASS / FAIL / NOT VERIFIED
   - reason summary
   - recommended fix
=== END REPORT ===
```

Локальний результат `check` і віддалений GitHub Actions є окремими результатами. У цьому розділі не можна підміняти один інший.

## 7. Послідовність реальних перевірок з командами

Команда `check` має виконувати такі реальні перевірки:

### 7.1. Git

```bash
git rev-parse --is-inside-work-tree
git branch --show-current
git status --short --branch
```

### 7.2. CMake і CTest

Для Windows (MSVC / багатоконфігураційний генератор):

```powershell
cmake -S . -B build
cmake --build build --config Debug
ctest --test-dir build -C Debug -N
ctest --test-dir build -C Debug --output-on-failure
```

Для Linux/macOS (GCC / Clang / одноконфігураційні генератори):

```bash
cmake -S . -B build
cmake --build build
ctest --test-dir build -N
ctest --test-dir build --output-on-failure
```

### 7.3. Перевірка виходу Hello World

Якщо бінарний файл створено, перевірити, що його запуск дає вивід, який містить `Hello` або `Hello, World!`.

### 7.4. Git ignore

```bash
git check-ignore -v build/hello build/Debug/hello.exe
```

Якщо відповідний файл для поточної платформи не створений, перевірка Git ignore може бути обмежена наявними локальними шляхами артефактів.

## 8. Типові помилки та їх обробка

### Типові помилки

- репозиторій не знайдено або відсутній `.git`;
- відсутній `README.md` або `docs/architecture.md`;
- відсутній `src/main.cpp`, `CMakeLists.txt` або `tests/BasicAdditionTest.cpp`;
- `hello` target не налаштований або `BasicAddition` не зареєстрований;
- `cmake` або `ctest` виконується з помилкою;
- виконуваний файл `hello` або `hello.exe` не існує;
- `ctest` видаляє або не реєструє тест;
- workflow не містить необхідні матрицю OS або тригери;
- `upload-artifact` не використовує `if-no-files-found: error`;
- `build/` або інші локальні артефакти не виключені з Git;
- GitHub Actions не запускалися реально, але програма позначена як PASS.

### Порядок обробки

1. Вказати точну перевірку, яка не пройшла.
2. Вказати точну причину: відсутній файл, помилка CMake, помилка тесту, конфлікт GitHub Actions або відсутній реальний запуск workflow.
3. Вказати місце проблеми: конкретний файл або команда.
4. Надати рекомендацію для виправлення.
5. Не маскувати помилку і не продовжувати orchestrator після критичної помилки.
6. Не позначати віддалений CI як PASS без реальних логів.

## 9. Приклад виконання

```text
Вхідні дані:
Repository path: C:/workspace/ai-agent-cpp-lab1
Current branch: develop
OS: Windows

Перевірки:
- git rev-parse --is-inside-work-tree -> PASS
- git branch --show-current -> develop
- git status --short --branch -> PASS
- README.md -> PASS
- docs/architecture.md -> PASS
- .gitignore -> PASS
- src/main.cpp -> PASS
- CMakeLists.txt -> PASS
- tests/BasicAdditionTest.cpp -> PASS
- cmake -S . -B build -> PASS
- cmake --build build --config Debug -> PASS
- ctest --test-dir build -C Debug -N -> PASS
- ctest --test-dir build -C Debug --output-on-failure -> PASS
- hello.exe exists -> PASS
- Hello World output -> PASS
- build/ ignored by Git -> PASS
- GitHub Actions workflow checked locally -> PASS
- Remote GitHub Actions status -> NOT VERIFIED (no real logs yet)

Підсумок:
Local check status: PASS
Remote CI status: NOT VERIFIED
Reason: Local build, tests and workflow configuration are valid; no real GitHub Actions jobs have been confirmed.
```

## 10. Правила безпеки та повторного запуску

Команда `check` має:

- не змінювати вихідний код, `README.md`, `docs/architecture.md`, `CMakeLists.txt`, тести, skills, prompts або CI-конфігурацію під час перевірки;
- не виконувати `commit`, `push`, `merge`, `reset --hard` або інші Git-операції без явної команди користувача;
- не перезаписувати `CMakeLists.txt`, `README.md`, workflow, тести, skills або prompt-файли;
- дозволяти створення або оновлення лише локальних результатів CMake/CTest у каталозі `build/`, який ігнорується Git;
- не змінювати Git-історію та не виконувати будь-які операції, що впливають на історію комітів;
- бути безпечною для повторного запуску;
- перевіряти поточний стан репозиторію перед звітом;
- зупинятися при будь-якій критичній помилці і повідомляти користувачу точну причину;
- не позначати реальний GitHub Actions результат як PASS без реальних логів від запуску jobs;
- зберігати повний і прозорий звіт перевірки.

## 11. Підсумок

Команда `check` є останнім діагностичним етапом у циклі лабораторної роботи. Вона підтверджує, що репозиторій, CMake, `hello` target, `BasicAddition` test, GitHub Actions workflow і локальні артефакти відповідають вимогам проєкту без внесення змін до основного коду або документації. Локальний `check` може завершитися `PASS`, навіть якщо віддалений GitHub Actions ще не запускалися і має статус `NOT VERIFIED`. Повна лабораторна робота вважається підтвердженою лише після успішного GitHub Actions на Windows, Linux і macOS.
