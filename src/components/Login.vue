<template lang='html'>
  <div>
    <el-dialog
      :show-close="false"
      center
      :visible="loginVisible"
      width="40%"
      >
    <span slot="title">
        <p>
          Welcome to version {{version}} of my Personal Knowledge Base Webapp.
          <br><br>
        </p>
        <el-button type="primary" @click="startDemo">User Guide and Demo</el-button>
      </span>
    <span slot="footer">
      New or returning User?
      <el-button type="primary" @click="logIn">Log in with Google</el-button>
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
  font-size: 29px;
  margin: 0;
}
</style>
