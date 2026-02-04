\# Snort 3 Installation



This section describes the installation of \*\*Snort 3\*\* inside the virtual machine environment used for the Intelligent and Secure Networks course.



The installation is performed on \*\*Ubuntu 24.04 LTS\*\*, running inside a VirtualBox virtual machine provided during laboratory activities.



---



\## Environment and assumptions



\- Host system: Windows

\- Guest system: Ubuntu Server 24.04 LTS (course VM)

\- Hypervisor: Oracle VirtualBox

\- Repository location: VirtualBox shared folder  

&nbsp; (`/media/sf\_ISNCODES/snort-nids-tutorial`)



Although the project repository is stored inside a shared folder, the compilation of Snort and its dependencies is performed in the local home directory (`~/build`) to avoid performance and permission issues typically associated with shared mounts.



---



\## Installation strategy



Snort 3 is installed \*\*from source code\*\* to ensure:



\- full control over enabled features,

\- compatibility with the course environment,

\- reproducibility of the setup.



The installation process includes:



1\. Installation of required build tools and development libraries.

2\. Compilation and installation of \*\*LibDAQ\*\*, the Data Acquisition library used by Snort.

3\. Compilation and installation of \*\*Snort 3\*\*.

4\. Verification of the installation.



All steps are automated through a dedicated script provided in the repository.



---



\## Automated installation script



The installation is performed using the script:



scripts/install-snort3.sh





The script executes the following operations:



\- Cleans and refreshes APT package lists to avoid transient mirror or cache issues.

\- Installs all required dependencies, including:

&nbsp; - compilation toolchain (`gcc`, `make`, `cmake`),

&nbsp; - network libraries (`libpcap-dev`),

&nbsp; - pattern matching libraries (`libpcre2-dev`),

&nbsp; - cryptographic and protocol libraries (`libssl-dev`, `libnghttp2-dev`),

&nbsp; - LuaJIT support for Snort configuration.

\- Builds and installs \*\*LibDAQ\*\* from the official Snort repository.

\- Builds and installs \*\*Snort 3\*\* under `/usr/local`.

\- Performs a final verification of the installation.



The compilation parallelism is limited to a single job to accommodate virtual machines with limited memory (2 GB RAM).



---



\## Running the installation



From the project root directory:



```bash

cd /media/sf\_ISNCODES/snort-nids-tutorial

chmod +x scripts/install-snort3.sh

./scripts/install-snort3.sh



The compilation process may take several minutes depending on the available system resources.



At the end of the installation, the following command is used to verify that Snort has been installed correctly:

snort -V



A successful installation prints the Snort version and build information.



During the setup phase, temporary 404 Not Found errors may occur when fetching packages from Ubuntu mirrors, due to repository synchronization or outdated package lists.



In such cases, the following commands restore a consistent state:



sudo apt clean

sudo rm -rf /var/lib/apt/lists/\*

sudo apt update



After refreshing the package lists, the installation script can be safely executed again.



