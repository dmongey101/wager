// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';

contract Wager is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    address public override owner;
    uint256 btcMarketCap;
    uint256 ethMarketCap;
    bytes32 private jobId;
    uint256 private fee;

    struct Bet {
        address person1;
        address person2;
        string apiEndpoint;
    }

    constructor() {
        owner = msg.sender,
    }

    function deployWager(address _person1, address _person2, string _apiEndpoint) public {
        Bet memory bet = new Bet({
            person1 = _person1,
            person2 = _person2,
            apiEndpoint = _api_endPoint
        });
    }

    function requestMarketCapData() public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        // Set the URL to perform the GET request on
        req.add('get', 'https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD');

        // Set the path to find the desired data in the API response, where the response format is:
        // {"RAW":
        //   {"ETH":
        //    {"USD":
        //     {
        //      "VOLUME24HOUR": xxx.xxx,
        //     }
        //    }
        //   }
        //  }
        // request.add("path", "RAW.ETH.USD.VOLUME24HOUR"); // Chainlink nodes prior to 1.0.0 support this format
        req.add('path', 'RAW,ETH,USD,VOLUME24HOUR'); // Chainlink nodes 1.0.0 and later support this format

        // Multiply the result by 1000000000000000000 to remove decimals
        int256 timesAmount = 10**18;
        req.addInt('times', timesAmount);

        // Sends the request
        return sendChainlinkRequest(req, fee);
    } 
}