Ext.define('RNAi.store.HTMLHitRegions', {
  extend:'Ext.data.Store',
  fields : [{
    name : 'html'
  }],
  proxy : {
    url : 'ws/rnai.php',
    type : 'ajax',
    extraParams:{
      id: null,
      table: 'hitregionsinquery',
      step: 'view',
      dbids: null
    }
  },
  autoLoad: false
});