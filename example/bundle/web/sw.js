// 1. Put here the name of your game:
const cachePrefix = "yagames-example";

// 2. Increment the version every time you publish your game!
const cacheName = cachePrefix + "-v1";

const cacheList = [
    "https://yandex.ru/games/sdk/v2",

    // 3. Add ALL your game files to the list:
    "index.html",
    "dmloader.js",
    "yagames.wasm",
    "yagames_wasm.js",
    "yagames_asmjs.js",
    "archive/archive_files.json",
    "archive/game.arcd0",
    "archive/game.arci0",
    "archive/game.dmanifest0",
    "archive/game.projectc0",
    "archive/game.public.der0",
];

// Installation of the service worker
self.addEventListener("install", function (event) {
    event.waitUntil(
        caches.open(cacheName).then((cache) => {
            return cache.addAll(cacheList);
        })
    );
});

// Deletion of old cache
self.addEventListener("activate", function (event) {
    console.assert(typeof cacheName === "string");
    console.assert(typeof cachePrefix === "string");

    event.waitUntil(
        caches.keys().then((keyList) => {
            return Promise.all(
                keyList.map((key) => {
                    if (key.indexOf(cachePrefix) === 0 && key !== cacheName) {
                        return caches.delete(key);
                    }
                })
            );
        })
    );
});

// Handling of data stored in the device cache with exceptions
self.addEventListener("fetch", function (event) {
    if (
        event.request.method !== "GET" ||
        event.request.url.indexOf("http://") === 0 ||
        event.request.url.indexOf("an.yandex.ru") !== -1
    ) {
        return;
    }

    event.respondWith(
        caches.match(event.request, { ignoreSearch: true }).then(function (response) {
            return response || fetch(event.request);
        })
    );
});
