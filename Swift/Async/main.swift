// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev


/**
 Swift Concurrency – a 'best of' for everyday iOS work.

 Topics:
  - async/await and suspension points
  - async let (lightweight structured parallelism)
  - Task and (cooperative) cancellation
  - task groups (withTaskGroup)
  - AsyncSequence, 'for await', AsyncStream (callback -> stream bridging)
  - actors and @MainActor (the UI 'thread')
  - withCheckedContinuation (callback -> async bridging)

 Deliberately excluded (look up when needed):
  - GCD/DispatchQueue details (legacy), Combine
  - Sendable fine print, custom executors, TaskLocal, distributed actors
  - swift-async-algorithms package (debounce, merge, zip, ...)

 Notes:
  - Top-level 'await' works in main.swift (script mode) since Swift 5.7,
    and top-level code runs on the MainActor – just like your UI code.
 
 Coroutine:
  – A coroutine is a function that may suspend
  – 'async' -> mark as can suspend
  – 'await' -> suspension point, i.e. the thread is not blocked (non-blocking),
    instead it goes off and does other work -> main idea
  - resume, i.e. after the awaited operation completes, execution continues
    from where it left off
  - preserve state, i.e. local variables and context are preserved across
    suspension points
  - he term "coroutine" is the computer science concept, while 'async'
    is Swift's keyword for it
 */

import Foundation

/*
  We want to simulate an IO-operation using 'sleep'

 do {
    try await Task.sleep(for: .milliseconds(50))
 } catch { ... }

  - 'sleep' returns nothing but can throw CancellationError, hence 'try'
  - with 'await' the function can pause while waiting for an async operation
    to complete
  - we can shorten this by using 'try?', it converts any thrown errors into
    an optional result, i.e. nil in case of an error, otherwise the value
  - we need to mark the function as a coroutine with 'async'
*/

/// simulates fetching a user from id
func fetchUser(id: Int) async -> String {

    try? await Task.sleep(for: .milliseconds(50))
    
    return "user-\(id)"                     // fake user name
}

/// simulates fetching an avatar from id
func fetchAvatar(id: Int) async -> String {
    try? await Task.sleep(for: .milliseconds(50))
    
    return "avatar-of-id-\(id)"
}

enum FetchError: Error { case notFound }

/// simulates fetching a score, but with exceptions possible,
/// hence 'async throws'
func fetchScore(id: Int) async throws -> Int {
    try await Task.sleep(for: .milliseconds(100))   // note 'try' only, not 'try?'
    
    guard id > 0 else { throw FetchError.notFound }
    return 42
}

func asyncAwaitBasics() async {                     // note 'async' here
    introduce(topic: "async/await Basics")

    // - A clock that measures time that always increments. It an be considered
    //   as a stopwatch style time. This means that the instants are only comparable
    //   locally during the execution of a program.
    // - This clock is suitable for high resolution measurements of execution.
    let clock = ContinuousClock()

    // sequential: the second call starts only after the first finished
    var start = clock.now
    let name1 = await fetchUser(id: 1)          // needs 50ms
    let avatar1 = await fetchAvatar(id: 1)     // needs 50ms
    print(" 1| \(name1), \(avatar1)")
    print(" 2| sequential took \(clock.now - start)")

    start = clock.now
    // parallel:
    // - 'async let' spawns a new child task that starts running immediately
    //   in parallel.
    // - The task runs immediately, but you only block to get the result when
    //   you await it.
    // - 'n' and 'a' act like a future/promise - a placeholder for a value that
    //   will arrive later.
    // - Structured concurrency: These child tasks are bound to the current scope
    //   and cannot outlive their parent.
    async let n = fetchUser(id: 2)
    async let a = fetchAvatar(id: 2)
    let (name2, avatar2) = await (n, a)     // await once, where the values are needed
    print(" 3| \(name2), \(avatar2)")
    print(" 4| parallel took \(clock.now - start) (roughly half)")

    do {
        let score = try await fetchScore(id: 1)
        print(" 5| score=\(score)")
        _ = try await fetchScore(id: -1)
    } catch {
        print(" 6| caught '\(error)'")
    }
}


