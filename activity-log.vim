""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" activity_log.vim
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Authors:      Andy Dawson <andydawson76 AT gmail DOT com>
" Version:      1.0.0
" Licence:      http://www.opensource.org/licenses/mit-license.php
"               The MIT License
" URL:          http://github.com/AD7six/vim-activity-log
"
"-----------------------------------------------------------------------------
"
" Section: Documentation
"
" The vim activity log plugin does one thing. it logs when you create, open or
" write a file. This provides you with a detailed log of what you've been up to.
" The activity log files are stored in the ~/activity/ directory by default (
" edit the s:LogActivity variable in this script) and are named as follows:
" YYYY/MM/DD.log
"
" The files are formatted in the following format:
"
" YYYY-MM-DD HH:MM:SS <action> /full/path/to/file
"
" The full date is included to allow concatenation and easier analysis

" Section: Plugin header
"
" loaded_activity_log is set to 1 when initialization begins, and 2 when it
" completes.

if exists('loaded_activity_log')
	finish
endif
let loaded_activity_log=1

" Section: Event group setup
" Log creating, opening and writing files
augroup ActivityLog
	au BufNewFile * call s:LogActivity('create')
	au BufReadPost * call s:LogActivity('open')

	au BufWritePost * call s:LogActivity('write')
augroup END

" Section: Script variables

" Where to store activity. setting to '' disables the log
let s:LogActivity = '~/activity/'

" Section: Utility functions
" These functions are not/should not be directly accessible

" Function: LogActivity()
" Log doing something
function s:LogActivity(action)
	if s:LogActivity == ''
		return
	endif

	let l:path = s:LogActivity . strftime('%Y/%m')

	:silent exe '! mkdir -p ' l:path

	let l:cmd = '!echo "' . strftime('%F %T') 
	let l:cmd = l:cmd . ' ' . a:action
	let l:cmd = l:cmd . ' ' . expand("%:p") . '"'
	:silent exe l:cmd . ' >> ' . l:path . '/' . strftime('%d') . '.log'
endfunction

" Section: Plugin completion
let loaded_activity_log=2