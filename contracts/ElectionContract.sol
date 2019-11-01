pragma solidity ^0.5.8;

//import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract ElectionContract is Ownable {

    struct Candidate {
        string name;
        string party;
    }

    struct Voter {
        string name;
        uint age;
    }

    struct Election {
        uint256 registrationPeriod;
        uint256 votingPeriod;
        uint256 endTime;
    }

    Candidate[] public candidates;
    uint public numberOfCandidates;

    Voter[] public voters;
    uint public numberOfVoters;

    Election public election;


    function _registerCandidate(string memory _name, string memory _party) public onlyOwner{
        candidates.push(Candidate(_name, _party));
        numberOfCandidates++;
    }

    function _registerVoter(string memory _name, uint _age) public onlyOwner{
        voters.push(Voter(_name,_age));
        numberOfVoters++;
    }

    function _isOwner(address _address) public view returns(bool) {
      return _address == owner();
    }



}
