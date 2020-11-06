--- YaGames - Yandex Games for Defold.
-- @module yacontext

local helper = require("yagames.helpers.helper")

local M = {}

-- <!-- Yandex.RTB R-A-663806-4 -->
-- <div id="yandex_rtb_R-A-663806-4"></div>
-- <script type="text/javascript">
--     (function(w, d, n, s, t) {
--         w[n] = w[n] || [];
--         w[n].push(function() {
--             Ya.Context.AdvManager.render({
--                 blockId: "R-A-663806-4",
--                 renderTo: "yandex_rtb_R-A-663806-4",
--                 async: true
--             });
--         });
--         t = d.getElementsByTagName("script")[0];
--         s = d.createElement("script");
--         s.type = "text/javascript";
--         s.src = "//an.yandex.ru/system/context.js";
--         s.async = true;
--         t.parentNode.insertBefore(s, t);
--     })(this, this.document, "yandexContextAsyncCallbacks");
-- </script>

return M