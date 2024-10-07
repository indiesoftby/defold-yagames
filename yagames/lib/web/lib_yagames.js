var LibYaGamesPrivate = {
    $YaGamesPrivate: {
        _ysdk: null,
        _lb: null,
        _payments: null,
        _player: null,
        _context: null,

        _callback_object: null,
        _callback_string: null,
        _callback_empty: null,
        _callback_number: null,
        _callback_bool: null,

        toErrStr: function (err) {
            return err + "";
        },

        parseJson: function (json) {
            try {
                return JSON.parse(json);
            } catch (e) {
                return null;
            }
        },

        send: function (cb_id, message_id, message) {
            if (YaGamesPrivate._callback_object) {
                // 0 and 1 are reserved IDs
                if (cb_id == 0 && message_id == "init") {
                    YaGamesPrivate._ysdk = message;
                    message = undefined;
                }

                var cmsg_id = 0;
                if (typeof message_id === "string") {
                    cmsg_id = stringToNewUTF8(message_id);
                }
                switch (typeof message) {
                    case "undefined":
                        {{{ makeDynCall("vii", "YaGamesPrivate._callback_empty") }}}(cb_id, cmsg_id);
                        break;
                    case "number":
                        {{{ makeDynCall("viif", "YaGamesPrivate._callback_number") }}}(cb_id, cmsg_id, message);
                        break;
                    case "string":
                        var msg = stringToNewUTF8(message);
                        {{{ makeDynCall("viii", "YaGamesPrivate._callback_string") }}}(cb_id, cmsg_id, msg, lengthBytesUTF8(message));
                        _free(msg);
                        break;
                    case "object":
                        var obj_str = JSON.stringify(message);
                        var msg = stringToNewUTF8(obj_str);
                        {{{ makeDynCall("viii", "YaGamesPrivate._callback_object") }}}(cb_id, cmsg_id, msg, lengthBytesUTF8(obj_str));
                        _free(msg);
                        break;
                    case "boolean":
                        var msg = message ? 1 : 0;
                        {{{ makeDynCall("viii", "YaGamesPrivate._callback_bool") }}}(cb_id, cmsg_id, msg);
                        break;
                    default:
                        console.warn("Unsupported message format: " + typeof message);
                }
                if (cmsg_id) {
                    _free(cmsg_id);
                }
            } else {
                // console.warn("You didn't set callback for YaGamesPrivate");
                if (typeof YaGamesPrivate_MsgQueue !== "undefined") {
                    YaGamesPrivate_MsgQueue.push([cb_id, message_id, message]);
                }
            }
        },

        delaySend: function (cb_id, message_id, message) {
            setTimeout(() => {
                YaGamesPrivate.send(cb_id, message_id, message);
            }, 0);
        },
    },

    YaGamesPrivate_RegisterCallbacks: function (
        callback_object,
        callback_string,
        callback_empty,
        callback_number,
        callback_bool
    ) {
        var self = YaGamesPrivate;

        self._callback_object = callback_object;
        self._callback_string = callback_string;
        self._callback_empty = callback_empty;
        self._callback_number = callback_number;
        self._callback_bool = callback_bool;

        while (typeof YaGamesPrivate_MsgQueue !== "undefined" && YaGamesPrivate_MsgQueue.length) {
            var m = YaGamesPrivate_MsgQueue.shift();
            self.send(m[0], m[1], m[2]);
        }
    },

    YaGamesPrivate_RemoveCallbacks: function () {
        var self = YaGamesPrivate;

        self._callback_object = null;
        self._callback_string = null;
        self._callback_empty = null;
        self._callback_number = null;
        self._callback_bool = null;
    },

    YaGamesPrivate_IsAvailableMethod: function (cb_id, cname) {
        var self = YaGamesPrivate;
        try {
            var name = UTF8ToString(cname);
            self._ysdk
                .isAvailableMethod(name)
                .then((result) => {
                    self.send(cb_id, null, result);
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_ServerTime: function () {
        return YaGamesPrivate._ysdk.serverTime() || 0; // the return value can be null?..
    },

    YaGamesPrivate_Adv_ShowFullscreenAdv: function (cb_id) {
        var self = YaGamesPrivate;
        try {
            self._ysdk.adv.showFullscreenAdv({
                callbacks: {
                    onClose: (wasShown) => {
                        self.send(cb_id, "close", wasShown);
                    },
                    onOpen: () => {
                        self.send(cb_id, "open");
                    },
                    onOffline: () => {
                        self.send(cb_id, "offline");
                    },
                    onError: (err) => {
                        self.send(cb_id, "error", self.toErrStr(err));
                    },
                },
            });
        } catch (err) {
            self.delaySend(cb_id, "error", self.toErrStr(err));
            self.delaySend(cb_id, "close", false);
        }
    },

    YaGamesPrivate_Adv_ShowRewardedVideo: function (cb_id) {
        var self = YaGamesPrivate;
        try {
            self._ysdk.adv.showRewardedVideo({
                callbacks: {
                    onOpen: () => {
                        self.send(cb_id, "open");
                    },
                    onRewarded: () => {
                        self.send(cb_id, "rewarded");
                    },
                    onClose: () => {
                        self.send(cb_id, "close");
                    },
                    onError: (err) => {
                        self.send(cb_id, "error", self.toErrStr(err));
                    },
                },
            });
        } catch (err) {
            self.delaySend(cb_id, "error", self.toErrStr(err));
            self.delaySend(cb_id, "close");
        }
    },

    YaGamesPrivate_Adv_GetBannerAdvStatus: function (cb_id) {
        var self = YaGamesPrivate;
        try {
            self._ysdk
                .adv.getBannerAdvStatus()
                .then((result) => {
                    self.send(cb_id, null, JSON.stringify(result));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Adv_ShowBannerAdv: function (cb_id) {
        var self = YaGamesPrivate;
        try {
            self._ysdk
                .adv.showBannerAdv()
                .then((result) => {
                    self.send(cb_id, null, JSON.stringify(result));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Adv_HideBannerAdv: function (cb_id) {
        var self = YaGamesPrivate;
        try {
            self._ysdk
                .adv.hideBannerAdv()
                .then((result) => {
                    self.send(cb_id, null, JSON.stringify(result));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_OpenAuthDialog: function (cb_id) {
        var self = YaGamesPrivate;
        try {
            self._ysdk.auth
                .openAuthDialog()
                .then(() => {
                    self.send(cb_id);
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Clipboard_WriteText: function (cb_id, ctext) {
        var self = YaGamesPrivate;
        try {
            var text = UTF8ToString(ctext);
            self._ysdk
                .clipboard.writeText(text)
                .then(() => {
                    self.send(cb_id, null);
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_DeviceInfo_Type: function () {
        var self = YaGamesPrivate;
        var ctype = stringToNewUTF8(self._ysdk.deviceInfo.type || "null"); // the return value can be undefined/null if you run the game outside of the YSDK system.
        return ctype;
    },

    YaGamesPrivate_DeviceInfo_IsDesktop: function () {
        return YaGamesPrivate._ysdk.deviceInfo.isDesktop();
    },

    YaGamesPrivate_DeviceInfo_IsMobile: function () {
        return YaGamesPrivate._ysdk.deviceInfo.isMobile();
    },

    YaGamesPrivate_DeviceInfo_IsTablet: function () {
        return YaGamesPrivate._ysdk.deviceInfo.isTablet();
    },

    YaGamesPrivate_DeviceInfo_IsTV: function () {
        return YaGamesPrivate._ysdk.deviceInfo.isTV();
    },

    YaGamesPrivate_Environment: function () {
        var self = YaGamesPrivate;
        var str = JSON.stringify(self._ysdk.environment);
        var cstr = stringToNewUTF8(str);
        return cstr;
    },

    YaGamesPrivate_Features_LoadingAPI_Ready: function () {
        var self = YaGamesPrivate;
        try {
            self._ysdk.features.LoadingAPI.ready();
        } catch (err) {
            console.warn(err);
        }
    },

    YaGamesPrivate_Features_GameplayAPI_Start: function () {
        var self = YaGamesPrivate;
        try {
            self._ysdk.features.GameplayAPI.start();
        } catch (err) {
            console.warn(err);
        }
    },

    YaGamesPrivate_Features_GameplayAPI_Stop: function () {
        var self = YaGamesPrivate;
        try {
            self._ysdk.features.GameplayAPI.stop();
        } catch (err) {
            console.warn(err);
        }
    },

    YaGamesPrivate_Features_GamesAPI_GetAllGames: function (cb_id) {
        var self = YaGamesPrivate;
        try {
            self._ysdk
                .features.GamesAPI.getAllGames()
                .then((result) => {
                    self.send(cb_id, null, JSON.stringify(result));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Features_GamesAPI_GetGameByID: function (cb_id, game_id) {
        var self = YaGamesPrivate;
        try {
            self._ysdk
                .features.GamesAPI.getGameByID(game_id)
                .then((result) => {
                    self.send(cb_id, null, JSON.stringify(result));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Feedback_CanReview: function (cb_id) {
        var self = YaGamesPrivate;
        try {
            self._ysdk
                .feedback.canReview()
                .then((result) => {
                    self.send(cb_id, null, JSON.stringify(result));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Feedback_RequestReview: function (cb_id) {
        var self = YaGamesPrivate;
        try {
            self._ysdk
                .feedback.requestReview()
                .then((result) => {
                    self.send(cb_id, null, JSON.stringify(result));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_GetLeaderboards: function (cb_id) {
        var self = YaGamesPrivate;
        try {
            self._ysdk
                .getLeaderboards()
                .then((lb) => {
                    self._lb = lb;
                    self.send(cb_id);
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Leaderboards_GetDescription: function (cb_id, cleaderboard_name) {
        var self = YaGamesPrivate;
        try {
            var leaderboard_name = UTF8ToString(cleaderboard_name);
            self._lb
                .getLeaderboardDescription(leaderboard_name)
                .then((result) => {
                    self.send(cb_id, null, JSON.stringify(result));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Leaderboards_GetPlayerEntry: function (cb_id, cleaderboard_name, coptions) {
        var self = YaGamesPrivate;
        try {
            var leaderboard_name = UTF8ToString(cleaderboard_name);
            var options = self.parseJson(UTF8ToString(coptions));
            self._lb
                .getLeaderboardPlayerEntry(leaderboard_name)
                .then((result) => {
                    if (options.getAvatarSrc && result.player) {
                        result.player.getAvatarSrc = result.player.getAvatarSrc(options.getAvatarSrc);
                    }
                    if (options.getAvatarSrcSet && result.player) {
                        result.player.getAvatarSrcSet = result.player.getAvatarSrcSet(options.getAvatarSrcSet);
                    }
                    self.send(cb_id, null, JSON.stringify(result));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Leaderboards_GetEntries: function (cb_id, cleaderboard_name, coptions) {
        var self = YaGamesPrivate;
        try {
            var leaderboard_name = UTF8ToString(cleaderboard_name);
            var options = self.parseJson(UTF8ToString(coptions));
            self._lb
                .getLeaderboardEntries(leaderboard_name, options)
                .then((result) => {
                    if (result.entries) {
                        for (var i = 0; i < result.entries.length; i++) {
                            var entry = result.entries[i];
                            if (options.getAvatarSrc) {
                                entry.player.getAvatarSrc = entry.player.getAvatarSrc(options.getAvatarSrc);
                            }
                            if (options.getAvatarSrcSet) {
                                entry.player.getAvatarSrcSet = entry.player.getAvatarSrcSet(options.getAvatarSrcSet);
                            }
                        }
                    }
                    self.send(cb_id, null, JSON.stringify(result));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Leaderboards_SetScore: function (cb_id, cleaderboard_name, score, cextra_data) {
        var self = YaGamesPrivate;
        try {
            var leaderboard_name = UTF8ToString(cleaderboard_name);
            var promise;
            if (cextra_data === 0) {
                promise = self._lb.setLeaderboardScore(leaderboard_name, score);
            } else {
                var extra_data = UTF8ToString(cextra_data);
                promise = self._lb.setLeaderboardScore(leaderboard_name, score, extra_data);
            }

            promise
                .then((result) => {
                    self.send(cb_id, null, JSON.stringify(result));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_GetPayments: function (cb_id, coptions) {
        var self = YaGamesPrivate;
        try {
            var options = self.parseJson(UTF8ToString(coptions));
            self._ysdk
                .getPayments(options)
                .then((payments) => {
                    self._payments = payments;
                    self.send(cb_id);
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Payments_Purchase: function (cb_id, coptions) {
        var self = YaGamesPrivate;
        try {
            var options = self.parseJson(UTF8ToString(coptions));
            self._payments
                .purchase(options)
                .then((p) => {
                    var tmp = {
                        developerPayload: p.developerPayload,
                        productID: p.productID,
                        purchaseTime: p.purchaseTime,
                        purchaseToken: p.purchaseToken,
                        signature: p.signature,
                    };
                    self.send(cb_id, null, JSON.stringify(tmp));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Payments_GetPurchases: function (cb_id) {
        var self = YaGamesPrivate;
        try {
            self._payments
                .getPurchases()
                .then((purchases) => {
                    var tmp = {
                        purchases: [],
                        signature: purchases.signature,
                    };
                    for (var i = 0; i < purchases.length; i++) {
                        var p = purchases[i];
                        tmp.purchases.push({
                            developerPayload: p.developerPayload,
                            productID: p.productID,
                            purchaseTime: p.purchaseTime,
                            purchaseToken: p.purchaseToken,
                        });
                    }

                    self.send(cb_id, null, JSON.stringify(tmp));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Payments_GetCatalog: function (cb_id, coptions) {
        var self = YaGamesPrivate;
        try {
            var options = coptions === 0 ? {} : self.parseJson(UTF8ToString(coptions));
            self._payments
                .getCatalog()
                .then((products) => {
                    if (typeof options.getPriceCurrencyImage === "string") {
                        const newResults = [];
                        for (const product of products) {
                            const result = JSON.parse(JSON.stringify(product));
                            result.getPriceCurrencyImage = product.getPriceCurrencyImage(options.getPriceCurrencyImage);
                            newResults.push(result);
                        }
                        products = newResults;
                    }
                    self.send(cb_id, null, JSON.stringify(products));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Payments_ConsumePurchase: function (cb_id, cpurchase_token) {
        var self = YaGamesPrivate;
        try {
            var purchase_token = UTF8ToString(cpurchase_token);
            self._payments
                .consumePurchase(purchase_token)
                .then(() => {
                    self.send(cb_id, null);
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_GetPlayer: function (cb_id, coptions) {
        var self = YaGamesPrivate;
        try {
            var options = self.parseJson(UTF8ToString(coptions));
            self._ysdk
                .getPlayer(options)
                .then((player) => {
                    self._player = player;
                    self.send(cb_id);
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Player_GetPayingStatus: function () {
        var self = YaGamesPrivate;
        var cstatus = stringToNewUTF8(self._player.getPayingStatus());
        return cstatus;
    },

    YaGamesPrivate_Player_GetPersonalInfo: function () {
        var self = YaGamesPrivate;
        var personalInfo = self._player._personalInfo;
        if (typeof personalInfo !== "undefined") {
            var str = JSON.stringify(personalInfo);
            var cstr = stringToNewUTF8(str);
            return cstr;
        } else {
            return 0;
        }
    },

    YaGamesPrivate_Player_GetSignature: function () {
        var self = YaGamesPrivate;
        var signature = self._player.signature;
        if (typeof signature === "string") {
            var csignature = stringToNewUTF8(signature);
            return csignature;
        } else {
            return 0;
        }
    },

    YaGamesPrivate_Player_GetID: function () {
        var self = YaGamesPrivate;
        var cid = stringToNewUTF8("" + self._player.getID());
        return cid;
    },

    YaGamesPrivate_Player_GetIDsPerGame: function (cb_id) {
        var self = YaGamesPrivate;
        try {
            self._player
                .getIDsPerGame()
                .then((arr) => {
                    self.send(cb_id, null, JSON.stringify(arr));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Player_GetMode: function () {
        var self = YaGamesPrivate;
        var cmode = stringToNewUTF8(self._player.getMode());
        return cmode;
    },

    YaGamesPrivate_Player_GetName: function () {
        var self = YaGamesPrivate;
        var cname = stringToNewUTF8(self._player.getName());
        return cname;
    },

    YaGamesPrivate_Player_GetPhoto: function (csize) {
        var self = YaGamesPrivate;
        var size = UTF8ToString(csize);
        var cname = stringToNewUTF8(self._player.getPhoto(size));
        return cname;
    },

    YaGamesPrivate_Player_GetUniqueID: function () {
        var self = YaGamesPrivate;
        var cid = stringToNewUTF8(self._player.getUniqueID());
        return cid;
    },

    YaGamesPrivate_Player_SetData: function (cb_id, cdata, flush) {
        var self = YaGamesPrivate;
        try {
            var data = self.parseJson(UTF8ToString(cdata));
            self._player
                .setData(data, flush)
                .then(() => {
                    self.send(cb_id);
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Player_GetData: function (cb_id, ckeys) {
        var self = YaGamesPrivate;
        try {
            var keys = ckeys === 0 ? undefined : self.parseJson(UTF8ToString(ckeys));
            self._player
                .getData(keys)
                .then((result) => {
                    self.send(cb_id, null, JSON.stringify(result));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Player_SetStats: function (cb_id, cstats) {
        var self = YaGamesPrivate;
        try {
            var stats = self.parseJson(UTF8ToString(cstats));
            self._player
                .setStats(stats)
                .then(() => {
                    self.send(cb_id);
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Player_IncrementStats: function (cb_id, cincrements) {
        var self = YaGamesPrivate;
        try {
            var increments = self.parseJson(UTF8ToString(cincrements));
            self._player
                .incrementStats(increments)
                .then((result) => {
                    self.send(cb_id, null, JSON.stringify(result));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Player_GetStats: function (cb_id, ckeys) {
        var self = YaGamesPrivate;
        try {
            var keys = ckeys === 0 ? undefined : self.parseJson(UTF8ToString(ckeys));
            self._player
                .getStats(keys)
                .then((result) => {
                    self.send(cb_id, null, JSON.stringify(result));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Screen_Fullscreen_Status: function () {
        var status = YaGamesPrivate._ysdk.screen.fullscreen.status;
        var cstatus = stringToNewUTF8(status);
        return cstatus;
    },

    YaGamesPrivate_Screen_Fullscreen_Request: function (cb_id) {
        var self = YaGamesPrivate;
        try {
            self._ysdk
                .screen.fullscreen.request()
                .then(() => {
                    self.send(cb_id, null);
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Screen_Fullscreen_Exit: function (cb_id) {
        var self = YaGamesPrivate;
        try {
            self._ysdk
                .screen.fullscreen.exit()
                .then(() => {
                    self.send(cb_id, null);
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Shortcut_CanShowPrompt: function (cb_id) {
        var self = YaGamesPrivate;
        try {
            self._ysdk
                .shortcut.canShowPrompt()
                .then((result) => {
                    self.send(cb_id, null, JSON.stringify(result));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Shortcut_ShowPrompt: function (cb_id) {
        var self = YaGamesPrivate;
        try {
            self._ysdk
                .shortcut.showPrompt()
                .then((result) => {
                    self.send(cb_id, null, JSON.stringify(result));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_GetStorage: function (cb_id) {
        var self = YaGamesPrivate;
        try {
            self._ysdk
                .getStorage()
                .then((storage) => {
                    self._storage = storage;
                    self.send(cb_id);
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_Storage_GetItem: function (ckey) {
        var self = YaGamesPrivate;
        var key = UTF8ToString(ckey);
        var value = self._storage.getItem(key);
        if (typeof value === "string") {
            var cvalue = stringToNewUTF8(value);
            return cvalue;
        } else {
            return 0;
        }
    },

    YaGamesPrivate_Storage_SetItem: function (ckey, cvalue) {
        // https://developer.mozilla.org/en-US/docs/Web/API/Storage/setItem
        // setItem() may throw an exception if the storage is full. Particularly, in Mobile Safari (since iOS 5)
        // it always throws when the user enters private mode. (Safari sets the quota to 0 bytes in private mode,
        // unlike other browsers, which allow storage in private mode using separate data containers.) Hence
        // developers should make sure to always catch possible exceptions from setItem().
        var self = YaGamesPrivate;
        var key = UTF8ToString(ckey);
        var value = UTF8ToString(cvalue);
        try {
            self._storage.setItem(key, value);
        } catch (e) {
            console.warn("yagames.storage_set_item:", e);
        }
    },

    YaGamesPrivate_Storage_RemoveItem: function (ckey) {
        var self = YaGamesPrivate;
        var key = UTF8ToString(ckey);
        self._storage.removeItem(key);
    },

    YaGamesPrivate_Storage_Clear: function () {
        var self = YaGamesPrivate;
        self._storage.clear();
    },

    YaGamesPrivate_Storage_Key: function (n) {
        var self = YaGamesPrivate;
        var key = self._storage.key(n);
        if (typeof key === "string") {
            var ckey = stringToNewUTF8(key);
            return ckey;
        } else {
            return 0;
        }
    },

    YaGamesPrivate_Storage_Length: function () {
        var self = YaGamesPrivate;
        return self._storage.length;
    },

    YaGamesPrivate_Event_Dispatch: function (cevent_name) {
        var self = YaGamesPrivate;
        var event_name = UTF8ToString(cevent_name);
        self._ysdk.dispatchEvent(self._ysdk.EVENTS[event_name]);
    },

    YaGamesPrivate_Event_On: function (cevent_name, cb_id) {
        var self = YaGamesPrivate;
        var event_name = UTF8ToString(cevent_name);
        try {
            self._ysdk.onEvent(self._ysdk.EVENTS[event_name], () => {
                self.send(cb_id, null);
            });

            // Uncomment to test the behaviour:
            // setInterval(function() { self.send(cb_id, null); }, 3000);
        } catch (err) {
            self.delaySend(cb_id, self.toErrStr(err));
        }
    },

    YaGamesPrivate_GetFlags: function (cb_id, coptions) {
        var self = YaGamesPrivate;
        try {
            var options = coptions === 0 ? {} : self.parseJson(UTF8ToString(coptions));
            self._ysdk
                .getFlags(options)
                .then((flags) => {
                    self.send(cb_id, null, JSON.stringify(flags));
                })
                .catch((err) => {
                    self.send(cb_id, self.toErrStr(err));
                });
        } catch (err) {
            
        }
    },

    YaGamesPrivate_Banner_Init: function (cb_id) {
        var self = YaGamesPrivate;
        self.delaySend(cb_id, "DEPRECATED.");
    },
};

autoAddDeps(LibYaGamesPrivate, "$YaGamesPrivate");
addToLibrary(LibYaGamesPrivate);
