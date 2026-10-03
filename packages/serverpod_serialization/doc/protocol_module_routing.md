# Typed module routing

Generated protocols expose immutable declarations of their local deserialization
handlers and their module dependencies through the optional
`ProtocolDeserializationProvider` interface. Handler declarations include model,
nullable, enum, container, record, and custom serializer types. They come from
the same generator entries as the actual local decoder branches.

Database protocols implement `DatabaseProtocolDeserializationProvider`, which
also inherits the database contract. Both capability interfaces inherit the API
of their corresponding serialization manager, preserving that API when Dart
infers the common type of a collection or conditional containing protocols.

For a payload without a class discriminator, the protocol uses these declarations
to exclude modules that cannot handle the requested Dart `Type`. The eligible
module list is cached per type. It preserves dependency order, overlapping
handlers, and the existing `DeserializationTypeNotFoundException` fallback.
Transitive dependencies participate in the same lookup. Primitive handlers
inherited from `SerializationManager` remain eligible.

The cache holds type declarations and module instances. It never holds rows,
field metadata, decoded objects, successful payload-dependent resolutions, or
negative results inferred from a decoder failure. No database invalidation or
transaction boundary is involved.

## Compatibility

The wire format is unchanged. In particular, neither `__className__` nor dynamic
`className` envelopes receive new prefixes. Class-name dispatch, subtype fallback,
host registrations, and all serialization methods retain their existing behavior.
Calls containing a class discriminator use the complete original module order,
since a module may recognize a name that its caller does not know.

| Deployment | Behavior |
| --- | --- |
| New server, existing client | Existing payloads and discriminators remain readable in both directions. |
| New client, existing server | The client writes and reads the same wire format. |
| New host, existing generated module | The module has no optional metadata interface and remains eligible in its original position. |
| Existing generated host, new module | The host uses its existing calls; the module's additive metadata is ignored by that host. |
| Custom serialization manager | No new member is required on `SerializationManager`; absence of the optional interface preserves probing. |

Regenerated code requires the runtime release containing the optional interface.
This is a local generator/runtime requirement, not a requirement to upgrade the
remote peer. Existing generated code continues to work with the new runtime.

## Cost and scope

The first typed lookup constructs small immutable type sets and caches an ordered
candidate list. Subsequent lookups reuse that list. Local type comparison chains
remain unchanged; this proposal composes with a separate static decoder-map
optimization. Old modules retain their original probing cost until regenerated.
Discriminator-bearing calls retain the existing class-name path.

Dependency declarations remain immutable. If lookup encounters a dependency
cycle, it conservatively retains that module in the original fallback order.
Planning therefore terminates without removing an earlier valid owner or changing
the behavior of legacy cyclic probes. Dynamic host registrations are not part of
the typed module graph and continue through their existing dispatch path.

## Validation

Run the generator with `--force` when developing the CLI without changing its
version: the ordinary freshness stamp tracks model inputs and outputs, not CLI
source edits.

The serialization package tests exercise candidate filtering, transitive and
legacy dependencies, precedence, primitive fallbacks, and immutable declarations.
The server test package exercises actual generated protocols, including subtype
fallback, malformed rows, nullable values, records, and inferred protocol APIs.

After resolving and generating the current checkout, the compatibility runner
compiles peers from a pre-change Git revision and from current source. It
exchanges actual payloads in both directions, checks both mixed-generation
host/module combinations, and compares old/new output bytes:

```sh
python3 tests/serverpod_test_server/tool/check_protocol_routing_compatibility.py \
  --baseline b693774b77613a21a3ebca3e1d310e59ca578c13 \
  --scratch /tmp/protocol-routing-compatibility \
  --dart /path/to/dart
```

Use a new scratch directory for each run. The output retains compilation logs,
wire payloads, package configurations, and a JSON result for every exchange.
