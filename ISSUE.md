The path in the failure is relative to a package/test server, not the workspace root. I’m locating the actual test file and checking the local testing conventions before editing.

• I’m using the Dart/Flutter testing skill here because this is a Dart integration test change. The failure points at a subscription readiness race: Redis pub/sub can drop a message if publish happens before the subscribe
  command has actually been acknowledged.

• The local API currently makes addListener synchronous, but it kicks off an async Redis subscription underneath. That means the test can publish immediately while Redis is still processing SUBSCRIBE, which matches the observed
<null> after timeout.

---

session.messages.addListener(...) is synchronous, but for Redis/global messages it starts an async SUBSCRIBE internally. The test immediately published with global: true, so Redis could receive PUBLISH before the server had
  actually received the SUBSCRIBE acknowledgement. Redis pub/sub does not buffer messages for not-yet-subscribed clients, so the message could genuinely be lost.

  I fixed the underlying race by making RedisController.subscribe() wait for Redis’ subscription confirmation and making global postMessage() wait for any in-flight subscription on that channel. No test file was changed.

codex resume 019e6f4c-80ad-7150-b366-00cdfdd3292d
