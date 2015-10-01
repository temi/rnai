Ext.define('Util.HelperFunctions',{
  singleton:true,
  getLeaves:function( node ){
    if( node.isLeaf()){
      this.push(node.get('id'));
      return;
    } else {
      node.eachChild( Util.HelperFunctions.getLeaves, this );
    }
  },
  showSelection:function( selected , store ){
    var i, id ;
      store.filterBy( Util.HelperFunctions.filterBy( selected ));
  },
  filterBy:function ( ids ){
    return function( rec ){
      var i, id;
      for ( i in ids ){
        id = ids[i];
        if(rec.get('id') == id ){
          return true;
        }
      }
      return false;
    };
  },
  /**
   * parse a fasta string. 
   * @param {Object} fasta
   *  >lm1
   *   AAGTCTGACGGAGCAACGCCGCGTGTATGAAGAAGGTTTTCGGATCGTAA
   *   AGTACTGTCCGTTAGAGAAGAACAAGGATAAGAGTAACTGCTTGTCCCTT
   *  >lm2
   *   AAGTCTGACGGAGCAACGCCGCGTGTATGAAGAAGGTTTTCGGATCGTAA
   *   AGTACTGTCCGTTAGAGAAGAACAAGGATAAGAGTAACTGCTTGTCCCTT
   * 
   * returns: object
   * [
   *  { "queryname":"lm1",
   *    "query": "AAGTCTGACGGAGCAACGCCGCGTGTATGAAGAAGGTTTTCGGATCGTAA
   *   AGTACTGTCCGTTAGAGAAGAACAAGGATAAGAGTAACTGCTTGTCCCTT"
   *  },{
   *   "queryname": "lm2",
   *   "query": "AAGTCTGACGGAGCAACGCCGCGTGTATGAAGAAGGTTTTCGGATCGTAA
   *   AGTACTGTCCGTTAGAGAAGAACAAGGATAAGAGTAACTGCTTGTCCCTT"
   *  }
   * ]
   */
  parseFasta: function( fasta ){
    fasta = fasta || '';
    var matches = fasta.match(/>[^\n]+[^>]+/mg), i, query, qname, lines, searchTxt, result = [], parsed;
    if ( matches && matches.length ){
      for( i = 0; i < matches.length; i++){
        parsed = {};
        query = matches[i];
        console.log( query );
        lines = query.split( '\n' );
        qname =  lines.shift();
        parsed.queryname = qname.replace('>','');
        parsed.query = lines.join('');
        result.push( parsed );
      }
    }
    return result;
  }
});