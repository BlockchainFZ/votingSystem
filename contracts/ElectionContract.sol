pragma solidity ^0.5.8;


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

    function _registerCandidate(string memory _name, string memory _party) public {
        candidates.push(Candidate(_name, _party));
        numberOfCandidates++;
    }

    function _registerVoter(string memory _name, uint _age) public {
        voters.push(Voter(_name,_age));
        numberOfVoters++;
    }

  }
