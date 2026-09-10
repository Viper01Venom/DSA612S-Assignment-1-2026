# DSA612S Assignment 1 — REST and gRPC (Ballerina)

This repository contains our group project for Assignment 1.

We implemented both **Question 1 (REST)** and **Question 2 (gRPC)** using Ballerina.

## Group Members

Mazilliano De Klerk — 220038872
Dyrall Beukes — 223058467
AJay Steyn — 222082429
Aden Beukes — 221138072
Grace Urikos — 223051764 

## Project Structure

### Question 1 — Library and Resource Management System (REST)

**Folder:** `question1-rest/`

**Files inside:**

`Ballerina.toml`
`server/main.bal`
`server/models.bal`
`server/data.bal`
`client/main.bal`

This is a RESTful service for managing library and institutional resources such as books, electronic resources, laboratories, and meeting rooms.

The server provides operations for creating, updating, viewing, and removing assets, filtering assets by institution or site, checking maintenance and booking schedules, managing components, and handling work orders and tasks.

The client demonstrates how to loan and book resources, view all assets, filter resources by campus or institution, identify overdue items, and manage servicing schedules.

### Question 2 — Rental Accommodation System (gRPC)

**Folder:** `question2-grpc/`

**Structure:**

`proto/` → Protocol Buffer contract (`rental_accommodation.proto`)
`server/` → gRPC server (`rental_service.bal`, `data.bal`)
`client/` → gRPC client (`rental_client.bal`)

This is a gRPC service for managing rental accommodation properties.

The system supports hosts and guests, including adding, updating, and removing properties, creating users, listing and searching available properties, booking properties, and confirming bookings with availability checks and total price calculation.
