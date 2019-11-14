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

    enum parties  {Conservative, Labour, LibDem, Green, Brexit }

    mapping(address => bool) isCandidateValid;
    mapping(address => bool) isVoterValid;
    mapping(string => uint256) partyCount;

    mapping(address => Voter) voters;
    mapping(address => Candidate) candidates;


    uint public numberOfCandidates;
    uint public numberOfVoters;


    constructor() public {
      election = Election(now, 1 days, 2 days, 2 days, true, false, false);
    }

    // events

    event LogNewCandidate(address _address, string _name, string _party);
    event LogNewVoter(address _address, string _name, uint _age);






    // modifiers

    modifier registrationPeriodIsOpen()  {
        require(election.openRegistrationPeriod == true, "Registration period is closed");
    _;
    }

    modifier votingPeriodIsOpen() {
      require(election.openVotingPeriod == true, "Voting period is closed");
      _;
    }

    modifier electionPeriodIsOpen() {
      require(election.openElectionPeriod == true, "Election period is closed");
      _;
    }

    modifier registeredCandidate(address _address) {
      require(isCandidateValid[_address] == true, "Candidate is invalid");
      _;
    }

    modifier unregisteredCandidate(address _address) {
        require(isCandidateValid[_address] != true, "Candidate is valid");
        _;
    }

    modifier unregisteredVoter(address _address) {
        require(voters[_address]._address == address(0), "Voter can already registered only once");
        _;
    }

    modifier registeredVoter(address _address) {
        require(voters[_address]._address != address(0), "Voter is not registered only once");
        _;
    }

    modifier validVote(string memory _party) {
      //require(_party == parties[0], "Vote must be from valid party");
      _;
    }


    //  Registration Functions

    function _registerCandidate(address _address, string memory _name, string memory _party) public
      registrationPeriodIsOpen
      electionPeriodIsOpen
      unregisteredCandidate(_address)
      onlyOwner {

        Candidate memory candidate = Candidate({
           _address:_address,
           name: _name,
           party:_party
        });
        emit LogNewCandidate(_address, _name, _party);
        candidates[_address] = candidate;
        isCandidateValid[_address] = true;
        numberOfCandidates++;
    }

    function _registerVoter(address _address, string memory _name, uint _age) public
      votingPeriodIsOpen
      electionPeriodIsOpen
      onlyOwner
      unregisteredVoter(msg.sender) {

        require(_age >= 18, "Voters must be over 18 to register");
        Voter memory newVoter = Voter({
            _address: msg.sender,
            name: _name,
            age:_age
        });
        emit LogNewVoter(_address, _name, _age);
        voters[msg.sender] = newVoter;
        isVoterValid[msg.sender] = true;
        numberOfVoters++;
    }

    // Vote Functions

    function vote(string memory _party) public
      votingPeriodIsOpen
      //validVote(_party)
      registeredVoter(msg.sender) {
        partyCount[_party]++;
      }

    // Candidate Functions

    function getCandidate(address _address) public view registeredCandidate(_address) returns(bool) {
        return(isCandidateValid[_address]);
    }

    // voting Functions

    function getVoter(address _address) public view registeredVoter(_address) returns(Voter memory){
        return(voters[_address]);
    }

    function getPartyCount(string memory _party) public view
      onlyOwner
      returns (uint256) {
          return(partyCount[_party]);
      }

    // Set Election Period Functions


    function setElectionAccess(bool _access) public onlyOwner returns (bool) {
              return election.openElectionPeriod = _access;
    }

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

    function getElectionAccess() public view onlyOwner returns (bool) {
            return election.openElectionPeriod;
    }



    function kill() onlyOwner external {
      selfdestruct(msg.sender);
    }

    // Assertion Test Functions

    function contractOwner() public view onlyOwner returns(bool){
        return isOwner();
    }




}
