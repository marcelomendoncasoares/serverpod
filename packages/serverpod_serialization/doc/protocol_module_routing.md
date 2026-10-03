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

On first access, a protocol initializes its immutable type set and module list.
Each requested type caches an ordered candidate list for subsequent lookups.
Memory grows with the declared types and requested routes. Local type comparison
chains remain unchanged; this proposal composes with a separate static decoder-map
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

## Measured workload

A local Linux SQLite receipt workload uses the branch emitter and runtime with
frozen model decoders, database 4.0.0, and Flutter 3.44.4 / Dart 3.12.2. It measures
actual persistence and validates persisted values, balanced postings, and stable
posting identities. Small and large fixtures contain 60/121 and 260/521 journal
entries/postings. Values below are milliseconds: means of three process medians,
with eight warm-up iterations discarded from 24 per action.

| Fixture / action | Ordinary | Routing | Lower latency |
| --- | ---: | ---: | ---: |
| Small: ignore | 27.33 | 24.13 | 11.7% |
| Small: category | 182.43 | 163.84 | 10.2% |
| Small: account | 170.69 | 153.12 | 10.3% |
| Large: ignore | 26.58 | 22.07 | 17.0% |
| Large: category | 362.21 | 277.13 | 23.5% |
| Large: account | 355.85 | 286.48 | 19.5% |

The comparison isolates routing: only generated protocol declarations/fallback,
the additive runtime capability, and the database capability interface differ.
SQL, decoded-model, and projection work match in every warm profile iteration.
Category saves execute 326 statements and decode 1,166 ORM rows, including 576
CRDT field and 514 CRDT row objects. No database or CRDT algorithm changes are
part of this proposal. These local results do not measure network sync,
PostgreSQL, rendering, or a release Flutter device.

Native Dart AOT probes exercise the same models, with 20,000 warm-up calls and
300,000 measured calls per case in three processes. Values are median
nanoseconds per call:

| Decode | Ordinary | Routing |
| --- | ---: | ---: |
| Core enum directly | 127.1 | 129.1 |
| Enum through application protocol | 13,667.4 | 234.6 |
| CrdtDataField | 7,160.4 | 1,312.9 |
| CrdtDataRow | 7,766.1 | 2,207.9 |
| Posting | 18,568.8 | 4,828.6 |
| List of one Posting | 21,770.7 | 6,225.9 |

First CRDT-field decoding is 151 versus 193 microseconds; RSS afterward is
9.06 versus 9.23 MB. Executable size is 7.89 versus 7.91 MB. These are standalone
first-use observations, not application startup or peak-memory measurements. Local decoder chains are unchanged.

Validation passes 2,290 generator tests, 518 serialization tests, and 777 server
unit tests with one existing skip, plus 12 application protocol cases per variant
and 29 application write-scope cases. Compiled pre-change/current peers pass both
wire directions and both mixed-generation host/module arrangements, emitting
byte-identical payloads. All 34 regenerated protocols preserve every method
except typed `deserialize`. Handwritten strict analysis and formatting pass;
generated analysis reports no errors or warnings and retains existing style
infos.

An observed contended timing batch is retained and excluded in full. Accepted
paired timing runs have no detected overlapping Dart tests or compilers. The
`financial_life` assessment includes process medians, raw samples, source hashes,
and log hashes in its repository under `docs/features/research/protocol-module-routing-results.json`;
raw copies and logs are retained locally at `/tmp/protocol-module-routing/`.
`tools/serverpod_cli/tool/reemit_protocol_routing.dart` applies the actual routing
emitter to frozen generated protocols so unrelated model/database changes do not
enter the comparison.
