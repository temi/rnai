Ext.define('RNAi.store.Classification', {
  extend : 'Ext.data.TreeStore',
  fields : ['id', 'name', {
    name : 'leaf',
    type : 'boolean'
  }],
  proxy : {
    url : 'ws/rnai.php?step=view&table=tree',
    type : 'ajax',
    extraParams : {
      id : null
    }
  },
  autoLoad : true
});
