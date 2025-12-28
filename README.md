[![YaGames Logo](cover.png)](https://github.com/indiesoftby/defold-yagames)

# YaGames - Yandex.Games for Defold

*This is an open-source project, and it's not affiliated with Yandex LLC.*

YaGames is the Yandex.Games SDK native extension for the [Defold](https://www.defold.com/) game engine. [Yandex.Games](https://yandex.com/games/) is a collection of browser HTML5 games for smartphones, computers, tablets, and TVs.

> [!WARNING]
> This extension was created before the "official" Yandex.Games extension for Defold appeared. Therefore, its API differs from the documentation at https://yandex.ru/dev/games/doc/ru/sdk/defold/install
> 
> **Please refer to the HTML5 documentation at https://yandex.ru/dev/games/doc/en/sdk/sdk-about and see below for the corresponding Lua API calls.**

## Installation

You can use it in your own project by adding this project as a [Defold library dependency](http://www.defold.com/manuals/libraries/). Open your `game.project` file and in the dependencies field add **a link to the ZIP file of a [specific release](https://github.com/indiesoftby/defold-yagames/releases).**

## Getting Started

* [📚 The official documentation](https://yandex.com/dev/games/doc/en/?lang=en).
* [💬 The Telegram chat about Defold](https://t.me/DefoldEngine) for Russian-speaking users.
* [💬 The Defold forum topic](https://forum.defold.com/t/yagames-yandex-games-sdk-for-defold/66810) about the this extension.

### Checklist For Releasing Game

1. [Sign up as a developer](https://yandex.ru/dev/games/doc/dg/concepts/about.html?lang=en).
2. Translate your game to the Russian language (*tip:* translate your game title into Russian too!). English and Turkish are optional [(more info)](https://yandex.ru/dev/games/doc/dg/concepts/languages-and-domains.html?lang=en).
3. Prepare assets for the catalogue:
    - Icon 512 x 512 px.
    - Cover 800 x 470 px.
    - Screenshots.
4. Add [the extension](https://github.com/indiesoftby/defold-yagames/archive/master.zip) as a Defold library dependency to your project. 
5. Enable monetization and earn revenue from placing ad blocks in your game. Ad blocks are available in the following formats:
    - **Interstitial blocks**: ad blocks that completely cover the app background and show up at certain points (for example, when accessing the next game level). *Important: Mute sounds before showing the ad!*
    - **Rewarded videos**: blocks with video ads that the user can choose to view and earn a reward or in-game currency. *Important: Mute sounds before showing the ad!*
    - **Sticky banners**: banner ads, super easy to setup.
    - **In-game purchases**: earn revenue by providing paid services to your users.
5. You can [publish your game on Yandex.Games](https://games.yandex.ru/console/) from this moment.

### Best Practices & Tips

1. The YaGames extension imitates a real API on *non-HTML5* platforms. The idea is to allow to you quickly implement API on your favourite platform (macOS, Windows, Linux) and don't spend time on slowly rebuilding/uploading the game to the Yandex.
2. The code from `yagames/manifests/web/engine_template.html` is always added to your HTML5 template. This behaviour can't be disabled. Tip: use Git-branching for every HTML5 platform and do not mix platform-specific code between them.
3. You don't need to set up any cache-busting techniques, since Yandex.Games hosts each version of your game in separate paths.

## Code Examples

Take a look at the demo project inside `example` directory. It has quite a few buttons to test all APIs. You can use it in your game as a debug screen or simply [download/upload a pre-built .zip archive](https://github.com/indiesoftby/defold-yagames/blob/gh-pages/demo_no-sw_no-native-cache.zip?raw=true) to make sure that you implemented SDK in the right way.

![YaGames Demo](screenshot.png)

### 1. Initialization

To get started, you need to initialize the SDK using the `init` method.

```lua
local yagames = require("yagames.yagames")

local function init_handler(self, err)
    if err then
        print("Something bad happened :(", err)
    else
        --
        -- SDK is ready!
        -- From this moment, you can use all available functions, i.e. invoke ads, get player data, etc.
        --

        -- For example, signal that the game has loaded all resources and is ready for user interaction:
        yagames.features_loadingapi_ready()

        -- Do something else!
    end
end

function init(self)
    yagames.init(init_handler)
end
```

### 2. Interstitial Ad

Interstitial ads are ad blocks that completely cover the app background and show up before a user gets the data requested (for example, accessing the next game level).

***Note:** Yandex.Games [recommends that developers call the display of full-screen ads in the game as often as possible](https://yandex.ru/blog/gamesfordevelopers/obnovlenie-algoritmov-pokaza-fulskrinov) but in suitable places in the game — so that the user understands that this is not a part of the game, but an ad unit. Do this in logical pauses in the game, for example: before starting the game, when moving to the next level, after losing.For example, inserting an ad unit is appropriate after going to the next level by pressing a button, and not appropriate in the middle of a level, when an ad suddenly appears under the playerʼs finger.*

* `open` - Called when an ad is opened successfully.
* `close` - Called when an ad is closed, an error occurred, or on ad failed to open due to too frequent calls. Used with the `was_shown` argument (type `boolean`), the value of which indicates whether an ad was shown.
* `offline` - Called when the network connection is lost (when offline mode is enabled).
* `error` - Called when an error occurrs. The error object is passed to the callback function.

**The `close` callback is called in any situation, even if there was an error.**

```lua
local yagames = require("yagames.yagames")

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

### 3. Rewarded Videos

Rewarded videos are video ad blocks used to monetize games and earn a reward or in-game currency.

* `open` - Called when a video ad is displayed on the screen.
* `rewarded` - Called when a video ad impression is counted. Use this function to specify a reward for viewing the video ad. 
* `close` - Called when a user closes a video ad or an error happens.
* `error` - Called when an error occurrs. The error object is passed to the callback function.

**The `close` callback is called in any situation, even if there was an error.** The `rewarded` callback is called before `close`, and you should update your in-game UI only after `close`.

```lua
local yagames = require("yagames.yagames")

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

### Misc

> [!TIP]
> We don't use thes features in our games as we don't see any improvements in our games metrics, and the complexity of its integration and support is quite high.

#### Native Cache How-To

Yandex's [Native Cache](https://yandex.ru/dev/games/doc/dg/concepts/native-cache-settings.html?lang=en) lets users use games offline. Currently, it's available only in Yandex Browser or the Yandex app on smartphones.

1. Set the path to the file `yandex-manifest.json` in the `game.project` settings.
2. Copy the `yagames/manifests/web/yandex-manifest.json` file to the root directory of your release build.
3. Edit the list of all game files inside your `yandex-manifest.json`, and update the path to the icon. Omit `sw.js` and `yandex-manifest.json`.

#### Service Worker How-To

Yandex dropped the Service Worker description page in their docs, but it still allows to integrate Service Worker into your game to be able to run both offline and online. 

1. Set the path to the file `sw.js` in the `game.project` settings.
2. Copy the `yagames/manifests/web/sw.js` file to the root directory of your release build.
3. Edit the list of all game files inside your `sw.js`. Omit `sw.js` and `yandex-manifest.json`.
4. You should increment the version inside `sw.js` on every update of your game on Yandex.Games.

## The `game.project` Settings (Optional!)

```ini
[yagames]
sdk_url = /sdk.js
sdk_init_options = {}
sdk_init_snippet = console.log("Yandex Games SDK is ready!");
service_worker_url = sw.js
manifest_url = yandex-manifest.json
```

* `sdk_url` - Sets the URL of the Yandex.Games SDK. In July 2024 the platform changed the URL of its SDK and now it can be of two kinds. First is the local `/sdk.js` for games you upload as an archive (default, **suitable for 99% of games**). The second is for iFrame games - `https://sdk.games.s3.yandex.net/sdk.js`.
* `sdk_init_options` - JavaScript Object that is passed as-is into the Yandex Games SDK initialization options for [the JS `YaGames.init` function](https://yandex.ru/dev/games/doc/dg/sdk/sdk-about.html?lang=en). Example: `{ orientation: { value: "landscape", lock: true } }`.
* `sdk_init_snippet` - JavaScript code that is passed as-is and called when the `ysdk` variable becomes available. Example: `console.log(ysdk);`. **Use with care, and don't forget to put a semicolon `;` at the end.**
* `service_worker_url` - Relative URL to the Service Worker file. Usually it's `sw.js`. Set the URL to enable Service Worker.
* `manifest_url` - URL to the Web App Manifest file. Set the URL to enable support of Yandex Native Cache.

## 🌒 Lua API

Yandex.Games JavaScript SDK uses ES6 Promise for asynchronous operations. For Lua API promises were replaced with callback functions with arguments `(self, err, result)`, where

- `self` <kbd>userdata</kbd> - Script self reference.
- `err` <kbd>string</kbd> - Error code if something went wrong.
- `result` - Data if the operation should return something.

The best way to integrate SDK into your game is to read [the official documentation](https://yandex.ru/dev/games/doc/dg/concepts/about.html?lang=en) and to use corresponding Lua API functions. 

And it's also a good idea to upload a demo build of YaGames to your game's draft and click on the buttons to understand what the arguments are and what each function returns.

#### Table of Contents

- [Initialization](#-initialization-docs)
- [Advertisement](#-advertisement-docs)
- [Advertisement - Sticky Banners](#-advertisement---sticky-banners-docs)
- [Authentication + Player](#-authentication--player-docs)
- [In-Game Purchases](#-in-game-purchases-docs)
- [Leaderboards](#-leaderboards-docs)
- [Features](#-features-docs)
- [Feedback](#-feedback-docs)
- [Clipboard](#-clipboard-docs)
- [Device Info](#-device-info-docs)
- [Environment](#-environment-docs)
- [Screen](#-screen-docs)
- [Shortcuts](#-shortcuts-docs)
- [Safe Storage](#-safe-storage-docs)
- [Remote Config](#-remote-config-docs)
- [Events](#-events-docs)
- [Multiplayer Sessions](#-multiplayer-sessions-docs)
- [Sitelock](#-sitelock-docs)

### 🌒 INITIALIZATION [(docs)](https://yandex.ru/dev/games/doc/ru/sdk/sdk-about)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `YaGames.init(options)` | `yagames.init(callback)` |
| `ysdk.isAvailableMethod(name)` | `yagames.is_available_method(name, callback)` |

#### `yagames.init(callback)`

Initializes the YaGames extension and waits for Yandex.Games SDK initialization. This method must be called before using any other YaGames functions.

**Parameters:**
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err)`. If `err` is not `nil`, initialization failed.

**Note:** The `options` parameter from JavaScript SDK (a JavaScript object `{}`) can be set in the `yagames.sdk_init_options` setting in your `game.project` file. See [The `game.project` Settings](#the-gameproject-settings-optional) section for details. This approach is used because the SDK initialization happens asynchronously during the game loading process, not at the moment when the Lua API is called.

**Example:**

```lua
local yagames = require("yagames.yagames")

local function init_handler(self, err)
    if err then
        print("YaGames initialization failed:", err)
        -- Handle error (show error message to user, etc.)
    else
        print("YaGames initialized successfully!")
        -- SDK is ready! You can now use all available functions.
        
        -- Signal that the game has loaded all resources and is ready for user interaction:
        yagames.features_loadingapi_ready()
        
        -- Continue with your game initialization...
    end
end

function init(self)
    yagames.init(init_handler)
end
```

#### `yagames.is_available_method(name, callback)`

Checks if a specific SDK method is available to call. This is useful for checking feature availability before attempting to use them.

**Parameters:**
- `name` <kbd>string</kbd> - The name of the method to check (e.g., `"adv.showFullscreenAdv"`, `"payments.purchase"`).
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, result)`, where `result` is a boolean indicating if the method is available.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Check if fullscreen ads are available
yagames.is_available_method("adv.showFullscreenAdv", function(self, err, result)
    if err then
        print("Error checking method availability:", err)
    elseif result then
        print("Fullscreen ads are available!")
        -- You can safely call yagames.adv_show_fullscreen_adv()
    else
        print("Fullscreen ads are not available on this platform")
        -- Use alternative monetization method
    end
end)

-- Check multiple methods
local methods_to_check = {
    "adv.showFullscreenAdv",
    "payments.purchase",
    "leaderboards.setLeaderboardScore"
}

for _, method_name in ipairs(methods_to_check) do
    yagames.is_available_method(method_name, function(self, err, result)
        if not err and result then
            print("Method '" .. method_name .. "' is available")
        end
    end)
end
```

### 🌒 ADVERTISEMENT [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-adv)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.adv.showFullscreenAdv({callbacks:{}})` | `yagames.adv_show_fullscreen_adv(callbacks)` |
| `ysdk.adv.showRewardedVideo({callbacks:{}})` | `yagames.adv_show_rewarded_video(callbacks)` |

#### `yagames.adv_show_fullscreen_adv(callbacks)`

Calls the fullscreen (interstitial) ad. Fullscreen ad blocks completely cover the game background and are shown when a player waits for something (for example, when switching to the next level of the game).

> [!IMPORTANT]
> **Mute all sounds before showing the ad!** You should switch off all sounds in the `open` callback and switch them back in the `close` callback.

> [!NOTE]
> Yandex.Games [recommends that developers call the display of full-screen ads in the game as often as possible](https://yandex.ru/blog/gamesfordevelopers/obnovlenie-algoritmov-pokaza-fulskrinov) but in suitable places in the game — so that the user understands that this is not a part of the game, but an ad unit. Do this in logical pauses in the game, for example: before starting the game, when moving to the next level, after losing. For example, inserting an ad unit is appropriate after going to the next level by pressing a button, and not appropriate in the middle of a level, when an ad suddenly appears under the player's finger.

**Parameters:**
- `callbacks` <kbd>table</kbd> - Table with callback functions:
  - `open` <kbd>function</kbd> - Called when an ad is opened successfully. **Mute sounds here!**
  - `close` <kbd>function</kbd> - Called when an ad is closed, an error occurred, or if ad failed to open due to too frequent calls. Receives `was_shown` argument (type `boolean`) indicating whether an ad was actually shown. **The `close` callback is called in any situation, even if there was an error.** **Unmute sounds here!**
  - `offline` <kbd>function</kbd> - Called when the network connection is lost (when offline mode is enabled).
  - `error` <kbd>function</kbd> - Called when an error occurs. The error object is passed to the callback function.

**Example:**

```lua
local yagames = require("yagames.yagames")

local function adv_open(self)
    -- Mute all game sounds!
    sound.set_group_gain("master", 0)
    print("Fullscreen ad opened")
end

local function adv_close(self, was_shown)
    -- Unmute all game sounds!
    sound.set_group_gain("master", 1)
    
    if was_shown then
        print("Fullscreen ad was shown and closed")
        -- Continue to the next level, etc.
    else
        print("Fullscreen ad was not shown (too frequent calls or error)")
        -- Handle the case when ad wasn't shown
    end
end

local function adv_offline(self)
    print("Network connection lost")
    -- Handle offline mode
end

local function adv_error(self, err)
    print("Error showing fullscreen ad:", err)
    -- Handle error
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

#### `yagames.adv_show_rewarded_video(callbacks)`

Calls the rewarded video ad. Rewarded videos are video ad blocks used to monetize games and earn a reward or in-game currency. The user can choose to view the video ad to earn a reward.

> [!IMPORTANT]
> **Mute all sounds before showing the ad!** You should switch off all sounds in the `open` callback and switch them back in the `close` callback.

> [!NOTE]
> The frequency of calling rewarded video ads is not limited by the platform.

**Parameters:**
- `callbacks` <kbd>table</kbd> - Table with callback functions:
  - `open` <kbd>function</kbd> - Called when a video ad is displayed on the screen. **Mute sounds here!**
  - `rewarded` <kbd>function</kbd> - Called when a video ad impression is counted. Use this function to specify a reward for viewing the video ad (e.g., add coins, unlock features). **The `rewarded` callback is called before `close`, and you should update your in-game UI only after `close`.**
  - `close` <kbd>function</kbd> - Called when a user closes a video ad or an error happens. **The `close` callback is called in any situation, even if there was an error.** **Unmute sounds here!**
  - `error` <kbd>function</kbd> - Called when an error occurs. The error object is passed to the callback function.

**Example:**

```lua
local yagames = require("yagames.yagames")

local function rewarded_open(self)
    -- Mute all game sounds!
    sound.set_group_gain("master", 0)
    print("Rewarded video ad opened")
end

local function rewarded_rewarded(self)
    -- Add reward here (coins, lives, etc.)
    -- But don't update UI yet - wait for 'close' callback
    print("User watched the video! Reward will be given after ad closes.")
    -- Store reward flag, update actual values in 'close' callback
end

local function rewarded_close(self)
    -- Unmute all game sounds!
    sound.set_group_gain("master", 1)
    
    -- Now update UI and give the reward
    print("Rewarded video ad closed")
    -- Give coins, unlock features, update UI, etc.
end

local function rewarded_error(self, err)
    print("Error showing rewarded video ad:", err)
    -- Handle error (maybe show alternative reward method)
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

### 🌒 ADVERTISEMENT - STICKY BANNERS [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-adv#sticky-banner)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.adv.getBannerAdvStatus()` | `yagames.adv_get_banner_adv_status(callback)` |
| `ysdk.adv.showBannerAdv()` | `yagames.adv_show_banner_adv([callback])` |
| `ysdk.adv.hideBannerAdv()` | `yagames.adv_hide_banner_adv([callback])` |

#### `yagames.adv_get_banner_adv_status(callback)`

Gets the current status of the sticky banner ad. Use this to check if a banner is currently showing before attempting to show or hide it.

**Parameters:**
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, result)`, where `result` is a table `{ stickyAdvIsShowing = boolean, [reason] = "string" }`. If `stickyAdvIsShowing = false`, the optional `reason` field may contain: `"ADV_IS_NOT_CONNECTED"` (banners are not connected) or `"UNKNOWN"` (error on Yandex side).

**Example:**

```lua
local yagames = require("yagames.yagames")

yagames.adv_get_banner_adv_status(function(self, err, result)
    if err then
        print("Error getting banner status:", err)
    elseif result.stickyAdvIsShowing then
        print("Banner is currently showing")
    elseif result.reason then
        print("Banner is not showing. Reason:", result.reason)
    else
        print("Banner is not showing. You can call showBannerAdv()")
        -- Show banner if needed
        yagames.adv_show_banner_adv()
    end
end)
```

#### `yagames.adv_show_banner_adv([callback])`

Shows the sticky banner ad. By default, sticky banners appear when the game starts and display for the entire session. To control when banners appear, enable "Use API for showing sticky banner" in the Developer Console and use this method.

**Parameters:**
- `callback` <kbd>function</kbd> (optional) - Callback function with arguments `(self, err, result)`, where `result` is a table `{ stickyAdvIsShowing = boolean, [reason] = "string" }`.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Show banner without callback
yagames.adv_show_banner_adv()

-- Show banner with callback
yagames.adv_show_banner_adv(function(self, err, result)
    if err then
        print("Error showing banner:", err)
    elseif result.stickyAdvIsShowing then
        print("Banner is now showing")
    elseif result.reason then
        print("Banner failed to show. Reason:", result.reason)
    end
end)
```

#### `yagames.adv_hide_banner_adv([callback])`

Hides the sticky banner ad.

**Parameters:**
- `callback` <kbd>function</kbd> (optional) - Callback function with arguments `(self, err, result)`, where `result` is a table `{ stickyAdvIsShowing = boolean }`.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Hide banner without callback
yagames.adv_hide_banner_adv()

-- Hide banner with callback
yagames.adv_hide_banner_adv(function(self, err, result)
    if err then
        print("Error hiding banner:", err)
    else
        print("Banner hidden. stickyAdvIsShowing:", result.stickyAdvIsShowing)
    end
end)
```

> [!NOTE]
> To use sticky banners, you need to configure them in the [Developer Console](https://games.yandex.ru/console/):
> 1. Go to the **Advertising** tab
> 2. In the **Sticky Banners** section, configure banner display for mobile devices (portrait/landscape) and desktop
> 3. Enable **"Use API for showing sticky banner"** option if you want to control banner display programmatically

### 🌒 AUTHENTICATION + PLAYER [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-player)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.auth.openAuthDialog()` | `yagames.auth_open_auth_dialog(callback)` |
| `ysdk.getPlayer(options)` | `yagames.player_init(options, callback)` |
| `player._personalInfo` | `yagames.player_get_personal_info()` |
| `player.signature` | `yagames.player_get_signature()` |
| `player.setData(data, flush)` | `yagames.player_set_data(data, flush, callback)` |
| `player.getData(keys)` | `yagames.player_get_data(keys, callback)` |
| `player.setStats(stats)` | `yagames.player_set_stats(stats, callback)` |
| `player.incrementStats(increments)` | `yagames.player_increment_stats(increments, callback)` |
| `player.getStats(keys)` | `yagames.player_get_stats(keys, callback)` |
| ~~`player.getID()`~~ <kbd>Deprecated</kbd> | ~~`yagames.player_get_id()`~~ <kbd>Deprecated</kbd> |
| `player.getUniqueID()` | `yagames.player_get_unique_id()` |
| `player.getIDsPerGame()` | `yagames.player_get_ids_per_game(callback)` |
| `player.getMode()` | `yagames.player_get_mode()` |
| `player.isAuthorized()` | `yagames.player_is_authorized()` |
| `player.getName()` | `yagames.player_get_name()` |
| `player.getPhoto(size)` | `yagames.player_get_photo(size)` |
| `player.getPayingStatus()` | `yagames.player_get_paying_status()` |

#### `yagames.auth_open_auth_dialog(callback)`

Opens the authorization dialog box. Use this method if the player is not authorized and you want to prompt them to authorize.

> [!TIP]
> Inform the user about the benefits of authorization. If the user doesn't understand why they need to authorize, they will likely refuse and exit the game.

**Parameters:**
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err)`. If `err` is `nil`, authorization was successful.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Note: Call player_init() only once, then use all player_* functions
-- This example shows the general idea
yagames.player_init({}, function(self, err)
    if err then
        print("Error initializing player:", err)
        return
    end
    
    if not yagames.player_is_authorized() then
        -- Player is not authorized, show auth dialog
        yagames.auth_open_auth_dialog(function(self, err)
            if err then
                print("Authorization cancelled or failed:", err)
            else
                print("Authorization successful!")
                -- Note: In real code, call player_init() only once at startup
                -- Re-initialize player to get authorized data (for demonstration only)
                yagames.player_init({}, function(self, err)
                    if not err then
                        print("Player name:", yagames.player_get_name())
                    end
                end)
            end
        end)
    else
        print("Player is already authorized")
        print("Player name:", yagames.player_get_name())
    end
end)
```

#### `yagames.player_init(options, callback)`

Initializes the Player system. This method must be called **once** before using any other player-related functions. After initialization, you can use all `player_*` functions. The Player object provides access to user data, game progress, and profile information.

> [!NOTE]
> Rate limit: **20 requests per 5 minutes**.

**Parameters:**
- `options` <kbd>table</kbd> (optional) - Table with initialization options:
  - `signed` <kbd>boolean</kbd> (optional) - If `true`, enables signature generation for server-side authentication. Use this when processing payments on your server to prevent fraud. Default: `false`.
  - `scopes` <kbd>boolean</kbd> (optional) - If `true`, requests access to user's personal data (name, avatar, etc.). Default: `false`.
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err)`. If `err` is not `nil`, initialization failed.

**Possible errors:**
- `"FetchError: Unauthorized"` - Authorization required
- `"TypeError: Failed to fetch"` - Network error

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Note: Call player_init() only once, then use all player_* functions
-- Initialize player with default options (no signature, no scopes)
yagames.player_init({}, function(self, err)
    if err then
        print("Player initialization failed:", err)
        return
    end
    
    print("Player initialized successfully!")
    print("Unique ID:", yagames.player_get_unique_id())
    print("Is authorized:", yagames.player_is_authorized())
end)

-- Note: Call player_init() only once, then use all player_* functions
-- Initialize player with signature for server-side authentication
yagames.player_init({signed = true}, function(self, err)
    if err then
        print("Player initialization failed:", err)
        return
    end
    
    local signature = yagames.player_get_signature()
    if signature then
        -- Send signature to your server for authentication
        -- signature contains two Base64-encoded strings: <signature>.<profile_data>
        print("Signature available for server authentication")
    end
end)

-- Note: Call player_init() only once, then use all player_* functions
-- Initialize player with scopes to access personal data
yagames.player_init({scopes = true}, function(self, err)
    if err then
        print("Player initialization failed:", err)
        return
    end
    
    if yagames.player_is_authorized() then
        print("Player name:", yagames.player_get_name())
        print("Player photo:", yagames.player_get_photo("large"))
    end
end)
```

#### `yagames.player_get_personal_info()`

Returns a table with player's personal information from their Yandex profile. Available only for authorized players who granted access to personal data.

**Returns:**
- <kbd>table</kbd> or <kbd>nil</kbd> - Table with personal info if available, or `nil` if the `_personalInfo` object is not available.

**Example:**

```lua
local yagames = require("yagames.yagames")

local personal_info = yagames.player_get_personal_info()
if personal_info then
    print("Personal info available:", personal_info)
    -- Access specific fields if needed
else
    print("Personal info not available (player not authorized or scopes not requested)")
end
```

#### `yagames.player_get_signature()`

Returns a string containing the user's data from their Yandex profile and a signature. Available only when player is initialized with `options.signed = true`. Used for server-side authentication to prevent fraud.

**Returns:**
- <kbd>string</kbd> or <kbd>nil</kbd> - Signature string if available, or `nil` if player was not initialized with `signed = true`.

The signature consists of two Base64-encoded strings separated by a dot:
```
<signature>.<profile_data>
```

> [!NOTE]
> The signature can be sent to your server no more than **20 times per 5 minutes**, otherwise the request will be rejected with an error.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Note: Call player_init() only once, then use all player_* functions
-- Initialize with signed = true
yagames.player_init({signed = true}, function(self, err)
    if err then
        print("Initialization failed:", err)
        return
    end
    
    local signature = yagames.player_get_signature()
    if signature then
        -- Send to your server for authentication
        -- Example: http.request("https://your-server.com/auth", "POST", signature)
        print("Signature:", signature)
    end
end)
```

#### `yagames.player_set_data(data, flush, callback)`

Saves user's game data to Yandex servers. Use this to store game progress, levels completed, settings, etc.

> [!WARNING]
> Maximum data size: **200 KB**. Exceeding this limit will result in an error.

> [!NOTE]
> Request rate limit: **100 requests per 5 minutes**.

**Parameters:**
- `data` <kbd>table</kbd> - Table containing key-value pairs. Example: `{ level = 5, coins = 100, settings = { sound = true } }`.
- `flush` <kbd>boolean</kbd> - Specifies when data is sent:
  - `true` - Data is sent immediately to the server
  - `false` (default) - Request is queued and sent later
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err)`. If `err` is `nil`, data was saved successfully.

**Note:** When `flush = false`, the callback only indicates data validity. The actual send is queued and happens later. However, `player_get_data()` will return the data set by the last `player_set_data()` call, even if it hasn't been sent yet.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Save game progress immediately
yagames.player_set_data({
    level = 5,
    coins = 100,
    unlocked_levels = {1, 2, 3, 4, 5},
    settings = {
        sound_enabled = true,
        music_enabled = false
    }
}, true, function(self, err)
    if err then
        print("Failed to save data:", err)
    else
        print("Game progress saved successfully!")
    end
end)

-- Queue data save (non-blocking)
yagames.player_set_data({
    last_play_time = os.time(),
    achievements = {"first_win", "level_5_complete"}
}, false, function(self, err)
    if err then
        print("Data validation failed:", err)
    else
        print("Data queued for saving")
    end
end)
```

#### `yagames.player_get_data(keys, callback)`

Asynchronously retrieves user's game data stored on Yandex servers.

> [!NOTE]
> Request rate is limited. Exceeding limits will result in errors.

**Parameters:**
- `keys` <kbd>table</kbd> (optional) - List of keys to retrieve (e.g., `{"level", "coins"}`). If `nil`, returns all game data.
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, result)`, where `result` is a table with key-value pairs.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Get all player data
yagames.player_get_data(nil, function(self, err, data)
    if err then
        print("Failed to get data:", err)
    else
        print("All player data:", data)
        if data.level then
            print("Current level:", data.level)
        end
        if data.coins then
            print("Coins:", data.coins)
        end
    end
end)

-- Get specific keys only
yagames.player_get_data({"level", "coins", "settings"}, function(self, err, data)
    if err then
        print("Failed to get data:", err)
    else
        print("Level:", data.level or "not set")
        print("Coins:", data.coins or 0)
        print("Settings:", data.settings or {})
    end
end)
```

#### `yagames.player_set_stats(stats, callback)`

Saves user's numeric statistics. Use this for tracking scores, achievements, counters, etc.

> [!WARNING]
> Maximum data size: **10 KB**. Only numeric values are supported.

> [!NOTE]
> Request rate limit: **60 requests per 1 minute**.

**Parameters:**
- `stats` <kbd>table</kbd> - Table with numeric key-value pairs. Example: `{ kills = 100, deaths = 5, score = 5000 }`.
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, result)`, where `result` contains the changed key-value pairs.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Save player statistics
yagames.player_set_stats({
    total_kills = 150,
    total_deaths = 10,
    high_score = 5000,
    games_played = 25
}, function(self, err, result)
    if err then
        print("Failed to save stats:", err)
    else
        print("Stats saved:", result)
    end
end)
```

#### `yagames.player_increment_stats(increments, callback)`

Increments (adds to) user's numeric statistics. Use this to update counters without reading current values first.

> [!WARNING]
> Maximum data size: **10 KB**. Only numeric values are supported.

**Parameters:**
- `increments` <kbd>table</kbd> - Table with numeric increments. Example: `{ kills = 5, score = 100 }` (adds 5 to kills, 100 to score).
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, result)`, where `result` contains the updated key-value pairs after increment.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Increment statistics after a game session
yagames.player_increment_stats({
    kills = 10,      -- Add 10 kills
    score = 500,     -- Add 500 to score
    games_played = 1 -- Increment games played by 1
}, function(self, err, result)
    if err then
        print("Failed to increment stats:", err)
    else
        print("Updated stats:", result)
        print("New kill count:", result.kills)
        print("New score:", result.score)
    end
end)

-- Can also use negative values to decrement
yagames.player_increment_stats({
    lives = -1  -- Decrease lives by 1
}, function(self, err, result)
    if not err then
        print("Lives remaining:", result.lives)
    end
end)
```

#### `yagames.player_get_stats(keys, callback)`

Asynchronously retrieves user's numeric statistics.

**Parameters:**
- `keys` <kbd>table</kbd> (optional) - List of keys to retrieve (e.g., `{"kills", "score"}`). If `nil`, returns all statistics.
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, result)`, where `result` is a table with numeric key-value pairs.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Get all statistics
yagames.player_get_stats(nil, function(self, err, stats)
    if err then
        print("Failed to get stats:", err)
    else
        print("All stats:", stats)
        print("Total kills:", stats.kills or 0)
        print("High score:", stats.high_score or 0)
    end
end)

-- Get specific statistics
yagames.player_get_stats({"kills", "deaths", "score"}, function(self, err, stats)
    if err then
        print("Failed to get stats:", err)
    else
        local kd_ratio = (stats.kills or 0) / math.max(stats.deaths or 1, 1)
        print("K/D ratio:", kd_ratio)
        print("Score:", stats.score or 0)
    end
end)
```

#### `yagames.player_get_unique_id()`

Returns the user's unique permanent identifier. This ID remains constant across sessions and games.

> [!IMPORTANT]
> The previously used `player_get_id()` method is deprecated. Use `player_get_unique_id()` instead. If your game previously used `player_get_id()` and stored data associated with it, you need to migrate that data to use `player_get_unique_id()`.

**Returns:**
- <kbd>string</kbd> - The user's unique ID.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Note: Call player_init() only once, then use all player_* functions
yagames.player_init({}, function(self, err)
    if not err then
        local user_id = yagames.player_get_unique_id()
        print("User ID:", user_id)
        -- Store this ID on your server for user identification
    end
end)
```

#### `yagames.player_get_ids_per_game(callback)`

Returns a table (array) with user IDs in all developer games where the user has explicitly consented to transfer their personal data.

> [!WARNING]
> This request is only available for authorized users. Use `yagames.auth_open_auth_dialog()` if needed.

**Parameters:**
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, result)`, where `result` is an array of tables with `appID` and `userID` fields.

**Example:**

```lua
local yagames = require("yagames.yagames")

yagames.player_get_ids_per_game(function(self, err, ids)
    if err then
        print("Failed to get IDs:", err)
        -- User might not be authorized
    else
        print("User IDs across games:", ids)
        -- Example result:
        -- {
        --     { appID = 103915, userID = "tOpLpSh7i8QG8Voh/SuPbeS4NKTj1OxATCTKQF92H4c=" },
        --     { appID = 103993, userID = "bviQCIAAuVmNMP66bZzC4x+4oSFzRKpteZ/euP/Jwv4=" }
        -- }
        for _, game_id in ipairs(ids) do
            print("Game", game_id.appID, "User ID:", game_id.userID)
        end
    end
end)
```

#### `yagames.player_get_mode()`

Returns the user's authorization mode.

> [!WARNING]
> This method is deprecated. Use `yagames.player_is_authorized()` instead.

**Returns:**
- <kbd>string</kbd> - Authorization mode: `"lite"` or `""` (empty string).

**Example:**

```lua
local yagames = require("yagames.yagames")

local mode = yagames.player_get_mode()
if mode == "lite" then
    print("User is in lite mode")
else
    print("User is authorized")
end
```

#### `yagames.player_is_authorized()`

Checks if the player is authorized on Yandex.

**Returns:**
- <kbd>boolean</kbd> - `true` if authorized, `false` otherwise.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Note: Call player_init() only once, then use all player_* functions
yagames.player_init({scopes = true}, function(self, err)
    if not err then
        if yagames.player_is_authorized() then
            print("Player is authorized")
            print("Name:", yagames.player_get_name())
            print("Photo:", yagames.player_get_photo("large"))
        else
            print("Player is not authorized")
            -- Show auth dialog
            yagames.auth_open_auth_dialog(function(self, err)
                if not err then
                    print("Authorization successful!")
                end
            end)
        end
    end
end)
```

#### `yagames.player_get_name()`

Returns the user's name from their Yandex profile.

**Returns:**
- <kbd>string</kbd> - User's name, or empty string if not available.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Note: Call player_init() only once, then use all player_* functions
yagames.player_init({scopes = true}, function(self, err)
    if not err then
        local name = yagames.player_get_name()
        if name and name ~= "" then
            print("Welcome,", name .. "!")
        else
            print("Welcome, Player!")
        end
    end
end)
```

#### `yagames.player_get_photo(size)`

Returns the URL of the user's avatar from their Yandex profile.

**Parameters:**
- `size` <kbd>string</kbd> - Required avatar size. Possible values: `"small"`, `"medium"`, `"large"`.

**Returns:**
- <kbd>string</kbd> - Avatar URL, or empty string if not available.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Note: Call player_init() only once, then use all player_* functions
yagames.player_init({scopes = true}, function(self, err)
    if not err then
        local photo_url = yagames.player_get_photo("large")
        if photo_url and photo_url ~= "" then
            print("Avatar URL:", photo_url)
            -- Load avatar image using the URL
            -- gui.load_texture("avatar", photo_url)
        end
    end
end)
```

#### `yagames.player_get_paying_status()`

Returns the user's payment status based on their purchase history on the Yandex platform. Useful for offering premium content or alternative monetization to paying users.

**Returns:**
- <kbd>string</kbd> - One of four possible values:
  - `"paying"` - User purchased portal currency for more than 500 rubles in the last month
  - `"partially_paying"` - User had at least one purchase of portal currency with real money in the last year
  - `"not_paying"` - User hasn't made any purchases of portal currency with real money in the last year
  - `"unknown"` - User is not from Russia or hasn't allowed sharing this information

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Note: Call player_init() only once, then use all player_* functions
yagames.player_init({}, function(self, err)
    if not err then
        local paying_status = yagames.player_get_paying_status()
        
        if paying_status == "paying" or paying_status == "partially_paying" then
            -- Offer premium content or skip ads for paying users
            print("Paying user detected - offering premium features")
            -- show_premium_content()
        elseif paying_status == "not_paying" then
            -- Show ads or free content
            print("Non-paying user - showing ads")
            -- show_ads()
        else
            -- Unknown status (user not from Russia)
            print("Payment status unknown")
        end
    end
end)
```

### 🌒 IN-GAME PURCHASES [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-purchases)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.getPayments(options)` | `yagames.payments_init(options, callback)` |
| `payments.purchase(options)` | `yagames.payments_purchase(options, callback)` |
| `payments.getPurchases()` | `yagames.payments_get_purchases(callback)` |
| `payments.getCatalog()` | `yagames.payments_get_catalog([options], callback)` |
| `payments.consumePurchase(purchaseToken)` | `yagames.payments_consume_purchase(purchase_token, callback)` |

#### `yagames.payments_init(options, callback)`

Initializes the in-game purchases system. This method must be called **once** before using any other payment-related functions. After initialization, you can use all `payments_*` functions.

> [!IMPORTANT]
> To enable in-game purchases:
> 1. Enable monetization in the [Developer Console](https://games.yandex.ru/console/)
> 2. Go to the **In-Game Purchases** tab and ensure there's at least one product in the table
> 3. Verify that **"Purchases connected"** message is displayed
> 4. After adding purchases and publishing a draft, send an email to games-partners@yandex-team.ru with your game name and ID to request purchase activation

> [!WARNING]
> Test purchases only after enabling their consumption. Otherwise, unprocessed payments may appear, making moderation impossible.

**Parameters:**
- `options` <kbd>table</kbd> (optional) - Table with initialization options:
  - `signed` <kbd>boolean</kbd> (optional) - If `true`, enables signature generation for server-side fraud prevention. Use this when processing payments on your server. Default: `false`.
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err)`. If `err` is not `nil`, initialization failed.

> [!NOTE]
> The `signed` parameter is used for fraud prevention:
> - **Client-side processing**: Use `signed: false` or omit the parameter. Purchase data will be returned in plain format.
> - **Server-side processing**: Use `signed: true`. Purchase data will be returned only in encrypted format in the `signature` parameter.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Note: Call payments_init() only once, then use all payments_* functions
-- Initialize payments for client-side processing
yagames.payments_init({}, function(self, err)
    if err then
        print("Payments initialization failed:", err)
        -- Purchases are not available
    else
        print("Payments initialized successfully!")
        -- Now you can use payments_get_catalog(), payments_purchase(), etc.
    end
end)

-- Initialize payments for server-side processing (with signature)
yagames.payments_init({signed = true}, function(self, err)
    if err then
        print("Payments initialization failed:", err)
    else
        print("Payments initialized with signature support")
        -- Purchase data will be encrypted in signature parameter
    end
end)
```

#### `yagames.payments_purchase(options, callback)`

Activates an in-game purchase process. Shows the purchase dialog to the user.

**Parameters:**
- `options` <kbd>table</kbd> - Table with purchase options:
  - `id` <kbd>string</kbd> - Product ID as set in the Developer Console
  - `developerPayload` <kbd>string</kbd> (optional) - Additional information about the purchase to send to your server (will be included in the `signature` parameter)
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, purchase)`, where `purchase` is a table with purchase data including `purchaseToken`.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Purchase an item
yagames.payments_purchase({
    id = "no_ads",  -- Product ID from Developer Console
    developerPayload = "user_123"  -- Optional: additional data for your server
}, function(self, err, purchase)
    if err then
        print("Purchase failed:", err)
        -- Handle error (user cancelled, network error, etc.)
    else
        print("Purchase successful!")
        print("Purchase token:", purchase.purchaseToken)
        print("Product ID:", purchase.product.id)
        
        -- Grant the purchase to the user
        if purchase.product.id == "no_ads" then
            -- Disable ads for this user
            disable_ads()
        elseif purchase.product.id == "coins_100" then
            -- Add 100 coins
            add_coins(100)
        end
        
        -- For consumable purchases, call payments_consume_purchase()
        -- For permanent purchases (like "no_ads"), don't consume
        -- `is_consumable` is a function that returns true if the purchase is consumable, false otherwise.
        -- For example:
        -- function is_consumable(product_id)
        --     return product_id == "coins_100"
        -- end
        if is_consumable(purchase.product.id) then
            yagames.payments_consume_purchase(purchase.purchaseToken, function(self, err)
                if not err then
                    print("Purchase consumed")
                end
            end)
        end
    end
end)
```

#### `yagames.payments_get_purchases(callback)`

Retrieves the list of purchases the player has already made. Use this to check for unprocessed purchases (e.g., when the game was closed during a purchase).

> [!IMPORTANT]
> Always check for unprocessed purchases when the game starts to ensure users receive their purchases even if the game was closed during the purchase process.

**Parameters:**
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, response)`, where `response` is a table:
  - `purchases` <kbd>table</kbd> - Array of purchase objects, each containing `purchaseToken` and `product` information
  - `signature` <kbd>string</kbd> - Signature string (if initialized with `signed: true`), contains encrypted purchase data for server verification

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Check for unprocessed purchases on game start
yagames.payments_get_purchases(function(self, err, response)
    if err then
        print("Failed to get purchases:", err)
        return
    end
    
    print("Total purchases:", #response.purchases)
    
    -- Process each purchase
    for i, purchase in ipairs(response.purchases) do
        print("Processing purchase:", purchase.product.id)
        print("Token:", purchase.purchaseToken)
        
        -- Grant the purchase to the user
        -- `grant_purchase` is a function that grants the purchase to the user.
        -- For example:
        -- function grant_purchase(product_id)
        --     if product_id == "coins_100" then
        --         add_coins(100)
        --     elseif product_id == "lives_5" then
        --         add_lives(5)
        --     else
        --         error("Unknown purchase:" .. product_id)
        --     end
        -- end
        grant_purchase(purchase.product.id)
        
        -- For consumable purchases, consume them after granting
        -- `is_consumable` is a function that returns true if the purchase is consumable, false otherwise.
        -- For example:
        -- function is_consumable(product_id)
        --     return product_id == "coins_100"
        -- end
        if is_consumable(purchase.product.id) then
            yagames.payments_consume_purchase(purchase.purchaseToken, function(self, err)
                if err then
                    print("Failed to consume purchase:", err)
                else
                    print("Purchase consumed successfully")
                end
            end)
        end
    end
    
    -- If using server-side verification, send signature to your server
    if response.signature then
        -- verify_signature_on_server(response.signature)
    end
end)
```

#### `yagames.payments_get_catalog([options], callback)`

Gets the list of all available products and their prices from the Developer Console.

**Parameters:**
- `options` <kbd>table</kbd> (optional) - Table with options:
  - `getPriceCurrencyImage` <kbd>string</kbd> (optional) - Size of currency image to include. Possible values: `"medium"`, `"small"`, `"svg"`. The currency image URL will be added to the `getPriceCurrencyImage` field of each product.
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, catalog)`, where `catalog` is a table with product information.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Note: Call `payments_init()` before using `payments_get_catalog()`.

-- Get catalog without currency images
yagames.payments_get_catalog(function(self, err, catalog)
    if err then
        print("Failed to get catalog:", err)
    else
        print("Available products:")
        for i, product in ipairs(catalog) do
            print("  -", product.id, ":", product.title)
            print("    Price:", product.price.value, product.price.currencyCode)
            print("    Description:", product.description)
        end
    end
end)

-- Get catalog with currency images
yagames.payments_get_catalog({
    getPriceCurrencyImage = "medium"  -- or "small", "svg"
}, function(self, err, catalog)
    if err then
        print("Failed to get catalog:", err)
    else
        for i, product in ipairs(catalog) do
            print("Product:", product.id)
            if product.getPriceCurrencyImage then
                print("Currency image URL:", product.getPriceCurrencyImage)
                -- Load and display currency icon
            end
        end
    end
end)
```

#### `yagames.payments_consume_purchase(purchase_token, callback)`

Consumes (marks as used) a consumable purchase. Use this for purchases that can be bought multiple times (e.g., in-game currency, consumable items).

> [!NOTE]
> There are two types of purchases:
> - **Permanent purchases** (e.g., "disable ads") - Don't consume these, they remain active forever
> - **Consumable purchases** (e.g., coins, lives) - Consume these after granting the purchase, so they can be purchased again

**Parameters:**
- `purchase_token` <kbd>string</kbd> - Purchase token returned by `payments_purchase()` or `payments_get_purchases()`
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err)`. If `err` is `nil`, purchase was consumed successfully.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- After granting a consumable purchase, consume it
function grant_and_consume_purchase(purchase_token, product_id)
    -- First, grant the purchase to the user
    if product_id == "coins_100" then
        add_coins(100)
    elseif product_id == "lives_5" then
        add_lives(5)
    end
    
    -- Then consume the purchase so it can be bought again
    yagames.payments_consume_purchase(purchase_token, function(self, err)
        if err then
            print("Failed to consume purchase:", err)
            -- Important: You may want to rollback the granted items
            -- if consumption fails, or retry consumption later
        else
            print("Purchase consumed successfully")
            -- Purchase can now be bought again
        end
    end)
end

-- Example usage
yagames.payments_purchase({id = "coins_100"}, function(self, err, purchase)
    if not err then
        grant_and_consume_purchase(purchase.purchaseToken, purchase.product.id)
    end
end)
```

> [!NOTE]
> **Server-side verification**: If you initialized payments with `signed: true`, the `signature` parameter in purchase responses contains encrypted purchase data. Verify this signature on your server using HMAC-SHA256 with your secret key from the Developer Console to prevent fraud. See the [official documentation](https://yandex.ru/dev/games/doc/ru/sdk/sdk-purchases#protection) for signature verification examples.

### 🌒 LEADERBOARDS [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-leaderboard)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.getLeaderboards()` | `yagames.leaderboards_init(callback)` |
| `lb.getLeaderboardDescription(leaderboardName)` | `yagames.leaderboards_get_description(leaderboard_name, callback)` |
| `lb.getLeaderboardPlayerEntry(leaderboardName)` | `yagames.leaderboards_get_player_entry(leaderboard_name, [options], callback)` |
| `lb.getLeaderboardEntries(leaderboardName, options)` | `yagames.leaderboards_get_entries(leaderboard_name, [options], callback)` |
| `lb.setLeaderboardScore(leaderboardName, score, extraData)` | `yagames.leaderboards_set_score(leaderboard_name, score, [extra_data], [callback])` |

#### `yagames.leaderboards_init(callback)`

Initializes the leaderboards subsystem. This method must be called **once** before using any other leaderboard-related functions. After initialization, you can use all `leaderboards_*` functions.

> [!IMPORTANT]
> Before using leaderboards, ensure that:
> 1. SDK is initialized (`yagames.init()`)
> 2. A leaderboard is created in the [Developer Console](https://games.yandex.ru/console/) with the correct **Technical Name** (this name will be used in API calls)
>
> If a leaderboard with the specified name doesn't exist in the console, you'll get a 404 error.

**Parameters:**
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err)`. If `err` is not `nil`, initialization failed.

> [!NOTE]
> Rate limit: **20 requests per 5 minutes** for most methods. See individual method descriptions for specific limits.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Note: Call leaderboards_init() only once, then use all leaderboards_* functions
yagames.leaderboards_init(function(self, err)
    if err then
        print("Leaderboards initialization failed:", err)
        -- Leaderboards are not available
    else
        print("Leaderboards initialized successfully!")
        -- Now you can use leaderboards_get_description(), leaderboards_set_score(), etc.
    end
end)
```

#### `yagames.leaderboards_get_description(leaderboard_name, callback)`

Gets the description and configuration of a leaderboard by its name. Use this to retrieve leaderboard settings like sort order, score format, and localized titles.

**Parameters:**
- `leaderboard_name` <kbd>string</kbd> - The technical name of the leaderboard as set in the Developer Console.
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, result)`, where `result` is a table containing:
  - `appID` <kbd>string</kbd> - Application identifier
  - `default` <kbd>boolean</kbd> - `true` if this is the default leaderboard
  - `description` <kbd>table</kbd> - Leaderboard configuration:
    - `invert_sort_order` <kbd>boolean</kbd> - Sort direction: `false` = descending (higher is better), `true` = ascending (lower is better)
    - `score_format` <kbd>table</kbd> - Score format configuration:
      - `type` <kbd>string</kbd> - Score type: `"numeric"` (number) or `"time"` (seconds)
      - `options.decimal_offset` <kbd>number</kbd> - Decimal part size (e.g., `2` means 1234 displays as 12.34)
  - `name` <kbd>string</kbd> - Leaderboard name
  - `title` <kbd>table</kbd> - Localized titles (e.g., `{ ru = "Рейтинг", en = "Rating" }`)

**Example:**

```lua
local yagames = require("yagames.yagames")

local LEADERBOARD_NAME = "RatingTable1"

-- Note: call leaderboards_init() only once, then use all leaderboards_* functions

yagames.leaderboards_get_description(LEADERBOARD_NAME, function(self, err, result)
    if err then
        print("Failed to get leaderboard description:", err)
        -- Check if leaderboard exists in Developer Console
    else
        print("Leaderboard name:", result.name)
        print("Is default:", result.default)
        print("Sort order:", result.description.invert_sort_order and "ascending" or "descending")
        print("Score type:", result.description.score_format.type)
        
        if result.title.ru then
            print("Title (RU):", result.title.ru)
        end
        if result.title.en then
            print("Title (EN):", result.title.en)
        end
    end
end)
```

#### `yagames.leaderboards_set_score(leaderboard_name, score, [extra_data], [callback])`

Sets a new score for the player in the leaderboard. Use this to submit player scores after completing levels, achieving milestones, etc.

> [!WARNING]
> This method is **only available for authorized users**. Use `yagames.auth_open_auth_dialog()` if needed. You can check availability using `yagames.is_available_method("leaderboards.setScore", callback)`.

> [!NOTE]
> Rate limit: **1 request per 1 second**. Exceeding this limit will result in errors.

> [!TIP]
> To save scores for all users regardless of authorization, consider implementing a custom leaderboard in your application code.

**Parameters:**
- `leaderboard_name` <kbd>string</kbd> - The technical name of the leaderboard as set in the Developer Console.
- `score` <kbd>number</kbd> - Score value. Must be a non-negative integer. If the leaderboard type is `"time"`, values must be in milliseconds.
- `extra_data` <kbd>string</kbd> (optional) - Additional user description or metadata to store with the score.
- `callback` <kbd>function</kbd> (optional) - Callback function with arguments `(self, err)`. If `err` is `nil`, score was set successfully.

**Example:**

```lua
local yagames = require("yagames.yagames")

local LEADERBOARD_NAME = "RatingTable1"

-- Note: call leaderboards_init() only once, then use all leaderboards_* functions

-- Set score without extra data
yagames.leaderboards_set_score(LEADERBOARD_NAME, 1000, nil, function(self, err)
    if err then
        print("Failed to set score:", err)
        -- Possible errors:
        -- "FetchError: Unauthorized" - User not authorized
        -- Rate limit exceeded
    else
        print("Score set successfully!")
    end
end)

-- Set score with extra data (e.g., level completed, time taken, etc.)
yagames.leaderboards_set_score(LEADERBOARD_NAME, 2500, "Level 5 completed in 2:30", function(self, err)
    if err then
        print("Failed to set score:", err)
    else
        print("Score with extra data set successfully!")
    end
end)

-- For time-based leaderboards, score must be in milliseconds
local time_in_milliseconds = 125000  -- 2 minutes 5 seconds
yagames.leaderboards_set_score("TimeLeaderboard", time_in_milliseconds, nil, function(self, err)
    if not err then
        print("Time score set!")
    end
end)
```

#### `yagames.leaderboards_get_player_entry(leaderboard_name, [options], callback)`

Gets the player's ranking entry in the leaderboard. Use this to show the player their current position and score.

> [!WARNING]
> This method requires **authorization**. Use `yagames.auth_open_auth_dialog()` if needed.

> [!NOTE]
> Rate limit: **60 requests per 5 minutes**.

**Parameters:**
- `leaderboard_name` <kbd>string</kbd> - The technical name of the leaderboard as set in the Developer Console.
- `options` <kbd>table</kbd> (optional) - Table with options:
  - `getAvatarSrc` <kbd>string</kbd> (optional) - Avatar size to include. Possible values: `"small"`, `"medium"`, `"large"`.
  - `getAvatarSrcSet` <kbd>string</kbd> (optional) - Avatar srcset size for Retina displays. Possible values: `"small"`, `"medium"`, `"large"`.
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, result)`, where `result` is a table containing:
  - `rank` <kbd>number</kbd> - Player's rank (0-based, so rank 0 = 1st place)
  - `score` <kbd>number</kbd> - Player's score
  - `formattedScore` <kbd>string</kbd> - Formatted score string
  - `extraData` <kbd>string</kbd> - Extra data associated with the score
  - `player` <kbd>table</kbd> - Player information:
    - `uniqueID` <kbd>string</kbd> - Player's unique ID
    - `publicName` <kbd>string</kbd> - Player's public name
    - `lang` <kbd>string</kbd> - Player's language code
    - `scopePermissions` <kbd>table</kbd> - Player's scope permissions:
      - `public_name` <kbd>string</kbd> - Permission for public name (e.g., `"allow"`)
      - `avatar` <kbd>string</kbd> - Permission for avatar (e.g., `"allow"`)
    - `getAvatarSrc` <kbd>string</kbd> - Avatar URL (only present if requested in options)
    - `getAvatarSrcSet` <kbd>string</kbd> - Avatar srcset URL (only present if requested in options)

**Possible errors:**
- `"FetchError: Player is not present in leaderboard"` - Player hasn't set a score yet

**Example:**

```lua
local yagames = require("yagames.yagames")

local LEADERBOARD_NAME = "RatingTable1"

-- Note: Call leaderboards_init() only once, then use all leaderboards_* functions

-- Get player entry without avatar
yagames.leaderboards_get_player_entry(LEADERBOARD_NAME, nil, function(self, err, result)
    if err then
        if err == "FetchError: Player is not present in leaderboard" then
            print("Player hasn't set a score yet")
        else
            print("Failed to get player entry:", err)
        end
    else
        local rank_display = result.rank + 1  -- Convert 0-based to 1-based
        print("Player rank:", rank_display)
        print("Player score:", result.score)
        print("Formatted score:", result.formattedScore)
        if result.extraData and result.extraData ~= "" then
            print("Extra data:", result.extraData)
        end
        
        if result.player then
            print("Player name:", result.player.publicName)
            print("Player language:", result.player.lang)
        end
    end
end)

-- Get player entry with avatar URLs
yagames.leaderboards_get_player_entry(LEADERBOARD_NAME, {
    getAvatarSrc = "medium",
    getAvatarSrcSet = "large"
}, function(self, err, result)
    if not err then
        local rank_display = result.rank + 1  -- Convert 0-based to 1-based
        print("Rank:", rank_display)
        print("Score:", result.score)
        print("Formatted score:", result.formattedScore)
        
        if result.player then
            print("Player name:", result.player.publicName)
            if result.player.getAvatarSrc then
                print("Avatar URL:", result.player.getAvatarSrc)
                -- Load and display avatar
            end
            if result.player.getAvatarSrcSet then
                print("Avatar srcset:", result.player.getAvatarSrcSet)
            end
        end
    end
end)
```

#### `yagames.leaderboards_get_entries(leaderboard_name, [options], callback)`

Gets multiple leaderboard entries. Use this to display top players and entries around the current player's position.

> [!NOTE]
> Rate limit: **20 requests per 5 minutes**. Authorization is optional (unauthorized users can still view leaderboards).

**Parameters:**
- `leaderboard_name` <kbd>string</kbd> - The technical name of the leaderboard as set in the Developer Console.
- `options` <kbd>table</kbd> (optional) - Table with options:
  - `includeUser` <kbd>boolean</kbd> (optional) - Include the authorized user in the response. Default: `false`.
  - `quantityAround` <kbd>number</kbd> (optional) - Number of entries below and above the user. Min: 1, Max: 10. Default: 5.
  - `quantityTop` <kbd>number</kbd> (optional) - Number of entries from the top. Min: 1, Max: 20. Default: 5.
  - `getAvatarSrc` <kbd>string</kbd> (optional) - Avatar size to include. Possible values: `"small"`, `"medium"`, `"large"`.
  - `getAvatarSrcSet` <kbd>string</kbd> (optional) - Avatar srcset size for Retina displays. Possible values: `"small"`, `"medium"`, `"large"`.
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, result)`, where `result` is a table containing:
  - `leaderboard` <kbd>table</kbd> - Leaderboard information:
    - `appID` <kbd>string</kbd> - Application identifier
    - `name` <kbd>string</kbd> - Leaderboard technical name
    - `title` <kbd>table</kbd> - Localized titles (e.g., `{ ru = "Рейтинг", en = "Rating" }`)
    - `default` <kbd>boolean</kbd> - `true` if this is the default leaderboard
    - `description` <kbd>table</kbd> - Leaderboard configuration (sort order, score format, etc.)
  - `entries` <kbd>table</kbd> - Array of leaderboard entry objects, each containing:
    - `rank` <kbd>number</kbd> - Entry rank (0-based, so rank 0 = 1st place)
    - `score` <kbd>number</kbd> - Score value
    - `formattedScore` <kbd>string</kbd> - Formatted score string
    - `extraData` <kbd>string</kbd> - Extra data associated with the score
    - `player` <kbd>table</kbd> - Player information:
      - `uniqueID` <kbd>string</kbd> - Player's unique ID
      - `publicName` <kbd>string</kbd> - Player's public name
      - `lang` <kbd>string</kbd> - Player's language code
      - `scopePermissions` <kbd>table</kbd> - Player's scope permissions:
        - `public_name` <kbd>string</kbd> - Permission for public name (e.g., `"allow"`)
        - `avatar` <kbd>string</kbd> - Permission for avatar (e.g., `"allow"`)
      - `getAvatarSrc` <kbd>string</kbd> - Avatar URL (only present if requested in options)
      - `getAvatarSrcSet` <kbd>string</kbd> - Avatar srcset URL for Retina displays (only present if requested in options)
  - `userRank` <kbd>number</kbd> - Current player's rank (0 if not included or not present)
  - `ranges` <kbd>table</kbd> - Array of range objects with `start` and `size` fields

**Example:**

```lua
local yagames = require("yagames.yagames")

local LEADERBOARD_NAME = "RatingTable1"

-- Note: call leaderboards_init() only once, then use all leaderboards_* functions

-- Get top 10 players
yagames.leaderboards_get_entries(LEADERBOARD_NAME, {
    quantityTop = 10,
    getAvatarSrc = "small"
}, function(self, err, result)
    if err then
        print("Failed to get entries:", err)
    else
        print("Top players:")
        for i, entry in ipairs(result.entries) do
            local rank_display = entry.rank + 1  -- Convert 0-based to 1-based
            local player_name = entry.player and entry.player.publicName or "Anonymous"
            print(string.format("%d. Rank %d: %s - Score %d", i, rank_display, player_name, entry.score))
            if entry.player and entry.player.getAvatarSrc then
                print("  Avatar:", entry.player.getAvatarSrc)
            end
        end
    end
end)

-- Get entries around the current player (include player + 5 above + 5 below)
yagames.leaderboards_get_entries(LEADERBOARD_NAME, {
    includeUser = true,
    quantityAround = 5,
    quantityTop = 10,
    getAvatarSrc = "medium",
    getAvatarSrcSet = "large"
}, function(self, err, result)
    if err then
        print("Failed to get entries:", err)
    else
        print("Player rank:", result.userRank)
        print("Total entries:", #result.entries)
        
        for i, entry in ipairs(result.entries) do
            local rank_display = entry.rank + 1  -- Convert 0-based to 1-based
            local player_name = entry.player and entry.player.publicName or "Anonymous"
            print(string.format("%d. Rank %d: %s - Score %d", i, rank_display, player_name, entry.score))
            
            if entry.extraData and entry.extraData ~= "" then
                print("  Extra data:", entry.extraData)
            end
            
            -- Display avatar if available
            if entry.player and entry.player.getAvatarSrc then
                print("  Avatar:", entry.player.getAvatarSrc)
                -- Load avatar image: gui.load_texture("avatar_" .. i, entry.player.getAvatarSrc)
            end
        end
    end
end)
```

### 🌒 FEATURES [(docs)](https://yandex.com/dev/games/doc/en/sdk/sdk-game-events)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.features.LoadingAPI?.ready()` | `yagames.features_loadingapi_ready()` |
| `ysdk.features.GameplayAPI?.start()` | `yagames.features_gameplayapi_start()` |
| `ysdk.features.GameplayAPI?.stop()` | `yagames.features_gameplayapi_stop()` |
| `ysdk.features.GamesAPI?.getAllGames()` | `yagames.features_gamesapi_get_all_games(callback)` |
| `ysdk.features.GamesAPI?.getGameByID(appID)` | `yagames.features_gamesapi_get_game_by_id(app_id, callback)` |

#### `yagames.features_loadingapi_ready()`

Informs the SDK that the game has loaded all resources and is ready for user interaction. This method should be called when:

- All game elements are ready for player interaction
- There are no loading screens visible
- The game is ready to start playing

> [!NOTE]
> This method helps Yandex.Games track loading metrics and improve game loading speed and availability worldwide. The Game Ready metric can be tracked in the Performance tab in DevTools.

**Example:**

```lua
local yagames = require("yagames.yagames")

local function init_handler(self, err)
    if err then
        print("YaGames initialization failed:", err)
    else
        print("YaGames initialized successfully!")
        
        -- Signal that the game has loaded all resources and is ready for user interaction
        yagames.features_loadingapi_ready()
        
        -- Continue with your game initialization...
    end
end

function init(self)
    yagames.init(init_handler)
end
```

#### `yagames.features_gameplayapi_start()`

Signals that the player has started or resumed gameplay. Call this method when:

- Starting a level
- Closing a menu
- Resuming from pause
- Resuming after showing an ad
- Returning to the current browser tab

> [!IMPORTANT]
> Make sure that after calling `features_gameplayapi_start()`, the gameplay is immediately active. This is especially important for multiplayer sessions - without calling this method, multiplayer events will not be sent.

**Example:**

```lua
local yagames = require("yagames.yagames")

local function start_level(self)
    -- Start the level logic
    start_level_logic()
    
    -- Signal that gameplay has started
    yagames.features_gameplayapi_start()
end

function on_message(self, message_id, message)
    if message_id == hash("resume_from_pause") then
        -- Resume gameplay
        resume_gameplay()
        yagames.features_gameplayapi_start()
    elseif message_id == hash("show_ad_complete") then
        -- Resume after ad
        yagames.features_gameplayapi_start()
    end
end
```

#### `yagames.features_gameplayapi_stop()`

Signals that the player has paused or stopped gameplay. Call this method when:

- Completing a level or losing
- Opening a menu
- Pausing the game
- Showing fullscreen or rewarded video ads
- Switching to another browser tab

> [!IMPORTANT]
> Make sure that after calling `features_gameplayapi_stop()`, the gameplay is stopped. When resuming gameplay, call `features_gameplayapi_start()` again.

**Example:**

```lua
local yagames = require("yagames.yagames")

local function pause_game(self)
    -- Pause gameplay logic
    pause_gameplay_logic()
    
    -- Signal that gameplay has stopped
    yagames.features_gameplayapi_stop()
end

local function show_ad_before_level(self)
    -- Stop gameplay before showing ad
    yagames.features_gameplayapi_stop()
    
    -- Show ad
    yagames.adv_show_fullscreen_adv({
        close = function(self, was_shown)
            -- Resume gameplay after ad closes
            yagames.features_gameplayapi_start()
        end
    })
end

local function complete_level(self)
    -- Complete level logic
    complete_level_logic()
    
    -- Signal that gameplay has stopped
    yagames.features_gameplayapi_stop()
end
```

#### `yagames.features_gamesapi_get_all_games(callback)`

Gets information about all your games available on the current platform and domain.

**Parameters:**
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, result)`, where `result` is a table containing:
  - `games` <kbd>table</kbd> - Array of game objects, each containing:
    - `appID` <kbd>string</kbd> - Application identifier (as string)
    - `title` <kbd>string</kbd> - Game title
    - `url` <kbd>string</kbd> - Game URL
    - `coverURL` <kbd>string</kbd> - Cover image URL
    - `iconURL` <kbd>string</kbd> - Icon image URL
  - `developerURL` <kbd>string</kbd> - Developer's URL

**Example:**

```lua
local yagames = require("yagames.yagames")

yagames.features_gamesapi_get_all_games(function(self, err, result)
    if err then
        print("Failed to get games:", err)
    else
        print("Developer URL:", result.developerURL)
        print("Total games:", #result.games)
        
        for i, game in ipairs(result.games) do
            print(string.format("%d. %s (ID: %s)", i, game.title, game.appID))
            print("  URL:", game.url)
            print("  Cover:", game.coverURL)
            print("  Icon:", game.iconURL)
        end
    end
end)
```

#### `yagames.features_gamesapi_get_game_by_id(app_id, callback)`

Gets information about a specific game by its application ID.

**Parameters:**
- `app_id` <kbd>number</kbd> - Application identifier (as number)
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, result)`, where `result` is a table containing:
  - `isAvailable` <kbd>boolean</kbd> - Whether the game is available on the current platform and domain
  - `game` <kbd>table</kbd> - Game object (present only when `isAvailable` is `true`), containing:
    - `appID` <kbd>string</kbd> - Application identifier (as string)
    - `title` <kbd>string</kbd> - Game title
    - `url` <kbd>string</kbd> - Game URL
    - `coverURL` <kbd>string</kbd> - Cover image URL
    - `iconURL` <kbd>string</kbd> - Icon image URL

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Get appID from features_gamesapi_get_all_games() and convert to number
local game_id = 290493  -- Number, not string

yagames.features_gamesapi_get_game_by_id(game_id, function(self, err, result)
    if err then
        print("Failed to get game:", err)
    else
        if result.isAvailable then
            print("Game is available!")
            print("App ID:", result.game.appID)
            print("Title:", result.game.title)
            print("URL:", result.game.url)
            print("Cover:", result.game.coverURL)
            print("Icon:", result.game.iconURL)
            -- Show game link or navigate to it
        else
            print("Game is not available on this platform/domain")
        end
    end
end)
```

### 🌒 FEEDBACK [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-review)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.feedback.canReview()` | `yagames.feedback_can_review(callback)` |
| `ysdk.feedback.requestReview()` | `yagames.feedback_request_review(callback)` |

#### `yagames.feedback_can_review(callback)`

Checks if it's possible to request a review/rating from the user. The review dialog will not be shown if the user is not authorized or has already rated the game.

> [!IMPORTANT]
> Always call `feedback_can_review()` before `feedback_request_review()` to check if requesting a review is possible.

**Parameters:**
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, result)`, where `result` is a table containing:
  - `value` <kbd>boolean</kbd> - `true` if review can be requested, `false` otherwise
  - `reason` <kbd>string</kbd> (optional) - Reason why review cannot be requested (only present when `value` is `false`). Possible values:
    - `"NO_AUTH"` - User is not authorized
    - `"GAME_RATED"` - User has already rated the game
    - `"REVIEW_ALREADY_REQUESTED"` - Review request has already been sent, waiting for user action
    - `"REVIEW_WAS_REQUESTED"` - Review request was already sent, user has taken action (rated or closed dialog)
    - `"UNKNOWN"` - Request was not sent, error on Yandex side

**Example:**

```lua
local yagames = require("yagames.yagames")

yagames.feedback_can_review(function(self, err, result)
    if err then
        print("Failed to check review availability:", err)
    else
        if result.value then
            print("Review can be requested")
            -- Proceed to request review
        else
            print("Review cannot be requested. Reason:", result.reason or "unknown")
            -- Handle the reason:
            -- if result.reason == "NO_AUTH" then
            --     -- User needs to authorize first
            -- elseif result.reason == "GAME_RATED" then
            --     -- User already rated the game
            -- end
        end
    end
end)
```

#### `yagames.feedback_request_review(callback)`

Shows a popup dialog asking the user to rate the game and write a comment. The dialog appears at the moment of the request, covering the app background.

> [!WARNING]
> You can request a review only **once per session**. Always use `feedback_can_review()` before calling this method. If you ignore `feedback_can_review()`, the result may include an error: `"use canReview before requestReview"`.

**Parameters:**
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, result)`, where `result` is a table containing:
  - `feedbackSent` <kbd>boolean</kbd> - `true` if the user rated the game, `false` if the user closed the dialog

**Example:**

```lua
local yagames = require("yagames.yagames")

-- First, check if review can be requested
yagames.feedback_can_review(function(self, err, result)
    if err then
        print("Failed to check review availability:", err)
        return
    end
    
    if result.value then
        -- Review can be requested, proceed
        yagames.feedback_request_review(function(self, err, result)
            if err then
                print("Failed to request review:", err)
                -- Error might be: "use canReview before requestReview"
            else
                if result.feedbackSent then
                    print("User rated the game!")
                    -- Thank the user, grant bonus, etc.
                else
                    print("User closed the review dialog")
                    -- User didn't rate, maybe ask later
                end
            end
        end)
    else
        print("Cannot request review. Reason:", result.reason or "unknown")
    end
end)
```

### 🌒 CLIPBOARD [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-params)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.clipboard.writeText(text)` | `yagames.clipboard_write_text(text, [callback])` |

#### `yagames.clipboard_write_text(text, [callback])`

Writes a string to the clipboard. Allows users to copy game data (e.g., share codes, save data) to the clipboard.

**Parameters:**
- `text` <kbd>string</kbd> - Text to write to the clipboard
- `callback` <kbd>function</kbd> (optional) - Callback function with arguments `(self, err)`. Called when the operation completes.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Copy share code to clipboard
local share_code = "ABC123XYZ"
yagames.clipboard_write_text(share_code, function(self, err)
    if err then
        print("Failed to copy to clipboard:", err)
    else
        print("Copied to clipboard:", share_code)
        -- Show message to user: "Share code copied!"
    end
end)

-- Copy without callback
yagames.clipboard_write_text("Game data: " .. game_data_string)
```

### 🌒 DEVICE INFO [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-params)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.deviceInfo.type` | `yagames.device_info_type()` |
| `ysdk.deviceInfo.isDesktop()` | `yagames.device_info_is_desktop()` |
| `ysdk.deviceInfo.isMobile()` | `yagames.device_info_is_mobile()` |
| `ysdk.deviceInfo.isTablet()` | `yagames.device_info_is_tablet()` |
| `ysdk.deviceInfo.isTV()` | `yagames.device_info_is_tv()` |

#### `yagames.device_info_type()`

Returns the type of the user's device as a string.

**Returns:**
- <kbd>string</kbd> - Device type: `"desktop"` (computer), `"mobile"` (mobile device), `"tablet"` (tablet), or `"tv"` (TV)

**Example:**

```lua
local yagames = require("yagames.yagames")

local device_type = yagames.device_info_type()
print("Device type:", device_type)

if device_type == "mobile" then
    -- Adjust UI for mobile devices
    adjust_ui_for_mobile()
elseif device_type == "desktop" then
    -- Adjust UI for desktop
    adjust_ui_for_desktop()
end
```

#### `yagames.device_info_is_desktop()`

Checks if the user's device is a desktop computer.

**Returns:**
- <kbd>boolean</kbd> - `true` if desktop, `false` otherwise

**Example:**

```lua
local yagames = require("yagames.yagames")

if yagames.device_info_is_desktop() then
    -- Enable keyboard controls
    enable_keyboard_controls()
end
```

#### `yagames.device_info_is_mobile()`

Checks if the user's device is a mobile device.

**Returns:**
- <kbd>boolean</kbd> - `true` if mobile, `false` otherwise

**Example:**

```lua
local yagames = require("yagames.yagames")

if yagames.device_info_is_mobile() then
    -- Use touch controls
    enable_touch_controls()
    -- Adjust UI scale for smaller screens
    adjust_ui_scale(0.8)
end
```

#### `yagames.device_info_is_tablet()`

Checks if the user's device is a tablet.

**Returns:**
- <kbd>boolean</kbd> - `true` if tablet, `false` otherwise

**Example:**

```lua
local yagames = require("yagames.yagames")

if yagames.device_info_is_tablet() then
    -- Use tablet-optimized controls
    enable_tablet_controls()
end
```

#### `yagames.device_info_is_tv()`

Checks if the user's device is a TV.

**Returns:**
- <kbd>boolean</kbd> - `true` if TV, `false` otherwise

**Example:**

```lua
local yagames = require("yagames.yagames")

if yagames.device_info_is_tv() then
    -- Use TV remote controls
    enable_tv_controls()
    -- Increase UI size for TV viewing distance
    adjust_ui_scale(1.5)
end
```

### 🌒 ENVIRONMENT [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-environment)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.environment` | `yagames.environment()` |

#### `yagames.environment()`

Returns a table with game environment variables. Use this to get information about the environment in which the game is running, including app ID, language, domain, and optional payload parameter from the URL.

**Returns:**
- <kbd>table</kbd> - Table containing environment variables:
  - `app` <kbd>table</kbd> - Game data:
    - `id` <kbd>string</kbd> - Application identifier
  - `i18n` <kbd>table</kbd> - Internationalization data:
    - `lang` <kbd>string</kbd> - Interface language in ISO 639-1 format (e.g., `"ru"`, `"en"`, `"tr"`). Use this to determine the user's language in your game.
    - `tld` <kbd>string</kbd> - Top-level domain (e.g., `"com"` for international Yandex.Games domain, `"ru"` for Russian domain)
  - `payload` <kbd>string</kbd> (optional) - Value of the `payload` parameter from the game URL. For example, for `https://yandex.ru/games/app/123?payload=test`, the value `"test"` can be obtained via `environment.payload`.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Note: call yagames.init() before using yagames.environment() and any other yagames.* functions!

-- Get environment variables
local env = yagames.environment()

print("App ID:", env.app.id)
print("Language:", env.i18n.lang)
print("Domain:", env.i18n.tld)

-- Use language to set game localization
local user_lang = env.i18n.lang
if user_lang == "ru" then
    set_game_language("russian")
elseif user_lang == "en" then
    set_game_language("english")
elseif user_lang == "tr" then
    set_game_language("turkish")
else
    -- Default to English
    set_game_language("english")
end

-- Check for payload parameter (e.g., from deep link)
if env.payload and env.payload ~= "" then
    print("Payload:", env.payload)
    -- Process payload (e.g., load specific level, share code, etc.)
    process_payload(env.payload)
end
```

### 🌒 SCREEN [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-params)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.screen.fullscreen.status` | `yagames.screen_fullscreen_status()` |
| `ysdk.screen.fullscreen.request()` | `yagames.screen_fullscreen_request([callback])` |
| `ysdk.screen.fullscreen.exit()` | `yagames.screen_fullscreen_exit([callback])` |

> [!WARNING]
> Yandex.Games may automatically launch in fullscreen mode, but many browsers prohibit switching modes without a user command. Yandex.Games already has a fullscreen button in the top-right corner of the screen, so use these methods to handle fullscreen buttons directly in your game.

#### `yagames.screen_fullscreen_status()`

Gets the current fullscreen state.

**Returns:**
- <kbd>string</kbd> - Current fullscreen state: `"on"` or `"off"`

**Example:**

```lua
local yagames = require("yagames.yagames")

local status = yagames.screen_fullscreen_status()
if status == "on" then
    print("Game is in fullscreen mode")
else
    print("Game is in windowed mode")
end
```

#### `yagames.screen_fullscreen_request([callback])`

Requests entering fullscreen mode. The browser may require user interaction (e.g., button click) to allow fullscreen.

**Parameters:**
- `callback` <kbd>function</kbd> (optional) - Callback function with arguments `(self, err)`. Called when the operation completes.

**Example:**

```lua
local yagames = require("yagames.yagames")

function on_message(self, message_id, message)
    if message_id == hash("toggle_fullscreen") then
        local current_status = yagames.screen_fullscreen_status()
        if current_status == "off" then
            -- Request fullscreen
            yagames.screen_fullscreen_request(function(self, err)
                if err then
                    print("Failed to enter fullscreen:", err)
                    -- Browser may have blocked fullscreen (requires user gesture)
                else
                    print("Entered fullscreen mode")
                end
            end)
        end
    end
end
```

#### `yagames.screen_fullscreen_exit([callback])`

Requests exit from fullscreen mode.

**Parameters:**
- `callback` <kbd>function</kbd> (optional) - Callback function with arguments `(self, err)`. Called when the operation completes.

**Example:**

```lua
local yagames = require("yagames.yagames")

function on_message(self, message_id, message)
    if message_id == hash("toggle_fullscreen") then
        local current_status = yagames.screen_fullscreen_status()
        if current_status == "on" then
            -- Exit fullscreen
            yagames.screen_fullscreen_exit(function(self, err)
                if err then
                    print("Failed to exit fullscreen:", err)
                else
                    print("Exited fullscreen mode")
                end
            end)
        end
    end
end
```

### 🌒 SHORTCUTS [(docs)](https://yandex.ru/dev/games/doc/ru/sdk/sdk-shortcut)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.shortcut.canShowPrompt()` | `yagames.shortcut_can_show_prompt(callback)` |
| `ysdk.shortcut.showPrompt()` | `yagames.shortcut_show_prompt(callback)` |

#### `yagames.shortcut_can_show_prompt(callback)`

Checks if it's possible to show a prompt to add a shortcut to the desktop. Availability depends on the platform, browser internal rules, and Yandex.Games platform restrictions.

> [!IMPORTANT]
> Always check availability before showing the shortcut prompt dialog to the user.

**Parameters:**
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err, result)`, where `result` is a table containing:
  - `canShow` <kbd>boolean</kbd> - `true` if shortcut can be added, `false` otherwise

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Check if shortcut can be added
yagames.shortcut_can_show_prompt(function(self, err, result)
    if err then
        print("Failed to check shortcut availability:", err)
    else
        if result.canShow then
            print("Shortcut can be added")
            -- Show button to add shortcut
            show_add_shortcut_button()
        else
            print("Shortcut cannot be added on this platform/browser")
            -- Hide button or show alternative
        end
    end
end)
```

#### `yagames.shortcut_show_prompt(callback)`

Shows a native dialog prompting the user to add a shortcut to the desktop. The shortcut is a link to the game.

> [!NOTE]
> On the first call, a shortcut to the Yandex.Games catalog is created. If it already exists, a shortcut with a link to the game itself will be created.

**Parameters:**
- `callback` <kbd>function</kbd> (optional) - Callback function with arguments `(self, err, result)`, where `result` is a table containing:
  - `outcome` <kbd>string</kbd> - Result of the operation. Possible values:
    - `"accepted"` - User accepted and added the shortcut
    - Other values indicate the user dismissed the dialog or an error occurred

**Example:**

```lua
local yagames = require("yagames.yagames")

-- First check availability
yagames.shortcut_can_show_prompt(function(self, err, result)
    if err then
        print("Failed to check shortcut availability:", err)
        return
    end
    
    if result.canShow then
        -- Show the shortcut prompt dialog
        yagames.shortcut_show_prompt(function(self, err, result)
            if err then
                print("Failed to show shortcut prompt:", err)
            else
                if result.outcome == "accepted" then
                    print("User added shortcut to desktop!")
                    -- Grant reward for adding shortcut
                    grant_reward_for_shortcut()
                else
                    print("User dismissed shortcut dialog")
                end
            end
        end)
    else
        print("Shortcut cannot be added on this platform")
    end
end)
```

### 🌒 SAFE STORAGE [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-player#progress-loss)

> [!NOTE]
> `key` and `value` should be valid UTF-8 strings. Storing strings with zero bytes aren't supported.

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.getStorage()` | `yagames.storage_init(callback)` |
| `safeStorage.getItem(key)` | `yagames.storage_get_item(key)` |
| `safeStorage.setItem(key, value)` | `yagames.storage_set_item(key, value)` |
| `safeStorage.removeItem(key)` | `yagames.storage_remove_item(key)` |
| `safeStorage.clear()` | `yagames.storage_clear()` |
| `safeStorage.key(n)` | `yagames.storage_key(n)` |
| `safeStorage.length` | `yagames.storage_length()` |

#### `yagames.storage_init(callback)`

Initializes the Safe Storage subsystem. Safe Storage provides a secure way to store data that persists across game sessions and is protected from loss.

> [!IMPORTANT]
> You must call `storage_init()` before using any other storage methods. All other storage methods will throw an error if storage is not initialized.

**Parameters:**
- `callback` <kbd>function</kbd> - Callback function with arguments `(self, err)`. Called when initialization completes.

**Example:**

```lua
local yagames = require("yagames.yagames")

yagames.storage_init(function(self, err)
    if err then
        print("Failed to initialize Safe Storage:", err)
    else
        print("Safe Storage initialized")
        -- Now you can use all storage methods
        yagames.storage_set_item("player_name", "Player1")
    end
end)
```

#### `yagames.storage_get_item(key)`

Gets the value stored under the specified key.

**Parameters:**
- `key` <kbd>string</kbd> - The key to retrieve

**Returns:**
- <kbd>string</kbd> or <kbd>nil</kbd> - The value associated with the key, or `nil` if the key doesn't exist

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Get stored value
local player_name = yagames.storage_get_item("player_name")
if player_name then
    print("Player name:", player_name)
else
    print("Player name not set")
end
```

#### `yagames.storage_set_item(key, value)`

Stores a value under the specified key. If the key already exists, its value will be updated.

**Parameters:**
- `key` <kbd>string</kbd> - The key to store the value under
- `value` <kbd>string</kbd> - The value to store (must be valid UTF-8, no zero bytes)

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Store player data
yagames.storage_set_item("player_name", "Player1")
yagames.storage_set_item("high_score", "1000")
yagames.storage_set_item("level", "5")

-- Update existing value
yagames.storage_set_item("high_score", "1500")
```

#### `yagames.storage_remove_item(key)`

Removes the key-value pair from the storage.

**Parameters:**
- `key` <kbd>string</kbd> - The key to remove

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Remove a specific key
yagames.storage_remove_item("player_name")

-- Check if it was removed
if yagames.storage_get_item("player_name") == nil then
    print("Key removed successfully")
end
```

#### `yagames.storage_clear()`

Removes all key-value pairs from the storage.

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Clear all storage
yagames.storage_clear()

-- Verify storage is empty
if yagames.storage_length() == 0 then
    print("Storage cleared")
end
```

#### `yagames.storage_key(n)`

Returns the name of the nth key in the storage.

> [!NOTE]
> The index `n` is **zero-based** (0 = first key, 1 = second key, etc.).

**Parameters:**
- `n` <kbd>number</kbd> - Zero-based index of the key

**Returns:**
- <kbd>string</kbd> or <kbd>nil</kbd> - The name of the nth key, or `nil` if the index is out of bounds

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Store some data
yagames.storage_set_item("key_1", "value_1")
yagames.storage_set_item("key_2", "value_2")
yagames.storage_set_item("key_3", "value_3")

-- Iterate through all keys
local length = yagames.storage_length()
for i = 0, length - 1 do
    local key = yagames.storage_key(i)
    if key then
        local value = yagames.storage_get_item(key)
        print(string.format("Key[%d]: %s = %s", i, key, value))
    end
end
```

#### `yagames.storage_length()`

Returns the number of key-value pairs stored in the storage.

**Returns:**
- <kbd>number</kbd> - The number of items in the storage

**Example:**

```lua
local yagames = require("yagames.yagames")

-- Store some data
yagames.storage_set_item("key1", "value1")
yagames.storage_set_item("key2", "value2")

-- Get storage size
local count = yagames.storage_length()
print("Storage contains", count, "items")  -- Output: Storage contains 2 items
```

### 🌒 REMOTE CONFIG [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-config)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.getFlags(options)` | `yagames.flags_get(options, callback)`<br>Options is optional. The callback result is a table like `{ flagName = "value" }` |

### 🌒 EVENTS [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-events)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.on(eventName, listener)` | `yagames.event_on(event_name, listener)`<br>`event_name` is a string: `game_api_pause`, `game_api_resume`, `HISTORY_BACK`, `multiplayer-sessions-transaction`, `multiplayer-sessions-finish` etc. |
| `ysdk.off(eventName, listener)` | `yagames.event_off(event_name, listener)`<br>`event_name` is a string: `game_api_pause`, etc. |
| `ysdk.dispatchEvent(eventName)` | `yagames.event_dispatch(event_name)`<br>`event_name` is a string: `EXIT` etc. |

### 🌒 MULTIPLAYER SESSIONS [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-multiplayer-sessions)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.multiplayer.sessions.init(options)` | `yagames.multiplayer_sessions_init(options, callback)`<br>The argument `options` is a Lua table `{ count = number, isEventBased = boolean, maxOpponentTurnTime = number, meta = { key = { min = number, max = number } } }`. See [the example](https://github.com/indiesoftby/defold-yagames/blob/master/example/ysdkdebug/pg_multiplayer.lua). |
| `ysdk.multiplayer.sessions.commit(data)` | `yagames.multiplayer_sessions_commit(data)`<br>The argument `data` is a Lua table, i.e. `{ key = value }`. |
| `ysdk.multiplayer.sessions.push(data)` | `yagames.multiplayer_sessions_push(data)`<br>The argument `data` is a Lua table, i.e. `{ key = value }`. |

### 🌒 SITELOCK [(docs)](#sitelock)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
|  | `sitelock.add_domain(domain)` |
|  | `sitelock.verify_domain()` |
|  | `sitelock.get_current_domain()` |
|  | `sitelock.is_release_build()` |

## Sitelock

It's a good idea to protect your HTML5 game from simple copy-pasting to another website. The YaGames extension has Sitelock API for that purpose. It's simple, but it's better than nothing.

By default, it checks hostnames `yandex.net` (CDN of the Yandex.Games) and `localhost` (for local debugging).

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


## Credits

Artsiom Trubchyk ([@aglitchman](https://github.com/aglitchman)) is the current YaGames owner within Indiesoft and is responsible for the open source repository.

This project uses the source code of [JsToDef](https://github.com/AGulev/jstodef).

### License

MIT license.
