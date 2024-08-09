command! -nargs=1 MKEQN lua require('mkeqn').mkeqn((<f-args>))
command! -nargs=1 KILLEQN lua require('mkeqn').killeqn((<f-args>))
