pragma solidity ^0.8.4;


import "./BetAccessControl.sol";
/// @title Bet contract which contains all storage structures
/*
BetStorage.sol contains all events, structs, mappings, and global variables used in more derived contracts.
*/
contract BetStorage is BetAccessControl {

    /*** EVENTS ***/
    event LogMatchResultUpdate(string description);
    event LogNewOraclizeQuery(string description);
    event LogQueryId(bytes32 queryId);
    event UpdateAddress(string description, address addr);
    event NewWagerCreated(address indexed creator, uint indexed matchId, bytes20 wagerId, uint wagerType);
    event WagerAccepted(address indexed sender, address indexed creator, bytes20 indexed wagerId);
    event WagerSettled(bytes20 indexed wagerId, uint indexed matchId);
    event NewMatchCreated(uint indexed matchId);
    event MatchUpdated(uint indexed matchId, uint home, uint away, uint indexed status);
    //event LogParseResult(string description, uint home, uint away, uint status, uint matchId, uint startTime);
    //event RecordUpdated(address indexed player, bytes20 indexed wager, uint win, uint loss, uint draw, uint result); //emitted after a users wager is settled, and his record is updated

    /*** DATA TYPES ***/
    /// @dev The main Event struct. Every event/game in Bet is represented by a copy
    ///  of this structure. Note that the order of the members in this structure
    ///  is important because of the byte-packing rules used by Ethereum.
    ///  Ref: http://solidity.readthedocs.io/en/develop/miscellaneous.html
    struct Match {
        uint home; //int score of the match (home team)
        uint away; //int score of the match (away team)
        uint status; //int status of match (pre-game, in-progress, cancelled/postponed, final)
        uint256 startTime; //epoch time (unix time) of match start
        bool created; //to check for existence in mapping. Will always be true once created
        bytes20[] wagerIds; //array which holds all wagers associated with this match
    }

    struct Wager {
        //necessary Wager data we need to store on-chain
        address creator; //address of creator.
        address taker; //address of taker (will be address(0) if this is a pooledWager)
        uint creatorSide; //side of wager chosen by creator (this will represent a different value depending on wagerType) 1 == home team win (wagertype 0), draw win (wagertype 1), over (wagertype 2)
        uint takerSide; //side of wager chosen by taker (this will represent a different value depending on wagerType) 2 == away team win (wagertype 0), no-draw win (wagertype 1), under (wagertype 2)
        uint wagerType; //type of wager 0=team vs team, 1=draw vs no draw,  2=total (over/under),
        uint spread; // will be 0 in the case of no spread involved (odds only).  Will be > 0 for point spreads and totals
        uint256 creatorRisk; //tokens risked by creator of wager
        uint256 takerRisk;
        uint matchId; //match this wager belongs to
        bool isSettled; // has the match been settled (paid out) ?
    }

    /*** STORAGE ***/
    //variable to halt ability to send oraclize queries
    bool queriesArePaused = false;
    uint commission = 97;
    //variable to pause entire contract
    bool pauseContract = false;
    // gas limit we will give for Oraclizes' callback.
    //NOTE: we will not be refunded if we set a higher limit than necessary, so we must estimate carefully
    uint256 public oracleGasLimit = 400000;
    string public oracleDataSourceUrl = "tbd"; //XXX TBD
    address public newContractAddress;
    /// a string array which records total count of matches.
    uint[] public matches;
    // mapping of matchId's (within contract) to Match structs
    mapping(uint => Match) public matchStructsById;
    // mapping of oraclize query ids to validity bool
    mapping(bytes32 => address) public validQueryIds;
    // used to keep track of the validity of unique ids created for wagers
    mapping(bytes20 => uint32) blobInfo;
    // used to store all Wagers
    mapping(bytes20 => Wager) wagers;
    //maps a queryId to a wager ID
    mapping(bytes32 => bytes20) queryIdToWagerId;
}