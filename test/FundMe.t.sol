//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
   address USER = makeAddr("user");
   uint256 constant SEND_VALUE = 0.1 ether;
   uint256 constant START_BALANCE = 100 ether;
   FundMe fundMe;
    function setUp() external {
         DeployFundMe deployFundMe = new DeployFundMe();
         fundMe = deployFundMe.run();
         vm.deal(USER, START_BALANCE);
       
    }

    function testMinimumDollarIsFive () public {
       assertEq(fundMe.MINIMUM_USD(), 5e18);
    }
    
    function testOnwerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }


    ///UNIT TEST
    /// --test functions - specific part of code
    ///INTEGRATION
    /// -- testing how code works with other parts of code
    ///FORKED
    /// -- testing code is simulated environment
    /// STAGING
    /// -- testing code on real chain (real envrionment)
    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq (version, 4);
    }

    function testFundFailIfEnoughFundsNotSent() public {
        vm.expectRevert();
      fundMe.fund();
    }

    function testFundPassIfEnoughFundSent() public funded {
       
        uint256 amountFunded =  fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFundersToArrayOfFunders() public funded{
       
        address funder = fundMe.getFunder(0);
        assertEq (funder, USER);


    }

    modifier funded (){
        vm.prank(USER);
        fundMe.fund{value :SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw () public funded{
       

         vm.expectRevert();
         vm.prank(USER);
         fundMe.withdraw();
    }

    function testWithddrawWithASingleFunder() public funded {
        //arrage
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
       ///act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        ///assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq (startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);

        
    }

    function testWithddrawWithMultiFunders() public funded {
        //arrage
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i= startingFunderIndex; i< numberOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq (startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
        
    }

    function testWithdrawMultipleCheap() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i= startingFunderIndex; i< numberOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq (startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }
}