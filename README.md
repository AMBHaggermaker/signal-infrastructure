# Signal Infrastructure

Startup scripts, process management config, and tunnel routing for the Unprecedented Times platform running on a Windows 10 host.

## Stack Overview

| Service | Port | Manager | Repo |
|---|---|---|---|
| Ghost CMS | 2368 | Docker | [ghost-platform](https://github.com/AMBHaggermaker/ghost-platform) |
| Open WebUI | — | Docker | — |
| Mycelium API | 3001 | PM2 | [mycelium-backend](https://github.com/AMBHaggermaker/mycelium-backend) |
| Lost & Found API | 3002 | PM2 | [lostfound-backend](https://github.com/AMBHaggermaker/lostfound-backend) |
| Mycelium Frontend | 4200 | startup.bat (npx serve) | [mycelium-frontend](https://github.com/AMBHaggermaker/mycelium-frontend) |
| Lost & Found Frontend | 4201 | startup.bat (npx serve) | [lostfound-frontend](https://github.com/AMBHaggermaker/lostfound-frontend) |
| Cloudflare Tunnel | — | startup.bat (cloudflared) | — |

## Domain Routing (Cloudflare Tunnel)

All traffic enters via a Cloudflare tunnel (`cloudflared`) and is routed to localhost by hostname and path:

| Hostname | Path | Local Service |
|---|---|---|
| unprecedentedtimes.org | * | Ghost :2368 |
| www.unprecedentedtimes.org | * | Ghost :2368 |
| mycelium.unprecedentedtimes.org | /api/* | Mycelium API :3001 |
| mycelium.unprecedentedtimes.org | * | Mycelium Frontend :4200 |
| lostfound.unprecedentedtimes.org | /api/* | Lost & Found API :3002 |
| lostfound.unprecedentedtimes.org | * | Lost & Found Frontend :4201 |

Config: `cloudflared/config.yml` (tunnel ID and credentials redacted — see setup below).

## Boot Sequence

Two mechanisms start services on login:

### 1. Windows Task Scheduler — PM2
A scheduled task (`PM2 Startup`) runs at user logon:
```
C:\Users\User\pm2-startup.bat  →  pm2 resurrect
```
This restores all PM2-managed processes (Mycelium API, Lost & Found API) from the saved dump at `C:\Users\User\.pm2\dump.pm2`.

### 2. startup.bat — Docker + Frontends + Tunnel
`startup.bat` is also triggered at login and handles everything PM2 doesn't:

1. Waits 60 seconds for Docker Desktop to finish loading
2. `docker start ghost` — starts Ghost CMS
3. `docker start open-webui` — starts Open WebUI
4. `npx serve` — serves Mycelium frontend on :4200
5. `npx serve` — serves Lost & Found frontend on :4201
6. `cloudflared tunnel run unprecedented` — opens the Cloudflare tunnel

## PM2 Setup

PM2 manages the two Node.js API backends. To start from the ecosystem file:

```bash
pm2 start pm2/ecosystem.config.js
pm2 save
```

To restore from a saved dump (what the Task Scheduler does on boot):
```bash
pm2 resurrect
```

Useful commands:
```bash
pm2 list               # show all processes
pm2 logs mycelium-api  # stream logs
pm2 restart all        # restart everything
```

## Cloudflare Tunnel Setup

1. Install cloudflared: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/
2. Authenticate: `cloudflared tunnel login`
3. Create tunnel: `cloudflared tunnel create unprecedented`
4. Copy your tunnel ID and credentials JSON path into `cloudflared/config.yml`
5. Route DNS: `cloudflared tunnel route dns unprecedented unprecedentedtimes.org`

The tunnel credential JSON lives at:
```
C:\Users\<USERNAME>\.cloudflared\<YOUR_TUNNEL_ID>.json
```
**Never commit this file.** It is excluded via `.gitignore`.

## Ghost (Docker)

See [ghost-platform](https://github.com/AMBHaggermaker/ghost-platform) for the full Docker run command and restore instructions. Content is persisted at `C:\ghost\data`.

## Local Code Locations

| Repo | Local Path |
|---|---|
| mycelium-backend | `C:\mycelium` |
| lostfound-backend | `C:\lostfound` |
| mycelium-frontend | `C:\mycelium-app` |
| lostfound-frontend | `C:\lostfound-app` |
| ghost content | `C:\ghost\data` |
