# Chef Cookbook — Automated Web Server Setup

A custom Chef cookbook (`zain_web`) that sets up an nginx web server automatically using **chef-solo in local mode** — no Chef Server needed. One converge installs nginx, deploys a branded index page from an ERB template (with the machine's real hostname and OS rendered into the page), and enables + starts the nginx service.

Publisher: **Zain Tech Automation Solutions** — Automate. Accelerate. Achieve.

## Status

**Complete — verified by an actual run** (see "Verified run" below). A second converge changed nothing: 0/5 resources updated, which is the idempotency proof.

## How it works

- `cookbooks/zain_web/metadata.rb` — cookbook name, maintainer, version, supported platforms
- `cookbooks/zain_web/recipes/default.rb` — the recipe: `package` (nginx, curl), `template` (index page), `service` (nginx enable + start) resources
- `cookbooks/zain_web/templates/index.html.erb` — ERB template; Chef fills in `node['hostname']`, `node['platform']` and `node['platform_version']` from ohai data at converge time
- `solo.rb` — tells chef-solo where the cookbooks and cache live (paths use the local username — adjust to your own)
- `web.json` — the run list: `recipe[zain_web::default]`

## Run it yourself

```bash
# Chef Workstation installed (free), then:
sudo chef-solo --chef-license accept -c solo.rb -j web.json
curl http://localhost
# Run the converge again — expect 0 resources updated (idempotent)
```

## Tech stack

Chef Infra Client 18.10.17 · Chef Workstation 25.14.2 · chef-solo (local mode) · Ruby (recipe DSL) · ERB templates · nginx · Kali Linux 2026.3

## Free / honesty note

Chef Workstation and chef-solo local mode are free to use and were the only Chef products used here. Chef Automate and hosted Chef Server are paid enterprise products and were **not** used.

## What I learned

- A **cookbook** is a versioned package of configuration; a **recipe** is the Ruby file inside it that declares the desired state.
- A **resource** (package / template / service) describes *what* should be true, not the steps to make it true — Chef works out the steps.
- **Converge** = Chef comparing the machine with the recipe and fixing only the differences. Running it twice with zero changes the second time is **idempotency**.
- ohai collects the machine facts (platform, hostname, memory) that templates and recipes can use.

## Challenges faced (and fixed)

- **VM clock was ~13 hours ahead on the wrong timezone (EST)** — fixed with `timedatectl set-timezone Asia/Karachi` + NTP before installing anything, so TLS downloads would validate.
- **Disk filled to 100% mid-project** (the Chef install plus old Docker data) — freed ~15 GB by pruning unused Docker images/containers/volumes from completed projects; all project proof was already on GitHub.
- **Cookbook path in solo.rb** had to match the real home directory (`/home/zain/...`), not the tutorial's example user — a wrong path is the first thing to check when chef-solo says a cookbook is not found.

## Verified run

Environment: Kali Linux 2026.3 VM · Chef Workstation 25.14.2 · Chef Infra Client 18.10.17 · ohai platform `kali`, version `2026.3`

**First converge** — `sudo chef-solo --chef-license accept -c solo.rb -j web.json`:

```
Infra Phase complete, 3/5 resources updated in 43 seconds
```

The template rendered the live page with the machine's real values filled in:

```
<h1>Zain Tech Automation Solutions</h1>
<p>Is machine ka hostname: kali</p>
<p>Is machine ka OS: kali 2026.3</p>
```

and the run ended with `service[nginx] action enable` + `service[nginx] action start` applied.

**Second converge** (idempotency check) — same command:

```
* apt_package[nginx] action install (up to date)
* apt_package[curl] action install (up to date)
* template[/var/www/html/index.html] action create (up to date)
* service[nginx] action enable (up to date)
* service[nginx] action start (up to date)
Infra Phase complete, 0/5 resources updated in 50 seconds
```
