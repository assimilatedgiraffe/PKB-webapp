<template>
  <v-app :dark="darkTheme">
    <v-navigation-drawer
      persistent
      :mini-variant="miniVariant"
      :clipped="clipped"
      v-model="drawer"
      enable-resize-watcher
      fixed
      app
    >
      <v-list>
        <v-list-tile
          value="true"
          v-for="(item, i) in items"
          :key="i"
        >
          <v-list-tile-action>
            <v-icon v-html="item.icon"></v-icon>
          </v-list-tile-action>
          <v-list-tile-content>
            <v-list-tile-title v-text="item.title"></v-list-tile-title>
          </v-list-tile-content>
        </v-list-tile>
      </v-list>
    </v-navigation-drawer>
    <v-toolbar
      app
      :clipped-left="clipped"
    >
      <v-toolbar-side-icon @click.stop="drawer = !drawer"></v-toolbar-side-icon>
      <v-btn icon @click.stop="miniVariant = !miniVariant">
        <v-icon v-html="miniVariant ? 'chevron_right' : 'chevron_left'"></v-icon>
      </v-btn>
      <v-btn icon @click.stop="clipped = !clipped">
        <v-icon>web</v-icon>
      </v-btn>
      <v-btn icon @click.stop="fixed = !fixed">
        <v-icon>remove</v-icon>
      </v-btn>
      <v-toolbar-title v-text="title"></v-toolbar-title>

      <v-spacer></v-spacer>

      <v-progress-circular indeterminate v-if="isLoading"></v-progress-circular>
      <v-tooltip bottom max-width="200px">
        <v-alert v-model="isDisconnected" slot="activator" outline type="warning" icon="priority_high" value="true">
        Offline
        </v-alert>
        <span>Looks like you're not connected to the internet. Changes you make while offline will be synced when you reconnect.</span>
      </v-tooltip>
      <v-btn @click.stop="toggleTheme">
        theme
        <v-icon>mdi-theme-light-dark</v-icon>
      </v-btn>
      <v-btn tag="a" href="https://github.com/assimilatedgiraffe/PKB-webapp" target="_blank">
        View on GitHub
        <v-icon>mdi-github-box</v-icon>
      </v-btn>
      <v-btn @click.stop="logOut">
        Log out
        <v-icon>exit_to_app</v-icon>
      </v-btn>
      <v-btn icon @click.stop="rightDrawer = !rightDrawer">
        <v-icon>menu</v-icon>
      </v-btn>
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
    <v-navigation-drawer
      temporary
      :right="right"
      v-model="rightDrawer"
      fixed
      app
    >
      <v-list>
        <v-list-tile @click="right = !right">
          <v-list-tile-action>
            <v-icon>compare_arrows</v-icon>
          </v-list-tile-action>
          <v-list-tile-title>Switch drawer (click me)</v-list-tile-title>
        </v-list-tile>
      </v-list>
    </v-navigation-drawer>
    <v-footer :fixed="fixed" app>
      <span>&copy; 2017</span>
    </v-footer>
  </v-app>
</template>

<script lang="coffee">
import firebase from 'firebase'
import { mapGetters } from 'vuex'
import Login from './components/Login.vue'

export default {
  name: 'App'
  data: -> {
    clipped: false
    drawer: false
    fixed: false
    snackbar: false
    items: [{
      icon: 'bubble_chart'
      title: 'Inspire'
    }]
    miniVariant: false
    right: true
    rightDrawer: false
    title: 'Personal Knowledge Base Web App'
  }
  components: {Login}

  computed: {
    ...mapGetters ['isLoading', 'isBusy', 'error', 'darkTheme']
    isDisconnected: -> not this.$store.getters.isConnected
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
