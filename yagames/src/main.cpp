#define LIB_NAME "YaGames"

// include the Defold SDK
#include <dmsdk/sdk.h>
#include <string.h>

#if defined(DM_PLATFORM_HTML5)

typedef void (*ObjectMessage)(const int cb_id, const char* message_id, const char* message);
typedef void (*NoMessage)(const int cb_id, const char* message_id);
typedef void (*NumberMessage)(const int cb_id, const char* message_id, float message);
typedef void (*BooleanMessage)(const int cb_id, const char* message_id, int message);

extern "C"
{
    void YaGamesPrivate_RegisterCallbacks(ObjectMessage cb_obj,
                                          ObjectMessage cb_string,
                                          NoMessage cb_empty,
                                          NumberMessage cb_num,
                                          BooleanMessage cb_bool);
    void YaGamesPrivate_RemoveCallbacks();

    void YaGamesPrivate_ShowFullscreenAdv(const int cb_id);
    void YaGamesPrivate_ShowRewardedVideo(const int cb_id);
    void YaGamesPrivate_OpenAuthDialog(const int cb_id);
    const bool YaGamesPrivate_DeviceInfo_IsDesktop();
    const bool YaGamesPrivate_DeviceInfo_IsMobile();
    const bool YaGamesPrivate_DeviceInfo_IsTablet();
    void YaGamesPrivate_GetPayments(const int cb_id, const char* options);
    void YaGamesPrivate_Payments_Purchase(const int cb_id, const char* options);
    void YaGamesPrivate_Payments_GetPurchases(const int cb_id);
    void YaGamesPrivate_Payments_GetCatalog(const int cb_id);
    void YaGamesPrivate_Payments_ConsumePurchase(const int cb_id, const char* purchase_token);
    void YaGamesPrivate_GetPlayer(const int cb_id, const char* options);
    void YaGamesPrivate_Player_GetIDsPerGame(const int cb_id);
    const char* YaGamesPrivate_Player_GetID();
    const char* YaGamesPrivate_Player_GetName();
    const char* YaGamesPrivate_Player_GetPhoto(const char* size);
    const char* YaGamesPrivate_Player_GetUniqueID();
    void YaGamesPrivate_Player_SetData(const int cb_id, const char* cdata, const bool flush);
    void YaGamesPrivate_Player_GetData(const int cb_id, const char* ckeys);
    void YaGamesPrivate_Player_SetStats(const int cb_id, const char* cstats);
    void YaGamesPrivate_Player_IncrementStats(const int cb_id, const char* cincrements);
    void YaGamesPrivate_Player_GetStats(const int cb_id, const char* ckeys);
    void YaGamesPrivate_Context_Init(const int cb_id);
}

struct YaGamesPrivateListener
{
    YaGamesPrivateListener()
        : m_L(0)
        , m_Callback(LUA_NOREF)
        , m_Self(LUA_NOREF)
    {
    }
    lua_State* m_L;
    int m_Callback;
    int m_Self;
    int m_OnlyId;
};

static void UnregisterCallback(lua_State* L, YaGamesPrivateListener* cbk);
static int GetEqualIndexOfListener(lua_State* L, YaGamesPrivateListener* cbk);

static dmArray<YaGamesPrivateListener> m_Listeners;

static bool CheckCallbackAndInstance(YaGamesPrivateListener* cbk)
{
    if (cbk->m_Callback == LUA_NOREF)
    {
        dmLogInfo("YaGamesPrivate callback do not exist.");
        return false;
    }
    lua_State* L = cbk->m_L;
    int top      = lua_gettop(L);
    lua_rawgeti(L, LUA_REGISTRYINDEX, cbk->m_Callback);
    //[-1] - callback
    lua_rawgeti(L, LUA_REGISTRYINDEX, cbk->m_Self);
    //[-1] - self
    //[-2] - callback
    lua_pushvalue(L, -1);
    //[-1] - self
    //[-2] - self
    //[-3] - callback
    dmScript::SetInstance(L);
    //[-1] - self
    //[-2] - callback
    if (!dmScript::IsInstanceValid(L))
    {
        UnregisterCallback(L, cbk);
        dmLogError("Could not run YaGamesPrivate callback because the instance has been deleted.");
        lua_pop(L, 2);
        assert(top == lua_gettop(L));
        return false;
    }
    return true;
}

