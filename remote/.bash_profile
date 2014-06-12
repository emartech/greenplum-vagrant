# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

export PATH=$PATH:$HOME/bin
export GPHOME=/usr/local/greenplum-db
export MASTER_DATA_DIRECTORY=/gpmaster/gpsne-1


source /usr/local/greenplum-db/greenplum_path.sh
