import Vue from 'vue'
import Vuex from 'vuex'
import state from './state'
import getWeb3 from '../util/getWeb3'
import pollWeb3 from '../util/pollWeb3'
import pollPoint from '../util/pollPoint'
import pollTransactions from '../util/pollTransactions'
import getContract from '../util/getContract'

Vue.use(Vuex)
export const store = new Vuex.Store({
  strict: true,
  state,
  mutations: {
    registerWeb3Instance (state, payload) {
      console.log('registerWeb3instance Mutation being executed', payload)
      let result = payload
      let web3Copy = state.web3
      web3Copy.coinbase = result.coinbase
      web3Copy.networkId = result.networkId
      web3Copy.balance = parseInt(result.balance, 10)
      web3Copy.isInjected = result.injectedWeb3
      web3Copy.web3Instance = result.web3
      state.web3 = web3Copy
      pollWeb3()
      pollPoint()
      pollTransactions()
    },
    pollWeb3Instance (state, payload) {
      console.log('pollWeb3Instance mutation being executed', payload)
      state.web3.coinbase = payload.coinbase
      state.web3.balance = parseInt(payload.balance, 10)
    },
    updatePoint (state, payload) {
      console.log('updatePoint mutation being executed', payload)
      state.point.received = payload.received
      state.point.available = payload.available
    },
    updateTransactions (state, payload) {
      console.log('updateTransactions mutation being executed', payload)
      state.transactions.sent = payload.sent
      state.transactions.received = payload.received
    },
    registerContractInstance (state, payload) {
      console.log('PeerPoint contract instance: ', payload)
      state.contractInstance = () => payload
    },
    setRefetch ({commit}, payload) {
      console.log('Set refetch', payload)
      state.refetch = () => payload
    }
  },
  actions: {
    registerWeb3 ({commit}) {
      console.log('registerWeb3 Action being executed')
      getWeb3.then(result => {
        console.log('committing result to registerWeb3Instance mutation')
        commit('registerWeb3Instance', result)
      }).catch(e => {
        console.log('error in action registerWeb3', e)
      })
    },
    pollWeb3 ({commit}, payload) {
      console.log('pollWeb3 action being executed')
      commit('pollWeb3Instance', payload)
    },
    pollPoint ({commit}, payload) {
      console.log('updatePoint action being executed')
      commit('updatePoint', payload)
    },
    pollTransactions ({commit}, payload) {
      console.log('pollTransactions action being executed')
      commit('updateTransactions', payload)
    },
    getContractInstance ({commit}) {
      getContract.then(result => {
        commit('registerContractInstance', result)
      }).catch(e => console.log(e))
    },
    setRefetch ({commit}, payload) {
      console.log('Set refetch', payload)
      commit('setRefetch', payload)
    }
  }
})
