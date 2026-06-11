# (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev
#
# SupaAppCLI — command-line companion for the SupaApp iOS app.
#
# Connects to the same Supabase project as the iOS app, signs in with
# email / password, then listens concurrently on two realtime channels:
#
#   • mobileApp-channel  — broadcast events (sent by any connected client,
#                          no RLS, arbitrary key/value payload)
#   • messages-changes   — postgres changes on global_message_queue
#                          (INSERT / UPDATE / DELETE, subject to RLS)
#
# Press 'q' + Enter to sign out and exit cleanly.
#
# Run:
#   uv run main.py          (uv handles the venv automatically)
#   uv sync                 (first time: creates .venv and installs deps)

import asyncio
import getpass
import sys
import threading
from datetime import datetime, timezone

from supabase import AsyncClient, acreate_client

# ── Supabase credentials ─────────────────────────────────────────────────────
# Mirror of Apps/Unit0x04/SupaApp/Models/SupabaseConfig.swift.
# SECURITY: keep out of version control in production — see the comment in
# SupabaseConfig.swift for the correct xcconfig / Info.plist approach.
# For Python the idiomatic equivalent is a .env file read via python-dotenv,
# but for this course project the values are kept inline for simplicity.

SUPABASE_URL = "https://uxadpjjumbfqzhmwhitv.supabase.co"

# The anon key is a signed JWT that identifies this client as the public
# (unauthenticated) role.  Sign-in replaces it with a per-user session JWT
# that grants the 'authenticated' role and enables RLS-protected queries.
SUPABASE_ANON_KEY = "sb_publishable_liuWudtUV5qBGWL8DIvPqw_uShDP5H4"
__SUPABASE_ANON_KEY = (
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
    ".eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp5cG5lb2t6Znltb25ub3hwZ2R6Iiwi"
    "cm9sZSI6ImFub24iLCJpYXQiOjE3NDcxOTgyNzcsImV4cCI6MjA2Mjc3NDI3N30"
    ".KktrFMFf6tgby1yVtePAJK7n5IFt6kz3CrpogCrp9DQ"
)

# ── Channel / event names — must match the iOS app exactly ──────────────────
BROADCAST_CHANNEL = "mobileApp-channel"  # DatabaseConnector.broadcastChannelName
BROADCAST_EVENT = "mobileApp-event"  # DatabaseConnector.broadcastEventName
DATA_CHANNEL = "messages-changes"  # DatabaseConnector.dataChannelName
DATA_TABLE = "global_message_queue"


# ── Helpers ──────────────────────────────────────────────────────────────────


def ts() -> str:
    """Current UTC wall-clock time as HH:MM:SS — prepended to every log line."""
    return datetime.now(tz=timezone.utc).strftime("%H:%M:%S")


# ── Main ─────────────────────────────────────────────────────────────────────


async def main() -> None:

    # ── Credentials ─────────────────────────────────────────────────────────
    # getpass.getpass() writes the prompt to /dev/tty and reads the password
    # without echoing it — works correctly even when stdout is redirected.
    email = input("Email:    ")
    password = getpass.getpass("Password: ")

    # ── Connect & sign in ────────────────────────────────────────────────────
    # acreate_client() returns an AsyncClient whose realtime, auth, and
    # postgrest layers all use asyncio under the hood — no thread-pool shims.
    print("\nConnecting to Supabase…")
    client: AsyncClient = await acreate_client(SUPABASE_URL, SUPABASE_ANON_KEY)

    try:
        auth = await client.auth.sign_in_with_password(
            {"email": email, "password": password}
        )
    except Exception as exc:
        print(f"Sign-in failed: {exc}")
        return

    print(f"Signed in as {auth.user.email}\n")

    # ── Quit mechanism ───────────────────────────────────────────────────────
    # asyncio.Event lets coroutines block on a signal that arrives from another
    # thread.  Keyboard input is inherently synchronous (sys.stdin.readline
    # blocks), so we park it in a daemon thread.  When 'q' is typed,
    # call_soon_threadsafe() schedules quit_event.set() on the event loop —
    # the only safe way to touch asyncio objects across thread boundaries.
    quit_event = asyncio.Event()
    loop = asyncio.get_running_loop()

    def _stdin_watcher() -> None:
        while True:
            try:
                line = sys.stdin.readline()
            except (EOFError, OSError):
                break
            if line.strip().lower() == "q":
                loop.call_soon_threadsafe(quit_event.set)
                break

    threading.Thread(target=_stdin_watcher, daemon=True, name="stdin-watcher").start()

    # ── Broadcast channel ────────────────────────────────────────────────────
    # Broadcast bypasses RLS entirely — the server fans the message out to all
    # subscribers on the named channel without touching any postgres table.
    # The iOS app sends here via DatabaseConnector.broadcast(payload:).
    def on_broadcast(payload: dict) -> None:
        # The SDK wraps the user payload one level deeper under a 'payload' key
        inner = payload.get("payload", payload)
        print(f"[{ts()}] BROADCAST   {inner}")

    bc = client.channel(BROADCAST_CHANNEL)
    bc.on_broadcast(event=BROADCAST_EVENT, callback=on_broadcast)
    await bc.subscribe()
    print(
        f"[{ts()}] Subscribed to broadcast  '{BROADCAST_CHANNEL}' / '{BROADCAST_EVENT}'"
    )

    # ── Postgres-changes channel ─────────────────────────────────────────────
    # Postgres changes go through Supabase Realtime's WAL (write-ahead log)
    # listener.  Prerequisites (already configured for the iOS app):
    #   • table must be in the 'supabase_realtime' publication
    #   • authenticated role needs a SELECT RLS policy (checked per event)
    # event="*" is shorthand for PostgresChangeEvent.ALL — catches INSERT,
    # UPDATE, and DELETE in a single subscription.
    def on_data_change(payload: dict) -> None:
        evt = payload.get("eventType", "?")
        new = payload.get("new", {})
        old = payload.get("old", {})
        errs = payload.get("errors")
        if errs:
            print(f"[{ts()}] DATA ERROR  {errs}")
        elif evt == "DELETE":
            print(f"[{ts()}] DATA DELETE  old={old}")
        else:
            print(f"[{ts()}] DATA {evt:<8}  {new}")

    dc = client.channel(DATA_CHANNEL)
    dc.on_postgres_changes(
        event="*",  # PostgresChangeEvent.ALL: INSERT | UPDATE | DELETE
        schema="public",
        table=DATA_TABLE,
        callback=on_data_change,
    )
    await dc.subscribe()
    print(f"[{ts()}] Subscribed to data       '{DATA_CHANNEL}' → table '{DATA_TABLE}'")

    # ── Event loop ───────────────────────────────────────────────────────────
    print(f"\nListening for events — press 'q' + Enter to quit.\n")
    await quit_event.wait()

    # ── Cleanup ──────────────────────────────────────────────────────────────
    # remove_all_channels() unsubscribes and closes WebSocket connections
    # gracefully so the server doesn't see a dirty close before sign-out.
    print("\nCleaning up…")
    await client.realtime.remove_all_channels()
    await client.auth.sign_out()
    print("Signed out. Bye.")


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        # Ctrl-C is an acceptable exit path — no stack trace needed
        print("\nInterrupted.")
