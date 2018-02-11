<template lang='html'>
  <div>
    <v-dialog v-model="loginVisible" persistent max-width="450">
      <v-card light>
        <v-card-title class="headline">
          Personal Knowledge Base Web App
          Version {{version}}
        </v-card-title>
        <v-card-text>
          <p>
            NOTE: this early version is optimised for desktop, viewing in landscape is recommended for mobile
          </p>
          <br/>
            Click below for demo (no need to log in):
          <br/>
          <v-spacer></v-spacer>
          <br/>
          <v-btn color="primary" large @click.native="startDemo"> Demo and User Guide </v-btn>
          <v-spacer></v-spacer>
            <small>
              <em>
                Existing user?
                <v-btn @click="logIn" color="grey darken-2" round flat small>Log in with Google</v-btn>
              </em>
            </small>
        </v-card-text>
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
