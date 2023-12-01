# uRescom -- Γέφυρα για διασύνδεση του Rescom με το Identity management

Το `uRescom` είναι μία εφαρμογή σε php για την παραγωγή του ενδιάμεσου πίνακα `v_vd_hrms` που απαιτείται για τη δημιουργία των λογαριασμών των χρηστών που προέρχονται από το `Rescom`.

## Βασικά Στοιχεία
### Τι κάνει το uRescom;

Το `uRescom` συνδέεται με τη βάση δεδομένων του `Rescom`, εκτελεί ένα σύνολο βημάτων και παράγει τις εγγραφές που πρέπει να υπάρχουν στον `v_vd_hrms`.

### Πώς γίνεται η εκτέλεση;

Η εκτέλεση γίνεται μέσα από το διαδικτυακό περιβάλλον του συστήματος. Επίσης απαιτείται και η εκτέλεση μιας διαδικασίας χρονοπρογραμματισμού (cron job), η οποία κάνει επικαιροποίηση της κατάστασης των λογαριασμών, συγκεκριμένα της στήλης employeeStatus, ώστε ανάλογα με την ισχύ των συμβάσεων, να έχει τιμές active, inactive, interim. Για παράδειγμα, αν
κάποια ενεργή σύμβαση λήξει, τότε, η χρονοπρογραμματισμένη διαδικασία που εκτελείται μία φορά την ημέρα, κάνει την κατάλληλη επικαιροποίηση στο πεδίο employeeStatus. Το Docker Compose stack φροντίζει να εκτελεί τη διαδικασία αυτή *αυτόματα* μέσω κατάλληλου service.

### Κύριοι πίνακες
Οι βασικοί πίνακες της εφαρμογής είναι οι ακόλουθοι:
* `v_vd_hrms`: Ο βασικός ενδιάμεσος πίνακας τον οποίο θα χρησιμοποιεί το `IDM` για τη δημιουργία χρηστών.
* `v_vd_hrms_incoming`: Ο πίνακας ο οποίος συγχρονίζεται με τη βάση του `Rescom` και διατηρεί τα στοιχεία των χρηστών τοπικά.
* `v_vd_hrms_loginnames`: Ο πίνακας στον οποίο διατηρείται η σύνδεση usernames με τους αριθμούς μητρώου των λογαριασμών του `Rescom`.

## FAQ
### Καταλήγουν όλοι οι συμβασιούχοι που υπάρχουν στο Rescom στον v_vd_hrms;

Όχι

### Ποιες εγγραφές συμβασιούχων καταλήγουν στον v_vd_hrms;

Οι εγγραφές των συμβασιούχων του Rescom που καταλήγουν στον `v_vd_hrms` είναι αυτές για τις οποίες έχει οριστεί όνομα χρήστη για το λογαριασμό του φυσικού προσώπου. Ο ορισμός ονόματος χρήστη γίνεται μέσα από το διαδικτυακό περιβάλλον του uRescom.

## Αρχιτεκτονική Εγκατάστασης
### Γενικές Πληροφορίες
Το `uRescom` παρέχεται από τη `GUNet` σε μορφή Docker containers για εύκολη εγκατάσταση.
Το ίδρυμα χρειάζεται απλά να εγκαταστήσει μία εικονική μηχανή (VM) σε κατάλληλη (ασφαλή)
τοποθεσία με δικτυακή πρόσβαση στη βάση του `Rescom`. Το VM θα λειτουργεί ως Docker
Host και απαιτείται απλά να είναι plain vanilla Linux (προτείνεται Debian) με εγκατεστημένο
το Docker (παρέχεται κατάλληλο script στο repo για την εγκατάσταση αυτή).

