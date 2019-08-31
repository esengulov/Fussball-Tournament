pragma solidity ^0.5.1;

import "./HSteam.sol";

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
    

    // TRACKING tournament parameters
    bool private registrationOpen;
    bool private tournamentOn;    
    uint private entryFee;
    uint private teamCount;    
    uint private winnerTeamIndex;
    uint private winnerPlayerIndex;
    bool private winnerSelection;    
    address private theWinner;


    bool private contractInitialized;

    

    modifier entryReq() {
        require(isHSMember[msg.sender] == true); 
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
    
    function _assignTeam (uint _playerID) internal {

        require(players[_playerID].inTeam == false);

        // should randomly assign the player to one of the teams
        // should ensure that it works as expected
        uint _teamID = block.gaslimit % teamCount;

        for(uint i = 0; i < teamCount - 1; i++) {

            uint _toCheck = (_teamID + i) % teamCount;

            if(teams[_toCheck].player1 == 1000) {
                teams[_toCheck].player1 = _playerID;
                assert(teams[_toCheck].player1 == _playerID);
                break;
            } else if (teams[_toCheck].player2 == 1000) {
                teams[_toCheck].player2 = _playerID;
                assert(teams[_toCheck].player2 == _playerID);                
                break;
            }

        }



        // stores new state
        players[_playerID].inTeam = true;
        assert (players[_playerID].inTeam == true);
    }
    
    function _finishTournament() internal returns(bool) {
  
            require(registrationOpen == false);               
            require(tournamentOn == true);
            require(winnerSelection == false);
            require(gamesPlayed == games.length);
                   
            currentGame = 100;
            tournamentOn = false;               
            winnerSelection = true;
            assert(currentGame == 100 && winnerSelection == true && tournamentOn == true);       

            //_selectWinners();
            return true;
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
        require(ChooseNextGame());
    } 




    // PUBLIC METHODS

    function registerPlayer (string memory _name) public payable entryReq returns(uint _playerID) {

        require(registrationOpen == true);
        require(tournamentOn == false);
        require(winnerSelection == false);             

        //create new Player _player 
        Player memory _player;
        address payable newPlayer = msg.sender;
        _player.addr = newPlayer;
        _player.goalsScored = 0;
        _player.id = players.length;
        _player.name = _name;
        _player.inTeam = false;

        // store new _player
        players.push(_player);
        isPlayer[newPlayer] = true;

        // assign player to a team
        _assignTeam(_player.id);
        
        // start tournament when enough players
        if (players.length / 2 == teamCount) {
            registrationOpen == false;
            _startTournament();                        
        }

        return players[_player.id].id;

    }
    
    
    
    
    
    
    

   
    function ChooseNextGame() public onlyHS returns(bool) {

        require(registrationOpen == false);       
        require(tournamentOn == true);
        require(winnerSelection == false);
        
        if(gamesPlayed == games.length) {
 
                currentGame = 100;
                _finishTournament();
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
   
   
   
    function finishGame (uint goalst1p1, uint goalst1p2, uint goalst2p1, uint goalst2p2) public {
       
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
        
        require(ChooseNextGame());
       
   }
 
   

   
   
        // function _selectWinners() internal returns(bool) {
           
        //     require(currentGame == 100);
        //     require(tournamentOn == false && registrationOpen == false && winnerSelection == true);
    
        //     require(_calculateBestTeam());
        //     require(_calculateBestPlayer());
        
        //     require(winnerTeamIndex != 100 && winnerPlayerIndex != 100);
            
        //     winnerSelection = false;
        //     return true;
        // }
        
                
        // function _calculateBestTeam() internal returns(bool) {
            
        //     uint mostWinsByTeam = 0;
           
        //     for (uint i = 0; i< teams.length; i++) {
               
        //         if(teams[i].gamesWon > mostWinsByTeam) {
        //             mostWinsByTeam = teams[i].gamesWon;
        //             winnerTeamIndex = i;
                    
        //         } else if (teams[i].gamesWon == mostWinsByTeam && teams[i].gamesWon != 0) {
                    
        //             if(teams[i].goalsScored > teams[winnerTeamIndex].goalsScored) {
                        
        //                 winnerTeamIndex = i;
                        
        //             } else if(teams[i].goalsScored == teams[winnerTeamIndex].goalsScored) {
                        
        //                 //compare goals missed parameter
        //                 if(teams[i].goalsMissed < teams[winnerTeamIndex].goalsMissed) {
    
        //                     winnerTeamIndex = i;
                            
        //                 } else if (teams[i].goalsMissed == teams[winnerTeamIndex].goalsMissed) {
                            
        //                     // when there are two equal teams then there is no winner
        //                     winnerTeamIndex = 100;
        //                 }
        //             }
        //         }
                
        //     }
            
        
        //     if (mostWinsByTeam == 0) {
        //         winnerTeamIndex = 100;
        //     }
            
        //     return true;
        // }   
       
       
        // function _calculateBestPlayer() internal returns(bool) {
            
        //     uint _mostGoals = 0;
            
        //     for (uint i = 0; i< players.length; i++) {
               
        //         if(players[i].goalsScored > _mostGoals) {
        //           _mostGoals = players[i].goalsScored;
        //           winnerPlayerIndex = i;
                 
        //         } else if (players[i].goalsScored == _mostGoals && _mostGoals != 0) {
                    
        //             winnerPlayerIndex = 100;
            
        //         }
        //     }
            
        //     if (_mostGoals == 0) {
        //         winnerPlayerIndex = 100;
        //     }
            
        //     return true;
        // }   


        // allows captain of the winner team to withdraw entire balance
        // function claimTeamPrize() public returns(bool) {

        //     require(winnerTeamIndex != 100);
        //     require(tournamentOn == false && registrationOpen == false && winnerSelection == false);
           
        //     uint _winnerTeamCapID = teams[winnerTeamIndex].player1;
        //     address payable _teamCapAddress = players[_winnerTeamCapID].addr;
        //     require (msg.sender == _teamCapAddress);
            
        //     uint _balance = address(this).balance;
        //     _teamCapAddress.transfer(_balance);
        //     // add assertion to check for contracts balance
        //     return true;                      
            
        // }
  
   
     
   // enable contract to accept ether transactions

   function() external payable {
     
   }


  
   
   // GETTER METHODS

    function getRegistrationStatus() public view returns(bool) {
        return registrationOpen;
    }


    function getTournamentStatus() public view returns(bool) {
        return tournamentOn;
    }


    function getTotalGames() public view returns(uint) {
       return games.length;
    }


    function getGamesPlayed() public view returns(uint) {
       return gamesPlayed;
    }


    function getCurrentGame() public view returns(uint _gameID, uint _team1ID, uint _team2ID) {
    
        if(currentGame !=100) {
            uint team1ID = games[currentGame].team1; 
            uint team2ID = games[currentGame].team2; 
            return (currentGame, team1ID, team2ID);
        } else {
            return (100,100,100);
        }
    
    }


    function getBalance() public view returns(uint) {
       return address(this).balance;
    }
    
    function getEntryFee() public view returns(uint) {
       return entryFee;
    }
    


    function getNumberTeams() public view returns(uint) {
       return teams.length;
    }


    function getTeam(uint _id) public view returns(string memory, uint, uint, uint, uint, uint, uint) {
        string memory _name = teams[_id].name;
        uint _player1 = teams[_id].player1;
        uint _player2 = teams[_id].player2;
        uint _gamesPlayed = teams[_id].gamesPlayed;        
        uint _goalsScored = teams[_id].goalsScored;
        uint _goalsMissed = teams[_id].goalsMissed;
        uint _gamesWon = teams[_id].gamesWon;
       return (_name, _player1, _player2, _gamesPlayed, _goalsScored, _goalsMissed, _gamesWon);
    }


    function getPlayer(uint _id) public view returns(address, uint) {
        address _addr = players[_id].addr;
        uint _goalsScored = players[_id].goalsScored;
        return (_addr, _goalsScored);
    }        
   
   
    function getGame(uint _id) public view returns(string memory, string memory, bool) {
       
        uint _team1 = games[_id].team1;
        string memory _name1 = teams[_team1].name;
        
        uint _team2 = games[_id].team2;
        string memory _name2 = teams[_team2].name;        
        
        bool _played = games[_id].played;
        return (_name1, _name2, _played);
    }
    

    function getWinners() public view returns(string memory, address) {
        address _winnerPlayer = players[winnerPlayerIndex].addr;
        string memory _winnerTeamName = teams[winnerTeamIndex].name;
        return (_winnerTeamName, _winnerPlayer);
    } 

    
}