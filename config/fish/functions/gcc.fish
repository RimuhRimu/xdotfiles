function gcc --wraps='git commit' --description 'alias gcc=git commit'
  git commit $argv; 
end
