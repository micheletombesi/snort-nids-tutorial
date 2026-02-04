\# 04 – Snort as NIDS



\## Obiettivo del capitolo



In questo capitolo viene chiarito l’uso di \*\*Snort 3 come Network Intrusion Detection System (NIDS)\*\*, distinguendolo esplicitamente dalla modalità IPS.  

L’obiettivo non è riconfigurare Snort, ma comprendere \*\*cosa fa realmente Snort quando opera come NIDS\*\*, come analizza il traffico di rete in tempo reale e quali sono i suoi limiti operativi.



Si assume che:

\- Snort 3 sia già installato

\- `snort.lua` sia già configurato

\- la generazione di alert tramite regole personalizzate funzioni correttamente



---



\## NIDS vs IPS: distinzione operativa



Snort può funzionare in due modalità concettualmente diverse:



\- \*\*NIDS (Network Intrusion Detection System)\*\*  

&nbsp; Snort analizza il traffico di rete e \*\*genera alert\*\* quando individua pattern sospetti o noti, \*\*senza modificare o bloccare il traffico\*\*.



\- \*\*IPS (Intrusion Prevention System)\*\*  

&nbsp; Snort si colloca inline e può \*\*bloccare, scartare o modificare\*\* i pacchetti ritenuti malevoli.



In questo tutorial Snort viene utilizzato \*\*esclusivamente come NIDS\*\*.



---



\## Cosa significa usare Snort come NIDS



Quando Snort opera come NIDS:



\- è \*\*passivo\*\*

\- non interferisce con il traffico di rete

\- osserva i pacchetti che transitano sull’interfaccia

\- applica le regole di detection

\- registra eventi e alert



Dal punto di vista architetturale, Snort:

\- legge i pacchetti dall’interfaccia di rete

\- li decodifica

\- li ispeziona

\- applica il motore di rilevamento

\- produce output (alert e log)



Il traffico \*\*non viene mai bloccato\*\*.



---



\## Modalità live vs analisi offline



Snort può analizzare traffico in due modi:



\### Analisi offline (PCAP)

\- input: file `.pcap`

\- traffico statico

\- utile per test, debug e studio



\### Modalità live (NIDS reale)

\- input: interfaccia di rete (es. `eth0`, `ens33`, `wlan0`)

\- traffico reale in tempo reale

\- tipico scenario di un NIDS



In questo capitolo il focus è sulla \*\*modalità live\*\*, che rappresenta l’uso reale di Snort come NIDS.



---



\## Pipeline di analisi in Snort NIDS



Quando Snort è in esecuzione come NIDS, ogni pacchetto attraversa una pipeline ben definita:



1\. \*\*Packet acquisition\*\*  

&nbsp;  I pacchetti vengono letti dall’interfaccia di rete tramite il DAQ (Data Acquisition).



2\. \*\*Decoding\*\*  

&nbsp;  Snort interpreta i livelli di rete (Ethernet, IP, TCP/UDP, ICMP, HTTP, ecc.).



3\. \*\*Pre-processing / Inspection\*\*  

&nbsp;  I pacchetti vengono normalizzati e preparati per l’analisi.



4\. \*\*Detection engine\*\*  

&nbsp;  Il motore di rilevamento confronta il traffico con le regole definite.



5\. \*\*Output\*\*  

&nbsp;  Se una regola matcha, viene generato un alert secondo la configurazione scelta.



Questa pipeline è sempre attiva in modalità NIDS.



---



\## Ruolo delle regole in modalità NIDS



Le regole sono il cuore del funzionamento di Snort come NIDS.



In modalità NIDS:

\- una regola \*\*non blocca\*\*

\- una regola \*\*segnala\*\*

\- una regola \*\*descrive un evento sospetto\*\*



Il risultato di una regola che matcha è:

\- un alert

\- un log

\- una notifica (a seconda dell’output configurato)



Le regole possono rilevare:

\- scansioni di porte

\- traffico ICMP anomalo

\- richieste HTTP sospette

\- pattern noti di attacco

\- comportamenti fuori norma



---



\## Output degli alert in modalità NIDS



In un uso tipico da laboratorio e da studio, Snort come NIDS produce:



\- `alert\_fast.txt`  

&nbsp; formato testuale semplice, leggibile, ideale per capire cosa sta succedendo



\- eventuali output strutturati (JSON, unified, ecc.)  

&nbsp; usati in contesti più avanzati o di correlazione eventi



Nel tutorial si utilizza principalmente `alert\_fast.txt` per:

\- verificare il corretto funzionamento

\- interpretare le regole

\- analizzare il traffico rilevato



---



\## Cosa Snort NON fa come NIDS



È importante chiarire anche i limiti:



\- non blocca attacchi

\- non modifica il traffico

\- non impedisce la comunicazione

\- non sostituisce un firewall

\- non è un sistema di risposta automatica



Snort come NIDS \*\*osserva e segnala\*\*, lasciando ad altri sistemi (o all’analista) il compito di reagire.



---



\## Perché usare Snort come NIDS



Usare Snort come NIDS è utile perché:



\- permette di comprendere il traffico di rete

\- rende visibili pattern sospetti

\- consente lo studio delle intrusioni

\- è ideale per laboratori e ambienti di test

\- è perfetto per l’apprendimento dei meccanismi di detection



Nel contesto di Intelligent and Secure Networks, Snort come NIDS è uno strumento fondamentale per collegare:

\- teoria della sicurezza

\- traffico reale

\- regole di detection

\- analisi degli eventi



---



\## Collegamento al capitolo successivo



Nel prossimo capitolo Snort verrà utilizzato \*\*in modalità live su un’interfaccia reale\*\*, con:



\- avvio su interfaccia di rete

\- generazione di traffico controllato

\- scrittura di regole HTTP

\- analisi dettagliata degli alert prodotti



\*\*File successivo:\*\*  

`05-live-traffic-monitoring.md`



