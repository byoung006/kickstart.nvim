# kickstart.nvim

## Introduction

This is my pride and joy. 

This config has been given more of my time than my dog, my wife, and probably god...

...take a look if you're a member of the 9th circle of vim. 

> **NOTE**

#### Read The Friendly Documentation

Read through the `init.lua` file in the configuration folder for more
information about my extension and plugin configuration.
> [!NOTE]
> For more information about a particular plugin check its repository's documentation - use google yo....or ask chat-gipity.


### Getting Started

[The Only Video You Need to Get Started with Neovim](https://youtu.be/m8C0Cq9Uv9o)


### Install Recipes

> Because you should be using linux if you can.
#### Linux Install
<details><summary>Ubuntu Install Steps - for the plebs like myself</summary>

```
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install make gcc ripgrep unzip git xclip neovim
```
</details>
<details><summary>Debian Install Steps - you okay bro? </summary>

```
sudo apt update
sudo apt install make gcc ripgrep unzip git xclip curl

# Now we install nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo mkdir -p /opt/nvim-linux-x86_64
sudo chmod a+rX /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

# make it available in /usr/local/bin, distro installs to /usr/bin
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/
```
</details>
<details><summary>Fedora Install Steps</summary>

```
sudo dnf install -y gcc make git ripgrep fd-find unzip neovim
```
</details>

<details><summary>Arch Install Steps - Because I use arch</summary>

```
sudo pacman -S --noconfirm --needed gcc make git ripgrep fd unzip neovim
```
</details>

