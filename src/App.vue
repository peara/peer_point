<template>
  <v-app id="inspire">
    <v-navigation-drawer
      v-model="drawer"
      fixed
      app
    >
      <v-list>
        <v-list-tile>
          <v-list-tile-action>
            <v-icon>assessment</v-icon>
          </v-list-tile-action>
          <v-list-tile-content>
            <v-list-tile-title>{{ network }}</v-list-tile-title>
          </v-list-tile-content>
        </v-list-tile>
        <v-list-tile>
          <v-list-tile-action>
            <v-icon>person_outline</v-icon>
          </v-list-tile-action>
          <v-list-tile-content>
            <v-list-tile-title>{{ coinbase }}</v-list-tile-title>
          </v-list-tile-content>
        </v-list-tile>
        <v-list-tile>
          <v-list-tile-action>
            <v-icon>account_balance_wallet</v-icon>
          </v-list-tile-action>
          <v-list-tile-content>
            <v-list-tile-title>{{ ethBalance }} ETH</v-list-tile-title>
          </v-list-tile-content>
        </v-list-tile>
      </v-list>
    </v-navigation-drawer>
    <v-toolbar color="indigo" dark fixed app>
      <v-toolbar-side-icon @click.stop="drawer = !drawer"></v-toolbar-side-icon>
        <v-toolbar-title>
          <router-link
            to="/"
            tag="span"
            style="cursor: pointer"
            >
            Peer Point
          </router-link>
        </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn flat @click="handleRedeem"><v-icon left>add_circle_outline</v-icon>Redeem</v-btn>
        <v-btn flat to="/transactions"><v-icon left>list</v-icon>Transactions</v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-content>
      <v-container fluid fill-height>
        <v-layout
          justify-center
        >
          <router-view ></router-view>
        </v-layout>
      </v-container>
    </v-content>
    <v-footer color="grey lighten-2" app>
      <span class="black--text">&nbsp;Framgia Inc &copy; 2018 | Developed with <a target="_blank" href="http://truffleframework.com/">Truffle</a> + <a target="_blank" href="https://vuejs.org/">Vue.js</a> + <span style="color:red">♥</span> by <a target="_blank" href="https://github.com/vigov5">vigov5</a> and <a target="_blank" href="https://github.com/peara">peara</a></span>
    </v-footer>
  </v-app>
</template>

<script>
  import {NETWORKS} from './util/constants/networks'
  import {mapState} from 'vuex'

  export default {
    name: 'app',
    data: () => ({
      drawer: null
    }),
    methods: {
      handleRedeem: function () {
        let self = this
        self.$store.state.contractInstance().redeem({
          value: 0,
          gas: 300000,
          gasPrice: window.web3.toWei(0.1, 'Gwei'),
          from: self.coinbase
        }).then(function () {
          alert('Redeem successfully !')
        }).catch(function (e) {
          console.log(e)
        })
      }
    },
    computed: mapState({
      isInjected: state => state.web3.isInjected,
      network: state => NETWORKS[state.web3.networkId],
      coinbase: state => state.web3.coinbase,
      balance: state => state.web3.balance,
      ethBalance: state => {
        if (state.web3.web3Instance !== null) return state.web3.web3Instance().fromWei(state.web3.balance, 'ether')
      }
    }),
    beforeCreate () {
      console.log('registerWeb3 Action dispatched Home.vue')
      this.$store.dispatch('registerWeb3')
    }
  }
</script>
