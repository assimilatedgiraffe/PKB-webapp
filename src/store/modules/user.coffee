import firebase from '../firebase.js'

export default {
  state:
    user: {}
    userID: ""

  mutations:
    setUser: (state, user) ->
      state.user = user
      state.userID = user?.uid

  actions:
    signIn: ({commit, state, dispatch, rootState}, user) ->
      console.log user
      commit('setUser', user)
      commit('setFbRef', firebase.database.ref('users/'+state.userID+'/notes'))
      commit('setFsRef', firebase.firestore.collection("users").doc(state.userID).collection("notes"))
      #check if anonymous (demo mode)
      if user.isAnonymous == true
        console.log "demo mode"
        dispatch('loadDemoNotes').then(dispatch('watchDatabase'))
      else
        dispatch('loadDatabase')

    signOut: ({commit, state, dispatch}) ->
      commit('setUser', null)

  getters:
    user: (state) -> state.user

}
