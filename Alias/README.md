# Prompt Style

* Kali Linux Style
  ```bash
  PS1='(\u㉿\h)-[\w] - [\D{%d %b %Y %H:%M}]\n\$ '
  ```

  ```
  (user㉿GPUSERVER)-[~/workspace/w_gpu] - [20 Aug 2026 01:27]
  $
  ```

  * Colored Prompt
  ```bash
  PS1='\[\e[1;7m\](\u㉿\h)\[\e[0m\] - [\[\e[1;31m\]\w\[\e[0m\]] - [\[\e[1;35m\]\D{%d %b %Y %H:%M}\[\e[0m\]]\n\$ '
  ```
