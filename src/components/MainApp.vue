<template lang="html">
  <div id="main-app">
    <el-row class="header">
      <el-col :span="24">
        history/breadcrumbs for subjects; recents
        <NoteList/>
      </el-col>
    </el-row>
    <el-row class="main-section">
      <el-col :span="4">
        parent
        <NoteList/>
      </el-col>
      <el-col :span="16">
        main editor
        <TextEditor/>
      </el-col>
      <el-col :span="4">
        children
        <NoteList/>
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
      msg: 'Welcome to Your Vue.js App'
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
