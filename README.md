# polybar

shell scripts for polybar

![monitor1](images/monitor1.png)
![monitor2](images/monitor2.png)

| folder  | comment                       |
| :------ | :---------------------------- |
| images  | images for the README.md file |

| file                   | comment                                                                 | image                                                                                                       |
| :--------------------- | :---------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------- |
| _polybar_helper.sh     | used in the other scripts for output, net check, etc.                   |                                                                                                             |
| polybar.sh             | start, restart, kill and cycle polybars                                 |                                                                                                             |
| polybar_freshrss.sh    | shows the number of rss feeds (unreaded/starred) from freshrss          | ![rss polybar](images/rss_polybar.png)                                                                      |
| polybar_inoreader.sh   | shows the number of rss feeds (unreaded/starred) from inoreader         | ![rss polybar](images/rss_polybar.png)                                                                      |
| polybar_music.sh       | cmus statusbar and notification                                         | ![cmus polybar](images/cmus_polybar.png) ![cmus notify](images/cmus_notify.png)                             |
| polybar_openweather.sh | shows current/forecast weather and sunrise/sunset time from openweather | ![openweather polybar](images/openweather_polybar.png) ![openweather notify](images/openweather_notify.png) |
| polybar_pacman.sh      | shows the number of package updates from pacman/aur                     | ![pacman polybar](images/pacman_polybar.png)                                                                |
| polybar_services.sh    | shows the status of defined services                                    | ![services polybar](images/services_polybar.png)                                                            |
| polybar_trash-cli.sh   | shows the number of trash items                                         | ![trash polybar](images/trash_polybar.png)                                                                  |

config files:

- [dotfiles/polybar](https://github.com/mrdotx/dotfiles/tree/master/.config/polybar)
- [dotfiles/i3](https://github.com/mrdotx/dotfiles/tree/master/.config/i3)
- [dotfiles/cmus](https://github.com/mrdotx/dotfiles/tree/master/.config/cmus)
- [dotfiles/xresource](https://github.com/mrdotx/dotfiles/tree/master/.config/X11)
- [dotfiles/systemd](https://github.com/mrdotx/dotfiles/tree/master/.config/systemd/user)
