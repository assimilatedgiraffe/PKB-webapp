<template>
  <v-app :dark="darkTheme">
    <v-toolbar
      app
      color="primary"
    >
      <v-icon large>mdi-note-text</v-icon>
      <v-toolbar-title v-text="title"></v-toolbar-title>

      <v-spacer></v-spacer>

      <v-progress-circular indeterminate v-if="isLoading"></v-progress-circular>
      <v-tooltip bottom max-width="200px">
        <v-alert v-model="isDisconnected" slot="activator" outline type="warning" icon="priority_high" value="true">
        Offline
        </v-alert>
        <span>Looks like you're not connected to the internet. Changes you make while offline will be synced when you reconnect.</span>
      </v-tooltip>

      <v-tooltip bottom dark max-width="200px" color="blue-grey darken-4" >
      <v-btn icon large slot="activator" @click.stop="toggleTheme">
        <v-icon v-if="darkTheme">mdi-white-balance-sunny</v-icon>
        <v-icon v-if="!darkTheme">mdi-weather-night</v-icon>
      </v-btn>
      <span> {{ darkTheme ? 'Day Theme' : 'Night Theme' }} </span> </v-tooltip>

      <v-tooltip bottom max-width="200px" color="blue-grey darken-4" >
      <v-btn icon large tag="a" slot="activator" href="https://github.com/assimilatedgiraffe/PKB-webapp" target="_blank">
        <v-icon>mdi-github-box</v-icon>
      </v-btn>
      <span> View Code on GitHub </span> </v-tooltip>

      <v-tooltip bottom max-width="200px" color="blue-grey darken-4" >
      <v-btn icon large slot="activator" @click.stop="logOut">
        <v-icon>exit_to_app</v-icon>
      </v-btn>
      <span> Log Out </span> </v-tooltip>
      <!-- <v-btn icon @click.stop="rightDrawer = !rightDrawer">
        <v-icon>menu</v-icon>
      </v-btn> -->
    </v-toolbar>

      <v-alert v-if="$vuetify.breakpoint.xsOnly" outline type="warning" icon="priority_high" value="true">
         NOTE: ** this early version is optimised for desktop, viewing in landscape is recommended for mobile **
      </v-alert>

    <v-toolbar flat dense class="breadcrumbs-bar">
      <v-breadcrumbs>
      <v-icon slot="divider">chevron_right</v-icon>
      <v-breadcrumbs-item
      v-for="item in breadcrumbs"
      :key="item.id"
      v-html="item.text"
      >
       <!-- {{ item.text }} -->
      </v-breadcrumbs-item>
    </v-breadcrumbs>
    </v-toolbar>

    <v-progress-linear color="primary" style="margin:0" indeterminate :active="isBusy || isLoading"></v-progress-linear>

    <Login></Login>

    <v-snackbar color="error" v-model="snackbar" top >
      <v-icon>error</v-icon>{{error}}
    </v-snackbar>

    <v-content>
      <router-view/>
    </v-content>

    <!-- <v-navigation-drawer
      temporary
      right
      v-model="rightDrawer"
      fixed
      app
    >
      <v-list>
        <v-list-tile @click="rightDrawer = false" >
          <v-list-tile-action>
            <v-icon>compare_arrows</v-icon>
          </v-list-tile-action>
          <v-list-tile-title>Close</v-list-tile-title>
        </v-list-tile>
      </v-list>
    </v-navigation-drawer> -->
    <v-footer app fixed style="min-height:28px">
      <v-flex d-inline-flex align-center justify-end >
      <!-- <span>&copy; 2017 </span> -->
      <a href="https://assimilatedgiraffe.github.io/" target="_blank" style="flex: none">
        <v-avatar size="20px">
        <img src="https://github.com/assimilatedgiraffe.png?size=20" class="" alt="face" >
        </v-avatar>
      </a>
      </v-flex>
    </v-footer>
  </v-app>
</template>

<script lang="coffee">
import firebase from 'firebase'
import fbconfig from './store/fbconfig.js'
# Required for side-effects
require("firebase/firestore")

import { mapGetters } from 'vuex'
import Login from './components/Login.vue'

export default {
  name: 'App'
  data: -> {
    snackbar: false
    rightDrawer: false
    title: 'Personal Knowledge Base Web App'
  }
  components: {Login}

  computed: {
    ...mapGetters ['isLoading', 'isBusy', 'error', 'darkTheme']
    isDisconnected: -> not this.$store.getters.isConnected
    breadcrumbs: ->
      breadcrumbs = []
      selected = this.$store.getters.selectedNote
      while selected?.parent?
        # hey, at least I didn't use regex
        hack = selected.text.split('<', 3)
        awfulHack = '<' + hack[1] + '<' + hack[2]
        breadcrumbs.unshift({text:awfulHack})
        selected = this.$store.getters.note(selected.parent)
        # break if selected.parent == "rootNode"
      return breadcrumbs
  }

  methods:
    logOut: ->
      console.log "logOut"
      firebase.auth().signOut()
    toggleTheme: -> this.$store.commit('toggleTheme')

  watch:
    error: (newError) ->
      if newError != ""
        console.log "error", newError, this
        this.snackbar = true
        setTimeout(() =>
          console.log "test"
          this.$store.commit('setError', "")
        , 6500)
    darkTheme: (newVal) ->
      this.$vuetify.theme.primary =  if newVal then '#00695C' else '#4db6ac'
      this.$vuetify.theme.secondary =  if newVal then '#263238' else '#eceff1'
      this.$vuetify.theme.error =  if newVal then '#b71c1c' else '#ef5350'

  created: ->
    if (process.env.NODE_ENV != 'production')
      firebase.initializeApp(fbconfig.dev)
    else
      firebase.initializeApp(fbconfig.prod)

    firebase.auth().onAuthStateChanged((user) =>
      if user
        this.$store.dispatch('signIn', user)
      else
        this.$store.dispatch('signOut')
    )
}
</script>


<style scoped lang="css">
*:focus {
  outline: none;
}
.alert {
  padding: 7px;
}
.breadcrumbs-bar {
  position: sticky;
  top: 0;
  z-index: 7;
}
</style>
