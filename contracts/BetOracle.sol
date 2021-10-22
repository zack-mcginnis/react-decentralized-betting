pragma solidity ^0.8.4;
//import "./usingOraclize.sol";
//import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
//import "github.com/Arachnid/solidity-stringutils/src/strings.sol";
//import "oraclize-api/contracts/usingOraclize.sol";
// import "../installed_contracts/oraclize-api/contracts/usingOraclize.sol";
// import "../installed_contracts/strings/strings.sol";
import "./SafeMath.sol";
import "./BetStorage.sol";
/// @title Bet contract which communicates with Oraclize, refunds, and settles wagers

/*
BetnOracle.sol is responsible for interacting with the oracle service (Oraclize as of 4/4/2018).
The oracle service will query a trusted data source (Opta sports) for up-to-date match scores.
The response must be parsed as it is returned to the contract as a string.
If there are matches which are in-progress or are starting < 24 hours, the contract will send
a query to the oracle service once every hour
If there are not matches in-progress, and no matches starting < 24 hours, the contract will send
a query to the oracle service once every 24 hours, until it finds a match beginning < 24 hours.
The oracle service response will trigger match creation and match updates in storage.  It will not
settle wagers within the matches.  This process is completed by the user (once the match has been updated to "complete")
*/
contract BetOracle is BetStorage {

    using SafeMath for uint256;

    modifier onlyCLevelOrOracle() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
            // msg.sender == oraclize_cbAddress()
        );
        _;
    }

    // modifier onlyOraclize() {
    //     require(msg.sender == oraclize_cbAddress());
    //     _;
    // }

    modifier whenNotPaused() override {
        require(paused == false);
        _;
    }

    //pause or unpause the queriesArePaused variable
    function pauseQuery()
        public
        onlyCLevelOrOracle
        whenNotPaused
    {
        queriesArePaused = true;
    }

    //pause or unpause the queriesArePaused variable
    function unPauseQuery()
        public
        onlyCLevelOrOracle
        whenNotPaused
    {
        queriesArePaused = false;
    }

    //update oracalize gas price
    function setOraclizeGasPrice(uint newGasPrice)
        public
        onlyCLevelOrOracle
        whenNotPaused
    { //2000000000 = 2GWei
        // oraclize_setCustomGasPrice(newGasPrice); //newGasPrice should be in wei units e.g. 2000000000 for 2GWei
        // OraclizeGasPriceUpdated("Oraclize gas price has been updated.", newGasPrice);
    }

    //update oraclize query delay
    //function updateQueryDelay(uint256 _delay) public onlyCLevelOrOracle whenNotPaused { delay = _delay; }

    //get oraclize gas cost for user to pay when verifying token from api
    function getGasCostForValidation() public returns (uint) {
        return 1;
        // return oraclize_getPrice("URL", 100000);
    }

    //update oraclize gas limit
    function updateOraclizeGasLimit(uint newGasLimit)
      public
      onlyCLevelOrOracle
      whenNotPaused
    {
      oracleGasLimit = newGasLimit;
    }

    //update oraclize data source url
    function updateOracleDataSourceUrl(string memory newUrl)
      public
      onlyCLevelOrOracle
      whenNotPaused
    {
      oracleDataSourceUrl = newUrl;
    }

    function constructUrl(string memory sport, uint matchId)
      internal
      whenNotPaused
      returns (string memory)
    {
      return '';
      //return "json(".toSlice().concat(sliceUrl).toSlice().concat(sliceSport).toSlice().concat("/".toSlice()).toSlice().concat(sliceMatchId).toSlice().concat(").[0]".toSlice());
    }

    //function which will be called to make Oraclize query to ?
    //we need to pay ether for this transaction, so we mark it as payable.
    //the ether will be supplied by this.balance within the contract.
    function getMatchResults(string memory sport, uint matchId, bytes20 wagerId)
        internal
        whenNotPaused
    {

      if (!queriesArePaused) {

        //   bytes32 queryId = oraclize_query("URL", constructUrl(sport, matchId), oracleGasLimit);

        //   validQueryIds[queryId] = address(this);//we reuse this mapping by putting in our contract address if the query exists
        //   queryIdToWagerId[queryId] = wagerId;

          //log .... XXX
          emit LogNewOraclizeQuery("Oraclize queries were sent, standing by for the answer..");
          //validIds[queryId] = true;
      } else {
          emit LogNewOraclizeQuery("Oraclize query was NOT sent");
      }
    }

    //callback function will be called when Opta query is returned
    // function __callback(
    //     bytes32 myid,
    //     string response,
    //     bytes proof
    // )
    //     whenNotPaused
    // {
    //     //LogMatchResultId("Logging match result id within callback...", myid);
    //     //if (validQueryIds[myid] == address(0)) revert(); //check if for query validity. a valid query will either have an address to add, or 'this'
    //     if (msg.sender != oraclize_cbAddress()) revert();
    //     if (validQueryIds[myid] == address(this)) {//THIS WILL BE TRUE FOR MATCH UPDATE (which occur when the first user attempts to settle a wager)
    //         parseMatchResult(queryIdToWagerId[myid], response);
    //     } else if (validQueryIds[myid] == address(0)) { //THIS WILL BE TRUE WHEN A USER ATTEMPTS TO CREATE A WAGER FOR A MATCH WHICH HAS NOT YET STARTED
    //         //create match, and add wager to it
    //         require(createMatchAndWager(queryIdToWagerId[myid], response));
    //     } else {
    //       //shouldn't get here
    //       revert();
    //     }
    //     delete queryIdToWagerId[myid];
    //     delete validQueryIds[myid]; //remove queryId from storage
    // }

    function parseMatchResult(bytes20 wagerId, string memory response)
        internal
        onlyCLevelOrOracle
        whenNotPaused
        returns (bool)
    {

        // bytes individualMatch = response.toSlice();

        // uint home = parseInt(individualMatch.copy().find("\"homeScore\": ".toSlice()).split(",".toSlice()).beyond("\"homeScore\": ".toSlice()).toString());
        // uint away = parseInt(individualMatch.copy().find("\"awayScore\": ".toSlice()).split(",".toSlice()).beyond("\"awayScore\": ".toSlice()).toString());
        // uint status = parseInt(individualMatch.copy().find("\"status\": ".toSlice()).split(",".toSlice()).beyond("\"status\": ".toSlice()).toString());
        // //uint startTime = parseInt(individualMatch.copy().find("\"startTime\": ".toSlice()).split(",".toSlice()).beyond("\"startTime\": ".toSlice()).toString());
        // uint matchId = parseInt(individualMatch.copy().find("\"gameId\": ".toSlice()).split(",".toSlice()).beyond("\"gameId\": ".toSlice()).toString());

        // Match storage _match = matchStructsById[matchId];


        // if (status == 4) {
        // //if updated status is final, and previous status is not final, settle all wagers
        //     if (_match.status != 4) {
        //         //LogMatchResultUpdate("Match has gone final. Settling wagers...", matchId);
        //         require(updateMatch(matchId, home, away, status, wagerId));
        //     }//ignore otherwise
        // } else if (status == 3) {
        // //if updated status is postponed, and old status was not postponed, refund all wagers
        //     if (_match.status != 3) {
        //         //LogMatchResultUpdate("Match has been cancelled. Refunding wagers...", matchId);
        //         require(updateMatch(matchId, home, away, status, wagerId));
        //     }//ignore otherwise
        // } else {
        //   //status is either pending (game hasn't yet started), or in progress
        //     //LogMatchResultUpdate("Nothing to update. Skipping match...", matchId);
        //     //countOfActiveMatches++;
        // }

        //log result of update
        emit LogMatchResultUpdate("match update success");

        return true;
    }

    /// creates a match if a new match is received from oracle/opta api callback
    function createMatchAndWager(
        bytes20 wagerId,
        string memory response
    )
        internal
        onlyCLevelOrOracle
        whenNotPaused
        returns (bool)
    {

        // bytes individualMatch = response.toSlice();

        // uint startTime = parseInt(individualMatch.copy().find("\"startTime\": ".toSlice()).split(",".toSlice()).beyond("\"startTime\": ".toSlice()).toString());
        // uint matchId = parseInt(individualMatch.copy().find("\"gameId\": ".toSlice()).split(",".toSlice()).beyond("\"gameId\": ".toSlice()).toString());

        // require(matchStructsById[matchId].created == false); //no overwriting existing matches

        // Match memory _match = Match({
        //     home: 0,
        //     away: 0,
        //     status: 0,
        //     startTime: startTime,
        //     created: true,
        //     wagerIds: new bytes20[](0)
        // });

        // matches.push(matchId);
        // matchStructsById[matchId] = _match;

        // //ADD WAGER ID OF USER WHO INITIATED THIS CALL
        // Match storage gotMatch = matchStructsById[matchId];
        // gotMatch.wagerIds.push(wagerId);

        // emit NewMatchCreated(
        //     matchId
        // );

        return true;
    }

    /// creates a match if a new match is received from oracle/opta api callback
    function createMatch(
        uint matchId,
        uint256 startTime
    )
        public
        onlyCLevelOrOracle
        whenNotPaused
        returns (bool)
    {
        //require(startTime > now);
        require(matchStructsById[matchId].created == false); //no overwriting existing matches

        Match memory _match = Match({
            home: 0,
            away: 0,
            status: 0,
            startTime: startTime,
            created: true,
            wagerIds: new bytes20[](0)
        });

        matches.push(matchId);
        matchStructsById[matchId] = _match;

        emit NewMatchCreated(
            matchId
        );

        return true;
    }

    //called when callback notifies contract that a particular match has been completed or cancelled
    function updateMatch(
        uint matchId,
        uint home,
        uint away,
        uint status,
        bytes20 wagerId
    )
        public
        onlyCLevelOrOracle
        whenNotPaused
        returns (bool)
    {

        Match storage gotMatch = matchStructsById[matchId];
        require(gotMatch.status < 3); //the match must have a current status of  0,1,2 = pregame or in progress.
        gotMatch.home = home;
        gotMatch.away = away;
        gotMatch.status = status;

        emit MatchUpdated(
            matchId,
            gotMatch.home,
            gotMatch.away,
            gotMatch.status
        );

        //we call settleWager with an empty string for 'sport' and '0' for 'matchId' because we do not need these params
        //they are only needed for the URL path when an oracle query is necessary for match updates
        settleWager(wagerId, '', 0);

        return true;
    }

    //can be called by any address to settle a wager for a game which has a status of 3 (cancelled) or 4 (completed)
    //the account which calls this function will pay the transaction fee
    function settleWager(bytes20 wagerId, string memory sport, uint matchId)
        public
        payable
        whenNotPaused
        returns (bool)
    {
        // Wager storage wager = wagers[wagerId];
        // Match storage gotMatch = matchStructsById[wager.matchId];
        // require(!wager.isSettled);
        // if(gotMatch.status < 3) {
        //   if (oraclize_getPrice("URL", 100000) > msg.value || oraclize_getPrice("URL", 2000000) < msg.value) {
        //       emit LogNewOraclizeQuery("Query fee was either too low or too high. ");
        //       revert();
        //   } else {
        //       getMatchResults(sport, matchId, wagerId);
        //   }
        //   return true;
        // }
        // require(gotMatch.status > 2); //the match must have a current status of  0,1,2 = pregame or in progress.

        // if (gotMatch.status == 3) {
        //     //refund
        //     //rToken.transfer(wager.creator, wager.creatorRisk);
        //     if (wager.taker != address(0)) {
        //         //rToken.transfer(wager.taker, wager.takerRisk);
        //     }
        // } else if (gotMatch.status == 4) {
        //     //match is final
        //     require(settleStraightWager(wagerId));

        // } else {
        //     //this point should never be reached, as it implies that the match has a status which the contract is not expecting.
        //     revert();
        // }

        // //clean up and finalize
        // wager.isSettled = true;
        // //wagers[wagerId] = wager;
        // //delete wagers[wagerId];

        // emit WagerSettled(
        //     wagerId,
        //     wager.matchId
        // );

        return true;
    }

    //settles a straight wager
    function settleStraightWager(bytes20 wagerId)
        private
        whenNotPaused
        returns (bool)
    {
      Wager storage wager = wagers[wagerId];

      if(wager.taker == address(0)) { //send tokens back if no one took the bet
        //rToken.transfer(wager.creator, wager.creatorRisk); //send tokens back to creator
      } else if (wager.takerSide == determineWagerResult(wagerId)) {
        //rToken.transfer(wager.taker, commission.mul(wager.creatorRisk).div(100).add(wager.takerRisk));
      } else if (wager.creatorSide == determineWagerResult(wagerId)) {
        //rToken.transfer(wager.creator, commission.mul(wager.takerRisk).div(100).add(wager.creatorRisk));
      } else {
        //rToken.transfer(wager.creator, wager.creatorRisk); //send tokens back to creator
        //rToken.transfer(wager.taker, wager.takerRisk); //send tokens back to taker
      }
      return true;
    }

    //called by settleWager().  will return result of any particular wager type based on match result
    function determineWagerResult(bytes20 wagerId)
        public
        returns (uint matchResult)
    {
        Wager storage wager = wagers[wagerId];
        Match storage gotMatch = matchStructsById[wager.matchId];

        if (wager.wagerType == 0) { //if 1v1 team A vs team B wager type
            if (gotMatch.home == gotMatch.away) {
                matchResult = 0; //if scores are equal and match is over, it is a draw 0
            } else {
                matchResult = gotMatch.home > gotMatch.away ? 1 : 2; //if home team wins, result = 1, else 2
            }
        } else if (wager.wagerType == 1) { //if "draw" wager type.   1 = draw, 2 = no draw
            if (gotMatch.home == gotMatch.away) {
                matchResult = 1; //if scores are equal and match is over, it is a draw and the users who chose "home" (1) win
            } else {
                matchResult = 2; //if no draw, users who chose "away" (2) win
            }
        } else if (wager.wagerType == 2) {//if "total" wager (over/under)
            if (gotMatch.home.add(gotMatch.away) == wager.spread) { //if total points is equal to spread, refund
                matchResult = 0; //if scores are equal and match is over, it is a draw 0
            } else {
                matchResult = gotMatch.home.add(gotMatch.away) > wager.spread ? 1 : 2; //if combined points is over spread, 1 (home) wins, else, 2 (away) under wins
            }
        } else if (wager.wagerType == 3) {//goal diff for home team (over/under)
            if (gotMatch.home - gotMatch.away == wager.spread) { //if goal diff is equal to spread, refund
                matchResult = 0; //if goal diff is equal to spread and match is over, it is a draw 0
            } else {
                matchResult = int(gotMatch.home - gotMatch.away) > int(wager.spread) ? 1 : 2; //if goal diff points is over spread, 1 (home) wins, else, 2 (away) under wins
            }
        } else if (wager.wagerType == 4) {//goal diff for away team (over/under)
            if (gotMatch.away - gotMatch.home == wager.spread) { //if goal diff is equal to spread, refund
                matchResult = 0; //if goal diff is equal to spread and match is over, it is a draw 0
            } else {
                matchResult = int(gotMatch.away - gotMatch.home) > int(wager.spread) ? 1 : 2; //if goal diff points is over spread, 1 (home) wins, else, 2 (away) under wins
            }
        } else {
            revert(); //shouldn't reach
        }
    }

    /// @dev A public method that creates a new wager and stores it
    function createFirstWagerOfMatch(
      bytes20 wagerId,
      string memory sport,
      uint matchId
    )
        internal
        whenNotPaused
        returns (bool)
    {
        // //prevent someone accidentally sending too much or too little to cover the oraclize fee
        // //queryId = oraclize_query(delay, "URL", "json(http://api.fixer.io/latest?symbols=USD,GBP).rates");
        // if (!queriesArePaused) {
        //     //url with json accessors to query
        //     //string public oracleDataSourceUrl = "json(http://13.57.222.160:5000/gameday).[*]";

        //     //oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS); //set proof to verify query result authenticity

        //     //our api
        //     bytes32 queryId = oraclize_query("URL", constructUrl(sport, matchId), oracleGasLimit);
        //     //bytes32 queryId = oraclize_query(delay, "URL", "json(http://54.183.244.59:5000/livecenter).matches", oraclizeGasLimit);

        //     //store each query ?
        //     queryIdToWagerId[queryId] = wagerId;//we reuse this mapping by putting in our contract address if the query exists

        //     //log .... XXX
        //     emit LogNewOraclizeQuery("Oraclize queries were sent, standing by for the answer..");
        //     //validIds[queryId] = true;
        // } else {
        //     emit LogNewOraclizeQuery("Oraclize query was NOT sent");
        // }

        return true;
    }

}