<template lang="html">
  <div id="main-app">
    <el-row class="header">
      <el-col :span="24">
        history/breadcrumbs for subjects; recents
        <NoteList :notes="notes" is-horizontal="true"></NoteList>
      </el-col>
    </el-row>
    <el-row class="main-section">
      <el-col :span="24">
        grid view
        <NoteGrid :notes="notes"></NoteGrid>
      </el-col>
    </el-row>
  </div>
</template>


<script lang="coffee">

# import { db } from '../firebase.js'
import TextEditor from './TextEditor.vue'
import NoteList from './NoteList'
import NoteGrid from './NoteGrid'
import testAuth from './testAuth'

export default {
  name: 'MainApp'

  data: -> {
    # notes: {}
    }

  computed:
    notes: ->

  # firebase: {
  #     # notes: { source: db.ref('notes') }
  #   }

  components: { NoteList, NoteGrid }

  methods: {
  }

  created: ->
    this.$store.dispatch('signIn', testAuth)
    # this.$store.dispatch('loadDatabase')
    # this.$store.dispatch('watchDatabase')

  mounted: ->
    # this.$store.dispatch('generateTestData')
}
</script>


<style lang="css">
.el-col {
  height: 100%;
}
.header {
  height: 20vh;
}
.main-section {
  height: 80vh;
}

/*wireframe css*/
.el-col {
  border-style: solid;
}

</style>
