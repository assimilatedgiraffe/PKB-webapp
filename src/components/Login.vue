<template lang='html'>
  <div>
    <el-dialog
      :show-close="false"
      center
      :visible="loginVisible"
      width="40%"
      >
    <span slot="title">
      <h1>
        Welcome to version {{version}} of my Personal Knowledge Base Web App.
        <br><br>
      </h1>
      <h3>
        NOTE: This early prototype is keyboard controlled/desktop only!
        <br><br>
        Click below for demo (no need to log in):
        <br><br>
        <br><br>
        <el-button type="primary" @click="startDemo">Demo and User Guide </el-button>
      </h3>
      </span>
    <span slot="footer" class="footer">
      New or returning User?
      <!-- <el-button type="info" size="mini" round @click="logIn">Log in with Google</el-button> -->
      <span @click="logIn" style="text-decoration: underline;">Log in with Google</span>
    </span>
  </el-dialog>
  </div>
</template>

<script lang='coffee'>
import firebase from 'firebase'

export default {
  name: 'Login'

  data: ->
    version: "0.1"

  computed:
    loginVisible: -> not this.$store.getters.user?

  methods:
    logIn: ->
      console.log "logIn"
      provider = new firebase.auth.GoogleAuthProvider()
      firebase.auth().signInWithRedirect(provider);
      this.$store.commit('setLoading', true)

    startDemo: ->
      console.log "startDemo"
      firebase.auth().signInAnonymously().catch (error) =>
        console.log error
        this.$notify.error({ title: 'Sign in Error', message: error.message })

  # created: ->
  # mounted: ->
}
</script>

<style scoped lang="css">
p {
  /*font-size: 29px;*/
  margin: 0;
}
.footer {
  background-color: grey;
}
</style>
