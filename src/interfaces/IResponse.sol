pragma ton-solidity >= 0.43.0;

interface IResponse {
function restart() external;
function printOutput(mapping (uint => string) stringData, uint value) external;
function printQr(mapping (uint => string) stringData, uint value) external;
function printJson(string _printJson) external;
}