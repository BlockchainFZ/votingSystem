
var ElectionContract = artifacts.require("ElectionContract");
const assert = require("chai").assert;
const truffleAssert = require('truffle-assertions');


contract('Flight Surety Tests', async (accounts) => {

    let contract;
    let owner = accounts[0];
    let account2 = accounts[1];

    beforeEach(async () => {
      contract = await ElectionContract.new({ from:owner});
    });

    afterEach(async () => {
        await contract.kill({ from:owner});
    });


     it(`Demonstrates the caller is the contract owner`, async () => {

       await truffleAssert.reverts(contract.contractOwner(owner,{from:account2}), "Ownable: caller is not the owner");
    });


    it('Demonstrates only the Owner has registration access', async() => {

      await truffleAssert.reverts(contract.setRegistrationAccess(true,{from:account2}),"Ownable: caller is not the owner");
    });

    it('Demonstrates the Election period is open', async() => {
        await truffleAssert.reverts(contract._registerCandidate(account2,"Boris Johnson", "Tory"), "Election period is closed");
    });


    it(`Demonstrates the Registration period is open`, async () => {

      await contract.setRegistrationAccess(false);
      await truffleAssert.reverts(contract._registerCandidate(account2,"Boris Johnson", "Tory"), "Registration period is closed");
    });

    it('Demonstrates the Voting period is open`', async() => {

        await truffleAssert.reverts(contract._registerVoter("John Derry", 19), "Voting period is closed");
    });

    it('Demostrates the Candidate is valid', async() => {

    });




});