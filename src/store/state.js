let state = {
  web3: {
    isInjected: false,
    web3Instance: null,
    networkId: null,
    coinbase: null,
    balance: null,
    error: null
  },
  point: {
    received: null,
    available: null
  },
  transactions: {
    sent: [],
    received: []
  },
  refetch: true,
  contractInstance: null
}
export default state
