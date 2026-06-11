if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_greeting
    fastfetch -c /usr/share/fastfetch/presets/paleofetch.jsonc
end

function fish_command_not_found
    set -l cmd $argv[1]

    set_color red
    echo "Oops! Command '$cmd' is not here!"
    set_color normal

    read -l -n 1 -P "Do you want to search for it in Homebrew? [y/N]: " response

    if string match -ri 'y' $response
        echo ""
        echo "Searching for '$cmd' in brew..."

        set -l search_result (brew search $cmd 2>/dev/null)

        if test -n "$search_result"
            set_color green
            echo "Found packages:"
            set_color normal
            echo $search_result | tr " " "\n"
        else
            set_color yellow
            echo "Not found in brew, you can try distrobox."
            set_color normal
        end
    end
end

set EDITOR micro
