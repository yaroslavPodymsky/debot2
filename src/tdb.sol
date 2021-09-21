pragma ton-solidity >=0.43.0;
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

contract TDB is Debot {

    address m_sender;
    string  entString;
    int256 entNumber;
    address entAddress;
    uint keyData;
    int128 entDate;
    int128 entTime;
    string json;

    mapping (uint => string) public stringData;

    struct Info{
        string  entString;
        int256 entNumber;
        address entAddress;
        int128 entDate;
        int128 entTime;
    }

    constructor() public {
      tvm.accept();
    }

    function start() public override {
        mainMenu(0);
    }

    function mainMenu(uint32 index) public {
        index;
        dataEntryMenu();
    }

    function entryPointInput() public {
        m_sender = msg.sender;
        dataEntryMenu();
    }

    function dataEntryMenu() public {
        MenuItem[] items;
        if(entString == '') {
            items.push(MenuItem("строка", "", tvm.functionId(enteringString)));
        }
        if(entNumber == 0) {
            items.push(MenuItem("число", "", tvm.functionId(enteringNumber)));
        }
        if(entAddress == address(0)) {
            items.push(MenuItem("адрес", "", tvm.functionId(enteringAddress)));
        }
        if(entDate == 0) {
            items.push(MenuItem("дата", "", tvm.functionId(enteringDate)));
        }
        if(entTime == 0) {
            items.push(MenuItem("время", "", tvm.functionId(enteringTime)));
        }
        items.push(MenuItem("проверить введенные данные", "", tvm.functionId(dataConfirmation)));
        Menu.select("жми на кнопку", "", items);
    }

    function dataEeditMenu() public {
        MenuItem[] items;
        items.push(MenuItem("строка", "", tvm.functionId(enteringString)));
        items.push(MenuItem("число", "", tvm.functionId(enteringNumber)));
        items.push(MenuItem("адрес", "", tvm.functionId(enteringAddress)));
        items.push(MenuItem("дата", "", tvm.functionId(enteringDate)));
        items.push(MenuItem("время", "", tvm.functionId(enteringTime)));
        items.push(MenuItem("проверить введенные данные", "", tvm.functionId(dataConfirmation)));
        Menu.select("жми на кнопку", "", items);
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////                                                 dataEdit                                           //////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function dataEdit() public {
        Terminal.print(0, "редаткирование");
        this.dataEeditMenu();
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////                                                 Confirm                                            //////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function confirm() public {
        ConfirmInput.get(tvm.functionId(setConfirm), "подтвердить");
    }
    function setConfirm(bool value) public {
        if(value == false) {
        dataEdit();
        } else if(value == true){
        dataEnteringOk();
        }
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////                                                 input                                              //////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function enteringString(uint32 index) public { index;
        Terminal.input(tvm.functionId(setEnteringString), "введите строку", false);
    }

    function setEnteringString(string value) public {
        entString = value;
        dataEntryMenu();
    }

    function enteringNumber(uint32 index) public { index;
        AmountInput.get(tvm.functionId(setEnteringNumber), "введите число",0, 0, 100e9);
    }

    function setEnteringNumber(int256 value) public {
        if(value == int256(0)) {
            Terminal.print(0, "число не может быть равно нулю");
            dataEntryMenu();
        } else {
            entNumber = value;
            dataEntryMenu();
        }
    }

    function enteringAddress(uint32 index) public { index;
        AddressInput.get(tvm.functionId(setEnteringAddress), "введите адрес" );
    }

    function setEnteringAddress(address value) public {
        entAddress = value;
        dataEntryMenu();
    }

    function enteringDate(uint32 index) public { index;
        DateTimeInput.getDate(tvm.functionId(setEnteringDate),
        "Choose a day in 2021 from the begining until current day:",
        int128(now), 1609448400, int128(now));
    }

    function setEnteringDate(int128 date) public {
        entDate = date;
        dataEntryMenu();
    }

    function enteringTime(uint32 index) public { index;
        DateTimeInput.getTime(tvm.functionId(setEnteringTime), "Choose a day time (local):", 55800, 55800, 86100, 1);
    }

    function setEnteringTime(uint32 time) public {
        entTime = time;
        dataEntryMenu();
    }

    function dataConfirmation(uint32 index) public {index;
        Terminal.print(0, format("\nстрока:{}\nчисло:{}\nадрес:{}\nдата:{}\nвремя:{}",
            entString,
            entNumber,
            entAddress,
            entDate,
            entTime
        ));
        confirm();
    }

    function dataEnteringOk() public {
        if( entString == "" &&
            entNumber == 0 &&
            entAddress == address(0) &&
            entDate == 0 &&
            entTime == 0) {
                Terminal.print(0, "введены не корректные данные");
                dataEntryMenu();
        } else {
            json = format("{\"entString\":\"{}\",\"entNumber\":\"{}\",\"entAddress\":\"{}\",\"entDate\":\"{}\",\"entTime\":\"{}\"}",
                entString,
                entNumber,
                entAddress,
                entDate,
                entTime
            );
            stringData[keyData] = json;
            Terminal.print(0, format("введённые данные записаны по ключу: {} ", keyData ));
            keyData++;
            entString = "";
            entNumber = 0;
            entAddress = address(0);
            entDate = 0;
            entTime = 0;
            invokeRestart();
        }
    }

    function invokeRestart() public view {
        IResponse(m_sender).restart();
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////                                                 OutputData                                         //////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function entryPointOutput() public {
        m_sender = msg.sender;
        outputOfDataByKey();
    }

    function outputOfDataByKey() public {
        AmountInput.get(tvm.functionId(getOutput), "введите ключ", 0, 0, 1000);
    }

    function getOutput(uint value) public {
        if(stringData.exists(value)){
            returnData(stringData, value);
        } else {
            Terminal.print(0, "по данному ключу нет данных");
            this.outputOfDataByKey();
        }
    }

    function returnData(mapping (uint => string) stringDataCurrent, uint value) public view {
        IResponse(m_sender).printOutput(stringDataCurrent, value);
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////                                                 qr                                                 //////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////            
    function entryOutputQr() public {
        m_sender = msg.sender;
        outputOfQrByKey();
    }

    function outputOfQrByKey() public {
        AmountInput.get(tvm.functionId(getOutputQr), "введите ключ", 0, 0, 1000);
    }

    function getOutputQr(uint value) public {
         if(stringData.exists(value)){
            returnQr(stringData, value);
        } else {
            Terminal.print(0, "по данному ключу нет данных");
            this.outputOfQrByKey();
        }
    }

    function returnQr(mapping (uint => string) stringDataCurrent, uint value) public {
        IResponse(m_sender).printQr(stringDataCurrent, value);
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////                                                 json                                               //////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function entryOutputJson() public {
        m_sender = msg.sender;
        outputOfJsonByKey();
    }

    function outputOfJsonByKey() public {
        AmountInput.get(tvm.functionId(getOutputJson), "введите ключ", 0, 0, 1000);
    }

    function getOutputJson(uint value) public {
        if(stringData.exists(value)){
            acceptsValueMapping(stringData[value]);
        } else {
            Terminal.print(0, "по данному ключу нет данных");
            this.outputOfJsonByKey();
        }
    }

    function acceptsValueMapping(string value) public {
        Json.deserialize(tvm.functionId(resultJson), value);
    }

    function resultJson(bool result, Info obj) public {
        string _entString = obj.entString;
        int256 _entNumber = obj.entNumber;
        address _entAddress = obj.entAddress;
        int128 _entDate = obj.entDate;
        int128 _entTime = obj.entTime;
        string _printJson = format("значения json\nстрока:{}\nчисло:{}\nадрес:{}\nдата:{}\nвремя:{}", _entString, _entNumber, _entAddress, _entDate, _entTime);
        returnJson(_printJson);
    }

    function returnJson(string _printJson) public {
        IResponse(m_sender).printJson(_printJson);
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
        return [ Terminal.ID ];
    }
}