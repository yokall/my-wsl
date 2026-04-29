# Reproducible WSL Setup

A rebuildable WSL Ubuntu development environment powered by Ansible.

## Quick Rebuild

### Step 1: Backup on Current System

```bash
# Backup SSH keys (they are NOT tracked in git)
./scripts/backup-ssh.sh

# Optional: full WSL export as a safety net
wsl --export Ubuntu-24.04 "C:\backups\ubuntu-24.04-backup.vhdx" --format vhd
```

### Step 2: Install Fresh Ubuntu 26.04

In **PowerShell (Admin)**:
```powershell
wsl --unregister Ubuntu-24.04   # only if you want to remove the old one
wsl --install -d Ubuntu-26.04   # install fresh 26.04
```

Complete the initial Ubuntu setup (create `colin` user).

### Step 3: Install Ansible

Ubuntu 26.04 ships with Python 3 but **not** Ansible. You must install Ansible before running the playbook.

#### Option A: Install from Ubuntu packages (recommended)

```bash
# Update package lists first
sudo apt update && sudo apt upgrade -y

# Install Ansible
sudo apt install -y ansible

# Verify installation
ansible --version
```

This installs the version of Ansible packaged by Ubuntu 26.04. It is stable and well-tested.

#### Option B: Install latest version via pip

If you need a newer version of Ansible than what Ubuntu packages provide:

```bash
# Install pip first
sudo apt update
sudo apt install -y python3-pip

# Install Ansible via pip
pip3 install --user ansible

# Ensure ~/.local/bin is in your PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
ansible --version
```

#### Troubleshooting Ansible Installation

**`ansible: command not found` after apt install:**
Run `hash -r` or open a new terminal.

**`ansible: command not found` after pip install:**
Ensure `~/.local/bin` is in your PATH:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Step 4: Clone and Run

```bash
# Clone this repo
git clone <repo-url> ~/my-wsl
cd ~/my-wsl

# Run the playbook
ansible-playbook ansible/playbook.yml -K
# -K prompts for your sudo password
```

### Step 5: Restore SSH Keys

```bash
./scripts/restore-ssh.sh
```

### Step 6: Restore Project Directories

Copy your project directories back from your backup:
```bash
# If you backed up via WSL export, mount the old VHDX or copy files from your backup location
cp -r /path/to/backup/AOC-2025 ~/
cp -r /path/to/backup/learn-ansible ~/
cp -r /path/to/backup/learn-dotnet ~/
cp -r /path/to/backup/rota-generator ~/
# ... etc for each project dir
```

### Step 7: Restart Your Shell

```bash
exec zsh
```

## What This Installs

| Category | Details |
|----------|---------|
| **Shell** | zsh (default), zinit, Powerlevel10k theme |
| **Base** | git, curl, wget, jq, tmux, byobu, vim, build-essential, perl, python3 |
| **Container** | Docker CE, docker-compose, buildx, containerd |
| **Language** | .NET 10 SDK, Python 3 |
| **Cloud** | Google Cloud SDK |

## Repository Structure

```
dotfiles/
  .zshrc          # Shell config with zinit, p10k, ssh-agent
  .p10k.zsh       # Powerlevel10k Pure-style theme config
  .gitconfig      # Git user config
ansible/
  playbook.yml    # Main playbook
  roles/
    base/         # System packages
    shell/        # Zsh + zinit + p10k
    docker/       # Docker CE from official repo
    dotnet/       # .NET 10 SDK
    gcloud/       # Google Cloud SDK
    dotfiles/     # Symlink dotfiles to ~
scripts/
  backup-ssh.sh   # Save SSH keys outside repo
  restore-ssh.sh  # Restore SSH keys with correct permissions
```

## SSH Keys

SSH keys are intentionally NOT tracked in git. Use the backup/restore scripts:

```bash
# On old system
./scripts/backup-ssh.sh    # copies ~/.ssh/* to ~/.ssh-backup/

# Copy ~/.ssh-backup to a safe location (USB, cloud, etc.)

# On new system
./scripts/restore-ssh.sh   # restores ~/.ssh-backup/* to ~/.ssh/
```

## Re-running the Playbook

The playbook is idempotent - safe to run multiple times:
```bash
ansible-playbook ansible/playbook.yml -K
```

## Adding New Packages

To add packages, edit the appropriate role's `tasks/main.yml`:

- System utilities: `ansible/roles/base/tasks/main.yml`
- Dev tools: Add a new role under `ansible/roles/`

Then re-run the playbook.

## Troubleshooting

**Ansible not found after install:** Ensure `~/.local/bin` is in your PATH if using pip.

**Dotfiles not taking effect:** Run `exec zsh` to reload the shell after symlinks are created.

**Docker permission denied:** Log out and back in (or run `newgrp docker`) after Docker installation.

**SSH agent not loading:** The `.zshrc` auto-starts ssh-agent. If keys aren't added, check `~/.ssh/id_ed25519` exists.

**Powerlevel10k prompt not loading:** On first run, you may be prompted to run `p10k configure`. Run it or skip to use the saved configuration.
