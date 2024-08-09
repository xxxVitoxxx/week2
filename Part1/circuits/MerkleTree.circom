pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels
    signal input leaves[2**n];
    signal output root;

    component poseidon = Poseidon(2**n);
    for (var i = 0; i < 2**n; i++) {
        poseidon.inputs[i] <== leaves[i];
    }

    root <== poseidon.out;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    component level_hashers[n];
    component mux[n];

    signal hashes[n+1];
    hashes[0] <== leaf;

    for (var i = 0; i < n; i++) {
        level_hashers[i] = Poseidon(2);
        mux[i] = MultiMux1(2);

        // When path_index[i] = 0, the current element is on the left
        mux[i].c[0][0] <== hashes[i];
        mux[i].c[0][1] <== path_elements[i];

        // When path_index[i] = 1, the current element is on the right
        mux[i].c[1][0] <== path_elements[i];
        mux[i].c[1][1] <== hashes[i];

        mux[i].s <== path_index[i];
        level_hashers[i].inputs[0] <== mux[i].out[0];
        level_hashers[i].inputs[1] <== mux[i].out[1];

        hashes[i+1] <== level_hashers[i].out;
    }

    root <== hashes[n];
}
