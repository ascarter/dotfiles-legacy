#!/bin/sh

export old_email=$1
export new_name=$2
export new_email=$3

git filter-branch --commit-filter '
if [ "$GIT_AUTHOR_EMAIL" = "${old_email}" ];
then
        GIT_AUTHOR_NAME="${new_name}";
        GIT_AUTHOR_EMAIL="${new_email}";
        git commit-tree "$@";
else
        git commit-tree "$@";
fi' HEAD
