<template>
  <v-app dark>
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

      <v-alert color="warning" icon="priority_high" value="true">
        Offline
      </v-alert>
      <v-progress-circular indeterminate :active="isBusy"></v-progress-circular>
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
    <Login></Login>
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
    ...mapGetters ['isLoading', 'isBusy', 'error']
  }

  methods:
    logOut: ->
      console.log "logOut"
      firebase.auth().signOut()
}
</script>
