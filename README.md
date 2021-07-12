# Simple-Bank-Raid-DarkRP

https://steamcommunity.com/sharedfiles/filedetails/?id=2545502275

Nice simple bank raiding system which includes a bank vault, buyer npc and gold bars. The default jobs that can raid are Gangster and Mob Boss.

## Extra Info
This is for the Gangster job only by default.
You will be made wanted when you pickup the gold bars.
You can check you current gold you are holding by typing in the chat box either /gold or !gold this will then tell you in chat how much if any you have on you.
You can get rewards as a CP for arresting holding gold on their person, it will be 3 * the sell price of the Gold
You can get rewards as a CP for stopping the bank raid, it will be 3 * the sell price of the Gold

# How to configure
## NPC / Pallet Config
You can spawn the gold buyer by looking where you want him to spawn then using console command **simplebankraid_spawnnpc**.
You can spawn the gold pallet by looking where you want it to spawn then using console command **simplebankraid_spawnpallet**.
You can save the gold buyer(s) and gold pallet(s) locations on the current map by using console command **simplebankraid_save**.
You can remove the gold buyer(s) and gold pallet(s) locations on the current map by using console command **simplebankraid_remove** this will prevent them spawning on the next restart..
You can respawn the gold buyer(s) and gold pallet(s) locations on the current map by using console command **simplebankraid_respawn** this is handy if you just saved them or updated the saves it will remove them from the map and reload from the file so if you move one by mistake then use the respawn command and it will fix its position.

## Bank Raid Config
You can set the sell price of the gold bars by setting **simplebankraid_sellprice xxx** in your server console. (Default = 3,000 per bar)
You can set the max gold bars you can carry by setting **simplebankraid_maxgold xxx** in your server console. (Default = 10)
You can set the disable the slow speed which is set to active by default meaning that if the player carries their max allowed gold they will nbot be able to move fast. do this by setting **simplebankraid_maxgold_slow 0** in your server console. (Default = 1)
Along with the above one if its set to 1 you can change the speed by setting **simplebankraid_maxgold_jumppower xxx** (Default = 10) and **simplebankraid_maxgold_runspeed xxx** (Default = 150) and **simplebankraid_maxgold_walkspeed xxx** (Default = 150) in your server console.
You can set the bar drop delay by setting **simplebankraid_bar_drop_delay xxx** in your server console. (Default = 5). The time between each bar being drop from the pallet.
You can set the bar drop limit by setting **simplebankraid_bar_drop_total xxx** in your server console. (Default = 40). This will end the raid once this many bars have dropped.
You can set the bar removal time by setting **simplebankraid_bar_remove xxx** in your server console. (Default = 15). This will remove the gold bar after this many seconds if uncollected to stop too many entities spawning.
You can set the gold bar drop delay by setting **simplebankraid_cooldown xxx** in your server console. (Default = 300)
You can set the pallet health by setting **simplebankraid_pallet_health xxx** in your server console. (Default = 2000). This is the health the pallet has before taking damage.
You can set the minimum players required online by setting **simplebankraid_min_players xxx** in your server console. (Default = 20). This is the minimum amount of players who need to be online for the bank to be raidable.
You can set the minimum cps required online by setting **simplebankraid_min_cps xxx** in your server console. (Default = 5). This is the minimum amount of cps who need to be online for the bank to be raidable. It will automatically count all CP jobs itsself and workout the count.
