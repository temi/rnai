<?php
function connectionArray(){
	$host = 'localhost';
	$driver = 'pgsql';
	$dbname = 'rnai';
	$port = 5432; 
	$username = 'var03f';
    $password = 'h';
	
	return array(
	 'host' => $host,
	 'driver' => $driver,
	 'dbname' => $dbname,
	 'port' => $port,
	 'username' => $username,
	 'password' => $password
	);
	
	// $DBH = new PDO("pgsql:host=morgan;dbname=rnai;port=5435", 'var03f', '');
	//return array("pgsql:host=localhost;dbname=rnai;port=5432", 'var03f', 'h');
}

function connectDB() {
//	$connection_data = connectionArray();
	 
		// ;
$connection_data = json_decode( file_get_contents('../data/config.json' ) , TRUE );
	 
	$DBH = new PDO($connection_data['driver'].':host='.$connection_data['host'].';dbname='.$connection_data['dbname']
		.';port='.$connection_data['port'], $connection_data['username'],$connection_data['password']);
	return $DBH;
}

/**
 * this function will execute the program written by Rob and modified by Alexie
 *
 *
 *
 * returns
 *  no parameters
 */
function executeProgram() {
	exec("php5 exec.php&");
}
/**
 * this function formats hit regions into canvasxpress's genome browser understandable format.
 */
function canvasXGBFormat($id, $seq, $dbHitRegions, $mismatches ) {
	$len = strlen($seq);
	$dna = array( array('name' => $len, 'type' => 'sequence', 'subtype' => 'DNA', 'data' => array( array('id' => "Queryname", 'sequence' => $seq, 'fill' => 'rgb(255,25,51)', 'outline' => 'rgb(110,0,0)', 'dir' => 'right', 'offset' => 1))));
	
	// create box that represent each database hit regions
	$boxes = array();
	if($mismatches >=1){
		$RGB = "rgb(25,255,51)";
	}else{
		$RGB= "rgb(255,255,51)";}

	foreach ($dbHitRegions as $dbid => $regions) {
		$box = array('id' => $regions, 'type' => 'box', 'dir' => 'right', 'data' => array( array('data' => $regions, 'id' => $dbid)), 'fill' => $RGB, 'metaname' => $regions);
		array_push( $boxes, $box );
	}
	$dna = array_merge( $dna, $boxes );
	return $dna;
}
/**
 * 
 */
