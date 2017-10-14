<template lang="html">
  <div>
    <el-col :span="colSpan" v-for="col in cols" :key="col.id">
      <div class="note-list" >
          <div v-for="note in col" :key="note.id">
            <TextEditor :note="note"></TextEditor>
          </div>
      </div>
    </el-col>
  </div>
</template>

<script lang="coffee">
import TextEditor from './TextEditor.vue'

export default {
  data: -> {
    numberOfCols: 3
    selectedIndex: [0,0,0]
    selectedCol: 0
  }
  props: ['notes']
  components: {TextEditor}
  computed: {
    colSpan: -> 24 / this.numberOfCols
    cols: ->
      loading = [[{text:""}],[],[]]
      root = this.notes[0]
      return loading if not root
      # console.log root.children
      zero = root.children
      # one = zero[this.selectedIndex[0]].children?
      # two = one[this.selectedIndex[1]].children?
      # return [[{text:""}], [{text:""}], [{text:""}]]
      return [zero,zero,zero]
  }
}

</script>

<style lang="css">
  .note-list {
    overflow-y: scroll;
    height: 100%;
  }
</style>
