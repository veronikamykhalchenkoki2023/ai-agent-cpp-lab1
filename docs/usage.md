# Інструкція з використання AI-агента build-engineer

## 1. Призначення

AI-агент `build-engineer` призначений для автоматизації створення, складання, тестування та налаштування CI/CD кросплатформного C++-проєкту Hello World.

У проєкті використовуються CMake, GoogleTest/CTest, GitHub Copilot та GitHub Actions.

## 2. Необхідні інструменти

Для локальної роботи необхідні:

- Git;
- Visual Studio Code із GitHub Copilot;
- CMake версії 3.16 або новішої;
- компілятор C++ із підтримкою C++17;
- підключення до інтернету для завантаження GoogleTest під час першої конфігурації.

У Windows можна використовувати Visual Studio 2022 та x64 Native Tools Command Prompt.

## 3. Структура AI-агента

Маніфест агента розташований у файлі `.github/agents/build-engineer.agent.md`.

Навички агента:

- `project-scaffold` — створення структури проєкту;
- `build-and-test` — налаштування CMake та тестування;
- `github-actions` — налаштування CI/CD.

Команди розміщено в `.github/prompts/`:

- `git-init.prompt.md`;
- `create-project.prompt.md`;
- `create-build.prompt.md`;
- `create-actions.prompt.md`;
- `check.prompt.md`;
- `init.prompt.md`.

## 4. Використання AI-агента

1. Відкрити репозиторій у Visual Studio Code.
2. Відкрити GitHub Copilot Chat.
3. Вибрати агента `build-engineer`.
4. Передати агенту завдання відповідно до файлу `.github/prompts/init.prompt.md`.
5. Перевіряти результати кожного етапу створення проєкту.

Оркестратор `init` виконує команди в послідовності: `git-init` → `create-project` → `create-build` → `create-actions` → `check`.

Для повторної перевірки можна використати інструкції з `.github/prompts/check.prompt.md`.

## 5. Локальне складання проєкту

У Windows рекомендується відкрити x64 Native Tools Command Prompt for Visual Studio 2022.

Перейти до кореневого каталогу проєкту та виконати:

`cmake -S . -B build`

`cmake --build build --config Debug`

Для запуску програми у Windows:

`build\Debug\hello.exe`

Очікуваний результат:

`Hello, World!`

## 6. Запуск модульних тестів

Для запуску тестування використовується команда:

`ctest --test-dir build -C Debug --output-on-failure`

Очікуваний результат:

`100% tests passed, 0 tests failed out of 1`

Модульний тест `BasicAddition` перевіряє правильність виконання операції додавання.

## 7. Перевірка за допомогою CI-сценаріїв

Для Windows використовується команда:

`ci.bat`

Для Linux та macOS:

`bash ./ci.sh`

Сценарії виконують складання, тестування та перевірку наявності виконуваного файлу.

## 8. GitHub Actions

Файл `.github/workflows/ci.yml` налаштовує автоматичні перевірки для Ubuntu, Windows та macOS.

Workflow запускається під час операцій `push` та `pull_request` для гілок `develop` і `main`.

Після успішної перевірки створюються артефакти `Linux-hello`, `Windows-hello` та `macOS-hello`.

## 9. Правила безпеки

AI-агент повинен працювати лише в межах поточного репозиторію, не перезаписувати коректні файли без необхідності, не розкривати секрети та не виконувати `commit`, `push` або `merge` без дозволу користувача.

Після генерації файлів потрібно переглядати зміни, перевіряти результати складання й тестування та аналізувати повідомлення про помилки.