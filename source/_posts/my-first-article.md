---
title: Don't starve Together server 搭建
date: 2017-11-02 14:20:45
tags: [Game,Linux,lua]
categories: [Linux,Server]
---
## Don't Starve Together服务器搭建(Linux)
> 本教程旨在为了解linux的玩家提供简易搭建教程。VPS-OS：ubuntu64

Klei官方英文搭建教程地址:[Don't Strave Together Dedicated Server](http://dont-starve-game.wikia.com/wiki/Guides/Don%E2%80%99t_Starve_Together_Dedicated_Servers)

{% asset_img dst.png  Don’t Starve Together %}

<!--more-->

#### 1.配置服务器运行环境
```sh
 sudo apt-get update  #更新源
 sudo apt-get install lib32gcc1 libcurl4-gnutls-dev:i386 screen #必要的库和软件
 ```
#### 2.安装steanm命令行平台和游戏包
```sh
mkdir ~/steamcmd   #创建文件夹
cd ~/steamcmd   #打开文件夹
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz   #下载精简包
tar -xvzf steamcmd_linux.tar.gz   #解压包
./steamcmd.sh +login anonymous +force_install_dir ~/dst +app_update 343050 validate +quit    #匿名登录steamcmd，安装饥荒(DST)到~/dst
```
#### 3.测试运行环境
```sh
cd ~/dst/bin   #打开启动命令文件夹
./dontstarve_dedicated_server_nullrenderer   #运行测试是否有错误
```

{% note danger %} ###### 一般会有下面这个错误出现：

libstdc++.so.6: version GLIBCXX_3.4.15 not found
{%endnote%}
```sh 
cp ~/steamcmd/linux32/libstdc++.so.6 ~/dst/bin/lib32/   #这是因为缺少库文件,输入此命令复制库文件解决
```

***

#### 4.运行启动文件
```sh
cd ~/dst/bin/
echo ./dontstarve_dedicated_server_nullrenderer -console -cluster MyDediServer -shard Master > overworld.sh   #地上世界启动脚本
echo ./dontstarve_dedicated_server_nullrenderer -console -cluster MyDediServer -shard Caves > cave.sh   #洞穴启动脚本
sh overworld.sh   #运行，等待几秒会提示你Your Server Will Not Start，这时按Ctrl+c终止进程
sh cave.sh   #运行，等待几秒会提示你Your Server Will Not Start，这时按Ctrl+c终止进程
rm -rf ~/.klei/DoNotStarveTogether/Cluster_*   #删除默认文件
```
{% note success %} ~/.klei/DoNotStarveTogether/MyDediServer  是默认配置目录，里面两个Master和caves分别是地上和洞穴配置目录
{%endnote%}

#### 5.配置核心文件
> 1.配置cluster_token.txt文件

进入饥荒主页面，右下角点击Account图标，在打开的页面找到Generate Server Token 按钮，随便输入一个描述，会生成一个token,新建一个cluster_token.txt文件，复制进去，放在MyDediServer目录下。

> 2.通用配置文件cluster.ini

```ini
[MISC]
max_snapshots = 6                  # 最大快照数，决定了可回滚的天数
console_enabled = true             # 是否开启控制台
 
[SHARD]
shard_enabled = true               # 服务器共享，要开启洞穴服务器的必须启用
bind_ip = 127.0.0.1                # 服务器监听的地址，当所有实例都运行在同一台机器时，可填写 127.0.0.1，会被 server .ini 覆盖
master_ip = 127.0.0.1              # master 服务器的 IP，针对非 master 服务器，若与 master 服务器运行在同一台机器时，可填写 127.0.0.1，会被 server.ini 覆盖
master_port = 10888                # 监听 master 服务器的 UDP 端口，所有连接至 master 服务器的非 master 服务器必须相同
cluster_key = dst                  # 连接密码，每台服务器必须相同，会被 server.ini 覆盖
 
[STEAM]
steam_group_only = false           # 只允许某 Steam 组的成员加入
steam_group_id = 0                 # 指定某个 Steam 组，填写组 ID
steam_group_admins = false         # 开启后，Steam 组的管理员拥有服务器的管理权限
 
[NETWORK]
offline_server = false             # 离线服务器，只有局域网用户能加入，并且所有依赖于 Steam 的任何功能都无效，比如说饰品掉落
tick_rate = 15                     # 每秒通信次数，越高游戏体验越好，但是会加大服务器负担
whitelist_slots = 0                # 为白名单用户保留的游戏位
cluster_password =                 # 游戏密码，不设置表示无密码
cluster_name = ttionya test        # 游戏房间名称
cluster_description = description  # 游戏房间描述
lan_only_cluster = false           # 局域网游戏
cluster_intention = madness        # 游戏偏好，选项为 cooperative, competitive, social, or madness，没什么用
 
[GAMEPLAY]
max_players = 16                   # 最大游戏人数
pvp = false                         # 能不能攻击其他玩家
game_mode = survival               # 游戏模式，可选 survival, endless or wilderness
pause_when_empty = true           # 没人服务器暂停
vote_kick_enabled = true          # 投票踢人
```
设置完毕保存为cluster.ini文件,放在MyDediServer下。

> 3.地上和洞穴独立配置文件server.ini

配置介绍：
```ini
[SHARD]
is_master = true /false      # 是否是 master 服务器，只能存在一个 true，其他全是 false
name = caves                 # 针对非 master 服务器的名称
 
[STEAM]
authentication_port = 8766   # Steam 用的端口，确保每个实例都不相同
master_server_port = 27016   # Steam 用的端口，确保每个实例都不相同
 
[NETWORK]
server_port = 10999          # 监听的 UDP 端口，只能介于 10998 - 11018 之间，确保每个实例都不相同
```
地上和洞穴配置具体在下方：
（地上）Master文件夹里的server.ini：
```ini
[SHARD]
is_master = true
 
[STEAM]
authentication_port = 12345
master_server_port = 12346
 
[NETWORK]
server_port = 10999
```
(洞穴)Caves文件夹里的server.ini:
```ini
[SHARD]
is_master = false
name = caves
 
[STEAM]
authentication_port = 12347
master_server_port = 12348
 
[NETWORK]
server_port = 11000
```

> 4.地上和洞穴的地图配置文件worldgenoverride.lua

地上：
```lua
return {
    override_enabled = true,
    preset = "SURVIVAL_TOGETHER",       -- "SURVIVAL_TOGETHER", "MOD_MISSING", "SURVIVAL_TOGETHER_CLASSIC", "SURVIVAL_DEFAULT_PLUS", "COMPLETE_DARKNESS", "DST_CAVE", "DST_CAVE_PLUS"
    overrides = {
        -- default is "never", "rare", "default", "often", "always" 下方值为default的几个调节的选项，从不，很少，默认，经常，总是
  
        -- MISC
        task_set = "default",           -- "classic", "default", "cave_default"
        start_location = "default",     -- "caves", "default", "plus", "darkness"
        world_size = "default",         -- "small", "medium", "default", "huge"-世界大小
        branching = "default",          -- "never", "least", "default", "most" 
        loop = "default",               -- "never", "default", "always"
        autumn = "default",             -- "noseason", "veryshortseason", "shortseason", "default", "longseason", "verylongseason", "random"
        winter = "default",             -- "noseason", "veryshortseason", "shortseason", "default", "longseason", "verylongseason", "random"
        spring = "default",             -- "noseason", "veryshortseason", "shortseason", "default", "longseason", "verylongseason", "random"
        summer = "default",             -- "noseason", "veryshortseason", "shortseason", "default", "longseason", "verylongseason", "random"
        season_start = "default",       -- "default", "winter", "spring", "summer", "autumnorspring", "winterorsummer", "random"
        day = "default",                -- "default", "longday", "longdusk", "longnight", "noday", "nodusk", "nonight", "onlyday", "onlydusk", "onlynight"
        weather = "default",
        earthquakes = "default", --地震
        lightning = "default", 
        frograin = "default", --青蛙雨
        wildfires = "default", --火灾
        touchstone = "default",
        regrowth = "default",           -- "veryslow", "slow", "default", "fast", "veryfast"
        cavelight = "default",          -- "veryslow", "slow", "default", "fast", "veryfast"
        boons = "default",
        prefabswaps_start = "default",  -- "classic", "default", "highly random"
        prefabswaps = "default",        -- "none", "few", "default", "many", "max"
        specialevent = "",  -- 特殊节日，一般选填冬季盛宴 winters_feast


        -- RESOURCES
        flowers = "default",
        grass = "default",
        sapling = "default",
        marshbush = "default",
        tumbleweed = "default",
        reeds = "default",
        trees = "default",
        flint = "default",
        rock = "default",
        rock_ice = "default",
        meteorspawner = "default",
        meteorshowers = "default",
        mushtree = "default",
        fern = "default",
        flower_cave = "default",
        wormlights = "default",
  
        -- UNPREPARED
        berrybush = "default", --浆果
        carrot = "default", --萝卜
        mushroom = "default", --蘑菇
        cactus = "default",
        banana = "default",
        lichen = "default",
  
        -- ANIMALS
        rabbits = "default",
        moles = "default",
        butterfly = "default",
        birds = "default",
        buzzard = "default",
        catcoon = "default",
        perd = "default",
        pigs = "default", --猪
        lightninggoat = "default",
        beefalo = "default",
        beefaloheat = "default",
        hunt = "default",
        alternatehunt = "default",
        penguins = "default",
        cave_ponds = "default",
        ponds = "default",
        bees = "default",
        angrybees = "default",
        tallbirds = "default",
        slurper = "default",
        bunnymen = "default",
        slurtles = "default",
        rocky = "default",
        monkey = "default", --猴子
  
        -- MONSTERS
        spiders = "default", --蜘蛛
        cave_spiders = "default",
        hounds = "default",
        houndmound = "default", --猎犬袭击
        merm = "default",
        tentacles = "default",
        chess = "default", --地上发条数量
        lureplants = "default",
        walrus = "default", 
        liefs = "default", --树人频率
        deciduousmonster = "default",
        krampus = "default",
        bearger = "default", --熊大
        deerclops = "default", -- 巨鹿
        goosemoose = "default", -- 蠢鹅
        dragonfly = "default", --苍蝇
        bats = "default",
        fissure = "default",
        worms = "default", --蠕虫
    },
}
```
洞穴：
```lua
return {
    override_enabled = true,
    preset = "DST_CAVE",                 -- "SURVIVAL_TOGETHER", "MOD_MISSING", "SURVIVAL_TOGETHER_CLASSIC", "SURVIVAL_DEFAULT_PLUS", "COMPLETE_DARKNESS", "DST_CAVE", "DST_CAVE_PLUS"
    overrides = {
        -- defalut is "never", "rare", "default", "often", "always"
  
        -- MISC
        task_set = "cave_default",       -- "classic", "default", "cave_default"
        start_location = "default",      -- "caves", "default", "plus", "darkness"
        world_size = "default",          -- "small", "medium", "default", "huge"
        branching = "default",           -- "never", "least", "default", "most"
        loop = "default",                -- "never", "default", "always"
        autumn = "default",              -- "noseason", "veryshortseason", "shortseason", "default", "longseason", "verylongseason", "random"
        winter = "default",              -- "noseason", "veryshortseason", "shortseason", "default", "longseason", "verylongseason", "random"
        spring = "default",              -- "noseason", "veryshortseason", "shortseason", "default", "longseason", "verylongseason", "random"
        summer = "default",              -- "noseason", "veryshortseason", "shortseason", "default", "longseason", "verylongseason", "random"
        season_start = "default",        -- "default", "winter", "spring", "summer", "autumnorspring", "winterorsummer", "random"
        day = "default",                 -- "default", "longday", "longdusk", "longnight", "noday", "nodusk", "nonight", "onlyday", "onlydusk", "onlynight"
        weather = "default",
        earthquakes = "default",
        lightning = "default",
        frograin = "default",
        wildfires = "default",
        touchstone = "default",
        regrowth = "default",            -- "veryslow", "slow", "default", "fast", "veryfast"
        cavelight = "default",           -- "veryslow", "slow", "default", "fast", "veryfast"
        boons = "default",
        prefabswaps_start = "default",   -- "classic", "default", "highly random"
        prefabswaps = "default",         -- "none", "few", "default", "many", "max"
  
        -- RESOURCES
        flowers = "default",
        grass = "default",
        sapling = "default",
        marshbush = "default",
        tumbleweed = "default",
        reeds = "default",
        trees = "default",
        flint = "default",
        rock = "default",
        rock_ice = "default",
        meteorspawner = "default",
        meteorshowers = "default",
        mushtree = "default",
        fern = "default",
        flower_cave = "default",
        wormlights = "default",
  
        -- UNPREPARED
        berrybush = "default",
        carrot = "default",
        mushroom = "default",
        cactus = "default",
        banana = "default",
        lichen = "default",
  
        -- ANIMALS
        rabbits = "default",
        moles = "default",
        butterfly = "default",
        birds = "default",
        buzzard = "default",
        catcoon = "default",
        perd = "default",
        pigs = "default",
        lightninggoat = "default",
        beefalo = "default",
        beefaloheat = "default",
        hunt = "default",
        alternatehunt = "default",
        penguins = "default",
        cave_ponds = "default",
        ponds = "default",
        bees = "default",
        angrybees = "default",
        tallbirds = "default",
        slurper = "default",
        bunnymen = "default",
        slurtles = "default",
        rocky = "default",
        monkey = "default",
  
        -- MONSTERS
        spiders = "default",
        cave_spiders = "default",
        hounds = "default",
        houndmound = "default",
        merm = "default",
        tentacles = "default",
        chess = "default",
        lureplants = "default",
        walrus = "default",
        liefs = "default",
        deciduousmonster = "default",
        krampus = "default",
        bearger = "default",
        deerclops = "default",
        goosemoose = "default",
        dragonfly = "default",
        bats = "default",
        fissure = "default",
        worms = "default",
    },
}
```
这时基本的已经完成，已经可以正常开服，但是没MOD怎么玩得下去嘞～
下面6，7，8为可选配置：
#### 6. 配置下载mod文件
 {% note info %}创建dedicated_server_mods_setup.lua文件：
 {% endnote %}
```lua
  --第一种是安装单独mod
  --ServerModSetup("mod的id")
  --第二种是安装mod合集
  --ServerModCollectionSetup("合集的id")

--下面推荐几个常用的mod   
ServerModSetup("666155465") --show me
ServerModSetup("375859599") --health info
ServerModSetup("780009141") --物品箱子提示
ServerModSetup("462434129") --restart
ServerModSetup("367546858") --服务端中文
ServerModSetup("841471368") --防熊锁
ServerModSetup("378160973") --全图定位
 
--饥荒的mod id查看：浏览器打开创意工坊任意要下载的mod页面，url处会有id=xxxxxxxx
```

保存在~/dst/mods/ 目录下，第一次开服时服务器会自动下载mod。

#### 7. 配置地上和洞穴的mod开关文件
{% note info %}
MOD开关文件：modoverrides.lua
{% endnote %}
```lua
return {
["workshop-375859599"] = { enabled = true },--healh info
["workshop-841471368"] = { enabled = true },--fangxiongsuo
["workshop-378160973"] = { enabled = true },--Global Positions
["workshop-462434129"] = { enabled = true },--restart
["workshop-780009141"] = { enabled = true },--Finder
["workshop-666155465"] = { enabled = true },--Show Me
["workshop-367546858"] = {enabled = true} --chinese
}
--true表示启用，false表示禁用
```
Master和Caves 文件夹里各放一份。

##### 8. 配置管理员，黑名单等
> 创建adminlist.txt文件，填入用户id（KU_开头的），用户id可以在人员进入服务器后Master目录下的chat log文件里找到。

>黑白名单同理，分别创建blocklist.txt和whitelist.txt

#### 最后你的服务器目录应该是这样：

```
/home/ubuntu/.klei/DoNotStarveTogether/MyDediServer
|
|   adminlist.txt（/adminlist.txt）
|   blocklist.txt（/blocklist.txt）
|   cluster.ini（/cluster.ini）
|   cluster_token.txt（/cluster_token.txt）
|   whitelist.txt（/whitelist.txt）
|
|---Master
|   |   modoverrides.lua（/Master/modoverrides.lua）
|   |   server.ini（/Master/server.ini）
|   |   worldgenoverride.lua（/Master/worldgenoverride.lua）
|   
|   
|  
|
|---Caves
    |   modoverrides.lua（/Caves/modoverrides.lua）
    |   server.ini（/Caves/server.ini）
    |   worldgenoverride.lua（/Caves/worldgenoverride.lua）
   
 
/home/ubuntu/dst/mods
|
|   dedicated_server_mods_setup.lua（/dedicated_server_mods_setup.lua）
```

{% note info %} 最后一步：开服！{% endnote %}

```sh
#启动地上
cd ~/dst/bin
screen sh ./overworld.sh  
再按下Ctrl+A键,然后按C键创建另一个会话
#启动地下
cd ~/dst/bin 
screen sh ./cave.sh
```

> 注：饥荒版本更新时，服务器版本更新命令（先关闭游戏进程）：

```sh
~/steamcmd/steamcmd.sh +login anonymous +force_install_dir ~/dst +app_update 343050 validate +quit
```

***
#### ---------简单开服&管理----------

其实这些命令都可以简化连续成自动化脚本来使用，，
于是我写了个综合示例 [DST server build](https://github.com/qwertyuiop6/DST-Server-Build)
里面的go.sh和dst.sh即为开服脚本和管理脚本，详解--> [使用简单shell脚本管理DST服务器](/2017/11/20/dst-shell/)