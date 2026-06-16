# Plex Media Infrastructure Project

### Proxmox Virtualization, Linux Administration, VPN Networking, and Remote Access

## Executive Summary

Designed, deployed, and troubleshot a self-hosted media infrastructure using Proxmox VE, Linux Containers (LXC), Plex Media Server, and Tailscale VPN. The project focused on secure remote access, virtualization, network routing, and Linux systems administration.

The primary objective was to provide secure remote access to services hosted inside a virtualized environment while maintaining network segmentation and avoiding direct exposure of services to the public internet.

---

## Business Problem

Organizations frequently need to provide secure remote access to internal services without exposing systems directly to the internet.

This project demonstrates how VPN-based remote access and subnet routing can be implemented to securely access services hosted within a private network while maintaining visibility, control, and security.

---

## Technical Environment

### Virtualization Platform

* Proxmox VE
* Linux Containers (LXC)

### Operating Systems

* Ubuntu Linux

### Networking

* Virtual network bridges
* Linux routing
* IPv4 forwarding
* Private network segmentation

### Remote Access

* Tailscale VPN
* Subnet routing
* Secure encrypted tunnels

### Services

* Plex Media Server

---

## Architecture Overview

```text
Remote Client
        │
        ▼
Secure VPN Tunnel
        │
        ▼
VPN Gateway
        │
        ▼
Virtualization Host
        │
        ▼
Linux Container
        │
        ▼
Media Streaming Service
```

The virtualization host acts as a routing point between VPN-connected devices and services running inside isolated Linux containers.

---

## Project Responsibilities

### Infrastructure Deployment

* Provisioned and configured Linux containers within Proxmox VE.
* Installed and configured application services.
* Validated service availability and port accessibility.

### Linux Administration

* Managed services and processes.
* Verified service startup and availability.
* Performed command-line diagnostics and troubleshooting.

### Network Troubleshooting

* Investigated service accessibility issues.
* Identified differences between host-level and container-level networking.
* Validated listening services and network paths.

### VPN Integration

* Configured secure remote access using Tailscale.
* Implemented subnet routing for internal network access.
* Validated remote connectivity through encrypted VPN tunnels.

### Routing and Traffic Flow Analysis

* Diagnosed connectivity failures between VPN-connected devices and internal services.
* Identified disabled IPv4 forwarding as a root cause.
* Implemented and validated forwarding configuration.

---

## Challenges Encountered

### Challenge 1: Service Discovery

Initially, application services appeared unavailable from the virtualization host.

#### Resolution

Verified that services were operating inside an isolated Linux container rather than directly on the host operating system.

---

### Challenge 2: Remote Access Failure

Remote VPN-connected clients were unable to access services hosted within the private network.

#### Resolution

Performed network diagnostics and determined that packet forwarding was disabled on the host.

Implemented Linux IP forwarding and configured VPN subnet routing to allow traffic to reach internal services.

---

### Challenge 3: Network Layer Separation

The environment contained multiple networking layers:

* VPN interfaces
* Host networking
* Container networking
* Service networking

#### Resolution

Mapped traffic flow across all layers and verified communication paths between systems.

---

## Security Considerations

The environment was designed to avoid exposing services directly to the public internet.

Security controls included:

* VPN-only remote access
* Private network segmentation
* Container isolation
* Encrypted communication channels
* Controlled routing between network segments

---

## Skills Demonstrated

### Systems Administration

* Linux Administration
* Service Management
* Process Monitoring
* System Diagnostics

### Networking

* TCP/IP
* Routing
* VPN Technologies
* Network Troubleshooting
* Subnet Routing

### Virtualization

* Proxmox VE
* LXC Containers
* Resource Allocation
* Container Networking

### Security

* Secure Remote Access
* Network Segmentation
* VPN Deployment
* Infrastructure Hardening Principles

---

## Project Outcomes

* Successfully deployed a virtualized Linux service environment.
* Implemented secure remote access without public service exposure.
* Resolved routing and connectivity issues through structured troubleshooting.
* Improved understanding of Linux networking, VPN technologies, and virtualization platforms.
* Produced reusable documentation and automation scripts for future deployments.

---

## Resume Bullet

* Designed and deployed a virtualized Linux service environment using Proxmox VE, LXC containers, and VPN-based remote access, implementing subnet routing, Linux network administration, and secure infrastructure troubleshooting.

```
```
