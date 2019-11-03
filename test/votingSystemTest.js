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

      await data._registerCandidate("Boris Johnson", "Tory");
      numberOfCandidates = await data.numberOfCandidates.call();
      assert.equal(numberOfCandidates, 1, "Contract has 1 candidate");
    });

    it('Returns remainingRegistrationPeriod',async () => {
      let data = await ElectionContract.deployed();
      let remainingRegistrationPeriod = await data._remainingRegistrationPeriod.call();
      console.log(remainingRegistrationPeriod.toNumber());


    });

    it('Allows an address to register voter', async() => {
      let data = await ElectionContract.deployed();
      await data._registerVoter("Jesse",26);
      let solTime = await data._returnTimenow.call();
      const now = new Date(solTime);
      console.log(now.toNumber());
      //console.log(now.getTime());




    });

  });
