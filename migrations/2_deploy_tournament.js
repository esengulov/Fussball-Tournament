
const Tournament = artifacts.require("Tournament");


var settings = {
	entryfee: 100, 
	teamCount: 6
};

module.exports = function(deployer) {

  deployer.deploy(Tournament, settings.entryfee, settings.teamCount);

};