// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

/*
 HumiditySensor is its own SensorDataReceiver and rebroadcasts new readings
 via a Swift Concurrency 'AsyncStream<Int>'. This is the modern, type-safe
 way to model a "push" data source in Swift 6 — no Combine import needed.

 Trade-offs of AsyncStream as a notification mechanism:
   Feature                AsyncStream
   Type safety            Yes (element type is part of the type)
   Lifecycle management   Yes (Task cancellation ends iteration;
                          continuation.finish() ends the stream)
   Global broadcast       No — a single iterator consumes the stream.
                          For multi-subscriber fan-out you need an
                          AsyncBroadcastSequence (swift-async-algorithms)
                          or a Combine-style subject.

 Design note: a fresh AsyncStream is created each time the consumer
 (the ViewModel) calls 'makeHumidityStream()'. That keeps each
 monitoring cycle clean and avoids the "you can only iterate me once"
 footgun of AsyncStream.
 */
class HumiditySensor: SimulatedSensor, SensorDataReceiver {
    // Continuation is kept as Optional so we can recreate it on every
    // monitoring cycle. Only the latest continuation receives values.
    private var continuation: AsyncStream<Int>.Continuation?

    init() {
        super.init(minValue: 0, maxValue: 100, startValue: 50, variation: 3)
        self.sensorDataReceiver = self
    }

    /// Creates a fresh AsyncStream for one monitoring cycle.
    /// The previous stream (if any) is finished so its consumer-Task exits cleanly.
    func makeHumidityStream() -> AsyncStream<Int> {
        // Finish any previous stream so old iterators terminate.
        continuation?.finish()

        return AsyncStream { cont in
            self.continuation = cont
            // onTermination fires when the stream is finished or the consuming
            // Task is cancelled. The closure is '@Sendable' and may run off
            // the main actor, so don't touch non-Sendable state from inside.
            // Good place for logging or external cleanup; left empty here.
            cont.onTermination = { _ in }
        }
    }

    func didReceiveSensorData(_ data: Int) {
        // 'yield' is non-blocking; if no consumer is iterating, the value
        // is buffered (default policy = .unbounded). 'finish()' ends the stream.
        continuation?.yield(data)
    }
}
