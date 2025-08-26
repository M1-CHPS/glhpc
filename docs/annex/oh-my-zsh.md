# Installing oh-my-zsh

Zsh is a powerful shell that can replace Bash. It provides better auto-completion, improved globbing, and an extensible configuration system.

oh-my-zsh is a community-driven framework for managing Zsh configuration. It comes with themes and plugins that make your console more productive.

### 1) Install Zsh
```sh title="Fedora"
sudo dnf install zsh
```

```sh title="Ubuntu/Debian"
sudo apt update
sudo apt install zsh
```

### 2) Install oh-my-zsh

Run the official installation script
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Or look up the command at [https://ohmyz.sh/#install](https://ohmyz.sh/#install)



### 3) Set Zsh as the default shell

```sh
chsh -s $(which zsh)
```

Note that you may have to log back in for changes to take effect.

### 4) Add plugins

Open the `~/.zshrc` file and find this line:
```
plugins=(git)
```

And change it to:
```
plugins=(git dnf pip zsh-syntax-highlighting zsh-autosuggestions)
```

Then run
```sh title="Fedora"
sudo dnf install zsh-syntax-highlighting zsh-autosuggestions
```


### 5) Optional: Set up powerlevel-10k

powerlevel-10k is a nice theme for oh-my-zsh which I highly recommend.

You can find up-to-date installation instructions at `https://github.com/romkatv/powerlevel10k`.
