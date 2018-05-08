var PeerPoint = artifacts.require("./PeerPoint.sol");

module.exports = function(deployer) {
  deployer.deploy(PeerPoint);
};
