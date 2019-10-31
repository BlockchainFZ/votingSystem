var ElectionContract = artifacts.require("ElectionContract");

contract('Flight Surety Tests', async (accounts) => {

    let owner = accounts[0];


    console.log(owner);


    it(`returns contract owner`, async () => {
      let data = await ElectionContract.deployed();
      let status = await data.isOwner.call();

      assert.equal(status, true, "Not the contract owner");

    });

    it(`Allows any address to add a candidate`, async () => {
      let data = await ElectionContract.deployed();
      let numberOfCandidates = await data.numberOfCandidates.call();
      assert.equal(numberOfCandidates, 0, "initial contract has 0 candidates");

      await data._registerCandidate("Boris Johnson", "Tory");
      numberOfCandidates = await data.numberOfCandidates.call();
      assert.equal(numberOfCandidates, 1, "Contract has 1 candidate");
      console.log('numberOfCandidates',numberOfCandidates.toNumber());

    });
  });
