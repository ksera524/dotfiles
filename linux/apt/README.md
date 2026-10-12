# Ubuntu apt signing keys

Public vendor signing keys retrieved and verified on 2026-10-12:

| File | Official source | Primary fingerprint |
| --- | --- | --- |
| `docker.asc` | https://download.docker.com/linux/ubuntu/gpg | `9DC858229FC7DD38854AE2D88D81803C0EBFCD88` |
| `tailscale.asc` | https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | `2596A99EAAB33821893C0A79458CA832957F5868` |

The Tailscale binary public key was exported as ASCII armor. No secret keys
are included. mise bootstrap deploys these files before installing vendor
packages; apt verifies repository signatures using each source's Signed-By key.
Update these public keys when the vendor rotates its repository signing key.
