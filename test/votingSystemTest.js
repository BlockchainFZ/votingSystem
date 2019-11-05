var ElectionContract = artifacts.require("ElectionContract");

contract('Flight Surety Tests', async (accounts) => {

    let owner = accounts[0];
    let account2 = accounts[1];



    it(`Confirms contract owner`, async () => {
      let data = await ElectionContract.deployed();
      let status = await data._isOwner(owner);
      assert.equal(status, true, "Not the contract owner");
      status = await data._isOwner(account2);
      assert.equal(status, false, "Contract owner required");

    });

    it(`Allows any address to register a candidate`, async () => {
      let data = await ElectionContract.deployed();
      let numberOfCandidates = await data.numberOfCandidates.call();
      assert.equal(numberOfCandidates, 0, "initial contract has 0 candidates");

      try {
          await data._registerCandidate(account2,"Boris Johnson", "Tory", {from:account2});
        } catch(err) {
          console.log("Only Contract Owner can register candidates");
        }

      try {
          await data._registerCandidate(account2,"Boris Johnson", "Tory", {from:owner});
      }   catch (err){
        console.log(err);
      }

      numberOfCandidates = await data.numberOfCandidates.call();
      assert.equal(numberOfCandidates, 1, "Contract has 1 candidate");
    });


    it('Allows an address to register voter', async() => {
      let data = await ElectionContract.deployed();
    //  await data.validateVoter(owner);
    //  await data._registerVoter("Jesse",26);

    });

  });
