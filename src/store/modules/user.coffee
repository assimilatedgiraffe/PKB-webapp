import firebase from '../firebase.js'

export default {
  state:
    user: null
    userID: ""

  mutations:
    setUser: (state, user) ->
      state.user = user
      state.userID = user.uid

  actions:
    signIn: ({commit, state, dispatch, rootState}, user) ->
      console.log user
      commit('setUser', user)
      commit('setFbRef', firebase.database.ref('users/'+state.userID+'/notes'))
      #check if anonymous (demo mode)
      if user.isAnonymous == true
        console.log "demo mode"
        firebase.database.ref('demoNotes').once('value')
        .then (data) ->
          rootState.fbRef.set(data.val())

      #check if new user
      rootState.fbRef.child("rootNode").once("value").then (data) ->
        if not data.val()?
          console.log "new user" # no rootNode means new user
          rootState.fbRef.push({
            parent: "rootNode"
            text: "Wecome to your Personal Knoledge Base"
            }).then (data) ->
              rootState.fbRef.child("rootNode").child("children").set([data.key])
              dispatch('loadDatabase')
              dispatch('watchDatabase')
        else
          dispatch('loadDatabase')
          dispatch('watchDatabase')
              # dispatch('generateTestData')
              # .catch (error) -> console.log error

    signOut: ({commit, state, dispatch}) ->
      commit('setUser', null)
}
