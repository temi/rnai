<?PHP

include "../ws/helper.php";

#$api = 'http://bie.ala.org.au/ws/search.json?q=%s&fq=class:INSECTA';
$filename = 'Classification100kite.txt';
$db = connectDB();
$stmt = $db->prepare("select * from genome where filename is not null");
$stmt->execute();
$res = $stmt->fetchAll(PDO::FETCH_ASSOC);

$findHigherClass = $db->prepare('select * from genome where title = :title');
$insertClass = $db->prepare("insert into genome(title,parentid) values( :title, :id )");
$updateSpecies = $db->prepare("update genome set parentid=:parentid where id = :id");
$class = array('order','family','genus');
$insecta = insertTitle($db , 'ARTHROPODA',0);
$other = insertTitle($db, 'OTHERS',0);

// read file here.
$fh = fopen($filename,'r');
$classify = array();
$binomial;
while(($row = fgetcsv($fh,0,"\t"))!==FALSE){
  $binomial = $row[2].' '.$row[3];
  $classify[$binomial] = $row;
}
var_dump($classify);
foreach( $res as $key=>$row){
  $name = $row['title'];
  $species = $classify[$name];
  if( $species ){
    $id = $insecta[0]->id;
    $genomerow = insertTitle($db, $species[0], $id );
    $id = $genomerow[0]->id;
    $genomerow = insertTitle($db, $species[1], $id );
    $id = $genomerow[0]->id;
    $genomerow = insertTitle($db, $species[2], $id );
    $id = $genomerow[0]->id;
  } else {
    $id = $other[0]->id;
  }
  // update the species with correct id
  $updateSpecies->execute( array('parentid'=>$id,'id'=> $row['id'] )  );
}
print('successfully completed program.');  
function insertTitle($db, $title, $id){
  $findHigherClass = $db->prepare('select * from genome where title = :title');
  $insertClass = $db->prepare("insert into genome(title,parentid) values( :title, :id )");
 
  $genomestmt = $findHigherClass->execute(array('title'=>$title));
  $genomerow = $findHigherClass->fetchAll(PDO::FETCH_CLASS);
  if( ! count( $genomerow ) ){
    $insertClass->execute( array( 'title'=> $title , 'id'=>$id));
    $genomestmt = $findHigherClass->execute(array('title'=> $title ));
    $genomerow = $findHigherClass->fetchAll( PDO::FETCH_CLASS );
  }
  return $genomerow;
}

?>
