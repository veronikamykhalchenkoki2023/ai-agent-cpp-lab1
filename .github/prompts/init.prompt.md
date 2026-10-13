---
description: "Ініціалізація повного циклу C++-проєкту через п'ять команд: git-init, create-project, create-build, create-actions, check."
agent: build-engineer
---

# init

## 1. Призначення

Команда `init` є головним orchestrator циклу лабораторної роботи №1. Вона послідовно запускає п'ять команд агента `build-engineer` в строго визначеному порядку:

1. `git-init`
2. `create-project`
3. `create-build`
4. `create-actions`
5. `check`

Мета `init` — забезпечити повну ініціалізацію C++-проєкту з Hello World, локально налаштувати CMake, GoogleTest / CTest, GitHub Actions і провести перевірку готовності проєкту без приховування помилок.

Оркестратор повинен діяти як керівний процес: перед кожним етапом він читає відповідний prompt-файл і виконує його інструкції, перевіряє результат, і зупиняється, якщо попередній крок завершився з помилкою.

## 2. Передумови

Перш ніж виконувати `init`, агент повинен підтвердити:

- відкрито кореневу папку дійсного Git-репозиторію;
- репозиторій належить до лабораторної роботи №1 і відповідає архітектурі, описаній у `README.md` і `docs/architecture.md`;
- файли `.github/prompts/git-init.prompt.md`, `create-project.prompt.md`, `create-build.prompt.md`, `create-actions.prompt.md` і `check.prompt.md` доступні для читання;
- відповідні skill-файли також доступні: `project-scaffold`, `build-and-test` і `github-actions`;
- користувач не просив виконувати commit, push, merge, force-push або зміну гілки;
- процес працює тільки в межах поточного репозиторію.

Якщо якийсь з цих пунктів не підтверджений, `init` має зупинитися і повідомити чітку причину, а не продовжувати виконання в невизначеному стані.

## 3. Вхідні дані

`init` приймає загальні вхідні дані належної лабораторної задачі:

- назва репозиторію;
- поточна гілка Git;
- стан репозиторію;
- тип проєкту: C++ / CMake / GoogleTest / CTest;
- платформи: Windows, Linux, macOS;
- виконуваний target: `hello`;
- базовий тест: `BasicAddition`;
- необхідні локальні каталоги: `src/`, `tests/`, `build/` (як локальний збірний каталог, що не виноситься до Git);
- бажана CI-інтеграція через GitHub Actions.

Типовий вхід:

```text
Repository: ai-agent-cpp-lab1
Branch: develop
Project: C++ Hello World
Build system: CMake
Testing: GoogleTest / CTest
Platforms: Windows, Linux, macOS
CI target: GitHub Actions
```

## 4. Порядок виконання п'яти команд

Команда `init` має виконувати п'ять етапів послідовно. Для кожного етапу агент повинен:

1. прочитати відповідний prompt-файл у `.github/prompts/`;
2. виконати його інструкції та перевірки безпосередньо в поточному репозиторії;
3. зафіксувати результат: `PASS`, `FAIL` або `SKIPPED`;
4. якщо результат `FAIL`, зупинити всі наступні кроки;
5. якщо результат `SKIPPED`, перевірити, чи це дійсно безпечний пропуск через вже виконаний правильний стан, а не помилка або неповна конфігурація.

### 4.1. Етап 1: git-init

Перед виконанням етапа `git-init` агент читає `.github/prompts/git-init.prompt.md` і виконує її правила:

- перевірити Git-репозиторій;
- перевірити поточну гілку і статус repo;
- перевірити `.gitignore`;
- безпечно доповнити правила для `build/`, `out/`, локальних артефактів, кешів, логів і секретів;
- не виконувати `git commit`, `git push`, `git merge`, `git reset --hard`, `git push --force` або будь-які зміни історії.

Результат етапу: `PASS` або `FAIL`.

### 4.2. Етап 2: create-project

Перед виконанням етапа `create-project` агент читає `.github/prompts/create-project.prompt.md` і виконує:

- перевірку структури репозиторію;
- перевірку, що `git-init` був успішний або його передумови підтверджені;
- створення каркасу `src/`, `tests/` і `docs/` лише при необхідності;
- збереження `README.md` і `docs/architecture.md` без перезапису;
- створення або перевірку `src/main.cpp` з базовим Hello World;
- безпечну обробку повторного запуску без дублювання та без змін коректних файлів.

Результат: `PASS` або `FAIL`.

### 4.3. Етап 3: create-build

Перед виконанням етапа `create-build` агент читає `.github/prompts/create-build.prompt.md` і виконує:

