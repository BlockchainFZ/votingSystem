pragma solidity ^0.5.8;

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
    //Voter public voter;
    //Candidate public candidate;
    mapping(address => bool) isCandidateValid;
    mapping(address => bool) isVoterValid;


    Candidate[] public candidates;
    uint public numberOfCandidates;


    Voter[] public voters;
    uint public numberOfVoters;


    constructor() public {
     election = Election(now, 1 days, 2 days, 2 days, true, false, false);

    }

    // modifiers

    modifier registrationPeriodIsOpen()  {
        require(election.openRegistrationPeriod == true);
    _;
    }

    modifier votingPeriodIsOpen() {
      require(election.openVotingPeriod == true);
      _;
    }

    modifier closeElectionPeriod() {
      require(election.openElectionPeriod == true);
      _;
    }

    modifier validCandidate(address _address) {
      require(isCandidateValid[_address] == true);
      _;
    }

    modifier unvalidatedCandidate(address _address) {
        require(isCandidateValid[_address] != true);
        _;
    }

    modifier validVoter(address _address) {
        require(isVoterValid[_address] == true);
        _;
    }



    // Contract Owner

    function _isOwner(address _address) public view returns(bool) {
      return _address == owner();
    }


    //  Registration Functions

    function _registerCandidate(address _address, string memory _name, string memory _party) public registrationPeriodIsOpen onlyOwner {
        candidates.push(Candidate(_address, _name, _party));
        isCandidateValid[_address] = true;
        numberOfCandidates++;
    }

    function _registerVoter(string memory _name, uint _age) public votingPeriodIsOpen  {
        voters.push(Voter(_name,_age));
        isVoterValid[msg.sender];
        numberOfVoters++;
    }


    // voting Functions


    // Close Registration Functions

    function _closeRegistrationPeriod() public returns (bool) {
            return election.openRegistrationPeriod = false;
    }

    function _closeVotingPeriod() public returns (bool) {
            return election.openVotingPeriod = false;
    }

    function _closeElection() public returns (bool) {
            return election.openElectionPeriod = false;
    }


}
