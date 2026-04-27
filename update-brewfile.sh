#!/bin/zsh

BREWFILE = $(git rev-parse --show-toplevel)/.config/Brewfile

brew bundle dump --describe --force --file=$BREWFILE
