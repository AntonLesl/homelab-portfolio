# Commands — 07 Wazuh SIEM

## Install Wazuh (all-in-one)

```bash
curl -sO https://packages.wazuh.com/4.x/wazuh-install.sh
bash ./wazuh-install.sh -a
```
**Why:** Deploys the Wazuh manager, indexer, and dashboard in one step for a single-node lab.
**Where learned:** https://documentation.wazuh.com/current/installation-guide/

## Add / edit custom detection rules

```bash
nano /var/ossec/etc/rules/local_rules.xml
```
**Why:** This is where the six custom MITRE-mapped rules live. Custom rules use IDs in the user range so upgrades don't overwrite them.
**Where learned:** https://documentation.wazuh.com/current/user-manual/ruleset/custom.html

## Restart the manager to load new rules

```bash
systemctl restart wazuh-manager
```
**Why:** Rule changes take effect after restarting the manager.

## Validate the ruleset for syntax errors

```bash
/var/ossec/bin/wazuh-logtest
```
**Why:** Feed a sample log line in to confirm which rule fires — used to verify each custom rule triggers on the intended event before relying on it.
**Where learned:** https://documentation.wazuh.com/current/user-manual/ruleset/testing.html

## Confirm pfSense logs are arriving

```bash
tail -f /var/ossec/logs/archives/archives.log
```
**Why:** Verifies remote syslog from pfSense is actually reaching the manager.
