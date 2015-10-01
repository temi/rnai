Ext.define('RNAi.store.Hits', {
  extend:'Ext.data.Store',
  fields : ['id','name', 'hits'],
  proxy : {
    url : 'ws/rnai.php?step=view&table=hits',
    type : 'ajax',
    extraParams: {
      id: null
    },
    reader:{
      type:'json',
      root:'result'
    }
  },
  autoLoad: true
});