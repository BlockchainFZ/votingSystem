const Migrations = artifacts.require("ElectionContract");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};