static void SendObjectMessage(const int cb_id, const char* message_id, const char* message)
{
    for (int i = m_Listeners.Size() - 1; i >= 0; --i)
    {
        YaGamesPrivateListener* cbk = &m_Listeners[i];
        lua_State* L                = cbk->m_L;
        int top                     = lua_gettop(L);
        bool is_fail                = false;
        if (cbk->m_OnlyId == cb_id && CheckCallbackAndInstance(cbk))
        {
            lua_pushinteger(L, cb_id);
            if (message_id)
            {
                lua_pushstring(L, message_id);
            }
            else
            {
                lua_pushnil(L);
            }

            dmJson::Document doc;
            dmJson::Result r = dmJson::Parse(message, &doc);
            if (r == dmJson::RESULT_OK && doc.m_NodeCount > 0)
            {
                char error_str_out[128];
                if (dmScript::JsonToLua(L, &doc, 0, error_str_out, sizeof(error_str_out)) < 0)
                {
                    dmLogError("Failed converting object JSON to Lua; %s", error_str_out);
                    is_fail = true;
                }
            }
            else
            {
                dmLogError("Failed to parse JS object(%d): (%s)", r, message);
                is_fail = true;
            }
            dmJson::Free(&doc);
            if (is_fail)
            {
                lua_pop(L, 3);
                assert(top == lua_gettop(L));
                return;
            }
            int ret = lua_pcall(L, 4, 0, 0);
            if (ret != 0)
            {
                dmLogError("Error running callback: %s", lua_tostring(L, -1));
                lua_pop(L, 1);
            }
        }
        assert(top == lua_gettop(L));
    }
}

static void SendStringMessage(const int cb_id, const char* message_id, const char* message)
{
    for (int i = m_Listeners.Size() - 1; i >= 0; --i)
    {
        if (i > m_Listeners.Size())
        {
            return;
        }
        YaGamesPrivateListener* cbk = &m_Listeners[i];
        lua_State* L                = cbk->m_L;
        int top                     = lua_gettop(L);
        if (cbk->m_OnlyId == cb_id && CheckCallbackAndInstance(cbk))
        {
            lua_pushinteger(L, cb_id);
            if (message_id)
            {
                lua_pushstring(L, message_id);
            }
            else
            {
                lua_pushnil(L);
            }
            lua_pushstring(L, message);

            int ret = lua_pcall(L, 4, 0, 0);
            if (ret != 0)
            {
                dmLogError("Error running callback: %s", lua_tostring(L, -1));
                lua_pop(L, 1);
            }
        }
        assert(top == lua_gettop(L));
    }
}

static void SendEmptyMessage(const int cb_id, const char* message_id)
{
    for (int i = m_Listeners.Size() - 1; i >= 0; --i)
    {
        if (i > m_Listeners.Size())
        {
            return;
        }
        YaGamesPrivateListener* cbk = &m_Listeners[i];
        lua_State* L                = cbk->m_L;
        int top                     = lua_gettop(L);
        if (cbk->m_OnlyId == cb_id && CheckCallbackAndInstance(cbk))
        {
            lua_pushinteger(L, cb_id);
            if (message_id)
            {
                lua_pushstring(L, message_id);
            }
            else
            {
                lua_pushnil(L);
            }

            int ret = lua_pcall(L, 3, 0, 0);
            if (ret != 0)
            {
                dmLogError("Error running callback: %s", lua_tostring(L, -1));
                lua_pop(L, 1);
            }
        }
        assert(top == lua_gettop(L));
    }
}

