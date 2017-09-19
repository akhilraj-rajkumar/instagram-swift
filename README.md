# Instagram Swift

<p align="center">
    <a href="http://perfect.org/get-involved.html" target="_blank">
        <img src="http://perfect.org/assets/github/perfect_github_2_0_0.jpg" alt="Get Involed with Perfect!" width="854" />
    </a>
</p>

<p align="center">
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat" alt="Swift 3.0">
    </a>
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat" alt="Platforms OS X | Linux">
    </a>
    <a href="http://perfect.org/licensing.html" target="_blank">
        <img src="https://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat" alt="License Apache">
    </a>
</p>

Instagram project in Swift

This repository holds Instagram implementation in Perfect Swift. It builds with Swift Package Manager and produces a stand-alone HTTP executable.

## Compatibility with Swift

The master branch of this project currently compiles with **Xcode 8.2** or the **Swift 3.0.2** toolchain on Ubuntu.

## Building & Running

The following will clone and build an empty starter project and launch the server on port 8282.

```
git clone https://github.com/akhilraj-rajkumar/instagram-swift
cd instagram-swift
swift build
.build/debug/PerfectTemplate
```

You should see the following output:

```
[INFO] Starting HTTP server  on 0.0.0.0:8282
```

This means the servers are running and waiting for connections. Access [http://localhost:8282/](http://127.0.0.1:8282/) to see the login. Hit control-c to terminate the server.

