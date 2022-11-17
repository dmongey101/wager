// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import './interfaces/IChainlinkAPI.sol';

contract Wager {
    IChainlinkAPI _chainlinkApi;
    bytes32 public requestId1;
    bytes32 public requestId2;

    struct Api {
        string apiEndpoint1;
        string apiEndpoint2;
        string path1;
        string path2;
    }

    struct Bet {
        address payable person1;
        address payable person2;
        Api api;
        uint256 amount;
        bool isActive;
    }

    mapping(uint256 => Bet) _betIndexes;

    mapping(address => uint256[]) _usersBets;

    uint256 _currentIndex = 0;

    event RequestedData(bytes32 requestId1, bytes32 requestId2);

    constructor() {
    }

    function deployWager(
        address _person2,
        string memory _apiEndpoint1, 
        string memory _apiEndpoint2, 
        string memory _path1, 
        string memory _path2, 
        uint256 _amount
    ) public {
        Api memory api = Api({
            apiEndpoint1: _apiEndpoint1,
            apiEndpoint2: _apiEndpoint2,
            path1: _path1,
            path2: _path2
        });

        Bet memory bet = Bet({
            person1: payable(msg.sender),
            person2: payable(_person2),
            api: api,
            amount: _amount,
            isActive: false
        });

        _betIndexes[_currentIndex] = bet;
        _usersBets[bet.person1].push(_currentIndex);
        _usersBets[bet.person2].push(_currentIndex);
        _currentIndex++;
    }

    function settle() public {

    }

    function requestData(uint256 _index) public {
        requestId1 = _chainlinkApi.requestData(_betIndexes[_index].api.apiEndpoint1, _betIndexes[_index].api.path1);
        requestId2 = _chainlinkApi.requestData(_betIndexes[_index].api.apiEndpoint2, _betIndexes[_index].api.path2);
        emit RequestedData(requestId1, requestId2);
    }

    function getData() public view returns (uint256, uint256){
        return (_chainlinkApi.getData(requestId1), _chainlinkApi.getData(requestId2));
    }

        /**
     * Allow withdraw of Link tokens from the contract
     */
    // function withdrawLink() public onlyOwner {
    //     LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    //     require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    // }
}