---
title: Windows, First impressions on win development
date: 2016-11-27
categories: [cs_related]
---

I have been developing windows small services and wcf servers in C# for a year.
Here are some of the high and low points for me :

## Great

* The isolation and ease of use of application domains
{% highlight c# %}
  public void RunInsideNewAppDomain(string domainConfig, string domainAssembly, string domainType) {
      AppDomainSetup newDomSetup = new AppDomainSetup();
      newDomSetup.ApplicationBase = // ...
      newDomSetup.ConfigurationFile = domainConfig;
      // Enables assemblies that are used in the app domain to be updated without unloading the app domain
      newDomSetup.ShadowCopyFiles = "true";

      var newDomain = AppDomain.CreateDomain("AppDomainName");
      // Creates a real instance in the new app domain and returns a proxy that forwards calls to the real object
      // Make sure domainType extends MarshalByRefObject
      var proxy = (SomeIf)newDomain.CreateInstanceAndUnwrap(domainAssembly, domainType);

      proxy.DoSomething();
      AppDomain.Unload(newDomain);
  }
{% endhighlight %}
* Fakes framework will make even oldest code unit testable
{% highlight c# %}
  public void TestRoutineUsingFilesystem() {
      // Method override will take place inside this scope only
      using (ShimsContext.Create()) {
          // Mock static method calls in 3rd party assemblies
          ShimFile.CopyStringString = (src, dest) => { ... }
      }
  }
{% endhighlight %}
* [WMI api][0] a valid replacement for ssh and text files in most scenarios and you can **transparently** access remote machines
{% highlight powershell %}
  # Backtick as new line escape : why ?
  Get-EventLog                                            `
    -ComputerName "hostname"                              `
    -logname "Application"                                `
    -after  (Get-Date).AddHours(-1)                       `
    -before (Get-Date)                                    `
    -entrytype "Error,Warning"                            `
    | format-list EntryType,Source,TimeGenerated,Message
{% endhighlight %}
* Visual studio integration with sqlserver
  * Update your test database schema directly from visual studio
  * Unit test databases thanks to [localdb][6]
  * Very powerful scripting capabilities through [SMO][5]
{% highlight c# %}
  public void CreateSqlSchemaScriptForNewTables () {
      var dbhost = new Server("machine");
      var db = dbhost.Databases["db_name"];

      var resultScripts = new List<StringCollection>();
      var options = new ScriptingOptions();

      options.WithDependencies = false;
      options.ScriptData = false;
      options.IncludeIfNotExists = true;

      foreach (Table tb in db.Tables) {
          if (tb.DateLastModified >= Datetime.Now.AddDays(-1))
              resultScripts.Add( tb.Script(options);
      }
  }
{% endhighlight %}

## Good

* Powershell approach of using objects instead of text. It is quite verbose and I still prefer bash but it shines for filtering output
{% highlight powershell %}
    # Roughly the equivalent of "find -mtime '-1'"
    $date = (Get-Date).AddHours(-24);

    # get-childitem return objects so we can use predicates on them
    get-childitem -Recurse -Force                                          `
    | where {($_.CreationDate -gt $date) -or ($_.LastWriteTime -gt $date)} `
    | select {$_.FullName};
{% endhighlight %}
* You can use .NET framework classes from powershell
  * Useful to get access to advanced functions from a script
  * No need to open a heavy IDE and wait for compilation
{% highlight powershell %}
    # We can use the .NET reflection API to get assembly metadata
    [reflection.assemblyname]::GetAssemblyName("stuff.dll")                 `
        | format-list FullName, ProcessorArchitecture, CodeBase
    [reflection.assembly]::LoadFrom("stuff.dll")                            `
        | format-list EntryPoint, GlobalAssemblyCache, ImageRuntimeVersion
    [diagnostics.FileVersionInfo]::GetVersionInfo("stuff.dll")              `
        | format-list CompanyName, FileVersion, ProductVersion, Language
{% endhighlight %}

## Bad

* [Nuget][3] packaging tool is buggy and not well thought for automation (like jenkins jobs)
* Visual studio verbose project configuration, worst to what you get using ant
* The .net configuration extension mechanism could be made simpler (by using a less imperative style)
{% highlight c# %}
  public class DessertConfigSection : ConfigurationSection {
      [ConfigurationProperty("desserts")]
      public DessertList DessertDefinitions
      {
          get { return (DessertList)this["desserts"];  }
          set { this["desserts"] = value; }
      }
  }

  public class DessertList : ConfigurationElementCollection {
      protected DessertList() {
          AddElementName = "add_dessert";
      }
      protected override ConfigurationElement CreateNewElement() {
          return new DessertDefinition();
      }
      protected override object GetElementKey(ConfigurationElement element) {
          return ((DessertDefinition) element).Name;
      }
  }

  public class DessertDefinition : ConfigurationElement {
      [ConfigurationProperty("name")]
      public String Name {
          get { return (String)this["name"]; }
          set { this["name"] = value; }
      }
      [ConfigurationProperty("taste")]
      public String Taste {
          get { return (DateTime)this["taste"]; }
          set { this["taste"] = value; }
      }
  }
{% endhighlight %}
{% highlight xml %}
  <configuration>
    <configSections>
      <section name="sweets" type="DessertConfigSection"/>
    </configSections>

    <sweets>
        <desserts>
          <add_dessert name="BananaSplit"   taste="yummy"/>
          <add_dessert name="BananaFlambee" taste="oh yeah"/>
       </desserts>
    </sweets>
  </configuration>
{% endhighlight %}

## Awful

* No decent text editor out of the box
* File explorer is unsable for powerusers (no tabs, crappy history ...)
* MSDN site is slow and unintuitive (and they keep asking "Is this page helpful?") 
  * Why can't I just change the url to land in the .NET version I want ?
* Visual studio does not follow the filesystem structure
* Versioning, why is sqlserver 2014 version 12.0 ?
* The "use the GUI" approach of some sysadmins

### What's the deal with logs ?!

* In windows **nothing is a file** if you need a ton of different apps to do simple things like:
  * Read/Search the system logs (stored with a cryptic etl format)
  * Read [HPC][1] scheduler and agent logs
* You have to [declare a log source][4] before you can emit records on the system logs (face palm)
* The enterprise library is bad, but the logging is terrible. And the documentation [treats you like a retard][2]

## That which shall not be named

Let's just say that you better not hope to get a **terminal emulator** equivalent (at least before windows server 2016)

[0]: https://msdn.microsoft.com/en-us/library/aa394585(v=vs.85).aspx
[1]: https://technet.microsoft.com/en-us/library/jj899572(v=ws.11).aspx
[2]: https://msdn.microsoft.com/en-us/library/dn440731(v=pandp.60).aspx
[3]: http://docs.nuget.org/
[4]: https://msdn.microsoft.com/en-us/library/2awhba7a(v=vs.110).aspx#Examples
[5]: https://msdn.microsoft.com/en-us//library/ms162169.aspx
[6]: https://msdn.microsoft.com/en-us/library/hh510202.aspx#Description

