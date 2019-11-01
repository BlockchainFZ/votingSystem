var ElectionContract = artifacts.require("ElectionContract");

contract('Flight Surety Tests', async (accounts) => {

    let owner = accounts[0];
    let account2 = accounts[1];


    it(`confirms contract owner`, async () => {
      let data = await ElectionContract.deployed();
      let status = await data._isOwner(owner);
      assert.equal(status, true, "Not the contract owner");
      status = await data._isOwner(account2);
      assert.equal(status, false, "Contract owner required");

    });

    it(`Allows contract owner to register a candidate`, async () => {
      let data = await ElectionContract.deployed();
      let numberOfCandidates = await data.numberOfCandidates.call();
      assert.equal(numberOfCandidates, 0, "initial contract has 0 candidates");

      await data._registerCandidate("Boris Johnson", "Tory", {from:owner});
      numberOfCandidates = await data.numberOfCandidates.call();
      assert.equal(numberOfCandidates, 1, "Contract has 1 candidate");

        try {
          await data._registerCandidate("Boris Johnson", "Tory", {from:account2});
        } catch (error) {
          console.log("Only Contract Owner can register candidate");
        }

      });

    it(`Allows contract owner to register voter`, async () => {
      let data = await ElectionContract.deployed();
      let numberOfVoters = await data.numberOfVoters.call();
      assert.equal(numberOfVoters, 0, "Contract initialised with no voters");

      await data._registerVoter("John B", 25, {from:owner});
      numberOfVoters = await data.numberOfVoters.call();
      assert.equal(numberOfVoters, 1, "One voter has been registered");

        try {
          await data._registerVoter("Kenny Ken", 40, {from:account2});
        } catch (error) {
          console.log("Only Contract Owner can register voters");
        }

      });



  });
