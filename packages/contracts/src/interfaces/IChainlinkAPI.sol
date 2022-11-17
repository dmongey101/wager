// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IChainlinkAPI {

    function requestData(string memory url, string memory path) external returns (bytes32);

    function getData(bytes32 requestId) external view returns (uint256);
    
    function withdrawLink() external;
}