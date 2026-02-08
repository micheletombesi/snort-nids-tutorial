Progetto di Implementazione NIDS: Snort 3 e PulledPork v3

Corso: Intelligent and Secure Networks Descrizione: Guida all'implementazione, configurazione e testing di un Network Intrusion Detection System.

Documentazione del Progetto

La documentazione completa del progetto è contenuta esclusivamente nella cartella dedicata. Il tutorial passo-passo, comprensivo di note teoriche, comandi di configurazione e analisi dei risultati, è disponibile in formato PDF al seguente percorso:
> Cartella: docs/
Si prega di fare riferimento al file PDF contenuto in tale directory per la guida operativa.

Obiettivi del Laboratorio

Il progetto ha lo scopo di illustrare il ciclo di vita completo di un sistema NIDS moderno. Attraverso la documentazione fornita, vengono trattati i seguenti punti:
Configurazione dell'Ambiente: Predisposizione di una Macchina Virtuale Ubuntu Server 24.04 LTS con configurazione di rete "Dual-Homed" (NAT + Rete Interna) per simulare un ambiente di produzione sicuro.
Compilazione di Snort 3: Installazione del motore IDS direttamente dal codice sorgente per garantire il controllo sulle dipendenze e sulle funzionalità abilitate.
Architettura NIDS: Analisi delle differenze operative tra la modalità di rilevamento (NIDS) e quella di prevenzione (IPS), con focus sulla pipeline di analisi dei pacchetti.
Gestione delle Regole (Threat Intelligence): Implementazione di PulledPork v3 per l'automazione del download e dell'aggiornamento delle regole Cisco Talos (set LightSPD), con configurazione specifica per l'esclusione delle regole "Shared Object" incompatibili.
Analisi Forense (Offline): Analisi di file PCAP contenenti traffico generato da malware reali (Emotet e IcedID) per identificare la catena di infezione (Kill Chain) e verificare l'efficacia delle firme.
Analisi Live: Intercettazione e analisi del traffico in tempo reale tra una macchina attaccante e la sonda Snort.

Requisiti di Sistema

Per replicare l'ambiente di laboratorio descritto nella documentazione, sono necessari i seguenti requisiti minimi:
Hypervisor: Oracle VirtualBox (versione 7.x o superiore consigliata).
Sistema Operativo Guest: Ubuntu Server 24.04 LTS.
Risorse Virtuali: Minimo 2 vCPU e 4GB di RAM per la VM Snort.

Disclaimer di Sicurezza

Questo repository contiene, all'interno della cartella dedicata ai test o tramite riferimenti nella documentazione, file di cattura traffico (.pcap) relativi a minacce informatiche reali. Sebbene tali file non siano eseguibili e non costituiscano un rischio di infezione diretta durante la semplice analisi tramite Snort, si raccomanda di manipolarli esclusivamente all'interno dell'ambiente virtuale isolato predisposto per il laboratorio.
