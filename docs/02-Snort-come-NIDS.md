# **Snort come NIDS: modalità operativa e funzionamento**

In questo capitolo chiariremo l’uso di **Snort 3 come Network Intrusion Detection System (NIDS)**, operando una distinzione netta rispetto alla modalità IPS.

L’obiettivo non è modificare la configurazione tecnica (assumiamo che Snort sia già installato e il file `snort.lua` configurato), ma comprendere **cosa fa realmente il software** quando agisce come NIDS, come analizza il flusso dati in tempo reale e quali sono i perimetri della sua azione.

## **NIDS vs IPS: le differenze operative**

Snort è versatile e può operare in due modalità concettualmente opposte. È fondamentale comprendere questa differenza prima di procedere all'analisi del traffico:

* **NIDS (Network Intrusion Detection System)** In questa modalità, Snort "ascolta" il traffico di rete e **genera alert** quando individua pattern sospetti o noti. La caratteristica chiave è che **non modifica né blocca** il traffico.  
* **IPS (Intrusion Prevention System)** In questa configurazione, Snort si colloca "in linea" (inline) sul traffico e ha il potere di **bloccare, scartare o modificare** i pacchetti ritenuti malevoli.

In questo tutorial, utilizzeremo Snort **esclusivamente come NIDS**.

## **Cosa significa usare Snort come NIDS**

Quando Snort è configurato come NIDS, agisce come un osservatore **passivo**. Non interferisce con la comunicazione tra host, ma si limita a:

* Osservare i pacchetti che transitano sull’interfaccia.  
* Applicare le regole di detection.  
* Registrare eventi e alert.

Dal punto di vista architetturale, il traffico viene letto, decodificato, ispezionato e confrontato con il motore di rilevamento. Se scatta un allarme, viene prodotto un log, ma il pacchetto originale **continua il suo percorso senza essere bloccato**.

## **Modalità Live vs Analisi Offline**

Snort offre due approcci all'analisi del traffico:

1. **Analisi Offline (PCAP)**: L'input è un file registrato (`.pcap`). Il traffico è statico ed è utile per test, debug o studio forense.  
2. **Modalità Live (NIDS Reale)**: L'input è un'interfaccia di rete fisica o virtuale (es. `eth0`, `ens33`). Snort analizza il traffico reale nel momento stesso in cui avviene.

## **La Pipeline di analisi**

Quando Snort è in esecuzione, ogni singolo pacchetto attraversa una "catena di montaggio" (pipeline) rigorosa:

1. **Packet acquisition**: I pacchetti vengono prelevati dall’interfaccia di rete tramite il modulo DAQ (Data Acquisition).  
2. **Decoding**: Snort interpreta i vari livelli di rete (Ethernet, IP, TCP/UDP, HTTP, ecc.) per capire cosa sta guardando.  
3. **Pre-processing / Inspection**: I pacchetti vengono normalizzati (resi uniformi) per facilitare l'analisi.  
4. **Detection engine**: Il cuore del sistema. Qui il traffico viene confrontato con le regole definite dall'utente.  
5. **Output**: Se una regola trova corrispondenza (match), viene generato un alert.

## **Il ruolo delle regole e l'Output**

In modalità NIDS, le regole servono a **descrivere eventi sospetti**. Possono rilevare scansioni di porte, traffico anomalo o payload specifici.

Il risultato tipico di questa analisi, specialmente in ambienti di laboratorio e studio, è la scrittura di un file di log:

`alert_fast.txt`

Si tratta di un formato testuale semplice e leggibile, ideale per verificare il funzionamento delle regole e capire immediatamente cosa sta succedendo nella rete. Esistono formati più complessi (JSON, unified), ma per l'apprendimento il formato "fast" è lo standard.

## **Limiti: cosa Snort NON fa come NIDS**

Per evitare errate aspettative, è bene ricordare i limiti di questa modalità. Snort NIDS:

* **Non blocca** gli attacchi.  
* **Non sostituisce** un firewall.  
* **Non impedisce** la comunicazione tra attaccante e vittima.

Il suo compito è fornire **visibilità**: osserva e segnala, lasciando all'analista (o ad altri sistemi) il compito di reagire.

## **Perché usare questa modalità?**

Nonostante i limiti nell'intervento attivo, la modalità NIDS è fondamentale per chi studia la sicurezza delle reti. Permette di comprendere la natura del traffico, visualizzare pattern di attacco e testare le regole di detection in un ambiente controllato, collegando la teoria della sicurezza all'analisi pratica degli eventi.

