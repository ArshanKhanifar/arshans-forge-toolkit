// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {WETH} from "solmate/tokens/WETH.sol";
import {BaseChainSetup} from "./BaseChainSetup.sol";

contract WethMintHelper is BaseChainSetup {
    mapping(string => address) wethWhaleLookup;

    function _setupWhaleInfo() private {
        wethWhaleLookup["avalanche"] = address(
            0xe50fA9b3c56FfB159cB0FCA61F5c9D750e8128c8
        );
        wethWhaleLookup["polygon"] = address(
            0x28424507fefb6f7f8E9D3860F56504E4e5f5f390
        );
    }

    function setupWethHelperInfo() public {
        _setupWhaleInfo();
    }

    function mintWrappedTo(
        string memory chain,
        address to,
        uint256 amount
    ) public {
        startImpersonating(to);
        dealTo(chain, to, to.balance + amount);
        WETH(getWrapped(chain)).deposit{value: amount}();
        stopImpersonating();
    }

    function mintWethTo(
        string memory chain,
        address to,
        uint256 amount
    ) public {
        switchTo(chain);
        if (gasEthLookup[chain]) {
            mintWrappedTo(chain, to, amount);
        } else {
            address whale = wethWhaleLookup[chain];
            if (whale == address(0)) {
                revert(string.concat("no weth whale for chain ", chain));
            }
            startImpersonating(whale);
            ERC20(wethLookup[chain]).transfer(to, amount);
            stopImpersonating();
        }
    }
}
