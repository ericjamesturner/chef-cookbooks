# UniMRCP cookbook

This Chef cookbook installs UniMRCP from source and configures its basic settings.

# Requirements

Tested on Ubuntu 12.04, Debian 7.1 & CentOS 6.5.

# Usage

Add `recipe[unimrcp]` to your node's run list.

# Attributes

* `node['unimrcp']['version']` - the version of UniMRCP to install (default `1.1.0`)
* `node['unimrcp']['install_dir']` - the directory in which to install UniMRCP (default `/usr/local/unimrcp`)
* `node['unimrcp']['install_flite']` - wether or not to install the Flite plugin to UniMRCP Server for open-source TTS (default `false`)
* `node['unimrcp']['install_pocketsphinx']` - wether or not to install the PocketSphinx plugin to UniMRCP Server for open-source ASR (default `false`)

# Recipes

* `unimrcp` - Fetches and installs UniMRCP

# Author

[Ben Langfeld](@benlangfeld)
