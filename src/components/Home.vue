<template>
  <v-flex text-xs-center>
    <p v-if="isInjected" id="has-metamask"><v-icon color="green">check_circle</v-icon> Metamask installed. Your address is {{ coinbase }}</p>
    <p v-else id="no-metamask"><v-icon color="orange">warning</v-icon> Metamask not found. Please download at <a href="https://metamask.io/">https://metamask.io/</a></p>
    <h1>Point received: {{ received }}</h1>
    <h2>Available point to send: {{ available }}</h2>
    <v-layout justify-center>
      <v-flex xs12 sm10 md8>
        <v-form ref="form" v-model="valid" lazy-validation>
          <v-text-field
            v-model="toAddress"
            :rules="toAddressRules"
            label="Address"
            required
          ></v-text-field>
          <v-text-field
            v-model="amount"
            :rules="amountRules"
            label="Amount"
            required
          ></v-text-field>

          <v-text-field
            v-model="message"
            label="Message"
          ></v-text-field>

          <v-btn
            :disabled="!valid"
            @click="submit"
          >
            submit
          </v-btn>
          <v-btn @click="clear">clear</v-btn>
        </v-form>
      </v-flex>
    </v-layout>
  </v-flex>
</template>

<script>
  import {mapState} from 'vuex'

  export default {
    data: () => ({
      valid: false,
      toAddress: '',
      amount: '',
      message: 'From Framgia Inc with <3',
      toAddressRules: [
        v => !!v || 'Address is required'
      ],
      amountRules: [
        v => !!v || 'Amount is required'
      ]
    }),
    methods: {
      submit () {
        let self = this
        this.$store.state.contractInstance().sendPoint(
          self.toAddress, self.amount, self.message, {
            value: 0,
            gas: 300000,
            gasPrice: window.web3.toWei(0.1, 'Gwei'),
            from: self.coinbase
          }
        ).then(function (err, res) {
          if (err) {
            console.log(err)
          } else {
            alert('Transaction completed !')
            this.$refs.form.reset()
          }
        })
      },
      clear () {
        this.$refs.form.reset()
      }
    },
    computed: mapState({
      isInjected: state => state.web3.isInjected,
      available: state => state.point.available,
      received: state => state.point.received,
      coinbase: state => state.web3.coinbase
    }),
    mounted () {
      console.log('dispatching getContractInstance')
      this.$store.dispatch('getContractInstance')
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h2, h3 {
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
