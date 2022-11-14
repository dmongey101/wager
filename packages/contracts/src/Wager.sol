// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';
import './interfaces/IChainlinkAPI.sol';

contract Wager {
    uint256 public variable1;
    uint256 public variable2;
    IChainlinkAPI api;
    bytes32 public requestId1;
    bytes32 public requestId2;

    struct Bet {
        address person1;
        address person2;
        string apiEndpoint1;
        string apiEndpoint2;
        string path1;
        string path2;
    }

    Bet currentBet;

    event RequestedData(bytes32 requestId1, bytes32 requestId2);

        /**
     * @notice Initialize the link token and target oracle
     * @dev The oracle address must be an Operator contract for multiword response
     *
     *
     * Goerli Testnet details:
     * Link Token: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Oracle: 0xCC79157eb46F5624204f47AB42b3906cAA40eaB7 (Chainlink DevRel)
     * jobId: 53f9755920cd451a8fe46f5087468395
     *
     */
    constructor(address _api) {
        api = IChainlinkAPI(_api);
    }

    function deployWager(address _person1, address _person2, string memory _apiEndpoint1, string memory _apiEndpoint2, string memory _path1, string memory _path2) public {
        Bet memory bet = Bet({
            person1: _person1,
            person2: _person2,
            apiEndpoint1: _apiEndpoint1,
            apiEndpoint2: _apiEndpoint2,
            path1: _path1,
            path2: _path2
        });

        currentBet = bet;
    }

    function requestData() public {

        requestId1 = api.requestData(currentBet.apiEndpoint1, currentBet.path1);
        requestId2 = api.requestData(currentBet.apiEndpoint2, currentBet.path2);
        emit RequestedData(requestId1, requestId2);

        // '[?(@.id=='bitcoin')].market_cap'
    }

    function getData() public view returns (uint256, uint256){
        return (api.getData(requestId1), api.getData(requestId2));
    }

        /**
     * Allow withdraw of Link tokens from the contract
     */
    // function withdrawLink() public onlyOwner {
    //     LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    //     require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    // }
}