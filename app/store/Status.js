Ext.define('RNAi.store.Status', {
  extend:'Ext.data.Store',
  fields : [{
    name : 'queryname',
    datatype:'string'
  }, {
    name : 'status',
    datatype: 'string'
  }, {
    name : 'id',
    datatype:'number'
  }, {
    name : 'query',
    datatype:'string'
  }, {
    name : 'mismatch',
    datatype:'number'
  },{
    name:'submittime',
    datatype:'date'
  },{
    name:'completetime',
    type:'date'
  }, {
    name : 'hits',
    datatype:'number'
  }],
  proxy : {
    url : 'data/status.json',
    api:{
      create: 'ws/rnai.php?step=register',
      read: 'ws/rnai.php?step=view&table=query&action=read',
      destroy:'ws/rnai.php?step=delete'
    },
    type : 'ajax', 
    reader:{
        totalProperty: 'total',
        root:'items'
    },
    writer: {
        type: 'json',
        allowSingle: false
    }
  },
  autoLoad: true,
  pageSize:50
});
