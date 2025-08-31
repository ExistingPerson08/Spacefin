enable-cosmic-repo:
  echo "Adding COSMIC repo"
  flatpak remote-add --if-not-exists --user cosmic https://apt.pop-os.org/cosmic/cosmic.flatpakrepo
  echo "Adding Flathub user (needed for COSMIC repo to work)"
  flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  
