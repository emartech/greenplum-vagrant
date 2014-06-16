Greenplum VM
------------
---

Enter following commands in your terminal window

```bash
$ git init
$ git clone https://github.com/emartech/greenplum-vagrant.git
$ cd greenplum-vagrant
$ vagrant plugin install vagrant-berkshelf --plugin-version ">= 2.0.1" # in case you haven't done it earlier
$ vagrant up
```



Create a database
-----------------
```bash
$ vagrant ssh
$ sudo su - gpadmin
$ createdb a_database
$ psql a_database
```

The gpadmin user's password is gpadmin.
