#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
TRIES=0

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT user_id, username FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')" > /dev/null
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  USER_ID=$(echo $USER_INFO | cut -d '|' -f 1)
  USERNAME_DB=$(echo $USER_INFO | cut -d '|' -f 2)
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME_DB! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

while true
do
  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  TRIES=$((TRIES + 1))

  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
    $PSQL "INSERT INTO games(user_id, guesses, secret_number) VALUES($USER_ID, $TRIES, $SECRET_NUMBER)" > /dev/null
    break
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done
