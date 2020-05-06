---
title: C#, API for writing services (aka daemons)
date: 2016-11-27
categories: [cs_related]
---

Boiler plate code for windows services is certainly not difficult. 
However visual studio makes it confusing with all its fancy graphical component editors ...

```c#
[RunInstaller(true)]
public class ServiceInstaller : System.Configuration.Install.Installer
{
    // Sets the registry values associated to the **executable** containing the services
    private ServiceProcessInstaller svcProcessInstaller;
    // Sets the registry values associated to the class containing the service logic
    private ServiceInstaller svcClassInstaller;
    private EventLogInstaller etwConsumerSrc;

    public ServiceInstaller()
    {
        svcProcessInstaller = new ServiceProcessInstaller();
        svcClassInstaller = new ServiceInstaller();

        svcProcessInstaller.Password = null;
        svcProcessInstaller.Username = null;
        // You can hook up to events (BeforeInstall, AfterInstall ...) to do some custom action
        svcProcessInstaller.AfterInstall += new InstallEventHandler(serviceProcessInstaller_AfterInstall);

        // It is crucial that the ServiceName be identical to the ServiceBase.ServiceName
        svcClassInstaller.ServiceName = nameof(ASimpleService);
        svcClassInstaller.Description = "This is a simple service ...";
        svcClassInstaller.StartType = ServiceStartMode.Manual;
        svcClassInstaller.ServicesDependedOn = new string[] { "BananaService" };

        // Add event log category in the logs
        etwConsumerSrc = new EventLogInstaller();
        etwConsumerSrc.Source = nameof(ASimpleService);
        etwConsumerSrc.Log = "Application";

        Installers.AddRange(new Installer[] {
            svcProcessInstaller,
            svcClassInstaller,
            etwConsumerSrc,
        });
    }

    private void serviceProcessInstaller_AfterInstall(object sender, InstallEventArgs e) { }
}

// The service skeleton
public class ASimpleService : ServiceBase
{
    public ASimpleService () 
    {
        ServiceName = nameof(ASimpleService);
        // Indicates whether to report Start, Stop, Pause, and Continue commands in the event log
        AutoLog = true;
        CanStop = true;
        CanPauseAndContinue = false;
    }

    // This method should return, if you need a long running service spawn a new thread
    protected override void OnStart(string[] args) 
    { 
        // the event log source is ServiceName, and the log name is the computer's "Application" log
        EventLog.Write("some interesting message");
    }

    // Clean the resources allocated in OnStart
    protected override void OnStop() { }
}

// Finally the main routine just creates the service and delegates running it to ServiceBase
public static class Program 
{
    public static void Main()
    {
        var service = new ASimpleService();
        ServiceBase.Run(service);
    }
}
```


Some explanations on the code.

* The `RunInstaller` attribute is used by the [installutil][2] tool to locate the installer in the assembly
* You need [`EventLogInstaller`][3] otherwise you may not be able to write to the event log. Indeed you need to declare the source you will use before, silly I know ...
* Installer are arranged in a tree structure. Notice how [`Installers.AddRange`][4] declares its child installers

That's it, you do not get all of the useless boiler plate visual studio generates for you.

* Class member of type `ComponentModel.IContainer` used for GUI programming and for the **crappy** drag-and-drop code editor
* No partial classes without reason

## Getting fancy : auto-installer

With some extra code you can even have the daemon binary auto install itself on demand (for example when called with certain command line arguments).
First use `AssemblyInstaller` to call your isntaller class.

```c#
private static void launchServicesInstaller(params string[] args)
{
    var toInstall = typeof(Program).Assembly;
    IDictionary state = new Hashtable();
    var nativeOpts = new List<string>(/* add any relevant command line args */);
    // you can use some options from https://docs.microsoft.com/en-us/dotnet/framework/tools/installutil-exe-installer-tool
    // depending on your installer hierarchy tree, other options may be available, look at `Installer.HelpText` property.
    nativeOpts.Add(@"/LogToConsole=true");
    nativeOpts.Add(@"/ShowCallStack");

    using (var installer = new AssemblyInstaller(toInstall, nativeOpts.ToArray()))
    {
        installer.UseNewContext = true;
        try
        {
            if (opts.Uninstall)
                installer.Uninstall(state);
            else
            {
                installer.Install(state);
                installer.Commit(state);
            }
        }
        catch
        {
            try { installer.Rollback(state); }
            catch { }
            throw;
        }
    }
}
```

You may also override the `Install` and `Uninstall` methods to add custom logging.

```c#
//Inside : class <Your_Installer> : System.Configuration.Install.Installer
public override void Install(IDictionary mySavedState) {
    try {
        Context.LogMessage("Launching custom install");
        base.Install(mySavedState);
    }
    catch (Exception err) {
        Context.LogMessage("Failed custom install : " + err);
        throw;
    }
}

public override void Uninstall(IDictionary mySavedState) {
    // ...
    base.Uninstall(mySavedState);
}
```

## Conclusion

I wish that for [workflows][0], and [ssis packages][1] microsoft realized the most efficient way to build your application is typing code.
Not waiting for a bloated graphical editor to load ...

(face palm)

[0]: https://msdn.microsoft.com/en-us/library/dd489441(v=vs.110).aspx
[1]: https://msdn.microsoft.com/en-us/library/ms141134.aspx
[2]: https://msdn.microsoft.com/en-us/library/50614e95(v=vs.110).aspx
[3]: https://msdn.microsoft.com/en-us/library/system.diagnostics.eventloginstaller(v=vs.110).aspx
[4]: https://msdn.microsoft.com/en-us/library/system.configuration.install.installer(v=vs.110).aspx#Remarks

