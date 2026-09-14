Question 2: gRPC Accommodation Service

Purpose of the Project

The purpose of Question 2 is to design and implement a distributed, gRPC-based Accommodation Service (conceptually similar to a vacation rental or hotel booking platform) using Ballerina. This system demonstrates the practical application of Remote Procedure Calls (RPC) to facilitate efficient, typed communication between a client and a centralized backend server.

The project highlights different gRPC communication patterns by providing a robust set of operations for two distinct user roles: *Hosts* and *Guests*.

System Architecture and Features

The system is built upon a strictly defined Protocol Buffers (`.proto`) contract (`accommodation.proto`), which outlines the service interfaces, message structures, and data types (such as Users, Properties, and Bookings) exchanged across the network. 

1. Host Operations
Hosts are able to manage their property listings using standard **Unary RPC** calls. The service allows them to:
- *Add Properties:* Register a new accommodation onto the platform.
- *Update Properties:* Modify the details (like price or status) of an existing listing.
- *Remove Properties:* Delete a property from the platform.

2. Guest Operations
Guests can explore and book properties utilizing a combination of Unary and Streaming RPCs:
- *Search Properties:* Look up the exact details of a specific property by its unique ID (Unary RPC).
- *List Available Properties:* Retrieve properties that match specific criteria, such as a target location and a maximum price per night. This operation demonstrates *Server-side Streaming*, allowing the server to continuously push matching property records to the client over a single connection as they are processed.
- **Book & Confirm:** A robust two-step booking process where guests first initiate a booking request to receive a temporary cart reference, and then confirm the transaction to finalize the booking (Unary RPC).

3. User Management
The system also demonstrates *Client-side Streaming* through the `create_users` operation. This feature allows the client to send a continuous stream of multiple user profiles (both hosts and guests) to the server over a single connection. Once the client finishes streaming the data, the server processes the batch and returns a unified acknowledgment response.

By encapsulating these features, Question 2 serves as a comprehensive exercise in defining Protobuf contracts, utilizing generated service stubs, and implementing modern, efficient inter-process communication in a distributed systems environment.