- перевірку наявності `src/main.cpp`;
- створення або коректне оновлення `CMakeLists.txt` без небезпечного перезапису;
- налаштування `hello` target;
- виділення функції `add(int a, int b)` в окремий модуль для тестування;
- створення `tests/BasicAdditionTest.cpp` з GoogleTest / CTest;
- локальну збірку через CMake і запуск `ctest`;
- перевірку, що `build/` не потрапляє до Git.

Результат: `PASS` або `FAIL`.

### 4.4. Етап 4: create-actions

Перед виконанням етапа `create-actions` агент читає `.github/prompts/create-actions.prompt.md` і виконує:

- перевірку, що CMake і CTest вже локально працюють;
- створення `.github/workflows/ci.yml` при необхідності;
- створення `ci.sh` і `ci.bat`;
- налаштування matrix для `ubuntu-latest`, `windows-latest`, `macos-latest`;
- використання `actions/checkout` і `actions/upload-artifact`;
- локальну перевірку workflow і скриптів без запуску реального GitHub Actions.

Результат: `PASS` або `FAIL`.

### 4.5. Етап 5: check

Перед виконанням етапа `check` агент читає `.github/prompts/check.prompt.md` і виконує:

- перевірку Git-репозиторію;
- перевірку структури проєкту;
- перевірку CMake, збірки, CTest і `BasicAddition`;
- перевірку `hello` / `hello.exe`;
- перевірку локальної CI-конфігурації;
- окреме фіксування `Local check status` і `Remote CI status`.

Локальний `check` може завершитись як `PASS` або `FAIL`.

Remote GitHub Actions не повинен ставитися як `PASS` без реальних логів. До реального підтвердження статус має бути `NOT VERIFIED`.

## 5. Логіка зупинки при помилці

Оркестратор `init` зупиняється при першій помилці, а не продовжує наступні етапи.

Правила:

- якщо етап `git-init` завершився з помилкою, `create-project` не запускається;
- якщо `create-project` завершився з помилкою, `create-build` не запускається;
- якщо `create-build` завершився з помилкою, `create-actions` не запускається;
- якщо `create-actions` завершився з помилкою, `check` не запускається;
- якщо `check` завершується з `FAIL`, процес завершується як невдалий.

При помилці агент повинен повідомити:

- назву етапу;
- причину збою;
- конкретний файл або команду, що спричинила помилку;
- рекомендацію щодо виправлення.

Немає права маскувати помилки CMake, GoogleTest, CTest, Git або GitHub Actions.

## 6. Безпечний повторний запуск

`init` повинен бути безпечним для повторного запуску.

Правила першого запуску:

- дозволено створювати відсутні файли проєкту, які відповідають поточному етапу: `src/main.cpp`, `CMakeLists.txt`, модуль `add()`, тести, `.gitignore`, `ci.yml`, `ci.sh` і `ci.bat`;
- локальні артефакти CMake / CTest дозволено створювати у каталозі `build/`, який ігнорується Git;
- якщо файли ще не існують, створення їх у відповідний момент є частиною нормального виконання orchestrator.

Правила повторного запуску:

- перевіряти вже створені файли перед їх створенням;
- не дублювати існуючі коректні файли;
- не перезаписувати `README.md`, `docs/architecture.md` без потреби;
- не перезаписувати коректний `CMakeLists.txt`, `ci.yml`, `ci.sh`, `ci.bat` без перевірки;
- якщо результат уже правильний, позначати крок як `SKIPPED` лише після фактичної перевірки, що результат уже існує і повністю відповідає вимогам;
- не видаляти існуючі файли без явного підтвердження користувача;
- не виконувати автоматично `commit`, `push`, `merge`, `force-push`, зміну гілки або перемикання гілки;
- не видаляти чи перезаписувати дані користувача без підтвердження.

Локальні результати CMake / CTest можуть створюватися або оновлюватися лише в каталозі `build/`, який ігнорується Git.

## 7. Критерії успіху

Етап є успішним, якщо його статус `PASS`.

Етап зі статусом `SKIPPED` допустимий лише тоді, коли агент реально перевірив, що відповідний результат уже існує і повністю відповідає вимогам. Пропуск перевірки без фактичного підтвердження заборонено.

Локальний `init` вважається успішним, якщо всі п'ять локальних етапів мають статус `PASS` або обґрунтований `SKIPPED`, а фінальна локальна перевірка `check` фактично виконана і має статус `PASS`.

Будь-який `FAIL` зупиняє orchestrator і не дозволяє переходити до наступного етапу.

Локальний `init` означає, що:

- Git-репозиторій готовий;
- базовий проєкт C++ Hello World створений;
- CMake налаштовано;
- CTest і GoogleTest діють;
- `BasicAddition` проходить локально;
- GitHub Actions workflow і CI-скрипти створені;
- локальні перевірки структури, збірки і workflow завершені успішно.

