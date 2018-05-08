import Vue from 'vue'
import Router from 'vue-router'
import Home from '@/components/Home'
import Transactions from '@/components/Transactions'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home
    },
    {
      path: '/transactions',
      name: 'transactions',
      component: Transactions
    }
  ]
})
