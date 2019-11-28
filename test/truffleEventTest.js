
var ElectionContract = artifacts.require("ElectionContract");
const assert = require("chai").assert;
const truffleAssert = require('truffle-assertions');


contract('Truffle Event Tests', async (accounts) => {

    let contract;
    let owner = accounts[0];
    let account2 = accounts[1];

    beforeEach(async () => {
      contract = await ElectionContract.new({ from:owner});
      contract.setElectionAccess(true);
      contract.setVotingAccess(true);
    });

    afterEach(async () => {
        await contract.kill({ from:owner});
    });

    it(`Emmits LogNewCandidate event when RegisteredCandidate is called`, async() => {
      let tx = await contract._registerCandidate(owner, "John Major","Tory");
      // Assert LogNewCandidate is emitted //
       truffleAssert.eventEmitted(tx, 'LogNewCandidate', (event) => {
         return (event._address == owner);
       });
       // Assert LogNewVoter is not emitted //
       truffleAssert.eventNotEmitted(tx,'LogNewVoter');

    });

    it(`Emmits LogNewVoter event when _registerVoter is called `, async() => {
      let tx = await contract._registerVoter(owner, "Billy Rat", 33);
        // Assert LogNewVoter is  emitted //
        truffleAssert.eventEmitted(tx,'LogNewVoter',(event) => {
          return(event._address == owner);
        });
        // Assert LogNewCandidate is not emitted //
        truffleAssert.eventNotEmitted(tx,'LogNewCandidate');
    });

});
