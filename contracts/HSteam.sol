

pragma solidity ^0.5.1;


contract HSteam {

	// tracking team members
    mapping (address => bool) isHSMember;
    address private owner;
    
	constructor() public {

		owner = msg.sender;

		// initializing initial members of the team

		isHSMember[0xd26c9AcfeFa3EDb09754FC738B672172Dd3c3Dd3] = true;
		isHSMember[0x334b82B6378B586C2030a01630E19e08Eaa3dA29] = true;
		isHSMember[0x7566F6b575280dB591E7329A0B22A27D375884c7] = true;
		isHSMember[0xA70a13b44A7262F32A5Fe3b2672A27d6Bf246CB2] = true;
		isHSMember[0xe8cBe210C1fCCF8d62C85932Cc3D3308264f140D] = true;
		isHSMember[0x65F2EeC860Ab34BC8A8f758cA45d311fA7546374] = true;
		isHSMember[0xdF8f4f70153267A1eb4c39865f1508C0D51a083B] = true;
		isHSMember[0x5e5b6d393410A5FEbEFde50806eFE5e578b8eBBB] = true;
		isHSMember[0x5136f6f47a2d2610BF816bA5def8dF9E2e514eCA] = true;
		isHSMember[0x3364e60e2DD46278f940bfC545E2196d2D290B13] = true;
		isHSMember[0x96F615b37843acE26fB1182ebEfa3eAb22A01BDb] = true;
		isHSMember[0x53c582B9431aBeF3F6513A136443e9304c2C21B2] = true;

	}


	function addMember (address _addr) public returns(bool) {
		require (msg.sender == owner);
		isHSMember[_addr] = true;
	}
	
    
}
