// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PropertyAssetTokenization {
    address contract_owner;
    IERC20 public token;
    IERC20 public propertyValueToken;
    IERC20 public propertyShareToken;

    uint platformFeePercentage = 2; // Platform fee percentage

    address private propertyValueToken_address= 0x1798982f0fCA6B7772a208B8831fA1B086CFf08e;
    address private propertyShareToken_address = 0xD5e0F15a0730839027f656408B4E81433B0998bA ;

    constructor() {
        contract_owner = msg.sender;
        propertyValueToken = IERC20(propertyValueToken_address);
        propertyShareToken = IERC20(propertyShareToken_address);
    }

    struct Property {
        uint id;
        string name;
        string _address;
        string description;
        string location;
        string[] images;
        string[] total_owners;
        uint percentage;
        uint total_value;
        string owner_name;
        address metamask_id;
        string user_name;
        string ownership_proof;
        bool isApproved;
        bool isInspected;
    }

    struct User {
        address id;
        string name;
        uint age;
        string city;
        string addhharNumber;
        string panNumber;
        string email;
        bool isUserVerified;
    }

    struct PropertyInspector {
        uint id;
        address _address;
        string name;
        uint age;
        string designation;
        string city;
    }

    enum req_status {
        requested,
        accepted,
        rejected,
        payment_done,
        completed
    }

    struct PropertyBuyRequest {
        uint req_id;
        address payable seller_id;
        address payable buyer_id;
        uint land_id;
        req_status _req_status;
        bool is_payment_done;
    }

    struct PropertyListingRequest {
        bool requested;
        string name;
        string propertyAddress;
        string description;
        string location;
        string[] images;
    }

    struct PropertyShareRequest {
        bool requested;
        uint percentage;
    }

    uint inspectors_count;
    uint public users_count;
    uint public properties_count;
    uint public document_id;
    uint request_count;

    mapping(address => PropertyInspector) public inspectors;
    mapping(address => bool) public isInspector;
    mapping(address => mapping(uint => PropertyListingRequest))
        public userPropertyListingRequests;
    mapping(address => mapping(uint => PropertyShareRequest))
        public userPropertyShares;
    mapping(uint => Property) public property;
    mapping(uint => PropertyBuyRequest) public property_buy_request;
    mapping(address => uint[]) public property_sell_received_request;
    mapping(address => uint[]) public property_sell_send_request;
    mapping(uint => uint[]) public all_properties_list;
    mapping(uint => uint[]) public payment_done_list;
    mapping(uint => mapping(address => uint)) public property_share;
    mapping(uint => mapping(address => uint)) public token_distribution_count;

    modifier onlyOwner() {
        require(msg.sender == contract_owner, "Caller is not the owner");
        _;
    }

    modifier onlyInspector() {
        require(isInspector[msg.sender], "Caller is not an inspector");
        _;
    }

    function addPropertyInspector(
        address _address,
        string memory _name,
        uint _age,
        string memory _designation,
        string memory _city
    ) public onlyOwner returns (bool) {
        inspectors_count++;
        inspectors[_address] = PropertyInspector(
            inspectors_count,
            _address,
            _name,
            _age,
            _designation,
            _city
        );
        isInspector[_address] = true;
        return true;
    }

    function removePropertyInspector(address _address) public onlyOwner {
        require(isInspector[_address], "Address is not an inspector");
        delete inspectors[_address];
        isInspector[_address] = false;
    }

    function requestPropertyListing(
        uint _propertyId,
        string memory _name,
        string memory _address,
        string memory _description,
        string memory _location,
        string[] memory _images
    ) public {
        require(property[_propertyId].id != 0, "Property does not exist");
        require(
            !userPropertyListingRequests[msg.sender][_propertyId].requested,
            "Already requested"
        );

        userPropertyListingRequests[msg.sender][
            _propertyId
        ] = PropertyListingRequest({
            requested: true,
            name: _name,
            propertyAddress: _address,
            description: _description,
            location: _location,
            images: _images
        });
    }

    function inspectProperty(
        uint _propertyId,
        bool _isApproved
    ) public onlyInspector {
        property[_propertyId].isInspected = true;
        property[_propertyId].isApproved = _isApproved;
    }

    function requestPropertyShare(uint _propertyId, uint _percentage) public {
        require(
            property[_propertyId].isApproved,
            "Property is not approved for listing"
        );
        require(
            !userPropertyShares[msg.sender][_propertyId].requested,
            "Already requested"
        );

        userPropertyShares[msg.sender][_propertyId] = PropertyShareRequest({
            requested: true,
            percentage: _percentage
        });
    }

    function approvePropertyShare(
        uint _propertyId,
        address _userAddress
    ) public onlyOwner {
        require(property[_propertyId].id != 0, "Property does not exist");
        require(
            userPropertyShares[_userAddress][_propertyId].requested,
            "No share request from user"
        );
        require(
            !property[_propertyId].isApproved,
            "Property is not approved for listing"
        );

        property_share[_propertyId][_userAddress] = userPropertyShares[
            _userAddress
        ][_propertyId].percentage;
        token_distribution_count[_propertyId][
            _userAddress
        ] = userPropertyShares[_userAddress][_propertyId].percentage;
    }

    function approvePropertyListing(uint _propertyId) public onlyOwner {
        property[_propertyId].isApproved = true;
    }
}
