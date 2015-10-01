<?php
require "helper.php";

// get config.json
$config = file_get_contents("../data/config.json");
$config = json_decode( $config, TRUE );
$databaseDir = $config['databaseDir'];
$tempDir = $config['tempDir'];
$queryFile = $config['queryFile'];

// get the list of submitted queries
$dbh = connectDB();
$sth = $dbh -> prepare("select * from query where status='submitted'");
$sth -> execute();
$submittedQs = $sth -> fetchAll(PDO::FETCH_ASSOC);

// change status from submitted to executing
$ids = array();
foreach ($submittedQs as $key => $value) {
	array_push($ids, $value['id']);
}

//stop script if there is none to execute
if( count($ids) == 0 ){
	return ;
}

$strIds = join(',', $ids);
$smtExec = $dbh -> prepare("update query set status='executing' where id in ( $strIds )");
$flag = $smtExec -> execute();
if (!$flag) {
	echo "error!";
	return;
}

// try to get lock to file
$fp = fopen("../files/lock.txt", "w+");
// echo 'before lock';
flock($fp, LOCK_EX);
// echo 'after lock';

//TODO: what happens when the md5 is already present in hits table

// execute rob's program
foreach ($submittedQs as $key => $value) {
	$id = $value['id'];
	$name = $value['queryname'];
	$md5 = $value['md5'];
	$query = $value['query'];
	$mismatch = $value['mismatch'];
	$mer_size = $value['mersize'];
	$queryH = fopen($queryFile, "w");
	fwrite( $queryH, "$name\t$query" );
	
	// print_r( $query );
	flush();
	fclose($queryH);
	print "../script/offtargetfinder.pl -file $queryFile -mismatch $mismatch -md5 $md5 -dir $databaseDir -outdir $tempDir -dbhost ".$config['host']." -dbuser ".$config['username']." -dbpass ".$config['password']." -dbname ".$config['dbname']." -port ".$config['port'];
	exec("../script/worfinder.pl -file $queryFile -mismatch $mismatch -md5 $md5 -dir $databaseDir -outdir $tempDir -dbhost ".$config['host']." -dbuser ".$config['username']." -dbpass ".$config['password']." -dbname ".$config['dbname']." -port ".$config['port']);
// TODO: is the tree table really needed?
	// $tree = json_encode( buildTree( $md5 ) );
	// print $tree;
	// $dbh->query("insert into tree(md5,tree) values('$md5','$tree')");

	$completetime = date('Y-m-d H:i:s');
	$dbh->query("update query set completetime='$completetime',status='completed' where id =$id");
}



// release lock
flock($fp, LOCK_UN);
fclose($fp);
?>
