// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';

contract Wager is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    address public override owner;
    uint256 variable1;
    uint256 variable2;
    bytes32 private jobId;
    uint256 private fee;

    struct Bet {
        address person1;
        address person2;
        string apiEndpoint1;
        string apiEndpoint2;
        string path1;
        string path2;
    }

    Bet currentBet;

    constructor() {
        owner = msg.sender,
    }

    function deployWager(address _person1, address _person2, string _apiEndpoint1, string _apiEndpoint2, string _path1. string _path2) public {
        Bet memory bet = new Bet({
            person1 = _person1,
            person2 = _person2,
            apiEndpoint1 = _apiEndPoint1,
            apiEndpoint2 = _apiEndPoint2,
            path1 = _path1,
            path2 = _path2
        });

        currentBet = bet;
    }

    function requestMarketCapData() public returns (bytes32 requestId) {

        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillMultipleParameters.selector
        );
        req.add('url1', currentBet.apiEndpoint1);
        req.add('path1', currentBet.path1);
        req.add('url2', currentBet.apiEndpoint2);
        req.add('path2', currentBet.path2);
        sendChainlinkRequest(req, fee); // MWR API.

        // '[?(@.id=="bitcoin")].market_cap'

        // Multiply the result by 1000000000000000000 to remove decimals
        int256 timesAmount = 10**18;
        req.addInt('times', timesAmount);

        // Sends the request
        return sendChainlinkRequest(req, fee);
    }

    function fulfillMultipleParameters(
        bytes32 requestId,
        uint256 path1Response,
        uint256 path2Response
    ) public recordChainlinkFulfillment(requestId) {
        emit RequestMultipleFulfilled(requestId, path1Response, path2Response);
        variable1 = path1Response;
        variable2 = path2Response;
    }

        /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    }
    
}