[![Build Status](https://travis-ci.org/adyang/dotfiles.svg?branch=master)](https://travis-ci.org/adyang/dotfiles)

# Dotfiles

## Bootstrap
```console
bash <(curl --fail --silent --show-error --location https://raw.githubusercontent.com/adyang/dotfiles/master/bootstrap)
```
This will setup the dotfiles repository into the current directory.

There are 3 interactive prompts:
1. Passphrase for SSH key (either use Diceware or generate from external password manager)
    - The public key will be copied into your clipboard; you can paste it into repository services while the installation proceeds
2. Password for sudo
3. Pause after expected failure of first `brew bundle --verbose --file=Brewfile-kext`
    - Go to `Security & Privacy` > click on `Allow`
    - Press enter to resume rest of installation

## Manual Steps
### Import GPG Keys
Obtain required files from password manager or external source, then run:
```console
./import-gpg-keys --public-key <public-key-file> --secret-key <secret-key-file> --ownertrust <ownertrust-file>
```

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

