# RAO AutoUpdater

Public distribution repository for RAO test-client updates. It only contains update manifests and release archives; the Godot client source remains in its own repository.

## Launcher manifest

The launcher reads this public URL:

`https://raw.githubusercontent.com/IlandelValle/RAO-AutoUpdater/main/manifest.json`

`manifest.json` is generated only when a client archive is published. Its format is described by `manifest.schema.json` and shown in `manifest.example.json`.

## Publish a test build

After the client workflow has produced the Windows ZIP, preview the release data first:

```powershell
.\scripts\Publish-RAOClientRelease.ps1 -ArchivePath C:\path\to\RAO-Client-0.1.0-test.1-windows-x86_64.zip -Version 0.1.0-test.1
```

The preview does not modify GitHub. Once the archive, version, and generated manifest look correct, run the same command with `-Publish`. It creates a GitHub Release, uploads the ZIP, writes `manifest.json`, commits it to `main`, and pushes it.

The ZIP must include `rao-client.exe` at its root. The launcher verifies the uploaded SHA-256 before it installs the update.
