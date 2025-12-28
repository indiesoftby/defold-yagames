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
| `lb.getLeaderboardPlayerEntry(leaderboardName)` | `yagames.leaderboards_get_player_entry(leaderboard_name, [options], callback)`<br>If the player doesn't have any score, you get the error `FetchError: Player is not present in leaderboard`.<br>The argument `options` is an optional Lua table `{ getAvatarSrc = "size", getAvatarSrcSet = "size" }`, where `size` (string) can be `small`, `medium`, `large`. |
| `lb.getLeaderboardEntries(leaderboardName, options)` | `yagames.leaderboards_get_entries(leaderboard_name, [options], callback)`<br>The argument `options` is an optional Lua table `{ includeUser = boolean, quantityAround = number, quantityTop = number, getAvatarSrc = "size", getAvatarSrcSet = "size" }`, where `size` (string) can be `small`, `medium`, `large`. |
| `lb.setLeaderboardScore(leaderboardName, score, extraData)` | `yagames.leaderboards_set_score(leaderboard_name, score, [extra_data], [callback])` |

### 🌒 FEATURES [(docs)](https://yandex.com/dev/games/doc/en/sdk/sdk-game-events)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.features.LoadingAPI?.ready()` | `yagames.features_loadingapi_ready()` |
| `ysdk.features.GameplayAPI?.start()` | `yagames.features_gameplayapi_start()` |
| `ysdk.features.GameplayAPI?.stop()` | `yagames.features_gameplayapi_stop()` |
| `ysdk.features.GamesAPI?.getAllGames()` | `yagames.features_gamesapi_get_all_games(callback)`<br>The callback result is a table `{ games = { ... }, developerURL = "string" }` |
| `ysdk.features.GamesAPI?.getGameByID(appID)` | `yagames.features_gamesapi_get_game_by_id(app_id, callback)`<br>The callback result is a table `{ isAvailable = true/false, game = { appID = "string", title = "string", url = "string", coverURL = "string", iconURL = "string" } }` |

### 🌒 FEEDBACK [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-review)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.feedback.canReview()` | `yagames.feedback_can_review(callback)`<br>The callback result is a table `{ value = true/false, reason = "string" }` |
| `ysdk.feedback.requestReview()` | `yagames.feedback_request_review(callback)`<br>The callback result is a table `{ feedbackSent = true/false }` |

### 🌒 CLIPBOARD [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-params)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.clipboard.writeText(text)` | `yagames.clipboard_write_text(text, [callback])` |

### 🌒 DEVICE INFO [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-params)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.deviceInfo.type` | `yagames.device_info_type()`<br>Returns `"desktop"`, `"mobile"`, `"tablet"` or `"tv"` |
| `ysdk.deviceInfo.isDesktop()` | `yagames.device_info_is_desktop()` |
| `ysdk.deviceInfo.isMobile()` | `yagames.device_info_is_mobile()` |
| `ysdk.deviceInfo.isTablet()` | `yagames.device_info_is_tablet()` |
| `ysdk.deviceInfo.isTV()` | `yagames.device_info_is_tv()` |

### 🌒 ENVIRONMENT [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-environment)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.environment` | `yagames.environment()`<br>Returns Lua table `{ app = { id = ... }, ... }` |

### 🌒 SCREEN [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-params)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.screen.fullscreen.status` | `yagames.screen_fullscreen_status()`<br>Returns `"on"` or `"off"` |
| `ysdk.screen.fullscreen.request()` | `yagames.screen_fullscreen_request([callback])` |
| `ysdk.screen.fullscreen.exit()` | `yagames.screen_fullscreen_exit([callback])` |

### 🌒 SHORTCUTS [(docs)](https://yandex.ru/dev/games/doc/ru/sdk/sdk-shortcut)

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.shortcut.canShowPrompt()` | `yagames.shortcut_can_show_prompt(callback)`<br>The callback result is a table `{ canShow = boolean }` |
| `ysdk.shortcut.showPrompt()` | `yagames.shortcut_show_prompt(callback)`<br>The callback result is a table `{ outcome = "string" }` |

### 🌒 SAFE STORAGE [(docs)](https://yandex.ru/dev/games/doc/en/sdk/sdk-player#progress-loss)

*Note: `key` and `value` should be valid UTF-8 strings. Storing strings with zero bytes aren't supported.*

| Yandex.Games JS SDK | YaGames Lua API |
| ------------------- | --------------- |
| `ysdk.getStorage()` | `yagames.storage_init(callback)` |
| `safeStorage.getItem(key)` | `yagames.storage_get_item(key)`<br>Returns that key's value or `nil`. |
| `safeStorage.setItem(key, value)` | `yagames.storage_set_item(key, value)`<br>Adds that key to the storage, or update that key's value if it already exists. |
| `safeStorage.removeItem(key)` | `yagames.storage_remove_item(key)`<br>Removes that key from the storage. |
| `safeStorage.clear()` | `yagames.storage_clear()`<br>Empties all keys out of the storage. |
| `safeStorage.key(n)` | `yagames.storage_key(n)`<br>Returns the name of the nth key in the storage or `nil`. *Note: the n index is zero-based.* |
| `safeStorage.length` | `yagames.storage_length()`<br>Returns the number of data items stored in the storage. |

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
