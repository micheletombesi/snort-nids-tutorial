# **Installazione di Snort 3**

In questa sezione affronteremo l'installazione di **Snort 3** all'interno dell'ambiente virtuale predisposto per il corso "Intelligent and Secure Networks".

Il processo è stato testato e ottimizzato per **Ubuntu 24.04 LTS**, il sistema operativo in esecuzione sulla macchina virtuale fornita per le attività di laboratorio.

## **Ambiente e requisiti**

Prima di procedere, riepiloghiamo la configurazione dell'ambiente di lavoro:

* **Host system**: Windows.  
* **Guest system**: Ubuntu Server 24.04 LTS (la VM del corso).  
* **Hypervisor**: Oracle VirtualBox.  
* **Repository**: Cartella condivisa di VirtualBox (`/media/sf_ISNCODES/snort-nids-tutorial`).

È importante notare un dettaglio tecnico: sebbene i file del progetto risiedano in una cartella condivisa, la compilazione di Snort e delle sue dipendenze verrà eseguita nella directory locale (`~/build`). Questa scelta è necessaria per evitare i problemi di permessi e il calo di prestazioni tipici delle cartelle montate in condivisione.

## **Strategia di installazione**

Per garantire il massimo controllo sulle funzionalità abilitate e la perfetta compatibilità con l'ambiente del corso, installeremo Snort 3 **compilandolo dal codice sorgente**.

Questa procedura ci permette di ottenere un setup riproducibile e comprende quattro fasi logiche:

1. Installazione dei tool di compilazione e delle librerie di sviluppo.  
2. Compilazione e installazione di **LibDAQ** (la libreria per l'acquisizione dati).  
3. Compilazione e installazione di **Snort 3**.  
4. Verifica del funzionamento.

Per semplificare l'operazione, tutti i passaggi sono stati automatizzati in uno script dedicato.

## **Lo script di installazione automatica**

L'intera procedura viene gestita dallo script:

`scripts/install-snort3.sh`

Ecco cosa esegue esattamente lo script "dietro le quinte":

* **Pulizia e aggiornamento APT**: Previene errori dovuti a cache o mirror non sincronizzati.  
* **Installazione dipendenze**: Scarica tutto il necessario, inclusi:  
  * Toolchain di compilazione (`gcc`, `make`, `cmake`).  
  * Librerie di rete (`libpcap-dev`).  
  * Librerie per il pattern matching (`libpcre2-dev`).  
  * Librerie crittografiche e protocolli (`libssl-dev`, `libnghttp2-dev`).  
  * Supporto LuaJIT per la configurazione.  
* **Build di LibDAQ e Snort**: Compila e installa i software nella directory `/usr/local`.

Un dettaglio importante: lo script è configurato per limitare il parallelismo della compilazione a un singolo job, per evitare di saturare la memoria della macchina virtuale (2 GB RAM).

## **Esecuzione e verifica**

Per avviare l'installazione, posizionarsi nella root del progetto ed eseguire lo script con i privilegi necessari:

Bash

cd /media/sf\_ISNCODES/snort-nids-tutorial

chmod \+x scripts/install-snort3.sh

./scripts/install-snort3.sh

La compilazione richiederà diversi minuti, a seconda delle risorse assegnate alla VM.

Al termine del processo, è fondamentale verificare che l'installazione sia andata a buon fine interrogando la versione di Snort:

Bash

snort \-V

Se l'output mostra il numero di versione e le informazioni sulla build, Snort è pronto all'uso.

### **Risoluzione problemi comuni (Errori 404\)**

Durante la fase di setup, potrebbero verificarsi errori temporanei di tipo "404 Not Found" durante il recupero dei pacchetti dai mirror di Ubuntu. Questo accade spesso quando le liste dei pacchetti sono obsolete.

Per ripristinare uno stato consistente e poter rilanciare lo script, eseguire questi comandi di pulizia:

Bash

sudo apt clean

sudo rm \-rf /var/lib/apt/lists/\*

sudo apt update

Una volta aggiornate le liste, è possibile rieseguire lo script di installazione in sicurezza.

