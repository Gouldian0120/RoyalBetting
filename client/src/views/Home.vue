<template>
  <v-container class="py-12">
    <notification v-if="hasMessage"/>
    <v-row>
      <v-col lg="4" cols="12">
        <v-card color="transparent">
          <v-card-text>
            <v-btn @click="connectWallet" v-if="isMetaMaskInstalled && !isMetaMaskConnected"  block large text-color="white" color="transparent" class="my-3">Connect Metamask</v-btn>
            <v-btn @click="lockMetamask" v-if="isMetaMaskInstalled && isMetaMaskConnected"  block large color="transparent" class="my-3">Connected Metamask</v-btn>
            <v-btn @click="startBettingView" block large color="transparent" class="my-3">Start Betting</v-btn>
            <v-btn @click="buyTicketView" block large color="transparent" class="my-3">Buy ticket</v-btn>
            <v-btn @click="closeBetting" block large color="transparent" class="my-3">Close Betting</v-btn>
            <v-btn @click="drawRacingNumberAndMakeBettingClaimable" block large color="transparent" class="my-3">Calculate the result of Bettng</v-btn>
            <v-btn @click="claimTicket" block large color="transparent" class="my-3">Claim the rewards for the place</v-btn>
            <v-btn @click="startBettingView" block large color="transparent" class="my-3">Start the next Betting</v-btn>
          </v-card-text>
        </v-card>
        <v-card color="transparent">
           <v-btn @click="generateRandomNumber" block large color="transparent" class="my-10">Generat random number</v-btn>
        </v-card>
      </v-col>
      <v-col lg="8" cols="12">
        <v-img v-if="isMetaMaskInstalled && !isMetaMaskConnected" :src="require('@/assets/favicon.png')" height="500px" contain width="600px"></v-img>
        <v-card v-if="isMetaMaskInstalled && isMetaMaskConnected && isStartBettingView" color="transparent" class="mb-3 pl-5 pr-5 pb-5">
          <div class="holder">
            <div class="text-h6">Enter the Price for winning place.</div>
            <v-text-field v-model="price1" class="walletForm" type="text" placeholder="Price for winning place (1 eth = 10 ^ 18)"></v-text-field>
            <div class="text-h6">Enter the Price for 1st-3rd place.</div>
            <v-text-field v-model="price2" class="walletForm" type="text" placeholder="Price for 1-3rd place (1 eth = 10 ^ 18)"></v-text-field>
            <div class="text-center">
              <v-btn @click="startBetitng" color="black" outlined elevation="4">Start Betting</v-btn>
            </div>
          </div>
        </v-card>
        <v-card v-if="isMetaMaskInstalled && isMetaMaskConnected && isBuyTicketView" color="transparent" class="mb-3 pl-5 pr-5 pb-5">
          <div class="holder">
            <div class="text-h6">Enter the Racing number (1 ~ 10).</div>
            <v-text-field v-model="racingNumber" class="walletForm" type="text" placeholder="Racing Number"></v-text-field>
            <div class="text-h6">Enter the Place kind (1: wining place, 2: 1st-3rd place).</div>
            <v-text-field v-model="placeKind" class="walletForm" type="text" placeholder="Place Kind (1: Winning place, 2: 1-3rd Place)"></v-text-field>
            <div class="text-center">
              <v-btn @click="buyTicket" color="black" outlined elevation="4">Buy</v-btn>
            </div>
          </div>
        </v-card>
        <v-card color="transparent" class="mb-3 pl-5 pr-5 pb-5 pt-5" v-if="isMetaMaskInstalled && isMetaMaskConnected">
          <div class="text-h6">Current Betting Status</div>
          <ol class="list-box"> 
              <li class="my-1">status: <span class="hilight">{{this.$store.state.royalbetting.status}} (0: Pending, 1: Open, 2: Close, 3: Claimable)</span></li>
              <li class="my-1">startTime: <span class="hilight">{{resultBeginDate}}</span></li>
              <li class="my-1">endTime: <span class="hilight">{{resultEndDate}}</span></li>
              <li class="my-1">price In WinningPlace: <span class="hilight">{{this.$store.state.royalbetting.priceInWinningPlace.shiftedBy(-18)}} ETH</span></li>
              <li class="my-1">price In ThirdPlace: <span class="hilight">{{this.$store.state.royalbetting.priceInThirdPlace.shiftedBy(-18)}} ETH</span></li>
              <li class="my-1">rewards Breakdown: <span class="hilight">{{this.$store.state.royalbetting.rewardsBreakdown}}</span></li>
              <li class="my-1">ETH Per Bracket: <span class="hilight">{{this.$store.state.royalbetting.ETHPerBracket}}</span></li>
              <li class="my-1">count of Winners Per Bracket: <span class="hilight">{{this.$store.state.royalbetting.countWinnersPerBracket}}</span></li>
              <li class="my-1">firstTicketId: <span class="hilight">{{this.$store.state.royalbetting.firstTicketId}}</span></li>
              <li class="my-1">firstTicketIdNextBetting: <span class="hilight">{{this.$store.state.royalbetting.firstTicketIdNextBetting}}</span></li>
              <li class="my-1">amount Collected In ETH: <span class="hilight">{{this.$store.state.royalbetting.amountCollectedInETH}}</span></li>
              <li class="my-1">winning Number: <span class="hilight">{{this.$store.state.royalbetting.winningNumber}}</span></li>
              <li class="my-1">amount Of PurchasedPeople: <span class="hilight">{{this.$store.state.royalbetting.amountOfPurchasedPeople}}</span></li>
              <li class="my-1">amount Of NotClaimed: <span class="hilight">{{this.$store.state.royalbetting.amountOfNotClaimed}}</span></li>
          </ol>          
          <div class="text-h6 my-5">Current your pedding rewards (End date : {{climableEndDate}})</div>
          <div class="text-h7 pl-2"><span class="hilight">{{this.$store.state.royalbetting.pendingRewards}} ETH</span></div>
          <div class="text-h6 my-5">Random Number</div>
          <div class="text-h7 pl-2"><span class="hilight">{{this.$store.state.royalbetting.randomNumber}}</span></div>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import Notification from '@/components/notification.vue';

