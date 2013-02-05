NetID Tools
===========

NetID Tools is a Ruby Gem that contains various methods for supporting Uniform Access computing at the University of Washington. These are mainly methods that I've found useful to create during the course of my job, but may be useful to others as well.

Currently the focus is on finding and displaying information on any MySQL database server(s) that users may be running, as well as highlight potential quota issues. 

## Installing

	gem install netid-tools

## Usage Notes

* Using keybased SSH authentication is highly recommended, both from your system->UA, and for UA->UA.
** To accomplish this, copy the contents of your ~/.ssh/id_rsa.pub to your ~/.ssh/authorized_keys
* You may need membership of certain Unix Groups in order to run some of these checks.

## Dependencies

* Ruby 1.9
* Nokogiri
* Colored

Executables
===========

`ua_check` is provided as an included executable.

## Example

	nikky@uvb76:~/Repositories/www ☿  on default at tip % ua_check nikky
	Running UA Check for NetID nikky on behalf of nikky

	MySQLd detected on ovid02.u.washington.edu:5280
	/ov03/d20/nikky

	Disk quotas for nikky (uid 247520):
	Filesystem        Usage      Quota      Limit       Grace   Files  Limit
	/cg32a           15.574   5120.000   105120.0                 219  10000
	/da21            17.523   1937.254     5370.0                1535  10000
	etc

Methods
=======

## Netid#validate_netid?(netid)

### What it does

This class method will return a true/false depending on if a given string could potentially be a NetID. It does not check to see if the NetID exists; only if a NetID has a valid structure. Namely:

* 1-8 Characters in length
* First character is *not* a number
* Only a word characters [a-zA-Z0-9]

### Example

	>> require 'netid-tools'
	=> true
	>> Netid.validate_netid?("nikky")
	=> true
	>> Netid.validate_netid?("1nikky")
	=> false
	>> Netid.validate_netid?("1nikky111")
	=> false
	>> Netid.validate_netid?("nikky@1")
	=> false

## Netid#check_for_mysql_presence(host,user,system_user)

### What it does

This class method will check to see if a specific NetID is running a MySQL instance on a specified host. It will return false if no MySQL server is found, and return [host,port] if true.

### Method variables

#### host

The FQDN of the server you want to check for MySQL

#### user

The NetID you want to check

#### system_user

*Your* NetID, required for login to the host.

### Example

	>> Netid.check_for_mysql_presence("ovid02.u.washington.edu","nikky","nikky")
	=> ["ovid02.u.washington.edu", "5280"]

## Netid#check_for_localhome(user,system_user)

### What it does

Checks to see if a user has a localhome, and if they do, return the location.

### Method variables

#### user

The NetID you want to check

#### system_user

*Your* NetID, required for login to the host.

### Example

	>> Netid.check_for_localhome("nikky","nikky")
	=> "/ov03/d20/nikky"

## Netid#quota_check(user,system_user)

### What it does

Spits out various quota information, and highlights a line in red if a user is over quota. This writes directly to stdout.

### Method variables

#### user

The NetID you want to check

#### system_user

*Your* NetID, required for login to the host.

Version History
===============

## 0.3.8

* Remove ovid21.u.washington.edu from host list; retired system

## 0.3.7

* Allow validate_netid? to return true for NetIDs that have a hyphen in them

## 0.3.6

* Add concise mode via -c flag to ua_check (skips quota results)
* Add OptionParser to ua_check
* Tweak formatting for results
* Allow multiple lookups per execption

## 0.3.3

* Fix broken code so that it properly displays localhome

## 0.3.2

* Added install notes

## 0.3.1

* Initial documented release
* Swich to Apache License

## 0.3.0

Initial release
