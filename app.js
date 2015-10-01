Ext.Loader.setConfig({enabled:true});
Ext.application({
  name:'RNAi',
  appPath:'app/',
  requires:['Util.MultiViewPanel','Util.HelperFunctions','Util.TagCloud','Util.Treemap','RNAi.view.Viewport'],
  controllers:['Ctrl'],
  // autoCreateViewport:true,
  launch: function(){
    var tags;
    // Ext.util.Observable.capture(grid.view, console.log);
    // Ext.create('RNAi.view.Viewport', {
      // renderTo: Ext.getBody()
    // });
  }
});