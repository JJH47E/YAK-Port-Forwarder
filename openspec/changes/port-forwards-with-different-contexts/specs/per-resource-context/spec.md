## ADDED Requirements

### Requirement: Context field on port-forward resource
Each `KubePortForwardResource` SHALL have an optional `context` field of type `String?`. When `nil`, the resource uses the system's active kubectl context. When set, the resource uses the named context for all kubectl operations.

#### Scenario: New resource defaults to active context
- **WHEN** the user opens the Add Port Forward sheet
- **THEN** the context picker SHALL be pre-selected to the currently active kubectl context

#### Scenario: Context persists across save and reload
- **WHEN** a resource has a non-nil context set and the user saves the `.yak` file and reopens it
- **THEN** the context field SHALL be restored to the same value on the reloaded resource

#### Scenario: Missing context key in saved file
- **WHEN** a `.yak` file is opened that does not contain a `context` key for a resource
- **THEN** the resource SHALL load successfully with `context` equal to `nil`
- **AND** the resource SHALL behave as if no context override is set

### Requirement: Context picker in PortForwardForm
The `PortForwardForm` SHALL display a `Picker` labelled "Context" populated with all kubectl contexts available in the user's kubeconfig, plus an explicit "System Default" option representing `nil`.

#### Scenario: Available contexts shown in picker
- **WHEN** the user opens the Add or Edit Port Forward sheet
- **THEN** the picker SHALL list all context names returned by `kubectl config get-contexts -o name`
- **AND** the "System Default" option SHALL appear at the top of the list

#### Scenario: User selects a specific context
- **WHEN** the user selects a named context from the picker
- **THEN** `portForwardResource.context` SHALL be set to that context name string

#### Scenario: User selects System Default
- **WHEN** the user selects the "System Default" option in the picker
- **THEN** `portForwardResource.context` SHALL be set to `nil`

### Requirement: Available contexts loaded at startup
`KubeViewModel` SHALL fetch the list of available kubectl contexts at load time and expose them as `availableContexts: [String]`.

#### Scenario: Contexts fetched on file open or create new
- **WHEN** the user opens a `.yak` file or creates a new configuration
- **THEN** `availableContexts` SHALL be populated by running `kubectl config get-contexts -o name`
- **AND** the list SHALL be available before the user opens any Add or Edit sheet

#### Scenario: kubectl not found
- **WHEN** `kubectl` is not found in the PATH
- **THEN** `availableContexts` SHALL be an empty array
- **AND** the existing error alert for missing kubectl SHALL still be shown

### Requirement: Context flag passed to kubectl port-forward
When starting a port-forward for a resource that has a non-nil `context`, the kubectl subprocess SHALL be invoked with `--context <context-name>` immediately after `port-forward`.

#### Scenario: Port-forward with context override
- **WHEN** a `KubePortForwardResource` has `context = "my-cluster"` and `start()` is called
- **THEN** the kubectl command SHALL include `--context my-cluster` in its arguments

#### Scenario: Port-forward without context override
- **WHEN** a `KubePortForwardResource` has `context = nil` and `start()` is called
- **THEN** the kubectl command SHALL NOT include a `--context` argument
- **AND** kubectl SHALL use whichever context is currently active in the system kubeconfig
