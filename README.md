# polybar

shell scripts for polybar

| name                 | comment                                                         |
| :------------------- | :-------------------------------------------------------------- |
| polybar.sh           | start and toggle polybar                                        |
| polybar_bluetooth.sh | enable/disable bluetooth, show bluetooth status                 |
| polybar_firewall.sh  | enable/disable firewall and show firewall status                |
| polybar_gestures.sh  | enable/disable gestures and show gestures status                |
| polybar_polkit.sh    | enable/disable gnome authentication agent and show agent status |
| polybar_printer.sh   | enable/disable printer and show printer status                  |
| polybar_rss.sh       | shows the quantity of new articles in newsboat                  |
| polybar_vpn_hades.sh | enable/disable vpn and show vpn status                          |
| rss@.service         | systemd service to reveive rss feeds with newsboat              |
| rss@klassiker.timer  | systemd timer for rss@.service                                  |

config files: [dotfiles/polybar](https://github.com/mrdotx/dotfiles/tree/master/.config/polybar)

![monitor1](screenshot_monitor1.png)
![monitor2](screenshot_monitor2.png)
