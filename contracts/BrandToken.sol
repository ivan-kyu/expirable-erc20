// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

import "hardhat/console.sol";

contract BrandToken is ERC20PresetMinterPauser, ERC20Permit {
    struct TokenBatch {
        uint256 amount;
        uint256 expiryDate;
    }

    event BatchCreated(address caller, uint256 amount, uint256 expiryDate);

    mapping(uint256 => TokenBatch) public tokenBatches;
    uint256 public lastBatchId;
    uint256 public firstBatchWithSomeTokens;
    uint256 public expiryPeriod;

    constructor(uint256 _expiryPeriod) ERC20PresetMinterPauser("Brand Token", "BRD") ERC20Permit("Brand Token") {
        expiryPeriod = _expiryPeriod;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        virtual
        override(ERC20, ERC20PresetMinterPauser)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function mintBatch(address _to, uint256 _amount) public {
        tokenBatches[lastBatchId++] = TokenBatch(_amount, block.timestamp + expiryPeriod);
        _mint(_to, _amount);

        emit BatchCreated(_msgSender(), _amount, block.timestamp + expiryPeriod);
    }

    function transfer(address _to, uint256 _amount) public virtual override returns (bool) {
        if (balanceOf(_msgSender()) < _amount) {
            revert("Not enough tokens");
        }

        TokenBatch storage tokenBatch = tokenBatches[firstBatchWithSomeTokens];

        if (tokenBatch.amount >= _amount) {
            tokenBatch.amount -= _amount;
            _transfer(_msgSender(), _to, _amount);
            return true;
        } else {
            // update batches amounts
            uint256 subtractedTokens = 0;
            while (subtractedTokens < _amount) {
                tokenBatch = tokenBatches[firstBatchWithSomeTokens];
                if (tokenBatch.expiryDate == 0) {
                    revert("Not enough minted batches");
                }

                if (block.timestamp > tokenBatch.expiryDate) {
                    if (firstBatchWithSomeTokens + 1 > lastBatchId) {
                        revert("Not enough unexpired minted batches");
                    }
                    firstBatchWithSomeTokens++;
                    continue;
                }

                uint256 amountToSubtract = _amount - subtractedTokens;

                if (amountToSubtract <= tokenBatch.amount) {
                    tokenBatch.amount -= amountToSubtract;
                    subtractedTokens += amountToSubtract;
                } else {
                    subtractedTokens += tokenBatch.amount;
                    tokenBatch.amount = 0;
                    firstBatchWithSomeTokens++;
                }
            }

            _transfer(_msgSender(), _to, _amount);
            return true;
        }
    }
}
