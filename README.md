[![Build Status](https://travis-ci.org/adyang/dotfiles.svg?branch=master)](https://travis-ci.org/adyang/dotfiles)

# Dotfiles

## Bootstrap
```console
bash <(curl --fail --silent --show-error --location https://raw.githubusercontent.com/adyang/dotfiles/master/bootstrap)
```
This will setup the dotfiles repository into the current directory.

There are 3 blocking interactive prompts:
1. Passphrase for SSH key (either use Diceware or generate from external password manager)
    - The public key will be copied into your clipboard; you can paste it into repository services while the installation proceeds
2. Password for sudo
3. Pause after expected failure of first `brew bundle --verbose --file=Brewfile-kext`
    - Go to `Security & Privacy` > click on `Allow`
    - Press enter to resume rest of installation

And 1 non-blocking prompt to set the default browser.

## Manual Steps
### Import GPG Keys
Obtain required files from password manager or external source, then run:
```console
./import-gpg-keys --public-key <public-key-file> --secret-key <secret-key-file> --ownertrust <ownertrust-file>
```

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

### Reboot System
Reboot system in order for MacOS updates to complete:
```console
sudo shutdown -r now
```

## References
1. https://github.com/trptcolin/dotfiles
2. https://github.com/sam-hosseini/dotfiles
3. https://github.com/mathiasbynens/dotfiles
4. https://github.com/holman/dotfiles
5. https://github.com/TimMoore/dotfiles