static void SendNumMessage(const int cb_id, const char* message_id, float message)
{
    for (int i = m_Listeners.Size() - 1; i >= 0; --i)
    {
        if (i > m_Listeners.Size())
        {
            return;
        }
        YaGamesPrivateListener* cbk = &m_Listeners[i];
        lua_State* L                = cbk->m_L;
        int top                     = lua_gettop(L);
        if (cbk->m_OnlyId == cb_id && CheckCallbackAndInstance(cbk))
        {
            lua_pushinteger(L, cb_id);
            if (message_id)
            {
                lua_pushstring(L, message_id);
            }
            else
            {
                lua_pushnil(L);
            }
            lua_pushnumber(L, message);

            int ret = lua_pcall(L, 4, 0, 0);
            if (ret != 0)
            {
                dmLogError("Error running callback: %s", lua_tostring(L, -1));
                lua_pop(L, 1);
            }
        }
        assert(top == lua_gettop(L));
    }
}

static void SendBoolMessage(const int cb_id, const char* message_id, int message)
{
    for (int i = m_Listeners.Size() - 1; i >= 0; --i)
    {
        YaGamesPrivateListener* cbk = &m_Listeners[i];
        lua_State* L                = cbk->m_L;
        int top                     = lua_gettop(L);
        if (cbk->m_OnlyId == cb_id && CheckCallbackAndInstance(cbk))
        {
            lua_pushinteger(L, cb_id);
            if (message_id)
            {
                lua_pushstring(L, message_id);
            }
            else
            {
                lua_pushnil(L);
            }
            lua_pushboolean(L, message);

            int ret = lua_pcall(L, 4, 0, 0);
            if (ret != 0)
            {
                dmLogError("Error running callback: %s", lua_tostring(L, -1));
                lua_pop(L, 1);
            }
        }
        assert(top == lua_gettop(L));
    }
}

static int GetEqualIndexOfListener(lua_State* L, YaGamesPrivateListener* cbk)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, cbk->m_Callback);
    int first  = lua_gettop(L);
    int second = first + 1;
    for (uint32_t i = 0; i != m_Listeners.Size(); ++i)
    {
        YaGamesPrivateListener* cb = &m_Listeners[i];
        lua_rawgeti(L, LUA_REGISTRYINDEX, cb->m_Callback);
        if (lua_equal(L, first, second))
        {
            lua_pop(L, 1);
            lua_rawgeti(L, LUA_REGISTRYINDEX, cbk->m_Self);
            lua_rawgeti(L, LUA_REGISTRYINDEX, cb->m_Self);
            if (lua_equal(L, second, second + 1))
            {
                lua_pop(L, 3);
                return i;
            }
            lua_pop(L, 2);
        }
        else
        {
            lua_pop(L, 1);
        }
    }
    lua_pop(L, 1);
    return -1;
}

static void UnregisterCallback(lua_State* L, YaGamesPrivateListener* cbk)
{
    int index = GetEqualIndexOfListener(L, cbk);
    if (index >= 0)
    {
        if (cbk->m_Callback != LUA_NOREF)
        {
            dmScript::Unref(cbk->m_L, LUA_REGISTRYINDEX, cbk->m_Callback);
            dmScript::Unref(cbk->m_L, LUA_REGISTRYINDEX, cbk->m_Self);
            cbk->m_Callback = LUA_NOREF;
        }
        m_Listeners.EraseSwap(index);
        if (m_Listeners.Size() == 0)
        {
            YaGamesPrivate_RemoveCallbacks();
        }
    }
    else
    {
        dmLogError("Can't remove a callback that didn't not register.");
    }
}

static int AddListener(lua_State* L)
{
    YaGamesPrivateListener cbk;
    cbk.m_L      = dmScript::GetMainThread(L);
    cbk.m_OnlyId = luaL_checkint(L, 1);

    luaL_checktype(L, 2, LUA_TFUNCTION);
    lua_pushvalue(L, 2);
    cbk.m_Callback = dmScript::Ref(L, LUA_REGISTRYINDEX);

    dmScript::GetInstance(L);
    cbk.m_Self = dmScript::Ref(L, LUA_REGISTRYINDEX);

    if (cbk.m_Callback != LUA_NOREF)
    {
        int index = GetEqualIndexOfListener(L, &cbk);
        if (index < 0)
        {
            if (m_Listeners.Full())
            {
                m_Listeners.OffsetCapacity(1);
            }
            m_Listeners.Push(cbk);
        }
        else
        {
            dmLogError("Can't register a callback again. Callback has been registered before.");
        }
        if (m_Listeners.Size() == 1)
        {
            YaGamesPrivate_RegisterCallbacks(SendObjectMessage,
                                             SendStringMessage,
                                             SendEmptyMessage,
                                             SendNumMessage,
                                             SendBoolMessage);
        }
    }
    return 0;
}

