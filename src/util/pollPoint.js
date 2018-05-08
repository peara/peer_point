import Web3 from 'web3'
import {store} from '../store/'

let pollPoint = function (state) {
  let web3 = window.web3
  web3 = new Web3(web3.currentProvider)

  setInterval(() => {
    if (web3 && store.state.web3.web3Instance && store.state.refetch) {
      let pointPromise = new Promise(function (resolve, reject) {
        store.state.contractInstance().pointOf.call(store.state.web3.coinbase, {
          from: store.state.web3.coinbase
        }).then((result) => {
          resolve(result)
        }).catch((err) => {
          reject(err)
        })
      })

      let balancePromise = new Promise(function (resolve, reject) {
        store.state.contractInstance().balanceOf.call(store.state.web3.coinbase, {
          from: store.state.web3.coinbase
        }).then((result) => {
          resolve(result)
        }).catch((err) => {
          reject(err)
        })
      })

      Promise.all([balancePromise, pointPromise]).then(function ([balance, point]) {
        store.dispatch('pollPoint', {
          available: point.valueOf(),
          received: balance.valueOf()
        })
      })
    }
  }, 5000)
}

export default pollPoint
