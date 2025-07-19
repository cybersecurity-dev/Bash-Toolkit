# **Bash Toolkit** | _Your Swiss Army Knife for the Command Line_
[![YouTube](https://img.shields.io/badge/YouTube-%23FF0000.svg?style=for-the-badge&logo=YouTube&logoColor=white)](https://youtube.com/playlist?list=PL9V4Zu3RroiVE4xP0WgiRLa_Fiszl83s0&si=bUeRrjG-EsewaOnO) [![Reddit](https://img.shields.io/badge/Reddit-FF4500?style=for-the-badge&logo=reddit&logoColor=white)](https://www.reddit.com/r/bash/)
<p align="center">
    <a href="https://github.com/cybersecurity-dev/"><img height="25" src="https://github.com/cybersecurity-dev/cybersecurity-dev/blob/main/assets/github.svg" alt="GitHub"></a>
    &nbsp;
    <a href="https://www.youtube.com/@CyberThreatDefence"><img height="25" src="https://github.com/cybersecurity-dev/cybersecurity-dev/blob/main/assets/youtube.svg" alt="YouTube"></a>
    &nbsp;
    <a href="https://cyberthreatdefence.com/my_awesome_lists"><img height="20" src="https://github.com/cybersecurity-dev/cybersecurity-dev/blob/main/assets/blog.svg" alt="My Awesome Lists"></a>
    <img src="https://github.com/cybersecurity-dev/cybersecurity-dev/blob/main/assets/bar.gif">
</p>

##  Install SSH server

* [![Debian](https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=fff)](#)
  ```bash
  sudo apt-get install -y openssh-server && sudo systemctl enable ssh --now
  ```
* [![Fedora](https://img.shields.io/badge/Fedora-51A2DA?logo=fedora&logoColor=fff)](#)
  ```bash
  sudo dnf install -y openssh-server && sudo systemctl enable sshd --now
  ```
* [![openSUSE](https://img.shields.io/badge/openSUSE-73BA25?style=flat&logo=SUSE&logoColor=white)](#)
  ```bash
  sudo zypper install --no-confirm openssh && sudo systemctl enable sshd --now
  ```

* Add Firewall Rure
  ```bash
  sudo firewall-cmd --permanent --add-service=ssh && sudo firewall-cmd --reload
  ```

## Verify that ssh service running
```bash
sudo systemctl status ssh
```

## Generate ssh-key
```bash
ssh-keygen -t rsa
```

```console
Generating public/private rsa key pair.
Enter file in which to save the key (/home/user/.ssh/id_rsa):
Created directory '/home/user/.ssh'.
Enter passphrase (empty for no passphrase):
```
After that you will see public key :
```console
Your public key has been saved in /home/user/.ssh/id_rsa.pub
The key fingerprint is: ...
```
copy fingerprint and paste into: 
```bash
vim /home/user_remote/.ssh/authorized_keys
```
or copy and install the public key using `ssh-copy-id` command in Linux

```bash
ssh-copy-id user_remote@user_remote_ip
```

and than you will connect via ssh without password but if you entered passphrase, system will ask you this.


## Install Applications
### Programming Language
#### Rust
  * [![Debian](https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=fff)](https://www.debian.org/)
    ```bash
    sudo apt-get update && sudo apt-get install -y rustc && rustc -V 
    ```
  * [![Fedora](https://img.shields.io/badge/Fedora-51A2DA?logo=fedora&logoColor=fff)](https://www.fedoraproject.org/)
    ```bash
    sudo dnf upgrade --refresh && sudo dnf install -y rustc && rustc -V
    ```
  * [![openSUSE](https://img.shields.io/badge/openSUSE-73BA25?style=flat&logo=SUSE&logoColor=white)](https://www.opensuse.org/)
    ```bash
    sudo zypper refresh && sudo zypper install -y rustc && rustc -V
    ```
  * Windows Subsystem for Linux
    ```bash
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    ```
