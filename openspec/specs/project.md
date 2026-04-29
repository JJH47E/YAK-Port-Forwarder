# YAK Port Forwarder — Baseline System Specification

> YAK (Yet Another Kubernetes) Port Forwarder is a native macOS GUI for managing and running `kubectl port-forward` processes against a Kubernetes cluster.

---

## Overview

The app allows a user to define a set of Kubernetes port-forward targets, persist them as a `.yak` file, and start/stop the underlying `kubectl` processes individually or all at once. It has no server component; all state is local to the running app instance.

---

## Architecture

```
YAK_Port_ForwarderApp (entry point)
│
├── KubeViewModel  ← single source of truth; ObservableObject
│   ├── portForwards: [KubePortForwardResource]
│   ├── context: String?          ← active kubectl context name
│   ├── loaded: Bool              ← gates main UI from splash
│   ├── runningAll: Bool          ← manually tracked "all running" toggle
│   ├── filePath: URL?            ← nil = not yet saved
│   └── hasError / errorText
│
├── Views
│   ├── Splash                    ← pre-load gate; Create or Open entry points
│   ├── MainContent               ← toolbar + list; shown when loaded=true
│   │   ├── PortForwardList       ← 2-column grid of cards
│   │   │   └── PortForwardItem   ← per-resource card with status/actions
│   │   │       └── [sheet] EditPortForward → PortForwardForm (clone pattern)
│   │   ├── [sheet] AddPortForward → PortForwardForm (new resource)
│   │   └── [sheet] UpdateNamespace
│
└── Helpers
    ├── ShellHelper               ← PATH resolution, kubectl discovery, Process factory
    └── KubectlExitReasonHelper   ← maps kubectl exit codes to user messages
```

---

## Core Domains

### 1. Configuration / File Domain

Managed by `KubeViewModel`.

**State**
- `portForwards` — the live list of `KubePortForwardResource` objects
- `filePath` — the currently open `.yak` file; `nil` means unsaved
- `loaded` — whether a configuration session is active (new or opened file)

**Behaviors**
- **Create new** — sets `loaded = true` with an empty `portForwards` list; calls `load()` to fetch kubectl context
- **Open file** — shows `NSOpenPanel`, reads JSON, validates each resource via `isValid`, sets `filePath`, then calls `load()`
- **Open via file association** — `.yak` files are associated with the app; opening from Finder triggers `onOpenURL → openFile(selectedURL:)`
- **Save** — if `filePath` is set, writes JSON to that path; otherwise delegates to Save As
- **Save As** — shows `NSSavePanel`, defaults filename to `kube-port-forward.yak`, writes JSON, sets `filePath`
- **Keyboard shortcuts** — Cmd+S (Save), Cmd+Shift+S (Save As), Cmd+O (Open)

**Persistence format**
- JSON array of `KubePortForwardResource` objects
- File extension: `.yak` (custom document type with file icon)
- Encoded fields: `resourceName`, `resourceType`, `namespace`, `forwardedPorts`
- Excluded from encoding: `status`, `errorDescription` (transient runtime state)
- Validation on open: each resource must satisfy `isValid` (non-empty name, namespace, at least one port mapping with both ports set); corrupt files show an error alert and abort load

---

### 2. Port Forward Resource Domain

**Model: `KubePortForwardResource`**

| Field | Type | Notes |
|-------|------|-------|
| `resourceName` | `String` | Kubernetes resource name (e.g. `nginx-bf5d5cf98-hqz66`) |
| `resourceType` | `KubeResourceType` | `.pod`, `.deployment`, or `.service` |
| `namespace` | `String` | Kubernetes namespace |
| `forwardedPorts` | `[PortMapping]` | One or more local→remote port pairs |
| `status` | `PortForwardStatus` | Runtime only; not persisted |
| `errorDescription` | `String?` | Runtime only; not persisted |

**Validity** (`isValid`): non-empty `resourceName`, non-empty `namespace`, at least one `PortMapping`, all mappings have both `localPort` and `remotePort` set.

**Model: `PortMapping`**

| Field | Type | Notes |
|-------|------|-------|
| `localPort` | `Int?` | `nil` = not yet configured |
| `remotePort` | `Int?` | `nil` = not yet configured |

**`KubeResourceType`**

| Case | `description` (UI label) | `resourceName` (kubectl prefix) |
|------|--------------------------|----------------------------------|
| `.pod` | Pod | `""` (no prefix) |
| `.deployment` | Deployment | `"deployment"` |
| `.service` | Service | `"service"` |

**`PortForwardStatus`**

```
idle ──[start()]──▶ running ──[clean exit / SIGTERM]──▶ stopped
                       │
                       └──[non-zero exit]──▶ error
running ──[stop()]──▶ stopped
error   ──[applyChanges()]──▶ idle   (edit resets status)
```

