Ext.define('RNAi.store.CanvasXpress', {
  extend:'Ext.data.Store',
  fields : [{
    name : 'canvas'
  }],
  proxy : {
    url : 'ws/rnai.php?step=view&table=canvas',
    type : 'ajax',
    extraParams:{
      id: null,
      table: 'canvas',
      step: 'view',
      dbids: null
    }
  },
  autoLoad: false
});