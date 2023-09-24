// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract Treasury {

    struct Claim {
        string hospitalName;
        address patientAddress;
        uint256 medicalProcedure;
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

	event HospitalAdded(string hospitalName, address indexed hospitalAddress);
    event ClaimCreated(uint256 indexed claimId, string hospitalName, address patientAddress, uint256 medicalProcedure, uint256 medicalProcedureCost);
    event HospitalPaid(string hospitalName, address indexed patientAddress, uint256 medicalProcedure, uint256 medicalProcedureCost);
    event PolicyCreated(uint256 indexed policyNumber, string name, uint256[] coverage);
    event ProcedureAdded(uint256 code, uint256 cost, uint256 probability);
    event MembershipAddedToPolicy(uint256 indexed policy, address lock);
    event LoadingRateChanged(uint256 newLoadingRate);

    constructor(address _treasury_wallet) {
        loading_rate = 10; //10% loading
		policy_counter = 0;
		treasury_wallet= _treasury_wallet;
    }


    modifier onlyVoter() {
        require(msg.sender == treasury_wallet, "Only a voter can call this function");
		_;
    }

    // Add hospital to the list
    function addHospital(string memory hospitalName, address hospitalAddress) public  {
        require(hospitalList[hospitalName] == address(0), "Hospital already exists");
        hospitalList[hospitalName] = hospitalAddress;
		emit HospitalAdded(hospitalName, hospitalAddress);
    }

    // Function to get the address of a hospital by name
    function getHospitalAddress(string memory hospitalName) public view returns (address) {
        return hospitalList[hospitalName];
    }

    function payHospital(
        string memory hospitalName,
        address patientAddress,
        uint256 medicalProcedure
    ) public payable onlyVoter {
        require(
            hospitalList[hospitalName] != address(0),
            "Hospital does not exist"
        );
        address hospitalAddress = hospitalList[hospitalName];
        uint256 medicalProcedureCost = msg.value;

        require(msg.value > 0, "Payment amount must be greater than 0");

        // Attempt to send the payment to the hospital address
        (bool success, ) = hospitalAddress.call{value: msg.value}("");
        require(success, "Payment failed");

        claims[claimCounter] = Claim({
            hospitalName: hospitalName,
            patientAddress: patientAddress,
            medicalProcedure: medicalProcedure,
            medicalProcedureCost: msg.value
        });

        claimCounter++;

		emit HospitalPaid(hospitalName,  patientAddress,  medicalProcedure, medicalProcedureCost);
        
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
		emit LoadingRateChanged(new_loading_rate);
	} 

	function addProcedure(uint256 code, uint256 cost, uint256 probability) public{
		medical_procedure_cost[code] =cost;
		medical_procedure_probability[code] = probability;
		emit ProcedureAdded(code, cost, probability);
	}

	function addInsurancePolicy(string memory name, uint256[] calldata coverage) public{
		//create a health insurance policy that covers x,y,z conditions
		policy[policy_counter] = coverage;
		policy_name[policy_counter] = name;
		policy_counter++;
		emit PolicyCreated(policy_counter, name, coverage);
	}

	function addMembershipToPolicy(uint256 _policy, address lock)public{
		membership_nft[_policy] = lock;
		emit MembershipAddedToPolicy(_policy, lock);
	}

	function getMembershipFromPolicy(uint256 _policy)public view returns(address) {
		return membership_nft[_policy];
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