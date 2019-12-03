
var ElectionContract = artifacts.require("ElectionContract");
const assert = require("chai").assert;
const truffleAssert = require('truffle-assertions');

contract('Returns System Tests', async (accounts) => {

    let contract;
    let owner = accounts[0];
    let account2 = accounts[1];

    beforeEach(async () => {
      contract = await ElectionContract.new({ from:owner });
      await contract.setElectionAccess(true);
      await contract.setVotingAccess(true);
      await contract.setRegistrationAccess(true);
    });

    afterEach(async () => {
      await contract.kill({ from:owner});
    });


     it(`Confirms getCandidate returns a registered candidate`, async() => {

      await contract._registerCandidate(account2,"James Smith", "Tory", {from:owner});
      let candidate = await contract.getCandidate(account2);
      assert.equal(account2,candidate[0],"Registered candidate is returned");
    });

    it(`Confirms getPartyCount returns the number of votes for requested party`, async() =>{
      await contract._registerCandidate(owner,"James Smith", "Tory", {from:owner});
      await contract._registerVoter(account2, "Bob Geledo", 60);
      let voter = await contract.getVoter(owner);
      let vote = await contract.vote("Con",voter);
      let voteCount = await contract.getPartyCount("Con");
      assert.equal(voteCount,1);

    });

  //  it(`Confirms a voter can be `)





  });
