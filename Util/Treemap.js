Ext.define('Util.Treemap',{
  extend:'Ext.container.Container',
  // extend:'Ext.panel.Panel',
  text:'Tree Map',
  alias:'widget.treemap',
  height:100,
//  widht:'100%',
  /**
   * the current node selected.
   */
  node: null,
  /**
   * grid to which this container is attached.
   */
  grid: null,
  events:{
    /**
     * fired when node is changed.
     */
    nodechanged: true
  },
  /**
   * The property that stores the identifier value. 
   */
  idProp: 'id',
  /**
   * The property that stores name of the node.
   */
  nameProp: 'name',
  separator: ' &gt; ',
  hrefTpl: '<a href=\'#\' idRec="{id}">{name}</a>',
  initComponent:function(){
    console.log('init component of treemap');
    console.log( arguments );
    // debugger;
    Ext.util.Observable.capture(this, console.log);
    this.on('render',function(){
      this.grid = this.up('treepanel'); 
      this.grid.addListener('selectionchange',this.setNode,this);      
    },this);    
    this.addListener('nodechanged',this.displayPath);
    this.callParent( arguments );
  },
  setNode:function( tm, nodes ){
    var node, temp;
    console.log('selection node');
    if( nodes.length ){
      temp = this.node;
      this.node = nodes[0];
      (this.node != temp ) && this.fireEvent('nodechanged', this.node);
    }
  },
  displayPath:function( node ){
    var path = this.getPathToRoot( node );
    this.renderPath( path );
  },
  renderPath: function( path ){
    var node, label=[], name, tpl, id;
    if( path.length ){
      tpl = new Ext.Template( this.hrefTpl );
      for( var i = path.length - 1 ; i >= 0; i--){
        node = path[i];
        id = node.get( this.idProp );
        name = node.get( this.nameProp ) || node.get( this.idProp ) ;
        // label.push( Ext.create( 'Ext.form.Label', {
          // text: name,
          // node : node,
          // treepanel: this.grid,
          // listeners:{
            // afterrender: this.onLabelRender
          // }
        // }) );
        label.push( tpl.apply({name:name, id:id }));
      }
      // this.removeAll();
      this.update( label.join( this.separator ) );
      // debugger;
      this.getEl().select('a').on('click', this.onClick, this );
      console.log( 'treemap');
      console.log( this.getEl().child('a') );
      // this.doLayout();
    }
  },  
  getPathToRoot:function( node ){
    var path = [];
    if( node ){
      while( !node.isRoot() ){
        path.push( node );
        node = node.parentNode;
      }
      path.push( node );
    }
    return path;
  },
  onLabelRender:function(){
    this.getEl().on('click', function(){
      console.log( this.treepanel );
      this.treepanel.getSelectionModel().select( this.node );
    }, this);
  },
  onClick:function(event, target, opts){
    var id = target.getAttribute('idRec'), rec;
    rec = this.grid.getSelectionModel().getStore().find('id', id );
    this.grid.getSelectionModel().select( rec );
    event.preventDefault();
    // return false;
  }
});
