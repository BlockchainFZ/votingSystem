pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract ElectionContract is Ownable {

    using SafeMath for uint256;

    struct Candidate {
        address _address;
        string name;
        string party;
    }

    struct Voter {
        address _address;
        string name;
        uint age;

    }

    struct Election {
        uint256 electionTimeStamp;
        uint256 registrationPeriod;
        uint256 votingPeriod;
        uint256 endTime;
        bool openRegistrationPeriod;
        bool openVotingPeriod;
        bool openElectionPeriod;
    }

    Election public election;

    mapping(address => bool) isCandidateValid;
    mapping(address => bool) isVoterValid;

    mapping(address => Voter) voters;
    mapping(address => Candidate) candidates;


    uint public numberOfCandidates;
    uint public numberOfVoters;


    constructor() public {
     election = Election(now, 1 days, 2 days, 2 days, true, false, false);

    }

    // events

    event LogNewCandidate(address sender);
    event LogNewVoter(address sender);

    // modifiers

    modifier registrationPeriodIsOpen()  {
        require(election.openRegistrationPeriod == true, "Registration period is closed");
    _;
    }

    modifier votingPeriodIsOpen() {
      require(election.openVotingPeriod == true, "Voting period is closed");
      _;
    }

    modifier closeElectionPeriod() {
      require(election.openElectionPeriod == true, "Election period is closed");
      _;
    }

    modifier validCandidate(address _address) {
      require(isCandidateValid[_address] == true, "Candidate is invalid");
      _;
    }

    modifier unvalidatedCandidate(address _address) {
        require(isCandidateValid[_address] != true, "Candidate is valid");
        _;
    }

    modifier validVoter(address _address) {
        require(voters[_address]._address == address(0), "Voter can register only once");
        _;
    }





    // Contract Owner

    function _isOwner(address _address) public view returns(bool) {
      return _address == owner();
    }


    //  Registration Functions

    function _registerCandidate(address _address, string memory _name, string memory _party) public registrationPeriodIsOpen onlyOwner {

        Candidate memory candidate = Candidate({
           _address:_address,
           name: _name,
           party:_party
        });
        emit LogNewCandidate(_address);
        candidates[_address] = candidate;
        isCandidateValid[_address] = true;
        numberOfCandidates++;
    }

    function _registerVoter(string memory _name, uint _age) public votingPeriodIsOpen validVoter(msg.sender) {

        require(_age >= 18, "Voters must be over 18 to register");
        Voter memory newVoter = Voter({
            _address: msg.sender,
            name: _name,
            age:_age
        });
        emit LogNewVoter(msg.sender);
        voters[msg.sender] = newVoter;
        isVoterValid[msg.sender] = true;
        numberOfVoters++;
    }

    function assertTest(uint age) public  {
      require(age == 0);
    }


    // voting Functions

    function getVoter(address _address) public view returns(Voter memory){
        return(voters[_address]);
    }

    // Set Election Period Functions

    function setRegistrationAccess(bool _access) public onlyOwner returns (bool) {
            return election.openRegistrationPeriod = _access;
    }

    function setVotingAccess(bool _access) public onlyOwner returns (bool) {
            return election.openVotingPeriod = _access;
    }


    // Get Election Period Functions

    function getRegistrationAccess() public view onlyOwner returns (bool) {
            return election.openRegistrationPeriod;
    }

    function getVotingAccess() public view onlyOwner returns (bool) {
            return election.openVotingPeriod;

    }

    function kill() onlyOwner external {
      selfdestruct(msg.sender);
    }

}
