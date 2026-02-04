Snort 3 Offline PCAP Analysis \& First Alerts

This section describes how to perform the first operational test of Snort 3 by analyzing a pre-recorded traffic capture (PCAP) and triggering a custom alert.



This step verifies that the detection engine is working correctly, the rule syntax is valid, and the configuration file is properly pointing to the rule definitions.



Environment and assumptions

Working Directory: /media/sf\_ISNCODES/snort-nids-tutorial



Configuration File: snort/snort.lua



Rule File: snort/rules/local.rules



Traffic Capture: pcaps/test-http.pcap



In this offline analysis mode, Snort reads packets from a file rather than a live network interface. This ensures reproducibility and is standard practice for testing new rules.



1\. Defining the Custom Rule

Snort rules must follow a strict syntax to be parsed correctly. A common mistake is splitting a rule across multiple lines, which causes the parser to fail or ignore the rule.



The Rule Syntax

For this initial test, we use a generic rule that alerts on any IP traffic.



Create or edit the file snort/rules/local.rules and insert the following rule. Ensure it is written on a single line:



Plaintext

alert ip any any -> any any (msg:"TEST any IP traffic"; sid:1000001; rev:1;)

Key rule components:



Header: alert ip any any -> any any (Alert on IP protocol, from any source to any destination).



Body: (msg:"..."; sid:...; rev:...) (Metadata including the message to display and the unique Signature ID).



2\. Configuring snort.lua

To make Snort load this rule file permanently, the main configuration file snort.lua must be modified.



Snort 3 uses Lua for configuration. A frequent error is attempting to include text-based rule files using Lua script commands (which results in errors like '=' expected near 'ip').



Correct Configuration

Open snort/snort.lua.



Locate or create the ips module configuration.



Use the include variable to point to your rule file.



Using an absolute path is recommended to avoid ambiguity when running Snort from different directories.



Lua

ips =

{

&nbsp;   -- Use 'include' to load text-based rule files.

&nbsp;   -- Ensure the path is correct and accessible.

&nbsp;   include = '/media/sf\_ISNCODES/snort-nids-tutorial/snort/rules/local.rules'

}

Note: Do not use the command include 'file.rules' at the global level of snort.lua, as Snort will attempt to execute the rules file as a Lua script and fail.



3\. Running the Analysis

With the configuration and rules in place, Snort is executed against the PCAP file.



Handling Checksums

Captured traffic (PCAP files) often contains packets with incorrect TCP/UDP checksums (due to "checksum offloading" on the capture device). By default, Snort drops these packets silently.



To analyze these files, the -k none flag must be used to disable checksum verification.



Execution Command

Run the following command from the project root:



Bash

snort -c snort/snort.lua -r pcaps/test-http.pcap -k none -A alert\_fast

Command breakdown:



-c snort/snort.lua: Uses the configuration file where we defined the ips block.



-r pcaps/test-http.pcap: Reads the specified PCAP file (Replay mode).



-k none: Forces Snort to ignore bad checksums (Critical for PCAP playback).



-A alert\_fast: Prints alerts to the console in a simple format.



4\. Expected Output and Troubleshooting

If successful, Snort will process the packets and output alerts to the console:



Plaintext

02/04-11:04:45.783318 \[\*\*] \[1:1000001:1] "TEST any IP traffic" \[\*\*] \[Priority: 0] {TCP} 10.0.2.15:43764 -> 104.18.26.120:80

...

At the end of the execution, the statistics summary should show:



Analyzed: 20 (or total number of packets in PCAP)



Allow: 20 (Snort is in IDS mode, so it doesn't block traffic, it only alerts)



Common Issues

1\. "Rules loaded: 0" If Snort runs but generates no alerts, check the file path in snort.lua. You can debug this by forcing the rule load from the command line:



Bash

snort -c snort/snort.lua -r pcaps/test-http.pcap -R snort/rules/local.rules -k none

2\. "'=' expected near 'ip'" This indicates the rule file is being read as a Lua script. Ensure you are using ips = { include = 'path' } and not a global include 'path' in snort.lua.



3\. Permissions If Snort cannot read the file inside a VirtualBox shared folder, verify the user permissions or temporarily copy the rule file to the local home directory.

