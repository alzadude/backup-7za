# backup-7za

A simple POSIX-compatible script for backing up a list of folders/directories to an external drive, as encrypted [7-Zip](https://en.wikipedia.org/wiki/7-Zip) archives.

One archive is created for each folder in the list.

An [Expect](https://en.wikipedia.org/wiki/Expect) program is used to pass the encryption password to 7-zip via stdin.

Any errors encountered whilst processing the list of folders will cause the script to exit immediately with non-zero exit status; no more folders in the list will be processed.

## Rationale

Make an encrypted backup of personal data, that is simple for a non-technical person to decrypt (by using commonly available applications like 7-zip, and avoiding the complexities and compatibility issues of encrypted file systems) so that the data can easily be accessed in the event of critical illness or death etc.

## Dependencies

### For Installation (If Installing Using Git)

- git

### For Usage

A POSIX-compatible shell environment, such as any GNU/Linux, Mac OSX (not tested), or WSL on Windows 10, with the following programs installed:

- dirname, rm, mkdir, sed, mv
- expect (and therefore Tcl)
- 7za (from 7-Zip)

## Install

### Using Git
```
git clone https://github.com/alzadude/backup-7za.git
```

## Configure

### List of Directories to Backup

Copy `backup.conf.example` to `backup.conf` and edit `DIRS` as needed.

### Password for Encrypted 7-zip Archives

Create a file called `backup.password` in the project directory, containing the backup password on a single line in plain text.

## Usage

### To Backup

```
mount <backup-device> <mount-point>
cd <location-of-backup-7za-project>
MEDIA=<mount-point> CONFIG=./backup.conf PASSWORD=./backup.password ./backup.sh
```

### To Restore

Connect the external drive containing the backup archives, and then use the 7-Zip application to decrypt and extract the data.

## License

Copyright © 2018 Alex Coyle

Released under the MIT license.
