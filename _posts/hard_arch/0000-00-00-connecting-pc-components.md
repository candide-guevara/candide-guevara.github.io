---
title: Hardware, How components are connected on a PC
date: 2020-04-12
categories: [cs_related, hardware]
published: false
---

### word soup

* PCIe/PCI/PCI root port
* SCIS/SAS
* SATA/PATA/IDE (sata express?)
* M.2 (key and card dimensions)/U.2
* host controller/HCI
  * x|EHCI, AHCI, NVME
* DMI/PCH (intel) vs southbridge pcie (amd)

### How the f\*ck CPU and mem are connected ?

* via pcie root complex ?
* otherwise how can memory io work ?

### M.2 trap

Specifically, for M.2 SSDs, there are 3 commonly used keys:

B-key edge connector can support SATA and/or PCIe protocol depending on your device but can only support up to PCIe x2 performance (1000MB/s) on the PCIe bus.
M-key edge connector can support SATA and/or PCIe protocol depending on your device and can support up to PCIe x4 performance (2000MB/s) on the PCIe bus, provided that the host system also supports x4.
B+M-key edge connector can support SATA and/or PCIe protocol depending on your device but can only support up to x2 performance on the PCIe bus.

## ACPI (may too much for single article)

* main table names+acronyms
* AML, how to read on linux
* vm for acpi code
* acpi driver https://lwn.net/Articles/367630/

### Links

https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/SATA_Express_interface.svg/564px-SATA_Express_interface.svg.png
https://labs.seagate.com/wp-content/uploads/sites/7/2018/09/an-introduction-to-nvme-tp690-1-1605us.pdf
https://sata-io.org/sites/default/files/documents/NVMe%20and%20AHCI%20as%20SATA%20Express%20Interface%20Options%20-%20Whitepaper_.pdf
