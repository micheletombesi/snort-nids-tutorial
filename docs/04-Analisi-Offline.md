# **Analisi Offline (PCAP) e primi alert con Snort 3**

In questa sezione effettueremo il primo test operativo di Snort 3\. Invece di collegarci subito alla rete dal vivo, analizzeremo una cattura di traffico pre-registrata (file PCAP) per far scattare un alert personalizzato.

Questo passaggio è cruciale per verificare tre aspetti prima di andare online:

1. Il motore di detection funziona correttamente.  
2. La sintassi delle regole è valida.  
3. Il file di configurazione punta correttamente al file delle regole.

## **Ambiente e requisiti**

Per questo test utilizzeremo i seguenti percorsi e file, già predisposti nell'ambiente del corso:

* **Directory di lavoro**: `/media/sf_ISNCODES/snort-nids-tutorial`  
* **File di configurazione**: `snort/snort.lua`  
* **File delle regole**: `snort/rules/local.rules`  
* **Traffico di test**: `pcaps/test-http.pcap`

Lavorare in modalità "offline" (leggendo da file invece che da interfaccia di rete) garantisce la riproducibilità del test ed è la prassi standard per validare nuove regole senza "rumore" di fondo.

## **1\. Definizione della regola personalizzata**

Le regole di Snort devono rispettare una sintassi rigorosa. Un errore molto comune è spezzare una regola su più righe: questo causa il fallimento del parser.

Per questo test iniziale, useremo una regola generica che genera un alert su **qualsiasi traffico IP**.

Apri o crea il file `snort/rules/local.rules` e inserisci la seguente regola, assicurandoti che sia scritta su **un'unica riga**:

Plaintext

alert ip any any \-\> any any (msg:"TEST any IP traffic"; sid:1000001; rev:1;)

**Analisi della regola:**

* **Header**: `alert ip any any -> any any` (Genera un alert sul protocollo IP, da qualsiasi sorgente verso qualsiasi destinazione).  
* **Body**: `(msg:"..."; sid:...; rev:...)` (Contiene i metadati, come il messaggio da visualizzare e il Signature ID univoco).

## **2\. Configurazione di snort.lua**

Affinché Snort carichi questo file in modo permanente, dobbiamo modificare il file di configurazione principale, `snort.lua`.

Snort 3 utilizza il linguaggio Lua per la configurazione. Un errore frequente è tentare di includere file di regole testuali usando comandi di script Lua (generando errori come `'=' expected near 'ip'`).

**Configurazione corretta:**

1. Aprire `snort/snort.lua`.  
2. Individuare o creare il blocco di configurazione del modulo `ips`.  
3. Usare la variabile `include` per puntare al file delle regole.

Si consiglia l'uso di un **percorso assoluto** per evitare ambiguità quando si esegue Snort da directory diverse.

Lua

ips \=

{

    \-- Usa 'include' per caricare file di regole testuali standard.

    \-- Assicurati che il percorso sia corretto e accessibile.

    include \= '/media/sf\_ISNCODES/snort-nids-tutorial/snort/rules/local.rules'

}

**Nota importante**: Non usare il comando `include 'file.rules'` a livello globale nel file `snort.lua`. Snort tenterebbe di eseguire il file delle regole come se fosse uno script Lua, fallendo. L'include va inserito dentro il blocco `ips = { ... }`.

## 

## **3\. Esecuzione dell'analisi**

Ora che configurazione e regole sono pronte, eseguiamo Snort contro il file PCAP.

### **Gestione dei Checksum**

Il traffico catturato (file PCAP) spesso contiene pacchetti con checksum TCP/UDP errati (a causa del "checksum offloading" sulle schede di rete che hanno effettuato la cattura). Di default, Snort scarta silenziosamente questi pacchetti. Per analizzare questi file, è obbligatorio usare il flag `-k none` per disabilitare la verifica dei checksum.

### **Comando di esecuzione**

Dalla root del progetto, esegui il seguente comando:

Bash

snort \-c snort/snort.lua \-r pcaps/test-http.pcap \-k none \-A alert\_fast

**Spiegazione del comando:**

* `-c snort/snort.lua`: Indica quale file di configurazione usare (dove abbiamo definito il blocco `ips`).  
* `-r pcaps/test-http.pcap`: Legge il file PCAP specificato (modalità Replay).  
* `-k none`: Forza Snort a ignorare i checksum errati (Fondamentale per la riproduzione di PCAP).  
* `-A alert_fast`: Stampa gli alert direttamente in console in un formato semplice e leggibile.

## **4\. Output atteso e Risoluzione problemi**

Se l'operazione ha successo, Snort processerà i pacchetti e visualizzerà gli alert in console:

Plaintext

02/04-11:04:45.783318 \[\*\*\] \[1:1000001:1\] "TEST any IP traffic" \[\*\*\] \[Priority: 0\] {TCP} 10.0.2.15:43764 \-\> 104.18.26.120:80

...

Al termine dell'esecuzione, il riepilogo delle statistiche dovrebbe mostrare:

* **Analyzed**: 20 (o il numero totale di pacchetti nel PCAP).  
* **Allow**: 20 (Snort è in modalità IDS, quindi non blocca il traffico, si limita a segnalare).

### **Problemi comuni**

**1\. "Rules loaded: 0"** Se Snort si avvia ma non genera alcun alert, controlla il percorso del file in `snort.lua`. Puoi fare un debug forzando il caricamento della regola da riga di comando:

Bash

snort \-c snort/snort.lua \-r pcaps/test-http.pcap \-R snort/rules/local.rules \-k none

**2\. Errore "'=' expected near 'ip'"** Questo indica che il file delle regole viene letto come uno script Lua. Assicurati di usare la sintassi `ips = { include = 'percorso' }` e non un `include` globale nel file `snort.lua`.

**3\. Permessi negati** Se Snort non riesce a leggere il file all'interno della cartella condivisa di VirtualBox, verifica i permessi dell'utente o copia temporaneamente il file delle regole nella directory home locale.

