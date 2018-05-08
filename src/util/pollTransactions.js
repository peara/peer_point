import Web3 from 'web3'
import {store} from '../store/'

let pollTransactions = function (state) {
  let web3 = window.web3
  web3 = new Web3(web3.currentProvider)

  setInterval(() => {
    if (web3 && store.state.web3.web3Instance && store.state.refetch) {
      let receivedPromise = new Promise(function (resolve, reject) {
        store.state.contractInstance().Transfer({
          to: store.state.web3.coinbase
        }, {
          fromBlock: 0
        }).get((err, res) => {
          let newReceived = []
          if (!err) {
            for (let [, event] of res.entries()) {
              newReceived.push({
                from: event.args.from,
                amount: event.args.tokens.valueOf(),
                message: web3.toAscii(event.args.message),
                block: event.blockNumber,
                txhash: event.transactionHash
              })
            }
            resolve(newReceived)
          } else {
            reject(new Error('Cant get received transactions'))
          }
        })
      })

      let sentPromise = new Promise(function (resolve, reject) {
        store.state.contractInstance().Transfer({
          from: store.state.web3.coinbase
        }, {
          fromBlock: 0
        }).get((err, res) => {
          if (!err) {
            let newSent = []
            for (let [, event] of res.entries()) {
              newSent.push({
                to: event.args.to,
                amount: event.args.tokens.valueOf(),
                message: web3.toAscii(event.args.message),
                block: event.blockNumber,
                txhash: event.transactionHash
              })
            }
            resolve(newSent)
          } else {
            reject(new Error('Cant get sent transactions'))
          }
        })
      })

      Promise.all([receivedPromise, sentPromise]).then(function ([newReceived, newSent]) {
        store.dispatch('pollTransactions', {
          sent: newSent,
          received: newReceived
        })
      })
    }
  }, 5000)
}

export default pollTransactions
