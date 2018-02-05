<template lang='html'>
  <div>
    <v-dialog v-model="loginVisible" persistent max-width="590">
      <v-card>
        <v-card-title class="headline">
          Welcome to version {{version}} of my Personal Knowledge Base Web App.
        </v-card-title>
        <v-card-text>
          NOTE: This early prototype is keyboard controlled/desktop only!
          <v-spacer></v-spacer>
          Click below for demo (no need to log in):
        </v-card-text>
        <v-card-actions>
          <v-btn color="green darken-1" flat @click.native="startDemo"> Demo and User Guide </v-btn>
          <v-spacer></v-spacer>
          <span @click="logIn" style="text-decoration: underline;">Log in with Google</span>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script lang='coffee'>
import firebase from 'firebase'

export default {
  name: 'Login'

  # data: ->

  computed:
    loginVisible: -> not this.$store.getters.user?
    version: -> this.$store.getters.version
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
