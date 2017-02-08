# Bluetooth Low Energy - Core Bluetooth

How to work with BLE support acting both like `central` and `peripheral`. [Core Bluetooth Reference](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/CoreBluetoothBackgroundProcessingForIOSApps/PerformingTasksWhileYourAppIsInTheBackground.html#//apple_ref/doc/uid/TP40013257-CH7-SW5).

## Background vs Foreground

We have two different [modes](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/iPhoneOSKeys.html#//apple_ref/doc/plist/info/UIBackgroundModes) in CB. Which is Background and Foreground. 
    
### Background
* System resources more limited
* More common CB tasks are **disabled while app is in the background or in a suspended state**. But to hack in the background we need to **activate CB background execution modes** in the app. So our app can **wake up from a suspended state** and **listen to alerts by the system when important background events occur**.
* Still, **even if our app has permissions to run on background** using CB, **it won't run forever**. Because the **system may eventually terminate our app in order to free up memory for the current foreground app**. But as of iOS 7, it allows us to save the state of a termination and then we can restore later.

### Foreground
* If the app **goes inactive or to background**, our **bluetooth support goes too**. 
* While in the **suspended state**, your app is **unable to perform Bluetooth-related tasks**, nor is it **aware of any Bluetooth-related events until it resumes to the foreground** and **cannot discover advertising peripherals**.

## Central Device vs Peripheral Device

iOS Core Bluetooth has two background execution modes: `bluetooth-central` and `bluetooth-peripheral`

### Central Role
* The **app communicates with Bluetooth low energy peripherals** using the Core Bluetooth framework.
* So this role allows us to **discover and connect to peripherals, and explore and interact with peripheral data**. And the **system wakes up our app while peripherals change their state, such as connection is established or torn down, when a peripheral sends updated characteristic values, and when a central manager's state changes**.
* The scanning *feature* while in background mode **operates differently** from the foreground one.
    * The `CBCentralManagerScanOptionAllowDuplicatesKey` scan option key is ignored, and multiple discoveries of an advertising peripheral are coalesced into a single discovery event.
    * If all apps that are scanning for peripherals are in the background, **the interval at which your central device scans for advertising packets increases**. As a result, it **may take longer to discover an advertising peripheral**.
    * **These changes help minimize radio usage and improve the battery life on your iOS device**.

### Peripheral Role
* The **app shares data using** the Core Bluetooth framework.
* In this mode, **system wakes up our app to process read, write, and subscription events from the connected central**. Additionally, we are **able to advertise while in the background state**. And this feature also **works differently** from the foreground one.
    * The `CBAdvertisementDataLocalNameKey` advertisement key is ignored, and the local name of peripheral is not advertised.
    * All service UUIDs contained in the value of the `CBAdvertisementDataServiceUUIDsKey` advertisement key are placed in a special “overflow” area; they can be discovered only by an iOS device that is explicitly scanning for them.
    * If all apps that are advertising are in the background, **the frequency at which your peripheral device sends advertising packets may decrease**. Also in **order to improve the battery consumption**.

## Use it wisely

Although declaring your app to support one or both of the Core Bluetooth background execution modes may be necessary to fulfill a particular use case, you should always perform background processing responsibly. Because performing many Bluetooth-related tasks require the active use of an iOS device’s onboard radio—and, in turn, radio usage has an adverse effect on an iOS device’s battery life—try to minimize the amount of work you do in the background. Apps woken up for any Bluetooth-related events should process them and return as quickly as possible so that the app can be suspended again.

Any app that declares support for either of the Core Bluetooth background executions modes must follow a few basic guidelines:

* Apps should be session based and provide an interface that allows the user **to decide when to start and stop the delivery** of Bluetooth-related events.
* Upon being woken up, an app has around **10 seconds** to complete a task.  **Ideally, it should complete the task as fast as possible and allow itself to be suspended again**. Apps that spend too much time executing in the background can be  **throttled back by the system or killed**.
* Apps **should not** use being woken up as an opportunity to perform extraneous tasks that are unrelated to why the app was woken up by the system.

## Background Long-Term Actions

Some apps may need to use the Core Bluetooth framework to perform long-term actions in the background. As an example, imagine you are developing a **home security app for an iOS device that communicates with a door lock (equipped with Bluetooth low energy technology)**. The app and the lock interact to **automatically lock the door when the user leaves home and unlock the door when the user returns—all while the app is in the background**. When the user leaves home, the iOS device may eventually become out of range of the lock, causing the connection to the lock to be lost. **At this point, the app can simply call the [`connectPeripheral:options:`](https://developer.apple.com/reference/corebluetooth/cbcentralmanager/1518766-connect) method of the [`CBCentralManager`](https://developer.apple.com/reference/corebluetooth/cbcentralmanager) class, and because connection requests do not time out, the iOS device will reconnect when the user returns home**.

Now imagine that the user is **away from home for a few days**. If the **app is terminated by the system while the user is away, the app will not be able to reconnect to the lock when the user returns home, and the user may not be able to unlock the door. For apps like these, it is critical to be able to continue using Core Bluetooth to perform long-term actions, such as monitoring active and pending connections**.

### State Preservation and Restoration

Because state preservation and restoration is built in to Core Bluetooth, your app can opt in to this feature to **ask the system to preserve the state of your app’s central and peripheral managers and to continue performing certain Bluetooth-related tasks on their behalf, even when your app is no longer running**. When **one of these tasks completes, the system relaunches your app into the background and gives your app the opportunity to restore its state and to handle the event appropriately**. In the case of the home security app described above, the system would monitor the **connection request, and re-relaunch the app to handle the `centralManager:didConnectPeripheral`: delegate callback when the user returned home and the connection request completed**.

Core Bluetooth supports state preservation and restoration for apps that implement the central **role, peripheral role, or both**. When your app implements the **central** role and adds support for state preservation and restoration, the **system saves the state of your central manager object when the system is about to terminate your app to free up memory (if your app has multiple central managers, you can choose which ones you want the system to keep track of)**. In particular, for a given `CBCentralManager` object, the system keeps track of:

* The services the central manager was scanning for (and any scan options specified when the scan started)
* The peripherals the central manager was trying to connect to or had already connected to
* The characteristics the central manager was subscribed to

Apps that implement the **peripheral** role can likewise take advantage of state preservation and restoration. For `CBPeripheralManager` objects, the system keeps track of:

* The data the peripheral manager was advertising
* The services and characteristics the peripheral manager published to the device’s database
* The centrals that were subscribed to your characteristics’ values

When your app is relaunched into the background by the system (because a peripheral your app was scanning for is discovered, for instance), you can **reinstantiate your app’s central and peripheral managers and restore their state**. The following section describes in detail how to take advantage of state preservation and restoration in your app.

### Adding Support for State Preservation and Restoration

State preservation and restoration in Core Bluetooth is an opt-in feature and requires help from your app to work. You can add support for this feature in your app by following this process:

* (Required) Opt in to state preservation and restoration when you allocate and initialize a central or peripheral manager object. This step is described in Opt In to State Preservation and Restoration.
* (Required) Reinstantiate any central or peripheral manager objects after your app is relaunched by the system. This step is described in .
* (Required) Implement the appropriate restoration delegate method. This step is described in .
* (Optional) Update your central and peripheral managers’ initialization process. This step is described in .


### Opt In to State Preservation and Restoration

To opt in to the state preservation and restoration feature, simply **provide a unique restoration identifier when you allocate and initialize a central or peripheral manager**. A restoration identifier is a string that identifies the central or peripheral manager to Core Bluetooth and to your app. The value of the string is significant only to your code, but the presence of this string tells Core Bluetooth that it needs to preserve the state of the tagged object. Core Bluetooth **preserves the state of only those objects that have a restoration identifier**.

For example, to opt in to state preservation and restoration in an app that uses **only one instance of a `CBCentralManager` object to implement the central role, specify the `CBCentralManagerOptionRestoreIdentifierKey` initialization option and provide a restoration identifier for the central manager when you allocate and initialize it**.

    myCentralManager =
        [[CBCentralManager alloc] initWithDelegate:self queue:nil
         options:@{ CBCentralManagerOptionRestoreIdentifierKey:
         @"myCentralManagerIdentifier" }];
         
Although the above example does not demonstrate this, you opt in to **state preservation and restoration in an app that uses peripheral manager objects in an analogous way**: Specify the `CBPeripheralManagerOptionRestoreIdentifierKey` initialization option, and provide a restoration identifier when you allocate and initialize each peripheral manager object.

Note: Because **apps can have multiple instances** of CBCentralManager and CBPeripheralManager objects, **be sure each restoration identifier is unique**, so that the system can properly **distinguish one central (or peripheral) manager object from another**.

### Reinstantiate Your Central and Peripheral Managers

When your app is relaunched into the background by the system, the **first thing you need to do is reinstantiate the appropriate central and peripheral managers with the same restoration identifiers as they had when they were first created**. If your app **uses only one central or peripheral manager, and that manager exists for the lifetime of your app, there is nothing more you need to do for this step**.

If your app **uses more than one central or peripheral manager or if it uses a manager that isn’t around for the lifetime of your app, your app needs to know which managers to reinstantiate when it is relaunched by the system**. You can **access a list of all the restoration identifiers for the manager objects the system was preserving for your app when it was terminated, by using the appropriate launch option keys `(UIApplicationLaunchOptionsBluetoothCentralsKey` or `UIApplicationLaunchOptionsBluetoothPeripheralsKey)` when implementing your app delegate’s `application:didFinishLaunchingWithOptions:` method**.

For example, when your app is **relaunched by system, you can retrieve all the restoration identifiers for the central manager objects the system was preserving for your app**                     , like this:

    - (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
        NSArray *centralManagerIdentifiers =
            launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey];
        ...
        
After you have the list of **restoration identifiers, simply loop through it and reinstantiate the appropriate central manager objects**.

Note: When your app is **relaunched, the system provides restoration identifiers only for central and peripheral managers for which it was performing some Bluetooth-related task (while the app was no longer running)**. These launch option keys are described in more detail in [`UIApplicationDelegate Protocol Reference`](https://developer.apple.com/reference/uikit/uiapplicationdelegate).

### Implement the Appropriate Restoration Delegate Method

After you have reinstantiated the appropriate central and peripheral managers in your app, **restore them by synchronizing their state with the state of the Bluetooth system**. To bring your app up to **speed with what the system has been doing on its behalf (while it was not running), you must implement the appropriate restoration delegate method**. For **central managers, implement the `centralManager:willRestoreState:` delegate method; for peripheral managers, implement the `peripheralManager:willRestoreState:` delegate method**.

In **both of the above delegate methods, the last parameter is a dictionary that contains information about the managers that were preserved at the time the app was terminated**. For a list of the **available dictionary keys, see the Central Manager State Restoration Options constants in CBCentralManagerDelegate Protocol Reference and the Peripheral_Manager_State_Restoration_Options constants in CBPeripheralManagerDelegate Protocol Reference**.

To restore the state of a **CBCentralManager object, use the keys to the dictionary that is provided in the `centralManager:willRestoreState:` delegate method**. As an example, if your **central manager object had any active or pending connections at the time your app was terminated, the system continued to monitor them on your app’s behalf**. As the following shows, you **can use the `CBCentralManagerRestoredStatePeripheralsKey` dictionary key to get of a list of all the peripherals (represented by CBPeripheral objects) the central manager was connected to or was trying to connect to**:

    - (void)centralManager:(CBCentralManager *)central
          willRestoreState:(NSDictionary *)state {
     
        NSArray *peripherals =
            state[CBCentralManagerRestoredStatePeripheralsKey];
        ...
        
What you do with the list of restored peripherals in the above example depends on the use case. For **instance, if your app keeps a list of the peripherals the central manager discovers, you may want to add the restored peripherals to that list to keep references to them**. As described in [Connecting to a Peripheral Device After You’ve Discovered It](), **be sure to set a peripheral’s delegate to ensure that it receives the appropriate callbacks**.

You can restore the state of a `CBPeripheralManager` object in a similar way by using the keys to the dictionary that is provided in the `peripheralManager:willRestoreState:` delegate method.

### Update Your Initialization Process

After you have implemented the previous three required steps, you **may want to take a look at updating your central and peripheral managers’ initialization process**. Although this is an **optional** step, it can be **important** in ensuring that things run **smoothly** in your app. As an example, your **app may have been terminated while it was in the middle of exploring the data of a connected peripheral. When your app is restored with this peripheral, it won’t know how far it made it the discovery process at the time it was terminated. You’ll want to make sure you’re starting from where you left off in the discovery process**.

For example, when initializing your app in the `centralManagerDidUpdateState:` delegate method, you can find out if you successfully discovered a particular service of a restored peripheral (before your app was terminated), like this:

    NSUInteger serviceUUIDIndex =
        [peripheral.services indexOfObjectPassingTest:^BOOL(CBService *obj,
        NSUInteger index, BOOL *stop) {
            return [obj.UUID isEqual:myServiceUUIDString];
        }];
 
    if (serviceUUIDIndex == NSNotFound) {
        [peripheral discoverServices:@[myServiceUUIDString]];
        ...

As the above example shows, if the **system terminated your app before it finished discovering the service, begin the exploring the restored peripheral’s data at that point by calling the `discoverServices:`**. If your app discovered the service successfully, you can then check to see whether the appropriate characteristics were discovered (and whether you already subscribed to them). By updating your initialization process in this manner, you’ll ensure that you’re calling the right methods at the right time.

## License

    The MIT License (MIT)

	Copyright (c) 2017 Leonardo Cardoso
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.