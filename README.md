# rofi-youtube

<p>search for youtube content using the rofi frontend<br>
searching for youtube videos that you already know the title in the website may seem clunky, and slow sometimes. rofi-youtube aims to be a fast frontend for searching youtube links.</p>

# Features

- search for any youtube video
- watch from mpv (soon more!) or just listen
- use your favorite multimedia player such as mpv or vlc!
- video & search history

# Installation

Download the rofi-youtube executable and run it, it's as easy as that.
Be sure to put in your Youtube Data API Key in the config first.

# Configuration

The default path for the configuration file is ~/.config/rofi-youtube/config.ini.<br>
possible condifguration:
| field | default value |
|--------------- | --------------- |
| api_key | N/A |
| default_player | mpv |
| rofi_config_path | ~/.config/rofi |
| rofi_file | ~/.cache/rofi-youtube |
| cache_file_size | 50 |

# Dependencies

[rofi](https://github.com/davatorium/rofi) (awesome menu dialog, dmenu alternative)<br>
[mpv](https://github.com/mpv-player/mpv) (simple light-weight multimedia player)
[jq](https://github.com/jqlang/jq) (powerful JSON processor)

# Contributors

<p>Just me for the moment.<br>
Feel free to contribute though.</p>
