# Ритм — трекер привычек для iOS

Минималистичное приложение на SwiftUI: отмечайте привычки одним касанием и смотрите, как растёт серия.
Проект в формате [xtool](https://github.com/xtool-org/xtool) (SwiftPM + `xtool.yml`), поэтому собирается без Xcode, в том числе на Windows через WSL.

## Что умеет

- **Сегодня**: приветствие по времени суток, кольцо прогресса за день, карточки привычек.
- **Отметка одним касанием**, с анимацией и откликом вибрацией.
- **Полоса недели** на каждой карточке (Пн–Вс): можно задним числом отметить пропущенный день.
- **Серия 🔥**: сколько дней подряд привычка выполняется.
- **Экран привычки**: текущая серия, рекорд, процент за 30 дней и календарь последних 6 недель.
- **Создание и редактирование**: название, готовые идеи, 24 иконки-эмодзи и 8 мягких цветов.
- Долгое нажатие на карточку открывает меню «Изменить / Удалить».
- Светлая и тёмная тема, шрифт SF Rounded.
- Данные хранятся локально, в `Documents/habits.json`. При первом запуске добавляются 4 примера.

## Структура

```
Ritm/
├── Package.swift              # SwiftPM-пакет (одна library = приложение)
├── xtool.yml                  # bundle ID, Info.plist, иконка
├── Resources/
│   ├── Info.plist             # название «Ритм», русский язык
│   └── AppIcon.png            # иконка 1024×1024
├── Sources/Ritm/
│   ├── RitmApp.swift          # точка входа
│   ├── Model/Habit.swift      # модель привычки, серии, статистика
│   ├── Model/HabitStore.swift # хранилище + сохранение в JSON
│   ├── Support/Day.swift      # работа с датами, склонения
│   ├── Support/Palette.swift  # цвета, эмодзи, идеи
│   └── Views/                 # экраны и компоненты
└── .github/workflows/build-ipa.yml  # облачная сборка .ipa
```

Минимальная версия iOS 17. Макросы SwiftData и `#Preview` намеренно не используются: так проект гарантированно собирается Linux-тулчейном xtool.

---

## Способ 1. Готовый .ipa через GitHub (без Mac и без WSL)

Каждый push в `main` запускает workflow **Build IPA**: за 5–10 минут он собирает приложение на macOS-машине GitHub и выкладывает `Ritm.ipa` в **Releases**.

1. Скачайте последнюю сборку по прямой ссылке:
   **<https://github.com/fuflik52/testIOS/releases/latest/download/Ritm.ipa>**
   (если репозиторий другой, то `https://github.com/<владелец>/<репо>/releases/latest/download/Ritm.ipa`).
2. Установите `.ipa` на iPhone. Файл **не подписан**, а iOS не ставит неподписанные приложения из браузера, поэтому нужен инструмент, который подпишет его вашим Apple ID:
   - **Sideloadly** (Windows): подключите iPhone кабелем, перетащите `Ritm.ipa`, введите Apple ID и нажмите Start.
   - **AltStore / SideStore**: откройте `.ipa` в приложении на телефоне.
3. На iPhone включите **Настройки → Конфиденциальность и безопасность → Режим разработчика** и доверьте сертификату в **Настройки → Основные → VPN и управление устройством**.

> С бесплатным Apple ID приложение работает 7 дней, после этого его нужно переподписать (Sideloadly/AltStore делают это повторной установкой).

## Способ 2. Локально через xtool (Windows + WSL)

Подробная инструкция: <https://github.com/xtool-org/xtool/blob/main/Documentation/xtool.docc/Installation-Linux.md>

1. Поставьте WSL (PowerShell от имени администратора), затем перезагрузите ПК:
   ```powershell
   wsl --install -d Ubuntu
   ```
2. В Ubuntu поставьте **Swift 6.4** по инструкции с <https://swift.org/install/linux> и проверьте командой `swift --version`.
3. Поставьте usbmuxd:
   ```bash
   sudo apt-get install usbmuxd libimobiledevice-utils
   ```
4. Пробросьте iPhone в WSL через [usbipd-win](https://learn.microsoft.com/windows/wsl/connect-usb): `winget install usbipd`, затем `usbipd list`, `usbipd bind --busid <id>` и `usbipd attach --wsl --busid <id>`.
5. Скачайте **Xcode 27** (`.xip`) с <https://developer.apple.com/download/all/?q=Xcode> (нужен вход с Apple ID).
6. Поставьте xtool:
   ```bash
   curl -fL "https://github.com/xtool-org/xtool/releases/latest/download/xtool-$(uname -m).AppImage" -o xtool
   chmod +x xtool && sudo mv xtool /usr/local/bin/
   xtool setup   # вход в Apple ID + путь к Xcode .xip, например /mnt/c/Users/<вы>/Downloads/Xcode_27.xip
   ```
7. Соберите и установите на подключённый iPhone:
   ```bash
   cp -r "/mnt/c/Проекты/Ritm" ~/Ritm && cd ~/Ritm
   xtool dev
   ```
   Только собрать `.ipa`: `xtool dev build --ipa`, файл появится в `xtool/Ritm.ipa`.

## Bundle ID

Сейчас в `xtool.yml` указано `com.example.Ritm`. Если Apple скажет, что такой ID занят, поменяйте его на любой уникальный, например `com.<ваше-имя>.Ritm`.
