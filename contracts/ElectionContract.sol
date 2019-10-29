pragma solidity ^0.4.24;

contract ElectionContract {

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
    string speaker;

    function _registerCandidate(string _name, string _party) public {
        candidates.push(Candidate(_name, _party));
        numberOfCandidates++;
    }

    function _registerVoter(string _name, uint _age) public {
        voters.push(Voter(_name,_age));
        numberOfVoters++;
    }

    function initializeElection(uint256 _registrationPeriod, uint256 _votingPeriod, uint256 _endTime) public {
        election.registrationPeriod = _registrationPeriod;
        election.votingPeriod = _votingPeriod;
        election.endTime = _endTime;
    }


}
