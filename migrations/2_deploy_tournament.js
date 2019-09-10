
const Tournament = artifacts.require("Tournament");


var settings = {
	entryfee: 100, 
	teamCount: 6
};




module.exports = async function(deployer) {

	await deployer.deploy(Tournament, settings.entryfee, settings.teamCount);

	// checking deployment
	let tournament = await Tournament.deployed();
	var getStatus = async function() {

		console.log("*** CONTRACT STATUS ***");
		console.log(">> address: "+ tournament.address);
		let status = await tournament.registrationStatus();
		let gamingStatus = await tournament.tournamentStatus();	
		console.log(">> balance: " + status[0]);
		console.log(">> entry fee: " + status[1]);
		console.log(">> teams: " + status[2]);
		console.log(">> players: " + status[3]);
		console.log(">> registrations are open: " + status[4]);
		console.log(">> games in progress: " + status[5]);
		console.log(">> total games: " + gamingStatus[0]);
		console.log(">> games played: " + gamingStatus[1]);
		console.log(">> current game: " + gamingStatus[2]);	
		console.log(">> winners selected: " + status[6]);
		console.log("------------------------------------")		
	}
	// display status
	await getStatus();


	// getting accounts
	let accounts = await web3.eth.getAccounts();


	// ADD DUMMY HS MEMBERS
	var addMembers = async function(){
		console.log(">> adding dummy HS members");	
		for (var i = 1; i <= settings.teamCount*2; i++) {
			await tournament.addMember(accounts[i-1], {from: accounts[0]});
		}
	}
	await addMembers();


	// REGISTER PLAYERS
	var registerPlayers = async function() {
		console.log(">> registering dummy HS members as players");	
		await tournament.registerPlayer("aibek", {from: accounts[0], value:100});
		await tournament.registerPlayer("kerim", {from: accounts[1], value:100});
		await tournament.registerPlayer("diana", {from: accounts[2], value:100});
		await tournament.registerPlayer("ermat", {from: accounts[3], value:100});
		await tournament.registerPlayer("chyngyz", {from: accounts[4], value:100});
		await tournament.registerPlayer("bakyt", {from: accounts[5], value:100});
		await tournament.registerPlayer("esen", {from: accounts[6], value:100});
		await tournament.registerPlayer("talgazainer", {from: accounts[7], value:100});
		await tournament.registerPlayer("nurkaly", {from: accounts[8], value:100});
		await tournament.registerPlayer("talgat", {from: accounts[9], value:100});
		await tournament.registerPlayer("anton", {from: accounts[10], value:100});
		await tournament.registerPlayer("arslan", {from: accounts[11], value:100});
		// should revert with "all teams are full" error
		// await tournament.registerPlayer("aibek", {from: accounts[12], value:100});
	}	
	await registerPlayers();


	// LIST TEAMS
	var listTeams = async function() {
		console.log("*** TEAMS ***");
		for (var i = 1; i <= settings.teamCount; i++) {
			team = await tournament.getTeam(i-1);
			console.log("Team " + i + ":" + team[0] + " and " + team[1]);
		}
	};
	await listTeams();
	// display status
	await getStatus();


	// PLAY GAMES
	var runGames = async function() {

		console.log("*** GAMES PLAYED! ***");

		for (var i = 0; i < settings.teamCount*(settings.teamCount-1)/2; i++) {		

			await tournament.getCurrentGame(function(err, result) {
				if(!err) {
					//console.log("Game ID: " + result[0]);
					console.log(">> " + result[1] + " + " + result[2] + " || " + result[3] + " + " + result[4]);
					//console.log(">> finish: 4, 2 // 3, 3")
				} else {
					console.log(err);
				}

			});

			await tournament.finishGame(4, 2, 3, 3);	

			console.log("game " + i + " finished.");
		};	
	};
	await runGames();
	await getStatus();


	// DISPLAY WINNERS


};















