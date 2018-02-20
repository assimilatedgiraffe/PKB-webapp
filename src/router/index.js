import Vue from 'vue'
import Router from 'vue-router'
import NoteGrid from '@/components/NoteGrid'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'NoteGrid',
      component: NoteGrid
    }
  ]
})