Важливо:

- відсутність реального запуску GitHub Actions не блокує локальний `init`;
- `Remote CI status` залишається `NOT VERIFIED` до фактичного підтвердження в логах GitHub Actions;
- повна лабораторна робота вважається підтвердженою лише після успішного GitHub Actions на Windows, Linux і macOS.

## 8. Формат підсумкового звіту

Наприкінці `init` агент формує підсумковий звіт у такій структурі:

```text
=== INIT REPORT ===
1. git-init: PASS / FAIL / SKIPPED
2. create-project: PASS / FAIL / SKIPPED
3. create-build: PASS / FAIL / SKIPPED
4. create-actions: PASS / FAIL / SKIPPED
5. check: PASS / FAIL / SKIPPED

Local build status: PASS / FAIL
Local CTest status: PASS / FAIL
BasicAddition status: PASS / FAIL
Local workflow status: PASS / FAIL
Local check status: PASS / FAIL
Remote CI status: PASS / FAIL / NOT VERIFIED

Summary:
- Stage-by-stage status
- Reasons for any failures
- Files or commands that caused the issue
- Recommended fix
=== END REPORT ===
```

У підсумку обов’язково розмежовувати:

- локальний результат `init`;
- фактичний віддалений GitHub Actions status.

## 9. Приклад першого запуску

```text
Вхідні дані:
Repository: ai-agent-cpp-lab1
Branch: develop
Project: C++ Hello World

Порядок:
1. git-init -> PASS
2. create-project -> PASS
3. create-build -> PASS
4. create-actions -> PASS
5. check -> PASS

Local build status: PASS
Local CTest status: PASS
BasicAddition status: PASS
Local workflow status: PASS
Local check status: PASS
Remote CI status: NOT VERIFIED

Підсумок:
Локальний init успішний. Віддалений GitHub Actions ще не запускалися, тому Remote CI status = NOT VERIFIED.
```

## 10. Приклад повторного запуску

```text
Вхідні дані:
Repository: ai-agent-cpp-lab1
Branch: develop
Project: C++ Hello World

Порядок:
1. git-init -> SKIPPED (перевірено, що .gitignore та Git-стан вже коректні)
2. create-project -> SKIPPED (перевірено, що src/main.cpp і структура вже відповідають вимогам)
3. create-build -> SKIPPED (перевірено, що CMakeLists.txt, add() і BasicAddition вже коректні)
4. create-actions -> SKIPPED (перевірено, що ci.yml, ci.sh і ci.bat вже відповідають вимогам)
5. check -> PASS

Local build status: PASS
Local CTest status: PASS
BasicAddition status: PASS
Local workflow status: PASS
Local check status: PASS
Remote CI status: NOT VERIFIED

Підсумок:
Повторний запуск безпечний: усі коректні файли перевірено і не перезаписано, а еквівалентні результати були підтверджені до SKIPPED. Локальний init успішний; віддалений CI ще не підтверджений.
```

## 11. Правила безпеки

Команда `init` має:

- працювати лише в межах поточного репозиторію;
- зберігати `README.md` і `docs/architecture.md` без небезпечного перезапису;
- дозволяти створення відсутніх файлів проєкту під час першого запуску: `src/main.cpp`, `CMakeLists.txt`, модуль `add()`, тести, `.gitignore`, `ci.yml`, `ci.sh` і `ci.bat` у відповідних етапах;
- під час повторного запуску зберігати існуючі коректні файли без перезапису;
- дозволяти створення локальних артефактів CMake / CTest у каталозі `build/`, який ігнорується Git;
- не змінювати вихідний код, CMakeLists.txt, тести, skills, prompts або workflow без необхідності;
- не створювати дублікати коректних файлів або workflow;
- не видаляти чи перезаписувати дані користувача без підтвердження;
- не виконувати `commit`, `push`, `merge`, `git checkout` з ризиком втрати даних, `git reset --hard` або `git push --force`;
- не виконувати автоматично перемикання гілки або інші Git-операції, що змінюють історію або поточну гілку без явної команди користувача;
- не маскувати помилки Git, CMake, CTest, GoogleTest, GitHub Actions або результати локальної перевірки;
- працювати в режимі "stop on first error";
- у разі помилки повідомляти точну причину і зупиняти процес без продовження.

## 12. Підсумок

Команда `init` є головним orchestrator циклу лабораторної роботи. Вона читає та виконує п'ять існуючих prompt-файлів в строгій послідовності, контролює успішність кожного етапу, зупиняється при помилці, зберігає безпеку повторного запуску і формує підсумковий звіт із чітким розмежуванням між локальним результатом і реальним віддаленим GitHub Actions status.
