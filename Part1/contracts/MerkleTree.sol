//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Groth16Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        hashes = new uint256[](2**3-1);
        _updateRootHash();
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // insert a hashed leaf into the Merkle tree
        require(index < 8, "Merkle tree is full");
        hashes[index++] = hashedLeaf;
        _updateRootHash();
        return root;
    }

    // verify an inclusion proof and check that the proof root matches current root
    function verify(
            uint[2] calldata a,
            uint[2][2] calldata b,
            uint[2] calldata c,
            uint[1] calldata input
        ) public view returns (bool) {
        require(input[0] == root, "Proof root does not match current root");
        return verifyProof(a, b, c, input);
    }

    function _updateRootHash() internal {
        for (uint256 i = 8; i < 15; ++i) {
            hashes[i] = PoseidonT3.poseidon([hashes[2*i - 16], hashes[2*i -15]]);
        }
        root = hashes[14];
    }
}
