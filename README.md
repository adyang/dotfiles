[![dotfiles](https://github.com/adyang/dotfiles/workflows/dotfiles/badge.svg)](https://github.com/adyang/dotfiles/actions?query=workflow%3Adotfiles)

# Dotfiles
## Prerequisites
1. Give Terminal Disk Access to avoid installation failure:
    * Go to `Privacy & Security` system preferences > `Full Disk Access` > click `+` and authenticate > select `Applications/Utilities/Terminal.app` > click `Open`

## Bootstrap
```console
bash <(curl --fail --silent --show-error --location https://raw.githubusercontent.com/adyang/dotfiles/master/bootstrap)
```
This will setup the dotfiles repository via [chezmoi](https://www.chezmoi.io/).

There are a few blocking interactive prompts:
1. Prompt to sign in to 1Password and to turn on 1Password CLI integration.
1. Password for sudo during brewing of apps
1. Pause during configuration of MacOS
    - Dialog `"Terminal.app" wants access to control "System Events.app"...` appears
    - Click `OK`

And 1 non-blocking prompt to set the default browser.

## Manual Steps
### Enable FileVault
```console
sudo fdesetup enable
```

### Configure Finder Sidebar (No Easy Way to Automate)
1. Open Finder > `Cmd + ,` to open Finder Preferences.
2. `Sidebar` > Under `Favorites`, tick home directory.
3. Under `Locations`, untick iCloud Drive and tick your computer's name.
4. Under `Tags`, untick all.

### Configure Spotlight Search results (Automation causes System Prefs UI Issue in macOS Sequoia)
1. Go to `Spotlight` System Preferences.
2. Ensure only the following is ticked (untick the rest):
    * Applications
    * Calculator
    * Folders
    * System Settings

### Disable System Shortcuts that Opens Terminal to Prevent Conflicts With IntelliJ (Automation via plist not Working)
1. Go to `Spotlight` System Preferences > `Keyboard`.
2. Under `Shortcuts` tab, click `Services`.
3. Untick `Open man Page in Terminal`.
4. Untick `Search man Page Index in Terminal`.

### Enable Firefox Extensions
The Firefox extensions installed via the scripts are disabled by default. To enable them:
1. Navigate to `about:addons`.
2. Click on the triple dot `...` on one of the extensions > `Enable`.
3. Click `Enable` again on the popup dialog.
4. Tick `Allow this extension to run in Private Windows` > `Okay, Got It` on another popup dialog.
5. Repeat for the rest of the disabled extensions.

### Import/ Configure Temporary Containers Extension Preferences
1. Login to Firefox Sync.
2. Navigate to `about:addons`.
3. Click on the `...` on the Temporary Containers extension > `Preferences`.
4. Click on the `Export/Import` tab.
5. Click `Import from Firefox Sync`.

### Enable Firefox Containers Bookmark Menus
1. Navigate to `about:addons`.
2. Click on the `...` on the Firefox Multi-Account Containers extension > `Preferences`.
3. Tick `Enable Bookmark Menus` > `Allow` `Read and modify bookmarks` permission in popup dialog.
4. Tick `Enable synchronization`.

### IntelliJ Settings
1. Open `./intellij-plugins` project > `Required plugins weren't loaded` dialog on bottom-right > click `Install required plugins` to install plugins > click `Restart` IDE.
1. Navigate to GitHub > `Settings` > `Developer settings` > `Personal access tokens` > `Tokens (classic)` > click on `Generate new token (classic)`.
1. Enter `Note` > tick `repo` > click `Generate token` > copy access token.
1. `Cmd/Ctrl + Shift + A` to open `Actions` > type and select `Settings Repository...` > paste HTTPS url of settings repo and click `Overwrite Local` > enter access token.
1. `Cmd/Ctrl + Shift + A` to open `Actions` > type and select `Keymap` > select desired default keymap.

### Reboot System
Reboot system in order for MacOS updates to complete:
```console
sudo shutdown -r now
```

## Development
### Development Commands
Due to the way macOS is setup, it has become very difficult to start a new version of macOS on an older version of macOS for local development.
Hence, the way forward would be to just test the installation on CI with macOS runners.

## References
1. https://github.com/trptcolin/dotfiles
2. https://github.com/sam-hosseini/dotfiles
3. https://github.com/mathiasbynens/dotfiles
4. https://github.com/holman/dotfiles
5. https://github.com/TimMoore/dotfiles
