> [!IMPORTANT]
> Deprecated - use the official Sticky Banners API from Yandex.

## Banner Ads

You can additionally monetize your game using Yandex Advertising Network *Real-Time Bidding* ad blocks. RTB block is rendered into HTML div block and placed over your game canvas.

The official documentation:
* [📚 Add a configurable RTB block to a game](https://yandex.ru/dev/games/doc/dg/console/add-custom-rtb-block.html?lang=en).
* [📚 Real-Time Bidding blocks](https://yandex.ru/support/partner2/web/products-rtb/about.html?lang=en).

### Creating RTB blocks

Create an RTB block in [the Yandex Advertising Network interface](https://partner2.yandex.ru/v2/context/rtb/) and copy **RTB id** of the block:

![RTB id](rtb_copy_id.png)

The ad block will be displayed within 30 minutes after saving the code and placing it on the game page. 

### Styling RTB blocks

Usually, developers put banners to the sides of a page. You can apply any CSS styles to the `div` block that will contain RTB ad via the `yagames.banner_create`'s `options` argument.

The following examples require to set `width` and `height` to `100%` for the `<body>`. You should append these CSS styles to your Defold's HTML template or CSS file:
```html
<style>
body {
    height: 100%;
    width: 100%;
}
</style>
```

Left vertical banner. Width is 350px:
```css
background: #d2d2d2; width: 350px; left: 0; align-items: center; display: flex; height: 100%; justify-content: center; position: absolute;
```

Right vertical banner ([screenshot](https://gist.github.com/aglitchman/a006968b838766279834ab65c049cfe4/raw/11b08fdbc392d4013bb6756ee57de382aa5a5b08/Screenshot%2520RIGHT.png)). Width is 350px:
```css
background: #d2d2d2; width: 350px; right: 0; align-items: center; display: flex; height: 100%; justify-content: center; position: absolute;
```

Horizontal banner at the top. Height is 250px:
```css
background: #d2d2d2; height: 250px; top: 0; align-items: center; display: flex; justify-content: center; position: absolute; width: 100%;
```

Horizontal banner at the bottom ([screenshot](https://gist.github.com/aglitchman/a006968b838766279834ab65c049cfe4/raw/11b08fdbc392d4013bb6756ee57de382aa5a5b08/Screenshot%2520BOTTOM.png)). Height is 250px:
```css
background: #d2d2d2; height: 250px; bottom: 0; align-items: center; display: flex; justify-content: center; position: absolute; width: 100%;
```

Note: `background: #d2d2d2;` - it's the background color for visual debugging. For production, you should remove it.

## Banner Ads Lua API

### yagames.banner_init(callback)
Loads Yandex Advertising Network SDK and calls the callback.

_PARAMETERS_
* __callback__ <kbd>function</kbd> - Function to call when the Yandex Advertising Network SDK has initialized.

The `callback` function is expected to accept the following values:

* __self__ <kbd>userdata</kbd> - Script self reference.
* __error__ <kbd>string</kbd> - Error code if something went wrong.

### yagames.banner_create(rtb_id, options, [callback])
Creates a DOM element (`<div></div>`) with `style="position: absolute"`, adds it to the end of the `<body>` (or to the end of the element specified by `append_to_id`), applies your CSS styles on it and renders an advertisement into the element.

_PARAMETERS_
* __rtb_id__ <kbd>string</kbd> - The unique RTB block ID. The block ID consists of a product ID (`R-A`), platform ID and the block's serial number.
* __options__ <kbd>table</kbd> - The table with key-value pairs.
* __callback__ <kbd>function</kbd> - The callback function that is invoked after ad rendering.

The `options` table can have these key-value pairs:
* __stat_id__ <kbd>integer</kbd> - The sample ID. A number between 1 and 1000000000. This will allow you to view group statistics for that block.
* __css_styles__ <kbd>string</kbd> - Sets inline CSS styles of the `<div></div>` element.
* __css_class__ <kbd>string</kbd> - Sets the value of the `class` attribute of the `<div></div>` element.
* __display__ <kbd>string</kbd> - The `display` property allows to show or hide the element. If you set `display` = `none`, it hides the entire element. Use `block` to show it back.
* __append_to_id__ <kbd>string</kbd> - The parent element ID if you want to add the `div` to the list of children of a specific parent node.

The `callback` function allows you to obtain information about whether the ad has been rendered (whether the ad was successfully selected when requested from the RTB system) and which particular ad was shown. The `callback` function is expected to accept the following values:

* __self__ <kbd>userdata</kbd> - Script self reference.
* __error__ <kbd>string</kbd> - Error code if something went wrong.
* __data__ <kbd>table</kbd> - The function obtains the `data.product` parameter with one of two values: `direct` - Yandex.Direct ads were shown in an RTB ad block, `rtb` - A media ad was shown in an RTB ad block.

If there were no suitable product listings at the auction to show your ad next to, then you can show your ad in the block. In this situation the `callback` function returns the error `No ads available.`.

### yagames.banner_destroy(rtb_id)
Removes the DOM element.

_PARAMETERS_
* __rtb_id__ <kbd>string</kbd> - The unique RTB block ID. The block ID consists of a product ID (`R-A`), platform ID and the block's serial number.

### yagames.banner_refresh(rtb_id, [callback])
Requests SDK to render new advertisement.

_PARAMETERS_
* __rtb_id__ <kbd>string</kbd> - The unique RTB block ID. The block ID consists of a product ID (`R-A`), platform ID and the block's serial number.
* __callback__ <kbd>function</kbd> - The callback function that is invoked after ad rendering.

The `callback` function is described in the `yagames.banner_create` section above.

### yagames.banner_set(rtb_id, property, value)
Sets a named property of the specified banner.

_PARAMETERS_
* __rtb_id__ <kbd>string</kbd> - The unique RTB block ID. The block ID consists of a product ID (`R-A`), platform ID and the block's serial number.
* __property__ <kbd>string</kbd> - Name of the property to set.
* __value__ <kbd>string</kbd> - The value to set.

_PROPERTIES_:
* __stat_id__ <kbd>integer</kbd> - The sample ID. A number between 1 and 1000000000. This will allow you to view group statistics for that block.
* __css_styles__ <kbd>string</kbd> - Sets inline CSS styles of the `<div></div>` element.
* __css_class__ <kbd>string</kbd> - Sets the value of the `class` attribute of the `<div></div>` element.
* __display__ <kbd>string</kbd> - The `display` property allows to show or hide the element. If you set `display` = `none`, it hides the entire element. Use `block` to show it back.
