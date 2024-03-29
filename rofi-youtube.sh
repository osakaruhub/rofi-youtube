if [ ! -f ~/.config/rofi-youtube/config.ini ]; then
  mkdir ~/.config/rofi-youtube
  touch ~/.config/rofi-youtube/config.ini
  echo "no configuration file found!\ncreated configuration file at ~/.config/rofi-youtube/config.ini"
  exit 0;
fi

no_video=false
# api_key=$(grep -E '^api-key\s*=' ~/.config/rofi-youtube/config.ini | sed -E 's/^api-key\s*=\s*//' | awk -F '=' '{print $2}' | tr -d ' ')
api_key=$(cat ~/.config/rofi-youtube/config.ini)

if [[ -z api_key ]]; then
  echo "no API Key found"
  exit 0;
fi

while getopts ":h:v:-n"; do
  case "option" in
    h)
      printf "%s\n"
             "Usage: rofi-youtube [OPTION] TARGET\n"
		    	   "\n"
		    	   "rofi frontend for youtube - search and play youtube content using rofi!\n"
		    	   "\n"
		    	   "Posible command options:\n"
		    	   "		        -h | --help       : Display this message\n"
             "		        -v | --version    : Print version and exit\n"
		    	   "\n";
		  exit 0;
      ;;
    v | --version)
      printf $RELEASE_VERSION
      return 0;
      ;;
    n | --no-video)
      no_video=true
      ;;
    *)
      printf "invalid option"
      exit 0;
      ;;
  esac
done

searchTerm=$(rofi -dmenu -mesg "search for video")
URL="https://youtube.googleapis.com/youtube/v3/search?part=snippet&q="$searchTerm"&type=video&key="$api_key
response=$(curl "$URL")

title=$(jq -r '.items[].snippet.title' <<< "$response" | rofi -dmenu)
videoId=$(jq --arg title "$title" -r '.items[] | select(.snippet.title == $title).id.videoId' <<< "$response")

mpv "https://www.youtube.com/watch?v=$videoId"
