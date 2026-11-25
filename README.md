# Forgejo Runner Image (`rusc-runner`)

Imatge base personalitzada i optimitzada per a runners efímers de **Forgejo Actions** al cluster K3s (`rusc.local`).

## Objectiu i Arquitectura

Al nostre homelab, els runners d'accions de Forgejo s'executen com a contenidors efímers gestionats per `forgejo-runner-provisioner` sobre un backend **Podman rootless**.

Per evitar problemes de `runc` amb Docker Buildx dins d'entorns d'espais de noms rootless i reduir dràsticament el temps de descàrrega i arrancada de cada treball de CI/CD, fem servir una arquitectura de **doble runner**:

1. **`rusc-runner`** (`docker://git.rusc.local/vdk84/forgejo-runner-image:latest`):
   - Imatge tunejada pròpia amb totes les eines essencials i la CA arrel interna ja preinstal·lades.
   - És el runner per defecte per a tots els fluxos de treball (`runs-on: rusc-runner`).
2. **`node-slim`** (`docker://node:22-bookworm-slim`):
   - Imatge genèrica oficial de suport i arrencada (*bootstrap*).
   - Resol el problema de l'ou i la gallina: construeix la pròpia imatge `forgejo-runner-image` sense dependre que aquesta existeixi prèviament al registre de paquets intern.
   - Serveix com a paracaigudes manual per a qualsevol build en cas d'incidència amb la imatge tunejada.

## Eines Incloses

Aquesta imatge està basada en `node:22-bookworm-slim` i inclou:

- **Certificats SSL/TLS**:
  - `ca-certificates` actualitzats.
  - CA arrel interna de **Smallstep** (`smallstep-root-ca.crt`), amb variables `NODE_EXTRA_CA_CERTS` i `SSL_CERT_FILE` configurades perquè NodeJS, curl, git i Python confiïn immediatament en els serveis interns (`*.rusc.local`).
- **Control de versions i xarxa**:
  - `git`
  - `curl`
  - `wget`
  - `openssh-client`
- **Utilitats de sistema i dades**:
  - `jq`
  - `unzip`, `tar`, `xz-utils`
- **Gestió de contenidors**:
  - `podman` (apuntant de forma remota al socket `/var/run/docker.sock` muntat pel runner).

## Com es Construeix (Bootstrap amb `node-slim`)

El workflow `.forgejo/workflows/build-runner-image.yaml`:
- S'executa amb `runs-on: node-slim`.
- Instal·la en un pas previ de bootstrap les utilitats mínimes necessàries per fer el `checkout` i cridar `podman --remote`.
- Construeix i puja la imatge a `git.rusc.local/vdk84/forgejo-runner-image` etiquetada amb:
  - `latest`
  - SemVer automàtic (`vX.Y.Z`, `X.Y.Z`, `vX.Y`, `vX`)
  - Commit SHA

## Reconstrucció Manual

Per llançar una nova versió o reconstruir la imatge manualment:
1. Accedeix a **Forgejo** (`https://git.rusc.local/vdk84/forgejo-runner-image/actions`).
2. Selecciona el workflow **"Build and Push Forgejo Runner Image"**.
3. Fes clic a **Run workflow** i, si cal, selecciona el tipus d'increment SemVer desitjat (`auto`, `patch`, `minor`, `major`).
