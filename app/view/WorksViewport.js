Ext.define('RNAi.view.Viewport', {
  extend : 'Ext.container.Viewport',
  requires : ['RNAi.store.Classification', 'RNAi.store.Hits', 'RNAi.store.Status', 'Util.GenomeBrowser'],
  // height : '100%',
  // width : '100%',
  layout : 'fit',
  events : {
    /**
     * fired when user clicks on show result button on status grid.
     * params:
     * 1. record of the clicked row
     */
    viewresult : true
  },
  initComponent : function() {
    var store = Ext.data.StoreManager.lookup('RNAi.store.Classification'), hits = Ext.data.StoreManager.lookup('RNAi.store.Hits'), status = Ext.data.StoreManager.lookup('RNAi.store.Status'), viewport = this, queries = Ext.data.StoreManager.lookup('RNAi.store.Queries'),
    htmlHitRegionsStore = Ext.data.StoreManager.lookup('RNAi.store.HTMLHitRegions'), hitPanel;
    this.classStore = store;
    this.hitsStore = hits;
    this.statusStore = status;
    this.queriesStore = queries;
    this.canvasStore = Ext.create('RNAi.store.CanvasXpress');
    this.htmlHitRegionsStore = htmlHitRegionsStore;
    
    hits.addListener('load',function(){
              viewport.displayEmptyText();
    });
    // store.load();
    // hits.load();
    
    // select the root node when new data is loaded
    store.addListener('load',function(){
      var panel = viewport.down('treepanel'), 
        root = panel.getRootNode();
      panel.getSelectionModel().select( root );
    });
    hitPanel = Ext.create( 'Ext.panel.Panel' ,{
      id:'hitRegions',
      menuTitle: 'Query Hit Regions',
      layout:'fit'
    });
    htmlHitRegionsStore.addListener('load',function(store, records, opt){
      if( records && records.length){
        this.update( records[0].data['html'] );
      }
    }, hitPanel);

    Ext.apply(this, {      items : [{
        xtype : 'tabpanel',
        layout : 'border',
activeTab: 0,
        // height : 700,
        // width : '100%',
        items : [{
          xtype : 'container',
          layout : 'hbox',
          title : 'Query',
          layout : 'border',
          id : 'query',
          items : [{
            xtype : 'form',
            layout : 'form',
            region : 'north',
            // height:400,
            // width:400,
            title : 'OffTargetFinder is a web-based tool for identifying RNAi sequences that will be specific to taxonomic groups.<br> <br>It is designed to assist transgene design and to identify non-target species at risk from particular RNAi-based pesticides.',
            items : [{
		icon : 'css/images/1kite_head.png',
              fieldLabel : 'Query String (fasta format no spaces in defline)',
              name : 'query',
              xtype : 'textarea',
              allowBlank : false,
              multi : true
            }, {
              fieldLabel : 'Mismatches(0-3)',
              name : 'mismatch',
              xtype : 'numberfield',
              value : 0,
              minValue : 0,
              maxValue : 3,
              allowBlank : false
            }],
            buttons : [{
	
              text : 'Find Off Targets',
              handler : this.onSubmitQuery
            }]
          }, {
            xtype : 'grid',
            title : 'History',
            region : 'west',
            store : status,
            height : 500,
            width : '100%',
            bbar:[{
              xtype:'pagingtoolbar',
              store: status,
              displayInfo: true
            }],
            viewConfig: { 
                  stripeRows: false, 
                  getRowClass: function(record) { 
                    var status = record.get('status'), className;
                    switch( status ){
                      case 'requesting':
                      case 'submitted':
                      case 'executing':
                        className =  'processing';
                        break;
                      case 'completed':
                        className = record.get('hits') > 0 ? 'hits' : 'nohits';
                        break;
                      
                    }
                    return className;
                  }
                },
            columns : [{
              dataIndex : 'queryname',
              text : "Query Name",
              flex : 1
            }, {
              dataIndex : 'status',
              text : "Status",
              flex : 1
            }, {
              dataIndex : 'submittime',
              text : "Submitted time",
              flex : 1
            }, {
              dataIndex : 'id',
              text : "Show Result",
              flex : 1,
              xtype : 'actioncolumn',
              items : [{
		
                icon :'css/images/1kite_head.png',
                tooltip : 'Transcriptome data brought you by the 1Kite consortium',
                handler : function(grid , rowIndex, columnIndex) {
                  var rec = grid.getStore().getAt(rowIndex);
                  if( rec.get('status') === 'completed'){
                    viewport.fireEvent('viewresult', arguments[5]);
                  } else {
                    Ext.Msg.show({msg:'The query has not completed execution. You can view it when status column says \'completed\'. Click the reload button to see if the query has completed.'});
                  }
                  
                }
              }]
            },{
              dataIndex : 'id',
              text : "Delete Query",
              flex : 1,
              xtype : 'actioncolumn',
              items : [{
                icon : 'css/images/delete.png',
                tooltip : 'delete query and result',
                handler : function(grid , rowIndex, columnIndex) {
                  var rec = grid.getStore().getAt(rowIndex);
                  if( rec.get('status') === 'completed'){
                    viewport.statusStore.remove( rec );
                    viewport.statusStore.sync();
                  } else {
                    Ext.Msg.show({msg:'The query can be deleted after it finishes execution'});
                  }
                  
                }
              }]
            }],
            tbar : [{
              xtype : 'button',
              text : 'Reload',
              handler : function() {
		viewport.statusStore.loadPage(1);
              }
            }]
          }]
        }, {
          xtype : 'container',
          layout : 'border',
          title : 'Result',
          id : 'result',
          listeners : {
            show : function() {
              viewport.displayEmptyText();
            }
          },
          // height : '100%',
          // width : '100%',
          items : [{
            xtype : 'treepanel',
            title : 'Organism Classification',
            region : 'west',
            collapsible : true,
            height : 800,
            width : 300,
            split : true,
            store : store,
            rootVisible: false  ,
            displayField : 'name',
            listeners : {
              selectionchange : function(tm, nodes) {
                var node, leaves = [], id;
                for (id in nodes) {
                  node = nodes[id];
                  node.eachChild(Util.HelperFunctions.getLeaves, leaves);
                  if (node.isLeaf()) {
                    leaves.push(node.get('id'));
                  }
                }
                console.log("leaves");
                console.log(leaves);
                Util.HelperFunctions.showSelection(leaves, hits);
                viewport.canvasStore.getProxy().setExtraParam('dbids', JSON.stringify(leaves));
                viewport.canvasStore.load();
                viewport.htmlHitRegionsStore.getProxy().setExtraParam('dbids', JSON.stringify(leaves));
                viewport.htmlHitRegionsStore.load();
              }
            }//,
            //bbar : [{
             // xtype : 'treemap'
           // }]
          }, {
            xtype : 'container',
            layout : 'vbox',
            region : 'center',
            items : [{
              id : 'querydetails',
              xtype : 'panel',
              html : 'Nothing to show',
              title : 'Query Details',
              height : 200,
              width : '100%',
              overflowY:'auto',
              xTpl : Ext.create('Ext.XTemplate', '<b>Query name: </b>{queryname}<br/><b>Status: </b>{status}<br/><b>mismatches: </b>{mismatch}<br/><b>Query: </b><p>{query}</p>'),
              updatePanel : function(data) {
                data = Ext.clone( data );
                var query = data['query'];
                query = query.match(/.{1,80}/g);
                query = query.join('<br/>');
                data['query'] = query;
                this.update(this.xTpl.apply(data));
              }
              // flex:1
            }, {
              xtype : 'multiviewpanel',
              title : 'Query Result',
              flex : 3,
              // region : 'center',
              // height : 500,
              // width : 300,
              // height:'100%',
              width : '100%',
              //layout : 'fit',
	      autoScroll:true,
	      //style:{
	//	'overflow-x':'scroll'
	  //    },
              // listeners:{
              // render:viewport.isEmpty,
              // show:viewport.isEmpty
              // },

              items : [
	Ext.create('Util.GenomeBrowser', {
                xtype : 'genomebrowser',
                store : this.canvasStore,
                menuTitle : 'Browser',
                layout : 'fit',
		//style:'overflow-y:auto',
		autoScroll:true,
		height:100,
		width:100
              }), 
	hitPanel,Ext.create('Ext.grid.Panel', {
                // height : 250,
                width : '100%',
                xtype : 'grid',
                emptyText : 'No results to show',
                menuTitle : 'Raw Data',
                store : hits,
                columns : [{
                  dataIndex : 'name',
                  text : 'Name',
                  flex : 1
                }, {
                  dataIndex : 'hits',
                  text : 'Hits',
                  flex : 1
                }]
              }), Ext.create('Ext.chart.Chart', {
               // width : 1000,
               // height : 300,
                animate : true,
                store : hits,
                menuTitle : 'Bar graph',
		autoScroll:true,
                listeners : {
                  show : function() {
		    this.setHeight( 30*this.store.count() )
                    this.refresh();
                  }
                },
                axes : [{
                  type : 'Numeric',
                  position : 'left',
                  fields : ['hits'],
                  label : {
                    renderer : Ext.util.Format.numberRenderer('0,0')
                  },
                  title : 'Hits',
                  grid : true,
                  minimum : 0
                }, {
                  type : 'Category',
                  //position : 'left',
                  position : 'bottom',
                  fields : ['name'],
                  title : 'Species',
		  label : {
			rotate:{degrees:270}	
                  }
                }],
                series : [{
                  type : 'column',
                  axis : 'left',
                  highlight : true,
                  tips : {
                    trackMouse : true,
                    width : 250,
                    height : 28,
                    renderer : function(storeItem, item) {
                      this.setTitle(storeItem.get('name') + ': ' + storeItem.get('hits'));
                    }
                  },
                  label : {
                    display : 'insideEnd',
                    'text-anchor' : 'middle',
                    field : 'data',
                    renderer : Ext.util.Format.numberRenderer('0'),
                    orientation : 'vertical',
                    color : '#333'
                  },
                  xField : 'name',
                  yField : 'hits'
                }]
              })]
            }]
          }],
          viewResult : function(record) {
            // clear selection
            var treep = viewport.down('treepanel');
            treep.getSelectionModel().deselectAll();
            
            viewport.classStore.getProxy().setExtraParam('id', record.get('id'));
            viewport.classStore.load();
            viewport.hitsStore.getProxy().setExtraParam('id', record.get('id'));
            viewport.hitsStore.load();
            viewport.statusStore.getProxy().setExtraParam('id', record.get('id'));
            viewport.statusStore.load();
            viewport.canvasStore.getProxy().setExtraParam('id', record.get('id'));
            viewport.canvasStore.load();
            viewport.htmlHitRegionsStore.getProxy().setExtraParam('id', record.get('id'));
            viewport.htmlHitRegionsStore.load();
            this.down('panel#querydetails').updatePanel(record.data);
          }
        }]
      }]
    });
    this.callParent(arguments);
  },
  displayEmptyText : function() {
    var panel = this.down('multiviewpanel');
    if (this.hitsStore.count() < 1) {
      if ( panel.rendered && !panel.emptyLoader ) {
        panel.emptyLoader = new Ext.LoadMask(panel, {
	  icon:undefined,
          msg : 'No result to show',
          useTargetEl : true
        });
        panel.emptyLoader.show();
      }
    } else {
      if (panel.emptyLoader) {
        panel.emptyLoader.hide();
        Ext.destroy( panel.emptyLoader );
        panel.emptyLoader = null;
      }
    }
  },
  onSubmitQuery : function() {
    // alert('submit clicked');
    console.log('querying started~!');
    // debugger;
    console.log(this);
    var form = this.up('form'), data = form.getValues(), viewport = this.up('viewport'), records, rec;
    console.log('new data adding');
    console.log(data);
    records = Util.HelperFunctions.parseFasta(data.query);
    console.log(records);
    for (var i = 0; i < records.length; i++) {
      rec = records[i];
      rec.mismatch = data.mismatch;
      rec.status = 'requesting';
    }
    viewport.statusStore.insert(0,records);
    viewport.statusStore.sync();
  }
}); 
