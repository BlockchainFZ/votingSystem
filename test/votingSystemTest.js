
var ElectionContract = artifacts.require("ElectionContract");
const assert = require("chai").assert;
const truffleAssert = require('truffle-assertions');


contract('Flight Surety Tests', async (accounts) => {

    let contract;
    let owner = accounts[0];
    let account2 = accounts[1];

    beforeEach(async () => {
      contract = await ElectionContract.new({ from: owner});

    });

    afterEach(async () => {
      await contract.kill({ from: owner});
    });

    it("Confirms value is not equal to Zero", async () => {

      await truffleAssert.reverts(contract.assertTest(10));
      //await truffleAssert.fails(contract.assertTest(10));
    });

    it(`Confirms contract owner`, async () => {

      let status = await contract._isOwner(owner);
      assert.equal(status, true, "Not the contract owner");
      status = await contract._isOwner(account2);
      assert.equal(status, false, "Contract owner required");


    });

    it(`Allows any address to register a candidate`, async () => {

      let numberOfCandidates = await contract.numberOfCandidates.call();
      assert.equal(numberOfCandidates, 0, "initial contract has 0 candidates");

      try {
          await contract._registerCandidate(account2,"Boris Johnson", "Tory", {from:account2});
        } catch(err) {
          console.log("Only Contract Owner can register candidates");
        }




      try {
          await contract._registerCandidate(account2,"Boris Johnson", "Tory", {from:owner});
      }   catch (err){
          console.log(err);
      }

          numberOfCandidates = await contract.numberOfCandidates.call();

         assert.equal(numberOfCandidates, 1, "Contract has 1 candidate");
    });


    it('Allows an address to register voter', async() => {

      let votingOpen = await contract.getVotingAccess.call();
      let voteFunction = contract.getVotingAccess();
      assert.equal(votingOpen, false, "Voter Registration open");





      try {
         await contract._registerVoter("John Derry", 18);
      }  catch(err) {
         console.log("Cannot Register Voter");
      }

      votingOpen = await contract.setVotingAccess(true,{from:owner});
      await truffleAssert.reverts(contract._registerVoter("John Derry", 1), "Voters must be over 18 to register");
      votingOpen = await contract.getVotingAccess.call();
      assert.equal(votingOpen, true, "Voter Registration closed");

      await contract._registerVoter("John Derry", 18, {from:owner});


    });



  });
