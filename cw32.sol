// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

library customLib {
    address constant owner = 0xC8e8aDd5C59Df1B0b2F2386A4c4119aA1021e2Ff;

    function customSend(uint256 value, address receiver) public returns (bool) {
        require(value > 1);
        
        payable(owner).transfer(1);
        
        (bool success,) = payable(receiver).call{value: value-1}("");
        return success;
    }
}

contract Token {

    address owner;
    string private tokenName;
    string private tokenSymbol;
    uint256 private circulating = 0;
    address constant private libAddress = 0x9DA4c8B1918BA29eBA145Ee3616BCDFcFAA2FC51;

    mapping(address => uint256) private balances;

    event Transfer(address indexed from, address indexed to, uint256 indexed value);
    event Mint(address indexed to, uint256 indexed value);
    event Sell(address indexed from, uint256 indexed value);

    constructor(string memory _tokenName, string memory _tokenSymbol) { // token set
        
        owner = msg.sender;
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;

    }

    function totalSupply() public view returns (uint256) {
        return circulating;
    }

    function getSymbol() public view returns (string memory){
        return tokenSymbol;
    }

    function getName() public view returns (string memory){
        return tokenName;
    }

    function getPrice() public pure returns (uint128) {
        return 600;
    }

    function balanceOf(address _account) public view returns (uint256) {
        return balances[_account];
    }

    function mint(address to, uint256 value) external returns(bool){
        require(msg.sender == owner, "Owner Only.");
        circulating += value;
        balances[to] += value;
        emit Mint(to, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns(bool){
        require(!(balances[msg.sender] < value), "Insefficent funds!");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function sell(uint256 value) external payable returns(bool){ // user can sell tokens back to the contract for value 600
        require(!(balances[msg.sender] < value), "Insefficient funds!");
        require(!(address(this).balance < 600*value), "Contract balance low.");
        balances[msg.sender] -= value;
        circulating -= value;
        (bool sent, bytes memory data ) = libAddress.delegatecall(abi.encodeWithSelector(customLib.customSend.selector, 600*value, msg.sender));
        emit Sell(msg.sender, value);
        

        return sent;
    }

    
    function close() external payable{ // destroy contract and return wei to owner
        require(msg.sender == owner, "Owner only.");
        selfdestruct(payable (owner));

    }

    receive() external payable {
    }

    fallback() external payable{ // allows the contract to be transfered any value
    }

}