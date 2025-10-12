enable-cosmic-repo:
  echo "Adding COSMIC repo"
  flatpak remote-add --if-not-exists --user cosmic https://apt.pop-os.org/cosmic/cosmic.flatpakrepo
  echo "Adding Flathub user (needed for COSMIC repo to work)"
  flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  
post-install:
  # Add brew taps
  brew tap existingperson08/tap
  brew tap ublue-os/tap

  # Add Flathub
  flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo

  # Update
  flatpak update
  brew update

  # Install apps
  brew install bbrew better-pkg
  flatpak install --system -y dev.edfloreshz.CosmicTweaks io.github.flattool.Warehouse io.github.kolunmi.Bazaar com.ranfdev.DistroShelf org.gnome.FileRoller com.github.tchx84.Flatseal be.alexandervanhee.gradia org.gnome.Calculator page.kramo.Cartridges
  echo "Post install setup finished!"