**Clone pattern**: `EditPortForward` clones the original resource on appear. "Confirm" calls `applyChanges(from:)` which copies all fields and resets status to `.idle`. "Cancel" discards the clone; the original is unmodified.

---

### 3. Process Execution Domain

Managed by `KubePortForwardResource` (process lifecycle) and the `Helpers` layer.

**`ShellHelper`** — static utility, evaluated lazily at app start

- `userPath` — spawns `zsh -ilc echo $PATH` to capture the user's full interactive shell PATH (needed so Homebrew-installed tools like `kubectl` are discoverable)
- `kubectlExecutable` — runs `/usr/bin/which kubectl` with the resolved PATH to find the `kubectl` binary URL; `nil` if not found
- `createProcess()` — factory that injects `userPath` into the process environment before returning a bare `Process`

**kubectl command construction**

```
kubectl port-forward <prefix/><resourceName> -n <namespace> <local>:<remote> [...]
```

- Pod:        `kubectl port-forward nginx-abc123 -n default 7701:80`
- Deployment: `kubectl port-forward deployment/my-app -n staging 8080:8080`
- Service:    `kubectl port-forward service/my-svc -n prod 9090:9090`

**Process lifecycle**
- Runs on a background `DispatchQueue` (`.background` QoS)
- `portForwardProcess` holds a strong reference while running; `nil` when stopped
- Termination handler dispatches back to main thread to update `status`
- Exit code 15 (SIGTERM) → `.stopped`; clean exit (0) → `.stopped`; anything else → `.error`
- `stop()` calls `process.terminate()` (SIGTERM)

**`KubectlExitReasonHelper`** — maps exit codes to user-facing strings

| Exit code (mod 128) | Message |
|---------------------|---------|
| 1 | Unspecified error, does the resource exist? |
| 2 | Terminated by Interrupt (SIGINT) |
| 9 | Terminated by Kill (SIGKILL) |
| 15 | Terminated gracefully (SIGTERM) |
| 126 | Permission denied |
| 127 | Command not found |
| other | Unknown error with raw exit code |

---

### 4. UI / View Domain

**App entry states**

```
App launch
    │
    ▼
Splash (loaded = false)
    ├── "Create Configuration File" → createNew() → MainContent
    └── "Open Configuration File"  → openFile()  → MainContent (if valid)

MainContent (loaded = true)
    ├── Empty state: large + button → AddPortForward sheet
    └── List state: PortForwardList (2-col grid) + toolbar
```

**Toolbar actions (MainContent)**

| Button | Behavior |
|--------|----------|
| GitHub icon | Opens `https://github.com/JJH47E/YAK-Port-Forwarder` |
| Actions menu → Change Namespace | Opens `UpdateNamespace` sheet |
| Save (floppy icon) | `viewModel.save()` |
| Start / Stop (toggle) | `viewModel.startStopAll()` |
| Add (+) | Opens `AddPortForward` sheet |

**PortForwardItem card**

| Element | Notes |
|---------|-------|
| Resource name (bold, title2) | |
| Namespace and resource type (subheadline) | |
| Port summary | First port pair shown; if >1, appends `, ...` |
| Error message | Shown in red when `status == .error` |
| Gear (edit) button | Opens `EditPortForward` sheet; disabled while `.running` |
| Play/Stop button | Toggles `startStop()`; icon reflects current status |

**EditPortForward**
- Clones resource on `.onAppear`
- Confirm: `applyChanges(from:)` + dismiss
- Cancel: dismiss (clone discarded)
- Delete: calls `deleteAction()` + dismiss
- Confirm disabled when `!editableResource.isValid`

**PortForwardForm**
- Shared between Add and Edit flows
- Fields: Resource Name (`TextField`), Resource Type (`Picker`), Namespace (`TextField`), Ports (scrollable list with add/remove)
- Resource Type uses a local `@State var type` synced to the model via `onAppear`/`onChange`

**UpdateNamespace**
- Single `TextField` for a new namespace value
- On confirm, calls `viewModel.updateNamespace(_:)` which overwrites the `namespace` field on **all** port forwards

---

## Key Invariants & Constraints

- Only one `.yak` file is open at a time (no tabs, no multi-document)
- No auto-save; the user must explicitly save
- `runningAll` is a manually maintained boolean toggle, not derived from the actual process states — it can desync if individual processes are started/stopped
- Editing a resource resets its status to `.idle` (stopping a running forward before editing is enforced by disabling the edit button while `.running`)
- Shell PATH is resolved once at app launch (static `let`); changes to the user's PATH during an app session are not picked up
- `kubectl` is located via `which` at launch; a `nil` result blocks any port-forward attempt with an error alert
- No support for switching kubectl contexts — the app reflects whichever context `kubectl config current-context` returns at load time

---

## Known Gaps / Roadmap Items (from README)

1. Support custom `kubectl` executable paths
2. Better error messages
3. Resource/Namespace autocomplete
4. No undo/redo
5. No test suite
