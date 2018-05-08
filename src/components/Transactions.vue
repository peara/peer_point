<template>
  <v-flex>
    <v-tabs icons-and-text centered fixed-tabs dark color="indigo">
      <v-tabs-slider color="yellow"></v-tabs-slider>
      <v-tab href="#tab-sent">
        Sent
        <v-icon>keyboard_arrow_right</v-icon>
      </v-tab>
      <v-tab href="#tab-received">
        Received
        <v-icon>keyboard_arrow_left</v-icon>
      </v-tab>
      <v-tab-item id="tab-sent">
        <v-data-table
          :headers="sentHeaders"
          :items="sentTransactions"
          hide-actions
          class="elevation-1"
        >
          <template slot="items" slot-scope="props">
            <td>{{ props.item.to }}</td>
            <td>{{ props.item.amount }}</td>
            <td>{{ props.item.message }}</td>
            <td>{{ props.item.block }}</td>
            <td>
              <a target="_blank" :href="createEtherscanUrl(props.item.txhash)"><v-icon>link</v-icon></a>
            </td>
          </template>
        </v-data-table>
      </v-tab-item>
      <v-tab-item id="tab-received">
        <v-data-table
            :headers="receivedHeaders"
            :items="receivedTransactions"
            hide-actions
            class="elevation-1"
          >
            <template slot="items" slot-scope="props">
              <td>{{ props.item.from }}</td>
              <td>{{ props.item.amount }}</td>
              <td>{{ props.item.message }}</td>
              <td>{{ props.item.block }}</td>
              <td>
                <a target="_blank" :href="createEtherscanUrl(props.item.txhash)"><v-icon>link</v-icon></a>
              </td>
            </template>
          </v-data-table>
      </v-tab-item>
    </v-tabs>
  </v-flex>
</template>

<script>
  import {mapState} from 'vuex'
  import {ETHERSCAN_URLS} from '../util/constants/networks'

  export default {
    data: () => ({
      sentHeaders: [
        {
          text: 'To',
          align: 'left',
          sortable: false,
          value: 'to'
        },
        { text: 'Amount', value: 'amount' },
        { text: 'Message', value: 'message' },
        { text: 'Block Number', value: 'block' },
        { text: 'Link', value: 'txhash' }
      ],
      receivedHeaders: [
        {
          text: 'From',
          align: 'left',
          sortable: false,
          value: 'from'
        },
        { text: 'Amount', value: 'amount' },
        { text: 'Message', value: 'message' },
        { text: 'Block Number', value: 'block' },
        { text: 'Link', value: 'txhash' }
      ]
    }),
    computed: mapState({
      isInjected: state => state.web3.isInjected,
      available: state => state.point.available,
      received: state => state.point.received,
      coinbase: state => state.web3.coinbase,
      sentTransactions: state => state.transactions.sent,
      receivedTransactions: state => state.transactions.received
    }),
    methods: {
      createEtherscanUrl: function (txhash) {
        return `${ETHERSCAN_URLS[this.$store.state.web3.networkId]}${txhash}`
      }
    },
    mounted () {
      this.$store.dispatch('getContractInstance')
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h2 {
  font-weight: normal;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
