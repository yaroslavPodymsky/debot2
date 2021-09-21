pragma ton-solidity >=0.43.0;

interface IB {
    function entryPointInput() external;
    function entryPointOutput() external;
    function entryOutputQr() external;
    function entryOutputJson() external;
}