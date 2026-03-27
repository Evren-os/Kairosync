function pwd --description 'Print working directory with home replaced by ~'
    builtin pwd $argv | string replace -- $HOME '~'
end