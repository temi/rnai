Ext.define('RNAi.store.Queries',{
  extend:'Ext.data.Store',
  fields:[{
    name: 'query',
    type:'string'
  },{
    name:'mismatch',
    type: 'number'
  }],
  proxy:{
    type:'ajax',
    url:'ws/rnai.php?step=view&table=query',
    api:{
      // create: 'data/status.json',
      // read: 'data/query.json'
    },
    processResponse:function(){
      console.log( 'queries!' );
      console.log( arguments );
    }
  },
  autoLoad:true
});
