<template lang="html">
  <div class="note-list">
    <el-card v-for="note in notes" :key="note.id" :class="{horizontal: isHorizontal}">
      <div>
        <h3>{{ note.title }}</h3>
      </div>
      <div v-show="!isHorizontal">
        {{ note.text }}
      </div>
    </el-card>
  </div>
</template>

<script>
export default {
  data () {
    return {
      testNotes: [
        'one', 'two', 'three'
      ]
    }
  },
  props: ['notes', 'isHorizontal']
}
</script>

<style lang="css">
  .note-list {
    overflow-y: scroll;
    height: 100%;
  }
  .horizontal {
    width: 180px;
    display: inline-flex;
  }
</style>
