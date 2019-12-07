[![Build Status](https://travis-ci.org/adyang/dotfiles.svg?branch=master)](https://travis-ci.org/adyang/dotfiles)

# Dotfiles

## Bootstrap
```console
bash <(curl --fail --silent --show-error --location https://raw.githubusercontent.com/adyang/dotfiles/master/bootstrap)
```
This will setup the dotfiles repository into the current directory.

There are 4 blocking interactive prompts:
1. Passphrase for SSH key (either use Diceware or generate from external password manager)
    - The public key will be copied into your clipboard; you can paste it into repository services while the installation proceeds
2. Password for sudo
3. Pause after expected failure of first `brew bundle --verbose --file=Brewfile-kext`
    - Go to `Security & Privacy` > click on `Allow`
    - Press enter to resume rest of installation
4. Pause during configuration of MacOS
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

### Configure Finder Sidebar (No Easy Way to Automate)
1. Open Finder > `Cmd + ,` to open Finder Preferences.
2. `Sidebar` > Under `Favorites`, tick home directory.
3. Under `Locations`, untick iCloud Drive and tick your computer's name.
4. Under `Tags`, untick all.

### Prevent Spotlight from Indexing new Mounted Volumes (Automation not Working in Mojave)
1. Go to `Spotlight` System Preferences > `Privacy`.
2. Click `+` > `Cmd + Shift + .` to show hidden files.
3. Navigate to root HD and select `/Volumes`.

### IntelliJ Settings
1. Navigate to GitHub > `Settings` > `Developer settings` > `Personal access tokens` > click on `Generate new token`.
2. Enter description > tick `repo` > click `Generate token` > copy access token.
3. In IntelliJ, navigate `Configure` > `Settings Repository`, paste HTTPS url of settings repo and enter access token.
4. Open `./intellij-plugins` project > `Required plugins weren't loaded` dialog on bottom-right > click `Install required plugins` to install plugins.

### Enable Firefox Extensions
The Firefox extensions installed via the scripts are disabled by default. To enable them:
1. Navigate to `about:addons`.
2. Click on the triple dot `...` on one of the extensions > `Enable`.
3. Click `Enable` again on the popup dialog.
4. Tick `Allow this extension to run in Private Windows` > `Okay, Got It` on another popup dialog.
5. Repeat for the rest of the disabled extensions.

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
Start virtual machine:
```console
vagrant up
```
Sync files into /vagrant folder in another terminal:
```console
vagrant rsync-auto
```
Consider taking a snapshot of the fresh installation:
```console
vagrant snapshot save fresh-install
```
Run bootstrap via standard instructions:
```console
vagrant ssh
eval "$(ssh-agent -s)"
bash <(curl --fail --silent --show-error --location https://raw.githubusercontent.com/adyang/dotfiles/master/bootstrap)
```
Run install script (note to clean up symlinked files or reset snapshot if standard bootstrap was previously run):
```console
vagrant ssh -c '/Users/Shared/vagrant/install' <<<$'vagrant\n'
```
Restore snapshot:
```console
vagrant snapshot restore fresh-install
```

### Workaround Development Issues
If `vagrant up` keeps failing because of box download, use the following command to keep retrying:
```console
while ! vagrant box add apscommode/macos-10.14; do : ; done
```
Also if using macOS, consider keeping the display on:
```console
caffeinate -d
```

### Creating macOS Vagrant Boxes
[macinbox](https://github.com/bacongravy/macinbox) is used to create macOS Vagrant Box.

[installinstallmacos.py](https://github.com/munki/macadmin-scripts/blob/master/installinstallmacos.py) is used to download a macOS installer disk image.

1. Download desired disk image:
    ```console
    installinstallmacos.py
    ```
    Select desired installer and choose build base on host hardware.

2. Install macinbox:
    ```console
    sudo gem install macinbox
    ```

3. Create macOS Vagrant Box, e.g.:
    ```console
    sudo macinbox --name macos-10.14 --box-format virtualbox --memory 4096 --installer-dmg <path/to/downloaded/disk/image>
    ```

## References
1. https://github.com/trptcolin/dotfiles
2. https://github.com/sam-hosseini/dotfiles
3. https://github.com/mathiasbynens/dotfiles
4. https://github.com/holman/dotfiles
5. https://github.com/TimMoore/dotfiles
