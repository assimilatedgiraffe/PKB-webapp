<template lang="html">
  <!-- <div id="main-app"> -->
  <el-container>
    <Login></Login>
    <el-header>
      <!-- menu -->
      <el-row type="flex" class="header" justify="end">
        <el-col :span="12" class="title">
          <h3>
            <i class="el-icon-tickets"></i>
            Personal Knowledge Base Webapp
          </h3>
        </el-col>
        <el-col :span="12" >
        <el-menu mode="horizontal">
          <el-menu-item index="1" v-if="isDisconnected">
            <i class="el-icon-warning"></i>Offline Mode - No changes can be made until connected
          </el-menu-item>
          <el-menu-item index="2" v-if="isBusy">
            <i class="el-icon-loading"></i>
          </el-menu-item>
          <el-menu-item @click="logOut" index="3"> Log out </el-menu-item>
        </el-menu>
        </el-col>
      </el-row>
    </el-header>
    <!-- <el-row class="header">
      <el-col :span="24">
        history/breadcrumbs for subjects; recents
        <NoteList :notes="notes" is-horizontal="true"></NoteList>
      </el-col>
    </el-row> -->
    <el-main id="main" v-loading="isLoading">
    <el-row class="main-section">
      <el-col :span="24">
        <!-- grid view -->
        <NoteGrid ref="NoteGrid"></NoteGrid>
      </el-col>
    </el-row>
  </el-main>
  <!-- <el-footer>Footer</el-footer> -->
  </el-container>
</template>


<script lang="coffee">

import TextEditor from './TextEditor.vue'
import NoteList from './NoteList.vue'
import NoteGrid from './NoteGrid.vue'
import Login from './Login.vue'
import { mapGetters } from 'vuex'

import firebase from 'firebase'

export default {
  name: 'MainApp'

  # data: ->

  computed: {
    ...mapGetters ['isLoading', 'isBusy', 'error']
    loginVisible: -> not this.$store.getters.user?
    isDisconnected: -> not this.$store.getters.isConnected
    # notes: ->
  }

  components: { NoteList, NoteGrid, Login }

  methods:
    logOut: ->
      console.log "logOut"
      firebase.auth().signOut()

    documentClick: ->
      console.log "setFocus"
      this.$refs.NoteGrid.$el.focus()

  watch:
    error: (newError) ->
      if newError != ""
        this.$message.error(newError)
        this.$store.commit 'setError', ""

  created: ->
    # this.$store.dispatch('loadDatabase')
    # this.$store.dispatch('watchDatabase')
    firebase.auth().onAuthStateChanged((user) =>
      if user
        this.$store.dispatch('signIn', user)
      else
        this.$store.dispatch('signOut')
    )
    document.addEventListener('click', this.documentClick)

  mounted: ->
    # this.$store.dispatch('generateTestData')

  destroyed: ->
    document.removeEventListener('click', this.documentClick)
}
</script>


<style lang="css">
.el-col {
  /*height: 100%;*/
}
.header {
  background-color: #eef1f6;
  /*margin-bottom: 10px;*/
}
.main-section {
  /*height: 80vh;*/
}
.el-menu {
  float: right;
}
.title {
  padding-left: 10px;
  margin: auto;
}

.el-container {
  height: 100vh;
}
.el-header {
  padding: 0;
}
body {
  background-color: lightgrey;
  margin: 0;
}

/*wireframe css*/
/*.el-col {
  border-style: solid;
}*/

</style>
