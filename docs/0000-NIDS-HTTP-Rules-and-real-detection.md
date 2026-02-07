# **06 \- NIDS HTTP Rules and Real Detection**

## **Goal of this Section**

In this section we move from **basic string matching** to **real HTTP-aware detection** using Snort 3\.

The objective is to:

* understand how the **HTTP inspector** works in Snort 3,  
* write **correct and robust NIDS rules** for HTTP traffic,  
* generate realistic traffic from a separate VM,  
* understand *why* HTTP-aware rules are superior to generic payload matching.

This is the first section where Snort performs **true semantic detection**, not just pattern matching.

---

## **Why HTTP Detection Is Different**

In previous sections we used rules like:

Snippet di codice

content:"GET";

While useful for learning, this approach has major limitations:

* it searches for the string `GET` **anywhere in the TCP payload**,

* it can generate false positives,

* it is easier to evade.

Snort 3 includes protocol inspectors that **understand application-layer semantics**.  
 For HTTP traffic, this means Snort can identify:

* HTTP methods,

* headers,

* URIs,

* User-Agent values,

* request and response structure.

This allows **precise, protocol-aware detection**.

---

## **HTTP Inspector in Snort 3**

When the HTTP inspector is enabled:

* Snort parses HTTP requests and responses,

* protocol fields are extracted and normalized,

* rules can match on *meaning*, not just raw bytes.

This is essential for NIDS usage:

* fewer false positives,

* better resistance to evasion,

* clearer alerts.

---

## **Lab Topology for HTTP Detection**

To make detection realistic, traffic is generated from **a separate virtual machine**.

### **Virtual Machines**

* **Snort VM (Sensor / Victim)**

  * Snort 3 running in live NIDS mode

  * HTTP test server listening on port 8000

  * Network interface monitored by Snort

* **Client VM (Traffic Generator)**

  * Same base OS image

  * No Snort installed

  * Generates HTTP and TCP traffic toward the Snort VM

Both VMs are connected to the same virtual network subnet.

---

## **Starting the HTTP Test Server**

On the Snort VM:

`python3 -m http.server 8000`

This provides a simple and controllable HTTP service.

---

## **Generating HTTP Traffic from the Client VM**

From the Client VM, use the IP address of the Snort VM.

### **Basic HTTP GET**

`curl http://<SNORT_VM_IP>:8000/`

---

## **Correct HTTP NIDS Rule: Method Detection**

### **Example Rule**

`alert http any any -> any any (`  
  `msg:"[NIDS] HTTP GET request detected";`  
  `http_method;`  
  `content:"GET";`  
  `sid:1000003;`  
  `rev:1;`  
`)`

### **Why This Rule Is Better**

This rule is superior to a generic `content:"GET"` rule because:

* `alert http` ensures the rule is applied **only to HTTP traffic**,

* `http_method` restricts matching to the HTTP method field,

* the rule matches **semantic HTTP structure**, not raw payload,

* false positives are significantly reduced.

In other words, this rule detects **actual HTTP GET requests**, not arbitrary data containing the string “GET”.

---

## **Detecting Suspicious HTTP Paths**

From the Client VM:

`curl http://<SNORT_VM_IP>:8000/admin`

### **Rule Example**

`alert http any any -> any any (`  
  `msg:"[NIDS] Suspicious HTTP access to /admin";`  
  `http_uri;`  
  `content:"/admin";`  
  `nocase;`  
  `sid:1000004;`  
  `rev:1;`  
`)`

This rule detects access to a sensitive path, a common behavior during reconnaissance.

---

## 

## **Detecting Anomalous User-Agents**

From the Client VM:

`curl -A "evil-scanner/1.0" http://<SNORT_VM_IP>:8000/`

### **Rule Example**

`alert http any any -> any any (`  
  `msg:"[NIDS] Anomalous HTTP User-Agent detected";`  
  `http_user_agent;`  
  `content:"evil";`  
  `nocase;`  
  `sid:1000005;`  
  `rev:1;`  
`)`

User-Agent analysis is frequently used to detect:

* scanners,

* custom scripts,

* non-browser clients.

---

## **Simple Scan Detection (Preparation)**

From the Client VM:

`nmap -p 8000 <SNORT_VM_IP>`

At this stage we only observe the alert behavior.  
 More advanced scan detection will be handled in the next section.

---

## **Why This Matters for a NIDS**

At this point Snort is:

* passively observing traffic,

* understanding HTTP semantics,

* detecting reconnaissance behaviors,

* producing meaningful alerts.

This is **true NIDS behavior**:

* no blocking,

* no interference,

* accurate visibility into network activity.

