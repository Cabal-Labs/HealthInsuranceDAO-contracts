// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract Treasury {

    struct Claim {
        string hospitalName;
        string patientName;
        string medicalProcedure;
        uint256 medicalProcedureCost;
    }


    mapping(uint256 => Claim) public claims; // Mapping to store claims by ID
    uint256 public claimCounter;
    mapping(string => address) private hospitalList; //List of hostpitals that can be paid
	mapping(uint256 => uint256) private medical_procedure_cost;
    mapping(uint256 => uint256) private medical_procedure_probability;
	mapping(uint256 => uint256[]) private policy; 
	mapping(uint256 => address) private membership_nft;
	mapping(uint256 => string) private policy_name;
    uint256 public loading_rate;
	uint256 public policy_counter;
	address public treasury_wallet;
    constructor(address _treasury_wallet) {
        loading_rate = 10; //10% loading
		policy_counter = 0;
		treasury_wallet= _treasury_wallet;
    }


    modifier onlyVoter() {
        //require(msg.sender == voter, "Only a voter can call this function");
        //_;
		_;
    }

    // Add hospital to the list
    function addHospital(string memory hospitalName, address hospitalAddress) public onlyVoter {
        require(hospitalList[hospitalName] == address(0), "Hospital already exists");
        hospitalList[hospitalName] = hospitalAddress;
    }

    // Function to get the address of a hospital by name
    function getHospitalAddress(string memory hospitalName) public view returns (address) {
        return hospitalList[hospitalName];
    }

    function payHospital(string memory hospitalName, uint256 paymentAmount, string memory patientName, string memory medicalProcedure) public onlyVoter {
        require(hospitalList[hospitalName] != address(0), "hospital does not exist");
        address hospitalAddress = hospitalList[hospitalName];

       // require({{Safe account address goes here( I think it's msg.sender)}}.balance >= paymentAmount, "Insufficient funds");

        // Attempt to send the payment to the hospital address
        (bool success, ) = hospitalAddress.call{value: paymentAmount}("");
        require(success, "Payment failed");

        claims[claimCounter] = Claim({
            hospitalName: hospitalName,
            patientName: patientName,
            medicalProcedure: medicalProcedure,
            medicalProcedureCost: paymentAmount
        });

        claimCounter++;
        
    }

    function getClaim(uint256 claimId) public view returns (Claim memory) {
        require(claimId < claimCounter, "Claim does not exist");
        return claims[claimId];
    }

    function getAllClaims() public view returns (Claim[] memory) {
        Claim[] memory allClaims = new Claim[](claimCounter);
        for (uint256 i = 0; i < claimCounter; i++) {
            allClaims[i] = claims[i];
        }
        return allClaims;
    }


	function setLoadingRate(uint256 new_loading_rate) public onlyVoter {
		loading_rate = new_loading_rate;
	} 

	function addProcedure(uint256 code, uint256 cost, uint256 probability) public{
		medical_procedure_cost[code] =cost;
		medical_procedure_probability[code] = probability;
	}

	function addInsurancePolicy(string memory name, uint256[] calldata coverage) public{
		//create a health insurance policy that covers x,y,z conditions
		policy[policy_counter] = coverage;
		policy_name[policy_counter] = name;
		policy_counter++;

	}

	function addMembershipToPolicy(uint256 policy, address lock)public{
		membership_nft[policy] = lock;
	}

	function getMembershipFromPolicy(uint256 policy)public view returns(address) {
		return membership_nft[policy];
	}

	function getPremium(uint256 policyNumber) public view returns(uint256){
		uint256 expectedLoss = 0;
		uint256[] memory coverage = policy[policyNumber];
		for(uint256 i = 0; i<coverage.length; i++){
			expectedLoss+= medical_procedure_cost[coverage[i]] * medical_procedure_probability[coverage[i]]; 
		}
		uint256 profit = applyPercentage(expectedLoss, loading_rate) + expectedLoss;
		return expectedLoss + profit;
	}

    function applyPercentage(uint256 amount, uint256 percentage) public pure returns (uint256) {
        require(percentage <= 100, "Percentage should be a whole number between 1 and 100");
        return (amount * percentage) / 100;
    }


}