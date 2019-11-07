var Election = artifacts.require("ElectionContract.sol");

module.exports = function(deployer) {
    deployer.deploy(Election);
};
