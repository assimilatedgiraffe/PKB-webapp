<template>
  <v-app :dark="darkTheme" v-scroll="onScroll">
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
      <v-btn icon large @click.stop="toggleTheme">
        <v-icon v-if="darkTheme">mdi-white-balance-sunny</v-icon>
        <v-icon v-if="!darkTheme">mdi-weather-night</v-icon>
      </v-btn>
      <!-- <v-tooltip bottom max-width="200px"> -->
      <v-btn icon large tag="a" href="https://github.com/assimilatedgiraffe/PKB-webapp" target="_blank">
        <v-icon>mdi-github-box</v-icon>
      </v-btn>
      <!-- <span>
        View Code on GitHub
      </span>
      </v-tooltip> -->
      <v-btn icon large @click.stop="logOut">
        <v-icon>exit_to_app</v-icon>
      </v-btn>
      <!-- <v-btn icon @click.stop="rightDrawer = !rightDrawer">
        <v-icon>menu</v-icon>
      </v-btn> -->
    </v-toolbar>

    <v-toolbar flat dense v-if="breadcrumbsFixed">
    </v-toolbar>
    <v-toolbar flat dense :fixed="breadcrumbsFixed">
      <v-breadcrumbs>
      <v-icon slot="divider">chevron_right</v-icon>
      <v-breadcrumbs-item
      v-for="item in breadcrumbs"
      :key="item.text"
      v-html="item.text"
      >
       <!-- {{ item.text }} -->
      </v-breadcrumbs-item>
    </v-breadcrumbs>
    </v-toolbar>

    <v-progress-linear color="primary" style="margin:0" indeterminate :active="isBusy"></v-progress-linear>
    <Login></Login>
    <v-snackbar
      v-model="snackbar"
      top
    >
    <v-alert outline type="error" value="true">
      {{error}}
    </v-alert>
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
    <!-- <v-footer app>
      <span>&copy; 2017</span>
    </v-footer> -->
  </v-app>
</template>

<script lang="coffee">
import firebase from 'firebase'
import { mapGetters } from 'vuex'
import Login from './components/Login.vue'

export default {
  name: 'App'
  data: -> {
    snackbar: false
    breadcrumbsFixed: false
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
    onScroll: (e) ->
      offsetTop = window.pageYOffset or document.documentElement.scrollTop
      this.breadcrumbsFixed = if offsetTop > 68 then true else false

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
      this.$vuetify.theme.primary =  if newVal then '#00695C' else '#26A69A'
      this.$vuetify.theme.secondary =  if newVal then '#263238' else '#ECEFF1'
}
</script>


<style lang="css">
*:focus {
  outline: none;
}
.alert {
  padding: 7px;
}
</style>
