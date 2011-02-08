Vim Activity Log
=========================

This vim plugin is used to keep track of what and when you do things.

# Installation

	cd ~
	git clone git://github.com/AD7six/vim-activity-log.git
	ln -s vim-activity-log/activity-log.vim ~/.vim/plugins/

# Usage

The plugin is automatic, and will create log files of your vim actions in: `~/activity/YYYY/MM/DD.log`

The format for entries in the log files is:

	Y-m-d H:i:s action /full/path/to/file

# Changelog

1.0.0 Intial release