static int RemoveListener(lua_State* L)
{
    YaGamesPrivateListener cbk;
    cbk.m_L = dmScript::GetMainThread(L);

    luaL_checktype(L, 1, LUA_TFUNCTION);
    lua_pushvalue(L, 1);

    cbk.m_Callback = dmScript::Ref(L, LUA_REGISTRYINDEX);

    dmScript::GetInstance(L);
    cbk.m_Self = dmScript::Ref(L, LUA_REGISTRYINDEX);

    UnregisterCallback(L, &cbk);
    return 0;
}

//
// Yandex Games SDK API
//

static int ShowFullscreenAdv(lua_State* L)
{
    YaGamesPrivate_ShowFullscreenAdv(luaL_checkint(L, 1));
    return 0;
}

static int ShowRewardedVideo(lua_State* L)
{
    YaGamesPrivate_ShowRewardedVideo(luaL_checkint(L, 1));
    return 0;
}

static int OpenAuthDialog(lua_State* L)
{
    YaGamesPrivate_OpenAuthDialog(luaL_checkint(L, 1));
    return 0;
}

static int DeviceInfo_IsDesktop(lua_State* L)
{
    lua_pushboolean(L, YaGamesPrivate_DeviceInfo_IsDesktop());
    return 1;
}

static int DeviceInfo_IsMobile(lua_State* L)
{
    lua_pushboolean(L, YaGamesPrivate_DeviceInfo_IsMobile());
    return 1;
}

static int DeviceInfo_IsTablet(lua_State* L)
{
    lua_pushboolean(L, YaGamesPrivate_DeviceInfo_IsTablet());
    return 1;
}

static int GetPayments(lua_State* L)
{
    YaGamesPrivate_GetPayments(luaL_checkint(L, 1), luaL_checkstring(L, 2));
    return 0;
}

static int Payments_Purchase(lua_State* L)
{
    YaGamesPrivate_Payments_Purchase(luaL_checkint(L, 1), luaL_checkstring(L, 2));
    return 0;
}

static int Payments_GetPurchases(lua_State* L)
{
    YaGamesPrivate_Payments_GetPurchases(luaL_checkint(L, 1));
    return 0;
}

static int Payments_GetCatalog(lua_State* L)
{
    YaGamesPrivate_Payments_GetCatalog(luaL_checkint(L, 1));
    return 0;
}

static int Payments_ConsumePurchase(lua_State* L)
{
    YaGamesPrivate_Payments_ConsumePurchase(luaL_checkint(L, 1), luaL_checkstring(L, 2));
    return 0;
}

static int GetPlayer(lua_State* L)
{
    YaGamesPrivate_GetPlayer(luaL_checkint(L, 1), luaL_checkstring(L, 2));
    return 0;
}

static int Player_GetID(lua_State* L)
{
    const char* id = YaGamesPrivate_Player_GetID();
    lua_pushstring(L, id);
    free((void*)id);
    return 1;
}

static int Player_GetIDsPerGame(lua_State* L)
{
    YaGamesPrivate_Player_GetIDsPerGame(luaL_checkint(L, 1));
    return 0;
}

static int Player_GetName(lua_State* L)
{
    const char* name = YaGamesPrivate_Player_GetName();
    lua_pushstring(L, name);
    free((void*)name);
    return 1;
}

static int Player_GetPhoto(lua_State* L)
{
    const char* url = YaGamesPrivate_Player_GetPhoto(luaL_checkstring(L, 1));
    lua_pushstring(L, url);
    free((void*)url);
    return 1;
}

static int Player_GetUniqueID(lua_State* L)
{
    const char* id = YaGamesPrivate_Player_GetUniqueID();
    lua_pushstring(L, id);
    free((void*)id);
    return 1;
}

