# GitHub Pull Requests

<p align="center">
  <a href="https://github.com/fork-my-spoons/github-pull-requests.spoon/actions">
    <img alt="Build" src="https://github.com/fork-my-spoons/github-pull-requests.spoon/workflows/release/badge.svg"/></a>
  <a href="https://github.com/fork-my-spoons/github-pull-requests.spoon/issues">
    <img alt="GitHub issues" src="https://img.shields.io/github/issues/fork-my-spoons/github-pull-requests.spoon"/></a>
  <a href="https://github.com/fork-my-spoons/github-pull-requests.spoon/releases">
    <img alt="GitHub all releases" src="https://img.shields.io/github/downloads/fork-my-spoons/github-pull-requests.spoon/total"/></a>
</p>

A menu bar app, showing a list of pull requests assigned to a user to review:

<p align="center">
  <img src="https://github.com/fork-my-spoons/github-pull-requests.spoon/raw/main/screenshots/screenshot1.png"/>
</p>

Each item in the list is showing following information:

<p align="center">
  <img src="https://github.com/fork-my-spoons/github-pull-requests.spoon/raw/main/screenshots/screenshot2.png"/>
</p>

# Installation

 - install [Hammerspoon](http://www.hammerspoon.org/) - a powerfull automation tool for OS X
   - Manually:

      Download the [latest release](https://github.com/Hammerspoon/hammerspoon/releases/latest), and drag Hammerspoon.app from your Downloads folder to Applications.
   - Homebrew:

      ```brew install hammerspoon --cask```

 - download [github-pull-requests.spoon](https://github.com/fork-my-spoons/github-pull-requests.spoon/releases/latest/download/github-pull-requests.spoon.zip), unzip and double click on a .spoon file. It will be installed under `~/.hammerspoon/Spoons` folder.
 
 - open ~/.hammerspoon/init.lua and add the following snippet, with your repositories:

```lua
-- github pull requests
hs.loadSpoon("github-pull-requests")
spoon['github-pull-requests']:setup({
  reviewer = '<yout-github-username>'
  team_reviewer = '<org-name>/<team-name>'
})
spoon['github-pull-requests']:start()
```

This app uses icons, to properly display them, install a [feather-font](https://github.com/AT-UI/feather-font) by [downloading](https://github.com/AT-UI/feather-font/raw/master/src/fonts/feather.ttf) this .ttf font and installing it.
