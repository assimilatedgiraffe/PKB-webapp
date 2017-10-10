<template lang="html">
  <div id="main-app">
    <el-row class="header">
      <el-col :span="24">
        history/breadcrumbs for subjects; recents
        <NoteList :notes="notes" is-horizontal="true"></NoteList>
        <NoteList :notes="notes" is-horizontal="true"></NoteList>
      </el-col>
    </el-row>
    <el-row class="main-section">
      <el-col :span="4">
        parent
        <NoteList :notes="notes"></NoteList>
      </el-col>
      <el-col :span="16">
        main editor
        <TextEditor/>
      </el-col>
      <el-col :span="4">
        children
        <NoteList :notes="notes"></NoteList>
      </el-col>
    </el-row>
  </div>
</template>


<script>
import TextEditor from './TextEditor.vue'
import NoteList from './NoteList.vue'

export default {
  name: 'MainApp',

  data () {
    return {
      notes: {}
    }
  },

  components: {TextEditor, NoteList},

  methods: {
    generateTestData () {
      let testNotes = {}
      for (let i = 0; i < 5; i++) {
        testNotes[i] = {title: 'Text Title', text: 'some example text for a note'}
      }
      return testNotes
    }
  },

  mounted () {
    // do something after mounting vue instance
    this.notes = this.generateTestData()
  }
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
