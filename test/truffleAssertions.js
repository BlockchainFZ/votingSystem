
var ElectionContract = artifacts.require("ElectionContract");
const assert = require("chai").assert;
const truffleAssert = require('truffle-assertions');


contract('Truffle Assertion Tests', async (accounts) => {

    let contract;
    let owner = accounts[0];
    let account2 = accounts[1];
    let account3 = accounts[2];

    beforeEach(async () => {
      contract = await ElectionContract.new({ from:owner});
    });

    afterEach(async () => {
        await contract.kill({ from:owner});
    });


     it(`Demonstrates the caller is the contract owner`, async () => {
      // Attempt to use onlyOwner from non-owner contract//
       await truffleAssert.reverts(contract.contractOwner({from:account2}), "Ownable: caller is not the owner");

    });

    it('Demonstrates only the Owner has registration access', async() => {
      // Attempt to use onlyOwner from non-owner contract//
      await truffleAssert.reverts(contract.setRegistrationAccess(true,{from:account2}),"Ownable: caller is not the owner");
    });

    it('Demonstrates the Election period is open', async() => {
      // Attempt to register candidate without opening an election//
        await truffleAssert.reverts(contract._registerCandidate(account2,"Boris Johnson", "Tory"), "Election period is closed");
    });

    it(`Demonstrates the Registration period is closed`, async () => {
      // Attempt to register candidate without opening registration period//
      await contract.setRegistrationAccess(false);
      await truffleAssert.reverts(contract._registerCandidate(account2,"Boris Johnson", "Tory"), "Registration period is closed");
    });

    it('Demonstrates the Voting period is closed`', async() => {
        // Attempt to register voter without opening voting period//
        await truffleAssert.reverts(contract._registerVoter(owner, "John Derry", 19), "Voting period is closed");
    });

    it(`Demonstrates an unregistered Candidate cannot fund a campaign`, async() => {
        // Attempt to retrieve candidate without opening an election//
        await contract.setElectionAccess(true);
        await contract.setRegistrationAccess(true);
        await truffleAssert.reverts(contract.fundPartyCampaign(owner, "Con", 2));
    });

    it(`Demonstrates a Candidate can be registered only once`, async() =>{
        // Open an election, register a candidate, attempt to retrieve non registered candidate//
        await contract.setElectionAccess(true);
        await contract._registerCandidate(owner,"Boris Johnson", "Tory");
        await truffleAssert.reverts(contract._registerCandidate(owner,"Boris Johnson", "Tory"));
    });

    it(`Demonstrates an unregistered Voter cannot vote`, async() => {
      // Open an election, Open Voting, cast vote
      await contract.setElectionAccess(true);
      await contract.setVotingAccess(true);
      await truffleAssert.reverts(contract.vote("Con", {from:owner}));

    });

    it('Demonstrates a voter can only vote once', async() => {
      // Open an election, Open Voting, cast vote, attempt to vote twice
      await contract.setElectionAccess(true);
      await contract.setVotingAccess(true);
      await contract._registerVoter(owner, "Dave McBade", 45);
      let voter = await contract.getVoter(0);
      await contract.vote("Con", {from:owner});
      await truffleAssert.reverts(contract.vote("Lab", {from:owner}));
    });





});
