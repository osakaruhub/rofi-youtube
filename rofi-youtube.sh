rofi_youtube_path=~/.config/rofi-youtube/config.ini
rofi_config_path=~/.config/rofi/config.rasi


if [[ -f "$rofi_youtube_path" ]]; then
  . $rofi_youtube_path
else
  mkdir ~/.config/rofi-youtube
  cp /etc/rofi_config.ini $rofi_youtube_path
  rofi -c rofi_config_path -dmenu -mesg "no configuration file found!\ncreated configuration file at $rofi_youtube_path"
  exit 0;
fi

no_video=false
verbose=false

if [[ -z api_key ]]; then
  echo "no API Key found"
  api_key = $(rofi -c $rofi_config_path --pasword -p "set API Key")
  sed -i "s/api_key = .*/api_key = $api_key/" $rofi_youtube_path
  exit 0;
fi

while getopts ":h:v:-V:-n:c:"; do
  case "option" in
    h)
      printf "%s\n"
             "Usage: rofi-youtube [OPTION] TARGET\n"
		    	   "\n"
		    	   "rofi frontend for youtube - search and play youtube content using rofi!\n"
		    	   "\n"
		    	   "Posible command options:\n"
		    	   "		        -h | --help     : Display this message\n"
             "		        -v | --version  : Print version and exit\n"
             "            -c | --config   : Edit the configuration file"
             "            -V | --verbose  : Debug output"
		    	   "\n";
		  exit 0;
      ;;
    v | --version)
      printf $RELEASE_VERSION
      return 0;
      ;;
    V | --verbose)
      verbose=true
      ;;
    n | --no-video)
      no_video=true
      ;;
    c)
      if [ -x "(command -v nano)" ]; then
        nano $rofi_youtube_path
      else
        vim $rofi_youtube_path
      fi
      ;;
    *)
      printf "invalid option"
      exit 0;
      ;;
  esac
done

searchTerm=$(rofi -c $rofi_config_path -dmenu -mesg "search for video")
# make search readable for youtube
searchTerm=$(echo "$searchTerm" | sed 's/ /%20/g; s/!/ %21/g; s/*/ %2A/g; s/'\''/ %27/g; s/(/ %28/g; s/)/ %29/g; s/;/ %3B/g; s/:/ %3A/g; s/@/ %40/g; s/&/ %26/g; s/=/ %3D/g; s/+/ %2B/g; s/\$/ %24/g; s/,/ %2C/g; s/\// %2F/g; s/?/ %3F/g; s/#/ %23/g; s/\[/ %5B/g; s/]/ %5D/g;')
URL="https://youtube.googleapis.com/youtube/v3/search?part=snippet&q="$searchTerm"&type=video&key="$api_key
if [[ $verbose=true ]]; then
  echo "$URL"
fi
response=$(curl "$URL")

title=$(jq -r '.items[].snippet.title' <<< "$response" | rofi -c $rofi_config_path -dmenu)
videoId=$(jq --arg title "$title" -r '.items[] | select(.snippet.title == $title).id.videoId' <<< "$response")
if [[ $verbose = true ]]; then
  echo "videoID: $videoId"
fi

videoBool=""
if [ "$no_video" = true ]; then
  videoBool="--no-video"
fi
if [[ -z "$default_player" ]]; then
  mpv $videoBool "https://www.youtube.com/watch?v=$videoId"
else
  eval $default_player $videoBool "https://www.youtube.com/watch?v=$videoId"
fi
