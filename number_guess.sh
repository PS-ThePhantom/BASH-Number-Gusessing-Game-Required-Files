#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~ Number Guessing Game\n"
echo "Enter your username:"
read USER_NAME

USER_INFO=$($PSQL "SELECT * FROM user_info WHERE username = '$USER_NAME'")
if [[ -z $USER_INFO ]]
then
  echo -e "\nWelcome, $USER_NAME! It looks like this is your first time here."
  
  ADD_USER_RESULT=$($PSQL "INSERT INTO user_info(username, games_played, best_game)
                           VALUES('$USER_NAME', 0, 0)")
  USER_INFO=$($PSQL "SELECT * FROM user_info")

  GAMES_PLAYED=0
  BEST_GAME=0
else
  IFS="|" read USER_NAME GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
    echo -e "\nWelcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

(( GAMES_PLAYED++ ))
ANSWER=$(( RANDOM % 1000 + 1 ))
CURRENT_GUESS=1
GUESS_NUMBER=0

echo -e "\nGuess the secret number between 1 and 1000:"

while [[ $GUESS_NUMBER != $ANSWER ]]
do
  read GUESS_NUMBER

  if [[ ! $GUESS_NUMBER =~ ^[-]?[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    (( CURRENT_GUESS++ ))
  elif (( GUESS_NUMBER > ANSWER ))
  then
    echo -e "\nIt's lower than that, guess again:"
    (( CURRENT_GUESS++ ))
  elif (( GUESS_NUMBER < ANSWER ))
  then
    echo -e "\nIt's higher than that, guess again:"
    (( CURRENT_GUESS++ ))
  else
    echo -e "\nYou guessed it in $CURRENT_GUESS tries. The secret number was $ANSWER. Nice job!"
    
    UPDATE_RESULT=$($PSQL "UPDATE user_info SET games_played = $GAMES_PLAYED WHERE username = '$USER_NAME'")
    if [[ $CURRENT_GUESS < $BEST_GAME || $BEST_GAME == 0 ]]
    then
      UPDATE_RESULT=$($PSQL "UPDATE user_info SET best_game = $CURRENT_GUESS WHERE username = '$USER_NAME'")
    fi
  fi
done

