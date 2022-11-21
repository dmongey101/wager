// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import './interfaces/IChainlinkAPI.sol';
import './interfaces/IERC20.sol';
import './libraries/SafeMath.sol';
import './libraries/SafeERC20.sol';

contract Wager {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IChainlinkAPI _chainlinkApi;
    IERC20 public _chainlinkToken;
    
    struct Api {
        string apiEndpoint1;
        string apiEndpoint2;
        string path1;
        string path2;
        bytes32 requestId1;
        bytes32 requestId2; 
    }

    struct Bet {
        address payable person1;
        address payable person2;
        Outcome person1Outcome;
        Api api;
        uint256 amountEther;
        bool isActive;
        uint256 deadline;
        bool complete;
    }

    enum Outcome {
        Win,
        Lose,
        Draw
    }

    // mapping(address => mapping(uint256 => uint256)) _userBetBalances;

    mapping(uint256 => Bet) _betIndexes;

    mapping(address => uint256[]) _usersBets;

    uint256 private _currentIndex = 1;

    event RequestedData(bytes32 requestId1, bytes32 requestId2);
    event DepositLink(address user, uint256 amount);

    constructor(address api, address chainlinkToken) {
        _chainlinkToken = IERC20(chainlinkToken);
        _chainlinkApi = IChainlinkAPI(api);
    }

    function deployWager(
        address _person2,
        uint32 _outcome,
        string memory _apiEndpoint1, 
        string memory _apiEndpoint2, 
        string memory _path1, 
        string memory _path2, 
        uint256 _amountForBet,
        uint256 _deadline
    ) public payable {
        require(_person2 != address(0), "Please use a valid address");
        require(_amountForBet.div(2) == msg.value, "Not the correct amount to deposit");
        _depositLink();
        Api memory api = Api({
            apiEndpoint1: _apiEndpoint1,
            apiEndpoint2: _apiEndpoint2,
            path1: _path1,
            path2: _path2,
            requestId1: 0,
            requestId2: 0
        });

        Bet memory bet = Bet({
            person1: payable(msg.sender),
            person2: payable(_person2),
            person1Outcome: Outcome(_outcome),
            api: api,
            amountEther: _amountForBet,
            isActive: false,
            deadline: _deadline,
            complete: false
        });

        _betIndexes[_currentIndex] = bet;
        _usersBets[bet.person1].push(_currentIndex);
        _usersBets[bet.person2].push(_currentIndex);
        _currentIndex++;
    }

    function makePayment(uint256 index) public payable {
        Bet storage bet = _betIndexes[index];
        require(msg.sender == bet.person2, "You are not assigned to this bet");
        require(bet.amountEther.div(2) == msg.value, "Not the correct amount to deposit");
        _depositLink();
        bet.isActive = true;
    }

    function settle(uint256 index) public {
        Bet storage bet = _betIndexes[index];
        require(bet.complete == false, "Bet already settled");
        (uint256 person1Data, uint256 person2Data) = _getData(index);
        require(person1Data != 0, "Data not ready");
        require(person2Data != 0, "Data not ready");
        // person1 is lose so wants to be less than person 2

        if (bet.person1Outcome == Outcome.Win) {
            if (person1Data > person2Data) {
                _transferEth(bet.person1, bet.amountEther);
            } else {
                _transferEth(bet.person2, bet.amountEther);
            }
        } else if (bet.person1Outcome == Outcome.Lose) {
            if (person1Data < person2Data) {
                _transferEth(bet.person1, bet.amountEther);
            } else {
                _transferEth(bet.person2, bet.amountEther);
            }
        }
        bet.complete = true;
    }

    function requestData(uint256 _index) public {
        Bet storage bet = _betIndexes[_index];
        require(bet.isActive, "Bet is not active");
        require(block.timestamp >= bet.deadline, "Too early to get data");
        require(_chainlinkToken.balanceOf(address(this)) >= 0.2 ether, "Not enough link in contract");
        _chainlinkToken.approve(address(_chainlinkApi), 0.2 ether);
        _chainlinkToken.safeTransferFrom(address(this), address(_chainlinkApi), 0.2 ether);
        bet.api.requestId1 = _chainlinkApi.requestData(bet.api.apiEndpoint1, bet.api.path1);
        bet.api.requestId2 = _chainlinkApi.requestData(bet.api.apiEndpoint2, bet.api.path2);
        emit RequestedData(bet.api.requestId1, bet.api.requestId2);
    }

    function _getData(uint256 _index) internal view returns (uint256, uint256){
        Bet memory bet = _betIndexes[_index];
        return (_chainlinkApi.getData(bet.api.requestId1), _chainlinkApi.getData(bet.api.requestId2));
    }

    function _transferEth(address to, uint256 amount) public {
        (bool success,) = to.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function _depositLink() private {
        require(_chainlinkToken.balanceOf(msg.sender) >= 0.1 ether, "Not enough Link");
        _chainlinkToken.safeTransferFrom(msg.sender, address(this), 0.1 ether);
        emit DepositLink(msg.sender, 0.1 ether);
    }

        /**
     * Allow withdraw of Link tokens from the contract
     */
    // function withdrawLink() public onlyOwner {
    //     LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    //     require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    // }
}