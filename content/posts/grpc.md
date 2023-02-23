gRPC
---

# Interface Definition Language(IDL)
protocol buffers

# Synchronous vs. asynchronous

# RPC life cycle
## Unary RPC
1. client -> server
- metadata
- method name
- deadline if applicable
2. server -> client
- send back its own initial metadata (which must be sent before any response) straight away,
- or wait for the client’s request message. 
- Which happens first, is application-specific.
- optional trailing metadata
## Server streaming RPC
## Client streaming RPC
## Bidirectional streaming RPC
 the call is initiated by the client invoking the method and the server receiving the client metadata, method name, and deadline
The server can choose to send back its initial metadata or wait for the client to start streaming messages
- processing is application specific
- two streams are independent

# Deadlines/Timeouts
- clients to specify
-  server can query
- Specifying a deadline or timeout is language specific

# RPC termination
both the client and server make independent and local determinations of the success of the call, and their conclusions may not match

# Cancelling an RPC
- either can cancel at any time
- Changes made before a cancellation are not rolled back.

# Metadata
# Channels
-  Clients can specify channel arguments to modify gRPC’s default behavior(such as message compression)

- has state, including connected and idle

- How gRPC deals with closing a channel is language dependent. Some languages also permit querying channel state