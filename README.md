# bazel-ios-app
bazel-ios-app is a simple example of iOS application with bazel build system.
This example describes belwos:
    - Compiling iOS bazel application for simulator and a device
    - deploying the compile application to a device
    - deployting and debugging the application on a device
  
## WORKSPACE
`WORKSPACE` describes a project's name and rules. 
This project used the rules of `https://github.com/bazelbuild/rules_apple.git`.
Therefore, `WORKSPACE` should contains `git_repository` for `0.2.0` tag for the github rules.

## BUILD
`BUILD` should be made in `ios` application directory.
The important one is that provisioning_profile is required only for deploying the application into a device.
In other words, it can be eliminated if you compile the application only for a simulator.

## Compiling for a simulator
`Makefile` describes rules for building applications for a simulator or a device.
In order to build it for a simulator, `debug.build` rule can be used.

### Installing into Simulator
For installing it into a simulator and then running the simulator, use `make simulator`.
This rule will install the application and then boot and open a simulator app.
To specify the name of the simulator, you can run as below:

``` shell
make simulator SIMULATOR='iPhone 8'
```

The default device is set to `iPhone X`.

## Compiling for a device
This is similar to compile for a simulator.
You can just run `make release.build` instead of `make debug.build`.
Firstly, you sould copy your provision into `ios/`. 
If you want to change the provision directory, `provisioning_profile` setting in `ios/BUILD` should be modified.
Next, Note that you specify your provision into `Makefile` or a command in advanced.

``` shell
make release.build PROVISION=cred/your_provision.mobileprovision
```

### Deploying the application into a device
For deploying the application into your device, just run `make deploy`.
This rule will use `ios-deploy`. 
Therefore, you sould install `ios-deploy` on your system.
For the detail of installation, you can visit `https://github.com/phonegap/ios-deploy`.

## Debugging the application
For debugging, you can run `make debug`.
After that, you can see `lldb`

