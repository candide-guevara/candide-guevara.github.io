---
title: Windows Failover cluster architecture
date: 2016-12-15
categories: [cs_related, architecture, distributed]
---

[Failover cluster][0] is a windows server mechanism to replicate your components for redundancy/high availability.
The system will guarantee that only one component (or "cluster resource") is active at any given time.

Failover cluster are made of several infrastructure services and I like the way the system is architected.
Using the base concept of **resource**, it bootstraps itself by creating infrastructure resources to support your applications.

### Legend
* [1. Cluster service][1]
* [2. Core resources][2]
* [3. Database properties][3]
* [4. Cluster API][3]
* [5. Powershell cmdlets][5]
* [6. Recource failover protocol][6]

![Windows_Failover_Cluster.svg]({{ site.images }}/Windows_Failover_Cluster.svg){:.my-wide-img}
![Windows_Failover_Sequence.svg]({{ site.images }}/Windows_Failover_Sequence.svg){:.my-wide-img}

[0]: https://msdn.microsoft.com/en-us/library/aa372871.aspx
[1]: https://msdn.microsoft.com/en-us/library/aa369163.aspx
[2]: https://msdn.microsoft.com/en-us/library/aa369314.aspx
[3]: https://msdn.microsoft.com/en-us/library/aa372230.aspx
[4]: https://msdn.microsoft.com/en-us/library/aa372859.aspx
[5]: https://technet.microsoft.com/library/hh847239.aspx
[6]: https://msdn.microsoft.com/en-us/library/aa372255.aspx
