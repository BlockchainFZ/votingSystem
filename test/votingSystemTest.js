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

    it(`Allows any address to add a candidate`, async () => {
      let data = await ElectionContract.deployed();
      let numberOfCandidates = await data.numberOfCandidates.call();
      assert.equal(numberOfCandidates, 0, "initial contract has 0 candidates");

      await data._registerCandidate("Boris Johnson", "Tory");
      numberOfCandidates = await data.numberOfCandidates.call();
      assert.equal(numberOfCandidates, 1, "Contract has 1 candidate");


    });
  });
