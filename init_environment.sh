#!/bin/bash -e

update()
{
    lex_dev_utils="lex_dev_utils"
    while [[ ! -d $lex_dev_utils ]]
    do
        lex_dev_utils="../$lex_dev_utils"
    done
}

load_dir()
{
    local dir="$1"
    local prefix="$2"
    shift 2

    mkdir "$dir"
    pushd "$dir" &>/dev/null
    update

    ln -s "$lex_dev_utils/Makefile"
    ln -s ../system-config.cmake

    for i
    do
        mkdir "$i"
        pushd "$i" &>/dev/null
        update
        git init
        local repo="${prefix}_$i"
        git remote add lex-pc "gitolite@lex.cs.istu.ru:$repo"
        git remote add cs "gitolite@cs.istu.ru:$repo"
        git remote add github "git@github.com:sarum9in/${repo}.git"
        parallel git fetch {} ::: lex-pc cs github || git fetch github
        git pull github master
        git branch --set-upstream-to=github/master || git branch --set-upstream master github/master
        ln -s "$lex_dev_utils/_gitignore" .gitignore
        if [[ -f CMakeLists.txt ]]
        then
            if [[ ! -e build ]]
            then
                mkdir build
            fi
            ln -s ../Makefile
            ln -s ../system-config.cmake
        fi
        popd &>/dev/null
    done

    popd &>/dev/null
}

#        base dir                           repository prefix   projects
load_dir ~/dev/bunsan                       bunsan              cmake testing binlogs binlogs_python common common_python curl dcs network pm pm_net pm_python process utility web worker worker_python
load_dir ~/dev/yandex.contest               yandex_contest      common system invoker invoker_compat_common invoker_compat_jni invoker_flowctl_game invoker_flowctl_pipectl invoker_debian
load_dir ~/dev/bunsan/bacs                  bunsan_bacs archive problem problems repository
load_dir ~/dev/bunsan/bacs/problem_plugins  bunsan_bacs_problem single