function getAncestors(){
	$dbh = connectDB();
	$stmt = $dbh->prepare('select id,title as name ,parentid, 1 as expanded from genome where filename is null order by id asc');
	$stmt -> execute();
	$sub = $stmt -> fetchAll( PDO::FETCH_CLASS);
	$result = array( );
	foreach ($sub as $key => $value) {
		$result[$value->id] = $value;
	}
    	#print_r($result);
	return $result;
}
function getLeaves( $md5 ){
	$dbh = connectDB();
	$stmt = $dbh->prepare("select id, title as name, parentid, 1 as leaf, hits from genome g join hits h on h.dbid=g.id where md5='$md5'");
	$stmt -> execute();
	$sub = $stmt -> fetchAll( PDO::FETCH_CLASS);
	return $sub;
}
function reconstructTree($node, $ancestors){
#function reconstructTree(&$node, &$ancestors){
#error_log('reconstructing\n');
#error_log($node->name );
  if( is_null ( $node->parentid ) ){
    return $node;
  }else {
    $parent = $ancestors[$node->parentid];
    if( !isset( $parent->children ) ){
      $parent->children = array();
    }
    if( !$node->traversed ){
     $parent->children[] = $node;
     $node->traversed = TRUE;
    }
    reconstructTree( $parent, $ancestors );
  }
}
function getHits( $node ){
#echo " entering getHits ".$node->name;
#echo print_r($node);
  if( !$node->hits ){
    $node->hits = 0;
  }
  foreach( $node->children as $child ){
    getHits($child);
    $node->hits += $child->hits;
  }
}
function buildTree( $md5 ){
	$leaves = getLeaves($md5);
	$ancestors = getAncestors();
	$nodes = array();
	$root;
	if( count($leaves)){
		foreach( $leaves as $key => $row ){
			$row->expanded = TRUE;
			$parent = $ancestors[$row->parentid];
			$rootNode = reconstructTree($row, $ancestors);
		}
		getHits( $ancestors[0] );
		$root = $rootNode->id;
		return json_decode(  json_encode( $ancestors[ 0 ] ),true) ;
	}
	return;
}
function getQueryRegions( $DBH, $dbids, $id ){
	ini_set('memory_limit', '-1');
	$dbids = json_decode($dbids);
	$stmt;
	if( count( $dbids ) ){
		$ids = '(' . join(',', $dbids ) . ')';
		$stmt = "select starting, ending, title, mismatches from regions r join genome g on dbid = g.id join query q on r.md5 = q.md5 where q.id=$id and dbid in $ids";
	} else {
		$stmt = "select starting, ending, title, mismatches from regions r join genome g on dbid = g.id join query q on r.md5 = q.md5 where q.id=$id";
	}
	$STH = $DBH-> prepare( $stmt );
	$STH -> execute();
	$serialisedRegions = $STH -> fetchAll(PDO::FETCH_ASSOC);
	return $serialisedRegions;
}
function showHitRegionsHTML($query, $hitsScore , $mismatches){
	$len =strlen( $query);
	$format = 'Black text on cyan background&emsp;&emsp;&emsp;&emsp;-  no offtargets<br/><br/>Yellow text on cyan background   -  1 offtarget<br/><br/>Red text on cyan background - 2 or more offtargets<br/><br/>Green background   -   Mismatch<br/><br/>';
	$max = max( $hitsScore );
	for( $i = 0;$i < $len; $i++){
		$score = $hitsScore[$i];
		if( is_null( $score )){
			$score = 0;
		}
		$ch = substr( $query, $i,1 );
		$p =  $score / $max ;
		$pos = $i +1;
		$color = setColor( $p );
		        $backgroundcolor = 'background-color:lightcyan';
        if( $mismatches[$i]){
            $backgroundcolor = "background-color:green";
        }
		$span = "<span style='color:$color;$backgroundcolor' title='position - $pos'>".$ch.'</span>';

		if( $i % 80 == 0){
			$format.='<br/>';
		}
		$format .= $span;
	}
	return $format;
}
function setColor($p){
 	$red = 0;
 	$green = 0;
	if( $p == 1){
		$red = 255;
	}else if( $p !== 0 ){
            $red = $p<0.5 ? round(256 - (0.5 - $p)*5.12):255;
	    $green = $p>0.50 ? round(($p)*5.12):255;
	}
    return "rgb(" . $red . "," . $green . ",0)";
}
function setIcon(&$root){
	$null = 'css/images/tree/drop-no.gif';
	$rootPic = 'css/images/tree/drop-yes.gif';
	$rEd = 'css/images/grid/red_rectangle.png';
	$orange = 'css/images/grid/orange_rectangle.png';
	$yellow = 'css/images/grid/yellow_rectangle.png';
	$grEen = 'css/images/grid/green_rectangle.png';
	$lightblue = 'css/images/grid/lightblue_rectangle.png';
	$darkblue = 'css/images/grid/darkblue_rectangle.png';
	$purple = 'css/images/grid/purple_rectangle.png';

	if( !empty( $root ) ){
		$hits = $root['hits'];
		if( is_null( $root['hits']) && !is_null( $root['children'] )) {
			$root['icon'] = $rootPic;
		} else if ( is_null ( $root['hits'] ) && is_null( $root['children'] )){
			$root['icon'] = $null;
		} else if ((int)$hits <= 1 ){
			$root['icon'] = $purple;
		} else if ( $hits > 1 && $hits < 5){
        		$root['icon'] = $darkblue;
        	} else if ( $hits >= 5 && $hits < 10){
                	$root['icon'] = $lightblue;
        	} else if ( $hits >= 10 && $hits < 20){
                	$root['icon'] = $grEen;
       	 	} else if ( $hits >= 20 && $hits < 50){
                	$root['icon'] = $yellow;
        	} else if ( $hits >= 50 && $hits < 100){
                	$root['icon'] = $orange;                                                                   
		} else if ( $hits >= 100 ){
                        $root['icon'] = $rEd;
		}
		if ( !is_null( $root['children'] )){ 
			foreach( $root['children'] as $i => $child){
				$child = setIcon ( $child );
				$root['children'][$i] = $child;
			}
		}
	}
	return $root;
}
?>
