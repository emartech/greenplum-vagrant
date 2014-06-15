Greenplum VM
--------------
--------------
Enter following commands in your terminal window
```
$ git init
$ git clone https://github.com/kailashjoshi/greenplum.git
$ cd greenplum
$ vagrant up
```

Test the installation
--------------
--------------
1. Run "gpstate" from your terminal window

If you see no error when running gpstate, that means Greenplum has been sucessfully completed.

## Using a sample database ##

You may also wish to experiment with a sample database. If you are **not** currently logged into the mdw machine as
gpadmin, make sure to log in there first (same as above steps)

> 1. vagrant ssh gpdb
> 2. su - gpadmin
> 3. Enter the password. The password is "gpadmin"

As user gpadmin...
```
$ createdb world
$ psql world
```





emarsys
