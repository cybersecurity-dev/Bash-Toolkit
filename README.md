# **Bash Toolkit** | _Your Swiss Army Knife for the Command Line_
[![open-source](https://forthebadge.com/images/badges/open-source.svg)](https://cyberthreatdefence.com/)

##  Install SSH server

### Debian based
```bash
sudo apt-get install -y openssh-server && sudo systemctl enable ssh --now
```
### Fedora based
```bash
sudo dnf install -y openssh-server && sudo systemctl enable sshd --now
```
### OpenSUSE based

```bash
sudo zypper install --no-confirm openssh && sudo systemctl enable sshd --now
```


### Verify that ssh service running
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
