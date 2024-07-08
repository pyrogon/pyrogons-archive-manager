#!/bin/bash

validate_url() {
    if [[ ! "$1" =~ ^https?:// ]]; then
        echo "Invalid URL. Please enter a valid URL."
        exit 1
    fi
}

# FUNCTION TO CREATE A NEW ARCHIVE
create_archive() {
    # This asks the user the name of the youtuber. This will create a string to name the new directory and input into directories.txt
    read -p "Enter the name of the YouTuber: " name_of_youtuber

    # This asks the user for the youtubers URL. PLEASE VIEW README.txt, this part is fucking stupid. No, I can't fix it.
    echo ""
    echo "https://www.streamweasels.com/tools/youtube-channel-id-and-user-id-convertor/"
    echo "Use this tool to get the URL, no, your web browsers URL is not valid"
    read -p "Enter the Youtubers channel URL: " channel_URL
    echo ""
    # This checks to make sure the users input is correct.
    validate_url "$channel_URL"

    # Creates a folder with the name of the youtuber using the name_of_youtuber string created earlier by the user
    mkdir -p "$name_of_youtuber"

    # Creates a file called archive.txt, view README.txt for more info
    touch "$name_of_youtuber/archive.txt"

    # Asks user for video resolution. README.txt has more information
    echo ""
    echo "Choose an option for video resolution:"
    echo "1. 720p"
    echo "2. 1080p"
    echo "3. Best available resolution"

    read -p "Enter your choice (1-3): " resolution_choice
    echo ""
    case $resolution_choice in
        1)
            resolution_option="-f 'bestvideo[height<=720]+bestaudio/best[height<=720]'"
            ;;
        2)
            resolution_option="-f 'bestvideo[height<=1080]+bestaudio/best[height<=1080]'"
            ;;
        3)
            resolution_option="-f 'bestvideo+bestaudio'"
            ;;
        *)
            echo "Invalid choice. Defaulting to best available resolution."
            resolution_option="-f 'bestvideo+bestaudio'"
            ;;
    esac

    # Creates a update.sh script with selected resolution
    cat > "$name_of_youtuber/update.sh" <<EOL
#!/bin/bash

# Ensure archive.txt exists
touch "archive.txt"

# yt-dlp command to download videos
yt-dlp $resolution_option --merge-output-format mp4 \\
    --download-archive "archive.txt" \\
    "$channel_URL"
EOL

    # Makes update.sh script executable
    chmod +x "$name_of_youtuber/update.sh"

    # Adds the new youtubers archive folder to directories.txt
    echo "$name_of_youtuber" >> directories.txt

    echo "Archive setup complete. To update the archive, run ./$name_of_youtuber/update.sh"
}

# Updates archive referencing directories.txt
update_all_archives() {
    echo "Updating all archives..."
    while IFS= read -r line; do
        if [ -d "$line" ] && [ -f "$line/update.sh" ]; then
            echo "Updating archive for $line..."
            (cd "$line" && ./update.sh)
        else
            echo "Directory $line or update.sh not found, skipping..."
        fi
    done < directories.txt
    echo "All archives updated."
}

# Removes an item from directories.txt, note, this does not delete the folder. It only prevents it from further updates. Remove manually
delete_from_directories() {
    echo ""
    echo "Current contents of directories.txt:"
    echo "------------------------------------"
    cat directories.txt
    echo ""

    read -p "Enter the name of the directory to delete: " directory_name

    # Check if the youtuber exists in directories.txt
    if grep -Fxq "$directory_name" directories.txt; then
        # Remove the youtuber from directories.txt
        sed -i "/^$directory_name\$/d" directories.txt
        echo "Directory '$directory_name' deleted from directories.txt."
    else
        echo "Directory '$directory_name' not found in directories.txt."
    fi
}

# Prints contents of directories.txt
print_directories() {
    echo ""
    echo "Contents of directories.txt:"
    echo "----------------------------"
    cat directories.txt
    echo ""
}

# Main menu
main_menu() {
    while true; do
        echo ""
        echo "Choose an option:"
        echo "1. Create a new archive"
        echo "2. Update all archives"
        echo "3. Delete an archive"
        echo "4. Print contents of directories.txt"
        echo "5. Exit"

        read -p "Enter your choice (1-5): " choice

        case $choice in
            1)
                create_archive
                ;;
            2)
                update_all_archives
                ;;
            3)
                delete_from_directories
                ;;
            4)
                print_directories
                ;;
            5)
                echo "Exiting."
                exit 0
                ;;
            *)
                echo "Invalid choice. Please enter a number from 1 to 5."
                ;;
        esac
    done
}

# Start the main menu loop
main_menu
