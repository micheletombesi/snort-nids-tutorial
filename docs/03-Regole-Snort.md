# **Regole Snort: struttura, funzionamento e scopo**

In questa lezione ci focalizzeremo sul cuore del motore di detection di Snort: le **regole**. Prima di passare alla scrittura pratica e all'analisi del traffico reale, è essenziale comprendere come sono strutturate le regole e quale logica seguono per intercettare minacce.

Le regole sono le istruzioni che definiscono quali pattern di traffico osservare e quali azioni intraprendere (ad esempio generare un alert) al verificarsi di determinate condizioni.

In questa sezione vedremo:

* Il concetto e lo scopo di una regola Snort.  
* La struttura sintattica (Header e Opzioni).  
* Il significato dei campi principali.

## **Cosa sono e a cosa servono le regole**

Una regola Snort è, essenzialmente, una **descrizione formale di un evento di rete**. Quando Snort opera in modalità NIDS (Network Intrusion Detection System), la regola non blocca o modifica il traffico, ma si limita a segnalare che una specifica condizione è stata rilevata.

L'obiettivo delle regole è trasformare il traffico grezzo in eventi di sicurezza leggibili, permettendo di:

* Individuare attacchi noti e tentativi di probing.  
* Rilevare anomalie nel traffico.  
* Monitorare l'accesso a risorse sensibili.

## **Struttura generale di una regola**

Ogni regola Snort è divisa logicamente in due parti principali: l'**Header** (intestazione) e le **Options** (opzioni).

La sintassi generica è la seguente:

Bash  
azione protocollo sorgente porta \-\> destinazione porta (opzioni)

### 

### **1\. L'Header della regola**

L'header è la parte fissa che definisce "chi" e "cosa" analizzare. È costituito dalle seguenti informazioni fondamentali:

* **Action**: indica l'operazione che Snort deve eseguire quando la regola viene soddisfatta. In modalità NIDS, l'azione più comune è `alert`, che genera una notifica e scrive un log. Esistono altre azioni (come `log` o `pass`), ma in questa fase ci concentreremo sulla generazione di allarmi.  
* **Protocol**: specifica il tipo di protocollo di trasporto da monitorare. I valori comuni sono `tcp`, `udp`, `icmp` (o `http` in Snort 3 con gli inspector dedicati). La scelta corretta del protocollo è vitale per la detection.  
* **Source IP & Port**: definiscono l'indirizzo IP e la porta di provenienza del pacchetto. Possiamo usare `any` per indicare "qualsiasi" o variabili come `$HOME_NET` per la rete interna.  
* **Direction Operator**: indica la direzione del traffico. L'operatore `->` specifica traffico che va dalla sorgente alla destinazione.  
* **Destination IP & Port**: definiscono l'indirizzo IP e la porta di destinazione.

Esempio di header: `alert tcp any any -> 192.168.1.0/24 80`

### **2\. Le Opzioni della regola**

Le opzioni costituiscono il cuore dell'analisi avanzata. Sono racchiuse tra parentesi tonde `( )` e separate da un punto e virgola `;`. Definiscono i dettagli del match (cosa cercare nel payload) e le informazioni da mostrare nell'alert.

Le opzioni principali che utilizzeremo sono:

* **msg**: è una stringa di testo che apparirà nel log dell'alert. Deve essere chiara e descrittiva (es. `msg:"HTTP GET request detected";`).  
* **content**: permette di cercare una specifica stringa o pattern esadecimale all'interno del pacchetto. È uno strumento potente ma va usato con cautela per evitare falsi positivi.  
* **nocase**: istruisce Snort a ignorare la differenza tra maiuscole e minuscole durante la ricerca del `content`.  
* **sid (Snort ID)**: è l'identificativo univoco della regola. Per le regole personalizzate (local rules), è buona norma utilizzare un range elevato (es. \> 1.000.000) per evitare conflitti con le regole ufficiali.  
* **rev**: indica il numero di revisione della regola. Ogni volta che una regola viene modificata, questo numero dovrebbe essere incrementato (es. `rev:1;`).

## 

## 

## **Esempio pratico di regola**

Mettiamo insieme i pezzi analizzando una regola completa per rilevare l'accesso a un server web:

Bash  
alert tcp any any \-\> $HOME\_NET 80 (msg:"HTTP access to web server"; content:"GET"; nocase; sid:1000002; rev:1;)

Analizziamo il comportamento di questa regola:

1. **Intercetta**: traffico TCP proveniente da qualsiasi indirizzo (`any`) verso la rete interna (`$HOME_NET`) sulla porta 80\.  
2. **Cerca**: la stringa "GET" all'interno del pacchetto, ignorando maiuscole/minuscole (`nocase`).  
3. **Segnala**: se il match avviene, genera un alert con il messaggio "HTTP access to web server".

### **Nota sui limiti delle regole "content"**

È importante notare che le regole basate puramente sulla ricerca di stringhe (`content`) presentano dei limiti: non "comprendono" la struttura del protocollo e possono essere evase o generare falsi positivi se la stringa appare in contesti legittimi non previsti. Per analisi più robuste, nelle prossime lezioni introdurremo l'uso dei *protocol inspectors*.

