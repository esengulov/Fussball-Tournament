const Migrations = artifacts.require("Migrations");

module.exports = async function(deployer) {

	var getAccount = async function() {
		let accounts = await web3.eth.getAccounts();
		console.log("*** OWNER ACCOUNT ***");
		console.log(">> address : " + accounts[0]);
		let ownerBalance = await web3.eth.getBalance(accounts[0]);
		console.log(">> address : " + ownerBalance);				
	}
	await getAccount();

  	deployer.deploy(Migrations);
}; 
