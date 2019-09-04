
const Tournament = artifacts.require("Tournament");


var settings = {
	entryfee: 100, 
	teamCount: 6
};




module.exports = async function(deployer) {

	await deployer.deploy(Tournament, settings.entryfee, settings.teamCount);

	// checking deployment
	let tournament = await Tournament.deployed();
	console.log("Tournament: "+ tournament.address);

	console.log("<<< AFTER DEPLOY >>>");
	let status = await tournament.registrationStatus();
	let gamingStatus = await tournament.tournamentStatus();	
	console.log(">> contract balance: " + status[0]);
	console.log(">> entry fee: " + status[1]);
	console.log(">> number of teams: " + status[2]);
	console.log(">> registered players: " + status[3]);
	console.log(">> registrations are open: " + status[4]);
	console.log(">> tournament started: " + status[5]);
	console.log(">> winners selected: " + status[6]);
	console.log(">> total games: " + gamingStatus[0]);
	console.log(">> games played: " + gamingStatus[1]);
	console.log(">> current game: " + gamingStatus[2]);	


	var runGame = async function() {
		console.log(".....")

		await tournament.getCurrentGame(function(err, result) {
			if(!err) {
				console.log("Game ID: " + result[0]);
				console.log(">> " + result[1] + " + " + result[2] + " || " + result[3] + " + " + result[4]);
				console.log(">> finish: 4, 2 // 3, 3")
			} else {
				console.log(err);
			}

		});

		await tournament.finishGame(4, 2, 3, 3);	
	};

	// create dummy HSmembers
	// for testing purposes
	let accounts = await web3.eth.getAccounts();
	console.log(">> adding dummy HS members");	
	console.log(accounts);
	await tournament.addMember(accounts[0], {from: accounts[0]});
	await tournament.addMember(accounts[1], {from: accounts[0]});
	await tournament.addMember(accounts[2], {from: accounts[0]});	
	await tournament.addMember(accounts[3], {from: accounts[0]});		
	await tournament.addMember(accounts[4], {from: accounts[0]});
	await tournament.addMember(accounts[5], {from: accounts[0]});
	await tournament.addMember(accounts[6], {from: accounts[0]});	
	await tournament.addMember(accounts[7], {from: accounts[0]});
	await tournament.addMember(accounts[8], {from: accounts[0]});
	await tournament.addMember(accounts[9], {from: accounts[0]});
	await tournament.addMember(accounts[10], {from: accounts[0]});
	await tournament.addMember(accounts[11], {from: accounts[0]});
	await tournament.addMember(accounts[12], {from: accounts[0]});	


	// register dummy HS members as players
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


	console.log("<<< AFTER PLAYER REGISTRATIONS >>>");
	let status2 = await tournament.registrationStatus();
	let gamingStatus2 = await tournament.tournamentStatus();
	console.log(">> contract balance: " + status2[0]);
	console.log(">> entry fee: " + status2[1]);
	console.log(">> number of teams: " + status2[2]);
	console.log(">> registered players: " + status2[3]);
	console.log(">> registrations are open: " + status2[4]);
	console.log(">> tournament started: " + status2[5]);
	console.log(">> winners selected: " + status2[6]);	
	console.log(">> total games: " + gamingStatus2[0]);
	console.log(">> games played: " + gamingStatus2[1]);
	console.log(">> current game: " + gamingStatus2[2]);



	// check that team allocations are random
	// first step work with real test net, Rinkeby
	// setup geth client

	console.log("*** TEAMS ***");
	let team1 = await tournament.getTeam(0);
	console.log("Team 1: " + team1[0] + " and " + team1[1]);

	let team2 = await tournament.getTeam(1);
	console.log("Team 2: " + team2[0] + " and " + team2[1]);

	let team3 = await tournament.getTeam(2);
	console.log("Team 3: " + team3[0] + " and " + team3[1]);

	let team4 = await tournament.getTeam(3);
	console.log("Team 4: " + team4[0] + " and " + team4[1]);

	let team5 = await tournament.getTeam(4);
	console.log("Team 5: " + team5[0] + " and " + team5[1]);

	let team6 = await tournament.getTeam(5);
	console.log("Team 6: " + team6[0] + " and " + team6[1]);



	// START GAMES
	// consider using getGame insead 
	// getGame();function commented below

	console.log("*** GAMES SET ***");

	await runGame();

	// let firstGame = await tournament.getCurrentGame();
	// console.log("first game id: " + firstGame[0]);
	// console.log(">> " + firstGame[1] + " + " + firstGame[2] + " || " + firstGame[3] + " + " + firstGame[4]);
	// console.log(">> finish: 3, 2 // 1, 3")
	// await tournament.finishGame(3, 2, 1, 3);

	// let secondGame = await tournament.getCurrentGame();
	// console.log("second game id: " + secondGame[0]);
	// console.log(">> " + secondGame[1] + " + " + secondGame[2] + " || " + secondGame[3] + " + " + secondGame[4]);
	// console.log(">> finish: 5, 1 // 4, 3")
	// await tournament.finishGame(5, 1, 4, 3);

	// let thirdGame = await tournament.getCurrentGame();
	// console.log("third game id: " + thirdGame[0]);
	// console.log(">> " + thirdGame[1] + " + " + thirdGame[2] + " || " + thirdGame[3] + " + " + thirdGame[4]);
	// console.log(">> finish: 3, 2 // 1, 3")
	// await tournament.finishGame(3, 2, 1, 3);

	// let fourthGame = await tournament.getCurrentGame();
	// console.log("foruth game id: " + fourthGame[0]);
	// console.log(">> " + fourthGame[1] + " + " + fourthGame[2] + " || " + fourthGame[3] + " + " + fourthGame[4]);
	// console.log(">> finish: 4, 2 // 3, 3")
	// await tournament.finishGame(4, 2, 3, 3);




};















