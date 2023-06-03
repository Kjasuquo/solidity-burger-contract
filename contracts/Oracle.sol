// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.0 < 0.9.0;

import "https://github.com/provable-things/ethereum-api/blob/master/provableAPI.sol";

contract Oracle is usingProvable{
    string public activity;

    function getActivity() public payable {
        provable_query("URL", "json(https://www.boredapi.com/api/activity/).activity");
    }

    function __callback(bytes32 _myid, string memory _result) public{
        require(msg.sender== provable_cbAddress());
        activity = _result;
        _myid;
    }
}