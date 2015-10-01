Ext.define('RNAi.controller.Ctrl',{
  extend : 'Ext.app.Controller',
  // requires:['RNAi.view.Viewport'],
  views : ['RNAi.view.Viewport'],
  stores:['RNAi.store.Classification', 'RNAi.store.Hits','RNAi.store.Status','RNAi.store.Queries','RNAi.store.HTMLHitRegions'],
  refs:[{
    ref : 'viewport',
    selector : 'viewport'
  },{
    ref : 'result',
    selector: 'viewport tabpanel container#result'
  },{
    ref : 'query',
    selector: 'viewport tabpanel container#query'
  },{
    ref : 'AppView',
    selector: 'viewport tabpanel'
  }],
  init:function(){
    var ctrl = this;
    console.log( this.getView('Viewport') );
    this.getView('Viewport').create();
   this.control({
       'viewport' : {
        viewresult : function( record ){
          var appView, query, result;
          appView = ctrl.getAppView();
          result = ctrl.getResult();
          appView.setActiveTab( result );
          result.viewResult( record );
        }
      }
    }); 
  }  
});