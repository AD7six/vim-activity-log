""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" activity_log.vim
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Authors:      Andy Dawson <andydawson76 AT gmail DOT com>
"               Sofia Cardita <sofiacardita AT gmail DOT com>
" Version:      1.3.0
" Licence:      http://www.opensource.org/licenses/mit-license.php
"               The MIT License
" URL:          http://github.com/AD7six/vim-activity-log
"
"-----------------------------------------------------------------------------
"
" Section: Documentation
"
" The vim activity log plugin logs when you create, open or write a file.
"
" This provides you with a detailed log of what you've been up to. By default
" the activity log files are stored in the ~/activity/ directory and are named
" as follows: YYYY/MM/DD.log
" You can change the log file locations by defining g:activity_log_location
" to a pattern to suit your needs. The pattern is passed to strftime
"
" The files are formatted in the following format:
"
" YYYY-MM-DD HH:MM:SS;<action>;/full/path/to/file;git-branch
" 
" Calling <leader>s (start_task), <leader>i (interval_task), 
" <leader>c (continue_task), <leader>e (end_task) writes 
" the current line to the log file as the last item
" resulting in a line as such
"
" YYYY-MM-DD HH:MM:SS;<action>_task;/full/path/to/file;git-branch;<current line 
" text>
"
" This allows for finer-grained statistics data for time-tracking reports.
"
" The full date is included to allow concatenation and easier analysis

" Section: Plugin header
"
" loaded_activity_log is set to 1 when initialization begins, and 2 when it
" completes.

if exists('g:loaded_activity_log')
	finish
endif
let g:loaded_activity_log=1

" Section: Event group setup
" Log creating, opening and writing files
augroup ActivityLog
	au BufNewFile * call s:LogAction('create')
	au BufReadPost * call s:LogAction('open')

	au BufWritePost * call s:LogAction('write')
augroup END


" Section: Line log setup
" Log create, interval/break, continue, end task
"" sets ,ls mapping to log current line as start of task in .log files
"" sets ,le mapping to log current line as end of task in .log files
nmap <silent> <Leader>ls :call TimeLogLine('start_task')<CR>
nmap <silent> <Leader>le :call TimeLogLine('end_task')<CR>
nmap <silent> <Leader>li :call TimeLogLine('interval_task')<CR>
nmap <silent> <Leader>lc :call TimeLogLine('continue_task')<CR>

" Section: Script variables

" Where to store activity. setting to '' disables the log, effectively
" disabling the plugin
if !exists('g:activity_log_location')
	let g:activity_log_location = '~/activity/%Y/%m/%d.log'
endif
" append the current git branch to log?
if !exists('g:activity_log_append_git_branch')
	if !executable("git")
		let g:activity_log_append_git_branch = 0
	else
		let g:activity_log_append_git_branch = 1
	endif
endif


" stack of unsaved log entries. Used to log open and create entries for
" delayed inserting into the log upon write
let s:UnsavedStack = {}

" Section: Utility functions
" These functions are not/should not be directly accessible

" Function: LogAction()
"
" Log doing something. If the action is not 'write' it is saved without
" writing to the activity log. If the file is closed before writing no action
" is taken. Otherwise, when the file is written the saved entry of
" opening/creating the file is also added to the activity log.
" If s:LogGitBranch is true, the git branch at the time of writing is appended
" to the log entry
function s:LogAction(action)
	if g:activity_log_location == ''
		return
	endif

	let l:file = fnameescape(expand("%:p"))
	if empty(l:file)
		return
	endif
	let l:time = strftime('%Y-%m-%d %H:%M:%S')

	if a:action != "write"
		if !has_key(s:UnsavedStack, l:file)
			let s:UnsavedStack[l:file] = {}
		endif
		let s:UnsavedStack[l:file][a:action] = l:time
		return
	endif

	if len(s:UnsavedStack) && has_key(s:UnsavedStack, l:file)
		for [key, value] in items(s:UnsavedStack[l:file])
			let l:message = value . ' ' . key  . ' ' . l:file
			call s:WriteLogAction(l:message)
		endfor
		let s:UnsavedStack[l:file] = {}
	endif

	let l:message = l:time . ';' . a:action  . ';' . l:file

	if g:activity_log_append_git_branch
		let l:branch = system('cd ' . fnameescape(expand("%:h")) . "; git rev-parse -q --abbrev-ref HEAD 2> /dev/null")
		let l:message = l:message . ';' . substitute(l:branch, '\v\C\n$', '', '')
	endif
	call s:WriteLogAction(l:message)
endfunction

" Function: WriteLogAction()
"
" Simple wrapper for appending a message to the correct log file
" Also creates any missing directories as required
function s:WriteLogAction(message)
	let l:path = expand(strftime(g:activity_log_location))
	" :silent exe '! mkdir -p ' substitute(l:path, '\/[^\/]*$', '', '')
	let l:dir = fnamemodify(l:path, ":p:h")
	if finddir(l:dir) == ""
		call mkdir(l:dir, "p")
	endif
   
	" :silent exe '! echo ' . shellescape(a:message) . ' >> ' . l:path
	if filereadable(l:path)
		let l:lines = readfile(l:path)
	else
		let l:lines = []
	endif
	if writefile(l:lines+[a:message], l:path) != 0
		echo "activity-log: failed to write to logfile"
	endif
endfunction



function TimeLogLine(action)
	let l:file = expand("%:p")
	let l:time = strftime('%Y-%m-%d %H:%M:%S')
	let l:task = getline('.')
	let l:task = substitute(l:task,"  ","","g") 
	let l:branch = ''

	if g:activity_log_append_git_branch
		let l:branch = system('cd ' . expand("%:h") . "; git branch --no-color 2> /dev/null | sed -e '/^[^*]/d'")
		if (l:branch =~ "^* ")
			let l:branch = substitute(l:branch, '\* ', '', '')
			let l:branch = substitute(l:branch, '\n', '', '')
		endif
	endif


	let l:message = l:time . ';' . a:action  . ';' . l:file . ';'. l:branch .';' . l:task
	call s:WriteLogAction(l:message)
endfunction


" Section: Plugin completion
let g:loaded_activity_log=2
