# **05 – Live Traffic Monitoring (Snort 3 as NIDS)**

## **Chapter Objective**

In this chapter, we transition from offline analysis (PCAP) to live mode, meaning Snort listens in real-time on a network interface and generates alerts as traffic actually flows.  
The goal is twofold:

1. Understand what we are doing and why (architectural choices / topology / sensor placement);  
2. Achieve a reproducible setup where we:  
   * generate controlled traffic (ICMP, TCP, HTTP),  
   * write realistic rules (especially HTTP),  
   * verify alerts and learn how to read them.

Note: We maintain Snort in NIDS (passive) mode. We do not block traffic: we observe and alert.

---

## **1\) Network Topology: How we envision it and why**

**When discussing NIDS, the fundamental question is: where does Snort "see" the packets? A NIDS works effectively only if placed at a point where it observes relevant traffic.**

### **Topology A – Minimal Lab (1 machine)**

Scenario: Snort runs on the same machine from which you generate traffic (or where traffic arrives).

* Pros: Very easy to start, zero infrastructure.  
* Cons: You only see what passes through that host and that NIC (and often miss "internal" traffic between other hosts).

It is useful for:

* learning commands,  
* testing rules,  
* verifying logging and alerts.

### **Topology B – Classic Lab (2 VMs \+ “LAN”)**

Scenario: Two VMs (Attacker and Victim) in the same virtual network; Snort resides:

