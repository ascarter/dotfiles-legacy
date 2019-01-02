#!/bin/sh

export old_email=$1
export au_name=$2
export au_email=$3
export co_name=${au_name}
export co_email=${au_email}

git filter-branch --env-filter '

an="$GIT_AUTHOR_NAME"
am="$GIT_AUTHOR_EMAIL"
cn="$GIT_COMMITTER_NAME"
cm="$GIT_COMMITTER_EMAIL"

if [ "$GIT_COMMITTER_EMAIL" = "${old_email}" ]
then
    cn="${co_name}"
    cm="${co_email}"
fi
if [ "$GIT_AUTHOR_EMAIL" = "${old_email}" ]
then
    an="${au_name}"
    am="${au_email}"
fi

export GIT_AUTHOR_NAME="$an"
export GIT_AUTHOR_EMAIL="$am"
export GIT_COMMITTER_NAME="$cn"
export GIT_COMMITTER_EMAIL="$cm"
'
