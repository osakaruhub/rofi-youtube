Help()
{
  printf "%s\n"
  "Usage: rofi-youtube [OPTION] TARGET"
	""
	"rofi frontend for youtube - search and play youtube content using rofi!"
	"Posible command options:"
	"		       -h | --help             : Display this message"
  "		       -v | --version          : Print version and exit"
  "          -n | --no-video         : Play without video (only audio)"
  "          -c | --config <PATH>    : Use a different config"
  "          -e | --edit-config      : Edit the configuration file"
  "          -p | --player <PLAYER>  : Set multimedia player";
}

rofi_youtube_config=~/.config/rofi-youtube/config.ini
rofi_config=~/.config/rofi/config.rasi
no_video=false
verbose=false

while getopts ":hvncep:" option; do
  case $option in
    h | help)
      Help
		  exit;;
    v | version)
      # echo "rofi-youtube $RELEASE_VERSION"
      echo "rofi-youtube 1.0"
      exit;;
    n | no-video)
      no_video=true
      ;;
    c | config)
      if [[ -f "$OPTARG" ]]; then
        rofi_youtube_config=$OPTARG
      else
        echo "invalid config at $OPTARG" 
        exit
      fi
      ;;
    e | edit-config)
      $EDITOR $rofi_youtube_config
      exit;;
    p | player)
      default_player=$OPTARG
      ;;
    *)
      echo "invalid option -$option"
      exit;;
  esac
done

if [[ -f "$rofi_youtube_config" ]]; then
  . $rofi_youtube_config
else
  mkdir ~/.config/rofi-youtube
  cp /etc/rofi_config.ini $rofi_youtube_config
  printf "no configuration file found!\ncreated configuration file at $rofi_youtube_config" | rofi -c $rofi_config -dmenu
  exit 0;
fi

if [[ -z api_key ]]; then
  echo "no API Key found"
  api_key = $(rofi -c $rofi_config --pasword -p "set API Key")
  sed -i "s/api_key = .*/api_key = $api_key/" $rofi_youtube_config
  exit 0;
fi

searchTerm=$(rofi -c $rofi_config -dmenu -mesg "search for video")
# make search readable for youtube
searchTerm=$(echo "$searchTerm" | sed 's/ /%20/g; s/!/ %21/g; s/*/ %2A/g; s/'\''/ %27/g; s/(/ %28/g; s/)/ %29/g; s/;/ %3B/g; s/:/ %3A/g; s/@/ %40/g; s/&/ %26/g; s/=/ %3D/g; s/+/ %2B/g; s/\$/ %24/g; s/,/ %2C/g; s/\// %2F/g; s/?/ %3F/g; s/#/ %23/g; s/\[/ %5B/g; s/]/ %5D/g;')
URL="https://youtube.googleapis.com/youtube/v3/search?part=snippet&q="$searchTerm"&type=video&key="$api_key
response=$(curl -s "$URL")
if jq -r '.error' <<< "$response" &> /dev/null = "" ; then
  rofi -c $rofi_config -dmenu -mesg "$(printf $response | jq '.error.message')"
fi

title=$(jq -r '.items[].snippet.title' <<< "$response" | rofi -c $rofi_config -dmenu)
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
