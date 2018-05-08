import Web3 from 'web3'
import { default as contract } from 'truffle-contract'
import artifacts from '../../build/contracts/PeerPoint.json'

let getContract = new Promise(function (resolve, reject) {
  let web3 = new Web3(window.web3.currentProvider)
  window.web3 = new Web3(web3.currentProvider)
  let PeerPoint = contract(artifacts)
  PeerPoint.setProvider(window.web3.currentProvider)
  let pointContractInstance = PeerPoint.deployed()
  resolve(pointContractInstance)
})

export default getContract
