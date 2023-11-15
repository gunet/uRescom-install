<?php
require_once '../_config.php';

try {
  $dsn = "mysql:host=" . $config_arr["bridgedb_servername"]
  . ";port=" . $config_arr["bridgedb_port"]
  . ";port=" . $config_arr["bridgedb_port"];

  echo "MySQL dsn = $dsn, username = " . $config_arr["bridgedb_username"]
  . " password = " . $config_arr["bridgedb_password"] . "<br>\n";
  $global_bridgeconn = new PDO("mysql:host=" . $config_arr["bridgedb_servername"]
  . ";port=" . $config_arr["bridgedb_port"]
  . ";dbname=" . $config_arr["bridgedb_dbname"]
  , $config_arr["bridgedb_username"]
  , $config_arr["bridgedb_password"]);
  $global_bridgeconn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  if ($global_bridgeconn)
    echo "MySQL PDO is OK<br>\n";
}
catch (Exception $e) {
  echo "Error (new PDO for MySQL server): " . $e->getMessage();
  exit;
}

echo "SQL dsn = " . $config_arr["rescomsqlsrv_dsn"] . " username = "
. $config_arr["rescomsqlsrv_user"] . " password = "
. $config_arr["rescomsqlsrv_password"] . "<br>\n";
try {
  $global_rescomconn = new PDO($config_arr["rescomsqlsrv_dsn"],
  $config_arr["rescomsqlsrv_user"],
  $config_arr["rescomsqlsrv_password"]);
  $global_rescomconn->setAttribute( PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION );

  if ($global_rescomconn)
    echo "SQL PDO is OK<br>\n";
}
catch (Exception $e) {
  echo "Error (new PDO for SQL server): " . $e->getMessage();
  exit;
}
?>