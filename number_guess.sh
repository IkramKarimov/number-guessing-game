#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GET_USERNAME() {
  echo Enter your username:
  read USERNAME
}

GET_USERNAME "Enter your username:"

GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
RANDOM_NUMBER=$(( RANDOM % (1000) + 1 ))
NUMBER_OF_GUESSES=0
echo "$BEST_GAME"

if [[ ! -z $USERNAME ]]
then
  SAVED_USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
  if [[ -z $SAVED_USERNAME ]]
  then
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
    echo Welcome, "$USERNAME"! It looks like this is your first time here.
  else
    echo Welcome back, "$USERNAME"! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
  fi

  echo "$RANDOM_NUMBER"

  echo Guess the secret number between 1 and 1000:
  read USER_GUESS

  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
    read USER_GUESS
  else
    while [[ $USER_GUESS != $RANDOM_NUMBER ]]
    do
      if [[ $USER_GUESS > $RANDOM_NUMBER ]]
      then
        (( NUMBER_OF_GUESSES++ ))
        echo "It's higher than that, guess again:"
        read USER_GUESS
      fi
      if [[ $USER_GUESS < $RANDOM_NUMBER ]]
      then
        (( NUMBER_OF_GUESSES++ ))
        echo "It's lower than that, guess again:"
        read USER_GUESS
      fi
    done
    if [[ $USER_GUESS == $RANDOM_NUMBER ]]
    then
      if [[ -z $GAMES_PLAYED ]]
      then
        GAMES_PLAYED=0
      fi
      (( GAMES_PLAYED++ ))
      (( NUMBER_OF_GUESSES++ ))
      if [[ -z $BEST_GAME ]]
      then
        INSERT_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
      fi
      if [[ $NUMBER_OF_GUESSES < $BEST_GAME ]]
      then
        UPDATE_RESULT=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES, games_played = $GAMES_PLAYED WHERE username = '$USERNAME';")
      else
        UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'";)
      fi
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
    fi
  fi
fi
