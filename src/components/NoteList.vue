<template lang="html">
  <div class="note-list">
    <el-card v-for="note in notes"></el-card>
  </div>
</template>

<script>
export default {
  data () {
    return {
      notes: [
        'one', 'two', 'three'
      ]
    }
  }
}
</script>

<style lang="css">
</style>
