pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract ElectionContract is Ownable {

    using SafeMath for uint256;


    struct candidateStruct {
        //address candidateAddress;
        string name;
        string party;
        uint index;
        bool isCandidate;
    }

    struct Voter {
        address voterAddress;
        string name;
        uint age;
        bool hasVoted;

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


    mapping(address => bool) isVoterValid;
    mapping(bytes => uint) votesReceived;
    mapping(address => Voter) voters;
    mapping(bytes => uint256) fundedParties;

    uint public numberOfVoters;

    mapping(address => candidateStruct) private candidates;
    address[] private candidateIndex;

    constructor() public {
      election = Election(now, 1 days, 2 days, 2 days, true, false, false);
    }

    // events
    event LogNewCandidate(address _address, string _name, string _party);
    event LogNewVoter(address _address, string _name, uint _age);
    event LogVote(string _name);
    event LogFundParty(address _address, string _party, uint256 _amount);


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
        //require(candidateIndex[candidates[_address].isCandidate] == true, "Candidate is not registered");
        require(candidates[_address].isCandidate == true, "Candidate is not registered");
        _;
    }

    modifier unregisteredCandidate(address _address) {
        require(candidates[_address].isCandidate == false,  "Candidate is already registered");

        _;
  }

    modifier unregisteredVoter(address _address) {
        require(voters[_address].voterAddress == address(0), "Voter is already registered");
        _;
    }

    modifier registeredVoter(address _address) {
        require(voters[_address].voterAddress != address(0), "Voter is not registered");
        _;
    }

    modifier validParty(string memory _name){
        require(validPartyStrings(_name) == true, "Invalid Party name");
        _;
    }

    modifier validVoter(address _address) {
      require(isVoterValid[_address] == true, "Voter is either unregistered, or has already voted");
      _;
    }

    modifier minimumFund(uint256 _amount) {
        require (_amount >= 1);
        _;
    }

    //  Registration Functions
    function _registerCandidate(address _address, string memory _name, string memory _party) public
      registrationPeriodIsOpen
      electionPeriodIsOpen
      unregisteredCandidate(_address)
      onlyOwner
      {
      //if(isCandidate(_address)) revert();
        candidateStruct memory candidate = candidateStruct({
           //candidateAddress:_address,
           name: _name,
           party:_party,
           index: candidateIndex.push(_address) - 1,
           isCandidate: true
        });
        emit LogNewCandidate(_address, _name, _party);
        candidates[_address] = candidate;
    }

    function _registerVoter(address _address, string memory _name, uint _age) public
      votingPeriodIsOpen
      electionPeriodIsOpen
      unregisteredVoter(msg.sender) {
        require(_age >= 18, "Voters must be over 18 to register");
        Voter memory newVoter = Voter({
            voterAddress: msg.sender,
            name: _name,
            age:_age,
            hasVoted:false
        });
        emit LogNewVoter(_address, _name, _age);
        voters[msg.sender] = newVoter;
        isVoterValid[msg.sender] = true;
        numberOfVoters++;
    }

    // Vote Functions

    function vote(string memory _name, Voter memory _voter) public
    votingPeriodIsOpen
    validParty(_name)
    registeredVoter(msg.sender)
    validVoter(msg.sender)
    {
      _voter.hasVoted = true;
      voters[msg.sender] = _voter;
      emit LogVote(_name);
      isVoterValid[msg.sender] = false;
      bytes memory name = bytes(_name);
      votesReceived[name]++;
    }

    // Party Functions
    function fundPartyCampaign(address _address, string memory _party, uint _amount) public payable
          registrationPeriodIsOpen
          electionPeriodIsOpen
          registeredCandidate(_address)
          validParty(_party)
          minimumFund(_amount)
        {
            emit LogFundParty(_address, _party, _amount);
            bytes memory party = bytes(_party);
            fundedParties[party] += _amount;
        }

    // Return functions
    function isCandidate(address _candidateAddress) public view returns (bool _isIndeed) {
      //if(candidateIndex.length == 0) return false;
      return (candidateIndex[candidates[_candidateAddress].index] == _candidateAddress);
    }

    function getNumberOfCandidates() public view returns (uint _amount) {
      return candidateIndex.length;
    }

    function getCandidate(uint _index) public view returns(address _address) {
        return(candidateIndex[_index]);
    }

    function getVoter(address _address) public view registeredVoter(_address) returns(Voter memory){
        return(voters[_address]);
    }

    function getPartyCount(string memory _name) public view
      onlyOwner
      validParty( _name)
      returns (uint) {
        bytes memory name = bytes(_name);
        return votesReceived[name];
    }

    function getPartyFund(string memory _party) public view returns (uint256 _amount) {
        bytes memory party = bytes(_party);
        return fundedParties[party];
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

    // Helper Functions
    function validPartyStrings(string memory _party) public pure returns (bool) {

        bytes memory con = "Con";
        bytes memory lab = "Lab";
        bytes memory lib = "Lib";

        return keccak256(bytes(_party)) == keccak256(bytes(con))  ||
               keccak256(bytes(_party)) == keccak256(bytes(lab))  ||
               keccak256(bytes(_party)) == keccak256(bytes(lib));
    }

    function kill() onlyOwner external {
      selfdestruct(msg.sender);
    }

    // Assertion Test Functions
    function contractOwner() public view onlyOwner returns(bool){
        return isOwner();
    }
}
