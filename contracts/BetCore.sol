pragma solidity ^0.8.4;


import "./BetOracle.sol";
import "./SafeMath.sol";

/*
BetCore.sol will be the most derived contract of the contract inheritance tree.
This means that when deploying, BetCore.sol should be the only file deployed to the network
This file sets privileged addresses within the constructor, in addition to instantiating the Bet Token contract
All functions relating to reading data (wager, match, user) are contained here
All functions relating to CRUD operations for Wagers are contained here (create, accept, settle).
*/
contract BetCore is BetOracle {

    using SafeMath for uint256;

    constructor() public payable {
        //FOR PRIVATE TESTNET ONLY (ethereum-bridge OAR requirement)
        //OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);//add this line if you are using Oraclize in private chain environment

        // Starts paused.  ******** XXX CHANGE TO TRUE BEFORE DEPLOYING TO MAIN NET ************
        //paused = false;
        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;
        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;
        //set oraclize gas price to 2Gwei
        //setOraclizeGasPrice(2000000000);
        //getMatchResults();
    }

    // fallback function for sending ether to this.balance (for oraclize transactions)
    fallback() external payable {}

    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    function unpause()
        public
        onlyCEO
        whenPaused
        override
    {
        // Actually unpause the contract.
        super.unpause();
    }

    function setNewAddress(address _v2Address)
        public
        onlyCEO
        whenPaused
    {
        // See README.md for updgrade plan
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
    }

    /// how much ether does this contract hold?
    function etherBalance()
        public
        view
        returns (uint)
    {
        return address(this).balance;
    }

    function pauseQueries()
        public
        onlyCEO
    {
        queriesArePaused = !queriesArePaused;
    }

    /// @notice Returns all the relevant information about a specific Match.
    function getMatch(uint matchId)
        public
        view
        returns (
        bytes20[] memory wagerIds, //an array of all wagerIds belonging to this match
        uint status, //status as provided by opta 0, 1, 2, 3, or 4
        uint home, // score of the home team
        uint away, // score of the away team
        uint startTime  // time (in unix epoch time) when match begins
    ) {
        Match storage gotMatch = matchStructsById[matchId];

        wagerIds = gotMatch.wagerIds;
        status = gotMatch.status;
        home = gotMatch.home;
        away = gotMatch.away;
        startTime = gotMatch.startTime;
    }

    /// @notice Returns all the relevant information about a specific Wager.
    function getWager(bytes20 _wagerId)
        public
        view
        returns (
        address creator, //address of creator.
        address taker, //address of taker
        uint creatorSide, //side of wager chosen by creator  1 == home, 2 == away, 3 == draw
        uint takerSide, //side of wager chosen by taker, 1 == home, 2 == away, 3 == draw
        uint256 creatorRisk, //tokens risked by creator of wager
        uint256 takerRisk,
        uint wagerType, //either 0, 1, 2 for straight team vs team, draw vs no-draw, or over vs under
        uint spread, //as of now (4/4/2018), spread only is used if wagerType=0.  Else, spread is unused.
        bool isSettled, // has this match been settled
        uint matchId // what match does this wager belong to?
    ) {
        Wager storage wager = wagers[_wagerId];

        creator = wager.creator;
        taker = wager.taker;
        creatorSide = wager.creatorSide;
        takerSide = wager.takerSide;
        creatorRisk = wager.creatorRisk;
        takerRisk = wager.takerRisk;
        wagerType = wager.wagerType;
        spread = wager.spread;
        isSettled = wager.isSettled;
        matchId = wager.matchId;
    }

    /// @dev A public method that creates a new wager and stores it
    function createWager(
        uint _creatorSide, //can be 1 (home, draw, or over) or 2 (away, no-draw, under)
        uint256 _creatorRisk, //amount creator wishes to risk on the wager
        uint256 _takerRisk,  //amount creator sets for the taker, based on odds set by creator in the front-end
        uint _wagerType, //either 0, 1, 2.  wagerType will dictate what "creatorSide" and "takerSide" represent
        uint _spread, // _spread > 0, and will only be applied if _wagerType=2
        uint matchId, // what match does this wager belong to
        string memory sport //only used if a new match must be created
    )
        public
        payable
        whenNotPaused
        returns (bytes20)
    {
        require(_creatorRisk > 0 && _takerRisk > 0);
        require(_creatorSide == 1 || _creatorSide == 2);
        require(_spread < 100000);

        // Wager memory _wager = Wager({
        //     creator: msg.sender,
        //     taker: address(0),
        //     creatorSide: _creatorSide,
        //     takerSide: _creatorSide == 1 ? 2 : 1,
        //     wagerType: _wagerType,
        //     spread: _spread,
        //     creatorRisk: _creatorRisk,
        //     takerRisk: _takerRisk,
        //     matchId: matchId,
        //     isSettled: false
        // });

        // //add this wager object to the array of Wager structs within the matchStructsByContractId storage
        // bytes20 newWagerId = createUniqueId(msg.sender);
        // wagers[newWagerId] = _wager;

        // Match storage gotMatch = matchStructsById[matchId];
        // //only attempt to create if match is not yet created.
        // if(!gotMatch.created) {
        //   if (oraclize_getPrice("URL", 100000) > msg.value || oraclize_getPrice("URL", 2000000) < msg.value) {
        //       emit LogNewOraclizeQuery("Query fee was either too low or too high. ");
        //       revert();
        //   } else {
        //       createFirstWagerOfMatch(newWagerId, sport, matchId);
        //   }
        // } else {
        //    // make sure match exists and hasnt started and has a status of 0
        //   require(gotMatch.created && gotMatch.startTime >= now && gotMatch.status < 1);

        //   gotMatch.wagerIds.push(newWagerId);
        // }
        // //THE ONLY DANGER HERE IS IF THE USER ATTEMPTS TO CREATE A WAGER FOR A MATCH WHICH DOESNT EXIST,
        // //AND A QUERY IS MADE TO THE API TO RETRIEVE AND ATTEMPT TO CREATE THAT MATCH
        // //AND THE RESPONSE IS A 500/ERROR, THE INITAL WAGER CREATION/TOKEN TRANSFER WILL COMPLETE SUCCESSFULLY
        // //THOUGH THE WAGER WILL NOT BE ASSIGNED TO A VALID MATCH

        // ///FIX
        // //require(rToken.transferToSportsContract(msg.sender, _creatorRisk)); //make sure token transfer succeeds

        // // emit the wager creation event
        // emit NewWagerCreated(
        //     _wager.creator,
        //     matchId,
        //     newWagerId,
        //     _wagerType
        // );

        return "";
    }

    /// called by a user who wishes to accept a wager which has been created by another user
    function acceptWager(
        uint256 _amountToRisk,
        bytes20 _wagerId // the id of the wager the user wants to accept
    )
        public
        whenNotPaused
        returns (bool)
    {
        Wager storage wager = wagers[_wagerId];
        require(wager.taker == address(0)); //bet must not be taken.
        require(wager.creator != msg.sender); //creator must not be address who accepts the wager
        //require(_amountToRisk > 0);

        Match storage gotMatch = matchStructsById[wager.matchId]; //locate matchId from Wager in storage
        // make sure match exists and hasnt started and has a status of 0
        require(gotMatch.created && gotMatch.startTime >= block.timestamp && gotMatch.status < 1);

        require(_amountToRisk == wager.takerRisk);
        //require(_amountToProfit == wager.creatorRisk);
        //if this is a straight bet, add msg.sender address to 'taker' field, and add tokens to
        wager.taker = msg.sender;

        //XXX FIX
        //require(rToken.transferToSportsContract(msg.sender, _amountToRisk)); //make sure token transfer succeeds

        emit WagerAccepted(
            wager.taker,
            wager.creator,
            _wagerId
        );

        return true;
    }

    /**
    * @dev Creates a new blob. It is guaranteed that different users will never receive the same blobId, even before consensus has been reached. This prevents blobId sniping. Consider createWithNonce() if not calling from another contract.
    */
    function createUniqueId(address creator)
        internal
        returns (bytes20)
    {
        // Generate the blobId.
        bytes20 blobId = "";
        return blobId;
    }
}