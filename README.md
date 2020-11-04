[![YaGames Logo](cover.png)](https://github.com/indiesoftby/defold-yagames)

# YaGames - Yandex.Games for Defold (WORK IN PROGRESS)

*This is an open-source project. It is not affiliated with Yandex LLC.*

YaGames is the Yandex.Games extension for the [Defold](https://www.defold.com/) game engine. [Yandex.Games](https://yandex.com/games/) is a collection of browser games for smartphones and computers. The games are available in Yandex Browser and the Yandex app.

## Installation

You can use it in your own project by adding this project as a [Defold library dependency](http://www.defold.com/manuals/libraries/). Open your `game.project` file and in the dependencies field under project add:

https://github.com/indiesoftby/defold-yagames/archive/master.zip

Or point to the ZIP file of a [specific release](https://github.com/indiesoftby/defold-yagames/releases).

**English edition of the documentation is not ready yet!**

# *На русском*

*Это проект с открытым исходным кодом. Он никак не аффилирован с компанией Яндекс.*

YaGames - это расширение для движка [Defold](https://www.defold.com/). [Яндекс.Игры](https://yandex.com/games/) - коллекция браузерных игр для смартфонов и компьютеров. Игры доступны через Яндекс.Браузер и приложение Яндекс на смартфонах.

## Быстрый старт

* [Официальная документация](https://yandex.ru/dev/games/doc/dg/concepts/about.html).
* [Telegram-чат Яндекс.Игр](https://t.me/yagamedev), где присутствуют официальные представители и модераторы.
* [Telegram-чат Defold Engine](https://t.me/DefoldEngine), где можно задать вопросы об этом расширении.

### Чек-лист для релиза Defold-игры на Яндекс.Играх

1. [Зарегистрируйтесь как разработчик в Яндекс.Играх](https://yandex.ru/dev/games/).
2. Подготовьте ассеты для каталога:
    1. Иконка 512x512 пикселей.
    2. Обложка 800x470 пикселей.
    3. Скриншоты по 2 шт. отдельно для мобильной и десктоп версии игр.
3. Переведите название игры на русский язык, подготовьте описание игры на русском.
4. Добавьте [ссылку на это расширение](https://github.com/indiesoftby/defold-yagames/archive/master.zip) в Dependencies вашего проекта. **С этого момента вы уже можете публиковать игру на Яндекс.Играх, она будет соответствовать требованиям.**
5. Подключите монетизацию в игре:
    1. С помощью полноэкранной рекламы в процессе загрузки игры, между уровнями игры, после поражения игрока. *Важно:* Во время показа такой рекламы звуки в игре должны выключаться.
    2. С помощью Rewarded рекламы. *Важно:* Во время показа такой рекламы звуки в игре должны выключаться.
    3. ~~С помощью контекстной рекламы (RTB-блоки).~~ Простой способ интеграции еще не реализован.
    4. С помощью внутриигровых покупок.
6. Включите Service Worker, скопировав файл `manifests/web/sw.js` в корневую директорию релизного билда игры:
    1. *Важно:* Укажите относительный путь к файлу `sw.js` в `game.project` настройках.
    2. *Важно:* В файле `sw.js` отредактируйте список файлов вашей игры. Сам `sw.js` включать в него не нужно.
    3. *Важно:* При каждом обновлении файлов игры на Яндексе вам нужно инкрементировать версию в файле `sw.js`.
7. Опубликуйте игру [в каталоге Яндекс.Игр](https://yandex.ru/dev/games/).

### Лучшие практики

1. Яндекс.Игры доступны только для HTML5, поэтому на остальных платформах это расширение имитирует работу SDK и предупреждает об этом на старте. Поэтому можно быстро внедрить и проверить работу SDK в основной среде разработки (Windows, macOS, Linux), затем загрузить полностью готовый к работе HTML5 билд вашей игры в каталог Яндекс.Игр.
2. Код из `manifests/web/engine_template.html` всегда внедряется в ваш HTML5 билд, соответственно SDK Яндекс.Игр подключается всегда. Это поведение не отключить, не удалив расширение.
3. Для каждой платформы и соответственно отдельно для Яндекс.Игр ведите отдельную ветку в вашем Git и не смешивайте в один файл код для каждой платформы, чтобы избежать больших ненужных ветвлений.

## Примеры кода

Расширение содержит демо-проект (директория `example`), с которым можно поиграться или использовать как внутренний отладочный экран в вашей игре.

![YaGames Demo](example/screenshot.png)

### 1. Инициализация

```lua
local function init_handler(self, err)
    if err then
        print("Something bad happened :(", err)
    end
end

function init(self)
    yagames.init(init_handler)
end
```

### 2. Вызов полноэкранной рекламы

* `open` - вызывается при успешном открытии рекламы.
* `close` - вызывается при закрытии рекламы, после ошибки, а также, если реклама не открылась по причине слишком частого вызова. Используется с аргументом `was_shown` (тип boolean), по значению которого можно узнать была ли показана реклама.
* `offline` - вызывается при потере сетевого соединения (переходе в офлайн-режим).
* `error` - вызывается при возникновении ошибки. Объект ошибки передается в callback-функцию.

```lua
local function adv_open(self)
    -- You should switch off all sounds!
end

local function adv_close(self, was_shown)
    -- You can switch sounds back!
end

local function adv_offline(self)
    -- Internet is offline
end

local function adv_error(self, err)
    -- Something wrong happened :(
end

function on_message(self, message_id, message)
    if message_id == hash("show_fullscreen_adv") then
        yagames.adv_show_fullscreen_adv({
            open = adv_open,
            close = adv_close,
            offline = adv_offline,
            error = adv_error
        })
    end
end
```

### 3. Вызов Rewarded видео

* `open` - вызывается при отображении видеорекламы на экране.
* `rewarded` - вызывается, когда засчитывается просмотр видеорекламы. Укажите в данной функции, какую награду пользователь получит после просмотра.
* `close` - вызывается при закрытии видеорекламы.
* `error` - вызывается при возникновении ошибки. Объект ошибки передается в callback-функцию.

```lua
local function rewarded_open(self)
    -- You should switch off all sounds!
end

local function rewarded_rewarded(self)
    -- Add coins!
end

local function rewarded_close(self)
    -- You can switch sounds back!
end

local function rewarded_error(self, err)
    -- Something wrong happened :(
end

function on_message(self, message_id, message)
    if message_id == hash("show_rewarded_video") then
        yagames.adv_show_rewarded_video({
            open = rewarded_open,
            rewarded = rewarded_rewarded,
            close = rewarded_close,
            error = rewarded_error
        })
    end
end
```

## Настройки расширения в `game.project`

```ini
[yagames]
sdk_init_options = { orientation: { value: "landscape", lock: true } }
service_worker_url = sw.js
```

* `sdk_init_options` - JavaScript код. Это дополнительные опции иницилизации Yandex Games SDK, передаются [в метод `YaGames.init`](https://yandex.ru/dev/games/doc/dg/sdk/sdk-about.html).
* `service_worker_url` - Ссылка на файл Service Worker. В большинстве случаев это `sw.js`. Указание этой ссылки включает поддержку Service Worker. 

## Lua API

В Yandex.Games SDK используются ES6 Promise (промис) для отложенных и асинхронных вычислений. В Lua API они заменены на callback-функции с аргументами `(self, err, result)`, где `self` - это контекст скрипта, `err` - это ошибка (равная `nil`, если ошибки нет), `result` - результат.

### Таблица соответствия с официальным SDK

| Yandex.Games SDK | Lua API |
| ---------------- | ------- |
| `YaGames.init(options)` | `yagames.init(callback)` - Опции указываются в настройках проекта в `yagames.sdk_init_options`. |
| `ysdk.deviceInfo.isDesktop()` | `yagames.device_info_is_desktop()` |
| `ysdk.deviceInfo.isMobile()` | `yagames.device_info_is_mobile()` |
| `ysdk.deviceInfo.isTablet()` | `yagames.device_info_is_tablet()` |
| `ysdk.adv.showFullscreenAdv({callbacks:{}})` | `yagames.adv_show_fullscreen_adv(callbacks)` [<kbd>Пример</kbd>](#2-вызов-полноэкранной-рекламы) |
| `ysdk.adv.showRewardedVideo({callbacks:{}})` | `yagames.adv_show_rewarded_video(callbacks)` [<kbd>Пример</kbd>](#3-вызов-rewarded-видео) |
| `ysdk.auth.openAuthDialog()` | `yagames.auth_open_auth_dialog(callback)` |
| `ysdk.getPlayer(options)` | `yagames.player_init(options, callback)` |
| `player.setData(data, flush)` | `yagames.player_set_data(data, flush, callback)` |
| `player.getData(keys)` | `yagames.player_get_data(keys, callback)` |
| `player.setStats(stats)` | `yagames.player_set_stats(stats, callback)` |
| `player.incrementStats(increments)` | `yagames.player_increment_stats(increments, callback)` |
| `player.getStats(keys)` | `yagames.player_get_stats(keys, callback)` |
| `player.getID()` <kbd>Deprecated</kbd> | `yagames.player_get_id()` <kbd>Deprecated</kbd> |
| `player.getUniqueID()` | `yagames.player_get_unique_id()` |
| `player.getIDsPerGame()` | `yagames.player_get_ids_per_game(callback)` |
| `player.getName()` | `yagames.player_get_name()` |
| `player.getPhoto(size)` | `yagames.player_get_photo(size)` |
| `ysdk.getPayments(options)` | `yagames.payments_init(options, callback)` |
| `payments.purchase(options)` | `yagames.payments_purchase(options, callback)` |
| `payments.getPurchases()` | `yagames.payments_get_purchases(callback)` - результат имеет формат `{ purchases = { ... }, signature = "..." }` |
| `payments.getCatalog()` | `yagames.payments_get_catalog(callback)` |
| `payments.consumePurchase(purchaseToken)` | `yagames.payments_consume_purchase(purchase_token, callback)` |

## Дополнительные функции

Защита игры от размещения на сторонних сайтах с помощью сайт-лока, то есть проверки доменного имени, где размещена игра. По умолчанию добавлены домены `yandex.net` (CDN Яндекс.Игр) и `localhost`:

```lua
local sitelock = require("yagames.sitelock")

-- Also you can add your domains:
-- sitelock.add_domain("yourdomainname.com")

function init(self)
    if html5 and sitelock.is_release_build() then
        if not sitelock.verify_domain() then
            -- Show warning and pause the game
        end
    end
end
```

## Лицензия

Лицензия проекта - **MIT**. Разработан и поддерживается [@aglitchman](https://github.com/aglitchman). Основан на исходном коде [JsToDef](https://github.com/AGulev/jstodef).
