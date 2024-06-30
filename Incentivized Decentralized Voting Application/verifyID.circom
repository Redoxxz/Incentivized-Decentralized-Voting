pragma circom 2.1.6;

template CheckRange() {
    signal input num;
    signal output isValid;

    signal diff1 = num - 9999999999;
    signal diff2 = 1000000000 - num;

    isValid <== (diff1 >= 0) && (diff2 >= 0);
}

component main = CheckRange();
