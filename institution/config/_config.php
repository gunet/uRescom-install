<?php
//ΜΕΤΟΝΟΜΑΣΤΕ ΑΥΤΟ ΤΟ ΑΡΧΕΙΟ ΣΕ config.php

$config_arr = array();

//Το αλλάζουμε αν θέλουμε να καθαρίσουμε την cache των css, javascript
$config_arr["cachetimestamp"] = "20221210_154513";

//ημερομηνία εγκατάστασης στη μορφή YYYY-MM-DD (set by docker build)
$config_arr["installation_date"] = "INSTALLATION_DATE";

//Συνήθης κατάληξη των ιδρυματικών e-mails π.χ. @todomainsas.gr
$config_arr["institution_mailpart"] = '@' . $_ENV['URESCOM_DOMAIN'];

//Αν ένας συνεργάτης έχει σύμβαση που ξεκινάει σε x=interim_limit_backwards
//μήνες, τότε για το διάστημα των x μηνών λαμβάνει το χαρακτηρισμό interim
$config_arr["interim_limit_backwards"] = "1";

//Αν η εφαρμογή τρέχει από τη ρίζα του ιστοτόπου αφήνουμε κενό
//Διαφορετικά, π.χ. αν τρέχει από υποφάκελο app, τότε βάζουμε app/
//Σημείωση: Στην περίπτωση υποφακέλου, τότε απαιτείται και το τελικό /
//όπως στο παράδειγμα
$config_arr["webroot"] = "";

//Αν ένας συνεργάτης έχει σύμβαση που έχει λήξει x=interim_limit_forward μήνες
//πριν, τότε για το διάστημα των x μηνών λαμβάνει το χαρακτηρισμό interim
$config_arr["interim_limit_forward"] = "3";

//Η διαδρομή (εκτός public html του autoload.php μετά την εγκατάσταση
//των πακέτων του composer.json), π.χ. εντός του libraries
//οπότε: "../ibrescom_offline/libraries/vendor/autoload.php"
$config_arr["vendor_path_autoload"] = "libraries/vendor/autoload.php";

//Στον παρακάτω φάκελο αποθηκεύονται τα αποτελέσματα εκτέλεσης των
//χρονοπρογραμματισμένων εργασιών. Αποθηκεύονται συνολικά 30 αρχεία και μετά
//γίνεται επανεγγραφή τους, π.χ. "../ibrescom_offline/crons/"
$config_arr["cron_output_folder"] = "___________________";

//1 = Γίνεται υποχρεωτικά ανακατεύθυνση σε https
//0 = μη υποχρεωτική ανακατεύθυνση
$config_arr["require_https"] = 1;

//1 = Γίνεται αυτόματη μεταγραφή ελληνικών ονομάτων σε αγγλικά
//ώστε να χρησιμοποιηθούν στις αγγλικές στήλες ονομάτων
//Στις ελληνικές στήλες ονομάτων παραμένουν τα ελληνικά
$config_arr["ELOT743"] = 0;

//Διαθέσιμες επιλογές: basic, cas
$config_arr["authmethod"] = "cas";

//Το μέγιστο που θα περιμένει το σύστημα για κάποια εκτέλεση.
//Αν περάσει αυτό το μέγιστο θεωρούμε ότι έχει ολοκληρωθεί η εκτέλεση
//απλώς δεν ενημερώθηκε η ώρα λήξης end_execution στο 1001
$config_arr["max_wait_seconds"] = 120;

//Στοιχεία σύνδεσης για Βάση Δεδομένων SQL Server Rescom
$config_arr["rescomsqlsrv_user"] = $_ENV['URESCOM_SQL_USER'];
$config_arr["rescomsqlsrv_password"] = $_ENV['URESCOM_SQL_PASSWORD'];
$config_arr["rescomsqlsrv_dsn"] = "sqlsrv:Server=$_ENV[URESCOM_SQL_HOST];Database=$_ENV[URESCOM_SQL_DATABASE];LoginTimeout=3;";

if ($_ENV['URESCOM_SQL_TRUST_CERT'] == 'yes')
  $config_arr["rescomsqlsrv_dsn"] = "sqlsrv:Server=$_ENV[URESCOM_SQL_HOST];Database=$_ENV[URESCOM_SQL_DATABASE];LoginTimeout=3;TrustServerCertificate=1;";

//Στοιχεία σύνδεσης για Βάση Δεδομένων Γέφυρα (που βλέπει το GUNet)
$config_arr["bridgedb_servername"] = $_ENV['URESCOM_MARIADB_HOST'];
$config_arr["bridgedb_username"] = $_ENV['URESCOM_MARIADB_USER'];
$config_arr["bridgedb_password"] = $_ENV['URESCOM_MARIADB_PASSWORD'];
$config_arr["bridgedb_dbname"] = $_ENV['URESCOM_MARIADB_DATABASE'];
$config_arr["bridgedb_port"] = "3306";

//Πίνακες βασικών αναζητήσεων
$config_arr["add_group_search_arr"] = ["vsrr__v_vd_hrms", "vkva__v_vd_hrms"];

//Ενεργοποίηση debugging (στα logs)
// Δυνατές τιμές:
// 1: Ενεργό
// 0: Ανενεργό
$config_arr['debug'] = 1;


if ($config_arr["authmethod"] == "basic") {
  $config_arr["basicauth_login_credentials"] = array(
    //"onomachristi" => "synthimatiko",
  );
} else if ($config_arr["authmethod"] == "cas") {
  ///////////// ΡΥΘΜΙΣΕΙΣ CAS ///////////

  //Τα ονόματα των χρηστών (από CAS) που έχουν δικαίωμα διαχείρισης
  $cas_allowed_usernames_arr =
    array(
      'admin'
    );

    // Only in testing
    if (isset($_ENV['URESCOM_TESING'])) {
      $cas_allowed_usernames_arr =
      array(
        'test', 'gunetdemo'
      );      
    }

  // Full Hostname of your CAS Server
  $cas_host = $_ENV['URESCOM_CAS_HOSTNAME'];

  // Context of the CAS Server
  $cas_context = $_ENV['URESCOM_CAS_CONTEXT'];

  // Port of your CAS server. Normally for a https server it's 443
  $cas_port = (int)$_ENV['URESCOM_CAS_PORT'];

  $client_service_name = $_ENV['URESCOM_SITE'];

  $client_domain = $_ENV['URESCOM_DOMAIN'];
  $client_path = 'phpcas';
  $client_secure = true;
  $client_httpOnly = true;
  $client_lifetime = 0;

  require_once 'requires/config_cas_rest.php';

  ////////// ΤΕΛΟΣ ΡΥΘΜΙΣΕΩΝ CAS ////////
}
?>