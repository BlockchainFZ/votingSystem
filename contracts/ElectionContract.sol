pragma solidity ^0.5.8;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract ElectionContract is Ownable {

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
        bool closeRegistrationPeriod;
        bool closeVotingPeriod;
        bool closeElectionPeriod;
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
     election = Election(now, 1 days, 2 days, 2 days, false, false, false);

    }

    // modifiers

    modifier registrationPeriodIsOpen()  {
        require(election.closeRegistrationPeriod == false);
    _;
    }

    modifier votingPeriodIsOpen() {
      require(election.closeVotingPeriod == false);
      _;
    }

    modifier closeElectionPeriod() {
      require(election.closeElectionPeriod == false);
      _;
    }

    modifier validCandidate(address _address) {
      require(isCandidateValid[_address] == true);
      _;
    }

    modifier validVoter(address _address) {
        require(isVoterValid[_address] == true);
        _;
    }



    // validate candidates

    function validateCandidate(address _address) public returns (bool) {
        return isCandidateValid[_address] = true;
    }

    function validateVoter(address _address) public returns (bool) {
        return isVoterValid[_address] = true;
    }


   // Open Registration Functions

    function _registerCandidate(address _address, string memory _name, string memory _party) public registrationPeriodIsOpen onlyOwner {
        candidates.push(Candidate(_address, _name, _party));
        numberOfCandidates++;
    }

    function _registerVoter(string memory _name, uint _age) public onlyOwner registrationPeriodIsOpen validVoter(msg.sender) {
        voters.push(Voter(_name,_age));
        numberOfVoters++;
    }


    // voting Functions


    // Close Registration Functions

 /*   function _closeRegistrationPeriod() public returns (bool) {
            return election.closeRegistrationPeriod = true;
    }

    function _closeVotingPeriod() public returns (bool) {
            return election.closeVotingPeriod = true;
    }

    function _closeElection() public returns (bool) {
            return election.closeElectionPeriod = true;
    }
    */

}
