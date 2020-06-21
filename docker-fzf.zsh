#! /usr/bin/zsh

export DOCKER_FZF_PREFIX="--bind ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all"

_fzf_complete_docker_run_post() {
    awk '{print $1":"$2}'
}

_fzf_complete_docker_run () {
    _fzf_complete "$DOCKER_FZF_PREFIX -m --header-lines=1" "$@" < <(
        docker images
    )
}

_fzf_complete_docker_common_post() {
    awk -F"\t" '{print $1}'
}

_fzf_complete_docker_common () {
    _fzf_complete "$DOCKER_FZF_PREFIX --reverse -m" "$@" < <(
        docker images --format "{{.Repository}}:{{.Tag}}\t {{.ID}}"
    )
}

_fzf_complete_docker_container_post() {
    awk '{print $NF}'
}

_fzf_complete_docker_container () {
    _fzf_complete "$DOCKER_FZF_PREFIX -m --header-lines=1" "$@" < <(
        docker ps
    )
}
_fzf_complete_docker_context () {
    _fzf_complete "$DOCKER_FZF_PREFIX -m --header-lines=1" "$@" < <(
        docker context ls
    )
}
_fzf_complete_docker_context_post () {
    awk '{print $1}'
}

_fzf_complete_docker() {
    local tokens docker_command
    setopt localoptions noshwordsplit noksh_arrays noposixbuiltins
    # http://zsh.sourceforge.net/FAQ/zshfaq03.html
    # http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion-Flags
    tokens=(${(z)LBUFFER})
    if [ ${#tokens} -le 2 ]; then
        return
    fi
    docker_command=${tokens[2]}
    case "$docker_command" in
        run)
            _fzf_complete_docker_run "$@"
            return
        ;;
        exec|rm|restart|stop|logs)
            _fzf_complete_docker_container "$@"
            return
        ;;
        save|load|push|pull|tag|rmi)
            _fzf_complete_docker_common "$@"
            return
        ;;
    esac

    if [ $docker_command != "context" ]; then
        return
    fi

    docker_subcommand=${tokens[3]}

    case "$docker_subcommand" in
        inspect|update|use|rm)
            _fzf_complete_docker_context "$@"
            return
        ;;
    esac
}

