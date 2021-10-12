import Vue from 'vue'
import Vuex from 'vuex'
import { BigNumber } from 'bignumber.js'
import axios from 'axios'

import abiROYALBETTING from '@/abi/royalbetting.json'

BigNumber.config({ EXPONENTIAL_AT: 100 })

const ADDR_OWNER = ''
const ADDR_TOKEN_ROYALBETTING = '0xf5ca1aaC340c5FF505Fe8605304B29728Bd7B39c'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    account: null,
    messageContent: null,
    messageType: null,
    searchResult:false,
    contracts: {
        tokenRoyalBetting: null,
    },
    royalbetting: {
      startTime: Number,
      endTime: Number,
      priceInWinningPlace: BigNumber,
      priceInThirdPlace: BigNumber,
      rewardsBreakdown: [],
      ETHPerBracket: [],
      countWinnersPerBracket: [],
      firstTicketId: Number,
      firstTicketIdNextBetting: Number,
      amountCollectedInETH: BigNumber,
      finalNumber: Number,
      winningNumber: Number,
      amountOfPurchasedPeople: Number,
      amountOfNotClaimed: BigNumber,
      pendingRewards: BigNumber,
      claimablePeriod: Number,
      randomNumber:0
    },
    isOwner() {
        if(this.account==null)
            return false
        return this.account.address==ADDR_OWNER
    }
  },
  mutations: {
    init(state) {
        state.contracts.tokenRoyalBetting = new window.web3.eth.Contract(abiROYALBETTING, ADDR_TOKEN_ROYALBETTING);
      },
    set_account(state,account) {
        state.account = account
    },
    show_info(state,message) {
        state.messageContent = message
        state.messageType = 'info'
    },
    show_success(state,message) {
        state.messageContent = message
        state.messageType = 'success'
    },
    show_error(state,message) {
        state.messageContent = message
        state.messageType = 'error'
    },
    show_warning(state,message) {
        state.messageContent = message
        state.messageType = 'warning'
    },
    read_royalbetting(state) {
      state.contracts.tokenRoyalBetting.methods.viewcurrentBettingId().call().then((ret)=>{
          let currentBettingId = ret;
          state.contracts.tokenRoyalBetting.methods.viewBetting(currentBettingId).call().then((ret)=>{
            state.royalbetting.status = ret.status;
            state.royalbetting.startTime = ret.startTime;
            state.royalbetting.endTime = ret.endTime;
            state.royalbetting.priceInWinningPlace = BigNumber(ret.priceInWinningPlace);
            state.royalbetting.priceInThirdPlace = BigNumber(ret.priceInThirdPlace);
            state.royalbetting.rewardsBreakdown = ret.rewardsBreakdown;
            state.royalbetting.ETHPerBracket = ret.ETHPerBracket;
            state.royalbetting.countWinnersPerBracket = ret.countWinnersPerBracket;
            state.royalbetting.firstTicketId = ret.firstTicketId;
            state.royalbetting.firstTicketIdNextBetting = ret.firstTicketIdNextBetting;
            state.royalbetting.amountCollectedInETH = BigNumber(ret.amountCollectedInETH);
            state.royalbetting.finalNumber = ret.finalNumber;
            state.royalbetting.amountOfPurchasedPeople = ret.amountOfPurchasedPeople;
            state.royalbetting.amountOfNotClaimed = BigNumber(ret.amountOfNotClaimed);

            let numbers = [];
            for (let j = 10; j > 0; j--) {
                const number = BigNumber(ret.finalNumber).shiftedBy(-(j-1)*2).mod(100).integerValue();
                numbers.push(number.toString());
            }       
  
            state.royalbetting.winningNumber = numbers.join(', ');
            }).catch((error)=>{
            console.error("tokenRoyalBetting.viewBetting",error)
          });

          state.contracts.tokenRoyalBetting.methods.getBracketsOfMatching(currentBettingId, state.account.address)
          .call().then((ret)=>{
            state.royalbetting.pendingRewards = BigNumber(ret.pendingRewards);
          })

          state.contracts.tokenRoyalBetting.methods.limitClaimablePeriod()
          .call().then((ret)=>{
            state.royalbetting.claimablePeriod = parseInt(state.royalbetting.endTime) + parseInt(ret);
          })
        }).catch((error)=>{
        console.error("tokenRoyalBetting.viewcurrentBettingId",error)
      });
    }
  },
  method: {
    fetchData(url){
        axios.get(url).then(response => {
           console.log(response);
        })
    },
  },
  actions: {
    connect({commit}) {
      window.ethereum.request({ 
          method: 'eth_requestAccounts' 
      }).then((accounts) => {
          if(accounts.length==0) {
              console.log("No connected");
          } else {
            window.ethereum.request({
              method: 'wallet_switchEthereumChain',
              params: [{ chainId: '0xfa2' }],
            }).then(() => {
              console.log("wallet_switchEthereumChain")
              const account = {
                address: accounts[0],
                //balance: BigNumber(balance,"ether")
              }
              commit('show_success','Connected')
              commit('set_account',account)
              commit('read_royalbetting');
            }).catch(error => {
              console.log("error:wallet_switchEthereumChain",error)
              if (error.code==4902 || error.code==-32603) {
                window.ethereum.request({
                  method: 'wallet_addEthereumChain',
                  params: [{ 
                    chainId: '0xfa2', 
                    chainName: 'FantomNetwork',
                    rpcUrls: ['https://rpc.testnet.fantom.network'],
                    blockExplorerUrls: ['https://testnet.ftmscan.com'],
                    nativeCurrency: {
                      name: 'Fantom',
                      symbol: 'FTM',
                      decimals: 18
                    }
                  }],
                }).then(() => {
                  const account = {
                    address: accounts[0],
                  }
                  commit('set_account',account)
                  commit('read_royalbetting');
                }).catch(() => {
                  console.log("error:wallet_switchEthereumChain")
                });
              }
            });
          }
      }).catch((err) => {
        if (err.code === 4001) {
          console.log('Please connect to MetaMask.');
        } else {
          console.error(err);
        }
      });  
    },
    disconnect({state}) {
        state.account = null
    },
    startBetting({state,commit}, params) {
      if (state.account==null)
      {
        commit('show_warning', 'Please connect Wallet!');
        return;         
      }

      state.contracts.tokenRoyalBetting.methods.startBetting(params.price1, params.price2).send({
        from: state.account.address
      }).then(()=>{
        commit('show_success', 'Start Betting Success!');
        commit('read_royalbetting');
      })
    },
    buyTicket({state,commit}, params) {
      if (state.account==null)
      {
        commit('show_warning', 'Please connect Wallet!');
        return;         
      }

      state.contracts.tokenRoyalBetting.methods.viewcurrentBettingId().call().then((ret)=>{
        let currentBettingId = ret;
        let price;

        if (params.placeKind == 1)
          price = state.royalbetting.priceInWinningPlace;
        else
          price = state.royalbetting.priceInThirdPlace;

        state.contracts.tokenRoyalBetting.methods.buyTickets(
          currentBettingId, params.racingNumber, params.placeKind).send({
          from: state.account.address,
          value:BigNumber(price).integerValue().toString()
        }).then(()=>{
          commit('show_success', 'Buy ticket Success!');
          commit('read_royalbetting');
        })
      }).catch((error)=>{
        console.error("tokenRoyalBetting.viewcurrentBettingId",error)
      });
    },
    closeBetting({state,commit}) {
      if (state.account==null)
      {
        commit('show_warning', 'Please connect Wallet!');
        return;         
      }

      state.contracts.tokenRoyalBetting.methods.viewcurrentBettingId().call().then((ret)=>{
        let currentBettingId = ret;
        state.contracts.tokenRoyalBetting.methods.closeBetting(currentBettingId).send({
          from: state.account.address
        }).then(()=>{
          commit('show_success', 'Close betting Success!');
          commit('read_royalbetting');
        })
      }).catch((error)=>{
        console.error("tokenRoyalBetting.viewcurrentBettingId",error)
      });
    },
    drawRacingNumberAndMakeBettingClaimable({state,commit}) {
      if (state.account==null)
      {
        commit('show_warning', 'Please connect Wallet!');
        return;         
      }

      state.contracts.tokenRoyalBetting.methods.viewcurrentBettingId().call().then((ret)=>{
        let currentBettingId = ret;
        state.contracts.tokenRoyalBetting.methods.drawRacingNumberAndMakeBettingClaimable(currentBettingId).send({
          from: state.account.address
        }).then(()=>{
          commit('show_success', 'Close betting Success!');
          commit('read_royalbetting');
        })
      }).catch((error)=>{
        console.error("tokenRoyalBetting.viewcurrentBettingId",error)
      });
    },    
    claimTicket({state,commit}) {
      if (state.account==null)
      {
        commit('show_warning', 'Please connect Wallet!');
        return;         
      }

      state.contracts.tokenRoyalBetting.methods.viewcurrentBettingId().call().then((ret)=>{
        let currentBettingId = ret;
        state.contracts.tokenRoyalBetting.methods.getBracketsOfMatching(currentBettingId, state.account.address)
        .call().then((ret)=>{
          state.contracts.tokenRoyalBetting.methods.claimTickets(currentBettingId, ret.new_ticketIds, ret.new_brackets)
          .send({
            from: state.account.address
          }).then(()=>{
            commit('show_success', 'Claim ticket Success!');
            commit('read_royalbetting');
          })
        })
      }).catch((error)=>{
        console.error("tokenRoyalBetting.viewcurrentBettingId",error)
      });
    },
    generateRandomNumber({state,commit}) {
      state.contracts.tokenRoyalBetting.methods.viewcurrentBettingId().call().then(()=>{
          state.contracts.tokenRoyalBetting.methods.generateRacingNumber()
          .send({
            from: state.account.address
          }).then(()=>{
            state.contracts.tokenRoyalBetting.methods.randomGeneratedNumber().call().then((ret)=>{

              let randomNumber = BigNumber(ret);
              let numbers = [];
              
              for (let j = 10; j > 0; j--) {
                  const number = randomNumber.shiftedBy(-(j-1)*2).mod(100).integerValue();
                  numbers.push(number.toString());
              }       

              state.royalbetting.randomNumber = numbers.join(', ');

              commit('show_success', 'Generating random number Success!');
          })
        })
      }).catch((error)=>{
        console.error("tokenRoyalBetting.viewcurrentBettingId",error)
      });
    }
  }
})
