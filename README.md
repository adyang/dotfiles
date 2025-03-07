[![dotfiles](https://github.com/adyang/dotfiles/workflows/dotfiles/badge.svg)](https://github.com/adyang/dotfiles/actions?query=workflow%3Adotfiles)

# Dotfiles

## Bootstrap
```console
bash <(curl --fail --silent --show-error --location https://raw.githubusercontent.com/adyang/dotfiles/master/bootstrap)
```
This will setup the dotfiles repository into the current directory.

There are 5 blocking interactive prompts:
1. Passphrase for SSH key (either use Diceware or generate from external password manager)
    - The public key will be copied into your clipboard; you can paste it into repository services while the installation proceeds
2. Password for sudo
3. Pause after expected failure of first `brew bundle --verbose --file=Brewfile-kext`
    - Go to `Security & Privacy` > click on `Allow`
    - Press enter to resume rest of installation
4. Pause on installation of VS Code
    - Click `OK`
    - Go to `Security & Privacy` > click on `Open Anyway`
    - On dialog, click `Open`
    - If installation of VS Code extension fails, rerun install/ bootstrap script
5. Pause during configuration of MacOS
    - Dialog `"Terminal.app" wants access to control "System Events.app"...` appears
    - Click `OK`

And 1 non-blocking prompt to set the default browser.

## Manual Steps
### Enable FileVault
```console
sudo fdesetup enable
```

### Import GPG Keys
Obtain required files from password manager or external source, then run:
```console
./import-gpg-keys --public-key <public-key-file> --secret-key <secret-key-file> --ownertrust <ownertrust-file>
```

### Configure Additional SSH Keys
For each additional key:
1. Generate new SSH Key Pair, e.g. assuming key-filename `id_ed25519_suffix`:
    ```console
    ./generate-ssh-keys --key-filename id_ed25519_suffix
    ```
2. Paste copied public key into corresponding repository services
3. Obtain its SSH configuration file from password manager or external source, and copy it into `${HOME}/.ssh/config.d/` directory.

### Configure Finder Sidebar (No Easy Way to Automate)
1. Open Finder > `Cmd + ,` to open Finder Preferences.
2. `Sidebar` > Under `Favorites`, tick home directory.
3. Under `Locations`, untick iCloud Drive and tick your computer's name.
4. Under `Tags`, untick all.

### Prevent Spotlight from Indexing new Mounted Volumes (Automation not Working in Mojave)
1. Go to `Spotlight` System Preferences > `Privacy`.
2. Click `+` > `Cmd + Shift + .` to show hidden files.
3. Navigate to root HD and select `/Volumes`.

### Configure Maccy Max Menu Item Length (Automation setting only works on UI Activation)
1. Open Maccy > `Cmd + ,` to open Preferences.
2. Under `Appearance` > Click on `Title Length` input box to focus on it.
3. Move focus to another field, e.g. `Number of items` > Exit Preferences.
4. Verify max menu item length setting is applied.

### Disable System Shortcuts that Opens Terminal to Prevent Conflicts With IntelliJ (Automation via plist not Working)
1. Go to `Spotlight` System Preferences > `Keyboard`.
2. Under `Shortcuts` tab, click `Services`.
3. Untick `Open man Page in Terminal`.
4. Untick `Search man Page Index in Terminal`.

### IntelliJ Settings
1. Open `./intellij-plugins` project > `Required plugins weren't loaded` dialog on bottom-right > click `Install required plugins` to install plugins > click `Restart` IDE.
1. Navigate to GitHub > `Settings` > `Developer settings` > `Personal access tokens` > `Tokens (classic)` > click on `Generate new token (classic)`.
1. Enter `Note` > tick `repo` > click `Generate token` > copy access token.
1. `Cmd/Ctrl + Shift + A` to open `Actions` > type and select `Settings Repository...` > paste HTTPS url of settings repo and click `Overwrite Local` > enter access token.
1. `Cmd/Ctrl + Shift + A` to open `Actions` > type and select `Keymap` > select desired default keymap.

### Enable Firefox Extensions
The Firefox extensions installed via the scripts are disabled by default. To enable them:
1. Navigate to `about:addons`.
2. Click on the triple dot `...` on one of the extensions > `Enable`.
3. Click `Enable` again on the popup dialog.
4. Tick `Allow this extension to run in Private Windows` > `Okay, Got It` on another popup dialog.
5. Repeat for the rest of the disabled extensions.

### Import/ Configure Temporary Containers Extension Preferences
1. Navigate to `about:addons`.
2. Click on the `...` on the Temporary Containers extension > `Preferences`.
3. Click on the `Export/Import` tab.
4. Click `Import from Firefox Sync`.

### Enable Firefox Containers Bookmark Menus
1. Navigate to `about:addons`.
2. Click on the `...` on the Firefox Multi-Account Containers extension > `Preferences`.
3. Tick `Enable Bookmark Menus` > `Allow` `Read and modify bookmarks` permission in popup dialog.

### Configure Default Firefox Search Engine
1. Navigate to target search engine site.
2. Click on the triple dot `...` to the right of the address bar > `Add Search Engine`.
3. Navigate to `about:preferences#search`
4. Under `Default Search Engine` > select target search engine.

### Reboot System
Reboot system in order for MacOS updates to complete:
```console
sudo shutdown -r now
```

## Testing
Run all tests:
```console
./test/run-tests
```
Run specific test(s):
```console
./test/run-tests <paths/to/bats/file ...>
```
Watch all tests:
```console
./test/watch-tests
```
Watch specific test(s):
```console
./test/watch-tests <paths/to/bats/file ...>
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
