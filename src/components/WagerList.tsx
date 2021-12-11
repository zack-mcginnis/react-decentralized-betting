import React, { useEffect } from "react";
import PropTypes from "prop-types";
import "./WagerList.css";
import Wager from "./Wager";
// import { initializeWeb3, getWeb3, getBlockNumber} from './services/web3';

function WagerList({wagers}) {

  useEffect(() => {
  }, []);   


  return (
    <div className={"center-screen"}>
      {wagers.map((wager: any) => <Wager
        key={wager.id}
        name={wager.name} 
        homeSide={wager.homeSide} 
        awaySide={wager.awaySide} 
        riskAmount={wager.riskAmount} 
        payout={wager.payout} 
      />)}
    </div>
  );
}

WagerList.propTypes = {
  wagers: PropTypes.array
};

export default WagerList;
