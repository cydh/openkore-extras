## Simply BOT Vendor

0. If you don't have Openkore yet, you can download the latest version of [Openkore](https://github.com/OpenKore/openkore/archive/master.zip)
1. Copy `control` directory and rename it to `control_vendor1` (well, it's good practice for people that new in openkore, don't duplicate all openkore directory!)
2. Now open `control_vendor1` folder
3. Edit `config.txt`, just find these configs
```
attackAuto 0
attackAuto_party 0

route_randomWalk 0

teleportAuto_idle 0
teleportAuto_deadly 0

shopAuto_open 1
shop_random 0
shop_useSkill 1
```
4. Most vendors have lockmap set, so try it yours too
```
lockMap prontera
lockMap_x 140
lockMap_y 92
```
5. Now open `shop.txt`. The documentaion there is clear enough. But first, make sure the item that you want to sell is in the cart!
At the end of file, the first line is shop name. Example you want to sell Red Potion with 25z and the shop title is `Red Potions`
Make sure, after item name, use tab to give the price!
```
# Jellopy		3
# Andre Card	200,000		5
# Coconut	1,000..2,000	2

Red Potions

Red Potion		25
```
6. Now, make a shortcut of `start.exe`
7. Then right-click it > Properties
8. In Shortcut tab, add this string in `Target`.
> --control=control_vendor1 --logs=control_vendor1\logs
9. Now run the openkore using the shortcut
