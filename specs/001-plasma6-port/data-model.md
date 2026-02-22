# Data Model: Plasma 6 Port

**Feature**: 001-plasma6-port | **Date**: 2026-02-22

This is a porting project — no new data entities are introduced. This
document maps existing entities to their Plasma 6 equivalents.

## Entity: Package Metadata

**Plasma 5**: `metadata.desktop` (INI format)
**Plasma 6**: `metadata.json` (JSON format)

| Field (Plasma 5) | Field (Plasma 6) | Notes |
|---|---|---|
| `Name` | `KPlugin.Name` | |
| `Comment` | `KPlugin.Description` | |
| `Icon` | `KPlugin.Icon` | |
| `X-KDE-PluginInfo-Name` | `KPlugin.Id` | |
| `X-KDE-PluginInfo-Author` | `KPlugin.Authors[].Name` | |
| `X-KDE-PluginInfo-Email` | `KPlugin.Authors[].Email` | |
| `X-KDE-PluginInfo-Version` | `KPlugin.Version` | |
| `X-KDE-PluginInfo-Website` | `KPlugin.Website` | |
| `X-KDE-PluginInfo-Category` | `KPlugin.Category` | |
| `X-KDE-PluginInfo-License` | `KPlugin.License` | |
| `X-KDE-ServiceTypes` | `KPackageStructure` | Value: `"Plasma/Applet"` |
| `X-Plasma-API` | REMOVED | |
| `X-Plasma-MainScript` | REMOVED | Inferred from package structure |
| N/A | `X-Plasma-API-Minimum-Version` | NEW: `"6.0"` |
| `X-Plasma-Provides` | `X-Plasma-Provides` | Array format in JSON |
| `Name[locale]` | `KPlugin.Name[locale]` | Translated names |
| `Comment[locale]` | `KPlugin.Description[locale]` | Translated descriptions |

## Entity: Widget Configuration (main.xml)

**Status**: UNCHANGED between Plasma 5 and 6.

The `main.xml` KConfigXT schema defines all `plasmoid.configuration.*`
keys. The schema format and all configuration keys are identical.
`ConfigMigration.qml` handles older key name migrations and continues
to work unchanged.

## Entity: Root QML Element

**Plasma 5**: `Item` with `Plasmoid.*` attached properties
**Plasma 6**: `PlasmoidItem` with direct properties

| Property (Plasma 5) | Property (Plasma 6) |
|---|---|
| `Plasmoid.compactRepresentation` | `compactRepresentation` |
| `Plasmoid.fullRepresentation` | `fullRepresentation` |
| `Plasmoid.preferredRepresentation` | `preferredRepresentation` |
| `Plasmoid.toolTipItem` | `toolTipItem` |
| `Plasmoid.toolTipMainText` | `toolTipMainText` |
| `Plasmoid.toolTipSubText` | `toolTipSubText` |
| `plasmoid.expanded` | `root.expanded` |
| N/A | `hideOnWindowDeactivate` | NEW direct property |
| N/A | `activationTogglesExpanded` | NEW direct property |

## Entity: QML Import Mapping

See `.specify/research/plasma6-porting-research.md` Section 2 for
the complete import mapping table (18 renamed/removed imports,
5 new imports).

## Entity: Component Mapping

See `.specify/research/plasma6-porting-research.md` Section 3 for
the complete component migration table covering:
- Units & Theme (PlasmaCore → Kirigami): 17 properties
- SVG (PlasmaCore → KSvg): 3 types
- DataSource (PlasmaCore → Plasma5Support): 2 types
- SortFilterModel (PlasmaCore → KItemModels): 1 type

## Entity: Actions

**Plasma 5**: Imperative `setAction()` / `action_*()` pattern
**Plasma 6**: Declarative `Plasmoid.contextualActions` array of
`PlasmaCore.Action` objects

See `.specify/research/plasma6-porting-research.md` Section 4.

## Entity: Configuration Pages

**Plasma 5**: Root element `Item` with `cfg_*` property aliases
**Plasma 6**: Root element `KCM.SimpleKCM` with `cfg_*` property aliases

The `cfg_*` property alias pattern is unchanged. Only the root
element type changes.

## State Transitions

No state machine changes. The widget lifecycle (install → load →
compact → expanded → configure) is unchanged between Plasma 5 and 6.
The only behavioral change is that `expanded` is now a direct property
on `PlasmoidItem` rather than an attached property on `Plasmoid`.
