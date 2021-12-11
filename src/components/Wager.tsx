import React, { useEffect } from "react";
import PropTypes from "prop-types";
import "./Wager.css";
// import { initializeWeb3, getWeb3, getBlockNumber} from './services/web3';

function Wager({id, name, homeSide, awaySide, riskAmount, payout}) {

  useEffect(() => {
  }, []);

  return (
    <div className="wager">
      <p className="title">{name}</p>
      <p className="home-side">{homeSide}</p>
      <p className="away-side">{awaySide}</p>
      <p className="risk-amount">{riskAmount}</p>
      <p className="to-win-amount">{payout}</p>
    </div>
  );
}

Wager.propTypes = {
  id: PropTypes.number,
  name: PropTypes.string,
  homeSide: PropTypes.string,
  awaySide: PropTypes.string,
  riskAmount: PropTypes.string,
  payout: PropTypes.string
};

export default Wager;