* either on the Victim (host-based sniffing on NIC),  
* or on a third "Sensor" VM that sees the traffic (depends on the hypervisor's network mode).  
* Pros: More realistic, allows simulation of attacks (scans, HTTP, etc.).  
* Cons: To truly see inter-VM traffic, proper virtual switch configuration / promiscuous mode / port mirroring is often required.

### **Topology C – Realistic (Snort on a central observation point)**

Scenario: Snort is a dedicated sensor placed on:

* a SPAN/mirror port of a switch,  
* a network TAP,  
* a bridge/segment where "traffic of interest" flows.

Reason: A NIDS is useful when it observes the traffic you want to monitor:

* inbound/outbound Internet traffic (perimeter),  
* traffic between segments (e.g., user VLAN ↔ server VLAN),  
* traffic towards critical resources.

Rule of thumb:

* if you want to detect attacks against servers: place the sensor near the servers or on the link reaching them.  
* if you want general visibility: place the sensor at a transit point (uplink, trunk, mirror).

In our tutorial, we will use a "lab" topology (A or B) because it is reproducible. However, we already think as if in C: we choose the interface where interesting traffic flows.

---

## **2\) Identifying the Right Network Interface (The "Listening Point")**

On Linux, we first identify the NICs and addresses.

### **2.1 List Interfaces and IPs**

Bash  
ip \-br a

**Typical example:**

* `eth0` / `ens33` → main interface (LAN)  
* `lo` → loopback (not interesting for real network traffic)

### **2.2 Why the interface matters**

If Snort listens on a NIC where the traffic you are generating does not flow, you will not see any alerts. To verify that there is traffic on that NIC, use tcpdump as a "sanity check":

Bash  
sudo tcpdump \-i \<IFACE\> \-n

If you don't see packets while browsing/pinging/scanning, you have likely chosen the wrong interface (or you are generating traffic on a different network).

## **3\) Preparing output files (alerts) and the working directory**

In this tutorial, we use a simple output: `alert_fast.txt` (text-based). We choose a dedicated directory, for example:

Bash  
sudo mkdir \-p /var/log/snort  
sudo touch /var/log/snort/alert\_fast.txt  
sudo chmod 666 /var/log/snort/alert\_fast.txt

In a "clean" context, you would use more restrictive permissions. We do this here for laboratory convenience.

## **4\) Fundamental settings: HOME\_NET and EXTERNAL\_NET (why they are needed)**

Many rules reason in terms of:

* **HOME\_NET** \= the network I protect/monitor as "internal"  
* **EXTERNAL\_NET** \= everything else

**Why is it important?**

If you get `HOME_NET` wrong, rules might not match (or match too much). It is fundamental for rules of the type "from external towards internal".

### **4.1 How to decide HOME\_NET in the lab**

Take the IP of the "monitored" machine (or the lab network):

Bash  
ip \-br a

If, for example, the NIC has `192.168.56.10/24`, then a sensible `HOME_NET` is:

* `192.168.56.0/24` (if you want to monitor the whole network)  
  * or  
* `192.168.56.10/32` (if you want to monitor only that host)

In the lab, we often set the `/24` subnet for simplicity.

**Where is it set?**

It depends on your `snort.lua`. In many setups, Snort 3 uses network variables in a section like: `HOME_NET` / `EXTERNAL_NET` (or equivalent in `variables` / `ips.variables`). If your `snort.lua` already has these variables, update them consistently with your IP/subnet.

## **5\) Local rules: local.rules (source of truth for tests)**

In the tutorial, we will use a local rules file (already used in the previous debugging):

`snort/rules/local.rules` (or a similar path)

Verify that it exists:

Bash  
ls \-l /absolute/path/to/snort/rules/local.rules

And that the inclusion in `snort.lua` is absolute (as you have already resolved):

Lua  
ips \=  
{  
  include \= '/absolute/path/to/snort/rules/local.rules'  
}

## **6\) Starting Snort in live mode (NIDS)**

### **6.1 Base command (concept)**

In live mode, we tell Snort:

1. which interface to listen to,  
2. which configuration to use,  
3. where to write alerts/logs.

A typical startup (adapt paths to your system) is:

Bash  
sudo snort \-c /absolute/path/to/snort.lua \-i \<IFACE\> \-A alert\_fast \-l /var/log/snort

**Parameter explanation:**

* `-c ...` : configuration file (`snort.lua`)  
* `-i <IFACE>` : interface to monitor (e.g., `eth0`, `ens33`)  
* `-A alert_fast` : alert output in "fast" format (simple)  
* `-l /var/log/snort` : log directory

If your configuration already handles output/logging internally, some flags might be redundant. In the lab, we prefer to make it explicit.

### **6.2 "Sanity" verification**

After startup:

* Snort must remain running (it must not exit immediately).  
* Alerts should appear in the `/var/log/snort/alert_fast.txt` file when we generate traffic that matches a rule.

## **7\) Generating controlled traffic (why we do it this way)**

In a serious laboratory, we do not "hope" that interesting traffic passes by: we create it.

This serves to:

* validate that Snort is listening on the right interface,  
* test rules one by one,  
* understand exactly why a rule matches.

### **7.1 Test 1: ICMP (ping)**

From a host towards the monitored host:

Bash  
ping \-c 3 \<IP\_TARGET\>

If you want a simple rule for ping, add to `local.rules`:

Plaintext  
alert icmp any any \-\> $HOME\_NET any (msg:"\[LAB\] ICMP ping towards HOME\_NET"; sid:1000001; rev:1;)

**What we are doing:**

* `alert icmp` : on ICMP traffic  
* `any any -> $HOME_NET any` : from any source towards HOME\_NET  
* `msg` : message in the alert  
* `sid` : unique ID (use your own range, e.g., 1000000+)  
* `rev` : rule revision

Then restart Snort and repeat the ping.

### **7.2 Test 2: "Simple" TCP on port (SYN towards a port)**

You can use `nc` (netcat) or `nmap`. Example with nmap (light scan, single port):

Bash  
nmap \-p 80 \<IP\_TARGET\>

Rule "port 80 towards HOME\_NET":

Plaintext  
alert tcp any any \-\> $HOME\_NET 80 (msg:"\[LAB\] TCP towards port 80 on HOME\_NET"; flags:S; sid:1000002; rev:1;)

**Why `flags:S`?**

We focus on the SYN (handshake start), useful for detecting scans and connection attempts.

## **8\) Key part: HTTP Traffic and realistic rules**

To perform HTTP in a controlled way, we need:

1. a "simple" HTTP server on the target host  
2. a client making HTTP requests

### **8.1 Starting a test HTTP server (on the Victim/Target)**

On the target:

Bash  
python3 \-m http.server 8000

Now the target exposes HTTP on port 8000\.

### **8.2 Generating HTTP requests (from the client/attacker or the same machine)**

From the client:

Bash  
curl \-v http://\<IP\_TARGET\>:8000/

Now we can write rules that intercept HTTP patterns.

## **9\) HTTP Rules: gradual examples with explanation**

**Attention:** in Snort 3, "HTTP" semantics use dedicated inspectors and keywords. In the lab, we start with simple rules and then make them more specific.

### **9.1 "Raw" rule based on payload (simple start)**

Plaintext  
alert tcp any any \-\> $HOME\_NET 8000 (msg:"\[LAB\] HTTP: GET request towards test server"; content:"GET"; nocase; sid:1000100; rev:1;)

**What it does:**

Matches TCP traffic towards port 8000 containing the string "GET" (case-insensitive).

**Why it is useful:**

It is a quick test to see if we are seeing the application payload.

**Limit:**

It is not very robust (could match false positives in other contexts).

### **9.2 Rule on User-Agent (more realistic)**

With curl, `User-Agent: curl/...` often appears.

Plaintext  
alert tcp any any \-\> $HOME\_NET 8000 (  
  msg:"\[LAB\] HTTP: User-Agent curl towards test server";  
  content:"User-Agent|3A|"; nocase;  
  content:"curl"; nocase; distance:0;  
  sid:1000101; rev:1;  
)

**What we are doing:**

* `content:"User-Agent|3A|"` looks for User-Agent: (`|3A|` is `:` in hex)  
* then we look for `curl` immediately after (with `distance:0` for "proximity")

**Why it is useful:**

It is a rule closer to a real case (client fingerprinting).

### **9.3 Rule on URL/suspicious pattern (attack example)**

Let's simulate a suspicious path:

Bash  
curl \-v "http://\<IP\_TARGET\>:8000/admin"

Rule:

Plaintext  
alert tcp any any \-\> $HOME\_NET 8000 (  
  msg:"\[LAB\] HTTP: access to /admin (sensitive path)";  
  content:"GET"; nocase;  
  content:"/admin"; nocase; distance:0;  
  sid:1000102; rev:1;  
)

**Why it makes sense:**

Many systems monitor access to sensitive paths (admin panel, login, backup).

## **10\) Reading and interpreting alerts (not just "seeing" them)**

Open the file:

Bash  
tail \-f /var/log/snort/alert\_fast.txt

**What you must check when an alert appears:**

1. timestamp (when it happened)  
2. message `msg` (what we detected)  
3. IP addresses and ports (who → who)  
4. protocol (icmp/tcp)  
5. if it is consistent with the test you were doing

**If an alert does not appear, the typical checklist is:**

* Is Snort listening on the right interface? (`-i <IFACE>`)  
* Does traffic really pass on that interface? (verify with `tcpdump`)  
* Is the rule actually included? (absolute include in `snort.lua`)  
* Is `HOME_NET` consistent with the destination IP?  
* Are the port and direction of the rule correct?  
* Does the traffic really contain that content? (`curl -v`, or `pcap`/`tcpdump`)

## **11\) Why we place Snort "there" (connection to the real world)**

In the lab, "there" means: on the interface where traffic passes between client and server. In the real world, the same logic becomes:

* I want to see attacks towards servers → sensor on the server segment or on a mirror of the link towards servers  
* I want to see Internet ↔ internal network traffic → sensor on the perimeter (uplink mirror)  
* I want to see lateral movement → sensor between VLANs / internal segments

**The key concept is:**

A NIDS does not "discover magic": it only detects what it manages to observe.

## **12\) Chapter output and next step**

At this point, you should have:

* Snort in live mode on a real NIC  
* Local rules tested with ICMP, TCP, HTTP  
* Alerts generated and interpreted with awareness

