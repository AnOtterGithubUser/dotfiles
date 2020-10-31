#!/usr/bin/env bash

add_env() {
  # export environment variables
  echo -e "Export variables DOT_REPO and DOT_LOCAL"
  EXPORT_COMMAND="export"

  CURRENT_SHELL=$(basename "$SHELL")
  if [[ $CURRENT_SHELL == "zsh" ]]; then
    echo "$EXPORT_COMMAND DOT_REPO:$1" >> "$HOME"/.zshrc
    echo "$EXPORT_COMMAND DOT_LOCAL:$2" >> "$HOME"/.zshrc
  elif [[ $CURRENT_SHELL == "bash" ]]; then
    echo "$EXPORT_COMMAND DOT_REPO:$1" >> "$HOME"/.bashrc
    echo "$EXPORT_COMMAND DOT_LOCAL:$2" >> "$HOME"/.bashrc
  else
    echo "Could not export environment variables DOT_REPO and DOT_LOCAL"
    echo "Shell could not be identified as zsh or bash"
    exit 1
  fi
  echo "Configuration for " ${CURRENT_SHELL} " has been updated"
}

first_setup() {
  echo -e "First time setup"
  echo -e "----------------------\n"
  read -p "Enter dotfiles github repository URL: " -r DOT_REPO
  read -p "Enter location in which to clone repository (default: " ${HOME} "/.dotfiles): " -r DOT_LOCAL
  DOT_LOCAL=${DOT_LOCAL:-$HOME}
  if [[ -d "${HOME}/${DOT_LOCAL}" ]]; then
    # Clone the repository in the destination folder
    if git -C "${HOME}/${DOT_LOCAL}" clone "${DOT_REPO}"; then
      add_env "${DOT_REPO}" "${DOT_LOCAL}"
      echo -e "\nSuccessfully cloned dotfiles into ${DOT_LOCAL}"
    else
      echo -e "\n${DOT_REPO} unavailable or non existent"
      exit 1
    fi
  else
    echo -e "\n${DOT_LOCAL} is not a valid directory"
    exit 1
  fi
}

list_dotfiles() {
  printf "\n"
  readarray -t DOTFILES < <( find "${HOME}" -maxdepth 1 -name ".*" -type f )
  printf "%s\n" "${DOTFILES[@]}"
}

show_diff() {

  declare -ag FILE_ARRAY

  readarray -t DOTFILES_REPO < <(find "${HOME}/${DOT_LOCAL}/$(basename "${DOT_REPO}")" -maxdepth 1 -name ".*" -type f )

  for (( i=0; i<"${#DOTFILES_REPO[@]}"; i++))
  do
    DOTFILE_NAME=$(basename "${DOTFILES_REPO[$i]}")
    DIFF=$(diff -u --suppress-common-lines --color=always "${DOTFILES_REPO[$i]}" "${HOME}/${DOTFILE_NAME}")
    if [[ $DIFF != "" ]]; then
      printf "\n\n%s" "Running diff between ${HOME}/${DOTFILE_NAME} and "
      printf "%s\n" "${DOTFILES_REPO[$i]}"
      printf "%s\n\n" "$DIFF"
    fi
    FILE_ARRAY+=("${DOTFILE_NAME}")
  done
  if [[ ${#FILE_ARRAY} == 0 ]]; then
    echo -e "\n\nNochanges in dotfiles. All up to date."
    return
  fi
}

dot_push() {
  show_diff
  echo "Copy changed files from $HOME to $HOME/$DOT_LOCAL/$(basename "$DOT_REPO")"
  for FILE in "${FILE_ARRAY[@]}"; do
    cp "${HOME}/$FILE" "${HOME}/${DOT_LOCAL}/$(basename "$DOT_REPO")"
  done

  LOCAL_DOT_REPO="$HOME/$DOT_LOCAL/$(basename "$DOT_REPO")"
  git -C "$LOCAL_DOT_REPO" add -A

  echo "Enter commit message (Ctrl+d to save): "
  COMMIT_MESSAGE=$(</dev/stdin)

  git -C "$DOT_REPO" commit -m "$COMMIT_MESSAGE"

  git -C "$DOT_REPO" push
}

dot_pull() {
  echo -e "Pull from $DOT_REPO... into $HOME/$DOT_LOCAL/$(basename "$DOT_REPO")"
  DOT_REPO="$HOME/$DOT_LOCAL/$(basename "$DOT_REPO")"
  git -C "$DOT_REPO" pull origin master
}

manage() {
  while :
  do
    echo -e "\n[1] Show diff"
    echo -e "[2] Update dotfiles to remote"
    echo -e "[3] Pull dotfiles from remote"
    echo -e "[4] List dotfiles"
    echo -e "[q] Quit"

    read - "Choice ? [1]" -n -1 -r CHOICE

    CHOICE=${CHOICE:-1}
    case $CHOICE in
      [1]* ) show_diff;;
      [2]* ) dot_push;;
      [3]* ) dot_pull;;
      [4]* ) list_dotfiles;;
      [q]* ) exit;;
      *) printf "\n%s\n" "Invalid input";;
    esac
  done
}

init_check() {
	# Check if the dotfiles variables are present in the system
	if [[ -z ${DOT_REPO} && -z ${DOT_LOCAL} ]]; then
		first_setup
	else
		manage
	fi
}

init_check