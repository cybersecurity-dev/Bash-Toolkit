# **Bash Toolkit** | _Your Swiss Army Knife for the Command Line_
[![open-source](https://forthebadge.com/images/badges/open-source.svg)](https://cyberthreatdefence.com/)


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
and than you will connect via ssh without password but if you entered passphrase, system will ask you this.
