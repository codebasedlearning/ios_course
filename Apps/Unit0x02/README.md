[© Alexander Voß, FH Aachen, codebasedlearning.dev](mailto:info@codebasedlearning.dev)

# iOS Course – Apps


## Unit 0x02

> In this unit we look at the application architecture and in particular the Model-View-ViewModel (MVVM).


## MVVM

MVVM is a design pattern that helps you separate concerns in your app, making your code more modular, testable, and reusable. 

Let's start with a brief characterisation of what is what.


### Model

This is your data layer. It knows nothing about the UI. 
Example:

```
struct User: Identifiable, Codable {
    let id: UUID
    let name: String
    let email: String
}
```

- Knows about: Just itself or other models it needs.
- Should NOT know about: ViewModel or any UI. No SwiftUI imports here.
- It’s the data vault. Quiet, solid, dependable.


### View

This is what the user sees. It presents data and sends user input to the ViewModel.
Example:
```
struct TicTacToeView: View {
    @Environment(TicTacToeViewModel.self) private var game
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
    ...
}
```

- Knows about: Only the ViewModel.
- It binds to observable properties exposed by the ViewModel using @Bindable (Swift 5.9+) or @ObservedObject / @StateObject in earlier versions.
- It doesn’t reach behind the curtain to poke at the models or services directly.


### ViewModel

This is where the magic happens. It takes the Model, processes it, and prepares it for display in the View. It also handles user actions and talks to services or use cases.

Example:
```
@Observable
class UserViewModel {
    var user = "Bob"
    ...
}
```

- Knows about:
    - Models (e.g., HeartbeatSensor)
    - Services (e.g., networking, persistence)
- Doesn’t know about: 
    - Specific Views. It just exposes properties the View might bind to.


### “Who Knows Who?” in MVVM

Component       Knows about             Should not know about
Model           Itself, other models    ViewModel, View
ViewModel       Models, Services        View (in a tight wayâ€”more on that below)
View            ViewModel               Model (directly), Services

> View knows about View Model, View Model knows about Model, Model knows nothing


Layer       Owns the truth of               Observable?     Bound to View?
Model       The real world / data layer     Maybe           no
ViewModel   The current UI state            yes!            yes
View        Just presents the truth         N/A             yes (subscribes)


### One-Way Data Flow in SwiftUI

User Input → View (binds to) → ViewModel (calls/uses) → Model → (back to) View

The cycle:
- User interacts with the View, e.g., taps a button.
- The View calls a method on the ViewModel.
- The ViewModel mutates state or talks to the Model.
- The Model returns data or triggers a change or the View Model observes the data changes from Model and update its own data.
- The ViewModel updates its observable properties.
- SwiftUI observes those changes and automatically re-renders the View.
    

### Models

There are many 'models'. Here are a few.


#### Domain Models

Represent real-world concepts, business logic, or core app data.
- Examples: HeartbeatSensor, User, Invoice, TemperatureReading.
- Behavior-focused, not just data holders.
- May contain validation, business rules, or simulation logic.

Swift Trait: Usually struct or class.


#### Data Transfer Objects (DTOs)

Data shaped for transport, not behavior.
- Examples: JSON responses, REST payloads
- Purely structural: just properties, no methods
- Often maps to/from domain models
    
Swift Trait: struct, always Codable


#### UI Models / View Data Models

Lightweight structs tailored for display in a View.
- Examples: UserRowViewModel, ChartDataPoint, FormattedDateModel
- Derived from domain or ViewModel logic
- Decouple the View from deep ViewModel knowledge
    
Swift Trait: struct, not observable


#### Persistence Models (e.g., Core Data / SwiftData)

Data shaped to fit the persistence framework.
- May include Core Data annotations or property wrappers
- Can often be converted to/from domain models

Swift Trait: class, framework-managed


#### Bonus: “Models” in ML or Algorithms

You might also see 'model' refer to a machine learning model, or the state representation in an algorithmic system (e.g., A-star search model, simulation model, etc.)


Model Type          Purpose                 Where It Belongs
Domain Model        Business logic          Core app logic
DTO                 Transport-only          Networking / data layers
UI Model            Data formatted for UI   ViewModel / View layer
Persistence Model   Storage representation  Persistence (Core Data)


## Other Architecture

The Composable Architecture (TCA) is a Swift architecture library by Pointfree. 
It is not a SwiftUI feature — it's an opinionated framework you import on top of SwiftUI. 
The mental model is borrowed from Elm and Redux, retrofitted into Swift's value-type, 
structured-concurrency world.
In a way to Model-View-Intent (MVI) on Android TCA is the iOS dialect of the same idea. 


## Tasks


### 👉 Task 'iOS-Project'

Think about 
- who you would like to form a group with.
- what kind of app you want to build.
- which iOS components you will need, such as databases, sensors, etc.
- how to divide up the tasks.
Think of a name for the group and a name for the app.
Start an iOS project in Gitlab or Github and invite me to join (as a maintainer).
Create a project outline and fill it in.

---

