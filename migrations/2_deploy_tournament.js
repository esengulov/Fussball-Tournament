
const Tournament = artifacts.require("Tournament");


var settings = {
	entryfee: 100, 
	teamCount: 6
};

module.exports = async function(deployer) {

	await deployer.deploy(Tournament, settings.entryfee, settings.teamCount);

	// checking deployment
	let tournament = await Tournament.deployed();

	console.log("<<< AFTER DEPLOY >>>");
	console.log("Tournament: "+ tournament.address);
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

	let accounts = await web3.eth.getAccounts();

	// create dummy HSmembers
	// for testing purposes
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
	await tournament.registerPlayer("aibek", {from: accounts[0], value:100});
	await tournament.registerPlayer("aibek", {from: accounts[1], value:100});
	await tournament.registerPlayer("aibek", {from: accounts[2], value:100});
	await tournament.registerPlayer("aibek", {from: accounts[3], value:100});
	await tournament.registerPlayer("aibek", {from: accounts[4], value:100});
	await tournament.registerPlayer("aibek", {from: accounts[5], value:100});
	await tournament.registerPlayer("aibek", {from: accounts[6], value:100});
	await tournament.registerPlayer("aibek", {from: accounts[7], value:100});
	await tournament.registerPlayer("aibek", {from: accounts[8], value:100});
	await tournament.registerPlayer("aibek", {from: accounts[9], value:100});
	await tournament.registerPlayer("aibek", {from: accounts[10], value:100});
	await tournament.registerPlayer("aibek", {from: accounts[11], value:100});
	// should revert with "all teams are full" error
	// await tournament.registerPlayer("aibek", {from: accounts[12], value:100});

	console.log("<<< AFTER PLAYER REGISTRATIONS >>>");
	console.log("Tournament: "+ tournament.address);
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





};