func tasksAndCancellation() async {
    introduce(topic: "Task & Cancellation")

    // Task { } = unstructured concurrency
    // - Tasks are not threads
    // - bridge from sync code into the async world
    // - task exists independently of the handle, it is just a reference,
    //   not ownership
    // - Tasks are executed by a cooperative thread pool managed by
    //   Swift's concurrency runtime
    // - ask can hop between threads at suspension points, i.e. when resumed,
    //   might continue on a different thread
    // - SwiftUI's .task {} includes automatic cancellation when the view
    //   disappears.
    //
    // Summary:
    //   Task - Lightweight unit of async work
    //   Thread Pool - Small set of threads (≈ CPU cores)
    //   Scheduler - Assigns tasks to threads
    //   Suspension - Task pauses, thread freed for other work
    //   Suspension points - are where hopping happens
    //   Thread hopping - Task resumes on potentially different thread
    //   Cooperative - Tasks must explicitly await to yield
    //
    let handle = Task {                     // or explicitly with return type: () -> String in
        for i in 1...5 {
            try Task.checkCancellation()    // cooperative! nobody kills a task by force
            print(" a| - working... step \(i)")
            try await Task.sleep(for: .milliseconds(40))    // sleep also throws on cancel
        }
        return "all steps done"
    }

    print(" 1| start")
    
    try? await Task.sleep(for: .milliseconds(100))
    handle.cancel()                         // a polite request, not a kill -9

    do {
        let result = try await handle.value // a task handle is also a future
        print(" 2| result=\(result)")
    } catch is CancellationError {
        print(" 3| task was cancelled (as planned)")
    } catch {
        print(" 4| unexpected: \(error)")
    }
}


func taskGroups() async {
    introduce(topic: "Task Groups")

    // n parallel jobs where n is only known at runtime -> task group
    
    // - this creates a task group
    // - that is a new scope that can contain a dynamic number of child tasks
    // - a group always waits for all of its child tasks to complete before it
    //   returns; even canceled tasks must run until completion before this
    //   function returns
    // - all child tasks run concurrently (parallel)
    // - results arrive in whichever finishes first (completion order)
    // - if group scope exits early, all children cancelled
    // - String.self is the ChildTaskResult.Type
    let names = await withTaskGroup(of: String.self) { group in
        for id in 1...4 {
            // suspends that specific child task while fetchUser runs
            group.addTask { await fetchUser(id: id) }
        }
        
        var collected: [String] = []
        
        // 'for await' waits but in the following sense
        // - as soon as any child task finishes, its result becomes available
        //   and the loop immediately processes that result
        // - then waits for the next child to finish
        // - continues until all children are done
        // That means, results arrive in completion order
        for await name in group {
            collected.append(name)
        }
        return collected
    }
    print(" 1| \(names)")

    // throwing variant: withThrowingTaskGroup – the first error cancels
    // all siblings
}

/// AsyncStream is the tool to turn the callback/delegate world into a clean
/// 'for await' loop
///
/// Summary:
/// AsyncStream - Container for async sequence of values
/// continuation - Handle to push values into the stream
/// yield(value) - Send a value to consumers, suspends at yield()
/// finish() - Signal no more values (stream ends)
/// onTermination - Cleanup when consumer stops early, i.e. the for-loop
/// Producer Task - Background work that generates values
/// @Sendable - marks types or closures that can be safely transferred
///             across concurrency boundaries without causing data races
///
/// see HumiditySensor in unit 0x02
/// 
func makeTicker(count: Int) -> AsyncStream<Int> {
    AsyncStream { continuation in
        let producer = Task {
            for i in 1...count {
                try? await Task.sleep(for: .milliseconds(30))
                continuation.yield(i)       // ca be called from a delegate
            }
            continuation.finish()
        }
        /// the closure can only capture Sendable values, ensuring
        /// it's safe to run on any thread
        continuation.onTermination = { @Sendable _ in   // cleanup hook
            producer.cancel()
        }
    }
}

