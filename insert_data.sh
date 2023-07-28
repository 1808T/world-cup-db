#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE teams, games RESTART IDENTITY")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    WINNER_TEAM="$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")"
    OPPONENT_TEAM="$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")"

    if [[ -z $WINNER_TEAM ]]
    then
      INSERT_WINNER_TEAM_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")"
      if [[ $INSERT_WINNER_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams: $WINNER
      fi
    fi

    if [[ -z $OPPONENT_TEAM ]]
    then
      INSERT_OPPONENT_TEAM_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")"
      if [[ $INSERT_OPPONENT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams: $OPPONENT
      fi
    fi

    WINNER_TEAM_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
    OPPONENT_TEAM_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"

    INSERT_GAME_RESULT="$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")"
    echo Inserted into games: $ROUND[$YEAR] // [$WINNER / $WINNER_TEAM_ID] - [$OPPONENT / $OPPONENT_TEAM_ID]: $WINNER_GOALS - $OPPONENT_GOALS
  fi
done
