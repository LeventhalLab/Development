function p = prc(cols,rc)
% rc = desired [row,col] position of subplot
p = (rc(1) * cols) - (cols - rc(2));