# Install list of packages
function Install-PackageList([string[]]$PackageList) {
    foreach ($Package in $PackageList) { winget install --interactive --moniker $Package }
}

# Install developer tools
function Install-Dev() {
    Install-PackageList @(
        "Docker.DockerDesktop",
        "GitHub.GitHubDesktop",
        "GoLang.Go",
        "Graphviz.Graphviz",
        "Meld.Meld",
        "Microsoft.AzureCLI",
        "Microsoft.AzureDataStudio",
        "Microsoft.AzureStorageEmulator",
        "Microsoft.AzureStorageExplorer",
        "Microsoft.GitCredentialsManager",
        "Microsoft.VisualStudioCode",
        "OpenJS.Nodejs",
        "Postman.Postman",
        "Python.Python",
        "Rust.rustup",
        "WiresharkFoundation.Wireshark"
    )
}

# Install user applications
function Install-Apps() {
    Install-PackageList @(
        "7zip.7zip",
        "AgileBits.1Password",
        "Audacity.Audacity",
        "HexChat.HexChat",
        "Microsoft.Edge",
        "Microsoft.PowerToys",
        "Microsoft.Skype",
        "Microsoft.Teams",
        "ProtonVPN.ProtonVPN",
        "Valve.Steam",
        "VideoLAN.VLC",
        "thehandbraketeam.handbrake",
        "transmission.transmission"
    )
}

Install-Dev
Install-Apps