static int Player_SetData(lua_State* L)
{
    YaGamesPrivate_Player_SetData(luaL_checkint(L, 1), luaL_checkstring(L, 2), lua_toboolean(L, 3));
    return 0;
}

static int Player_GetData(lua_State* L)
{
    if (lua_isstring(L, 2))
    {
        YaGamesPrivate_Player_GetData(luaL_checkint(L, 1), luaL_checkstring(L, 2));
    }
    else
    {
        YaGamesPrivate_Player_GetData(luaL_checkint(L, 1), 0);
    }
    return 0;
}

static int Player_SetStats(lua_State* L)
{
    YaGamesPrivate_Player_SetStats(luaL_checkint(L, 1), luaL_checkstring(L, 2));
    return 0;
}

static int Player_IncrementStats(lua_State* L)
{
    YaGamesPrivate_Player_IncrementStats(luaL_checkint(L, 1), luaL_checkstring(L, 2));
    return 0;
}

static int Player_GetStats(lua_State* L)
{
    if (lua_isstring(L, 2))
    {
        YaGamesPrivate_Player_GetStats(luaL_checkint(L, 1), luaL_checkstring(L, 2));
    }
    else
    {
        YaGamesPrivate_Player_GetStats(luaL_checkint(L, 1), 0);
    }
    return 0;
}

//
//
//

static int Context_Init(lua_State* L)
{
    YaGamesPrivate_Context_Init(luaL_checkint(L, 1));
    return 0;
}

//
//
//

static const luaL_reg Module_methods[] = {
    { "add_listener", AddListener },
    { "remove_listener", RemoveListener },
    // Yandex Games SDK API
    // - Adv
    { "show_fullscreen_adv", ShowFullscreenAdv },
    { "show_rewarded_video", ShowRewardedVideo },
    // - Auth
    { "open_auth_dialog", OpenAuthDialog },
    // - Device Info
    { "device_info_is_desktop", DeviceInfo_IsDesktop },
    { "device_info_is_mobile", DeviceInfo_IsMobile },
    { "device_info_is_tablet", DeviceInfo_IsTablet },
    // - Payments
    { "get_payments", GetPayments },
    { "payments_purchase", Payments_Purchase },
    { "payments_get_purchases", Payments_GetPurchases },
    { "payments_get_catalog", Payments_GetCatalog },
    { "payments_consume_purchase", Payments_ConsumePurchase },
    // - Player
    { "get_player", GetPlayer },
    { "player_get_id", Player_GetID },
    { "player_get_ids_per_game", Player_GetIDsPerGame },
    { "player_get_name", Player_GetName },
    { "player_get_photo", Player_GetPhoto },
    { "player_get_unique_id", Player_GetUniqueID },
    { "player_set_data", Player_SetData },
    { "player_get_data", Player_GetData },
    { "player_set_stats", Player_SetStats },
    { "player_increment_stats", Player_IncrementStats },
    { "player_get_stats", Player_GetStats },
    // - Context
    { "context_init", Context_Init },
    { 0, 0 }
};

static void LuaInit(lua_State* L)
{
    int top = lua_gettop(L);
    luaL_register(L, "yagames_private", Module_methods);
    lua_pop(L, 1);
    assert(top == lua_gettop(L));
}

static dmExtension::Result InitializeYaGames(dmExtension::Params* params)
{
    LuaInit(params->m_L);
    return dmExtension::RESULT_OK;
}

static dmExtension::Result FinalizeYaGames(dmExtension::Params* params)
{
    for (int i = m_Listeners.Size() - 1; i >= 0; --i)
    {
        m_Listeners.Pop();
    }
    return dmExtension::RESULT_OK;
}

#else // unsupported platforms

static dmExtension::Result InitializeYaGames(dmExtension::Params* params)
{
    return dmExtension::RESULT_OK;
}

static dmExtension::Result FinalizeYaGames(dmExtension::Params* params)
{
    return dmExtension::RESULT_OK;
}

#endif

DM_DECLARE_EXTENSION(YaGames, LIB_NAME, 0, 0, InitializeYaGames, 0, 0, FinalizeYaGames)
