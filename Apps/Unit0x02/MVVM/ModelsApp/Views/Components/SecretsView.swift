// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

/*
 SecretsView shows user-dependent data and *collapses to nothing* when
 no one is signed in.

 Two things to flag:

  1. The 'if secrets.isVisible' is structural identity territory:
     when isVisible flips false, the view is REMOVED from the
     hierarchy (not just hidden), .onDisappear fires, any .task
     state is torn down. When it flips true again, a NEW view
     instance is built. That's usually what you want for "session-
     gated" components — the previous user's state shouldn't survive
     into the next user's session.

  2. There's no subscription code here, and there's no subscription
     code in SecretsViewModel either. The entire data path
        AuthService.currentUser  →  SecretsViewModel  →  SecretsView
     is held together by the Observation framework alone. Cheap.

 To make the spectrum visible: contrast this row with HumidityView
 (which has to wire its own AsyncStream consumer in the VM and a
 lifecycle handler in the View) — same MVVM shape, vastly more
 plumbing, because the sensor's Model is raw and async.
 */
struct SecretsView: View {
    @Environment(SecretsViewModel.self) private var secrets

    var body: some View {
        if secrets.isVisible {
            HStack(alignment: .lastTextBaseline, spacing: 5) {
                Text("Secret:")
                Text(secrets.sessionToken ?? "-")
                    .font(.title2)
                    .monospaced() // it's a token, give it the techy look
            }
            .padding(5)
        }
        // else: nothing — view is absent from the hierarchy entirely
    }
}
