---
layout: post
title:  The ultimate .profile of ultimate destiny
image: /assets/article_images/profile.png
date:   2018-04-05 16:00:00
tags:
- code
- bash
- profile
- mac
---
I have released version [1.4 of my .profile](https://gist.github.com/usbsnowcrash/a391fd6cea9f07ed16a959e7a21eb86c) that I use on my macs for development.  It ensures that certain homebrew packages are installed, my prefered font is on the system, that anyenv is installed and up to date for managing my installed development languages.  The goal is to get close to being able to drop this on any mac and have my dev env spring back to life.


This version includes some checks that make sure we only perform software install steps once per machine and anyenv updates once per week.  This is accomplished with a couple of checks like these
```bash
# Keep language managers up to date once per week
find ~/.anyenvupdatedate -mtime +7 -exec rm {} \;
if [ ! -f ~/.anyenvupdatedate ]; then
	printf "\n\n⚙️ Keep languges up to date \n"
    anyenv update
    touch ~/.anyenvupdatedate
fi
```

## Variables needed for development
```bash
# Some exports for development
export HOMEBREW_GITHUB_API_TOKEN=TOKEN_GOES_HERE
export DATABASE_URL=postgres://localhost
```

## Is homebrew installed?
```bash
# Make sure brew itself is installed
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    printf "\033[0;31mbrew "
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    # brew is already installed
    printf "\033[1;32mbrew "
fi
```

## Development packages
```bash
for pkg in git bash-completion bash-git-prompt phantomjs cask gist jq redis wget curl openssl postgres; do
    if brew list -1 | grep -q "^${pkg}\$"; then
        printf "\033[1;32m$pkg "
        
    else
        printf "\033[0;31m$pkg "
        brew install ${pkg}
    fi
```
## Ensure that anyenv is present
```bash
# Check for anyenv (multi language manager)
if [ -d ~/.anyenv/bin ]; then 
    printf "\033[1;32manyenv "
else
    printf "\033[0;31manyenv "
    git clone https://github.com/riywo/anyenv ~/.anyenv 
fi

if [ -d ~/.anyenv/plugins/anyenv-git ]; then 
    printf "\033[1;32manyenv-git "
else
    printf "\033[0;31manyenv-git "
    mkdir -p ~/.anyenv/plugins
    git clone https://github.com/znz/anyenv-git.git ~/.anyenv/plugins/anyenv-git
fi

if [ -d ~/.anyenv/plugins/anyenv-update ]; then 
    printf "\033[1;32manyenv-update "
else
    printf "\033[0;31manyenv-update "
    mkdir -p ~/.anyenv/plugins
    git clone https://github.com/znz/anyenv-update.git ~/.anyenv/plugins/anyenv-update
fi
```

## Ensure my prefered font is on the system
```bash
# Casks are handled a little differentlly 
for pkg in font-inconsolata; do
    if brew cask list -1 | grep -q "^${pkg}\$"; then
        printf "\033[1;32m$pkg "
        echo "Package '$pkg' is installed"
    else
        printf "\033[0;31m$pkg "
        brew tap caskroom/fonts
        brew cask install ${pkg}
    fi
done
```    
## Turn on bash completion, git prompt
```bash
# Autocomplete git branch names and such
printf "\n\033[1;97m🌈 Enabling \n"
printf "bash completion "
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

printf "git branch completion "
source /usr/local/etc/bash_completion.d/git-completion.bash

# Special command prompt to show github info
printf "git prompt "
if [ -f /usr/local/share/gitprompt.sh ]; then
  GIT_PROMPT_THEME=Default
  . /usr/local/share/gitprompt.sh
fi
```

## Make sure anyenv is managing my languages and stays up to date
```bash
# Enable anyenv
printf "anyenv "
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

printf "\n\n⚙️ Keep languges up to date \n"
anyenv update
touch ~/.anyenvupdatedate
```

I welcome feedback.  I am still trying to figure out how I would make sure vscode and rubymine is on the machine.