export default {
  name: "Attributes",
  components: {Notification},
  data() {
    return {
      currentTab: "mint",
      price1:null,
      price2:null,
      currentProce: null,
      bettingID:null,
      racingNumber:null,
      placeKind:null
    };
  },
  computed: {
      isMetaMaskInstalled() {
          const { ethereum } = window;
          return Boolean(ethereum && ethereum.isMetaMask)
      },
      isMetaMaskConnected() {
          return this.$store.state.account!=null;
      },
      isBuyTicketView(){
          return Boolean(this.currentProce == "buyTicket")
      },
      isStartBettingView(){
          return Boolean(this.currentProce == "startBetting")
      },
      hasMessage() {
          return this.$store.state.messageContent!=null
      },
      resultBeginDate() {
        console.log(this.$store.state.royalbetting.startTime)
          if(this.$store.state.royalbetting.startTime == null)
            return;
          let date = this.$store.state.royalbetting.startTime * 1000;
          const options = { year: 'numeric', month: 'numeric', day: 'numeric', hour: 'numeric', minute: 'numeric' }
          const dtf = new Intl.DateTimeFormat('en-US', options);
          return dtf.format(date)
      },
      resultEndDate() {
        console.log(this.$store.state.royalbetting.endTime)
          if(this.$store.state.royalbetting.endTime == null)
            return;
          let date = this.$store.state.royalbetting.endTime * 1000;
          const options = { year: 'numeric', month: 'numeric', day: 'numeric', hour: 'numeric', minute: 'numeric' }
          const dtf = new Intl.DateTimeFormat('en-US', options);
          return dtf.format(date)
      },
      climableEndDate() {
          if(this.$store.state.royalbetting.claimablePeriod == null)
              return;
          let date = this.$store.state.royalbetting.claimablePeriod * 1000;
          const options = { year: 'numeric', month: 'numeric', day: 'numeric', hour: 'numeric', minute: 'numeric' }
          const dtf = new Intl.DateTimeFormat('en-US', options);
          return dtf.format(date)
      },
  },
  mounted() {
  },
  methods: {
      connectWallet() {                
          this.$store.dispatch("connect")              
      },
      lockMetamask() {
          this.$store.dispatch("disconnect")
      },
      buyTicketView() {
          this.currentProce = "buyTicket"
      },
      startBettingView() {
          this.currentProce = "startBetting"
      },
      startBetitng() {
          this.$store.dispatch("startBetting", {
          price1:this.price1,
          price2:this.price2
        })
      },
      buyTicket() {
          this.$store.dispatch("buyTicket", {
          racingNumber:this.racingNumber,
          placeKind:this.placeKind
        })
      },
      closeBetting() {
        this.currentProce = "closeBetting"
        this.$store.dispatch("closeBetting")
      },
      drawRacingNumberAndMakeBettingClaimable() {
        this.currentProce = "drawRacingNumber"
        this.$store.dispatch("drawRacingNumberAndMakeBettingClaimable")
      },
      claimTicket() {        
        this.currentProce = "claimTicket"
        this.$store.dispatch("claimTicket")
      },
      generateRandomNumber() {
        this.$store.dispatch("generateRandomNumber")
      }
  }
};
</script>

<style>
  .action {
      background: white;
      border: black;
      border-radius: 2px;
      cursor: pointer;
      width:30%;
      margin-bottom: 1px;
  }
  .hilight {
      color:rgb(255, 255, 0)
  }
</style>
