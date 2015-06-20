#!/bin/bash -e

operation="$1"
shift
argv=("$@")

safe_ln()
{
    local src="$1"
    local dst="${2:-$(basename "$src")}"
    if [[ -h $dst || ! -e $dst ]]
    then
        ln -sf "$src" "$dst"
    fi
}

do_operation()
{
    echo "[[[ $PWD ]]]"
    echo "$operation" "$@"
    "op_$operation" "$@"
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

op_fetch()
{
    local url="$1"

    if [[ ! -d .git ]]
    then
        git init
        git remote add github "$url"
        op_set_remote "$@"
        git fetch github
        git pull github master
        git branch --set-upstream-to=github/master || git branch --set-upstream master github/master
    fi
    safe_ln "$dev_utils/_gitignore" .gitignore
    if [[ -f CMakeLists.txt ]]
    then
        if [[ ! -e build ]]
        then
            mkdir build
        fi
        safe_ln "$dev_utils/Makefile"
        safe_ln "$dev_utils/system-config.cmake"
    fi
}

op_set_remote()
{
    local url="$1"
    local pull="$(echo "$url" | sed -r 's|:|/|;s|git[^@]*@|git://|;')"

    git remote set-url --push github "$url"
    git remote set-url github "$pull"
}

op_pull()
{
    local url="$1"

    git pull --ff-only
}

op_make()
{
    if [[ -e Makefile ]]
    then
        make "${argv[@]}"
    fi
}

op_rebuild()
{
    if [[ -e Makefile ]]
    then
        make rebuild
    fi
}

op_wc()
{
    "$dev_utils/wc"
}

op_grep()
{
    git grep "${argv[@]}" | (grep --color "${argv[@]}" || true)
}

#        base dir                           repository prefix   projects
visit    ~/dev/bunsan                       ''                  cmake \
                                                                testing \
                                                                common \
                                                                crypto \
                                                                protobuf \
                                                                common_python \
                                                                curl \
                                                                process \
                                                                utility \
                                                                pm \
                                                                pm_net \
                                                                pm_python \
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
