pragma solidity ^0.5.1;

import "./HSteam.sol";

    // TO DO
    // try deploying on proper testnet (rinkeby, kovan)
    // make sure that team allocations are random
    // run trials

contract Tournament is HSteam {


    // TRACKING TEAMS
    struct Team {
        uint id;
        string name;
        uint player1;
        uint player2;
        uint goalsScored;
        uint goalsMissed;
        uint gamesPlayed;
        uint gamesWon;
    }
    
    Team[] teams;
    uint[] winnerTeams;

    // TRACKING PLAYERS
    struct Player {
        uint id;
        address payable addr;
        uint goalsScored;
        string name;
        bool inTeam;
    }
  
    mapping (address => bool) isPlayer;
    Player[] players;
    uint[] winners;
    
    
    // TRACKING GAMES
    struct Game {
        uint id;
        uint team1;
        uint team2;      
        bool played;
    }

    Game[] games;
    
    uint private gamesPlayed;
    uint private currentGame;
    

    // TRACKING tournament
    bool private registrationOpen;
    bool private tournamentOn;    
    uint private entryFee;
    uint private teamCount;    
    uint private winnerTeamIndex;
    uint private winnerPlayerIndex;
    bool private winnerSelection;    
    address private theWinner;


    bool private contractInitialized;

    uint private lastRegistration;

    

    modifier entryReq() {
        require(isHSMember[msg.sender] == true); 
        require ((teamCount*2) - 1 >= players.length, "all teams are full");             
        require(isPlayer[msg.sender] != true);   
        require(msg.value >= entryFee);           
        _;
    }    

    modifier onlyHS() {
        require(isHSMember[msg.sender] == true); 
        _;
    }   

    constructor (uint _entryFee, uint _teamCount) public {
        
        require(_entryFee >= 100);
        entryFee = _entryFee;
        teamCount = _teamCount;

        registrationOpen = true;
        tournamentOn = false;
        gamesPlayed = 0;

        winnerSelection = false;
        winnerTeamIndex = 100;
        winnerPlayerIndex = 100;      

        contractInitialized = false;
        _generateTeams();
        assert (contractInitialized == true); 

        lastRegistration = 0;             
    }

    // INTERNAL METHODS 

    function _generateTeams() internal {

        for(uint i = 0; i<teamCount; i++) {

            Team memory _team;
            uint _currentlTeamID = teams.length;
            _team.id = _currentlTeamID;
            _team.goalsScored = 0;
            _team.goalsMissed = 0;
            _team.gamesPlayed = 0;
            _team.gamesWon = 0;
            _team.player1 = 1000;
            _team.player2 = 1000;
     
            teams.push(_team);
        }
        assert(teams.length == teamCount);
        contractInitialized = true;
    }  
    
    function _assignTeam (uint _id) internal {

        require(players[_id].inTeam == false, "already registered!");

        // should randomly assign the player to one of the teams
        // should ensure that it works as expected
        uint _teamID = (block.gaslimit) % teamCount;

        for(uint i = 0; i < teamCount; i++) {

            uint _toCheck = (_teamID + i) % teamCount;

            if(teams[_toCheck].player1 == 1000) {
                teams[_toCheck].player1 = _id;
                assert(teams[_toCheck].player1 == _id);
                break;
            } else if (teams[_toCheck].player2 == 1000) {
                teams[_toCheck].player2 = _id;
                assert(teams[_toCheck].player2 == _id);                
                break;
            }

        }

        // stores new state
        players[_id].inTeam = true;
        assert (players[_id].inTeam == true);
    }
        
    
    function _startTournament () internal {

        require(registrationOpen == false);
        require(tournamentOn == false);
        require(winnerSelection == false);     
        gamesPlayed = 0;

        for (uint i=1; i<teamCount; i++) {
            
            for (uint j = i+1; j<=teamCount; j++) {
                
                Game memory _game;
                _game.team1 = i-1;
                _game.team2 = j-1;                               
                _game.played = false;
                _game.id = games.length;
                games.push(_game);
            }   
        }

        tournamentOn = true;
        assert (tournamentOn == true && gamesPlayed == 0);

        // guarantee execution of the following method
        require(selectGame());
    } 
    
   
    function _calculateWinners() internal returns(bool) {

        require(currentGame == 100);

        uint _mostGoals = 0;
        uint _mostWins = 0;

        for (uint i = 0; i< players.length; i++) {    
            if(players[i].goalsScored > _mostGoals) {
            _mostGoals = players[i].goalsScored;
            winners.push(winnerPlayerIndex);
            winnerPlayerIndex = i;
            }
        }

        for (uint k = 0; k< teams.length; k++) {       
            if(teams[k].gamesWon > _mostWins) {
            _mostWins = teams[k].gamesWon;
            winnerTeams.push(winnerTeamIndex);
            winnerTeamIndex = k;         
            }    
        }       

        winnerSelection = true;
        return true;   
    }





   // enable contract to accept ether transactions
    function() external payable {}




    // PUBLIC SETTER METHODS

    function registerPlayer (string memory _name) public payable entryReq returns(uint) {
 
        require(registrationOpen == true);
        require(tournamentOn == false);
        require(winnerSelection == false);

        // to ensure randomness in team allocation
        // as an idea consider restricting one 
        // user registration per block

        //require (lastRegistration > block.timestamp, "Another user has already regsitered in this block. Try again in a few min");
        

        //create new Player _player 
        Player memory _player;
        _player.addr = msg.sender;
        _player.goalsScored = 0;
        _player.id = players.length;
        _player.name = _name;
        _player.inTeam = false;

        // store new _player
        players.push(_player);        
        isPlayer[msg.sender] = true;
        lastRegistration = block.timestamp;

        //assign player to a team
        _assignTeam(_player.id);
        
        // start tournament when enough players
        if (players.length / 2 == teamCount) {
            registrationOpen = false;
            _startTournament();                         
        }


        return players[_player.id].id;
    }
    
    function selectGame() public onlyHS returns(bool) {
        
        require(registrationOpen == false && tournamentOn == true && winnerSelection == false);       
    
        if(gamesPlayed == games.length) {
 
                currentGame = 100;
                require(_calculateWinners());
                return true;           
           
        } else {
           
                uint numGames = games.length; 
                uint _currentGame = (block.gaslimit % numGames);      
               
                if (games[_currentGame].played == true) {
                   
                    for (uint k = 1; k <=numGames; k++) {
                         
                        uint _next = (_currentGame+k) % numGames;
                         
                        if (games[_next].played == false) {
                            currentGame = _next;
                            break;
                        }
                    }
                    
                    return true;
                        
                } else {
               
                    currentGame = _currentGame;
                    return true;
                }
        }           
    }   

    function finishGame (uint goalst1p1, uint goalst1p2, uint goalst2p1, uint goalst2p2) public onlyHS returns(uint) {
       
        require(games[currentGame].played == false);
        // check that call made by team captain or player2

        uint _goalsByTeam1 = goalst1p1 + goalst1p2;
        uint _goalsByTeam2 = goalst2p1 + goalst2p2;
        
        uint _team1ID = games[currentGame].team1;
        uint _team2ID = games[currentGame].team2;
        
        teams[_team1ID].gamesPlayed += 1;
        teams[_team2ID].gamesPlayed += 1;
        teams[_team1ID].goalsScored += _goalsByTeam1;
        teams[_team2ID].goalsScored += _goalsByTeam2;
        teams[_team1ID].goalsMissed += _goalsByTeam2;
        teams[_team2ID].goalsMissed += _goalsByTeam1;
        
        if(_goalsByTeam1 > _goalsByTeam2) {
              teams[_team1ID].gamesWon += 1;
        } 
        
        if(_goalsByTeam1 < _goalsByTeam2) {
              teams[_team2ID].gamesWon += 1;  
        }
        
        
        // update player objects

        uint _t1p1 = teams[_team1ID].player1;
        players[_t1p1].goalsScored += goalst1p1;
        
        uint _t1p2 = teams[_team1ID].player2;
        players[_t1p2].goalsScored += goalst1p2;        
        
        uint _t2p1 = teams[_team2ID].player1;
        players[_t2p1].goalsScored += goalst2p1;
        uint _t2p2 = teams[_team2ID].player2;
        players[_t2p2].goalsScored += goalst2p2;

       
        // update game objects
        games[currentGame].played = true;        
        gamesPlayed ++;
        
        //uint _existingGame = currentGame;
        
        require(selectGame());

        // assert(_existingGame != currentGame);
        
        return currentGame; 
    }
 


   // PUBLIC GETTER METHODS

    function registrationStatus() public view returns(uint, uint, uint, uint, bool, bool, bool) {
        uint _balance = address(this).balance;
        uint _entryFee = entryFee;
        uint _teams = teams.length;
        uint _registeredPlayers = players.length;
        bool _registrationOpen = registrationOpen;
        bool _tournamentOn = tournamentOn;
        bool _winnerSelection = winnerSelection;
        return (_balance, _entryFee, _teams, _registeredPlayers, _registrationOpen, _tournamentOn, _winnerSelection);
    }

    function tournamentStatus() public view returns(uint, uint, uint)  {
        uint _totalGames = games.length;
        uint _gamesPlayed = gamesPlayed;
        uint _currentGame = currentGame;
        return (_totalGames, _gamesPlayed, _currentGame);
    }




    function getTeam(uint _id) public view onlyHS returns(uint, uint, uint, uint, uint, uint) {
        uint _player1 = teams[_id].player1;
        uint _player2 = teams[_id].player2;
        uint _gamesPlayed = teams[_id].gamesPlayed;        
        uint _goalsScored = teams[_id].goalsScored;
        uint _goalsMissed = teams[_id].goalsMissed;
        uint _gamesWon = teams[_id].gamesWon;
        return (_player1, _player2, _gamesPlayed, _goalsScored, _goalsMissed, _gamesWon);
    } 

    function getGame(uint _id) public view onlyHS returns(uint, uint, bool, uint, uint, uint, uint) {
       
        uint _team1 = games[_id].team1;  
        uint _t1p1 = teams[_team1].player1;
        uint _t1p2 = teams[_team1].player2;

        uint _team2 = games[_id].team2;        
        uint _t2p1 = teams[_team2].player1;
        uint _t2p2 = teams[_team2].player2;                  

        bool _played = games[_id].played;

        return (_team1, _team2, _played, _t1p1, _t1p2, _t2p1, _t2p2);
    }

    function getPlayer(uint _id) public view returns(string memory) {
        //require (_id == players[_id].id);
        string memory _name = players[_id].name;
        return _name;
    } 

    function getCurrentGame() public view returns(uint, string memory, string memory, string memory, string memory) {

        require (currentGame != 100);

        uint _team1ID = games[currentGame].team1; 
        uint _team2ID = games[currentGame].team2;

        uint _t1p1 = teams[_team1ID].player1;
        string memory t1p1_name = players[_t1p1].name;

        uint _t1p2 = teams[_team1ID].player2;
        string memory t1p2_name = players[_t1p2].name;

        uint _t2p1 = teams[_team2ID].player1;
        string memory t2p1_name = players[_t2p1].name;

        uint _t2p2 = teams[_team2ID].player2;
        string memory t2p2_name = players[_t2p2].name;                    

        return (currentGame, t1p1_name, t1p2_name, t2p1_name, t2p2_name);

    }
   

   

   
   








    
}