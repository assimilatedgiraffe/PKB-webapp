<template lang='html'>
  <div>
    <el-row>
      <el-col :span="12">New or returning User? </el-col>
      <el-col :span="12"><el-button type="primary" @click="logIn">Log in with Google</el-button></el-col>
    </el-row>
    <el-row>
      <el-col :span="12">Just Looking? </el-col>
      <el-col :span="12"><el-button type="primary">Demo mode</el-button></el-col>
    </el-row>
  </div>
</template>

<script lang='coffee'>
import firebase from 'firebase'

export default {
  name: 'Login'

  # data: ->

  # computed:

  methods:
    logIn: ->
      console.log "logIn"
      provider = new firebase.auth.GoogleAuthProvider()
      firebase.auth().signInWithPopup(provider).then (result) =>
        # This gives you a Google Access Token. You can use it to access the Google API.
        token = result.credential.accessToken
        # The signed-in user info.
        user = result.user;

        this.$store.dispatch('signIn', user)

      .catch (error) ->
        #  Handle Errors here.
        console.log error

  # created: ->
  # mounted: ->
}
</script>
