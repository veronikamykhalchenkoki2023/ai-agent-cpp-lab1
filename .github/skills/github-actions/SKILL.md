---
name: github-actions
description: "Створення та перевірка GitHub Actions для кросплатформного C++-проєкту з CMake, GoogleTest / CTest, Linux, Windows і macOS."
---

# github-actions

## 1. Призначення

Цей skill призначений для створення та перевірки конфігурації GitHub Actions для кросплатформного C++-проєкту. Він гарантує, що після успішного локального складання та проходження тестів через `build-and-test` проект автоматично перевіряється в CI на Windows, Linux і macOS.

Skill відповідає за:

- генерацію workflow для GitHub Actions;
- підтримку кросплатформного запуску для `ubuntu-latest`, `windows-latest` і `macos-latest`;
- налаштування запуску при `push` і `pull_request` до `develop` або `main`;
- організацію виконання власних скриптів `ci.sh` і `ci.bat`;
- збереження артефактів складання через `actions/upload-artifact`;
- перевірку успішного проходження тесту `BasicAddition` у CI-середовищі.

## 2. Коли застосовувати skill

Цей skill застосовується лише після успішного локального складання та проходження тестів через `build-and-test`. Якщо базовий C++-проєкт ще не готовий або CMake / CTest не працюють локально, наступний етап CI/CD не повинен запускатися.

Skill не застосовується:

- якщо проект не має кореневого `CMakeLists.txt`;
- якщо `BasicAddition` не проходить локально;
- якщо репозиторій не має потрібної структури для GitHub Actions.

## 3. Вхідні дані

Перш ніж виконувати skill, потрібно мати або підтвердити такі вхідні параметри:

- назва репозиторію;
- структура C++-проєкту;
- кореневий `CMakeLists.txt`;
- конфігурація GoogleTest / CTest;
- файли `ci.sh` і `ci.bat`;
- перелік платформ: `ubuntu-latest`, `windows-latest`, `macos-latest`;
- коректно зібраний проект, готовий до CI-перевірки.

Приклад вхідних даних:

```text
Repository: ai-agent-cpp-lab1
Project structure: src/, tests/, build/
CMake: root CMakeLists.txt configured
Test framework: GoogleTest / CTest
Platform matrix: ubuntu-latest, windows-latest, macos-latest
Scripts: ci.sh, ci.bat
```

## 4. Очікувані результати

Після успішного виконання skill у репозиторії мають бути:

- файл `.github/workflows/ci.yml`;
- скрипт `ci.sh` для Linux і macOS;
- скрипт `ci.bat` для Windows;
- виконувані файли `hello` або `hello.exe` для кожної платформи;
- локальні артефакти доступні після запуску CI;
- успішне виконання тесту `BasicAddition` у GitHub Actions.

Очікувана структура файлів:

```text
.github/
  workflows/
    ci.yml
  skills/
    github-actions/
      SKILL.md
ci.sh
ci.bat
CMakeLists.txt
src/
  main.cpp
tests/
  BasicAdditionTest.cpp
```

## 5. Вимоги до workflow

Workflow має відповідати таким правилам:

1. Запускатися при `push` і `pull_request` до гілок `develop` або `main`.
2. Мати одну job із matrix для платформ:
   - `ubuntu-latest`
   - `windows-latest`
   - `macos-latest`
3. Виконувати `checkout` репозиторію.
4. Викликати `ci.sh` для Linux/macOS.
5. Викликати `ci.bat` для Windows.
6. Скрипти самостійно виконують:
   - конфігурацію CMake;
   - збірку проєкту;
   - запуск `ctest`;
   - перевірку статусу `BasicAddition`.
7. `ci.yml` не повинен дублювати команди складання або запуску тестів безпосередньо в workflow, якщо це вже реалізовано в скриптах.
8. Використовувати `actions/upload-artifact` для збереження бінарних файлів `hello` або `hello.exe`.
9. Повідомлення про статус і помилки мають бути зрозумілими для користувача.

## 6. Перевірки

Перед завершенням skill потрібно виконати два типи перевірок, які мають бути чітко розмежовані.

### 6.1. Локальна перевірка під час виконання skill

Локальна перевірка виконується без реального запуску GitHub Actions і має підтверджувати, що:

1. створено `.github/workflows/ci.yml`;
2. створено `ci.sh` і `ci.bat`;
3. YAML workflow має коректний синтаксис;
4. налаштовано одну job із matrix для `ubuntu-latest`, `windows-latest` і `macos-latest`;
5. скрипти викликають CMake, виконують складання та запуск `ctest`;
6. передбачено `upload-artifact` для виконуваних файлів `hello` або `hello.exe`;
7. у вихідному коді та workflow відсутні секрети, токени або конфіденційні дані.

