<template lang="html">
  <div id="main-app">
    <el-row class="header">
      <el-col :span="24">history/breadcrumbs for subjects; recents</el-col>
    </el-row>
    <el-row class="main-section">
      <el-col :span="4">parent</el-col>
      <el-col :span="16">main editor</el-col>
      <el-col :span="4">children</el-col>
    </el-row>
  </div>
</template>


<script>
export default {
  name: 'MainApp',
  data () {
    return {
      msg: 'Welcome to Your Vue.js App'
    }
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
