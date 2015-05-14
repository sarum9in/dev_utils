#!/bin/bash -e

operation="$1"
shift

do_operation()
{
    echo "[[[ $PWD ]]]"
    echo "$operation" "$@"
    "$operation" "$@"
    echo
}

update()
{
    dev_utils="dev_utils"
    while [[ ! -d $dev_utils ]]
    do
        dev_utils="../$dev_utils"
    done
}

visit()
{
    local dir="$1"
    local prefix="$2"
    shift 2

    mkdir -p "$dir"
    pushd "$dir" &>/dev/null
    update

    ln -sf "$dev_utils/Makefile"
    ln -sf ../system-config.cmake

    for i
    do
        mkdir -p "$i"
        pushd "$i" &>/dev/null
        update
        if [[ $prefix ]]
        then
            local repo="${prefix}_${i}"
        else
            local repo="${i}"
        fi
        do_operation "git@github.com:bunsanorg/${repo}.git"
        popd &>/dev/null
    done

    popd &>/dev/null
}

fetch()
{
    local url="$1"

    if [[ ! -d .git ]]
    then
        git init
        git remote add github "$url"
        git fetch github
        git pull github master
        git branch --set-upstream-to=github/master || git branch --set-upstream master github/master
    fi
    ln -sf "$dev_utils/_gitignore" .gitignore
    if [[ -f CMakeLists.txt ]]
    then
        if [[ ! -e build ]]
        then
            mkdir build
        fi
        ln -sf ../Makefile
        ln -sf ../system-config.cmake
    fi
}

set_remote()
{
    local url="$1"

    git remote set-url github "$url"
}

rebuild()
{
    if [[ -e Makefile ]]
    then
        make rebuild
    fi
}

wc()
{
    local url="$1"

    "$dev_utils/wc"
}

#        base dir                           repository prefix   projects
visit    ~/dev/bunsan                       ''                  cmake \
                                                                testing \
                                                                common \
                                                                protobuf \
                                                                common_python \
                                                                curl \
                                                                network \
                                                                pm \
                                                                pm_net \
                                                                pm_python \
                                                                process \
                                                                utility \
                                                                web \
                                                                worker_python \
                                                                broker

visit    ~/dev/yandex.contest               yandex_contest      common \
                                                                system \
                                                                invoker \
                                                                invoker_compat_common \
                                                                invoker_compat_jni \
                                                                invoker_flowctl_interactive \
                                                                invoker_flowctl_pipectl \
                                                                invoker_debian

visit    ~/dev/bunsan/bacs                  bacs                common \
                                                                external \
                                                                system \
                                                                problem \

visit    ~/dev/bunsan/bacs/problem_plugins  bacs_problem        single

visit    ~/dev/bunsan/bacs                  bacs                problems \
                                                                archive \
                                                                statement_provider \
                                                                repository
