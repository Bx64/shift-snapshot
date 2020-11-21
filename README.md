# shift-snapshot
A bash script to automate backups for [**shift-lisk**](https://github.com/ShiftNrg/shift-lisk) blockchain.

**v0.4** - rebuilt script for use with official shift_manager.bash rebuild function.

For more information about the Shift Community Project, please visit: https://shiftnrg.org/

### Upgrade

If you are on a version prior to **v0.4** you can upgrade with the following commands:

```
cd ~/shift-snapshot/ 
git fetch
git reset --hard origin/master
```

## Requisites

    - This script works with postgres and shift_db, configured with shift user;
    - You need to have sudo privileges.

## Installation

Execute the following commands:
```
cd ~/
git clone https://github.com/Bx64/shift-snapshot
cd shift-snapshot/
chmod +x shift-snapshot.sh
./shift-snapshot.sh help
```
If you do not use **pm2** to monitor your node, you should comment or remove lines **55** & **70** by editing the script:
```
nano shift-snapshot.sh
```

## Available commands

    - create
    - restore
    - help

### create

Command _create_ is used to create a new snapshot. Example of usage:<br>
`bash shift-snapshot.sh create`<br>
This wil automatically create a snapshot file in the shift-lisk/ installation folder.<br>
It does not require you to stop your node's app.js instance.<br>
Example of output:<br>
```
   + Creating snapshot                                
  -------------------------------------------------- 
  OK snapshot created successfully at block  4628362 (0.7G).
```

### restore

Command _restore_ is used to rebuild the created snapshot using the official shift_manager rebuild function.<br>
Example of usage:<br>
`bash shift-snapshot.sh restore`<br>
<br>

### Schedule

To create scheduled snapshots, you can add one of these commands to `cronatab -e`:

```
@hourly cd ~/shift-snapshot && bash shift-snapshot.sh create

@daily cd ~/shift-snapshot && bash shift-snapshot.sh create

@weekly cd ~/shift-snapshot && bash shift-snapshot.sh create

@monthly cd ~/shift-snapshot && bash shift-snapshot.sh create
```

-------------------------------------------------------------

### Notice

This script adaptation is purely to make snapshots compatible with the official rebuild function.
It will not append the snapshots with dates, nor log the snapshots made. If you want that functionality, consider [Mx's script](https://github.com/MxShift/shift-snapshot).
