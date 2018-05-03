// Import the page's CSS. Webpack will know what to do with it.
import '../stylesheets/app.css'

// Import libraries we need.
import { default as Web3 } from 'web3'
import { default as contract } from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
import peerpointArtifacts from '../../build/contracts/PeerPoint.json'

// PeerPoint is our usable abstraction, which we'll use through the code below.
var PeerPoint = contract(peerpointArtifacts)

// The following code is simple to show off interacting with your contracts.
// As your needs grow you will likely need to change its form and structure.
// For application bootstrapping, check out window.addEventListener below.

window.addEventListener('load', function () {
  function setAccountInfo () {
    let baseAddress = web3.eth.coinbase

    $('#address-label').text(baseAddress)
    web3.eth.getBalance(baseAddress, (err, res) => {
      if (!err) {
        $('#balance-label').text(web3.fromWei(res, 'ether') + ' ether')
      } else {
        console.log(err)
      }
    })
    PeerPoint.deployed().then(function (instance) {
      instance.balanceOf(baseAddress, (err, res) => {
        if (!err) {
          $('#rec-point-label').text(res.toString())
        } else {
          console.log(err)
        }
      })

      instance.pointOf(baseAddress, (err, res) => {
        if (!err) {
          $('#send-point-label').text(res.toString())
        } else {
          console.log(err)
        }
      })
    })
  }

  function handleRedeem () {
    $('#redeem-btn').prop('disabled', true)
    PeerPoint.redeem({
      value: 0,
      gas: 200000,
      gasPrice: web3.toWei(0.1, 'Gwei')
    }, (err, res) => {
      if (!err) {
        console.log(res)
      } else {
        console.log(err)
      }
    })
    $('#redeem-btn').prop('disabled', false)
  }

  function handleSend () {
    $('#send-btn').prop('disabled', true)
    PeerPoint.transfer(
      $('#address-input').val(), $('#amount-input').val(), {
        value: 0,
        gas: 200000,
        gasPrice: web3.toWei(0.1, 'Gwei')
      },
      (err, res) => {
        if (!err) {
          console.log(res)
        } else {
          console.log(err)
        }
      })
    $('#send-btn').prop('disabled', false)
  }

  function updateInfo () {
    setAccountInfo()
    web3.eth.getBlockNumber((err, blockNumber) => {
      if (!err) {
        PeerPoint.Transfer({
          to: baseAddress
        }, {
          fromBlock: 0
        }).get((err, res) => {
          html = ''
          for (let [index, event] of res.entries()) {
            html += '<tr>'
            html += '<th>' + (index + 1) + '</th>'
            html += '<td>' + event.args.from + '</td>'
            html += '<td>' + event.args.tokens.toString() + '</td>'
            html += '<td>' + (blockNumber - event.blockNumber) + '</td>'
            html += '</tr>'
          }
          $('#receive-body').html(html)
        })

        PeerPoint.Transfer({
          from: baseAddress
        }, {
          fromBlock: 0
        }).get((err, res) => {
          html = ''
          for (let [index, event] of res.entries()) {
            html += '<tr>'
            html += '<th>' + (index + 1) + '</th>'
            html += '<td>' + event.args.to + '</td>'
            html += '<td>' + event.args.tokens.toString() + '</td>'
            html += '<td>' + (blockNumber - event.blockNumber) + '</td>'
            html += '</tr>'
          }
          $('#send-body').html(html)
        })
      } else {
        console.log(err)
      }
    })
  }

  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 PeerPoint, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider)
  } else {
    if (window.location.pathname == '/sign-in') {
      window.location = '/'
    }
  }

  web3.version.getNetwork((err, networkId) => {
    let networkName = ''
    switch (networkId) {
      case '1':
        networkName = 'Main'
        break
      case '2':
        networkName = 'Morden'
        break
      case '3':
        networkName = 'Ropsten'
        break
      case '4':
        networkName = 'Rinkeby'
        break
      case '42':
        networkName = 'Kovan'
        break
      default:
        networkName = 'Unknown'
    }

    $('#network-label').text(networkName)
  })

  if (typeof web3 !== 'undefined' && web3.eth.coinbase !== null) {
    if (window.location.pathname == '/signin.html') {
      window.location = '/'
    }
    window.web3 = new Web3(web3.currentProvider)
    updateInfo()
    $('#redeem-btn').click(handleRedeem)
    $('#send-btn').click(handleSend)
    setInterval(updateInfo, 5000)
  } else {
    console.log('No web3? You should consider trying MetaMask!')
    if (window.location.pathname !== '/signin.html') {
      window.location = '/signin.html'
    }
  }
})
