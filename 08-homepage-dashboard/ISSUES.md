# Issues — 08 Homepage Dashboard

---

## Issue 001 — Certificate error reaching HTTPS services

**Status:** ✅ Resolved
**Severity:** Low
**Time to resolve:** 15 minutes

### Symptom
Status widgets for services behind self-signed HTTPS (e.g. the firewall, OpenVAS) showed errors instead of health.

### Root Cause
The backends use self-signed certificates, which the widget's HTTPS check rejected by default.

### How I Fixed It
Configured the affected widgets to allow the self-signed certs (skip strict verification for those internal tiles).

### Lesson Learned
Internal services commonly use self-signed certs. Dashboards need to be told to accept them for status checks, or given the internal CA.

---

## Issue 002 — Wrong port on a service tile

**Status:** ✅ Resolved
**Severity:** Low
**Time to resolve:** 10 minutes

### Symptom
A tile linked to a service but the link/status failed.

### Root Cause
The tile used the wrong port for the service's web UI.

### How I Fixed It
Corrected the port in `services.yaml` and restarted the container.

### Lesson Learned
Keep a record of each service's actual management port — dashboards fail silently when a port is off by a digit.
