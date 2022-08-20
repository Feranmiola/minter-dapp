// SPDX-License-Identifier: UNLICENCED
pragma solidity >=0.5.0;

interface IPancakePair {
    function balanceOf(address owner) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}