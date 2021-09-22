"pragma ton-solidity >=0.43.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "./interfaces/IResponse.sol";
import "./interfaces/IB.sol";
import "./debot-interfaces/Debot.sol";
import "./debot-interfaces/Terminal.sol";
import "./debot-interfaces/Menu.sol";
import "./debot-interfaces/QRCode.sol";
import "./debot-interfaces/DateTimeInput.sol";
import "./debot-interfaces/Msg.sol";
import "./debot-interfaces/ConfirmInput.sol";
import "./debot-interfaces/AddressInput.sol";
import "./debot-interfaces/NumberInput.sol";
import "./debot-interfaces/AmountInput.sol";
import "./debot-interfaces/Sdk.sol";
import "./debot-interfaces/Upgradable.sol";
import "./debot-interfaces/UserInfo.sol";
import "./debot-interfaces/SigningBoxInput.sol";
import "./debot-interfaces/Json.sol";


contract TDA is Debot {
    
    address m_debotB;

    constructor(address b) public {
        tvm.accept();
        m_debotB = b;
    }

    function start() public override {
        Terminal.print(0, "Hi, i'm DeBot A.");
        mainMenu(0);
    }

    function mainMenu(uint32 index) public {
        index;
        restart();
    }

    function restart() public {
        MenuItem[] items;
        items.push(MenuItem("ввод данных", "", tvm.functionId(invokeDataEntryMenu)));
        items.push(MenuItem("вывод данных", "", tvm.functionId(invokeOutputOfDataByKey)));
        items.push(MenuItem("вывод qr", "", tvm.functionId(invokeOutputOfQrDataByKey)));
        items.push(MenuItem("вывод json", "", tvm.functionId(invokeOutputOfJsonByKey)));
        Menu.select("Menu:", "", items);
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////                                                 input                                              //////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function invokeDataEntryMenu(uint32 index) public view {index;
        IB(m_debotB).entryPointInput();
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////                                                 OutputData                                         //////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function invokeOutputOfDataByKey(uint32 index) public view {index;
        IB(m_debotB).entryPointOutput();
    }

    function printOutput(mapping (uint => string) stringData, uint value) public {
        Terminal.print(0, format("значения по введенному ключу  {}: {}", value, stringData[value]));
        this.restart();
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////                                                 qr                                                 //////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function invokeOutputOfQrDataByKey(uint32 index) public view {index;
        IB(m_debotB).entryOutputQr();
    }

    function printQr(mapping (uint => string) stringData, uint value) public {
        QRCode.draw(tvm.functionId(returnQr), "QR",  stringData[value]);
    }

    function returnQr(QRStatus result) public {
        this.restart();
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////                                                 json                                               //////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function invokeOutputOfJsonByKey(uint32 index) public view {
        IB(m_debotB).entryOutputJson();
    }

    function printJson(string _printJson) public {
        Terminal.print(0,format("{}", _printJson));
        this.restart();
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////                                                                                                    //////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "DePass Event Manager";
        version = "0.0.1-beta";
        publisher = "TON Surf";
        key = "";
        author = "TON Surf";
        support = address.makeAddrStd(0, 0x606545c3b681489f2c217782e2da2399b0aed8640ccbcf9884f75648304dbc77);   // TODO!!
        hello = "Hello, I’m DePass Event Manager Debot, and I’m here to help you Surf.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = "";
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID ];
    }
}"
