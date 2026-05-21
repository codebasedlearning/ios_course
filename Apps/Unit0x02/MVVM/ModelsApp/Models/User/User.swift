// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

/*
 User is a Domain Model — a value type representing the identity of a
 person who can be signed in.

 Why a struct, not a class?
  - It's data. No behaviour, no identity beyond its fields.
  - Value semantics make it cheap to pass around and impossible to
    accidentally share-mutate.
  - Equatable + Identifiable are the two protocols a Domain Model
    almost always wants:
      * Identifiable so SwiftUI lists / ForEach can key on 'id'.
      * Equatable so we can compare two snapshots ("did the user change?").

 This is the first value-type Model in the unit — contrast with the
 sensor classes (HeartbeatSensor, PowerSensor, …) which are reference
 types because they have lifetime (timers, subscriptions, mutable
 internal state). A User is just a snapshot of "who is signed in".
 */
struct User: Identifiable, Equatable {
    let id: UUID
    let name: String
    let email: String
}