/*
 example; assume, LocationManager is a class with a callback called for
 every location change
 
 func locationStream() -> AsyncStream<CLLocation> {
     AsyncStream { continuation in
         let manager = LocationManager()
         manager.delegate = LocationDelegate { location in
            continuation.yield(location)
         }
         manager.startUpdatingLocation()
         
         continuation.onTermination = { _ in
             manager.stopUpdatingLocation()
         }
     }
 }
 */

func asyncSequences() async {
    introduce(topic: "AsyncSequence & AsyncStream")

    print(" 1| ticks:", terminator: "")
    for await tick in makeTicker(count: 4) {    // suspends between elements
        print(" \(tick)", terminator: "")
    }
    print()

    // async sequences understand map/filter/prefix/contains etc. (lazily)
    print(" 2| evens:", terminator: "")
    for await tick in makeTicker(count: 6).filter({ $0.isMultiple(of: 2) }) {
        print(" \(tick)", terminator: "")
    }
    print()

    /// throwing variant: AsyncThrowingStream and 'for try await'
}


/// An actor serializes access to its state – no data races, no locks.
/// 'await' at the call site, because you might have to wait in line.
///
/// Actors are similar to classes, but with some important differences.
/// They serializes access to its state – no data races, no locks.
/// 'await' at the call site, because you might have to wait in line.
///
/// Summary:
/// Reference type
/// No Inheritance
/// Automatic Thread safety
/// Safe Mutable state
/// Access from outside requires await
/// Protocol conformance
/// Stored properties
/// Methods
/// Initializers
/// No locks needed, Swift runtime handles synchronization
/// Requires await, because you might have to wait for other tasks to finish

actor Counter {
    private(set) var value = 0
    func increment() { value += 1 }         // inside the actor: no await needed
}

/*
 Here, multiple threads may access/modify values simultaneously. This results
 in a data race = undefined behavior.

 class UnsafeCounter {
     var value = 0
     func increment() { value += 1 }
 }
 */

/// UI belongs to the MainActor; in a real app this would set label.text etc.
/// Calling it from elsewhere 'hops' to the main actor – just one await.
///
/// UI updates from background thread lead to chrashs as UIKit or all UI updates
/// must run on main thread
///
/// MainActor
/// guarantees execution on the main thread
/// can be called from anywhere with await
/// automatically "hops" to main thread if needed
/// Common patterns: Background work in Task, UI on main
///
@MainActor
func updateUI(_ text: String) {
    print(" 3| [main thread: \(Thread.isMainThread)] \(text)")
}

func actorsAndMainActor() async {
    introduce(topic: "Actors & MainActor")

    let counter = Counter()
    await withTaskGroup(of: Void.self) { group in
        for _ in 1...1000 { group.addTask { await counter.increment() } }
    }
    
    print(" 1| counter=\(await counter.value) (always 1000 – try that with a plain class...)")

    print(" 2| [main thread: \(Thread.isMainThread)] before the hop")
    await updateUI("hello from a background context")
    
    // this works today but won't in strict Swift 6 mode
    // isMainThread and get true, then at the next await point, resume on a different thread
    // Actor isolation is what matters

    // view models are typically annotated @MainActor as a whole
}


//----------------------


await asyncAwaitBasics()
await tasksAndCancellation()
await taskGroups()
await asyncSequences()
await actorsAndMainActor()
print()

//----------------------


/// print function intro
func introduce(topic: String) { print("\n\n\(topic)\n\(String(repeating: "=", count: topic.count))\n") }
