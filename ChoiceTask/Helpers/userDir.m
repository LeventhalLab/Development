function userdir = userDir()

if ispc
    userdir = getenv('USERPROFILE');
else
    userdir = getenv('HOME');
end