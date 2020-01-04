pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract ElectionContract is Ownable {

    using SafeMath for uint256;

    struct candidateStruct {
        string name;
        string party;
        uint index;
    }

    struct voterStruct {
        //address voterAddress;
        string name;
        uint age;
        bool hasVoted;
        uint index;
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

    //mapping(address => bool) isVoterValid;
    mapping(bytes => uint) votesReceived;

    mapping(bytes => uint256) fundedParties;

    //uint public numberOfVoters;

    mapping(address => candidateStruct) private candidates;
    address[] private candidateIndex;

    mapping(address => voterStruct) private voters;
    address[] private votersIndex;

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

/*    modifier registeredCandidate(address _address) {
        require(candidateIndex[candidates[_address].index] == _address, "Candidate is not registered");
        //require(candidates[_address].isCandidate == true, "Candidate is not registered");
        _;
    }

    modifier unregisteredCandidate(address _address) {
        //require(candidates[_address].isCandidate == false,  "Candidate is already registered");
        //require(candidates[_address] == _address);
        require(candidateIndex[candidates[_address].index] == _address, "Candidate is not registered");
        _;
  }
*
    modifier unregisteredVoter(address _address) {
        require(voters[_address].isRegistered == false, "Voter is already registered");
        _;
    }

    modifier registeredVoter(address _address) {
        require(voters[_address].isRegistered == true, "Voter is not registered");
        _;
    }
*/
    modifier validVoter(address _address) {
      require(voters[_address].hasVoted == false, "Voter is either unregistered, or has already voted");
      _;
    }

    modifier validParty(string memory _name){
        require(validPartyStrings(_name) == true, "Invalid Party name");
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
      //unregisteredCandidate(_address)
      onlyOwner
      {
      if(isCandidate(_address)) revert();
        candidateStruct memory candidate = candidateStruct({
           name: _name,
           party:_party,
           index: candidateIndex.push(_address) - 1
        });
        emit LogNewCandidate(_address, _name, _party);
        candidates[_address] = candidate;
    }

    function _registerVoter(address _address, string memory _name, uint _age) public
      votingPeriodIsOpen
      electionPeriodIsOpen
      //unregisteredVoter(msg.sender)
      {
        if(isRegisteredVoter(_address)) revert();
        require(_age >= 18, "Voters must be over 18 to register");
        voterStruct memory newVoter = voterStruct({
            name: _name,
            age:_age,
            hasVoted: false,
            index: votersIndex.push(_address) - 1

        });
        emit LogNewVoter(_address, _name, _age);
        voters[_address] = newVoter;
      }

    // Vote Functions

    function vote(string memory _name) public
    votingPeriodIsOpen
    validParty(_name)
    //registeredVoter(_voter)
    validVoter(msg.sender)
    {
      if(!isRegisteredVoter(msg.sender)) revert();
      voters[msg.sender].hasVoted = true;
      emit LogVote(_name);

      bytes memory name = bytes(_name);
      votesReceived[name]++;
    }

    // Party Functions
    function fundPartyCampaign(address _address, string memory _party, uint _amount) public payable
          registrationPeriodIsOpen
          electionPeriodIsOpen
          //registeredCandidate(_address)
          validParty(_party)
          minimumFund(_amount)
        {
            if(!isCandidate(_address)) revert();
            emit LogFundParty(_address, _party, _amount);
            bytes memory party = bytes(_party);
            fundedParties[party] += _amount;
        }

    // Return functions
    function isCandidate(address _candidateAddress) public view returns (bool _isIndeed) {
      if(candidateIndex.length == 0) return false;
      return (candidateIndex[candidates[_candidateAddress].index] == _candidateAddress);
    }

    function isRegisteredVoter(address _voterAddress) public view returns (bool _isIndeed) {
      if(votersIndex.length == 0) return false;
      return (votersIndex[voters[_voterAddress].index] == _voterAddress);
    }

    function getNumberOfCandidates() public view returns (uint _amount) {
      return candidateIndex.length;
    }

    function getCandidate(uint _index) public view returns(address _address) {
        return(candidateIndex[_index]);
    }

    function getVoter(uint _index) public view returns(address _address){
        return(votersIndex[_index]);
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