Локальний етап `create-actions` не слід вважати невдалим лише через те, що GitHub Actions ще не запускався у віддаленому середовищі. Проте, якщо локальна перевірка workflow або скриптів завершується з помилкою, skill має зупинити виконання orchestrator.

### 6.2. Фактична перевірка GitHub Actions

Фактична перевірка виконується після `push` або `pull_request` і має підтверджувати:

1. успішні jobs для Windows, Linux і macOS;
2. наявність завантажених artifacts у GitHub Actions;
3. коректний результат виконання `BasicAddition` на кожній платформі;
4. збір і збереження результатів для звіту.

Фактичний результат GitHub Actions не можна позначати як `PASS` без реального підтвердження в логах виконання jobs. У разі відсутності реального запуску або невдалого виконання віддаленого CI, відповідний статус має залишатися `not verified` або `failed`, а не `passed`.

### 6.3. Правило завершення для перевірок

- локальна перевірка workflow і скриптів є обов’язковою перед завершенням skill;
- фактичний запуск GitHub Actions є окремим підтверджуючим кроком, який не замінює локальної валідації;
- лише реальний успішний CI може бути підставою для позначення результату як повний success.

## 7. Правила безпеки та повторного запуску

Skill повинен діяти безпечно:

- не перезаписувати коректні CI-файли без попередньої перевірки;
- не створювати дублікати workflow;
- не змінювати захист гілок або правила безпеки репозиторію;
- не виконувати автоматичний `commit`, `push`, merge або publish без явної команди користувача;
- перевіряти, чи вже існує потрібний workflow, і якщо він коректний, не дублювати його;
- зберігати мінімальну інструкцію для CI без зайвого ризику.

## 8. Приклад вхідних даних, очікуваної структури файлів, результатів CI та типового повідомлення про успіх

### Вхідні дані

```text
Repository: ai-agent-cpp-lab1
Branch trigger: develop, main
Platforms: ubuntu-latest, windows-latest, macos-latest
CMake build: enabled
Tests: BasicAddition via CTest
Artifacts: hello, hello.exe
```

### Очікувана структура файлів

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
```

### Очікуваний результат CI

```text
ubuntu-latest: PASS
windows-latest: PASS
macos-latest: PASS
Artifact upload: OK
BasicAddition: PASS on all platforms
```

### Типове повідомлення про успіх

```text
CI workflow completed successfully for all supported platforms.
BasicAddition passed on ubuntu-latest, windows-latest and macos-latest.
Artifacts were uploaded successfully.
```

## 9. Типовий сценарій помилки та порядок його обробки

### Типові помилки

- збій складання на Windows через неправильне виконання `ci.bat`;
- відсутній файл `ci.sh` або `ci.bat`;
- невдалий запуск `ctest` через помилку тесту `BasicAddition`;
- workflow не містить потрібну матрицю ОС;
- `upload-artifact` не знаходить виконуваний файл `hello` або `hello.exe`;
- YAML workflow має синтаксичну помилку.

### Порядок обробки

1. Показати точний текст помилки з GitHub Actions, shell-скрипта або CTest.
2. Зупинити подальше виконання orchestrator і повідомити, що CI не пройшов.
3. Перевірити, чи існують `ci.sh` і `ci.bat`, і чи workflow коректно викликає їх.
4. Перевірити кореневий `CMakeLists.txt`, наявність бінарного файлу і правильність запуску `ctest`.
5. Перевірити, чи `BasicAddition` проходить на всіх платформах.
6. Не дозволяти переходу до наступного кроку, якщо хоча б один platform або один сценарій завершився з помилкою.
7. Повідомити користувачу чітко, що відбувся збій і які саме файли або платформи потребують виправлення.

## 10. Правило завершення

Skill `github-actions` вважається локально завершеним, якщо створено `.github/workflows/ci.yml`, `ci.sh` і `ci.bat`, а також успішно виконано доступні локальні перевірки структури, YAML, скриптів і налаштувань. Якщо локальна перевірка завершується з помилкою, orchestrator `init` повинен зупинитися.

Фактична перевірка GitHub Actions на Windows, Linux і macOS виконується після `push` або `pull_request`. До реального успішного запуску GitHub Actions віддалений CI має статус `not verified`. Отже, віддалений CI не можна позначати як `PASS` без фактичних результатів виконання jobs і наявності завантажених artifacts.

Повністю виконаною лабораторна робота вважається лише після підтвердження успішних GitHub Actions на трьох операційних системах і наявності artifacts. До цього моменту локально створені workflow і скрипти можуть бути коректними, але фактичний GitHub Actions status залишається `not verified`.

## 11. Висновок

Skill `github-actions` завершує цикл автоматизації C++-проєкту: після успішної локальної збірки та тестування він готує кросплатформний GitHub Actions workflow, який перевіряє проєкт на Ubuntu, Windows і macOS, зберігає артефакти та забезпечує контроль якості без приховування помилок.
