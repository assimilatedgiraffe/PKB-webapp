<template lang="html">
  <div id="main-app">
    <el-dialog
      title="Login"
      :visible="loginVisible">
      <Login></Login>
    </el-dialog>
    <!-- menu -->
      <el-row type="flex" class="header" justify="end">
        <el-menu mode="horizontal">
          <el-menu-item index="1" v-if="isDisconnected"> ! Offline Mode  </el-menu-item>
          <el-menu-item @click="logOut" index="2"> Log out </el-menu-item>
        </el-menu>
      </el-row>
    <!-- <el-row class="header">
      <el-col :span="24">
        history/breadcrumbs for subjects; recents
        <NoteList :notes="notes" is-horizontal="true"></NoteList>
      </el-col>
    </el-row> -->
    <el-row class="main-section">
      <el-col :span="24">
        <!-- grid view -->
        <NoteGrid></NoteGrid>
      </el-col>
    </el-row>
  </div>
</template>


<script lang="coffee">

import TextEditor from './TextEditor.vue'
import NoteList from './NoteList.vue'
import NoteGrid from './NoteGrid.vue'
import Login from './Login.vue'

import firebase from 'firebase'

export default {
  name: 'MainApp'

  # data: ->

  computed:
    loginVisible: -> not this.$store.getters.user?
    isDisconnected: -> not this.$store.getters.isConnected
    # notes: ->

  components: { NoteList, NoteGrid, Login }

  methods:
    logOut: ->
      console.log "logOut"
      firebase.auth().signOut()

  created: ->
    # this.$store.dispatch('loadDatabase')
    # this.$store.dispatch('watchDatabase')
    firebase.auth().onAuthStateChanged((user) =>
      if user
        this.$store.dispatch('signIn', user)
      else
        this.$store.dispatch('signOut')
    )

  mounted: ->
    # this.$store.dispatch('generateTestData')
}
</script>


<style lang="css">
.el-col {
  height: 100%;
}
.header {
  background-color: #eef1f6;
  margin-bottom: 10px;
}
.main-section {
  height: 80vh;
}

body {
  background-color: lightgrey;
}

/*wireframe css*/
/*.el-col {
  border-style: solid;
}*/

</style>
