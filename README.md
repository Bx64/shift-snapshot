# shift-snapshot
A bash script to automate backups for [**shift-lisk**](https://github.com/ShiftNrg/shift-lisk) blockchain

**v0.4** - rebuilt script for use with official shift_manager.bash rebuild function.

For more information about Shift Community Project please visit: https://shiftproject.com/

### Upgrade

If you are in a version prior to **v0.4** you can upgrade with the following commands:

```
cd ~/shift-snapshot/ 
git fetch
git reset --hard origin/master
```

## Requisites
    - This script works with postgres and shift_db, configured with shift user
    - You need to have sudo privileges

## Installation

Execute the following commands:
```
cd ~/
git clone https://github.com/Bx64/shift-snapshot
cd shift-snapshot/
chmod +x shift-snapshot.sh
./shift-snapshot.sh help
```

## Available commands

    - create
    - restore
    - help

### create

Command _create_ is for create new snapshot, example of usage:<br>
`bash shift-snapshot.sh create`<br>
Automaticly will create a snapshot file in the shift-lisk/ installation folder.<br>
Don't require to stop you node app.js instance.<br>
Example of output:<br>
```
   + Creating snapshot                                
  -------------------------------------------------- 
  OK snapshot created successfully at block  4628362 (0.7G).
```

### restore

Command _restore_ is to rebuild the created snapshot using the official shift_manager rebuild function.<br>
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