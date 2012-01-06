Vim Activity Log ![Project status](http://stillmaintained.com/AD7six/vim-activity-log.png?20120106)
=========================

This vim plugin is used to keep track of what and when you do things.

# Installation

	cd ~
	git clone git://github.com/AD7six/vim-activity-log.git
	ln -s vim-activity-log/plugin/activity-log.vim ~/.vim/plugin/

# Usage

The plugin is automatic, and will create log files of your vim actions in: `~/activity/YYYY/MM/DD.log`
If you prefer a different location for your logs - you can define `g:activity_log_location` in your
.vimrc file

The format for entries in the log files is:

	Y-m-d H:i:s;action;/full/path/to/file;git-branch

The git-branch is only added if a branch can be determined.

# Changelog

* 1.0.0 Intial release
* 1.1.0 Only write create/open entries if the file is edited
* 1.2.0 Append current git branch, changed delimiter from space to semi-colon
* 1.2.1 Correct git branch parsing
* 1.3.0 Restructure parameters, use a pattern not a fixed file location, allow setting from outside
	the plugin
