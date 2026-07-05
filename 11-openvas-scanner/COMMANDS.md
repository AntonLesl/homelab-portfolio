# Commands — 11 OpenVAS / Greenbone

## Install Docker in the container

```bash
curl -fsSL https://get.docker.com | sh
```
**Why:** The Greenbone Community stack is distributed as Docker containers, so Docker must be present inside the LXC first.
**Where learned:** https://docs.docker.com/engine/install/

## Deploy Greenbone Community Edition

```bash
curl -fsSL https://greenbone.github.io/docs/latest/_static/setup-and-start-greenbone-community-edition.sh -o gce-setup.sh
bash gce-setup.sh
```
**Why:** Official setup script that pulls and starts the full Greenbone stack (gvmd, ospd-openvas, scanner, GSA web UI, PostgreSQL, redis, feed data). Used after the Proxmox community helper script turned out to be dead. See ISSUES.md.
**Where learned:** https://greenbone.github.io/docs/latest/22.4/container/index.html

## Watch the feed sync

```bash
docker compose logs -f
```
**Why:** The vulnerability feed sync takes a long time and is disk-heavy; the logs show progress and surface disk-full errors early.

## Check disk usage (feed + images are large)

```bash
df -h
```
**Why:** The Docker images and vulnerability feed repeatedly filled the disk during setup (see ISSUES.md). This is the fast check before/after expanding storage.

## Set the admin password (GVM)

```bash
docker compose exec -u gvmd gvmd gvmd --user=admin --new-password='[password]'
```
**Why:** Sets the web UI admin credential after the stack is up.
**Where learned:** https://greenbone.github.io/docs/latest/22.4/container/index.html
