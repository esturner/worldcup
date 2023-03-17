#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Inserts data into worldcup database
echo $($PSQL 'TRUNCATE TABLE games, teams')
echo $($PSQL 'ALTER SEQUENCE teams_team_id_seq RESTART WITH 1')
echo $($PSQL 'ALTER SEQUENCE games_game_id_seq RESTART WITH 1')

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
	if [[ $WINNER != 'winner' ]]
	then
		#check for winning team id
		W_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
		#if no team id, add team to teams
		if [[ -z $W_ID ]]
		then
			INSERT_W_ID_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
			if [[ $INSERT_W_ID_RESULT == 'INSERT 0 1' ]]
			then
				echo Inserted winner into teams, $WINNER
			fi
			wait			
			#get new winner's team id	
			W_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
		fi		
		#check for opposing team id
		O_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
		#if no team id, add team to teams
		if [[ -z $O_ID ]]
		then
			INSERT_O_ID_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
			if [[ $INSERT_O_ID_RESULT == 'INSERT 0 1' ]]
			then
				echo Inserted opponent into teams, $OPPONENT
			fi
			wait
			#get new opponent id
			O_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
		fi

		#insert game into games table
		INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $W_ID, $O_ID, '$WINNER_GOALS', '$OPPONENT_GOALS')")
		
		if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]
		then
			echo Inserted game into games: $YEAR $ROUND
		fi
	fi
done 
