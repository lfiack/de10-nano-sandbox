# DE10-Nano Sandbox
Projets randoms DE10-nano

## Importer le projet
Le SystemCD contenant la doc (604M!) est ignoré. 
À télécharger à l'adresse suivante : https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=167&No=1046&PartNo=4#contents
Et à mettre dans le dossier systemCD

## NIOS 2 
Pour pouvoir travailler sereinement, il faut lancer la commande suivante : 
```bash
<Quartus installation directory>/nios2eds/nios2_command_shell.sh
```

Avant de lancer eclipse, il faut d'abord l'installer (grmbl). Lire le fichier README dans :
```bash
<Quartus installation directory>/nios2eds/bin/README
```

### Faire fonctionner eclipse (sous Ubuntu 22.04)
Il faut installer des trucs pour utiliser le debugger :
```bash
sudo apt install libfl-dev
sudo apt install libncursesw5-dev
cd /usr/lib/x86_64-linux-gnu/
sudo ln -s libncursesw.so.6.3 libncursesw.so.5
```
