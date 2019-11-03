pragma solidity ^0.5.8;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract ElectionContract is Ownable {

    using SafeMath for uint256;

    struct Candidate {
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
        bool closeRegistrationPeriod;
        bool closeVotingPeriod;
        bool closeElectionPeriod;
    }
    Election public election;

    Candidate[] private candidates;
    uint public numberOfCandidates;

    Voter[] private voters;
    uint private numberOfVoters;

    constructor() public {
     election = Election(now, 1 days, 2 days, 2 days, false, false, false);

    }

    modifier isvalidRegistrationPeriod () {
        require(_remainingRegistrationPeriod() <= election.registrationPeriod);
     _;
    }

    modifier voteIsOpen()  {
        require(now < election.electionTimeStamp.add(election.votingPeriod));
    _;
    }

    modifier isvalidVotingPeriod() {
        require(_remainingVotingPeriod() <= election.votingPeriod);
        _;
    }

    function _isOwner(address _address) public view returns(bool) {
      return _address == owner();
    }

    function _registerCandidate(string memory _name, string memory _party) public isvalidRegistrationPeriod {
        candidates.push(Candidate(_name, _party));
        numberOfCandidates++;
    }

    function _registerVoter(string memory _name, uint _age) public onlyOwner voteIsOpen {
        voters.push(Voter(_name,_age));
        numberOfVoters++;
    }

    function _remainingRegistrationPeriod() public view returns (uint256){
        return now.sub(election.electionTimeStamp);

    }

    function _remainingVotingPeriod() public view returns (uint256) {
        return now.sub(election.electionTimeStamp);
    }

    function _closeRegistrationPeriod() public returns (bool) {
            return election.closeRegistrationPeriod = true;
    }

    function _closeVotingPeriod() public returns (bool) {
            return election.closeVotingPeriod = true;
    }

    function _closeElection() public returns (bool) {
            return election.closeElectionPeriod = false;
    }



  }
