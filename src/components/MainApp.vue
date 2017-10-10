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
      notes: {
        note1: {
          title: 'Example Title',
          text: 'some much longer example text for a note to see how scrolling works in the web app fjdklsfjsldkfjldksjf  jslkdfj dsfjkld fjslkdjs;lkfjsl   djklsjdf;lsjflksjfha fhsdjkf ahlkjf hskd  fhjdksla skdfdskjdgfjhdsf ghdj fsdhf sd f df hdskjfsdhkdjfhslkfh s dfhjdkslfksdjf skf ds fhsklf dkjhfskdhf sdfsdhjfklsfksdlfslj df shjkfhs f'
        },
        note2: {
          title: 'Example Title',
          text: 'some example text for a note'
        },
        note3: {
          title: 'Example Title',
          text: 'some example text for a note'
        }
      }
    }
  },
  components: {
    TextEditor,
    NoteList
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
