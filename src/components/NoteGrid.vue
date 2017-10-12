<template lang="html">
  <div>
    <el-col :span="colSpan" v-for="col in numberOfCols" :key="col.id">
      <div class="note-list">
        <el-card v-for="note in notes" :key="note.id">
          <div>
            <TextEditor :note="note"></TextEditor>
          </div>
        </el-card>
      </div>
    </el-col>
  </div>
</template>

<script>
import TextEditor from './TextEditor.vue'

export default {
  data () {
    return {
      numberOfCols: 3
    }
  },
  props: ['notes'],
  components: {TextEditor},
  computed: {
    colSpan: function () { return 24 / this.numberOfCols }
  }
}
</script>

<style lang="css">
  .note-list {
    overflow-y: scroll;
    height: 100%;
  }
</style>
