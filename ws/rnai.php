<?php
require "helper.php";
function RNAiSwitch($input) {
	$DBH = connectDB();
	$step = $input['step'];
	// print_r(PDO::getAvailableDrivers());
	switch ( $step ) {
		case 'test':
			echo json_encode( buildTree('3d62d2a23bd1ac7491577361fe430ec1') );
			// createTree($tree, $flatTree);
			break;
		case 'register' :

			/**
			 * get data from post
			 */
			$v = file_get_contents('php://input');
			// why?
			$v = stripslashes($v);
			$v = json_decode($v, true);

			// $STH = $DBH -> prepare("INSERT INTO query (queryname, query, status, mismatch, submittime,md5) values (:queryname, :query, :status, :mismatch, :submittime, :md5) returning id");

			// $submittime = time();
			$submittime = date('Y-m-d H:i:s');
			$ids = array();
			// print_r($v);

			foreach ($v as $key => $value) {
				$query = $value['query'];
				$STH = $DBH -> prepare("INSERT INTO query (queryname, query, status, mismatch, submittime,md5, mersize) values (:queryname, E'$query', :status, :mismatch, :submittime, :md5,:mersize)");
				$md5 = md5($value['query'] . $value['mismatch']);
				$value['submittime'] = $submittime;
				$value['status'] = 'submitted';
				$value['md5'] = $md5;
				$value['mersize'] = 21;
				// $value['query'] = "E'".$value['query']."'";
				// echo print_r( $value );
				unset($value['completetime']);
				unset($value['query']);
				unset($value['hits']);
				// print_r( $value );
				$STH -> execute($value);
				// print_r( $STH->errorInfo());
				array_push($ids, $DBH -> lastInsertId('query_id_seq'));
			}
			// print_r( $ids );
			$strids = join(',', $ids);
			$STH = $DBH -> prepare("select *, NULL as hits from query where id in ( $strids )");
			// $STH->bindValue( ':ids', join(',', $ids ), PDO::PARAM_INT );
			$STH -> execute();
			$json = $STH -> fetchAll(PDO::FETCH_CLASS);
			// print_r( $STH->errorInfo());
			echo json_encode($json);
			// exec("php5 exec.php > ../script/RNAi/output.txt &");
			executeProgram();
			break;
		case 'delete' :

			/**
			 * get data from post
			 */
			$v = file_get_contents('php://input');
			// why?
			$v = stripslashes($v);
			$v = json_decode($v, TRUE);

			$ids = array();
//			print_r($v);
			
			foreach ($v as $key => $value) {
//				echo print_r( $value );
	                        $STH = $DBH -> prepare("select * from query where id = $id");
        	                $STH -> execute();
                	        $query = $STH -> fetchAll(PDO::FETCH_ASSOC);
                        	$query = $query[0];
				
				// delete hits
                                $STH = $DBH -> prepare("Delete from hits where md5 = '".$query['md5']."'");
                                $STH -> execute( );

				// delete regions 
                                $STH = $DBH -> prepare("Delete from regions where md5 = '".$query['md5']."'");
                                $STH -> execute( );

				$STH = $DBH -> prepare("Delete from query where id = :id");
				$id = "".$value['id'];
				$ids[ $id ] = array();
				$success = $STH -> execute( array('id'=> $id ) );
				
				if( $success ){
//					echo "success";
					$ids[ $id ]['success'] = TRUE;  
				}else {
	//				echo "fail";
					$ids[ $id ]['success'] = FALSE;
					$ids[ $id ]['msg'] = 'Query did not execute';
				}
			}
			
//			$ids = '('.join(',', $ids).')';
			//echo $ids;
			
			echo json_encode( $ids );
			break;
		case 'execute' :
			// exec("nohup php5 exec.php &");
			executeProgram();
			break;
		case 'view' :
			$table = $input['table'];
			$id = $input['id'];
			$STH = $DBH -> prepare("select * from query where id = $id");
			$STH -> execute();
			$query = $STH -> fetchAll(PDO::FETCH_ASSOC);
			$query = $query[0];
			switch ( $table ) {
				case 'hits' :
					if (!$id) {
						return;
					}
					$STH = $DBH -> prepare("select dbid as id,hits, title as name from hits h join genome g on h.dbid = g.id ,query where h.md5 = query.md5 and query.id = $id");
					$STH -> execute();
					$json = $STH -> fetchAll(PDO::FETCH_ASSOC);
		
					echo json_encode( array( 'result'=>$json,'total'=>count($json)) );
		
					
					break;
				case 'tree' :
					if (!$id) {
						return;
					}
					$md5 = $query['md5'];
					$tree =  buildTree( $md5 ) ;
					$tree = setIcon( $tree );
					echo json_encode( array('children'=>array($tree)) );
					break;
				case 'query' :
					$limit = (int)$input['limit'];
					$page = (int)$input['page'];
					$offset = ($page - 1 )*$limit;
					$STH = $DBH -> prepare("select id,queryname,query,status,mismatch,submittime,count(hits) hits from query q left join hits h on h.md5 = q.md5 group by id,queryname,query,status,mismatch,submittime order by submittime DESC offset $offset limit $limit");
					$STH -> execute();
					$json = $STH -> fetchAll(PDO::FETCH_ASSOC);
					$STH = $DBH -> prepare("select count(*) as total from query");
					$STH -> execute();
					$total = $STH -> fetchAll(PDO::FETCH_ASSOC);
					$total = $total[0]['total'];
					echo json_encode( array( 'items'=>$json, 'total'=>$total ) );
					break;
				case 'canvas':
	/*
					$dbids = json_decode($input['dbids']);
						$stmt;
						if( count( $dbids ) ){
							$ids = '(' . join(',', $dbids ) . ')';
							$stmt = "select starting, ending, title from regions r join genome g on dbid = g.id join query q on r.md5 = q.md5 where q.id=$id and dbid in $ids";
						} else {
							$stmt = "select starting, ending, title from regions r join genome g on dbid = g.id join query q on r.md5 = q.md5 where q.id=$id";
						}
						$STH = $DBH-> prepare( $stmt );
						$STH -> execute();
						$serialisedRegions = $STH -> fetchAll(PDO::FETCH_ASSOC);*/
	
					$serialisedRegions = getQueryRegions($DBH,$input['dbids'], $id);
					$dbHitRegions = array();
					foreach ($serialisedRegions as $index => $row ) {
						$dbname = $row['title'];
						if( ! $dbHitRegions[$dbname] ){
							$dbHitRegions[$dbname] = array();
						}
						array_push( $dbHitRegions[$dbname],array( $row['starting'], $row['ending'] ) );
					}
					// print_r( $dbHitRegions );
//					$STH = $DBH-> prepare("select * from query where id = $id");
//					$STH -> execute();
//					$queryinfo = $STH -> fetchAll(PDO::FETCH_ASSOC);
					// echo $queryinfo[0]['query'];
					$result = canvasXGBFormat($id, $query['query'], $dbHitRegions);
					echo json_encode( array('canvas' => array( 'tracks' => $result ) ));
					break;
				case 'hitregionsinquery':
					$serialisedRegions = getQueryRegions($DBH,$input['dbids'], $id);
					$len = strlen( $query['query'] );
					$hitsScore = array();
$mismatches = array();
					foreach ($serialisedRegions as $index => $row ) {
						for( $i = (int)$row['starting']; $i < (int)$row['ending']; $i++){
							if( is_null( $hitsScore[$i] )){
								$hitsScore[$i - 1 ] = 0;
							}
							$hitsScore[$i - 1 ] ++;
						}
//echo print_r($row );
                        if( $row['mismatches'] ){
                            $mismatchesTmp = split( ',', $row['mismatches']);
                            if( $mismatchesTmp ){
                                foreach( $mismatchesTmp as $index => $mismatch){
                                    $numberofmatches = preg_match('/(\d+):(.)\>(.)/',$mismatch, $mismatchLocation);
//echo print_r($mismatchLocation);
                                    if( $numberofmatches ){
                                        $location = (int)$mismatchLocation[1] + (int)$row['starting'];
                                        if( is_null( $mismatches[$location] )){
                                            $mismatches[$location] = array();
                                        }
                                        $mismatches[$location][ $mismatchLocation[3] ] = true;
                                      }
                                }
                            }
                        }

					}
//print_r($mismatches);
					$html = showHitRegionsHTML( $query['query'], $hitsScore , $mismatches);
					echo '[{ "html": "'.$html.'" }]';
					break;
				default :
					break;
			}

			break;
	}
};
RNAiSwitch($_REQUEST);
?>