Για ευκολότερη εγκατάσταση η GUNet παρέχει Docker image για τη δημιουργία installation CD (ISO image)
`Just Enough OS` βασισμένου σε Debian bullseye. To public repo βρίσκεται [εδώ](https://github.com/gunet/JeOS/) (περιλαμβάνονται οδηγίες) ενώ το Docker image είναι το `ghcr.io/gunet/jeos-builder:latest`

Η λειτουργία της υπηρεσίας βασίζεται σε ένα Docker Compose stack με τα ακόλουθα στοιχεία:
* `uRescom` βασισμένο σε Apache+FPM και PHP (με τα κατάλληλα modules επικοινωνίας με βάσεις)
* `uRescom-cron` για την εκτέλεση του cron job συγχρονισμού
* `MariaDB` SQL βάση δεδομένων

Αρχιτεκτονικά, η GUNet έχει ήδη κάνει build base image για την υπηρεσία `uRescom` και το κάθε ίδρυμα
κάνει build τη δική του προσθέτοντας το δικό του configuration και (web) certificate pair.

Παράλληλα, για λόγους δοκιμών και εξοικείωσης με την υπηρεσία παρέχεται και testing stack το οποίο περιέχει επιπλέον:
* `CAS` SSO server για την πιστοποίηση χρηστών
* `OpenLDAP` LDAP server με δοκιμαστικούς χρήστες.
* `MSSQL` SQL server με δοκιμαστικό σχήμα και δεδομένα του `Rescom`
* MSSQL data init container το οποίο φροντίζει ώστε να αρχικοποιήσει τα δεδομένα της MSSQL βάσης με βάση
το σχήμα και δοκιμαστικά δεδομένα για το `Rescom`. Σημειώνουμε ότι αναλόγως με το υλικό στο οποίο
τρέχει το stack είναι πιθανό να απαιτηθεί αρκετός χρόνος ώστε να ξεκινήσουν όλα τα components του.

## Εγκατάσταση
Το κάθε ίδρυμα χρειάζεται να ασχοληθεί μόνο με το φάκελο `institution` και το αρχείο `variables.env`
Τα στοιχεία πρέπει να επικαιροποιηθούν **πριν** το build και εκτέλεση του Docker compose stack. Σημειώνουμε ότι το MariaDB
container **δε** θα είναι προσβάσιμο παρά μόνο από το container του `uRescom` οπότε δεν υπάρχει ιδιαίτερος λόγος να αλλάξουν τα default passwords.

Για το αρχείο `variables.env`, ιδιαίτερα σημαντικές είναι οι μεταβλητές:
* `PRIVKEY_PASSPHRASE`: Περιέχει το private key passphrase του private key του πιστοποιητικού της υπηρεσίας σε περίπτωση που επιλεχθεί η αποθήκευση του με κρυπτογραφημένο τρόπο (βλέπε και παρακάτω το τμήμα για το φάκελο `certs`)
* `URESCOM_SITE`: Θα πρέπει να είναι το FQDN του uRescom site, πχ `https://urescom.uoi.gr`
* `URESCOM_CAS_HOSTNAME`: To hostname του CAS SSO. Για τα ιδρύματα με GUNet IDM Θα είναι το `sso.<institution>.gr` (πχ `sso.uoi.gr` για το Πανεπιστήμιο Ιωαννίνων)
* `URESCOM_DOMAIN`: Συνήθης κατάληξη των ιδρυματικών email (συνήθως `<institution>.gr`)
* `URESCOM_SQL_TRUST_CERT`: Αν ο MSSQL server του `Rescom` διαθέτει πιστοποιητικό από έγκυρη αρχή πιστοποίησης και επιθυμούμε να το ελέγχουμε μπορούμε να θέσουμε την τιμή `yes`. Είναι αυτονόητο ότι σε αυτή την περίπτωση η σύνδεση με τη `Rescom` θα αποτύχει αν πχ το πιστοποιητικό της βάσης λήξει χωρίς να ανανεωθεί.

Στο φάκελο `institution` υπάρχουν δύο υπο-φάκελοι:
* `certs` για τα (web) πιστοποιητικά της υπηρεσίας
* `config` με τα αρχεία διαμόρφωσης

Επίσης υπάρχει ο φάκελος `test` ο οποίος γίνεται volume mounted σε περίπτωση testing περιβάλλοντος στο http location `/test`
και περιέχει τα εξής βοηθητικά αρχεία:
* `info.php` με αρχείο το οποίο απλά καλεί τη `phpinfo()`
* `test.php` με αρχείο το οποίο δοκιμάζει τις συνδέσεις προς τις βάσεις με αναλυτικό debugging
Καθώς είναι volume mounted, κάθε αλλαγή στα αρχεία αυτά θα φανεί απευθείας και στα αντίστοιχα στο `uRescom` container

Για λόγους διευκόλυνσης υπάρχουν τα παρακάτω βοηθητικά scripts:
* `scripts/install_docker.sh` για την εγκατάσταση του Docker subsystem (πρέπει να εκτελεστεί ως root)
* `urescom_admin.sh` για τη διαχείριση του Docker compose stack

### Φάκελος certs
Στο φάκελο χρειάζεται να ενσωματωθούν το certificate της υπηρεσίας στο αρχείο `server.crt` και το αντίστοιχο
private key στο αρχείο `privkey.pem` αν είναι plain-text ή `privkey.key` αν είναι κρυπτογραφημένο με 
passphrase. Στη δεύτερη περίπτωση θα πρέπει να οριστεί η κατάλληλη τιμή στην μεταβλητή `PRIVKEY_PASSPHRASE`
στο αρχείο `variables.env`

Τυπικά, τα πιστοποιητικά που εκδίδουν τα ιδρύματα (Sectigo ή HARICA) περιέχουν link (`Authority Information Access`) και προς την ιεραρχία των CA που υπέγραψαν τα πιστοποιητικό με συνέπεια οι browsers να μπορούν να επιβεβαιώσουν το πιστοποιητικό χωρίς να χρειάζεται το πλήρες certificate chain στο αρχείο. Αν κάποιος επιθυμεί να συμπεριλάβει όλο το chain στο αρχείο, το πρώτο certificate θα πρέπει να είναι το server certificate και το τελευταίο η root CA.

Η GUNet παρέχει [repo](https://github.com/gunet/cert-req/) με οδηγίες και κατάληλο Docker image για την εύκολη δημιουργία αιτήματος CSR, την κρυπτογράφηση ενός private key και την έκδοση ενός self-signed certificate

Για λόγους ευκολίας στο φάκελο υπάρχει ήδη ένα self-signed private key/certificate pair

### Φάκελος config
Στο φάκελο `config` υπάρχουν δύο αρχεία:
* `_config.php` με τη διαμόρφωση της υπηρεσίας. Τυπικά δεν απαιτούνται ιδιαίτερες μεταβολές καθώς οι περισσότερες τιμές
ορίζονται μέσα από μεταβλητές στο αρχείο `variables.env`. Εξαίρεση αποτελεί ο πίνακας `$cas_allowed_usernames_arr` ο
οποίος περιέχει τα usernames (πιστοποιημένα μέσω CAS SSO) που θα έχουν πρόσβαση στην εφαρμογή
* `acl.conf` για τον ορισμό αν απαιτείται Apache IP ACLs για περιορισμό πρόσβασης στην εφαρμογή.

### urescom_admin.sh
Το script έχει αναλυτικό help page αν εκτελεστεί χωρίς κάποιο argument.

Βασικές λειτουργίες είναι:
* `./urescom_admin.sh recreate` το οποίο θα πρέπει να χρησιμοποιηθεί **την πρώτη φορά** ώστε να γίνουν pull τα κατάλληλα
Docker images, να γίνει build το institutional image και να ανέβει το συνολικό stack. Αν υπάρξουν αλλαγές στο φάκελο
institution ή γνωρίζουμε ότι υπάρχει διαθέσιμη νέα έκδοση του `uRescom` base Docker image θα πρέπει να εκτελεστεί ξανά.
* `./urescom_admin.sh status` για να δούμε την κατάσταση του stack
* `./urescom_admin.sh down` για να κατεβάσουμε το stack με παράλληλη διαγραφή των containers. Το volume της MariaDB SQL
βάσης δεδομένων θα παραμείνει. Δεν πρόκειται για καταστροφική ενέργεια καθώς τα containers θα δημιουργηθούν ξανά από τα Docker images στο επόμενο `up`.
* `./urescom_admin.sh up` για να ανέβει ξανά το stack. Η εντολή είναι χρήσιμη σε περίπτωση που έχουμε κάνει down ή σε
περίπτωση που αλλάξουμε κάτι στο αρχείο `variables.env`
* `./urescom_admin.sh bash` για να ανοίξει bash shell στο container. Η εγκατάσταση του uRescom βρίσκεται στο φάκελο
`/var/www/urescom` που θα είναι και working directory του shell. Σημειώνουμε ότι ο container έχει εγκατεστημένο `vi`
ενώ είναι δυνατή η on the fly εγκατάσταση Debian πακέτων με `apt-get update && apt-get install -y <package name>`
* `./urescom_admin.sh remove` για να αφαιρεθούν εντελώς τόσο τα containers (που πρώτα θα κατέβουν αν εκτελούνται) όσο και
τα Docker images ώστε ο διαχειριστής να μπορεί να ξεκινήσει από το μηδέν αν το επιθυμεί.
* `./urescom_admin.sh destroy` για να γίνει πλήρης αφαίρεση της εγκατάστασης με διαγραφή containers, Docker images *και* του MariaDB data volume. **Προσοχή**: Αποτελεί την μόνη επιλογή που πραγματοποιεί διαγραφή δεδομένων και δε γίνεται κάποια αυτόματη παραγωγή backup της βάσης πριν την εκτέλεση της λειτουργίας αυτής.
* `./urescom_admin.sh backup [dst]` για να πραγματοποιηθεί backup των στοιχείων της βάσης (`urescom`) στο αρχείο `<dst>` ή αν δεν παρασχεθεί στο αρχείο `/var/tmp/urescom.sql`

Σημειώνεται ότι κατά το pull των Docker images το script θα παραπονεθεί για `error` σε ότι αφορά το image του `uRescom` και του `urescom-cron`. Δε χρειάζεται να ανησυχούμε καθώς αυτό γίνεται build τοπικά.

### Δοκιμαστικό περιβάλλον

Αν η μεταβλητή περιβάλλοντος `URESCOM_TESTING` είναι διαθέσιμη (πχ με `export URESCOM_TESTING=1`) τότε το script διαχείρισης `urescom_admin.sh` θα περιλάβει και το δοκιμαστικό περιβάλλον ενώ θα θέσει τις μεταβλητές κατάλληλα ώστε να μπορεί να λειτουργήσει σωστά.

Η υπηρεσία σε δοκιμαστικό περιβάλλον θα είναι διαθέσιμη στη σελίδα `https://localhost`

Ο ευκολότερος τρόπος για την αναζήτηση χρηστών κατά την πρώτη επαφή με το περιβάλλον είναι να αναζητηθούν "πρόσφατοι" συμβασιούχοι μέσω του tab `Νέοι συμβασιούχοι`. Μπορεί να επιλεχθεί κάποιο από αυτά για να προστεθεί loginName.

#### SSO usernames
Για δοκιμές μπορούν να χρησιμοποιηθούν τα username/password:
* `test/test`
* `gunetdemo/gunetdemo`

## Ανάγκες υλικού
### JeOS
Οι ανάγκες του JeOS που παρέχει η GUNet στο δίσκο είναι περίπου `3.5 GB`
### Βασική υπηρεσία
* Χώρος στο δίσκο: `1.3GB`
    - uRescom: `660MB`
    - DB: `400MB` + `200MB` για δεδομένα (αναλόγως με τα μεγέθη του κάθε ιδρύματος)
* Μνήμη: `200MB`
    - uRescom: `50MB`
    - DB: `150MB`
### Δοκιμαστικό περιβάλλον
* Χώρος στο δίσκο: `3.3GB`
    - uRescom: `660MB`
    - DB: `400MB` + `200MB` για δεδομένα
    - CAS: `320MB`
    - LDAP: `110MB`
    - MSSQL: `1.5GB` + `50MB` για δεδομένα
* Μνήμη: `2GB`
    - uRescom: `50MB`
    - DB: `150MB`
    - CAS: `800MB`
    - LDAP: `20MB`
    - MSSQL: `1GB`