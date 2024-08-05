# .profile

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin
umask 022
if [ -f ~/.ashrc ]; then
    source ~/.ashrc
fi
