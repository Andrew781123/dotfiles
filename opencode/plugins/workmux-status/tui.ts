import { execFile } from "node:child_process"
import { Plugin } from "@opencode/plugin/tui"

/**
 * Keeps the workmux window status in sync with OpenCode session activity.
 *
 * This is a CLI plugin: in V2 plugins run inside the shared background
 * service, which has no tmux pane of its own, so `workmux set-window-status`
 * must be driven from the terminal client process instead.
 */
export default Plugin.define({
  id: "workmux-status",
  setup(context: any) {
    function run(args: string[]): Promise<void> {
      return new Promise((resolve) => {
        execFile("workmux", args, { timeout: 5000 }, () => resolve())
      })
    }

    void run(["register-agent"])

    // OpenCode can emit several events per turn and across child sessions.
    // Track every session so one idle session cannot mark the whole pane done
    // while another session is still working.
    const statusBySession = new Map<string, string>()
    const deletedSessions = new Set<string>()
    let reportedStatus: string | undefined
    let statusQueue = Promise.resolve()

    function writeStatus(status: string) {
      return run(["set-window-status", status])
    }

    function queueStatus(status: string) {
      statusQueue = statusQueue.then(
        () => writeStatus(status),
        () => writeStatus(status),
      )
      return statusQueue
    }

    async function reportAggregateStatus() {
      const statuses = [...statusBySession.values()]
      let status = "done"

      if (statuses.includes("waiting")) {
        status = "waiting"
      } else if (statuses.includes("working")) {
        status = "working"
      }

      if (reportedStatus === status) {
        return
      }

      reportedStatus = status
      await queueStatus(status)
    }

    async function setStatus(sessionID: string | undefined, status: string) {
      if (!sessionID || deletedSessions.has(sessionID)) {
        return
      }

      const previous = statusBySession.get(sessionID)
      // A session we never saw start cannot finish the pane.
      if (status === "done" && previous === undefined) {
        return
      }
      if (previous === status) {
        return
      }

      statusBySession.set(sessionID, status)
      await reportAggregateStatus()
    }

    const handle = (event: any) => {
      void (async () => {
        try {
          switch (event.type) {
            case "session.execution.started":
              await setStatus(event.data.sessionID, "working")
              break
            case "session.execution.succeeded":
            case "session.execution.failed":
            case "session.execution.interrupted":
            case "session.idle":
              await setStatus(event.data.sessionID, "done")
              break
            case "permission.asked":
              await setStatus(event.data.sessionID, "waiting")
              break
            case "form.created":
              await setStatus(event.data.form.sessionID, "waiting")
              break
            case "permission.replied":
            case "form.replied":
            case "form.cancelled":
              await setStatus(event.data.sessionID, "working")
              break
            case "session.deleted": {
              const sessionID = event.data.sessionID
              deletedSessions.add(sessionID)
              if (statusBySession.delete(sessionID)) {
                await reportAggregateStatus()
              }
              break
            }
          }
        } catch {
          // A malformed event must not break the subscription.
        }
      })()
    }

    const stops = [
      "session.execution.started",
      "session.execution.succeeded",
      "session.execution.failed",
      "session.execution.interrupted",
      "session.idle",
      "permission.asked",
      "permission.replied",
      "form.created",
      "form.replied",
      "form.cancelled",
      "session.deleted",
    ].map((type: string) => context.data.on(type, handle))

    return () => {
      for (const stop of stops) {
        stop()
      }
    }
  },
})
