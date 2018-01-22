<template lang='html'>
  <div>
    <el-row>
      <el-col :span="12">New or returning User? </el-col>
      <el-col :span="12"><el-button type="primary" @click="logIn">Log in with Google</el-button></el-col>
    </el-row>
    <el-row>
      <el-col :span="12">Just Looking? </el-col>
      <el-col :span="12"><el-button type="primary" @click="startDemo">Demo mode</el-button></el-col>
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
      firebase.auth().signInWithPopup(provider).catch (error) =>
        console.log error
        this.$notify.error({ title: 'Sign in Error', message: error.message })

    startDemo: ->
      console.log "startDemo"
      firebase.auth().signInAnonymously().catch (error) =>
        console.log error
        this.$notify.error({ title: 'Sign in Error', message: error.message })

  # created: ->
  # mounted: ->
}
</script>
